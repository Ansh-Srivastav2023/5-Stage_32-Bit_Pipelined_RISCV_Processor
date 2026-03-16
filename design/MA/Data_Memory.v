module Data_Memory (
    input clk,
    input MemWrite,
    input MemRead,
    input [31:0] MemWriteData,
    input [31:0] ALUresult,
    input [31:0] PC,
    output reg [31:0] portA,
    output reg [31:0] portB
);

    reg [31:0] boot_rom [0:255];

    reg [31:0] main_ram [0:16383];

    wire is_boot_rom = (ALUresult[31:12] == 20'h00000);
    wire is_main_ram = (ALUresult[31:28] == 4'h2);


    wire [7:0] rom_addr = ALUresult[9:2];
    wire [13:0] ram_addr = ALUresult[15:2];
    wire [1:0] byte_offset = ALUresult[1:0];


    wire is_pc_boot = (PC[31:12] == 20'h00000);
    wire is_pc_ram  = (PC[31:28] == 4'h2);

    always @(posedge clk) begin
        if (MemWrite)
            if(is_main_ram)
                main_ram[ram_addr] <= MemWriteData;
    end
    
    always @(*) begin
        if (MemRead) begin
            if(is_boot_rom) begin
                portB = boot_rom[rom_addr];
            end
            else if(is_main_ram) begin
                case (byte_offset)
                    2'b00: portB = main_ram[ram_addr];
                    2'b01: portB = main_ram[ram_addr] >> 8;
                    2'b10: portB = main_ram[ram_addr] >> 16;
                    2'b11: portB = main_ram[ram_addr] >> 24;
                endcase
            end

            else begin
                portB = 32'hDEADBEEF;
            end
        end else begin
            portB = 32'b0;
        end
    end

    always @(*) begin
        if (is_pc_boot)
            portA = boot_rom[PC[9:2]];
        else if (is_pc_ram)
            portA = main_ram[PC[15:2]];
        else
            portA = 32'h00000013;
    end

    initial begin
        $readmemh("/media/anx/New_Volume/Importants/Verilog/open_sta/design/MA/bootloader_rom.hex", boot_rom);
        $readmemh("/media/anx/New_Volume/Importants/Verilog/open_sta/design/MA/instr_mem.hex", main_ram, 0);
        $readmemh("/media/anx/New_Volume/Importants/Verilog/open_sta/design/MA/data_mem.hex", main_ram, 8192);
    end

endmodule
