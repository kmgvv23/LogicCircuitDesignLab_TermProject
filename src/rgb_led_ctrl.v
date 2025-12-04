// rgb_led_ctrl.v
// RGB LED controller for correct/wrong feedback
module rgb_led_ctrl(
    input wire clk,
    input wire rst,
    input wire show_correct,   // Trigger green for 1 second
    input wire show_wrong,     // Trigger red for 1 second
    output reg rgb_r,
    output reg rgb_g,
    output reg rgb_b
);

    localparam ONE_SEC = 100_000_000;  // 1 second at 100MHz

    reg [26:0] counter;
    reg active;
    reg color_mode;  // 0=red, 1=green

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            active <= 1'b0;
            color_mode <= 1'b0;
            rgb_r <= 1'b1;  // Active low
            rgb_g <= 1'b1;
            rgb_b <= 1'b1;
        end else begin
            if (show_correct) begin
                active <= 1'b1;
                color_mode <= 1'b1;  // Green
                counter <= 0;
            end else if (show_wrong) begin
                active <= 1'b1;
                color_mode <= 1'b0;  // Red
                counter <= 0;
            end else if (active) begin
                if (counter < ONE_SEC) begin
                    counter <= counter + 1;
                end else begin
                    active <= 1'b0;
                    counter <= 0;
                end
            end

            // Output control
            if (active) begin
                if (color_mode == 1'b1) begin  // Green
                    rgb_r <= 1'b1;
                    rgb_g <= 1'b0;
                    rgb_b <= 1'b1;
                end else begin  // Red
                    rgb_r <= 1'b0;
                    rgb_g <= 1'b1;
                    rgb_b <= 1'b1;
                end
            end else begin
                rgb_r <= 1'b1;
                rgb_g <= 1'b1;
                rgb_b <= 1'b1;
            end
        end
    end

endmodule
