# ✅ Soluciones — Apéndice a06: Python, Java y los drivers

> **Curso:** Ruta SQL · Solucionario del [Apéndice a06](../a06-python-java-y-drivers.md)
> **Ejercicios:** 6 · **Perfil:** M · **Motores:** los tres del camino base, de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso); Python 3.13.13 con uv 0.11.14, y
> Java 25.0.4.1
> **Fecha de verificación ejecutada:** 12/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

---

## 🟢 Fácil (1–2)

### Ejercicio 1

**Enunciado (resumen):** imprimir Python y los tres drivers con `importlib.metadata`, compararlos con
el `uv.lock`, y explicar `pymysql.__version__`.

**Solución.** Con `uv run python versiones.py` desde `src/`:

```python
import importlib.metadata as m
import platform

import pymysql

print("Python", platform.python_version())
for package in ("psycopg", "psycopg-binary", "pymysql", "oracledb"):
    print(f"{package} {m.version(package)}")
print("pymysql.__version__ =", pymysql.__version__)
```

```text
Python 3.13.13
psycopg 3.3.6
psycopg-binary 3.3.6
pymysql 1.2.3
oracledb 26.0.1
pymysql.__version__ = 2.2.8
```

Las cuatro versiones de paquete coinciden con las del `uv.lock` (`grep -A1 '^name = "pymysql"'
uv.lock` da `version = "1.2.3"`). `pymysql.__version__` no es la versión de PyMySQL: es la de
`mysqlclient` con la que dice ser compatible, para el código viejo que importaba `MySQLdb`. La propia,
en `pymysql.VERSION`, es `(1, 2, 3, 'final')`. Tu Python puede ser otro 3.13: el proyecto acepta
cualquiera de la serie.

[← Volver al ejercicio](../a06-python-java-y-drivers.md#-ejercicio-1--las-versiones-que-corre-tu-entorno)

### Ejercicio 2

**Enunciado (resumen):** un `SELECT` sin `commit` en psycopg, mirado desde otra conexión en
`pg_stat_activity`.

**Solución.** Es el script de la sección [La transacción que nadie
cerró](../a06-python-java-y-drivers.md#-la-transacción-que-nadie-cerró):

```text
estado de la conexión: INTRANS
pg_stat_activity: ('idle in transaction', True)
```

`INTRANS` lo informa el driver: hay una transacción abierta y ninguna sentencia corriendo. `idle in
transaction` es lo mismo visto desde el motor, y el `True` dice que `xact_start` ya tiene fecha. El
`application_name` es lo que permite encontrar *tu* conexión entre las demás; sin él, la fila existe
igual, pero no sabes de quién es.

[← Volver al ejercicio](../a06-python-java-y-drivers.md#-ejercicio-2--un-select-que-abre-una-transacción)

## 🟡 Intermedio (3–4)

### Ejercicio 3

**Enunciado (resumen):** cambiar el `CREATE TABLE` del script por un `ALTER TABLE` que agregue
`active boolean`, predecir y comparar.

**Solución.** El primer intento, con la sintaxis de Postgres en los tres, falla en Oracle:

```text
oracledb.exceptions.DatabaseError: ORA-03050: invalid identifier: "COLUMN" is a reserved word
Help: https://docs.oracle.com/error-help/db/ora-03050/
```

Oracle escribe `ALTER TABLE payer ADD active boolean`, sin `COLUMN`. Con esa sentencia en Oracle y
`ADD COLUMN` en los otros dos:

```python
    cur.execute("ALTER TABLE payer ADD active boolean" if engine == "oracle"      # Oracle no acepta COLUMN
                else "ALTER TABLE payer ADD COLUMN active boolean")
```

```text
postgres: autocommit=False; sin commit, otra sesión ve 0 fila(s)
postgres: tras ALTER TABLE y rollback, payer tiene 0 fila(s)
postgres: al salir de `with connect()` sin commit, payer tiene 1 fila(s)
mysql: autocommit=False; sin commit, otra sesión ve 0 fila(s)
mysql: tras ALTER TABLE y rollback, payer tiene 1 fila(s)
mysql: al salir de `with connect()` sin commit, payer tiene 0 fila(s)
oracle: autocommit=False; sin commit, otra sesión ve 0 fila(s)
oracle: tras ALTER TABLE y rollback, payer tiene 1 fila(s)
oracle: al salir de `with connect()` sin commit, payer tiene 0 fila(s)
```

El mismo resultado que con `CREATE TABLE`: el `INSERT` sobrevive al `rollback` en MySQL y en Oracle,
porque cualquier DDL confirma antes lo pendiente. **La migración de cinco pasos que falla en el
tercero** queda, en Postgres, sin ningún paso aplicado si corrió dentro de una transacción; en MySQL y
en Oracle, con los dos primeros aplicados y confirmados, y hay que escribir a mano el camino de vuelta.

[← Volver al ejercicio](../a06-python-java-y-drivers.md#-ejercicio-3--el-ddl-que-confirma)

### Ejercicio 4

**Enunciado (resumen):** que el `INSERT` dentro de `with connect()` quede confirmado en los tres
motores, sin ramas por motor.

**Solución.** Un `commit()` explícito antes de salir del bloque:

```python
    with connect(engine) as conn:
        conn.cursor().execute(INSERT)
        conn.commit()
```

```text
postgres: al salir de `with connect()` con commit, payer tiene 1 fila(s)
mysql: al salir de `with connect()` con commit, payer tiene 1 fila(s)
oracle: al salir de `with connect()` con commit, payer tiene 1 fila(s)
```

(Son las tres líneas de `with` de la salida; las otras seis no cambian.) En psycopg el `commit` es
redundante, porque su `with` ya confirma, pero no hace daño, y el código queda correcto en los tres.

[← Volver al ejercicio](../a06-python-java-y-drivers.md#-ejercicio-4--with-en-tres-drivers)

## 🟠 Difícil (5–6)

### Ejercicio 5

**Enunciado (resumen):** leer `Pacientes.csv` de M con UTF-8, con `errors="ignore"` y con Latin-1, y
contar las filas con `Ñ`.

**Solución de referencia.**

```python
import sys

path = sys.argv[1]
try:
    with open(path, encoding="utf-8", newline="") as fh:
        rows = fh.readlines()
except UnicodeDecodeError as exc:
    print("utf-8:", exc)
with open(path, encoding="utf-8", errors="ignore", newline="") as fh:
    rows = fh.readlines()
print("utf-8 con errors='ignore':", sum("Ñ" in r for r in rows), "con Ñ ·", sum("MUOZ" in r for r in rows), "con MUOZ")
with open(path, encoding="latin-1", newline="") as fh:
    rows = fh.readlines()
print("latin-1:", sum("Ñ" in r for r in rows), "con Ñ ·", sum("MUÑOZ" in r for r in rows), "con MUÑOZ")
```

```text
utf-8: 'utf-8' codec can't decode byte 0xf1 in position 764: invalid continuation byte
utf-8 con errors='ignore': 0 con Ñ · 4335 con MUOZ
latin-1: 32675 con Ñ · 4335 con MUÑOZ
```

**Por qué `errors="ignore"` es peor que el error:** el error te detiene en el primer byte y te dice
cuál es. `ignore` sigue sin avisar y borra cada `Ñ`: las 4.335 filas con `MUÑOZ` quedan como `MUOZ`, un
apellido que no existe, y cualquier deduplicación por nombre trabaja desde ahí sobre datos que tu
propio código rompió. (Son 32.675 filas con `Ñ` y no las 21.559 de `Nombre` porque el conteo mira la
línea entera: también hay eñes en `Direccion`.)

**Rúbrica.** Una respuesta correcta tiene que:
- copiar el error literal de la primera lectura;
- mostrar que con `ignore` desaparecen las `Ñ` y explicar qué le hace eso a los datos;
- leer con `encoding="latin-1"` como solución, no con un `replace` posterior.

Y queda invalidada si:
- propone `errors="ignore"` o `errors="replace"` como arreglo.

[← Volver al ejercicio](../a06-python-java-y-drivers.md#-ejercicio-5--la-eñe-que-desaparece)

### Ejercicio 6

**Enunciado (resumen):** ejecutar `ContarEnPostgres.java`, agregar un `UPDATE` seguido de una
excepción, y decir qué pasó y qué línea lo cambia.

**Solución de referencia.** `ContarEnPostgres.java` da, con M:

```text
autocommit por defecto: true
filas con Ñ en legacy."Pacientes": 21559
```

Para el `UPDATE`, un archivo con una tabla de prueba en el esquema `alameda` y un argumento para elegir
el modo:

```java
// Un UPDATE y una excepción antes de la segunda escritura: ¿quedó el UPDATE? Con `manual`, sin autocommit.
import java.sql.DriverManager;

void main(String[] args) throws Exception {
    boolean manual = args.length > 0 && args[0].equals("manual");
    var url = "jdbc:postgresql://postgres:5432/alameda";
    try (var conn = DriverManager.getConnection(url, "postgres", "lab"); var st = conn.createStatement()) {
        st.execute("CREATE TABLE IF NOT EXISTS alameda.payer_check (payer_code varchar(10) PRIMARY KEY, name varchar(100))");
        st.execute("DELETE FROM alameda.payer_check");
        st.execute("INSERT INTO alameda.payer_check VALUES ('PAMI', 'PAMI')");
        if (manual) {
            conn.setAutoCommit(false);
        }
        try {
            st.executeUpdate("UPDATE alameda.payer_check SET name = 'INSTITUTO NACIONAL' WHERE payer_code = 'PAMI'");
            throw new IllegalStateException("se cayó antes de la segunda escritura");
        } catch (IllegalStateException e) {
            if (manual) {
                conn.rollback();
            }
            IO.println("autocommit=" + conn.getAutoCommit() + " · excepción: " + e.getMessage());
        }
        try (var rs = st.executeQuery("SELECT name FROM alameda.payer_check")) {
            rs.next();
            IO.println("name = " + rs.getString(1));
        }
    }
}
```

```text
$ java -cp lib/postgresql-42.7.14.jar UpdateYExcepcion.java
autocommit=true · excepción: se cayó antes de la segunda escritura
name = INSTITUTO NACIONAL
$ java -cp lib/postgresql-42.7.14.jar UpdateYExcepcion.java manual
autocommit=false · excepción: se cayó antes de la segunda escritura
name = PAMI
```

Con el *autocommit* de JDBC, el `UPDATE` quedó confirmado en cuanto se ejecutó, y la excepción llegó
tarde. La línea que lo cambia es `conn.setAutoCommit(false)` antes de la primera escritura, con su
`rollback()` en el `catch`: así se comporta como los drivers de Python.

**Rúbrica.** Una respuesta correcta tiene que:
- mostrar que `getAutoCommit()` devuelve `true` por defecto;
- reproducir el `UPDATE` que sobrevive a la excepción, y el que no sobrevive con *autocommit* apagado;
- nombrar el `rollback` en el manejo del error, no solo el `setAutoCommit`.

Y queda invalidada si:
- apaga el *autocommit* y nunca llama a `commit()`: el caso feliz tampoco queda guardado.

[← Volver al ejercicio](../a06-python-java-y-drivers.md#-ejercicio-6--jdbc-y-el-autocommit)
