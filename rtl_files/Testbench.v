`include "Top_Module.v"

module Testbench;

    reg clk, rst;
    wire Carry;
    Top_Module uut(clk, rst, Carry);
    always #5 clk = ~clk;

    initial begin
        clk = 1'b1;
        rst = 1'b0;

        #2 rst = ~rst;
        // wait (uut.IDEX.instruction_ID == 32'h0000006f)
        #200
        $finish;
    end
    
    initial begin
        $monitor("Time = %0t", $time,   
                "    x2 = %0d", uut.Register.register[2], 
                "    x13 = %0d", uut.Register.register[3], 
                "    x10 = %0d", uut.Register.register[10],  
                "    x14 = %0d", uut.Register.register[14], 
                "    x15 = %0d", uut.Register.register[15], 
                "    m8  = %0d",  uut.Data_Memory.mem[1021], 
                "    m12 = %0d", uut.Data_Memory.mem[1016]);        
    end 

endmodule //testbench