riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -Ttext 0x00000000 -o bootloader.elf bootloader.s

riscv-none-elf-objcopy -O binary bootloader.elf bootloader.bin

hexdump -v -e '1/4 "%08x\n"' bootloader.bin > bootloader_rom.hex

mv bootloader_rom.hex /media/anx/New_Volume/Importants/Verilog/open_sta/memory_files