// Data memory: 64 words. Reading is combinational (MemRead),
// writing happens on the rising clock edge (MemWrite).
module data_mem (
    input  wire        clk,
    input  wire [31:0] addr,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] wd,
    output wire [31:0] rd
);
    reg [31:0] mem [0:63];

    integer i;
    initial for (i = 0; i < 64; i = i + 1) mem[i] = 0;

    assign rd = mem_read ? mem[addr[7:2]] : 32'd0;

    always @(posedge clk)
        if (mem_write)
            mem[addr[7:2]] <= wd;
endmodule
