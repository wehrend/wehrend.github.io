// sll: shift left logical, 8 bit. Zeros are shifted in from the right.
module shifter_sll (
    input  wire [7:0] a,
    input  wire [2:0] shamt,
    output wire [7:0] y
);
    wire [7:0] s1, s2;

    assign s1 = shamt[0] ? {a[6:0],  1'b0}    : a;    // shift by 1 or not
    assign s2 = shamt[1] ? {s1[5:0], 2'b00}   : s1;   // shift by 2 or not
    assign y  = shamt[2] ? {s2[3:0], 4'b0000} : s2;   // shift by 4 or not
endmodule
