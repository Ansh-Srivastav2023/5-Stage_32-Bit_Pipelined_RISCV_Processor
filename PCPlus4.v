module PCPlus4 (PC, rst, PCPlus4);

    input [31:0] PC;
    input rst;
    output [31:0] PCPlus4;

    assign PCPlus4 = (rst) ? (PC + 3'b100) : 'b0;

endmodule //PC_nextPlus4