# rescatado de la sesión 9890285f, 2026-09-10T17:54:30Z · Verify appendix usage declarations against actual phase references
import re,glob,os
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
fases={}
for f in glob.glob('[0-9][0-9]-*.md'):
    if f.startswith(('00-convencion','00-historia')): continue
    fases[int(f[:2])]=open(f,encoding='utf-8').read()
for f in sorted(glob.glob('a[01][0-9]-*.md')):
    s=open(f,encoding='utf-8').read()
    n=f[1:3]
    m=re.search(r'Usado por:\s*(.+)',s)
    if not m: print(f"{f}: sin 'Usado por'"); continue
    decl=set(int(x) for x in re.findall(r'\b(\d{1,2})\b',m.group(1).split('·')[0]))
    real=set(k for k,v in fases.items() if re.search(r'\bA'+n+r'\b',v))
    falta=sorted(decl-real); extra=sorted(real-decl)
    st=[]
    if falta: st.append("declara y NO la cita: "+str(falta))
    if extra: st.append("la cita y no está declarada: "+str(extra))
    print(f"A{n}  decl={sorted(decl)}  real={sorted(real)}  {'  ⚠ '+' | '.join(st) if st else '✓'}")
