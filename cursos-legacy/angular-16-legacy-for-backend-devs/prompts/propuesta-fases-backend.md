# 🗺️ Propuesta de fases, apéndices y alcance — Track BE

Documento de encuadre del **track opcional de backend** del tutorial *Angular 16
Legacy — CertCore, inspecciones y certificaciones*. Define por qué existe, qué
cobra, cuánto pesa, **qué versiones congela** y cómo se reparte en fases y
apéndices.

> **Estado:** propuesta, pendiente de revisión. Es el **primer documento
> versionado** del track y el **único registro** de su diseño: el razonamiento
> que lo produjo se consolidó en §0, y las notas sueltas donde se llevó no
> estaban versionadas ni se conservan.
> **Fecha:** 9 de septiembre de 2026.
> **Track base afectado:** ninguno en su contenido. Las fases 0–14 no cambian ni
> una línea de código; sí hay adiciones de encuadre en siete documentos (§10), y
> **una de ellas toca la ficción publicada** — ver §10.2, que es la única
> decisión de este documento que hay que aprobar explícitamente.
> **Fuentes de verdad que respeta:** `prompts/alcance-del-proyecto.md`,
> `prompts/guia-de-estilo-y-convenciones.md`, `prompts/plantillas-de-capitulo.md`,
> `00-historia-del-sistema.md`, `00-convencion-de-git-y-tags.md`.
> **⚠️ = sin verificar.** Lo verificado lleva su medición y su fecha.

---

## 🕰️ 0. De dónde sale esto: historial de la conversación

El track no se diseñó de un tirón: salió de once rondas de discusión que se
llevaron en notas de trabajo sin versionar, que ya no existen; **lo que quedó de
ellas es este apartado**, y por eso conserva **el razonamiento que descartó
cosas**, que es la mitad del valor: sin él, dentro de seis meses alguien va a
volver a proponer Dart, o Sinatra, o Symfony.

### 0.1 La bisagra: qué clase de track es este

La primera decisión no fue de tecnología, fue de signo. Un track de backend colgado
de un curso de frontend se escribe casi solo como **redención**: el mock era un
atajo declarado, y las fases del backend existirían para cobrar —una por una— las
deudas 💸 que el track base anunció y no podía pagar desde el navegador.

Ese molde funciona y aquí se descartó a propósito, porque daba un curso de
tecnología con la deuda de excusa. La inversión de signo es lo que funda este
track:

> 🧠 **El backend no viene a redimir nada. El backend es la escena del crimen.**
> El contenido no es *"cómo se hace bien"*, es *"qué haces el lunes cuando lo que
> está mal es una decisión de arquitectura de hace ocho años, el sistema factura,
> y no hay presupuesto para deshacerla"*.

Y su corolario: **el desenlace honesto casi nunca es migrar.** Es estabilizar,
acotar el daño, y escribir el documento que defiende la decisión.

### 0.2 Qué clase de deuda cobra: ausencia de revisión

Se descartó desde temprano que el eje fuera el **modelo de datos** —*"elegimos mal
la base y ahora la integridad no la sostiene nadie"*—. Es una lección legítima, y es
otra: se resuelve mirando datos. Este track quería la que casi ningún material
técnico trata, la que se resuelve mirando **quién decidió, cuándo, y quién no
volvió a revisarlo**. La ficha del track, entonces:

| | Angular 16 · **CertCore** |
|---|---|
| **El pecado** | **Ausencia de revisión** |
| **El actor** | El converso a Laravel |
| **Cómo se decidió** | Nadie lo decidió: se eligió para *un servicio* y jamás se revisó |
| **Stack** | PHP 7.4 + Lumen + `postgres:16.9` |
| **Fallo insignia** | **Familiaridad falsa** |
| **Entregable final** | ***Assessment* de riesgo con números** |

Ese eje es el que hace único al track: no enseña sobre **datos**, enseña sobre
**personas y ecosistema**, una dimensión que decide la mitad de los proyectos
reales y que casi nunca se practica.

### 0.3 Los cinco candidatos, y por qué ganó Lumen

La pregunta de la segunda ronda fue *"¿qué tecnología pesa como decisión por
moda?"*, y el hallazgo es que **"boom que salió caro" no es un fallo, son cinco**.
Elegir candidato es elegir lección, no elegir logo.

| Fallo | Candidato | La frase que lo resume | Veredicto |
|---|---|---|---|
| **Familiaridad falsa** | **Lumen** | *"Todos creen que saben esto, y se equivocan"* | ✅ **Elegido** |
| Escasez de gente | Dart + Conduit | *"Nadie sabe esto y nadie quiere aprenderlo"* | Suplente. El fallo es solo de RRHH: produce vacantes, no bugs |
| Riesgo legal | Scala + Play + Akka | *"Una licencia cambió y tu arquitectura quedó ilegal"* | Mejor historia, peor laboratorio: el coste **por iteración** lo tumba |
| Deuda de autor | Ruby + Sinatra | *"Lo escribió un esteta y se fue"* | Ganó una ronda y perdió la siguiente: coste de laboratorio y solapamiento con `docker-container-legacy` |
| Abandono del vendor | LoopBack 3 | *"La v4 existe, pero migrar es reescribir"* | Boom tibio, la historia da poco |
| Muerte del vendor | RethinkDB | *"Era excelente y aun así murió"* | Compite en el eje de datos, que no es el de este track (§0.2) |
| **Grupo de control** | Symfony / Rails | *"Súbelo, hay camino"* | Sanos y con disciplina de upgrade. **No sostienen ocho fases** — pero sirven de vara de medir (`bea-09`) |

**Por qué Lumen y no Dart**, que fue el primer candidato: el problema de Dart es de
RRHH —una vacante abierta nueve meses—. El problema de Lumen es de RRHH **y
forense**: *produce bugs*, y bugs del tipo exacto que este curso ya enseña a cazar.

> 🧠 **El problema de Lumen no es que nadie lo conozca. Es que todos creen que lo
> conocen.** Llega un dev de Laravel, se siente en casa, pega una respuesta de
> StackOverflow que funciona en Laravel — y en Lumen **falla en silencio**, porque
> el contenedor, los facades, el middleware y la capa de eventos no son los
> mismos. No revienta: se comporta distinto.

Un curso cuya identidad es *"reproduce el bug desde un ticket vago"* saca más de una
tecnología que **produce** bugs que de una que produce una vacante.

**Por qué Ruby/Sinatra perdió tras haber ganado.** La objeción fue de laboratorio y
es decisiva:

> 🧭 **Las gemas de Ruby compilan; los paquetes de Composer no.** `ruby:2.7` existe
> y hasta trae arm64 — Ruby nunca fue el problema. El problema son `nokogiri`, `pg`,
> `mysql2`, `bcrypt`: extensiones nativas sin binario preconstruido para ARM. Eso ya
> está contado, y mejor, en `docker-container-legacy`, y como este track debe ser
> **autocontenido**, no bastaría con enlazar: habría que reenseñarlo. Dos fases
> gastadas en repetir otro curso.

### 0.4 La cronología, y la deuda que deja

La fecha del backend se discutió aparte de su tecnología, y la conclusión no es la
intuitiva. Se planteó fecharlo junto al sistema —una API de 2019–2021 bajo un
frontend de 2021— y se descartó, porque **la edad del frontend no ordena la edad
del backend**. El quiasmo es deliberado y es la mejor idea del diseño:

| | Sistema (frontend) | Backend v1 |
|---|---|---|
| CertCore | **2021** (→ migrado 2024) | **2016–2018** |

> 🧠 **CertCore es la app moderna con el backend viejo.** Un frontend de 2021
> migrado en 2024, hablando con una API de 2016. Eso es lo que pasa de verdad en
> las empresas, y explica de una sola vez por qué la forma del contrato es rara.

**La rima de disciplina**, que es la razón de fondo:

> 🧠 `strict: true` con null / undefined / campo ausente como tres cosas distintas
> ↔ **Postgres con tipos declarados, `NOT NULL` y `NULL`**.

El curso enseña la misma pregunta de disciplina en sus dos capas. La familia de
bugs que el track base caza —`null` no es `undefined` no es campo ausente— es
literalmente la conversación de `NULL` en SQL, vista desde el navegador. Fechar el
backend en 2019 con otro motor rompía esa rima.

**Y la rima forense:** los ejercicios 🧬 del track base preguntan *"¿este archivo es
de 2021 o de 2024?"* — estratos **por fecha**. Lumen aporta estratos **por
procedencia**. Mismo método, otro eje. Ver `be02`.

**Lo que esa cronología cuesta, y hay que pagarlo aquí.** Un Lumen 6 + PHP 7.4 de
2019 encajaría sin retoques bajo un frontend de 2019. Fecharlo en 2016 obliga a
sostener que **el backend es más viejo que el sistema tal como el README lo
publicó**. Esa deuda es real, no se disuelve ignorándola, y §10.2 la salda por
escrito.

### 0.5 Verificaciones ejecutadas

Todo sobre Docker Desktop 29.6.2, host `aarch64`, el **8 de septiembre de 2026**.
Ver §5 para la tabla completa. Los dos resultados que decidieron contenido:

1. **La verificación bloqueante pasa.** El `pdo_pgsql` de `php:7.4` habla SCRAM
   con un Postgres 16.9 sin tocar nada: la `libpq 13` de bullseye lo soporta. Sin
   eso, el stack entero se caía.
2. **La imagen se murió mientras se hablaba de ella.** El LTS de Debian 11
   bullseye —base de `php:7.4-cli`— caducó **el día anterior a la prueba**, y el
   primer `docker build` falló con el mensaje literal. La solución venía escrita
   dentro de la propia imagen. Ver §5.4: es contenido, no un accidente.

---

## 🧭 1. En una frase

Ocho fases opcionales que **construyen el backend de 2016 que CertCore siempre
tuvo y nadie del curso había visto** —PHP 7.4, Lumen y un Postgres que alguien
externo fue actualizando cuatro veces—, lo ponen en el puerto `3000` en lugar del
mock, y usan ese sistema para **medir** lo que cuesta una tecnología que era
correcta el día que se eligió y hoy es un pasivo.

La señal de éxito no es un backend bonito. Es esta, y se verifica:

> 🧭 **Se apaga `npm run mock`, se levanta el contenedor en el mismo puerto
> `3000`, y la aplicación Angular no cambia ni un archivo.** Y a partir de ahí,
> cada fase entra por un ticket y sale por un **número**.

Y el remate, que es lo que fija su identidad:

> 🧠 **El track no termina con código. Termina con un *assessment* de riesgo
> tecnológico** que el alumno escribe y defiende, con cuatro opciones costeadas y
> una regla: *la respuesta correcta depende de la fecha de decomisión, no de la
> calidad del código.*

---

## ✅ 2. Decisiones cerradas

Estas ya no se discuten en los chats siguientes.

| Pregunta | Decisión | Consecuencia |
|---|---|---|
| ¿Curso aparte o mismo curso? | **Mismo curso, mismo directorio**, track opcional | Un solo README, una sola guía de estilo, un solo diccionario |
| ¿Numeración? | Fases `beNN-tema.md` (be00–be07), apéndices `bea-NN-tema.md` | No colisiona con `NN-`, `aNN-` ni `forense-fase-NN` del track base |
| ¿Obligatorio? | **No.** El track base se completa con el mock y las 122h no cambian | Se marca 🔥 en el README; sus horas se declaran aparte |
| ¿Prerrequisito? | **Fase 10 del track base terminada** | Es el corte exacto: ahí existen certificados con vigencia, y con ellos el contrato completo. El dashboard (Fase 11) queda fuera del contrato obligatorio |
| ¿Lenguaje? | **PHP 7.4 + Lumen**, monolito | Ver §5. PHP 7.4 está EOL desde noviembre de 2022, **y eso no es un problema: es la premisa** |
| ¿Base de datos? | **`postgres:16.9`**, con historia de upgrade **9.6 → 11 → 13 → 16** | La versión moderna se justifica sola: *a la infraestructura la actualizan, a la aplicación no* |
| ¿MySQL / MariaDB? | **No.** Postgres | MySQL 5.7 reintroduce la emulación en Mac ARM ⚠️ y su dualidad de licencias distrae de un eje que no es el de este track (§0.2) |
| ¿El inyector de caos? | **Se reimplementa en PHP**, con los mismos modos y las dos vías de activación, apagado por defecto | Las fases 3 en adelante del track base entrenan contra él; no puede desaparecer |
| ¿El login del mock? | **Se absorbe.** El `mock/auth.js` pasa a ser autenticación real del backend | El contrato del token no cambia: el interceptor de la Fase 2 no se entera |
| ¿Relación con otros cursos? | **Ninguna.** Este track no sabe que existe `docker-container-legacy` | Todo lo de contenedores vive en `bea-02`, cerrado y autocontenido |
| ¿ORM? | **Eloquent**, el que trae Lumen | No es comodidad: **lo que Eloquent absorbe y lo que no** es el contenido de `be04` |
| ¿Datos de prueba? | **El `db.json` del propio alumno** como semilla; volumen sintético como camino 🔥 | La semilla real hace el reemplazo creíble |
| ¿Piezas forenses en archivo aparte? | **No.** Van embebidas en la §6 de cada fase BE | Ver §9 |
| ¿Cuaderno de incidentes? | **`cuaderno-incidentes-be.md`**, propio del track | Un alumno que solo hace el track base no debe recibir incidentes de PHP mezclados con los suyos |

---

## 💸 3. Por qué existe este track: lo que viene a cobrar

El track base declaró sus atajos y dijo dónde se pagarían. Varios **no se pueden
pagar desde el navegador** porque viven del otro lado de HTTP. Pero la tesis de
este track es más fuerte que eso:

> 🧠 **La mitad de los bugs que parecían del frontend no lo eran.** El curso base
> enseña el síntoma; el track BE muestra que la causa estaba tres capas más abajo,
> en una decisión que nadie tomó y que nadie revisó nunca.

| # | Deuda o síntoma del track base | Dónde vive de verdad | Fase BE que la cobra |
|---|---|---|---|
| 💸 1 | El mock **devuelve el objeto completo**: sin paginación ni proyecciones (Fase 3) | En que la API de 2016 nunca las expuso, y hoy hay cuatro mil inspecciones | `be03` |
| 💸 2 | El `status` del certificado **está guardado como dato** y empieza a mentir al día siguiente (Fase 10, ejercicio 21) | En una columna `status` que un `UPDATE` de 2017 escribe y nadie recalcula | `be03` · `be05` |
| ⭐ 3 | *"Esta inspección se renderiza con la plantilla de hoy en vez de con la de su fecha"* — el corazón de la Fase 7 | En que **la plantilla versionada y la ejecución viven en tablas que nadie une con una restricción**: la invariante no la sostiene nadie | `be05` ⭐ |
| 💸 4 | Fechas con offset `-05:00` en todo el `db.json`, y la cicatriz del certificado que *"venció ayer para el servidor y vence hoy"* (Fase 10) | En columnas `timestamp` **sin zona**, escritas por un runtime con el TZ del contenedor | `be04` |

Y añade tres facturas que el track base **no podía ni nombrar**:

- **La familiaridad falsa.** Cuatro familias de bugs que solo existen porque Lumen
  *parece* Laravel. Ver `be01`.
- **La deuda de plantilla.** El mercado de devs **PHP** es enorme; el de devs
  **Lumen** no existe. Quien entra viene reciclado —de Laravel, de Symfony, de
  CakePHP—: **barato y disponible, pero con formación que hay que pagar y que se
  va en dieciocho meses**, porque nadie quiere "Lumen 2018" en su CV. Se paga el
  onboarding una y otra vez y nunca se amortiza.
- **La subida de versión que nadie decidió.** El proveedor gestionado movió la base
  cuatro veces mientras la aplicación se quedaba quieta (`be04`).

### 3.1 El mecanismo pedagógico central: cuatro bugs que solo Lumen produce

- **Facades.** `Cache::get()` no existe como método en ningún archivo: es
  `__callStatic` resolviendo contra el contenedor. **`grep` no encuentra nada.**
- **En Lumen los facades están apagados por defecto** (`$app->withFacades()`).
  Familiaridad falsa en estado puro: el ejemplo de internet funciona en Laravel y
  aquí lanza *class not found*… o peor, funciona porque alguien los encendió a
  medias.
- **Magia de Eloquent:** `__get` para atributos dinámicos, `scopeActive()` invocado
  como `Model::active()`. Buscar el nombre no encuentra nada.
- **Lo que Lumen quitó de Laravel:** sesiones, parte de eventos y de middleware. La
  respuesta de internet asume que están.

Y el remate de 2026, que es la versión más útil de la lección y se demuestra en un
ejercicio de diez minutos:

> 🧠 **Un asistente te responde con confianza… en Laravel.** No hay ausencia de
> respuesta: hay **respuesta plausible y equivocada**. La ausencia te vuelve
> cuidadoso; lo plausible te vuelve confiado.

### 3.2 Y la defensa obligatoria: Lumen no fue una tontería

Sería traicionar el criterio del repositorio. En 2016, para una empresa mediana
latinoamericana con gente de PHP del intranet viejo, Lumen era **la decisión
sensata**: aprovechas el equipo que tienes, la sintaxis que ya conocen, y encima es
moderno y rápido. El beneficio se cobró de verdad durante años.

> 🧭 **El pecado no fue elegirlo. Fue elegirlo para *un servicio*, acertar, y que
> nadie volviera a decidir nunca.** Si el curso presenta la elección original como
> una estupidez, el alumno no aprende nada: los errores caros no se parecen a
> estupideces, se parecen a esto.

---

## 🚫 4. Reglas no negociables

**El frontend no se toca.** Ni un componente, ni un servicio, ni un
`BehaviorSubject`, ni el interceptor, ni `environment.apiUrl`. El backend se adapta
al contrato existente, nunca al revés.
`git diff fase-10-certificados-vigencia..HEAD -- src/` devuelve vacío, y ese
comando es un ítem del checklist de `be00`.

**El contrato manda sobre la elegancia.** json-server tiene un dialecto y el
frontend lo consume tal cual: `GET /inspections/503/findings`, el `id` compuesto de
las plantillas (`elevator-annual-v2`) con el identificador lógico en `templateId`,
el `404` con cuerpo vacío, el objeto completo sin paginar. Reimplementarlo en Lumen
es *aburrido y correcto*.

**El caos sobrevive.** El `mock/chaos.js` que el alumno construyó en la Fase 3 es
la herramienta de práctica de ocho fases del track base. Se reimplementa en PHP con
los mismos modos, apagado por defecto, con las dos vías de activación — incluida la
que decide el TTL del token.

**Autocontención estricta.** Este track no remite a ningún otro curso, aunque
exista uno de contenedores en el catálogo. Todo lo que hace falta vive en
`bea-02`, escrito como receta cerrada y verificable. Ninguna fase dice
*"confírmalo contra tu entorno real"* ni deja una versión pendiente.

**El alumno no instala PHP.** Ni Composer, ni `psql`. Cuatro comandos de
`docker compose` y nada más (§5.3). Verificado.

**Nada de PHP moderno gratuito.** Sin tipos de retorno union, sin `match`, sin
constructor property promotion, sin enums, sin atributos. Todo eso es PHP 8 y aquí
el runtime es 7.4 **a propósito**. Aparecen como comparación 🔥, igual que Angular
17 en el track base.

**Idioma, igual que siempre.** Narrativa y comentarios en español latinoamericano
con tuteo; código en inglés — clases, métodos, rutas, nombres de tabla y de
columna. `Client`, `Asset`, `Template`, `Inspection`, `Finding` y `Certificate`
significan exactamente lo mismo a los dos lados del cable, y eso lo garantiza el
anexo PHP de la guía de estilo (§10).

---

## 🛠️ 5. Stack y versiones

**Todo fijado y medido, salvo las tres ⚠️ de §5.5**, que son de redacción y no
bloquean ninguna fase. Esta tabla es la fuente de verdad del track: el curso no
depende de ningún `composer.json` externo.

### 5.1 La pila

| Pieza | Versión | Por qué esta y no otra |
|---|---|---|
| Runtime | **PHP 7.4.33** (`php:7.4-cli`) | Verificado aarch64 el 8/09/2026. **EOL desde noviembre de 2022, y esa es la premisa**: un runtime sin parches de seguridad es exactamente el legacy que el track quiere |
| Imagen | `php:7.4-cli`, congelada | Último push de la imagen oficial: **2022-11-15**. La imagen se congeló el día que PHP 7.4 llegó a EOL. Dato duro y citable |
| Framework | **Lumen 5.x** ⚠️ | La línea que corresponde a 2016–2018. La versión exacta se fija antes de escribir `be01` (§5.5) |
| Gestor de paquetes | **Composer 2** (`COPY --from=composer:2`) | Se copia el binario en el Dockerfile: no se instala nada en la máquina del alumno |
| ORM | **Eloquent**, el de la línea de Lumen | Lo que Eloquent absorbe y lo que no **es** el contenido de `be04` |
| Base de datos | **`postgres:16.9`** | Verificado arm64 y runtime. **PG 16 y no 15:** un año más de soporte (EOL nov-2028 frente a nov-2027 ⚠️) y mejor encaje cronológico — PG 16 salió en septiembre de 2023, así que la última subida forzada cae natural en 2024 |
| Cadena de upgrade | **9.6 (2016) → 11 (2019) → 13 (2021) → 16 (2024)** | Escalonada, no de un salto. Cada escalón con su fecha y su ventana. **La cadena es evidencia de la fecha de nacimiento del backend**, no color narrativo |
| Extensión PDO | `pdo_pgsql` vía `docker-php-ext-install` | La `libpq 13` de bullseye habla SCRAM sin tocar nada. Verificado |
| Servidor HTTP | `php -S 0.0.0.0:3000 -t public` | El servidor embebido basta para un laboratorio. Nada de nginx: distrae |
| Pruebas | PHPUnit, el de la línea de Lumen ⚠️ | Estrategia y versión se cierran en `be06` |
| Puerto de la API | **3000** | El mismo del mock. El frontend no debe enterarse |
| Puerto de Postgres | **5432**, no publicado por defecto | Se publica bajo demanda para `psql`; `bea-02` lo explica |

### 5.2 Lo verificado, con fecha

Docker Desktop 29.6.2, host `aarch64`, 8 de septiembre de 2026. **Nada necesita
emulación.**

| Imagen | arm64 | Cómo se comprobó |
|---|---|---|
| `php:7.4-cli` / `7.4-apache` / `7.4-fpm` | ✅ | registro (`linux/arm64/v8` activo) **y runtime** |
| `postgres:15 / 16 / 17 / 18` | ✅ | registro y runtime |

**La verificación que decidía el stack** — PHP 7.4.33 arm64 contra PostgreSQL 16.9
arm64:

```
conexion:       OK
servidor:       PostgreSQL 16.9
password_encr:  scram-sha-256
hash del user:  SCRAM-SHA-256...
php:            7.4.33 (aarch64)
escritura:      hola
```

Desde PG 14 el `password_encryption` por defecto es `scram-sha-256`, y un cliente
con `libpq` anterior a la 10 no habla SCRAM. **La `libpq 13` de bullseye sí.** La
duda quedó cerrada y el stack es viable.

**Salida real de `curl localhost:3000` tras `docker compose up -d`:**

```json
{ "php": "7.4.33", "arch": "aarch64", "postgres": "16.9 (Debian 16.9-1.pgdg130+1)" }
```

### 5.3 El arranque, en cuatro comandos

```bash
docker compose up -d          # levanta postgres + la API en el 3000
curl localhost:3000/health    # comprobar
docker compose logs -f api    # ver que pasa
docker compose down           # parar (con -v borra la base)
```

`compose.yaml`, probado:

```yaml
services:
  db:
    image: postgres:${POSTGRES_TAG}
    environment: {POSTGRES_PASSWORD: certcore, POSTGRES_DB: certcore}
    volumes: [pgdata:/var/lib/postgresql/data]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 2s
      retries: 15
  api:
    build: ./docker/php
    ports: ["3000:3000"]
    volumes: [".:/app"]
    environment: {DB_DSN: "pgsql:host=db;dbname=certcore"}
    depends_on: {db: {condition: service_healthy}}
    command: php -S 0.0.0.0:3000 -t public
volumes: {pgdata: }
```

### 5.4 El hallazgo del laboratorio, que es contenido y no un accidente

El primer `docker build` falló así:

```
E: Release file for http://deb.debian.org/debian-security/dists/bullseye-security/InRelease
   is expired (invalid since 1d 6h 39min 54s)
```

**El LTS de Debian 11 bullseye —base de `php:7.4-cli`— caducó poco más de un día
antes.** Al forzar la fecha, el siguiente error fue `404`: los paquetes ya se
movieron a `archive.debian.org`. No es un ejemplo didáctico: es **la muerte de una
imagen en directo, con fecha y mensaje literal**, capturada el día que ocurrió.

Y la solución venía escrita dentro de la propia imagen. El `/etc/apt/sources.list`
de `php:7.4-cli` incluye, **comentadas**, sus propias fuentes de
`snapshot.debian.org` fijadas al día del build:

```dockerfile
FROM php:7.4-cli
RUN printf 'deb http://snapshot.debian.org/archive/debian/20221114T000000Z bullseye main\ndeb http://snapshot.debian.org/archive/debian-security/20221114T000000Z bullseye-security main\n' > /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends libpq-dev unzip \
 && docker-php-ext-install pdo_pgsql \
 && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /app
```

> 🧠 **La imagen traía escrita su propia cápsula del tiempo y nadie la lee nunca.**
> Receta obligatoria de `bea-02`, y lección en sí misma.

⚠️ **Nota de mantenimiento:** `archive.debian.org/debian-security` todavía no
servía `bullseye-security` el día de la prueba. Si `snapshot.debian.org` fallara,
el plan B es usar solo `bullseye main` desde el archivo.

### 5.5 Las ⚠️ que quedaban, y cómo se cerraron

**1. La versión exacta de Lumen — ✅ CERRADA el 11/09/2026, verificada contra
Packagist** (`repo.packagist.org/p2/laravel/lumen-framework.json`, que trae fecha
y restricción de cada versión):

| Versión | Publicada | Requiere | Papel en la ficción |
|---|---|---|---|
| **5.2.9** | 7/09/2016 | `php >=5.5.9` | Con la que nace `certcore-api`. Fija la Era 0 con precisión de recibo |
| 5.3.3 | 17/12/2016 | `php >=5.6.4` | Primera subida, sin drama |
| 5.5.2 | 16/10/2017 | `php >=7.0` | Segunda |
| **5.8.13** | 28/08/2019 | `php ^7.1.3` | **La que corre hoy.** Última de la línea 5.x, y el último `composer.lock` tocado |
| 6.0.0 | 12/09/2019 | `php ^7.2` | Salió **quince días después** de la última subida. Nunca se subió |
| 9.0.0 | 15/02/2022 | `php ^8.0.2` | **El primer Lumen que admite PHP 8** |

De ahí sale el ticket que abre el track, y es más duro de lo que parece: la
restricción `^7.1.3` de 5.8.13 **excluye PHP 8**, y el primer escalón que lo
admite está **cuatro versiones mayores más arriba** (6, 7, 8, 9). *"Subir el
runtime"* significa, en realidad, *"cambiar de framework"* — y eso no lo sabía
nadie cuando se escribió el ticket. Lumen 5.8 **sí corre bien sobre PHP 7.4.33**:
el sistema no está roto, está sin soporte, que es peor porque no duele.

**2. El estado oficial de Lumen frente a Laravel + Octane — ✅ CERRADA**, cita
literal de la documentación oficial (`lumen.laravel.com/docs/10.x`, sección
*Installation*), para `be07`:

> *"In the years since releasing Lumen, PHP has made a variety of wonderful
> performance improvements. For this reason, along with the availability of
> Laravel Octane, we no longer recommend that you begin new projects with Lumen.
> Instead, we recommend always beginning new projects with Laravel."*

Fíjate en lo que **no** dice: no dice que Lumen esté muerto ni que haya que
migrar. Dice que no empieces proyectos nuevos con él. Para `be07` esa distinción
es el material: un producto sin recomendación oficial para proyectos nuevos y sin
ruta de migración declarada es exactamente el pasivo que el *assessment* costea.

**3. Los cambios de dialecto de la cadena — ✅ CERRADA el 11/09/2026 al escribir
`be04`, y con dos correcciones a lo que este documento suponía.** Verificado
contra las notas de release oficiales (`postgresql.org/docs/release/10.0/`,
`/12.0/`, `/15.0/`):

| Lo que §7 `be04` suponía | Veredicto |
|---|---|
| `WITH OIDS` eliminado en PG 12 | ✅ **Cierto**, con cita literal |
| Escapado manual de comillas, era previa a `standard_conforming_strings` | ❌ **Falso en esta cadena**: ese valor pasó a `on` por defecto en **PG 9.1 (2011)**, cinco años antes del nacimiento del sistema |
| Casts implícitos retirados por Postgres | ❌ **Falso en esta cadena**: la retirada masiva fue **PG 8.3 (2008)** |

Las dos falsas **no se borran del material: se usan**. `be04` las presenta como
*pistas heredadas que hay que verificar*, y descartarlas es la mitad de su
lección forense. En su lugar, las rupturas reales de la cadena son cuatro:
**PG 10** (renombrado de `pg_xlog`→`pg_wal` y de las funciones `xlog`, que se
lleva el script de respaldo), **PG 12** (`WITH OIDS`, los tipos `abstime`/
`reltime`/`tinterval`, y `pg_constraint.consrc`/`pg_attrdef.adsrc`), **PG 14**
(`scram-sha-256` por defecto, que aquí no rompió) y **PG 15** (se revoca `CREATE`
en el esquema `public`, **sólo en clústeres nuevos** — muerde en el laboratorio y
no mordió en producción; y el fin del modo de respaldo exclusivo, que se lleva el
mismo script por segunda vez).

**4. La versión de PHPUnit — ✅ CERRADA el 11/09/2026 al escribir `be06`.** El
`composer.json` de `laravel/lumen-framework` **v5.8.13** declara
`"require-dev": {"phpunit/phpunit": "^7.0|^8.0", "mockery/mockery": "^1.0"}`
(verificado en Packagist). Se fija **PHPUnit 8.5**, la última de la línea 8: es
la más nueva que la restricción admite y corre sobre PHP 7.4. PHPUnit 9 obligaría
a cambiar la restricción del framework, que es justo la clase de cambio que este
track no hace a la ligera.

La estrategia de pruebas queda también cerrada en `be06`: contra el
`postgres:16.9` del compose —nunca SQLite, que no tiene claves foráneas
compuestas con la misma semántica ni `jsonb` ni la distinción de zonas, y
probarlo ahí sería probar otro sistema—, con **transacción envuelta y `ROLLBACK`**
como limpieza por defecto (milisegundos por prueba) y `TRUNCATE` sólo en las
pocas que necesitan `COMMIT` real. El criterio que gobierna es el **tiempo de
ciclo**: si la suite pasa de treinta segundos, se arregla antes de seguir
escribiendo pruebas.

---

## ⏱️ 6. Presupuesto de horas

El track base **sigue siendo de 122h** (108h de fases + 14h de cuaderno) y no
cambia. El track BE declara las suyas aparte, y son menos porque el alumno ya trae
el dominio aprendido: no hay que explicarle qué es una plantilla versionada ni por
qué un certificado tiene vigencia.

| Bloque | Fases | Horas |
|---|---|---|
| El contrato y la familiaridad falsa | be00–be01 | 16h |
| La medición: quién escribió esto | be02 | 8h |
| El reemplazo | be03 | 10h |
| Lo que pasó sin que nadie mirara | be04 | 10h |
| La invariante que no sostenía nadie | be05 | 10h |
| La reescritura a medias | be06 | 8h |
| El *assessment* | be07 | 10h |
| **Total track BE** | **8 fases** | **72h** |
| 📓 Cuaderno de incidentes BE | `cuaderno-incidentes-be.md` | **8h** · 12 incidentes |
| | **Total con cuaderno** | **80h** |

Los apéndices no cuentan: son consulta bajo demanda, igual que `a01`–`a13`.

> 📝 **Por qué ocho fases y no nueve.** La subida forzada de versión estuvo cerca
> de llevarse una fase entera propia. Cabe en `be04` junto con el dialecto porque
> Postgres se rompe **menos** de lo que uno espera entre versiones mayores — que
> es, precisamente, la paradoja de §7 `be04`.

---

## 🌳 7. Las ocho fases

Cada una usa la **plantilla obligatoria de nueve secciones** de
`prompts/guia-de-estilo-y-convenciones.md` §8 y cierra con sus 📌 Pendientes fuera
de lo que lee el alumno. Ejercicios: **25 mínimo, 30 ideal, hasta 35 en las
densas**, con al menos un tercio de diagnóstico.

Cada fase nombra su **pieza forense**, que en este track casi nunca es un DevTools:
es un log, un `EXPLAIN`, una query en `pg_stat_statements` o un `grep` que **no**
encuentra nada.

Y todas siguen el mismo ciclo, que es el del track base y **no** un recorrido
"deuda por deuda":

> 🧭 **síntoma → medición → contención.** Ninguna fase enseña el producto por el
> producto. Si una fase se puede resumir como *"aquí se explica Eloquent"*, está
> mal escrita y se reescribe.

### 📜 be00 — El contrato: auditoría del mock (6h)

Antes de escribir una línea de PHP hay que saber exactamente qué promete el
servidor que se va a apagar. Y aquí es *más* necesario que de costumbre, porque el
backend heredado va a ser raro: **el contrato es lo único firme**.

Entra: capturar el tráfico real con la pestaña Network contra las fases 3 a 10 del
track base —no leer el código del mock, **capturarlo**—; inventariar las seis
colecciones (`clients`, `assets`, `templates`, `inspections`, `findings`,
`certificates`) y el login; documentar el dialecto que el frontend consume de
verdad, incluido el `id` compuesto de las plantillas y la ruta anidada
`GET /inspections/:id/findings`; e inventariar los modos del inyector de caos con
sus vías de activación, incluida la que manipula el TTL del token.

Sale: **`CONTRACT.md`** y **`smoke.sh`** ejecutable, que a partir de aquí es el
juez de todas las fases. Y aquí se cuenta, por primera vez, **de dónde salió el
backend**: la empresa certificaba desde antes de que existiera la app Angular
(§10.2).

Pieza forense: dos peticiones que el alumno **juraría** que son iguales y que
difieren en un header o en el orden de los parámetros. El contrato no es lo que uno
recuerda.

### 🐘 be01 — Lumen sobre PHP 7.4, y la familiaridad falsa (10h) ⭐

Entra: el `composer.json` y la forma del monolito; el bootstrap de Lumen, que **no
es el de Laravel**; rutas, middleware y el contenedor; `$app->withFacades()` y qué
cambia según esté encendido o apagado; y el primer endpoint vivo, `GET /health`.

Se reimplementa aquí el **inyector de caos**, apagado por defecto y con las mismas
vías de activación que el mock.

Y la mitad de la fase son los cuatro bugs de §3.1, provocados a propósito:

- El `grep` de `Cache::get` que devuelve cero resultados sobre un método que sí se
  ejecuta.
- El ejemplo de StackOverflow que funciona en Laravel y **se comporta distinto** en
  Lumen, sin lanzar nada.
- El `scopeActive()` invocado como `Model::active()`, que no aparece buscando
  `active(`.
- Y el ejercicio de diez minutos que cierra la fase: **pregúntale a un asistente
  cómo se hace X en Lumen, copia la respuesta, y mide en qué falla.** No falla por
  ignorancia: falla porque contesta en Laravel, con confianza.

> 🧠 **La ausencia de respuesta te vuelve cuidadoso; la respuesta plausible te
> vuelve confiado.** Ese es el bug más caro del track y no está en ninguna línea de
> código.

Pieza forense: el `grep` vacío. En un curso construido sobre buscar en el código,
tener una capa donde buscar **no sirve** es el reflejo que hay que romper.

Sale a `bea-01` (PHP y Lumen para quien no escribe PHP) y `bea-03` (el
contenedor, los facades y por qué `grep` falla).

### 🧬 be02 — Estratos por procedencia: de dónde venía quien escribió esto (8h)

**La fase que rima con el track base y gira su eje.** Los ejercicios 🧬 de Angular
16 preguntan *"¿este archivo es de 2021 o de 2024?"* — estratos **por fecha**. Aquí
la pregunta es otra:

> 🧠 **El dev que llega deja huella según de dónde venga.** El de Laravel asume
> facades, contenedor completo y `config()`. El de Symfony mete inyección por
> constructor y servicios donde el resto usa *service locator*. El de CakePHP
> arrastra Active Record y convenciones de tabla que aquí no existen. **El bug te
> dice de dónde venía quien lo escribió.**

El código tiene estratos **por procedencia**, no por fecha, y esa es la firma de la
economía de rotación de §3: el mercado de devs Lumen no existe, así que todos los
que pasaron venían reciclados de otro sitio y se fueron en dieciocho meses.

Entra: leer el código heredado clasificando cada archivo por su procedencia; contar
—**medir, no suponer**— cuántos estilos conviven para resolver lo mismo; y el
inventario que sale de ahí, que es el insumo directo del *assessment* de `be07`:
cuántas maneras hay de hacer una consulta, de inyectar una dependencia, de
manejar un error.

Pieza forense: dos endpoints vecinos que hacen lo mismo de dos maneras correctas y
distintas. **Ninguno está mal**, exactamente como los dos estilos de inyección del
track base. Uniformarlos no es el trabajo; saber cuál tocar sí.

Sale a `bea-09` (Symfony como vara de medir).

### 🗄️ be03 — El reemplazo: de `db.json` a Postgres 16 (10h)

**La bisagra del track.** Se implementan las seis colecciones del contrato, se
siembra la base **desde el `db.json` que el alumno ya tiene** —no desde un dump
ajeno—, y se apaga el mock.

Entra: las migraciones y el esquema de `clients`, `assets`, `templates`,
`inspections`, `findings`, `certificates` y `users`; los modelos de Eloquent; la
paginación de servidor que la API nunca expuso (💸 1), servida en el dialecto del
mock para que el frontend no note nada; el `id` compuesto de las plantillas
(`elevator-annual-v2`) traducido a clave primaria de verdad; y la absorción del
login.

Y el hallazgo incómodo: **`certificates.status` es una columna**. El track base ya
lo señaló como error de diseño puesto a propósito; aquí se ve la columna, se
cuenta cuántas filas mienten hoy, y se difiere la corrección a `be05`.

Pieza forense: el primer `smoke.sh` en rojo. Un `id` que salió como `7` en vez de
`"elevator-annual-v2"` y una pantalla en blanco. El contrato es el juez.

> 🧭 **La señal de que quedó bien:** *"apagué `npm run mock`, levanté el
> contenedor, y la única forma de notar el cambio fue que la lista de inspecciones
> tardó 40 ms más."*

Sale a `bea-04` (Eloquent: lo que absorbe y lo que no).

### 📅 be04 — El salto de versión que nadie corrió (10h)

La fase que la asimetría le regala al track:

> 🧠 **A la infraestructura sí la actualizan. A la aplicación no.** La base tiene
> dueño —un proveedor gestionado, una auditoría, un calendario ajeno— y fue subiendo
> de versión durante ocho años. La aplicación no tenía dueño y sigue en 2016.

Y el motivo, que es concreto y con culpable: **el proveedor gestionado anunció fin
de soporte y subió la versión en una ventana de mantenimiento**, con un correo que
alguien archivó. Con la ironía puesta por el dominio: fue una **auditoría de
cumplimiento** la que exigió correr sobre versiones soportadas. *La certificadora no
pasaba su propia auditoría.*

Entra: la tabla de evidencia con los cuatro escalones y sus fechas; el upgrade
ejecutado cambiando **una línea del `.env`**; y el inventario de lo que se rompió —
código que asumía `WITH OIDS`, eliminado en PG 12 ⚠️; escapado manual de comillas,
de la era previa a `standard_conforming_strings` ⚠️; comparaciones que dependían de
casts implícitos que Postgres retiró ⚠️. Y las columnas `timestamp` **sin zona**
(💸 4), que es de donde sale la cicatriz del certificado que *"venció ayer para el
servidor y vence hoy"*.

Los dos matices que evitan el cuento:

> 🧠 **Nada se rompió a lo grande precisamente porque Postgres es muy bueno en
> compatibilidad hacia atrás. El 95% siguió funcionando y por eso nadie miró. La
> calidad de la compatibilidad es lo que permitió el abandono.** Paradoja real, sin
> villanos fabricados.

> 🧠 **La factura del salto la paga exactamente el código que se saltó las
> convenciones.** Eloquent absorbe casi todos los cambios de dialecto; lo que no
> absorbe es el `DB::select()` con SQL a mano que alguien escribió para ir más
> rápido. Es la moraleja del track vista desde otro ángulo — y para diseñar
> ejercicios es un regalo, porque dice **dónde** ponerlos sin adivinar.

Pieza forense ⭐: **el incidente cuyo `git log` está vacío.**

```
# .env — La versión de la base vive AQUÍ, fuera del código fuente.
POSTGRES_TAG=16.9
```

La causa y el síntoma están separados por meses, y **el cambio que rompió no está
en el repositorio**. El alumno hace lo que hace siempre —`git log`, `git blame`,
revisar el último despliegue— y no encuentra nada, porque no hay nada. En un curso
construido sobre el par `-roto` / `-fix` y el `git diff` como factura de la deuda,
tener un incidente con el diff vacío vale mucho. Y como el "cambio" es una línea de
un archivo que no es código, **no fuerza ninguna convención de tags**.

Sale a `bea-05` (dialectos y saltos de versión) y `bea-07` (tiempo y
`TIMESTAMPTZ`).

### ⭐ be05 — La invariante que no sostenía nadie (10h) ⭐⭐

**La fase insignia**, y la que cierra el círculo con el corazón del track base.

La Fase 7 del curso base enseña el síntoma: *una inspección de hace un año se está
renderizando con la plantilla de hoy*. El alumno lo arregló en el frontend y estuvo
bien. Esta fase muestra dónde estaba la causa.

Entra: la invariante enunciada en una línea —*una inspección se lee siempre contra
la versión de plantilla que estaba vigente cuando se ejecutó*— y la comprobación de
que **ninguna restricción de la base la sostiene**: `inspections` guarda
`template_id` y `template_version` como dos columnas sueltas, sin clave foránea
compuesta contra `templates`. La consulta que encuentra las filas que ya la violan
en producción. Y el `certificates.status` de `be03`, convertido en derivado.

Y las tres salidas realistas, costeadas: clave foránea compuesta (qué se rompe al
añadirla sobre datos sucios), una restricción `CHECK` con función, o disciplina de
aplicación documentada. Se mide cada una.

> 🧭 **Una invariante que nadie sostiene no está rota: está esperando.** El sistema
> funcionó ocho años porque nadie borró una plantilla vieja. El día que alguien lo
> haga, la auditoría encuentra inspecciones que se renderizan con la norma
> equivocada — y en una certificadora eso no es un bug de interfaz.

Pieza forense: la fila de `inspections` que apunta a una `template_version` que ya
no existe, y el `EXPLAIN` de la consulta que la encuentra en cuatro mil filas.

Sale a `bea-06` (restricciones, claves compuestas y datos sucios).

### 🧱 be06 — La reescritura que se quedó a medias (8h)

El extra propio de CertCore. En algún momento alguien empezó a mover el sistema
hacia Laravel completo —o hacia servicios, o hacia lo que fuera— y se fue antes de
terminar. Quedaron **dos maneras de hacer lo mismo, las dos vivas**, y nadie sabe
cuál es la buena.

Entra: medir la superficie de la reescritura a medias —qué endpoints se movieron y
cuáles no—; entender por qué el camino de vuelta de Lumen a Laravel **no es un
upgrade, es un trasplante de bootstrap**; y las pruebas, que llegan aquí y no antes
por una razón: *no se puede probar lo que no se ha decidido cuál es*.

Y la conversación honesta que la fase obliga a tener: **terminar una migración que
otro empezó suele costar más que empezarla de cero, y aun así casi siempre es la
respuesta correcta**, porque el estado intermedio es el más caro de todos.

Pieza forense: el mismo recurso servido por dos caminos, con comportamientos
distintos ante el mismo error. El ticket dice *"a veces devuelve 500 y a veces 422"*
y tiene razón: depende de por dónde entres.

Sale a `bea-08` (seguridad de API sobre un runtime sin parches).

### 📊 be07 — El *assessment* de riesgo tecnológico (10h)

El cierre, y **no es código**: es el documento que el alumno escribe y defiende. Es
el entregable que ningún tutorial de internet enseña a producir, porque todos
terminan en el *happy path* del rewrite.

Cuatro opciones, todas costeadas con los números que las siete fases anteriores
produjeron:

1. **Quedarse y formar.** Cuánto cuesta, cuánto tarda, y qué pasa si el formado se
   va también — que es lo que pasó las últimas tres veces (§3, deuda de plantilla).
2. **Reescribir a un lenguaje aburrido y sostenido.** El coste real, no el
   optimista, y qué se rompe mientras. Symfony es la vara: su disciplina de
   deprecaciones y sus LTS cada dos años son el contraste exacto que hace visible
   que Lumen no tenía ninguna (`bea-09`).
3. **Estrangular por endpoint.** Un proxy delante, se migra la ruta más dolorosa, se
   mide. Probablemente la respuesta correcta y la más aburrida.
4. **No hacer nada y documentar el riesgo.** A veces gana, y **saber cuándo gana es
   seniority**.

Con la regla que gobierna la fase:

> 🧭 **La respuesta correcta depende de la fecha de decomisión, no de la calidad del
> código.** Un sistema con dos años de vida por delante y uno con diez no reciben la
> misma respuesta aunque el código sea idéntico.

Y el cierre honesto obligatorio: **dónde Lumen de verdad ganó.** Aprovechar el
equipo de PHP que la empresa ya tenía fue una ventaja real y medible durante años.
El curso pone el número de las dos columnas, o no ha entendido nada.

---

## 📎 8. Los apéndices

Consulta, no lectura corrida. Se abren cuando una fase manda a ellos. Entre 5 y 10
ejercicios cortos cada uno, contra el laboratorio propio.

| Archivo | Qué resuelve |
|---|---|
| `bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md` | PHP mínimo para un senior de otro lenguaje: Composer y PSR-4, tipado gradual, arrays que son dos cosas, excepciones, y el modelo de ejecución *shared-nothing* — que es la diferencia conceptual más grande con cualquier backend de proceso persistente |
| `bea-02-receta-de-imagen-y-compose.md` | **La receta rápida.** El `compose.yaml` y el Dockerfile de §5.3–5.4 copiables, con la **cápsula del tiempo de `snapshot.debian.org`**, el `.env` con `POSTGRES_TAG`, los comandos de arranque, y los tres errores que salen siempre. Cerrado y autocontenido |
| `bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md` | `__callStatic`, `__get`, el *service locator* frente a la inyección, `$app->withFacades()`, y el método de búsqueda que **sí** funciona cuando `grep` no encuentra nada |
| `bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md` | Active Record, *scopes*, relaciones, N+1, `DB::select()` y por qué es donde se concentran los bugs. El diccionario de qué diferencias de dialecto absorbe el ORM y cuáles te deja ver |
| `bea-05-dialectos-y-saltos-de-version-en-postgresql.md` | Qué cambia de verdad entre versiones mayores: el directorio de datos que no es compatible, `pg_upgrade` frente a dump/restore, `WITH OIDS`, `standard_conforming_strings`, los casts implícitos retirados, y `password_encryption` con SCRAM |
| `bea-06-restricciones-claves-compuestas-y-datos-sucios.md` | Poner una restricción sobre datos que ya la violan: `NOT VALID` y `VALIDATE CONSTRAINT`, claves foráneas compuestas, `CHECK` con función, columnas generadas, y el procedimiento para no tumbar producción |
| `bea-07-tiempo-zonas-y-timestamptz.md` | UTC como única verdad, `timestamp` **sin** zona frente a `TIMESTAMPTZ`, `America/Bogota`, el TZ del contenedor de PHP como fuente de bugs, y por qué el `-05:00` del `db.json` importa |
| `bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md` | OWASP sobre este dominio, **con el agravante de que el runtime está EOL**: inyección SQL, autorización a nivel de objeto, asignación masiva, y la conversación real — cómo se defiende un sistema cuando ya no hay parches que aplicar |
| `bea-09-symfony-como-vara-de-medir.md` | **El grupo de control, no el paciente.** Por qué Symfony pierde como candidato —está sano y su disciplina de upgrade es buena— y por qué eso lo vuelve la vara: avisos de deprecación, LTS cada dos años, Rector. Con lo que sí duele en Symfony, para el registro: el salto a Flex, las cuatro eras de configuración, el contenedor compilado, Doctrine, y el ecosistema de bundles de la era 2.x que murió |
| `bea-10-mapa-de-deuda-del-track-be.md` | Qué quedó feo a propósito en el backend, qué lo vuelve exigible y en qué orden se pagaría. ⚠️ **Sin hermano en el track base**: éste no consolida su deuda en ningún apéndice —vive en el 💸 de cada fase y en su 📌 de cierre—, y `a12` es `a12-arm64-m1.md` |
| `bea-11-datos-de-prueba-y-volumen.md` 🔥 | Sembrar y generar: la semilla desde el `db.json` propio, volumen sintético para que las mediciones de `be05` digan algo con cuatro mil inspecciones, datos deterministas con semilla fija, y **por qué un dataset aleatorio arruina una prueba de regresión** |

`bea-02` es el que más cuidado necesita: es el único punto donde el track toca
contenedores, y tiene que funcionar de principio a fin **sin remitir a nada
externo**, aunque exista `docker-container-legacy` en el catálogo. Es además el
apéndice con el mejor material del track: la imagen que se murió en directo.

---

## 📐 9. Convenciones de archivo

Fases: **`be00-tema.md` a `be07-tema.md`**. Apéndices: **`bea-01-tema.md` a
`bea-11-tema.md`**. Minúsculas con guiones, dos dígitos, igual que el track base.

El prefijo `be` mantiene los cuatro bloques ordenados y separados dentro del mismo
directorio, sin subdirectorios: las fases base (`00-` a `14-`), sus apéndices
(`a01-` a `a13-`), las piezas forenses (`forense-fase-NN.md`) y el track BE.

> 📝 **Sobre `bea-01-` frente a `bea01-`.** El track base de este curso usa `aNN-`
> (`a09-docker-kubernetes.md`), así que `bea09-` habría rimado mejor localmente. Se
> elige `bea-NN-` porque es la convención ya registrada en el `CLAUDE.md` del
> repositorio. **Un solo nombre para la misma cosa en todo el repositorio vale más
> que la rima local.**
>
> 🪦 **Renombrado el 10/09/2026: la convención era `be-a-NN-`.** Se cambió a
> `bea-NN-` en todo el repositorio —tres segmentos antes del tema se leían como
> tres cosas en vez de una— y este curso se alinea antes de escribir su primer
> apéndice, así que no hay ningún archivo que renombrar aquí.

Archivos nuevos del track, fuera de fases y apéndices:

| Archivo | Qué es |
|---|---|
| `cuaderno-incidentes-be.md` | Los 12 incidentes del track BE, con sus IDs propios. **Separado del `cuaderno-incidentes.md` base a propósito** |
| ~~`prompts/plantilla-de-incidente-be.md`~~ | 🪦 **No se escribió** (11/09/2026): el formato **no diverge** lo suficiente. La plantilla de §7 de `formato-cuaderno-incidentes.md` se usó tal cual, y lo propio del track —las cuatro formas de preparación y la excepción de `be-06`— ya vive en su §🔥 |
| `prompts/preparaciones-de-incidentes-be.md` | ✅ **Escrito.** El estado roto de cada incidente: cuatro ramas, cinco guiones de `sql/`, la línea del `.env` y las tres sin preparación. Material de autoría; el estudiante no lo abre |
| `prompts/prompts-backend-fase.md` | Los prompts **A** de redacción de fases BE. Archivo nuevo, no adición a `prompts-extendidos-fases.md` |
| `prompts/prompts-backend-apendice.md` | Ídem para apéndices |

**No hay `forense-be-NN.md`.** Es una divergencia explícita respecto del track base,
y esta es la razón: los archivos `forense-fase-NN.md` existen para sostener capturas
de DevTools, recetas de breakpoints y flujos de Network, que no caben en la fase. La
pieza forense de este track es un log, un `EXPLAIN` o un `grep` vacío — **cabe en la
§6 de la fase y se lee mejor ahí**, junto al código que la produce. Si al escribir
`be01` o `be05` la §6 se desborda, se revisa esta decisión y se declara el cambio.

El código del backend se referencia como `server/…` dentro del mismo proyecto del
alumno. El frontend sigue en la raíz, sin moverse.

**Tags de git:** `be-fase-` + el mismo slug del archivo, en un namespace propio para
que `git tag -l 'fase-*'` siga siendo el índice limpio del track base
(`be00-el-contrato.md` → `be-fase-00-el-contrato`). Los commits llevan prefijo
`be00: …`, y los de ejercicio `be00 ej17: …`.

---

## 🔧 10. Documentos existentes que hay que tocar

### 10.1 Las adiciones sin fricción

Ninguna altera el contenido del track base; todas son adiciones de encuadre. Se
hacen **antes** de escribir `be00`.

1. **`README.md`** — sección nueva del track opcional 🔥, con su tabla de ocho
   fases, su tabla de once apéndices, sus 72h + 8h declaradas **aparte de las 122**,
   y el prerrequisito (Fase 10 terminada).
2. **`prompts/guia-de-estilo-y-convenciones.md`** — registrar la convención `beNN-` /
   `bea-NN-`, el anexo PHP del diccionario de código (`Client`, `Asset`,
   `Template`, `Inspection`, `Finding`, `Certificate`), las reglas de estilo de PHP
   7.4 de §4, y que la plantilla de nueve secciones también aplica al track BE.
3. **`prompts/alcance-del-proyecto.md`** — el track BE en la sección de alcance, con
   su declaración explícita de opcionalidad y sus horas fuera del calendario.
4. **`00-convencion-de-git-y-tags.md`** — el namespace `be-fase-*`, el prefijo de
   commit `beNN:`, y la nota de que el "cambio" de `be04` **no es un commit**: es una
   línea del `.env`, y por eso ese incidente no tiene par `-roto`/`-fix`.
5. **`prompts/propuesta-fases-y-alcance.md`** — una línea apuntando aquí, para que
   ese documento siga siendo el índice de encuadre del curso.
6. **`cuaderno-incidentes.md`** y **`prompts/formato-cuaderno-incidentes.md`** — nota
   de que existe un cuaderno hermano para el track BE, con rangos de ID
   independientes.
7. **`CLAUDE.md`** (raíz del repositorio) — dejar registrado en la nota de *File
   Naming Conventions* que este curso adopta la convención `beNN-` / `bea-NN-`.

### 10.2 🪦 La única que toca la ficción publicada — **aprobada y aplicada**

> **Cerrado el 10/09/2026.** La aprobación se dio y el cambio ya está en el curso:
> `00-historia-del-sistema.md` §🗄️ tiene la **«Era 0 (2016-2018) — `certcore-api`,
> la que ya estaba»**, y el README la cita en su sección del track BE. **No hay
> nada que decidir aquí**: lo que sigue se conserva porque explica *por qué* hubo
> que decidirlo, que es lo que un lector de mañana necesita para no reabrirlo.

**El problema.** El README y `00-historia-del-sistema.md` dicen que **CertCore nació
en 2021**. Este track necesita que la API sea de **2016–2018**, porque ahí está el
boom de Lumen, ahí arranca la cadena `9.6 → 11 → 13 → 16`, y de ahí sale la premisa
entera. Tal como está publicado, hay contradicción.

**La salida, que no inventa nada y mejora la historia.** Andina de Certificaciones
S.A.S. **certificaba antes de tener una app Angular**. Lo que nació en 2021 fue el
piloto de campo con dos clientes; el servicio de emisión de certificados existía
desde 2016, cuando la empresa dejó el Excel. La frase que hay que poder decir es:

> 🧠 **CertCore, la aplicación, nació en 2021. `certcore-api`, contra la que habla,
> es de 2016 y nadie la revisó nunca.** Eso es lo que pasa de verdad en las
> empresas, y es la razón de que la forma del contrato sea rara.

**Qué cuesta.** Una frase en el README y un párrafo en `00-historia-del-sistema.md`,
antes de la "Era 1 (2021)": una **Era 0** de dos párrafos. No contradice ninguna de
las tres eras publicadas —las tres hablan del *código Angular*— y de hecho explica
mejor por qué el piloto de 2021 salió en unos meses: había una API esperándolo.

**Por qué esto requiere aprobación explícita.** El `CLAUDE.md` del repositorio
declara *content lock*: una vez publicado un curso, los cambios que rompen deberían
ser raros. Este no rompe nada, pero **añade ficción a un documento cerrado**, y esa
decisión no es del track BE: es del curso. Si se rechaza, la alternativa es fechar
el backend en 2019–2020 y aceptar la cadena `11 → 13 → 16` con un salto menos — se
pierde poco, pero hay que decidirlo antes de escribir `be00`.

---

## ⚖️ 11. Riesgos y decisiones de detalle

### Los cuatro riesgos que hay que vigilar

**Que se convierta en "curso de Lumen".** Es el riesgo grande. La defensa: **cada
fase tiene que poder responder qué deuda cobra y con qué número**. La que no pueda,
sobra. `be01` y `be03` son las más expuestas.

**Enseñar una tecnología que el alumno no va a usar.** Hay que aceptarlo de frente:
nadie va a buscar trabajo de Lumen. El track **no vende Lumen**: vende el método
para diagnosticar un sistema cuya tecnología se volvió un pasivo, y para escribir el
documento que sostiene la decisión. PHP, al menos, es transferible. **Conviene
decirlo en el README con esas palabras.**

**Que Lumen quede como villano.** Sería traicionar el criterio del repositorio. La
defensa está en §3.2 y tiene que aparecer **en `be00`**, antes de la primera
factura: en 2016 fue la decisión sensata y se cobró de verdad durante años.

**El riesgo de contrato.** El frontend consume detalles del dialecto de json-server
que hoy no están inventariados en ninguna parte —el `id` compuesto de las plantillas
es el más traicionero—. Si `be00` los audita mal, `be03` falla y el alumno pierde la
fe en el track. Por eso `be00` se apoya en una **captura real de Network** y no en la
lectura del código del mock.

### Cuatro decisiones de detalle, ya cerradas

**El corte de entrada es la Fase 10.** Es el punto exacto donde el dominio está
completo: existen clientes, activos, plantillas versionadas, inspecciones, hallazgos
y certificados con vigencia. La Fase 11 (dashboard) queda **fuera del contrato
obligatorio**, y con ella un eventual endpoint de estadísticas: hoy las métricas se
calculan en el navegador y ahí se quedan. Se registra como 🔥 en los pendientes de
`be07`.

**El caos se controla por las dos vías**, igual que en el mock, incluida la que
manipula el TTL del token. Apagado por defecto.

**La semilla sale del `db.json` del propio alumno.** No se entrega un dump. Que los
datos que aparecen tras el reemplazo sean exactamente los que el alumno vio en el
track base —la inspección 501 con su v1, la 503 rechazada con su hallazgo crítico—
es la mitad del efecto de `be03`.

Dicho eso, cinco inspecciones no permiten medir nada. Por eso `be05` entrega
**además** volumen sintético —cuatro mil inspecciones, con las violaciones de
invariante ya adentro—, y `bea-11` explica cómo se genera de forma determinista.
Es la única vez que el track entrega datos ajenos, y la fase lo declara.

**PHP 7.4 EOL no se arregla.** Es la premisa, no un pendiente. Cualquier fase que
proponga subir a PHP 8 está proponiendo el trasplante de bootstrap de `be06`, y esa
conversación tiene su sitio: el *assessment* de `be07`.

---

## 🎯 12. Criterio de éxito del track

No es *"el alumno aprendió PHP"*. Es esto, y se verifica:

Puede tomar un contrato de API existente y reimplementarlo sin romper a quien lo
consume. Sabe reconocer una capa de *magia* —facades, Active Record, resolución
dinámica— y **sabe buscar en ella cuando `grep` no sirve**. Sabe leer un archivo
heredado y decir de qué ecosistema venía quien lo escribió, y qué implica eso para
el fix. Sabe que una invariante que ninguna restricción sostiene no está rota: está
esperando. Sabe que un asistente le va a contestar con confianza sobre un framework
que no es el suyo, y sabe cómo verificarlo en diez minutos. Y sabe escribir y
defender un *assessment* de riesgo tecnológico con cuatro opciones costeadas, sin
que la respuesta sea automáticamente *reescribir*.

> **La señal de que quedó bien:** *"levanté el backend de 2016 con mis propias
> manos, medí lo que cuesta tenerlo, escribí las cuatro opciones con números, y
> recomendé la aburrida. Y el frontend nunca se enteró de nada."*
