read_liberty /home/anx/OpenSTA/examples/nangate45_fast.lib

read_verilog /media/anx/New_Volume/Importants/Verilog/Pipelined_Processor/rtl_files/Top_Module.v

link_design Top_Module

create_clock -name core_clock -period 5 {clk}

set_input_delay -clock core_clock 0 [all_inputs]
set_output_delay -clock core_clock 0 [all_outputs]

report_checks -path_delay min_max -fields {slew trans net cap input_pin}
report_checks -digits 4

report_power