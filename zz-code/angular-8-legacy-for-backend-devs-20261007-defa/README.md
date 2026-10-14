# 🧪 angular-8-legacy-for-backend-devs-20261007-defa · cómo correr estas pruebas

> **Curso:** angular-8-legacy-for-backend-devs · **Tanda:** T1–T5 del plan de edición (giro a Ottawa) · **Estado:** archivado
> · **Creado:** 2026-10-07
> **Propósito:** probar, ejecutando, lo que el giro de LabCore a Ottawa–Gatineau cambia en el curso: la
> tabla de fechas, el `DatePipe` con zona IANA y el pipe `appDate`, el selector de rangos y el incidente
> 07, la imagen de la Fase 13 y el incidente 19 (T1); Java 8 y `mongo:4.0` de `bea-08`, `bea-06`,
> `bea-12` y `be04` (T3).
> Las reglas, en `zz-code/README.md` § "El README de cada directorio".

## 1. 🎯 Qué se prueba y para qué

| Prueba | Archivo | Documento del curso | Qué decide |
|---|---|---|---|
| `DatePipe` con IANA | `sondas/angular8/datepipe-iana.js` | Fase 02 §5.10, A07 §6 | Angular 8 ignora `'America/Toronto'` en silencio → nace `appDate` |
| Tabla de fechas | `fechas/inventario.py`, `fechas/tabla.js` | todo el curso (D7) | Equivalencias viejo → nuevo, día de la semana, desfase real |
| Formatos de A07 | `sondas/angular8/a07-formatos.js` | A07 §6, incidente 04 | Salida real de `formatDate` en `es`/`fr`/`en` |
| Fecha de nacimiento | `sondas/angular8/fase05-fechas.js` | Fase 05 §5.10 y §6 | El "día antes" es de la carga al oeste de UTC → `toLocalDate()` |
| Selector de rangos | `sondas/angular8/fase08-selector.js` | Fase 08 §5.3, incidente 07 | Con `-05:00` en los dos lados elige bien: el 07 viejo no se reproducía |
| Incidente 07 nuevo | `sondas/angular8/incidente07.js` | cuaderno 07, prep 07, forense 08 | Borde de la v2 en UTC: desde las 19:00 del 31 elige la v2 |
| PDF | `sondas/angular8/fase09-pdf.js` | Fase 09 §5.1 | `toLocaleString` con IANA respeta Ottawa en invierno y verano |
| Verificación de T1 | `sondas/angular8/t1-verificar.js` | Fases 02, 04, 05, 08; prep y cuaderno 07; forense 08 | 15 comprobaciones y el spec de regresión del 07 con Jasmine |
| Imagen y entrypoint | `esqueleto/armar.sh`, `incidente19.sh` | Fase 13 §5.2–5.8, incidente 19, Fase 13 ej. 13 | `ng build --prod` real, `config.json`, log, valor por defecto y render en Chrome |
| Cierre de T1 | `fechas/cierre-t1.py` | camino base | Ninguna marca de tiempo fuera de la tabla |
| `json-server` | comando en §4 (T1) | Fase 04 | El `db.json` de la fase carga en `json-server` 0.16.3 |
| Moneda | `sondas/angular8/t2-moneda.js` | A07 §6 | `currency:'CAD':'symbol-narrow':'1.2-2'` en `es`, `en`, `fr` |
| Fase 12 y regex | `extraer/t2-entradas.sh`, `sondas/angular8/t2-verificar.sh` | Fases 05 y 12 | 9 specs de reducer y selectores con Jasmine en Node; la regex `HC/PP/LB` |
| Zonas en Java 8 | `sondas/java8/Zonas.java` | `bea-08` §5 y §8 | Reglas de Toronto 2006–2022, hueco y solape, la constante de julio, el `java.util.Date` |
| `LocalDate` de Spring Data | `sondas/java8/springdata/` | `bea-08` §5 | Escrito en UTC y leído en Ottawa sale un día antes; al revés no |
| Fragmentos de `bea-08` | `extraer/t3-java-bea08.py` → `sondas/java8/bea08/Bea08.java` | `bea-08` §5 y §8 | Los cinco bloques compilan en Java 8 y dan lo que dicen sus comentarios |
| `mongo:4.0` | `sondas/mongo/t3-mongo.js`, `sondas/mongo/generar-pacientes.js` | `bea-06`, `bea-08` §3, `bea-12` | El `pattern` acepta HC/PP/LB y rechaza CC; los 4.820 generados cumplen; agregación por día con `timezone` |
| Semillero en invierno | `sondas/seed/comparar.js` | Fase 05 §5.1 | Antes y después: mismos pacientes y órdenes salvo fechas; 40/40 EST |
| Incidente 22 | `extraer/t4-entradas.sh`, `sondas/angular8/inc22/verificar.js` | cuaderno 22, prep 22 | Detector y spec (3/3), datos, línea de custodia con `appDate` |
| Índice del cuaderno | `fechas/indice.py` | cuaderno | Índice = encabezados; escala y semanas |
| `curl` del 07 y del 22 | `sondas/curl/correr.sh` | soluciones del 07 y del 22 | Los `PATCH`, la consulta y el chequeo de bordes, contra `json-server` |
| Verificadores | `verificar-curso.py`, `verificar-secciones.py` | todo el curso | Enlaces, anclas, vallas, `zz-code`, escenario, incidente ↔ fase; referencias "Fase N §X" |
| Corrida final | `corrida-final.sh` | T1–T4 | Todo de cero y comparado con `salidas/` |

## 2. 🛠️ Prerrequisitos

- Docker (probado con 29.8.0, arm64). Imágenes: `node:14.21.3` (el `.nvmrc` de `a03`),
  `node:14.21.3-bullseye-slim` y `nginx:stable-alpine` (las del `Dockerfile` de la Fase 13),
  `zenika/alpine-chrome:124` (Chrome headless para renderizar la página de sonda).
- Python 3 en el host (solo biblioteca estándar) para extraer bloques y aplicar ediciones.
- `CURSO` apuntando al directorio del curso:
  `export CURSO=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-legacy/angular-8-legacy-for-backend-devs`.
- Dependencias de las sondas (`sondas/angular8/package.json`): `@angular/common` y `@angular/core`
  8.2.14, `typescript` 3.5.3, `jasmine` 3.4.0, `json-server` 0.16.3. Se instalan en contenedor.

## 3. 🧭 Reglas antes de correr

```bash
mkdir -p salidas
docker ps -aq --no-trunc > salidas/contenedores-antes.txt
docker images -q | sort -u > salidas/imagenes-antes.txt
docker volume ls -q > salidas/volumenes-antes.txt
```

Todo lo que se crea lleva `--label curso=angular8`. El único puerto publicado es `127.0.0.1:18080`
(el contenedor `lab-frontend-prod` del incidente 19); los `docker run` del cuaderno dicen `-p 8080:80`
y `incidente19.sh` los cambia a ese puerto y les agrega la etiqueta y la red, sin tocar nada más. No
hay cambios temporales en la máquina.

## 4. ▶️ Cómo se corre

Desde este directorio, en este orden:

```bash
bash comandos-t1.sh install       # npm install de sondas/angular8 en node:14.21.3
bash comandos-t1.sh datepipe      # DatePipe/formatDate con IANA, con TZ UTC, Asia/Tokyo y America/Toronto
bash comandos-t1.sh fechas        # inventario + tabla en tres zonas del host; deben salir idénticas
bash extraer/t1-entradas.sh       # extrae del markdown los bloques que prueban las sondas
for tz in America/Toronto Asia/Tokyo; do
  docker run --rm --label curso=angular8 -e TZ=$tz -v "$PWD/sondas/angular8:/w" -v "$PWD/fechas:/fechas:ro" \
    -w /w node:14.21.3 node t1-verificar.js
done
for s in a07-formatos fase05-fechas fase08-selector incidente07 fase09-pdf; do
  for tz in America/Toronto UTC Asia/Tokyo; do
    docker run --rm --label curso=angular8 -e TZ=$tz -v "$PWD/sondas/angular8:/w" -w /w node:14.21.3 node $s.js
  done
done
python3 fechas/cierre-t1.py       # 0 fuera de tabla
# json-server de la Fase 04 con su db.json
docker run --rm --label curso=angular8 -v "$PWD/sondas/angular8:/w" -w /w node:14.21.3 sh t1-json-server.sh
```

T2 (Fases 05 y 12, A07, Fase 09):

```bash
bash extraer/t2-entradas.sh       # store de la Fase 05, specs de la Fase 12, regex; agrega la respuesta del ejercicio 1 de la Fase 05
docker run --rm --label curso=angular8 -v "$PWD/sondas/angular8:/w" -w /w node:14.21.3 sh t2-verificar.sh
docker run --rm --label curso=angular8 -v "$PWD/sondas/angular8:/w" -w /w node:14.21.3 node t2-moneda.js
```

T3 (track BE). La caché de Maven va en un volumen **etiquetado**: créalo antes con
`docker volume create --label curso=angular8 angular8-m2` (en la primera corrida se creó sin etiqueta y
se borró).

```bash
(cd sondas/java8 && for tz in UTC America/Toronto; do docker run --rm --label curso=angular8 -e TZ=$tz \
   -v "$PWD:/w" -w /w eclipse-temurin:8-jdk sh -c 'javac -d /tmp Zonas.java && java -cp /tmp Zonas'; done)
(cd sondas/java8/springdata && docker run --rm --label curso=angular8 -v "$PWD:/w" -v angular8-m2:/root/.m2 -w /w \
   maven:3.8.6-eclipse-temurin-8 sh -c 'mvn -q -B dependency:copy-dependencies -DoutputDirectory=lib && mvn -q -B compile &&
   for p in "UTC America/Toronto" "America/Toronto UTC" "America/Toronto America/Toronto" "Asia/Tokyo UTC"; do
     java -cp target/classes:lib/* LocalDateProbe $p; done')
python3 extraer/t3-java-bea08.py > sondas/java8/bea08/Bea08.java
(cd sondas/java8/bea08 && for tz in UTC America/Toronto; do docker run --rm --label curso=angular8 -e TZ=$tz \
   -v "$PWD:/w" -w /w eclipse-temurin:8-jdk sh -c 'javac -d /tmp Bea08.java && java -cp /tmp Bea08'; done)
python3 extraer/bloque.py bea-12-datos-de-prueba-y-volumen.md "var SHAPES = [" > sondas/mongo/generar.js
python3 extraer/bloque.py bea-06-jsonschema-sobre-datos-sucios.md "collMod: 'patients'" > sondas/mongo/bea06-collmod.js
python3 extraer/bloque.py bea-08-tiempo-zonas-y-fechas-en-mongo.md "timezone: 'America/Toronto'" > sondas/mongo/bea08-agg.js
docker run --rm --label curso=angular8 -v "$PWD/sondas:/s" -w /s/mongo node:14.21.3 node generar-pacientes.js
docker run -d --label curso=angular8 --name angular8-mongo40 -v "$PWD/sondas/mongo:/s:ro" mongo:4.0
docker exec angular8-mongo40 mongoimport --quiet --db t3gen --collection patients --jsonArray --file /s/patients.json
docker exec angular8-mongo40 mongo --quiet /s/t3-mongo.js
docker rm -f -v angular8-mongo40   # -v: sin él quedan los dos volúmenes anónimos de /data
```

El esqueleto de Angular 8 (una sola vez; `clinical-lab` es el nombre de la Fase 0 §5.2):

```bash
cd esqueleto
docker run --rm --label curso=angular8 -v "$PWD:/w" -w /w node:14.21.3 sh -c '
  npm install --no-audit --no-fund --loglevel=error --prefix /tmp/cli @angular/cli@8.3.29 >/dev/null &&
  NG_CLI_ANALYTICS=false /tmp/cli/node_modules/.bin/ng new clinical-lab --minimal=true --skip-tests=true \
    --style=css --routing=false --skip-git=true --skip-install=true --interactive=false &&
  cd clinical-lab && npm install --no-audit --no-fund --loglevel=error &&
  npm install --no-audit --no-fund --loglevel=error --save-exact @angular/material@8.2.3 @angular/cdk@8.2.3 @ngx-translate/core@11.0.1'
cd ..
bash esqueleto/armar.sh           # copia los bloques del curso: pipe, environment, SharedModule, Fase 13
(cd esqueleto/clinical-lab && docker build --label curso=angular8 -t lab-frontend:t1 .)
bash incidente19.sh               # los docker run del cuaderno, config.json, logs, inspect y render
```

`esqueleto/sonda/` trae lo único que no sale del curso: un `AppModule` mínimo (el `SharedModule` y el
`AppConfigService` del curso, el `APP_INITIALIZER` de la Fase 13 y `LOCALE_ID` `'es'`) y un componente
que pinta cuatro instantes con `appDate` (zona de `environment` y zona del `config.json`) y con `date` e
IANA, para compararlos.

`ediciones/` guarda los scripts con los que se editó el curso (`rep.py` es el ayudante; cada
`t1-*.py` se corre con `CURSO=… python3 ediciones/<script>.py` y falla si el texto de origen no está
exactamente una vez). Las primeras ediciones de T1 (Fases 02, 04, 05, 08, A07, forense 08 y `prompts/`
de P3) se hicieron con scripts en línea que quedaron solo en la transcripción.

T4 y T5:

```bash
bash extraer/t4-entradas.sh            # detector, spec y datos del 22 desde el curso
for tz in America/Toronto Asia/Tokyo; do docker run --rm --label curso=angular8 -e TZ=$tz \
  -v "$PWD/sondas/angular8:/w" -w /w node:14.21.3 node inc22/verificar.js; done
python3 extraer/bloque.py 05-pacientes.md "var SEEDABLE_ORDER_STATUSES" > sondas/seed/seed-despues.js
(cd sondas/seed && cp ../angular8/extraidos/fase04-db.json db.json && docker run --rm --label curso=angular8 \
  -e TZ=Asia/Tokyo -v "$PWD:/w" -w /w node:14.21.3 node comparar.js)
python3 fechas/indice.py
docker run --rm --label curso=angular8 -v "$PWD/sondas/curl:/w" -v "$PWD/sondas/angular8:/a8:ro" node:14.21.3 sh /w/correr.sh
python3 verificar-curso.py && python3 verificar-secciones.py
bash corrida-final.sh                  # todo T1–T4 de cero, salidas en salidas/final/ y comparación
```

`sondas/seed/seed-antes.js` es el semillero tal como estaba antes del cambio (extraído antes de editar).
La tabla de fechas se construye **una vez** desde el curso original: `git archive HEAD
cursos-legacy/angular-8-legacy-for-backend-devs | tar -x -C salidas/head-original` y
`CURSO=salidas/head-original/… bash comandos-t1.sh fechas`. Correrla sobre el curso editado la vacía.

## 5. 📏 Cómo se mide

No hay mediciones de rendimiento. Cada prueba es determinista y se corre con el reloj del contenedor
en dos o tres zonas (`America/Toronto`, `UTC`, `Asia/Tokyo`) para que ningún resultado dependa del host.
Node 14.21.3 trae ICU 70.1 con datos de zonas 2022f.

## 6. 🧮 Los intermedios que amasan la salida

`fechas/inventario.py` → `fechas/inventario.json` (100 literales) → `fechas/tabla.js` →
`fechas/tabla.json` y `fechas/tabla.md` (70 apariciones de 2019, 31 equivalencias). `fechas/aplicar.py`
reemplazó los literales exactos de la tabla en el curso. El resto de las pruebas imprime directo.

## 7. ✅ Qué se espera ver

Corrida del 2026-10-07, guardada en `salidas/`:

- `t1-datepipe-iana.txt`: `formatDate(…, 'America/Toronto')` sale en la zona del contenedor
  (`2022-01-01 00:30 Z` con TZ=UTC); `'-0500'` y `'EST'` sí funcionan.
- `t1-fechas-*.txt`: cambios de hora de Toronto 2019–2022 (10/03/2019 … 06/11/2022), 0 problemas, misma
  tabla en las tres zonas.
- `t1-fase05-fechas.txt`: en Toronto, editar sin tocar la fecha guarda `1984-03-11`; en Tokio,
  `toISOString` guardaría `1984-03-11`.
- `t1-fase08-selector.txt`: el selector, con el código del curso, elige `v1` en todos los casos con
  `-05:00`.
- `t1-incidente07.txt`: dato roto → `v2` y amarillo desde las 19:00 del 31; dato arreglado → `v1` y rojo.
- `t1-verificar.txt`: `15/15 PASS` y `Jasmine incidente 07: verde`, en Toronto y en Tokio.
- `t1-incidente19.txt`: `config.json` con `uat` y `America/Toronto`; primera línea de log
  `[entrypoint] config generada para ambiente: uat -> http://uat.interno:3000`; con el fix, `prod`; sin
  `APP_TIME_ZONE`, `America/Toronto`; con el navegador en Tokio, `appDate` muestra `3 ene. 2022 8:15:00`
  y `date` con IANA `3 ene. 2022 22:15:00`; con `APP_TIME_ZONE=America/Vancouver`, la 01:30 de Ottawa
  sale `3/1/22 22:30`.
- `t1-cierre.txt`: `base track: 0 fuera de tabla`.
- `t1-json-server.txt`: 3 pacientes `HC-1032456789 HC-1098765432 PP-1122334455`, la v2 desde
  `2022-01-01T00:00:00-05:00`, la orden pendiente del `2022-01-03T08:15:00-05:00`.
- `t2-verificar.txt`: `9 specs, 0 failures` y `regex Fase 05 … 11/11 PASS`.
- `t2-moneda.txt`: `1.234,50 $` (es, con U+00A0), `$1,234.50` (en), `1 234,50 $` (fr, con U+00A0).
- `t2-fase09-pdf.txt`: `3/1/2022, 23:40:00` en invierno y `30/6/2021, 23:40:00` en verano, en UTC y en Tokio.
- `t3-java-zonas.txt`: tzdb 2026b; 2006 abril/octubre, 2007 en adelante marzo/noviembre; `02:30 → 03:30-04:00`;
  `01:30-04:00` y `01:30-05:00`; `'2021-07-15T09:00:00-05:00'` es `10:00 -04:00`; `1757516645123L` era 2025.
- `t3-java-localdate.txt`: escrito en UTC y leído en Toronto → `1984-03-11`; las otras tres combinaciones → `1984-03-12`
  salvo Tokio→UTC (`1984-03-11`).
- `t3-java-bea08.txt`: `Thu Sep 10 15:04:05 UTC 2026` / `Thu Sep 10 11:04:05 EDT 2026`, y las tres líneas de §8.
- `t3-bea12.txt`: `4820` pacientes, 0 fuera de la regex.
- `t4-seed-invierno.txt`: `pacientes iguales: true`, `ordenes iguales salvo fechas: true`, `{ EST: 40 }`;
  antes, 26 de 40 en meses de verano.
- `t4-incidente22.txt`: la 7202 sale `15/3/21 10:00` / `15/3/21 9:38`, detector `true`, invertida; 3 specs verdes.
- `t4-indice.txt`: 22 incidentes, 0 diferencias, `🟢 2 · 🟡 8 · 🟠 10 · 🔴 2`, semanas `7 / 8 / 4 / 3`.
- `t5-verificar.txt`: `83 documentos · 0 errores` (los seis enlaces de A13 al curso de Docker, como aviso, existen).
- `t5-secciones.txt`: `0 referencias rotas` sobre 568.
- `t5-curl-07-22.txt`: bordes en `Z` 2 → 0 tras los `PATCH`; la consulta del 22 y su nota.
- `final/`: la corrida final; 19/19 iguales a las de arriba, más `t1-build.txt` (`ng build --prod: ok`).
- `t3-mongo.txt`: `mongod 4.0.28`; acepta `HC-…, PP-…, LB-…`, rechaza `CC-…, hc-…, HC1…`; `4820 … 4820 cumplen`;
  con `America/Toronto` el 00:30 del 16/7 queda el 16 y con `-05:00` cae el 15.

## 8. 📂 Salidas

Todo en `salidas/`, regenerable corriendo §4. Al curso no se copió nada de aquí: los cambios están en
el markdown y salen de `ediciones/` y de `fechas/aplicar.py`.

## 9. 🧹 Limpieza

```bash
docker rm -f -v $(docker ps -aq --filter label=curso=angular8) 2>/dev/null
docker network rm angular8-t1
docker rmi lab-frontend:t1 lab-frontend:inc19
docker volume rm angular8-m2
# Hecho el 2026-10-07 al cerrar T5: contenedores, red, imágenes lab-frontend, los volúmenes anónimos del
# mongo y las cinco imágenes base que bajó la sesión (eclipse-temurin:8-jdk, mongo:4.0,
# maven:3.8.6-eclipse-temurin-8, node:14.21.3, zenika/alpine-chrome:124), cada una tras comprobar que
# ningún contenedor la usaba. Queda la caché de build de Docker: no se hace prune.
# El contenedor condor-lab-series-1 (ruta-no-sql-lite) es de otra sesión: no se toca.
```

## 10. 🚫 Qué se dejó fuera

`sondas/angular8/node_modules` y `esqueleto/clinical-lab/node_modules` (se regeneran con §4);
`sondas/angular8/specs-generados/` (lo escribe `t1-verificar.js`); `sondas/angular8/fase12/out/` (tsc);
`sondas/java8/springdata/lib` y `target` (Maven); `sondas/mongo/patients.json` (lo escribe `generar-pacientes.js`);
`sondas/seed/run-*` y `sondas/angular8/inc22/out` (generados); `salidas/head-original` (se rehace con `git archive`).
