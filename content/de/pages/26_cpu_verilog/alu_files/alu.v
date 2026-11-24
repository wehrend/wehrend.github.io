// N-bit ALU: a chain of 1-bit ALU cells, as in chapter 05.
// ctrl = {Ainvert, Binvert, Operation}:
//   0000 and    0001 or    0010 add    0110 sub    0111 slt    1100 nor    1101 nand
module alu #(
    parameter N = 32
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire [3:0]   ctrl,
    output wire [N-1:0] result,
    output wire         zero,
    output wire         overflow
);
    wire ainvert = ctrl[3];
    wire binvert = ctrl[2];
    wire [1:0] operation = ctrl[1:0];

    wire [N:0]   c;        // carry chain
    wire [N-1:0] sum;
    wire         is_less;   // "a < b" for slt

    // subtraction a - b = a + ~b + 1: Binvert also provides the +1 as carry in
    assign c[0] = binvert;

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : slice
            alu_cell u (
                .a(a[i]), .b(b[i]),
                .ainvert(ainvert), .binvert(binvert),
                .cin(c[i]),
                .less(i == 0 ? is_less : 1'b0),   // only bit 0 gets the result of slt
                .operation(operation),
                .result(result[i]), .cout(c[i+1]), .sum(sum[i])
            );
        end
    endgenerate

    // overflow: carry into the sign bit differs from carry out of it
    assign overflow = c[N-1] ^ c[N];
    // slt: the sign of a - b, corrected if the subtraction overflowed
    assign is_less = sum[N-1] ^ overflow;
    // zero: a NOR over all result bits
    assign zero = ~|result;
endmodule
