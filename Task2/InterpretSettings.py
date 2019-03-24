class InterpretSettings:
    """Stores info about interpret current settings"""
    def __init__(self, source, input_file, stats_output_file, insts_stat, vars_stat, vars_first):
        self.Source = source
        self.Input = input_file
        self.Stats = stats_output_file
        self.Insts = insts_stat
        self.Vars = vars_stat
        self.VarFirst = vars_first

    def __str__(self):
        return "Source:" + str(self.Source) + ", Input:" + str(self.Input) + ", Stats:" + str(self.Stats) \
               + ", Insts:" + str(self.Insts) + ", Vars:" + str(self.Vars) + "VarsFirstL " + str(self.VarsFirst)
