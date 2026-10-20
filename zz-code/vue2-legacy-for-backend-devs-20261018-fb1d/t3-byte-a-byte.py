# T3: los bloques ```dockerfile y ```jsonc de a7 son byte a byte los archivos que corrieron (guía §17.5.6).
import re, sys
md, dockerfile, devcontainer = sys.argv[1:4]
s = open(md, encoding="utf-8").read()
for lenguaje, ruta in (("dockerfile", dockerfile), ("jsonc", devcontainer)):
    bloques = re.findall(r"^```" + lenguaje + r"\n(.*?)\n```$", s, flags=re.S | re.M)
    original = open(ruta, encoding="utf-8").read().rstrip("\n")
    print(lenguaje, len(bloques), "bloque(s)", "IGUAL" if bloques and bloques[0] == original else "DISTINTO")
