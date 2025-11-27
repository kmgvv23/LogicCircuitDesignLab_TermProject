////////////////////////////////////////////////////////////////////////////////
// High Score Manager
// Tracks and updates the highest stage reached
////////////////////////////////////////////////////////////////////////////////

module high_score_manager (
    input wire clk,
    input wire rst,
    input wire [3:0] game_state,
    input wire [7:0] current_stage,

    output reg [7:0] high_score
);

    // Game states (must match game_controller.v)
    localparam STATE_GAME_OVER = 4'd9;

    reg [3:0] prev_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            high_score <= 8'd0;
            prev_state <= 4'd0;
        end else begin
            prev_state <= game_state;

            // Check for transition to GAME_OVER state
            if (game_state == STATE_GAME_OVER && prev_state != STATE_GAME_OVER) begin
                // Game just ended, check if new high score
                if (current_stage > high_score) begin
                    high_score <= current_stage;
                end
            end
        end
    end

endmodule
