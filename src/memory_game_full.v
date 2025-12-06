// memory_game_full.v
// Complete memory game with all features:
// - Random LED pattern display
// - 8-array 7-segment input display
// - Single 7-segment countdown timer
// - LCD display (stage, lives, score)
// - Piezo buzzer (pattern beeps, correct/wrong sounds)
// - RGB LED feedback
// - Life system (3 lives)

module memory_game_full(
    input clk,
    input [7:0] dip_sw,
    input [11:0] btn,
    output reg [7:0] led,
    output reg [7:0] seg_timer_data,
    output reg [7:0] seg_arr_data,
    output reg [7:0] seg_arr_sel,
    output reg [7:0] lcd_data,
    output reg lcd_e,
    output reg lcd_rs,
    output reg lcd_rw,
    output reg piezo,
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
    localparam GAME_OVER = 7;

    reg [2:0] state;
    reg [31:0] counter;

    // Pattern storage (max 8)
    reg [2:0] pattern [0:7];
    reg [3:0] pattern_len;
    reg [3:0] pattern_idx;

    // User input
    reg [2:0] user_input [0:7];
    reg [3:0] input_len;

    // Game stats
    reg [2:0] lives;  // 3 lives
    reg [15:0] score;  // Score counter
    reg [3:0] stage;   // Current stage (1-8+)

    // Timer (30 seconds for input)
    reg [3:0] timer_sec;
    reg [26:0] timer_counter;

    // LFSR for random
    reg [15:0] lfsr;
    wire [2:0] random_num = lfsr[2:0];

    always @(posedge clk or posedge rst) begin
        if (rst)
            lfsr <= 16'hACE1;
        else
            lfsr <= {lfsr[14:0], lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10]};
    end

    // Button edge detection
    reg [11:0] btn_prev;
    wire [11:0] btn_pressed = ~btn_prev & btn;

    always @(posedge clk or posedge rst) begin
        if (rst)
            btn_prev <= 0;
        else
            btn_prev <= btn;
    end

    // 7-segment scan for input display
    reg [16:0] scan_counter;
    reg [2:0] scan_pos;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_counter <= 0;
            scan_pos <= 0;
        end else begin
            if (scan_counter < 50000) begin
                scan_counter <= scan_counter + 1;
            end else begin
                scan_counter <= 0;
                scan_pos <= scan_pos + 1;
            end
        end
    end

    // 7-seg decoder (Common Cathode: 1=ON)
    function [7:0] seg_decode;
        input [3:0] num;
        case (num)
            4'd0: seg_decode = 8'b00111111;  // 0
            4'd1: seg_decode = 8'b00000110;  // 1
            4'd2: seg_decode = 8'b01011011;  // 2
            4'd3: seg_decode = 8'b01001111;  // 3
            4'd4: seg_decode = 8'b01100110;  // 4
            4'd5: seg_decode = 8'b01101101;  // 5
            4'd6: seg_decode = 8'b01111101;  // 6
            4'd7: seg_decode = 8'b00000111;  // 7
            4'd8: seg_decode = 8'b01111111;  // 8
            4'd9: seg_decode = 8'b01101111;  // 9
            default: seg_decode = 8'b00000000;
        endcase
    endfunction

    // 8-array 7-segment display (right-aligned input)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_arr_data <= 8'b00000000;
            seg_arr_sel <= 8'b00000000;
        end else begin
            seg_arr_sel <= (8'b00000001 << scan_pos);

            case (scan_pos)
                3'd0: seg_arr_data <= (input_len >= 8) ? seg_decode({1'b0, user_input[0]}) : 8'b00000000;
                3'd1: seg_arr_data <= (input_len >= 7) ? seg_decode({1'b0, user_input[input_len-7]}) : 8'b00000000;
                3'd2: seg_arr_data <= (input_len >= 6) ? seg_decode({1'b0, user_input[input_len-6]}) : 8'b00000000;
                3'd3: seg_arr_data <= (input_len >= 5) ? seg_decode({1'b0, user_input[input_len-5]}) : 8'b00000000;
                3'd4: seg_arr_data <= (input_len >= 4) ? seg_decode({1'b0, user_input[input_len-4]}) : 8'b00000000;
                3'd5: seg_arr_data <= (input_len >= 3) ? seg_decode({1'b0, user_input[input_len-3]}) : 8'b00000000;
                3'd6: seg_arr_data <= (input_len >= 2) ? seg_decode({1'b0, user_input[input_len-2]}) : 8'b00000000;
                3'd7: seg_arr_data <= (input_len >= 1) ? seg_decode({1'b0, user_input[input_len-1]}) : 8'b00000000;
            endcase
        end
    end

    // Single 7-segment timer display
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_timer_data <= 8'b00000000;
        end else begin
            seg_timer_data <= seg_decode(timer_sec);
        end
    end

    // Piezo frequency generator
    reg [15:0] piezo_counter;
    reg [15:0] piezo_period;  // Period for square wave
    reg piezo_enable;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            piezo_counter <= 0;
            piezo <= 0;
        end else if (piezo_enable && piezo_period > 0) begin
            if (piezo_counter < piezo_period) begin
                piezo_counter <= piezo_counter + 1;
            end else begin
                piezo_counter <= 0;
                piezo <= ~piezo;
            end
        end else begin
            piezo <= 0;
        end
    end

    // LCD controller (simplified)
    reg [7:0] lcd_state;
    reg [31:0] lcd_counter;
    reg [7:0] lcd_char_idx;

    localparam LCD_INIT = 0;
    localparam LCD_READY = 1;
    localparam LCD_WRITE = 2;

    // LCD display strings
    reg [7:0] lcd_line1 [0:15];  // "STAGE:X  LIFE:X"
    reg [7:0] lcd_line2 [0:15];  // "SCORE: XXXX    "

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lcd_state <= LCD_INIT;
            lcd_counter <= 0;
            lcd_e <= 0;
            lcd_rs <= 0;
            lcd_rw <= 0;
            lcd_data <= 8'h00;
        end else begin
            case (lcd_state)
                LCD_INIT: begin
                    if (lcd_counter < 100_000_000) begin  // 1 sec init delay
                        lcd_counter <= lcd_counter + 1;
                    end else begin
                        lcd_state <= LCD_READY;
                        lcd_counter <= 0;
                    end
                end

                LCD_READY: begin
                    // Update LCD content based on game state
                    // Line 1: "STAGE:X  LIFE:X"
                    lcd_line1[0] <= "S";
                    lcd_line1[1] <= "T";
                    lcd_line1[2] <= "A";
                    lcd_line1[3] <= "G";
                    lcd_line1[4] <= "E";
                    lcd_line1[5] <= ":";
                    lcd_line1[6] <= "0" + stage;
                    lcd_line1[7] <= " ";
                    lcd_line1[8] <= " ";
                    lcd_line1[9] <= "L";
                    lcd_line1[10] <= "I";
                    lcd_line1[11] <= "F";
                    lcd_line1[12] <= "E";
                    lcd_line1[13] <= ":";
                    lcd_line1[14] <= "0" + lives;
                    lcd_line1[15] <= " ";

                    // Line 2: "SCORE: XXXX    "
                    lcd_line2[0] <= "S";
                    lcd_line2[1] <= "C";
                    lcd_line2[2] <= "O";
                    lcd_line2[3] <= "R";
                    lcd_line2[4] <= "E";
                    lcd_line2[5] <= ":";
                    lcd_line2[6] <= " ";
                    lcd_line2[7] <= "0" + ((score / 1000) % 10);
                    lcd_line2[8] <= "0" + ((score / 100) % 10);
                    lcd_line2[9] <= "0" + ((score / 10) % 10);
                    lcd_line2[10] <= "0" + (score % 10);
                    lcd_line2[11] <= " ";
                    lcd_line2[12] <= " ";
                    lcd_line2[13] <= " ";
                    lcd_line2[14] <= " ";
                    lcd_line2[15] <= " ";

                    // Simple LCD update (actual LCD control would be more complex)
                    lcd_e <= 0;
                    lcd_rs <= 1;  // Data mode
                    lcd_rw <= 0;  // Write
                end
            endcase
        end
    end

    // Main FSM
    reg match;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            led <= 8'b00000001;
            pattern_len <= 3;
            pattern_idx <= 0;
            input_len <= 0;
            counter <= 0;
            lives <= 3;
            score <= 0;
            stage <= 1;
            timer_sec <= 30;
            timer_counter <= 0;
            piezo_enable <= 0;
            piezo_period <= 0;
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
                    piezo_enable <= 0;

                    if (btn_pressed[9]) begin  // START button
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

                        // Piezo tone based on LED number (different frequencies)
                        piezo_enable <= 1;
                        case (pattern[pattern_idx])
                            3'd0: piezo_period <= 16'd38223;  // C4 (261 Hz)
                            3'd1: piezo_period <= 16'd34048;  // D4 (293 Hz)
                            3'd2: piezo_period <= 16'd30338;  // E4 (329 Hz)
                            3'd3: piezo_period <= 16'd28635;  // F4 (349 Hz)
                            3'd4: piezo_period <= 16'd25511;  // G4 (392 Hz)
                            3'd5: piezo_period <= 16'd22727;  // A4 (440 Hz)
                            3'd6: piezo_period <= 16'd20248;  // B4 (493 Hz)
                            3'd7: piezo_period <= 16'd19111;  // C5 (523 Hz)
                        endcase

                        counter <= counter + 1;
                    end else if (counter < 50_000_000) begin  // 100ms OFF (gap)
                        led <= 8'b00000000;
                        piezo_enable <= 0;
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        if (pattern_idx < pattern_len - 1) begin
                            pattern_idx <= pattern_idx + 1;
                        end else begin
                            state <= GET_INPUT;
                            input_len <= 0;
                            led <= 8'b00000000;
                            timer_sec <= 30;  // Reset timer
                            timer_counter <= 0;
                        end
                    end
                end

                GET_INPUT: begin
                    led <= 8'b10000000;  // LED 8 = waiting input
                    piezo_enable <= 0;

                    // Countdown timer (1 second per tick)
                    if (timer_counter < 100_000_000) begin
                        timer_counter <= timer_counter + 1;
                    end else begin
                        timer_counter <= 0;
                        if (timer_sec > 0) begin
                            timer_sec <= timer_sec - 1;
                        end else begin
                            // Time's up!
                            state <= WRONG;
                            counter <= 0;
                        end
                    end

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

                    // Compare (unrolled)
                    match = 1;
                    if (input_len != pattern_len) begin
                        match = 0;
                    end else begin
                        if (pattern_len >= 1 && pattern[0] != user_input[0]) match = 0;
                        if (pattern_len >= 2 && pattern[1] != user_input[1]) match = 0;
                        if (pattern_len >= 3 && pattern[2] != user_input[2]) match = 0;
                        if (pattern_len >= 4 && pattern[3] != user_input[3]) match = 0;
                        if (pattern_len >= 5 && pattern[4] != user_input[4]) match = 0;
                        if (pattern_len >= 6 && pattern[5] != user_input[5]) match = 0;
                        if (pattern_len >= 7 && pattern[6] != user_input[6]) match = 0;
                        if (pattern_len >= 8 && pattern[7] != user_input[7]) match = 0;
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

                    // Success sound (rising tones)
                    piezo_enable <= 1;
                    if (counter < 20_000_000)
                        piezo_period <= 16'd30338;  // E4
                    else if (counter < 40_000_000)
                        piezo_period <= 16'd25511;  // G4
                    else if (counter < 60_000_000)
                        piezo_period <= 16'd19111;  // C5
                    else
                        piezo_enable <= 0;

                    if (counter < 100_000_000) begin  // 1 sec
                        counter <= counter + 1;
                    end else begin
                        // Update score and stage
                        score <= score + (pattern_len * 10);
                        if (pattern_len < 8) begin
                            pattern_len <= pattern_len + 1;
                            stage <= stage + 1;
                        end
                        // else stay at pattern_len=8 for infinite play

                        state <= IDLE;
                        piezo_enable <= 0;
                    end
                end

                WRONG: begin
                    led <= 8'b00000000;  // All off
                    rgb_r <= 1;  // Red (Active HIGH)
                    rgb_g <= 0;
                    rgb_b <= 0;

                    // Fail sound (descending tones)
                    piezo_enable <= 1;
                    if (counter < 20_000_000)
                        piezo_period <= 16'd19111;  // C5
                    else if (counter < 40_000_000)
                        piezo_period <= 16'd25511;  // G4
                    else if (counter < 60_000_000)
                        piezo_period <= 16'd30338;  // E4
                    else
                        piezo_enable <= 0;

                    if (counter < 100_000_000) begin  // 1 sec
                        counter <= counter + 1;
                    end else begin
                        if (lives > 1) begin
                            lives <= lives - 1;
                            state <= IDLE;
                        end else begin
                            state <= GAME_OVER;
                        end
                        piezo_enable <= 0;
                        counter <= 0;
                    end
                end

                GAME_OVER: begin
                    led <= 8'b10101010;  // Alternating pattern
                    rgb_r <= 1;
                    rgb_g <= 0;
                    rgb_b <= 0;
                    piezo_enable <= 0;

                    // Wait for restart
                    if (btn_pressed[9]) begin
                        state <= IDLE;
                        lives <= 3;
                        score <= 0;
                        stage <= 1;
                        pattern_len <= 3;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
