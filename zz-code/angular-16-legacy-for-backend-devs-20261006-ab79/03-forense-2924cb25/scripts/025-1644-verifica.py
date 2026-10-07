# rescatado de la sesión 2924cb25, 2026-09-11T16:44:22Z · Final verification sweep
import re,glob
esp=re.compile(r'\b(descargar|guardar|cargar|enviar|calcular|obtener|validar|construir|buscar|eliminar|actualizar|crear|abrir|cerrar|mostrar|listar|filtrar|ordenar|resolver|emitir|revocar|aprobar|rechazar)\s*\(')
n=0
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    if '_deprecado' in f: continue
    infence=False
    for i,l in enumerate(open(f).read().split('\n'),1):
        if l.strip().startswith('```'): infence=not infence; continue
        if infence and esp.search(l): print(f'{f}:{i} {l.strip()[:80]}'); n+=1
print('identificadores en español:',n)
