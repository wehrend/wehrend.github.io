// Immediate generator (chapter 17): extracts the constant from the instruction
// and sign-extends it to 32 bits. The sign bit is always inst[31].
module imm_gen (
    input  wire [31:0] inst,
    output reg  [31:0] imm
);
    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case (opcode)
            7'b0100011:                                          // S-type: sw
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            7'b1100011:                                          // B-type: beq, bne
                imm = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            default:                                             // I-type: lw, addi
                imm = {{20{inst[31]}}, inst[31:20]};
        endcase
    end
endmodule
