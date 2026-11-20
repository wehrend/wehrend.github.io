`timescale 1ns / 1ps

module mux3_tb;
    reg  [1:0] sel;
    reg  [7:0] a = 8'd10, b = 8'd20, c = 8'd30;
    wire [7:0] y;

    mux3 dut (.sel(sel), .a(a), .b(b), .c(c), .y(y));

    initial begin
        $dumpfile("mux3.vcd");
        $dumpvars(0, mux3_tb);
        sel = 2'b00; #10;
        sel = 2'b01; #10;
        sel = 2'b11; #10;   // the forgotten case
        b   = 8'd99; #10;   // change an input - does y follow?
        sel = 2'b10; #10;
        $finish;
    end

    always @(y) $strobe("t=%0d ns  sel=%b  y=%0d", $time, sel, y);
endmodule
