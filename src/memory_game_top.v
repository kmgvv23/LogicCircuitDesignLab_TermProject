// memory_game_top.v
// Top-level module for memory game
module memory_game_top(
    input clk,
    input [7:0] dip_sw,
    input [11:0] btn,
    output [7:0] led,
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

    // Reset signal from DIP_SW1
    wire rst;
    wire game_enable;
    assign game_enable = dip_sw[0];
    assign rst = ~dip_sw[0];

    // Debounced button signals
    wire [11:0] btn_db;
    wire [11:0] btn_edge;

    // Pattern storage
    reg [3:0] pattern [0:7];
    wire [3:0] random_num;
    reg [3:0] pattern_index;

    // Input buffer signals
    wire [3:0] input_buf [0:7];
    wire [3:0] input_length;

    // FSM control signals
    wire [3:0] fsm_state;
    wire gen_pattern, play_pattern, clear_input;
    wire start_timer, stop_timer;
    wire compare_en, match_result;
    wire show_correct, show_wrong;
    wire play_correct_sound, play_wrong_sound;
    wire update_highscore;
    wire [7:0] stage;
    wire [2:0] life;
    wire [3:0] pattern_length;
    wire [3:0] display_mode;

    // LED player signals
    wire [7:0] led_out;
    wire [3:0] note_out;
    wire play_note;
    wire player_playing, player_done;

    // Timer signals
    wire timeout;

    // High score
    wire [7:0] high_score;
    wire new_record;

    // Generate 12 debouncers for buttons
    genvar i;
    generate
        for (i = 0; i < 12; i = i + 1) begin : btn_debounce
            debouncer debouncer_inst (
                .clk(clk),
                .rst(rst),
                .btn_in(btn[i]),
                .btn_out(btn_db[i]),
                .btn_edge(btn_edge[i])
            );
        end
    endgenerate

    // LFSR random generator
    lfsr_random lfsr_inst (
        .clk(clk),
        .rst(rst),
        .enable(gen_pattern),
        .random_num(random_num)
    );

    // Pattern generation logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pattern_index <= 0;
            pattern[0] <= 4'd1;
            pattern[1] <= 4'd2;
            pattern[2] <= 4'd3;
            pattern[3] <= 4'd4;
            pattern[4] <= 4'd5;
            pattern[5] <= 4'd6;
            pattern[6] <= 4'd7;
            pattern[7] <= 4'd8;
        end else if (gen_pattern) begin
            if (pattern_index < pattern_length) begin
                pattern[pattern_index] <= random_num;
                pattern_index <= pattern_index + 1;
            end else begin
                pattern_index <= 0;
            end
        end else begin
            pattern_index <= 0;
        end
    end

    // FSM controller
    fsm_controller fsm_inst (
        .clk(clk),
        .rst(rst),
        .game_enable(game_enable),
        .start_btn(btn_edge[9]),   // Use edge signal
        .confirm_btn(btn_edge[11]), // Use edge signal
        .timeout(timeout),
        .player_done(player_done),
        .match_result(match_result),
        .state_out(fsm_state),
        .gen_pattern(gen_pattern),
        .play_pattern(play_pattern),
        .clear_input(clear_input),
        .start_timer(start_timer),
        .stop_timer(stop_timer),
        .compare_en(compare_en),
        .show_correct(show_correct),
        .show_wrong(show_wrong),
        .play_correct_sound(play_correct_sound),
        .play_wrong_sound(play_wrong_sound),
        .update_highscore(update_highscore),
        .stage(stage),
        .life(life),
        .pattern_length(pattern_length),
        .display_mode(display_mode)
    );

    // Input buffer
    input_buffer input_buf_inst (
        .clk(clk),
        .rst(rst),
        .clear(clear_input),
        .num_btn(btn_db[7:0]),
        .cancel_btn(btn_db[8]),
        .input_0(input_buf[0]),
        .input_1(input_buf[1]),
        .input_2(input_buf[2]),
        .input_3(input_buf[3]),
        .input_4(input_buf[4]),
        .input_5(input_buf[5]),
        .input_6(input_buf[6]),
        .input_7(input_buf[7]),
        .input_length(input_length)
    );

    // Pattern comparator
    pattern_compare compare_inst (
        .clk(clk),
        .rst(rst),
        .pattern_0(pattern[0]),
        .pattern_1(pattern[1]),
        .pattern_2(pattern[2]),
        .pattern_3(pattern[3]),
        .pattern_4(pattern[4]),
        .pattern_5(pattern[5]),
        .pattern_6(pattern[6]),
        .pattern_7(pattern[7]),
        .input_0(input_buf[0]),
        .input_1(input_buf[1]),
        .input_2(input_buf[2]),
        .input_3(input_buf[3]),
        .input_4(input_buf[4]),
        .input_5(input_buf[5]),
        .input_6(input_buf[6]),
        .input_7(input_buf[7]),
        .pattern_length(pattern_length),
        .input_length(input_length),
        .compare_en(compare_en),
        .match(match_result)
    );

    // High score register
    highscore_reg highscore_inst (
        .clk(clk),
        .rst(rst),
        .current_stage(stage),
        .update_en(update_highscore),
        .high_score(high_score),
        .new_record(new_record)
    );

    // LED player
    led_player led_player_inst (
        .clk(clk),
        .rst(rst),
        .start(play_pattern),
        .pattern_0(pattern[0]),
        .pattern_1(pattern[1]),
        .pattern_2(pattern[2]),
        .pattern_3(pattern[3]),
        .pattern_4(pattern[4]),
        .pattern_5(pattern[5]),
        .pattern_6(pattern[6]),
        .pattern_7(pattern[7]),
        .pattern_length(pattern_length),
        .led(led_out),
        .note_out(note_out),
        .play_note(play_note),
        .playing(player_playing),
        .done(player_done)
    );

    assign led = led_out | fsm_state;  // Show both pattern AND FSM state on LEDs

    // Piezo sound controller
    piezo_sound piezo_inst (
        .clk(clk),
        .rst(rst),
        .note_select(note_out),
        .play_note(play_note),
        .play_correct(play_correct_sound),
        .play_wrong(play_wrong_sound),
        .piezo(piezo)
    );

    // RGB LED controller
    rgb_led_ctrl rgb_inst (
        .clk(clk),
        .rst(rst),
        .show_correct(show_correct),
        .show_wrong(show_wrong),
        .rgb_r(rgb_r),
        .rgb_g(rgb_g),
        .rgb_b(rgb_b)
    );

    // Single 7-segment timer
    seg_timer seg_timer_inst (
        .clk(clk),
        .rst(rst),
        .start(start_timer),
        .stop(stop_timer),
        .seg_data(seg_timer_data),
        .timeout(timeout)
    );

    // 8-array 7-segment input display
    seg_input_view seg_input_inst (
        .clk(clk),
        .rst(rst),
        .input_0(input_buf[0]),
        .input_1(input_buf[1]),
        .input_2(input_buf[2]),
        .input_3(input_buf[3]),
        .input_4(input_buf[4]),
        .input_5(input_buf[5]),
        .input_6(input_buf[6]),
        .input_7(input_buf[7]),
        .input_length(input_length),
        .seg_data(seg_arr_data),
        .seg_sel(seg_arr_sel)
    );

    // LCD controller
    lcd_controller lcd_inst (
        .clk(clk),
        .rst(rst),
        .stage(stage),
        .high_score(high_score),
        .life(life),
        .display_mode(display_mode),
        .lcd_data(lcd_data),
        .lcd_e(lcd_e),
        .lcd_rs(lcd_rs),
        .lcd_rw(lcd_rw)
    );

endmodule
