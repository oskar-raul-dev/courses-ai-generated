# rescatado de la sesión 13793b0f, 2026-09-11T01:47:25Z · Check Cassandra image tags
curl -s --max-time 20 "https://hub.docker.com/v2/repositories/library/cassandra/tags?page_size=60" | python3 -c "
import sys,json,re
d=json.load(sys.stdin)
ns=[r['name'] for r in d.get('results',[]) if re.fullmatch(r'\d+\.\d+(\.\d+)?', r['name'])]
def key(n):
    p=[int(x) for x in n.split('.')]
    return p+[0]*(3-len(p))
print(sorted(set(ns), key=key)[-8:])
" 2>/dev/null || echo fallo
