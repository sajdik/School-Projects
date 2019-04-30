from ErrorHandler import ErrorHandler
from Frame import Frame
import sys
import re


# noinspection PyUnusedLocal
class Operation:
    """Contains methods for interpretation of instructions"""

    @staticmethod
    def get(opcode):
        """Returns function representing opcode functionality"""
        lst = {"MOVE": Operation.move, "DEFVAR": Operation.defvar, "CREATEFRAME": Operation.create_frame,
               "PUSHFRAME": Operation.push_frame, "POPFRAME": Operation.pop_frame, "CALL": Operation.call,
               "RETURN": Operation.ret, "PUSHS": Operation.pushs, "POPS": Operation.pops, "CLEARS": Operation.clears,
               "ADD": Operation.add, "SUB": Operation.sub, "MUL": Operation.mul, "IDIV": Operation.idiv,
               "DIV": Operation.div, "ADDS": Operation.adds, "SUBS": Operation.subs, "MULS": Operation.muls,
               "IDIVS": Operation.idivs, "DIVS": Operation.divs, "LT": Operation.lt, "GT": Operation.gt,
               "EQ": Operation.eq, "LTS": Operation.lts, "GTS": Operation.gts, "EQS": Operation.eqs,
               "AND": Operation.andi, "OR": Operation.ori, "NOT": Operation.noti, "ANDS": Operation.ands,
               "ORS": Operation.ors, "NOTS": Operation.nots, "INT2CHAR": Operation.int2char,
               "STRI2INT": Operation.stri2int, "INT2FLOAT": Operation.int2float, "FLOAT2INT": Operation.float2int,
               "INT2CHARS": Operation.int2chars, "STRI2INTS": Operation.stri2ints, "INT2FLOATS": Operation.int2floats,
               "FLOAT2INTS": Operation.float2ints, "READ": Operation.read, "WRITE": Operation.write,
               "CONCAT": Operation.concat, "STRLEN": Operation.strlen, "GETCHAR": Operation.getchar,
               "SETCHAR": Operation.setchar, "TYPE": Operation.type, "LABEL": None, "JUMP": Operation.jump,
               "JUMPIFEQ": Operation.jump_if_eq, "JUMPIFNEQ": Operation.jump_if_neq, "JUMPIFEQS": Operation.jump_if_eqs,
               "JUMPIFNEQS": Operation.jump_if_neqs, "EXIT": Operation.exit, "BREAK": Operation.breaki,
               "DPRINT": Operation.dprint}
        return lst[opcode]

    @staticmethod
    def move(inter, instr):
        if instr.Args[0].Type != "var":
            ErrorHandler.error(1, "")
        if instr.Args[1].Type in ("int", "bool", "float", "string", "nil"):
            set_variable_value(inter, instr.Args[0].Value, get_symb_value(inter, instr.Args[1]))
        elif instr.Args[1].Type == "var":
            set_variable_value(inter, instr.Args[0].Value, get_symb_value(inter, instr.Args[1]))
        else:
            ErrorHandler.error(1, "")

    @staticmethod
    def defvar(inter, instr):
        var = instr.Args[0].Value
        get_frame(inter, var).define(cut_frame(var))

    @staticmethod
    def create_frame(inter, instr):
        inter.TF = Frame()

    @staticmethod
    def push_frame(inter, instr):
        if inter.TF is None:
            ErrorHandler.error(55, "Pushing undefined frame")
        inter.FrameStack.append(inter.TF)
        inter.LF = inter.TF
        inter.TF = None

    @staticmethod
    def pop_frame(inter, instr):
        if not inter.FrameStack:
            ErrorHandler.error(55, "Popping empty stack")
        inter.TF = inter.FrameStack.pop()
        try:
            inter.LF = inter.FrameStack[-1]
        except IndexError:
            inter.LF = None

    @staticmethod
    def call(inter, instr):
        label = instr.Args[0].Value
        if label not in inter.Labels.keys():
            ErrorHandler.error(52, "Undefined label")
        inter.CallStack.append(inter.InstructionIndex)
        inter.InstructionIndex = inter.Labels[label]

    @staticmethod
    def ret(inter, instr):
        if not inter.CallStack:
            ErrorHandler.error(56, "RETURN without previous CALL")
        inter.InstructionIndex = inter.CallStack.pop()

    @staticmethod
    def pushs(inter, instr):
        symb = instr.Args[0]
        inter.DataStack.append(get_symb_value(inter, symb))

    @staticmethod
    def pops(inter, instr):
        var = instr.Args[0].Value
        if not inter.DataStack:
            ErrorHandler.error(56, "Data Stack is empty")
        set_variable_value(inter, var, inter.DataStack.pop())

    @staticmethod
    def clears(inter, instr):
        inter.DataStack = []

    @staticmethod
    def add(inter, instr):
        var = instr.Args[0].Value
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        if type(symb1) == type(symb2) and (isinstance(symb1, int) or isinstance(symb1, float)):
            set_variable_value(inter, var, symb1 + symb2)
        else:
            ErrorHandler.error(53, "Invalid operation")

    @staticmethod
    def sub(inter, instr):
        var = instr.Args[0].Value
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        if type(symb1) == type(symb2) and (isinstance(symb1, int) or isinstance(symb1, float)):
            set_variable_value(inter, var, symb1 - symb2)
        else:
            ErrorHandler.error(53, "Invalid operation")

    @staticmethod
    def mul(inter, instr):
        var = instr.Args[0].Value
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        if type(symb1) == type(symb2) and (isinstance(symb1, int) or isinstance(symb1, float)):
            set_variable_value(inter, var, symb1 * symb2)
        else:
            ErrorHandler.error(53, "Invalid operation")

    @staticmethod
    def idiv(inter, instr):
        var = instr.Args[0].Value
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        if type(symb1) == type(symb2) and isinstance(symb1, int):
            if symb2 == 0:
                ErrorHandler.error(57, "Division by 0")
            set_variable_value(inter, var, symb1 // symb2)
        else:
            ErrorHandler.error(53, "Invalid operation")

    @staticmethod
    def div(inter, instr):
        var = instr.Args[0].Value
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        if type(symb1) == type(symb2) and isinstance(symb1, float):
            if symb2 == 0.0:
                ErrorHandler.error(57, "Division by 0")
            set_variable_value(inter, var, symb1 / symb2)
        else:
            ErrorHandler.error(53, "Invalid operation")

    @staticmethod
    def adds(inter, instr):
        symb2 = inter.DataStack.pop()
        symb1 = inter.DataStack.pop()
        if type(symb1) == type(symb2) and (isinstance(symb1, int) or isinstance(symb1, float)):
            inter.DataStack.append(symb1 + symb2)
        else:
            ErrorHandler.error(53, "Invalid operation")

    @staticmethod
    def subs(inter, instr):
        symb2 = inter.DataStack.pop()
        symb1 = inter.DataStack.pop()
        if type(symb1) == type(symb2) and (isinstance(symb1, int) or isinstance(symb1, float)):
            inter.DataStack.append(symb1 - symb2)
        else:
            ErrorHandler.error(53, "Invalid operation")

    @staticmethod
    def muls(inter, instr):
        symb2 = inter.DataStack.pop()
        symb1 = inter.DataStack.pop()
        if type(symb1) == type(symb2) and (isinstance(symb1, int) or isinstance(symb1, float)):
            inter.DataStack.append(symb1 * symb2)
        else:
            ErrorHandler.error(53, "Invalid operation")

    @staticmethod
    def idivs(inter, instr):
        symb2 = inter.DataStack.pop()
        symb1 = inter.DataStack.pop()
        if type(symb1) == type(symb2) and isinstance(symb1, int):
            if symb2 == 0:
                ErrorHandler.error(57, "Division by 0")
            inter.DataStack.append(symb1 // symb2)
        else:
            ErrorHandler.error(53, "Invalid operation")

    @staticmethod
    def divs(inter, instr):
        symb2 = inter.DataStack.pop()
        symb1 = inter.DataStack.pop()
        if type(symb1) == type(symb2) and isinstance(symb1, float):
            if symb2 == 0.0:
                ErrorHandler.error(57, "Division by 0")
            inter.DataStack.append(symb1 / symb2)
        else:
            ErrorHandler.error(52, "Invalid operation")

    @staticmethod
    def lt(inter, instr):
        var = instr.Args[0].Value
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        if type(symb1) != type(symb2) or symb1 is None:
            ErrorHandler.error(53, "Invalid operation")
        set_variable_value(inter, var, symb1 < symb2)

    @staticmethod
    def gt(inter, instr):
        var = instr.Args[0].Value
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        if type(symb1) != type(symb2) or symb1 is None:
            ErrorHandler.error(53, "Invalid operation")
        set_variable_value(inter, var, symb1 > symb2)

    @staticmethod
    def eq(inter, instr):
        var = instr.Args[0].Value
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        set_variable_value(inter, var, symb1 == symb2 and type(symb1) == type(symb2))

    @staticmethod
    def lts(inter, instr):
        symb2 = inter.DataStack.pop()
        symb1 = inter.DataStack.pop()
        if type(symb1) != type(symb2) or symb1 is None:
            ErrorHandler.error(53, "Invalid operation")
        inter.DataStack.append(symb1 < symb2)

    @staticmethod
    def gts(inter, instr):
        symb2 = inter.DataStack.pop()
        symb1 = inter.DataStack.pop()
        if type(symb1) != type(symb2) or symb1 is None:
            ErrorHandler.error(53, "Invalid operation")
        inter.DataStack.append(symb1 > symb2)

    @staticmethod
    def eqs(inter, instr):
        symb2 = inter.DataStack.pop()
        symb1 = inter.DataStack.pop()
        inter.DataStack.append(symb1 == symb2 and type(symb1) == type(symb2))

    @staticmethod
    def andi(inter, instr):
        var = instr.Args[0].Value
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        if not (type(symb1) == type(symb2) == type(True)):
            ErrorHandler.error(53, "Invalid operation")
        set_variable_value(inter, var, symb1 and symb2)

    @staticmethod
    def ori(inter, instr):
        var = instr.Args[0].Value
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        if not (type(symb1) == type(symb2) == type(True)):
            ErrorHandler.error(53, "Invalid operation")
        set_variable_value(inter, var, symb1 or symb2)

    @staticmethod
    def noti(inter, instr):
        var = instr.Args[0].Value
        symb = get_symb_value(inter, instr.Args[1])
        if not isinstance(symb, bool):
            ErrorHandler.error(53, "Invalid operation")
        set_variable_value(inter, var, not symb)

    @staticmethod
    def ands(inter, instr):
        symb2 = inter.DataStack.pop()
        symb1 = inter.DataStack.pop()
        if not (type(symb1) == type(symb2) == type(True)):
            ErrorHandler.error(53, "Invalid operation")
        inter.DataStack.append(symb1 and symb2)

    @staticmethod
    def ors(inter, instr):
        symb2 = inter.DataStack.pop()
        symb1 = inter.DataStack.pop()
        if not (type(symb1) == type(symb2) == type(True)):
            ErrorHandler.error(53, "Invalid operation")
        inter.DataStack.append(symb1 or symb2)

    @staticmethod
    def nots(inter, instr):
        symb = inter.DataStack.pop()
        if not isinstance(symb, bool):
            ErrorHandler.error(53, "Invalid operation")
        inter.DataStack.append(not symb)

    @staticmethod
    def int2char(inter, instr):
        var = instr.Args[0].Value
        symb = get_symb_value(inter, instr.Args[1])
        if not isinstance(symb, int):
            ErrorHandler.error(53, "Invalid operation")
        try:
            set_variable_value(inter, var, chr(symb))
        except ValueError:
            ErrorHandler.error(58, "Invalid ordinal value: " + str(symb))

    @staticmethod
    def stri2int(inter, instr):
        var = instr.Args[0].Value
        stri = get_symb_value(inter, instr.Args[1])
        index = get_symb_value(inter, instr.Args[2])
        if not isinstance(index, int) or not isinstance(stri, str):
            ErrorHandler.error(53, "Invalid operation")
        if index >= len(stri) or index < 0:
            ErrorHandler.error(58, "Index out of range")
        set_variable_value(inter, var, ord(stri[index]))

    @staticmethod
    def int2float(inter, instr):
        var = instr.Args[0].Value
        symb = get_symb_value(inter, instr.Args[1])
        if not isinstance(symb, int):
            ErrorHandler.error(53, "Invalid operation")
        set_variable_value(inter, var, float(symb))

    @staticmethod
    def float2int(inter, instr):
        var = instr.Args[0].Value
        symb = get_symb_value(inter, instr.Args[1])
        if not isinstance(symb, float):
            ErrorHandler.error(53, "Invalid operation")
        set_variable_value(inter, var, int(symb))

    @staticmethod
    def int2chars(inter, instr):
        symb = inter.DataStack.pop()
        if not isinstance(symb, int):
            ErrorHandler.error(53, "Invalid operation")
        try:
            inter.DataStack.append(chr(symb))
        except ValueError:
            ErrorHandler.error(58, "Invalid ordinal value: " + str(symb))

    @staticmethod
    def stri2ints(inter, instr):
        index = inter.DataStack.pop()
        stri = inter.DataStack.pop()
        if not (isinstance(index, int) and isinstance(stri, str)):
            ErrorHandler.error(53, "Invalid operation")
        if index >= len(stri):
            ErrorHandler.error(58, "Index out of range")
        inter.DataStack.append(ord(stri[index]))

    @staticmethod
    def int2floats(inter, instr):
        symb = inter.DataStack.pop()
        if not isinstance(symb, int):
            ErrorHandler.error(53, "Invalid operation")
        inter.DataStack.append(float(symb))

    @staticmethod
    def float2ints(inter, instr):
        symb = inter.DataStack.pop()
        if not isinstance(symb, float):
            ErrorHandler.error(53, "Invalid operation")
        inter.DataStack.append(int(symb))

    @staticmethod
    def read(inter, instr):
        var = instr.Args[0].Value
        input_type = instr.Args[1].Value
        value = ""
        try:
            value = read_input(inter)
            if value is None:
                value = ""
            value = convert_input(input_type, value)
        except (ValueError, EOFError):
            value = get_default_value(input_type)
        set_variable_value(inter, var, value)

    @staticmethod
    def write(inter, instr):
        symb = instr.Args[0]
        val = get_symb_value(inter, symb)
        if val is None:
            return
        elif isinstance(val, bool):
            if val:
                print("true", end='')
            else:
                print("false", end='')
        else:
            print(val, end='')

    @staticmethod
    def concat(inter, instr):
        var = instr.Args[0].Value
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        if not (type(symb1) == type(symb2) == str):
            ErrorHandler.error(53, "Invalid operation")
        set_variable_value(inter, var, symb1 + symb2)

    @staticmethod
    def strlen(inter, instr):
        var = instr.Args[0].Value
        symb = get_symb_value(inter, instr.Args[1])
        if not isinstance(symb, str):
            ErrorHandler.error(53, "Invalid operation")
        set_variable_value(inter, var, len(symb))

    @staticmethod
    def getchar(inter, instr):
        var = instr.Args[0].Value
        stri = get_symb_value(inter, instr.Args[1])
        index = get_symb_value(inter, instr.Args[2])
        if not (isinstance(index, int) and isinstance(stri, str)):
            ErrorHandler.error(53, "Invalid value")
        if index >= len(stri) or index < 0:
            ErrorHandler.error(58, "Index out of range")
        set_variable_value(inter, var, stri[index])

    @staticmethod
    def setchar(inter, instr):
        var = instr.Args[0].Value
        var_value = get_symb_value(inter, instr.Args[0])
        index = get_symb_value(inter, instr.Args[1])
        char = get_symb_value(inter, instr.Args[2])
        if not ((isinstance(index, int) and isinstance(char, str)) and isinstance(var_value, str)):
            ErrorHandler.error(53, "Invalid operation - setchar")
        if index >= len(var_value) or index < 0 or len(char) == 0:
            ErrorHandler.error(58, "Index out of range")
        var_value = list(var_value)
        var_value[index] = char[0]
        set_variable_value(inter, var, "".join(var_value))

    @staticmethod
    def type(inter, instr):
        var = instr.Args[0].Value
        if instr.Args[1].Type == "var":
            frame = get_frame(inter, instr.Args[1].Value)
            var_name = cut_frame(instr.Args[1].Value)
            if var_name not in frame.store:
                ErrorHandler.error(54, "Undefined variable")
            if var_name not in frame.initialized:
                set_variable_value(inter, var, "")
                return
        symb = get_symb_value(inter, instr.Args[1])
        type_str = get_type(symb)
        set_variable_value(inter, var, type_str)

    @staticmethod
    def label(inter, instr):
        label = instr.Args[0].Value
        if label in inter.Labels.keys():
            ErrorHandler.error(52, "Label redefinition")
        inter.Labels[label] = int(instr.Order)

    @staticmethod
    def jump(inter, instr):
        label = instr.Args[0].Value
        inter.InstructionIndex = inter.Labels[label]
        if inter.InstructionIndex is None:
            ErrorHandler.error(52, "Label does not exist")

    @staticmethod
    def jump_if_eq(inter, instr):
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        if type(symb1) == type(symb2) or symb1 is None or symb2 is None:
            if symb1 == symb2:
                Operation.jump(inter, instr)
        else:
            ErrorHandler.error(53, "Different types comparison")

    @staticmethod
    def jump_if_neq(inter, instr):
        symb1 = get_symb_value(inter, instr.Args[1])
        symb2 = get_symb_value(inter, instr.Args[2])
        if type(symb1) == type(symb2) or symb1 is None or symb2 is None:
            if symb1 != symb2:
                Operation.jump(inter, instr)
        else:
            ErrorHandler.error(53, "Different types comparison")

    @staticmethod
    def jump_if_eqs(inter, instr):
        symb2 = inter.DataStack.pop()
        symb1 = inter.DataStack.pop()
        if type(symb1) == type(symb2) or symb1 is None or symb2 is None:
            if symb1 == symb2:
                Operation.jump(inter, instr)
        else:
            ErrorHandler.error(53, "Different types comparison")

    @staticmethod
    def jump_if_neqs(inter, instr):
        symb2 = inter.DataStack.pop()
        symb1 = inter.DataStack.pop()
        if type(symb1) == type(symb2) or symb1 is None or symb2 is None:
            if symb1 != symb2:
                Operation.jump(inter, instr)
        else:
            ErrorHandler.error(53, "Different types comparison")

    @staticmethod
    def exit(inter, instr):
        value = get_symb_value(inter, instr.Args[0])
        if not isinstance(value, int):
            ErrorHandler.error(53, "Exiting with non int value")
        if not (0 <= value < 50):
            ErrorHandler.error(57, "Exit value out of range")
        inter.Stats.Instr += 1
        if inter.Options.Stats is not None:
            inter.Stats.save(inter.Options)
        sys.exit(value)

    @staticmethod
    def breaki(inter, instr):
        print("Position in code: " + str(inter.InstructionIndex), file=sys.stderr)
        print("Global frame: " + str(inter.GF), file=sys.stderr)
        print("Temporary frame: " + str(inter.TF), file=sys.stderr)
        print("Local frame" + str(inter.LF), file=sys.stderr)
        print("Frames on stack(LF included): " + str(len(inter.FrameStack)), file=sys.stderr)
        print("Instruction executed count: " + str(inter.Stats.Instr), file=sys.stderr)

    @staticmethod
    def dprint(inter, instr):
        symb = get_symb_value(inter, instr.Args[0])
        print(symb, file=sys.stderr)


def set_variable_value(inter, var, value):
    frame = get_frame(inter, var)
    var_name = cut_frame(var)
    if var_name not in frame.initialized:
        frame.initialized.add(var_name)
        inter.Stats.Vars += 1
    frame[var_name] = value


def get_variable_value(inter, var):
    frame = get_frame(inter, var)
    var_name = cut_frame(var)
    if var_name in frame and var_name not in frame.initialized:
        ErrorHandler.error(56, "Variable was not initialized: " + var)
    try:
        return frame[var_name]
    except ValueError:
        ErrorHandler.error(54, "Variable does not exists: " + var)


def get_symb_value(inter, symb):
    if symb.Type in ("int", "bool", "float", "string", "nil"):
        return convert_to_value(symb)
    elif symb.Type == "var":
        return get_variable_value(inter, symb.Value)
    else:
        ErrorHandler.error(32, "Unknown type: " + symb.Type)


def get_frame(inter, var):
    frame_name = re.match("^(.+)@.*$", var)[1]
    frame = None
    if frame_name == "GF":
        frame = inter.GF
    elif frame_name == "LF":
        frame = inter.LF
    elif frame_name == "TF":
        frame = inter.TF
    else:
        ErrorHandler.error(32, "Corrupted variable name: " + var)
    if frame is None:
        ErrorHandler.error(55, "Frame does not exist: " + frame_name)
    return frame


def cut_frame(var_name):
    return var_name.split("@")[1]


def convert_to_value(symb):
    try:
        if symb.Type == "int":
            return int(symb.Value)
        elif symb.Type == "bool":
            if symb.Value == "true":
                return True
            elif symb.Value == "false":
                return False
            else:
                ErrorHandler.error(32, "symb cannot be converted: " + symb.Value)
        elif symb.Type == "string":
            if symb.Value is None:
                return ""
            return escape_sequences(str(symb.Value))
        elif symb.Type == "float":
            try:
                return float(symb.Value)
            except ValueError:
                return float.fromhex(symb.Value)
        elif symb.Type == "nil":
            return None
    except ValueError:
        ErrorHandler.error(32, "symb cannot be converted: " + symb.Value)


def escape_sequences(stri):
    sequences = re.findall(r'(\\[0-9]{3})', stri)
    for seq in sequences:
        int(seq[1:])
        stri = re.sub(r'(\\[0-9]{3})', chr(int(seq[1:])), stri, 1)
    return stri


def get_default_value(input_type):
    values = {"int": 0, "float": 0.0, "string": "", "bool": False}
    return values[input_type]


def read_input(inter):
    if inter.InputFile is not None:
        value = inter.InputFile.readline()
        if len(value) != 0:
            if value[-1] == "\n":
                value = value[0:-1:]
    else:
        value = input()
    return value


def convert_input(input_type, value):
    if input_type == "int":
        return int(value)
    elif input_type == "float":
        try:
            return float(value)
        except ValueError:
            return float.fromhex(value)
    elif input_type == "string":
        return str(value)
    elif input_type == "bool":
        return value.upper() == "TRUE"
    else:
        ErrorHandler.error(32, "Unknown type")


def get_type(symb):
    if isinstance(symb, bool):
        return "bool"
    elif isinstance(symb, int):
        return "int"
    elif isinstance(symb, float):
        return "float"
    elif isinstance(symb, str):
        return "string"
    elif symb is None:
        return "nil"
