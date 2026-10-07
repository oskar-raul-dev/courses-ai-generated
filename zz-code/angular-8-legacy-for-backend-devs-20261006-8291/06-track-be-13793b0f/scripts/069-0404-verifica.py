# rescatado de la sesión 13793b0f, 2026-09-11T04:04:16Z · Final version coherence check
import re,io,glob
print("═══ COHERENCIA DE VERSIONES CONTRA EL STACK DEL README ═══")
stack={'Angular':'16.2.12','Material':'16.2.14','RxJS':'7.8.1','TypeScript':'5.1.6',
       'Node':'18.18.2','jspdf':'2.5.1','zone.js':'0.13.3','json-server':'0.17.4'}
pat={'Angular':r'Angular\s+(\d+\.\d+\.\d+)','Material':r'Material[^\n]{0,24}?(\d+\.\d+\.\d+)',
 'RxJS':r'RxJS\s+(\d+\.\d+\.\d+)','TypeScript':r'TypeScript\s+(\d+\.\d+\.\d+)',
 'Node':r'Node\s+(\d+\.\d+\.\d+)','jspdf':r'jspdf[`\s@]+(\d+\.\d+\.\d+)',
 'zone.js':r'zone\.js[`\s@]+(\d+\.\d+\.\d+)','json-server':r'json-server[`\s@]+(\d+\.\d+\.\d+)'}
avisos=0
for f in sorted(glob.glob('*.md')):
    s=io.open(f,encoding='utf-8').read(); malos=[]
    for k,p in pat.items():
        for v in set(re.findall(p,s)):
            if v!=stack[k]: malos.append(f"{k}={v}")
    if malos:
        avisos+=1
        nota='(esperado: es el apéndice de migración)' if f.startswith('a10') else ''
        print(f"  {f:34} {', '.join(sorted(set(malos)))} {nota}")
print(f"  archivos con versiones fuera del stack: {avisos}")
