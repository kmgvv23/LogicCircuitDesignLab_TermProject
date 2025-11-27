////////////////////////////////////////////////////////////////////////////////
// Pattern Generator
// Generates random LED pattern using LFSR
// Pattern length = stage + 3 (Stage 1 = 4 LEDs, Stage 2 = 5 LEDs, etc.)
////////////////////////////////////////////////////////////////////////////////

module pattern_generator (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [7:0] stage,

    output reg [7:0] pattern_seq [0:31],  // Pattern sequence (max 32)
    output reg [4:0] pattern_length,      // Actual pattern length
    output reg done
);

    // LFSR for random number generation (16-bit)
    reg [15:0] lfsr;
    reg [4:0] gen_count;
    reg generating;

    // LFSR tap positions: 16, 14, 13, 11 (maximal length)
    wire feedback = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];

    // State machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= 16'hACE1;  // Non-zero seed
            gen_count <= 0;
            generating <= 0;
            done <= 0;
            pattern_length <= 0;
        end else begin
            if (start && !generating) begin
                // Start pattern generation
                generating <= 1;
                done <= 0;
                gen_count <= 0;
                // Calculate pattern length: stage + 3
                pattern_length <= stage[4:0] + 5'd3;
                // Cap at 32 max
                if (stage[4:0] + 5'd3 > 31)
                    pattern_length <= 31;
            end else if (generating) begin
                if (gen_count < pattern_length) begin
                    // Generate next random LED position (0-7)
                    pattern_seq[gen_count] <= {5'b0, lfsr[2:0]};

                    // Advance LFSR
                    lfsr <= {lfsr[14:0], feedback};
                    gen_count <= gen_count + 1;
                end else begin
                    // Generation complete
                    generating <= 0;
                    done <= 1;
                end
            end else if (done && !start) begin
                // Clear done flag when start is deasserted
                done <= 0;
            end
        end
    end

endmodule
