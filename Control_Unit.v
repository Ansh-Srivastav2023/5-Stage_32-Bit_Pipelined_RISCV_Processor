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
    // Wire to connect the RTypeALUControl sub-module's output
    wire [3:0] r_type_ALUControl;

    // Instantiate the RTypeALUControl sub-module
    RTypeALUControl r_type_alu_ctrl_inst (
        .funct7(funct7), // Connects the funct7 input to the sub-module
        .funct3(funct3), // Connects the funct3 input to the sub-module
        .ALUControl(r_type_ALUControl) // Connects the sub-module's output to the wire
    );
    
    // Assigns the PCSrc signal based on the reset and branch/jump conditions.
    // PCSrc is the Program Counter Source, which determines if the next PC is from a branch/jump or the next sequential instruction.
    assign PCSrc = (rst) ? (Branch | Jump) : 1'b0;
    
    // This combinational block determines all the control signals based on the current instruction's opcode and function fields.
    // The @(*) sensitivity list means it re-evaluates whenever any input changes.
    always @(*) begin
        // Reset condition: all control signals are set to a default, inactive state.
        if(~rst) begin
            RegWrite   = 1'b0; // Don't write to the register file
            MemWrite   = 1'b0; // Don't write to data memory
            MemRead    = 1'b0;  // Don't read from data memory
            ALUSrc     = 1'b0;  // ALU second operand is from a register
            ResultSrc  = 2'b00; // Result comes from the ALU
            Branch     = 1'b0;  // No branch
            Jump       = 1'b0;  // No unconditional jump
            JumpReg    = 1'b0;  // No Jump and Link with Register
            ImmType    = 2'b00; // Immediate type for R-type and I-type (lw)
            ALUControl = 4'b0000; // Default ALU operation
        end
        // Main logic for decoding instructions
        else begin
            case (opcode)
                // R-Type Instructions (e.g., add, sub, and)
                7'b0110011: begin
                    RegWrite   = 1'b1;  // Always write back the result to a register
                    ALUSrc     = 1'b0;  // ALU second operand is from a register (rs2)
                    ResultSrc  = 2'b00; // Result comes from the ALU
                    ImmType    = 2'b00; // Immediate not used
                    ALUControl = r_type_ALUControl; // ALU operation is determined by funct3/7 in the sub-module
                    Branch     = 1'b0;  // Not a branch instruction
                end
                // I-Type Instructions (Load) (lw)
                7'b0000011: begin
                    RegWrite   = 1'b1;  // Always write back the result to a register
                    MemRead    = 1'b1;  // Read from data memory
                    ALUSrc     = 1'b1;  // ALU second operand is an immediate value
                    ResultSrc  = 2'b01; // Result comes from data memory
                    ImmType    = 2'b00; // Immediate type for I-type
                    ALUControl = 4'b0000; // ALU performs an addition (to calculate memory address)
                end
                // I-Type Instructions (e.g., addi, slli)
                7'b0010011: begin
                    RegWrite   = 1'b1;  // Always write back the result to a register
                    ALUSrc     = 1'b1;  // ALU second operand is an immediate value
                    ResultSrc  = 2'b00; // Result comes from the ALU
                    ImmType    = 2'b00; // Immediate type for I-type
                    Branch     = 1'b0;
                    // Nested case to determine the specific ALU operation based on funct3/funct7
                    case (funct3)
                        3'b000: ALUControl = 4'b0000; // ADDI
                        3'b010: ALUControl = 4'b0101; // SLTI
                        3'b011: ALUControl = 4'b0110; // SLTIU
                        3'b100: ALUControl = 4'b0100; // XORI
                        3'b110: ALUControl = 4'b0011; // ORI
                        3'b111: ALUControl = 4'b0010; // ANDI
                        3'b001: begin // SLLI
                            if (funct7 == 7'b0000000) ALUControl = 4'b0111;
                        end
                        3'b101: begin // SRLI, SRAI
                            if (funct7 == 7'b0000000) ALUControl = 4'b1000;
                            else if (funct7 == 7'b0100000) ALUControl = 4'b1001;
                        end
                        default: ALUControl = 4'b0000; // Default
                    endcase
                end
                // S-Type Instructions (Store) (sw)
                7'b0100011: begin
                    MemWrite   = 1'b1;  // Write to data memory
                    ALUSrc     = 1'b1;  // ALU second operand is an immediate value
                    ImmType    = 2'b01; // Immediate type for S-type
                    ALUControl = 4'b0000; // ALU performs an addition (to calculate memory address)
                    RegWrite   = 1'b0;  // Do not write back to a register
                end
                // B-Type Instructions (Branch) (e.g., beq, bne)
                7'b1100011: begin 
                    Branch     = 1'b1;  // This is a branch instruction
                    ALUSrc     = 1'b0;  // ALU second operand is from a register (rs2)
                    ImmType    = 2'b10; // Immediate type for B-type
                    RegWrite   = 1'b0;  // Do not write back to a register
                    // Nested case to determine the specific ALU operation and branch condition
                    case (funct3)
                        3'b000: begin // BEQ
                            ALUControl = 4'b0001; // ALU performs subtraction to check for equality
                            Branch     = Zero;     // Branch if the Zero flag is set (i.e., rs1 == rs2)
                        end
                        3'b001: begin // BNE
                            ALUControl = 4'b0001; // ALU performs subtraction
                            Branch     = ~Zero;    // Branch if the Zero flag is NOT set (i.e., rs1 != rs2)
                        end
                        3'b100: begin // BLT (signed)
                            ALUControl = 4'b0101; // ALU performs a signed less than comparison
                            Branch     = ~Zero;    // Branch if rs1 < rs2
                        end
                        3'b101: begin // BGE (signed)
                            ALUControl = 4'b0101; // ALU performs a signed less than comparison
                            Branch     = Zero;     // Branch if rs1 >= rs2
                        end
                        3'b110: begin // BLTU (unsigned)
                            ALUControl = 4'b0110; // ALU performs an unsigned less than comparison
                            Branch     = ~Zero;    // Branch if rs1 < rs2
                        end
                        3'b111: begin // BGEU (unsigned)
                            ALUControl = 4'b0110; // ALU performs an unsigned less than comparison
                            Branch     = Zero;     // Branch if rs1 >= rs2
                        end
                        default: begin
                            ALUControl = 4'b0001;
                            Branch     = 1'b0;
                        end
                    endcase
                end
                // U-Type (LUI)
                7'b0110111: begin
                    RegWrite   = 1'b1;  // Write back to a register
                    ALUSrc     = 1'b1;  // ALU second operand is an immediate value
                    ResultSrc  = 2'b00; // Result comes from the ALU
                    ImmType    = 2'b11; // Immediate type for U-type
                    ALUControl = 4'b0000; // ALU performs an addition (effectively just passes the immediate)
                end
                // U-Type (AUIPC)
                7'b0010111: begin
                    RegWrite   = 1'b1;  // Write back to a register
                    ALUSrc     = 1'b1;  // ALU second operand is an immediate value
                    ResultSrc  = 2'b00; // Result comes from the ALU
                    ImmType    = 2'b11; // Immediate type for U-type
                    ALUControl = 4'b0000; // ALU performs an addition (adds PC to immediate)
                end
                // J-Type (JAL)
                7'b1101111: begin
                    RegWrite   = 1'b1;  // Write back to a register (the return address)
                    Jump       = 1'b1;  // This is an unconditional jump
                    ResultSrc  = 2'b10; // Result is the next PC address
                    ImmType    = 2'b11; // Immediate type for J-type
                    ALUControl = 4'b0000; // Not used
                end
                // I-Type (JALR)
                7'b1100111: begin
                    RegWrite   = 1'b1;  // Write back to a register (the return address)
                    JumpReg    = 1'b1;  // This is a jump with a register offset
                    ALUSrc     = 1'b1;  // ALU second operand is an immediate value
                    ResultSrc  = 2'b10; // Result is the next PC address
                    ImmType    = 2'b00; // Immediate type for I-type
                    ALUControl = 4'b0000; // ALU performs an addition (rs1 + immediate)
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