# Responde las preguntas de `quasar create` eligiendo opciones por su texto (pseudo-terminal).
import os, pty, re, select, sys, time
cmd = sys.argv[1:]
ANSI = re.compile(r"\x1b\[[0-9;?]*[a-zA-Z]")
pid, fd = pty.fork()
if pid == 0:
    os.execvp(cmd[0], cmd)
buf = ""; log = open(os.environ.get("Q_LOG", "/work/piloto.log"), "w")
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
def pantalla(): return ANSI.sub("", buf)
def enviar(s): os.write(fd, s.encode())
ABAJO = "\x1b[B"
def elegir(lista_texto):
    # cuenta las opciones visibles después de la última pregunta y baja hasta la deseada
    t = pantalla(); q = t.rfind("?")
    opciones = [l.strip(" ❯>◯◉●○*").strip() for l in t[q:].split("\n")[1:]
                if l.strip() and not l.strip().startswith("-") and "Use arrow keys" not in l]
    idx = next((i for i, o in enumerate(opciones) if lista_texto.lower() in o.lower()), None)
    log.write(f"\n[piloto] opciones={opciones} -> {lista_texto} idx={idx}\n")
    if idx is None: idx = 0
    enviar(ABAJO * idx + "\r")
def marcar(deseadas):
    t = pantalla(); q = t.rfind("?")
    opciones = [l.strip(" ❯>◯◉●○\r").strip() for l in t[q:].split("\n")[1:] if ("◯" in l or "◉" in l)]
    marcadas = [l for l in t[q:].split("\n")[1:] if "◉" in l]
    log.write(f"\n[piloto] checkbox opciones={opciones} marcadas={marcadas}\n")
    pos = 0
    for i, o in enumerate(opciones):
        quiero = any(d.lower() in o.lower() for d in deseadas)
        ya = any(o in m for m in marcadas)
        if quiero != ya:
            enviar(ABAJO * (i - pos)); pos = i; enviar(" "); time.sleep(0.2)
    enviar("\r")
hechas = set()
reglas = [
    ("Project name", lambda: enviar("\r")), ("product name", lambda: enviar("\r")),
    ("Project description", lambda: enviar("\r")), ("Author", lambda: enviar("\r")), ("Cordova/Capacitor id", lambda: enviar("\r")),
    ("CSS preprocessor", lambda: elegir("SCSS")),
    ("import strategy", lambda: elegir(os.environ.get("Q_IMPORT", "Auto-import"))),
    ("features needed", lambda: marcar(os.environ.get("Q_FEATURES", "ESLint,Vuex,Axios").split(","))),
    ("ESLint preset", lambda: elegir("Standard")),
    ("install project dependencies", lambda: elegir("NPM")),
    ("Yes, use Yarn", lambda: elegir("NPM")),   # la pregunta se corta en "created? (": se reconoce por sus opciones
]
inicio = time.time()
while time.time() - inicio < 900:
    vivo = leer()
    t = pantalla()
    lineas = re.split(r"[\r\n]|(?=\? )", t)   # el spinner separa con \r, no con \n
    qi = max([i for i, l in enumerate(lineas) if l.lstrip().startswith("? ")] or [-1])
    ultima = " ".join([l for l in lineas[qi:] if l.strip()][:6]) if qi >= 0 else ""
    if ultima != globals().get("_vista"):
        globals()["_vista"] = ultima; log.write(f"\n[traza] vivo={vivo} ultima={ultima[-140:]!r}\n"); log.flush()
    for clave, accion in reglas:
        if clave not in hechas and clave.lower() in ultima.lower():
            time.sleep(0.4); leer(0.8); accion(); hechas.add(clave); break
    if not vivo: break
log.write(f"\n[piloto] respondidas: {sorted(hechas)}\n"); log.close()
_, estado = os.waitpid(pid, 0)
print("piloto: respondidas", sorted(hechas), "estado", estado)
