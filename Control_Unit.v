`include "RTypeALUControl.v"
// This Control_Unit includes the ALU_Control too.
module Control_Unit(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input Zero, rst,
    output reg  RegWrite,
    output reg  MemWrite,
    output reg  MemRead,
    output reg  ALUSrc,
    output PCSrc,
    output reg [1:0] ResultSrc,
    output reg  Branch,
    output reg  Jump,
    output reg  JumpReg,
    output reg [1:0] ImmType,
    output reg [3:0] ALUControl
);

    wire [3:0] r_type_ALUControl;

    RTypeALUControl r_type_alu_ctrl_inst (
        .funct7(funct7),
        .funct3(funct3),
        .ALUControl(r_type_ALUControl)
    );
    
    assign PCSrc = (rst) ? (Branch | Jump) : 1'b0;
    // assign PCSrc = (rst) ? ((Branch) ? (funct3[0] ? ~Zero : Zero) : 1'b0) : 1'b0;

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
            ImmType    = 2'b00;
            ALUControl = 4'b0000;
        end

        else begin

        case (opcode)
            7'b0110011: begin
                RegWrite   = 1'b1;
                ALUSrc     = 1'b0;
                ResultSrc  = 2'b00;
                ImmType    = 2'b00;
                ALUControl = r_type_ALUControl;
                Branch     = 1'b0;
            end

            7'b0000011: begin
                RegWrite   = 1'b1;
                MemRead    = 1'b1;
                ALUSrc     = 1'b1;
                ResultSrc  = 2'b01;
                ImmType    = 2'b00;
                ALUControl = 4'b0000;
            end

            7'b0010011: begin
                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                ResultSrc  = 2'b00;
                ImmType    = 2'b00;
                Branch     = 1'b0;

                case (funct3)
                    3'b000: ALUControl = 4'b0000;
                    3'b010: ALUControl = 4'b0101;
                    3'b011: ALUControl = 4'b0110;
                    3'b100: ALUControl = 4'b0100;
                    3'b110: ALUControl = 4'b0011;
                    3'b111: ALUControl = 4'b0010;
                    3'b001: begin
                        if (funct7 == 7'b0000000) ALUControl = 4'b0111;
                    end
                    3'b101: begin
                        if (funct7 == 7'b0000000) ALUControl = 4'b1000;
                        else if (funct7 == 7'b0100000) ALUControl = 4'b1001;
                    end
                    default: ALUControl = 4'b0000;
                endcase
            end

            7'b0100011: begin
                MemWrite   = 1'b1;
                ALUSrc     = 1'b1;
                ImmType    = 2'b01;
                ALUControl = 4'b0000;
                RegWrite   = 1'b0;
            end

            7'b1100011: begin // branch operations
                Branch     = 1'b1;
                ALUSrc     = 1'b0;
                ImmType    = 2'b10;
                RegWrite   = 1'b0;

                case (funct3)
                    3'b000: begin // beq
                        ALUControl = 4'b0001; // SUB
                        Branch     = Zero;    // branch if rs1 == rs2
                    end
                    3'b001: begin // bne
                        ALUControl = 4'b0001; // SUB
                        Branch     = ~Zero;   // branch if rs1 != rs2
                    end
                    3'b100: begin // blt (signed)
                        ALUControl = 4'b0101; // SLT (signed)
                        Branch     = ~Zero;
                    end
                    3'b101: begin // bge (signed)
                        ALUControl = 4'b0101; // SLT (signed)
                        Branch     = Zero;
                    end
                    3'b110: begin // bltu (unsigned)
                        ALUControl = 4'b0110; // SLTU (unsigned)
                        Branch     = ~Zero;
                    end
                    3'b111: begin // bgeu (unsigned)
                        ALUControl = 4'b0110; // SLTU (unsigned)
                        Branch     = Zero;
                    end
                    default: begin
                        ALUControl = 4'b0001;
                        Branch     = 1'b0;
                    end
                endcase
            end

            7'b0110111: begin
                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                ResultSrc  = 2'b00;
                ImmType    = 2'b11;
                ALUControl = 4'b0000;
            end

            7'b0010111: begin
                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                ResultSrc  = 2'b00;
                ImmType    = 2'b11;
                ALUControl = 4'b0000;
            end

            7'b1101111: begin
                RegWrite   = 1'b1;
                Jump       = 1'b1;
                ResultSrc  = 2'b10;
                ImmType    = 2'b11;
                ALUControl = 4'b0000;
            end

            7'b1100111: begin
                RegWrite   = 1'b1;
                JumpReg    = 1'b1;
                ALUSrc     = 1'b1;
                ResultSrc  = 2'b10;
                ImmType    = 2'b00;
                ALUControl = 4'b0000;
            end

            default: begin
                RegWrite   = 1'b0;
                Branch     = 1'b0;
                Jump       = 1'b0;
            end
        endcase
    end
    end

endmodule
