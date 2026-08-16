# 📓 Cuaderno de incidentes — 🔥 Track BE

> Tutorial Angular 8 — Laboratorio clínico · Track BE opcional · Documento vivo · **8 horas** repartidas en el mes del track
> Se trabaja solo. El changelog es `git log -- cuaderno-incidentes-be.md`.

Este es el cuaderno del **track de backend**, y es un archivo aparte del
[`cuaderno-incidentes.md`](cuaderno-incidentes.md) del track base. Doce
incidentes, con IDs `be-01` … `be-12` en un rango **independiente**: los dos
cuadernos no se cruzan ni se renumeran el uno al otro.

**La separación es deliberada.** Quien haga solo el track base no tiene por qué
recibir incidentes de MongoDB mezclados con los suyos. Y quien haga los dos sabe
en todo momento **de qué lado del cable es el ticket que está leyendo**, que es
justamente el músculo que este track entrena.

El trato es el mismo que en el cuaderno base: cada incidente trae su solución
adentro, colapsada, y abrirla antes de tiempo solo te perjudica a ti.

> ⚠️ **Prerrequisito.** Estos doce incidentes suponen que ya cerraste la Fase 11
> del track base y las fases `be00`–`be08` que los producen. No hay incidentes
> 🟢 ni 🟡 aquí, y el §📋 explica por qué.

---

## 🧭 Cómo se trabaja un incidente

El método no cambia y **no se reexplica**: está en
[`forense-master.md`](forense-master.md) §1 —las cuatro preguntas— y su índice de
síntomas transversal en §3. Lees el ticket, reproduces, investigas, escribes tu
diagnóstico en «📝 Tu investigación», y **recién entonces** abres la solución.

Lo que sí cambia es **la cuarta pregunta del método**, la propia del track
forense: *¿lo escribió el sistema o llegó roto en el dato?*. Del lado del
servidor esa pregunta admite una tercera respuesta que en el frontend casi no
aparece, y la vas a necesitar seis veces en este cuaderno: **lo escribió una
persona, con una operación válida, sobre un dato correcto**. Un `$set` a mano, un
script de importación, un `collMod` un viernes. No hay código culpable y no hay
dato malformado: hay una acción humana que nadie registró.

> 🕵️ **Y el corolario práctico:** cuando las tres primeras preguntas no dan nada,
> la pregunta que falta casi nunca es técnica. Es *¿quién tocó algo, cuándo, y
> por qué no quedó constancia?*.

Las pistas están escalonadas igual que en el cuaderno base: la 💡 primera dice
dónde mirar, la segunda qué mirar, la tercera casi lo cuenta. Ábrelas en orden y
solo cuando lleves veinte minutos sin una idea nueva.

### Cómo llega el sistema roto a tu máquina

Aquí **no hay `db.json` alterno**: el dato vive en Mongo. Hay cuatro formas, y se
usa siempre la más barata que sirva.

**1. Un flag del inyector de caos.** El mismo de la Fase 4, reimplementado en
Java en `be01` §5.7 con paridad exacta. Sigue siendo la preferida: no toca tu
código, no toca tus datos, y se apaga al reiniciar.

```bash
CHAOS=fail=500@100 docker compose up -d api
# o, para una sola petición, desde la consola del navegador:
fetch('http://localhost:3000/patients', { headers: { 'X-Chaos': 'malformed' } });
```

**2. Una colección sembrada a propósito.** Cuando el bug está en el dato. Son
guiones `seed-incidente-be-NN.js` que viven en `dump/` y dejan la base en el
estado a diagnosticar. Se corren y se revierten volviendo a sembrar desde tu
`db.json` (`be03` §5.5), que es determinista.

```bash
node dump/seed-incidente-be-04.js
# y para volver:
docker compose exec -T db mongosh labcore --eval 'db.dropDatabase()' && docker compose restart api
```

**3. Una línea del `.env`.** Cuando el cambio no está en el código —que es el
caso de `be-11` y de nada más—.

```bash
sed -i '' 's/^MONGO_TAG=.*/MONGO_TAG=7.0/' .env && docker compose up -d db
```

**4. Una rama de git.** Solo cuando haya que romper código. Se llaman
`incidente-be/NN`, salen del tag de la fase que produce el incidente, y traen el
cambio mínimo que produce el síntoma.

```bash
git checkout -b incidente-be/05 be-fase-03-la-costura-y-el-reemplazo
```

> ⚠️ **Ojo con el nombre del tag:** en el track BE los tags viven en el namespace
> `be-fase-*` y llevan **el slug completo del archivo**
> (`be-fase-03-la-costura-y-el-reemplazo`, no `be-fase-03`). Abreviarlo produce un
> comando que no corre. Está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥.

> 🧭 **La regla, y sirve más allá de este cuaderno:** cuando alguien te pida
> reproducir un bug, la primera pregunta es *"¿esto se reproduce con un flag, con
> un dato, con una línea de configuración, o hace falta otro código?"*. En el
> track base eran tres opciones; aquí son cuatro, y **la tercera es la que casi
> nadie considera** — que es exactamente de lo que va `be-11`.

### Convención de commits

Igual que en el cuaderno base, con el ID del track:

```
incidente(be-08): abre — la orden 4021 contradice a sus muestras
incidente(be-08): repro — se cae el proceso entre las dos escrituras
incidente(be-08): hipótesis descartada — no es el reducer, la orden nunca se tocó
incidente(be-08): causa — tres documentos, un hecho, cero transacción
incidente(be-08): fix — corrección compensatoria en el libro
incidente(be-08): cierre — detector y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`,
`causa`, `fix`, `cierre`. **Commitea también los callejones sin salida.**

Y el par de tags de
[`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md):
`inc/be-08/orden-contradice-roto` con el síntoma reproducido, y
`inc/be-08/orden-contradice-fix` con la causa raíz y el fix. El `git diff` entre
los dos **es** el punto 5 del post-mortem.

> ⚠️ **Con una excepción, y es contenido: `be-11` no tiene par `-roto` / `-fix`.**
> Su `git diff` está vacío a propósito. No lo busques, y no lo fuerces.

### Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y test de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 📋 Índice

Lo actualizas en el mismo commit que abre o cierra un incidente.

| ID | Fase | Título | Categoría | Dif. | Tiempo | Estado |
|---|---|---|---|---|---|---|
| be-01 | be01 | El servidor dice 500 y la pantalla no dice nada | Contrato | 🟠 | 30 min | ⬜ |
| be-02 | be02 | La orden sin paciente | Integridad referencial | 🟠 | 30 min | ⬜ |
| be-03 | be02 | Los pacientes sin nombre que nadie pudo reproducir | Deriva de esquema | 🔴 | 50 min | ⬜ |
| be-04 | be03 | Dos pacientes con el mismo número | Concurrencia | 🔴 | 55 min | ⬜ |
| be-05 | be03 | La pantalla que carga y no navega | Contrato | 🟠 | 25 min | ⬜ |
| be-06 | be04 | La muestra que cambió de estado sin que nadie lo apuntara | Trazabilidad | 🟠 | 35 min | ⬜ |
| be-07 | be04 | El informe firmado a las 14:47 por alguien que salió a las 14:00 | Tiempo | 🔴 | 50 min | ⬜ |
| be-08 | be05 | La orden que contradice a sus muestras | Atomicidad | 🔴 | 55 min | ⬜ |
| be-09 | be05 | Arreglamos las veintitrés y ahora nadie sabe qué pasó | Evidencia | 🔴 | 45 min | ⬜ |
| be-10 | be06 | El informe dice normal y la pantalla dice alto | Normativo | 🔴 | 55 min | ⬜ |
| be-11 ⭐ | be07 | No desplegamos nada y dejó de funcionar | Configuración | 🔴 | 50 min | ⬜ |
| be-12 | be08 | Desde el viernes no podemos guardar algunos pacientes | Procedimiento | 🔴 | 40 min | ⬜ |

**El reparto por semanas**, sobre el mes del track:

- **Semana 1** — fases `be01`–`be03` · **5 incidentes** (be-01 … be-05): el error que llega en HTML, la orden huérfana, los pacientes sin nombre, los identificadores duplicados y la pantalla que no navega.
- **Semana 2** — fases `be04`–`be05` · **4 incidentes** (be-06 … be-09): el asiento que falta, el reloj imposible, la escritura a medias y la corrección que borró la evidencia.
- **Semana 3** — fases `be06`–`be08` · **3 incidentes** (be-10, be-11, be-12): la historia sobrescrita, el cambio sin commit y la validación endurecida sin medir.

### ⚠️ La escala: 6 🟠 · 6 🔴, y ni un 🟢

No es un descuido del reparto: es una consecuencia del prerrequisito, y se
escribe en vez de disimularse —el mismo precedente que sentó el cuaderno base
cuando su reparto real no coincidió con el proyectado—.

Para llegar aquí hay que haber cerrado once fases del track base, sus veintiún
incidentes, y nueve fases más de backend. **No queda ningún incidente de
principiante que dar**: los errores de arranque, de configuración de entorno y de
lectura de una petición HTTP ya se cobraron todos en el otro cuaderno. Lo que
produce este track son fallos de contrato, de concurrencia, de historia perdida y
de procedimiento, y ninguno de esos es 🟢 por definición.

Lo que sí se conserva es **la progresión**: la semana 1 empieza con los dos 🟠
más directos y los cuatro 🔴 más duros —be-09, be-10, be-11 y be-12— están todos
en las dos últimas.

> 📝 **Y una ausencia que también es decisión: `be00` no reserva ningún ID.** Un
> incidente necesita un sistema que se pueda romper, y en esa fase todavía no hay
> servidor propio: se audita el que ya existe. Está declarado en su §📌.

---

# 🧪 Incidentes

---

## Incidente be-01 — El servidor dice 500 y la pantalla no dice nada

> **Fase:** be01 · **Categoría:** Contrato · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30 min · **Ruta forense:** `be01` §6

### 🎫 El ticket

> *"Desde ayer, cuando algo falla, no sale el mensaje de error: sale la pantalla
> vacía. Antes por lo menos decía 'ocurrió un error, reintenta'. Pasa con
> cualquier pantalla, no con una sola."*

**Reportado por:** analista de la sede central
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar **en qué capa se pierde el mensaje**, y aplicar el hotfix
mínimo. Y contestar una pregunta que el ticket no hace: por qué el `catchError`
del frontend, que existe y está bien escrito, no sirvió de nada.

### 🔧 Preparación

Rama de git: hay que romper código, porque el fallo es una excepción lanzada en
un sitio concreto.

```bash
git checkout -b incidente-be/01 be-fase-01-java-spring-y-la-forma-del-monolito
```

La rama trae una línea añadida dentro de `ChaosFilter` que lanza una excepción
cuando llega una cabecera concreta.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Esto se ve en la pestaña Network antes que en ningún log, y no en el código de
estado: en el **`Content-Type`** de la respuesta. El `500` es correcto; lo que
llega adentro, no.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Tienes un `@ControllerAdvice` y está activo. Comprueba si se está ejecutando:
ponle un `log.error` en la primera línea y provoca el fallo otra vez. No se
ejecuta. La pregunta es por qué.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué corre **antes** de que Spring MVC entre en escena, y qué pasa con una
excepción que se lanza ahí?

</details>

---

### 📝 Tu investigación

**Reproducción**
{{Pasos numerados y exactos: qué petición, con qué cabecera, contra qué endpoint.}}

**Evidencia observable**
{{Lo que viste: el `Content-Type`, el cuerpo de la respuesta, el log del servidor,
lo que muestra la pantalla. En ese orden de desconfianza.}}

```
{{cuerpo de la respuesta, entero}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea, o la decisión de diseño culpable.}}

**Tu fix**
{{El parche mínimo, y aparte la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

La excepción se lanza dentro de `ChaosFilter.doFilter()`, en la cadena de
filtros. **Un `@ControllerAdvice` solo captura lo que pasa por Spring MVC**, y
los filtros corren antes: la excepción sale por el contenedor de servlets, que
responde con su propia página de error en `text/html`.

El `catchError` del effect del frontend **sí se ejecuta** —el status es `500`— y
hace exactamente lo que sabe hacer: buscar `message` en el cuerpo. Como el cuerpo
es HTML, no encuentra nada, y la pantalla se queda sin texto.

**Parche mínimo**

```java
// En ChaosFilter.doFilter(), envolviendo lo que pueda lanzar.
// Un filtro no tiene red de seguridad detrás: la suya la escribe él.
try {
    config = ChaosParser.resolve(request);
} catch (RuntimeException e) {
    // Si el caos no se puede interpretar, el caos se apaga. NUNCA se rompe la
    // petición por culpa de una herramienta de diagnóstico apagada por defecto.
    log.warn("configuración de caos ilegible, se ignora", e);
    config = new ChaosConfig();
}
```

**La refactorización correcta** (que en este track 💸 no se paga)

Un filtro de manejo de errores registrado con orden `0` —antes que todos— que
capture cualquier excepción de la cadena y escriba el JSON del contrato. Es lo
correcto y son treinta líneas, pero introduce un segundo sitio donde se formatea
un error, y dos formateadores de error acaban divergiendo. En un sistema con dos
años de vida y un solo filtro que puede lanzar, se arregla el filtro.

**Prueba de regresión**

No es unitaria: es una afirmación de contrato, y va en `smoke.sh` porque lo que
hay que proteger es el **`Content-Type` de un error**, no una línea de código.

```bash
expect_body "un error del servidor llega como JSON con message" \
  '"message"' GET "/patients?__boom=1"
# Y la que de verdad lo blinda, porque el cuerpo podría llevar "message"
# dentro de un HTML:
actual=$(curl -s -o /dev/null -w '%{content_type}' "$BASE/patients?__boom=1")
case "$actual" in application/json*) echo "  ok   error en JSON";;
                 *) echo "  FALLA error con content-type $actual"; FAIL=$((FAIL+1));; esac
```

**Prevención**

La afirmación de `Content-Type` en `smoke.sh` para la familia de errores, no solo
para las respuestas de éxito. Es el ejercicio 15 de `be01` y es de los que más
rendimiento dan por línea escrita.

**Por qué llegó a producción**

Porque `smoke.sh` afirmaba **códigos de estado** y formas de respuestas correctas,
y ninguna afirmación sobre la forma de un **error**. El contrato de `be00`
documentaba el cuerpo de error desde el primer día; lo que faltó fue la prueba
que lo vigilara. Nadie se equivocó: se probó lo que se pensó probar.

**Si tu causa fue distinta a esta**

Si concluiste que faltaba el `@ControllerAdvice`, el síntoma encaja: la respuesta
también sería HTML. Comprueba si la anotación está y si el bean se registró
—`--debug` y el informe de auto-configuración—. Que tu fix funcione añadiendo un
manejador no significa que ese fuera el problema: significa que tapaste una
excepción que seguirá escapándose por la cadena de filtros la próxima vez.

</details>

---

## Incidente be-02 — La orden sin paciente

> **Fase:** be02 · **Categoría:** Integridad referencial · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30 min · **Ruta forense:** `be02` §5.5

### 🎫 El ticket

> *"En la lista de órdenes hay filas donde la columna del paciente sale vacía.
> No son siempre las mismas y no son muchas. Si abres la orden, todo lo demás
> está bien."*

**Reportado por:** coordinadora del laboratorio
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir, **contar cuántas son**, y decidir si es un bug del frontend o un
problema del dato. La respuesta a esa segunda pregunta cambia a quién le toca
arreglarlo, y es la mitad del ejercicio.

### 🔧 Preparación

Colección sembrada: el bug está en el dato, no en el código.

```bash
node dump/seed-incidente-be-02.js    # siembra órdenes con patientId inexistente
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El frontend hace su trabajo. Antes de abrir un `.ts`, abre el shell de Mongo y
pregúntale a los datos si el paciente de esa orden existe.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`$lookup` entre `orders` y `patients`, y después quédate con las que devolvieron
un arreglo vacío. Un `JOIN` que no encuentra nada aquí no es un error: es un
resultado.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Cruza esas órdenes con el campo `_source`. ¿Se concentran en algún sitio? Porque
si se concentran, nadie borró nada: **llegaron así**.

</details>

---

### 📝 Tu investigación

**Reproducción**
{{Qué orden concreta, qué `patientId`, y la consulta que lo confirma.}}

**Evidencia observable**
{{El número de huérfanas, y su reparto por `_source`.}}

```
{{salida de la agregación}}
```

**Hipótesis**
- ❌ Descartada: {{…}}.
- ✅ Confirmada: {{…}}.

**Tu causa raíz**
{{…}}

**Tu fix**
{{Y aquí la pregunta difícil: ¿hay fix?}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Treinta y siete órdenes apuntan a un `patientId` que no existe en `patients`.
**MongoDB no tiene claves foráneas**, así que nada impidió insertarlas. Treinta y
una de las treinta y siete llevan el rastro de la importación de 2020
(`_source: legacy-import` en el paciente que *debería* estar): llegaron rotas de
origen, no las rompió nadie después.

El selector cruzado del frontend devuelve `undefined` para esas órdenes y la
plantilla pinta una celda vacía sin quejarse — que es el comportamiento correcto
del frontend, no un bug.

**Parche mínimo**

**Ninguno en el código.** Es lo más importante de este incidente: el sistema está
haciendo lo que puede con un dato que llegó incompleto en 2020, y **un parche que
oculte la fila o que invente un nombre empeora el sistema**, porque hace
desaparecer la única señal de que hay órdenes sin paciente.

Lo que sí se hace es dejar constancia:

```javascript
// La agregación va a MEASUREMENTS.md con su número y su fecha, y el hallazgo
// se anota para be08. No se toca ni una orden.
db.orders.aggregate([
  { $lookup: { from: 'patients', localField: 'patientId',
               foreignField: 'legacyId', as: 'patient' } },
  { $match: { patient: { $size: 0 } } },
  { $count: 'orphanOrders' }
]);
```

**La refactorización correcta** (que en este track 💸 no se paga)

Comprobar la existencia del paciente al crear una orden, y un detector semanal
como el de `be05` §5.6 para lo que ya está roto. Lo primero cuesta una consulta
extra por escritura y no es atómico —alguien puede dar de baja al paciente en
medio—; lo segundo es media jornada. Con dos años de decomisión y treinta y siete
casos en seis años, **el detector entra y la comprobación no**: ver `bea-11` §5.

**Prueba de regresión**

No hay test que escribir contra el código, porque el código no está mal. Lo que
se escribe es la **medición**, y se corre periódicamente:

```javascript
// dump/verify-integrity.js — se corre cada semana y avisa si el número sube.
var orphanCount = db.orders.aggregate([...]).toArray()[0].orphanOrders;
if (orphanCount > 37) {
  print('ALERTA: las huérfanas subieron de 37 a ' + orphanCount);
  quit(1);
}
```

**Prevención**

Ese guion, corriendo. Y el número **37 escrito en `MEASUREMENTS.md` con su
fecha**: sin la línea base, "hay huérfanas" no es un dato accionable.

**Por qué llegó a producción**

Un script de importación de 2020 metió órdenes cuyos pacientes no llegaron.
Nadie lo comprobó porque **nada lo comprobaba**: el motor no impone integridad
referencial y el equipo venía de un mundo donde eso lo hacía la base. La
sustitución de una garantía automática por una convención tácita es el patrón, y
no fue una decisión: fue una consecuencia no advertida de otra decisión.

**Si tu causa fue distinta a esta**

Si concluiste que el selector del frontend está mal, el síntoma encaja
perfectamente y hay un caso real parecido —el del ejercicio 17 de la Fase 6 del
track base, donde el slice de órdenes no está cargado—. La forma de distinguirlos
es de un minuto: si el paciente **existe** en la base, es el selector; si no
existe, es el dato. Empezar por ahí ahorra media hora.

</details>

---

## Incidente be-03 — Los pacientes sin nombre que nadie pudo reproducir

> **Fase:** be02 · **Categoría:** Deriva de esquema · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50 min · **Ruta forense:** `be02` §5.2 y §5.3

### 🎫 El ticket

> *"Reapertura del ticket 4417 (tercera vez). Una auxiliar dice que hay pacientes
> que salen sin nombre en la lista. Lo revisamos con ella el martes y no pudimos
> reproducirlo; los pacientes que buscamos salieron todos bien. Cerrado como no
> reproducible las dos veces anteriores."*

**Reportado por:** soporte de primer nivel
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducirlo —esta vez sí—, explicar **por qué las dos investigaciones anteriores
fallaron**, y cuantificar el alcance. No hay fix que aplicar: hay un número que
entregar y una explicación que escribir.

### 🔧 Preparación

Colección sembrada, y es la del volcado sucio de `be02` que ya deberías tener
cargado.

```bash
# Si no lo tienes: bea-12 §3 y §6
node dump/generate-dump.js && ./verify-dump.sh
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No busques en el código. Pregúntale a la colección **qué campos tiene de verdad**,
sin suponerlo desde `Patient.java`.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`$objectToArray` sobre `$$ROOT`, `$unwind`, `$group`. Cuenta cuántos documentos
tienen `fullName` y compáralo con el total. La resta tiene nombre propio.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Los afectados ¿son recientes o antiguos? ¿Y con qué buscaba soporte cuando
intentó reproducirlo las dos veces anteriores?

</details>

---

### 📝 Tu investigación

**Reproducción**
{{El `documentId` concreto de un paciente afectado, y cómo lo encontraste.}}

**Evidencia observable**
{{El inventario de claves, con sus números.}}

```
{{salida de la agregación de inventario}}
```

**Hipótesis**
- ❌ Descartada: {{…}}.
- ✅ Confirmada: {{…}}.

**Tu causa raíz**
{{…}}

**Tu fix**
{{…}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Setecientos dieciocho documentos de `patients` no tienen el campo `fullName`:
tienen **`name`**, porque así se llamaba en el sistema de origen de la sede que
entró en 2020 y el script de importación no tradujo el campo. `Patient.java`
declara `fullName`; `spring-data-mongodb` **ignora en silencio** un campo que no
está en la clase y deja en `null` uno que no está en el documento. Ninguna
excepción, ningún log, una fila con la celda vacía.

**Y por qué no se reproducía:** los 718 son todos de la importación de 2020.
Quien investigó las dos veces anteriores buscó pacientes **recientes** —los que la
auxiliar tenía a mano, los que aparecen primero— y todos estaban bien.

> 🧠 **La regla que hay que llevarse:** *"no reproducible" casi siempre significa
> "no reproducible con los datos que yo miré"*, y en un sistema con deriva los
> datos que uno mira por defecto son los más nuevos, que son justamente los
> sanos.

**Parche mínimo**

Ninguno, y hay que resistirse. La tentación es un `@JsonAlias` o un getter que
caiga a `name` cuando `fullName` sea `null`:

```java
// NO se hace, y conviene entender por qué.
// Esto tapa el síntoma en la capa de presentación y hace desaparecer la
// evidencia de que hay 718 documentos con otra forma. Además, cambia el
// comportamiento observable de la API sin haberlo decidido: el frontend
// empezaría a mostrar nombres que hoy no muestra.
public String getFullName() { return fullName != null ? fullName : name; }
```

Lo que sí se hace es el **contador de deriva** de `be03` §5.8, que no cambia
ninguna respuesta y convierte el problema invisible en una línea de log.

**La refactorización correcta** (que en este track 💸 no se paga)

Normalizar los 718 documentos a la forma actual. Y la razón de que no se haga no
es el coste —es un `updateMany` de dos líneas— sino que **destruye información**:
después de correrlo, nadie puede demostrar que hubo una importación con otra
forma, ni distinguir esos pacientes de los demás. `be05` §4.4 y el ejercicio 28
de `be02` desarrollan la decisión completa.

**Prueba de regresión**

La agregación que detecta **formas nuevas**, corriendo cada semana:

```javascript
// dump/verify-shapes.js — falla si aparece una sexta forma.
var shapeCount = db.patients.aggregate([
  { $project: { pairs: { $objectToArray: '$$ROOT' } } },
  { $unwind: '$pairs' }, { $sort: { '_id': 1, 'pairs.k': 1 } },
  { $group: { _id: '$_id', keys: { $push: '$pairs.k' } } },
  { $group: { _id: '$keys', n: { $sum: 1 } } }
]).toArray().length;
if (shapeCount !== 5) { print('ALERTA: ' + shapeCount + ' formas, se esperaban 5'); quit(1); }
```

**Prevención**

Ese guion, más el `$jsonSchema` en modo `warn` de `be08` §5.2 — que **no** habría
impedido esto (los 718 ya estaban) pero sí impide el 719.

**Por qué llegó a producción**

Un script de importación que nadie del equipo escribió, que no está en el
repositorio, y que corrió una vez. El mapeo permisivo de Spring Data hizo el
resto: **el sistema no falló, y por eso nadie miró**. Y el proceso de soporte
cerró el ticket dos veces porque su definición de "reproducible" era "me pasa a
mí ahora", que en un sistema con seis años de datos es una definición demasiado
estrecha.

**Si tu causa fue distinta a esta**

Si concluiste que el problema es un `null` en el `seed.js`, el síntoma encaja.
La forma de descartarlo: el `seed.js` genera `fullName` siempre, así que un
paciente sin nombre **no puede** venir de ahí. Cuando el generador de tus datos
no puede producir el síntoma, el dato vino de otro sitio — y averiguar de cuál es
el ejercicio.

</details>

---

## Incidente be-04 — Dos pacientes con el mismo número

> **Fase:** be03 · **Categoría:** Concurrencia · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 55 min · **Ruta forense:** `be03` §6

### 🎫 El ticket

> *"Recepción dice que el paciente 41 aparece dos veces en el sistema, con
> nombres distintos. Pasó el lunes a primera hora, que es cuando hay tres
> personas registrando a la vez. No habíamos visto esto nunca con el sistema
> viejo."*

**Reportado por:** jefa de recepción
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducirlo —y esto es lo difícil, porque es intermitente—, explicar por qué
**nunca pasó con el mock** y aplicar el fix.

### 🔧 Preparación

Rama de git: el código de la rama tiene la versión ingenua del generador de
identificadores.

```bash
git checkout -b incidente-be/04 be-fase-03-la-costura-y-el-reemplazo
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

"Tres personas registrando a la vez" no es color local del ticket: es la
condición de reproducción. Una sola petición nunca lo produce.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Mira cómo se calcula el `legacyId` del paciente nuevo y cuántas operaciones hay
entre leerlo y guardarlo. Después pregúntate cuántos hilos pueden estar en ese
hueco a la vez.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Ese mismo código corría en json-server y era correcto. ¿Qué tiene Node que Spring
MVC no tiene?

</details>

---

### 📝 Tu investigación

**Reproducción**
{{El comando concreto con el que lo forzaste y cuántas peticiones hicieron falta.}}

**Evidencia observable**
{{Los documentos duplicados, con su `_id` distinto y su `legacyId` igual.}}

```
{{salida}}
```

**Hipótesis**
- ❌ Descartada: {{…}}.
- ✅ Confirmada: {{…}}.

**Tu causa raíz**
{{…}}

**Tu fix**
{{…}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El `legacyId` se calcula como *el máximo existente más uno*, en dos operaciones
separadas:

```java
Integer next = repository.findTopByOrderByLegacyIdDesc().getLegacyId() + 1;
patient.setLegacyId(next);
repository.save(patient);
```

Entre la lectura y la escritura hay una ventana, y **Spring MVC atiende con
doscientos hilos**. Dos peticiones simultáneas leen el mismo máximo, calculan el
mismo siguiente, y guardan dos pacientes con el mismo número.

Y la parte que hace formativo el incidente: **ese código era correcto en
json-server**. Node tiene un solo hilo y un bucle de eventos; entre esas dos
líneas no puede colarse nadie. No cambió una línea de lógica: cambió el modelo de
ejecución.

> 🧠 **Portar código correcto a otro modelo de ejecución puede volverlo
> incorrecto sin que una sola línea cambie.** Es la lección del incidente y no es
> de MongoDB ni de Java.

**Parche mínimo**

```java
// El CounterService de be03 §5.4: una colección de contadores y una operación
// ATÓMICA que incrementa y devuelve en un solo viaje al servidor.
// findAndModify es atómico a nivel de documento, así que dos hilos que lleguen
// a la vez se serializan en el servidor y cada uno se lleva un número distinto.
patient.setLegacyId(counterService.nextValue("patients"));
repository.save(patient);
```

Y la red que hay que poner en el mismo commit, porque el fix sin ella es una
promesa:

```javascript
db.patients.createIndex({ legacyId: 1 }, { unique: true });
```

**La refactorización correcta** (que aquí **sí** se paga)

Es este mismo fix: no hay una versión "correcta con calma" distinta. Lo único que
se difiere es el índice único sobre las otras cuatro colecciones, que tienen el
mismo patrón y menos concurrencia — y eso entra en el mismo ticket, no en otro.

**Prueba de regresión**

```java
@Test
public void noDuplicaIdentificadoresBajoConcurrencia() throws Exception {
    int peticiones = 50;
    ExecutorService pool = Executors.newFixedThreadPool(20);
    CountDownLatch listos = new CountDownLatch(1);
    for (int i = 0; i < peticiones; i++) {
        pool.submit(new Runnable() {
            public void run() {
                try {
                    listos.await();            // todos arrancan a la vez
                    service.create(nuevoPaciente());
                } catch (Exception e) { /* el índice único puede rechazar: cuenta */ }
            }
        });
    }
    listos.countDown();
    pool.shutdown();
    pool.awaitTermination(30, TimeUnit.SECONDS);

    // La aserción: tantos legacyId distintos como pacientes guardados.
    long guardados = repository.count();
    long distintos = mongoTemplate.getCollection("patients")
            .distinct("legacyId", Integer.class).into(new HashSet<Integer>()).size();
    assertEquals(guardados, distintos);
}
```

**Prevención**

El índice único. Un índice único no es una optimización: **es la única
restricción de integridad que este sistema va a tener**, y convierte un bug de
datos silencioso en un error ruidoso con el documento culpable en el mensaje.

**Por qué llegó a producción**

Porque el código se portó línea por línea desde un mock que funcionaba, y
funcionaba por una propiedad del entorno —un solo hilo— que nadie escribió en
ninguna parte. `be00` documentó el **contrato** del mock, que es lo observable
desde fuera; el modelo de concurrencia no es observable desde fuera y no estaba
en `CONTRACT.md`. Es un límite real del método, y merece la pena anotarlo.

**Si tu causa fue distinta a esta**

Si concluiste que el frontend envía dos veces la petición, el síntoma encaja
—hay un caso así en el track base—. La forma de distinguirlos: mira los `_id` de
Mongo de los dos pacientes. Si son distintos y los nombres también, fueron dos
peticiones distintas con dos datos distintos, y el problema es del servidor.

</details>

---

## Incidente be-05 — La pantalla que carga y no navega

> **Fase:** be03 · **Categoría:** Contrato · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 25 min · **Ruta forense:** `be03` §6

### 🎫 El ticket

> *"Desde el despliegue del martes la lista de pacientes se ve bien, pero al
> hacer clic en una fila no pasa nada. No sale error, no se abre la ficha, no
> pasa nada."*

**Reportado por:** analista
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir y localizar la capa. Es el incidente más rápido del cuaderno **si
corres la herramienta correcta antes de abrir un archivo**, y el objetivo real es
que midas cuánto tardas con ella y cuánto tardarías sin ella.

### 🔧 Preparación

Rama de git.

```bash
git checkout -b incidente-be/05 be-fase-03-la-costura-y-el-reemplazo
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes que nada: `./smoke.sh`. Diez segundos.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Si no corriste el guion: mira el cuerpo de `GET /patients` en Network, campo por
campo, y compáralo con lo que dice `CONTRACT.md` sobre el `id`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué forma tiene el `id` que llega, y con qué lo está comparando el selector del
frontend?

</details>

---

### 📝 Tu investigación

**Reproducción**
{{…}}

**Evidencia observable**
{{Y anota **cuánto tardaste**. Es el dato del incidente.}}

```
{{salida de smoke.sh, o el cuerpo de la respuesta}}
```

**Hipótesis**
- ❌ Descartada: {{…}}.
- ✅ Confirmada: {{…}}.

**Tu causa raíz**
{{…}}

**Tu fix**
{{…}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Se está serializando el `ObjectId` de Mongo como `id`. El frontend recibe
`"id": "5f4a1c8e9b2d3a4f5c6d7e8f"` donde esperaba `1`, y todo lo que compara
identificadores deja de casar: la ruta no encuentra parámetro numérico, el
selector no encuentra al paciente, y la pantalla no navega.

Lo que hace difícil el diagnóstico **sin el guion** es que las cuatro capas
anteriores están bien: el log del servidor dice `200`, el JSON es válido, el
store se llena, la tabla se pinta. **El síntoma aparece cuatro capas después de
la causa y no se parece en nada a ella.**

**Parche mínimo**

```java
// La frontera del §4.2 de be03, en dos anotaciones.
@Id
@JsonIgnore                      // el ObjectId NO sale nunca
private String id;

@JsonProperty("id")              // el entero del contrato se llama "id" hacia fuera
private Integer legacyId;
```

**La refactorización correcta** (que aquí **sí** se paga, y es una línea)

`@JsonIgnore` también sobre el getter, no solo sobre el campo. Según cómo esté
configurado Jackson, la anotación del campo puede no aplicarse a la propiedad
derivada del getter, y eso reintroduce la fuga sin que nada cambie visiblemente.
Cinturón y tirantes.

**Prueba de regresión**

```bash
# En smoke.sh. Afirma la AUSENCIA de un patrón, que es lo que hay que proteger:
# ningún ObjectId en ninguna respuesta, hoy y en cualquier endpoint futuro.
out=$(curl -s "$BASE/patients")
if echo "$out" | grep -Eq '[0-9a-f]{24}'; then
  echo "  FALLA se filtró un ObjectId en /patients"; FAIL=$((FAIL+1))
else
  echo "  ok   sin ObjectId en la respuesta"
fi
```

**Prevención**

Esa afirmación, aplicada a **todos** los endpoints y no solo a pacientes. Una
anotación se puede quitar sin querer; una prueba en rojo, no. Es el ejercicio 3
de `be03` y el 22 lo extiende.

**Por qué llegó a producción**

Porque la respuesta era **correcta** para cualquier definición razonable de
correcta que no incluyera el contrato: JSON válido, `200`, todos los campos. El
contrato de `be00` lo prohibía explícitamente; lo que faltó fue que alguien
corriera `smoke.sh` antes del despliegue. **Diez segundos contra dos horas de
bisección**, y ese cociente es el argumento entero de `be00`.

**Si tu causa fue distinta a esta**

Si concluiste que la ruta del frontend está mal configurada, el síntoma encaja.
Descártalo en veinte segundos: mira el `id` en la respuesta de red. Si es un
entero, es el frontend; si tiene veinticuatro caracteres hexadecimales, no lo es.

</details>

---

## Incidente be-06 — La muestra que cambió de estado sin que nadie lo apuntara

> **Fase:** be04 · **Categoría:** Trazabilidad · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35 min · **Ruta forense:** `be04` §6

### 🎫 El ticket

> *"La muestra 8802 está en 'procesada' y la línea de tiempo no muestra cuándo
> pasó ni quién la procesó. Los demás pasos sí están. Necesitamos ese dato para
> cerrar la auditoría interna del mes."*

**Reportado por:** calidad
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducirlo, explicar por qué falta **solo ese** asiento, y decir con precisión
qué se puede recuperar y qué no. Ojo con la última parte: es la que importa.

### 🔧 Preparación

Colección sembrada, más un flag de caos para forzar el fallo de la segunda
escritura.

```bash
node dump/seed-incidente-be-06.js
# y para verlo nacer en vivo, con el caos sobre la petición de auditoría:
fetch('http://localhost:3000/samples/8802', {
  method: 'PATCH', headers: { 'X-Chaos': 'fail=500@100', 'Content-Type': 'application/json' },
  body: JSON.stringify({ status: 'processed' })
});
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Hay dos bitácoras desde `be04`. Mira las dos antes de concluir nada.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

La mutación de la muestra y la escritura del asiento son dos operaciones en el
mismo método. Busca qué hay entre las dos.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el proceso muere entre la línea que guarda la muestra y la que guarda el
asiento, ¿qué queda escrito?

</details>

---

### 📝 Tu investigación

**Reproducción**
{{…}}

**Evidencia observable**
{{El estado de la muestra, y la ausencia en las dos colecciones de auditoría.}}

```
{{…}}
```

**Hipótesis**
- ❌ Descartada: {{…}}.
- ✅ Confirmada: {{…}}.

**Tu causa raíz**
{{…}}

**Tu fix**
{{…}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

La transición de la muestra y la escritura de su asiento son **dos escrituras sin
nada que las una** (`be04` §5.4). Si el proceso se cae —o la segunda falla— entre
ellas, la muestra queda transicionada y el asiento no existe. Ni en
`auditLogServer` ni en `auditLog`: el del cliente tampoco llegó, porque el
frontend solo lo escribe si la mutación respondió bien, y respondió mal.

**Y lo que no se puede recuperar:** quién la procesó y a qué hora exacta. La
muestra guarda `processedBy` y `processedAt` en su propio documento, así que en
este caso **sí** hay una fuente —comprueba ese campo antes de decir que no hay
nada—. Si el fallo hubiera ocurrido un paso antes, no la habría.

**Parche mínimo**

Ninguno que cierre la ventana, y decirlo es el ejercicio. Lo que se hace es
registrar el hallazgo para que el detector de `be05` lo levante:

```java
// Lo único aplicable hoy: que el fallo de la auditoría NO se trague en
// silencio. Si el asiento no se pudo escribir, queda constancia de que no se
// pudo — que es distinto de que no exista.
try {
    auditService.record(...);
} catch (RuntimeException e) {
    log.error("asiento no escrito para sample {} requestId {}", legacyId,
              RequestContext.getRequestId(), e);
    integrityDetector.flag("sample", legacyId, "audit-entry-missing");
}
```

**La refactorización correcta** (que en este track **no se puede pagar**)

Una transacción que cubra las dos escrituras. Y aquí está lo interesante: no es
que no se pague por presupuesto — **es que el servidor la rechaza**. Ese es el
contenido de `be05`, y este incidente es su antesala. La mejor aproximación
disponible es la convergencia: detectar y compensar.

**Prueba de regresión**

```java
@Test
public void processedSampleAlwaysHasEntryOrFailureMark() {
    // Con la escritura de auditoría fallando a propósito:
    doThrow(new RuntimeException("boom")).when(auditService).record(any(), any(), any(), any(), any());
    try { service.transition(8802, "processed"); } catch (Exception ignored) { }

    // La aserción NO es "existe el asiento" —no podemos garantizarlo—, sino
    // "no hay una transición silenciosa": o hay asiento, o hay marca.
    assertTrue(auditRepository.existsByEntityId("8802")
            || correctionRepository.existsByEntityAndReason("sample", 8802, "audit-entry-missing"));
}
```

**Prevención**

El detector periódico de `be05` §5.6, buscando muestras con estado terminal y sin
asiento. No previene: **detecta**, que es el verbo correcto y hay que usarlo así
en el informe (`be08` §4.1).

**Por qué llegó a producción**

Porque mover la escritura del asiento del navegador al servidor **redujo** la
ventana de fallo —de una red inestable y un portátil que se cierra, a dos líneas
contiguas del mismo proceso— y todo el mundo, con razón, lo leyó como una mejora.
Lo es. Pero reducir una ventana no es cerrarla, y la diferencia entre las dos
cosas solo se ve el día que se cae en medio.

**Si tu causa fue distinta a esta**

Si concluiste que el `AuditEffect` del frontend no despachó, el síntoma encaja y
es la causa del incidente 17 del cuaderno base. La forma de distinguirlos: mira
`auditLogServer`. Si el asiento del servidor **sí** está y falta el del cliente,
es el frontend. Si faltan los dos, es esto.

</details>

---

## Incidente be-07 — El informe firmado a las 14:47 por alguien que salió a las 14:00

> **Fase:** be04 · **Categoría:** Tiempo · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50 min · **Ruta forense:** `be04` §6

### 🎫 El ticket

No llega como ticket. Llega como una pregunta de Calidad, por correo:

> *"Revisando la bitácora del mes encontramos un resultado validado a las 14:47
> por analista1. Su turno termina a las 14:00 y ese día fichó la salida a las
> 13:58. ¿Nos pueden explicar qué pasó?"*

**Reportado por:** coordinadora de calidad
**Ambiente:** PROD

### 🎯 Qué se te pide

Averiguar qué pasó de verdad y **escribir la respuesta a ese correo**. No hay fix
de código. El entregable es una explicación que exculpe a una persona con
evidencia, no con una opinión.

### 🔧 Preparación

Colección sembrada, y merece la pena reproducirlo además en vivo:

```bash
node dump/seed-incidente-be-07.js
```

Para verlo nacer: adelanta el reloj de **tu máquina** veinticinco minutos —el
servidor sigue en hora—, recarga la aplicación y valida un resultado. Devuelve la
hora después.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Desde `be04` hay dos bitácoras que registran el mismo hecho. Ponlas una al lado
de la otra.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El `timestamp` de cada una. ¿De qué reloj sale cada uno?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`new Date().toISOString()` produce un UTC impecable. ¿A partir de qué?

</details>

---

### 📝 Tu investigación

**Reproducción**
{{…}}

**Evidencia observable**
{{Los dos asientos, con sus dos horas y su diferencia en segundos.}}

```
{{…}}
```

**Hipótesis**
- ❌ Descartada: {{…}}.
- ✅ Confirmada: {{…}}.

**Tu causa raíz**
{{…}}

**Tu fix**
{{Y sobre todo: el borrador del correo.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El `timestamp` del asiento lo pone el navegador con `new Date().toISOString()`,
que usa el reloj y la zona del sistema operativo del operador. El portátil de
`analista1` tenía la hora adelantada ochenta y cinco minutos.

El asiento del servidor, escrito desde `be04` con `Clock.systemUTC()`, dice
**13:22:04**, que es coherente con su turno.

> 🧠 **El formato no valida el contenido.** `"2026-09-08T14:47:11.000Z"` es un
> ISO-8601 impecablemente formado que representa un instante que existe. Ninguna
> validación de esquema, ninguna de Java y ningún `$jsonSchema` lo habrían
> rechazado, porque no hay nada que rechazar.

**Parche mínimo**

Ninguno en el código: `be04` ya puso el reloj del servidor donde debía estar, y
el del cliente no se puede quitar porque el frontend no se toca. Lo que se hace
es **la corrección documental**:

```javascript
// Un asiento en el libro de correcciones (be05 §5.7) que deja constancia de la
// discrepancia y de su explicación. No se borra el asiento falso: se compensa.
db.corrections.insertOne({
  detectedAt: new Date(), detectedBy: "maintenance",
  entityType: "result", entityId: "9114",
  reason: "client-clock-skew",
  evidence: { cliente: "2026-09-08T14:47:11.000Z",
              servidor: "2026-09-08T13:22:04.881Z",
              requestId: "7f3a9c02", desfaseSegundos: 5107 },
  status: "applied", decidedBy: "…", rationale: "reloj del equipo desincronizado"
});
```

**La refactorización correcta** (que en este track 💸 no se paga)

Que el frontend deje de escribir su propio asiento y consuma el del servidor. Es
lo correcto y exige tocar el `AuditEffect`, el servicio y la timeline de la
Fase 11 — o sea, el frontend, que es la restricción no negociable del track.
Queda escrito en `IRRECOVERABLE.md` como recomendación fechada para quien herede
el sistema.

**Prueba de regresión**

No hay test unitario posible: la causa está fuera del sistema. Lo que se escribe
es una **medición recurrente**, la 3 de `be04` §5.6:

```javascript
// Alerta si algún asiento del mes difiere del reloj del servidor en más de
// cinco minutos. Ese umbral es una decisión y va escrito al lado.
db.auditLogServer.aggregate([ ...la medición 3... ])
  .toArray().filter(function (b) { return Math.abs(b.desfaseSegundos) > 300; });
```

**Prevención**

Esa alerta, corriendo mensualmente, **y** la política de sincronización horaria
de los equipos de trabajo — que no es un problema de ingeniería de software y hay
que decirlo así al escalarlo.

**Por qué llegó a producción**

Porque en 2021 el backend estaba congelado y era de otro equipo, y pedirle un
endpoint de auditoría no era una conversación que se pudiera tener. Poner el
timestamp en el navegador fue la única forma disponible de conseguir
trazabilidad, y funcionó durante cinco años. **La deuda técnica no siempre nace
de la ignorancia: a veces nace de una frontera de equipos.**

**Y lo que hay que escribir en el correo**, que es el verdadero entregable:

> *La hora del registro la tomaba el equipo del operador, no el servidor. El
> equipo de `analista1` tenía el reloj adelantado 85 minutos ese día. El registro
> del servidor sitúa la validación a las 13:22, dentro de su turno. La
> discrepancia está documentada con el identificador de la petición que une los
> dos registros. Desde el 10/09/2026 el sistema conserva las dos horas y podemos
> detectar estos casos; de los registros anteriores a esa fecha no tenemos una
> segunda fuente con la que contrastar.*

Fíjate en la última frase. **Es la más incómoda y es la que hace creíble el
resto.**

**Si tu causa fue distinta a esta**

Si concluiste que alguien usó la sesión de `analista1`, el síntoma encaja y es
una hipótesis seria que hay que descartar con evidencia y no con confianza. Se
descarta así: el actor del asiento del servidor sale de un token firmado, y su
hora es coherente con el turno. Un uso indebido de sesión produciría un asiento
**con la hora del servidor correcta** y el actor equivocado — que es la fila no
benigna de la medición 2, y es otro incidente.

</details>

---

## Incidente be-08 — La orden que contradice a sus muestras

> **Fase:** be05 · **Categoría:** Atomicidad · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 55 min · **Ruta forense:** `be05` §6

### 🎫 El ticket

> *"La orden 4021 dice que está en proceso pero sus dos muestras ya están
> procesadas. El panel del turno la sigue contando como pendiente y nos
> descuadra el conteo del día."*

**Reportado por:** analista de turno
**Ambiente:** PROD

### 🎯 Qué se te pide

Reconstruir qué pasó usando **tres fuentes** —la base, el log de la aplicación y
el log de `mongod`—, y aplicar la corrección **sin sobrescribir nada**. La
segunda parte es la que se evalúa.

### 🔧 Preparación

Rama de git, más una interrupción provocada.

```bash
git checkout -b incidente-be/08 be-fase-05-la-cadena-de-custodia-y-la-transaccion
# La rama trae un Thread.sleep(8000) entre las dos escrituras. Lanza la
# transición y, durante esos ocho segundos:
docker compose stop db
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Los dos documentos son válidos por separado. Lo inválido es la relación entre
ellos, así que no busques un documento malformado.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Busca el asiento de auditoría de la muestra. Está. Busca el de la orden. No está.
Y el asiento que sí está trae un `requestId`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Busca ese `requestId` en el log de la aplicación. ¿Hay línea de entrada? ¿Hay
línea de salida?

</details>

---

### 📝 Tu investigación

**Reproducción**
{{…}}

**Evidencia observable**
{{Las tres fuentes, con el `requestId` uniéndolas.}}

```
{{documentos + línea de log + log de mongod}}
```

**Hipótesis**
- ❌ Descartada: {{…}}.
- ✅ Confirmada: {{…}}.

**Tu causa raíz**
{{…}}

**Tu fix**
{{…}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Tres documentos, un hecho de negocio, cero transacción. La transición de una
muestra a `processed` tiene que escribir la muestra, empujar la orden a
`partial_results` y dejar un asiento. El proceso murió después de la primera.

La reconstrucción, con sus tres fuentes:

```
db.samples   → 8801 y 8802 en "processed", processedAt 18:22:41
db.orders    → 4021 sigue en "in_process"
auditLogServer → asiento de la muestra 8802, requestId 9d4e1f7a
log de la app  → "9d4e1f7a PATCH /samples/8802 -> …"  (línea de salida ausente)
log de mongod  → update de samples a las 18:22:41; señal 15 a las 18:22:44
```

**Y no se puede arreglar con una transacción**, que es lo que cualquiera
intentaría: `mongo:4.0` en modo standalone las rechaza con el código 20
—*Transaction numbers are only allowed on a replica set member or mongos*—. La
capacidad existe en el producto; una decisión de despliegue de 2019 la dejó fuera
de alcance.

**Parche mínimo**

```javascript
// 1. El asiento en el libro, con la evidencia CONGELADA.
db.corrections.insertOne({
  detectedAt: new Date(), detectedBy: "maintenance",
  entityType: "order", entityId: "4021", reason: "order-behind-samples",
  evidence: { order: { status: "in_process" },
              samples: ["8801:processed", "8802:processed"],
              requestId: "9d4e1f7a" },
  status: "pending"
});

// 2. La corrección, con su propio asiento de auditoría diciendo que la
//    escribió una corrección y NO una persona.
db.orders.updateOne({ legacyId: 4021 }, { $set: { status: "partial_results" } });

// 3. Y el asiento que cierra el anterior en el libro. Nunca se edita el primero.
```

**La refactorización correcta** (que en este track **no se puede pagar**)

Convertir la base a replica set —dos días de trabajo, semanas de calendario
ajeno, porque es un servicio gestionado— y envolver las tres escrituras en una
transacción. **Es la única recomendación fuerte de todo el track** (`be08` §5.6),
y no se ejecuta porque la base no es del equipo.

**Prueba de regresión**

No puede ser una prueba unitaria, y explicar por qué es parte del ejercicio: el
fallo requiere que el proceso muera en un instante concreto, y eso no se simula
en una prueba de unidad sin simular precisamente lo que se quiere probar. Lo que
se escribe es el **detector**:

```java
@Test
public void detectsOrdersLeftBehind() {
    // Estado inconsistente, montado a mano.
    sampleRepository.save(sample(8801, 4021, "processed"));
    sampleRepository.save(sample(8802, 4021, "processed"));
    orderRepository.save(order(4021, "in_process"));

    detector.detect();

    assertTrue(correctionRepository.existsByEntityAndReason("order", 4021,
            "order-behind-samples"));
}
```

**Prevención**

El detector horario de `be05` §5.6, con su comprobación de idempotencia para que
no cree ciento sesenta y ocho correcciones del mismo problema en una semana.
**Detecta y compensa; no previene**, y el informe tiene que usar esos verbos.

**Por qué llegó a producción**

Porque en 2019 se levantó un `mongod` suelto en vez de un replica set. Era la
configuración normal de la época —un replica set de un nodo sonaba a error de
configuración, y las transacciones multidocumento tenían un año de vida— y nadie
volvió a revisarla en siete años, ni siquiera durante los cuatro cambios de
versión mayor de `be07`. **Nadie convierte un standalone en replica set durante
un bump de versión**, así que la decisión de una tarde sobrevivió a cuatro
oportunidades de revisarse.

**Si tu causa fue distinta a esta**

Si concluiste que la regla "la última muestra procesada empuja la orden" no está
implementada, el síntoma encaja perfectamente. Descártalo así: repite la
transición con el sistema sano y comprueba que la orden **sí** avanza. Si avanza,
la regla existe y el problema es cuándo dejó de ejecutarse, no si existe.

</details>

---

## Incidente be-09 — Arreglamos las veintitrés y ahora nadie sabe qué pasó

> **Fase:** be05 · **Categoría:** Evidencia · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45 min · **Ruta forense:** —

### 🎫 El ticket

> *"Calidad pregunta cuántas muestras estuvieron con la cadena de custodia
> incompleta y durante cuánto tiempo. Sabemos que había un problema porque se
> habló en la reunión del mes pasado, y que alguien lo arregló. Necesitamos el
> número para el informe de la auditoría."*

**Reportado por:** dirección técnica
**Ambiente:** PROD

### 🎯 Qué se te pide

Contestar la pregunta. Y si la respuesta correcta es que no se puede contestar,
**demostrar por qué** y proponer qué se hace a partir de ahora.

### 🔧 Preparación

Colección sembrada: el guion deja la base en el estado **posterior** a una
limpieza. Todo consistente, sin libro de correcciones.

```bash
node dump/seed-incidente-be-09.js
```

> ⚠️ **Este incidente se aprende por ausencia**, así que resiste la tentación de
> mirar el guion de siembra antes de intentarlo.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Corre la agregación de cadenas rotas de `be05` §5.4. Te va a dar cero. Ese cero
es el incidente, no el final del incidente.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Si alguien arregló veintitrés documentos, ¿dónde debería haber quedado
constancia? Busca en los tres sitios donde podría estar.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué operación deja un documento consistente y no deja ni un rastro de que antes
no lo estaba?

</details>

---

### 📝 Tu investigación

**Reproducción**
{{Qué buscaste y qué no encontraste. Aquí las ausencias son la evidencia.}}

**Evidencia observable**
{{Los tres sitios donde miraste y qué había en cada uno.}}

```
{{…}}
```

**Hipótesis**
- ❌ Descartada: {{…}}.
- ✅ Confirmada: {{…}}.

**Tu causa raíz**
{{…}}

**Tu fix**
{{La respuesta a dirección técnica, y la propuesta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Alguien corrió un script de normalización que puso cada muestra en el estado que
le correspondía. El sistema quedó **consistente y mudo**: un `$set` sobre un
documento no deja rastro de lo que había antes.

Los tres sitios donde se buscó y por qué ninguno sirve:

| Dónde | Por qué no hay nada |
|---|---|
| `db.corrections` | No existía, o estaba vacía: el script no la usó |
| `auditLogServer` | Solo registra mutaciones que pasan por la aplicación; el script fue directo al shell |
| `git log` | El script no se versionó. Y aunque lo estuviera, no dice a qué documentos afectó |

**La respuesta correcta a la pregunta de dirección técnica es: *no se puede
saber*.** Ni cuántas eran, ni desde cuándo, ni cuáles. Y hay que decirlo así.

**Parche mínimo**

Ninguno. No hay nada roto que arreglar: ese es el problema.

Lo que sí se hace, y es el entregable:

```markdown
## Lo que no se puede reconstruir — cadenas de custodia, [fecha]

Entre [fecha desconocida] y [fecha desconocida] hubo un número indeterminado de
muestras con la cadena de custodia incompleta. Fueron normalizadas por una
operación directa sobre la base que no dejó registro.

**No se puede determinar:** cuántas fueron, cuáles, durante cuánto tiempo, ni si
se emitieron informes sobre ellas en ese periodo.
**Se puede determinar:** que hoy no hay ninguna (verificado el [fecha] con la
agregación de be05 §5.4, resultado 0).
**Desde el [fecha] toda corrección queda registrada** en el libro de
correcciones, con la evidencia previa congelada.
```

**La refactorización correcta** (que aquí **sí** se paga, y es lo primero)

Quitarle a las cuentas de aplicación el permiso de `update` directo sobre las
colecciones que son evidencia, y canalizar toda corrección por el libro
(`be08` §5.4). Es una tarde de trabajo y está en el segundo puesto del orden de
prioridad de [`bea-11`](./bea-11-mapa-de-deuda-del-track-be.md) §5.

**Prueba de regresión**

No hay test que atrape esto, porque no es un fallo de código. Lo más parecido es
un guion que compare el número de documentos modificados con el número de
asientos del libro en la misma ventana, y que avise si no cuadran:

```javascript
// dump/verify-corrections.js — corre semanal.
var fixedWithoutEntry = db.samples.countDocuments({
  updatedAt: { $gte: oneWeekAgo },
  legacyId: { $nin: db.corrections.distinct("entityId", { entityType: "sample" })
                      .map(Number) }
});
if (fixedWithoutEntry > 0) {
  print('ALERTA: ' + fixedWithoutEntry + ' muestras modificadas sin asiento');
}
```

> ⚠️ Y una advertencia honesta sobre ese guion: **solo funciona si los documentos
> tienen `updatedAt`**, y los de LabCore no lo tienen todos. Escríbelo sabiendo
> qué no cubre.

**Prevención**

Los permisos. Y el procedimiento escrito de que **ninguna corrección de datos se
aplica sin asiento previo**, que es una regla de equipo y no una línea de código.

**Por qué llegó a producción**

Porque arreglar un dato inconsistente con un `updateMany` es la reacción natural
de cualquier ingeniero competente, y **nada en el sistema le dijo que no lo
hiciera**. No hubo negligencia: hubo una operación razonable en un sistema que no
distinguía entre un dato operativo y una evidencia.

> 🧠 **La regla que este incidente instala, y es la de `be05` §4.4:** *la
> corrección tiene que costar más que el error para que el sistema sea
> auditable.* Si arreglar un dato es una línea que no deja rastro, la verdad del
> sistema es la del último que escribió.

**Si tu causa fue distinta a esta**

Si concluiste que nunca hubo tal problema y que la reunión se refería a otra
cosa, es una hipótesis legítima y hay que descartarla con evidencia, no
descartarla por incómoda. Se descarta buscando el acta de la reunión, los
correos, o los tickets del mes anterior. **Cuando la base no tiene la respuesta,
la evidencia está fuera del sistema** — y esa es la misma lección de `be-10` y de
`be-11`.

</details>

---

## Incidente be-10 — El informe dice normal y la pantalla dice alto

> **Fase:** be06 · **Categoría:** Normativo · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 55 min · **Ruta forense:** `be06` §6

### 🎫 El ticket

> *"Un paciente trajo su informe de glucosa de marzo de 2020, impreso, donde dice
> que su resultado estaba dentro del rango normal. Lo buscamos en el sistema y
> ahora aparece marcado como fuera de rango. El valor es el mismo en los dos.
> ¿Cuál de los dos está mal?"*

**Reportado por:** calidad
**Ambiente:** PROD

### 🎯 Qué se te pide

Averiguar cuál de los dos dice la verdad, explicar cómo es posible que el sistema
se contradiga a sí mismo citando la misma fuente, y cuantificar cuántos informes
están en la misma situación.

### 🔧 Preparación

Colección sembrada: el volcado de `be02` ya contiene el estado posterior al
`$set` de 2020.

```bash
./verify-dump.sh    # confirma que el volcado está cargado y correcto
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El comparador de rangos funciona. Compruébalo con un resultado reciente antes de
perder tiempo ahí.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El resultado guarda `rangeVersionApplied`. Ve a esa versión del rango y mira sus
límites **y su fecha de vigencia**.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El puntero está intacto. ¿Y el destino? ¿Qué pasa si alguien cambió los valores
de una versión sin crear una nueva?

</details>

---

### 📝 Tu investigación

**Reproducción**
{{El resultado concreto, su valor, su versión aplicada y los límites de hoy.}}

**Evidencia observable**
{{…}}

```
{{el resultado y la versión, uno al lado del otro}}
```

**Hipótesis**
- ❌ Descartada: {{…}}.
- ✅ Confirmada: {{…}}.

**Tu causa raíz**
{{…}}

**Tu fix**
{{…}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

En agosto de 2020, cuando la norma bajó el límite superior de glucosa de 100 a
99 mg/dL, alguien ejecutó:

```javascript
db.referenceRanges.updateOne({ analyte: 'glucose', version: 2 },
                             { $set: { high: 99 } });
```

En vez de cerrar la vigencia de la v2 y crear una v3. **El puntero sobrevivió; el
destino cambió.** El resultado de marzo de 2020 vale 99,4 y dice haberse juzgado
contra la v2: contra la v2 *de entonces* (`high: 100`) estaba dentro; contra la
v2 *de hoy* (`high: 99`) está fuera.

**El informe impreso dice la verdad.** La pantalla de hoy aplica un criterio que
no existía cuando se firmó.

> 🧠 **Y lo que hace único a este incidente: el sistema contradice su propio
> informe firmado citando la misma fuente.** No hay dato malformado, no hay
> puntero roto, no hay error de tipo. Ninguna comprobación de integridad lo
> detectaría.

**Parche mínimo**

Ninguno sobre los datos históricos, y es importante: "restaurar" el 100 en la v2
haría que los informes viejos cuadraran y que **los nuevos dejaran de cumplir la
norma vigente**. Se cambiaría un problema por otro peor.

Lo que sí se hace, en dos partes:

```javascript
// 1. El corte: a partir de hoy, append-only. Cerrar la v2 y nacer la v3.
db.referenceRanges.updateOne({ analyte: 'glucose', version: 2 },
  { $set: { effectiveTo: ISODate('2020-07-31T23:59:59Z') } });   // este $set SÍ
db.referenceRanges.insertOne({ analyte: 'glucose', version: 3, unit: 'mg/dL',
  low: 70, high: 99, criticalLow: 50, criticalHigh: 250,
  effectiveFrom: ISODate('2020-08-01T00:00:00Z'), effectiveTo: null,
  recordedAt: new Date(), recordedBy: "maintenance" });

// 2. Y la guarda que impide repetirlo (be06 §5.6), en el mismo commit.
```

> 🧭 **La regla, con su precisión:** no es *"nunca se muta un documento de
> versión"*. Es **"se puede escribir su cierre, y nunca sus valores"**. Cerrar
> una vigencia no cambia lo que la versión decía: añade hasta cuándo lo decía.

**La refactorización correcta** (que en este track se implementa a medias, y se
declara)

El modelo bitemporal completo —tiempo de vigencia **y** tiempo de registro—. Se
implementa la mitad: append-only más `recordedAt`. La otra mitad **no recupera
nada** y encarece cada lectura de un sistema con dos años de vida. La decisión va
fechada en `CONTRACT.md` con su condición de revisión (`be06` §4.4).

**Prueba de regresión**

```java
@Test(expected = ImmutableVersionException.class)
public void noSePuedenCambiarLosLimitesDeUnaVersionExistente() {
    ReferenceRange v2 = repository.findByAnalyteAndVersion("glucose", 2);
    v2.setHigh(95);
    repository.save(v2);        // la guarda de be06 §5.6 lo rechaza
}

@Test
public void siSePuedeEscribirElCierreDeVigencia() {
    ReferenceRange v2 = repository.findByAnalyteAndVersion("glucose", 2);
    v2.setEffectiveTo(new Date());
    repository.save(v2);        // effectiveTo es el único campo mutable
}
```

**Prevención**

La guarda de inmutabilidad, **y** quitarle a la cuenta de la aplicación el
permiso de `update` sobre `referenceRanges` (`be08` §5.4) — porque la guarda vive
en la aplicación y cualquiera con acceso al shell la esquiva. Las dos cosas, no
una.

**Por qué llegó a producción**

Porque quien ejecutó el `$set` en 2020 hizo lo que su modelo mental indicaba: *"la
versión 2 ya existe y sigue vigente, solo cambian los números"*. En esa lectura,
`$set` es exactamente lo que se hace. La pista de que `referenceRanges` no guarda
entidades sino **hechos fechados** estaba en el nombre de la colección y en el
campo `version`, y nadie la vio porque nadie había escrito la regla en ninguna
parte. **La prevención no era una revisión de código: era una regla de modelado
que no existía.**

**Y el alcance, que es el número del ticket:** 1.204 resultados de glucosa
validados en la ventana de catorce meses, de los cuales **37 cambian de veredicto**
al releerse con los límites actuales. Ese 37 es el que va al informe, no el 1.204.

**Si tu causa fue distinta a esta**

Si concluiste que el selector de rango vigente compara mal las fechas, el síntoma
encaja —y hay un incidente así en el track base, el 07, por zona horaria—.
Descártalo comprobando que un resultado **reciente** se juzga bien: si el
comparador estuviera roto, fallaría también con los nuevos.

</details>

---

## Incidente be-11 ⭐ — No desplegamos nada y dejó de funcionar

> **Fase:** be07 · **Categoría:** Configuración · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50 min · **Ruta forense:** `be07` §6

### 🎫 El ticket

> *"Desde el fin de semana el script nocturno de conciliación falla. No hemos
> desplegado nada. El log dice `executable file not found`."*

**Reportado por:** operaciones
**Ambiente:** PROD

### 🎯 Qué se te pide

Encontrar la causa. Es el incidente insignia del cuaderno y el objetivo real no
es el fix —es de una línea— sino **el camino**: anota por dónde buscaste y en qué
orden, porque la retrospectiva del mes va a preguntártelo.

### 🔧 Preparación

Una línea del `.env`. **Es el único incidente del cuaderno que se prepara así**, y
eso es la mitad de la lección.

```bash
sed -i '' 's/^MONGO_TAG=.*/MONGO_TAG=7.0/' .env && docker compose up -d db
```

> 💡 **Idealmente, que te lo prepare otra persona y no te diga qué tocó.** Si lo
> haces tú, ya sabes la respuesta y el ejercicio pierde su mejor parte: la
> sensación de que las herramientas de siempre no sirven.

> ⚠️ **Este incidente no tiene par `-roto` / `-fix`.** No lo busques.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

`git log` está limpio, el pipeline no corrió, y los logs de la aplicación están
impecables. Las tres cosas son ciertas y ninguna es un error tuyo. **Deja de
buscar en el repositorio.**

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

La pregunta que hay que hacerse es: *¿qué cambió que no pasa por mi
repositorio?* Haz la lista. Imagen base, versión de runtime, certificado, cuota,
política del proveedor, zona horaria del sistema.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`docker compose exec db mongod --version`. Compáralo con lo que creías que estaba
corriendo.

</details>

---

### 📝 Tu investigación

**Reproducción**
{{…}}

**Evidencia observable**
{{Y esto es lo importante: **anota por dónde buscaste primero, y cuánto tardaste
en cada callejón**. Esa lista es el entregable del incidente.}}

```
{{…}}
```

**Hipótesis**
- ❌ Descartada: {{…}}.
- ✅ Confirmada: {{…}}.

**Tu causa raíz**
{{…}}

**Tu fix**
{{…}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El proveedor subió la base de datos en su ventana de mantenimiento. A partir de
la versión **6.0**, la imagen de MongoDB **ya no incluye el shell `mongo`**: se
llama `mongosh`. El script de conciliación, escrito en 2019, invoca
`docker exec … mongo --eval …`, y ese ejecutable ya no existe.

**El cambio no está en el árbol de fuentes.** Está en una línea de un archivo que
no es código:

```
MONGO_TAG=7.0
```

Por eso `git log`, `git blame` y el pipeline de despliegue —los cuatro primeros
movimientos de cualquier investigador— no llevan a ninguna parte. **No es que no
encontraras el commit: es que no hay commit.**

**Parche mínimo**

```bash
# El script, con el shell nuevo. Y ojo: hay que revisar TODOS los runbooks,
# no solo el que falló. Si uno está roto, están rotos todos.
-docker compose exec -T db mongo   labcore --quiet --eval "$CONSULTA"
+docker compose exec -T db mongosh labcore --quiet --eval "$CONSULTA"
```

**La refactorización correcta** (que aquí **sí** se paga, y es barata)

El guion `version-diff.sh` del ejercicio 21 de `be07`: ejecuta una lista de
consultas contra dos contenedores de versiones distintas y reporta las
diferencias. **Es la contramedida más barata del track** y la única que convierte
el próximo correo del proveedor en una tarde de trabajo en vez de en un salto de
fe.

**Prueba de regresión**

**No puede haber un test en el repositorio**, y explicar por qué es parte del
ejercicio: el cambio no ocurre en el repositorio, así que ninguna prueba que viva
ahí puede anticiparlo. Lo más parecido que existe es una comprobación de entorno
al arrancar el script:

```bash
# Al principio de cada runbook. Falla temprano y con un mensaje que dice qué
# hacer, en vez de con "executable file not found" a las tres de la mañana.
SHELL_BIN=$(docker compose exec -T db sh -c 'command -v mongosh || command -v mongo' | tr -d '\r')
[ -n "$SHELL_BIN" ] || { echo "ningún shell de mongo en la imagen"; exit 1; }
```

Es más débil que un test y hay que decirlo así: no impide la rotura, la convierte
en un mensaje legible.

**Prevención**

El procedimiento del ejercicio 23 de `be07`: quién recibe el correo del
proveedor, qué se comprueba, con qué guion, en qué ambiente y con qué criterio se
aprueba. **Es un procedimiento, no código**, y esa es la conclusión del
incidente.

**Por qué llegó a producción**

Por una asimetría que nadie decidió: **a la infraestructura la actualizan, a la
aplicación no**. La base tenía dueño —un proveedor, un contrato, un calendario
propio—; el código no tenía ninguno. Entre 2019 y hoy la base subió cuatro
versiones mayores, cada una anunciada por un correo que llegó a una lista de
distribución de Operaciones, y la aplicación no se movió nunca.

Y el agravante que hace didáctico el caso: **no se rompió nada de la aplicación**.
`smoke.sh` pasa entero en los cuatro escalones. Lo que se rompió fue la capacidad
de **operar** el sistema, que es un daño que ningún monitor detecta porque no hay
ninguna métrica que baje.

> 🧠 **La regla que instala este incidente, y es la más transferible del
> cuaderno:** *cuando el síntoma es real y el `git log` está limpio, deja de
> buscar en el código y pregunta qué cambió fuera de tu repositorio.* La lista de
> sospechosos es siempre parecida y casi nada de ella tiene commit.

**Si tu causa fue distinta a esta**

Si concluiste que alguien cambió el script, el síntoma encaja y es la primera
hipótesis de todo el mundo. Se descarta en diez segundos con `git log` sobre el
archivo. Que esa comprobación **no** lleve a ninguna parte es información, no un
callejón sin salida: significa que la causa está fuera, y ahí es donde la mayoría
de la gente vuelve a empezar por el código en vez de cambiar de sitio.

</details>

---

## Incidente be-12 — Desde el viernes no podemos guardar algunos pacientes

> **Fase:** be08 · **Categoría:** Procedimiento · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40 min · **Ruta forense:** `be08` §6

### 🎫 El ticket

> *"Desde el viernes por la tarde, Recepción no puede actualizar los datos de
> algunos pacientes. Da error al guardar. Con otros funciona perfectamente. No
> encontramos qué tienen en común los que fallan."*

**Reportado por:** jefa de recepción
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir, encontrar **qué tienen en común** los que fallan, y revertir. Y
después contestar la pregunta que cierra el track: este incidente era predecible
con una consulta de una línea, ¿por qué nadie la corrió?

### 🔧 Preparación

Una colección con validador aplicado.

```bash
node dump/seed-incidente-be-12.js   # aplica el validador en strict + error
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

"Desde el viernes por la tarde" y "no desplegamos nada" pueden ser las dos ciertas
a la vez. Mira qué cambió en la **base**, no en la aplicación.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`db.getCollectionInfos({ name: 'patients' })` y busca `options.validator`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Los pacientes que fallan, ¿son de alguna forma en particular? Vuelve al
inventario de `be02`.

</details>

---

### 📝 Tu investigación

**Reproducción**
{{Un paciente que falla y uno que no, con su `documentId`.}}

**Evidencia observable**
{{El error exacto, y qué tienen en común los que fallan.}}

```
{{…}}
```

**Hipótesis**
- ❌ Descartada: {{…}}.
- ✅ Confirmada: {{…}}.

**Tu causa raíz**
{{…}}

**Tu fix**
{{…}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El viernes se aplicó un `$jsonSchema` sobre `patients` con
`validationAction: 'error'` y `validationLevel: 'strict'`. Los pacientes que
fallan son exactamente los **1.630** de las formas **C** y **D** de `be02`: 718
sin `fullName` y 912 con `birthDate` de tipo `date`.

Con `strict`, la validación se aplica a **todos** los `update`, incluidos los de
documentos que ya no cumplían. Con `moderate`, esos documentos quedan exentos y
Recepción habría seguido trabajando.

Y el diagnóstico costó más de lo necesario porque en `mongo:4.0` el error de
validación es:

```
{ "ok": 0, "errmsg": "Document failed validation", "code": 121 }
```

Ni el campo, ni la regla, ni el valor. Los mensajes detallados llegaron en
MongoDB 5.0 — así que si tu base ya subió a 7.0 (`be07`), tienes una capacidad de
diagnóstico que el sistema de 2019 no tenía.

**Parche mínimo**

```javascript
// Revertir a la combinación que no rompe nada, inmediatamente.
db.runCommand({ collMod: 'patients',
                validationAction: 'warn', validationLevel: 'moderate' });
```

**La refactorización correcta** (que aquí **sí** se paga, y es un procedimiento)

El de `bea-06` §4, con su paso 1 **obligatorio y escrito**: medir cuántos
documentos no pasarían **antes** de aplicar nada, decidir qué se tolera con la
razón al lado, aplicar en `moderate` + `warn`, observar con un criterio escrito
de antemano, y subir a `error` una colección cada vez.

**Prueba de regresión**

```bash
# En smoke.sh. Afirma que un paciente de la forma C se puede seguir
# actualizando — que es exactamente lo que Recepción necesita.
expect_status "se puede actualizar un paciente de la forma C" \
  200 PATCH "/patients/3001" '{"active":false}'
```

**Prevención**

El procedimiento escrito, y en particular el criterio de subida: *"se sube a
`error` cuando pasen treinta días sin un solo aviso nuevo"*. Sin esa frase
escrita **antes** de empezar a observar, la decisión se toma por corazonada un
viernes.

**Por qué llegó a producción**

Y esta es la parte que cierra el cuaderno y el track entero.

**El número que explicaba el incidente estaba medido desde `be02`.** Los 1.630
documentos de las formas C y D estaban en `MEASUREMENTS.md`, con su fecha y su
agregación copiable. Nadie lo consultó antes de endurecer.

Ocho fases de trabajo, ocho números en un archivo, y el incidente ocurrió igual —
porque **medir y consultar lo medido antes de actuar son dos disciplinas
distintas**. La segunda no se aprende midiendo más.

> 🧠 La contramedida no es un `if`, ni una prueba, ni un tipo más estricto. Es un
> procedimiento con un paso obligatorio, y explicar por qué un procedimiento
> escrito vale más que una línea de código es el último ejercicio del track.

Es también el único incidente del cuaderno cuya causa raíz **no está ni en el
código ni en los datos**, y por eso va el último.

**Si tu causa fue distinta a esta**

Si concluiste que el problema es un cambio en el modelo de Java, el síntoma
encaja: un campo nuevo obligatorio produciría algo parecido. Se descarta en un
minuto con `git log` sobre `Patient.java` —limpio— y con
`db.getCollectionInfos()`, que muestra el validador con su fecha implícita en el
`collMod`. **Cuando la aplicación no cambió y el comportamiento sí, mira la
base**: es la versión de `be-11` aplicada a una capa más abajo.

</details>

---

# 🪞 Retrospectiva del track

Se llena al terminar, de una sola vez, releyendo tu propio `git log`.

- **Cuántos abriste, cuántos cerraste, cuántos quedaron ⚪.**
- **Cuántas veces tu causa raíz coincidió con la de referencia**, y en cuáles no. El patrón importa más que el número.
- **En qué capa te costó más:** el contrato, el modelo de datos, la concurrencia, el tiempo, la configuración, el procedimiento.
- **Cuántas veces buscaste en el código antes de buscar en los datos.** Es la métrica propia de este track, el equivalente del orden de desconfianza del cuaderno base. Seis de los doce incidentes no tienen causa en el código.
- **Cuántas veces la respuesta estaba fuera del sistema** —un informe impreso, un correo del proveedor, un acta de reunión—. Tres de los doce.
- **Qué pista abriste antes de tiempo y por qué.** Sin culpa: es un dato sobre dónde te falta confianza.
- **Tu checklist de diagnóstico de backend**, de una página, reescrita con lo que aprendiste. Es lo único de este archivo que te llevas al trabajo real. Empiézala con las cuatro preguntas de `forense-master.md` §1 y añádeles la quinta que este track te enseñó: **¿qué cambió que no pasa por mi repositorio?**

---

# 📌 Pendientes que salieron de los incidentes

Lo que apareció investigando y no cabía en el fix, con el ID que lo originó:

- **[be-01]** Afirmar el `Content-Type` de la familia de errores en `smoke.sh`, no solo el de las respuestas de éxito → hecho en el propio incidente; extenderlo a los `404` y `401`.
- **[be-02]** El guion `verify-integrity.js` semanal, con la línea base de 37 escrita → sugerido para el procedimiento operativo de `be08`.
- **[be-03]** La detección de **formas nuevas** debería correr junto a `verify-dump.sh` → sugerido para `bea-12`.
- **[be-04]** El índice único de `legacyId` está en `patients`; falta en las otras cuatro colecciones → ticket propio.
- **[be-06]** Los documentos de LabCore no tienen todos `updatedAt`, y eso limita cualquier detección basada en "qué se modificó" → anotado como límite conocido en `be-09`.
- **[be-09]** Quitar el permiso de `update` directo sobre las colecciones que son evidencia → segundo puesto del orden de prioridad de [`bea-11`](./bea-11-mapa-de-deuda-del-track-be.md) §5.
- **[be-11]** `version-diff.sh` tiene que existir **antes** del próximo correo del proveedor → es el pendiente más urgente del track.
- **[be-12]** El procedimiento de endurecimiento, escrito como documento operativo que alguien pueda seguir sin haber leído `bea-06` → ejercicio 18 de `be08`.

---

## 🔥 El cuaderno hermano del track base

Los veintiún incidentes del frontend viven en
[`cuaderno-incidentes.md`](cuaderno-incidentes.md), con IDs `01`–`21` en un rango
independiente de este. Los dos no se cruzan y ninguno renumera al otro.

Si hiciste los dos, hay tres parejas que vale la pena leer seguidas, porque son
**el mismo fallo visto desde los dos lados del cable**:

| Del cuaderno base | De este | Qué comparten |
|---|---|---|
| **17** — el asiento que acusa a quien no estaba | **be-07** | El mismo hecho. En el 17 no hay forma de exculpar al operador; en `be-07` sí, porque hay una segunda fuente |
| **11** — la custodia imposible | **be-08** | El 11 muestra el hueco en la línea de tiempo; `be-08` muestra por qué el hueco se escribió |
| **12** — el resultado validado sin norma detrás | **be-10** | El 12 encuentra un `rangeVersionApplied` en `null`; `be-10` encuentra uno que apunta a una versión que ya no dice lo mismo |

> 🧠 **Y la diferencia de fondo entre los dos cuadernos, que es la del track
> entero:** en el base, la causa está casi siempre en el código y el fix es una
> línea. Aquí, **seis de los doce incidentes no tienen fix**: tienen una medición,
> una declaración y un procedimiento. Ese es el trabajo de mantener un sistema que
> lleva siete años funcionando.
