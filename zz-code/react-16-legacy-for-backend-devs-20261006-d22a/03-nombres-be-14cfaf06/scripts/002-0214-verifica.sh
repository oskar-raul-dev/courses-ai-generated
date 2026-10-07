# rescatado de la sesión 14cfaf06, 2026-09-12T02:14:00Z · Check BE notebook completeness
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
grep -n '^## ' cuaderno-incidentes-be.md | head -30
echo "--- ejercicios por fase be (conteo aprox) ---"
for f in be0*.md; do printf "%s: %s ejercicios\n" "$f" "$(grep -cE '^### (Ejercicio )?[0-9]+' $f)"; done
