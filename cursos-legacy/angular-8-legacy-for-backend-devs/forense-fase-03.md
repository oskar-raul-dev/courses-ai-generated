# 🕵️ Forense Fase 03 — Una petición de punta a punta: breakpoints condicionales y correlación

> Pieza forense de la [**Fase 3 — Autenticación mínima**](./03-autenticacion.md) · Recorrido: ~45 min · [Índice del track](./forense-master.md)
> Herramientas: breakpoints condicionales en el interceptor · Application → Local Storage · el log de Express
> Síntoma que cubre: "me saca al login sin decir nada", y todo lo que hay entre el navegador y el servidor.

El interceptor es el único punto por el que pasan **todas** las peticiones de la aplicación. Eso lo convierte en el mejor sitio del sistema para mirar —y en el peor, si lo miras mal: un breakpoint ahí se dispara veinte veces por pantalla y no sirve para nada. Esta pieza es el primer ejercicio serio de leer una petición HTTP de punta a punta, y su primera mitad es aprender a **no** detener las diecinueve que no te interesan.

---

## 🎫 El ticket

> *"Estoy trabajando y de un momento a otro me manda al login. No sale ningún mensaje. Vuelvo a entrar y sigo como si nada, hasta que pasa otra vez."*

**Reportado por:** una analista
**Ambiente:** UAT

Sin mensaje, sin patrón aparente y con recuperación inmediata. Tres candidatos, y sólo uno se puede descartar sin escribir código: **el guard** te manda al login antes de pedir nada, **el interceptor** te manda al login después de un `401`, y **el token** puede haber vencido solo. Los tres producen la misma pantalla.

---

## 🧭 La ruta

Cinco pasos. Los dos primeros son diez segundos de Network y de Local Storage y resuelven la mayoría de los casos; el tercero es el breakpoint condicional, que es la técnica que se aprende acá; el cuarto y el quinto unen las dos mitades del viaje.

### Paso 1 — ¿Guard o interceptor? Lo dice Network en diez segundos

Reproduce la navegación que dispara el problema con la pestaña Network abierta y el filtro en `XHR`.

```
Name       Status  Type  Time
patients   401     xhr   14 ms
```

**Qué descarta.** Esa fila decide el rumbo entero:

- **Hay petición y volvió `401`** → el guard te dejó pasar: para él, la sesión era válida. El que te devolvió al login fue **el interceptor**, reaccionando a la respuesta del servidor. El desacuerdo está entre lo que el navegador cree del token y lo que el servidor opina de él. Paso 4.
- **No hay ninguna petición** → nadie llegó a preguntar. El **guard** cortó antes, o sea que `isAuthenticated()` devolvió falso. El token no está, o está y se considera vencido en el propio navegador. Paso 2.

### Paso 2 — El token, mirado directamente

Application → **Local Storage** → `http://localhost:4200` → la clave `lab_clinico_token`.

```
Key                 Value
lab_clinico_token   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhbmFsaXN0YTEi…
```

Y su contenido, sin salir de la consola:

```js
JSON.parse(atob(localStorage.getItem('lab_clinico_token').split('.')[1]))
// { sub: "analista1", fullName: "…", exp: 1567458000 }

// La comparación que hace isExpired(), hecha a mano:
new Date(1567458000 * 1000).toISOString()   // cuando vence
new Date().toISOString()                    // ahora
```

**Qué descarta.** Cuatro salidas y cuatro diagnósticos:

- **No hay clave** → alguien la borró: otra pestaña que cerró sesión, el propio usuario, o un `logout()` disparado por un `401` anterior.
- **Hay clave y `exp` ya pasó** → el token venció de verdad. No es un bug: es la sesión corta que la fase configura a propósito.
- **Hay clave, `exp` está en el futuro, y aun así te saca** → el desacuerdo es de unidades o de reloj. Paso 2 bis.
- **Hay clave y no es un JWT** —una cadena cualquiera— → `getDecodedUser()` devuelve `null`, `isExpired()` lo trata como vencido, y acabas en el login. Correcto por accidente, y merece comprobarse: el ejercicio 16 de la fase se ocupa de que también lo sea a propósito.

### Paso 2 bis — Segundos frente a milisegundos, que es el clásico

`exp` viene en **segundos** desde epoch; `Date.now()` está en **milisegundos**. Si alguien compara los dos sin multiplicar por mil, cualquier token parece vencido desde hace cuarenta y siete años.

```js
// Lo que hace el código correcto:
Date.now() >= decoded.exp * 1000     // false, la sesión vive

// Lo que hace el código con el bug:
Date.now() >= decoded.exp            // true SIEMPRE
```

**Qué descarta.** Si la segunda línea es la que está en `isExpired()`, el diagnóstico está cerrado y explica la parte del ticket que parecía rara: te saca **siempre**, y "vuelvo a entrar y sigo como si nada" porque el token recién emitido tarda un instante en volver a "vencer". La otra causa de esta familia es el reloj del cliente corrido respecto del servidor, y se detecta comparando el `exp` con la hora del mock.

### Paso 3 — El breakpoint que sólo se detiene donde te interesa

Ahora sí, el interceptor. Sources → `auth.interceptor.ts` → clic derecho sobre el número de línea del `const authReq = …` → **Add conditional breakpoint** → y la condición:

```js
req.url.indexOf('/patients') !== -1
```

**Qué descarta.** Nada por sí solo: lo que hace es **hacer usable** el resto de la investigación. Sin condición, ese breakpoint se dispara en cada petición de cada pantalla —traducciones, listas, escrituras— y a la quinta parada ya has perdido el hilo. Con condición, se detiene en la única que te importa.

Detenido ahí, la consola contesta las tres preguntas de un interceptor:

```js
req.url                                  // "http://localhost:3000/patients"
req.method                               // "GET"
this.authService.getToken() ? 'hay token' : 'no hay token'
```

Otras condiciones que valen lo que cuestan escribirlas:

| Condición | Para qué |
|---|---|
| `req.method !== 'GET'` | detenerse sólo en escrituras |
| `req.url.indexOf('/login') === -1` | todo menos el login |
| `!this.authService.getToken()` | cazar la petición que sale **sin** token |
| `req.headers.get('Authorization') === 'Bearer null'` | el clásico del interceptor mal escrito |

Esa última fila es un diagnóstico en sí misma: si el header dice literalmente `Bearer null`, el interceptor está agregando la cabecera aunque no haya token, y el ternario que debía condicionarlo no está condicionando nada.

### Paso 4 — Las dos mitades del viaje, y cómo unirlas

Con el `401` de la fila del paso 1, quedan dos versiones de la misma historia: la del navegador y la de Express. Compararlas es lo que cierra el caso, y hay dos formas.

**La barata, que sirve casi siempre.** El log de Express y la pestaña Network comparten método, ruta y momento. Con poco tráfico, emparejarlas a ojo alcanza:

```
[mock] POST /login
[mock] GET /patients
```

**La honesta, cuando hay tráfico de verdad.** Emparejar por hora falla en cuanto hay diez peticiones por segundo, y entonces hace falta un identificador que viaje con la petición. **LabCore no lo tiene** —ni el interceptor lo pone ni el mock lo registra—, así que se añade como **instrumento de diagnóstico temporal**, igual que se añade un `console.log`, y se quita al terminar. Son dos líneas:

```typescript
// auth.interceptor.ts — TEMPORAL, solo mientras investigas.
var requestId = Math.random().toString(36).slice(2, 10);
console.log('[req ' + requestId + '] ' + req.method + ' ' + req.url);
const authReq = token
  ? req.clone({ setHeaders: { Authorization: 'Bearer ' + token, 'X-Request-Id': requestId } })
  : req.clone({ setHeaders: { 'X-Request-Id': requestId } });
```

```javascript
// mock-server/server.js — TEMPORAL, junto al resto de middlewares.
app.use(function (req, res, next) {
  console.log('[mock ' + (req.headers['x-request-id'] || '-') + '] ' + req.method + ' ' + req.originalUrl);
  next();
});
```

Y entonces las dos mitades se leen como una sola:

```
[req k3f9a2b1] GET http://localhost:3000/patients      ← consola del navegador
[mock k3f9a2b1] GET /patients                          ← terminal de Express
```

**Qué descarta.** Con el identificador, "esta petición no llegó" deja de ser una hipótesis y pasa a ser un hecho comprobable: si el id aparece en el navegador y no en el mock, la petición no llegó — y con eso vuelves a la familia de `status: 0` de la Fase 0. Si aparece en los dos y la respuesta fue `401`, el servidor la vio y la rechazó, y el siguiente sitio donde mirar es qué token recibió.

> ⚠️ **Ojo con CORS al añadir el header.** `X-Request-Id` es un header personalizado, así que convierte la petición en "no simple" y dispara un preflight `OPTIONS`. Si no lo agregas a `Access-Control-Allow-Headers` en el mock, el navegador bloquea la petición y el mensaje habla de CORS, no de tu header. Es exactamente lo que le pasa a `X-Chaos` en la Fase 4, y es la razón por la que ahí está declarado.

### Paso 5 — El experimento que separa guard de interceptor

Para fijar la diferencia, provócala. Con la aplicación logueada: Application → Local Storage → borra `lab_clinico_token` **sin recargar**. Ahora navega de `/patients` a `/orders` **por el menú**, no con el botón de recargar.

**Qué descarta.** Lo esperado es acabar en `/login` sin que salga ninguna petición: `isAuthenticated()` consulta el storage en cada navegación, no una copia en memoria, así que el guard corta antes. Si en cambio **sigues navegando como si nada**, la pantalla te está mintiendo: algo quedó cacheado donde no debería, y el sitio donde mirar no es el componente sino el guard.

Es el mismo síntoma del **incidente 05** —*"cerré sesión en una pestaña y en la otra sigo adentro"*—, provocado por tus dedos en vez de por otra pestaña.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| Vuelta al login **sin** petición previa | el guard cortó: no hay token o parece vencido | Local Storage, y `exp` a mano |
| Vuelta al login **con** un `401` | el servidor rechazó el token; el interceptor reaccionó | qué token viajó, en Request Headers |
| Te desloguea a los pocos segundos siempre | `exp` en segundos comparado contra milisegundos | `isExpired()` |
| Te desloguea sólo en una máquina | el reloj del cliente, corrido respecto del servidor | `exp` frente a la hora del mock |
| `Bearer null` en Request Headers | el interceptor no condiciona el header | el ternario del `req.clone` |
| Ningún header `Authorization` | `getToken()` devolvió `null` cuando no debía | la clave del storage: ¿es la real? |
| El guard deja pasar sin sesión | se lee `'token'` en vez de `lab_clinico_token` | todas las referencias literales a la clave |
| El primer `401` desloguea y los siguientes no | ya no hay sesión que cerrar: es el mismo camino | el orden de las acciones, no un segundo bug |
| Cualquier petición devuelve `401` a voluntad | `CHAOS=expired` de la Fase 4 | el arranque del mock |
| El breakpoint se dispara veinte veces por pantalla | falta la condición | clic derecho → *Edit breakpoint* |
| El header personalizado dispara un error de CORS | no está en `Access-Control-Allow-Headers` | el primer middleware del mock |
| El rastro dice el nombre de la persona donde debería decir el usuario | se usó `getDecodedUser()` para registrar | `getCurrentUser()` es la de registrar |

---

## ⚰️ Los callejones

**"El backend está tirando 401 por su cuenta."** Comprobable en un minuto y conviene tumbarlo pronto porque es la hipótesis que traslada el problema a otro equipo: mira **qué token viajó**, en Request Headers de esa petición, y decodifícalo. Si el `exp` ya pasó, el servidor hizo lo correcto y el bug está en que el navegador lo mandó igual.

**"Es que el token expira muy rápido."** Puede ser una decisión de configuración —y en esta fase lo es, a propósito— pero conviene distinguirla del bug de unidades. Un token que vence a los dos minutos y otro que **parece** vencido desde siempre producen la misma queja y se separan con dos líneas de consola.

**"Hay que meter refresh token."** Es el rediseño que siempre aparece en la reunión, está fuera del alcance del curso, y no diagnostica nada: si el bug es la comparación de `exp`, un refresh token lo hereda tal cual y encima añade una petición más que investigar.

**"El interceptor no está corriendo."** Se descarta antes de suponer nada: si en Request Headers hay un `Authorization`, el interceptor corrió. Si no lo hay en ninguna petición, entonces sí —y las causas son dos: se registró sin `multi: true` y otro provider lo pisó, o `CoreModule` se importó dos veces y hay dos interceptores con orden impredecible.

---

## 🧨 Deshacer

Este recorrido añade instrumentación temporal en dos archivos y toca el storage:

```bash
# 1. Las líneas de request-id del interceptor y del mock. NO se quedan:
#    ponerlas de forma permanente es una decisión de proyecto, no un hotfix.
git checkout -- src/app/core/auth/auth.interceptor.ts mock-server/server.js
```

```js
// 2. El storage, si borraste el token o pegaste basura para probar.
localStorage.removeItem('lab_clinico_token');
```

Y **quita los breakpoints condicionales** antes de seguir: Sources → panel *Breakpoints* → clic derecho → *Remove all breakpoints*. Uno olvidado en el interceptor detiene la aplicación en la siguiente investigación y parece un cuelgue.

> 📌 Si el equipo decide que el identificador de correlación se queda, eso es una decisión de proyecto con su ticket: toca el interceptor, el mock y la lista de headers permitidos de CORS. No se cuela en el commit de un hotfix.

---

## 🧠 El patrón transferible

> **Un viaje HTTP tiene dos mitades y cada una tiene su propio testigo.** El navegador sabe qué mandó; el servidor sabe qué recibió. Cuando los dos relatos no encajan, la pregunta no es cuál miente sino **cómo emparejarlos**, y emparejar por hora sólo funciona cuando no hay tráfico. Un identificador que viaje con la petición convierte una discusión entre equipos en una consulta de treinta segundos, y es lo primero que echas de menos el día que el sistema tiene volumen.

Y el segundo, que es la técnica concreta que se aprende acá: **un breakpoint sin condición en un punto de paso común no es una herramienta, es un obstáculo.** Interceptores, middlewares, reducers y guards ven todo lo que pasa por el sistema; detenerse en todo equivale a no detenerse en nada. Escribir la condición antes de poner el breakpoint es lo que separa una investigación de una tarde de pulsar F8.

**Incidentes del cuaderno que usan esta ruta:** el **05** —*"cerré sesión en una pestaña y en la otra sigo adentro"*—, que entra directo por el paso 5.
**Amplía:** [`forense-fase-04.md`](./forense-fase-04.md) para el modo `expired` y el resto de los fallos inyectables, y la [**Fase 11**](./11-trazabilidad-audit-log.md) para por qué el rastro se guarda con `getCurrentUser()` y no con el nombre de la persona.
