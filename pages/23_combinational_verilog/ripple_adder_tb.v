`timescale 1ns / 1ps

module ripple_adder_tb;
    localparam N = 8;

    reg  [N-1:0] a, b;
    reg          cin;
    wire [N-1:0] sum;
    wire         cout;
    integer i, j, k;
    integer errors = 0;

    ripple_adder #(.N(N)) dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        // exhaustive test: 256 * 256 * 2 = 131072 combinations
        for (i = 0; i < (1 << N); i = i + 1)
            for (j = 0; j < (1 << N); j = j + 1)
                for (k = 0; k < 2; k = k + 1) begin
                    a = i; b = j; cin = k;
                    #1;
                    if ({cout, sum} !== a + b + cin) begin
                        if (errors < 10)
                            $display("ERROR: %0d + %0d + %0d = %0d", a, b, cin, {cout, sum});
                        errors = errors + 1;
                    end
                end
        if (errors == 0) $display("PASSED: all %0d combinations correct", (1 << (2*N)) * 2);
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
