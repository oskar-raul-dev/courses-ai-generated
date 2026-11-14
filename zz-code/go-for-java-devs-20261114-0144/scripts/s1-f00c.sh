#!/usr/bin/env bash
# Emula en linux/arm64 la receta de Apple Silicon: el envoltorio de go1.13 compilado para amd64.
set -uo pipefail
export PATH=$PATH:/go/bin
p() { echo; echo "### $*"; }
p "con GOBIN puesto (go env -w GOBIN=…): GOARCH=amd64 go install"
export GOENV=/tmp/goenv; go env -w GOBIN=/go/bin
GOARCH=amd64 go install golang.org/dl/go1.13@latest; echo "exit $?"
p "sin GOBIN"
go env -u GOBIN
GOARCH=amd64 go install golang.org/dl/go1.13@latest; echo "exit $?"
ls -la /go/bin/linux_amd64/ 2>&1
file /go/bin/linux_amd64/go1.13 2>/dev/null || od -An -c -N20 /go/bin/linux_amd64/go1.13 | head -2
p "con GOBIN vacío en el entorno"
go env -w GOBIN=/go/bin
GOBIN= GOARCH=amd64 go install golang.org/dl/go1.13@latest; echo "exit $?"
rm -rf /go/bin/linux_amd64
