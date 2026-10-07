import re,os,glob
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
ap={}
for f in glob.glob('a[01][0-9]-*.md'):
    n=f[1:3]; s=set()
    for l in open(f,encoding='utf-8'):
        m=re.match(r'#{2,3}\s+(\d+)(?:\.(\d+))?\.?\s',l)
        if m:
            s.add(m.group(1))
            if m.group(2): s.add(m.group(1)+'.'+m.group(2))
    ap[n]=(f,s)
pat=re.compile(r'\bA(\d\d)\b[^.\n]{0,25}?§\s?(\d+(?:\.\d+)?)')
tot=0;bad=[]
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    for m in pat.finditer(open(f,encoding='utf-8').read()):
        n,sec=m.group(1),m.group(2); tot+=1
        if n not in ap: bad.append((f,n,sec,'apéndice inexistente')); continue
        if sec not in ap[n][1]: bad.append((f,n,sec,'no existe; tiene §'+','.join(sorted(ap[n][1],key=lambda x:[int(y) for y in x.split('.')]))))
print("citas 'ANN §N' revisadas:",tot,"| rotas:",len(bad))
for b in bad: print("  ✗",b[0],"-> A"+b[1],"§"+b[2],"|",b[3])
