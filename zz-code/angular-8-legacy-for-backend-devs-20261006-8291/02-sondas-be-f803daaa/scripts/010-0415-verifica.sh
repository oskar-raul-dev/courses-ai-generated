# rescatado de la sesión f803daaa, 2026-09-09T04:15:10Z · Check mongo vs mongosh shell availability by version
for t in 4.0 6.0 7.0; do
  printf "mongo:%-4s  " "$t"
  docker run --rm --entrypoint sh --platform linux/arm64 mongo:$t -c '
    m=$(command -v mongo >/dev/null 2>&1 && echo si || echo NO)
    s=$(command -v mongosh >/dev/null 2>&1 && echo si || echo NO)
    echo "shell \"mongo\": $m   |   \"mongosh\": $s"' 2>&1 | tail -1
done
