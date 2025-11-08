module mult_div_stall (ALUControl_5, stall, mul_done, div_done, rst);

    input ALUControl_5, rst;
    input mul_done, div_done;
    output stall;

    assign stall =  !rst ? 1'b0 : 
                    ALUControl_5 ? ((mul_done | div_done) ? 1'b0 : 1'b1) : 1'b0;
endmodule