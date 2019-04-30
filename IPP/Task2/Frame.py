from ErrorHandler import ErrorHandler


class Frame:
    """Storing variables, info about them and their values"""
    def __init__(self):
        self.store = dict()
        self.initialized = set()

    def define(self, name):
        """Define variable in frame"""
        assert name is not str
        if name in self.store:
            ErrorHandler.error(52, "Variable redefinition")
        self.store[name] = None

    def __setitem__(self, name, value):
        if name not in self.store:
            ErrorHandler.error(54, "Accessing to non existing variable (set)")
        self.store[name] = value

    def __getitem__(self, name):
        if name not in self.store:
            ErrorHandler.error(54, "Accessing to non existing variable (get)")
        return self.store[name]

    def __len__(self):
        return len(self.store)

    def __contains__(self, item):
        return item in self.store.keys()

    def __str__(self):
        result = ""
        for key in self.store.keys():
            result += "[" + key + ":" + str(self[key]) + "]"
        return result
