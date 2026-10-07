# rescatado de la sesión 2924cb25, 2026-09-11T17:04:33Z · Look for placeholders and section coverage
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== marcadores de pendiente ==="; grep -n 'TODO\|FALTA\|por escribir\|pendiente de redactar\|\[Pega aquí\|XXX\|{{' prompts/prompts-backend-fase.md prompts/prompts-backend-apendice.md | head -20
echo; echo "=== secciones por prompt en el archivo de fases ==="
awk '/^## # Fase/{f=$0; c[""]} /^## /{if(f&&$0!~/^## # Fase/) printf "%s | %s\n", substr(f,8,22), $0}' prompts/prompts-backend-fase.md
