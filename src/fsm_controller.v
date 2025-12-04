// fsm_controller.v
// Main game state machine controller
module fsm_controller(
    input wire clk,
    input wire rst,
    input wire game_enable,
    input wire start_btn,
    input wire confirm_btn,
    input wire timeout,
    input wire player_done,
    input wire match_result,
    output reg [3:0] state_out,
    output reg gen_pattern,
    output reg play_pattern,
    output reg clear_input,
    output reg start_timer,
    output reg stop_timer,
    output reg compare_en,
    output reg show_correct,
    output reg show_wrong,
    output reg play_correct_sound,
    output reg play_wrong_sound,
    output reg update_highscore,
    output reg [7:0] stage,
    output reg [2:0] life,
    output reg [3:0] pattern_length,
    output reg [3:0] display_mode
);

    // State definitions
    localparam STATE_POWER_OFF = 0;
    localparam STATE_IDLE = 1;
    localparam STATE_INIT = 2;
    localparam STATE_GEN_PATTERN = 3;
    localparam STATE_SHOW_PATTERN = 4;
    localparam STATE_GET_INPUT = 5;
    localparam STATE_COMPARE = 6;
    localparam STATE_CORRECT = 7;
    localparam STATE_WRONG = 8;
    localparam STATE_GAMEOVER = 9;

    reg [3:0] state, next_state;
    reg [31:0] delay_counter;

    // Button inputs are already edge-detected by debouncer
    // Just use them directly
    wire start_pressed;
    wire confirm_pressed;

    assign start_pressed = start_btn;      // Already an edge pulse
    assign confirm_pressed = confirm_btn;  // Already an edge pulse

    // State machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STATE_POWER_OFF;
            stage <= 8'd1;
            life <= 3'd3;
            pattern_length <= 4'd3;
            delay_counter <= 0;
        end else begin
            if (!game_enable) begin
                state <= STATE_POWER_OFF;
                stage <= 8'd1;
                life <= 3'd3;
                pattern_length <= 4'd3;
            end else begin
                state <= next_state;

                case (state)
                    STATE_IDLE: begin
                        if (start_pressed) begin
                            stage <= 8'd1;
                            life <= 3'd3;
                            pattern_length <= 4'd3;
                        end
                    end

                    STATE_CORRECT: begin
                        if (delay_counter >= 100_000_000) begin  // 1 second
                            delay_counter <= 0;
                        end else begin
                            delay_counter <= delay_counter + 1;
                        end
                    end

                    STATE_WRONG: begin
                        if (delay_counter >= 100_000_000) begin
                            delay_counter <= 0;
                            if (life > 0) begin
                                life <= life - 1;
                            end
                        end else begin
                            delay_counter <= delay_counter + 1;
                        end
                    end

                    STATE_GEN_PATTERN: begin
                        if (delay_counter >= 10_000_000) begin  // 100ms for generation
                            delay_counter <= 0;
                        end else begin
                            delay_counter <= delay_counter + 1;
                        end
                    end
                endcase
            end
        end
    end

    // Next state logic
    always @(*) begin
        next_state = state;

        case (state)
            STATE_POWER_OFF: begin
                if (game_enable) begin
                    next_state = STATE_IDLE;
                end
            end

            STATE_IDLE: begin
                if (start_pressed) begin
                    next_state = STATE_INIT;
                end
            end

            STATE_INIT: begin
                next_state = STATE_GEN_PATTERN;
            end

            STATE_GEN_PATTERN: begin
                if (delay_counter >= 10_000_000) begin
                    next_state = STATE_SHOW_PATTERN;
                end
            end

            STATE_SHOW_PATTERN: begin
                if (player_done) begin
                    next_state = STATE_GET_INPUT;
                end
            end

            STATE_GET_INPUT: begin
                if (confirm_pressed) begin
                    next_state = STATE_COMPARE;
                end else if (timeout) begin
                    next_state = STATE_WRONG;
                end
            end

            STATE_COMPARE: begin
                if (match_result) begin
                    next_state = STATE_CORRECT;
                end else begin
                    next_state = STATE_WRONG;
                end
            end

            STATE_CORRECT: begin
                if (delay_counter >= 100_000_000 && start_pressed) begin
                    if (pattern_length < 8) begin
                        next_state = STATE_GEN_PATTERN;
                    end else begin
                        next_state = STATE_GAMEOVER;
                    end
                end
            end

            STATE_WRONG: begin
                if (delay_counter >= 100_000_000) begin
                    if (life > 1) begin
                        if (start_pressed) begin
                            next_state = STATE_GEN_PATTERN;
                        end else begin
                            next_state = STATE_IDLE;
                        end
                    end else begin
                        next_state = STATE_GAMEOVER;
                    end
                end
            end

            STATE_GAMEOVER: begin
                if (start_pressed) begin
                    next_state = STATE_IDLE;
                end
            end
        endcase
    end

    // Output logic
    always @(*) begin
        // Default values
        gen_pattern = 1'b0;
        play_pattern = 1'b0;
        clear_input = 1'b0;
        start_timer = 1'b0;
        stop_timer = 1'b0;
        compare_en = 1'b0;
        show_correct = 1'b0;
        show_wrong = 1'b0;
        play_correct_sound = 1'b0;
        play_wrong_sound = 1'b0;
        update_highscore = 1'b0;
        display_mode = 4'd0;
        state_out = state;

        case (state)
            STATE_POWER_OFF: begin
                display_mode = 4'd0;
            end

            STATE_IDLE: begin
                display_mode = 4'd0;
            end

            STATE_INIT: begin
                clear_input = 1'b1;
                display_mode = 4'd1;
            end

            STATE_GEN_PATTERN: begin
                gen_pattern = 1'b1;
                clear_input = 1'b1;
                display_mode = 4'd1;
            end

            STATE_SHOW_PATTERN: begin
                play_pattern = 1'b1;
                display_mode = 4'd1;
            end

            STATE_GET_INPUT: begin
                start_timer = 1'b1;
                display_mode = 4'd1;
            end

            STATE_COMPARE: begin
                stop_timer = 1'b1;
                compare_en = 1'b1;
                display_mode = 4'd1;
            end

            STATE_CORRECT: begin
                show_correct = 1'b1;
                play_correct_sound = 1'b1;
                display_mode = 4'd2;
                if (delay_counter >= 100_000_000 && start_pressed) begin
                    update_highscore = 1'b1;
                end
            end

            STATE_WRONG: begin
                show_wrong = 1'b1;
                play_wrong_sound = 1'b1;
                display_mode = 4'd3;
            end

            STATE_GAMEOVER: begin
                update_highscore = 1'b1;
                display_mode = 4'd4;
            end
        endcase
    end

    // Update pattern length when advancing stage
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pattern_length <= 4'd3;
        end else begin
            if (state == STATE_CORRECT && next_state == STATE_GEN_PATTERN) begin
                if (pattern_length < 8) begin
                    pattern_length <= pattern_length + 1;
                    stage <= stage + 1;
                end
            end else if (state == STATE_IDLE && start_pressed) begin
                pattern_length <= 4'd3;
                stage <= 8'd1;
            end
        end
    end

endmodule
