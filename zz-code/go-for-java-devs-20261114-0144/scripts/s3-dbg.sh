#!/usr/bin/env bash
. /scripts/prep.sh
cd $M/labs/golden-report && go1.13 test -run TestWriteCSV -update . 2>&1 | tail -5; ls testdata 2>&1
cd $M/services/opsreport && go1.13 test ./internal/opsreport 2>&1 | head -30
which goimports
