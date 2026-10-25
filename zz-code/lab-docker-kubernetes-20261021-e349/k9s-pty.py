"""F21 §5.8: k9s 0.51.0 contra kind-lab, manejada por una terminal emulada (pyte) porque la sesión no tiene una
interactiva. Cada paso manda las teclas de la tabla de la fase y guarda la pantalla resultante.
Uso: <python con pyte> k9s-pty.py > logs/f21-k9s.log"""
import fcntl, os, pty, select, struct, termios, time
import pyte

COLS, ROWS = 170, 46
screen = pyte.Screen(COLS, ROWS); stream = pyte.ByteStream(screen)
pid, fd = pty.fork()
if pid == 0:
    os.environ["TERM"] = "xterm-256color"
    os.execvp("k9s", ["k9s", "--readonly", "--context", "kind-lab", "-n", "apps", "-c", "pods", "--headless", "--logoless"])
fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", ROWS, COLS, 0, 0))

def pump(seconds):
    end = time.time() + seconds
    while time.time() < end:
        r, _, _ = select.select([fd], [], [], 0.1)
        if r:
            try: stream.feed(os.read(fd, 65536))
            except OSError: return

def shot(title):
    print(f"===== {title}")
    for line in screen.display:
        if line.strip(): print(line.rstrip())

def keys(data, wait=3):
    os.write(fd, data.encode()); pump(wait)

pump(8); shot(":pods (al abrir)")
keys("/pricing\r"); shot("/ para filtrar: pricing")
keys("d", 4); shot("d sobre el pod: describe")
keys("\x1b"); keys("\x1b", 2)
keys(":events\r", 4); shot(":events")
keys(":pods\r", 4); keys("/inventory\r")
keys("l", 5); shot("l: logs de inventory")
keys("p", 5); shot("p dentro de los logs: --previous")
keys("\x1b"); keys("\x1b", 2)
keys("F", 3); shot("shift-f: port-forward")
keys("\x1b", 2)
keys("s", 3); shot("s: shell (en --readonly)")
keys("\x1b"); keys(":q\r", 2)
os.kill(pid, 15)
