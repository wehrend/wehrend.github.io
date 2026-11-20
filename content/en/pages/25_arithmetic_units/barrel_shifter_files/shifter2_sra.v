// Stage 2: srl and sra. The only difference: what is shifted in from the left.
module shifter2 (
    input  wire [7:0] a,
    input  wire [2:0] shamt,
    input  wire       arith,        // 0: srl, 1: sra
    output wire [7:0] y
);
    wire fill = arith & a[7];       // sra: copy of the sign bit, srl: 0
    wire [7:0] s1, s2;

    assign s1 = shamt[0] ? {fill,          a[7:1]}  : a;
    assign s2 = shamt[1] ? {{2{fill}},     s1[7:2]} : s1;
    assign y  = shamt[2] ? {{4{fill}},     s2[7:4]} : s2;
endmodule
