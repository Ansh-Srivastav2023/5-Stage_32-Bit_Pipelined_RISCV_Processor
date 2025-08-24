module MEM_WB(Reg_Con, MemReadData, ALUresult, rd_EXMEM, MEM_WB, clk, rst, ResultSrc, PC);

    input Reg_Con, clk, rst;
    input [1:0] ResultSrc;
    input [31:0] MemReadData, ALUresult, PC;
    input [4:0] rd_EXMEM;

    output reg [103:0] MEM_WB;
    

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            MEM_WB <= 'b0;
        end
        else
            MEM_WB <= {PC, ResultSrc, Reg_Con, MemReadData, ALUresult, rd_EXMEM};
    end

endmodule

module multiplex_result(A, B, C, D, sel, Result);

    input [31:0] A, B, C, D;
    input [1:0] sel;
    output [31:0] Result;

    assign Result = (sel == 2'b00)  ? A : 
                    ((sel == 2'b01) ? B : 
                    ((sel == 2'b10) ? C: D));

endmodule //MEM_WB