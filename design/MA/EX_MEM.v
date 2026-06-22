`default_nettype wire
`timescale 1ns/1ps

module EX_MEM(clk, stall, rst, ALUresult, data2, rd_ID_EX, RegWrite, Mem_Con, ResultSrc, ResultSrc_EX, RegWrite_EX, Mem_Con_EX, ALUresult_EX, data2_EX, rd_ID_EX_EX, PC_next_ID, PC_next_EX, stall_EX);

    input clk, rst, RegWrite, stall;
    input [1:0] Mem_Con, ResultSrc;
    input [31:0] ALUresult, data2, PC_next_ID;
    input [4:0] rd_ID_EX;
    
    output reg RegWrite_EX, stall_EX;
    output reg [1:0] Mem_Con_EX, ResultSrc_EX;
    output reg [31:0] ALUresult_EX, data2_EX, PC_next_EX;
    output reg [4:0] rd_ID_EX_EX;

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            {stall_EX, PC_next_EX, ResultSrc_EX, RegWrite_EX, Mem_Con_EX, ALUresult_EX, data2_EX, rd_ID_EX_EX} <= 'b0;
        end
        else
            {stall_EX, PC_next_EX, ResultSrc_EX, RegWrite_EX, Mem_Con_EX, ALUresult_EX, data2_EX, rd_ID_EX_EX} <= {stall, PC_next_ID, ResultSrc, RegWrite, Mem_Con, ALUresult, data2, rd_ID_EX};
    end

endmodule
