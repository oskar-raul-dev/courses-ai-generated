# 📎 Apéndice bea-07 — Tiempo, zonas y `TIMESTAMPTZ`

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **3 horas**
> Usado por: **be04** · Versiones cubiertas: **PostgreSQL 16**, **PHP 7.4** (`DateTimeImmutable`)
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido.** Se entra con un síntoma —*"venció ayer para uno y hoy para otro"*— y se sale sabiendo en qué capa se perdió la información.

**Qué problema resuelve:** que las fechas de CertCore signifiquen **lo mismo** en la base, en el runtime de PHP y en el navegador. Hoy no lo significan, y este apéndice explica la cicatriz desde el lado del servidor.

**Qué queda fuera:** librerías de fecha de terceros —con `DateTimeImmutable` sobra para todo lo que hace este sistema—; y el horario de verano en profundidad: **en Colombia no aplica**, y se nombra sólo porque los datos de proveedores externos sí pueden traerlo.

---

## Índice

- [El anclaje: la cicatriz que ya conoces](#el-anclaje-la-cicatriz-que-ya-conoces)
- [`timestamp` frente a `TIMESTAMPTZ`: qué guarda cada uno](#timestamp-frente-a-timestamptz-qué-guarda-cada-uno)
- [Las tres zonas que intervienen, y cuál gana](#las-tres-zonas-que-intervienen-y-cuál-gana)
- [`AT TIME ZONE`, en los dos sentidos](#at-time-zone-en-los-dos-sentidos)
- [El TZ del contenedor de PHP, que no aparece en ningún diff](#el-tz-del-contenedor-de-php-que-no-aparece-en-ningún-diff)
- [`DateTimeImmutable`, y por qué la versión mutable envenena](#datetimeimmutable-y-por-qué-la-versión-mutable-envenena)
- [La vigencia de un certificado es un intervalo, no un instante](#la-vigencia-de-un-certificado-es-un-intervalo-no-un-instante)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-8)

---

## El anclaje: la cicatriz que ya conoces

El `db.json` del track base guarda **todas** las fechas con offset `-05:00`. Ni una `Z`, ni una fecha desnuda. Eso fue una decisión buena de quien escribió la semilla, y no sirvió de nada, porque del otro lado del cable la columna es `timestamp` **sin zona** y el offset **se descarta al insertar, en silencio**:

```sql
-- Lo que entró:    "2024-06-30T12:00:00-05:00"
-- Lo que quedó:
SELECT valid_until, pg_typeof(valid_until) FROM certificates LIMIT 1;
--   2024-06-30 12:00:00 | timestamp without time zone
```

De ahí sale, literalmente, el síntoma de la Fase 10 del track base: *"venció ayer para el servidor y vence hoy para el navegador"*. No es un bug de fechas. **Es que nadie decidió a qué hora, y en qué zona, vence un certificado.**

> 🧠 **Una fecha sin zona no es ambigua: significa cosas distintas según quién la lea, y ninguna lectura es detectablemente errónea.** Por eso nadie reporta el bug: cada uno ve un dato coherente consigo mismo.

---

## `timestamp` frente a `TIMESTAMPTZ`: qué guarda cada uno

La confusión universal, y se deshace con una frase: **`TIMESTAMPTZ` no guarda la zona.**

| | `timestamp` (sin zona) | `timestamptz` (con zona) |
|---|---|---|
| Qué guarda | Una **fecha y hora de pared**, sin referencia | Un **instante absoluto**, normalizado a UTC |
| Qué hace al escribir | **Ignora** el offset que le mandes | **Usa** el offset para convertir a UTC |
| Qué hace al leer | Devuelve lo que guardó | Convierte a la zona de la sesión (`TimeZone`) |
| Cuándo es correcto | Un día de calendario, una hora local de un sitio fijo | **Cualquier instante real**: cuándo pasó algo |
| Almacenamiento | 8 bytes | 8 bytes — **cuesta lo mismo** |

```sql
SET TimeZone = 'America/Bogota';
SELECT
  '2024-06-30T12:00:00-05:00'::timestamp   AS sin_zona,    -- 2024-06-30 12:00:00
  '2024-06-30T12:00:00-05:00'::timestamptz AS con_zona;    -- 2024-06-30 12:00:00-05

SET TimeZone = 'UTC';
SELECT
  '2024-06-30T12:00:00-05:00'::timestamp   AS sin_zona,    -- 2024-06-30 12:00:00  ← IGUAL
  '2024-06-30T12:00:00-05:00'::timestamptz AS con_zona;    -- 2024-06-30 17:00:00+00 ← el MISMO instante
```

Mira las dos columnas de la derecha. `timestamptz` dice dos cosas distintas que significan **lo mismo**; `timestamp` dice lo mismo en dos contextos donde significa **cosas distintas**. Ese es todo el asunto.

> 🧭 **La regla, y no tiene excepciones útiles:** si lo que guardas es *cuándo pasó algo*, es `TIMESTAMPTZ`. Si lo que guardas es *un día del calendario* —una fecha de instalación, una fecha de vigencia sin hora—, es `date`. `timestamp` sin zona queda para el caso raro de una hora de pared local que no representa un instante: un horario de apertura, una alarma que suena a las 8 esté donde esté.

En CertCore: `installed_at`, `valid_from` y `valid_until` de plantillas son `date` y están **bien**. `started_at`, `completed_at`, `resolved_at`, `issued_at`, `revoked_at` y `certificates.valid_until` son instantes y están en `timestamp` **sin zona**, y eso es la deuda 💸 4.

---

## Las tres zonas que intervienen, y cuál gana

En cada petición de CertCore hay tres relojes y tres zonas, y ninguna está declarada en ningún sitio del código:

1. **La zona de la sesión de PostgreSQL** (`SHOW TimeZone`). Decide cómo se muestra un `timestamptz` y qué devuelve `now()`. Por defecto, la del servidor — que en el contenedor oficial es **UTC**.
2. **La zona del runtime de PHP** (`date_default_timezone_get()`). Decide qué imprime `date()`, cómo se interpreta una cadena sin offset, y qué instante es "ahora" para el código. Por defecto, **UTC** también, salvo que alguien ponga `date.timezone` en el `php.ini`… o una variable `TZ` en el `compose.yaml`.
3. **La zona del navegador.** Decide qué ve el usuario. En CertCore, casi siempre `America/Bogota`.

```bash
docker compose exec db  psql -U postgres certcore -c "SELECT now(), current_setting('TimeZone');"
docker compose exec api php -r 'echo date_default_timezone_get(), " | ", date("c"), "\n";'
```

Cuando las tres coinciden, el sistema parece correcto. **Y no lo es: sólo está en un estado donde el defecto no se nota.** Cambia una de las tres y el bug aparece sin que nadie haya tocado un dato.

---

## `AT TIME ZONE`, en los dos sentidos

El operador que más se usa mal, porque hace dos cosas opuestas según el tipo que recibe:

```sql
-- De SIN zona a instante: "esta hora de pared, interpretada en Bogotá".
SELECT '2024-06-30 12:00:00'::timestamp AT TIME ZONE 'America/Bogota';
--   2024-06-30 17:00:00+00     → devuelve TIMESTAMPTZ

-- De instante a hora de pared: "este instante, visto desde Bogotá".
SELECT '2024-06-30T17:00:00Z'::timestamptz AT TIME ZONE 'America/Bogota';
--   2024-06-30 12:00:00        → devuelve TIMESTAMP sin zona
```

**Aplicado a CertCore**, es la consulta que recupera el significado perdido: los datos entraron asumiendo `-05:00`, así que interpretarlos en `America/Bogota` reconstruye el instante que se quiso guardar.

```sql
-- Los certificados vencidos, leyendo bien las fechas heredadas.
SELECT id, valid_until AT TIME ZONE 'America/Bogota' AS vence_instante
FROM certificates
WHERE (valid_until AT TIME ZONE 'America/Bogota') < now();
```

> ⚠️ **Esa consulta es correcta sólo porque asumimos que todos los datos entraron con `-05:00`.** Esa suposición está fuera de la base, la sostiene el `db.json`, y **nadie la verifica**. Si un solo registro entró desde otra zona, esa fila queda mal para siempre y no hay manera de saber cuál es. Es exactamente por eso que la migración a `TIMESTAMPTZ` se costea en [`be04`](be04-el-salto-de-version-que-nadie-corrio.md) y no se ejecuta a la ligera: **al convertir hay que elegir una zona de origen, y esa elección es irreversible**.

---

## El TZ del contenedor de PHP, que no aparece en ningún diff

La fuente de bugs más silenciosa del sistema, porque **cambia el resultado y no está en el código**:

```yaml
  api:
    environment:
      TZ: America/Bogota      # ← una línea del compose. Ningún archivo PHP cambia.
```

Con esa línea puesta o quitada, este código devuelve días distintos:

```php
// Interpretación de una cadena SIN offset: usa la zona por defecto del runtime.
$when = new DateTimeImmutable('2024-06-30 23:30:00');
echo $when->format('Y-m-d');   // depende del TZ del proceso
```

Es primo hermano del `POSTGRES_TAG` de [`be04`](be04-el-salto-de-version-que-nadie-corrio.md): **configuración que despliega sin pasar por un commit.** Cuando un cálculo de fechas falle en un entorno y no en otro, la primera pregunta no es qué código cambió — es **qué zona tiene cada proceso**.

La defensa, y es de una línea: **fija la zona explícitamente en el arranque de la aplicación** en vez de heredarla del entorno.

```php
// server/bootstrap/app.php
date_default_timezone_set('UTC');   // explícito, versionado, reproducible
```

---

## `DateTimeImmutable`, y por qué la versión mutable envenena

PHP tiene dos clases casi idénticas, y una de ellas muerde:

```php
$issued = new DateTime('2024-06-30 12:00:00');
$expires = $issued->add(new DateInterval('P1Y'));
echo $issued->format('Y-m-d');    // 2025-06-30  ← ¡$issued CAMBIÓ!

$issued = new DateTimeImmutable('2024-06-30 12:00:00');
$expires = $issued->add(new DateInterval('P1Y'));
echo $issued->format('Y-m-d');    // 2024-06-30  ← intacto
```

`DateTime::add()` **modifica el objeto y además devuelve `$this`**. Si lo pasas a una función que lo modifica, tu variable cambia sin que nadie la asigne — y en un cálculo de vigencias eso significa emitir un certificado con la fecha equivocada sin un solo error en ningún log.

> 🧭 **Usa `DateTimeImmutable` siempre. Sin excepciones, sin discusión.** Y si encuentras `DateTime` en el código heredado, no lo cambies a lo loco: comprueba primero si alguien depende de la mutación. Cambiarlo es correcto y no es gratis.

Y el par que hace falta para trabajar con instantes:

```php
// Leer una cadena CON offset: el offset manda, la zona del proceso da igual.
$when = new DateTimeImmutable('2024-06-30T12:00:00-05:00');

// Emitir siempre con offset explícito: 'c' es ISO 8601 completo.
echo $when->format('c');           // 2024-06-30T12:00:00-05:00

// Comparar instantes: los objetos se comparan directamente y es correcto.
if ($when < new DateTimeImmutable('now')) { /* ya pasó */ }
```

---

## La vigencia de un certificado es un intervalo, no un instante

El error conceptual de fondo, y el que ninguna migración de tipos arregla sola:

> **"El certificado vence el 30 de junio" no es una fecha: es una pregunta sin contestar.** ¿A las 00:00 del 30 o a las 23:59:59? ¿En la zona de quién? ¿El día 30 está dentro o fuera?

Mientras eso no esté escrito en algún sitio, el sistema tendrá **dos respuestas defendibles** para "¿está vigente?", y las dos aparecerán: una en el panel, otra en el PDF. La solución no es técnica en su primer paso — es **decidir y escribirlo**:

> *La vigencia de un certificado de CertCore termina al final del día calendario de `valid_until`, en `America/Bogota`. Un certificado cuyo `valid_until` es el 30 de junio está vigente hasta las 23:59:59 del 30 de junio, hora de Bogotá.*

Con esa frase escrita, la implementación es una línea en cada capa y todas dicen lo mismo. Sin ella, `TIMESTAMPTZ` sólo hace que las dos respuestas sean más precisas.

---

## 🧭 Cuándo usar qué

| Qué guardas | Tipo | Por qué |
|---|---|---|
| Cuándo pasó algo (inicio, emisión, resolución) | **`timestamptz`** | Es un instante; debe significar lo mismo para todos |
| Un día de calendario (instalación, vigencia de plantilla) | **`date`** | No tiene hora y añadirla inventa precisión |
| Una hora de pared local sin instante (horario de apertura) | `timestamp` | El caso raro y legítimo del tipo sin zona |
| Una duración | `interval` o entero de segundos | No es un instante |
| Un momento en PHP | **`DateTimeImmutable`** | `DateTime` muta y envenena por referencia |
| Emitir una fecha al cliente | `->format('c')` | ISO 8601 con offset explícito, como el `db.json` |
| Leer una fecha heredada sin zona | `AT TIME ZONE 'America/Bogota'` | Reconstruye la suposición de origen — **declárala** |
| "Ahora" en una consulta | `now()` con `timestamptz` | Con `timestamp` sin zona, "ahora" depende de la sesión |

---

## ⚠️ Advertencias

**Migrar a `TIMESTAMPTZ` obliga a elegir una zona de origen, y esa elección es irreversible.** El dato guardado no dice de dónde vino. En CertCore se asume `-05:00` porque lo dice el `db.json`, y esa suposición hay que escribirla en la migración, no dejarla implícita en la cabeza de quien la ejecutó.

**En Colombia no hay horario de verano, y eso oculta la mitad de los bugs.** `America/Bogota` es `-05:00` todo el año, así que un sistema que confunde offset fijo con zona horaria **funciona** aquí. El día que llegue un dato de un proveedor en `America/Santiago` o en `Europe/Madrid`, el error aparece de golpe y sin relación aparente con nada. Guarda zonas, no offsets.

**El `smoke.sh` no detecta un cambio de formato de fecha** si sólo comprueba tipos y presencia de campos (be03, ejercicio 🧨). Un contrato ejecutable que no comprueba el formato de las fechas deja pasar exactamente la familia de bugs de este apéndice.

---

## 📚 Referencias

- https://www.postgresql.org/docs/16/datatype-datetime.html — los tipos de fecha y hora, con la explicación de qué guarda cada uno. La sección de `timestamptz` merece leerse dos veces.
- https://www.postgresql.org/docs/16/functions-datetime.html — `AT TIME ZONE`, `now()`, `date_trunc()` y `age()`.
- https://www.php.net/manual/es/class.datetimeimmutable.php y https://www.php.net/manual/es/class.datetime.php — las dos clases, para comparar la firma de `add()` en cada una.
- https://www.php.net/manual/es/datetime.formats.php — cómo interpreta PHP una cadena de fecha, que es donde se decide si el offset manda o manda el TZ del proceso.
- https://www.iana.org/time-zones — la base de datos de zonas horarias. Lo que se guarda es un identificador de aquí (`America/Bogota`), nunca un offset.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos. Y con las zonas horarias en particular, **desconfía de cualquier consejo que hable de offsets fijos**: los offsets cambian por decisión política, y ha pasado varias veces en América Latina en los últimos treinta años.

---

## 🧪 Ejercicios (8)

1. Ejecuta las dos consultas de comparación entre `timestamp` y `timestamptz` con `SET TimeZone` en `America/Bogota` y en `UTC`. Pega las cuatro salidas y explica en dos líneas cuál de las dos columnas conserva el significado.
2. Comprueba las tres zonas del sistema —base, PHP, navegador— y anótalas. ¿Coinciden? Si coinciden, cambia una y describe qué se rompe.
3. **Diagnóstico.** Toma un certificado concreto y calcula su estado de tres maneras: desde `psql`, desde PHP, y desde la pantalla. ¿Coinciden las tres? Si sí, cambia el TZ del contenedor y repite.
4. Escribe la consulta que reinterpreta `valid_until` en `America/Bogota` y compara sus resultados con la consulta ingenua. Cuenta cuántos certificados cambian de estado.
5. **Diagnóstico.** Demuestra con código la mutación de `DateTime::add()` y su ausencia en `DateTimeImmutable`. Después busca `new DateTime(` en `server/app/` y decide, caso por caso, si cambiarlo sería seguro.
6. Escribe la frase que define la vigencia de un certificado de CertCore, y después impleméntala en las dos capas —la consulta SQL y el cálculo en PHP— comprobando que dan el mismo resultado en los bordes: las 23:59:59 y las 00:00:00.
7. **Diagnóstico.** Añade `TZ: America/Bogota` al servicio `api` del compose, recrea el contenedor y busca **una** diferencia observable en la aplicación sin haber tocado una línea de código. Documéntala.
8. **Diagnóstico.** Escribe la comprobación que le falta al `smoke.sh`: que cada fecha del contrato viaja con offset explícito, en formato ISO 8601. Haz que falle emitiendo una fecha sin offset, y después que pase.

---

> 🏷️ **Este apéndice no lleva tag propio.** Lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be04: …`). Dos cosas conviene conservar porque otras fases las citan: la frase de definición de vigencia del ejercicio 6 —que en be05 se convierte en una restricción— y la comprobación del ejercicio 8, que se incorpora al `smoke.sh` y a partir de ahí es contrato. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
