# 🅰️ Prompts iniciales por fase — Track BE 🔥
## Tutorial React 16 — Rifas y chances · Backend en Go

Cada prompt está listo para copiar y pegar en un chat nuevo. Los datos ya están
completados según `prompts/propuesta-fases-backend.md` y
`prompts/decisiones-y-versiones.md` §7. Solo cópialo tal cual al abrir el chat
de esa fase.

Son los prompts **A** —los que cargan el contexto y confirman el encuadre—. La
solicitud de redacción propiamente dicha (el prompt B) se escribe después, en el
mismo chat, cuando el modelo confirmó que tiene el contexto.

> ⚠️ **Antes del primer chat del track.** Sube al Project Knowledge, además de
> los documentos del track base, `prompts/propuesta-fases-backend.md`. Sin él,
> ninguna fase BE puede justificar qué deuda cobra, y esa justificación es el
> criterio que decide qué entra en cada fase.

---

## Fase be00 — El contrato: auditoría del mock

```
Este es el chat de redacción de la Fase be00 — El contrato: auditoría del
mock, del track BE opcional del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16 para el track BE), (6)
prompts/diccionario-codigo-ingles.md (§7bis para Go y SQL), (7)
prompts/plantilla-de-fase.md, (8) las fases 0-8 del track base ya escritas y
aprobadas, (9) decisiones de este chat.

Contexto de esta fase:
- Fase: be00 de be09. Es la primera del track.
- Nombre: El contrato: auditoría del mock.
- Horas: 6h.
- Depende de: Fase 8 del track base terminada. No depende de ninguna fase BE.
- Habilita: be01 — Go 1.19 y la forma del monolito.
- Qué entra: inventario completo de lo que el frontend consume del puerto
  3001, medido con la pestaña Network y no adivinado leyendo código; el
  dialecto de json-server (_page, _limit, _sort, _order, q, X-Total-Count,
  el 404 con cuerpo vacío, el POST que devuelve el recurso con su id); las
  tres rutas propias de la Fase 3 (GET /raffles/:id/numbers, POST
  .../reserve, POST .../sell con su 409); POST /login y su forma de
  respuesta; POST /_chaos; el header X-Request-Id; la separación entre
  régimen estricto (lo que no puede cambiar) y régimen de crecimiento (lo
  que el backend puede añadir sin romper nada); y el checklist de smoke test
  que se ejecutará al final de be03 y de cada fase posterior.
- Qué NO entra: una sola línea de Go. Esta fase no escribe código de
  backend; audita y documenta.
- Pieza forense de esta fase: capturar con Network todas las peticiones de
  un recorrido completo por la aplicación y convertir esa captura en el
  contrato.
- Deuda del track base que cobra: ninguna todavía. Prepara el terreno para
  cobrarlas todas.

Decisiones confirmadas que aplican (prompts/decisiones-y-versiones.md — no se
reabren en este chat):
- D21 El backend Go tomará el puerto 3001 y honrará el contrato del mock.
- D22 El caos se reimplementa en Go con doble control (ruta POST /_chaos y
  variable CHAOS_LEVEL), apagado por defecto.

La regla que gobierna todo el track y que esta fase debe dejar por escrito:
el frontend heredado NO SE TOCA. El backend se adapta al contrato existente,
nunca al revés.

No hace falta preguntarme por versiones ni decisiones de stack: están todas
en prompts/decisiones-y-versiones.md §7. Si algo específico de esta fase no
está definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Fase be01 — Go 1.19 y la forma del monolito

```
Este es el chat de redacción de la Fase be01 — Go 1.19 y la forma del
monolito, del track BE opcional del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7)
prompts/plantilla-de-fase.md, (8) be00 ya cerrada y aprobada, (9) decisiones
de este chat.

Contexto de esta fase:
- Fase: be01 de be09.
- Nombre: Go 1.19 y la forma del monolito.
- Horas: 8h.
- Depende de: be00 — el contrato ya está auditado y escrito.
- Habilita: be02 — La costura de datos.
- Qué entra: go.mod y el layout en server/; net/http con gorilla/mux; la
  cadena de middlewares (recuperación de pánico, CORS hacia el 3000,
  logging, X-Request-Id); context.Context como vehículo transversal; manejo
  de errores con error explícito; apagado ordenado con
  http.Server.Shutdown; GET /health como primer endpoint vivo; y la
  reimplementación del middleware de caos con doble control.
- Qué NO entra (se difiere a be02): cualquier acceso a base de datos. Esta
  fase sirve datos en memoria o fijos.
- Pieza forense de esta fase: un pánico dentro de un handler. Sin recover
  tumba el proceso entero y el navegador solo ve una conexión cortada — la
  primera lección cultural de Go para quien viene de Node.
- Deuda del track base que cobra: ninguna directamente; monta el andamiaje
  que permitirá cobrarlas.
- Remite a: bea-01 (Go para quien no escribe Go) para toda la sintaxis.

Decisiones confirmadas que aplican (no se reabren en este chat):
- D14 Go 1.19.13, sin slog, sin errors.Join, sin genéricos, sin los patrones
  de método de http.ServeMux. Lo moderno va marcado 🔥 como comparación.
- D15 gorilla/mux 1.8.0 sobre net/http. Nada de Gin, Echo o Fiber.
- D22 Caos con ruta POST /_chaos y variable CHAOS_LEVEL; gana la última
  orden recibida y el arranque cuenta como orden.

Audiencia: dev backend senior que puede no haber escrito Go nunca. No le
expliques qué es HTTP, un middleware o la inyección de dependencias. Sí
explícale lo que Go hace distinto: errores como valores, interfaces
implícitas, y por qué no hay excepciones.

No hace falta preguntarme por versiones ni decisiones de stack. Si algo
específico de esta fase no está definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Fase be02 — La costura de datos y el mito de la agnosia

```
Este es el chat de redacción de la Fase be02 — La costura de datos y el mito
de la agnosia, del track BE opcional del tutorial React 16 + Rifas y
chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7)
prompts/plantilla-de-fase.md, (8) be00 y be01 cerradas y aprobadas, (9)
decisiones de este chat.

Contexto de esta fase:
- Fase: be02 de be09.
- Nombre: La costura de datos y el mito de la agnosia.
- Horas: 10h.
- Depende de: be01 — el servidor HTTP ya corre.
- Habilita: be03 — CRUD y el reemplazo.
- Qué entra: database/sql y el pool de conexiones; sqlx y Rebind para los
  placeholders (? contra $1); migraciones versionadas con golang-migrate; el
  esquema completo de raffles, raffle_numbers, participants, settlements y
  users; y el inventario MEDIDO de dónde se rompe la portabilidad entre
  SQLite y PostgreSQL: identidades autoincrementales, RETURNING, booleanos,
  tipos de fecha (que en SQLite no existen) y semántica de bloqueo.
- Qué NO entra (se difiere a be03): los handlers del CRUD. Acá se construye
  la capa de datos y se prueba desde tests, no desde HTTP.
- Pieza forense de esta fase: la misma consulta contra los dos motores
  devolviendo resultados distintos. No se argumenta la diferencia: se
  muestra.
- Deuda del track base que cobra: prepara el pago de db.json como almacén.
- Remite a: bea-03 (dialectos SQL) para el diccionario completo de
  divergencias.

Decisiones confirmadas que aplican (no se reabren en este chat):
- D17 database/sql + sqlx 1.3.5, SIN ORM. El SQL se escribe a mano y queda
  visible: es el objetivo pedagógico de esta fase.
- D18 PostgreSQL 13 es el motor de verdad; SQLite 3.35+ solo en pruebas.
- D19 lib/pq v1.10.7 y mattn/go-sqlite3 v1.14.16, con la cuestión cgo
  abierta hasta be09.
- D20 Migraciones con golang-migrate v4.15.2, dos SQL por versión.

El ángulo honesto de esta fase, que es su tesis: la agnosia total de base de
datos NO EXISTE. Lo que existe es portabilidad por disciplina, con una
costura donde el dialecto se hace explícito en vez de esconderse. La fase
tiene que decirlo así de claro y demostrarlo con código, no suavizarlo.

Audiencia: dev senior con años de SQL. No le expliques qué es un índice, una
transacción ni una clave foránea.

No hace falta preguntarme por versiones ni decisiones de stack. Si algo
específico de esta fase no está definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Fase be03 — CRUD de rifas y el momento del reemplazo

```
Este es el chat de redacción de la Fase be03 — CRUD de rifas y el momento
del reemplazo, del track BE opcional del tutorial React 16 + Rifas y
chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7)
prompts/plantilla-de-fase.md, (8) be00, be01 y be02 cerradas y aprobadas, y
el contrato de be00 como criterio de aceptación, (9) decisiones de este
chat.

Contexto de esta fase:
- Fase: be03 de be09. ES LA BISAGRA DEL TRACK.
- Nombre: CRUD de rifas y el momento del reemplazo.
- Horas: 10h.
- Depende de: be02 — la capa de datos ya existe.
- Habilita: be04 — Identidad real.
- Qué entra: los recursos del contrato implementados en capas (handler →
  service → store); la siembra de la base desde el db.json que el alumno ya
  tiene del track base (no desde un dump nuestro); y la prueba de fuego: se
  apaga json-server, se levanta el binario en el 3001 y se recorre la
  aplicación entera SIN TOCAR EL FRONTEND. El checklist de smoke test de
  be00 es el criterio de aprobación y no es opinable: pasa o no pasa.
- Qué NO entra (se difiere a be04): autenticación real. El login sigue
  devolviendo el token de mentira que espera el frontend.
- Pieza forense de esta fase: una discrepancia de contrato encontrada por el
  frontend y no por un test — típicamente un campo que json-server devolvía
  como número y Go serializa como string, o una lista que llegaba envuelta.
  Es la forma real en que aparecen estos bugs.
- Deuda del track base que cobra: db.json como almacén. 🪦 Retiro formal de
  json-server.
- Ejercicio opcional 🔥: generar volumen con un faker (remite a bea-10).
  Sin volumen, las mediciones de be05 y be08 no dicen nada.

Decisiones confirmadas que aplican (no se reabren en este chat):
- D21 El backend toma el puerto 3001 y reimplementa el dialecto de
  json-server tal cual lo consume el frontend. Un backend "mejor diseñado"
  que obligue a cambiar el cliente es, para este curso, un backend roto.

Esta fase tiene que estar escrita alrededor de su momento 🪦. La señal de
que quedó bien es literal: "apagué el mock, levanté mi binario, y la
aplicación no se enteró".

No hace falta preguntarme por versiones ni decisiones de stack. Si algo
específico de esta fase no está definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Fase be04 — Identidad real: bcrypt, JWT y un CVE

```
Este es el chat de redacción de la Fase be04 — Identidad real: bcrypt, JWT y
un CVE, del track BE opcional del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16 y §13 para el post-mortem),
(6) prompts/diccionario-codigo-ingles.md (§7bis), (7)
prompts/plantilla-de-fase.md, (8) be00-be03 cerradas, y las fases 2 y 3 del
track base como origen de las deudas que se cobran acá, (9) decisiones de
este chat.

Contexto de esta fase:
- Fase: be04 de be09.
- Nombre: Identidad real: bcrypt, JWT y un CVE.
- Horas: 8h.
- Depende de: be03 — el backend ya sirve a la aplicación.
- Habilita: be05 — Venta concurrente.
- Qué entra: POST /login validando contra un hash bcrypt y firmando un JWT
  cuyo string viaja en EL MISMO CAMPO token que el frontend ya lee, de modo
  que el interceptor de la Fase 2 sigue funcionando sin cambios; middleware
  de verificación; identidad tomada de req.Context() y nunca del cuerpo de
  la petición; transiciones del flujo borrador → abierta → cerrada →
  resuelta → liquidada custodiadas en el service; y la secuencia completa de
  adoptar dgrijalva/jwt-go a propósito, descubrir el abandono y el CVE de
  manejo de audiencia, y migrar a golang-jwt/jwt con post-mortem sin
  culpabilización.
- Qué NO entra: refresh tokens. El JWT expira, el frontend no renueva, y esa
  fricción se DECLARA COMO DEUDA VIVA en vez de tocar el frontend. Token de
  vida larga para el laboratorio.
- Pieza forense de esta fase: un token manipulado en jwt.io reenviado a la
  API — ver fallar la firma, y después ver qué pasaría si el servidor
  aceptara el algoritmo none.
- Deudas del track base que cobra, y son cuatro: el token de mentira de la
  Fase 2, las contraseñas comparadas en claro, el cliente mentiroso (quien
  crea una rifa es quien el navegador dice que es) y las transiciones de
  estado libres.
- Remite a: bea-04 (JWT por dentro y su CVE) y bea-08 (seguridad de API).

Decisiones confirmadas que aplican (no se reabren en este chat):
- D16 Se adopta dgrijalva/jwt-go v3.2.0 a propósito y se migra a
  golang-jwt/jwt v4.4.2 en la misma fase. La secuencia abandono → CVE → fork
  ES el contenido; no la resumas ni la saltes.
- D21 El contrato manda: el campo token de la respuesta de login no cambia
  de nombre ni de forma.

⚠️ Cita el identificador del CVE y las fechas desde el aviso oficial, nunca
de memoria, y adviértelo en el texto como pide la guía de estilo §10.3.

No hace falta preguntarme por versiones ni decisiones de stack. Si algo
específico de esta fase no está definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Fase be05 — ⭐ Venta concurrente resuelta donde se resuelve

```
Este es el chat de redacción de la Fase be05 — Venta concurrente resuelta
donde se resuelve, del track BE opcional del tutorial React 16 + Rifas y
chances. Es una de las dos fases ⭐ del track.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7)
prompts/plantilla-de-fase.md, (8) be00-be04 cerradas, y LA FASE 5 DEL TRACK
BASE como contraparte obligatoria de lectura, (9) decisiones de este chat.

Contexto de esta fase:
- Fase: be05 de be09. ⭐ Pieza central.
- Nombre: Venta concurrente resuelta donde se resuelve.
- Horas: 10h.
- Depende de: be04 — ya hay identidad real detrás de cada venta.
- Habilita: be06 — Hora dura y zonas horarias.
- Qué entra: índice único como última línea de defensa; transacciones y
  niveles de aislamiento; SELECT ... FOR UPDATE frente a INSERT ... ON
  CONFLICT; reservas con expiración y el trabajo que las vence; el 409
  producido por la base y no por un if; y una comparación MEDIDA entre
  bloqueo pesimista y optimista sobre el mismo caso.
- Qué NO entra: reintentos automáticos en el cliente. El frontend no se
  toca.
- Pieza forense de esta fase: dos clientes concurrentes peleando por el
  número 0347 desde la línea de comandos, y la transacción bloqueada
  observada desde pg_stat_activity. El alumno VE el bloqueo, no lo imagina.
  Y el remate: el mismo escenario contra SQLite, donde no hay FOR UPDATE y
  aparece un SQLITE_BUSY — es la evidencia que justifica la regla del motor
  de be08.
- Deuda del track base que cobra: el 409 de venta duplicada producido por un
  if en JavaScript sobre un archivo JSON (Fase 3), y la race condition que
  la Fase 5 solo podía estudiar desde el store.
- Remite a: bea-05 (concurrencia en Postgres).

El ángulo que hace valiosa esta fase: el alumno ya vio el MISMO SÍNTOMA
resuelto en la capa equivocada. Acá tiene que entender por qué ninguna race
condition de venta se resuelve en el cliente, y quedarse con el criterio
—no solo con la solución.

No hace falta preguntarme por versiones ni decisiones de stack. Si algo
específico de esta fase no está definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Fase be06 — Hora dura, zonas horarias y la autoridad del reloj

```
Este es el chat de redacción de la Fase be06 — Hora dura, zonas horarias y
la autoridad del reloj, del track BE opcional del tutorial React 16 + Rifas
y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7)
prompts/plantilla-de-fase.md, (8) be00-be05 cerradas, y la Fase 7 del track
base como contraparte, (9) decisiones de este chat.

Contexto de esta fase:
- Fase: be06 de be09.
- Nombre: Hora dura, zonas horarias y la autoridad del reloj.
- Horas: 8h.
- Depende de: be05 — la venta ya está protegida.
- Habilita: be07 — Liquidación transaccional.
- Qué entra: TIMESTAMPTZ frente a TIMESTAMP y por qué la diferencia es una
  factura; la hora de cierre evaluada en el servidor; el rechazo de venta
  tras el cierre como regla de negocio y no como validación de formulario;
  serialización en RFC 3339; y el desfase entre el reloj del cliente y el
  del servidor, expuesto a propósito.
- Qué NO entra: el polling de resultados, que sigue consumiendo el mock de
  lotería del puerto 3002 — ese servidor NO se reescribe en Go, es un
  proveedor externo y esa frontera se conserva.
- Pieza forense de esta fase: adelantar el reloj del navegador y comprobar
  que el frontend deja vender y el backend no. Es la demostración de una
  sola pantalla de por qué la autoridad temporal vive del lado del servidor.
- Deuda del track base que cobra: la hora de cierre evaluada con el reloj
  del cliente (Fase 7).
- Remite a: bea-06 (tiempo, zonas y relojes).

Audiencia: dev senior que ya sufrió zonas horarias. No le expliques qué es
UTC; explícale qué hace Postgres realmente con TIMESTAMPTZ, que es donde
casi todo el mundo tiene un modelo mental equivocado.

No hace falta preguntarme por versiones ni decisiones de stack. Si algo
específico de esta fase no está definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Fase be07 — Liquidación: dinero entero y transaccional

```
Este es el chat de redacción de la Fase be07 — Liquidación: dinero entero y
transaccional, del track BE opcional del tutorial React 16 + Rifas y
chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7)
prompts/plantilla-de-fase.md, (8) be00-be06 cerradas, y la Fase 8 más el
apéndice A10 del track base como contraparte obligatoria, (9) decisiones de
este chat.

Contexto de esta fase:
- Fase: be07 de be09.
- Nombre: Liquidación: dinero entero y transaccional.
- Horas: 6h.
- Depende de: be06 — el cierre ya lo decide el servidor.
- Habilita: be08 — Pruebas y la regla del motor.
- Qué entra: BIGINT en centavos, coherente con A10; el cálculo del premio
  dentro de una transacción; el reparto que cuadra al centavo y la política
  explícita para el residuo; idempotencia de la liquidación; y la
  trazabilidad como registro inmutable en vez de campo actualizable.
- Qué NO entra: el dashboard y sus métricas. La Fase 9 del track base queda
  fuera del contrato obligatorio; un GET /stats es pendiente 🔥 de be09.
- Pieza forense de esta fase: una liquidación interrumpida a la mitad. Con
  transacción no pasa nada; sin ella la base queda con dinero repartido y la
  rifa sin liquidar.
- Deuda del track base que cobra: que la aritmética en centavos viviera solo
  en el frontend, sin que la base garantizara nada.

La coherencia con A10 es obligatoria: mismas reglas de redondeo, mismo
tratamiento del residuo, mismos nombres. Si algo de A10 no se puede sostener
del lado del servidor, dilo explícitamente en vez de cambiarlo en silencio.

No hace falta preguntarme por versiones ni decisiones de stack. Si algo
específico de esta fase no está definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Fase be08 — Pruebas por niveles y la regla del motor

```
Este es el chat de redacción de la Fase be08 — Pruebas por niveles y la
regla del motor, del track BE opcional del tutorial React 16 + Rifas y
chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7)
prompts/plantilla-de-fase.md, (8) be00-be07 cerradas, y la Fase 10 del track
base como contraparte, (9) decisiones de este chat.

Contexto de esta fase:
- Fase: be08 de be09.
- Nombre: Pruebas por niveles y la regla del motor.
- Horas: 10h.
- Depende de: be07 — el dominio está completo del lado del servidor.
- Habilita: be09 — Empaquetado y pipeline.
- Qué entra: httptest para handlers; la suite de contrato que verifica el
  checklist de be00 endpoint por endpoint; pruebas de integración contra
  Postgres en contenedor; pruebas de concurrencia con goroutines; go test
  -race; y el contenido central, que es una regla y su demostración:

  "SQLite vale para pruebas que no tocan concurrencia, bloqueos, zonas
  horarias ni SQL específico del motor. En cuanto una prueba toca cualquiera
  de las cuatro, corre contra PostgreSQL o no vale."

  No se enuncia como opinión: se demuestra con una prueba que PASA EN SQLITE
  Y FALLA EN POSTGRES, y con otra que hace lo contrario.
- Qué NO entra: e2e del frontend, que ya vive en la Fase 10 del track base.
- Pieza forense de esta fase: exactamente ese par de pruebas contradictorias.
- Deuda del track base que cobra: la suite del track base no podía probar
  nada del servidor; acá la mitad invisible del sistema queda cubierta.

Decisiones confirmadas que aplican (no se reabren en este chat):
- D18 PostgreSQL es el motor de verdad; SQLite solo en pruebas, y solo bajo
  la regla de arriba.

El argumento que la fase debe dejar clavado: una suite verde contra el motor
equivocado es PEOR que no tener suite, porque da permiso para desplegar.

No hace falta preguntarme por versiones ni decisiones de stack. Si algo
específico de esta fase no está definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Fase be09 — Empaquetado, ambientes y pipeline

```
Este es el chat de redacción de la Fase be09 — Empaquetado, ambientes y
pipeline, del track BE opcional del tutorial React 16 + Rifas y chances. Es
la fase de cierre del track.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7)
prompts/plantilla-de-fase.md, (8) be00-be08 cerradas, y los apéndices A3, A9
y A13 del track base como contraparte, (9) decisiones de este chat.

Contexto de esta fase:
- Fase: be09 de be09. Cierra el track.
- Nombre: Empaquetado, ambientes y pipeline.
- Horas: 8h.
- Depende de: be08 — hay una suite que puede correr en CI.
- Habilita: nada. Es el cierre.
- Qué entra: build multi-stage; la decisión cgo contra puro Go CON SU
  MEDICIÓN de tamaño de imagen y tiempo de compilación; configuración por
  variables de entorno para los cuatro ambientes; migraciones ejecutadas al
  arrancar frente a ejecutadas como paso previo del despliegue; y un
  workflow de GitHub Actions que compila, prueba contra los dos motores y
  publica la imagen.
- Qué NO entra: orquestación, Kubernetes, despliegue real a un proveedor.
- Pieza forense de esta fase: la imagen que compila en la máquina del alumno
  y no en el runner, o al revés. El clásico de cgo, musl y arquitectura.
- Cierre del track: el VEREDICTO HONESTO. Qué quedó mejor que el mock, qué
  quedó peor, qué deudas siguen vivas (el refresh token entre ellas), y
  cuándo NO vale la pena reemplazar un mock por un backend propio.
- Pendiente 🔥 a registrar: un GET /stats para el dashboard de la Fase 9,
  para quien haya terminado el curso completo. Ninguna fase depende de él.
- Remite a: bea-02 (receta de imagen y compose) y bea-09 (mapa de deuda
  del track BE).

Decisiones confirmadas que aplican (no se reabren en este chat):
- D19 La elección entre mattn/go-sqlite3 (cgo) y modernc.org/sqlite (puro
  Go) se MIDE acá, no se decide por gusto.
- D23 La aplicación es de 2022 y el pipeline es de hoy: acciones actuales
  ejecutando Go 1.19 dentro de container: golang:1.19 con services:
  postgres:13. Esa separación de edades es contenido y hay que explicarla,
  no esconderla.

AUTOCONTENCIÓN, y acá es crítico: esta fase NO remite a ningún otro curso
del catálogo, exista o no uno de contenedores. Todo lo necesario vive acá y
en bea-02, escrito como receta cerrada y verificable de principio a fin.

No hace falta preguntarme por versiones ni decisiones de stack. Si algo
específico de esta fase no está definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```
