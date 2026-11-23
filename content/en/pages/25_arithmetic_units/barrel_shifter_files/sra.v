// sra: shift right arithmetic, 8 bit. Copies of the sign bit a[7] are shifted in from the left.
module shifter_sra (
    input  wire [7:0] a,
    input  wire [2:0] shamt,
    output wire [7:0] y
);
    wire [7:0] s1, s2;

    assign s1 = shamt[0] ? {a[7],      a[7:1]}  : a;    // shift by 1 or not
    assign s2 = shamt[1] ? {{2{a[7]}}, s1[7:2]} : s1;   // shift by 2 or not
    assign y  = shamt[2] ? {{4{a[7]}}, s2[7:4]} : s2;   // shift by 4 or not
endmodule
