# rescatado de la sesión 9890285f, 2026-09-10T17:49:58Z · Audit appendix structure and references
import re,os,glob
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
print(f"{'apéndice':24}{'lin':>5}{'índice':>8}{'ejerc':>7}{'refs':>6}{'URLs':>6}{'🏷️':>4}{'👁️/✍️':>7}{'links':>6}")
for f in sorted(glob.glob('a[01][0-9]-*.md')):
    s=open(f,encoding='utf-8').read()
    n=len(s.splitlines())
    idx=bool(re.search(r'salto rápido|Índice|índice',s))
    ej=len(re.findall(r'^\s*\d+\.\s',s,re.M))
    ejs=bool(re.search(r'[Ee]jercicios',s))
    refs=bool(re.search(r'Referencias|Bibliograf|Para seguir',s))
    urls=len(re.findall(r'https?://',s))
    tag='🏷️' in s
    eyes=('👁️' in s or '✍️' in s)
    links=len(re.findall(r'\[[^\]]*\]\((?!http)',s))
    print(f"{f:24}{n:>5}{('sí' if idx else 'NO'):>8}{('sí' if ejs else 'NO'):>7}{('sí' if refs else 'NO'):>6}{urls:>6}{('sí' if tag else '·'):>4}{('sí' if eyes else '·'):>7}{links:>6}")
