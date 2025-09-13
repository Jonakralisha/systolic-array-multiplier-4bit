 `timescale 1ns/1ps
`define IDX_A(r,c) ((r)*5 + (c))   // a_bus has 4 rows x 5 cols  = 20 bits
`define IDX_B(r,c) ((r)*4 + (c))   // b_bus has 5 rows x 4 cols  = 20 bits
`define IDX_S(r,c) ((r)*5 + (c))   // sum grid is 5x5 entries
module systolic4x4_mul (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] a,      // multiplicand
    input  wire [3:0] b,      // multiplier
    output wire [7:0] p       // product
);
    // Flattened interconnect
    wire [19:0]  a_bus;       // 4x5
    wire [19:0]  b_bus;       // 5x4
    wire [199:0] sum_bus;     // 25 entries * 8 bits each
    genvar i, j;
    generate
        for (i = 0; i < 4; i = i + 1) begin : A_LEFT
            assign a_bus[`IDX_A(i,0)] = a[i];
        end
    endgenerate
    generate
        for (j = 0; j < 4; j = j + 1) begin : B_TOP
            assign b_bus[`IDX_B(0,j)] = b[j];
        end
    endgenerate
    // Sum boundaries:
    assign sum_bus[8*`IDX_S(0,0)+7 : 8*`IDX_S(0,0)] = 8'd0;
    generate
        for (i = 0; i < 3; i = i + 1) begin : SUM_CHAIN
            assign sum_bus[8*`IDX_S(i+1,0)+7 : 8*`IDX_S(i+1,0)]
                 = sum_bus[8*`IDX_S(i,4)+7   : 8*`IDX_S(i,4)];
        end
    endgenerate
    // 4x4 PE grid
    generate
        for (i = 0; i < 4; i = i + 1) begin : ROWS
            for (j = 0; j < 4; j = j + 1) begin : COLS
                pe_cell #(.ROW(i), .COL(j)) u_pe (
                    .clk    (clk),
                    .rst_n  (rst_n),
                    .a_in   (a_bus[`IDX_A(i,j)]),
                    .b_in   (b_bus[`IDX_B(i,j)]),
                    .sum_in (sum_bus[8*`IDX_S(i,j)+7 : 8*`IDX_S(i,j)]),
                    .a_out  (a_bus[`IDX_A(i, j+1)]),
                    .b_out  (b_bus[`IDX_B(i+1, j)]),
                    .sum_out(sum_bus[8*`IDX_S(i, j+1)+7 : 8*`IDX_S(i, j+1)])
                );
            end
        end
    endgenerate
    // Final product
    assign p = sum_bus[8*`IDX_S(3,4)+7 : 8*`IDX_S(3,4)];
endmodule
