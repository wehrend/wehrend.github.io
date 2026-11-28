// traffic_light_eq.v 
// traffic light as Moore machine, built from the equations of chapter 14
// next state:  Q0' = ~Q0,  Q1' = Q1 ^ Q0
// outputs:     R = ~Q1,  Y = Q0,  G = Q1 & ~Q0
module traffic_light_eq (
    input  wire clk,
    input  wire rst,
    output wire r,
    output wire y,
    output wire g
);
    reg q1, q0;

    always @(posedge clk) begin
        if (rst) begin
            q1 <= 1'b0;
            q0 <= 1'b0;
        end else begin
            q0 <= ~q0;
            q1 <= q1 ^ q0;
        end
    end

    assign r = ~q1;
    assign y = q0;
    assign g = q1 & ~q0;
endmodule
