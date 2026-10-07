# rescatado de la sesión 2924cb25, 2026-09-11T17:04:47Z · Compare section structure with the completed angular-8 track
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== angular-8 apendice: secciones por apéndice ==="
awk '/^## # Apéndice/{f=substr($0,14,12)} /^## /{if(f&&$0!~/^## # Apéndice/) printf "%s | %s\n", f, $0}' angular-8-legacy-for-backend-devs/prompts/prompts-backend-apendice.md | head -40
echo; echo "=== angular-8 fase: secciones ==="
awk '/^## # Fase/{f=substr($0,8,10)} /^## /{if(f&&$0!~/^## # Fase/) printf "%s | %s\n", f, $0}' angular-8-legacy-for-backend-devs/prompts/prompts-backend-fase.md | head -14
