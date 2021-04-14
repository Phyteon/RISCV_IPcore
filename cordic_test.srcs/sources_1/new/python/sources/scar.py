
# SCAR - Static C code Analyzer for RISC-V

# Imports:
import sys
import json
# End imports

arguments = sys.argv

f = open('D:\\VivadoProjects\\cordic_test\\RISCV_IPcore\\cordic_test.srcs' +
         '\\sources_1\\new\\python\\resources\\riscv_instructions.json')
database = json.load(f)
f.close()

for object in database:
    print(object)

with open(arguments[0]) as asm:
    code = asm.readlines()
    for line in code:
        print(line)

