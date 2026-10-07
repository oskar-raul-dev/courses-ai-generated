# Comandos Bash de la sesión 31a544c8-743c-4327-84b8-a34d9fce769e, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-11T17:46:31 · List prompts dir and count lines
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs && ls -la prompts/ && wc -l *.md prompts/*.md | tail -70

# --- 2026-09-11T17:46:34 · Read README and forense master
cat README.md && echo "=====FORENSE MASTER=====" && cat forense-master.md

# --- 2026-09-11T17:46:42 · Inspect be00 and git state
head -60 be00-el-contrato-auditoria-del-mock.md && echo "=== GIT ===" && git status --short . && echo "=== recent ===" && ls -lat *.md | head -12

# --- 2026-09-11T17:46:45 · List BE phases and appendices headings
grep -nE '^#{2,3} .*(be0[0-7]|bea-[0-9]{2})' prompts/propuesta-fases-backend.md | head -40

# --- 2026-09-11T17:48:06 · Read backend phase prompts
cat prompts/prompts-backend-fase.md

# --- 2026-09-11T17:48:09 · Read first part of backend phase prompts
sed -n '1,400p' /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/tool-results/bsnchn8sx.txt

# --- 2026-09-11T17:48:12 · Read rest of backend phase prompts
sed -n '400,800p' /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/tool-results/bsnchn8sx.txt

# --- 2026-09-11T17:48:16 · Read chapter templates
cat prompts/plantillas-de-capitulo.md

# --- 2026-09-11T17:48:20 · Read backend appendix prompts
cat prompts/prompts-backend-apendice.md

# --- 2026-09-11T17:48:24 · Outline of propuesta-fases-backend
grep -n '^#\{1,3\} ' prompts/propuesta-fases-backend.md

# --- 2026-09-11T17:48:30 · Read sections 1-7 intro of propuesta
sed -n '160,500p' prompts/propuesta-fases-backend.md

# --- 2026-09-11T17:48:33 · Read phases detail and appendices
sed -n '500,810p' prompts/propuesta-fases-backend.md

# --- 2026-09-11T17:48:36 · Outline of style guide
grep -n '^#\{2,3\} ' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-11T17:48:41 · Read checklist and BE track section
sed -n '716,859p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-11T17:48:45 · Outline of be00
grep -n '^#\{2,4\} \|^> 🏷️\|^### ' be00-el-contrato-auditoria-del-mock.md

# --- 2026-09-11T17:48:50 · Read be00 section 5
sed -n '93,250p' be00-el-contrato-auditoria-del-mock.md

# --- 2026-09-11T17:48:53 · Read be00 sections 6-9 and closing
sed -n '405,560p' be00-el-contrato-auditoria-del-mock.md

# --- 2026-09-11T17:50:21 · Find token shape in phase 2
grep -n "accessToken\|sub\b\|expiresIn\|HS256\|role\|jwt.sign\|exp\b" 02-autenticacion.md | head -40

# --- 2026-09-11T17:50:23 · Read mock auth implementation
sed -n '125,215p' 02-autenticacion.md

# --- 2026-09-11T17:50:27 · Find chaos injector details
grep -n "CHAOS\|chaos" 03-mock-api-caos.md | head -50

# --- 2026-09-11T17:50:31 · Read chaos.js and server.js of mock
sed -n '388,470p' 03-mock-api-caos.md; echo ====; sed -n '505,600p' 03-mock-api-caos.md

# --- 2026-09-11T17:50:33 · Read rest of chaos and server
sed -n '470,600p' 03-mock-api-caos.md

# --- 2026-09-11T17:55:35 · Write be01 sections 1-5
cat > be01-lumen-y-la-familiaridad-falsa.md <<'MDEOF'
# 🐘 Fase be01 — Lumen sobre PHP 7.4, y la familiaridad falsa

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Fase be01 de be07 · **10 horas** ⭐
> Depende de: **be00 cerrada** (`CONTRACT.md` y `smoke.sh` en verde contra el mock) · Habilita: be02
> Apéndices de apoyo: [`bea-01`](bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md) · [`bea-02`](bea-02-receta-de-imagen-y-compose.md) · [`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md) · Incidentes asociados: **be-01**, **be-02**
> Estilo de esta fase: **PHP 7.4 sin azúcar de PHP 8**, y Lumen 5.8.13 — la última versión de su línea, congelada en agosto de 2019

> 🔥 **Esta fase pertenece al track opcional de backend.** El track base se completa sin abrirla.

---

## 🎯 1. Propósito

Levantar el monolito de 2016 y descubrir, en carne propia, que **parecerse a Laravel es peor que no parecerse a nada**.

Al terminar be00 sabes qué promete el servidor que vas a apagar. Ahora vas a conocer al que lo va a reemplazar, que lleva ocho años en producción emitiendo certificados y que nadie ha revisado nunca. La parte difícil no va a ser PHP — PHP se aprende en una tarde y `bea-01` está para eso. La parte difícil es que **casi todo lo que sabes de Laravel aplica aquí, menos lo que no**, y que no hay forma de saber cuál es cuál sin ejecutarlo.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `docker compose up -d` levanta los dos servicios y `curl localhost:3000/health` devuelve `{"status":"ok","php":"7.4.33","lumen":"5.8.13","chaos":"ninguno"}`. Sin instalar PHP, Composer ni `psql` en tu máquina.
- [ ] `docker compose exec api composer show laravel/lumen-framework` dice **`5.8.13`**, y `cat server/composer.json` explica por qué no dice `6.0`.
- [ ] El **inyector de caos está reimplementado en PHP** con los seis modos, las mismas variables (`CHAOS`, `CHAOS_RATE`, `CHAOS_DELAY_MS`) y las mismas dos vías de activación. `CHAOS=latencia` —mal escrito, en español— **impide que el servicio arranque** y el log nombra los seis válidos.
- [ ] Los ejercicios de caos de la **Fase 3 del track base** se repiten contra este backend sin cambiar una palabra del enunciado. Lo comprobaste con tres de ellos como mínimo.
- [ ] `BASE_URL=http://localhost:3000 ./smoke.sh` corre sin modificar una línea y da **`OK: 4/24`**. No es un fallo: es la línea base. Anotaste cuáles cuatro pasan y por qué.
- [ ] `FALSA-FAMILIARIDAD.md` existe y documenta los **cuatro bugs**, cada uno con el comando que lo reproduce y la salida literal.
- [ ] Hiciste el **experimento de los diez minutos** de §5.9 y pegaste la respuesta del asistente con tus anotaciones. Esa página es el mejor material que vas a producir en el track.

---

## 🚫 3. Qué NO entra todavía

- **PostgreSQL, migraciones, modelos que consultan de verdad** → be03. Aquí se sirven datos fijos, y el límite exacto es `->toSql()`: la consulta se construye, no se ejecuta.
- **La clasificación del código heredado por procedencia** → be02. Hoy lo levantas; la próxima fase lo lees con lupa.
- **Las pruebas automatizadas** → be06, y por una razón que se escribe allí: no se puede probar lo que todavía no se ha decidido cuál es.
- **Subir a PHP 8.** Es la premisa del track, no un pendiente. La conversación completa es de be07.
- **El login de verdad.** El mock sigue siendo el que autentica hasta be03; aquí `/health` es público y no hay nada más que proteger.

---

## 🧠 4. Concepto mínimo

### El ticket que abre el track

Antes de mirar una línea de código conviene leer el ticket que hace que este track exista, porque explica la urgencia y también por qué la urgencia no sirve de nada:

> **SEC-2291 · Prioridad alta.** La auditoría de cumplimiento anual señaló que `certcore-api` corre sobre **PHP 7.4, sin soporte de seguridad desde el 28 de noviembre de 2022**. Se requiere plan de actualización a PHP 8.x antes del cierre del trimestre.

Suena a tarde de trabajo. Son dos comandos para averiguar que no lo es:

```bash
# Qué versión de Lumen corre aquí.
docker compose exec api composer show laravel/lumen-framework | head -3
#   name     : laravel/lumen-framework
#   versions : * 5.8.13
#   released : 2019-08-28

# Qué PHP admite.
docker compose exec api composer show laravel/lumen-framework | grep -A1 requires
#   php ^7.1.3
```

`^7.1.3` **excluye PHP 8**, y no por capricho de Composer: la línea 5.8 es de 2019 y nunca se probó contra un runtime que salió en 2020. El primer Lumen que declara `^8.0.2` es **9.0.0, del 15 de febrero de 2022**. Entre uno y otro hay cuatro versiones mayores —6, 7, 8, 9—, cada una con su tanda de cambios de ruptura en Illuminate.

> 🧭 **El ticket pide subir el runtime y lo que en realidad pide es cambiar de framework.** Nadie escribió eso en el ticket porque nadie lo sabía. Averiguarlo en diez minutos, antes de estimar, es la mitad del oficio que enseña este track.

### La cronología de Lumen en CertCore, que dice más que un post-mortem

La **Era 0** de [`00-historia-del-sistema.md`](00-historia-del-sistema.md) fecha la API en 2016. Las versiones lo confirman con precisión de recibo:

| Cuándo | Qué pasó | Evidencia |
|---|---|---|
| Septiembre de 2016 | Nace `certcore-api` sobre **Lumen 5.2.9** (publicada el 7/09/2016), PHP 5.6 | El primer commit del `composer.lock` |
| 2017–2019 | Tres subidas dentro de la línea 5.x, todas sin drama: 5.3 → 5.5 → 5.8 | El `composer.lock` versionado |
| Agosto de 2019 | Última subida: **5.8.13**, del 28/08/2019 | El `composer.lock` no se ha vuelto a tocar |
| Septiembre de 2019 | Sale **Lumen 6.0.0** (12/09/2019), que pide `php ^7.2` | Nunca se subió |
| 2020–2026 | Nada | Nada |

Mira las dos últimas fechas: **quince días**. El equipo subió hasta el último escalón de su línea y la siguiente versión mayor salió dos semanas después. No hubo decisión de quedarse; hubo una persona que se fue, un sprint que se llenó de otra cosa, y siete años.

> 📝 **Nota de migración.** Lumen 5.8 corre en PHP 7.4 y lo hace bien, aunque su `composer.json` sea de 2019: `^7.1.3` incluye 7.4 y la línea 5.8 recibió parches hasta agosto de ese año. Es decir: el sistema **no está roto**. Está sin soporte, que es otra cosa y es peor, porque no duele.

### Lumen en una línea, y lo que le quitó a Laravel

Lumen es Laravel con el bootstrap partido por la mitad. Mismos componentes de Illuminate, mismo Eloquent, misma sintaxis de rutas — y un arranque que carga sólo lo que le pides. Esa es toda la idea, y en 2016 era una buena idea: una API que no necesita sesiones ni vistas no tiene por qué pagar el arranque completo.

Lo que quitó importa más que lo que dejó, porque es exactamente lo que la respuesta de internet da por hecho:

| Lo que asume un ejemplo de Laravel | Qué pasa aquí |
|---|---|
| Los facades (`Cache::get()`, `DB::table()`) están disponibles | **Apagados por defecto.** `$app->withFacades()` está comentado en `bootstrap/app.php` |
| Eloquent está listo | **Apagado por defecto.** `$app->withEloquent()`, ídem |
| `session()`, `Session::get()` | **No existe.** Lumen no trae sesiones |
| `Route::resource()`, `Route::middleware()->group()` | **No existe** esa fachada de rutas. Aquí es `$router->get(...)` |
| `config()` lee cualquier archivo de `config/` | Sólo lee los que registres con `$app->configure('nombre')` |
| `env()` funciona en cualquier parte | Funciona, pero **fuera de `config/` es un bug esperando**: en cuanto alguien cachee la configuración deja de leerse |
| Middleware terminable, buena parte de los eventos | Recortados |

🪞 **Tu instinto de Laravel dice… y esta vez se equivoca.** Tu instinto dice *"esto es Laravel, sé moverme"*. Y tiene razón en el 80%. El problema es que un 80% de acierto con un 20% invisible es **el peor reparto posible**: te da confianza para no comprobar, y te deja sin la señal que te haría comprobar. Un framework completamente desconocido te obliga a leer la documentación desde el primer minuto; éste no.

🩻 **Esto sí funciona igual.** Y es mucho, para que no salgas de aquí pensando que Lumen es un campo minado: el ciclo petición → router → middleware → controlador → respuesta es el de Laravel, tal cual. La inyección por el contenedor funciona igual. Eloquent, cuando lo enciendas en be03, es **el mismo Eloquent**, sin recortes. La validación es la misma. Los helpers de colecciones son los mismos. Si sabes leer un controlador de Laravel, sabes leer uno de aquí.

### Shared-nothing, que es la diferencia conceptual de verdad

Si vienes de Node, Go, Java o .NET, tu modelo mental es un proceso que arranca una vez, se queda vivo, y atiende peticiones sobre un estado que persiste. **PHP no es eso.** Cada petición arranca un intérprete limpio, carga las clases que necesita, responde, y **se muere entera**: no quedan variables globales, ni conexiones abiertas, ni cachés en memoria, ni un `BehaviorSubject` guardando nada entre una petición y la siguiente.

Eso tiene dos consecuencias que vas a sentir hoy mismo. La buena: una fuga de memoria en PHP es casi imposible de sostener, porque el proceso se muere en cada petición. Ese modelo perdona una barbaridad, y parte de que CertCore lleve ocho años en pie sin que nadie lo mire se explica por ahí. La mala la vas a descubrir en §5.6 con el modo `timeout`.

El detalle de sintaxis, `declare(strict_types=1)`, los arrays que son lista y mapa a la vez, y cómo se lee un stack trace de PHP están en [`bea-01`](bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md). No los repito aquí: enlazo.

---

## 💻 5. Código mínimo con comentarios

### 5.1 La forma del monolito

Todo el backend vive en `server/`, dentro del mismo proyecto. El frontend sigue en la raíz **y no se toca** — `git diff fase-10-certificados-vigencia..HEAD -- src/` tiene que seguir devolviendo vacío al cerrar esta fase, igual que al cerrar be00.

```
server/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── HealthController.php
│   │   └── Middleware/
│   │       └── ChaosMiddleware.php
│   ├── Support/
│   │   └── ChaosConfig.php
│   └── Models/                  ← vacío hasta be03
├── bootstrap/
│   └── app.php                  ← el archivo que hay que leer entero ⭐
├── config/
│   └── chaos.php
├── public/
│   └── index.php
├── routes/
│   └── web.php
├── tools/
│   └── probe.php                ← el laboratorio de la magia (§5.8)
├── composer.json
└── composer.lock                ← versionado, y es la prueba documental de §4
docker/
└── php/
    └── Dockerfile
compose.yaml
.env
```

La receta completa del `Dockerfile`, el `compose.yaml` y el `.env` está en [`bea-02`](bea-02-receta-de-imagen-y-compose.md), incluido el motivo por el que la primera construcción de esa imagen falla si la copias de cualquier tutorial. Ábrelo ahora, levanta la pila, y vuelve aquí.

### 5.2 `composer.json`, que es un documento histórico

```json
{
  "name": "certcore/api",
  "description": "API de inspecciones y certificaciones",
  "type": "project",
  "require": {
    "php": "^7.1.3",
    "laravel/lumen-framework": "5.8.*",
    "firebase/php-jwt": "^5.0",
    "vlucas/phpdotenv": "^3.3"
  },
  "autoload": {
    "psr-4": {
      "App\\": "app/"
    }
  },
  "config": {
    "preferred-install": "dist",
    "sort-packages": true,
    "optimize-autoloader": true
  },
  "minimum-stability": "stable",
  "prefer-stable": true
}
```

**Detalles con intención**

- **`"php": "^7.1.3"` no lo escribió nadie de CertCore**: viene del esqueleto de Lumen 5.8, copiado tal cual. Nadie lo revisó nunca, y hoy es la línea que decide si el ticket SEC-2291 es una tarde o un trimestre. La restricción más cara del sistema entró por copiar y pegar.
- **`firebase/php-jwt ^5.0`** es la línea contemporánea de Lumen 5.8, y es la que va a absorber el `jsonwebtoken` del mock en be03. Fíjate en la implicación: el contrato del token no cambia, cambia quién lo firma.
- **`composer.lock` está versionado.** Es lo correcto y encima es la fuente documental de §4: `git log --follow server/composer.lock` es el único sitio del repositorio donde la historia de este backend está escrita de verdad. Guárdate ese comando; en be04 vas a necesitar el contrario — un cambio que **no** está en ningún log.

### 5.3 `bootstrap/app.php`, el archivo que no es de Laravel ⭐

Si sólo lees un archivo de esta fase, que sea éste. En Laravel el arranque está repartido entre proveedores de servicios y nadie lo mira nunca. En Lumen cabe en una pantalla, y **cada línea comentada es una decisión que alguien tomó** —o que nadie tomó, que es lo que suele pasar.

```php
<?php
// server/bootstrap/app.php
// El arranque completo de la aplicación. Aquí se decide qué existe y qué no.

require_once __DIR__ . '/../vendor/autoload.php';

// Carga el .env. En Lumen esto es explícito: no hay magia que lo haga por ti.
(new Laravel\Lumen\Bootstrap\LoadEnvironmentVariables(
    dirname(__DIR__)
))->bootstrap();

$app = new Laravel\Lumen\Application(
    dirname(__DIR__)
);

// ── Las dos líneas más importantes del archivo ──────────────────────────────
// Con withFacades() encendido, Cache::get() y DB::table() existen. Apagado,
// lanzan "Class not found" — y ese es el bug 2 de §5.7.
// CertCore las tiene ASÍ desde 2016, y eso explica la mitad de las rarezas
// del código heredado: quien llegaba de Laravel se encontraba con que sus
// reflejos no compilaban, y resolvía cada uno a su manera.
// $app->withFacades();
// $app->withEloquent();   ← se enciende en be03, no antes

$app->singleton(
    Illuminate\Contracts\Debug\ExceptionHandler::class,
    App\Exceptions\Handler::class
);

$app->singleton(
    Illuminate\Contracts\Console\Kernel::class,
    App\Console\Kernel::class
);

// Sólo los archivos de config/ que registres aquí son legibles con config().
// Uno que exista en el directorio y no esté en esta lista devuelve null, sin
// advertencia. Es la primera trampa que se lleva a todo el mundo.
$app->configure('chaos');

// ── Middleware global: corre en TODA petición, en este orden ────────────────
$app->middleware([
    App\Http\Middleware\CorsMiddleware::class,
    App\Http\Middleware\ChaosMiddleware::class,
]);

// Middleware con nombre, que se aplica ruta por ruta. Vacío hasta be03, que es
// cuando vuelve a haber algo que proteger.
$app->routeMiddleware([]);

$app->router->group([
    'namespace' => 'App\Http\Controllers',
], function ($router) {
    require __DIR__ . '/../routes/web.php';
});

return $app;
```

**Detalles con intención**

- **El orden del array de `middleware()` es el orden de ejecución.** CORS va primero por la misma razón que en el mock de la Fase 3: si el caos responde un `500` antes de que se pongan las cabeceras, el navegador te va a contar un problema de CORS que no existe y vas a depurar el error equivocado. Es la misma decisión, en otro lenguaje, y compararlas es el ejercicio 12.
- **`$app->configure('chaos')` no es opcional.** Sin esa línea, `config('chaos.faults')` devuelve `null` en silencio y el inyector se queda apagado sin decir nada. Un archivo en `config/` que nadie registró es invisible.
- **Las dos líneas comentadas no son un ejemplo didáctico**: son el estado real de CertCore. Las descomentarás una sola vez en todo el track —`withEloquent()` en be03— y `withFacades()` **no la vas a descomentar nunca**, porque encenderla hoy cambiaría el comportamiento de código heredado que ya se acostumbró a vivir sin ella. Eso también es una decisión, y va documentada.

**El patrón a memorizar**

> En un framework con arranque explícito, lo que está comentado te dice más que lo que está escrito. Lee `bootstrap/app.php` **antes** que cualquier controlador: te ahorra suponer.

### 5.4 El primer endpoint vivo

`public/index.php` es de dos líneas útiles y no se toca nunca más:

```php
<?php
// server/public/index.php — el único punto de entrada. Todo pasa por aquí.

$app = require __DIR__ . '/../bootstrap/app.php';

$app->run();
```

Las rutas, que en Lumen son `$router` y no `Route::`:

```php
<?php
// server/routes/web.php
// Ojo con el instinto: aquí NO existe Route::get(), ni Route::resource(),
// ni Route::middleware()->group(). El router es una variable, no un facade.

/** @var \Laravel\Lumen\Routing\Router $router */

$router->get('/health', 'HealthController@show');
```

Y el controlador, que existe para dar tres datos y para ser el primer sitio donde ves inyección por el contenedor:

```php
<?php
// server/app/Http/Controllers/HealthController.php

declare(strict_types=1);

namespace App\Http\Controllers;

use Laravel\Lumen\Routing\Controller as BaseController;

class HealthController extends BaseController
{
    /**
     * Devuelve el estado del servicio. Es público a propósito: un endpoint de
     * salud que exige token no sirve para lo que sirve un endpoint de salud.
     *
     * @return array<string, string>
     */
    public function show(): array
    {
        // config() lee de config/chaos.php porque bootstrap/app.php lo registró
        // con $app->configure('chaos'). Sin esa línea, esto sería null.
        $faults = config('chaos.faults');

        return [
            'status' => 'ok',
            'php' => PHP_VERSION,
            // La constante la define el propio framework. Es la forma honesta
            // de responder "qué versión soy": la que reporta el código que corre,
            // no la que dice el composer.json.
            'lumen' => app()->version(),
            'chaos' => $faults === [] ? 'ninguno' : implode(',', $faults),
        ];
    }
}
```

**Detalles con intención**

- **Devolver un array desde un controlador de Lumen produce JSON**, con `Content-Type: application/json` y todo. No hace falta `response()->json()`. Es cómodo, es idiomático, y en be02 te va a servir para clasificar código: quien venía de Symfony **nunca** hace esto y devuelve siempre un objeto `Response` explícito.
- **`app()->version()` devuelve algo como `Lumen (5.8.13) (Laravel Components 5.8.*)`.** Léelo entero la primera vez: ahí está, en una cadena, la relación real entre los dos frameworks.

**Prueba de fuego**

```bash
docker compose up -d
curl -s localhost:3000/health | jq .
```

Tiene que salir el objeto de la sección 2. Si sale una página de error de PHP en HTML, el problema es de arranque y `bea-02` tiene los tres errores que salen siempre. **Y si `curl` devuelve vacío sin error**, no tienes un problema de PHP: tienes el contenedor parado. `docker compose ps` antes que cualquier otra cosa.

### 5.5 El inyector de caos, en PHP

Lo construiste en JavaScript en la Fase 3 y lo inventariaste en be00 §5.4. Ahora se reimplementa con los mismos seis modos, las mismas variables de entorno y las mismas dos reglas — porque los enunciados de ocho fases del track base dependen de que se comporte igual.

Primero la configuración, que **falla ruidosamente**:

```php
<?php
// server/app/Support/ChaosConfig.php

declare(strict_types=1);

namespace App\Support;

use RuntimeException;

class ChaosConfig
{
    /** Los seis modos válidos. Cualquier otro mata el arranque. */
    public const KNOWN_FAULTS = ['latency', 'error', 'malformed', 'cors', 'expired', 'timeout'];

    private const DEFAULT_DELAY_MS = 2500;
    private const DEFAULT_RATE = 0.3;

    /**
     * Lee la configuración del entorno y valida. Devuelve un array asociativo
     * porque config/chaos.php espera exactamente esa forma.
     *
     * @param array<string, string> $env
     * @return array{faults: string[], delayMs: int, rate: float}
     */
    public static function fromEnvironment(array $env): array
    {
        $raw = trim($env['CHAOS'] ?? '');
        // array_filter sin callback elimina las cadenas vacías, que es lo que
        // deja un CHAOS=latency, con coma colgando.
        $faults = $raw === '' ? [] : array_values(array_filter(array_map('trim', explode(',', $raw))));

        $unknown = array_diff($faults, self::KNOWN_FAULTS);

        if ($unknown !== []) {
            // Igual que en el mock: fallar al arrancar, no en silencio. Un
            // CHAOS=latencia mal escrito que simplemente no hace nada te cuesta
            // veinte minutos buscando un bug que no existe.
            throw new RuntimeException(sprintf(
                'Fallos de caos desconocidos: %s. Los válidos son: %s.',
                implode(', ', $unknown),
                implode(', ', self::KNOWN_FAULTS)
            ));
        }

        return [
            'faults' => $faults,
            'delayMs' => (int) ($env['CHAOS_DELAY_MS'] ?? self::DEFAULT_DELAY_MS),
            'rate' => (float) ($env['CHAOS_RATE'] ?? self::DEFAULT_RATE),
        ];
    }
}
```

```php
<?php
// server/config/chaos.php
// Este archivo sólo es legible porque bootstrap/app.php hace
// $app->configure('chaos'). Bórrale esa línea y config('chaos.faults') pasa a
// devolver null sin una sola advertencia.

return App\Support\ChaosConfig::fromEnvironment($_ENV + $_SERVER);
```

Y el middleware, que es donde viven cinco de los seis modos:

```php
<?php
// server/app/Http/Middleware/ChaosMiddleware.php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class ChaosMiddleware
{
    /** @var string[] */
    private $faults;

    /** @var int */
    private $delayMs;

    /** @var bool */
    private $rolled;

    public function __construct()
    {
        $configured = config('chaos');

        $this->faults = $configured['faults'];
        $this->delayMs = $configured['delayMs'];
        // El dado se tira UNA vez por petición y se reutiliza, igual que en el
        // mock: si cada fallo tirara el suyo, con dos flags activos la mitad de
        // las peticiones saldría ilesa y el escenario dejaría de ser reproducible.
        $this->rolled = (mt_rand() / mt_getrandmax()) < $configured['rate'];
    }

    /**
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        // El caos no toca la autenticación. `expired` es la excepción y vive
        // donde se firma el token, no aquí.
        if (strpos($request->path(), 'auth/') === 0) {
            return $next($request);
        }

        if ($this->has('latency')) {
            // Incondicional, como en el mock: una latencia intermitente no se
            // distingue de un problema de red, y aquí queremos que se distinga.
            usleep($this->delayMs * 1000);
        }

        if ($this->has('timeout') && $this->rolled) {
            // Ni respondemos ni llamamos a $next. Lee la advertencia de abajo
            // antes de usar este modo: en PHP no sale gratis.
            while (true) {
                sleep(1);
            }
        }

        if ($this->has('error') && $this->rolled) {
            return response()->json(['message' => 'Fallo interno del servidor'], 500);
        }

        $response = $next($request);

        if ($this->has('malformed') && $this->rolled) {
            return $this->corrupt($response);
        }

        return $response;
    }

    private function has(string $fault): bool
    {
        return in_array($fault, $this->faults, true);
    }

    /**
     * Las dos mismas corrupciones del mock, y las dos son fallos reales de
     * despliegue: envolver un array en un objeto —el clásico cambio a respuesta
     * paginada que nadie avisó— y cambiar el tipo de un campo numérico.
     *
     * @param mixed $response
     * @return mixed
     */
    private function corrupt($response)
    {
        $body = json_decode($response->getContent(), true);

        if (is_array($body) && array_keys($body) === range(0, count($body) - 1)) {
            // Un array de lista, en el sentido de PHP: claves 0..n-1. La
            // comprobación es fea y es obligatoria, porque en PHP una lista y
            // un mapa son el mismo tipo (bea-01).
            return response()->json(['items' => $body, 'total' => count($body)]);
        }

        if (is_array($body) && isset($body['version']) && is_int($body['version'])) {
            $body['version'] = (string) $body['version'];

            return response()->json($body);
        }

        return $response;
    }
}
```

**Detalles con intención**

- **El dado se tira en el constructor**, no en `handle()`. En PHP eso basta para que sea "una vez por petición": el contenedor construye el middleware una sola vez por petición porque **la petición entera es un proceso nuevo**. En un backend persistente, este mismo código daría un valor fijo para toda la vida del proceso y sería un bug grave. Es la primera vez que shared-nothing cambia el significado de un fragmento, y no va a ser la última.
- **`usleep()` bloquea el proceso entero, no sólo la petición.** Con el servidor embebido en su configuración por defecto, `CHAOS=latency` no retrasa una respuesta: **congela el servidor** 2,5 segundos para todo el mundo. El mock de Node no tenía este problema porque `setTimeout` no bloquea nada.

> ⚠️ **El modo `timeout` cuelga el servidor completo, y hay que saberlo antes de usarlo.** El servidor embebido de PHP corre un único proceso de un solo hilo: la documentación oficial lo dice con todas sus letras —*"the web server runs only one single-threaded process, so PHP applications will stall if a request is blocked"*—. Una petición que no termina nunca no deja pasar ninguna otra.
>
> La salida está en `compose.yaml` y es una línea, **disponible por primera vez en PHP 7.4.0**, que es justo la última versión que este sistema alcanzó:
>
> ```yaml
> environment: { PHP_CLI_SERVER_WORKERS: 4 }
> ```
>
> Con cuatro *workers*, `timeout` cuelga uno y el resto sigue atendiendo, que es el comportamiento que los ejercicios de la Fase 3 dan por hecho. **Cuatro peticiones colgadas y estás igual que antes**, y eso también es fiel a la realidad: ésa es exactamente la forma en que se cae una API en PHP bajo presión, y no se parece en nada a como se cae una de Node.

🪞 **Tu instinto de Node dice… y esta vez se equivoca.** En Node, una petición lenta es una petición lenta. En PHP, **una petición lenta es un trabajador menos**, y el modelo de concurrencia es el número de procesos que tengas. El mock aguantaba `CHAOS=timeout` sin despeinarse porque era asíncrono; este backend, no. Cuando en be07 alguien proponga "lo mismo pero en Node", este párrafo es uno de los números de la columna.

**Prueba de fuego**

```bash
# 1. El modo desconocido mata el arranque, con mensaje útil.
CHAOS=latencia docker compose up api
#   RuntimeException: Fallos de caos desconocidos: latencia.
#   Los válidos son: latency, error, malformed, cors, expired, timeout.

# 2. El caos se combina, igual que en el mock.
CHAOS=latency,error CHAOS_RATE=1 docker compose up -d api
curl -s -o /dev/null -w '%{http_code} en %{time_total}s\n' localhost:3000/health
#   500 en 2.51s   ← el 500 llega retrasado: latency actúa antes que error
```

Ese `500 en 2.51s` es la misma respuesta que daba el mock en el ejercicio 16 de la Fase 3. Si el tuyo devuelve `500 en 0.01s`, tienes los dos fallos en el orden contrario y acabas de cambiar, sin querer, el enunciado de un ejercicio del track base.

### 5.6 Datos fijos, y el `smoke.sh` que baja

No hay base de datos hasta be03, así que `/templates` devuelve las tres plantillas escritas a mano. No es un atajo pedagógico: es la forma de tener **hoy** algo contra lo que correr el juez del contrato.

```php
<?php
// server/routes/web.php (añadido)

$router->get('/health', 'HealthController@show');

// Datos fijos hasta be03. La forma sale de CONTRACT.md, no de la imaginación:
// array desnudo, id compuesto, version numérica, validUntil null cuando la
// plantilla sigue vigente.
$router->get('/templates', function () {
    return [
        ['id' => 'elevator-annual-v1', 'templateId' => 'elevator-annual', 'version' => 1,
         'validFrom' => '2021-01-01', 'validUntil' => '2023-12-31', 'items' => []],
        ['id' => 'elevator-annual-v2', 'templateId' => 'elevator-annual', 'version' => 2,
         'validFrom' => '2024-01-01', 'validUntil' => null, 'items' => []],
        ['id' => 'boiler-annual-v1', 'templateId' => 'boiler-annual', 'version' => 1,
         'validFrom' => '2022-01-01', 'validUntil' => null, 'items' => []],
    ];
});
```

Ahora el momento de la fase:

```bash
BASE_URL=http://localhost:3000 ./smoke.sh
#   ...
#   OK: 4/24
```

**Cuatro de veinticuatro, y no se toca el `smoke.sh`.** Ése es el contador que vas a ver bajar y subir durante todo el track, y la regla que lo hace útil cabe en una línea: *el juez no se ajusta para aprobar al acusado*. Si en algún momento te descubres editando `smoke.sh` para que pase algo, para y pregúntate qué acabas de dejar de comprobar.

```
💸 DEUDA TÉCNICA INTENCIONAL — datos fijos en una ruta anónima
Las tres plantillas están escritas dentro de una clausura en routes/web.php,
sin modelo, sin repositorio y sin fuente. Es lo correcto HOY —no hay base y el
objetivo es tener contra qué medir—, y es exactamente la clase de código que
se queda seis años si nadie lo borra.
SE PAGA EN be03, y la factura se lee con:
    git diff be-fase-01-... be-fase-03-... -- server/routes/web.php
```

### 5.7 Los cuatro bugs de la familiaridad falsa ⭐

Esto es la mitad de la fase. Los cuatro se reproducen con un comando y **hay que ejecutarlos**, no leerlos: el objetivo no es que sepas que existen, es que reconozcas el síntoma dentro de seis meses en un sistema distinto.

Abre `FALSA-FAMILIARIDAD.md` y ve anotando: comando, salida literal, y una línea con la explicación.

#### Bug 1 — El `grep` que no encuentra un método que sí se ejecuta

En el código heredado, `app/Http/Controllers/LegacyTemplateController.php` tiene esto:

```php
// Código heredado, tal como está. En be02 vas a clasificar quién lo escribió.
$cached = Cache::get('templates.all');
```

Funciona. Se ejecuta. Ahora búscalo:

```bash
docker compose exec api grep -rn "function get" vendor/illuminate/cache/CacheManager.php
#   (nada)
```

Ningún archivo del proyecto declara un método estático `get` en una clase `Cache`. **No existe.** `Cache` es un facade: extiende `Illuminate\Support\Facades\Facade`, que implementa `__callStatic`, que pide al contenedor el servicio registrado bajo `cache` y le llama `get()` al objeto de verdad.

> 🧠 **En una capa con resolución dinámica, buscar el nombre no encuentra la implementación — encuentra el nombre.** Y en un curso construido entero sobre buscar en el código, ése es el reflejo que hay que romper.

El método que sí funciona —seguir el binding, `get_class()` en tiempo de ejecución, el stack trace como mapa— está desarrollado en [`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md), que es el apéndice que sostiene esta fase. La versión corta, ejecutable, está en §5.8.

#### Bug 2 — El ejemplo que funciona en Laravel y aquí no existe

Copia el primer resultado de cualquier búsqueda sobre cacheo en Laravel y ponlo en una ruta nueva:

```php
$router->get('/probe/cache', function () {
    return ['valor' => Cache::get('cualquier-cosa', 'por defecto')];
});
```

```bash
curl -s localhost:3000/probe/cache
#   Fatal error: Uncaught Error: Class 'Cache' not found
```

**En Lumen los facades están apagados por defecto.** El ejemplo no está mal: está escrito para un framework donde `$app->withFacades()` viene de fábrica. Aquí la línea está comentada en `bootstrap/app.php` desde 2016.

Y ahora lo que de verdad hace daño, que es el caso a medias. Descomenta `withFacades()`, reinicia, y vuelve a pedirlo: ahora responde `"por defecto"`. **Funciona.** Pero acabas de cambiar el arranque de una aplicación de ocho años, y hay código heredado que se escribió sabiendo que los facades no estaban — con su propio ayudante, su propio singleton, su propia manera. Vuelve a comentarla: la forma de arreglar esto **no** es encender la bombilla.

> ⚰️ **Autopsia de anti-patrón: encender los facades "para que compile".** Lo que se ve al hacerlo: una ruta que antes reventaba ahora responde. Lo que no se ve: `Cache`, `DB`, `Log` y treinta clases más pasan a existir en todo el proyecto, y el siguiente que llegue va a mezclar los dos estilos sin enterarse de que hay dos. Antes: un error ruidoso en un sitio. Después: cero errores y dos convenciones vivas. En be02 vas a contar cuántas hay, y esta clase de decisión es de dónde salieron.

#### Bug 3 — El scope que no aparece buscando su propio nombre

En el modelo heredado:

```php
// server/app/Models/Template.php — el modelo, tal como está desde 2018
class Template extends Model
{
    protected $table = 'templates';

    /**
     * Scope de Eloquent. Se DECLARA como scopeActive() y se INVOCA como
     * Template::active(). Buscar "active(" no lo encuentra nunca.
     */
    public function scopeActive($query)
    {
        return $query->whereNull('valid_until');
    }
}
```

```bash
docker compose exec api grep -rn "function active" server/app/
#   (nada)
docker compose exec api grep -rn "::active(" server/app/
#   app/Http/Controllers/LegacyTemplateController.php:31:  $rows = Template::active()->get();
```

Dos búsquedas, dos resultados incompatibles: hay una llamada y no hay una declaración. `__call` de Eloquent recibe `active`, le antepone `scope`, y llama al método que sí existe. Es la misma magia del bug 1 con otra puerta.

**Y aquí está el límite exacto de esta fase**, que es contenido y no una limitación:

```bash
docker compose exec api php tools/probe.php "Template::active()->toSql()"
#   select * from "templates" where "valid_until" is null

docker compose exec api php tools/probe.php "Template::active()->get()"
#   SQLSTATE[08006] [7] could not translate host name "db" ... o Connection refused
```

`toSql()` **no conecta con nada**: construye la consulta con la gramática que dice la configuración. `get()` sí, y ahí se acaba be01. Esa diferencia vale por sí sola: puedes investigar el 90% de un ORM sin una base de datos delante, y casi nadie lo sabe.

#### Bug 4 — Lo que Lumen quitó, y la respuesta que asume que está

```php
$router->get('/probe/session', function () {
    session(['ultima_consulta' => 'templates']);   // Laravel puro
    return ['ok' => true];
});
```

```bash
curl -s localhost:3000/probe/session
#   Fatal error: Uncaught Error: Call to undefined function session()
```

No es que esté apagado: **no existe**. Lumen no trae sesiones, y no las trae a propósito — una API sin estado no las necesita. Lo mismo con `Route::resource()`, con los grupos de middleware encadenados y con parte del sistema de eventos.

Lo interesante no es la lista. Es **cómo se comporta cada ausencia**, porque no todas fallan igual de bien:

| Lo que falta | Cómo se entera de que falta |
|---|---|
| `session()` | `Call to undefined function`. Ruidoso e inmediato: el mejor caso |
| `Cache::get()` sin facades | `Class 'Cache' not found`. Ruidoso, aunque el mensaje despista |
| `config('algo')` de un archivo no registrado | **`null`. En silencio.** El peor caso, y el más común |
| `env('ALGO')` fuera de `config/` | Funciona… hasta que alguien cachea la configuración |

> 🧭 **La regla que sale de esa tabla:** en Lumen, las ausencias que gritan son las que menos te van a costar. La factura la pasan las que devuelven `null` con cara de normalidad.

### 5.8 `tools/probe.php`, el laboratorio de la magia

Lumen 5.8 no trae `tinker`. Sin una consola interactiva, investigar una capa dinámica es incomodísimo, así que el laboratorio lo montas tú y son veinte líneas:

```php
<?php
// server/tools/probe.php — arranca la aplicación y evalúa una expresión.
//
//   docker compose exec api php tools/probe.php "get_class(app('cache'))"
//
// Existe porque en una capa con resolución dinámica la pregunta útil casi
// nunca es "qué dice el código", es "qué objeto hay aquí AHORA MISMO".

$app = require __DIR__ . '/../bootstrap/app.php';

$expression = $argv[1] ?? null;

if ($expression === null) {
    fwrite(STDERR, "Uso: php tools/probe.php \"<expresión PHP>\"\n");
    exit(1);
}

// eval() en una herramienta de laboratorio, que no se despliega y que sólo
// corre quien ya tiene una terminal dentro del contenedor. En cualquier otro
// sitio del proyecto esto sería una vulnerabilidad; bea-08 vuelve sobre la
// diferencia entre "peligroso" y "peligroso aquí".
$result = eval("return {$expression};");

var_dump($result);
```

Las cuatro preguntas que vas a hacerle todo el track:

```bash
# ¿Qué objeto está detrás de este facade, de verdad?
php tools/probe.php "get_class(app('cache'))"
#   string(38) "Illuminate\Cache\CacheManager"

# ¿Qué hay registrado en el contenedor?
php tools/probe.php "array_slice(array_keys(app()->getBindings()), 0, 10)"

# ¿Existe siquiera este método?
php tools/probe.php "method_exists(App\Models\Template::class, 'active')"
#   bool(false)     ← y sin embargo Template::active() funciona

# ¿Qué SQL sale de esto?
php tools/probe.php "App\Models\Template::active()->toSql()"
```

Ese `bool(false)` con la llamada funcionando al lado es **la pieza forense de la fase**, y por eso está en §6.

### 5.9 El experimento de los diez minutos ⭐

El mejor material de todo el track, y no lleva una línea de código propia.

**El protocolo**, que es el mismo para cualquier tecnología sin mercado, no sólo para Lumen:

1. Elige una tarea real y pequeña de esta fase. Por ejemplo: *"cómo registro un middleware global"*, *"cómo cacheo el resultado de una consulta"*, *"cómo devuelvo un 422 con errores de validación"*.
2. Pregúntaselo a un asistente **sin decirle que es Lumen 5.8**. Pregunta lo que preguntarías un martes: *"¿cómo registro un middleware global en Lumen?"*.
3. Copia la respuesta entera en `FALSA-FAMILIARIDAD.md`, sin editarla.
4. **Ejecútala tal cual** en tu contenedor.
5. Anota tres cosas: qué falló, **en qué momento** te habrías dado cuenta si no lo hubieras ejecutado, y qué parte de la respuesta era correcta. Casi siempre lo será en su mayoría.
6. Repítelo pidiéndole explícitamente *"para Lumen 5.8, no Laravel"*. Compara las dos respuestas y anota si la segunda mejoró **y si algo la delata como Laravel igualmente**.

Lo que vas a encontrar, y lo interesante es por qué: la respuesta será plausible, estará bien escrita, usará `Route::middleware()` o `$app->middleware()` según sople el viento, y **tendrá razón en todo menos en lo que no hay forma de saber sin ejecutar**. No es ignorancia. Es que hay cien veces más Laravel que Lumen escrito en el mundo, y una versión de 2019 pesa poco contra siete años de Laravel posterior.

> 🧠 **La ausencia de respuesta te vuelve cuidadoso; la respuesta plausible te vuelve confiado.** Con un framework que nadie conoce, lees la documentación desde el primer minuto. Con éste, no la abres nunca — y ése es el bug más caro del track, el único que no está en ninguna línea de código.

Y el remate, que es lo que convierte el experimento en un argumento de be07: **esto le pasa igual a la persona que contrates.** Llega de Laravel, es buena, y va a cometer estos cuatro errores durante sus primeros tres meses. Multiplícalo por las tres veces que se repitió el ciclo en CertCore y tienes un número — no una sensación — para la opción 1 del *assessment*.

---
MDEOF
wc -l be01-lumen-y-la-familiaridad-falsa.md

# --- 2026-09-11T17:55:57 · Insert CorsMiddleware snippet into be01
python3 - <<'PY'
import re
p='be01-lumen-y-la-familiaridad-falsa.md'
s=open(p).read()
anchor="**Detalles con intención**\n\n- **El dado se tira en el constructor**"
add = '''Faltan dos de los seis modos, y el reparto es idéntico al del mock: **`cors` vive donde se ponen las cabeceras** —no se puede omitir una cabecera desde un middleware que corre después— y **`expired` vive donde se firma el token**, que hasta be03 sigue siendo el mock.

```php
<?php
// server/app/Http/Middleware/CorsMiddleware.php

declare(strict_types=1);

namespace App\\Http\\Middleware;

use Closure;
use Illuminate\\Http\\Request;

class CorsMiddleware
{
    /**
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        $breakCors = in_array('cors', config('chaos.faults'), true);
        $isAuthRequest = strpos($request->path(), 'auth/') === 0;

        // El preflight se contesta aquí y se acaba: si lo dejas pasar, el caos
        // puede responderle un 500 y el navegador te va a contar un problema de
        // CORS que no existe.
        if ($request->getMethod() === 'OPTIONS') {
            $response = response('', 204);
        } else {
            $response = $next($request);
        }

        if (! $breakCors || $isAuthRequest) {
            // Las tres cabeceras son literalmente las del mock de la Fase 2.
            // X-Correlation-Id tiene que seguir en la lista: si desaparece, el
            // navegador rechaza la petición ANTES de enviarla y el error que
            // ves no menciona la cabecera.
            $response->headers->set('Access-Control-Allow-Origin', 'http://localhost:4200');
            $response->headers->set('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Correlation-Id');
            $response->headers->set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
        }

        return $response;
    }
}
```

'''
assert anchor in s
s=s.replace(anchor, add+anchor,1)
open(p,'w').write(s)
print("ok")
PY

# --- 2026-09-11T17:58:08 · Append be01 sections 6-9
cat >> be01-lumen-y-la-familiaridad-falsa.md <<'MDEOF'

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Encender `withFacades()` para que un ejemplo funcione.**
*Síntoma:* copiaste un fragmento de Laravel, dio `Class 'Cache' not found`, descomentaste la línea del bootstrap y ya funciona.
*Causa:* el ejemplo asume el arranque completo de Laravel, y el bootstrap de Lumen es explícito a propósito.
*Fix mínimo:* vuelve a comentarla y usa el contenedor directamente — `app('cache')->get(...)`, que es lo que el facade hace por dentro. Encender los facades no es un fix: es un cambio en el arranque de una aplicación de ocho años, y lo tiene que decidir alguien, no una prisa.

**Poner el archivo en `config/` y no registrarlo.**
*Síntoma:* `config('chaos.faults')` devuelve `null`, el inyector no hace nada, y no hay ningún error en ningún log.
*Causa:* falta `$app->configure('chaos')` en `bootstrap/app.php`. En Lumen los archivos de configuración no se descubren solos.
*Fix mínimo:* añade la línea. Y aprovecha para ver el patrón: **la ausencia más cara de esta capa es la que devuelve `null` sin avisar.**

**Depurar el orden del middleware leyendo el código.**
*Síntoma:* juras que CORS corre primero y las respuestas de error siguen saliendo sin cabeceras.
*Causa:* el orden es el del array de `$app->middleware([...])`, y lo que corre "después" en la ida corre "antes" en la vuelta. Un middleware que modifica la respuesta se comporta al revés que uno que modifica la petición.
*Fix mínimo:* no lo deduzcas. Mete un `error_log(__CLASS__)` en cada uno, pide `/health`, y lee `docker compose logs api`. Treinta segundos, cero suposiciones.

**Buscar el error de PHP en la respuesta HTTP.**
*Síntoma:* `curl` devuelve un `500` con un cuerpo HTML enorme, o directamente vacío, y no hay forma de saber qué pasó.
*Causa:* según cómo esté el manejador de excepciones, el error puede acabar en la salida estándar del proceso y no en la respuesta.
*Fix mínimo:* `docker compose logs -f api` **en una terminal aparte, siempre abierta**. En este track, el log del contenedor es lo que la consola del navegador era en el track base.

### Pieza forense de esta fase

**El `grep` vacío.**

Llega el ticket: *"la lista de plantillas está devolviendo datos viejos a veces"*. Tu reflejo, entrenado por catorce fases de Angular, es buscar en el código. Y por primera vez en el curso, **buscar no sirve**.

```bash
# Paso 1 — el reflejo. Dónde se cachea esto.
docker compose exec api grep -rn "Cache::get" server/app/
#   app/Http/Controllers/LegacyTemplateController.php:28

# Paso 2 — la implementación. Dónde está ese get().
docker compose exec api grep -rn "class Cache" server/app/ vendor/illuminate/support/
#   (nada útil: sólo el facade, que no implementa get)
```

Aquí se acaba el camino conocido, y empieza el que hay que aprender. Son tres pasos y ninguno es buscar:

1. **Pregúntale al objeto, no al archivo.** `php tools/probe.php "get_class(app('cache'))"` → `Illuminate\Cache\CacheManager`. Ya sabes qué clase mirar, y no la dedujiste: la observaste.
2. **Sigue el binding.** El facade declara su clave —`protected static function getFacadeAccessor() { return 'cache'; }`— y el contenedor la resuelve. El puente entre el nombre que ves y la clase que corre es esa cadena, y es la única pista que existe.
3. **Usa el stack trace como mapa.** Lanza una excepción a propósito dentro del bloque sospechoso y lee la traza de abajo arriba: `__callStatic` aparece en ella con nombre y apellido, y te dice el camino exacto que `grep` no podía enseñarte.

El desarrollo completo del método —incluida la tabla de qué técnica aplicar según el síntoma— está en [`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md).

> 🧠 **Cuando buscar deja de funcionar, deja de leer el código y empieza a interrogar al proceso.** Es transferible a cualquier framework con resolución dinámica, en cualquier lenguaje, y es lo único de esta fase que te va a servir en un sistema que no sea CertCore.

> 🧨 **Rompe a propósito y observa.** Comenta la línea `$app->configure('chaos')` en `bootstrap/app.php` y arranca con `CHAOS=error CHAOS_RATE=1`. Anota, en este orden: qué devuelve `/health`, qué dice el log, y cuánto tardas en darte cuenta de que el caos no se aplicó. Después haz lo contrario: deja la línea y escribe `CHAOS=eror` (con una erre). Compara los dos fallos. **Uno te cuesta veinte minutos y el otro cero**, y la única diferencia es que alguien decidió validar.

---

## 🧪 7. Ejercicios (32)

**🟢 Fácil (1–8)**

1. Levanta la pila con los cuatro comandos de [`bea-02`](bea-02-receta-de-imagen-y-compose.md) y pega la salida de `curl -s localhost:3000/health | jq .` en `FALSA-FAMILIARIDAD.md`, con la fecha. Es tu línea base.
2. Corre `docker compose exec api composer show laravel/lumen-framework` y anota las tres líneas que importan: versión, fecha de publicación y restricción de `php`. Explica en dos frases por qué esa última convierte el ticket SEC-2291 en otra cosa.
3. **Diagnóstico.** Corre `BASE_URL=http://localhost:3000 ./smoke.sh` sin tocarlo y anota cuáles comprobaciones pasan. Para cada una de las cuatro, di **por qué** pasa: ¿porque el backend la cumple, o porque la comprobación es débil?
4. Lee `bootstrap/app.php` entero y haz una lista de las líneas comentadas. Para cada una, escribe qué dejaría de fallar si la descomentaras y qué empezaría a cambiar.
5. Arranca con `CHAOS=latencia` y copia el mensaje de error literal. Después con `CHAOS=latency,eror`. ¿Nombra los seis válidos en los dos casos?
6. **Diagnóstico.** Mide `curl -s -o /dev/null -w '%{time_total}\n' localhost:3000/health` con y sin `CHAOS=latency`. Comprueba que la diferencia es `CHAOS_DELAY_MS` y no otra cosa.
7. Reproduce el bug 4: llama a `session()` desde una ruta y pega el error. Después busca `function session` en `vendor/` y explica el resultado.
8. Añade a `/health` un campo `container` con el `hostname` del contenedor. Comprueba que cambia al recrear el servicio, y di para qué te va a servir eso cuando haya más de un *worker*.

**🟡 Intermedio (9–19)**

9. **Diagnóstico.** Reproduce el bug 1 completo y documéntalo: los dos `grep` vacíos, el `get_class(app('cache'))`, y la clase real. Criterio de éxito: alguien que lea tu ficha puede repetir el hallazgo sin ayuda.
10. Reimplementa el modo `malformed` y comprueba con `curl` que corrompe **igual** que el mock: array envuelto en `{items, total}` y `version` numérica convertida a cadena. Compara las dos salidas lado a lado.
11. **Diagnóstico.** Con `CHAOS=timeout CHAOS_RATE=1` y **sin** `PHP_CLI_SERVER_WORKERS`, haz una petición, déjala colgada, y desde otra terminal pide `/health`. Describe qué pasa. Después pon cuatro *workers* y repite hasta agotarlos. Anota cuántas peticiones colgadas hacen falta.
12. Compara `ChaosMiddleware.php` con el `mock/chaos.js` de la Fase 3 y escribe las tres diferencias que **no** son de sintaxis. Pista: dónde se tira el dado, qué bloquea `usleep`, y qué pasa con el estado entre peticiones.
13. **Diagnóstico.** Pon un `error_log(__CLASS__)` en los dos middleware, pide `/health`, y lee el log. Dibuja el orden real de ida y de vuelta. ¿Coincide con el que habías supuesto leyendo el array?
14. Repite **tres ejercicios de caos de la Fase 3** del track base contra este backend, sin cambiar una palabra del enunciado. Anota cuál de los tres se comporta distinto y por qué; si ninguno, dilo, que también es un resultado.
15. Añade un `config/app.php` con una clave cualquiera y léela con `config()` **sin** registrarla en el bootstrap. Anota qué devuelve. Regístrala y repite. Escribe la regla en una línea.
16. **Diagnóstico.** Descomenta `$app->withFacades()`, pide `/probe/cache` y comprueba que responde. Después busca en `server/app/` todo el código heredado que resuelve cacheo **sin** facades. ¿Cuántas formas distintas encuentras? Guarda el número: es la primera medición de be02.
17. Escribe `tools/probe.php` y úsalo para responder tres preguntas: qué clase hay detrás de `app('cache')`, cuántos bindings tiene el contenedor al arrancar, y si `Template` tiene un método `active`.
18. **Diagnóstico.** Ejecuta `Template::active()->toSql()` y después `->get()`. Pega las dos salidas y explica en tres frases por qué la primera funciona sin base de datos.
19. Haz el experimento de los diez minutos (§5.9) con una pregunta tuya, y documenta los seis pasos. Este ejercicio no se salta.

**🟠 Difícil (20–27)**

20. **Diagnóstico.** El `smoke.sh` da `4/24`. Elige **una** comprobación que falle y que puedas hacer pasar sin base de datos, hazla pasar, y argumenta en cinco líneas si eso mejora el backend o sólo mejora el marcador.
21. Documenta los cuatro bugs en `FALSA-FAMILIARIDAD.md` con el formato de la §6: síntoma, causa, fix mínimo y **cómo se habría detectado antes**. Esa última columna es la que vale.
22. **Diagnóstico.** Haz que `CHAOS=error` devuelva `500` **con** las cabeceras de CORS y después **sin** ellas. Entra a la aplicación Angular con cada variante y anota qué mensaje ve el usuario en cada caso. Explica por qué el orden de los middleware decide cuál de los dos ve.
23. Compara el arranque de Lumen con el de Laravel leyendo los dos `bootstrap/app.php` (el de Laravel lo tienes en la documentación oficial). Escribe una tabla de qué hace cada uno y qué se paga por cada línea de más.
24. **Diagnóstico.** Reproduce el bug 3 con un método de verdad: añade un `scopeExpired()` al modelo, invócalo como `Template::expired()`, y demuestra con `method_exists()` que no existe. Después encuentra en `vendor/` la línea exacta de `__call` que lo hace funcionar.
25. Mide cuánto tarda `/health` en frío y en caliente, veinte peticiones de cada. Explica la diferencia con el modelo shared-nothing en la mano, y di qué parte del arranque se paga en cada petición.
26. **Diagnóstico adversarial.** Un compañero propone encender `withFacades()` *"porque así el código se parece a Laravel y los nuevos entran más rápido"*. Escribe la respuesta en dos párrafos: qué gana realmente, qué se rompe, y por qué el argumento del onboarding es exactamente el que hay que discutir en be07 y no aquí.
27. Añade el endpoint `GET /templates` con datos fijos y comprueba con el `smoke.sh` cuántas comprobaciones nuevas pasan. Si no pasa ninguna, averigua por qué — la respuesta está en `CONTRACT.md` y es más interesante que el ejercicio.

**🔴 Muy difícil (28–32)**

28. **Diagnóstico.** Repite el experimento de §5.9 **cinco veces** con cinco tareas distintas y construye una tabla: tarea, qué falló, si el fallo era ruidoso o silencioso, y cuántos minutos habrías perdido. Después calcula el coste de un mes de onboarding con esa tabla. Ese número es un insumo directo de la opción 1 del *assessment* de be07 — anótalo también en `bea-10`.
29. Escribe la nota técnica de tres párrafos que habría que adjuntar al ticket SEC-2291: qué pide, qué implica de verdad —de Lumen 5.8.13 a 9.0.0 son cuatro versiones mayores—, y las tres opciones con su orden de magnitud. No estimes en horas si no puedes defenderlas; estima en semanas y di de qué depende.
30. **Diagnóstico.** Encuentra en `vendor/` el archivo donde `Facade::__callStatic` resuelve el servicio, y escribe la cadena completa desde `Cache::get('x')` hasta el método que de verdad se ejecuta, nombrando cada archivo y cada línea. Es tedioso a propósito: es lo que hay que hacer una vez para no volver a hacerlo nunca.
31. Diseña y ejecuta una prueba que demuestre que **el estado no sobrevive entre peticiones**: escribe en una variable estática en una petición y trata de leerla en la siguiente. Después hazlo con `Cache` (con driver de archivo) y explica la diferencia. Cierra con la pregunta difícil: ¿qué del frontend de CertCore —que sí mantiene estado en `BehaviorSubject`— depende de que el servidor **no** lo mantenga?
32. **Diagnóstico adversarial.** Dado sólo el `composer.lock`, reconstruye la historia de actualizaciones de este backend y fecha cada una. Después responde lo difícil: **¿qué señal, en 2019, tendría que haber disparado la subida a Lumen 6?** Y la más difícil: ¿existía esa señal, o el sistema simplemente no tenía a nadie a quien avisarle?

**🔥 Opcionales**

- 🔥 Reescribe `/health` usando los facades encendidos y compáralo con la versión del contenedor. Cuenta caracteres, cuenta capas, y decide cuál conservarías en un equipo con rotación de dieciocho meses.
- 🔥 Levanta el mismo `/health` en PHP puro, sin framework, en un solo archivo. Mide la diferencia de tiempo de respuesta y de líneas. Después di qué pierdes — la lista honesta es larga.
- 🔥 Intenta `composer update` para subir a Lumen 6. Pega el error de resolución de dependencias entero y tradúcelo a español de negocio, en tres líneas, para alguien que no sabe qué es Composer.

---

## 📚 8. Referencias

**Documentación oficial**
- https://lumen.laravel.com/docs/5.8 — la documentación **de la versión exacta** que corre aquí. Cambia el `5.8` de la URL por cualquier otra cosa y estarás leyendo otro producto: es el error más caro de esta fase.
- https://packagist.org/packages/laravel/lumen-framework — el historial de versiones con fechas. Es la fuente de la tabla de §4, y se puede consultar por versión concreta para ver su restricción de `php`.
- https://www.php.net/manual/es/features.commandline.webserver.php — el servidor embebido, incluido `PHP_CLI_SERVER_WORKERS` (disponible desde PHP 7.4.0) y la advertencia de que el proceso es único y de un solo hilo.
- https://www.php.net/supported-versions.php — el calendario de soporte de PHP. La fila de 7.4 dice **28 de noviembre de 2022**, y es la premisa del track entero.
- https://laravel.com/docs/5.8/facades — los facades explicados por la documentación contemporánea. ⚠️ Es de **Laravel**: todo lo que dice aplica aquí sólo si `withFacades()` está encendido, y en CertCore no lo está.

**Libros / artículos de referencia**
- *Working Effectively with Legacy Code* (Michael Feathers, Prentice Hall, 2004), capítulos 1 y 6 — la distinción entre código legado y código sin pruebas, y qué hacer cuando no puedes ejecutar lo que quieres entender. Escrito veinte años antes que esta fase y sigue siendo el mejor marco para ella.

**Video / apoyo**
- https://www.youtube.com/results?search_query=php+shared+nothing+request+lifecycle — el modelo de ejecución, que es lo que más desorienta a quien viene de un backend persistente. Busca charlas que expliquen el ciclo completo de una petición, no tutoriales de framework.

**Orden de lectura sugerido:** la página de versiones de PHP **antes** de nada, para tener el 28/11/2022 en la cabeza → [`bea-01`](bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md) **mientras** lees el primer controlador → la documentación de Lumen 5.8 **sólo cuando la necesites**, y entrando por el índice → [`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md) **después** del primer `grep` vacío, no antes: el apéndice se entiende mucho mejor con la frustración reciente.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. Y con este stack hay dos advertencias que no son opcionales: **casi toda la documentación de PHP en línea asume PHP 8**, y **casi todo lo que encuentres de Lumen está escrito para Laravel**. Comprueba siempre la versión en la URL, y verifica en tu propio contenedor.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Tienes un backend vivo en el puerto 3000, con un endpoint de salud, el inyector de caos completo, y un `smoke.sh` que dice `4/24` sin que nadie lo haya tocado. Tienes también un documento —`FALSA-FAMILIARIDAD.md`— que vale más que el código: cuatro bugs reproducidos, y la respuesta de un asistente pegada con tus anotaciones encima.

Y tienes una sospecha que en **be02** se vuelve una medición. Al buscar cómo resuelve el cacheo el código heredado (ejercicio 16) encontraste más de una forma. No es descuido: es que cada persona que pasó por aquí venía de otro framework y resolvió con los reflejos que traía. La próxima fase clasifica el código **por la procedencia de quien lo escribió**, lo cuenta, y convierte esa sospecha en el inventario que el *assessment* de be07 va a costear.

> **La señal de que quedó bien:** *"le pregunté a un asistente cómo se hacía algo en Lumen, ejecuté su respuesta sin creérmela, y ahora sé exactamente en qué me iba a mentir — y por qué."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-01-lumen-y-la-familiaridad-falsa \
>   -m "be01 cerrada: /health vivo en el 3000 con Lumen 5.8.13 sobre PHP 7.4.33;
> inyector de caos reimplementado con los seis modos; smoke.sh en 4/24 sin tocarlo;
> los cuatro bugs de familiaridad falsa documentados en FALSA-FAMILIARIDAD.md;
> experimento de los diez minutos hecho"
> ```
>
> Los commits de esta fase llevan `be01: …` y los de ejercicio `be01 ej28: …`. El namespace `be-fase-*` es propio del track; la convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥.
>
> Esta fase estrena el par `-roto`/`-fix` del track BE: los dos incidentes que reserva abajo salen de este tag, y sus ramas se llaman `incidente/be-01` e `incidente/be-02`. Y estrena también una comprobación que vas a repetir en las seis fases que quedan: `git diff fase-10-certificados-vigencia..HEAD -- src/` **tiene que devolver vacío**. El día que devuelva algo, el track se rompió.

---

## 📌 Pendientes sugeridos

- **`withFacades()` queda apagado y no hay un documento que diga por qué.** La decisión se explica en §5.3 y en el ejercicio 26, pero vive dentro de una fase y no en el código. → **`bea-10`**, como la primera entrada del mapa de deuda: *deuda que no se paga, con su razón escrita*.
- **`tools/probe.php` usa `eval()`.** Es correcto para un laboratorio que no se despliega, y es exactamente la clase de archivo que alguien copia a `app/` un martes. → **`bea-08`**, en la sección de reducción de superficie, y un 🔥 de be06 si se decide excluirlo del artefacto de despliegue.
- **El modo `timeout` se comporta distinto que en el mock** y el ajuste es `PHP_CLI_SERVER_WORKERS`. Los enunciados de la Fase 3 siguen valiendo, pero la explicación de *por qué* pertenece a la conversación de concurrencia que el track todavía no ha tenido. → **be07**, como número de la columna de comparación, y nota en `bea-02`.
- **La versión de PHPUnit sigue sin fijar** (⚠️ de la propuesta §5.5). No bloqueó esta fase porque aquí no hay pruebas, pero **bloquea be06**. → **Cerrar antes del chat de be06**, verificándola contra la línea de Lumen 5.8 y no de memoria.
- **`GET /templates` con datos fijos en una clausura** es 💸 declarada y se paga en be03. Si al llegar allí sigue viva, la fase está mal cerrada.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| **be-01** | "El caché no se limpia nunca y no encuentro dónde se llena" | Facades y resolución dinámica | 🟠 |
| **be-02** | "Copié la solución de internet y el servidor dejó de arrancar" | Familiaridad falsa · bootstrap | 🟡 |
MDEOF
wc -l be01-lumen-y-la-familiaridad-falsa.md

# --- 2026-09-11T18:00:07 · Write bea-02 appendix
cat > bea-02-receta-de-imagen-y-compose.md <<'MDEOF'
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
MDEOF
wc -l bea-02-receta-de-imagen-y-compose.md

# --- 2026-09-11T18:02:19 · Write bea-01 appendix
cat > bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md <<'MDEOF'
# 📎 Apéndice bea-01 — PHP 7.4 y Lumen para quien no escribe PHP

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **4 horas**
> Usado por: **be01** principalmente, y de consulta en todas las demás · Versiones cubiertas: PHP **7.4.33**, Lumen **5.8.13**, Composer 2
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido.** Se entra por el índice buscando algo concreto —*"¿qué diablos es `??`"*, *"¿por qué este array se comporta raro?"*— y se sale. Resuelve un problema y sólo uno: **que un senior de otro lenguaje pueda leer y escribir `certcore-api` sin haber escrito PHP nunca, o habiéndolo escrito en 2012 y con rencor.**

**Qué queda fuera:** todo lo de PHP 8 salvo notas 🔥 —aquí el runtime es 7.4 a propósito—; **Laravel**, que se nombra constantemente como contraste pero no se enseña; **los facades y el contenedor**, que tienen apéndice propio en [`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md); y **Eloquent**, que es [`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md). Si lo que buscas es magia que `grep` no encuentra, estás en el apéndice equivocado: ve a `bea-03`.

---

## Índice

- [Lo que de verdad te va a desorientar: shared-nothing](#lo-que-de-verdad-te-va-a-desorientar-shared-nothing)
- [Composer, PSR-4 y el autoload](#composer-psr-4-y-el-autoload)
- [Tipado gradual y `declare(strict_types=1)`](#tipado-gradual-y-declarestrict_types1)
- [Los arrays, que son dos cosas a la vez](#los-arrays-que-son-dos-cosas-a-la-vez)
- [El puñado de sintaxis que hay que reconocer](#el-puñado-de-sintaxis-que-hay-que-reconocer)
- [Errores y excepciones, que no son lo mismo](#errores-y-excepciones-que-no-son-lo-mismo)
- [El ciclo de vida de una petición en Lumen](#el-ciclo-de-vida-de-una-petición-en-lumen)
- [Cómo se lee un stack trace de PHP](#cómo-se-lee-un-stack-trace-de-php)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-9)

---

## Lo que de verdad te va a desorientar: shared-nothing

La sintaxis de PHP se aprende en una tarde. El modelo de ejecución, no — y es lo único de este apéndice que cambia cómo piensas.

Tu modelo mental, vengas de Node, Java, Go o .NET, es un proceso que arranca una vez, se queda vivo y atiende peticiones sobre un estado compartido. **PHP no es eso.** Cada petición arranca un intérprete limpio, incluye los archivos que necesita, construye todo desde cero, responde, y **se muere entera**. No sobrevive nada: ni variables globales, ni `static`, ni conexiones, ni cachés en memoria.

```php
<?php
// Una variable estática dentro de una función. En cualquier backend persistente
// esto sería un contador. Aquí devuelve 1 en TODAS las peticiones.
function counter(): int
{
    static $count = 0;
    $count++;

    return $count;
}
```

Las consecuencias, en orden de utilidad:

- **Una fuga de memoria casi no se puede sostener.** El proceso se muere en cada petición y se lleva la fuga con él. PHP perdona una barbaridad, y parte de que CertCore lleve ocho años en pie sin que nadie lo mire se explica exactamente por ahí.
- **El estado compartido vive fuera del proceso** o no vive: base de datos, caché, sistema de archivos. Si quieres algo entre dos peticiones, lo escribes en algún sitio.
- **Arrancar cuesta en cada petición.** Autoload, configuración, contenedor: todo se paga otra vez. Por eso existe Lumen, y por eso la comparación de rendimiento con un backend persistente nunca es una comparación justa en ninguno de los dos sentidos.
- **La concurrencia es el número de procesos.** Una petición lenta no es una petición lenta: es un trabajador menos. Esto es lo que hace que `CHAOS=timeout` se comporte distinto aquí que en el mock de Node, y está desarrollado en be01 §5.5.

> 🧠 **En PHP no hay servidor: hay un guion que se ejecuta entero, muchas veces por segundo.** Casi todo lo raro que vas a ver se explica con esa frase.

---

## Composer, PSR-4 y el autoload

Composer es npm. Mismo papel, casi mismo vocabulario: `composer.json` es el manifiesto, `composer.lock` fija las versiones exactas, `vendor/` es `node_modules`, `composer install` respeta el lock y `composer update` lo reescribe.

```bash
docker compose exec api composer install            # ✍️ instala lo del lock
docker compose exec api composer show               # 👁️ qué hay instalado
docker compose exec api composer show laravel/lumen-framework   # 👁️ una sola
docker compose exec api composer dump-autoload      # ✍️ regenera el mapa de clases
```

Lo que no tiene equivalente cómodo es **PSR-4**, que es la convención que hace que las clases se carguen solas. El trato es de una línea:

```json
"autoload": { "psr-4": { "App\\": "app/" } }
```

Significa: *el namespace `App\` corresponde al directorio `app/`, y a partir de ahí namespace y ruta son lo mismo*. Así que `App\Http\Middleware\ChaosMiddleware` **tiene que** vivir en `app/Http/Middleware/ChaosMiddleware.php`. Un archivo, una clase, mismo nombre.

Y aquí está el error que te va a pasar una vez: **si mueves un archivo y no cuadra el namespace, el error no dice "namespace incorrecto"**, dice `Class 'App\Foo\Bar' not found`, que es el mismo mensaje que da una clase que no existe. Cuando lo veas, comprueba en este orden: (1) que el archivo esté donde dice el namespace, (2) que la clase se llame igual que el archivo, (3) `composer dump-autoload`.

---

## Tipado gradual y `declare(strict_types=1)`

PHP 7.4 tiene tipos, y son opcionales. Puedes declarar parámetros, retornos y —desde 7.4— **propiedades**:

```php
<?php

declare(strict_types=1);   // ← esta línea, y qué hace, abajo

namespace App\Support;

class TemplateResolver
{
    /** Propiedad tipada: es novedad de PHP 7.4 y el código de 2016 no la usa. */
    private string $defaultTemplateId;

    /** @var string[] Los arrays se tipan en el docblock, no en la firma. */
    private array $knownIds;

    public function __construct(string $defaultTemplateId, array $knownIds)
    {
        $this->defaultTemplateId = $defaultTemplateId;
        $this->knownIds = $knownIds;
    }

    /** El `?` significa "o null", igual que en TypeScript con strictNullChecks. */
    public function resolve(?string $templateId): string
    {
        // ?? es el operador de coalescencia nula. Devuelve el derecho si el
        // izquierdo es null O NO EXISTE — y esa segunda parte no tiene
        // equivalente exacto en TypeScript.
        return $templateId ?? $this->defaultTemplateId;
    }
}
```

**`declare(strict_types=1)` es la línea que más se parece a `strict: true` del track base**, y hace exactamente una cosa: sin ella, PHP *convierte* los argumentos al tipo declarado —le pasas `"5"` a un `int $x` y recibe `5`—; con ella, **lanza `TypeError`**. Siempre va en la primera línea del archivo, se aplica archivo por archivo, y sólo afecta a las llamadas escritas *en ese archivo*.

> ⚠️ El código heredado de CertCore **no la tiene**. El código que escribes tú en este track **sí**. Esa diferencia es una de las huellas que vas a contar en be02, y es la razón por la que un `"2"` que llega de una consulta puede colarse durante ocho años como si fuera un `2`.

🔥 **En PHP 8 esto cambia** de varias formas relevantes —tipos union (`int|string`), `match`, promoción de propiedades en el constructor, enums—, y nada de eso existe aquí. Cuando veas un ejemplo con `match(...)`, estás leyendo documentación de otro runtime.

---

## Los arrays, que son dos cosas a la vez

Ésta es la fuente de la mitad de los bugs sutiles de PHP, y la mitad menos evidente.

**En PHP hay un solo tipo `array`, y es a la vez lista y mapa.** No hay `Array` y `Map`: hay una tabla ordenada de claves, donde las claves pueden ser enteros o cadenas, y una "lista" no es más que una tabla cuyas claves son `0, 1, 2, …`.

```php
$list = ['a', 'b', 'c'];              // claves 0, 1, 2
$map  = ['id' => 7, 'name' => 'Ana']; // claves 'id', 'name'
// Los dos son `array`. gettype() devuelve "array" para ambos.
```

Por qué importa, en tres consecuencias que te van a morder:

**1. `json_encode` decide el JSON según las claves.** Un array con claves `0..n-1` sale como `[...]`; cualquier otra cosa sale como `{...}`.

```php
json_encode([1, 2, 3]);                  // "[1,2,3]"
json_encode([0 => 1, 2 => 3]);           // '{"0":1,"2":3}'  ← ¡objeto!
```

Y de ahí sale un bug clásico y muy caro: filtras una lista con `array_filter()`, que **conserva las claves originales**, se te va el `1` de en medio, y tu endpoint que siempre devolvía un array empieza a devolver un objeto. El frontend hace `*ngFor` sobre él y la pantalla se queda en blanco. **El fix es `array_values()`**, y es la razón por la que aparece en el `ChaosMiddleware` de be01.

```php
$actives = array_values(array_filter($templates, function ($t) {
    return $t['validUntil'] === null;
}));   // array_values() reindexa. Sin él, esto puede salir como objeto.
```

**2. Comprobar si algo es lista es incómodo en 7.4.** No hay `array_is_list()` (llegó en PHP 8.1 🔥), así que se hace a mano: `array_keys($a) === range(0, count($a) - 1)`.

**3. `isset` y `array_key_exists` no son lo mismo.** `isset($a['k'])` es `false` si la clave existe pero vale `null`. Cuando distingues "campo ausente" de "campo con valor nulo" —que es medio track base— la diferencia deja de ser académica:

```php
$row = ['validUntil' => null];
isset($row['validUntil']);              // false  ← miente sobre la existencia
array_key_exists('validUntil', $row);   // true   ← la verdad
```

> 🧠 **`null`, `undefined` y "campo ausente" eran tres cosas distintas en el track base (Fase 9). En PHP siguen siendo tres, y la herramienta para distinguirlas es `array_key_exists`, no `isset`.**

---

## El puñado de sintaxis que hay que reconocer

No es un curso de PHP: es la lista de cosas que te van a hacer parar la lectura.

| Escrito así | Qué es |
|---|---|
| `$var` | Toda variable lleva `$`. También las propiedades: `$this->name` |
| `->` | Acceso a miembro de objeto. El `.` de otros lenguajes |
| `::` | Acceso estático o a constante: `Template::active()`, `self::KNOWN_FAULTS` |
| `.` | **Concatenación de cadenas.** El `+` de JavaScript. Sumar cadenas con `+` es un error |
| `'simples'` vs `"dobles"` | Las dobles interpolan variables (`"Hola $name"`), las simples no. Prefiere simples salvo que interpoles |
| `??` | Coalescencia nula, y además **silencia el aviso de índice inexistente** |
| `?->` | 🔥 No existe en 7.4. Es de PHP 8 |
| `=>` | Separa clave y valor en arrays, y **no** es una función flecha |
| `fn($x) => $x * 2` | Función flecha de PHP 7.4. Captura el ámbito automáticamente y es de una sola expresión |
| `function ($x) use ($y) {}` | Clausura clásica. **`use` es obligatorio** para capturar variables de fuera |
| `[$a, $b] = $pair` | Desestructuración, igual que en JavaScript |
| `...$args` | Operador de propagación, igual |
| `@` delante de algo | Silenciador de errores. Si lo ves en código heredado, apúntalo: es deuda casi siempre |
| `<?php` sin `?>` al final | Correcto y deliberado: cerrar la etiqueta permite que se cuele un espacio en la salida |

---

## Errores y excepciones, que no son lo mismo

Éste es el rincón donde PHP se comporta distinto a todo lo demás, y donde más tiempo se pierde.

PHP tiene **dos jerarquías** que no comparten raíz: `Exception` (lo que esperas) y `Error` (lo que en otros lenguajes serían errores de ejecución fatales: `TypeError`, `DivisionByZeroError`, `Error` a secas por llamar a un método inexistente). Las dos implementan `Throwable`, y **`catch (Exception $e)` no atrapa un `Error`**.

```php
try {
    $result = $noExiste->metodo();
} catch (Exception $e) {
    // NO entra aquí: un método sobre null lanza Error, no Exception.
} catch (Throwable $e) {
    // Aquí sí. Cuando quieras atrapar "cualquier cosa", es Throwable.
}
```

Y encima existen los **avisos** (`Warning`, `Notice`, `Deprecated`), que no son ninguna de las dos cosas: no interrumpen la ejecución, se escriben en el log, y el programa sigue con un valor probablemente equivocado.

```php
$row = [];
echo $row['nope'];   // Warning: Undefined array key "nope" ... y sigue, con null
```

> 🧭 **La regla práctica:** en PHP, que no haya excepción no significa que no haya pasado nada. Antes de dar por bueno un comportamiento, **mira el log**. En el track BE, `docker compose logs -f api` es lo que la consola del navegador era en el track base.

🔥 En PHP 8 muchos de estos avisos se convirtieron en errores de verdad, lo que hace el lenguaje bastante más honesto — y es una de las razones por las que subir de versión no es gratis: código que "funcionaba" empieza a reventar.

---

## El ciclo de vida de una petición en Lumen

Siete pasos, y todos ocurren **de nuevo** en cada petición:

1. El servidor web entrega la petición a `public/index.php`, el único punto de entrada.
2. `bootstrap/app.php` construye la aplicación: carga el `.env`, crea el contenedor, registra la configuración que le pidan, declara los middleware y carga las rutas.
3. El *router* empareja método y URL con una ruta.
4. **Middleware global**, en el orden del array, hacia dentro.
5. El controlador (o la clausura) se ejecuta. Sus dependencias las resuelve el contenedor por el tipo de los parámetros.
6. **Middleware, de vuelta hacia fuera**, en orden inverso. Aquí es donde se modifica la respuesta.
7. Se emite la respuesta y **el proceso muere**.

El paso 6 es el que cuesta un rato: un middleware que toca la petición corre en el orden que lees, y uno que toca la respuesta corre al revés. Si alguna vez dudas, no lo deduzcas — pon un `error_log(__CLASS__)` en cada uno y mira el log. Treinta segundos contra veinte minutos de teoría.

`bootstrap/app.php` está comentado línea a línea en **be01 §5.3**, y es el archivo que hay que leer entero antes que cualquier controlador.

---

## Cómo se lee un stack trace de PHP

```
PHP Fatal error:  Uncaught Error: Call to undefined method App\Models\Template::activo()
in /app/server/app/Http/Controllers/LegacyTemplateController.php:31
Stack trace:
#0 /app/server/vendor/illuminate/routing/Controller.php(54): App\Http\Controllers\LegacyTemplateController->index()
#1 /app/server/vendor/laravel/lumen-framework/src/Routing/Pipeline.php(30): Illuminate\Routing\...
#2 {main}
  thrown in /app/server/app/Http/Controllers/LegacyTemplateController.php on line 31
```

Cuatro reglas para leerlo rápido:

1. **La primera línea es el qué; la línea `in ...` es el dónde.** `LegacyTemplateController.php:31`. Empieza siempre ahí y no por el `#0`.
2. **La traza se lee de arriba abajo, de lo más reciente a lo más antiguo.** `#0` es quien llamó al que falló; `{main}` es el principio del mundo.
3. **Todo lo que esté bajo `vendor/` es ruido, hasta que no lo es.** Salta esas líneas en la primera pasada. Cuando el bug sea de los de `bea-03`, serán justo esas líneas las que te digan qué magia se ejecutó.
4. **`Uncaught Error` y `Uncaught Exception` son familias distintas** (ver arriba), y esa palabra te dice qué `catch` habría servido.

Y el detalle que te va a hacer perder tiempo exactamente una vez: **la traza puede no llegar al navegador**. Según cómo esté el manejador de excepciones, `curl` te devuelve un `500` sin cuerpo o una página HTML inútil, y el texto de arriba está en el log del contenedor. Terminal aparte, siempre.

---

## 🧭 Cuándo usar qué

| Quieres… | Usa | Ojo con |
|---|---|---|
| Saber si una clave existe, aunque valga `null` | `array_key_exists($k, $a)` | `isset()` devuelve `false` con valor `null` |
| Un valor por defecto si falta o es nulo | `$a['k'] ?? 'defecto'` | Silencia el aviso de clave inexistente: también oculta erratas |
| Que un endpoint devuelva `[...]` y no `{...}` | `array_values(...)` tras filtrar | `array_filter` conserva las claves |
| Atrapar cualquier fallo | `catch (Throwable $e)` | `catch (Exception $e)` no atrapa `TypeError` |
| Comparar dos valores | `===` y `!==` | `==` compara con conversión y da sorpresas |
| Recorrer un array | `foreach ($a as $k => $v)` | `for` con índice se rompe con claves no numéricas |
| Una función de una expresión | `fn($x) => ...` (7.4) | No admite cuerpo de varias líneas |
| Una clausura que usa variables de fuera | `function ($x) use ($y) {}` | Sin `use`, `$y` no existe dentro |
| Ver qué es realmente un valor | `var_dump($x)` | `print_r` no distingue `"2"` de `2` |
| Que un tipo equivocado explote | `declare(strict_types=1)` | Sólo afecta a las llamadas de ESE archivo |

---

## ⚠️ Advertencias

**Casi toda la documentación de PHP que encuentres asume PHP 8**, y casi todo lo de Lumen está escrito para Laravel. Cita siempre la documentación con la versión en la URL (`php.net/manual/es/...` marca desde qué versión existe cada cosa; `lumen.laravel.com/docs/5.8`), y **verifica en tu propio contenedor**: `docker compose exec api php -r 'var_dump(PHP_VERSION);'` no miente.

**Y la advertencia que define el track:** un asistente te va a contestar en Laravel, con total confianza y con código que casi funciona. No es ignorancia, es distribución de la evidencia: hay cien veces más Laravel escrito que Lumen. El protocolo para convivir con eso —y para medirlo— está en **be01 §5.9**, y es el mejor material del track.

---

## 📚 Referencias

- https://www.php.net/manual/es/langref.php — la referencia del lenguaje, en español, con la versión mínima anotada en cada función.
- https://www.php.net/manual/es/language.types.array.php — los arrays. Léete la sección entera una vez; te ahorra media docena de bugs.
- https://www.php.net/manual/es/language.errors.php7.php — la jerarquía de `Error` y `Exception`, que es lo que no se parece a nada.
- https://www.php.net/manual/es/migration74.new-features.php — qué trajo 7.4: propiedades tipadas, funciones flecha, `??=`. Es el techo de este sistema.
- https://www.php.net/supported-versions.php — el calendario de soporte. 7.4 terminó el **28 de noviembre de 2022**.
- https://getcomposer.org/doc/01-basic-usage.md — Composer, para quien ya sabe npm: se lee en veinte minutos.
- https://www.php-fig.org/psr/psr-4/ — PSR-4, que es la regla que hace que las clases se carguen solas.
- https://lumen.laravel.com/docs/5.8 — la documentación de la versión exacta que corre en CertCore.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos. Y con php.net en particular, **mira siempre la nota de versión** que acompaña a cada función: la mitad de los ejemplos útiles que encontrarás usan algo que no existe en 7.4.

---

## 🧪 Ejercicios (9)

1. Ejecuta `docker compose exec api php -v` y `php -m`. Anota la versión exacta y comprueba que `pdo_pgsql` está en la lista de módulos.
2. Escribe la función `counter()` de la primera sección en una ruta y pídela cinco veces. Pega la salida. Después explica en dos líneas qué habría pasado en Node.
3. **Diagnóstico.** Crea un array de las tres plantillas, filtra con `array_filter` las que tengan `validUntil === null`, y devuélvelo desde una ruta. Mira el JSON. Después añade `array_values()` y vuelve a mirar. Explica qué le pasaría al `*ngFor` del frontend con la primera versión.
4. Demuestra con `var_dump` la diferencia entre `isset($a['k'])` y `array_key_exists('k', $a)` cuando el valor es `null`. Relaciónalo con la Fase 9 del track base en una frase.
5. **Diagnóstico.** Escribe una función con `int $version` y llámala con `"2"`, primero sin `declare(strict_types=1)` y después con él. Pega los dos resultados. ¿Cuál de los dos comportamientos tiene el código heredado de CertCore?
6. Provoca los tres tipos de fallo —un `Warning` por clave inexistente, una `Exception` lanzada a mano, y un `Error` por llamar a un método inexistente— y comprueba cuáles atrapa `catch (Exception $e)` y cuáles `catch (Throwable $e)`. Haz una tabla de tres filas.
7. **Diagnóstico.** Mueve una clase de `app/Support/` a `app/Http/` sin cambiar su namespace y pide una ruta que la use. Pega el error literal. ¿Menciona en algún sitio que el problema es el namespace?
8. Toma un stack trace real de tu laboratorio (provoca uno) y anótalo a mano: dónde está el qué, dónde el dónde, qué líneas son ruido de `vendor/`, y cuál es el primer archivo tuyo que aparece.
9. **Diagnóstico.** Busca en el código heredado de `server/app/` tres cosas: un archivo sin `declare(strict_types=1)`, un `@` silenciando algo, y un `array_filter` sin `array_values`. Para cada uno escribe una línea de qué podría salir mal. Guarda la lista: es materia prima de be02.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y no deja archivos versionados: el código que explica lo escriben las fases, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be01: …`, `be03: …`). Si haces mediciones que quieras conservar, van en el mensaje de un tag anotado de ejercicio (`ej/bea-01/5`). La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
MDEOF
wc -l bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md

# --- 2026-09-11T18:04:19 · Write bea-03 appendix
cat > bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md <<'MDEOF'
# 📎 Apéndice bea-03 — El contenedor, los facades y por qué `grep` falla

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **4 horas**
> Usado por: **be01** ⭐, **be02** · Versiones cubiertas: Lumen **5.8.13** (componentes Illuminate 5.8)
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido.** Se entra por el índice con un síntoma —*"el método no existe"*, *"la clase no existe"*, *"el método existe pero hace otra cosa"*— y se sale con una técnica. Resuelve un problema y sólo uno: **poder investigar una capa de magia cuando la herramienta que usas siempre —buscar el nombre en el código— deja de encontrar nada.**

🧭 **El ángulo, que es lo que hace único a este apéndice en todo el repositorio.** Los dos cursos de Angular están construidos sobre buscar en el código: `grep`, "buscar en todos los archivos", `git log -S`. Aquí hay una capa donde **buscar no sirve**, y moverse en ella es una habilidad transferible a cualquier framework con resolución dinámica, en cualquier lenguaje. No es un apéndice sobre Lumen: es un apéndice sobre qué haces cuando tu herramienta principal se queda muda.

**Qué queda fuera:** el diseño de contenedores de inyección en abstracto —hay bibliografía mejor y no es el oficio de este track—; la sintaxis de PHP, que es [`bea-01`](bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md); y **Eloquent**, que comparte la magia de `__get` y `__call` pero tiene apéndice propio en [`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md) — aquí se explica el mecanismo, allí lo que significa para tus consultas.

---

## Índice

- [Los tres métodos mágicos, en veinte líneas](#los-tres-métodos-mágicos-en-veinte-líneas)
- [Qué es un facade, de verdad](#qué-es-un-facade-de-verdad)
- [`$app->withFacades()`, apagado por defecto](#appwithfacades-apagado-por-defecto)
- [El contenedor: qué hay dentro y cómo se mira](#el-contenedor-qué-hay-dentro-y-cómo-se-mira)
- [*Service locator* frente a inyección por constructor](#service-locator-frente-a-inyección-por-constructor)
- [Qué quitó Lumen de Laravel](#qué-quitó-lumen-de-laravel)
- [El método de búsqueda que sí funciona](#el-método-de-búsqueda-que-sí-funciona)
- [🧭 Cuándo usar qué: la tabla por síntoma](#-cuándo-usar-qué-la-tabla-por-síntoma)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-10)

---

## Los tres métodos mágicos, en veinte líneas

Toda la magia de este framework —y de media docena más— sale de tres métodos que PHP llama **cuando no encuentra lo que pediste**. Ésa es la clave entera: no se invocan, se invocan *en tu lugar*.

```php
<?php

class Magic
{
    /** Se llama cuando pides una PROPIEDAD que no existe. */
    public function __get(string $name)
    {
        return "no existe ninguna propiedad \$$name, y aun así esto responde";
    }

    /** Se llama cuando invocas un MÉTODO de instancia que no existe. */
    public function __call(string $method, array $args)
    {
        return "no existe el método $method(), y aun así esto responde";
    }

    /** Se llama cuando invocas un método ESTÁTICO que no existe. */
    public static function __callStatic(string $method, array $args)
    {
        return "no existe Magic::$method(), y aun así esto responde";
    }
}

$m = new Magic();
echo $m->loQueSea;        // __get
echo $m->loQueSea();      // __call
echo Magic::loQueSea();   // __callStatic
```

> 🧠 **Los tres se disparan por ausencia.** Por eso `grep` falla: estás buscando algo cuya única razón de existir es que **no está escrito en ninguna parte**.

Con esos tres en la cabeza, todo lo demás de este apéndice es aplicación:

| Magia | Quién la usa en CertCore | Síntoma que produce |
|---|---|---|
| `__callStatic` | Los facades: `Cache::get()`, `DB::table()` | Buscas `function get` y no hay nada |
| `__call` | Los *scopes* de Eloquent: `Template::active()` | Buscas `function active` y no hay nada; hay `scopeActive` |
| `__get` | Los atributos de Eloquent: `$template->valid_until` | Buscas la propiedad y no existe: es una columna |

---

## Qué es un facade, de verdad

Un facade es **una clase vacía con un nombre corto que le pide un objeto al contenedor y le reenvía la llamada**. Nada más. La implementación completa cabe en la cabeza:

```php
// Lo que hay de verdad detrás de Cache::get('templates.all'), resumido:

abstract class Facade
{
    public static function __callStatic($method, $args)
    {
        // 1. El facade declara una CLAVE, no una clase.
        $instance = static::getFacadeRoot();   // → app('cache')

        // 2. Y le reenvía la llamada al objeto que el contenedor devuelva.
        return $instance->$method(...$args);
    }
}

class Cache extends Facade
{
    // La única línea propia de la clase: su clave en el contenedor.
    protected static function getFacadeAccessor() { return 'cache'; }
}
```

De ahí salen las tres consecuencias que importan:

1. **`Cache::get()` no es una llamada estática.** Es una llamada de instancia con disfraz. Por eso se puede sustituir en pruebas y por eso no hay estado global de verdad.
2. **El puente entre el nombre que ves y la clase que corre es una cadena de texto** — `'cache'` —, y las cadenas no aparecen en una búsqueda de definiciones de método.
3. **Para saber qué se ejecuta hay que preguntarle al contenedor**, no al código. Eso es todo el método de la sección de abajo.

---

## `$app->withFacades()`, apagado por defecto

En Laravel los facades vienen de fábrica. **En Lumen hay que encenderlos**, y en CertCore la línea lleva comentada desde 2016:

```php
// server/bootstrap/app.php
// $app->withFacades();
```

Esto es familiaridad falsa en estado puro, y tiene tres estados, no dos:

| Estado | Qué pasa | Cómo se detecta |
|---|---|---|
| Apagado | `Cache::get()` → `Class 'Cache' not found` | Ruidoso e inmediato |
| Encendido | Funciona como en Laravel | — |
| **Encendido a medias** | Alguien registró *algunos* alias a mano | **Unos funcionan y otros no, sin patrón visible** |

El tercero es el que arruina tardes. `withFacades()` acepta un segundo argumento con alias personalizados, y es perfectamente posible que en 2019 alguien registrara dos clases sueltas para desatascar un ticket. El resultado: `Cache::get()` funciona y `Log::info()` no, y no hay ninguna regla que lo explique salvo mirar el arranque.

```bash
# Los alias que existen AHORA MISMO, que es la única fuente fiable:
docker compose exec api php tools/probe.php "class_exists('Cache')"
docker compose exec api php tools/probe.php "class_exists('Log')"
```

> 🧭 **Antes de discutir si los facades "están o no están", ejecútalo.** En una capa dinámica, la configuración efectiva no se deduce del código: se observa.

Y la decisión de CertCore, que está declarada en be01 §5.3 y no se toca en este track: **quedan apagados**. Encenderlos hoy no arregla nada y cambia el arranque de una aplicación de ocho años cuyo código heredado ya se acostumbró a vivir sin ellos.

---

## El contenedor: qué hay dentro y cómo se mira

El contenedor es un mapa de **clave → cómo construir esto**. Las claves son cadenas cortas (`'cache'`, `'db'`, `'router'`) o nombres de clase completos.

```bash
# ¿Qué claves hay registradas?
php tools/probe.php "array_keys(app()->getBindings())"

# ¿Qué objeto sale de una clave?
php tools/probe.php "get_class(app('cache'))"
#   Illuminate\Cache\CacheManager

# ¿Es un singleton? (¿dos resoluciones dan el mismo objeto?)
php tools/probe.php "app('cache') === app('cache')"
```

Las tres formas de sacar algo del contenedor que vas a encontrar en el código heredado —y las tres significan lo mismo:

```php
$cache = app('cache');                                   // helper, por clave
$cache = $this->app->make('cache');                      // explícito
public function __construct(CacheManager $cache) { }     // por tipo, automático
```

La última es la interesante: **el contenedor resuelve por el tipo declarado del parámetro**. Si un controlador pide un `TemplateResolver` y esa clase no está registrada, el contenedor **la construye igual** mirando los tipos de *su* constructor, recursivamente. Eso es lo que hace que la inyección "funcione sola" y también lo que hace que un error de construcción aparezca tres niveles más abajo de donde lo escribiste.

---

## *Service locator* frente a inyección por constructor

Las dos formas resuelven lo mismo. Ninguna está mal. Y la diferencia entre ellas es, en be02, **una huella de procedencia**.

```php
// A — service locator. El objeto se pide donde se necesita.
class LegacyTemplateController extends BaseController
{
    public function index()
    {
        $cached = app('cache')->get('templates.all');
        // ...
    }
}

// B — inyección por constructor. Las dependencias se declaran arriba.
class TemplateController extends BaseController
{
    /** @var CacheManager */
    private $cache;

    public function __construct(CacheManager $cache)
    {
        $this->cache = $cache;
    }

    public function index()
    {
        $cached = $this->cache->get('templates.all');
    }
}
```

Lo que cambia de verdad:

- **A esconde sus dependencias.** Para saber qué necesita esa clase hay que leerla entera. B las declara en la firma: se leen en dos segundos.
- **A es más corto** y, en un controlador de tres líneas, sinceramente más cómodo. Por eso está por todas partes.
- **A no se puede sustituir en una prueba sin tocar el contenedor**; B sí, pasándole otra cosa. En be06, cuando lleguen las pruebas, esto deja de ser estético.
- **A es el reflejo de quien viene de Laravel; B, el de quien viene de Symfony.** Esa frase es media fase be02.

> 🧭 **Ninguna de las dos es el trabajo.** El trabajo es saber en cuál está escrito el archivo que vas a tocar, y escribir el fix en ésa. Es exactamente la misma regla que el track base aplica a `constructor` frente a `inject()` — otro eje, misma disciplina.

---

## Qué quitó Lumen de Laravel

La lista corta, que es la que produce bugs:

| Lo que asume el ejemplo de internet | Aquí |
|---|---|
| `Route::get()`, `Route::resource()`, grupos encadenados | **No existe** esa fachada. Es `$router->get(...)` |
| `session()`, `Session::` | **No existe.** Lumen no trae sesiones |
| Vistas Blade completas, `view()` | Recortado; el track no las usa |
| Cualquier archivo de `config/` se lee solo | Sólo los registrados con `$app->configure('x')`. El resto: **`null` en silencio** |
| `env()` en cualquier parte | Funciona, y es un bug esperando en cuanto alguien cachee la configuración |
| Todo el sistema de eventos y middleware terminable | Parcial |

Y la jerarquía de cómo duele cada ausencia, que es más útil que la lista:

1. **`Call to undefined function`** — ruidoso, inmediato, gratis.
2. **`Class 'X' not found`** — ruidoso, pero el mensaje despista: parece un problema de autoload y es un facade apagado.
3. **`null` en silencio** — el caso caro. Un `config()` de un archivo no registrado no avisa de nada, y el fallo aparece tres capas más allá con otra cara.

---

## El método de búsqueda que sí funciona

Cuatro técnicas, en el orden en que se aplican. Ninguna es leer más código.

**1. Pregúntale al objeto, no al archivo.**

```bash
php tools/probe.php "get_class(app('cache'))"
php tools/probe.php "get_class_methods(app('cache'))"
php tools/probe.php "method_exists(App\Models\Template::class, 'active')"
```

`method_exists()` devolviendo `false` sobre un método que se está ejecutando es la prueba de que estás ante magia, y no ante un error tuyo. Ahí es donde empieza la investigación de verdad.

**2. Sigue el binding, que es la única pista escrita.**

El facade declara una cadena (`getFacadeAccessor`), y alguien registró esa cadena en el contenedor. Esas dos son las únicas apariciones textuales, y **`grep` sí las encuentra** — si buscas la cadena y no el método:

```bash
# Mal: buscar el método que no existe.
grep -rn "function get" vendor/illuminate/cache/

# Bien: buscar la CLAVE.
grep -rn "'cache'" vendor/laravel/lumen-framework/src/Application.php
```

> 🧠 **La regla: en una capa dinámica se busca la cadena, no el símbolo.** Los nombres de método son ficción; las claves del contenedor son texto real.

**3. El stack trace como mapa.**

Lanza una excepción dentro del bloque sospechoso y lee la traza: `__callStatic` y `__call` aparecen en ella **con nombre, archivo y línea**. La traza te enseña el camino que el código fuente se negaba a enseñarte, porque es el camino que se recorrió de verdad.

```php
$cached = Cache::get('templates.all');
throw new RuntimeException('mapa');   // y lee el log del contenedor
```

**4. `var_dump` bien puesto, que no es trampa.**

En una capa sin tipos estáticos y con resolución en tiempo de ejecución, `var_dump($x)` contesta en un segundo preguntas que leer código no contesta en media hora. Úsalo sin culpa, y bórralo antes de commitear. `print_r` no sirve aquí: no distingue `"2"` de `2`, que suele ser justo lo que estás buscando.

---

## 🧭 Cuándo usar qué: la tabla por síntoma

| Síntoma | Primera técnica | Por qué esa |
|---|---|---|
| *"Este método no existe en ningún archivo y sin embargo se ejecuta"* | `method_exists()` + buscar `__call`/`__callStatic` en la clase padre | Confirma que es magia antes de perder tiempo buscando |
| *"`Class 'X' not found`"* | `class_exists('X')` y revisar `withFacades()` en el bootstrap | Distingue facade apagado de autoload roto |
| *"El método existe pero hace otra cosa"* | `get_class()` sobre el objeto real | El facade puede apuntar a un binding sustituido |
| *"`grep` de un nombre no devuelve nada"* | Buscar la **cadena** de la clave, no el símbolo | Las claves sí son texto literal |
| *"`config('x.y')` devuelve `null`"* | Comprobar `$app->configure('x')` en el bootstrap | Es la causa en nueve de cada diez |
| *"Funciona en un sitio y no en otro"* | `class_exists()` en los dos sitios | Casi siempre: facades encendidos a medias |
| *"No sé de dónde sale esta dependencia"* | Leer el constructor; si no hay, buscar `app(` en el cuerpo | Es la diferencia entre B y A de arriba |
| *"La traza es toda de `vendor/`"* | Buscar el primer archivo **tuyo**, de arriba abajo | Lo demás es el framework haciendo su trabajo |
| *"Quiero saber qué hay registrado"* | `array_keys(app()->getBindings())` | Es el inventario, y no está escrito en ningún sitio |

---

## ⚠️ Advertencias

**No conviertas la investigación en una refactorización.** Localizar la capa es el entregable; el fix suele ser de tres líneas y viene después. Si te encuentras "arreglando" el uso de facades mientras investigas un ticket, para: estás cambiando el arranque de un sistema de ocho años para resolver una molestia de lectura.

**`tools/probe.php` usa `eval()`.** Es correcto en una herramienta de laboratorio que no se despliega y que sólo ejecuta quien ya tiene una terminal dentro del contenedor. Es también exactamente la clase de archivo que alguien copia a `app/` un martes por la tarde. Si alguna vez lo ves fuera de `tools/`, eso es un hallazgo, y [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) explica por qué.

**Esta habilidad no es de PHP.** Es de cualquier sistema con resolución dinámica: los decoradores de Angular también son magia —el track base convive con ellos sin llamarlos así—, igual que los proxies de Spring, los *metaclass hooks* de Python o los generadores de código de Go. Lo que cambia es la técnica concreta; el método —observar el proceso en vez de leer el fuente— es el mismo en todos.

---

## 📚 Referencias

- https://www.php.net/manual/es/language.oop5.overloading.php — `__get`, `__set`, `__call` y `__callStatic` en la documentación oficial. Es la página que explica **todo** lo de este apéndice.
- https://www.php.net/manual/es/function.method-exists.php y https://www.php.net/manual/es/function.get-class.php — las dos herramientas de interrogación básicas.
- https://lumen.laravel.com/docs/5.8 — la documentación de la versión exacta, incluido el capítulo del contenedor y la lista de lo que Lumen no trae.
- https://laravel.com/docs/5.8/facades — cómo se explican los facades desde el lado de Laravel. ⚠️ Es **Laravel**: todo lo que dice vale aquí sólo con `withFacades()` encendido, y en CertCore no lo está.
- https://laravel.com/docs/5.8/container — el contenedor, documentado por Laravel 5.8. Es el mismo componente Illuminate que usa Lumen 5.8, así que aquí sí aplica casi todo.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos. Y repite el reflejo del track: **si la URL no lleva `5.8`, estás leyendo otro producto.**

---

## 🧪 Ejercicios (10)

Todos contra el código heredado real de `server/`, con el laboratorio levantado.

1. Escribe la clase `Magic` de la primera sección y comprueba los tres métodos. Después añade un `__get` que lance una excepción y lee el stack trace: ¿aparece `__get` en la traza?
2. **Diagnóstico.** Encuentra en `vendor/` el archivo donde `Facade::__callStatic` reenvía la llamada, y escribe la cadena completa desde `Cache::get('x')` hasta el método que se ejecuta de verdad, nombrando archivo y línea de cada salto.
3. Lista las claves del contenedor con `array_keys(app()->getBindings())` y elige tres. Para cada una, averigua qué clase devuelve y si es singleton.
4. **Diagnóstico.** Comprueba con `class_exists()` si los facades están encendidos en tu laboratorio. Enciéndelos, repite, y apágalos otra vez. Anota qué clases pasan a existir.
5. Busca en `server/app/` todas las formas distintas de obtener un servicio del contenedor (`app(`, `->make(`, inyección por constructor). Cuenta cuántas hay de cada una. **Guarda el número**: es una medición de be02.
6. **Diagnóstico.** Provoca un `config()` que devuelva `null` quitando su `$app->configure()`. Después escribe dos líneas sobre cómo detectarías esto en un sistema que no conoces, si nadie te dijera que puede pasar.
7. Toma un controlador heredado escrito con *service locator* y reescríbelo con inyección por constructor. Mide: líneas, dependencias visibles desde la firma, y si haría falta tocar el contenedor para probarlo. **Después revierte** y justifica en tres frases si lo harías de verdad en producción.
8. **Diagnóstico.** Usa el stack trace como mapa: lanza una excepción dentro de un método que se invoque a través de `__call` y señala, en la traza, la línea exacta donde la magia ocurre.
9. Elige un síntoma de la tabla de "cuándo usar qué", reprodúcelo a propósito en tu laboratorio, y comprueba que la técnica recomendada te lleva a la respuesta. Anota cuánto tardaste.
10. **Diagnóstico adversarial.** Alguien propone prohibir los facades en el proyecto *"porque no se pueden buscar"*. Escribe la respuesta en dos párrafos: qué problema real resuelve esa prohibición, qué cuesta aplicarla sobre ocho años de código, y cuál es la alternativa barata. Pista: la alternativa no es una regla, es una técnica — y está en este apéndice.

---

> 🏷️ **Este apéndice no lleva tag propio.** El código que explica lo escriben las fases, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be01: …`, `be02: …`). Las mediciones de los ejercicios 5 y 9 conviene guardarlas en el mensaje de un tag anotado (`ej/bea-03/5`), porque be02 y be07 las van a citar. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
MDEOF
wc -l bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md

# --- 2026-09-11T18:04:29 · Read section 5.5 exactly
sed -n '430,446p' prompts/propuesta-fases-backend.md

# --- 2026-09-11T18:04:48 · Record resolved decisions in propuesta 5.5
python3 - <<'PY'
p='prompts/propuesta-fases-backend.md'
s=open(p).read()
old = """### 5.5 Las tres ⚠️ que quedan, y por qué no bloquean

1. **La versión exacta de Lumen** que corresponde a 2016–2018, y **en qué PHP dejó
   de arrancar**. Decide el ticket que abre el track (*"seguridad exige subir a PHP
   8 y Lumen 5.x no arranca ahí"*), así que hay que fijarla antes de `be01` — pero
   no cambia ninguna fase.
2. **El estado oficial de Lumen frente a Laravel + Octane** ⚠️. Es una cita, no una
   decisión: va en `be07` y debe salir de la documentación oficial, nunca de
   memoria.
3. **Los tags exactos de la cadena** (`9.6.x`, `11.x`, `13.x` ⚠️). Solo afectan a la
   tabla de evidencia de `be04`.
"""
new = """### 5.5 Las ⚠️ que quedaban, y cómo se cerraron

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

**3. Los tags exactos de la cadena** (`9.6.x`, `11.x`, `13.x` ⚠️) — sigue abierta.
Solo afecta a la tabla de evidencia de `be04`, y se verifica contra las notas de
release oficiales al escribir esa fase.

**4. La versión de PHPUnit de la línea de Lumen 5.8** ⚠️ — sigue abierta. No la
necesita ninguna fase hasta `be06`, que es donde llegan las pruebas.
"""
assert old in s
open(p,'w').write(s.replace(old,new,1))
print('ok')
PY

# --- 2026-09-11T18:09:01 · Write be02 phase
cat > be02-estratos-por-procedencia.md <<'MDEOF'
# 🧬 Fase be02 — Estratos por procedencia: de dónde venía quien escribió esto

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Fase be02 de be07 · **8 horas**
> Depende de: **be01 cerrada** (el laboratorio levantado y `FALSA-FAMILIARIDAD.md` escrito) · Habilita: be03
> Apéndices de apoyo: [`bea-09`](bea-09-symfony-como-vara-de-medir.md) · [`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md) · Incidentes asociados: **be-03**
> Estilo de esta fase: **no se escribe casi nada.** Se lee, se clasifica y se cuenta

> 🔥 **Esta fase pertenece al track opcional de backend.** El track base se completa sin abrirla.

---

## 🎯 1. Propósito

Leer el código heredado clasificándolo **por la procedencia de quien lo escribió**, y convertir la sensación de *"esto está desordenado"* en un inventario con números.

En el track base entrenaste un ojo: *¿este archivo es de 2021 o de 2024?* — estratos **por fecha**. Aquí la misma disciplina gira sobre otro eje, porque este código no tiene dos generaciones: tiene cuatro autores que venían de sitios distintos.

> 🧠 **El dev que llega deja huella según de dónde venga.** El de Laravel asume facades, contenedor completo y `config()`. El de Symfony mete inyección por constructor y servicios donde el resto usa *service locator*. El de CakePHP arrastra Active Record y convenciones de tabla que aquí no existen. **El bug te dice de dónde venía quien lo escribió.**

---

## ✅ 2. Qué queda listo al terminar

- [ ] `ESTRATOS.md` existe y clasifica **todos** los archivos de `server/app/` con una de cuatro etiquetas: `laravel`, `symfony`, `cake`, `neutro`. Ningún archivo sin clasificar, y cada clasificación con **la evidencia** —el rasgo concreto, con archivo y línea— no con una impresión.
- [ ] Las **tres mediciones** están hechas y anotadas con el comando que las produce: cuántas formas hay de hacer una consulta, cuántas de obtener una dependencia, y cuántas de manejar un error.
- [ ] La **tabla de huellas** de §5.2 está completada con ejemplos sacados de tu propio `server/`, no copiados de esta fase.
- [ ] Sabes decir, para cualquier archivo que se abra al azar, de qué procedencia es y **en qué estilo escribirías un fix ahí**, sin dudar más de diez segundos.
- [ ] El **coste de rotación** está estimado con el método de §5.5, y el número está en `ESTRATOS.md` con sus supuestos escritos al lado. Es un insumo directo de la opción 1 del *assessment* de be07.
- [ ] No has uniformado nada. `git diff --stat` sobre `server/app/` devuelve **cero líneas cambiadas** salvo comentarios de clasificación, si decidiste ponerlos.

---

## 🚫 3. Qué NO entra todavía

- **Uniformar el código.** Ni un archivo. Esta fase mide; el track no uniforma nunca, y §5.6 explica por qué eso no es pereza.
- **PostgreSQL y Eloquent de verdad** → be03. Aquí las consultas se leen, no se ejecutan.
- **Las pruebas** → be06, que es donde la pluralidad de estilos deja de ser estética y empieza a costar.
- **El *assessment*** → be07. Esta fase le entrega el inventario y un número; la decisión es allí.
- **Juzgar a nadie.** Los cuatro autores hicieron lo razonable con lo que sabían. Si tu `ESTRATOS.md` se lee como una lista de culpables, está mal escrito.

---

## 🧠 4. Concepto mínimo

### Por qué hay estratos, y por qué son de procedencia y no de fecha

En el track base los estratos son cronológicos porque hubo **una** migración con fecha: 2024, de NgModules a standalone. Todo el equipo se movió a la vez, en la misma dirección, siguiendo la misma guía oficial. Los estratos de CertCore-frontend son geología: capas ordenadas por tiempo.

Aquí no pasó nada de eso, y la causa es de mercado:

> 🧠 **El mercado de devs PHP es enorme. El de devs Lumen no existe.**

Nadie ha trabajado "en Lumen" cinco años. Todos los que pasaron por `certcore-api` llegaron **reciclados** de otro sitio: de Laravel casi siempre, de Symfony alguna vez, de CakePHP el que llevaba más años en el oficio. Cada uno resolvió el primer ticket con los reflejos que traía puestos, nadie hizo una guía, nadie revisó a nadie — la **ausencia de revisión** es el pecado que funda este track— y el resultado no son capas: son **parcelas**.

📖 **Diccionario de traducción: de dónde venía → qué escribió aquí**

| Venía de | Su reflejo | Cómo se ve en `server/` |
|---|---|---|
| **Laravel** | *"El framework tiene un helper para eso"* | `app('cache')`, `response()`, `abort(404)`, `collect()`, arrays asociativos por todas partes |
| **Symfony** | *"Las dependencias se declaran, no se buscan"* | Inyección por constructor, interfaces, `new JsonResponse(...)`, excepciones de dominio propias |
| **CakePHP** | *"El modelo sabe guardarse solo"* | `$row->save()` dentro del controlador, columnas `created`/`modified`, un `id` autonumérico en toda tabla |
| **Ninguno** (backend genérico) | *"Esto es una función"* | Código sin framework: `PDO` a pelo, `json_encode`, `header()` |

### Los cuatro autores de `certcore-api`, y por qué se fueron

La Era 0 de [`00-historia-del-sistema.md`](00-historia-del-sistema.md) explica el origen; esto es la plantilla que lo mantuvo:

| Quién | Cuándo | De dónde venía | Qué dejó |
|---|---|---|---|
| El fundador técnico | 2016–2018 | La intranet PHP de la empresa, sin framework | El esqueleto y las decisiones que nadie revisó |
| La segunda | 2018–2019 | **Laravel** | La mitad del código actual, y la última subida de Lumen |
| El tercero | 2020–2021 | **CakePHP** | El módulo de plantillas y certificados, con sus convenciones de tabla |
| La cuarta | 2022–2024 | **Symfony** | La reescritura que se quedó a medias (be06) |

Ninguno duró más de dieciocho meses, y no es casualidad: **nadie quiere "Lumen 2018" en su CV.** Quien entra sabe que lo que aprenda aquí no se cotiza fuera, así que se va en cuanto puede — y la empresa paga el onboarding otra vez.

> 🧭 **La deuda de plantilla, enunciada para que se pueda medir:** *contratar barato y disponible sale caro cuando la formación no se amortiza nunca.* Se paga el onboarding una vez por cada persona, se pierde entera cada dieciocho meses, y **no aparece en ningún presupuesto** porque no tiene factura. La tienes que construir tú, y es §5.5.

🩻 **Esto sí funciona igual.** Antes de que parezca un desastre: los cuatro escribieron código que funciona, que lleva años en producción, y **ninguno de los tres estilos está mal**. Exactamente igual que en el track base, donde `constructor(private x: X)` e `inject(X)` son las dos correctas. La pluralidad no es el problema; el problema es que nadie la documentó, así que cada persona nueva la descubre a golpes y añade la suya.

🪞 **Tu instinto de "esto hay que homogeneizarlo" dice… y esta vez se equivoca.** Es el reflejo correcto en un equipo estable con un sistema vivo. Aquí tienes un sistema en mantenimiento, sin pruebas (hasta be06), con cuatro parcelas que funcionan y presupuesto para cero refactorizaciones. Uniformar significa tocar código que nadie entiende del todo, sin red, para ganar coherencia estética. **Lo que vas a hacer en su lugar —saber en qué parcela estás antes de escribir— cuesta ocho horas y sirve mañana.**

---

## 💻 5. Código mínimo con comentarios

### 5.1 Cuatro archivos que hacen lo mismo

Los cuatro devuelven las plantillas vigentes. Los cuatro funcionan. Léelos antes de la tabla de huellas: la gracia está en reconocerlos tú primero.

```php
<?php
// server/app/Http/Controllers/LegacyTemplateController.php   ← procedencia: LARAVEL
// Sin declare(strict_types=1). Sin tipos de retorno. Helpers por todas partes.

namespace App\Http\Controllers;

use Laravel\Lumen\Routing\Controller as BaseController;

class LegacyTemplateController extends BaseController
{
    public function index()
    {
        // Service locator: la dependencia se pide donde se usa, no se declara.
        $cached = app('cache')->get('templates.all');

        if ($cached) {
            return $cached;
        }

        $rows = Template::active()->get();

        // response() y collect() son helpers globales de Illuminate: el reflejo
        // más reconocible de quien viene de Laravel.
        return response()->json(collect($rows)->values());
    }
}
```

```php
<?php
// server/app/Http/Controllers/TemplateController.php   ← procedencia: SYMFONY

declare(strict_types=1);   // ← la primera huella, y está en la línea 3

namespace App\Http\Controllers;

use App\Domain\Template\TemplateRepositoryInterface;   // ← una interfaz. Aquí no hay más
use Illuminate\Http\JsonResponse;
use Laravel\Lumen\Routing\Controller as BaseController;

class TemplateController extends BaseController
{
    /** @var TemplateRepositoryInterface */
    private $templates;

    // Inyección por constructor, contra una interfaz, con el binding declarado
    // aparte. Es más código y es más fácil de probar; en be06 eso deja de ser
    // una opinión.
    public function __construct(TemplateRepositoryInterface $templates)
    {
        $this->templates = $templates;
    }

    public function index(): JsonResponse
    {
        // Objeto de respuesta explícito, nunca el helper. Y tipo de retorno
        // declarado en la firma: quien viene de Symfony no se lo salta nunca.
        return new JsonResponse($this->templates->findActive());
    }
}
```

```php
<?php
// server/app/Http/Controllers/CertificateController.php   ← procedencia: CAKEPHP

namespace App\Http\Controllers;

use App\Models\Certificate;
use Illuminate\Http\Request;
use Laravel\Lumen\Routing\Controller as BaseController;

class CertificateController extends BaseController
{
    public function store(Request $request)
    {
        $certificate = new Certificate();

        // El modelo se rellena y se guarda a sí mismo, dentro del controlador.
        // Active Record llevado hasta el final: no hay repositorio, no hay
        // servicio, no hay transacción. Y funciona.
        $certificate->inspection_id = $request->input('inspectionId');
        $certificate->status = 'valid';        // ← el status guardado como dato (💸 2)
        $certificate->created = date('Y-m-d H:i:s');   // ← 'created', no 'created_at'

        $certificate->save();

        return $certificate;
    }
}
```

```php
<?php
// server/app/Http/Controllers/HealthLegacyController.php   ← procedencia: NINGUNA
// El fundador técnico, 2016. Venía de la intranet, no de un framework.

namespace App\Http\Controllers;

class HealthLegacyController
{
    public function ping()
    {
        // PDO a pelo, json_encode a mano, header() a mano. Funciona igual de
        // bien y no usa nada del framework que lo aloja.
        $pdo = new \PDO(getenv('DB_DSN'), 'postgres', 'certcore');
        $row = $pdo->query('SELECT 1')->fetch();

        header('Content-Type: application/json');
        echo json_encode(['db' => $row !== false]);
        exit;   // ← y corta el ciclo de Lumen por la mitad. Ver §6.
    }
}
```

**Detalles con intención**

- **Los cuatro conviven hoy y los cuatro se ejecutan.** No son ejemplos didácticos: son el estado del sistema que vas a mantener durante cinco fases más.
- **El `exit` del cuarto no es folclore.** Cortar la ejecución salta el resto de la cadena de middleware: sin CORS, sin caos, sin manejo de errores. Es un archivo que vive fuera del framework aunque esté dentro del directorio, y en be06 va a ser el que rompa las pruebas.
- **`created` en vez de `created_at`** es la huella de CakePHP más cara del sistema: Eloquent espera `created_at`/`updated_at` y aquí la columna se llama de otra forma, así que alguien la desactivó a mano en el modelo. Esa desactivación lleva ocho años puesta.

### 5.2 La tabla de huellas, que es la herramienta de la fase

Rellénala con ejemplos de **tu** `server/`, no con los de arriba. Es el entregable que vas a consultar durante todo el track.

| Rasgo observable | Laravel | Symfony | CakePHP | Ninguno |
|---|---|---|---|---|
| `declare(strict_types=1)` | casi nunca | **siempre** | nunca | nunca |
| Tipos en firmas y retornos | a medias | **siempre** | casi nunca | nunca |
| Cómo obtiene dependencias | `app('x')`, helpers | **constructor + interfaz** | estáticamente, del modelo | `new` a pelo |
| Cómo responde | `response()->json()` o array | **`new JsonResponse`** | devuelve el modelo | `echo json_encode` |
| Dónde vive la lógica | controlador | servicio/repositorio | **modelo** | controlador |
| Cómo consulta | `Model::where()->get()` | repositorio con interfaz | `find()` y arrays de condiciones | **SQL a mano** |
| Cómo maneja errores | `abort(404)` | **excepción de dominio** | `return false` | `http_response_code()` |
| Nombres de columna | `created_at` | `created_at` | **`created`, `modified`** | lo que fuera |
| Profundidad de namespaces | `App\Http\...` | **`App\Domain\Template\...`** | `App\Models` | ninguno |
| Docblocks | escasos | **exhaustivos** | ninguno | ninguno |

> 🧭 **La regla de clasificación, y hay que aplicarla con disciplina:** *un rasgo no clasifica; tres sí.* `declare(strict_types=1)` suelto no significa nada — pudo ponerlo cualquiera. `declare` + inyección por constructor + `JsonResponse` es una firma.

### 5.3 Las tres mediciones

Medir, no suponer. Los comandos dan un número; el número es lo que be07 va a poder defender.

**Medición 1 — ¿De cuántas formas se consulta?**

```bash
cd server

# Eloquent directo desde el controlador
grep -rn "::where(\|::all()\|::find(" app/Http/Controllers/ | wc -l
# Eloquent a través de un repositorio
grep -rln "RepositoryInterface" app/ | wc -l
# Query builder sin modelo
grep -rn "DB::table(" app/ | wc -l
# SQL a mano  ← acuérdate de este número en be04
grep -rn "DB::select(\|->query(\|->prepare(" app/ | wc -l
```

**Medición 2 — ¿De cuántas formas se obtiene una dependencia?**

```bash
grep -rn "app(" app/ | wc -l                      # service locator con helper
grep -rn "->make(" app/ | wc -l                   # service locator explícito
grep -rn "public function __construct" app/ | wc -l   # inyección por constructor
grep -rn "new [A-Z]" app/ | wc -l                 # instanciación directa
```

**Medición 3 — ¿De cuántas formas se maneja un error?**

```bash
grep -rn "abort(" app/ | wc -l
grep -rn "throw new" app/ | wc -l
grep -rn "return false;\|return null;" app/Http/ | wc -l
grep -rn "http_response_code(\|header(" app/ | wc -l
grep -rn "@" app/ --include="*.php" | grep -v "@param\|@var\|@return" | wc -l   # silenciadores
```

Y la tabla que sale, que es lo que se pega en `ESTRATOS.md`:

| Qué | Formas distintas | La más usada | La que más cuesta |
|---|---|---|---|
| Consultar | | | |
| Obtener una dependencia | | | |
| Manejar un error | | | |

> 💡 **El número que más vale no es el total, es el de la última columna.** Cuatro formas de consultar es incómodo; **una sola de ellas concentrando los bugs** es accionable. En be04 vas a descubrir que la del SQL a mano es exactamente ésa, y vas a poder decir *"lo sabíamos desde be02, y aquí está el conteo"*.

```
💸 DEUDA TÉCNICA INTENCIONAL — el inventario vive en un .md y no en el código
ESTRATOS.md envejece en cuanto alguien toque un archivo, y nada lo verifica.
Lo correcto sería una herramienta de análisis estático en el pipeline que
fallara ante un estilo nuevo.
NO SE PAGA, y la razón está escrita: un sistema en mantenimiento sin pruebas
(hasta be06) y con fecha de decomisión sin decidir (be07) no justifica montar
un pipeline de análisis. Queda declarada en `bea-10` como deuda aceptada, que
es distinto de deuda olvidada.
```

### 5.4 Cómo se clasifica un archivo en dos minutos

El procedimiento, que hay que poder aplicar sin pensar:

1. **Mira la línea 3.** ¿`declare(strict_types=1)`? Symfony, casi seguro. Sigue confirmando, pero ya tienes hipótesis.
2. **Mira el constructor.** ¿Hay? ¿Pide interfaces? Symfony. ¿No hay y el cuerpo llama a `app(...)`? Laravel.
3. **Mira el `return` del primer método.** Array u objeto de respuesta: Laravel o Symfony. ¿Devuelve un modelo? CakePHP. ¿`echo` y `exit`? Sin framework.
4. **Mira los nombres de columna** que toque. `created`/`modified` es CakePHP y no hay más que hablar.
5. **Cuenta tres rasgos coincidentes antes de escribir la etiqueta.** Si sólo tienes dos, la etiqueta es `neutro` y se anota así — un archivo que no se deja clasificar también es información.

**El patrón a memorizar**

> Antes de escribir una línea en un archivo ajeno, contesta dos preguntas: **¿de qué parcela es?** y **¿mi fix va a seguir pareciéndose a este archivo cuando termine?** Es la misma disciplina que en el track base decide entre `constructor` e `inject()`, y ahorra exactamente la misma clase de revisión imposible.

### 5.5 El número que be07 va a necesitar: el coste de rotación

Aquí es donde la deuda de plantilla deja de ser una queja. El método es tosco a propósito —los supuestos se escriben al lado y se discuten— y eso es justo lo que lo hace defendible.

```
COSTE DE ROTACIÓN — plantilla para ESTRATOS.md

(a) Tiempo hasta que alguien nuevo entrega un cambio sin supervisión:  ____ semanas
    Supuesto: sale de tu propia experiencia en be01. Mide lo que te costó a ti
    entender el bootstrap, los facades apagados y la resolución dinámica, y
    súmale lo que no has tocado todavía.

(b) Productividad media durante ese periodo:                            ____ %
(c) Coste semanal cargado de una persona:                               ____
(d) Permanencia media observada en CertCore:                            18 meses
(e) Coste de una rotación = (a) × (c) × (1 − (b))                       ____
(f) Rotaciones en los últimos 8 años:                                   3
(g) Coste de onboarding pagado y perdido = (e) × (f)                    ____

Y la columna que casi nadie escribe:
(h) De ese aprendizaje, ¿cuánto se transfiere a otro sistema?           ____ %
    En un stack con mercado, alto: quien aprende Laravel se lo lleva.
    En Lumen 5.8, cercano a cero — y ESA es la deuda de plantilla.
```

> 🧭 **La deuda de plantilla no es que la gente se vaya. Es que lo que aprendió aquí no vale fuera, así que se va antes y el aprendizaje se pierde entero.** Un sistema en Laravel con la misma rotación pierde mucho menos, porque el siguiente llega sabiendo.

Ese número entra en la opción 1 del *assessment* de be07 —*quedarse y formar*—, y es el que la vuelve discutible. Sin él, "formar a alguien" suena gratis.

### 5.6 Por qué no se uniforma, y por qué eso no es pereza

La conversación llega sola en cuanto la tabla está llena, así que conviene tenerla escrita:

- **Uniformar es tocar todo** el código que funciona, sin pruebas que te avisen (llegan en be06), para ganar coherencia que no cambia ninguna salida.
- **La coherencia no era el problema.** El problema es no saber en qué parcela estás, y eso lo resuelve `ESTRATOS.md` en ocho horas en vez de en dos sprints.
- **Y el argumento que cierra:** si la respuesta del *assessment* acaba siendo *estrangular por endpoint* (be07, opción 3), uniformar hoy es trabajo que se tira entero. **La decisión de uniformar depende de la fecha de decomisión, exactamente igual que todo lo demás en este track.**

Lo que sí se hace, y cuesta cero: **cuando toques un archivo, escribe en su estilo.** Esa disciplina, aplicada durante un año, uniforma más que una refactorización — y sin riesgo.

**Prueba de fuego**

Abre un archivo de `server/app/` que no hayas mirado todavía, pon un cronómetro en dos minutos, y clasifícalo con el procedimiento de §5.4. Después comprueba tu respuesta con `git log --format='%an %ad' -- <archivo>` **si el repositorio conserva esa historia**. Si acertaste sin mirar el log, el ojo ya está entrenado; si el log no dice nada útil, mejor todavía: **acabas de comprobar que la clasificación por rasgos funciona donde `git blame` no llega**, y ése es el músculo de verdad.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Clasificar por un solo rasgo.**
*Síntoma:* etiquetas de `symfony` un archivo porque tiene un constructor con una dependencia.
*Causa:* un rasgo aislado no es una firma; cualquiera escribe un constructor.
*Fix mínimo:* aplica la regla de los tres rasgos, y cuando sólo tengas dos usa `neutro`. Un inventario con etiquetas dudosas es peor que uno con huecos honestos.

**Escribir el fix en tu estilo y no en el del archivo.**
*Síntoma:* un diff de cuatro líneas que nadie sabe revisar: dos son del archivo y dos son tuyas, con otra forma de pedir la misma dependencia.
*Causa:* el reflejo de "yo escribo bien", que además suele ser cierto y da igual.
*Fix mínimo:* reescribe el fix en el estilo del archivo. Y si te duele, anota el archivo en `ESTRATOS.md` como candidato a una reescritura futura — con fecha de decomisión en la mano, no antes.

**Confundir procedencia con calidad.**
*Síntoma:* tu `ESTRATOS.md` tiene una columna implícita de bueno/malo, y `symfony` siempre sale ganando.
*Causa:* el estilo con más ceremonia parece el más profesional.
*Fix mínimo:* añade a cada parcela una línea de **qué hace mejor que las otras**. La de Laravel es la más rápida de leer en un controlador de tres líneas; la de CakePHP concentra la lógica donde está el dato; la del fundador no depende del framework, y en una migración eso vale oro.

**Suponer el conteo en vez de medirlo.**
*Síntoma:* escribes "hay como tres formas de consultar".
*Causa:* el número parecía obvio.
*Fix mínimo:* corre el `grep`. En be04 vas a necesitar el número exacto de `DB::select()` para saber dónde poner los ejercicios, y "como tres" no sirve.

### Pieza forense de esta fase

**Dos endpoints vecinos que hacen lo mismo de dos maneras correctas.**

Llega el ticket: *"la lista de plantillas a veces sale distinta según desde dónde entres"*. Dos rutas, mismo recurso:

```
GET /templates          → LegacyTemplateController@index   (laravel)
GET /v2/templates       → TemplateController@index         (symfony)
```

La investigación, y fíjate en que **ninguno de los tres pasos es leer el código entero**:

1. **Compara las dos salidas, no las dos implementaciones.**
   ```bash
   diff <(curl -s localhost:3000/templates | jq -S .) \
        <(curl -s localhost:3000/v2/templates | jq -S .)
   ```
   Si el diff está vacío, el ticket es sobre otra cosa —caché, orden, momento— y acabas de descartar la mitad del problema en diez segundos.

2. **Si difieren, mira dónde.** Casi siempre en tres sitios: el **orden** (uno ordena y el otro no), la **forma** (array desnudo frente a envuelto) o los **nulos** (uno omite `validUntil: null` y el otro lo incluye). Los tres son decisiones de estilo del autor, tomadas en años distintos, y ninguna está mal por sí sola.

3. **Clasifica los dos archivos antes de tocar ninguno.** Ésa es la pregunta 4 del método forense del track base —*¿de qué generación es el archivo que voy a tocar?*— girada sobre este eje. La respuesta decide **dónde va el fix**: si el consumidor es el frontend de CertCore, el fix va en el endpoint que el frontend usa, escrito en el estilo de **ese** archivo. El otro se anota y se deja quieto.

**Aquí no hay bug que arreglar, y eso es el hallazgo.** Hay dos implementaciones correctas de la misma cosa que divergen en los bordes, exactamente como los dos estilos de inyección del track base. Uniformarlas no es el trabajo. **Saber cuál tocar, sí.**

> 🧠 **Un sistema con dos caminos correctos no tiene un bug: tiene una pregunta sin contestar.** El ticket *"a veces sale distinto"* siempre tiene razón; lo que falta es decir de qué depende ese "a veces".

> 🧨 **Rompe a propósito y observa.** Añade un campo nuevo —`deprecatedAt`— **sólo** al endpoint de Laravel y corre el `smoke.sh`. Después añádelo sólo al de Symfony. Anota en cuál de los dos casos el juez del contrato se entera, y explica por qué. Después la pregunta difícil: si el frontend consume el primero y alguien "arregla" el segundo para que coincida, **¿qué acaba de pasar con el contrato?**

---

## 🧪 7. Ejercicios (29)

**🟢 Fácil (1–7)**

1. Clasifica los cuatro archivos de §5.1 sin volver a leer la tabla de huellas, y después comprueba. Anota cuántos acertaste a la primera.
2. Corre las tres mediciones de §5.3 y pega la salida literal en `ESTRATOS.md`, con la fecha.
3. **Diagnóstico.** Busca todos los archivos de `server/app/` **sin** `declare(strict_types=1)` y cuenta qué porcentaje del total son. Explica en dos líneas qué implica ese porcentaje para el ejercicio 5 de `bea-01`.
4. Encuentra las columnas con nombre de CakePHP (`created`, `modified`) y anota en qué tablas están. Guárdalo: be03 las va a tener que crear tal cual.
5. Elige un controlador y rellena para él la fila completa de la tabla de huellas, con archivo y línea de cada rasgo.
6. **Diagnóstico.** Encuentra el archivo que hace `exit` y explica qué middleware se salta. Compruébalo con un `error_log` en cada middleware.
7. Lista las clases de `server/app/` cuyo namespace tenga más de tres niveles. ¿De qué procedencia son todas?

**🟡 Intermedio (8–18)**

8. **Diagnóstico.** Clasifica **todos** los archivos de `server/app/` y completa `ESTRATOS.md`. Criterio de éxito: ningún archivo sin etiqueta, y cada una con tres rasgos citados.
9. Toma la parcela con más archivos y escribe su "manual de una página": cómo se consulta, cómo se responde, cómo se manejan los errores **en esa parcela**. Alguien nuevo tendría que poder escribir un endpoint en ese estilo leyendo sólo eso.
10. **Diagnóstico.** Para cada una de las cuatro formas de consultar, escribe qué pasaría si la base cambiara de motor. ¿Cuál sobrevive intacta y cuál no sobrevive nada? Guarda la respuesta: es la tesis de be04.
11. Escribe el mismo endpoint —devolver los certificados vigentes— **en las tres procedencias**. Compara líneas, dependencias visibles y facilidad de prueba.
12. **Diagnóstico.** Encuentra un archivo que mezcle dos procedencias dentro de sí mismo. Averigua si fue una modificación posterior —`git log -p` sobre ese archivo— o si alguien escribió así desde el principio. Las dos respuestas son interesantes por motivos distintos.
13. Completa el cálculo de coste de rotación de §5.5 con tus propios supuestos, y escribe cada uno al lado de su número. Después pásale el cálculo a otra persona y pídele que ataque **los supuestos**, no el resultado.
14. **Diagnóstico.** Mide cuánto tardas en clasificar diez archivos al azar. Si tardas más de dos minutos por archivo, ¿qué rasgo te está faltando en la tabla?
15. Añade a `ESTRATOS.md` una columna *"qué hace mejor esta parcela"* y rellénala para las cuatro. Si alguna te sale vacía, no has entendido esa parcela todavía.
16. **Diagnóstico.** Elige un ticket inventado —*"el campo `validUntil` a veces llega como cadena vacía y a veces como null"*— y determina **en qué parcela** habría que arreglarlo y por qué. No lo arregles.
17. Compara `ESTRATOS.md` con el ejercicio 5 de [`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md) —el conteo de formas de obtener servicios— y comprueba que los dos números cuadran. Si no cuadran, uno de los dos está mal: averigua cuál.
18. **Diagnóstico.** Reproduce la pieza forense de §6 con tus propios endpoints y anota en cuál de los tres sitios divergen (orden, forma, nulos).

**🟠 Difícil (19–25)**

19. **Diagnóstico.** Escribe un guion —`estratos.sh`— que clasifique automáticamente cada archivo por rasgos y saque la tabla. Después corre tu clasificación manual contra la automática y explica **cada discrepancia**. Las discrepancias son el resultado interesante, no el guion.
20. Toma el archivo sin framework (el del `exit`) y decide, argumentando: ¿se deja, se adapta o se reescribe? Da el criterio, no la preferencia, y di qué dato te haría cambiar de opinión.
21. **Diagnóstico.** Con la medición 1 en la mano, predice **en qué archivos** van a aparecer los bugs cuando la base de datos suba de versión mayor. Escribe la lista, séllala en un commit, y no la mires hasta be04. Ahí la comparas con lo que pase de verdad.
22. Escribe la guía de estilo que este proyecto nunca tuvo: dos páginas, para alguien que entra mañana. Después responde lo incómodo: **¿habría evitado los estratos?** Escribe honestamente qué habría hecho falta además del documento.
23. **Diagnóstico.** Busca en el código heredado un caso donde una convención de CakePHP —`id` autonumérico en toda tabla— haya condicionado una decisión de diseño que hoy duele. Pista: mira cómo está identificada una plantilla versionada. **Guarda el hallazgo: es el punto de partida de be05.**
24. Estima cuánto costaría uniformar las tres parcelas en horas, con supuestos escritos. Después estima cuánto costaría **no** uniformarlas durante dos años más. Presenta las dos cifras juntas: ése es el formato de todo el track.
25. **Diagnóstico adversarial.** Un compañero propone una regla de análisis estático en el pipeline que rechace cualquier archivo sin `declare(strict_types=1)`. Escribe la respuesta en dos párrafos: cuántos archivos rompería hoy (el número sale de tu ejercicio 3), qué pasaría con el primer hotfix urgente, y cuál es la versión de esa regla que sí se puede aplicar.

**🔴 Muy difícil (26–29)**

26. **Diagnóstico.** Reconstruye la historia de plantilla de `certcore-api` **sólo con el código**: cuántas personas distintas lo escribieron, en qué orden, y con qué solapamiento. Contrasta con la tabla de §4 y anota en qué te equivocaste. Lo interesante es en qué basaste cada inferencia.
27. Escribe el post-mortem de dos páginas que nadie escribió en 2019: *"por qué tenemos cuatro estilos"*. Con causas, no culpables, y con la sección que siempre falta — **qué señal, en qué momento, tendría que haber disparado una revisión**.
28. **Diagnóstico.** Toma las tres mediciones y construye el argumento de una página para la opción 1 del *assessment* (*quedarse y formar*). Después construye el argumento **contrario** con **los mismos números**. Que los dos sean defendibles es el resultado: los números no deciden solos, y saber eso es seniority.
29. **Diagnóstico adversarial.** Alguien sostiene que los estratos por procedencia son un problema inventado, *"porque todo esto es PHP y todo funciona"*. Desmóntalo con evidencia de tu propio inventario: nombra un bug concreto que la pluralidad hizo posible, di cuánto costó encontrarlo, y —lo honesto— **reconoce qué parte del argumento contrario es cierta**.

**🔥 Opcionales**

- 🔥 Clasifica por procedencia el frontend de CertCore con el mismo método. ¿Funciona? ¿Qué eje aparece ahí que aquí no existe, y al revés?
- 🔥 Escribe una anotación de clasificación (`@estrato laravel`) en la cabecera de cada archivo y deja que `estratos.sh` la use. Después argumenta si eso mejora el sistema o sólo lo decora — y qué pasa cuando alguien mueve código de un archivo a otro.

---

## 📚 8. Referencias

**Documentación oficial**
- https://lumen.laravel.com/docs/5.8 — la referencia de la versión exacta. Útil aquí para confirmar qué es idiomático **en Lumen** y qué se coló de Laravel.
- https://symfony.com/doc/current/service_container.html — la inyección por constructor tal como la enseña Symfony. Es la fuente del reflejo que vas a reconocer en la parcela `symfony`.
- https://book.cakephp.org/3/en/orm/table-objects.html — las convenciones de CakePHP, incluidas las de nombres de columna. Explica de dónde salió `created`/`modified`. ⚠️ Es la documentación de CakePHP 3, contemporánea del autor que dejó esa huella.
- https://www.php-fig.org/psr/psr-12/ — el estándar de estilo de PHP. Léelo sabiendo lo que este track sostiene: **un estándar de formato no evita estratos de arquitectura.**

**Libros / artículos de referencia**
- *Your Code as a Crime Scene* (Adam Tornhill, Pragmatic Bookshelf, 2015) — el análisis de código como evidencia social: quién tocó qué, cuándo, y qué dice eso del sistema. Es el marco conceptual exacto de esta fase, y el capítulo de *knowledge loss* es literalmente la deuda de plantilla con otro nombre.
- *Peopleware* (DeMarco y Lister, 3.ª ed., Addison-Wesley, 2013), capítulos sobre rotación — de dónde sale el método tosco de §5.5 y por qué un cálculo con supuestos visibles vale más que uno preciso con supuestos ocultos.

**Video / apoyo**
- https://www.youtube.com/results?search_query=conway%27s+law+software+architecture — la ley de Conway, que es esta fase vista desde arriba: la arquitectura acaba pareciéndose a la organización que la escribió. Aquí la organización era "una persona cada dieciocho meses".

**Orden de lectura sugerido:** [`bea-09`](bea-09-symfony-como-vara-de-medir.md) **antes** de clasificar, para tener la vara en la mano → la documentación de convenciones de CakePHP **durante**, cuando encuentres la primera columna rara → Tornhill **después**, cuando tengas tu inventario y quieras llevarlo a un sistema que no sea CertCore.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. Y ojo con un sesgo de esta bibliografía: **casi toda la documentación de Symfony y CakePHP que encontrarás es de sus versiones actuales**, mientras que las huellas que estás clasificando son de 2018–2022. Lo que reconoces es el reflejo de esa época, no el estilo que esos frameworks recomiendan hoy.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Tienes `ESTRATOS.md`: todos los archivos clasificados, tres mediciones con su comando, y un número de coste de rotación con los supuestos a la vista. Y tienes algo que no se ve en ningún archivo: la capacidad de abrir un controlador que no conocías y decir en diez segundos de qué parcela es y en qué estilo vas a escribir tu fix.

**be03** es el paso natural y por fin se toca la base. Vas a apagar el mock y a levantar PostgreSQL con las siete tablas, sembrado desde **tu propio `db.json`**, sirviendo el dialecto de json-server hasta en sus rarezas. Y dos cosas de esta fase viajan contigo: las columnas `created`/`modified` de la parcela CakePHP —que hay que crear tal cual, aunque duela— y el conteo de `DB::select()` con SQL a mano, que en be04 va a resultar ser el mapa exacto de dónde están los bugs.

> **La señal de que quedó bien:** *"abrí un archivo que no había visto nunca, supe de quién venía antes de leer el segundo método, y escribí el fix sin que se notara que no era mío."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-02-estratos-por-procedencia \
>   -m "be02 cerrada: ESTRATOS.md con todos los archivos clasificados y su evidencia;
> las tres mediciones hechas con su comando; coste de rotación estimado con supuestos;
> cero líneas uniformadas"
> ```
>
> Los commits de esta fase llevan `be02: …` y los de ejercicio `be02 ej21: …`. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥.
>
> Esta fase tiene algo propio que decir sobre git, y es una advertencia: **`git blame` aquí miente por omisión**. Los archivos se movieron de directorio dos veces, y el autor que figura suele ser quien reindentó, no quien decidió. La clasificación por rasgos de §5.4 funciona precisamente donde `blame` no llega, y el ejercicio 26 existe para que lo compruebes. Guarda la predicción del ejercicio 21 en un commit con `be02 ej21: predicción sellada` — en be04 la vas a abrir.

---

## 📌 Pendientes sugeridos

- **`ESTRATOS.md` envejece y nada lo verifica** (💸 de §5.3). Queda declarada como deuda aceptada, no olvidada. → **`bea-10`**, con su razón escrita.
- **El archivo con `exit` se salta la cadena de middleware entera**, incluido el manejo de errores. Hoy es una curiosidad; en be06 es lo que va a romper la primera prueba que lo toque. → **be06**, como caso de la reescritura a medias.
- **La convención de `id` autonumérico** que la parcela CakePHP dejó puesta (ejercicio 23) explica por qué una plantilla versionada se identifica como se identifica. Es demasiado importante para quedarse en un ejercicio. → **be05**, donde la invariante se mira de frente; se nombra también en be03 al crear la tabla.
- **El coste de rotación usa la permanencia observada de CertCore (18 meses) como si fuera un dato del sector**, y no lo es. La fase lo declara como supuesto y así se queda; si alguna vez hay una fuente pública que lo respalde, se cita. → **be07**, que es quien lo va a defender ante alguien.
- **Nadie decidió nunca qué parcela es la buena**, y esta fase tampoco lo decide a propósito. Esa decisión es de be06 —donde llegan las pruebas— y de be07 —donde se costea—. Si alguien la toma antes, se la toma sin datos.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| **be-03** | "El mismo dato sale distinto según por dónde entres" | Estratos por procedencia · dos caminos correctos | 🟠 |
MDEOF
wc -l be02-estratos-por-procedencia.md

# --- 2026-09-11T18:11:10 · Write bea-09 appendix
cat > bea-09-symfony-como-vara-de-medir.md <<'MDEOF'
# 📎 Apéndice bea-09 — Symfony como vara de medir

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **3 horas**
> Usado por: **be02**, **be06**, **be07** ⭐ · Versiones cubiertas: las LTS de Symfony (2.8, 3.4, 4.4, 5.4, 6.4, 7.4), verificadas el 11/09/2026
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

🧭 **Symfony es el grupo de control, no el paciente. Y aquí no se escribe una línea de Symfony.**

Ésa es la primera frase por una razón: este apéndice existe para **medir a Lumen contra algo**, no para enseñar otro framework. Si buscas un tutorial de Symfony, éste no lo es y no va a serlo en ningún párrafo.

**Esto no se lee de corrido.** Se entra buscando un argumento concreto —*"¿qué le faltaba a Lumen, exactamente?"*, *"¿cuánto cuesta de verdad una reescritura?"*— y se sale con él y con la cifra que lo respalda.

**Qué queda fuera:** enseñar Symfony, su sintaxis, su contenedor o su configuración; **Doctrine** más allá de nombrarlo como el monstruo que es; y cualquier recomendación de migrar a nada. La decisión es de [`be07`](be07-el-assessment-de-riesgo.md) y depende de la fecha de decomisión, no de este apéndice.

---

## Índice

- [Por qué Symfony perdió como candidato, y por qué eso lo vuelve útil](#por-qué-symfony-perdió-como-candidato-y-por-qué-eso-lo-vuelve-útil)
- [Papel 1 — Vara de medir: la disciplina que Lumen no tuvo](#papel-1--vara-de-medir-la-disciplina-que-lumen-no-tuvo)
- [Papel 2 — Origen: la huella del dev de Symfony](#papel-2--origen-la-huella-del-dev-de-symfony)
- [Papel 3 — Destino: la opción 2 del *assessment*](#papel-3--destino-la-opción-2-del-assessment)
- [Y dónde sí duele Symfony, para el registro](#y-dónde-sí-duele-symfony-para-el-registro)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-6)

---

## Por qué Symfony perdió como candidato, y por qué eso lo vuelve útil

Cuando se diseñó este track se consideraron cinco tecnologías para hacer de sistema enfermo. Symfony se descartó por una razón que suena a elogio y lo es:

> 🧭 **No tiene problemas suficientes.** Es enorme, está sano, y su disciplina de actualización es famosa y merecida. El veredicto honesto sobre un Symfony viejo sería *"súbelo, hay camino"* — y eso no sostiene ocho fases de nada.

Y justo por eso vale como **grupo de control**. Para poder decir con argumentos *"a Lumen le faltaba X"* hace falta un sistema comparable —mismo lenguaje, misma época, mismo tipo de empresa— donde **X sí existía**. Sin esa comparación, cualquier queja sobre Lumen es una opinión; con ella, es una diferencia medible.

---

## Papel 1 — Vara de medir: la disciplina que Lumen no tuvo

Aquí está el 80% del valor del apéndice. Tres mecanismos, y los tres tienen fecha.

### El calendario, que es la diferencia más grande

Symfony publica una versión menor cada **seis meses** (mayo y noviembre), una mayor cada **dos años**, y una **LTS cada dos años** que recibe **tres años de correcciones y cuatro de parches de seguridad** — siete años de cobertura por versión.

| LTS | Publicada | Fin de seguridad |
|---|---|---|
| 2.8 | Nov 2015 | Nov 2019 |
| 3.4 | Nov 2017 | Nov 2021 |
| 4.4 | Nov 2019 | Nov 2023 |
| 5.4 | Nov 2021 | Feb 2029 |
| 6.4 | Nov 2023 | Nov 2027 |
| 7.4 | Nov 2025 | Nov 2029 |

*(Verificado en `symfony.com/releases` el 11/09/2026.)*

Contrástalo con lo que sabes de CertCore: **Lumen 5.8.13 se publicó el 28/08/2019 y no tiene ninguna fila equivalente.** No hay fecha de fin de soporte porque nunca hubo una promesa de soporte. No hay LTS. No hay calendario.

> 🧠 **La diferencia no es la calidad del código: es que uno de los dos te dice cuándo vas a tener que moverte.** Un equipo que sabe que su versión pierde parches en noviembre de 2027 puede planificar. Un equipo sin esa fila planifica cuando se rompe algo — y eso, en CertCore, fue nunca.

### Los avisos de deprecación

Symfony marca lo que va a desaparecer **una versión mayor antes**, y lo emite en tiempo de ejecución: el código sigue funcionando y grita. Una versión menor no rompe nada; las roturas se acumulan para la mayor, y todo lo que va a romperse ya se avisó.

Eso convierte una migración mayor en **una lista de tareas**, no en una expedición. Y explica la frase honesta del track: *"súbelo, hay camino"*.

**Lumen 5.x no tenía nada de esto.** Ni avisos de deprecación consistentes, ni una guía de actualización por versión mayor, ni una herramienta que dijera qué te va a romper. Por eso la subida de 5.8 a 6.0 nunca se intentó: no era una lista de tareas, era una apuesta.

### El utillaje

Existe Rector —reescritura automática de código entre versiones—, existen los *upgrade guides* por versión, existe una herramienta que audita dependencias con vulnerabilidades conocidas. Nada de eso es magia, y nada de eso reemplaza el trabajo; lo que hace es **poner el trabajo en una barra de progreso**, que es exactamente lo que falta cuando le pides a alguien presupuesto para una migración.

> 🧭 **La frase que hay que poder defender en be07:** *"el problema no fue elegir Lumen. Fue elegir algo sin calendario de soporte para un servicio que iba a durar diez años, y no volver a mirarlo."* Esta sección es la evidencia de esa frase.

---

## Papel 2 — Origen: la huella del dev de Symfony

De aquí viene una de las cuatro parcelas de [`be02`](be02-estratos-por-procedencia.md). El dev que llega de Symfony trae reflejos concretos y reconocibles:

- **Inyección por constructor, siempre.** Nunca *service locator*. Las dependencias se declaran en la firma, no se buscan en el cuerpo.
- **Interfaces.** Depende de `TemplateRepositoryInterface`, no de la clase.
- **`declare(strict_types=1)`** en la primera línea, sin excepciones.
- **Objetos de respuesta explícitos** (`new JsonResponse(...)`), nunca un helper global.
- **Excepciones de dominio propias**, no `abort(404)`.
- **Namespaces profundos** que modelan el dominio (`App\Domain\Template\...`), no la infraestructura.

Nada de eso está mal — al contrario, es el código más fácil de probar del repositorio, y en [`be06`](be06-la-reescritura-a-medias.md) eso deja de ser una opinión. Lo que hay que entender es **por qué chirría**: llega a un proyecto donde el resto usa el estilo contrario, y sin una guía que decida, la parcela nueva se suma a las que ya había.

> 🧠 **Un buen reflejo aplicado sin una decisión de equipo produce un estrato más.** La calidad individual no compensa la ausencia de revisión — que es la tesis del track entero.

---

## Papel 3 — Destino: la opción 2 del *assessment*

En [`be07`](be07-el-assessment-de-riesgo.md), la opción 2 es *reescribir a algo aburrido y sostenido*. Symfony es el ejemplo canónico de "aburrido y sostenido", y este apéndice existe para que esa opción se pueda costear en vez de invocar.

Lo que se gana, y hay que decirlo completo:

- Un calendario de soporte con fechas, siete años por LTS.
- Un mercado laboral de verdad: se puede contratar gente que ya lo sabe, y lo que aprenda aquí le sirve fuera — lo cual **ataca directamente la deuda de plantilla de be02**, que es el argumento más fuerte de esta opción y el que casi nadie pone sobre la mesa.
- Deprecaciones avisadas y utillaje de actualización.

Lo que cuesta, y hay que decirlo igual de completo:

- **Reescribir, no migrar.** No hay camino de Lumen a Symfony: son contenedores distintos, arranque distinto, ORM distinto (Eloquent → Doctrine, que no es una traducción, es un cambio de modelo mental).
- **Mientras dura, dos sistemas.** El coste del estado intermedio es el tema de be06, y es el más caro de todos.
- **El equipo actual no sabe Symfony.** Formar o contratar, y las dos tienen factura.
- **Y la pregunta que decide:** ¿cuántos años le quedan a CertCore? Con dos, no se reescribe nada. Con diez, no reescribir es la decisión cara.

---

## Y dónde sí duele Symfony, para el registro

Si este apéndice pintara Symfony como el paraíso, sería propaganda y el track perdería su criterio. Duele, y en sitios concretos:

- **El salto de 2/3 a 4 con Flex** reestructuró el proyecto entero: la forma del directorio, la configuración y la gestión de *bundles* cambiaron a la vez. Fue lo más parecido a una reescritura que le ha pasado a un framework sano, y muchas empresas se quedaron en 3.4 hasta su EOL en noviembre de 2021 precisamente por eso.
- **Cuatro eras de configuración conviviendo:** XML, YAML, anotaciones y atributos. Un proyecto con ocho años tiene las cuatro, y cada persona escribe en la que aprendió — **exactamente el mismo fenómeno de be02, en un framework sano**. La disciplina de versiones no cura los estratos de estilo.
- **El contenedor compilado**, con su clásico *"funciona después de `cache:clear`"*. Es rapidísimo en producción y una fuente inagotable de desconcierto en desarrollo.
- **Doctrine, que duele más que Symfony mismo.** Es el monstruo real: migraciones que divergen de la base, *proxies* perezosos que explotan fuera de contexto, N+1 por todas partes, y un modelo de persistencia —*data mapper*, unidad de trabajo— que es conceptualmente correcto y muy incómodo para quien viene de Active Record. Comparado con Eloquent, Doctrine te obliga a tener razón antes de escribir.
- **El ecosistema de *bundles* de la era 2.x murió.** Paquetes de terceros que eran estándar de facto en 2015 no sobrevivieron a Flex, y sus reemplazos no eran equivalentes. **El framework tenía calendario; sus dependencias, no.** Ésa es la advertencia que hay que llevarse a be07: la disciplina del núcleo no se hereda al ecosistema.

> 🧠 **Un framework sano no es un framework sin dolor. Es uno donde el dolor tiene fecha, aviso y documentación.** Es toda la diferencia que este apéndice viene a medir.

---

## 🧭 Cuándo usar qué

| Necesitas… | Usa de aquí | Cuidado con |
|---|---|---|
| Argumentar qué le faltaba a Lumen | La tabla de LTS y las deprecaciones | No deslices "Lumen es malo": el pecado fue no revisar |
| Clasificar un archivo en be02 | La lista de reflejos del papel 2 | Un rasgo no clasifica; tres sí |
| Costear la opción 2 de be07 | Lo que se gana / lo que cuesta | El coste del estado intermedio es de be06, no lo dupliques |
| Defender que **no** hay que reescribir | La sección de dónde duele Symfony | Es honestidad, no munición: úsala completa |
| Explicar por qué hay cuatro estilos | Las cuatro eras de configuración | Pasa igual en frameworks sanos: no es culpa de Lumen |
| Decidir entre formar y contratar | El argumento de mercado del papel 3 | El número sale de be02 §5.5, no de aquí |

---

## ⚠️ Advertencias

**No conviertas este apéndice en una recomendación.** Dice que Symfony tiene disciplina de versiones y mercado; no dice que CertCore deba migrar. La respuesta correcta depende de la fecha de decomisión, y quien la decide es be07 con los números de las siete fases.

**Las fechas envejecen.** La tabla de LTS está verificada el 11/09/2026; consúltala en la fuente antes de citarla en un documento que alguien vaya a firmar. Y fíjate en el detalle que cambia argumentos: **5.4 tiene seguridad hasta febrero de 2029**, más allá de lo que marca la política estándar. Las excepciones existen y desmontan generalizaciones.

**El alumno no escribe Symfony en este track, y eso es deliberado.** Los seis ejercicios de abajo son de comparación argumentada, ninguno de código. Si acabas montando un proyecto de Symfony para "probar", te has salido del track: lo que se entrena aquí es defender una decisión, no aprender un framework.

---

## 📚 Referencias

- https://symfony.com/releases — la tabla de versiones con fechas de fin de correcciones y de seguridad. **Es la fuente de la tabla de arriba** y la que hay que citar.
- https://symfony.com/doc/current/contributing/community/releases.html — la política de publicación: menores cada seis meses, mayores cada dos años, LTS con tres años de correcciones y cuatro de seguridad.
- https://symfony.com/doc/current/setup/upgrade_major.html — cómo se sube una versión mayor, con los avisos de deprecación como mecanismo central. Léelo pensando en qué habría hecho falta para subir Lumen 5.8 a 6.0.
- https://getrector.com/ — Rector, la reescritura automática entre versiones. Existe también para Laravel; **no existió nunca para el salto que CertCore necesitaba**.
- https://www.doctrine-project.org/projects/orm.html — Doctrine, para entender por qué "reescribir a Symfony" incluye cambiar de modelo de persistencia y no sólo de framework.
- https://packagist.org/packages/laravel/lumen-framework — el contraste: el historial de versiones de Lumen, sin ninguna columna de soporte.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos, y **con las fechas de soporte hazlo siempre**: son el único dato de este apéndice que un lector podría llevarse a una reunión.

---

## 🧪 Ejercicios (6)

Ninguno es de código. Todos se entregan escritos, y todos se defienden.

1. Construye la tabla comparativa de soporte: Lumen 5.8.13 frente a la LTS de Symfony contemporánea (4.4). Columnas: fecha de publicación, fin de correcciones, fin de seguridad, guía de actualización, herramienta de migración. Las celdas vacías del lado de Lumen son el ejercicio.
2. **Comparación argumentada.** Escribe en una página qué habría pasado en CertCore si en 2016 se hubiera elegido Symfony 2.8. Incluye lo malo: el salto de Flex les habría caído encima en 2018. ¿Habría sido mejor, o sólo distinto? Da un criterio, no una preferencia.
3. Toma la parcela `symfony` de tu `ESTRATOS.md` (be02) y argumenta en tres párrafos si esos archivos son *mejores* que los de la parcela `laravel`. Obligatorio: al menos un párrafo tiene que defender los de Laravel, y tiene que ser convincente.
4. **Comparación argumentada.** Un equipo propone migrar a Symfony para "tener soporte". Escribe la objeción de dos párrafos que un arquitecto experimentado pondría, sabiendo lo del ecosistema de *bundles* de la era 2.x. Pista: la disciplina del núcleo no se hereda a las dependencias.
5. Estima la opción 2 del *assessment* con lo que sabes hasta ahora: reescribir `certcore-api` a Symfony. Escribe los supuestos primero y el número después, y marca **de qué fase del track sale cada dato**. Si algún dato no sale de ninguna, márcalo como estimación inventada — eso también es información.
6. **Comparación adversarial.** Alguien sostiene que el calendario de LTS es marketing y que *"en la práctica todo el mundo se queda en la versión que tiene igual"*. Desmóntalo con las fechas de la tabla, y después **concede la parte que es cierta**: muchas empresas se quedaron en 3.4 hasta su EOL. ¿Qué cambia entonces el calendario, si la gente igual no actualiza? Contesta eso y tendrás el argumento de be07.

---

> 🏷️ **Este apéndice no lleva tag propio.** No deja archivos versionados —no se escribe una línea de Symfony— y lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be02: …`, `be06: …`, `be07: …`). Las tablas comparativas de los ejercicios 1 y 5 conviene conservarlas: be07 las cita, y lo hace mejor si están fechadas en el mensaje de un tag anotado (`ej/bea-09/1`). La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
MDEOF
wc -l bea-09-symfony-como-vara-de-medir.md

# --- 2026-09-11T18:11:21 · Read domain models from phase 3
sed -n '600,760p' 03-mock-api-caos.md

# --- 2026-09-11T18:15:57 · Write be03 phase
cat > be03-el-reemplazo.md <<'MDEOF'
# 🗄️ Fase be03 — El reemplazo: de `db.json` a Postgres 16

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Fase be03 de be07 · **10 horas**
> Depende de: **be02 cerrada** (`ESTRATOS.md` completo) · Habilita: be04
> Apéndices de apoyo: [`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md) · [`bea-02`](bea-02-receta-de-imagen-y-compose.md) · Incidentes asociados: **be-04**, **be-05**
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
MDEOF
wc -l be03-el-reemplazo.md

# --- 2026-09-11T18:17:57 · Write bea-04 appendix
cat > bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md <<'MDEOF'
# 📎 Apéndice bea-04 — Eloquent: lo que absorbe y lo que no

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **3 horas**
> Usado por: **be03**, **be04** ⭐ · Versiones cubiertas: Eloquent de la línea de **Lumen 5.8** (componentes Illuminate 5.8), **PostgreSQL 16**
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido.** Se entra con una pregunta concreta —*"¿qué SQL sale de esto?"*, *"¿esto me protege de un cambio de versión?"*— y se sale con la respuesta y con el comando para comprobarla.

🧭 **El ángulo: este apéndice no enseña a usar Eloquent. Enseña dónde deja de protegerte.** Ésa es la diferencia que lo hace útil, porque de usar Eloquent hay mil tutoriales y de lo otro no hay ninguno. Y tiene una consecuencia práctica que vale por todo el documento: **te dice dónde van a aparecer los bugs el día que la base cambie de versión**, que es exactamente la fase [`be04`](be04-el-salto-de-version-que-nadie-corrio.md).

**Qué queda fuera:** **Doctrine**, que se nombra en [`bea-09`](bea-09-symfony-como-vara-de-medir.md) como el monstruo de Symfony y no se enseña; el **diseño del esquema**, que es de [`be03`](be03-el-reemplazo.md) y no se repite aquí; la optimización fina de consultas; y la magia de `__call`/`__get` en sí misma, que es [`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md) — aquí se da por sabida y se enlaza.

---

## Índice

- [Lo primero: cómo se ve el SQL de verdad](#lo-primero-cómo-se-ve-el-sql-de-verdad)
- [Active Record: el modelo es también la fila](#active-record-el-modelo-es-también-la-fila)
- [Los *scopes*, y por qué no aparecen buscándolos](#los-scopes-y-por-qué-no-aparecen-buscándolos)
- [La clave primaria compuesta, que Eloquent no soporta](#la-clave-primaria-compuesta-que-eloquent-no-soporta)
- [Relaciones y el N+1, con medición](#relaciones-y-el-n1-con-medición)
- [`DB::select()`, `DB::raw()` y el SQL a mano ⭐](#dbselect-dbraw-y-el-sql-a-mano-)
- [Migraciones que divergen de la base real](#migraciones-que-divergen-de-la-base-real)
- [🧭 Cuándo usar qué: qué absorbe y qué te deja ver](#-cuándo-usar-qué-qué-absorbe-y-qué-te-deja-ver)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-8)

---

## Lo primero: cómo se ve el SQL de verdad

Todo lo demás de este apéndice depende de esto, y sin ello estarías suponiendo. Tres formas, de menos a más invasiva:

```php
// 1. Sin ejecutar nada: qué SQL saldría. No necesita conexión.
Template::active()->toSql();
//   select * from "templates" where "valid_until" is null
//   ⚠️ Muestra los marcadores, no los valores. Para los valores: ->getBindings()

// 2. Registrar todo lo que se ejecute en esta petición.
DB::enableQueryLog();
// ... tu código ...
var_dump(DB::getQueryLog());   // sql, bindings y tiempo de cada consulta

// 3. Escuchar cada consulta y mandarla al log del contenedor.
DB::listen(function ($query) {
    error_log(sprintf('%s | %s | %.2f ms',
        $query->sql, json_encode($query->bindings), $query->time));
});
```

La tercera, puesta en `bootstrap/app.php` detrás de una variable de entorno, es la que vas a querer durante be03 y be04:

```bash
docker compose logs -f api | grep 'select\|insert\|update'
```

> 🧭 **Regla del apéndice, y de los ocho ejercicios:** ningún SQL se supone. Se saca del log o de `toSql()`, y se pega tal cual. Eloquent genera cosas que no son las que escribirías tú, y ése es justo el tema.

---

## Active Record: el modelo es también la fila

Eloquent es Active Record: un objeto es una fila, y el objeto sabe guardarse.

```php
$certificate = new Certificate();
$certificate->inspection_id = 501;
$certificate->status = 'valid';
$certificate->save();     // INSERT ... y el objeto se queda con el id asignado
```

Lo cómodo es evidente. Lo que conviene tener presente es lo otro:

- **La persistencia está dentro del modelo de dominio.** No hay sitio "natural" para una regla que abarque varias filas —una transacción, una invariante entre dos tablas—, así que acaba en el controlador. En CertCore eso es literal: la emisión de un certificado son dos escrituras y no hay transacción (be00, ejercicio 20).
- **`$model->campo` no es una propiedad**: es `__get` mirando un array interno de atributos. Un typo no da error, **da `null`**. `$certificate->statuss` es `null` y tu `if` se lo traga.
- **`save()` sobre un modelo sin cambios no hace nada**, y sobre uno con cambios hace un `UPDATE` sólo de las columnas tocadas. Es eficiente y sorprende la primera vez que ves el log.

> ⚠️ **El `null` silencioso de `__get` es la familia de bugs más cara de este ORM**, y es exactamente la misma conversación que la Fase 9 del track base: `null`, `undefined` y campo ausente son tres cosas distintas. Aquí las tres se ven igual.

---

## Los *scopes*, y por qué no aparecen buscándolos

```php
// Se DECLARA así...
public function scopeActive($query) { return $query->whereNull('valid_until'); }

// ...y se INVOCA así.
Template::active()->get();
```

`__call` recibe `active`, le antepone `scope`, y llama al método que sí existe. Buscar `function active` no encuentra nada; buscar `::active(` sí. El mecanismo está en [`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md); lo que importa aquí es que **un scope es una porción de consulta reutilizable**, y que se componen:

```php
Template::active()->where('template_id', 'elevator-annual')->orderBy('version')->toSql();
//   select * from "templates" where "valid_until" is null and "template_id" = ?
//   order by "version" asc
```

Y la trampa de composición, que cuesta una tarde: **un scope con varias condiciones y un `orWhere` fuera se mezclan sin paréntesis**, y el `AND`/`OR` sale donde no querías. Si un scope tiene más de una condición, encierra su cuerpo en una clausura (`$query->where(function ($q) { ... })`). Compruébalo siempre con `toSql()`.

---

## La clave primaria compuesta, que Eloquent no soporta

Ésta es la limitación que más le duele a CertCore, y la razón está en `templates`: su clave es `(template_id, version)`.

**Eloquent da por hecho una clave primaria simple, y además incremental.** No hay forma de declarar una compuesta. Lo que se puede hacer es desactivar los supuestos y trabajar con `where()` explícito:

```php
class Template extends Model
{
    public $incrementing = false;   // no hay serial
    protected $primaryKey = null;   // no hay clave simple
    public $timestamps = false;     // no hay created_at/updated_at
}
```

Y a partir de ahí, lo que deja de funcionar:

| Lo que esperas | Qué pasa |
|---|---|
| `Template::find('elevator-annual-v2')` | **No.** No hay clave simple que buscar |
| `$template->save()` sobre uno existente | **Cuidado:** sin clave primaria, el `UPDATE` no sabe qué fila tocar |
| `$template->delete()` | Lo mismo |
| Relaciones estándar contra `templates` | **No.** `belongsTo` asume una columna |

La forma que funciona, y que es la que verás en `server/`:

```php
// Buscar: explícito, siempre.
Template::where('template_id', $templateId)->where('version', $version)->first();

// Actualizar: por consulta, no por modelo.
Template::where('template_id', $templateId)->where('version', $version)
    ->update(['valid_until' => $date]);
```

> 🧠 **Aquí está el origen del `id` compuesto de CertCore.** Cuando el ORM de tu framework no sabe hablar de claves compuestas, la salida cómoda es aplastarlas en una cadena —`"elevator-annual-v2"`— y declarar *esa* como clave. Nadie tomó esa decisión por convicción: la tomó la herramienta, en 2016, y ocho años después es la razón por la que **la clave foránea compuesta que sostendría la invariante nunca se pudo ni escribir**. Ése es el asunto entero de [`be05`](be05-la-invariante-que-no-sostenia-nadie.md).

---

## Relaciones y el N+1, con medición

```php
class Inspection extends Model
{
    public function findings()
    {
        return $this->hasMany(Finding::class, 'inspection_id');
    }
}
```

El N+1 es el bug clásico y se ve **en el log**, no en el código:

```php
// MAL: una consulta + una por cada inspección.
foreach (Inspection::all() as $inspection) {
    $count = $inspection->findings->count();
}
//   select * from "inspections"
//   select * from "findings" where "inspection_id" = ?     ← ×N

// BIEN: dos consultas, siempre dos.
foreach (Inspection::with('findings')->get() as $inspection) {
    $count = $inspection->findings->count();
}
//   select * from "inspections"
//   select * from "findings" where "inspection_id" in (?, ?, ?, …)
```

**Con las cinco inspecciones del `db.json` la diferencia es indetectable**, y por eso lleva ocho años ahí. Con las cuatro mil de [`be05`](be05-la-invariante-que-no-sostenia-nadie.md) son cuatro mil viajes. El método para medirlo es siempre el mismo: contar consultas, no adivinar.

```php
DB::enableQueryLog();
// ... el código sospechoso ...
error_log('consultas: ' . count(DB::getQueryLog()));
```

> 🧭 **El N+1 no se detecta leyendo código: se detecta contando consultas.** Y no se arregla por prevención generalizada —poner `with()` en todas partes trae de vuelta datos que nadie usa—, se arregla donde el contador lo señale.

---

## `DB::select()`, `DB::raw()` y el SQL a mano ⭐

**Ésta es la sección por la que existe el apéndice.** Todo lo anterior lo absorbe el ORM; esto, no.

```php
// Consulta cruda: Eloquent no participa. El SQL viaja tal cual al servidor.
$rows = DB::select('SELECT * FROM certificates WHERE valid_until < NOW() AND status = ?', ['valid']);

// Fragmento crudo dentro de una consulta construida.
Certificate::where(DB::raw("date_trunc('day', valid_until)"), '<=', $date)->get();
```

Las tres razones por las que esto está en `certcore-api` son siempre las mismas, y ninguna es mala intención: una función que el constructor de consultas no expone, una consulta de informe que era más fácil de escribir en SQL, y la prisa.

Y las tres consecuencias:

1. **Todo cambio de dialecto te llega entero.** Comillas, funciones de fecha, casts, sintaxis específica de la versión: el ORM no está en medio para traducir nada.
2. **La inyección SQL es posible aquí y sólo aquí.** Con marcadores (`?`) no; concatenando, sí. [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) lo trata, y no por casualidad apunta a este mismo sitio.
3. **Es donde hay que poner los ejercicios y donde hay que buscar los bugs.** Literalmente: un `grep` te da el mapa.

```bash
cd server
grep -rn "DB::select(\|DB::raw(\|DB::statement(\|->query(" app/ | tee ../SQL-CRUDO.txt | wc -l
```

> 🧠 **La factura de un salto de versión la paga exactamente el código que se saltó las convenciones.** Eloquent absorbe casi todos los cambios de dialecto; lo que no absorbe es el SQL que alguien escribió a mano para ir más rápido. Para diseñar ejercicios es un regalo, porque dice **dónde** ponerlos sin adivinar — y para diagnosticar en producción, lo mismo.

Ese archivo `SQL-CRUDO.txt` es el insumo directo de be04. Guárdalo.

---

## Migraciones que divergen de la base real

Las migraciones describen el esquema **que deberían haber producido**, no el que hay. Divergen en cuanto alguien toca producción a mano — y en un sistema de ocho años, alguien tocó producción a mano.

Cómo se comprueba, que es lo único que hay que saber:

```bash
# Lo que la base tiene de verdad.
docker compose exec db psql -U postgres certcore -c '\d+ certificates'

# Lo que las migraciones dicen que debería tener.
grep -rn "certificates" server/database/migrations/
```

Las divergencias típicas, en orden de frecuencia: un índice creado a mano durante un incidente y nunca versionado; una columna añadida con `ALTER TABLE` en caliente; un `DEFAULT` cambiado; un tipo ampliado (`varchar(50)` → `varchar(255)`).

> ⚠️ **Un `php artisan migrate:fresh` sobre una base con divergencias reconstruye el esquema de las migraciones, no el real.** En desarrollo es lo que quieres; si alguna vez lo lees como *"así es producción"*, te estás mintiendo. La única fuente de verdad sobre una base es la base.

---

## 🧭 Cuándo usar qué: qué absorbe y qué te deja ver

La tabla que se consulta de verdad. A la izquierda, la diferencia de dialecto; a la derecha, si el ORM te protege o no.

| Diferencia de dialecto | ¿La absorbe Eloquent? | Qué significa para be04 |
|---|---|---|
| **Comillas de identificadores** (`"tabla"` frente a `` `tabla` ``) | ✅ Sí, la gramática por driver | Ni te enteras |
| **Marcadores de parámetros** | ✅ Sí | Ni te enteras |
| **`LIMIT` / `OFFSET`** | ✅ Sí | Ni te enteras |
| **Booleanos** (`true` frente a `1`) | ✅ Sí, con el cast del modelo | Cuidado si el cast falta |
| **Autoincremento y secuencias** | ✅ Sí, salvo que siembres ids a mano | Ver be03 §5.4 |
| **Concatenación de cadenas** | ⚠️ Sólo si usas el constructor | En `DB::raw` va tal cual |
| **Funciones de fecha** (`date_trunc`, `age`, `NOW()`) | ❌ **No** | Aquí aparecen bugs |
| **Casts implícitos entre tipos** | ❌ **No** | **Aquí aparecen los peores** |
| **`RETURNING`** | ⚠️ Parcial: lo usa al insertar, no lo expone | Cuidado al escribirlo a mano |
| **Bloqueo (`FOR UPDATE`, `SKIP LOCKED`)** | ⚠️ `lockForUpdate()` sí; el resto, crudo | Raro en CertCore |
| **Tipos específicos (`jsonb`, arrays, rangos)** | ❌ **No** más allá de leer y escribir | Las consultas sobre `jsonb` son crudas |
| **`WITH OIDS` y demás sintaxis retirada** | ❌ **No** | Sólo puede estar en SQL crudo |

Y la regla que resume la tabla:

> 🧭 **Si la consulta la construyó el ORM, un cambio de versión mayor casi nunca te toca. Si la escribiste tú, te toca entera.** Por eso `SQL-CRUDO.txt` es el mapa de riesgo del sistema, y por eso cabe en una pantalla.

---

## ⚠️ Advertencias

**Este apéndice no dice que el SQL crudo esté mal.** Hay consultas que el constructor no sabe expresar, e informes donde escribir SQL es lo correcto. Lo que dice es que **cada línea de SQL crudo es una línea que no está protegida**, y que conviene saber cuántas hay y dónde. Un sistema con doce `DB::select()` localizados y documentados está mejor que uno con cero y una capa de abstracción que nadie entiende.

**Eloquent de la línea 5.8 no es el Eloquent que documenta internet.** Las versiones posteriores añadieron bastante —casos de uso de `jsonb`, `upsert`, mejoras en relaciones— y nada de eso está aquí. Si un ejemplo usa un método que no existe, no estás loco: estás leyendo documentación de Laravel 10.

**No generalices desde el laboratorio.** Con cinco filas, el N+1 no se ve, el índice ausente no se nota y `EXPLAIN` no dice nada. Las mediciones que valen son las de be05, con volumen. Las de aquí sirven para tener línea base, que es distinto.

---

## 📚 Referencias

- https://laravel.com/docs/5.8/eloquent — Eloquent en su versión contemporánea a Lumen 5.8. ⚠️ Es documentación de **Laravel**: lo del ORM aplica tal cual; lo de facades y arranque, no (ver [`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md)).
- https://laravel.com/docs/5.8/eloquent-relationships — relaciones y carga ansiosa (`with`), que es el arreglo del N+1.
- https://laravel.com/docs/5.8/queries — el constructor de consultas, incluidos `DB::select`, `DB::raw` y `DB::statement`.
- https://www.postgresql.org/docs/16/sql-explain.html — `EXPLAIN` y `EXPLAIN ANALYZE`, que es como se comprueba si una consulta hace lo que crees.
- https://www.postgresql.org/docs/16/functions-json.html — las funciones de `jsonb`, que Eloquent 5.8 no envuelve y que en CertCore hacen falta para `items` y `answers`.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos, y **comprueba siempre la versión en la URL**: `laravel.com/docs/5.8` y `laravel.com/docs/12.x` describen dos ORM parecidos y no iguales.

---

## 🧪 Ejercicios (8)

Todos con el laboratorio levantado, y **todos con el SQL real sacado del log o de `toSql()`**, nunca supuesto.

1. Activa `DB::listen` y pide `GET /templates`. Pega el SQL literal y sus *bindings*. ¿Coincide con el que habrías escrito a mano? Anota las diferencias.
2. **Diagnóstico.** Compón `Template::active()` con un `orWhere` externo y saca el `toSql()`. ¿Dónde quedaron los paréntesis? Arréglalo encerrando el scope en una clausura y compara los dos SQL.
3. Provoca un N+1 recorriendo las inspecciones y pidiendo sus hallazgos. Cuenta las consultas con `DB::getQueryLog()`. Después usa `with()` y vuelve a contar. Anota los dos números.
4. **Diagnóstico.** Escribe `$certificate->statuss` (con doble ese) en un `if` y comprueba qué pasa. Después busca en `server/app/` si hay algún acceso a atributo que no corresponda a ninguna columna. Es un `grep` incómodo: explica por qué.
5. Corre el `grep` de SQL crudo, genera `SQL-CRUDO.txt` y clasifica cada aparición en tres columnas: qué hace, por qué crees que no se usó el constructor, y **qué le pasaría si la base cambiara de versión mayor**. Guarda el archivo: be04 lo usa entero.
6. **Diagnóstico.** Intenta `Template::find('elevator-annual-v2')` y explica el resultado con la sección de claves compuestas en la mano. Después escríbelo de la forma que sí funciona.
7. Compara `\d+ certificates` con lo que dicen las migraciones. Anota cada divergencia, y para cada una escribe una hipótesis de cómo apareció.
8. **Diagnóstico.** Escribe la misma consulta —los certificados vencidos— de tres formas: con el constructor, con `DB::raw` en un fragmento, y con `DB::select` entera. Saca el SQL de las tres y responde: ¿cuál sobrevive intacta a un cambio de versión mayor, y por qué? Esa respuesta es la tesis de be04 en una línea.

---

> 🏷️ **Este apéndice no lleva tag propio.** El código que explica lo escriben las fases, así que lo que salga de leerlo se commitea con su prefijo (`be03: …`, `be04: …`). Dos salidas conviene conservarlas porque otras fases las citan: `SQL-CRUDO.txt` del ejercicio 5 —que es el mapa de riesgo que be04 consume— y el par de números del ejercicio 3, en el mensaje de un tag anotado (`ej/bea-04/3`). La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
MDEOF
wc -l bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md

# --- 2026-09-11T18:23:13 · Write be04 phase
cat > be04-el-salto-de-version-que-nadie-corrio.md <<'MDEOF'
# 📅 Fase be04 — El salto de versión que nadie corrió

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Fase be04 de be07 · **10 horas**
> Depende de: **be03 cerrada** (`smoke.sh` en `24/24` contra PostgreSQL) · Habilita: be05
> Apéndices de apoyo: [`bea-05`](bea-05-dialectos-y-saltos-de-version-en-postgresql.md) · [`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md) ⭐ · [`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md) · [`bea-02`](bea-02-receta-de-imagen-y-compose.md) · Incidentes asociados: **be-06** ⭐, **be-07**, **be-08**
> Estilo de esta fase: **investigación.** Se escribe poco código y se leen muchas notas de release

> 🔥 **Esta fase pertenece al track opcional de backend.** El track base se completa sin abrirla.

---

## 🎯 1. Propósito

Investigar un incidente cuyo `git log` está vacío.

Durante quince fases del track base y tres de éste, tu reflejo ante un fallo ha sido el mismo: buscar el cambio. `git log`, `git blame`, `git bisect`, el diff entre dos tags. Esta fase existe para romper ese reflejo una vez, en un entorno controlado, **porque la causa no está en el repositorio y no hay forma de que lo esté.**

> 🧠 **A la infraestructura sí la actualizan. A la aplicación no.** La base tenía dueño —un proveedor gestionado, una auditoría, un calendario ajeno— y subió cuatro veces en ocho años. La aplicación no tenía dueño y sigue en 2016.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `EVIDENCIA-VERSIONES.md` existe y reconstruye los **cuatro escalones** con fecha y con la evidencia que sostiene cada uno. Ninguna fecha viene de la memoria de nadie.
- [ ] Recorriste la cadena **en tu laboratorio**: `POSTGRES_TAG` en `9.6`, `11`, `13` y `16`, sembrando en cada escalón, y anotaste qué se rompió en cada uno.
- [ ] Las rupturas están **verificadas contra las notas de release oficiales**, con la cita y la URL. Las que resultaron ser falsas también están anotadas **como falsas** — y son dos.
- [ ] `SQL-CRUDO.txt` (de [`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md) §ejercicio 5) está cruzado con las rupturas: para cada consulta cruda, si le afecta o no y por qué.
- [ ] La **predicción sellada de be02** (ejercicio 21) está abierta y comparada con lo que pasó de verdad.
- [ ] Sabes explicar, sin mirar, **por qué `git log` no muestra nada** y qué habrías tenido que mirar en su lugar desde el primer minuto.
- [ ] La cicatriz de las fechas (💸 4) está diagnosticada: sabes qué se perdió, dónde, y qué costaría arreglarlo — **sin arreglarlo**.

---

## 🚫 3. Qué NO entra todavía

- **Migrar las columnas a `TIMESTAMPTZ`.** Se diagnostica, se costea y se difiere: tocar el tipo de una columna de fechas sobre ocho años de datos es el mismo problema que la invariante de be05, y se hace una vez, allí, con procedimiento.
- **La invariante de plantillas** → be05.
- **`pg_upgrade` de verdad.** En el laboratorio la versión cambia con una línea y un volumen nuevo. Se explica cómo sería en producción y **no se ejecuta**: ver la advertencia grande de §5.4, que es contenido y no un atajo.
- **Las pruebas** → be06.
- **Subir PHP.** Sigue siendo la premisa, no un pendiente.

---

## 🧠 4. Concepto mínimo

### El ticket, y por qué no se parece a un ticket

> **OPS-4412 · Prioridad media.** *"El informe mensual de certificados vencidos lleva fallando desde el fin de semana. No hemos desplegado nada. El equipo de infraestructura dice que no tocaron nada tampoco."*

Dos frases que en cualquier otro contexto serían ruido —*"no hemos desplegado nada"*, *"no tocaron nada"*— y que aquí son **las dos pistas buenas**, porque las dos son ciertas.

🪞 **Tu instinto dice `git log`… y esta vez se equivoca.** Vas a hacer lo que haces siempre: `git log --since`, `git blame` sobre el informe, revisar el último despliegue, comparar los dos últimos tags. Y no vas a encontrar nada, **porque no hay nada**. El árbol de fuentes no cambió. El cambio está en una línea de un archivo que no es código:

```bash
# .env — La versión de la base vive AQUÍ, fuera del código fuente.
POSTGRES_TAG=16.9
```

> 🧭 **Lo que no está en el repositorio también despliega.** Un `.env`, una variable del entorno gestionado, un tag de imagen, una política del proveedor. Cuando un incidente no aparece en ningún log de git, la pregunta correcta deja de ser *"¿quién lo tocó?"* y pasa a ser **"¿qué parte de este sistema no es código?"**.

### Quién subió la base, y la ironía que pone el dominio

No fue un fantasma y no fue negligencia: fue un calendario ajeno. El proveedor gestionado anunció fin de soporte de la versión mayor, dio una ventana de mantenimiento, y subió. Hay un correo. Alguien lo archivó.

Y el motivo de fondo lo pone el propio negocio, con una ironía que no hubo que inventar: fue una **auditoría de cumplimiento** la que exigió correr sobre versiones soportadas.

> 🧠 **La certificadora no pasaba su propia auditoría.** La empresa que emite certificados de conformidad corría su sistema sobre componentes fuera de soporte. Lo que arregló la base —una auditoría con poder— es exactamente lo que nunca se aplicó a la aplicación.

### Los dos matices que evitan el cuento, y son obligatorios los dos

**Matiz 1 — nada se rompió a lo grande, y ése es el problema.**

> 🧠 **Postgres es extraordinariamente bueno en compatibilidad hacia atrás. El 95% siguió funcionando y por eso nadie miró. La calidad de la compatibilidad es lo que permitió el abandono.**

No hay villano. Cuatro versiones mayores, ocho años, y la aplicación no se enteró casi de nada. Si se hubiera roto entera en 2019, alguien habría tenido que mirarla — y hoy no estaríamos aquí. 🩻 La sección *"esto sí funciona igual"* de [`bea-05`](bea-05-dialectos-y-saltos-de-version-en-postgresql.md) es larga a propósito: el SQL estándar, el protocolo de cable y los tipos básicos aguantan sin despeinarse.

**Matiz 2 — la factura la paga el código que se saltó las convenciones.**

> 🧠 **Eloquent absorbe casi todos los cambios de dialecto. Lo que no absorbe es el `DB::select()` con SQL a mano que alguien escribió para ir más rápido.**

Y eso, para diagnosticar, es un regalo: **ya tienes la lista**. `SQL-CRUDO.txt` salió del ejercicio 5 de `bea-04`, y la predicción que sellaste en be02 decía en qué archivos iban a aparecer los bugs. Esta fase es donde se abre el sobre.

### Dos de las tres pistas que traías son falsas

Esto es lo más forense de la fase, así que se dice antes de empezar: **al verificar contra las notas de release, dos de las sospechas habituales se caen.**

| Sospecha | Veredicto | Por qué |
|---|---|---|
| *"Se rompió el escapado manual de comillas"* | ❌ **Falsa en esta cadena** | `standard_conforming_strings` pasó a `on` por defecto en **PostgreSQL 9.1 (2011)**, cinco años antes de que naciera este sistema. El escapado defensivo que ves en el código es una **cicatriz heredada** de quien vivió aquel cambio, no algo que se rompiera aquí |
| *"Postgres retiró los casts implícitos"* | ❌ **Falsa en esta cadena** | La retirada masiva de casts implícitos a `text` fue de **PostgreSQL 8.3 (2008)**. Los `::text` explícitos repartidos por el SQL crudo son de la misma familia: reflejos de una época anterior |
| *"`WITH OIDS` dejó de existir"* | ✅ **Cierta, PG 12** | Y está verificada abajo, con cita |

> 🧭 **Una pista heredada que nadie verificó es indistinguible de una pista buena.** Las dos falsas de arriba circulan en foros desde hace quince años y suenan razonables. Verificarlas cuesta diez minutos; no verificarlas cuesta media fase buscando en el sitio equivocado. **Esto es la fase entera en una tabla.**

---

## 💻 5. Código mínimo con comentarios

### 5.1 La tabla de evidencia

No se construye con recuerdos. Cada fila tiene que apoyarse en algo que se pueda enseñar.

| Escalón | Cuándo subió | Evidencia que lo prueba | Dónde está |
|---|---|---|---|
| **9.6** | 2016 | El `composer.lock` inicial y el primer `compose.yaml` | Repositorio |
| **11** | 2019 | El correo de fin de soporte del proveedor | Buzón de alguien |
| **13** | 2021 | La ventana de mantenimiento en el calendario de operaciones | Fuera del repositorio |
| **16** | 2024 | `SELECT version();` **hoy**, y el `POSTGRES_TAG` actual | La base y el `.env` |

Y el procedimiento para reconstruirla cuando no tienes ni el correo ni el calendario —que es lo normal—, en orden de coste:

```sql
-- 1. Qué corre AHORA. Es el único dato que nadie puede discutir.
SELECT version();

-- 2. Cuándo se creó el clúster: una cota inferior para la última subida.
SELECT pg_postmaster_start_time();   -- sólo dice el último arranque
-- Mejor, si tienes acceso al directorio de datos:
--   docker compose exec db cat /var/lib/postgresql/data/PG_VERSION
```

```bash
# 3. Los artefactos que envejecen y delatan la ÉPOCA en que se escribieron:
grep -rn "pg_start_backup\|pg_xlog\|pg_switch_xlog" server/ scripts/ 2>/dev/null
#    → un script que usa nombres retirados en PG 10 se escribió ANTES de PG 10

grep -rn "WITH OIDS\|oids=true" server/ 2>/dev/null
#    → sintaxis imposible desde PG 12: data el código antes de 2019
```

> 💡 **Un artefacto que usa una sintaxis retirada es un fósil datable.** No te dice cuándo se subió la base; te dice **antes de qué versión se escribió ese archivo**, que muchas veces es la única fecha fiable que vas a conseguir.

### 5.2 El recorrido, en tu laboratorio

La cadena se reproduce entera cambiando una línea. Cada escalón: volumen nuevo, migraciones, siembra, `smoke.sh`, y anotar.

```bash
# ── Escalón 1: como en 2016 ────────────────────────────────────────────────
sed -i '' 's/^POSTGRES_TAG=.*/POSTGRES_TAG=9.6/' .env    # (en Linux: sed -i 's/…/')
docker compose down -v && docker compose up -d
docker compose exec api php artisan migrate --seed
BASE_URL=http://localhost:3000 ./smoke.sh | tail -1
docker compose exec db psql -U postgres certcore -c 'SELECT version();'

# ── Escalones 2, 3 y 4: idéntico, con 11, 13 y 16.9 ───────────────────────
```

Y la anotación, que es el entregable:

| Escalón | `smoke.sh` | Qué se rompió | ¿Lo absorbió el ORM? |
|---|---|---|---|
| 9.6 | | | |
| 11 | | | |
| 13 | | | |
| 16.9 | | | |

> ⚠️ **Tu laboratorio no reproduce producción, y la diferencia importa.** Aquí cada escalón empieza con un **volumen nuevo** (`down -v`): es un clúster recién creado. En producción el proveedor hizo `pg_upgrade` o un `dump`/`restore` **sobre el clúster existente**, y hay al menos una ruptura que se comporta distinto según cuál de las dos cosas hagas — la de PG 15, en §5.3. Anota esta diferencia en `EVIDENCIA-VERSIONES.md` antes de sacar conclusiones: **un laboratorio que no sabe en qué difiere del sistema real produce diagnósticos con mucha confianza y poca validez.**

### 5.3 Lo que se rompió de verdad, con cita

Cuatro rupturas, las cuatro verificadas contra las notas de release oficiales el 11/09/2026. El desarrollo completo está en [`bea-05`](bea-05-dialectos-y-saltos-de-version-en-postgresql.md); aquí va lo que esta fase necesita.

**PG 10 (escalón de 2019) — el vocabulario del WAL cambió de nombre.**

> *"Rename write-ahead log directory `pg_xlog` to `pg_wal`, and rename transaction status directory `pg_clog` to `pg_xact`"* · *"Rename SQL functions, tools, and options that reference "xlog" to "wal". For example, `pg_switch_xlog()` becomes `pg_switch_wal()`"*

**A la aplicación no le afectó nada.** Al script de respaldo de 2016, sí — y nadie lo notó hasta que hizo falta restaurar. Es el patrón más peligroso del oficio: **lo que se rompe primero es lo que sólo se usa en emergencias.**

**PG 12 (escalón de 2021) — `WITH OIDS` y los tipos que se fueron.**

> *"Previously, a normally-invisible `oid` column could be specified during table creation using `WITH OIDS`; that ability has been removed. […] Operations on tables that have columns created using `WITH OIDS` will need adjustment."*

Y en la misma versión, dos que golpean a código de 2016 con más frecuencia de la que nadie espera:

> *"Remove obsolete data types `abstime`, `reltime`, and `tinterval`. Use the SQL-standard types such as `timestamp` instead."*
> *"Remove deprecated `pg_constraint.consrc` and `pg_attrdef.adsrc` columns"* — quien introspeccionaba el esquema con esas columnas se quedó sin ellas.

**PG 14 (dentro del escalón de 2024) — la autenticación.** El valor por defecto de `password_encryption` pasó a `scram-sha-256`, y un cliente con `libpq` anterior a la 10 no lo habla. Aquí **no rompió** —la `libpq 13` de la imagen sí lo habla, verificado el 8/09/2026—, y conviene saber por qué no rompió tanto como por qué podría haberlo hecho.

**PG 15 (dentro del escalón de 2024) — el esquema `public` dejó de ser de todos.**

> *"Remove `PUBLIC` creation permission on the `public` schema […] The change applies to new database clusters and to newly-created databases in existing clusters. Upgrading a cluster or restoring a database dump will preserve `public`'s existing permissions."*

Léelo dos veces, porque es la ruptura más interesante de la cadena: **en tu laboratorio muerde** —creas clústeres nuevos— **y en la producción de CertCore no mordió**, porque allí se actualizó el clúster existente. Dos sistemas, la misma versión, comportamientos distintos, y la diferencia está en cómo llegaste a ella, no en dónde estás.

Y de la misma versión, la que se lleva al script de respaldo otra vez:

> *"Remove long-deprecated exclusive backup mode. Functions `pg_start_backup()`/`pg_stop_backup()` have been renamed to `pg_backup_start()`/`pg_backup_stop()`"*

> 🧠 **El mismo archivo se rompió dos veces, en PG 10 y en PG 15, y nadie se enteró ninguna de las dos.** Un script de respaldo sólo falla el día que hay que restaurar. Si esta fase te deja una sola cosa aplicable a tu trabajo real, que sea ésta: **los artefactos de emergencia hay que ejercitarlos en calma, porque son los que más envejecen y los únicos cuyo fallo no avisa.**

### 5.4 El cruce con `SQL-CRUDO.txt`

Aquí se comprueba el matiz 2, y se comprueba con números.

```bash
# Para cada consulta cruda, ¿usa algo que cambió?
grep -n "pg_xlog\|WITH OIDS\|abstime\|reltime\|consrc\|adsrc\|pg_start_backup" SQL-CRUDO.txt
```

Y la tabla que sale:

| Consulta cruda | Archivo | ¿Le afecta? | Qué versión |
|---|---|---|---|
| | | | |

La conclusión que buscas es un cociente: **cuántas de las consultas construidas por Eloquent se rompieron, frente a cuántas de las escritas a mano.** Si la primera cifra es cero, acabas de medir exactamente lo que el ORM te estaba comprando durante ocho años — que es, de paso, el argumento más honesto a favor de usar uno.

### 5.5 La cicatriz de las fechas (💸 4)

Esto no es una ruptura de versión: es un defecto de diseño de 2016 que **ninguna subida arregló ni empeoró**, y que produce el bug más famoso del track base.

```sql
-- La columna es `timestamp` SIN zona. Mira qué guardó de verdad:
SELECT id, valid_until, pg_typeof(valid_until) FROM certificates LIMIT 3;
--   valid_until        | timestamp without time zone
--   2024-06-30 12:00:00    ← el "-05:00" del db.json SE PERDIÓ, en silencio
```

El JSON traía `2024-06-30T12:00:00-05:00`. La columna se quedó con `2024-06-30 12:00:00` **sin ninguna indicación de zona**, así que el mismo instante significa cosas distintas según quién lo lea: PHP lo interpreta con el TZ del contenedor, el navegador con el del usuario, y `now()` en la base con el del servidor.

> 🧠 **Una fecha sin zona no es una fecha ambigua: es una fecha que significa cosas distintas según quién la lea, y ninguna lectura es detectablemente errónea.** De ahí sale, literalmente, *"venció ayer para el servidor y vence hoy para el navegador"* de la Fase 10 del track base. El desarrollo completo —`AT TIME ZONE`, el TZ del contenedor, `America/Bogota`, y la vigencia como intervalo— está en [`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md).

```
💸 DEUDA TÉCNICA INTENCIONAL — timestamp sin zona, diagnosticada y no pagada
Lo correcto es TIMESTAMPTZ en las seis columnas de fecha con hora. El cambio
de tipo es una sola sentencia por columna... y reescribe la tabla entera, con
bloqueo, sobre datos cuya zona de origen hay que ASUMIR (-05:00) porque no
está guardada en ningún sitio.
NO SE PAGA EN ESTA FASE, a propósito: es el mismo problema de procedimiento
que la invariante de be05 —cambiar algo estructural sobre ocho años de datos
sin tumbar producción—, y el track lo enseña UNA vez, allí, completo.
Aquí se diagnostica, se costea y se anota en `bea-10`.
```

**Prueba de fuego**

Con la base en `16.9` y el sistema sembrado, corre esto:

```bash
docker compose exec db psql -U postgres certcore -c \
  "SELECT now(), current_setting('TimeZone');"
docker compose exec api php -r 'echo date_default_timezone_get(), " ", date("c"), "\n";'
```

Si las dos zonas no coinciden, acabas de reproducir la cicatriz **sin tocar una línea de código**: el mismo certificado vence en dos momentos distintos según quién pregunte. Y si coinciden, cámbiale el TZ al contenedor de PHP y repite — porque en producción nadie te garantiza que coincidan, y ése es el punto.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Buscar el cambio en el repositorio hasta agotarlo.**
*Síntoma:* cuarenta minutos de `git log`, `git blame` y `git bisect` sin un solo candidato.
*Causa:* el reflejo correcto aplicado a un sistema donde parte de la configuración vive fuera del árbol de fuentes.
*Fix mínimo:* pon un límite. **Diez minutos de git y, si no hay candidato, cambia de pregunta**: *¿qué de esto no es código?* — el `.env`, la imagen, la versión de la base, una política del proveedor, un certificado que caducó.

**Citar una ruptura de memoria.**
*Síntoma:* escribes "los casts implícitos se retiraron en la 12" y encima suena bien.
*Causa:* la sospecha circula desde hace quince años y nadie la verifica.
*Fix mínimo:* la nota de release, con URL y versión, o no entra en el documento. En esta fase eso no es rigor académico: **dos de las tres pistas que traías eran falsas**, y con ellas habrías buscado en el sitio equivocado.

**Confundir "no se rompió" con "no le afectó".**
*Síntoma:* das por bueno un escalón porque el `smoke.sh` sigue verde.
*Causa:* el juez del contrato comprueba el contrato, y hay cosas —el script de respaldo, un informe mensual, un trabajo programado— que no pasan por ninguna ruta HTTP.
*Fix mínimo:* haz la lista de lo que **no** cubre el `smoke.sh` antes de declarar un escalón limpio. Esa lista es, casi exactamente, la lista de lo que va a fallar en el peor momento.

**Arreglar las fechas "ya que estamos".**
*Síntoma:* un `ALTER TABLE ... TYPE timestamptz` en medio de la investigación.
*Causa:* está claro cuál es el arreglo y parece barato.
*Fix mínimo:* revierte. Cambiar el tipo reescribe la tabla, asume una zona de origen que no está guardada, y mezcla dos cosas en el mismo cambio: la investigación y la corrección. **Primero se sabe qué pasó; después se decide qué hacer.**

### Pieza forense de esta fase ⭐

**El incidente cuyo `git log` está vacío.**

El informe mensual falla. Nadie desplegó. Nadie tocó nada. Y las dos afirmaciones son ciertas.

La ruta, en cinco pasos, y el valor está en el **orden**:

1. **Reproduce y acota.** ¿Falla siempre o sólo el informe? ¿Desde cuándo exactamente? El "desde el fin de semana" del ticket es la pista de calendario y hay que fecharla con precisión: la primera ejecución fallida es una hora concreta, y esa hora se compara con otras cosas que pasaron esa noche.
2. **Diez minutos de git, y se acabó.** `git log --since`, `git blame` sobre el informe. Si no hay candidato, **para**. No sigas por inercia.
3. **Cambia la pregunta: ¿qué de este sistema no es código?** El `.env`, el tag de la imagen, la versión de la base, la configuración del proveedor, un secreto que rotó, un certificado TLS que caducó. Esa lista se escribe una vez y sirve toda la vida.
4. **Pregúntale al sistema qué versión es.** `SELECT version();` y `docker compose exec db cat /var/lib/postgresql/data/PG_VERSION`. Compáralo con lo que creías. **Aquí termina el 90% de estas investigaciones.**
5. **Confirma con la nota de release**, no con la intuición: busca en la versión nueva la función o la sintaxis que usa el informe.

**Y lo que hace única a esta pieza:** el arreglo no tiene par `-roto`/`-fix`. No hay diff, no hay commit que revertir, no hay factura que leer con `git diff` entre dos tags. En un curso construido sobre el par `-roto`/`-fix` y el diff como factura de la deuda, **tener un incidente cuyo cambio no es código vale mucho** — porque en la vida real son un tercio de los incidentes y el curso, hasta ahora, no te había enseñado ninguno.

> 🧭 **Cuando el `git log` está vacío y el sistema falla, el sistema tiene razón.** Lo que falta es tu inventario de lo que puede cambiar sin pasar por un commit.

> 🧨 **Rompe a propósito y observa.** Cambia `POSTGRES_TAG` a `13.15`, deja el volumen existente (**sin** `-v`), y levanta. Pega el error literal —es el del ejercicio 7 de [`bea-02`](bea-02-receta-de-imagen-y-compose.md), y ahora ya sabes por qué—. Después responde tres cosas: qué dice exactamente el log del contenedor de la base, **por qué el directorio de datos no es compatible aunque el SQL sí lo sea**, y qué habría hecho falta en producción para pasar de 13 a 16 sin perder los datos. Esa tercera pregunta es `pg_upgrade` frente a `dump`/`restore`, y está en [`bea-05`](bea-05-dialectos-y-saltos-de-version-en-postgresql.md).

---

## 🧪 7. Ejercicios (32)

**🟢 Fácil (1–8)**

1. Corre `SELECT version();` y `cat /var/lib/postgresql/data/PG_VERSION`. Anota las dos salidas y explica en una línea por qué hay dos sitios donde preguntarlo.
2. Baja a `POSTGRES_TAG=9.6` con volumen nuevo, migra y siembra. Corre el `smoke.sh` y anota el resultado.
3. **Diagnóstico.** Recorre los cuatro escalones y rellena la tabla de §5.2. Anota el resultado del `smoke.sh` en cada uno.
4. Busca en las notas de release de PG 12 el párrafo de `WITH OIDS` y cópialo literal en `EVIDENCIA-VERSIONES.md`, con la URL.
5. **Diagnóstico.** Busca `pg_xlog`, `pg_start_backup` y `WITH OIDS` en todo el proyecto. Para cada resultado, di **antes de qué versión** se escribió ese archivo.
6. Corre la comprobación de zonas de la prueba de fuego y anota las dos salidas. ¿Coinciden?
7. Abre la predicción sellada de be02 (ejercicio 21) y compárala con lo que encontraste. Anota los aciertos y los fallos, sin corregir la predicción.
8. Lista tres cosas del sistema que pueden cambiar **sin pasar por un commit**. Después amplíala a diez con ayuda de [`bea-02`](bea-02-receta-de-imagen-y-compose.md).

**🟡 Intermedio (9–20)**

9. **Diagnóstico.** Reproduce el incidente OPS-4412 completo con los cinco pasos de §6 y cronometra cada uno. ¿Cuánto tardaste en abandonar git? Sé honesto: ése es el número que mide el reflejo.
10. Verifica las dos pistas falsas de §4 contra las notas de release. Cita versión, fecha y URL de cada una. Escribe en una línea por qué las dos siguen circulando.
11. **Diagnóstico.** Crea una tabla con `WITH OIDS` bajo 9.6, siembra, y sube a 11 y a 13. ¿En cuál falla exactamente, y con qué mensaje?
12. Cruza `SQL-CRUDO.txt` con las cuatro rupturas y rellena la tabla de §5.4. Calcula el cociente entre consultas del ORM rotas y consultas crudas rotas.
13. **Diagnóstico.** Con la base en 15 o superior y un clúster nuevo, intenta crear una tabla con un usuario que no sea el propietario. Pega el error. Después explica por qué en la producción de CertCore ese error **no** apareció.
14. Escribe el script de respaldo de 2016 —con `pg_start_backup()`— y ejecútalo contra 9.6 y contra 16.9. Anota los dos resultados y la versión en la que dejó de funcionar.
15. **Diagnóstico.** Con la base en 9.6, comprueba qué `password_encryption` usa por defecto; repítelo en 16.9. Explica por qué el cambio no rompió nada aquí y en qué escenario sí habría roto.
16. Reconstruye `EVIDENCIA-VERSIONES.md` entero, con las cuatro filas y su evidencia. Marca explícitamente qué fila se apoya en un artefacto y cuál en un testimonio.
17. **Diagnóstico.** Mide el mismo `EXPLAIN ANALYZE` de `GET /inspections` (be03, ejercicio 19) en 9.6 y en 16.9. ¿Cambió el plan? ¿Cambió el tiempo? Anótalo aunque no cambie nada.
18. Escribe la consulta que demuestra que el offset `-05:00` se perdió al sembrar, comparando el `db.json` con lo que hay en la tabla.
19. **Diagnóstico.** Cambia el TZ del contenedor de PHP a `UTC` y vuelve a abrir la pantalla de certificados. Anota cuántos cambiaron de estado **sin que nadie tocara un dato**.
20. Haz la lista de lo que el `smoke.sh` **no** cubre. Compárala con la lista de lo que se rompió de verdad en la cadena.

**🟠 Difícil (21–27)**

21. **Diagnóstico.** Escribe el post-mortem de OPS-4412 con el formato del track base: qué pasó, cómo se detectó, cuánto tardó el diagnóstico, **cuál fue el paso que más tiempo desperdició** y qué habría que cambiar para que la próxima vez cueste diez minutos.
22. Costea la migración de las seis columnas de fecha a `TIMESTAMPTZ`: cuántas filas, qué bloqueo, qué zona hay que asumir y en qué se apoya esa suposición, y qué se rompería en el frontend. **No la ejecutes.** Guarda el costeo: es un insumo de be07.
23. **Diagnóstico.** Diseña el procedimiento de subida de versión que CertCore no tuvo: qué se comprueba antes, qué se ejecuta, qué se verifica después, y quién decide. Una página. Después responde lo incómodo: **¿qué de ese procedimiento habría detectado el fallo del script de respaldo?**
24. Reproduce la diferencia clúster-nuevo / clúster-actualizado con la ruptura de PG 15: en una base nueva y en una restaurada desde un `dump` de la anterior. Documenta los dos comportamientos.
25. **Diagnóstico.** Encuentra en el sistema **otro** artefacto que sólo se use en emergencias y que nadie haya ejercitado. Compruébalo. Si funciona, di desde cuándo no se probaba y cómo lo sabes.
26. Escribe el correo que el proveedor mandó en 2024 anunciando la subida, tal como te gustaría haberlo recibido: qué tendría que haber dicho para que alguien en CertCore actuara. Después responde lo difícil: **¿lo habría leído alguien igualmente?** Y si no, ¿qué canal sí habría funcionado?
27. **Diagnóstico adversarial.** Alguien propone fijar la versión de la base *"para que esto no vuelva a pasar"*. Escribe la respuesta en dos párrafos: qué problema resuelve de verdad, qué problema **crea** (pista: el runtime de PHP de este mismo proyecto lleva fijado desde 2019), y cuál es la política que sí funciona.

**🔴 Muy difícil (28–32)**

28. **Diagnóstico.** Reconstruye la cadena entera sin usar ninguna fuente externa al sistema: sólo artefactos, código y datos. Después compárala con la tabla de §5.1 y anota qué escalón no pudiste fechar y por qué.
29. Escribe la sección *"lo que no es código"* del `HOTFIX.md` de la Fase 13 del track base: el inventario de todo lo que puede cambiar sin un commit en un sistema como CertCore, con cómo se comprueba cada cosa. **Es el único entregable de esta fase que te sirve en un sistema que no sea CertCore.**
30. **Diagnóstico.** Simula el escalón que no ocurrió: sube la aplicación de Lumen 5.8 a 6.0 en una rama y anota cada ruptura. Compara el número de rupturas con las cuatro de la base en ocho años. **Ese contraste es el argumento central del track**, y ahora lo tienes medido.
31. Con todo lo medido, escribe una página para la dirección titulada *"por qué la base está al día y la aplicación no"*. Sin culpables, con mecanismos. Tiene que poder leerla alguien que no sabe qué es Postgres.
32. **Diagnóstico adversarial.** Un consultor afirma que la subida de la base fue temeraria y que el proveedor debería responder por el incidente. Desmóntalo con las notas de release en la mano —qué se rompió de verdad, cuánto, y qué lo permitió—, y después **concede lo que tiene razón**: hubo una comunicación que no funcionó. ¿De quién era la responsabilidad de que funcionara?

**🔥 Opcionales**

- 🔥 Ejecuta un `pg_upgrade` de verdad entre dos escalones, fuera del flujo del laboratorio. Mide el tiempo de parada y compáralo con `dump`/`restore` sobre los mismos datos.
- 🔥 Monta una comprobación automática que compare la versión de la base con la esperada y falle ruidosamente si no coinciden. Después argumenta dónde debería vivir: en el arranque de la aplicación, en el `smoke.sh`, o en la supervisión.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/release/10.0/ — las notas de la 10, con el cambio de `pg_xlog` a `pg_wal` y el renombrado de funciones. Verificado el 11/09/2026.
- https://www.postgresql.org/docs/release/12.0/ — `WITH OIDS`, los tipos `abstime`/`reltime`/`tinterval`, y `consrc`/`adsrc`. Verificado el 11/09/2026.
- https://www.postgresql.org/docs/release/15.0/ — el permiso de creación en el esquema `public` y el fin del modo de respaldo exclusivo. Verificado el 11/09/2026.
- https://www.postgresql.org/support/versioning/ — la política de versiones: cinco años de soporte por versión mayor, y una mayor al año. Es el calendario ajeno que movió esta historia.
- https://www.postgresql.org/docs/16/pgupgrade.html — `pg_upgrade`, para el ejercicio 🔥 y para entender qué hizo el proveedor.

**Libros / artículos de referencia**
- *Database Reliability Engineering* (Campbell y Majors, O'Reilly, 2017), capítulos sobre gestión del cambio y sobre *release management* — el marco de por qué la infraestructura tiene calendario y las aplicaciones no.
- *The Field Guide to Understanding Human Error* (Sidney Dekker, 4.ª ed., 2023) — para escribir el post-mortem del ejercicio 21 sin culpables. El correo archivado no es negligencia de nadie: es un sistema de comunicación que no funcionó.

**Video / apoyo**
- https://www.youtube.com/results?search_query=postgresql+major+version+upgrade+strategy — charlas sobre estrategias de subida en producción. Busca las que hablen de ventanas y de vuelta atrás, no las que enseñan el comando.

**Orden de lectura sugerido:** [`bea-05`](bea-05-dialectos-y-saltos-de-version-en-postgresql.md) **antes** de recorrer la cadena, para saber qué mirar → las notas de release **durante**, una por escalón, y sólo la sección de migración → [`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md) **cuando llegues a §5.5**, no antes → Dekker **después**, para el post-mortem.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. Y una advertencia propia de esta fase: **las notas de release de PostgreSQL son largas y sólo interesa la sección "Migration to Version X"**, que está siempre al principio. Todo lo demás son mejoras, y ninguna mejora te rompe nada.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Reconstruiste una cadena de ocho años sin un solo commit que la documentara, verificaste cuatro rupturas contra las notas oficiales, descartaste dos sospechas heredadas que llevaban quince años circulando, y mediste lo que un ORM te estaba comprando sin que nadie lo hubiera agradecido nunca.

Y dejaste una cosa diagnosticada y sin arreglar, otra vez a propósito: las fechas sin zona. Está costeada, está anotada, y su corrección es un procedimiento —cambiar algo estructural sobre ocho años de datos sin tumbar producción— que el track enseña **una vez**, entero, en la fase siguiente.

**be05** es el paso natural y es la fase insignia. Vas a mirar de frente la invariante que sostiene el sistema entero —*una inspección se lee siempre contra la versión de plantilla que estaba vigente cuando se ejecutó*— y a descubrir que **ninguna restricción de la base la sostiene**. El bug estrella del track base, el de la Fase 7, nunca fue del frontend.

> **La señal de que quedó bien:** *"el `git log` estaba vacío, dejé de buscar a los diez minutos, y encontré la causa preguntándole al sistema en vez de al repositorio."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-04-el-salto-de-version-que-nadie-corrio \
>   -m "be04 cerrada: cadena 9.6->11->13->16 recorrida en el laboratorio;
> cuatro rupturas verificadas contra las notas de release y dos sospechas descartadas;
> SQL-CRUDO.txt cruzado; cicatriz de fechas diagnosticada y costeada sin pagar"
> ```
>
> Los commits de esta fase llevan `be04: …` y los de ejercicio `be04 ej22: …`.
>
> Y esta fase tiene algo propio que decir sobre git, que es justo lo contrario de lo habitual: **el incidente `be-06` no tiene par `-roto`/`-fix`.** El "cambio" que lo provocó es una línea de un archivo que no es código, así que no hay diff que enseñar ni convención de tags que aplicar. Es la única excepción declarada del track, y está prevista en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥. Lo que sí conviene etiquetar es el costeo del ejercicio 22 (`ej/be04/22`), porque be07 lo va a citar.

---

## 📌 Pendientes sugeridos

- **La migración a `TIMESTAMPTZ` queda costeada y sin ejecutar** (💸 4). Es deliberado: el procedimiento de cambio estructural sobre datos sucios se enseña completo en be05. → **be05** para el método, **`bea-10`** para el registro de la deuda, **be07** para el número.
- **El script de respaldo se rompió dos veces y nadie se enteró.** El hallazgo es más grande que esta fase: ningún artefacto de emergencia del sistema está ejercitado. → **be06**, junto con las pruebas; y una línea en el `HOTFIX.md` del track base (ejercicio 29).
- **No hay comprobación de la versión de la base en ningún sitio** (ejercicio 🔥). Dónde debería vivir es una decisión de diseño con tres respuestas defendibles. → **be06** si se decide que es una prueba, **be07** si se decide que es supervisión.
- **La diferencia entre el laboratorio y producción** —clúster nuevo frente a clúster actualizado— afecta al menos a una ruptura y podría afectar a más. Este track no puede reproducir `pg_upgrade` sin salirse de su alcance. → **Declarado como límite conocido** en `EVIDENCIA-VERSIONES.md` y en `bea-05`.
- **La subida de Lumen 5.8 → 6.0 del ejercicio 30 se queda en una rama.** Es material excelente y no cabe aquí. → **be07**, como dato duro de la opción 2 del *assessment*.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| **be-06** ⭐ | "El informe falla y no hemos desplegado nada" | Cambio fuera del repositorio · sin par `-roto`/`-fix` | 🔴 |
| **be-07** | "El respaldo de anoche no se puede restaurar" | Artefacto de emergencia envejecido | 🟠 |
| **be-08** | "El certificado dice que vence hoy y en el PDF dice ayer" | Fechas sin zona · TZ del contenedor | 🟠 |
MDEOF
wc -l be04-el-salto-de-version-que-nadie-corrio.md

# --- 2026-09-11T18:23:34 · Record verified dialect findings in propuesta
python3 - <<'PY'
p='prompts/propuesta-fases-backend.md'
s=open(p).read()
old = """**3. Los tags exactos de la cadena** (`9.6.x`, `11.x`, `13.x` ⚠️) — sigue abierta.
Solo afecta a la tabla de evidencia de `be04`, y se verifica contra las notas de
release oficiales al escribir esa fase."""
new = """**3. Los cambios de dialecto de la cadena — ✅ CERRADA el 11/09/2026 al escribir
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

**4. La versión de PHPUnit de la línea de Lumen 5.8** ⚠️ — sigue abierta. No la
necesita ninguna fase hasta `be06`, que es donde llegan las pruebas."""
assert old in s
s = s.replace(old,new,1)
# quitar el 4 duplicado que ya existía debajo
dup = """

**4. La versión de PHPUnit de la línea de Lumen 5.8** ⚠️ — sigue abierta. No la
necesita ninguna fase hasta `be06`, que es donde llegan las pruebas.

---

## ⏱️ 6. Presupuesto de horas"""
assert dup in s
s = s.replace(dup, """

---

## ⏱️ 6. Presupuesto de horas""",1)
open(p,'w').write(s)
print('ok')
PY

# --- 2026-09-11T18:25:19 · Write bea-05 appendix
cat > bea-05-dialectos-y-saltos-de-version-en-postgresql.md <<'MDEOF'
# 📎 Apéndice bea-05 — Dialectos y saltos de versión en PostgreSQL

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **4 horas**
> Usado por: **be04** ⭐ · Versiones cubiertas: la cadena **9.6 → 11 → 13 → 16**
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido.** Se entra con una pregunta —*"¿esto me afecta?"*, *"¿por qué no arranca con el volumen viejo?"*— y se sale con la respuesta y con la nota de release que la sostiene.

**Qué problema resuelve:** saber **qué cambia de verdad** entre versiones mayores de PostgreSQL, y por qué el 95% no cambia nada — que es justamente lo peligroso.

**Qué queda fuera:** replicación, alta disponibilidad y *tuning*; y la **ejecución real de un `pg_upgrade`**, que aquí se explica pero no se hace — en el laboratorio la versión se cambia con una línea del `.env` y un volumen nuevo ([`bea-02`](bea-02-receta-de-imagen-y-compose.md)), y la diferencia entre las dos cosas es contenido, no atajo.

---

## Índice

- [🩻 Esto sí funciona igual, y es casi todo](#-esto-sí-funciona-igual-y-es-casi-todo)
- [El directorio de datos no es compatible entre versiones mayores](#el-directorio-de-datos-no-es-compatible-entre-versiones-mayores)
- [`pg_upgrade` frente a `dump`/`restore`](#pg_upgrade-frente-a-dumprestore)
- [La autenticación: SCRAM desde PG 14](#la-autenticación-scram-desde-pg-14)
- [Las rupturas reales de esta cadena, con cita](#las-rupturas-reales-de-esta-cadena-con-cita)
- [Dos rupturas que todo el mundo cita y no son de esta cadena](#dos-rupturas-que-todo-el-mundo-cita-y-no-son-de-esta-cadena)
- [Cómo se lee una nota de release en diez minutos](#cómo-se-lee-una-nota-de-release-en-diez-minutos)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-9)

---

## 🩻 Esto sí funciona igual, y es casi todo

Esta sección es larga a propósito, porque es la que explica la historia de CertCore.

Entre PostgreSQL 9.6 (2016) y 16 (2023) hay siete versiones mayores, y lo que **no** cambió incluye prácticamente todo lo que una aplicación normal toca:

- **El SQL estándar.** `SELECT`, `JOIN`, `GROUP BY`, subconsultas, `CTE`, funciones de ventana: igual. Una consulta escrita en 2016 contra 9.6 corre hoy contra 16 sin tocarla.
- **El protocolo de cable.** Un cliente de la era 9.6 se conecta a un servidor 16 y se entiende con él (con el matiz de SCRAM, abajo).
- **Los tipos de datos de siempre.** `integer`, `text`, `varchar`, `numeric`, `date`, `timestamp`, `boolean`, `jsonb`: mismo comportamiento, mismo almacenamiento lógico.
- **Las restricciones.** `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `NOT NULL`: idénticas.
- **Las transacciones y los niveles de aislamiento.** Igual.
- **`EXPLAIN`.** Los planes mejoran —el planificador es más listo—, pero se leen igual.
- **La sintaxis de índices**, incluidos los parciales y los de expresión.

Lo que cambió es, casi siempre, **administración**: nombres de directorios y funciones de WAL, columnas de catálogo deprecadas, opciones de configuración, valores por defecto, tipos obsoletos de los años noventa.

> 🧠 **La calidad de la compatibilidad hacia atrás de PostgreSQL es lo que permitió el abandono de CertCore.** Paradoja real, sin villanos: si actualizar hubiera roto la aplicación en 2019, alguien habría tenido que mirarla. Como no rompió nada, nadie miró nunca — y ocho años después el problema no es la base, es todo lo demás.

---

## El directorio de datos no es compatible entre versiones mayores

La confusión más común de todas, y la que produce el error del ejercicio 7 de [`bea-02`](bea-02-receta-de-imagen-y-compose.md):

> **Que el SQL sea compatible no significa que el formato en disco lo sea.** Un directorio de datos creado por PG 15 **no arranca** bajo PG 16. El servidor se niega, y hace bien.

```
FATAL:  database files are incompatible with server
DETAIL: The data directory was initialized by PostgreSQL version 15,
        which is not compatible with this version 16.9.
```

El número que manda está en un archivo de una línea:

```bash
docker compose exec db cat /var/lib/postgresql/data/PG_VERSION
#   16
```

Y la consecuencia para el laboratorio: **cambiar `POSTGRES_TAG` sin cambiar el volumen no es una subida de versión, es un error de arranque.** La subida son dos pasos: `docker compose down -v` (volumen nuevo) y volver a migrar y sembrar. En producción eso no es una opción, y de ahí la sección siguiente.

---

## `pg_upgrade` frente a `dump`/`restore`

Las dos formas reales de subir de versión mayor sin perder los datos:

| | `pg_upgrade` | `dump` / `restore` |
|---|---|---|
| Qué hace | Reescribe los catálogos y **reutiliza los archivos de datos** (con `--link`, sin copiarlos) | Exporta todo a SQL y lo vuelve a insertar |
| Tiempo de parada | Minutos, casi independiente del tamaño | Horas, proporcional al tamaño |
| Riesgo | Con `--link`, **no hay vuelta atrás fácil**: los archivos se comparten | Bajo: el origen queda intacto |
| Efecto secundario | **Conserva permisos, propietarios y configuración del clúster** | Reconstruye desde cero lo que el volcado incluya |
| Cuándo | Bases grandes, ventanas cortas | Bases pequeñas, o cuando quieres empezar limpio |

La fila que más importa es la penúltima, y es la que explica una ruptura entera de [`be04`](be04-el-salto-de-version-que-nadie-corrio.md): el cambio de permisos del esquema `public` de PG 15 **sólo afecta a clústeres y bases nuevos**. Un `pg_upgrade` conserva los permisos existentes; un laboratorio con volumen nuevo, no.

> 🧭 **Dos sistemas en la misma versión pueden comportarse distinto según cómo llegaron a ella.** Es la clase de diferencia que hace que un diagnóstico correcto en tu máquina sea falso en producción — y al revés.

---

## La autenticación: SCRAM desde PG 14

Desde **PostgreSQL 14**, el valor por defecto de `password_encryption` es `scram-sha-256` en lugar de `md5`. Un cliente cuya `libpq` sea anterior a la 10 **no sabe hablar SCRAM** y falla al autenticarse, con un mensaje que no siempre lo dice claro.

```bash
docker compose exec db psql -U postgres -c "SHOW password_encryption;"
docker compose exec db psql -U postgres -c \
  "SELECT rolname, substring(rolpassword for 14) FROM pg_authid WHERE rolname='postgres';"
#   SCRAM-SHA-256...
```

**Dato verificado, con fecha (8/09/2026):** la `libpq 13` que trae `php:7.4-cli` —base Debian bullseye— **sí habla SCRAM** contra un `postgres:16.9`. Era la verificación que decidía si el stack entero de este track era viable, y salió que sí:

```
conexion:       OK
servidor:       PostgreSQL 16.9
password_encr:  scram-sha-256
php:            7.4.33 (aarch64)
```

> ⚠️ **Si alguna vez ves este fallo, la tentación es bajar `password_encryption` a `md5`.** Funciona y es exactamente la decisión equivocada: estás degradando la seguridad del servidor para acomodar un cliente viejo. La respuesta correcta es subir el cliente; si no se puede, es una excepción documentada con fecha de revisión, no una configuración. [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) trata esa conversación entera.

---

## Las rupturas reales de esta cadena, con cita

Verificadas contra las notas de release oficiales el 11/09/2026. Son las que `be04` usa, y las únicas que se pueden afirmar.

### PG 10 — el vocabulario del WAL

> *"Rename write-ahead log directory `pg_xlog` to `pg_wal`, and rename transaction status directory `pg_clog` to `pg_xact`"*
> *"Rename SQL functions, tools, and options that reference "xlog" to "wal". For example, `pg_switch_xlog()` becomes `pg_switch_wal()`, pg_receivexlog becomes pg_receivewal, and `--xlogdir` becomes `--waldir`."*

También se renombró `location` a `lsn` en las funciones y vistas de WAL, se retiró `contrib/tsearch2`, y desaparecieron las marcas de tiempo en coma flotante.

**A quién le duele:** a los scripts de respaldo, supervisión y mantenimiento. **A la aplicación, casi nunca.**

### PG 12 — `WITH OIDS` y los tipos de los años noventa

> *"Previously, a normally-invisible `oid` column could be specified during table creation using `WITH OIDS`; that ability has been removed. Columns can still be explicitly declared as type `oid`. Operations on tables that have columns created using `WITH OIDS` will need adjustment."*

> *"Remove obsolete data types `abstime`, `reltime`, and `tinterval`. Use the SQL-standard types such as `timestamp` instead."*

> *"Remove deprecated `pg_constraint.consrc` and `pg_attrdef.adsrc` columns"* — hay que usar `pg_get_expr()` o `pg_get_constraintdef()` en su lugar.

**A quién le duele:** a tablas creadas antes de 2019, a código que introspecciona el esquema, y a cualquiera que guardara intervalos con los tipos viejos. También cambió el comportamiento *greedy* de `substring()` con patrones SQL (`%#"aa*#"%`), que es la única ruptura de manejo de cadenas real de esta cadena.

### PG 14 — SCRAM por defecto

Ver la sección de arriba. En este stack **no rompió**, y saber por qué no rompió vale tanto como saber por qué podría.

### PG 15 — el esquema `public` deja de ser de todos

> *"Remove `PUBLIC` creation permission on the `public` schema […] The change applies to new database clusters and to newly-created databases in existing clusters. Upgrading a cluster or restoring a database dump will preserve `public`'s existing permissions."*

> *"Remove long-deprecated exclusive backup mode […] Functions `pg_start_backup()`/`pg_stop_backup()` have been renamed to `pg_backup_start()`/`pg_backup_stop()`, and the functions `pg_backup_start_time()` and `pg_is_in_backup()` have been removed."*

**A quién le duele:** a las migraciones que corren con un usuario que no es el propietario de la base (el primero) y **otra vez al script de respaldo** (el segundo). Es el mismo archivo roto por segunda vez en la misma cadena, y sigue sin que nadie se entere, porque un respaldo sólo falla el día que hay que restaurar.

---

## Dos rupturas que todo el mundo cita y no son de esta cadena

Esto es lo más útil del apéndice y por eso tiene sección propia.

**1. "El escapado manual de comillas se rompió."** `standard_conforming_strings` pasó a `on` por defecto en **PostgreSQL 9.1, en 2011** — cinco años antes de que naciera `certcore-api`. El escapado defensivo con barras que ves en el SQL crudo del sistema es una **cicatriz heredada** de alguien que vivió aquel cambio, no algo que se rompiera aquí.

**2. "Postgres retiró los casts implícitos."** La retirada masiva de casts implícitos a `text` fue de **PostgreSQL 8.3, en 2008**. Los `::text` explícitos repartidos por el código son de la misma familia: reflejos de una época anterior, escritos por alguien que ya se había quemado.

> 🧭 **Las dos son ciertas como hechos históricos y falsas como diagnóstico de esta cadena.** Es la trampa más común del oficio: una afirmación verdadera **en otro contexto**, repetida en foros durante quince años, aplicada a un caso donde no toca. Por eso la regla del track es la que es — **la nota de release, con versión y URL, o no entra en el documento**.

---

## Cómo se lee una nota de release en diez minutos

Las notas de PostgreSQL son larguísimas y el 90% son mejoras que no te rompen nada. El procedimiento:

1. **Entra por `postgresql.org/docs/release/<N>.0/`.** La sección **"Migration to Version N"** está siempre al principio: es la única que importa.
2. **Lee sólo esa sección, entera.** Suele tener entre diez y treinta ítems.
3. **Clasifica cada ítem en tres cubos:** *no me afecta* (replicación, extensiones que no uso), *me afecta si…* (usas tal función, tal tipo, tal columna de catálogo), *me afecta seguro* (valores por defecto, permisos).
4. **Para cada ítem del segundo cubo, busca en tu código.** Un `grep` por el nombre de la función o el tipo. Treinta segundos por ítem.
5. **Anota los que descartes y por qué.** El descarte razonado vale tanto como el hallazgo, y es lo que hace revisable tu trabajo.
6. **Salta de versión en versión, sin atajos.** Si vas de 9.6 a 16 tienes que leer las siete secciones de migración. No hay un resumen acumulado fiable, y los que circulan por ahí son de dónde salen las dos falsas de arriba.

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer | Por qué |
|---|---|---|
| El servidor no arranca tras cambiar el tag | Mirar `PG_VERSION` en el directorio de datos | Es incompatibilidad de formato, no de SQL |
| Subir de versión en el laboratorio | `down -v` + volumen nuevo + migrar y sembrar | Rápido, reproducible, y **no es lo que hace producción** |
| Subir de versión en producción, base grande | `pg_upgrade` | Minutos de parada en vez de horas |
| Subir de versión y querer empezar limpio | `dump` / `restore` | Reconstruye permisos y catálogos |
| Saber si una versión te afecta | Sólo la sección "Migration to Version N" | El resto son mejoras |
| Un error de autenticación tras subir | Comprobar `password_encryption` y la `libpq` del cliente | Casi siempre es SCRAM desde PG 14 |
| Fechar un archivo sin `git log` | Buscar sintaxis retirada (`pg_xlog`, `WITH OIDS`) | Un fósil datable: se escribió antes de esa versión |
| Alguien cita una ruptura de memoria | Pedir versión y URL | Dos de las más citadas no son de esta cadena |

---

## ⚠️ Advertencias

**Este apéndice cubre una cadena concreta: 9.6 → 16.** Si trabajas con otra, el método sirve y la lista no. Vuelve al procedimiento de los diez minutos y constrúyete la tuya.

**Las rupturas que no rompen nada son las peligrosas.** El 95% de compatibilidad es lo que hace que nadie mire; el 5% restante se cobra en el artefacto que sólo se usa en emergencias. Cuando subas una versión mayor, **ejercita el respaldo y la restauración antes de dar por buena la subida**, aunque el sistema esté verde.

**El laboratorio no es producción y la diferencia está documentada** (los permisos del esquema `public`). Antes de llevarte un diagnóstico de aquí a un sistema real, escribe en qué difieren los dos. Si no puedes escribirlo, no puedes llevártelo.

---

## 📚 Referencias

- https://www.postgresql.org/docs/release/10.0/ · https://www.postgresql.org/docs/release/12.0/ · https://www.postgresql.org/docs/release/15.0/ — las tres notas de release de donde salen todas las citas de este apéndice. Verificadas el 11/09/2026.
- https://www.postgresql.org/support/versioning/ — la política: una versión mayor al año, cinco años de soporte cada una. Es el calendario que movió la base de CertCore.
- https://www.postgresql.org/docs/16/pgupgrade.html — `pg_upgrade`, con la explicación de `--link` y sus consecuencias.
- https://www.postgresql.org/docs/16/auth-password.html — `password_encryption`, SCRAM y `md5`.
- https://www.postgresql.org/docs/16/ddl-schemas.html — el esquema `public` y los patrones de uso seguros que motivaron el cambio de PG 15.
- https://www.postgresql.org/docs/9.1/release-9-1.html — para comprobar por ti mismo la primera de las dos falsas: `standard_conforming_strings` en 2011.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos. Y el reflejo de siempre: **`/docs/current/` no es `/docs/16/`**, y en este apéndice esa diferencia es literalmente el tema.

---

## 🧪 Ejercicios (9)

1. Levanta la base en 9.6 y en 16.9 y compara: `SELECT version()`, `SHOW password_encryption`, y el contenido de `PG_VERSION`. Pega las seis salidas.
2. **Diagnóstico.** Provoca el error de incompatibilidad del directorio de datos: cambia `POSTGRES_TAG` sin borrar el volumen. Pega el mensaje literal y señala qué dos versiones nombra.
3. Crea una tabla con `WITH OIDS` bajo 9.6, comprueba que funciona, y repite bajo 12. Anota el mensaje exacto.
4. **Diagnóstico.** Escribe una consulta que use `pg_constraint.consrc` bajo 9.6 y tradúcela a `pg_get_constraintdef()`. Comprueba las dos bajo 16.
5. Lee la sección "Migration to Version 13" completa con el procedimiento de los diez minutos y clasifica cada ítem en los tres cubos. ¿Cuántos caen en "me afecta seguro"?
6. **Diagnóstico.** Comprueba la ruptura del esquema `public` de dos formas: en un clúster nuevo y en uno restaurado desde un volcado de la versión anterior. Documenta los dos comportamientos y explica cuál se parece a producción.
7. Busca en el proyecto todos los "fósiles datables" —sintaxis retirada— y úsalos para fechar cada archivo. Contrasta con `git log` cuando exista.
8. **Diagnóstico.** Escribe el script de respaldo con `pg_start_backup()` y ejecútalo contra 9.6, 13 y 16.9. Anota en qué versión dejó de funcionar y qué habría avisado antes.
9. **Diagnóstico.** Toma una de las dos rupturas falsas de este apéndice, busca tres páginas en internet que la afirmen sin versión, y escribe en cinco líneas por qué la afirmación sigue circulando. Después escribe la versión correcta de esa afirmación, la que sí es cierta.

---

> 🏷️ **Este apéndice no lleva tag propio.** Lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be04: …`). La tabla de clasificación del ejercicio 5 y el fechado del ejercicio 7 conviene conservarlos en `EVIDENCIA-VERSIONES.md`, que sí es entregable de be04. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
MDEOF
wc -l bea-05-dialectos-y-saltos-de-version-en-postgresql.md

# --- 2026-09-11T18:27:01 · Write bea-07 appendix
cat > bea-07-tiempo-zonas-y-timestamptz.md <<'MDEOF'
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
MDEOF
wc -l bea-07-tiempo-zonas-y-timestamptz.md

# --- 2026-09-11T18:30:55 · Write be05 flagship phase
cat > be05-la-invariante-que-no-sostenia-nadie.md <<'MDEOF'
# ⭐ Fase be05 — La invariante que no sostenía nadie

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Fase be05 de be07 · **10 horas** ⭐⭐
> Depende de: **be04 cerrada** · Habilita: be06
> Apéndices de apoyo: [`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md) · [`bea-11`](bea-11-datos-de-prueba-y-volumen.md) 🔥 · Incidentes asociados: **be-09**, **be-10**
> Estilo de esta fase: **contención, no corrección.** Se pone una restricción sobre datos que ya la violan, sin tocar el histórico

> 🔥 **Esta fase pertenece al track opcional de backend.** Es la fase insignia y la que cierra el círculo con el corazón del track base.

---

## 🎯 1. Propósito

Descubrir que el bug estrella del track base no era un bug de frontend.

La Fase 7 te enseñó el síntoma: *una inspección de hace un año se está renderizando con la plantilla de hoy*. Lo arreglaste en el frontend, con `resolveTemplateVersion`, y estuvo bien: era el arreglo correcto en la capa donde estabas. Esta fase muestra **dónde estaba la causa**.

> 🧠 **La mitad de los bugs que parecían del frontend no lo eran.**

---

## ✅ 2. Qué queda listo al terminar

- [ ] La invariante está **escrita en una línea** en `INVARIANTES.md`, con su enunciado formal y su consecuencia de negocio.
- [ ] Demostraste que **ninguna restricción de la base la sostiene**: el `\d inspections` no tiene ninguna foránea contra `templates`, y lo sabes enseñar.
- [ ] La **consulta que encuentra las violaciones** está escrita, corre sobre las cuatro mil inspecciones del volumen sintético, y devuelve un número. Ese número está en `INVARIANTES.md` con su fecha.
- [ ] Las **tres salidas están costeadas y medidas**, no descritas: clave foránea compuesta con `NOT VALID`, `CHECK` con función, y disciplina de aplicación documentada.
- [ ] La restricción recomendada **está puesta**: la foránea compuesta en `NOT VALID`, con el `smoke.sh` en verde y sin haber tocado una sola fila del histórico.
- [ ] Una inserción nueva que viole la invariante **falla**; las filas viejas que la violan **siguen ahí**. Lo comprobaste con las dos pruebas.
- [ ] `certificates.status` ya no miente: está servido como **derivado**, y sabes explicar por qué una columna generada **no podía** resolverlo.
- [ ] Tienes el `EXPLAIN` de la consulta de violaciones sobre cuatro mil filas, comparado con la línea base de cinco de be03.

---

## 🚫 3. Qué NO entra todavía

- **Limpiar los datos sucios.** En un dominio regulado el histórico no se reescribe: una inspección de 2019 se hizo como se hizo. Contener no es corregir, y ésa es la doctrina del track.
- **La reescritura a medias** → be06.
- **El *assessment*** → be07, que consume los números de esta fase.
- **`VALIDATE CONSTRAINT` sobre el histórico.** Se explica, se deja preparado, y **no se ejecuta**: validar exige decidir antes qué se hace con las filas que fallen, y esa decisión es de negocio.
- **Migrar las fechas a `TIMESTAMPTZ`** (💸 4 de be04). Sigue costeada y sin pagar; el procedimiento que aprendes aquí es el que haría falta.

---

## 🧠 4. Concepto mínimo

### La invariante, en una línea

> 🧭 **Una inspección se lee siempre contra la versión de plantilla que estaba vigente cuando se ejecutó.**

Esa frase es el corazón de CertCore. Sostiene el valor legal de todo el sistema: un certificado dice que un activo cumplía **la norma vigente en su momento**, y si la inspección se re-renderiza con la plantilla de hoy, el documento afirma algo que nunca se comprobó.

Y ahora la pregunta de esta fase, que en el track base no se podía ni formular: **¿quién sostiene esa invariante?**

- ¿El frontend? `resolveTemplateVersion` la respeta **al pintar**. Eso es una lectura correcta, no una garantía.
- ¿El backend? Guarda `template_id` y `template_version` al crear la inspección. Eso es una escritura correcta, no una garantía.
- ¿La base? Vamos a mirar.

```bash
docker compose exec db psql -U postgres certcore -c '\d inspections'
```

```
   Column          |  Type   | ...
-------------------+---------+-----
 template_id       | character varying  |
 template_version  | integer            |
...
Foreign-key constraints:
    "inspections_asset_id_foreign" FOREIGN KEY (asset_id) REFERENCES assets(id)
```

**Una foránea, a `assets`. Ninguna a `templates`.** Las dos columnas que sostienen el valor legal del sistema son dos campos sueltos que nadie comprueba: se puede escribir `template_version = 99` sin que nada proteste.

> 🧭 **Una invariante que nadie sostiene no está rota: está esperando.** CertCore funcionó ocho años porque nadie borró una plantilla vieja. El día que alguien lo haga —una limpieza, una migración, un `DELETE` con un `WHERE` de más—, la auditoría encuentra inspecciones renderizadas con la norma equivocada. Y en una certificadora eso no es un bug de interfaz.

🪞 **Tu instinto de integridad referencial dice… y esta vez se equivoca a medias.** Tu instinto dice *"pon la foránea"*, y tiene razón. Lo que el instinto no trae es qué hacer cuando **los datos ya la violan** y el sistema tiene que seguir emitiendo certificados mañana. `ALTER TABLE ... ADD FOREIGN KEY` sobre una tabla con filas sucias falla, punto. Ahí empieza el oficio de esta fase, y es lo que [`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md) desarrolla.

### Por qué nadie la declaró en 2016

No fue descuido, y la cadena de causas es rastreable —la empezaste en be02, ejercicio 23:

1. El ORM de 2016 **no sabe hablar de claves primarias compuestas** ([`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md)).
2. La salida cómoda fue aplastar `(template_id, version)` en una cadena: `"elevator-annual-v2"`, y declararla `id`.
3. Con la clave de `templates` siendo una cadena compuesta y las columnas de `inspections` siendo dos campos separados, **la foránea compuesta no se podía ni escribir**.
4. Y como todo funcionaba, nadie volvió a mirarlo.

> 🧠 **La limitación de una herramienta se convirtió en una decisión de arquitectura, y nadie la tomó.** Es el pecado que funda este track —ausencia de revisión— en su forma más pura: no hay un culpable, hay una cadena de opciones razonables que nadie reevaluó.

🩻 **Esto sí funciona igual.** Todo tu instinto relacional sirve: la foránea compuesta es la solución correcta, `NOT VALID` existe desde hace años, y el procedimiento es el de siempre. Lo único que cambia respecto de un sistema limpio es el **orden**: primero se cuenta el daño, después se contiene, y la corrección del histórico es una decisión de negocio que probablemente sea *"no se toca"*.

---

## 💻 5. Código mínimo con comentarios

### 5.1 El volumen: por qué con cinco filas no se mide nada

Con las cinco inspecciones del `db.json`, todas las consultas de esta fase tardan lo mismo —nada— y todos los planes son un `Seq Scan`. No se puede argumentar con eso.

Así que aquí, y **sólo aquí en todo el track**, se entregan datos ajenos: **cuatro mil inspecciones sintéticas, con las violaciones ya dentro**. El generador, su semilla fija y las reglas que respeta están en [`bea-11`](bea-11-datos-de-prueba-y-volumen.md).

```bash
docker compose exec api php database/seeds/volume.php --inspections=4000 --seed=20240915
#   sembradas 4000 inspecciones (3.912 válidas, 88 violando la invariante)
#   semilla 20240915 — reproducible
```

> ⚠️ **Que el track entregue datos aquí es una excepción y se declara.** Todo lo demás sale de tu propio `db.json`. El volumen sintético **no entra en ninguna colección que el `smoke.sh` audite** (la regla está en `bea-11`): si lo hiciera, el contrato dejaría de ser verificable, y este track no negocia con su juez.

### 5.2 La consulta que encuentra las violaciones

La pieza central, y son ocho líneas:

```sql
-- Inspecciones que apuntan a una versión de plantilla que NO EXISTE.
-- Es exactamente la comprobación que haría una clave foránea compuesta, y por
-- eso vale como censo previo: cuenta las filas que impedirían añadirla.
SELECT i.id, i.template_id, i.template_version, i.started_at, i.status
FROM inspections i
LEFT JOIN templates t
  ON t.template_id = i.template_id
 AND t.version     = i.template_version
WHERE t.template_id IS NULL
ORDER BY i.started_at;
```

Y la que hay que correr primero, porque el número es el que gobierna la fase:

```sql
SELECT count(*) AS violaciones,
       count(*) FILTER (WHERE i.status IN ('approved', 'completed')) AS con_certificado_posible
FROM inspections i
LEFT JOIN templates t
  ON t.template_id = i.template_id AND t.version = i.template_version
WHERE t.template_id IS NULL;
```

La segunda columna es la que asusta: una inspección huérfana en estado `requested` es un dato feo; una **aprobada** es un certificado emitido contra una norma que no se puede reconstruir.

**Detalles con intención**

- **`LEFT JOIN` + `IS NULL` y no `NOT EXISTS`**, aunque los dos sirven: el `LEFT JOIN` te deja añadir columnas de la plantilla cuando **sí** existe, y eso permite reutilizar la misma consulta para la variante del ejercicio 12 —las que apuntan a una versión que existe pero **no estaba vigente** en la fecha de la inspección, que es una violación más sutil y más frecuente.
- **`ORDER BY started_at`** no es cosmético: te dice **cuándo** empezaron a aparecer, y eso suele señalar el evento que las produjo.

**Prueba de fuego**

```sql
EXPLAIN ANALYZE
SELECT count(*) FROM inspections i
LEFT JOIN templates t ON t.template_id = i.template_id AND t.version = i.template_version
WHERE t.template_id IS NULL;
```

Compáralo con la línea base de cinco filas de be03 (ejercicio 19). Con cuatro mil, el plan ya dice algo: si ves un `Seq Scan` sobre `inspections` **está bien** —las estás mirando todas—, pero fíjate en cómo accede a `templates`: ahí sí hay una clave que usar, y el planificador debería usarla.

### 5.3 Las tres salidas, costeadas

#### Salida A — Clave foránea compuesta con `NOT VALID` ⭐ (la recomendada)

```sql
-- Se añade la restricción SIN validar el histórico. A partir de este momento:
--   · toda fila NUEVA o MODIFICADA tiene que cumplirla
--   · las 88 filas viejas que no la cumplen SIGUEN AHÍ, intactas
-- La operación toma un bloqueo breve y NO reescribe la tabla.
ALTER TABLE inspections
  ADD CONSTRAINT inspections_template_fk
  FOREIGN KEY (template_id, template_version)
  REFERENCES templates (template_id, version)
  NOT VALID;
```

Qué se gana el primer día: **la hemorragia para**. Ninguna inspección nueva puede apuntar a una plantilla inexistente, y —lo que casi nadie ve— **ya no se puede borrar una plantilla que tenga inspecciones**, que era el escenario que convertía la invariante dormida en un incidente.

Qué cuesta:

- Un bloqueo `SHARE ROW EXCLUSIVE` sobre `inspections` durante la creación. Con cuatro mil filas, imperceptible; con cuatro millones, sigue siendo rápido **porque `NOT VALID` no lee las filas** — ésa es toda la gracia.
- Las 88 filas sucias siguen siendo inválidas y ahora están **declaradas** como tales, que es mejor que estar escondidas.
- Y un efecto que hay que saber: `NOT VALID` **no se hereda hacia atrás**, pero sí se aplica a un `UPDATE` de una fila vieja. Tocar una de las 88 para cualquier otra cosa hará que falle. Eso es correcto y hay que avisarlo, porque el primer `UPDATE` masivo que alguien haga se va a estrellar contra esto.

```sql
-- Cuando el negocio decida qué hacer con las 88, se valida. NO HOY.
-- Toma un bloqueo más suave (SHARE UPDATE EXCLUSIVE) y lee la tabla entera.
ALTER TABLE inspections VALIDATE CONSTRAINT inspections_template_fk;
```

#### Salida B — `CHECK` con función

```sql
CREATE FUNCTION template_version_exists(p_template_id text, p_version integer)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM templates WHERE template_id = p_template_id AND version = p_version
  );
$$ LANGUAGE sql STABLE;

ALTER TABLE inspections
  ADD CONSTRAINT inspections_template_check
  CHECK (template_version_exists(template_id, template_version)) NOT VALID;
```

Funciona… hasta que deja de funcionar, y hay que saber exactamente por qué:

- **Un `CHECK` sólo se evalúa cuando cambia la fila que lo lleva.** Si alguien borra una plantilla, las inspecciones que la referenciaban **no se revalidan**: el `CHECK` no las mira nunca más. La foránea sí lo impide, y ésa es la diferencia que decide.
- Un `CHECK` que consulta otra tabla **miente al restaurar un volcado**: el orden de carga puede hacer que falle o que pase sin significar nada.
- A cambio, es la única salida que permite una regla más rica que "existe" — por ejemplo, *que estuviera vigente en la fecha de la inspección*.

#### Salida C — Disciplina de aplicación documentada

No poner nada en la base y garantizarlo en el código: una comprobación en el servicio que crea inspecciones, una prueba de regresión, y un documento.

Cuándo es la respuesta correcta, porque a veces lo es: cuando la restricción tiene excepciones legítimas que la base no puede expresar, cuando la tabla es tan grande que cualquier `ALTER` es un evento, o cuando el sistema tiene fecha de decomisión cercana y lo que se necesita es que no empeore.

Cuándo no lo es, que es aquí: **`certcore-api` tiene cuatro maneras distintas de escribir en `inspections`** (lo mediste en be02) y ninguna prueba (llegan en be06). Una disciplina de aplicación con cuatro puertas y sin red no es una garantía: es una intención.

| | A · FK compuesta `NOT VALID` | B · `CHECK` con función | C · Disciplina |
|---|---|---|---|
| Impide filas nuevas malas | ✅ | ✅ | ⚠️ si pasan por la puerta correcta |
| Impide borrar una plantilla usada | ✅ | ❌ | ❌ |
| Coste de ponerla hoy | Un bloqueo breve | Un bloqueo breve | Semanas de código |
| Toca el histórico | **No** | No | No |
| Sobrevive a un volcado/restauración | ✅ | ⚠️ según el orden | ✅ |
| Permite reglas más ricas | ❌ | ✅ | ✅ |
| **Veredicto del track** | ⭐ **Recomendada** | Complemento | Sólo si A es imposible |

> 🧭 **La recomendación del track es A, y el motivo es la fila que casi nadie mira:** sólo la foránea impide **borrar la plantilla vieja**, que es exactamente el escenario que convierte esta invariante dormida en un incidente de auditoría. Contener la causa vale más que comprobar el síntoma.

### 5.4 `certificates.status`, y la trampa de la columna generada

La deuda 💸 2 viene desde la Fase 10 del track base y se contó en be03: el estado está guardado y empieza a mentir al día siguiente. Ahora se arregla, y el primer intento **no funciona**:

```sql
-- LO QUE TODO EL MUNDO INTENTA PRIMERO, Y NO SE PUEDE:
ALTER TABLE certificates
  ADD COLUMN status_derivado text GENERATED ALWAYS AS (
    CASE WHEN revoked_at IS NOT NULL THEN 'revoked'
         WHEN valid_until < now()    THEN 'expired'
         ELSE 'valid' END
  ) STORED;
--   ERROR:  generation expression is not immutable
```

Y el error es **la lección**, no un obstáculo. Una columna generada se calcula **al escribir la fila** y tiene que ser inmutable: la misma entrada, el mismo resultado, siempre. `now()` no lo es. Y no puede serlo, porque el estado de un certificado **no es una función de la fila: es una función de la fila y del momento en que preguntas.**

> 🧠 **Si un valor cambia sin que nadie escriba, no es una columna: es una consulta.** Ésa es la definición operativa de "dato derivado", y explica de una vez por qué `certificates.status` llevaba ocho años mintiendo — estaba guardado en el único sitio donde no podía estar bien.

La salida correcta es una vista, que se evalúa **cada vez que se lee**:

```sql
CREATE VIEW certificates_with_status AS
SELECT
  c.id,
  c.inspection_id,
  c.issued_at,
  c.valid_until,
  c.revoked_at,
  -- El estado, calculado en el momento de preguntar. La vigencia termina al
  -- final del día calendario en America/Bogota: la frase está escrita en
  -- INVARIANTES.md y aquí sólo se implementa (bea-07).
  CASE
    WHEN c.revoked_at IS NOT NULL THEN 'revoked'
    WHEN (c.valid_until AT TIME ZONE 'America/Bogota') < now() THEN 'expired'
    WHEN (c.valid_until AT TIME ZONE 'America/Bogota') < now() + interval '30 days' THEN 'expiring'
    ELSE 'valid'
  END AS status,
  -- Se conserva el valor guardado, con otro nombre, para poder medir la
  -- divergencia durante la transición. Se borra cuando llegue a cero... o
  -- cuando alguien decida que nunca va a llegar.
  c.status AS status_almacenado
FROM certificates c;
```

Y el controlador pasa a leer de la vista. **El contrato no cambia**: el frontend sigue recibiendo un `status` en el mismo sitio con los mismos valores. Lo único que cambia es que ahora es verdad.

```
💸 DEUDA TÉCNICA INTENCIONAL — la columna `status` sigue existiendo
No se borra. Hay código heredado que la escribe (el controlador de la parcela
CakePHP de be02 §5.1) y borrarla lo rompería, sin que ninguna prueba avise.
SE PAGA EN be06, cuando haya pruebas y se haya decidido cuál de las dos
maneras de emitir un certificado es la buena. Hasta entonces la vista la deja
inofensiva: nadie la lee.
```

### 5.5 El procedimiento de despliegue, que es el entregable de verdad

Poner la restricción son tres líneas. Ponerla **sin tumbar producción** es un procedimiento, y es lo único de esta fase que te sirve en un sistema que no sea CertCore:

1. **Censar.** Corre la consulta de §5.2 y anota el número **con fecha y hora**. Sin censo no hay decisión: un `ALTER` que falla a las tres de la mañana no es una sorpresa, es una medición que no hiciste.
2. **Clasificar las violaciones.** ¿Son viejas y estables, o siguen apareciendo? El `ORDER BY started_at` lo dice. **Si siguen apareciendo, la restricción es urgente**; si pararon en 2021, ya sabes que algo se arregló solo y conviene saber qué.
3. **Decidir qué pasa con las filas malas.** Y la respuesta aquí es *nada*: en un dominio regulado el histórico no se reescribe. Esa decisión se escribe en `INVARIANTES.md` firmada por alguien, no se deja implícita.
4. **Añadir con `NOT VALID`**, en una ventana cualquiera: no reescribe la tabla.
5. **Comprobar las dos caras.** Que una inserción mala falla y que las viejas siguen ahí. Las dos pruebas, siempre: comprobar sólo una de las dos es la forma más común de creer que has puesto una restricción que no pusiste.
6. **Avisar del efecto lateral:** cualquier `UPDATE` sobre una de las filas viejas va a fallar a partir de ahora. Eso va en el correo de despliegue, no en un comentario del código.
7. **Dejar `VALIDATE` preparado y no ejecutarlo.** Documenta el comando y quién puede autorizarlo.

**El patrón a memorizar**

> Para poner una restricción sobre datos sucios no hace falta limpiar los datos. Hace falta **separar el futuro del pasado**: `NOT VALID` hace exactamente eso, y es la herramienta más infravalorada de PostgreSQL.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Intentar la foránea sin `NOT VALID`.**
*Síntoma:* `ERROR: insert or update on table "inspections" violates foreign key constraint`, y el `ALTER` no deja nada puesto.
*Causa:* PostgreSQL valida el histórico entero por defecto.
*Fix mínimo:* `NOT VALID`. Y antes, el censo — si no sabes cuántas filas fallan, tampoco sabes si el problema es de 88 filas o de 88.000.

**Limpiar los datos para que la restricción entre.**
*Síntoma:* un `UPDATE` que apunta las inspecciones huérfanas a la plantilla más parecida, y el `ALTER` ya pasa.
*Causa:* la restricción se convirtió en el objetivo, en vez de ser la herramienta.
*Fix mínimo:* revierte, y despacio. Acabas de reescribir el histórico de un sistema regulado: esas inspecciones ahora dicen que se ejecutaron contra una plantilla contra la que **no** se ejecutaron. Es peor que el problema original, porque además es indetectable.

**Creer que un `CHECK` protege de un `DELETE` en otra tabla.**
*Síntoma:* con el `CHECK` puesto, alguien borra una plantilla y las inspecciones se quedan huérfanas sin un solo error.
*Causa:* un `CHECK` sólo se evalúa cuando cambia **su propia fila**.
*Fix mínimo:* la foránea. Y la lección general: **una restricción protege en la dirección en que está escrita, no en la que te imaginas.**

**Poner la restricción y no comprobar las dos caras.**
*Síntoma:* declaras la fase cerrada y dos semanas después entra una inspección huérfana.
*Causa:* comprobaste que las filas viejas seguían ahí y no que las nuevas fallaran; o al revés.
*Fix mínimo:* las dos pruebas, siempre, en el mismo commit.

### Pieza forense de esta fase

**La fila que apunta a una plantilla que no existe.**

Llega el ticket, y viene de auditoría interna: *"la inspección 3117 no se puede reimprimir: sale vacía"*.

1. **Mira el dato, no el código.**
   ```sql
   SELECT id, template_id, template_version, status, started_at
   FROM inspections WHERE id = 3117;
   --   3117 | elevator-annual | 3 | approved | 2023-04-11 09:20:00
   ```
2. **Pregunta por lo referenciado.**
   ```sql
   SELECT template_id, version FROM templates WHERE template_id = 'elevator-annual';
   --   elevator-annual | 1
   --   elevator-annual | 2
   ```
   **No hay versión 3.** La inspección apunta a una plantilla que no existe, y está **aprobada**: hay un certificado emitido contra una norma que nadie puede reconstruir.
3. **Pregunta si es una o son muchas.** La consulta de §5.2. Ochenta y ocho. Y `ORDER BY started_at` dice que todas son de un rango de tres semanas de 2023.
4. **Busca el evento, no al culpable.** Tres semanas, un rango cerrado. Alguien publicó una v3, se emitieron inspecciones contra ella, y después **la v3 se borró** — probablemente porque se publicó por error. Las inspecciones quedaron apuntando al vacío. No hay malicia: hay un `DELETE` que la base permitió porque nadie le dijo que no podía.
5. **Y la pregunta que cierra la investigación:** ¿por qué el frontend no se enteró nunca? Porque `resolveTemplateVersion` **degrada con elegancia**: si no encuentra la versión, cae a la vigente y pinta algo. La pantalla nunca estuvo en blanco. **Durante tres años, esas inspecciones se vieron perfectas y con la plantilla equivocada.**

> 🧠 **Un frontend que degrada con elegancia oculta la corrupción de datos durante años.** Es el mismo código que en la Fase 7 celebraste por ser robusto. Robusto y silencioso son la misma propiedad vista desde dos sitios, y cuál de las dos es depende de si alguien está mirando la base.

> 🧨 **Rompe a propósito y observa.** Con la restricción puesta, intenta `DELETE FROM templates WHERE template_id = 'elevator-annual' AND version = 1`. Pega el error. Después quítala, repite el borrado, abre la inspección 501 en la aplicación **y mira la pantalla**: no hay error, no hay aviso, y los ítems que ves son los de otra versión. Anota cuánto tiempo habría tardado alguien en darse cuenta. Ésa es la respuesta a por qué esto duró ocho años.

---

## 🧪 7. Ejercicios (33)

**🟢 Fácil (1–8)**

1. Escribe la invariante en `INVARIANTES.md` con tus palabras, y debajo su consecuencia de negocio en una frase que entienda alguien de auditoría.
2. Corre `\d inspections` y señala qué foráneas hay y cuáles faltan. Pega la salida.
3. **Diagnóstico.** Siembra el volumen sintético y corre la consulta de conteo de §5.2. Anota los dos números con fecha y hora.
4. Corre la consulta de violaciones completa y mira el `ORDER BY started_at`. ¿En qué rango de fechas se concentran?
5. Intenta añadir la foránea **sin** `NOT VALID`. Pega el error literal.
6. **Diagnóstico.** Añádela con `NOT VALID` y comprueba las dos caras: una inserción mala falla, las viejas siguen. Pega las dos salidas.
7. Intenta crear la columna generada de §5.4 y pega el error de inmutabilidad. Explícalo en dos líneas.
8. Crea la vista `certificates_with_status` y compara su `status` con el almacenado. ¿Cuántos difieren?

**🟡 Intermedio (9–20)**

9. **Diagnóstico.** Investiga la inspección 3117 con los cinco pasos de §6 y escribe la ruta completa. Criterio: alguien que no haya visto la fase puede repetirla.
10. Compara el `EXPLAIN ANALYZE` de la consulta de violaciones con cinco filas y con cuatro mil. Anota los dos planes y explica qué cambió y qué no.
11. **Diagnóstico.** Intenta borrar una plantilla referenciada, con la restricción puesta y sin ella. Documenta los dos comportamientos y cuál de los dos ve el usuario.
12. Escribe la variante sutil de la consulta: inspecciones cuya versión de plantilla **existe** pero **no estaba vigente** en su `started_at`. ¿Cuántas hay? ¿Es una violación de la invariante o de otra cosa?
13. Implementa la salida B (`CHECK` con función) en una rama, y demuestra con un `DELETE` que no protege lo que la foránea sí protege.
14. **Diagnóstico.** Con la restricción puesta, intenta un `UPDATE` sobre una de las 88 filas sucias (cambia sólo el `status`). Pega el error y explica por qué es correcto que falle y por qué hay que avisarlo antes de desplegar.
15. Haz que el controlador de certificados lea de la vista y comprueba con el `smoke.sh` que el contrato no cambió.
16. **Diagnóstico.** Mide el tiempo de `GET /certificates` leyendo de la tabla y leyendo de la vista, con cuatro mil filas. ¿Cuánto cuesta la verdad?
17. Escribe el paso 3 del procedimiento —qué se hace con las filas malas— como un documento firmable: la decisión, quién la toma, y qué pasaría si se tomara la contraria.
18. **Diagnóstico.** Averigua si las violaciones siguen apareciendo hoy: inserta una inspección nueva **sin** la restricción y comprueba si algún camino del código la habría impedido. Recuerda que hay cuatro caminos (be02).
19. Documenta el efecto lateral del `UPDATE` (ejercicio 14) en el correo de despliegue que mandarías. Cinco líneas, para gente de operaciones.
20. **Diagnóstico.** Comprueba qué pasa con la restricción al restaurar un volcado: haz `pg_dump`, restaura en una base nueva, y mira si la restricción llegó como `NOT VALID` o validada. Repite el ejercicio con la salida B y compara.

**🟠 Difícil (21–28)**

21. **Diagnóstico.** Reconstruye el evento de 2023: ¿qué secuencia exacta de operaciones produce 88 inspecciones huérfanas en tres semanas? Escríbela como una línea de tiempo y después **reprodúcela** en tu laboratorio partiendo de datos limpios.
22. Costea las tres salidas con números de tu laboratorio: tiempo de `ALTER`, bloqueo tomado, filas afectadas, y qué protege cada una. Tabla de tres columnas, defendible ante alguien que prefiere la C.
23. **Diagnóstico.** Prepara el `VALIDATE CONSTRAINT` sin ejecutarlo: qué bloqueo toma, cuánto tardaría con cuatro mil filas y cuánto con cuatro millones (mídelo o extrapólalo con método), y qué haría falta decidir antes. Documéntalo.
24. Extiende la invariante a los `jsonb`: escribe la consulta que encuentra respuestas (`answers`) cuyo `itemId` no existe en la plantilla de esa inspección (be03, ejercicio 24). ¿Cuántas hay? Después responde lo difícil: **¿se puede restringir eso?** Si no, di qué se puede hacer en su lugar.
25. **Diagnóstico.** Demuestra la degradación silenciosa del frontend: borra una plantilla, abre la inspección en la aplicación, y documenta qué ve el usuario. Después propón un cambio **en el backend** —no en el frontend, que no se toca— que convierta ese silencio en ruido. ¿Es buena idea? Argumenta las dos posturas.
26. Escribe la prueba de regresión que impediría que esto vuelva a pasar, en el lenguaje que sea, y di **dónde tendría que correr** para servir de algo. Guárdala: be06 la va a necesitar.
27. **Diagnóstico.** Aplica el procedimiento de siete pasos de §5.5 a **otra** deuda del sistema: la migración a `TIMESTAMPTZ` de be04. ¿Qué paso cambia? ¿Cuál es más caro? Entrega el procedimiento adaptado.
28. Con cuarenta mil inspecciones en vez de cuatro mil ([`bea-11`](bea-11-datos-de-prueba-y-volumen.md)), repite el censo y el `ALTER`. Anota los tiempos. ¿Cambia alguna de las recomendaciones?

**🔴 Muy difícil (29–33)**

29. **Diagnóstico.** Escribe el informe para auditoría: cuántas inspecciones se renderizaron con una plantilla que no era la suya, durante cuánto tiempo, qué certificados salieron de ellas, y **qué se puede y qué no se puede reconstruir hoy**. Es el documento más incómodo del track y el más realista.
30. Diseña el esquema que CertCore debería haber tenido en 2016 para que esta invariante fuera imposible de violar. Después costea la migración desde el actual. Cierra con la pregunta honesta: **¿la habrías diseñado así tú, en 2016, con un ORM que no soporta claves compuestas?**
31. **Diagnóstico.** La invariante tiene una versión más fuerte: *una inspección se lee contra la versión que estaba **vigente** en su fecha*. Mide cuántas filas violan **esa**, decide si merece una restricción, y si decides que sí, escríbela. Si decides que no, escribe por qué — las dos respuestas son defendibles y lo que se evalúa es el criterio.
32. Con todos los números de la fase, escribe el argumento de una página titulada *"esto no era un bug del frontend"*, dirigida al equipo que arregló la Fase 7. Sin reproche: el arreglo de allí era correcto. Lo que hay que explicar es **por qué era insuficiente y qué habría hecho falta saber para verlo**.
33. **Diagnóstico adversarial.** Alguien propone borrar las 88 filas sucias *"porque son datos corruptos y no sirven para nada"*. Escribe la respuesta en tres párrafos: qué se destruiría exactamente, qué obligación legal podría estar en juego en una certificadora, y **qué parte del argumento contrario es cierta** — porque algo de razón tiene.

**🔥 Opcionales**

- 🔥 Implementa la invariante fuerte del ejercicio 31 con un `EXCLUDE` o un índice de rango sobre la vigencia de las plantillas. Mide qué cuesta y decide si vale la pena.
- 🔥 Escribe un trabajo programado que audite la invariante cada noche y avise. Después argumenta si eso sustituye a la restricción, la complementa, o es una excusa para no ponerla.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/16/ddl-constraints.html — restricciones, incluidas las compuestas. La base de toda la fase.
- https://www.postgresql.org/docs/16/sql-altertable.html — `ADD CONSTRAINT ... NOT VALID` y `VALIDATE CONSTRAINT`, con los bloqueos que toma cada uno. **Léete la sección de bloqueos entera**: es lo que separa un despliegue tranquilo de un incidente.
- https://www.postgresql.org/docs/16/ddl-generated-columns.html — columnas generadas y el requisito de inmutabilidad, que es la trampa de §5.4.
- https://www.postgresql.org/docs/16/sql-createview.html — vistas, la salida correcta para un valor que depende del reloj.
- https://www.postgresql.org/docs/16/explicit-locking.html — la tabla de conflictos entre modos de bloqueo. Es la referencia que contesta *"¿esto para producción?"*.

**Libros / artículos de referencia**
- *Refactoring Databases* (Ambler y Sadalage, 2006), capítulos sobre *transition period* — la idea de que un cambio de esquema sobre un sistema vivo se hace en dos tiempos, que es exactamente `NOT VALID` y `VALIDATE`.
- *Designing Data-Intensive Applications* (Kleppmann, O'Reilly, 2017), capítulo 12 — la distinción entre integridad y puntualidad, y por qué una restricción declarativa vale más que una comprobación de aplicación en sistemas con varios escritores.

**Video / apoyo**
- https://www.youtube.com/results?search_query=postgresql+zero+downtime+schema+migration — charlas sobre migraciones sin parada. Busca las que hablen de bloqueos y de `NOT VALID`; descarta las que sólo enseñen `ALTER TABLE`.

**Orden de lectura sugerido:** [`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md) **antes** de tocar nada — es el apéndice que sostiene esta fase → [`bea-11`](bea-11-datos-de-prueba-y-volumen.md) **cuando siembres el volumen** → la documentación de `ALTER TABLE`, sección de bloqueos, **antes** de proponer el despliegue → Kleppmann **después**, cuando quieras defender por qué la base y no el código.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. Y con `NOT VALID` en particular, **comprueba la versión**: el comportamiento de los bloqueos ha ido mejorando versión a versión, y lo que leas de PostgreSQL 9 puede ser más pesimista que lo que hace la 16.

---

## 🚀 9. Cierre y conexión con la siguiente fase

La invariante que sostiene el valor legal de CertCore lleva ocho años sin que nadie la sostenga, y ahora está declarada, censada y contenida. Ochenta y ocho filas siguen violándola y **siguen ahí**, que es lo correcto: el histórico de un dominio regulado no se reescribe. Lo que ya no puede pasar es que aparezcan más, ni que alguien borre una plantilla vieja sin enterarse.

Y el bug estrella del track base quedó explicado desde el otro lado del cable: `resolveTemplateVersion` era el arreglo correcto en su capa, y era insuficiente porque **la capa no era la suya**.

**be06** es el paso natural por una razón que se escribe allí y no antes: ahora que sabes cuál es la regla, se puede probar. Hasta hoy no se podía, porque había cuatro maneras de escribir en `inspections` y ninguna era la oficial. La próxima fase mide la reescritura que alguien empezó y no terminó, y descubre que el estado intermedio es el más caro de todos.

> **La señal de que quedó bien:** *"puse una restricción sobre una tabla cuyas filas ya la violaban, en un martes cualquiera, sin tocar el histórico y sin que nadie se enterara — y ahora una plantilla vieja no se puede borrar."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-05-la-invariante-que-no-sostenia-nadie \
>   -m "be05 cerrada: invariante enunciada y censada (88 violaciones sobre 4000);
> foránea compuesta en NOT VALID puesta, con las dos pruebas;
> certificates.status servido como derivado desde una vista;
> las tres salidas costeadas y el procedimiento de siete pasos escrito"
> ```
>
> Los commits de esta fase llevan `be05: …` y los de ejercicio `be05 ej29: …`.
>
> Esta fase paga la deuda más grande del track base —⭐ 3, la invariante de plantillas versionadas— y la factura se lee entre dos tags de **cursos distintos**, que es la primera vez que pasa:
>
> ```bash
> git diff fase-07-plantillas-versionadas be-fase-05-la-invariante-que-no-sostenia-nadie -- src/ server/
> ```
>
> El lado de `src/` sale **vacío**, y eso es exactamente el punto: la causa se arregló donde estaba, y el frontend que la sufría no cambió ni una línea. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥.

---

## 📌 Pendientes sugeridos

- **`VALIDATE CONSTRAINT` queda preparado y sin ejecutar.** No es un olvido: validar exige decidir antes qué pasa con las 88 filas, y esa decisión es de negocio. → **Documentado en `INVARIANTES.md`** con el comando y quién puede autorizarlo; se cita en be07 como riesgo aceptado.
- **La columna `certificates.status` sigue existiendo** y hay código heredado que la escribe (💸 de §5.4). → **be06**, cuando haya pruebas y se haya decidido cuál de las dos maneras de emitir es la buena.
- **Las respuestas huérfanas dentro de `answers` (`jsonb`)** son la misma clase de agujero un nivel más abajo, y **no se pueden restringir** con el modelo actual (ejercicio 24). → **`bea-10`**, como deuda aceptada con su razón; y 🔥 de be06 para quien quiera normalizar.
- **La invariante fuerte** —*vigente en su fecha*, no sólo *existente*— (ejercicio 31) se queda sin decidir a propósito: las dos respuestas son defendibles y el track no la resuelve por el lector. → **Decisión pendiente**, anotada en `INVARIANTES.md` con los argumentos de los dos lados.
- **La prueba de regresión del ejercicio 26 no tiene dónde correr todavía.** → **be06**, que es donde llega la infraestructura de pruebas.
- **El informe para auditoría (ejercicio 29) es el entregable más realista del track** y se queda como ejercicio. Si alguna vez el track gana una fase de comunicación con negocio, sale de ahí. → **📌 de autoría**, para el chat de cierre.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| **be-09** | "Una inspección de 2023 no se puede reimprimir" | Invariante · fila huérfana | 🔴 |
| **be-10** | "Después del despliegue no puedo actualizar unas inspecciones viejas" | `NOT VALID` · efecto lateral del `UPDATE` | 🟠 |
MDEOF
wc -l be05-la-invariante-que-no-sostenia-nadie.md

# --- 2026-09-11T18:32:43 · Write bea-06 appendix
cat > bea-06-restricciones-claves-compuestas-y-datos-sucios.md <<'MDEOF'
# 📎 Apéndice bea-06 — Restricciones, claves compuestas y datos sucios

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **3 horas**
> Usado por: **be05** ⭐ · Versiones cubiertas: **PostgreSQL 16**
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido.** Se entra con una pregunta operativa —*"¿esto bloquea la tabla?"*, *"¿cómo pongo esto si ya hay filas malas?"*— y se sale con el comando y con el bloqueo que toma.

🧭 **El ángulo:** el problema nunca es escribir la restricción. Es que **ocho años de datos no la cumplen** y el sistema tiene que seguir emitiendo certificados mañana por la mañana.

**Qué queda fuera:** **limpiar los datos sucios**. En un dominio regulado el histórico no se reescribe, y este apéndice no da recetas para hacerlo — enlaza con la doctrina del track y no la contradice. Tampoco entra el diseño de esquema, que es [`be03`](be03-el-reemplazo.md), ni el análisis de la invariante concreta de CertCore, que es [`be05`](be05-la-invariante-que-no-sostenia-nadie.md).

---

## Índice

- [Claves primarias y foráneas compuestas](#claves-primarias-y-foráneas-compuestas)
- [`NOT VALID` y `VALIDATE CONSTRAINT` ⭐](#not-valid-y-validate-constraint-)
- [`CHECK` con función, y sus tres límites](#check-con-función-y-sus-tres-límites)
- [Columnas generadas, y lo que **no** pueden hacer](#columnas-generadas-y-lo-que-no-pueden-hacer)
- [Índices únicos parciales](#índices-únicos-parciales)
- [El procedimiento de despliegue sin bloquear la tabla](#el-procedimiento-de-despliegue-sin-bloquear-la-tabla)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-7)

---

## Claves primarias y foráneas compuestas

Una clave compuesta es una clave cuyo valor son **varias columnas juntas**. No tiene nada de exótico y PostgreSQL las soporta desde siempre; lo que suele faltar es el ORM.

```sql
-- Clave primaria compuesta: lo que `templates` necesitaba y no tuvo hasta be03.
ALTER TABLE templates ADD PRIMARY KEY (template_id, version);

-- Y la foránea compuesta que apunta a ella.
ALTER TABLE inspections
  ADD CONSTRAINT inspections_template_fk
  FOREIGN KEY (template_id, template_version)
  REFERENCES templates (template_id, version);
```

Tres cosas que hay que saber y que casi nunca se dicen:

1. **La tabla referenciada necesita un `PRIMARY KEY` o un `UNIQUE` sobre exactamente esas columnas, en ese orden.** Sin él, el `ALTER` falla con *"there is no unique constraint matching given keys"*, y ése es el mensaje que delata que el problema está en la **otra** tabla.
2. **El orden de las columnas importa** para el índice que respalda la clave, aunque no para la semántica de la restricción.
3. **PostgreSQL no crea índice para la foránea**, sólo para la clave referenciada. Si vas a borrar o actualizar filas de la tabla padre, quieres un índice en las columnas hijas o cada `DELETE` hará un recorrido secuencial.

```sql
CREATE INDEX inspections_template_idx ON inspections (template_id, template_version);
```

> 🧠 **Cuando un sistema tiene un identificador compuesto aplastado en una cadena —`"elevator-annual-v2"`— casi siempre es que alguien no pudo declarar la clave compuesta y buscó la salida.** La causa suele ser el ORM, y la consecuencia es que la foránea compuesta que hacía falta no se pudo ni escribir. En CertCore eso es literal ([`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md)).

---

## `NOT VALID` y `VALIDATE CONSTRAINT` ⭐

El mecanismo central del apéndice, y la herramienta más infravalorada de PostgreSQL.

**El problema:** `ALTER TABLE ... ADD CONSTRAINT` valida el histórico entero. Si hay una sola fila que no cumple, no se añade nada. Y si hay millones de filas que sí cumplen, la validación bloquea la tabla mientras las lee todas.

**La salida, en dos tiempos:**

```sql
-- Tiempo 1 — HOY. No lee las filas existentes: sólo declara la regla.
ALTER TABLE inspections
  ADD CONSTRAINT inspections_template_fk
  FOREIGN KEY (template_id, template_version) REFERENCES templates (template_id, version)
  NOT VALID;

-- Tiempo 2 — CUANDO SE PUEDA, y sólo si se decidió qué hacer con las filas malas.
ALTER TABLE inspections VALIDATE CONSTRAINT inspections_template_fk;
```

Qué hace exactamente cada uno:

| | `ADD ... NOT VALID` | `VALIDATE CONSTRAINT` |
|---|---|---|
| Filas nuevas y modificadas | **Se comprueban** desde el primer segundo | Ya se comprobaban |
| Filas viejas que violan | **Se quedan**, intactas | Hacen fallar el comando |
| ¿Lee la tabla entera? | **No** | Sí |
| Bloqueo (foránea) | `SHARE ROW EXCLUSIVE` sobre ambas tablas, breve | `SHARE UPDATE EXCLUSIVE`: **no bloquea lecturas ni escrituras normales** |
| ¿Lo usa el planificador? | No confía en ella | Sí, una vez validada |

Y los tres efectos que sorprenden y hay que anunciar antes de desplegar:

- **Un `UPDATE` sobre una fila vieja inválida falla**, aunque el `UPDATE` no toque las columnas de la restricción. La fila entera se revalida al modificarse. Es correcto, y es lo que rompe el primer proceso masivo que alguien corra después.
- **Una foránea `NOT VALID` sí impide borrar filas del padre** referenciadas por hijos válidos, y también por los inválidos existentes. La protección "hacia el otro lado" es completa desde el primer día, y suele ser el motivo principal para ponerla.
- **`VALIDATE` se puede correr en cualquier momento** y, si falla, no deja la restricción peor de lo que estaba: sigue existiendo como `NOT VALID`.

> 🧭 **`NOT VALID` no es una restricción a medias: es una restricción completa para el futuro.** Separa el futuro del pasado, que es justo lo que hace falta cuando el pasado no se puede tocar.

```sql
-- Qué restricciones hay sin validar en esta base:
SELECT conrelid::regclass AS tabla, conname, contype
FROM pg_constraint WHERE NOT convalidated;
```

Ese `SELECT` conviene tenerlo a mano: una restricción `NOT VALID` que lleva tres años sin validar **es una deuda declarada**, y aparece en un inventario. Una que nadie sabe que existe, no.

---

## `CHECK` con función, y sus tres límites

Una restricción `CHECK` puede llamar a una función, y eso permite reglas que la sintaxis declarativa no expresa:

```sql
CREATE FUNCTION template_version_exists(p_template_id text, p_version integer)
RETURNS boolean AS $$
  SELECT EXISTS (SELECT 1 FROM templates WHERE template_id = p_template_id AND version = p_version);
$$ LANGUAGE sql STABLE;

ALTER TABLE inspections
  ADD CONSTRAINT inspections_template_check
  CHECK (template_version_exists(template_id, template_version)) NOT VALID;
```

Los tres límites, en orden de importancia:

1. **Un `CHECK` sólo se evalúa cuando cambia su propia fila.** Si la verdad que comprueba vive en **otra** tabla, un cambio allí no lo revalida nunca. Borra la plantilla y las inspecciones se quedan huérfanas sin un error. **Para eso está la foránea, y por eso no son intercambiables.**
2. **Un `CHECK` no inmutable miente al restaurar.** `pg_restore` revalida las restricciones al cargar; según el orden de las tablas, puede fallar o pasar sin significar nada.
3. **Rendimiento:** una función que consulta otra tabla se ejecuta en cada `INSERT` y en cada `UPDATE` de esa fila.

A cambio, es la única forma de expresar reglas más ricas que "existe": *que estuviera vigente en la fecha*, *que la severidad sea coherente con el estado*, *que las fechas no se crucen*.

---

## Columnas generadas, y lo que **no** pueden hacer

Una columna generada se calcula a partir de otras columnas **de la misma fila**, al escribir:

```sql
ALTER TABLE certificates
  ADD COLUMN is_revoked boolean GENERATED ALWAYS AS (revoked_at IS NOT NULL) STORED;
```

Y ahora la parte que importa, porque es donde se estrella todo el mundo:

```sql
ALTER TABLE certificates
  ADD COLUMN status_derivado text GENERATED ALWAYS AS (
    CASE WHEN revoked_at IS NOT NULL THEN 'revoked'
         WHEN valid_until < now()    THEN 'expired'
         ELSE 'valid' END
  ) STORED;
--   ERROR:  generation expression is not immutable
```

> ⚠️ **Una columna generada exige una expresión inmutable, y `now()` no lo es.** No es una limitación arbitraria: la columna se calcula **una vez, al escribir**, y se guarda. Si dependiera del reloj, el valor guardado sería falso al minuto siguiente — exactamente el defecto que se estaba intentando arreglar.

> 🧠 **Si un valor cambia sin que nadie escriba la fila, no es una columna: es una consulta.** Ésa es la definición operativa de dato derivado, y la que decide entre estas tres herramientas:

| Lo que necesitas | Herramienta |
|---|---|
| Un valor que depende **sólo de la fila** | **Columna generada** (`STORED`) |
| Un valor que depende del **reloj** o de **otras tablas** | **Vista** (o expresión en la consulta) |
| Un valor caro que se lee mucho y tolera estar desfasado | **Vista materializada**, con su refresco y su desfase declarado |

En CertCore, `certificates.status` es del segundo tipo, y por eso [`be05`](be05-la-invariante-que-no-sostenia-nadie.md) lo resuelve con una vista. La columna generada, ahí, **no es una opción** — y el error de inmutabilidad es la mejor explicación de por qué el dato estaba mal guardado desde el principio.

---

## Índices únicos parciales

El truco que resuelve la mitad de las reglas de unicidad del mundo real, donde la unicidad sólo aplica a **algunas** filas:

```sql
-- "Sólo puede haber UNA plantilla vigente por templateId."
-- La vigente es la que tiene valid_until nulo; las cerradas, cualquier número.
CREATE UNIQUE INDEX templates_one_active_per_id
  ON templates (template_id)
  WHERE valid_until IS NULL;
```

Es declarativo, lo comprueba la base, y no necesita disparadores. Y se puede crear sin bloquear escrituras:

```sql
CREATE UNIQUE INDEX CONCURRENTLY ...   -- tarda más, no bloquea
```

⚠️ `CONCURRENTLY` **no se puede ejecutar dentro de una transacción**, así que no encaja en una migración normal de Eloquent sin desactivar la transacción envolvente. Y si falla, deja un índice **inválido** que hay que borrar a mano (`DROP INDEX`) antes de reintentar. Compruébalo siempre después:

```sql
SELECT indexrelid::regclass FROM pg_index WHERE NOT indisvalid;
```

---

## El procedimiento de despliegue sin bloquear la tabla

Seis pasos, y el primero no es técnico:

1. **Censa.** Cuenta las filas que violan la regla, con fecha y hora. **Sin censo no hay decisión.**
2. **Clasifica.** ¿Las violaciones son viejas y estables, o siguen apareciendo? Ordena por la fecha de creación: si siguen apareciendo, la restricción es urgente; si pararon, algo se arregló solo y conviene saber qué.
3. **Decide qué pasa con las filas malas, y que alguien firme.** En un dominio regulado, la respuesta suele ser *nada*. Escríbela.
4. **Añade con `NOT VALID`**, fuera de hora punta por prudencia, sabiendo que no reescribe la tabla.
5. **Comprueba las dos caras:** una fila nueva mala falla, las viejas siguen ahí. **Siempre las dos.**
6. **Anuncia los efectos laterales** —el `UPDATE` sobre filas viejas inválidas ahora falla— en el correo de despliegue, y deja `VALIDATE` documentado sin ejecutar.

Y el `SET lock_timeout` que evita el peor escenario, que es el `ALTER` esperando un bloqueo detrás de una transacción larga y **bloqueando a todos los que llegan después**:

```sql
SET lock_timeout = '3s';   -- si no consigo el bloqueo en 3 segundos, me rindo
ALTER TABLE inspections ADD CONSTRAINT ... NOT VALID;
```

> 🧭 **Un `ALTER` que espera es peor que un `ALTER` que falla.** Mientras espera el bloqueo, todo lo que llega detrás se encola. `lock_timeout` convierte un incidente en un reintento.

---

## 🧭 Cuándo usar qué

| Situación | Herramienta | Qué cuesta |
|---|---|---|
| La verdad está en otra tabla | **Clave foránea** (compuesta si hace falta) | Bloqueo breve con `NOT VALID` |
| Hay filas que ya la violan | **`NOT VALID`**, y validar después o nunca | Las viejas siguen inválidas y declaradas |
| La regla es más rica que "existe" | `CHECK` con función | No protege de cambios en otra tabla |
| El valor depende sólo de la fila | Columna generada `STORED` | Debe ser inmutable |
| El valor depende del reloj | **Vista** | Se calcula en cada lectura |
| Unicidad sólo para algunas filas | Índice único **parcial** | `CONCURRENTLY` fuera de transacción |
| La tabla es enorme y está caliente | `NOT VALID` + `lock_timeout` | Nada: es el caso para el que existe |
| No puedes poner nada en la base | Disciplina de aplicación **documentada** | Sólo vale si hay una única puerta de escritura |

---

## ⚠️ Advertencias

**Limpiar los datos para que la restricción entre es casi siempre el error más caro.** Reescribir el histórico de un sistema regulado destruye evidencia y encima lo hace de forma indetectable: las filas corregidas afirman algo que nunca ocurrió. Si alguien propone un `UPDATE` masivo "para dejar la tabla limpia", la pregunta que lo frena es: *¿quién firma que esos datos ahora dicen la verdad?*

**Una restricción protege en la dirección en que está escrita, no en la que te imaginas.** Antes de darla por buena, escribe las dos o tres operaciones que **quieres** impedir y compruébalas una a una. La mitad de las restricciones mal elegidas del mundo son `CHECK` puestos donde hacía falta una foránea.

**`NOT VALID` no es un estado transitorio por definición.** Puede quedarse años, y es legítimo — siempre que esté **declarado** en un inventario de deuda y no escondido. La consulta de `pg_constraint` de arriba es la que convierte "se nos quedó así" en "está así, y estas son las razones".

---

## 📚 Referencias

- https://www.postgresql.org/docs/16/sql-altertable.html — `ADD CONSTRAINT ... NOT VALID`, `VALIDATE CONSTRAINT` y, sobre todo, **la sección de bloqueos**, que es la que contesta si algo se puede desplegar.
- https://www.postgresql.org/docs/16/ddl-constraints.html — restricciones, incluidas las compuestas y las parciales.
- https://www.postgresql.org/docs/16/ddl-generated-columns.html — columnas generadas y el requisito de inmutabilidad.
- https://www.postgresql.org/docs/16/sql-createindex.html — índices únicos parciales y `CONCURRENTLY`, con lo que pasa si falla.
- https://www.postgresql.org/docs/16/explicit-locking.html — la tabla de conflictos entre modos de bloqueo. Imprescindible antes de proponer una ventana.
- https://www.postgresql.org/docs/16/runtime-config-client.html — `lock_timeout` y `statement_timeout`.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos. Y con los bloqueos en particular, **comprueba la versión**: lo que leas de PostgreSQL 9 sobre qué bloquea un `ALTER` es más pesimista que lo que hace la 16, y en una discusión de despliegue esa diferencia cambia la decisión.

---

## 🧪 Ejercicios (7)

Todos con un criterio de éxito numérico: **el número de filas que violan la restricción**, antes y después.

1. Cuenta las filas que violan la invariante de `inspections`. Añade la foránea **sin** `NOT VALID` y pega el error. Después con `NOT VALID` y comprueba que el número de filas malas **no cambió**.
2. **Diagnóstico.** Con la restricción `NOT VALID` puesta, intenta tres operaciones: insertar una fila mala, actualizar una fila vieja mala, y actualizar una fila vieja buena. Anota cuáles fallan y explica por qué.
3. Implementa la misma regla con `CHECK` y función. Después borra una plantilla referenciada y cuenta las filas huérfanas que aparecieron. Repite con la foránea: el número tiene que ser cero.
4. **Diagnóstico.** Intenta crear la columna generada con `now()` y pega el error. Después resuélvelo con una vista y comprueba que el resultado cambia con el paso del tiempo sin que nadie escriba.
5. Crea el índice único parcial de "una sola plantilla vigente por `templateId`". Cuenta cuántas filas lo violan hoy; si son cero, provoca una violación y comprueba que la base la impide.
6. **Diagnóstico.** Mide los bloqueos: en una transacción abierta haz un `SELECT ... FOR UPDATE` sobre `inspections`, y desde otra sesión lanza el `ALTER ... NOT VALID`. Observa qué pasa. Después repite con `SET lock_timeout = '3s'` y anota la diferencia.
7. **Diagnóstico.** Lista las restricciones `NOT VALID` de tu base con la consulta de `pg_constraint`. Para cada una, escribe una línea: qué protege, cuántas filas la violan hoy, y qué haría falta para poder validarla. Ese documento es, exactamente, una entrada del mapa de deuda de [`bea-10`](bea-10-mapa-de-deuda-del-track-be.md).

---

> 🏷️ **Este apéndice no lleva tag propio.** Lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be05: …`). El inventario del ejercicio 7 conviene conservarlo: be05 lo cita en `INVARIANTES.md` y `bea-10` lo consume entero. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
MDEOF
wc -l bea-06-restricciones-claves-compuestas-y-datos-sucios.md

# --- 2026-09-11T18:32:55 · Correct generated-column claim in appendix prompts
python3 - <<'PY'
p='prompts/prompts-backend-apendice.md'
s=open(p).read()
old="""  `CHECK` con función y sus límites; columnas generadas, que es como el
  `certificates.status` deja de mentir; índices únicos parciales; y el
  procedimiento de despliegue de una restricción sin bloquear la tabla."""
new="""  `CHECK` con función y sus límites; columnas generadas **y lo que no pueden
  hacer** ⚠️ —**corrección verificada el 11/09/2026**: una columna generada exige
  expresión **inmutable**, así que `certificates.status`, que depende del reloj,
  **no** se puede resolver con una; el error `generation expression is not
  immutable` es la mejor explicación de por qué ese dato estaba mal guardado, y
  la salida correcta es una **vista**, que es lo que hace `be05`—; índices únicos
  parciales; y el procedimiento de despliegue de una restricción sin bloquear la
  tabla."""
assert old in s, "no encontrado"
open(p,'w').write(s.replace(old,new,1))
print('ok')
PY

# --- 2026-09-11T18:33:00 · Find generated columns mentions
grep -n "columnas generadas" prompts/prompts-backend-apendice.md prompts/propuesta-fases-backend.md

# --- 2026-09-11T18:33:02 · Show exact lines
sed -n '329,335p' prompts/prompts-backend-apendice.md

# --- 2026-09-11T18:33:07 · Correct generated-column claim in appendix prompts
python3 - <<'PY'
p='prompts/prompts-backend-apendice.md'
s=open(p).read()
old="""`CHECK` con función y sus límites; columnas generadas, que es como el
  `certificates.status` deja de mentir; índices únicos parciales; y el
  procedimiento de despliegue de una restricción sin bloquear la tabla."""
new="""`CHECK` con función y sus límites; columnas generadas **y lo que no
  pueden hacer** ⚠️ —**corrección verificada el 11/09/2026**: una columna generada
  exige una expresión **inmutable**, así que `certificates.status`, que depende
  del reloj, **no** se puede resolver con una. El error `generation expression is
  not immutable` es la mejor explicación de por qué ese dato estaba mal guardado
  desde el principio, y la salida correcta es una **vista**, que es lo que hace
  `be05`—; índices únicos parciales; y el procedimiento de despliegue de una
  restricción sin bloquear la tabla."""
assert old in s
open(p,'w').write(s.replace(old,new,1))
print('ok')
PY

# --- 2026-09-11T18:34:37 · Write bea-11 appendix
cat > bea-11-datos-de-prueba-y-volumen.md <<'MDEOF'
# 📎 Apéndice bea-11 — Datos de prueba y volumen

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **3 horas**
> Usado por: **be05** · Versiones cubiertas: PHP 7.4, PostgreSQL 16
> 🔥 **Opcional dentro del track opcional.** be05 se puede hacer sin generar volumen; lo que se pierde es poder medir.

**Esto no se lee de corrido.** Se entra buscando cómo generar datos que sirvan —o por qué los que generaste no sirven— y se sale con el generador y con la regla que lo hace utilizable.

**Qué problema resuelve:** conseguir **cuatro mil inspecciones creíbles** para que las mediciones de [`be05`](be05-la-invariante-que-no-sostenia-nadie.md) digan algo, **sin que los datos generados arruinen las pruebas**.

**Qué queda fuera:** la **anonimización de datos reales de clientes**. Es un dominio regulado: tomar datos de producción y "quitarles los nombres" no es anonimizar, y este apéndice no da receta. Si te lo plantean, la respuesta correcta es hablar con cumplimiento antes de copiar la primera fila.

---

## Índice

- [La regla que justifica el apéndice entero](#la-regla-que-justifica-el-apéndice-entero)
- [Las dos fuentes de datos del track, y no hay una tercera](#las-dos-fuentes-de-datos-del-track-y-no-hay-una-tercera)
- [Determinismo: la semilla fija](#determinismo-la-semilla-fija)
- [El generador de volumen de be05](#el-generador-de-volumen-de-be05)
- [Coherencia con el dominio, que es lo que lo vuelve utilizable](#coherencia-con-el-dominio-que-es-lo-que-lo-vuelve-utilizable)
- [Las violaciones sembradas a propósito](#las-violaciones-sembradas-a-propósito)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-7)

---

## La regla que justifica el apéndice entero

> 🧭 **Un dataset aleatorio arruina una prueba de regresión.**

Una prueba afirma algo concreto: *"esta consulta devuelve 88 filas"*, *"este endpoint tarda menos de 200 ms"*. Si los datos cambian en cada ejecución, la afirmación deja de ser comprobable: la prueba pasa unos días y falla otros, y el equipo aprende a ignorarla — que es peor que no tenerla.

De ahí sale la distinción que ordena todo lo demás:

| | Datos de **aserción** | Datos de **carga y medición** |
|---|---|---|
| Para qué | Comprobar que algo vale exactamente X | Ver cómo se comporta el sistema con volumen |
| De dónde salen | **El `db.json` del propio alumno**, fijo | Generados |
| Cuántos | Cinco inspecciones. Las que conoces | Cuatro mil, o cuarenta mil |
| ¿Pueden cambiar? | **No.** Cambiarlos cambia el significado de las pruebas | Sí, mientras la semilla quede anotada |
| ¿Los audita el `smoke.sh`? | **Sí** | **Nunca** |

> ⚠️ **El faker es una herramienta de carga y de medición, no de aserción.** En cuanto una prueba afirma algo sobre un dato generado, esa prueba ya no prueba nada.

---

## Las dos fuentes de datos del track, y no hay una tercera

**Fuente 1 — tu propio `mock/db.json`.** Es la semilla por defecto de todo el track, y por eso be03 insiste en sembrar desde ahí y no desde un volcado que venga con el curso. Que la inspección 501 sea la que llevas viendo desde la Fase 3 es la mitad del efecto: cuando algo se rompa, vas a reconocer el dato.

**Fuente 2 — el volumen sintético de be05.** Es la **única vez** en todo el track que se entregan datos ajenos, y la fase lo declara explícitamente. El motivo es que con cinco inspecciones no se mide nada: todos los planes son un recorrido secuencial, todos los tiempos son cero, y no se puede argumentar con eso delante de nadie.

No hay tercera fuente. En particular, **no hay datos de producción**, ni siquiera "anonimizados".

---

## Determinismo: la semilla fija

Todo generador de este apéndice recibe una semilla y la imprime. Sin eso, un hallazgo no es reproducible y un informe no es defendible.

```php
// La semilla se PASA y se IMPRIME. Las dos cosas.
$seed = (int) ($options['seed'] ?? 20240915);
mt_srand($seed);

fwrite(STDERR, sprintf("semilla %d — reproducible con --seed=%d\n", $seed, $seed));
```

Y las tres reglas que hacen que sirva de verdad:

1. **Misma semilla, mismos datos.** Si dos ejecuciones con la misma semilla dan resultados distintos, hay una fuente de azar sin sembrar — casi siempre `uniqid()`, `random_bytes()` o **la fecha actual**.
2. **Nada de `now()` dentro del generador.** Es la fuente de no-determinismo más común y la más difícil de ver: el dataset de hoy y el de mañana se parecen, pero las consultas que filtran por fecha devuelven números distintos. Usa una **fecha de referencia fija**, pasada como parámetro.
3. **La semilla se anota junto al resultado.** *"88 violaciones"* no significa nada; *"88 violaciones con `--seed=20240915` y `--inspections=4000`"* sí, y se puede volver a comprobar dentro de un año.

---

## El generador de volumen de be05

```php
<?php
// server/database/seeds/volume.php
//
//   docker compose exec api php database/seeds/volume.php \
//       --inspections=4000 --seed=20240915 --violations=88
//
// Genera inspecciones sintéticas RESPETANDO EL DOMINIO, con un número exacto de
// violaciones de la invariante sembradas a propósito. No toca ninguna colección
// que audite el smoke.sh: sólo añade filas a `inspections` y `findings`.

declare(strict_types=1);

$app = require __DIR__ . '/../../bootstrap/app.php';

$options = getopt('', ['inspections::', 'seed::', 'violations::', 'reference-date::']);

$count = (int) ($options['inspections'] ?? 4000);
$seed = (int) ($options['seed'] ?? 20240915);
$violations = (int) ($options['violations'] ?? 88);
// Fecha de referencia FIJA: sin ella, el dataset cambia de significado cada día.
$reference = new DateTimeImmutable($options['reference-date'] ?? '2024-09-15 00:00:00');

mt_srand($seed);

// Los activos y las plantillas NO se generan: son los de tu db.json. Sólo se
// genera el hecho repetitivo —la inspección—, que es lo único que en la vida
// real crece a miles.
$assets = DB::table('assets')->pluck('id')->all();
$templates = DB::table('templates')->get()->all();

// … el cuerpo completo del generador, con las reglas de dominio de abajo …

fwrite(STDERR, sprintf(
    "sembradas %d inspecciones (%d válidas, %d violando la invariante)\nsemilla %d, fecha de referencia %s\n",
    $count, $count - $violations, $violations, $seed, $reference->format('Y-m-d')
));
```

**Detalles con intención**

- **Sólo se genera `inspections` (y sus `findings`).** Clientes, activos y plantillas siguen siendo los tuyos: son pocos, los conoces, y generarlos destruiría el reconocimiento que hace útil el laboratorio.
- **El número de violaciones es un parámetro, no un accidente.** Un dataset donde no sabes cuántas violaciones hay no sirve para comprobar una consulta que las cuenta: no tendrías con qué comparar.
- **La fecha de referencia se pasa.** Así el dataset se puede regenerar dentro de un año y significar exactamente lo mismo.

---

## Coherencia con el dominio, que es lo que lo vuelve utilizable

Un generador que respeta los tipos y viola las reglas del negocio produce un dataset **peor que ninguno**: las consultas de be05 encontrarían violaciones falsas, y la fase entera mentiría.

Las reglas que el generador tiene que respetar, todas sacadas del track base:

- Una inspección `approved` **no puede tener hallazgos `critical` sin resolver**. Un `critical` abierto bloquea la aprobación: es la regla de la Fase 9.
- Un certificado sólo existe **sobre una inspección aprobada**. Nada de certificados colgando de inspecciones rechazadas.
- `completed_at` es **nulo** mientras el estado no sea `completed` o posterior, y **posterior** a `started_at` cuando existe.
- `template_version` tiene que ser **una versión que existía** en la fecha de la inspección… **salvo en las filas que se siembran como violación a propósito**, que son las únicas excepciones y están contadas.
- Las respuestas (`answers`) sólo contienen `itemId` que existan en esa versión de la plantilla, y sus valores salen de los `criteria` del ítem.
- Las fechas se reparten en un rango plausible —dos o tres años hacia atrás desde la fecha de referencia—, no todas el mismo día.

> 🧠 **Un dataset sintético es un modelo del dominio escrito en código.** Si el generador no puede respetar una regla, has encontrado una regla que el sistema tampoco sostiene — y eso es un hallazgo, no un problema del generador. En CertCore pasa exactamente con la invariante de plantillas.

---

## Las violaciones sembradas a propósito

Las 88 filas rotas de be05 no son azar: son el ejercicio.

```php
// Las N últimas inspecciones apuntan a una versión de plantilla que NO existe.
// Se concentran en un rango de fechas estrecho a propósito: reproducen el
// patrón real de "alguien publicó una versión, se usó, y después se borró".
$brokenWindowStart = $reference->modify('-18 months');

for ($i = 0; $i < $violations; $i++) {
    $startedAt = $brokenWindowStart->modify(sprintf('+%d days', mt_rand(0, 21)));

    $rows[] = [
        'template_id' => 'elevator-annual',
        // Versión 3: existió durante tres semanas y ya no está.
        'template_version' => 3,
        'status' => 'approved',      // aprobadas: el caso que de verdad duele
        'started_at' => $startedAt->format('Y-m-d H:i:s'),
        // …
    ];
}
```

Que estén **concentradas en tres semanas** y que estén **aprobadas** no es decoración: es lo que permite que el ejercicio de investigación de be05 §6 funcione —el `ORDER BY started_at` revela el rango, y el rango revela el evento—. Un dataset con violaciones repartidas al azar haría esa investigación imposible y, sobre todo, **falsa**: en la realidad, los datos corruptos se agrupan alrededor de un suceso.

---

## 🧭 Cuándo usar qué

| Necesitas… | Usa | Nunca |
|---|---|---|
| Comprobar que una consulta devuelve X | El `db.json` propio | Datos generados |
| Medir un tiempo o leer un `EXPLAIN` | Volumen sintético con semilla | Cinco filas |
| Reproducir un hallazgo dentro de un año | Semilla **y** fecha de referencia anotadas | `now()` en el generador |
| Probar el contrato (`smoke.sh`) | El `db.json` propio, sembrado limpio | Datos generados, **jamás** |
| Un caso límite concreto | Una fila escrita a mano, con nombre | Buscarla entre cuatro mil generadas |
| Volumen mayor para un experimento | El mismo generador con otro `--inspections` | Copiar el dataset y editarlo |

---

## ⚠️ Advertencias

**Los datos generados nunca entran en una colección que el `smoke.sh` audite.** Si lo hacen, el contrato deja de ser verificable: las comprobaciones que cuentan elementos o comparan valores empezarán a fallar por motivos que no tienen que ver con el contrato. El generador de este apéndice sólo añade `inspections` y `findings`, y las comprobaciones del `smoke.sh` que las tocan se escribieron con eso en mente.

**Antes de medir, di contra qué mides.** Un tiempo de respuesta sin la línea base de cinco filas (be03, ejercicio 19) no se puede interpretar. Guarda las dos mediciones siempre.

**Y el límite del laboratorio:** cuatro mil inspecciones en un contenedor de tu portátil no son cuatro mil en producción. El caché está caliente, no hay concurrencia, y el disco es el tuyo. Sirve para comparar **entre sí** dos consultas o dos versiones, no para prometer un número a nadie. Cuando lleves una medición de aquí a una conversación de be07, **di en qué condiciones se tomó**.

---

## 📚 Referencias

- https://www.php.net/manual/es/function.mt-srand.php — el generador sembrado de PHP. Léete la nota sobre qué cambió en PHP 7.1: la secuencia **no** es comparable con la de versiones anteriores.
- https://www.postgresql.org/docs/16/sql-explain.html — `EXPLAIN ANALYZE`, que es para lo que existe el volumen.
- https://www.postgresql.org/docs/16/populate.html — cómo cargar datos rápido: `COPY` frente a `INSERT`, índices después de la carga, y por qué sembrar cuatro mil filas de una en una tarda lo que tarda.
- https://www.postgresql.org/docs/16/sql-analyze.html — `ANALYZE`, que hay que correr **después** de sembrar: sin estadísticas frescas, el planificador toma decisiones basadas en una tabla que ya no existe.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos. Y si buscas librerías de datos falsos, comprueba la versión de PHP que piden: las actuales exigen PHP 8 y aquí el runtime es 7.4 — razón de más para que el generador de este track sean cuarenta líneas propias y ninguna dependencia.

---

## 🧪 Ejercicios (7)

1. Genera cuatro mil inspecciones con `--seed=20240915` dos veces, sobre bases limpias, y comprueba que los datos son idénticos. Si no lo son, encuentra la fuente de azar sin sembrar.
2. **Diagnóstico.** Quita la fecha de referencia y sustitúyela por `now()`. Genera hoy, y vuelve a generar cambiando la fecha del contenedor. Documenta qué consulta de be05 cambia de resultado y por qué es un problema.
3. Corre `ANALYZE` después de sembrar y compara el `EXPLAIN` de la consulta de violaciones antes y después. Anota los dos planes.
4. **Diagnóstico.** Genera un dataset que **viole el dominio** a propósito: certificados sobre inspecciones rechazadas. Después corre las consultas de be05 y explica exactamente qué conclusión falsa sacarías.
5. Cambia `--violations` a 0 y después a 400. Corre el censo de be05 en los dos casos y comprueba que el número coincide con el parámetro. Si no coincide, tu consulta o tu generador tienen un defecto: averigua cuál.
6. **Diagnóstico.** Siembra cuarenta mil inspecciones y repite las mediciones de be05. ¿Cambia alguna recomendación de la fase? ¿Cambia algún plan? Anota los tiempos de las dos escalas.
7. **Diagnóstico.** Comprueba la advertencia principal: mete datos generados en una colección que el `smoke.sh` audite y corre el juez. Anota qué comprobaciones caen y por qué **ninguna de esas caídas significa que el contrato esté roto**. Después revierte.

---

> 🏷️ **Este apéndice no lleva tag propio.** El generador que describe lo escribe be05, así que se commitea con su prefijo (`be05: …`). Lo que sí conviene es que **la semilla, el número de inspecciones y la fecha de referencia queden en el mensaje del tag de be05**: es lo único que hace reproducibles las mediciones de esa fase dentro de un año. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
MDEOF
wc -l bea-11-datos-de-prueba-y-volumen.md

# --- 2026-09-11T18:34:51 · Check Lumen 5.8 dev dependencies
curl -s https://repo.packagist.org/p2/laravel/lumen-framework.json | python3 -c "
import json,sys
d=json.load(sys.stdin)
for v in d['packages']['laravel/lumen-framework']:
    if v['version'] in ('v5.8.13','v5.8.0'):
        print(v['version'], v.get('time'))
        print(' require-dev:', json.dumps(v.get('require-dev'), indent=1))
" 2>/dev/null || echo "sin red"

# --- 2026-09-11T18:38:05 · Write be06 phase
cat > be06-la-reescritura-a-medias.md <<'MDEOF'
# 🧱 Fase be06 — La reescritura que se quedó a medias

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Fase be06 de be07 · **8 horas**
> Depende de: **be05 cerrada** (la restricción puesta y el `smoke.sh` en verde) · Habilita: be07
> Apéndices de apoyo: [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) · [`bea-09`](bea-09-symfony-como-vara-de-medir.md) · Incidentes asociados: **be-11**
> Estilo de esta fase: **medir primero, probar después.** Es la primera fase del track con pruebas automatizadas, y llegan aquí por una razón

> 🔥 **Esta fase pertenece al track opcional de backend.** El track base se completa sin abrirla.

---

## 🎯 1. Propósito

Medir el coste del estado intermedio, que es el más caro de todos.

En algún momento alguien empezó a mover `certcore-api` hacia otra cosa —Laravel completo, servicios, lo que fuera— y se fue antes de terminar. Quedaron **dos maneras de hacer lo mismo, las dos vivas**, y nadie sabe cuál es la buena. Esta fase le pone un número a eso, y sólo entonces escribe las primeras pruebas del track.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `SUPERFICIE.md` existe y mide la reescritura a medias con **tres números**: cuántos endpoints se movieron, cuántos no, y cuántos están **a medias dentro de sí mismos**.
- [ ] Para cada recurso del contrato sabes **cuál de los dos caminos es el oficial**, y esa decisión está escrita y firmada. No adivinada: decidida.
- [ ] PHPUnit **8.5** corre en el contenedor: `docker compose exec api ./vendor/bin/phpunit` da verde.
- [ ] Hay al menos **cinco pruebas** que valen: la invariante de be05, el contrato de un endpoint por camino, la paginación compatible hacia atrás, el caso `500`/`422` de la pieza forense, y la regresión del incidente `be-09`.
- [ ] El **tiempo de ciclo** está medido: cuánto tarda la suite entera contra el `postgres:16.9` del compose, con limpieza entre pruebas. El número está en `SUPERFICIE.md`.
- [ ] Sabes explicar **por qué el camino de vuelta de Lumen a Laravel no es un upgrade**, con el `bootstrap/app.php` de be01 en la mano.
- [ ] El coste de terminar la migración está estimado, y el de **no terminarla** también. Las dos cifras juntas.

---

## 🚫 3. Qué NO entra todavía

- **Terminar la reescritura.** Esta fase mide y decide cuál es el camino oficial; ejecutar la migración no cabe en ocho horas y, sobre todo, **es una decisión que depende del *assessment*** (be07).
- **Subir a PHP 8.** Es la premisa del track, no un pendiente, y cualquier propuesta de subirlo **es** el trasplante de bootstrap. La conversación es de be07: aquí se nombra y se difiere.
- **Cobertura como objetivo.** Un porcentaje de cobertura sobre un sistema con dos caminos vivos mide el doble de lo mismo. Aquí se escriben las pruebas que deciden algo, no las que suben un número.
- **Uniformar el estilo** (be02). Sigue sin tocarse.

---

## 🧠 4. Concepto mínimo

### Por qué las pruebas llegan en la fase seis y no en la uno

La pregunta es legítima y la respuesta es la fase entera:

> 🧭 **No se puede probar lo que no se ha decidido cuál es.**

Una prueba es una afirmación sobre el comportamiento correcto. Si hay dos implementaciones vivas del mismo recurso y **nadie ha decidido cuál es la buena**, una prueba no comprueba: elige. Y elige en silencio, en un archivo que nadie lee como si fuera una decisión de arquitectura.

Fíjate en el orden de las seis fases anteriores, porque no es casual: be00 fijó el **contrato**, be03 lo **sirvió**, be05 declaró la **invariante**. Sólo con esas tres cosas escritas existe algo que una prueba pueda afirmar. Escribirlas en be01 habría producido pruebas de lo que el código hacía, que es la forma más cara de congelar un error.

🪞 **Tu instinto dice "esto debería haber tenido pruebas desde el día uno"… y esta vez se equivoca a medias.** Tiene razón para un sistema que nace. Para uno que heredas con ocho años y dos caminos vivos, escribir pruebas antes de decidir **cristaliza la ambigüedad**: acabas con dos suites verdes que se contradicen, y el sistema se vuelve más difícil de cambiar, no menos.

### El estado intermedio, y por qué es el más caro

Tres estados posibles, y el del medio no es un punto medio del coste:

| Estado | Coste de mantenerlo | Coste de moverse |
|---|---|---|
| Todo viejo | Conocido y estable | Alto, pero acotado |
| **A medias** | **El más alto de los tres** | Alto, y creciendo |
| Todo nuevo | Bajo | — |

Por qué el del medio es el peor, y son cuatro razones concretas que se pueden medir:

1. **Todo cambio se hace dos veces**, o se hace una y se olvida la otra — que es peor, porque produce divergencia silenciosa.
2. **Nadie sabe cuál es la puerta correcta**, así que cada persona nueva elige, y las dos siguen vivas.
3. **Las pruebas, si las hay, prueban las dos** y ninguna decide nada.
4. **El conocimiento de por qué se empezó se fue con quien se fue.** Nadie puede decir si el camino nuevo era mejor o sólo era distinto.

> 🧠 **Terminar una migración que otro empezó suele costar más que empezarla de cero, y aun así casi siempre es la respuesta correcta** — porque el estado intermedio se paga todos los meses, y empezar de cero es pagar otra vez lo ya pagado *más* el intermedio durante más tiempo.

### De Lumen a Laravel no es un upgrade: es un trasplante de bootstrap

Esto hay que entenderlo antes de estimar nada, y el archivo que lo explica ya lo leíste en be01 §5.3.

Lumen y Laravel **comparten los componentes de Illuminate**, y eso hace que el código de dominio —modelos, consultas, validación, colecciones— se parezca tanto que parece portable. Lo que **no** comparten es el arranque: `Laravel\Lumen\Application` no es `Illuminate\Foundation\Application`. Distinto contenedor, distinto ciclo de proveedores de servicios, distinto manejo de configuración, distinto router, distinto sistema de eventos.

📖 **Diccionario de traducción: qué cuesta cada pieza al cruzar**

| Pieza | Cruzar cuesta |
|---|---|
| Modelos y consultas de Eloquent | **Nada.** Es el mismo componente |
| Validación, colecciones, ayudantes | Casi nada |
| Controladores | Poco, salvo los que usan ayudantes específicos |
| **Rutas** | **Reescribir.** `$router->get()` no es `Route::get()`, y los grupos no son iguales |
| **Arranque y configuración** | **Reescribir entero.** Es el trasplante |
| Middleware | Reescribir el registro; la lógica se salva |
| Proveedores de servicios | Reescribir: el ciclo de vida es otro |
| Pruebas | Reescribir el andamiaje; las aserciones se salvan |
| **Y todo lo que Lumen no tenía** | **Escribir de cero** — sesiones, eventos completos, lo que haga falta |

Y una consecuencia que casi nadie ve venir: **un salto a PHP 8 obliga a este mismo trasplante**, porque el primer Lumen que admite PHP 8 es 9.0.0 y entre 5.8 y 9.0 hay cuatro versiones mayores de Illuminate. El ticket de seguridad de be01 y la reescritura a medias de esta fase **son el mismo trabajo visto desde dos sitios**, y darse cuenta de eso es lo que hace que el *assessment* de be07 tenga sentido.

---

## 💻 5. Código mínimo con comentarios

### 5.1 Medir la superficie: los tres números

Sin estos tres números, esta fase es una anécdota.

**Número 1 — endpoints por camino.**

```bash
cd server
# Todas las rutas declaradas, con el controlador que las atiende.
grep -rn "\$router->" routes/ | sed 's/.*=> *//' | sort | uniq -c | sort -rn
```

Clasifica cada ruta con las etiquetas de `ESTRATOS.md` (be02) y cuenta. La tabla que sale es el primer número:

| Recurso | Camino viejo | Camino nuevo | ¿Cuál usa el frontend? | ¿Cuál es el oficial? |
|---|---|---|---|---|
| `/clients` | | | | |
| `/assets` | | | | |
| `/templates` | | | | |
| `/inspections` | | | | |
| `/findings` | | | | |
| `/certificates` | | | | |

**La cuarta columna se mide** —`grep` en `src/` del frontend, o el `CONTRACT.md` de be00—. **La quinta se decide**, y es el entregable.

**Número 2 — endpoints a medias dentro de sí mismos.** El caso peor, y el que no aparece contando rutas: un controlador del camino nuevo que llama a un servicio del viejo, o al revés.

```bash
# Controladores "nuevos" (inyección por constructor) que además usan el locator:
grep -rln "public function __construct" app/Http/Controllers/ \
  | xargs grep -ln "app(\|DB::" 2>/dev/null
```

**Número 3 — escrituras por recurso.** El que decide si la disciplina de aplicación es viable (be05 §5.3, salida C):

```bash
# ¿Cuántos sitios distintos escriben en inspections?
grep -rn "inspections'\|Inspection::" app/ | grep -i "insert\|update\|save\|create" | wc -l
```

> 🧭 **La superficie de una reescritura a medias no se mide en archivos: se mide en decisiones pendientes.** Cada fila sin quinta columna es una decisión que alguien tiene que tomar, y mientras no se tome, las dos implementaciones siguen divergiendo.

```
💸 DEUDA TÉCNICA INTENCIONAL — dos caminos vivos, y se quedan los dos
Esta fase decide cuál es el oficial y NO borra el otro. Borrar el camino no
oficial es correcto y no cabe aquí: hay código heredado que lo llama, no hay
pruebas que cubran esas llamadas (las primeras son de esta fase), y el
esfuerzo depende de una decisión que todavía no se ha tomado (be07).
SE PAGA EN be07 si el assessment elige terminar la migración; NO SE PAGA si
elige estrangular o no hacer nada — y en ese caso pasa a `bea-10` como deuda
aceptada, con su razón escrita.
```

### 5.2 PHPUnit 8.5, y por qué esa versión

```json
{
  "require-dev": {
    "phpunit/phpunit": "^8.5",
    "mockery/mockery": "^1.0"
  }
}
```

La línea de Lumen 5.8.13 declara `"phpunit/phpunit": "^7.0|^8.0"`. Se elige **8.5**, la última de la línea 8, porque es la más nueva que la restricción admite y corre sobre PHP 7.4. PHPUnit 9 pediría cambiar la restricción del framework, que es exactamente la clase de cambio que este track no hace a la ligera.

```php
<?php
// server/tests/TestCase.php

declare(strict_types=1);

use Laravel\Lumen\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    /** Arranca la MISMA aplicación que sirve las peticiones reales. */
    public function createApplication()
    {
        return require __DIR__ . '/../bootstrap/app.php';
    }
}
```

### 5.3 La estrategia de pruebas, y el número que la gobierna

La decisión no es *"¿con base de datos real o con dobles?"*. Es **cuánto tarda el ciclo**, porque una suite que tarda cuatro minutos no se ejecuta y una que no se ejecuta no existe.

Se prueba **contra el `postgres:16.9` del compose**, no contra SQLite. El motivo es este track entero: SQLite no tiene claves foráneas compuestas con la misma semántica, no tiene `jsonb`, no distingue `timestamp` de `timestamptz`, y **la mitad de lo que be04 y be05 enseñaron es precisamente dialecto**. Probar contra otro motor sería probar otro sistema.

Y la limpieza entre pruebas, con sus tiempos medidos en el laboratorio:

| Estrategia | Qué hace | Coste por prueba | Cuándo |
|---|---|---|---|
| **Transacción envuelta** ⭐ | Abre una transacción y hace `ROLLBACK` al terminar | **Milisegundos** | Casi siempre |
| `TRUNCATE` de las tablas tocadas | Vacía y resiembra lo mínimo | Decenas de ms | Cuando la prueba necesita commit |
| `migrate:fresh --seed` | Reconstruye todo | **Segundos** | Nunca por prueba; a lo sumo una vez por suite |

```php
// server/tests/DatabaseTransactions.php — la que se usa por defecto.
trait DatabaseTransactions
{
    public function setUp(): void
    {
        parent::setUp();
        DB::beginTransaction();
    }

    public function tearDown(): void
    {
        // ROLLBACK en vez de limpiar: la base queda exactamente como estaba y
        // cuesta lo mismo tanto si la prueba escribió una fila como mil.
        DB::rollBack();
        parent::tearDown();
    }
}
```

> ⚠️ **La transacción envuelta no sirve para probar transacciones.** Si la prueba necesita comprobar que un `COMMIT` ocurrió —la emisión de un certificado, que son dos escrituras—, el `ROLLBACK` externo te oculta justo lo que quieres ver. Ésas van con `TRUNCATE`, son pocas, y conviene que estén marcadas.

**Prueba de fuego**

```bash
time docker compose exec api ./vendor/bin/phpunit
```

Anota el número en `SUPERFICIE.md`. **Si pasa de treinta segundos, arréglalo antes de escribir la prueba número seis**, porque a partir de ahí sólo va a crecer y el momento de decidir la estrategia es éste.

### 5.4 Las cinco pruebas que valen

No son cinco por casualidad: cada una afirma algo que alguna fase anterior **decidió**.

```php
<?php
// server/tests/InvariantTest.php
// Afirma la invariante de be05. Es la prueba más importante del track: si esta
// falla, el sistema está emitiendo certificados contra normas inexistentes.

declare(strict_types=1);

class InvariantTest extends TestCase
{
    use DatabaseTransactions;

    /** @test */
    public function una_inspeccion_no_puede_apuntar_a_una_version_inexistente(): void
    {
        $this->expectException(\Illuminate\Database\QueryException::class);

        // La restricción NOT VALID de be05 tiene que impedir esto en la base,
        // no en el código. Por eso la prueba escribe DIRECTO con el query
        // builder: si pasara por el servicio, estaría probando el servicio.
        DB::table('inspections')->insert([
            'asset_id' => 'ASC-CENTRAL-03',
            'inspector_id' => 'INS-15',
            'template_id' => 'elevator-annual',
            'template_version' => 99,          // no existe
            'status' => 'requested',
            'started_at' => '2026-01-15 09:00:00',
            'answers' => '[]',
        ]);
    }

    /** @test */
    public function las_filas_historicas_que_la_violan_siguen_siendo_legibles(): void
    {
        // La otra cara, y es igual de importante: contener no es corregir.
        // Si esta prueba falla, alguien "limpió" el histórico.
        $huerfanas = DB::select("
            SELECT count(*) AS total FROM inspections i
            LEFT JOIN templates t
              ON t.template_id = i.template_id AND t.version = i.template_version
            WHERE t.template_id IS NULL
        ");

        $this->assertGreaterThan(0, (int) $huerfanas[0]->total,
            'El histórico sucio desapareció: alguien reescribió datos que no se tocan.');
    }
}
```

Las otras tres, en una línea cada una: **el contrato de un endpoint por cada camino** —la misma aserción contra los dos, que es lo que revela la divergencia—; **la paginación compatible hacia atrás** —sin `_page` devuelve todo—; y **la regresión del incidente `be-09`**, que es el que produjo la investigación de be05.

> 🧭 **Una prueba vale si su fallo te dice qué decisión se rompió.** "La invariante ya no se sostiene" es una prueba. "El método devuelve un array" no lo es.

### 5.5 La pieza que decide: `500` o `422`, según por dónde entres

Aquí es donde los dos caminos dejan de ser un problema estético.

```php
// Camino viejo (parcela laravel): no valida, deja explotar.
$router->post('/findings', function (Request $request) {
    return Finding::create($request->all());   // severity inválido → QueryException → 500
});

// Camino nuevo (parcela symfony): valida y responde 422 con detalle.
public function store(Request $request): JsonResponse
{
    $this->validate($request, ['severity' => 'required|in:critical,major,minor']);
    // …
}
```

El mismo dato malo produce un `500` por una puerta y un `422` por la otra. **Las dos respuestas son defendibles**; lo que no es defendible es que dependa de la puerta.

Y la decisión, que es de esta fase y hay que tomarla: **gana el que el frontend consume**, siempre. No el más correcto: el que ya tiene un cliente. Si el frontend espera el `500` y le das un `422`, has roto una pantalla para mejorar un código de estado — y la regla del track es que el contrato manda sobre la elegancia.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Escribir pruebas antes de decidir cuál es el camino oficial.**
*Síntoma:* dos suites verdes que afirman cosas incompatibles sobre el mismo recurso.
*Causa:* probar lo que el código hace en vez de lo que el sistema debe hacer.
*Fix mínimo:* decide primero, escribe después. Y si no puedes decidir, **eso es el hallazgo**: anótalo en `SUPERFICIE.md` como decisión pendiente con nombre y apellido.

**Probar contra SQLite "porque es más rápido".**
*Síntoma:* la suite pasa en verde y producción falla con una violación de restricción.
*Causa:* otro motor, otro dialecto, otra semántica. Todo lo que be04 y be05 enseñaron desaparece.
*Fix mínimo:* contra el `postgres:16.9` del compose, con transacción envuelta. Si va lento, el problema es la limpieza, no el motor.

**Perseguir un porcentaje de cobertura.**
*Síntoma:* cuarenta pruebas, 70% de cobertura, y el incidente `be-09` se habría colado igual.
*Causa:* la cobertura mide líneas ejecutadas, no decisiones protegidas. Con dos caminos vivos, además, mide el doble de lo mismo.
*Fix mínimo:* por cada prueba, escribe en una línea **qué decisión protege**. Las que no puedan contestar, sobran.

**Empezar a borrar el camino no oficial.**
*Síntoma:* un diff enorme en una fase de ocho horas.
*Causa:* la decisión estaba tomada y parecía el siguiente paso natural.
*Fix mínimo:* revierte. Borrar depende del *assessment*: si la respuesta es *estrangular por endpoint*, ese código se va por otro camino y con otro orden.

### Pieza forense de esta fase

**"A veces devuelve 500 y a veces 422".**

El ticket tiene razón, y ése es el punto: no es intermitente, es **dependiente de la ruta**, y quien lo reportó no tenía cómo saberlo.

1. **Reproduce las dos, con el mismo cuerpo.**
   ```bash
   curl -sS -o /dev/null -w '%{http_code}\n' -X POST localhost:3000/findings \
        -H 'Content-Type: application/json' -d '{"severity":"catastrofico"}'
   curl -sS -o /dev/null -w '%{http_code}\n' -X POST localhost:3000/v2/findings \
        -H 'Content-Type: application/json' -d '{"severity":"catastrofico"}'
   #   500
   #   422
   ```
   En dos comandos ya sabes que no es azar. **Ese es el paso que convierte "a veces" en "depende de".**
2. **Pregunta quién llama a cada una.** `grep` en `src/` del frontend. Si sólo una tiene cliente, la decisión está tomada por los hechos.
3. **Mira qué produce el `500`.** Una `QueryException` que llega al manejador sin traducir: la base rechazó el valor. No es un fallo del servidor, es **una validación que ocurre en la capa equivocada y con el vocabulario equivocado**.
4. **Y la pregunta que cierra:** ¿cuántos recursos más tienen este par? La tabla de §5.1 lo contesta, y ése es el número que mide de verdad la superficie.

> 🧠 **"A veces" casi nunca significa azar: significa una variable que quien reporta no puede ver.** En el track base era el caos, la caché o el reloj. Aquí es la ruta. El método es el mismo: **encontrar de qué depende el "a veces"**.

> 🧨 **Rompe a propósito y observa.** Haz que el camino viejo devuelva `422` como el nuevo. Corre el `smoke.sh` —probablemente pase— y después entra a la aplicación y crea un hallazgo inválido. Anota qué ve el usuario, y si mejoró o empeoró. Después responde lo difícil: **¿cómo sabrías, sin preguntarle a nadie, si alguna pantalla dependía del `500`?** Si tu respuesta es "no puedo saberlo", acabas de entender por qué el contrato manda sobre la elegancia — y por qué un sistema sin pruebas te obliga a ser conservador aunque tengas razón.

---

## 🧪 7. Ejercicios (29)

**🟢 Fácil (1–7)**

1. Instala PHPUnit 8.5 en el contenedor y haz que `./vendor/bin/phpunit` dé verde con una prueba trivial. Pega la versión exacta.
2. Cuenta las rutas declaradas y clasifícalas por camino. Rellena las tres primeras columnas de la tabla de §5.1.
3. **Diagnóstico.** Reproduce el `500` y el `422` con los dos `curl`. Pega las dos salidas.
4. Mide el tiempo de la suite con una sola prueba y con diez. Extrapola a cien.
5. **Diagnóstico.** Averigua, con `grep` sobre `src/`, cuál de los dos caminos usa el frontend para cada recurso. Rellena la cuarta columna.
6. Escribe la prueba de la invariante de §5.4 y comprueba que falla si quitas la restricción de be05.
7. Compara el tiempo de `DatabaseTransactions` con el de `migrate:fresh` por prueba. Anota los dos números.

**🟡 Intermedio (8–18)**

8. **Diagnóstico.** Encuentra los endpoints "a medias dentro de sí mismos" (número 2 de §5.1). Para cada uno, di qué parte es de cada camino.
9. Rellena la quinta columna de la tabla: **decide** cuál es el camino oficial de cada recurso, con un criterio escrito. El criterio importa más que la elección.
10. **Diagnóstico.** Escribe la misma prueba de contrato contra los dos caminos de un recurso y documenta todas las diferencias que aparezcan.
11. Escribe la prueba de paginación compatible hacia atrás y comprueba que falla si alguien pone el límite por defecto sin `_page`.
12. **Diagnóstico.** Escribe la regresión del incidente `be-09` y verifica que falla contra el código de antes de be05 (`git stash` la migración de la restricción).
13. Mide el tiempo de ciclo de la suite completa y decide si hace falta cambiar la estrategia de limpieza. Justifica con el número.
14. **Diagnóstico.** Encuentra una prueba que pasaría con los dos caminos y por tanto no decide nada. Reescríbela para que decida.
15. Lee `bootstrap/app.php` (be01 §5.3) y haz la lista de todo lo que habría que reescribir para cruzar a Laravel. Cuenta las líneas.
16. **Diagnóstico.** Cuenta cuántos sitios escriben en `inspections` (número 3). Con ese número, revisa la salida C de be05 —disciplina de aplicación— y di si habría sido viable.
17. Escribe una prueba que compruebe la vigencia de un certificado en los bordes: 23:59:59 y 00:00:00 en `America/Bogota` ([`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md)). ¿Pasa?
18. **Diagnóstico.** Marca las pruebas que necesitan `COMMIT` de verdad y cámbialas a `TRUNCATE`. Mide cuánto se encarece la suite.

**🟠 Difícil (19–25)**

19. **Diagnóstico.** Estima el coste de terminar la migración con los tres números de §5.1 y los supuestos escritos. Después estima el de **no terminarla** durante dos años: cada cambio hecho dos veces, cada persona nueva eligiendo, cada divergencia. Presenta las dos cifras juntas.
20. Diseña el plan de estrangulamiento por endpoint: en qué orden moverías los seis recursos, con qué criterio, y qué mides después de cada uno. Una página.
21. **Diagnóstico.** Toma el endpoint que el frontend **no** usa y bórralo en una rama. ¿Qué se rompe? ¿Cuánto tardaste en saberlo? ¿Qué te lo dijo: las pruebas, el `smoke.sh`, o nada?
22. Escribe la prueba que habría detectado el fallo del script de respaldo de be04. Si no se puede escribir, explica por qué y qué haría falta en su lugar.
23. **Diagnóstico.** Añade `xdebug` o `pcov` y saca la cobertura. Después escribe dos párrafos sobre por qué ese número miente en este sistema concreto. Sé específico: nombra dos zonas de código que la cobertura cuenta dos veces.
24. Escribe la guía de una página para la próxima persona: cuál es el camino oficial de cada recurso, cómo se escribe una prueba aquí, y qué no se toca. Es el documento que nadie escribió en 2020.
25. **Diagnóstico adversarial.** Alguien propone terminar la migración *"en los ratos libres, sin proyecto"*. Escribe la respuesta en dos párrafos: qué pasó las tres veces anteriores (be02), por qué una migración sin dueño produce exactamente el estado en el que estás, y cuál es la versión mínima viable de esa propuesta que sí podría funcionar.

**🔴 Muy difícil (26–29)**

26. **Diagnóstico.** Escribe el informe *"superficie de la reescritura a medias"* que be07 va a consumir: los tres números, la tabla de decisiones, el coste de terminar y el de no terminar, y **qué pasa si no se hace nada durante dos años más**. Dos páginas, con la metodología al lado de cada cifra.
27. Demuestra con código que el cruce a Laravel es un trasplante: coge **un** controlador y hazlo funcionar bajo un esqueleto de Laravel en una rama aparte. Anota qué se salvó tal cual, qué se reescribió, y cuánto tardaste. Multiplícalo por el número de controladores y **discute honestamente por qué esa multiplicación es optimista**.
28. **Diagnóstico.** Con los números de los ejercicios 19 y 27 en la mano, responde: ¿terminar la migración o empezar de cero? Defiende tu respuesta, y después **escribe la mejor defensa de la contraria**. Si la segunda no te sale convincente, no has entendido el problema.
29. **Diagnóstico adversarial.** Un consultor propone subir a PHP 8 "primero, y ya después vemos". Demuestra con el `composer.json` y las fechas de be01 que eso **es** el trasplante de bootstrap, no un paso previo. Después concede lo que tiene de razón —el runtime está EOL y eso no se arregla solo— y di dónde se decide de verdad esa conversación.

**🔥 Opcionales**

- 🔥 Monta la suite en un pipeline que corra en cada commit y mide cuánto tarda de principio a fin. Después argumenta si un pipeline sobre un sistema con fecha de decomisión sin decidir es una inversión o una distracción.
- 🔥 Escribe una prueba de contrato generada automáticamente desde `CONTRACT.md`. Después compárala con el `smoke.sh` y decide si alguno de los dos sobra.

---

## 📚 8. Referencias

**Documentación oficial**
- https://phpunit.readthedocs.io/en/8.5/ — la documentación de PHPUnit **8.5**, que es la línea que admite Lumen 5.8 (`"phpunit/phpunit": "^7.0|^8.0"`). ⚠️ Si acabas en la documentación de PHPUnit 10 u 11, las anotaciones y la configuración son otras.
- https://lumen.laravel.com/docs/5.8/testing — las utilidades de prueba que trae el framework, incluida `createApplication()`.
- https://laravel.com/docs/5.8/database-testing — las estrategias de limpieza. ⚠️ Es documentación de Laravel: el `RefreshDatabase` que describe no existe igual en Lumen, y por eso el *trait* de §5.3 es propio.
- https://packagist.org/packages/laravel/lumen-framework — el historial de versiones, para comprobar por ti mismo la restricción de PHPUnit de la línea 5.8.

**Libros / artículos de referencia**
- *Working Effectively with Legacy Code* (Michael Feathers, 2004), capítulos 6 a 9 — cómo poner bajo prueba código que no se diseñó para ello, y el concepto de *seam*, que es exactamente lo que buscas al elegir por dónde entra cada prueba.
- *Monolith to Microservices* (Sam Newman, O'Reilly, 2019), capítulo 3 — el patrón *strangler fig* y, más útil aquí, el capítulo sobre por qué las migraciones a medias son el estado más caro.

**Video / apoyo**
- https://www.youtube.com/results?search_query=strangler+fig+pattern+migration — busca charlas que cuenten una migración **que no terminó**: son más raras y valen el doble.

**Orden de lectura sugerido:** tu propio `ESTRATOS.md` (be02) **antes** de medir la superficie → Feathers **mientras** escribes las tres primeras pruebas → [`bea-09`](bea-09-symfony-como-vara-de-medir.md) **cuando estimes el coste de cruzar** → [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) **al final**, porque el runtime EOL es lo que convierte esta conversación en urgente y es el insumo de be07.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. Y con PHPUnit la advertencia es fuerte: **la mayor parte de lo que encuentres es de la línea 9 o posterior**, con atributos de PHP 8 que aquí no existen. Comprueba la versión en la URL antes de copiar una anotación.

---

## 🚀 9. Cierre y conexión con la siguiente fase

La reescritura a medias tiene tres números y una tabla de decisiones donde antes había una sensación. Hay cinco pruebas que protegen decisiones reales —la invariante la primera— y una suite que corre en segundos contra el mismo PostgreSQL que sirve la aplicación. Y sabes que el camino de vuelta no es un upgrade, con el `bootstrap/app.php` como prueba.

Y tienes las dos cifras que nadie había puesto juntas: lo que cuesta terminar, y lo que cuesta no terminar.

**be07** es el cierre y no es código. Es el documento que ningún tutorial de internet enseña a producir, porque todos terminan en el *happy path* del rewrite: un *assessment* de riesgo tecnológico con **cuatro opciones costeadas**, todas con números que las siete fases anteriores produjeron. Los tuyos ya están: el coste de rotación de be02, la evidencia de versiones de be04, el censo de violaciones de be05, y la superficie de esta fase.

> **La señal de que quedó bien:** *"dejé de decir 'a veces devuelve 500' y empecé a decir 'devuelve 500 por esta ruta y 422 por esta otra, y la oficial es ésta porque el frontend la consume'."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-06-la-reescritura-a-medias \
>   -m "be06 cerrada: superficie medida con tres números y camino oficial decidido por recurso;
> PHPUnit 8.5 corriendo contra postgres:16.9 con transacción envuelta;
> cinco pruebas que protegen decisiones, invariante incluida;
> coste de terminar y de no terminar, estimados juntos"
> ```
>
> Los commits de esta fase llevan `be06: …` y los de ejercicio `be06 ej27: …`.
>
> Esta fase estrena algo en el track: **una prueba que falla contra un tag anterior**. `git stash` sobre la migración de be05 y `InvariantTest` se pone rojo — esa es la demostración de que la prueba prueba algo. Guarda el experimento del ejercicio 12 con `ej/be06/12`. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥.

---

## 📌 Pendientes sugeridos

- **El camino no oficial no se borra** (💸 de §5.1). Depende del *assessment*. → **be07** si elige terminar la migración; **`bea-10`** como deuda aceptada si elige estrangular o esperar.
- **La columna `certificates.status` sigue existiendo** (💸 de be05 §5.4) y ahora hay pruebas y hay decisión sobre cuál es el camino oficial de emisión — es decir, **ya se puede borrar**. No cabía en esta fase. → **Primer candidato de limpieza** cuando be07 dé una dirección.
- **La cobertura miente en este sistema** (ejercicio 23) y conviene que quede dicho en un sitio permanente, no en un ejercicio. → **`bea-10`**, y una línea en la guía del ejercicio 24.
- **El archivo con `exit` de be02 rompe cualquier prueba que lo toque**, porque corta el ciclo antes del `tearDown`. Se documenta y no se arregla. → **`bea-10`**, con su razón; y candidato de limpieza junto con el camino no oficial.
- **PHP 7.4 EOL sigue siendo la premisa.** Esta fase demuestra que subirlo es el trasplante de bootstrap, y ahí se queda. → **be07**, con [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) al lado para costear la opción de no hacer nada.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| **be-11** | "A veces devuelve 500 y a veces 422 con el mismo dato" | Dos caminos vivos · validación en capas distintas | 🟠 |
MDEOF
wc -l be06-la-reescritura-a-medias.md

# --- 2026-09-11T18:38:19 · Close PHPUnit decision in propuesta
python3 - <<'PY'
p='prompts/propuesta-fases-backend.md'
s=open(p).read()
old="""**4. La versión de PHPUnit de la línea de Lumen 5.8** ⚠️ — sigue abierta. No la
necesita ninguna fase hasta `be06`, que es donde llegan las pruebas."""
new="""**4. La versión de PHPUnit — ✅ CERRADA el 11/09/2026 al escribir `be06`.** El
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
escribiendo pruebas."""
assert old in s
open(p,'w').write(s.replace(old,new,1))
print('ok')
PY

# --- 2026-09-11T18:40:01 · Write bea-08 appendix
cat > bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md <<'MDEOF'
# 📎 Apéndice bea-08 — Seguridad de API sobre un runtime sin parches

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **4 horas**
> Usado por: **be06**, **be07** · Versiones cubiertas: PHP **7.4.33** (**EOL desde el 28 de noviembre de 2022**), Lumen **5.8.13**
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido.** Se entra buscando qué hacer con un riesgo concreto —*"tengo SQL a mano y no puedo parchear el runtime"*— y se sale con la compensación y con la forma de documentarlo.

🧭 **El ángulo, que es lo que lo diferencia de cualquier checklist de OWASP: el runtime está EOL y eso no se va a arreglar.** Es la premisa del track, no un pendiente. La pregunta no es *"¿cómo lo actualizo?"* —eso es el trasplante de bootstrap de [`be06`](be06-la-reescritura-a-medias.md) y la decisión de [`be07`](be07-el-assessment-de-riesgo.md)—, es **"¿qué hago mientras tanto, y cómo lo documento para que la decisión la tome quien debe?"**.

**Qué queda fuera:** asesoría de seguridad —esto es material didáctico, no un dictamen—; **pruebas de intrusión** y cualquier técnica ofensiva; y cualquier receta que dependa de infraestructura que no tengas. Este apéndice enseña a **detectar, compensar y escalar**, y las tres palabras son literales.

---

## Índice

- [La premisa, dicha sin rodeos](#la-premisa-dicha-sin-rodeos)
- [OWASP sobre este dominio, en cuatro riesgos](#owasp-sobre-este-dominio-en-cuatro-riesgos)
- [Las capas de compensación](#las-capas-de-compensación)
- [Cómo se documenta y se escala un riesgo aceptado](#cómo-se-documenta-y-se-escala-un-riesgo-aceptado)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-7)

---

## La premisa, dicha sin rodeos

PHP 7.4 dejó de recibir parches de seguridad el **28 de noviembre de 2022**. La imagen `php:7.4-cli` tuvo su último *push* el **15 de noviembre de 2022** — se congeló, literalmente, el día que el runtime llegó a su fin de vida. Y la base del sistema operativo de esa imagen, Debian 11 *bullseye*, también terminó su ciclo (es la historia de la cápsula del tiempo de [`bea-02`](bea-02-receta-de-imagen-y-compose.md)).

Eso significa que **hay tres capas sin parches**: el sistema operativo de la imagen, el runtime, y el framework. No una.

> 🧠 **Un sistema sin parches no es un sistema inseguro: es un sistema cuyo riesgo crece solo, todos los meses, sin que nadie haga nada.** Ésa es la diferencia que hay que saber explicar, porque es la que convierte "no ha pasado nada" en un argumento malo.

Y la consecuencia práctica que ordena el apéndice: **si no puedes parchear, sólo te quedan tres movimientos** — reducir la superficie, compensar en otra capa, y documentar lo que queda. Ninguno de los tres arregla nada. Los tres se hacen igual.

⚠️ **Sobre los CVE concretos:** el listado de vulnerabilidades de PHP 7.4 posteriores a su EOL hay que consultarlo **en el aviso oficial y con fecha** —nunca de memoria y nunca desde este documento—, y hay que asumir que **la lista crece**. Este apéndice envejece por diseño: lo que enseña es el método, no el inventario.

---

## OWASP sobre este dominio, en cuatro riesgos

No la lista entera: los cuatro que este sistema tiene de verdad, cada uno con dónde vive exactamente en `certcore-api`.

### 1. Inyección SQL, y sabemos dónde está

Eloquent usa marcadores y no es inyectable. **El riesgo vive, entero, en el SQL a mano** — que es exactamente donde [`be04`](be04-el-salto-de-version-que-nadie-corrio.md) dijo que estaban también los bugs de dialecto. Ese archivo ya lo tienes:

```bash
cd server
grep -rn "DB::select(\|DB::raw(\|DB::statement(" app/ > ../SQL-CRUDO.txt
# Y ahora lo que importa: ¿cuáles CONCATENAN en vez de usar marcadores?
grep -n '\$' ../SQL-CRUDO.txt | grep -v '?'
```

```php
// ❌ Inyectable: la variable entra en el texto de la consulta.
DB::select("SELECT * FROM certificates WHERE status = '" . $status . "'");

// ✅ Con marcador: el valor viaja aparte y nunca se interpreta como SQL.
DB::select('SELECT * FROM certificates WHERE status = ?', [$status]);

// ⚠️ El caso que los marcadores NO cubren: identificadores.
// Un nombre de columna no puede ser un marcador. Si viene de fuera, sólo
// hay una defensa: una LISTA BLANCA. Escapar no basta.
$allowed = ['issued_at', 'valid_until'];
$column = in_array($request->query('sort'), $allowed, true) ? $request->query('sort') : 'issued_at';
```

> 🧭 **La lista blanca no es "una forma de validar": es la única defensa para lo que no admite marcadores.** Ordenaciones dinámicas, nombres de tabla, direcciones de ordenación. Si te descubres escapando un identificador, estás resolviendo el problema equivocado.

### 2. Autorización a nivel de objeto, que aquí significa algo concreto

En una certificadora: **que un cliente no vea los activos de otro.** Es el riesgo más probable de este sistema y el más fácil de pasar por alto, porque no produce ningún error.

```php
// ❌ Comprueba que estás autenticado. No comprueba que sea TUYO.
$router->get('/assets/{id}', function ($id) {
    return Asset::find($id);
});
```

El token de CertCore trae `sub` y `role`, y **el `role` no autoriza nada** — el track base lo declaró explícitamente en su Fase 2. Cambiar eso es una decisión de producto, no de este apéndice; lo que sí corresponde aquí es **detectarlo y escribirlo**:

```bash
# Rutas con {id} — cada una es un candidato a acceso directo a objeto.
grep -rn "{id}\|{.*}" server/routes/web.php
```

Para cada una, contesta tres preguntas: ¿quién puede pedirla?, ¿qué pasa si cambio el id por otro?, ¿lo habría notado alguien? **La tercera es la que duele.**

### 3. Asignación masiva

```php
// ❌ Todo lo que llegue en el cuerpo entra en la fila.
Certificate::create($request->all());
```

Con eso, un cliente puede mandar `{"status": "valid", "revoked_at": null}` sobre un certificado revocado. En Eloquent la defensa es declarativa y va **en el modelo**:

```php
class Certificate extends Model
{
    // Lista blanca de lo que se puede asignar en masa. Todo lo demás se ignora.
    protected $fillable = ['inspection_id', 'issued_at', 'valid_until'];

    // Y lo que nunca se expone al serializar, aunque esté en la fila.
    protected $hidden = ['internal_notes'];
}
```

⚠️ `$guarded = []` —que aparece en muchos ejemplos— **desactiva la protección entera**. Si lo encuentras en el código heredado, es un hallazgo, no un estilo.

### 4. Lo que exponen los mensajes de error

```bash
docker compose exec api php -r 'var_dump(getenv("APP_DEBUG"));'
```

Con `APP_DEBUG=true`, una excepción devuelve la traza completa: rutas del sistema de archivos, nombres de clase, fragmentos de consulta y, con suerte para quien mira, valores. Es información de reconocimiento gratis.

La regla es de una línea y no tiene excepciones: **`APP_DEBUG=false` en cualquier entorno que no sea tu portátil**, y el detalle al log del contenedor, que es donde tiene que estar de todas formas ([`bea-01`](bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md)).

Y un caso propio de este track: **`tools/probe.php` usa `eval()`** ([`be01`](be01-lumen-y-la-familiaridad-falsa.md) §5.8). Es correcto en una herramienta de laboratorio que no se despliega y que sólo ejecuta quien ya tiene una terminal dentro del contenedor; sería una puerta trasera completa si acabara en el artefacto de despliegue. **La diferencia entre "peligroso" y "peligroso aquí" es dónde vive el archivo**, y por eso excluirlo del despliegue es una línea de configuración que hay que escribir, no una confianza.

---

## Las capas de compensación

Cuando el runtime no se puede parchear, la defensa se mueve a las capas que sí controlas. Ninguna sustituye al parche; todas reducen la probabilidad o el alcance.

| Capa | Qué compensa | Qué **no** compensa |
|---|---|---|
| **Reducir la superficie** | Endpoints que nadie usa, herramientas de laboratorio, extensiones de PHP de más, `APP_DEBUG` | Nada de lo que sí se usa |
| **Red** | Exposición directa: la API detrás de un proxy, la base **sin puerto publicado** | Un fallo en un endpoint legítimo |
| **WAF / filtro delante** | Patrones conocidos de inyección y recorrido de rutas | Lógica de negocio, autorización |
| **Límites de tasa** | Fuerza bruta, enumeración de identificadores | Un único acceso bien dirigido |
| **Registro y alerta** | Nada — pero es lo único que te dice que pasó | Que pase |
| **Aislamiento** | El alcance: qué puede tocar el proceso si cae | La caída |

Las tres que en este laboratorio ya están puestas y conviene reconocer: **la base no publica el 5432** (`bea-02`), **`pdo_pgsql` es la única extensión instalada**, y **el código va montado, no copiado** — lo cual es cómodo en desarrollo y sería un error en un despliegue, y ahí está la diferencia entre un laboratorio y un sistema.

> 🧭 **La reducción de superficie es la única compensación que no cuesta dinero ni añade una pieza nueva que mantener.** Empieza siempre por ahí: cada endpoint que borras, cada extensión que no instalas y cada variable de depuración que apagas es riesgo que desaparece en vez de mudarse.

---

## Cómo se documenta y se escala un riesgo aceptado

Ésta es la parte que alimenta el *assessment* de [`be07`](be07-el-assessment-de-riesgo.md), y es la que casi nadie escribe.

Un riesgo aceptado **no es un riesgo ignorado**. La diferencia son cinco campos:

```markdown
## R-01 · Runtime sin parches de seguridad

**Qué es.** `certcore-api` corre sobre PHP 7.4.33, sin soporte de seguridad desde
el 28/11/2022. El sistema operativo de la imagen y el framework están igual.

**Qué podría pasar.** Una vulnerabilidad publicada del runtime no tendrá parche.
La exposición depende de qué componentes procesen entrada externa.

**Probabilidad y alcance.** [Con criterio y fecha, no con adjetivos.]

**Qué se ha hecho para compensar.** Superficie reducida (n endpoints retirados),
API detrás de proxy, base sin puerto publicado, `APP_DEBUG=false`, SQL crudo
revisado (n consultas, todas con marcadores).

**Qué haría falta para eliminarlo.** Subir a PHP 8, que implica el trasplante de
bootstrap de be06: estimación en `SUPERFICIE.md`.

**Quién lo acepta y hasta cuándo.** ← EL CAMPO QUE HACE QUE ESTO SIRVA.
Nombre, cargo, fecha de aceptación y **fecha de revisión**. Sin los dos últimos,
esto es un archivo; con ellos, es una decisión.
```

> 🧠 **Un riesgo sin dueño y sin fecha de revisión no está aceptado: está escondido.** Escalar no es quejarse por correo: es poner el riesgo por escrito, con su compensación y su coste de eliminación, delante de quien tiene el presupuesto — y conseguir una firma o un *no* con fecha. Las dos respuestas sirven; el silencio, no.

Y la frase que hay que poder decir sin que suene a excusa: *"no es un fallo técnico pendiente, es una decisión de negocio que necesita a alguien que la tome."*

---

## 🧭 Cuándo usar qué

| Síntoma o situación | Qué hacer primero | Después |
|---|---|---|
| Hay SQL crudo | Comprobar marcadores, no escapado | Lista blanca para identificadores |
| Ruta con `{id}` sin comprobación de dueño | Documentarla como riesgo | Decidir si el producto necesita autorización por objeto |
| `create($request->all())` | `$fillable` en el modelo | Buscar `$guarded = []` en todo el proyecto |
| Trazas en las respuestas | `APP_DEBUG=false` | Registro estructurado al log del contenedor |
| Herramienta de laboratorio con `eval()` | Excluirla del artefacto de despliegue | Comprobarlo en el pipeline |
| No se puede parchear el runtime | Reducir superficie | Compensar en red, documentar, escalar |
| Alguien pide bajar la seguridad de la base para un cliente viejo | **No** | Subir el cliente, o excepción documentada con fecha |
| Te piden un dictamen de seguridad | Detectar, compensar, escalar | Y decir que no eres el dictamen |

---

## ⚠️ Advertencias

**Este apéndice no es una auditoría de seguridad y no la sustituye.** Enseña a detectar lo evidente, compensar lo que se pueda y escalar el resto. Si el sistema maneja datos de terceros bajo obligación regulatoria —y una certificadora los maneja—, la conversación incluye a cumplimiento y a alguien con mandato, no sólo al equipo.

**Ningún ejercicio de este apéndice es ofensivo.** Todos son de detección y de documentación. Este track no enseña a explotar nada, y no porque sea difícil: porque no es el oficio que entrena.

**La lista de vulnerabilidades crece y este documento no.** Cita siempre el aviso oficial con fecha. Un inventario de CVE escrito en un `.md` envejece mal y da falsa tranquilidad — que es peor que no tener ninguno.

---

## 📚 Referencias

- https://owasp.org/API-Security/editions/2023/en/0x11-t10/ — el top 10 de seguridad de API. Los cuatro riesgos de arriba salen de aquí, aplicados a este dominio.
- https://owasp.org/www-project-top-ten/ — el clásico, para el contexto general.
- https://www.php.net/supported-versions.php — el calendario de soporte. La fila de 7.4 dice **28 de noviembre de 2022**.
- https://www.php.net/ChangeLog-7.php — el registro de cambios de PHP 7, donde se ve **qué dejó de recibir correcciones y cuándo**.
- https://nvd.nist.gov/vuln/search — la base nacional de vulnerabilidades, para consultar con fecha en vez de citar de memoria.
- https://laravel.com/docs/5.8/eloquent#mass-assignment — `$fillable` y `$guarded` en la línea contemporánea de este sistema.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos. Y con los avisos de vulnerabilidades, **la fecha de consulta es parte del dato**: escribe siempre *"consultado el DD/MM/AAAA"* junto a cualquier afirmación sobre qué hay publicado.

---

## 🧪 Ejercicios (7)

Ninguno es ofensivo: todos son de detección y de documentación.

1. Genera `SQL-CRUDO.txt` y clasifica cada consulta: con marcadores, con concatenación, o con identificador dinámico. Anota el número de cada clase.
2. **Diagnóstico.** Busca `$guarded = []` y `create($request->all())` en `server/app/`. Para cada hallazgo, escribe qué campo podría sobrescribirse y qué significaría eso en el dominio de certificaciones.
3. Lista las rutas con `{id}` y contesta las tres preguntas de autorización por objeto para cada una. Marca las que un cliente podría usar para ver datos de otro.
4. **Diagnóstico.** Con `APP_DEBUG=true`, provoca una excepción y anota **exactamente** qué información aparece en la respuesta. Después ponlo en `false` y repite. Compara las dos salidas línea a línea.
5. Escribe la ficha de riesgo `R-01` completa, con los siete campos, incluida la fecha de revisión. Después identifica en tu organización —real o imaginaria— **quién tendría que firmarla**.
6. **Diagnóstico.** Haz el inventario de reducción de superficie: endpoints que nadie llama (el `CONTRACT.md` de be00 lo dice), extensiones de PHP instaladas, variables de depuración, y herramientas de laboratorio que no deberían desplegarse. Cuantifica cuánto se reduce.
7. **Diagnóstico.** Consulta hoy, con fecha, cuántas vulnerabilidades con CVE afectan a PHP 7.4 publicadas **después** del 28/11/2022. Anota el número y la fuente. Después escribe en tres líneas por qué ese número, por sí solo, **no** decide nada — y qué haría falta añadirle para que decidiera.

---

> 🏷️ **Este apéndice no lleva tag propio.** Lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be06: …`, `be07: …`). La ficha de riesgo del ejercicio 5 sí es un entregable que sobrevive: vive en el *assessment* de be07 y se cita en [`bea-10`](bea-10-mapa-de-deuda-del-track-be.md) como la deuda insignia del track. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
MDEOF
wc -l bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md

# --- 2026-09-11T18:43:09 · Write be07 final phase
cat > be07-el-assessment-de-riesgo.md <<'MDEOF'
# 📊 Fase be07 — El *assessment* de riesgo tecnológico

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Fase be07 de be07 · **10 horas**
> Depende de: **be00 a be06 cerradas** — esta fase consume los números que todas produjeron · Habilita: nada. Es el cierre del track
> Apéndices de apoyo: [`bea-09`](bea-09-symfony-como-vara-de-medir.md) · [`bea-10`](bea-10-mapa-de-deuda-del-track-be.md) · [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) · Incidentes asociados: **be-12**
> Estilo de esta fase: **no se escribe código.** Se escribe un documento y se defiende

> 🔥 **Esta fase pertenece al track opcional de backend.** El track base se completa sin abrirla.

---

## 🎯 1. Propósito

Escribir y defender el documento que ningún tutorial de internet enseña a producir, porque todos terminan en el *happy path* del rewrite.

Siete fases produjeron números. Esta los convierte en una decisión que alguien puede firmar — y, sobre todo, en una decisión que se puede **discutir con datos** delante de gente que prefiere otra.

> 🧭 **La regla que gobierna la fase:** *la respuesta correcta depende de la fecha de decomisión, no de la calidad del código.* Un sistema con dos años de vida por delante y uno con diez no reciben la misma respuesta aunque el código sea idéntico.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `ASSESSMENT.md` existe, tiene el índice de §5.1 completo, y **cada cifra dice de qué fase sale**. Ninguna estimación sin fuente o, si la hay, está marcada como inventada.
- [ ] Las **cuatro opciones** están costeadas con el mismo formato: coste, plazo, qué se rompe mientras, qué riesgo elimina, qué riesgo deja.
- [ ] La **recomendación** está escrita, con su criterio, y **depende explícitamente de la fecha de decomisión**. Hay al menos dos escenarios de fecha con respuestas distintas.
- [ ] El **cierre honesto** está: dónde Lumen de verdad ganó, **con el número de las dos columnas**.
- [ ] La ficha de riesgo del runtime EOL (`R-01` de [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md)) está incorporada, con dueño y fecha de revisión.
- [ ] Defendiste el documento ante alguien —una persona, o tú mismo por escrito— que **prefiere el rewrite**, y las objeciones están respondidas dentro del documento, no aparte.
- [ ] Desmontaste el *assessment* adversarial del incidente **be-12**.

---

## 🚫 3. Qué NO entra

- **Ejecutar la decisión.** El track termina con el documento. Lo que venga después no cabe en diez horas y, sobre todo, no es lo que este track entrena.
- **Código.** Ni una línea. Si acabas programando, te saliste.
- **Inventar números.** Si una cifra no sale de una fase, se marca como estimación y se dice en qué se apoya. **Es literalmente lo que la fase enseña.**

---

## 🧠 4. Concepto mínimo

### Qué es un *assessment* y qué no es

No es una propuesta técnica ni un plan de migración. Es **un documento de decisión**: describe el estado, cuantifica el riesgo, presenta opciones costeadas, recomienda una, y deja claro **quién tiene que decidir y con qué información**.

Tres propiedades lo separan de lo que la mayoría de la gente escribe:

1. **Las opciones son de verdad.** Si tres de las cuatro son de paja, es una propuesta disfrazada y el lector lo nota en dos minutos.
2. **Los números tienen origen.** Cada cifra dice de dónde sale. Las que no salen de ningún sitio se marcan como lo que son.
3. **La recomendación es condicional.** *"Depende de X"* no es tibieza: es la forma honesta cuando X de verdad cambia la respuesta — y aquí X es la fecha de decomisión.

🪞 **Tu instinto dice "hay que reescribir esto"… y esta vez puede que se equivoque.** Después de siete fases mirando lo que está mal, la conclusión emocional es evidente. Y la respuesta correcta depende de un dato que **no está en el código**: cuántos años le quedan al sistema. Éste es el momento del track en que hay que separar *"tengo razón sobre el código"* de *"tengo razón sobre qué hacer"*.

### El estado, en una página

Lo que las siete fases establecieron, y es el resumen que abre el documento:

| Hecho | De dónde sale |
|---|---|
| El runtime está **EOL desde el 28/11/2022**; la imagen se congeló el 15/11/2022 | be01, `bea-08` |
| El framework es **Lumen 5.8.13** (28/08/2019), última de su línea. Su restricción `php ^7.1.3` **excluye PHP 8** | be01 |
| El primer Lumen con PHP 8 es **9.0.0** (15/02/2022): cuatro versiones mayores más arriba | be01 |
| **Lumen no tiene calendario de soporte** ni LTS ni avisos de deprecación | `bea-09` |
| El código tiene **cuatro procedencias** conviviendo, medidas archivo por archivo | be02 |
| **Tres rotaciones en ocho años**, permanencia media 18 meses, aprendizaje no transferible | be02 |
| La base subió **cuatro veces** y la aplicación ninguna | be04 |
| La invariante central **no la sostenía ninguna restricción**; 88 filas la violan | be05 |
| Hay una **reescritura a medias** con dos caminos vivos, medida en tres números | be06 |
| **No había una sola prueba** hasta be06 | be06 |

Y la cita que hay que poner textual, porque es la posición oficial del producto:

> *"In the years since releasing Lumen, PHP has made a variety of wonderful performance improvements. For this reason, along with the availability of Laravel Octane, we no longer recommend that you begin new projects with Lumen. Instead, we recommend always beginning new projects with Laravel."*
> — Documentación oficial de Lumen, sección *Installation*

Léela con cuidado, porque **no dice lo que a todo el mundo le gustaría que dijera**: no dice que Lumen esté muerto, ni que haya que migrar, ni da una ruta. Dice *"no empieces proyectos nuevos"*. Y eso, para un sistema que ya existe y factura, significa exactamente una cosa: **estás en un producto sin recomendación oficial y sin camino de salida declarado**. Ésa es la frase que va en el documento, no *"Lumen está abandonado"*.

---

## 💻 5. El documento

### 5.1 El índice, que es el entregable

```markdown
# ASSESSMENT — certcore-api · <fecha>

1. Resumen ejecutivo · una página, y se escribe al final
2. Estado actual · la tabla de §4, con fuente por fila
3. Riesgos · cada uno con probabilidad, alcance y compensación actual
   3.1 R-01 · Runtime sin parches ← la deuda insignia (bea-08)
   3.2 R-02 · Framework sin calendario de soporte
   3.3 R-03 · Deuda de plantilla · el conocimiento no se amortiza
   3.4 R-04 · Reescritura a medias · dos caminos vivos
   3.5 R-05 · Invariantes contenidas pero no validadas
4. Opciones
   4.1 Quedarse y formar
   4.2 Reescribir a algo aburrido y sostenido
   4.3 Estrangular por endpoint
   4.4 No hacer nada y documentar el riesgo
5. Recomendación · condicional a la fecha de decomisión
6. Qué NO recomendamos, y por qué
7. Qué hace falta para decidir · quién, con qué dato, para cuándo
8. Anexo · dónde Lumen de verdad ganó
```

**Detalles con intención**

- **El resumen ejecutivo se escribe al final y va primero.** Es lo único que va a leer quien decide. Una página, sin jerga, y con la recomendación en el primer párrafo.
- **La sección 6 —"qué NO recomendamos"— no es relleno.** Es donde se desactivan de antemano las propuestas que van a aparecer en la reunión: *"reescribirlo en Node"*, *"subir sólo el PHP"*, *"meterle microservicios"*. Anticiparlas con un párrafo cada una ahorra la reunión entera.
- **La sección 7 es la que convierte un informe en una decisión.** Nombre de quien decide, dato que le falta, fecha. Sin ella, el documento se archiva.

### 5.2 Las cuatro opciones, y de dónde sale cada número

Todas con el mismo formato, porque comparar es el ejercicio.

#### Opción 1 — Quedarse y formar

**Qué es.** Contratar o formar gente para mantener `certcore-api` tal como está, con las contenciones puestas.

| Dato que necesita | De qué fase sale |
|---|---|
| Tiempo hasta que alguien nuevo entrega sin supervisión | **be02** §5.5, calibrado con tu propia experiencia de be01 |
| Coste de una rotación, y cuántas hubo | **be02** §5.5 (tres en ocho años) |
| Qué porcentaje del aprendizaje es transferible | **be02** — cercano a cero, y **ése es el problema** |
| Cuánto tarda alguien en caer en los cuatro bugs de familiaridad falsa | **be01** §5.9, el experimento de los diez minutos |

**Lo que casi nadie pone, y es lo que la hunde o la salva:** esta opción **ya se intentó tres veces**. Las tres funcionaron durante dieciocho meses. No es una hipótesis: es un experimento con tres repeticiones y resultado conocido.

#### Opción 2 — Reescribir a algo aburrido y sostenido

**Qué es.** Rehacer el servicio en un stack con calendario de soporte y mercado laboral. [`bea-09`](bea-09-symfony-como-vara-de-medir.md) usa Symfony como vara porque es el contraste exacto: LTS cada dos años, siete años de cobertura por versión, deprecaciones avisadas.

| Dato que necesita | De qué fase sale |
|---|---|
| Tamaño real del sistema: endpoints, tablas, reglas | **be03** (siete tablas) y **be06** (los tres números) |
| Qué se salva al cruzar y qué se reescribe | **be06** §4, el diccionario de traducción |
| Coste medido de cruzar **un** controlador | **be06**, ejercicio 27 — y por qué multiplicarlo es optimista |
| Qué se rompe mientras | **be06** §4: el estado intermedio es el más caro |
| Qué riesgos elimina | R-01 y R-02 completos; R-03 en gran parte |

**El argumento fuerte de esta opción no es técnico**: es que **ataca la deuda de plantilla**. En un stack con mercado, lo que alguien aprende le sirve fuera, así que se queda más y el siguiente llega sabiendo.

#### Opción 3 — Estrangular por endpoint

**Qué es.** Un proxy delante, se migra la ruta más dolorosa a un servicio nuevo, se mide, se repite. El sistema viejo va adelgazando.

| Dato que necesita | De qué fase sale |
|---|---|
| Qué endpoints hay y cuáles usa el frontend | **be00** (`CONTRACT.md`) y **be06** §5.1 |
| Cuál duele más | **be04** (`SQL-CRUDO.txt`) y **be05** (la invariante) |
| Con qué se verifica cada paso | **be00**: `smoke.sh`, que ya es el juez |
| Coste por endpoint | **be06**, extrapolado del ejercicio 27 |

**Probablemente la respuesta correcta y la más aburrida.** Tiene una ventaja que las otras no: **se puede parar en cualquier momento** y lo hecho sigue sirviendo. En una empresa que no ha decidido la fecha de decomisión, esa propiedad vale más que cualquier ganancia técnica.

Y una condición previa que este track dejó lista sin proponérselo: **estrangular exige un contrato verificable**, y `smoke.sh` lo es desde be00.

#### Opción 4 — No hacer nada y documentar el riesgo

**Qué es.** Congelar el sistema, mantener las contenciones, documentar los riesgos con dueño y fecha de revisión, y dedicar el presupuesto a otra cosa.

| Dato que necesita | De qué fase sale |
|---|---|
| Los riesgos, con compensación actual | **`bea-08`**, la ficha `R-01` |
| Qué contenciones ya están puestas | **be05** (la restricción), **be06** (las pruebas) |
| Cuánto cuesta mantenerlo un año más | **be02** (rotación) + incidentes del cuaderno |

**A veces gana, y saber cuándo gana es seniority.** Gana si la fecha de decomisión está cerca, si el sistema no crece, si el riesgo está compensado y documentado, y **si hay alguien que lo acepta con nombre y fecha**. Sin esa firma no es la opción 4: es no decidir, que es otra cosa y siempre sale peor.

### 5.3 La tabla comparativa

Va en el documento, y es lo que más se mira después del resumen:

| | 1 · Formar | 2 · Reescribir | 3 · Estrangular | 4 · No hacer nada |
|---|---|---|---|---|
| Coste inicial | Bajo | **Alto** | Medio, repartido | ~Cero |
| Coste recurrente | **Alto y repetido** | Bajo tras terminar | Decreciente | Constante, y creciendo |
| Plazo hasta ver algo | Semanas | **Meses o años** | Semanas por endpoint | Inmediato |
| Se puede parar a medias | — | **No, sin perderlo todo** | **Sí** ⭐ | — |
| Elimina R-01 (runtime EOL) | ❌ | ✅ | Parcial, creciente | ❌ |
| Elimina R-03 (plantilla) | ❌ **al contrario** | ✅ | Parcial | ❌ |
| Riesgo de la propia opción | Que se vaya el formado | **Que no termine** — ya pasó una vez (be06) | Vivir con dos sistemas | Que nadie la firme |
| Gana si la decomisión es… | Indiferente | **> 5 años** | 2–5 años, o sin decidir | **< 2 años** |

> 🧭 **La última fila es el documento entero.** Si te llevas una sola cosa de este track, que sea que esa fila existe y que **el dato que la rellena no está en el código**: está en la estrategia de la empresa, y hay que ir a preguntarlo.

### 5.4 El cierre honesto obligatorio: dónde Lumen de verdad ganó

Sin esta sección el *assessment* no es creíble, y el track no habría entendido su propio criterio.

En 2016, para una empresa mediana latinoamericana con gente de PHP de la intranet vieja, **Lumen era la decisión sensata**: aprovechaba el equipo que ya existía, la sintaxis que ya conocían, y encima era moderno y rápido. Y el beneficio **se cobró de verdad durante años**.

Las dos columnas, y hay que poner número en las dos:

| Lo que Lumen ahorró (2016–2019) | Lo que costó (2019–2026) |
|---|---|
| No hubo que contratar un equipo nuevo: el de la intranet escribió la API | Tres ciclos de onboarding no amortizados (be02 §5.5) |
| Salió a producción en semanas, no en trimestres | Ocho años sin subir de versión, y ahora el salto son cuatro mayores |
| Sintaxis conocida: los primeros endpoints se escribieron sin formación | Familiaridad falsa: cuatro familias de bugs, medidas en be01 §5.9 |
| Un framework ligero para una API pequeña: sin sobrecoste de arranque | Sin calendario de soporte, sin deprecaciones avisadas, sin utillaje |
| **Cuantifícalo tú** con la fecha de salida a producción | **Cuantifícalo tú** con los números de be02, be04 y be06 |

> 🧭 **El pecado no fue elegirlo. Fue elegirlo para *un servicio*, acertar, y que nadie volviera a decidir nunca.** Si el documento presenta la elección original como una estupidez, quien lo lea —y que probablemente estuvo ahí en 2016— deja de escucharte en el primer párrafo. Y además sería falso: **los errores caros no se parecen a estupideces. Se parecen a esto.**

**El patrón a memorizar**

> Un *assessment* que sólo tiene la columna del coste no es un análisis: es una acusación. La columna del beneficio es la que te da autoridad para escribir la otra.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Escribir cuatro opciones y que tres sean de paja.**
*Síntoma:* la opción 4 ocupa dos líneas y termina en *"obviamente inaceptable"*.
*Causa:* ya habías decidido antes de escribir.
*Fix mínimo:* escribe **la mejor versión de cada opción**, incluida la que no te gusta. Si no puedes defender la 4 en un párrafo convincente, no la entiendes — y alguien en la reunión sí.

**Inventar números para rellenar la tabla.**
*Síntoma:* "reescribirlo son unos seis meses".
*Causa:* la tabla pedía una celda.
*Fix mínimo:* marca la celda como estimación, escribe en qué se apoya, y da un rango con el supuesto. **Un rango honesto se defiende; un número inventado se desmonta en una pregunta.**

**Confundir el coste de la migración con el del estado intermedio.**
*Síntoma:* la opción 2 sale barata porque cuentas sólo el desarrollo.
*Causa:* el estado intermedio no aparece en ninguna estimación estándar.
*Fix mínimo:* be06 ya lo midió. Súmalo: cada mes de migración es un mes de sistema a medias, que es el estado más caro.

**Recomendar sin condición.**
*Síntoma:* "recomendamos reescribir".
*Causa:* parecía más firme.
*Fix mínimo:* *"recomendamos X si la decomisión es posterior a AAAA; si es anterior, recomendamos Y"*. Es más firme, no menos: **estás diciendo exactamente qué dato cambia la respuesta**, y eso es lo que quien decide necesita.

### Pieza forense de esta fase

**El *assessment* que recomienda el rewrite sin datos** (incidente `be-12`).

Te llega un documento de tres páginas. Está bien escrito, tiene diagramas, y recomienda reescribir en un stack moderno en seis meses. Tu trabajo es desmontarlo — y no es fácil, porque **casi todo lo que afirma sobre el código es cierto**.

El método, que es el mismo que usarías con un ticket vago:

1. **Separa las afirmaciones verificables de las de valor.** *"El runtime está EOL"* se verifica. *"El código es inmantenible"* no significa nada hasta que alguien diga qué mide.
2. **Para cada cifra, pregunta de dónde sale.** Las que no tengan fuente son el hallazgo. **No hace falta discutirlas: basta con pedir su origen.**
3. **Busca la opción que falta.** Casi siempre falta la 3, estrangular — la aburrida —, y casi siempre falta la 4. Un documento con una sola opción real no es un *assessment*.
4. **Busca el coste del estado intermedio.** Si la estimación de seis meses no incluye los seis meses de dos sistemas vivos, está incompleta por un factor que no es pequeño.
5. **Busca la fecha de decomisión.** Si no aparece, el documento no puede recomendar nada, **por buena que sea su descripción del problema**.
6. **Y concede lo que tiene razón.** Ése es el paso que convierte una objeción en una conversación: *"el diagnóstico es correcto, y por eso mismo la recomendación necesita dos datos que no están"*.

> 🧠 **Un documento con un diagnóstico correcto y una recomendación sin sustento es más peligroso que uno malo entero**, porque el diagnóstico correcto le presta credibilidad a lo demás. El paso 1 —separar lo verificable de lo valorativo— existe exactamente para eso.

> 🧨 **Rompe a propósito y observa.** Coge tu propio `ASSESSMENT.md` y **quítale la fecha de decomisión**: borra la condición de la recomendación y déjala afirmativa. Léelo entero otra vez. ¿Sigue siendo defendible? Después haz lo contrario: cambia la fecha de decomisión de tres años a diez y mira **cuántas secciones tienes que reescribir**. Si son pocas, tus opciones no eran de verdad.

---

## 🧪 7. Ejercicios (27)

**🟢 Fácil (1–6)**

1. Recopila de las siete fases todos los números producidos y ponlos en una sola tabla, con la fase de origen. Si alguno no existe, márcalo como hueco.
2. Escribe la sección 2 (estado actual) con la tabla de §4, verificando cada fila contra su fase.
3. **Diagnóstico.** Busca la cita oficial de Lumen en su documentación y cópiala literal con la URL. Después escribe en dos líneas qué dice **y qué no dice**.
4. Escribe la ficha `R-01` completa con los siete campos de [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md).
5. Rellena la tabla comparativa de §5.3 con lo que ya sabes. Marca en rojo las celdas que no puedas justificar.
6. **Diagnóstico.** Para cada una de las cuatro opciones, escribe **de qué fase** sale su número principal. Si alguna no tiene fuente, es que falta contenido: dilo.

**🟡 Intermedio (7–16)**

7. Costea la opción 1 con el cálculo de be02 §5.5 y los supuestos escritos al lado.
8. **Diagnóstico.** Costea la opción 2 a partir del ejercicio 27 de be06 —el coste real de cruzar un controlador— y explica por qué multiplicar es optimista. Da un rango, no un número.
9. Diseña la opción 3 en detalle: en qué orden, con qué criterio, y qué se mide después de cada endpoint.
10. Costea la opción 4: cuánto cuesta un año más de sistema congelado, contando incidentes, rotación y riesgo.
11. **Diagnóstico.** Escribe la sección 6 —"qué NO recomendamos"— con tres propuestas que sabes que van a aparecer en la reunión, y un párrafo para cada una.
12. Escribe el resumen ejecutivo de una página. Dáselo a leer a alguien que no conozca el sistema y pídele que te diga cuál es la recomendación. Si no la encuentra en treinta segundos, reescríbelo.
13. **Diagnóstico.** Rellena las dos columnas del anexo "dónde Lumen de verdad ganó" **con números**, no con adjetivos.
14. Escribe la sección 7: quién decide, qué dato le falta, para cuándo. Con nombres de rol, no genéricos.
15. **Diagnóstico.** Toma los cinco riesgos del índice y ordénalos por *probabilidad × alcance*. Documenta el criterio de ordenación antes de ordenar.
16. Compara tu recomendación con la de [`bea-09`](bea-09-symfony-como-vara-de-medir.md) sobre reescribir a Symfony. ¿Coinciden? Si no, explica qué dato tuyo cambia el resultado.

**🟠 Difícil (17–22)**

17. **Diagnóstico.** Escribe el *assessment* completo, las ocho secciones. Es el entregable de la fase.
18. Escribe la **misma recomendación** para dos fechas de decomisión distintas —dos años y diez— y compara qué secciones cambian. Si cambian pocas, tus opciones no eran reales.
19. **Diagnóstico.** Desmonta el *assessment* adversarial del incidente `be-12` con los seis pasos de §6. Entrega la refutación por escrito, incluida la parte donde concedes lo que tiene razón.
20. Defiende tu documento ante alguien que prefiere el rewrite —una persona real, o tú mismo escribiendo las objeciones más duras que se te ocurran—. Incorpora las objeciones **dentro** del documento, no en un anexo.
21. **Diagnóstico.** Encuentra la cifra más débil de tu propio *assessment* y atácala hasta romperla. Después decide: ¿se puede medir mejor, o hay que marcarla como estimación? Documenta cuál de las dos.
22. Escribe el correo de dos párrafos con el que mandarías este documento a la dirección. Es el ejercicio más corto y el que más veces se hace mal.

**🔴 Muy difícil (23–27)**

23. **Diagnóstico.** Consigue —o construye con supuestos explícitos— la fecha de decomisión de CertCore. Después escribe la recomendación definitiva y **defiende el supuesto**, que es la parte difícil: ¿en qué te apoyas para decir cuántos años le quedan a un sistema?
24. Escribe el *assessment* que un consultor externo escribiría en tres días sin haber hecho este track, y compáralo con el tuyo. ¿En qué se parecen? **¿En qué acierta él y tú no?** Sé honesto: la ventaja de la mirada externa es real.
25. **Diagnóstico.** Aplica el método de este documento a un sistema que conozcas de verdad, fuera de CertCore. Escribe la versión de una página. **Éste es el ejercicio que justifica las ochenta horas del track.**
26. Escribe la sección que este *assessment* no tiene y probablemente debería: **qué pasa si no se decide nada durante dos años más**. Con números, y sin dramatismo — el no-decidir también tiene coste y casi nunca se calcula.
27. **Diagnóstico adversarial.** Un directivo lee tu documento y responde: *"todo esto está muy bien, pero el sistema funciona y no ha fallado nunca; ¿por qué gastaría un peso?"*. Escribe la respuesta de dos párrafos. **No puedes usar la palabra "deuda técnica"**, y tiene que ser honesta: parte de lo que dice es cierto.

**🔥 Opcionales**

- 🔥 Calcula el coste total de propiedad de las cuatro opciones a cinco años, con una hoja de cálculo y los supuestos a la vista. Después haz un análisis de sensibilidad: ¿qué supuesto, al moverse un 20%, cambia la recomendación?
- 🔥 Escribe la versión de este documento para un sistema **sano**, con calendario y mercado. Compárala con ésta y anota cuántas secciones desaparecen. Esa diferencia es, exactamente, lo que cuesta el pasivo tecnológico.

---

## 📚 8. Referencias

**Documentación oficial**
- https://lumen.laravel.com/docs/10.x — la cita oficial del apartado *Installation*, que es la posición del producto y hay que citar textual.
- https://www.php.net/supported-versions.php — el calendario de soporte de PHP; la fila de 7.4 es la premisa del documento.
- https://symfony.com/releases — el contraste: fechas de fin de correcciones y de seguridad por versión. Es lo que Lumen no tiene.
- https://packagist.org/packages/laravel/lumen-framework — el historial de versiones sin ninguna columna de soporte.

**Libros / artículos de referencia**
- *Technical Debt* (Philippe Kruchten, Robert Nord, Ipek Ozkaya, Addison-Wesley, 2019) — la distinción entre deuda que se paga y deuda que se documenta, y cómo se presenta a quien decide. Es el marco de la sección 3 del documento.
- *Escaping the Build Trap* (Melissa Perri, O'Reilly, 2018) — por qué la fecha de decomisión es una decisión de producto y no de ingeniería, y cómo se pregunta.
- *Accelerate* (Forsgren, Humble, Kim, IT Revolution, 2018) — para el argumento de la opción 3: entregas pequeñas y medibles frente a proyectos grandes y binarios.

**Video / apoyo**
- https://www.youtube.com/results?search_query=legacy+system+modernization+strangler+vs+rewrite — busca charlas de gente que eligió **no** reescribir y cuenta por qué. Son minoría y son las útiles.

**Orden de lectura sugerido:** [`bea-10`](bea-10-mapa-de-deuda-del-track-be.md) **antes de nada**, porque es el inventario consolidado de todo lo que este documento tiene que cubrir → tus propios entregables de las siete fases **mientras** rellenas la tabla de números → [`bea-09`](bea-09-symfony-como-vara-de-medir.md) **al costear la opción 2** → [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) **al costear la opción 4**, que es donde el riesgo aceptado necesita dueño → Kruchten **después**, si tienes que defenderlo ante alguien que no es técnico.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. Y con la cita oficial de Lumen en particular: **cópiala con la fecha de consulta**, porque es el tipo de párrafo que un proyecto reescribe sin avisar y tu documento la va a citar como prueba.

---

## 🚀 9. Cierre del track

Aquí termina el track BE, y termina como empezó: con un documento y ninguna promesa.

Ochenta horas atrás, `certcore-api` era una caja negra detrás de `npm run mock`. Ahora es un sistema que levantaste tú, con su historia reconstruida, su código clasificado por procedencia, su invariante contenida, sus primeras pruebas y su riesgo escrito con nombre y fecha. Y tienes un documento que recomienda algo **y dice de qué depende**.

Lo que te llevas al trabajo real no es Lumen —nadie va a buscar trabajo de Lumen, y conviene decirlo—. Es el método: **cómo se diagnostica un sistema cuya tecnología se volvió un pasivo, cómo se le pone número, y cómo se defiende una decisión ante alguien que prefiere otra.** Eso sirve igual en Rails 4, en Spring 3, en .NET Framework, o en el Angular 8 del curso hermano.

Y la última frase del track es la misma con la que empezó:

> 🧠 **El backend no viene a redimir nada. El backend es la escena del crimen.** Lo que aprendiste no es cómo se hace bien: es **qué haces el lunes cuando lo que está mal es una decisión de arquitectura de hace ocho años, el sistema factura, y no hay presupuesto para deshacerla.**

> **La señal de que quedó bien:** *"defendí no reescribir delante de alguien que quería reescribir, con números, y salimos los dos con la misma pregunta pendiente: cuántos años le quedan a este sistema."*

> 🏷️ **No cierres el track sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-07-el-assessment-de-riesgo \
>   -m "be07 cerrada y track BE completo: ASSESSMENT.md con las ocho secciones;
> cuatro opciones costeadas con la fase de origen de cada cifra;
> recomendación condicional a la fecha de decomisión;
> anexo honesto con las dos columnas de Lumen"
> ```
>
> Los commits de esta fase llevan `be07: …`. Y una última comprobación, la misma de las siete fases anteriores y la que define el track entero:
>
> ```bash
> git diff fase-10-certificados-vigencia..HEAD -- src/
> ```
>
> **Tiene que devolver vacío.** Ochenta horas de backend, un reemplazo completo de servidor, una restricción nueva y un cambio de motor de datos — y el frontend no cambió ni una línea. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥.

---

## 📌 Pendientes sugeridos

- **El *assessment* no se ejecuta**, y ésa es la frontera del track. Lo que venga después —migrar, estrangular, congelar— es otro curso y probablemente otro oficio. → **Declarado como límite del track** en el README.
- **La fecha de decomisión es un supuesto del alumno** (ejercicio 23) y no un dato de la ficción. Es deliberado: en la vida real tampoco te la dan, hay que ir a buscarla. Si alguna vez el track gana una fase de comunicación con negocio, ahí es donde vive. → **📌 de autoría**, para el chat de cierre.
- **El ejercicio 25 —aplicar el método a un sistema real— es el que justifica el track** y es el único que no se puede evaluar desde aquí. → Si el curso llega a tener tutoría, es el entregable que se revisa.
- **`bea-10` tiene que cuadrar con este documento**: cada 💸 de las ocho fases aparece en los dos, o hay un error. → **Comprobación de cierre**, antes de dar el track por cerrado.
- **El cuaderno `cuaderno-incidentes-be.md`** consume los doce IDs reservados (`be-01` … `be-12`) y se escribe después de las ocho fases. → **Siguiente y último documento del track.**

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| **be-12** | "Tenemos un assessment que recomienda reescribir en seis meses" | Adversarial · decisión sin datos | 🔴 |
MDEOF
wc -l be07-el-assessment-de-riesgo.md

# --- 2026-09-11T18:43:17 · List declared debts in BE phases
grep -n "💸 DEUDA TÉCNICA INTENCIONAL" be0*.md | cat; echo ---; grep -n "^💸\|💸 [0-9]" be0*.md | head -20

# --- 2026-09-11T18:44:46 · Write bea-10 debt map
cat > bea-10-mapa-de-deuda-del-track-be.md <<'MDEOF'
# 📎 Apéndice bea-10 — Mapa de deuda del track BE

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **2 horas**
> Usado por: **be07** · Se escribe **al final**, con las ocho fases cerradas
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido**, aunque es el más corto del track: se entra buscando *"¿esto era a propósito?"* y se sale con la fase que lo declaró y con el motivo por el que sigue ahí.

**Qué problema resuelve:** dejar por escrito **qué quedó feo a propósito** en el backend que acabas de construir, **qué lo vuelve exigible**, y **en qué orden se pagaría**.

> ⚠️ **Este apéndice no tiene hermano en el track base, y conviene saberlo.** El track base **no consolida su deuda en ningún sitio**: cada fase declara sus 💸 en su cuerpo y sus 📌 al cierre, y ahí se quedan (`a12` de ese curso es `a12-arm64-m1.md`, Apple Silicon, no un mapa de deuda). Así que este documento **no copia una estructura existente: la inventa**.

**Qué queda fuera:** **las deudas del track base.** No se listan ni se resumen aquí — viven repartidas en el 💸 de cada fase y en su 📌 de cierre, y duplicarlas crearía una segunda fuente de verdad para algo que ese track ya sostiene. Cuando haga falta citar una, se nombra la fase que la declaró y se enlaza ese capítulo.

---

## Índice

- [La deuda insignia: el runtime EOL](#la-deuda-insignia-el-runtime-eol)
- [El inventario, fase por fase](#el-inventario-fase-por-fase)
- [Las que no se pagan nunca, con su razón](#las-que-no-se-pagan-nunca-con-su-razón)
- [El criterio que las ordena](#el-criterio-que-las-ordena)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-6)

---

## La deuda insignia: el runtime EOL

Va primera y con apartado propio porque **no es una deuda que se pague: es una que se documenta, se compensa y se escala.**

`certcore-api` corre sobre PHP 7.4.33, sin soporte de seguridad desde el **28 de noviembre de 2022**, sobre una imagen congelada el **15 de noviembre de 2022**, con un framework —Lumen 5.8.13— cuya restricción `php ^7.1.3` **excluye PHP 8**. Subir el runtime no es subir el runtime: es el **trasplante de bootstrap** que midió [`be06`](be06-la-reescritura-a-medias.md).

| | |
|---|---|
| **Declarada en** | be01 §4 (el ticket SEC-2291) |
| **Por qué no se paga** | Porque pagarla es la opción 2 del *assessment*, y esa decisión es de negocio |
| **Compensación actual** | Reducción de superficie, red, `APP_DEBUG=false`, SQL crudo revisado — [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) |
| **Cómo se gestiona** | Ficha de riesgo `R-01` con **dueño y fecha de revisión** |
| **Dónde se decide** | [`be07`](be07-el-assessment-de-riesgo.md) |

> 🧭 **Una deuda que no se puede pagar sin una decisión de negocio no es un pendiente de ingeniería: es un riesgo con dueño.** La diferencia entre las dos cosas son dos campos —quién la acepta y hasta cuándo— y es lo único que separa "aceptada" de "escondida".

---

## El inventario, fase por fase

Cada 💸 que aparece aquí existe **literalmente** en el cuerpo de una fase, y cada 💸 de las fases aparece aquí. Si encuentras una que no cuadra, no la inventes ni la borres: **significa que una fase está mal**.

| # | Deuda | Declarada en | ¿Se paga? | Dónde / por qué no |
|---|---|---|---|---|
| **B1** | El contrato **no tiene paginación**: `GET /inspections` devuelve todo | be00 §5.3 | ✅ **Pagada** | **be03**, con el frontend intacto: sin `_page` se sigue recibiendo todo |
| **B2** | Datos fijos en una clausura anónima en `routes/web.php` | be01 §5.6 | ✅ **Pagada** | **be03**. La factura: `git diff be-fase-01-… be-fase-03-… -- server/routes/web.php` |
| **B3** | El inventario de estratos vive en un `.md` y nada lo verifica | be02 §5.3 | ❌ **Aceptada** | Un pipeline de análisis estático no se justifica en un sistema en mantenimiento sin fecha de decomisión decidida |
| **B4** | `certificates.status` es una **columna**, no un derivado | be03 §5.1 | ⚠️ **Contenida** | **be05**: servido desde una vista. La columna sigue existiendo (ver **B8**) |
| **B5** | Fechas en `timestamp` **sin zona**, con datos que traen offset `-05:00` | be03 §5.1 | ❌ **Diagnosticada y costeada, sin pagar** | **be04** §5.5 la diagnostica; convertir obliga a **elegir una zona de origen irreversible** ([`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md)) |
| **B6** | `inspections` apunta a `(template_id, template_version)` **sin clave foránea** | be03 §5.1 | ✅ **Pagada** | **be05**: foránea compuesta en `NOT VALID`, sin tocar el histórico |
| **B7** | Dominios sin `CHECK`: `status`, `severity`, `type` son texto libre | be03 §5.1 | ❌ **Aceptada** | El frontend ya valida esos valores, y meter cuatro restricciones a la vez sobre datos viejos diluiría la lección de be05 |
| **B8** | La columna `certificates.status` **no se borra** aunque ya no se lea | be05 §5.4 | ⚠️ **Diferida** | **be06** le dio pruebas y camino oficial; es el **primer candidato de limpieza** cuando be07 dé dirección |
| **B9** | Respuestas huérfanas dentro de `answers` (`jsonb`): **no se pueden restringir** | be05 §📌 | ❌ **Aceptada** | Dentro de un documento `jsonb` no hay restricciones. Normalizar `items`/`answers` es una reescritura de esquema que ninguna fase justifica |
| **B10** | **Dos caminos vivos** para los mismos recursos; se decide el oficial y no se borra el otro | be06 §5.1 | ⚠️ **Condicional** | Se paga si be07 elige *terminar la migración*; queda aceptada si elige *estrangular* o *esperar* |
| **B11** | `tools/probe.php` usa `eval()` | be01 §📌 | ⚠️ **Contenida** | Correcta en `tools/`, inaceptable en el artefacto de despliegue. Excluirla es configuración, no confianza ([`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md)) |
| **B12** | El archivo heredado con `exit` **se salta la cadena de middleware** entera | be02 §5.1, be06 §📌 | ❌ **Aceptada** | Documentada. Rompe cualquier prueba que lo toque; candidato de limpieza junto con **B10** |
| **B13** | `withFacades()` queda **apagado** y la decisión no vive en el código | be01 §5.3 | ❌ **Aceptada, por diseño** | Encenderlos cambiaría el arranque de un sistema de ocho años cuyo código heredado se acostumbró a vivir sin ellos |
| **B14** | El sembrador **no es idempotente** | be03 §📌 | ⚠️ **Diferida** | **be06**, junto con la estrategia de pruebas, que siembra y limpia en cada ciclo |
| **B15** | La cobertura de pruebas **miente** en este sistema: con dos caminos vivos mide el doble de lo mismo | be06 §📌 | ❌ **Aceptada** | Se documenta en vez de perseguir un porcentaje. Desaparece sola si se resuelve **B10** |
| **B16** | La restricción de be05 queda **`NOT VALID`**: 88 filas históricas siguen violándola | be05 §5.3 | ❌ **Aceptada, con firma** | Validar exige decidir qué se hace con esas filas, y en un dominio regulado el histórico no se reescribe. `VALIDATE` queda documentado y sin ejecutar |

**Cuatro pagadas, cinco contenidas o diferidas, siete aceptadas.** Ése es el estado real del sistema al cerrar el track, y es un resultado, no un fracaso: **un backend heredado con siete deudas aceptadas y escritas está mejor gestionado que uno con cero deudas declaradas y las mismas por debajo.**

---

## Las que no se pagan nunca, con su razón

Tres merecen destacarse porque la tentación de pagarlas es constante:

**B7 — los dominios sin `CHECK`.** Parece barato y no lo es: cada `CHECK` sobre una columna de texto libre con ocho años de datos es el procedimiento completo de [`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md), censo incluido, cuatro veces. Y el beneficio es bajo, porque el frontend ya restringe esos valores en origen. **Se acepta y se escribe.**

**B13 — los facades apagados.** Es la deuda que más gente querría "arreglar" en su primera semana, y arreglarla **empeora el sistema**: enciende treinta clases nuevas en todo el proyecto y crea una segunda convención viva junto a la que ya se usa. La autopsia está en be01 §5.7.

**B16 — la restricción sin validar.** Es la deuda más visible del track y la que menos hay que tocar: `NOT VALID` **no es un estado transitorio por definición**, y puede quedarse años siempre que esté declarada y con dueño. El día que alguien decida qué pasa con las 88 inspecciones huérfanas, se valida en una tarde.

> 🧠 **Una deuda aceptada con su razón escrita no es lo mismo que una deuda olvidada, aunque el código sea idéntico.** La diferencia está en este documento, y es la diferencia entre un sistema gestionado y uno abandonado — que es, exactamente, la tesis del track.

---

## El criterio que las ordena

No se ordenan por tamaño ni por antigüedad. Tres preguntas, en este orden:

1. **¿Crece sola?** Una deuda cuyo coste aumenta sin que nadie la toque va primera. **B1** crecía con cada inspección nueva (por eso se pagó), y la insignia —el runtime EOL— crece cada mes que pasa.
2. **¿Bloquea otra cosa?** **B6** bloqueaba cualquier garantía sobre la invariante, así que se pagó aunque no molestara a diario.
3. **¿Su coste de pago crece con el tiempo?** **B10**, la reescritura a medias, se encarece cada mes que siguen vivos los dos caminos. Las que no crecen —**B7**, **B13**— pueden esperar indefinidamente, y decirlo es más honesto que ponerlas en una lista que nadie va a atender.

Y el criterio que manda sobre los tres, el mismo de be07:

> 🧭 **El orden de pago depende de la fecha de decomisión.** Con dos años por delante, sólo se paga lo que crece solo. Con diez, se paga lo que bloquea. **Una lista de deuda sin fecha de decomisión es una lista de deseos.**

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer |
|---|---|
| *"¿Esto era a propósito?"* | Busca en la tabla. Si no está, **no era a propósito**: es un hallazgo |
| Vas a costear el *assessment* (be07) | Cada fila con su fase de origen es un insumo; las 🔴 aceptadas son las que alimentan la opción 4 |
| Alguien propone "limpiar deuda" en un sprint | Aplica el criterio de orden: sólo lo que crece solo o bloquea algo |
| Encuentras una 💸 en una fase que no está aquí | **Ni la inventes ni la borres**: una de las dos fuentes está mal. Arregla la fase |
| Encuentras aquí una que no está en ninguna fase | Lo mismo, al revés |
| Vas a cerrar el track | Corre el ejercicio 1: las dos listas tienen que cuadrar exactamente |

---

## ⚠️ Advertencias

**Este documento envejece a la primera modificación del código.** Es el mismo defecto que **B3** —un inventario en un `.md` que nada verifica—, y se acepta por la misma razón. Lo que lo mantiene vivo es que be07 lo consume: mientras alguien escriba el *assessment* a partir de aquí, esta tabla se revisa.

**Una deuda listada no es una deuda gestionada.** Sólo las que tienen dueño y fecha de revisión lo están, y en este track ésa es exactamente una: la insignia, vía la ficha `R-01`. Las otras quince están **declaradas**, que es un peldaño menos y hay que decirlo así.

**No listes aquí deudas del track base.** Viven en sus fases. Si necesitas citar una —la ⭐ 3 de la Fase 7, el `status` de la Fase 10—, nómbrala y enlaza su capítulo.

---

## 📚 Referencias

- *Technical Debt* (Kruchten, Nord, Ozkaya, Addison-Wesley, 2019) — la distinción entre deuda que se paga, que se contiene y que se documenta. Es el marco de la tabla de arriba.
- https://martinfowler.com/bliki/TechnicalDebtQuadrant.html — el cuadrante de deuda deliberada/inadvertida y prudente/imprudente. Casi todo lo de este track es **deliberada y prudente**, y merece la pena saber por qué eso importa.
- [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) — la ficha de riesgo `R-01`, que es la forma gestionada de la deuda insignia.
- [`be07`](be07-el-assessment-de-riesgo.md) — donde estas dieciséis filas se convierten en cuatro opciones costeadas.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos.

---

## 🧪 Ejercicios (6)

Todos de priorización argumentada. Ninguno es de código.

1. **Comprobación de cierre.** Extrae con `grep` todas las 💸 de las ocho fases y crúzalas con esta tabla. Tienen que cuadrar **exactamente**, en los dos sentidos. Si no cuadran, arregla la fase o esta tabla, y di cuál estaba mal.
2. Ordena las dieciséis por el criterio de §"El criterio que las ordena", **primero** con una fecha de decomisión de dos años y **después** con una de diez. Compara las dos listas: ¿cuántas cambian de posición?
3. **Diagnóstico.** Elige una de las "aceptadas" y construye el mejor argumento para pagarla. Después construye el mejor argumento para no hacerlo. Decide, y escribe qué dato te haría cambiar de opinión.
4. Para cada deuda **contenida** (**B4**, **B8**, **B11**), escribe qué pasaría si la contención desapareciera —si alguien borra la vista, si se despliega `tools/`—. ¿Cuál de las tres es más frágil?
5. **Diagnóstico.** Convierte una deuda declarada en una deuda **gestionada**: elige una, escríbele la ficha de riesgo completa de [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) con dueño y fecha de revisión, y decide a quién se la mandarías.
6. **Diagnóstico adversarial.** Alguien propone un sprint de dos semanas "de deuda técnica" para resolver todo lo que se pueda de esta tabla. Escribe la respuesta en dos párrafos: cuáles de las dieciséis se pueden cerrar de verdad en dos semanas, cuáles **no se deben** tocar aunque se pueda, y por qué un sprint de deuda sin fecha de decomisión decidida suele terminar en una tabla idéntica con otros números.

---

> 🏷️ **Este apéndice no lleva tag propio.** Se escribe al cerrar el track y se commitea con el prefijo de la última fase (`be07: …`). La comprobación del ejercicio 1 —que las dos listas cuadren— conviene correrla **antes** de etiquetar `be-fase-07-el-assessment-de-riesgo`: si no cuadran, el track no está cerrado. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
MDEOF
wc -l bea-10-mapa-de-deuda-del-track-be.md

# --- 2026-09-11T18:44:58 · Cross-check appendix references
echo "=== Apéndices de apoyo declarados por cada fase ==="; for f in be0*.md; do printf "%-14s " "${f%%-*}"; sed -n '4p' "$f" | grep -o 'bea-[0-9][0-9]' | tr '\n' ' '; echo; done
echo; echo "=== Usado por, declarado por cada apéndice ==="; for f in bea-*.md; do printf "%-8s " "$(echo $f|cut -c1-6)"; sed -n '3p' "$f" | sed 's/.*Usado por: //;s/ · Versiones.*//'; done

# --- 2026-09-11T18:45:06 · Cross-check both directions
echo "=== fases → apéndices ==="; for f in be0*.md; do printf "%-6s " "$(echo $f|cut -c1-4)"; head -6 "$f" | grep -o 'bea-[0-9][0-9]' | sort -u | tr '\n' ' '; echo; done
echo; echo "=== apéndices → fases ==="; for f in bea-*.md; do printf "%-7s " "$(echo $f|cut -c1-6)"; head -5 "$f" | grep -o 'Usado por:.*' | sed 's/ · Versiones.*//;s/Usado por: //'; echo; done

# --- 2026-09-11T18:45:16 · Find bea-02 refs in be03
grep -n "bea-02" be03-el-reemplazo.md

# --- 2026-09-11T18:45:20 · Align be03 appendix declaration
python3 - <<'PY'
p='be03-el-reemplazo.md'
s=open(p).read()
s=s.replace("> Apéndices de apoyo: [`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md) · [`bea-02`](bea-02-receta-de-imagen-y-compose.md) · Incidentes asociados",
            "> Apéndices de apoyo: [`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md) · Incidentes asociados",1)
open(p,'w').write(s)
print('ok')
PY
head -6 be03-el-reemplazo.md | tail -3

# --- 2026-09-11T18:45:28 · Locate README backend section
grep -n "Track opcional de backend" README.md; grep -n "^## 🧰 El stack, fijado" README.md

# --- 2026-09-11T18:45:57 · Update README backend section
python3 - <<'PY'
p='README.md'
lines=open(p).read().split('\n')
# líneas 114..153 (1-indexed) → índices 113..152
old_block='\n'.join(lines[113:152])
new_block = """## 🔥 Track opcional de backend — CertCore desde el otro lado del cable

CertCore, la aplicación, nació en 2021. **`certcore-api`, contra la que habla, es
de 2016 y nadie la revisó nunca** — está en la Era 0 de
[`00-historia-del-sistema.md`](00-historia-del-sistema.md), y explica de una sola
vez por qué el contrato devuelve el objeto completo sin paginar, por qué el
`status` del certificado viene guardado como dato, y por qué las plantillas
versionadas tienen un `id` compuesto que nadie diseñó. El **track BE** es la
continuación opcional que la levanta —**PHP 7.4.33 + Lumen 5.8.13 + PostgreSQL
16.9**—, la mide y la contiene.

No es "hagamos el backend bien". Es lo contrario:

> 🧠 **El backend no viene a redimir nada. El backend es la escena del crimen.**
> Qué haces el lunes cuando lo que está mal es una decisión de arquitectura de
> hace ocho años, el sistema factura, y no hay presupuesto para deshacerla.

**Ocho fases (`be00`–`be07`) y once apéndices (`bea-01`–`bea-11`), 72h más 8h de
cuaderno propio, declaradas aparte de las 122h del curso.** Prerrequisito: la
Fase 10 terminada. Regla no negociable: **el frontend no se toca** — se apaga
`npm run mock`, se levanta el contenedor en el mismo puerto 3000, y la aplicación
Angular no cambia ni un archivo. Al cerrar la última fase,
`git diff fase-10-certificados-vigencia..HEAD -- src/` sigue devolviendo vacío.

| Fase | Archivo | Horas | Ejercicios |
|---|---|---|---|
| 📜 be00 · El contrato: auditoría del mock | [`be00-el-contrato-auditoria-del-mock.md`](be00-el-contrato-auditoria-del-mock.md) | 6h | 26 |
| 🐘 be01 · Lumen sobre PHP 7.4, y la familiaridad falsa ⭐ | [`be01-lumen-y-la-familiaridad-falsa.md`](be01-lumen-y-la-familiaridad-falsa.md) | 10h | 32 |
| 🧬 be02 · Estratos por procedencia | [`be02-estratos-por-procedencia.md`](be02-estratos-por-procedencia.md) | 8h | 29 |
| 🗄️ be03 · El reemplazo: de `db.json` a Postgres 16 | [`be03-el-reemplazo.md`](be03-el-reemplazo.md) | 10h | 31 |
| 📅 be04 · El salto de versión que nadie corrió | [`be04-el-salto-de-version-que-nadie-corrio.md`](be04-el-salto-de-version-que-nadie-corrio.md) | 10h | 32 |
| ⭐ be05 · **La invariante que no sostenía nadie** ⭐⭐ | [`be05-la-invariante-que-no-sostenia-nadie.md`](be05-la-invariante-que-no-sostenia-nadie.md) | 10h | 33 |
| 🧱 be06 · La reescritura que se quedó a medias | [`be06-la-reescritura-a-medias.md`](be06-la-reescritura-a-medias.md) | 8h | 29 |
| 📊 be07 · El *assessment* de riesgo tecnológico | [`be07-el-assessment-de-riesgo.md`](be07-el-assessment-de-riesgo.md) | 10h | 27 |

Su fase insignia cierra el círculo con el corazón de este curso: la Fase 7 enseña
que *una inspección de hace un año se renderiza con la plantilla de hoy* y lo
arregla en el frontend. **be05** muestra que ninguna restricción de la base
sostenía esa invariante, y que el bug nunca fue del frontend.

**Los once apéndices** —consulta bajo demanda, sus horas no cuentan en ningún
calendario— cubren lo que las fases delegan: PHP y Lumen para quien no escribe
PHP ([`bea-01`](bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md)), la receta
de imagen y compose con **la cápsula del tiempo de una imagen que se murió en
directo** ([`bea-02`](bea-02-receta-de-imagen-y-compose.md)), el contenedor y por
qué `grep` falla
([`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md)), Eloquent y
lo que **no** absorbe
([`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md)), los dialectos de
PostgreSQL
([`bea-05`](bea-05-dialectos-y-saltos-de-version-en-postgresql.md)), las
restricciones sobre datos sucios
([`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md)), el tiempo
y `TIMESTAMPTZ` ([`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md)), la seguridad
sobre un runtime sin parches
([`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md)), Symfony
como vara de medir ([`bea-09`](bea-09-symfony-como-vara-de-medir.md)), el mapa de
deuda del track ([`bea-10`](bea-10-mapa-de-deuda-del-track-be.md)) y los datos de
prueba y volumen ([`bea-11`](bea-11-datos-de-prueba-y-volumen.md) 🔥).

Y el track **no vende Lumen** —nadie va a buscar trabajo de Lumen, y conviene
decirlo—: vende el método para diagnosticar un sistema cuya tecnología se volvió
un pasivo. El entregable final no es código, es un ***assessment* de riesgo
tecnológico** con cuatro opciones costeadas y una regla: *la respuesta correcta
depende de la fecha de decomisión, no de la calidad del código.*

El encuadre completo —stack con versiones verificadas, las ocho fases, los once
apéndices y los riesgos— está en
[`prompts/propuesta-fases-backend.md`](prompts/propuesta-fases-backend.md), y los
prompts de redacción en `prompts/prompts-backend-fase.md` y
`prompts/prompts-backend-apendice.md`. **Lo único que queda pendiente del track es
`cuaderno-incidentes-be.md`**, con los doce incidentes que las fases reservaron
(`be-01` … `be-12`)."""
lines[113:152] = new_block.split('\n')
open(p,'w').write('\n'.join(lines))
print("ok")
PY
sed -n '110,120p' README.md; echo ...; grep -n "^## 🧰 El stack" README.md

# --- 2026-09-11T18:46:05 · Verify README and exercise counts
grep -n "propuesto\|sin escribir" README.md | head; echo "=== conteos declarados en §7 ==="; grep -h "^## 🧪 7\. Ejercicios" be0*.md; echo "=== apéndices ==="; grep -h "^## 🧪 Ejercicios" bea-*.md

# --- 2026-09-11T18:46:12 · Verify exercise numbering matches declared counts
for f in be0*.md bea-*.md; do
  d=$(grep -o "Ejercicios ([0-9]*)" "$f" | head -1 | grep -o '[0-9]*')
  last=$(awk '/^## 🧪/{s=1} s&&/^[0-9]+\./{n=$1} /^## 📚/{s=0} END{print n}' "$f" | tr -d '.')
  st=$([ "$d" = "$last" ] && echo OK || echo "⚠ declarado=$d último=$last")
  printf "%-52s %s\n" "$f" "$st"
done

# --- 2026-09-11T18:46:22 · Verify template compliance and incident IDs
echo "=== IDs reservados ==="; grep -h "^| \*\*be-[0-9]" be0*.md | sed 's/|.*\*\*\(be-[0-9]*\)\*\*.*/\1/' | sort | tr '\n' ' '; echo
echo "=== secciones por fase ==="; for f in be0*.md; do printf "%-6s %s\n" "$(echo $f|cut -c1-4)" "$(grep -c '^## ' $f)"; done
echo "=== faltantes de plantilla ==="; for f in be0*.md; do for s in "1. Propósito" "2. Qué queda listo" "3. Qué NO entra" "4. Concepto mínimo" "5. " "6. Errores comunes" "7. Ejercicios" "8. Referencias" "9. Cierre" "📌 Pendientes"; do grep -q "^## .*$s" "$f" || echo "$f falta: $s"; done; done

# --- 2026-09-11T18:46:32 · Read BE tracks memory
cat /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/tracks-be-angular-decisiones.md

# --- 2026-09-11T18:46:51 · Update memory with CertCore BE track status
cd /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory && python3 - <<'PY'
p='tracks-be-angular-decisiones.md'
s=open(p).read()
s=s.replace("description: Track BE de angular-8 (LabCore) COMPLETO — 9 fases, 12 apéndices y su cuaderno de 12 incidentes. CertCore (angular-16) sigue solo propuesto.",
"description: Tracks BE de los dos cursos de Angular. LabCore (angular-8) COMPLETO. CertCore (angular-16): 8 fases y 11 apéndices escritos el 11/09/2026; solo falta su cuaderno de incidentes.")
s=s.replace("""**CertCore (angular-16) sigue solo propuesto: ninguna fase escrita.**""",
"""**CertCore (angular-16), escrito el 11/09/2026:** las ocho fases `be00`–`be07` y
los once apéndices `bea-01`–`bea-11`, en siete tandas (cada fase con los
apéndices que declara). **Falta solo `cuaderno-incidentes-be.md`** con los doce
IDs que las fases reservaron, `be-01` … `be-12`.

Decisiones cerradas al escribirlo, todas ya replicadas en la propuesta §5.5 con
su verificación y fecha:
- **Lumen 5.8.13** (28/08/2019, `php ^7.1.3`) es lo que corre; nace en **5.2.9**
  (7/09/2016). El primer Lumen con PHP 8 es **9.0.0** (15/02/2022): "subir el
  runtime" son **cuatro versiones mayores**, y ése es el ticket que abre el track.
  Lumen 6.0.0 salió **quince días** después de la última subida y nunca se hizo.
- **PHPUnit 8.5** (el `require-dev` de 5.8.13 es `^7.0|^8.0`); pruebas contra el
  `postgres:16.9` del compose con **transacción envuelta + ROLLBACK**, nunca
  SQLite. El criterio que manda es el tiempo de ciclo (<30 s).
- **Dos supuestos de la propuesta resultaron FALSOS al verificarlos** contra las
  notas de release, y el material los usa como *pistas heredadas que hay que
  verificar*: `standard_conforming_strings` es de **PG 9.1 (2011)** y los casts
  implícitos de **PG 8.3 (2008)**, las dos anteriores a la cadena. Las rupturas
  reales son PG 10 (`pg_xlog`→`pg_wal`), PG 12 (`WITH OIDS`, `abstime`,
  `consrc`/`adsrc`), PG 14 (SCRAM, que no rompió) y PG 15 (`public` sin CREATE
  **solo en clústeres nuevos** — muerde en el laboratorio y no mordió en
  producción; y `pg_start_backup` renombrado, que se lleva el script de respaldo
  por segunda vez).
- **Una columna generada NO puede resolver `certificates.status`**: exige
  expresión inmutable y `now()` no lo es. La salida es una **vista**, y el error
  `generation expression is not immutable` se usa como lección. Corregido también
  en el prompt de `bea-06`.
- Esquema: **siete tablas**, `items`/`answers` en `jsonb`, clave primaria
  compuesta en `templates` y el `id` (`elevator-annual-v2`) **derivado** al
  serializar. be05 recomienda la **foránea compuesta en `NOT VALID`** (88
  violaciones sobre 4.000 inspecciones sintéticas, semilla 20240915).""")
open(p,'w').write(s)
print('ok')
PY

# --- 2026-09-11T18:47:04 · Refresh memory index line
cd /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory && python3 - <<'PY'
import re
p='tracks-be-angular-decisiones.md'; s=open(p).read()
s=s.replace("angular-16 se\nalineó sin renombrar nada porque aún no tiene apéndices escritos.",
            "angular-16 se\nalineó sin renombrar nada porque entonces aún no tenía apéndices escritos; los\nonce que se escribieron el 11/09/2026 ya nacieron con `bea-NN-`.")
open(p,'w').write(s)
m='MEMORY.md'; t=open(m).read()
t=t.replace("— LabCore (angular-8) completo —9 fases, 12 apéndices y su cuaderno de 12 incidentes—; CertCore (angular-16) aún solo propuesto.",
            "— LabCore (angular-8) completo; CertCore (angular-16) con sus 8 fases y 11 apéndices escritos el 11/09/2026 (falta solo su cuaderno), y las decisiones verificadas de Lumen/PostgreSQL.")
open(m,'w').write(t)
print(open(m).read())
PY

# --- 2026-09-12T01:27:53 · Check git convention and notebook format for BE sections
cd angular-16-legacy-for-backend-devs && grep -n "🔥" 00-convencion-de-git-y-tags.md | head -20; echo "=== formato cuaderno ==="; grep -n '^#\{2,3\} ' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-12T01:28:08 · Read BE sections of format and git convention
sed -n '451,478p' prompts/formato-cuaderno-incidentes.md; echo "=== git conv 🔥 ==="; sed -n '431,476p' 00-convencion-de-git-y-tags.md

# --- 2026-09-12T01:28:24 · Read notebook format sections 1-3
sed -n '18,150p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-12T01:28:30 · Read commits, states and incident template
sed -n '193,250p' prompts/formato-cuaderno-incidentes.md; echo "===== PLANTILLA ====="; sed -n '243,390p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-12T01:28:36 · Read base notebook header
sed -n '1,120p' cuaderno-incidentes.md

# --- 2026-09-12T01:28:44 · Read a sample incident
awk '/^## Incidente 09 /,/^## Incidente 10 /' cuaderno-incidentes.md | head -130

# --- 2026-09-12T01:29:11 · Read base preparations doc structure
sed -n '1,60p' prompts/preparaciones-de-incidentes.md; echo ...; grep -n '^## ' prompts/preparaciones-de-incidentes.md | head -30

# --- 2026-09-12T01:30:19 · Write BE notebook header and index
cat > cuaderno-incidentes-be.md <<'MDEOF'
# 📓 Cuaderno de incidentes — Track BE 🔥

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · **12 incidentes · 8 horas**
> Declaradas **aparte** de las 122h del track base y de las 72h de las ocho fases BE

Doce tickets del otro lado del cable. Siguen llegando vagos y escritos por gente que no sabe qué es un facade — sólo que ahora la respuesta no está en DevTools: está en un log, en un `EXPLAIN`, en una línea del `.env`, o en un `grep` que **no** encuentra nada.

> 🧭 **El trato, igual que en el cuaderno base.** Cada incidente trae su solución de referencia, plegada al final. Está ahí porque trabajas sin instructor y necesitas saber si acertaste. **Abrirla antes de escribir la tuya no te ahorra tiempo: te ahorra el ejercicio**, que es lo único que estabas comprando. Lo mismo con las tres pistas: son un plan de rescate, no un atajo.

> 🔥 **Este cuaderno es del track opcional de backend.** Sus IDs —`be-01` … `be-12`— viven en un rango **independiente** del [`cuaderno-incidentes.md`](cuaderno-incidentes.md) base: los dos no se cruzan ni se renumeran el uno al otro. Si sólo hiciste el track base, este archivo no es tuyo y no te falta nada.

**Prerrequisito:** la fase BE que reserva cada incidente, terminada y etiquetada. El índice dice cuál.

---

## 🧭 Cómo se trabaja un incidente

### El método, en cuatro preguntas

Son las mismas del track base —están en [`forense-master.md`](forense-master.md) §1— y siguen valiendo enteras. Lo único que cambia es dónde se contesta cada una:

1. **¿Se reproduce, y con qué?** — con un flag del caos, con un dato, con **una línea del `.env`**, o hace falta otro código. Son **cuatro** formas en este track, y la tercera es la que casi nadie considera.
2. **¿Qué dice la evidencia observable, antes que el código?** — el log del contenedor, la salida de `psql`, un `EXPLAIN`, el `smoke.sh`. **No la consola del navegador**: aquí el frontend casi nunca es el testigo útil.
3. **¿En qué capa está?** — ruta, middleware, controlador, modelo, consulta, esquema, motor, contenedor, o **configuración que no es código**.
4. **¿De qué procedencia es el archivo que voy a tocar?** 🧬 — la pregunta 4 del método, girada sobre el eje de este track: el parche mínimo se escribe **en el estilo de la parcela que tocas**, y tu `ESTRATOS.md` de be02 dice cuál es.

> 🧭 **Y la que hay que añadir en este track, antes que todas:** *¿esto lo pudo cambiar alguien sin hacer un commit?* Diez minutos de `git log` y, si no hay candidato, se cambia de pregunta. El incidente `be-06` existe para grabar ese reflejo.

### Las cuatro formas de tener el sistema roto

Cada incidente dice cuál usa en su bloque **🔧 Preparación**, y el orden no es casual: **se usa siempre la más barata que sirva.**

**1 · Un flag del inyector de caos** (be01), cuando el fallo es de red o de respuesta. No toca tu código, no toca tus datos, y se apaga al recrear el contenedor.

```bash
CHAOS=malformed docker compose up -d api
```

**2 · Una tabla sembrada a propósito**, cuando el bug está en el dato. Los guiones viven en `sql/` y se aplican con el `psql` del contenedor de la base.

```bash
docker compose exec -T db psql -U postgres certcore < sql/seed-incidente-be-09.sql
```

Para volver: `docker compose exec api php artisan migrate:fresh --seed`.

**3 · Una línea del `.env`** — **la forma propia de este track**, y la que casi nadie considera cuando le piden reproducir algo.

```bash
sed -i '' 's/^POSTGRES_TAG=.*/POSTGRES_TAG=15.7/' .env    # en Linux: sed -i 's/…/'
docker compose up -d
```

**4 · Una rama de git**, y sólo cuando haya que romper código. Sale del tag `be-fase-*` de la fase que produce el incidente, con el slug completo:

```bash
git switch -c incidente-be/03 be-fase-02-estratos-por-procedencia
```

Las ramas llevan **namespace propio** (`incidente-be/NN`) para que `git branch --list 'incidente/*'` siga devolviendo sólo las del track base. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥.

> 🧭 **La regla, y sirve más allá de este cuaderno:** cuando alguien te pida reproducir un bug, la primera pregunta es *"¿esto se reproduce con un flag, con un dato, con una variable de entorno, o hace falta otro código?"*. En un sistema con contenedores, la tercera opción es más frecuente de lo que nadie espera — y es la que no aparece en ningún `git log`.

### La convención de commits

La misma del cuaderno base, con el ID de este:

```
incidente(be-06): abre — el informe falla y no hemos desplegado nada
incidente(be-06): repro — falla también en local, con los mismos datos
incidente(be-06): hipótesis descartada — no hay commits en el rango, ni en server/ ni en src/
incidente(be-06): causa — la base subió de versión; el cambio está en el .env
incidente(be-06): fix — reescribir la consulta del informe sin la función retirada
incidente(be-06): cierre — prueba de regresión y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`, `causa`, `fix`, `cierre`. **Commitea también los callejones sin salida**: en este track son la mitad del valor, porque medio cuaderno consiste en descartar la pista equivocada.

Y el par de tags, con el ID de este cuaderno adentro:

```bash
git tag -a inc/be-09/fila-huerfana-roto -m "be05 inc be-09: la prueba reproduce el bug y falla"
# …el fix…
git tag -a inc/be-09/fila-huerfana-fix  -m "be05 inc be-09: causa raíz y fix, con la prueba en verde"

git diff inc/be-09/fila-huerfana-roto inc/be-09/fila-huerfana-fix
git tag -n99 -l 'inc/be-*'          # ← este cuaderno entero, sin abrir un archivo
```

> ⚠️ **`be-06` no tiene par `-roto` / `-fix`, y es a propósito.** Su causa está en una línea de un archivo que no es código, así que su `git diff` está vacío. No es un incumplimiento de la convención: **es el contenido del incidente**, y la convención ya lo prevé ([`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥). El enunciado no lo dice antes; lo dice al resolverlo.

**Regla del archivo: se agrega, no se corrige.** Una hipótesis que resultó falsa no se borra: se marca como descartada, con la evidencia que la tumbó.

### Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y prueba de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

### Dos divergencias declaradas respecto del cuaderno base

Las dos vienen de que este track está construido distinto, y conviene tenerlas escritas para que nadie las lea como un descuido.

**1 · No hay campo «Ruta forense» que apunte a un archivo aparte.** El track BE **no tiene `forense-be-NN.md`**: su pieza forense es un log, un `EXPLAIN` o un `grep` vacío, y **cabe en la §6 de cada fase**, junto al código que la produce (la divergencia está declarada en `propuesta-fases-backend.md` §9). Así que cada incidente enlaza la **§6 de su fase**, y ese enlace cumple exactamente el mismo papel.

**2 · El reparto es por bloque de fases, no por semana.** El cuaderno base reparte sus veinte incidentes en cuatro semanas porque el curso dura un mes y tiene calendario. Este track es **opcional y a ritmo propio**: repartirlo por semanas inventaría un calendario que nadie tiene. Se reparte por la fase que lo habilita, que es el único orden real.

Y una consecuencia del reparto que también se declara: **no hay incidentes 🟢**. Para llegar aquí hay que haber hecho diez fases del track base con sus incidentes, más las fases BE previas. No queda ningún incidente de principiante que dar, y fabricar uno sería relleno. La escala arranca en 🟡 y pesa en 🟠.

---

## 📋 Índice

Actualiza la columna **Estado** en el mismo commit que abre o cierra cada incidente.

### Bloque 1 · El contrato y la familiaridad falsa (be00–be01)

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [be-01](#incidente-be-01--el-caché-no-se-limpia-nunca-y-no-encuentro-dónde-se-llena) | be01 | "El caché no se limpia nunca y no encuentro dónde se llena" | Resolución dinámica | 🟠 | ⬜ |
| [be-02](#incidente-be-02--copié-la-solución-de-internet-y-el-servidor-dejó-de-arrancar) | be01 | "Copié la solución de internet y el servidor dejó de arrancar" | Familiaridad falsa | 🟡 | ⬜ |

### Bloque 2 · La medición (be02)

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [be-03](#incidente-be-03--el-mismo-dato-sale-distinto-según-por-dónde-entres) | be02 | "El mismo dato sale distinto según por dónde entres" | Estratos por procedencia 🧬 | 🟠 | ⬜ |

### Bloque 3 · El reemplazo (be03)

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [be-04](#incidente-be-04--desde-el-despliegue-las-plantillas-salen-en-otro-orden) | be03 | "Desde el despliegue, las plantillas salen en otro orden" | Contrato | 🟡 | ⬜ |
| [be-05](#incidente-be-05--no-puedo-crear-inspecciones-nuevas-dice-que-el-id-ya-existe) | be03 | "No puedo crear inspecciones nuevas: dice que el id ya existe" | Datos y siembra | 🟠 | ⬜ |

### Bloque 4 · Lo que pasó sin que nadie mirara (be04)

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [be-06](#incidente-be-06--el-informe-falla-y-no-hemos-desplegado-nada) ⭐ | be04 | "El informe falla y no hemos desplegado nada" | Cambio fuera del repositorio | 🔴 | ⬜ |
| [be-07](#incidente-be-07--el-respaldo-de-anoche-no-se-puede-restaurar) | be04 | "El respaldo de anoche no se puede restaurar" | Artefacto de emergencia | 🟠 | ⬜ |
| [be-08](#incidente-be-08--el-certificado-dice-que-vence-hoy-y-en-el-pdf-dice-ayer) | be04 | "El certificado dice que vence hoy y en el PDF dice ayer" | Tiempo | 🟠 | ⬜ |

### Bloque 5 · La invariante (be05)

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [be-09](#incidente-be-09--una-inspección-de-2023-no-se-puede-reimprimir) | be05 | "Una inspección de 2023 no se puede reimprimir" | Versionado normativo | 🔴 | ⬜ |
| [be-10](#incidente-be-10--después-del-despliegue-no-puedo-actualizar-unas-inspecciones-viejas) | be05 | "Después del despliegue no puedo actualizar unas inspecciones viejas" | Restricciones | 🟠 | ⬜ |

### Bloque 6 · La reescritura a medias y el cierre (be06–be07)

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [be-11](#incidente-be-11--a-veces-devuelve-500-y-a-veces-422-con-el-mismo-dato) | be06 | "A veces devuelve 500 y a veces 422 con el mismo dato" | Dos caminos vivos | 🟠 | ⬜ |
| [be-12](#incidente-be-12--tenemos-un-assessment-que-recomienda-reescribir-en-seis-meses) | be07 | "Tenemos un *assessment* que recomienda reescribir en seis meses" | Decisión sin datos | 🔴 | ⬜ |

**Dos 🟡, siete 🟠, tres 🔴.** El peso está en el medio a propósito: los 🔴 de este cuaderno no son más difíciles de arreglar —dos de ellos ni siquiera terminan en un fix—, son más difíciles de **encuadrar**, que es la habilidad que el track viene a entrenar.

---

## 🧪 Incidentes
MDEOF
wc -l cuaderno-incidentes-be.md

# --- 2026-09-12T01:32:30 · Write incidents be-01 to be-03
cat >> cuaderno-incidentes-be.md <<'MDEOF'

## Incidente be-01 — "El caché no se limpia nunca y no encuentro dónde se llena"

> **Fase:** be01 · **Categoría:** Resolución dinámica · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min · **Pieza forense:** [`be01` §6](be01-lumen-y-la-familiaridad-falsa.md#️-6-errores-comunes-y-pieza-forense) — el `grep` vacío

### 🎫 El ticket

> *"Publicamos la v3 de la plantilla de ascensores el lunes y la gente del centro de servicio sigue viendo la v2. Si reinician el navegador tampoco cambia. Alguien dijo que hay un caché y que había que limpiarlo, pero no encontramos dónde se limpia ni quién lo llena."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

**Localizar la capa**, que es el entregable de verdad: dónde se guarda ese caché y qué código lo escribe. El fix es de dos líneas y viene después.

### 🔧 Preparación

Hace falta código: una rama. Sale del tag de be01.

```bash
git switch -c incidente-be/01 be-fase-01-lumen-y-la-familiaridad-falsa
docker compose up -d
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 15 min sin una idea nueva)</summary>

Tu reflejo va a ser `grep`. Hazlo, y **cronometra cuánto tardas en aceptar que no está dando resultados**: ese número es la mitad del ejercicio.

Después cambia de herramienta. Un caché tiene tres cosas que se pueden observar sin leer código: **un almacén** (¿dónde escribe?), **una clave** y **un tiempo de vida**. Empieza por el almacén, y pregúntaselo al proceso, no al archivo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
docker compose exec api php tools/probe.php "get_class(app('cache'))"
docker compose exec api php tools/probe.php "get_class(app('cache')->getStore())"
docker compose exec api ls -la storage/framework/cache/data 2>/dev/null | head
```

Y con el almacén localizado, la pregunta cambia: *¿quién escribe ahí?* El nombre del método que buscas no existe en ningún archivo. **La clave, en cambio, sí es texto literal.**

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`Cache::put('templates.all', $rows)` sin tercer argumento. En la línea 5.8 de Illuminate, ¿qué tiempo de vida tiene una entrada guardada así — y en qué versión posterior cambió ese valor por defecto?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`server/app/Http/Controllers/LegacyTemplateController.php`, líneas 28-36. El controlador de la parcela `laravel` cachea la lista de plantillas **sin caducidad y sin invalidación**:

```php
// Lo que hay:
$cached = Cache::get('templates.all');
if ($cached) {
    return $cached;
}

$rows = Template::active()->get();
Cache::put('templates.all', $rows);   // ← sin tercer argumento
```

Dos hechos se juntan para producir el síntoma:

1. **`Cache::put()` sin tiempo de vida guarda para siempre** en esta línea de Illuminate. El valor por defecto no es "una hora" ni "hasta el reinicio": es indefinido, y el almacén es de archivo, así que **sobrevive al reinicio del contenedor**.
2. **Nadie invalida la clave al publicar una versión nueva.** `TemplateController::store()` —el de la parcela `symfony`, que es el que usa el formulario de publicación— no sabe que existe ese caché. Son dos parcelas distintas y ninguna de las dos conoce a la otra (be02).

Y la parte que hace que esto sea un incidente de este track y no un despiste cualquiera: **`grep -rn "Cache::get" vendor/` no encuentra ninguna implementación**. `Cache` es un facade y `get()` no existe como método en ninguna clase con ese nombre: es `__callStatic` resolviendo contra el contenedor ([`bea-03`](bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md)). La herramienta con la que llevas quince fases investigando **no sirve aquí**, y el tiempo que tardaste en aceptarlo es el resultado del ejercicio.

**Parche mínimo**

Escrito en el estilo de la parcela `laravel`, que es la del archivo que se toca:

```php
// server/app/Http/Controllers/LegacyTemplateController.php
// Fix mínimo de un viernes: ponerle caducidad. No arregla la invalidación
// —eso es la refactorización—, pero acota el daño a diez minutos en vez de
// a "para siempre".
$rows = Template::active()->get();
Cache::put('templates.all', $rows, 600);   // 600 segundos, explícito
```

**La refactorización correcta**

Invalidar la clave donde se publica, no esperar a que caduque:

```php
// server/app/Http/Controllers/TemplateController.php (parcela symfony)
public function store(Request $request): JsonResponse
{
    $template = $this->templates->publish($request->all());

    // El caché de la otra parcela también es nuestro problema mientras las dos
    // estén vivas. Esto es exactamente el coste del estado intermedio de be06.
    app('cache')->forget('templates.all');

    return new JsonResponse($template, 201);
}
```

Fíjate en lo que acaba de pasar: **para arreglar bien un bug de una parcela hay que tocar la otra.** Ése es el coste medido de la reescritura a medias, y por eso be06 lo cuenta con un número.

**Prueba de regresión**

```php
// server/tests/TemplateCacheTest.php
/** @test */
public function publicar_una_version_invalida_el_cache_de_la_lista(): void
{
    $this->get('/templates');                        // llena el caché
    $this->assertNotNull(app('cache')->get('templates.all'));

    $this->post('/v2/templates', [
        'templateId' => 'elevator-annual',
        'version' => 3,
        'validFrom' => '2026-06-01',
        'items' => [],
    ]);

    // Si esta aserción falla, el caché sobrevivió a la publicación y el
    // coordinador va a seguir viendo la v2.
    $this->assertNull(app('cache')->get('templates.all'));
}
```

**Prevención**

Una regla de equipo que cabe en una línea y que este sistema no tenía: **ninguna llamada a `put()` sin tercer argumento.** Es comprobable con un `grep` —que aquí sí funciona, porque `put(` **es** texto literal en el código de la aplicación, a diferencia de la implementación del facade—:

```bash
grep -rn "Cache::put(\|->put(" server/app/ | grep -v ","
```

**Por qué llegó a producción**

Tres cosas se alinearon, y ninguna es de una persona:

- El caché se añadió durante un incidente de rendimiento, con prisa, y funcionó.
- El valor por defecto de la librería —guardar indefinidamente— es una decisión razonable del framework que **se vuelve peligrosa cuando el que llama no la conoce**, y es exactamente la clase de detalle que un dev reciclado de Laravel da por sabido sin comprobar.
- Las dos parcelas no se conocen, así que la publicación no podía invalidar lo que no sabía que existía.

**Si tu causa fue distinta a esta**

- *"Es el caché HTTP del navegador."* Encaja con "reiniciar el navegador no cambia nada" sólo si además hay cabeceras de caché — compruébalo con `curl -sD -`: no las hay. El síntoma también se explicaría así, y descartarlo cuesta diez segundos.
- *"La v3 no se publicó bien."* Es la hipótesis correcta que hay que descartar primero, y se descarta con un `SELECT` a `templates`: la fila está. Si te quedaste ahí, no perdiste el tiempo — descartar el dato antes que el código es el orden correcto.
- *"Es el `opcache` de PHP."* Plausible y falso: `opcache` cachea *código compilado*, no datos. Que se te haya ocurrido significa que estabas pensando en la capa correcta.

</details>

---

## Incidente be-02 — "Copié la solución de internet y el servidor dejó de arrancar"

> **Fase:** be01 · **Categoría:** Familiaridad falsa · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-30 min · **Pieza forense:** [`be01` §6](be01-lumen-y-la-familiaridad-falsa.md#️-6-errores-comunes-y-pieza-forense)

### 🎫 El ticket

> *"Necesitaba registrar cuánto tarda cada petición y busqué cómo se hace. Copié el ejemplo que salía primero, lo pegué, y ahora el contenedor arranca y se muere solo. No entiendo qué tiene de malo: el ejemplo tiene ochocientos votos."*

**Reportado por:** un compañero del equipo, en su rama
**Ambiente:** local

### 🎯 Qué se te pide

Reproducir, **explicar en una frase por qué el ejemplo es correcto y aun así no funciona aquí**, y dejar la versión que sí funciona. Y anotar cuánto tardaste: es la medición que be01 §5.9 te pidió empezar.

### 🔧 Preparación

Una rama, con el pegote ya puesto:

```bash
git switch -c incidente-be/02 be-fase-01-lumen-y-la-familiaridad-falsa
docker compose up -d api
docker compose logs -f api      # ← aquí está todo lo que necesitas
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El contenedor "arranca y se muere solo" no es un diagnóstico: es la ausencia de uno. El proceso escribió algo antes de morirse y no llegó a ninguna respuesta HTTP, así que no lo vas a ver con `curl`.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Lee el mensaje del log **entero**, incluida la primera línea, y fíjate en qué palabra exacta usa: ¿dice *undefined method*, *class not found*, o *undefined function*? Las tres significan cosas distintas y apuntan a capas distintas — la tabla está en [`be01` §5.7](be01-lumen-y-la-familiaridad-falsa.md#-57-los-cuatro-bugs-de-la-familiaridad-falsa-).

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El ejemplo registra el middleware con `$this->app['router']->aliasMiddleware(...)` desde un proveedor de servicios. Abre `bootstrap/app.php` y busca dónde se registran los middleware **en este framework**. ¿Cuántas formas hay, y cuántas de ellas existen aquí?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`server/app/Providers/TimingServiceProvider.php`, línea 14. El ejemplo copiado hace esto:

```php
// Lo que se pegó — es Laravel válido y aquí no:
public function boot()
{
    $this->app['router']->aliasMiddleware('timing', TimingMiddleware::class);
    Log::info('timing middleware registrado');
}
```

Y el log dice:

```
PHP Fatal error:  Uncaught Error: Call to undefined method
Laravel\Lumen\Routing\Router::aliasMiddleware()
in /app/server/app/Providers/TimingServiceProvider.php:14
```

Dos cosas fallan a la vez, y la segunda es la interesante:

1. **`aliasMiddleware()` no existe en el router de Lumen.** Es del router de Laravel. Aquí el registro se hace en `bootstrap/app.php`, con `$app->middleware([])` para el global o `$app->routeMiddleware([])` para el nombrado.
2. **`Log::info()` habría fallado igual**, con otro mensaje —`Class 'Log' not found`—, porque **los facades están apagados** (`$app->withFacades()` comentado desde 2016). Es decir: hay **dos** bugs en cinco líneas copiadas, y el primero tapa al segundo. Arreglar sólo el que ves te deja creyendo que terminaste.

> 🧠 **El ejemplo no está mal: está escrito para otro framework que se llama casi igual.** Ochocientos votos son ochocientas personas para las que funcionó — en Laravel. Ninguna de ellas te mintió.

**Parche mínimo**

```php
// server/bootstrap/app.php — el registro va aquí, no en un proveedor.
$app->routeMiddleware([
    'timing' => App\Http\Middleware\TimingMiddleware::class,
]);
```

```php
// server/app/Http/Middleware/TimingMiddleware.php
// Sin facades: el logger se pide al contenedor, que es como lo hace el resto
// del código heredado de este proyecto.
public function handle(Request $request, Closure $next)
{
    $startedAt = microtime(true);
    $response = $next($request);

    app('log')->info(sprintf('%s %s — %.1f ms',
        $request->getMethod(), $request->path(), (microtime(true) - $startedAt) * 1000));

    return $response;
}
```

Y `server/app/Providers/TimingServiceProvider.php` se borra entero: no hacía falta.

**La refactorización correcta**

Ninguna. Ésta **es** la forma correcta en este framework, y ahí está la lección: no había nada que refactorizar, había que saber dónde va. Lo que sí conviene es dejarlo escrito en la guía de una página de be06 (ejercicio 24), para que la próxima persona no repita los treinta minutos.

**Prueba de regresión**

Difícil de probar con una aserción, y conviene decirlo en vez de inventar una. Lo que sí se puede probar es **que la aplicación arranca**, que es lo que se rompió:

```php
// server/tests/BootstrapTest.php
/** @test */
public function la_aplicacion_arranca_y_responde_health(): void
{
    $this->get('/health');

    $this->assertResponseOk();
    $this->seeJsonStructure(['status', 'php', 'lumen', 'chaos']);
}
```

Una prueba de humo del arranque parece trivial hasta el día que alguien pega un proveedor de servicios de otro framework. **Y ese día llega en todos los proyectos.**

**Prevención**

No es una prueba ni un *linter*: es el protocolo de los diez minutos de [`be01` §5.9](be01-lumen-y-la-familiaridad-falsa.md#-59-el-experimento-de-los-diez-minutos-). Antes de pegar una respuesta de internet o de un asistente, **ejecutarla y anotar en qué falla**. En este proyecto no es prudencia general: es que hay cien veces más Laravel escrito que Lumen, y la respuesta plausible es la norma.

**Por qué llegó a producción**

No llegó — se quedó en una rama, y esa es la buena noticia. Llegó al equipo, que es distinto: el compañero perdió media tarde y la perdió **con razón**, porque el ejemplo era correcto, tenía votos, y no había ninguna señal disponible de que este framework no fuera aquél. La señal que faltaba no es técnica: es que nadie había escrito la página que dice *"aquí los middleware se registran en `bootstrap/app.php` y los facades están apagados"*.

**Si tu causa fue distinta a esta**

- *"Falta el proveedor en `bootstrap/app.php`."* Es exactamente la trampa: **añadirlo con `$app->register()` hace que el error cambie** —pasa a `Class 'Log' not found`— y parece que avanzas. Estás persiguiendo el segundo bug con el primero todavía puesto.
- *"Hay que encender los facades."* Resuelve el `Log::info` y deja el `aliasMiddleware` intacto. Y además cambia el arranque de una aplicación de ocho años para arreglar una línea de un ejemplo copiado: ver la autopsia de [`be01` §5.7](be01-lumen-y-la-familiaridad-falsa.md#-57-los-cuatro-bugs-de-la-familiaridad-falsa-).

</details>

---

## Incidente be-03 — "El mismo dato sale distinto según por dónde entres"

> **Fase:** be02 · **Categoría:** Estratos por procedencia 🧬 · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min · **Pieza forense:** [`be02` §6](be02-estratos-por-procedencia.md#️-6-errores-comunes-y-pieza-forense) — dos endpoints vecinos

### 🎫 El ticket

> *"El listado de plantillas del panel muestra la v1 arriba y el de la pantalla de plantillas muestra la v2 arriba. Son los mismos datos. Uno de los dos está mal pero no sabemos cuál, y el de arriba cambia según el día."*

**Reportado por:** analista de calidad
**Ambiente:** UAT

### 🎯 Qué se te pide

Determinar **si hay un bug**, y eso incluye la posibilidad de que no lo haya. Si lo hay, decidir **en qué archivo va el fix** y justificarlo — con `ESTRATOS.md` en la mano.

### 🔧 Preparación

Ninguna: el sistema ya está así desde be02. Sólo hace falta el laboratorio arriba.

```bash
git switch be-fase-02-estratos-por-procedencia   # o tu rama de trabajo
docker compose up -d
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

*"Cambia según el día"* con datos que no cambian es la firma de algo que **no está determinado**. Antes de abrir un archivo, compara las dos salidas — y compáralas varias veces seguidas, no una.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
for i in 1 2 3; do
  curl -s localhost:3000/templates    | jq -r '.[0].id'
  curl -s localhost:3000/v2/templates | jq -r '.[0].id'
done
```

Si las columnas no son estables entre ejecuciones, el problema no es *cuál de los dos está mal*. Y para saber por qué, hay una cláusula SQL cuya **ausencia** es la respuesta.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Uno de los dos controladores tiene `orderBy` y el otro no. ¿Qué garantiza PostgreSQL sobre el orden de un `SELECT` sin `ORDER BY`, y qué operación sobre la tabla hace que ese orden cambie de un día para otro?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Dos endpoints sirven el mismo recurso y **sólo uno ordena**:

```php
// server/app/Http/Controllers/TemplateController.php  (parcela symfony) — ordena
$query->orderBy('template_id')->orderBy('version');

// server/app/Http/Controllers/LegacyTemplateController.php  (parcela laravel) — no
$rows = Template::active()->get();
```

**Un `SELECT` sin `ORDER BY` no garantiza ningún orden.** No es que devuelva el de inserción: es que puede devolver cualquiera, y en PostgreSQL cambia en cuanto la tabla recibe un `UPDATE` —la fila actualizada se reescribe al final del montón— o cuando el planificador decide leerla de otra forma. Por eso "cambia según el día": alguien publicó o cerró una versión, y el montón se reorganizó.

El mock de json-server sí devolvía el orden de inserción del `db.json`, siempre, y el frontend nunca ordenó porque no le hizo falta. **La trampa estaba anotada en `CONTRACT.md` desde be00** y se cobró aquí.

> 🧠 **Ninguno de los dos endpoints está "mal escrito".** Están escritos por dos personas que venían de sitios distintos, y una de ellas tenía el reflejo de ordenar explícitamente. Eso no es calidad: es procedencia. Y saber cuál tocar es el trabajo.

**Parche mínimo**

En el archivo que el frontend consume —y sólo en ése—, escrito **en el estilo de esa parcela**:

```php
// server/app/Http/Controllers/LegacyTemplateController.php  (parcela laravel)
// Sin ORDER BY explícito el orden no está garantizado, y el frontend no ordena:
// la pantalla cambia sin que nadie la toque. Mismo criterio que /v2/templates.
$rows = Template::active()->orderBy('template_id')->orderBy('version')->get();
```

**La refactorización correcta**

`ORDER BY` explícito en **toda** consulta de colección del proyecto, no sólo en ésta. Es una revisión de veinte minutos con un `grep` y vale la pena hacerla entera:

```bash
grep -rn "->get()\|->all()" server/app/Http/Controllers/ | grep -v "orderBy"
```

Lo que **no** se hace es unificar los dos endpoints. Ésa es la decisión de [`be06`](be06-la-reescritura-a-medias.md), depende del *assessment*, y hacerla aquí sería resolver un ticket de treinta minutos con una migración.

**Prueba de regresión**

```php
// server/tests/TemplateOrderTest.php
/** @test */
public function el_listado_de_plantillas_tiene_orden_estable_tras_un_update(): void
{
    $before = json_decode($this->call('GET', '/templates')->getContent(), true);

    // Un UPDATE cualquiera: es lo que reorganiza el montón en PostgreSQL.
    DB::table('templates')
        ->where('template_id', 'boiler-annual')
        ->update(['valid_from' => '2022-01-02']);

    $after = json_decode($this->call('GET', '/templates')->getContent(), true);

    $this->assertSame(
        array_column($before, 'id'),
        array_column($after, 'id'),
        'El orden del listado cambió tras un UPDATE: falta ORDER BY.'
    );
}
```

**Prevención**

La regla es de una línea y va en la guía de be06: **toda consulta de colección lleva `ORDER BY` explícito.** Y una comprobación en el `smoke.sh` que fije el orden esperado del recurso más sensible — con la advertencia del ejercicio 18 de be00: fijar el orden en el contrato es una decisión, no un automatismo, y hay argumentos para no hacerlo.

**Por qué llegó a producción**

Porque **funcionó durante ocho años**. Con json-server el orden era estable por accidente, y el frontend se construyó encima de esa estabilidad sin que nadie la declarara. El reemplazo de be03 cambió el motor sin cambiar el contrato… salvo en esta propiedad, que **no estaba en el contrato porque nadie la había escrito**. Es el ejemplo más limpio del track de un contrato de facto: pesa igual que uno de derecho y es más difícil de encontrar.

**Si tu causa fue distinta a esta**

- *"Uno filtra `active()` y el otro no."* Es cierto y es otra diferencia real entre los dos endpoints; **compruébalo**, porque si tus dos listas tienen distinto número de elementos, ése es tu bug y el del orden está tapado detrás.
- *"Es el caché del incidente `be-01`."* Encaja con "cambia según el día" y se descarta comprobando que la clave no existe (`php tools/probe.php "app('cache')->get('templates.all')"`). Que se te haya ocurrido está bien: es la hipótesis barata y va antes.

</details>
MDEOF
wc -l cuaderno-incidentes-be.md

# --- 2026-09-12T01:33:55 · Write incidents be-04 and be-05
cat >> cuaderno-incidentes-be.md <<'MDEOF'

---

## Incidente be-04 — "Desde el despliegue, las plantillas salen en otro orden"

> **Fase:** be03 · **Categoría:** Contrato · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-30 min · **Pieza forense:** [`be03` §6](be03-el-reemplazo.md#️-6-errores-comunes-y-pieza-forense) — el primer `smoke.sh` en rojo

### 🎫 El ticket

> *"Desde que cambiaron el servidor, en la pantalla de plantillas la de calderas aparece primera y antes aparecía última. No es grave pero la gente pregunta si se borró algo. ¿Cambiaron algo de la pantalla?"*

**Reportado por:** inspector de campo
**Ambiente:** PROD

### 🎯 Qué se te pide

Contestar la pregunta del ticket —**no, nadie tocó la pantalla**— con evidencia, y decidir si esto se arregla o se documenta. Las dos respuestas son defendibles y lo que se evalúa es el argumento.

### 🔧 Preparación

Un dato: una tabla sembrada con el orden alterado.

```bash
docker compose exec -T db psql -U postgres certcore < sql/seed-incidente-be-04.sql
```

Para volver: `docker compose exec api php artisan migrate:fresh --seed`.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El ticket trae la mejor pista y está en su primera palabra: *"desde que cambiaron el servidor"*. Antes de mirar nada, contesta si el **contenido** cambió o sólo el **orden**, y hazlo sin abrir el navegador.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s localhost:3000/templates | jq -r '.[].id'
```

Los tres identificadores están. Ninguno se borró. Entonces la pregunta ya no es *qué falta*, es **quién decide ese orden** — y hay exactamente tres candidatos: la base, el backend y el frontend. Descarta el tercero con un `grep` en `src/`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

json-server devolvía el orden de inserción del `db.json`. ¿Qué devuelve PostgreSQL cuando la consulta no dice nada sobre el orden, y qué operación reciente sobre la tabla lo cambió?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

La misma familia que [`be-03`](#incidente-be-03--el-mismo-dato-sale-distinto-según-por-dónde-entres) vista desde el otro lado, y por eso este incidente es 🟡 y aquél 🟠: aquí ya sabes que existe la clase de problema.

`GET /templates` no lleva `ORDER BY`. El mock devolvía el orden de inserción del `db.json` —estable, garantizado por el archivo—, y el frontend se construyó encima de esa propiedad **sin que nadie la escribiera en el contrato**. Al reemplazar el servidor (be03), la propiedad desapareció: PostgreSQL no promete orden sin `ORDER BY`, y basta un `UPDATE` para que el montón se reorganice.

**Nadie tocó la pantalla, y el ticket tiene razón en preguntarlo.**

**Parche mínimo**

```php
// server/app/Http/Controllers/TemplateController.php
// El orden es contrato aunque nadie lo escribiera: el frontend no ordena.
$query->orderBy('template_id')->orderBy('version');
```

**La refactorización correcta**

Que el `smoke.sh` lo vigile, para que no vuelva a perderse en el próximo reemplazo:

```bash
# smoke.sh — el orden de /templates es contrato de facto: fíjalo.
ids=$(curl -s "$BASE_URL/templates" | jq -r '[.[].id] | join(",")')
check "GET /templates · orden estable por templateId y versión" \
      "boiler-annual-v1,elevator-annual-v1,elevator-annual-v2" "$ids"
```

Y aquí viene la decisión, porque **hay un argumento en contra y es bueno**: fijar el orden en el juez del contrato convierte una propiedad accidental en una promesa, y a partir de ese momento no se puede cambiar sin romper el contrato. El ejercicio 18 de be00 pedía exactamente este argumento. **La recomendación del track es fijarlo**, por una razón de dominio: la pantalla de plantillas la usa gente que compara versiones de una norma, y un orden que cambia solo destruye la confianza en un sistema de certificación. Pero si tu argumento fue el contrario y está escrito, está bien.

**Prueba de regresión**

La de [`be-03`](#incidente-be-03--el-mismo-dato-sale-distinto-según-por-dónde-entres) sirve tal cual. Si ya la escribiste, este incidente no necesita una nueva — y darse cuenta de eso también es parte del ejercicio.

**Prevención**

`ORDER BY` explícito en toda consulta de colección, y la comprobación en el `smoke.sh`. Las dos juntas: la primera arregla hoy, la segunda impide que se pierda en el próximo cambio de motor.

**Por qué llegó a producción**

Porque el `smoke.sh` **pasó en verde**. El juez del contrato comprobaba forma, tipos y presencia de campos, y el orden de un array es exactamente la clase de propiedad que se olvida al escribir un contrato — hasta que alguien la nota en una pantalla. El propio `CONTRACT.md` lo había anotado como *"trampa"* en be00 y aun así no se convirtió en comprobación: **una trampa anotada y no verificada es una nota, no una defensa.**

**Si tu causa fue distinta a esta**

- *"Se cambió el `db.json`."* Se descarta en veinte segundos con un `SELECT`, y es la hipótesis correcta que va primero: el dato antes que el código.
- *"El frontend ordena y alguien lo tocó."* Se descarta con `git diff fase-10-certificados-vigencia..HEAD -- src/`, que **tiene que estar vacío** — y comprobarlo es, además, el checklist de todas las fases BE.

</details>

---

## Incidente be-05 — "No puedo crear inspecciones nuevas: dice que el id ya existe"

> **Fase:** be03 · **Categoría:** Datos y siembra · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-40 min · **Pieza forense:** [`be03` §6](be03-el-reemplazo.md#️-6-errores-comunes-y-pieza-forense)

### 🎫 El ticket

> *"Estoy en el cliente y no puedo abrir la inspección. Le doy a crear y sale error rojo. Lo intenté cuatro veces. Un compañero en otra sucursal dice que a él sí le deja."*

**Reportado por:** inspector de campo
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir, encontrar la causa, y aplicar el **hotfix mínimo** — este ticket bloquea trabajo en campo y no admite esperar a la refactorización.

### 🔧 Preparación

Un dato: la base sembrada con la secuencia desajustada, que es como quedó tras el reemplazo.

```bash
docker compose exec -T db psql -U postgres certcore < sql/seed-incidente-be-05.sql
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

*"A él sí le deja"* es la pista que descarta media investigación: no es una caída, no es la red, no es el despliegue. Es algo que depende de **qué** se está creando o de **cuándo**.

Y el "error rojo" tiene un cuerpo. Búscalo donde vive de verdad en este track: el log del contenedor.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
docker compose logs api | grep -i "duplicate\|unique\|SQLSTATE" | tail -5
```

El mensaje nombra una restricción y un valor. Ese valor no lo mandó nadie desde el navegador: lo puso la base. **¿De dónde saca PostgreSQL el siguiente `id` de una columna `serial`?**

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

```sql
SELECT last_value FROM inspections_id_seq;
SELECT max(id) FROM inspections;
```

Compara los dos números. Y después pregúntate qué pasa con una secuencia cuando alguien inserta filas **con el `id` puesto a mano** — como hizo el sembrador de be03.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

```
SQLSTATE[23505]: Unique violation: 7 ERROR:  duplicate key value violates
unique constraint "inspections_pkey"
DETAIL:  Key (id)=(3) already exists.
```

La secuencia `inspections_id_seq` va por 3 y la tabla tiene inspecciones hasta la 503. La causa está en el sembrador de [`be03` §5.4](be03-el-reemplazo.md#-54-la-siembra-desde-tu-propio-dbjson): insertó las filas **con su `id` explícito** —tenía que hacerlo, porque el frontend conoce la inspección 501 por su número— y **la secuencia no se enteró**. En PostgreSQL, un `INSERT` que trae el valor de una columna `serial` no consume el siguiente de la secuencia: la secuencia sigue donde estaba.

Así que el sistema funcionó perfectamente hasta la primera creación de una inspección nueva, que intentó el `id` 1, chocó, reintentó el 2, chocó, y así. **Y "al compañero de otra sucursal sí le deja"** porque estaba creando un **cliente**, no una inspección: `clients_id_seq` sí se reajustó — el sembrador tenía tres `setval` y ése estaba, el de `inspections` se quedó fuera en una edición posterior.

> 🧠 **El error más caro de una migración de datos no está en los datos: está en los objetos que los acompañan.** Secuencias, índices, permisos, disparadores. Los datos se ven al mirar la tabla; una secuencia desajustada sólo se ve el día que alguien escribe.

**Parche mínimo**

Una sentencia, y el sistema vuelve a funcionar en el acto:

```sql
-- Reajusta la secuencia al máximo id existente. Es idempotente y se puede
-- correr en caliente: no bloquea la tabla.
SELECT setval('inspections_id_seq', (SELECT max(id) FROM inspections));
```

**La refactorización correcta**

Que el sembrador no pueda volver a dejarse una: **derivar la lista de secuencias del catálogo** en vez de escribirlas a mano.

```php
// server/database/seeds/DbJsonSeeder.php
// Reajusta TODAS las secuencias de la base, sin lista escrita a mano. Una
// lista a mano se queda corta el día que alguien añade una tabla — que es
// exactamente lo que pasó con inspections.
$sequences = DB::select("
    SELECT s.relname AS sequence_name, t.relname AS table_name, a.attname AS column_name
    FROM pg_class s
    JOIN pg_depend d ON d.objid = s.oid
    JOIN pg_class t ON t.oid = d.refobjid
    JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = d.refobjsubid
    WHERE s.relkind = 'S'
");

foreach ($sequences as $sequence) {
    DB::statement(sprintf(
        "SELECT setval('%s', COALESCE((SELECT max(%s) FROM %s), 1))",
        $sequence->sequence_name, $sequence->column_name, $sequence->table_name
    ));
}
```

**Prueba de regresión**

```php
// server/tests/SeederSequenceTest.php
/** @test */
public function tras_sembrar_se_puede_crear_una_fila_nueva_en_cada_tabla(): void
{
    foreach (['inspections', 'clients', 'findings'] as $table) {
        $max = DB::table($table)->max('id');
        $next = DB::select("SELECT last_value FROM {$table}_id_seq")[0]->last_value;

        $this->assertGreaterThanOrEqual(
            $max, $next,
            "La secuencia de {$table} va por detrás del max(id): el primer INSERT nuevo va a fallar."
        );
    }
}
```

**Prevención**

La prueba de arriba, corriendo **después de sembrar** en el ciclo de be06. Y una regla que vale para cualquier migración de datos: **la lista de lo que hay que arreglar después de una carga masiva no se escribe a mano** — secuencias, `ANALYZE`, índices desactivados, permisos. Se deriva del catálogo o se olvida una.

**Por qué llegó a producción**

Porque el `smoke.sh` sólo lee. Las veinticuatro comprobaciones del contrato son `GET` y un `POST /auth/login`; **ninguna crea una inspección**, así que el juez pasó en verde sobre un sistema en el que no se podía escribir. Es el agujero más caro que un contrato ejecutable puede tener, y sólo se ve cuando alguien lo formula así: *¿qué operación real del negocio no está en el juez?*

**Si tu causa fue distinta a esta**

- *"El frontend manda un `id`."* Se descarta mirando el cuerpo de la petición en el log. Es la hipótesis correcta que va primero, porque acusaría al cliente y eso se comprueba en diez segundos.
- *"Hay dos usuarios creando a la vez."* Explicaría un choque aislado, no cuatro seguidos, y no explicaría que a otra persona sí le deje en otro recurso. Descartarla con el patrón de repetición es un razonamiento correcto.
- *"Falta una restricción única."* Es lo contrario de lo que pasa: la restricción está haciendo su trabajo. Si llegaste aquí, la evidencia que te faltaba era el `DETAIL: Key (id)=(3)` — el valor pequeño es toda la historia.

</details>
MDEOF
wc -l cuaderno-incidentes-be.md

# --- 2026-09-12T01:35:44 · Write incidents be-06 and be-07
cat >> cuaderno-incidentes-be.md <<'MDEOF'

---

## Incidente be-06 — "El informe falla y no hemos desplegado nada" ⭐

> **Fase:** be04 · **Categoría:** Cambio fuera del repositorio · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-70 min · **Pieza forense:** [`be04` §6](be04-el-salto-de-version-que-nadie-corrio.md#️-6-errores-comunes-y-pieza-forense) — el incidente cuyo `git log` está vacío

### 🎫 El ticket

> *"El informe mensual de certificados vencidos lleva fallando desde el fin de semana. No hemos desplegado nada. Le preguntamos a infraestructura y dicen que ellos tampoco tocaron nada. Necesitamos el informe para el comité del jueves."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** PROD

### 🎯 Qué se te pide

Encontrar la causa. Y **cronometrar cuántos minutos pasas dentro de `git`** antes de cambiar de pregunta: ese número es el resultado real del ejercicio, más que el fix.

### 🔧 Preparación

**Una línea del `.env`** — la forma propia de este track, y aquí no es una comodidad: es el incidente.

```bash
sed -i '' 's/^POSTGRES_TAG=.*/POSTGRES_TAG=16.9/' .env    # en Linux: sed -i 's/…/'
docker compose down -v && docker compose up -d
docker compose exec api php artisan migrate --seed
docker compose exec -T db psql -U postgres certcore < sql/seed-incidente-be-06.sql
```

> El guion de siembra deja el sistema **como estaba antes**: los datos de siempre y el informe mensual instalado. Lo único distinto respecto de la última vez que el informe funcionó está en el `.env`, y no te lo van a decir.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 15 min en `git`)</summary>

Si llevas quince minutos en `git log`, `git blame` y el historial de despliegues sin un solo candidato, **la pista es esa misma ausencia**. Ponle un límite y cambia de pregunta.

La nueva pregunta no es *"¿quién lo tocó?"*. Es: **¿qué partes de este sistema pueden cambiar sin pasar por un commit?** Haz la lista antes de seguir. Debería tener al menos cinco entradas.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
docker compose logs api | grep -i "error\|SQLSTATE" | tail -5
docker compose exec db psql -U postgres certcore -c 'SELECT version();'
docker compose exec db cat /var/lib/postgresql/data/PG_VERSION
```

Compara la tercera salida con lo que creías que estaba corriendo. Y compárala con lo que dice el `.env` **de la rama que desplegaste hace seis meses**.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El informe usa una función de PostgreSQL que existía y ya no. Búscala en `SQL-CRUDO.txt` —el inventario que hiciste en [`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md), ejercicio 5— y después búscala en la sección *"Migration to Version N"* de las notas de release de la versión que está corriendo de verdad.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El informe mensual —`server/app/Reports/ExpiredCertificatesReport.php`— construye su consulta con `DB::select()`, SQL a mano, y una de sus columnas se apoya en `pg_constraint.consrc` para etiquetar de qué regla viene cada exclusión. Esa columna **se eliminó en PostgreSQL 12**:

> *"Remove deprecated `pg_constraint.consrc` and `pg_attrdef.adsrc` columns"* — notas de release de PostgreSQL 12, *Migration to Version 12*.

Y el sistema estaba corriendo PostgreSQL 16 desde el fin de semana, porque el proveedor gestionado subió la versión en una ventana de mantenimiento anunciada por un correo que alguien archivó ([`be04` §4](be04-el-salto-de-version-que-nadie-corrio.md#-4-concepto-mínimo)).

**Las dos frases del ticket eran ciertas.** Nadie desplegó: el árbol de fuentes no cambió. Infraestructura no "tocó nada" en el sentido en que ellos lo entienden: siguieron un calendario de fin de soporte. El cambio existe y está en un archivo que no es código:

```bash
# .env — la versión de la base vive AQUÍ, fuera del código fuente.
POSTGRES_TAG=16.9
```

> 🧭 **Cuando el `git log` está vacío y el sistema falla, el sistema tiene razón.** Lo que falta es tu inventario de lo que puede cambiar sin pasar por un commit: el `.env`, el tag de una imagen, la versión de un servicio gestionado, un secreto que rotó, un certificado que caducó, una política del proveedor.

Y el segundo hallazgo, que es el que hace que esto no sea mala suerte: **la factura la pagó el SQL a mano.** Las demás consultas del informe —las que construye Eloquent— sobrevivieron a cuatro versiones mayores sin una línea de cambio. Sólo se rompió la que alguien escribió a mano para ir más rápido, y estaba en tu inventario desde be04.

**Parche mínimo**

```php
// server/app/Reports/ExpiredCertificatesReport.php
// pg_constraint.consrc se eliminó en PostgreSQL 12; la forma soportada —y que
// funciona igual desde 9.x— es pg_get_constraintdef(). El cambio es compatible
// hacia atrás, así que no hay que condicionarlo por versión.
$rows = DB::select("
    SELECT c.conname,
           pg_get_constraintdef(c.oid) AS definition   -- antes: c.consrc
    FROM pg_constraint c
    WHERE c.conrelid = 'certificates'::regclass
");
```

**La refactorización correcta**

Dos cosas, y la segunda importa más que la primera:

1. Revisar **las demás** entradas de `SQL-CRUDO.txt` contra las notas de release de la cadena. Si una se rompió, las otras están igual de expuestas y hoy sabes cuáles son.
2. **Hacer visible la versión de la base.** Que el sistema sepa contra qué está corriendo y lo diga:

```php
// server/app/Http/Controllers/HealthController.php
// La versión de la base en /health. No previene el cambio —no es asunto nuestro
// impedirlo—, pero convierte "no sabemos qué pasó" en un dato de treinta segundos.
'db' => DB::select('SHOW server_version')[0]->server_version,
```

Dónde debería vivir esa comprobación —en `/health`, en el `smoke.sh` o en la supervisión— es una decisión con tres respuestas defendibles, y era el ejercicio 🔥 de be04.

**Prueba de regresión**

```php
// server/tests/ExpiredCertificatesReportTest.php
/** @test */
public function el_informe_de_vencidos_corre_contra_la_base_real(): void
{
    // La prueba no comprueba el contenido del informe: comprueba que la
    // consulta es VÁLIDA contra el motor que hay. Es exactamente lo que faltaba.
    $rows = (new ExpiredCertificatesReport())->run();

    $this->assertIsArray($rows);
}
```

Una prueba que sólo verifica que una consulta no explota parece pobre, y para el SQL a mano **es justo la que hace falta**: lo que se rompió no fue la lógica, fue la compatibilidad. Corriendo contra el `postgres:16.9` del compose (be06), esta prueba se habría puesto roja el día del cambio de versión — si alguien hubiera corrido la suite después de la ventana de mantenimiento.

**Prevención**

- **La versión de la base, visible** en `/health` y comparada en la supervisión contra la esperada.
- **El inventario de SQL a mano** (`SQL-CRUDO.txt`) revisado cada vez que la base suba de versión mayor. Son diez minutos y dice exactamente dónde mirar.
- **Y la más barata de las tres:** un acuerdo con quien opera la base — que avise **al equipo**, no a un buzón. La ausencia de ese acuerdo es lo que convirtió una ventana de mantenimiento anunciada en un incidente sorpresa.

**Por qué llegó a producción**

No llegó a producción: **producción cambió debajo.** Y ésa es la lección entera del incidente.

El post-mortem sereno tiene tres causas y ninguna es una persona:

1. **Nadie era dueño de la aplicación.** La base tenía calendario, proveedor y auditoría; el código no tenía a nadie a quien avisar.
2. **El correo llegó a un buzón, no a un equipo.** Archivarlo fue el comportamiento razonable de alguien que no podía saber qué implicaba.
3. **El 95% siguió funcionando**, y por eso nadie miró. La compatibilidad hacia atrás de PostgreSQL —que es excelente— es lo que permitió ocho años de abandono. **La calidad de la compatibilidad es la causa de fondo**, y es una paradoja real, sin villanos.

Y la ironía la puso el propio negocio: fue una **auditoría de cumplimiento** la que exigió correr sobre versiones soportadas. *La certificadora no pasaba su propia auditoría.*

**⚠️ Este incidente no tiene par `-roto` / `-fix`.** No hay diff que enseñar: la causa es una línea de un archivo que no es código. Cierra con un solo tag —`inc/be-06/consrc-fix`— y **escribe en su mensaje que el par no existe y por qué**. Esa anomalía en `git tag -n99 -l 'inc/be-*'` es el mejor recordatorio que te vas a dejar.

**Si tu causa fue distinta a esta**

- *"Alguien desplegó y no lo dijo."* Es la hipótesis correcta y hay que descartarla **con evidencia**, no con confianza: `git log --since` en el rango, y el registro de despliegues. Descartarla en diez minutos es el comportamiento buscado; seguir cuarenta es el hábito que este incidente viene a romper.
- *"Se corrompieron los datos."* Encaja con "el informe falla" y se descarta corriendo el resto de informes, que funcionan. Bien razonado: separar *"falla todo"* de *"falla esto"* es el primer corte.
- *"Es un problema de permisos tras el cambio."* **Muy cerca, y plausible por un motivo real**: PostgreSQL 15 revocó `CREATE` en el esquema `public` para clústeres nuevos. No es la causa aquí —el informe sólo lee—, pero si tu laboratorio se creó desde cero puede que hayas visto ese error primero. Que se te ocurriera significa que ya estabas mirando el motor, que es donde había que estar.

</details>

---

## Incidente be-07 — "El respaldo de anoche no se puede restaurar"

> **Fase:** be04 · **Categoría:** Artefacto de emergencia · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min · **Pieza forense:** [`be04` §5.3](be04-el-salto-de-version-que-nadie-corrio.md#-53-lo-que-se-rompió-de-verdad-con-cita)

### 🎫 El ticket

> *"Necesitamos restaurar la base a como estaba el martes para revisar un certificado que alguien modificó. El archivo de respaldo del martes existe y pesa lo normal, pero el equipo dice que no se puede restaurar. ¿Cuántos días de respaldos tenemos buenos?"*

**Reportado por:** jefe de operaciones
**Ambiente:** PROD

### 🎯 Qué se te pide

Determinar **desde cuándo** los respaldos no sirven, y explicar por qué nadie se enteró. El fix del guion es lo de menos; la respuesta que el ticket necesita es la fecha.

### 🔧 Preparación

Una rama, con el guion de respaldo de 2016 tal como está:

```bash
git switch -c incidente-be/07 be-fase-04-el-salto-de-version-que-nadie-corrio
docker compose up -d
bash scripts/backup.sh          # ← míralo fallar
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

*"El archivo existe y pesa lo normal"* es la pista central y hay que leerla al revés: **algo escribió un archivo de tamaño plausible que no sirve**. Un guion que falla a la mitad puede dejar exactamente eso.

Y la pregunta que ordena la investigación no es *"¿por qué falla?"*, es **"¿desde cuándo?"**.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Abre `scripts/backup.sh` y fíjate en qué funciones de PostgreSQL llama — y en si el guion comprueba el código de salida de cada paso. Después busca esos nombres en las notas de release de la cadena `9.6 → 11 → 13 → 16`.

Son **dos** nombres retirados en **dos** versiones distintas, no uno.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`pg_xlog` y las funciones `xlog` se renombraron en PostgreSQL 10. `pg_start_backup()` y `pg_stop_backup()` se renombraron —y el modo exclusivo se eliminó— en PostgreSQL 15. ¿En cuál de las dos subidas dejó de servir el respaldo, y por qué nadie lo notó en ninguna de las dos?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`scripts/backup.sh`, escrito en 2016 y no tocado desde entonces. Se rompió **dos veces**, en dos subidas distintas, y las dos veces siguió generando un archivo:

```bash
# Lo que hay, resumido:
psql -c "SELECT pg_start_backup('nightly')"      # ← eliminada en PG 15
tar czf "$DEST/certcore-$(date +%F).tar.gz" "$PGDATA"
psql -c "SELECT pg_stop_backup()"                # ← ídem
psql -c "SELECT pg_switch_xlog()"                # ← renombrada en PG 10
```

```
ERROR:  function pg_start_backup(unknown) does not exist
ERROR:  function pg_switch_xlog() does not exist
```

Y el detalle que lo convierte en un incidente y no en un error: **el guion no comprueba el código de salida de ninguna línea**. Los `psql` fallan, el `tar` corre igual, y el archivo se genera — con el directorio de datos copiado **sin haber puesto la base en modo respaldo**, es decir, un `tar` de archivos que se estaban escribiendo. Pesa lo normal. Y no sirve.

Cronología, que es lo que el ticket pide:

| Cuándo | Qué pasó | Estado del respaldo |
|---|---|---|
| 2019 (subida a PG 11) | `pg_switch_xlog()` empieza a fallar | Degradado: el archivo se genera |
| 2024 (subida a PG 16, pasando por 15) | `pg_start_backup()`/`pg_stop_backup()` desaparecen | **Inservible** |

**Los respaldos no sirven desde la subida de 2024.** Los anteriores son de calidad dudosa desde 2019.

> 🧠 **Lo que se rompe primero es lo que sólo se usa en emergencias, y su fallo no avisa.** Un endpoint roto lo reporta un usuario en diez minutos; un respaldo roto no lo reporta nadie hasta el día que hay que restaurar — que es, por definición, el peor día posible.

**Parche mínimo**

```bash
#!/usr/bin/env bash
# scripts/backup.sh
set -euo pipefail   # ← LA LÍNEA QUE FALTABA: que un fallo detenga el guion.

# pg_dump no depende del modo de respaldo exclusivo (eliminado en PG 15) ni de
# las funciones xlog (renombradas en PG 10). Para el tamaño de esta base es
# suficiente, y es la opción que menos envejece.
pg_dump -U postgres -Fc certcore > "$DEST/certcore-$(date +%F).dump"

# Y la comprobación que convierte un archivo en un respaldo:
pg_restore --list "$DEST/certcore-$(date +%F).dump" > /dev/null
echo "OK: respaldo verificado $(date +%F)"
```

**La refactorización correcta**

No es el guion: es el **ensayo**. Un respaldo que no se ha restaurado nunca no es un respaldo, es un archivo. Un trabajo semanal que restaure el último volcado en una base desechable y corra tres `SELECT` de comprobación cuesta media hora de escribir y es la diferencia entre tener respaldos y creer que los tienes.

**Prueba de regresión**

```bash
# scripts/verify-backup.sh — corre después de cada respaldo, y falla ruidoso.
set -euo pipefail

docker compose exec -T db createdb -U postgres restore_check
pg_restore -U postgres -d restore_check "$1"

rows=$(docker compose exec -T db psql -U postgres restore_check -tAc \
       'SELECT count(*) FROM certificates')
docker compose exec -T db dropdb -U postgres restore_check

[ "$rows" -gt 0 ] || { echo "❌ el respaldo restauró 0 certificados"; exit 1; }
echo "OK: $rows certificados restaurados"
```

**Prevención**

- **`set -euo pipefail` en todo guion de operaciones.** La ausencia de esa línea es lo que convirtió dos errores ruidosos en un fallo silencioso de cinco años.
- **Verificar cada respaldo restaurándolo**, no comprobando que el archivo existe.
- Y la general, que sale de este incidente y de [`be04`](be04-el-salto-de-version-que-nadie-corrio.md): **al subir una versión mayor, ejercitar los artefactos de emergencia antes de dar la subida por buena.** Respaldo, restauración, plan de vuelta atrás. Están fuera del `smoke.sh` por definición, así que hay que acordarse a mano.

**Por qué llegó a producción**

Porque un respaldo sólo falla el día que hay que restaurar, y ese día tardó cinco años en llegar. Las dos subidas de versión que lo rompieron estaban anunciadas, se hicieron bien, y **nadie tenía la lista de artefactos que había que reejercitar después** — porque esa lista no existía en ninguna parte. No es negligencia: es una tarea que nadie tenía asignada porque nadie sabía que existía.

**Si tu causa fue distinta a esta**

- *"El archivo está corrupto por el almacenamiento."* Hipótesis razonable y se descarta abriendo el `tar`: se abre bien. El archivo está íntegro; lo que no sirve es su **contenido**, que es una distinción incómoda y correcta.
- *"Falta espacio en disco."* Explicaría un archivo truncado, no uno de tamaño normal. El "pesa lo normal" del ticket la descarta sola, y darse cuenta de eso es leer bien el reporte.
- *"Es un problema de permisos del usuario de respaldo."* Plausible, y de hecho el mensaje de `pg_start_backup` en algunas versiones habla de privilegios. Se descarta corriendo la función a mano como superusuario: **tampoco existe**.

</details>
MDEOF
wc -l cuaderno-incidentes-be.md

# --- 2026-09-12T01:37:28 · Write incidents be-08 and be-09
cat >> cuaderno-incidentes-be.md <<'MDEOF'

---

## Incidente be-08 — "El certificado dice que vence hoy y en el PDF dice ayer"

> **Fase:** be04 · **Categoría:** Tiempo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min · **Pieza forense:** [`be04` §5.5](be04-el-salto-de-version-que-nadie-corrio.md#-55-la-cicatriz-de-las-fechas--4) · Apoyo: [`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md)

### 🎫 El ticket

> *"El certificado CERT-2024-0087 aparece como vigente en la pantalla, pero el PDF que descargué esta mañana dice que venció ayer. Es el mismo certificado. El cliente ya llamó preguntando. ¿Cuál de los dos vale?"*

**Reportado por:** coordinador de certificaciones
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar **cuál de los dos tiene razón** — y la respuesta honesta puede ser "ninguno". Después, proponer qué habría que decidir para que la pregunta deje de tener sentido. **No migres las columnas**: eso está costeado y diferido.

### 🔧 Preparación

Un dato con la fecha justa en el borde, y una variable de entorno:

```bash
docker compose exec -T db psql -U postgres certcore < sql/seed-incidente-be-08.sql
# El certificado del ticket queda con valid_until a las 00:30 de hoy.
docker compose up -d api      # el contenedor de PHP corre en UTC
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Dos capas dan dos respuestas sobre el mismo dato. Antes de decidir cuál está mal, **pregúntale a las dos por separado** y anota las dos respuestas con su hora exacta. Después pregúntate qué reloj usó cada una.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
docker compose exec db  psql -U postgres certcore -c "SELECT now(), current_setting('TimeZone');"
docker compose exec api php -r 'echo date_default_timezone_get(), " | ", date("c"), "\n";'
docker compose exec db  psql -U postgres certcore -c \
  "SELECT valid_until, pg_typeof(valid_until) FROM certificates WHERE id='CERT-2024-0087';"
```

La tercera salida trae la palabra que explica el incidente entero, y está en el tipo de la columna.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El `db.json` original guardaba `2024-06-30T00:30:00-05:00`. La columna es `timestamp` **sin zona**. ¿Qué guardó PostgreSQL exactamente, y qué le pasó al `-05:00`? Y con ese valor guardado, ¿qué contesta un proceso que corre en UTC frente a uno que corre en `America/Bogota`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Tres capas, tres relojes, **un dato al que le falta la mitad de la información**.

```
db.json original :  2024-06-30T00:30:00-05:00
columna          :  2024-06-30 00:30:00          ← timestamp SIN zona: el offset se descartó
```

El offset **no se guardó en ninguna parte**. A partir de ahí, cada capa lo interpreta con su propio reloj:

- La **pantalla** pregunta al backend, que compara con `now()` de una sesión en UTC. A las 04:00 UTC del 30 de junio, `00:30` todavía no ha pasado: **vigente**.
- El **PDF** se genera en el navegador del coordinador ([`a08`](a08-pdf-cliente.md)), en `America/Bogota`, y ahí la comparación cae del otro lado: **vencido ayer**.

**Los dos tienen razón dentro de su marco, y ninguno de los dos es la respuesta correcta** — porque la pregunta *"¿está vigente?"* no tiene respuesta única mientras nadie haya decidido **a qué hora y en qué zona vence un certificado**.

> 🧠 **Esto no es un bug de fechas. Es una decisión de negocio que nunca se tomó, disfrazada de bug de fechas.** Por eso no se arregla convirtiendo una columna: se arregla escribiendo una frase y después implementándola en las tres capas.

Y hay un agravante que conviene mirar de frente: la interpretación *"todos los datos entraron con `-05:00`"` es una **suposición**. La sostiene el `db.json` y no la verifica nadie. Si un solo registro entró desde otra zona, esa fila está mal para siempre y **no hay forma de saber cuál es**.

**Parche mínimo**

No hay parche de código honesto para este incidente, y decirlo es parte de la solución. Lo mínimo es **la frase**, escrita en `INVARIANTES.md` y firmada:

> *La vigencia de un certificado de CertCore termina al final del día calendario de `valid_until`, en `America/Bogota`. Un certificado cuyo `valid_until` cae el 30 de junio está vigente hasta las 23:59:59 del 30 de junio, hora de Bogotá.*

Con esa frase escrita, el fix del backend es una línea y las tres capas dicen lo mismo:

```php
// server/app/Http/Serializers/CertificateSerializer.php
// La comparación se hace SIEMPRE reinterpretando la fecha heredada en la zona
// de origen asumida (-05:00 / America/Bogota), y contra el fin del día. La
// suposición está declarada en INVARIANTES.md; sin declararla, esto sería
// adivinar con más pasos.
$expiresAt = new DateTimeImmutable(
    $certificate->valid_until, new DateTimeZone('America/Bogota')
);
$expiresAt = $expiresAt->setTime(23, 59, 59);

$status = $expiresAt < new DateTimeImmutable('now') ? 'expired' : 'valid';
```

**La refactorización correcta**

Migrar las seis columnas de fecha con hora a `TIMESTAMPTZ`, que es la 💸 declarada en [`be03` §5.1](be03-el-reemplazo.md#-51-el-esquema-entero) y costeada en [`be04` §5.5](be04-el-salto-de-version-que-nadie-corrio.md#-55-la-cicatriz-de-las-fechas--4). **No se hace aquí**, y el motivo es serio: convertir obliga a **elegir una zona de origen y esa elección es irreversible**. Se hace una vez, con el procedimiento de siete pasos de [`be05` §5.5](be05-la-invariante-que-no-sostenia-nadie.md#-55-el-procedimiento-de-despliegue-que-es-el-entregable-de-verdad) y con la frase de arriba ya firmada.

**Prueba de regresión**

```php
// server/tests/CertificateValidityTest.php
/** @test */
public function la_vigencia_es_la_misma_en_cualquier_zona_del_proceso(): void
{
    $answers = [];

    foreach (['UTC', 'America/Bogota', 'Europe/Madrid'] as $timezone) {
        date_default_timezone_set($timezone);
        $answers[] = json_decode($this->call('GET', '/certificates/CERT-2024-0087')->getContent(), true)['status'];
    }

    // Si esta aserción falla, la vigencia depende de dónde corra el proceso —
    // que es exactamente el bug del ticket.
    $this->assertCount(1, array_unique($answers));
}
```

**Prevención**

- **La comprobación de formato en el `smoke.sh`** que faltaba (be03, ejercicio 🧨 y [`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md), ejercicio 8): toda fecha del contrato viaja con offset explícito, en ISO 8601. Sin ella, un cambio de formato de fecha pasa el juez en verde.
- **El TZ fijado explícitamente en el arranque** (`date_default_timezone_set('UTC')` en `bootstrap/app.php`), en vez de heredarlo del entorno. Una zona que viene de una variable del contenedor es configuración que despliega sin pasar por un commit — la misma familia que [`be-06`](#incidente-be-06--el-informe-falla-y-no-hemos-desplegado-nada-).
- Y la de fondo: **guardar zonas, no offsets**, y decidir la regla de negocio antes que el tipo de la columna.

**Por qué llegó a producción**

Porque en Colombia no hay horario de verano. `America/Bogota` es `-05:00` los 365 días, así que un sistema que confunde offset fijo con zona horaria **funciona** — y funciona durante años. El defecto sólo se manifiesta en la franja de cinco horas entre medianoche local y medianoche UTC, con un dato que caiga justo ahí. La mayoría de los certificados vencen a mediodía y nadie vio nunca nada.

**Si tu causa fue distinta a esta**

- *"El PDF usa datos viejos."* Es un bug real y documentado del track base —el PDF se arma desde la vista ([`a08`](a08-pdf-cliente.md) §7)— y encaja con el síntoma. Se descarta comprobando que la fecha del PDF **coincide** con la de la base: no es un dato viejo, es el mismo dato leído distinto.
- *"El reloj del servidor está mal."* Se descarta con `date` en los dos contenedores. Y ojo: si el reloj estuviera mal, **las dos capas dirían lo mismo equivocado**, no cosas distintas. Que difieran es la prueba de que el problema es de interpretación, no de hora.
- *"Falta un `AT TIME ZONE` en la consulta."* Es parte del fix y no es la causa raíz. Si te quedaste ahí, tapaste el síntoma en una capa: el PDF seguiría discrepando, porque se genera en el navegador.

</details>

---

## Incidente be-09 — "Una inspección de 2023 no se puede reimprimir"

> **Fase:** be05 · **Categoría:** Versionado normativo · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-70 min · **Pieza forense:** [`be05` §6](be05-la-invariante-que-no-sostenia-nadie.md#️-6-errores-comunes-y-pieza-forense) — la fila huérfana

### 🎫 El ticket

> *"Auditoría pidió el acta de la inspección 3117, de abril de 2023. Al abrirla sale la pantalla pero sin ítems, y el PDF sale con la primera hoja y nada más. Otras inspecciones del mismo mes sí salen. Necesitamos entregarla el viernes."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** PROD

### 🎯 Qué se te pide

Localizar la causa, **decir cuántas inspecciones más están igual**, y contestar la pregunta que auditoría va a hacer después: *¿qué se puede reconstruir y qué no?* No hay fix de código que devuelva lo que no está.

### 🔧 Preparación

Un dato: el volumen sintético de be05, con las violaciones ya dentro.

```bash
docker compose exec api php database/seeds/volume.php --inspections=4000 --seed=20240915 --violations=88
docker compose exec -T db psql -U postgres certcore < sql/seed-incidente-be-09.sql   # fija la 3117
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

"Sale la pantalla pero sin ítems" no es una pantalla en blanco: la inspección **existe**. Lo que no aparece es lo que la inspección referencia.

Empieza por el dato y no por el render. Y no preguntes por la inspección: pregunta por **lo que la inspección apunta**.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```sql
SELECT id, template_id, template_version, status FROM inspections WHERE id = 3117;
SELECT template_id, version FROM templates WHERE template_id = 'elevator-annual';
```

Compara las dos salidas. Y cuando veas lo que pasa, la pregunta inmediata **no** es cómo arreglarlo: es **cuántas más**.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

La inspección apunta a una versión de plantilla que no existe. Escribe la consulta que encuentra todas las que están igual —un `LEFT JOIN` y un `IS NULL`— y ordénalas por `started_at`. **El rango de fechas que salga es la respuesta a "qué pasó".**

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

```
inspections.id 3117 → template_id 'elevator-annual', template_version 3
templates      → elevator-annual v1, elevator-annual v2
```

**No hay versión 3.** La inspección apunta al vacío, y con ella otras ochenta y siete:

```sql
SELECT count(*) AS violaciones,
       count(*) FILTER (WHERE status IN ('approved','completed')) AS aprobadas,
       min(started_at) AS desde, max(started_at) AS hasta
FROM inspections i
LEFT JOIN templates t
  ON t.template_id = i.template_id AND t.version = i.template_version
WHERE t.template_id IS NULL;
--   88 | 88 | 2023-03-27 | 2023-04-17
```

Ochenta y ocho, **todas aprobadas**, **todas en tres semanas de 2023**. Un rango cerrado no es azar: es un suceso. Alguien publicó una v3 —probablemente por error, o para una norma que se echó atrás—, se ejecutaron inspecciones contra ella durante tres semanas, y después **la v3 se borró**. La base lo permitió porque nadie le había dicho que no podía: `inspections` guarda `template_id` y `template_version` como dos columnas sueltas, **sin clave foránea compuesta** ([`be05` §4](be05-la-invariante-que-no-sostenia-nadie.md#-4-concepto-mínimo)).

Y la parte que responde a *"¿por qué nadie se enteró en tres años?"*: **`resolveTemplateVersion` degrada con elegancia.** Si no encuentra la versión, cae a la vigente y pinta algo. Durante tres años esas ochenta y ocho inspecciones se vieron **perfectas y con la plantilla equivocada**. Lo que rompió el silencio fue el PDF, que no degrada igual.

> 🧠 **Un frontend que degrada con elegancia oculta la corrupción de datos durante años.** Es el mismo código que en la Fase 7 celebraste por robusto. Robusto y silencioso son la misma propiedad vista desde dos sitios, y cuál de las dos es depende de si alguien está mirando la base.

**Parche mínimo**

Aquí no hay parche que devuelva los datos, y proponerlo sería el error grave de este incidente. Lo mínimo honesto es **que el sistema deje de mentir**:

```php
// server/app/Http/Controllers/InspectionController.php
// Si la versión de plantilla con la que se ejecutó la inspección no existe, el
// acta NO se puede reconstruir. Decirlo explícitamente es mejor que devolver
// una lista vacía que parece una inspección sin ítems.
$template = Template::where('template_id', $inspection->template_id)
    ->where('version', $inspection->template_version)
    ->first();

if ($template === null) {
    return response()->json([
        'message' => 'La versión de plantilla con la que se ejecutó esta inspección no está disponible.',
        'templateId' => $inspection->template_id,
        'templateVersion' => $inspection->template_version,
    ], 409);
}
```

Un `409` con un mensaje explícito no arregla nada y **cambia todo**: convierte un dato silenciosamente falso en un error visible, que es lo que auditoría necesita saber.

⚠️ Y ojo con la regla del track: esto **toca el contrato**. El frontend no espera un `409` en ese endpoint. Es una excepción justificada —y hay que justificarla por escrito— porque la alternativa es seguir emitiendo actas con la norma equivocada. Si el equipo decide que no, la alternativa es un campo nuevo en el cuerpo (régimen de crecimiento, be00) y que la pantalla lo ignore hasta que alguien la actualice.

**La refactorización correcta**

La de [`be05`](be05-la-invariante-que-no-sostenia-nadie.md), completa: la **clave foránea compuesta en `NOT VALID`**. No repara las ochenta y ocho —nada las repara— y hace dos cosas que valen más: impide que aparezcan nuevas, y **impide borrar una plantilla que tenga inspecciones**, que es exactamente el suceso que causó esto.

**Prueba de regresión**

```php
// server/tests/OrphanInspectionTest.php
/** @test */
public function no_se_puede_borrar_una_plantilla_con_inspecciones(): void
{
    $this->expectException(\Illuminate\Database\QueryException::class);

    // Éste es el suceso de 2023, reproducido. Con la foránea compuesta puesta,
    // la base lo impide; sin ella, se lleva por delante tres años de actas.
    DB::table('templates')
        ->where('template_id', 'elevator-annual')
        ->where('version', 1)
        ->delete();
}
```

**Prevención**

- **La restricción**, que es la única prevención real.
- **Una auditoría de invariante** que corra a diario y avise si el conteo sube: no impide nada, pero convierte tres años en un día.
- Y la que menos cuesta: **el `smoke.sh` con una comprobación de que el conteo de huérfanas no crece**. Es una línea de `jq` sobre un endpoint de diagnóstico.

**Por qué llegó a producción**

Tres capas fallaron en silencio, y ninguna por descuido de una persona:

1. **La base no tenía la restricción**, porque el ORM de 2016 no sabía declarar claves compuestas y el `id` de plantilla se aplastó en una cadena ([`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md)). Una limitación de herramienta convertida en decisión de arquitectura que nadie tomó.
2. **El backend permitió el borrado**, porque nada se lo impedía.
3. **El frontend degradó con elegancia**, que en su momento fue una buena decisión de robustez.

Cada una es defendible por separado. Juntas, produjeron tres años de actas que dicen algo que no se comprobó. **En una certificadora, eso no es un bug de interfaz.**

**Si tu causa fue distinta a esta**

- *"Los ítems de esa plantilla se borraron del `jsonb`."* Encaja con "sin ítems" y se descarta mirando la plantilla — que ni siquiera existe. Buena hipótesis: apunta a la capa correcta.
- *"El PDF falla por tamaño o por acentos."* Es un problema real y documentado ([`a08`](a08-pdf-cliente.md)), y se descarta porque la pantalla **también** está vacía. Que dos salidas distintas fallen igual apunta al dato, no al render.
- *"Es un problema de permisos sobre esa inspección."* Se descarta con un `SELECT` directo: la fila está y se lee. Descartar autorización antes que datos es un orden defendible; cuesta treinta segundos.

</details>
MDEOF
wc -l cuaderno-incidentes-be.md

# --- 2026-09-12T01:39:09 · Write incidents be-10 and be-11
cat >> cuaderno-incidentes-be.md <<'MDEOF'

---

## Incidente be-10 — "Después del despliegue no puedo actualizar unas inspecciones viejas"

> **Fase:** be05 · **Categoría:** Restricciones · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-40 min · **Pieza forense:** [`be05` §5.3](be05-la-invariante-que-no-sostenia-nadie.md#-53-las-tres-salidas-costeadas) · Apoyo: [`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md)

### 🎫 El ticket

> *"Estamos cerrando el mes y hay que marcar como archivadas unas inspecciones de 2023. El proceso corre y se cae a la mitad. Las de este año sí se archivan. Ayer funcionaba."*

**Reportado por:** analista de operaciones
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar por qué falla **ahora** algo que ayer funcionaba, decidir si es un bug o un comportamiento correcto, y proponer qué hacer con el proceso de cierre de mes. Ojo: la respuesta *"quitar la restricción"* es una de las opciones y hay que evaluarla en serio.

### 🔧 Preparación

Una rama: la del despliegue de ayer, con la restricción recién puesta y el proceso de archivado tal cual.

```bash
git switch -c incidente-be/10 be-fase-05-la-invariante-que-no-sostenia-nadie
docker compose exec api php database/seeds/volume.php --inspections=4000 --seed=20240915 --violations=88
docker compose exec api php artisan certcore:archive --year=2023     # ← míralo caerse
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

*"Ayer funcionaba"* con el mismo código y los mismos datos apunta a un cambio en el medio. Y ayer hubo un despliegue. Empieza por ahí: **qué se desplegó**, no qué hace el proceso.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
docker compose logs api | grep -i "violates\|constraint" | tail -3
```

El error nombra una restricción. Busca cuándo se añadió y con qué modificador, y después **cuenta cuántas de las filas que el proceso quiere tocar la violan**.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

La restricción está `NOT VALID`: no se comprobó contra el histórico. Pero un `UPDATE` sobre una fila vieja **revalida la fila entera**, aunque el `UPDATE` no toque las columnas de la restricción. ¿Cuántas de las inspecciones de 2023 que el proceso intenta archivar son de las ochenta y ocho huérfanas?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

```
SQLSTATE[23503]: Foreign key violation: 7 ERROR:  insert or update on table
"inspections" violates foreign key constraint "inspections_template_fk"
DETAIL:  Key (template_id, template_version)=(elevator-annual, 3) is not present
in table "templates".
```

El despliegue de ayer fue el de [`be05`](be05-la-invariante-que-no-sostenia-nadie.md): la clave foránea compuesta, añadida con `NOT VALID`. Hace exactamente lo que promete —las ochenta y ocho filas históricas se quedaron intactas y nadie las tocó— y tiene un efecto lateral que hay que conocer **antes** de desplegar, no después:

> ⚠️ **Un `UPDATE` sobre una fila vieja que viola la restricción falla, aunque el `UPDATE` no toque las columnas de la restricción.** La fila entera se revalida al modificarse.

El proceso de cierre de mes hace `UPDATE inspections SET status = 'archived' WHERE ...`. No toca `template_id` ni `template_version`. Y falla igual, en las ochenta y ocho filas huérfanas de 2023 — que son justo las del incidente [`be-09`](#incidente-be-09--una-inspección-de-2023-no-se-puede-reimprimir).

**Esto no es un bug: es el comportamiento correcto y documentado**, y el fallo real es de comunicación — nadie lo anunció en el correo de despliegue.

**Parche mínimo**

Que el proceso de archivado **no se caiga a la mitad**, que es lo peor de todo: deja el mes medio cerrado y sin saber dónde se quedó.

```php
// server/app/Console/Commands/ArchiveInspections.php
// Se archiva fila a fila y se cuenta lo que no se pudo. Un proceso de cierre
// de mes tiene que terminar SIEMPRE y decir qué quedó fuera: caerse a la mitad
// es peor que no correr, porque nadie sabe en qué punto se detuvo.
$skipped = [];

foreach ($inspections as $inspection) {
    try {
        DB::table('inspections')->where('id', $inspection->id)->update(['status' => 'archived']);
    } catch (QueryException $exception) {
        $skipped[] = $inspection->id;
    }
}

if ($skipped !== []) {
    $this->warn(sprintf(
        '%d inspecciones no se pudieron archivar (violan inspections_template_fk): %s',
        count($skipped), implode(', ', array_slice($skipped, 0, 10)) . '…'
    ));
}
```

**La refactorización correcta**

Hay **tres** salidas y elegir es el ejercicio:

1. **Excluir las huérfanas del archivado**, con la misma consulta del censo de be05. Es honesto: esas inspecciones están en un estado excepcional y merecen tratamiento excepcional. **Es la recomendación**, porque no cambia la restricción ni los datos.
2. **Decidir qué se hace con las ochenta y ocho** y ejecutarlo. Es la salida definitiva y **no es de ingeniería**: en un dominio regulado, reescribir el histórico lo decide alguien con nombre.
3. **Quitar la restricción.** Devuelve el sistema a antes de ayer, deja pasar el cierre de mes, y **reabre la puerta que causó [`be-09`](#incidente-be-09--una-inspección-de-2023-no-se-puede-reimprimir)**. Hay que evaluarla en serio y descartarla por escrito: la presión de un cierre de mes es exactamente la circunstancia en la que se desactiva una defensa nueva y ya no se vuelve a poner.

**Prueba de regresión**

```php
// server/tests/ArchiveInspectionsTest.php
/** @test */
public function el_archivado_termina_y_reporta_las_que_no_pudo(): void
{
    $orphans = DB::select("
        SELECT i.id FROM inspections i
        LEFT JOIN templates t ON t.template_id = i.template_id AND t.version = i.template_version
        WHERE t.template_id IS NULL AND extract(year from i.started_at) = 2023
    ");

    $exitCode = $this->artisan('certcore:archive --year=2023');

    // Termina bien...
    $this->assertSame(0, $exitCode);
    // ...y no dejó a medias las que sí podía archivar.
    $pending = DB::table('inspections')
        ->whereYear('started_at', 2023)->where('status', '!=', 'archived')->count();

    $this->assertSame(count($orphans), $pending);
}
```

**Prevención**

- **El correo de despliegue.** El paso 6 del procedimiento de [`be05` §5.5](be05-la-invariante-que-no-sostenia-nadie.md#-55-el-procedimiento-de-despliegue-que-es-el-entregable-de-verdad) lo pedía explícitamente: *anunciar los efectos laterales*. Este incidente **existe porque ese paso se saltó**, y es el más barato de los siete.
- **Todo proceso por lotes termina y reporta**, nunca se cae a la mitad.
- Y una comprobación que cuesta cinco minutos antes de cualquier `ALTER`: **¿qué procesos periódicos escriben en esta tabla?** El cierre de mes, un trabajo nocturno, una integración. Ninguno está en el `smoke.sh` y todos se van a encontrar con la restricción nueva.

**Por qué llegó a producción**

Porque el despliegue fue técnicamente impecable y **la comunicación no existió**. La restricción se puso bien, con `NOT VALID`, sin tocar el histórico, con las dos pruebas. Lo que faltó fue una frase en un correo, y el coste de esa frase ausente fue un cierre de mes a medias.

Es el patrón más común de los incidentes que siguen a un cambio correcto: *el cambio estaba bien y nadie lo contó*.

**Si tu causa fue distinta a esta**

- *"El proceso de archivado tiene un bug de fechas."* Encaja con "las de este año sí" y se descarta comparando el año de las que fallan: no es el año, es **qué filas** son. Buena hipótesis y barata de tumbar.
- *"Se quedó un bloqueo de la migración de ayer."* Plausible tras un despliegue y se descarta con `pg_locks` o simplemente reintentando: falla igual, siempre en las mismas filas. Un fallo determinista no es un bloqueo.
- *"Hay que validar la restricción."* Es lo contrario de lo que hay que hacer: `VALIDATE CONSTRAINT` fallaría con las mismas ochenta y ocho filas. Si llegaste aquí, releé qué hace exactamente `NOT VALID` en [`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md).

</details>

---

## Incidente be-11 — "A veces devuelve 500 y a veces 422 con el mismo dato"

> **Fase:** be06 · **Categoría:** Dos caminos vivos · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-40 min · **Pieza forense:** [`be06` §6](be06-la-reescritura-a-medias.md#️-6-errores-comunes-y-pieza-forense)

### 🎫 El ticket

> *"Cuando registro un hallazgo con una severidad que no está en la lista, unas veces sale un error feo de servidor y otras veces sale un mensaje decente diciendo qué está mal. Es el mismo formulario. ¿De qué depende?"*

**Reportado por:** inspector de campo
**Ambiente:** UAT

### 🎯 Qué se te pide

Contestar la pregunta literal del ticket —**¿de qué depende?**— y decidir cuál de los dos comportamientos es el oficial, con el criterio escrito. El fix es lo de menos.

### 🔧 Preparación

Ninguna: el sistema ya está así desde be06.

```bash
git switch be-fase-06-la-reescritura-a-medias
docker compose up -d
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

*"A veces"* casi nunca significa azar: significa **una variable que quien reporta no puede ver**. En el track base esa variable era el caos, la caché o el reloj. Aquí hay una nueva y la aprendiste en be06.

Antes de leer código: manda el mismo cuerpo malo dos veces, por dos sitios distintos.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -sS -o /dev/null -w '%{http_code}\n' -X POST localhost:3000/findings \
     -H 'Content-Type: application/json' -d '{"severity":"catastrofico"}'
curl -sS -o /dev/null -w '%{http_code}\n' -X POST localhost:3000/v2/findings \
     -H 'Content-Type: application/json' -d '{"severity":"catastrofico"}'
```

Dos comandos y ya sabes que no es azar. Ahora la pregunta útil: **¿cuál de las dos rutas llama el frontend?**

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Uno de los dos controladores valida antes de escribir y el otro deja que la base rechace el valor. Mira **en qué capa** se detecta el error en cada caso, y qué clase de excepción llega al manejador cuando lo detecta la base.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Dos caminos vivos para el mismo recurso, con la validación en capas distintas:

```php
// server/routes/web.php — camino viejo (parcela laravel)
$router->post('/findings', function (Request $request) {
    return Finding::create($request->all());     // → QueryException → 500
});

// server/app/Http/Controllers/FindingController.php — camino nuevo (parcela symfony)
public function store(Request $request): JsonResponse
{
    $this->validate($request, ['severity' => 'required|in:critical,major,minor']);
    // → 422 con el detalle
}
```

El mismo dato malo produce un `500` por una puerta y un `422` por la otra. **"A veces" era, en realidad, "según por dónde entres"** — y el inspector que abrió el ticket no tenía forma de saber que había dos puertas, porque el formulario es uno solo y el frontend elige la ruta según la pantalla desde la que se abra.

**Las dos respuestas son defendibles por separado.** Lo que no es defendible es que dependa de la puerta.

**Parche mínimo**

Gana **el que el frontend consume**, y eso se comprueba, no se opina:

```bash
grep -rn "'/findings'\|/v2/findings" src/ | head
```

Si es el viejo, el fix va ahí, escrito en el estilo de esa parcela:

```php
// server/routes/web.php  (parcela laravel)
// Validar antes de escribir: el mismo dominio que la base ya restringe, en la
// capa donde se puede contestar con un mensaje útil. No se cambia el código de
// estado del camino nuevo: se hace que éste diga lo mismo.
$router->post('/findings', function (Request $request) {
    $validator = app('validator')->make($request->all(), [
        'severity' => 'required|in:critical,major,minor',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 422);
    }

    return Finding::create($request->only(['inspection_id', 'item_id', 'severity', 'description']));
});
```

⚠️ **Y aquí hay que parar un segundo**, porque cambiar un `500` por un `422` **cambia el contrato**. Si alguna pantalla dependía del `500` —por ejemplo, mostrando un mensaje genérico de "error del servidor"—, esto la altera. La comprobación es la del ejercicio 🧨 de be06, y la respuesta honesta suele ser *"no puedo saberlo sin pruebas"*. En este caso concreto se puede: el `smoke.sh` no cubre este endpoint y el frontend trata cualquier error con el mismo `ApiError`, así que el cambio es seguro. **Escribir esa comprobación es parte del fix**, no un extra.

**La refactorización correcta**

Decidir cuál de los dos caminos es el oficial —lo pedía la tabla de [`be06` §5.1](be06-la-reescritura-a-medias.md#-51-medir-la-superficie-los-tres-números)— y anotarlo. Borrar el otro **no** es de este incidente: depende del *assessment* de be07, y hacerlo aquí sería resolver un ticket de treinta minutos con una migración.

Y una tercera capa que conviene añadir aunque el frontend valide: el `CHECK` en la columna. Es la 💸 **B7** del [mapa de deuda](bea-10-mapa-de-deuda-del-track-be.md), declarada como aceptada — y este incidente es el argumento más fuerte a favor de pagarla al menos en `severity`.

**Prueba de regresión**

```php
// server/tests/FindingValidationTest.php
/** @test */
public function los_dos_caminos_responden_igual_ante_un_dato_invalido(): void
{
    $payload = ['inspection_id' => 501, 'item_id' => 'ITEM-01', 'severity' => 'catastrofico'];

    $viejo = $this->call('POST', '/findings', $payload)->getStatusCode();
    $nuevo = $this->call('POST', '/v2/findings', $payload)->getStatusCode();

    // No afirma cuál es el correcto: afirma que no depende de la puerta. Es
    // la única aserción honesta mientras los dos caminos sigan vivos.
    $this->assertSame($nuevo, $viejo);
}
```

**Prevención**

- **La tabla de caminos oficiales** de be06, escrita y visible, con una fila por recurso.
- **Una prueba de paridad por recurso** como la de arriba: mientras haya dos caminos, que ninguno pueda divergir en silencio. Es la prueba más rentable de un sistema a medio migrar.
- Y la de fondo: **el dominio de `severity` restringido en la base**, para que la respuesta no dependa de que alguien se acuerde de validar.

**Por qué llegó a producción**

Porque alguien empezó a mover el sistema hacia otra cosa, lo hizo bien, y se fue antes de terminar. El camino nuevo es **mejor** —valida, responde con detalle, es más fácil de probar— y eso es justamente lo que hace que este estado sea el más caro de los tres: no hay un camino malo que borrar, hay dos correctos y nadie decidió cuál.

Es la consecuencia directa de la economía de rotación de [`be02`](be02-estratos-por-procedencia.md): dieciocho meses de permanencia media no alcanzan para terminar una migración, y nadie hereda el contexto de por qué se empezó.

**Si tu causa fue distinta a esta**

- *"El `500` es intermitente por el caos."* Es la hipótesis correcta que va primero en este track, y se descarta comprobando que `CHAOS` está vacío en `/health`. Diez segundos.
- *"Depende del dato, no de la ruta."* Perfectamente razonable, y se descarta mandando **el mismo cuerpo** por las dos. Que el ticket dijera "el mismo formulario" es la pista que lo sugiere y no lo prueba: el formulario es uno, las rutas son dos.
- *"Falta un manejador de excepciones que traduzca `QueryException` a 422."* **Es una solución real y defendible**, y más general que la propuesta. Su problema es que traduce *cualquier* violación de la base en un `422`, incluidas las que sí son errores del servidor — y entonces el `500` desaparece de sitios donde hacía falta. Si elegiste ésta, escribe qué excepciones excluyes.

</details>
MDEOF
wc -l cuaderno-incidentes-be.md

# --- 2026-09-12T01:39:18 · Read retrospective and closing checklist format
sed -n '388,450p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-12T01:40:58 · Write be-12, retrospective and pending items
cat >> cuaderno-incidentes-be.md <<'MDEOF'

---

## Incidente be-12 — "Tenemos un *assessment* que recomienda reescribir en seis meses"

> **Fase:** be07 · **Categoría:** Decisión sin datos · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-80 min · **Pieza forense:** [`be07` §6](be07-el-assessment-de-riesgo.md#️-6-errores-comunes-y-pieza-forense) · Apoyo: [`bea-09`](bea-09-symfony-como-vara-de-medir.md), [`bea-10`](bea-10-mapa-de-deuda-del-track-be.md)

### 🎫 El ticket

> *"La consultora entregó su informe sobre `certcore-api`. Recomienda reescribirlo completo en seis meses, con un equipo de cuatro personas, y dice que el sistema actual es inmantenible. La dirección quiere aprobarlo el martes. ¿Ves algún problema?"*

**Reportado por:** el jefe de tecnología
**Ambiente:** —

### 🎯 Qué se te pide

**Desmontar el documento o respaldarlo**, por escrito y en una página. Con una condición que lo hace difícil: casi todo lo que el informe dice sobre el estado del código **es cierto**, y tú lo sabes mejor que nadie porque lo mediste tú.

Este incidente **no termina en un fix.** Termina en un documento y en una reunión.

### 🔧 Preparación

Ninguna técnica. El informe es esto, y es todo lo que te van a dar:

```
INFORME DE MODERNIZACIÓN — certcore-api
Preparado por: consultora externa · 3 páginas

HALLAZGOS
· Runtime PHP 7.4, sin soporte de seguridad desde noviembre de 2022.
· Framework Lumen 5.8, discontinuado; el fabricante no lo recomienda.
· Sin pruebas automatizadas. Sin CI. Sin documentación de arquitectura.
· Código heterogéneo, con al menos cuatro estilos distintos conviviendo.
· Integridad referencial incompleta en tablas críticas.

DIAGNÓSTICO
El sistema es inmantenible y representa un riesgo operativo inaceptable.

RECOMENDACIÓN
Reescritura completa sobre un stack moderno (PHP 8.3 + Laravel 11).
Plazo estimado: 6 meses. Equipo: 4 personas. Inversión: <cifra>.
Beneficios: mantenibilidad, seguridad, atracción de talento.
```

Ten a mano tus propios entregables: `ESTRATOS.md`, `EVIDENCIA-VERSIONES.md`, `INVARIANTES.md`, `SUPERFICIE.md` y tu `ASSESSMENT.md`.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No empieces por la recomendación: empieza por **separar el informe en dos listas**. A la izquierda, lo que se puede verificar. A la derecha, lo que es un juicio de valor.

Vas a descubrir que la primera lista es casi toda cierta. Eso no debilita tu posición: es lo que la hace creíble.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Coge cada cifra del informe y pregúntale **de dónde sale**. Son tres: seis meses, cuatro personas y la inversión. Ninguna trae fuente.

Y después cuenta cuántas opciones presenta el documento. Un *assessment* con una sola opción real no es un *assessment*.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Falta un dato que **cambia la respuesta entera** y que no aparece ni una vez en las tres páginas. No es técnico, no está en el código, y tú tampoco lo tienes: hay que ir a buscarlo a otra parte de la empresa.

</details>

---

### 📝 Tu investigación

**Reproducción** *(aquí: la lectura crítica, punto por punto)*

**Evidencia observable** *(qué afirma el informe y qué dicen tus mediciones)*

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz** *(qué falla en el documento, no en el sistema)*

**Tu fix** *(la nota de una página que mandas antes del martes)*

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El informe tiene un **diagnóstico correcto y una recomendación sin sustento**, que es la combinación más peligrosa: el diagnóstico correcto le presta credibilidad a lo demás.

**Lo que acierta, y hay que concederlo primero y sin regatear:**

| Afirmación | Tu evidencia |
|---|---|
| Runtime EOL desde noviembre de 2022 | Cierto — [`be01` §4](be01-lumen-y-la-familiaridad-falsa.md#-4-concepto-mínimo) y `R-01` de [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) |
| El fabricante no recomienda Lumen para proyectos nuevos | Cierto, y **hay cita literal** — [`be07` §4](be07-el-assessment-de-riesgo.md#-4-concepto-mínimo) |
| Cuatro estilos conviviendo | Cierto, y **medido archivo por archivo** — `ESTRATOS.md` |
| Integridad referencial incompleta | Cierto — 88 filas huérfanas, `INVARIANTES.md` |
| Sin pruebas | Cierto hasta be06; ahora hay cinco, y **eso también hay que decirlo** |

**Los cinco defectos, en orden de gravedad:**

1. **"Inmantenible" no es un hallazgo: es un adjetivo.** El sistema se mantiene —lleva ocho años en producción emitiendo certificados— y tú acabas de resolver once incidentes en él. Lo que es cierto es que **mantenerlo cuesta más de lo que debería**, y eso sí tiene número: el coste de rotación de [`be02` §5.5](be02-estratos-por-procedencia.md#-55-el-número-que-be07-va-a-necesitar-el-coste-de-rotación). Sustituir el adjetivo por la cifra mejora el informe y **fortalece** su argumento.
2. **Las tres cifras no tienen origen.** Seis meses, cuatro personas, la inversión. Tú tienes el coste medido de cruzar **un** controlador ([`be06`](be06-la-reescritura-a-medias.md), ejercicio 27) y sabes que multiplicarlo es optimista. No hace falta discutir el número: basta con pedir de dónde sale.
3. **No cuenta el estado intermedio.** Seis meses de reescritura son seis meses con **dos sistemas vivos**, que es el estado más caro de los tres ([`be06` §4](be06-la-reescritura-a-medias.md#-4-concepto-mínimo)). Y CertCore ya tiene una reescritura a medias que alguien empezó y no terminó: **es la mejor evidencia disponible de que este riesgo es real aquí, no en abstracto.**
4. **Presenta una sola opción.** Faltan las otras tres: quedarse y formar, estrangular por endpoint, y no hacer nada documentando el riesgo. **Estrangular es probablemente la respuesta correcta** y es la que un informe de tres páginas nunca propone, porque es la aburrida.
5. **Y el defecto que lo invalida entero: no aparece la fecha de decomisión.** Ni una vez.

> 🧭 **La respuesta correcta depende de la fecha de decomisión, no de la calidad del código.** Con dos años de vida por delante, reescribir es tirar el dinero. Con diez, no reescribir es la decisión cara. **El mismo código, la misma consultora, el mismo informe — y dos recomendaciones opuestas.** Un documento que no nombra ese dato no puede recomendar nada.

**Parche mínimo** *(la nota de una página, antes del martes)*

Tres párrafos y una petición:

> **Párrafo 1 — conceder.** El diagnóstico del informe coincide con nuestras propias mediciones, y en varios puntos las nuestras son más precisas: adjuntamos el inventario de estilos, la evidencia de versiones y el censo de integridad. El runtime EOL es un riesgo real, está documentado como `R-01`, y **necesita una decisión**.
>
> **Párrafo 2 — lo que falta.** La recomendación no es evaluable tal como está: las tres cifras no declaran su origen, la estimación no incluye el coste del periodo con dos sistemas vivos —del que ya tenemos precedente en este mismo sistema— y no se comparan alternativas. Adjuntamos las cuatro opciones costeadas con la fuente de cada número.
>
> **Párrafo 3 — el dato que decide.** Nuestra recomendación es condicional a un dato que no está en el informe ni en el código: **cuántos años de vida útil le quedan a CertCore como producto**. Con horizonte menor a dos años recomendamos contener y documentar; entre dos y cinco, estrangular por endpoint; más de cinco, reescribir — y entonces el informe tendría razón en el fondo, aunque no en el plazo.
>
> **La petición:** aplazar la aprobación hasta tener esa fecha. Si no existe, **esa es la decisión que hay que tomar el martes**, no la del presupuesto.

**La refactorización correcta**

Que la empresa tenga la fecha de decomisión de sus sistemas como un dato de gestión y no como una conversación de pasillo. Es de producto, no de ingeniería, y es la única forma de que la próxima decisión de este tipo no dependa de quién escriba el informe más convincente.

**Prueba de regresión**

No hay código, y aun así hay una prueba, que es la del ejercicio 🧨 de [`be07`](be07-el-assessment-de-riesgo.md): **coge tu propio `ASSESSMENT.md` y cámbiale la fecha de decomisión de tres años a diez.** Si no tienes que reescribir varias secciones, tus opciones no eran reales y acabas de cometer el mismo defecto que estás señalando.

**Prevención**

Un criterio de aceptación para cualquier documento de decisión que entre a la empresa, y cabe en cuatro preguntas:

1. ¿Cada cifra dice de dónde sale?
2. ¿Hay al menos tres opciones, y la peor está defendida en su mejor versión?
3. ¿Se cuenta el coste del estado de transición?
4. ¿Se nombra el dato que cambiaría la recomendación?

Un informe que no pasa las cuatro no se rechaza: **se devuelve con las cuatro preguntas**.

**Por qué llegó a la mesa de dirección**

No por mala fe. Por tres razones que se repiten en todas partes:

- **El diagnóstico era correcto**, y un diagnóstico correcto compra credibilidad para lo que viene después.
- **La reescritura es la recomendación más fácil de vender y de entender.** Tiene un antes y un después, un plazo y un presupuesto. "Estrangular por endpoint y medir" no cabe en una diapositiva.
- **Nadie de dentro había escrito el documento alternativo.** Ése es el punto que este track viene a corregir: cuando el único documento sobre la mesa es el de la consultora, la consultora tiene razón por incomparecencia.

**Si tu causa fue distinta a esta**

- *"El informe está bien y hay que reescribir."* **Puede ser la respuesta correcta**, y si la defendiste con la fecha de decomisión y los números de las siete fases, el ejercicio está bien resuelto. Lo que se evalúa no es la conclusión: es si la conclusión depende de un dato o de una preferencia.
- *"Hay que subir a PHP 8 primero y ya después vemos."* Es la trampa de [`be06`](be06-la-reescritura-a-medias.md), ejercicio 29: subir a PHP 8 **es** el trasplante de bootstrap, no un paso previo más barato. Si lo propusiste, comprueba la restricción del `composer.json` y las fechas de Lumen antes de defenderlo.
- *"Hay que pedir una segunda opinión externa."* Razonable en política y evasivo en técnica: la segunda consultora va a tener el mismo problema que la primera —**no tiene la fecha de decomisión**—, y vas a gastar seis semanas en descubrirlo.

</details>

---

## 🪞 Retrospectiva del track

Se llena al terminar los doce, de una sola vez, releyendo tu propio `git log`. No es un formulario: es la media hora que convierte doce incidentes sueltos en un método.

- **Cuántos abriste, cuántos cerraste, cuántos quedaron ⚪.** Y de los cerrados, cuántos terminaron **sin fix de código** — en este cuaderno son tres, y si a ti te salieron menos, mira por qué.
- **Cuántas veces tu causa raíz coincidió con la de referencia**, y en cuáles no. El patrón importa más que el número: si fallaste dos veces en la misma capa, ahí está tu punto ciego.
- **Cuántos minutos pasaste dentro de `git` en `be-06`** antes de cambiar de pregunta. Es la métrica propia de este track y la que más vale fuera de él. Anótala aunque duela.
- **En qué capa te costó más:** ruta, middleware, controlador, modelo, consulta, esquema, motor, o configuración que no es código. Esa última columna no existía en el cuaderno base.
- **Cuántas veces te confundió la procedencia** 🧬: cuántos incidentes perdiste buscando en la parcela equivocada, o escribiendo un fix en un estilo que no era el del archivo.
- **Cuántas veces `grep` no sirvió**, y cuánto tardaste en aceptarlo cada vez. Debería bajar entre `be-01` y `be-11`.
- **Qué pista abriste antes de tiempo y por qué.** Sin culpa: es un dato sobre dónde te falta confianza, no sobre tu disciplina.
- **Tu inventario de "lo que no es código"**, reescrito con lo que aprendiste. Empezó con cinco entradas en `be-06` y debería tener el doble. **Es lo único de este archivo que te sirve en un sistema que no es CertCore** — junto con el `HOTFIX.md` de la Fase 13 del track base, al que conviene añadirle ahora una sección con esa lista.

---

## 📌 Pendientes que salieron de los incidentes

- **[be-01]** El caché de plantillas no tiene invalidación y arreglarlo bien obliga a tocar **la otra parcela**. Es el coste del estado intermedio, medido en un caso concreto. → **Insumo de [`be06`](be06-la-reescritura-a-medias.md)**, y ejemplo para la guía de una página de su ejercicio 24.
- **[be-02]** No existe la página que diga *"aquí los middleware se registran en `bootstrap/app.php` y los facades están apagados"*. Su ausencia costó media tarde. → **La guía de una página de be06**, ejercicio 24.
- **[be-03]**, **[be-04]** El `smoke.sh` no comprueba el **orden** de ninguna colección, y el orden es contrato de facto. Fijarlo es una decisión con dos respuestas defendibles. → **Comprobación en el `smoke.sh`** si se decide que sí; anotado en `CONTRACT.md` en cualquier caso.
- **[be-05]** El `smoke.sh` **sólo lee**: ninguna de sus veinticuatro comprobaciones crea nada, así que pasó en verde sobre un sistema en el que no se podía escribir. → **be06**, junto con las pruebas: al menos una comprobación de escritura por recurso.
- **[be-06]** La versión de la base no es visible en ningún sitio del sistema. Dónde debería vivir la comprobación —`/health`, `smoke.sh` o supervisión— tiene tres respuestas defendibles. → **Ejercicio 🔥 de be04**, decisión de be07.
- **[be-07]** Ningún artefacto de emergencia está ejercitado, y no hay lista de cuáles son. El respaldo era el primero de una lista que no existe. → **be06**, y una sección en el `HOTFIX.md` del track base.
- **[be-08]** La frase que define la vigencia de un certificado **no estaba escrita en ninguna parte**. Sin ella, `TIMESTAMPTZ` sólo haría más precisas dos respuestas contradictorias. → **`INVARIANTES.md`**, firmada, antes de la migración de tipos que be04 costeó.
- **[be-09]** El sistema no tiene forma de avisar de que una inspección apunta a una plantilla inexistente: el frontend degrada con elegancia y lo oculta. → **Auditoría diaria de invariante** (be05, ejercicio 🔥) y una comprobación en el `smoke.sh`.
- **[be-10]** El correo de despliegue no se mandó, y el paso 6 del procedimiento de be05 lo pedía. Es el paso más barato de los siete y el que se salta siempre. → **Plantilla de correo de despliegue** para cambios de esquema, en la guía de be06.
- **[be-11]** El dominio de `severity` no está restringido en la base (💸 **B7** del [mapa de deuda](bea-10-mapa-de-deuda-del-track-be.md), declarada como aceptada). Este incidente es el argumento más fuerte para pagarla al menos en esa columna. → **Revisar B7 en `bea-10`** con este caso como evidencia.
- **[be-12]** La empresa **no tiene fecha de decomisión** de sus sistemas, y sin ese dato ninguna decisión de modernización es evaluable. Es el pendiente más grande del track y no es técnico. → **be07 §7**, la sección *"qué hace falta para decidir"*.

---

> 🏷️ **Cierre del cuaderno.** Cuando los doce estén en 🟢 o ⚪:
>
> ```bash
> git tag -a be-cuaderno-cerrado \
>   -m "Cuaderno BE cerrado: 12 incidentes, N con causa coincidente,
> inventario de 'lo que no es código' actualizado"
> git tag -n99 -l 'inc/be-*'      # ← el cuaderno entero, sin abrir un archivo
> ```
>
> Y una anomalía que vas a ver en esa última salida: **`be-06` tiene un solo tag**, sin par `-roto`/`-fix`. No es un olvido — es el incidente cuyo cambio no era código, y esa irregularidad en el listado es el mejor recordatorio que te dejas a ti mismo. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥.
MDEOF
wc -l cuaderno-incidentes-be.md

# --- 2026-09-12T01:41:12 · Verify notebook anchors
python3 - <<'PY'
import re,unicodedata
s=open('cuaderno-incidentes-be.md').read()
heads=re.findall(r'^## (Incidente be-\d+ .*)$', s, re.M)
def anchor(t):
    t=t.lower()
    t=t.replace('*','').replace('"','').replace(':','').replace('—','').replace('⭐','').replace('·','')
    t=re.sub(r'[^\w\s-]','',t)
    t=re.sub(r'\s+','-',t.strip())
    return '#'+t
links=re.findall(r'\]\((#incidente-be-[^)]*)\)', s)
computed=[anchor(h) for h in heads]
print("headings:",len(heads),"links:",len(set(links)))
for h,c in zip(heads,computed): print(c)
print("---- links en índice ----")
for l in sorted(set(links)): print(l, "OK" if l in computed else "❌")
PY

# --- 2026-09-12T01:41:32 · Recompute anchors GitHub-style
python3 - <<'PY'
import re
s=open('cuaderno-incidentes-be.md').read()
def gh(t):
    t=t.strip().lower()
    t=re.sub(r'[^\w\- ]','',t, flags=re.U)   # quita puntuación y emojis, deja letras/números/_/-/espacio
    return '#'+t.replace(' ','-')
heads=re.findall(r'^## (Incidente be-\d+ .*)$', s, re.M)
computed=[gh(h) for h in heads]
for h,c in zip(heads,computed): print(repr(h[:40]),'->',c)
links=sorted(set(re.findall(r'\]\((#incidente-be-[^)]*)\)', s)))
print('\n--- links ---')
for l in links: print(l, 'OK' if l in computed else '❌')
PY

# --- 2026-09-12T01:41:47 · Fix be-06 anchor and re-verify
python3 - <<'PY'
p='cuaderno-incidentes-be.md'; s=open(p).read()
s=s.replace('## Incidente be-06 — "El informe falla y no hemos desplegado nada" ⭐\n',
            '## Incidente be-06 — "El informe falla y no hemos desplegado nada"\n')
s=s.replace('#incidente-be-06--el-informe-falla-y-no-hemos-desplegado-nada-)',
            '#incidente-be-06--el-informe-falla-y-no-hemos-desplegado-nada)')
open(p,'w').write(s)
PY
python3 - <<'PY'
import re
s=open('cuaderno-incidentes-be.md').read()
def gh(t):
    t=t.strip().lower(); t=re.sub(r'[^\w\- ]','',t,flags=re.U); return '#'+t.replace(' ','-')
heads=[gh(h) for h in re.findall(r'^## (Incidente be-\d+ .*)$', s, re.M)]
bad=[l for l in set(re.findall(r'\]\((#incidente-be-[^)]*)\)', s)) if l not in heads]
print("enlaces rotos:", bad or "ninguno")
print("incidentes:", len(heads))
PY

# --- 2026-09-12T01:44:10 · Write BE incident preparations doc
cat > prompts/preparaciones-de-incidentes-be.md <<'MDEOF'
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
| be-01 | be01 | Rama | `incidente-be/01` |
| be-02 | be01 | Rama | `incidente-be/02` |
| be-03 | be02 | **Ninguna** | El sistema ya está así |
| be-04 | be03 | Siembra | `sql/seed-incidente-be-04.sql` |
| be-05 | be03 | Siembra | `sql/seed-incidente-be-05.sql` |
| be-06 | be04 | **`.env`** + siembra | `POSTGRES_TAG` · `sql/seed-incidente-be-06.sql` |
| be-07 | be04 | Rama | `incidente-be/07` |
| be-08 | be04 | Siembra | `sql/seed-incidente-be-08.sql` |
| be-09 | be05 | Volumen + siembra | `volume.php` · `sql/seed-incidente-be-09.sql` |
| be-10 | be05 | Rama + volumen | `incidente-be/10` · `volume.php` |
| be-11 | be06 | **Ninguna** | El sistema ya está así |
| be-12 | be07 | **Ninguna** | El informe va en el enunciado |

**Cuatro ramas, cinco guiones de siembra, una línea del `.env` y tres sin nada.**
El reparto no es casual y conviene defenderlo: en el track base dieciséis de veinte
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

**De dónde sale:** `be-fase-01-lumen-y-la-familiaridad-falsa`
**Qué se toca:** `server/app/Http/Controllers/LegacyTemplateController.php`
**Parcela:** `laravel` — helpers, *service locator*, sin tipos ni `declare`.

```php
// ANTES (lo que hay en el tag)
public function index()
{
    $rows = Template::active()->get();

    return response()->json(collect($rows)->values());
}

// DESPUÉS (el commit de la rama)
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
del router de Laravel. Fatal al arrancar, así que el contenedor entra en bucle de
reinicio y el estudiante ve *"arranca y se muere solo"*.

**Y el segundo bug, que es el que hace bueno el incidente:** aunque se arregle el
primero, `Log::info()` falla con `Class 'Log' not found` porque los facades están
apagados. **Dos bugs en cinco líneas copiadas, y el primero tapa al segundo.**

⚠️ El middleware `TimingMiddleware` **sí existe** en la rama y está bien escrito.
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
use Illuminate\Support\Facades\DB;

class ArchiveInspections extends Command
{
    protected $signature = 'certcore:archive {--year=}';

    public function handle()
    {
        $year = $this->option('year');

        // Un solo UPDATE masivo. Si una fila falla, falla la sentencia entera y
        // el mes se queda a medias — que es exactamente el síntoma del ticket.
        $updated = DB::table('inspections')
            ->whereYear('started_at', $year)
            ->where('status', '!=', 'archived')
            ->update(['status' => 'archived']);

        $this->info("archivadas: {$updated}");
    }
}
```

**Qué se rompe.** El `UPDATE` no toca `template_id` ni `template_version`, y aun así
**la fila entera se revalida** contra la foránea compuesta `NOT VALID` de be05. Las
88 inspecciones huérfanas de 2023 la violan, así que la sentencia falla completa y
no archiva ninguna.

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

### `sql/seed-incidente-be-04.sql` — el orden alterado

```sql
-- be-04: "Desde el despliegue, las plantillas salen en otro orden".
-- No cambia NINGÚN dato visible: sólo fuerza la reescritura física de una fila,
-- que es lo que reorganiza el montón y cambia el orden de un SELECT sin ORDER BY.
UPDATE templates
   SET valid_from = valid_from
 WHERE template_id = 'boiler-annual';

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
-- Reproduce el estado en que quedó la base tras el sembrador de be03: filas con
-- id explícito y la secuencia sin reajustar.
SELECT setval('inspections_id_seq', 1, false);

-- Comprobación (last_value debe ser 1 y max(id) mucho mayor):
--   SELECT last_value FROM inspections_id_seq;
--   SELECT max(id) FROM inspections;
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

-- Comprobación (debe devolver 3 o más):
--   SELECT count(*) FROM certificates WHERE valid_until < now();
```

> ⚠️ **`ExpiredCertificatesReport.php` tiene que existir en el tag de be04**, con su
> `DB::select()` apoyado en `pg_constraint.consrc`. Es parte del código heredado que
> la fase entrega, no de esta preparación — y por eso `SQL-CRUDO.txt` lo lista desde
> `bea-04`. Si al escribir be04 ese archivo no quedó puesto, este incidente no se
> puede preparar.

### `sql/seed-incidente-be-08.sql` — la fecha en el borde

```sql
-- be-08: "El certificado dice que vence hoy y en el PDF dice ayer".
-- La franja peligrosa es la de cinco horas entre medianoche en Bogotá y
-- medianoche en UTC. Se coloca el vencimiento a las 00:30 de HOY, hora local.
UPDATE certificates
   SET valid_until = (current_date + time '00:30')
 WHERE id = 'CERT-2024-0087';

-- Comprobación: la respuesta a "¿está vigente?" tiene que DIFERIR según la zona.
--   SET TimeZone='UTC';             SELECT valid_until < now() FROM certificates WHERE id='CERT-2024-0087';
--   SET TimeZone='America/Bogota';  SELECT valid_until < now() FROM certificates WHERE id='CERT-2024-0087';
```

⚠️ **Este incidente sólo se reproduce en una franja horaria concreta.** Si el
estudiante lo intenta a las tres de la tarde, las dos respuestas coinciden y no ve
nada. El enunciado lo resuelve pidiendo además que cambie el TZ del contenedor de
PHP; **si se prepara para una sesión con horario fijo, ajústese la hora del `UPDATE`
para que el borde caiga dentro de la sesión**. Es la única preparación de este
cuaderno sensible al reloj y hay que saberlo.

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
sed -i '' 's/^POSTGRES_TAG=.*/POSTGRES_TAG=11.22/' .env
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
que el escalón "de antes" tiene que ser `11.x`. Con `13` el informe ya falla y la
demostración pierde el contraste.

---

## 6. Las tres que no necesitan preparación

**`be-03`** (dos endpoints que divergen) y **`be-11`** (el `500` frente al `422`)
**ya están así en el sistema** desde be02 y be06 respectivamente. No hay nada que
sembrar: la pluralidad de caminos es el estado real del backend que el alumno
construyó, y eso es precisamente lo que los hace buenos incidentes.

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

**`be-08` es sensible al reloj** y es la única. Está anotado en su receta y no tiene
arreglo limpio: el bug que reproduce **es** un bug de franja horaria, y una
preparación que lo hiciera reproducible a cualquier hora estaría reproduciendo otra
cosa.

**`be-09` y `be-10` dependen de la semilla exacta** `--seed=20240915` con
`--violations=88`. El número 88 aparece literalmente en las soluciones de referencia
de las dos y en `be05`. Si alguna vez se cambia el generador, hay que cambiar los
tres sitios — o mejor: no cambiarlo.

**Y la que vale para todo el documento:** una preparación escrita en el estilo
equivocado es una pista falsa. Si el incidente vive en la parcela `laravel`, el
código roto se escribe con helpers y sin `declare(strict_types=1)`; si vive en la
`symfony`, al revés. El estudiante va a usar `ESTRATOS.md` para clasificar el
archivo antes de tocarlo, y **tiene que llegar a la conclusión correcta**.
MDEOF
wc -l prompts/preparaciones-de-incidentes-be.md

# --- 2026-09-12T01:44:37 · Add notebook to README
python3 - <<'PY'
p='README.md'; s=open(p).read()
old = """El encuadre completo —stack con versiones verificadas, las ocho fases, los once
apéndices y los riesgos— está en
[`prompts/propuesta-fases-backend.md`](prompts/propuesta-fases-backend.md), y los
prompts de redacción en `prompts/prompts-backend-fase.md` y
`prompts/prompts-backend-apendice.md`. **Lo único que queda pendiente del track es
`cuaderno-incidentes-be.md`**, con los doce incidentes que las fases reservaron
(`be-01` … `be-12`)."""
new = """### 📓 Cuaderno de incidentes del track

[`cuaderno-incidentes-be.md`](cuaderno-incidentes-be.md) — **12 incidentes, 8
horas**, con IDs propios (`be-01` … `be-12`) que **no se cruzan** con los del
cuaderno base. Doce tickets del otro lado del cable: la respuesta ya no está en
DevTools, está en un log, en un `EXPLAIN`, en una línea del `.env`, o en un `grep`
que **no** encuentra nada.

Dos 🟡, siete 🟠 y tres 🔴 — **no hay 🟢**, y se declara por qué: para llegar aquí
hay que haber hecho diez fases del track base con sus incidentes, así que no queda
ninguno de principiante que dar. Y **tres de los doce no terminan en un fix de
código**: uno se cierra con una frase escrita en `INVARIANTES.md`, otro con un
correo de despliegue que nadie mandó, y el último con una nota de una página que
desmonta un *assessment* ajeno.

El insignia es **`be-06`**, y es el único incidente del repositorio **sin par
`-roto`/`-fix`**: su `git diff` está vacío porque la causa vive en una línea de un
archivo que no es código.

El encuadre completo —stack con versiones verificadas, las ocho fases, los once
apéndices y los riesgos— está en
[`prompts/propuesta-fases-backend.md`](prompts/propuesta-fases-backend.md); los
prompts de redacción en `prompts/prompts-backend-fase.md` y
`prompts/prompts-backend-apendice.md`; y el estado roto de cada incidente —material
de autoría que el estudiante no abre— en
`prompts/preparaciones-de-incidentes-be.md`. **El track está completo.**"""
assert old in s
open(p,'w').write(s.replace(old,new,1))
print('README ok')
PY

# --- 2026-09-12T01:44:57 · Mark notebook written in format doc
python3 - <<'PY'
p='prompts/formato-cuaderno-incidentes.md'; s=open(p).read()
old="""  Cuando el track se escriba, el contenido de esas preparaciones va en un
  `prompts/preparaciones-de-incidentes-be.md` aparte, por la misma razón por la
  que los cuadernos están separados."""
new="""  El contenido de esas preparaciones vive en
  [`preparaciones-de-incidentes-be.md`](preparaciones-de-incidentes-be.md)
  —**escrito el 11/09/2026**—, aparte del documento equivalente del track base por
  la misma razón por la que los cuadernos están separados.

> ✅ **Escrito el 11/09/2026.** `cuaderno-incidentes-be.md` tiene sus doce
> incidentes, con la escala **2 🟡 · 7 🟠 · 3 🔴 y ningún 🟢** —declarada con su
> razón: después de diez fases del track base con sus incidentes no queda ninguno
> de principiante que dar—. De las cuatro formas de preparación se usaron **cuatro
> ramas, cinco guiones de `sql/`, una vez el `.env` y tres veces ninguna**; el flag
> del caos **no se usó**, y también está declarado por qué: el inyector ya se
> ejercita entero en be01 y en los ejercicios de la Fase 3 repetidos contra el
> backend nuevo, así que un incidente de caos sería una repetición.
>
> **Y dos divergencias más respecto de este formato, declaradas en el propio
> cuaderno:** (1) no hay campo *«Ruta forense»* que apunte a un archivo aparte,
> porque el track BE no tiene `forense-be-NN.md` —cada incidente enlaza la **§6 de
> su fase**, que cumple el mismo papel—; y (2) el reparto es **por bloque de
> fases, no por semana**, porque el track es opcional y a ritmo propio, así que
> repartirlo en semanas inventaría un calendario que nadie tiene.
>
> 🪦 **`prompts/plantilla-de-incidente-be.md` no se escribió**, y la propuesta lo
> dejaba abierto *"si el formato diverge"*. No diverge lo suficiente: la plantilla
> de §7 se usó tal cual, y lo propio del track —las cuatro formas de preparación y
> la excepción de `be-06`— ya vive en esta sección."""
assert old in s
open(p,'w').write(s.replace(old,new,1))
print('ok')
PY

# --- 2026-09-12T01:45:05 · Find remaining pending references
grep -n "plantilla-de-incidente-be\|cuaderno-incidentes-be" prompts/propuesta-fases-backend.md prompts/prompts-backend-fase.md prompts/prompts-backend-apendice.md

# --- 2026-09-12T01:45:19 · Update pending references in prompt docs
python3 - <<'PY'
import re
# 1) propuesta §9: marcar la plantilla como no escrita, con razón
p='prompts/propuesta-fases-backend.md'; s=open(p).read()
old="| `prompts/plantilla-de-incidente-be.md` | La plantilla de incidente del track, si el formato diverge del base |"
new="| ~~`prompts/plantilla-de-incidente-be.md`~~ | 🪦 **No se escribió** (11/09/2026): el formato **no diverge** lo suficiente. La plantilla de §7 de `formato-cuaderno-incidentes.md` se usó tal cual, y lo propio del track —las cuatro formas de preparación y la excepción de `be-06`— ya vive en su §🔥 |\n| `prompts/preparaciones-de-incidentes-be.md` | ✅ **Escrito.** El estado roto de cada incidente: cuatro ramas, cinco guiones de `sql/`, la línea del `.env` y las tres sin preparación. Material de autoría; el estudiante no lo abre |"
assert old in s; s=s.replace(old,new,1)
open(p,'w').write(s)

# 2) cierres de los dos archivos de prompts
for p,old,new in [
 ('prompts/prompts-backend-fase.md',
  """2. **`cuaderno-incidentes-be.md`** — los doce incidentes reservados en los prompts
   de arriba (`be-01` … `be-12`), con IDs propios y sin mezclarse con el cuaderno
   base.""",
  """2. ✅ **`cuaderno-incidentes-be.md`** — **escrito el 11/09/2026** con los doce
   incidentes reservados en los prompts de arriba (`be-01` … `be-12`), IDs propios
   y sin mezclarse con el cuaderno base. Su material de autoría —el estado roto de
   cada uno— está en `prompts/preparaciones-de-incidentes-be.md`."""),
 ('prompts/prompts-backend-apendice.md',
  """1. **`cuaderno-incidentes-be.md`** — los doce incidentes reservados en
   `prompts-backend-fase.md` (`be-01` … `be-12`).""",
  """1. ✅ **`cuaderno-incidentes-be.md`** — **escrito el 11/09/2026** con los doce
   incidentes reservados en `prompts-backend-fase.md` (`be-01` … `be-12`), más
   `prompts/preparaciones-de-incidentes-be.md` con su estado roto."""),
]:
    s=open(p).read(); assert old in s, p
    open(p,'w').write(s.replace(old,new,1))
print('ok')
PY

# --- 2026-09-12T01:45:32 · Cross-check incidents and links
echo "=== incidentes declarados por fase vs cuaderno ==="
for f in be0*.md; do printf "%-6s " "$(echo $f|cut -c1-4)"; sed -n '5p' "$f" | grep -o 'be-[0-9][0-9]' | tr '\n' ' '; echo; done
echo "cuaderno:"; grep -o '^## Incidente be-[0-9][0-9]' cuaderno-incidentes-be.md | grep -o 'be-[0-9][0-9]' | tr '\n' ' '; echo
echo; echo "=== enlaces a archivos inexistentes ==="
grep -oh '](\([a-z0-9][^):#]*\.md\)' be0*.md bea-*.md cuaderno-incidentes-be.md README.md | sed 's/](//' | sort -u | while read f; do [ -f "$f" ] || echo "❌ $f"; done
echo "(sin salida = todos existen)"

# --- 2026-09-12T01:45:43 · Verify prompt doc links and list new files
grep -oh '](\([a-z0-9][^):#]*\.md\)' prompts/preparaciones-de-incidentes-be.md | sed 's/](//' | sort -u | while read f; do [ -f "prompts/$f" ] || [ -f "$f" ] || echo "❌ $f"; done
grep -oh '](\.\./[^)#]*\.md' prompts/preparaciones-de-incidentes-be.md prompts/formato-cuaderno-incidentes.md | sed 's/](\.\.\///' | sort -u | while read f; do [ -f "$f" ] || echo "❌ ../$f"; done
echo "(sin salida = ok)"; echo; git -C .. status --short angular-16-legacy-for-backend-devs | tail -25

# --- 2026-09-12T01:46:07 · Mark BE track complete in memory
cd /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory && python3 - <<'PY'
p='tracks-be-angular-decisiones.md'; s=open(p).read()
s=s.replace("description: Tracks BE de los dos cursos de Angular. LabCore (angular-8) COMPLETO. CertCore (angular-16): 8 fases y 11 apéndices escritos el 11/09/2026; solo falta su cuaderno de incidentes.",
"description: Tracks BE de los dos cursos de Angular, LOS DOS COMPLETOS. CertCore (angular-16) se cerró el 11/09/2026: 8 fases, 11 apéndices, cuaderno de 12 incidentes y sus preparaciones.")
s=s.replace("""**CertCore (angular-16), escrito el 11/09/2026:** las ocho fases `be00`–`be07` y
los once apéndices `bea-01`–`bea-11`, en siete tandas (cada fase con los
apéndices que declara). **Falta solo `cuaderno-incidentes-be.md`** con los doce
IDs que las fases reservaron, `be-01` … `be-12`.""",
"""**CertCore (angular-16) está COMPLETO desde el 11/09/2026:** las ocho fases
`be00`–`be07` y los once apéndices `bea-01`–`bea-11` (escritos en siete tandas,
cada fase con los apéndices que declara), más `cuaderno-incidentes-be.md` con sus
doce incidentes y `prompts/preparaciones-de-incidentes-be.md` con el estado roto
de cada uno. **Nada pendiente.**

Del cuaderno de CertCore, cuatro decisiones —tres de ellas divergen del cuaderno
base y están declaradas dentro del propio archivo—: escala **2 🟡 · 7 🟠 · 3 🔴 sin
🟢** (después de diez fases base con sus incidentes no queda ninguno de
principiante); **reparto por bloque de fases, no por semana**, porque el track es
opcional y a ritmo propio; **no hay campo «Ruta forense» a un archivo aparte** —no
existen `forense-be-NN.md`, así que cada incidente enlaza la §6 de su fase—; y
**`plantilla-de-incidente-be.md` no se escribió**, igual que en LabCore y por la
misma razón: el formato no diverge, y lo propio del track vive en la §🔥 de
`formato-cuaderno-incidentes.md`. De las cuatro formas de preparación se usaron
**4 ramas, 5 guiones de `sql/`, 1 vez el `.env` y 3 veces ninguna**; **el flag del
caos no se usó** y está declarado por qué (ya se ejercita entero en be01).
`be-06` es el único incidente del repositorio **sin par `-roto`/`-fix`**.""")
open(p,'w').write(s)
m='MEMORY.md'; t=open(m).read()
t=t.replace("— LabCore (angular-8) completo; CertCore (angular-16) con sus 8 fases y 11 apéndices escritos el 11/09/2026 (falta solo su cuaderno), y las decisiones verificadas de Lumen/PostgreSQL.",
            "— los dos completos; CertCore (angular-16) cerrado el 11/09/2026 con 8 fases, 11 apéndices y su cuaderno de 12 incidentes, y las decisiones verificadas de Lumen/PostgreSQL.")
open(m,'w').write(t)
print('ok')
PY

# --- 2026-09-12T02:12:05 · Run the course's forensic verification script
cd angular-16-legacy-for-backend-devs && python3 prompts/verificar-forenses.py 2>&1 | tail -30

# --- 2026-09-12T02:12:19 · Verify exercise counts across all course files
python3 - <<'PY'
import re,glob,os
def last_num(path, start=r'^## 🧪'):
    s=open(path).read()
    m=re.search(start+r'.*?\((\d+)\)', s, re.M)
    declared=int(m.group(1)) if m else None
    body=s.split('## 🧪',1)[-1]
    body=re.split(r'^## 📚|^## 🏷|^---\n\n> 🏷', body, flags=re.M)[0]
    nums=[int(x) for x in re.findall(r'^(\d+)\.', body, re.M)]
    return declared, (max(nums) if nums else None), len(set(nums))
print(f"{'archivo':<46}{'declara':>8}{'último':>8}{'únicos':>8}  estado")
bad=[]
for f in sorted(glob.glob('[0-9][0-9]-*.md')+glob.glob('a[0-9][0-9]-*.md')+glob.glob('be0*.md')+glob.glob('bea-*.md')):
    d,l,u=last_num(f)
    ok = d is not None and d==l==u
    if not ok: bad.append(f)
    print(f"{f:<46}{str(d):>8}{str(l):>8}{str(u):>8}  {'OK' if ok else '⚠️'}")
print("\nCon problema:", bad or "ninguno")
PY

# --- 2026-09-12T02:12:35 · Check exercise and hour totals against README claims
python3 - <<'PY'
import re,glob
def n(f):
    m=re.search(r'^## 🧪.*?\((\d+)\)', open(f).read(), re.M); return int(m.group(1)) if m else 0
base=[f for f in sorted(glob.glob('[0-9][0-9]-*.md')) if not f.startswith('00-conv') and not f.startswith('00-hist')]
oblig=[f for f in base if not f.startswith('14-')]
ap=sorted(glob.glob('a[0-9][0-9]-*.md'))
be=sorted(glob.glob('be0*.md')); bea=sorted(glob.glob('bea-*.md'))
print("obligatorias (14):", sum(map(n,oblig)), "· README dice 410")
print("fase 14:", sum(map(n,[f for f in base if f.startswith('14-')])), "· README dice 15")
print("apéndices base (13):", sum(map(n,ap)), "· README dice 93")
print("fases BE (8):", sum(map(n,be)))
print("apéndices BE (11):", sum(map(n,bea)))
# horas
def horas(f):
    m=re.search(r'\*\*(\d+(?:[.,]\d+)?) horas?\*\*', open(f).read())
    return float(m.group(1).replace(',','.')) if m else None
print("\nhoras fases base:", sum(h for f in oblig if (h:=horas(f))), "· README dice 108")
print("horas apéndices base:", sum(h for f in ap if (h:=horas(f))), "· README dice 33")
print("horas fases BE:", sum(h for f in be if (h:=horas(f))), "· propuesta dice 72")
print("horas apéndices BE:", sum(h for f in bea if (h:=horas(f))))
PY

# --- 2026-09-12T02:12:52 · Check template compliance, naming leftovers, and Spanish variant
echo "=== plantilla de 9 secciones (fases base + BE) ==="
for f in [0-9][0-9]-*.md be0*.md; do
  case "$f" in 00-conv*|00-hist*) continue;; esac
  miss=""
  for s in "1\. Propósito" "2\. Qué queda listo" "3\. Qué NO entra" "4\. Concepto mínimo" "5\." "6\. Errores comunes" "7\. Ejercicios" "8\. Referencias" "9\. Cierre" "📌 Pendientes"; do
    grep -qE "^## .*$s" "$f" || miss="$miss [$s]"
  done
  grep -q "🏷️" "$f" || miss="$miss [tag]"
  grep -q "La señal de que quedó bien" "$f" || miss="$miss [señal]"
  [ -n "$miss" ] && echo "⚠️ $f$miss"
done
echo "(sin salida = todas completas)"
echo
echo "=== restos del nombre viejo be-a-NN- ==="
grep -rn "be-a-[0-9]" --include="*.md" . | head -5 || true
echo "(sin salida = ok)"
echo
echo "=== términos de España / voseo ==="
grep -rniE "\bordenador|\bvale\b|vosotros|\bcoged|\btenés\b|\bpodés\b|\bsos\b" --include="*.md" . | grep -v "equivale\|válido\|valen\|valor" | head -10
echo "(sin salida = ok)"

# --- 2026-09-12T02:13:09 · Validate all internal links and anchors
python3 - <<'PY'
import re,glob,os
files=sorted(glob.glob('*.md')+glob.glob('prompts/*.md'))
broken=[]
for f in files:
    base=os.path.dirname(f)
    for target,anchor in re.findall(r'\]\(([^)#\s]+\.md)(#[^)\s]*)?\)', open(f).read()):
        if target.startswith('http'): continue
        p=os.path.normpath(os.path.join(base,target))
        if not os.path.exists(p): broken.append((f,target))
print("Enlaces a archivos inexistentes:", len(broken))
for b in broken[:20]: print("  ❌",b[0],"->",b[1])

# anclas internas dentro del mismo archivo
def slug(t):
    t=t.strip().lower(); t=re.sub(r'[^\w\- ]','',t,flags=re.U); return '#'+t.replace(' ','-')
badanchor=[]
for f in files:
    s=open(f).read()
    heads={slug(h) for h in re.findall(r'^#{1,6} (.+)$', s, re.M)}
    for a in re.findall(r'\]\((#[^)\s]+)\)', s):
        if a not in heads: badanchor.append((f,a))
print("\nAnclas internas rotas:", len(badanchor))
for b in badanchor[:25]: print("  ❌",b[0],b[1])
PY

# --- 2026-09-12T02:13:46 · Re-validate anchors with an accurate GitHub slugger
python3 - <<'PY'
import re,glob,os
# github-slugger: minúsculas, elimina este conjunto de puntuación (NO el guion),
# y espacios -> guiones. El selector de variación U+FE0F NO se elimina.
PUNCT = re.compile('['
  ' -'      # control
  '!-,'      # ! " # $ % & ' ( ) * + ,     (el guion 0x2D queda fuera)
  './'       # . /
  ':-@'      # : ; < = > ? @
  '[-^'      # [ \ ] ^
  '`'             # `
  '{-~'      # { | } ~
  ']')
def slug(t):
    t = t.strip().lower()
    t = PUNCT.sub('', t)
    return '#' + t.replace(' ', '-')

files = sorted(glob.glob('*.md') + glob.glob('prompts/*.md'))
bad = []
for f in files:
    s = open(f).read()
    heads = {}
    for h in re.findall(r'^#{1,6} (.+?)\s*$', s, re.M):
        a = slug(h)
        heads[a] = heads.get(a, 0) + 1
    for a in re.findall(r'\]\((#[^)\s]+)\)', s):
        if a not in heads:
            bad.append((f, a))
    dup = [k for k, v in heads.items() if v > 1]
    if dup: print(f"  ⚠️ anclas duplicadas en {f}: {dup[:3]}")
print("Anclas internas rotas:", len(bad))
for f, a in bad: print("  ❌", f, a)
PY

# --- 2026-09-12T02:13:58 · Run accurate anchor validation
cat > /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/scratchpad/slug.py <<'PY'
import re, glob, os, sys
# github-slugger: minusculas, elimina puntuacion (el guion NO), espacios -> guiones.
# U+FE0F (selector de variacion) NO se elimina: por eso "## <warn> Advertencias"
# produce un ancla que empieza por el selector.
ranges = [(0x00,0x1F),(0x21,0x2C),(0x2E,0x2F),(0x3A,0x40),(0x5B,0x5E),(0x60,0x60),(0x7B,0x7E)]
def strip_punct(t):
    return ''.join(c for c in t if not any(a <= ord(c) <= b for a,b in ranges))
def slug(t):
    return '#' + strip_punct(t.strip().lower()).replace(' ', '-')

files = sorted(glob.glob('*.md') + glob.glob('prompts/*.md'))
bad = []
for f in files:
    s = open(f).read()
    heads = {}
    for h in re.findall(r'^#{1,6} (.+?)\s*$', s, re.M):
        a = slug(h); heads[a] = heads.get(a, 0) + 1
    for a in re.findall(r'\]\((#[^)\s]+)\)', s):
        if a not in heads: bad.append((f, a))
    dup = [k for k, v in heads.items() if v > 1]
    if dup: print("  dup en", f, dup[:3])
print("Anclas internas rotas:", len(bad))
for f, a in bad: print("  X", f, a)
PY
python3 /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/scratchpad/slug.py

# --- 2026-09-12T02:14:39 · Validate anchors with a Unicode-accurate slugger
cat > /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/scratchpad/slug2.py <<'PY'
import re, glob, unicodedata
def keep(c):
    if c.isalnum() or c == ' ' or c == '-':
        return True
    return unicodedata.category(c) == 'Mn'      # conserva el selector de variacion
def slug(t):
    return '#' + ''.join(c for c in t.strip().lower() if keep(c)).replace(' ', '-')

files = sorted(glob.glob('*.md') + glob.glob('prompts/*.md'))
bad = []
for f in files:
    s = open(f).read()
    heads = set()
    for h in re.findall(r'^#{1,6} (.+?)\s*$', s, re.M):
        heads.add(slug(h))
    for a in set(re.findall(r'\]\((#[^)\s]+)\)', s)):
        if a not in heads:
            bad.append((f, a))
print("Anclas internas rotas:", len(bad))
for f, a in bad:
    print("  X", f, a)
PY
python3 /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/scratchpad/slug2.py

# --- 2026-09-12T02:14:54 · Re-run anchor check keeping underscores
cd /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/scratchpad && sed -i '' "s/c == ' ' or c == '-'/c in ' -_'/" slug2.py && cd - >/dev/null && python3 /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/scratchpad/slug2.py

# --- 2026-09-12T02:15:04 · Fix broken anchor and re-verify
python3 - <<'PY'
p='bea-03-el-contenedor-los-facades-y-por-que-grep-falla.md'; s=open(p).read()
s=s.replace('](#appwithfacades-apagado-por-defecto)','](#app-withfacades-apagado-por-defecto)')
open(p,'w').write(s)
PY
python3 /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/scratchpad/slug2.py

# --- 2026-09-12T02:15:20 · Validate cross-file anchors
cat > /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/scratchpad/xanchor.py <<'PY'
import re, glob, os, unicodedata
def keep(c): return c.isalnum() or c in ' -_' or unicodedata.category(c)=='Mn'
def slug(t): return '#'+''.join(c for c in t.strip().lower() if keep(c)).replace(' ','-')
def heads(path):
    return {slug(h) for h in re.findall(r'^#{1,6} (.+?)\s*$', open(path).read(), re.M)}
cache={}
bad=[]
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    d=os.path.dirname(f)
    for tgt,anc in re.findall(r'\]\(([^)#\s]+\.md)(#[^)\s]+)\)', open(f).read()):
        p=os.path.normpath(os.path.join(d,tgt))
        if not os.path.exists(p): bad.append((f,tgt+anc,'archivo')); continue
        if p not in cache: cache[p]=heads(p)
        if anc not in cache[p]: bad.append((f,tgt+anc,'ancla'))
print("Anclas entre archivos rotas:", len(bad))
for f,a,k in bad: print("  X",f,"->",a,f"({k})")
PY
python3 /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/scratchpad/xanchor.py

# --- 2026-09-12T02:15:39 · Fix cross-file anchors in BE notebook
python3 - <<'PY'
import re, unicodedata, os
def keep(c): return c.isalnum() or c in ' -_' or unicodedata.category(c)=='Mn'
def slug(t): return '#'+''.join(c for c in t.strip().lower() if keep(c)).replace(' ','-')
p='cuaderno-incidentes-be.md'; s=open(p).read()
cache={}
def heads(f):
    if f not in cache: cache[f]={slug(h) for h in re.findall(r'^#{1,6} (.+?)\s*$', open(f).read(), re.M)}
    return cache[f]
fixed=0
for tgt,anc in set(re.findall(r'\]\(([^)#\s]+\.md)(#[^)\s]+)\)', s)):
    if not os.path.exists(tgt) or anc in heads(tgt): continue
    cand = '#'+anc[2:] if anc.startswith('#-') else None
    if cand and cand in heads(tgt):
        s=s.replace(f']({tgt}{anc})', f']({tgt}{cand})'); fixed+=1
    else:
        print("sin candidato:", tgt, anc)
open(p,'w').write(s); print("corregidos:", fixed)
PY
python3 /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/scratchpad/xanchor.py

# --- 2026-09-12T02:15:56 · Check forensic-notebook bidirectional references
python3 - <<'PY'
import re,glob
# 1) Cada pieza forense declara qué incidentes usan su ruta
claims={}
for f in sorted(glob.glob('forense-fase-*.md')):
    s=open(f).read()
    m=re.search(r'Incidentes del cuaderno que usan esta ruta(.{0,600})', s, re.S)
    ids=set(re.findall(r'\b(?:incidente[s]?\s*)?(\d{2})\b', m.group(1))) if m else set()
    claims[f]=(m is not None, ids)
    if not m: print("⚠️ sin sección de incidentes:", f)
# 2) Cada incidente del cuaderno declara su ruta forense
s=open('cuaderno-incidentes.md').read()
inc={}
for blk in re.split(r'^## Incidente ', s, flags=re.M)[1:]:
    nid=blk[:2]
    rutas=set(re.findall(r'forense-fase-(\d{2})\.md', blk[:600]))
    inc[nid]=rutas
print(f"\nIncidentes en el cuaderno base: {len(inc)}")
sin=[k for k,v in inc.items() if not v]
print("Incidentes sin ruta forense declarada:", sin or "ninguno")
# 3) reciprocidad
prob=[]
for nid,rutas in inc.items():
    for r in rutas:
        f=f'forense-fase-{r}.md'
        if f in claims and nid not in claims[f][1]:
            prob.append(f"incidente {nid} enlaza {f} pero la pieza no lo reclama")
for f,(ok,ids) in claims.items():
    r=f[13:15]
    for nid in ids:
        if nid in inc and r not in inc[nid]:
            prob.append(f"{f} reclama el incidente {nid} pero el incidente no la enlaza")
print("\nProblemas de reciprocidad:", len(prob))
for x in prob: print("  ❌",x)
PY

# --- 2026-09-12T02:16:07 · Inspect the incident-claim sections
for f in forense-fase-00.md forense-fase-14.md forense-fase-06.md; do echo "===== $f"; grep -A 8 "Incidentes del cuaderno que usan esta ruta" "$f"; done

# --- 2026-09-12T02:16:26 · Recheck reciprocity with precise extraction
python3 - <<'PY'
import re,glob
claims={}
for f in sorted(glob.glob('forense-fase-*.md')):
    s=open(f).read()
    m=re.search(r'\*\*Incidentes del cuaderno que usan esta ruta:\*\*(.*)', s)
    if not m: print("⚠️ sin sección:", f); continue
    line=m.group(1)
    line=re.sub(r'forense-fase-\d{2}\.md','',line)     # nombres de archivo
    line=re.sub(r'\bA\d{2}\b|§\s*\d+','',line)          # apéndices y secciones
    line=re.sub(r'\bFase \d+\b','',line, flags=re.I)
    ids=set(re.findall(r'\b(\d{2})\b', line))
    claims[f]=ids
s=open('cuaderno-incidentes.md').read()
inc={}
for blk in re.split(r'^## Incidente ', s, flags=re.M)[1:]:
    nid=blk[:2]
    head=blk.split('### 🎫',1)[0]
    inc[nid]=set(re.findall(r'forense-fase-(\d{2})\.md', head))
prob=[]
for nid,rutas in inc.items():
    for r in rutas:
        f=f'forense-fase-{r}.md'
        if nid not in claims.get(f,set()): prob.append(f"incidente {nid} → {f}: la pieza NO lo reclama")
for f,ids in claims.items():
    r=f[13:15]
    for nid in ids:
        if r not in inc.get(nid,set()): prob.append(f"{f} reclama {nid}: el incidente NO la enlaza")
print("Reciprocidad — problemas:", len(prob))
for x in sorted(prob): print("  ❌",x)
print("\nReclamos por pieza:")
for f in sorted(claims): print(f"  {f}: {sorted(claims[f]) or '—'}")
PY

# --- 2026-09-12T02:16:45 · Inspect incident 03 header
awk '/^## Incidente 03 /,/^### 🎫/' cuaderno-incidentes.md | head -8; echo "=== y el 07, que sí lleva dos ==="; awk '/^## Incidente 07 /,/^### 🎫/' cuaderno-incidentes.md | head -6

# --- 2026-09-12T02:17:00 · Fix incident 03 reciprocity and re-verify
python3 - <<'PY'
p='cuaderno-incidentes.md'; s=open(p).read()
old="**Tiempo sugerido:** 30-40 min · **Ruta forense:** [`forense-fase-02.md`](forense-fase-02.md)\n\n### 🎫 El ticket\n\n> *\"Entro"
new="**Tiempo sugerido:** 30-40 min · **Ruta forense:** [`forense-fase-02.md`](forense-fase-02.md) y [`forense-fase-00.md`](forense-fase-00.md)\n\n### 🎫 El ticket\n\n> *\"Entro"
assert s.count(old)==1
open(p,'w').write(s.replace(old,new,1)); print('ok')
PY
python3 - <<'PY'
import re,glob
claims={}
for f in sorted(glob.glob('forense-fase-*.md')):
    m=re.search(r'\*\*Incidentes del cuaderno que usan esta ruta:\*\*(.*)', open(f).read())
    line=m.group(1) if m else ''
    if 'ninguno' in line.lower(): claims[f]=set(); continue
    line=re.sub(r'forense-fase-\d{2}\.md|\bA\d{2}\b|§\s*\d+','',line)
    claims[f]=set(re.findall(r'\b(\d{2})\b', line))
inc={}
for blk in re.split(r'^## Incidente ', open('cuaderno-incidentes.md').read(), flags=re.M)[1:]:
    inc[blk[:2]]=set(re.findall(r'forense-fase-(\d{2})\.md', blk.split('### 🎫',1)[0]))
prob=[f"incidente {n} → forense-fase-{r}.md no lo reclama" for n,rs in inc.items() for r in rs if n not in claims.get(f'forense-fase-{r}.md',set())]
prob+=[f"forense-fase-{f[13:15]}.md reclama {n} sin reciprocidad" for f,ids in claims.items() for n in ids if f[13:15] not in inc.get(n,set())]
print("Reciprocidad forense ↔ cuaderno:", prob or "0 problemas")
PY

# --- 2026-09-12T02:17:11 · Inspect fase-07 claim line
grep -A2 "Incidentes del cuaderno que usan esta ruta" forense-fase-07.md

# --- 2026-09-12T02:17:34 · Check reciprocity, debt destinations, doc links and sibling-course mentions
python3 - <<'PY'
import re,glob
def claims(f):
    m=re.search(r'\*\*Incidentes del cuaderno que usan esta ruta:\*\*(.*)', open(f).read())
    if not m: return None
    line=m.group(1)
    if re.match(r'\s*ninguno directamente', line.strip(), re.I): return set()
    line=re.sub(r'forense-fase-\d{2}\.md|\bA\d{2}\b|§\s*\d+','',line)
    return set(re.findall(r'\b(\d{2})\b', line))
C={f:claims(f) for f in sorted(glob.glob('forense-fase-*.md'))}
inc={}
for blk in re.split(r'^## Incidente ', open('cuaderno-incidentes.md').read(), flags=re.M)[1:]:
    inc[blk[:2]]=set(re.findall(r'forense-fase-(\d{2})\.md', blk.split('### 🎫',1)[0]))
prob=[f"inc {n} → f-{r} sin reclamo" for n,rs in inc.items() for r in rs if n not in (C.get(f'forense-fase-{r}.md') or set())]
prob+=[f"f-{f[13:15]} reclama {n} sin vuelta" for f,ids in C.items() if ids for n in ids if f[13:15] not in inc.get(n,set())]
print("1) Reciprocidad forense ↔ cuaderno:", prob or "✅ 0 problemas")
PY
echo
echo "2) 💸 sin destino de cobro (fases base + BE):"
for f in [0-9][0-9]-*.md be0*.md; do
  n=$(grep -c "💸 DEUDA TÉCNICA INTENCIONAL" "$f" 2>/dev/null || echo 0)
  d=$(grep -cE "SE PAGA EN|NO SE PAGA|se paga en" "$f" 2>/dev/null || echo 0)
  [ "$n" -gt 0 ] && [ "$d" -eq 0 ] && echo "  ❌ $f: $n deudas, 0 destinos"
done
echo "  (sin salida = todas declaran dónde se pagan)"
echo
echo "3) Enlaces a angular.dev sin advertencia (la guía exige v16.angular.io):"
grep -ln "angular\.dev" *.md | while read f; do grep -q "angular.dev" "$f" && grep -qiE "advert|ojo|⚠️" "$f" || echo "  ❌ $f"; done
echo "  (sin salida = ok)"
echo
echo "4) Menciones a LabCore fuera de a10 y README:"
grep -ln "LabCore" *.md | grep -v "^a10-\|^README"
echo "  (sin salida = ok)"

# --- 2026-09-12T02:17:47 · Verify every debt block declares where it is paid
python3 - <<'PY'
import re,glob
print("Deudas 💸 y su destino declarado")
tot=0; bad=[]
for f in sorted(glob.glob('[0-9][0-9]-*.md')+glob.glob('be0*.md')):
    s=open(f).read()
    blocks=re.findall(r'💸 DEUDA TÉCNICA INTENCIONAL.*?(?=```)', s, re.S)
    for b in blocks:
        tot+=1
        if not re.search(r'SE PAGA EN|NO SE PAGA|se paga en|Se paga en', b):
            bad.append((f,b.splitlines()[0][:70]))
print(f"  bloques 💸 encontrados: {tot}")
print("  sin destino:", bad or "✅ ninguno")
# marcas 💸 sueltas fuera de bloque
sueltas=[(f,l.strip()[:90]) for f in sorted(glob.glob('[0-9][0-9]-*.md')+glob.glob('be0*.md'))
         for l in open(f) if '💸' in l and 'DEUDA TÉCNICA' not in l and 'SE PAGA' not in l]
print(f"\n  menciones 💸 en prosa (referencias cruzadas, no bloques): {len(sueltas)}")
PY

# --- 2026-09-12T02:17:56 · Inspect the debt block flagged in phase 8
grep -n -A 12 "💸 DEUDA TÉCNICA INTENCIONAL" 08-formulario-dinamico.md | head -60

# --- 2026-09-12T02:18:14 · Check README coverage and incident reservations
python3 - <<'PY'
import re,glob,os
R=open('README.md').read()
# 1) archivos enlazados desde el README vs archivos reales del curso
linked={t for t in re.findall(r'\]\(([a-z0-9][^)#\s]*\.md)\)', R)}
real={f for f in glob.glob('*.md')} - {'README.md'}
print("1) README ↔ archivos")
print("   enlazados que no existen:", sorted(linked-real) or "✅ ninguno")
print("   archivos del curso no enlazados en el README:", sorted(real-linked) or "✅ ninguno")

# 2) reservas de incidentes en las fases base vs cuaderno
res=set()
for f in sorted(glob.glob('[0-9][0-9]-*.md')):
    s=open(f).read()
    tail=s.split('Reservas para el cuaderno de incidentes')[-1]
    res |= set(re.findall(r'^\|\s*\**(\d{2})\**\s*\|', tail, re.M))
cua={b[:2] for b in re.split(r'^## Incidente ', open('cuaderno-incidentes.md').read(), flags=re.M)[1:]}
print("\n2) Reservas de las fases ↔ cuaderno base")
print("   reservados sin entrada:", sorted(res-cua) or "✅ ninguno")
print("   en el cuaderno sin reserva:", sorted(cua-res) or "✅ ninguno")
print("   total incidentes:", len(cua))
PY

# --- 2026-09-12T02:18:32 · Check version pin consistency across the course
python3 - <<'PY'
import re,glob,collections
pins={
 'Angular': r'\b16\.2\.12\b', 'TypeScript': r'\b5\.1\.6\b', 'RxJS': r'\b7\.8\.1\b',
 'Material/CDK': r'\b16\.2\.14\b', 'zone.js': r'\b0\.13\.3\b', 'Node': r'\b18\.18\.2\b',
 'npm': r'\b9\.8\.1\b', 'jsPDF': r'\b2\.5\.1\b', 'json-server': r'\b0\.17\.4\b',
 'PHP': r'\b7\.4\.33\b', 'Lumen': r'\b5\.8\.13\b', 'Postgres': r'\b16\.9\b',
}
files=glob.glob('*.md')
print("Versiones fijadas — apariciones y contradicciones evidentes:")
for name,rx in pins.items():
    n=sum(len(re.findall(rx, open(f).read())) for f in files)
    print(f"  {name:<14} {n:>4} apariciones")
# buscar versiones de Angular distintas de 16.2.12 escritas como x.y.z
alt=collections.Counter()
for f in files:
    for m in re.findall(r'[Aa]ngular\s+(\d+\.\d+\.\d+)', open(f).read()):
        if m!='16.2.12': alt[m]+=1
print("\n  Otras versiones de Angular con patch citadas:", dict(alt) or "✅ ninguna")
# TS / rxjs alternativas
for label,rx,good in [('TypeScript',r'TypeScript\s+(\d+\.\d+\.\d+)','5.1.6'),
                      ('RxJS',r'RxJS\s+(\d+\.\d+\.\d+)','7.8.1'),
                      ('Node',r'Node\s+(\d+\.\d+\.\d+)','18.18.2'),
                      ('Lumen',r'Lumen\s+(\d+\.\d+\.\d+)','5.8.13')]:
    c=collections.Counter(m for f in files for m in re.findall(rx, open(f).read()) if m!=good)
    print(f"  Otras de {label}:", dict(c) or "✅ ninguna")
PY

# --- 2026-09-12T02:18:44 · Inspect off-pin version mentions
grep -rn "18\.19\.0" *.md | head; echo ---; grep -rn "3\.5\.3\|6\.5\.5\|8\.2\.14" *.md | cut -c1-120

# --- 2026-09-12T02:18:57 · Check Dockerfile pin and BE tag naming
echo "=== Fase 13: imagen base del Dockerfile (la 🪦 de la Fase 0 exigía 18.18.2) ==="
grep -n "node:18" 13-build-despliegue.md 14-casi-prod-kind.md a09-docker-kubernetes.md a12-arm64-m1.md 2>/dev/null | cut -c1-110
echo
echo "=== tags BE: el bloque 🏷️ usa be-fase-NN + slug del archivo ==="
for f in be0*.md; do
  slug="be-fase-${f#be}"; slug="be-fase-$(echo "$f" | sed 's/^be\([0-9][0-9]\)-\(.*\)\.md$/\1-\2/')"
  if grep -q "git tag -a $slug" "$f"; then echo "  OK  $f → $slug"; else echo "  ❌ $f: esperado '$slug'"; grep -o "git tag -a [a-z0-9-]*" "$f" | head -1; fi
done

# --- 2026-09-12T02:19:13 · Measure diagnostic exercise ratio per phase
python3 - <<'PY'
import re,glob
print("Ejercicios de diagnóstico (la guía pide ≥ 1/3)")
bad=[]
for f in sorted(glob.glob('[0-9][0-9]-*.md')+glob.glob('be0*.md')):
    s=open(f).read()
    m=re.search(r'^## 🧪.*?\((\d+)\)', s, re.M)
    if not m: continue
    tot=int(m.group(1))
    body=s.split('## 🧪',1)[1].split('## 📚',1)[0]
    diag=len(re.findall(r'^\d+\.\s*\*\*Diagnóstico', body, re.M))
    ratio=diag/tot
    flag='' if ratio>=1/3 else '  ⚠️ por debajo de 1/3'
    if flag: bad.append(f)
    print(f"  {f:<46} {diag:>3}/{tot:<3} = {ratio:.0%}{flag}")
print("\nPor debajo del tercio:", bad or "✅ ninguna")
PY

# --- 2026-09-12T02:19:26 · Check whether phase 14 declares its exercise regime divergence
grep -n "15\|🔥" 14-casi-prod-kind.md | grep -iE "ejercicio|opcional|sin horas|no cuenta|régimen|regimen" | head -8; echo ---; sed -n '/^## 🧪 7\. Ejercicios/,/^\*\*🟢/p' 14-casi-prod-kind.md | head -12

# --- 2026-09-12T02:19:45 · Final checks on tags, style exercises and preparation forms
python3 - <<'PY'
import re,glob
print("1) Tags de las fases base")
bad=[]
for f in sorted(glob.glob('[0-9][0-9]-*.md')):
    if f.startswith(('00-conv','00-hist')): continue
    nn=f[:2]
    if f"git tag -a fase-{nn}" not in open(f).read(): bad.append(f)
print("   sin tag correcto:", bad or "✅ ninguna")

print("\n2) Ejercicios de estilo 🧬 (la guía pide ≥2 desde la Fase 5)")
for f in sorted(glob.glob('[0-9][0-9]-*.md')):
    if f.startswith(('00-','01-','02-','03-','04-')): continue
    body=open(f).read().split('## 🧪',1)[-1].split('## 📚',1)[0]
    n=len(re.findall(r'^\d+\..*🧬', body, re.M))
    print(f"   {f:<40} {n}", "" if n>=2 else "⚠️")

print("\n3) Fases BE: comprobación 'el frontend no se toca'")
for f in sorted(glob.glob('be0*.md')):
    ok='git diff fase-10-certificados-vigencia..HEAD -- src/' in open(f).read()
    print(f"   {f:<46}", "OK" if ok else "— (no la menciona)")

print("\n4) Cuaderno BE: forma de preparación declarada por incidente")
s=open('cuaderno-incidentes-be.md').read()
for blk in re.split(r'^## Incidente ', s, flags=re.M)[1:]:
    nid=blk[:5]
    prep=blk.split('### 🔧 Preparación',1)[1].split('---',1)[0] if '### 🔧 Preparación' in blk else ''
    forma = ('rama' if 'git switch -c' in prep else
             'sql'  if 'psql -U postgres certcore <' in prep else
             '.env' if 'POSTGRES_TAG' in prep else
             'caos' if 'CHAOS=' in prep else
             'ninguna' if re.search(r'[Nn]inguna', prep) else '❌ SIN DECLARAR')
    print(f"   {nid}: {forma}")
PY

# --- 2026-09-12T02:20:01 · Check be00 for the frontend-untouched checklist item
grep -n "src/\|frontend" be00-el-contrato-auditoria-del-mock.md | head -8

# --- 2026-09-12T02:20:14 · Add the missing checklist item to be00
python3 - <<'PY'
p='be00-el-contrato-auditoria-del-mock.md'; s=open(p).read()
old="- [ ] Sabes explicar, sin mirar, **por qué `certificates.status` es un campo guardado**"
new="""- [ ] `git diff fase-10-certificados-vigencia..HEAD -- src/` devuelve **vacío**. Es la comprobación que abre el track y la que vas a repetir al cerrar cada una de las ocho fases: el backend se adapta al contrato, nunca al revés.
- [ ] Sabes explicar, sin mirar, **por qué `certificates.status` es un campo guardado**"""
assert s.count(old)==1
open(p,'w').write(s.replace(old,new,1)); print('añadido a be00 §2')
PY
grep -c "git diff fase-10-certificados-vigencia..HEAD -- src/" be0*.md | tr '\n' ' '

# --- 2026-09-12T02:20:27 · Re-run all validators after fixes
python3 /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/scratchpad/slug2.py && python3 /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/31a544c8-743c-4327-84b8-a34d9fce769e/scratchpad/xanchor.py && python3 prompts/verificar-forenses.py | tail -2 && echo && echo "Ejercicios be00 tras la edición:" && grep -m1 "^## 🧪 7" be00-el-contrato-auditoria-del-mock.md && git -C .. status --short angular-16-legacy-for-backend-devs | wc -l

