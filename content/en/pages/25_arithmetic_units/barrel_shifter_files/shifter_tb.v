`timescale 1ns / 1ps

// Tests all three stages at once against the Verilog operators.
module shifter_tb;
    reg  [7:0] a;
    reg  [2:0] shamt;
    wire [7:0] y1, y2_srl, y2_sra, y3_sll, y3_srl, y3_sra;
    reg  [7:0] exp_sll, exp_srl, exp_sra;
    integer i, j, errors = 0;

    shifter1 st1 (.a(a), .shamt(shamt), .y(y1));
    shifter2 st2a (.a(a), .shamt(shamt), .arith(1'b0), .y(y2_srl));
    shifter2 st2b (.a(a), .shamt(shamt), .arith(1'b1), .y(y2_sra));
    shifter3 st3a (.a(a), .shamt(shamt), .op(2'b00), .y(y3_sll));
    shifter3 st3b (.a(a), .shamt(shamt), .op(2'b01), .y(y3_srl));
    shifter3 st3c (.a(a), .shamt(shamt), .op(2'b11), .y(y3_sra));

    initial begin
        a = 8'b1001_0110; shamt = 3; #1;
        $display("a = %b, shamt = 3:  sll = %b  srl = %b  sra = %b", a, y3_sll, y3_srl, y3_sra);

        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 8; j = j + 1) begin
                a = i; shamt = j; #1;
                // compute the expected values first: inside a comparison with an unsigned
                // signal, $signed(a) >>> shamt would be evaluated unsigned (and shift in zeros)
                exp_sll = a << shamt;
                exp_srl = a >> shamt;
                exp_sra = $signed(a) >>> shamt;
                if (y1 !== exp_srl || y2_srl !== exp_srl || y2_sra !== exp_sra
                    || y3_sll !== exp_sll || y3_srl !== exp_srl || y3_sra !== exp_sra) begin
                    errors = errors + 1;
                    $display("ERROR: a=%b shamt=%0d", a, shamt);
                end
            end
        if (errors == 0) $display("PASSED: all stages correct");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
