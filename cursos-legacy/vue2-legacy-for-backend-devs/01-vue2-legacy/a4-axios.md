# 🌐 Apéndice 4 — axios (repaso de consulta)

## 🎯 Para qué sirve este apéndice

axios es el sistema circulatorio del Mini Jira desde la Fase 0, pero sus
piezas se explicaron repartidas en cinco fases. Este apéndice las junta:
instancias, config, la forma exacta de respuesta y error, interceptores y
cancelación — con el ancla de dónde vive cada cosa en el proyecto. Consúltalo
cuando un request se comporte raro o cuando toque extender `apiClient`.

Versión del curso: **0.21.1** (F0) — la era pre-1.x, la que domina el legacy.

---

## ⚔️ axios vs fetch — por qué la época eligió axios

`fetch` es nativo del navegador; axios es una librería. En 2018–2021 la
elección era casi unánime, por razones que siguen explicando el código que
mantendrás:

| | fetch nativo | axios |
|---|---|---|
| JSON | a mano: `res.json()` (¡otra Promise!) | automático: `res.data` ya parseado |
| Errores HTTP (404, 500) | **NO rechaza** — resuelve con `res.ok=false` 💀 | **rechaza** la Promise: tu `.catch` los ve |
| Interceptores | no existen | ✅ el token de la F2 en una línea |
| Instancias con baseURL | no | ✅ `apiClient` |
| Timeout | no (era AbortController manual) | opción `timeout` |
| params → query string | a mano | opción `params` |
| IE11 (real en la época) | no sin polyfill | sí |

La fila en negrita es la trampa histórica: código legacy migrado de axios a
fetch "para quitar la dependencia" que de pronto trata los 500 como éxito. Si
ves `fetch` en un legacy, busca el `if (!res.ok) throw` — si no está, ahí hay
un bug dormido.

---

## 🏭 Instancias — el patrón `apiClient`

```js
// services/apiClient.js (F2/F3) — LA pieza central
var apiClient = axios.create({
  baseURL: "http://localhost:3000"
  // otras opciones de instancia: timeout: 10000, headers comunes...
});
```

`axios.create` produce una copia con configuración propia. El principio del
curso: **nadie fuera de `services/` importa axios** — todos importan
`apiClient`. Un solo lugar para baseURL, token, timeouts y manejo
transversal. Cuando el legacy que heredes tenga `axios.get("http://...")`
regado por los componentes, ya sabes cuál es el refactor y por qué.

(El singleton sale gratis: los módulos ES se evalúan una vez — Apéndice 2.)

## 📤 Anatomía del request

```js
apiClient.get("/tickets", {
  params: { status: "open", _sort: "createdAt" }  // → ?status=open&_sort=createdAt
});

apiClient.post("/tickets", payload);          // el 2º argumento ES el body
apiClient.patch("/tickets/" + id, changes);   // parcial (F3: PATCH vs PUT)
apiClient.delete("/tickets/" + id);

// forma general equivalente:
apiClient({ method: "get", url: "/tickets", params: {...}, data: {...} });
```

⚠️ La asimetría que causa bugs: en `get`/`delete` el segundo argumento es
**el objeto de config** (con `params` adentro); en `post`/`put`/`patch` el
segundo es **el body** y la config va tercera. El clásico
`apiClient.get("/tickets", { status: "open" })` — sin el `params:` — manda
una config inválida y cero query string, silenciosamente. 📍 Los tests del
servicio (F11) vigilan exactamente esta forma:
`toHaveBeenCalledWith("/tickets", { params: {...} })`.

## 📥 Anatomía de la respuesta

```js
{
  data:    ...,   // el body, ya parseado si era JSON — LO ÚNICO que sueles querer
  status:  200,
  headers: {...},
  config:  {...}  // el request que la originó (útil en interceptores)
}
```

📍 De aquí la regla de la Fase 3: **los servicios devuelven `res.data`, no la
respuesta** — las vistas y el store no deben conocer la forma del sobre de
axios, solo la carta. (Y el test del servicio en F11 verifica ese contrato.)

## 💥 Anatomía del error — el árbol de diagnóstico

Cuando la Promise rechaza, el `error` trae la clave del diagnóstico:

```js
.catch(function (error) {
  if (error.response) {
    // 1) EL SERVIDOR RESPONDIÓ con 4xx/5xx
    error.response.status   // 404, 401, 422, 500...
    error.response.data     // el body del error (mensajes del backend)
  } else if (error.request) {
    // 2) EL REQUEST SALIÓ pero NADIE respondió
    //    servidor caído, red muerta, CORS bloqueó la respuesta, timeout
  } else {
    // 3) NI SIQUIERA SALIÓ: error armando el request (config inválida)
    error.message
  }
});
```

📍 En el curso: la rama 1 diferenció el 404 del detalle (F3) y el 401 del
interceptor (F2 ej. 23 / F3 ej. 24); el ejercicio 19 de la F3 construyó
mensajes distintos por rama ("sin conexión" vs status). En mantenimiento,
preguntar "¿response, request, o ninguno?" ante cualquier error HTTP te
ahorra la mitad del debugging: **respondió mal / no respondió / no salió**
son tres problemas de tres mundos distintos.

Nota CORS: un bloqueo CORS cae en la rama 2 con un mensaje genérico — el
detalle real está en la **consola del navegador**, no en el objeto error, y
la solución vive en el **servidor** (o en el proxy del dev server, Apéndice
5), nunca en axios. "Arreglar CORS con axios" es el molino de viento clásico.

## 🚦 Interceptores — el middleware del cliente

```js
// REQUEST: se ejecuta ANTES de salir cada request (F2: el token)
apiClient.interceptors.request.use(function (config) {
  var token = localStorage.getItem("token");
  if (token) config.headers.Authorization = "Bearer " + token;
  return config;   // ⚠️ SIEMPRE devolver config — olvidarlo mata el request
});

// RESPONSE: se ejecuta al volver — dos manejadores: éxito y error
apiClient.interceptors.response.use(
  function (response) { return response; },       // pasa de largo
  function (error) {
    if (error.response && error.response.status === 401) {
      // limpiar sesión + redirigir (F2 ej. 23 / F3 ej. 24)
    }
    return Promise.reject(error);  // ⚠️ re-rechazar: si no, los .catch de
  }                                //    los servicios ven un ÉXITO undefined 💀
);
```

Las dos flechas ⚠️ son los dos bugs de interceptor más comunes del legacy:
el request interceptor que olvida el `return config` (requests que
"desaparecen") y el response interceptor de error que no re-rechaza (errores
que se vuelven éxitos fantasma — la versión interceptora del verde falso de
la F11).

Reglas de convivencia: aplican **por instancia** (los de `apiClient` no tocan
un `axios.get` suelto — otra razón para el patrón), los de request corren en
orden inverso al registro y los de response en orden directo (detalle que
solo importa con varios: el de timing de la F3 ej. 20 + el de auth), y se
pueden quitar con el id que devuelve `use()` → `interceptors.request.eject(id)`.

## ✂️ Cancelación (la de la época: CancelToken)

Para el problema del ejercicio 22 de la F7 (respuestas viejas ganándole a
nuevas), la solución de raíz es cancelar el request obsoleto:

```js
var CancelToken = axios.CancelToken;
var cancel;

apiClient.get("/tickets", {
  cancelToken: new CancelToken(function (c) { cancel = c; })
});

// al disparar una búsqueda nueva:
if (cancel) cancel("obsoleto");

// y en el catch, distinguir cancelación de error real:
if (axios.isCancel(error)) return; // silencio: fue a propósito
```

⚰️ `CancelToken` está deprecado en axios ≥0.22 a favor de `AbortController` —
pero en 0.21.x (y en todo el legacy que verás) es CancelToken o nada.
Reconoce ambos.

---

## 📎 Subida de archivos: `multipart/form-data`

El Mini Jira los rozó como mock (adjuntos del wizard, F6 ej. 18). Aquí va lo
real — y es la operación HTTP que más se hace mal en legacy.

### El concepto: por qué NO sirve JSON

Un JSON es texto. Un archivo es **binario** (una imagen, un PDF, un ZIP). Para
mandarlo por HTTP hay dos caminos:

| | JSON + base64 | `multipart/form-data` |
|---|---|---|
| Cómo | codificas el binario a texto y lo metes en el JSON | el body se parte en "trozos" (parts), cada uno con su nombre, tipo y contenido crudo |
| Tamaño | **+33%** (base64 infla) | 1:1, sin inflar |
| Memoria | el archivo entero en un string, en RAM | streaming, el navegador lo maneja |
| Mezclar campos + archivos | fácil (todo es JSON) | fácil también (cada campo es un part) |
| Progreso de subida | difícil | ✅ nativo |
| Cuándo | archivos diminutos, APIs que lo exigen | **el estándar, siempre que puedas** |

Multipart es literalmente el body del `<form enctype="multipart/form-data">`
de toda la vida — el que existía antes de las SPA. Un body multipart, por
dentro, se ve así (el navegador lo arma; tú nunca lo escribes a mano):

```
------WebKitFormBoundary7dR3sT   ← el "boundary": el separador
Content-Disposition: form-data; name="ticketId"

42
------WebKitFormBoundary7dR3sT
Content-Disposition: form-data; name="file"; filename="captura.png"
Content-Type: image/png

<...bytes crudos del PNG...>
------WebKitFormBoundary7dR3sT--   ← cierre
```

### El código: `FormData` + axios

```js
// 1) En el template: un input de tipo file.
//    ⚠️ v-model NO funciona con inputs file (el value es de solo lectura por
//    seguridad del navegador): se usa @change y se lee event.target.files
```

```vue
<input type="file" @change="onFileSelected" accept="image/*,.pdf" />
<!-- multiple → permite varios; accept es una SUGERENCIA de UI, no validación -->
```

```js
// 2) En el servicio (services/attachmentService.js):
import apiClient from "./apiClient";

function upload(ticketId, file, onProgress) {
  var formData = new FormData();          // el sobre multipart
  formData.append("ticketId", ticketId);  // campos de texto: igual que un form
  formData.append("file", file);          // el File del input: axios detecta el binario

  return apiClient
    .post("/attachments", formData, {
      // ⚠️ NO pongas Content-Type a mano. Ver la trampa del boundary abajo.
      onUploadProgress: function (event) {
        if (event.lengthComputable && onProgress) {
          onProgress(Math.round((event.loaded / event.total) * 100));
        }
      }
    })
    .then(function (res) { return res.data; });
}

export default { upload: upload };
```

```js
// 3) En el componente:
data: function () {
  return { file: null, progress: 0, uploading: false, error: "" };
},
methods: {
  onFileSelected: function (event) {
    var files = event.target.files;
    this.file = files.length ? files[0] : null;  // FileList NO es un Array
  },
  submitUpload: function () {
    var self = this;
    if (!this.file) return;

    // validación en cliente: UX, no seguridad (el servidor debe revalidar)
    if (this.file.size > 5 * 1024 * 1024) {
      this.error = "El archivo supera los 5 MB.";
      return;
    }

    this.uploading = true;
    this.progress = 0;

    attachmentService
      .upload(this.ticketId, this.file, function (percent) {
        self.progress = percent;           // ← la barra de progreso, reactiva
      })
      .then(function (created) { self.$emit("uploaded", created); })
      .catch(function () { self.error = "No se pudo subir el archivo."; })
      .finally(function () { self.uploading = false; });
  }
}
```

### ⚠️ Las cinco trampas del multipart (todas las verás en legacy)

1. **NO fijes el `Content-Type` a mano.** El clásico
   `headers: { "Content-Type": "multipart/form-data" }` **rompe la subida**:
   el header debe incluir el boundary generado
   (`multipart/form-data; boundary=----WebKit...`), y el navegador lo pone
   solo *si lo dejas en paz*. Al escribirlo tú, pisas el boundary y el
   servidor no puede parsear el body. Es el bug de multipart #1 del mundo.
   (Si tu `apiClient` tuviera un Content-Type global de JSON, para este
   request hay que anularlo: `headers: { "Content-Type": undefined }`.)
2. **`v-model` no funciona en inputs file.** Usa `@change` + `event.target.files`.
3. **`files` es un `FileList`, no un Array**: no tiene `.map`/`.filter`. Para
   varios archivos: `Array.prototype.slice.call(files)` (o `Array.from`).
4. **Resetear el input es traicionero**: reasignar `this.file = null` no
   limpia el input del DOM (seguirá mostrando el nombre). Se limpia con
   `this.$refs.input.value = ""` — el `$refs` sobre elemento DOM de la F7,
   en su uso más justificado.
5. **La validación de cliente es UX, no seguridad.** `accept`, el chequeo de
   `size` y `type` se saltan con dos clics en DevTools. El servidor **debe**
   validar tipo, tamaño y contenido real (un `.png` puede ser un script
   renombrado). 📍 Misma moraleja que `SECURITY-NOTES.md` viene repitiendo
   desde la F2: *nada que arme el cliente es confiable*.

### Descargar archivos (el camino de vuelta)

```js
// responseType: "blob" → el binario llega como Blob, no como texto corrompido
apiClient.get("/attachments/" + id + "/download", { responseType: "blob" })
  .then(function (res) {
    var url = window.URL.createObjectURL(res.data);
    var link = document.createElement("a");
    link.href = url;
    link.download = "adjunto.pdf";
    link.click();
    window.URL.revokeObjectURL(url); // liberar: si no, el Blob vive en memoria
  });
```

El `revokeObjectURL` es la limpieza que el legacy olvida — mismo espíritu que
el `chart.destroy()` de la F7: **todo recurso creado a mano, se libera a
mano**.

📍 *json-server no procesa multipart* — para practicar de verdad, el
ejercicio 32 monta un endpoint de subida real con un middleware Node.

---

## ⚠️ Diagnóstico rápido

| Síntoma | Causa probable |
|---|---|
| El query string no llega | falta el envoltorio `params: {}` en get/delete |
| Multipart falla / el servidor no ve el archivo | fijaste `Content-Type` a mano y pisaste el boundary |
| El archivo descargado se corrompe | falta `responseType: "blob"` en el GET |
| `onUploadProgress` nunca se llama | el archivo es diminuto (un solo chunk), o el navegador no puede computar la longitud |
| "El interceptor no corre" | el request usó `axios` pelado, no la instancia |
| Requests que nunca salen ni fallan | interceptor de request sin `return config` |
| Errores HTTP que llegan como éxito con `undefined` | interceptor de response sin `Promise.reject` |
| Error genérico "Network Error" | rama `error.request`: servidor caído, o CORS (mira la consola del navegador) |
| 401 en todo tras el login | el header no se armó: revisa el interceptor y qué instancia usa el servicio |
| Doble slash o ruta rota (`//tickets`) | baseURL con `/` final + url con `/` inicial: elige una convención |
| El PATCH manda `[object Object]` | header Content-Type pisado a mano innecesariamente — axios lo pone solo |
| En tests, "Cannot read property 'get' of undefined" | falta el `jest.mock` de apiClient (F11), o el mock no cubre ese método |

---

## 🧪 Ejercicios (40) — todos opcionales

> Todo el contenido de los apéndices es **opcional**: material de consulta y
> práctica libre. Haz los que te sirvan, cuando te sirvan.

**🟢 Fácil (1–10)**

1. Agrega `timeout: 5000` al `apiClient`, arranca json-server con
   `--delay 8000` y observa en qué rama del árbol de error cae el timeout.
2. Provoca la rama `error.request`: apaga json-server y captura el error
   completo en consola. Compara su forma contra un 404 (rama response).
3. Rompe a propósito un `get` quitando el envoltorio `params:` y verifica en
   la pestaña Network que el query string desapareció sin error.
4. En Network, inspecciona un POST del curso completo: headers (¿está el
   Bearer?), payload, respuesta. Cinco minutos que valen oro.
5. Loguea la respuesta cruda de axios (`console.log(res)`) en un servicio y
   recorre sus cuatro campos (data, status, headers, config).
6. Cambia `baseURL` a algo con `/` final y una url con `/` inicial: observa
   el doble slash en Network. Define tu convención y documéntala.
7. Añade `headers: { "X-Cliente": "mini-jira" }` a la instancia y verifica
   que viaja en todos los requests.
8. Compara `PUT` vs `PATCH` con un ticket incompleto (F3 ej. 22, ahora
   mirando el body real en Network).
9. Escribe un `get` con `params` que incluya un valor con espacios y acentos:
   observa el encoding automático de axios.
10. Añade un `<input type="file">` a un componente de prueba, selecciona un
    archivo y loguea `event.target.files[0]`: mira name, size, type.

**🟡 Intermedio (11–22)**

11. Interceptor de request que loguee `config.method` y `config.url`.
    Verifica el orden si convive con el del token.
12. Interceptor de response del 401 completo: limpiar sesión + redirigir +
    mensaje. Pruébalo con el middleware que rechaza sin Authorization.
13. Reproduce el bug del re-reject: quita `Promise.reject` del interceptor
    de error y observa qué reciben los `.then` de los servicios. Restaura.
14. Reproduce el bug del `return config` faltante: quítalo y documenta el
    silencio absoluto que produce.
15. Interceptor de timing (F3 ej. 20): mide la duración de cada request
    usando `config.metadata` y loguéala al volver.
16. `attachmentService.upload` completo con `FormData` (aunque json-server lo
    rechace: mira el body multipart en Network — eso ya enseña).
17. Provoca la trampa #1: fija `Content-Type: multipart/form-data` a mano y
    compara el header resultante en Network contra la versión correcta.
    Captura ambos boundaries (o su ausencia).
18. Barra de progreso real con `onUploadProgress`: usa un archivo grande
    (>10 MB) y `--delay` o throttling de red en DevTools para verla moverse.
19. Multi-archivo: `<input multiple>`, convierte el `FileList` a Array y
    haz `formData.append("files", f)` por cada uno. Inspecciona el body.
20. Limpieza del input file: implementa el reset con `$refs.input.value = ""`
    tras subir, y verifica que el nombre del archivo desaparece de la UI.
21. Descarga con `responseType: "blob"`: sirve un PDF cualquiera desde una
    carpeta estática y descárgalo desde la app con el patrón del apéndice.
22. Validación en cliente: rechaza >5 MB y tipos no permitidos con mensajes
    claros. Luego sáltate tu propia validación desde DevTools y anota cómo
    lo hiciste (esa es la lección).

**🟠 Difícil (23–30)**

23. Búsqueda con cancelación (CancelToken): el filtro server-side del
    dashboard cancela el request anterior al disparar uno nuevo. Verifica
    con `--delay` que las respuestas viejas ya no pisan.
24. Extrae la baseURL a `VUE_APP_API_URL` (Apéndice 5) y haz que apiClient
    funcione igual en dev y en un build de producción.
25. Retry con backoff como **interceptor de response**: ante error de red
    (rama `request`), reintenta hasta 3 veces con 1s/2s/4s antes de rechazar.
    Cuidado con el loop infinito y con reintentar POSTs no idempotentes —
    discútelo en un comentario.
26. Cola de requests durante refresh de token (el patrón clásico): si un 401
    dispara un "refresh", los requests que llegaban mientras tanto deben
    encolarse y reintentarse tras el refresh, no fallar en cascada. Simula
    el refresh con un delay.
27. Subida cancelable: botón "Cancelar" durante el upload usando CancelToken;
    distingue en el catch la cancelación (`axios.isCancel`) del error real y
    resetea la barra.
28. Subida por trozos (chunked) de juguete: parte un archivo con
    `file.slice(start, end)` en trozos de 1 MB, súbelos secuencialmente con
    índice y total, y muestra el progreso agregado. (El servidor del ej. 32
    puede solo recibirlos y contarlos.)
29. Preview antes de subir: con `URL.createObjectURL(file)` muestra la imagen
    seleccionada, y **revoca** la URL en `beforeDestroy`. La disciplina de
    limpieza de la F7 aplicada a Blobs.
30. Test del servicio de subida (F11): mockea `apiClient` y verifica que el
    POST recibió un `FormData` con los campos correctos (pista: `FormData`
    en jsdom se puede inspeccionar con `.get("file")`).

**🔴 Muy difícil (31–40)**

31. Mini-axios pedagógico: una función `request(config)` sobre `fetch` que
    replique lo esencial — baseURL, params, JSON automático, **rechazo en
    status ≥400** y un array de interceptores de request. Úsala en UN
    servicio real del curso. Al terminar sabrás exactamente qué te regala
    axios (y qué te quitaría migrar a fetch a la ligera).
32. Endpoint de subida REAL: middleware Node (con `multer` o parseando el
    multipart a mano con `busboy`) montado en json-server; guarda los
    archivos en `uploads/`, devuelve `{id, filename, size, url}` y persiste
    la metadata en `db.json`. Conecta la UI de adjuntos del ticket
    end-to-end. Este es el ejercicio que convierte todo lo anterior en real.
33. Adjuntos completos en el Mini Jira: colección `attachments`, subida desde
    el workspace del panel (F9), listado con iconos por tipo, descarga y
    borrado. Emite un evento de socket (F8) para que otros agentes vean el
    adjunto nuevo en vivo. Integración de cuatro fases.
34. Drag & drop de archivos: zona de arrastre con los eventos
    `dragover`/`drop` (¡`preventDefault` en ambos o el navegador abre el
    archivo!), con feedback visual, listeners limpiados en `beforeDestroy`.
    Comparte código con el `<input file>` sin duplicar el servicio.
35. Pega desde el portapapeles: captura el evento `paste` y sube la imagen
    del clipboard como adjunto (el flujo real de una mesa de soporte:
    PrtScr → Ctrl+V). `event.clipboardData.items` es tu amigo.
36. Deduplicación por hash: antes de subir, calcula el SHA-256 del archivo
    con `crypto.subtle.digest` sobre el ArrayBuffer; si el hash ya existe en
    `attachments`, no subas — enlaza el existente. Mide el costo del hash en
    archivos grandes.
37. Subida resumible: guarda en localStorage qué trozos del ej. 28 se
    completaron; si el usuario recarga a mitad, ofrece "reanudar" y sube solo
    lo que falta. Maneja el caso de que el archivo local ya no sea el mismo.
38. Instrumentación completa de la capa HTTP: un módulo `httpMetrics` que,
    vía interceptores, registre por endpoint: cantidad, latencia p50/p95,
    tasa de error. Muéstralo en una vista `/debug` (solo en desarrollo).
    Acabas de construir un APM de juguete.
39. Refactor total a un cliente tipado por contrato: genera (a mano o con un
    script) un objeto `api` con un método por endpoint documentado en
    `API-CONTRACT.md` (F3 ej. 26), que valide en desarrollo que la respuesta
    tiene la forma esperada y avise en consola si el backend cambió el
    contrato. Discute qué problema real de legacy resuelve esto.
40. Migración honesta a fetch: reimplementa `apiClient` completo (baseURL,
    interceptores equivalentes, manejo de errores, cancelación con
    `AbortController`, multipart, progreso — ojo: **fetch no tiene progreso
    de subida**, investiga por qué y qué se hacía) manteniendo la MISMA
    interfaz pública, de modo que ni un servicio se entere. Cuando todos los
    tests de F11 pasen, escribe el veredicto: ¿valió la pena quitar la
    dependencia?

## 📚 Referencias

- axios — docs: https://axios-http.com/docs/intro
- Instancias: https://axios-http.com/docs/instance
- Config de request: https://axios-http.com/docs/req_config
- Manejo de errores: https://axios-http.com/docs/handling_errors
- Interceptores: https://axios-http.com/docs/interceptors
- Cancelación (CancelToken, la de la época): https://axios-http.com/docs/cancellation
- MDN — fetch (para la comparación honesta):
  https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API

**Subida de archivos**

- MDN — FormData: https://developer.mozilla.org/en-US/docs/Web/API/FormData
- MDN — File API (File, FileList, Blob):
  https://developer.mozilla.org/en-US/docs/Web/API/File_API
- MDN — usar archivos desde aplicaciones web:
  https://developer.mozilla.org/en-US/docs/Web/API/File_API/Using_files_from_web_applications
- MDN — URL.createObjectURL / revokeObjectURL:
  https://developer.mozilla.org/en-US/docs/Web/API/URL/createObjectURL
- MDN — multipart/form-data (spec del enctype):
  https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Content-Type
- multer (para el endpoint real del ej. 32): https://www.npmjs.com/package/multer
