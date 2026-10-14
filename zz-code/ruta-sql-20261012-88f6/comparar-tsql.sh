#!/usr/bin/env bash
# Compara dbo.fn_ExtraerDNI (SQL Server, 2016) con el port de Python de ExtraerDNI (2026) sobre
# nombres de legacy."Pacientes" (perfil cargado en Postgres). Deja salidas/comparar-tsql.tsv.
set -euo pipefail
cd "$(dirname "$0")"
SRC=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src
docker exec alameda-lab-postgres-1 psql -U postgres -d alameda -AtF $'\t' -c "
  (SELECT p.\"IdPaciente\", p.\"Nombre\" FROM legacy.\"Pacientes\" p JOIN truth.patient_record r
     ON r.legacy_patient_id = p.\"IdPaciente\" WHERE 'dni_in_name' = ANY(r.dirt) ORDER BY 1 LIMIT 3000)
  UNION ALL
  (SELECT \"IdPaciente\", \"Nombre\" FROM legacy.\"Pacientes\" ORDER BY md5(\"IdPaciente\"::text) LIMIT 1000)" \
  > salidas/nombres.tsv
python3 -I - "$SRC" salidas/nombres.tsv > salidas/comparar.sql <<'PY'
import sys
rows = [l.rstrip("\n").split("\t", 1) for l in open(sys.argv[2], encoding="utf-8")]
print("SET NOCOUNT ON; CREATE TABLE #n (id int, nombre nvarchar(255));")
for i in range(0, len(rows), 500):
    vals = ",".join(f"({k}, N'{n.replace(chr(39), chr(39)*2)}')" for k, n in rows[i:i+500])
    print(f"INSERT #n VALUES {vals};")
print("SELECT id, dbo.fn_ExtraerDNI(nombre) FROM #n;")
PY
docker cp salidas/comparar.sql alameda-lab-sqlserver-1:/tmp/comparar.sql >/dev/null
docker exec alameda-lab-sqlserver-1 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P Lab-2026-pass \
  -C -b -d ALAMEDA -f 65001 -h -1 -W -s $'\t' -i /tmp/comparar.sql > salidas/tsql-dni.tsv
python3 -I - "$SRC" salidas/nombres.tsv salidas/tsql-dni.tsv <<'PY'
import collections, sys
sys.path.insert(0, sys.argv[1])
from lab.generator.rubens_parser import extract_dni
names = dict(l.rstrip("\n").split("\t", 1) for l in open(sys.argv[2], encoding="utf-8"))
tsql = {}
for l in open(sys.argv[3], encoding="utf-8"):
    k, _, v = l.rstrip("\n").partition("\t")
    if k.strip().isdigit():
        tsql[k.strip()] = "" if v == "NULL" else v
diff = [(k, n, extract_dni(n), tsql[k]) for k, n in names.items() if extract_dni(n) != tsql[k]]
print(f"nombres {len(names)} · iguales {len(names) - len(diff)} · distintos {len(diff)}")
kinds = collections.Counter(n.split()[0] if n.split()[0] in ("RN",) else
                            ("OTRO" if " OTRO " in f" {n} " else "otro caso") for _, n, _, _ in diff)
print(dict(kinds))
for k, n, py, ts in diff[:15]:
    print(f"  {n!r}  python={py!r}  tsql={ts!r}")
PY
