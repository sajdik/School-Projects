class Argument:
    """Contains info about argument"""
    def __init__(self, arg_type, value):
        self.Type = arg_type
        self.Value = value

    def __str__(self):
        return " Type: " + self.Type + "  Value: \"" + self.Value + "\""
