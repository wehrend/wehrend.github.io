`timescale 1ns / 1ps

// Tests the three single-purpose shifters and the combined shifter against the Verilog operators.
module shifters_tb;
    reg  [7:0] a;
    reg  [2:0] shamt;
    wire [7:0] y_sll, y_srl, y_sra;
    wire [7:0] all_sll, all_srl, all_sra;
    reg  [7:0] exp_sll, exp_srl, exp_sra;
    integer i, j, errors = 0;

    shifter_sll u_sll (.a(a), .shamt(shamt), .y(y_sll));
    shifter_srl u_srl (.a(a), .shamt(shamt), .y(y_srl));
    shifter_sra u_sra (.a(a), .shamt(shamt), .y(y_sra));

    // the combined shifter, once for every operation
    shifter_all u_all_sll (.a(a), .shamt(shamt), .op(2'b00), .y(all_sll));
    shifter_all u_all_srl (.a(a), .shamt(shamt), .op(2'b01), .y(all_srl));
    shifter_all u_all_sra (.a(a), .shamt(shamt), .op(2'b11), .y(all_sra));

    initial begin
        a = 8'b1001_0110; shamt = 3; #1;
        $display("a = %b, shamt = 3:  sll = %b  srl = %b  sra = %b", a, y_sll, y_srl, y_sra);

        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 8; j = j + 1) begin
                a = i; shamt = j; #1;
                // compute the expected values first: inside a comparison with an unsigned
                // signal, $signed(a) >>> shamt would be evaluated unsigned (and shift in zeros)
                exp_sll = a << shamt;
                exp_srl = a >> shamt;
                exp_sra = $signed(a) >>> shamt;
                if (y_sll !== exp_sll || y_srl !== exp_srl || y_sra !== exp_sra
                    || all_sll !== exp_sll || all_srl !== exp_srl || all_sra !== exp_sra) begin
                    errors = errors + 1;
                    $display("ERROR: a=%b shamt=%0d", a, shamt);
                end
            end
        if (errors == 0) $display("PASSED: all 2048 combinations correct for sll, srl, sra and the combined shifter");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
