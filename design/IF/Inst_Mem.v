// module Inst_Mem(PC, rst, instruction, clk);
//     input [31:0] PC;
//     input clk, rst;
//     output reg [31:0] instruction;

//     (* ram_style = "block" *)
//     reg [31:0] instruction_mem [0:255];
    
//     // assign instruction = (!rst) ? {32{1'b0}} : instruction_mem[{PC[31:2]}];
    
//     initial $readmemh("/media/anx/New_Volume/Importants/Verilog/open_sta/design/IF/instr_mem.hex", instruction_mem);
    
//     always @(negedge clk) begin
//         instruction = (!rst) ? {32{1'b0}} : instruction_mem[{PC[9:2]}];   
//     end

//     // initial begin
//     //     $display("hello");
//     // end
    
// endmodule
