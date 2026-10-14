# T2/T3 (D8): patient identifiers CC-/TI-/CE- -> HC-/PP-/LB- in every course file, and the two regexes.
import os, re, sys
CURSO = os.environ["CURSO"]
MAP = {"CC": "HC", "TI": "PP", "CE": "LB"}
ident = re.compile(r"\b(CC|TI|CE)-(?=[0-9…])")
alt = re.compile(r"\(CC\|TI\|CE\)")
total = 0
for root, _, files in os.walk(CURSO):
    for f in files:
        if not f.endswith(".md") or "_desechable" in f or "_deprecado" in f:
            continue
        p = os.path.join(root, f)
        s = open(p, encoding="utf-8").read()
        n = len(ident.findall(s)) + len(alt.findall(s))
        if n:
            s = ident.sub(lambda m: MAP[m.group(1)] + "-", s)
            s = alt.sub("(HC|PP|LB)", s)
            open(p, "w", encoding="utf-8").write(s)
            print(f"{n:3d}  {os.path.relpath(p, CURSO)}"); total += n
print(total, "reemplazos")
