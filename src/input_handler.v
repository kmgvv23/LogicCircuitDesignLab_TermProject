////////////////////////////////////////////////////////////////////////////////
// Input Handler Module
// Handles user button input and stores sequence
// - Number buttons (1-8) add to sequence
// - Back button removes last input
// - Confirm button completes input
// Uses flattened 1D array for Verilog compatibility
////////////////////////////////////////////////////////////////////////////////

module input_handler (
    input wire clk,
    input wire rst,
    input wire [3:0] game_state,
    input wire [7:0] btn_num,
    input wire btn_confirm,
    input wire btn_back,
    input wire [4:0] pattern_length,

    output reg [255:0] user_input_flat,
    output reg [4:0] user_input_count,
    output reg input_complete
);

    // Game states (must match game_controller.v)
    localparam STATE_WAIT_INPUT = 4'd4;

    // Button edge detection
    reg [7:0] btn_num_prev;
    reg btn_confirm_prev;
    reg btn_back_prev;
    wire [7:0] btn_num_edge;
    wire btn_confirm_edge;
    wire btn_back_edge;

    assign btn_num_edge = btn_num & ~btn_num_prev;
    assign btn_confirm_edge = btn_confirm & ~btn_confirm_prev;
    assign btn_back_edge = btn_back & ~btn_back_prev;

    // Internal array for easier manipulation
    reg [7:0] user_input [0:31];
    integer i;

    // Pack array into flat output
    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            user_input_flat[i*8 +: 8] = user_input[i];
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_num_prev <= 8'b0;
            btn_confirm_prev <= 1'b0;
            btn_back_prev <= 1'b0;
            user_input_count <= 0;
            input_complete <= 0;
            for (i = 0; i < 32; i = i + 1)
                user_input[i] <= 0;
        end else begin
            // Update previous button states
            btn_num_prev <= btn_num;
            btn_confirm_prev <= btn_confirm;
            btn_back_prev <= btn_back;

            if (game_state == STATE_WAIT_INPUT) begin
                // Handle number button presses
                if (btn_num_edge != 8'b0 && user_input_count < 31) begin
                    // Determine which button was pressed (0-7)
                    if (btn_num_edge[0]) user_input[user_input_count] <= 8'd0;
                    else if (btn_num_edge[1]) user_input[user_input_count] <= 8'd1;
                    else if (btn_num_edge[2]) user_input[user_input_count] <= 8'd2;
                    else if (btn_num_edge[3]) user_input[user_input_count] <= 8'd3;
                    else if (btn_num_edge[4]) user_input[user_input_count] <= 8'd4;
                    else if (btn_num_edge[5]) user_input[user_input_count] <= 8'd5;
                    else if (btn_num_edge[6]) user_input[user_input_count] <= 8'd6;
                    else if (btn_num_edge[7]) user_input[user_input_count] <= 8'd7;

                    user_input_count <= user_input_count + 1;
                end

                // Handle back button (undo last input)
                if (btn_back_edge && user_input_count > 0) begin
                    user_input_count <= user_input_count - 1;
                    user_input[user_input_count - 1] <= 0;
                end

                // Handle confirm button
                if (btn_confirm_edge) begin
                    input_complete <= 1;
                end
            end else begin
                // Reset for next input phase
                user_input_count <= 0;
                input_complete <= 0;
                for (i = 0; i < 32; i = i + 1)
                    user_input[i] <= 0;
            end
        end
    end

endmodule
