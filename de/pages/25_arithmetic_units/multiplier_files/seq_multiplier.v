// Sequential shift-and-add multiplier (unsigned), one bit per clock cycle.
// Needs only one N-bit adder instead of N-1 adders, but takes N clock cycles.
//
// The product register holds the upper half (running sum) and the lower half
// (the remaining multiplier bits) at the same time: in every cycle
//   1. if the lowest bit is 1, the multiplicand is added to the upper half,
//   2. the whole register is shifted right by one bit.
// After N cycles the register contains the complete product.
module seq_multiplier #(
    parameter N = 8
) (
    input  wire           clk,
    input  wire           rst,
    input  wire           start,    // one clock cycle high: start a multiplication
    input  wire [N-1:0]   a,        // multiplicand
    input  wire [N-1:0]   b,        // multiplier
    output wire [2*N-1:0] p,        // product
    output reg            busy,
    output reg            done      // high when p is valid, until the next start
);
    reg [N-1:0] mcand;                  // multiplicand, stays constant
    reg [2*N:0] prod;                   // one extra bit for the carry of the addition
    reg [$clog2(N+1)-1:0] count;        // remaining steps

    wire [N:0] upper = prod[2*N:N] + (prod[0] ? {1'b0, mcand} : {(N+1){1'b0}});

    always @(posedge clk) begin
        if (rst) begin
            busy  <= 0;
            done  <= 0;
            count <= 0;
            prod  <= 0;
            mcand <= 0;
        end else if (start && !busy) begin
            mcand <= a;
            prod  <= {{(N+1){1'b0}}, b};   // upper half 0, lower half = multiplier
            count <= N;
            busy  <= 1;
            done  <= 0;
        end else if (busy) begin
            prod  <= {upper, prod[N-1:0]} >> 1;   // add, then shift right
            count <= count - 1;
            if (count == 1) begin
                busy <= 0;
                done <= 1;
            end
        end
    end

    assign p = prod[2*N-1:0];
endmodule
