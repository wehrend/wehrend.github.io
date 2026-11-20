// D-flip-flop: takes over d only at the rising edge of clk
module d_ff (
    input  wire clk,
    input  wire d,
    output reg  q
);
    always @(posedge clk) begin
        q <= d;
    end
endmodule
