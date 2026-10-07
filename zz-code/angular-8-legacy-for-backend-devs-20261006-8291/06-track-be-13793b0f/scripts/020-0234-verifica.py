# rescatado de la sesión 13793b0f, 2026-09-11T02:34:51Z · Compare master symptoms against piece titles
import re,io,glob
m=io.open('forense-master.md',encoding='utf-8').read()
filas=dict()
for f,sint,_,arch in re.findall(r'^\|\s*(\d+)\s*\|([^|]+)\|([^|]+)\|\s*`([^`]+)`\s*\|', m, re.M):
    filas[int(f)]=(sint.strip(),arch.strip())
print("=== síntoma del master vs título de la pieza ===")
for i,(sint,arch) in sorted(filas.items()):
    s=io.open(arch,encoding='utf-8').read()
    titulo=s.split('\n')[0]
    nucleo=re.sub(r'[“”"⭐🔥🧬]','',sint).strip().lower()[:40]
    ok = nucleo[:25] in titulo.lower()
    print(f"  Fase {i:2}  {'ok ' if ok else 'DIFIERE'}  master: {sint[:44]:44} | pieza: {titulo[:52]}")
