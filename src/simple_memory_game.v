// simple_memory_game.v
// Ultra-simple working version - core functionality only
module simple_memory_game(
    input clk,
    input [7:0] dip_sw,
    input [11:0] btn,
    output reg [7:0] led,
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

    wire rst = ~dip_sw[0];

    // Simple state machine
    localparam IDLE = 0;
    localparam SHOW = 1;
    localparam WAIT = 2;

    reg [1:0] state;
    reg [31:0] counter;
    reg [2:0] pattern_index;
    reg [2:0] pattern [0:2];  // Only 3 items for simplicity

    // Simple pattern (fixed for now)
    initial begin
        pattern[0] = 3'd0;  // LED 1
        pattern[1] = 3'd2;  // LED 3
        pattern[2] = 3'd4;  // LED 5
    end

    // Button debounce (super simple)
    reg [19:0] btn_counter;
    reg btn_start_prev;
    wire btn_start_pressed;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_counter <= 0;
            btn_start_prev <= 0;
        end else begin
            if (btn[9] != btn_start_prev) begin
                if (btn_counter < 200000) begin  // 2ms
                    btn_counter <= btn_counter + 1;
                end else begin
                    btn_start_prev <= btn[9];
                    btn_counter <= 0;
                end
            end else begin
                btn_counter <= 0;
            end
        end
    end

    assign btn_start_pressed = (btn[9] == 1 && btn_start_prev == 0);

    // Main FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            led <= 8'b00000000;
            counter <= 0;
            pattern_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    led <= 8'b00000001;  // LED 1 to show IDLE
                    if (btn_start_pressed) begin
                        state <= SHOW;
                        pattern_index <= 0;
                        counter <= 0;
                    end
                end

                SHOW: begin
                    if (counter < 50_000_000) begin  // 500ms
                        // Turn on current LED
                        led <= (8'b00000001 << pattern[pattern_index]);
                        counter <= counter + 1;
                    end else begin
                        counter <= 0;
                        if (pattern_index < 2) begin
                            pattern_index <= pattern_index + 1;
                        end else begin
                            state <= WAIT;
                            led <= 8'b10000000;  // LED 8 to show WAIT
                        end
                    end
                end

                WAIT: begin
                    led <= 8'b10000000;  // Keep LED 8 on
                    if (btn_start_pressed) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    // Turn off everything else
    assign seg_timer_data = 8'b00000000;
    assign seg_arr_data = 8'b00000000;
    assign seg_arr_sel = 8'b00000000;
    assign lcd_data = 8'h00;
    assign lcd_e = 1'b0;
    assign lcd_rs = 1'b0;
    assign lcd_rw = 1'b0;
    assign piezo = 1'b0;
    assign rgb_r = 1'b1;
    assign rgb_g = 1'b1;
    assign rgb_b = 1'b1;

endmodule
