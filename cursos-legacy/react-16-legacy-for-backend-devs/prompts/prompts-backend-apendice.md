# 🅰️ Prompts iniciales por apéndice — Track BE 🔥
## Tutorial React 16 — Rifas y chances · Backend en Go

Cada prompt está listo para copiar y pegar en un chat nuevo. Los datos ya están
completados según `prompts/propuesta-fases-backend.md` y
`prompts/decisiones-y-versiones.md` §7.

Los apéndices se crean **bajo demanda, cuando una fase los referencia** — no
hace falta seguir este orden. Son material de **consulta rápida**, no de lectura
corrida: índice de salto, secciones cortas, una guía final de "cuándo usar qué"
y entre 5 y 10 ejercicios cortos contra el laboratorio propio del alumno.

> 🧭 **El recordatorio que aplica a los diez.** Un apéndice de este track no
> enseña un producto: resuelve una duda que nace en una fase. Si al escribirlo
> aparece material que no responde a ninguna pregunta de ninguna fase, sobra —
> por interesante que sea.

---

## Apéndice bea-01 — Go para quien no escribe Go

```
Este es el chat de redacción del Apéndice bea-01 — Go para quien no escribe
Go, del track BE opcional del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16 para el track BE), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7) entregables aprobados de
fases BE relevantes, (8) decisiones de este chat.

Contexto de este apéndice:
- Apéndice: bea-01 — Go para quien no escribe Go.
- Horas estimadas: 4h.
- Fases que lo referencian: be01 y en adelante.
- Es material de CONSULTA RÁPIDA: solo cubre lo que aparece en el código
  real del track, nada de un tour completo del lenguaje.
- Contenido esperado: paquetes y módulos; error como valor de retorno en vez
  de excepciones, y el envoltorio con %w; interfaces implícitas y por qué
  cambian el diseño; punteros y receptores; structs y etiquetas JSON;
  context.Context; goroutines, canales y el modelo de concurrencia, solo
  hasta donde be05 y be08 lo necesitan; y el go tooling mínimo (build, test,
  vet, mod tidy).

Decisiones confirmadas que aplican (no se reabren en este chat):
- D14 Go 1.19.13. Sin slog, sin errors.Join, sin genéricos en el código
  principal; lo moderno se marca 🔥 como comparación.

Audiencia, y es lo que define el apéndice: dev backend SENIOR que domina
otro lenguaje y puede no haber escrito Go nunca. No expliques qué es una
función, un tipo o la concurrencia. Explica lo que Go hace DISTINTO de lo
que el lector ya sabe, y por qué.

No hace falta preguntarme por versiones. Si algo específico no está
definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Apéndice bea-02 — Receta de imagen y compose

```
Este es el chat de redacción del Apéndice bea-02 — Receta de imagen y
compose, del track BE opcional del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7) el apéndice A9 del track
base (entornos y contenedores) para no contradecirlo, (8) decisiones de este
chat.

Contexto de este apéndice:
- Apéndice: bea-02 — Receta de imagen y compose.
- Horas estimadas: 3h.
- Fases que lo referencian: be02 (Postgres en contenedor), be03, be09.
- Es LA RECETA RÁPIDA del track: el alumno viene a copiar algo que funcione,
  no a estudiar contenedores.
- Contenido esperado: Dockerfile multi-stage copiable (golang:1.19-bullseye
  como builder, debian:bullseye-slim como runtime, y por qué NO Alpine
  mientras haya cgo); docker-compose.yml con Postgres 13 y el backend, con
  las variables de entorno de los cuatro ambientes; el puerto 5432 y qué
  hacer si ya está ocupado (publicar en 5433); comandos de arranque, parada
  y reseteo de la base; y los tres o cuatro errores que salen SIEMPRE, con
  su mensaje literal y su causa.

Decisiones confirmadas que aplican (no se reabren en este chat):
- D19 mattn/go-sqlite3 exige CGO_ENABLED=1, y eso condiciona la imagen base.
- D23 Pipeline actual ejecutando Go 1.19 en contenedor.

AUTOCONTENCIÓN, y en este apéndice es la restricción crítica: NO remite a
ningún otro curso del catálogo, exista o no uno de contenedores. Todo lo que
el alumno necesita para construir la imagen y levantar el laboratorio vive
acá, escrito como receta cerrada y verificable de principio a fin. Tampoco
enseña Docker en general: enseña ESTA imagen y ESTE compose.

No hace falta preguntarme por versiones. Si algo específico no está
definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Apéndice bea-03 — SQL portable y dialectos

```
Este es el chat de redacción del Apéndice bea-03 — SQL portable y
dialectos, del track BE opcional del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7) be02 ya escrita, de la que
este apéndice es la referencia extendida, (8) decisiones de este chat.

Contexto de este apéndice:
- Apéndice: bea-03 — SQL portable y dialectos.
- Horas estimadas: 3h.
- Fases que lo referencian: be02 principalmente; be05, be06 y be08 lo
  consultan.
- Es material de CONSULTA RÁPIDA: un diccionario de divergencias que se abre
  cuando algo no funciona igual en los dos motores.
- Contenido esperado, divergencia por divergencia y con el "qué hacer" al
  lado: placeholders (? contra $1) y sqlx.Rebind; identidades
  autoincrementales; RETURNING y su cota de SQLite 3.35; tipos de fecha, que
  en SQLite no existen; booleanos; tipos numéricos y dinero; semántica de
  bloqueo y la ausencia de FOR UPDATE; concurrencia de escritura y
  SQLITE_BUSY; y las diferencias de DDL que obligan a decidir entre un
  subconjunto común y migraciones por dialecto.
- Cierre obligatorio: la guía de "cuándo usar qué", que acá es la regla del
  motor de be08.

Decisiones confirmadas que aplican (no se reabren en este chat):
- D17 database/sql + sqlx, sin ORM.
- D18 PostgreSQL 13 es el motor de verdad; SQLite 3.35+ solo en pruebas.

Audiencia: dev senior con años de SQL. No le expliques qué es una
transacción, un índice o una clave foránea. La tesis del apéndice es que la
agnosia total no existe, y el material tiene que sostenerla con ejemplos
ejecutables, no con adjetivos.

No hace falta preguntarme por versiones. Si algo específico no está
definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Apéndice bea-04 — JWT por dentro y su CVE

```
Este es el chat de redacción del Apéndice bea-04 — JWT por dentro y su CVE,
del track BE opcional del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16 y §13), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7) be04 ya escrita, (8)
decisiones de este chat.

Contexto de este apéndice:
- Apéndice: bea-04 — JWT por dentro y su CVE.
- Horas estimadas: 3h.
- Fases que lo referencian: be04; bea-08 lo cruza.
- Es material de CONSULTA RÁPIDA.
- Contenido esperado: anatomía de un JWT (header, payload, firma) y qué
  significa realmente "firmado"; claims estándar y cuáles importan acá (exp,
  aud, sub); algoritmos y el ataque alg: none; por qué un JWT no se puede
  revocar y qué se hace al respecto; el CVE de manejo de audiencia de
  dgrijalva/jwt-go; cómo se lee un aviso de seguridad y cómo se decide si te
  afecta; y la migración a golang-jwt/jwt paso a paso.
- Cierre obligatorio: guía de "cuándo usar qué" — JWT contra sesión de
  servidor, y por qué esta aplicación usa lo que usa.

Decisiones confirmadas que aplican (no se reabren en este chat):
- D16 dgrijalva/jwt-go v3.2.0 se adopta a propósito y se migra a
  golang-jwt/jwt v4.4.2.

⚠️ Cita el identificador del CVE, su alcance y sus fechas DESDE EL AVISO
OFICIAL, nunca de memoria, y deja escrita la advertencia de verificación que
pide la guía de estilo §10.3. Un apéndice de seguridad con un dato de
segunda mano es peor que no tenerlo.

No hace falta preguntarme por versiones. Si algo específico no está
definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Apéndice bea-05 — Concurrencia en PostgreSQL

```
Este es el chat de redacción del Apéndice bea-05 — Concurrencia en
PostgreSQL, del track BE opcional del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7) be05 ya escrita, de la que
este apéndice es la referencia extendida, (8) decisiones de este chat.

Contexto de este apéndice:
- Apéndice: bea-05 — Concurrencia en PostgreSQL.
- Horas estimadas: 3h.
- Fases que lo referencian: be05 principalmente; be07 y be08 lo consultan.
- Es material de CONSULTA RÁPIDA.
- Contenido esperado: niveles de aislamiento y qué anomalía previene cada
  uno; FOR UPDATE y sus variantes (SKIP LOCKED, NOWAIT) con el caso de uso
  de cada una; INSERT ... ON CONFLICT; el índice único como última línea de
  defensa; bloqueo pesimista contra optimista con criterio para elegir;
  deadlocks, cómo se producen y cómo se leen en el log; y cómo OBSERVAR todo
  esto desde pg_stat_activity y pg_locks.
- Cierre obligatorio: la guía de "cuándo usar qué" para el caso concreto de
  vender un número que no se puede vender dos veces.

Audiencia: dev senior con años de SQL que probablemente sabe qué es un
nivel de aislamiento pero nunca tuvo que elegir uno con un número de por
medio. El apéndice tiene que ser ejecutable: cada mecanismo con su sesión
doble reproducible en dos terminales.

No hace falta preguntarme por versiones. Si algo específico no está
definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Apéndice bea-06 — Tiempo, zonas y relojes

```
Este es el chat de redacción del Apéndice bea-06 — Tiempo, zonas y relojes,
del track BE opcional del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7) be06 ya escrita y la Fase
7 del track base, (8) decisiones de este chat.

Contexto de este apéndice:
- Apéndice: bea-06 — Tiempo, zonas y relojes.
- Horas estimadas: 3h.
- Fases que lo referencian: be06; be02 y be07 lo consultan.
- Es material de CONSULTA RÁPIDA.
- Contenido esperado: qué hace REALMENTE Postgres con TIMESTAMPTZ, que es
  donde casi todo el mundo tiene el modelo mental equivocado; TIMESTAMP sin
  zona y por qué casi nunca es lo que quieres; time.Time en Go y su zona;
  RFC 3339 como formato de frontera; horario de verano y el minuto que
  existe dos veces; la ausencia de tipo fecha en SQLite; y el reloj del
  cliente como fuente permanente de bugs.
- Cierre obligatorio: guía de "cuándo usar qué" — dónde se guarda UTC, dónde
  se guarda la zona del negocio, y dónde se convierte para mostrar.

Audiencia: dev senior que ya sufrió esto. No le expliques qué es UTC ni qué
es un offset. Explícale las trampas concretas de este stack, con el caso del
curso —una rifa que cierra a medianoche— como hilo.

No hace falta preguntarme por versiones. Si algo específico no está
definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Apéndice bea-07 — Logs, request-id y correlación

```
Este es el chat de redacción del Apéndice bea-07 — Logs, request-id y
correlación, del track BE opcional del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7) be01 ya escrita, la Fase 2
del track base (el interceptor que lee el X-Request-Id) y el apéndice A13
(depurar el build de producción), (8) decisiones de este chat.

Contexto de este apéndice:
- Apéndice: bea-07 — Logs, request-id y correlación.
- Horas estimadas: 2h.
- Fases que lo referencian: be01 y todas las posteriores.
- Es material de CONSULTA RÁPIDA.
- Contenido esperado: log estructurado con la biblioteca estándar de Go 1.19
  (sin slog, que es de 1.21 — ver D14); el X-Request-Id generado o
  respetado si ya viene; su propagación por context.Context hasta el store y
  hasta la consulta SQL; qué se loguea y qué NUNCA se loguea (tokens,
  contraseñas, datos personales); niveles de log y ruido; y el recorrido
  completo de un request-id desde la consola del navegador hasta la query,
  con su tiempo.
- Cierre obligatorio: guía de "cuándo usar qué" para diagnosticar con logs
  frente a diagnosticar con DevTools.

Este apéndice cierra un bucle que el track base abrió: el interceptor de la
Fase 2 loguea un request-id que en el mock nace y muere en el middleware.
Acá ese id cruza todo el backend y la correlación deja de ser un ejercicio
para volverse una herramienta. Escríbelo con esa continuidad explícita.

No hace falta preguntarme por versiones. Si algo específico no está
definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Apéndice bea-08 — Seguridad de API aplicada

```
Este es el chat de redacción del Apéndice bea-08 — Seguridad de API
aplicada, del track BE opcional del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7) be04 ya escrita y
bea-04, (8) decisiones de este chat.

Contexto de este apéndice:
- Apéndice: bea-08 — Seguridad de API aplicada.
- Horas estimadas: 3h.
- Fases que lo referencian: be04 principalmente; be03 y be09 lo consultan.
- Es material de CONSULTA RÁPIDA.
- Contenido esperado, SIEMPRE aplicado al dominio de rifas y nunca en
  abstracto: inyección SQL y por qué los placeholders parametrizados no son
  negociable; autorización a nivel de objeto (que un vendedor no liquide la
  rifa de otro); asignación masiva (que el cuerpo de un POST no pueda fijar
  el estado o el precio); límites de tasa; qué filtra un mensaje de error; y
  CORS bien entendido, que es de lo que más se malinterpreta.
- Cierre obligatorio: guía de "cuándo usar qué" y una lista de lo que este
  backend NO cubre a propósito, para que nadie lo confunda con un backend de
  producción.

Encuadre defensivo: este apéndice enseña a PROTEGER la aplicación del curso.
Los ataques se explican al nivel necesario para escribir la defensa y
reconocer el síntoma — no como recetas ofensivas ni contra sistemas ajenos.

Audiencia: dev senior que conoce OWASP de oídas y necesita aterrizarlo en
ESTE código. Nada de listas genéricas de diez puntos: cada riesgo con su
línea de código de este proyecto.

No hace falta preguntarme por versiones. Si algo específico no está
definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Apéndice bea-09 — Mapa de deuda del track BE

```
Este es el chat de redacción del Apéndice bea-09 — Mapa de deuda del track
BE, del track BE opcional del tutorial React 16 + Rifas y chances.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7) TODAS las fases be00-be09
ya escritas, más el apéndice A12 del track base como modelo estructural, (8)
decisiones de este chat.

Contexto de este apéndice:
- Apéndice: bea-09 — Mapa de deuda del track BE.
- Horas estimadas: 2h.
- Fases que lo referencian: be09 principalmente; cualquier fase que declare
  una deuda 💸 la registra acá.
- Es material de CONSULTA RÁPIDA y es HERMANO DE A12: misma estructura,
  mismo criterio, otra capa.
- Contenido esperado: cada deuda declarada en el track BE con su fase de
  origen, qué la vuelve exigible, cuánto costaría pagarla y en qué orden se
  pagaría. Entran, como mínimo: el refresh token que no existe y el JWT de
  vida larga; el endpoint POST /_chaos que ningún backend real debería
  tener; la ausencia de roles y permisos finos; el secreto del JWT en
  variable de entorno sin rotación; la falta de paginación real en algún
  listado si quedó así; y la decisión cgo si se dejó sin resolver.
- Cierre obligatorio: guía de "cuándo usar qué" — qué deuda se paga primero
  si este sistema fuera a producción de verdad.

⚠️ Este apéndice SOLO se escribe cuando las diez fases estén cerradas: su
insumo son las secciones 📌 Pendientes de cada una. Escribirlo antes
garantiza que quede incompleto.

El tono: inventario sereno, sin dramatismo y sin autoflagelación. Una deuda
declarada y medida es una decisión de ingeniería; una deuda oculta es un
problema.

No hace falta preguntarme por versiones. Si algo específico no está
definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```

---

## Apéndice bea-10 — Datos de prueba y faker 🔥

```
Este es el chat de redacción del Apéndice bea-10 — Datos de prueba y faker,
del track BE opcional del tutorial React 16 + Rifas y chances. Es un
apéndice OPCIONAL 🔥 dentro de un track ya opcional.

Actúa siguiendo las instrucciones del proyecto. Fuentes de verdad, en este
orden: (1) prompts/instrucciones-del-proyecto.md, (2)
00-alcance-del-proyecto.md, (3) prompts/propuesta-fases-backend.md, (4)
prompts/decisiones-y-versiones.md §7, (5)
prompts/guia-de-estilo-y-convenciones.md (§16), (6)
prompts/diccionario-codigo-ingles.md (§7bis), (7) be03 y be08 ya escritas,
(8) decisiones de este chat.

Contexto de este apéndice:
- Apéndice: bea-10 — Datos de prueba y faker. OPCIONAL 🔥.
- Horas estimadas: 2h.
- Fases que lo referencian: be03 (ejercicio 🔥 de volumen), be05 y be08
  (mediciones que necesitan datos suficientes).
- Es material de CONSULTA RÁPIDA.
- Contenido esperado: la siembra determinista desde el db.json del track
  base, que es el camino por defecto y no se reemplaza; generación de
  volumen con brianvoe/gofakeit v6 para llegar a decenas de rifas y decenas
  de miles de números; cómo FIJAR LA SEMILLA del generador para que un
  conjunto de datos sea reproducible; datos que respetan las reglas del
  dominio (una rifa cerrada no puede tener números vendidos después de su
  hora de cierre); y cómo limpiar y regenerar sin romper migraciones.
- El punto que justifica el apéndice, y tiene que quedar clavado: UN
  CONJUNTO DE DATOS ALEATORIO ARRUINA UNA PRUEBA DE REGRESIÓN. El faker es
  herramienta de carga y de medición, nunca de aserción. Una prueba que
  afirma sobre datos que cambian en cada corrida es una prueba que va a
  fallar sola algún martes.
- Cierre obligatorio: guía de "cuándo usar qué" — semilla real, faker con
  semilla fija, o fixture escrito a mano.

Decisiones confirmadas que aplican (no se reabren en este chat):
- brianvoe/gofakeit v6.19.x es dependencia SOLO de este apéndice y vive en
  server/internal/seed/. No entra al go.mod del backend como dependencia de
  producción.

Referencias: acá sí caben enlaces a tutoriales externos de generación de
datos, con la advertencia de la guía de estilo §10.3 — pueden ser inexactos
y hay que verificarlos.

No hace falta preguntarme por versiones. Si algo específico no está
definido, pregúntame antes de asumir.

Confírmame que tienes el contexto y quedamos listos para el prompt de
redacción.
```
