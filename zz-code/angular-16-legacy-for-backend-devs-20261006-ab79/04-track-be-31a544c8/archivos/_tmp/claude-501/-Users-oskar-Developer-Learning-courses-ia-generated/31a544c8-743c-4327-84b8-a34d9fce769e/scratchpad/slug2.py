import re, glob, unicodedata
def keep(c):
    if c.isalnum() or c == ' ' or c == '-':
        return True
    return unicodedata.category(c) == 'Mn'      # conserva el selector de variacion
def slug(t):
    return '#' + ''.join(c for c in t.strip().lower() if keep(c)).replace(' ', '-')

files = sorted(glob.glob('*.md') + glob.glob('prompts/*.md'))
bad = []
for f in files:
    s = open(f).read()
    heads = set()
    for h in re.findall(r'^#{1,6} (.+?)\s*$', s, re.M):
        heads.add(slug(h))
    for a in set(re.findall(r'\]\((#[^)\s]+)\)', s)):
        if a not in heads:
            bad.append((f, a))
print("Anclas internas rotas:", len(bad))
for f, a in bad:
    print("  X", f, a)
