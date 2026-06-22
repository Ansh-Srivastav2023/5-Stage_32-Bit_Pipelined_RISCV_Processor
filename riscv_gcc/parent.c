#define IO_addr 0x90000000
#define UART_addr 0x80000000

int IO(volatile int data){
    volatile unsigned int *IO_pin = (unsigned int *) IO_addr;

    while(1){
        *IO_pin = data;
    }
    return 0;
}

int UART(volatile int data) {
    volatile unsigned int *IO_pin = (unsigned int *) UART;
    
    while(1){
        *IO_pin = data;
    }    
    return 0;
}

    void rgstr_wt(char reg[], int value){
        asm volatile("mv %0, %1" : : "r" (reg), "r" (value));
    }