TOP = Testbench		# name of the top module
SRC = /media/anx/New_Volume/Importants/Verilog/open_sta/top_module/Testbench.v	# clname of the file

all: slang_test build run

slang_test:
	slang $(SRC)

build:
	verilator --sv --binary $(SRC) --trace --quiet
# 	make -C obj_dir -f V$(TOP).mk V$(TOP) --quiet

run:
	./obj_dir/V$(TOP) +trace --quiet

clean:
	rm -rf obj_dir logs *.log
	clear

