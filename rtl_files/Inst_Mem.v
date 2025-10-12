module Inst_Mem(PC, rst, instruction);
    input [31:0] PC;
    input rst;
    output [31:0] instruction;

    reg [31:0] instruction_mem [0:1024];
    
    assign instruction = (!rst) ? {31{1'b0}} : instruction_mem[{PC[31:2]}];

    initial $readmemh("instr_mem.hex", instruction_mem);
    
endmodule
