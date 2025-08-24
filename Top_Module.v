`include "PC.v"
`include "PCPlus4.v"
`include "Inst_Mem.v"
`include "Register.v"
`include "Imm_Extend.v"
`include "ALU.v"
`include "Multiplexer.v"
`include "Control_Unit.v"
`include "Data_Memory.v"
`include "IF_ID.v"
`include "ID_EX.v"
`include "EX_MEM.v"
`include "MEM_WB.v"

module Top_Module (clk, rst);

    input clk, rst;

    wire [31:0] PC, PC_next, PCPlus4, instruction;
    wire [63:0] IF_ID;

    wire [31:0] Result, data1, data2, ImmExt, PC_ALU_Sum;
    wire RegWrite, JumpReg, Jump, Branch, PCSrc, ALUSrc, Zero, MemWrite, MemRead, Zero_branch;
    wire [31:0] rdB, ALUresult;

    wire [175:0] ID_EX;
    wire [1:0] ImmType, ResultSrc;
    wire [3:0] ALUControl;

    wire [140:0] EX_MEM;

    wire [31:0] MemReadData;

    wire [103:0] MEM_WB;

    wire x; assign x = EX_MEM[106];

    

    PC PC0(.PC_next(PC_next), .clk(clk), .rst(rst), .PC(PC));
    PCPlus4 PCplus4(.PC(PC), .rst(rst), .PCPlus4(PCPlus4));
    Inst_Mem Inst_Mem (.PC(PC), .rst(rst), .instruction(instruction));
    IF_ID IFID(.clk(clk), .rst(rst), .PC(PC), .instruction(instruction), .IF_ID(IF_ID));
    Multiplexer MultiPC (.A(PCPlus4), .B(EX_MEM[101:70]), .sel(x), .Out(PC_next));


    
    Control_Unit Control_Unit(.opcode(IF_ID[6:0]),.funct3(IF_ID[14:12]),.funct7(IF_ID[31:25]),.Zero(Zero_branch),.RegWrite(RegWrite),.MemWrite(MemWrite),.MemRead(MemRead),.ALUSrc(ALUSrc),.PCSrc(PCSrc),.ResultSrc(ResultSrc),.Branch(Branch),.Jump(Jump),.JumpReg(JumpReg),.ImmType(ImmType),.ALUControl(ALUControl), .rst(rst));
    ALU ALU_branch(.rdA(data1), .rdB(data2), .ALUControl(ALUControl), .Zero(Zero_branch));


    Register Register(.clk(clk), .rst(rst), .data1(data1), .data2(data2), .rs1(IF_ID[19:15]), .rs2(IF_ID[24:20]), .w_add(MEM_WB[4:0]), .RegWrite(MEM_WB[69]), .RegWriteData(Result));
    Imm_Extend Imm0(.instruction(IF_ID[31:0]), .ImmType(ImmType), .ImmExt(ImmExt));
    ID_EX IDEX (.clk(clk), .rst(rst), .data1(data1), .data2(data2), .ImmExt(ImmExt), .PC(IF_ID[63:32]), .instruction({IF_ID[31:0]}), .ID_EX(ID_EX), .Reg_Con(RegWrite), .Mem_Con({MemWrite, MemRead}), .Ex_Con({ALUSrc, PCSrc, ResultSrc, Branch, Jump, JumpReg, ImmType, ALUControl}));



    ALU ALU(.rdA(ID_EX[127:96]), .rdB(rdB), .ALUControl(ID_EX[163:160]), .ALUresult(ALUresult), .Carry(Carry), .Zero(Zero));
    Multiplexer Multiplex_ALU (.A(ID_EX[95:64]), .B(ID_EX[63:32]), .sel(ID_EX[172]), .Out(rdB));
    PC_ALU_Adder PC_ALU_Adder0(.A(ID_EX[159:128]), .B(ID_EX[63:32]), .Sum(PC_ALU_Sum));
    EX_MEM EXMEM(.clk(clk), .rst(rst), .EX_MEM(EX_MEM), .PC_ALU_Sum(PC_ALU_Sum), .Zero(Zero), .ALUresult(ALUresult), .data2(ID_EX[95:64]), .rd_ID_EX(ID_EX[11:7]), .Reg_Con(ID_EX[175]), .Mem_Con(ID_EX[174:173]), .Branch(ID_EX[168]), .PCSrc(ID_EX[171]), .ResultSrc(ID_EX[170:169]), .PC(ID_EX[159:128]));



    Data_Memory Data_Memory(.clk(clk), .MemWrite(EX_MEM[104]), .MemRead(EX_MEM[103]), .MemWriteData(EX_MEM[36:5]), .MemReadData(MemReadData), .ALUresult(EX_MEM[68:37]));
    MEM_WB MEMWB (.Reg_Con(EX_MEM[105]), .MemReadData(MemReadData), .ALUresult(EX_MEM[68:37]), .rd_EXMEM(EX_MEM[4:0]), .MEM_WB(MEM_WB), .clk(clk), .rst(rst), .ResultSrc(EX_MEM[108:107]), .PC(EX_MEM[140:109]));
    multiplex_result multipplex_result0 (.A(MEM_WB[36:5]), .B(MEM_WB[68:37]), .C(MEM_WB[103:72]), .D('b0), .sel(MEM_WB[71:70]), .Result(Result));

endmodule //Top_Module