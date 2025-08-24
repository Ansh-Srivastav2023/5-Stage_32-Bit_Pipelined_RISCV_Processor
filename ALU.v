module ALU(
    input signed [31:0] rdA,
    input signed [31:0] rdB,
    input [3:0]  ALUControl,
    output reg signed [31:0] ALUresult,
    output Carry, Zero
);

    wire [4:0] shamt;
    reg Cout;
    assign shamt = rdB[4:0];

    assign Carry = Cout;
    assign Zero  = ~|ALUresult;

    always @(*) begin
        ALUresult = 'b0;

        case (ALUControl)
            4'b0000: begin
                {Cout, ALUresult} = rdA + rdB;
            end

            4'b0001: begin
                ALUresult = rdA - rdB;
            end

            4'b0010: begin
                ALUresult = rdA & rdB;
            end

            4'b0011: begin
                ALUresult = rdA | rdB;
            end

            4'b0100: begin
                ALUresult = rdA ^ rdB;
            end

            4'b0101: begin
                ALUresult = ($signed(rdA) < $signed(rdB)) ? {31'b0, 1'b1} : 'b0;
            end

            4'b0110: begin
                ALUresult = ($unsigned(rdA) < $unsigned(rdB)) ? {31'b0, 1'b1} : 'b0;
            end

            4'b0111: begin
                ALUresult = rdA << shamt;
            end

            4'b1000: begin
                ALUresult = rdA >> shamt;
            end

            4'b1001: begin
                ALUresult = $signed(rdA) >>> shamt;
            end

            default: begin
                ALUresult = 32'b0;
            end
        endcase
    end

endmodule




module PC_ALU_Adder (A, B, Sum);

    input [31:0] A, B;
    output [31:0] Sum;

    assign Sum = A + B;
endmodule //PC_ALU_Asser

module Multiplexer_ALUCtrl(A, B, sel, Out);

    input [3:0] A, B;
    input sel;
    output [3:0] Out;

    assign Out = sel ? B : A;

endmodule