# rescatado de la sesión 31a544c8, 2026-09-12T02:18:32Z · Check version pin consistency across the course
import re,glob,collections
pins={
 'Angular': r'\b16\.2\.12\b', 'TypeScript': r'\b5\.1\.6\b', 'RxJS': r'\b7\.8\.1\b',
 'Material/CDK': r'\b16\.2\.14\b', 'zone.js': r'\b0\.13\.3\b', 'Node': r'\b18\.18\.2\b',
 'npm': r'\b9\.8\.1\b', 'jsPDF': r'\b2\.5\.1\b', 'json-server': r'\b0\.17\.4\b',
 'PHP': r'\b7\.4\.33\b', 'Lumen': r'\b5\.8\.13\b', 'Postgres': r'\b16\.9\b',
}
files=glob.glob('*.md')
print("Versiones fijadas — apariciones y contradicciones evidentes:")
for name,rx in pins.items():
    n=sum(len(re.findall(rx, open(f).read())) for f in files)
    print(f"  {name:<14} {n:>4} apariciones")
# buscar versiones de Angular distintas de 16.2.12 escritas como x.y.z
alt=collections.Counter()
for f in files:
    for m in re.findall(r'[Aa]ngular\s+(\d+\.\d+\.\d+)', open(f).read()):
        if m!='16.2.12': alt[m]+=1
print("\n  Otras versiones de Angular con patch citadas:", dict(alt) or "✅ ninguna")
# TS / rxjs alternativas
for label,rx,good in [('TypeScript',r'TypeScript\s+(\d+\.\d+\.\d+)','5.1.6'),
                      ('RxJS',r'RxJS\s+(\d+\.\d+\.\d+)','7.8.1'),
                      ('Node',r'Node\s+(\d+\.\d+\.\d+)','18.18.2'),
                      ('Lumen',r'Lumen\s+(\d+\.\d+\.\d+)','5.8.13')]:
    c=collections.Counter(m for f in files for m in re.findall(rx, open(f).read()) if m!=good)
    print(f"  Otras de {label}:", dict(c) or "✅ ninguna")
