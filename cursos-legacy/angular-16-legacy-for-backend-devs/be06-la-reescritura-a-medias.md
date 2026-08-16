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
