// RISC-V register file: 32 registers of 32 bits,
// two read ports (combinational) and one write port (on the rising clock edge).
// Register x0 is hard-wired to 0: reading it always returns 0, writing it has no effect.
module regfile (
    input  wire        clk,
    input  wire [4:0]  rs1,         // read port 1
    input  wire [4:0]  rs2,         // read port 2
    output wire [31:0] rd1,
    output wire [31:0] rd2,
    input  wire        we,          // RegWrite
    input  wire [4:0]  rd,          // write port
    input  wire [31:0] wd
);
    reg [31:0] regs [0:31];

    assign rd1 = (rs1 == 0) ? 32'd0 : regs[rs1];
    assign rd2 = (rs2 == 0) ? 32'd0 : regs[rs2];

    always @(posedge clk)
        if (we && rd != 0)
            regs[rd] <= wd;
endmodule
