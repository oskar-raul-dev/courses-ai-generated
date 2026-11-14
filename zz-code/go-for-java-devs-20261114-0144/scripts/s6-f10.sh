#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
for m in labs/client-timeouts labs/backoff-lab services/atlassync services/eventrelay services/storeagent; do (cd $M/$m && go mod edit -go=1.25.1 && go mod tidy >/dev/null 2>&1); done
bash /scripts/compila.sh go labs/client-timeouts labs/backoff-lab services/atlassync
echo "-- eventrelay circuit/httpsender"; (cd $M/services/eventrelay && go vet ./internal/circuit/ ./internal/httpsender/ 2>&1 | head)
echo "-- storeagent sync"; (cd $M/services/storeagent && go vet ./internal/sync/ 2>&1 | head)
p "APIs reales (E8: pocas llamadas)"
curl -s -o /tmp/rc.json -w 'restcountries fields: %{http_code} %{size_download} B\n' 'https://restcountries.com/v3.1/all?fields=name,cca2,cca3,currencies,languages,timezones,region,subregion'
curl -s -o /dev/null -w 'restcountries sin fields: %{http_code}\n' 'https://restcountries.com/v3.1/all'
curl -s -o /tmp/fx.json -w 'frankfurter.app: %{http_code} %{redirect_url}\n' 'https://api.frankfurter.app/latest?from=EUR'; head -c 200 /tmp/fx.json; echo
curl -s -o /dev/null -w 'frankfurter.dev: %{http_code}\n' 'https://api.frankfurter.dev/v1/latest?base=EUR'
jq 'length, .[0] | keys? // .' /tmp/rc.json 2>/dev/null | head -12
