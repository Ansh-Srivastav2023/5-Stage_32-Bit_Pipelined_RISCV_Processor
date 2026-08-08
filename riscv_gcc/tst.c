#include <stdint.h>
#include "pixel_data.h"

#define OUTPUT_ADDR 0x90000000

#define WIDTH  709
#define HEIGHT 518

int main() {
    volatile uint32_t *out = (volatile uint32_t *) OUTPUT_ADDR;
    
    for (int i = 0; i < (WIDTH * HEIGHT); i++) {
        uint32_t pixel = pixel_data[i]; 
        
        // Extract channels
        uint8_t b = (uint8_t)(pixel & 0xFF);
        uint8_t g = (uint8_t)((pixel >> 8)  & 0xFF);
        uint8_t r = (uint8_t)((pixel >> 16) & 0xFF);

        // Invert each channel (255 - value)
        uint8_t inv_r = ~r; // Bitwise NOT flips all bits (e.g., 0 -> 255)
        uint8_t inv_g = ~g;
        uint8_t inv_b = ~b;

        // Repack into 0x00RRGGBB format and stream out
        *out = ((uint32_t)inv_r << 16) | ((uint32_t)inv_g << 8) | (uint32_t)inv_b;
    }

    return 0;
}