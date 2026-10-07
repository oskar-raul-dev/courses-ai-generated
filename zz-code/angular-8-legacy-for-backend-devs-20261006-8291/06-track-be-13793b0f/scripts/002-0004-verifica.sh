# rescatado de la sesión 13793b0f, 2026-09-11T00:04:35Z · Check Testcontainers versions on Maven Central
curl -s --max-time 20 "https://search.maven.org/solrsearch/select?q=g:org.testcontainers+AND+a:testcontainers&core=gav&rows=8&wt=json" | python3 -c "
import sys,json
d=json.load(sys.stdin)['response']['docs']
print([x['v'] for x in d])
" 2>/dev/null || echo "fallo"
