////////////////////////////////////////////////////////////////////////////////
// Game Controller - Main FSM
// Controls game flow and state transitions
////////////////////////////////////////////////////////////////////////////////

module game_controller (
    input wire clk,
    input wire rst,

    // Button inputs
    input wire btn_start,
    input wire btn_confirm,

    // Status signals from other modules
    input wire pattern_gen_done,
    input wire pattern_display_done,
    input wire input_complete,
    input wire check_done,
    input wire answer_correct,
    input wire timer_expired,

    // Game status outputs
    output reg [3:0] game_state,
    output reg [7:0] current_stage,
    output reg [2:0] lives,

    // Control signals to other modules
    output reg pattern_gen_start,
    output reg pattern_display_start,
    output reg timer_start,
    output reg check_start
);

    // State definitions
    localparam STATE_IDLE         = 4'd0;
    localparam STATE_INIT         = 4'd1;
    localparam STATE_GEN_PATTERN  = 4'd2;
    localparam STATE_SHOW_PATTERN = 4'd3;
    localparam STATE_WAIT_INPUT   = 4'd4;
    localparam STATE_CHECK_ANSWER = 4'd5;
    localparam STATE_CORRECT      = 4'd6;
    localparam STATE_WRONG        = 4'd7;
    localparam STATE_STAGE_CLEAR  = 4'd8;
    localparam STATE_GAME_OVER    = 4'd9;

    // Constants
    localparam INITIAL_LIVES = 3'd3;
    localparam INITIAL_STAGE = 8'd1;

    // Internal signals
    reg btn_start_prev;
    wire btn_start_edge;
    reg [31:0] delay_counter;
    localparam DELAY_CYCLES = 100_000_000; // 1 second at 100MHz

    // Detect rising edge of start button
    always @(posedge clk or posedge rst) begin
        if (rst)
            btn_start_prev <= 1'b0;
        else
            btn_start_prev <= btn_start;
    end

    assign btn_start_edge = btn_start && !btn_start_prev;

    // Main FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            game_state <= STATE_IDLE;
            current_stage <= INITIAL_STAGE;
            lives <= INITIAL_LIVES;
            pattern_gen_start <= 1'b0;
            pattern_display_start <= 1'b0;
            timer_start <= 1'b0;
            check_start <= 1'b0;
            delay_counter <= 0;
        end else begin
            // Default: deassert control signals
            pattern_gen_start <= 1'b0;
            pattern_display_start <= 1'b0;
            timer_start <= 1'b0;
            check_start <= 1'b0;

            case (game_state)
                STATE_IDLE: begin
                    // Wait for start button
                    if (btn_start_edge) begin
                        game_state <= STATE_INIT;
                    end
                end

                STATE_INIT: begin
                    // Initialize game variables
                    current_stage <= INITIAL_STAGE;
                    lives <= INITIAL_LIVES;
                    game_state <= STATE_GEN_PATTERN;
                end

                STATE_GEN_PATTERN: begin
                    // Start pattern generation
                    pattern_gen_start <= 1'b1;
                    if (pattern_gen_done) begin
                        game_state <= STATE_SHOW_PATTERN;
                    end
                end

                STATE_SHOW_PATTERN: begin
                    // Start pattern display
                    pattern_display_start <= 1'b1;
                    if (pattern_display_done) begin
                        game_state <= STATE_WAIT_INPUT;
                        timer_start <= 1'b1;
                    end
                end

                STATE_WAIT_INPUT: begin
                    // Wait for user to complete input or timer to expire
                    if (input_complete) begin
                        game_state <= STATE_CHECK_ANSWER;
                        check_start <= 1'b1;
                    end else if (timer_expired) begin
                        // Time's up, treat as wrong answer
                        game_state <= STATE_WRONG;
                    end
                end

                STATE_CHECK_ANSWER: begin
                    // Wait for answer checking to complete
                    if (check_done) begin
                        if (answer_correct) begin
                            game_state <= STATE_CORRECT;
                        end else begin
                            game_state <= STATE_WRONG;
                        end
                    end
                end

                STATE_CORRECT: begin
                    // Show correct message for 1 second
                    delay_counter <= delay_counter + 1;
                    if (delay_counter >= DELAY_CYCLES) begin
                        delay_counter <= 0;
                        game_state <= STATE_STAGE_CLEAR;
                    end
                end

                STATE_WRONG: begin
                    // Show wrong message for 1 second
                    delay_counter <= delay_counter + 1;
                    if (delay_counter >= DELAY_CYCLES) begin
                        delay_counter <= 0;
                        lives <= lives - 1;
                        if (lives == 1) begin
                            // Last life lost
                            game_state <= STATE_GAME_OVER;
                        end else begin
                            // Try same stage again
                            game_state <= STATE_GEN_PATTERN;
                        end
                    end
                end

                STATE_STAGE_CLEAR: begin
                    // Show stage clear message for 1 second
                    delay_counter <= delay_counter + 1;
                    if (delay_counter >= DELAY_CYCLES) begin
                        delay_counter <= 0;
                        current_stage <= current_stage + 1;
                        game_state <= STATE_GEN_PATTERN;
                    end
                end

                STATE_GAME_OVER: begin
                    // Show game over message, wait for restart
                    if (btn_start_edge) begin
                        game_state <= STATE_INIT;
                    end
                end

                default: begin
                    game_state <= STATE_IDLE;
                end
            endcase
        end
    end

endmodule
