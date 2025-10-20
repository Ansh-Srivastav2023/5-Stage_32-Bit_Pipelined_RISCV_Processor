module ALU(
    input signed [31:0] rdA,
    input signed [31:0] rdB,
    input [4:0]  ALUControl, // Expanded to 5 bits for M-extension
    output reg signed [31:0] ALUresult,
    output Carry, Zero
);

    wire [4:0] shamt;
    reg Cout;
    
    wire signed [63:0] mul_result;

    assign shamt = rdB[4:0];
    assign Carry = Cout;
    assign Zero  = ~|ALUresult; // Zero is true if ALUresult is all zeros

    assign mul_result = rdA * rdB;
    
    always @(*) begin
        ALUresult = 32'b0;
        Cout = 1'b0;

        case (ALUControl)
            // --- Original RV32I Operations ---
            5'b00000: {Cout, ALUresult} = rdA + rdB;
            5'b00001: ALUresult = rdA - rdB;
            5'b00010: ALUresult = rdA & rdB;
            5'b00011: ALUresult = rdA | rdB;
            5'b00100: ALUresult = rdA ^ rdB;
            5'b00101: ALUresult = ($signed(rdA) < $signed(rdB)) ? 32'd1 : 32'd0;
            5'b00110: ALUresult = ($unsigned(rdA) < $unsigned(rdB)) ? 32'd1 : 32'd0;
            5'b00111: ALUresult = rdA << shamt;
            5'b01000: ALUresult = rdA >> shamt;
            5'b01001: ALUresult = $signed(rdA) >>> shamt;
            // 5'b01001: ALUresult = 

            // --- New RV32M Operations ---
            // Multiplication
            5'b10000: ALUresult = mul_result[31:0];         // MUL: Lower 32 bits of signed multiplication
            5'b10001: ALUresult = mul_result[63:32];        // MULH: Upper 32 bits of signed multiplication
            5'b10010: ALUresult = ($unsigned(rdA) * $unsigned(rdB)) >> 32; // MULHU: Upper 32 bits of unsigned multiplication
            5'b10011: ALUresult = ($signed(rdA) * $unsigned(rdB)) >> 32; // MULHSU: Upper 32 bits of signed*unsigned
            
            // Division
            5'b10100: ALUresult = $signed(rdA) / $signed(rdB); // DIV: Signed Division
            5'b10101: ALUresult = $unsigned(rdA) / $unsigned(rdB); // DIVU: Unsigned Division

            // Remainder
            5'b10110: ALUresult = $signed(rdA) % $signed(rdB); // REM: Signed Remainder
            5'b10111: ALUresult = $unsigned(rdA) % $unsigned(rdB); // REMU: Unsigned Remainder

            default: ALUresult = 32'b0;
        endcase
    end

endmodule



module PC_ALU_Adder (A, B, Sum);

    input [31:0] A, B;
    output [31:0] Sum;

    assign Sum = A + B;
endmodule 


module Multiplexer_ALUCtrl(A, B, sel, Out);

    input [3:0] A, B;
    input sel;
    output [3:0] Out;

    assign Out = sel ? B : A;

endmodule