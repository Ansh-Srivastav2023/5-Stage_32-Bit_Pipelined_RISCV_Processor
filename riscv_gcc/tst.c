// void write_to_x10(int value){
//     asm volatile("mv x10, %0" : : "r" (value));
// }

// void main(){
//     volatile int a = 2;
//     volatile int b = 4;
//     volatile int c = 3;

//     write_to_x10(b*c);
//     write_to_x10(a*b);
//     write_to_x10(b*b);

//     while(1);

//     return;
// }


#define addr 0x90000000

void delay(int count) {
    for (int i = 0; i < count; i++) {
        __asm__ volatile ("nop"); 
    }
}

int main() {
    volatile unsigned int *led = (unsigned int *) addr;
    
    unsigned int pattern = 0x000F; // 4 bits ON (0000 0000 0000 1111)
    
    while (1) {
        *led = pattern;
        delay(20000); 
        unsigned int top_bit = (pattern & 0x8000) >> 15;        
        pattern = ((pattern << 1) & 0xFFFF) | top_bit;
    }
}


// volatile int my_test_data = 0xDEADBEEF;
// __attribute__((noinline))
// int main(){
//     volatile int a = 10;
//     volatile int b = 28;
//     return a+b;
// }


// #define LED_ADDR 0x90000000
// void main() {
//     volatile unsigned int *led = (unsigned int *) LED_ADDR;

//     while (1) {
//         *led = 0x00;  // Turn on LEDs
//         for (volatile int i = 0; i < 15000; i++);  // Delay
//         *led = 0xFF;  // Turn off LEDs
//         for (volatile int i = 0; i < 15000; i++);  // Delay
//     }
// }


// #define UART_ADDR 0x80000000

// void send_char(char c) {
//     volatile int *uart = (int *)UART_ADDR;
//     *uart = c;
// }

// int main()
// {
//     char ch[] = "HELO MAN WHO IS ANX";
//     int i = 0;
//     while(ch[i] != '\0') {
//         send_char(ch[i]);
//         i++;
//     }
//     return 0;
// }

// #define UART_ADDR 0x80000000

// void send_data(int d) {
//     int *uart = (int *)UART_ADDR;
//     *uart = d;
// }

// int main (){
//     int arr0[5] = {-10, 12, -2, 10, 3};
//     int arr1[5] = {6, 7, 8, 3, 11};

//     for(int i=0; i<5; i++){
//         arr0[i] = arr0[i] * arr1[i];
//         send_data(arr0[i]);
//     }
// }