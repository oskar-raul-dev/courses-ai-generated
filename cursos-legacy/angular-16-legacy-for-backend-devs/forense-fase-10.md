# 🕵️ Forense Fase 10 — "Venció ayer para el sistema y hoy para el cliente"

> Pieza forense de la **Fase 10 — Certificados, vigencia y PDF** · Recorrido: ~45 min
> Herramientas: los últimos seis caracteres de una cadena ISO · tres conversiones en consola · la zona horaria del sistema operativo
> Síntoma que cubre: dos observadores del mismo dato llegan a conclusiones distintas, y sólo a ciertas horas.

Esta pieza tiene una conclusión que conviene leer antes que el recorrido, porque cambia dónde se busca: **nunca es un bug de fechas.** `Date` hizo exactamente lo que le pidieron. Es un bug de **no haber decidido a qué hora vence algo**, y por eso el arreglo nunca es un `+1` ni un `-5`.

La fase resume los tres pasos. Aquí está el recorrido con la salida de cada uno, más el segundo ticket que la misma causa produce en el PDF.

---

## 🎫 Ticket A — el que llega mal escrito

> *"A veces el sistema dice que un certificado está vencido y el cliente nos manda una foto del papel donde dice que vence hoy. Pasa sobre todo por la tarde."*

**Reportado por:** coordinador de certificaciones · **Ambiente:** PROD · **Es el incidente 15**

Tres datos que el reporte trae sin saberlo: **"a veces"** (no siempre), **"por la tarde"** (hay un patrón horario) y **"la foto del papel"** (el PDF y la pantalla no coinciden, que es el ticket B).

## 🎫 Ticket B — el documento que no coincide

> *"Descargué el certificado y la tabla de hallazgos no dice lo mismo que la pantalla que tenía delante."*

**Reportado por:** supervisor · **Ambiente:** UAT · **Es el incidente 14**

---

Las dos rutas arrancan por lo mismo y por la misma razón: **mirar los últimos seis caracteres de una cadena ISO cuesta un vistazo** y decide si hay bug o no lo hay. Todo lo demás —las conversiones, el experimento del cambio de hora, comparar pantalla y PDF— cuesta minutos, y sólo tiene sentido después de saber qué trae el dato.

---

## 🧭 Ruta A — la vigencia

### Paso 1 — Los últimos seis caracteres, y sólo ésos

Network → la petición a `/certificates` → pestaña **Response**. No leas el objeto: lee **el final de la cadena**.

```json
{
  "id": "CERT-2024-000502",
  "inspectionId": 502,
  "issuedAt": "2024-02-10T10:00:00-05:00",
  "validUntil": "2025-02-10T23:59:59-05:00",
  "status": "valid",
  "revokedAt": null
}
```

**Qué descarta.** Los seis últimos caracteres de `validUntil` deciden en qué mitad del sistema está el bug, y se leen en diez segundos:

| Lo que termina la cadena | Qué significa | Dónde está el bug |
|---|---|---|
| `-05:00` | el dato está completo y sin ambigüedad | en **quien lo lee**: paso 2 |
| `Z` | el instante es correcto y el **día** de negocio se perdió al escribirlo | en **quien lo emitió** |
| nada (`2025-02-10T23:59:59`) | no hay instante: hay una cadena que cada lector interpreta a su manera | en **quien lo emitió**, y es peor |
| `2025-02-10` a secas | ni siquiera hay hora | en el modelo: falta una decisión |

En CertCore todas las fechas de la semilla llevan `-05:00`, a propósito y desde la Fase 3. Así que en este ticket el bug está en la lectura — que es la mitad buena, porque se arregla sin tocar ningún dato histórico.

> ⚠️ **Y una segunda cosa en esa misma respuesta, que es un bug distinto y peor:** `status: "valid"` está **guardado**. Un estado que se calcula pero se almacena empieza a mentir al día siguiente. Ese certificado vence el 10 de febrero de 2025 y su campo dice `valid` para siempre, hasta que alguien lo actualice. La Fase 10 lo convierte en derivado por esto, y es la misma familia que el ticket B de `forense-fase-09.md`.

### Paso 2 — Las tres conversiones, y las tres son correctas

Con la pantalla abierta, en la consola:

```js
const validUntil = '2025-02-10T23:59:59-05:00';

new Date(validUntil).toISOString();
// '2025-02-11T04:59:59.000Z'      ← el MISMO instante, en UTC

new Date(validUntil).toString();
// 'Mon Feb 10 2025 23:59:59 GMT-0500 …'   ← el mismo instante, en TU huso

toBusinessDay(validUntil);
// '2025-02-10'                    ← el DÍA que ve el negocio
```

**Qué descarta.** Las tres son correctas y las tres dicen cosas distintas, y ahí está todo el bug: **alguien eligió una de las tres para decidir, y eligió sin saber que estaba eligiendo.**

Fíjate en la primera: en UTC, ese certificado vence el **11** de febrero. Si el código compara días con `toISOString().slice(0, 10)`, un usuario en Bogotá y el servidor no están hablando del mismo día — y la diferencia sólo se nota a partir de las 19:00 hora de Bogotá, que es **exactamente el "sobre todo por la tarde" del ticket**.

Esa frase del reporte, que parecía ruido, era el dato más preciso que traía.

### Paso 3 — El experimento de treinta segundos que separa dos mundos

Cambia la zona horaria de **tu sistema operativo** a Auckland (UTC+13) y recarga la aplicación.

```js
// Para comprobar que el cambio tomó efecto:
Intl.DateTimeFormat().resolvedOptions().timeZone;   // 'Pacific/Auckland'
```

**Qué descarta**, y es un corte limpio:

- **Si ningún certificado cambia de estado** → el cálculo es correcto. La única zona que participa es la del negocio, como manda `business-day.ts`, y el huso del navegador no entra en ninguna decisión.
- **Si alguno cambia** → hay un `new Date()` leyendo con el huso del navegador en algún punto del camino, y el paso 2 te dice en cuál.

```bash
# Y el sospechoso se busca así. Cada aparición hay que justificarla:
grep -rn "new Date()\|Date.now()\|toISOString()" src/app --include="*.ts" | grep -v spec
```

**Un `new Date()` suelto donde importe el día es siempre sospechoso.** No porque esté mal en abstracto, sino porque no dice de quién es el reloj que está preguntando.

### Paso 4 — Por qué el arreglo es una función y no un ajuste

```ts
// ❌ Los tres arreglos que aparecen en cualquier revisión, y los tres son peores
//    que el bug: mueven el síntoma a otra hora del día o a otro huso.
const expired = new Date(cert.validUntil) < new Date();
const expired = new Date(cert.validUntil).getTime() + 86400000 < Date.now();
const expired = cert.validUntil.slice(0, 10) < new Date().toISOString().slice(0, 10);

// ✅ Una decisión, con nombre, en un archivo, llamada desde todas partes.
export const BUSINESS_TIME_ZONE = 'America/Bogota';

export function todayInBusinessZone(): string { … }   // '2025-02-10'
export function toBusinessDay(instant: string): string { … }

const expired = toBusinessDay(cert.validUntil) < todayInBusinessZone();
```

> 🧭 **La regla del proyecto: la zona horaria de una decisión de negocio es un dato del negocio, no del entorno.** Un certificado vence al final del día **en el huso donde opera la empresa**, y eso no cambia porque el inspector esté de viaje o porque el servidor esté en otro continente. Cuando esa decisión tiene nombre y vive en un archivo, deja de tomarse por accidente en catorce sitios distintos.


**Aquí termina la ruta A.** El bug está localizado en una conversión que usa el huso del navegador para una decisión de negocio, y el arreglo es una función con el huso dentro. Si tu síntoma era que el PDF no coincide con la pantalla, la tuya es la **ruta B**.

---

## 🧭 Ruta B — el PDF que no coincide

### Paso 1 — Reproducir con dos pestañas

No hace falta ninguna herramienta:

1. Abre el detalle de un certificado en una pestaña. **No la cierres.**
2. En otra pestaña, marca como resuelto uno de sus hallazgos.
3. Vuelve a la primera —que sigue mostrando el estado de hace un rato— y descarga el PDF.

```
Pantalla (pestaña 1):  door-sensor · Mayor · Pendiente
PDF descargado:        door-sensor · Mayor · Pendiente
Servidor (curl):       door-sensor · Mayor · RESUELTO
```

**Qué descarta.** El PDF coincide con la **pantalla** y no con el **dato**. Eso localiza el bug sin ambigüedad: el documento se armó desde lo que había pintado, no desde la fuente.

### Paso 2 — La comprobación en el código, que es una firma

```ts
// ❌ Si la función que arma el PDF recibe lo que el componente ya tenía,
//    el bug está en la firma, antes de leer una línea del cuerpo.
download(view: CertificateView, findings: readonly InspectionFinding[]): Promise<void>

// ✅ Una interfaz explícita con todo lo que el documento necesita, y las seis
//    cosas se piden otra vez.
export interface CertificateDocumentSource {
  readonly certificate: Certificate;
  readonly view: CertificateView;
  readonly inspection: Inspection;
  readonly template: ChecklistTemplate;   // la versión CONGELADA de la inspección
  readonly asset: Asset;
  readonly client: Client;
  readonly findings: readonly InspectionFinding[];
}
```

**Que sea un tipo con nombre y no "lo que tenga el componente" es la mitad del arreglo:** se ve de un vistazo que hacen falta seis cosas, y las seis tienen que venir de la fuente.

> ⚠️ **Lo que hace peligrosa a esta deuda no es que el dato esté viejo: es que el PDF es el único artefacto del sistema que sobrevive al sistema.** Una pantalla desactualizada se arregla con F5. Un PDF desactualizado se archiva, se imprime y se adjunta a la respuesta de un requerimiento normativo, y dentro de dos años nadie va a poder decir de qué momento son sus datos. El desarrollo completo está en **A08** §7 y §9.


**Aquí termina la ruta B.** El bug está localizado: el documento se arma con lo que el componente tenía a mano en vez de con el dato de la fuente. La pieza no escribe el fix — es del incidente 14 — pero deja la firma del tipo, que es por dónde empieza.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Primera comprobación |
|---|---|---|
| "Vence hoy" para uno y "venció ayer" para otro | se comparan días en husos distintos | los seis últimos caracteres de la cadena |
| Pasa sólo a ciertas horas | la diferencia de huso cruza la medianoche | el offset, y quién lo lee |
| Una fecha termina en `Z` | el día de negocio se perdió al escribirla | quien la emitió, no quien la lee |
| Una fecha sin offset | no hay instante, hay una cadena ambigua | el modelo: falta una decisión |
| El estado dice `valid` y la fecha dice que no | el estado está guardado, no derivado | es la misma familia que `forense-fase-09.md` |
| Cambias el huso del sistema y algo cambia | hay un `new Date()` con el reloj del navegador | `grep` de `new Date()` |
| El PDF no coincide con la pantalla | se armó desde la vista | la **firma** de la función que lo arma |
| El PDF coincide con la pantalla y no con el servidor | lo mismo, confirmado | tres pestañas, ninguna herramienta |

---

## ⚰️ Los callejones

**"Es un bug de zonas horarias de JavaScript."** El callejón más caro, porque manda a buscar librerías. `Date` es incómodo y aquí no se equivocó: convirtió correctamente entre husos, tres veces, con tres resultados correctos. El bug es que nadie decidió **cuál de los tres** era el bueno para esta decisión de negocio.

**"Guardemos todo en UTC y se acabó."** Es la respuesta estándar y resuelve el problema equivocado. UTC te da un **instante** sin ambigüedad, y eso ya lo tienes con el offset. Lo que UTC no te da es el **día de calendario del negocio**, que es lo que decide si un certificado está vencido. Un certificado que vence "el 10 de febrero" no vence a las 05:00 UTC del 11 porque sí: vence al final del día laboral de donde opera la empresa.

**"Sumemos un día."** Mueve el error de sitio. Con `+1` día el bug desaparece por la tarde en Bogotá y aparece por la mañana en Auckland. Un desplazamiento constante nunca arregla un problema de husos, sólo cambia a quién le toca.

**"El PDF está cacheado."** Descartable en un segundo: cada descarga genera el archivo desde cero en el navegador. Si el contenido es viejo, es porque los **datos** que se le dieron eran viejos, no porque el archivo lo fuera.

---

## 🧨 Deshacer

**Devuelve la zona horaria de tu sistema operativo** después del paso 3. Es el único paso de todo el track que toca algo fuera del proyecto, y olvidarlo te va a dar resultados desconcertantes en la Fase 11 y en la 12 —donde hay tests que dependen del reloj— sin ninguna relación aparente con lo que estabas haciendo.

Si marcaste hallazgos como resueltos reproduciendo la ruta B, `npm run seed`.

---

## 🧠 El patrón transferible

> **Nunca es un bug de fechas.** Es un bug de no haber decidido, y la pregunta que lo revela siempre es la misma: *¿a qué hora, y en qué huso, ocurre esto?* Si la respuesta no está escrita en un archivo con un nombre, está tomada por accidente en cada sitio donde alguien escribió `new Date()`.

Y el segundo, que vale para cualquier artefacto exportado: **lo que hay en la pantalla es una foto de hace un rato.** Está bien para mirar y está mal para imprimir. Cualquier cosa que sobreviva a la sesión —un PDF, un correo, un export— se arma pidiendo el dato otra vez, y la forma de garantizarlo es que la función que lo arma **no acepte** lo que el componente ya tenía.

**Incidentes del cuaderno que usan esta ruta:** 14 (el PDF que no coincide) y 15 (venció ayer/hoy).
**Amplía:** **A08** §7 y §9 para el PDF que se arma desde el dato y para lo que un documento exportado ya no puede desandar, y `forense-fase-09.md` para el mismo mecanismo de dato guardado frente a dato derivado.
