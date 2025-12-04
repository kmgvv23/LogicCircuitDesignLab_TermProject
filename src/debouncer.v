// debouncer.v
// Simple button debouncer for ACTIVE HIGH buttons
module debouncer #(
    parameter DEBOUNCE_TIME = 20_000  // 0.2ms at 100MHz
)(
    input wire clk,
    input wire rst,
    input wire btn_in,
    output reg btn_out,
    output reg btn_edge
);

    reg [15:0] counter;
    reg btn_sync;

    // Single-stage synchronizer
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_sync <= 1'b0;  // CORRECTED: Active HIGH, so unpressed = 0
        end else begin
            btn_sync <= btn_in;
        end
    end

    // Simple debounce with counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            btn_out <= 1'b0;   // CORRECTED: Unpressed = 0
            btn_edge <= 1'b0;
        end else begin
            // Default: no edge
            btn_edge <= 1'b0;

            if (btn_sync != btn_out) begin
                // Button state changing
                if (counter < DEBOUNCE_TIME) begin
                    counter <= counter + 1;
                end else begin
                    // Stable for debounce period
                    btn_out <= btn_sync;
                    counter <= 0;

                    // Generate edge on press (0->1)  CORRECTED
                    if (btn_out == 1'b0 && btn_sync == 1'b1) begin
                        btn_edge <= 1'b1;
                    end
                end
            end else begin
                // Button stable
                counter <= 0;
            end
        end
    end

endmodule
