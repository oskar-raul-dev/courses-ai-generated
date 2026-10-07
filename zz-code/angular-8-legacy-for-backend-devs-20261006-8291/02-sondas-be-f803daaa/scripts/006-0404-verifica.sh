# rescatado de la sesión f803daaa, 2026-09-09T04:04:47Z · Verify transaction rejection on standalone mongo 4.0
docker rm -f m40 >/dev/null 2>&1
docker run -d --name m40 --platform linux/arm64 mongo:4.0 >/dev/null 2>&1 && sleep 8
docker exec m40 mongo --quiet --eval '
var s = db.getMongo().startSession();
var c = s.getDatabase("lab").custody;
s.startTransaction();
try { c.insertOne({step:"recepcion"}); s.commitTransaction(); print("  RESULTADO: transaccion COMPLETADA"); }
catch(e){ print("  RESULTADO: RECHAZADA"); print("  codigo:  " + e.code + " (" + e.codeName + ")"); print("  mensaje: " + e.errmsg); }
' 2>&1 | sed 's/^/  /'
docker rm -f m40 >/dev/null 2>&1; echo "  (limpieza hecha)"
