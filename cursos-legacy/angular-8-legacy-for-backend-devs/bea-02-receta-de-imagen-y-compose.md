# 📎 Apéndice bea-02 — Receta de imagen y compose

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Consulta rápida · **3 horas**
> Usado por: be01, be02, be03, be07 · Versiones cubiertas: `maven:3.8-eclipse-temurin-8`, `mongo:4.0` → `mongo:7.0`, `postgres:16.9`, Docker Compose v2

**Esto no se lee de corrido.** Es la receta: se entra buscando el comando o el bloque de YAML que hace falta y se sale. Resuelve una sola cosa —**levantar la pila entera sin instalar un JDK, ni Maven, ni Mongo, ni `mongosh` en tu máquina**— y la resuelve completa: todo lo que necesitas está en esta página.

**Qué queda fuera:** la construcción de imágenes multi-etapa y la optimización de tamaño, que no hacen falta porque el laboratorio corre con la imagen de Maven directamente; Kubernetes; y cualquier discusión de arquitectura de contenedores. Si quieres empaquetar LabCore para producción de verdad, eso es otro tema y este apéndice no lo cubre.

> 🧭 **Autocontención.** Este es el único punto del track BE que toca contenedores, y es deliberadamente autosuficiente: no remite a ningún otro material. Si algo necesitaba una explicación larga, está resuelto dentro del `compose.yaml` y explicado aquí en dos líneas.

---

## Índice

- [1. Los cuatro comandos](#1-los-cuatro-comandos)
- [2. El `compose.yaml` completo](#2-el-composeyaml-completo)
- [3. El `.env`, y por qué importa tanto](#3-el-env-y-por-qué-importa-tanto)
- [4. El volumen `m2`: el que hace usable el ciclo](#4-el-volumen-m2-el-que-hace-usable-el-ciclo)
- [5. Entrar a la base: `mongo`, `mongosh` y el puerto 27017](#5-entrar-a-la-base)
- [6. Postgres, solo para `be08`](#6-postgres-solo-para-be08)
- [7. 🩺 Los errores que salen siempre](#7--los-errores-que-salen-siempre)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Los cuatro comandos

```bash
docker compose up -d          # levanta mongo + la API en el 3000
curl localhost:3000/health    # comprobar
docker compose logs -f api    # ver qué pasa
docker compose down           # parar (con -v borra la base)
```

Eso es todo lo que hace falta saber el 90 % de los días. El resto de esta página existe para el otro 10 %.

Dos avisos sobre el primero, porque son la causa de casi todas las dudas:

- **La primera vez tarda**, y puede tardar varios minutos. Maven está bajando el árbol de dependencias completo a un volumen nombrado. A partir de ahí no vuelve a hacerlo, y un arranque son segundos. Si te impacientas y cortas a la mitad, el volumen queda incompleto y la siguiente vez tarda otra vez: déjalo terminar.
- **`docker compose down -v` borra la base.** El `-v` elimina los volúmenes, y con ellos los datos que sembraste y todo lo que creaste desde la aplicación. Es lo que quieres cuando algo se corrompió y lo último que quieres el resto del tiempo.

---

## 2. El `compose.yaml` completo

Copiable tal cual. Vive en la raíz del proyecto, al lado del `db.json` y de `smoke.sh`.

```yaml
services:

  db:
    # La versión sale del .env. Esa indirección NO es comodidad: es lo que
    # hace posible la fase be07, donde subir la base cuatro versiones mayores
    # es cambiar una línea de un archivo que no está en el código fuente.
    image: mongo:${MONGO_TAG}
    volumes:
      - mongodata:/data/db
    # El 27017 NO se publica por defecto. Se publica bajo demanda, y aquí
    # abajo está cómo. Un puerto de base de datos abierto en el portátil es
    # una costumbre que conviene no coger.
    healthcheck:
      # Sin esto, la API arranca antes de que Mongo esté lista y falla en la
      # primera consulta con un error que apunta al sitio equivocado.
      # depends_on por sí solo espera a que el CONTENEDOR arranque, no a que
      # el proceso de adentro esté listo — y esa diferencia se cobra siempre.
      test: ["CMD", "mongosh", "--quiet", "--eval", "db.adminCommand('ping')"]
      interval: 5s
      timeout: 5s
      retries: 12
      start_period: 20s

  api:
    # Se corre con la imagen de Maven directamente, sin construir una imagen
    # propia. Para un laboratorio es lo correcto: cero Dockerfile que mantener
    # y recompilación instantánea al cambiar código.
    image: maven:3.8-eclipse-temurin-8
    working_dir: /app
    ports:
      - "3000:3000"
    volumes:
      # El proyecto entero, para que el SeedRunner pueda leer ../db.json y
      # para que editar un .java se vea sin reconstruir nada.
      - ".:/app"
      # La caché de Maven. Ver más abajo: es la línea que decide si este
      # laboratorio es usable o insoportable.
      - "m2:/root/.m2"
    environment:
      MONGO_URI: "mongodb://db:27017"
    depends_on:
      db:
        condition: service_healthy
    command: mvn -q -f server/pom.xml spring-boot:run

volumes:
  mongodata:
  m2:
```

**Detalles con intención**

- **El `healthcheck` de `mongosh` no funciona en `mongo:4.0`**, porque `mongosh` no existe hasta la 6.0. Para arrancar el track en 4.0, cambia ese `test` por `["CMD", "mongo", "--quiet", "--eval", "db.adminCommand('ping')"]`. Que el propio `compose.yaml` tenga que cambiar al subir de versión es, en sí mismo, un ejemplo perfecto de lo que `be07` viene a contar: **el shell desaparecido no rompe la aplicación, rompe las herramientas** — y un `healthcheck` es una herramienta.
- **`MONGO_URI` apunta a `db`, no a `localhost`.** Dentro de la red de compose, el nombre del servicio es el nombre de la máquina. Un `localhost` ahí adentro significa "este mismo contenedor", que es el error más frecuente al portar una configuración local.
- **`-f server/pom.xml`** porque el proyecto del alumno tiene el frontend en la raíz y el backend en `server/`. El directorio de trabajo es `/app` para que las rutas relativas del `SeedRunner` funcionen.
- **`mvn -q`** silencia el ruido de Maven; los logs que quedan son los de Spring, que son los que interesan.

---

## 3. El `.env`, y por qué importa tanto

```bash
# .env — La versión de la base vive AQUÍ, fuera del código fuente.
MONGO_TAG=4.0
```

Un archivo, una línea. Compose lo lee automáticamente si está en el mismo directorio, y sustituye `${MONGO_TAG}` en el `compose.yaml`.

> 🧠 **Esa línea es el material de una fase entera.** En `be07`, el alumno investiga un incidente cuyo `git log` está vacío: el sistema cambió de comportamiento y no hay ni un commit que lo explique, porque el cambio no está en el árbol de fuentes. **Está aquí.** Cuando llegues a esa fase, vuelve a esta sección.

Y la advertencia práctica de hoy: `.env` **sí se versiona** en este curso, porque es parte del laboratorio y no contiene secretos. En un proyecto real casi nunca se versiona, y ahí está el problema: *el archivo que decide qué versión de base corre en producción suele ser el único que no tiene historia*.

Tags conocidos de la cadena, comprobados contra el registro el **10/09/2026**:

| Escalón | Tag flotante | Último parche visible |
|---|---|---|
| El de 2019 | `mongo:4.0` | `4.0.28` |
| Primer salto | `mongo:4.4` | `4.4.30` |
| Segundo salto | `mongo:6.0` | `6.0.28` |
| Hoy | `mongo:7.0` | `7.0.41` |

> ⚠️ **Un tag flotante como `mongo:6.0` apunta hoy a un parche y mañana a otro.** Esa tabla va a estar desactualizada cuando la leas, y eso no es un defecto del apéndice: es el tema de `be07`. Compruébalo tú.

---

## 4. El volumen `m2`: el que hace usable el ciclo

```yaml
- "m2:/root/.m2"
```

Sin esa línea, cada `docker compose up` baja el árbol de dependencias entero desde cero: varios minutos, cada vez. Con ella, se baja una vez a un volumen nombrado que sobrevive a `docker compose down` y se reutiliza siempre.

Es la diferencia entre un laboratorio que se usa y uno que se abandona en la segunda sesión.

```bash
# Comprobar que la caché está haciendo su trabajo: la primera línea tarda,
# la segunda no.
time docker compose run --rm api mvn -f server/pom.xml -q dependency:resolve
time docker compose run --rm api mvn -f server/pom.xml -q dependency:resolve

# Y si alguna vez la caché se corrompe —pasa, y el síntoma es un error de
# checksum o un .jar de cero bytes—, se tira solo ese volumen:
docker compose down
docker volume rm "$(basename "$PWD")_m2"
```

> 💡 **`docker compose down` sin `-v` conserva los dos volúmenes.** Eso es exactamente lo que quieres: apagar la pila al terminar el día sin perder ni los datos ni la caché.

---

## 5. Entrar a la base

El 27017 **no está publicado** en el `compose.yaml` de arriba, y no hace falta publicarlo para trabajar: se entra desde dentro del contenedor.

```bash
# En mongo:4.0 y 4.4 — el shell se llama "mongo".
docker compose exec db mongo labcore

# En mongo:6.0 y 7.0 — se llama "mongosh". El "mongo" ya no existe.
docker compose exec db mongosh labcore

# Una consulta suelta, sin entrar al shell interactivo:
docker compose exec db mongosh labcore --quiet --eval 'db.patients.countDocuments()'
```

Para cargar un volcado desde tu máquina, el `-T` es obligatorio y se olvida siempre:

```bash
# El -T desactiva la asignación de TTY. Sin él, la redirección "<" no llega
# al proceso de adentro y el comando se queda colgado sin decir nada.
docker compose exec -T db mongoimport \
  --db labcore --collection patients --drop --jsonArray < dump/patients.json
```

**Si de verdad necesitas conectarte con una herramienta gráfica** —Compass, o el cliente de tu editor—, publica el puerto bajo demanda y solo mientras lo uses. Un archivo aparte, sin tocar el principal:

```yaml
# compose.override.yaml — compose lo lee automáticamente si existe.
services:
  db:
    ports:
      - "27017:27017"
```

```bash
docker compose up -d db        # ahora sí está en localhost:27017
mv compose.override.yaml _off  # y cuando termines, se desactiva
```

---

## 6. Postgres, solo para `be08`

El read-model de la última fase, y nada más. **No participa del contrato, no lo toca `smoke.sh`, y no recibe escrituras de la aplicación.** Se añade al mismo `compose.yaml`:

```yaml
  readmodel:
    image: postgres:16.9
    environment:
      POSTGRES_DB: labcore_read
      POSTGRES_USER: labcore
      POSTGRES_PASSWORD: labcore
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U labcore -d labcore_read"]
      interval: 5s
      timeout: 5s
      retries: 10
```

```bash
docker compose exec readmodel psql -U labcore -d labcore_read
```

Y las credenciales literales en el YAML, que en un proyecto real serían un problema: aquí son deliberadas y el apéndice lo declara. **Es un laboratorio desechable en tu portátil.** El día que esto se pareciera a producción, esas tres líneas serían lo primero que habría que sacar.

---

## 7. 🩺 Los errores que salen siempre

Entra por el síntoma.

| Síntoma | Causa | Qué hacer |
|---|---|---|
| `port is already allocated` en el 3000 | `npm run mock` sigue corriendo | Apágalo. Los dos quieren el mismo puerto, y eso **no es un defecto**: es el diseño del track |
| La API arranca y falla en la primera consulta | Mongo no estaba lista; falta el `healthcheck` o el `condition: service_healthy` | El bloque del `compose.yaml`. `depends_on` a secas espera al contenedor, no al proceso |
| `executable file not found in $PATH: mongo` | Estás en 6.0 o superior | `mongosh`. Y revisa el `healthcheck`, que también lo usa |
| La primera vez tarda una eternidad | Maven bajando el árbol al volumen `m2` | Déjalo terminar. Solo pasa una vez |
| Un `.jar` corrupto o un error de checksum | La caché de Maven se corrompió al cortar una descarga | Borrar el volumen `m2` y dejar que se rehaga |
| El comando con `<` se queda colgado | Falta el `-T` en `docker compose exec` | Ponlo |
| Cambio un `.java` y no se ve | `spring-boot:run` no recompila solo | Reinicia el servicio: `docker compose restart api` |
| `connection refused` a `localhost:27017` desde la API | Dentro de la red, el nombre es `db` | `MONGO_URI: mongodb://db:27017` |
| Los datos desaparecieron | Alguien hizo `docker compose down -v` | Volver a sembrar. Y `-v` solo cuando de verdad se quiera |

---

## 🧭 Cuándo usar qué

| Situación | Comando | Por qué |
|---|---|---|
| Empezar el día | `docker compose up -d` | Segundos, con la caché ya hecha |
| Ver qué está pasando | `docker compose logs -f api` | Los logs de Spring en vivo, con el `X-Request-Id` de `be01` |
| Cambié código Java | `docker compose restart api` | Más rápido que bajar y subir la pila entera |
| Cambié el `.env` o el YAML | `docker compose up -d` otra vez | Compose recrea solo lo que cambió |
| Terminar el día | `docker compose down` | Conserva datos y caché |
| Empezar de cero de verdad | `docker compose down -v` | Borra todo. Habrá que volver a sembrar |
| Entrar a la base | `exec db mongo` / `exec db mongosh` | Según la versión. Ver arriba |
| Correr algo de Maven | `docker compose run --rm api mvn …` | `--rm` para que no deje contenedores muertos |

---

## ⚠️ Advertencias

**El JDK 8 nativo para macOS aarch64 no existe, y da igual.** Es la duda que tiene todo el mundo con un Mac de Apple Silicon, así que la respuesta directa: no hay una distribución oficial de JDK 8 para macOS/arm64, pero **sí la hay para Linux/arm64**, que es lo que corre dentro del contenedor. Como en este track todo pasa por Docker, la limitación no te afecta en absoluto. No instales nada.

**Todas las imágenes de esta página corren arm64 nativo.** Comprobado el **8/09/2026** sobre Docker Desktop 29.6.2 en un host `aarch64`: `eclipse-temurin:8-jdk` (runtime, `1.8.0_502`), `maven:3.8-eclipse-temurin-8` (runtime), `mongo` 3.6/4.0/4.2/4.4/6.0/7.0/8.0 (registro, y la 4.0 también en runtime: `4.0.28`), y `postgres:16.9` (registro y runtime). **Nada necesita emulación**, y si ves un aviso de plataforma, algo está mal en tu configuración y no en la receta.

**El puerto 3000 es del contrato, no una preferencia.** El frontend apunta ahí con `environment.apiUrl` y el frontend no se toca. Cambiarlo en el `compose.yaml` rompe la aplicación entera.

**Este compose no es un despliegue.** Credenciales literales, sin límites de recursos, sin política de reinicio, sin respaldos y sin usuario no privilegiado. Es un laboratorio en tu portátil y está bien que lo sea; lo que no está bien es copiarlo a un servidor.

---

## 📚 Referencias

- Docker Compose — especificación del archivo, versión 2: https://docs.docker.com/reference/compose-file/
- `healthcheck` y `depends_on` con `condition`: https://docs.docker.com/reference/compose-file/services/#healthcheck
- Sustitución de variables y el archivo `.env`: https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/
- Volúmenes nombrados: https://docs.docker.com/engine/storage/volumes/
- Imagen oficial de MongoDB, con sus tags y variables: https://hub.docker.com/_/mongo
- Imagen oficial de Maven: https://hub.docker.com/_/maven
- Imagen oficial de PostgreSQL: https://hub.docker.com/_/postgres
- `mongoimport`: https://www.mongodb.com/docs/database-tools/mongoimport/
- `mongosh`, y en qué se diferencia del shell antiguo: https://www.mongodb.com/docs/mongodb-shell/

> ⚠️ Las URLs y los contenidos cambian. Y con las imágenes oficiales, además, cambia lo que hay dentro: el ejemplo de `mongosh` que no existe en `mongo:4.0` es exactamente eso ocurriendo dentro de este mismo apéndice.

---

## 🧪 Ejercicios (8)

1. Levanta la pila con `MONGO_TAG=4.0`, comprueba `curl localhost:3000/health`, y anota cuánto tardó el primer arranque y cuánto el segundo.
2. Con la pila arriba, intenta arrancar `npm run mock`. Anota el error exacto y por qué es el comportamiento correcto.
3. Quita el `healthcheck` del servicio `db` y arranca de cero (`down -v` primero). Reprodúcelo hasta que la API falle en la primera consulta y anota el mensaje. Vuelve a ponerlo.
4. Mide el efecto del volumen `m2`: quítalo, arranca, cronometra; ponlo, arranca dos veces, cronometra las dos. Escribe los tres números.
5. Entra a la base y cuenta los documentos de `patients` en 4.0 con `mongo`. Después sube a `MONGO_TAG=6.0`, repite el mismo comando, y anota el error. Resuélvelo.
6. Publica el 27017 con un `compose.override.yaml`, conéctate con una herramienta gráfica, y después desactívalo. Comprueba que el archivo principal no cambió.
7. Carga un archivo JSON con `mongoimport` **sin** el `-T`. Observa qué pasa. Repítelo con `-T`.
8. Añade el servicio `readmodel` de Postgres, comprueba que arranca sano, y confirma con `grep` que `smoke.sh` no lo menciona ni una vez.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida, y el `compose.yaml` y el `.env` que describe los escribe **be01** —y los modifica `be07` al subir la versión, y `be08` al añadir Postgres—, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be01: …`, `be07: …`). Si haces una medición que quieras conservar —los tiempos del ejercicio 4, por ejemplo—, va en el mensaje de un tag anotado `ej/bea-02/4`. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.
