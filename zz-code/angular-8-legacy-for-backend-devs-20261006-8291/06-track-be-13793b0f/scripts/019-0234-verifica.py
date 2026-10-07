# rescatado de la sesión 13793b0f, 2026-09-11T02:34:28Z · Check forensic headers and master structure
import re,io,glob
print("=== Encabezado de cada pieza: herramientas · tiempo · síntoma ===")
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    head='\n'.join(s.split('\n')[:12])
    tiene_h=bool(re.search(r'Herramientas?:', head))
    tiene_t=bool(re.search(r'\b\d+\s*[-–]?\s*\d*\s*min|minutos', head))
    tiene_s=bool(re.search(r'S[ií]ntoma:', head))
    fase=bool(re.search(r'Fase\s+\d+', head))
    flags=[n for n,v in [('herramientas',tiene_h),('tiempo',tiene_t),('síntoma',tiene_s),('fase',fase)] if not v]
    print(f"  {f:22} {'ok' if not flags else 'FALTA: '+', '.join(flags)}")
print()
m=io.open('forense-master.md',encoding='utf-8').read()
print("=== forense-master: bloques ===")
for k,lbl in [('método|cuatro preguntas','1 método'),('📇','2 índice piezas'),('🩺','3 síntomas transversal'),('🧰','4 herramientas'),('HOTFIX','5 cierre→HOTFIX.md')]:
    print(f"  {lbl:24} {'ok' if re.search(k,m,re.I) else 'FALTA'}")
filas=len(re.findall(r'^\|', m, re.M))
print(f"  filas de tabla en el master: {filas}")
