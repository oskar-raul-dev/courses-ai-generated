# rescatado de la sesión 13793b0f, 2026-09-10T23:42:41Z · List exact mongo patch tags
for p in 4.4 6.0 7.0; do echo "== $p =="; curl -s --max-time 25 "https://hub.docker.com/v2/repositories/library/mongo/tags?page_size=100&name=$p." | python3 -c "
import sys,json,re
d=json.load(sys.stdin)
ns=[r['name'] for r in d.get('results',[]) if re.fullmatch(r'\d+\.\d+\.\d+', r['name'])]
def key(n): return tuple(int(x) for x in n.split('.'))
print(sorted(set(ns), key=key)[-4:])
"; done
