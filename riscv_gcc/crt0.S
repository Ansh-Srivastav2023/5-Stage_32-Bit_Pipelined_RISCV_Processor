.section .init
.global _start

_start:
    li sp, 0x20001000   
    jal ra, main        

trap:
    j trap