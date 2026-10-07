# rescatado de la sesión ba539b99, 2026-09-11T03:41:12Z · Validate in-document anchor links
import re,glob,unicodedata,os
def slug(h):
    h=h.strip()
    h=re.sub(r'`','',h)
    h=re.sub(r'\*\*|\*|_','',h)
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h)
    s=h.lower()
    s=''.join(c for c in s if c.isalnum() or c in ' -_̀-ͯ' or unicodedata.category(c)=='Mn' or ord(c)>127)
    # github: remove punctuation, spaces->-
    s=re.sub(r'[^\w\s-]','',s,flags=re.U)
    s=re.sub(r'\s','-',s)
    return s
files=sorted(glob.glob('*.md'))
heads={}
for f in files:
    hs=set()
    for line in open(f,encoding='utf-8'):
        m=re.match(r'^#{1,6}\s+(.*)$',line)
        if m: hs.add(slug(m.group(1)))
    heads[f]=hs
bad=0
for f in files:
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\]\(([^)]*#[^)]+)\)',line):
            tgt=m.group(1)
            path,anc=tgt.split('#',1)
            tf = f if not path else os.path.normpath(os.path.join(os.path.dirname(f),path))
            if tf not in heads: continue
            if anc not in heads[tf]:
                bad+=1
                print(f'{f}:{i}  ->  {tgt}')
print('anclas rotas:',bad)
