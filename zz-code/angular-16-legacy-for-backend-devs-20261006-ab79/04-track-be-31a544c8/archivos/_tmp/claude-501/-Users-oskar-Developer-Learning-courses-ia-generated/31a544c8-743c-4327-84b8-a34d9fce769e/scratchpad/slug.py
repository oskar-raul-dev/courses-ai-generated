import re, glob, os, sys
# github-slugger: minusculas, elimina puntuacion (el guion NO), espacios -> guiones.
# U+FE0F (selector de variacion) NO se elimina: por eso "## <warn> Advertencias"
# produce un ancla que empieza por el selector.
ranges = [(0x00,0x1F),(0x21,0x2C),(0x2E,0x2F),(0x3A,0x40),(0x5B,0x5E),(0x60,0x60),(0x7B,0x7E)]
def strip_punct(t):
    return ''.join(c for c in t if not any(a <= ord(c) <= b for a,b in ranges))
def slug(t):
    return '#' + strip_punct(t.strip().lower()).replace(' ', '-')

files = sorted(glob.glob('*.md') + glob.glob('prompts/*.md'))
bad = []
for f in files:
    s = open(f).read()
    heads = {}
    for h in re.findall(r'^#{1,6} (.+?)\s*$', s, re.M):
        a = slug(h); heads[a] = heads.get(a, 0) + 1
    for a in re.findall(r'\]\((#[^)\s]+)\)', s):
        if a not in heads: bad.append((f, a))
    dup = [k for k, v in heads.items() if v > 1]
    if dup: print("  dup en", f, dup[:3])
print("Anclas internas rotas:", len(bad))
for f, a in bad: print("  X", f, a)
