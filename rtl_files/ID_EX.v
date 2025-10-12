module ID_EX(clk, rst, data1, data2, ImmExt, PC, instruction, RegWrite, Mem_Con, RegWrite_ID, Mem_Con_ID, PC_ID, data1_ID, data2_ID, ImmExt_ID, instruction_ID, rs1_ID, rs2_ID, rs1, rs2, ALUSrc, ALUSrc_ID, rd, rd_ID, B_Zero, B_Zero_ID, ResultSrcHZ, BranchHZ, JumpHZ, JumpRegHZ, ImmTypeHZ, ALUControlHZ, ResultSrc_ID, Branch_ID, Jump_ID, JumpReg_ID, ImmType_ID, ALUControl_ID, Flush, isPC_select, isPC_select_ID, PC_next_IF, PC_next_ID);

    input rst, clk, RegWrite, ALUSrc, B_Zero, BranchHZ, JumpHZ, JumpRegHZ, Flush;
    input [2:0] ImmTypeHZ;
    input [4:0] ALUControlHZ;
    input [1:0] Mem_Con, ResultSrcHZ, isPC_select;
    input [31:0] data1, data2, ImmExt, PC, PC_next_IF;
    input [31:0] instruction;
    input [4:0] rs1, rs2, rd;
    
    output reg RegWrite_ID, ALUSrc_ID, B_Zero_ID, Branch_ID, Jump_ID, JumpReg_ID;
    output reg [2:0] ImmType_ID;
    output reg [4:0] ALUControl_ID;
    output reg [1:0] Mem_Con_ID, ResultSrc_ID, isPC_select_ID;
    output reg [31:0] data1_ID, data2_ID, ImmExt_ID, PC_ID, PC_next_ID;
    output reg [31:0] instruction_ID;
    output reg [4:0] rs1_ID, rs2_ID, rd_ID;
    

    always @(posedge clk or negedge rst) begin
        if(~rst || Flush) begin
            {PC_next_ID, isPC_select_ID, ResultSrc_ID, Branch_ID, Jump_ID, JumpReg_ID, ImmType_ID, ALUControl_ID, B_Zero_ID, rd_ID, ALUSrc_ID, rs1_ID, rs2_ID, RegWrite_ID, Mem_Con_ID, PC_ID, data1_ID, data2_ID, ImmExt_ID, instruction_ID} <= 'b0;
        end
        else 
            {PC_next_ID, isPC_select_ID,ResultSrc_ID, Branch_ID, Jump_ID, JumpReg_ID, ImmType_ID, ALUControl_ID, B_Zero_ID, rd_ID, ALUSrc_ID, rs1_ID, rs2_ID, RegWrite_ID, Mem_Con_ID, PC_ID, data1_ID, data2_ID, ImmExt_ID, instruction_ID} <= {PC_next_IF,isPC_select, ResultSrcHZ, BranchHZ, JumpHZ, JumpRegHZ, ImmTypeHZ, ALUControlHZ, B_Zero, rd, ALUSrc, rs1, rs2, RegWrite, Mem_Con, PC, data1, data2, ImmExt, instruction};
    end

endmodule