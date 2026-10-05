# P8 bloque A.C.: YottaDB r2.06 nativo en arm64, un global desde M y desde Python.
# sin set -u: ydb_env_set lee variables que pueden no existir
. /etc/os-release; echo "### $PRETTY_NAME · $(uname -m)"
. /opt/yottadb/current/ydb_env_set
echo "ydb_dist=$ydb_dist"
"$ydb_dist/yottadb" -version 2>&1 | head -3
"$ydb_dist/yottadb" -run %XCMD 'set ^student(1)="Ana",^student(1,"section","7A")="",^student(2)="Beatriz" write $order(^student(1)),!'
apt-get update -qq >/dev/null; apt-get install -y -qq python3-venv python3-dev gcc pkg-config libffi-dev >/dev/null 2>&1
python3 -m venv /tmp/vy && /tmp/vy/bin/pip install -q yottadb 2>&1 | tail -3
/tmp/vy/bin/python - <<'PY'
import yottadb
from importlib.metadata import version
student = yottadb.Key("^student")
print("yottadb", version("yottadb"), "· ^student(1) =", student["1"].value.decode(),
      "· hijos de ^student:", [k.decode() for k in student.subscripts])
PY
