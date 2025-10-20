module Decompressor (
    input  [15:0] c_instr,  // Compressed 16-bit instruction
    output reg [31:0] r_instr   // Resulting 32-bit standard instruction
);

    // Standard RISC-V Opcodes
    localparam OPCODE_LOAD   = 7'b0000011;
    localparam OPCODE_STORE  = 7'b0100011;
    localparam OPCODE_BRANCH = 7'b1100011;
    localparam OPCODE_JALR   = 7'b1100111;
    localparam OPCODE_JAL    = 7'b1101111;
    localparam OPCODE_OP_IMM = 7'b0010011;
    localparam OPCODE_OP     = 7'b0110011;
    localparam OPCODE_LUI    = 7'b0110111;
    localparam OPCODE_AUIPC  = 7'b0010111;

    // Field extraction from the 16-bit instruction
    wire [1:0] op     = c_instr[1:0];
    wire [2:0] funct3 = c_instr[15:13];
    wire [4:0] rd     = c_instr[11:7];
    wire [4:0] rs1    = c_instr[11:7];
    wire [4:0] rs2    = c_instr[6:2];

    // Registers in the x8-x15 range
    wire [4:0] rd_prime  = {2'b01, c_instr[4:2]};
    wire [4:0] rs1_prime = {2'b01, c_instr[9:7]};
    wire [4:0] rs2_prime = {2'b01, c_instr[4:2]};

    // Reconstructed 32-bit instruction fields
    reg [31:0] imm32;
    reg [4:0]  final_rs1, final_rs2, final_rd;
    reg [2:0]  final_funct3;
    reg [6:0]  final_funct7;
    reg [6:0]  final_opcode;

    always @(*) begin
        // --- Default assignments ---
        imm32        = 32'b0;
        final_rs1    = 5'b0;
        final_rs2    = 5'b0;
        final_rd     = 5'b0;
        final_funct3 = 3'b0;
        final_funct7 = 7'b0;
        final_opcode = 7'b0; // Defaults to an illegal instruction

        // --- Main decompressor logic ---
        case ({funct3, op})
            // Quadrant 0
            {3'b000, 2'b00}: begin // C.ADDI4SPN
                imm32        = {22'b0, c_instr[10:7], c_instr[12:11], c_instr[5], c_instr[6], 2'b0};
                final_rs1    = 5'd2; // sp
                final_rd     = rd_prime;
                final_funct3 = 3'b000; // ADDI
                final_opcode = OPCODE_OP_IMM;
            end
            {3'b010, 2'b00}: begin // C.LW
                imm32        = {25'b0, c_instr[5], c_instr[12:10], c_instr[6], 2'b0};
                final_rs1    = rs1_prime;
                final_rd     = rd_prime;
                final_funct3 = 3'b010; // LW
                final_opcode = OPCODE_LOAD;
            end
            {3'b110, 2'b00}: begin // C.SW
                imm32        = {25'b0, c_instr[5], c_instr[12:10], c_instr[6], 2'b0};
                final_rs1    = rs1_prime;
                final_rs2    = rs2_prime;
                final_funct3 = 3'b010; // SW
                final_opcode = OPCODE_STORE;
            end

            // Quadrant 1
            {3'b000, 2'b01}: begin // C.ADDI
                imm32        = {{26{c_instr[12]}}, c_instr[12], c_instr[6:2]};
                final_rs1    = rd;
                final_rd     = rd;
                final_funct3 = 3'b000; // ADDI
                final_opcode = OPCODE_OP_IMM;
            end
            {3'b001, 2'b01}: begin // C.JAL (RV32)
                imm32        = {{20{c_instr[12]}}, c_instr[8], c_instr[10:9], c_instr[6], c_instr[7], c_instr[2], c_instr[11], c_instr[5:3], 1'b0};
                final_rd     = 5'd1; // ra
                final_opcode = OPCODE_JAL;
            end
            {3'b010, 2'b01}: begin // C.LI
                imm32        = {{26{c_instr[12]}}, c_instr[12], c_instr[6:2]};
                final_rs1    = 5'd0; // x0
                final_rd     = rd;
                final_funct3 = 3'b000; // ADDI
                final_opcode = OPCODE_OP_IMM;
            end
            {3'b011, 2'b01}: begin
                if (rd == 5'd2) begin // C.ADDI16SP
                    imm32        = {{22{c_instr[12]}}, c_instr[12], c_instr[4:3], c_instr[5], c_instr[2], c_instr[6], 4'b0};
                    final_rs1    = 5'd2; // sp
                    final_rd     = 5'd2; // sp
                    final_funct3 = 3'b000; // ADDI
                    final_opcode = OPCODE_OP_IMM;
                end else if (rd != 5'd0) begin // C.LUI
                    imm32        = {{14{c_instr[12]}}, c_instr[12], c_instr[6:2], 12'b0};
                    final_rd     = rd;
                    final_opcode = OPCODE_LUI;
                end
            end
            {3'b100, 2'b01}: begin
                case (c_instr[11:10])
                    2'b00: begin // C.SRLI
                        imm32        = {26'b0, c_instr[12], c_instr[6:2]};
                        final_rs1    = rs1_prime;
                        final_rd     = rd_prime;
                        final_funct3 = 3'b101; // SRLI
                        final_opcode = OPCODE_OP_IMM;
                    end
                    2'b01: begin // C.SRAI
                        imm32        = {26'b0, c_instr[12], c_instr[6:2]};
                        final_rs1    = rs1_prime;
                        final_rd     = rd_prime;
                        final_funct3 = 3'b101; // SRAI
                        final_funct7 = 7'b0100000;
                        final_opcode = OPCODE_OP_IMM;
                    end
                    2'b10: begin // C.ANDI
                        imm32        = {{26{c_instr[12]}}, c_instr[12], c_instr[6:2]};
                        final_rs1    = rs1_prime;
                        final_rd     = rd_prime;
                        final_funct3 = 3'b111; // ANDI
                        final_opcode = OPCODE_OP_IMM;
                    end
                    2'b11: begin
                        final_rs1 = rs1_prime;
                        final_rs2 = rs2_prime;
                        final_rd  = rd_prime;
                        final_opcode = OPCODE_OP;
                        case ({c_instr[12], c_instr[6:5]})
                            3'b000: {final_funct7, final_funct3} = {7'b0000000, 3'b000}; // SUB
                            3'b001: {final_funct7, final_funct3} = {7'b0000000, 3'b100}; // XOR
                            3'b010: {final_funct7, final_funct3} = {7'b0000000, 3'b110}; // OR
                            3'b011: {final_funct7, final_funct3} = {7'b0000000, 3'b111}; // AND
                        endcase
                    end
                endcase
            end
            {3'b101, 2'b01}: begin // C.J
                imm32        = {{20{c_instr[12]}}, c_instr[8], c_instr[10:9], c_instr[6], c_instr[7], c_instr[2], c_instr[11], c_instr[5:3], 1'b0};
                final_rd     = 5'd0;
                final_opcode = OPCODE_JAL;
            end
            {3'b110, 2'b01}: begin // C.BEQZ
                imm32        = {{23{c_instr[12]}}, c_instr[12], c_instr[6:5], c_instr[2], c_instr[11:10], c_instr[4:3], 1'b0};
                final_rs1    = rs1_prime;
                final_rs2    = 5'd0; // x0
                final_funct3 = 3'b000; // BEQ
                final_opcode = OPCODE_BRANCH;
            end
            {3'b111, 2'b01}: begin // C.BNEZ
                imm32        = {{23{c_instr[12]}}, c_instr[12], c_instr[6:5], c_instr[2], c_instr[11:10], c_instr[4:3], 1'b0};
                final_rs1    = rs1_prime;
                final_rs2    = 5'd0; // x0
                final_funct3 = 3'b001; // BNE
                final_opcode = OPCODE_BRANCH;
            end

            // Quadrant 2
            {3'b000, 2'b10}: begin // C.SLLI
                imm32        = {26'b0, c_instr[12], c_instr[6:2]};
                final_rs1    = rd;
                final_rd     = rd;
                final_funct3 = 3'b001; // SLLI
                final_opcode = OPCODE_OP_IMM;
            end
            {3'b010, 2'b10}: begin // C.LWSP
                imm32        = {24'b0, c_instr[3:2], c_instr[12], c_instr[6:4], 2'b0};
                final_rs1    = 5'd2; // sp
                final_rd     = rd;
                final_funct3 = 3'b010; // LW
                final_opcode = OPCODE_LOAD;
            end
            {3'b100, 2'b10}: begin
                if (c_instr[12] == 1'b0) begin
                    if (rs2 == 5'd0) begin // C.JR
                        final_rs1    = rs1;
                        final_opcode = OPCODE_JALR;
                    end else begin // C.MV
                        final_rs1    = rs2;
                        final_rd     = rd;
                        final_opcode = OPCODE_OP;
                    end
                end else begin
                    if (rs2 == 5'd0) begin // C.JALR
                        final_rs1    = rs1;
                        final_rd     = 5'd1; // ra
                        final_opcode = OPCODE_JALR;
                    end else begin // C.ADD
                        final_rs1    = rd;
                        final_rs2    = rs2;
                        final_rd     = rd;
                        final_opcode = OPCODE_OP;
                    end
                end
            end
            {3'b110, 2'b10}: begin // C.SWSP
                imm32        = {24'b0, c_instr[8:7], c_instr[12:9], 2'b0};
                final_rs1    = 5'd2; // sp
                final_rs2    = rs2;
                final_funct3 = 3'b010; // SW
                final_opcode = OPCODE_STORE;
            end
        endcase

        // --- Final Assembly of the 32-bit instruction ---
        // This structure maps the decoded fields to the standard R/I/S/B/U/J formats
        case(final_opcode)
            OPCODE_OP:     r_instr = {final_funct7, final_rs2, final_rs1, final_funct3, final_rd, final_opcode}; // R-Type
            OPCODE_OP_IMM: r_instr = {imm32[11:0], final_rs1, final_funct3, final_rd, final_opcode}; // I-Type
            OPCODE_LOAD:   r_instr = {imm32[11:0], final_rs1, final_funct3, final_rd, final_opcode}; // I-Type
            OPCODE_STORE:  r_instr = {imm32[11:5], final_rs2, final_rs1, final_funct3, imm32[4:0], final_opcode}; // S-Type
            OPCODE_BRANCH: r_instr = {{imm32[12],imm32[10:5]}, final_rs2, final_rs1, final_funct3, {imm32[4:1],imm32[11]}, final_opcode}; // B-Type
            OPCODE_LUI:    r_instr = {imm32[31:12], final_rd, final_opcode}; // U-Type
            OPCODE_AUIPC:  r_instr = {imm32[31:12], final_rd, final_opcode}; // U-Type
            OPCODE_JAL:    r_instr = {{imm32[20],imm32[10:1],imm32[11],imm32[19:12]}, final_rd, final_opcode}; // J-Type
            OPCODE_JALR:   r_instr = {imm32[11:0], final_rs1, final_funct3, final_rd, final_opcode}; // I-Type
            default:       r_instr = 32'b0; // Illegal instruction
        endcase
    end
endmodule

// module test;
// reg [15:0] c_instr;
// wire [31:0] r_instr;

//     Decompressor dut (c_instr, r_instr);
//     initial begin
//         c_instr = 16'h1141;
//         #40
//         $display("%h", r_instr);
//         $finish;
//     end

// endmodule