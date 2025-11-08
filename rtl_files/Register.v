`default_nettype none

module Register (rs1, rs2, w_add, RegWrite, RegWriteData, clk, rst, data1, data2);

    input [4:0] rs1, rs2, w_add;
    input [31:0] RegWriteData;
    input RegWrite;
    input rst, clk;
    output signed [31:0] data1, data2;

    reg signed [31:0] register [0:31];

    always @(posedge clk) begin
        if(RegWrite) 
            register[w_add] <= RegWriteData;
        
        register[0] <= 32'b0;        
    end

    assign data1 = ~rst ? 32'b0 : register[rs1];
    assign data2 = ~rst ? 32'b0 : register[rs2];

    // initial begin
    //     register[1] = 32'd5;
    //     register[2] = 32'd2;
    // end

endmodule