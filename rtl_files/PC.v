module PC(PC_next, clk, rst, PC, PCWrite);

    input clk, rst;
    input PCWrite;
    input [31:0] PC_next;
    output reg [31:0] PC;

    always @(posedge clk or negedge rst) begin
        if(~rst)
            PC <='b0;
        else if (!PCWrite)
            PC <= PC;
        else
            PC <= PC_next;
    end
        
endmodule