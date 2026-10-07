# rescatado de la sesión 51943195, 2026-09-10T02:00:06Z · Check links and stray characters in all pieces
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
for f in 01-vue2-legacy/forense-*.md 02-complement-mongodb-backend/forense-*.md; do d=$(dirname $f); grep -o '](\.\{0,2\}[^)]*\.md[^)]*)' $f | sed 's/](//;s/)$//;s/#.*//' | sort -u | while read p; do [ -e "$d/$p" ] || echo "ROTO: $f -> $p"; done; done | sort | uniq -c | sort -rn | head
echo "=== no ascii raros ==="
LC_ALL=C grep -l '[\xE4-\xE9][\x80-\xBF][\x80-\xBF]' 01-vue2-legacy/forense-*.md 02-complement-mongodb-backend/forense-*.md 2>/dev/null | head
