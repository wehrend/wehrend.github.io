`timescale 1ns / 1ps

module regfile_tb;
    reg         clk = 0;
    reg  [4:0]  rs1 = 0, rs2 = 0, rd = 0;
    reg         we = 0;
    reg  [31:0] wd = 0;
    wire [31:0] rd1, rd2;
    integer i, errors = 0;

    regfile dut (.clk(clk), .rs1(rs1), .rs2(rs2), .rd1(rd1), .rd2(rd2),
                 .we(we), .rd(rd), .wd(wd));

    // clock: period 10 ns
    always #5 clk = ~clk;

    initial begin
        $dumpfile("regfile.vcd");
        $dumpvars(0, regfile_tb);

        // write i * 3 into register i, and 0xDEAD into x0 (which must ignore it)
        for (i = 0; i < 32; i = i + 1) begin
            @(negedge clk);
            we = 1; rd = i; wd = (i == 0) ? 32'hDEAD : i * 3;
        end
        @(negedge clk);
        we = 0;

        // read all registers on both ports
        for (i = 0; i < 32; i = i + 1) begin
            rs1 = i; rs2 = 31 - i; #1;
            if (rd1 !== (i == 0 ? 0 : i * 3) || rd2 !== (i == 31 ? 0 : (31 - i) * 3)) begin
                errors = errors + 1;
                $display("ERROR: x%0d = %0d, x%0d = %0d", rs1, rd1, rs2, rd2);
            end
        end

        // write without we: nothing must change
        @(negedge clk);
        we = 0; rd = 5; wd = 999;
        @(negedge clk);
        rs1 = 5; #1;
        if (rd1 !== 15) begin
            errors = errors + 1;
            $display("ERROR: x5 changed without we: %0d", rd1);
        end

        rs1 = 0; rs2 = 7; #1;
        $display("x0 = %0d (0xDEAD was written, x0 stays 0), x7 = %0d", rd1, rd2);
        if (errors == 0) $display("PASSED");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
