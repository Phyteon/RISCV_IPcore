

class Instruction:
    def __init__(self, dictobj):
        self.Name = dictobj["Name"]
        self.IsImplemented = dictobj["Implemented"]
        self.FormatAsString = dictobj["Format"]
        self.BasicInfoString = dictobj["BasicInfo"]

