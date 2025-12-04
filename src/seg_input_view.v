// seg_input_view.v
// 8-array 7-segment display controller (right-aligned input sequence)
module seg_input_view(
    input wire clk,
    input wire rst,
    input wire [3:0] input_0,
    input wire [3:0] input_1,
    input wire [3:0] input_2,
    input wire [3:0] input_3,
    input wire [3:0] input_4,
    input wire [3:0] input_5,
    input wire [3:0] input_6,
    input wire [3:0] input_7,
    input wire [3:0] input_length,
    output reg [7:0] seg_data,  // {DP, G, F, E, D, C, B, A}
    output reg [7:0] seg_sel    // S0~S7, active low
);

    localparam REFRESH_RATE = 100_000;  // ~1kHz at 100MHz

    reg [16:0] counter;
    reg [2:0] scan_pos;
    reg [3:0] current_digit;

    // 7-segment decoder (Common Anode: 0=ON, 1=OFF)
    function [7:0] decode_seg;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: decode_seg = 8'b11000000;
                4'd1: decode_seg = 8'b11111001;
                4'd2: decode_seg = 8'b10100100;
                4'd3: decode_seg = 8'b10110000;
                4'd4: decode_seg = 8'b10011001;
                4'd5: decode_seg = 8'b10010010;
                4'd6: decode_seg = 8'b10000010;
                4'd7: decode_seg = 8'b11111000;
                4'd8: decode_seg = 8'b10000000;
                4'd9: decode_seg = 8'b10010000;
                default: decode_seg = 8'b11111111;  // Blank
            endcase
        end
    endfunction

    // Scan counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            scan_pos <= 0;
        end else begin
            if (counter < REFRESH_RATE - 1) begin
                counter <= counter + 1;
            end else begin
                counter <= 0;
                scan_pos <= scan_pos + 1;
            end
        end
    end

    // Select digit based on scan position and input length (right-aligned)
    always @(*) begin
        case (scan_pos)
            3'd0: current_digit = (input_length >= 8) ? input_7 : 4'd10;
            3'd1: current_digit = (input_length >= 7) ? input_6 : 4'd10;
            3'd2: current_digit = (input_length >= 6) ? input_5 : 4'd10;
            3'd3: current_digit = (input_length >= 5) ? input_4 : 4'd10;
            3'd4: current_digit = (input_length >= 4) ? input_3 : 4'd10;
            3'd5: current_digit = (input_length >= 3) ? input_2 : 4'd10;
            3'd6: current_digit = (input_length >= 2) ? input_1 : 4'd10;
            3'd7: current_digit = (input_length >= 1) ? input_0 : 4'd10;
            default: current_digit = 4'd10;
        endcase
    end

    // Output segment data and selection
    always @(*) begin
        seg_data = decode_seg(current_digit);
        case (scan_pos)
            3'd0: seg_sel = 8'b11111110;  // S0
            3'd1: seg_sel = 8'b11111101;  // S1
            3'd2: seg_sel = 8'b11111011;  // S2
            3'd3: seg_sel = 8'b11110111;  // S3
            3'd4: seg_sel = 8'b11101111;  // S4
            3'd5: seg_sel = 8'b11011111;  // S5
            3'd6: seg_sel = 8'b10111111;  // S6
            3'd7: seg_sel = 8'b01111111;  // S7
            default: seg_sel = 8'b11111111;
        endcase
    end

endmodule
