// mul_result[2*bits-1:bits]  ------>   rem
// mul_result[bits-1:0]  b    ------>   quo

module ALU #(parameter bits = 32)(
    input rst, clk,
    input [4:0] ALUControl,
    input signed [bits-1:0] rdA,
    input signed [bits-1:0] rdB,
    output Carry, Zero,
    output reg signed [bits-1:0] ALUresult,
    output reg mul_done, div_done   
);

    parameter IDLE = 3'b000; 
    parameter ADDS = 3'b001; 
    parameter SHFT = 3'b010; 
    parameter DONE = 3'b011;
    parameter RUN  = 3'b100;
    parameter FNSH = 3'b101;
    
    reg [2:0] state;
    wire [4:0] shamt;
    reg [$clog2(bits):0] k;
    reg [2*bits-1:0] mul_result;
    reg [bits-1:0] a_reg, b_reg;
    reg temp_sign, mul_carry, Cout, a_sign;

    assign Carry = Cout;
    assign shamt = rdB[4:0];
    assign Zero  = ~|ALUresult;
    
    wire [bits:0] rem_nxt = {(mul_result[2*bits-1:bits]), (a_reg[bits-1])};
    wire [bits:0] sub     = rem_nxt + ~{1'b0, b_reg} + 1'b1;    

    wire is_add = (ALUControl == 5'b00000);
    wire is_sub = (ALUControl == 5'b00001);
    wire [bits-1:0] add_sub_in_b = rdB ^ {bits{is_sub}};
    wire [bits-1:0] add_sub_res = rdA + add_sub_in_b + is_sub;

    wire is_mul_op = (ALUControl[4] && !ALUControl[2]); 
    wire is_div_op = (ALUControl[4] &&  ALUControl[2]); 

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
   
    always @(posedge clk) begin
        if (!rst) begin
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
                
                // --- MULTIPLICATION START LOGIC ---
                if (is_mul_op) begin 
                    k           <= 'b0;
                    state       <= ADDS;
                    // Determine operands based on signed/unsigned opcodes
                    a_reg       <= (ALUControl == 5'b10010) ? rdA : ((rdA[bits-1]) ? -rdA : rdA);                   
                    b_reg       <= (ALUControl == 5'b10010 || ALUControl == 5'b10011) ? rdB : ((rdB[bits-1]) ? -rdB : rdB);
                    // Determine sign of result
                    temp_sign   <= (ALUControl == 5'b10010) ? 1'b0 : (ALUControl == 5'b10011) ? rdA[bits-1] : rdA[bits-1]^rdB[bits-1];
                    mul_carry   <= 1'b0;
                    mul_result  <= {{(bits){1'b0}}, {(ALUControl == 5'b10010 || ALUControl == 5'b10011) ? rdB : ((rdB[bits-1]) ? -rdB : rdB)}}; 
                end

                // --- DIVISION START LOGIC ---
                else if (is_div_op) begin
                    // Handle Divide by Zero
                    if (rdB == 'b0) begin
                        state   <= FNSH;
                        mul_result[bits-1:0]       <= {bits{1'b1}}; // -1 in some architectures
                        mul_result[2*bits-1:bits]  <= rdA;
                    end
                    else if (rdA == {1'b1, {(bits-1){1'b0}}} && rdB == {bits{1'b1}}) begin
                        state   <= FNSH;
                        mul_result[bits-1:0]       <= {1'b1, {(bits-1){1'b0}}};
                        mul_result[2*bits-1:bits]  <= 'b0;
                    end
                    else begin
                        k       <= bits;
                        a_reg   <= (ALUControl == 5'b10101 || ALUControl == 5'b10111) ? rdA : (rdA[bits-1] ? -rdA : rdA);
                        b_reg   <= (ALUControl == 5'b10101 || ALUControl == 5'b10111) ? rdB : (rdB[bits-1] ? -rdB : rdB);
                        state   <= RUN;
                        
                        a_sign  <= (ALUControl == 5'b10101 || ALUControl == 5'b10111) ? 1'b0 : rdA[bits-1]; 
                        temp_sign  <= (ALUControl == 5'b10101 || ALUControl == 5'b10111) ? 1'b0 : (rdA[bits-1] ^ rdB[bits-1]);
                        
                        mul_result  <= 'b0;
                    end
                end
            end
            
            // --- MUL STATES ---
            ADDS: begin
                if (mul_result[0]) begin
                    {mul_carry, mul_result[2*bits-1 : bits]} <= mul_result[2*bits-1 : bits] + a_reg;
                end else begin
                    mul_carry <= 1'b0;
                end
                state <= SHFT;
            end
            
            SHFT: begin
                mul_result <= {mul_carry, mul_result[2*bits-2:0]} >> 1; // Fixed width indexing
                k <= k + 1;
                if (k == bits-1) begin
                    state <= DONE;
                end
                else
                    state <= ADDS;
            end
            
            RUN: begin
                if (!sub[bits]) begin
                     mul_result[2*bits-1:bits] <= sub[bits-1:0];
                     mul_result[bits-1:0] <= (mul_result[bits-1:0] << 1) | 32'b1;
                end else begin
                     mul_result[2*bits-1:bits] <= rem_nxt[bits-1:0];
                     mul_result[bits-1:0] <= (mul_result[bits-1:0] << 1) | 32'b0;
                end
        
                k <= k - 1;
                if(k == 1) begin
                    state <= FNSH;
                end
                else begin
                    state <= RUN;
                end
                
                a_reg <= a_reg << 1; 
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

            default: state <= IDLE;
            endcase
        end
    end
endmodule


module PC_ALU_Adder (A, B, Sum);

    input [31:0] A, B;
    output [31:0] Sum;

    assign Sum = A + B;
endmodule 
