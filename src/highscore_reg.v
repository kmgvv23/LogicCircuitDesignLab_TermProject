// highscore_reg.v
// High score register and comparison logic
module highscore_reg(
    input wire clk,
    input wire rst,
    input wire [7:0] current_stage,
    input wire update_en,
    output reg [7:0] high_score,
    output reg new_record
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            high_score <= 8'd0;
            new_record <= 1'b0;
        end else begin
            if (update_en) begin
                if (current_stage > high_score) begin
                    high_score <= current_stage;
                    new_record <= 1'b1;
                end else begin
                    new_record <= 1'b0;
                end
            end else begin
                new_record <= 1'b0;
            end
        end
    end

endmodule
