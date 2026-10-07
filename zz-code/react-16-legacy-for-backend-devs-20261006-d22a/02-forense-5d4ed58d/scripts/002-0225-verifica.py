# rescatado de la sesión 5d4ed58d, 2026-09-10T02:25:28Z · Check markdown links and file citations
import re, os, glob, collections
files = sorted([f for f in glob.glob("*.md")] + glob.glob("prompts/*.md"))
files = [f for f in files if f != "completado_cuaderno_incidentes.md"]
print(f"archivos revisados: {len(files)}\n")

# 1. enlaces markdown [x](y.md)
bad = []
for f in files:
    base = os.path.dirname(f)
    for m in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)', open(f, encoding='utf-8').read()):
        target = m.group(2).split('#')[0]
        if not target or target.startswith(('http','mailto:')): continue
        p = os.path.normpath(os.path.join(base, target))
        if not os.path.exists(p):
            bad.append((f, m.group(2)))
print("== 1. ENLACES MARKDOWN ROTOS ==")
print("\n".join(f"  {f} -> {t}" for f,t in bad) or "  ninguno")

# 2. nombres de archivo .md citados entre backticks
bad2 = collections.Counter()
for f in files:
    for m in re.finditer(r'`([A-Za-z0-9_./-]+\.md)`', open(f, encoding='utf-8').read()):
        t = m.group(1)
        cands = [t, os.path.join("prompts", os.path.basename(t)), os.path.basename(t)]
        if not any(os.path.exists(c) for c in cands):
            bad2[(f, t)] += 1
print("\n== 2. ARCHIVOS .md CITADOS QUE NO EXISTEN ==")
print("\n".join(f"  {f}: `{t}` ({n}x)" for (f,t),n in sorted(bad2.items())) or "  ninguno")
