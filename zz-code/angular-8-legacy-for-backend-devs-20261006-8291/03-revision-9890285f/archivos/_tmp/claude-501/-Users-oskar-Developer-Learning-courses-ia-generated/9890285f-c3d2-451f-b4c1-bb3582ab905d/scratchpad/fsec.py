import re,os,glob
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
fa={}
for f in glob.glob('[0-9][0-9]-*.md'):
    if f.startswith(('00-convencion','00-historia')): continue
    n=str(int(f[:2])); s=set()
    for l in open(f,encoding='utf-8'):
        m=re.match(r'#{2,4}\s+(?:[^\w\s]*\s*)?(\d+)(?:\.(\d+))?\.?\s',l)
        if m:
            s.add(m.group(1))
            if m.group(2): s.add(m.group(1)+'.'+m.group(2))
    fa[n]=(f,s)
pat=re.compile(r'[Ff]ase\s+(\d{1,2})\s*§\s?(\d+(?:\.\d+)?)')
tot=0;bad=[]
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    for m in pat.finditer(open(f,encoding='utf-8').read()):
        n,sec=m.group(1),m.group(2); tot+=1
        n=str(int(n))
        if n not in fa: bad.append((f,n,sec,'fase inexistente')); continue
        if sec not in fa[n][1]: bad.append((f,n,sec,fa[n][0]+' tiene §'+','.join(sorted(fa[n][1],key=lambda x:[int(y) for y in x.split('.')]))[:60]))
print("citas 'Fase N §M' revisadas:",tot,"| rotas:",len(bad))
for b in bad: print("  ✗",b[0],"-> Fase",b[1],"§"+b[2],"|",b[3])
