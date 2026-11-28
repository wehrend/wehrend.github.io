// WRONG: 3-to-1 multiplexer - the case for sel = 2'b11 is missing
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
