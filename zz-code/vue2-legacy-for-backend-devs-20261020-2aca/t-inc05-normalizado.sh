#!/usr/bin/env bash
# Tercer escenario del incidente 05: la refactorización del cuaderno (normalizeTicket en ticketService)
# sobre la rama, sin $set. Corre sin y con la refactorización. Usa el volumen de t-inc05.sh. Uso: ./t-inc05-normalizado.sh
set -uo pipefail
cd "$(dirname "$0")"
R="docker run --rm --label curso=vue2-legacy --label tanda=inc05 -v $PWD/f05-rama:/w -v vue2-inc05-nm:/w/node_modules -w /w node:14.21.3"
correr() { $R bash -c "npx vue-cli-service test:unit tests/unit/inc05-normalizado.spec.js 2>&1 | grep -E '✓|✕|Tests:|Received:' -A1 | head -8"; }
cp f05-rama/src/services/ticketService.js salidas/ticketService-f05.js
echo "== sin la refactorización (servicio de F5)"; correr
python3 -I - <<'PY'
p = "f05-rama/src/services/ticketService.js"; t = open(p, encoding="utf-8").read()
a = """function getTickets(params) {
  // params opcional: { status: "open", _sort: "createdAt", _order: "desc" }
  return apiClient.get("/tickets", { params: params }).then(function (res) {
    return res.data;
  });
}"""
b = """// lo que un ticket tiene que tener siempre; lo demás que traiga (createdAt, reporter…) se conserva
var TICKET_DEFAULTS = {
  title: "",
  description: "",
  status: "open",
  priority: "medium",
  assignee: null
};

function normalizeTicket(raw) {
  // tags va aparte: un arreglo nuevo por ticket, nunca uno compartido entre todos
  return Object.assign({}, TICKET_DEFAULTS, raw, { tags: raw.tags || [] });
}

function getTickets(params) {
  return apiClient.get("/tickets", { params: params }).then(function (res) {
    return res.data.map(normalizeTicket);
  });
}"""
assert t.count(a) == 1, "getTickets de F5 no encontrado"; open(p, "w", encoding="utf-8").write(t.replace(a, b))
PY
echo "== con la refactorización del cuaderno"; correr
cp salidas/ticketService-f05.js f05-rama/src/services/ticketService.js
