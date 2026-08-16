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

Faltan dos de los seis modos, y el reparto es idéntico al del mock: **`cors` vive donde se ponen las cabeceras** —no se puede omitir una cabecera desde un middleware que corre después— y **`expired` vive donde se firma el token**, que hasta be03 sigue siendo el mock.

```php
<?php
// server/app/Http/Middleware/CorsMiddleware.php

declare(strict_types=1);

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

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
