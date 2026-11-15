# bullseye tras su fin de vida (agosto de 2026): la seguridad se mudó a archive.debian.org
set -u; echo "== sources antes"; grep -rh "^deb" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null
sudo sed -i 's#http://security.debian.org/debian-security#http://archive.debian.org/debian-security#' /etc/apt/sources.list
echo "== sources después"; grep -rh "^deb" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null
rm -rf ~/lab ~/node-v14.21.3
