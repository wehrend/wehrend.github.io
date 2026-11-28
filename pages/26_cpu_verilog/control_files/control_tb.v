`timescale 1ns / 1ps

// Feeds the instructions of our example program (chapter 17) into
// control, ALU control and immediate generator, and compares with the tables.
module control_tb;
    reg  [31:0] inst;
    wire        reg_write, alu_src, mem_to_reg, mem_read, mem_write, branch;
    wire [1:0]  alu_op;
    wire [3:0]  alu_ctrl;
    wire [31:0] imm;
    integer errors = 0;

    control ctl (
        .opcode(inst[6:0]), .reg_write(reg_write), .alu_src(alu_src),
        .mem_to_reg(mem_to_reg), .mem_read(mem_read), .mem_write(mem_write),
        .branch(branch), .alu_op(alu_op)
    );
    alu_control actl (.alu_op(alu_op), .funct7_5(inst[30]), .funct3(inst[14:12]), .alu_ctrl(alu_ctrl));
    imm_gen ig (.inst(inst), .imm(imm));

    // expected: RegWrite ALUSrc MemToReg MemRead MemWrite Branch ALUOp(2) ALUctrl(4) and the immediate
    // (for sw and bne/beq, MemToReg is "don't care"; our logic gives 0.
    //  R-type instructions have no immediate, the value of imm does not matter there)
    task check(input [31:0] i, input [127:0] name, input [7:0] exp_signals, input [3:0] exp_ctrl, input integer exp_imm);
        begin
            inst = i; #1;
            $display("%-16s RegWrite=%b ALUSrc=%b MemToReg=%b MemRead=%b MemWrite=%b Branch=%b ALUOp=%b ALUctrl=%b imm=%0d",
                     name, reg_write, alu_src, mem_to_reg, mem_read, mem_write, branch, alu_op, alu_ctrl, $signed(imm));
            if ({reg_write, alu_src, mem_to_reg, mem_read, mem_write, branch, alu_op} !== exp_signals
                || alu_ctrl !== exp_ctrl
                || ((alu_src || branch) && $signed(imm) !== exp_imm)) begin
                errors = errors + 1;
                $display("  ERROR");
            end
        end
    endtask

    initial begin
        //                                      RW AS MR MRd MW Br ALUOp
        check(32'h00a00193, "addi x3,x0,10",   8'b11_0_0_0_0_00, 4'b0010, 10);
        check(32'h002080b3, "add x1,x1,x2",    8'b10_0_0_0_0_10, 4'b0010, 0);
        check(32'h40208133, "sub x2,x1,x2",    8'b10_0_0_0_0_10, 4'b0110, 1026);
        check(32'h0020f0b3, "and x1,x1,x2",    8'b10_0_0_0_0_10, 4'b0000, 2);
        check(32'h0020e0b3, "or x1,x1,x2",     8'b10_0_0_0_0_10, 4'b0001, 2);
        check(32'h00832283, "lw x5,8(x6)",     8'b11_1_1_0_0_00, 4'b0010, 8);
        check(32'h00102223, "sw x1,4(x0)",     8'b01_0_0_1_0_00, 4'b0010, 4);
        check(32'hfe309ce3, "bne x1,x3,-8",    8'b00_0_0_0_1_01, 4'b0110, -8);
        check(32'h00000063, "beq x0,x0,0",     8'b00_0_0_0_1_01, 4'b0110, 0);
        // the addi trap from chapter 17: bit 30 is 1, but ALUOp = 00 still selects add
        check(32'hfff28293, "addi x5,x5,-1",   8'b11_0_0_0_0_00, 4'b0010, -1);

        if (errors == 0) $display("PASSED");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
