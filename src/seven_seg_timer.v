////////////////////////////////////////////////////////////////////////////////
// Timer 7-Segment Display Controller
// Displays single-digit countdown timer (9-0 seconds)
// No multiplexing - single digit display
////////////////////////////////////////////////////////////////////////////////

module seven_seg_timer (
    input wire clk,
    input wire rst,
    input wire [3:0] sec_ones,
    input wire [3:0] sec_tens,

    output reg [7:0] seg_cathode  // 8-bit cathode (segments a-g + dp)
);

    // 7-segment encoding (common anode: 0=on, 1=off)
    // Includes DP (bit 7, always off for timer)
    function [7:0] digit_to_7seg;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: digit_to_7seg = 8'b11000000;  // 0
                4'd1: digit_to_7seg = 8'b11111001;  // 1
                4'd2: digit_to_7seg = 8'b10100100;  // 2
                4'd3: digit_to_7seg = 8'b10110000;  // 3
                4'd4: digit_to_7seg = 8'b10011001;  // 4
                4'd5: digit_to_7seg = 8'b10010010;  // 5
                4'd6: digit_to_7seg = 8'b10000010;  // 6
                4'd7: digit_to_7seg = 8'b11111000;  // 7
                4'd8: digit_to_7seg = 8'b10000000;  // 8
                4'd9: digit_to_7seg = 8'b10010000;  // 9
                default: digit_to_7seg = 8'b11111111;  // blank
            endcase
        end
    endfunction

    // Display logic - simply show sec_ones on single digit
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_cathode <= 8'b11111111;
        end else begin
            // Display countdown value (9 -> 0)
            seg_cathode <= digit_to_7seg(sec_ones);
        end
    end

endmodule
