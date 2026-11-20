// traffic_light.v 
// traffic light as Moore machine with named states
module traffic_light (
    input  wire clk,
    input  wire rst,
    output reg  r,
    output reg  y,
    output reg  g
);
    localparam RED        = 2'b00;
    localparam RED_YELLOW = 2'b01;
    localparam GREEN      = 2'b10;
    localparam YELLOW     = 2'b11;

    reg [1:0] state, next;

    // state register
    always @(posedge clk) begin
        if (rst)
            state <= RED;
        else
            state <= next;
    end

    // next-state logic
    always @(*) begin
        case (state)
            RED:        next = RED_YELLOW;
            RED_YELLOW: next = GREEN;
            GREEN:      next = YELLOW;
            YELLOW:     next = RED;
            default:    next = RED;
        endcase
    end

    // output logic: depends only on the state (Moore)
    always @(*) begin
        {r, y, g} = 3'b000;
        case (state)
            RED:        {r, y, g} = 3'b100;
            RED_YELLOW: {r, y, g} = 3'b110;
            GREEN:      {r, y, g} = 3'b001;
            YELLOW:     {r, y, g} = 3'b010;
            default:    {r, y, g} = 3'b100;
        endcase
    end
endmodule
