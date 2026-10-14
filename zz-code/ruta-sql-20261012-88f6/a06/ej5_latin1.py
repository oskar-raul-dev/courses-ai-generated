import sys

path = sys.argv[1]
try:
    with open(path, encoding="utf-8") as fh:
        rows = fh.readlines()
except UnicodeDecodeError as exc:
    print("utf-8:", exc)
with open(path, encoding="latin-1", newline="") as fh:
    rows = fh.readlines()
print("latin-1:", len(rows) - 1, "filas,", sum("Ñ" in r for r in rows), "con Ñ")
