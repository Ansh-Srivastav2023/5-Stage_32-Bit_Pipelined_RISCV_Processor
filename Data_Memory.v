module Data_Memory (clk, MemWrite, MemRead, MemWriteData, MemReadData, ALUresult);

    input  clk, MemWrite, MemRead;
    input  [31:0] ALUresult;
    input  signed [31:0] MemWriteData;

    output signed [31:0] MemReadData;

    reg signed [31:0] mem [0:31];

    initial begin
        mem[0] = 32'd21;
        mem[1] = 32'd50;
        mem[2] = 32'd18;
        mem[5] = 32'd18;
        mem[6] = 32'd23;
        mem[7] = 32'd100;
    end

    assign MemReadData = MemRead ? mem[ALUresult[31:2]] : 'b0;

    always @(posedge clk) begin
        if(MemWrite)
            mem[ALUresult[31:2]] <= MemWriteData;
    end

endmodule //Data_Memory



