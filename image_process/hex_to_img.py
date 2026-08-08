import os
from PIL import Image

def hex_word_to_png(hex_filepath, output_filepath, width, height):
    print(f"Reading 32-bit hex data from: {hex_filepath}...")

    pixels = []
    with open(hex_filepath, 'r') as f:
        for line in f:
            clean_line = line.strip()
            if clean_line and not clean_line.startswith('@'):
                pixels.append(int(clean_line, 16))

    expected_pixels = width * height
    if len(pixels)!= expected_pixels:
        print(f"Warning: Expected {expected_pixels} pixels, but found {len(pixels)} in file.")
        # Pad with black if too few pixels
        pixels.extend( * (expected_pixels - len(pixels)))

    print(f"Constructing Color Image: {width}x{height} pixels...")

    img = Image.new('RGB', (width, height))

    rgb_data = []
    for p_word in pixels:
        r = (p_word >> 16) & 0xFF
        g = (p_word >> 8) & 0xFF
        b = p_word & 0xFF
        rgb_data.append((r, g, b))

    img.putdata(rgb_data)
    img.save(output_filepath, 'PNG')

    print(f"Success! Color image saved to {output_filepath}")

path = os.getcwd()

if __name__ == "__main__":
    hex_word_to_png(f"{path}/io_out.hex", f"{path}/processed_image.png", 709, 518)