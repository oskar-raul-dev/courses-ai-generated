# rescatado de la sesión 2924cb25, 2026-09-11T16:38:35Z · Check for malformed emoji anchors
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== anclas ⚠️ mal formadas ==="; grep -rn '](#-advertencias)' *.md prompts/*.md | head -20
echo; echo "=== otras anclas con emoji sospechosas ==="; grep -rhno '](#[^)]*)' *.md | grep -o '#[^)]*' | sort -u | head -40
