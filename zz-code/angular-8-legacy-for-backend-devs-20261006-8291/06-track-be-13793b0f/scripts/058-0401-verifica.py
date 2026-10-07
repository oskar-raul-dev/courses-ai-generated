# rescatado de la sesión 13793b0f, 2026-09-11T04:01:17Z · Full inventory of the angular-16 course
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()
print("═══ INVENTARIO ═══")
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p) and 'convencion' not in p and 'historia' not in p)
print(f"  fases numeradas: {len(fases)} → {[f[:2] for f in fases]}")
print(f"  documentos 00-* de encuadre: {[p for p in glob.glob('00-*.md') if p not in fases]}")
print(f"  apéndices: {len(glob.glob('a[0-9][0-9]-*.md'))}")
print(f"  piezas forenses: {len(glob.glob('forense-fase-*.md'))} + master")
print(f"  cuadernos: {glob.glob('cuaderno-*.md')}")
print(f"  prompts: {len(glob.glob('prompts/*'))} archivos")
print(f"  archivos del track BE en disco: {glob.glob('be0*.md')+glob.glob('bea-*.md')} (debe estar vacío: es propuesto)")
