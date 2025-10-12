// RTypeALUControl.v
// Decodes funct3 and funct7 for R-Type instructions, including M-extension.

module RTypeALUControl(
    input [6:0] funct7,     
    input [2:0] funct3,     
    output reg [4:0] ALUControl // Changed output to 5 bits
    // output reg ALUSrc
);

    always @(*) begin
        ALUControl = 5'b00000; // Default to ADD operation
        // ALUSrc = 1'b0;

        // Check for M-extension instructions (funct7 = 7'b0000001)
        if (funct7 == 7'b0000001) begin
            case (funct3)
                3'b000: ALUControl = 5'b10000; // MUL
                3'b001: ALUControl = 5'b10001; // MULH
                3'b010: ALUControl = 5'b10010; // MULHU
                3'b011: ALUControl = 5'b10011; // MULHSU
                3'b100: ALUControl = 5'b10100; // DIV
                3'b101: ALUControl = 5'b10101; // DIVU
                3'b110: ALUControl = 5'b10110; // REM
                3'b111: ALUControl = 5'b10111; // REMU
                default: ALUControl = 5'b00000; // Should not happen
            endcase
        end
        // Standard I-extension R-Type instructions
        else begin
            case (funct3)
                3'b000: begin
                    if (funct7 == 7'b0000000)      ALUControl = 5'b00000; // ADD
                    else if (funct7 == 7'b0100000) ALUControl = 5'b00001; // SUB
                end
                3'b001: begin  
                    if (funct7 == 7'b0000000)      ALUControl = 5'b00111; // SLL
                end
                3'b010: begin  
                    if (funct7 == 7'b0000000)      ALUControl = 5'b00101; // SLT
                end
                3'b011: begin  
                    if (funct7 == 7'b0000000)      ALUControl = 5'b00110; // SLTU
                end
                3'b100: begin  
                    if (funct7 == 7'b0000000)      ALUControl = 5'b00100; // XOR
                end
                3'b101: begin    
                    if (funct7 == 7'b0000000)      ALUControl = 5'b01000; // SRL
                    else if (funct7 == 7'b0100000) ALUControl = 5'b01001; // SRA
                end
                3'b110: begin  
                    if (funct7 == 7'b0000000)      ALUControl = 5'b00011; // OR
                end
                3'b111: begin  
                    if (funct7 == 7'b0000000)      ALUControl = 5'b00010; // AND
                end
                default: ALUControl = 5'b00000;
            endcase
        end
    end

endmodule