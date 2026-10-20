# Piloto genérico de inquirer por pseudo-terminal. Reglas: (texto de la pregunta, acción).
# Acciones: "enter", "y", "n", ("lista", texto_opcion), ("casillas", [textos]).
import os, pty, re, select, sys, time, json
reglas = json.loads(sys.argv[1]); cmd = sys.argv[2:]
ANSI = re.compile(r"\x1b\[[0-9;?]*[a-zA-Z]")
pid, fd = pty.fork()
if pid == 0:
    os.execvp(cmd[0], cmd)
buf = ""; log = open("/app/../piloto.log", "w") if os.path.isdir("/app") else open("piloto.log", "w")
def leer(espera=1.5):
    global buf
    fin = time.time() + espera
    while time.time() < fin:
        r, _, _ = select.select([fd], [], [], 0.2)
        if r:
            try: d = os.read(fd, 4096).decode("utf-8", "replace")
            except OSError: return False
            if not d: return False
            buf += d; log.write(d); log.flush(); fin = time.time() + espera
    return True
def enviar(s): os.write(fd, s.encode())
def bloque():
    t = ANSI.sub("", buf); lineas = t.split("\n")
    qi = max([i for i, l in enumerate(lineas) if l.lstrip().startswith("? ")] or [-1])
    return lineas[qi:] if qi >= 0 else []
def lista(texto):
    b = bloque()
    filas = [l for l in b[1:] if l.strip() and not l.strip().startswith("-") and "Use arrow keys" not in l]
    ops = [l.strip(" ❯>◯◉*\r").strip() for l in filas]
    actual = next((i for i, l in enumerate(filas) if "❯" in l), 0)   # el cursor arranca en la recomendada
    idx = next((i for i, o in enumerate(ops) if texto.lower() in o.lower()), actual)
    mov = "\x1b[B" * (idx - actual) if idx >= actual else "\x1b[A" * (actual - idx)
    log.write(f"\n[piloto] lista {ops} cursor={actual} -> {texto} idx={idx}\n"); enviar(mov + "\r")
hechas = []
inicio = time.time(); quieto = 0
while time.time() - inicio < 1500:
    vivo = leer()
    b = bloque(); preg = " ".join(b[:2]).lower()
    clave = preg[:120]
    if b and clave not in hechas and ("(y/n)" in preg or "use arrow keys" in " ".join(b).lower() or preg.rstrip().endswith(")")):
        accion = "enter"
        for texto, acc in reglas:
            if texto.lower() in preg: accion = acc; break
        time.sleep(0.4); leer(0.6)
        log.write(f"\n[piloto] pregunta: {b[0].strip()[:110]} -> {accion}\n")
        if accion == "enter": enviar("\r")
        elif accion in ("y", "n"): enviar(accion + "\r")
        elif isinstance(accion, list) and accion[0] == "lista": lista(accion[1])
        hechas.append(clave)
    if not vivo: break
log.close(); _, estado = os.waitpid(pid, 0); print("piloto estado", estado)
