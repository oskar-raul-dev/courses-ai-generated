# 🗓️ Programa del curso

> **Curso:** Ruta SQL — La base que nadie diseñó
> **Última actualización:** 18/10/2026, con las 27 fases, el track y los apéndices escritos y ejecutados
> en macOS arm64
> **Qué es:** el temario entero en una página: qué fase va dónde, cuánto cuesta, qué está publicado y en
> qué orden conviene seguirlo. Qué es el curso y para quién está en el [README](README.md).

---

## 🧭 Cómo se sigue

**Una fase por sesión de trabajo, y en orden.** Los bloques no son independientes: el Bloque II mide
sobre el modelo del I, el III concurre sobre las tablas del II, y el VI argumenta citando todo lo
anterior. Se pueden saltar el IV y el V; no se puede empezar por el III.

Cada fase tiene la misma forma: el dolor de Alameda en la caja, el mecanismo, el contraste en otro
motor, la 🪞 apuesta escrita antes de medir, el 💥 punto de rotura con su mensaje literal, la ⚰️ autopsia
con números de antes y después, la 📖 traducción, el ⚖️ veredicto honesto de cuándo **no** usar lo que
enseña, y sus ejercicios con solucionario. Cierra con su checklist y su tag `fase-NN-<slug>`
([convención de git](00-convencion-de-git-y-tags.md)).

Lo que mide va a la [bitácora](bitacora-de-medicion.md), lo que falla con mensaje literal al
[catálogo de errores](a08-catalogo-de-errores.md), y cada instinto que se rompe a
[`INSTINTOS.md`](INSTINTOS.md).

**Tres rutas**, con sus horas y lo que dejan, en el [README](README.md#-por-dónde-empezar-tres-rutas):
la mínima (Bloques 0 y I, 60 h), la de rendimiento (hasta el Bloque III, 160 h) y la completa con el
track (292 h).

---

## 📋 Las fases

✅ escrita, ejecutada y verificada en macOS arm64 con Docker Desktop (Linux y Windows 11 con WSL2, escritos
y sin ejecutar: ver [`a01`](a01-laboratorio-contenerizado.md))

| # | Fase | Bloque | Horas | Ejercicios | Estado |
|---|---|---|---|---|---|
| 00 | [La base que nadie diseñó](00-la-base-que-nadie-diseno.md) | 0 | 4 | 12 | ✅ |
| 01 | [La caja y el arnés](01-la-caja-y-el-arnes.md) | 0 | 5 | 22 | ✅ |
| 02 | [Las cinco preguntas, desde el otro lado](02-las-cinco-preguntas-desde-el-otro-lado.md) | 0 | 3 | 12 | ✅ |
| 03 | [Lo que SQL le hace al modelo relacional](03-lo-que-sql-le-hace-al-modelo.md) | I | 8 | 22 | ✅ |
| 04 | [Un valor, un hecho](04-un-valor-un-hecho.md) | I | 8 | 24 | ✅ |
| 05 | [Una persona no es su documento](05-una-persona-no-es-su-documento.md) | I | 8 | 24 | ✅ |
| 06 | [Cuarta y quinta forma normal](06-cuarta-y-quinta-forma-normal.md) | I | 8 | 20 | ✅ |
| 07 | [El tiempo en el modelo](07-el-tiempo-en-el-modelo.md) | I | 8 | 24 | ✅ |
| 08 | [Los dos extremos del mismo error](08-los-dos-extremos-del-mismo-error.md) | I | 8 | 26 | ✅ |
| 09 | [El tamaño de las cosas](09-el-tamano-de-las-cosas.md) | II | 10 | 24 | ✅ |
| 10 | [Identificadores](10-identificadores.md) | II | 10 | 26 | ✅ |
| 11 | [Índices y lo que cuestan](11-indices-y-lo-que-cuestan.md) | II | 10 | 28 | ✅ |
| 12 | [Estadísticas y cardinalidad](12-estadisticas-y-cardinalidad.md) | II | 10 | 24 | ✅ |
| 13 | [El optimizador en tres motores](13-el-optimizador-en-tres-motores.md) | II | 10 | 24 | ✅ |
| 14 | [La base no estaba lenta](14-la-base-no-estaba-lenta.md) | II | 10 | 26 | ✅ |
| 15 | [Aislamiento comparado](15-aislamiento-comparado.md) | III | 10 | 26 | ✅ |
| 16 | [El folio sin huecos](16-el-folio-sin-huecos.md) | III | 10 | 26 | ✅ |
| 17 | [MVCC y su factura](17-mvcc-y-su-factura.md) | III | 10 | 24 | ✅ |
| 18 | [Bloqueos, deadlocks y DDL](18-bloqueos-deadlocks-y-ddl.md) | III | 10 | 26 | ✅ |
| 19 | [JSON en los motores](19-json-en-los-motores.md) | IV | 10 | 24 | ✅ |
| 20 | [La propuesta de Florencia, medida](20-la-propuesta-de-florencia.md) | IV | 10 | 26 | ✅ |
| 21 | [Hasta dónde llega el motor](21-hasta-donde-llega-el-motor.md) | IV | 10 | 24 | ✅ |
| 22 | [La exportación de las 9:40](22-la-exportacion-de-las-9-40.md) | V | 15 | 28 | ✅ |
| 23 | [La base como producto](23-la-base-como-producto.md) | V | 15 | 26 | ✅ |
| 24 | [El diseño](24-el-diseno.md) | VI | 12 | 22 | ✅ |
| 25 | [La migración sin parar](25-la-migracion-sin-parar.md) | VI | 10 | 24 | ✅ |
| 26 | [El comité](26-el-comite.md) | VI | 10 | 20 | ✅ |
| | **Total** | | **252 h** | **634** | **27 de 27** |

---

## 🪟 El track de SQL Server

Opcional y fuera de las 252 h. Requisito: el camino base hasta la Fase 18; `ss01` se puede hacer después
de la Fase 04. En Apple Silicon corre emulado y exige Docker Desktop. **Todo resultado de SQL Server va
como apuesta sin resolver**, con el comando para resolverla ([`a09`](a09-licencias-publicacion-y-riesgo.md)).

| # | Fase | Horas | Ejercicios | Estado |
|---|---|---|---|---|
| ss01 | [La base en su motor original](ss01-la-base-en-su-motor-original.md) | 8 | 20 | ✅ |
| ss02 | [Pesimista contra RCSI](ss02-pesimista-contra-rcsi.md) | 8 | 22 | ✅ |
| ss03 | [Query Store y *parameter sniffing*](ss03-query-store-y-parameter-sniffing.md) | 8 | 22 | ✅ |
| ss04 | [Clustered, `NEWSEQUENTIALID` y tablas temporales](ss04-clustered-newsequentialid-y-temporales.md) | 8 | 20 | ✅ |
| ss05 | [Data API builder y el tipo `json`](ss05-data-api-builder-y-json.md) | 8 | 20 | ✅ |
| ssa-01 | [Qué cambia en Windows](ssa-01-que-cambia-en-windows.md), apéndice del track | 1 | 6 | ✅ |
| | **Total** | **40 h**, más la hora de `ssa-01` | **110** | **6 de 6** |

---

## 📎 Los apéndices

Van fuera de las horas del curso, y se consultan cuando una fase los pide. `a01`, `a02`, `a05` y `a06` se
leen antes de la Fase 01.

| # | Apéndice | Horas | Ejercicios | Estado |
|---|---|---|---|---|
| a01 | [Laboratorio contenerizado en tres plataformas](a01-laboratorio-contenerizado.md) | 3 | 8 | ✅ macOS arm64; Linux y Windows 11, escritos y sin ejecutar |
| a02 | [El `compose.yaml` de la ruta](a02-compose-de-la-ruta.md) | 2 | 6 | ✅ |
| a03 | [CLIs de los motores](a03-clis-de-los-motores.md) | 2 | 8 | ✅ |
| a04 | [El arnés de forma](a04-el-arnes-de-forma.md) | 3 | 8 | ✅ con SQL Server en el track |
| a05 | [La caja y el generador](a05-la-caja-y-el-generador.md) | 3 | 6 | ✅ |
| a06 | [Python, Java y los drivers](a06-python-java-y-drivers.md) | 2 | 6 | ✅ |
| a07 | [Diccionario de traducción y glosario](a07-diccionario-y-glosario.md) | 2 | 6 | ✅ |
| a08 | [Catálogo de errores](a08-catalogo-de-errores.md) | 3 | 10 | ✅ 102 entradas; el curso se proponía 50 |
| a09 | [Licencias, publicación y riesgo](a09-licencias-publicacion-y-riesgo.md) | 1 | 5 | ✅ |
| a10 | [El Access de museo](a10-el-access-de-museo.md) (opcional) | 2 | 6 | ✅ |
| | **Total** | **23 h** | **69** | **10 de 10** |

---

## 💀 Los boss

Todos opcionales y fuera de las 252 h. Cada uno empieza con un sistema roto en `src/` y se acepta con
criterios que un arnés o un script comprueban. **Ninguna solución se publica**: el criterio de aceptación
es el entregable.

| Bloque | 💀 Boss | Lo pide | El sistema roto | Estado |
|---|---|---|---|---|
| I | [La señora que es tres pacientes](08-los-dos-extremos-del-mismo-error.md#-boss-del-bloque-i--la-señora-que-es-tres-pacientes) | Norma Castellani | [`src/08-…/boss/`](src/08-los-dos-extremos-del-mismo-error/boss/README.md) | ✅ |
| II | [El portal de 2018](14-la-base-no-estaba-lenta.md#-boss-del-bloque-ii--el-portal-de-2018) | Verónica Colombo | [`src/14-…/boss/`](src/14-la-base-no-estaba-lenta/boss/README.md) | ✅ |
| III | [Una tarde de julio](18-bloqueos-deadlocks-y-ddl.md#-boss-del-bloque-iii--una-tarde-de-julio) | Matías Ledesma | [`src/18-…/boss/`](src/18-bloqueos-deadlocks-y-ddl/boss/README.md) | ✅ |
| IV | [El informe en la app](21-hasta-donde-llega-el-motor.md#-16-boss-del-bloque-iv--el-informe-en-la-app) | Florencia Marchetti | [`src/21-…/boss/`](src/21-hasta-donde-llega-el-motor/boss/README.md) | ✅ |
| V | [Las 9:40](23-la-base-como-producto.md#-16-boss-del-bloque-v--las-940) | Verónica Colombo | [`src/23-…/boss/`](src/23-la-base-como-producto/boss/README.md) | ✅ |
| V ☕ | [El puente](23-la-base-como-producto.md#-16b-boss-del-puente--el-puente), en Java 25 con Apache Artemis | Matías Ledesma | [`src/23-…/puente/`](src/23-la-base-como-producto/puente/README.md) | ✅ |

🏆 **"Un martes"**, el boss global, cierra una nota al final de cada bloque y termina en la
[Fase 26](26-el-comite.md#55-un-martes-el-boss-global): la facturación de un martes corre entera sobre la
base nueva, con legacy viva al lado. Su arnés está en [`src/26-…/martes/`](src/26-el-comite/martes/README.md).

---

## 🚦 El orden en que se escribió

El de las fases es el mejor para aprender, y también fue el de escritura: cada tanda se escribió, se
ejecutó y se verificó entera antes de la siguiente.

1. **Los apéndices del laboratorio y el Bloque 0** (`a01`, `a02`, `a05`, `a06`, `a09`, F00–F02). ✅ 12/10/2026
2. **Bloques I, II y III** (F03–F18), con los boss I, II y III. ✅ 12 al 14/10/2026
3. **Bloques IV y V** (F19–F23), con los boss IV, V y del puente. ✅ 14/10/2026
4. **Bloque VI** (F24–F26) y el 🏆 "Un martes". ✅ 15/10/2026
5. **El track de SQL Server** (ss01–ss05 y ssa-01). ✅ 18/10/2026
6. **El Access de museo** (`a10`) y el cierre de los apéndices que crecen con el curso (`a03`, `a04`,
   `a07` y `a08`). ✅ 18/10/2026
