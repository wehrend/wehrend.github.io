`timescale 1ns / 1ps

module traffic_light_tb;
    reg  clk = 0;
    reg  rst = 1;
    wire r_eq, y_eq, g_eq;
    wire r, y, g;
    integer errors = 0;

    traffic_light_eq by_hand (.clk(clk), .rst(rst), .r(r_eq), .y(y_eq), .g(g_eq));
    traffic_light    named   (.clk(clk), .rst(rst), .r(r),    .y(y),    .g(g));

    // clock: period 10 ns
    always #5 clk = ~clk;

    initial begin
        $dumpfile("traffic_light.vcd");
        $dumpvars(0, traffic_light_tb);
        #12 rst = 0;
        #100;
        if (errors == 0) $display("PASSED: both implementations are identical");
        else             $display("FAILED: %0d differences", errors);
        $finish;
    end

    // compare both implementations after every rising clock edge
    always @(posedge clk) begin
        #1;
        $display("t=%0d ns  state=%b  R=%b Y=%b G=%b", $time, named.state, r, y, g);
        if ({r_eq, y_eq, g_eq} !== {r, y, g})
            errors = errors + 1;
    end
endmodule
