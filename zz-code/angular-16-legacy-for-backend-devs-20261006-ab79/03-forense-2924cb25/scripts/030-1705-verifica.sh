# rescatado de la sesión 2924cb25, 2026-09-11T17:05:24Z · Check completeness of each prompt block
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== apéndices sin línea de Ejercicios ==="
awk '/^## # Apéndice/{if(cur&&!ej) print cur" ← SIN ejercicios"; cur=$0; ej=0} /Ejercicios:/{ej=1} END{if(cur&&!ej)print cur" ← SIN ejercicios"}' prompts/prompts-backend-apendice.md
echo "=== apéndices sin 'Qué queda explícitamente fuera' ==="
awk '/^## # Apéndice/{if(cur&&!f) print cur; cur=$0; f=0} /explícitamente fuera|queda fuera|NO entra/{f=1} END{if(cur&&!f)print cur}' prompts/prompts-backend-apendice.md
echo "=== fases sin línea de Ejercicios ==="
awk '/^## # Fase/{if(cur&&!ej) print cur" ← SIN ejercicios"; cur=$0; ej=0} /Ejercicios:/{ej=1} END{if(cur&&!ej)print cur" ← SIN ejercicios"}' prompts/prompts-backend-fase.md
echo "— fin —"
