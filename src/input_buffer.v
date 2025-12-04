// input_buffer.v
// User input buffer with cancel functionality
module input_buffer(
    input wire clk,
    input wire rst,
    input wire clear,
    input wire [7:0] num_btn,    // btn[0]~btn[7] for 1~8
    input wire cancel_btn,       // btn[8] to cancel last input
    output reg [3:0] input_0,
    output reg [3:0] input_1,
    output reg [3:0] input_2,
    output reg [3:0] input_3,
    output reg [3:0] input_4,
    output reg [3:0] input_5,
    output reg [3:0] input_6,
    output reg [3:0] input_7,
    output reg [3:0] input_length
);

    reg [7:0] num_btn_prev;
    reg cancel_btn_prev;

    always @(posedge clk or posedge rst) begin
        if (rst || clear) begin
            input_0 <= 4'd0;
            input_1 <= 4'd0;
            input_2 <= 4'd0;
            input_3 <= 4'd0;
            input_4 <= 4'd0;
            input_5 <= 4'd0;
            input_6 <= 4'd0;
            input_7 <= 4'd0;
            input_length <= 4'd0;
            num_btn_prev <= 8'hFF;
            cancel_btn_prev <= 1'b1;
        end else begin
            num_btn_prev <= num_btn;
            cancel_btn_prev <= cancel_btn;

            // Detect button press (edge detection)
            if (cancel_btn_prev == 1'b1 && cancel_btn == 1'b0) begin
                // Cancel last input
                if (input_length > 0) begin
                    input_length <= input_length - 1;
                    // Shift all inputs right
                    case (input_length)
                        4'd1: input_0 <= 4'd0;
                        4'd2: begin input_1 <= 4'd0; end
                        4'd3: begin input_2 <= 4'd0; end
                        4'd4: begin input_3 <= 4'd0; end
                        4'd5: begin input_4 <= 4'd0; end
                        4'd6: begin input_5 <= 4'd0; end
                        4'd7: begin input_6 <= 4'd0; end
                        4'd8: begin input_7 <= 4'd0; end
                    endcase
                end
            end else if (input_length < 8) begin
                // Check for number button press
                if (num_btn_prev[0] == 1'b1 && num_btn[0] == 1'b0) begin
                    // Button 1 pressed
                    case (input_length)
                        4'd0: input_0 <= 4'd1;
                        4'd1: input_1 <= 4'd1;
                        4'd2: input_2 <= 4'd1;
                        4'd3: input_3 <= 4'd1;
                        4'd4: input_4 <= 4'd1;
                        4'd5: input_5 <= 4'd1;
                        4'd6: input_6 <= 4'd1;
                        4'd7: input_7 <= 4'd1;
                    endcase
                    input_length <= input_length + 1;
                end else if (num_btn_prev[1] == 1'b1 && num_btn[1] == 1'b0) begin
                    case (input_length)
                        4'd0: input_0 <= 4'd2;
                        4'd1: input_1 <= 4'd2;
                        4'd2: input_2 <= 4'd2;
                        4'd3: input_3 <= 4'd2;
                        4'd4: input_4 <= 4'd2;
                        4'd5: input_5 <= 4'd2;
                        4'd6: input_6 <= 4'd2;
                        4'd7: input_7 <= 4'd2;
                    endcase
                    input_length <= input_length + 1;
                end else if (num_btn_prev[2] == 1'b1 && num_btn[2] == 1'b0) begin
                    case (input_length)
                        4'd0: input_0 <= 4'd3;
                        4'd1: input_1 <= 4'd3;
                        4'd2: input_2 <= 4'd3;
                        4'd3: input_3 <= 4'd3;
                        4'd4: input_4 <= 4'd3;
                        4'd5: input_5 <= 4'd3;
                        4'd6: input_6 <= 4'd3;
                        4'd7: input_7 <= 4'd3;
                    endcase
                    input_length <= input_length + 1;
                end else if (num_btn_prev[3] == 1'b1 && num_btn[3] == 1'b0) begin
                    case (input_length)
                        4'd0: input_0 <= 4'd4;
                        4'd1: input_1 <= 4'd4;
                        4'd2: input_2 <= 4'd4;
                        4'd3: input_3 <= 4'd4;
                        4'd4: input_4 <= 4'd4;
                        4'd5: input_5 <= 4'd4;
                        4'd6: input_6 <= 4'd4;
                        4'd7: input_7 <= 4'd4;
                    endcase
                    input_length <= input_length + 1;
                end else if (num_btn_prev[4] == 1'b1 && num_btn[4] == 1'b0) begin
                    case (input_length)
                        4'd0: input_0 <= 4'd5;
                        4'd1: input_1 <= 4'd5;
                        4'd2: input_2 <= 4'd5;
                        4'd3: input_3 <= 4'd5;
                        4'd4: input_4 <= 4'd5;
                        4'd5: input_5 <= 4'd5;
                        4'd6: input_6 <= 4'd5;
                        4'd7: input_7 <= 4'd5;
                    endcase
                    input_length <= input_length + 1;
                end else if (num_btn_prev[5] == 1'b1 && num_btn[5] == 1'b0) begin
                    case (input_length)
                        4'd0: input_0 <= 4'd6;
                        4'd1: input_1 <= 4'd6;
                        4'd2: input_2 <= 4'd6;
                        4'd3: input_3 <= 4'd6;
                        4'd4: input_4 <= 4'd6;
                        4'd5: input_5 <= 4'd6;
                        4'd6: input_6 <= 4'd6;
                        4'd7: input_7 <= 4'd6;
                    endcase
                    input_length <= input_length + 1;
                end else if (num_btn_prev[6] == 1'b1 && num_btn[6] == 1'b0) begin
                    case (input_length)
                        4'd0: input_0 <= 4'd7;
                        4'd1: input_1 <= 4'd7;
                        4'd2: input_2 <= 4'd7;
                        4'd3: input_3 <= 4'd7;
                        4'd4: input_4 <= 4'd7;
                        4'd5: input_5 <= 4'd7;
                        4'd6: input_6 <= 4'd7;
                        4'd7: input_7 <= 4'd7;
                    endcase
                    input_length <= input_length + 1;
                end else if (num_btn_prev[7] == 1'b1 && num_btn[7] == 1'b0) begin
                    case (input_length)
                        4'd0: input_0 <= 4'd8;
                        4'd1: input_1 <= 4'd8;
                        4'd2: input_2 <= 4'd8;
                        4'd3: input_3 <= 4'd8;
                        4'd4: input_4 <= 4'd8;
                        4'd5: input_5 <= 4'd8;
                        4'd6: input_6 <= 4'd8;
                        4'd7: input_7 <= 4'd8;
                    endcase
                    input_length <= input_length + 1;
                end
            end
        end
    end

endmodule
