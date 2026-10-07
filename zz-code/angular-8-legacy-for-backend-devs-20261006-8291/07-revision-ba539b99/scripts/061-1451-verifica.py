# rescatado de la sesión ba539b99, 2026-09-11T14:51:43Z · Check accents and identifier language in the new notebook
import re,glob
# tildes y acentos en comentarios de código dentro del cuaderno nuevo
bad=r'\b(numero|version|codigo|tambien|aqui|asi|despues|sesion|razon|ultimo|ultima|deberia|ademas|dia|dias|mas|habria|seria|aca|arbol|maquina|estan|sintoma|proposito|pagina|linea|peticion|segun|unica|unico|validacion|configuracion|migracion|documentacion|aplicacion|traduccion|produccion|comprobacion|decision|situacion|coleccion|suscripcion|edicion|confirmacion|comparacion)\b'
src=open('cuaderno-incidentes.md',encoding='utf-8').read().split('\n')
infence=False;n=0
for i,l in enumerate(src,1):
    if re.match(r'^\s*```',l): infence=not infence; continue
    if not infence: continue
    m=re.search(r'(?://|#)\s*(.+)$',l)
    if m and re.findall(bad,m.group(1).lower()): n+=1;print(f'{i}: {l.strip()[:100]}')
print('comentarios sin tilde:',n)
# identificadores en español en el código del cuaderno
pat=re.compile(r'\b(?:var|let|const|function)\s+([a-záéíóúñ][A-Za-z0-9]*)')
es=re.compile(r'(?i)(pacient|orden|muestra|resultad|rango|fecha|nombre|estado|accion|vacio|forma|huerfan|correo|conteo|prueba|salida|entrada|consulta|primero|segundo|exito|acciones)')
infence=False;k=0
for i,l in enumerate(src,1):
    if re.match(r'^\s*```',l): infence=not infence; continue
    if not infence: continue
    if l.strip().startswith(('//','#')): continue
    for m in pat.finditer(l):
        if es.search(m.group(1)): k+=1;print('ID ES:',i,l.strip()[:90])
print('identificadores en español:',k)
