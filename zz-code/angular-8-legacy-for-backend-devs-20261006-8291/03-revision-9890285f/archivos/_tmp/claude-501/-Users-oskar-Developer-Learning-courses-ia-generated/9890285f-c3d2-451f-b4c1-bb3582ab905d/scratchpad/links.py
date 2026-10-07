import re,os,sys,collections
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
files=[f for f in sorted(os.listdir('.')) if f.endswith('.md')]
files+=['prompts/'+f for f in sorted(os.listdir('prompts')) if f.endswith('.md')]
link=re.compile(r'\[([^\]]*)\]\(([^)]+)\)')
bad=collections.defaultdict(list)
ext=collections.Counter()
for f in files:
    s=open(f,encoding='utf-8').read()
    for m in link.finditer(s):
        t=m.group(2).strip()
        if t.startswith('http'):
            ext[t]+=1; continue
        if t.startswith('#'): continue
        path=t.split('#')[0]
        base=os.path.dirname(f)
        full=os.path.normpath(os.path.join(base,path))
        if not os.path.exists(full):
            bad[f].append((m.group(1)[:40],t))
for f,v in bad.items():
    print("BROKEN",f)
    for a,b in v: print("   ",b,"   <-",a)
print("total externos:",sum(ext.values()),"unicos:",len(ext))
