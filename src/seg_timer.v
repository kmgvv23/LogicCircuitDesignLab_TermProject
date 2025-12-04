// seg_timer.v
// Single 7-segment countdown timer (9 to 0)
module seg_timer(
    input wire clk,
    input wire rst,
    input wire start,
    input wire stop,
    output reg [7:0] seg_data,  // {DP, G, F, E, D, C, B, A}
    output reg timeout
);

    localparam ONE_SEC = 100_000_000;  // 1 second at 100MHz

    reg [3:0] count;
    reg [26:0] counter;
    reg running;

    // 7-segment decoder (Common Cathode: 1=ON, 0=OFF)
    function [7:0] decode_seg;
        input [3:0] digit;
        begin
            case (digit)
                4'd0: decode_seg = 8'b00111111;  // 0
                4'd1: decode_seg = 8'b00000110;  // 1
                4'd2: decode_seg = 8'b01011011;  // 2
                4'd3: decode_seg = 8'b01001111;  // 3
                4'd4: decode_seg = 8'b01100110;  // 4
                4'd5: decode_seg = 8'b01101101;  // 5
                4'd6: decode_seg = 8'b01111101;  // 6
                4'd7: decode_seg = 8'b00000111;  // 7
                4'd8: decode_seg = 8'b01111111;  // 8
                4'd9: decode_seg = 8'b01101111;  // 9
                default: decode_seg = 8'b00000000;  // Blank
            endcase
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 4'd9;
            counter <= 0;
            running <= 1'b0;
            timeout <= 1'b0;
        end else begin
            if (start) begin
                count <= 4'd9;
                counter <= 0;
                running <= 1'b1;
                timeout <= 1'b0;
            end else if (stop) begin
                running <= 1'b0;
            end else if (running) begin
                if (counter < ONE_SEC - 1) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 0;
                    if (count > 0) begin
                        count <= count - 1;
                    end else begin
                        running <= 1'b0;
                        timeout <= 1'b1;
                    end
                end
            end
        end
    end

    always @(*) begin
        if (running || timeout) begin
            seg_data = decode_seg(count);
        end else begin
            seg_data = 8'b00000000;  // Blank when not running (Common Cathode)
        end
    end

endmodule
