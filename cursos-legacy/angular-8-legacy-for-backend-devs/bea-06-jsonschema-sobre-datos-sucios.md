# 📎 Apéndice bea-06 — `$jsonSchema` sobre datos sucios

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Consulta rápida · **3 horas**
> Usado por: be08 · Versiones cubiertas: MongoDB 4.0 y 7.0

**Esto no se lee de corrido.** Se entra con una colección que lleva años sin validación y la intención de ponerle una, y se sale con el procedimiento para hacerlo sin tumbar producción.

Resuelve una cosa: **poner validación sobre una colección que lleva siete años sin ninguna, sin romper el sistema mañana.**

> 🧭 **El ángulo, y conviene tenerlo claro antes de escribir una línea:** el problema no es escribir el esquema. Escribir el esquema son veinte minutos. El problema es que **un tercio de los documentos que ya están guardados no lo cumplen**, y el sistema tiene que seguir funcionando el lunes.

**Qué queda fuera:** migrar o limpiar los datos sucios. En un sistema regulado lo roto no se sobrescribe: se compensa. Esa es la doctrina de [`be05`](./be05-la-cadena-de-custodia-y-la-transaccion.md) §4.4, aquí se respeta y no se contradice. Este apéndice enseña a **poner una barrera hacia adelante**, no a reescribir el pasado.

---

## Índice

- [1. El número primero, el esquema después](#1-el-número-primero-el-esquema-después)
- [2. La sintaxis mínima](#2-la-sintaxis-mínima)
- [3. Los dos ejes: nivel y acción](#3-los-dos-ejes-nivel-y-acción)
- [4. El procedimiento de subida por escalones](#4-el-procedimiento-de-subida-por-escalones)
- [5. Qué le pasa a un documento viejo bajo `moderate`](#5-qué-le-pasa-a-un-documento-viejo-bajo-moderate)
- [6. Convivir con excepciones declaradas](#6-convivir-con-excepciones-declaradas)
- [7. ⚠️ El mensaje de error de 4.0, que no dice nada](#7-️-el-mensaje-de-error-de-40-que-no-dice-nada)
- [8. Lo que `$jsonSchema` **no** puede hacer](#8-lo-que-jsonschema-no-puede-hacer)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-7)

---

## 1. El número primero, el esquema después

La regla que ordena el apéndice entero, y es lo contrario de lo que hace casi todo el mundo:

> 🧭 **Antes de aplicar nada, escribe el esquema como una consulta y cuenta cuántos documentos no lo cumplirían.** Ese número decide si el esquema es aplicable o si hay que aflojarlo.

```javascript
// El esquema "obvio" de paciente, escrito como consulta. Todavía no toca la
// base: solo pregunta cuántos documentos se quedarían fuera.
db.patients.count({ $or: [
  { documentId: { $exists: false } },
  { documentId: { $not: { $type: 'string' } } },
  { fullName:   { $exists: false } },
  { birthDate:  { $not: { $type: 'string' } } }
]});
```

```
1630
```

Mil seiscientos treinta sobre 4.820: **un tercio de la colección**. Son las formas **C** y **D** que midió `be02` —718 sin `fullName`, 912 con `birthDate` de tipo `date`—, y con ese número delante la conversación cambia por completo: el esquema obvio no es aplicable, y no porque esté mal escrito.

> 🧠 **Por qué este paso no se puede sustituir por "aplicar en `warn` y mirar el log":** el log de `warn` solo registra lo que se **escribe**. Los documentos viejos que nadie actualiza **no aparecen nunca** — y son exactamente los que van a reventar el día que subas el nivel a `error`. Un mes de logs limpios sobre una colección con un tercio de documentos incompatibles da una falsa sensación de seguridad perfecta.
>
> El log de `warn` te dice si el **código nuevo** cumple. La consulta de arriba te dice si los **datos viejos** cumplen. Son dos preguntas distintas y hacen falta las dos.

---

## 2. La sintaxis mínima

`$jsonSchema` es un subconjunto de JSON Schema con tipos BSON. Lo que se usa el 95 % de las veces:

```javascript
db.runCommand({
  collMod: 'patients',
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['documentId'],
      properties: {
        documentId: {
          bsonType: 'string',
          pattern: '^(CC|TI|CE)-[0-9]+$',
          description: 'documento de identidad con su prefijo'
        },
        // Un arreglo de tipos: el campo puede ser CUALQUIERA de ellos.
        // Feo y honesto: describe lo que hay, no lo que querríamos.
        birthDate: { bsonType: ['string', 'date'] },
        active: { bsonType: ['bool', 'null'] },
        email: { bsonType: ['string', 'null'] },
        contact: {
          bsonType: 'object',
          properties: { email: { bsonType: ['string', 'null'] } }
        }
      }
      // additionalProperties NO se pone. Por defecto es true, y eso es lo
      // que queremos: el régimen de crecimiento de CONTRACT.md depende de
      // que un campo nuevo no rompa nada.
    }
  },
  validationAction: 'warn',
  validationLevel: 'moderate'
});
```

Las palabras clave que valen la pena, y su equivalente mental:

| Palabra | Qué hace | Equivalente en SQL |
|---|---|---|
| `bsonType` | Tipo, o lista de tipos aceptados | El tipo de la columna |
| `required` | Campos obligatorios | `NOT NULL` |
| `properties` | Reglas por campo | La definición de columnas |
| `enum` | Valores permitidos | `CHECK (x IN (…))` |
| `pattern` | Expresión regular | `CHECK (x ~ '…')` |
| `minimum` / `maximum` | Rango numérico | `CHECK (x BETWEEN …)` |
| `additionalProperties: false` | Prohíbe campos no declarados | No tiene equivalente, y **casi nunca se quiere** |

> ⚠️ **`required` con un campo que no está en `properties` sigue siendo obligatorio**, y al revés: declarar un campo en `properties` **no** lo hace obligatorio. Son dos listas independientes y confundirlas es el error de sintaxis más común.

```javascript
// El enum que sí vale la pena en LabCore, porque los estados son un
// contrato compartido con el frontend y equivocarse ahí es un bug real:
status: { enum: ['pending', 'in_process', 'partial_results',
                 'complete', 'delivered', 'expired'] }
```

---

## 3. Los dos ejes: nivel y acción

Son **dos cosas distintas** y todo el mundo las confunde. Una dice **a qué documentos** se aplica la regla; la otra, **qué pasa** cuando no se cumple.

**`validationLevel` — a quién se aplica:**

| Valor | A qué documentos |
|---|---|
| `off` | A ninguno. La validación existe y no se ejecuta |
| `moderate` | A los `insert`, y a los `update` de documentos **que ya cumplían** |
| `strict` (por defecto) | A todos los `insert` y a **todos** los `update` |

**`validationAction` — qué pasa si falla:**

| Valor | Qué ocurre |
|---|---|
| `warn` | Se **registra en el log del servidor** y la escritura se aplica |
| `error` (por defecto) | La escritura **se rechaza** |

Y la matriz completa, que es lo que conviene tener a mano:

| | `warn` | `error` |
|---|---|---|
| **`off`** | nada | nada |
| **`moderate`** | ⬅️ **Aquí se empieza siempre** | Los viejos se pueden seguir tocando; los nuevos y los sanos, no |
| **`strict`** | Registra todo, no rompe nada | ⬅️ **El destino**, si se llega |

> 🧠 **La combinación `moderate` + `warn` es la que permite aplicar validación un martes por la tarde sin avisar a nadie**, porque no rechaza nada y deja en paz a los documentos incompatibles. Y `strict` + `error` es la que hay que llegar a poder poner algún día. **Todo el trabajo está en el camino entre las dos.**

⚠️ **Y ojo con los valores por defecto:** si aplicas un `validator` sin decir nada más, estás poniendo `strict` + `error`. Es decir, la combinación más agresiva posible. Los dos campos **siempre** se escriben explícitamente.

---

## 4. El procedimiento de subida por escalones

Cinco pasos. Saltarse el primero es el incidente `be-12`.

**1. Medir cuánto rechazaría.** El §1. Con el número delante, no antes.

**2. Decidir qué se tolera, por hallazgo y con la razón escrita.** No "hasta que pase todo": cada tolerancia es una línea con su motivo.

```markdown
| Regla aflojada | Por qué | ¿Se revisa? |
|---|---|---|
| `fullName` fuera de `required` | 718 documentos de la importación de 2020 no lo tienen y **nunca lo van a tener**. Exigirlo bloquea su mantenimiento sin recuperar el dato | No |
| `birthDate` admite `string` y `date` | Las dos poblaciones existen (be02 §5.4). Un esquema que mintiera sobre eso no protegería nada | Si alguna vez se normalizan |
| `email` admite `null` | 906 documentos lo tienen así explícitamente | No |
```

**3. Aplicar en `moderate` + `warn`.** Nada se rompe. Desde este momento, cada escritura que viole el esquema deja una línea en el log del servidor.

**4. Observar el log el tiempo suficiente, con un criterio escrito de antemano.**

```bash
# Los avisos de validación en el log de mongod:
docker compose logs db | grep -i 'validation'
```

> 🧭 **El criterio se escribe antes de empezar a observar, no después.** *"Se sube a `error` cuando pasen treinta días sin un solo aviso nuevo."* Sin esa frase escrita, la subida se decide por corazonada un viernes, que es exactamente cómo empieza `be-12`.

**5. Subir a `error`, una colección cada vez.** Nunca las cinco a la vez: si algo se rompe, quieres saber cuál.

```javascript
db.runCommand({ collMod: 'patients', validationAction: 'error' });
// Y el nivel se queda en 'moderate' bastante más tiempo del que la gente
// espera. Pasar a 'strict' significa que los 1.630 documentos antiguos ya
// no se pueden actualizar, y eso es una decisión de producto, no técnica.
```

---

## 5. Qué le pasa a un documento viejo bajo `moderate`

Es la pregunta que decide si puedes aplicar esto hoy, y la respuesta merece verse en detalle.

Con `validationLevel: 'moderate'`, MongoDB comprueba, **antes de aplicar un `update`**, si el documento tal como está **ya cumplía** el esquema:

- **Cumplía** → se valida el resultado. Si el cambio lo rompe, se rechaza (o se avisa, según la acción).
- **No cumplía** → **queda exento**. El `update` se aplica sin validar.

```javascript
// Un paciente de la forma C, sin fullName. No cumple el esquema.
// Bajo moderate, esto funciona:
db.patients.updateOne({ legacyId: 3001 }, { $set: { active: false } });
// La baja lógica de un paciente de 2020 sigue funcionando. Que es justo lo
// que Recepción necesita que siga funcionando.

// Bajo strict, esto se rechaza, y Recepción llama por teléfono.
```

> 💡 **Esa exención es el mecanismo que hace posible todo lo demás**, y tiene un efecto secundario elegante: un documento viejo que alguien actualice **añadiéndole** el campo que faltaba pasa a cumplir, y desde entonces ya se valida. **La colección se limpia sola al ritmo al que se usa**, sin migración y sin un `$set` masivo. Es lo más parecido a arreglar el pasado que este apéndice admite, y lo admite porque lo hace el uso normal del sistema y queda registrado como cualquier otra escritura.

---

## 6. Convivir con excepciones declaradas

Un esquema que tolera todo no protege nada; uno que no tolera nada no se puede aplicar. El punto medio es **tolerar con nombre y fecha**.

Tres formas, de mejor a peor:

**1. Aflojar la regla y documentar la razón** (el §4, paso 2). Es lo que hace `be08`. El esquema describe lo que hay, la tabla de tolerancias dice por qué, y las dos cosas viven juntas.

**2. Segmentar con `$or`**, cuando las dos poblaciones son legítimas y distinguibles:

```javascript
// Un documento es válido si tiene fullName, O si viene de la importación de
// 2020 y tiene name. Las dos formas son aceptables por razones distintas.
validator: {
  $or: [
    { $jsonSchema: { required: ['documentId', 'fullName'] } },
    { $jsonSchema: { required: ['documentId', 'name', '_source'] } }
  ]
}
```

Es más honesto que un `required` corto —dice que hay dos formas legítimas— y es más frágil: cada forma nueva es otra rama. Sirve cuando las poblaciones son dos o tres y están cerradas.

**3. Dejar el campo fuera del esquema.** La peor, porque el esquema deja de decir nada sobre él y nadie recuerda si fue deliberado. Si se hace, va con un `description` explicando la ausencia.

> ⚠️ **Y la regla que evita que el esquema se degrade con el tiempo:** *cada tolerancia lleva un motivo y una condición de revisión.* Sin eso, en dos años el esquema es un objeto que acepta cualquier cosa, nadie sabe por qué, y quitarle una tolerancia da miedo porque nadie sabe qué protegía. Es la misma degradación que sufre un test al que le van quitando aserciones.

---

## 7. ⚠️ El mensaje de error de 4.0, que no dice nada

Esto es lo que más tiempo hace perder y hay que saberlo antes de empezar.

```javascript
// En mongo:4.0, una escritura que viola el esquema devuelve esto:
{ "ok": 0, "errmsg": "Document failed validation", "code": 121 }
```

**Y ya está.** No dice qué campo falló, ni qué regla, ni qué valor. Con un esquema de veinte propiedades, eso es una búsqueda a mano.

Las dos formas de sobrevivir:

```javascript
// 1. Convertir el esquema en consulta y buscar el culpable. Es el mismo
//    truco del §1, aplicado a un documento concreto.
db.patients.find({ legacyId: 3001, $nor: [ { $jsonSchema: { …el esquema… } } ] });
// Si devuelve el documento, ese documento es el que no cumple. Después se
// va quitando reglas del esquema hasta encontrar cuál.

// 2. Empezar por esquemas PEQUEÑOS. Un validador con tres reglas da un
//    error igual de mudo, pero con tres sospechosos en vez de veinte.
```

> 🧠 **Y aquí hay una de las pocas buenas noticias de `be07`:** desde **MongoDB 5.0**, el error de validación es detallado — dice qué campo, qué regla y qué valor. Así que la base de LabCore, después de subir a 7.0, **da mensajes mucho mejores que la de 2019**. Es el ejemplo más claro del track de que los cuatro saltos mayores trajeron cosas buenas que nadie aprovechó: el sistema lleva años con una capacidad de diagnóstico que no usa porque nunca hubo un validador que la ejerciera.

---

## 8. Lo que `$jsonSchema` **no** puede hacer

Sus límites, que son los que deciden qué se valida en la base y qué se valida en la aplicación.

| No puede | Ejemplo de LabCore | Dónde se resuelve |
|---|---|---|
| **Comparar con el estado anterior** | "el `high` de una versión de rango no se puede cambiar" | La guarda de `be06` §5.6, **en la aplicación** |
| **Comparar con otra colección** | "el `patientId` tiene que existir" | El detector de `be05`, o un índice… que tampoco existe aquí |
| **Validar una transición de estado** | `pending → complete` sin pasar por en medio | El reducer del frontend y el service |
| **Dar un mensaje propio** | "el documento tiene que llevar prefijo" | Se valida en la aplicación si el mensaje importa |
| **Comparar dos campos del documento** | `effectiveTo > effectiveFrom` | ⚠️ Esto **sí**, con `$expr`, pero no con `$jsonSchema` |

```javascript
// El validador admite operadores de consulta además de $jsonSchema, así que
// dos campos del MISMO documento sí se pueden comparar:
validator: {
  $and: [
    { $jsonSchema: { … } },
    { $expr: { $or: [ { $eq: ['$effectiveTo', null] },
                      { $gt: ['$effectiveTo', '$effectiveFrom'] } ] } }
  ]
}
```

> 🧭 **La regla que reparte el trabajo:** *la base valida la **forma** de un documento; la aplicación valida las **transiciones** entre estados.* Lo que hay que prohibir en `be06` —que los valores de una versión cambien— es una transición, no una forma, y por eso ninguna cantidad de `$jsonSchema` lo habría impedido. Ahí lo que hace falta es una guarda en el código y, sobre todo, **quitar el permiso de `update`** (`be08` §5.4), que es la única prevención de verdad.

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer |
|---|---|
| Colección nueva, datos limpios | `strict` + `error` desde el primer día. Es gratis |
| Colección con años y sin validación | `moderate` + `warn`, **después de medir** |
| Quiero saber si puedo endurecer | El esquema como consulta y un `count()` |
| El log de `warn` lleva meses limpio | Subir a `error`, una colección cada vez |
| Un tercio de los documentos no cumple | Aflojar el esquema **con la razón escrita**, no forzar |
| Dos formas legítimas conviviendo | `$or` de dos `$jsonSchema` |
| Comparar dos campos del documento | `$expr` en el validador, junto al `$jsonSchema` |
| Comparar con el estado anterior | **No es aquí.** Guarda en la aplicación + permisos |
| El error no dice qué falló | Estás en 4.0. Esquemas pequeños, o subir de versión |
| Campos nuevos que el servidor añade | **No** pongas `additionalProperties: false` |

---

## ⚠️ Advertencias

**Los valores por defecto son los agresivos.** Un `validator` aplicado sin `validationLevel` ni `validationAction` es `strict` + `error`. Los dos se escriben siempre, explícitamente, aunque coincidan con el defecto.

**La validación no se aplica a los documentos existentes hasta que alguien los toca.** Eso es una ventaja —permite aplicar el esquema sin migración— y una trampa: **una colección con validación `strict` + `error` puede estar llena de documentos que no la cumplen**, y nadie se entera hasta que alguien intenta actualizarlos. El estado de la colección y el estado del validador son dos cosas distintas.

**`additionalProperties: false` rompe el régimen de crecimiento.** `CONTRACT.md` declara que el servidor puede añadir campos sin romper nada; un esquema que prohíba campos no declarados convierte cada campo nuevo en un despliegue coordinado. En LabCore no se usa, y en general se usa mucho menos de lo que parece.

**Y la que de verdad importa: un esquema no arregla los datos que ya están.** Es una barrera hacia adelante y nada más. Los 1.630 documentos de las formas C y D siguen ahí después de aplicarlo, y seguirán ahí el día de la decomisión. Lo que el esquema garantiza es que **no habrá 1.631**.

---

## 📚 Referencias

- MongoDB 4.0 — validación de esquema: https://www.mongodb.com/docs/v4.0/core/schema-validation/
- `$jsonSchema`, con la lista completa de palabras clave soportadas: https://www.mongodb.com/docs/v4.0/reference/operator/query/jsonSchema/
- `collMod`, que es como se aplica sobre una colección existente: https://www.mongodb.com/docs/v4.0/reference/command/collMod/
- `$expr` en un validador, para comparar campos del mismo documento: https://www.mongodb.com/docs/v4.0/reference/operator/query/expr/
- Mensajes de error de validación detallados, **desde MongoDB 5.0**: https://www.mongodb.com/docs/manual/core/schema-validation-handle-errors/ ⚠️ Comprueba la versión: en 4.0 no existen.
- Tipos BSON y sus nombres en `bsonType`: https://www.mongodb.com/docs/v4.0/reference/bson-types/
- La especificación de JSON Schema, de la que `$jsonSchema` es un subconjunto (draft 4): https://json-schema.org/specification-links#draft-4
- El patrón de *schema versioning* de MongoDB, que es lo que habría hecho innecesaria media fase `be02`: https://www.mongodb.com/blog/post/building-with-patterns-the-schema-versioning-pattern

> ⚠️ URLs y contenidos cambian; verifícalos. Y con este tema el riesgo es concreto: casi todos los ejemplos que encuentres asumen una versión que da errores detallados, y la de LabCore no.

---

## 🧪 Ejercicios (7)

Todos con **el número de documentos rechazados** como criterio de éxito. Un ejercicio de validación sin ese número no enseña nada.

1. Escribe el esquema "obvio" de `patients` como consulta y cuenta cuántos documentos no lo cumplirían. Confirma que son 1.630 y localiza a qué formas de `be02` corresponden.
2. Aplícalo en `moderate` + `warn` y comprueba que la aplicación sigue funcionando. Da de baja a un paciente de la forma C y confirma que la operación se aplica.
3. Cámbialo a `strict` + `error`, repite la baja del ejercicio 2, y anota el error exacto. Después vuelve a `moderate` + `warn`.
4. Escribe la tabla de tolerancias del §4 paso 2 para `patients`: qué reglas aflojas, por qué, y si se revisan.
5. **Diagnóstico.** Provoca un fallo de validación en `mongo:4.0` y comprueba que el mensaje no dice qué campo falló. Encuentra el culpable con el truco del `$nor` y cronométralo. Después sube la base a 7.0 y repite: anota los dos mensajes lado a lado.
6. Escribe el validador de `referenceRanges` con un `$expr` que exija `effectiveTo > effectiveFrom` o `null`. Comprueba que rechaza una versión con las fechas invertidas. Después intenta escribir con `$jsonSchema` la regla que `be06` de verdad necesitaba —"los límites de una versión no cambian"— y explica en dos líneas por qué no se puede.
7. **Diagnóstico.** Aplica un validador con `additionalProperties: false` sobre `patients` y después haz que el backend añada un campo nuevo a un documento. Anota qué pasa y relaciónalo con el régimen de crecimiento de `CONTRACT.md`.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y los validadores que describe los aplica **be08**, así que lo que salga de leerlo se commitea con el prefijo de esa fase (`be08: …`). El número del ejercicio 1 y la tabla de tolerancias del 4 **no van en un tag**: van en `MEASUREMENTS.md` y en `CONTRACT.md` respectivamente, porque los dos son entregables que `IRRECOVERABLE.md` cita. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.
