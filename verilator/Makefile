TOP = Testbench
PARNET_DIR := $(abspath $(CURDIR)/..)

SRC1 := $(wildcard $(PARNET_DIR)/top_module/*.v)
SRC2 := $(wildcard $(PARNET_DIR)/design/EX/*.v)
SRC3 := $(wildcard $(PARNET_DIR)/design/ID/*.v)
SRC4 := $(wildcard $(PARNET_DIR)/design/IF/*.v)
SRC5 := $(wildcard $(PARNET_DIR)/design/MA/*.v)
SRC6 := $(wildcard $(PARNET_DIR)/design/WB/*.v)
SRC7 := $(PARNET_DIR)/design/Reset_Sync.v

SRC = $(SRC1) $(SRC2) $(SRC3) $(SRC4) $(SRC5) $(SRC6) $(SRC7)

MEM := $(wildcard $(PARNET_DIR)/memory_files/*.mem)

all: build run

slang_test:
	@ slang $(SRC)

build:
	@ verilator --sv --binary $(SRC) --trace --quiet
	@ cp $(MEM) ./

run:
# 	cd obj_dir && ./V$(TOP) +trace
	./obj_dir/V$(TOP) +trace --quiet

clean:
	rm -rf obj_dir logs *.log
	clear