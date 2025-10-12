module Ctrl_mux (RegWrite, MemWrite, MemRead, ALUSrc, ResultSrc, Branch, Jump, JumpReg, ImmType, ALUControl, sel, RegWriteHZ, MemWriteHZ, MemReadHZ, ALUSrcHZ, ResultSrcHZ, BranchHZ, JumpHZ, JumpRegHZ, ImmTypeHZ, ALUControlHZ);

    input RegWrite, MemWrite, MemRead, ALUSrc, Branch, Jump, JumpReg;
    input [1:0] ResultSrc;
    input [2:0] ImmType;
    input [4:0] ALUControl;
    input sel;

    output RegWriteHZ, MemWriteHZ, MemReadHZ, ALUSrcHZ, BranchHZ, JumpHZ, JumpRegHZ;
    output [1:0] ResultSrcHZ;
    output [2:0] ImmTypeHZ;
    output [4:0] ALUControlHZ;

    assign {RegWriteHZ, MemWriteHZ, MemReadHZ, ALUSrcHZ, ResultSrcHZ, BranchHZ, JumpHZ, JumpRegHZ, ImmTypeHZ, ALUControlHZ} = sel ? 'b0 : {RegWrite, MemWrite, MemRead, ALUSrc, ResultSrc, Branch, Jump, JumpReg, ImmType, ALUControl};

endmodule //Ctrl_mux