# rescatado de la sesión ba539b99, 2026-09-11T04:03:26Z · Check runtime version consistency
import re,glob,collections
pats={'Node':r'Node\s+\**(1[0-9]\.\d+\.\d+)',
 'npm':r'npm\s+(6\.\d+\.\d+)',
 'node-sass':r'node-sass`?\s+(4\.\d+\.\d+)',
 'MongoDB tags':r'mongo:(\d+\.\d+(?:\.\d+)?)',
 'Mongo driver':r'mongo-java-driver[`\s]+(\d+\.\d+\.\d+)',
 'Java':r'Java\s+(\d+)\b',
 'Maven':r'Maven\s+(3\.\d+\.\d+)'}
for k,p in pats.items():
    c=collections.Counter()
    for f in glob.glob('*.md'):
        for v in re.findall(p,open(f,encoding='utf-8').read()): c[v]+=1
    print(('⚠️  ' if len(c)>1 else 'ok  ')+k, dict(c))
