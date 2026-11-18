// RIGHT: non-blocking assignments (<=) in a clocked block
module shift_reg (
    input  wire       clk,
    input  wire       d,
    output reg  [3:0] q
);
    always @(posedge clk) begin
        q[0] <= d;
        q[1] <= q[0];
        q[2] <= q[1];
        q[3] <= q[2];
    end
endmodule
