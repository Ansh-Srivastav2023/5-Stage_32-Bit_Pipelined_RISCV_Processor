`include "/media/anx/New_Volume/Importants/Verilog/open_sta/top_module/Top_Module.v"
`timescale 1ns/1ps

module Testbench;

    reg clk, rst;
    wire Carry;
    wire Tx_Done, Rx_Done, Tx_Serial, full, empty;
    wire [15:0] IO_OUT;

    Top_Module uut(clk, rst, Carry, Tx_Done, Rx_Done, Tx_Serial, full, empty, IO_OUT);

    always #5 clk = ~clk;

    wire signed [7:0] tx_data = uut.fifo_uart.uart.uart_tx.data_in;

    initial begin
        clk = 1'b1;
        rst = 1'b1;

        #2 rst = !rst;

        #2 rst = ~rst;
        wait (uut.IDEX.instruction_ID == 32'h0000006f)
        wait (empty);
        // @(posedge clk);
        // @(posedge clk);
        #6000;
        $finish;
    end


    // initial begin
    //     $monitor(
    //     "main_ram = %0h", uut.Data_Memory.main_ram[0],
    //     "   main_ram = %0h", uut.Data_Memory.main_ram[1],
    //     "   main_ram = %0h", uut.Data_Memory.main_ram[2],
    //     "   main_ram = %0h", uut.Data_Memory.main_ram[3],
    //     "   main_ram = %0h", uut.Data_Memory.main_ram[4]
    //     );
    // end
    
    initial begin
        $monitor(//"instr = %h", uut.IDEX.instruction_ID,
                // "    x0 = %0d", uut.Register.register[0],
                // "    x1 = %0d", uut.Register.register[1],
                // "    x2 = %0d", uut.Register.register[2],
                // "    x3 = %0d", uut.Register.register[3],
                // "    x4 = %0d", uut.Register.register[4],
                // "    x5 = %0d", uut.Register.register[10]
                // "Time = [%0t]" , $time,
                // "Tx Data = %d", $signed(uut.fifo_uart.uart.uart_tx.data_in),
                "IO_OUT = %d", IO_OUT
                // "    x10 = %0d", uut.Register.register[10]
                // "    x12 = %0d", uut.Register.register[12],  
                // "    x13 = %0d", uut.Register.register[13],  
                // "    x15 = %0d", uut.Register.register[15], 
                // "    LED = %0d",  uut.Data_Memory.main_ram[8192]
                // "    m1022 = %0d",  uut.Data_Memory.mem[1022], 
                // "    m1023 = %0d", uut.Data_Memory.mem[1023]
                );        
    end 

    initial begin
        $dumpfile("RISCV.vcd");
        $dumpvars(0);
    end

endmodule //testbench