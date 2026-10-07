# rescatado de la sesión ba539b99, 2026-09-11T14:51:18Z · Verify chaos flags and phase tag names
echo "=== flags de caos usados ==="; grep -o "CHAOS=[a-z0-9=@]*" cuaderno-incidentes.md | sort -u
echo; echo "=== tags de fase usados en preparación ==="; grep -oE "git checkout -b incidente/[0-9]{2} [a-z0-9-]+" cuaderno-incidentes.md
echo; echo "=== tags que existen de verdad ==="; for f in [01][0-9]-*.md; do [ "${f:0:2}" = "00" ] && [ "${f}" != "00-setup-hola-mundo.md" ] && continue; echo "fase-${f%.md}"; done
