`include "RTypeALUControl.v"

module Control_Unit(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input Zero, rst,
    output reg  RegWrite,
    output reg  MemWrite,
    output reg  MemRead,
    output reg  ALUSrc,
    output reg [1:0] ResultSrc,
    output reg  Branch,
    output reg  Jump,
    output reg  JumpReg,
    output reg [2:0] ImmType,
    output reg [4:0] ALUControl,
    output reg B_Zero, // Branch Zero Checker
    output reg [1:0] isPC_select // Branch Zero Checker
);

    wire [4:0] r_type_ALUControl; // Changed from [3:0] to [4:0]

    RTypeALUControl r_type_alu_ctrl_inst (
        .funct7(funct7),
        .funct3(funct3),
        .ALUControl(r_type_ALUControl)
    );


    always @(*) begin
        if(~rst) begin
            RegWrite   = 1'b0;
            MemWrite   = 1'b0;
            MemRead    = 1'b0;
            ALUSrc     = 1'b0;
            ResultSrc  = 2'b00;
            Branch     = 1'b0;
            Jump       = 1'b0;
            JumpReg    = 1'b0;
            ImmType    = 3'b000;
            ALUControl = 5'b00000;
            B_Zero     = 1'b0;
            isPC_select= 2'b00;
        end
        else begin
            // The rest of this file remains identical to your original code.
            case (opcode)
                7'b0110011: begin // R-Type (includes M-extension now)
                    RegWrite   = 1'b1;
                    ALUSrc     = 1'b0;
                    ResultSrc  = 2'b00;
                    ImmType    = 3'b000;
                    ALUControl = r_type_ALUControl; // This now passes the 5-bit control signal
                    Branch     = 1'b0;
                    Jump       = 1'b0;
                    JumpReg    = 1'b0;
                    MemRead    = 1'b0;
                    isPC_select= 2'b00;
                    
                end
                7'b0000011: begin // Load
                    RegWrite   = 1'b1;
                    MemRead    = 1'b1;
                    ALUSrc     = 1'b1;
                    ResultSrc  = 2'b01;
                    ImmType    = 3'b000;
                    ALUControl = 5'b00000;
                    MemWrite   = 1'b0;
                    Branch     = 1'b0;
                    isPC_select= 2'b00;
                end
                7'b0010011: begin // I-Type
                    RegWrite   = 1'b1;
                    ALUSrc     = 1'b1;
                    ResultSrc  = 2'b00;
                    ImmType    = 3'b000;
                    Branch     = 1'b0;
                    MemWrite   = 1'b0;
                    isPC_select= 2'b00;
                    case (funct3)
                        3'b000: ALUControl = 5'b00000;
                        3'b010: ALUControl = 5'b00101;
                        3'b011: ALUControl = 5'b00110;
                        3'b100: ALUControl = 5'b00100;
                        3'b110: ALUControl = 5'b00011;
                        3'b111: ALUControl = 5'b00010;
                        3'b001: begin
                            if (funct7 == 7'b0000000) ALUControl = 5'b00111;
                        end
                        3'b101: begin
                            if (funct7 == 7'b0000000) ALUControl = 5'b01000;
                            else if (funct7 == 7'b0100000) ALUControl = 5'b01001;
                        end
                        default: ALUControl = 5'b00000;
                    endcase
                end
                7'b0100011: begin // Store
                    MemWrite   = 1'b1;
                    ALUSrc     = 1'b1;
                    ImmType    = 3'b001;
                    ALUControl = 5'b00000;
                    RegWrite   = 1'b0;
                    MemRead    = 1'b0;
                    Branch     = 1'b0;
                    isPC_select= 2'b00;
                end
                7'b1100011: begin // Branch
                    Branch     = 1'b1;
                    ALUSrc     = 1'b0;
                    ImmType    = 3'b010;
                    RegWrite   = 1'b0;
                    MemRead    = 1'b0;
                    isPC_select= 2'b00;
                    case (funct3)
                        3'b000: begin //beq
                            ALUControl = 5'b00001;
                            B_Zero     = 1'b0;
                            // Branch     = Zero;
                        end
                        3'b001: begin //bne
                            ALUControl = 5'b00001;
                            B_Zero     = 1'b1;
                            // Branch     = ~Zero;
                        end
                        3'b100: begin //blt
                            ALUControl = 5'b00101;
                            B_Zero     = 1'b1;
                            // Branch     = ~Zero;
                        end
                        3'b101: begin //bge
                            ALUControl = 5'b00101;
                            B_Zero     = 1'b0;
                            // Branch     = Zero;
                        end
                        3'b110: begin //bltu
                            ALUControl = 5'b00110;
                            B_Zero     = 1'b1;
                            // Branch     = ~Zero;
                        end
                        3'b111: begin //bgue
                            ALUControl = 5'b00110;
                            B_Zero     = 1'b0;
                            // Branch     = Zero;
                        end
                        default: begin
                            ALUControl = 5'b00001;
                            // B_Zero     = 1'b1;
                            Branch     = 1'b0;
                        end
                    endcase
                end
                7'b0110111: begin // LUI
                    RegWrite   = 1'b1;
                    ALUSrc     = 1'b1;
                    ResultSrc  = 2'b00;
                    ImmType    = 3'b011;
                    ALUControl = 5'b00000;
                    Branch     = 1'b0;
                    isPC_select= 2'b10;
                end
                7'b0010111: begin // AUIPC
                    RegWrite   = 1'b1;
                    ALUSrc     = 1'b1;
                    ResultSrc  = 2'b00;
                    ImmType    = 3'b011;
                    ALUControl = 5'b00000;
                    MemRead    = 1'b0;
                    Branch     = 1'b1;
                    isPC_select= 2'b01;
                end
                7'b1101111: begin // JAL
                    RegWrite   = 1'b1;
                    Jump       = 1'b1;
                    ResultSrc  = 2'b10;
                    ImmType    = 3'b100;
                    ALUControl = 5'b00000;
                    ALUSrc     = 1'b0;
                    MemRead    = 1'b0;
                    Branch     = 1'b0;
                    isPC_select= 2'b00;
                end
                7'b1100111: begin // JALR
                    RegWrite   = 1'b1;
                    JumpReg    = 1'b1;
                    ALUSrc     = 1'b1;
                    ResultSrc  = 2'b10;
                    ImmType    = 3'b000;
                    ALUControl = 5'b00000;
                    MemRead    = 1'b0;
                    Branch     = 1'b0;
                    isPC_select= 2'b00;
                end
                default: begin
                    ALUSrc     = 1'b0;
                    RegWrite   = 1'b0;
                    Branch     = 1'b0;
                    Jump       = 1'b0;
                    JumpReg    = 1'b0;
                    MemWrite   = 1'b0;
                    MemRead    = 1'b0;
                    isPC_select= 2'b00;
                end
            endcase
        end
    end

endmodule