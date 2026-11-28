// Sequential restoring divider (unsigned), one quotient bit per clock cycle.
// Works like long division on paper: in every cycle, the next bit of the
// dividend is shifted into the remainder, and the divisor is subtracted if it fits.
//   - fits (no borrow):  remainder = difference, quotient bit = 1
//   - does not fit:      remainder stays (is "restored"), quotient bit = 0
// After N cycles: quotient = dividend / divisor, remainder = dividend % divisor.
//
// Division by zero needs no special case: the divisor 0 always "fits",
// so the quotient becomes all ones and the remainder equals the dividend.
// This is exactly what RISC-V specifies for divu/remu.
module seq_divider #(
    parameter N = 8
) (
    input  wire         clk,
    input  wire         rst,
    input  wire         start,      // one clock cycle high: start a division
    input  wire [N-1:0] dividend,
    input  wire [N-1:0] divisor,
    output reg  [N-1:0] quotient,
    output reg  [N-1:0] remainder,
    output reg          busy,
    output reg          done        // high when the results are valid, until the next start
);
    reg [N-1:0] dsor;                   // divisor, stays constant
    reg [$clog2(N+1)-1:0] count;        // remaining steps

    // shift the next dividend bit (MSB of the quotient register) into the remainder
    wire [N:0] shifted = {remainder, quotient[N-1]};
    wire [N:0] diff    = shifted - {1'b0, dsor};
    wire       fits    = !diff[N];      // no borrow: divisor fits

    always @(posedge clk) begin
        if (rst) begin
            busy      <= 0;
            done      <= 0;
            count     <= 0;
            quotient  <= 0;
            remainder <= 0;
            dsor      <= 0;
        end else if (start && !busy) begin
            dsor      <= divisor;
            quotient  <= dividend;      // the quotient register starts with the dividend
            remainder <= 0;
            count     <= N;
            busy      <= 1;
            done      <= 0;
        end else if (busy) begin
            remainder <= fits ? diff[N-1:0] : shifted[N-1:0];
            quotient  <= {quotient[N-2:0], fits};
            count     <= count - 1;
            if (count == 1) begin
                busy <= 0;
                done <= 1;
            end
        end
    end
endmodule
