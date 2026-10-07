# rescatado de la sesión f803daaa, 2026-09-09T03:51:48Z · Check php 7.4 image architectures on Docker Hub
for t in 7.4-cli 7.4-apache 7.4-fpm; do
  echo "=== php:$t ==="
  curl -s --max-time 20 "https://hub.docker.com/v2/repositories/library/php/tags/$t/" \
  | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
except Exception as e:
    print('  no se pudo leer:',e); raise SystemExit
if 'images' not in d: print('  respuesta inesperada:',str(d)[:200]); raise SystemExit
for i in d['images']:
    print('  %-8s %-8s %-6s %s' % (i.get('os'), i.get('architecture'), i.get('variant') or '', i.get('status')))
print('  last_pushed:', d.get('tag_last_pushed'))
"
done
