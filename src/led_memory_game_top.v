////////////////////////////////////////////////////////////////////////////////
// LED Pattern Memory Game - Top Module
// Board: Combo 2 DLD (Spartan-7 xc7s75fgga484-1)
// Clock: 100MHz (assumed)
////////////////////////////////////////////////////////////////////////////////

module led_memory_game_top (
    // Clock and Reset
    input wire clk,              // 100MHz system clock
    input wire rst,              // Reset button (active high)

    // Button Inputs
    input wire btn_start,        // Start/Restart button
    input wire btn_confirm,      // Confirm/Enter button
    input wire btn_back,         // Back/Undo button
    input wire [7:0] btn_num,    // Number buttons 1-8

    // DIP Switch
    input wire dip_reset,        // Game reset switch

    // Speed Selection (3 levels: 00=slow, 01=medium, 10=fast)
    input wire [1:0] speed_select,

    // LED Array Output (8 LEDs for pattern display)
    output wire [7:0] led_array,

    // RGB LED Output (single RGB LED)
    output wire rgb_r,
    output wire rgb_g,
    output wire rgb_b,

    // LCD 16x2 Interface (4-bit parallel)
    output wire lcd_rs,          // Register select
    output wire lcd_rw,          // Read/Write
    output wire lcd_e,           // Enable
    output wire [3:0] lcd_data,  // 4-bit data bus

    // 8-Array 7-Segment Display (for user input AND timer display)
    // Digits 0-5: User input, Digits 6-7: Timer countdown
    output wire [7:0] seg_array_cathode,  // 7-segment cathodes (8 digits)
    output wire [7:0] seg_array_anode,    // 7-segment anodes (digit select)

    // Piezo Buzzer
    output wire piezo
);

    // Internal signals
    wire [7:0] debounced_num;
    wire debounced_start, debounced_confirm, debounced_back;
    wire system_reset;

    // Game state signals
    wire [3:0] game_state;
    wire [7:0] current_stage;
    wire [2:0] lives;
    wire [7:0] high_score;

    // Pattern signals (flattened 1D array)
    wire [255:0] pattern_seq_flat;  // 32 x 8-bit flattened
    wire [4:0] pattern_length;
    wire pattern_gen_start;
    wire pattern_gen_done;

    // Display signals
    wire pattern_display_start;
    wire pattern_display_done;
    wire [7:0] current_led;

    // Input signals (flattened 1D array)
    wire [255:0] user_input_flat;   // 32 x 8-bit flattened
    wire [4:0] user_input_count;
    wire input_complete;

    // Answer checking
    wire answer_correct;
    wire check_start;
    wire check_done;

    // Timer signals
    wire [3:0] timer_sec_ones;
    wire [3:0] timer_sec_tens;
    wire timer_expired;
    wire timer_start;

    // Piezo signals
    wire [1:0] piezo_mode;  // 0=off, 1=beep, 2=correct, 3=wrong
    wire piezo_trigger;

    // LCD signals
    wire [127:0] lcd_line1;
    wire [127:0] lcd_line2;
    wire lcd_update;

    // System reset = external reset OR DIP switch
    assign system_reset = rst | dip_reset;


    ////////////////////////////////////////////////////////////////////////////
    // Button Debouncers
    ////////////////////////////////////////////////////////////////////////////

    button_debouncer db_start (
        .clk(clk),
        .rst(system_reset),
        .btn_in(btn_start),
        .btn_out(debounced_start)
    );

    button_debouncer db_confirm (
        .clk(clk),
        .rst(system_reset),
        .btn_in(btn_confirm),
        .btn_out(debounced_confirm)
    );

    button_debouncer db_back (
        .clk(clk),
        .rst(system_reset),
        .btn_in(btn_back),
        .btn_out(debounced_back)
    );

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : btn_debounce
            button_debouncer db_num (
                .clk(clk),
                .rst(system_reset),
                .btn_in(btn_num[i]),
                .btn_out(debounced_num[i])
            );
        end
    endgenerate


    ////////////////////////////////////////////////////////////////////////////
    // Game Controller (Main FSM)
    ////////////////////////////////////////////////////////////////////////////

    game_controller game_ctrl (
        .clk(clk),
        .rst(system_reset),
        .btn_start(debounced_start),
        .btn_confirm(debounced_confirm),
        .pattern_gen_done(pattern_gen_done),
        .pattern_display_done(pattern_display_done),
        .input_complete(input_complete),
        .check_done(check_done),
        .answer_correct(answer_correct),
        .timer_expired(timer_expired),
        .game_state(game_state),
        .current_stage(current_stage),
        .lives(lives),
        .pattern_gen_start(pattern_gen_start),
        .pattern_display_start(pattern_display_start),
        .timer_start(timer_start),
        .check_start(check_start)
    );


    ////////////////////////////////////////////////////////////////////////////
    // Pattern Generator (LFSR-based random pattern)
    ////////////////////////////////////////////////////////////////////////////

    pattern_generator patt_gen (
        .clk(clk),
        .rst(system_reset),
        .start(pattern_gen_start),
        .stage(current_stage),
        .pattern_seq_flat(pattern_seq_flat),
        .pattern_length(pattern_length),
        .done(pattern_gen_done)
    );


    ////////////////////////////////////////////////////////////////////////////
    // Pattern Display (LED sequencer)
    ////////////////////////////////////////////////////////////////////////////

    pattern_display patt_disp (
        .clk(clk),
        .rst(system_reset),
        .start(pattern_display_start),
        .speed(speed_select),
        .pattern_seq_flat(pattern_seq_flat),
        .pattern_length(pattern_length),
        .led_out(current_led),
        .piezo_trigger(piezo_trigger),
        .done(pattern_display_done)
    );

    assign led_array = current_led;


    ////////////////////////////////////////////////////////////////////////////
    // Input Handler
    ////////////////////////////////////////////////////////////////////////////

    input_handler input_hdl (
        .clk(clk),
        .rst(system_reset),
        .game_state(game_state),
        .btn_num(debounced_num),
        .btn_confirm(debounced_confirm),
        .btn_back(debounced_back),
        .pattern_length(pattern_length),
        .user_input_flat(user_input_flat),
        .user_input_count(user_input_count),
        .input_complete(input_complete)
    );


    ////////////////////////////////////////////////////////////////////////////
    // Answer Checker
    ////////////////////////////////////////////////////////////////////////////

    answer_checker ans_check (
        .clk(clk),
        .rst(system_reset),
        .start(check_start),
        .pattern_seq_flat(pattern_seq_flat),
        .pattern_length(pattern_length),
        .user_input_flat(user_input_flat),
        .user_input_count(user_input_count),
        .correct(answer_correct),
        .done(check_done)
    );


    ////////////////////////////////////////////////////////////////////////////
    // Timer Module (10 second countdown)
    ////////////////////////////////////////////////////////////////////////////

    timer_module timer (
        .clk(clk),
        .rst(system_reset),
        .start(timer_start),
        .game_state(game_state),
        .sec_ones(timer_sec_ones),
        .sec_tens(timer_sec_tens),
        .expired(timer_expired)
    );


    ////////////////////////////////////////////////////////////////////////////
    // High Score Manager
    ////////////////////////////////////////////////////////////////////////////

    high_score_manager hs_mgr (
        .clk(clk),
        .rst(system_reset),
        .game_state(game_state),
        .current_stage(current_stage),
        .high_score(high_score)
    );


    ////////////////////////////////////////////////////////////////////////////
    // LCD Controller (16x2, 4-bit)
    ////////////////////////////////////////////////////////////////////////////

    lcd_controller lcd_ctrl (
        .clk(clk),
        .rst(system_reset),
        .game_state(game_state),
        .stage(current_stage),
        .lives(lives),
        .high_score(high_score),
        .speed(speed_select),
        .answer_correct(answer_correct),
        .lcd_rs(lcd_rs),
        .lcd_rw(lcd_rw),
        .lcd_e(lcd_e),
        .lcd_data(lcd_data)
    );


    ////////////////////////////////////////////////////////////////////////////
    // 8-Array 7-Segment Display (User input)
    ////////////////////////////////////////////////////////////////////////////

    seven_seg_array seg_arr (
        .clk(clk),
        .rst(system_reset),
        .user_input_flat(user_input_flat),
        .input_count(user_input_count),
        .timer_sec_ones(timer_sec_ones),
        .timer_sec_tens(timer_sec_tens),
        .seg_cathode(seg_array_cathode),
        .seg_anode(seg_array_anode)
    );


    ////////////////////////////////////////////////////////////////////////////
    // RGB LED Controller
    ////////////////////////////////////////////////////////////////////////////

    rgb_controller rgb_ctrl (
        .clk(clk),
        .rst(system_reset),
        .game_state(game_state),
        .answer_correct(answer_correct),
        .rgb_r(rgb_r),
        .rgb_g(rgb_g),
        .rgb_b(rgb_b)
    );


    ////////////////////////////////////////////////////////////////////////////
    // Piezo Controller
    ////////////////////////////////////////////////////////////////////////////

    piezo_controller piezo_ctrl (
        .clk(clk),
        .rst(system_reset),
        .game_state(game_state),
        .trigger(piezo_trigger),
        .answer_correct(answer_correct),
        .btn_pressed(|debounced_num),
        .piezo_out(piezo)
    );

endmodule
