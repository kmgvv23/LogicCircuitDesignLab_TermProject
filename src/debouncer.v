// debouncer.v
// Button debouncer module (20ms debounce time)
module debouncer #(
    parameter DEBOUNCE_TIME = 2_000_000  // 20ms at 100MHz
)(
    input wire clk,
    input wire rst,
    input wire btn_in,
    output reg btn_out,
    output reg btn_edge  // One-cycle pulse on rising edge
);

    reg [20:0] counter;
    reg btn_sync_0, btn_sync_1;
    reg btn_state;
    reg btn_prev;

    // Synchronizer
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_sync_0 <= 1'b1;  // Active low buttons
            btn_sync_1 <= 1'b1;
        end else begin
            btn_sync_0 <= btn_in;
            btn_sync_1 <= btn_sync_0;
        end
    end

    // Debounce logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            btn_state <= 1'b1;
        end else begin
            if (btn_sync_1 != btn_state) begin
                if (counter < DEBOUNCE_TIME) begin
                    counter <= counter + 1;
                end else begin
                    btn_state <= btn_sync_1;
                    counter <= 0;
                end
            end else begin
                counter <= 0;
            end
        end
    end

    // Output and edge detection
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_out <= 1'b1;
            btn_prev <= 1'b1;
            btn_edge <= 1'b0;
        end else begin
            btn_out <= btn_state;
            btn_prev <= btn_state;
            btn_edge <= (btn_prev == 1'b1) && (btn_state == 1'b0);  // Falling edge (pressed)
        end
    end

endmodule
