module Decompressor_mux (instr, is_compressed);
    input [1:0] instr;
    output is_compressed;

    assign is_compressed = (instr == 2'b11) ? 1'b0:1'b1;
endmodule //Decompressor_muxe