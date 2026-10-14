#!/usr/bin/env python3
"""Extract a fenced code block from a course markdown file, as written.

Usage: CURSO=<course dir> python3 extraer/bloque.py <file.md> <text that the block contains> [nth]
Prints the block body (without the fences). Fails if no block or the nth block does not exist.
"""
import os, re, sys, textwrap
CURSO = os.environ.get("CURSO") or sys.exit("set CURSO")
path, needle = sys.argv[1], sys.argv[2]
nth = int(sys.argv[3]) if len(sys.argv) > 3 else 1
text = open(os.path.join(CURSO, path), encoding="utf-8").read()
# Fences may be indented (blocks inside list items); the indentation is removed.
blocks = [textwrap.dedent(b) for _, b in re.findall(r"^( *)```[a-zA-Z]*\n(.*?)^\1```", text, flags=re.S | re.M)]
hits = [b for b in blocks if needle in b]
if len(hits) < nth:
    sys.exit(f"no block #{nth} containing {needle!r} in {path} ({len(hits)} found)")
sys.stdout.write(hits[nth - 1])
