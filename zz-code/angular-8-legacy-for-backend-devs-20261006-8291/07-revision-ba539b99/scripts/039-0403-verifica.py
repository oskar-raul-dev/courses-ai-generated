# rescatado de la sesión ba539b99, 2026-09-11T04:03:17Z · Check stack version consistency
import re,glob,collections
# versiones del stack citadas, para detectar contradicciones
pats={
 'Angular': r'Angular\s+(8\.\d+\.\d+)',
 'CLI': r'CLI\s+(8\.\d+\.\d+)',
 'TypeScript': r'TypeScript\s+(3\.\d+\.\d+)',
 'RxJS': r'RxJS\s+(6\.\d+\.\d+)',
 'NgRx': r'NgRx\s+(8\.\d+\.\d+)',
 'Material': r'(?:Material(?: y CDK)?)\s+(8\.\d+\.\d+)',
 'zone.js': r'zone\.js\s+(0\.\d+\.\d+)',
 'node-sass': r'node-sass\s+(4\.\d+\.\d+)',
 'jsPDF': r'jsPDF\s+(1\.\d+\.\d+)',
 'Bootstrap': r'Bootstrap\s+(4\.\d+\.\d+)',
 'json-server': r'json-server\s+(0\.\d+\.\d+)',
 'ngx-translate': r'@ngx-translate/core[`\s]+(\d+\.\d+\.\d+)',
 'Spring Boot': r'Spring Boot\s+(2\.\d+\.\d+)',
}
for k,p in pats.items():
    c=collections.Counter()
    for f in glob.glob('*.md'):
        for v in re.findall(p,open(f,encoding='utf-8').read()): c[v]+=1
    if len(c)>1: print('⚠️ ',k,dict(c))
    elif c: print('ok',k,list(c)[0],f'({sum(c.values())} menciones)')
