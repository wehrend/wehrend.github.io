`timescale 1ns / 1ps

module seven_seg_tb;
    reg  [3:0] value;
    wire [6:0] seg;
    integer i;

    seven_seg dut (.value(value), .seg(seg));

    initial begin
        $dumpfile("seven_seg.vcd");
        $dumpvars(0, seven_seg_tb);
        for (i = 0; i < 16; i = i + 1) begin
            value = i;
            #10;
            $display("value=%h  seg(gfedcba)=%b", value, seg);
        end
        $finish;
    end
endmodule
