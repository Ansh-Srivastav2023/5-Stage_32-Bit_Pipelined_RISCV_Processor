import os
import sys
import subprocess



if len(sys.argv) < 2:
    print("Usage: python automate.py <run|hex|clean>")
    sys.exit(1)



if sys.argv[1] == 'clean':
    subprocess.run(['make clean'], shell=True, cwd = os.path.join(os.getcwd(), 'top_module'))
    subprocess.run(['make clean'], shell=True, cwd=os.path.join(os.getcwd(), 'verilator'))
    # with open(os.path.join(os.getcwd(), 'memory_files/instr_mem.mem'), 'r+') as instr_file:
    #     instr_file.seek(0)
    #     instr_file.truncate()


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

