`timescale 1ns / 1ps

module seq_divider_tb;
    reg        clk = 0;
    reg        rst = 1;
    reg        start = 0;
    reg  [7:0] dividend = 0, divisor = 0;
    wire [7:0] quotient, remainder;
    wire       busy, done;
    reg  [7:0] exp_q, exp_r;
    integer i, j, errors = 0, tests = 0;

    seq_divider #(.N(8)) dut (
        .clk(clk), .rst(rst), .start(start),
        .dividend(dividend), .divisor(divisor),
        .quotient(quotient), .remainder(remainder),
        .busy(busy), .done(done)
    );

    // clock: period 10 ns
    always #5 clk = ~clk;

    // start one division and wait until it is done
    task divide(input [7:0] x, input [7:0] y);
        begin
            @(negedge clk);
            dividend = x; divisor = y; start = 1;
            @(negedge clk);
            start = 0;
            @(posedge done);
            @(negedge clk);
            // division by zero: RISC-V defines quotient = all ones, remainder = dividend
            exp_q = (y == 0) ? 8'hFF : x / y;
            exp_r = (y == 0) ? x     : x % y;
            tests = tests + 1;
            if (quotient !== exp_q || remainder !== exp_r) begin
                errors = errors + 1;
                $display("ERROR: %0d / %0d = %0d rest %0d, expected %0d rest %0d",
                         x, y, quotient, remainder, exp_q, exp_r);
            end
        end
    endtask

    initial begin
        $dumpfile("seq_divider.vcd");
        $dumpvars(0, seq_divider_tb);
        #12 rst = 0;

        divide(100, 7);
        $display("t=%0d ns  100 / 7 = %0d rest %0d", $time, quotient, remainder);
        divide(42, 0);
        $display("t=%0d ns  42 / 0 = %0d rest %0d", $time, quotient, remainder);

        $dumpoff;                     // the exhaustive test would make the file huge
        for (i = 0; i < 256; i = i + 1)
            for (j = 0; j < 256; j = j + 1)
                divide(i, j);

        if (errors == 0) $display("PASSED: %0d divisions correct", tests);
        else             $display("FAILED: %0d of %0d", errors, tests);
        $finish;
    end
endmodule
