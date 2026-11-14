#!/usr/bin/env bash
. /scripts/prep.sh
cd $M && make lint 2>&1 | grep -v "^0 issues"; echo "exit $?"
