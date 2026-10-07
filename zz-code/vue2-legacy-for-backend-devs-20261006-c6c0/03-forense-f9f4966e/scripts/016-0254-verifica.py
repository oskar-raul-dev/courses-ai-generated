# rescatado de la sesión f9f4966e, 2026-09-10T02:54:26Z · Verify formatting of inserted blocks
import io,glob,re
n=0
for f in glob.glob('0*/*.md')+['README.md']:
    s=io.open(f,encoding='utf-8').read()
    if re.search(r'\n---\n\s*\n---\n', s): print("doble separador:",f); n+=1
print("archivos con doble separador:",n)
