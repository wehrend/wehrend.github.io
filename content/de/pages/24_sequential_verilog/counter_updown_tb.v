`timescale 1ns / 1ps

module counter_updown_tb;
    reg        clk = 0;
    reg        rst = 1;
    reg        en  = 0;
    reg        up  = 1;
    wire [3:0] q;

    counter_updown #(.WIDTH(4), .MOD(10)) dut (
        .clk(clk), .rst(rst), .en(en), .up(up), .q(q)
    );

    // clock: period 10 ns
    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter_updown.vcd");
        $dumpvars(0, counter_updown_tb);

        #12  rst = 0;
        #10  en  = 1;     // count up: 0 ... 9, 0 ... 3
        #130 up  = 0;     // count down: 2, 1, 0, 9, 8, 7
        #60;
        $finish;
    end

    always @(posedge clk)
        $strobe("t=%0d ns  rst=%b en=%b up=%b  q=%0d", $time, rst, en, up, q);
endmodule
