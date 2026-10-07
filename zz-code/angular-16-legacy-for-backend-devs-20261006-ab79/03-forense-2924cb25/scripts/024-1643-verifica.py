# rescatado de la sesión 2924cb25, 2026-09-11T16:43:57Z · Scan for Spanish method names and JSON keys
import re,glob
esp=re.compile(r'\b(descargar|guardar|cargar|enviar|calcular|obtener|validar|construir|buscar|eliminar|actualizar|crear|abrir|cerrar|mostrar|ocultar|listar|filtrar|ordenar|resolver|emitir|revocar|aprobar|rechazar)\s*\(')
key=re.compile(r'"(requiere[A-Z]|severidad|nombre|fecha|estado|version[A-Z]|plantilla|hallazgo|inspeccion|certificado|cliente|activo)[A-Za-z]*"\s*:')
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    if '_deprecado' in f: continue
    s=open(f).read().split('\n'); infence=False
    for i,l in enumerate(s,1):
        if l.strip().startswith('```'): infence=not infence; continue
        if not infence: continue
        for rx,tag in ((esp,'método'),(key,'clave')):
            m=rx.search(l)
            if m: print(f'{f}:{i} [{tag}] {l.strip()[:90]}')
