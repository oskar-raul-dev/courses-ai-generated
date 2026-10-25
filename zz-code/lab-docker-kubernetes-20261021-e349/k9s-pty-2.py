"""F21 §5.8: k9s 0.51.0 contra kind-lab, manejada por una terminal emulada (pyte) porque la sesión no tiene una
interactiva. Cada paso manda las teclas de la tabla de la fase y guarda la pantalla resultante.
Uso: <python con pyte> k9s-pty.py > logs/f21-k9s.log"""
import fcntl, os, pty, select, struct, termios, time
import pyte, sys
READONLY = "--readonly" in sys.argv

COLS, ROWS = 170, 46
screen = pyte.Screen(COLS, ROWS); stream = pyte.ByteStream(screen)
pid, fd = pty.fork()
if pid == 0:
    os.environ["TERM"] = "xterm-256color"
    os.execvp("k9s", ["k9s"] + (["--readonly"] if READONLY else []) + [ "--context", "kind-lab", "-n", "apps", "-c", "pods", "--headless", "--logoless"])
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

import sys
pump(8)
keys("/replenish-\r")
keys("F", 3); shot("shift-f sobre replenish: port-forward" + (" (readonly)" if READONLY else ""))
keys("\x1b", 2)
keys("s", 5); shot("s sobre replenish: shell" + (" (readonly)" if READONLY else ""))
keys("exit\r", 3); keys("\x1b", 2); keys(":q\r", 2)
os.kill(pid, 15)
