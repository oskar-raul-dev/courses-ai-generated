# rescatado de la sesión 13793b0f, 2026-09-11T02:44:31Z · Check route intros of remaining five pieces
for f in forense-fase-06.md forense-fase-10.md forense-fase-11.md forense-fase-12.md forense-fase-13.md; do echo "===== $f"; python3 -c "
import io,sys
s=io.open('$f',encoding='utf-8').read()
i=s.find('## 🧭'); j=s.find('###', i)
print(' '.join(s[i:j].split())[:300])
"; done
