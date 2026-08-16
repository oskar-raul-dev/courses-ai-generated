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
- [`$app->withFacades()`, apagado por defecto](#app-withfacades-apagado-por-defecto)
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
