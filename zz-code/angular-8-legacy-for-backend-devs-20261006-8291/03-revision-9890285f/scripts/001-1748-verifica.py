# rescatado de la sesión 9890285f, 2026-09-10T17:48:11Z · Count internal links vs bare filename mentions
import re,os
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
link=re.compile(r'\[[^\]]*\]\((?!http)([^)#]+)')
bare=re.compile(r'`((?:a\d\d|\d\d)-[a-z0-9-]+\.md|forense-[a-z0-9-]+\.md|cuaderno-incidentes(?:-be)?\.md)`')
rows=[]
for f in sorted(os.listdir('.')):
    if not f.endswith('.md'): continue
    s=open(f,encoding='utf-8').read()
    rows.append((f,len(link.findall(s)),len(bare.findall(s))))
print(f"{'archivo':34}{'links':>7}{'backticks':>11}")
for f,l,b in rows: print(f"{f:34}{l:>7}{b:>11}")
