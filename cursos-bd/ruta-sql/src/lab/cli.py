"""`uv run lab …`: el laboratorio de la Ruta SQL en un comando.

    uv run lab up [perfil …]            levanta los perfiles del compose (base por defecto) y espera
    uv run lab down [-v]                los baja; con -v borra también los volúmenes
    uv run lab ps                       qué está arriba
    uv run lab generate --profile s     genera la caja del perfil (s, m o l) en lab/caja/
    uv run lab load --profile s         carga la caja en Postgres: legacy entera y la verdad
    uv run lab load --profile m --model     y además el modelo de las fases 04 a 08 (Bloque II)
    uv run lab load --engine mysql --tables Pacientes,Protocolos
    uv run --extra sqlserver lab load --engine sqlserver        el track: la caja entera en su motor original
    uv run lab measure --engine postgres -c "SELECT …"     la forma de una consulta
    uv run lab race -f escenario.race --isolation serializable   sesiones intercaladas en un orden fijo
"""

import argparse
import subprocess
import sys

from . import config
from .engines import LoadError, manifest, selected, short_hash

PROFILES = ("base", "contraste", "oracle", "mongo", "sqlserver", "dab", "api", "puente")


def compose(*args: str) -> int:
    cmd = config.compose_command() + list(args)
    # Se muestra sin los `-f`: el comando que escribirías a mano desde src/lab/.
    print("→ " + env_compose() + " " + " ".join(args), flush=True)
    return subprocess.call(cmd)


def env_compose() -> str:
    return config.env("LAB_COMPOSE", "docker compose")


def cmd_up(a) -> int:
    profiles = a.profiles or ["base"]
    unknown = [p for p in profiles if p not in PROFILES]
    if unknown:
        print(f"Perfiles que el compose no tiene: {', '.join(unknown)}. Los que hay: {', '.join(PROFILES)}")
        return 2
    flags = [x for p in profiles for x in ("--profile", p)]
    return compose(*flags, "up", "-d", "--wait")


def cmd_down(a) -> int:
    flags = [x for p in PROFILES for x in ("--profile", p)]
    return compose(*flags, "down", *(["-v"] if a.volumes else []))


def cmd_ps(_a) -> int:
    flags = [x for p in PROFILES for x in ("--profile", p)]
    return compose(*flags, "ps")


def cmd_generate(a) -> int:
    from .generator import generate
    out = config.caja_dir()
    print(f"Generando el perfil {a.profile} con la semilla {a.seed} en {out}/{a.profile} …")
    m = generate(a.profile, a.seed, str(out))
    print(f"Listo en {m['seconds']} s: {m['people']} personas, {m['patients']} filas de Pacientes, "
          f"{m['protocols']} protocolos, {m['rows']['ResultadoItem']} filas de ResultadoItem.")
    print(f"SHA-256 de la caja: {m['sha256']}")
    return 0


def cmd_load(a) -> int:
    try:
        man = manifest(a.profile)
        tables = selected(a.tables.split(",") if a.tables else None)
        if a.model and (a.engine != "postgres" or a.tables):
            print("--model va con la caja entera en Postgres: sin --engine ni --tables")
            return 2
        if a.engine in ("mysql", "oracle") and not a.tables:
            print("En MySQL y Oracle la caja se carga por tablas: --tables Pacientes,Protocolos,…")
            return 2
        print(f"Cargando el perfil {a.profile} (caja {short_hash(man)}, semilla {man['seed']}) en {a.engine} …")
        if a.engine == "postgres":
            from .engines import postgres
            postgres.load(a.profile, man, tables)
            if a.model:
                from . import model
                model.build(a.profile)
        elif a.engine == "mysql":
            from .engines import mysql
            mysql.load(a.profile, man, tables)
        elif a.engine == "sqlserver":
            from .engines import sqlserver
            sqlserver.load(a.profile, man, tables, private=a.private)
        else:
            from .engines import oracle
            oracle.load(a.profile, man, tables, private=a.private)
    except LoadError as exc:
        print(f"✗ {exc}")
        return 1
    return 0


def num(x) -> str:
    """Postgres 18 da las filas reales como promedio por vuelta, con decimales: entero si lo es."""
    return str(int(x)) if float(x).is_integer() else f"{x:.1f}"


def loaded(engine: str) -> tuple[str | None, str]:
    """El perfil y la caja de la última carga, según lab.loaded; (None, …) si no hay registro."""
    try:
        if engine == "postgres":
            from .engines import postgres
            with postgres.connect() as conn:
                row = conn.execute("SELECT profile, sha256 FROM lab.loaded ORDER BY loaded_at DESC LIMIT 1").fetchone()
        elif engine == "sqlserver":
            from .engines import sqlserver
            conn = sqlserver.connect()
            cur = conn.cursor()
            cur.execute("SELECT TOP 1 profile, sha256 FROM lab.loaded ORDER BY loaded_at DESC")
            row = cur.fetchone()
            conn.close()
        else:
            from .engines import mysql
            conn = mysql.connect()
            with conn.cursor() as cur:
                cur.execute("SELECT profile, sha256 FROM lab.loaded ORDER BY loaded_at DESC LIMIT 1")
                row = cur.fetchone()
            conn.close()
    except Exception:
        row = None
    return (row[0], f"caja {row[1][:12]}") if row else (None, "caja desconocida")


def cmd_measure(a) -> int:
    query = a.command or open(a.file, encoding="utf-8").read()
    query = query.strip().rstrip(";")
    images = config.images()
    digest = images.get(a.engine, "?").rsplit("@", 1)[-1]
    image = f"{images.get(a.engine + ':tag', a.engine)}@{digest[:19]}…"
    profile, caja = a.profile, "caja desconocida"
    if profile is None and a.engine in ("postgres", "mysql", "sqlserver"):
        profile, caja = loaded(a.engine)          # lo que dejó `lab load` en lab.loaded
    elif profile is not None:
        try:
            caja = f"caja {short_hash(manifest(profile))}"
        except LoadError:
            pass
    print(f"📐 lab measure · {a.engine} · perfil {profile or '?'} · {caja} · {image}")
    if a.engine == "postgres":
        from .engines import postgres
        r = postgres.measure(query)
        print(f"filas devueltas: {num(r['rows'])} (estimadas: {r['estimated_rows']})")
        print(f"bloques: {r['shared_hit'] + r['shared_read']} (en caché {r['shared_hit']}, leídos {r['shared_read']})")
        print(f"filas examinadas en las hojas del plan: {num(r['examined'])}")
        print("plan:")
        print("\n".join("  " + line for line in r["plan"]))
        print(f"tiempo: {r['time_ms']:.1f} ms (contexto, no argumento)")
    elif a.engine == "mysql":
        from .engines import mysql
        r = mysql.measure(query)
        print("contadores Handler_read: " + " · ".join(f"{k[13:]} {v}" for k, v in r["handlers"].items()))
        print(f"filas examinadas (suma de los contadores): {r['examined']}")
        print("plan (EXPLAIN ANALYZE):")
        print("\n".join("  " + line for line in r["plan"]))
    else:
        if a.engine == "sqlserver":
            from .engines import sqlserver as engine
        else:
            from .engines import oracle as engine
        name = "SQL Server" if a.engine == "sqlserver" else "Oracle"
        try:
            r = engine.measure(query, private=a.private)
        except LoadError as exc:
            print(f"✗ {exc}")
            return 1
        if r["private"]:
            print(f"🔒 SALIDA PRIVADA: tiene estadísticas de ejecución de {name}. No la publiques.")
        else:
            print(f"🔒 solo la estructura del plan: de {name} el curso no publica números (apéndice a09)")
        print("\n".join("  " + line for line in r["plan"]))
    return 0


def cmd_race(a) -> int:
    from . import race
    return race.main(a)


def main(argv=None) -> int:
    p = argparse.ArgumentParser(prog="lab", description="El laboratorio de la Ruta SQL.")
    sub = p.add_subparsers(dest="cmd", required=True)
    s = sub.add_parser("up", help="levanta perfiles del compose y espera a que estén sanos")
    s.add_argument("profiles", nargs="*", help=f"perfiles: {', '.join(PROFILES)} (base por defecto)")
    s = sub.add_parser("down", help="baja todo el laboratorio")
    s.add_argument("-v", "--volumes", action="store_true", help="borra también los volúmenes (los datos)")
    sub.add_parser("ps", help="qué está arriba")
    s = sub.add_parser("generate", help="genera la caja de un perfil")
    s.add_argument("--profile", choices=("s", "m", "l"), default="s")
    s.add_argument("--seed", type=int, default=1996)
    s = sub.add_parser("load", help="carga la caja en un motor")
    s.add_argument("--profile", choices=("s", "m", "l"), default="s")
    s.add_argument("--engine", choices=("postgres", "mysql", "oracle", "sqlserver"), default="postgres")
    s.add_argument("--tables", help="tablas separadas por coma (obligatorio en mysql y oracle)")
    s.add_argument("--private", action="store_true", help="Oracle y SQL Server: muestra el tiempo (no lo publiques)")
    s.add_argument("--model", action="store_true",
                   help="Postgres: después de la caja, el modelo de las fases 04 a 08 (staging y alameda)")
    s = sub.add_parser("measure", help="la forma de una consulta: filas, bloques y plan")
    s.add_argument("--engine", choices=("postgres", "mysql", "oracle", "sqlserver"), default="postgres")
    s.add_argument("--profile", choices=("s", "m", "l"),
                   help="el perfil cargado; por defecto, el de lab.loaded (en Oracle, hay que decirlo)")
    g = s.add_mutually_exclusive_group(required=True)
    g.add_argument("-c", "--command", help="la consulta")
    g.add_argument("-f", "--file", help="un archivo con la consulta")
    s.add_argument("--private", action="store_true",
                   help="Oracle y SQL Server: estadísticas de ejecución (no las publiques)")
    s = sub.add_parser("race", help="intercala sesiones en un orden fijo y muestra qué pasó en cada paso")
    s.add_argument("-f", "--file", required=True, help="el escenario (.race)")
    s.add_argument("--engine", choices=("postgres", "mysql", "sqlserver"), help="cambia el @engine del archivo")
    s.add_argument("--isolation", choices=("read-uncommitted", "read-committed", "repeatable-read", "serializable",
                                           "snapshot"),
                   help="el valor de {isolation} en el archivo")
    s.add_argument("--permutation", help='un orden de pasos ("a1 b1 a2 b2"); por defecto, los @permutation del archivo')
    s.add_argument("--timeout", type=float, default=30.0, help="segundos que espera un paso (30)")
    s.add_argument("--patience", type=float, default=3.0,
                   help="segundos que espera a una sesión bloqueada antes de declarar imposible el orden (3)")
    s.add_argument("--sql", action="store_true", help="muestra la sentencia de cada paso")
    a = p.parse_args(argv)
    handlers = {"up": cmd_up, "down": cmd_down, "ps": cmd_ps, "generate": cmd_generate,
                "load": cmd_load, "measure": cmd_measure, "race": cmd_race}
    return handlers[a.cmd](a)


if __name__ == "__main__":
    sys.exit(main())
