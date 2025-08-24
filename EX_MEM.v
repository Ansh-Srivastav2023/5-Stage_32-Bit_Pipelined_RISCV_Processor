module EX_MEM(clk, rst, EX_MEM, PC_ALU_Sum, Zero, ALUresult, data2, rd_ID_EX, Reg_Con, Mem_Con, Branch, PCSrc, ResultSrc, PC);

    input clk, rst, Zero, Reg_Con, Branch, PCSrc;
    input [1:0] Mem_Con, ResultSrc;
    input [31:0] PC_ALU_Sum, ALUresult, data2, PC;
    input [4:0] rd_ID_EX;
    output reg [140:0] EX_MEM;
    

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            EX_MEM <= 'b0;
        end
        else
            EX_MEM <= {PC, ResultSrc, PCSrc, Reg_Con, Mem_Con, Branch, PC_ALU_Sum, Zero, ALUresult, data2, rd_ID_EX};
    end

endmodule