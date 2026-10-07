# rescatado de la sesión f803daaa, 2026-09-09T03:54:06Z · Inspect apt sources and test archive repo
docker run --rm --platform linux/arm64 php:7.4-cli sh -c '
echo "--- sources.list ---"; cat /etc/apt/sources.list 2>/dev/null
echo "--- sources.list.d ---"; ls -la /etc/apt/sources.list.d/ 2>/dev/null
echo "--- prueba archive ---"
printf "deb http://archive.debian.org/debian bullseye main\ndeb http://archive.debian.org/debian-security bullseye-security main\n" > /etc/apt/sources.list
apt-get -o Acquire::Check-Valid-Until=false update 2>&1 | tail -8
' 2>&1 | head -40
