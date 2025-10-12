module Ld_Ctrl_HZ (PCWriteEN, IF_ID_WriteEN, ID_EX_MemRead, NOP, ID_EX_rd, IF_ID_rs1, IF_ID_rs2, Branch, Jump, JumpReg, Flush);

    input [4:0] IF_ID_rs1, IF_ID_rs2, ID_EX_rd;
    input ID_EX_MemRead, Branch, Jump, JumpReg;
    output reg PCWriteEN, IF_ID_WriteEN, NOP, Flush;

    always @(*) begin
        PCWriteEN       <= 1'b1;
        IF_ID_WriteEN   <= 1'b1;
        NOP             <= 1'b0;
        Flush           <= 1'b0;

        if((ID_EX_MemRead == 1 && ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)))) begin
            PCWriteEN       <= 1'b0;
            IF_ID_WriteEN   <= 1'b0;
            NOP             <= 1'b1;
            Flush           <= 1'b0;
        end
        
        else if (Branch | Jump | JumpReg) begin
            Flush           <= 1'b1;            
        end

        else begin
            PCWriteEN       <= 1'b1;
            IF_ID_WriteEN   <= 1'b1;
            NOP             <= 1'b0; 
            Flush           <= 1'b0;
        end
    end

endmodule //Hazard_Detection