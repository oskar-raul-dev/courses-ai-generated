# rescatado de la sesión 13793b0f, 2026-09-11T02:37:10Z · Confirm the variation selector hypothesis
grep -n 'advertencias' a01-material.md | head -3 | cat -v | head -5; echo "---"; python3 -c "
import io,re
s=io.open('a01-material.md',encoding='utf-8').read()
for m in re.finditer(r'\]\(#([^)]*advertencias)\)',s):
    print('ancla:',[hex(ord(c)) for c in m.group(1)[:3]])
for h in re.findall(r'^##.*Advertencias.*$',s,re.M):
    print('titulo:',[hex(ord(c)) for c in h[:8]], repr(h))
"
