#!/usr/bin/env bash
set -uo pipefail
export PATH=$PATH:/go/bin
p() { echo; echo "### $*"; }
rm -f /go/bin/golangci-lint
p "go install golangci-lint@v2.12.2"
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.12.2 2>&1 | tail -2
golangci-lint version
p "config verify"
cd /root/dev/meridian && golangci-lint config verify; echo "exit $?"
p "F00:L43 golangci-lint run ./... en la raíz del monorepo"
golangci-lint run ./... ; echo "exit $?"
p "golangci-lint run ./... en labs/hello-go"
cd labs/hello-go && golangci-lint run ./... ; echo "exit $?"; cd ../..
p "F00:L1075 make fmt vet lint test en la raíz"
apt-get -qq update >/dev/null 2>&1; apt-get -qq install -y make >/dev/null 2>&1 || true
make fmt vet lint test ; echo "exit $?"
p "make help"
make help
