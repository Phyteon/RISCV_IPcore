
from field import Field


class Format:
    def __init__(self, dictobj):
        self.Typename = dictobj["Typename"]
        self.FieldsAsDicts = dictobj["Fields"]
        self.FieldsList = [Field(dictionary) for dictionary in self.FieldsAsDicts]