module Data_Memory (clk, MemWrite, MemRead, MemWriteData, MemReadData, ALUresult);

    input  clk, MemWrite, MemRead;
    input  [31:0] ALUresult;
    input  signed [31:0] MemWriteData;

    output reg signed [31:0] MemReadData;

    (* ram_style = "block" *)
    reg signed [31:0] mem [0:16383];

    wire [13:0] address = ALUresult[15:2];

    // assign MemReadData = MemRead ? mem[address] : 'b0;
    
    always @(posedge clk) begin
        if(MemWrite)
            mem[address] <= MemWriteData;
    end
    
    always @(negedge clk) begin
        MemReadData = MemRead ? mem[address] : 'b0; 
    end

    initial begin
        $readmemh("data_mem.hex", mem);
    end

endmodule //Data_Memory


