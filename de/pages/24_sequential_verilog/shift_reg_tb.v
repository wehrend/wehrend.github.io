`timescale 1ns / 1ps

module shift_reg_tb;
    reg        clk = 0;
    reg        d   = 0;
    wire [3:0] q_blocking, q_nonblocking;

    shift_reg_blocking bad  (.clk(clk), .d(d), .q(q_blocking));
    shift_reg          good (.clk(clk), .d(d), .q(q_nonblocking));

    // clock: period 10 ns
    always #5 clk = ~clk;

    initial begin
        $dumpfile("shift_reg.vcd");
        $dumpvars(0, shift_reg_tb);

        // shift in the pattern 1, 0, 0, 0, 0, ...
        #2  d = 1;
        #10 d = 0;
        #50;
        $finish;
    end

    // print both registers after every rising clock edge
    always @(posedge clk)
        $strobe("t=%0d ns  d=%b  blocking q=%b  non-blocking q=%b", $time, d, q_blocking, q_nonblocking);
endmodule
