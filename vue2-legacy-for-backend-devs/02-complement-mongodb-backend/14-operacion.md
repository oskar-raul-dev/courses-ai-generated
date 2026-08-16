# 🛠️ Fase 14 — Operación: lo que un dev SQL sí extraña

## 🎯 Propósito

Hay un duelo silencioso en todo dev SQL que migra: extraña a su DBA — o
extraña *ser* su DBA. El Slow Query Log, el plan de backups con su restore
ensayado, el índice creado a las 3 am sin bloquear a nadie, el `v$session`
para cazar la query fugitiva. Esta fase te devuelve todo eso con nombres
nuevos: **el profiler**, **mongodump con `--oplog`**, **los index builds de
4.4**, **`currentOp`/`killOp`** — y cierra el proyecto con el
`docker-compose` final que empaqueta API + Mongo + sockets como una unidad
operable.

La Fase 0 te dio el menú de backups y la regla de oro (backup sin
restauración = hipótesis); aquí se convierte en **operación**: programada,
consistente, con punto en el tiempo y con simulacros.

---

## ✅ Qué queda listo al terminar

- backups programados de verdad: `mongodump --oplog` para consistencia bajo
  escrituras, política de retención, y el **simulacro de restauración**
  como rito mensual documentado;
- point-in-time recovery entendido y ensayado a escala de laboratorio
  (el oplog como tu redo log/binlog);
- índices creados en caliente con conocimiento de causa: qué cambió en 4.4
  (adiós al dilema foreground/background), qué bloquea y qué no;
- el **profiler** operando como tu Slow Query Log: umbral, lectura de
  `system.profile`, y el flujo profiler → `explain` → índice (Fase 7) cerrado;
- `mongostat`/`mongotop`/`currentOp`/`killOp`: el monitoreo de guardia y la
  ejecución de la query fugitiva;
- espacio en disco sin sustos: `db.stats`, por qué borrar no libera, y qué
  hace `compact`;
- el `docker-compose.yml` **final**: mongo (RS de 1 nodo) + API + healthchecks
  + backups, con `SETUP.md` convertido en runbook de operación completo.

## 🚫 Qué NO entra todavía

Y aquí, con más honestidad que en otras fases: buena parte de esto **no entra
nunca** en el curso, es fuera de alcance declarado — sabrás dónde empieza cada
mundo y con qué doc, pero no lo cruzamos.

- réplicas multi-nodo reales, elecciones, arbiters, sharding — el curso opera
  UN nodo como los sistemas internos que simula; sabrás dónde empieza ese
  mundo y con qué doc
- Ops Manager / Atlas / Percona Backup — se nombran en el mapa; operarlos es
  otro curso
- alerting y observabilidad con stack dedicado (Prometheus/Grafana) — dejas
  los endpoints y métricas listos; el stack es decisión de tu casa
- tuning fino de WiredTiger (cache, compresión por colección) — se señala la
  puerta, no se cruza

---

## 🧠 El oplog en 60 segundos (tu redo log, con otro collar)

En el RS que montaste en la Fase 6 vive una colección especial:
`local.oplog.rs` — el **operations log**: cada escritura, registrada como
operación idempotente, en orden. Es el mecanismo de replicación… y tu
puente a dos superpoderes operativos:

1. **Backup consistente bajo tráfico:** `mongodump --oplog` guarda los datos
   Y las operaciones ocurridas *durante* el dump; `mongorestore
   --oplogReplay` deja la base exactamente como estaba al **final** del
   backup — sin detener escrituras. Tu backup en caliente de toda la vida.
2. **Point-in-time:** datos del último dump + rebanada del oplog hasta el
   segundo T = la base como estaba en T. El "restaurar a las 14:59, justo
   antes del `DELETE` sin WHERE" de tu vida anterior — mismo concepto,
   mismas lágrimas evitadas.

```js
// Míralo con tus ojos (mongosh):
use local
db.oplog.rs.find().sort({ $natural: -1 }).limit(3)   // tus últimas escrituras
db.oplog.rs.stats().maxSize                           // es capped: se recicla
```

> ⚠️ La consecuencia del reciclaje: tu **ventana de point-in-time** es lo que
> el oplog retiene. Si el oplog da para 24 h de escrituras y tu último dump
> es de hace 30 h, hay 6 h irrecuperables. Dimensionar oplog + frecuencia de
> dumps ES la política de backup (ejercicio 23).

> ### 🪞 Tu instinto dice… "borro los documentos viejos y recupero el disco"
>
> **Predicción falsable:** "tras borrar el 50% de una colección, `du` sobre
> el `dbPath` mostrará ~50% menos".
>
> Mídelo (ejercicio 26). No baja casi nada: WiredTiger marca el espacio como
> **reutilizable** para esa colección, pero no lo devuelve al sistema
> operativo. Tu instinto conoce este patrón — es el high-water mark de los
> datafiles de Oracle, el `VACUUM` sin `FULL` de Postgres. La devolución
> real exige `compact` (bloquea, y en 4.4 tiene su letra chica) o un
> resync/restore. **Veredicto: el instinto se equivoca igual que se
> equivocaba en SQL — y la solución también rima.** 📓 A `INSTINTOS.md`.

### 🩻 Esto SÍ funciona igual

Toda tu liturgia operativa: backups que se ensayan, ventanas de
mantenimiento, el respeto reverencial al disco lleno, "primero mide, después
toca", el runbook escrito ANTES del incidente, y la regla de que en
producción no se ejecuta nada que no se haya ejecutado antes en staging. La
fase entera es tu oficio de siempre con binarios nuevos.

---

## 💾 Backups de operación (la Fase 0, ascendida)

### El backup en caliente y consistente

```bash
# El dump de producción de la época — consistente aunque escriban:
mongodump --uri="mongodb://localhost:27017/?replicaSet=rs0" \
  --oplog --gzip --out=./backups/$(date +%F_%H%M)

# Restauración fiel al instante final del dump:
mongorestore --uri="..." --oplogReplay --gzip --drop ./backups/2026-07-11_0300
```

🔎 **Qué hace:** `--oplog` añade al dump un `oplog.bson` con lo escrito
durante la copia; `--oplogReplay` lo aplica al final. Sin él, un dump bajo
tráfico es una foto **movida**: cada colección copiada en un instante
distinto (la transferencia de la Fase 6 podría aparecer a medias). Nota
honesta: `--oplog` exige replica set — otro dividendo del RS de un nodo.

### La política, no el comando

La Fase 0 te dio el **comando** (`mongodump`/`mongorestore`, restauración
ensayada); aquí fijas por primera vez la **política** — frecuencia, retención,
ubicación y rito. Esa es toda la diferencia entre "sé hacer un backup" y
"tengo backups":

| Pieza | Decisión del Mini Jira (documenta la TUYA) |
|---|---|
| Frecuencia | dump nocturno (cron/servicio) + oplog dimensionado a >24 h |
| Retención | 7 diarios, 4 semanales, 3 mensuales (rotación en el script) |
| Dónde | fuera de la máquina (el backup en el mismo disco muere con él) |
| Adjuntos | GridFS entra al dump (decisión Fase 12, ej. 28: revalídala aquí) |
| **El rito** | restauración completa a un contenedor limpio, **mensual**, cronometrada, con checklist — un backup sin simulacro es una hipótesis con cron |

### Point-in-time, ensayado (el laboratorio estrella: ejercicio 22)

El guion: dump 03:00 → tráfico de la mañana → a las 11:47 alguien ejecuta el
`deleteMany({})` maldito → restauras el dump + repites el oplog **hasta las
11:46:59** (`mongorestore --oplogReplay --oplogLimit <timestamp>`). Los
tickets de la mañana viven; el desastre, no. Quien ha hecho esto una vez en
laboratorio no lo improvisa por primera vez en producción.

---

## ⚡ Índices en producción: la buena noticia de 4.4

La pregunta que te quitaba el sueño en SQL — "¿crear este índice bloqueará
la tabla?" — tiene en 4.4 una respuesta mejor que la que dejaste:

> 📝 **Nota legacy honesta (léela: vas a heredar código de esto):** hasta
> 4.0, `createIndex` tenía dos modos — *foreground* (rápido, **bloqueaba la
> base entera**) y `{ background: true }` (lento, no bloqueaba, índice algo
> peor). Todo tutorial de la época repite ese mantra, y verás
> `background: true` fosilizado en scripts heredados. **Desde 4.2 el dilema
> murió:** un único build híbrido que solo toma locks breves al inicio y al
> final, y construye sin bloquear lecturas ni escrituras. En 4.4 la opción
> `background` se **ignora** (no falla: se ignora — típico detalle que
> confunde auditorías). Traducción: en tu 4.4, crear índices en caliente es
> seguro por diseño; el costo restante es I/O y CPU, no locks.

Lo que sigue importando (tu oficio, intacto):

```js
// Verlo construir y medir su impacto:
db.currentOp({ "command.createIndexes": { $exists: true } })

// El precio permanente: cada índice se paga en CADA escritura (F7 dixit)
// El precio del build: I/O — en horario valle sigue siendo cortesía, no requisito
```

Y para el mundo multi-nodo que este curso no opera: el *rolling index build*
(nodo por nodo) queda señalado con su doc en referencias — sabrás que existe
el día que tu legacy tenga réplicas.

---

## 🔍 El profiler: tu Slow Query Log, reencontrado

Dos herramientas superpuestas, como en casa:

**1. El log de mongod** ya registra toda operación > 100 ms (el `slowms` por
defecto) — tu slow log gratuito: `docker compose logs mongo | grep "Slow query"`.
En 4.4 el log del servidor es **JSON estructurado**, pero `Slow query` sigue
apareciendo como texto del campo `msg`, así que el `grep` funciona igual (si
heredas un mongod más viejo con log en texto plano, la frase también está).

**2. El profiler** lo asciende a colección consultable:

```js
db.setProfilingLevel(1, { slowms: 50 })   // nivel 1: solo lentas; 2: TODO (solo para cazar)
db.getProfilingStatus()

// system.profile es una colección capped: consúltala como cualquier otra
db.system.profile.find({ millis: { $gt: 50 } })
  .sort({ ts: -1 }).limit(5)

// El top de dolor por forma de query (¡tu vieja consulta al AWR, en MQL!):
db.system.profile.aggregate([
  { $group: { _id: { op: "$op", ns: "$ns",
                     plan: "$planSummary" },          // COLLSCAN = la pista
              total: { $sum: "$millis" }, n: { $sum: 1 },
              avg: { $avg: "$millis" } } },
  { $sort: { total: -1 } }, { $limit: 10 }
])
```

🔎 **Qué hace:** el nivel 1 con umbral razonable convive con producción de
sistemas internos (nivel 2 jamás: registra TODO y se paga); `planSummary`
trae la palabra que buscas — **COLLSCAN** — y con ella el flujo completo que
esta fase cierra: **profiler encuentra → `explain` diagnostica (Fase 7) →
índice resuelve → profiler confirma**. El círculo de tu vida de DBA,
restaurado.

### La guardia: mongostat, mongotop, currentOp, killOp

```bash
mongostat 5        # el vmstat de mongo: ops/s, dirty cache, conexiones — el pulso
mongotop 5         # tiempo de lectura/escritura POR colección — quién duele
```

```js
// La query fugitiva (tu v$session + kill de siempre):
db.currentOp({ active: true, secs_running: { $gt: 10 } })
db.killOp(<opid>)     // con juicio: mata la OPERACIÓN, respeta el proceso
```

---

## 🐳 El compose final: el sistema, empaquetado

```yaml
# 'version' es informativa en Compose v2+; se conserva por costumbre de la época
version: "3.8"

services:
  mongo:
    image: mongo:${MONGO_VERSION:-4.4}
    container_name: ${MONGO_CONTAINER:-minijira-mongo}
    command: ["mongod", "--replSet", "rs0", "--oplogSize", "512"]
    ports: ["${MONGO_PORT:-27017}:27017"]
    volumes:
      - ${MONGO_DATA_PATH:-./mongo-data}:/data/db
    healthcheck:
      test: ["CMD", "mongo", "--quiet", "--eval", "db.adminCommand('ping').ok"]
      interval: 10s
      timeout: 5s
      retries: 5

  api:
    build: .
    container_name: minijira-api
    environment:
      - MONGO_URL=mongodb://mongo:27017/minijira?replicaSet=rs0
      - JWT_SECRET=${JWT_SECRET:?definelo_en_.env}
      - NODE_ENV=production
    ports:
      - "3000:3000"     # API
      - "4000:4000"     # sockets
    depends_on:
      mongo:
        condition: service_healthy

  backup:
    image: mongo:${MONGO_VERSION:-4.4}
    profiles: ["ops"]              # solo corre cuando lo invocas
    volumes: ["./backups:/backups"]
    entrypoint: >
      mongodump --uri="mongodb://mongo:27017/?replicaSet=rs0"
      --oplog --gzip --out=/backups/manual
```

🔎 **Qué hace:** tres decisiones operativas encarnadas — el **healthcheck**
de mongo hace que la API espere a un motor vivo, no a un contenedor
encendido (adiós al `ECONNREFUSED` del arranque); el `JWT_SECRET` con
`:?` **exige** el `.env` (el secreto no tiene default, por diseño — Fase 11);
y el servicio `backup` bajo `profiles: ["ops"]` es tu comando de respaldo
manual (`docker compose --profile ops run backup`) con la misma imagen y la
misma red. Nota fina de shell: dentro de la imagen `mongo:4.4` el binario del
shell es `mongo` (el clásico legacy) — por eso el healthcheck usa `mongo` y no
`mongosh`. `mongosh` es el shell nuevo que instalas aparte (Compass lo trae, y
es el que usas en tu host para inspeccionar el oplog arriba); ambos conviven en
la época y no es una errata. Otra nota fina: dentro de la red de compose, la
URI dice `mongo:27017`
— y el `rs.initiate` del RS debe declarar ese host (ejercicio 28 pelea y
documenta ese detalle, el clásico de la época).

---

## 🧩 Chuleta de la fase

```bash
# Backup de operación
mongodump --uri=...replicaSet=rs0 --oplog --gzip --out=DIR
mongorestore --oplogReplay [--oplogLimit ts] [--drop] DIR
# política = frecuencia + retención + fuera de máquina + SIMULACRO mensual
# ventana PIT = dump más viejo útil + retención real del oplog

# Índices en caliente (4.4): build híbrido, sin foreground/background
#   `background: true` en legacy = fósil inofensivo (se ignora)

# El Slow Query Log reencontrado
db.setProfilingLevel(1, { slowms: 50 })
db.system.profile ... planSummary: "COLLSCAN"   ← la palabra
# flujo: profiler → explain (F7) → índice → profiler confirma

# La guardia
mongostat 5 · mongotop 5
db.currentOp({ secs_running: { $gt: 10 } }) → db.killOp(id)

# Disco: borrar NO devuelve espacio al SO (reutilizable ≠ liberado) → compact/restore
```

---

## ⚠️ Errores comunes

- Dump sin `--oplog` bajo tráfico y creer que es consistente (la foto
  movida).
- Backups religiosos, restauración jamás ensayada — hasta el día que sí.
- Backup en el mismo disco/host que la base (mueren juntos, siempre juntos).
- Oplog dimensionado por defecto con dumps semanales: la ventana PIT es una
  ilusión aritmética.
- Copiar `background: true` de un tutorial 2018 a tu 4.4 y creer que hizo
  algo (o peor: creer que su ausencia bloqueará todo y crear índices a las
  3 am por superstición — mide, no temas).
- Profiler nivel 2 olvidado encendido en un sistema con tráfico.
- `killOp` a lo que no se debe (operaciones internas de replicación: el
  manual lista qué NO matar — léelo antes de la guardia, no durante).
- El compose sin healthcheck: la API corriendo antes que el motor, y el
  clásico crash-loop del arranque.
- Pánico por el disco que "no baja" tras un gran borrado (el 🪞 de la fase:
  es reutilizable, no fugado).

---

## 🧪 Ejercicios (34)

**🟢 Fácil (1–10)**

1. Enciende el profiler (nivel 1, `slowms: 50`) y genera una lenta a propósito (regex no anclado sobre 100k sin índice — Fase 2/7). Encuéntrala en `system.profile` y lee su `planSummary`.
2. Cierra tu primer círculo: con lo que el profiler encontró, corre el `explain` (Fase 7), crea el índice que falta, repite la query y confirma en el profiler que bajó del umbral. Documenta el flujo en 5 pasos.
3. `mongostat 5` durante el torture-test (Fase 6/11): identifica qué columnas se mueven y qué significan (la doc de mongostat al lado). ¿Cuál delataría un problema de memoria?
4. `mongotop 5` durante el mismo torture: ¿qué colección concentra la escritura? ¿Coincide con lo que sabes del test?
5. Mira tu oplog: las últimas 5 operaciones tras crear un ticket desde el frontend. ¿Cómo aparece el `findOneAndUpdate` del "tomar"? ¿Y el `$inc` del contador `commentsCount` (Fase 6)?
6. `rs.printReplicationInfo()`: ¿cuántas horas de ventana tiene tu oplog HOY con tu tráfico de laboratorio? Anótalo — es la cifra que gobierna tu PIT.
7. Primer dump de operación: `--oplog --gzip`, y restáuralo con `--oplogReplay` a una base renombrada (`--nsFrom/--nsTo`, Fase 0). Verifica conteos por colección.
8. Escribe el script `scripts/backup.sh` de la política: dump con fecha, gzip, rotación 7/4/3 (borra los que sobran), y log de resultado. Córrelo 3 veces y verifica la rotación.
9. Lanza una query eterna a mano (un `$where` con sleep o un regex monstruoso sobre 1M), cázala con `currentOp` y ejecútala con `killOp`. Verifica qué recibió el cliente.
10. Inventario de índices para el runbook: `getIndexes()` de cada colección + tamaño (`db.collection.stats().indexSizes`) → tabla en `SETUP.md`.

**🟡 Intermedio (11–20)**

11. La foto movida, demostrada: durante un dump SIN `--oplog`, corre en paralelo el rename todo-o-nada de la Fase 6 (la doble escritura `users`+`tickets`, en bucle). Restaura y busca inconsistencias entre `users` y `tickets` (el script de reconciliación de la F5 como detector). Repite CON `--oplog --oplogReplay`. Documenta la diferencia encontrada (o por qué esta vez no apareció: probabilidad también es dato).
12. El simulacro mensual, versión completa: contenedor limpio desde cero + restauración del último backup + suite de contrato (`test:contract`, Fase 13) contra el restaurado. Cronometra el RTO (tiempo hasta "API respondiendo"). Documenta el rito en `SETUP.md` con checklist.
13. Redimensiona el oplog en caliente (`replSetResizeOplog`) a 1 GB. Verifica con `printReplicationInfo` cómo cambió la ventana. ¿Qué pasa con las entradas viejas?
14. El profiler es capped: llena `system.profile` (nivel 2 durante el torture, 1 minuto) y observa cómo recicla. Redimensiónalo (requiere apagar el profiler, drop y recrear con tamaño — la doc lo guía). ¿Por qué capped es la elección correcta aquí?
15. Construye un índice grande en caliente: sobre la colección de 1M (genera si hace falta), crea un compuesto mientras el torture corre. Mide: duración del build, ¿se bloquearon las escrituras? (compara ops/s de mongostat durante/antes). El mantra foreground/background, enterrado con datos.
16. Encuentra el fósil: agrega `{ background: true }` al createIndex en tu 4.4. ¿Error, warning o silencio? Busca en el log del server qué dijo. Escribe la nota de auditoría que dejarías en un PR legacy que lo tenga.
17. `mongotop` no ve lo que no corre: compara la visión de mongotop vs el profiler para el MISMO minuto de tráfico. ¿Qué ve cada uno que el otro no? (Agregado por colección vs operación por operación.) ¿Cuál usarías para "algo está lento" y cuál para "ESTA query está lenta"?
18. Dashboard de guardia mínimo: script `scripts/health-report.js` que junte en una pantalla: serverStatus (conexiones, memoria), printReplicationInfo (ventana oplog), top 5 del profiler, y espacio de `db.stats()`. Es tu `AWR de los pobres` — y suficiente para el Mini Jira.
19. Restaura un backup de una versión "anterior": simula heredar un dump hecho con opciones viejas (hazlo sin gzip, sin oplog) y súbelo a tu 4.4. ¿Qué se pierde? ¿Los índices llegan? (El `.metadata.json` de la Fase 0, reencontrado en contexto serio.)
20. Backup selectivo bajo fuego: la colección `attachments.chunks` pesa (Fase 12, ej. 28). Implementa la política de dos velocidades: dump diario SIN chunks (`--excludeCollection`) + dump semanal completo. Mide ambos y documenta el trade-off de recuperación (¿qué pierdes si el desastre cae en jueves?).

**🟠 Difícil (21–28)**

21. **Point-in-time, el laboratorio estrella (parte 1):** monta el guion completo — dump 03:00 (simulada), 500 escrituras "de la mañana" con timestamps reales, y el `deleteMany({})` maldito a una hora conocida. Anota el timestamp exacto del desastre (el oplog te lo da: encuéntralo).
22. **(parte 2):** restaura a T-1 segundo con `--oplogReplay --oplogLimit`. Verifica: las 500 de la mañana viven, el delete no ocurrió. Cronometra todo el procedimiento y escríbelo como runbook paso a paso en `SETUP.md` — con el espacio para "timestamp del desastre: ____" que llenarás con manos temblorosas el día real.
23. La aritmética de la ventana: con tu tamaño de oplog y una tasa de escritura medida (genera tráfico constante y mide GB/hora de oplog con `printReplicationInfo` en dos momentos), calcula: ¿cada cuánto DEBES dumpear para que siempre haya PIT posible? Escribe la fórmula y tu política resultante.
24. `fsyncLock` y la copia caliente del filesystem: la alternativa de la Fase 0 (copia fría) sin apagar — `db.fsyncLock()`, copia del dbPath, `fsyncUnlock()`. Hazlo bajo tráfico ligero, restaura la copia en otro contenedor y verifica. Documenta los riesgos (¿qué pasa con las escrituras durante el lock? ¿y si olvidas el unlock?).
25. `compact` con la letra chica: tras el gran borrado del 🪞 (ej. 26 primero si vas en orden), corre `compact` sobre la colección en tu 4.4. ¿Bloqueó? ¿Cuánto devolvió? Lee en la doc qué cambió sobre compact justamente en 4.4 (spoiler: dejó de bloquear la base entera) y documenta la versión de tu runbook.
26. El 🪞 medido: colección de 2 GB (el generador + adjuntos falsos), borra el 50%, mide `du` del dbPath y `db.stats()` (dataSize vs storageSize — la diferencia ES el espacio reutilizable). Inserta de nuevo: ¿creció el archivo o reusó? El high-water mark, demostrado.
27. La guardia completa, simulada: un compañero (o tú con dos terminales y mala intención) provoca UNO de: query fugitiva / profiler nivel 2 olvidado / disco al 90% con oplog gigante / build de índice pesado. Tu trabajo: diagnosticar SOLO con las herramientas de la fase (sin mirar el "código del ataque") y escribir el mini-postmortem: síntoma → herramienta → causa → acción.
28. El compose final, peleado y ganado: móntalo completo (con Dockerfile de la API). Pelea el detalle del RS con hostname (`rs.initiate` con `mongo:27017` vs `localhost` — el error te va a encontrar) y documenta la solución. Verifica: `docker compose up` desde cero → seed → suite de contrato verde → backup con el profile ops. El sistema entero, un comando.

**🔴 Muy difícil (29–34)**

29. Restore parcial quirúrgico: del backup completo, restaura SOLO la colección `comments` a una base lateral, extrae los 50 comentarios que un bug borró (simúlalo), e injértalos en producción sin tocar lo demás (`mongorestore --nsInclude` + export/import fino de la Fase 0). El caso real más frecuente que el PIT completo.
30. Automatiza el simulacro: script/compose que ejecute el rito del ej. 12 completo sin intervención (levantar contenedor efímero, restaurar último backup, correr test:contract, reportar RTO y resultado, destruir). Déjalo listo para un cron mensual. Un simulacro que exige voluntad humana termina no ocurriendo.
31. El presupuesto de operación: durante 1 hora de torture sostenido mide y tabula: costo del profiler nivel 1 (ops/s con vs sin), costo del dump nocturno en caliente (latencia p95 de la API durante), costo del build de índice grande. Es la tabla que responde "¿puedo hacer esto en horario laboral?" con números y no con miedo.
32. Runbook adversarial: dale tu `SETUP.md` a alguien que NO hizo el curso (o sigue tú cada paso con literalidad malintencionada) para el procedimiento PIT del ej. 22. Cada paso donde tuvo que preguntar o adivinar es un bug del runbook: repara hasta que sea ejecutable bajo estrés. (Los runbooks se leen a las 4 am; escríbelos para esa persona.)
33. El mapa del mundo multi-nodo: SIN montarlo, escribe la página "el día que este sistema tenga réplicas": qué cambia en backups (dumps desde el secundario), en índices (rolling builds), en la connection string, en el monitoreo (lag de replicación) — cada afirmación con su link a la doc 4.4. Es el documento que te hará parecer adivino cuando pase.
34. **El ensayo de la fase** (1 página, `INSTINTOS.md`): "Operar es la parte que no cambió". Tesis: los cinco paradigmas invirtieron cómo modelas, unes y garantizas — pero la operación (backup ensayado, ventana calculada, medir antes de tocar, el runbook para las 4 am) es EL territorio donde tu década de SQL se transfiere casi entera; por eso el dev SQL que opera Mongo con su vieja liturgia supera al nativo NoSQL que nunca la aprendió. Usa tus simulacros y mediciones como evidencia. Cierra con tu checklist de guardia personal en 10 líneas.

---

## 📚 Referencias

**Documentación oficial (4.4 y herramientas)**

- MongoDB Backup Methods (el mapa, releído con ojos de operador): https://www.mongodb.com/docs/v4.4/core/backups/
- mongodump — `--oplog`: https://www.mongodb.com/docs/database-tools/mongodump/
- mongorestore — `--oplogReplay`, `--oplogLimit`, `--nsInclude`: https://www.mongodb.com/docs/database-tools/mongorestore/
- Replica Set Oplog: https://www.mongodb.com/docs/v4.4/core/replica-set-oplog/
- Index Builds on Populated Collections (el build híbrido de 4.2+): https://www.mongodb.com/docs/v4.4/core/index-creation/
- Rolling Index Builds (el mundo multi-nodo, para el ej. 33): https://www.mongodb.com/docs/v4.4/tutorial/build-indexes-on-replica-sets/
- Database Profiler: https://www.mongodb.com/docs/v4.4/tutorial/manage-the-database-profiler/
- Profiler output (leer `system.profile`): https://www.mongodb.com/docs/v4.4/reference/database-profiler/
- mongostat / mongotop: https://www.mongodb.com/docs/database-tools/mongostat/ · https://www.mongodb.com/docs/database-tools/mongotop/
- `db.currentOp` / `db.killOp` (y qué NO matar): https://www.mongodb.com/docs/v4.4/reference/method/db.currentOp/ · https://www.mongodb.com/docs/v4.4/reference/method/db.killOp/
- `compact` (y su comportamiento en 4.4): https://www.mongodb.com/docs/v4.4/reference/command/compact/
- `fsyncLock`: https://www.mongodb.com/docs/v4.4/reference/method/db.fsyncLock/
- Compose — healthchecks y profiles: https://docs.docker.com/compose/compose-file/

> ⚠️ **Aviso de versión:** los enlaces de **Database Tools** (`mongodump`,
> `mongorestore`, `mongostat`, `mongotop`) y de **Compose** no están fijados a
> una versión por MongoDB/Docker: apuntan a la doc viva. Las Database Tools de
> la época son la línea ~100.x y Compose vivía entre v1 y v2 — verifica que la
> página que leas corresponda a tu stack antes de copiar flags. El resto de
> enlaces sí son de MongoDB **4.4**, tu versión.

**Libros**

- *MongoDB: The Definitive Guide*, 3.ª ed. — parte de administración
  (backups, monitoring): escrita exactamente para tu versión.

**Video (YouTube)**

- Backups oficiales y PIT: busca "MongoDB backup restore oplog" en el canal
  de MongoDB (los talks de M312/ops de la época recorren este capítulo)
- mongostat/mongotop en vivo: cualquier demo de "MongoDB performance
  troubleshooting" de MongoDB World 2019–2020

**Orden de lectura sugerido para perfil senior:**
Replica Set Oplog (10 min — es tu redo log, lo vas a leer sonriendo) →
ejercicios 5–7 → mongodump/restore como referencia mientras montas la
política → el laboratorio PIT (ej. 21–22) ANTES de leer más: es la fase →
Index Builds de 4.2+ (la buena noticia) → profiler → el compose final.

---

## 🚀 Cierre

Al final de esta fase el sistema no solo funciona: **se opera**. Backups
nocturnos consistentes bajo tráfico con su simulacro mensual automatizable,
point-in-time ensayado con el timestamp del desastre encontrado en el oplog,
índices creados en caliente sin superstición, el Slow Query Log reencontrado
en el profiler con su círculo virtuoso cerrado, la guardia equipada
(mongostat, currentOp, killOp con juicio), y todo empaquetado en un compose
que levanta el sistema completo con un comando. `SETUP.md` ya no es un
documento de instalación: es el runbook que le dejarías al que te releve.

La señal de que quedó bien:

> "si mañana a las 11:47 alguien ejecuta el deleteMany maldito, no improviso:
> abro el runbook, encuentro el timestamp en el oplog, y ejecuto un
> procedimiento que ya hice tres veces en laboratorio".

**Siguiente parada:** ⚖️ Fase 15 — El veredicto honesto: ¿debías haber usado
Mongo? Sabes modelar, consultar, garantizar, servir y operar. Queda la
conversación que ningún tutorial tiene — mirar el sistema completo (y los que
heredarás) y responder la pregunta prohibida con criterio en vez de bandera.
