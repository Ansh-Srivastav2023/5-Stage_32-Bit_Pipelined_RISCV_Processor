module Multiplexer (A, B, sel, Out);

    input [31:0] A, B;
    input sel;
    output [31:0] Out;

    assign Out = (sel) ? B:A;

endmodule //Multiplexer