import os
from PIL import Image

def png_to_harvard_hex(png_path, output_file="data_mem.mem"):
    print(f"Reading image: {png_path}")

    img = Image.open(png_path).convert("RGB")
    width, height = img.size

    pixel_words = []

    for r, g, b in img.getdata():
        pixel_words.append(f"0x{0:02x}{r:02x}{g:02x}{b:02x}")

    os.makedirs(os.path.dirname(output_file) or ".", exist_ok=True)
    with open(output_file, "w") as out_file:
        out_file.write("@00000000\n")
        out_file.write("\n".join(pixel_words) + "\n")

    print(f"Success! Processed {width}x{height} image ({width*height} pixels).")
    print(f"Generated single file: '{output_file}'")

path = os.getcwd()

if __name__ == "__main__":
    png_to_harvard_hex(
        f"{path}/input.png",
        output_file=f"{path}/img_hex.h"
    )
