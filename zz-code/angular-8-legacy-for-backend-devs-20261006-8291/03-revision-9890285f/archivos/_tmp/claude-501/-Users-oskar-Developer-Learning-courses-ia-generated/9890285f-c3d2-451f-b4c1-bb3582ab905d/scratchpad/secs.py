import re,os,glob
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
# build section inventory per file
def secs(f):
    out=set()
    for l in open(f,encoding='utf-8'):
        m=re.match(r'#{2,4}\s+(?:[^\w\s]*\s*)?(\d+)(?:\.(\d+))?',l)
        if m:
            out.add(m.group(1))
            if m.group(2): out.add(m.group(1)+'.'+m.group(2))
    return out
inv={}
for f in glob.glob('*.md')+glob.glob('prompts/*.md'):
    inv[os.path.basename(f)]=secs(f)

# find "<file> §N" or "§N de <file>"
pat1=re.compile(r'`?([a-z0-9][a-z0-9-]*\.md)`?[^.\n]{0,40}?§\s?(\d+(?:\.\d+)?)')
pat2=re.compile(r'§\s?(\d+(?:\.\d+)?)\s+de\s+`?([a-z0-9][a-z0-9-]*\.md)`?')
bad=[]
tot=0
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    s=open(f,encoding='utf-8').read()
    hits=[(m.group(1),m.group(2)) for m in pat1.finditer(s)]+[(m.group(2),m.group(1)) for m in pat2.finditer(s)]
    for tgt,sec in hits:
        tot+=1
        b=os.path.basename(tgt)
        if b not in inv: bad.append((f,tgt,sec,'archivo inexistente')); continue
        if sec not in inv[b]: bad.append((f,tgt,sec,'sección inexistente; tiene: '+','.join(sorted(inv[b],key=lambda x:[int(y) for y in x.split('.')]))[:70]))
print("citas §archivo revisadas:",tot)
for r in bad: print(" ✗",r[0],"->",r[1],"§"+r[2],"|",r[3])
