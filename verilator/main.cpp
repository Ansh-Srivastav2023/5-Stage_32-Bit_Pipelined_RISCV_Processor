// #include "VTop_Module.h"
// #include "verilated.h"
// #include "verilated_vcd_c.h" // Required for waveform tracing

// int main(int argc, char** argv) {
//     Verilated::commandArgs(argc, argv);
    
//     VTop_Module* top = new VTop_Module;

//     Verilated::traceEverOn(true);
//     VerilatedVcdC* tfp = new VerilatedVcdC;
//     top->trace(tfp, 99);         // Trace 99 levels of hierarchy
//     tfp->open("waveform.vcd");   // Name of the output waveform file

//     vluint64_t main_time = 0;    // Simulation time resolution
//     top->clk = 0;                // Initialize clock (CHANGE 'clk' IF YOUR PORT NAME IS DIFFERENT)

//     while (!Verilated::gotFinish()) {
        
//         if ((main_time > 10) == 1) {
//             top->async_rst = 1; 
//         }

//         top->clk = !top->clk;

//         top->eval();

//         if(top->fifo_uart->empty_Tx)
//             break;
//         else if(top->instruction == 0x0000006f)
//             break;

//         tfp->dump(main_time);
//         main_time++;
//     }

//     top->final(); 
//     tfp->close();
//     delete tfp;
//     delete top;

//     return 0;
// }


#include "VTest.h"
#include "verilated.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    VTop_Module* top = new VTop_Module;

    while (!Verilated::gotFinish()) {
        top->eval();
    }

    delete top;
    return 0;
}