`timescale 1ns / 1ps

module full_adder_tb;
    // signals that drive the inputs of the DUT
    reg  a, b, cin;
    // signals that observe the outputs of the DUT
    wire sum, cout;

    // the device under test (DUT)
    full_adder dut (
        .a(a), .b(b), .cin(cin),
        .sum(sum), .cout(cout)
    );

    integer i;
    initial begin
        $dumpfile("full_adder.vcd");
        $dumpvars(0, full_adder_tb);

        // apply all 8 input combinations
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i;
            #10;
            $display("a=%b b=%b cin=%b -> cout=%b sum=%b", a, b, cin, cout, sum);
        end
        $finish;
    end
endmodule
