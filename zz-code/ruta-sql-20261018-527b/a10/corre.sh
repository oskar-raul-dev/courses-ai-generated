#!/usr/bin/env bash
# a10 · la prueba del Access de museo, en contenedores: dependencias, generar, exportar, parsear, aplicar y consultar.
set -euo pipefail
A=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src/a10-el-access-de-museo
Z=$(cd "$(dirname "$0")/.." && pwd)
MVN=maven@sha256:a291659c5ffddf142e5174df5bfc3f3dcb48706e44868f341ef7914b39a254c9
JAVA=eclipse-temurin@sha256:589ff4cc3f71aab462e7048a47a0d10edf57fbccde3fceea2281e610bf5880b4
UV=ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim@sha256:0f373734b28e2dea75993003daacf1badd7aa88f3ba88e8d1b4779dabf54ad08
r() { docker run --rm --label curso=ruta-sql -v "$A":/w -w /w "$@"; }
cd "$A"
r -v "$Z/salidas/m2":/root/.m2 $MVN mvn -q dependency:copy-dependencies -DoutputDirectory=lib
echo "jars: $(ls lib | wc -l)"
mkdir -p out
r $JAVA java -cp "lib/*" AccdbTool.java generate out/alameda_1998.accdb
r $JAVA java -cp "lib/*" AccdbTool.java export out/alameda_1998.accdb out/pacientes.csv
r $UV python3 parse_patients.py out/pacientes.csv out/pacientes_parseado.csv
cp out/alameda_1998.accdb out/alameda_1998_parseado.accdb
r $JAVA java -cp "lib/*" AccdbTool.java apply out/alameda_1998_parseado.accdb out/pacientes_parseado.csv
r $JAVA java -cp "lib/*" QueryAccdb.java demo out/alameda_1998.accdb
r $JAVA java -cp "lib/*" QueryAccdb.java query out/alameda_1998.accdb "SELECT COUNT(*) FROM pacientes WHERE dni IS NULL"
