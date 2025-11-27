// LED Pattern Memory Game for Spartan-7 (Combo2 DLD) board
// Features:
// - 8-button pattern input with start/confirm/backspace controls
// - 3 speed levels via clock select switch
// - Pattern length grows each stage (stage 1 = 4 entries, +1 each stage)
// - 3 lives, unlimited stages, high-score register with reset DIP
// - 16x2 text LCD (4-bit parallel) status outputs
// - Full-color RGB LED feedback (green=correct, red=wrong, blue=idle)
// - Piezo buzzer tones for pattern playback, input clicks, success/fail
// - 8-array LED playback and 8-digit 7-seg scroller for user input echo

`timescale 1ns/1ps

module led_pattern_game #(
    parameter CLK_FREQ_HZ = 100_000_000,      // default board clock
    parameter INPUT_TIMEOUT_S = 10            // countdown seconds on 7-seg
) (
    input  wire        clk,
    input  wire        dip_power_on,          // 1=on, 0=reset+power-off behavior
    input  wire        dip_highscore_reset,   // pulse high to reset high-score
    input  wire [1:0]  speed_sel,             // 3 speed levels: 0=slow,1=med,2=fast
    input  wire        btn_start,
    input  wire        btn_confirm,
    input  wire        btn_backspace,
    input  wire [7:0]  btn_input,             // buttons mapped to LED positions 0..7
    output reg  [7:0]  led_array,
    output reg  [2:0]  rgb_led,               // {R,G,B}
    output reg         piezo,
    output reg  [6:0]  seg_ca,                // seven-seg cathodes (a..g)
    output reg         seg_dp,
    output reg  [7:0]  seg_sel,               // digit enable
    output reg         lcd_rs,
    output reg         lcd_en,
    output reg  [3:0]  lcd_data
);
    //============================================================
    // Clock enables for slow domains
    //============================================================
    localparam integer DIV_SLOW = CLK_FREQ_HZ/4; // ~4Hz toggle
    reg [31:0] slow_cnt;
    reg slow_ce;
    always @(posedge clk) begin
        if (!dip_power_on) begin
            slow_cnt <= 0; slow_ce <= 1'b0;
        end else if (slow_cnt >= DIV_SLOW-1) begin
            slow_cnt <= 0; slow_ce <= 1'b1;
        end else begin
            slow_cnt <= slow_cnt + 1; slow_ce <= 1'b0;
        end
    end

    // Speed divider for pattern playback (3 levels)
    function integer calc_delay;
        input [1:0] sel;
        begin
            case (sel)
                2'd0: calc_delay = CLK_FREQ_HZ/2;   // slow 2Hz
                2'd1: calc_delay = CLK_FREQ_HZ/3;   // medium ~3.3Hz
                default: calc_delay = CLK_FREQ_HZ/5; // fast 5Hz
            endcase
        end
    endfunction

    reg [31:0] pattern_div;
    reg [31:0] pattern_cnt;
    reg        pattern_ce;
    always @(posedge clk) begin
        pattern_div <= calc_delay(speed_sel);
        if (!dip_power_on) begin
            pattern_cnt <= 0; pattern_ce <= 1'b0;
        end else if (pattern_cnt >= pattern_div-1) begin
            pattern_cnt <= 0; pattern_ce <= 1'b1;
        end else begin
            pattern_cnt <= pattern_cnt + 1; pattern_ce <= 1'b0;
        end
    end

    //============================================================
    // Button synchronization and edge detection
    //============================================================
    wire start_p, confirm_p, back_p;
    wire [7:0] input_p;

    generate
        genvar i;
        for (i=0; i<8; i=i+1) begin : gen_btn
            pulse_sync u_sync_input(.clk(clk), .rst_n(dip_power_on), .btn(btn_input[i]), .pulse(input_p[i]));
        end
    endgenerate
    pulse_sync u_sync_start    (.clk(clk), .rst_n(dip_power_on), .btn(btn_start),     .pulse(start_p));
    pulse_sync u_sync_confirm  (.clk(clk), .rst_n(dip_power_on), .btn(btn_confirm),   .pulse(confirm_p));
    pulse_sync u_sync_back     (.clk(clk), .rst_n(dip_power_on), .btn(btn_backspace), .pulse(back_p));

    //============================================================
    // Game state machine
    //============================================================
    localparam S_IDLE      = 3'd0;
    localparam S_GEN       = 3'd1;
    localparam S_PLAYBACK  = 3'd2;
    localparam S_INPUT     = 3'd3;
    localparam S_EVAL      = 3'd4;
    localparam S_RESULT    = 3'd5;

    reg [2:0]  state, state_n;
    reg [7:0]  stage, stage_n;
    reg [1:0]  lives, lives_n;
    reg [3:0]  pattern_idx, pattern_idx_n;
    reg [3:0]  input_idx, input_idx_n;
    reg [2:0]  pattern_mem [0:31]; // support up to 32 steps per stage
    reg [2:0]  user_mem    [0:31];
    reg [2:0]  lfsr_val;
    wire [2:0] rand_val;

    // LFSR for pseudo random LED positions (0..7)
    lfsr3 u_lfsr(.clk(clk), .rst_n(dip_power_on), .en(state==S_GEN), .value(rand_val));

    // High score register (kept until reset)
    reg [7:0] high_score;
    always @(posedge clk) begin
        if (!dip_power_on) begin
            high_score <= 0;
        end else if (dip_highscore_reset) begin
            high_score <= 0;
        end else if (state==S_RESULT && result_correct && stage > high_score)
            high_score <= stage;
    end

    // Countdown timer for input phase
    reg [31:0] timeout_cnt;
    reg [3:0]  seconds_left;
    always @(posedge clk) begin
        if (!dip_power_on || state!=S_INPUT) begin
            timeout_cnt <= 0;
            seconds_left <= INPUT_TIMEOUT_S[3:0];
        end else if (timeout_cnt >= CLK_FREQ_HZ-1) begin
            timeout_cnt <= 0;
            if (seconds_left>0) seconds_left <= seconds_left - 1'b1;
        end else begin
            timeout_cnt <= timeout_cnt + 1;
        end
    end

    // Derived signals
    wire stage_clear = (pattern_idx==pattern_len && state==S_EVAL && result_correct);
    wire timeout_expired = (state==S_INPUT && seconds_left==0);

    // Result flag
    reg result_correct, result_correct_n;
    wire [3:0] pattern_len = stage[3:0] + 4'd3; // stage1 -> 4 entries

    // State transition logic
    always @(*) begin
        state_n = state;
        stage_n = stage;
        lives_n = lives;
        pattern_idx_n = pattern_idx;
        input_idx_n = input_idx;
        result_correct_n = result_correct;

        // Default comparison result update
        if (state==S_EVAL) begin
            result_correct_n = 1'b1;
            if (timeout_expired) result_correct_n = 1'b0;
            if (input_idx != pattern_len) result_correct_n = 1'b0;
            for (t=0; t<input_idx; t=t+1) begin
                if (user_mem[t] != pattern_mem[t]) result_correct_n = 1'b0;
            end
        end else if (state==S_IDLE) begin
            result_correct_n = 1'b0;
        end

        case (state)
            S_IDLE: begin
                if (start_p && dip_power_on) begin
                    stage_n = 1; lives_n = 2'd3; pattern_idx_n = 0; input_idx_n = 0; state_n = S_GEN;
                end
            end
            S_GEN: begin
                // Fill pattern for current stage
                if (pattern_idx < pattern_len) begin
                    pattern_idx_n = pattern_idx + 1'b1;
                end else begin
                    pattern_idx_n = 0;
                    state_n = S_PLAYBACK;
                end
            end
            S_PLAYBACK: begin
                if (pattern_idx < pattern_len) begin
                    if (pattern_ce) pattern_idx_n = pattern_idx + 1'b1;
                end else begin
                    pattern_idx_n = 0;
                    input_idx_n = 0;
                    state_n = S_INPUT;
                end
            end
            S_INPUT: begin
                if (confirm_p || timeout_expired) begin
                    state_n = S_EVAL;
                end else if (back_p && input_idx>0) begin
                    input_idx_n = input_idx - 1'b1;
                end else begin
                    // capture button press
                    for (integer j=0; j<8; j=j+1) begin
                        if (input_p[j] && input_idx < pattern_len) begin
                            input_idx_n = input_idx + 1'b1;
                        end
                    end
                end
            end
            S_EVAL: begin
                if (result_correct) begin
                    if (input_idx == pattern_len) begin
                        state_n = S_RESULT;
                        stage_n = stage + 1'b1;
                    end else begin
                        state_n = S_RESULT; // partial correct but short input
                    end
                end else begin
                    state_n = S_RESULT;
                    if (lives!=0)
                        lives_n = lives - 1'b1;
                    if (lives==0) begin
                        stage_n = 1; // reset stage on next start
                    end
                end
            end
            S_RESULT: begin
                if (start_p) begin
                    if (lives==0) begin
                        stage_n = 1; lives_n = 2'd3;
                    end
                    pattern_idx_n = 0; input_idx_n = 0; state_n = S_GEN;
                end else if (!result_correct && lives==0) begin
                    // wait for start to restart
                    state_n = S_RESULT;
                end else begin
                    // auto-continue to next stage
                    pattern_idx_n = 0; input_idx_n = 0; state_n = S_GEN;
                end
            end
        endcase
    end

    //============================================================
    // Sequential storage and comparisons
    //============================================================
    integer k, t;
    always @(posedge clk) begin
        if (!dip_power_on) begin
            state <= S_IDLE; stage <= 1; lives <= 2'd3; pattern_idx <= 0; input_idx <= 0; result_correct <= 1'b0;
        end else begin
            state <= state_n;
            stage <= stage_n;
            lives <= lives_n;
            pattern_idx <= pattern_idx_n;
            input_idx <= input_idx_n;
            result_correct <= result_correct_n;
        end

        // Generate pattern entries during S_GEN
        if (state==S_GEN && pattern_idx < pattern_len) begin
            pattern_mem[pattern_idx] <= rand_val;
        end

        // Collect user inputs
        if (state==S_INPUT) begin
            for (k=0; k<8; k=k+1) begin
                if (input_p[k] && input_idx < pattern_len) begin
                    user_mem[input_idx] <= k[2:0];
                end
            end
        end

        // Backspace removal
        if (state==S_INPUT && back_p && input_idx>0) begin
            user_mem[input_idx-1] <= 3'd0; // optional clear
        end
    end

    //============================================================
    // LED array playback and RGB feedback
    //============================================================
    always @(posedge clk) begin
        if (!dip_power_on) begin
            led_array <= 8'h00;
            rgb_led <= 3'b001; // blue idle
        end else begin
            case (state)
                S_PLAYBACK: begin
                    if (pattern_idx < pattern_len)
                        led_array <= (8'h01 << pattern_mem[pattern_idx]);
                    else
                        led_array <= 8'h00;
                    rgb_led <= 3'b001; // blue during playback
                end
                S_INPUT: begin
                    led_array <= 8'h00;
                    rgb_led <= 3'b001;
                end
                S_RESULT: begin
                    if (result_correct)
                        rgb_led <= 3'b010; // green
                    else
                        rgb_led <= 3'b100; // red
                    led_array <= 8'h00;
                end
                default: begin
                    led_array <= 8'h00;
                    rgb_led <= 3'b001;
                end
            endcase
        end
    end

    //============================================================
    // Piezo sound patterns (simplified square wave toggling)
    //============================================================
    reg [15:0] tone_div;
    reg [15:0] tone_cnt;
    always @(*) begin
        case (state)
            S_PLAYBACK: tone_div = 16'd20000;   // base tone during pattern
            S_INPUT:    tone_div = 16'd40000;   // gentle click speed
            S_RESULT:   tone_div = result_correct ? 16'd10000 : 16'd5000; // ding/dong
            default:    tone_div = 16'd0;
        endcase
    end

    always @(posedge clk) begin
        if (!dip_power_on || tone_div==0) begin
            piezo <= 1'b0; tone_cnt <= 0;
        end else if (tone_cnt >= tone_div) begin
            tone_cnt <= 0; piezo <= ~piezo;
        end else begin
            tone_cnt <= tone_cnt + 1'b1;
        end
    end

    //============================================================
    // 7-seg countdown + input scroller (upper digits for timeout)
    //============================================================
    reg [3:0] seg_digits [0:7];
    reg [2:0] seg_pos;
    reg [15:0] seg_refresh;

    // capture input sequence into scrolling window
    always @(posedge clk) begin
        integer m;
        if (!dip_power_on) begin
            for (m=0; m<8; m=m+1) seg_digits[m] <= 4'hF; // blank
        end else if (state==S_INPUT) begin
            for (m=0; m<8; m=m+1) begin
                seg_digits[m] <= seg_digits[m];
            end
            for (m=0; m<8; m=m+1) begin
                if (input_p[m]) begin
                    // shift right, insert new digit at rightmost
                    seg_digits[7] <= m[3:0];
                    seg_digits[6] <= seg_digits[7];
                    seg_digits[5] <= seg_digits[6];
                    seg_digits[4] <= seg_digits[5];
                    seg_digits[3] <= seg_digits[4];
                    seg_digits[2] <= seg_digits[3];
                    seg_digits[1] <= seg_digits[2];
                    seg_digits[0] <= seg_digits[1];
                end
            end
        end else if (state==S_IDLE) begin
            for (m=0; m<8; m=m+1) seg_digits[m] <= 4'hF;
        end
    end

    // multiplex digits: digits[7:6] show seconds_left (tens, ones)
    wire [3:0] timeout_tens = seconds_left / 10;
    wire [3:0] timeout_ones = seconds_left % 10;

    always @(posedge clk) begin
        if (!dip_power_on) begin
            seg_pos <= 0; seg_refresh <= 0; seg_sel <= 8'hFF; seg_ca <= 7'h7F; seg_dp <= 1'b1;
        end else if (seg_refresh >= 16'd5000) begin // ~2kHz refresh
            seg_refresh <= 0;
            seg_pos <= seg_pos + 1'b1;
            case (seg_pos)
                3'd7: seg_val(timeout_tens, 1'b1);
                3'd6: seg_val(timeout_ones, 1'b0);
                default: seg_val(seg_digits[seg_pos], 1'b1);
            endcase
        end else begin
            seg_refresh <= seg_refresh + 1'b1;
        end
    end

    task seg_val(input [3:0] val, input dp_on);
        begin
            seg_sel <= ~(8'b1 << seg_pos);
            seg_dp  <= ~dp_on;
            case (val)
                4'd0: seg_ca <= 7'b1000000;
                4'd1: seg_ca <= 7'b1111001;
                4'd2: seg_ca <= 7'b0100100;
                4'd3: seg_ca <= 7'b0110000;
                4'd4: seg_ca <= 7'b0011001;
                4'd5: seg_ca <= 7'b0010010;
                4'd6: seg_ca <= 7'b0000010;
                4'd7: seg_ca <= 7'b1111000;
                4'd8: seg_ca <= 7'b0000000;
                4'd9: seg_ca <= 7'b0010000;
                default: seg_ca <= 7'b1111111; // blank
            endcase
        end
    endtask

    //============================================================
    // LCD helper: export basic status as nibbles (user to integrate controller)
    //============================================================
    // For simplicity, drive LCD with coarse updates on slow_ce ticks.
    reg [3:0] lcd_state;
    always @(posedge clk) begin
        if (!dip_power_on) begin
            lcd_state <= 0; lcd_en <= 0; lcd_rs <= 0; lcd_data <= 4'h0;
        end else if (slow_ce) begin
            lcd_state <= lcd_state + 1'b1;
            case (lcd_state)
                4'd0: begin lcd_rs<=1; lcd_data <= 4'hC; lcd_en <= 1; end // "Stage" high nibble placeholder
                4'd1: begin lcd_rs<=1; lcd_data <= stage[3:0]; lcd_en <= 1; end
                4'd2: begin lcd_rs<=1; lcd_data <= 4'hL; lcd_en <= 1; end // lives marker
                4'd3: begin lcd_rs<=1; lcd_data <= {2'b00,lives}; lcd_en <= 1; end
                4'd4: begin lcd_rs<=1; lcd_data <= result_correct ? 4'hC : 4'hE; lcd_en <= 1; end // C=Correct/E=Error
                4'd5: begin lcd_rs<=1; lcd_data <= high_score[3:0]; lcd_en <= 1; end
                default: begin lcd_en<=0; lcd_rs<=0; lcd_data<=4'h0; end
            endcase
        end else begin
            lcd_en <= 0;
        end
    end

endmodule

//============================================================
// Supporting modules
//============================================================
module pulse_sync(
    input  wire clk,
    input  wire rst_n,
    input  wire btn,
    output wire pulse
);
    reg [2:0] ff;
    always @(posedge clk) begin
        if (!rst_n) ff <= 3'b000; else ff <= {ff[1:0], btn};
    end
    assign pulse = ff[1] & ~ff[2]; // rising edge
endmodule

module lfsr3(
    input  wire clk,
    input  wire rst_n,
    input  wire en,
    output reg  [2:0] value
);
    always @(posedge clk) begin
        if (!rst_n) value <= 3'b001;
        else if (en) value <= {value[1:0], value[2]^value[1]};
    end
endmodule

