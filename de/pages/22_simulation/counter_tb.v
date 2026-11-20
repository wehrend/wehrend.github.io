`timescale 1ns / 1ps

module counter_tb;
    reg        clk = 0;
    reg        rst = 1;
    reg        en  = 0;
    wire [3:0] q;

    counter dut (.clk(clk), .rst(rst), .en(en), .q(q));

    // Takt: Periode 10 ns (100 MHz)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb);

        #12 rst = 0;      // Reset nach der ersten steigenden Flanke aufheben
        #10 en  = 1;      // Zählen starten
        #100 en = 0;      // zwei Takte pausieren
        #20 en  = 1;      // weiterzählen
        #60;
        $finish;
    end

    // Zählerstand nach jeder steigenden Taktflanke ausgeben
    always @(posedge clk)
        $strobe("t=%0d ns  rst=%b en=%b q=%0d", $time, rst, en, q);
endmodule
