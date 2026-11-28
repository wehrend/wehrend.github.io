// ALU control (chapter 17): the second decoding stage.
// From the 2-bit ALUOp of the main control and, for R-type instructions,
// from funct7 (only bit 30 of the instruction) and funct3, it generates
// the 4 control bits {Ainvert, Binvert, Operation} of the ALU.
module alu_control (
    input  wire [1:0] alu_op,
    input  wire       funct7_5,       // instruction bit 30
    input  wire [2:0] funct3,
    output reg  [3:0] alu_ctrl
);
    always @(*) begin
        case (alu_op)
            2'b00:   alu_ctrl = 4'b0010;                 // lw, sw, addi: add
            2'b01:   alu_ctrl = 4'b0110;                 // beq, bne: sub
            default: case (funct3)                       // R-type: look at funct
                         3'b000:  alu_ctrl = funct7_5 ? 4'b0110 : 4'b0010;   // sub / add
                         3'b111:  alu_ctrl = 4'b0000;    // and
                         3'b110:  alu_ctrl = 4'b0001;    // or
                         default: alu_ctrl = 4'b0010;
                     endcase
        endcase
    end
endmodule
