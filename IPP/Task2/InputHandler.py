import xml.etree.ElementTree as eT
import sys

from Instruction import Instruction
from ErrorHandler import ErrorHandler
from Analyser import Analyzer


class InputHandler:
    """Loads source program and sends it to interpreter"""
    def __init__(self, file):
        if file is None:
            root = load_xml(sys.stdin)
        else:
            root = load_xml(file)

        self.InstrList = create_instr_list(root)
        if not (Analyzer.analyze_instr_list(self.InstrList)):
            ErrorHandler.error(32, "Syntax error")

    def __str__(self):
        result = ""
        for instr in self.InstrList:
            result += str(instr) + "\n"
        return result

    def get_instruction(self, index):
        """Returns syntactically correct instruction"""
        assert index > 0
        if index > len(self.InstrList):
            return None
        else:
            if not (Analyzer.analyze_instr(self.InstrList[index - 1])):
                ErrorHandler.error(32, "Syntax error: " + str(self.InstrList[index - 1].OpCode))

            return self.InstrList[index - 1]


def load_xml(file):
    try:
        tree = eT.parse(file)
        return tree.getroot()
    except eT.ParseError:
        ErrorHandler.error(31, "XML file is corrupted")


def create_instr_list(root):
    lst = []
    for item in root:
        lst.append(Instruction(item))
    return sorted(lst)
