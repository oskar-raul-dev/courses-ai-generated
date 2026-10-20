#!/usr/bin/env bash
# T2 (a6 §5): qué URL de mongod 4.4.18 arma mongodb-memory-server 6.9.6 por plataforma, y si existe.
B=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/vue2-legacy-for-backend-devs-20261014-b44a/backend/tiquetera-backend
docker run --rm --label curso=vue2-legacy --label tanda=T2 -v "$B/node_modules:/app/node_modules:ro" node:14.21.3 bash -c '
cat > /app/u.js <<JS
const U = require("/app/node_modules/mongodb-memory-server-core/lib/util/MongoBinaryDownloadUrl").default;
(async () => {
  for (const [platform, arch] of [["darwin","x64"],["darwin","arm64"],["linux","arm64"],["linux","x64"]]) {
    try { console.log(platform + "/" + arch, await new U({ platform, arch, version: "4.4.18" }).getDownloadUrl()); }
    catch (e) { console.log(platform + "/" + arch, "ERROR", e.message); }
  }
})();
JS
node /app/u.js | while read pa url; do echo "$pa $url $(curl -s -o /dev/null -w "%{http_code}" -I "$url")"; done'
