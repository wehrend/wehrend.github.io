// Main control unit of the single-cycle CPU (chapter 17), pure combinational logic.
// A decoder recognizes the opcode and activates exactly one line,
// every control signal is an OR of the lines in which it is 1.
module control (
    input  wire [6:0] opcode,
    output wire       reg_write,
    output wire       alu_src,
    output wire       mem_to_reg,
    output wire       mem_read,
    output wire       mem_write,
    output wire       branch,
    output wire [1:0] alu_op
);
    // decoder: one line per instruction type
    wire r   = (opcode == 7'b0110011);   // add, sub, and, or
    wire lw  = (opcode == 7'b0000011);
    wire sw  = (opcode == 7'b0100011);
    wire br  = (opcode == 7'b1100011);   // beq, bne
    wire imm = (opcode == 7'b0010011);   // addi

    // the equations from chapter 17, including the extension for addi
    assign reg_write  = r | lw | imm;
    assign alu_src    = lw | sw | imm;
    assign mem_to_reg = lw;
    assign mem_read   = lw;
    assign mem_write  = sw;
    assign branch     = br;
    assign alu_op     = {r, br};         // ALUOp1 = R, ALUOp0 = BR
endmodule
