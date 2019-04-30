from ErrorHandler import ErrorHandler
from Argument import Argument


class Instruction:
    """Contains info about instruction and its arguments"""

    def __init__(self, instr):
        try:
            self.Order = instr.attrib["order"]
            self.OpCode = instr.attrib["opcode"].upper()
            self.Args = [None, None, None]
            for arg in instr:
                if self.Args[int(arg.tag[3]) - 1] is not None:
                    ErrorHandler.error(31, "XML file is corrupted")
                self.Args[int(arg.tag[3]) - 1] = Argument(arg.attrib["type"], arg.text)
        except KeyError:
            ErrorHandler.error(32, "Format error")

    def __str__(self):
        result = "Order: " + self.Order + "\nOpcode: " + self.OpCode
        i = 1
        for arg in self.Args:
            result += "\n   Arg" + str(i) + " " + str(arg)
            i += 1
        return result

    def __lt__(self, other):
        assert other is not Instruction
        return int(self.Order) < int(other.Order)

    def __gt__(self, other):
        assert other is not Instruction
        return int(self.Order) > int(other.Order)

    def __eq__(self, other):
        assert other is not Instruction
        return int(self.Order) == int(other.Order)
