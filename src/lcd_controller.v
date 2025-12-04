// lcd_controller.v
// Simplified HD44780-compatible LCD controller
module lcd_controller(
    input wire clk,
    input wire rst,
    input wire [7:0] stage,
    input wire [7:0] high_score,
    input wire [2:0] life,
    input wire [3:0] display_mode,
    output reg [7:0] lcd_data,
    output reg lcd_e,
    output reg lcd_rs,
    output reg lcd_rw
);

    // Timing parameters (for 100MHz clock)
    localparam DELAY_15MS = 1_500_000;
    localparam DELAY_4MS  = 400_000;
    localparam DELAY_100US = 10_000;
    localparam DELAY_40US  = 4_000;
    localparam DELAY_1US   = 100;

    // LCD Commands
    localparam CMD_CLEAR        = 8'h01;
    localparam CMD_HOME         = 8'h02;
    localparam CMD_ENTRY_MODE   = 8'h06;
    localparam CMD_DISPLAY_ON   = 8'h0C;
    localparam CMD_FUNCTION_SET = 8'h38;
    localparam CMD_SETDDRAM_L1  = 8'h80;
    localparam CMD_SETDDRAM_L2  = 8'hC0;

    // State machine
    localparam ST_POWER_ON       = 0;
    localparam ST_INIT_FUNC1     = 1;
    localparam ST_INIT_FUNC2     = 2;
    localparam ST_INIT_FUNC3     = 3;
    localparam ST_INIT_DISPLAY   = 4;
    localparam ST_INIT_CLEAR     = 5;
    localparam ST_INIT_ENTRY     = 6;
    localparam ST_WRITE_LINE1    = 7;
    localparam ST_WRITE_LINE2    = 8;
    localparam ST_IDLE           = 9;

    reg [3:0] state, next_state;
    reg [31:0] counter;
    reg [7:0] char_index;
    reg [7:0] char_to_write;
    reg is_cmd;

    // Message storage
    reg [7:0] line1_msg [0:15];
    reg [7:0] line2_msg [0:15];

    integer i;

    // Update display messages based on mode
    always @(posedge clk) begin
        // Initialize with spaces
        for (i = 0; i < 16; i = i + 1) begin
            line1_msg[i] <= " ";
            line2_msg[i] <= " ";
        end

        case (display_mode)
            4'd0: begin  // Idle - "PRESS START"
                line1_msg[0] <= "P"; line1_msg[1] <= "R"; line1_msg[2] <= "E"; line1_msg[3] <= "S";
                line1_msg[4] <= "S"; line1_msg[5] <= " "; line1_msg[6] <= "S"; line1_msg[7] <= "T";
                line1_msg[8] <= "A"; line1_msg[9] <= "R"; line1_msg[10] <= "T";
            end
            4'd1: begin  // Playing
                line1_msg[0] <= "H"; line1_msg[1] <= "I"; line1_msg[2] <= ":";
                line1_msg[3] <= "0" + (high_score / 10);
                line1_msg[4] <= "0" + (high_score % 10);
                line1_msg[6] <= "L"; line1_msg[7] <= "I"; line1_msg[8] <= "F"; line1_msg[9] <= "E";
                line1_msg[10] <= ":";
                if (life >= 1) line1_msg[11] <= "#";
                if (life >= 2) line1_msg[12] <= "#";
                if (life >= 3) line1_msg[13] <= "#";

                line2_msg[0] <= "S"; line2_msg[1] <= "T"; line2_msg[2] <= "A"; line2_msg[3] <= "G";
                line2_msg[4] <= "E"; line2_msg[5] <= ":";
                line2_msg[6] <= "0" + (stage / 10);
                line2_msg[7] <= "0" + (stage % 10);
            end
            4'd2: begin  // Correct
                line1_msg[0] <= "C"; line1_msg[1] <= "O"; line1_msg[2] <= "R"; line1_msg[3] <= "R";
                line1_msg[4] <= "E"; line1_msg[5] <= "C"; line1_msg[6] <= "T"; line1_msg[7] <= "!";
                line2_msg[0] <= "P"; line2_msg[1] <= "R"; line2_msg[2] <= "E"; line2_msg[3] <= "S";
                line2_msg[4] <= "S"; line2_msg[5] <= " "; line2_msg[6] <= "N"; line2_msg[7] <= "E";
                line2_msg[8] <= "X"; line2_msg[9] <= "T";
            end
            4'd3: begin  // Wrong
                line1_msg[0] <= "W"; line1_msg[1] <= "R"; line1_msg[2] <= "O"; line1_msg[3] <= "N";
                line1_msg[4] <= "G"; line1_msg[5] <= "!";
                line2_msg[0] <= "L"; line2_msg[1] <= "I"; line2_msg[2] <= "F"; line2_msg[3] <= "E";
                line2_msg[4] <= ":";
                if (life >= 1) line2_msg[5] <= "#";
                if (life >= 2) line2_msg[6] <= "#";
                if (life >= 3) line2_msg[7] <= "#";
            end
            4'd4: begin  // Game Over
                line1_msg[0] <= "G"; line1_msg[1] <= "A"; line1_msg[2] <= "M"; line1_msg[3] <= "E";
                line1_msg[4] <= " "; line1_msg[5] <= "O"; line1_msg[6] <= "V"; line1_msg[7] <= "E";
                line1_msg[8] <= "R";
                line2_msg[0] <= "S"; line2_msg[1] <= "C"; line2_msg[2] <= "O"; line2_msg[3] <= "R";
                line2_msg[4] <= "E"; line2_msg[5] <= ":";
                line2_msg[6] <= "0" + (stage / 10);
                line2_msg[7] <= "0" + (stage % 10);
            end
            4'd5: begin  // New Record
                line1_msg[0] <= "N"; line1_msg[1] <= "E"; line1_msg[2] <= "W"; line1_msg[3] <= " ";
                line1_msg[4] <= "R"; line1_msg[5] <= "E"; line1_msg[6] <= "C"; line1_msg[7] <= "O";
                line1_msg[8] <= "R"; line1_msg[9] <= "D"; line1_msg[10] <= "!";
                line2_msg[0] <= "S"; line2_msg[1] <= "C"; line2_msg[2] <= "O"; line2_msg[3] <= "R";
                line2_msg[4] <= "E"; line2_msg[5] <= ":";
                line2_msg[6] <= "0" + (high_score / 10);
                line2_msg[7] <= "0" + (high_score % 10);
            end
        endcase
    end

    // State machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= ST_POWER_ON;
            counter <= 0;
            char_index <= 0;
            lcd_e <= 1'b0;
            lcd_rs <= 1'b0;
            lcd_rw <= 1'b0;
            lcd_data <= 8'h00;
        end else begin
            case (state)
                ST_POWER_ON: begin
                    lcd_rs <= 1'b0;
                    lcd_rw <= 1'b0;
                    if (counter < DELAY_15MS) begin
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        state <= ST_INIT_FUNC1;
                    end
                end

                ST_INIT_FUNC1, ST_INIT_FUNC2, ST_INIT_FUNC3: begin
                    if (counter == 0) begin
                        lcd_data <= CMD_FUNCTION_SET;
                        lcd_e <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter < DELAY_1US) begin
                        counter <= counter + 1;
                    end else if (counter == DELAY_1US) begin
                        lcd_e <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter < DELAY_1US + DELAY_1US) begin
                        counter <= counter + 1;
                    end else if (counter == DELAY_1US + DELAY_1US) begin
                        lcd_e <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter < DELAY_4MS) begin
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        if (state == ST_INIT_FUNC1) state <= ST_INIT_FUNC2;
                        else if (state == ST_INIT_FUNC2) state <= ST_INIT_FUNC3;
                        else state <= ST_INIT_DISPLAY;
                    end
                end

                ST_INIT_DISPLAY: begin
                    if (counter == 0) begin
                        lcd_data <= CMD_DISPLAY_ON;
                        lcd_e <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter < DELAY_1US) begin
                        counter <= counter + 1;
                    end else if (counter == DELAY_1US) begin
                        lcd_e <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter < DELAY_1US + DELAY_1US) begin
                        counter <= counter + 1;
                    end else if (counter == DELAY_1US + DELAY_1US) begin
                        lcd_e <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter < DELAY_40US) begin
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        state <= ST_INIT_CLEAR;
                    end
                end

                ST_INIT_CLEAR: begin
                    if (counter == 0) begin
                        lcd_data <= CMD_CLEAR;
                        lcd_e <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter < DELAY_1US) begin
                        counter <= counter + 1;
                    end else if (counter == DELAY_1US) begin
                        lcd_e <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter < DELAY_1US + DELAY_1US) begin
                        counter <= counter + 1;
                    end else if (counter == DELAY_1US + DELAY_1US) begin
                        lcd_e <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter < DELAY_4MS) begin
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        state <= ST_INIT_ENTRY;
                    end
                end

                ST_INIT_ENTRY: begin
                    if (counter == 0) begin
                        lcd_data <= CMD_ENTRY_MODE;
                        lcd_e <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter < DELAY_1US) begin
                        counter <= counter + 1;
                    end else if (counter == DELAY_1US) begin
                        lcd_e <= 1'b1;
                        counter <= counter + 1;
                    end else if (counter < DELAY_1US + DELAY_1US) begin
                        counter <= counter + 1;
                    end else if (counter == DELAY_1US + DELAY_1US) begin
                        lcd_e <= 1'b0;
                        counter <= counter + 1;
                    end else if (counter < DELAY_40US) begin
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        char_index <= 0;
                        state <= ST_WRITE_LINE1;
                    end
                end

                ST_WRITE_LINE1: begin
                    if (char_index == 0) begin
                        // Set DDRAM address to line 1
                        if (counter == 0) begin
                            lcd_rs <= 1'b0;
                            lcd_data <= CMD_SETDDRAM_L1;
                            lcd_e <= 1'b0;
                            counter <= counter + 1;
                        end else if (counter < DELAY_1US) begin
                            counter <= counter + 1;
                        end else if (counter == DELAY_1US) begin
                            lcd_e <= 1'b1;
                            counter <= counter + 1;
                        end else if (counter < DELAY_1US + DELAY_1US) begin
                            counter <= counter + 1;
                        end else if (counter == DELAY_1US + DELAY_1US) begin
                            lcd_e <= 1'b0;
                            counter <= counter + 1;
                        end else if (counter < DELAY_40US) begin
                            counter <= counter + 1;
                        end else begin
                            counter <= 0;
                            char_index <= 1;
                        end
                    end else if (char_index <= 16) begin
                        // Write character
                        if (counter == 0) begin
                            lcd_rs <= 1'b1;
                            lcd_data <= line1_msg[char_index - 1];
                            lcd_e <= 1'b0;
                            counter <= counter + 1;
                        end else if (counter < DELAY_1US) begin
                            counter <= counter + 1;
                        end else if (counter == DELAY_1US) begin
                            lcd_e <= 1'b1;
                            counter <= counter + 1;
                        end else if (counter < DELAY_1US + DELAY_1US) begin
                            counter <= counter + 1;
                        end else if (counter == DELAY_1US + DELAY_1US) begin
                            lcd_e <= 1'b0;
                            counter <= counter + 1;
                        end else if (counter < DELAY_40US) begin
                            counter <= counter + 1;
                        end else begin
                            counter <= 0;
                            char_index <= char_index + 1;
                        end
                    end else begin
                        char_index <= 0;
                        state <= ST_WRITE_LINE2;
                    end
                end

                ST_WRITE_LINE2: begin
                    if (char_index == 0) begin
                        // Set DDRAM address to line 2
                        if (counter == 0) begin
                            lcd_rs <= 1'b0;
                            lcd_data <= CMD_SETDDRAM_L2;
                            lcd_e <= 1'b0;
                            counter <= counter + 1;
                        end else if (counter < DELAY_1US) begin
                            counter <= counter + 1;
                        end else if (counter == DELAY_1US) begin
                            lcd_e <= 1'b1;
                            counter <= counter + 1;
                        end else if (counter < DELAY_1US + DELAY_1US) begin
                            counter <= counter + 1;
                        end else if (counter == DELAY_1US + DELAY_1US) begin
                            lcd_e <= 1'b0;
                            counter <= counter + 1;
                        end else if (counter < DELAY_40US) begin
                            counter <= counter + 1;
                        end else begin
                            counter <= 0;
                            char_index <= 1;
                        end
                    end else if (char_index <= 16) begin
                        // Write character
                        if (counter == 0) begin
                            lcd_rs <= 1'b1;
                            lcd_data <= line2_msg[char_index - 1];
                            lcd_e <= 1'b0;
                            counter <= counter + 1;
                        end else if (counter < DELAY_1US) begin
                            counter <= counter + 1;
                        end else if (counter == DELAY_1US) begin
                            lcd_e <= 1'b1;
                            counter <= counter + 1;
                        end else if (counter < DELAY_1US + DELAY_1US) begin
                            counter <= counter + 1;
                        end else if (counter == DELAY_1US + DELAY_1US) begin
                            lcd_e <= 1'b0;
                            counter <= counter + 1;
                        end else if (counter < DELAY_40US) begin
                            counter <= counter + 1;
                        end else begin
                            counter <= 0;
                            char_index <= char_index + 1;
                        end
                    end else begin
                        char_index <= 0;
                        counter <= 0;
                        state <= ST_IDLE;
                    end
                end

                ST_IDLE: begin
                    if (counter < 50_000_000) begin  // Refresh every 500ms
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        char_index <= 0;
                        state <= ST_WRITE_LINE1;
                    end
                end

                default: state <= ST_POWER_ON;
            endcase
        end
    end

endmodule
