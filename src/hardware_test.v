// hardware_test.v
// Simple hardware connection test module
module hardware_test(
    input clk,
    input [7:0] dip_sw,
    input [11:0] btn,
    output reg [7:0] led,
    output reg [7:0] seg_timer_data,
    output reg [7:0] seg_arr_data,
    output reg [7:0] seg_arr_sel,
    output reg [7:0] lcd_data,
    output reg lcd_e,
    output reg lcd_rs,
    output reg lcd_rw,
    output reg piezo,
    output reg rgb_r,
    output reg rgb_g,
    output reg rgb_b
);

    reg [31:0] counter;
    reg [2:0] scan_pos;

    // Simple counter
    always @(posedge clk) begin
        counter <= counter + 1;
    end

    // Test LEDs: Light up when corresponding button is pressed
    always @(*) begin
        led = ~btn[7:0];  // Active low buttons, so invert
    end

    // Test single 7-segment: Show "8" (all segments on except DP)
    always @(*) begin
        seg_timer_data = 8'b10000000;  // Common Anode: 0=ON
    end

    // Test 8-array 7-segment: Show "1" on rightmost digit
    always @(*) begin
        scan_pos = counter[19:17];  // Scan at ~381Hz

        case (scan_pos)
            3'd7: begin
                seg_arr_data = 8'b11111001;  // "1"
                seg_arr_sel = 8'b01111111;   // S7
            end
            default: begin
                seg_arr_data = 8'b11111111;  // Blank
                seg_arr_sel = 8'b11111111;   // None
            end
        endcase
    end

    // Test RGB LED: Cycle through colors
    always @(*) begin
        case (counter[25:24])
            2'b00: begin rgb_r = 1'b0; rgb_g = 1'b1; rgb_b = 1'b1; end  // Red
            2'b01: begin rgb_r = 1'b1; rgb_g = 1'b0; rgb_b = 1'b1; end  // Green
            2'b10: begin rgb_r = 1'b1; rgb_g = 1'b1; rgb_b = 1'b0; end  // Blue
            2'b11: begin rgb_r = 1'b1; rgb_g = 1'b1; rgb_b = 1'b1; end  // Off
        endcase
    end

    // Test LCD: Simple initialization and display
    always @(*) begin
        lcd_data = 8'h00;
        lcd_e = 1'b0;
        lcd_rs = 1'b0;
        lcd_rw = 1'b0;
    end

    // Test Piezo: Generate ~440Hz tone when button 0 pressed
    always @(*) begin
        if (~btn[0]) begin
            piezo = counter[16];  // ~1.5kHz
        end else begin
            piezo = 1'b0;
        end
    end

endmodule
