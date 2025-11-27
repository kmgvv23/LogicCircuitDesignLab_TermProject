////////////////////////////////////////////////////////////////////////////////
// Timer Module
// 10-second countdown timer for user input phase
// Outputs BCD digits for 7-segment display
////////////////////////////////////////////////////////////////////////////////

module timer_module (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [3:0] game_state,

    output reg [3:0] sec_ones,
    output reg [3:0] sec_tens,
    output reg expired
);

    // Game states (must match game_controller.v)
    localparam STATE_WAIT_INPUT = 4'd4;

    // Timer constants
    localparam TIMER_INITIAL = 10;  // 10 seconds
    localparam CYCLES_PER_SEC = 100_000_000;  // 100MHz clock

    reg [31:0] cycle_counter;
    reg [3:0] seconds_remaining;
    reg timer_active;

    // Convert seconds to BCD
    always @(*) begin
        sec_tens = seconds_remaining / 10;
        sec_ones = seconds_remaining % 10;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle_counter <= 0;
            seconds_remaining <= TIMER_INITIAL;
            timer_active <= 0;
            expired <= 0;
        end else begin
            if (start && !timer_active) begin
                // Start timer
                timer_active <= 1;
                seconds_remaining <= TIMER_INITIAL;
                cycle_counter <= 0;
                expired <= 0;
            end else if (timer_active && game_state == STATE_WAIT_INPUT) begin
                cycle_counter <= cycle_counter + 1;

                if (cycle_counter >= CYCLES_PER_SEC - 1) begin
                    // One second elapsed
                    cycle_counter <= 0;

                    if (seconds_remaining > 0) begin
                        seconds_remaining <= seconds_remaining - 1;
                    end else begin
                        // Timer expired
                        expired <= 1;
                        timer_active <= 0;
                    end
                end
            end else if (game_state != STATE_WAIT_INPUT) begin
                // Reset timer when not in input state
                timer_active <= 0;
                expired <= 0;
                seconds_remaining <= TIMER_INITIAL;
                cycle_counter <= 0;
            end
        end
    end

endmodule
