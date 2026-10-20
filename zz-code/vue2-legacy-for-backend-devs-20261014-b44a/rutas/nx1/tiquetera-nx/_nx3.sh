npm i -g json-server@0.16.3 > /tmp/js.log 2>&1
(json-server --port 3000 db.json > /tmp/js.out 2>&1 &)
(npx nuxt > /tmp/dev.log 2>&1 &)
sleep 55
echo "== store manda"; curl -s -o /tmp/p.html -w "HTTP %{http_code}\n" http://127.0.0.1:8080/tickets; grep -c "La impresora no imprime" /tmp/p.html; grep -o "Cargando tickets" /tmp/p.html | head -1
echo "== sesion por cookie"; curl -s -H 'Cookie: token=mock-jwt-token-123; user=%7B%22username%22%3A%22admin%22%7D' -o /tmp/c.html http://127.0.0.1:8080/tickets; grep -o 'token:"[^"]*"' /tmp/c.html | head -2; grep -o 'user:{[^}]*}' /tmp/c.html | head -1
echo "== asyncData"; curl -s -o /tmp/a.html -w "HTTP %{http_code}\n" http://127.0.0.1:8080/alt; grep -c "La impresora no imprime" /tmp/a.html
echo "== this en asyncData"; curl -s -o /tmp/t.html -w "HTTP %{http_code}\n" http://127.0.0.1:8080/err-this; sed "s/\x1b\[[0-9;]*m//g" /tmp/dev.log | grep -i "undefined" | sort -u | head -3
echo "== fetch sin return"; curl -s -o /tmp/s.html -w "HTTP %{http_code}\n" http://127.0.0.1:8080/sin-return; grep -c "La impresora no imprime" /tmp/s.html
echo "== API caida"; pkill -f json-server; sleep 2
curl -s -o /tmp/a2.html -w "alt HTTP %{http_code}\n" http://127.0.0.1:8080/alt; grep -o "No se pudieron cargar los tickets." /tmp/a2.html | head -1
curl -s -o /tmp/p2.html -w "tickets HTTP %{http_code}\n" http://127.0.0.1:8080/tickets; grep -o "No se pudieron cargar[^<]*" /tmp/p2.html | head -2
echo "== log"; sed "s/\x1b\[[0-9;]*m//g" /tmp/dev.log | grep -i "error\|warn" | sort | uniq -c | head -10
