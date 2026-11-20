// up/down counter from 0 to MOD-1 with synchronous reset and enable
module counter_updown #(
    parameter WIDTH = 4,
    parameter MOD   = 10
) (
    input  wire             clk,
    input  wire             rst,
    input  wire             en,
    input  wire             up,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk) begin
        if (rst)
            q <= 0;
        else if (en) begin
            if (up)
                q <= (q == MOD - 1) ? 0 : q + 1;
            else
                q <= (q == 0) ? MOD - 1 : q - 1;
        end
    end
endmodule
