module Imm_Extend (instruction, ImmType, ImmExt);

    input [31:0] instruction;
    input [2:0] ImmType;

    output reg [31:0] ImmExt;

    wire [11:0] i_imm = instruction[31:20];
    wire [11:0] s_imm = {instruction[31:25], instruction[11:7]};
    wire [12:0] b_imm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    wire [19:0] u_imm = instruction[31:12];
    wire [19:0] j_imm = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};

    always @(*) begin
        ImmExt = 32'b0;
        case (ImmType)
            3'b000: ImmExt = {{20{i_imm[11]}}, i_imm};
            3'b001: ImmExt = {{20{s_imm[11]}}, s_imm};
            3'b010: ImmExt = {{19{b_imm[12]}}, b_imm};
            3'b011: ImmExt = {u_imm, 12'b0};
            3'b100: ImmExt = {{11{j_imm[19]}}, j_imm, 1'b0};
            default: ImmExt = 32'b0;
        endcase
    end

endmodule