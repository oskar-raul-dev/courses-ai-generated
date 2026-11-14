#!/usr/bin/env bash
. /scripts/prep.sh
cd $M/labs/text-toolkit
for v in v0.21.1 v0.21.0 v0.20.0; do echo "== gopls $v"; GOWORK=off timeout 300 go run golang.org/x/tools/gopls/internal/analysis/modernize/cmd/modernize@$v ./... 2>&1 | tail -4; echo "exit $?"; done
echo "== x/tools passes/modernize"; GOWORK=off timeout 300 go run golang.org/x/tools/go/analysis/passes/modernize/cmd/modernize@latest ./... 2>&1 | tail -3
