`timescale 1ns / 1ps

module full_adder_tb;
    reg  a, b, cin;
    wire sum, cout;
    integer i;
    integer errors = 0;

    full_adder dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i;
            #10;
            // reference model: the sum of three bits is a 2-bit number
            if ({cout, sum} !== a + b + cin) begin
                $display("ERROR: a=%b b=%b cin=%b -> got %b%b", a, b, cin, cout, sum);
                errors = errors + 1;
            end
        end
        if (errors == 0) $display("PASSED: all 8 combinations correct");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
