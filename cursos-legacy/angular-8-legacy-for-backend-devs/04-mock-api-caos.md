# 🧪 Fase 04 — Mock API + caos

> Tutorial Angular 8 — Laboratorio clínico · Fase 4 de 14 · **6 horas**
> Depende de: Fase 1 — Estructura base + NgRx · Fase 2 — Internacionalización · Fase 3 — Autenticación mínima
> Habilita: Fases 5-12
> Apéndices de apoyo: [A03 (Node y npm)](./a03-node-npm.md) · [A05 (RxJS de supervivencia)](./a05-rxjs.md) · [A02 (Bootstrap 4 + Sass)](./a02-bootstrap-sass.md) · [A07 (i18n en Angular 8)](./a07-i18n.md) · [Incidentes asociados](./cuaderno-incidentes.md): 06, 08

---

## 🎯 1. Propósito

Hasta acá el backend fue un santo. json-server responde en dos milisegundos, nunca falla, nunca devuelve basura, y el token que firmó la Fase 3 siempre llega a tiempo. Contra un servidor así, cualquier código parece correcto: el `catchError` del effect nunca se ejecutó, el mensaje de error nunca se pintó, y el botón de reintentar todavía no existe porque nadie lo necesitó.

El sistema que vas a mantener no vive en ese mundo. Vive en uno donde una consulta de resultados tarda ocho segundos a las once de la mañana, donde un servicio intermedio devuelve `500` una de cada diez veces sin patrón visible, y donde alguien reporta que "a veces la lista de pacientes sale vacía" y no hay forma de reproducirlo en tu máquina. Esta fase construye el servidor mentiroso que hace falta para practicar eso: un Express propio con json-server adentro y un **inyector de caos** que rompe a pedido, de forma controlada y repetible.

Lo importante es que el caos se escribe, no se instala. Escribirlo te obliga a decidir *dónde* se rompe una petición —antes de la respuesta, durante, después— y esa decisión es exactamente el mapa mental que necesitas cuando el que se rompe es un servidor real que no puedes leer.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `npm run mock` levanta **un solo proceso** en el puerto 3000 que sirve `/patients`, `/orders`, `/samples`, `/results`, `/referenceRanges` y `/login`, y la aplicación sigue funcionando sin tocar `environment.apiUrl`.
- [ ] Arrancas con `CHAOS=latency=3000 npm run mock`, abres `/patients`, y el spinner dura tres segundos medidos en la pestaña Network.
- [ ] Con `CHAOS=fail=500@100`, la pantalla de pacientes muestra el mensaje de error traducido y un botón de reintentar, y en Redux DevTools ves entrar `[Patients] Load Patients Failure` con el código adentro.
- [ ] Envías una sola petición con el header `X-Chaos: malformed` desde la consola del navegador y confirmas que esa petición sale rota y las demás no.
- [ ] Con `CHAOS=timeout`, la petición no cuelga para siempre: a los diez segundos el effect corta por su cuenta y despacha el fallo. Puedes decir qué diferencia hay en Network entre ese caso y un `500`.
- [ ] Con `CHAOS=expired`, cualquier petición autenticada devuelve `401` y la aplicación te devuelve a `/login` — el mismo camino que la Fase 3, disparado a voluntad.

---

## 🚫 3. Qué NO entra todavía

- Backend propio de verdad, con base de datos y reglas de negocio del lado del servidor. No lo va a haber: el curso es 100% frontend y el mock es descartable → fuera de alcance del proyecto.
- Paginación, ordenamiento y filtrado del lado del servidor. El `db.json` se sirve entero y quien filtra es el navegador → **Fase 5**, y con la deuda declarada ahí.
- Panel de control del caos dentro de la aplicación. Se activa por variable de entorno o por header, a mano → deuda 💸 de §5.8, y candidato a ejercicio 🔥.
- Tests del middleware de caos. Es código Node sin cobertura, igual que el resto del mock → **Fase 12**.
- El mock dentro de un contenedor. Acá corre con Node local → **Fase 13**.
- CORS roto como escenario de primera clase. Con un solo origen no se puede reproducir de verdad; se explica en §6 y se practica en el ejercicio 26, apoyado en el ejercicio 22 de la Fase 0 → se queda en ejercicio.

---

## 🧠 4. Concepto mínimo

### El problema primero

Te llega el ticket: *"la pantalla de pacientes a veces sale vacía"*. Abres la aplicación en tu máquina, entras treinta veces, y las treinta funciona. No puedes reproducirlo, así que no puedes arreglarlo, y lo que haces en la práctica es cerrar el ticket como "no reproducible" y esperar a que vuelva.

El problema no es que seas mal depurador. Es que tu entorno es **más confiable que producción** y eso te esconde la mitad de los caminos de tu propio código. El bloque de error del effect, el estado `error` del reducer, el mensaje en pantalla: todo eso existe en el repositorio y ninguna de esas líneas se ejecutó jamás en tu máquina. Son código no probado disfrazado de código escrito.

Un inyector de caos invierte la carga: hace que la falla sea la condición normal cuando tú lo decides. Deja de ser "esperemos a ver si pasa" y pasa a ser "lo enciendo, pasa siempre, lo apago, deja de pasar". Eso es lo que convierte un bug intermitente en un bug reproducible, que es el 80% del trabajo de arreglarlo.

### La herramienta: un middleware, o sea una tubería

Un servidor Express es una tubería de funciones. Cada petición entra por un extremo y va pasando por una fila de funciones —los *middlewares*— hasta que alguna decide responder. Cada una recibe la petición, la respuesta y una función `next`; si llama a `next()`, la petición sigue viajando; si responde, el viaje termina ahí.

Si vienes de backend, esto ya lo conoces: es la misma idea que una cadena de filtros de servlets, o un pipeline de middleware en cualquier framework de la última década. El paralelo aguanta bastante bien y se rompe en un punto concreto: acá no hay contenedor, ni ciclo de vida gestionado, ni orden declarado en un archivo de configuración. **El orden es literalmente el orden en que escribes las líneas**, y equivocarte de línea no produce un error, produce un middleware que no se ejecuta nunca. Ese es el error de configuración más común de todo Express y lo vas a cometer una vez en esta fase, a propósito, en el ejercicio 19.

El inyector de caos es un middleware que se pone **antes** del que sirve los datos. Cuando el caos está apagado, llama a `next()` y desaparece. Cuando está encendido, decide si esta petición en particular se rompe y cómo.

### Las cinco formas de romper, y por qué no son la misma

No sirve un "modo error" genérico. Cada forma de fallar produce un síntoma distinto en el navegador, y aprender a distinguirlos es el objetivo real de la fase.

La **latencia** no rompe nada: la respuesta llega correcta, tarde. El síntoma es un spinner largo y, si hay dos peticiones compitiendo, resultados que llegan en desorden. Es la que más bugs esconde porque el código funciona.

El **500** es la falla honesta: el servidor dice que falló, el navegador te entrega un `HttpErrorResponse` con `status: 500`, y tu `catchError` se ejecuta. Si algo se rompe acá, se rompe con nombre y apellido.

La **respuesta malformada** es la más cruel: `200 OK`, cuerpo con la forma equivocada. Ningún `catchError` se dispara porque, desde el punto de vista de HTTP, todo salió bien. El error aparece tres capas más adelante, en la plantilla, cuando algo intenta recorrer un arreglo que resultó ser un objeto. Con TS-0 y `any` en todo el store, el compilador no te va a avisar. Este es el escenario que justifica media Fase 4.

El **timeout** es la respuesta que nunca llega. El servidor recibe la petición, no responde y no cierra la conexión. En Network la petición se queda en *pending* indefinidamente. Nadie te avisa nunca, y es la causa real detrás de la mayoría de los "se queda cargando".

El **token expirado** devuelve `401` sin importar el token que le mandes. Ya tienes el camino armado desde la Fase 3; lo que faltaba era el interruptor para dispararlo cuando quieres y no cuando la vida quiere.

> 📝 **Nota de época.** En 2019 esto se hacía a mano, exactamente como acá. Hoy existen herramientas dedicadas —proxies de fallo, *service virtualization*, `msw` del lado del navegador— y en un proyecto nuevo se usarían. En un sistema de 2019 en mantenimiento, el mock que hay es el que alguien escribió, y saber leerlo vale más que saber cuál lo reemplazaría.

### Dónde corta el cliente

Hay una asimetría que conviene tener clara antes de escribir código: el servidor puede decidir no responder, pero **quien decide cuánto esperar es el cliente**. `HttpClient` no trae timeout propio; si nadie hace nada, espera lo que el navegador quiera esperar, que puede ser minutos.

Por eso el modo `timeout` del middleware necesita una contraparte en el effect: el operador `timeout(...)` de RxJS, que corta la espera y emite un error. Sin esa línea, el modo `timeout` del servidor produce una pantalla congelada y ninguna acción en el store — lo cual, dicho sea de paso, es un ejercicio excelente y por eso lo vas a ver así primero.

> 📚 Operador `timeout` (RxJS 6): https://rxjs.dev/api/operators/timeout
> 📚 Express — escribir middleware: https://expressjs.com/en/guide/writing-middleware.html

---

## 💻 5. Código mínimo con comentarios

Ocho piezas. Primero los datos, después el servidor honesto, después el que miente, y al final el cliente aprendiendo a defenderse.

> 📝 **De dónde viene el `server.js`.** La Fase 3 ya creó `mock-server/server.js` con lo mínimo: CORS a mano, `express.json()`, el login y `json-server` montado como router. Esta fase le agrega dos cosas —la bitácora y el inyector de caos— y mueve el login de lugar. El archivo se muestra completo abajo para que no tengas que reconstruirlo de memoria, pero solo los bloques 3 y 4 son nuevos.

### 5.1 `db.json` — el modelo del laboratorio

Hasta ahora el `db.json` tenía una sola colección con lo que el formulario de la Fase 0 fue dejando adentro. Acá se fija el modelo completo del dominio, con datos semilla suficientes para que las fases siguientes tengan de dónde agarrarse.

```json
{
  "patients": [
    { "id": 1, "documentId": "CC-1032456789", "fullName": "Marcela Ríos", "birthDate": "1984-03-12", "email": "marcela.rios@example.com" },
    { "id": 2, "documentId": "CC-1098765432", "fullName": "Julián Prada", "birthDate": "1991-11-02", "email": "julian.prada@example.com" },
    { "id": 3, "documentId": "TI-1122334455", "fullName": "Deisy Cárdenas", "birthDate": "2009-07-25", "email": null }
  ],
  "orders": [
    { "id": 101, "patientId": 1, "status": "pending", "createdAt": "2019-09-02T08:15:00-05:00", "dueAt": "2019-09-04T08:15:00-05:00", "testCodes": ["CBC", "GLU"] },
    { "id": 102, "patientId": 2, "status": "in_process", "createdAt": "2019-09-02T09:40:00-05:00", "dueAt": "2019-09-05T09:40:00-05:00", "testCodes": ["GLU"] },
    { "id": 103, "patientId": 1, "status": "expired", "createdAt": "2019-08-20T07:00:00-05:00", "dueAt": "2019-08-22T07:00:00-05:00", "testCodes": ["TSH"] }
  ],
  "samples": [
    { "id": 501, "orderId": 101, "status": "received", "collectedAt": "2019-09-02T10:05:00-05:00", "collectedBy": "analista1" },
    { "id": 502, "orderId": 102, "status": "scheduled", "collectedAt": null, "collectedBy": null }
  ],
  "results": [
    { "id": 9001, "sampleId": 501, "analyte": "glucose", "value": 118, "unit": "mg/dL", "status": "preliminary", "validatedBy": null, "validatedAt": null, "rangeVersionApplied": null },
    { "id": 9002, "sampleId": 501, "analyte": "tsh", "value": 4.1, "unit": "mUI/L", "status": "validated", "validatedBy": "supervisor1", "validatedAt": "2019-09-02T14:20:00-05:00", "rangeVersionApplied": 1 }
  ],
  "referenceRanges": [
    { "id": 1, "analyte": "glucose", "version": 1, "unit": "mg/dL", "low": 70, "high": 110, "criticalLow": 50, "criticalHigh": 250, "effectiveFrom": "2019-01-01T00:00:00-05:00", "effectiveTo": "2019-05-31T23:59:59-05:00" },
    { "id": 2, "analyte": "glucose", "version": 2, "unit": "mg/dL", "low": 70, "high": 100, "criticalLow": 50, "criticalHigh": 250, "effectiveFrom": "2019-06-01T00:00:00-05:00", "effectiveTo": null },
    { "id": 3, "analyte": "tsh", "version": 1, "unit": "mUI/L", "low": 0.4, "high": 4.0, "criticalLow": 0.1, "criticalHigh": 20, "effectiveFrom": "2019-01-01T00:00:00-05:00", "effectiveTo": null }
  ]
}
```

**Detalles con intención**

- Todo en inglés, incluidos los valores de `status`. Son identificadores del sistema, no textos de interfaz: lo que ve el usuario sale de una clave de traducción que mapea `orders.status.inProcess`.
- **Los estados salen del flujo canónico y de ningún otro sitio.** Una orden vive en `pending → in_process → partial_results → complete → delivered → expired`, y una muestra en `scheduled → collected → received → in_process → processed → discarded`. Los dos flujos comparten la palabra `in_process` y no significan lo mismo: una orden en proceso es una a la que ya se le tomó algo, una muestra en proceso está dentro del analizador. Que se llamen igual es una decisión de LabCore que vas a mantener, y es una fuente de confusión real en los tickets.
- Las fechas llevan **offset explícito** (`-05:00`), no `Z` ni fecha suelta. La Fase 2 fijó `America/Bogota` como zona de la aplicación y la Fase 8 va a comparar fechas de verdad; una fecha sin zona guardada hoy es un incidente dentro de tres fases.
- El paciente 3 tiene `email: null` y la orden 103 está `expired`. No son datos de relleno: son los casos borde que las fases siguientes necesitan para tener algo que romper.
- **Un resultado se identifica por `analyte`, no por el `testCode` de la orden**, y son dos vocabularios distintos a propósito: la orden pide un examen (`GLU`, el código que usa quien la crea) y el resultado mide un analito (`glucose`, lo que el aparato reporta). En un laboratorio de verdad un examen puede arrojar varios analitos, y esa asimetría es la razón de que los rangos de referencia cuelguen del segundo y no del primero.
- `referenceRanges` ya trae **dos versiones del mismo analito**, con ventana de vigencia cerrada la primera y abierta la segunda. La glucosa pasa de un techo de 110 a uno de 100 el 1 de junio de 2019, así que un mismo valor de 105 cae dentro o fuera según la fecha del resultado. La **Fase 8 vive de eso**; acá solo se sirve.
- El resultado 9002 nace `validated` y con su `rangeVersionApplied` puesto, que es como tiene que verse un resultado firmado (Fase 8 §5.6). El 9001 está `preliminary` y por eso los tres campos de validación van en `null`.
- Solo `patients` tiene store en esta fase. Las demás colecciones existen como datos y nada más.

> **Nota de continuidad (editada desde las Fases 6 y 8).** Este `db.json` sembraba
> las órdenes con `created` y `collected` —dos valores que no pertenecen al flujo
> canónico de una orden; el segundo es, de hecho, un estado **de muestra**— y
> modelaba los resultados con `testCode` y `rangeVersion`, mientras que la Fase 8
> los genera con `analyte` y `rangeVersionApplied` y añade `status`, `criticalLow`,
> `criticalHigh` y `effectiveTo`. Como la Fase 8 sobrescribe las dos colecciones,
> en la práctica funcionaba — pero esta fase pasaba cuatro capítulos anunciando "el
> modelo completo del dominio" y resultaba ser otro, con las Fases 5, 6 y 7 leyéndolo
> en medio. Se normaliza aquí, que es donde el dato nace.

### 5.2 Instalar Express y fijar los scripts

```bash
npm install express@4.17.1 json-server@0.16.3 jsonwebtoken@8.5.1 --save-dev
```

> 🧭 **Las tres versiones del mock, fijadas — y son las únicas del curso que no
> vienen de LabCore.** `json-server` en **0.16.3**, la que la Fase 0 ya usaba con
> `npx`. `express` en **4.17.1**, la contemporánea del stack: la rama 5 cambia el
> manejo de errores asíncronos y no la queremos. `jsonwebtoken` en **8.5.1**, la de
> la época. Ninguna de las tres entra al bundle de Angular —van en
> `devDependencies`— y ninguna de las tres existe en LabCore: **el mock es
> andamiaje pedagógico**, código que este curso escribe para tener contra qué
> trabajar y que desaparece el día que el proyecto se cierre. Es la distinción que
> conviene tener presente cada vez que una fase diga "así lo hace LabCore": del
> `mock-server/` para adentro, no lo hace.

En `package.json`:

```json
{
  "scripts": {
    "start": "ng serve",
    "mock": "node mock-server/server.js",
    "mock:chaos": "node mock-server/server.js"
  }
}
```

Los dos scripts apuntan al mismo archivo a propósito. `mock:chaos` existe para que lo edites tú con la combinación de caos que estés practicando; en Windows la sintaxis `CHAOS=... node ...` no funciona en `cmd`, así que ahí se usa `set CHAOS=...` en una línea aparte o `cross-env` si el equipo lo tiene. El apéndice A03 cubre la diferencia.

El mock **no** se agrega a `npm start`. Son dos procesos y dos terminales, y eso es deliberado: cuando el estudiante apague el mock a mano para el ejercicio 5, tiene que ser evidente qué apagó.

### 5.3 `mock-server/server.js` — el servidor honesto

```javascript
// mock-server/server.js
// Servidor único del curso. Express es el anfitrion y json-server va adentro
// como router, no como proceso aparte: así hay un solo puerto, un solo origen
// y un solo lugar donde meter el caos.
const express = require('express');
const jsonServer = require('json-server');
const path = require('path');

const { login } = require('./auth');
const { chaosMiddleware } = require('./chaos/chaos.middleware');

const PORT = 3000;

const app = express();

// 1. CORS. La aplicación corre en 4200 y el mock en 3000: son origenes
// distintos y sin estas cabeceras el navegador bloquea todo antes de que
// nuestro código se entere. Se escribe a mano en vez de usar la librería
// "cors" para que el modo de caos pueda quitarlas después.
app.use(function (req, res, next) {
  res.header('Access-Control-Allow-Origin', 'http://localhost:4200');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Chaos');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');

  // El preflight se responde acá y no sigue viajando. Si lo dejaras pasar al
  // middleware de caos, un OPTIONS con latencia de tres segundos retrasaría
  // cada petición el doble y el síntoma sería imposible de explicar.
  if (req.method === 'OPTIONS') {
    res.sendStatus(204);
    return;
  }

  next();
});

// 2. Parseo del cuerpo. Sin esto, req.body es undefined en el login y el
// error que ves es "no se puede leer username de undefined", que apunta al
// lugar equivocado.
app.use(express.json());

// 3. Bitácora mínima. Una línea por petición, con el modo de caos activo si
// lo hay. Es lo primero que vas a mirar cuando algo no cuadre.
app.use(function (req, res, next) {
  const chaosHeader = req.headers['x-chaos'] || process.env.CHAOS || '-';
  console.log('[mock] ' + req.method + ' ' + req.originalUrl + ' | chaos: ' + chaosHeader);
  next();
});

// 4. El inyector de caos. Va DESPUÉS del log (queremos ver hasta lo que se
// rompe) y ANTES de todo lo que responde datos, incluido el login.
//
// La Fase 3 dejó el login registrado antes del caos y anotó que la Fase 4
// decidiría si eso cambia. Cambia: el modo "expired" no tiene sentido si el
// login es inmune, y un login lento es justo el síntoma que más se reporta.
app.use(chaosMiddleware);

// 5. El login, con el mismo auth.js de la Fase 3, sin tocar una línea.
// Lo único que cambio respecto de la Fase 3 es su posición: bajo dos líneas,
// de arriba del caos a abajo. Nada más.
app.post('/login', login);

// 6. json-server al final, sirviendo todo lo demás desde db.json.
// El router lee el archivo una vez al arrancar y mantiene el estado en
// memoria; los cambios se escriben de vuelta al archivo.
const router = jsonServer.router(path.join(__dirname, '..', 'db.json'));
app.use(router);

app.listen(PORT, function () {
  console.log('[mock] escuchando en http://localhost:' + PORT);
  if (process.env.CHAOS) {
    console.log('[mock] caos global activo: ' + process.env.CHAOS);
  }
});
```

**Detalles con intención**

- El orden de los seis bloques **es** la lógica del archivo. Mueves el caos debajo de `router` y deja de ejecutarse sin un solo error: json-server responde y termina el viaje antes. Ese es el ejercicio 19.
- CORS escrito a mano y no con la librería `cors`. Es más código, pero es el único modo de que un modo de caos pueda quitar la cabecera; con la librería habría que desmontarla.
- El preflight se corta en el bloque 1. Es la línea que más gente omite y la que produce "solo fallan las peticiones con `Authorization`", porque un `GET` simple no dispara preflight y uno con header personalizado sí.
- `X-Chaos` está declarado en `Allow-Headers`. Si se te olvida, el navegador rechaza la petición con caos por header y el mensaje habla de CORS, no de tu header.

### 5.4 `mock-server/chaos/chaos-config.js` — leer la intención

```javascript
// mock-server/chaos/chaos-config.js
// Traduce la cadena de configuración del caos a un objeto. La cadena puede
// venir de la variable de entorno CHAOS (global, para toda la sesión) o del
// header X-Chaos (por petición). El header pisa a la variable.
//
// Formato: modos separados por coma.
//   latency=2000     -> demora fija en milisegundos
//   fail=500@30      -> devuelve 500 en el 30% de las peticiones
//   malformed        -> responde 200 con el cuerpo con la forma equivocada
//   timeout          -> no responde nunca
//   expired          -> devuelve 401 como si el token estuviera vencido
//   nocors           -> responde sin la cabecera Access-Control-Allow-Origin

function parseChaos(rawValue) {
  // any implícito: esto es Node sin TypeScript. La forma del objeto que
  // devuelve esta función es un contrato tácito con el middleware, y el
  // día que alguien agregue un modo y se olvide de un campo, nadie avisa.
  const config = {
    latency: 0,
    failStatus: 0,
    failRate: 0,
    malformed: false,
    timeout: false,
    expired: false,
    nocors: false
  };

  if (!rawValue) {
    return config;
  }

  const parts = String(rawValue).split(',');

  parts.forEach(function (rawPart) {
    const part = rawPart.trim();

    if (part.indexOf('latency=') === 0) {
      config.latency = parseInt(part.split('=')[1], 10) || 0;
      return;
    }

    if (part.indexOf('fail=') === 0) {
      // "500@30" -> status 500, 30 por ciento. Sin @ se asume 100%.
      const spec = part.split('=')[1];
      const pieces = spec.split('@');
      config.failStatus = parseInt(pieces[0], 10) || 500;
      config.failRate = pieces.length > 1 ? parseInt(pieces[1], 10) : 100;
      return;
    }

    if (part === 'malformed') { config.malformed = true; return; }
    if (part === 'timeout') { config.timeout = true; return; }
    if (part === 'expired') { config.expired = true; return; }
    if (part === 'nocors') { config.nocors = true; return; }

    // Un modo desconocido se ignora en silencio. Es una decisión mala a
    // propósito: escribe "latencia=2000" en vez de "latency=2000" y el
    // servidor arranca contento sin caos. El ejercicio 21 lo arregla.
  });

  return config;
}

// El header gana sobre la variable de entorno. Así puedes tener el servidor
// entero sano y romper una sola petición desde la consola del navegador.
function resolveChaos(req) {
  const headerValue = req.headers['x-chaos'];
  if (headerValue) {
    return parseChaos(headerValue);
  }
  return parseChaos(process.env.CHAOS);
}

module.exports = { parseChaos: parseChaos, resolveChaos: resolveChaos };
```

**El patrón a memorizar:** cuando una configuración se puede leer de dos lugares, lo primero que hay que documentar no es el formato sino **la precedencia**. La mitad de los incidentes de configuración de cualquier sistema son dos fuentes de verdad sin un orden escrito entre ellas. En la Fase 13 vas a ver esta misma frase, con nginx y variables de entorno en vez de un header.

### 5.5 `mock-server/chaos/chaos.middleware.js` — el que miente

```javascript
// mock-server/chaos/chaos.middleware.js
// El inyector de fallos. Es una sola función de middleware que decide, por
// petición, si la deja pasar intacta o la rompe y como.
const { resolveChaos } = require('./chaos-config');

// Cuerpo con la forma equivocada. Devuelve un objeto donde el cliente
// espera un arreglo: es el error más caro de diagnosticar del curso porque
// HTTP dice 200 y nadie sospecha del servidor.
function malformedBody() {
  return {
    data: {
      items: 'no-soy-un-arreglo'
    },
    total: null
  };
}

function chaosMiddleware(req, res, next) {
  const config = resolveChaos(req);

  // Modo nocors: quita la cabecera que puso el primer middleware. La
  // respuesta sale bien formada del servidor y el navegador la descarta
  // igual, que es justo lo que la hace confusa.
  if (config.nocors) {
    res.removeHeader('Access-Control-Allow-Origin');
  }

  // Modo timeout: no se responde y no se llama a next(). La conexión queda
  // abierta hasta que alguien se canse. Nadie del lado del servidor va a
  // registrar nunca que esta petición existió más allá del log de arriba.
  if (config.timeout) {
    return;
  }

  // La latencia envuelve al resto: primero se espera, después se decide.
  // Si fuera al revés, un 500 con latencia saldría instantáneo y el
  // escenario "el servidor tarda y además falla" no se podría reproducir.
  setTimeout(function () {

    if (config.expired) {
      // Mismo contrato de error que el auth.js de la Fase 3, para que el
      // interceptor no tenga que distinguir de donde vino el 401.
      res.status(401).json({ message: 'Token expirado' });
      return;
    }

    if (config.failStatus && rollsAgainst(config.failRate)) {
      res.status(config.failStatus).json({
        message: 'Fallo inyectado por el middleware de caos',
        chaos: true
      });
      return;
    }

    if (config.malformed) {
      // 200 a propósito. El status miente y el cuerpo también.
      res.status(200).json(malformedBody());
      return;
    }

    // Sin ningun modo activo, la petición sigue su viaje intacta.
    next();

  }, config.latency);
}

// Devuelve true el porcentaje de las veces indicado. Con rate 100 siempre
// devuelve true; con 0, nunca.
function rollsAgainst(ratePercent) {
  if (!ratePercent) {
    return false;
  }
  return Math.random() * 100 < ratePercent;
}

module.exports = { chaosMiddleware: chaosMiddleware };
```

**Detalles con intención**

- El orden de los `if` dentro del `setTimeout` define la precedencia entre modos. `expired` gana sobre `fail`, y `fail` sobre `malformed`. No es la única opción razonable; es la que está escrita, y por eso está comentada. Un middleware de caos con precedencias implícitas es un generador de bugs propios.
- `setTimeout` con `config.latency` en cero se ejecuta igual, en el siguiente ciclo del *event loop*. No hay rama especial para "sin latencia" y eso mantiene una sola ruta de código.
- El modo `timeout` hace `return` sin `next()` y sin responder. Es la única línea del archivo que rompe la regla implícita de todo middleware —siempre responde o sigue— y por eso vale la pena mirarla dos veces. Node no se queja: simplemente hay un socket abierto y una promesa que nadie va a cumplir.
- `Math.random()` significa que `fail=500@30` **no es reproducible**. Es a propósito: los bugs intermitentes de producción tampoco lo son. El ejercicio 30 pide hacerlo determinista y explicar qué se pierde.

### 5.6 `patients.effects.ts` — el cliente aprende a esperar menos

El effect de la Fase 1 ya tenía `catchError` en el lugar correcto. Le faltaban dos cosas: un límite de espera propio y un error legible.

```typescript
// src/app/patients/store/patients.effects.ts
import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { map, switchMap, catchError, timeout } from 'rxjs/operators';

import { PatientsService } from '../patients.service';
import * as PatientsActions from './patients.actions';

// Cuanto esperamos antes de darnos por vencidos. Diez segundos es mucho para
// un mock y poco para un reporte pesado de LabCore: el número correcto
// depende del endpoint, y tenerlo acá, global y único, ya es una decisión
// discutible que LabCore también tomó.
const REQUEST_TIMEOUT_MS = 10000;

@Injectable()
export class PatientsEffects {

  constructor(
    private actions$: Actions,
    private patientsService: PatientsService
  ) { }

  loadPatients$ = createEffect(function (this: PatientsEffects) {
    return this.actions$.pipe(
      ofType(PatientsActions.loadPatients),

      switchMap(() => {
        return this.patientsService.getPatients().pipe(

          // timeout va DENTRO del switchMap, por la misma razón que
          // catchError: si el límite se dispara, el error tiene que morir
          // acá adentro y no matar el flujo de acciones.
          timeout(REQUEST_TIMEOUT_MS),

          map(function (patients: any) {
            return PatientsActions.loadPatientsSuccess({ patients: patients });
          }),

          catchError(function (error: any) {
            // El error se traduce a algo que el reducer pueda guardar y la
            // plantilla pueda mostrar. Guardar el HttpErrorResponse crudo en
            // el store funciona, pero mete un objeto enorme y no serializable
            // en DevTools, y el día que lo mires no vas a encontrar nada.
            return of(PatientsActions.loadPatientsFailure({
              error: describeError(error)
            }));
          })
        );
      })
    );
  }.bind(this));
}

// Traduce el error de HttpClient a una clave de traducción y un código.
// Vive fuera de la clase porque no depende de nada inyectado.
// TS-0: recibe any porque puede llegar un HttpErrorResponse, un TimeoutError
// o cualquier cosa que alguien lance más adelante.
export function describeError(error: any): any {
  // TimeoutError de RxJS no trae status: es el único caso donde el error
  // nació del lado del cliente y el servidor sigue tan tranquilo.
  if (error && error.name === 'TimeoutError') {
    return { code: 'TIMEOUT', status: 0, messageKey: 'errors.networkDown' };
  }

  // status 0 significa que la petición nunca llegó a un servidor: conexión
  // rechazada, DNS o CORS. Es la firma que viste en la Fase 0.
  if (error && error.status === 0) {
    return { code: 'NETWORK', status: 0, messageKey: 'errors.networkDown' };
  }

  if (error && error.status === 401) {
    // El interceptor de la Fase 3 ya se encarga de desloguear; acá solo
    // dejamos rastro para que la acción en DevTools cuente la historia.
    return { code: 'UNAUTHORIZED', status: 401, messageKey: 'errors.loadFailed' };
  }

  return {
    code: 'HTTP_' + (error && error.status ? error.status : 'UNKNOWN'),
    status: error && error.status ? error.status : -1,
    messageKey: 'errors.loadFailed'
  };
}
```

**Detalles con intención**

- El error que llega al store es un objeto chico y serializable con tres campos. En Redux DevTools eso se lee de un vistazo; un `HttpErrorResponse` completo, no.
- `messageKey` es una **clave de traducción**, no un texto. La plantilla la pasa por el pipe. Las claves `errors.loadFailed` y `errors.networkDown` ya existen desde la Fase 2 — y en `fr.json` la rama `errors` entera falta, que es exactamente el ejercicio 24.
- Fíjate en lo que **no** hace el effect: no muestra nada, no navega, no decide. Convierte una falla en un hecho registrado. Quien decide qué se ve es la plantilla.

> 💸 **Deuda técnica intencional: el timeout es una constante global del effect.** Lo correcto hoy sería configurarlo por endpoint —una consulta de lista y una generación de informe no tienen el mismo presupuesto de espera— idealmente en un interceptor que lea el valor de `environment` o de la propia petición. **En Track A no se paga:** LabCore tiene el número escrito a mano en varios effects, con valores distintos entre sí y ninguno documentado. Cambiar eso significa decidir un presupuesto de espera para cada uno de los endpoints, que es una conversación de producto y no un hotfix. Lo que sí haces es reconocer el patrón: cuando alguien reporte "se cayó a los diez segundos exactos", busca una constante, no un servidor.

### 5.7 `patient-list.component` — la pantalla deja de mentir

Hasta acá, cuando la carga fallaba, la lista quedaba simplemente vacía. Y "vacía" y "rota" se ven idénticas.

```typescript
// src/app/patients/patient-list/patient-list.component.ts (fragmento)
// Solo lo que cambia. El resto del componente sigue como lo dejó la Fase 1.
export class PatientListComponent implements OnInit {

  patients: any[] = [];
  loading = false;
  loadError: any = null;   // any: es el objeto que arma describeError()

  constructor(private store: Store<any>) { }

  ngOnInit() {
    // Tres suscripciones a pelo, sin async pipe. Es el estilo del sistema
    // real y la Fase 12 va a sufrirlo cuando toque testear esto.
    this.store.select(selectAllPatients).subscribe(function (this: PatientListComponent, items) {
      this.patients = items;
    }.bind(this));

    this.store.select(selectPatientsLoading).subscribe(function (this: PatientListComponent, loading) {
      this.loading = loading;
    }.bind(this));

    this.store.select(selectPatientsError).subscribe(function (this: PatientListComponent, error) {
      this.loadError = error;
    }.bind(this));

    this.store.dispatch(PatientsActions.loadPatients());
  }

  // El reintento es un dispatch de la misma acción de carga. No hay acción
  // "retry" propia: para el store, reintentar y cargar por primera vez son
  // el mismo evento. Eso tiene una consecuencia que vas a ver en DevTools,
  // y es que el log no distingue una carga inicial de un reintento número
  // ocho. El ejercicio 27 la aprovecha.
  retryLoad() {
    this.store.dispatch(PatientsActions.loadPatients());
  }
}
```

El selector `selectPatientsError` no existía. Se agrega a `patients.selectors.ts`:

```typescript
// src/app/patients/store/patients.selectors.ts (fragmento nuevo)
export const selectPatientsError = createSelector(
  selectPatientsState,
  function (state) { return state.error; }
);
```

Y la plantilla, con los tres estados excluyentes bien separados:

```html
<!-- src/app/patients/patient-list/patient-list.component.html (fragmento) -->

<!-- Cargando. Nada más se pinta mientras tanto. -->
<div class="text-center my-4" *ngIf="loading">
  <mat-spinner diameter="40" class="mx-auto"></mat-spinner>
</div>

<!-- Error. Va antes de la lista y antes del vacío: si hubo error, lo que
     importa es el error, no que la lista esté vacía por consecuencia. -->
<div class="alert alert-warning" *ngIf="!loading && loadError">
  <p>{{ loadError.messageKey | translate }}</p>

  <!-- El código técnico se muestra a propósito. Un usuario que reporta
       "salió HTTP_500" te ahorra media hora; uno que reporta "salió un
       error" no te ahorra nada. -->
  <small class="text-muted">{{ loadError.code }}</small>

  <button mat-stroked-button color="primary" (click)="retryLoad()">
    {{ 'patients.retry' | translate }}
  </button>
</div>

<!-- Vacío de verdad: sin error y sin datos. -->
<p *ngIf="!loading && !loadError && patients.length === 0">
  {{ 'patients.empty' | translate }}
</p>
```

**El patrón a memorizar:** cargando, error, vacío y con datos son **cuatro** estados, no dos. La mayoría de las pantallas legacy tienen dos (`*ngIf="items.length"` y nada más) y por eso todo fallo se ve igual que un resultado sin registros. Cuando te llegue un ticket que dice "no aparece nada", la primera pregunta es cuántos estados sabe pintar esa pantalla.

### 5.8 La deuda de esta fase

> 💸 **Deuda técnica intencional: el caos se configura por header global y variable de entorno, sin panel.** Para encender un modo hay que reiniciar el proceso con otra variable, o abrir la consola del navegador y armar una petición a mano con `fetch`. No hay pantalla, no hay interruptor, no queda registro de qué modo estaba activo cuando algo se rompió.
>
> **Lo correcto hoy** sería un panel de desarrollo dentro de la aplicación —una ruta `/dev/chaos` visible solo cuando `environment.production` es falso— con casillas por modo, que escriba el header vía interceptor y muestre el estado activo en un rincón de la pantalla. Con eso, el modo activo sería siempre visible y nadie perdería veinte minutos depurando un bug que él mismo encendió hace una hora.
>
> **En Track A no se paga**, por dos razones. La primera es de alcance: ese panel es código de aplicación, con su ruta, su módulo, su interceptor y su estado, y todo eso viaja al bundle salvo que alguien monte una exclusión de build. Es una feature completa para una herramienta de desarrollo. La segunda es más importante: LabCore **no tiene inyector de caos en absoluto**. El caos allá se llama "producción". Este middleware es andamiaje pedagógico y va a desaparecer del proyecto de curso el día que se cierre; construirle una interfaz sería invertir en algo que ya sabemos que no sobrevive.
>
> Lo que sí te llevas: la costumbre de preguntar *"¿qué tenía yo encendido cuando esto falló?"* antes de empezar a leer código.

> **Prueba de fuego.** En una terminal, `CHAOS=fail=500@100 npm run mock`. En la otra, `npx ng serve`. Entra a `/patients`. Vas a ver el mensaje de error con su código y el botón de reintentar; en Network, un `500` en rojo; y en Redux DevTools, la secuencia `[Patients] Load Patients` seguida de `[Patients] Load Patients Failure` con `{ code: 'HTTP_500', status: 500, messageKey: 'errors.loadFailed' }` adentro. Pulsa reintentar tres veces y mira cómo el log acumula tres pares idénticos. Después, sin apagar nada, cambia la variable a `CHAOS=latency=4000`, reinicia el mock y vuelve a reintentar: el mismo botón, otro síntoma, cero cambios en el código de Angular.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**El middleware de caos no hace nada.**
Síntoma: enciendes `CHAOS=fail=500@100`, recargas, y todo funciona perfecto. El log del mock imprime la línea con `chaos: fail=500@100`.
Causa: casi siempre el orden. `app.use(chaosMiddleware)` quedó después de `app.use(router)`, y json-server respondió antes de que el caos existiera. La segunda causa en frecuencia es un modo mal escrito (`latencia=` en vez de `latency=`), que el parser ignora en silencio.
Fix mínimo: subir la línea del middleware por encima del router.
Refactor correcto: que `parseChaos` falle ruidosamente ante un modo desconocido, en vez de ignorarlo. Es el ejercicio 21.

**Con `CHAOS=timeout` la aplicación se congela y no pasa nada en DevTools.**
Síntoma: el spinner gira para siempre, no hay error en consola, no entra ninguna acción al store.
Causa: es el comportamiento esperado si el effect no tiene el operador `timeout`. El servidor no responde nunca y `HttpClient` espera indefinidamente.
Fix mínimo: agregar `timeout(REQUEST_TIMEOUT_MS)` dentro del `switchMap`.
Refactor correcto: un interceptor que aplique el límite a todas las peticiones de una vez, con posibilidad de sobreescribirlo por petición. No se hace acá — está declarado como deuda en §5.6.

**La petición con `X-Chaos` falla con un error de CORS y las otras no.**
Síntoma: desde la consola del navegador mandas un `fetch` con el header y el navegador lo bloquea hablando de CORS, aunque el mismo endpoint sin header funciona.
Causa: `X-Chaos` no está en `Access-Control-Allow-Headers`. Un header personalizado convierte la petición en "no simple" y dispara un preflight `OPTIONS`; el servidor tiene que declarar explícitamente que acepta ese header.
Fix mínimo: agregarlo a la lista del bloque 1 de `server.js`.
Refactor correcto: el mismo. Lo que se aprende es que el preflight existe y que la lista de headers permitidos es una lista blanca, no un adorno.

**La lista sale vacía sin ningún error, y el mock respondió 200.**
Síntoma: `CHAOS=malformed` activo, pantalla vacía, cero errores en consola, `catchError` sin ejecutar.
Causa: el cuerpo tiene la forma equivocada. El reducer guardó un objeto donde el estado espera un arreglo, `patients.length` es `undefined`, y `*ngIf` lo trata como falso.
Fix mínimo: ninguno del lado del cliente que sea honesto. El bug está en el servidor.
Refactor correcto: validar la forma de la respuesta en el effect antes de despachar el éxito. Es lo que `strict` y una interfaz `Patient` real harían gratis, y es la tesis del ejercicio 🔥 de migración a TS-1.

### Pieza forense de esta fase

La pieza es **qué acción se despacha cuando el backend devuelve 500**, y se desarrolla completa en [`forense-fase-04.md`](./forense-fase-04.md). Acá va lo justo para saber qué vas a encontrar.

La idea central es que el store convierte un evento del mundo exterior en un registro con nombre y momento. Un `500` en Network es un dato que se pierde cuando cierras la pestaña; `[Patients] Load Patients Failure` con su carga útil es un dato que queda en el log de acciones, ordenado respecto de todo lo demás que pasó. Cuando reconstruyas un incidente a partir de un reporte de usuario, no vas a tener su pestaña Network — vas a tener, con suerte, la secuencia de acciones. Aprender a que esa secuencia cuente la historia completa es una decisión que se toma al escribir el `catchError`, no al depurar.

**Rompe a propósito y observa.** Arranca con `CHAOS=malformed` y abre `/patients`.

En la pantalla vas a ver la lista vacía, con el mensaje de "no hay pacientes registrados". En Network, un `200 OK` verde y un cuerpo de respuesta que, si lo abres, no se parece en nada a un arreglo de pacientes. En la consola, silencio absoluto. Y en Redux DevTools, `[Patients] Load Patients Success` — **éxito**, con un objeto raro en la carga útil.

La mentira que te cuenta la pantalla es que no hay pacientes. La mentira que te cuenta el store es que la carga salió bien. La única capa que no miente es el cuerpo de la respuesta en Network, y llegar hasta ahí exige haber descartado antes las otras dos. Ese descarte —pantalla, store, red, en ese orden y con esa desconfianza— es el reflejo que entrena esta fase.

Compara ese caso con `CHAOS=fail=500@100`, donde el store dice `Failure` y todo el mundo dice la verdad. La diferencia entre ambos escenarios no es la gravedad: es que uno se diagnostica en dos minutos y el otro en dos horas, y lo único que los separa es que el servidor tuvo la decencia de admitir que falló.

Los **incidentes 06 y 08** del cuaderno viven de esta fase: uno es un endpoint que responde bien pero con la forma equivocada, y el otro es un intermitente que solo aparece con el mock lento.

> 📝 **Por qué 06 y 08, y no 06 y 07.** El 07 ya estaba asignado a la Fase 8 antes de que se escribiera esta fase, y la regla del cuaderno es que **el ID nunca se reasigna**: los IDs viven en los mensajes de commit, así que renumerar rompería hacia atrás el `git log`, que es el changelog del cuaderno. El número es secuencial global y no codifica la fase; la fase vive en la columna del índice, que sí se puede corregir sin costo.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Levanta el mock con `npm run mock` y pide `http://localhost:3000/patients` desde el navegador, sin la aplicación. Anota cuántos registros devuelve y cuánto tardó según Network.
2. Agrega un cuarto paciente al `db.json` a mano, recarga `/patients` sin reiniciar el mock y anota si aparece. Explica qué implica eso sobre cuándo lee json-server el archivo.
3. Arranca con `CHAOS=latency=3000` y mide en Network cuánto tarda la petición de pacientes. Compara el número con el que configuraste y explica la diferencia.
4. Con `CHAOS=fail=500@100`, captura la pantalla, el renglón de Network y la acción de DevTools. Pega las tres cosas en tu cuaderno.
5. Apaga el mock con `Ctrl+C` con la aplicación abierta y pulsa reintentar. Anota el `code` que aparece en pantalla y por qué no es `HTTP_500`.
6. Con `CHAOS=expired`, entra a `/patients` y describe la secuencia completa hasta que vuelves a `/login`.
7. Cambia `REQUEST_TIMEOUT_MS` a 2000, arranca con `CHAOS=latency=5000` y anota qué `code` llega al store.
8. Lee el log del mock durante una carga de `/patients` y cuenta cuántas líneas imprime. Explica de dónde sale cada una.

**🟡 Intermedio (9–17)**

9. Agrega un modo `slowfirst` que aplique latencia solo a la primera petición de cada sesión del servidor y responda normal el resto. Documenta dónde guardaste el estado y por qué eso hace el modo no reproducible entre reinicios.
10. Haz que el modo `fail` devuelva `503` en vez de `500` usando solo la cadena de configuración, sin tocar código. Confirma en el store que el `code` cambió.
11. Desde la consola del navegador, manda un `fetch` a `/patients` con el header `X-Chaos: malformed` y confirma que esa petición sale rota y que recargar la aplicación sigue funcionando bien.
12. Agrega `orders` al `db.json` con una orden más y confirma que `http://localhost:3000/orders?patientId=1` devuelve solo las de ese paciente. Anota qué te da json-server gratis y qué no.
13. Mueve `app.use(express.json())` **después** del `app.post('/login', ...)`. Intenta iniciar sesión y anota el error exacto, del lado del servidor y del lado del navegador. Restáuralo.
14. Agrega al log del mock el tiempo que tardó cada petición en responder. Confirma que el número coincide con la latencia inyectada.
15. Haz que el modo `malformed` devuelva un arreglo de objetos con los campos renombrados (`name` en vez de `fullName`). Anota qué se ve en pantalla y por qué es peor que el objeto de `malformedBody()`.
16. Agrega la clave `errors.chaosInjected` a los tres árboles de i18n y úsala cuando `error.code` empiece con `HTTP_5`. Confirma que el francés no se rompe.
17. Escribe un segundo script de npm que levante el mock con `CHAOS=latency=1500,fail=500@20` y funcione en Windows sin `cross-env`. Anota qué tuviste que cambiar.

**🟠 Difícil (18–24)**

18. **Diagnóstico.** Te entregan el proyecto con `timeout(REQUEST_TIMEOUT_MS)` puesto **fuera** del `switchMap`. Arranca con `CHAOS=timeout`, espera el corte, apaga el caos y pulsa reintentar. Documenta la secuencia de acciones y explica por qué el reintento no hace nada nunca más.
19. **Diagnóstico.** Mueves `app.use(chaosMiddleware)` debajo de `app.use(router)`. El reporte dice "el inyector de caos dejó de funcionar después de que alguien tocó el mock". Reproduce, localiza y escribe el post-mortem de tres líneas.
20. **Diagnóstico.** Con `CHAOS=malformed`, un compañero afirma que "el bug está en el reducer porque el estado queda mal". Reproduce, y escribe el argumento de dos líneas que lo convence de que el reducer hizo exactamente lo que le pidieron.
21. Haz que `parseChaos` falle ruidosamente ante un modo desconocido: que el servidor no arranque si `CHAOS` trae basura, pero que un header con basura solo devuelva `400`. Explica por qué el trato es distinto en cada caso.
22. **Diagnóstico.** Alguien quitó `X-Chaos` de `Access-Control-Allow-Headers`. El reporte dice "las peticiones con caos por header fallan con error de CORS, las normales andan". Reproduce y explica qué papel juega el preflight `OPTIONS` en el síntoma.
23. **Diagnóstico.** Arranca con `CHAOS=fail=500@30` y entra a `/patients` diez veces seguidas. Documenta cuántas fallaron y escribe el ticket tal como lo escribiría un analista del laboratorio, sin usar la palabra "error" ni ningún número de estado.
24. **Diagnóstico.** Con `CHAOS=fail=500@100` y el idioma en francés, la pantalla muestra `errors.loadFailed` en crudo. Explica por qué, di en qué archivo está la causa, y aplica el fix mínimo. Después, en una línea, cuál sería la prevención.

**🔴 Muy difícil (25–30)**

25. **Diagnóstico.** Sin tocar el código de Angular, consigue que la pantalla de pacientes muestre datos de un paciente que ya no existe en `db.json`. Documenta la cadena completa y en qué capa vive la copia vieja.
26. Reproduce un CORS roto de verdad. Usa el modo `nocors` y, aparte, levanta el Express de diez líneas del ejercicio 22 de la Fase 0 en el puerto 3001 apuntando `apiUrl` ahí. Documenta las diferencias entre ambos casos en Network, en consola y en el `status` que llega al store, y explica cuál de los dos se parece más a un CORS mal configurado en producción.
27. **Diagnóstico.** Con `CHAOS=latency=4000`, pulsa reintentar tres veces seguidas sin esperar. Documenta cuántas peticiones salen en Network, cuántas acciones de éxito entran al store, y qué hizo `switchMap` con las anteriores. Explica por qué el log de acciones no te deja distinguir un reintento de una carga inicial y qué agregarías para que sí.
28. **Diagnóstico.** Combina `CHAOS=latency=2000,fail=500@50` y navega entre `/patients` y `/orders` repetidamente durante un minuto. Encuentra un estado de la interfaz que sea incoherente —spinner y error a la vez, o datos viejos con mensaje de fallo— y documenta la secuencia exacta que lo produce.
29. **Diagnóstico.** Haz que el modo `expired` devuelva `401` solo en las peticiones a `/results` y no en las demás. Después, sin decirle cuál es el modo, describe el ticket que escribiría un usuario y las tres primeras cosas que mirarías tú.
30. Haz el modo `fail` determinista: que falle la petición número N de cada M en vez de al azar, con la cadena `fail=500@1of3`. Explica qué ganas para los tests y qué pierdes como entrenamiento forense.

**🔥 Opcionales**

- 🔥 Construye el panel de caos de la deuda de §5.8: una ruta `/dev/chaos` con casillas por modo y un interceptor que escriba el header. Mide cuánto crece el bundle de producción y anota si tu build lo excluyó o no.
- 🔥 Reescribe el middleware para que registre cada fallo inyectado en un archivo `chaos-log.json` con fecha, ruta y modo. Después úsalo para reconstruir una sesión de depuración completa a posteriori.
- 🔥 Agrega un modo `partial` que devuelva la mitad de los registros con `200` y una cabecera personalizada avisándolo. Anota cuántas capas del cliente ignoran esa cabecera hoy.

---

## 📚 8. Referencias

**Documentación oficial**

- https://expressjs.com/en/guide/writing-middleware.html — cómo se escribe un middleware y qué significa `next()`. El sitio documenta Express 4 y 5 juntos; lo de esta página aplica a ambos.
- https://expressjs.com/en/guide/using-middleware.html — el orden de la tubería, que es la mitad de esta fase.
- https://github.com/typicode/json-server/tree/v0.16.3 — el README de la versión exacta que usamos. ⚠️ La rama principal del repositorio documenta la 1.x, que cambió la API y el formato del archivo: no copies de ahí.
- https://rxjs.dev/api/operators/timeout — el operador `timeout`. ⚠️ El sitio asume RxJS 7; en 6.5.5 la firma que usamos —milisegundos sueltos— sigue siendo válida, pero la variante con objeto de configuración no existe todavía.
- https://rxjs.dev/api/index/class/TimeoutError — la forma del error que captura `describeError`.
- https://v8.angular.io/guide/http#error-handling — manejo de errores de `HttpClient` en la versión del curso.
- https://v8.angular.io/api/common/http/HttpErrorResponse — las propiedades del objeto de error, incluido `status: 0`.
- https://developer.mozilla.org/es/docs/Web/HTTP/CORS — CORS y el preflight, en español y sin depender de ninguna versión.

**Video / apoyo**

- Cualquier introducción a *middleware* de Express en YouTube sirve para el modelo mental de la tubería; busca una que dibuje la cadena de funciones antes de escribir código. Verifica que hable de Express 4: los tutoriales de Express 5 cambian el manejo de errores asíncronos y el código no es intercambiable.
- Para CORS, el complemento natural del ejercicio 26 es cualquier explicación visual del preflight `OPTIONS`. Es un tema donde ver el diagrama del intercambio ahorra más tiempo que leer la especificación.

**Orden de lectura sugerido:** lee la página de *using middleware* de Express antes de escribir §5.3, porque el orden de la tubería es lo único que no se puede depurar por error de compilación. Ten abierta la referencia de `HttpErrorResponse` mientras escribes `describeError` en §5.6. Y vuelve a la página de CORS de MDN al llegar al ejercicio 26, no antes: sin haber roto CORS a propósito, ese texto no se pega a nada.

> ⚠️ URLs, títulos y contenidos cambian o desaparecen; verificalos. Dos enlaces de esta lista apuntan a documentación de versiones **posteriores** a las del curso (json-server y RxJS) y están marcados; el resto es estable o independiente de versión.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Quedó construido el servidor único del curso: Express como anfitrión, json-server adentro, el login de la Fase 3 absorbido, y un inyector de caos propio con cinco modos que se encienden por variable de entorno o por header. Del lado del cliente, el effect de pacientes ahora corta la espera por su cuenta y traduce cualquier fallo a un objeto chico y legible que queda registrado en el store; la pantalla distingue cuatro estados donde antes había dos.

La Fase 5 arranca el primer CRUD de verdad —pacientes y órdenes, con tabla de Material, filtros y formularios reactivos— y necesita las dos cosas que nacieron acá. Necesita el `db.json` con el modelo completo, porque sin órdenes no hay nada que listar. Y necesita el caos, porque un CRUD tiene cuatro operaciones y cada una puede fallar de las cinco formas que ya sabes provocar: a partir de la Fase 5, "¿y si esto falla?" deja de ser una pregunta retórica y pasa a ser un comando que puedes ejecutar.

> **La señal de que quedó bien:** si puedes tomar cualquier ticket vago del tipo "a veces no carga" y, en menos de cinco minutos, encender el modo de caos que lo reproduce de forma consistente en tu máquina, esta fase hizo su trabajo. El resto del arreglo es la parte fácil.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-04-mock-api-caos -m "F4 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f04: …`) y los de ejercicio su
> número (`f04 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f04/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Y desde esta fase tus tags dejan de ser solo tuyos. Las ramas `incidente/NN`
> del cuaderno salen del commit donde cerraste la fase que produce cada
> incidente —`git checkout -b incidente/06 fase-04-mock-api-caos`—, así que sin
> el tag ese commit no tiene nombre y hay que buscarlo a mano.

---

## 📌 Pendientes sugeridos

- **Redacción de los incidentes 06 y 08.** Los IDs ya están reservados en el índice de `cuaderno-incidentes.md` con sus títulos (*"la pantalla de pacientes sale vacía y no dice nada"* y *"a veces no carga"*); lo que falta es el enunciado completo con la plantilla de ocho puntos. El 06 es la respuesta malformada con `200`, el 08 es el intermitente con `fail=500@30` → chat del cuaderno de incidentes.
- **Interceptor de timeout global.** Declarado como deuda en §5.6. Encaja mejor como sección de un apéndice de HTTP o como ejercicio 🔥 de una fase posterior que como refactor del effect → apéndice, a definir.
- **Validación de la forma de la respuesta.** El modo `malformed` deja abierta la pregunta de si el effect debería verificar lo que recibe. Es material natural del ejercicio 🔥 de migración a TS-1 → **Apéndice A11 §5**, que es donde vive la conversación de `strict` (qué banderas enciende, por qué produce cientos de errores en un código TS-0 y por qué nunca se hace en la misma tanda que un cambio de versión). El **A10** cubre el tramo 8 → 9; A06 y A07 son NgRx e i18n, la referencia anterior estaba equivocada.
- **Panel de caos con feature flag y exclusión de build.** El 🔥 de esta fase lo pide a medias; hacerlo bien toca el `angular.json` y toca la Fase 13 → **Fase 13** o ejercicio 🔥 propio.
- 🪦 **`db.json` como fuente de los incidentes: resuelto.** El blocker era cómo se distribuye un estado roto, y lo cierra el propio cuaderno en su sección *«Cómo llega el sistema roto a tu máquina»*: **flag del inyector de caos siempre que sirva, `db.incidente-NN.json` cuando el bug esté en el dato, y rama `incidente/NN` solo cuando haya que romper código**. El middleware que construye esta fase es lo que hizo posible que la primera opción sea la habitual.

### Reservas para el cuaderno de incidentes

Esta fase toma los incidentes **06 y 08**, ambos ya reservados en el índice de
[`cuaderno-incidentes.md`](./cuaderno-incidentes.md). El enunciado completo —ticket, preparación,
pistas plegadas y solución de referencia— **ya está escrito allí**:

- **06** · Fase 4 · *"La pantalla de pacientes sale vacía y no dice nada"* · Categoría: integración · Dificultad 🟡 — el modo `malformed`: un `200` verde con la forma equivocada, y el store despachando **Success** con basura. Se prepara con un flag del inyector de caos, que es la forma más barata de las tres.
- **08** · Fase 4 · *"A veces no carga"* · Categoría: integración · Dificultad 🟡 — el intermitente con `fail=500@30`. La lección es que un "a veces" es un flag del caos que todavía no encendiste, no un misterio.
