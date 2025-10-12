module Data_Memory (clk, MemWrite, MemRead, MemWriteData, MemReadData, ALUresult);

    input  clk, MemWrite, MemRead;
    input  [31:0] ALUresult;
    input  signed [31:0] MemWriteData;

    output signed [31:0] MemReadData;

    reg signed [31:0] mem [0:1023];

    assign MemReadData = MemRead ? mem[ALUresult[31:2]] : 'b0;

    always @(posedge clk) begin
        if(MemWrite)
            mem[ALUresult[31:2]] <= MemWriteData;
    end

endmodule //Data_Memory



