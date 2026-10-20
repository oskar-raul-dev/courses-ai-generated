true
npm i -g json-server@0.16.3 socket.io@2.4.1 > /tmp/js.log 2>&1
export NODE_PATH=/usr/local/lib/node_modules
(json-server --port 3000 db.json > /tmp/js.out 2>&1 &)
(node server/socket-server.js > /tmp/sock.out 2>&1 &)
(npx nuxt > /tmp/dev.log 2>&1 &)
sleep 60
echo "== head"; curl -s -m 30 -o /tmp/a.html -w "HTTP %{http_code}\n" http://127.0.0.1:8080/tickets/1/activity; grep -o "<title>[^<]*</title>\|<meta data-n-head=\"ssr\" data-hid=\"description\"[^>]*>" /tmp/a.html; grep -c 'name="description"' /tmp/a.html; grep -o "cambió el estado de [a-z_]* a [a-z_]*\|comentó: [^<]*" /tmp/a.html
echo "== 999"; curl -s -m 30 -o /tmp/b.html -w "HTTP %{http_code}\n" http://127.0.0.1:8080/tickets/999/activity; grep -o "Ticket no encontrado\|This page could not be found" /tmp/b.html | head -1
echo "== abc"; curl -s -m 30 -o /tmp/c.html -w "HTTP %{http_code}\n" http://127.0.0.1:8080/tickets/abc/activity; grep -o "Ticket no encontrado\|This page could not be found" /tmp/c.html | head -1
grep -c "GET /tickets/abc\|GET /activity?ticketId=abc" /tmp/js.out
echo "== rele"; cat > /tmp/rele.js <<'J'
var io = require("/app/node_modules/socket.io-client");
var a = io("http://localhost:4000"), b = io("http://localhost:4000");
b.on("activity:created", function (ev) { console.log("B recibe:", JSON.stringify(ev)); process.exit(0); });
a.on("connect", function () { setTimeout(function () { a.emit("activity:created", { id: 3, ticketId: 1, type: "status_change", actor: "lmcorrea", from: "in_progress", to: "resolved", at: "2020-03-11T09:00:00Z" }); }, 500); });
setTimeout(function () { console.log("B no recibió nada"); process.exit(1); }, 5000);
J
node /tmp/rele.js
echo "== log"; sed "s/\x1b\[[0-9;]*m//g" /tmp/dev.log | grep -i "error\|warn" | sort | uniq -c | head
