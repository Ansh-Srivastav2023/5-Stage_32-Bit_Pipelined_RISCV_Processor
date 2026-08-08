`default_nettype wire
`timescale 1ns/1ns

module UART_addr_sel (
    input [31:0] ALUresult,
    input MemWrite, rst,
    input [31:0] IO_OUT_temp,
    
    output reg [31:0] IO_OUT,
    output reg [1:0] UART_Mem_wt
);

    localparam UART_addr = 32'h80000000;
    localparam IO_addr = 32'h90000000;

    wire IO_OUT_latch_select;

    assign IO_OUT_latch_select = (UART_Mem_wt == 2'b11) ? 1'b1 : 1'b0;

    always @(posedge IO_OUT_latch_select or negedge rst) begin
        if(!rst) IO_OUT <= 0;
        else IO_OUT <= IO_OUT_temp;
    end

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
