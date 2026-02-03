`include "Top_Module.v"
`timescale 1ps/1ps

module Testbench;

    reg clk, rst;
    wire Carry;
    wire [14:0] debug_reg_a10;
    Top_Module uut(clk, rst, Carry, debug_reg_a10);
    always #5 clk = ~clk;

    initial begin
        clk = 1'b1;
        rst = 1'b0;

        #2 rst = ~rst;
        wait (uut.IDEX.instruction_ID == 32'h0000006f)
        // #120
        $finish;
    end
    
    initial begin
        $monitor("instr = %h", uut.IDEX.instruction_ID,
                "    x0 = %0d", uut.Register.register[0], 
                "    x1 = %0d", uut.Register.register[1], 
                "    x2 = %0h", uut.Register.register[2], 
                "    x3 = %0d", uut.Register.register[3], 
                "    x5 = %0d", uut.Register.register[5], 
                "    x10 = %0d", uut.Register.register[10],  
                "    x12 = %0d", uut.Register.register[12],  
                "    x13 = %0d", uut.Register.register[13],  
                "    x15 = %0d", uut.Register.register[15], 
                "    LED = %0d",  uut.Data_Memory.mem[3],
                "    m1022 = %0d",  uut.Data_Memory.mem[1022], 
                "    m1023 = %0d", uut.Data_Memory.mem[1023]);        
    end 

endmodule //testbench