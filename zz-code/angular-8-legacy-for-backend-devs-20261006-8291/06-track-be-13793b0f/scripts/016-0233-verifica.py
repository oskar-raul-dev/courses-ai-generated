# rescatado de la sesión 13793b0f, 2026-09-11T02:33:40Z · Check notebook-to-forensic link and cost-order declaration
import re,io,glob
pat=re.compile(r'barat|m[aá]s caro|cuesta diez segundos|de menos a m[aá]s|orden no es', re.I)
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    print(f"{f:22} {'ok' if pat.search(s) else 'NO DECLARA el orden'}")
