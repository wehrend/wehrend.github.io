// Parität über 8 Bit: p = 1, wenn eine ungerade Anzahl Bits gesetzt ist
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
