// void write_to_x10(int value){
//     asm volatile("mv x10, %0" : : "r" (value));
// }


// int main(){

//     int arr[] = {1, 2, 3, 4, 5, 6};
//     volatile int a = 0;

//     for (int i = 0; i < 6; i++) {
//         a += arr[i];
//     }

//     return a;

// }


// #define addr 0x90000000

// void delay(int count) {
//     for (int i = 0; i < count; i++) {
//         __asm__ volatile ("nop"); 
//     }
// }

// int main() {
//     volatile unsigned int *led = (unsigned int *) addr;
    
//     unsigned int pattern = 0x000F; // 4 bits ON (0000 0000 0000 1111)
    
//     while (1) {
//         *led = pattern;
//         delay(20000); 
//         unsigned int top_bit = (pattern & 0x8000) >> 15;        
//         pattern = ((pattern << 1) & 0xFFFF) | top_bit;
//     }

//     while (1)
//     {
//         *led = 0xFF;
//         delay(10000);
//         *led = 0x00;
//         delay(10000);
//     }
    
    
//     return 0;
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


// #define addr 0x90000000

// int main(){
//     volatile unsigned int *led = (unsigned int *) addr;
//     char data[] = "hello man how are you";
//     volatile int i = 0;

//     while (data[i] != '\0') {
//         *led = data[i];
//         i++;
//     }

//     return 0;
// }


#define LED_ADDR 0x90000000
void main() {
    volatile unsigned int *led = (unsigned int *) LED_ADDR;

    // while (1) {
    //     *led = 0xFF;
    //     for (volatile int i = 0; i < 50000; i++);

    //     *led = 0x00;
    //     for (volatile int i = 0; i < 50000; i++);
    // }

    *led = 45;

    return;
}


// #define UART_ADDR 0x90000000

// void send_char(char c) {
//     volatile int *uart = (int *)UART_ADDR;
//     *uart = c;
// }

// int main()
// {
//     char ch[] = "HELO PC ";
//     int j;

//     for(int i = 0; ; i++) {
//         j = 0;

//         while(ch[j] != '\0') {
//             send_char(ch[j]);
//             j++;
//         }
//     }
//     return 0;
// }

// #define UART_ADDR 0x90000000

// void send_data(int d) {
//     int *uart = (int *)UART_ADDR;
//     *uart = d;
// }

// int main (){
//     // int arr0[5] = {10, 12, -2, 10, 3};
//     // int arr1[5] = {6, 7, 8, 3, 11};

//     // for(int i=0; i<5; i++){
//     //     arr0[i] = arr0[i] + arr1[i];
//     //     send_data(arr0[i]);
//     // }

//     volatile int a = 23;
//     send_data(a);
//     volatile int b = 103;
//     send_data(b);
//     volatile int c = 43;
//     send_data(c);
//     volatile int d = 27;
//     send_data(d);
//     volatile int e = 98;
//     send_data(e);
// }