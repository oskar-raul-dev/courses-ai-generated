var __o = {
// La query fugitiva (tu v$session + kill de siempre):
db.currentOp({ active: true, secs_running: { $gt: 10 } })
db.killOp(<opid>)     // con juicio: mata la OPERACIÓN, respeta el proceso
};