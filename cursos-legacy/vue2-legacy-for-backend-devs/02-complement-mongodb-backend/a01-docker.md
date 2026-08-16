# 🐳 Apéndice 1 — Docker mínimo

## 🎯 Para qué sirve este apéndice

El curso usó Docker desde la primera línea de la Fase 0 y nunca se detuvo a
explicarlo: levantaste Mongo, montaste volúmenes, peleaste con puertos y
terminaste en la Fase 14 con un compose de tres servicios, healthchecks y un
perfil de backup. Aquí está la teoría que iba debajo — la justa para que
puedas **leer, modificar y depurar** el entorno de cualquier proyecto de la
época sin adivinar.

No es un curso de Docker: es el mapa de las piezas que este curso usó, con
el bug clásico de cada una explicado desde la raíz.

> ⚠️ Lo que NO entra: Kubernetes, swarm, orquestación, multi-stage builds
> avanzados, registries privados. Si tu legacy los tiene, este apéndice te
> deja en condiciones de leer su doc — no de operarlos.

---

## 🧠 Imagen, contenedor, volumen: los tres sustantivos

| Pieza | Qué es | Tu analogía |
|---|---|---|
| **Imagen** | plantilla inmutable de solo lectura (`mongo:4.4`) | el instalador / la ISO |
| **Contenedor** | una instancia en ejecución de una imagen, con su capa de escritura efímera | el proceso corriendo |
| **Volumen / bind mount** | almacenamiento que **sobrevive** al contenedor | el disco de datos |

La regla que ordena todo: **el contenedor es desechable, los datos no.** Todo
lo que escribas dentro del contenedor y no esté en un volumen muere con él.
Por eso `docker compose down` no te borró las personas de la Fase 0: vivían
en `MONGO_DATA_PATH`, fuera del contenedor.

### El tag: la línea entre reproducible y roulette

```yaml
image: mongo:4.4        # ✅ el curso: la línea 4.4, actualizable en parches
image: mongo:4.4.18     # ✅✅ producción: byte por byte, siempre igual
image: mongo            # 🚨 = mongo:latest = "lo que sea que haya hoy"
```

`latest` no significa "estable": significa "la última que publicaron". Un
`docker pull` seis meses después te trae otro motor. **El 90% de los "en mi
máquina funciona" de la época vivía en esa línea.**

---

## 🗄️ Volúmenes vs bind mounts (la decisión de la Fase 0, explicada)

```yaml
volumes:
  - ./mongo-data:/data/db      # BIND MOUNT: una carpeta TUYA, la ves con ls
  - mongo_data:/data/db        # VOLUMEN NOMBRADO: Docker lo administra
```

| | Bind mount | Volumen nombrado |
|---|---|---|
| Dónde viven los bytes | donde tú digas (`./mongo-data`, `/datos/mongo`) | en las tripas de Docker (`docker volume inspect` te lo dice) |
| Los ves con `ls` | ✅ sí — valor didáctico (viste `WiredTiger.wt`) | ❌ no directamente |
| Rendimiento en Linux | idéntico | idéntico |
| Rendimiento en Win/macOS | 🐌 **más lento** (el FS cruza una VM) | ✅ rápido |
| Permisos | pueden morder (UID del contenedor vs tuyo) | Docker los maneja |
| `docker compose down -v` | **no los borra** (por eso el ej. 8 de la F1) | **los borra** |

**El criterio del curso:** bind mount en la Fase 0 porque *ver* los datos
físicos era el punto pedagógico (un DBA pregunta "¿dónde están mis bytes?"
antes que nada). En un servidor Linux de producción, cualquiera de los dos
sirve; en tu laptop Windows/macOS con una base grande, el volumen nombrado te
ahorra sufrimiento.

---

## 🌐 Redes: el bug que te esperaba en la Fase 14

Este es el concepto que más tiempo te habría ahorrado saber antes:

```
Desde TU MÁQUINA (host)          →  localhost:27017   (por el `ports:` publicado)
Desde OTRO CONTENEDOR de compose →  mongo:27017       (por el nombre del servicio)
```

Compose crea una red privada donde **cada servicio es un hostname**. Por eso
el `MONGO_URL` de la API dice `mongodb://mongo:27017` y tu mongosh dice
`localhost`. Y `ports: ["27017:27017"]` es solo el puente
host→contenedor: **los contenedores entre sí no lo necesitan** (podrías
borrar el `ports` de mongo y la API seguiría funcionando; solo perderías tu
acceso desde mongosh).

> 💥 **El bug clásico del `rs.initiate` (F14, ej. 28):** si inicias el replica
> set declarando `host: "localhost:27017"`, el propio Mongo se anuncia como
> "localhost" — y cuando la API (desde otro contenedor) se conecta y descubre
> la topología, intenta hablarle a *su propio* localhost y falla. La cura:
> declarar `host: "mongo:27017"` (el nombre de red)… lo que rompe tu acceso
> desde el host, porque tu máquina no resuelve "mongo". Las dos salidas de la
> época: (1) agregar `127.0.0.1 mongo` a tu `/etc/hosts` — el truco sucio que
> todos usábamos; (2) usar `directConnection=true` en la URI del host. Ahora
> el error tiene sentido en vez de ser magia negra.

---

## 🎛️ El compose que el curso construyó, anotado

```yaml
version: "3.8"

services:
  mongo:
    image: mongo:${MONGO_VERSION:-4.4}          # ① variable con default
    container_name: ${MONGO_CONTAINER:-minijira-mongo}
    command: ["mongod", "--replSet", "rs0"]     # ② pisa el CMD de la imagen
    ports: ["${MONGO_PORT:-27017}:27017"]       # ③ host:contenedor
    volumes:
      - ${MONGO_DATA_PATH:-./mongo-data}:/data/db
    healthcheck:                                 # ④ ¿está VIVO o solo encendido?
      test: ["CMD", "mongo", "--quiet", "--eval", "db.adminCommand('ping').ok"]
      interval: 10s
      timeout: 5s
      retries: 5

  api:
    build: .                                     # ⑤ construye desde tu Dockerfile
    environment:
      - MONGO_URL=mongodb://mongo:27017/minijira?replicaSet=rs0   # ⑥ hostname de red
      - JWT_SECRET=${JWT_SECRET:?definelo_en_.env}                # ⑦ sin default: EXIGIDO
    ports: ["3000:3000", "4000:4000"]
    depends_on:
      mongo:
        condition: service_healthy               # ⑧ espera al healthcheck, no al proceso

  backup:
    image: mongo:${MONGO_VERSION:-4.4}
    profiles: ["ops"]                            # ⑨ no arranca con `up`; se invoca
    volumes: ["./backups:/backups"]
    entrypoint: >
      mongodump --uri="mongodb://mongo:27017/?replicaSet=rs0" --oplog --gzip --out=/backups/manual
```

**Las nueve piezas:**

① `${VAR:-default}` = usa `.env` o cae al default (el compose funciona recién
clonado). ② `command` reemplaza el comando por defecto de la imagen —
así le metiste flags a `mongod`. ③ **izquierda = tu máquina, derecha =
dentro del contenedor**; cambiar `MONGO_PORT` a 27018 solo cambia la
izquierda. ④ el **healthcheck** distingue "el contenedor arrancó" de "Mongo
responde ping". ⑤ `build: .` = hay un `Dockerfile` en esa carpeta. ⑥ el
hostname de red, no localhost. ⑦ `${VAR:?mensaje}` **falla el arranque** si
falta — así se declara que un secreto no tiene default. ⑧ `depends_on` a
secas solo espera a que el contenedor **exista**; con `condition:
service_healthy` espera a que esté **sano** — la diferencia entre un
`ECONNREFUSED` en el arranque y un sistema que sube solo. ⑨ `profiles` deja
servicios definidos pero dormidos: `docker compose --profile ops run backup`.

---

## 📦 El Dockerfile de la API (Node 14 de época)

```dockerfile
FROM node:14.21.3-alpine

WORKDIR /app

# ⚡ Truco de capas: copiar SOLO los manifiestos primero.
# Docker cachea cada capa; si package.json no cambió, no reinstala nada
# aunque hayas tocado 40 archivos de src/. Invertir estas 4 líneas
# = npm install en CADA build. Es EL error de Dockerfile de la época.
COPY package*.json ./
RUN npm ci --only=production

COPY . .

ENV NODE_ENV=production
EXPOSE 3000 4000
CMD ["node", "src/server.js"]
```

```gitignore
# .dockerignore — sin esto, el COPY . . se lleva node_modules
# (megas de basura, y peor: binarios compilados para TU SO, no para alpine)
node_modules
npm-debug.log
mongo-data
backups
.env
.git
```

🔎 **Qué hace:** `npm ci` (no `install`) instala exactamente el
`package-lock.json` — reproducible y más rápido; `--only=production` deja
fuera Jest y compañía. El `.dockerignore` no es opcional: sin él, copias tus
`node_modules` locales dentro de la imagen y en el mejor caso pesa 400 MB de
más, en el peor rompe con módulos nativos compilados para otro sistema.

---

## 🧩 Chuleta

```bash
# Ciclo de vida
docker compose up -d / down / ps / restart <svc>
docker compose logs -f <svc>            # ⬅️ el primer comando de todo diagnóstico
docker compose down -v                  # -v BORRA volúmenes nombrados (bind mounts NO)

# Meterse dentro
docker exec -it <cont> bash             # o `sh` en imágenes alpine
docker exec -it <cont> mongo            # el shell clásico, dentro
docker cp <cont>:/tmp/x.json .          # sacar/meter archivos

# Construir
docker compose build [--no-cache]
docker compose up -d --build            # rebuild + levantar

# Forense
docker compose config                   # ⬅️ el compose con las variables YA resueltas
docker volume ls / docker volume inspect <v>
docker stats                            # CPU/RAM por contenedor
docker system df / docker system prune  # cuánto ocupa / limpiar basura

# Red: host → localhost:PUERTO_PUBLICADO · contenedor → nombre_servicio:PUERTO_REAL
```

---

## ⚠️ Diagnóstico rápido

| Síntoma | Causa probable |
|---|---|
| `port is already allocated` | otro contenedor (o un Mongo nativo) ya tiene el puerto — `docker ps`, o cambia `MONGO_PORT` |
| La API arranca y muere con `ECONNREFUSED mongo:27017` | `depends_on` sin `condition: service_healthy`: subió antes que el motor |
| `ECONNREFUSED 127.0.0.1:27017` desde la API | la API usa `localhost` en vez del hostname de red (`mongo`) |
| `getaddrinfo ENOTFOUND mongo` desde tu **host** | estás usando el nombre de red fuera de la red — desde el host es `localhost` |
| Los datos "desaparecieron" | cambiaste `MONGO_DATA_PATH` (los viejos siguen en la ruta vieja) o usabas volumen nombrado y corriste `down -v` |
| El build tarda una eternidad siempre | Dockerfile con `COPY . .` antes del `npm ci` — el orden de capas |
| La imagen pesa 1 GB | falta `.dockerignore` (te llevaste `node_modules` y `.git`) |
| Cambié el `.env` y no pasó nada | las variables se leen al **crear** el contenedor: `docker compose up -d` de nuevo (o `--force-recreate`) |
| `permission denied` en el bind mount (Linux) | UID del proceso del contenedor ≠ dueño de la carpeta |
| Todo raro tras editar el YAML | `docker compose config` y mira qué entendió de verdad |

---

## 🧪 Ejercicios (34) — todos opcionales

**🟢 Fácil (1–10)**

1. `docker compose config` sobre el compose de la Fase 14: localiza cada `${VAR}` ya resuelta. Cambia una en el `.env` y repite: verifica que se propagó.
2. Rompe el puerto a propósito: levanta dos veces el mismo servicio con el mismo `ports`. Lee el error, resuélvelo de dos formas distintas (cambiar puerto / matar el otro).
3. `docker exec -it` al contenedor de Mongo: explora `/data/db` desde dentro y compáralo con lo que ves en tu `MONGO_DATA_PATH` desde fuera. Son los mismos bytes: demuéstralo creando un archivo desde un lado y viéndolo del otro.
4. Elimina el contenedor (no el volumen) y recréalo. ¿Sobrevivieron los datos? Escribe la regla en una línea.
5. Publica Mongo en otro puerto (`27020:27017`) y conéctate. Explica en un comentario por qué el `27017` de la derecha NO cambió.
6. Quita el `ports:` de mongo y verifica: ¿la API sigue funcionando? ¿Y tu mongosh? Deduce quién necesita la publicación de puertos.
7. `docker stats` durante el torture-test (F6/F12): ¿cuánta RAM come Mongo? Compáralo con el flag `--wiredTigerCacheSizeGB` de la Fase 0.
8. `docker system df`: ¿cuánto espacio te ha comido el curso entre imágenes, contenedores y volúmenes? Limpia con `prune` y vuelve a medir (cuidado con los volúmenes que quieres conservar).
9. Levanta un `mongo:latest` junto al `mongo:4.4` en otro puerto. Compara `db.version()`. Escribe la nota de por qué el curso fija el tag.
10. Construye la imagen de la API y mira su tamaño (`docker images`). Ahora borra el `.dockerignore` y reconstruye. Compara. Restaura el archivo.

**🟡 Intermedio (11–22)**

11. El orden de capas: cronometra `docker compose build` tras tocar un archivo de `src/` con el Dockerfile correcto. Ahora invierte (`COPY . .` antes del `npm ci`), toca `src/` y reconstruye. Tabula la diferencia — acabas de ver el caché de capas.
12. Añade un healthcheck a la API (`GET /health` con `wget`/`curl` en la imagen — ojo: alpine trae `wget`, no `curl`). Verifica el estado con `docker ps` (columna health).
13. Prueba `depends_on` sin `condition`: quítalo y arranca todo desde cero repetidas veces. ¿Cuántas veces la API muere por `ECONNREFUSED`? Restaura la condición y repite. La carrera de arranque, medida.
14. El bug del RS con hostname: haz `rs.initiate` con `localhost:27017` y conecta la API. Fotografía el error. Ahora con `mongo:27017` y conecta desde tu host. Fotografía el otro error. Aplica una de las dos curas y documéntala en `SETUP.md`.
15. `${VAR:?mensaje}`: borra `JWT_SECRET` del `.env` e intenta levantar. Lee el mensaje. ¿Por qué es preferible a un default `"secreto123"`?
16. Perfiles: ejecuta el servicio `backup` con `--profile ops run`. Verifica el archivo en `./backups`. Añade un segundo servicio de perfil ops (`restore`) y úsalo.
17. Variables en tiempo de build vs de ejecución: agrega un `ARG NODE_VERSION` al Dockerfile y un `ENV APP_NAME` al compose. Demuestra con `docker exec ... env` cuál está disponible dónde y por qué.
18. Logs con criterio: `docker compose logs --since 5m mongo | grep -i "slow query"` — encuentra las lentas de la Fase 14 sin encender el profiler. ¿Qué te da el log que no da el profiler y viceversa?
19. Monta el `mongod.conf` como bind mount (F0, ej. 31) y arranca con `--config`. Verifica en los logs que tomó tus opciones.
20. Dos entornos, un compose: crea `docker-compose.override.yml` (dev: puertos publicados, bind mount) y verifica cómo compose los fusiona con el base. `docker compose config` te muestra el resultado.
21. Red aislada: crea una red custom donde Mongo NO publique puertos y la API sí. Desde el host, intenta conectar a Mongo directo (debe fallar) y a través de un endpoint de la API (debe funcionar). Acabas de hacer lo que producción hace siempre.
22. Limpieza de imágenes huérfanas: tras 10 builds, `docker images` está lleno de `<none>`. Investiga qué son (capas de builds anteriores) y límpialas sin borrar lo que usas.

**🟠 Difícil (23–29)**

23. Multi-stage build: separa una etapa `builder` (con devDependencies, corre los tests de la F13) de la etapa final (solo producción). Compara el tamaño final y verifica que un test rojo **rompe el build**. Acabas de tener CI sin CI.
24. Usuario no-root: el contenedor de Node corre como root por defecto (mala idea). Agrega `USER node` al Dockerfile y pelea los permisos que aparezcan. Documenta qué se rompió y cómo lo arreglaste — es el ejercicio que separa el Dockerfile de tutorial del de producción.
25. Permisos del bind mount en Linux: provoca el `permission denied` (carpeta con dueño equivocado), diagnostícalo (`docker exec ... id`, `ls -ln` del host) y resuélvelo de dos formas (chown vs `user:` en compose). Documenta cuál usarías en un servidor compartido.
26. Backup del volumen nombrado: si migras al volumen nombrado (F0 ej. 12), ¿cómo respaldas los bytes? Implementa el patrón clásico: un contenedor efímero que monta el volumen y el directorio de backup, y hace tar. Restáuralo en un volumen nuevo y verifica.
27. Límites de recursos: pon `mem_limit` y `cpus` a Mongo en el compose. Corre el torture-test y observa qué pasa cuando el motor no tiene RAM para su caché (`docker stats` + latencias). Encuentra el límite donde el sistema empieza a doler — es exactamente el ejercicio de dimensionamiento que harás en un servidor real.
28. Compose de tests: un `docker-compose.test.yml` que levante Mongo efímero (tmpfs, sin volumen: datos en RAM) y corra `npm test` de la F13 dentro de un contenedor, saliendo con el código de Jest. Es el pipeline de CI en 15 líneas — y funciona en cualquier máquina con Docker.
29. Depura un contenedor que muere al arrancar: sabotea el `CMD` (typo en la ruta). El contenedor se va y no puedes hacer `exec`. Encuentra las tres técnicas para investigar igual (`logs`, `run --entrypoint sh` sobre la imagen, `docker commit` del fallido). Es el rescate que necesitarás algún día.

**🔴 Muy difícil (30–34)**

30. El proxy unificador (F12, ej. 29) hecho compose: nginx que sirva el frontend estático, `/api` → API, `/socket.io` → sockets, todo en un solo origin. Verifica que el frontend puede usar `baseURL` relativa y que la deuda de URLs hardcodeadas quedó pagada. Documenta el `nginx.conf` línea por línea.
31. Escalado horizontal: `docker compose up --scale api=3` tras el proxy con balanceo. Verifica que la API responde… y que los sockets se rompen (F12, ej. 30). Ahora sabes DÓNDE se rompió y por qué (cada réplica con su io). Documenta el diagnóstico como si fuera un incidente real.
32. Reproducibilidad total: fija TODO (tag con digest `mongo:4.4@sha256:...`, `npm ci` con lock, versión de compose) y demuestra que dos máquinas distintas producen imágenes idénticas (compara digests). Escribe qué se rompería sin cada pieza fijada.
33. Sistema completo desde cero en una máquina virgen: clona tu repo en otra máquina (o borra TODO: imágenes, volúmenes, node_modules) y cronometra hasta "suite de contrato en verde" siguiendo solo tu `SETUP.md`. Cada tropiezo es un bug del runbook (el ejercicio adversarial de la F14, aplicado al entorno).
34. El apéndice que faltaba: escribe `DOCKER-NOTES.md` para tu proyecto — qué servicio hace qué, qué variable controla qué, los 5 comandos que un dev nuevo necesita, y los 3 errores que se va a encontrar con su cura. Media página. Es lo que te habría gustado recibir en la Fase 0.

---

## 📚 Referencias

**Documentación oficial**

- Docker — Get Started (conceptos): https://docs.docker.com/get-started/
- Compose file reference (v3.8 — la del curso): https://docs.docker.com/compose/compose-file/compose-file-v3/
- Compose — variables de entorno y `${VAR:-def}` / `${VAR:?err}`: https://docs.docker.com/compose/environment-variables/
- Storage — volumes vs bind mounts: https://docs.docker.com/storage/
- Networking en Compose (los hostnames de servicio): https://docs.docker.com/compose/networking/
- Dockerfile best practices (el orden de capas está aquí): https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
- Imagen oficial de MongoDB: https://hub.docker.com/_/mongo
- Imagen oficial de Node: https://hub.docker.com/_/node

**Video (YouTube)**

- Docker in 100 Seconds — Fireship: https://www.youtube.com/watch?v=Gjnup-PuquQ
- Docker Compose in 100 Seconds — Fireship: https://www.youtube.com/watch?v=Qw9zlE3t8Ko
- Docker Tutorial for Beginners — TechWorld with Nana (largo, pero es LA referencia en video de la época)

**Orden de lectura sugerido:**
la sección de redes de este apéndice (es lo que más te habría dolido no
saber) → Compose networking oficial → Dockerfile best practices (el orden de
capas, 10 min bien invertidos) → el resto como consulta.
