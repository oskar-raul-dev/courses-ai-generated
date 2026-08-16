# 🛠️ Fase 0 — Preliminares: instalar, arrancar y tocar Mongo

## 🎯 Propósito

Dejar MongoDB **4.4 instalado, corriendo y tocado con las manos** antes de que
la Fase 1 empiece a hablar en serio. Aquí no hay paradigmas ni Mini Jira:
hay terminal, un `docker-compose.yml` parametrizable que te va a acompañar
todo el curso, y una base de juguete (`playground`, con personas) para perder
el miedo a la CLI, cargar datos, y volcarlos a disco como JSON.

Piénsalo como el ritual de entrada: cuando termines, escribir
`mongosh` y ver el prompt te resultará tan natural como `sqlplus` o `psql`.

> ⚠️ **La versión no es negociable: 4.4.** Es la del legacy 2018–2021 que este
> curso simula. Si instalas la última "porque es mejor", vas a estudiar contra
> un motor que tu futuro sistema heredado no tiene.

---

## ✅ Qué queda listo al terminar

- MongoDB 4.4 corriendo (Docker como camino principal; instalador nativo en
  Windows/macOS como alternativa documentada);
- un `docker-compose.yml` **parametrizable por `.env`**: puerto, ruta física
  de los datos, nombre del contenedor, flags de `mongod`;
- mongosh y Compass conectados;
- la base `playground` con una colección `people`: insertar, consultar
  mínimo, actualizar, borrar;
- datos volcados a disco como JSON (`mongoexport`) y recargados
  (`mongoimport`) — el ciclo completo de ida y vuelta;
- el menú de **backup real** conocido y las dos opciones básicas probadas:
  `mongodump`/`mongorestore` (BSON, con restauración ensayada a otra base) y
  la copia fría del `dbPath`;
- claridad sobre dónde viven **físicamente** tus datos;
- un `SETUP.md` que documenta los tres caminos (Docker/Windows/macOS): cómo
  arrancar y detener, dónde viven los datos, y las tres estrategias de backup
  con su restauración verificada — el runbook que le pasarías al siguiente dev.

## 🚫 Qué NO entra todavía

- el diccionario SQL↔Mongo y el proyecto Mini Jira (Fase 1)
- consultas en serio: operadores, proyecciones, trampas (Fase 2)
- modelado (Fase 3) — `people` es plastilina, no diseño
- **operación** de backups (programación, oplog, point-in-time, restauración
  selectiva) — Fase 14; aquí conoces el menú de opciones y pruebas las dos
  básicas con tus manos
- réplicas, auth del servidor, producción — nada de eso

---

## 🧠 Qué estás instalando, en 60 segundos

Tres piezas distintas que la gente confunde:

| Pieza | Qué es | Tu equivalente mental |
|---|---|---|
| `mongod` | el **servidor**: el proceso que guarda datos y escucha en `:27017` | el servicio de SQL Server / el `postgres` daemon |
| `mongosh` | el **shell**: cliente de línea de comandos (REPL de JavaScript) | `sqlplus`, `psql`, `sqlcmd` |
| Compass | la **GUI** oficial | SSMS, DBeaver, pgAdmin |

> 📝 **Nota legacy honesta:** hay dos shells. El clásico se llama `mongo` (a
> secas) y es el que trae la imagen Docker 4.4 por dentro; el moderno es
> `mongosh` y es el que instalarás en tu máquina. Para todo lo que hace este
> curso son intercambiables; escribimos `mongosh` y avisamos si algo difiere.
> En un servidor legacy real solo encontrarás `mongo`: no te asustes.

---

## 🐳 Camino A (recomendado): Docker con compose parametrizable

Docker te da la versión exacta, aislada, borrable y repetible. Este compose es
**el oficial del curso** — la Fase 1 lo reutiliza tal cual:

### `docker-compose.yml`

```yaml
version: "3.8"

services:
  mongo:
    image: mongo:${MONGO_VERSION:-4.4}
    container_name: ${MONGO_CONTAINER:-curso-mongo}
    ports:
      - "${MONGO_PORT:-27017}:27017"
    volumes:
      # Bind mount: la ruta FÍSICA de tus datos, visible y elegible por ti
      - ${MONGO_DATA_PATH:-./mongo-data}:/data/db
    # Parámetros extra de mongod (ejemplos; bórralos si no los necesitas)
    command: ["mongod", "--wiredTigerCacheSizeGB", "0.5"]
```

### `.env` (junto al compose — aquí parametrizas sin tocar el YAML)

```bash
MONGO_VERSION=4.4
MONGO_CONTAINER=curso-mongo
MONGO_PORT=27017
# Ruta física donde vivirá la base. Relativa o absoluta:
MONGO_DATA_PATH=./mongo-data
# MONGO_DATA_PATH=/datos/mongo-curso        # Linux/macOS
# MONGO_DATA_PATH=C:/datos/mongo-curso      # Windows (barras normales)
```

```bash
docker compose up -d          # levantar
docker compose ps             # ¿está corriendo?
docker compose logs -f mongo  # ver el arranque de mongod
docker compose down           # apagar (los datos QUEDAN en MONGO_DATA_PATH)
```

🔎 **Qué hace:** la sintaxis `${VAR:-default}` toma el valor del `.env` y, si
no existe, usa el default — el compose funciona recién clonado y se
personaliza sin editarlo. El **bind mount** (`ruta-tuya:/data/db`) responde la
pregunta que todo DBA hace primero: *"¿dónde están físicamente mis datos?"*
Respuesta: en `MONGO_DATA_PATH`, míralos con `ls`.

✅ **Buenas prácticas que quedan sembradas:**

- versionar `docker-compose.yml` y un `.env.example`; el `.env` real, al
  `.gitignore` (costumbre que pagará dividendos cuando en la Fase 11 tenga
  secretos de verdad);
- `docker compose down` **no** borra datos con bind mount; borrar es decisión
  explícita tuya (`rm -rf ./mongo-data`) — como debe ser;
- el `command` es donde afinarás flags de `mongod` cuando toque (el ejemplo
  limita la caché de WiredTiger a 0.5 GB: útil en laptops con poca RAM).

> 📝 **Bind mount vs volumen nombrado:** el compose de la Fase 1 original
> usaba un volumen nombrado (`mongo_data:`) — datos administrados por Docker
> en una ruta interna. Aquí preferimos bind mount porque *ver* los archivos
> (`WiredTiger.wt`, `collection-*.wt`, `journal/`) tiene valor didáctico para
> un DBA. Trade-off honesto: en **Windows y macOS** el bind mount es más
> lento (el filesystem cruza una VM); si te molesta, cambia a volumen
> nombrado — ejercicio 12.

**Instala aparte en tu máquina (host):**

- **mongosh:** https://www.mongodb.com/docs/mongodb-shell/install/
- **Compass:** https://www.mongodb.com/docs/compass/install/
- **MongoDB Database Tools** (`mongoexport`, `mongoimport` — desde 4.4 se
  distribuyen separadas del servidor): https://www.mongodb.com/docs/database-tools/installation/installation/

```bash
mongosh mongodb://localhost:27017    # y estás dentro
```

> 💡 Alternativa sin instalar nada en el host: todo vive también dentro del
> contenedor — `docker exec -it curso-mongo mongo` (shell clásico) y
> `docker exec -it curso-mongo mongoexport ...`. Menos cómodo, cero
> instalación. Elige tu religión; el curso muestra los comandos desde el host.

---

## 🪟 Camino B: instalador nativo en Windows (breve)

1. Descarga el **MSI de MongoDB Community Server 4.4** desde el Download
   Center (elige versión 4.4.x, no la última): https://www.mongodb.com/try/download/community
2. En el instalador: *Complete*, marca **"Install MongoD as a Service"**
   (arranca solo con Windows) y desmarca Compass si prefieres instalarlo
   aparte.
3. Rutas que importan (configurables en el MSI):
   - binarios: `C:\Program Files\MongoDB\Server\4.4\bin`
   - **datos**: `C:\Program Files\MongoDB\Server\4.4\data`
   - configuración: `...\4.4\bin\mongod.cfg` — ahí vive `storage.dbPath` si
     quieres mover los datos a otro disco (edita, reinicia el servicio).
4. El servicio se administra con `services.msc` o
   `net stop MongoDB` / `net start MongoDB` (terminal como administrador).
5. Instala mongosh y las Database Tools aparte y agrégalos al `PATH`.

## 🍎 Camino C: instalador nativo en macOS (breve)

```bash
# Homebrew + tap oficial de MongoDB
brew tap mongodb/brew
brew install mongodb-community@4.4

brew services start mongodb-community@4.4   # arrancar como servicio
brew services stop mongodb-community@4.4
```

Rutas (Homebrew): datos en `/usr/local/var/mongodb` (Intel) o
`/opt/homebrew/var/mongodb` (Apple Silicon); config en `mongod.conf` junto a
ellas (`storage.dbPath` para moverlos).

> ⚠️ **Apple Silicon:** los binarios 4.4 son x86_64 (corren vía Rosetta 2) y
> el tap puede ponerse quisquilloso con versiones viejas. Si hay fricción, no
> pelees: **usa Docker**, que para eso está el Camino A.

> 🎯 Regla del curso para B y C: son válidos y quedan documentados, pero los
> ejemplos asumen Docker. Si vas nativo, tu única diferencia real es cómo
> arrancas/detienes el servidor y dónde está `dbPath`.

---

## 🧪 La base de juguete: `playground` y sus `people`

Nada de tickets todavía. Plastilina pura para soltar la mano:

```js
mongosh mongodb://localhost:27017

use playground

// Insertar UNA persona — mira el anidamiento sin dramatismo: es solo JSON
db.people.insertOne({
  name: "Ana",
  lastName: "García",
  age: 34,
  email: "ana@example.com",
  tags: ["ops", "backend"],
  address: { city: "Bogotá", country: "CO" }
})

// Insertar VARIAS
db.people.insertMany([
  { name: "Luis", lastName: "Pérez", age: 41, email: "luis@example.com",
    tags: ["dba"], address: { city: "Medellín", country: "CO" } },
  { name: "Marta", lastName: "Ruiz", age: 29, email: "marta@example.com",
    tags: ["frontend", "backend"], address: { city: "Quito", country: "EC" } },
  { name: "Iker", lastName: "Etxeberria", age: 52, email: "iker@example.com",
    tags: [], address: { city: "Bilbao", country: "ES" } }
])

// Leer (la Fase 2 convierte esto en un arsenal; hoy, lo mínimo vital)
db.people.find()                          // todo
db.people.find({ age: { $gte: 40 } })    // un WHERE de probadita
db.people.findOne({ name: "Ana" })      // el primero que matchee
db.people.countDocuments()                // COUNT(*)

// Actualizar y borrar (idem: probadita; lo serio en Fases 2 y 6)
db.people.updateOne({ name: "Ana" }, { $set: { age: 35 } })
db.people.deleteOne({ name: "Iker" })

// Inventario
show dbs
show collections
db.people.drop()        // cuando quieras empezar de cero
```

🔎 **Qué hace:** te pasea por el ciclo completo — crear insertando (sin DDL:
la Fase 1 le pondrá nombre a esa sorpresa), leer, actualizar con `$set`,
borrar, inventariar. Fíjate en el `_id` que apareció solo en cada documento:
también tiene capítulo en la Fase 1.

> 💡 **mongosh es un REPL de JavaScript.** `var x = db.people.findOne();
> x.email` funciona. `for` funciona. Esto convierte al shell en tu navaja de
> auditoría — el curso lo explota sin piedad.

Abre **Compass**, conéctate, y mira `playground → people`: los mismos
documentos, con pestañas de esquema inferido e inserción visual. Úsalo como
usabas SSMS: para mirar; la terminal es donde se trabaja.

---

## 💾 Volcar a disco y recargar: el ciclo JSON

Tu instinto de DBA pide backup antes de jugar. El par de época para JSON
plano es `mongoexport` / `mongoimport`:

```bash
# Exportar la colección a un archivo JSON (un documento por línea: NDJSON)
mongoexport --uri="mongodb://localhost:27017/playground" \
  --collection=people --out=people.json

# ¿Prefieres un array JSON "normal" en vez de NDJSON? --jsonArray
mongoexport --uri="mongodb://localhost:27017/playground" \
  --collection=people --jsonArray --pretty --out=people-array.json

# Importar de vuelta (a otra colección, para comparar)
mongoimport --uri="mongodb://localhost:27017/playground" \
  --collection=people_restored --file=people.json

# La versión --jsonArray se importa declarándolo:
mongoimport --uri="mongodb://localhost:27017/playground" \
  --collection=people_v2 --jsonArray --file=people-array.json

# El combo clásico "reemplaza todo": --drop
mongoimport --uri="mongodb://localhost:27017/playground" \
  --collection=people --drop --jsonArray --file=people-array.json
```

🔎 **Qué hace:** `mongoexport` escribe JSON legible a disco (por defecto
**NDJSON**: un documento por línea — el formato que las herramientas de la
época mastican mejor); `--jsonArray` produce el array clásico. `mongoimport`
hace el viaje inverso, y `--drop` vacía la colección antes de cargar.

Abre `people.json` en tu editor y mira cómo viajó el `_id`:

```json
{"_id":{"$oid":"64a1f2..."},"name":"Ana","age":35, ...}
```

Ese `{"$oid": ...}` es **Extended JSON**: la convención para representar
tipos BSON (ObjectId, fechas) en JSON plano sin perderlos. Te lo vas a
encontrar en fixtures, logs y tickets de soporte de por vida — reconócelo.

> ⚠️ **JSON ≠ backup.** `mongoexport`/`mongoimport` son para intercambio
> legible y fixtures. Un backup real preserva tipos, índices y estructura —
> la sección siguiente te da el menú. Si hoy alguien te pide "el backup en
> JSON", ya sabes qué cara poner.

> 🐳 **Desde Docker sin tools en el host:** `docker exec curso-mongo
> mongoexport ... --out=/tmp/people.json` y luego
> `docker cp curso-mongo:/tmp/people.json .` — el archivo nace dentro del
> contenedor y lo copias afuera. (Ejercicio 15.)

---

## 🗄️ Backup real: el menú más allá del volcado JSON

El volcado JSON pierde cosas que un DBA no acepta perder: los tipos exactos
(lo viste con el `$oid`), los **índices**, las colecciones vacías, las
opciones de colección (validators de la Fase 4). Las opciones reales de la
época, de más usada a más seria:

| Opción | Qué copia | Consistencia | Cuándo usarla |
|---|---|---|---|
| **`mongodump` / `mongorestore`** (BSON) | datos en BSON binario + metadatos (índices se **recrean** al restaurar) | consistente por colección; para consistencia total del cluster necesita `--oplog` (Fase 14) | el estándar diario de la época: portable, selectivo (una base, una colección), no requiere detener nada |
| **Copia fría del `dbPath`** (filesystem) | TODO byte a byte: datos, índices ya construidos, journal | perfecta — pero exige **mongod detenido** (o `fsyncLock`, Fase 14) | migrar de máquina, clonar un entorno, backup brutal pre-cirugía |
| **Snapshot de filesystem/volumen** (LVM, EBS, ZFS…) | el volumen completo en un instante | consistente **si** el journal está en el mismo volumen | producción seria con infraestructura que lo soporte |
| Réplica como "backup" | — | — | ⚠️ **no es backup**: replica también tus `DROP` — es disponibilidad, no historia. Recuérdalo cuando un legacy te lo presente como estrategia |

### `mongodump` / `mongorestore`: el backup de verdad, probado hoy

```bash
# Backup binario de la base playground (carpeta dump/ con .bson + .metadata.json)
mongodump --uri="mongodb://localhost:27017" --db=playground --out=./dump

# Mira lo que produjo: datos en BSON + índices/opciones en el metadata
ls dump/playground/
#   people.bson   people.metadata.json

# Restaurar a OTRA base (ensayo sin riesgo — nunca ensayes sobre la original)
mongorestore --uri="mongodb://localhost:27017" \
  --nsFrom="playground.*" --nsTo="playground_restored.*" ./dump

# El combo destructivo clásico (reemplaza lo que exista): --drop
mongorestore --uri="mongodb://localhost:27017" --drop ./dump

# Comprimido y a un solo archivo (para mover entre máquinas):
mongodump --uri="..." --db=playground --gzip --archive=playground.gz
mongorestore --uri="..." --gzip --archive=playground.gz
```

🔎 **Qué hace:** `mongodump` escribe cada colección como `.bson` (los bytes
tal cual, tipos intactos) más un `.metadata.json` con índices y opciones;
`mongorestore` recarga los datos y **reconstruye los índices** al final. El
par `--nsFrom`/`--nsTo` renombra al restaurar — la forma civilizada de
ensayar una restauración sin pisar el original. Vienen en el mismo paquete de
Database Tools que ya instalaste.

### La copia fría del `dbPath`: el backup de DBA clásico

Tu bind mount de esta fase la vuelve trivial:

```bash
docker compose down                    # mongod detenido = bytes quietos
cp -r ./mongo-data ./backups/frio-2026-07-11
docker compose up -d
```

Restaurar = apuntar `MONGO_DATA_PATH` a la copia (o copiarla de vuelta). Es
el backup más simple y más completo que existe — al precio de una ventana de
apagado, impagable en producción 24/7 (por eso existen el `fsyncLock` y los
snapshots: Fase 14).

> 📝 **Regla de oro que esta fase deja instalada:** un backup que nunca se
> restauró es una **hipótesis**, no un backup. Todo ejercicio de backup de
> este curso incluye su restauración verificada — cuenta documentos, compara,
> y solo entonces confía.

---

## 🧩 Chuleta de la fase

```bash
# Entorno
docker compose up -d / down / ps / logs -f mongo
mongosh mongodb://localhost:27017

# Dónde están mis datos físicamente
#   Docker: $MONGO_DATA_PATH (bind mount)
#   Windows MSI: ...\Server\4.4\data  (mongod.cfg → storage.dbPath)
#   macOS brew: /usr/local/var/mongodb | /opt/homebrew/var/mongodb

# Supervivencia mongosh
show dbs / use X / show collections
db.col.insertOne({...}) / insertMany([...])
db.col.find({...}) / findOne / countDocuments()
db.col.updateOne({filtro}, { $set: {...} })
db.col.deleteOne({filtro}) / db.col.drop()

# JSON a disco y de vuelta (intercambio/fixtures, NO backup)
mongoexport --uri=... --collection=X [--jsonArray --pretty] --out=X.json
mongoimport --uri=... --collection=X [--jsonArray] [--drop] --file=X.json

# Backup REAL
mongodump  --uri=... --db=X [--gzip --archive=X.gz] --out=./dump
mongorestore --uri=... [--drop] [--nsFrom="X.*" --nsTo="X_rest.*"] ./dump
# frío: down → copiar $MONGO_DATA_PATH → up   (mongod detenido = bytes quietos)
# regla: backup sin restauración verificada = hipótesis
```

---

## ⚠️ Errores comunes

- Instalar "la última versión" y estudiar contra un motor que tu legacy no
  tendrá (4.4 o nada).
- Confundir las tres piezas: "instalé Compass" no es "instalé MongoDB".
- En Docker: cambiar `MONGO_DATA_PATH` con el contenedor corriendo y
  preguntarse dónde quedaron los datos (down → cambiar → up; los datos viejos
  siguen en la ruta vieja).
- Buscar `mongoexport` dentro del paquete del servidor: desde 4.4 las
  Database Tools se instalan **aparte**.
- Exportar sin `--jsonArray`, intentar importar como array (o viceversa) y
  culpar al archivo.
- En Windows: editar `mongod.cfg` y no reiniciar el servicio.
- Dejar dos `mongod` peleando por el 27017 (el nativo como servicio + el de
  Docker): el error `port already in use` en los logs del contenedor te lo
  dirá — apaga uno.

> 🔎 **Pieza forense de la fase:** cuando algo no arranca, el primer sitio a
> mirar son los logs del arranque — `docker compose logs -f mongo` (o el visor
> de eventos del servicio nativo). Ahí viven las dos pistas que resuelven el
> 90% de los tropiezos de setup: `port already in use` (hay otro `mongod`
> ocupando el 27017) y los errores de permisos sobre el `dbPath` del bind
> mount. Léelos antes de googlear.

---

## 🧪 Ejercicios (34)

> Numeración continua; los 🔥 opcionales van aparte al final, sin numerar.

**🟢 Fácil (1–10)**

1. Levanta el entorno por tu camino elegido y verifica versión desde mongosh: `db.version()` debe empezar con `4.4`.
2. Cambia `MONGO_PORT` a `27018` en el `.env`, recicla el contenedor y conéctate al puerto nuevo. Devuélvelo a `27017`.
3. Localiza tus datos físicos: lista el contenido de `MONGO_DATA_PATH` (o `dbPath` nativo) e identifica `WiredTiger.wt` y la carpeta `journal/`. No toques nada: solo mira.
4. Inserta 5 personas más en `playground.people`, al menos dos de tu país con `address` completa.
5. `find` de las personas con `age` mayor que un valor que deje fuera al menos a una. Cuenta el resultado con `countDocuments` usando el mismo filtro.
6. Actualiza el email de una persona con `updateOne` + `$set`. Verifica con `findOne`.
7. Borra una persona por nombre. Confirma el conteo antes y después.
8. `show dbs` antes y después de `use playground` con la base recién borrada (`db.dropDatabase()`): ¿cuándo aparece una base en la lista? Reconstruye tus personas después.
9. Exporta `people` a NDJSON y a `--jsonArray --pretty`. Abre ambos en el editor y anota 3 diferencias.
10. Reimporta el NDJSON a `people_copy` y verifica que los conteos coinciden.

**🟡 Intermedio (11–22)**

11. Apaga todo con `docker compose down`, borra el contenedor, vuelve a levantar. ¿Siguen las personas? Explica por qué (bind mount). Ahora repite el experimento tras mover `MONGO_DATA_PATH` a otra ruta: ¿qué ves y por qué?
12. Convierte el compose a **volumen nombrado** (`mongo_data:/data/db` + bloque `volumes:`). Averigua con `docker volume inspect` dónde guarda Docker los datos realmente. Vuelve al bind mount y escribe 3 líneas: ¿cuál prefieres para este curso y cuál usarías en un servidor Linux de producción?
13. Agrega al `command` del compose el flag `--port 27017` explícito y otro parámetro que encuentres en la doc de `mongod` (por ejemplo `--quiet`). Verifica en los logs que arrancó con ellos.
14. Crea un `.env.example` versionable (sin valores sensibles, con comentarios) y agrega `.env` y `mongo-data/` al `.gitignore`.
15. Haz el ciclo export/import **completamente dentro del contenedor** (`docker exec` + `docker cp`), sin Database Tools en el host.
16. Sube un segundo contenedor Mongo (`curso-mongo-b`, puerto 27020, ruta de datos propia) **reutilizando el mismo compose** con un segundo servicio. Conéctate a ambos en dos pestañas de mongosh.
17. Exporta las personas de `curso-mongo` e impórtalas en `curso-mongo-b`. Acabas de hacer tu primera "migración" entre servidores.
18. En Compass: inserta una persona usando el formulario, edita otra, y usa la pestaña *Schema* sobre `people`. ¿Qué infiere del campo `tags`? ¿Y de `address`?
19. `mongoexport` con `--query`: exporta solo las personas de un país (ojo: el filtro va como JSON entre comillas — pelea con el quoting de tu shell y documenta la sintaxis que te funcionó).
20. `mongoimport --mode=upsert`: modifica una persona en el JSON exportado (cambia su edad), reimporta sobre la colección original sin `--drop` y verifica que actualizó en vez de duplicar. ¿Qué campo usó para reconocerla?

21. Escribe `scripts/backup-json.sh` (o `.ps1` en Windows): exporta TODAS las colecciones de una base a una carpeta `backups/AAAA-MM-DD/` con un archivo por colección. Pista: `mongosh --quiet --eval "db.getCollectionNames()"` te da la lista.
22. Y su pareja `scripts/restore-json.sh`: recorre la carpeta y reimporta cada archivo con `--drop`. Prueba el ciclo completo: backup → estropea datos a mano → restore → verifica.
**🟠 Difícil (23–30)**

23. Mueve los datos de sitio **sin perderlos**: down, mueve la carpeta física a la ruta nueva, actualiza `MONGO_DATA_PATH`, up. Verifica que las personas siguen. Documenta el procedimiento en 5 pasos: acabas de escribir tu primer runbook.
24. Rompe un import a propósito: edita el JSON exportado e introduce una línea con JSON inválido y otra con un `_id` duplicado. ¿Qué reporta `mongoimport`? ¿Importó las líneas sanas? Investiga `--stopOnError` y decide cuál comportamiento querrías en un script de carga nocturna.
25. El Extended JSON en serio: exporta, y en el archivo cambia a mano un `_id` de `{"$oid":"..."}` a un string plano `"..."`. Reimporta a una colección nueva. ¿Qué tipo tiene ahora ese `_id`? (Compass te lo muestra.) ¿Qué consecuencia tendría esa contaminación silenciosa? — guarda la respuesta para la trampa de tipos de la Fase 2.
26. Instala 4.4 por el camino nativo de tu sistema operativo (aunque tu camino principal sea Docker): deja el servicio corriendo en otro puerto, conéctate, y luego desinstálalo/deténlo limpiamente. Documenta dónde estaba su `dbPath`. (Si estás en Apple Silicon y el tap se rebela, documenta el error exacto y por qué Docker es la salida — también es aprendizaje.)
27. **Backup real, ida y vuelta:** `mongodump` de `playground`, restauración con `--nsFrom/--nsTo` a `playground_restored`, y verificación por conteos colección por colección. Abre el `.metadata.json` del dump: ¿qué guarda que el JSON de `mongoexport` perdía?
28. Demuestra la diferencia con un experimento: crea un índice en `people` (`db.people.createIndex({ email: 1 })` — la Fase 7 lo explicará; hoy es utilería), haz un ciclo `mongoexport→mongoimport` a una base nueva y un ciclo `mongodump→mongorestore` a otra. Compara `db.people.getIndexes()` en las tres bases. ¿Cuál ciclo preservó el índice y por qué?
29. **Copia fría completa:** down → copia del `dbPath` → up. Luego el desastre controlado: `db.dropDatabase()` sobre `playground` y restauración apuntando `MONGO_DATA_PATH` a la copia. Verifica y cronometra ambos sentidos. Bonus: ¿qué pasa si copias el `dbPath` con mongod **corriendo** y levantas esa copia? Pruébalo y documenta el resultado (journal, locks, o corrupción — lo que veas es la lección).
30. El archivo portable: `mongodump --gzip --archive` de `playground`, muévelo al segundo contenedor del ejercicio 16 y restáuralo ahí. Compara el tamaño del archivo contra la carpeta `dump/` sin comprimir y contra el JSON del ejercicio 9. Tabla de los tres formatos: tamaño, qué preserva, para qué sirve cada uno.

**🔴 Muy difícil (31–34)**

31. Parametriza el compose para aceptar un **archivo de configuración** de `mongod` (`mongod.conf` montado como volumen + `command: ["mongod", "--config", ...]`). Replica en el `.conf` los flags que tenías en `command` y verifica en logs que los tomó. Ahora tienes el setup que encontrarás en servidores reales.
32. Cronometra una carga: genera con un script Node o mongosh un JSON de 100.000 personas falsas, impórtalo con `mongoimport` midiendo el tiempo, y compara contra insertarlas vía mongosh con `insertMany` por lotes de 1.000. Tabula resultados. (Te reencontrarás con este experimento en la Fase 1, ejercicio 27 — guarda los números.)
33. Investiga qué son los archivos `collection-*.wt` e `index-*.wt` de tu carpeta de datos: inserta una colección nueva grande, observa qué archivos aparecen y cómo crecen (`ls -lh` antes/después). Escribe media página: ¿qué le contarías a un DBA de Oracle sobre cómo WiredTiger organiza esto en disco? (No hace falta profundidad de internals: observación + doc oficial.)
34. **El runbook de la fase:** documenta en `SETUP.md` los tres caminos (Docker/Windows/macOS) con: cómo arrancar, cómo detener, dónde están los datos, y las TRES estrategias de respaldo probadas (JSON para fixtures, `mongodump` como estándar, copia fría como opción nuclear) con su restauración verificada. Es el documento que le darías al siguiente dev del equipo. (Sí: escribir también es un ejercicio, y este archivo crece durante el curso.)

**🔥 Opcionales**

- 🔥 Levanta el mismo compose en una segunda máquina (o una VM) y restaura ahí el `--gzip --archive` del ejercicio 30. Cronometra la transferencia + restauración: es el ensayo de una migración real entre servidores.
- 🔥 Mide el peso del `journal/` bajo carga: importa las 100.000 personas del ejercicio 32 y observa cómo crece y se recicla la carpeta `journal/` durante la escritura (`ls -lh` en bucle). ¿Qué le contarías a un DBA sobre por qué está ahí?
- 🔥 Automatiza el backup frío con un script que haga `down → cp -r $MONGO_DATA_PATH → up` y registre la ventana de apagado en un log. Discute en 3 líneas por qué esa ventana es inaceptable en producción 24/7 (y qué la reemplaza: `fsyncLock`, snapshots — Fase 14).

---

## 📚 Referencias

**Documentación oficial (4.4 y herramientas)**

- Instalación MongoDB 4.4 (todas las plataformas): https://www.mongodb.com/docs/v4.4/installation/
- Instalar en Windows (MSI, servicio, `mongod.cfg`): https://www.mongodb.com/docs/v4.4/tutorial/install-mongodb-on-windows/
- Instalar en macOS (brew tap): https://www.mongodb.com/docs/v4.4/tutorial/install-mongodb-on-os-x/
- Imagen Docker oficial (variables, volúmenes): https://hub.docker.com/_/mongo
- Referencia de `mongod` (flags para el `command`): https://www.mongodb.com/docs/v4.4/reference/program/mongod/
- Archivo de configuración de mongod: https://www.mongodb.com/docs/v4.4/reference/configuration-options/
- mongosh: https://www.mongodb.com/docs/mongodb-shell/
- MongoDB Database Tools — mongoexport: https://www.mongodb.com/docs/database-tools/mongoexport/
- MongoDB Database Tools — mongoimport: https://www.mongodb.com/docs/database-tools/mongoimport/
- MongoDB Database Tools — mongodump: https://www.mongodb.com/docs/database-tools/mongodump/
- MongoDB Database Tools — mongorestore: https://www.mongodb.com/docs/database-tools/mongorestore/
- Manual 4.4 — MongoDB Backup Methods (el mapa completo de opciones): https://www.mongodb.com/docs/v4.4/core/backups/
- Manual 4.4 — Back Up and Restore with Filesystem Snapshots: https://www.mongodb.com/docs/v4.4/tutorial/backup-with-filesystem-snapshots/
- Extended JSON: https://www.mongodb.com/docs/v4.4/reference/mongodb-extended-json/
- Compass: https://www.mongodb.com/docs/compass/

**Docker (si te falta base)**

- Compose file reference (variables y defaults `${VAR:-def}`): https://docs.docker.com/compose/environment-variables/
- Volumes vs bind mounts: https://docs.docker.com/storage/

**Video (YouTube)**

- Docker Compose in 100 Seconds — Fireship: https://www.youtube.com/watch?v=Qw9zlE3t8Ko
- MongoDB with Docker (setup rápido) — Net Ninja / Traversy (cualquiera de sus setups de la época sirve; verifica que usen imagen con tag de versión)

**Orden de lectura sugerido para perfil senior:**
levanta el compose primero (no leas: ejecuta) → sección de la imagen Docker
en Docker Hub → mongoexport/mongoimport → ejercicios 11–12 (volúmenes: es lo
único conceptualmente nuevo de la fase) → el resto de ejercicios.

---

## 🚀 Cierre

Al final de esta fase tienes el motor exacto de la época corriendo bajo un
compose que controlas parámetro a parámetro, sabes dónde viven físicamente
tus datos en los tres sistemas operativos, la CLI te responde sin mirar
apuntes, el ciclo datos↔disco (export/import JSON, con Extended JSON
reconocido a simple vista) está probado con tus manos — y sabes distinguir
un volcado de un backup: `mongodump` ensayado con restauración verificada y
la copia fría como opción nuclear.

La señal de que quedó bien:

> "puedo levantar, apagar, mover de carpeta, respaldar en JSON y restaurar
> esta base sin googlear — y sé exactamente qué pieza estoy tocando en cada
> comando".

**Siguiente parada:** 🍃 Fase 1 — Mongo en 30 min para gente que ya sabe
bases de datos. Se acabó la plastilina: entra el diccionario de traducción,
el ObjectId con su capítulo propio, y el `db.json` heredado del Mini Jira —
tu primer encuentro con una integridad referencial que ya no custodia nadie
más que tú.
