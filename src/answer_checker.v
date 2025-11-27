////////////////////////////////////////////////////////////////////////////////
// Answer Checker Module
// Compares user input with correct pattern sequence
////////////////////////////////////////////////////////////////////////////////

module answer_checker (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [7:0] pattern_seq [0:31],
    input wire [4:0] pattern_length,
    input wire [7:0] user_input [0:31],
    input wire [4:0] user_input_count,

    output reg correct,
    output reg done
);

    reg checking;
    reg [4:0] check_index;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            correct <= 0;
            done <= 0;
            checking <= 0;
            check_index <= 0;
        end else begin
            if (start && !checking) begin
                // Start checking
                checking <= 1;
                done <= 0;
                check_index <= 0;
                correct <= 1;  // Assume correct until proven wrong

                // First check: do lengths match?
                if (user_input_count != pattern_length) begin
                    correct <= 0;
                end
            end else if (checking) begin
                if (check_index < pattern_length && check_index < user_input_count) begin
                    // Compare each element
                    if (pattern_seq[check_index] != user_input[check_index]) begin
                        correct <= 0;
                    end
                    check_index <= check_index + 1;
                end else begin
                    // Checking complete
                    checking <= 0;
                    done <= 1;
                end
            end else if (done && !start) begin
                // Clear done flag
                done <= 0;
            end
        end
    end

endmodule
