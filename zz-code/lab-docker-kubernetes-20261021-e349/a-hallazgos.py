"""Convierte hallazgos-candidatos.md al formato de prompts/verificacion-de-laboratorio/hallazgos.md: los tramos bajan a
###, y cada hallazgo es una viñeta en negrita con su cuerpo sangrado. Imprime el resultado."""
import pathlib, re

src = (pathlib.Path(__file__).parent / "hallazgos-candidatos.md").read_text().splitlines()
out, in_item = [], False
for line in src[1:]:
    if line.startswith("Se pasan a ") or line.startswith("# "):
        continue
    if line.startswith("## "):
        out += ["", "### " + line[3:], ""]
        in_item = False
        continue
    m = re.match(r"### (H\d+) · (.*?)( [🔴🟡🟢⚪])?$", line)
    if m:
        out += ["", f"- **{m.group(1)} · {m.group(2).rstrip('.')}.**{m.group(3) or ''}"]
        in_item = True
        continue
    if in_item:
        out.append(("  " + line) if line.strip() else "")
    elif line.strip():
        out.append(line)
text = "\n".join(out)
text = re.sub(r"\n{3,}", "\n\n", text).strip()
print(text)
