# 🕵️ Forense Fase 03 — "A veces carga y a veces se queda pensando"

> Pieza forense de la **Fase 3 — Mock API y caos** · Recorrido: ~40 min
> Herramientas: pestaña Network (Timing, Response, Status) · consola · logs del mock
> Síntoma que cubre: fallos intermitentes, y los seis que este proyecto puede producir a voluntad.

Ésta es la pieza que más se consulta durante el cuaderno de incidentes, porque casi todos los fallos intermitentes del curso son uno de estos seis. El objetivo no es memorizar la tabla: es **saber qué mirar primero** para que la tabla conteste sola.

La fase resume los seis y dice cuál miente. Aquí está el árbol de decisión completo, con la salida literal de cada uno.

---

## 🎫 El ticket

> *"La pantalla de plantillas a veces carga y a veces se queda pensando. Y una vez me salió un mensaje raro de que la respuesta no tenía la forma esperada, pero no lo pude repetir."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

El ticket describe **dos fallos distintos** y quien lo escribió cree que es uno. Eso es lo normal, y separarlos es el primer trabajo.

---

## 🧭 El árbol de decisión

Una sola pregunta al principio, y de ahí salen tres ramas. **Empieza siempre por el status**, porque cuesta un vistazo y parte el problema en tres.

```
¿Qué dice la columna Status de Network?

├─ (failed), sin número ......................... rama A — nadie contestó
├─ pending, para siempre ........................ rama B — contestaron a medias
└─ un número (200, 401, 500) .................... rama C — sí contestaron
```

### Rama A — `(failed)`, sin status

```
Name        Status      Type    Initiator          Size    Time
templates   (failed)    xhr     zone.js:xxxx       0 B     3 ms
```

Y en la consola:

```
Access to XMLHttpRequest at 'http://localhost:3000/templates' from origin
'http://localhost:4200' has been blocked by CORS policy: No 'Access-Control-Allow-Origin'
header is present on the requested resource.
```

**Lo que tu código recibe**, que es la parte importante:

```js
// El HttpErrorResponse que llega al catchError:
error.status;         // 0     ← no es 403, no es 404: es CERO
error.statusText;     // 'Unknown Error'
error.url;            // 'http://localhost:3000/templates'
```

> ⚠️ **`status: 0` es indistinguible desde el código de tres situaciones distintas:** CORS bloqueado, servidor caído, y red ausente. La información que las separa **sólo existe en la consola del navegador**, y tu código no puede leerla. Por eso el mensaje que `toApiError` produce menciona las tres posibilidades en vez de adivinar una: adivinar mandaría a quien lee el ticket a mirar el sitio equivocado dos de cada tres veces.

Cómo se separan a mano, en diez segundos:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/templates
# 200 → el servidor está vivo: era CORS (curl no aplica la política del navegador)
# 000 → no hay nadie en ese puerto: el servidor está caído o el puerto es otro
```

**Qué descarta.** Con `status: 0` confirmado, quedan descartados de golpe todos los fallos que sí llegaron a contestar: no es un `500`, no es `malformed`, no es un token vencido. Lo que queda son tres causas —CORS, servidor caído, red ausente— y el `curl` de arriba las separa en dos grupos.

**Reproducir a voluntad:** `CHAOS=cors npm run mock`.

### Rama B — `pending` para siempre

```
Name        Status      Type    Size        Time
templates   pending     xhr     0 B         (contando)
```

No hay error. No hay nada en consola. El spinner gira. Es el fallo **más silencioso** de los seis y el que peor tolera un usuario, porque no puede ni reintentar.

**Lo que tu código recibe:** nada. El observable no emite, no falla y no completa. Si la pantalla no tiene tiempo límite, se queda así hasta que alguien recargue.

**Qué descarta.** Sin error y sin respuesta queda descartado todo lo demás: cualquier otro fallo de los seis produce **algo** —un status, un cuerpo, una excepción—. Si no hay nada que capturar, el sospechoso es uno solo. Y descarta también tu `catchError`: no está fallando, es que nunca se le llamó.

**Reproducir a voluntad:** `CHAOS=timeout npm run mock`.

> 💡 **La lección de diseño que sale de aquí:** un `catchError` no te protege de esto, porque nunca hay error que capturar. Lo único que protege es un `timeout(ms)` explícito en el flujo, y decidir cuántos milisegundos es una decisión de producto que casi nadie toma hasta que le pasa esto.

### Rama C — sí contestaron: el status manda

**`500`, y sólo a veces:**

```
Name        Status    Type
templates   500       xhr
templates   200       xhr
templates   500       xhr
templates   200       xhr
```

Recarga cinco veces y cuenta. Si los fallos se alternan sin patrón, es un fallo probabilístico. `CHAOS=error npm run mock` lo produce con probabilidad `CHAOS_RATE` (0.3 por defecto), y `CHAOS_RATE=1` lo hace determinista para poder investigar sin luchar contra el azar — que es el primer movimiento de cualquier investigación de intermitentes.

**`200` verde, y la pantalla dice que el dato no tiene la forma esperada:**

```
Name        Status    Type    Size
templates   200       xhr     87 B
```

```json
// Network → Response. Esperabas un array y llegó esto:
{ "data": [], "meta": { "note": "chaos" } }
```

**Éste es el que miente**, y por eso tiene su propio párrafo. Los otros cinco se anuncian: hay algo rojo, hay un status raro, hay algo que mirar. `malformed` devuelve `200` con el cuerpo cambiado, así que **la pestaña Network te dice que todo salió bien**. Si te fías del semáforo verde, te pasas media hora leyendo tu componente buscando un bug que está en el borde HTTP.

Lo que lo caza en un segundo, y por eso los `*ApiService` de la fase lo llevan puesto:

```ts
// En TemplateApiService.getAll(), antes de devolver nada.
map((response: unknown) => {
  if (!Array.isArray(response)) {
    // El mensaje nombra la FORMA, no la red: es lo que hace que el ticket
    // llegue con la palabra correcta y no como "a veces no carga".
    throw new ApiError('El servidor devolvió algo que no es una lista de plantillas.');
  }
  return response;
});
```

**Qué descarta.** Un `200` con el cuerpo cambiado descarta la red entera: la petición salió, llegó y volvió. A partir de aquí el problema está en el **contenido**, y por tanto en el borde HTTP de tu aplicación o en el servidor — nunca en el componente, que está haciendo lo correcto con un dato equivocado.

**Reproducir a voluntad:** `CHAOS=malformed CHAOS_RATE=1 npm run mock`.

**Todo va lento pero funciona:**

Network → clic en la petición → pestaña **Timing**:

```
Queueing              0.4 ms
Stalled               0.9 ms
Request sent          0.1 ms
Waiting (TTFB)     2503.7 ms     ← aquí está
Content Download      1.2 ms
```

**`Waiting (TTFB)` alto con el resto normal es el servidor pensando**, no la red ni el navegador. Si el que estuviera alto fuera `Content Download`, sería un cuerpo enorme; si fuera `Stalled`, sería el límite de conexiones simultáneas del navegador. Los tres se ven distintos y llevan a sitios distintos.

**Qué descarta.** Que el retraso esté concentrado en `Waiting (TTFB)` descarta la red y el navegador: los bytes viajaron rápido y el servidor tardó en empezar a contestar. Si el alto fuera `Content Download`, el sospechoso sería el tamaño del cuerpo; si fuera `Stalled`, el límite de conexiones simultáneas. Tres filas, tres investigaciones distintas.

**Reproducir a voluntad:** `CHAOS=latency npm run mock`, con `CHAOS_DELAY_MS` para ajustar.

**Entra y te devuelve al login de inmediato:**

Es `expired`, y su ruta completa está en `forense-fase-02.md`, paso 2. Aquí sólo la forma de provocarlo: `CHAOS=expired npm run mock`.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Fallo | Cómo lo confirmas | Flag |
|---|---|---|---|
| Todo lento pero funciona | latencia | Timing → `Waiting (TTFB)` alto, el resto normal | `latency` |
| Falla una de cada tres recargas, `500` | error intermitente | recarga cinco veces; se alternan | `error` |
| `200` verde y la forma no es la esperada | respuesta malformada | Response: objeto donde esperabas array | `malformed` |
| `(failed)` sin status, consola con `Access-Control-Allow-Origin` | CORS | `error.status === 0` | `cors` |
| Te devuelve al login de inmediato | token vencido | decodifica el token: `exp` en el pasado | `expired` |
| Spinner eterno, `pending` para siempre | sin respuesta | no hay error que capturar | `timeout` |

Y las combinaciones, que es donde esto se parece de verdad a producción:

```bash
CHAOS=latency,error CHAOS_RATE=0.5 npm run mock
```

---

## ⚰️ Los callejones

**"Es mi componente."** El callejón número uno, y `malformed` es quien te mete en él. La regla que lo evita: **antes de leer una línea de tu componente, mira el cuerpo crudo de la respuesta.** Si el cuerpo no es lo que tu tipo dice, el bug está en el borde HTTP, y tu componente está haciendo lo correcto con un dato equivocado.

**"Es un `403`, no tengo permiso."** Un fallo de CORS **no es un `403`**. Un `403` es una respuesta del servidor: llegó, se leyó, y dijo que no. CORS es el navegador negándose a entregarte una respuesta que quizá llegó perfectamente. La diferencia es total y el `status: 0` es la pista.

**"Se cayó la red."** Puede ser, y por eso el mensaje de `toApiError` no lo afirma. Pero antes de aceptarlo, el `curl` del paso A: si `curl` contesta `200`, la red está bien y el problema es del navegador, que es un sitio completamente distinto donde buscar.

**"El azar no me deja investigar."** No es un callejón, es una técnica que falta: `CHAOS_RATE=1` convierte un intermitente en un determinista, y **ése es siempre el primer movimiento**. Un bug que ocurre una de cada tres veces no se investiga: se hace ocurrir siempre, y entonces se investiga.

---

## 🧨 Deshacer

Todos los fallos de esta pieza se apagan **reiniciando el mock sin el flag**: `npm run mock`. Es la razón por la que el inyector de caos es la forma de preparación preferida del cuaderno de incidentes — no toca tu código, no toca tus datos, y no deja rastro.

Si durante la investigación creaste o modificaste datos, `npm run seed` devuelve el `db.json` a la semilla.

---

## 🧠 El patrón transferible

> **Empieza siempre por el status, y sólo después por el cuerpo.** El status parte el problema en tres ramas que no se parecen en nada: nadie contestó, contestaron a medias, o contestaron. Cada rama tiene sus sospechosos y ninguno se solapa.

Y el segundo, que es el que más se olvida: **un `200` no es una garantía de nada más que de que el servidor respondió.** El semáforo verde de Network es una afirmación sobre el transporte, no sobre el contenido. El único sitio donde se comprueba el contenido es el borde HTTP de tu aplicación, y si no lo compruebas ahí, el dato malformado entra al sistema y explota tres capas más allá, dentro de un `*ngFor`, sin ninguna pista de dónde vino.

**Incidentes del cuaderno que usan esta ruta:** 04 (la pantalla que a veces carga) y, como herramienta de preparación, prácticamente todos los intermitentes de la semana 4.
**Amplía:** **A06** §6 para qué devolver desde un `catchError`, y `forense-fase-13.md` para cuando el mismo síntoma llega desde un contenedor y no desde el mock.
