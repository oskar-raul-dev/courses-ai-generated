# rescatado de la sesión fd43dd61, 2026-09-10T22:23:39Z · Verify links and show diff summary
echo "=== enlaces rotos ==="; grep -oh "(\./[^)]*\.md)" *.md prompts/*.md | tr -d '()' | sed 's|^\./||' | sort -u | while read f; do [ -f "$f" ] || [ -f "prompts/$f" ] || echo "ROTO: $f"; done
echo "=== enlaces relativos de prompts/ ==="; grep -oh "(\.\./[^)]*\.md)" prompts/*.md | tr -d '()' | sed 's|^\.\./||' | sort -u | while read f; do [ -f "$f" ] || echo "ROTO: $f"; done
echo "=== fases: forma del enlace ==="; grep -c "](\./forense-fase" 10-dashboard.md
echo "=== diff ==="; cd .. && git diff --stat
