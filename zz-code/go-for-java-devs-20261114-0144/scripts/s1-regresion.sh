#!/usr/bin/env bash
# S1 · regresión: lo que quedó en el curso, re-extraído, compila, pasa gofmt y make en verde.
set -uo pipefail
export PATH=$PATH:/go/bin
apt-get -qq update >/dev/null 2>&1; apt-get -qq install -y make >/dev/null 2>&1
M=/root/dev/meridian; cd $M
echo "### gofmt -l"; gofmt -l labs services; echo "(fin gofmt)"
echo "### go1.13 build/vet de los módulos del Bloque A"
for m in labs/movement-parser labs/text-toolkit labs/log-grep services/opsreport; do (cd $m && go1.13 vet ./... && go1.13 build ./... && echo "ok $m"); done
echo "### opsreport"; (cd services/opsreport && go1.13 run ./cmd/opsreport 2>&1)
echo "### make fmt vet lint test"; make fmt vet lint test; echo "exit $?"
