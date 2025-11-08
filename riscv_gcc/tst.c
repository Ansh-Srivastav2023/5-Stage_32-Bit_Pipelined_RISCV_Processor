// void main() {
//     register unsigned int x1 asm("x1") = 12;     // Simulated return address
//     register unsigned int x2 asm("x2") = 4096;   // Simulated stack pointer
//     register unsigned int x3 asm("x3");          // Will hold x2 + x1
//     register unsigned int a0 asm("a0");          // Return value

//     asm volatile (
//         "add x3, x2, x1\n"   // x3 = x2 + x1
//         "mv a0, x3\n"        // a0 = x3
//         "ebreak\n"           // halt for debug
//     );
// }
// #include <stdio.h>

__attribute__((noinline))
int main(){
    volatile int a = 2;
    volatile int b = 1;

    for(int i = 5; i > 0; i-=1){
        b = a*b;
        a = b+2;
        b = a*2;
        a = b+2+a;
    }

    return b;
    // printf("b = %d", b);
}

// #define LED_ADDR 0x0c  // Replace with actual GPIO address

// void main() {
//     volatile unsigned int *led = (unsigned int *)LED_ADDR;

//     while (1) {
//         *led = 0xFF;  // Turn on LEDs
//         for (volatile int i = 0; i < 100000; i++);  // Delay
//         *led = 0x00;  // Turn off LEDs
//         for (volatile int i = 0; i < 100000; i++);  // Delay
//     }
// }
