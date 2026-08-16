# 📎 Apéndice bea-12 — Datos de prueba y volumen 🔥

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Consulta rápida · **3 horas** · 🔥 opcional dentro del track
> Usado por: be02; de consulta desde be03 (su ejercicio 🔥 de volumen) · Versiones cubiertas: Node 12/14 (el del track base), MongoDB 4.0 → 7.0

**Esto no se lee de corrido.** Se entra buscando de dónde salen los datos con los que estás midiendo, o por qué tu medición da un número distinto cada vez que la corres.

Resuelve una cosa: **conseguir volumen suficiente para que las mediciones del track digan algo, sin que los datos generados arruinen las pruebas.** Son dos objetivos que tiran en direcciones contrarias, y casi todo este apéndice existe por el segundo.

**Qué queda fuera:** la anonimización de datos reales de pacientes. Es un dominio regulado, el problema es real y serio, y este apéndice **no da receta**: si en tu trabajo alguien propone traerse un volcado de producción a un portátil, eso lo decide cumplimiento y no ingeniería. Se nombra y se escala.

---

## Índice

- [1. Las tres fuentes de datos del track](#1-las-tres-fuentes-de-datos-del-track)
- [2. Por qué un dataset aleatorio arruina una prueba](#2-por-qué-un-dataset-aleatorio-arruina-una-prueba)
- [3. El generador determinista](#3-el-generador-determinista)
- [4. Las cinco formas del documento de paciente](#4-las-cinco-formas-del-documento-de-paciente)
- [5. Los números que el volcado tiene que producir](#5-los-números-que-el-volcado-tiene-que-producir)
- [6. `verify-dump.sh`: el volcado se verifica, no se cree](#6-verify-dumpsh-el-volcado-se-verifica-no-se-cree)
- [7. Volumen: cuando hace falta medir de verdad](#7-volumen-cuando-hace-falta-medir-de-verdad)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Las tres fuentes de datos del track

Conviene tenerlas separadas desde el primer día, porque mezclarlas es el error que produce mediciones que no cuadran.

| Fuente | Qué es | Quién la usa | Dónde vive |
|---|---|---|---|
| **Tu `db.json`** | Lo que generó `npm run seed` en el track base: ~25 pacientes, ~40 órdenes, limpio | `be03` y todo lo demás | La base `labcore` |
| **El volcado sucio** | 4.820 pacientes con seis años de deriva, sintético y determinista | `be02`, `be05` | La base **`labcore_prod_sample`** |
| **El volumen sintético** | El volcado sucio multiplicado, solo para medir rendimiento | ejercicios de escalado de `be02` y `be03` | Una base desechable |

> 🧭 **La regla que ordena la tabla, y viene de `be03`:** *la aplicación corre siempre sobre tu propio `db.json`; el volcado sucio vive en una base aparte y solo se mide.* Si los dos se mezclan, pasan dos cosas malas a la vez: las mediciones de `be02` dejan de ser reproducibles porque la aplicación va escribiendo encima, y la aplicación empieza a mostrar pacientes sin nombre que tú no sembraste.

Y la razón de que el volcado no salga de tu `seed.js`, que a primera vista parecería lo natural: **veinticinco pacientes no tienen deriva de esquema**. No pueden tenerla. Los generó un solo programa, una sola vez, con una sola versión del modelo. La deriva necesita años y equipos distintos, y eso hay que fabricarlo a propósito.

---

## 2. Por qué un dataset aleatorio arruina una prueba

Esta es la sección que justifica el apéndice entero, y la lección vale mucho más allá de MongoDB.

Un generador de datos falsos —un *faker*— es una herramienta excelente **para cargar y para medir**, y una herramienta pésima **para afirmar**. La diferencia está en si alguien va a comparar el resultado contra un número esperado.

```javascript
// MAL. Este test pasa hoy, falla el martes, y nadie sabe por qué.
var patients = generatePatients(100);   // nombres, correos y fechas al azar
insert(patients);
expect(countWithoutEmail()).toBe(17);      // 17 hoy. Mañana 12. El jueves 23.
```

Lo que ocurre después es siempre igual y es peor de lo que parece: alguien "arregla" el test cambiando el número esperado por un rango, después por un `> 0`, y en tres meses el test no comprueba nada y sigue en verde. **Un test que no puede fallar es peor que no tener test**, porque ocupa el sitio del que sí habría fallado.

El mismo problema, en una medición de `be02`:

> *"La colección tiene cinco formas de documento de paciente."*

Si el volcado fuera aleatorio, esa frase no significaría nada: tendría cinco formas hoy y seis mañana, y el alumno no podría saber si midió bien o midió mal. **Un ejercicio de medición sobre datos cuya respuesta nadie conoce no enseña a medir: enseña a creerse el primer número que sale.**

> 🧭 **La regla, en una línea:** *un dato generado puede ser arbitrario, pero tiene que ser el mismo arbitrario todas las veces.* Semilla fija, generador propio, y el resultado esperado escrito al lado.

Dónde sí vale lo aleatorio, para no tirar el bebé con el agua: **pruebas de propiedades** (generar mil casos y comprobar que se cumple un invariante, sin importar cuáles) y **pruebas de carga** (donde lo que importa es el volumen y no el contenido). En las dos, el criterio de éxito no es un número concreto.

---

## 3. El generador determinista

```javascript
// dump/generate-dump.js
// Genera el volcado sintético "de producción" de be02: seis años de deriva
// de esquema, fabricados a propósito y reproducibles byte a byte.
//
// Se corre con el Node del track base (12 o 14, ver A03):
//   node dump/generate-dump.js
//
// Escribe dump/patients.json, orders.json, samples.json, results.json y
// referenceRanges.json, listos para mongoimport --jsonArray.
'use strict';

var fs = require('fs');
var path = require('path');

// ---------------------------------------------------------------------------
// LA SEMILLA. Es lo más importante del archivo y por eso está arriba del todo.
//
// Mismo generador congruencial que el seed.js del track base, con la misma
// semilla: 20190902, la fecha de puesta en producción de LabCore. Cambiarla
// cambia TODOS los números de be02, be05 y be06, y con ellos media docena de
// tablas del material. Si alguna vez hay que tocarla, hay que rehacer las
// mediciones y las tablas a la vez.
// ---------------------------------------------------------------------------
var seed = 20190902;
function random() {
  seed = (seed * 9301 + 49297) % 233280;
  return seed / 233280;
}
function pick(list) { return list[Math.floor(random() * list.length)]; }
function pad(v, n) { var s = String(v); while (s.length < n) { s = '0' + s; } return s; }

// Las cinco poblaciones, con su recuento exacto. Estas cinco líneas SON el
// contrato del volcado: cualquier medición del track se deriva de aquí.
var SHAPES = [
  { id: 'A', n: 2379 },   // la actual
  { id: 'B', n:  747 },   // 2019, sin "active"
  { id: 'C', n:  718 },   // importación de 2020: "name", sin correo
  { id: 'D', n:  912 },   // 2021: correo en "contact", birthDate como Date
  { id: 'E', n:   64 }    // el intento previo, con "phone" arriba
];

// De los que SÍ tienen la clave "email" (formas A, B y E = 3190), estos son
// los dos tipos de vacío. El resto lleva un correo de verdad.
var EMAIL_NULL = 906;     // el campo existe y vale null
var EMAIL_EMPTY = 247;    // el campo existe y vale ""

var FIRST_NAMES = ['Marcela', 'Julian', 'Deisy', 'Andres', 'Paola', 'Ricardo', 'Luz', 'Camilo'];
var LAST_NAMES = ['Rios', 'Prada', 'Cardenas', 'Beltran', 'Osorio', 'Quintero', 'Salazar'];

function randomFullName() { return pick(FIRST_NAMES) + ' ' + pick(LAST_NAMES); }

function randomBirthDate() {
  return (1950 + Math.floor(random() * 55)) + '-' +
         pad(1 + Math.floor(random() * 12), 2) + '-' +
         pad(1 + Math.floor(random() * 28), 2);
}

function buildPatients() {
  var patients = [];
  var legacyId = 1;

  // Se decide de antemano a QUIÉN le toca cada tipo de vacío, en vez de
  // sortearlo documento a documento. Sorteando, el recuento final saldría
  // "aproximadamente 906" y la medición de be02 dejaría de ser exacta.
  var withEmail = SHAPES[0].n + SHAPES[1].n + SHAPES[4].n;   // A + B + E = 3190
  var emptyKinds = {};
  for (var k = 0; k < EMAIL_NULL; k++)  { emptyKinds[k] = null; }
  for (var k2 = EMAIL_NULL; k2 < EMAIL_NULL + EMAIL_EMPTY; k2++) { emptyKinds[k2] = ''; }
  var emailIndex = 0;

  SHAPES.forEach(function (shape) {
    for (var i = 0; i < shape.n; i++) {
      var base = {
        legacyId: legacyId++,
        documentId: 'CC-10' + pad(Math.floor(random() * 99999999), 8)
      };

      // --- Forma C: la importación de 2020 -------------------------------
      // "name" en vez de "fullName" porque el sistema de origen lo llamaba
      // así y nadie tradujo el campo. Y SIN correo: el sistema de origen no
      // lo capturaba. Son los dos hallazgos que be02 encuentra primero.
      if (shape.id === 'C') {
        base.name = randomFullName();
        base.birthDate = randomBirthDate();
        base._source = 'legacy-import';
        patients.push(base);
        continue;
      }

      base.fullName = randomFullName();

      // --- Forma D: el cambio de 2021 ------------------------------------
      // Dos cosas a la vez y solo una declarada: el correo baja a un
      // subdocumento, y birthDate pasa a guardarse como BSON Date. La
      // notación {"$date": ...} es JSON extendido y mongoimport la entiende.
      if (shape.id === 'D') {
        base.birthDate = { '$date': randomBirthDate() + 'T00:00:00Z' };
        base.contact = { email: 'paciente' + base.legacyId + '@example.com', phone: null };
        base.active = true;
        patients.push(base);
        continue;
      }

      base.birthDate = randomBirthDate();

      // --- Formas A, B y E: las que tienen "email" al nivel superior -----
      var emptyKind = emptyKinds[emailIndex++];
      if (emptyKind === null) {
        base.email = null;
      } else if (emptyKind === '') {
        base.email = '';
      } else {
        base.email = 'paciente' + base.legacyId + '@example.com';
      }

      if (shape.id === 'E') { base.phone = '30' + pad(Math.floor(random() * 99999999), 8); }
      if (shape.id !== 'B') { base.active = true; }   // la B es anterior a la baja lógica

      patients.push(base);
    }
  });

  return patients;
}
```

**Detalles con intención**

- **La semilla y los recuentos están en las primeras treinta líneas.** Es deliberado: son el contrato del volcado, y quien abra este archivo buscando "de dónde salen los 912" tiene que encontrarlo sin leer nada más.
- **El reparto de los vacíos se decide antes, no se sortea.** Sorteando con probabilidad `0,28` saldrían "unos 900", y entonces el ejercicio de `be02` —confirmar que `1630 + 906 = 2536`— dejaría de tener una respuesta comprobable.
- **`legacyId` y no `id`.** El identificador entero del contrato se llama así desde `be03`; usar `id` aquí obligaría a traducirlo al importar.
- **La forma D mete dos cambios a la vez** —el correo y el tipo de la fecha— porque eso es lo que pasó de verdad en 2021 y es lo que hace que `be02` §5.4 tenga material. Un generador que hiciera un cambio por forma sería más limpio y enseñaría menos.

---

## 4. Las cinco formas del documento de paciente

La tabla de referencia, que es la respuesta del ejercicio central de `be02`. **Está aquí a propósito**: un apéndice de consulta puede tener la solución, porque quien lo abre ya midió o ya se rindió.

| Forma | Claves (sin `_id`) | Documentos | Época |
|---|---|---|---|
| **A** | `documentId, fullName, birthDate, email, active` | 2.379 | La actual |
| **B** | `documentId, fullName, birthDate, email` | 747 | 2019, antes de la baja lógica |
| **C** | `documentId, name, birthDate, _source` | 718 | La importación de 2020 |
| **D** | `documentId, fullName, birthDate, contact, active` | 912 | 2021, correo embebido y fecha como `Date` |
| **E** | `documentId, fullName, birthDate, email, phone, active` | 64 | El intento previo del cambio de 2021 |

Y los demás generadores, en resumen —el código completo sigue el mismo patrón y es el ejercicio 5—:

| Colección | Documentos | Lo que se fabrica a propósito |
|---|---|---|
| `orders` | 4.180 | **37 huérfanas**: su `patientId` apunta a un `legacyId` que no existe. 31 de ellas con `_source: legacy-import` en su rastro, 6 sin él — dos historias distintas |
| `samples` | 6.240 | **23 con la cadena rota**: tienen `processedBy` sin `receivedBy`, o `status: processed` sin `processedAt` |
| `results` | 9.870 | 1.204 de glucosa validados con `rangeVersionApplied: 2` dentro de la ventana de `be06`, de los cuales **37 cambian de veredicto** con los límites de hoy |
| `referenceRanges` | 9 | La v2 de glucosa **ya mutada**, con `high: 99` y su `effectiveFrom` de 2019 intacto. El `$set` de 2020 ya ocurrió: el volcado es el después, no el antes |

> 🧠 **Esa última fila es la más importante del apéndice y la más fácil de pasar por alto.** El volcado no contiene la historia perdida de `be06` — **no puede contenerla**, porque el punto de esa fase es que no existe en ninguna parte. El generador escribe directamente el estado posterior al `$set`. Si algún día alguien "mejora" el generador para que guarde también la versión anterior, `be06` deja de tener sentido.

---

## 5. Los números que el volcado tiene que producir

Todos los que el material cita, en una tabla. Si tu volcado no da estos números, algo se movió.

| Medición | Valor | Dónde se usa |
|---|---|---|
| Pacientes totales | 4.820 | be02 §5.2 |
| Claves `fullName` | 4.102 | be02 §5.2 |
| Claves `active` | 3.355 | be02 §5.2 |
| Claves `email` | 3.190 | be02 §5.2 |
| Claves `contact` / `name` / `_source` / `phone` | 912 / 718 / 718 / 64 | be02 §5.2 |
| Formas distintas | **5** | be02 §5.3 |
| `birthDate` como `string` / `date` | 3.908 / 912 | be02 §5.4 |
| `email` ausente / `null` / cadena vacía | 1.630 / 906 / 247 | be02 §5.6 |
| `{ email: null }` devuelve | 2.536 | be02 §5.6 |
| Respuesta correcta a "sin correo utilizable" | 2.783 | be02 §5.6 |
| Órdenes huérfanas | 37 sobre 4.180 | be02 §5.5 |
| Muestras con eslabón huérfano | 23 | be05 §5.4 |
| Órdenes que se quedaron atrás | 9 | be05 §5.4 |
| Resultados en la ventana de rangos | 1.204 | be06 §5.2 |
| Veredictos que cambian | 37 | be06 §5.3 |
| Documentos que un `$jsonSchema` obvio rechazaría | 1.630 | be08 §5.2 |

> 💡 Las tres coincidencias numéricas —37 huérfanas, 37 veredictos, 1.630 en dos filas distintas— son casualidad del generador y **no significan nada**. Se dicen aquí para que nadie construya una hipótesis sobre ellas: es exactamente el tipo de patrón falso que aparece cuando se miran muchos números juntos.

---

## 6. `verify-dump.sh`: el volcado se verifica, no se cree

```bash
#!/usr/bin/env bash
# verify-dump.sh — Comprueba que el volcado cargado produce los números que
# el material cita. Se corre DESPUÉS de mongoimport y ANTES de empezar a
# medir: si esto sale en rojo, cualquier medición posterior es ruido.
#
#   uso: ./verify-dump.sh [mongo|mongosh]
set -u
SHELL_BIN="${1:-mongosh}"
DB=labcore_prod_sample
FAIL=0

check() {   # etiqueta · esperado · consulta
  local actual
  actual=$(docker compose exec -T db "$SHELL_BIN" "$DB" --quiet --eval "$3" | tr -d '\r\n ')
  if [ "$actual" = "$2" ]; then
    echo "  ok   $1 = $2"
  else
    echo "  FALLA $1 — esperaba $2, salió $actual"; FAIL=$((FAIL+1))
  fi
}

echo "== Verificación del volcado sintético =="
check "pacientes"          4820 'db.patients.countDocuments()'
check "con fullName"       4102 'db.patients.countDocuments({fullName:{$exists:true}})'
check "con active"         3355 'db.patients.countDocuments({active:{$exists:true}})'
check "con email"          3190 'db.patients.countDocuments({email:{$exists:true}})'
check "con contact"         912 'db.patients.countDocuments({contact:{$exists:true}})'
check "con name"            718 'db.patients.countDocuments({name:{$exists:true}})'
check "birthDate string"   3908 'db.patients.countDocuments({birthDate:{$type:"string"}})'
check "birthDate date"      912 'db.patients.countDocuments({birthDate:{$type:"date"}})'
check "email ausente"      1630 'db.patients.countDocuments({email:{$exists:false}})'
check "email null"          906 'db.patients.countDocuments({email:{$type:"null"}})'
check "email vacío"         247 'db.patients.countDocuments({email:""})'
check "órdenes"            4180 'db.orders.countDocuments()'

echo
echo "== $FAIL en rojo =="
[ "$FAIL" -eq 0 ] || exit 1
```

> 🧭 **Es el mismo movimiento que `smoke.sh` hace con el contrato, aplicado a los datos.** Y tiene el mismo valor: cuando una medición de `be02` te dé un número raro, la primera pregunta deja de ser *"¿estará mal mi agregación?"* y pasa a ser *"¿está bien cargado el volcado?"* — que se contesta en diez segundos en vez de en media hora.

Y el flujo completo, de principio a fin:

```bash
node dump/generate-dump.js                      # genera los cinco .json
for c in patients orders samples results referenceRanges; do
  docker compose exec -T db mongoimport \
    --db labcore_prod_sample --collection "$c" --drop --jsonArray < "dump/$c.json"
done
./verify-dump.sh mongosh                        # y solo entonces, a medir
```

---

## 7. Volumen: cuando hace falta medir de verdad

El volcado de 4.820 pacientes sirve para medir **formas**, no para medir **rendimiento**. Con ese tamaño, el `COLLSCAN` de `be02` tarda doce milisegundos y no duele; ese es justamente el punto pedagógico de esa fase, y también su límite.

Para los ejercicios de escalado —el 26 de `be02`, el 22 de `be07`— hace falta multiplicar:

```bash
# Multiplicar x10 conservando las proporciones: se importa el mismo volcado
# diez veces, desplazando el legacyId en cada pasada para no chocar con el
# índice único de be03.
for i in $(seq 0 9); do
  node dump/generate-dump.js --offset $((i * 10000)) --out "dump/x$i"
  docker compose exec -T db mongoimport --db labcore_volumen \
    --collection patients --jsonArray < "dump/x$i/patients.json"
done
```

Tres cosas que hay que tener presentes al medir sobre volumen, y las tres se olvidan:

1. **Una base desechable, nunca la del track.** `labcore_volumen`, y se borra al terminar. Diez veces el volcado dentro de `labcore_prod_sample` invalida todas las mediciones de `be02` en el momento.
2. **Las proporciones se conservan, los valores absolutos no.** Con diez copias hay diez veces más huérfanas y diez veces más formas, pero los porcentajes son idénticos. Para rendimiento sirve; para citar un número en un informe, no.
3. **El multiplicador tiene que estar escrito al lado de la medida.** *"La consulta tarda 1,2 s"* no significa nada sin *"sobre 48.200 pacientes, que son diez veces el volcado"*.

---

## 🧭 Cuándo usar qué

| Situación | Fuente | Base |
|---|---|---|
| Usar la aplicación, probar el contrato, `smoke.sh` | tu `db.json` | `labcore` |
| Medir deriva de esquema, referencias rotas, los tres `null` | el volcado sucio | `labcore_prod_sample` |
| Medir cadenas de custodia rotas (`be05`) | el volcado sucio | `labcore_prod_sample` |
| Medir rendimiento, planes, escalado | volumen ×10 | `labcore_volumen`, desechable |
| Escribir una prueba con un número esperado | **cualquiera, con semilla fija** | — |
| Escribir una prueba de propiedades o de carga | aleatorio, sin problema | — |

---

## ⚠️ Advertencias

**Los datos generados nunca entran a una colección que `smoke.sh` audite.** Es la advertencia más dura del apéndice. `smoke.sh` afirma cosas sobre el contenido de `labcore` —que `/patients/1` existe, que el arreglo no está vacío—, y si alguien carga el volcado sucio ahí, el guion empieza a pasar o a fallar por motivos que no tienen nada que ver con el contrato. **En cuanto eso ocurre, el contrato deja de ser verificable**, que es la única cosa que el track no se puede permitir perder.

**Cambiar la semilla cambia el material.** Los treinta y tantos números de la tabla de arriba están citados en `be02`, `be05`, `be06` y `be08`. Tocar `seed = 20190902` los invalida todos a la vez y en silencio. Si de verdad hace falta, hay que rehacer las mediciones y las tablas en la misma sesión.

**El volcado es sintético, y eso se declara en `MEASUREMENTS.md`.** No es una limitación del ejercicio: es lo que hace que el ejercicio enseñe. Sobre datos reales nadie sabe la respuesta, así que medir mal y medir bien se parecen demasiado. Aquí hay cinco formas porque el generador escribió cinco, y si mides seis, mediste mal.

**Y lo que no se hace, dicho claro:** traerse un volcado de producción con datos de pacientes reales a un portátil. Es un dominio regulado, hay normativa de protección de datos de salud, y la anonimización bien hecha es un proyecto en sí mismo —no basta con cambiar los nombres: una fecha de nacimiento, un código de examen y una sede reidentifican a una persona con una facilidad que sorprende—. Si en tu trabajo se plantea, **eso lo decide cumplimiento y queda por escrito**. Este apéndice no da receta a propósito.

---

## 📚 Referencias

- `mongoimport` y sus modos (`--jsonArray`, `--drop`, `--upsert`): https://www.mongodb.com/docs/database-tools/mongoimport/
- JSON extendido de MongoDB, que es lo que hace posible el `{"$date": …}` de la forma D: https://www.mongodb.com/docs/manual/reference/mongodb-extended-json/
- `mongodump` / `mongorestore`, la alternativa binaria a los `.json`, más rápida y menos inspeccionable: https://www.mongodb.com/docs/database-tools/mongodump/
- John Hughes, *QuickCheck* y las pruebas basadas en propiedades: https://dl.acm.org/doi/10.1145/351240.351266 — es el caso en el que lo aleatorio **sí** es la herramienta correcta, y saber distinguirlo es la mitad de este apéndice.
- Sobre generadores congruenciales lineales y por qué uno de dos líneas basta para esto: https://en.wikipedia.org/wiki/Linear_congruential_generator ⚠️ No sirven para criptografía, y aquí no hace falta que sirvan.

> ⚠️ URLs y contenidos cambian; verifícalos.

---

## 🧪 Ejercicios (8)

1. Corre `generate-dump.js`, impórtalo a `labcore_prod_sample` y pásale `verify-dump.sh`. Todo en verde antes de hacer nada más.
2. Corre el generador dos veces y compara los archivos con `diff`. Tienen que ser idénticos byte a byte. Si no lo son, hay una fuente de aleatoriedad que se escapó: encuéntrala.
3. Cambia la semilla a `20190903`, regenera, y corre `verify-dump.sh`. Anota cuántas afirmaciones caen y cuáles no. Explica por qué algunas sobreviven.
4. Sustituye el reparto fijo de vacíos por un sorteo con probabilidad equivalente, regenera diez veces y anota los diez recuentos de `email: null`. Con esos diez números, escribe por qué el reparto fijo no es una manía.
5. Escribe el generador de `orders` con sus 37 huérfanas, repartidas 31 con `_source: legacy-import` y 6 sin él. Verifica con la agregación de `be02` §5.5.
6. **Diagnóstico.** Carga el volcado sucio en `labcore` —la base de la aplicación— a propósito. Corre `smoke.sh` y anota qué falla y qué pasa aunque no debería. Después limpia y vuelve a sembrar desde tu `db.json`.
7. Multiplica el volcado ×10 en una base desechable y repite el `explain()` de `be02` §5.7. Anota los cuatro números y compáralos con los originales.
8. **Diagnóstico.** Alguien "mejoró" el generador para que `referenceRanges` conserve también la versión anterior al `$set` de 2020. Aplica ese cambio y después lee `be06` §5.1. Explica en tres líneas qué fase acabas de destruir y por qué.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y lo que describe —`generate-dump.js` y `verify-dump.sh`— lo pone en marcha **be02**, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be02: …`, `be05: …`). Los dos guiones **sí se versionan**, y esa es la única forma de que el volcado siga siendo reproducible dentro de seis meses: un dato determinista cuyo generador no está en el repositorio no es determinista, es una coincidencia. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.
