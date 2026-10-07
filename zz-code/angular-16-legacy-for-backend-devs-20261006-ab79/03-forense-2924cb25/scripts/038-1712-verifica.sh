# rescatado de la sesión 2924cb25, 2026-09-11T17:12:32Z · Check declared BE filenames and naming rationale
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== nombres de archivo declarados en los prompts BE ==="
grep -oE '`be[a0-9][^`]*\.md`' prompts/prompts-backend-fase.md prompts/prompts-backend-apendice.md | sort -u
echo; echo "=== lo que dice la propuesta sobre la convención ==="
sed -n '765,790p' prompts/propuesta-fases-backend.md
