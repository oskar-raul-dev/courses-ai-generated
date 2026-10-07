# rescatado de la sesión 13793b0f, 2026-09-11T02:33:52Z · Read route intros of pieces without explicit cost ordering
import re,io
for f in ['forense-fase-02.md','forense-fase-03.md','forense-fase-05.md','forense-fase-07.md','forense-fase-08.md','forense-fase-09.md','forense-fase-14.md']:
    s=io.open(f,encoding='utf-8').read()
    m=re.search(r'^## 🧭 (.+?)\n(.*?)(?=^###)', s, re.M|re.S)
    if m:
        txt=' '.join(m.group(2).split())[:260]
        print(f"--- {f}  [{m.group(1)[:40]}]\n    {txt}\n")
