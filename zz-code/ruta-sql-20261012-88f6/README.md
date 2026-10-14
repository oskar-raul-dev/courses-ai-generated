# 🧪 ruta-sql-20261012-88f6 · cómo correr estas pruebas

> **Curso:** ruta-sql · **Tanda:** T0 a T4 · **Creado:** 2026-10-12
> **Propósito:** el laboratorio de la Ruta SQL (T1): generar la caja con el generador de `a05`,
> levantar y cargar los tres motores con el CLI `lab`, medir arranque, memoria y disco para `a01` y
> `a02`, y ejecutar todo lo que publican `a01`, `a02`, `a04`, `a05`, `a06` y `a08`, con sus
> solucionarios.
> Se llenó **mientras se probaba**. Las reglas, en `zz-code/README.md` § "El README de cada directorio".

## 1. 🎯 Qué se prueba y para qué

| Prueba | Script | Alimenta |
|---|---|---|
| Generar S y M con la semilla 1996, determinismo por hash | `generar.py`, `proporciones.py` | `a05`, contrato §8 (T1) |
| Levantar el laboratorio y cargar S y M en Postgres, MySQL y Oracle | `lab.sh`, `lab-en-contenedor.sh` | `a01`, `a02`, `a05` |
| Arranque en frío y RAM en reposo por servicio; RAM con M cargado y pico de carga | comandos de §4 | `a02` (tablas de *healthchecks* y de RAM) |
| Oracle con poca memoria: 512 MB a 2 GB, sola y con el laboratorio al lado | `captura-a01-ej5.sh` y comandos de §4 | `a01` (memoria), `a08` E-03 |
| El ciclo, conectarse antes de tiempo, puerto ocupado (proyecto real, puertos del curso) | `capturas-a01.sh` | `a01` y su solucionario |
| `fn_ExtraerDNI` de 2016 en SQL Server contra el port de Python | `comparar-tsql.sh` | `a05` (la copia sin `OTRO`), F04 |
| Transacciones en los tres drivers, versiones, `idle in transaction`, Latin-1 | `a06/*.py`, `a06/ej.sh`, `a06/correr-a06.sh` | `a06` y su solucionario, `a08` E-11 y E-12 |
| Java 25 de un archivo, JDBC por Maven, *autocommit* | `a06/java/*.java` | `a06`, `a08` E-13 |
| `lab measure` en los tres motores | `lab-en-contenedor.sh measure …` | `a04` |
| `max_wal_size` 4 GB contra 1 GB en la carga de M | `salidas/wal-1gb.yaml` | `src/lab/compose.yaml` (se quitó) |
| Digests y tags del día | `tags.sh`, `comandos-versiones.sh` | `a02` (sin cambios contra el 11/10) |
| T2 · Licencias de SQL Server 2025, Oracle Free, OTN, Postgres, MySQL y MongoDB, descargadas el 12/10 | `curl` y `pdftotext` sobre `salidas/fuentes/` | `a09` |
| T2 · La carga de Latin-1 como UTF-8 en los tres motores | `salidas/f01-oracle-utf8*.sql` y los comandos de `salidas/f01-rotura-*.txt` | F01 (punto de rotura), `a08` E-14 a E-16 |
| T2 · Catálogo, planes y prueba de fuego de F01; las 419 tablas contra sus CSV | `f01/contar_todo.py` y las consultas de `salidas/f01-*.txt` | F01 y su solucionario, bitácora M-01 |
| T2 · Las tres CLIs | las sesiones de `salidas/a03-*.txt` | `a03`, `a08` E-17 |
| T3 · La presentación de Rubén, `NULL`, `NOT IN` y la cadena vacía | `src/03-…/*.sql` y `f03/oracle-vacio.sql` | F03 y su solucionario, M-05, M-06 |
| T3 · Dependencias, tabla de rechazos, parsers y huérfanos | los ocho scripts de `src/04-…/` y `f04/` | F04 y su solucionario, M-07 |
| T3 · Identidad, *matcher* contra la verdad, fusión y rotura | los siete scripts de `src/05-…/` y `f05/*.sql` | F05 y su solucionario, M-08, M-09 |
| T4 · Convenios, 4FN y 5FN; precios en rangos, historia y bitemporal; los cuatro modelos del resultado | los scripts de `src/06-…` a `src/08-…` y `f06/` a `f08/` | F06 a F08 y sus solucionarios, M-10 a M-13 |
| T4 · El boss I | `src/08-…/boss/01_what_norma_sees.sql` y `boss1/solucion.sql` | F08 §16 (la solución no se publica) |
| T4 · `ub_value()` arreglada: S y M regenerados, M recargado, F01 recapturado | `generar.py`, `lab-en-contenedor.sh load --profile m --model` | contrato §8 (T4), los hashes de `a04`, `a05` y F01 |
| T3 · La numeración única: S y M regenerados, M recargado | `generar.py`, `lab-en-contenedor.sh load` | contrato §8 (T3), los hashes de `a04`, `a05` y F01 |

## 2. 🛠️ Prerrequisitos

macOS 26.7.1 en Apple M1 Pro (32 GB), Docker Desktop con motor 29.8.0 (VM de 7,75 GiB, kernel
`7.0.12-linuxkit`), Compose v5.5.1, Python 3.13.4 en el host (solo biblioteca estándar: `generar.py`,
`proporciones.py`, `lab.sh`). Imágenes: las cinco del `compose.yaml` del curso,
`ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim` (el CLI `lab` con el `uv.lock`) y
`maven:3.10.0-eclipse-temurin-25-noble` (Java 25 y Maven). **No se instaló nada en la máquina**: `uv`,
los drivers y Java corren en contenedores.

## 3. 🧭 Reglas antes de correr

`salidas/inventario-antes.txt` es el inventario del arranque de la sesión. Todo lo que se crea lleva
`curso=ruta-sql` (contenedores, volúmenes y red del `compose.yaml`, y los `docker run` de los
scripts). Las pruebas usan `compose.pruebas.yaml`, que pone puertos aleatorios en `127.0.0.1`; solo
`capturas-a01.sh` y `captura-a01-ej5.sh` usan los puertos del curso (`25432`…), porque el ejercicio
del puerto ocupado los necesita, y empiezan y terminan con `lab down -v`. Las pruebas de memoria y de
arranque en frío usan un proyecto aparte, `alameda-oom`, para no tocar el laboratorio cargado.

## 4. ▶️ Cómo se corre

Desde este directorio:

```bash
# desde T4: la caja y el modelo de las fases 04 a 08 en un comando (o ./rehacer-modelo.sh sobre una carga hecha)
./lab-en-contenedor.sh load --profile m --model
docker exec -i alameda-lab-postgres-1 psql -U postgres -d alameda < f05/medir.sql
python3 -I generar.py s 1996 salidas/caja        # y m; la caja va a salidas/caja/<perfil>
python3 -I proporciones.py salidas/caja/m         # proporciones contra la historia y D30
./lab.sh up base contraste oracle                 # up/down/ps con el override de pruebas
./lab-en-contenedor.sh load --profile m                                  # Postgres entero
./lab-en-contenedor.sh load --profile m --engine mysql --tables Pacientes,Protocolos,ResultadoItem,Practicas
./lab-en-contenedor.sh load --profile m --engine oracle --tables Pacientes,Protocolos,ResultadoItem,Practicas
./lab-en-contenedor.sh measure -c 'SELECT …'      # y --engine mysql | oracle --profile m
./lab.sh up sqlserver && ./comparar-tsql.sh        # tras crear ALAMEDA con esquema/ALAMEDA.sql y tsql/
a06/correr-a06.sh /a06/ej.sh /a06/tres_preguntas.py
./capturas-a01.sh                                  # destruye el laboratorio: lo deja en down -v
./captura-a01-ej5.sh
```

Java, desde `a06/java/`: `docker run --rm --network alameda-lab_default -v "$PWD":/w -w /w
maven:3.10.0-eclipse-temurin-25-noble sh -c 'mvn -q dependency:copy
-Dartifact=org.postgresql:postgresql:42.7.14 -DoutputDirectory=lib && java -cp
lib/postgresql-42.7.14.jar ContarEnPostgres.java'`.

Arranque en frío por servicio (proyecto `alameda-oom`): para cada perfil, `docker compose -p
alameda-oom -f src/lab/compose.yaml -f compose.pruebas.yaml --profile P up -d --wait`, `sleep 60`,
`docker stats --no-stream` y `down -v`. Lo mismo con `ORACLE_MEMORY=…` para el piso de Oracle.

## 5. 📏 Cómo se mide

Tiempos de pared con `date +%s` o `time`, una corrida (son contexto, nunca argumento). RAM con `docker
stats --no-stream`: en reposo, un minuto después de *healthy*; con M, un minuto después de un
`SELECT sum(length("Valor"))` sobre `ResultadoItem` en cada motor; el pico de carga, muestreando cada
3 s durante `lab load`. Oracle: su tiempo de carga solo con `--private` y no se publica; su RAM y su
arranque sí (excepción de dimensionamiento, guía §6.1).

## 6. 🧮 Los intermedios que amasan la salida

- **Proporciones:** `proporciones.py` lee los CSV y `truth/`; en `a05` se publican con SQL sobre
  `truth` (`salidas/consultas-a05-m.txt`), que da lo mismo.
- **Tabla de RAM:** las cuatro líneas de `salidas/ram-m-recorrido-final.txt`, sumadas a mano
  (613 MiB + 878 MiB + 1,60 GiB ≈ 3,1 GiB; con SQL Server, 3,8 GiB); el pico, el máximo de cada motor
  en `salidas/ram-carga-final.txt` (`sort -h | tail -1`).
- **Repetidos de `NroProtocolo`:** el `GROUP BY` con CTE de `salidas/consultas-a05-m.txt`; el ritmo a
  escala real, 28 filas de 2005 / 2 × 9,5 ≈ 133 al año ≈ 2,6 por semana.
- **Precisión y cobertura de la regex:** la consulta del ejercicio 5 de `a05`, con `round(…, 1)`.

## 7. ✅ Qué se espera ver

- S: SHA-256 `49cfb8db4194…`, 20.002 personas, 24.245 pacientes, 132.065 protocolos, 1.201.086
  resultados. M: `3e59292e9918…`, 200.002 · 242.427 · 1.327.622 · 12.134.453 (los de T1 y T3 quedaron atrás
  con los cuatro cambios del generador). Parser de Rubén: 88,9 %
  en S y 90,1 % en M.
- Carga de M: Postgres 46–48 s (419 tablas y `truth`), MySQL 37–38 s (cuatro tablas, sin binlog).
- `fn_ExtraerDNI` contra el port: 3.982 de 3.983 iguales; el distinto, `OTRO`.
- Drivers: los tres sin *autocommit*; DDL confirma en MySQL y Oracle; `with` confirma solo en psycopg;
  JDBC con *autocommit* encendido.
- Todo quedó registrado en los apéndices y solucionarios de T1 (12/10/2026).
- F05 (13/10/2026): 1.144.780 candidatos; regla combinada 0,6 con 85,7 % y 0,89 %; nivel automático
  19.620 pares sin falsos y 18.538 fusiones; 4.389 madres, todas correctas.

## 8. 📂 Salidas

`salidas/` (2,6 GB, ignorado; de F05 valen `f05-medidas.txt` y siguientes: `f05-niveles.txt`, `f05-dni-como-clave.txt` y `f05-medidas-modelo.txt` son de la caja anterior a la numeración única): `caja/s` y `caja/m` (regenerables con `generar.py`), `uv-cache` y
`uv-venv` (el entorno del `uv.lock`), `m2` (el repositorio de Maven), y los `.txt`/`.log` de cada
prueba, con el nombre de lo que midieron. `fuentes/` tiene el manual del WSFEv1 de donde salió el
código 10016 de `ComprobantesRechazados`. Al curso se copiaron las salidas literales que citan los
apéndices; ningún archivo de aquí se cita desde el curso.

## 9. 🧹 Limpieza

`./lab.sh down -v` (o `capturas-a01.sh`, que termina así) y, para el proyecto aparte, `docker compose
-p alameda-oom -f ../../cursos-bd/ruta-sql/src/lab/compose.yaml down -v`. Comprobación:
`docker ps -a --filter label=curso=ruta-sql`, `docker volume ls --filter label=curso=ruta-sql` y
`docker network ls --filter label=curso=ruta-sql` vacíos (lo estaban al cerrar T1). La imagen de Maven
se dejó, porque T11 la usa.

## 10. 🚫 Qué se dejó fuera

`salidas/caja/` (2,4 GB: `python3 -I generar.py s|m 1996 salidas/caja`), `salidas/uv-venv` y
`salidas/uv-cache` (se rehacen solos con `uv run --locked`), `salidas/m2` y `a06/java/lib/` (`mvn
dependency:copy`).
