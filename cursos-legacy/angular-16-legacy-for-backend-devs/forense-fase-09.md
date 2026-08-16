# 🕵️ Forense Fase 09 — "El sistema me dejó aprobar y no debía"

> Pieza forense de la **Fase 9 — Hallazgos y severidad** · Recorrido: ~40 min
> Herramientas: el JSON crudo de la respuesta · tres comparaciones en consola · `ng.getComponent($0)`
> Síntoma que cubre: una regla de negocio que no se aplicó, sin ningún error en ninguna parte.

Los dos tickets de esta pieza son la misma familia con dos caras: **`null`, `undefined` y campo ausente son tres cosas distintas**, y bajo `strict` el compilador te protege de dos de ellas y no de la tercera. La tercera es la que llega desde la red.

La fase resume el primer recorrido. Aquí están los dos tickets y la salida de cada paso.

---

## 🎫 Ticket A — la regla que no bloqueó

> *"Aprobé la inspección del ascensor de la torre A y el sistema me dejó, pero el cable está para cambiar. Lo puse como hallazgo crítico y aun así me dejó aprobar. ¿No era que no se podía?"*

**Reportado por:** supervisor de certificaciones · **Ambiente:** UAT · **Es el incidente 12**

## 🎫 Ticket B — el cambio que se deshizo solo

> *"El supervisor subió la severidad de un hallazgo de menor a mayor el jueves, y el viernes había vuelto a bajar. Nadie lo tocó. No aparece en ningún registro."*

**Reportado por:** coordinador de certificaciones · **Ambiente:** UAT · **Es el incidente 13**

**No hay error en consola, no hay nada rojo en Network, y la pantalla muestra el dato perfectamente.** Los dos tickets describen un sistema que hace algo distinto de lo que dice hacer, en silencio.

---

Las dos rutas empiezan por el mismo sitio y por la misma razón: **el cuerpo de la respuesta es la única capa que no interpreta nada**, y mirarlo cuesta un clic. Todo lo que viene después —la pantalla, el servicio, la regla— ya aplicó valores por defecto, así que preguntarle a cualquiera de ellos antes que al JSON crudo es empezar por la capa que miente.

---

## 🧭 Ruta A — la regla que no bloqueó

### Paso 1 — El JSON crudo, no lo que pinta la pantalla

Ésta es la distinción que resuelve el ticket, y hay que hacerla en ese orden: **primero el cuerpo de la respuesta, después la pantalla.** La pantalla ya aplicó tus valores por defecto; el cuerpo, no.

Network → la petición a `/findings?inspectionId=…` → pestaña **Response**:

```json
[
  {
    "id": 900,
    "inspectionId": 503,
    "itemId": "main-cable",
    "severity": "critical",
    "description": "Desgaste severo del cable principal, con hilos visibles",
    "resolvedAt": null
  },
  {
    "id": 904,
    "inspectionId": 503,
    "itemId": "door-sensor",
    "severity": "major",
    "description": "El sensor no detecta obstáculos"
  }
]
```

**Qué descarta.** Míralas por columnas, no por filas. La primera trae `resolvedAt: null`. **La segunda no trae la clave.** No es que valga `null`: es que el campo **no existe**.

Y entre el tipo que declara ese campo y el servidor que no lo manda **no hay nadie comprobando nada**:

```ts
// El tipo promete que el campo existe. TypeScript se lo cree, porque el
// tipado de una respuesta HTTP es una afirmación, no una verificación.
export interface Finding {
  readonly resolvedAt: string | null;
}
```

Ésa es la línea entera del bug: `this.http.get<Finding[]>(url)` **no valida nada**. El genérico es una promesa que tú haces al compilador sobre datos que vienen de fuera.

### Paso 2 — Las tres preguntas, y sus tres respuestas distintas

Con la pantalla de hallazgos abierta: inspector → selecciona el `<li>` del hallazgo → consola.

```js
const finding = ng.getComponent($0).finding;

finding.resolvedAt === null;    // false  ← y aquí nace el bug
finding.resolvedAt == null;     // true   ← cubre null Y undefined
'resolvedAt' in finding;        // false  ← el campo NO EXISTE
finding.resolvedAt;             // undefined
```

**Estas tres líneas son la fase entera en tres respuestas.** La primera es la que escribiste; la segunda es el fix del viernes; la tercera es la que te dice de dónde vino.

Y la regla que las une, con la comprobación culpable delante:

```ts
// ❌ La regla, escrita como se escribe siempre:
const blocking = findings.filter(
  (finding) => finding.severity === 'critical' && finding.resolvedAt === null,
);
// El hallazgo 904 tiene `undefined`, no `null`. `undefined === null` es false.
// El hallazgo no entra en la lista, no bloquea nada, y la emisión sigue.
```

> ⚠️ **`strict: true` no te salva de esto, y conviene entender por qué.** El compilador comprueba lo que **declaraste**, y tú declaraste `string | null`. Si el dato real trae `undefined`, el compilador no tiene forma de saberlo: nunca vio la respuesta. `strict` protege la frontera entre tus archivos; **la frontera con la red la tienes que defender tú.**

**Qué descarta.** La tercera línea es la que decide. Si `'resolvedAt' in finding` devuelve `false`, el campo no existe y descarta toda hipótesis sobre la regla: el problema entró por la red y el arreglo va en el borde, que es el **Paso 3**. Si devuelve `true` y el valor es `null`, la regla está bien escrita y el bug es de otro sitio: la ruta A no es la tuya.

### Paso 3 — Dónde va el arreglo, que es la decisión de verdad

El `?? null` puede ir en tres sitios y **los tres funcionan hoy**:

```ts
// Opción 1 — en el componente, donde se manifestó.
const blocking = findings.filter((f) => f.severity === 'critical' && (f.resolvedAt ?? null) === null);

// Opción 2 — en la regla de dominio.
export function blockingFindings(findings: readonly Finding[]): readonly Finding[] { … }

// Opción 3 — en el borde HTTP, al entrar el dato al sistema.
map((raw) => raw.map((finding) => ({ ...finding, resolvedAt: finding.resolvedAt ?? null })));
```

| Opción | Arregla esta pantalla | La emisión del certificado (Fase 10) | El dashboard (Fase 11) |
|---|---|---|---|
| 1 — componente | ✅ | ❌ | ❌ |
| 2 — regla de dominio | ✅ | ✅ | ❌ si el dashboard no la usa |
| 3 — **borde HTTP** | ✅ | ✅ | ✅ |

**Sólo la tercera sigue funcionando cuando la Fase 10 lea el mismo campo para decidir si emite un certificado, y cuando la Fase 11 lo cuente en el panel.** Ponerlo en el borde no es elegancia: es no tener que acordarte dos fases más adelante, en dos archivos que todavía no existen.

> 🧭 **La regla del proyecto: lo que entra por la red se normaliza una vez, en el borde, y a partir de ahí el dominio confía.** Un `?? null` repartido por cinco componentes es cinco sitios donde alguien puede olvidarse; uno en el `*ApiService` es un sitio donde alguien puede leerlo.


**Aquí termina la ruta A.** El bug está localizado —una comparación estricta contra un campo que no existe— y, más importante, está decidido **dónde** va el arreglo: en el borde, una sola vez. Si tu síntoma era un cambio que se deshace solo, la tuya es la **ruta B**.

---

## 🧭 Ruta B — el cambio que se deshizo solo

### Paso 1 — ¿El dato está guardado o está derivado?

La pregunta que ordena el ticket, y se contesta comparando dos cosas:

```bash
# Lo que el servidor guarda:
curl -s "http://localhost:3000/findings/901" -H "Authorization: Bearer <token>"
# { "id": 901, "inspectionId": 503, "itemId": "cabin-lighting",
#   "severity": "major", … }
```

```js
// Lo que la pantalla muestra:
ng.getComponent($0).finding.severity;   // 'minor'
```

**Guardado dice `major`. Pintado dice `minor`.** El dato existe, se guardó bien, y algo lo está recalculando por encima.

**Qué descarta.** Descarta el guardado entero —la petición, el servidor y el `db.json`— y con él la mitad de las hipótesis del ticket: nadie perdió el cambio, alguien lo está pisando al leer. Si el JSON guardado dijera `minor`, la ruta sería la contraria y el problema estaría en la escritura. Con `major` guardado, sigues al **Paso 2**: quién manda, el dato o la regla.

### Paso 2 — Quién manda: el dato o la regla

```ts
// La regla de derivación de la fase: la severidad sale del ítem de la
// plantilla, no del hallazgo.
export function severityOf(item: ChecklistItem, answer: string): Severity {
  return isNonCompliant(item, answer) ? item.nonComplianceSeverity : 'minor';
}
```

`cabin-lighting` tiene `nonComplianceSeverity: 'minor'` en la v2 de `elevator-annual`. La regla devuelve `minor` cada vez que se ejecuta, y **pisa el `major` que el supervisor escribió**.

**Qué descarta.** No es un bug de guardado: el `PATCH` funcionó y el dato está en el servidor. Es que **el sistema tiene dos fuentes de verdad para el mismo campo** y la derivada gana cada vez que alguien recarga.

### Paso 3 — La forma del arreglo, y por qué `undefined` vuelve a ser el culpable

Un campo de anulación explícito, y aquí está la trampa que conecta esta ruta con la A:

```ts
// ❌ Opcional: "no me molesté en decidirlo".
severityOverride?: Severity;
// Un hallazgo sin anulación trae la clave ausente; otro trae `undefined`;
// otro trae `null` si alguien la quitó. Tres formas de decir lo mismo, y la
// comprobación que las distinga se escribe mal la primera vez.

// ✅ Explícito: `null` significa "sin anulación", y es un valor decidido.
readonly severityOverride: Severity | null;

export function effectiveSeverity(finding: Finding, item: ChecklistItem, answer: string): Severity {
  // La anulación gana, y sólo si existe de verdad.
  return finding.severityOverride ?? severityOf(item, answer);
}
```

> 🧭 **La regla del proyecto (guía §6.4): los modelos del dominio distinguen ausencia de vacío.** `validUntil: string | null` significa "vigente indefinidamente"; `validUntil?: string` significaría "no me molesté en decidirlo", y eso no entra al curso. Es la misma decisión que la ruta A, tomada al escribir el modelo en vez de al depurar el ticket.

Y la mitad que este ticket deja sin resolver, que hay que decir en el post-mortem: **no aparece en ningún registro**. Aunque la anulación se guarde bien, nadie sabe quién la puso ni cuándo. En un sistema cuyo dominio **es** la trazabilidad, eso es un hallazgo de diseño, no un bug — y es exactamente el límite del patrón de estado que **A07** §8 nombra.


**Aquí termina la ruta B.** El bug está localizado y la regla del proyecto que lo evita, escrita. Lo que esta ruta **no** resuelve —que la anulación no quede registrada en ninguna parte— no es un bug: es una deuda, y va al post-mortem del incidente.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Primera comprobación |
|---|---|---|
| Una regla no se aplicó y no hay error | `undefined` donde esperabas `null` | `'campo' in objeto` en la consola |
| El JSON crudo no trae una clave que el tipo declara | el genérico de `HttpClient` no valida nada | normaliza en el borde HTTP |
| `x === null` es `false` y el campo está vacío | es `undefined` | `== null` cubre los dos, y es el fix del viernes |
| Guardado dice una cosa y pintado otra | hay un derivado pisando el dato | compara `curl` con `ng.getComponent` |
| Un cambio se deshace al recargar | dos fuentes de verdad para un campo | decide cuál manda, y hazlo explícito |
| El cambio se aplica y nadie sabe quién lo hizo | no hay trazabilidad | es un hallazgo de diseño — **A07** §8 |
| El mismo bug reaparece en otra pantalla | el arreglo se puso en el componente | debía ir en el borde — paso 3 de la ruta A |

---

## ⚰️ Los callejones

**"El supervisor no guardó bien."** El callejón número uno del ticket B, y es el que echa la culpa a una persona. Se descarta con un `curl`: si el servidor tiene `major`, el guardado funcionó. Y hacerlo **antes** de preguntarle a nadie es la diferencia entre un post-mortem y una conversación incómoda.

**"Faltaba un `!` o un `as`."** Es lo que sugiere el compilador cuando el tipo no cuadra, y aquí sería lo peor posible: silenciarías la única señal disponible. La guía prohíbe el aserto de no-nulo en el código del curso precisamente por esta familia de bugs.

**"El backend está mal y que lo arreglen ellos."** Puede ser cierto **y no cambia tu trabajo**. Un cliente que se cae porque el servidor omitió un campo opcional es un cliente frágil. La normalización en el borde no es suplir al backend: es no depender de que nadie cambie nunca un contrato.

**"Hay que quitar la derivación y guardar la severidad."** Tentador y peor: si la severidad se guarda, el día que la norma cambie el `nonComplianceSeverity` de un ítem, los hallazgos viejos seguirán diciendo lo de antes y nadie sabrá si eso es correcto o es un dato viejo. La derivación es la decisión correcta; lo que faltaba era **una anulación explícita**, que es otra cosa.

---

## 🧨 Deshacer

La ruta A se reproduce quitando la clave `resolvedAt` de un hallazgo en el `db.json` — es el 🧨 de la fase. **`npm run seed`** lo devuelve: un hallazgo sin ese campo hace que la Fase 10 emita certificados que no debería, y el síntoma aparece dos fases más allá sin ninguna pista de dónde vino.

La ruta B no modifica nada: se mira. Si probaste el `PATCH` de la severidad, la misma orden.

---

## 🧠 El patrón transferible

> **`strict` protege la frontera entre tus archivos, no la frontera con la red.** Un genérico en `http.get<T>()` es una promesa que tú le haces al compilador sobre datos que él nunca va a ver. Todo lo que entra por esa puerta hay que normalizarlo una vez, en el borde, y a partir de ahí el dominio puede confiar.

Y el segundo, que es de diseño: **cuando un campo tiene dos fuentes de verdad, la derivada gana siempre, y gana en silencio.** No hay error, no hay conflicto, no hay aviso: simplemente el próximo recálculo pisa lo que alguien escribió. Si quieres que un valor manual sobreviva, tiene que existir como campo propio con un valor que signifique "aquí no hay anulación" — y ese valor se decide al escribir el modelo, no al depurar el ticket.

**Incidentes del cuaderno que usan esta ruta:** 12 y 13, los dos de tipos bajo `strict`.
**Amplía:** **A05** §1 para `FormControl<T>` y el `| null` que nadie espera, **A07** §5 y §8 para derivar sin duplicar y para dónde el patrón se queda corto, y `forense-fase-10.md` para el mismo mecanismo aplicado al `status` de un certificado.
