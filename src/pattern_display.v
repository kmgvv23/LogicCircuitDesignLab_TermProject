////////////////////////////////////////////////////////////////////////////////
// Pattern Display Module
// Sequentially displays LED pattern with speed control
// Speed: 00=slow(1s), 01=medium(0.5s), 10=fast(0.25s)
// Uses flattened 1D array for Verilog compatibility
////////////////////////////////////////////////////////////////////////////////

module pattern_display (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [1:0] speed,
    input wire [255:0] pattern_seq_flat,
    input wire [4:0] pattern_length,

    output reg [7:0] led_out,
    output reg piezo_trigger,
    output reg done
);

    // Timing parameters (100MHz clock)
    localparam SLOW_CYCLES   = 100_000_000;  // 1.0 second
    localparam MEDIUM_CYCLES = 50_000_000;   // 0.5 second
    localparam FAST_CYCLES   = 25_000_000;   // 0.25 second
    localparam LED_ON_TIME   = 20_000_000;   // LED on for 0.2 second

    reg [31:0] counter;
    reg [31:0] interval_cycles;
    reg [4:0] display_index;
    reg displaying;
    reg led_active;

    // Extract pattern value from flattened array
    function [2:0] get_pattern_led;
        input [4:0] index;
        begin
            get_pattern_led = pattern_seq_flat[index*8 +: 3];
        end
    endfunction

    // Select interval based on speed
    always @(*) begin
        case (speed)
            2'b00: interval_cycles = SLOW_CYCLES;
            2'b01: interval_cycles = MEDIUM_CYCLES;
            2'b10: interval_cycles = FAST_CYCLES;
            default: interval_cycles = MEDIUM_CYCLES;
        endcase
    end

    // Display FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_out <= 8'b0;
            counter <= 0;
            display_index <= 0;
            displaying <= 0;
            led_active <= 0;
            done <= 0;
            piezo_trigger <= 0;
        end else begin
            piezo_trigger <= 0;  // Default

            if (start && !displaying) begin
                // Start display sequence
                displaying <= 1;
                done <= 0;
                display_index <= 0;
                counter <= 0;
                led_active <= 1;
                // Turn on first LED
                led_out <= 8'b1 << get_pattern_led(0);
                piezo_trigger <= 1;
            end else if (displaying) begin
                counter <= counter + 1;

                if (led_active) begin
                    // LED is on, wait for LED_ON_TIME
                    if (counter >= LED_ON_TIME) begin
                        led_out <= 8'b0;  // Turn off LED
                        led_active <= 0;
                        counter <= 0;
                    end
                end else begin
                    // LED is off, wait for rest of interval
                    if (counter >= (interval_cycles - LED_ON_TIME)) begin
                        counter <= 0;
                        display_index <= display_index + 1;

                        if (display_index < pattern_length - 1) begin
                            // Show next LED
                            led_active <= 1;
                            led_out <= 8'b1 << get_pattern_led(display_index + 1);
                            piezo_trigger <= 1;
                        end else begin
                            // All LEDs displayed
                            displaying <= 0;
                            done <= 1;
                        end
                    end
                end
            end else if (done && !start) begin
                // Clear done flag when start is deasserted
                done <= 0;
            end
        end
    end

endmodule
