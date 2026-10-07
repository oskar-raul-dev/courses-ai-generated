# rescatado de la sesión 13793b0f, 2026-09-11T02:34:14Z · Check version coherence across appendices and forensics
import re,io,glob
fijado={'Angular':'16.2.12','Material':'16.2.14','RxJS':'7.8.1','TypeScript':'5.1.6',
        'Node':'18.18.2','npm':'9.8.1','jsPDF/jspdf':'2.5.1','zone.js':'0.13.3',
        'json-server':'0.17.4','Chart.js':'4.4','Jasmine':'4.6','Karma':'6.4',
        'ng2-charts':'4.1.1','Express':'4.18.2','jsonwebtoken':'9.0.2'}
print("Versiones que aparecen en apéndices y forenses, y si chocan con el stack:")
patrones={'Angular':r'Angular\s+(\d+\.\d+\.\d+)','Material':r'Material[^\n]{0,20}?(\d+\.\d+\.\d+)',
 'RxJS':r'RxJS\s+(\d+\.\d+\.\d+)','TypeScript':r'TypeScript\s+(\d+\.\d+\.\d+)',
 'Node':r'Node\s+(\d+\.\d+\.\d+)','jspdf':r'jspdf[`\s]+(\d+\.\d+\.\d+)',
 'zone.js':r'zone\.js[`\s]+(\d+\.\d+\.\d+)','json-server':r'json-server[`\s@]+(\d+\.\d+\.\d+)'}
for f in sorted(glob.glob('a[0-9][0-9]-*.md'))+sorted(glob.glob('forense-*.md')):
    s=io.open(f,encoding='utf-8').read(); avisos=[]
    for k,p in patrones.items():
        for v in set(re.findall(p,s)):
            esperado={'Angular':'16.2.12','Material':'16.2.14','RxJS':'7.8.1','TypeScript':'5.1.6',
                      'Node':'18.18.2','jspdf':'2.5.1','zone.js':'0.13.3','json-server':'0.17.4'}[k]
            if not v.startswith(esperado[:4]) and v!=esperado:
                avisos.append(f"{k}={v}")
    if avisos: print(f"  {f:34} {', '.join(sorted(set(avisos)))}")
print("  (las de migración A10/A11 mencionan otras a propósito)")
