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
