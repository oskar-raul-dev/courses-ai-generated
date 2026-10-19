"""`uv run lab race`: el intercalado determinista de sesiones (D14, D43).

Cada sesión es una conexión con su propio hilo. El coordinador manda un paso por vez, en el orden de
la permutación, y no manda el siguiente hasta que cada sesión ocupada terminó su paso **o está
esperando un bloqueo según el catálogo del motor** (`pg_blocking_pids()` en Postgres;
`data_lock_waits` y `metadata_locks` en MySQL; `sys.dm_exec_requests` en SQL Server, que necesita el extra
`sqlserver`). Así la misma permutación da siempre la misma salida: no
hay `sleep` ni "correr muchas veces hasta que salga".

El archivo `.race`:

    -- @engine postgres                  postgres, mysql o sqlserver (--engine lo cambia)
    -- @database ss02                    solo sqlserver: la base a la que se conecta cada sesión (ALAMEDA)
    -- @isolation repeatable read        el valor de {isolation} (--isolation lo cambia)
    -- @setup DROP TABLE IF EXISTS …     una sentencia por línea, antes de cada permutación
    -- @check SELECT …                   al final de cada permutación: dice si hubo anomalía
    -- @teardown …                       después de cada permutación
    a1: BEGIN ISOLATION LEVEL {isolation};
    b1: …                                la letra es la sesión; el paso sigue hasta la próxima etiqueta
    -- @permutation a1 b1 a2 b2 …        una o varias; sin ninguna, el orden del archivo

Desde Python, el mismo motor acepta pasos que son funciones (`step("a3", lambda conn: …)`), que
corren en el hilo de la sesión con su conexión: así una caja llama al web service fiscal de F16 en
medio de su transacción.
"""

from __future__ import annotations

import queue
import re
import threading
import time
from dataclasses import dataclass, field
from typing import Callable

from . import config

ISOLATION = {"read-uncommitted": "READ UNCOMMITTED", "read-committed": "READ COMMITTED",
             "repeatable-read": "REPEATABLE READ", "serializable": "SERIALIZABLE",
             "snapshot": "SNAPSHOT"}                 # SNAPSHOT existe solo en SQL Server
LABEL = re.compile(r"^([a-z])(\d+)\s*:\s?(.*)$")
POLL = 0.005


class RaceError(Exception):
    pass


@dataclass
class Outcome:
    label: str
    session: str
    text: str = ""                 # "1 fila (0)", "UPDATE 1", "COMMIT"…
    error: str | None = None       # código del motor: 40001, 40P01, 1213, 1205…
    message: str = ""
    blocked: bool = False          # quedó esperando un bloqueo al mandarlo
    rows: list = field(default_factory=list)
    value: object = None           # lo que devolvió un paso que es una función


def connect(engine: str, database: str | None = None, **kw):
    if engine == "sqlserver":
        from .engines import sqlserver
        return sqlserver.connect(database or "ALAMEDA", autocommit=True)
    if engine == "postgres":
        import psycopg
        return psycopg.connect(**config.POSTGRES, autocommit=True, **kw)
    if engine == "mysql":
        import pymysql
        return pymysql.connect(**config.MYSQL, autocommit=True, **kw)
    raise RaceError(f"lab race trabaja con postgres, mysql y sqlserver, no con {engine}")


def _execute(engine: str, conn, sql: str) -> Outcome:
    out = Outcome("", "")
    if engine == "postgres":
        import psycopg
        try:
            with conn.cursor() as cur:
                cur.execute(sql)
                tag = cur.statusmessage or ""
                if cur.description is not None:
                    out.rows = cur.fetchall()
                    out.text = _rows_text(out.rows)
                else:
                    out.text = re.sub(r"^INSERT 0 ", "INSERT ", tag)
        except psycopg.Error as exc:
            out.error = exc.sqlstate or "?"
            out.message = str(exc).splitlines()[0]
        return out
    if engine == "sqlserver":
        return _execute_sqlserver(conn, sql)
    import pymysql
    try:
        with conn.cursor() as cur:
            affected = cur.execute(sql)
            if cur.description is not None:
                out.rows = list(cur.fetchall())
                out.text = _rows_text(out.rows)
            else:
                verb = sql.split(None, 1)[0].upper() if sql.strip() else ""
                out.text = f"{verb} {affected}" if verb in ("INSERT", "UPDATE", "DELETE", "REPLACE") else verb
    except pymysql.err.MySQLError as exc:
        out.error = str(exc.args[0]) if exc.args else "?"
        out.message = str(exc.args[1]) if len(exc.args) > 1 else str(exc)
    return out


# El driver de SQL Server no da el número de error nativo: se pide con @@ERROR en la misma conexión,
# que todavía lo tiene porque es la sentencia siguiente.
def _execute_sqlserver(conn, sql: str) -> Outcome:
    out = Outcome("", "")
    cur = conn.cursor()
    try:
        cur.execute(sql)
        rows = None
        while True:                      # un lote puede devolver varios resultados: vale el último con filas
            if cur.description is not None:
                rows = [tuple(r) for r in cur.fetchall()]
            if not cur.nextset():
                break
        if rows is not None:
            out.rows, out.text = rows, _rows_text(rows)
        else:
            verb = sql.split(None, 1)[0].upper() if sql.strip() else ""
            out.text = f"{verb} {cur.rowcount}" if verb in ("INSERT", "UPDATE", "DELETE", "MERGE") else verb
    except Exception as exc:
        text = str(exc)
        out.message = text.split("[SQL Server]", 1)[-1].strip() if "[SQL Server]" in text else text.splitlines()[0]
        try:
            c2 = conn.cursor()
            c2.execute("SELECT @@ERROR")
            out.error = str(c2.fetchone()[0])
        except Exception:
            out.error = "?"
    return out


def _rows_text(rows: list) -> str:
    n = len(rows)
    head = f"{n} fila" if n == 1 else f"{n} filas"
    if 0 < n <= 3:
        shown = ", ".join("(" + ", ".join("NULL" if v is None else str(v) for v in r) + ")" for r in rows)
        return f"{head}  {shown}"
    return head


class Session:
    """Una conexión y su hilo. `send` encola un paso; `done` dice si ya terminó."""

    def __init__(self, engine: str, name: str, database: str | None = None):
        self.engine, self.name = engine, name
        self.conn = connect(engine, database)
        if engine == "postgres":
            self.backend = self.conn.info.backend_pid
        elif engine == "sqlserver":
            cur = self.conn.cursor()
            cur.execute("SELECT @@SPID")
            self.backend = int(cur.fetchone()[0])
        else:
            self.backend = self.conn.thread_id()
        self.inbox: queue.Queue = queue.Queue()
        self.current: tuple[str, threading.Event, list] | None = None
        self.thread = threading.Thread(target=self._loop, daemon=True)
        self.thread.start()

    def _loop(self) -> None:
        while True:
            item = self.inbox.get()
            if item is None:
                return
            label, action, event, box = item
            if callable(action):
                out = Outcome(label, self.name)
                try:
                    out.value = action(self.conn)
                    out.text = "" if out.value is None else str(out.value)
                except Exception as exc:          # el error de un paso es parte del resultado
                    code = getattr(exc, "sqlstate", None) or (exc.args[0] if exc.args else None)
                    out.error = str(code) if code is not None else type(exc).__name__
                    out.message = str(exc).splitlines()[0] if str(exc) else type(exc).__name__
            else:
                out = _execute(self.engine, self.conn, action)
            out.label, out.session = label, self.name
            box.append(out)
            event.set()

    def send(self, label: str, action) -> None:
        if self.busy:
            raise RaceError(f"la sesión {self.name} todavía está en {self.current[0]}")
        event, box = threading.Event(), []
        self.current = (label, event, box)
        self.inbox.put((label, action, event, box))

    @property
    def busy(self) -> bool:
        return self.current is not None

    def finished(self) -> Outcome | None:
        """Si el paso en curso terminó, lo devuelve y deja la sesión libre."""
        if self.current and self.current[1].is_set():
            out = self.current[2][0]
            self.current = None
            return out
        return None

    def close(self) -> None:
        try:
            if self.engine == "postgres":
                self.conn.execute("ROLLBACK")
            elif self.engine == "sqlserver":
                self.conn.cursor().execute("IF @@TRANCOUNT > 0 ROLLBACK")
            else:
                self.conn.rollback()
        except Exception:
            pass
        self.inbox.put(None)
        try:
            self.conn.close()
        except Exception:
            pass


class Monitor:
    """La conexión que mira el catálogo: ¿esta sesión está esperando un bloqueo?"""

    def __init__(self, engine: str, database: str | None = None):
        self.engine = engine
        self.conn = connect(engine, database)

    def waiting(self, backend: int) -> bool:
        if self.engine == "postgres":
            row = self.conn.execute("SELECT cardinality(pg_blocking_pids(%s)) > 0", (backend,)).fetchone()
            return bool(row[0])
        if self.engine == "sqlserver":
            cur = self.conn.cursor()
            cur.execute("SELECT COUNT(*) FROM sys.dm_exec_requests WHERE session_id = ? AND blocking_session_id <> 0",
                        (backend,))
            return bool(cur.fetchone()[0])
        with self.conn.cursor() as cur:
            # data_lock_waits y no information_schema.innodb_trx: consultada cada 5 ms, innodb_trx no
            # mostró nunca una espera que empezó mientras se la leía (a04).
            cur.execute("SELECT count(*) FROM performance_schema.data_lock_waits w "
                        "JOIN performance_schema.threads t ON t.THREAD_ID = w.REQUESTING_THREAD_ID "
                        "WHERE t.PROCESSLIST_ID = %s", (backend,))
            if cur.fetchone()[0]:
                return True
            cur.execute("SELECT count(*) FROM performance_schema.metadata_locks m "
                        "JOIN performance_schema.threads t ON t.THREAD_ID = m.OWNER_THREAD_ID "
                        "WHERE t.PROCESSLIST_ID = %s AND m.LOCK_STATUS = 'PENDING'", (backend,))
            return bool(cur.fetchone()[0])

    def cancel(self, backend: int) -> None:
        if self.engine == "postgres":
            self.conn.execute("SELECT pg_cancel_backend(%s)", (backend,))
        elif self.engine == "sqlserver":
            # SQL Server no cancela la sentencia de otra sesión: KILL termina la sesión y deshace su transacción.
            self.conn.cursor().execute(f"KILL {int(backend)}")
        else:
            with self.conn.cursor() as cur:
                cur.execute(f"KILL QUERY {int(backend)}")

    def run(self, sql: str) -> None:
        out = _execute(self.engine, self.conn, sql)
        if out.error:
            raise RaceError(f"{sql[:60]}… → {out.error} {out.message}")

    def close(self) -> None:
        self.conn.close()


@dataclass
class Race:
    engine: str = "postgres"
    database: str | None = None
    setup: list[str] = field(default_factory=list)
    teardown: list[str] = field(default_factory=list)
    checks: list[str] = field(default_factory=list)
    checked: list[str] = field(default_factory=list)    # lo que dijo cada @check en la última corrida
    steps: dict[str, tuple[str, object]] = field(default_factory=dict)   # etiqueta → (sesión, sql o función)
    permutations: list[list[str]] = field(default_factory=list)
    isolation: str | None = None
    timeout: float = 30.0
    patience: float = 3.0         # cuánto se espera a una sesión bloqueada antes de declarar imposible el orden

    def step(self, label: str, action: str | Callable) -> "Race":
        m = re.match(r"^([a-z])\d+$", label)
        if not m:
            raise RaceError(f"etiqueta inválida: {label} (una letra y un número: a1, b2…)")
        self.steps[label] = (m.group(1), action)
        return self

    @classmethod
    def from_file(cls, path: str) -> "Race":
        race, current = cls(), None
        for raw in open(path, encoding="utf-8").read().splitlines():
            line = raw.rstrip()
            directive = re.match(r"^--\s*@(\w+)\s*(.*)$", line)
            if directive:
                key, value = directive.group(1), directive.group(2).strip()
                current = None
                if key == "engine":
                    race.engine = value
                elif key == "database":
                    race.database = value
                elif key == "isolation":
                    race.isolation = value.upper()
                elif key == "setup":
                    race.setup.append(value)
                elif key == "teardown":
                    race.teardown.append(value)
                elif key == "check":
                    race.checks.append(value)
                elif key == "permutation":
                    race.permutations.append(value.split())
                else:
                    raise RaceError(f"directiva desconocida: @{key}")
                continue
            m = LABEL.match(line)
            if m:
                current = m.group(1) + m.group(2)
                race.steps[current] = (m.group(1), m.group(3))
            elif current and line.strip() and not line.lstrip().startswith("--"):
                session, sql = race.steps[current]
                race.steps[current] = (session, sql + "\n" + line)
        return race

    def _resolve(self, action):
        if callable(action):
            return action
        sql = action.strip().rstrip(";").strip()
        if "{isolation}" in sql:
            if not self.isolation:
                raise RaceError("el archivo usa {isolation}: pásalo con --isolation o con -- @isolation")
            sql = sql.replace("{isolation}", self.isolation)
        return sql

    def run(self, permutation: list[str] | None = None, echo: bool = True, show_sql: bool = False) -> list[Outcome]:
        order = permutation or (self.permutations[0] if self.permutations else list(self.steps))
        missing = [x for x in order if x not in self.steps]
        if missing:
            raise RaceError(f"pasos que el archivo no tiene: {' '.join(missing)}")
        monitor = Monitor(self.engine, self.database)
        for sql in self.setup:
            monitor.run(self._resolve(sql))
        names = sorted({self.steps[x][0] for x in order})
        sessions = {n: Session(self.engine, n, self.database) for n in names}
        results: list[Outcome] = []
        blocked: set[str] = set()
        suspect: set[str] = set()

        def report(out: Outcome, late: bool) -> None:
            results.append(out)
            if not echo:
                return
            prefix = "   ↳ " if late else " "
            text = f"✗ {out.error} {out.message}" if out.error else out.text
            print(f"{prefix}{out.label:<4}{text}")

        def settle(first: str | None = None) -> None:
            """Espera a que cada sesión ocupada termine o esté bloqueada según el catálogo.

            `first` es la sesión del paso recién mandado: se la mira antes que a las demás, para que su
            resultado salga antes que el de los pasos que ese mismo paso destrabó."""
            deadline = time.monotonic() + self.timeout
            while True:
                pending = False
                for n in ([first] if first else []) + [x for x in names if x != first]:
                    s = sessions[n]
                    out = s.finished()
                    if out is not None:
                        out.blocked = n in blocked
                        report(out, late=out.blocked)
                        blocked.discard(n)
                        suspect.discard(n)
                    elif s.busy and n not in blocked:
                        # La espera tiene que verse en dos consultas seguidas del catálogo: con una
                        # sola, una vez en nueve corridas, una sesión que no esperaba nada pasó por
                        # bloqueada.
                        if not monitor.waiting(s.backend):
                            suspect.discard(n)
                            pending = True
                        elif n in suspect:
                            blocked.add(n)
                            suspect.discard(n)
                            if echo:
                                print(f" {s.current[0]:<4}⏳ espera un bloqueo")
                        else:
                            suspect.add(n)
                            pending = True
                    if n == first:
                        if s.busy and n not in blocked:
                            break               # el paso recién mandado sigue: las demás esperan su turno
                        first = None            # terminó o espera: desde ahora, todas por igual
                        pending = True
                if not pending:
                    return
                if time.monotonic() > deadline:
                    raise RaceError("un paso tardó más que --timeout sin estar bloqueado")
                time.sleep(POLL)

        try:
            if echo:
                print(f"🏁 lab race · {self.engine} · permutación {' '.join(order)}"
                      + (f" · {self.isolation.lower()}" if self.isolation else ""))
            aborted = False
            for label in order:
                name, action = self.steps[label]
                s = sessions[name]
                started = time.monotonic()
                while s.busy:                       # el paso le toca a una sesión ocupada
                    settle()
                    if not s.busy:
                        break
                    waited = time.monotonic() - started
                    if name in blocked and waited > self.patience:
                        # Espera a una sesión que no avanza hasta que le toque: el motor no deja
                        # que este orden ocurra. Se cancela lo bloqueado y la permutación termina.
                        impossible = Outcome(label, name, error="imposible",
                                             message=f"{label} le toca a {name}, que espera un bloqueo "
                                                     f"desde {s.current[0]}: el motor no deja ocurrir este orden")
                        report(impossible, late=False)
                        aborted = True
                        for n in names:
                            if sessions[n].busy:
                                monitor.cancel(sessions[n].backend)
                        settle()
                        break
                    if waited > self.timeout:
                        raise RaceError(f"{label}: la sesión {name} sigue ocupada en {s.current[0]}")
                    time.sleep(POLL)
                if aborted:
                    break
                if show_sql and echo and not callable(action):
                    print("      " + self._resolve(action).replace("\n", "\n      "))
                s.send(label, self._resolve(action))
                settle(first=name)
            started = time.monotonic()
            while any(sessions[n].busy for n in names):
                settle()
                busy = [n for n in names if sessions[n].busy]
                if busy and all(n in blocked for n in busy) and time.monotonic() - started > self.patience:
                    # Se acabaron los pasos y alguien sigue esperando: se cancela y queda dicho.
                    for n in busy:
                        report(Outcome(sessions[n].current[0], n, error="sin-pasos",
                                       message="quedó esperando un bloqueo al terminar la permutación"), late=False)
                        monitor.cancel(sessions[n].backend)
                    settle()
                    break
                if time.monotonic() - started > self.timeout:
                    raise RaceError("al final quedaron sesiones ocupadas: " + ", ".join(busy))
                time.sleep(POLL)
        finally:
            for s in sessions.values():
                s.close()
            self.checked = []
            for sql in self.checks:
                out = _execute(self.engine, monitor.conn, self._resolve(sql))
                self.checked.append(f"✗ {out.error} {out.message}" if out.error else out.text)
            try:
                for sql in self.teardown:
                    monitor.run(self._resolve(sql))
            finally:
                monitor.close()
        if echo:
            print("resultado: " + summary(results, names))
            for text in self.checked:
                print("comprobación: " + text)
        return results


def summary(results: list[Outcome], names: list[str]) -> str:
    parts = []
    for n in names:
        errors = [r for r in results if r.session == n and r.error]
        parts.append(f"{n} sin errores" if not errors else
                     f"{n} con error " + ", ".join(f"{r.error} en {r.label}" for r in errors))
    return " · ".join(parts)


def main(a) -> int:
    try:
        race = Race.from_file(a.file)
    except (OSError, RaceError) as exc:
        print(f"✗ {exc}")
        return 1
    if a.engine:
        race.engine = a.engine
    if a.isolation:
        race.isolation = ISOLATION[a.isolation]
    race.timeout = a.timeout
    race.patience = a.patience
    perms = [a.permutation.split()] if a.permutation else (race.permutations or [None])
    for i, perm in enumerate(perms):
        if i:
            print()
        try:
            race.run(perm, show_sql=a.sql)
        except RaceError as exc:
            print(f"✗ {exc}")
            return 1
    return 0
