#!/bin/bash
# Arranque en frío hasta la PRIMERA PETICIÓN SERVIDA (no el "Started" del log), y RSS
# en reposo. Uso dentro del contenedor de la app: cold-start.sh PUERTO comando…
port=$1; shift
start=$(date +%s%N)
"$@" > /tmp/app.log 2>&1 &
pid=$!
until (exec 3<>/dev/tcp/127.0.0.1/$port && printf 'GET /health HTTP/1.0\r\n\r\n' >&3 && head -1 <&3 | grep -q " 200") 2>/dev/null; do
  sleep 0.005
done
end=$(date +%s%N)
echo "arranque_ms=$(( (end - start) / 1000000 ))"
sleep 3
echo "rss_reposo_mb=$(( $(awk '/VmRSS/{print $2}' /proc/$pid/status) / 1024 ))"
kill $pid; wait $pid 2>/dev/null
