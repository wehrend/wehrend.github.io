`timescale 1ns / 1ps

module full_adder_tb;
    // Signale, die die Eingänge des DUT treiben
    reg  a, b, cin;
    // Signale, die die Ausgänge des DUT beobachten
    wire sum, cout;

    // das zu testende Bauteil (Device Under Test, DUT)
    full_adder dut (
        .a(a), .b(b), .cin(cin),
        .sum(sum), .cout(cout)
    );

    integer i;
    initial begin
        $dumpfile("full_adder.vcd");
        $dumpvars(0, full_adder_tb);

        // alle 8 Eingangskombinationen anlegen
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i;
            #10;
            $display("a=%b b=%b cin=%b -> cout=%b sum=%b", a, b, cin, cout, sum);
        end
        $finish;
    end
endmodule
