`timescale 1ns/1ps
module tb_mul4x4_systolic;
    reg clk;
    reg rst_n;
    reg [3:0] a, b;
    wire [7:0] p;
    systolic4x4_mul uut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .p(p)
    );
    initial clk = 0;
    always #5 clk = ~clk;
    initial begin
        rst_n = 0;
        a = 4'd0;
        b = 4'd0;
        #12;
        rst_n = 1;
        #10 a=4'd4; b=4'd3;   // 4*3 = 12
        #200;
        $stop;
    end
    initial begin
        $display("Time\t a b | p");
        $monitor("%0dns\t %d %d | %d", $time, a, b, p);
    end
endmodule

