# Comandos Bash de la sesión 14cfaf06-578d-44da-99e0-ba6788d8c1c8, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-12T02:12:25 · List prompts and read README
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && ls -la prompts/ && wc -l *.md prompts/*.md | tail -5 && echo "=== README ===" && cat README.md

# --- 2026-09-12T02:12:30 · Read project instructions and style guide outline
echo "=== instrucciones-del-proyecto ===" && cat prompts/instrucciones-del-proyecto.md && echo "=== INDICE guia-de-estilo ===" && grep -n '^#\{1,3\} ' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-12T02:12:37 · Check git status and pending section
cd /Users/oskar/Developer/Learning/courses-ia-generated && git status --short -- react-16-legacy-for-backend-devs | head -40; echo "=== pendientes guia §15 ==="; sed -n '802,868p' react-16-legacy-for-backend-devs/prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-12T02:13:37 · Compare angular-8 naming and check react BE file sizes
echo "=== angular-8 ===" && ls angular-8-legacy-for-backend-devs/ && echo "=== react16 be sizes ===" && wc -l react-16-legacy-for-backend-devs/be*.md react-16-legacy-for-backend-devs/cuaderno-incidentes-be.md

# --- 2026-09-12T02:13:49 · Verify naming convention and completeness
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== ¿existe algún beaNN- (sin guion) en el repo? ==="
ls */ | grep -E '^bea[0-9]' || echo "NINGUNO"
echo "=== ¿quedan be-a-NN- ? ==="
grep -rl 'be-a-[0-9]' --include='*.md' . || echo "NINGUNO"
echo "=== referencias a 'bea' en prompts de react16 (muestra) ==="
grep -rho 'bea[-0-9][0-9-]*' react-16-legacy-for-backend-devs/prompts/ | sort | uniq -c | sort -rn | head
echo "=== angular-8 prompts: cómo nombra sus apéndices ==="
grep -rho 'bea[-0-9][0-9-]*' angular-8-legacy-for-backend-devs/prompts/ | sort | uniq -c | sort -rn | head -5
echo "=== cabeza de bea-06 (react16) ==="
head -20 react-16-legacy-for-backend-devs/bea-06-tiempo-zonas-y-relojes.md
echo "=== cola de be07 ==="
tail -12 react-16-legacy-for-backend-devs/be07-liquidacion-dinero-entero-y-transaccional.md

# --- 2026-09-12T02:13:55 · Locate leftover naming in angular-8 proposal
grep -n 'be-a-[0-9]' angular-8-legacy-for-backend-devs/prompts/propuesta-fases-backend.md

# --- 2026-09-12T02:14:00 · Check BE notebook completeness
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
grep -n '^## ' cuaderno-incidentes-be.md | head -30
echo "--- ejercicios por fase be (conteo aprox) ---"
for f in be0*.md; do printf "%s: %s ejercicios\n" "$f" "$(grep -cE '^### (Ejercicio )?[0-9]+' $f)"; done

# --- 2026-09-12T02:14:06 · Inspect exercise formatting in a BE phase
sed -n '/🧪 Ejercicios/,/📚/p' be05-venta-concurrente.md | grep -nE '^\*\*[0-9]|^[0-9]+\.|^#{3,4} ' | head -40

# --- 2026-09-12T02:14:10 · Count exercises in be05
grep -n 'Ejercicio' be05-venta-concurrente.md | head -40; echo "---total 🟢🟡🟠🔴 markers---"; grep -c '🟢\|🟡\|🟠\|🔴' be05-venta-concurrente.md

# --- 2026-09-12T02:14:13 · Inspect exercises section and declared counts
sed -n '711,760p' be05-venta-concurrente.md; echo "=== conteo declarado por fase ==="; grep -h 'Ejercicios (' be0*.md bea-*.md

# --- 2026-09-12T02:16:09 · Compare BE naming across all courses
cd /Users/oskar/Developer/Learning/courses-ia-generated
for d in angular-8-legacy-for-backend-devs angular-16-legacy-for-backend-devs react-16-legacy-for-backend-devs docker-container-legacy* ; do echo "=== $d ==="; ls $d 2>/dev/null | grep -E '^be' | head -30; done

