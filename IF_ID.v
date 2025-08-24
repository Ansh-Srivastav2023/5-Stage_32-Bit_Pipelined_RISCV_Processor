
module IF_ID(clk, rst, PC, instruction, IF_ID);
    input [31:0] PC, instruction;
    input clk, rst;
    output reg [63:0] IF_ID;
    
    reg [63:0] IF_ID_nxt;

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            IF_ID_nxt <= 'b0;
            IF_ID <= 'b0;
        end
        else
            IF_ID <= {PC, instruction};
    end    
    
        
    // always @(posedge clk) begin
    //     IF_ID <= IF_ID_nxt;        
    // end
endmodule