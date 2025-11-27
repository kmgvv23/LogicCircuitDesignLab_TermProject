////////////////////////////////////////////////////////////////////////////////
// LCD Controller Module
// Controls 16x2 LCD in 4-bit mode (HD44780 compatible)
// Displays game status, stage, lives, and high score
////////////////////////////////////////////////////////////////////////////////

module lcd_controller (
    input wire clk,
    input wire rst,
    input wire [3:0] game_state,
    input wire [7:0] stage,
    input wire [2:0] lives,
    input wire [7:0] high_score,
    input wire [1:0] speed,
    input wire answer_correct,

    output reg lcd_rs,
    output wire lcd_rw,
    output reg lcd_e,
    output reg [3:0] lcd_data
);

    // Game states (must match game_controller.v)
    localparam STATE_IDLE         = 4'd0;
    localparam STATE_SHOW_PATTERN = 4'd3;
    localparam STATE_WAIT_INPUT   = 4'd4;
    localparam STATE_CORRECT      = 4'd6;
    localparam STATE_WRONG        = 4'd7;
    localparam STATE_STAGE_CLEAR  = 4'd8;
    localparam STATE_GAME_OVER    = 4'd9;

    // LCD timing parameters (at 100MHz)
    localparam CYCLES_15MS  = 1_500_000;
    localparam CYCLES_5MS   = 500_000;
    localparam CYCLES_2MS   = 200_000;
    localparam CYCLES_100US = 10_000;
    localparam CYCLES_40US  = 4_000;

    // FSM states for LCD operations
    reg [7:0] lcd_state;
    reg [31:0] wait_counter;
    reg [7:0] char_index;
    reg [7:0] display_buffer [0:31];  // 2 lines x 16 chars
    reg init_done;
    integer i;  // Loop variable declaration

    // LCD RW is always 0 (write mode)
    assign lcd_rw = 1'b0;

    // Convert numbers to ASCII
    function [7:0] digit_to_ascii;
        input [3:0] digit;
        begin
            digit_to_ascii = 8'h30 + digit;
        end
    endfunction

    // Prepare display content based on game state
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Initialize display buffer with spaces
            for (i = 0; i < 32; i = i + 1)
                display_buffer[i] <= 8'h20;  // Space character
        end else begin
            case (game_state)
                STATE_IDLE: begin
                    // Line 1: "PRESS START BTN "
                    display_buffer[0]  <= 8'h50;  // P
                    display_buffer[1]  <= 8'h52;  // R
                    display_buffer[2]  <= 8'h45;  // E
                    display_buffer[3]  <= 8'h53;  // S
                    display_buffer[4]  <= 8'h53;  // S
                    display_buffer[5]  <= 8'h20;  // Space
                    display_buffer[6]  <= 8'h53;  // S
                    display_buffer[7]  <= 8'h54;  // T
                    display_buffer[8]  <= 8'h41;  // A
                    display_buffer[9]  <= 8'h52;  // R
                    display_buffer[10] <= 8'h54;  // T
                    display_buffer[11] <= 8'h20;  // Space
                    display_buffer[12] <= 8'h42;  // B
                    display_buffer[13] <= 8'h54;  // T
                    display_buffer[14] <= 8'h4E;  // N
                    display_buffer[15] <= 8'h20;  // Space

                    // Line 2: "HI-SCORE: XX    "
                    display_buffer[16] <= 8'h48;  // H
                    display_buffer[17] <= 8'h49;  // I
                    display_buffer[18] <= 8'h2D;  // -
                    display_buffer[19] <= 8'h53;  // S
                    display_buffer[20] <= 8'h43;  // C
                    display_buffer[21] <= 8'h4F;  // O
                    display_buffer[22] <= 8'h52;  // R
                    display_buffer[23] <= 8'h45;  // E
                    display_buffer[24] <= 8'h3A;  // :
                    display_buffer[25] <= 8'h20;  // Space
                    display_buffer[26] <= digit_to_ascii(high_score / 10);
                    display_buffer[27] <= digit_to_ascii(high_score % 10);
                    display_buffer[28] <= 8'h20;
                    display_buffer[29] <= 8'h20;
                    display_buffer[30] <= 8'h20;
                    display_buffer[31] <= 8'h20;
                end

                STATE_SHOW_PATTERN: begin
                    // Line 1: "WATCH PATTERN!  "
                    display_buffer[0]  <= 8'h57;  // W
                    display_buffer[1]  <= 8'h41;  // A
                    display_buffer[2]  <= 8'h54;  // T
                    display_buffer[3]  <= 8'h43;  // C
                    display_buffer[4]  <= 8'h48;  // H
                    display_buffer[5]  <= 8'h20;  // Space
                    display_buffer[6]  <= 8'h50;  // P
                    display_buffer[7]  <= 8'h41;  // A
                    display_buffer[8]  <= 8'h54;  // T
                    display_buffer[9]  <= 8'h54;  // T
                    display_buffer[10] <= 8'h45;  // E
                    display_buffer[11] <= 8'h52;  // R
                    display_buffer[12] <= 8'h4E;  // N
                    display_buffer[13] <= 8'h21;  // !
                    display_buffer[14] <= 8'h20;
                    display_buffer[15] <= 8'h20;

                    // Line 2: "STAGE:XX LIFE:X "
                    display_buffer[16] <= 8'h53;  // S
                    display_buffer[17] <= 8'h54;  // T
                    display_buffer[18] <= 8'h47;  // G
                    display_buffer[19] <= 8'h3A;  // :
                    display_buffer[20] <= digit_to_ascii(stage / 10);
                    display_buffer[21] <= digit_to_ascii(stage % 10);
                    display_buffer[22] <= 8'h20;
                    display_buffer[23] <= 8'h4C;  // L
                    display_buffer[24] <= 8'h49;  // I
                    display_buffer[25] <= 8'h46;  // F
                    display_buffer[26] <= 8'h45;  // E
                    display_buffer[27] <= 8'h3A;  // :
                    display_buffer[28] <= digit_to_ascii(lives);
                    display_buffer[29] <= 8'h20;
                    display_buffer[30] <= 8'h20;
                    display_buffer[31] <= 8'h20;
                end

                STATE_WAIT_INPUT: begin
                    // Line 1: "YOUR TURN!      "
                    display_buffer[0]  <= 8'h59;  // Y
                    display_buffer[1]  <= 8'h4F;  // O
                    display_buffer[2]  <= 8'h55;  // U
                    display_buffer[3]  <= 8'h52;  // R
                    display_buffer[4]  <= 8'h20;  // Space
                    display_buffer[5]  <= 8'h54;  // T
                    display_buffer[6]  <= 8'h55;  // U
                    display_buffer[7]  <= 8'h52;  // R
                    display_buffer[8]  <= 8'h4E;  // N
                    display_buffer[9]  <= 8'h21;  // !
                    display_buffer[10] <= 8'h20;
                    display_buffer[11] <= 8'h20;
                    display_buffer[12] <= 8'h20;
                    display_buffer[13] <= 8'h20;
                    display_buffer[14] <= 8'h20;
                    display_buffer[15] <= 8'h20;

                    // Line 2: Same as SHOW_PATTERN
                    display_buffer[16] <= 8'h53;  // S
                    display_buffer[17] <= 8'h54;  // T
                    display_buffer[18] <= 8'h47;  // G
                    display_buffer[19] <= 8'h3A;  // :
                    display_buffer[20] <= digit_to_ascii(stage / 10);
                    display_buffer[21] <= digit_to_ascii(stage % 10);
                    display_buffer[22] <= 8'h20;
                    display_buffer[23] <= 8'h4C;  // L
                    display_buffer[24] <= 8'h49;  // I
                    display_buffer[25] <= 8'h46;  // F
                    display_buffer[26] <= 8'h45;  // E
                    display_buffer[27] <= 8'h3A;  // :
                    display_buffer[28] <= digit_to_ascii(lives);
                    display_buffer[29] <= 8'h20;
                    display_buffer[30] <= 8'h20;
                    display_buffer[31] <= 8'h20;
                end

                STATE_CORRECT: begin
                    // Line 1: "   CORRECT!     "
                    display_buffer[0]  <= 8'h20;
                    display_buffer[1]  <= 8'h20;
                    display_buffer[2]  <= 8'h20;
                    display_buffer[3]  <= 8'h43;  // C
                    display_buffer[4]  <= 8'h4F;  // O
                    display_buffer[5]  <= 8'h52;  // R
                    display_buffer[6]  <= 8'h52;  // R
                    display_buffer[7]  <= 8'h45;  // E
                    display_buffer[8]  <= 8'h43;  // C
                    display_buffer[9]  <= 8'h54;  // T
                    display_buffer[10] <= 8'h21;  // !
                    display_buffer[11] <= 8'h20;
                    display_buffer[12] <= 8'h20;
                    display_buffer[13] <= 8'h20;
                    display_buffer[14] <= 8'h20;
                    display_buffer[15] <= 8'h20;
                end

                STATE_WRONG: begin
                    // Line 1: "    WRONG!      "
                    display_buffer[0]  <= 8'h20;
                    display_buffer[1]  <= 8'h20;
                    display_buffer[2]  <= 8'h20;
                    display_buffer[3]  <= 8'h20;
                    display_buffer[4]  <= 8'h57;  // W
                    display_buffer[5]  <= 8'h52;  // R
                    display_buffer[6]  <= 8'h4F;  // O
                    display_buffer[7]  <= 8'h4E;  // N
                    display_buffer[8]  <= 8'h47;  // G
                    display_buffer[9]  <= 8'h21;  // !
                    display_buffer[10] <= 8'h20;
                    display_buffer[11] <= 8'h20;
                    display_buffer[12] <= 8'h20;
                    display_buffer[13] <= 8'h20;
                    display_buffer[14] <= 8'h20;
                    display_buffer[15] <= 8'h20;
                end

                STATE_STAGE_CLEAR: begin
                    // Line 1: "  STAGE CLEAR!  "
                    display_buffer[0]  <= 8'h20;
                    display_buffer[1]  <= 8'h20;
                    display_buffer[2]  <= 8'h53;  // S
                    display_buffer[3]  <= 8'h54;  // T
                    display_buffer[4]  <= 8'h41;  // A
                    display_buffer[5]  <= 8'h47;  // G
                    display_buffer[6]  <= 8'h45;  // E
                    display_buffer[7]  <= 8'h20;
                    display_buffer[8]  <= 8'h43;  // C
                    display_buffer[9]  <= 8'h4C;  // L
                    display_buffer[10] <= 8'h45;  // E
                    display_buffer[11] <= 8'h41;  // A
                    display_buffer[12] <= 8'h52;  // R
                    display_buffer[13] <= 8'h21;  // !
                    display_buffer[14] <= 8'h20;
                    display_buffer[15] <= 8'h20;
                end

                STATE_GAME_OVER: begin
                    // Line 1: "   GAME OVER!   "
                    display_buffer[0]  <= 8'h20;
                    display_buffer[1]  <= 8'h20;
                    display_buffer[2]  <= 8'h20;
                    display_buffer[3]  <= 8'h47;  // G
                    display_buffer[4]  <= 8'h41;  // A
                    display_buffer[5]  <= 8'h4D;  // M
                    display_buffer[6]  <= 8'h45;  // E
                    display_buffer[7]  <= 8'h20;
                    display_buffer[8]  <= 8'h4F;  // O
                    display_buffer[9]  <= 8'h56;  // V
                    display_buffer[10] <= 8'h45;  // E
                    display_buffer[11] <= 8'h52;  // R
                    display_buffer[12] <= 8'h21;  // !
                    display_buffer[13] <= 8'h20;
                    display_buffer[14] <= 8'h20;
                    display_buffer[15] <= 8'h20;

                    // Line 2: "YOUR SCORE: XX  "
                    display_buffer[16] <= 8'h59;  // Y
                    display_buffer[17] <= 8'h4F;  // O
                    display_buffer[18] <= 8'h55;  // U
                    display_buffer[19] <= 8'h52;  // R
                    display_buffer[20] <= 8'h20;
                    display_buffer[21] <= 8'h53;  // S
                    display_buffer[22] <= 8'h43;  // C
                    display_buffer[23] <= 8'h4F;  // O
                    display_buffer[24] <= 8'h52;  // R
                    display_buffer[25] <= 8'h45;  // E
                    display_buffer[26] <= 8'h3A;  // :
                    display_buffer[27] <= 8'h20;
                    display_buffer[28] <= digit_to_ascii(stage / 10);
                    display_buffer[29] <= digit_to_ascii(stage % 10);
                    display_buffer[30] <= 8'h20;
                    display_buffer[31] <= 8'h20;
                end
            endcase
        end
    end

    // Simplified LCD control FSM (initialization and writing)
    // This is a basic implementation - real LCD control needs precise timing
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lcd_state <= 0;
            lcd_rs <= 0;
            lcd_e <= 0;
            lcd_data <= 4'h0;
            wait_counter <= 0;
            char_index <= 0;
            init_done <= 0;
        end else begin
            // Simplified: just hold initialization commands
            // Real implementation would need full HD44780 init sequence
            if (!init_done) begin
                wait_counter <= wait_counter + 1;
                if (wait_counter > CYCLES_15MS) begin
                    init_done <= 1;
                    lcd_state <= 0;
                end
            end else begin
                // Simplified display update
                // Real implementation would write each character to LCD
                lcd_state <= lcd_state + 1;
            end
        end
    end

endmodule
