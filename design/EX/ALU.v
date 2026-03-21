`default_nettype wire
`timescale 1ns/1ps

module ALU #(parameter bits = 32)(
    input rst, clk,
    input [4:0] ALUControl,
    input signed [bits-1:0] rdA,
    input signed [bits-1:0] rdB,
    output Carry, Zero,
    output reg signed [bits-1:0] ALUresult,
    output wire mul_active, div_active   
);
    
    wire [4:0] shamt;
    wire [2*bits-1:0] mul_result;
    reg Cout;

    assign Carry = Cout;
    assign shamt = rdB[4:0];
    assign Zero  = ~|ALUresult;

    wire is_sub = (ALUControl == 5'b00001);
    wire [bits-1:0] add_sub_in_b = rdB ^ {bits{is_sub}};
    wire [bits-1:0] add_sub_res = rdA + add_sub_in_b + is_sub;

    always @(*) begin
        ALUresult = 32'b0;
        Cout = 1'b0;

        case (ALUControl)
            // Arithmetic / Logic
            5'b00000: {Cout, ALUresult} = {1'b0, add_sub_res};
            5'b00001: ALUresult = add_sub_res;
            5'b00010: ALUresult = rdA & rdB;
            5'b00011: ALUresult = rdA | rdB;
            5'b00100: ALUresult = rdA ^ rdB;
            5'b00101: ALUresult = ($signed(rdA) < $signed(rdB)) ? 32'd1 : 'd0;
            5'b00110: ALUresult = ($unsigned(rdA) < $unsigned(rdB)) ? {32'd1} : 'd0;
            5'b00111: ALUresult = rdA << shamt;
            5'b01000: ALUresult = rdA >> shamt;
            5'b01001: ALUresult = $signed(rdA) >>> shamt;

            // Multiplication Outputs
            5'b10000: ALUresult = mul_result[bits-1:0];         // MUL
            5'b10001: ALUresult = mul_result[2*bits-1:bits];    // MULH
            5'b10010: ALUresult = mul_result[2*bits-1:bits];    // MULHU
            5'b10011: ALUresult = mul_result[2*bits-1:bits];    // MULHSU

            // Division Outputs
            5'b10100: ALUresult = mul_result[bits-1:0];         // DIV
            5'b10101: ALUresult = mul_result[bits-1:0];         // DIVU
            5'b10110: ALUresult = mul_result[2*bits-1:bits];    // REM
            5'b10111: ALUresult = mul_result[2*bits-1:bits];    // REMU
            
            default: ALUresult  = {(bits){1'b0}};
        endcase
    end
   
    parameter IDLE = 0, RUN_MUL = 1, RUN_DIV = 2, L_MUL_SHIFT = 3, L_DIV_SHIFT = 4, DIV_SUB = 5, STOP = 6;

    reg Q_1;
    reg [4:0] count;
    reg [2:0] state;
    reg [bits-1:0] B, Q, A;

    assign mul_result = {A, Q};

    assign mul_active = (ALUControl[4] && state != STOP) ? 1'b1 : 1'b0;
    assign div_active = (ALUControl[4] && state != STOP) ? 1'b1 : 1'b0;

    always @(posedge clk or negedge rst) begin
    if(!rst) begin
        state <= IDLE;
    end 
    else begin 
        case(state)
            IDLE: begin
                A <= 'b0;
                Q_1 <= 1'b0;
                count <= bits[4:0];
                
                if(ALUControl[4:2] == 3'b100 && mul_active == 1) begin
                    Q <= rdA;
                    B <= rdB;
                    state <= RUN_MUL;
                end
                
                else if(ALUControl[4:2] == 3'b101 && div_active == 1) begin
                    B <= rdB;
                    Q <= rdA;
                    state <= L_DIV_SHIFT;
                end
                
                else begin
                    state <= IDLE;
                end
            end

            RUN_MUL: begin
                if({Q[0], Q_1} == 2'b10) begin
                    A <= A-B;
                end

                else if({Q[0], Q_1} == 2'b01) begin
                    A <= A+B;
                end

                else begin
                    A <= A;
                end
                
                state <= L_MUL_SHIFT;
            end
            
            L_MUL_SHIFT: begin
                {A, Q, Q_1} <= $signed({A, Q, Q_1} >>> 1);
                count <= count - 1;
    
                if(count == 1) begin
                    state <= STOP;
                end

                else begin
                    state <= RUN_MUL;
                end
            end

            L_DIV_SHIFT: begin
                {A, Q} <= {A, Q} << 1;
                state <= DIV_SUB;
            end

            DIV_SUB: begin
                A <= A - B;
                state <= RUN_DIV;
            end

            RUN_DIV: begin
                if(A[bits-1]) begin
                    Q[0] <= 1'b0;
                    A <= A + B;
                end
                else begin
                    Q[0] <= 1'b1;
                end

                count <= count - 1'b1;

                if (count == 1) begin
                    state <= STOP;
                end
                else begin
                    state <= L_DIV_SHIFT;
                end
            end

            STOP: begin
                state <= IDLE;
            end
            
            default: begin
                state <= IDLE;
            end
        endcase
    end
    end

endmodule


module PC_ALU_Adder (A, B, Sum);

    input [31:0] A, B;
    output [31:0] Sum;

    assign Sum = A + B;
endmodule 
