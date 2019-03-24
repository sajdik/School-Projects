"""
    Class Analyzer performs syntax analysis
"""


class Analyzer:
    def __init__(self):
        pass

    no_args = ("CREATEFRAME", "PUSHFRAME", "POPFRAME", "RETURN", "CLEARS", "ADDS", "SUBS",
               "MULS", "IDIVS", "DIVS", "LTS", "GTS", "EQS", "ANDS", "ORS", "NOTS", "INT2CHARS",
               "STRI2INTS", "INT2FLOATS", "FLOAT2INTS", "BREAK")
    only_var = ("DEFVAR", "POPS")
    only_symb = ("PUSHS", "WRITE", "EXIT", "DPRINT")
    only_label = ("LABEL", "CALL", "JUMP", "JUMPIFEQS", "JUMPIFNEQS")
    var_and_symb = ("MOVE", "NOT", "INT2CHAR", "STRLEN", "TYPE")
    var_and_2_symb = ("ADD", "SUB", "MUL", "IDIV", "LT", "GT", "EQ", "AND", "OR", "STRI2INT", "INT2FLOAT", "FLOAT2INT",
                      "CONCAT", "GETCHAR", "SETCHAR")
    label_and_2_symb = ("JUMPIFEQ", "JUMPIFNEQ")
    var_and_type = "READ"

    Symb = ("int", "bool", "string", "float", "nil", "var")

    '''
        Analyze instr syntax - checking arguments and return false if error
    '''

    @staticmethod
    def analyze_instr(instr):
        """Perform syntactic check on instruction. Returns False in case of error"""
        instr.OpCode = instr.OpCode.upper()
        try:
            if len(instr.Args) > 3:
                return False
            if instr.OpCode in Analyzer.no_args:
                return has_no_args(instr.Args)
            elif instr.OpCode in Analyzer.only_var:
                return has_only_var(instr.Args)
            elif instr.OpCode in Analyzer.only_symb:
                return has_only_symb(instr.Args)
            elif instr.OpCode in Analyzer.only_label:
                return has_only_label(instr.Args)
            elif instr.OpCode in Analyzer.var_and_symb:
                return has_var_and_symb(instr.Args)
            elif instr.OpCode in Analyzer.var_and_2_symb:
                return has_var_and_2symb(instr.Args)
            elif instr.OpCode in Analyzer.label_and_2_symb:
                return has_label_and_2symb(instr.Args)
            elif instr.OpCode == Analyzer.var_and_type:
                return has_var_and_type(instr.Args)
            else:
                return False
        except AttributeError:
            return False

    @staticmethod
    def analyze_instr_list(instr_list):
        """Perform syntactic check on list of instruction"""
        return check_for_duplicities(instr_list) and check_orders(instr_list)


def check_for_duplicities(instr_list):
    used = set()
    for instr in instr_list:
        if instr.Order in used:
            return False
        used.add(instr.Order)
    return True


def check_orders(instr_list):
    if len(instr_list) == 0:
        return True
    return int(instr_list[-1].Order) == len(instr_list) and int(instr_list[0].Order) == 1


def has_no_args(args):
    return args[0] is args[1] is args[2] is None


def has_only_var(args):
    return args[0].Type == "var" and args[1] is args[2] is None


def has_only_symb(args):
    return args[0].Type in Analyzer.Symb and args[1] is args[2] is None


def has_only_label(args):
    return args[0].Type == "label" and args[1] is args[2] is None


def has_var_and_symb(args):
    return args[0].Type == "var" and args[1].Type in Analyzer.Symb and args[2] is None


def has_var_and_2symb(args):
    return args[0].Type == "var" and args[1].Type in Analyzer.Symb and args[2].Type in Analyzer.Symb


def has_label_and_2symb(args):
    return args[0].Type == "label" and args[1].Type in Analyzer.Symb and args[2].Type in Analyzer.Symb


def has_var_and_type(args):
    return args[0].Type == "var" and args[1].Type == "type" and args[2] is None
