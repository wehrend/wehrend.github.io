`timescale 1ns / 1ps

module latch_vs_ff_tb;
    reg  clk = 0;
    reg  d   = 0;
    wire q_latch, q_ff;

    // the clock is used as enable for the latch
    d_latch latch (.en(clk), .d(d), .q(q_latch));
    d_ff    ff    (.clk(clk), .d(d), .q(q_ff));

    // clock: period 20 ns
    always #10 clk = ~clk;

    initial begin
        $dumpfile("latch_vs_ff.vcd");
        $dumpvars(0, latch_vs_ff_tb);

        #13 d = 1;    // clk = 1: latch follows, flip-flop holds
        #4  d = 0;    // clk = 1: latch follows
        #8  d = 1;    // clk = 0: both hold, both take 1 at the edge at 30 ns
        #8  d = 0;    // clk = 1: latch follows, flip-flop holds
        #12 d = 1;    // clk = 0: both hold, both take 1 at the edge at 50 ns
        #10 d = 0;    // clk = 1: latch follows, flip-flop holds
        #25;
        $finish;
    end

    initial
        $monitor("t=%0d ns  clk=%b d=%b  q_latch=%b q_ff=%b", $time, clk, d, q_latch, q_ff);
endmodule
