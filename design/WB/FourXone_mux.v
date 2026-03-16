module FourXone_mux (A, B, C, sel, Out);

    input [31:0] A, B, C;
    input [1:0] sel;
    output [31:0] Out;

    assign Out = (sel == 2'b00) ? A : ((sel == 2'b01) ? B : C);

endmodule //FourXone_mux