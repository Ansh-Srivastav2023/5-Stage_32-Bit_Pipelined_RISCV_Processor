This is a 32-Bit 5-Stage Pipelined RISC-V processor. Designed completely in verilog. Instruction sets from `RV32VI` ISA can be directly put into `instr_mem.hex` file in `hexadecimal` format and run it to obtain the results.
One can change the `Testbench.v` to look for specific results obtained.
RV32: A 32-bit architecture, meaning its integer registers and address space are 32 bits wide.
I: The base integer instruction set. This is a mandatory component for any RISC-V processor and includes essential operations like integer computation, memory access, and control flow.
V: The standard Vector operations extension. This optional extension adds vector registers and instructions for parallel processing, accelerating tasks in areas like machine learning, signal processing, and cryptography. 
