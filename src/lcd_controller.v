// lcd_controller.v
// HD44780-compatible LCD controller
module lcd_controller(
    input wire clk,
    input wire rst,
    input wire [7:0] stage,
    input wire [7:0] high_score,
    input wire [2:0] life,
    input wire [3:0] display_mode,  // 0=idle, 1=playing, 2=correct, 3=wrong, 4=gameover, 5=new_record
    output reg [7:0] lcd_data,
    output reg lcd_e,
    output reg lcd_rs,
    output reg lcd_rw
);

    localparam CLK_DELAY = 5000;  // 50us at 100MHz

    // LCD Commands
    localparam CMD_CLEAR = 8'h01;
    localparam CMD_HOME = 8'h02;
    localparam CMD_ENTRY = 8'h06;
    localparam CMD_DISPLAY = 8'h0C;
    localparam CMD_FUNCTION = 8'h38;
    localparam CMD_LINE1 = 8'h80;
    localparam CMD_LINE2 = 8'hC0;

    // State machine
    localparam INIT = 0, WAIT = 1, WRITE = 2, ENABLE = 3, HOLD = 4, NEXT = 5, IDLE = 6;
    reg [3:0] state;
    reg [31:0] counter;
    reg [7:0] char_index;
    reg [7:0] init_step;
    reg init_done;

    // Message storage
    reg [7:0] line1 [0:15];
    reg [7:0] line2 [0:15];
    reg [7:0] current_char;
    reg is_cmd;

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= INIT;
            counter <= 0;
            char_index <= 0;
            init_step <= 0;
            init_done <= 1'b0;
            lcd_data <= 8'h00;
            lcd_e <= 1'b0;
            lcd_rs <= 1'b0;
            lcd_rw <= 1'b0;
        end else begin
            case (state)
                INIT: begin
                    if (counter < 15_000_000) begin  // Wait 150ms for power-on
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        state <= WRITE;
                    end
                end

                WRITE: begin
                    if (!init_done) begin
                        case (init_step)
                            0: begin current_char <= CMD_FUNCTION; is_cmd <= 1'b1; end
                            1: begin current_char <= CMD_FUNCTION; is_cmd <= 1'b1; end
                            2: begin current_char <= CMD_FUNCTION; is_cmd <= 1'b1; end
                            3: begin current_char <= CMD_DISPLAY; is_cmd <= 1'b1; end
                            4: begin current_char <= CMD_CLEAR; is_cmd <= 1'b1; end
                            5: begin current_char <= CMD_ENTRY; is_cmd <= 1'b1; end
                            default: begin init_done <= 1'b1; state <= IDLE; end
                        endcase

                        if (init_step < 6) begin
                            lcd_rs <= ~is_cmd;
                            lcd_rw <= 1'b0;
                            lcd_data <= current_char;
                            state <= ENABLE;
                        end
                    end else begin
                        // Display content based on mode
                        if (char_index == 0) begin
                            current_char <= CMD_LINE1;
                            is_cmd <= 1'b1;
                        end else if (char_index <= 16) begin
                            current_char <= line1[char_index - 1];
                            is_cmd <= 1'b0;
                        end else if (char_index == 17) begin
                            current_char <= CMD_LINE2;
                            is_cmd <= 1'b1;
                        end else if (char_index <= 33) begin
                            current_char <= line2[char_index - 18];
                            is_cmd <= 1'b0;
                        end else begin
                            char_index <= 0;
                            state <= IDLE;
                        end

                        if (char_index <= 33) begin
                            lcd_rs <= ~is_cmd;
                            lcd_rw <= 1'b0;
                            lcd_data <= current_char;
                            state <= ENABLE;
                        end
                    end
                end

                ENABLE: begin
                    if (counter < CLK_DELAY) begin
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        lcd_e <= 1'b1;
                        state <= HOLD;
                    end
                end

                HOLD: begin
                    if (counter < CLK_DELAY) begin
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        lcd_e <= 1'b0;
                        state <= NEXT;
                    end
                end

                NEXT: begin
                    if (counter < CLK_DELAY * 10) begin
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        if (!init_done) begin
                            init_step <= init_step + 1;
                        end else begin
                            char_index <= char_index + 1;
                        end
                        state <= WRITE;
                    end
                end

                IDLE: begin
                    if (counter < 10_000_000) begin  // Refresh every 100ms
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        char_index <= 0;
                        state <= WRITE;
                    end
                end

                default: state <= INIT;
            endcase
        end
    end

    // Update display content based on mode
    always @(*) begin
        // Default: blank spaces
        for (i = 0; i < 16; i = i + 1) begin
            line1[i] = " ";
            line2[i] = " ";
        end

        case (display_mode)
            4'd0: begin  // Idle
                line1[0] = "P"; line1[1] = "R"; line1[2] = "E"; line1[3] = "S";
                line1[4] = "S"; line1[5] = " "; line1[6] = "S"; line1[7] = "T";
                line1[8] = "A"; line1[9] = "R"; line1[10] = "T";
            end
            4'd1: begin  // Playing
                line1[0] = "H"; line1[1] = "I"; line1[2] = "G"; line1[3] = "H";
                line1[4] = ":"; line1[5] = " ";
                line1[6] = "0" + (high_score / 10);
                line1[7] = "0" + (high_score % 10);
                line1[11] = "L"; line1[12] = "I"; line1[13] = "F"; line1[14] = "E";
                line1[15] = ":";
                line2[0] = "S"; line2[1] = "T"; line2[2] = "A"; line2[3] = "G";
                line2[4] = "E"; line2[5] = ":"; line2[6] = " ";
                line2[7] = "0" + (stage / 10);
                line2[8] = "0" + (stage % 10);
                // Display life hearts on line1
                if (life >= 1) line1[9] = "*";
                if (life >= 2) line1[10] = "*";
                if (life >= 3) line1[11] = "*";
            end
            4'd2: begin  // Correct
                line1[0] = "C"; line1[1] = "O"; line1[2] = "R"; line1[3] = "R";
                line1[4] = "E"; line1[5] = "C"; line1[6] = "T"; line1[7] = "!";
                line2[0] = "P"; line2[1] = "R"; line2[2] = "E"; line2[3] = "S";
                line2[4] = "S"; line2[5] = " "; line2[6] = "N"; line2[7] = "E";
                line2[8] = "X"; line2[9] = "T";
            end
            4'd3: begin  // Wrong
                line1[0] = "W"; line1[1] = "R"; line1[2] = "O"; line1[3] = "N";
                line1[4] = "G"; line1[5] = "!";
                line2[0] = "L"; line2[1] = "I"; line2[2] = "F"; line2[3] = "E";
                line2[4] = ":"; line2[5] = " ";
                if (life >= 1) line2[6] = "*";
                if (life >= 2) line2[7] = "*";
                if (life >= 3) line2[8] = "*";
            end
            4'd4: begin  // Game Over
                line1[0] = "G"; line1[1] = "A"; line1[2] = "M"; line1[3] = "E";
                line1[4] = " "; line1[5] = "O"; line1[6] = "V"; line1[7] = "E";
                line1[8] = "R";
                line2[0] = "S"; line2[1] = "C"; line2[2] = "O"; line2[3] = "R";
                line2[4] = "E"; line2[5] = ":"; line2[6] = " ";
                line2[7] = "0" + (stage / 10);
                line2[8] = "0" + (stage % 10);
            end
            4'd5: begin  // New Record
                line1[0] = "N"; line1[1] = "E"; line1[2] = "W"; line1[3] = " ";
                line1[4] = "R"; line1[5] = "E"; line1[6] = "C"; line1[7] = "O";
                line1[8] = "R"; line1[9] = "D"; line1[10] = "!";
                line2[0] = "S"; line2[1] = "C"; line2[2] = "O"; line2[3] = "R";
                line2[4] = "E"; line2[5] = ":"; line2[6] = " ";
                line2[7] = "0" + (high_score / 10);
                line2[8] = "0" + (high_score % 10);
            end
        endcase
    end

endmodule
