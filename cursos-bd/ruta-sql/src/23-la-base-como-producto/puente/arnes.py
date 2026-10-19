"""💀☕ Boss del puente · el arnés: cinco criterios, y la medida de "¿hacía falta un broker?".

    uv run python 23-la-base-como-producto/puente/arnes.py [directorio]

Evalúa el directorio que se le pasa (por defecto, este): su `01_setup.sql` y su `Puente.java`. El servicio corre en
el contenedor de Java 25 del curso, en la red del laboratorio; las dependencias se bajan antes con Maven a `lib/`
(o se indica otra carpeta con PUENTE_LIB). Necesita `uv run lab up base puente`.

  P1  ningún resultado se pierde, aunque el productor caiga entre confirmar y enviar (2 %)
  P2  ningún mensaje se aplica dos veces, aunque el consumidor caiga entre aplicar y confirmar (2 %)
  P3  las correcciones quedan en su última versión, aunque la anterior llegue después
  P4  los tres mensajes veneno terminan en la tabla de descartes del SIH, con su motivo
  P5  la medida: 6.651 mensajes con cuatro consumidores, todos aplicados una vez (contra la cola de la Fase 22)
"""

import os
import pathlib
import subprocess
import sys

import psycopg

from lab import config

DIR = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else pathlib.Path(__file__).parent).resolve()
LIB = pathlib.Path(os.environ.get("PUENTE_LIB", pathlib.Path(__file__).parent / "lib")).resolve()
JAVA = "eclipse-temurin@sha256:589ff4cc3f71aab462e7048a47a0d10edf57fbccde3fceea2281e610bf5880b4"  # 25.0.4.1 (a06)
N = 1000

admin = psycopg.connect(**config.POSTGRES, autocommit=True)


def java(*args: str) -> str:
    cmd = ["docker", "run", "--rm", "--label", "curso=ruta-sql", "--network", "alameda-lab_default",
           "-e", f"LAB_PASSWORD={os.environ.get('LAB_PASSWORD', 'lab')}",
           "-v", f"{LIB}:/deps:ro", "-v", f"{DIR}:/app:ro", JAVA, "java", "--enable-native-access=ALL-UNNAMED", "-cp", "/deps/*", "/app/Puente.java", *args]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
    salida = (r.stdout + r.stderr).strip()
    lineas = r.stdout.strip().splitlines() or salida.splitlines() or ["(sin salida)"]
    for linea in lineas:
        print(f"   java {args[0]} → {linea}")
    return salida


def preparar() -> None:
    admin.execute((DIR / "01_setup.sql").read_text(encoding="utf-8"))
    java("purgar")


resultados: dict[str, bool] = {}


def criterio(cod: str, nombre: str, ok: bool, detalle: str) -> None:
    resultados[cod] = ok
    print(f"{'✅' if ok else '❌'} {cod} · {nombre}: {detalle}")


print("Escenario con fallas: productor y consumidor con 2 % de caídas, 50 correcciones desordenadas, 3 veneno")
preparar()
java("producir", str(N), "0.02")
java("consumir", "4", "0.02")

distintos = admin.execute("SELECT count(DISTINCT result_id) FROM staging.sih_resultado").fetchone()[0]
filas = admin.execute("SELECT count(*) FROM staging.sih_resultado").fetchone()[0]
corregidos_bien = admin.execute("""SELECT count(*) FROM (
    SELECT result_id FROM staging.sih_resultado WHERE result_id <= 50 GROUP BY result_id
    HAVING array_agg(version ORDER BY version) = ARRAY[2]) x""").fetchone()[0]
descartes = admin.execute("SELECT count(*) FROM staging.sih_descartes WHERE reason IS NOT NULL").fetchone()[0]

criterio("P1", "ningún resultado perdido", distintos == N, f"{distintos} de {N} resultados en el SIH")
criterio("P2", "ningún mensaje aplicado dos veces", distintos > 0 and filas == distintos, f"{filas} filas para {distintos} resultados")
criterio("P3", "las correcciones quedan en su última versión", corregidos_bien == 50, f"{corregidos_bien} de 50 con solo la versión 2")
criterio("P4", "el veneno termina en descartes", descartes == 3, f"{descartes} de 3 en la tabla de descartes")

print("\nMedida: 6.651 mensajes, sin caídas, cuatro consumidores")
preparar()
java("medir", "6651", "4")
aplicados = admin.execute("SELECT count(DISTINCT result_id), count(*) FROM staging.sih_resultado").fetchone()
criterio("P5", "6.651 mensajes aplicados una vez", aplicados == (6651, 6651), f"{aplicados[0]} distintos, {aplicados[1]} filas")

pasan = sum(resultados.values())
print(f"\n{pasan} de 5 criterios pasan.")
sys.exit(0 if pasan == 5 else 1)
