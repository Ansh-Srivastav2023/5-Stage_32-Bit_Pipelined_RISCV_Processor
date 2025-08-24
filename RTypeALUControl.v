module RTypeALUControl(
    input [6:0] funct7,     
    input [2:0] funct3,     
    output reg [3:0] ALUControl 
);

    always @(*) begin
        ALUControl = 4'b0000; 

        case (funct3)
            3'b000: begin
                if (funct7 == 7'b0000000) begin
                    ALUControl = 4'b0000;  
                end else if (funct7 == 7'b0100000) begin
                    ALUControl = 4'b0001;  
                end
            end
            3'b001: begin  
                if (funct7 == 7'b0000000) begin
                    ALUControl = 4'b0111;  
                end
            end
            3'b010: begin  
                if (funct7 == 7'b0000000) begin
                    ALUControl = 4'b0101;
                end
            end
            3'b011: begin  
                if (funct7 == 7'b0000000) begin
                    ALUControl = 4'b0110;
                end
            end
            3'b100: begin  
                if (funct7 == 7'b0000000) begin
                    ALUControl = 4'b0100;
                end
            end
            3'b101: begin    
                if (funct7 == 7'b0000000) begin
                    ALUControl = 4'b1000;
                end else if (funct7 == 7'b0100000) begin
                    ALUControl = 4'b1001;
                end
            end
            3'b110: begin  
                if (funct7 == 7'b0000000) begin
                    ALUControl = 4'b0011;  
                end
            end
            3'b111: begin  
                if (funct7 == 7'b0000000) begin
                    ALUControl = 4'b0010;  
                end
            end
            default: begin
                ALUControl = 4'b0000;
            end
        endcase
    end

endmodule
