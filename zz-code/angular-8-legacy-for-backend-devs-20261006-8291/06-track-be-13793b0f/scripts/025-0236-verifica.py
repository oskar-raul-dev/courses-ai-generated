# rescatado de la sesión 13793b0f, 2026-09-11T02:36:33Z · Check internal anchors and URL sanity
import re,io,glob,unicodedata
def slug(t):
    t=t.strip().lower()
    t=re.sub(r'`|\*\*|\*|__','',t)
    t=''.join(c for c in t if c.isalnum() or c in ' -_')
    return re.sub(r'\s+','-',t.strip())
print("=== anclas internas rotas en apéndices y forenses ===")
mal=0
for f in sorted(glob.glob('a[0-9][0-9]-*.md'))+sorted(glob.glob('forense-*.md')):
    s=io.open(f,encoding='utf-8').read()
    heads={slug(h) for h in re.findall(r'^#{2,4}\s*(.+)$', s, re.M)}
    for m in re.finditer(r'\]\(#([^)]+)\)', s):
        a=m.group(1)
        if a not in heads:
            print(f"  {f}: #{a}"); mal+=1
print("  rotas:",mal)
print("\n=== URLs: formato y sospechosas ===")
urls=[]
for f in glob.glob('*.md'):
    urls+= [(f,u) for u in re.findall(r'https?://[^\s\)\]`>]+', io.open(f,encoding='utf-8').read())]
print("  total URLs:",len(urls))
import collections
raras=[(f,u) for f,u in urls if re.search(r'ejemplo|example\.com|TODO|xxx|localhost:\d+/algo', u)]
print("  sospechosas:", len(raras))
for f,u in raras[:6]: print("   ",f,u)
dom=collections.Counter(re.sub(r'https?://([^/]+).*',r'\1',u) for _,u in urls)
print("  dominios top:", dom.most_common(6))
