# 🕵️ Forense Fase 00 — "Levanté todo y no conecta"

> **Sale de:** [Fase 0 — Preliminares](00-preliminares.md) ·
> **Herramientas:** el log del contenedor (`docker compose logs`), `mongosh` y
> el listado de puertos · **Recorrido:** cuatro pasos, ninguno abre un archivo
> de la aplicación
>
> **El síntoma, en una línea:** el contenedor dice que está arriba, y nada
> logra conectarse.

Es la investigación menos vistosa del curso y la que más se repite en la vida
real. El punto no es Mongo: es el reflejo de **leer el log del arranque antes de
googlear el mensaje de error del cliente**, porque el cliente casi nunca sabe
por qué no lo dejaron entrar.

---

## 🎫 El ticket

> "Seguí los pasos, levanté el compose y me dice que el contenedor está
> corriendo, pero Compass no conecta y mongosh tampoco. Ayer funcionaba. No
> cambié nada, solo reinicié la máquina."
>
> — un compañero que se está incorporando al proyecto

"Ayer funcionaba" y "no cambié nada" son, casi siempre, ciertos. Lo que cambió
fue el entorno alrededor, y eso es lo que hay que buscar.

---

## 🧭 La ruta

Del más barato al más caro: el log del arranque cuesta un comando y contesta el
90% de los casos; los puertos, otro comando; y solo al final se toca el compose.

### Paso 1 — ¿qué dice el log del arranque?

Antes que nada, y antes que el cliente:

```bash
docker compose logs -f mongo
```

```
mongo_1  | {"t":{"$date":"…"},"s":"E","c":"NETWORK","msg":"Failed to set up listener",
mongo_1  |  "attr":{"error":"Address already in use"}}
mongo_1  | {"t":{"$date":"…"},"s":"I","c":"CONTROL","msg":"now exiting"}
```

**Qué descarta.** Descarta el cliente, la cadena de conexión, la red de Docker y
tu configuración: el servidor **ni siquiera llegó a escuchar**. Y descarta la
sensación de que "el contenedor está arriba": puede estar reiniciándose en bucle,
cosa que `docker compose ps` confirma. Las dos pistas que resuelven la mayoría de
los tropiezos de setup viven acá — el puerto ocupado y los permisos sobre el
`dbPath` del bind mount.

### Paso 2 — ¿quién tiene el 27017?

Si el log habla de la dirección en uso:

```bash
lsof -i :27017              # macOS / Linux
netstat -ano | findstr :27017   # Windows
```

```
mongod   1284  oskar   11u  IPv4  TCP *:27017 (LISTEN)
```

**Qué descarta.** Cierra el caso más común de todos, y explica el "ayer
funcionaba": hay **dos `mongod` peleando** — el nativo, instalado como servicio y
que arranca solo al encender la máquina, y el del contenedor. El de Docker llega
segundo y no puede escuchar. Apaga uno de los dos; en el Curso 02 el que manda es
el del compose.

### Paso 3 — el contenedor vive y aun así no entra nadie

Si el log no tiene errores y el proceso escucha, prueba desde dentro y desde
fuera, en ese orden:

```bash
docker compose exec mongo mongosh --eval 'db.runCommand({ ping: 1 })'
```

```
{ ok: 1 }
```

```bash
mongosh "mongodb://localhost:27017/minijira" --eval 'db.runCommand({ ping: 1 })'
```

```
MongoServerSelectionError: connect ECONNREFUSED 127.0.0.1:27017
```

**Qué descarta.** Separa dos mundos que se confunden todo el tiempo. Si adentro
responde y afuera no, Mongo está perfecto: lo que falta es la **publicación del
puerto** en el compose (`ports: - "27017:27017"`), o el proceso está escuchando
solo en la interfaz interna. Ningún cambio en tu código va a arreglar eso.

### Paso 4 — "se perdieron los datos"

Variante del mismo ticket, con otro susto. Si conecta pero las colecciones están
vacías:

```js
> show dbs
admin    41 kB
config   61 kB
local    41 kB
```

```bash
grep -n "MONGO_DATA_PATH\|volumes:" -A 3 docker-compose.yml
```

**Qué descarta.** Descarta el borrado. Los datos casi nunca se pierden en este
escenario: **siguen en la ruta vieja**. Cambiar la ruta del volumen con el
contenedor corriendo deja los archivos donde estaban y monta un directorio
nuevo, vacío. El orden correcto es `down` → cambiar → `up`. Y si el proyecto se
levantó sin volumen ninguno, entonces sí: recrear el contenedor se lleva todo, y
eso es diseño de compose, no un fallo de Mongo.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| El contenedor "está arriba" y nadie conecta | El log del arranque: casi seguro no llegó a escuchar |
| `Address already in use` en el log | Dos `mongod`: el nativo como servicio y el de Docker |
| Adentro responde el ping y afuera no | Falta publicar el puerto en el compose |
| Conecta y las colecciones están vacías | El volumen cambió de ruta: los datos siguen en la vieja |
| Errores de permisos sobre el `dbPath` | Bind mount con dueño equivocado |
| `mongoexport` no existe | Desde 4.4 las Database Tools se instalan aparte |
| Importaste un dump y "no entró nada" | `--jsonArray` puesto o faltante según el formato del archivo |
| Editaste `mongod.cfg` en Windows y nada cambió | El servicio no se reinició |
| Compass conecta y tu aplicación no | Cadena de conexión distinta: revisa base, usuario y host |

---

## ⚰️ Los callejones

**"Borro el contenedor y lo levanto de cero."** Es el `rm -rf node_modules` de
este curso: a veces funciona, nunca enseña nada, y si el problema era el volumen
acabas de perder datos de verdad. Antes de recrear, lee el log — cuesta cinco
segundos y suele traer el diagnóstico escrito.

**"Instalo la última versión, seguro es un bug de la 4.4."** El curso fija 4.4 a
propósito: es el motor que tu legacy va a tener. Estudiar contra otra versión
cambia el comportamiento de cosas que sí importan —transacciones, `$lookup` con
`let`, el planificador— y te deja aprendiendo un sistema que no es el tuyo.

**"Instalé Compass, entonces ya tengo MongoDB."** Son tres piezas distintas —el
servidor, el shell y la interfaz gráfica— y confundirlas produce media hora de
desconcierto. Compass es un cliente: si el servidor no está, no hay nada que
mirar.

---

## 🧠 El patrón transferible

**Cuando un cliente no puede conectarse, el cliente es el peor testigo posible.**
Solo sabe que no lo dejaron entrar; el motivo está del otro lado. Por eso el
orden de esta pieza pone el log del servidor por delante del mensaje de error, y
por eso el paso 3 prueba desde dentro antes que desde fuera: cada movimiento
parte el problema en dos y descarta una mitad.

Lo que se lleva uno a cualquier stack: **el arranque de un servicio es su
declaración de intenciones**, y casi siempre dice en texto plano lo que después
vas a tardar una hora en deducir desde el otro extremo.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 0](00-preliminares.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 01](cuaderno-incidentes.md); y los detalles de Docker, en
[A01](a01-docker.md).
