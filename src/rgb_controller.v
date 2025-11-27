////////////////////////////////////////////////////////////////////////////////
// RGB LED Controller
// Controls RGB LED based on game state
// Green = Correct answer
// Red = Wrong answer
// Off = Other states
////////////////////////////////////////////////////////////////////////////////

module rgb_controller (
    input wire clk,
    input wire rst,
    input wire [3:0] game_state,
    input wire answer_correct,

    output reg rgb_r,
    output reg rgb_g,
    output reg rgb_b
);

    // Game states (must match game_controller.v)
    localparam STATE_CORRECT = 4'd6;
    localparam STATE_WRONG   = 4'd7;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rgb_r <= 1'b0;
            rgb_g <= 1'b0;
            rgb_b <= 1'b0;
        end else begin
            case (game_state)
                STATE_CORRECT: begin
                    // Green
                    rgb_r <= 1'b0;
                    rgb_g <= 1'b1;
                    rgb_b <= 1'b0;
                end

                STATE_WRONG: begin
                    // Red
                    rgb_r <= 1'b1;
                    rgb_g <= 1'b0;
                    rgb_b <= 1'b0;
                end

                default: begin
                    // Off
                    rgb_r <= 1'b0;
                    rgb_g <= 1'b0;
                    rgb_b <= 1'b0;
                end
            endcase
        end
    end

endmodule
