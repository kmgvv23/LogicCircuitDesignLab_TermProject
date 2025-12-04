// piezo_sound.v
// Piezo buzzer controller with musical notes
module piezo_sound(
    input wire clk,
    input wire rst,
    input wire [3:0] note_select,  // 1~8 for pattern playback
    input wire play_note,
    input wire play_correct,
    input wire play_wrong,
    output reg piezo
);

    // Note frequencies (at 100MHz clock)
    // Divider = 100_000_000 / (2 * frequency)
    localparam C4_DIV = 190840;  // 262 Hz
    localparam D4_DIV = 170068;  // 294 Hz
    localparam E4_DIV = 151515;  // 330 Hz
    localparam F4_DIV = 143266;  // 349 Hz
    localparam G4_DIV = 127551;  // 392 Hz
    localparam A4_DIV = 113636;  // 440 Hz
    localparam B4_DIV = 101215;  // 494 Hz
    localparam C5_DIV = 95602;   // 523 Hz

    localparam NOTE_DURATION = 30_000_000;  // 300ms

    reg [31:0] freq_divider;
    reg [31:0] freq_counter;
    reg [31:0] duration_counter;
    reg tone_en;
    reg [2:0] melody_index;
    reg [31:0] melody_counter;

    // Select frequency divider based on note
    always @(*) begin
        case (note_select)
            4'd1: freq_divider = C4_DIV;
            4'd2: freq_divider = D4_DIV;
            4'd3: freq_divider = E4_DIV;
            4'd4: freq_divider = F4_DIV;
            4'd5: freq_divider = G4_DIV;
            4'd6: freq_divider = A4_DIV;
            4'd7: freq_divider = B4_DIV;
            4'd8: freq_divider = C5_DIV;
            default: freq_divider = C4_DIV;
        endcase
    end

    // Tone generator
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            freq_counter <= 0;
            duration_counter <= 0;
            tone_en <= 1'b0;
            piezo <= 1'b0;
            melody_index <= 0;
            melody_counter <= 0;
        end else begin
            // Handle play triggers
            if (play_note) begin
                tone_en <= 1'b1;
                duration_counter <= 0;
                freq_counter <= 0;
                melody_index <= 0;
            end else if (play_correct) begin
                tone_en <= 1'b1;
                duration_counter <= 0;
                freq_counter <= 0;
                melody_index <= 3'd1;  // Correct melody
                melody_counter <= 0;
            end else if (play_wrong) begin
                tone_en <= 1'b1;
                duration_counter <= 0;
                freq_counter <= 0;
                melody_index <= 3'd2;  // Wrong melody
                melody_counter <= 0;
            end

            // Generate tone
            if (tone_en) begin
                if (melody_index == 0) begin
                    // Single note mode
                    if (duration_counter < NOTE_DURATION) begin
                        duration_counter <= duration_counter + 1;
                        if (freq_counter < freq_divider) begin
                            freq_counter <= freq_counter + 1;
                        end else begin
                            freq_counter <= 0;
                            piezo <= ~piezo;
                        end
                    end else begin
                        tone_en <= 1'b0;
                        piezo <= 1'b0;
                    end
                end else if (melody_index == 3'd1) begin
                    // Correct melody: C-E-G (ascending)
                    if (melody_counter < 30_000_000) begin
                        melody_counter <= melody_counter + 1;
                        if (freq_counter < C4_DIV) begin
                            freq_counter <= freq_counter + 1;
                        end else begin
                            freq_counter <= 0;
                            piezo <= ~piezo;
                        end
                    end else if (melody_counter < 60_000_000) begin
                        melody_counter <= melody_counter + 1;
                        if (freq_counter < E4_DIV) begin
                            freq_counter <= freq_counter + 1;
                        end else begin
                            freq_counter <= 0;
                            piezo <= ~piezo;
                        end
                    end else if (melody_counter < 90_000_000) begin
                        melody_counter <= melody_counter + 1;
                        if (freq_counter < G4_DIV) begin
                            freq_counter <= freq_counter + 1;
                        end else begin
                            freq_counter <= 0;
                            piezo <= ~piezo;
                        end
                    end else begin
                        tone_en <= 1'b0;
                        piezo <= 1'b0;
                        melody_index <= 0;
                    end
                end else if (melody_index == 3'd2) begin
                    // Wrong melody: G-E-C (descending)
                    if (melody_counter < 30_000_000) begin
                        melody_counter <= melody_counter + 1;
                        if (freq_counter < G4_DIV) begin
                            freq_counter <= freq_counter + 1;
                        end else begin
                            freq_counter <= 0;
                            piezo <= ~piezo;
                        end
                    end else if (melody_counter < 60_000_000) begin
                        melody_counter <= melody_counter + 1;
                        if (freq_counter < E4_DIV) begin
                            freq_counter <= freq_counter + 1;
                        end else begin
                            freq_counter <= 0;
                            piezo <= ~piezo;
                        end
                    end else if (melody_counter < 90_000_000) begin
                        melody_counter <= melody_counter + 1;
                        if (freq_counter < C4_DIV) begin
                            freq_counter <= freq_counter + 1;
                        end else begin
                            freq_counter <= 0;
                            piezo <= ~piezo;
                        end
                    end else begin
                        tone_en <= 1'b0;
                        piezo <= 1'b0;
                        melody_index <= 0;
                    end
                end
            end else begin
                piezo <= 1'b0;
            end
        end
    end

endmodule
