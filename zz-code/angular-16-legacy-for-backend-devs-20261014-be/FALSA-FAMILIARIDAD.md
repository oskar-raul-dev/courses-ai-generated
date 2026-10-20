# FALSA-FAMILIARIDAD.md — be01: Lumen 5.8 sobre PHP 7.4

> Cuaderno de la fase be01. Cada bloque es un comando que se corrió dentro del contenedor `api`
> (`docker compose -p certcore-be exec api …`) y su salida literal. Donde la lección decía otra cosa, se
> anota la diferencia y no se corrige el resultado. Fecha de la corrida: 14/10/2026.
>
> Nada de esto sale del host: sin puertos publicados. Las comprobaciones que necesitan red van por una
> `docker run --network certcore-be_default` con `curl` y `jq`.

---

## Línea base (lección §2 y ejercicio 1)

```
$ curl -s localhost:3000/health | jq .        # dentro del contenedor, sin puerto publicado
{"status":"ok","php":"7.4.33","lumen":"Lumen (5.8.12) (Laravel Components 5.8.*)","chaos":"ninguno"}
```

**Diferencia con la lección:** la lección espera `"lumen":"5.8.13"`. `composer.lock` dice `laravel/lumen-framework v5.8.13`,
pero `Laravel\Lumen\Application::version()` devuelve una cadena fija en el código de la 5.8.13:

```
$ grep -n "function version" -A3 server/vendor/laravel/lumen-framework/src/Application.php
141:    public function version()
142-    {
143-        return 'Lumen (5.8.12) (Laravel Components 5.8.*)';
```

El paquete está en 5.8.13 y el framework se reporta como 5.8.12. Se deja tal cual: es lo que responde el código.

```
$ composer show laravel/lumen-framework   →  versions : * v5.8.13
$ php -v                                   →  PHP 7.4.33
```

### `smoke.sh` contra Lumen (línea base)

```
$ docker run … node:18.18.2-alpine sh -c 'BASE_URL=http://api:3000 bash smoke.sh'
FALLOS: 22 de 26
```

La lección dice `OK: 4/24` y el script tiene 26 comprobaciones. La salida completa está en
`evidencia-be01-linea-base.txt`. Las cuatro que pasan:

| Comprobación | Por qué pasa |
|---|---|
| `GET /templates devuelve un array` | Es la ruta con datos fijos de §5.6. **El backend la cumple.** |
| `un id inexistente devuelve 404` | **Comprobación débil.** `GET /clients/NO-EXISTE` no tiene ruta en Lumen: responde 404 HTML de Lumen, no el 404 del contrato. El status coincide por accidente. |
| `y el identificador lógico vive en templateId` | **Comprobación débil.** `GET /templates?templateId=…&version=2` ignora los parámetros y devuelve la primera fila (la v1), que también tiene `templateId`. |
| `las vigencias de plantilla son días desnudos` | **Comprobación débil.** Las tres filas de §5.6 tienen `validFrom` de día, y el filtro no se aplica. |

Dos de cuatro pasan porque el filtro no filtra. Eso responde la pregunta del ejercicio 3: pasan porque la comprobación
es débil, no porque el backend cumpla el contrato. Los otros 22 fallan porque el backend todavía no tiene datos ni rutas.

---

## Bug 1 — El `grep` que no encuentra lo que sí se ejecuta

```
$ grep -rn "Cache::get" server/app/
server/app/Http/Controllers/LegacyTemplateController.php:19:        $cached = Cache::get('templates.all');

$ grep -rn "function get" server/vendor/illuminate/cache/CacheManager.php
80:    protected function get($name)
278:    protected function getPrefix(array $config)
289:    protected function getConfig($name)
299:    public function getDefaultDriver()

$ php server/tools/probe.php "get_class(app('cache'))"
string(29) "Illuminate\Cache\CacheManager"
```

**Diferencias con la lección:**
- La lección espera `(nada)` en el primer `grep` de `function get`. Aquí aparece un `protected function get($name)` en
  `CacheManager`. No es el `get` que llama el facade (ése está en el repositorio que devuelve `store()`), y por eso el
  `grep` sigue sin llevar a la implementación. El síntoma se sostiene, pero el resultado de la lección no.
- La lección dice `string(38)`. El nombre `Illuminate\Cache\CacheManager` tiene 29 caracteres: lo que cuenta `var_dump` es 29.
- La línea del `Cache::get` está en la 19 de este archivo (la lección dice la 28). El archivo se reconstruyó: la lección no
  publica el archivo completo.

**Lo que enseña:** `grep` encuentra nombres y no implementaciones. `probe.php` pregunta al objeto.

---

## Bug 2 — El ejemplo de Laravel que aquí no existe

```
$ php server/tools/probe.php "Cache::get('cualquier-cosa', 'por defecto')"
In probe.php(22) : eval()'d code line 1:
  Class 'Cache' not found
```

Descomentando `$app->withFacades();` en `server/bootstrap/app.php` (y restaurando después, byte a byte):

```
$ php server/tools/probe.php "Cache::get('cualquier-cosa', 'por defecto')"
string(11) "por defecto"
```

**Coincide con la lección** para el caso de `Cache`. Ojo: con los facades apagados, `LegacyTemplateController::index()` no "funciona" como dice
la lección §5.7. Con los facades apagados, `Cache::get` en ese archivo fallaría con
`Class 'App\Http\Controllers\Cache' not found` (inferido del espacio de nombres; no se ejecutó). Ninguna ruta lo llama
en be01, así que no se ve.

---

## Bug 3 — El scope que no aparece buscando su propio nombre

```
$ grep -rn "function active" server/app/
(sin salida, exit 1)

$ grep -rn "::active(" server/app/
server/app/Http/Controllers/LegacyTemplateController.php:25:        $rows = Template::active()->get();

$ php server/tools/probe.php "method_exists(App\Models\Template::class, 'active')"
bool(false)

$ php server/tools/probe.php "App\Models\Template::active()->toSql()"
In Model.php line 1253:
  Call to a member function connection() on null

$ php server/tools/probe.php "App\Models\Template::active()->get()"
In Model.php line 1253:
  Call to a member function connection() on null
```

**Diferencia con la lección, y es la más importante de la fase:** la lección dice que `toSql()` "no conecta con nada" y
devuelve `select * from "templates" where "valid_until" is null`. **No funciona en be01.** Sin `$app->withEloquent()`
no hay resolutor de conexiones, y `Model` falla antes de construir la consulta. Para que `toSql()` funcione hace falta
encender Eloquent, que la lección reserva para be03. Es decir: el "límite exacto de la fase" de §5.7 está en el sitio
equivocado. Hoy no se puede investigar el SQL de un scope sin base de datos ni `withEloquent()`.

La línea 25 del controlador aparece en la lección como la 31.

---

## Bug 4 — Lo que Lumen quitó

```
$ php server/tools/probe.php "session(['ultima_consulta' => 'templates'])"
In probe.php(22) : eval()'d code line 1:
  Call to undefined function session()
```

**Coincide con la lección.** La tabla de §5.7 (qué falla en ruidoso y qué en silencio) se sostiene para este caso: es el
mejor de los cuatro, porque grita. La única fila silenciosa de la tabla, `config('algo')` sin registrar, se comprueba
más abajo con el caos.

---

## Caos en PHP (ejercicios 5 y 6 de §7, y la tabla de §5.5)

Medido con un cliente PHP dentro del contenedor (`file_get_contents` con el tiempo de respuesta). Cada modo con su
variable y arrancando el servicio de nuevo.

| Variables | Petición | Resultado | Tiempo |
|---|---|---|---|
| `CHAOS=latency,error CHAOS_RATE=1` | `/health` | `HTTP/1.0 500` `{"message":"Fallo interno del servidor"}` | 2,63 s |
| `CHAOS=error CHAOS_RATE=1` | `/health` | `HTTP/1.0 500` | 0,05 s |
| `CHAOS=cors` | `/health` | `200`, **sin** `Access-Control-Allow-Origin` | 0,05 s |
| `CHAOS=malformed CHAOS_RATE=1` | `/templates` | `200`, cuerpo `{"items":[…],"total":3}` (array envuelto) | 0,04 s |
| `CHAOS=timeout CHAOS_RATE=1` | `/health` | sin respuesta (corte del cliente a 5 s) | 5,01 s |
| `CHAOS=latencia` | arranque | **el servicio no arranca**: `Fatal error: Uncaught RuntimeException: Fallos de caos desconocidos: latencia. Los válidos son: latency, error, malformed, cors, expired, timeout.` → `Exited (255)` | — |
| sin caos | `/health` y `/templates` | `200` con `ACAO` | 0,11 s / 0,31 s |

- `expired` no se puede comprobar en be01: vive en `auth.js` del mock y el backend todavía no tiene `/auth/login`.
  Se verifica en be03.
- `timeout`: con `CHAOS_RATE=1` todas las peticiones cuelgan. Con `PHP_CLI_SERVER_WORKERS=4` y una probabilidad menor,
  no se ha medido si las demás peticiones siguen respondiendo mientras una cuelga.

**Diferencia con la lección:** la lección dice que `CHAOS=latencia` impide arrancar sin más. Con `php -S` sólo, no era así:
el servidor arrancaba y el error aparecía en la primera petición. Se añadió un preflight en `compose.yaml`
(`php -r 'require "server/bootstrap/app.php";' && exec php -S …`), que carga la configuración antes de servir. Con eso,
el contenedor sale con `Exited (255)` y el mensaje en el log.

---

## Qué se desvió de la lección (y por qué)

1. **Sin puertos publicados.** `compose.yaml` no tiene `ports:`. La regla del autor es no publicar puertos por defecto
   desde contenedores de prueba. Las pruebas van dentro de la red de compose.
2. **Variables del caos en `compose.yaml`.** `CHAOS`, `CHAOS_RATE` y `CHAOS_DELAY_MS` pasan del shell con los mismos
   valores por defecto que el mock (`:-0.3`, `:-2500`). Sin ese `:-`, un `CHAOS_RATE` vacío valdría `0` y no `0,3`.
3. **Preflight de arranque** (ver arriba).
4. **Composer bloquea dos paquetes con avisos de seguridad.** Al resolver con Composer 2.10.3, `firebase/php-jwt` y
   `illuminate/view` se rechazan por los avisos `PKSA-y2cr-5h3j-g3ys`, `PKSA-2kqm-ps5x-s4f5` y `PKSA-h74q-2n9z-j6wq`.
   Con `--no-security-blocking` en la única ejecución de `composer install` el lock queda con
   `firebase/php-jwt v5.5.1` e `illuminate/view v5.8.36`. **Es una decisión de laboratorio** y tiene que quedar a la vista:
   el backend corre con dependencias que tienen avisos abiertos, justo lo que SEC-2291 y bea-08 describen. No se
   escribió en `composer.json`.
5. **`server/app/Models/Template.php` y `LegacyTemplateController.php` están reconstruidos.** La lección muestra el modelo
   pero no el controlador completo. El modelo lleva `namespace` y `use` que la lección omite.
6. **`Exceptions/Handler.php` y `Console/Kernel.php`** son los stubs mínimos de Lumen, porque la lección no los muestra y
   `bootstrap/app.php` los referencia.
7. **`composer.json` no puede explicar por qué no es 6.0.** La lección pide que lo explique, pero JSON no admite comentarios.
   La explicación queda pendiente de redactar en otro documento. No se ha verificado contra Packagist en esta corrida
   qué exige Lumen 6.x; no se afirma aquí.

---

## Pendiente

- [—] **El experimento de los diez minutos (§5.9)** (no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026)). Pedir una respuesta a un asistente y pegarla sin editar. Requiere
  una conversación real fuera del terminal; no lo puedo hacer yo.
- [—] `git tag be-fase-01-…`: los tags son del repositorio del alumno, no de esta validación.
- [~] Las comprobaciones de la lección que no se pueden hacer hasta be03: `expired`, `/auth/login` y los `401` del
  interceptor.

---

## Actualización del 15/10/2026: correcciones aplicadas a be01 y lo que cambió aquí

- **El controlador heredado canónico** es el de be02 §5.1 (`app('cache')->get('templates.all')`, línea 15;
  `Template::active()`, línea 21). be01 bug 1 usa ahora esa línea y el `grep` de `function get` con su salida real.
- **`toSql()`:** be01 dice ahora lo medido: en be01 falla (`connection() on null`); desde be03, con `withEloquent()` y
  `$app->boot()` en `tools/probe.php`, da el SQL aunque la base esté parada, y `get()` falla con
  `could not translate host name "db"`.
- **`/health`** en la lección muestra `Lumen (5.8.12) …` y explica por qué.
- **`string(29)`**, no `string(38)`.
- **`compose.yaml` (bea-02):** `working_dir: /app/server`, `APP_ENV: local`, las variables del caos y un preflight que carga
  el arranque **y arranca los proveedores** antes de servir. Con eso, `CHAOS=latencia` mata el arranque (`Exited (255)`) y el
  proveedor copiado de be-02 también.
- **Línea base del smoke:** las 4 que pasaban siguen sin depender de las dos comprobaciones que cambiaron en be00
  (la ruta anidada pasó a `?inspectionId=`); no se ha vuelto a montar el backend de be01 para medirla otra vez.
