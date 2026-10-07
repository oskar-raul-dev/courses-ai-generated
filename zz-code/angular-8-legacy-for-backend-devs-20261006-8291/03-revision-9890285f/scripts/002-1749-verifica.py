# rescatado de la sesión 9890285f, 2026-09-10T17:49:05Z · Audit forensic pieces against their format checklist
import re,os,glob
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
print(f"{'pieza':20}{'lin':>5}{'pasos':>7}{'🧨':>4}{'inc':>5}{'patrón':>8}{'apend':>7}{'fase§6':>8}")
for f in sorted(glob.glob('forense-fase-*.md')):
    s=open(f,encoding='utf-8').read()
    n=len(s.splitlines())
    pasos=len(re.findall(r'^#{2,3}\s*(?:[^\w\s]*\s*)?Paso\s',s,re.M))
    if not pasos: pasos=len(re.findall(r'Paso \d',s))
    des='🧨' in s
    inc=sorted(set(re.findall(r'[Ii]ncidente\s+\**(\d\d)',s)))
    pat='transferible' in s.lower()
    ap=sorted(set(re.findall(r'\bA(\d\d)\b',s)))
    f6=bool(re.search(r'§\s?6|sección 6',s))
    print(f"{f:20}{n:>5}{pasos:>7}{'sí' if des else '·':>4}{','.join(inc) or '·':>5}{'sí' if pat else 'NO':>8}{','.join(ap) or '·':>7}{'sí' if f6 else 'NO':>8}")
