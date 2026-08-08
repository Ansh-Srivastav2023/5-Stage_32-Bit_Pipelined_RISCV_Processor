`default_nettype wire
`timescale 1fs/1fs

module Testbench;

    reg clk, rst;

    wire Carry;
    wire Tx_Serial;
    wire [31:0] IO_OUT;

    wire tickx, Tx_Donex, Tx_Serialx, Tx_Activex;
    reg Tx_Drivex;
    reg [7:0] data_inx;

    Top_Module uut(.clk(clk), .async_rst(rst), .Rx_Serial(Tx_Serialx), .Carry(Carry), .Tx_Serial(Tx_Serial), .IO_OUT(IO_OUT));

    always #5 clk = ~clk;

    reg [31:0] a = 32'h30000000;

    initial begin
        clk = 1'b1;
        rst = 1'b1;
        Tx_Drivex = 0;

        #2 rst = !rst;
        #2 rst = ~rst;
        
        wait (uut.instruction_ID == 32'h0000006f)
        wait (uut.fifo_uart.empty_Tx);
        
        $finish;
    end
    
    // initial begin
    //     // $monitor("\n Time = [%0t] | IO_OUT = %c%c%c%c", $time, IO_OUT[7:0], IO_OUT[15:8], IO_OUT[23:16], IO_OUT[31:24]);
    //     $monitor("\n Time = [%0t] | IO_OUT = %d", $time, IO_OUT);
    // end 

    // initial begin
    //     $dumpfile("RISCV.vcd");
    //     $dumpvars(0);
    // end

    integer fd;
    initial begin
        fd = $fopen("io_out.hex","w");
    end

    always @(posedge uut.UART_addr_sel.IO_OUT_latch_select) begin
            $fdisplay(fd,"%h", IO_OUT);
    end

    final begin
        $fclose(fd);
    end

endmodule
