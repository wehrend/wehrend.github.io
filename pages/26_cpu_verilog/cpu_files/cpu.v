// Single-cycle RISC-V CPU from part 2 (chapters 16 and 17).
// Instructions: add, sub, and, or, addi, lw, sw, beq, bne.
// Every instruction is executed in one clock cycle: everything between two
// rising edges is combinational logic, only PC, register file and data memory store values.
module cpu #(
    parameter PROGRAM = "program.hex"
) (
    input  wire clk,
    input  wire rst
);
    // ---- instruction fetch -------------------------------------------------
    reg  [31:0] pc;
    wire [31:0] inst;
    wire [31:0] pc_plus4 = pc + 4;               // first adder

    instr_mem #(.PROGRAM(PROGRAM)) imem (.addr(pc), .inst(inst));

    // ---- decode: the fields of the instruction ----------------------------
    wire [6:0] opcode = inst[6:0];
    wire [4:0] rd     = inst[11:7];
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rs1    = inst[19:15];
    wire [4:0] rs2    = inst[24:20];

    // ---- control ------------------------------------------------------------
    wire       reg_write, alu_src, mem_to_reg, mem_read, mem_write, branch;
    wire [1:0] alu_op;
    wire [3:0] alu_ctrl;

    control ctl (
        .opcode(opcode), .reg_write(reg_write), .alu_src(alu_src),
        .mem_to_reg(mem_to_reg), .mem_read(mem_read), .mem_write(mem_write),
        .branch(branch), .alu_op(alu_op)
    );
    alu_control actl (.alu_op(alu_op), .funct7_5(inst[30]), .funct3(funct3), .alu_ctrl(alu_ctrl));

    // ---- register file and immediate ---------------------------------------
    wire [31:0] rd1, rd2, imm, write_data;

    regfile rf (
        .clk(clk), .rs1(rs1), .rs2(rs2), .rd1(rd1), .rd2(rd2),
        .we(reg_write), .rd(rd), .wd(write_data)
    );
    imm_gen ig (.inst(inst), .imm(imm));

    // ---- execute -------------------------------------------------------------
    wire [31:0] alu_b = alu_src ? imm : rd2;     // multiplexer in front of the ALU
    wire [31:0] alu_result;
    wire        zero, overflow;

    alu #(.N(32)) alu (
        .a(rd1), .b(alu_b), .ctrl(alu_ctrl),
        .result(alu_result), .zero(zero), .overflow(overflow)
    );

    // ---- memory access ---------------------------------------------------------
    wire [31:0] mem_data;

    data_mem dmem (
        .clk(clk), .addr(alu_result), .mem_read(mem_read), .mem_write(mem_write),
        .wd(rd2), .rd(mem_data)
    );

    // ---- write back ------------------------------------------------------------
    assign write_data = mem_to_reg ? mem_data : alu_result;   // multiplexer behind the memory

    // ---- next PC ---------------------------------------------------------------
    wire [31:0] branch_target = pc + imm;                     // second adder
    wire        pc_src = branch & (zero ^ inst[12]);          // inst[12] = 1 for bne
    wire [31:0] pc_next = pc_src ? branch_target : pc_plus4;  // multiplexer in front of the PC

    always @(posedge clk)
        if (rst) pc <= 0;
        else     pc <= pc_next;
endmodule
