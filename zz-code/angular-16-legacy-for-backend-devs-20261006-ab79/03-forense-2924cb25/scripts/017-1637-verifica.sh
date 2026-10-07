# rescatado de la sesión 2924cb25, 2026-09-11T16:37:23Z · Check phase headers and incident reservation blocks
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== cabeceras de fases ==="; for f in 0*.md 1*.md; do head -6 "$f" | grep -n 'Apéndices de apoyo\|Incidentes asociados' | sed "s|^|$f: |"; done
echo; echo "=== bloques de reservas ==="; grep -rn 'Reservas para el cuaderno' *.md | head -20
