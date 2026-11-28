`timescale 1ns / 1ps

module seq_multiplier_tb;
    reg         clk = 0;
    reg         rst = 1;
    reg         start = 0;
    reg  [7:0]  a = 0, b = 0;
    wire [15:0] p;
    wire        busy, done;
    integer i, j, errors = 0, tests = 0;

    seq_multiplier #(.N(8)) dut (
        .clk(clk), .rst(rst), .start(start), .a(a), .b(b),
        .p(p), .busy(busy), .done(done)
    );

    // for the waveform: the two halves of the product register
    wire [7:0] upper = dut.prod[15:8];    // running sum
    wire [7:0] lower = dut.prod[7:0];     // remaining multiplier bits (and the finished product bits)

    // clock: period 10 ns
    always #5 clk = ~clk;

    // start one multiplication and wait until it is done
    task multiply(input [7:0] x, input [7:0] y);
        begin
            @(negedge clk);           // change inputs away from the rising edge
            a = x; b = y; start = 1;
            @(negedge clk);
            start = 0;
            @(posedge done);
            @(negedge clk);
            tests = tests + 1;
            if (p !== x * y) begin
                errors = errors + 1;
                $display("ERROR: %0d * %0d = %0d, expected %0d", x, y, p, x * y);
            end
        end
    endtask

    initial begin
        $dumpfile("seq_multiplier.vcd");
        $dumpvars(0, seq_multiplier_tb);
        #12 rst = 0;

        multiply(13, 11);
        $display("t=%0d ns  13 * 11 = %0d", $time, p);

        #20 $dumpoff;                 // the exhaustive test would make the file huge
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1)
                multiply(i, j);

        if (errors == 0) $display("PASSED: %0d products correct", tests);
        else             $display("FAILED: %0d of %0d", errors, tests);
        $finish;
    end
endmodule
