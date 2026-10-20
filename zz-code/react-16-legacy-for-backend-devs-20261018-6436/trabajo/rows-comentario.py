import os
p = "server/internal/wheel/store.go"
if os.path.exists(p):
    s = open(p, encoding="utf-8").read()
    old = ("\t// Cada Rows abierto retiene una conexión del pool hasta que se cierra.\n"
           "\t// Este defer es la línea más barata del archivo y la más cara de olvidar.\n")
    new = ("\t// Un Rows abierto retiene su conexión hasta que lo cierra Close, el último\n"
           "\t// Next o la cancelación de su contexto. Si este bucle sale antes —un error\n"
           "\t// de Scan—, este defer la devuelve al pool sin depender de nada más.\n")
    if old in s:
        open(p, "w", encoding="utf-8").write(s.replace(old, new))
