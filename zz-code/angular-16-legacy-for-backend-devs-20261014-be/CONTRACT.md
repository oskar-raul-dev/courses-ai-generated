# CONTRACT.md — el contrato que habla el frontend de CertCore

> Fase be00. Documenta lo que el frontend (`certcore/`, hasta `fase-10`) **le pide** al servidor y lo que el
> mock (`npm run mock`) **le responde** hoy. No critica el diseño: lo transcribe. La crítica es de be02 y be07.
>
> **Cómo se obtuvo.** Sin navegador, así que **no hay captura de DevTools**. Las peticiones salen del código de
> cada `*ApiService` (método, ruta, parámetros, cuerpo) y se ejecutan con `curl` contra el mock limpio
> (`npm run seed`, sin flags de caos). Las respuestas son las reales del mock. Cuando la captura de DevTools
> esté disponible, las cabeceras que manda el navegador se contrastan aquí; hasta entonces, lo que sigue es
> lo que el código del cliente hace, no lo que un navegador hizo.
>
> **Cabeceras del cliente:** `Authorization: Bearer <jwt>` (interceptor de la Fase 2) y `X-Correlation-Id`
> (interceptor de la Fase 2). El `Accept` no se ha medido; no se documenta.
>
> **Verificación:** `smoke.sh` contra el mock da `OK: 26/26`. Ver §Discrepancias: la lección dice 24.

---

## POST /auth/login

**Quién lo llama:** `AuthService` (Fase 2), desde el formulario de `/login`.

**Petición**
- Cuerpo: `{ "email": string, "password": string }`.

**Respuesta 200**

```json
{ "accessToken": "eyJhbGciOiJIUzI1NiIs…", "expiresIn": 3600 }
```

El JWT lleva `sub`, `name`, `role`, `iat`, `exp`. `exp − iat = expiresIn`.

**Respuesta 401** — credenciales malas: `{ "message": "Credenciales inválidas" }`. El interceptor distingue 401
de 500 para decidir si cierra la sesión.

**Trampas**
- El caos no toca el login, salvo `CHAOS=expired`, que firma un token con `ttl = -60`.
- Ningún otro endpoint responde sin `Authorization: Bearer`: `401 {"message":"Falta el token de acceso"}`.

---

## GET /clients · GET /clients/:id · GET /clients?q= · GET /clients?taxId= · POST · PUT /clients/:id · DELETE /clients/:id

**Quién lo llama:** `ClientApiService` (Fase 6), desde `ClientStateService`. `?q=` lo usa el buscador (`search`);
`?taxId=` lo usa la comprobación de NIT duplicado.

**Respuesta 200 de la colección** — array desnudo:

```json
[ { "id": 1, "legalName": "Edificio Central S.A.S.", "taxId": "900123456" },
  { "id": 2, "legalName": "Clínica del Norte S.A.S.", "taxId": "901456789" },
  { "id": 3, "legalName": "Industrias Aurora S.A.S.", "taxId": "900987654" } ]
```

**Escritura**
- `POST /clients` → `201` con el objeto y su `id` asignado.
- `PUT /clients/1` → `200` con el objeto.
- `DELETE /clients/3` → `200` con `{}`.
- Id inexistente → `404` con `{}`.

**Trampas**
- `?q=` busca en **todos** los campos, no sólo en la razón social: `q=900` también encuentra por NIT. El frontend
  lo espera así (`client-api.service.ts`, comentario sobre el `search`).
- **`DELETE /clients/:id` destruye en cascada** (medido, no supuesto). Con `DELETE /clients/3` (cliente con dos
  activos), json-server 0.17 se llevó también los activos del cliente, **todas las plantillas y las cinco
  inspecciones**. Los `findings` y `certificates` quedaron. La UI lo impide cuando el cliente tiene activos; la
  API no. Es un comportamiento de json-server (`destroy` → `getRemovable`), no de CertCore. Ver §Trampas del mock.

---

## GET /assets · GET /assets/:id · GET /assets?clientId= · POST · PUT /assets/:id

**Quién lo llama:** `AssetApiService` (Fase 6). `?clientId=` lo usa `ClientStateService` para el aviso de borrado.

**Respuesta 200** — array desnudo:

```json
[ { "id": "ASC-CENTRAL-03", "clientId": 1, "type": "elevator",
    "description": "Ascensor lado norte, torre A", "installedAt": "2015-06-10" } ]
```

**Trampas**
- El `id` del activo es **texto escrito por el usuario** (`ASC-CENTRAL-03`), no un entero generado. Un ORM que
  asigne claves enteras rompe la relación con las inspecciones.
- `clientId` es **entero**; el de las plantillas no. Cruzar ambos sin convertir falla en silencio.

---

## GET /templates · GET /templates?templateId=&version= · GET /templates?templateId= · POST · PUT /templates/:id

**Quién lo llama:** `TemplateApiService` (Fase 7). `?templateId=&version=` lo usa `getByVersion` (la versión de
una inspección); `?templateId=` lo usa la línea de tiempo de la versión.

**Respuesta 200** — array desnudo. Semilla limpia, tres filas:

```json
[ { "id": "elevator-annual-v1", "templateId": "elevator-annual", "version": 1,
    "validFrom": "2021-01-01", "validUntil": "2023-12-31", "items": [ … ] },
  { "id": "elevator-annual-v2", "templateId": "elevator-annual", "version": 2,
    "validFrom": "2024-01-01", "validUntil": null, "items": [ … ] },
  { "id": "boiler-annual-v1", "templateId": "boiler-annual", "version": 1,
    "validFrom": "2022-01-01", "validUntil": null, "items": [ … ] } ]
```

Cada `items[]`: `{ id, title, criteria: [...], photoRequired, nonComplianceSeverity }`.

**Escritura**
- `POST /templates` → alta de una versión nueva.
- `PUT /templates/:id` → **cierre** de una versión: cambia sólo `validUntil`. Es la única escritura permitida
  sobre una versión publicada.

**Trampas**
- **`validUntil: null` significa "vigente indefinidamente", no "sin datos".** `resolveTemplateVersion` depende de
  esa lectura.
- Las vigencias de plantilla son **días desnudos** (`2024-01-01`), no instantes. Las de certificado son instantes
  con offset (`…-05:00`). Son dos tipos distintos.
- **El array no viene ordenado por nada garantizado.** json-server devuelve el orden de inserción; el frontend no
  ordena. Otro orden cambia la pantalla sin que nadie la toque.
- El `id` es **compuesto** (`elevator-annual-v2`); el identificador lógico vive en `templateId`. Un `id` entero
  rompe `?templateId=&version=` en cascada (ver la prueba de fuego en `smoke.sh`).

---

## GET /inspections · GET /inspections/:id · POST · PATCH /inspections/:id

**Quién lo llama:** `InspectionApiService` (Fases 8 y 9). `getAll` y `getById` desde `InspectionStateService`;
`complete` y `setStatus` mandan `PATCH`.

**Respuesta 200 de la colección** — con las respuestas **embebidas** (esto es contrato, y es la deuda de be03):

```json
[ { "id": 500, "assetId": "ASC-CENTRAL-03", "inspectorId": "INS-15",
    "templateId": "elevator-annual", "templateVersion": 2, "status": "in_progress",
    "startedAt": "2024-03-15T09:00:00-05:00", "completedAt": null,
    "answers": [ { "itemId": "main-cable", "answer": "light_wear",
                   "evidenceUrl": "assets/evidence/500-main-cable.jpg", "note": "Revisar en 6 meses" } ] } ]
```

La inspección 501 declara `templateVersion: 1` y guarda tres respuestas. Es la inspección que obliga a resolver
contra la versión congelada, no la vigente.

**Escritura**
- `PATCH /inspections/:id` con `{ answers, status: "completed", completedAt }` → cierre (`complete`).
- `PATCH /inspections/:id` con `{ status: "approved" | "rejected" }` → `setStatus`.
- `PATCH` devuelve el **objeto completo**, no sólo lo modificado. El frontend lo consume así.
- `POST /inspections` está definido en `InspectionApiService.create` pero **sin llamador** en el frontend.

**Trampas**
- `templateVersion` es el invariante: no debe cambiar al escribir. El `PATCH` lo conserva (json-server mezcla los
  campos).
- Las respuestas van dentro de la inspección, no en su propia colección. Por eso `GET /inspections` devuelve el
  objeto entero, sin paginar: **deuda intencional que se paga en be03**.

---

## GET /findings?inspectionId= · PATCH /findings/:id

**Quién lo llama:** `FindingApiService` (Fase 9). `getByInspection(inspectionId)` manda
`GET /findings?inspectionId=503`.

**Respuesta 200** — array desnudo:

```json
[ { "id": 900, "inspectionId": 503, "itemId": "main-cable", "severity": "critical",
    "description": "Desgaste severo del cable principal, con hilos visibles", "resolvedAt": null },
  { "id": 901, "inspectionId": 503, "itemId": "cabin-lighting", "severity": "minor",
    "description": "Dos luminarias de cabina fuera de servicio", "resolvedAt": null } ]
```

**Escritura:** `PATCH /findings/:id` con `{ resolvedAt: "<instante>" }` para resolver, o `{ resolvedAt: null }`
para deshacer. Devuelve el objeto completo.

**Trampas**
- **La ruta anidada `/inspections/:id/findings` existe en el mock, pero el frontend no la llama.**
  `InspectionApiService.getFindings` la define y nadie la usa. El camino real es el filtro `?inspectionId=`.
  Ver §Discrepancias.
- `severity` guardada no es la severidad que deriva la Fase 9 cruzando con los `criteria` de la versión. Quien
  manda es la derivación (`normalizeFinding` y `inspection-rules`).

---

## GET /certificates · GET /certificates?inspectionId= · GET /certificates/:id · POST · PATCH /certificates/:id

**Quién lo llama:** `CertificateApiService` (Fase 10). `?inspectionId=` lo usa `getByInspection`.

**Respuesta 200** — array desnudo:

```json
[ { "id": "CERT-2023-000501", "inspectionId": 501, "issuedAt": "2023-08-21T10:00:00-05:00",
    "validUntil": "2024-08-21T23:59:59-05:00", "status": "expired", "revokedAt": null },
  { "id": "CERT-2024-000502", "inspectionId": 502, "issuedAt": "2024-02-10T10:00:00-05:00",
    "validUntil": "2025-02-10T23:59:59-05:00", "status": "valid", "revokedAt": null } ]
```

**Escritura**
- `POST /certificates` → emisión (`issue`).
- `PATCH /certificates/:id` con `{ revokedAt }` → revocación (`revoke`). Devuelve el objeto completo.

**Trampas**
- **`status` está guardado, no derivado.** Es un error de diseño y es contrato: `CERT-2024-000502` dice `valid` y su
  `validUntil` ya pasó. La Fase 10 lo deriva en pantalla (`expired` gana sobre el guardado) y lo marca como
  divergencia.
- Los instantes llevan **offset explícito** (`-05:00`), nunca `Z` ni fecha desnuda.

---

## 5. Dialecto de json-server: lo que usa el frontend

Esta es la tabla que be03 tiene que reimplementar. Se midió contra el código, no contra la lección.

| Forma | ¿La usa el frontend? | Dónde | Qué hay que hacer en be03 |
|---|---|---|---|
| `GET /recurso` | ✅ | los seis `*ApiService` | Reimplementar |
| `GET /recurso/:id` | ✅ | clientes, activos, inspecciones, certificados | Reimplementar |
| `?campo=valor` (igualdad) | ✅ | `clientId`, `templateId`+`version` (AND), `taxId`, `inspectionId` (findings y certificates) | Reimplementar. Varios parámetros se combinan con AND |
| `?q=` (texto completo sobre todos los campos) | ✅ | buscador de clientes | **Reimplementar.** La lección dice que no se usa; se usa |
| `GET /inspections/:id/findings` (ruta anidada) | ❌ **definida, sin llamador** | `InspectionApiService.getFindings` | No hace falta para el frontend. Lo exige `smoke.sh` (ver §Discrepancias) |
| `_page` / `_limit` + `X-Total-Count` | ❌ | — | No implementar todavía. Es la 💸 1 de be03 |
| `_sort` / `_order` | ❌ | — | No implementar. No usarlo no significa que el orden dé igual (trampa de `/templates`) |
| `_embed` / `_expand` | ❌ | — | No implementar |
| `POST` | ✅ | clientes, activos, plantillas, certificados (`issue`) | Reimplementar |
| `PUT /recurso/:id` | ✅ | clientes (`update`), activos (`update`), plantillas (`close`) | **Reimplementar.** La lección dice que no se usa; se usa |
| `PATCH /recurso/:id` | ✅ | inspecciones (`complete`, `setStatus`), hallazgos (`resolve`), certificados (`revoke`) | Reimplementar |
| `DELETE /clients/:id` | ✅ | clientes (`delete`) | Reimplementar, **con la cascada que json-server hace y el frontend no espera** (ver §Trampas) |

---

## 6. El inyector de caos, inventariado

Verificado contra `mock/chaos.js` y `mock/auth.js`. Los defaults son `CHAOS_DELAY_MS=2500` y `CHAOS_RATE=0.3`.

| Modo | Activación | Qué hace | Dónde vive |
|---|---|---|---|
| `latency` | `CHAOS=latency`, `CHAOS_DELAY_MS` | Retrasa **toda** respuesta no-auth, incondicionalmente | `chaos.js` (middleware) |
| `error` | `CHAOS=error`, `CHAOS_RATE` | `500 {"message":"Fallo interno del servidor"}` con esa probabilidad | `chaos.js` |
| `malformed` | `CHAOS=malformed`, `CHAOS_RATE` | `200` con el cuerpo corrompido: array envuelto en `{items,total}` o `version` numérica pasada a texto. Parchea `res.json` **y** `res.jsonp` | `chaos.js` |
| `cors` | `CHAOS=cors` | Omite `Access-Control-Allow-Origin` (no en `/auth/`) | `server.js` (antes del caos) |
| `timeout` | `CHAOS=timeout`, `CHAOS_RATE` | No responde nunca, con esa probabilidad | `chaos.js` |
| `expired` | `CHAOS=expired` | Firma el token con `ttl = -60` | **`auth.js`**, no el middleware |

Las reglas, medidas:
- El caos no toca `/auth/login`, salvo `expired`.
- Un modo desconocido **impide arrancar**: `CHAOS=latencia` → `Error: Fallos de caos desconocidos: latencia. Los válidos son: latency, error, malformed, cors, expired, timeout.` y salida con código 1.

---

## 7. Fechas

| Qué | Formato | Ejemplo |
|---|---|---|
| Instantes de certificado | ISO con offset explícito | `2024-02-10T10:00:00-05:00` |
| Vigencia de plantilla | Día desnudo | `2024-01-01` |
| `validUntil` nulo | `null` = indefinida | `"validUntil": null` |

---

## Discrepancias con la lección be00 (a decidir por el autor)

Ninguna se corrigió en la lección. Son hechos medidos que contradicen el texto publicado.

1. **Total de comprobaciones.** La lección dice `OK: 24/24`, y en varios sitios «veintitrés restantes» y «FALLOS: 2 de 24».
   El `smoke.sh` de la lección, sin tocar una línea, da **`OK: 26/26`**.
2. **La prueba de fuego da 1 fallo, no 2.** Cambiar `"elevator-annual-v2"` por `"7"` en `db.json` rompe sólo la
   comprobación del id compuesto (`FALLOS: 1 de 26`). El filtro `?templateId=…&version=1` sigue encontrando la v1
   porque busca por `templateId` y `version`, no por `id`. La cascada que describe la lección no ocurre con esta
   rotura.
3. **La lección dice que `?q=` no se usa.** Lo usa el buscador de clientes (`ClientApiService.search`).
4. **La lección dice que `PUT` no se usa.** Lo usan clientes, activos y el cierre de plantillas.
5. **La lección dice que `FindingApiService.getByInspection()` usa la ruta anidada.** Usa `?inspectionId=`. La ruta
   anidada la define `InspectionApiService.getFindings`, que nadie llama. Por eso el `smoke.sh` comprueba una ruta
   que el frontend no pide: be03 se vería obligada a implementarla sin que ninguna pantalla la use.
6. **La lección no menciona `DELETE`, ni la cascada de `DELETE /clients/:id`.** Es la trampa más cara del mock.
7. **`GET /certificates?inspectionId=` y `GET /clients?taxId=` no están en la tabla de la lección.** Existen y se usan.

## Límites conocidos

- `smoke.sh` no comprueba CORS: `curl` no aplica la política de mismo origen. El modo `cors` del caos es invisible
  para él. Límite declarado en la lección (§Pendientes).
- `smoke.sh` comprueba la **forma** de las respuestas, no el contenido (`jq -r 'type'`), salvo las rarezas
  explícitas.
- No hay `POST /templates` atómico: publicar una versión son dos escrituras, y el mock no puede hacerlas juntas.
  Va a be05.

---

## Actualización del 15/10/2026: discrepancias corregidas en la lección

Las siete discrepancias de arriba están corregidas en `be00-el-contrato-auditoria-del-mock.md`: el total es 26, la prueba de
fuego da 1 de 26, la tabla del dialecto incluye `?q=`, `PUT`, `DELETE` (con la advertencia de la cascada), `?taxId=` e
`?inspectionId=`, y la ruta anidada aparece como declarada y sin llamador. **`smoke.sh` comprueba ahora
`GET /findings?inspectionId=503`** (lo que el frontend usa) en vez de la ruta anidada; da 26/26 contra el mock y contra el
backend PHP. El orden de `/templates` desde be03 es `templateId, version` (incidente be-04).
