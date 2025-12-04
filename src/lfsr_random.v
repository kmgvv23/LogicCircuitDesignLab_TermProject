// lfsr_random.v
// LFSR-based pseudo-random number generator (outputs 1~8)
module lfsr_random(
    input wire clk,
    input wire rst,
    input wire enable,
    output reg [3:0] random_num  // 1~8
);

    reg [15:0] lfsr;
    wire feedback;

    assign feedback = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];  // Taps for maximal LFSR

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= 16'hACE1;  // Non-zero seed
        end else if (enable) begin
            lfsr <= {lfsr[14:0], feedback};
        end
    end

    // Map to 1~8 range
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            random_num <= 4'd1;
        end else if (enable) begin
            case (lfsr[2:0])
                3'd0: random_num <= 4'd1;
                3'd1: random_num <= 4'd2;
                3'd2: random_num <= 4'd3;
                3'd3: random_num <= 4'd4;
                3'd4: random_num <= 4'd5;
                3'd5: random_num <= 4'd6;
                3'd6: random_num <= 4'd7;
                3'd7: random_num <= 4'd8;
            endcase
        end
    end

endmodule
