# 📎 Apéndice bea-02 — Receta de imagen y compose

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **3 horas**
> Usado por: **be01**, **be04** · Versiones cubiertas: `php:7.4-cli`, `postgres:16.9`, Composer 2, Docker Compose v2
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve un problema y sólo uno: **levantar toda la pila del track con cuatro comandos, sin instalar PHP, Composer ni `psql` en tu máquina.**

**Qué queda fuera:** nginx y php-fpm —el servidor embebido basta para un laboratorio y meter un servidor web delante distrae del tema—; las construcciones multi-etapa; Kubernetes; y cualquier cosa que dependa de infraestructura que no tengas. Este apéndice es **autocontenido a propósito**: no remite a ningún otro curso del catálogo, y si algo necesita explicación larga va resuelto en el archivo y explicado en dos líneas.

---

## Índice

- [Los cuatro comandos](#los-cuatro-comandos)
- [`compose.yaml`, completo](#composeyaml-completo)
- [El `.env`, y por qué la versión de la base vive ahí](#el-env-y-por-qué-la-versión-de-la-base-vive-ahí)
- [`Dockerfile`, completo](#dockerfile-completo)
- [⭐ La cápsula del tiempo: el día que la imagen se murió](#-la-cápsula-del-tiempo-el-día-que-la-imagen-se-murió)
- [Publicar el 5432 bajo demanda](#publicar-el-5432-bajo-demanda)
- [Los tres errores que salen siempre](#los-tres-errores-que-salen-siempre)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-7)

---

## Los cuatro comandos

Son estos y no hay un quinto:

```bash
docker compose up -d          # 👁️/✍️ levanta postgres + la API en el 3000
curl localhost:3000/health    # 👁️ comprobar que está vivo
docker compose logs -f api    # 👁️ ver qué pasa — déjalo en una terminal aparte
docker compose down           # ✍️ parar. Con -v borra ADEMÁS el volumen de datos
```

El tercero no es opcional aunque lo parezca. En este track **el log del contenedor es lo que la consola del navegador era en el track base**: la mitad de los errores de PHP no llegan a la respuesta HTTP, llegan ahí.

Y el cuarto tiene una trampa que cuesta una hora exactamente una vez: `docker compose down` conserva los datos, `docker compose down -v` **borra el volumen**. Desde be03 eso significa perder la base sembrada. No es grave —se vuelve a sembrar—, pero conviene que sea una decisión y no un dedo.

---

## `compose.yaml`, completo

Este archivo está probado y es copiable tal cual. Va en la raíz del proyecto, junto al `package.json` del frontend.

```yaml
# compose.yaml — la pila completa del track BE.
# Dos servicios: la base, y la API que la usa. Nada más.

services:
  db:
    # La versión NO está escrita aquí: viene del .env. Esa indirección es lo
    # que hace posible la fase be04 — y es, de paso, la razón por la que un
    # cambio de versión de la base no deja rastro en el código fuente.
    image: postgres:${POSTGRES_TAG}
    environment:
      POSTGRES_PASSWORD: certcore
      POSTGRES_DB: certcore
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      # pg_isready responde cuando el servidor acepta conexiones, que es varios
      # segundos después de que el contenedor esté "arriba". Sin esto, la API
      # arranca antes que la base y falla la primera petición de cada mañana.
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 2s
      retries: 15

  api:
    build: ./docker/php
    ports:
      - "3000:3000"
    volumes:
      # El código se monta, no se copia: editas en tu editor y la siguiente
      # petición ya usa el archivo nuevo. En PHP eso sale gratis porque no hay
      # proceso que reiniciar — cada petición relee lo que haya en disco.
      - ".:/app"
    environment:
      DB_DSN: "pgsql:host=db;dbname=certcore"
      # El servidor embebido es de un solo proceso. Con cuatro workers, una
      # petición colgada (CHAOS=timeout) deja de tumbar el laboratorio entero.
      # Disponible desde PHP 7.4.0, que es justo la versión que corre aquí.
      PHP_CLI_SERVER_WORKERS: 4
    depends_on:
      db:
        # No "cuando el contenedor arranque": cuando el healthcheck esté verde.
        condition: service_healthy
    command: php -S 0.0.0.0:3000 -t server/public

volumes:
  pgdata:
```

**Detalles con intención**

- **El puerto es el 3000 y no se negocia.** Es el del mock, y la regla del track es que el frontend no se entere del cambio. Si algún día necesitas el 3000 para otra cosa, para otra cosa — no para esto.
- **`depends_on: service_healthy` y no `depends_on: db` a secas.** La forma corta espera a que el contenedor exista, no a que la base acepte conexiones. La diferencia son diez segundos y un error intermitente al arrancar, que es el peor tipo de error.
- **El volumen tiene nombre (`pgdata`), no es un *bind mount*.** Deliberado: en be04 vas a cambiar la versión mayor de Postgres, y la forma limpia de hacerlo en un laboratorio es **volumen nuevo**, no `pg_upgrade`. Con un directorio del host montado eso sería mucho más incómodo.

---

## El `.env`, y por qué la versión de la base vive ahí

```bash
# .env — configuración del laboratorio.
#
# La versión de la base de datos vive AQUÍ, fuera del código fuente. Eso no es
# una decisión de este curso: es como funciona en la vida real, y es la razón
# por la que en be04 vas a investigar un incidente cuyo `git log` está vacío.
POSTGRES_TAG=16.9
```

Guarda esa línea en la cabeza. En be04 el sistema se va a romper por un cambio que **no está en el árbol de fuentes**, `git blame` no va a decir nada, y el motivo es este archivo.

> 🧠 **Lo que no está en el repositorio también despliega.** Un `.env`, una variable del entorno gestionado, un tag de imagen. El día que un incidente no aparezca en ningún log de git, la pregunta correcta no es *"¿quién lo tocó?"*, es *"¿qué parte de esto no es código?"*.

---

## `Dockerfile`, completo

Va en `docker/php/Dockerfile`. Léelo antes de copiarlo: la primera instrucción `RUN` parece una rareza y es el contenido más valioso de este apéndice.

```dockerfile
# docker/php/Dockerfile
FROM php:7.4-cli

# Las fuentes de apt se reescriben apuntando a snapshot.debian.org, congeladas
# en la fecha del build de la propia imagen. La explicación entera está abajo,
# en "La cápsula del tiempo", y hay que leerla: sin esto, este build NO FUNCIONA.
RUN printf 'deb http://snapshot.debian.org/archive/debian/20221114T000000Z bullseye main\ndeb http://snapshot.debian.org/archive/debian-security/20221114T000000Z bullseye-security main\n' > /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends libpq-dev unzip \
 && docker-php-ext-install pdo_pgsql \
 && rm -rf /var/lib/apt/lists/*

# Composer se COPIA desde su propia imagen. No se instala, no se descarga con
# un script, y sobre todo: no se instala en la máquina del alumno.
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app
```

Cuatro decisiones y sus porqués:

- **`php:7.4-cli` y no `7.4-apache` ni `7.4-fpm`.** El servidor embebido de PHP basta para un laboratorio, y mete una variable menos entre tu código y el error que estás depurando. Apache o fpm significan un archivo de configuración más que puede estar mal, y en este track ya hay bastantes.
- **`pdo_pgsql` y nada más.** Es la única extensión que el track necesita. Cada extensión de más es un minuto más de construcción y una superficie más que mantener.
- **`libpq-dev` sí, `postgresql-client` no.** Lo primero es para compilar la extensión; `psql` no hace falta en el contenedor de PHP porque lo tienes en el de la base (`docker compose exec db psql -U postgres certcore`).
- **`COPY --from=composer:2`.** Es la forma limpia de tener Composer sin instalar nada: se copia un binario de otra imagen. Si algún día lo ves resuelto con `curl | php`, es la versión de 2016 de esta misma línea.

---

## ⭐ La cápsula del tiempo: el día que la imagen se murió

Esto no es un ejemplo didáctico. Es **la muerte de una imagen en directo**, capturada el día que ocurrió, con su mensaje literal.

El **8 de septiembre de 2026**, el primer `docker build` de este track falló así:

```
E: Release file for http://deb.debian.org/debian-security/dists/bullseye-security/InRelease
   is expired (invalid since 1d 6h 39min 54s)
```

Léelo despacio: *inválido desde hace 1 día, 6 horas y 39 minutos*. El **LTS de Debian 11 “bullseye” —la base de `php:7.4-cli`— había caducado el día anterior.** No un mes antes, no un año: el día anterior. La imagen llevaba años construyéndose sin problema y dejó de hacerlo esa tarde.

El primer reflejo —decirle a apt que ignore la fecha— no basta:

```bash
apt-get -o Acquire::Check-Valid-Until=false update    # pasa la validación...
apt-get install libpq-dev                             # ...y ahora:
#   404  Not Found
```

Los paquetes ya no están: se movieron a `archive.debian.org`. La distribución no expiró sin más, **se mudó**.

Y la solución venía escrita **dentro de la propia imagen**. Si abres su `/etc/apt/sources.list`:

```bash
docker run --rm php:7.4-cli cat /etc/apt/sources.list
```

verás, entre las fuentes activas, **sus propias fuentes de `snapshot.debian.org` comentadas**, fijadas al `20221114T000000Z` — el día en que esa imagen se construyó. El mantenedor las dejó puestas, comentadas, para el día en que hicieran falta. Descomentarlas —que es lo que hace el `printf` del Dockerfile— da un apt **determinista**: siempre los mismos paquetes, las mismas versiones, inmune al paso del tiempo.

> 🧠 **La imagen traía escrita su propia cápsula del tiempo, y nadie la lee nunca.**

Hay un detalle que redondea la historia y conviene mirar de frente: **el último push de `php:7.4-cli` es del 15 de noviembre de 2022**, un día después de la fecha del snapshot. La imagen se congeló, literalmente, el día que PHP 7.4 llegó a su fin de vida. Lo que estás construyendo no es una simulación de un sistema abandonado: **es un sistema abandonado, con fecha de defunción en los metadatos**.

⚠️ **Nota de mantenimiento, porque este apéndice envejece por diseño.** El día de la prueba, `archive.debian.org/debian-security` todavía **no** servía `bullseye-security`. Si `snapshot.debian.org` llegara a fallar o a retirar ese snapshot, el plan B es usar sólo `bullseye main` desde el archivo:

```dockerfile
RUN printf 'deb http://archive.debian.org/debian bullseye main\n' > /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends libpq-dev unzip \
 && docker-php-ext-install pdo_pgsql
```

Pierdes los parches de seguridad de bullseye, que en un laboratorio local es aceptable y **en producción no lo sería nunca**. Si algún día tienes que usar el plan B, escríbelo en `bea-10` como deuda, no como detalle.

---

## Publicar el 5432 bajo demanda

Por defecto la base **no** está publicada: sólo la ve el contenedor de la API, a través de la red interna de compose. Es lo correcto — un puerto menos expuesto en tu máquina — y además obliga a usar `docker compose exec`, que es como vas a trabajar el 90% del tiempo:

```bash
docker compose exec db psql -U postgres certcore       # 👁️/✍️ psql, sin instalar psql
```

Cuando quieras conectar un cliente gráfico o un `psql` de tu máquina, añade la línea y recrea sólo ese servicio:

```yaml
  db:
    ports: ["5432:5432"]     # ✍️ sólo mientras lo necesites
```

```bash
docker compose up -d db      # ✍️ recrea el contenedor de la base con el puerto abierto
```

Vuelve a quitarlo después. La contraseña del laboratorio está en claro en el `compose.yaml` y eso es aceptable **mientras no haya un puerto abierto al mundo**; en cuanto lo hay, deja de serlo.

---

## Los tres errores que salen siempre

**1. `could not translate host name "db"`**

*Qué pasó:* tu código intenta conectar a la base desde fuera de la red de compose —desde tu máquina, o desde un contenedor que no es de esta pila—, donde el nombre `db` no significa nada.
*Qué hacer:* desde dentro, `db`; desde tu máquina con el 5432 publicado, `localhost`. Y si sale **dentro** del contenedor de la API, casi siempre es que la base todavía no aceptaba conexiones: revisa que `depends_on` tenga `condition: service_healthy`.

**2. `SQLSTATE[08006] ... SCRAM authentication requires libpq version 10 or above`**

*Qué pasó:* desde PostgreSQL 14 el valor por defecto de `password_encryption` es `scram-sha-256`, y un cliente con `libpq` anterior a la 10 no sabe hablarlo.
*Qué hacer:* nada, con esta receta. La `libpq 13` que trae bullseye **sí habla SCRAM** contra un PG 16.9 — se verificó el 8/09/2026 y era la comprobación que decidía si el stack entero era viable. Si el error aparece, es que estás usando otra imagen base; no bajes la seguridad de la base para arreglarlo. `bea-05` tiene el detalle.

**3. El build falla con `Release file ... is expired` o con `404`**

*Qué pasó:* copiaste el `Dockerfile` de un tutorial en vez del de aquí. Es el error de la cápsula del tiempo, y ahora ya sabes por qué pasa y por qué no se arregla ignorando la fecha.
*Qué hacer:* usa el `RUN` de arriba, entero, tal cual.

---

## 🧭 Cuándo usar qué

| Situación | Qué usar | Por qué |
|---|---|---|
| Quiero ver qué está pasando ahora mismo | `docker compose logs -f api` 👁️ | La mitad de los errores de PHP no llegan a la respuesta HTTP |
| Quiero una terminal dentro del contenedor | `docker compose exec api bash` 👁️ | El contenedor tiene PHP y Composer; tu máquina no, y así queda |
| Quiero correr `psql` | `docker compose exec db psql -U postgres certcore` 👁️/✍️ | Evita publicar el 5432 |
| Cambié el `Dockerfile` | `docker compose up -d --build api` ✍️ | Sin `--build` sigue corriendo la imagen vieja y vas a depurar un fantasma |
| Cambié código PHP | **Nada** | El código está montado y PHP relee en cada petición |
| Cambié el `.env` | `docker compose up -d` ✍️ | Compose sustituye las variables al crear el contenedor, no al vuelo |
| Quiero empezar la base de cero | `docker compose down -v && docker compose up -d` ✍️ | Es el camino de be04 para cambiar de versión mayor |
| Quiero saber qué versión de base está corriendo | `docker compose exec db postgres --version` 👁️ | Más fiable que mirar el `.env`: te dice lo que corre, no lo que pediste |

---

## ⚠️ Advertencias

**Este laboratorio no es un despliegue y no se le parece.** La contraseña está en claro, el servidor es el embebido de PHP, el código está montado desde el host y no hay TLS por ningún lado. Todo eso es correcto para aprender y sería inaceptable en producción. Cuando en be07 costees opciones, no cuentes este `compose.yaml` como "ya tenemos contenedores": lo que tienes es un laboratorio.

**La imagen `php:7.4-cli` no va a recibir más actualizaciones.** Está congelada desde noviembre de 2022 y eso incluye los parches de seguridad del sistema operativo de base. En el laboratorio da igual; en `bea-08` esa frase es el punto de partida de una conversación seria.

**En Apple Silicon no hace falta emulación.** `php:7.4-cli` publica `linux/arm64/v8` y `postgres:16.9` también; el runtime completo se verificó en `aarch64` el 8/09/2026. Si en algún momento ves `CrashLoopBackOff`, advertencias de plataforma o una lentitud rarísima, no es este track: es que estás tirando de una imagen que no tiene tu arquitectura.

---

## 📚 Referencias

- https://hub.docker.com/_/php — los tags de la imagen oficial. Fíjate en la fecha del último push de `7.4-cli`: **2022-11-15**.
- https://hub.docker.com/_/postgres — ídem para `postgres:16.9`.
- https://snapshot.debian.org/ — el archivo histórico de Debian, que es lo que hace determinista el `apt-get` de arriba.
- https://www.debian.org/releases/bullseye/ — el estado de soporte de Debian 11, que es la fecha que mató el build.
- https://docs.docker.com/reference/compose-file/ — la referencia del formato de compose, en particular `depends_on` con `condition` y `healthcheck`.
- https://www.php.net/manual/es/features.commandline.webserver.php — el servidor embebido y `PHP_CLI_SERVER_WORKERS`.

> ⚠️ Los enlaces pueden estar desactualizados; verifícalos. Y hay uno que **va a envejecer seguro**: la receta de `snapshot.debian.org` depende de que ese servicio siga sirviendo el snapshot del `20221114T000000Z`. El plan B está escrito arriba; si tienes que usarlo, anótalo como deuda.

---

## 🧪 Ejercicios (7)

1. Levanta la pila con los cuatro comandos y pega la salida de `curl -s localhost:3000/health`. Después para con `docker compose down` (sin `-v`), vuelve a levantar, y comprueba que la base conserva lo que tuviera.
2. Corre `docker run --rm php:7.4-cli cat /etc/apt/sources.list` y **encuentra las líneas comentadas del snapshot**. Copia la fecha que traen. ¿Coincide con la del `Dockerfile` de este apéndice?
3. Rompe el build a propósito: cambia la primera línea del `RUN` por `deb http://deb.debian.org/debian bullseye main` y construye. Pega el error literal. Después arréglalo y anota cuánto tardaste.
4. Quita `condition: service_healthy` del `depends_on`, levanta la pila desde cero (`down -v` primero) y pide `/health` inmediatamente. Repítelo tres veces. ¿Falla siempre, a veces, o nunca? Explica por qué "a veces" es la peor respuesta posible.
5. Publica el 5432, conéctate con un cliente de tu máquina, y vuelve a quitarlo. Después responde en dos líneas: ¿qué cambió en la superficie expuesta de tu laptop mientras estuvo abierto?
6. Con `PHP_CLI_SERVER_WORKERS` puesto en `1`, arranca con `CHAOS=timeout CHAOS_RATE=1`, cuelga una petición y pide `/health` desde otra terminal. Sube a `4` y repite hasta agotarlos. Anota el número exacto de peticiones que hacen falta para tumbar el laboratorio.
7. Cambia `POSTGRES_TAG` a `15.7`, levanta con el volumen existente, y pega el error. **No lo arregles todavía**: ese error es el tema central de `bea-05` y la fase be04 lo va a usar entero. Anota el mensaje literal y vuelve a `16.9`.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida, y los archivos que describe —`compose.yaml`, `docker/php/Dockerfile`, `.env`— los crea la fase desde la que llegaste, así que se commitean con su prefijo (`be01: …`). La única excepción razonable es el `.env`, que **no se versiona**: si tu proyecto lo ignora en `.gitignore`, deja en su lugar un `.env.example` con `POSTGRES_TAG=16.9` y commitéalo, porque en be04 ese archivo es la prueba del delito. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
