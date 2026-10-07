# rescatado de la sesión f803daaa, 2026-09-09T04:09:45Z · Find mock API ports in both Angular courses
cd /Users/oskar/Developer/Learning/courses-ia-generated
for f in angular-8-legacy-for-backend-devs/04-mock-api-caos.md angular-16-legacy-for-backend-devs/03-mock-api-caos.md; do
  echo "=== $f ==="
  grep -oE "localhost:[0-9]{4}|puerto \`?[0-9]{4}|PORT[ =:]+[0-9]{4}|:[0-9]{4}/" "$f" | sort | uniq -c | sort -rn | head -6
done
