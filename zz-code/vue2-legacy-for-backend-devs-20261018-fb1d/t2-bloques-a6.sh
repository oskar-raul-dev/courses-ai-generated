#!/usr/bin/env bash
# T2: los bloques de a6 que corren en Linux, copiados tal cual, en arm64 y amd64.
for plat in linux/arm64 linux/amd64; do
echo "===== $plat"
docker run --rm --label curso=vue2-legacy --label tanda=T2 --platform $plat -v "$PWD/f11/tiquetera-legacy:/src:ro" node:14.21.3 bash -c '
cp -r /src /w && cd /w
echo "## 📍"; uname -m; node -p process.arch; file "$(which node)"
echo "## 💡"; uname -m ; node -v ; node -p process.arch ; npm -v
echo "## 🧹 ritual (sin nvm use: no hay nvm en la imagen)"
node -p process.arch
rm -rf node_modules
npm ci --silent >/dev/null 2>&1; echo "npm ci EXIT=$?"
echo "## 🧬 find"; find node_modules -name binding.gyp -not -path "*/node-gyp/*" | sort
echo "## deasync bin"; ls node_modules/deasync/bin | grep -c .; ls node_modules/deasync/bin | grep "darwin-arm64\|node-14$"'
done
