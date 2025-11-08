// mul_result[2*bits-1:bits]  ------>   rem
// mul_result[bits-1:0]  b    ------>   quo

module ALU #(parameter bits = 32)(
    input rst, clk,
    input [4:0] ALUControl, // Expanded to 5 bits for M-extension
    input signed [bits-1:0] rdA,
    input signed [bits-1:0] rdB,
    output Carry, Zero,
    output reg signed [bits-1:0] ALUresult,
    output reg mul_done, div_done
);

    // multiplication
    parameter IDLE = 3'b000; 
    parameter ADDS = 3'b001; 
    parameter SHFT = 3'b010; 
    parameter DONE = 3'b011;

    // division
    parameter RUN  = 3'b100;
    parameter FNSH = 3'b101;
    
    reg [2:0] state;
    wire[4:0] shamt;
    reg [$clog2(bits):0] k;
    reg [2*bits-1:0] mul_result;
    reg [bits-1:0] a_reg, b_reg;
    reg temp_sign, mul_carry, Cout, a_sign;
    assign Carry          = Cout;
    assign shamt          = rdB[4:0];
    assign Zero           = ~|ALUresult;
    
    
    wire [bits:0] sub     = rem_nxt + ~b_reg + 1'b1;    
    wire [bits:0] rem_nxt = {(mul_result[2*bits-1:bits]), (a_reg[bits-1])};

    wire is_sub = (ALUControl == 5'b00001);
    wire [bits-1:0] add_sub_in_b = rdB ^ {bits{is_sub}};
    wire [bits-1:0] add_sub_res = rdA + add_sub_in_b + is_sub;

    reg start_div, start_mul;
    // reg mul_done, div_done;

    always @(*) begin
        ALUresult = 32'b0;
        Cout = 1'b0;

        case (ALUControl)
            5'b00000: {Cout, ALUresult} = add_sub_res;
            5'b00001: ALUresult = add_sub_res;
            5'b00010: ALUresult = rdA & rdB;
            5'b00011: ALUresult = rdA | rdB;
            5'b00100: ALUresult = rdA ^ rdB;
            5'b00101: ALUresult = ($signed(rdA) < $signed(rdB)) ? 1'd1 : 'd0;
            5'b00110: ALUresult = ($unsigned(rdA) < $unsigned(rdB)) ? {1'd1} : 'd0;
            5'b00111: ALUresult = rdA << shamt;
            5'b01000: ALUresult = rdA >> shamt;
            5'b01001: ALUresult = $signed(rdA) >>> shamt;

            5'b10000: begin
                ALUresult = mul_result[bits-1:0];         // MUL: Lower 32 bits of signed multiplication
                start_mul = mul_done ? 1'b0 : 1'b1;
            end
            5'b10001: begin
                ALUresult = mul_result[2*bits-1:bits];    // MULH: Upper 32 bits of signed multiplication
                start_mul = mul_done ? 1'b0 : 1'b1;
            end
            5'b10010: begin
                ALUresult = mul_result[2*bits-1:bits];    // MULHU: Upper 32 bits of unsigned multiplication
                start_mul = mul_done ? 1'b0 : 1'b1;
            end
            5'b10011: begin
                ALUresult = mul_result[2*bits-1:bits];    // MULHSU: Upper 32 bits of signed*unsigned
                start_mul = mul_done ? 1'b0 : 1'b1;
            end
            5'b10100: begin
                ALUresult = mul_result[bits-1:0];         // DIV: Signed Division
                start_div = div_done ? 1'b0 : 1'b1;
            end
            5'b10101: begin
                ALUresult = mul_result[bits-1:0];         // DIVU: Unsigned Division
                start_div = div_done ? 1'b0 : 1'b1;
            end

            5'b10110: begin
                ALUresult = mul_result[2*bits-1:bits]; // REM: Signed Remainder
                start_div = div_done ? 1'b0 : 1'b1;
            end
            5'b10111: begin
                ALUresult = mul_result[2*bits-1:bits]; // REMU: Unsigned Remainder
                start_div = div_done ? 1'b0 : 1'b1;
            end
            
            default: ALUresult  = {(bits){1'b0}};

        endcase
    end
   
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            k           <= 'b0;
            a_reg       <= 'b0;
            b_reg       <= 'b0;
            state       <= IDLE;
            a_sign      <= 1'b0;
            mul_done    <= 1'b0;
            div_done    <= 1'b0;
            mul_carry   <= 1'b0;
            temp_sign   <= 1'b0;
            mul_result  <= 'b0;
        end
        else begin
            
            case (state)
            IDLE: begin
                div_done <= 1'b0;
                mul_done <= 1'b0;
                if (start_mul) begin 
                    k           <= 'b0;
                    state       <= ADDS;
                    a_reg       <= (ALUControl == 5'b10010) ? rdA : ((rdA[bits-1]) ? -rdA : rdA);                   
                    b_reg       <= (ALUControl == 5'b10010 || ALUControl == 5'b10011) ? rdB : ((rdB[bits-1]) ? -rdB : rdB);
                    temp_sign   <= (ALUControl == 5'b10010) ? 1'b0 : (ALUControl == 5'b10011) ? rdA[bits-1] : rdA[bits-1]^rdB[bits-1];
                    mul_carry   <= 1'b0;
                    mul_result  <= {{(bits){1'b0}}, {(ALUControl == 5'b10010 || ALUControl == 5'b10011) ? rdB : ((rdB[bits-1]) ? -rdB : rdB)}}; 
                end

                if (start_div) begin
                    if (rdB == 'b0) begin
                        state   <= FNSH;
                        mul_result[bits-1:0]     <= 'b1;
                        mul_result[2*bits-1:bits]     <= rdA;
                    end
                    else if (rdA == {1'b1, {(bits-1){1'b0}}} && rdB == {bits{1'b1}}) begin
                        state   <= FNSH;
                        mul_result[bits-1:0]     <= {1'b1, {(bits-1){1'b0}}};
                        mul_result[2*bits-1:bits]     <= 'b0;
                    end
                    else begin
                        k       <= {bits};
                        a_reg   <= rdA[bits-1] ? -rdA : rdA;
                        state   <= RUN;
                        b_reg   <= rdB[bits-1] ? -rdB : rdB;
                        a_sign  <= (ALUControl == 5'b10101) ? 1'b0 : rdA[bits-1];
                        temp_sign  <= (ALUControl == 5'b10100) ? (rdA[bits-1] ^ rdB[bits-1]) : 1'b0;
                        mul_result  <= 'b0;
                    end
                end

            end
            
            ADDS: begin
                if (mul_result[0]) begin
                    {mul_carry, mul_result[2*bits-1 : bits]} <= mul_result[2*bits-1 : bits] + a_reg;
                end else begin
                    mul_carry <= 1'b0;
                end
                state       <= SHFT;
            end
            
            SHFT: begin
                mul_result  <= {mul_carry, mul_result} >> 1;
                k <= k + 1;
                if (k == bits-1'b1) begin
                    state   <= DONE;
                end
                else
                    state   <= ADDS;
            end
            
            RUN: begin
                a_reg   <= a_reg << 1;
        
                if (!sub[bits]) begin
                    mul_result[2*bits-1:bits] <= sub[bits-1:0];
                    mul_result[bits-1:0] <= (mul_result[bits-1:0] << 1) | 1'b1;
                end
                
                else begin
                    mul_result[bits-1:0] <= (mul_result[bits-1:0] << 1) | 1'b0;                
                    mul_result[2*bits-1:bits] <= rem_nxt[bits-1:0];
                end
        
                k <= k - 1'b1;
                if(k  == 1'b1) begin
                    state <= FNSH;
                end
                else begin
                    state <= RUN;
                end
            end
        
            FNSH: begin
                state <= IDLE;
                div_done <= 1'b1;
                mul_result[bits-1:0] <= temp_sign ? -(mul_result[bits-1:0]) : (mul_result[bits-1:0]);
                mul_result[2*bits-1:bits] <= a_sign ? -(mul_result[2*bits-1:bits]) : (mul_result[2*bits-1:bits]);
            end

            DONE: begin
                state       <= IDLE; 
                mul_done    <= 1'b1; 
                mul_result  <= temp_sign ? -mul_result : mul_result;
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


module Multiplexer_ALUCtrl(A, B, sel, Out);

    input [3:0] A, B;
    input sel;
    output [3:0] Out;

    assign Out = sel ? B : A;

endmodule