CROSS     ?= riscv-none-elf
CC        := $(CROSS)-gcc
OBJDUMP   := $(CROSS)-objdump
OBJCOPY   := $(CROSS)-objcopy
SIZE      := $(CROSS)-size

ARCH      ?= rv32im
ABI       ?= ilp32
ARCHFLAGS = -march=$(ARCH) -mabi=$(ABI)

GCC_DIR := /media/anx/New_Volume/Importants/Verilog/Pipelined_Processor/riscv_gcc
RTL_DIR := /media/anx/New_Volume/Importants/Verilog/Pipelined_Processor/top_module
PARNET_DIR := $(abspath $(CURDIR)/..)


C_SRC    = $(GCC_DIR)/tst.c
ASM_SRC  = $(GCC_DIR)/crt0.S

OBJ      = $(C_SRC:.c=.o) $(ASM_SRC:.S=.o)

ELF      = $(GCC_DIR)/tst.elf
BIN      = $(GCC_DIR)/tst.bin
DISASM   = $(GCC_DIR)/disasm.txt

IMEM_HEX = $(PARNET_DIR)/design/MA/instr_mem.hex
DMEM_HEX = $(PARNET_DIR)/design/MA/data_mem.hex

TB       = $(RTL_DIR)/Testbench.v
SIMV     = $(RTL_DIR)/simv
SIM_OUT  = $(RTL_DIR)/sim_output.txt

IVERILOG ?= iverilog
VVP      ?= vvp


CFLAGS  = $(ARCHFLAGS) -O2 -Wall -Wextra -ffreestanding \
          -fdata-sections -ffunction-sections -c

ASFLAGS = $(ARCHFLAGS) -ffreestanding -c

LDFLAGS = $(ARCHFLAGS) -T $(GCC_DIR)/link.ld -nostdlib -nostartfiles \
          --specs=nosys.specs

.PHONY: all clean simulate size dump

all: $(DISASM) $(IMEM_HEX) $(DMEM_HEX)


$(ELF): $(OBJ) $(GCC_DIR)/link.ld
	$(CC) $(LDFLAGS) -o $@ $(OBJ)
	$(SIZE) $@

$(DISASM): $(ELF)
	$(OBJDUMP) -d -S $< > $@

$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@


$(IMEM_HEX): $(ELF)
	@echo "Generating Instruction Memory HEX (32-bit words)..."
	@mkdir -p $(dir $@)
	
	# 1. Extract BOTH .init and .text sections to binary
	#    Note: Since they are contiguous in your memory map (0x00 and 0x10),
	#    this creates one smooth binary file.
	$(OBJCOPY) -O binary \
		--only-section=.init \
		--only-section=.text \
		$< $(GCC_DIR)/imem.bin
	
	# 2. Add header
	echo "@00000000" > $@
	
	# 3. Convert binary to 32-bit Hex strings
	hexdump -v -e '1/4 "%08x" "\n"' $(GCC_DIR)/imem.bin >> $@
	
	# 4. Cleanup
	rm -f $(GCC_DIR)/imem.bin


$(DMEM_HEX): $(ELF)
	@echo "Generating Data Memory HEX (32-bit words)..."
	@mkdir -p $(dir $@)
	
	# Check if data sections exist
	@if $(OBJDUMP) -h $< | grep -E "\.data|\.sdata|\.rodata" > /dev/null; then \
		echo "  > Data sections detected. Extracting..."; \
		$(OBJCOPY) -O binary \
			--only-section=.rodata \
			--only-section=.data \
			--only-section=.sdata \
			$< $(GCC_DIR)/dmem.bin; \
		echo "@00002000" > $@; \
		hexdump -v -e '1/4 "%08x" "\n"' $(GCC_DIR)/dmem.bin >> $@; \
		rm -f $(GCC_DIR)/dmem.bin; \
	else \
		echo "  > No data sections found. Creating empty data_mem.hex"; \
		touch $@; \
	fi

$(GCC_DIR)/%.o: $(GCC_DIR)/%.c
	$(CC) $(CFLAGS) -o $@ $<

$(GCC_DIR)/%.o: $(GCC_DIR)/%.S
	$(CC) $(ASFLAGS) -o $@ $<


simulate: $(IMEM_HEX) $(DMEM_HEX) $(TB)
	@echo "Running Verilog Simulation..."
	$(IVERILOG) -g2012 -o $(SIMV) $(TB)
	$(VVP) $(SIMV)


size: $(ELF)
	$(SIZE) $(ELF)

dump: $(ELF)
	$(OBJDUMP) -d -S $(ELF) | less

# ================= Clean =================

clean:
	rm -f $(OBJ) $(ELF) $(BIN) \
	      $(SIMV) $(SIM_OUT) \
	      $(GCC_DIR)/dmem_tmp1.elf $(GCC_DIR)/dmem_tmp2.elf