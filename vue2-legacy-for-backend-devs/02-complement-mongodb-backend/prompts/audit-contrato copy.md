# 📜 AUDIT-CONTRATO.md — El contrato que el backend debe honrar

> **Documento de decisiones del curso "Formación no-SQL + MongoDB legacy para
> backend devs".** El jefe de este proyecto no es Mongo ni Express: es el
> **frontend heredado** (entregado con el curso, no se toca). Este documento
> fija qué significa exactamente "cambiar el `baseURL` y que no se entere",
> dónde esa promesa es estricta y dónde pasa a ser "el contrato crece, no se
> rompe".

---

## 🎯 La regla de oro y sus dos regímenes

| Régimen | Fases | Regla |
|---|---|---|
| **Promesa estricta** | 1 → 10 | El frontend cambia **una sola línea** (`baseURL`). Ningún otro archivo se toca. El backend imita a json-server hasta en sus manías. |
| **El contrato crece** | 11 → 15 | Se permiten **extensiones** (endpoints nuevos, códigos de estado nuevos, eventos nuevos). Se prohíben **rupturas** (cambiar la forma de una respuesta existente, renombrar un campo, exigir un header que antes no existía… con una excepción declarada abajo: el login). |

---

## 📡 Dialecto json-server a reimplementar (régimen estricto)

Lo que el frontend heredado consume hoy, con las manías exactas de
json-server 0.16:

| Método | Ruta | Manías a imitar |
|---|---|---|
| GET | `/tickets` | Soporta `?status=`, `?_sort=<campo>`, `?_order=asc\|desc`, `?q=`. Devuelve **array plano**, sin envelope. |
| GET | `/tickets/:id` | 404 **real** si no existe (el frontend lo espera). |
| POST | `/tickets` | Devuelve el ticket creado **con su `id` asignado**, status 201. |
| PATCH | `/tickets/:id` | Merge parcial. Devuelve el **ticket completo actualizado**. |
| DELETE | `/tickets/:id` | Devuelve `{}` con 200 (manía de json-server; se imita). |
| GET | `/users` | Soporta `?role=agent`. Array plano. |
| GET | `/comments` | Soporta `?ticketId=X` y `?_sort=createdAt`. |
| POST | `/comments` | Devuelve el comentario con `id`, status 201. |

**Reglas de forma (todas las respuestas):**

- JSON plano, **sin envelope** (`{ data: [...] }` está prohibido: la capa de
  servicios del frontend devuelve `res.data` y espera el recurso directo).
- Fechas como **string ISO 8601** (`"2020-03-10T10:00:00Z"`), nunca objetos
  `Date` serializados de otra forma ni timestamps numéricos.
- Los cuerpos de error pueden ser mejores que los de json-server (que devuelve
  `{}`): el frontend **no depende** del cuerpo de un error, solo del status.
  Aquí tenemos libertad.

### La manía `?q=` (alcance acotado)

json-server busca `q` en **todos los valores** del recurso. Decisión: nuestro
backend busca solo en `title` y `description` (los únicos campos de texto
visibles donde el usuario buscaría). Es una **desviación declarada y
aceptable**: el comportamiento observable desde la UI es idéntico. Bonus
didáctico: en la Fase 7 esta búsqueda motiva el índice de texto vs `$regex`.

---

## 🆔 La decisión más importante: `id` vs `_id`

**El problema.** json-server sirve `id` numérico (`1, 2, 3…`). Mongo trae
`_id: ObjectId("5f8a...")`. El frontend usa `id` en rutas (`/tickets/:id`),
payloads y comparaciones.

**Opciones consideradas:**

1. ❌ **Ids numéricos autoincrementales en Mongo** (colección de contadores).
   Reproduce el instinto SQL de la secuencia, agrega un punto de contención en
   cada insert, y es exactamente el anti-patrón que el curso combate. Solo se
   menciona para descartarlo con argumentos (ejercicio de la Fase 1).
2. ✅ **ObjectId interno, mapeo en la frontera.** La base usa `_id: ObjectId`
   como Mongo manda. La capa API (controller) **serializa `_id` → `id`
   (string hex)** en cada respuesta y **traduce `:id` → ObjectId** en cada
   entrada. La base habla Mongo; la API habla el contrato.

**Riesgo declarado 🎯:** el `id` pasa de *número* a *string hex*. Los params de
ruta ya son strings, así que la navegación sobrevive. Pero si en algún punto
el frontend hace una comparación con casteo numérico (`Number(id)`) o un `===`
entre número y string, **ahí se rompe**. Mitigación:

- **Smoke test manual obligatorio** al final de la Fase 10 (checklist abajo).
- Si algo se rompe por esto, se clasifica como **bug latente del frontend
  heredado** (dependía de un detalle de implementación del mock, no del
  contrato) y su arreglo puntual **no cuenta como romper la promesa** — pero
  se documenta.

---

## 🔌 Sockets (régimen estricto → crece en Fase 12)

- Mismo servidor lógico en `:4000` (el puerto que hoy escucha el cliente),
  **socket.io 2.4** — la versión importa: 2.x y 3.x no se hablan.
- Mismo nombre de evento: `ticket:created` (y `ticket:updated` /
  `ticket:deleted` cuando se activen).
- **Misma forma del payload** que hoy emite el propio cliente (el "cliente
  mentiroso" heredado: quien crea el ticket emite el evento).
- El cambio de la Fase 12 es **quién emite** (el servidor tras persistir), no
  **qué** se emite. El frontend escucha lo mismo y no distingue. Muere el relé
  tonto sin funeral visible.

---

## 📈 Extensiones pactadas (régimen "el contrato crece")

| Extensión | Fase | Tipo |
|---|---|---|
| `POST /auth/login` → `{ token, user }` con JWT real | 11 | ⚠️ **La excepción declarada:** el login mock del frontend heredado es client-side; conectarlo exige tocar una función de su `authService.js`. Es la única ruptura admitida, se anuncia con nombre y apellido, y el frontend ya dejó el terreno preparado (el login ya devuelve una Promise). |
| `401` en cualquier endpoint con token inválido/ausente | 11 | Extensión. Si el frontend tiene interceptor de respuesta lo aprovecha; sin él, el usuario ve errores genéricos — feo pero no roto. |
| `403` por rol insuficiente | 11 | Extensión. |
| `409` en el doble "tomar" (update condicional falló) | 6/11 | Extensión. El PATCH del frontend recibe un error donde antes recibía un éxito silencioso mentiroso. El manejo fino es ejercicio. |
| `GET /stats` (agregaciones server-side) | 9 | Endpoint nuevo, ya previsto por el contrato heredado como pendiente. |
| `POST /attachments` (multipart) + descarga | 12 | Endpoint nuevo, ya previsto como pendiente. |
| Server emite los sockets | 12 | Cambio de emisor, no de contrato. |

---

## 🌱 Semilla de datos

El `db.json` heredado es la **fixture oficial**. La Fase 1 lo importa a Mongo
con un script de seed que:

1. convierte cada `id` numérico en un `ObjectId` nuevo,
2. **retraduce las referencias** (`comments.ticketId` debe apuntar al ObjectId
   nuevo del ticket, no al número viejo — primer contacto con "la integridad
   referencial ahora es tu problema"),
3. convierte fechas string → `Date` de BSON (y la API las devuelve como ISO;
   ida y vuelta declarada).

Este script no es plomería: es el **primer ejercicio de paradigma** del curso.

---

## ✅ Smoke test de la promesa (checklist de la Fase 10)

Con json-server apagado y `baseURL` apuntando al Express:

- [ ] Login mock entra y el dashboard carga tickets
- [ ] Búsqueda (`?q=`) y filtros por status funcionan
- [ ] Orden por columna (`_sort`/`_order`) funciona
- [ ] Detalle de ticket carga; un id inexistente da la vista de 404
- [ ] Crear ticket (form y wizard) → aparece con id asignado
- [ ] Editar, tomar, cambiar estado, eliminar → la UI refleja el resultado
- [ ] Comentarios: listan ordenados y se crean
- [ ] Las métricas del dashboard siguen calculando en cliente sin errores
- [ ] Recarga de página con sesión activa: todo lo anterior sobrevive
- [ ] `git diff` del frontend: **exactamente una línea**
