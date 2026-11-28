`timescale 1ns / 1ps

module parity8_tb;
    reg  [7:0] d;
    wire       p;
    integer i;
    integer errors = 0;

    parity8 dut (.d(d), .p(p));

    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            d = i;
            #1;
            // reference model: the reduction operator ^ XORs all bits
            if (p !== ^d) errors = errors + 1;
        end
        if (errors == 0) $display("PASSED: all 256 values correct");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
