import re

from ErrorHandler import ErrorHandler
from InterpretSettings import InterpretSettings
import sys


class ProgramArgumentsHandler:
    """Handles arguments inserted through command line to program"""
    def __init__(self):
        pass

    @staticmethod
    def handle(argv):
        """Analyze arguments and returns int settings"""
        source = None
        input_file = None
        stat_output_file = None
        insts_stat = False
        vars_stat = False
        vars_first = None
        for arg in argv[1:]:
            if arg == "--help":
                if len(argv) > 2:
                    ErrorHandler.error(10, "--help in combination with other arguments")
                print_help()
                sys.exit(0)
            elif re.search("^--source=(.+)$", arg):
                source = re.match("^--source=(.+)$", arg)[1]
            elif re.search("^--input=(.+)$", arg):
                input_file = re.match("^--input=(.+)$", arg)[1]
            elif re.search("^--stats=(.+)$", arg):
                stat_output_file = re.match("^--stats=(.+)$", arg)[1]
            elif arg == "--insts":
                if vars_first is None:
                    vars_first = False
                insts_stat = True
            elif arg == "--vars":
                if vars_first is None:
                    vars_first = True
                vars_stat = True
            else:
                ErrorHandler.error(10, "Unknown argument")

        if (insts_stat or vars_stat) and stat_output_file is None or source is None and input_file is None:
            ErrorHandler.error(10, "Unsupported combination of arguments")

        return InterpretSettings(source, input_file, stat_output_file, insts_stat, vars_stat, vars_first)


def print_help():
    print("Program loads XML representation of program from source file\n"
          "and interprets this program using stdin and stdout\n"
          "Usage: \n"
          "python3 interpret.py <arguments>\n"
          "List of arguments: --help, --source=<source_file>, --input=<input_file>, --stats=<output_file>, --vars, "
          "--insts\n "
          "Example: python3 interpret.py --source=<source_file>\n")
