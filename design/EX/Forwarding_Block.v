module Forwarding_Block (EX_MEM_RegWrite, MEM_WB_RegWrite, ID_EX_rs1, ID_EX_rs2, EX_MEM_rd, MEM_WB_rd, ForwardA, ForwardB);

    input EX_MEM_RegWrite, MEM_WB_RegWrite;
    input [4:0] ID_EX_rs1, ID_EX_rs2;
    input [4:0] EX_MEM_rd, MEM_WB_rd;
    output [1:0] ForwardA, ForwardB;

    assign ForwardA = (EX_MEM_RegWrite && (EX_MEM_rd != 'b0) && (EX_MEM_rd == ID_EX_rs1)) ? 2'b10 : 
                      (MEM_WB_RegWrite && (MEM_WB_rd != 'b0) && (MEM_WB_rd == ID_EX_rs1)) ? 2'b01 : 2'b00;
    
    assign ForwardB = (EX_MEM_RegWrite && (EX_MEM_rd != 'b0) && (EX_MEM_rd == ID_EX_rs2)) ? 2'b10 : 
                      (MEM_WB_RegWrite && (MEM_WB_rd != 'b0) && (MEM_WB_rd == ID_EX_rs2)) ? 2'b01 : 2'b00;

endmodule //Forwarding_Block


// Mux Control Signal Encoding:
// 2'b00: Select data from Register File (ID/EX)
// 2'b01: Forward from MEM/WB stage
// 2'b10: Forward from EX/MEM stage