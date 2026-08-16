# 🗄️ Fase be03 — El reemplazo: de `db.json` a Postgres 16

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Fase be03 de be07 · **10 horas**
> Depende de: **be02 cerrada** (`ESTRATOS.md` completo) · Habilita: be04
> Apéndices de apoyo: [`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md) · Incidentes asociados: **be-04**, **be-05**
> Estilo de esta fase: **el contrato manda sobre la elegancia.** Se reimplementa un dialecto ajeno, con sus rarezas, sin corregir ninguna

> 🔥 **Esta fase pertenece al track opcional de backend.** El track base se completa sin abrirla.

---

## 🎯 1. Propósito

Apagar el mock y que la aplicación no se entere.

Es la bisagra del track: hasta aquí el backend nuevo era un laboratorio con datos fijos; a partir de aquí **es el sistema**. Y la vara de medir no es que el código quede bonito — es una frase que se verifica:

> 🧭 **La señal de éxito, y se comprueba:** *"apagué `npm run mock`, levanté el contenedor en el mismo puerto 3000, y la única forma de notar el cambio fue que la lista de inspecciones tardó 40 ms más."*

---

## ✅ 2. Qué queda listo al terminar

- [ ] `BASE_URL=http://localhost:3000 ./smoke.sh` da **`OK: 24/24`** contra el backend en PHP, **sin haber tocado una línea del `smoke.sh`**.
- [ ] `npm run mock` está **apagado**. La aplicación Angular funciona entera contra el contenedor: entrar, clientes, activos, plantillas, la inspección 501, hallazgos, certificados.
- [ ] `git diff fase-10-certificados-vigencia..HEAD -- src/` sigue devolviendo **vacío**.
- [ ] Las **siete tablas** existen con sus migraciones versionadas, y `docker compose exec db psql -U postgres certcore -c '\dt'` las lista.
- [ ] La base está sembrada **desde tu propio `mock/db.json`**, no desde un volcado ajeno: la inspección 501 con su `templateVersion: 1`, la 503 rechazada con su hallazgo crítico, y los mismos identificadores que llevas viendo desde la Fase 3.
- [ ] La **paginación de servidor** funciona en el dialecto del mock (`_page`, `_limit`, cabecera `X-Total-Count`) **y un cliente que no la pide sigue recibiendo todo**. Lo comprobaste con el frontend, que no la pide.
- [ ] El **login está absorbido**: `POST /auth/login` lo firma PHP, con los mismos cinco claims, y el interceptor de la Fase 2 no se entera.
- [ ] Sabes decir **cuántas filas de `certificates` mienten hoy** en su columna `status`, con la consulta que lo cuenta escrita en `HALLAZGOS.md`.

---

## 🚫 3. Qué NO entra todavía

- **La subida de versión de PostgreSQL** → be04. Aquí la base es `16.9` desde el primer minuto y no nos preguntamos por qué.
- **La invariante de plantillas versionadas** → be05. Aquí se ve el agujero y **se anota**; taparlo es la fase insignia y no se adelanta.
- **Corregir `certificates.status`** → be05. Aquí se cuenta cuántas filas mienten y se deja la columna tal cual.
- **Las pruebas** → be06.
- **Mejorar el contrato.** Ni sobres, ni `camelCase` "más limpio", ni códigos de estado más correctos. El contrato se reimplementa, no se opina.

---

## 🧠 4. Concepto mínimo

### Reimplementar un dialecto es aburrido, y ése es el trabajo

json-server tiene un dialecto, el frontend lo consume tal cual, y en be00 lo mediste: cuatro formas de consulta, una ruta anidada que nadie diseñó, un `404` con cuerpo vacío, arrays desnudos sin sobre. Reimplementar eso en Lumen no tiene ni una decisión interesante, y ahí está la lección:

> 🧭 **El contrato manda sobre la elegancia.** Cada vez que te descubras pensando *"esto quedaría mejor así"*, estás a punto de romper una pantalla que funciona. La forma correcta no es la que te gusta: es la que ya consume alguien.

🩻 **Esto sí funciona igual.** Todo tu instinto de modelado relacional sirve aquí, entero. Claves primarias, foráneas, índices, `NOT NULL`, transacciones: nada de eso cambia por estar en PHP. Lo único que cambia es **quién decide la forma de la salida**, y en este track no eres tú.

### La traducción del `db.json`: dónde hay decisión y dónde no

📖 **Diccionario de traducción: del documento a la tabla**

| En `db.json` | En PostgreSQL | ¿Hay decisión? |
|---|---|---|
| `clients[].id: number` | `clients.id serial` | No |
| `assets[].id: "ASC-CENTRAL-03"` | `assets.id text` | No: es un identificador operativo, el que está pintado en el equipo |
| `templates[].id: "elevator-annual-v2"` | **derivado**, no almacenado | **Sí, y es la decisión de la fase** |
| `templates[].templateId` + `version` | **clave primaria compuesta** | **Sí** |
| `templates[].items[]` | `templates.items jsonb` | **Sí** |
| `inspections[].templateId` + `templateVersion` | dos columnas sueltas, **sin clave foránea** | **Sí, y es la de be05** |
| `inspections[].answers[]` | `inspections.answers jsonb` | Sí, la misma que `items` |
| `certificates[].status` | `certificates.status text` | **No hay decisión: así está el dato** 💸 |
| Fechas con offset `-05:00` | `timestamp` **sin zona** | **No hay decisión: así lo escribió 2016** 💸 |

Tres de esas filas merecen párrafo.

**El `id` compuesto de las plantillas.** El `db.json` guarda `"elevator-annual-v2"` como identificador de fila, y `templateId` + `version` aparte. Es redundante y es contrato: el frontend pinta ese `id`. En la base lo correcto es al revés — la clave es `(template_id, version)` y el `id` se **deriva** al serializar. Así la base sostiene la unicidad de verdad, y la respuesta sigue siendo idéntica byte a byte.

> 🧠 **Un identificador compuesto aplastado en una cadena es una clave primaria que alguien no se atrevió a declarar.** La convención de "toda tabla lleva un `id`" —la huella de CakePHP que encontraste en be02, ejercicio 23— es exactamente lo que impidió declararla en 2016. Y sin esa clave declarada, **la clave foránea compuesta que be05 necesita no se podía ni escribir.**

**`items` y `answers` como `jsonb`.** La alternativa —tablas hijas— es más ortodoxa y aquí se descarta a propósito: el contrato entrega los ítems anidados dentro de la plantilla, siempre, sin excepción y sin endpoint propio; y ninguna consulta del frontend filtra por ítem. Modelarlos aparte significa reconstruir el anidamiento en cada respuesta a cambio de una integridad que nadie consulta. Con `jsonb` la traducción es directa y `9.6` ya lo soportaba.

Y el precio, que hay que escribir porque es la mitad de be05: **dentro de un `jsonb` no hay restricciones.** Un `itemId` de una respuesta que no existe en la plantilla no lo impide nadie. Lo mismo que pasa entre `inspections` y `templates`, un nivel más abajo.

**Las fechas `timestamp` sin zona.** No es una decisión de esta fase: es fidelidad. El `db.json` guarda todo con offset `-05:00`, y el sistema de 2016 lo escribió en columnas sin zona. La cicatriz de la Fase 10 —*"venció ayer para el servidor y vence hoy para el navegador"*— nace exactamente ahí, y en be04 se mira de frente con [`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md) en la mano.

🪞 **Tu instinto de modelador dice… y esta vez se equivoca.** Tu instinto dice: pon `TIMESTAMPTZ`, declara la foránea compuesta, normaliza los ítems, haz `status` una columna generada. Las cuatro son correctas y las cuatro están **prohibidas en esta fase**. No por pedagogía: porque el trabajo de hoy es *reemplazar sin que nadie se entere*, y cada mejora que metas aquí es una variable más cuando el `smoke.sh` se ponga rojo. **Primero se reemplaza, después se arregla, y las dos cosas no se hacen el mismo día.**

---

## 💻 5. Código mínimo con comentarios

### 5.1 El esquema, entero

Siete tablas. Éste es el documento del que dependen be04 y be05, así que se lee completo antes de escribir nada.

```php
<?php
// server/database/migrations/2016_09_20_000100_create_core_tables.php
//
// La fecha del nombre es de 2016 a propósito: estas migraciones reconstruyen el
// esquema tal como quedó entonces, no como lo haríamos hoy. Lo que hoy haríamos
// distinto va marcado 💸 y tiene fase de cobro.

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCoreTables extends Migration
{
    public function up(): void
    {
        // ── clients ────────────────────────────────────────────────────────
        Schema::create('clients', function (Blueprint $table) {
            $table->increments('id');
            $table->string('legal_name');
            // El NIT es la clave del negocio: siempre presente y único.
            $table->string('tax_id')->unique();
        });

        // ── assets ─────────────────────────────────────────────────────────
        Schema::create('assets', function (Blueprint $table) {
            // Clave de texto, no serial: "ASC-CENTRAL-03" es el identificador
            // que está pintado en el equipo. Inventar un id numérico al lado
            // habría sido la decisión de CakePHP, y aquí no se tomó.
            $table->string('id')->primary();
            $table->unsignedInteger('client_id');
            $table->string('type');   // elevator | boiler | tank | fire_system
            $table->string('description');
            // Día de calendario, no instante: una fecha de instalación no tiene hora.
            $table->date('installed_at');

            $table->foreign('client_id')->references('id')->on('clients');
        });

        // ── templates ──────────────────────────────────────────────────────
        Schema::create('templates', function (Blueprint $table) {
            $table->string('template_id');
            $table->unsignedInteger('version');
            $table->date('valid_from');
            // null = vigente indefinidamente. NO es "sin datos", y de esa
            // lectura depende resolveTemplateVersion en el frontend.
            $table->date('valid_until')->nullable();
            // Los ítems del checklist, anidados. El contrato los entrega
            // siempre dentro de la plantilla y nadie filtra por ítem.
            $table->jsonb('items');

            // LA clave primaria compuesta. El "id" de texto que ve el
            // frontend ("elevator-annual-v2") se DERIVA de estas dos columnas
            // al serializar: ver el modelo en §5.2.
            $table->primary(['template_id', 'version']);
        });

        // ── inspections ────────────────────────────────────────────────────
        Schema::create('inspections', function (Blueprint $table) {
            $table->increments('id');
            $table->string('asset_id');
            $table->string('inspector_id');

            // Las dos columnas que este track existe para mirar.
            $table->string('template_id');
            $table->unsignedInteger('template_version');

            $table->string('status');
            // 💸 sin zona: ver el bloque de deuda de abajo.
            $table->timestamp('started_at');
            $table->timestamp('completed_at')->nullable();
            $table->jsonb('answers');

            $table->foreign('asset_id')->references('id')->on('assets');

            // ⚠️ Y AQUÍ NO HAY NADA MÁS. No hay foreign compuesta contra
            // templates. No es un olvido de esta migración: es el estado real
            // del sistema desde 2016, y es el tema entero de be05.
        });

        // ── findings ───────────────────────────────────────────────────────
        Schema::create('findings', function (Blueprint $table) {
            $table->increments('id');
            $table->unsignedInteger('inspection_id');
            $table->string('item_id');
            $table->string('severity');   // critical | major | minor
            $table->string('description');
            // null = sin resolver. Un critical sin resolver bloquea el certificado.
            $table->timestamp('resolved_at')->nullable();

            $table->foreign('inspection_id')->references('id')->on('inspections');
            // Índice explícito: la ruta anidada /inspections/:id/findings es el
            // acceso más frecuente de todo el sistema.
            $table->index('inspection_id');
        });

        // ── certificates ───────────────────────────────────────────────────
        Schema::create('certificates', function (Blueprint $table) {
            $table->string('id')->primary();   // "CERT-2024-0087"
            $table->unsignedInteger('inspection_id');
            $table->timestamp('issued_at');
            $table->timestamp('valid_until');
            // 💸 status ALMACENADO. Ver el bloque de deuda: esta columna es la
            // protagonista del hallazgo incómodo de §5.6.
            $table->string('status');
            $table->timestamp('revoked_at')->nullable();

            $table->foreign('inspection_id')->references('id')->on('inspections');
        });

        // ── users ──────────────────────────────────────────────────────────
        Schema::create('users', function (Blueprint $table) {
            // "INS-15", "SUP-02": los mismos sub del token del mock.
            $table->string('id')->primary();
            $table->string('email')->unique();
            $table->string('password_hash');
            $table->string('name');
            $table->string('role');   // inspector | supervisor
        });
    }

    public function down(): void
    {
        // Orden inverso al de creación: las foráneas mandan.
        Schema::dropIfExists('users');
        Schema::dropIfExists('certificates');
        Schema::dropIfExists('findings');
        Schema::dropIfExists('inspections');
        Schema::dropIfExists('templates');
        Schema::dropIfExists('assets');
        Schema::dropIfExists('clients');
    }
}
```

```
💸 DEUDA TÉCNICA INTENCIONAL — tres, y las tres están en este esquema

1. certificates.status es una COLUMNA, no un derivado. Lo correcto sería una
   columna generada o una vista: el estado de un certificado es una función de
   valid_until, revoked_at y el reloj. Tal como está, empieza a mentir al día
   siguiente de cada emisión.
   SE PAGA EN be05, y aquí se MIDE (§5.6).

2. Fechas en `timestamp` SIN zona, con datos que traen offset -05:00. Lo
   correcto es TIMESTAMPTZ. Es de donde sale la cicatriz de la Fase 10 del
   track base.
   SE PAGA EN be04, con bea-07 al lado.

3. inspections apunta a (template_id, template_version) SIN clave foránea
   compuesta. Ninguna restricción sostiene la invariante central del sistema.
   SE PAGA EN be05 ⭐ — es la fase insignia del track.

Y una que NO se paga nunca, declarada aquí: assets.type, inspections.status,
findings.severity y certificates.status son `string` libres, sin CHECK ni
enum. Lo correcto sería restringir el dominio. No se toca porque el frontend
ya valida esos valores y porque añadir un CHECK sobre ocho años de datos es
exactamente el problema de be05 — resolverlo en cuatro columnas a la vez sería
diluir la lección. Queda en `bea-10` como deuda aceptada.
```

**Detalles con intención**

- **`assets.id` es texto y `clients.id` es serial.** No es incoherencia: son dos clases de identificador distintas. El del activo existe fuera del sistema —está pintado en el ascensor—; el del cliente lo inventó la base. Cuando un identificador existe en el mundo real, usarlo es lo correcto.
- **El índice de `findings.inspection_id` es el único explícito del esquema.** PostgreSQL crea índice para claves primarias y únicas, **no para foráneas**. Es el olvido más común del oficio, y aquí está puesto porque `/inspections/:id/findings` se llama en cada apertura de inspección.
- **La ausencia de la foránea compuesta está comentada en el código.** Un agujero sin comentario parece un descuido; con comentario es una deuda localizable. Ese comentario es el que be05 va a borrar.

### 5.2 Los modelos, y el `id` que se deriva

```php
<?php
// server/app/Models/Template.php

declare(strict_types=1);

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Template extends Model
{
    protected $table = 'templates';

    // Clave compuesta. Eloquent NO la soporta de fábrica: da por hecho una
    // columna `id` incremental. Se desactiva el incremental y se le dice que
    // no hay clave simple; todo lo que necesite buscar por clave va explícito
    // con where(). Es una limitación real del ORM y bea-04 la desarrolla.
    public $incrementing = false;
    protected $primaryKey = null;

    // Las columnas de la parcela CakePHP se llaman `created`/`modified`, y
    // estas tablas ni siquiera las tienen. Sin esta línea, Eloquent añade
    // created_at/updated_at a cada INSERT y revienta.
    public $timestamps = false;

    protected $casts = [
        'version' => 'integer',
        'items' => 'array',
    ];

    /**
     * El id compuesto que ve el frontend: "elevator-annual-v2".
     * Se DERIVA, no se guarda. La base sostiene la unicidad con la clave
     * primaria compuesta; el contrato recibe la cadena que siempre recibió.
     */
    public function getIdAttribute(): string
    {
        return sprintf('%s-v%d', $this->template_id, $this->version);
    }

    /** Scope heredado. Se invoca como Template::active() — ver bea-03. */
    public function scopeActive($query)
    {
        return $query->whereNull('valid_until');
    }
}
```

Y el serializador, que es donde el contrato se cumple o se rompe:

```php
<?php
// server/app/Http/Serializers/TemplateSerializer.php

declare(strict_types=1);

namespace App\Http\Serializers;

use App\Models\Template;

class TemplateSerializer
{
    /**
     * La forma EXACTA de CONTRACT.md. Cada línea de este método es una ficha
     * de aquel documento, y el orden de las claves también: json-server las
     * emitía así y hay pantallas que iteran sobre Object.keys().
     *
     * @return array<string, mixed>
     */
    public static function toArray(Template $template): array
    {
        return [
            'id' => $template->id,                       // derivado
            'templateId' => $template->template_id,      // snake → camel, aquí
            // (int) explícito: sin él, el driver de PostgreSQL devuelve los
            // enteros como CADENA, y el frontend recibe "2" en vez de 2. Es
            // literalmente la pieza forense de esta fase (§6).
            'version' => (int) $template->version,
            'validFrom' => $template->valid_from,
            'validUntil' => $template->valid_until,      // null se emite como null
            'items' => $template->items,
        ];
    }
}
```

> 🧭 **La frontera `snake_case` / `camelCase` vive en el serializador y en ningún otro sitio.** La base habla en `snake_case` porque es su convención; el contrato habla en `camelCase` porque así nació. Un proyecto que traduce en diez sitios acaba con ocho de ellos mal.

### 5.3 El dialecto de json-server, reimplementado

La tabla de be00 §5.3 decía exactamente qué hay que reimplementar. Ni más, ni menos:

```php
<?php
// server/app/Http/Controllers/TemplateController.php (fragmento)

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\Template;
use App\Http\Serializers\TemplateSerializer;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

class TemplateController extends BaseController
{
    public function index(Request $request)
    {
        $query = Template::query();

        // Filtros de igualdad exacta, combinados con AND. Son los cuatro
        // parámetros que el frontend usa de verdad; todo lo demás del
        // dialecto de json-server NO se implementa (be00 §5.3).
        foreach (['templateId' => 'template_id', 'version' => 'version'] as $param => $column) {
            if ($request->has($param)) {
                $query->where($column, $request->query($param));
            }
        }

        // El orden. json-server devolvía el de inserción del db.json y el
        // frontend no ordena; un SELECT sin ORDER BY no garantiza NADA, y
        // PostgreSQL lo demuestra en cuanto la tabla recibe UPDATEs. La
        // trampa estaba anotada en CONTRACT.md y aquí se paga con una línea.
        $query->orderBy('template_id')->orderBy('version');

        return $this->paginated($request, $query, function (Template $row) {
            return TemplateSerializer::toArray($row);
        });
    }
}
```

Y la paginación, que es la 💸 1 del track base y se paga **sin que el frontend cambie**:

```php
<?php
// server/app/Http/Controllers/Concerns/PaginatesLikeJsonServer.php

declare(strict_types=1);

namespace App\Http\Controllers\Concerns;

use Illuminate\Http\Request;

trait PaginatesLikeJsonServer
{
    /**
     * Paginación en el dialecto de json-server 0.17.4:
     *   - _page y _limit como parámetros de consulta
     *   - cabecera X-Total-Count con el total
     *   - array DESNUDO en el cuerpo, nunca un sobre
     *
     * Y la regla que la hace compatible hacia atrás, que es la parte que
     * importa: un cliente que NO manda _page recibe todo, como siempre.
     * El frontend de CertCore no la manda. No tiene que enterarse de nada.
     */
    protected function paginated(Request $request, $query, callable $serialize)
    {
        $total = (clone $query)->count();

        if ($request->has('_page')) {
            $limit = (int) $request->query('_limit', '10');
            $page = max(1, (int) $request->query('_page', '1'));

            $query->limit($limit)->offset(($page - 1) * $limit);
        }

        $rows = array_map($serialize, $query->get()->all());

        // array_values porque array_map sobre una colección puede dejar claves
        // no consecutivas, y entonces json_encode emite un OBJETO en vez de un
        // array. Es el bug de bea-01, y aquí costaría la pantalla entera.
        return response()->json(array_values($rows))
            ->header('X-Total-Count', (string) $total);
    }
}
```

**Detalles con intención**

- **`X-Total-Count` se manda siempre**, se pida o no la paginación. Es lo que hacía json-server, es gratis, y el día que alguien quiera paginar tiene el total sin cambiar el servidor.
- **El límite por defecto es 10, y sólo aplica si hay `_page`.** Si lo aplicaras siempre, "compatible hacia atrás" duraría hasta la primera pantalla con once filas.
- **`clone $query` antes del `count()`.** Sin el clon, el `count()` consume el constructor y el `get()` posterior devuelve otra cosa. Es un clásico y cuesta media hora.

### 5.4 La siembra, desde tu propio `db.json`

Esto no es cosmético. Que los datos sean **los mismos que llevas viendo desde la Fase 3** —la inspección 501 con su v1, la 503 rechazada con su hallazgo crítico— es la mitad del efecto de la fase: cuando el `smoke.sh` se ponga rojo, vas a reconocer el dato que falla.

```php
<?php
// server/database/seeds/DbJsonSeeder.php

declare(strict_types=1);

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DbJsonSeeder extends Seeder
{
    public function run(): void
    {
        // El db.json del PROPIO alumno, montado en el contenedor. No un
        // volcado que venga con el curso: el tuyo, con lo que hayas hecho.
        $raw = file_get_contents('/app/mock/db.json');
        $db = json_decode($raw, true, 512, JSON_THROW_ON_ERROR);

        DB::transaction(function () use ($db) {
            foreach ($db['clients'] as $client) {
                DB::table('clients')->insert([
                    'id' => $client['id'],
                    'legal_name' => $client['legalName'],
                    'tax_id' => $client['taxId'],
                ]);
            }

            foreach ($db['templates'] as $template) {
                DB::table('templates')->insert([
                    // El id compuesto del JSON NO se guarda: se descompone.
                    // Si alguna vez no cuadra con templateId + version, tienes
                    // un dato corrupto y quieres enterarte ahora, no en be05.
                    'template_id' => $template['templateId'],
                    'version' => $template['version'],
                    'valid_from' => $template['validFrom'],
                    'valid_until' => $template['validUntil'],
                    'items' => json_encode($template['items']),
                ]);
            }

            foreach ($db['inspections'] as $inspection) {
                DB::table('inspections')->insert([
                    'id' => $inspection['id'],
                    'asset_id' => $inspection['assetId'],
                    'inspector_id' => $inspection['inspectorId'],
                    'template_id' => $inspection['templateId'],
                    'template_version' => $inspection['templateVersion'],
                    'status' => $inspection['status'],
                    // La cadena entra con su offset -05:00 y la columna es
                    // `timestamp` SIN zona: PostgreSQL se queda con la hora
                    // local y TIRA EL OFFSET, en silencio. Ahí nace la deuda
                    // 💸 4, y en be04 se cobra.
                    'started_at' => $inspection['startedAt'],
                    'completed_at' => $inspection['completedAt'],
                    'answers' => json_encode($inspection['answers']),
                ]);
            }

            // …y lo mismo para assets, findings y certificates.

            // Las secuencias de las tablas con `serial` hay que reajustarlas a
            // mano después de insertar ids explícitos, o el primer INSERT
            // nuevo choca con la 500. Es el error que sale SIEMPRE al sembrar.
            DB::statement("SELECT setval('inspections_id_seq', (SELECT MAX(id) FROM inspections))");
            DB::statement("SELECT setval('clients_id_seq', (SELECT MAX(id) FROM clients))");
            DB::statement("SELECT setval('findings_id_seq', (SELECT MAX(id) FROM findings))");
        });
    }
}
```

**Prueba de fuego**

```bash
docker compose exec api php artisan migrate --seed
docker compose exec db psql -U postgres certcore -c \
  "SELECT id, template_id, template_version, status FROM inspections ORDER BY id;"
```

Tienen que salir tus inspecciones, con los mismos identificadores y los mismos estados que ves en la aplicación. Si la 501 sale con `template_version = 2`, **para**: no es un error de esta fase, es que tu `db.json` ya tenía el problema de la Fase 7 y acabas de encontrarlo desde el otro lado del cable.

### 5.5 El login absorbido

`mock/auth.js` deja de existir. El contrato del token no cambia ni una coma: el interceptor de la Fase 2 no puede enterarse.

```php
<?php
// server/app/Http/Controllers/AuthController.php

declare(strict_types=1);

namespace App\Http\Controllers;

use Firebase\JWT\JWT;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

class AuthController extends BaseController
{
    // El mismo secreto de juguete que el mock, y por el mismo motivo: esto es
    // un laboratorio. Un secreto de verdad no vive en el repositorio — y esa
    // conversación, en serio, es de bea-08.
    private const SECRET = 'certcore-dev-secret';
    private const TTL_SECONDS = 3600;

    public function login(Request $request)
    {
        $user = \App\Models\User::where('email', $request->input('email'))->first();

        // password_verify contra el hash sembrado. El mock comparaba cadenas
        // en claro; ésta es la única mejora que esta fase se permite, y se
        // permite porque NO ES VISIBLE EN EL CONTRATO.
        if ($user === null || ! password_verify((string) $request->input('password'), $user->password_hash)) {
            // 401 CON cuerpo y con el mensaje en español, literal: la pantalla
            // de login lo muestra tal cual.
            return response()->json(['message' => 'Credenciales inválidas'], 401);
        }

        // El TTL negativo es el modo `expired` del inyector de caos: firma un
        // token que ya nació vencido. Vive aquí y no en el middleware, igual
        // que en el mock.
        $ttl = in_array('expired', config('chaos.faults'), true) ? -60 : self::TTL_SECONDS;

        $issuedAt = time();
        $payload = [
            'sub' => $user->id,
            'name' => $user->name,
            'role' => $user->role,
            'iat' => $issuedAt,
            'exp' => $issuedAt + $ttl,
        ];

        return response()->json([
            'accessToken' => JWT::encode($payload, self::SECRET, 'HS256'),
            // Redundante con el `exp` del token, y se manda igual porque el
            // mock lo mandaba y el cliente lo lee.
            'expiresIn' => $ttl,
        ]);
    }
}
```

**El patrón a memorizar**

> Cuando reemplaces un servicio, la lista de lo que **no** puedes mejorar es más importante que la de lo que vas a construir. Aquí sólo había una mejora invisible desde fuera —guardar contraseñas con hash— y por eso entró. Todo lo demás espera.

### 5.6 El hallazgo incómodo: cuántas filas mienten hoy

`certificates.status` es una columna. El track base ya lo señaló como error de diseño puesto a propósito (Fase 10, ejercicio 21). Ahora la ves, y puedes **contarla**:

```sql
-- ¿Cuántos certificados dicen una cosa y los datos dicen otra?
SELECT
  status AS estado_guardado,
  CASE
    WHEN revoked_at IS NOT NULL          THEN 'revoked'
    WHEN valid_until < now()             THEN 'expired'
    WHEN valid_until < now() + interval '30 days' THEN 'expiring'
    ELSE 'valid'
  END AS estado_real,
  count(*)
FROM certificates
GROUP BY 1, 2
ORDER BY 3 DESC;
```

Las filas donde las dos primeras columnas **no coinciden** son certificados que el sistema está mostrando mal ahora mismo. Anota el número en `HALLAZGOS.md`, con la fecha y la hora.

> 🧠 **Un estado guardado no está mal el día que se escribe: está mal al día siguiente.** Por eso es tan difícil de detectar y por eso nadie lo reporta como bug — el usuario ve un dato coherente con lo que vio ayer.

Y aquí **no se arregla**. Se cuenta, se anota, y se difiere a be05, donde se convierte en derivado con una columna generada. Si lo arreglas hoy, el `smoke.sh` va a cambiar de resultado por un motivo que no es el reemplazo, y vas a perder la única medición limpia que esta fase produce.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Dejar que PostgreSQL devuelva los enteros como cadena.**
*Síntoma:* `version` llega al frontend como `"2"`, y `resolveTemplateVersion` no encuentra nada. En Network todo verde.
*Causa:* el driver devuelve casi todo como texto y PHP no convierte solo. En el mock, `version` era un número de JavaScript desde el `db.json`.
*Fix mínimo:* casts explícitos en el modelo (`protected $casts`) **y** en el serializador. Los dos: el `$casts` te protege en el código, el `(int)` del serializador protege el contrato.

**Olvidar reajustar las secuencias tras sembrar.**
*Síntoma:* todo funciona hasta que alguien crea una inspección, y entonces `duplicate key value violates unique constraint`.
*Causa:* insertaste ids explícitos y la secuencia sigue en 1.
*Fix mínimo:* los `setval` del final del sembrador. Y cuando lo veas en un sistema ajeno, ya sabes que alguien sembró a mano.

**Mejorar el contrato "un poquito".**
*Síntoma:* devuelves `{"data": [...]}` porque es más profesional, o `204` en vez de `200` con cuerpo vacío.
*Causa:* buen gusto, mal momento.
*Fix mínimo:* revierte y corre el `smoke.sh`. Y si el `smoke.sh` **no** lo detecta, tienes dos problemas: el cambio y una comprobación que falta.

**Confiar en el orden de las filas.**
*Síntoma:* la lista de plantillas sale en otro orden que antes y nadie tocó la pantalla.
*Causa:* `SELECT` sin `ORDER BY`. json-server devolvía el orden de inserción; PostgreSQL no garantiza nada, y menos tras un `UPDATE`.
*Fix mínimo:* `ORDER BY` explícito en toda consulta de colección. Estaba anotado como trampa en `CONTRACT.md` desde be00: ésta es la fase donde esa nota se cobra sola.

### Pieza forense de esta fase

**El primer `smoke.sh` en rojo.**

```
  ❌ GET /templates · el id de la primera plantilla es compuesto
     esperado: "elevator-annual-v1"
     recibido: 7
  ❌ GET /templates · version es un número
     esperado: number
     recibido: string
  OK: 22/24
```

Y en la aplicación, la pantalla de plantillas **en blanco**. Dos síntomas, una causa, y la ruta es corta:

1. **El juez ya te dijo dónde.** No abras el navegador: el `smoke.sh` nombra el campo y el valor. `7` es un `id` de fila que nadie pidió; `"2"` es un entero que se convirtió en cadena. Los dos son de serialización, no de datos.
2. **Confirma en la base, no en el código.** `SELECT template_id, version FROM templates LIMIT 1;` → los datos están bien. Con eso acabas de descartar el sembrador y la migración: el problema está entre la fila y el JSON.
3. **Mira el JSON crudo, no el `jq`.** `curl -s localhost:3000/templates | head -c 200`. Ahí está: `"id":7,"version":"2"`. El `id` salió del atributo real del modelo en vez del derivado, porque alguien dejó la clave incremental puesta; y el `version` salió como texto porque falta el cast.
4. **El fix son dos líneas** —`$casts` y el accesor `getIdAttribute()`—, y no es el aprendizaje. El aprendizaje es el orden: **el juez del contrato te llevó al campo exacto sin abrir el navegador ni leer un archivo.**

> 🧠 **Un contrato ejecutable convierte "la pantalla está en blanco" en "el campo `version` viaja como cadena".** Es la misma traducción que el track base hace con DevTools, y aquí la hace un guion de bash de cien líneas.

> 🧨 **Rompe a propósito y observa.** Cambia una sola cosa en el serializador de certificados: emite `validUntil` sin el offset (`2024-06-30 12:00:00` en vez de `2024-06-30T12:00:00-05:00`). Corre el `smoke.sh` —probablemente **pase**— y después abre la pantalla de certificados y mira las fechas de vencimiento. Anota: cuántas comprobaciones cayeron, qué ve el usuario, y **qué tendría que comprobar el `smoke.sh` para que esto no se le escape**. Esa comprobación que falta es exactamente el agujero que be04 va a hacer sangrar.

---

## 🧪 7. Ejercicios (31)

**🟢 Fácil (1–8)**

1. Corre las migraciones y lista las tablas con `\dt`. Después `\d templates` y comprueba que la clave primaria es compuesta.
2. Siembra desde tu `db.json` y verifica con tres `SELECT` que los datos son los que ves en la aplicación: la inspección 501, la 503 y sus hallazgos.
3. **Diagnóstico.** Corre el `smoke.sh` a mitad de la fase y anota cuántas pasan. Repítelo al final. La diferencia entre los dos números es el trabajo de hoy.
4. Pide `GET /templates` con `curl` y compara la salida, byte a byte, con la del mock guardada en `CONTRACT.md`. Usa `diff`.
5. Comprueba que `X-Total-Count` sale en todas las colecciones con `curl -sD - -o /dev/null`.
6. **Diagnóstico.** Pide `GET /inspections?_page=1&_limit=2` y después `GET /inspections` a secas. Explica por qué la segunda tiene que devolver todo.
7. Entra a la aplicación con el mock apagado y recorre las seis pantallas. Anota cualquier diferencia visible, por pequeña que sea.
8. Mide con `curl -w '%{time_total}'` cuánto tarda `GET /inspections` contra el mock y contra PHP. Anota la diferencia en milisegundos: es la frase de §1.

**🟡 Intermedio (9–20)**

9. **Diagnóstico.** Quita el `$casts` del modelo `Template` y observa qué se rompe, en este orden: la salida de `curl`, el `smoke.sh`, la pantalla. ¿Cuál de los tres avisa antes?
10. Implementa el filtro combinado `?templateId=…&version=…` y comprueba con el `smoke.sh` que el AND funciona. Después prueba con los parámetros en orden inverso (la pieza forense de be00).
11. **Diagnóstico.** Borra el `ORDER BY` de una colección, haz un `UPDATE` sobre una fila cualquiera, y vuelve a pedirla. ¿Cambió el orden? Explica por qué un `UPDATE` puede mover una fila.
12. Implementa la ruta anidada `GET /inspections/:id/findings` y comprueba que devuelve lo mismo que json-server, incluido el caso de una inspección sin hallazgos.
13. **Diagnóstico.** Pide `GET /inspections/9999` (no existe). ¿Devuelve `404` con cuerpo vacío, como el contrato? Si devuelve una página de error de Lumen, arréglalo — y explica dónde vive esa decisión.
14. Absorbe el login y comprueba que el interceptor de la Fase 2 sigue funcionando sin cambios. Decodifica el token y verifica los cinco claims.
15. **Diagnóstico.** Con `CHAOS=expired`, entra a la aplicación y comprueba que el comportamiento es idéntico al del mock: ¿quién detecta primero el token vencido, el cliente o el servidor?
16. Escribe la consulta de §5.6 y anota cuántos certificados mienten. Después cambia el reloj del contenedor (o una fecha de la tabla) y vuelve a contar.
17. **Diagnóstico.** Siembra dos veces sin limpiar y describe qué pasa. Después arregla el sembrador para que sea idempotente, y decide si eso debería serlo o no.
18. Compara el SQL que genera Eloquent para `GET /templates` con el que escribirías a mano. Sácalo del log, no lo supongas ([`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md) explica cómo).
19. **Diagnóstico.** Mide `GET /inspections` con `EXPLAIN ANALYZE`. Con cinco filas no dice nada interesante: anota el plan igualmente. En be05, con cuatro mil, vas a comparar.
20. Implementa `PATCH /inspections/:id` respetando el contrato: qué devuelve, con qué código, y qué pasa con un campo que no existe (be00, ejercicio 13).

**🟠 Difícil (21–27)**

21. **Diagnóstico.** Provoca la pieza forense a propósito: deja la clave incremental puesta en el modelo `Template` y observa los cuatro síntomas en orden. Documenta la ruta completa en `HALLAZGOS.md`.
22. Implementa la paginación y demuestra con dos pruebas que es compatible hacia atrás: una con `_page`, otra sin. Después responde: **¿qué pasa si alguien manda `_limit` sin `_page`?** Decide, impleméntalo y justifica.
23. **Diagnóstico.** Encuentra todas las respuestas donde un entero podría viajar como cadena. Escribe una comprobación en el `smoke.sh` para cada una — con `jq 'type'`, no con el valor.
24. Los ítems y las respuestas son `jsonb`. Escribe la consulta que encuentra **respuestas con un `itemId` que no existe en la plantilla de esa inspección**. Cuenta cuántas hay. Guarda la consulta: es el ensayo general de be05.
25. **Diagnóstico.** Apaga el mock, levanta el backend con `CHAOS=malformed CHAOS_RATE=1` y repite los ejercicios de la Fase 3 del track base. ¿Se comportan igual? Documenta cada diferencia.
26. Modela los ítems en una tabla hija en vez de `jsonb`, en una rama aparte. Mide: líneas de migración, líneas de serialización, y tiempo de `GET /templates`. Después decide cuál conservas y escribe el argumento en cinco líneas. **Las dos respuestas son defendibles.**
27. **Diagnóstico adversarial.** Un compañero señala que `inspections` no tiene clave foránea contra `templates` y propone añadirla ahora mismo. Escribe la respuesta en dos párrafos: por qué tiene razón, qué pasaría exactamente si la añade hoy (pista: cuenta primero las filas que la violan), y por qué esa conversación es de be05.

**🔴 Muy difícil (28–31)**

28. **Diagnóstico.** Consigue `OK: 24/24` y después demuestra que el frontend no cambió: `git diff fase-10-certificados-vigencia..HEAD -- src/` vacío, y un recorrido completo de las seis pantallas con Network abierto. Anota **cualquier** diferencia en las peticiones.
29. Escribe `contract-diff.sh` de verdad (ejercicio 24 de be00) y corre el `smoke.sh` contra el mock y contra PHP a la vez. Lista las comprobaciones que difieren. Si no difiere ninguna, tu `smoke.sh` es demasiado débil: **escribe tres comprobaciones más que sí las distingan**.
30. **Diagnóstico.** El sembrador mete las fechas con offset `-05:00` en columnas sin zona. Averigua exactamente qué guardó PostgreSQL: pide el valor crudo, compáralo con el JSON original, y escribe qué información se perdió. **Séllalo en un commit**: en be04 vas a abrirlo.
31. **Diagnóstico adversarial.** Alguien sostiene que reimplementar el dialecto de json-server fue un error y que lo correcto habría sido diseñar una API REST decente y adaptar el frontend. Escribe la refutación en tres párrafos con números: cuántos archivos del frontend habría que tocar (cuéntalos), cuánto duraría el sistema con dos contratos a la vez, y **qué parte del argumento contrario es cierta**. Esa última parte es la nota.

**🔥 Opcionales**

- 🔥 Añade `_sort` y `_order` del dialecto de json-server, que el frontend no usa. Después borra el commit y explica por qué implementar contrato que nadie consume es deuda y no previsión.
- 🔥 Mide `GET /inspections` con 5, 500 y 5000 filas. Dibuja la curva. ¿Dónde deja de ser aceptable, y qué habría que cambiar primero?

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/16/index.html — la documentación de la versión exacta que corre en el contenedor. Los capítulos de tipos de datos y de restricciones son los de esta fase.
- https://www.postgresql.org/docs/16/datatype-json.html — `json` frente a `jsonb`, y qué se puede y qué no se puede restringir dentro de un documento.
- https://laravel.com/docs/5.8/migrations y https://laravel.com/docs/5.8/eloquent — migraciones y ORM de la línea que trae Lumen 5.8. ⚠️ Es documentación de **Laravel**: lo de migraciones y Eloquent aplica tal cual, lo de facades y arranque no.
- https://www.php.net/manual/es/function.password-verify.php — el `password_verify` del login absorbido.
- https://github.com/typicode/json-server/tree/v0.17.4 — el dialecto que estás reimplementando, en su versión exacta.

**Libros / artículos de referencia**
- *Refactoring Databases* (Ambler y Sadalage, Addison-Wesley, 2006), capítulos 1 a 3 — el cambio de esquema sobre un sistema en producción y la idea de *transición* frente a *corte*. Es el marco de esta fase y de be05.
- *Building Microservices* (Sam Newman, 2.ª ed., 2021), capítulo 4 — el patrón de *strangler fig*, que aquí aparece en su versión más simple: sustituir el servidor entero conservando el contrato.

**Video / apoyo**
- https://www.youtube.com/results?search_query=postgresql+jsonb+vs+normalized+tables — la decisión de §4, discutida por gente que la ha sufrido en producción. Mira dos charlas con conclusiones opuestas: las dos tienen razón en su contexto.

**Orden de lectura sugerido:** tu propio `CONTRACT.md` **antes** de escribir la primera migración —es el requisito, no la documentación— → [`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md) **durante**, la primera vez que el SQL generado te sorprenda → la documentación de `jsonb` **cuando llegues al ejercicio 24** → Ambler y Sadalage **después**, si te quedas con ganas de arreglar el esquema: te van a explicar por qué se hace en dos pasos.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. Con la documentación de PostgreSQL, **comprueba siempre el número de versión en la URL**: `/docs/16/` y `/docs/current/` dejarán de ser lo mismo, y en be04 esa diferencia es el contenido de la fase.

---

## 🚀 9. Cierre y conexión con la siguiente fase

El mock está apagado. La aplicación Angular funciona entera contra PostgreSQL 16 servido por un Lumen de 2019, con el mismo contrato, en el mismo puerto y sin una línea cambiada en `src/`. El `smoke.sh` dice `24/24` y no lo has tocado.

Y dejaste tres cosas anotadas sin arreglar, que es más difícil que arreglarlas: cuántos certificados mienten hoy, qué información se perdió al meter fechas con offset en columnas sin zona, y el comentario en la migración donde debería haber una clave foránea compuesta y no la hay.

**be04** es el paso natural porque ahora hay una base de datos **con versión**. Y esa versión la ha estado moviendo alguien que no eres tú, durante ocho años, mientras la aplicación se quedaba quieta. La próxima fase investiga un incidente cuyo `git log` está vacío — y la respuesta está en el archivo que leíste en [`bea-02`](bea-02-receta-de-imagen-y-compose.md) y probablemente ya olvidaste.

> **La señal de que quedó bien:** *"apagué el mock, levanté el contenedor, y la única forma de notar el cambio fue que la lista de inspecciones tardó 40 ms más."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-03-el-reemplazo \
>   -m "be03 cerrada: siete tablas migradas y sembradas desde el db.json propio;
> dialecto de json-server reimplementado con paginación compatible hacia atrás;
> login absorbido sin cambio de contrato; smoke.sh en OK: 24/24 sin tocarlo;
> certificados que mienten, contados y anotados"
> ```
>
> Los commits de esta fase llevan `be03: …` y los de ejercicio `be03 ej24: …`.
>
> Esta fase paga la primera deuda del track base y la factura se lee con un comando:
>
> ```bash
> git diff be-fase-01-lumen-y-la-familiaridad-falsa be-fase-03-el-reemplazo -- server/routes/web.php
> ```
>
> Ahí se ve cómo las tres plantillas fijas dentro de una clausura (💸 de be01 §5.6) se convierten en un controlador con una consulta. Si esa clausura sigue viva, la fase no está cerrada. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥.

---

## 📌 Pendientes sugeridos

- **Los dominios sin `CHECK`** (`status`, `severity`, `type`) quedan declarados como deuda aceptada y no como olvido. Meter cuatro restricciones sobre ocho años de datos a la vez diluiría la lección de be05. → **`bea-10`**, con su razón; y un 🔥 de be05 para quien quiera aplicarle el mismo procedimiento a una quinta columna.
- **`items` y `answers` en `jsonb` no admiten restricciones**, y el ejercicio 24 demuestra que ya hay respuestas huérfanas. Es la misma clase de agujero que la invariante de plantillas, un nivel más abajo. → **be05**, como caso secundario tras el principal.
- **El `smoke.sh` no detecta el cambio de formato de fecha** (ejercicio 🧨). Es un agujero real del juez del contrato, y taparlo aquí quitaría a be04 su mejor demostración. → **be04**, donde el agujero se usa primero y se tapa después.
- **El sembrador no es idempotente** (ejercicio 17). Con `docker compose down -v` no molesta; en cuanto alguien lo corra dos veces sobre la misma base, sí. → **be06**, junto con la estrategia de pruebas, que necesita sembrar y limpiar en cada ciclo.
- **La medición de `EXPLAIN` con cinco filas no dice nada** (ejercicio 19) y aun así hay que guardarla: sin línea base no hay comparación. → **be05**, que la repite con cuatro mil filas.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| **be-04** | "Desde el despliegue, las plantillas salen en otro orden" | Contrato · `ORDER BY` ausente | 🟡 |
| **be-05** | "No puedo crear inspecciones nuevas: dice que el id ya existe" | Siembra · secuencias desajustadas | 🟠 |
