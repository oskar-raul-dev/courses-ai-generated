#!/usr/bin/env bash
# Rediseño del incidente 05: en node:14.21.3 (arm64), sobre f05-rama (F7 + rama incidente/05):
# npm ci, plugin de Jest de F11, la prueba interna de la vista con la rama (bug), con el parche $set y
# con la refactorización del cuaderno (normalizeTicket), y build + lint de la rama.
# Uso: ./t-inc05.sh   (los node_modules quedan en el volumen vue2-inc05-nm; package.json del árbol de prueba gana el plugin)
set -uo pipefail
cd "$(dirname "$0")"
L="--label curso=vue2-legacy --label tanda=inc05"; VOL=vue2-inc05-nm
docker volume create $L $VOL >/dev/null
R="docker run --rm $L -v $PWD/f05-rama:/w -v $VOL:/w/node_modules -w /w node:14.21.3"
cp f05-rama/package.json salidas/package-f07.json
$R bash -c 'npm ci --silent >/dev/null 2>&1; echo EXIT_CI=$?; npm install --silent --save-dev @vue/cli-plugin-unit-jest@3.12.1 @vue/test-utils@1.3.6 babel-core@7.0.0-bridge.0 babel-jest@23.6.0 >/dev/null 2>&1; echo EXIT_PLUGIN=$?'
correr() { $R bash -c "npx vue-cli-service test:unit tests/unit/inc05-vista.spec.js 2>&1 | grep -E '✓|✕|Tests:|Expected|Received' | head -12"; }
echo "== 1. con la rama (bug)"; correr
cp f05-rama/src/views/TicketsView.vue salidas/TicketsView-rama.vue
python3 -I - <<'PY'
p = "f05-rama/src/views/TicketsView.vue"; t = open(p).read()
a = """      var tags = (ticket.tags || []).concat("facturación");
      ticketService.updateTicket(ticket.id, { tags: tags }).then(function (saved) {
        ticket.tags = saved.tags;
      });"""
b = """      var self = this;
      var tags = (ticket.tags || []).concat("facturación");
      ticketService.updateTicket(ticket.id, { tags: tags }).then(function (saved) {
        // $set y no ticket.tags = …: una propiedad que no existía cuando el ticket
        // entró a data no es reactiva en Vue 2
        self.$set(ticket, "tags", saved.tags);
      });"""
assert t.count(a) == 1; open(p, "w").write(t.replace(a, b))
PY
echo "== 2. con el parche mínimo (\$set)"; correr
cp salidas/TicketsView-rama.vue f05-rama/src/views/TicketsView.vue
echo "== 3. build y lint de la rama"
$R bash -c 'npx vue-cli-service lint --no-fix src 2>&1 | tail -3; npx vue-cli-service build 2>&1 | grep -E "Build complete|ERROR|error" | head -3'
