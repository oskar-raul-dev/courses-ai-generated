#!/usr/bin/env bash
# F26 §5.3 sin los prune destructivos; luego §8 (dos fixtures) y ej. 9. Secuencial: un motor a la vez.
export CONTAINER_CONNECTION=p4-legacy
cd "$(dirname "$0")/../../lab"
t(){ /usr/bin/time -p "$@" 2>&1 >/dev/null | awk '/^real/ {print $2 " s"}'; }
echo "== COLD (--no-cache)"
for e in docker podman; do printf '%-7s ' $e; t $e build --no-cache --platform linux/amd64 -t p4-bench:$e . ; done
echo "== WARM"
for e in docker podman; do printf '%-7s ' $e; t $e build --platform linux/amd64 -t p4-bench:$e . ; done
echo "== ARRANQUE x5 (node -e '')"
for e in docker podman; do printf '%-7s ' $e; for i in 1 2 3 4 5; do printf '%s ' "$(t $e run --rm p4-bench:$e node -e '')"; done; echo; done
cd ../experimentos/f26
echo "== §8 bucle arreglado, dos fixtures"
for fx in 10-vue2-min 30-react16-min; do
  for eng in docker podman; do
    vol="p4-crossengine-${fx}-${eng}"; $eng volume rm $vol >/dev/null 2>&1; $eng volume create $vol >/dev/null
    printf '%-15s %-7s ' $fx $eng
    s=$(date +%s)
    $eng run --rm --platform linux/amd64 -e NODE_VERSION=10.24.1 \
      --mount "type=bind,src=$PWD/src/11-validar-tu-proyecto/$fx,dst=/workspace" \
      --mount "type=volume,src=$vol,dst=/workspace/node_modules" \
      legacy-node-toolchain:phase15 \
      bash -c 'npm ci >/dev/null 2>&1 && printf "ci=✅ " || printf "ci=❌ "; npm run build >/dev/null 2>&1 && printf "build=✅ " || printf "build=❌ "' 2>/dev/null | grep -o 'ci=.*'
    echo "  $(( $(date +%s) - s )) s"
  done
done
echo "== ej. 9: npm ci de vue2 con node_modules en volumen vs en bind mount"
for eng in docker podman; do
  vol="p4-ej9-${eng}"; $eng volume rm $vol >/dev/null 2>&1; $eng volume create $vol >/dev/null
  printf '%-7s volumen ' $eng
  t $eng run --rm --platform linux/amd64 --mount "type=bind,src=$PWD/src/11-validar-tu-proyecto/10-vue2-min,dst=/workspace" --mount "type=volume,src=$vol,dst=/workspace/node_modules" legacy-node-toolchain:phase15 npm ci
  rm -rf src/11-validar-tu-proyecto/10-vue2-min/node_modules
  printf '%-7s bind    ' $eng
  t $eng run --rm --platform linux/amd64 --mount "type=bind,src=$PWD/src/11-validar-tu-proyecto/10-vue2-min,dst=/workspace" legacy-node-toolchain:phase15 npm ci
  rm -rf src/11-validar-tu-proyecto/10-vue2-min/node_modules
done
echo "== fin"
