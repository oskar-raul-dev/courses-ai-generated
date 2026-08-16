# 🕵️ Forense Fase 07 — "Esta inspección se ve con otra plantilla" ⭐

> Pieza forense de la **Fase 7 — Plantillas versionadas** · Recorrido: ~45 min
> Herramientas: la URL de la petición a `/templates` · `curl` · el `db.json`
> Síntoma que cubre: dos tickets que llegan con las mismas palabras y significan cosas opuestas. Uno **no es un bug** y hay que demostrarlo; el otro es el más grave del sistema.

Ésta es la pieza central del curso. El invariante que protege cabe en una línea —**una inspección guarda su `templateVersion` y se lee siempre con ésa**— y se rompe de seis maneras. Lo notable es que las seis se distinguen **mirando la URL de una petición**, antes de abrir un archivo.

La fase enseña las dos preguntas gemelas. Aquí están los dos tickets literales, con la salida de cada paso.

---

## 🎫 Ticket 1 — el que no es un bug

> *"Abrí la inspección 501 del ascensor de la torre A, la de agosto del año pasado, y el ítem del cable dice 'Estado del cable principal'. En las inspecciones nuevas dice 'Estado y tensión del cable principal'. ¿Está desactualizada?"*

**Reportado por:** coordinador de certificaciones · **Ambiente:** UAT

## 🎫 Ticket 2 — el que sí lo es

> *"La inspección de agosto ahora tiene un ítem más que cuando la hice. Yo respondí tres cosas y ahora aparecen cuatro, y la última está vacía. No la he vuelto a tocar."*

**Reportado por:** inspector de campo · **Ambiente:** UAT

**Las mismas palabras, la conclusión opuesta.** El ticket 1 describe el sistema funcionando; el ticket 2 describe el histórico corrompiéndose. Y quien los escribe no puede saber cuál tiene.

---

## 🧭 La ruta

Los dos tickets comparten los tres primeros pasos. Es lo que los hace eficientes: **una sola investigación contesta las dos preguntas.**

Y el orden de esos pasos es el de siempre, del más barato al más caro: **mirar la URL de una petición cuesta diez segundos y descarta cuatro de las seis causas**, mientras que abrir el servicio de estado y seguir de dónde salió el dato cuesta media hora. Por eso los dos primeros pasos no abren un solo archivo.

### Paso 1 — ¿Qué versión dice la inspección que usó?

Es un **campo guardado**, no un cálculo. Y por eso se puede consultar sin pasar por la aplicación:

```bash
curl -s "http://localhost:3000/inspections/501" -H "Authorization: Bearer <token>" \
  | python3 -m json.tool | head -8
```

```json
{
    "id": 501,
    "assetId": "ASC-CENTRAL-04",
    "inspectorId": "INS-15",
    "templateId": "elevator-annual",
    "templateVersion": 1,
    "status": "approved",
    "startedAt": "2023-08-02T08:30:00-05:00"
}
```

**Qué descarta.** `templateVersion: 1`. A partir de aquí hay **un solo comportamiento correcto**: esa inspección se lee con la v1, hoy y dentro de diez años, aunque la vigente sea la v9. Cualquier otra cosa es el bug. Si este campo faltara o fuera `null`, el problema sería anterior y mucho peor: una inspección sin versión guardada no se puede reconstruir nunca.

### Paso 2 — ⭐ La URL de la petición contesta antes que el código

DevTools → **Network** → filtro `Fetch/XHR` → abre la inspección → busca la petición a `/templates`.

**Éste es el paso que decide toda la investigación**, y son diez segundos:

```
✅ CORRECTO
Request URL: http://localhost:3000/templates?templateId=elevator-annual&version=1
```

```
❌ BUG — resolvió por fecha
Request URL: http://localhost:3000/templates?templateId=elevator-annual
```

```
❌ BUG — versión equivocada
Request URL: http://localhost:3000/templates?templateId=elevator-annual&version=2
```

| Lo que ves en la URL | Qué pasó | Dónde está |
|---|---|---|
| `&version=1`, igual que el campo | el sistema hizo lo correcto | **es el ticket 1**: no hay bug, salta al paso 4 |
| **No hay `version=`** | alguien resolvió por fecha, no por versión | **el 90% del ticket 2**: `resolveTemplateVersion` donde iba `getByVersion` |
| `&version=` con otro número | leyó el campo equivocado | típicamente `family.latest.version` en vez de `inspection.templateVersion` |
| No hay ninguna petición a `/templates` | la plantilla salió de un estado ya cargado | y ese estado puede tener la vigente: mira el `*StateService` |

**Qué descarta.** Esa tabla descarta cuatro de las seis causas sin abrir un archivo. Si la URL lleva el `version=` que la inspección tiene guardado, el sistema está haciendo lo correcto y vas al **Paso 4**, que demuestra que no hay bug. Si lleva otro número o no lleva ninguno, hay bug y su línea está en el **Paso 5**.

> 🧭 **La regla que hace posible este paso, y que vale para cualquier sistema con datos versionados: la petición es la confesión.** Si la consulta no lleva la versión, no hay forma de que la respuesta sea la correcta salvo por casualidad — y la casualidad se acaba el día que alguien publica una versión nueva. Comprobarlo cuesta un vistazo, y evita leer código durante una hora.

### Paso 3 — ¿La respuesta trae lo que pidió la URL?

Clic en la petición → pestaña **Response**:

```json
[
  {
    "id": "elevator-annual-v1",
    "templateId": "elevator-annual",
    "version": 1,
    "validFrom": "2021-01-01",
    "validUntil": "2023-12-31",
    "items": [
      { "id": "main-cable", "title": "Estado del cable principal", … },
      { "id": "emergency-brake", "title": "Freno de emergencia", … },
      { "id": "door-sensor", "title": "Sensor de puerta", … }
    ]
  }
]
```

**Tres ítems**, y `main-cable` con el título **sin** "y tensión". Ésa es la v1, y ésa es la respuesta correcta para la inspección 501.

**Qué descarta.** Si la URL pedía `version=1` y la respuesta trae cuatro ítems o el título nuevo, entonces **el bug no está en el frontend**: alguien editó una versión publicada en la base de datos. Es el caso más raro y el más grave, y se confirma comparando contra la semilla:

```bash
diff <(curl -s "http://localhost:3000/templates?templateId=elevator-annual&version=1") \
     <(python3 -c "import json,sys; d=json.load(open('mock/db.seed.json')); \
        print(json.dumps([t for t in d['templates'] if t['id']=='elevator-annual-v1']))")
```

### Paso 4 (ticket 1) — Cómo se demuestra que no hay bug

Éste es un entregable tan legítimo como un fix, y hay que saber escribirlo. Tres afirmaciones, cada una con su evidencia:

1. **La inspección 501 se ejecutó el 2 de agosto de 2023** (`startedAt`), cuando la v1 era la vigente (`validFrom: 2021-01-01`, `validUntil: 2023-12-31`).
2. **Guardó `templateVersion: 1`**, y ese campo no ha cambiado.
3. **La pantalla pide la v1 y pinta tres ítems**, que es lo que la v1 tiene.

Y la frase que cierra el ticket, que es la parte difícil porque contradice a quien lo reportó:

> *"No está desactualizada: está congelada, y es lo que tiene que pasar. Una inspección firmada en 2023 dice lo que se inspeccionó en 2023. Si se re-renderizara con la norma de hoy, el certificado que salió de ella estaría afirmando algo que nadie comprobó."*

**Aquí termina la ruta del ticket 1.** Queda demostrado que **no hay bug**, y con las tres evidencias de arriba se puede cerrar el ticket por escrito. El ticket 2 sigue abierto y su ruta continúa en el Paso 5.

### Paso 5 (ticket 2) — Dónde está la línea

Con la URL sin `version=`, el archivo es uno de dos y la diferencia es la lección de la fase entera:

```ts
// ❌ "¿Qué versión aplica HOY?" — es una pregunta legítima, y no es ésta.
const template = resolveTemplateVersion(family, todayInBusinessZone());

// ✅ "¿Con qué versión se ejecutó ESTA inspección?" — es un campo, no un cálculo.
const template = await firstValueFrom(
  this.templateApi.getByVersion(inspection.templateId, inspection.templateVersion),
);
```

```bash
# Los dos sitios donde puede estar, y son pocos:
grep -rn "resolveTemplateVersion" src/app --include="*.ts" | grep -v spec
```

**Cada aparición de `resolveTemplateVersion` hay que justificarla.** Es correcta cuando se está **empezando** una inspección nueva —ahí sí se pregunta qué versión rige hoy— y es un bug en cualquier sitio donde se esté **leyendo** una inspección existente. La Fase 8 §5.9 tiene el único uso legítimo del curso.

**Aquí termina la ruta del ticket 2.** El bug está localizado en una línea concreta: una llamada a `resolveTemplateVersion` en un camino de lectura. El fix es del incidente que corresponda; esta pieza localiza y para. El Paso 6 es un tercer síntoma que comparte la misma raíz y se recorre sólo si aparece.

### Paso 6 — El otro incidente: "el sistema dice que hay dos plantillas vigentes"

Es el incidente 09 y su ruta es distinta, porque el bug está en el **dato**, no en la lectura:

```bash
curl -s "http://localhost:3000/templates?templateId=elevator-annual" \
  | python3 -c "import json,sys; [print(t['version'], t['validFrom'], t['validUntil']) for t in json.load(sys.stdin)]"
```

```
1 2021-01-01 2023-12-31
2 2024-01-01 None
3 2025-06-01 None      ← dos ventanas abiertas a la vez
```

**Dos filas con `validUntil: null` es el bug entero**, y se ve en tres líneas de salida. `null` significa "vigente indefinidamente"; publicar la v3 sin cerrar la v2 deja dos versiones vigentes el mismo día, y `resolveTemplateVersion` tiene que elegir entre dos respuestas igualmente válidas — así que devuelve la que le toque según cómo esté escrito el desempate, y ése es el comportamiento indefinido.

> ⚠️ **Publicar una versión nueva es una operación de dos escrituras**: nace la v3 con su `validFrom` **y** se cierra la v2 poniéndole `validUntil`. Si sólo se hace la primera, no falla nada hoy y el sistema queda ambiguo para siempre. Es la clase de bug que un `strict` no puede atrapar, porque `null` es un valor perfectamente válido en las dos filas.


**Aquí termina la ruta.** Las tres versiones del síntoma están localizadas y comparten una raíz: alguien preguntó qué versión rige hoy donde tenía que leer la que quedó guardada. La pieza no va más allá; los fixes son de los incidentes 08, 09 y 10.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| Una inspección vieja con la plantilla vieja | **no es un bug** | demuéstralo con los tres puntos del paso 4 |
| Una inspección vieja con la plantilla nueva | resolución por fecha | la URL: falta `version=` |
| La URL lleva `version=` con otro número | se leyó el campo equivocado | `family.latest.version` en vez de `inspection.templateVersion` |
| La URL es correcta y el contenido no | el dato está corrompido | `diff` contra `db.seed.json` |
| No hay petición a `/templates` | vino de un estado ya cargado | el `*StateService`, que puede tener la vigente |
| "Hay dos plantillas vigentes" | dos `validUntil: null` | el `db.json`, tres líneas de salida |
| Una inspección sin `templateVersion` | mucho peor que todo lo anterior | no se puede reconstruir: es un dato perdido |

---

## ⚰️ Los callejones

**"Hay que actualizar las inspecciones viejas a la versión nueva."** Es la reacción más frecuente y **es exactamente el bug**, propuesto como arreglo. Una inspección responde a las preguntas que se le hicieron; migrarla a otra plantilla inventa respuestas que nadie dio. El histórico no se actualiza: se respeta.

**"El editor de plantillas está sobrescribiendo la v1."** Comprobable en un `diff` contra la semilla, y casi nunca es cierto: el editor de la Fase 7 sólo **crea** versiones nuevas y sólo toca `validUntil` al cerrar. Lo que sí puede sobrescribirla es un script de mantenimiento o alguien editando el `db.json` a mano — y ahí no hay ninguna defensa activa, sólo un diseño que no ofrece la operación.

**"Es la caché del navegador."** Descartable con *Disable cache* y una recarga. Y aunque lo fuera, la URL seguiría siendo la misma: si la URL no lleva `version=`, la caché no tiene nada que ver.

**"El backend devuelve mal."** Posible y raro. El paso 3 lo separa: si la URL pide `version=1` y la respuesta trae la v2, es del servidor; si la URL no pide versión, el servidor hizo lo que le pidieron.

---

## 🧨 Deshacer

Si probaste el paso 3 editando la v1 en el `db.json` —el 🧨 de la fase te lo hace hacer—, **`npm run seed`** lo devuelve todo. No lo dejes: la v1 alterada rompe la Fase 8, la Fase 10 y cuatro incidentes del cuaderno, y el síntoma que produce parece un bug de código.

Si añadiste una v3 para reproducir el paso 6, la misma orden la borra.

---

## 🧠 El patrón transferible

> **En un sistema con datos versionados, hay dos preguntas que suenan igual y no lo son: "¿cuál rige hoy?" y "¿con cuál se hizo esto?".** La primera es un cálculo sobre fechas; la segunda es leer un campo. Confundirlas no da ningún error: da un histórico que cambia solo, y nadie se entera hasta que alguien compara con un papel.

Y el segundo, que es el que ahorra las horas: **la consulta es la confesión.** Antes de leer una línea de código, mira qué se le pidió al servidor. Si la petición no lleva el discriminante, la respuesta sólo puede ser correcta por casualidad.

**Incidentes del cuaderno que usan esta ruta:** 08 (el ítem de más), 09 (dos vigentes) y 10 (los ítems de otra inspección), que son los tres de versionado del curso, y ninguno se resuelve en el mismo archivo.
**Amplía:** `forense-fase-08.md` para cuando el síntoma llega desde el formulario, y `forense-fase-12.md` para el test de regresión que reproduce el 08 **antes** del fix.
