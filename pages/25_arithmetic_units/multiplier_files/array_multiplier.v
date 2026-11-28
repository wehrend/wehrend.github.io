// N x N array multiplier (unsigned), purely combinational.
// Like long multiplication on paper: every bit of b selects a partial product
// (a AND b[i]), and one ripple-carry adder per row adds it to the running sum.
module array_multiplier #(
    parameter N = 4
) (
    input  wire [N-1:0]   a,
    input  wire [N-1:0]   b,
    output wire [2*N-1:0] p
);
    // partial products: row i = a AND b[i]
    wire [N-1:0] pp [0:N-1];
    // running sum after each row (upper N bits, the lowest bit is already final)
    wire [N-1:0] acc [0:N-1];

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : partial
            assign pp[i] = a & {N{b[i]}};
        end

        // row 0: nothing to add yet, bit 0 of the product is final
        assign p[0]   = pp[0][0];
        assign acc[0] = {1'b0, pp[0][N-1:1]};

        // rows 1 .. N-1: one adder per row
        for (i = 1; i < N; i = i + 1) begin : row
            wire [N-1:0] sum;
            wire         cout;
            ripple_adder #(.N(N)) add (
                .a(acc[i-1]), .b(pp[i]), .cin(1'b0),
                .sum(sum), .cout(cout)
            );
            assign p[i]   = sum[0];                 // lowest bit is final
            assign acc[i] = {cout, sum[N-1:1]};     // the rest moves on to the next row
        end
    endgenerate

    // after the last row, the remaining bits are the upper half of the product
    assign p[2*N-1:N] = acc[N-1];
endmodule
