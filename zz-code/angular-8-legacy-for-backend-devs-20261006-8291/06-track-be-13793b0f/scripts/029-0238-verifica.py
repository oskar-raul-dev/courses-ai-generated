# rescatado de la sesión 13793b0f, 2026-09-11T02:38:10Z · Verify appendix hours and exercise totals against README
import re,io,glob
rd=io.open('README.md',encoding='utf-8').read()
tabla=dict((m.group(1), m.group(2)) for m in re.finditer(r'\[`(a\d\d-[^`]+\.md)`\][^|]*\|[^|]*\|\s*(\d+)h\s*\|', rd))
print("apéndice  README  cabecera  ejercicios")
tot_h=0; tot_e=0
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    s=io.open(a,encoding='utf-8').read()
    h=re.search(r'\*\*(\d+)\s*horas?\*\*', s)
    e=re.search(r'Ejercicios?\s*\((\d+)', s)
    rh=tabla.get(a,'?')
    ok='' if (h and rh==h.group(1)) else '  ⚠ DIFIERE'
    tot_h+=int(rh) if rh.isdigit() else 0; tot_e+=int(e.group(1)) if e else 0
    print(f"  {a[:3]}      {rh}h      {h.group(1)+'h' if h else '(sin)':6}    {e.group(1) if e else '?':3}{ok}")
print(f"  TOTALES  {tot_h}h                 {tot_e}   (README dice 33h y 93 ejercicios)")
