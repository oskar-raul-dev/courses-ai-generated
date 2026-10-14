#!/usr/bin/env bash
# Tags recientes de cada imagen candidata (D12). Salida en salidas/tags-AAAAMMDD.txt
set -uo pipefail
cd "$(dirname "$0")"
consulta() { echo "== $1"; ./tags.sh "$1" "$2" | head -"${3:-12}"; }
{
consulta library/postgres '^[0-9]+(\.[0-9]+)?$'
consulta library/postgres '^19'
consulta library/mysql '^[0-9]+\.[0-9]+(\.[0-9]+)?$'
consulta library/mongo '^[0-9]+\.[0-9]+(\.[0-9]+)?$'
consulta postgrest/postgrest '^v[0-9]'
consulta apache/activemq-artemis '^[0-9]'
consulta apache/artemis '^[0-9]'
consulta pgvector/pgvector 'pg1[89]$'
consulta gvenzl/oracle-free '^2[0-9]\.[0-9]+' 20
echo "== mcr.microsoft.com/mssql/server (2025, CU ordenados)"
curl -fsS "https://mcr.microsoft.com/v2/mssql/server/tags/list" \
  | python3 -c 'import json,sys,re; t=[x for x in json.load(sys.stdin)["tags"] if re.match(r"2025-CU\d+(-GDR\d+)?-ubuntu-24.04$",x)]; t.sort(key=lambda x:[int(n) for n in re.findall(r"\d+",x)]); print("\n".join(t[-6:]))'
} 2>&1 | tee "salidas/tags-$(date +%Y%m%d).txt"
