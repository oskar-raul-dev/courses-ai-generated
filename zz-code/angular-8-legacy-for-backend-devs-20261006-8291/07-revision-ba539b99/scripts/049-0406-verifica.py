# rescatado de la sesión ba539b99, 2026-09-11T04:06:27Z · Check domain naming consistency
import re,glob
sus=r'\b(paciente|orden|muestra|resultado|rango|entrega|validar|crear|obtener|listar|guardar|buscar|usuario|fecha|nombre|estado)[A-Za-z]*\s*(?:=|\(|:)'
for f in sorted(glob.glob('*.md')):
    t=open(f,encoding='utf-8').read()
    for blk in re.findall(r'```[a-zA-Z]*\n(.*?)```',t,re.S):
        for l in blk.split('\n'):
            s=l.strip()
            if s.startswith(('//','#','*')): continue
            m=re.search(sus,s)
            if m and not re.search(r'["\'].*'+m.group(0)[:6],s): print(f,'|',s[:100])
