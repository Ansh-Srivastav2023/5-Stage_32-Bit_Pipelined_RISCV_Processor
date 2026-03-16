.section .init
.global _start

_start:
    # 1. Set up the stack pointer
    la sp, _stack_top

    # 2. Clear BSS (Zero out uninitialized globals)
    la t0, _bss_start
    la t1, _bss_end
bss_clear:
    beq t0, t1, jump_main
    sw x0, 0(t0)
    addi t0, t0, 4
    j bss_clear

jump_main:
    # 3. Jump to main C function
    call main

    # 4. If main returns, loop forever or trap
    ebreak

loop_forever:
    j loop_forever
    