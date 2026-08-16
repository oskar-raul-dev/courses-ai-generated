# 🅰️ Prompts iniciales por apéndice — Track BE 🔥
## Tutorial Angular 16 — Inspecciones y certificaciones · Backend en PHP 7.4 + Lumen + PostgreSQL

Cada sección es el prompt completo del apéndice, listo para copiar al chat que lo
redacta. Los valores están rellenados con los de `propuesta-fases-backend.md` §8;
si alguna vez cambian allí, se cambian aquí después y **nunca al revés**.

Las horas de los apéndices **no cuentan** en ningún calendario: son consulta bajo
demanda, igual que `a01`-`a13` del track base.

---

## 🧱 Marco común a todos los apéndices del track BE

Este bloque va **al principio de cada prompt de abajo**; se repite a propósito
para que cada sección se pueda copiar sola.

```markdown
## Marco (no lo repitas, aplícalo)

Fuentes de verdad: `prompts/propuesta-fases-backend.md` §8 (manda sobre el
alcance de este apéndice), `prompts/alcance-del-proyecto.md`,
`prompts/guia-de-estilo-y-convenciones.md`, y la **plantilla de apéndice** de
`prompts/plantillas-de-capitulo.md`, que es deliberadamente laxa: encabezado,
índice de salto rápido, secciones cortas con ejemplo mínimo ejecutable, tabla de
"cuándo usar qué", advertencias si aplica, referencias y 5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas del track que no cambian: el frontend no se toca; código en inglés y
comentarios en español con tildes; nada de PHP 8 salvo marcado 🔥 —el runtime es
7.4 a propósito—; **autocontención estricta**, este track no remite a ningún otro
curso del catálogo ni siquiera al de contenedores; y coherencia de la ficción de
CertCore (guía §11), con `certcore-api` fechada en 2016 y descrita en la **Era 0**
de `00-historia-del-sistema.md`.

El cierre lleva su bloque 🏷️ (guía §8.1) en la variante negativa que corresponde
a un apéndice: **sin tag propio**, porque el código que explica lo escriben las
fases, diciendo con qué prefijo se commitea lo que salga de leerlo (`beNN: …`, el
de la fase desde la que se llegó). Enlaza `00-convencion-de-git-y-tags.md`; no lo
reexpliques.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan y
propón si las enlazas o las reescribes desde otro ángulo. Si no tienes el
entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes. Devuélveme: (a) preguntas
bloqueantes, sobre todo **versiones exactas a cubrir** —nada de dar una versión
por buena de memoria; se toma de `propuesta-fases-backend.md` §5—; (b) el índice
de salto rápido que propones; (c) qué crees que ya está en las fases y cómo
piensas evitar repetirlo.
**Paso 2 — Redacción**, cuando yo responda.
**Paso 3 — Autoverificación** contra el checklist de §14 de la guía, en lista
corta.
```

---

## # Apéndice bea-01 — PHP 7.4 y Lumen para quien no escribe PHP

```markdown
Este es el chat del **Apéndice bea-01 — PHP 7.4 y Lumen para quien no escribe
PHP**, del track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único
entregable es `bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-01 — PHP 7.4 y Lumen para quien no escribe PHP
- Horas de referencia: **4h** (no cuentan en ningún calendario)
- Versiones cubiertas: PHP 7.4.33, Lumen 5.x ⚠️ (fija la versión desde §5 de la
  propuesta), Composer 2
- Usado por: **be01** principalmente, y de consulta en todas las demás
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** que un senior de otro lenguaje pueda leer
  y escribir `certcore-api` sin haber escrito PHP nunca, o habiéndolo escrito en
  2012.
- **Secciones esperadas:** Composer, PSR-4 y el autoload; **el modelo de ejecución
  *shared-nothing*** —cada petición arranca de cero, no hay estado entre
  peticiones—, que es la diferencia conceptual grande con cualquier backend de
  proceso persistente y lo que más desorienta a quien viene de Java, Go o Node;
  el tipado gradual de PHP 7.4 y `declare(strict_types=1)`; **los arrays, que son
  lista y mapa a la vez** y son la fuente de la mitad de los bugs sutiles;
  excepciones y el manejo de errores; el ciclo de vida de una petición en Lumen; y
  cómo se lee un stack trace de PHP.
- **Qué queda explícitamente fuera:** todo lo de PHP 8 salvo notas 🔥; Laravel
  completo —se nombra constantemente como contraste pero no se enseña—; los
  facades y el contenedor, que tienen apéndice propio (`bea-03`); y Eloquent, que
  es `bea-04`.
- **Advertencias obligatorias:** casi toda la documentación de PHP y de Laravel en
  línea asume PHP 8 y Laravel 10+. **Y la advertencia que define el track:** un
  asistente te va a contestar en Laravel con total confianza. Cita siempre la
  documentación con versión en la URL, y verifica en tu propio contenedor.
- **Ejercicios:** 8-10 cortos, de consulta, contra el laboratorio propio.
```

---

## # Apéndice bea-02 — Receta de imagen y compose

```markdown
Este es el chat del **Apéndice bea-02 — Receta de imagen y compose**, del track
BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable es
`bea-02-receta-de-imagen-y-compose.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-02 — Receta de imagen y compose
- Horas de referencia: **3h**
- Versiones cubiertas: `php:7.4-cli`, `postgres:16.9`, Composer 2, Docker Compose v2
- Usado por: **be01**, **be04**
- Estado: Base — **es el apéndice más delicado y el que tiene el mejor material
  del track**

## Alcance

- **Qué problema resuelve (una línea):** levantar toda la pila con cuatro
  comandos, sin que el alumno instale PHP, Composer ni `psql`.
- ⚠️ **Autocontención absoluta.** Este es el único punto donde el track toca
  contenedores. Tiene que funcionar de principio a fin **sin remitir a ningún otro
  curso del catálogo**. Si algo necesita explicación larga, se pone resuelto en el
  compose y se explica en dos líneas.
- **Secciones esperadas:** los cuatro comandos del arranque; el `compose.yaml`
  completo y copiable de `propuesta-fases-backend.md` §5.3, con su `healthcheck` y
  su `depends_on: service_healthy`; el `Dockerfile` de §5.4; **el `.env` con
  `POSTGRES_TAG`** y la nota de que la versión de la base vive fuera del código
  fuente, que es lo que hace posible la fase be04; publicar el 5432 bajo demanda;
  y los tres errores que salen siempre.
- ⭐ **La sección estrella del apéndice: la cápsula del tiempo.** El 8/09/2026 el
  primer `docker build` de este track falló así:
  `E: Release file for http://deb.debian.org/debian-security/dists/bullseye-security/InRelease is expired (invalid since 1d 6h 39min 54s)`.
  **El LTS de Debian 11 bullseye —base de `php:7.4-cli`— había caducado el día
  anterior**, y al forzar la fecha el siguiente error fue `404`: los paquetes ya se
  habían movido a `archive.debian.org`. La solución venía escrita **dentro de la
  propia imagen**: su `/etc/apt/sources.list` incluye, comentadas, sus fuentes de
  `snapshot.debian.org` fijadas al `20221114T000000Z`, el día de su build.
  Descomentarlas da un apt determinista, inmune al paso del tiempo.
  > 🧠 La imagen traía escrita su propia cápsula del tiempo y nadie la lee nunca.
  Esto no es un ejemplo didáctico: es **la muerte de una imagen en directo, con
  fecha y mensaje literal**, capturada el día que ocurrió. Escríbelo como tal.
- ⚠️ **Nota de mantenimiento obligatoria:** `archive.debian.org/debian-security`
  todavía no servía `bullseye-security` el día de la prueba. Si
  `snapshot.debian.org` llegara a fallar, el plan B es usar solo `bullseye main`
  desde el archivo. Déjalo escrito: este apéndice va a envejecer.
- **Dato verificado que hay que citar con fecha:** `php:7.4-cli` publica
  `linux/arm64/v8` activo y su **último push es de 2022-11-15** — la imagen se
  congeló el día que PHP 7.4 llegó a EOL. Y el runtime completo (PHP 7.4.33
  aarch64 → PG 16.9 con SCRAM) está probado. **Nada necesita emulación.**
- **Qué queda explícitamente fuera:** nginx y php-fpm —el servidor embebido basta
  para un laboratorio y meter nginx distrae—; multi-stage; Kubernetes.
- **Ejercicios:** 6-8 cortos.
```

---

## # Apéndice bea-03 — El contenedor, los facades y por qué `grep` falla

```markdown
Este es el chat del **Apéndice bea-03 — El contenedor, los facades y por qué
`grep` falla**, del track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su
único entregable es
`bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-03 — El contenedor, los facades y por qué `grep` falla
- Horas de referencia: **4h**
- Versiones cubiertas: Lumen 5.x ⚠️
- Usado por: **be01** ⭐, **be02**
- Estado: Base — **es el apéndice que sostiene la fase insignia**

## Alcance

- **Qué problema resuelve (una línea):** poder investigar una capa de magia cuando
  la herramienta que usas siempre —buscar el nombre en el código— deja de
  encontrar nada.
- 🧭 **El ángulo, que es lo que hace único a este apéndice en todo el repositorio:**
  los dos cursos de Angular están construidos sobre buscar en el código. Aquí hay
  una capa donde **buscar no sirve**, y aprender a moverse en ella es una
  habilidad transferible a cualquier framework con resolución dinámica.
- **Secciones esperadas:** `__callStatic` y cómo un facade se convierte en una
  llamada al contenedor; `__get` y los atributos dinámicos; el contenedor de
  servicios y la diferencia entre *service locator* e inyección por constructor
  —que en be02 se vuelve una huella de procedencia—; **`$app->withFacades()`, que
  en Lumen está apagado por defecto** y es familiaridad falsa en estado puro; qué
  quitó Lumen de Laravel (sesiones, parte de eventos y de middleware); y **el
  método de búsqueda que sí funciona**: seguir el binding en el contenedor,
  `get_class()` en tiempo de ejecución, el stack trace como mapa, y un
  `var_dump` bien puesto.
- **Tabla de "cuándo usar qué" obligatoria:** qué técnica de búsqueda aplicar
  según el síntoma —el método no existe, la clase no existe, el método existe pero
  hace otra cosa—.
- **Qué queda explícitamente fuera:** el diseño de contenedores de inyección en
  abstracto; Eloquent, que es `bea-04` aunque comparta la magia de `__get`
  —enlaza y no repitas—.
- **Ejercicios:** 8-10, todos de búsqueda sobre el código heredado real.
```

---

## # Apéndice bea-04 — Eloquent: lo que absorbe y lo que no

```markdown
Este es el chat del **Apéndice bea-04 — Eloquent: lo que absorbe y lo que no**,
del track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable
es `bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-04 — Eloquent: lo que absorbe y lo que no
- Horas de referencia: **3h**
- Versiones cubiertas: Eloquent de la línea de Lumen 5.x ⚠️, PostgreSQL 16
- Usado por: **be03**, **be04** ⭐
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** saber exactamente qué diferencias de
  dialecto te está tapando el ORM, y por lo tanto **dónde van a aparecer los bugs
  el día que la base cambie de versión**.
- 🧭 **El ángulo:** este apéndice no enseña a usar Eloquent. Enseña dónde deja de
  protegerte. Es la herramienta que hace medible la moraleja de be04 — *la factura
  del salto la paga el código que se saltó las convenciones*.
- **Secciones esperadas:** Active Record y qué implica que el modelo sea también
  la fila; los *scopes* y `__call`; las relaciones y el **N+1**, con medición;
  `DB::select()`, `DB::raw()` y el SQL a mano — **dónde se concentran los bugs**;
  las migraciones y cómo divergen de la base real cuando alguien toca producción a
  mano; y la **tabla de "cuándo usar qué"**: qué diferencias de dialecto absorbe el
  ORM (comillas, placeholders, `LIMIT`/`OFFSET`, booleanos) y cuáles te deja ver
  (casts implícitos, funciones de fecha, `RETURNING`, bloqueo).
- **Qué queda explícitamente fuera:** Doctrine —que se nombra en `bea-09` como el
  monstruo de Symfony y no se enseña—; el diseño de esquema, que es de be03; y la
  optimización fina de consultas.
- **Ejercicios:** 8, cada uno con la consulta SQL real que Eloquent genera, sacada
  del log y no supuesta.
```

---

## # Apéndice bea-05 — Dialectos y saltos de versión en PostgreSQL

```markdown
Este es el chat del **Apéndice bea-05 — Dialectos y saltos de versión en
PostgreSQL**, del track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único
entregable es `bea-05-dialectos-y-saltos-de-version-en-postgresql.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-05 — Dialectos y saltos de versión en PostgreSQL
- Horas de referencia: **4h**
- Versiones cubiertas: la cadena **9.6 → 11 → 13 → 16**
- Usado por: **be04** ⭐
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** saber qué cambia de verdad entre versiones
  mayores, y por qué el 95% no cambia nada — que es justamente lo peligroso.
- 🩻 **Sección "Esto sí funciona igual" obligatoria y larga:** SQL y protocolo de
  cable aguantan muy bien. **La calidad de la compatibilidad hacia atrás de
  Postgres es lo que permitió el abandono de CertCore.** Paradoja real, sin
  villanos: dilo así.
- **Secciones esperadas:** **el directorio de datos no es compatible entre
  versiones mayores** —da igual el SQL: un volumen creado con PG 15 no arranca bajo
  PG 16 sin `pg_upgrade` o dump/restore—; **la autenticación**, con
  `password_encryption` en `scram-sha-256` por defecto desde PG 14 ⚠️ y los
  clientes con `libpq` anterior a la 10 que no lo hablan; `WITH OIDS`, eliminado en
  PG 12 ⚠️; `standard_conforming_strings` y el escapado manual de comillas de la
  era previa ⚠️; los casts implícitos que Postgres retiró ⚠️; y cómo se lee una
  nota de release para saber si te afecta.
- **Todo lo marcado ⚠️ hay que verificarlo contra las notas de release oficiales
  antes de escribir.** Es el contenido central de be04: citarlo de memoria no vale.
- **Dato verificado que hay que citar con fecha (8/09/2026):** la `libpq 13` de
  bullseye que trae `php:7.4-cli` **sí habla SCRAM** contra un PG 16.9. Era la
  verificación que decidía el stack entero.
- **Qué queda explícitamente fuera:** replicación, alta disponibilidad y tuning; y
  la ejecución real de un `pg_upgrade`, que se explica pero no se hace —en el
  laboratorio la versión se cambia con una línea del `.env` y un volumen nuevo—.
- **Ejercicios:** 8-10, con al menos tres de diagnóstico sobre SQL que funcionaba
  en 9.6 y no en 16.
```

---

## # Apéndice bea-06 — Restricciones, claves compuestas y datos sucios

```markdown
Este es el chat del **Apéndice bea-06 — Restricciones, claves compuestas y datos
sucios**, del track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único
entregable es `bea-06-restricciones-claves-compuestas-y-datos-sucios.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-06 — Restricciones, claves compuestas y datos sucios
- Horas de referencia: **3h**
- Versiones cubiertas: PostgreSQL 16
- Usado por: **be05** ⭐
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** poner una restricción sobre una tabla cuyas
  filas ya la violan, sin tumbar producción.
- 🧭 **El ángulo:** el problema no es escribir la restricción. Es que ocho años de
  datos no la cumplen y el sistema tiene que seguir emitiendo certificados mañana.
- **Secciones esperadas:** claves primarias y foráneas **compuestas**, que es lo que
  `templates` + `inspections` necesitaban y no tuvieron; **`NOT VALID` y
  `VALIDATE CONSTRAINT`**, que es el mecanismo central del apéndice —permite poner
  la restricción hoy, que valga para las filas nuevas, y validar las viejas cuando
  se pueda—; `CHECK` con función y sus límites; columnas generadas **y lo que no
  pueden hacer** ⚠️ —**corrección verificada el 11/09/2026**: una columna generada
  exige una expresión **inmutable**, así que `certificates.status`, que depende
  del reloj, **no** se puede resolver con una. El error `generation expression is
  not immutable` es la mejor explicación de por qué ese dato estaba mal guardado
  desde el principio, y la salida correcta es una **vista**, que es lo que hace
  `be05`—; índices únicos parciales; y el procedimiento de despliegue de una
  restricción sin bloquear la tabla.
- **Tabla de "cuándo usar qué" obligatoria:** restricción declarativa, disciplina
  de aplicación, o nada — con el criterio para elegir y qué cuesta cada una.
- **Qué queda explícitamente fuera:** limpiar los datos sucios. En un dominio
  regulado el histórico no se reescribe. Enlaza con la doctrina del track y no la
  contradigas.
- **Ejercicios:** 6-8, todos con el número de filas que violan la restricción como
  criterio de éxito.
```

---

## # Apéndice bea-07 — Tiempo, zonas y `TIMESTAMPTZ`

```markdown
Este es el chat del **Apéndice bea-07 — Tiempo, zonas y `TIMESTAMPTZ`**, del track
BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable es
`bea-07-tiempo-zonas-y-timestamptz.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-07 — Tiempo, zonas y `TIMESTAMPTZ`
- Horas de referencia: **3h**
- Versiones cubiertas: PostgreSQL 16, PHP 7.4 (`DateTimeImmutable`)
- Usado por: **be04**
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** que las fechas de CertCore signifiquen lo
  mismo en la base, en el runtime de PHP y en el navegador.
- **El anclaje al track base:** el `db.json` guarda **todas** las fechas con offset
  `-05:00`, ni una `Z` ni una fecha desnuda, y la Fase 10 tiene una cicatriz
  explícita —*un certificado que "venció ayer" para el servidor y "vence hoy" para
  el navegador*—. Este apéndice explica esa cicatriz desde el servidor.
- **Secciones esperadas:** UTC como única verdad; **`timestamp` sin zona frente a
  `TIMESTAMPTZ`**, que es la distinción que CertCore no hizo en 2016 y que le costó
  la cicatriz; qué guarda de verdad cada uno; `AT TIME ZONE` y cómo se convierte;
  **el TZ del contenedor de PHP como fuente de bugs** —cambia el resultado y no
  aparece en ningún diff—; `DateTimeImmutable` y por qué la versión mutable
  envenena; `America/Bogota`; y la vigencia de un certificado, que es un intervalo
  y no un instante.
- **Qué queda explícitamente fuera:** librerías de fecha de terceros; el horario de
  verano en profundidad —en Colombia no aplica, se nombra para datos de proveedores
  externos y se sigue—.
- **Ejercicios:** 8 cortos, con al menos dos de diagnóstico sobre un certificado
  cuya vigencia cambia según quién pregunte.
```

---

## # Apéndice bea-08 — Seguridad de API sobre un runtime sin parches

```markdown
Este es el chat del **Apéndice bea-08 — Seguridad de API sobre un runtime sin
parches**, del track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único
entregable es `bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-08 — Seguridad de API sobre un runtime sin parches
- Horas de referencia: **4h**
- Versiones cubiertas: PHP 7.4.33 (**EOL desde noviembre de 2022**), Lumen 5.x ⚠️
- Usado por: **be06**, **be07**
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** defender un sistema cuando ya no hay
  parches que aplicar.
- 🧭 **El ángulo, que es lo que lo diferencia de cualquier checklist de OWASP:** el
  runtime está **EOL y eso no se va a arreglar** — es la premisa del track, no un
  pendiente. La pregunta no es "cómo lo actualizo", es "qué hago mientras tanto y
  cómo lo documento".
- **Secciones esperadas:** OWASP aplicado a este dominio —inyección SQL en el
  `DB::select()` con SQL a mano, que es exactamente donde be04 dijo que estaban los
  bugs; autorización a nivel de objeto, que en una certificadora significa que un
  cliente no vea los activos de otro; asignación masiva y `$fillable` en Eloquent;
  qué exponen los mensajes de error—; **las capas de compensación** cuando el
  runtime no se puede parchear: WAF, red, límites de tasa, reducción de superficie;
  y **cómo se documenta y se escala un riesgo aceptado**, que es la parte que
  alimenta el *assessment* de be07.
- **Qué queda explícitamente fuera:** asesoría de seguridad; pruebas de intrusión;
  y cualquier receta que dependa de infraestructura que el alumno no tiene. El
  apéndice enseña a detectar, compensar y escalar — dilo en el cierre con esas
  palabras.
- **Advertencia obligatoria:** el listado de CVEs de PHP 7.4 posteriores a su EOL
  hay que citarlo desde el aviso oficial y con fecha, nunca de memoria, y hay que
  advertir que **la lista crece**: el apéndice envejece por diseño.
- **Ejercicios:** 6-8, ninguno ofensivo: todos de detección y de documentación de
  riesgo.
```

---

## # Apéndice bea-09 — Symfony como vara de medir

```markdown
Este es el chat del **Apéndice bea-09 — Symfony como vara de medir**, del track BE
opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable es
`bea-09-symfony-como-vara-de-medir.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-09 — Symfony como vara de medir
- Horas de referencia: **3h**
- Versiones cubiertas: las LTS de Symfony ⚠️ (2.8, 3.4, 4.4, 5.4, 6.4 — verifícalas)
- Usado por: **be02**, **be06**, **be07** ⭐
- Estado: Base — **es el apéndice que impide que el track sea un curso de Lumen**

## Alcance

- **Qué problema resuelve (una línea):** dar un patrón de comparación real para
  poder decir, con argumentos, qué le faltaba a Lumen.
- 🧭 **El ángulo, y hay que enunciarlo en la primera línea: Symfony es el grupo de
  control, no el paciente.** Perdió como candidato del track por una razón que lo
  vuelve valioso: **no tiene problemas suficientes**. Es enorme, está sano, y su
  disciplina de actualización es famosa y buena. El veredicto honesto sobre un
  Symfony viejo sería *"súbelo, hay camino"*, y eso no sostiene ocho fases.
- **Sus tres papeles en el track, los tres obligatorios:**
  1. **Vara de medir.** Avisos de deprecación, LTS cada dos años, Rector y
     herramientas de upgrade. Es el contraste exacto que hace visible que **Lumen
     no tenía ninguna disciplina de deprecaciones**.
  2. **Origen.** De aquí viene la mitad de los reciclados de be02: el dev de
     Symfony mete inyección por constructor donde el resto usa *service locator*.
  3. **Destino.** Es la opción 2 del *assessment* de be07 — *reescribir a algo
     aburrido y sostenido*.
- **Y dónde sí duele Symfony, para el registro y por honestidad:** el salto de 2/3
  a 4 con Flex, que reestructuró el proyecto entero ⚠️; las cuatro eras de
  configuración conviviendo (XML, YAML, anotaciones, atributos); el contenedor de
  inyección compilado con su clásico *"funciona después de `cache:clear`"*;
  **Doctrine**, que es el monstruo real y duele más que Symfony mismo —migraciones
  que divergen de la base, proxies perezosos, N+1—; y el ecosistema de bundles de
  la era 2.x que murió ⚠️.
- **Qué queda explícitamente fuera:** enseñar Symfony. El alumno no escribe una
  línea. Dilo al principio para que nadie espere un tutorial.
- **Ejercicios:** 6, todos de comparación argumentada, ninguno de código.
```

---

## # Apéndice bea-10 — Mapa de deuda del track BE

```markdown
Este es el chat del **Apéndice bea-10 — Mapa de deuda del track BE**, del track BE
opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable es
`bea-10-mapa-de-deuda-del-track-be.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-10 — Mapa de deuda del track BE
- Horas de referencia: **2h**
- Usado por: **be07**
- Estado: Base — **se escribe al final, cuando las ocho fases están cerradas**
- ⚠️ **No tiene hermano en el track base, y conviene saberlo antes de empezar.**
  El track base **no consolida su deuda en ningún apéndice**: cada fase declara
  sus 💸 en su cuerpo y sus 📌 al cierre, y ahí se quedan. `a12` de este curso es
  `a12-arm64-m1.md` —Apple Silicon—, no un mapa de deuda. Así que este apéndice
  **no copia una estructura existente: la inventa**, y si te parece que debería
  existir la del track base, eso es un 📌 para el chat de cierre, no material de
  aquí.

## Alcance

- **Qué problema resuelve (una línea):** dejar por escrito qué quedó feo a propósito
  en el backend que el alumno acaba de construir, qué lo vuelve exigible, y en qué
  orden se pagaría.
- **Secciones esperadas:** el inventario completo de las 💸 declaradas en las ocho
  fases, cada una con la fase que la declaró y el motivo por el que no se paga; el
  criterio que las ordena; y las que **no se pagan nunca**, con su razón.
- **La deuda insignia del track, que va primera y con su propio apartado:** el
  runtime EOL. No es una deuda que se pague: es una que se documenta, se compensa y
  se escala. Enlaza con `bea-08` y con be07.
- **Regla de coherencia dura:** cada 💸 que aparezca aquí tiene que existir
  literalmente en alguna fase, y cada 💸 de las fases tiene que aparecer aquí. Si al
  escribirlo encuentras una que no cuadra, **no la inventes ni la borres**: dímelo,
  porque significa que una fase está mal.
- **Qué queda explícitamente fuera:** las deudas del track base. **No tienen mapa
  consolidado** —viven en el 💸 de cada fase y en su 📌 de cierre—, así que aquí no
  se listan ni se resumen: se nombra la fase que declaró la que haga falta citar y
  se enlaza ese capítulo. Inventariar la deuda ajena en este apéndice crearía una
  segunda fuente de verdad para algo que el track base ya sostiene repartido.
- **Ejercicios:** 5-6, de priorización argumentada.
```

---

## # Apéndice bea-11 — Datos de prueba y volumen 🔥

```markdown
Este es el chat del **Apéndice bea-11 — Datos de prueba y volumen**, del track BE
opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable es
`bea-11-datos-de-prueba-y-volumen.md`.

[Pega aquí el Marco común del track BE]

## Identidad

- Apéndice bea-11 — Datos de prueba y volumen 🔥 (opcional dentro del track)
- Horas de referencia: **3h**
- Usado por: **be05**
- Estado: Opcional 🔥

## Alcance

- **Qué problema resuelve (una línea):** conseguir cuatro mil inspecciones creíbles
  para que las mediciones de be05 digan algo, sin que los datos generados arruinen
  las pruebas.
- **Secciones esperadas:** la semilla desde el `db.json` del propio alumno, que es
  la fuente por defecto de todo el track; la generación del volumen de **be05**
  —cuatro mil inspecciones con las violaciones de invariante ya adentro—
  documentada para que sea reproducible; **datos deterministas con semilla fija**;
  y la sección que justifica el apéndice entero: **por qué un dataset aleatorio
  arruina una prueba de regresión**. El faker es una herramienta de carga y de
  medición, no de aserción.
- **Coherencia con el dominio:** los datos generados tienen que respetar el flujo
  real —una inspección `approved` sin hallazgos `critical`, un certificado solo
  sobre una inspección aprobada—. Un dataset que viola el dominio hace que las
  consultas de be05 encuentren violaciones falsas, y entonces la fase miente.
- **Qué queda explícitamente fuera:** anonimización de datos reales de clientes. Se
  nombra el problema —es un dominio regulado— y se remite al equipo de
  cumplimiento, sin dar receta.
- **Advertencia obligatoria:** los datos generados nunca entran a una colección que
  el `smoke.sh` audite. Si lo hacen, el contrato deja de ser verificable.
- **Ejercicios:** 6-8.
```

---

## 🧾 Recordatorio de cierre del track

Con los once apéndices escritos, del track BE quedan pendientes:

1. ✅ **`cuaderno-incidentes-be.md`** — **escrito el 11/09/2026** con los doce
   incidentes reservados en `prompts-backend-fase.md` (`be-01` … `be-12`), más
   `prompts/preparaciones-de-incidentes-be.md` con su estado roto.
2. **Las adiciones de encuadre de §10 de `propuesta-fases-backend.md`**, que se
   hacen **antes** de escribir `be00`.
