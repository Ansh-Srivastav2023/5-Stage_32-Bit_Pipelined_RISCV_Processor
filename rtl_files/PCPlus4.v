module PCPlus4 (PC, rst, PCPlus4);

    input [31:0] PC;
    input rst;
    output [31:0] PCPlus4;

    assign PCPlus4 = (rst) ? (PC + 32'd4) : 'b0;

endmodule //PC_nextPlus4