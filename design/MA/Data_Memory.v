`default_nettype wire
`timescale 1ns/1ns

module Data_Memory (
    input clk,
    input MemWrite,
    input MemRead,
    input [31:0] MemWriteData,
    input [7:0] Rx_Data,
    input [31:0] ALUresult,
    input [31:0] PC,
    input [2:0] funct3_st_ld,

    input full_Rx, empty_Rx,

    output Rx_read_en,
    output reg [31:0] portA,
    output reg [31:0] portB
);

    reg [31:0] uart_status_reg;
    reg [31:0] boot_rom [0:49];
    reg [31:0] instr_ram [0:1023];
    
    reg [7:0] main_ram0 [0:1200000];
    reg [7:0] main_ram1 [0:1200000];
    reg [7:0] main_ram2 [0:1200000];
    reg [7:0] main_ram3 [0:1200000];


    wire is_boot_rom = (ALUresult[31:12] == 20'h00000);
    wire is_main_ram = (ALUresult[31:28] == 4'h3);
    wire is_Rx_Data = (ALUresult == 32'h80000000);
    wire is_Rx_uart_status = (ALUresult == 32'h80000004);


    assign Rx_read_en = (MemRead && is_Rx_Data);


    wire [5:0] rom_addr = ALUresult[7:2];
    wire [1:0] byte_offset = ALUresult[1:0];
    wire [27:2] ram_addr = ALUresult[27:2];


    wire is_pc_boot = (PC[31:12] == 20'h00000);
    wire is_pc_ram  = (PC[31:28] == 4'h2);
    
    wire [31:0] raw_word = {main_ram3[ram_addr], main_ram2[ram_addr], main_ram1[ram_addr], main_ram0[ram_addr]};

    reg [3:0] byte_en;


    always @(*) begin
        byte_en = 4'b0000;
        if (MemWrite && is_main_ram) begin
            case (funct3_st_ld)
                3'b010: begin // SW: Store Word
                    byte_en = 4'b1111; // Enable all 4 banks
                end
                
                3'b001: begin // SH: Store Halfword (2 bytes)
                    if (byte_offset[1] == 1'b0)
                        byte_en = 4'b0011; // Lower halfword (Banks 1 and 0)
                    else
                        byte_en = 4'b1100; // Upper halfword (Banks 3 and 2)
                end
                
                3'b000: begin // SB: Store Byte (1 byte)
                    case (byte_offset)
                        2'b00: byte_en = 4'b0001; // Enable Bank 0
                        2'b01: byte_en = 4'b0010; // Enable Bank 1
                        2'b10: byte_en = 4'b0100; // Enable Bank 2
                        2'b11: byte_en = 4'b1000; // Enable Bank 3
                    endcase
                end
                default: begin
                    byte_en = 4'b1111;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        // Bank 0
        if (byte_en[0]) 
            main_ram0[ram_addr] <= MemWriteData[7:0];
            
        // Bank 1
        if (byte_en[1]) 
            main_ram1[ram_addr] <= (funct3_st_ld == 3'b000) ? MemWriteData[7:0] : MemWriteData[15:8];
            
        // Bank 2
        if (byte_en[2]) 
            main_ram2[ram_addr] <= (funct3_st_ld == 3'b000) ? MemWriteData[7:0] : MemWriteData[23:16];
            
        // Bank 3
        if (byte_en[3]) 
            main_ram3[ram_addr] <= (funct3_st_ld == 3'b000) ? MemWriteData[7:0] : 
                                   (funct3_st_ld == 3'b001) ? MemWriteData[15:8] : MemWriteData[31:24];
    end


    reg [7:0]  selected_byte;
    reg [15:0] selected_halfword;

    always @(*) begin
        case(byte_offset)
            2'b00: selected_byte = raw_word[7:0];
            2'b01: selected_byte = raw_word[15:8];
            2'b10: selected_byte = raw_word[23:16];
            2'b11: selected_byte = raw_word[31:24];
            default: selected_byte = raw_word[31:24];
        endcase

        case(byte_offset[1])
            1'b0: selected_halfword = raw_word[15:0];
            1'b1: selected_halfword = raw_word[31:16];
            default: selected_halfword = raw_word[15:0];
        endcase
    end


    always @(*) begin
        uart_status_reg = {30'b0, full_Rx, ~empty_Rx};

        if (MemRead) begin
            if(is_boot_rom) begin
                portB = boot_rom[rom_addr];
            end

            else if (is_Rx_Data) begin
                portB = {24'b0, Rx_Data};
            end

            else if(is_Rx_uart_status) begin
                portB = uart_status_reg;
            end

            else if(is_main_ram) begin
                case (funct3_st_ld)
                    3'b010: portB = raw_word;
                    
                    3'b000: portB = {{24{selected_byte[7]}}, selected_byte};
                    
                    3'b100: portB = {24'b0, selected_byte};
                    
                    3'b001: portB = {{16{selected_halfword[15]}}, selected_halfword};
                    
                    3'b101: portB = {16'b0, selected_halfword};
                    
                    default: portB = raw_word;
                endcase
            end

            else begin
                portB = 32'hDEADBEEF;
            end
        end
        else begin
            portB = 32'b0;
        end
    end

    always @(*) begin
        if (is_pc_boot)
            portA = boot_rom[PC[7:2]];
        else if (is_pc_ram)
            portA = instr_ram[PC[11:2]];
        else
            portA = 32'h00000013;
    end

    initial begin
        $readmemh("bootloader_rom.mem", boot_rom);
        $readmemh("instr_mem.mem", instr_ram, 0);
        
        $readmemh("data_mem0.mem", main_ram0);
        $readmemh("data_mem1.mem", main_ram1);
        $readmemh("data_mem2.mem", main_ram2);
        $readmemh("data_mem3.mem", main_ram3);    
    end

endmodule
