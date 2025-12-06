// simple_memory_game.v
// Core memory game: Random pattern -> Show -> Input -> Compare -> Next
module simple_memory_game(
    input clk,
    input [7:0] dip_sw,
    input [11:0] btn,
    output reg [7:0] led,
    output [7:0] seg_timer_data,
    output reg [7:0] seg_arr_data,
    output reg [7:0] seg_arr_sel,
    output [7:0] lcd_data,
    output lcd_e,
    output lcd_rs,
    output lcd_rw,
    output piezo,
    output reg rgb_r,
    output reg rgb_g,
    output reg rgb_b
);

    wire rst = ~dip_sw[0];

    // States
    localparam IDLE = 0;
    localparam GEN_PATTERN = 1;
    localparam SHOW_PATTERN = 2;
    localparam GET_INPUT = 3;
    localparam CHECK = 4;
    localparam CORRECT = 5;
    localparam WRONG = 6;

    reg [2:0] state;
    reg [31:0] counter;

    // Pattern storage (max 8)
    reg [2:0] pattern [0:7];
    reg [3:0] pattern_len;
    reg [3:0] pattern_idx;

    // User input
    reg [2:0] user_input [0:7];
    reg [3:0] input_len;

    // LFSR for random
    reg [15:0] lfsr;
    wire [2:0] random_num = lfsr[2:0];  // 0~7

    always @(posedge clk or posedge rst) begin
        if (rst)
            lfsr <= 16'hACE1;
        else
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end

    // Button edge detection (simple)
    reg [11:0] btn_prev;
    wire [11:0] btn_pressed = ~btn_prev & btn;

    always @(posedge clk or posedge rst) begin
        if (rst)
            btn_prev <= 0;
        else
            btn_prev <= btn;
    end

    // 7-segment display for input
    reg [16:0] scan_counter;
    reg [2:0] scan_pos;

    always @(posedge clk) begin
        if (scan_counter < 100000)
            scan_counter <= scan_counter + 1;
        else begin
            scan_counter <= 0;
            scan_pos <= scan_pos + 1;
        end
    end

    // 7-seg decoder (Common Cathode)
    function [7:0] seg_decode;
        input [2:0] num;
        case (num)
            3'd0: seg_decode = 8'b00111111;
            3'd1: seg_decode = 8'b00000110;
            3'd2: seg_decode = 8'b01011011;
            3'd3: seg_decode = 8'b01001111;
            3'd4: seg_decode = 8'b01100110;
            3'd5: seg_decode = 8'b01101101;
            3'd6: seg_decode = 8'b01111101;
            3'd7: seg_decode = 8'b00000111;
            default: seg_decode = 8'b00000000;
        endcase
    endfunction

    // Display input on 7-segment (right aligned)
    always @(*) begin
        if (scan_pos < input_len) begin
            seg_arr_data = seg_decode(user_input[scan_pos]);
            seg_arr_sel = (8'b00000001 << scan_pos);
        end else begin
            seg_arr_data = 8'b00000000;
            seg_arr_sel = 8'b00000000;
        end
    end

    // Main FSM
    integer i;
    reg match;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            led <= 8'b00000001;
            pattern_len <= 3;
            pattern_idx <= 0;
            input_len <= 0;
            counter <= 0;
            rgb_r <= 0;
            rgb_g <= 0;
            rgb_b <= 0;
        end else begin
            case (state)
                IDLE: begin
                    led <= 8'b00000001;  // LED 1 = IDLE
                    rgb_r <= 0;
                    rgb_g <= 0;
                    rgb_b <= 0;
                    if (btn_pressed[9]) begin  // START
                        state <= GEN_PATTERN;
                        pattern_idx <= 0;
                    end
                end

                GEN_PATTERN: begin
                    led <= 8'b00000010;  // LED 2 = generating
                    if (pattern_idx < pattern_len) begin
                        pattern[pattern_idx] <= random_num;
                        pattern_idx <= pattern_idx + 1;
                    end else begin
                        state <= SHOW_PATTERN;
                        pattern_idx <= 0;
                        counter <= 0;
                    end
                end

                SHOW_PATTERN: begin
                    if (counter < 40_000_000) begin  // 400ms ON
                        led <= (8'b00000001 << pattern[pattern_idx]);
                        counter <= counter + 1;
                    end else if (counter < 50_000_000) begin  // 100ms OFF
                        led <= 8'b00000000;
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        if (pattern_idx < pattern_len - 1) begin
                            pattern_idx <= pattern_idx + 1;
                        end else begin
                            state <= GET_INPUT;
                            input_len <= 0;
                            led <= 8'b00000000;
                        end
                    end
                end

                GET_INPUT: begin
                    led <= 8'b10000000;  // LED 8 = waiting input

                    // Input buttons 0-7
                    if (btn_pressed[0] && input_len < 8) begin
                        user_input[input_len] <= 3'd0;
                        input_len <= input_len + 1;
                    end else if (btn_pressed[1] && input_len < 8) begin
                        user_input[input_len] <= 3'd1;
                        input_len <= input_len + 1;
                    end else if (btn_pressed[2] && input_len < 8) begin
                        user_input[input_len] <= 3'd2;
                        input_len <= input_len + 1;
                    end else if (btn_pressed[3] && input_len < 8) begin
                        user_input[input_len] <= 3'd3;
                        input_len <= input_len + 1;
                    end else if (btn_pressed[4] && input_len < 8) begin
                        user_input[input_len] <= 3'd4;
                        input_len <= input_len + 1;
                    end else if (btn_pressed[5] && input_len < 8) begin
                        user_input[input_len] <= 3'd5;
                        input_len <= input_len + 1;
                    end else if (btn_pressed[6] && input_len < 8) begin
                        user_input[input_len] <= 3'd6;
                        input_len <= input_len + 1;
                    end else if (btn_pressed[7] && input_len < 8) begin
                        user_input[input_len] <= 3'd7;
                        input_len <= input_len + 1;
                    end

                    // Cancel last input
                    if (btn_pressed[8] && input_len > 0) begin
                        input_len <= input_len - 1;
                    end

                    // Confirm
                    if (btn_pressed[11]) begin
                        state <= CHECK;
                    end
                end

                CHECK: begin
                    led <= 8'b01000000;  // LED 7 = checking

                    // Compare
                    match = 1;
                    if (input_len != pattern_len) begin
                        match = 0;
                    end else begin
                        for (i = 0; i < pattern_len; i = i + 1) begin
                            if (pattern[i] != user_input[i])
                                match = 0;
                        end
                    end

                    if (match)
                        state <= CORRECT;
                    else
                        state <= WRONG;

                    counter <= 0;
                end

                CORRECT: begin
                    led <= 8'b11111111;  // All LEDs
                    rgb_r <= 0;
                    rgb_g <= 1;  // Green (Active HIGH)
                    rgb_b <= 0;

                    if (counter < 100_000_000) begin  // 1 sec
                        counter <= counter + 1;
                    end else begin
                        if (pattern_len < 8)
                            pattern_len <= pattern_len + 1;
                        state <= IDLE;
                    end
                end

                WRONG: begin
                    led <= 8'b00000000;  // All off
                    rgb_r <= 1;  // Red (Active HIGH)
                    rgb_g <= 0;
                    rgb_b <= 0;

                    if (counter < 100_000_000) begin  // 1 sec
                        counter <= counter + 1;
                    end else begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    // Turn off unused
    assign seg_timer_data = 8'b00000000;
    assign lcd_data = 8'h00;
    assign lcd_e = 1'b0;
    assign lcd_rs = 1'b0;
    assign lcd_rw = 1'b0;
    assign piezo = 1'b0;

endmodule
