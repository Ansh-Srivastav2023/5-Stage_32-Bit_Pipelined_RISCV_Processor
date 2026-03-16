module UART_addr_sel (
    input [31:0] ALUresult,
    input MemWrite,
    input [15:0] IO_OUT_temp,
    output [15:0] IO_OUT,

    output reg [1:0] UART_Mem_wt
);

    localparam UART_addr = 32'h80000000;
    localparam IO_addr = 32'h90000000;

    assign IO_OUT = (UART_Mem_wt == 2'b11) ? IO_OUT_temp : 16'b0;

    always @(*) begin
        if(MemWrite) begin
            if(ALUresult == UART_addr) begin
                UART_Mem_wt = 2'b10;
            end

            else if (ALUresult == IO_addr) begin
                UART_Mem_wt = 2'b11;
            end

            else begin
                UART_Mem_wt = 2'b01;
            end
        end

        else begin
            UART_Mem_wt = 2'b00;
        end        
    end
    
endmodule

// 2'b00 = no Memory Mapped operations
// 2'b01 = write to Memory
// 2'b10 = Write via UART
// 2'b11 = Direct to the I/O port