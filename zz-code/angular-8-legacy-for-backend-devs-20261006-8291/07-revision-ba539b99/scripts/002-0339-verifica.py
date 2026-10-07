# rescatado de la sesión ba539b99, 2026-09-11T03:39:08Z · Find mentions of nonexistent md files
import re,os,glob,collections
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
exist=set(os.path.basename(p) for p in glob.glob('*.md'))|set(os.path.basename(p) for p in glob.glob('prompts/*.md'))
bad=collections.defaultdict(list)
for f in files:
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'`([A-Za-z0-9_./-]+\.md)`',line):
            name=os.path.basename(m.group(1))
            if name not in exist and not re.search(r'NN|<|\*',name):
                bad[m.group(1)].append(f'{f}:{i}')
for k,v in sorted(bad.items()):
    print(k, '->', ', '.join(v[:6]), '' if len(v)<=6 else f'(+{len(v)-6})')
