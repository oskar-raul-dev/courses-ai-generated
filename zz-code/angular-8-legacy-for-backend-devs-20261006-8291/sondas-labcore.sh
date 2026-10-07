#!/usr/bin/env bash
# Replays the LabCore probes of session f803daaa (09/09/2026) under today's rules:
# label curso=angular-8-legacy-for-backend-devs, no published port, work copy in salidas/.
#
#   ./sondas-labcore.sh transaccion   mongo:4.0 standalone on arm64: version, topology, and a transaction
#                                     that the server rejects (code 20)
#   ./sondas-labcore.sh temurin       eclipse-temurin:8-jdk runs natively on arm64
#   ./sondas-labcore.sh matriz        the 2019 Java driver (mongo-java-driver 3.8.2) against mongo 4.0 … 8.0,
#                                     with the rescued compose project (maven:3.8-eclipse-temurin-8 + mongo)
#   ./sondas-labcore.sh shells        which images still ship the "mongo" shell and which only "mongosh"
#   ./sondas-labcore.sh limpiar       removes everything this script created, by label and project name
#
# The 09/09 originals published port 3000 and ran unlabelled containers; that is all that changed.
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
ORIGEN="$AQUI/02-sondas-be-f803daaa/archivos/_tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f803daaa-f024-4042-af34-b44d49809430/scratchpad"
TRABAJO="$AQUI/salidas/sondas"
CURSO=angular-8-legacy-for-backend-devs
LABEL="curso=$CURSO"
PROYECTO=a8-labcore
TAGS="${TAGS:-4.0 4.2 4.4 5.0 6.0 7.0 8.0}"

transaccion() {
  docker rm -f a8-m40 >/dev/null 2>&1 || true
  docker run -d --name a8-m40 --label "$LABEL" --platform linux/arm64 mongo:4.0 >/dev/null && sleep 8
  echo "### mongo:4.0 arm64 nativo"
  docker exec a8-m40 mongo --quiet --eval '
    print("  version:    " + db.version());
    print("  arquitect.: " + db.serverBuildInfo().buildEnvironment.target_arch);
    print("  topologia:  " + (rs.status().ok ? "replica set" : "standalone"));
  ' 2>&1 | sed 's/^/  /' | head -4
  echo "### una transaccion en standalone"
  docker exec a8-m40 mongo --quiet --eval '
    var s = db.getMongo().startSession();
    var c = s.getDatabase("lab").custody;
    s.startTransaction();
    try { c.insertOne({step:"recepcion"}); s.commitTransaction(); print("  RESULTADO: transaccion COMPLETADA"); }
    catch(e){ print("  RESULTADO: RECHAZADA"); print("  codigo:  " + e.code + " (" + e.codeName + ")"); print("  mensaje: " + e.errmsg); }
  ' 2>&1 | sed 's/^/  /'
  docker rm -f a8-m40 >/dev/null
}

temurin() {
  echo "### temurin 8 arm64 nativo"
  docker run --rm --label "$LABEL" --platform linux/arm64 eclipse-temurin:8-jdk \
    sh -c 'java -version 2>&1 | head -2; echo "  uname: $(uname -m)"' 2>&1 | sed 's/^/  /'
}

preparar() {
  mkdir -p "$TRABAJO" && rm -rf "$TRABAJO/labcore" && cp -R "$ORIGEN/labcore" "$TRABAJO/"
  # .env was left out of the rescue (rule 6); its only line was the database tag
  printf '# La version de la base vive AQUI, fuera del codigo fuente.\nMONGO_TAG=4.0\n' > "$TRABAJO/labcore/.env"
  cat > "$TRABAJO/labcore/compose.override.yaml" <<EOF
services:
  db:
    labels: ["$LABEL"]
  api:
    ports: !reset []
    labels: ["$LABEL"]
volumes:
  mongodata:
    labels: ["$LABEL"]
  m2:
    labels: ["$LABEL"]
EOF
}

matriz() {
  preparar
  cd "$TRABAJO/labcore"
  echo "### primera compilacion (baja dependencias al volumen m2, una sola vez)"
  docker compose -p "$PROYECTO" run --rm -T api mvn -q compile 2>&1 | tail -3
  echo "### driver Java 3.8.2 (el de 2019) contra cada version de servidor"
  for tag in $TAGS; do
    printf "mongo:%-4s " "$tag"
    MONGO_TAG=$tag docker compose -p "$PROYECTO" rm -sfv db >/dev/null 2>&1 || true
    docker volume rm "${PROYECTO}_mongodata" >/dev/null 2>&1 || true
    MONGO_TAG=$tag docker compose -p "$PROYECTO" up -d db >/dev/null 2>&1
    sleep 7
    MONGO_TAG=$tag docker compose -p "$PROYECTO" run --rm -T api mvn -q exec:java 2>&1 | grep -E "OK |FALLA " | head -2
  done
  docker compose -p "$PROYECTO" down -v >/dev/null 2>&1
}

shells() {
  for t in 4.0 6.0 7.0; do
    printf "mongo:%-4s  " "$t"
    docker run --rm --label "$LABEL" --entrypoint sh --platform linux/arm64 "mongo:$t" -c '
      m=$(command -v mongo >/dev/null 2>&1 && echo si || echo NO)
      s=$(command -v mongosh >/dev/null 2>&1 && echo si || echo NO)
      echo "shell \"mongo\": $m   |   \"mongosh\": $s"' 2>&1 | tail -1
  done
}

limpiar() {
  [ -f "$TRABAJO/labcore/compose.yaml" ] && (cd "$TRABAJO/labcore" && docker compose -p "$PROYECTO" down -v >/dev/null 2>&1 || true)
  docker ps -aq --filter "label=$LABEL" | xargs -r docker rm -f
  docker volume ls -q --filter "label=$LABEL" | xargs -r docker volume rm
  rm -rf "$TRABAJO"
}

case "${1:-}" in
  transaccion) transaccion ;;
  temurin) temurin ;;
  matriz) matriz ;;
  shells) shells ;;
  limpiar) limpiar ;;
  *) sed -n '2,14p' "$0"; exit 1 ;;
esac
