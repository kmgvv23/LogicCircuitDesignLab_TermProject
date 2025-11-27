////////////////////////////////////////////////////////////////////////////////
// Timer 7-Segment Display Controller
// Displays 2-digit countdown timer (00-10 seconds)
// Uses multiplexing for 2 digits
////////////////////////////////////////////////////////////////////////////////

module seven_seg_timer (
    input wire clk,
    input wire rst,
    input wire [3:0] sec_ones,
    input wire [3:0] sec_tens,

    output reg [6:0] seg_cathode,  // 7-bit cathode (segments a-g)
    output reg [1:0] seg_anode     // 2-bit anode (digit select)
);

    // Multiplexing counter
    reg [15:0] refresh_counter;
    reg digit_select;

    // 7-segment encoding (common anode: 0=on, 1=off)
    function [6:0] digit_to_7seg;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: digit_to_7seg = 7'b1000000;  // 0
                4'd1: digit_to_7seg = 7'b1111001;  // 1
                4'd2: digit_to_7seg = 7'b0100100;  // 2
                4'd3: digit_to_7seg = 7'b0110000;  // 3
                4'd4: digit_to_7seg = 7'b0011001;  // 4
                4'd5: digit_to_7seg = 7'b0010010;  // 5
                4'd6: digit_to_7seg = 7'b0000010;  // 6
                4'd7: digit_to_7seg = 7'b1111000;  // 7
                4'd8: digit_to_7seg = 7'b0000000;  // 8
                4'd9: digit_to_7seg = 7'b0010000;  // 9
                default: digit_to_7seg = 7'b1111111;  // blank
            endcase
        end
    endfunction

    // Multiplexing: alternate between 2 digits
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_counter <= 0;
            digit_select <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
            if (refresh_counter == 0) begin
                digit_select <= ~digit_select;
            end
        end
    end

    // Display logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_cathode <= 7'b1111111;
            seg_anode <= 2'b11;
        end else begin
            if (digit_select == 0) begin
                // Display tens digit
                seg_anode <= 2'b10;
                seg_cathode <= digit_to_7seg(sec_tens);
            end else begin
                // Display ones digit
                seg_anode <= 2'b01;
                seg_cathode <= digit_to_7seg(sec_ones);
            end
        end
    end

endmodule
