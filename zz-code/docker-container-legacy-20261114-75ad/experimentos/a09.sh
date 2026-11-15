docker run --rm --platform linux/amd64 -e NODE_VERSION=10.24.1   --mount type=bind,src=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/docker-container-legacy-20261114-75ad/experimentos/a09-labcore,dst=/workspace   --mount type=volume,src=labcore-node10-modules,dst=/workspace/node_modules   legacy-node-toolchain:phase15 bash -c '
set -o pipefail
s=$(date +%s); apt-get update -qq >/dev/null 2>&1; apt-get install -y -qq --no-install-recommends chromium >/tmp/apt.log 2>&1; echo "apt chromium exit=$? en $(($(date +%s)-s)) s"
dpkg -s chromium | grep -E "^Version"; chromium --version 2>&1 | head -1
ldd /usr/lib/chromium/chromium | grep -c "not found"
df -h /dev/shm | tail -1
export CHROME_BIN=/usr/bin/chromium
s=$(date +%s); timeout 600 npx ng test --watch=false --browsers=ChromeHeadlessNoSandbox --progress=false 2>&1 | tail -15; echo "ng test exit=$? en $(($(date +%s)-s)) s"
'
