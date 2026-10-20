npm i -g json-server@0.16.3 > /tmp/js.log 2>&1
(json-server --port 3000 db.json > /tmp/js.out 2>&1 &)
npm run build > /tmp/build.log 2>&1; echo "build exit $?"; sed "s/\x1b\[[0-9;]*m//g" /tmp/build.log | grep -i "error\|warn\|Compiled\|Ready" | head -5
(npm run start > /tmp/start.log 2>&1 &)
sleep 15; sed "s/\x1b\[[0-9;]*m//g" /tmp/start.log | grep -i "listening" 
curl -s -m 30 -o /tmp/a.html -w "HTTP %{http_code}\n" http://127.0.0.1:8080/tickets/1/activity; grep -o "<title>[^<]*</title>" /tmp/a.html
curl -s -m 30 -o /tmp/t.html -w "tickets HTTP %{http_code}\n" http://127.0.0.1:8080/tickets; grep -c "La impresora no imprime" /tmp/t.html
