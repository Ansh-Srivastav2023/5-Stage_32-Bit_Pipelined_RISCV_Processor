import os
import sys
import subprocess


if len(sys.argv) < 2:
    print("Usage: python automate.py <run|hex|clean>")
    sys.exit(1)


if sys.argv[1] == 'clean':
    subprocess.run(['make clean'], shell=True, cwd = os.path.join(os.getcwd(), 'top_module'))
    subprocess.run(['make clean'], shell=True, cwd=os.path.join(os.getcwd(), 'verilator'))


elif sys.argv[1] == 'clean_all':
    subprocess.run(['make clean'], shell=True, cwd = os.path.join(os.getcwd(), 'top_module'))
    subprocess.run(['make clean_all'], shell=True, cwd=os.path.join(os.getcwd(), 'verilator'))



elif sys.argv[1] == 'hex':
    subprocess.run(['make'], cwd = os.path.join(os.getcwd(), 'top_module'))
    with open(os.path.join(os.getcwd(), 'memory_files/instr_mem.mem'), 'r+') as instr_file:
        line_num = sum(1 for _ in instr_file)
        instr_file.seek(0)
        content = instr_file.read()
        instr_file.seek(0)
        instr_file.write(f"{hex(line_num)}\n{content}")


elif sys.argv[1] == 'run':
    subprocess.run(['make'], cwd = os.path.join(os.getcwd(), 'top_module'))
    with open(os.path.join(os.getcwd(), 'memory_files/instr_mem.mem'), 'r+') as instr_file:
        line_num = sum(1 for _ in instr_file)
        instr_file.seek(0)
        content = instr_file.read()
        instr_file.seek(0)
        instr_file.write(f"{hex(line_num)}\n{content}")
    subprocess.run(['make'], cwd=os.path.join(os.getcwd(), 'verilator'))


elif sys.argv[1] == 'process_image':
    print("Running...\npython img_to_hex.py\n")
    subprocess.run(['python', 'img_to_hex.py'], cwd=os.path.join(os.getcwd(), 'image_process'))
    print("\n\nRunning...\npython convert_c.py")
    subprocess.run(['python', 'convert_c.py'], cwd=os.path.join(os.getcwd(), 'image_process'))
    print("\n\nRunning...\nmv pixel_data.h ../riscv_gcc")
    subprocess.run(['mv', 'pixel_data.h', '../riscv_gcc'], cwd=os.path.join(os.getcwd(), 'image_process'))
    print("\n\nRunning in top_module...\nmake")
    subprocess.run(['make'], cwd = os.path.join(os.getcwd(), 'top_module'))
    with open(os.path.join(os.getcwd(), 'memory_files/instr_mem.mem'), 'r+') as instr_file:
        line_num = sum(1 for _ in instr_file)
        instr_file.seek(0)
        content = instr_file.read()
        instr_file.seek(0)
        instr_file.write(f"{hex(line_num)}\n{content}")
    print("\n\nRunning in verilator...\nmake")
    subprocess.run(['make'], cwd=os.path.join(os.getcwd(), 'verilator'))
    print("\n\nRunning...\nmv io_out.hex ../img_process")
    subprocess.run(['mv', 'io_out.hex', '../image_process'], cwd=os.path.join(os.getcwd(), 'verilator'))
    print("\n\nRunning...\nmv python hex_to_img.py\n")
    subprocess.run(['python', 'hex_to_img.py'], cwd=os.path.join(os.getcwd(), 'image_process'))

