// Instruction memory: 64 words, read-only, loaded from a hex file at simulation start.
// The address is a byte address; since every instruction is 4 bytes long,
// the lowest two bits are always 0 and are not used.
module instr_mem #(
    parameter PROGRAM = "program.hex"
) (
    input  wire [31:0] addr,
    output wire [31:0] inst
);
    reg [31:0] mem [0:63];

    initial $readmemh(PROGRAM, mem);

    assign inst = mem[addr[7:2]];
endmodule
