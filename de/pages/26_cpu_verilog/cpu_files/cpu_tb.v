`timescale 1ns / 1ps

// Runs the example program and prints one line per clock cycle,
// like the table in chapter 17. At the end, the results are checked.
// (Icarus warns that program.hex has fewer than 64 words: that is fine,
//  the rest of the instruction memory is simply never used.)
module cpu_tb;
    reg clk = 0;
    reg rst = 1;
    integer cycle = 0, errors = 0, writes = 0;

    cpu #(.PROGRAM("program.hex")) dut (.clk(clk), .rst(rst));

    // short names for the waveform: lowest byte of the PC, the registers and memory[4]
    wire [7:0]  pc    = dut.pc[7:0];
    wire [31:0] x1    = dut.rf.regs[1];
    wire [31:0] x3    = dut.rf.regs[3];
    wire [31:0] mem4  = dut.dmem.mem[1];      // address 4 = word 1

    // clock: period 10 ns
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_tb);
        #12 rst = 0;
        #350;                                 // 35 clock cycles

        // check the results
        if (x1 !== 10)   begin errors = errors + 1; $display("ERROR: x1 = %0d", x1); end
        if (x3 !== 10)   begin errors = errors + 1; $display("ERROR: x3 = %0d", x3); end
        if (mem4 !== 10) begin errors = errors + 1; $display("ERROR: memory[4] = %0d", mem4); end
        if (dut.pc !== 32'h18) begin errors = errors + 1; $display("ERROR: PC = %h", dut.pc); end
        if (writes !== 10) begin errors = errors + 1; $display("ERROR: %0d writes to memory", writes); end

        if (errors == 0) $display("PASSED: counted to 10 in 33 clock cycles, CPU loops at 0x18");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end

    // one line per clock cycle, like the table in chapter 17.
    // At the rising edge, the non-blocking assignments have not happened yet:
    // we still see the instruction of this cycle and the values that are about to be stored.
    always @(posedge clk)
        if (!rst) begin
            cycle = cycle + 1;
            $write("clock %2d  PC=0x%02h  inst=%h  ", cycle, dut.pc[7:0], dut.inst);
            if (dut.reg_write) $write("x%0d = %0d", dut.rd, $signed(dut.write_data));
            if (dut.mem_write) $write("memory[%0d] = %0d", dut.alu_result, dut.rd2);
            if (dut.branch)    $write("Zero=%b PCSrc=%b", dut.zero, dut.pc_src);
            $display("  ->  next PC=0x%02h", dut.pc_next[7:0]);
            if (dut.mem_write) begin
                writes = writes + 1;
                if (dut.rd2 !== writes) begin
                    errors = errors + 1;
                    $display("ERROR: write %0d stores %0d", writes, dut.rd2);
                end
            end
        end
endmodule
