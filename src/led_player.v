// led_player.v
// LED pattern player with synchronized audio
module led_player(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [3:0] pattern_0,
    input wire [3:0] pattern_1,
    input wire [3:0] pattern_2,
    input wire [3:0] pattern_3,
    input wire [3:0] pattern_4,
    input wire [3:0] pattern_5,
    input wire [3:0] pattern_6,
    input wire [3:0] pattern_7,
    input wire [3:0] pattern_length,
    output reg [7:0] led,
    output reg [3:0] note_out,
    output reg play_note,
    output reg playing,
    output reg done
);

    localparam STEP_DURATION = 50_000_000;  // 500ms per LED

    reg [3:0] current_index;
    reg [31:0] step_counter;
    reg [3:0] current_pattern;
    reg note_triggered;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_index <= 0;
            step_counter <= 0;
            led <= 8'b00000000;
            note_out <= 4'd0;
            play_note <= 1'b0;
            playing <= 1'b0;
            done <= 1'b0;
            note_triggered <= 1'b0;
        end else begin
            if (start) begin
                current_index <= 0;
                step_counter <= 0;
                playing <= 1'b1;
                done <= 1'b0;
                note_triggered <= 1'b0;
            end else if (playing) begin
                if (current_index < pattern_length) begin
                    // Select current pattern
                    case (current_index)
                        4'd0: current_pattern = pattern_0;
                        4'd1: current_pattern = pattern_1;
                        4'd2: current_pattern = pattern_2;
                        4'd3: current_pattern = pattern_3;
                        4'd4: current_pattern = pattern_4;
                        4'd5: current_pattern = pattern_5;
                        4'd6: current_pattern = pattern_6;
                        4'd7: current_pattern = pattern_7;
                        default: current_pattern = 4'd0;
                    endcase

                    if (step_counter == 0 && !note_triggered) begin
                        // Light up LED and trigger note
                        case (current_pattern)
                            4'd1: led <= 8'b00000001;
                            4'd2: led <= 8'b00000010;
                            4'd3: led <= 8'b00000100;
                            4'd4: led <= 8'b00001000;
                            4'd5: led <= 8'b00010000;
                            4'd6: led <= 8'b00100000;
                            4'd7: led <= 8'b01000000;
                            4'd8: led <= 8'b10000000;
                            default: led <= 8'b00000000;
                        endcase
                        note_out <= current_pattern;
                        play_note <= 1'b1;
                        note_triggered <= 1'b1;
                    end else begin
                        play_note <= 1'b0;
                    end

                    if (step_counter < STEP_DURATION - 1) begin
                        step_counter <= step_counter + 1;
                    end else begin
                        step_counter <= 0;
                        current_index <= current_index + 1;
                        led <= 8'b00000000;
                        note_triggered <= 1'b0;
                    end
                end else begin
                    // Finished playing pattern
                    playing <= 1'b0;
                    done <= 1'b1;
                    led <= 8'b00000000;
                end
            end else begin
                led <= 8'b00000000;
                play_note <= 1'b0;
                if (done && !start) begin
                    done <= 1'b0;
                end
            end
        end
    end

endmodule
