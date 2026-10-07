# rescatado de la sesión ba539b99, 2026-09-11T03:39:29Z · Structural check of forensic pieces
for f in forense-fase-*.md; do
 l=$(wc -l < "$f"); pasos=$(grep -cE "^### Paso " "$f"); tk=$(grep -c "🎫" "$f"); diag=$(grep -c "🩺" "$f"); cal=$(grep -c "⚰️" "$f"); des=$(grep -c "🧨" "$f"); pat=$(grep -c "🧠" "$f"); desc=$(grep -c "Qué descarta" "$f");
 printf "%-20s lin:%4s pasos:%s descarta:%s 🎫%s 🩺%s ⚰️%s 🧨%s 🧠%s\n" "$f" "$l" "$pasos" "$desc" "$tk" "$diag" "$cal" "$des" "$pat"; done
