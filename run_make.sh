#!/bin/bash


case ${1,,} in

    # iverilog) 
    #     cd "/media/anx/New_Volume/Importants/Verilog/open_sta/top_module"
    #     iverilog -o Testbench.v.out Testbench.v
    #     vvp Testbench.v.out
    #     ;;

    clean)
        cd top_module
        make clean
        cd ..
        cd verilator
        make clean
        cd ..
    ;;

    make)
        cd top_module
        make
        cd ..
        cd verilator
        make
        cd ..
    ;;

    *)
        cd top_module
        make clean
        cd ..
        cd verilator
        make clean
        cd ..
        cd top_module
        make
        cd ..
        cd verilator
        make
        cd ..
esac