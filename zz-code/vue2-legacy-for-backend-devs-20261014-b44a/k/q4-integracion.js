// K4: Q4 contra json-server y el relé de sockets, como lo publica la fase
var http = require("http");
var io = require("socket.io-client");
function req(method, path, body) {
  return new Promise(function (ok, ko) {
    var r = http.request({ host: "localhost", port: 3000, path: path, method: method, headers: { "Content-Type": "application/json" } }, function (res) {
      var d = ""; res.on("data", function (c) { d += c; }); res.on("end", function () { ok({ status: res.statusCode, body: d }); });
    });
    r.on("error", ko); if (body) r.write(JSON.stringify(body)); r.end();
  });
}
req("GET", "/activity?ticketId=1&_sort=at&_order=desc").then(function (r) {
  console.log("GET /activity?ticketId=1 →", r.status, JSON.parse(r.body).map(function (a) { return a.id + ":" + a.type; }).join(" "));
  return req("POST", "/activity", { ticketId: 1, type: "status_change", actor: "lmcano", from: "in_progress", to: "resolved", at: "2020-03-11T09:00:00Z" });
}).then(function (r) {
  var saved = JSON.parse(r.body); console.log("POST /activity →", r.status, "id", saved.id);
  var a = io("http://localhost:4000"), b = io("http://localhost:4000"), n = 0, got = null;
  b.on("activity:created", function (x) { got = x; });
  function go() { if (++n === 2) a.emit("activity:created", saved); }
  a.on("connect", go); b.on("connect", go);
  setTimeout(function () { console.log("B recibió activity:created:", got && got.id, "| A (emisor) no se lo autoenvía"); a.close(); b.close(); process.exit(0); }, 1500);
});
