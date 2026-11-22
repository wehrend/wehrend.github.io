// Stage 3: sll, srl and sra. A left shift is a right shift of the reversed word.
module shifter3 (
    input  wire [7:0] a,
    input  wire [2:0] shamt,
    input  wire [1:0] op,           // 00: sll, 01: srl, 11: sra
    output wire [7:0] y
);
    wire left = (op == 2'b00);
    wire fill = op[1] & a[7];

    // reverse the bit order: a[0] becomes bit 7, a[7] becomes bit 0
    wire [7:0] a_rev = {a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]};
    wire [7:0] in    = left ? a_rev : a;

    wire [7:0] s1, s2, s3;
    assign s1 = shamt[0] ? {fill,      in[7:1]} : in;
    assign s2 = shamt[1] ? {{2{fill}}, s1[7:2]} : s1;
    assign s3 = shamt[2] ? {{4{fill}}, s2[7:4]} : s2;

    // reverse back after shifting
    wire [7:0] s3_rev = {s3[0], s3[1], s3[2], s3[3], s3[4], s3[5], s3[6], s3[7]};
    assign y = left ? s3_rev : s3;
endmodule
