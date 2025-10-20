`include "Top_Module.v"

module Testbench;

    reg clk, rst;
    Top_Module uut(clk, rst);
    always #5 clk = ~clk;

    initial begin
        clk = 1'b1;
        rst = 1'b0;

        #2 rst = ~rst;
        #300
        $finish;
    end
    
    initial begin
        // $monitor("Time = %0t,   Instr = %h",$time,  uut.instruction, "    x2 = %0h", uut.Register.register[2], "    x13 = %0d", uut.Register.register[13], "    x10 = %0d", uut.Register.register[10],  "    x14 = %0d", uut.Register.register[14], "    x15 = %0d", uut.Register.register[15], "    m8 = %0d", uut.Data_Memory.mem[1022], "    m12 = %0d", uut.Data_Memory.mem[12]);
        $monitor("Time = %0t", $time, "    x0 = %0d",uut.Register.register[0], "     x1 = %0d",uut.Register.register[1], "    x2 = %0d", uut.Register.register[2], "    x3 = %0d", uut.Register.register[3], "   x10 = %0d", uut.Register.register[10], "   data memory = %0d", uut.Data_Memory.mem[12]);
    end 

    initial begin
        $dumpfile("RISC_V.vcd");
        $dumpvars(0, Testbench);
    end
endmodule //testbench