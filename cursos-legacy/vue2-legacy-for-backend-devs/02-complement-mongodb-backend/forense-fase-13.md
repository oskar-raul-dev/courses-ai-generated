# 🕵️ Forense Fase 13 — "Verde en mi máquina, rojo en CI"

> **Sale de:** [Fase 13 — Testing de API](13-testing-de-api.md) ·
> **Herramientas:** la salida de la suite, el log del `globalSetup`, y
> `serverInfo().version` · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la misma suite, el mismo commit, dos resultados
> distintos según dónde corra.

Esta pieza promueve a archivo el post-mortem que la Fase 13 ya traía en su
sección 6, con la estructura de ocho puntos del curso y su regla: **se analiza el
sistema, no a la persona.** Nadie rompió nada; el sistema permitía dos motores
distintos, y el arreglo es que deje de permitirlo.

---

## 🎫 El ticket

> "La suite pasa en local siempre y en CI falla una de cada tres corridas. Falla
> en `services/`, en los asserts del `$ne` y en el del upsert que colisiona. No
> hemos cambiado ese código en dos semanas."
>
> — el compañero que montó el pipeline · **Ambiente:** local y CI

---

## 🧭 La ruta

Del más barato al más caro: primero se comprueba **contra qué** estás
ejecutando, después se reproduce, y el código de los tests es lo último — porque
en este caso no tiene la culpa.

### Paso 1 — ¿contra qué motor corre cada entorno?

En la suite, o en el log del arranque del `globalSetup`:

```js
> await db.admin().serverInfo().version
'4.4.18'        // tu equipo
```

```
CI  ›  mongodb-memory-server: downloading mongod 7.0.5 …
```

**Qué descarta.** Descarta el código, los tests y la lógica de negocio de una
sola vez. Los dos entornos están midiendo **motores distintos**, y el
comportamiento de precondiciones atómicas e índices únicos —justo lo que fallaba—
cambia entre versiones. El test no es *flaky*: es correcto, y está midiendo dos
cosas.

### Paso 2 — reproducirlo en tu propia máquina

```bash
rm -rf ~/.cache/mongodb-binaries    # o la caché que use tu instalación
npx jest test/services
```

```
FAIL  test/services/tickets.service.spec.js
```

**Qué descarta.** Descarta que sea "cosa de CI", que es la conclusión cómoda y la
que deja el bug vivo. En una máquina limpia, sin binario cacheado y sin
`binary.version` fijado, `mongodb-memory-server` descarga **el más nuevo
disponible** — y tu laptop solo se salvaba porque tenía el 4.4 cacheado desde la
Fase 0.

### Paso 3 — la causa raíz, escrita como corresponde

```js
// test/globalSetup.js
module.exports = async function () {
  var server = await MongoMemoryServer.create({
    binary: { version: "4.4.18" }        // ← esto es lo que faltaba
  });
  …
};
```

**Qué descarta.** Cierra el caso: el default del paquete es traer lo último, y
nadie lo declaró. El arreglo no es un `retry` ni marcar el test como flaky, es
**fijar el binario en el repositorio** —no en la máquina de quien lo corrió
primero— y cachearlo en CI por su versión exacta, nunca por "latest".

Y la prueba de regresión que impide la reincidencia, que es un test trivial y
vale su peso en oro:

```js
it("corre contra el motor del curso", async function () {
  var info = await db.admin().serverInfo();
  expect(info.version).toMatch(/^4\.4/);
});
```

Si alguien "moderniza" el binario, grita ese test antes que los de lógica — y
grita diciendo la verdad, no un fallo de negocio que despista.

### Paso 4 — el otro flaky: el que depende del orden

Si el motor ya está fijado y el rojo persiste, cambia el sospechoso:

```bash
npx jest test/services --runInBand
```

```
PASS  test/services/tickets.service.spec.js
```

**Qué descarta.** Si en serie pasa y en paralelo falla, el problema es
**aislamiento**: suites que comparten nombres de colección sobre la misma base
efímera, o un `deleteMany` en `afterEach` que deja el resultado a merced del
orden. Se resuelve con una base por suite, no con `--runInBand` permanente —eso
esconde el problema y te cobra el tiempo en cada corrida.

### Paso 5 — el test que nunca falla

Aprovecha la investigación para comprobar lo contrario, que no reporta nadie:

```js
it("detecta el doble take", async function () {
  await Promise.all([take(id, "ana"), take(id, "beto")]);
  expect(await countAssigned(id)).toBe(1);
});
```

```
PASS
```

Rompe a propósito la precondición del filtro (Fase 6) y vuelve a correr:

```
PASS        // ⚠️ sigue verde
```

**Qué descarta.** Descarta el valor de ese verde. Una carrera es
**probabilística**: con una sola ronda, el verde es suerte. Un test de
concurrencia serio repite la operación decenas de veces, y si no lo hace, no está
probando la carrera — está probando que dos llamadas seguidas funcionan.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Verde en local, rojo intermitente en CI | Versión del binario sin fijar: dos motores distintos |
| Falla en paralelo y pasa con `--runInBand` | Aislamiento: base o colecciones compartidas entre suites |
| Un test que nunca falla aunque rompas el código | Async sin `await`, o una sola ronda en un test de carrera |
| La suite tarda una eternidad | Un memory-server por test en vez de uno por suite |
| Tests verdes que no prueban nada | Se mockeó la colección: tu mock no reproduce `$ne` ni el upsert |
| Asserts que fallan por la forma del documento | Decide qué piso pruebas: documento crudo o contrato serializado |
| 100% de coverage y bugs en producción | El coverage detecta lo no probado; no certifica lo probado |
| Ruido de sockets en los tests de service | El singleton `realtime` con su no-op ya te protege |

---

## ⚰️ Los callejones

**"Es un test flaky, lo marco como tal y sigo."** Es la puerta de salida más
rápida y la que más caro sale: un test intermitente marcado como flaky deja de
mirarse, y el día que falle por una razón real nadie se va a enterar. Antes de
etiquetarlo, contesta la pregunta del paso 1 — contra qué está corriendo.

**"Mockeamos Mongo y se acabaron los problemas de entorno."** Y con ellos se
acaba el valor de la suite: un mock jamás va a reproducir un upsert que colisiona
ni un `$ne` que incluye ausentes, que es exactamente lo que estos tests
comprueban. Base real efímera — pero **la misma** base real que la de producción,
que es la lección de esta pieza.

**"En CI ponemos la última versión, que es más segura."** Más nueva no es más
parecida a tu producción. Si el backend va a correr en 4.4, testear en 7 es
testear otro sistema: verde en CI y rojo donde importa.

---

## 🧠 El patrón transferible

**Un test que da resultados distintos en dos sitios no es inestable: está
midiendo dos sistemas.** Antes de sospechar del test, enumera qué cambia entre
los dos entornos — versión del motor, zona horaria, orden de ejecución,
paralelismo, datos previos — y fija lo que puedas fijar. Casi siempre hay una sola
variable suelta, y casi siempre está en un default que nadie declaró.

Y la regla que se lleva uno a cualquier proyecto: **lo que no está escrito en el
repositorio, no existe.** El binario cacheado en la laptop del primero que corrió
la suite es configuración invisible, y la configuración invisible es la causa
raíz favorita de los bugs que "solo pasan en CI".

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 13](13-testing-de-api.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 12](cuaderno-incidentes.md); y la carrera que estos tests intentan
cazar, en la [pieza de la Fase 6](forense-fase-06.md).
