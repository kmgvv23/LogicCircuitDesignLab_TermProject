////////////////////////////////////////////////////////////////////////////////
// Button Debouncer Module
// Debounces button input with ~20ms delay
// Clock: 100MHz
////////////////////////////////////////////////////////////////////////////////

module button_debouncer (
    input wire clk,
    input wire rst,
    input wire btn_in,
    output reg btn_out
);

    // 20ms debounce time at 100MHz = 2,000,000 cycles
    parameter DEBOUNCE_CYCLES = 2_000_000;

    reg [20:0] counter;
    reg btn_sync_0, btn_sync_1;
    reg btn_stable;

    // Synchronize button input to clock domain
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_sync_0 <= 1'b0;
            btn_sync_1 <= 1'b0;
        end else begin
            btn_sync_0 <= btn_in;
            btn_sync_1 <= btn_sync_0;
        end
    end

    // Debounce logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            btn_stable <= 1'b0;
            btn_out <= 1'b0;
        end else begin
            if (btn_sync_1 != btn_stable) begin
                // Button state is different from stable state
                counter <= counter + 1;
                if (counter >= DEBOUNCE_CYCLES) begin
                    btn_stable <= btn_sync_1;
                    counter <= 0;
                end
            end else begin
                // Button state matches stable state
                counter <= 0;
            end

            // Output is the stable state
            btn_out <= btn_stable;
        end
    end

endmodule
