`default_nettype wire
`timescale 1ns/1ps

module EX_MEM(clk, stall, rst, ALUresult, data2, rd_ID_EX, RegWrite, Mem_Con, ResultSrc, ResultSrc_EX, RegWrite_EX, Mem_Con_EX, ALUresult_EX, data2_EX, rd_ID_EX_EX, PC_next_ID, PC_next_EX, stall_EX, instruction_EX, instruction_ID, funct3_EX, funct3_ID);

    input clk, rst, RegWrite, stall;
    input [1:0] Mem_Con, ResultSrc;
    input [31:0] ALUresult, data2, PC_next_ID;
    input [4:0] rd_ID_EX;
    input [31:0] instruction_ID;
    input [2:0] funct3_ID;
    
    output reg [2:0] funct3_EX;
    output reg [31:0] instruction_EX;
    output reg RegWrite_EX, stall_EX;
    output reg [1:0] Mem_Con_EX, ResultSrc_EX;
    output reg [31:0] ALUresult_EX, data2_EX, PC_next_EX;
    output reg [4:0] rd_ID_EX_EX;

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            funct3_EX <= 'b0;
            instruction_EX <= 'b0;
            {stall_EX, PC_next_EX, ResultSrc_EX, RegWrite_EX, Mem_Con_EX, ALUresult_EX, data2_EX, rd_ID_EX_EX} <= 'b0;
        end
        else begin
            funct3_EX <= funct3_ID;
            instruction_EX <= instruction_ID;
            {stall_EX, PC_next_EX, ResultSrc_EX, RegWrite_EX, Mem_Con_EX, ALUresult_EX, data2_EX, rd_ID_EX_EX} <= {stall, PC_next_ID, ResultSrc, RegWrite, Mem_Con, ALUresult, data2, rd_ID_EX};
        end
    end

endmodule

