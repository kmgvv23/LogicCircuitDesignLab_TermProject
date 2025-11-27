////////////////////////////////////////////////////////////////////////////////
// Piezo Buzzer Controller
// Generates tones for different game events
// - Pattern display: Simple beep (1kHz)
// - Button press: Click sound (2kHz)
// - Correct answer: Ascending tone (C-E-G)
// - Wrong answer: Descending buzz (500Hz)
////////////////////////////////////////////////////////////////////////////////

module piezo_controller (
    input wire clk,
    input wire rst,
    input wire [3:0] game_state,
    input wire trigger,           // Pattern display trigger
    input wire answer_correct,
    input wire btn_pressed,       // Any button pressed

    output reg piezo_out
);

    // Game states
    localparam STATE_SHOW_PATTERN = 4'd3;
    localparam STATE_WAIT_INPUT   = 4'd4;
    localparam STATE_CORRECT      = 4'd6;
    localparam STATE_WRONG        = 4'd7;

    // Frequency dividers (100MHz clock)
    // Note frequencies: C4=262Hz, E4=330Hz, G4=392Hz
    localparam FREQ_C4   = 190840;  // 100MHz / (262Hz * 2)
    localparam FREQ_E4   = 151515;  // 100MHz / (330Hz * 2)
    localparam FREQ_G4   = 127551;  // 100MHz / (392Hz * 2)
    localparam FREQ_1KHZ = 50000;   // 100MHz / (1000Hz * 2)
    localparam FREQ_2KHZ = 25000;   // 100MHz / (2000Hz * 2)
    localparam FREQ_500HZ = 100000; // 100MHz / (500Hz * 2)

    // Tone duration (100ms = 10,000,000 cycles at 100MHz)
    localparam TONE_DURATION = 10_000_000;

    reg [31:0] freq_divider;
    reg [31:0] tone_counter;
    reg [31:0] duration_counter;
    reg [1:0] melody_step;
    reg tone_active;
    reg trigger_prev;
    reg btn_prev;

    // Detect edges
    wire trigger_edge = trigger && !trigger_prev;
    wire btn_edge = btn_pressed && !btn_prev;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            piezo_out <= 1'b0;
            freq_divider <= FREQ_1KHZ;
            tone_counter <= 0;
            duration_counter <= 0;
            melody_step <= 0;
            tone_active <= 0;
            trigger_prev <= 0;
            btn_prev <= 0;
        end else begin
            trigger_prev <= trigger;
            btn_prev <= btn_pressed;

            // State-based tone generation
            case (game_state)
                STATE_SHOW_PATTERN: begin
                    // Beep when pattern LED lights up
                    if (trigger_edge) begin
                        tone_active <= 1;
                        duration_counter <= 0;
                        freq_divider <= FREQ_1KHZ;
                    end
                end

                STATE_WAIT_INPUT: begin
                    // Click sound on button press
                    if (btn_edge) begin
                        tone_active <= 1;
                        duration_counter <= 0;
                        freq_divider <= FREQ_2KHZ;
                    end
                end

                STATE_CORRECT: begin
                    // Play ascending melody: C-E-G
                    if (melody_step == 0) begin
                        tone_active <= 1;
                        freq_divider <= FREQ_C4;
                        melody_step <= 1;
                        duration_counter <= 0;
                    end else if (melody_step == 1 && duration_counter >= TONE_DURATION) begin
                        freq_divider <= FREQ_E4;
                        melody_step <= 2;
                        duration_counter <= 0;
                    end else if (melody_step == 2 && duration_counter >= TONE_DURATION) begin
                        freq_divider <= FREQ_G4;
                        melody_step <= 3;
                        duration_counter <= 0;
                    end else if (melody_step == 3 && duration_counter >= TONE_DURATION) begin
                        tone_active <= 0;
                        melody_step <= 0;
                    end
                end

                STATE_WRONG: begin
                    // Play buzz
                    if (melody_step == 0) begin
                        tone_active <= 1;
                        freq_divider <= FREQ_500HZ;
                        melody_step <= 1;
                        duration_counter <= 0;
                    end else if (duration_counter >= TONE_DURATION * 2) begin
                        tone_active <= 0;
                        melody_step <= 0;
                    end
                end

                default: begin
                    tone_active <= 0;
                    melody_step <= 0;
                end
            endcase

            // Generate tone
            if (tone_active) begin
                tone_counter <= tone_counter + 1;
                duration_counter <= duration_counter + 1;

                if (tone_counter >= freq_divider) begin
                    piezo_out <= ~piezo_out;
                    tone_counter <= 0;
                end

                // Auto-stop short tones
                if (game_state == STATE_SHOW_PATTERN || game_state == STATE_WAIT_INPUT) begin
                    if (duration_counter >= TONE_DURATION) begin
                        tone_active <= 0;
                        piezo_out <= 0;
                    end
                end
            end else begin
                piezo_out <= 1'b0;
                tone_counter <= 0;
                duration_counter <= 0;
            end
        end
    end

endmodule
