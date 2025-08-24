module ID_EX(clk, rst, data1, data2, ImmExt, PC, instruction, ID_EX, Reg_Con, Mem_Con, Ex_Con);

    input rst, clk, Reg_Con;
    input [1:0] Mem_Con;
    input [12:0] Ex_Con;
    input [31:0] data1, data2, ImmExt, PC;
    input [31:0] instruction;
    output reg [175:0] ID_EX;

    reg [175:0] ID_EX_nxt;

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            // ID_EX_nxt <= 'b0;
            ID_EX <= 'b0;
        end
        else 
            ID_EX <= {Reg_Con, Mem_Con, Ex_Con, PC, data1, data2, ImmExt, instruction};
    end


    // always @(posedge clk) begin
    //     ID_EX <= ID_EX_nxt;
    // end
endmodule