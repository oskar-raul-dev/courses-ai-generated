# T3: arma a7 desde el borrador, insertando el Dockerfile y el devcontainer.json que corrieron, sin tocarlos.
import sys
borrador, dockerfile, devcontainer, destino = sys.argv[1:5]
s = open(borrador, encoding="utf-8").read()
for marca, ruta in (("__DOCKERFILE__", dockerfile), ("__DEVCONTAINER__", devcontainer)):
    contenido = open(ruta, encoding="utf-8").read().rstrip("\n")
    assert s.count(marca) == 1
    s = s.replace(marca, contenido)
open(destino, "w", encoding="utf-8").write(s)
print("escrito", destino)
