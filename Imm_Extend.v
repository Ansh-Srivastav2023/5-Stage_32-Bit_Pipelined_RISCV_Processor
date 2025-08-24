module Imm_Extend (instruction, ImmType, ImmExt);

    input [31:0] instruction;
    input [1:0] ImmType;

    output reg [31:0] ImmExt;

    wire [11:0] i_imm;
    assign i_imm = instruction[31:20];

    wire [11:0] s_imm;
    assign s_imm = {instruction[31:25], instruction[11:7]};

    wire [11:0] b_imm;
    assign b_imm = {instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    
    wire [19:0] u_imm;
    assign u_imm = instruction[31:12];

    always @(*) begin
        ImmExt = 32'b0;
        case (ImmType)
            2'b00: ImmExt = {{20{i_imm[11]}}, i_imm};
            2'b01: ImmExt = {{20{s_imm[11]}}, s_imm};
            2'b10: ImmExt = {{20{b_imm[11]}}, b_imm};
            2'b11: ImmExt = {u_imm, 12'b0};
            default : begin
                ImmExt = 32'b0;
            end
        endcase
    end

endmodule //Imm_Extend