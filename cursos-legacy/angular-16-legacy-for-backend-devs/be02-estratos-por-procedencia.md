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
