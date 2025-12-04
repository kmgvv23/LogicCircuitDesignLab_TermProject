// pattern_compare.v
// Compare user input with generated pattern
module pattern_compare(
    input wire clk,
    input wire rst,
    input wire [3:0] pattern_0,
    input wire [3:0] pattern_1,
    input wire [3:0] pattern_2,
    input wire [3:0] pattern_3,
    input wire [3:0] pattern_4,
    input wire [3:0] pattern_5,
    input wire [3:0] pattern_6,
    input wire [3:0] pattern_7,
    input wire [3:0] input_0,
    input wire [3:0] input_1,
    input wire [3:0] input_2,
    input wire [3:0] input_3,
    input wire [3:0] input_4,
    input wire [3:0] input_5,
    input wire [3:0] input_6,
    input wire [3:0] input_7,
    input wire [3:0] pattern_length,
    input wire [3:0] input_length,
    input wire compare_en,
    output reg match
);

    integer i;
    reg all_match;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            match <= 1'b0;
        end else if (compare_en) begin
            // First check if lengths match
            if (pattern_length != input_length) begin
                match <= 1'b0;
            end else begin
                // Check each element
                all_match = 1'b1;

                if (pattern_length >= 1 && pattern_0 != input_0) all_match = 1'b0;
                if (pattern_length >= 2 && pattern_1 != input_1) all_match = 1'b0;
                if (pattern_length >= 3 && pattern_2 != input_2) all_match = 1'b0;
                if (pattern_length >= 4 && pattern_3 != input_3) all_match = 1'b0;
                if (pattern_length >= 5 && pattern_4 != input_4) all_match = 1'b0;
                if (pattern_length >= 6 && pattern_5 != input_5) all_match = 1'b0;
                if (pattern_length >= 7 && pattern_6 != input_6) all_match = 1'b0;
                if (pattern_length >= 8 && pattern_7 != input_7) all_match = 1'b0;

                match <= all_match;
            end
        end
    end

endmodule
