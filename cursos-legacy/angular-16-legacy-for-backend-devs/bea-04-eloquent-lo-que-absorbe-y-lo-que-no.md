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
