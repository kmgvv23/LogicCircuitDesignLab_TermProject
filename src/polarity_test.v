// polarity_test.v
// Test ALL polarities at once
module polarity_test(
    input clk,
    input [7:0] dip_sw,
    input [11:0] btn,
    output [7:0] led,
    output [7:0] seg_timer_data,
    output [7:0] seg_arr_data,
    output [7:0] seg_arr_sel,
    output [7:0] lcd_data,
    output lcd_e,
    output lcd_rs,
    output lcd_rw,
    output piezo,
    output rgb_r,
    output rgb_g,
    output rgb_b
);

    reg [31:0] counter;

    always @(posedge clk) begin
        counter <= counter + 1;
    end

    // LEDs: Direct button mapping (already confirmed working)
    assign led = btn[7:0];

    // Single 7-segment: Test "8" pattern
    // Try BOTH polarities - see which one shows "8"
    assign seg_timer_data = (dip_sw[1] == 0) ? 8'b10000000 : 8'b01111111;
    // DIP_SW1=0: Common Anode (0=ON), shows "8"
    // DIP_SW1=1: Common Cathode (1=ON), shows "8"

    // 8-array 7-segment: Show "1" on rightmost digit
    wire [2:0] scan = counter[19:17];

    assign seg_arr_data = (scan == 3'd7) ?
                          ((dip_sw[2] == 0) ? 8'b11111001 : 8'b00000110) :
                          8'b11111111;
    // DIP_SW2=0: Common Anode (shows "1")
    // DIP_SW2=1: Common Cathode (shows "1")

    assign seg_arr_sel = (scan == 3'd7) ?
                         ((dip_sw[3] == 0) ? 8'b01111111 : 8'b10000000) :
                         8'b00000000;
    // DIP_SW3=0: Active LOW select
    // DIP_SW3=1: Active HIGH select

    // RGB LED on button 10
    assign rgb_r = (dip_sw[4] == 0) ? ~btn[9] : btn[9];
    assign rgb_g = (dip_sw[4] == 0) ? btn[9] : ~btn[9];
    assign rgb_b = 1'b1;

    // LCD off
    assign lcd_data = 8'h00;
    assign lcd_e = 1'b0;
    assign lcd_rs = 1'b0;
    assign lcd_rw = 1'b0;

    // Piezo off
    assign piezo = 1'b0;

endmodule
