#!/usr/bin/env python3
"""P11: applies exact replacements to a file and fails if any old text is missing or ambiguous.

Usage: reemplazar.py FILE PAIRS.py   (PAIRS.py defines PAIRS = [(old, new), ...])
"""
import runpy, sys
path, pairs_file = sys.argv[1], sys.argv[2]
pairs = runpy.run_path(pairs_file)["PAIRS"]
text = open(path, encoding="utf-8").read()
for i, (old, new) in enumerate(pairs, 1):
    n = text.count(old)
    if n != 1:
        sys.exit(f"{path}: pair {i} found {n} times: {old[:80]!r}")
    text = text.replace(old, new)
open(path, "w", encoding="utf-8").write(text)
print(f"{path}: {len(pairs)} replacements")
