# Receta de a01 y a02 en Debian y Ubuntu, tal como la escribiría el lector.
set -u
. /etc/os-release; echo "### $PRETTY_NAME · $(uname -m)"
apt-get update -qq >/dev/null
apt-get install -y -qq sqlite3 python3 >/dev/null 2>&1
sqlite3 --version
python3 --version
echo "--- venv sin python3-venv:"
python3 -m venv /tmp/venv 2>&1 | head -12
apt-get install -y -qq python3-venv >/dev/null 2>&1
python3 -m venv /tmp/venv && /tmp/venv/bin/pip install -q -r /req/requirements.txt 2>&1 | tail -2
/tmp/venv/bin/python -c "import sqlite3, faker; print('python', __import__('sys').version.split()[0], '· sqlite del módulo', sqlite3.sqlite_version, '· faker', faker.VERSION)"
printf '\\list;\n' | /tmp/venv/bin/radb /tmp/x.db 2>&1 | grep -E 'Version|relations'
