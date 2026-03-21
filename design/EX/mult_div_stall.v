`default_nettype wire
`timescale 1ns/1ps

module mult_div_stall (ALUControl_5, stall, mul_active, div_active, rst);

    input ALUControl_5, rst;
    input mul_active, div_active;
    output stall;

    assign stall =  !rst ? 1'b0 : ((mul_active | div_active) ? 1'b1 : 1'b0);
endmodule