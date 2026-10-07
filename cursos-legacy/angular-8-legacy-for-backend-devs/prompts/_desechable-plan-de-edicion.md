# 🗓️ Plan de edición: el giro a Ottawa–Gatineau
## Tutorial Angular 8 — LabCore, de Bogotá a la región de la capital de Canadá

Este documento dice **qué cambia en el curso por el giro de la historia, en qué orden y cuándo una
tanda está terminada**. El curso ya existe completo; el giro **no toca la estructura** (fases,
apéndices, horas, ejercicios) sino el **contexto**: lugar, zona horaria, identificadores de paciente,
moneda y nombre de la empresa. La única pieza nueva es el **incidente 22** (el cambio de hora).

Es un **plan de edición** y no de producción: el curso está cerrado y lo que se hace son cambios de
contenido sobre él. Se conservan las piezas operativas de la plantilla de producción: reglas de orden,
estado, tandas, verificaciones, bitácora, checklist y directorios de `zz-code/`.

- **El qué** lo manda [`../00-historia-del-sistema.md`](../00-historia-del-sistema.md) (v2, escrita el
  2026-10-06): Andina Laboratories Inc., sede en Ottawa, puntos en Gatineau, Chaudière Conseils y el
  equipo de San José, la cronología 2017 → 2019 → 2020 → 2021 → 2022.
- **La forma** la manda [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md),
  sobre todo §11 (las cuatro reglas de la ficción).
- **El orden** lo manda este documento.

> **Caducidad:** desechable. **No se cita desde ninguna fase, apéndice ni README.** Al cerrar la
> última tanda se borra con permiso del autor; lo que deba sobrevivir pasa a la guía de estilo.
>
> **Vigencia:** 2026-10-07. **Siguiente paso:** P2 (verificación de hechos), luego P3 y T1.

**Salto rápido:** [1](#1--decisiones) · [2](#2--reglas-de-orden) · [3](#3--estado) · [4](#4--inventario-del-impacto) · [5](#5--las-tandas) · [6](#6--hechos-por-verificar) · [7](#7--bitácora) · [8](#8--checklist-final) · [9](#9--directorios-de-zz-code)

---

## 1. 🧭 Decisiones

### 1.1 Tomadas por el autor (2026-10-06)

- **D1 — Lugar:** Ottawa–Gatineau.
- **D2 — Sede:** Ontario (Ottawa). El inglés es el idioma de la sede; el francés llega con Gatineau
  en 2020; el `DEFAULT_LANGUAGE = 'es'` de la Fase 02 se queda y la historia lo explica.
- **D3 — Cambio de hora:** es un **incidente nuevo, el 22**. La historia v2 ya lo cita y dice
  "veintidós tickets".
- **D4 — Cronología de los personajes:** llegada en 2008, convalidación y clínicas 2010–2015,
  posgrado, Andina abre en 2017, LabCore en 2019.
- **D5 — El curso no cambia en código ni en estructura**, salvo lo que exigen D6–D9. No se agrega
  contenido de legislación canadiense: la Ley 96 y la Ley 25 de Quebec quedan como contexto en la
  historia.

### 1.2 Tomadas por el autor sobre propuesta (2026-10-06)

Se conservan con su razonamiento porque las tandas lo necesitan. En D7 rige la **Opción A**.

- **D6 — Zona horaria de la aplicación: `America/Toronto`.** Es el identificador IANA de Ottawa y de
  Gatineau (`America/Montreal` es un alias de Toronto). Reemplaza a `America/Bogota` en
  `environment.timeZone`, en `APP_TIME_ZONE` y en todo el texto.

- **D7 — Las fechas de los datos pasan a invierno** *(Opción A)*. Hoy hay 60 marcas de tiempo con
  `-05:00`: 7 de enero (correctas en Ottawa) y 53 de mayo, junio, agosto y septiembre, que en Ottawa
  son `-04:00`. Hay dos caminos:

  **Opción A — mover las fechas a meses de horario de invierno y conservar el `-05:00`.**
  Qué cambia: solo cadenas de fecha. Toda la aritmética del curso ("a partir de las 19:00 ya es el día
  siguiente en UTC") sigue siendo verdad.
  El costo: hay que elegir fechas que conserven los días de la semana y los bordes de mes de cada
  incidente (el 07 necesita un viernes por la noche que cruce a sábado y a otro mes).
  Veredicto: **elegida.** Deja el cambio de hora aislado en el incidente 22 y en
  `bea-08` §8, donde enseña algo, en vez de repartido por todo el curso como ruido.

  **Opción B — conservar las fechas y corregir los desfases a `-04:00`.**
  Qué cambia: el desfase en cada marca de verano, y cada explicación que diga "UTC−5" o "19:00".
  El costo: más texto reescrito, y el lector ve dos desfases distintos desde la Fase 04 sin que nadie
  le haya explicado todavía por qué.
  Veredicto: descartada. Más correcta en apariencia, pero adelanta el problema del incidente 22 a fases donde
  estorba.

  Fechas candidatas, que el script de T1 confirma o ajusta (el criterio es fijo; la fecha exacta no):
  - `effectiveFrom` de la v2 de rangos: hoy `2019-06-01`, que además **contradice la cronología** (la
    historia dice que los rangos cambiaron en la Era 3, 2021). Candidata: `2022-01-01`, decidida en
    2021; el `2021-12-31` es viernes, así que el incidente 07 conserva su viernes por la noche que
    cruza a sábado y a otro mes.
  - Las órdenes y custodias de septiembre de 2019: candidatas en noviembre o diciembre de 2019,
    después del fin del horario de verano (3 de noviembre de 2019), y después del arranque de LabCore.
  - La v1 de rangos (`2019-01-01`) se queda.

- **D8 — Identificador del paciente.** Hoy es `CC-`, `TI-` o `CE-` (cédula, tarjeta de identidad y
  cédula de extranjería colombianas), validado con `/^(CC|TI|CE)-\d{6,12}$/` en la Fase 05 y con
  `^(CC|TI|CE)-[0-9]+$` en `bea-06`. Queda así: tres prefijos con el mismo largo y la misma forma,
  para que las regex y los tests solo cambien de letras:
  - `HC-` — tarjeta sanitaria provincial (OHIP en Ontario, RAMQ en Quebec);
  - `PP-` — pasaporte, para el recién llegado sin cobertura todavía, que es el cliente típico de Andina;
  - `LB-` — número interno del laboratorio, para quien no presenta ninguno de los dos.

  La regla que la Fase 05 enseña con la regex no cambia; cambia el dominio de los valores. Las
  longitudes de los números de ejemplo se ajustan a algo creíble (la tarjeta de Ontario tiene 10
  dígitos; la de Quebec es alfanumérica, y por eso conviene no prometer formato de provincia).

- **D9 — Moneda y locale de formato.** `currency:'COP'` en `a07` pasa a `'CAD'`, con dos decimales
  (`'1.2-2'`) porque el dólar sí los usa. `toLocaleString('es-CO', …)` en `09-entrega-pdf.md` pasa a
  `'es'`, el mismo `LOCALE_ID` que fija la Fase 02.

- **D10 — Nombre legal.** "Laboratorios Andina" (10 menciones en el track BE) pasa a **Andina
  Laboratories Inc.**, y el pie del PDF de `be08` (`Laboratorios Andina S.A.S.`) a
  `Andina Laboratories Inc. · Laboratoires Andina`. El paquete Java `com.andina.labcore` **se queda**:
  la marca no cambió.

---

## 2. 🧱 Reglas de orden

1. **Las decisiones D1–D10 están cerradas.** Una tanda que necesite cambiar alguna para y lo consulta
   con el autor; no la reinterpreta. Ninguna tanda de escritura empieza con P2 y P3 abiertas.
2. **Cada tanda deja el curso coherente hasta donde llega.** Si una tanda cambia una fecha o un
   identificador, en la misma sesión cambia todos los lugares que lo repiten (datos, forenses,
   cuaderno, preparaciones). Lo que no se puede cerrar se anota en §7.
3. **La aritmética de tiempo se comprueba ejecutando, no a mano.** Cada fecha movida, cada día de la
   semana y cada conversión a UTC se verifica con Node en contenedor (`TZ=America/Toronto`) y la
   salida queda en `zz-code/`. Lo mismo para el incidente 22.
4. **El README se toca solo en T5.** Lo que una tanda querría decir en él se anota en §7.
5. **Todo en el hilo principal, en secuencia y sin agentes.** Se para al cerrar cada tanda.
6. **Git lo hace el autor.** Nada de `git mv` ni `git rm`; borrados con `rm`, archivo por archivo.
7. **Pruebas en contenedor**, con `--label curso=angular8`, puertos altos ligados a `127.0.0.1`, y
   borrado de lo creado al cerrar. Nada de `prune`. Nada se instala en el host.
8. **Todo el código de las sesiones va a `zz-code/`** (`python3 zz-code/nuevo.py
   angular-8-legacy-for-backend-devs`), con su `README.md` de corrida y medición. Ningún documento del
   curso cita `zz-code/`. Cada directorio se anota en §9 con su estado.
9. **Todo bloque de código que la edición toca se ejecuta antes de publicarse**, aunque el cambio sea
   una fecha, un literal o un comentario. Las pruebas no reescriben el código: un script extrae del
   markdown los bloques tal como quedan y los corre en contenedor. El curso no tiene `src/`, así que se
   prueban las funciones y los datos, no la aplicación entera:
   - **frontend:** Node 14.21.3 (el `.nvmrc` de `a03`) con `@angular/common@8` para `formatDate`,
     `DatePipe` y `currency`, y Jasmine en Node para los specs de la Fase 12;
   - **track BE:** Java 8 y `mongo:4.0`, con la receta de `bea-02`.

   Lo que la edición promete en la prosa (una salida en un comentario, un "a partir de las 19:00") se
   compara contra la salida real. Lo que no se pueda correr se marca como no verificado en §7; si una
   prueba exige montar la aplicación (Karma, `ng build`), se para y se consulta.

---

## 3. 📊 Estado

- ✅ **T0 — Historia v2.** `00-historia-del-sistema.md` reescrita (2026-10-06). La fundadora
  colombiana se llama Liliana Ospina porque "Marcela Ríos" ya es `analista1` y la paciente 1 del mock.
- ✅ **P1 — Decisiones D6–D10** aprobadas por el autor (2026-10-06).
- ⬜ **P2 — Verificación de hechos** (§6).
- ⬜ **P3 — `prompts/`** al escenario nuevo.
- ⬜ **T1 — Zona horaria y fechas** del camino base.
- ⬜ **T2 — Paciente, moneda y locale** del camino base.
- ⬜ **T3 — Track BE.**
- ⬜ **T4 — Incidente 22.**
- ⬜ **T5 — README y cierre.**

---

## 4. 🔎 Inventario del impacto

Medido con `grep` el 2026-10-06 sobre los `.md` del curso, sin contar la historia.

- **`Bogot`/`America/Bogota`** — 39 líneas en 15 archivos: `bea-08` (12), `cuaderno-incidentes` (6,
  en los incidentes 07 y 19), `08-resultados-rangos` (4), `02-i18n`, `05-pacientes`, `be04`,
  `forense-fase-08`, `forense-fase-13` (2 cada uno), `04-mock-api-caos`, `09-entrega-pdf`,
  `13-build-despliegue`, `a07-i18n` (1 cada uno) y en `prompts/` (`propuesta-fases-backend`,
  `prompts-backend-apendice`, `preparaciones-de-incidentes`).
- **"Colombia no tiene horario de verano"** — el argumento que el giro invierte: `02-i18n.md` (~777),
  `a07-i18n.md` (~343), `bea-08` §8 entera (y su entrada en el índice), `be04` (~90) y
  `prompts-backend-apendice` (~398).
- **Marcas de tiempo con desfase** — 60 en `04-mock-api-caos`, `08-resultados-rangos`,
  `forense-fase-07`, `forense-fase-08`, `forense-fase-11`, `be04`, `bea-08`, `cuaderno-incidentes` y
  `preparaciones-de-incidentes`. Por mes: enero 7 · mayo 21 · junio 6 · agosto 2 · septiembre 24.
- **Identificador del paciente** (`CC-`, `TI-`, `CE-`) — 32 apariciones en 14 archivos: `12-testing`
  (7), `05-pacientes` (4, con la regex), `be02` (4), `04-mock-api-caos` (3), `forense-fase-05`,
  `forense-fase-12`, `cuaderno-incidentes`, `bea-05` (2 cada uno), `forense-fase-02`, `bea-04`,
  `bea-06` (con la regex), `bea-12`, `be03`, `be00` (1 cada uno).
- **"Laboratorios Andina"** — 10, todas en el track BE (`bea-10` 4, `be07` 3, `bea-09` 2, `be08` 1),
  más el `S.A.S.` del pie del PDF en `be08` (~330).
- **Moneda y locale** — `a07-i18n.md` (~321, `COP`) y `09-entrega-pdf.md` (~159, `es-CO`).
- **"El equipo contratado"** — `README`, `be00`, `be01`, la guía y `prompts-backend-fase`. No
  contradice la historia (sigue siendo un equipo contratado), pero conviene revisar que no diga nada
  que choque con "la consultora y el equipo de San José".
- **Sin impacto:** los nombres de pacientes y usuarios (`Marcela Ríos`, `Julián Prada`,
  `Deisy Cárdenas`) son creíbles en la comunidad latina de Ottawa; el paquete `com.andina.labcore`;
  los incidentes que no tocan tiempo ni identificadores.
- **`zz-code/`** — `angular-8-legacy-for-backend-devs-20261006-8291` tiene `Bogota` y `-05:00` en
  `01-forense` y `07-revision`. Son corridas históricas: no se editan. Las corridas nuevas van a un
  directorio nuevo.

---

## 5. 🧩 Las tandas

### P1 — Decisiones ✅

Cerrada el 2026-10-06: D6 `America/Toronto`, D7 opción A (fechas a invierno), D8 `HC/PP/LB`,
D9 `CAD` con `'1.2-2'` y `'es'`, D10 Andina Laboratories Inc. Si una tanda descubre que alguna no
se sostiene, se para y se consulta (regla 1).

### P2 — Verificación de hechos

Los puntos de §6, con fuente anotada en §7. Si un hecho falla, se corrige la historia v2 antes de
cualquier otra tanda.

### P3 — `prompts/`

- `guia-de-estilo-y-convenciones.md`: §11 y §12 (la ficción y la coherencia) mencionan el escenario
  solo de pasada; revisar, y agregar en §12 la tríada nueva de invariantes: **zona
  `America/Toronto`, datos en horario de invierno, identificadores `HC/PP/LB`**.
- `alcance-del-proyecto.md` y `propuesta-fases-y-alcance.md`: buscar menciones de Colombia o del
  dominio viejo.
- `propuesta-fases-backend.md` (~717) y `prompts-backend-apendice.md` (~391, ~398): `America/Bogota`
  y el argumento del horario de verano.
- `preparaciones-de-incidentes.md`: las fechas del 07 (D7) y el `docker run` del 19 (D6). La
  preparación del 22 se escribe en T4.
- `formato-cuaderno-incidentes.md` §11: el 22 pasa de candidato a reservado para el cambio de hora.
  Los dos candidatos anteriores (`setTextColor` y el `undefined` del slice lazy) quedan como
  candidatos al 23.

### T1 — Zona horaria y fechas (camino base)

En este orden, porque cada uno hereda las fechas del anterior:

1. **Script de fechas** en `zz-code/`: la tabla de equivalencias vieja → nueva (D7), con día de la
   semana, desfase real en `America/Toronto` y la hora UTC de cada una. Es la fuente de verdad de
   toda la tanda.
2. `02-i18n.md` — `timeZone: 'America/Toronto'` y la nota de ~777, que pasa a decir lo contrario: un
   desfase fijo **no** es seguro en Ottawa; el proyecto usa el identificador IANA por eso.
3. `a07-i18n.md` — §~337–343, con la misma inversión.
4. `04-mock-api-caos.md` — `db.json` con las fechas nuevas; la nota de ~129 ("las fechas llevan
   offset explícito…") explica que el `-05:00` es el de invierno y que la Era 1 lo usaba de constante.
5. `05-pacientes.md` — ~1104 y ~1293 (la medianoche local en UTC).
6. `08-resultados-rangos.md` — `effectiveFrom`, los cuatro `America/Bogotá` y los ejemplos.
7. `09-entrega-pdf.md` — ~151 (la zona; el locale va en T2).
8. `13-build-despliegue.md` — el valor por defecto de `APP_TIME_ZONE`.
9. Forenses `07`, `08`, `11` y `13`.
10. `cuaderno-incidentes.md` — incidente 07 (preparación, investigación y solución) e incidente 19
    (`APP_TIME_ZONE` en los `docker run` y el JSON).

**Pruebas** (regla 9), en contenedor y con el reloj de la máquina en `TZ=UTC` y en otra zona
(`Asia/Tokyo`), para que ninguna salida dependa del host:

- **`DatePipe` con un identificador IANA.** Con `formatDate` de `@angular/common@8`: ¿`'America/Toronto'`
  formatea en la zona de Ottawa o vuelve en silencio a la del reloj? Las notas de `02-i18n` (~775) y
  `a07` §6 dicen que funciona "si el navegador soporta la API de zonas horarias"; si la prueba muestra
  que Angular 8 solo acepta desfases y abreviaturas, el texto está mal desde antes del giro, y con una
  zona con horario de verano el `'-0500'` tampoco sirve. **Se para y se consulta**: cambia D6 o la
  forma de aplicarla.
- **El PDF de la Fase 9** (~159): `toLocaleString` con `timeZone: 'America/Toronto'` y una fecha cerca
  de medianoche, en invierno y en verano.
- **`db.json`** de la Fase 04: es JSON válido, lo carga el `json-server` de la fase y toda marca de
  tiempo está en la tabla del script.
- **El selector de rangos de la Fase 08**, extraído: con `effectiveFrom` `2022-01-01`, el viernes
  `2021-12-31` por la noche hora de Ottawa elige la v1 en el cliente y la v2 en UTC. Es el incidente 07,
  visto fallar antes del hotfix y pasar después.
- **La Fase 05** (~1104, ~1293): la medianoche local en UTC, contra el script.
- **La Fase 13:** el script de arranque con `APP_TIME_ZONE` sin definir y definido produce el
  `config.json` esperado.
- **El incidente 19**: los `docker run` del cuaderno, tal como quedan escritos.

**Cierre:** `grep -rn "Bogot" .` devuelve cero fuera del track BE; toda fecha del camino base cae en
la tabla del script; las pruebas de arriba corren en contenedor con su salida en `zz-code/`, y el
incidente 07 se reproduce corriendo su preparación.

### T2 — Paciente, moneda y locale (camino base)

1. `05-pacientes.md` — la regex y su explicación, los ejemplos y los errores comunes.
2. `04-mock-api-caos.md` — los `documentId` del `db.json`.
3. `12-testing-coverage.md` — los siete casos; **los tests se corren** en contenedor y siguen en
   verde.
4. Forenses `02`, `05` y `12`, y las dos apariciones del cuaderno.
5. `a07-i18n.md` (`CAD`, `'1.2-2'`) y `09-entrega-pdf.md` (`'es'`).

**Pruebas** (regla 9):

- La regex de la Fase 05 contra `HC-`, `PP-` y `LB-` válidos y contra los casos que deben fallar
  (prefijo viejo `CC-`, sin guion, minúsculas, largo fuera de rango).
- Los siete casos de la Fase 12 en verde con Jasmine en Node sobre los bloques extraídos.
- `currency:'CAD':'symbol-narrow':'1.2-2'` y `number` con los locales `es`, `en` y `fr` registrados:
  la salida real coincide con la que muestran los comentarios de `a07` (~321); `toLocaleString('es')`
  de la Fase 09, con Node 14 y su ICU completo.

**Cierre:** `grep -rnE "(CC|TI|CE)-[0-9]" .` devuelve cero fuera del track BE, y las pruebas de
arriba corren en contenedor.

### T3 — Track BE

1. `bea-08-tiempo-zonas-y-fechas-en-mongo.md` — la más pesada: `America/Toronto` en el código Java y
   en las agregaciones, y **§8 reescrita**: de "Colombia no, y aun así" a "Ottawa sí, y por eso", con
   el puente al incidente 22. Revisar el índice y los ejercicios (~322).
2. `be04` — ~83, ~90 y ~250, con las fechas de T1.
3. `be00`, `be02`, `be03`, `bea-04`, `bea-05`, `bea-06` (la regex de JSON Schema) y `bea-12` (el
   generador de datos): identificadores D8.
4. `be07`, `be08`, `bea-09` y `bea-10`: el nombre legal D10. En `bea-09` y `cuaderno-incidentes-be`,
   revisar "sede central" contra la red de la historia v2.
5. `bea-01` y `be01`: revisar que lo que cuentan del "equipo contratado" no choque con la consultora.

**Pruebas** (regla 9):

- `bea-08`: los fragmentos Java con `ZoneId.of("America/Toronto")` compilan y corren en Java 8, en
  invierno y en verano; las agregaciones con `timezone: 'America/Toronto'` corren en `mongo:4.0` y dan
  lo que dice el texto; la §8 nueva se apoya en esas salidas, no en cuentas a mano.
- `bea-06`: el `$jsonSchema` con el `pattern` nuevo acepta `HC-`, `PP-` y `LB-` y rechaza `CC-` en
  `mongo:4.0`.
- `bea-12`: el generador de datos produce identificadores que pasan la regex de la Fase 05 y el
  `$jsonSchema` de `bea-06`.
- `be04`: las fechas, contra la tabla de T1.
- `be08`: si el pie del PDF sale de código, el bloque se corre y el PDF muestra el nombre nuevo.

**Cierre:** `grep -rn "Bogot\|Colombia\|Laboratorios Andina\|S\.A\.S" .` devuelve cero en todo el
curso, salvo esta propia nota, y las pruebas de arriba corren en contenedor.

### T4 — Incidente 22: el cambio de hora

Escrito con `prompts/formato-cuaderno-incidentes.md` y con la preparación en
`preparaciones-de-incidentes.md`. Punto de partida, a discutir antes de escribir:

- **Síntoma, en boca de Liliana:** *"Los resultados del domingo en la mañana dicen que se validaron
  antes de que llegara la muestra."* Ocurre dos domingos al año.
- **Mecánica:** una custodia o una validación construida con el `-05:00` constante de la Era 1
  durante el horario de verano queda una hora corrida; el orden entre "recibida" y "validada" se
  invierte si están a menos de una hora, y el audit log de la Fase 11 lo muestra.
- **Fase de anclaje:** la 7 (custodia) o la 8 (comparación de fechas); semana y dificultad a definir
  contra la escala del cuaderno (hoy 2 🟢 · 8 🟡 · 9 🟠 · 2 🔴 y semanas 7 / 7 / 4 / 3).
- **Preparación:** un `db.incidente-22.json` con marcas alrededor del 8 de marzo de 2020 o del 1 de
  noviembre de 2020, verificadas con el script de T1.
- **Final:** probablemente **no termina en fix**, como el 17: el arreglo de fondo es del backend sin
  dueño. Lo que se entrega es el diagnóstico y la contención.
- **Puentes:** a `bea-08` §8 y a la nota de `02-i18n`.

**Pruebas** (regla 9): las marcas del `db.incidente-22.json` salen del script de T1; con el código
extraído de la fase de anclaje y de la Fase 11 (audit log), el orden "recibida" → "validada" se ve
invertido con el `-05:00` constante y correcto con `America/Toronto`. Si el incidente termina en
contención y no en fix, la prueba muestra el síntoma y que la contención lo hace visible.

**Cierre:** el índice del cuaderno, el README, la escala y el reparto por semanas coinciden fila por
fila; la preparación se corre en contenedor y reproduce el síntoma.

### T5 — README y cierre

1. `README.md`: el párrafo de LabCore (si nombra la empresa o el país), la fila del incidente 22, las
   cuentas del cuaderno y las horas si cambian.
2. Validadores del curso: enlaces y anclas, referencias `§N`, paridad de vallas y reciprocidad
   fase ↔ apéndice ↔ incidente.
3. **Corrida final:** todas las pruebas de T1–T4 se repiten de cero, con contenedores nuevos y
   siguiendo solo los README de sus directorios de `zz-code/`, contra el markdown como quedó al final.
   Las salidas coinciden con las guardadas; si no, la tanda que las produjo se reabre. §9 al día.
4. Barrido final de §8.
5. Memoria del proyecto al día; este plan, a borrar con permiso del autor.

---

## 6. 🔬 Hechos por verificar

La historia v2 los usa; la mayoría está escrita para que un detalle fino no la rompa, pero ninguno
se da por bueno sin fuente.

- La licencia de laboratorio y de centro de toma de muestras en Ontario, y si exige un **director
  médico**.
- Si una red con sede en Ontario necesita un permiso aparte para tomar muestras en Quebec.
- La **Ley 96** (2022): qué exige sobre el idioma de trabajo y del software, y el umbral de empleados
  de la francización.
- La **Ley 25** de Quebec: qué exige antes de comunicar datos personales fuera de la provincia y desde
  cuándo rige esa parte.
- Las reglas sobre médicos con participación en un laboratorio al que derivan pacientes
  (autorreferencia), que condicionan el papel de Tomás Lagos.
- La certificación de tecnólogos formados en el extranjero (CSMLS) y el registro en Ontario (CMLTO).
- La armonización de intervalos de referencia en Canadá hacia 2021.
- El programa federal de trabajadores calificados en 2008 y la llegada de refugiados chilenos después
  de 1973.
- Las fechas del cambio de hora en `America/Toronto` en 2019–2021, **por ejecución** (script de T1).
- Si el `DatePipe` de Angular 8 acepta identificadores IANA, **por ejecución** (primera prueba de T1).

---

## 7. 📓 Bitácora

- **2026-10-06** — Historia v2 escrita (T0). Decisiones D1–D5 del autor. La fundadora pasa de
  "Marcela Ríos" a "Liliana Ospina" por el choque con `analista1` y la paciente 1. Inventario de §4
  medido. Hallazgo previo al giro: el `effectiveFrom` de la v2 de rangos (`2019-06-01`) ya contradecía
  la cronología de la historia (rangos versionados en 2021); D7 lo corrige de paso.
- **2026-10-06** — P1 cerrada: el autor aprueba D6–D10 tal como se proponen (D7, opción A).
  Comprobado con Python (`zoneinfo`): el 31/12/2021 y el 31/01/2020 son viernes, y el cambio de hora
  en `America/Toronto` cae el 10/03/2019, 03/11/2019, 08/03/2020, 01/11/2020, 14/03/2021 y
  07/11/2021. El plan queda listo para la sesión de escritura; **la siguiente es P2**.
- **2026-10-07** — El plan pasa a llamarse `_desechable-plan-de-edicion.md` (es edición de un curso
  cerrado). El autor deja *Andina Laboratories* como está (D10 sin cambios). Las pruebas de código
  entran a las tandas: regla 9 (todo bloque tocado corre en contenedor), pruebas por tanda en T1–T4,
  corrida final en T5 y §9 nueva. Hallazgo al revisar: las notas de `02-i18n` y `a07` §6 afirman que
  el `DatePipe` de Angular 8 acepta `'America/Bogota'`; hasta donde se sabe solo acepta desfases y
  abreviaturas. Queda como primera prueba de T1 y como hecho por verificar en §6.

---

## 8. ✅ Checklist final

- [ ] `grep -rn "Bogot\|Colombia\|colombian" .` → cero fuera de esta nota.
- [ ] `grep -rnE "(CC|TI|CE)-[0-9]" .` → cero.
- [ ] `grep -rn "Laboratorios Andina\|S\.A\.S\|es-CO\|'COP'" .` → cero.
- [ ] Toda marca de tiempo del curso está en la tabla del script de T1, con su desfase real.
- [ ] Ninguna frase dice que la zona de la aplicación no tiene horario de verano.
- [ ] El incidente 22 existe, está en el índice y en el README, y su preparación reproduce el síntoma.
- [ ] La historia v2 cita el 22 y dice "veintidós tickets", y las dos cosas son verdad.
- [ ] Los tests de la Fase 12 y los incidentes 07, 19 y 22 corrieron en contenedor, con salida
      fechada en `zz-code/`.
- [ ] Todo bloque de código tocado en T1–T4 corrió en contenedor (regla 9), incluidos el `DatePipe`
      con IANA, el `$jsonSchema` de `bea-06` y los fragmentos Java de `bea-08`.
- [ ] La corrida final de T5 se hizo de cero desde los README de `zz-code/`, con las mismas salidas.
- [ ] §9 al día; contenedores y volúmenes de la edición borrados, nada fuera de lo creado.
- [ ] Validadores del curso en cero.
- [ ] Ningún documento del curso cita este plan ni `zz-code/`.

---

## 9. 🧪 Directorios de `zz-code/`

Cada tanda que corra código crea su directorio con `python3 zz-code/nuevo.py
angular-8-legacy-for-backend-devs` (o reutiliza el de la tanda anterior, si sigue *vigente*) y lo
anota aquí con su estado: *vigente*, *extraído* o *archivado* (`zz-code/README.md`, regla 3).

| Directorio | Tanda | Qué tiene | Estado |
|---|---|---|---|
| `angular-8-legacy-for-backend-devs-20261006-8291` | rescate | Pruebas rescatadas de las sesiones anteriores (sondas de LabCore, forenses, revisiones); tiene `Bogota` y `-05:00`, y no se edita | archivado |
| *(por crear)* | T1 | Extractor de bloques, script de fechas, `DatePipe` con IANA, selector de rangos, incidentes 07 y 19 | — |
| *(por crear o el de T1)* | T2 | Regex de la Fase 05, specs de la Fase 12, moneda y locale | — |
| *(por crear o el de T1)* | T3 | Java 8 y `mongo:4.0`: `bea-08`, `bea-06`, `bea-12` | — |
| *(por crear o el de T1)* | T4 | Incidente 22: preparación y orden del audit log | — |
