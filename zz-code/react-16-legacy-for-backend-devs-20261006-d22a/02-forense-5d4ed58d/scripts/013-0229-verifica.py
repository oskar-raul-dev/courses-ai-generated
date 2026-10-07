# rescatado de la sesión 5d4ed58d, 2026-09-10T02:29:43Z · Document table exceptions and run final citation sweep
import re, io, glob, os, collections
bad=collections.Counter()
for f in [x for x in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")) if x!="completado_cuaderno_incidentes.md"]:
    for m in re.finditer(r'`([A-Za-z0-9_./-]+\.md)`', io.open(f,encoding="utf-8").read()):
        t=m.group(1)
        if re.search(r'(NN|AN|tema|slug|CLAUDE)', t): continue          # patrones de nombre, no referencias
        if t.startswith('server/') or t in ('CONTRACT.md','concurrencia.md','dinero.md','regla-del-motor.md','VEREDICTO.md'):
            continue                                                     # artefactos que el alumno crea
        if not any(os.path.exists(c) for c in (t, os.path.join("prompts",os.path.basename(t)), os.path.basename(t))):
            bad[(f,t)]+=1
for (f,t),n in sorted(bad.items()): print(f"  {f}: `{t}` ({n}x)")
print("  ninguna" if not bad else f"  ({sum(bad.values())})")
