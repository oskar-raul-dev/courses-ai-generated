npm i -g json-server@0.16.3 > /tmp/js.log 2>&1
(json-server --port 3000 db.json > /tmp/js.out 2>&1 &)
sleep 3
(npx nuxt > /tmp/dev.log 2>&1 &)
sleep 50
sed "s/\x1b\[[0-9;]*m//g" /tmp/dev.log | grep -i "listening\|in use\|address\|port" | head
