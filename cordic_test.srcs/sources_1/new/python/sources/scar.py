
# SCAR - Static C code Analyzer for RISC-V

# Imports:
import sys
import json
import re
from isas import ISA
# End imports

arguments = sys.argv
architecture = "RV32I"  # TODO: In final version get parameter from console
asm_path = '..\\resources\\template.asm'  # TODO: In final version get parameter from console
json_path = '..\\resources\\riscv_instructions.json'  # TODO: in final version get parameter from console or from repo

f = open(json_path)
database = json.load(f)
f.close()

rv32iarch = ISA("RV32I", database["RV32I"])
print(rv32iarch.Formats[0].Typename)
