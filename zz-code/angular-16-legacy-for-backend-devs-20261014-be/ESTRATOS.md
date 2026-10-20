# ESTRATOS.md — procedencia de `server/app/` (be02)

> Fase be02. Clasifica **los 11 archivos** de `server/app/` con una de cuatro etiquetas: `laravel`, `symfony`,
> `cake`, `neutro`. Cada clasificación lleva la evidencia (archivo:línea). Medido el 14/10/2026 sobre
> `zz-code/angular-16-legacy-for-backend-devs-20261014-be/server/app/`.
>
> **Regla aplicada:** un rasgo no clasifica, tres sí. Si un archivo tiene tres rasgos de una familia y ninguno de
> otra, su etiqueta es esa familia. Si tiene tres de dos familias, o dos o menos, es `neutro` y la mezcla se anota.

---

## 1. Clasificación archivo a archivo

| Archivo | Etiqueta | Evidencia (archivo:línea) |
|---|---|---|
| `Http/Controllers/TemplateController.php` | **symfony** | `declare(strict_types=1)` en la 4; firma tipada `index(): JsonResponse` (25); constructor con interfaz `TemplateRepositoryInterface` (20); `new JsonResponse` (29); docblock de la propiedad (14). |
| `Http/Controllers/CertificateController.php` | **cake** | Active Record en el controlador: `new Certificate()` (14), `->save()` (23), devuelve el modelo `return $certificate` (25); columna `created` (21), no `created_at`; `status` guardado como dato (20). |
| `Http/Controllers/LegacyTemplateController.php` | **laravel** | Service locator `app('cache')->get` (15); scope `Template::active()` (21); helper `response()->json(collect(...))` (25). |
| `Models/Template.php` | **laravel** | `extends Model` de `Illuminate\Database\Eloquent` (6, 8); convención de scope `scopeActive` (16) y `return` en la 18; columna `valid_until` en snake_case. |
| `Http/Middleware/CorsMiddleware.php` | **laravel** | Helpers `response('', 204)` y `config(...)`; tipos `Illuminate\Http\Request`, `Closure`. Sólo dos rasgos de Symfony (`strict_types`, un `@return mixed` suelto). |
| `Http/Controllers/HealthController.php` | **neutro** (mezcla) | Laravel: `extends` de la base de Lumen (10), `config()` (22), `app()->version()` (30). Symfony: `strict_types` (4), firma `show(): array` (18), docblock (16). Tres y tres. |
| `Http/Middleware/ChaosMiddleware.php` | **neutro** (mezcla) | Laravel: `response()->json` (60, 93, 99), `config()` (en el constructor), `Illuminate\Http\Request` (9). Symfony: `strict_types` (4), firmas tipadas (72), seis docblocks. Tres y tres. |
| `Http/Controllers/HealthLegacyController.php` | **neutro** | Sin framework: `new \PDO` (13), `->query` (14), `header()` (16), `json_encode` a mano, `exit;` (18). Sin namespace de framework, sin `use`. Es la columna **Ninguno** de la tabla de huellas. |
| `Support/ChaosConfig.php` | **neutro** | Sin dependencias de framework (sólo `RuntimeException`, 8). Firmas tipadas (25) y `strict_types` (4), que son rasgos de Symfony, pero sin interfaz, sin inyección y sin helpers. No hay tres rasgos de una familia que lo lleven a ella. |
| `Console/Kernel.php` | **neutro** | Scaffold de Lumen: `extends ConsoleKernel` de `Laravel\Lumen` (7). Un rasgo de framework y `strict_types` (3). Sin autoría propia. |
| `Exceptions/Handler.php` | **neutro** | Scaffold de Lumen: `extends ExceptionHandler` de `Laravel\Lumen` (7). Un rasgo, más `strict_types` (3). |

**Recuento:** `laravel` 3 · `symfony` 1 · `cake` 1 · `neutro` 6.

### Notas de clasificación

- **Dos archivos son mezcla y se dejan en `neutro` a propósito.** `HealthController` y `ChaosMiddleware` fueron escritos
  en este track con tipado estricto (rasgo Symfony) y con los helpers de Lumen (rasgo Laravel). Si se etiquetaran `laravel`
  porque el framework es Lumen, la mezcla desaparecería de la tabla; ésa es la razón de dejarla visible.
- **`LegacyTemplateController.php` tenía dos versiones en la lección.** El 15/10/2026 el autor fijó la de be02 §5.1
  (`app('cache')->get(...)`, service locator) como canónica desde be01, y be01 se corrigió para usarla. Con ella, la
  medición 2 da `app(` = 2 (`HealthController` y este archivo) y la clasificación no cambia. Las líneas de esta tabla son
  las de la versión canónica.
- **Los archivos `TemplateController`, `CertificateController` y `HealthLegacyController` vienen de la lección be02 §5.1.**
  No los escribió la fase ni se modificó nada de `server/app/` de be01. Son el estado heredado que be02 clasifica.
- **`TemplateController` no se ejecuta.** Pide `App\Domain\Template\TemplateRepositoryInterface`, que no existe, y no
  tiene ruta. La lección dice que "los cuatro se ejecutan"; no es cierto en este árbol. Su clasificación no depende de eso.

---

## 2. Las tres mediciones

Comandos sobre `server/app/`. En esta máquina `grep` es `ugrep`: los patrones que empiezan por `->` se pasan con `-F -e`.

### Medición 1 — ¿De cuántas formas se consulta?

| Forma | Comando (lección) | Resultado | Notas |
|---|---|---|---|
| Eloquent directo desde el controlador (`::where(`, `::all()`, `::find(`) | `grep -rn "::where(\|::all()\|::find(" app/Http/Controllers/ \| wc -l` | **0** | El patrón de la lección no ve `Template::active()`. |
| Eloquent a través de repositorio (`RepositoryInterface`) | `grep -rln "RepositoryInterface" app/ \| wc -l` | **1** | `TemplateController.php`, sin implementación. |
| Query builder sin modelo (`DB::table(`) | `grep -rn "DB::table(" app/ \| wc -l` | **0** | |
| SQL a mano (`DB::select(`, `->query(`, `->prepare(`) | `grep -rn "DB::select(\|->query(\|->prepare(" app/ \| wc -l` | **1** | `HealthLegacyController.php:14`, `->query('SELECT 1')`. |

Medición adicional, porque el patrón de la lección no las cuenta: **scope de Eloquent por llamada estática** (`Template::active()`,
`LegacyTemplateController.php:25`) y **Active Record en el controlador** (`->save()`, `CertificateController.php:23`).
Con ellas, las formas de consultar son **cuatro** (repositorio, scope, Active Record, SQL a mano).

### Medición 2 — ¿De cuántas formas se obtiene una dependencia?

| Forma | Comando (lección) | Resultado | Notas |
|---|---|---|---|
| Service locator con helper (`app(`) | `grep -rn "app(" app/ \| wc -l` | **1** | `HealthController.php:30`, `app()->version()`. **Falso positivo:** no obtiene una dependencia. |
| Service locator explícito (`->make(`) | `grep -rn -F -e "->make(" app/ \| wc -l` | **0** | |
| Inyección por constructor (`public function __construct`) | `grep -rn "public function __construct" app/ \| wc -l` | **2** | `ChaosMiddleware.php:22` (sin dependencias) y `TemplateController.php:20` (con interfaz). |
| Instanciación directa (`new [A-Z]`) | `grep -rnE "new [A-Z]" app/ \| wc -l` | **3** | `CertificateController.php:14`, `TemplateController.php:29`, `ChaosConfig.php:38` (una excepción). |

Dependencias obtenidas de forma **real** en el código: inyección (1, la de `TemplateController`, que no se ejecuta), facade
(1, `Cache::get` en la versión de be01) y estática/`new` (2). **Tres formas** de obtener una dependencia en 11 archivos.

### Medición 3 — ¿De cuántas formas se maneja un error?

| Forma | Comando (lección) | Resultado | Notas |
|---|---|---|---|
| Excepción de dominio o genérica (`throw new`) | `grep -rn "throw new" app/ \| wc -l` | **1** | `ChaosConfig.php:38`, `RuntimeException`. |
| Respuesta de error con el helper (`response()->json(…, 500)`) | (no está en la lección) | **1** | `ChaosMiddleware.php:60`. |
| Cabecera a mano (`header(`, `http_response_code(`) | `grep -rn -F -e "header(" -e "http_response_code(" app/ \| wc -l` | **2**, de los que **1** es código | `HealthLegacyController.php:16`; la otra es el comentario de la línea 11. |
| `abort(` | `grep -rn "abort(" app/ \| wc -l` | **0** | |
| `return false;` / `return null;` en `Http/` | `grep -rn "return false;\|return null;" app/Http/ \| wc -l` | **0** | |
| Silenciadores (`@`) | `grep -rn "@" app/ --include="*.php" \| grep -v "@param\|@var\|@return" \| wc -l` | **0** | |

**Formas distintas de manejar error: tres** (excepción, respuesta con helper, cabecera a mano). Cada una lleva a un
comportamiento distinto: la excepción no se captura en ningún sitio de `server/app/`, la respuesta con helper se
ve en el cliente, la cabecera a mano corta el ciclo de Lumen (`exit;`, `HealthLegacyController.php:18`).

### La tabla de resumen

| Qué | Formas distintas | La más usada | La que más cuesta |
|---|---|---|---|
| Consultar | 4 | Eloquent por scope (1) y SQL a mano (1), empatadas | **SQL a mano** (`HealthLegacyController.php:14`): es la única que salta el modelo y la que be04 tiene que tocar al cambiar de versión de PostgreSQL. |
| Obtener una dependencia | 3 | Instanciación directa (3 `new`, una de ellas una excepción) | **Facade** (`Cache::get`, `LegacyTemplateController.php:19`): sólo funciona con `withFacades()`, que be01 mostró que cambia el arranque. |
| Manejar un error | 3 | Excepción (1) y respuesta con helper (1), empatadas | **Cabecera a mano con `exit`** (`HealthLegacyController.php:16–18`): corta el ciclo de middleware, así que CORS y caos no se aplican a esa ruta. |

---

## 3. La tabla de huellas, rellenada con `server/`

| Rasgo observable | Laravel | Symfony | CakePHP | Ninguno | Ejemplo en `server/` |
|---|---|---|---|---|---|
| `declare(strict_types=1)` | casi nunca | **siempre** | nunca | nunca | `TemplateController.php:4` (symfony) · `CertificateController.php` no lo tiene (cake) · `LegacyTemplateController.php` no lo tiene (laravel) |
| Tipos en firmas y retornos | a medias | **siempre** | casi nunca | nunca | `TemplateController.php:25` `index(): JsonResponse` · `CertificateController.php:12` `store(Request $request)` sin retorno (cake) |
| Cómo obtiene dependencias | `app('x')`, helpers | **constructor + interfaz** | estáticamente, del modelo | `new` a pelo | `TemplateController.php:20` (symfony) · `LegacyTemplateController.php:19` `Cache::get` (laravel) · `HealthLegacyController.php:13` `new \PDO` (neutro) |
| Cómo responde | `response()->json()` o array | **`new JsonResponse`** | devuelve el modelo | `echo json_encode` | `LegacyTemplateController.php:27` `response()->json` (laravel) · `TemplateController.php:29` `new JsonResponse` (symfony) · `CertificateController.php:25` `return $certificate` (cake) · `HealthLegacyController.php:17–18` `echo json_encode` (neutro) |
| Dónde vive la lógica | controlador | servicio/repositorio | **modelo** | controlador | `CertificateController.php:14–23` en el controlador, con `save()` (cake) · `TemplateController.php:20` interfaz de repositorio (symfony) |
| Cómo consulta | `Model::where()->get()` | repositorio con interfaz | `find()` y arrays de condiciones | **SQL a mano** | `Template::active()->get()` `LegacyTemplateController.php:25` (laravel) · `->query('SELECT 1')` `HealthLegacyController.php:14` (neutro) |
| Cómo maneja errores | `abort(404)` | **excepción de dominio** | `return false` | `http_response_code()` | `throw new RuntimeException` `ChaosConfig.php:38` (neutro) · `header()` + `exit` `HealthLegacyController.php:16–18` (neutro) |
| Nombres de columna | `created_at` | `created_at` | **`created`, `modified`** | lo que fuera | `CertificateController.php:21` `created` (cake) · `Template.php` `valid_until` snake_case (laravel) |
| Profundidad de namespaces | `App\Http\...` | **`App\Domain\Template\...`** | `App\Models` | ninguno | `TemplateController.php:8` `App\Domain\Template\...` (symfony) · `CertificateController.php:6` `App\Models\Certificate` (cake) |
| Docblocks | escasos | **exhaustivos** | ninguno | ninguno | `ChaosMiddleware.php` seis (neutro, mezcla) · `Template.php` ninguno (laravel) · `CertificateController.php` ninguno (cake) |

> 🧭 **Dos filas no separan nada en este árbol.** Las de "docblocks" y "tipos" sólo tienen un ejemplo symfony y lo demás
> es `neutro` o mezcla. La de "dependencias" separa bien. Con once archivos, el número de rasgos fuertes por familia es
> pequeño: la clasificación se apoya más en las columnas de consulta y de error que en las de estilo.

---

## 4. Cómo se clasifica en dos minutos (aplicado a un archivo al azar)

Archivo elegido sin mirar la lista: `Http/Middleware/CorsMiddleware.php`.

1. **Línea 3–4:** `declare(strict_types=1)`. Symfony, hipótesis.
2. **Constructor:** no hay. Pasa por `handle(Request $request, Closure $next)`: `Closure` y `Illuminate\Http\Request`. Laravel.
3. **Primer `return`:** `return $response;`, que sale de `response('', 204)` (helper). Laravel.
4. **Nombres de columna:** no toca ninguno.
5. **Recuento:** Laravel tiene tres rasgos (`response()` y `config()` como helpers, los `use` de `Illuminate`). Symfony tiene uno (`strict_types`), más un `@return mixed` que no cuenta.

**Etiqueta:** `laravel`. **Fix:** lo escribiría con `response()` y `config()`, como el resto de middleware de Lumen de este árbol. Nunca con un constructor
con interfaz, porque ahí no hay ninguna.

---

## 5. Coste de rotación (plantilla de la lección §5.5, con lo que hay)

Las cifras (d) y (f) vienen de la propia lección y **no se han verificado** contra datos reales del proyecto.
Las que faltan dependen de quien las mide. No se han inventado.

| Concepto | Valor | Origen |
|---|---|---|
| (a) Semanas hasta que alguien nuevo entrega sin supervisión | — | no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026). |
| (b) Productividad media en ese periodo | — | no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026). |
| (c) Coste semanal cargado | — | no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026). |
| (d) Permanencia media en CertCore | 18 meses | Cifra de la lección. Sin verificar. |
| (e) Coste de una rotación = (a) × (c) × (1 − (b)) | **pendiente** de (a), (b), (c) | Fórmula de la lección. |
| (f) Rotaciones en 8 años | 3 | Cifra de la lección. Sin verificar. |
| (g) Coste de onboarding = (e) × (f) | **pendiente** | |
| (h) Porcentaje transferible a otro sistema | — | no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026). Según la lección, cercano a cero en Lumen 5.8. |

**Supuesto que sí se puede escribir aquí:** la columna de la última fila de §2 (la forma que más cuesta) es la que
concentra el riesgo de rotación: facade, `header()` con `exit` y SQL a mano. Quien llega de Laravel sabe usar el facade y
no sabe que la ruta de `HealthLegacyController` no pasa por el middleware. Eso es lo que (h) tendría que medir.

---

## 6. Qué no se ha uniformado

`git diff --stat` sobre `server/app/` no aplica: `zz-code/` no es un repositorio. El equivalente es: **ningún archivo
de `server/app/` de be01 se ha modificado para esta fase.** Lo que cambió son tres archivos que la lección de be02
añade desde fuera (`TemplateController`, `CertificateController`, `HealthLegacyController`). Cero líneas cambiadas
en el resto.

No se han puesto comentarios de clasificación en los archivos, para no tocarlos.
