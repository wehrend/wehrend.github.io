// even parity over 8 bits: p = 1 if an odd number of bits is set
module parity8 (
    input  wire [7:0] d,
    output reg        p
);
    integer i;

    always @(*) begin
        p = 1'b0;
        for (i = 0; i < 8; i = i + 1)
            p = p ^ d[i];
    end
endmodule
