.section .init
.globl _start

_start:
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    
    li sp, 0x30400000   
    jal ra, main        

trap:
    j trap