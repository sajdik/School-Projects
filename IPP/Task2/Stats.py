from ErrorHandler import ErrorHandler


class Stats:
    """Stores stats about interpretation"""
    def __init__(self):
        self.Instr = -1
        self.Vars = 0

    def save(self, options):
        """Saves stats to file in format defined in options"""
        output_file = options.Stats
        vars_first = options.VarFirst
        try:
            with open(output_file, "w") as file:
                if vars_first:
                    if options.Vars:
                        print(str(self.Vars), file=file)
                    if options.Insts:
                        print(str(self.Instr), file=file)
                else:
                    if options.Insts:
                        print(str(self.Instr), file=file)
                    if options.Vars:
                        print(str(self.Vars), file=file)
        except Exception:
            ErrorHandler.error(12, "Cannot open output file for stats: " + str(output_file))
