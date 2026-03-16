ENTRY(_start)

MEMORY {
    RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 64k
}

SECTIONS {
    .init : {
        KEEP(*(.init))
    } > RAM

    .text : {
        *(.text)
        *(.text.*)
    } > RAM

    .data 0x20008000  : { 
        _data_start = .;
        *(.data*) 
        *(.rodata*)
        _data_end = .;
    } > RAM

    .bss : {
        . = ALIGN(4);
        _bss_start = .;
        *(.bss)
        *(COMMON)
        _bss_end = .;
    } > RAM

    .stack (NOLOAD) : {
        . = ALIGN(16);
        _stack_bottom = .;
        . = . + 8192;
        _stack_top = .;
    } > RAM
}