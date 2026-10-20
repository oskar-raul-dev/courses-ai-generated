#!/bin/sh
# Apagado ordenado: una petición en vuelo (latencia del caos) y SIGTERM a mitad de camino.
kill $(pidof api) 2>/dev/null; sleep 0.5
(CHAOS_LEVEL=high CHAOS_SEED=3 PORT=3011 /tmp/api > /tmp/ap.log 2>&1 &); sleep 0.5
curl -s -o /dev/null -w "en vuelo: %{http_code} en %{time_total}s\n" localhost:3011/health & 
sleep 0.2; kill -TERM $(pidof api); sleep 0.1
curl -s -o /dev/null -w "nueva tras SIGTERM: %{http_code}\n" localhost:3011/health || echo "nueva tras SIGTERM: rechazada (curl $?)"
wait; sleep 0.5; cat /tmp/ap.log
echo "== puerto ocupado"
(PORT=3011 /tmp/api > /tmp/p1.log 2>&1 &); sleep 0.5; PORT=3011 /tmp/api 2>&1 | tail -1; echo "exit=$?"; kill $(pidof api) 2>/dev/null
