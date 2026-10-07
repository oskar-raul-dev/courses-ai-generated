# rescatado de la sesión 9890285f, 2026-09-10T17:55:01Z · Quantify linked vs unlinked cross-references
import re,glob,os
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
print(f"{'archivo':24}{'menciones ANN':>15}{'de ellas link':>15}{'menciones Fase N':>18}{'link':>7}")
for f in sorted(glob.glob('a[01][0-9]-*.md'))+sorted(glob.glob('forense-fase-*.md')):
    s=open(f,encoding='utf-8').read()
    men=len(re.findall(r'\bA\d\d\b',s))
    lin=len(re.findall(r'\[[^\]]*A\d\d[^\]]*\]\(',s))+len(re.findall(r'\]\(\.?/?a\d\d-',s))
    fm=len(re.findall(r'\bFase\s+\d{1,2}\b',s))
    fl=len(re.findall(r'\]\(\.?/?\d\d-',s))
    print(f"{f:24}{men:>15}{lin:>15}{fm:>18}{fl:>7}")
