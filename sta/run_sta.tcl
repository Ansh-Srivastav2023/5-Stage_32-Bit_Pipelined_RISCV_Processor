# 1. READ LIBRARIES
read_liberty /home/anx/OpenSTA/examples/nangate45_fast.lib

# 2. READ NETLIST
read_verilog final_netlist.v

# 3. LINK DESIGN
link_design Top_Module

# 4. CREATE CLOCK (CRITICAL STEP)
# 'clk' must match the input port name in your Verilog
# -period 10 means 10ns (100MHz). Adjust as needed.
create_clock -name core_clock -period 10 {clk}

# Optional: Set input/output delays (assumed 0 for basic checks)
set_input_delay -clock core_clock 0 [all_inputs]
set_output_delay -clock core_clock 0 [all_outputs]
set_false_path -from [get_ports async_rst]

# 5. CHECK TIMING
report_checks -path_delay min_max -fields {slew trans net cap input_pin}
report_checks -digits 4

# 6. REPORT POWER
report_power