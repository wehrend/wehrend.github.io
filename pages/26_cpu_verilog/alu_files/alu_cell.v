// 1-bit ALU cell from part 1 (chapter 05):
// Ainvert and Binvert invert the inputs, Operation selects the result.
//   Operation = 00: and   01: or   10: sum (add)   11: less (for slt)
module alu_cell (
    input  wire       a,
    input  wire       b,
    input  wire       ainvert,
    input  wire       binvert,
    input  wire       cin,
    input  wire       less,
    input  wire [1:0] operation,
    output reg        result,
    output wire       cout,
    output wire       sum           // needed by the most significant cell for slt
);
    wire aa = a ^ ainvert;          // the XOR as a controllable inverter
    wire bb = b ^ binvert;

    assign sum  = aa ^ bb ^ cin;    // full adder
    assign cout = (aa & bb) | (cin & (aa ^ bb));

    always @(*) begin
        case (operation)
            2'b00: result = aa & bb;
            2'b01: result = aa | bb;
            2'b10: result = sum;
            2'b11: result = less;
        endcase
    end
endmodule
