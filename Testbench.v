`include "Top_Module.v"

module Testbench;

    reg clk, rst;
    Top_Module uut(clk, rst);
    always #5 clk = ~clk;

    initial begin
        clk = 1'b1;
        rst = 1'b0;

        #2 rst = ~rst;
        #100
        $finish;
    end
    
    initial begin
        $monitor(uut.Register.register[1], " ", uut.Register.register[3], " ", uut.Data_Memory.mem[3]);
    end

    initial begin
        $dumpfile("RISC_V.vcd");
        $dumpvars(0, Testbench);
    end
endmodule //testbench