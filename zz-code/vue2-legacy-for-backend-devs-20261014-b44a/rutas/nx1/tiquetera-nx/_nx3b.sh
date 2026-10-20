npm i -g json-server@0.16.3 > /tmp/js.log 2>&1
(json-server --port 3000 db.json > /tmp/js.out 2>&1 &)
(npx nuxt > /tmp/dev.log 2>&1 &)
sleep 55
echo "== store manda"; curl -s -m 30 -o /tmp/p.html -w "HTTP %{http_code}\n" http://127.0.0.1:8080/tickets; grep -c "La impresora no imprime" /tmp/p.html
echo "== this en asyncData"; curl -s -m 30 -o /tmp/t.html -w "HTTP %{http_code}\n" http://127.0.0.1:8080/err-this; grep -o "Cannot read[^<&]*" /tmp/t.html | head -2
sed "s/\x1b\[[0-9;]*m//g" /tmp/dev.log | grep -B1 -A2 "Cannot read" | head -8
echo "== nuxtServerInit en modulo"; grep -c "PRUEBA nuxtServerInit" /tmp/dev.log
echo "== API caida"; pkill -f json-server; sleep 2
curl -s -m 30 -o /tmp/p2.html -w "tickets HTTP %{http_code}\n" http://127.0.0.1:8080/tickets; grep -o 'alert alert-danger[^<]*<\?[^<]*' /tmp/p2.html | head -2
