`timescale 1ns / 1ps

// Tests all seven ALU operations with interesting and random values
// against the Verilog operators.
module alu_tb;
    reg  [31:0] a, b;
    reg  [3:0]  ctrl;
    wire [31:0] result;
    wire        zero, overflow;
    reg  [31:0] expected;
    integer i, k, errors = 0, tests = 0;

    alu #(.N(32)) dut (.a(a), .b(b), .ctrl(ctrl), .result(result), .zero(zero), .overflow(overflow));

    reg [3:0]  ops    [0:6];
    reg [31:0] values [0:7];

    task check;
        begin
            #1;
            case (ctrl)
                4'b0000: expected = a & b;
                4'b0001: expected = a | b;
                4'b0010: expected = a + b;
                4'b0110: expected = a - b;
                4'b0111: expected = ($signed(a) < $signed(b)) ? 1 : 0;
                4'b1100: expected = ~(a | b);
                4'b1101: expected = ~(a & b);
            endcase
            tests = tests + 1;
            if (result !== expected || zero !== (expected == 0)) begin
                errors = errors + 1;
                $display("ERROR: ctrl=%b a=%h b=%h result=%h expected=%h", ctrl, a, b, result, expected);
            end
        end
    endtask

    initial begin
        ops[0] = 4'b0000; ops[1] = 4'b0001; ops[2] = 4'b0010; ops[3] = 4'b0110;
        ops[4] = 4'b0111; ops[5] = 4'b1100; ops[6] = 4'b1101;
        // values at the edges: 0, 1, -1, largest and smallest number, ...
        values[0] = 0;            values[1] = 1;            values[2] = 32'hFFFFFFFF;
        values[3] = 32'h7FFFFFFF; values[4] = 32'h80000000; values[5] = 10;
        values[6] = 32'hFFFFFFF7; values[7] = 32'h12345678;

        // the operations of our example program
        ctrl = 4'b0010; a = 1;  b = 1;  check; $display("add: 1 + 1   = %0d", $signed(result));
        ctrl = 4'b0110; a = 1;  b = 10; check; $display("sub: 1 - 10  = %0d, zero = %b", $signed(result), zero);
        ctrl = 4'b0110; a = 10; b = 10; check; $display("sub: 10 - 10 = %0d, zero = %b", $signed(result), zero);
        // slt with overflow: -2^31 < 1, although -2^31 - 1 has a positive sign bit
        ctrl = 4'b0111; a = 32'h80000000; b = 1; check;
        $display("slt: %0d < 1 = %0d (overflow = %b)", $signed(a), result, overflow);

        for (k = 0; k < 7; k = k + 1) begin
            ctrl = ops[k];
            for (i = 0; i < 64; i = i + 1) begin
                a = values[i / 8]; b = values[i % 8]; check;
            end
            for (i = 0; i < 1000; i = i + 1) begin
                a = $random; b = $random; check;
            end
        end

        if (errors == 0) $display("PASSED: %0d tests", tests);
        else             $display("FAILED: %0d of %0d tests", errors, tests);
        $finish;
    end
endmodule
