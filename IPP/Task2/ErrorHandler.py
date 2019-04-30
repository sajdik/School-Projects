import sys


class ErrorHandler:
    """Performs reactions on error situations"""
    Interpret = None

    def __init__(self):
        pass

    @staticmethod
    def error(err_code, err_message):
        """Prints err_message on stderr and exit program with err_code"""
        print("Int: " + err_message, file=sys.stderr)
        if ErrorHandler.Interpret is not None:
            if ErrorHandler.Interpret.Options.Stats is not None:
                ErrorHandler.Interpret.Stats.save(ErrorHandler.Interpret.Options)
        sys.exit(err_code)
