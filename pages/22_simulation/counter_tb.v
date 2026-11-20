`timescale 1ns / 1ps

module counter_tb;
    reg        clk = 0;
    reg        rst = 1;
    reg        en  = 0;
    wire [3:0] q;

    counter dut (.clk(clk), .rst(rst), .en(en), .q(q));

    // clock: period 10 ns (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb);

        #12 rst = 0;      // release reset after the first rising edge
        #10 en  = 1;      // start counting
        #100 en = 0;      // pause for two clock cycles
        #20 en  = 1;      // continue
        #60;
        $finish;
    end

    // print the counter value after every rising clock edge
    always @(posedge clk)
        $strobe("t=%0d ns  rst=%b en=%b q=%0d", $time, rst, en, q);
endmodule
