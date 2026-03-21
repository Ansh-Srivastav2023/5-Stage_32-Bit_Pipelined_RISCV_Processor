`default_nettype wire
`timescale 1ns/1ps

module Control_Unit(
    input  [6:0] opcode,
    input  [2:0] funct3,
    input  [6:0] funct7,
    input        rst,

    output reg        RegWrite,
    output reg        RegRead,
    output reg        MemWrite,
    output reg        MemRead,
    output reg        ALUSrc,
    output reg [1:0]  ResultSrc,
    output reg        Branch,
    output reg        Jump,
    output reg        JumpReg,
    output reg [2:0]  ImmType,
    output reg [4:0]  ALUControl,
    output reg        B_Zero,
    output reg [1:0]  isPC_select
  );

  wire [4:0] r_type_ALUControl;

  RTypeALUControl r_type_alu_ctrl_inst (
                    .funct7(funct7),
                    .funct3(funct3),
                    .ALUControl(r_type_ALUControl)
                  );

  always @(*)
  begin

    // ================= DEFAULTS =================
    RegWrite    = 1'b0;
    RegRead     = 1'b0;
    MemWrite    = 1'b0;
    MemRead     = 1'b0;
    ALUSrc      = 1'b0;
    ResultSrc   = 2'b00;
    Branch      = 1'b0;
    Jump        = 1'b0;
    JumpReg     = 1'b0;
    ImmType     = 3'b000;
    ALUControl  = 5'b00000;
    B_Zero      = 1'b0;
    isPC_select = 2'b00;

    case (opcode)

      // ================= R-Type =================
      7'b0110011:
      begin
        RegWrite   = 1'b1;
        RegRead    = 1'b1;
        ALUControl = r_type_ALUControl;
      end

      // ================= Load =================
      7'b0000011:
      begin
        RegWrite   = 1'b1;
        RegRead    = 1'b1;
        MemRead    = 1'b1;
        ALUSrc     = 1'b1;
        ResultSrc  = 2'b01;
      end

      // ================= I-Type =================
      7'b0010011:
      begin
        RegWrite   = 1'b1;
        RegRead    = 1'b1;
        ALUSrc     = 1'b1;

        case (funct3)
          3'b000:
            ALUControl = 5'b00000;
          3'b010:
            ALUControl = 5'b00101;
          3'b011:
            ALUControl = 5'b00110;
          3'b100:
            ALUControl = 5'b00100;
          3'b110:
            ALUControl = 5'b00011;
          3'b111:
            ALUControl = 5'b00010;

          3'b001:
          begin
            if (funct7 == 7'b0000000)
              ALUControl = 5'b00111;
            else
              ALUControl = 5'b00000;   // KEEP ELSE
          end

          3'b101:
          begin
            if (funct7 == 7'b0000000)
              ALUControl = 5'b01000;
            else if (funct7 == 7'b0100000)
              ALUControl = 5'b01001;
            else
              ALUControl = 5'b00000;   // KEEP ELSE
          end

          default:
            ALUControl = 5'b00000;   // KEEP DEFAULT
        endcase
      end

      // ================= Store =================
      7'b0100011:
      begin
        MemWrite = 1'b1;
        RegRead  = 1'b1;
        ALUSrc   = 1'b1;
        ImmType  = 3'b001;
      end

      // ================= Branch =================
      7'b1100011:
      begin
        Branch  = 1'b1;
        RegRead = 1'b1;
        ImmType = 3'b010;

        case (funct3)
          3'b000:
            ALUControl = 5'b00001;

          3'b001:
          begin
            ALUControl = 5'b00001;
            B_Zero     = 1'b1;
          end

          3'b100:
          begin
            ALUControl = 5'b00101;
            B_Zero     = 1'b1;
          end

          3'b101:
            ALUControl = 5'b00101;

          3'b110:
          begin
            ALUControl = 5'b00110;
            B_Zero     = 1'b1;
          end

          3'b111:
            ALUControl = 5'b00110;

          default:
          begin
            ALUControl = 5'b00001;   // KEEP DEFAULT
            Branch     = 1'b0;
          end
        endcase
      end

      // ================= LUI =================
      7'b0110111:
      begin
        RegWrite    = 1'b1;
        RegRead     = 1'b1;
        ALUSrc      = 1'b1;
        ImmType     = 3'b011;
        isPC_select = 2'b10;
      end

      // ================= AUIPC =================
      7'b0010111:
      begin
        RegWrite    = 1'b1;
        RegRead     = 1'b1;
        ALUSrc      = 1'b1;
        ImmType     = 3'b011;
        Branch      = 1'b1;
        isPC_select = 2'b01;
      end

      // ================= JAL =================
      7'b1101111:
      begin
        RegWrite   = 1'b1;
        Jump       = 1'b1;
        ResultSrc  = 2'b10;
        ImmType    = 3'b100;
      end

      // ================= JALR =================
      7'b1100111:
      begin
        RegWrite   = 1'b1;
        RegRead    = 1'b1;
        JumpReg    = 1'b1;
        ALUSrc     = 1'b1;
        ResultSrc  = 2'b10;
      end

      // ================= DEFAULT OPCODE =================
      default:
      begin
        RegWrite    = 1'b0;
        RegRead     = 1'b0;
        MemWrite    = 1'b0;
        MemRead     = 1'b0;
        ALUSrc      = 1'b0;
        ResultSrc   = 2'b00;
        Branch      = 1'b0;
        Jump        = 1'b0;
        JumpReg     = 1'b0;
        ImmType     = 3'b000;
        ALUControl  = 5'b00000;
        B_Zero      = 1'b0;
        isPC_select = 2'b00;
      end

    endcase
  end

endmodule
