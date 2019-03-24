import sys
from Operation import Operation

from ProgramArgumentsHandler import ProgramArgumentsHandler
from InputHandler import InputHandler
from Frame import Frame
from ErrorHandler import ErrorHandler
from Stats import Stats


class Interpret:
    """
        Main part of program - contains info about actual status of interpretation and calling other parts of program
    """
    def __init__(self, options):
        self.InputHandler = None
        self.InputFile = None
        self.Options = options
        self.InstructionIndex = 0
        self.TF = None
        self.LF = None
        self.GF = Frame()
        self.FrameStack = []
        self.CallStack = []
        self.DataStack = []
        self.Labels = dict()
        self.Stats = Stats()

    def load_input(self):
        """Open source and input file"""
        try:
            self.InputHandler = InputHandler(self.Options.Source)
            if self.Options.Input is not None:
                self.InputFile = open(self.Options.Input)
        except Exception:
            ErrorHandler.error(11, "Failed to open file")

    def load_labels(self):
        """Load labels and put them to dict"""
        instr = self.next_instr()
        while instr is not None:
            if instr.OpCode == "LABEL":
                Operation.label(self, instr)
            instr = self.next_instr()
        self.Stats = Stats()
        self.InstructionIndex = 0

    def run(self):
        """Interprets instructions from source file"""
        instr = self.next_instr()
        while instr is not None:
            self.run_instr(instr)
            instr = self.next_instr()

    def next_instr(self):
        self.InstructionIndex += 1
        self.Stats.Instr += 1
        return self.InputHandler.get_instruction(self.InstructionIndex)

    def run_instr(self, instr):
        try:
            operation = None
            try:
                operation = Operation.get(instr.OpCode)
            except ValueError:
                ErrorHandler.error(32, "Unknown opcode")
            if operation is not None:
                operation(self, instr)
        except ValueError:
            ErrorHandler.error(56, "Popping empty stack")


int_options = ProgramArgumentsHandler.handle(sys.argv)
inter = Interpret(int_options)
ErrorHandler.Interpret = inter
inter.load_input()
inter.load_labels()
inter.run()
if inter.Options.Stats is not None:
    inter.Stats.save(inter.Options)

