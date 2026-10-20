# 🕰️ Apéndice bea-06 — Tiempo, zonas y relojes

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · **Track BE opcional 🔥** · Consulta rápida · ~3 horas
> Lo referencian: `be06`; `be02` y `be07` lo consultan

---

Ya sufriste zonas horarias. No vamos a explicar qué es UTC ni qué es un offset.
Lo que sigue son **las trampas concretas de este stack** —Postgres 13, Go 1.19,
un navegador, un celular y SQLite en pruebas— con el caso del curso como hilo: *la
Rueda de fin de mes, que cerró a las 8:00 p. m. del 30 de agosto de 2026 en Panamá*.

La pregunta que ordena el apéndice es una sola:

> 🧭 **¿Esto es un instante o es una fecha de calendario?** Un instante es un
> punto en la línea del tiempo del universo: el cierre de la rueda. Una fecha de
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

Empecemos por el malentendido, porque es el que produce los tickets.

> ⚠️ **`TIMESTAMP WITH TIME ZONE` no almacena ninguna zona horaria.** El nombre
> es desafortunado hasta el punto de ser engañoso.

Lo que guarda es un **instante**, internamente en UTC, con los mismos 8 bytes que
un `TIMESTAMP` normal. La zona aparece en dos momentos y en ninguno más:

- **Al entrar.** Si el literal trae offset, lo usa para convertir a UTC. Si **no**
  lo trae, asume la zona de la sesión (`SHOW TimeZone`).
- **Al salir.** Convierte el instante a la zona de la sesión y lo muestra así.

Compruébalo en `psql`, que es la mejor forma de entenderlo:

```sql
CREATE TEMP TABLE t (a TIMESTAMPTZ, b TIMESTAMP);
INSERT INTO t VALUES ('2026-08-30 20:00:00-05', '2026-08-30 20:00:00-05');

SET TIME ZONE 'America/Panama';   SELECT * FROM t;
--   a: 2026-08-30 20:00:00-05    b: 2026-08-30 20:00:00
SET TIME ZONE 'UTC';              SELECT * FROM t;
--   a: 2026-08-31 01:00:00+00    b: 2026-08-30 20:00:00   ← b NO cambió
SET TIME ZONE 'Asia/Tokyo';       SELECT * FROM t;
--   a: 2026-08-31 10:00:00+09    b: 2026-08-30 20:00:00
```

La columna `a` dice **el mismo instante** de tres maneras. La `b` dice "las 8:00
p. m." y se niega a decir de dónde: el offset del `INSERT` se descartó sin aviso.

De ahí sale la propiedad que hace correcto usar `TIMESTAMPTZ`: **dos valores que
representan el mismo instante son iguales**, sin importar con qué offset se
escribieron.

```sql
SELECT '2026-08-30 20:00:00-05'::timestamptz = '2026-08-31 01:00:00+00'::timestamptz;
-- t
```

> ⚠️ **El corolario que muerde.** La zona de la sesión afecta a la **salida**. Dos
> aplicaciones leyendo la misma fila pueden ver `20:00-05:00` y `01:00+00:00`, y
> las dos tienen razón. Si tu código compara **cadenas** de fecha, acabas de
> heredar un bug que depende de la configuración del servidor.

Y por eso `be06` fija las dos zonas por separado y con jerarquía explícita:

| Qué | Valor | Para qué |
|---|---|---|
| Zona del **proceso** Go | UTC (`time.Local = time.UTC`) | Decidir y comparar instantes |
| Zona de la **sesión** de base | `America/Panama`, en el DSN de cada conexión | **Solo** serializar la salida con el offset del contrato |

Las dos, escritas en el código (`be06` §5.1). Un `SET TIME ZONE` después de abrir el pool
vale para una sola conexión: medido, 9 de 200 consultas salieron en Panamá y 191 en UTC.

📖 **El instante es la verdad; el offset de la serialización es cosmética.** La
zona de presentación no participa en ninguna decisión.

---

## 2. `TIMESTAMP` sin zona, y por qué casi nunca lo quieres

Un `TIMESTAMP` sin zona es un número que parece una fecha. "Las 8:00 p. m." sin decir
de dónde **no identifica ningún momento del universo**, y compararlo con otro es
comparar dos opiniones.

Los síntomas son siempre los mismos y siempre tardíos: todo funciona en
desarrollo —donde el servidor está en tu misma zona— y las horas se corren en
producción, donde está en UTC. La ambigüedad no se nota hasta que se nota.

**Cuándo `TIMESTAMP` sin zona sí es lo correcto:** cuando el dato **no es un
instante**. Un feriado nacional es "el 3 de noviembre", no un punto en la línea del
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
t2 := t1.Round(0) // Round(0) descarta la lectura monótona
fmt.Println("t1 == t2:", t1 == t2, "· t1.Equal(t2):", t1.Equal(t2))
fmt.Printf("%+v\n", t1)
```

```text
t1 == t2: false · t1.Equal(t2): true
2026-10-20 03:18:59.410916127 +0000 UTC m=+0.000021293
```

El `m=+0.000021293` del final es la lectura monótona: viaja con `t1` y no con `t2`.

> 🧭 **En Go, `time.Time` no se compara con operadores. Nunca.** `Equal`, `Before`
> y `After`. El síntoma de olvidarlo es un test que falla comparando dos fechas
> que se ven idénticas en el mensaje de error, y se pierde media hora buscando en
> el lugar equivocado.

### La zona

`time.Now()` devuelve la hora en la zona local del proceso; `time.Now().UTC()`, en
UTC. El instante es el mismo — solo cambia cómo se imprime y qué devuelven
`Hour()`, `Day()` y compañía.

```go
func (System) Now() time.Time { return time.Now().UTC() }
```

Que el `clock.System` del track devuelva UTC no es cosmética: fija que el backend se
comporte igual en tu máquina, en el contenedor y en el runner de CI. **Un backend
cuyo comportamiento depende de la configuración regional del host falla distinto
en cada ambiente.**

### El valor cero, y el puntero

El cero de `time.Time` es el 1 de enero del año 1, y `IsZero()` lo detecta. Pero
si el dominio distingue "no hay fecha" de "hay una fecha", **usa un puntero**:
`*time.Time` serializa `nil` a `null`. Es la misma decisión que el
`*string` de `deliveredPrize` en el resultado del giro de `be05`, y la misma que
`golang-jwt` v4 tomó al cambiar `int64` por `*NumericDate`. En la base, el
`next_free_spin_at` nulo de `be06` significa *"ya puede reclamar"*.

### Cargar zonas

`time.LoadLocation("America/Santiago")` lee la base de datos de zonas **del
sistema**, y una imagen mínima no la tiene:

```go
import _ "time/tzdata" // embebe la base en el binario
```

Medido con Go 1.19.13, un programa mínimo pasa de 1.999.354 a 2.392.490 bytes:
unos 390 KB. Sin eso, `unknown time zone` **solo dentro del contenedor**: funciona
en tu máquina y falla en el despliegue (`be09`). Y con eso, la versión de la base
de zonas pasa a ser la de **tu** Go, no la de la imagen: el §5 explica por qué esa
diferencia puede ser de una hora.

---

## 4. RFC 3339 como formato de frontera

RFC 3339 es el perfil de ISO 8601 que se usa en APIs. Lo relevante:

```
2026-08-30T20:00:00-05:00     ← con offset
2026-08-31T01:00:00Z          ← el MISMO instante, en UTC
2026-08-30T20:00:00           ← ⚠️ sin offset: ambiguo, no es RFC 3339 válido
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
3. **`Z` y `-05:00` son intercambiables para el cliente.** `Date.parse()` produce el
   mismo valor con los dos. El track conserva el offset del contrato por
   verificabilidad y legibilidad, no por semántica.

---

## 5. Horario de verano: el minuto que existe dos veces

Panamá no tiene horario de verano: `America/Panama` es UTC−5 todo el año, y la
consola vive ahí. Pero los jugadores de la Esclusa de Oro no: los hay en Chile,
que cambia la hora dos veces al año. **La consola se libra del problema por suerte
geográfica, y el giro gratis no**: por eso conviene saber qué pasa en una zona
con horario de verano.

Hay dos momentos patológicos cada año, y Santiago tiene los dos en 2026:

- **Adelanto (septiembre):** una hora local **no existe**. La noche del sábado 5 al
  domingo 6, el reloj pasa de las 23:59 (`-04`) a la 01:00 (`-03`). Las 00:30 del
  domingo nunca ocurren.
- **Atraso (abril):** una hora local **existe dos veces**. La noche del sábado 4 al
  domingo 5, el reloj vuelve de la medianoche a las 23:00. "Las 23:30 del sábado"
  son dos instantes separados por una hora, y un `TIMESTAMP` sin zona no puede
  decirte cuál.

```sql
SELECT ts AT TIME ZONE 'America/Santiago' AS pared, ts
FROM (VALUES ('2026-04-05 02:30:00+00'::timestamptz), ('2026-04-05 03:30:00+00'::timestamptz)) v(ts);
--         pared        |           ts
--  2026-04-04 23:30:00 | 2026-04-05 02:30:00+00
--  2026-04-04 23:30:00 | 2026-04-05 03:30:00+00     ← la misma hora de pared, dos instantes

SELECT '2026-04-04 23:30:00'::timestamp AT TIME ZONE 'America/Santiago';
--  2026-04-05 03:30:00+00                           ← Postgres elige uno sin avisar
SELECT '2026-09-06 00:30:00'::timestamp AT TIME ZONE 'America/Santiago';
--  2026-09-06 04:30:00+00                           ← una hora que no existió, convertida igual
```

> 🧭 **Guardar el instante te salva de todo esto. Guardar "hora local + zona", no.**
> Si el dato es un instante ya decidido —el cierre de *esta* rueda, el próximo
> giro gratis de *este* jugador— un `TIMESTAMPTZ` es inmune: el momento
> patológico ya se resolvió cuando se calculó. El giro gratis de `be06` es
> "cuatro horas después del anterior": la noche de septiembre, un jugador de
> Santiago que reclama a las 23:30 vuelve a poder a las 4:30, **cinco horas** de
> pared y cuatro de verdad. Medido en `be06` §5.5, y no hay nada que corregir.
>
> El problema aparece con **reglas recurrentes**: *"un giro gratis a las 0, 4, 8…
> de la hora local de cada jugador"*, o *"todas las ruedas cierran los viernes a
> las 8:00 p. m. hora local"*. Ahí sí hay que guardar la regla —la hora local y
> **el nombre IANA de la zona**, nunca el offset— y calcular el instante cada vez.

Y los offsets **cambian por ley**. Paraguay usaba horario de verano (`-04` en
invierno, `-03` en verano) hasta octubre de 2024, cuando una ley lo dejó en `-03`
todo el año. Cada imagen de tu sistema trae su propia copia de la base de zonas,
congelada el día que se construyó. El 1 de julio de 2025 a las 12:00 UTC, en las
dos imágenes del laboratorio:

| Imagen | Base de zonas (`head -1 /usr/share/zoneinfo/tzdata.zi`) | `America/Asuncion` |
|---|---|---|
| `postgres:13` (13.23) | 2025b | 09:00 (−03) |
| `golang:1.19.13` | 2023c | 08:00 (−04) |

Una hora de diferencia entre dos capas del mismo sistema, y las dos *"tienen
razón"* según su base. Mientras solo compares instantes, ninguna decisión cambia.
El día que conviertas a la hora local de un jugador para **decidir** algo, la
versión de la base de zonas es una dependencia más, y se fija y se anota como
cualquier otra.

> 📖 Las zonas horarias no son un problema técnico: son un **problema legal** con
> consecuencias técnicas.

Este dominio no tiene reglas recurrentes. Si algún día las tuviera, esa es la
conversación que habría que abrir —y sería una migración de esquema, no un
parche—. El ejercicio 29 de `be06` la plantea.

---

## 6. SQLite: sin tipo fecha

SQLite **no tiene** tipo de fecha. Guarda `TEXT`, `INTEGER` o `REAL`, y comparar
texto es comparación lexicográfica. Con formato ISO y **todo en el mismo huso**
funciona por accidente; con husos mezclados, no.

El caso del track (Divergencia 2 de `be02`, Prueba B de `be08`):

```sql
-- closes_at = '2026-08-30T20:00:00-05:00'  →  el 31 a la 01:00 UTC
SELECT count(*) FROM wheels WHERE closes_at > '2026-08-30T23:00:00Z';
```

- **Postgres:** compara instantes → 01:00Z del 31 > 23:00Z del 30 → **1**.
- **SQLite** (3.45.3): compara `'2026-08-30T20…'` con `'2026-08-30T23…'` letra por
  letra → `20 < 23` → **0**.

Los dos funcionan correctamente según su especificación, y tu regla de negocio da
resultados **opuestos**.

> 🧭 **Consecuencia directa, y es una de las cuatro áreas de la regla del motor:**
> cualquier prueba que dependa de comparar instantes **corre contra Postgres o no
> vale**. El diccionario completo de divergencias está en `bea-03` §4. Y por eso
> `be06` compara el cierre en Go, con `time.Time`, y no en el `WHERE`: el barrido
> de cierre pasa la misma prueba en los dos motores.

---

## 7. El reloj del cliente

`new Date()` en el navegador devuelve la hora del equipo de la operadora, que ella
controla con dos clics. La hora del celular de un jugador, con dos toques. La Fase
7 del track base dejó anotado el primero como deuda 💸, y `be06` la cobró **del
lado del servidor**: el cierre y el giro gratis los decide su reloj.

Los dos escenarios, y no son simétricos:

| El reloj del cliente está… | La consola o el juego | El servidor | Consecuencia |
|---|---|---|---|
| **Adelantado** | Cierra antes de tiempo, deshabilita el giro | Sigue aceptando | Se **pierde un giro legítimo**. Molesto |
| **Atrasado** | Sigue ofreciendo el giro | Rechaza con `409` | Mensaje confuso, **datos correctos** |

Medido en el incidente `be-11`, con el navegador una hora adelante y una rueda a
la que le quedaban treinta minutos: la consola veía las 04:11 UTC y marcaba la
rueda `(cerrada)`; `X-Server-Time` decía las 03:11, y el mismo envío mandado al
servidor respondió `201`. Antes de `be06`, el segundo escenario anotaba un envío
de una rueda cerrada. **Una interfaz confusa es un problema; una base de datos
mentirosa es un incidente.**

Y la versión peligrosa: que el servidor **lea** la hora del cliente. Una cabecera
`X-Client-Now` *"para que la cuenta regresiva del juego coincida"* basta para que
un jugador con el celular cuatro horas adelante cobre otro giro gratis. Es el
incidente `be-18`. La hora del cliente no se valida: no se lee.

**Qué se hizo y qué no.** El servidor publica su hora en cada respuesta, con
milisegundos (`be06` §5.6):

```go
w.Header().Set(serverTimeHeader, clk.Now().Format("2006-01-02T15:04:05.000Z07:00"))
```

Y en el giro gratis manda el instante, `nextFreeSpinAt`, para que el juego pinte la
cuenta regresiva restando el desfase. La consola **no consume** `X-Server-Time`.
Está puesto igual, y no es un adorno: es el punto donde la deuda se vuelve barata
de pagar. Consumirlo exigiría un interceptor que guarde el desfase y una función
`serverNow()` que lo aplique, en `apiClient.js` y `closing.js`, y eso excede la
única excepción negociada del track (`D27`). 💸 Queda declarada, con su precio, en
`bea-09`.

Y una advertencia sobre medir el desfase: el simple `hora del servidor − hora
local` incluye la latencia de la red. La corrección seria —descontar la mitad del
tiempo de ida y vuelta— es media implementación de NTP, y sirve para entender por
qué sincronizar relojes es más difícil de lo que parece.

---

## 🧩 Cuándo usar qué: dónde vive cada cosa

| Dato | Dónde y cómo |
|---|---|
| Un instante de negocio (cierre, giro, compra, próximo giro gratis) | `TIMESTAMPTZ` en la base, `time.Time` en Go, RFC 3339 con offset en el JSON |
| Una fecha de calendario (feriado, cumpleaños) | `DATE`. No lo conviertas a instante |
| Una regla recurrente ("los viernes a las 8:00 p. m.") | La hora local **y el nombre IANA de la zona**, nunca el offset. Este dominio no tiene ninguna |
| Una duración (el giro gratis cada 4 h, el giro en proceso) | `time.Duration` / `INTERVAL`. No dos fechas |
| La hora "de ahora" en SQL | La costura (`db.Now()`), nunca `now()` escrito a mano |
| La hora "de ahora" en Go | Un `Clock` inyectado. Nunca `time.Now()` dentro de la lógica |

| Quién decide qué |
|---|
| **El servidor** decide si un giro llega a tiempo, y si ya toca el giro gratis. Siempre |
| **El servidor** sella cuándo ocurrió un hecho de negocio (`created_at` del giro, `nextFreeSpinAt`) |
| **El cliente** decide **cómo se muestra** una fecha al usuario |
| **El cliente** puede decidir si ofrece una opción. Es cortesía, no protección |

Y las cinco reglas que resumen el apéndice:

1. **Guarda instantes, no horas de pared**, salvo que el dato sea de calendario.
2. **Compara instantes, nunca cadenas ni componentes de fecha.**
3. **Fija las zonas explícitamente** —proceso y sesión— en vez de heredar la del
   host. Y anota qué versión de la base de zonas trae cada imagen.
4. **Inyecta el reloj**, o no podrás probar los bordes.
5. **Nunca confíes en el reloj del cliente** para una regla de negocio.

---

## 🧪 Ejercicios (8)

1. **🟢** Ejecuta el experimento del §1 con las tres zonas y anota qué columna cambia y cuál no.
2. **🟢** Comprueba que `'2026-08-30 20:00:00-05'::timestamptz = '2026-08-31 01:00:00+00'::timestamptz` es verdadero, y explica por qué.
3. **🟡 Diagnóstico.** Compara dos `time.Time` con `==` en un test y hazlo fallar. Imprime los valores con `%+v` e identifica qué llevan adjunto.
4. **🟡** Arranca el backend con `TZ=Asia/Tokyo` y corre la suite entera. Si algo falla, encontraste una comparación que mira componentes de fecha. Si no falla nada, explica por qué eso demuestra que la política del §1 funciona.
5. **🟠 Diagnóstico.** Ejecuta el §6 contra los dos motores y pega las dos salidas. Clasifica la divergencia en una de las cuatro áreas de la regla del motor.
6. **🟠 Diagnóstico.** Adelanta el reloj de tu máquina una hora, pon una rueda a cerrar en treinta minutos, y abre el asistente de envíos. Documenta los dos escenarios de la tabla del §7, con capturas y con `X-Server-Time`.
7. **🟠** Mide en tus imágenes la tabla de Asunción del §5: la versión de la base de zonas de cada una y el offset del mismo instante. Después pon un `closesAt` de una rueda a las 00:30 del 6 de septiembre de 2026 en Santiago, y explica qué guardó Postgres y por qué.
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
- https://www.iana.org/time-zones — la base de datos de zonas. Mira el anuncio de la versión 2025a: Paraguay, el §5 en estado puro.
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
> de verdad de versiones es `00-decisiones-y-versiones.md` §7.

---

> 🏷️ **Este apéndice no lleva tag.** Es de consulta pura. La política de tiempo
> del ejercicio 8 y la evidencia del desfase van en `server/evidence/reloj.md`,
> que es entregable de `be06`.
