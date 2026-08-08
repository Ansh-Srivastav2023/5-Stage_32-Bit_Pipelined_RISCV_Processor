ENTRY(_start)

MEMORY {
    IMEM (rx)  : ORIGIN = 0x20000000, LENGTH = 4K 
    
    DMEM (rwx) : ORIGIN = 0x30000000, LENGTH = 4M
}

SECTIONS {
    
    .text : {
        *(.init)
        *(.text)
        *(.text.*)
    } > IMEM

    .rodata : {
        . = ALIGN(4);
        *(.rodata*)
    } > IMEM


    .data : { 
        . = ALIGN(4);
        _data_start = .;
        *(.data) 
        *(.data.*)
        *(.sdata)
        *(.sdata.*)
        _data_end = .;
    } > DMEM

    .bss : {
        . = ALIGN(4);
        _bss_start = .;
        *(.bss)
        *(COMMON)
        _bss_end = .;
    } > DMEM

    .stack (NOLOAD) : {
        . = ALIGN(16);
        _stack_bottom = .;
        . = ORIGIN(DMEM) + LENGTH(DMEM);
        _stack_top = .;
        PROVIDE(__global_pointer$ = ORIGIN(DMEM) + 0x800);
    } > DMEM
}