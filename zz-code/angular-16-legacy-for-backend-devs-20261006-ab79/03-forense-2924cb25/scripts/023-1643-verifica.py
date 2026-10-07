# rescatado de la sesión 2924cb25, 2026-09-11T16:43:45Z · Scan for Spanish identifiers in code blocks
import re,glob
pat=re.compile(r'\b(?:const|let|var|function|readonly)\s+([a-záéíóúñ][A-Za-z0-9áéíóúñ_]*)\b')
esp=re.compile(r'(?i)(resultado|estado(?!Ref)|accion|acciones|lista|creado|actualizado|respuesta|valor(?!ue)|nombre|fecha|usuario|plantilla|hallazgo|inspeccion|certificado|activo|cliente(?!s?Api)|previo|siguiente|contador|archivo|datos|prueba|error(?:es)?Msg|cantidad|indice|clave|elemento|numero|texto|linea|mensaje|descarga|guardar|cargar|enviar|calcular|obtener|validar|construir)')
hits={}
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    s=open(f).read(); infence=False
    for i,l in enumerate(s.split('\n'),1):
        if l.strip().startswith('```'): infence=not infence; continue
        if not infence: continue
        for m in pat.finditer(l):
            n=m.group(1)
            if esp.fullmatch(n) or esp.match(n) and len(n)>4:
                hits.setdefault(f,[]).append((i,n,l.strip()[:80]))
for f,v in hits.items():
    print('###',f)
    for i,n,l in v[:6]: print('   ',i,n,'|',l)
print('archivos con sospecha:',len(hits))
