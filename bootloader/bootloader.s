# RISC-V UART Bootloader with Length Header

.section .text
.globl _start

_start:
    li t0, 0x80000000       # t0 = UART Data Register
    li t1, 0x80000004       # t1 = UART Status Register
    li t2, 0x20000000       # t2 = RAM Destination Address

get_length_header:
    li t3, 4                # t3 = Byte counter (need 4 bytes)
    li t4, 0                # t4 = Shift amount (0, 8, 16, 24)
    li t6, 0                # t6 = Accumulator for the Length Header

length_byte_loop:
    lw a0, 0(t1)            
    andi a0, a0, 1
    beq a0, x0, length_byte_loop 

    lw a0, 0(t0)            
    andi a0, a0, 0xFF       
    sll a0, a0, t4          
    or t6, t6, a0           

    addi t4, t4, 8          
    addi t3, t3, -1         
    bne t3, x0, length_byte_loop

    beq t6, x0, finish_loading


get_instructions:
    li t3, 4                # t3 = Byte counter
    li t4, 0                # t4 = Shift amount
    li t5, 0                # t5 = instruction holder

instruction_byte_loop:
    lw a0, 0(t1)            
    andi a0, a0, 1          
    beq a0, x0, instruction_byte_loop 

    lw a0, 0(t0)            
    andi a0, a0, 0xFF       
    sll a0, a0, t4          
    or t5, t5, a0           

    addi t4, t4, 8          
    addi t3, t3, -1         
    bne t3, x0, instruction_byte_loop

    sw t5, 0(t2)            
    addi t2, t2, 4

    addi t6, t6, -1         
    bne t6, x0, get_instructions

finish_loading:
    nop                     # Clear pipeline hazards
    nop
    nop

    li t2, 0x20000000
    jalr x0, 0(t2)

    