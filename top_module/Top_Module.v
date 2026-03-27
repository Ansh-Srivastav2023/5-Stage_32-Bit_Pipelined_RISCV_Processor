`default_nettype wire
`timescale 1ns/1ps


module Top_Module (
    input  clk,
    input  async_rst,
    input  Rx_Serial,
    output Carry,
    output Tx_Serial, 
    output [15:0] IO_OUT
);

    wire rst;
    wire [31:0] PC, PC_next, PCPlus4, instruction;
    
    wire [31:0] Result, data1, data2, ImmExt, PC_ALU_Sum, initial_instr, compress_instr, data1_ID_ForwA, rdB_ForwB, rf_data1, rf_data2;
    wire RegWrite, JumpReg, Jump, Branch, PCSrc, ALUSrc, Zero, MemWrite, MemRead, ALUSrc_ID, PCWriteEN, IF_ID_WriteEN, NOP, B_Zero, B_Zero_ID, Branch_ID, Jump_ID, JumpReg_ID, Flush;
    wire [31:0] rdA, rdB, ALUresult,PC_Branch;
    
    wire [2:0] ImmType;
    wire [1:0] ResultSrc, ResultSrc_ID;
    wire [4:0] ALUControl, rs1_ID, rs2_ID, ALUControl_ID;
        
    wire [31:0] MemReadData;
    
    wire [31:0] PC_IF, instruction_IF;

    wire RegWrite_ID, is_compressed, stall, mul_active, div_active;
    wire [1:0] Mem_Con_ID, ForwardA, ForwardB, isPC_select, isPC_select_ID;
    wire [31:0] PC_ID, data1_ID, data2_ID, ImmExt_ID;

    wire [31:0] ALUresult_EX, data2_EX;
    wire [1:0] ResultSrc_EX, Mem_Con_EX, ResultSrc_MEM;
    wire RegWrite_EX, RegWrite_MEM, stall_EX, stall_MEM;
    wire [4:0] rd_ID_EX_EX, rd_EXMEM_MEM, rd_ID;

    wire [31:0] MemReadData_MEM, ALUresult_MEM;

    wire RegWriteHZ, MemWriteHZ, MemReadHZ, ALUSrcHZ, BranchHZ, JumpHZ, JumpRegHZ;
    wire [1:0] ResultSrcHZ;
    wire [4:0] ALUControlHZ;
    wire [31:0] PC_next_IF, PC_next_ID, PC_next_EX, PC_next_MEM;

    wire [1:0] UART_Mem_wt;

    wire [7:0] FIFO_Rx_Dout;
    wire Rx_read_en, full_Rx, empty_Rx;


    Reset_Sync Reset_Sync(.async_rst(async_rst), .clk(clk), .sync_rst(rst));

    PC PC0(
        .PC_next(PC_next), 
        .clk(clk), 
        .rst(rst), 
        .PC(PC),
        .PCWrite(PCWriteEN & ~stall));
    PCPlus4 PCplus4(
        .PC(PC), 
        .rst(rst), 
        .PCPlus4(PCPlus4));


    Decompressor Decompressor(
        .r_instr(compress_instr), 
        .c_instr(initial_instr[15:0]));
    Decompressor_mux Decomp_Mux (
        .instr(initial_instr[1:0]), 
        .is_compressed(is_compressed));
    Multiplexer compressed_multiplex(
        .A(initial_instr), 
        .B(compress_instr), 
        .sel(is_compressed), 
        .Out(instruction));
    Multiplexer MultiPC (
        .A(PCPlus4), 
        .B(PC_ALU_Sum), 
        .sel(PCSrc), 
        .Out(PC_next));
    IF_ID IFID (
        .clk(clk), 
        .rst(rst), 
        .PC(PC), 
        .instruction(instruction), 
        .PC_IF(PC_IF), 
        .instruction_IF(instruction_IF),
        .IF_ID_WriteEN(IF_ID_WriteEN & ~stall), 
        .Flush(Flush),
        .PC_next(PC_next),
        .PC_next_IF(PC_next_IF));
        

    Control_Unit Control_Unit(
        .opcode(instruction_IF[6:0]),
        .funct3(instruction_IF[14:12]),
        .funct7(instruction_IF[31:25]),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .ALUSrc(ALUSrc),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .Jump(Jump),
        .JumpReg(JumpReg),
        .ImmType(ImmType),
        .ALUControl(ALUControl), 
        .B_Zero(B_Zero),
        // .RegRead(RegRead),
        .isPC_select(isPC_select));
        
    Register Register(
        .clk(clk), 
        .rst(rst), 
        .data1(rf_data1), 
        .data2(rf_data2), 
        .rs1(instruction_IF[19:15]), 
        .rs2(instruction_IF[24:20]), 
        .w_add(rd_EXMEM_MEM), 
        .RegWrite(RegWrite_MEM & ~stall_MEM), 
        .RegWriteData(Result));


    Imm_Extend Imm0(
        .instruction(instruction_IF[31:7]), 
        .ImmType(ImmType), 
        .ImmExt(ImmExt));

    ID_EX IDEX (
        .clk(clk), 
        .rst(rst), 
        .data1(data1), 
        .data2(data2), 
        .ImmExt(ImmExt), 
        .PC(PC_IF), 
        .RegWrite(RegWriteHZ), 
        .Mem_Con({MemWriteHZ, MemReadHZ}), 
        .ResultSrcHZ(ResultSrcHZ), .BranchHZ(BranchHZ), .JumpHZ(JumpHZ), .JumpRegHZ(JumpRegHZ), .ALUControlHZ(ALUControlHZ), 
        .RegWrite_ID(RegWrite_ID),
        .Mem_Con_ID(Mem_Con_ID),
        .PC_ID(PC_ID),
        .data1_ID(data1_ID),
        .data2_ID(data2_ID),
        .ImmExt_ID(ImmExt_ID),
        .rs1(instruction_IF[19:15]),
        .rs2(instruction_IF[24:20]),
        .rs1_ID(rs1_ID),
        .rs2_ID(rs2_ID),
        .ALUSrc(ALUSrcHZ),
        .ALUSrc_ID(ALUSrc_ID),
        .rd(instruction_IF[11:7]),
        .rd_ID(rd_ID),
        .B_Zero(B_Zero),
        .B_Zero_ID(B_Zero_ID),
        .ResultSrc_ID(ResultSrc_ID), .Branch_ID(Branch_ID), .Jump_ID(Jump_ID), .JumpReg_ID(JumpReg_ID), .ALUControl_ID(ALUControl_ID),
        .Flush(Flush),
        .isPC_select(isPC_select),
        .isPC_select_ID(isPC_select_ID),
        .PC_next_IF(PC_next_IF),
        .PC_next_ID(PC_next_ID),
        .stall(stall));


    ALU ALU(
            .rdA(rdA), 
            .rdB(rdB), .rst(rst), .clk(clk), 
            .ALUControl(ALUControl_ID), 
            .ALUresult(ALUresult), 
            .Carry(Carry), 
            .Zero(Zero),
            .mul_active(mul_active),
            .div_active(div_active));
    FourXone_mux ForwA_mux (.A(data1_ID), .B(Result), .C(ALUresult_EX), .sel(ForwardA), .Out(data1_ID_ForwA));
    FourXone_mux ForwB_mux (.A(data2_ID), .B(Result), .C(ALUresult_EX), .sel(ForwardB), .Out(rdB_ForwB));
    Multiplexer Multiplex_ALU (
                    .A(rdB_ForwB), 
                    .B(ImmExt_ID), 
                    .sel(ALUSrc_ID), 
                    .Out(rdB));
    PC_ALU_Adder PC_ALU_Adder0 (
                    .A(PC_ID), 
                    .B(ImmExt_ID), 
                    .Sum(PC_Branch));
    Multiplexer Multiplex_jump_branch (
                    .A(PC_Branch), 
                    .B(ALUresult), 
                    .sel(JumpReg_ID),
                    .Out(PC_ALU_Sum));
    multiplex_3x1 MUX_PC_Data (.A(data1_ID_ForwA),
                    .B(PC_ID), 
                    .C('b0),
                    .D('b0),
                    .sel(isPC_select_ID), 
                    .Result(rdA));

    EX_MEM EXMEM(
                .clk(clk), 
                .rst(rst), 
                .ALUresult(ALUresult), 
                .data2(rdB_ForwB), 
                .rd_ID_EX(rd_ID), 
                .RegWrite(RegWrite_ID), 
                .Mem_Con(Mem_Con_ID), 
                .ResultSrc(ResultSrc_ID), 
                .ResultSrc_EX(ResultSrc_EX), 
                .RegWrite_EX(RegWrite_EX), 
                .Mem_Con_EX(Mem_Con_EX), 
                .ALUresult_EX(ALUresult_EX), 
                .data2_EX(data2_EX), 
                .rd_ID_EX_EX(rd_ID_EX_EX),
                .PC_next_ID(PC_next_ID),
                .PC_next_EX(PC_next_EX),
                .stall(stall), 
                .stall_EX(stall_EX));

    mult_div_stall mult_div_stall ( .stall(stall), .rst(rst), 
                                    .mul_active(mul_active), 
                                    .div_active(div_active));

        assign PCSrc = rst ? (Branch_ID & (Zero ^ B_Zero_ID)) | Jump_ID | JumpReg_ID : 1'b0;

    Data_Memory Data_Memory(
                .clk(clk), 
                .MemWrite(Mem_Con_EX[1] && (UART_Mem_wt == 2'b01)), 
                .MemRead(Mem_Con_EX[0]), 
                .MemWriteData(data2_EX), 
                .Rx_Data(FIFO_Rx_Dout),
                .ALUresult(ALUresult_EX), 
                .PC(PC[31:2]),
                .full_Rx(full_Rx),
                .empty_Rx(empty_Rx),
                .Rx_read_en(Rx_read_en),
                .portA(initial_instr),
                .portB(MemReadData));

    MEM_WB MEMWB (
            .clk(clk), 
            .rst(rst), 
            .RegWrite(RegWrite_EX), 
            .MemReadData(MemReadData), 
            .ALUresult(ALUresult_EX), 
            .rd_EXMEM(rd_ID_EX_EX), 
            .ResultSrc(ResultSrc_EX), 
            .ResultSrc_MEM(ResultSrc_MEM), 
            .RegWrite_MEM(RegWrite_MEM), 
            .MemReadData_MEM(MemReadData_MEM), 
            .ALUresult_MEM(ALUresult_MEM), 
            .rd_EXMEM_MEM(rd_EXMEM_MEM),
            .PC_next_EX(PC_next_EX),
            .PC_next_MEM(PC_next_MEM),
            .stall_EX(stall_EX),
            .stall_MEM(stall_MEM));

    multiplex_3x1 multipplex_result0 (
                    .A(ALUresult_MEM), 
                    .B(MemReadData_MEM), 
                    .C(PC_next_MEM), 
                    .D('b0), 
                    .sel(ResultSrc_MEM), 
                    .Result(Result));


    Forwarding_Block FB (
                        .EX_MEM_RegWrite(RegWrite_EX), 
                        .MEM_WB_RegWrite(RegWrite_MEM), 
                        .ID_EX_rs1(rs1_ID), 
                        .ID_EX_rs2(rs2_ID), 
                        .EX_MEM_rd(rd_ID_EX_EX), 
                        .MEM_WB_rd(rd_EXMEM_MEM), 
                        .ForwardA(ForwardA), 
                        .ForwardB(ForwardB));


    Hazard_Detection Haz_Det (.PCWriteEN(PCWriteEN), 
                        .IF_ID_WriteEN(IF_ID_WriteEN), 
                        .NOP(NOP), 
                        .ID_EX_MemRead(Mem_Con_ID[0]), 
                        .ID_EX_rd(rd_ID), 
                        .IF_ID_rs1(instruction_IF[19:15]), 
                        .IF_ID_rs2(instruction_IF[24:20]),
                        .Branch(Branch_ID & (Zero ^ B_Zero_ID)),
                        .Jump(Jump_ID),
                        .JumpReg(JumpReg_ID), 
                        .Flush(Flush));

    
    Ctrl_mux Ctrl_Mux (.RegWrite(RegWrite), 
                        .MemWrite(MemWrite), 
                        .MemRead(MemRead), 
                        .ALUSrc(ALUSrc), 
                        .ResultSrc(ResultSrc), 
                        .Branch(Branch), 
                        .Jump(Jump), 
                        .JumpReg(JumpReg), 
                        .ALUControl(ALUControl), 
                        .sel(NOP), .RegWriteHZ(RegWriteHZ), 
                        .MemWriteHZ(MemWriteHZ), 
                        .MemReadHZ(MemReadHZ), 
                        .ALUSrcHZ(ALUSrcHZ), 
                        .ResultSrcHZ(ResultSrcHZ), 
                        .BranchHZ(BranchHZ), 
                        .JumpHZ(JumpHZ), 
                        .JumpRegHZ(JumpRegHZ), 
                        .ALUControlHZ(ALUControlHZ));


    assign data1 = (RegWrite_MEM && (rd_EXMEM_MEM != 5'b0) && (rd_EXMEM_MEM == instruction_IF[19:15]))
                ? Result      // Forward the final result from WB stage
                : rf_data1;

    assign data2 = (RegWrite_MEM && (rd_EXMEM_MEM != 5'b0) && (rd_EXMEM_MEM == instruction_IF[24:20]))
                ? Result      // Forward the final result from WB stage
                : rf_data2;



    UART_addr_sel UART_addr_sel (.ALUresult(ALUresult_EX),
                                .MemWrite(Mem_Con_EX[1]), .rst(rst),
                                .UART_Mem_wt(UART_Mem_wt),
                                .IO_OUT_temp(data2_EX[15:0]),
                                .IO_OUT(IO_OUT));

    FIFO_UART_top fifo_uart    (.clk(clk), .rst(rst), 
                                .write_en(UART_Mem_wt == 2'b10), 
                                .Rx_read_en(Rx_read_en),
                                .Tx_Din(data2_EX[7:0]), 
                                .Tx_Serial(Tx_Serial),
                                .Rx_Serial(Rx_Serial),
                                .full_Rx(full_Rx),
                                .empty_Rx(empty_Rx),
                                .FIFO_Rx_Dout(FIFO_Rx_Dout));
    

                                
endmodule
   
   
   
   
// initial begin
//     // if ($test$plusargs("trace") || $test$plusargs("waves")) begin
//         $dumpfile("dump.vcd");
//         $dumpvars(0);
//     // end
// end
