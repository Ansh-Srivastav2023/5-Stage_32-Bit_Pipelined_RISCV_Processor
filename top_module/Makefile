CROSS     ?= riscv-none-elf
CC        := $(CROSS)-gcc
OBJDUMP   := $(CROSS)-objdump
OBJCOPY   := $(CROSS)-objcopy
SIZE      := $(CROSS)-size

ARCH      ?= rv32im
ABI       ?= ilp32
ARCHFLAGS = -march=$(ARCH) -mabi=$(ABI)

PARNET_DIR := $(abspath $(CURDIR)/..)
GCC_DIR := $(PARNET_DIR)/riscv_gcc
RTL_DIR := $(PARNET_DIR)/top_module


C_SRC    = $(GCC_DIR)/tst.c
ASM_SRC  = $(GCC_DIR)/crt0.S

OBJ      = $(ASM_SRC:.S=.o) $(C_SRC:.c=.o)

ELF      = $(GCC_DIR)/tst.elf
BIN      = $(GCC_DIR)/tst.bin
DISASM   = $(GCC_DIR)/disasm.txt

IMEM_HEX = $(PARNET_DIR)/memory_files/instr_mem.mem
DMEM_HEX = $(PARNET_DIR)/memory_files/data_mem.mem

TB       = $(RTL_DIR)/Testbench.v
SIMV     = $(RTL_DIR)/simv
SIM_OUT  = $(RTL_DIR)/sim_output.txt



CFLAGS  = $(ARCHFLAGS) -O2 -Wall -Wextra -ffreestanding \
          -fdata-sections -ffunction-sections -c

ASFLAGS = $(ARCHFLAGS) -ffreestanding -c

LDFLAGS = $(ARCHFLAGS) -T $(GCC_DIR)/link.ld -nostdlib -nostartfiles \
          --specs=nosys.specs

.PHONY: all clean size dump

all: $(DISASM) $(IMEM_HEX) $(DMEM_HEX)


$(ELF): $(OBJ) $(GCC_DIR)/link.ld
	@ $(CC) $(LDFLAGS) -o $@ $(OBJ)
	@ $(SIZE) $@

$(DISASM): $(ELF)
	@ $(OBJDUMP) -d -M no-aliases -S $< > $@

$(BIN): $(ELF)
	@ $(OBJCOPY) -O binary $< $@


$(IMEM_HEX): $(ELF)
	@echo "Generating Instruction Memory HEX (32-bit words)..."
	@mkdir -p $(dir $@)
	
	@$(OBJCOPY) -O binary \
		--only-section=.init \
		--only-section=.text \
		$< $(GCC_DIR)/imem.bin
	
# 	@echo "@00000000" > $@
	@echo "" > $@
	@hexdump -v -e '1/4 "%08x" "\n"' $(GCC_DIR)/imem.bin >> $@
	@rm -f $(GCC_DIR)/imem.bin


$(DMEM_HEX): $(ELF)
	@echo "Generating Data Memory HEX (4 byte lanes)..."
	@mkdir -p $(dir $@)
	
	@if $(OBJDUMP) -h $< | grep -E "\.data|\.sdata|\.rodata" > /dev/null; then \
		echo "  > Data sections detected. Extracting..."; \
		$(OBJCOPY) -O binary \
			--only-section=.data \
			--only-section=.sdata \
			--only-section=.bss \
			$< $(GCC_DIR)/dmem.bin; \
		echo "  > Splitting into 4 byte-lane files..."; \
		hexdump -v -e '1/1 "%02x\n"' $(GCC_DIR)/dmem.bin > $(GCC_DIR)/dmem_bytes.txt; \
		\
		# FIX: Freshly truncate/wipe files to prevent appending onto old builds \
		> "$(dir $@)data_mem0.mem"; \
		> "$(dir $@)data_mem1.mem"; \
		> "$(dir $@)data_mem2.mem"; \
		> "$(dir $@)data_mem3.mem"; \
		\
		# FIX: Use awk with '>>' stream formatting into the freshly cleared files \
		awk '\
		NR%4==1 {print $$1 >> "$(dir $@)data_mem0.mem"} \
		NR%4==2 {print $$1 >> "$(dir $@)data_mem1.mem"} \
		NR%4==3 {print $$1 >> "$(dir $@)data_mem2.mem"} \
		NR%4==0 {print $$1 >> "$(dir $@)data_mem3.mem"}' $(GCC_DIR)/dmem_bytes.txt; \
		\
		rm -f $(GCC_DIR)/dmem.bin $(GCC_DIR)/dmem_bytes.txt; \
		echo "  > Successfully generated data_mem[0-3].mem"; \
	else \
		echo "  > No data sections found. Overwriting to create empty data_mem files..."; \
		# FIX: Force clean overwrite/creation if no data section exists \
		> $(dir $@)data_mem0.mem; \
		> $(dir $@)data_mem1.mem; \
		> $(dir $@)data_mem2.mem; \
		> $(dir $@)data_mem3.mem; \
	fi

$(GCC_DIR)/%.o: $(GCC_DIR)/%.c
	@$(CC) $(CFLAGS) -o $@ $<

$(GCC_DIR)/%.o: $(GCC_DIR)/%.S
	@$(CC) $(ASFLAGS) -o $@ $<


size: $(ELF)
	@$(SIZE) $(ELF)

dump: $(ELF)
	@$(OBJDUMP) -d -S $(ELF) | less

# ================= Clean =================

clean:
	rm -f $(OBJ) $(ELF) $(BIN) \
	      $(SIMV) $(SIM_OUT) \
	      $(GCC_DIR)/dmem_tmp1.elf $(GCC_DIR)/dmem_tmp2.elf
