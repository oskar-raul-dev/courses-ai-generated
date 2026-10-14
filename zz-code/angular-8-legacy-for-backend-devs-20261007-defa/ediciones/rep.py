"""Tiny helper for the edit scripts: exact, unique replacement in a course file."""
import os
CURSO = os.environ["CURSO"]
class Archivo:
    def __init__(self, rel):
        self.path = os.path.join(CURSO, rel)
        self.s = open(self.path, encoding="utf-8").read()
    def rep(self, a, b, count=1):
        n = self.s.count(a)
        assert n == count, f"{self.path}: expected {count}, found {n}: {a[:80]!r}"
        self.s = self.s.replace(a, b)
        return self
    def between(self, start, end, new):
        i = self.s.index(start); j = self.s.index(end, i)
        self.s = self.s[:i] + new + self.s[j:]
        return self
    def save(self):
        open(self.path, "w", encoding="utf-8").write(self.s)
