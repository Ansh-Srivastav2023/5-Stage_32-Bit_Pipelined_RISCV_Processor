TOP := Testbench
PARENT_DIR := $(abspath $(CURDIR)/..)

SRC2 := $(wildcard $(PARENT_DIR)/design/EX/*.v)
SRC3 := $(wildcard $(PARENT_DIR)/design/ID/*.v)
SRC4 := $(wildcard $(PARENT_DIR)/design/IF/*.v)
SRC5 := $(wildcard $(PARENT_DIR)/design/MA/*.v)
SRC1 := $(wildcard $(PARENT_DIR)/top_module/*.v)
SRC6 := $(wildcard $(PARENT_DIR)/design/WB/*.v)
SRC7 := $(PARENT_DIR)/design/Reset_Sync.v

SRC = $(SRC1) $(SRC2) $(SRC3) $(SRC4) $(SRC5) $(SRC6) $(SRC7)

MEM := $(wildcard $(PARENT_DIR)/memory_files/*.mem)

.PHONY: all slang_test build run clean

all: slang_test build run

slang_test:
	@ slang $(SRC)


build:
	@ echo "Running V E R I L A T O R...."
	@ verilator --sv --binary --top $(TOP) $(SRC) --trace --quiet
	@ cp $(MEM) ./

run:
	@./obj_dir/V$(TOP) +trace --quiet


clean:
	rm -rf obj_dir logs *.log *.mem
	clear




# build:
# 	@ echo "Verilating the design..."
# 	@verilator -Wall --trace --top $(TOP) -cc $(SRC) --exe main.cpp --quiet
# 	@ if [ -n "$(MEM)" ]; then cp $(MEM) ./; fi

# run:
# 	@ echo "Compiling C++ wrapper and running..."
# 	make -j -C obj_dir -f V$(TOP).mk V$(TOP) --quiet
# 	./obj_dir/V$(TOP)

##################################################################
