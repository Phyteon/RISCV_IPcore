
# SCAR - Static C code Analyzer for RISC-V

# Imports:
import sys
import json
import re
# End imports

arguments = sys.argv
architecture = "RV32I"
asm_path = 'D:\\VivadoProjects\\cordic_test\\RISCV_IPcore\\' \
           'cordic_test.srcs\\sources_1\\new\\python\\resources\\template.asm'

f = open('D:\\VivadoProjects\\cordic_test\\RISCV_IPcore\\cordic_test.srcs' +
         '\\sources_1\\new\\python\\resources\\riscv_instructions.json')
database = json.load(f)
f.close()
inst = database["Architecture"][0][architecture][0]
print(len(inst))

with open(asm_path) as asm:
    code = asm.readlines()
    for line in code:
        for types in inst:
            for instructions in inst[types][0]["Instructions"][0]:
                print(instructions)


