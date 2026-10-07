# rescatado de la sesión 31a544c8, 2026-09-12T02:12:52Z · Check template compliance, naming leftovers, and Spanish variant
echo "=== plantilla de 9 secciones (fases base + BE) ==="
for f in [0-9][0-9]-*.md be0*.md; do
  case "$f" in 00-conv*|00-hist*) continue;; esac
  miss=""
  for s in "1\. Propósito" "2\. Qué queda listo" "3\. Qué NO entra" "4\. Concepto mínimo" "5\." "6\. Errores comunes" "7\. Ejercicios" "8\. Referencias" "9\. Cierre" "📌 Pendientes"; do
    grep -qE "^## .*$s" "$f" || miss="$miss [$s]"
  done
  grep -q "🏷️" "$f" || miss="$miss [tag]"
  grep -q "La señal de que quedó bien" "$f" || miss="$miss [señal]"
  [ -n "$miss" ] && echo "⚠️ $f$miss"
done
echo "(sin salida = todas completas)"
echo
echo "=== restos del nombre viejo be-a-NN- ==="
grep -rn "be-a-[0-9]" --include="*.md" . | head -5 || true
echo "(sin salida = ok)"
echo
echo "=== términos de España / voseo ==="
grep -rniE "\bordenador|\bvale\b|vosotros|\bcoged|\btenés\b|\bpodés\b|\bsos\b" --include="*.md" . | grep -v "equivale\|válido\|valen\|valor" | head -10
echo "(sin salida = ok)"
