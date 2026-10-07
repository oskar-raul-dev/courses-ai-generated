# rescatado de la sesión f803daaa, 2026-09-09T04:04:09Z · Runtime check of mongo 4.0 and temurin 8 on arm64
echo "### mongo:4.0 arm64 nativo"
docker rm -f m40 >/dev/null 2>&1
docker run -d --name m40 --platform linux/arm64 mongo:4.0 >/dev/null 2>&1 && sleep 8
docker exec m40 mongo --quiet --eval '
  print("  version:    " + db.version());
  print("  arquitect.: " + db.serverBuildInfo().buildEnvironment.target_arch);
  print("  topologia:  " + (rs.status().ok ? "replica set" : "standalone"));
  var e=""; try { var s=db.getMongo().startSession(); s.startTransaction(); e="permitida"; } catch(x){ e="RECHAZADA -> " + x.message.substring(0,60); }
  print("  transaccion: " + e);
' 2>&1 | sed 's/^/  /' | head -8
docker rm -f m40 >/dev/null 2>&1
echo "### temurin 8 arm64 nativo"
docker run --rm --platform linux/arm64 eclipse-temurin:8-jdk sh -c 'java -version 2>&1 | head -2; echo "  uname: $(uname -m)"' 2>&1 | sed 's/^/  /'
