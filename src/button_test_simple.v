// button_test_simple.v
// Ultra-simple button test - bypasses all debouncing
module button_test_simple(
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

    // Direct button to LED mapping (no debouncing)
    // Buttons are active LOW, LEDs light when LOW
    assign led = ~btn[7:0];  // Buttons 1-8 to LEDs

    // Show button 10 (start) on RGB LED
    assign rgb_r = btn[9];   // Green when pressed (active low)
    assign rgb_g = ~btn[9];
    assign rgb_b = 1'b1;

    // Turn off 7-segments and LCD
    assign seg_timer_data = 8'b11111111;
    assign seg_arr_data = 8'b11111111;
    assign seg_arr_sel = 8'b11111111;
    assign lcd_data = 8'h00;
    assign lcd_e = 1'b0;
    assign lcd_rs = 1'b0;
    assign lcd_rw = 1'b0;
    assign piezo = 1'b0;

endmodule
