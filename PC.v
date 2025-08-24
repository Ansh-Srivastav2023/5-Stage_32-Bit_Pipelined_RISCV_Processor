module PC(PC_next, clk, rst, PC);

    input clk, rst;
    input [31:0] PC_next;
    output reg [31:0] PC;

    always @(posedge clk or negedge rst) begin
        if(~rst)
            PC <='b0;
        else 
            PC <= PC_next;
    end
        
endmodule