# rescatado de la sesión 31a544c8, 2026-09-11T18:34:51Z · Check Lumen 5.8 dev dependencies
curl -s https://repo.packagist.org/p2/laravel/lumen-framework.json | python3 -c "
import json,sys
d=json.load(sys.stdin)
for v in d['packages']['laravel/lumen-framework']:
    if v['version'] in ('v5.8.13','v5.8.0'):
        print(v['version'], v.get('time'))
        print(' require-dev:', json.dumps(v.get('require-dev'), indent=1))
" 2>/dev/null || echo "sin red"
