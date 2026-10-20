# 🧰 Preparaciones de los incidentes — Track BE 🔥
## Tutorial Angular 16 — Inspecciones y certificaciones · Backend en PHP 7.4 + Lumen + PostgreSQL

Este documento **no lo lee el estudiante**. Es material de autoría, como el bloque
📌 de cada fase: contiene el **estado roto** de cada incidente de
[`cuaderno-incidentes-be.md`](../cuaderno-incidentes-be.md), o sea exactamente la
respuesta que el estudiante tiene que encontrar por su cuenta.

> ⚠️ **Quien vaya a resolver el cuaderno no abre este archivo.** Abrirlo es peor
> que abrir la pista 3: la pista 3 te deja la pregunta cuya respuesta es la causa;
> esto te deja el `git diff`. Si estás haciendo el track, cierra la pestaña.

**Por qué existe.** La §🔥 de
[`formato-cuaderno-incidentes.md`](formato-cuaderno-incidentes.md) define **cómo**
llega el sistema roto a la máquina del estudiante en este track —un flag del caos,
una tabla sembrada, **una línea del `.env`**, o una rama `incidente-be/NN`—, y los
doce enunciados usan ese mecanismo. Lo que no estaba escrito en ninguna parte era
**el contenido**: qué línea rompe cada rama y qué filas cambia cada guion de
siembra.

**Es el hermano de [`preparaciones-de-incidentes.md`](preparaciones-de-incidentes.md)**,
el del track base, y está aparte por la misma razón por la que los cuadernos están
separados: un estudiante que sólo hace el track base no debe recibir preparaciones
de PostgreSQL mezcladas con las suyas.

**Quién lo aplica.** Igual que en el track base, hay dos formas y las dos son
legítimas: **el propio estudiante**, preparando las cuatro ramas y los cinco
guiones de una sentada antes de empezar y sin leer las secciones *"Qué se rompe"*
más allá de lo necesario; o **quien coordine el onboarding**, que es la forma
buena.

---

## Índice

- [1. Cómo se usa este documento](#1-cómo-se-usa-este-documento)
- [2. Mapa: qué necesita cada incidente](#2-mapa-qué-necesita-cada-incidente)
- [3. Las cuatro ramas](#3-las-cuatro-ramas)
- [4. Los cinco guiones de `sql/`](#4-los-cinco-guiones-de-sql)
- [5. La línea del `.env`, que es la propia del track](#5-la-línea-del-env-que-es-la-propia-del-track)
- [6. Las tres que no necesitan preparación](#6-las-tres-que-no-necesitan-preparación)
- [7. Verificar que la preparación sirve](#7-verificar-que-la-preparación-sirve)
- [⚠️ Advertencias](#️-advertencias)

---

## 1. Cómo se usa este documento

Cada receta trae cuatro cosas y siempre las mismas:

1. **De dónde sale** — el tag de la fase BE. En este track los tags son
   **`be-fase-` + el número y el slug completo**
   (`be-fase-04-el-salto-de-version-que-nadie-corrio`), según
   [`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md) §🔥. Las
   ramas llevan namespace propio: **`incidente-be/NN`**.
2. **Qué archivo se toca** — la ruta exacta dentro de `server/`, `sql/` o
   `scripts/`.
3. **El cambio** — el antes y el después, escrito **en el estilo de la parcela que
   se toca** 🧬 según `ESTRATOS.md` (be02): helpers y *service locator* en la
   parcela `laravel`, `declare(strict_types=1)` e inyección por constructor en la
   `symfony`. Una preparación escrita en el estilo equivocado no es una
   preparación: es una pista falsa.
4. **Cómo se revierte** — siempre, y siempre en una línea.

Y una regla propia de este track: **nada de PHP 8 en las preparaciones**. El
runtime es 7.4 y una preparación que no arranca no es una preparación.

---

## 2. Mapa: qué necesita cada incidente

| ID | Fase | Forma | Artefacto |
|---|---|---|---|
| be-01 | be01 (rama desde be03) | Rama | `incidente-be/01` |
| be-02 | be01 | Rama | `incidente-be/02` |
| be-03 | be02 (desde be03) | Siembra | `sql/seed-incidente-be-03.sql` |
| be-04 | be03 | **Ninguna** | El sistema ya está así desde be03 |
| be-05 | be03 | Siembra | `sql/seed-incidente-be-05.sql` |
| be-06 | be04 | **`.env`** + siembra | `POSTGRES_TAG` · `sql/seed-incidente-be-06.sql` |
| be-07 | be04 | Rama | `incidente-be/07` |
| be-08 | be04 | Siembra | `sql/seed-incidente-be-08.sql` |
| be-09 | be05 | Volumen + siembra | `volume.php` · `sql/seed-incidente-be-09.sql` |
| be-10 | be05 | Rama + volumen | `incidente-be/10` · `volume.php` |
| be-11 | be06 | **Ninguna** | El sistema ya está así |
| be-12 | be07 | **Ninguna** | El informe va en el enunciado |

**Cuatro ramas, cinco guiones de siembra, una línea del `.env` y tres sin nada.**
El reparto no es casual y conviene defenderlo: en el track base dieciséis de los veintidós
incidentes necesitaban rama, porque casi todo el daño estaba en el código. Aquí
**la mitad está en el dato o en la configuración**, y eso es exactamente lo que un
backend añade al curso.

> 📝 **Ningún incidente usa el flag del caos**, aunque la forma existe y está
> documentada. No es un olvido: el inyector de caos ya se ejercita entero en los
> ejercicios de be01 y en los de la Fase 3 del track base repetidos contra el
> backend nuevo. Un incidente de caos aquí sería una repetición, y el cuaderno
> tiene doce entradas para gastar. **La forma se mantiene documentada porque es la
> más barata y hay que ofrecerla primero cada vez que se diseñe un incidente
> nuevo.**

---

## 3. Las cuatro ramas

### `incidente-be/01` — el caché sin caducidad ni invalidación

**De dónde sale:** `be-fase-03-el-reemplazo` (hace falta la base y el camino viejo en `/legacy/templates`)
**Qué se toca:** `server/app/Http/Controllers/LegacyTemplateController.php`
**Parcela:** `laravel` — helpers, *service locator*, sin tipos ni `declare`.

```php
// ANTES (lo que hay en el tag: la versión de be02 §5.1)
public function index()
{
    // Service locator: la dependencia se pide donde se usa, no se declara.
    $cached = app('cache')->get('templates.all');

    if ($cached) {
        return $cached;
    }

    $rows = Template::active()->get();

    return response()->json(collect($rows)->values());
}

// DESPUÉS (el commit de la rama). Arriba, junto a los otros `use`, también `use Cache;`:
// el alias es global y desde App\Http\Controllers no se ve sin importarlo.
public function index()
{
    // Cacheado durante el incidente de rendimiento de marzo. Funcionó.
    $cached = Cache::get('templates.all');

    if ($cached) {
        return $cached;
    }

    $rows = Template::active()->get();
    Cache::put('templates.all', $rows);   // ← sin tercer argumento: para siempre

    return response()->json(collect($rows)->values());
}
```

**Qué se rompe.** `Cache::put()` sin tiempo de vida guarda indefinidamente en la
línea 5.8 de Illuminate, y el almacén por defecto es de archivo: **sobrevive al
reinicio del contenedor**. Nadie invalida la clave al publicar, y el que publica es
el controlador de la **otra** parcela.

⚠️ **La rama tiene que encender los facades** para que `Cache::` resuelva
(`$app->withFacades()` en `bootstrap/app.php`), **o** usar `app('cache')`. Se elige
lo primero **a propósito**: encendidos, el `grep` vacío de la pista 1 es más
desconcertante, y encima deja el sistema en el tercer estado de
[`bea-03`](../bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md) —facades a
medias—, que es el realista. El commit de la rama incluye las dos líneas.

**Cómo se revierte:** `git switch -` y borrar la rama.

---

### `incidente-be/02` — el proveedor de servicios copiado de Laravel

**De dónde sale:** `be-fase-01-lumen-y-la-familiaridad-falsa`
**Qué se toca:** `server/app/Providers/TimingServiceProvider.php` (nuevo) y
`server/bootstrap/app.php`.

```php
<?php
// server/app/Providers/TimingServiceProvider.php — ARCHIVO NUEVO
// Pegado tal cual de una respuesta de internet. Es Laravel válido.

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Log;
use App\Http\Middleware\TimingMiddleware;

class TimingServiceProvider extends ServiceProvider
{
    public function boot()
    {
        $this->app['router']->aliasMiddleware('timing', TimingMiddleware::class);
        Log::info('timing middleware registrado');
    }
}
```

```php
// server/bootstrap/app.php — una línea añadida
$app->register(App\Providers\TimingServiceProvider::class);
```

**Qué se rompe.** `Laravel\Lumen\Routing\Router` no tiene `aliasMiddleware()`: es
del router de Laravel. Fatal al arrancar: el preflight de `compose.yaml` arranca los
proveedores antes de servir, el contenedor sale con `Exited (255)` y el estudiante ve
*"arranca y se muere solo"*.

**Y el segundo bug, que es el que hace bueno el incidente:** aunque se arregle el
primero, `Log::info()` falla con `A facade root has not been set.` porque los facades
están apagados (el `use` apunta a la clase del facade, que existe, pero nadie la conectó
al contenedor). **Dos bugs en cinco líneas copiadas, y el primero tapa al segundo.**

⚠️ El middleware `TimingMiddleware` **sí existe** en la rama y está bien escrito
(`server/app/Http/Middleware/TimingMiddleware.php`: mide `microtime(true)` alrededor de
`$next($request)` y pone la cabecera `X-Response-Time-Ms`).
Que la pieza que el compañero programó esté correcta y lo que falle sea el pegote
es deliberado: el error no está en saber PHP.

**Cómo se revierte:** `git switch -`.

---

### `incidente-be/07` — el guion de respaldo de 2016

**De dónde sale:** `be-fase-04-el-salto-de-version-que-nadie-corrio`
**Qué se toca:** `scripts/backup.sh` (nuevo, fechado en 2016 en el mensaje del
commit).

```bash
#!/usr/bin/env bash
# scripts/backup.sh — respaldo nocturno. Escrito en 2016, no tocado desde entonces.
# NOTA DE AUTORÍA: la ausencia de `set -euo pipefail` es EL bug, no un descuido
# de quien escribe esta preparación. Sin ella los psql fallan y el tar corre igual.

DEST="${DEST:-/tmp/certcore-backups}"
PGDATA="${PGDATA:-/var/lib/postgresql/data}"
mkdir -p "$DEST"

psql -U postgres -c "SELECT pg_start_backup('nightly')"
tar czf "$DEST/certcore-$(date +%F).tar.gz" "$PGDATA" 2>/dev/null
psql -U postgres -c "SELECT pg_stop_backup()"
psql -U postgres -c "SELECT pg_switch_xlog()"

echo "respaldo completado: $DEST/certcore-$(date +%F).tar.gz"
```

**Qué se rompe.** Dos veces y en dos versiones distintas:

| Función | Retirada en | Cita |
|---|---|---|
| `pg_switch_xlog()` | **PG 10** | *"Rename SQL functions, tools, and options that reference "xlog" to "wal""* |
| `pg_start_backup()` / `pg_stop_backup()` | **PG 15** | *"Remove long-deprecated exclusive backup mode […] renamed to `pg_backup_start()`/`pg_backup_stop()`"* |

Y como no hay `set -e`, el guion **imprime "respaldo completado"** después de haber
fallado dos veces. El archivo existe, pesa lo normal, y es un `tar` de un directorio
de datos que se estaba escribiendo.

**Dónde se ejecuta.** Dentro del contenedor de la base —`docker compose exec -T db bash < scripts/backup.sh`—,
que es donde están `psql` y el directorio de datos. Medido en el laboratorio:

| Escalón | Qué pasa |
|---|---|
| 9.6 con `wal_level=replica` | Todo responde y el respaldo es bueno. (Con el `minimal` por defecto de la imagen 9.6, `pg_start_backup` falla: el proveedor lo tenía en `replica`; para reproducir 2016 hay que arrancar la base con `-c wal_level=replica`.) |
| 11 y 13 | `pg_start_backup`/`pg_stop_backup` funcionan; sólo falla `pg_switch_xlog()`, **después** del `tar`. El respaldo sigue sirviendo. |
| 16.9 | Fallan `pg_start_backup` y `pg_stop_backup`: el `tar` copia un directorio de datos vivo sin modo respaldo. Imprime «respaldo completado» y el archivo pesa lo normal (6,6 MB con la semilla). |

⚠️ **El `echo` final es imprescindible en la preparación.** Sin él, el estudiante ve
un guion que evidentemente falló; con él, ve el escenario real — un proceso nocturno
que dice que todo salió bien.

**Cómo se revierte:** `git switch -`.

---

### `incidente-be/10` — el proceso de cierre de mes

**De dónde sale:** `be-fase-05-la-invariante-que-no-sostenia-nadie` (con la
restricción **ya puesta**: es el despliegue "de ayer" del ticket)
**Qué se toca:** `server/app/Console/Commands/ArchiveInspections.php` (nuevo).
**Parcela:** `laravel` — es un proceso viejo, y su estilo tiene que decirlo.

```php
<?php
// server/app/Console/Commands/ArchiveInspections.php
// Cierre de mes. Escrito hace años, corre el primer día hábil del mes.

namespace App\Console\Commands;

use Illuminate\Console\Command;

class ArchiveInspections extends Command
{
    protected $signature = 'certcore:archive {--year=}';

    public function handle()
    {
        $year = $this->option('year');
        $db = app('db');

        // Archivar es MOVER la fila: se borra y se vuelve a insertar con status
        // 'archived'. Así lo exige el disparador de auditoría de 2017, que sólo
        // registra INSERT. Las que tienen certificado las archiva otro proceso.
        $rows = $db->table('inspections')
            ->whereYear('started_at', $year)
            ->where('status', 'approved')
            ->whereNotExists(function ($query) {
                $query->from('certificates')->whereColumn('certificates.inspection_id', 'inspections.id');
            })
            ->orderBy('id')
            ->get();

        $moved = 0;

        // Una sola transacción para todo el año: si una fila falla, falla el año entero
        // y el mes se queda a medias — que es exactamente el síntoma del ticket.
        $db->transaction(function () use ($db, $rows, &$moved) {
            foreach ($rows as $row) {
                $data = (array) $row;
                $data['status'] = 'archived';

                $db->table('inspections')->where('id', $row->id)->delete();
                $db->table('inspections')->insert($data);   // ← el INSERT sí revalida la FK
                $moved++;
            }
        });

        $this->info("archivadas: {$moved}");
    }
}
```

Y el comando se registra en `$commands` de `server/app/Console/Kernel.php`.

**Qué se rompe.** El proceso no archiva con un `UPDATE`: **mueve** la fila, con `DELETE` e
`INSERT`, porque el disparador de auditoría de 2017 sólo registra inserciones. Para la
foránea compuesta `NOT VALID` de be05, la fila reinsertada **es una fila nueva**, y se
comprueba: las ochenta y ocho huérfanas de 2023 la violan, la transacción del año entero se
deshace y no archiva ninguna. Un `UPDATE` de sólo el estado **no** habría fallado —PostgreSQL
no revisa la foránea si la clave no cambia (be05 §5.3)—, y es justo lo que despista.

Medido en el laboratorio: `--year=2023` falla con
`Key (template_id, template_version)=(elevator-annual, 3) is not present in table "templates"`
y deja 0 archivadas; `--year=2024` archiva 170.

⚠️ **La rama exige el volumen sintético sembrado antes** (`volume.php` con
`--seed=20240915 --violations=88`), o no hay filas huérfanas y el proceso pasa sin
error. El enunciado del incidente ya trae los dos comandos en ese orden.

**Cómo se revierte:** `git switch -` y `migrate:fresh --seed`.

---

## 4. Los cinco guiones de `sql/`

Todos son idempotentes y todos se aplican igual:

```bash
docker compose exec -T db psql -U postgres certcore < sql/seed-incidente-be-NN.sql
```

Y todos se revierten igual: `docker compose exec api php artisan migrate:fresh --seed`.

### `sql/seed-incidente-be-03.sql` — el orden alterado

```sql
-- be-03: "El listado del panel cambia de orden según el día".
-- No cambia NINGÚN dato visible: sólo fuerza la reescritura física de las filas de
-- ascensores, que es lo que reorganiza el montón y cambia el orden de un SELECT sin
-- ORDER BY (el de /legacy/templates). Con la de calderas no se ve: ya está al final.
UPDATE templates
   SET valid_from = valid_from
 WHERE template_id = 'elevator-annual';

-- Comprobación de la preparación (debe salir boiler-annual primero):
--   SELECT template_id, version FROM templates;
```

> 💡 **La belleza de este guion es que no cambia nada.** `SET valid_from = valid_from`
> escribe la misma fecha, y aun así PostgreSQL reescribe la fila al final del montón.
> Si el estudiante compara los datos antes y después, son **idénticos** — y ése es
> justo el punto del incidente.

### `sql/seed-incidente-be-05.sql` — la secuencia desajustada

```sql
-- be-05: "No puedo crear inspecciones nuevas: dice que el id ya existe".
-- Reproduce el estado en que quedó la base de producción tras un sembrador anterior
-- al de be03, que no reajustaba esta secuencia: filas con id explícito (500…504) y
-- la secuencia apuntando al primero de ellos.
SELECT setval('inspections_id_seq', (SELECT min(id) FROM inspections), false);

-- Comprobación (el siguiente id que dará la secuencia ya existe):
--   SELECT last_value, is_called FROM inspections_id_seq;   -- 500, f
--   SELECT min(id), max(id) FROM inspections;
```

⚠️ **Sólo se desajusta `inspections_id_seq`.** Las de `clients` y `findings` se
dejan bien **a propósito**: es lo que sostiene el *"a mi compañero de otra sucursal
sí le deja"* del ticket, que es la pista que descarta media investigación.

### `sql/seed-incidente-be-06.sql` — el informe mensual

```sql
-- be-06: "El informe falla y no hemos desplegado nada".
-- El guion NO rompe nada: instala el informe tal como estaba y deja el sistema
-- exactamente como el día que funcionaba. Lo que rompe es el .env (§5).
--
-- El informe vive en código (server/app/Reports/ExpiredCertificatesReport.php),
-- así que aquí sólo se siembran los datos que hacen que se ejecute con sentido:
-- certificados vencidos suficientes para que el informe tenga filas.

UPDATE certificates
   SET valid_until = now() - interval '40 days'
 WHERE id IN (SELECT id FROM certificates ORDER BY issued_at LIMIT 3);

-- Comprobación (con la semilla del db.json devuelve 2: sólo hay dos certificados):
--   SELECT count(*) FROM certificates WHERE valid_until < now();
```

> ⚠️ **`ExpiredCertificatesReport.php` tiene que existir en el tag de be04**, con su
> SQL a mano apoyado en `pg_constraint.consrc`. Es parte del código heredado que la
> fase entrega —por eso `SQL-CRUDO.txt` lo lista desde `bea-04`—, pero ninguna lección
> lo escribe entero. Si tu be04 no lo dejó puesto, éstos son los dos archivos, y el
> comando se registra en `$commands` de `server/app/Console/Kernel.php`:

```php
<?php
// server/app/Reports/ExpiredCertificatesReport.php
// Informe mensual de certificados vencidos. Escrito en 2017, con PostgreSQL 9.6 delante,
// y no tocado desde entonces. SQL a mano: es una de las entradas de SQL-CRUDO.txt (bea-04).

namespace App\Reports;

class ExpiredCertificatesReport
{
    public function run()
    {
        // Las reglas de la tabla, para etiquetar en el informe por qué se excluye cada fila.
        // pg_constraint.consrc existe hasta PostgreSQL 11 inclusive (be04 §5.3).
        $rules = app('db')->select("
            SELECT c.conname, c.consrc AS definition
            FROM pg_constraint c
            WHERE c.conrelid = 'certificates'::regclass
        ");

        $expired = app('db')->select('
            SELECT id, inspection_id, valid_until
            FROM certificates
            WHERE valid_until < now()
            ORDER BY valid_until
        ');

        return ['rules' => $rules, 'expired' => $expired];
    }
}
```

```php
<?php
// server/app/Console/Commands/ReportExpiredCertificates.php — `php artisan certcore:report:expired`

namespace App\Console\Commands;

use App\Reports\ExpiredCertificatesReport;
use Illuminate\Console\Command;

class ReportExpiredCertificates extends Command
{
    protected $signature = 'certcore:report:expired';

    protected $description = 'Informe mensual de certificados vencidos';

    public function handle()
    {
        $report = (new ExpiredCertificatesReport())->run();

        $this->info(sprintf('vencidos: %d · reglas: %d', count($report['expired']), count($report['rules'])));
    }
}
```

### `sql/seed-incidente-be-08.sql` — la fecha en el borde

```sql
-- be-08: "El certificado sale vigente y el informe lo cuenta como vencido".
-- La franja peligrosa son las cinco horas en las que un valor sin zona ya pasó si se
-- lee en UTC y todavía no si se lee en Bogotá. El vencimiento se pone dos horas por
-- delante de la hora de Bogotá, escrito sin zona: cae dentro de la franja a cualquier
-- hora del día, porque se mueve el dato en vez de esperar al reloj.
-- La semilla del db.json no trae el CERT-2024-0087 del ticket: se crea (o se ajusta,
-- si ya existe) sobre la inspección 502, que está aprobada.
INSERT INTO certificates (id, inspection_id, issued_at, valid_until, status, revoked_at)
VALUES ('CERT-2024-0087', 502, current_date - interval '1 year',
        (now() AT TIME ZONE 'America/Bogota') + interval '2 hours', 'valid', NULL)
ON CONFLICT (id) DO UPDATE SET valid_until = EXCLUDED.valid_until;

-- Comprobación: la respuesta a "¿está vencido?" tiene que DIFERIR según la zona
-- (UTC: t; Bogotá: f), y el informe de vencidos tiene que contar uno más que sin el guion.
--   SET TimeZone='UTC';             SELECT valid_until < now() FROM certificates WHERE id='CERT-2024-0087';
--   SET TimeZone='America/Bogota';  SELECT valid_until < now() FROM certificates WHERE id='CERT-2024-0087';
```

⚠️ **El incidente vive en una franja de cinco horas, y la receta la persigue.** Con
un valor fijo (`current_date + time '00:30'`, la versión anterior de este guion) sólo se
reproducía de 19:30 a 00:30 de Bogotá: a las tres de la tarde las dos respuestas
coincidían y no se veía nada. Poner el dato relativo a `now()` lo deja dentro de la
franja a cualquier hora. **Requisito:** el informe tiene que correr, así que si el
estudiante no cerró be-06 aplica antes su parche (`pg_get_constraintdef`). Medido el
15/10/2026: con el guion, el informe da `vencidos: 3`; sin él, `vencidos: 2`.

### `sql/seed-incidente-be-09.sql` — la inspección 3117

```sql
-- be-09: "Una inspección de 2023 no se puede reimprimir".
-- El volumen sintético (volume.php --violations=88) ya deja 88 inspecciones
-- huérfanas en un rango de tres semanas de 2023. Este guion sólo FIJA una de
-- ellas con el id que el ticket nombra, para que el enunciado sea reproducible.

UPDATE inspections
   SET id = 3117
 WHERE id = (
   SELECT i.id FROM inspections i
   LEFT JOIN templates t ON t.template_id = i.template_id AND t.version = i.template_version
   WHERE t.template_id IS NULL AND i.status = 'approved'
   ORDER BY i.started_at
   LIMIT 1
 );

-- Comprobación (debe devolver 88, y la 3117 entre ellas):
--   SELECT count(*) FROM inspections i
--   LEFT JOIN templates t ON t.template_id = i.template_id AND t.version = i.template_version
--   WHERE t.template_id IS NULL;
```

⚠️ **Depende del volumen sembrado con la semilla exacta** (`--seed=20240915`). Con
otra semilla el conteo cambia y el enunciado deja de cuadrar con la solución de
referencia, que dice 88.

---

## 5. La línea del `.env`, que es la propia del track

**Sólo el incidente `be-06` la usa, y es su contenido entero.**

```bash
# El estudiante viene de be04 con esto:
POSTGRES_TAG=16.9
```

La preparación **no cambia el `.env`**: lo deja en `16.9`, que es donde ya estaba.
Lo que hace el enunciado es pedir un `down -v && up -d` con siembra limpia, para que
el sistema esté corriendo **PostgreSQL 16** con un informe escrito para
**PostgreSQL 9.6**.

> 🧠 **La preparación de este incidente consiste en no preparar nada, y ése es el
> punto.** No hay diff, no hay rama, no hay dato alterado. El sistema es el que era
> y falla igual, porque lo que cambió está fuera del árbol de fuentes.

Si se quiere reproducir la **transición** —el sistema funcionando y después
fallando, que es más didáctico si hay tiempo—, la receta es:

```bash
# 1. El mundo de antes: el informe funciona.
sed -i '' 's/^POSTGRES_TAG=.*/POSTGRES_TAG=11/' .env
docker compose down -v && docker compose up -d
docker compose exec api php artisan migrate --seed
docker compose exec -T db psql -U postgres certcore < sql/seed-incidente-be-06.sql
docker compose exec api php artisan certcore:report:expired      # ✅ funciona

# 2. La ventana de mantenimiento del proveedor, en una línea.
sed -i '' 's/^POSTGRES_TAG=.*/POSTGRES_TAG=16.9/' .env
docker compose down -v && docker compose up -d
docker compose exec api php artisan migrate --seed
docker compose exec -T db psql -U postgres certcore < sql/seed-incidente-be-06.sql
docker compose exec api php artisan certcore:report:expired      # ❌ y sin un solo commit
```

⚠️ **`pg_constraint.consrc` existe hasta PG 11 inclusive y desaparece en PG 12**, así
que el escalón "de antes" tiene que ser `11` (medido: con `postgres:11` el informe da
`vencidos: 2 · reglas: 2`; con `16.9`, `column c.consrc does not exist`). Con `13` el informe ya falla y la
demostración pierde el contraste.

---

## 6. Las tres que no necesitan preparación

**`be-04`** (el orden que cambió con el reemplazo) y **`be-11`** (el `500` frente al
`422`) **ya están así en el sistema** desde be03: el `ORDER BY` del camino nuevo y los
dos caminos vivos (`/findings` y `/legacy/findings`). No hay nada que sembrar: es el
estado real del backend que el alumno construyó, y eso es precisamente lo que los
hace buenos incidentes.

**`be-12`** (el *assessment* adversarial) trae su artefacto **dentro del enunciado**:
el informe de tres páginas está transcrito en el bloque de preparación del cuaderno.
No hay sistema que romper porque el defecto no está en el sistema.

> 🧭 **Tres de doce sin preparación es un buen número y conviene no bajarlo.** Un
> incidente que no necesita montaje es un incidente que se puede intentar un martes
> cualquiera, y son los que de verdad se hacen.

---

## 7. Verificar que la preparación sirve

Antes de dar por buena cualquier receta de este documento, las tres comprobaciones:

1. **El síntoma aparece**, y aparece **como lo describe el ticket** — no de otra
   forma parecida. Si el ticket dice "sale la pantalla sin ítems" y lo que sale es
   un error 500, la preparación está mal.
2. **El sistema sigue arrancando** y el resto de pantallas funcionan. Un incidente
   que rompe medio sistema no entrena el diagnóstico: lo hace trivial.
3. **`BASE_URL=http://localhost:3000 ./smoke.sh` sigue dando lo que tenía que dar.**
   La mayoría de estas preparaciones **no** deben mover el contador — y las que sí,
   están anotadas. Si el juez del contrato se pone rojo sin que estuviera previsto,
   la preparación rompió algo de más.

Y una comprobación específica de este track, que sale del ejercicio de
[`bea-11`](../bea-11-datos-de-prueba-y-volumen.md): **ninguna preparación mete datos
generados en una colección que el `smoke.sh` audite.** El volumen sintético de
`be-09` y `be-10` sólo añade `inspections` y `findings`, y las comprobaciones del
contrato que las tocan se escribieron contando con eso.

---

## ⚠️ Advertencias

**Las preparaciones envejecen con las fases.** Si al editar una fase cambia el
nombre de un archivo, de una columna o de un endpoint, hay que revisar aquí. La
comprobación barata es correr las tres verificaciones de §7 sobre las doce recetas
antes de dar el track por cerrado.

**`be-08` depende de `now()`** y es la única. La versión anterior de su receta fijaba
la hora y sólo reproducía el incidente cinco horas al día; la actual pone el dato
relativo al reloj, que reproduce el mismo bug (un dato dentro de la franja) a cualquier
hora. Lo que sí sigue siendo sensible: la receta necesita el informe de be-06 ya
parcheado.

**`be-09` y `be-10` dependen de la semilla exacta** `--seed=20240915` con
`--violations=88`. El número 88 aparece literalmente en las soluciones de referencia
de las dos y en `be05`. Si alguna vez se cambia el generador, hay que cambiar los
tres sitios — o mejor: no cambiarlo.

**Y la que vale para todo el documento:** una preparación escrita en el estilo
equivocado es una pista falsa. Si el incidente vive en la parcela `laravel`, el
código roto se escribe con helpers y sin `declare(strict_types=1)`; si vive en la
`symfony`, al revés. El estudiante va a usar `ESTRATOS.md` para clasificar el
archivo antes de tocarlo, y **tiene que llegar a la conclusión correcta**.
