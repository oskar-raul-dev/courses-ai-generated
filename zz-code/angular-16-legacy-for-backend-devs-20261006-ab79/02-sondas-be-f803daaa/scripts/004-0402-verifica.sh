# rescatado de la sesión f803daaa, 2026-09-09T04:02:53Z · Check arm64 availability for mongo, temurin 8 and postgres tags
chk(){ curl -s --max-time 20 "https://hub.docker.com/v2/repositories/library/$1/tags/$2/" \
 | python3 -c "
import sys,json
d=json.load(sys.stdin)
if 'images' not in d: print('  %-22s NO EXISTE' % '$1:$2'); raise SystemExit
arch=sorted({i['architecture'] for i in d['images'] if i.get('status')=='active'})
mark='arm64 SI ' if 'arm64' in arch else 'arm64 NO '
print('  %-22s %s  [%s]  push %s' % ('$1:$2', mark, ','.join(arch), (d.get('tag_last_pushed') or '')[:10]))
" 2>/dev/null || echo "  $1:$2  (sin respuesta)"; }
echo "=== MongoDB ==="
for v in 3.6 4.0 4.2 4.4 5.0 6.0 7.0 8.0; do chk mongo $v; done
echo "=== JDK 8 ==="
for v in 8-jdk 8-jdk-focal 8-jdk-jammy; do chk eclipse-temurin $v; done
echo "=== PostgreSQL ==="
for v in 15 16 17 18; do chk postgres $v; done
