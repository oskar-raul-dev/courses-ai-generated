# rescatado de la sesión 13793b0f, 2026-09-11T04:02:50Z · Verify README table against phase files
import re,io,glob
rd=io.open('README.md',encoding='utf-8').read()
filas=re.findall(r'^\| [^|]*\|\s*\[`(\d\d-[^`]+\.md)`\][^|]*\|\s*([^|]+)\|\s*(\d+)\s*\|', rd, re.M)
print(f"filas de fase leídas: {len(filas)}")
mal=0; th=0; te=0
for arch,horas,ejs in filas:
    s=io.open(arch,encoding='utf-8').read()
    mh=re.search(r'\*\*(\d+) horas?\*\*', s)
    me=re.search(r'Ejercicios \((\d+)\)', s)
    h=horas.strip()
    if 'sin horas' not in h:
        th+=int(mh.group(1)) if mh else 0
        if not mh or mh.group(1)+'h'!=h: mal+=1; print(f"  ⚠ {arch}: README «{h}» · archivo «{mh.group(1)+'h' if mh else '—'}»")
    te+=int(ejs)
    if not me or me.group(1)!=ejs: mal+=1; print(f"  ⚠ {arch}: README {ejs} ej · archivo {me.group(1) if me else '—'}")
print(f"desajustes: {mal}")
print(f"suma de horas de las 14 obligatorias: {th}h (README dice 108h)")
print(f"suma de ejercicios: {te} (README dice 410 + 15 = 425)")
