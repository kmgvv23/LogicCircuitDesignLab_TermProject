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

    // 7-segment encoding (common cathode: 1=on, 0=off)
    // Includes DP (bit 7, always off for timer)
    function [7:0] digit_to_7seg;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: digit_to_7seg = 8'b00111111;  // 0
                4'd1: digit_to_7seg = 8'b00000110;  // 1
                4'd2: digit_to_7seg = 8'b01011011;  // 2
                4'd3: digit_to_7seg = 8'b01001111;  // 3
                4'd4: digit_to_7seg = 8'b01100110;  // 4
                4'd5: digit_to_7seg = 8'b01101101;  // 5
                4'd6: digit_to_7seg = 8'b01111101;  // 6
                4'd7: digit_to_7seg = 8'b00000111;  // 7
                4'd8: digit_to_7seg = 8'b01111111;  // 8
                4'd9: digit_to_7seg = 8'b01101111;  // 9
                default: digit_to_7seg = 8'b00000000;  // blank
            endcase
        end
    endfunction

    // Display logic - simply show sec_ones on single digit
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_cathode <= 8'b00000000;
        end else begin
            // Display countdown value (9 -> 0)
            seg_cathode <= digit_to_7seg(sec_ones);
        end
    end

endmodule
