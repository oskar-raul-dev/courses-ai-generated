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

Lee el mensaje del log **entero**, incluida la primera línea, y fíjate en qué palabra exacta usa: ¿dice *undefined method*, *class not found*, o *undefined function*? Las tres significan cosas distintas y apuntan a capas distintas — la tabla está en [`be01` §5.7](be01-lumen-y-la-familiaridad-falsa.md#57-los-cuatro-bugs-de-la-familiaridad-falsa-).

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

No es una prueba ni un *linter*: es el protocolo de los diez minutos de [`be01` §5.9](be01-lumen-y-la-familiaridad-falsa.md#59-el-experimento-de-los-diez-minutos-). Antes de pegar una respuesta de internet o de un asistente, **ejecutarla y anotar en qué falla**. En este proyecto no es prudencia general: es que hay cien veces más Laravel escrito que Lumen, y la respuesta plausible es la norma.

**Por qué llegó a producción**

No llegó — se quedó en una rama, y esa es la buena noticia. Llegó al equipo, que es distinto: el compañero perdió media tarde y la perdió **con razón**, porque el ejemplo era correcto, tenía votos, y no había ninguna señal disponible de que este framework no fuera aquél. La señal que faltaba no es técnica: es que nadie había escrito la página que dice *"aquí los middleware se registran en `bootstrap/app.php` y los facades están apagados"*.

**Si tu causa fue distinta a esta**

- *"Falta el proveedor en `bootstrap/app.php`."* Es exactamente la trampa: **añadirlo con `$app->register()` hace que el error cambie** —pasa a `Class 'Log' not found`— y parece que avanzas. Estás persiguiendo el segundo bug con el primero todavía puesto.
- *"Hay que encender los facades."* Resuelve el `Log::info` y deja el `aliasMiddleware` intacto. Y además cambia el arranque de una aplicación de ocho años para arreglar una línea de un ejemplo copiado: ver la autopsia de [`be01` §5.7](be01-lumen-y-la-familiaridad-falsa.md#57-los-cuatro-bugs-de-la-familiaridad-falsa-).

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

La secuencia `inspections_id_seq` va por 3 y la tabla tiene inspecciones hasta la 503. La causa está en el sembrador de [`be03` §5.4](be03-el-reemplazo.md#54-la-siembra-desde-tu-propio-dbjson): insertó las filas **con su `id` explícito** —tenía que hacerlo, porque el frontend conoce la inspección 501 por su número— y **la secuencia no se enteró**. En PostgreSQL, un `INSERT` que trae el valor de una columna `serial` no consume el siguiente de la secuencia: la secuencia sigue donde estaba.

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

---

## Incidente be-06 — "El informe falla y no hemos desplegado nada"

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
> **Tiempo sugerido:** 35-45 min · **Pieza forense:** [`be04` §5.3](be04-el-salto-de-version-que-nadie-corrio.md#53-lo-que-se-rompió-de-verdad-con-cita)

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

---

## Incidente be-08 — "El certificado dice que vence hoy y en el PDF dice ayer"

> **Fase:** be04 · **Categoría:** Tiempo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min · **Pieza forense:** [`be04` §5.5](be04-el-salto-de-version-que-nadie-corrio.md#55-la-cicatriz-de-las-fechas--4) · Apoyo: [`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md)

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

Migrar las seis columnas de fecha con hora a `TIMESTAMPTZ`, que es la 💸 declarada en [`be03` §5.1](be03-el-reemplazo.md#51-el-esquema-entero) y costeada en [`be04` §5.5](be04-el-salto-de-version-que-nadie-corrio.md#55-la-cicatriz-de-las-fechas--4). **No se hace aquí**, y el motivo es serio: convertir obliga a **elegir una zona de origen y esa elección es irreversible**. Se hace una vez, con el procedimiento de siete pasos de [`be05` §5.5](be05-la-invariante-que-no-sostenia-nadie.md#55-el-procedimiento-de-despliegue-que-es-el-entregable-de-verdad) y con la frase de arriba ya firmada.

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
- **El TZ fijado explícitamente en el arranque** (`date_default_timezone_set('UTC')` en `bootstrap/app.php`), en vez de heredarlo del entorno. Una zona que viene de una variable del contenedor es configuración que despliega sin pasar por un commit — la misma familia que [`be-06`](#incidente-be-06--el-informe-falla-y-no-hemos-desplegado-nada).
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

---

## Incidente be-10 — "Después del despliegue no puedo actualizar unas inspecciones viejas"

> **Fase:** be05 · **Categoría:** Restricciones · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-40 min · **Pieza forense:** [`be05` §5.3](be05-la-invariante-que-no-sostenia-nadie.md#53-las-tres-salidas-costeadas) · Apoyo: [`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md)

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

- **El correo de despliegue.** El paso 6 del procedimiento de [`be05` §5.5](be05-la-invariante-que-no-sostenia-nadie.md#55-el-procedimiento-de-despliegue-que-es-el-entregable-de-verdad) lo pedía explícitamente: *anunciar los efectos laterales*. Este incidente **existe porque ese paso se saltó**, y es el más barato de los siete.
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

Decidir cuál de los dos caminos es el oficial —lo pedía la tabla de [`be06` §5.1](be06-la-reescritura-a-medias.md#51-medir-la-superficie-los-tres-números)— y anotarlo. Borrar el otro **no** es de este incidente: depende del *assessment* de be07, y hacerlo aquí sería resolver un ticket de treinta minutos con una migración.

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

1. **"Inmantenible" no es un hallazgo: es un adjetivo.** El sistema se mantiene —lleva ocho años en producción emitiendo certificados— y tú acabas de resolver once incidentes en él. Lo que es cierto es que **mantenerlo cuesta más de lo que debería**, y eso sí tiene número: el coste de rotación de [`be02` §5.5](be02-estratos-por-procedencia.md#55-el-número-que-be07-va-a-necesitar-el-coste-de-rotación). Sustituir el adjetivo por la cifra mejora el informe y **fortalece** su argumento.
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
