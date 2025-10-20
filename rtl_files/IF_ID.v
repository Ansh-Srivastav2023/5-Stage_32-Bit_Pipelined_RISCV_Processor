
module IF_ID(clk, rst, PC, instruction, PC_IF, instruction_IF, IF_ID_WriteEN, Flush, PC_next, PC_next_IF);
    input [31:0] PC, instruction;
    input clk, rst, IF_ID_WriteEN, Flush;
    input [31:0] PC_next;
    output reg [31:0] PC_IF, instruction_IF;
    output reg [31:0] PC_next_IF;
    
    always @(posedge clk or negedge rst) begin
        if(~rst || Flush) begin
            {PC_next_IF, PC_IF, instruction_IF} <= 'b0;
        end
        else if(IF_ID_WriteEN) 
            {PC_next_IF, PC_IF, instruction_IF} <= {PC_next, PC, instruction};

        else if (!IF_ID_WriteEN)
            {PC_next_IF, PC_IF, instruction_IF} <= {PC_next_IF, PC_IF, instruction_IF};
    end    
    
endmodule