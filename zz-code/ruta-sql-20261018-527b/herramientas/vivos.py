"""Agrega entradas a los documentos vivos del curso (a08 y bitácora) y sus enlaces de índice.
Uso: python3 vivos.py a08 entradas.md   ·   python3 vivos.py bitacora entradas.md
Las entradas van al final de las entradas (antes del pie de a08, o al final de la bitácora)."""
import re, sys, unicodedata
from pathlib import Path

CURSO = Path("/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql")


def slug(h: str) -> str:
    """Ancla de GitHub: minúsculas, sin puntuación salvo guiones, espacios a guiones (conserva tildes)."""
    h = h.strip().lower()
    h = re.sub(r"[^\w\- ]", "", h, flags=re.UNICODE)
    return h.replace(" ", "-")


def main(doc: str, src: str) -> None:
    new = Path(src).read_text(encoding="utf-8").strip("\n") + "\n"
    heads = re.findall(r"^### ((E|M)-\d+ · .+)$", new, flags=re.M)
    if doc == "a08":
        p = CURSO / "a08-catalogo-de-errores.md"
        s = p.read_text(encoding="utf-8")
        foot = "\n---\n\n> 🏷️ **Este apéndice no lleva tag propio.**"
        assert s.count(foot) == 1
        s = s.replace(foot, "\n" + new + foot)
        links = " · ".join(f"[{h.split(' · ')[0]}](#{slug(h)})" for h, _ in heads)
        line = re.search(r"^- \*\*SQL Server\*\*, del track — .*?(?=\n\n|\n---)", s, flags=re.M | re.S)
        s = s[:line.end()] + " · " + links + s[line.end():]
        n = len(re.findall(r"^### E-\d+", s, flags=re.M))
        s = re.sub(r"\*\*Entradas:\*\* \d+", f"**Entradas:** {n}", s)
    else:
        p = CURSO / "bitacora-de-medicion.md"
        s = p.read_text(encoding="utf-8").rstrip("\n") + "\n\n" + new
        links = " · ".join(f"[{h.split(' · ')[0]}](#{slug(h)}) 🔒" if "sin resolver" in new.split(h, 1)[1].split("\n###")[0][:200]
                           else f"[{h.split(' · ')[0]}](#{slug(h)})" for h, _ in heads)
        row = re.search(r"^\| Track SQL Server \| ss01–ss05 \| (.*) \|$", s, flags=re.M)
        cur = row.group(1)
        cur = links if cur.strip() == "—" else cur + " · " + links
        s = s[:row.start()] + f"| Track SQL Server | ss01–ss05 | {cur} |" + s[row.end():]
    p.write_text(s, encoding="utf-8")
    print(f"{p.name}: {len(heads)} entradas")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
