#!/bin/sh
# Mide el caos de be01: reproducibilidad con semilla, el 401 que no toca /users y la precedencia.
run() { for i in $(seq 1 $2); do curl -s -o /dev/null --max-time 2 -w "%{http_code}\n" localhost:3011$1; done | sort | uniq -c | tr "\n" " "; echo; }
start() { (env "$@" PORT=3011 /tmp/api > /tmp/a.log 2>&1 &); sleep 0.5; }
stop() { kill $(pidof api) 2>/dev/null; sleep 0.5; }
stop
echo "== high, semilla 7, dos arranques, 40 peticiones a /health (000 = el cliente cortó a los 2 s)"
start CHAOS_LEVEL=high CHAOS_SEED=7
for i in $(seq 1 40); do curl -s -o /dev/null --max-time 2 -w "%{http_code} " localhost:3011/health; done > /tmp/seq1; stop
start CHAOS_LEVEL=high CHAOS_SEED=7
for i in $(seq 1 40); do curl -s -o /dev/null --max-time 2 -w "%{http_code} " localhost:3011/health; done > /tmp/seq2; stop
echo "secuencia 1: $(cat /tmp/seq1)"; echo "secuencia 2: $(cat /tmp/seq2)"; cmp -s /tmp/seq1 /tmp/seq2 && echo "IDÉNTICAS" || echo "DISTINTAS"
echo "== high sin semilla, dos arranques"
start CHAOS_LEVEL=high
for i in $(seq 1 40); do curl -s -o /dev/null --max-time 2 -w "%{http_code} " localhost:3011/health; done > /tmp/seq3; stop
start CHAOS_LEVEL=high
for i in $(seq 1 40); do curl -s -o /dev/null --max-time 2 -w "%{http_code} " localhost:3011/health; done > /tmp/seq4
cmp -s /tmp/seq3 /tmp/seq4 && echo "IDÉNTICAS" || echo "DISTINTAS"
echo "== /users en high, 200 peticiones (el 401 no lo toca)"; run "/users" 200
echo "== /health en high, 200 peticiones"; run "/health" 200
stop
echo "== precedencia: arranque high -> POST off -> reinicio"
start CHAOS_LEVEL=high
curl -s -X POST localhost:3011/_chaos -d '{"level":"off"}'; run "/health" 30
stop; start CHAOS_LEVEL=high; grep "nivel inicial" /tmp/a.log; stop
