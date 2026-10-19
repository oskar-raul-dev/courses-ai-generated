# Edita los incidentes 01–06 del cuaderno (solo esa zona), con comprobación de cada reemplazo.
# Uso: python3 editar_cuaderno_01_06.py <ruta-al-cuaderno> <carpeta-de-pruebas>
import re
import sys
from pathlib import Path

CUADERNO = Path(sys.argv[1])
PRUEBAS = Path(sys.argv[2])
s = CUADERNO.read_text(encoding="utf-8")
INI = s.index("## Incidente 01 —")
FIN = s.index("## Incidente 07 —")


def patron(old):
    # Espacios y saltos de línea entre palabras: el texto del cuaderno está partido a mano.
    return r"\s+".join(re.escape(w) for w in old.split())


def rep(old, new, count=1):
    global s, FIN
    z = s[INI:FIN]
    hits = len(re.findall(patron(old), z))
    assert hits == count, f"esperaba {count} y hay {hits} en 01–06: {old[:70]!r}"
    z2 = re.sub(patron(old), lambda m: new, z)
    s = s[:INI] + z2 + s[FIN:]
    FIN = FIN + (len(z2) - len(z))


def bloque(inicio, fin, nuevo):
    global s, FIN
    i = s.index(inicio, INI)
    assert i < FIN, inicio
    j = s.index(fin, i) + len(fin)
    s = s[:i] + nuevo + s[j:]
    FIN = FIN + len(nuevo) - (j - i)


def leer(nombre):
    return (PRUEBAS / nombre).read_text(encoding="utf-8").split("\n", 1)[1].rstrip("\n")


# ---------- 02
rep("pinta tarjetas de rifas", "pinta tarjetas de ruedas")
rep("- **Datos:** no aplica.\n- **Hace falta",
    "- **Datos:** no aplica.\n- **Reproducción en contenedor:** parcial. `node-sass` 4.14.1 compila en `node:14` arm64 mientras la imagen tenga Python 2 (la trae). El `node-gyp` que falla es el de una máquina sin Python 2 o con `npm_config_python=python3`, que es el caso de un Mac; el fenómeno del USB necesita dos máquinas. Ambos se verifican a mano.\n- **Hace falta")

# ---------- 03
rep('cada vez que hago clic en "Rifas" la pantalla', 'cada vez que hago clic en "Ruedas" la pantalla')
rep("llenando el formulario de una rifa", "llenando el formulario de una rueda")
rep("**Reportado por:** supervisor de ventas", "**Reportado por:** supervisor de operación", count=2)
rep("con las rifas de demostración alcanza", "con las ruedas de demostración alcanza")
rep("tabla de rifas, que no tiene", "tabla de ruedas, que no tiene")
rep('// ❌ antes: <a href="/raffles">Rifas</a>', '// ❌ antes: <a href="/wheels">Ruedas</a>')
rep('<Link to="/raffles">Rifas</Link>', '<Link to="/wheels">Ruedas</Link>')
rep('<NavLink to="/raffles" activeClassName="active">Rifas</NavLink>', '<NavLink to="/wheels" activeClassName="active">Ruedas</NavLink>')
rep('<a href="/raffles">', '<a href="/wheels">', count=2)
rep('<Link to="/raffles">', '<Link to="/wheels">', count=1)
bloque("// src/components/Navbar.test.jsx", "\n```",
       "// src/components/Navbar.test.jsx (la misma prueba que corre en el repo de prueba)\n"
       + leer("inc03.test.jsx").replace("../components/Navbar", "./Navbar") + "\n```")

# ---------- 04
rep("## Incidente 04 — Entro al detalle de otra rifa y sigo viendo la anterior",
    "## Incidente 04 — Entro al detalle de otra rueda y sigo viendo la anterior")
bloque("Tengo la lista de rifas.", "parecidos.",
       "Tengo la lista de ruedas. Abro la Esclusa de Oro, la miro, vuelvo atrás y abro la Semana del Canal… y me sigue mostrando la Esclusa de Oro. Arriba, en la barra del navegador, dice que estoy en la 2, pero abajo el nombre y los datos son los de la 1. Si aprieto F5 ahí sí aparece la correcta. Yo creo que se confunde por los nombres parecidos.")
rep("**Reportado por:** vendedor de rifas\n**Ambiente:** UAT", "**Reportado por:** operadora de soporte\n**Ambiente:** UAT")
rep("descartar la teoría del vendedor.", "descartar la teoría de los nombres parecidos.")
bloque("- **Datos:** hacen falta al menos dos rifas", "La rama ya las trae.",
       "- **Datos:** ya están en `mock/wheels.js`: `Esclusa de Oro` con `id: 1` y `Semana del Canal` con `id: 2`. Nombres bien distintos, para que el síntoma sea inconfundible.")
rep("# Navega: /raffles → detalle de la 1 → atrás → detalle de la 2", "# Navega: /wheels → detalle de la 1 → atrás → detalle de la 2")
rep("selecciona `RaffleDetailPage` y déjala", "selecciona `WheelDetailPage` y déjala")
rep("navegas de una rifa a la otra", "navegas de una rueda a la otra")
rep("al cambiar de rifa, o ni se entera?", "al cambiar de rueda, o ni se entera?")
rep("params.id = ...   ·   state.raffle = ...", "params.id = ...   ·   state.wheel = ...")
rep("`src/pages/RaffleDetailPage.jsx` guarda la rifa en estado local", "`src/pages/WheelDetailPage.jsx` guarda la rueda en estado local")
rep("const [raffle, setRaffle] = useState(findRaffle(id));", "const [wheel, setWheel] = useState(findWheel(id));")
rep("Al navegar de `/raffles/1` a `/raffles/2`", "Al navegar de `/wheels/1` a `/wheels/2`")
rep("rifa 1, para siempre.", "rueda 1, para siempre.")
rep("setRaffle(findRaffle(id));", "setWheel(findWheel(id));")
rep("La rifa no es información", "La rueda no es información")
rep("const raffle = findRaffle(id);   // sin useState", "const wheel = findWheel(id);   // sin useState")
rep("cámbiale el nombre a una de las dos rifas", "cámbiale el nombre a una de las dos ruedas")
bloque("// src/pages/RaffleDetailPage.test.jsx", "\n```",
       "// src/pages/WheelDetailPage.test.jsx (la misma prueba que corre en el repo de prueba)\n"
       + leer("inc04.test.jsx").replace("../pages/WheelDetailPage", "./WheelDetailPage") + "\n```")

# ---------- 05
rep("## Incidente 05 — Las peticiones salen sin token y el servidor las rebota",
    "## Incidente 05 — Después de entrar, mis peticiones salen sin token")
bloque("Entro con mi usuario y mi contraseña", "pasa lo mismo.",
       "Entro con mi usuario y mi contraseña y me deja pasar sin problema: veo el menú y arriba a la derecha aparece mi nombre. Pero las peticiones que la consola manda después de entrar no llevan nada que identifique mi sesión: en la herramienta de red no aparece ningún `Authorization`. Probé cerrando y volviendo a entrar y pasa lo mismo.")
rep("**Reportado por:** vendedor de rifas\n**Ambiente:** desarrollo", "**Reportado por:** operadora de soporte\n**Ambiente:** desarrollo")
rep("- **Caos:** `off`. Este bug es determinista y con caos encendido se confunde con\n  el incidente 08: apágalo antes de empezar.\n- **Datos:** el `db.json` de la fase, con al menos un usuario válido.",
    "- **Caos:** no aplica en esta fase: el mock todavía no tiene caos (llega en Fase 3).\n- **Datos:** `mock/db.json`, con los usuarios de la fase.\n- **Qué no se ve todavía:** el mock no rechaza peticiones; ningún recurso está protegido aún. El síntoma se ve en el header y en el store, y el `401` llega en Fase 4, cuando haya recursos protegidos.")
rep("CHAOS_LEVEL=off npm run mock\nnpm start", "npm run mock:api\nnpm start", count=2)
rep("de cualquier petición a una rifa.", "de cualquier petición a una rueda.")
rep("acá la petición sale, llega y la rechazan con un\n`401` bien formado.", "acá la petición sale sin header. En esta fase el mock todavía no rechaza nada; el `401` llega en Fase 4, cuando hay recursos protegidos.")

# ---------- 06
rep("en el kiosco compartido", "en una consola compartida")
rep("- **Caos:** `off`.\n", "- **Caos:** no aplica en esta fase.\n")
n_app = len(re.findall(r"src/App\.jsx", s[INI:FIN]))
rep("src/App.jsx", "src/AppRouter.jsx", count=n_app)

CUADERNO.write_text(s, encoding="utf-8")
print("cuaderno 01–06 actualizado; rifas restantes en la zona:",
      len(re.findall(r"rifa|raffle|kiosco|CHAOS_LEVEL|App\.jsx", s[INI:FIN], re.I)))
