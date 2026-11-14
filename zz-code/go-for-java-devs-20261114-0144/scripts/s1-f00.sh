#!/usr/bin/env bash
# S1 · F00 — los comandos de la fase, en orden, dentro del contenedor.
# Cada paso imprime "### F00:Lnnn" con la línea de la fase cuya salida se compara.
set -uo pipefail
export PATH=$PATH:/go/bin
p() { echo; echo "### $*"; }
M=/root/dev/meridian

p "F00:L80 go version"
go version

p "F00:L106 go install golang.org/dl/go1.13@latest && go1.13 download && go1.13 version"
go install golang.org/dl/go1.13@latest
go1.13 download 2>&1 | tail -3
go1.13 version
p "dl: ¿qué hace el envoltorio en darwin/arm64 con versiones < 1.16?"
grep -rn -i "rosetta\|darwin.*arm64\|arm64.*darwin" /go/pkg/mod/golang.org/dl@*/internal/version/version.go | head

p "F00:L136 mkdir services/opsreport && go mod init (con go1.25.1)"
rm -rf $M/_f00 && mkdir -p $M/_f00/services/opsreport && cd $M/_f00/services/opsreport
go mod init github.com/meridian/opsreport
cat go.mod

p "F00:L174 go env GOROOT GOPATH GOMODCACHE GOBIN GOFLAGS"
go env GOROOT GOPATH GOMODCACHE GOBIN GOFLAGS
p "F00:L330 go env GOROOT GOPATH GOBIN GOMODCACHE GOFLAGS GOPROXY GOPRIVATE GONOSUMDB"
go env GOROOT GOPATH GOBIN GOMODCACHE GOFLAGS GOPROXY GOPRIVATE GONOSUMDB
p "ejercicio 2: go1.13 env GOROOT"
go1.13 env GOROOT

p "F00:L252 go tool dist list | wc -l"
go tool dist list | wc -l

p "F00:L369 hello-go"
mkdir -p $M/labs/hello-go && cd $M/labs/hello-go
rm -f go.mod go.sum
go mod init github.com/meridian/labs/hello-go
p "F00:L388 go run ."
go run .
p "F00:L1004 cat go.mod"
cat go.mod

p "F00:L402 import os sin usar"
cp main.go /tmp/main.go.bak
sed -i 's/^import "fmt"$/import (\n\t"fmt"\n\t"os"\n)/' main.go
go build . ; cp /tmp/main.go.bak main.go
p "F00:L414 variable sin usar"
cat > main.go <<'GO'
// labs/hello-go/main.go
package main

import "fmt"

func main() {
	count := 42
	fmt.Println("Meridian platform tooling check")
}
GO
go build . ; cp /tmp/main.go.bak main.go

p "F00:L1027 go get uuid"
go get github.com/google/uuid@v1.6.0
cat go.mod; cat go.sum
p "F00:L1048 go mod tidy"
go mod tidy; cat go.mod
p "F00:L1060 go mod why / graph / list"
go mod why github.com/google/uuid
go mod graph | head
go list -m all

p "F00:L435 build-info"
mkdir -p $M/labs/build-info && cd $M/labs/build-info
rm -f go.mod; go mod init github.com/meridian/labs/buildinfo
p "F00:L464 go build && ./bin/buildinfo"
go build -o bin/buildinfo . && ./bin/buildinfo
p "F00:L473 -ldflags -X (sin git: commit fijo)"
git config --global --add safe.directory '*' 2>/dev/null
go build -ldflags "\
  -X main.version=0.1.0 \
  -X main.commit=$(git rev-parse --short HEAD 2>/dev/null || echo 4f2a19c) \
  -X main.buildDate=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  -o bin/buildinfo .
./bin/buildinfo
p "F00:L491 -s -w: tamaño antes y después"
go build -o bin/full . && go build -ldflags "-s -w" -o bin/stripped . && ls -l bin/full bin/stripped | awk '{print $5, $9}'

p "F00:L517 crossbuild"
mkdir -p $M/labs/crossbuild && cd $M/labs/crossbuild
rm -f go.mod; go mod init github.com/meridian/labs/crossbuild
cat > main.go <<'GO'
package main

import "fmt"

var version = "dev"

func main() { fmt.Println("crossbuild", version) }
GO
cat > build-all.sh <<'SH'
#!/usr/bin/env bash
# labs/crossbuild/build-all.sh
# Compila el mismo paquete para cinco plataformas. Sin Docker, sin toolchain
# cruzado, sin plugin: dos variables de entorno por objetivo.
set -euo pipefail

APP="crossbuild"
LDFLAGS="-s -w -X main.version=0.1.0"

targets=(
  "darwin/arm64"
  "darwin/amd64"
  "linux/amd64"
  "linux/arm64"
  "windows/amd64"
)

rm -rf bin && mkdir -p bin

for target in "${targets[@]}"; do
  os="${target%/*}"
  arch="${target#*/}"
  out="bin/${APP}-${os}-${arch}"
  [ "$os" = "windows" ] && out="${out}.exe"

  echo "==> ${os}/${arch}"
  GOOS="$os" GOARCH="$arch" CGO_ENABLED=0 go build -ldflags "$LDFLAGS" -o "$out" .
done

ls -lh bin/
SH
chmod +x build-all.sh
p "F00:L559 time ./build-all.sh"
go clean -cache
time ./build-all.sh

p "F00:L832 golangci-lint"
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest 2>&1 | tail -5
golangci-lint version
p "golangci-lint con .golangci.yml del curso"
cd $M && cp /scripts/../lector/.golangci.yml . 2>/dev/null; ls -la .golangci.yml
cd $M/labs/hello-go && golangci-lint config verify -c $M/.golangci.yml 2>&1 | tail -5
golangci-lint run -c $M/.golangci.yml ./... 2>&1 | tail -5

p "F00:L1126 epoch-test"
rm -rf /tmp/epoch-test && mkdir -p /tmp/epoch-test && cd /tmp/epoch-test
go mod init epochtest
cat > main.go <<'GO'
// main.go — usa slices.Sort, que llegó en Go 1.21
package main

import (
	"fmt"
	"slices"
)

func main() {
	priorities := []int{5, 2, 9, 1}
	slices.Sort(priorities)
	fmt.Println(priorities)
}
GO
cat go.mod
p "F00:L1147 go build ."
go build . && echo "compila: exit $?"
p "F00:L1148 go1.13 build ."
go1.13 build . ; echo "exit $?"
p "variante: go.mod con go 1.13"
go mod edit -go=1.13 && cat go.mod && go1.13 build . ; echo "exit $?"
p "variante: go build con go.mod en 1.13 (toolchain moderno)"
go build . ; echo "exit $?"
