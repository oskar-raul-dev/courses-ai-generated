# 🕰️ Apéndice bea-06 — Tiempo, zonas y relojes

> Tutorial React 16 — Rifas y chances · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be06`; `be02` y `be07` lo consultan

---

Ya sufriste zonas horarias. No vamos a explicar qué es UTC ni qué es un offset.
Lo que sigue son **las trampas concretas de este stack** —Postgres 13, Go 1.19,
un navegador y SQLite en pruebas— con el caso del curso como hilo: *una rifa que
cierra a las 22:00 del 30 de agosto en Bogotá*.

La pregunta que ordena el apéndice es una sola:

> 🧭 **¿Esto es un instante o es una fecha de calendario?** Un instante es un
> punto en la línea del tiempo del universo: el cierre de la rifa. Una fecha de
> calendario es una etiqueta local sin instante asociado: un cumpleaños, un
> feriado. **Se guardan distinto, se comparan distinto y se rompen distinto.**
> Este dominio solo tiene instantes, y eso simplifica más de lo que parece.

---

## 🧭 Índice de salto rápido

1. [Qué hace realmente Postgres con `TIMESTAMPTZ`](#1-qué-hace-realmente-postgres-con-timestamptz)
2. [`TIMESTAMP` sin zona, y por qué casi nunca lo quieres](#2-timestamp-sin-zona-y-por-qué-casi-nunca-lo-quieres)
3. [`time.Time` en Go: zona, reloj monótono y `==`](#3-timetime-en-go-zona-reloj-monótono-y-)
4. [RFC 3339 como formato de frontera](#4-rfc-3339-como-formato-de-frontera)
5. [Horario de verano: el minuto que existe dos veces](#5-horario-de-verano-el-minuto-que-existe-dos-veces)
6. [SQLite: sin tipo fecha](#6-sqlite-sin-tipo-fecha)
7. [El reloj del cliente](#7-el-reloj-del-cliente)
8. [🧩 Cuándo usar qué: dónde vive cada cosa](#-cuándo-usar-qué-dónde-vive-cada-cosa)

---

## 1. Qué hace realmente Postgres con `TIMESTAMPTZ`

Empecemos por el malentendido, porque es el que produce las facturas.

> ⚠️ **`TIMESTAMP WITH TIME ZONE` no almacena ninguna zona horaria.** El nombre
> es desafortunado hasta el punto de ser engañoso.

Lo que guarda es un **instante**, internamente en UTC, con los mismos 8 bytes que
un `TIMESTAMP` normal. La zona aparece en dos momentos y en ninguno más:

- **Al entrar.** Si el literal trae offset, lo usa para convertir a UTC. Si **no**
  lo trae, asume la zona de la sesión (`SHOW TimeZone`).
- **Al salir.** Convierte el instante a la zona de la sesión y lo muestra así.

Compruébalo, que es la mejor forma de entenderlo:

```sql
CREATE TEMP TABLE t (a TIMESTAMPTZ, b TIMESTAMP);
INSERT INTO t VALUES ('2026-08-30 22:00:00-05', '2026-08-30 22:00:00-05');

SET TIME ZONE 'America/Bogota';   SELECT * FROM t;
--   a: 2026-08-30 22:00:00-05    b: 2026-08-30 22:00:00
SET TIME ZONE 'UTC';              SELECT * FROM t;
--   a: 2026-08-31 03:00:00+00    b: 2026-08-30 22:00:00   ← b NO cambió
SET TIME ZONE 'Asia/Tokyo';       SELECT * FROM t;
--   a: 2026-08-31 12:00:00+09    b: 2026-08-30 22:00:00
```

La columna `a` dice **el mismo instante** de tres maneras. La `b` dice "las 22:00"
y se niega a decir de dónde: el offset del `INSERT` se descartó sin aviso.

De ahí sale la propiedad que hace correcto usar `TIMESTAMPTZ`: **dos valores que
representan el mismo instante son iguales**, sin importar con qué offset se
escribieron.

```sql
SELECT '2026-08-30 22:00:00-05'::timestamptz = '2026-08-31 03:00:00+00'::timestamptz;
-- t
```

> ⚠️ **El corolario que muerde.** La zona de la sesión afecta a la **salida**. Dos
> aplicaciones leyendo la misma fila pueden ver `22:00-05:00` y `03:00+00:00`, y
> las dos tienen razón. Si tu código compara **cadenas** de fecha, acabas de
> heredar un bug que depende de la configuración del servidor.

Y por eso `be06` fija las dos zonas por separado y con jerarquía explícita:

| Qué | Valor | Para qué |
|---|---|---|
| Zona del **proceso** Go | `TZ=UTC` | Decidir y comparar instantes |
| Zona de la **sesión** de base | `America/Bogota` | **Solo** serializar la salida con el offset del contrato |

📖 **El instante es la verdad; el offset de la serialización es cosmética.** La
zona de presentación no participa en ninguna decisión.

---

## 2. `TIMESTAMP` sin zona, y por qué casi nunca lo quieres

Un `TIMESTAMP` sin zona es un número que parece una fecha. "Las 22:00" sin decir
de dónde **no identifica ningún momento del universo**, y compararlo con otro es
comparar dos opiniones.

Los síntomas son siempre los mismos y siempre tardíos: todo funciona en
desarrollo —donde el servidor está en tu misma zona— y las horas se corren en
producción, donde está en UTC. La ambigüedad no se nota hasta que se nota.

**Cuándo `TIMESTAMP` sin zona sí es lo correcto:** cuando el dato **no es un
instante**. Un feriado nacional es "el 20 de julio", no un punto en la línea del
tiempo; convertirlo a UTC lo empeora. Este dominio no tiene ninguno.

> ⚠️ **Cuidado con las migraciones de tipo.** Un `ALTER COLUMN … TYPE TIMESTAMPTZ`
> **reinterpreta** los datos existentes usando la zona de la sesión. Si los
> valores se guardaron en otra zona, acabas de mover todas tus fechas sin que
> nada falle. Antes de convertir: comprueba en qué zona se escribieron y usa
> `AT TIME ZONE` explícito.

---

## 3. `time.Time` en Go: zona, reloj monótono y `==`

Un `time.Time` lleva tres cosas: el instante, una `*Location`, y —si vino de
`time.Now()`— una lectura de **reloj monótono**.

### El reloj monótono, que rompe las comparaciones

`time.Now()` adjunta una lectura monótona pensada para medir duraciones (inmune a
ajustes de NTP). Esa lectura **no sobrevive** a una serialización ni a una ida y
vuelta a la base. Consecuencia:

```go
t1 := time.Now()
t2 := t1.Round(0)      // Round(0) descarta la lectura monótona
t1 == t2               // false  ❌ aunque sean el mismo instante
t1.Equal(t2)           // true   ✅
```

> 🧭 **En Go, `time.Time` no se compara con operadores. Nunca.** `Equal`, `Before`
> y `After`. El síntoma de olvidarlo es un test que falla comparando dos fechas
> que se ven idénticas en el mensaje de error, y se pierde media hora buscando en
> el lugar equivocado.

### La zona

`time.Now()` devuelve la hora en la zona local del proceso; `time.Now().UTC()`, en
UTC. El instante es el mismo — solo cambia cómo se imprime y qué devuelven
`Hour()`, `Day()` y compañía.

```go
func (systemClock) Now() time.Time { return time.Now().UTC() }
```

Que el `Clock` del track devuelva UTC no es cosmética: fija que el backend se
comporte igual en tu máquina, en el contenedor y en el runner de CI. **Un backend
cuyo comportamiento depende de la configuración regional del host falla distinto
en cada ambiente.**

### El valor cero, y el puntero

El cero de `time.Time` es el 1 de enero del año 1, y `IsZero()` lo detecta. Pero
si el dominio distingue "no hay fecha" de "hay una fecha", **usa un puntero**:
`*time.Time` serializa `nil` a `null`. Es la misma decisión que el
`*int64` del `participantId` de `be03`, y la misma que `golang-jwt` v4 tomó al
cambiar `int64` por `*NumericDate`.

### Cargar zonas

`time.LoadLocation("America/Bogota")` lee la base de datos de zonas **del
sistema**, y una imagen mínima no la tiene:

```go
import _ "time/tzdata"   // embebe la base en el binario (~450 KB)
```

Sin eso, `unknown time zone` **solo dentro del contenedor**: funciona en tu
máquina y falla en el despliegue (`be09`, error común 2).

---

## 4. RFC 3339 como formato de frontera

RFC 3339 es el perfil de ISO 8601 que se usa en APIs. Lo relevante:

```
2026-08-30T22:00:00-05:00     ← con offset
2026-08-31T03:00:00Z          ← el MISMO instante, en UTC
2026-08-30T22:00:00           ← ⚠️ sin offset: ambiguo, no es RFC 3339 válido
```

En Go: `time.RFC3339` (segundos) y `time.RFC3339Nano` (con fracción). En JSON,
`encoding/json` serializa `time.Time` en RFC 3339 automáticamente, con el offset
que traiga el valor.

**Las tres reglas de frontera del track:**

1. **Siempre con offset.** Un instante sin offset es una invitación a que cada
   consumidor lo interprete a su manera.
2. **Nunca literales de fecha en el SQL.** Los instantes viajan como `time.Time`
   por placeholder; el driver los serializa. Un literal sin offset lo interpreta
   Postgres en la zona de la sesión (§1).
3. **`Z` y `-05:00` son intercambiables para el cliente.** `new Date()` produce el
   mismo valor con los dos. El track conserva el offset del contrato por
   verificabilidad y legibilidad, no por semántica.

---

## 5. Horario de verano: el minuto que existe dos veces

Colombia no tiene horario de verano: `America/Bogota` es UTC−5 todo el año. **Este
dominio se libra del problema por suerte geográfica, no por diseño**, y por eso
conviene saber qué habría pasado con otra zona.

En una zona con DST hay dos momentos patológicos cada año:

- **Adelanto (primavera):** una hora local **no existe**. Si el cierre estaba
  programado a las 02:30 y el reloj salta de 02:00 a 03:00, ese instante nunca
  ocurre.
- **Atraso (otoño):** una hora local **existe dos veces**. "Las 01:30" son dos
  instantes distintos separados por una hora, y un `TIMESTAMP` sin zona no puede
  decirte cuál.

```sql
SET TIME ZONE 'America/Santiago';
SELECT '2026-04-04 23:30:00'::timestamp AT TIME ZONE 'America/Santiago';
-- pruébalo alrededor del cambio y mira qué instante te devuelve
```

> 🧭 **Guardar el instante te salva de todo esto. Guardar "hora local + zona", no.**
> Si el dato es un instante ya decidido —el cierre de *esta* rifa— un
> `TIMESTAMPTZ` es inmune: el momento patológico ya se resolvió cuando se
> calculó.
>
> El problema aparece con **reglas recurrentes**: *"todas las rifas cierran los
> viernes a las 22:00 hora local"*. Ahí sí hay que guardar la regla —la hora local
> y **el nombre IANA de la zona**, nunca el offset— y calcular el instante cada
> vez. Porque los offsets **cambian por decisión política**, varias veces al año
> en el mundo, y la base de datos de zonas se actualiza para seguirlas.
>
> 📖 Las zonas horarias no son un problema técnico: son un **problema legal** con
> consecuencias técnicas.

Este dominio no tiene reglas recurrentes. Si algún día las tuviera, esa es la
conversación que habría que abrir — y sería una migración de esquema, no un
parche.

---

## 6. SQLite: sin tipo fecha

SQLite **no tiene** tipo de fecha. Guarda `TEXT`, `INTEGER` o `REAL`, y comparar
texto es comparación lexicográfica. Con formato ISO y **todo en el mismo huso**
funciona por accidente; con husos mezclados, no.

El caso del track (Divergencia 2 de `be02`, Prueba B de `be08`):

```sql
-- closes_at = '2026-08-30T22:00:00-05:00'  →  el 31 a las 03:00 UTC
SELECT name FROM raffles WHERE closes_at > '2026-08-31T01:00:00Z';
```

- **Postgres:** compara instantes → 03:00Z > 01:00Z → **devuelve la rifa**.
- **SQLite:** compara `'2026-08-30…'` con `'2026-08-31…'` → `30 < 31` → **nada**.

Los dos funcionan correctamente según su especificación, y tu regla de negocio da
resultados **opuestos**.

> 🧭 **Consecuencia directa, y es una de las cuatro áreas de la regla del motor:**
> cualquier prueba que dependa de comparar instantes **corre contra Postgres o no
> vale**. El diccionario completo de divergencias está en `bea-03` §4.

---

## 7. El reloj del cliente

`new Date()` en el navegador devuelve la hora del equipo del usuario, que el
usuario controla con dos clics. La Fase 7 del track base lo dejó anotado como
deuda 💸 y `be06` la cobró **del lado del servidor**.

Los dos escenarios, y no son simétricos:

| El reloj del cliente está… | La interfaz | El servidor | Consecuencia |
|---|---|---|---|
| **Adelantado** | Cierra antes de tiempo, esconde el botón | Sigue vendiendo | El usuario **pierde una venta legítima**. Molesto |
| **Atrasado** | Sigue mostrando el botón | Rechaza con `409` | Mensaje confuso, **datos correctos** |

Antes de `be06`, el segundo caso vendía un número de una rifa cerrada y el
desajuste aparecía semanas después, en la liquidación. **Una interfaz confusa es
un problema; una base de datos mentirosa es un incidente.**

**Qué se hizo y qué no.** El servidor publica su hora en cada respuesta:

```go
w.Header().Set("X-Server-Time", s.clock.Now().Format(time.RFC3339Nano))
```

Hoy **nadie lo consume**. Está puesto igual, y no es un adorno: es el punto donde
la deuda se vuelve barata de pagar. Consumirlo exigiría un interceptor que guarde
el desfase y una función `serverNow()` que lo aplique —unas treinta líneas en dos
archivos del frontend— y eso excede la única excepción negociada del track
(`D27`). 💸 Queda declarada, con su precio, en `bea-09`.

Y una advertencia sobre medir el desfase: el simple `hora del servidor − hora
local` incluye la latencia de la red. La corrección seria —descontar la mitad del
tiempo de ida y vuelta— es media implementación de NTP, y sirve para entender por
qué sincronizar relojes es más difícil de lo que parece.

---

## 🧩 Cuándo usar qué: dónde vive cada cosa

| Dato | Dónde y cómo |
|---|---|
| Un instante de negocio (cierre, venta, liquidación) | `TIMESTAMPTZ` en la base, `time.Time` en Go, RFC 3339 con offset en el JSON |
| Una fecha de calendario (feriado, cumpleaños) | `DATE`. No lo conviertas a instante |
| Una regla recurrente ("los viernes a las 22:00") | La hora local **y el nombre IANA de la zona**, nunca el offset. Este dominio no tiene ninguna |
| Una duración (TTL de reserva, ventana de gracia) | `time.Duration` / `INTERVAL`. No dos fechas |
| La hora "de ahora" en SQL | La costura (`db.Now()`), nunca `now()` escrito a mano |
| La hora "de ahora" en Go | Un `Clock` inyectado. Nunca `time.Now()` dentro de la lógica |

| Quién decide qué |
|---|
| **El servidor** decide si una venta llega a tiempo. Siempre |
| **El servidor** sella cuándo ocurrió un hecho de negocio (`settledAt`, `soldAt`) |
| **El cliente** decide **cómo se muestra** una fecha al usuario |
| **El cliente** puede decidir si enseña un botón. Es cortesía, no protección |

Y las cinco reglas que resumen el apéndice:

1. **Guarda instantes, no horas de pared**, salvo que el dato sea de calendario.
2. **Compara instantes, nunca cadenas ni componentes de fecha.**
3. **Fija las zonas explícitamente** —proceso y sesión— en vez de heredar la del
   host.
4. **Inyecta el reloj**, o no podrás probar los bordes.
5. **Nunca confíes en el reloj del cliente** para una regla de negocio.

---

## 🧪 Ejercicios (8)

1. **🟢** Ejecuta el experimento del §1 con las tres zonas y anota qué columna cambia y cuál no.
2. **🟢** Comprueba que `'2026-08-30 22:00:00-05'::timestamptz = '2026-08-31 03:00:00+00'::timestamptz` es verdadero, y explica por qué.
3. **🟡 Diagnóstico.** Compara dos `time.Time` con `==` en un test y hazlo fallar. Imprime los valores con `%+v` e identifica qué llevan adjunto.
4. **🟡** Arranca el backend con `TZ=Asia/Tokyo` y corre la suite entera. Si algo falla, encontraste una comparación que mira componentes de fecha. Si no falla nada, explica por qué eso demuestra que la política del §1 funciona.
5. **🟠 Diagnóstico.** Ejecuta el §6 contra los dos motores y pega las dos salidas. Clasifica la divergencia en una de las cuatro áreas de la regla del motor.
6. **🟠 Diagnóstico.** Adelanta el reloj de tu máquina una hora y recorre la aplicación. Documenta los dos escenarios de la tabla del §7, con capturas.
7. **🟠** Elige una zona con horario de verano, pon un `closesAt` justo en el salto, y determina qué pasa. Explica por qué guardar el instante te salva y guardar "hora local + zona" no.
8. **🔴** Escribe la política de tiempo del sistema como documento de una página para quien entre nuevo: qué se guarda, en qué tipo, en qué zona corre cada proceso, quién decide, cómo se serializa y qué está prohibido. Tiene que poder aplicarse sin leer código.

---

## 📚 Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/13/datatype-datetime.html — §8.5.1.3 es exactamente el malentendido del §1.
- https://www.postgresql.org/docs/13/functions-datetime.html — `AT TIME ZONE`, que es la herramienta del §2.
- https://wiki.postgresql.org/wiki/Don%27t_Do_This#Don.27t_use_timestamp_.28without_time_zone.29 — el §2 en cinco líneas y sin diplomacia.
- https://pkg.go.dev/time — y en particular la sección "Monotonic Clocks", que explica el §3.
- https://pkg.go.dev/time#Time.Equal — por qué existe y por qué `==` no sirve.
- https://pkg.go.dev/time/tzdata — el import de una línea del §3.
- https://www.rfc-editor.org/rfc/rfc3339 — corto, y vale la pena leerlo entero una vez en la vida.
- https://www.iana.org/time-zones — la base de datos de zonas. Mira su historial de cambios: es el §5 en estado puro.
- https://www.sqlite.org/lang_datefunc.html — qué ofrece SQLite en lugar de un tipo fecha.

**Libros**
- *Designing Data-Intensive Applications* (Kleppmann) — la sección *Unreliable Clocks* del capítulo 8. Su idea de que "los relojes son intervalos de confianza, no puntos" cambia cómo se diseña.

**Video / apoyo**
- "The Problem with Time & Timezones" (Computerphile) — diez minutos, y es la mejor introducción que existe al tema. Si solo vas a ver una cosa de esta lista, que sea esta.

**Orden de lectura sugerido:** el vídeo de Computerphile para la intuición → el
"Don't Do This" del wiki de Postgres, que fija la regla → el §1 de este apéndice
ejecutado con las manos → `datatype-datetime.html` §8.5 para el detalle → y la
nota del reloj monótono en `pkg.go.dev/time` el día que un test te falle sin
motivo aparente.

> ⚠️ URLs, títulos y ediciones pueden haber cambiado: verifícalos. Las
> referencias a libros y videos son de memoria y pueden ser inexactas. La
> documentación de Postgres tiene **una versión por URL**: fija el 13. La fuente
> de verdad de versiones es `prompts/decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. La política de tiempo
> del ejercicio 8 y la evidencia del desfase van en `server/evidence/reloj.md`,
> que es entregable de `be06`.
