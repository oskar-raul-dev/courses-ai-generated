# T2: compara el CSS de la ruta Q compilado con Dart Sass (arm64) y con node-sass (amd64).
# Normaliza lo que es solo forma (comentarios, ceros a la izquierda) y lista lo que queda distinto.
import re, sys
def rules(p):
    s = open(p).read()
    s = re.sub(r'/\*.*?\*/', '', s, flags=re.S)
    s = re.sub(r'(?<![\w.])0\.(\d)', r'.\1', s)
    return [r.strip() for r in s.split('}') if r.strip()]
a, b = rules(sys.argv[1]), rules(sys.argv[2])
sa, sb = set(a), set(b)
print(len(a), len(b), 'solo-dart', len(sa - sb), 'solo-node-sass', len(sb - sa))
for x in sorted(sa - sb)[:15]: print('D', x[:200])
for x in sorted(sb - sa)[:15]: print('N', x[:200])
