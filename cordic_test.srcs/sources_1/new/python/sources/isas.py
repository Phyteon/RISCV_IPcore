
from format import Format
from instruction import Instruction


class ISA:
    def __init__(self, name, dictobj):
        self.Formats = [Format(dictionary) for dictionary in dictobj["Formats"]]
        self.Name = name
        self.Instructions = [Instruction(dictionary) for dictionary in dictobj["Instructions"]]
