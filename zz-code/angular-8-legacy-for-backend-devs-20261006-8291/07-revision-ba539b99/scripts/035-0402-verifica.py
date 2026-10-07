# rescatado de la sesión ba539b99, 2026-09-11T04:02:32Z · Check backticked filenames exist
import re,glob,collections,os
# 1. nombres de archivo .md citados en backticks que no existen
exist={os.path.basename(p) for p in glob.glob('*.md')}|{os.path.basename(p) for p in glob.glob('prompts/*.md')}
bad=collections.defaultdict(list)
for f in sorted(glob.glob('*.md')):
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'`([A-Za-z0-9_./-]+\.md)`',l):
            b=os.path.basename(m.group(1))
            if b not in exist and not re.search(r'NN|<|\*|\{',b): bad[m.group(1)].append(f'{f}:{i}')
print('== archivos .md citados que no existen (fuera de prompts/) ==')
for k,v in sorted(bad.items()): print(' ',k,'->',', '.join(v[:5]))
