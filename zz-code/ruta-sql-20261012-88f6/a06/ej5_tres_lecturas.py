import sys

path = sys.argv[1]
try:
    with open(path, encoding="utf-8", newline="") as fh:
        rows = fh.readlines()
except UnicodeDecodeError as exc:
    print("utf-8:", exc)
with open(path, encoding="utf-8", errors="ignore", newline="") as fh:
    rows = fh.readlines()
print("utf-8 con errors='ignore':", sum("Ñ" in r for r in rows), "con Ñ ·", sum("MUOZ" in r for r in rows), "con MUOZ")
with open(path, encoding="latin-1", newline="") as fh:
    rows = fh.readlines()
print("latin-1:", sum("Ñ" in r for r in rows), "con Ñ ·", sum("MUÑOZ" in r for r in rows), "con MUÑOZ")
