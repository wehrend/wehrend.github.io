// D-latch: transparent while en = 1, holds its value while en = 0
module d_latch (
    input  wire en,
    input  wire d,
    output reg  q
);
    always @(*) begin
        if (en)
            q <= d;
    end
endmodule
