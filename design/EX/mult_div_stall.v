`default_nettype wire
`timescale 1ns/1ns

module mult_div_stall (stall, mul_active, div_active, rst);

    input rst;
    input mul_active, div_active;
    output stall;

    assign stall =  !rst ? 1'b0 : ((mul_active | div_active) ? 1'b1 : 1'b0);
endmodule
