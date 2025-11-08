module MEM_WB(RegWrite, stall, MemReadData, ALUresult, rd_EXMEM, clk, rst, ResultSrc, PC, PC_MEM, ResultSrc_MEM, RegWrite_MEM, MemReadData_MEM, ALUresult_MEM, rd_EXMEM_MEM, PC_next_EX, PC_next_MEM);

    input RegWrite, clk, rst, stall;
    input [1:0] ResultSrc;
    input [31:0] MemReadData, ALUresult, PC, PC_next_EX;
    input [4:0] rd_EXMEM;
    
    output reg RegWrite_MEM;
    output reg [4:0] rd_EXMEM_MEM;
    output reg [1:0] ResultSrc_MEM;
    output reg [31:0] MemReadData_MEM, ALUresult_MEM, PC_MEM, PC_next_MEM;

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            {PC_next_MEM, PC_MEM, ResultSrc_MEM, RegWrite_MEM, MemReadData_MEM, ALUresult_MEM, rd_EXMEM_MEM} <= 'b0;
        end
        else if (stall)
            {PC_next_MEM, PC_MEM, ResultSrc_MEM, RegWrite_MEM, MemReadData_MEM, ALUresult_MEM, rd_EXMEM_MEM} <= {PC_next_MEM, PC_MEM, ResultSrc_MEM, RegWrite_MEM, MemReadData_MEM, ALUresult_MEM, rd_EXMEM_MEM};
        else
            {PC_next_MEM, PC_MEM, ResultSrc_MEM, RegWrite_MEM, MemReadData_MEM, ALUresult_MEM, rd_EXMEM_MEM} <= {PC_next_EX, PC, ResultSrc, RegWrite, MemReadData, ALUresult, rd_EXMEM};
    end

endmodule

module multiplex_3x1(A, B, C, D, sel, Result);

    input [31:0] A, B, C, D;
    input [1:0] sel;
    output [31:0] Result;

    assign Result = (sel == 2'b00)  ? A : 
                    ((sel == 2'b01) ? B : 
                    ((sel == 2'b10) ? C: D));

endmodule //MEM_WB