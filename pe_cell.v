`timescale 1ns/1ps
// One pipeline stage (Processing Element)
module pe_cell #(
    parameter ROW = 0,
    parameter COL = 0
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       a_in,      // 1-bit
    input  wire       b_in,      // 1-bit
    input  wire [7:0] sum_in,    // running sum
    output reg        a_out,
    output reg        b_out,
    output reg  [7:0] sum_out
);
    localparam integer SHIFT = ROW+COL;
    wire [7:0] pp = (a_in & b_in) ? (8'd1 << SHIFT) : 8'd0;
 
    always @(posedge clk) begin
        if (!rst_n) begin
            a_out   <= 1'b0;
            b_out   <= 1'b0;
            sum_out <= 8'd0;
        end else begin
            a_out   <= a_in;           // push A right
            b_out   <= b_in;           // push B down
            sum_out <= sum_in + pp;    // accumulate local partial product
        end
    end
endmodule
