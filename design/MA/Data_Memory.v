`default_nettype wire
`timescale 1ns/1ps

module Data_Memory (
    input clk,
    input MemWrite,
    input MemRead,
    input [31:0] MemWriteData,
    input [7:0] Rx_Data,
    input [31:0] ALUresult,
    input [31:0] PC,

    input full_Rx, empty_Rx,

    output Rx_read_en,
    output reg [31:0] portA,
    output reg [31:0] portB
  );

  reg [31:0] uart_status_reg;
  reg [31:0] boot_rom [0:49];
  reg [31:0] main_ram [0:1023];


  wire is_boot_rom = (ALUresult[31:12] == 20'h00000);
  wire is_main_ram = (ALUresult[31:28] == 4'h2);
  wire is_Rx_Data = (ALUresult == 32'h80000000);
  wire is_Rx_uart_status = (ALUresult == 32'h80000004);


  assign Rx_read_en = (MemRead && is_Rx_Data);


  wire [5:0] rom_addr = ALUresult[7:2];
  wire [9:0] ram_addr = ALUresult[11:2];
  wire [1:0] byte_offset = ALUresult[1:0];


  wire is_pc_boot = (PC[31:12] == 20'h00000);
  wire is_pc_ram  = (PC[31:28] == 4'h2);


  always @(posedge clk)
  begin
    if (MemWrite)
      if(is_main_ram)
        main_ram[ram_addr] <= MemWriteData;
  end

  always @(*)
  begin
    uart_status_reg = {30'b0, full_Rx, ~empty_Rx};

    if (MemRead)
    begin
      if(is_boot_rom)
      begin
        portB = boot_rom[rom_addr];
      end

      else if (is_Rx_Data)
      begin
        portB = {24'b0, Rx_Data};
      end

      else if(is_Rx_uart_status)
      begin
        portB = uart_status_reg;
      end

      else if(is_main_ram)
      begin
        case (byte_offset)
          2'b00:
            portB = main_ram[ram_addr];
          2'b01:
            portB = main_ram[ram_addr] >> 8;
          2'b10:
            portB = main_ram[ram_addr] >> 16;
          2'b11:
            portB = main_ram[ram_addr] >> 24;
        endcase
      end

      else
      begin
        portB = 32'hDEADBEEF;
      end
    end
    else
    begin
      portB = 32'b0;
    end
  end

  always @(*)
  begin
    if (is_pc_boot)
      portA = boot_rom[PC[7:2]];
    else if (is_pc_ram)
      portA = main_ram[PC[11:2]];
    else
      portA = 32'h00000013;
  end

  initial
  begin
    $readmemh("bootloader_rom.mem", boot_rom);
    // $readmemh("instr_mem.mem", main_ram, 0);
    $readmemh("data_mem.mem", main_ram, 512);

  end

endmodule
