# 🧪 Fase 03 — Mock API + Express caos

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 3 de 14 · **6 horas**
> Depende de: Fase 2 (autenticación mínima) · Habilita: Fases 4 a 13
> Apéndices de apoyo: [A03 (Node y npm)](a03-node-npm.md) · [A06 (RxJS 7 idiomático)](a06-rxjs.md)
> [Incidentes asociados](cuaderno-incidentes.md): 04
> Estilo de esta fase: **nuevo** para los servicios de la aplicación; el mock es Node y va aparte

---

## 🎯 1. Propósito

Levantar el backend falso contra el que va a correr todo lo que queda del curso, con el modelo de dominio completo sembrado, y —esto es lo que de verdad importa— **construir el inyector de caos que hace que CertCore falle de verdad, a voluntad y de forma reproducible.**

Un mock que siempre responde `200` en dos milisegundos no enseña a mantener nada. En producción el backend tarda, se cae una de cada tres veces, devuelve un campo con el tipo cambiado tras un despliegue, y a veces no responde nunca. Aquí eso se provoca con una variable de entorno.

Y el caos **se construye, no se copia**. Una librería te daría lo mismo en dos líneas, y el estudiante no sabría qué está pasando cuando el fallo aparezca. Escribiendo el middleware entiendes exactamente qué se rompe, dónde, y por qué el síntoma se ve como se ve — que es la mitad del trabajo de diagnosticar.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `npm run mock` levanta el servidor en el puerto 3000, y `curl http://localhost:3000/templates` devuelve tres plantillas: `elevator-annual` en v1 y v2, y `boiler-annual` en v1.
- [ ] `curl http://localhost:3000/inspections/501/findings` devuelve sólo los hallazgos de esa inspección.
- [ ] `npm run seed` deja `mock/db.json` idéntico a la semilla, sin importar cómo lo hayas dejado.
- [ ] Los seis flags funcionan y se combinan: `CHAOS=latency,error npm run mock` retrasa **y** falla.
- [ ] La pantalla de Plantillas lista las tres, con su versión y su vigencia, leyéndolas del mock.
- [ ] Con `CHAOS=cors` esa pantalla muestra un mensaje que menciona la red, y con `CHAOS=malformed` uno que menciona la forma de la respuesta. Dos mensajes distintos para dos fallos distintos.
- [ ] `mock/README.md` existe y lista los seis flags con una línea cada uno.
- [ ] `git tag` lista `fase-03`.

---

## 🚫 3. Qué NO entra todavía

- **Servicios de estado y `BehaviorSubject`** → Fase 4. Hoy la pantalla de Plantillas se suscribe al `ApiService` directamente, y eso es una 💸 con fecha.
- **Paginación y proyecciones del lado del servidor** → no entran nunca, y el porqué está en la 💸 de 5.2.
- **Caché HTTP, reintentos automáticos, `retry`** → ejercicios 🔥. Reintentar es fácil de escribir y difícil de decidir; hoy toca ver los fallos, no taparlos.
- **`timeout()` de RxJS** → ejercicio 18. CertCore no lo tiene, y el spinner eterno es el síntoma que reportan los usuarios de verdad.
- **Interceptor global de errores** → no entra. El `authInterceptor` de la Fase 2 maneja el `401` y nada más; centralizar el resto de errores esconde justo lo que esta fase quiere que veas.
- **Las pantallas de clientes, activos, inspecciones y certificados** → Fases 6 a 11. Los `ApiService` que las van a alimentar sí nacen hoy.

---

## 🧠 4. Concepto mínimo

### El borde HTTP es donde el tipado se acaba

`this.http.get<ChecklistTemplate[]>(url)` no valida nada. Ese genérico es una **promesa que le haces tú al compilador**, no una comprobación: TypeScript se borra al compilar y en tiempo de ejecución lo que llega es lo que el servidor haya querido mandar. Si el backend cambia `version` de número a cadena en un despliegue de un viernes, tu código sigue compilando y empieza a comportarse raro el lunes.

Esto no es un defecto de Angular ni de TypeScript: es la frontera del sistema de tipos, y todo lenguaje con tipos estáticos la tiene en el mismo sitio. Lo que cambia entre un equipo y otro es qué se hace con ella. Hay tres posturas honestas, y el curso toma la tercera:

**Confiar y que reviente.** Cero código, cero costo, y el error aparece lejos del origen —en una plantilla, con un `*ngFor` sobre algo que no es un array— y sin decir de dónde vino.

**Validar todo con un esquema** (`zod`, `io-ts`). Correcto, caro en dependencia y en mantenimiento de esquemas duplicados, y raro en un sistema en mantenimiento donde nadie va a escribir cuarenta validadores retroactivos.

**Validar la forma, no el contenido.** Comprobar que lo que dijiste que era un array es un array, y dejar el resto. Cuesta tres líneas por servicio, convierte un fallo misterioso en un mensaje con nombre, y es lo que CertCore hace. El ejercicio 26 te hace decidir dónde se pone y dónde no vale la pena.

### `catchError` y la pregunta que todo el mundo contesta mal

`catchError` intercepta el error de un observable y **tiene que devolver otro observable**. La tentación —está en la mitad de los tutoriales— es devolver `of([])`:

```ts
// ❌ No lo hagas.
catchError(() => of([]))
```

Léelo con los ojos del usuario: el servidor se cayó y la pantalla dice "no hay plantillas". Son dos frases distintas y esa línea las confunde para siempre. El componente ya no puede distinguir "está vacío" de "falló", y por lo tanto no puede ofrecer un botón de reintentar ni decirle a nadie qué pasó.

La regla del curso es corta: **`catchError` traduce, no traga.** Convierte un `HttpErrorResponse` —que es un objeto de infraestructura, con `status` y `headers`— en un error del dominio con un mensaje que alguien puede leer, y lo vuelve a lanzar. Quien llamó decide qué hacer.

> 📚 El operador entero, con los tres antipatrones que produce, está en **A06**.

### El `status: 0`, que es la pista más útil de la fase

Cuando `HttpErrorResponse` llega con `status: 0`, **el servidor no dijo cero**. Es Angular avisando de que el navegador ni siquiera consiguió una respuesta: el servidor está caído, la red no está, el DNS falló, o —lo más frecuente en desarrollo— el navegador bloqueó la petición por CORS antes de dejarla salir.

Distinguir `status: 0` de `status: 500` es distinguir "no hablé con nadie" de "hablé y me dijeron que no". Son investigaciones completamente distintas y el mensaje que le muestras al usuario también debería serlo.

### El orden de los middlewares es el diseño

Un servidor Express es una tubería: cada middleware recibe la petición, hace algo y decide si pasa al siguiente. El orden en que los montas **es** el comportamiento. En este mock hay cuatro y el orden es deliberado:

```
CORS  →  caos  →  auth  →  datos (json-server)
```

CORS va primero porque hasta una respuesta de error tiene que llevar sus cabeceras: si no, el navegador se traga el `500` y te muestra un problema de CORS que no existe. El caos va segundo, sobre todo lo demás, porque un backend real falla en cualquier punto. Auth va tercero, y por eso el caos puede afectar a los datos sin impedirte entrar. Y los datos van al final, que es donde van siempre los datos.

> 📝 **Nota de migración.** Este mock no existía en el CertCore de 2021: el equipo desarrollaba contra un entorno de integración compartido, con los problemas que eso trae —dos personas pisándose los datos, y nadie capaz de reproducir un fallo de red a voluntad—. El mock local con inyector de caos es de **2024**, y lo montó quien lideró la migración precisamente para poder verificar que la 16 se comportaba igual que la 12 ante un backend hostil. Es la única pieza de CertCore que nació buena.

---

## 💻 5. Código mínimo con comentarios

### 5.1 Lo que se instala y el árbol del mock

```bash
npm install --save-dev json-server@0.17.4
```

Express 4.18.2 y jsonwebtoken 9.0.2 ya están desde la Fase 2. El mock queda así:

```
mock/
├── db.seed.json      ← la semilla. Sólo se edita a propósito.
├── db.json           ← la copia viva. json-server escribe aquí.
├── seed.js           ← regenera db.json desde la semilla
├── auth.js           ← lo de la Fase 2, extraído
├── chaos.js          ← el inyector de fallos ⭐
├── server.js         ← el ensamblaje
└── README.md         ← los seis flags, a un vistazo
```

**Los dos archivos de datos están versionados**, y eso es deliberado: `db.seed.json` es el escenario canónico del curso, y `db.json` es tu campo de pruebas, que puedes commitear cuando construyas un caso que quieras conservar. Cómo volver de un `db.json` hecho un desastre —y la diferencia entre `git checkout -- mock/db.json` y `npm run seed`, que no es la misma— está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

```jsonc
// package.json → scripts
{
  "scripts": {
    "mock": "node mock/server.js",
    "seed": "node mock/seed.js"
  }
}
```

```js
// mock/seed.js
const fs = require('fs');
const path = require('path');

// Un script de Node y no un `cp`: el curso corre en Windows, Linux y macOS, y
// esto se comporta igual en los tres. Copiar a mano es la primera fuente de
// "en mi máquina el ejercicio no arranca".
const seedPath = path.join(__dirname, 'db.seed.json');
const dbPath = path.join(__dirname, 'db.json');

fs.copyFileSync(seedPath, dbPath);

console.log('db.json regenerado desde db.seed.json');
```

### 5.2 El modelo sembrado

Éste es el escenario sobre el que se apoyan once fases. **Cópialo, no lo teclees**: escribir a mano cinco inspecciones coherentes con dos versiones de plantilla es una hora que no te enseña nada. Lo que sí conviene es leerlo despacio una vez, porque casi cada fila está puesta para provocar algo.

```json
{
  "clients": [
    { "id": 1, "legalName": "Edificio Central S.A.S.", "taxId": "900123456" },
    { "id": 2, "legalName": "Clínica del Norte S.A.S.", "taxId": "901456789" },
    { "id": 3, "legalName": "Industrias Aurora S.A.S.", "taxId": "900987654" }
  ],

  "assets": [
    { "id": "ASC-CENTRAL-03", "clientId": 1, "type": "elevator",
      "description": "Ascensor lado norte, torre A", "installedAt": "2015-06-10" },
    { "id": "ASC-CENTRAL-04", "clientId": 1, "type": "elevator",
      "description": "Ascensor lado sur, torre A", "installedAt": "2015-06-10" },
    { "id": "CAL-NORTE-01", "clientId": 2, "type": "boiler",
      "description": "Caldera de agua caliente, sótano", "installedAt": "2018-02-20" },
    { "id": "ASC-NORTE-02", "clientId": 2, "type": "elevator",
      "description": "Ascensor de camillas", "installedAt": "2019-11-05" },
    { "id": "TAN-AURORA-07", "clientId": 3, "type": "tank",
      "description": "Tanque de almacenamiento norte", "installedAt": "2012-09-01" },
    { "id": "RCI-AURORA-01", "clientId": 3, "type": "fire_system",
      "description": "Red contra incendio, bodega 2", "installedAt": "2020-03-15" }
  ],

  "templates": [
    {
      "id": "elevator-annual-v1",
      "templateId": "elevator-annual",
      "version": 1,
      "validFrom": "2021-01-01",
      "validUntil": "2023-12-31",
      "items": [
        { "id": "main-cable", "title": "Estado del cable principal",
          "criteria": ["no_wear", "light_wear", "critical_wear"],
          "photoRequired": true, "nonComplianceSeverity": "critical" },
        { "id": "emergency-brake", "title": "Freno de emergencia",
          "criteria": ["ok", "needs_adjustment", "failed"],
          "photoRequired": false, "nonComplianceSeverity": "critical" },
        { "id": "door-sensor", "title": "Sensor de puerta",
          "criteria": ["ok", "intermittent", "failed"],
          "photoRequired": true, "nonComplianceSeverity": "major" }
      ]
    },
    {
      "id": "elevator-annual-v2",
      "templateId": "elevator-annual",
      "version": 2,
      "validFrom": "2024-01-01",
      "validUntil": null,
      "items": [
        { "id": "main-cable", "title": "Estado y tensión del cable principal",
          "criteria": ["no_wear", "light_wear", "critical_wear"],
          "photoRequired": true, "nonComplianceSeverity": "critical" },
        { "id": "emergency-brake", "title": "Freno de emergencia",
          "criteria": ["ok", "needs_adjustment", "failed"],
          "photoRequired": false, "nonComplianceSeverity": "critical" },
        { "id": "door-sensor", "title": "Sensor de puerta",
          "criteria": ["ok", "intermittent", "failed"],
          "photoRequired": true, "nonComplianceSeverity": "major" },
        { "id": "cabin-lighting", "title": "Iluminación de cabina y de emergencia",
          "criteria": ["ok", "partial", "failed"],
          "photoRequired": false, "nonComplianceSeverity": "minor" }
      ]
    },
    {
      "id": "boiler-annual-v1",
      "templateId": "boiler-annual",
      "version": 1,
      "validFrom": "2022-01-01",
      "validUntil": null,
      "items": [
        { "id": "pressure-valve", "title": "Válvula de alivio de presión",
          "criteria": ["ok", "leaking", "blocked"],
          "photoRequired": true, "nonComplianceSeverity": "critical" },
        { "id": "flue-gas", "title": "Análisis de gases de combustión",
          "criteria": ["within_range", "out_of_range"],
          "photoRequired": false, "nonComplianceSeverity": "major" }
      ]
    }
  ],

  "inspections": [
    { "id": 500, "assetId": "ASC-CENTRAL-03", "inspectorId": "INS-15",
      "templateId": "elevator-annual", "templateVersion": 2, "status": "in_progress",
      "startedAt": "2024-03-15T09:00:00-05:00", "completedAt": null,
      "answers": [
        { "itemId": "main-cable", "answer": "light_wear",
          "evidenceUrl": "assets/evidence/500-main-cable.jpg",
          "note": "Revisar en 6 meses" }
      ] },

    { "id": 501, "assetId": "ASC-CENTRAL-04", "inspectorId": "INS-15",
      "templateId": "elevator-annual", "templateVersion": 1, "status": "approved",
      "startedAt": "2023-08-02T08:30:00-05:00", "completedAt": "2023-08-02T11:15:00-05:00",
      "answers": [
        { "itemId": "main-cable", "answer": "no_wear",
          "evidenceUrl": "assets/evidence/501-main-cable.jpg", "note": null },
        { "itemId": "emergency-brake", "answer": "ok", "evidenceUrl": null, "note": null },
        { "itemId": "door-sensor", "answer": "intermittent",
          "evidenceUrl": "assets/evidence/501-door-sensor.jpg",
          "note": "Falla en el tercio inferior" }
      ] },

    { "id": 502, "assetId": "CAL-NORTE-01", "inspectorId": "INS-22",
      "templateId": "boiler-annual", "templateVersion": 1, "status": "approved",
      "startedAt": "2024-02-09T07:00:00-05:00", "completedAt": "2024-02-09T09:40:00-05:00",
      "answers": [
        { "itemId": "pressure-valve", "answer": "ok",
          "evidenceUrl": "assets/evidence/502-pressure-valve.jpg", "note": null },
        { "itemId": "flue-gas", "answer": "within_range", "evidenceUrl": null, "note": null }
      ] },

    { "id": 503, "assetId": "ASC-NORTE-02", "inspectorId": "INS-15",
      "templateId": "elevator-annual", "templateVersion": 2, "status": "rejected",
      "startedAt": "2024-05-20T14:00:00-05:00", "completedAt": "2024-05-20T16:20:00-05:00",
      "answers": [
        { "itemId": "main-cable", "answer": "critical_wear",
          "evidenceUrl": "assets/evidence/503-main-cable.jpg",
          "note": "Hilos visibles en el tramo superior" },
        { "itemId": "emergency-brake", "answer": "ok", "evidenceUrl": null, "note": null },
        { "itemId": "door-sensor", "answer": "ok", "evidenceUrl": null, "note": null },
        { "itemId": "cabin-lighting", "answer": "partial", "evidenceUrl": null, "note": null }
      ] },

    { "id": 504, "assetId": "ASC-CENTRAL-03", "inspectorId": "INS-22",
      "templateId": "elevator-annual", "templateVersion": 2, "status": "scheduled",
      "startedAt": "2025-01-20T09:00:00-05:00", "completedAt": null, "answers": [] }
  ],

  "findings": [
    { "id": 900, "inspectionId": 503, "itemId": "main-cable", "severity": "critical",
      "description": "Desgaste severo del cable principal, con hilos visibles",
      "resolvedAt": null },
    { "id": 901, "inspectionId": 503, "itemId": "cabin-lighting", "severity": "minor",
      "description": "Dos luminarias de cabina fuera de servicio", "resolvedAt": null },
    { "id": 902, "inspectionId": 501, "itemId": "door-sensor", "severity": "major",
      "description": "El sensor no detecta obstáculos en el tercio inferior",
      "resolvedAt": "2023-08-18T16:00:00-05:00" },
    { "id": 903, "inspectionId": 500, "itemId": "main-cable", "severity": "minor",
      "description": "Desgaste leve, dentro de tolerancia", "resolvedAt": null }
  ],

  "certificates": [
    { "id": "CERT-2023-000501", "inspectionId": 501,
      "issuedAt": "2023-08-21T10:00:00-05:00",
      "validUntil": "2024-08-21T23:59:59-05:00",
      "status": "expired", "revokedAt": null },
    { "id": "CERT-2024-000502", "inspectionId": 502,
      "issuedAt": "2024-02-10T10:00:00-05:00",
      "validUntil": "2025-02-10T23:59:59-05:00",
      "status": "valid", "revokedAt": null }
  ]
}
```

**Detalles con intención**

- **La plantilla `elevator-annual` existe en dos versiones, y cada una es una fila con su propio `id`.** El modelo de referencia de `alcance-del-proyecto.md` §5.1 usaba `id: "elevator-annual"` con un campo `version`, y así **las dos versiones no pueden coexistir**: json-server usa `id` como clave única y la segunda pisaría a la primera. Por eso el `id` es compuesto (`elevator-annual-v2`) y el identificador lógico vive en `templateId`. Las inspecciones siguen guardando `templateId` + `templateVersion`, exactamente como manda §5.1.
- **La inspección 501 es la bomba del curso.** Se ejecutó en agosto de 2023 con la v1, cuando la v1 era la vigente. Hoy la vigente es la v2 y tiene un ítem más. Si algún día ves la inspección 501 con cuatro ítems y uno de ellos vacío, alguien rompió el invariante — y eso es la Fase 7 entera ⭐.
- **La v2 no sólo añade un ítem: le cambia el título a `main-cable`.** "Estado del cable principal" pasó a "Estado y tensión del cable principal" porque la norma lo pidió. Es el detalle que hace que renderizar con la versión equivocada sea *visible* y no sólo incorrecto.
- **La 503 está rechazada y tiene un hallazgo `critical` sin resolver.** Por eso no tiene certificado, y por eso es el caso de prueba de la Fase 9.
- **Los `findings` son una colección propia**, con `inspectionId`, y eso es lo que hace que json-server sirva `GET /inspections/503/findings` sin configurar nada. El modelo de §5.1 no la tenía, pero la guía §5.3 ya nombraba ese endpoint: se siembra hoy porque añadirla en la Fase 9 significaría cambiar el `db.json` sobre el que seis fases construyeron.
- **Todas las fechas llevan offset `-05:00`.** Ni una `Z`, ni una fecha desnuda. La Fase 10 va a vivir de eso.

> ⚠️ **El `status` de los certificados está guardado como dato, y eso es un error de diseño puesto a propósito.** `CERT-2024-000502` dice `"valid"` y su `validUntil` es de febrero de 2025: según el reloj de quien lea esto, hace tiempo que no es válido. Un estado que se calcula pero se almacena empieza a mentir el día siguiente. La Fase 10 lo convierte en derivado, y el ejercicio 21 te hace nombrar el problema antes de que te lo cuenten.

```
💸 DEUDA TÉCNICA INTENCIONAL — el mock devuelve el objeto completo
No hay paginación ni proyecciones: GET /inspections trae las cinco inspecciones
enteras, con todas sus respuestas. Lo correcto en un sistema real es paginar y
devolver sólo los campos que la pantalla usa.
NO SE PAGA, y el motivo es de alcance: implementar paginación en el mock es
trabajo de backend que no enseña ni una línea de Angular. Lo que sí se lleva el
estudiante es el reflejo de preguntar "¿y cuando haya cuatro mil inspecciones?"
—que en la Fase 11, con el dashboard, deja de ser retórico—.
```

### 5.3 `mock/auth.js` — lo de la Fase 2, extraído

Sale del `server.js` sin un cambio de comportamiento, salvo uno: el TTL del token ahora lo decide el caos.

```js
// mock/auth.js
const express = require('express');
const jwt = require('jsonwebtoken');

const JWT_SECRET = 'certcore-dev-secret';
const TOKEN_TTL_SECONDS = 3600;

const USERS = [
  { email: 'inspector@certcore.co', password: 'certcore123',
    sub: 'INS-15', name: 'Ana Restrepo', role: 'inspector' },
  { email: 'supervisor@certcore.co', password: 'certcore123',
    sub: 'SUP-02', name: 'Diego Marín', role: 'supervisor' },
];

function createAuthRouter(chaos) {
  const router = express.Router();

  router.post('/auth/login', (request, response) => {
    const { email, password } = request.body;
    const user = USERS.find((candidate) => candidate.email === email && candidate.password === password);

    if (!user) {
      return response.status(401).json({ message: 'Credenciales inválidas' });
    }

    // El único fallo de caos que actúa dentro del login: firma un token que ya
    // nació vencido. Todo lo demás deja el login en paz a propósito — si no
    // puedes entrar, no puedes diagnosticar nada.
    const ttl = chaos.faults.includes('expired') ? -60 : TOKEN_TTL_SECONDS;

    const accessToken = jwt.sign(
      { sub: user.sub, name: user.name, role: user.role },
      JWT_SECRET,
      { expiresIn: ttl },
    );

    response.json({ accessToken, expiresIn: ttl });
  });

  return router;
}

function requireToken(request, response, next) {
  const header = request.headers.authorization;

  if (typeof header !== 'string' || !header.startsWith('Bearer ')) {
    return response.status(401).json({ message: 'Falta el token de acceso' });
  }

  try {
    request.user = jwt.verify(header.slice('Bearer '.length), JWT_SECRET);
    next();
  } catch (error) {
    response.status(401).json({ message: 'Token inválido o expirado' });
  }
}

module.exports = { createAuthRouter, requireToken };
```

### 5.4 `mock/chaos.js` — el inyector, en cuatro pasos ⭐

**Paso 1: leer la configuración, y fallar ruidosamente.**

```js
// mock/chaos.js
const DEFAULT_DELAY_MS = 2500;
const DEFAULT_RATE = 0.3;

const KNOWN_FAULTS = ['latency', 'error', 'malformed', 'cors', 'expired', 'timeout'];

function readChaosConfig(env) {
  const raw = (env.CHAOS ?? '').trim();
  const faults = raw === '' ? [] : raw.split(',').map((fault) => fault.trim()).filter(Boolean);

  const unknown = faults.filter((fault) => !KNOWN_FAULTS.includes(fault));

  if (unknown.length > 0) {
    // Falla al arrancar, no en silencio. Un CHAOS=latencia mal escrito que
    // simplemente no hace nada te cuesta veinte minutos buscando un bug que no
    // existe. Un servidor que se niega a arrancar te cuesta cero.
    throw new Error(
      `Fallos de caos desconocidos: ${unknown.join(', ')}. Los válidos son: ${KNOWN_FAULTS.join(', ')}.`,
    );
  }

  return {
    faults,
    delayMs: Number(env.CHAOS_DELAY_MS ?? DEFAULT_DELAY_MS),
    rate: Number(env.CHAOS_RATE ?? DEFAULT_RATE),
  };
}
```

**Paso 2: el esqueleto del middleware, con la latencia.**

```js
function createChaosMiddleware(chaos) {
  const has = (fault) => chaos.faults.includes(fault);
  // La probabilidad se tira UNA vez por petición y se reutiliza: si cada fallo
  // tirara su propio dado, con dos flags activos la mitad de las peticiones
  // saldrían ilesas y el escenario dejaría de ser reproducible.
  const rolls = () => Math.random() < chaos.rate;

  return (request, response, next) => {
    // El caos no toca la autenticación. `expired` es la excepción y vive en auth.js.
    if (request.path.startsWith('/auth/')) {
      return next();
    }

    if (has('latency')) {
      // El retraso es incondicional: una latencia intermitente no se distingue
      // de un problema de red, y aquí queremos que se distinga.
      return setTimeout(() => applyResponseFaults(request, response, next), chaos.delayMs);
    }

    applyResponseFaults(request, response, next);
  };
}
```

**Paso 3: los fallos que afectan a la respuesta.**

```js
  function applyResponseFaults(request, response, next) {
    if (has('timeout') && rolls()) {
      // Ni respondemos ni llamamos a next(). La petición se queda colgada para
      // siempre, que es exactamente lo que hace un backend que se atascó: no
      // manda un error, no cierra la conexión, no dice nada.
      return;
    }

    if (has('error') && rolls()) {
      return response.status(500).json({ message: 'Fallo interno del servidor' });
    }

    if (has('malformed') && rolls()) {
      // Envolvemos response.json para corromper el cuerpo justo antes de salir.
      // Fíjate en que el status sigue siendo 200: en Network todo está verde.
      const originalJson = response.json.bind(response);
      response.json = (body) => originalJson(corruptPayload(body));
    }

    next();
  }
```

**Paso 4: en qué consiste corromper.**

```js
/**
 * Dos corrupciones, y las dos son fallos reales de despliegue, no maldades
 * inventadas: envolver un array en un objeto (el clásico cambio a una respuesta
 * paginada que nadie avisó) y cambiar el tipo de un campo numérico.
 */
function corruptPayload(body) {
  if (Array.isArray(body)) {
    return { items: body, total: body.length };
  }

  if (body !== null && typeof body === 'object' && typeof body.version === 'number') {
    return { ...body, version: String(body.version) };
  }

  return body;
}

module.exports = { readChaosConfig, createChaosMiddleware, KNOWN_FAULTS };
```

**El patrón a memorizar**

> Un inyector de caos que falla en silencio cuando lo configuras mal es peor que no tenerlo: te hace buscar un bug donde no lo hay. Cualquier herramienta de diagnóstico tiene que ser la primera en gritar cuando ella misma está mal usada.

### 5.5 `mock/server.js` — el ensamblaje

```js
// mock/server.js
const path = require('path');
const express = require('express');
const jsonServer = require('json-server');

const { createAuthRouter, requireToken } = require('./auth');
const { readChaosConfig, createChaosMiddleware } = require('./chaos');

const chaos = readChaosConfig(process.env);
const app = express();

app.use(express.json());

// ── 1. CORS ────────────────────────────────────────────────────────────────
// Va primero para que hasta una respuesta de error lleve sus cabeceras. Si no,
// un 500 llega al navegador sin Access-Control-Allow-Origin y lo que ves es un
// problema de CORS que no existe, tapando el error de verdad.
const breakCors = chaos.faults.includes('cors');

app.use((request, response, next) => {
  const isAuthRequest = request.path.startsWith('/auth/');

  if (!breakCors || isAuthRequest) {
    response.header('Access-Control-Allow-Origin', 'http://localhost:4200');
    response.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Correlation-Id');
    response.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  }

  if (request.method === 'OPTIONS') {
    return response.sendStatus(204);
  }

  next();
});

// ── 2. Caos ────────────────────────────────────────────────────────────────
app.use(createChaosMiddleware(chaos));

// ── 3. Autenticación ───────────────────────────────────────────────────────
app.use(createAuthRouter(chaos));
// A partir de aquí, todo exige token. El authInterceptor de la Fase 2 lo pone.
app.use(requireToken);

// ── 4. Datos ───────────────────────────────────────────────────────────────
app.use(jsonServer.router(path.join(__dirname, 'db.json')));

app.listen(3000, () => {
  const active = chaos.faults.length === 0 ? 'ninguno' : chaos.faults.join(', ');
  console.log(`Mock de CertCore en http://localhost:3000 · caos: ${active}`);
});
```

**Prueba de fuego**

Levanta el mock sin caos y pide una plantilla concreta:

```bash
curl -s "http://localhost:3000/templates?templateId=elevator-annual&version=1" \
  -H "Authorization: Bearer <tu token>" | head -20
```

Te tiene que devolver **un array con una sola plantilla**, la v1, con tres ítems. Si te devuelve dos, el filtro por `version` no está llegando; si te devuelve `401`, el token expiró y tienes que volver a pedirlo. Y fíjate en el detalle que va a importar durante ocho fases: **json-server devuelve un array incluso cuando el resultado es uno solo**, porque estás filtrando una colección y no pidiendo un recurso por su id.

### 5.6 `mock/README.md`

Diez líneas que el cuaderno de incidentes va a citar durante un mes.

```markdown
# Mock de CertCore

    npm run mock     # levanta el servidor en http://localhost:3000
    npm run seed     # regenera db.json desde db.seed.json

## Inyector de caos

    CHAOS=<fallos separados por coma> npm run mock

- `latency`    — retrasa toda respuesta CHAOS_DELAY_MS (por defecto 2500)
- `error`      — devuelve 500 con probabilidad CHAOS_RATE (por defecto 0.3)
- `malformed`  — responde 200 con un cuerpo que no cumple el tipo
- `cors`       — omite la cabecera Access-Control-Allow-Origin
- `expired`    — el login firma un token que ya nació vencido
- `timeout`    — no responde nunca, con probabilidad CHAOS_RATE

Ejemplo: `CHAOS=latency,error CHAOS_RATE=0.5 npm run mock`

El caos no toca /auth/login, salvo `expired`. Si no puedes entrar, no puedes
diagnosticar.
```

### 5.7 Los modelos del dominio

El vocabulario de las once fases que quedan. Cada `| null` es una decisión, no un descuido.

```ts
// src/app/core/models/client.model.ts
export interface Client {
  readonly id: number;
  readonly legalName: string;
  /** NIT o identificación tributaria. Siempre presente: es la clave del negocio. */
  readonly taxId: string;
}
```

```ts
// src/app/core/models/asset.model.ts
export type AssetType = 'elevator' | 'boiler' | 'tank' | 'fire_system';

export interface Asset {
  /** Identificador operativo, el que está pintado en el equipo: "ASC-CENTRAL-03". */
  readonly id: string;
  readonly clientId: number;
  readonly type: AssetType;
  readonly description: string;
  /** Fecha de instalación, sin hora: es un día de calendario, no un instante. */
  readonly installedAt: string;
}
```

```ts
// src/app/core/models/checklist-template.model.ts
import { FindingSeverity } from './finding.model';

export interface ChecklistItem {
  readonly id: string;
  readonly title: string;
  /** Las respuestas admisibles, en orden de mejor a peor. */
  readonly criteria: readonly string[];
  readonly photoRequired: boolean;
  /** Qué severidad tiene un hallazgo sobre este ítem si no cumple. */
  readonly nonComplianceSeverity: FindingSeverity;
}

/**
 * Se llama ChecklistTemplate y no Template a propósito: en un curso de Angular,
 * "plantilla" ya significa otra cosa, y el lector va a leer las dos palabras en
 * el mismo párrafo durante ocho fases. El endpoint sigue siendo /templates y
 * los campos del dominio siguen siendo templateId y templateVersion.
 */
export interface ChecklistTemplate {
  /** Clave de la fila: "elevator-annual-v2". Compuesta, y por eso única. */
  readonly id: string;
  /** Identificador lógico, compartido por todas las versiones. */
  readonly templateId: string;
  readonly version: number;
  readonly validFrom: string;
  /** `null` significa "vigente indefinidamente". No es un campo sin decidir. */
  readonly validUntil: string | null;
  readonly items: readonly ChecklistItem[];
}
```

```ts
// src/app/core/models/inspection.model.ts
export type InspectionStatus =
  | 'requested'
  | 'scheduled'
  | 'in_progress'
  | 'completed'
  | 'approved'
  | 'rejected';

export interface InspectionAnswer {
  readonly itemId: string;
  /** Uno de los `criteria` del ítem. Se valida contra la plantilla, no aquí. */
  readonly answer: string;
  /** `null` cuando el ítem no exigía foto o el inspector no la subió todavía. */
  readonly evidenceUrl: string | null;
  readonly note: string | null;
}

export interface Inspection {
  readonly id: number;
  readonly assetId: string;
  readonly inspectorId: string;
  readonly templateId: string;
  /**
   * La versión con la que se EJECUTÓ. Es el campo más importante del sistema:
   * una inspección se lee siempre con ésta, nunca con la vigente. Fase 7 ⭐.
   */
  readonly templateVersion: number;
  readonly status: InspectionStatus;
  readonly startedAt: string;
  /** `null` mientras no se haya cerrado. */
  readonly completedAt: string | null;
  readonly answers: readonly InspectionAnswer[];
}
```

```ts
// src/app/core/models/finding.model.ts
export type FindingSeverity = 'critical' | 'major' | 'minor';

export interface Finding {
  readonly id: number;
  readonly inspectionId: number;
  readonly itemId: string;
  readonly severity: FindingSeverity;
  readonly description: string;
  /** `null` = sin resolver. Un `critical` sin resolver bloquea el certificado. */
  readonly resolvedAt: string | null;
}
```

```ts
// src/app/core/models/certificate.model.ts
export type CertificateStatus = 'issued' | 'valid' | 'expiring' | 'expired' | 'revoked';

export interface Certificate {
  readonly id: string;
  readonly inspectionId: number;
  readonly issuedAt: string;
  /** Con hora y offset: "¿vence hoy?" depende de dónde esté parado quien pregunta. */
  readonly validUntil: string;
  /**
   * ⚠️ Viene almacenado y debería ser derivado de `validUntil` contra el reloj.
   * Se deja así porque así está el dato real; la Fase 10 lo convierte en
   * calculado y explica por qué un estado guardado empieza a mentir mañana.
   */
  readonly status: CertificateStatus;
  readonly revokedAt: string | null;
}
```

### 5.8 El error del dominio

```ts
// src/app/core/api/api-error.ts
import { HttpErrorResponse } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';

/**
 * Un fallo de la API, ya traducido a algo que un componente puede mostrar.
 * Extender Error funciona sin trucos porque el target es ES2022; con ES5 haría
 * falta el arreglo del prototipo que se ve en tantos proyectos viejos.
 */
export class ApiError extends Error {
  constructor(
    message: string,
    /** El status HTTP, o `null` si nunca hubo respuesta. */
    readonly status: number | null,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

/** Traduce cualquier fallo en un ApiError y lo relanza. Nunca lo traga. */
export function toApiError(error: unknown): Observable<never> {
  if (error instanceof HttpErrorResponse) {
    const message =
      error.status === 0
        ? // status 0 NO significa que el servidor respondiera cero: significa
          // que no hubo respuesta. Servidor caído, red ausente, o el navegador
          // bloqueando la petición por CORS antes de dejarla salir.
          'No se pudo contactar con el servidor. Puede ser la red, el servidor caído o un CORS mal configurado.'
        : `El servidor respondió ${error.status} al pedir ${error.url ?? 'el recurso'}.`;

    return throwError(() => new ApiError(message, error.status));
  }

  return throwError(() => new ApiError('Fallo inesperado al hablar con la API.', null));
}
```

### 5.9 `TemplateApiService` — nuevo

```ts
// src/app/core/api/template-api.service.ts
import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, map } from 'rxjs';

import { environment } from '../../../environments/environment';
import { ChecklistTemplate } from '../models/checklist-template.model';
import { ApiError, toApiError } from './api-error';

@Injectable({ providedIn: 'root' })
export class TemplateApiService {
  // inject() y no constructor: este servicio es de 2024. En el mismo directorio
  // vive AuthService, que es de 2021 y usa constructor. Los dos están bien; lo
  // que no estaría bien es mezclar las dos formas dentro de un archivo.
  private readonly http = inject(HttpClient);

  private readonly baseUrl = `${environment.apiBaseUrl}/templates`;

  getAll(): Observable<readonly ChecklistTemplate[]> {
    return this.http.get<readonly ChecklistTemplate[]>(this.baseUrl).pipe(
      // El genérico de arriba es una promesa nuestra, no una verificación.
      // Estas tres líneas comprueban la FORMA —lo que dijimos que era un array
      // lo es— y ni una cosa más. Es el punto medio del §4: sin esto, un
      // CHAOS=malformed explota dentro de un *ngFor, tres capas más allá.
      map((templates) => {
        if (!Array.isArray(templates)) {
          throw new ApiError('El servidor devolvió algo que no es una lista de plantillas.', 200);
        }

        return templates;
      }),
      catchError(toApiError),
    );
  }

  /**
   * Resuelve UNA versión concreta. Es el método que sostiene el invariante del
   * curso: una inspección se lee con la versión que guardó, no con la vigente.
   */
  getByVersion(templateId: string, version: number): Observable<ChecklistTemplate> {
    const params = new HttpParams().set('templateId', templateId).set('version', version);

    // json-server devuelve un array al filtrar una colección, aunque la
    // coincidencia sea única. Desempaquetar aquí evita que cada componente
    // tenga que recordar ese detalle del backend.
    return this.http.get<readonly ChecklistTemplate[]>(this.baseUrl, { params }).pipe(
      map((matches) => {
        const [template] = matches;

        if (template === undefined) {
          throw new ApiError(
            `No existe la plantilla ${templateId} en su versión ${version}.`,
            404,
          );
        }

        return template;
      }),
      catchError(toApiError),
    );
  }
}
```

### 5.10 `ClientApiService` y el resto del patrón

```ts
// src/app/core/api/client-api.service.ts
import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError } from 'rxjs';

import { environment } from '../../../environments/environment';
import { Client } from '../models/client.model';
import { toApiError } from './api-error';

@Injectable({ providedIn: 'root' })
export class ClientApiService {
  private readonly http = inject(HttpClient);

  private readonly baseUrl = `${environment.apiBaseUrl}/clients`;

  getAll(): Observable<readonly Client[]> {
    return this.http.get<readonly Client[]>(this.baseUrl).pipe(catchError(toApiError));
  }

  getById(id: number): Observable<Client> {
    // Aquí sí pedimos un recurso por su id, y json-server devuelve el objeto
    // solo. Es la diferencia con el filtro de getByVersion, y confundirlas es
    // el error más frecuente al escribir el tercer servicio.
    return this.http.get<Client>(`${this.baseUrl}/${id}`).pipe(catchError(toApiError));
  }
}
```

Los tres que faltan siguen exactamente el mismo molde, y los escribes tú en los ejercicios 9 y 26:

- `AssetApiService` — `getAll()`, `getByClient(clientId: number)`.
- `InspectionApiService` — `getAll()`, `getById(id: number)`, `getFindings(inspectionId: number)` contra `/inspections/:id/findings`.
- `CertificateApiService` — `getAll()`, `getByInspection(inspectionId: number)`.

**Detalles con intención**

- **`readonly ChecklistTemplate[]` y no `ChecklistTemplate[]`.** Lo que llega de la API no se muta: se reemplaza, y el `readonly` lo dice en el tipo en vez de en un comentario que nadie lee. Ojo con el alcance de esa protección: cubre **el borde HTTP y nada más**. La Fase 4 va a guardar estos datos en un contenedor de estado que **sí** se expone mutable, a propósito y con su 💸 declarada, y la Fase 6 lo cobra. Que la puerta de entrada esté cerrada no significa que la casa lo esté.
- **Un `ApiService` por recurso, sin lógica de negocio.** Traduce HTTP a dominio y nada más. La regla del proyecto: si un método de un `*ApiService` empieza a decidir algo, ese algo pertenece al servicio de estado de la Fase 4 o al componente.

### 5.11 La primera pantalla que habla con el backend

Tocamos el `TemplateListComponent` que la Fase 1 dejó como placeholder. Es un componente de 2021, así que **el cambio va en estilo de 2021**: `constructor`, `.subscribe()`, `Subscription` y `ngOnDestroy`.

```ts
// src/app/features/templates/template-list/template-list.component.ts
import { Component, OnDestroy, OnInit } from '@angular/core';
import { Subscription } from 'rxjs';

import { ApiError } from '../../../core/api/api-error';
import { TemplateApiService } from '../../../core/api/template-api.service';
import { ChecklistTemplate } from '../../../core/models/checklist-template.model';

@Component({
  selector: 'cc-template-list',
  templateUrl: './template-list.component.html',
})
export class TemplateListComponent implements OnInit, OnDestroy {
  templates: readonly ChecklistTemplate[] = [];
  loading = false;
  errorMessage: string | null = null;

  private subscription: Subscription | null = null;

  /**
   * 💸 DEUDA TÉCNICA INTENCIONAL
   * El componente habla con el ApiService directamente y guarda el resultado
   * en un campo suyo. Con una sola pantalla funciona; con cuatro pantallas
   * necesitando la misma lista, cada una pide lo suyo y las cuatro pueden
   * mostrar cosas distintas a la vez.
   * Lo correcto es un servicio de estado con un BehaviorSubject privado y un
   * Observable público, y la vista pintando con el pipe async.
   * SE PAGA EN LA FASE 4, que existe exactamente para esto.
   */
  constructor(private readonly templateApi: TemplateApiService) {}

  ngOnInit(): void {
    this.loading = true;
    this.errorMessage = null;

    this.subscription = this.templateApi.getAll().subscribe({
      next: (templates) => {
        this.templates = templates;
        this.loading = false;
      },
      error: (error: unknown) => {
        this.loading = false;
        // El mensaje ya viene traducido desde toApiError: el componente no
        // sabe nada de status HTTP, y así es como debe ser.
        this.errorMessage =
          error instanceof ApiError
            ? error.message
            : 'Ocurrió un error inesperado al cargar las plantillas.';
      },
    });
  }

  ngOnDestroy(): void {
    // Desuscripción manual: el estilo de 2021. Un observable de HttpClient
    // completa solo, así que esto parece de más — hasta que corres con
    // CHAOS=latency y navegas fuera antes de que responda. Ahí es cuando
    // importa. En el código nuevo esto se escribe con takeUntilDestroyed, y la
    // Fase 4 lo compara con las otras tres formas de cerrar la puerta.
    this.subscription?.unsubscribe();
  }
}
```

```html
<!-- src/app/features/templates/template-list/template-list.component.html -->
<h2>Plantillas de checklist</h2>

<mat-progress-spinner *ngIf="loading" mode="indeterminate" diameter="32"></mat-progress-spinner>

<p class="template-error" *ngIf="errorMessage !== null">{{ errorMessage }}</p>

<mat-nav-list *ngIf="!loading && errorMessage === null">
  <a mat-list-item *ngFor="let template of templates">
    <span matListItemTitle>{{ template.templateId }} · v{{ template.version }}</span>
    <span matListItemLine>
      Vigente desde {{ template.validFrom }}
      <ng-container *ngIf="template.validUntil !== null">
        hasta {{ template.validUntil }}
      </ng-container>
      <ng-container *ngIf="template.validUntil === null">
        · sin fecha de fin
      </ng-container>
      · {{ template.items.length }} ítems
    </span>
  </a>
</mat-nav-list>
```

**Prueba de fuego**

Con el mock limpio, entra a Plantillas: tres filas, y la de `elevator-annual v1` con "hasta 2023-12-31" mientras la v2 dice "sin fecha de fin". Ahora reinicia el mock con `CHAOS=cors npm run mock` y recarga: la pantalla dice que no se pudo contactar con el servidor. Reinícialo con `CHAOS=malformed` y recarga unas cuantas veces: en algunas te dirá que el servidor devolvió algo que no es una lista.

**Dos fallos, dos mensajes distintos, y ninguno de los dos es "algo salió mal".** Ese es el resultado de la fase.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** `npm run mock` muere con `Cannot find module 'json-server'`.
**Causa:** json-server está instalado globalmente pero no en el proyecto, o el `npm install` se hizo antes de añadirlo.
**Fix mínimo:** `npm install --save-dev json-server@0.17.4`.
**Lo que importa:** el mock forma parte del repositorio, no del entorno de nadie. Si funciona sólo en tu máquina porque tienes algo global, mañana no funciona en la de otro — que es el mismo problema que resuelve el `.nvmrc` de la Fase 0, un piso más arriba.

**Síntoma:** el login devuelve `401` con credenciales correctas y no hay forma de entrar.
**Causa:** `requireToken` quedó montado **antes** que `createAuthRouter`. El middleware de autorización se ejecuta sobre la propia petición de login, que por definición no lleva token.
**Fix mínimo:** invertir las dos líneas en `server.js`.
**Lo que importa:** es la lección del orden de middlewares en su forma más pura, y es un bug que en un backend real deja fuera a todo el mundo a la vez. El ejercicio 19 te hace provocarlo a propósito.

**Síntoma:** `GET /inspections/503/findings` devuelve los cuatro hallazgos en vez de los dos de esa inspección.
**Causa:** las filas de `findings` no tienen `inspectionId`, o lo tienen como cadena en vez de número. json-server construye la ruta anidada a partir de ese campo y, si no lo encuentra, sirve la colección entera.
**Fix mínimo:** corregir el `db.json` y `npm run seed`.
**Lo que importa:** el filtro lo hace el servidor por convención de nombres, no por configuración. Cuando una ruta anidada devuelve de más, la respuesta está en el dato y no en el código.

**Síntoma:** pones `CHAOS=latencia` y el mock arranca tan campante sin retrasar nada.
**Causa:** no ocurre — el `readChaosConfig` de 5.4 se niega a arrancar y te dice cuáles son los flags válidos.
**Lo que importa:** que ese comportamiento fue una decisión, y es la que más tiempo te va a ahorrar en cuatro semanas de incidentes. Una herramienta de diagnóstico mal configurada que no protesta te manda a buscar un bug inexistente.

### Pieza forense de esta fase

**Los seis fallos, y cuál miente.** Ésta es la tabla que vas a consultar durante todo el cuaderno de incidentes.

| Lo que ves | Fallo probable | Cómo lo confirmas |
|---|---|---|
| Todo va lento pero funciona | `latency` | Network → Timing → **Waiting (TTFB)** alto, el resto normal |
| Falla una de cada tres recargas, con `500` | `error` | Recarga cinco veces; los éxitos y fallos se alternan |
| `200` verde y la pantalla dice que la respuesta no tiene la forma esperada | `malformed` | Network → Response: el cuerpo es un objeto donde esperabas un array |
| Network dice `(failed)` sin status, y la consola habla de `Access-Control-Allow-Origin` | `cors` | El `status` del `HttpErrorResponse` es **0** |
| Entras y te devuelve al login de inmediato | `expired` | Decodifica el token: su `exp` está en el pasado |
| Spinner eterno, la petición se queda en `pending` para siempre | `timeout` | Network → Status: `pending`. No hay error, no hay nada |

**El que miente es `malformed`, y por eso está aquí.** Los otros cinco se anuncian: hay un error rojo, un status raro, algo que mirar. `malformed` devuelve `200` con el cuerpo cambiado, así que **la pestaña Network te dice que todo salió bien**. Si te fías del semáforo verde, te pasas media hora leyendo tu código de componente buscando un bug que está en el borde HTTP.

La segunda mentira es más sutil y es de `cors`: la consola del navegador te dice claramente que es un problema de CORS, pero el `status: 0` que ve tu código es **idéntico** al de un servidor caído o al de una red ausente. Desde dentro de la aplicación no puedes distinguirlos: la información sólo existe en la consola, y por eso el mensaje que escribimos en `toApiError` menciona las tres posibilidades en vez de adivinar una.

> 📄 El recorrido completo, con la salida literal de cada fallo y el árbol de decisión, en `forense-fase-03.md`.

**🧨 Rompe a propósito**

Borra la comprobación `Array.isArray` de `TemplateApiService.getAll()`, corre con `CHAOS=malformed CHAOS_RATE=1 npm run mock` y entra a Plantillas. Responde:

1. ¿Dónde explota ahora, exactamente? Copia el mensaje y el archivo que señala.
2. ¿Cuántas capas hay entre donde explota y donde está el problema de verdad?
3. Si el `errorMessage` del componente se hubiera pintado, ¿qué habría leído el usuario?
4. Las tres líneas del guard, ¿te parecen caras a este precio?

---

## 🧪 7. Ejercicios (26)

**🟢 Fácil (1–7)**

1. Instala json-server con la versión exacta, levanta el mock y verifica con `curl` que `/templates` devuelve tres filas y `/clients` tres. Demuestra con `npm ls json-server` que no quedó ningún `^`.
2. Pide `GET /inspections/503/findings` y explica qué campo del `db.json` hace posible esa ruta anidada sin haber configurado nada.
3. **Diagnóstico.** Levanta con `CHAOS=latency` y mide en Network cuánto tarda la petición de plantillas. Di en qué fila exacta del panel Timing se ve el retraso, y en cuál **no** se ve.
4. Crea una plantilla nueva con un `POST` a `/templates`, comprueba que quedó en `db.json`, y devuélvelo a su estado original con `npm run seed`. Después explica en una línea qué habría hecho `git checkout -- mock/db.json` en su lugar, y por qué no es lo mismo.
5. **Diagnóstico.** Levanta con `CHAOS=cors` y entra a Plantillas. Anota tres cosas: el mensaje literal de la consola, el status que muestra Network, y el `status` que recibe tu código. Explica por qué no es un `403`.
6. Pide la v1 y la v2 de `elevator-annual` por separado y lista **las dos diferencias** entre sus `items`. Una es evidente y la otra no.
7. Arranca con `CHAOS=latencia` (en español, mal escrito) y explica qué pasa y por qué preferimos que pase eso.

**🟡 Intermedio (8–15)**

8. **Diagnóstico.** Con `CHAOS=error`, recarga la pantalla de Plantillas veinte veces y cuenta los fallos. Compara con `CHAOS_RATE`. Después ponlo en `1` y en `0.1` y comprueba que la cuenta acompaña.
9. Escribe `AssetApiService` completo siguiendo el molde de 5.10, con `getAll()` y `getByClient(clientId)`. Criterio: `getByClient(1)` devuelve exactamente dos activos.
10. **Diagnóstico.** Con `CHAOS=malformed CHAOS_RATE=1`, describe qué ve el usuario, qué mensaje se pinta, y en qué línea del código se detuvo el flujo. Compáralo con lo que pasa cuando el guard no está (ejercicio 11).
11. Haz el 🧨 de la sección 6 y entrega las cuatro respuestas.
12. **Diagnóstico.** Con `CHAOS=timeout CHAOS_RATE=1`, describe el estado de la petición en Network y explica por qué el navegador no la corta él solo. ¿Cuánto tiempo estaría así?
13. Con `CHAOS=latency CHAOS_DELAY_MS=8000`, entra a Plantillas y **navega a otra ruta antes de que responda**. Añade un `console.log` en el `ngOnDestroy` y otro en el `next` del `subscribe`, y demuestra cuál de los dos se ejecuta. Explica qué habría pasado sin el `unsubscribe`.
14. Usa `getByVersion('elevator-annual', 1)` para pintar los ítems de la v1 en la pantalla de Plantillas. Criterio: aparecen tres ítems y `cabin-lighting` **no** está entre ellos.
15. **Diagnóstico.** Cambia a mano el `templateVersion` de la inspección 501 a `9` y pide su plantilla con `getByVersion`. Describe qué error se produce, en qué capa nace, y qué mensaje llega al usuario. Restaura con `npm run seed`.

**🟠 Difícil (16–21)**

16. **Diagnóstico.** Corre con `CHAOS=latency,error CHAOS_RATE=1` y determina experimentalmente en qué orden actúan los dos fallos: ¿el `500` llega retrasado o inmediato? Explica el resultado leyendo `createChaosMiddleware`, y di si el orden que elegimos es el correcto.
17. Añade un séptimo fallo al inyector: `truncated`, que devuelve sólo la primera mitad de un array. Documéntalo en `mock/README.md` con el mismo formato que los otros seis, y provoca con él un bug que el `Array.isArray` **no** detecte.
18. Añade `timeout(10_000)` de RxJS a `TemplateApiService.getAll()` y comprueba con `CHAOS=timeout CHAOS_RATE=1` que ahora el usuario ve un error en lugar de un spinner eterno. Después argumenta en cinco líneas dónde debería vivir ese timeout —en cada servicio, en un interceptor, o en ningún sitio— y qué le pasa a una subida de evidencia de 20 MB si lo pones en el interceptor.
19. **Diagnóstico.** Mueve `app.use(requireToken)` por encima de `app.use(createAuthRouter(chaos))`. Reinicia, intenta entrar, y describe el resultado. Enuncia con tus palabras la regla de orden que acabas de comprobar, y di qué otro middleware de este servidor la ilustra igual de bien.
20. Construye `mock/db.incidente-04.json`: una copia de la semilla donde la inspección 500 apunta a `templateVersion: 5`, que no existe. Verifica que la aplicación falla de forma diagnosticable —con mensaje, no con pantalla en blanco— y commitea el archivo como escenario, según la convención de git.
21. **Diagnóstico.** `CERT-2024-000502` tiene `"status": "valid"` y un `validUntil` que ya pasó. Explica por qué el dato dice una cosa y el reloj otra, en qué momento exacto empezó a mentir, y qué habría que cambiar para que no pudiera volver a pasar. No lo implementes: es la Fase 10.

**🔴 Muy difícil (22–26)**

22. Escribe el post-mortem completo de ocho puntos del incidente **04** siguiendo `formato-cuaderno-incidentes.md` §7, con su par de tags `inc/04/<slug>-roto` / `-fix`. Indica también cuál de las **tres formas de preparación** de §4 usarías para reproducirlo y por qué es la más barata que sirve.
23. Reescribe `seed.js` para que calcule las fechas de vigencia de los certificados **relativas a hoy**: uno vencido hace un mes, uno vigente y uno que vence en veinte días. Después argumenta qué pierdes al hacerlo —piensa en `git diff`, en reproducir el enunciado de un incidente seis meses después, y en los tests de la Fase 12— y decide si lo dejarías puesto.
24. **Diagnóstico.** Ticket: *"el listado de plantillas a veces sale vacío y a veces no"*. Al menos tres configuraciones del inyector producen algo que encaja con esa frase. Identifícalas, diseña un árbol que las separe en **dos pasos**, y verifica tu árbol provocando las tres.
25. Reconstruye la tabla 🩺 de la sección 6 sin mirarla: seis filas, con lo que ves y cómo lo confirmas. Después compárala con la del capítulo y anota las diferencias — las tuyas pueden ser mejores, y si lo son, cámbialas en `mock/README.md`.
26. **Diagnóstico.** El guard de forma protege `getAll()` pero no `getByVersion()`, ni `getById()`, ni los tres servicios que faltan. Recorre el borde HTTP completo, enumera **todos** los puntos donde el tipo declarado puede estar mintiendo, y decide en cuáles pondrías validación y en cuáles no. Justifica cada decisión con el costo de equivocarte, no con una regla general. Implementa las que decidas.

**🔥 Opcionales**

- 🔥 Añade `retry({ count: 2, delay: 500 })` a un `ApiService` y corre con `CHAOS=error`. Después responde lo difícil: ¿qué pasa si la petición que reintentas es un `POST` que crea una inspección?
- 🔥 Haz que el inyector de caos se pueda cambiar en caliente con un endpoint `POST /chaos` en vez de reiniciar el mock. Decide si eso mejora el curso o lo empeora, y argumenta.
- 🔥 Sirve el mock en un puerto distinto y provoca un CORS real —no simulado— sin tocar `chaos.js`. Compara los dos mensajes de consola.

---

## 📚 8. Referencias

**Documentación oficial**

- https://github.com/typicode/json-server/tree/v0.17.4 — la versión exacta que usa el curso. Las secciones de rutas de filtro (`?campo=valor`) y rutas anidadas son las dos que vas a releer.
- https://expressjs.com/es/guide/using-middleware.html — el orden de los middlewares, en español y con ejemplos. Es la lectura que hace clara la sección 5.5.
- https://v16.angular.io/guide/http#error-handling — manejo de errores con `HttpClient` en la versión del curso, incluido `HttpErrorResponse` y el `status: 0`.
- https://v16.angular.io/api/common/http/HttpParams — construir la query de `getByVersion` sin concatenar cadenas.
- https://rxjs.dev/api/operators/catchError y https://rxjs.dev/api/index/function/throwError — los dos operadores de `toApiError`. Complementan **A06**.
- https://developer.mozilla.org/es/docs/Web/HTTP/CORS — CORS explicado desde el navegador, que es desde donde lo vas a sufrir. La sección de peticiones con verificación previa (`OPTIONS`) explica el `sendStatus(204)` de `server.js`.
- https://developer.mozilla.org/es/docs/Web/API/Fetch_API/Using_Fetch#comprobando_que_la_petición_es_correcta — por qué una respuesta de error sigue siendo una respuesta "exitosa" a nivel de red, que es la raíz de la confusión con `status: 0`.

> ⚠️ json-server publicó una versión 1.x con una API distinta y sin compatibilidad hacia atrás. Todo lo que encuentres escrito de 2024 en adelante puede estar hablando de esa otra librería: la del curso es la **0.17.4**, y la URL de arriba lleva a su tag exacto.

**Video y apoyo**

- Cualquier introducción a middlewares de Express sirve para esta fase, y hay decenas. ⚠️ Busca por tema y no por enlace: los identificadores de video cambian y no vamos a inventar uno.

**Orden de lectura sugerido**

Antes de escribir código: la guía de middlewares de Express, que son quince minutos y hacen que la sección 5.5 se lea sola. Durante: la página de json-server, cuando llegues al `db.json`, sobre todo el apartado de filtros. Después: la sección de manejo de errores de `HttpClient` y **A06** — vuelve a ellas cuando hayas visto los seis fallos con tus ojos, porque hasta entonces `catchError` es abstracto y después ya no.

---

## 🚀 9. Cierre y conexión con la siguiente fase

CertCore tiene backend. Un backend falso, sí, pero con el dominio entero sembrado —dos versiones de la misma plantilla incluidas—, con autenticación real, y con la capacidad de portarse mal a voluntad. Y tienes cinco `ApiService` tipados, un error de dominio que traduce en vez de tragar, y una pantalla que muestra tres mensajes distintos para tres fallos distintos.

Lo que de verdad te llevas de hoy no es el mock: es haber visto los seis fallos con tus ojos y saber cuál miente. La próxima vez que alguien diga "el backend está raro", tú vas a preguntar si es lento, si es intermitente, o si responde bien y con el cuerpo cambiado — y esas tres preguntas te ahorran la tarde.

La **Fase 4** ataca la 💸 que dejaste en `TemplateListComponent`. Ahora mismo esa pantalla pide sus plantillas y se las guarda para ella sola. Cuando en la Fase 6 haya cuatro pantallas necesitando saber qué plantilla está vigente, cuatro peticiones y cuatro copias del mismo dato dejan de ser una molestia y pasan a ser un bug: dos pantallas mostrando cosas distintas al mismo tiempo. La Fase 4 mete el `BehaviorSubject` privado y el `Observable` público entre el componente y el `ApiService`, y con ellos llega la otra mitad del asunto — quién se suscribe, quién se desuscribe, y por qué las fugas del curso nacen ahí.

> **La señal de que quedó bien:** cuando algo falla y, antes de abrir el código, ya has mirado el status y sabes si el problema está en la red, en el servidor o en la forma de la respuesta.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-03 -m "F3 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 03: …`) y los de ejercicio su
> número (`fase 03 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f03/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Antes de etiquetar, **corre `npm run seed`**. A partir de hoy `mock/db.json`
> es un archivo vivo que se ensucia con cada ejercicio, y un tag de fase con la
> base de datos hecha un campo de batalla no sirve como punto de retorno: el
> cuaderno de incidentes va a mandarte aquí durante cuatro semanas esperando el
> escenario limpio. Los `db.incidente-NN.json` que construyas sí se commitean
> tal cual, que para eso son.

---

## 📌 Pendientes sugeridos

- 🪦 **El modelo de referencia de `alcance-del-proyecto.md` §5.1, actualizado.** Esta fase cambió dos cosas por necesidad: el `id` compuesto de las plantillas (sin él, v1 y v2 no coexisten) y la colección `findings` (que §5.3 ya nombraba en su endpoint pero §5.1 no modelaba). Las dos están ya reflejadas en §5.1, con sus notas. → **Cerrado**, sin acción pendiente.
- **`ChecklistTemplate` se aparta del diccionario de la guía §5.2**, que mapea "plantilla" a `template` a secas. La desviación tiene motivo —"plantilla" ya significa otra cosa en un curso de Angular— y debería quedar escrita junto a la excepción de `AuthService` que dejó la Fase 2. → **Decisión de proyecto**, dos líneas en §5.2.
- **El `status` almacenado de los certificados** es una bomba de relojería puesta a propósito: el ejercicio 21 la nombra y la **Fase 10** tiene que desactivarla convirtiéndolo en derivado. Si la Fase 10 no lo hace, el `db.seed.json` queda mintiendo para siempre. → **Aviso para el chat de la Fase 10.**
- **Las fechas fijas de la semilla envejecen.** Hoy es una virtud (deterministas, diffables, reproducibles) y dentro de dos años todos los certificados estarán vencidos. El ejercicio 23 explora la alternativa. Si el curso llegara a distribuirse ampliamente, conviene decidirlo. → **Decisión de proyecto**, sin urgencia.
- **La Fase 11 va a necesitar más certificados** para que el dashboard de "por vencer a 30/60/90 días" tenga qué mostrar. La semilla trae dos, y ampliarla es barato hoy y caro cuando seis fases dependan de ella. → **Aviso para el chat de la Fase 11**: si añades filas, van en `db.seed.json` y no en `db.json`.
- **El endpoint `POST /chaos`** del ejercicio 🔥 es tentador y probablemente una mala idea: reiniciar el mock es lo que hace que el escenario sea reproducible. Si alguien lo implementa, que lo justifique. → **Ejercicio 🔥, y no más que eso.**
- 🔥 **Un diagrama de la tubería de middlewares** —CORS, caos, auth, datos— ayudaría en 5.5 tanto como el de la petición de la Fase 2. Pendiente de ilustración.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 04 | "La pantalla de plantillas a veces carga y a veces se queda pensando" | Integración | 🟢 |
