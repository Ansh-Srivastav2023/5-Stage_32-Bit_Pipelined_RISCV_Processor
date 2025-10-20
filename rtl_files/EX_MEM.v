module EX_MEM(clk, rst, PC_ALU_Sum, Zero, ALUresult, data2, rd_ID_EX, RegWrite, Mem_Con, Branch, PCSrc, ResultSrc, PC, PC_EX, ResultSrc_EX, PCSrc_EX, RegWrite_EX, Mem_Con_EX, Branch_EX, PC_ALU_Sum_EX, Zero_EX, ALUresult_EX, data2_EX, rd_ID_EX_EX, PC_next_ID, PC_next_EX);

    input clk, rst, Zero, RegWrite, Branch, PCSrc;
    input [1:0] Mem_Con, ResultSrc;
    input [31:0] PC_ALU_Sum, ALUresult, data2, PC, PC_next_ID;
    input [4:0] rd_ID_EX;
    
    output reg Zero_EX, RegWrite_EX, Branch_EX, PCSrc_EX;
    output reg [1:0] Mem_Con_EX, ResultSrc_EX;
    output reg [31:0] PC_ALU_Sum_EX, ALUresult_EX, data2_EX, PC_EX, PC_next_EX;
    output reg [4:0] rd_ID_EX_EX;

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            {PC_next_EX, PC_EX, ResultSrc_EX, PCSrc_EX, RegWrite_EX, Mem_Con_EX, Branch_EX, PC_ALU_Sum_EX, Zero_EX, ALUresult_EX, data2_EX, rd_ID_EX_EX} <= 'b0;
        end
        else
            {PC_next_EX, PC_EX, ResultSrc_EX, PCSrc_EX, RegWrite_EX, Mem_Con_EX, Branch_EX, PC_ALU_Sum_EX, Zero_EX, ALUresult_EX, data2_EX, rd_ID_EX_EX} <= {PC_next_ID, PC, ResultSrc, PCSrc, RegWrite, Mem_Con, Branch, PC_ALU_Sum, Zero, ALUresult, data2, rd_ID_EX};
    end

endmodule