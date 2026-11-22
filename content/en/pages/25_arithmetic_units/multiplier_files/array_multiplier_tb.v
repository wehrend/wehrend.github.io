`timescale 1ns / 1ps

// Exhaustive test of the 4 x 4 array multiplier: all 256 combinations.
module array_multiplier_tb;
    reg  [3:0] a, b;
    wire [7:0] p;
    integer i, j, errors = 0;

    array_multiplier #(.N(4)) dut (.a(a), .b(b), .p(p));

    initial begin
        a = 13; b = 11; #1;
        $display("%0d * %0d = %0d  (%b * %b = %b)", a, b, p, a, b, p);

        for (i = 0; i < 16; i = i + 1)
            for (j = 0; j < 16; j = j + 1) begin
                a = i; b = j; #1;
                if (p !== a * b) begin
                    errors = errors + 1;
                    $display("ERROR: %0d * %0d = %0d, expected %0d", a, b, p, a * b);
                end
            end

        if (errors == 0) $display("PASSED: all 256 products correct");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
