import os

path = os.getcwd()

with open(f"{path}/img_hex.h") as f, open(f"{path}/pixel_data.h","w") as out:
    vals = []
    for line in f:
        line=line.strip()
        if not line or line.startswith("@"): continue
        vals.append(line)

    out.write("#include <stdint.h>\n\n")
    out.write(f"int pixel_data_len = {len(vals)};\n\n")
    out.write(f"int pixel_data[{len(vals)}] = {{\n ")
    out.write(",\n ".join(vals))
    out.write("\n};\n")