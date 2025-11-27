////////////////////////////////////////////////////////////////////////////////
// 8-Array 7-Segment Display Controller
// Displays user input sequence (8 digits max)
// Uses multiplexing to drive 8 digits
// Uses flattened 1D array for Verilog compatibility
////////////////////////////////////////////////////////////////////////////////

module seven_seg_array (
    input wire clk,
    input wire rst,
    input wire [255:0] user_input_flat,
    input wire [4:0] input_count,

    output reg [7:0] seg_cathode,  // 8-bit cathode (segments a-g + dp)
    output reg [7:0] seg_anode     // 8-bit anode (digit select)
);

    // Multiplexing counter (refresh ~1kHz, each digit displayed ~125Hz)
    reg [16:0] refresh_counter;
    reg [2:0] digit_select;

    // Extract input value from flattened array
    function [3:0] get_input_value;
        input [4:0] index;
        begin
            get_input_value = user_input_flat[index*8 +: 4];
        end
    endfunction

    // 7-segment encoding (common anode: 0=on, 1=off)
    function [7:0] hex_to_7seg;
        input [3:0] hex;
        begin
            case (hex)
                4'h0: hex_to_7seg = 8'b11000000;  // 0
                4'h1: hex_to_7seg = 8'b11111001;  // 1
                4'h2: hex_to_7seg = 8'b10100100;  // 2
                4'h3: hex_to_7seg = 8'b10110000;  // 3
                4'h4: hex_to_7seg = 8'b10011001;  // 4
                4'h5: hex_to_7seg = 8'b10010010;  // 5
                4'h6: hex_to_7seg = 8'b10000010;  // 6
                4'h7: hex_to_7seg = 8'b11111000;  // 7
                4'h8: hex_to_7seg = 8'b10000000;  // 8
                4'h9: hex_to_7seg = 8'b10010000;  // 9
                default: hex_to_7seg = 8'b11111111;  // blank
            endcase
        end
    endfunction

    // Multiplexing: cycle through 8 digits
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_counter <= 0;
            digit_select <= 0;
        end else begin
            refresh_counter <= refresh_counter + 1;
            if (refresh_counter == 0) begin
                digit_select <= digit_select + 1;
            end
        end
    end

    // Display logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_cathode <= 8'b11111111;
            seg_anode <= 8'b11111111;
        end else begin
            // Select current digit
            seg_anode <= ~(8'b1 << digit_select);

            // Display user input
            if (digit_select < input_count) begin
                // Display the corresponding input value
                seg_cathode <= hex_to_7seg(get_input_value(digit_select));
            end else begin
                // No input yet for this digit, show blank
                seg_cathode <= 8'b11111111;
            end
        end
    end

endmodule
