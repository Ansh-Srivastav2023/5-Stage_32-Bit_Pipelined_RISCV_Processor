`default_nettype wire
`timescale 1ns/1ns

module Register (rs1, rs2, w_add, RegWrite, RegWriteData, clk, rst, data1, data2);

    input [4:0] rs1, rs2, w_add;
    input [31:0] RegWriteData;
    input RegWrite;
    input rst, clk;
    output signed [31:0] data1, data2;

    (* ram_style = "distributed" *)
    reg signed [31:0] register [0:31];

    always @(posedge clk) begin
        if(RegWrite && w_add != 5'b00000) 
            register[w_add] <= RegWriteData;
        end
        
    initial register[0] = 32'b0;

    assign data1 = ~rst ? 32'b0 : register[rs1];
    assign data2 = ~rst ? 32'b0 : register[rs2];

endmodule

