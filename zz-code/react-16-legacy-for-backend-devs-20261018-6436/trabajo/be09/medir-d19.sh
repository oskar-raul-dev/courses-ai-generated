#!/usr/bin/env bash
# D19, medido: el binario del API con cgo (mattn, -tags sqlite), puro Go (sin SQLite) y con modernc.org/sqlite v1.19.5,
# cada uno con la caché de compilación vacía. Sobre una copia de server/ dentro del contenedor; el repo no se toca.
Z="$(cd "$(dirname "$0")/../.." && pwd)"
docker run --rm --label curso=react16 -v "$Z/esclusa-app/server":/src:ro -v r16t7-gomod:/go/pkg/mod golang:1.19.13 sh -c '
cp -r /src /w && cd /w
build() { go clean -cache; s=$(date +%s%N); sh -c "$2" >/tmp/log 2>&1 || { cat /tmp/log; return; }; e=$(date +%s%N)
  printf "%-26s binario %9s bytes · build en frío %5s ms · cgo: %s\n" "$1" "$(stat -c %s /tmp/bin)" "$(( (e-s)/1000000 ))" \
    "$(go version -m /tmp/bin | grep -o "CGO_ENABLED=[01]")"; }
build "cgo (mattn, -tags sqlite)" "CGO_ENABLED=1 go build -tags sqlite -o /tmp/bin ./cmd/api"
build "puro Go (sin SQLite)"      "CGO_ENABLED=0 go build -o /tmp/bin ./cmd/api"
go get modernc.org/sqlite@v1.19.5 >/dev/null 2>&1
printf "//go:build modernc\n\npackage storage\n\nimport _ \"modernc.org/sqlite\"\n" > internal/storage/driver_modernc.go
sed -i "s#^//go:build !sqlite#//go:build !sqlite \&\& !modernc#" internal/storage/driver_nosqlite.go
printf "//go:build modernc\n\npackage storage\n\nconst sqliteEnabled = true\n\nfunc sqliteUnique(error) bool     { return false }\nfunc sqliteForeignKey(error) bool { return false }\n" > internal/storage/driver_modernc_errors.go
build "modernc.org/sqlite v1.19.5" "CGO_ENABLED=0 go build -tags modernc -o /tmp/bin ./cmd/api"
echo "== SQLite en las pruebas, con mattn (go test -tags sqlite ./internal/wheel/, caché vacía)"
go clean -cache; s=$(date +%s%N); go test -tags sqlite -count=1 ./internal/wheel/ | tail -1; e=$(date +%s%N); echo "   $(( (e-s)/1000000 )) ms con la compilación"'
