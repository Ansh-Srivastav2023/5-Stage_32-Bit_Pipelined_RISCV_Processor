# ===== RISC-V bare-metal build + Testbench simulation =====

# Toolchain (xPack riscv-none-elf in /opt/riscv/bin)
CROSS    ?= riscv-none-elf
CC       := $(CROSS)-gcc
OBJDUMP  := $(CROSS)-objdump
OBJCOPY  := $(CROSS)-objcopy
SIZE     := $(CROSS)-size

# Architecture
ARCH     ?= rv32im
ABI      ?= ilp32
ARCH_FLAGS = -march=$(ARCH) -mabi=$(ABI)

# Paths
GCC_FILE_PATH := /media/anx/New_Volume/Importants/Verilog/Branch_Improved/riscv_gcc
RTL_FILE_PATH := /media/anx/New_Volume/Importants/Verilog/Branch_Improved/rtl_files

# Compiler / Linker flags
CFLAGS  = $(ARCH_FLAGS) -O2 -Wall -Wextra -ffreestanding \
          -fdata-sections -ffunction-sections -c
ASFLAGS = $(ARCH_FLAGS) -ffreestanding -c
LDFLAGS = $(ARCH_FLAGS) -T $(GCC_FILE_PATH)/link.ld -nostdlib -nostartfiles \
          -Wl,--gc-sections --specs=nosys.specs

# Sources / outputs
C_SRC   = $(GCC_FILE_PATH)/tst.c
ASM_SRC = $(GCC_FILE_PATH)/crt0.S
OBJ     = $(C_SRC:.c=.o) $(ASM_SRC:.S=.o)

ELF     = $(GCC_FILE_PATH)/tst.elf
BIN     = $(GCC_FILE_PATH)/tst.bin
DISASM  = $(GCC_FILE_PATH)/disasm.txt

HEX     = $(RTL_FILE_PATH)/instr_mem.hex
TB      = $(RTL_FILE_PATH)/Testbench.v
SIMV    = $(RTL_FILE_PATH)/simv
SIM_OUT = $(RTL_FILE_PATH)/sim_output.txt

IVERILOG ?= iverilog
VVP      ?= vvp

.PHONY: all clean size dump bin hex simulate

# Default target
all: $(DISASM) $(HEX) simulate

# ---------- Firmware build ----------

$(ELF): $(OBJ) $(GCC_FILE_PATH)/link.ld
	$(CC) $(LDFLAGS) -o $@ $(OBJ)
	$(SIZE) $@

$(DISASM): $(ELF)
	$(OBJDUMP) -d -S $< > $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

# Create HEX as 32-bit little-endian words, one per line
$(HEX): $(BIN)
	@mkdir -p $(dir $@)
	od -An -tx4 -v -w4 $< | sed 's/ //g' > $@

# ---------- Compile rules (path-aware) ----------
# NOTE: % cannot match '/', so make path-aware patterns
$(GCC_FILE_PATH)/%.o: $(GCC_FILE_PATH)/%.c
	$(CC) $(CFLAGS) -o $@ $<

$(GCC_FILE_PATH)/%.o: $(GCC_FILE_PATH)/%.S
	$(CC) $(ASFLAGS) -o $@ $<

# ---------- Testbench simulation ----------

simulate: $(HEX) $(TB)
	@echo "Running Verilog Testbench..."
	@mkdir -p $(dir $(SIMV)) $(dir $(SIM_OUT))
	$(IVERILOG) -g2012 -o $(SIMV) $(TB)
	$(VVP) $(SIMV) > sim_output.txt 2>&1

# ---------- Handy utilities ----------

size: $(ELF)
	$(SIZE) $(ELF)

dump: $(ELF)
	$(OBJDUMP) -d -S $(ELF) | less

bin: $(BIN)
hex: $(HEX)

# ---------- Clean ----------

clean:
	rm -f $(OBJ) $(ELF) $(BIN) $(DISASM) $(SIM_OUT) $(SIMV) $(HEX)
