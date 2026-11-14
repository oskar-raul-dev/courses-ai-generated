#!/usr/bin/env bash
set -uo pipefail
export PATH=$PATH:/go/bin
apt-get -qq update >/dev/null 2>&1; apt-get -qq install -y make >/dev/null 2>&1
cd /root/dev/meridian
echo "### F00:L1099 make fmt vet lint test"; make fmt vet lint test; echo "exit $?"
echo "### make cover (sin tests todavía)"; make cover; echo "exit $?"
echo "### make clean"; make clean; echo "exit $?"
