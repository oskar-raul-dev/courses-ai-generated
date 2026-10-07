# rescatado de la sesión ba539b99, 2026-09-11T03:39:54Z · Check bidirectional links phases vs forensic pieces
echo "=== fase -> su pieza ==="; for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do f=$(ls ${n}-*.md 2>/dev/null); c=$(grep -c "forense-fase-$n.md" "$f"); echo "$f -> forense-fase-$n: $c"; done
echo "=== master indexa piezas ==="; for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do printf "%s:%s " $n $(grep -c "forense-fase-$n.md" forense-master.md); done; echo
echo "=== pieza -> su fase y master ==="; for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do ph=$(ls ${n}-*.md); echo "forense-fase-$n: fase=$(grep -c "$ph" forense-fase-$n.md) master=$(grep -c "forense-master.md" forense-fase-$n.md)"; done
