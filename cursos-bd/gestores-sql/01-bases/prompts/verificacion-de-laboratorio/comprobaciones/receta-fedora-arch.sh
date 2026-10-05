# Receta de a01 y a02 en Fedora y Arch, tal como la escribiría el lector.
set -u
. /etc/os-release; echo "### $PRETTY_NAME · $(uname -m)"
if command -v dnf >/dev/null; then
  dnf install -y -q sqlite python3 >/dev/null 2>&1; rpm -q sqlite python3
else
  pacman -Sy --noconfirm --needed ${PACMAN_EXTRA:-} sqlite python >/dev/null 2>&1; pacman -Q sqlite python
fi
sqlite3 --version
python3 --version
python3 -m venv /tmp/venv && /tmp/venv/bin/pip install -q -r /req/requirements.txt 2>&1 | tail -2
/tmp/venv/bin/python -c "import sqlite3, faker; print('python', __import__('sys').version.split()[0], '· sqlite del módulo', sqlite3.sqlite_version, '· faker', faker.VERSION)"
printf '\\list;\n' | /tmp/venv/bin/radb /tmp/x.db 2>&1 | grep -E 'Version|relations'
/tmp/venv/bin/python /c/faker-semilla.py | tail -1
