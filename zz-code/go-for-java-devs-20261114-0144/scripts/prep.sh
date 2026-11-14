# Se incluye al principio de cada script de tanda: herramientas y goimports sobre los parches fusionados.
export PATH=$PATH:/go/bin
p() { echo; echo "### $*"; }
M=/root/dev/meridian
command -v goimports >/dev/null || go install golang.org/x/tools/cmd/goimports@v0.36.0 >/dev/null 2>&1
command -v jq >/dev/null || { apt-get -qq update >/dev/null 2>&1; apt-get -qq install -y make sqlite3 jq >/dev/null 2>&1; }
if [ -f /scripts/fusionados.txt ]; then
  sort -u /scripts/fusionados.txt | while read -r f; do [ -f "$M/$f" ] && goimports -w "$M/$f"; done
fi
# Módulos: crea el go.mod de cada directorio de modulos.tsv que exista y no lo tenga.
grep -v '^#' /scripts/modulos.tsv | while IFS=$'\t' read -r dir mod tool fase; do
  [ -d "$M/$dir" ] && [ ! -f "$M/$dir/go.mod" ] && (cd "$M/$dir" && $tool mod init "$mod" >/dev/null 2>&1)
done
