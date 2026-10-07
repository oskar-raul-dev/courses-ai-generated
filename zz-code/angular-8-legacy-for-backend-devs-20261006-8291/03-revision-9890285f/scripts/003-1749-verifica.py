# rescatado de la sesión 9890285f, 2026-09-10T17:49:46Z · Verify phase-piece-master reciprocity
import re,os,glob
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
fases={f[:2]:f for f in glob.glob('[0-9][0-9]-*.md') if not f.startswith('00-convencion') and not f.startswith('00-historia')}
print(f"{'fase':30}{'→pieza':>9}{'pieza→fase':>12}{'→master':>9}")
for n in sorted(fases):
    fase=fases[n]; pieza=f'forense-fase-{n}.md'
    s=open(fase,encoding='utf-8').read(); p=open(pieza,encoding='utf-8').read() if os.path.exists(pieza) else ''
    print(f"{fase:30}{('sí' if pieza in s else 'NO'):>9}{('sí' if fase in p else 'NO'):>12}{('sí' if 'forense-master' in p else 'NO'):>9}")
