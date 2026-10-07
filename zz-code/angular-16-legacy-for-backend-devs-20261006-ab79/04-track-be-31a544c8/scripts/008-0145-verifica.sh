# rescatado de la sesión 31a544c8, 2026-09-12T01:45:43Z · Verify prompt doc links and list new files
grep -oh '](\([a-z0-9][^):#]*\.md\)' prompts/preparaciones-de-incidentes-be.md | sed 's/](//' | sort -u | while read f; do [ -f "prompts/$f" ] || [ -f "$f" ] || echo "❌ $f"; done
grep -oh '](\.\./[^)#]*\.md' prompts/preparaciones-de-incidentes-be.md prompts/formato-cuaderno-incidentes.md | sed 's/](\.\.\///' | sort -u | while read f; do [ -f "$f" ] || echo "❌ ../$f"; done
echo "(sin salida = ok)"; echo; git -C .. status --short angular-16-legacy-for-backend-devs | tail -25
