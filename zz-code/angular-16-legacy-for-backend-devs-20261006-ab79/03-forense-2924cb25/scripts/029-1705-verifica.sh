# rescatado de la sesión 2924cb25, 2026-09-11T17:05:00Z · Cross-check appendix references between the two prompt files
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== apéndices referenciados desde las fases ==="
grep -o 'bea-[0-9][0-9]' prompts/prompts-backend-fase.md | sort | uniq -c
echo; echo "=== 'Usado por' declarado en cada apéndice ==="
grep -n '^- Usado por:' prompts/prompts-backend-apendice.md
echo; echo "=== títulos de apéndice en cada archivo ==="
grep -o '^## # Apéndice bea-[0-9][0-9] — .*' prompts/prompts-backend-apendice.md
