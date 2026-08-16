# 🕵️ Forense Fase 00 — "Le di guardar y no pasó nada"

> Pieza forense de la **Fase 0 — Setup + hola mundo standalone** · Recorrido: ~25 min
> Herramientas: consola · pestaña Network · source maps
> Síntoma que cubre: el usuario pulsó un botón, no ve ningún error, y no está seguro de si se guardó.

Es el síntoma más frecuente de todos y el que menos información trae. "No pasó nada" puede significar cinco cosas distintas, y las cinco se distinguen en menos de un minuto **sin abrir un solo archivo**. Ésa es la ruta.

El resumen de en qué miente cada herramienta está en la sección 6 de la fase. Aquí está el recorrido con la salida de cada paso.

---

## 🎫 El ticket

> *"Llené el formulario de solicitud para el ascensor de la torre A, le di a Solicitar inspección y no pasó nada. No sé si quedó. Lo hice tres veces."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** desarrollo, con `npm run mock` y `ng serve` corriendo

Fíjate en el dato que el reporte trae sin saberlo: **lo hizo tres veces**. Si la petición sí salía, hay tres solicitudes en el mock. Eso ya es una comprobación.

---

## 🧭 La ruta

Cinco pasos, ordenados **del más barato al más caro**. El paso 1 cuesta diez segundos y descarta la mitad de los casos; el paso 5 cuesta un build entero. Nunca al revés.

### Paso 1 — ¿La petición llegó a salir?

DevTools → **Network** → filtro `Fetch/XHR` → *Preserve log* activado → pulsa el botón otra vez.

```
Name                    Status    Type    Initiator            Size     Time
inspection-requests     201       xhr     zone.js:xxxx         241 B    12 ms
```

**Qué descarta.** Si aparece una fila, el navegador habló con alguien: no es un problema de que el botón no esté conectado, ni de que el formulario esté inválido y no dispare. Salta al **paso 3**.
Si **no aparece ninguna fila**, la petición nunca salió y el problema está antes: paso 2.

### Paso 2 — Si no salió: ¿el botón llega a llamar al método?

El formulario de la Fase 0 no envía si es inválido. Con el formulario abierto, en la consola:

```js
// $0 es el <form> seleccionado en el inspector de elementos.
const component = ng.getComponent($0);
component.form.status;   // 'INVALID'
component.form.errors;   // null  ← el grupo está bien; el problema está en un control
Object.entries(component.form.controls)
  .filter(([, control]) => control.invalid)
  .map(([name, control]) => [name, control.errors]);
// [ [ 'assetId', { required: true } ] ]
```

**Qué descarta.** Si sale un control inválido, no hay bug: hay un campo vacío y un mensaje que no se está mostrando — que **sí** es un bug, pero de interfaz, no de guardado. Si el formulario está `VALID` y aun así no sale nada por Network, entonces el `(ngSubmit)` no está conectado o hay una excepción antes del `subscribe`, y eso sí está en la consola.

### Paso 3 — ¿A qué URL, exactamente?

Clic en la fila → pestaña **Headers** → **Request URL**. Completa, con puerto y ruta.

```
Request URL:     http://localhost:3000/inspection-requests
Request Method:  POST
Status Code:     201 Created
```

**Qué descarta.** Aquí se cazan los dos errores más tontos y más frecuentes del curso, y los dos producen síntomas distintos:

| Lo que ves | Qué pasó |
|---|---|
| `http://localhost:4200/inspection-requests` | la URL base quedó relativa: le estás pidiendo al servidor de desarrollo, no al mock |
| `http://localhost:3001/…` con el mock en el 3000 | puerto equivocado → **no hay respuesta**, y el status es `(failed)` |
| `…/inspection-request` en singular | ruta equivocada → `404`, con cuerpo `{}` |
| `http://localhost:3000/inspection-requests` con `201` | la petición está bien. Sigue al paso 4 |

### Paso 4 — Un `201` no significa que hiciera lo que crees

Pestaña **Payload** —lo que enviaste— y pestaña **Response** —lo que devolvió—. En ese orden.

```json
// Request Payload
{
  "assetId": "ASC-CENTRAL-03",
  "requestedFor": "2025-03-14"
}
```

```json
// Response
{
  "assetId": "ASC-CENTRAL-03",
  "requestedFor": "2025-03-14",
  "id": 1
}
```

**Qué descarta.** El servidor guardó. Si el ticket dice que "no quedó", ya sabes que sí quedó y que el problema es que **la pantalla no lo dijo**: falta el mensaje de confirmación, o el `subscribe` tiene `next` y no hace nada visible. Ése es el bug, y está en el componente.

Y aquí aparece el otro hallazgo, el que la fase deja marcado 💸: `requestedFor` viaja como `"2025-03-14"`, **sin offset**. El servidor no se queja, el `201` es verde, y el dato está incompleto desde el primer día. No es el bug de este ticket; es el bug de la Fase 10, sembrado aquí.

### Paso 5 — Cuando la consola está limpia y aun así algo falló

Éste es el paso que explica por qué la consola miente por omisión:

```ts
// ❌ Esto traga el fallo entero. Petición fallida, pantalla congelada,
//    consola impecable.
this.http.post<InspectionRequest>(url, payload).subscribe((created) => {
  this.saved = true;
});

// ✅ Con el callback de error puesto, el fallo tiene dónde aparecer.
this.http.post<InspectionRequest>(url, payload).subscribe({
  next: (created) => { this.saved = true; },
  error: (error: unknown) => { console.error('No se pudo guardar la solicitud', error); },
});
```

Si el código bajo investigación no tiene `error`, **la consola limpia no es evidencia de nada**. Ponlo antes de sacar conclusiones; es la primera línea que se añade en cualquier investigación de este tipo.

Y el caso que cierra el paso: en un build de producción, la consola muestra el stack minificado.

```
ERROR TypeError: Cannot read properties of null (reading 'value')
    at t.<anonymous> (main.8a1f2c.js:1:48213)
```

Con `sourceMap.hidden: true` puesto y el `.map` al lado, DevTools traduce esa línea al archivo y la línea reales. Sin él, `main.8a1f2c.js:1:48213` es todo lo que vas a tener nunca. Es la diferencia entre una investigación de diez minutos y una de dos días, y la fase la deja preparada a propósito.


**Aquí termina la ruta.** El síntoma ya es concreto: hay una línea de código, un archivo y un momento. Con eso el ticket deja de decir *«no pasó nada»* y pasa a decir algo que se puede arreglar — que es todo lo que una pieza forense promete.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves en Network | Lo que significa | Dónde miras |
|---|---|---|
| Ninguna fila | la petición no salió | el formulario y el `(ngSubmit)` — paso 2 |
| `(failed)` sin status | nadie contestó: puerto, servidor caído o CORS | la URL y si el mock está vivo |
| `(failed)` y la consola habla de `Access-Control-Allow-Origin` | CORS | Fase 3; desde el código es indistinguible de un servidor caído |
| `404` | la ruta no existe | plural, guiones, la barra final |
| `201` / `200` y la pantalla no reacciona | el servidor hizo su trabajo | el `subscribe` del componente |
| `200` con un cuerpo que no es lo que esperabas | el borde HTTP | Fase 3 — es `malformed` |
| `500` | el servidor reventó | los logs del mock, no tu código |

---

## ⚰️ Los callejones

**"Es que el mock no está corriendo."** Se descarta en cinco segundos y sin salir de la terminal:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/inspection-requests
# 200 → está vivo
# 000 → no hay nadie escuchando en ese puerto
```

**"Es que el formulario borra los datos al enviar."** Plausible y falso: si `reset()` fuera el culpable, el payload del paso 4 estaría vacío o con `null`. Está completo, así que el problema es posterior al envío.

**"Es que Angular no detectó el cambio."** El sospechoso favorito y casi nunca el culpable. En la Fase 0 no hay `OnPush` en ninguna parte, así que la detección por defecto revisa todo ante cualquier evento. Si la pantalla no cambió, es porque **nadie cambió nada que pintar**, no porque no se enteró.

---

## 🧨 Deshacer

El 🧨 de la fase te hace cambiar el puerto de `API_BASE_URL` de `3000` a `3001`. Devuélvelo a `3000` en `src/environments/environment.ts` y `ng serve` recompila solo. Si probaste también la ruta en singular, la misma línea.

Las solicitudes que se crearon durante la investigación quedan en el `db.json`; `npm run seed` lo devuelve a la semilla.

---

## 🧠 El patrón transferible

> **"No pasó nada" no es un síntoma: es la ausencia de uno.** El trabajo es convertirlo en un síntoma concreto, y la conversión cuesta un minuto: ¿salió la petición?, ¿a dónde?, ¿qué contestó?, ¿qué mandaste? Cuatro preguntas, cuatro pestañas, y ninguna requiere leer código.

Y el corolario que vale para cualquier stack: **una consola limpia sólo es evidencia si sabes que alguien estaba escuchando.** Un `catch` vacío, un `subscribe` sin `error`, un `.catch(() => {})` en un `Promise`: los tres producen exactamente este ticket.

**Incidentes del cuaderno que usan esta ruta:** 01 (el proyecto que no arranca) y 03 (la sesión que se cae sin decir nada).
**Amplía:** **A03** para el entorno y las versiones, **A06** §6 para qué hacer con el error una vez que aparece.
