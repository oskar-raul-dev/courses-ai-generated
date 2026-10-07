# rescatado de la sesión 073aaed3, 2026-10-06T00:05:49Z · 
import re,glob,unicodedata,collections
def es(c):
    cp=ord(c);return unicodedata.category(c)=="So" or 0x1F000<=cp<=0x1FAFF or 0x2600<=cp<=0x27BF
h=collections.Counter();co=collections.Counter()
for f in glob.glob("*.md"):
    fence=False
    for l in open(f,encoding="utf-8"):
        if l.lstrip().startswith("```"): fence=not fence;continue
        if fence: continue
        if l.startswith("### "):
            for c in l:
                if es(c): h[c]+=1
        m=re.match(r"^> (\S+) \*\*",l)
        if m: co[m.group(1)]+=1
print(sorted(h.items(),key=lambda x:-x[1]));print(sorted(co.items(),key=lambda x:-x[1]))
