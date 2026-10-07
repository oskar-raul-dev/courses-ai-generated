# rescatado de la sesión fd43dd61, 2026-09-10T22:18:19Z · Check block presence in each forensic piece
for f in forense-fase-*.md; do
 t=$(head -1 $f)
 b=""
 for e in "🎫" "🧭" "🩺" "⚰️" "🧨" "🧠"; do grep -q "$e" $f && b="$b$e" || b="$b·"; done
 printf "%-22s %s  %s\n" "$f" "$b" "$t"
done
echo "=== master ==="; grep -n "^## \|^### " forense-master.md
