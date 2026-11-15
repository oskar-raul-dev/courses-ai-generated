source scripts/engine.sh

for eng in docker podman; do
  "$eng" info >/dev/null 2>&1 || continue   # responde, no solo existe
  vol="crossengine-vue2-node10-amd64-${eng}"      # ⚠️ un volumen POR MOTOR
  "$eng" volume rm "$vol" >/dev/null 2>&1 || true
  "$eng" volume create "$vol" >/dev/null

  printf '%-8s ' "$eng"
  "$eng" run --rm --platform linux/amd64 \
    -e NODE_VERSION=10.24.1 \
    --mount "type=bind,src=$PWD/src/11-validar-tu-proyecto/10-vue2-min,dst=/workspace" \
    --mount "type=volume,src=${vol},dst=/workspace/node_modules" \
    legacy-node-toolchain:phase15 \
    bash -c 'npm ci >/dev/null 2>&1 && printf "ci=✅ " || printf "ci=❌ "
             npm run build >/dev/null 2>&1 && printf "build=✅\n" || printf "build=❌\n"'
done
