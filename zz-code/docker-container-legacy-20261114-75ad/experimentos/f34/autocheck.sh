# 1. la imagen construye desde cero, sin caché
docker build --no-cache --platform linux/amd64 -t proyecto-final:v1 . && echo "OK 1"

# 2. ninguna versión lleva rango ni latest
! grep -nE ':(latest|[0-9]+\.x)|\^[0-9]|~[0-9]' Dockerfile && echo "OK 2"

# 3. el proyecto NO está dentro de la imagen
! docker run --rm proyecto-final:v1 test -e /workspace/package.json && echo "OK 3"

# 4. el volumen sigue la convención de nombres con la generación
docker volume ls --format '{{.Name}}' | grep -qE '\-node(10|12|14|16)\-modules$' && echo "OK 4"

# 5. el expediente tiene sus tres piezas
test -f VALIDATION-REPORT.md && test -d evidencia && ls evidencia/*.log >/dev/null && echo "OK 5"

# 6. el reporte declara arquitectura y versión de Node
grep -qE 'linux/(amd64|arm64)' VALIDATION-REPORT.md && \
grep -qE '1[0246]\.[0-9]+\.[0-9]+' VALIDATION-REPORT.md && echo "OK 6"

# 7. la matriz de las cuatro generaciones está completa
grep -c -E '10\.24\.1|12\.22\.12|14\.21\.3|16\.20\.2' VALIDATION-REPORT.md   # debe dar 4 o más
