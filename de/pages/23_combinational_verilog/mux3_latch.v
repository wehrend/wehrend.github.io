// FALSCH: 3-zu-1-Multiplexer - der Fall sel = 2'b11 fehlt
module mux3 (
    input  wire [1:0] sel,
    input  wire [7:0] a, b, c,
    output reg  [7:0] y
);
    always @(*) begin
        case (sel)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
        endcase
    end
endmodule
