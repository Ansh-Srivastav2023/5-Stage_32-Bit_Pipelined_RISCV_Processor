`default_nettype wire
`timescale 1ns/1ps

module multiplex_3x1(A, B, C, D, sel, Result);

    input [31:0] A, B, C, D;
    input [1:0] sel;
    output [31:0] Result;

    assign Result = (sel == 2'b00)  ? A : 
                    ((sel == 2'b01) ? B : 
                    ((sel == 2'b10) ? C: D));

endmodule //MEM_WB

