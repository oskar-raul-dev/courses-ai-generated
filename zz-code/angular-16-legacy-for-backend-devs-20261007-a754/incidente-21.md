## Incidente 21 — "En la isla todavía era 12 y el sistema ya decía vencido"

> **Fase:** 10 · **Categoría:** Tiempo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45 min · **Ruta forense:** [`forense-fase-10.md`](forense-fase-10.md)

### 🎫 El ticket

> **De:** Patricio Villacís · **Asunto:** RV: certificado de la caldera — Aurum Inn Galápagos
>
> *"Les reenvío lo de abajo. Anoche a las once y cuarto, hora de la isla, el administrador del Inn me pidió confirmar el certificado de la caldera, porque la gente de cumplimiento del laboratorio lo pedía antes de la cena de cierre de la convención. Entré a CertCore desde Quito y salía VENCIDO. El papel dice que vence el 12, y allá todavía era 12. Esta mañana sale vencido también, pero eso sí está bien: los inspectores vuelan mañana. Lo que no quiero es que me vuelva a pasar con un cliente al lado."*
>
> > *"Ingeniero, buenas noches. La coordinadora de cumplimiento del laboratorio nos pide confirmar que la caldera está certificada. El certificado que tenemos dice vigente hasta el 12 de marzo. ¿Nos confirma, por favor? Es para antes de la cena. — Administración, Aurum Inn Galápagos"*

**Reportado por:** gerente de Plomada Ecuador, reenviando el correo de un cliente
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir el "vencido" de las once y cuarto sin viajar a Galápagos, explicar por qué a esa misma hora un certificado de una torre de Quito **no** se equivoca, y arreglarlo sin mover un segundo los certificados del continente y sin reescribir nada de lo ya emitido.

### 🔧 Preparación

El código de la Fase 10 ya tiene el bug: lo que falta es el dato que lo dispara. Un `db.json` alterno, con la hostería de Galápagos, su caldera, la plantilla ecuatoriana `boiler-annual-ec` y el certificado que se emitió hace un año.

```bash
cp mock/db.json mock/db.mio.json          # guarda el tuyo
cp mock/db.incidente-21.json mock/db.json
npm run mock
npm start
```

Y el experimento que reproduce el ticket, que **es parte de la preparación**: pon el reloj de tu sistema operativo en el **12 de marzo de 2026 a las 23:15, hora de Galápagos** (UTC−6), y abre la lista de certificados. Después ponlo a las 22:45 del mismo día y compara. Devuelve el reloj al terminar: hay tests de la Fase 12 que dependen de él.

Para volver: `npm run seed`, o `cp mock/db.mio.json mock/db.json`.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de leer código, mira el cuerpo crudo del certificado `CERT-2025-000505` y los últimos seis caracteres de su `validUntil`. Después busca en qué ciudad está el activo de esa inspección. Una de las dos cosas no sabe de la otra.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Abre `src/app/core/time/business-day.ts` y lee entero el comentario de `CERTCORE_TIME_ZONE_OFFSET`, con su ⚠️. ¿Cuántos de los activos del `db.json` cumplen lo que dice ese comentario?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`2026-03-12T23:59:59-05:00`: ¿qué hora es en Puerto Ayora en ese instante? ¿Y a qué hora de Puerto Ayora empieza CertCore a decir que el certificado venció?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Esta vez **quien lee no tiene la culpa.** `deriveCertificateStatus` compara instantes con `isPast`, que es exactamente lo que la Fase 10 decidió y lo que arregló el incidente 15. El que está mal es el **instante**, y está mal desde el día en que se emitió:

```json
{ "id": "CERT-2025-000505", "inspectionId": 505,
  "issuedAt": "2025-03-12T20:40:00.000Z",
  "validUntil": "2026-03-12T23:59:59-05:00",
  "status": "issued", "revokedAt": null }
```

`computeValidity` cerró el día con `endOfBusinessDay`, y `endOfBusinessDay` le pega `CERTCORE_TIME_ZONE_OFFSET`: `-05:00`, la hora de Bogotá, Lima y Quito. La caldera está en Puerto Ayora, que vive en UTC−6 todo el año:

```js
new Date('2026-03-12T23:59:59-05:00').toLocaleString('es-EC', { timeZone: 'Pacific/Galapagos' });
// '12/3/2026, 22:59:59'  ← en la isla, el certificado "vence" a las once menos un segundo
new Date('2026-03-12T23:59:59-05:00').toLocaleString('es-EC', { timeZone: 'America/Guayaquil' });
// '12/3/2026, 23:59:59'  ← en el continente, donde debe
```

Desde las 23:00 hasta las 23:59:59 del último día, hora de la isla, CertCore lo declara vencido. Es una hora al año por activo, y el ticket cayó justo dentro de ella. Patricio miraba desde Quito, pero la pantalla habría dicho lo mismo desde cualquier sitio: el instante está guardado así.

Lo había avisado el comentario de la constante, escrito a finales de 2022: *"si algún día un activo está en otra zona… este archivo entero cambia"*. El Inn llegó en 2024 por un contrato comercial, se dio de alta como cualquier cliente, y nadie volvió a leer ese ⚠️.

> 🧠 **El 15 y el 21 son el mismo error visto desde los dos lados.** En el 15 el dato estaba bien y lo leía mal quien lo leía. Aquí el que lee es correcto y el dato nació mal, porque *"la zona del negocio es la zona del activo"* era verdad en el continente y nadie lo escribió como supuesto. La regla de la historia —el certificado vale hasta el final del día **en la hora del lugar donde está el activo**— siempre fue ésa. El código conocía la mitad.

**Parche mínimo**

Va en dos pasos, porque el bug también tiene dos lados: **leer** bien lo que ya se emitió, sin tocarlo, y **emitir** bien lo que viene. Y el país entra por donde el sistema puede saberlo: por el activo.

Primero el dato, que es de un **activo** y no de un certificado. Lo emitido no se toca: el histórico es de la auditoría. En el `db.json`, la caldera gana su zona:

```diff
     { "id": "CAL-INN-GPS-01", "clientId": 4, "type": "boiler",
       "description": "Caldera de agua caliente, cuarto de máquinas, Puerto Ayora",
-      "installedAt": "2016-04-18" }
+      "installedAt": "2016-04-18", "timeZone": "Pacific/Galapagos" }
```

El modelo lo admite como **opcional**. Sin el campo, todo sigue por el camino de siempre:

```diff
// src/app/core/models/asset.model.ts
   /** Fecha de instalación, sin hora: es un día de calendario, no un instante. */
   readonly installedAt: string;
+  /**
+   * 🩹 INCIDENTE 21. La zona IANA del lugar donde está el activo, SÓLO si no es
+   * la del negocio (`business-day.ts`). Hoy, únicamente la caldera del Inn.
+   */
+  readonly timeZone?: string;
 }
```

`business-day.ts` gana dos funciones con zona. Están **al lado** de las de siempre y no las reemplazan:

```ts
// src/app/core/time/business-day.ts — lo que añade el fix del incidente 21

/**
 * 🩹 INCIDENTE 21. El día de calendario de un instante en una zona IANA.
 *
 * Sin zona es `toBusinessDay`, el camino de siempre: los activos que no traen
 * `timeZone` —todos los del continente— no pasan por `Intl` y no se mueven ni
 * un segundo. Con zona, la cuenta la hace `Intl`, que sí conoce las zonas.
 */
export function toLocalDay(instant: Instant, timeZone?: string): BusinessDay {
  if (timeZone === undefined) {
    return toBusinessDay(instant);
  }

  // 'en-CA' formatea como YYYY-MM-DD, que es exactamente un `BusinessDay`.
  return new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(new Date(instant));
}

/** El último instante de un día en una zona IANA. Sin zona, `endOfBusinessDay`. */
export function endOfLocalDay(day: BusinessDay, timeZone?: string): Instant {
  if (timeZone === undefined) {
    return endOfBusinessDay(day);
  }

  return `${day}T23:59:59${offsetOn(day, timeZone)}`;
}

/**
 * El desplazamiento de una zona en un día dado, como '-06:00'. Se mide al
 * mediodía UTC de ese día: en las zonas de CertCore no hay cambio de hora, y en
 * una que lo tuviera el salto ocurre de madrugada, lejos del mediodía.
 */
function offsetOn(day: BusinessDay, timeZone: string): string {
  const name = new Intl.DateTimeFormat('en-US', { timeZone, timeZoneName: 'longOffset' })
    .formatToParts(new Date(`${day}T12:00:00Z`))
    .find((part) => part.type === 'timeZoneName')?.value;

  if (name === undefined) {
    throw new Error(`No se pudo calcular el desplazamiento de "${timeZone}".`);
  }

  // 'GMT-06:00' → '-06:00'; UTC llega como 'GMT', sin número.
  return name === 'GMT' ? '+00:00' : name.slice(3);
}
```

**Paso 1, leer.** El estado y la vista reciben la zona. Lo que ya se emitió con `-05:00` se lee por su **día** y se cierra en la hora del activo:

```diff
// src/app/core/domain/certificate-status.ts
-import { BusinessDay, Instant, daysBetween, isPast, toBusinessDay } from '../time/business-day';
+import { BusinessDay, Instant, daysBetween, endOfLocalDay, isPast, toLocalDay } from '../time/business-day';
@@
-export function daysUntilExpiry(certificate: Certificate, now: Instant): number {
-  return daysBetween(toBusinessDay(now), toBusinessDay(certificate.validUntil));
+export function daysUntilExpiry(certificate: Certificate, now: Instant, timeZone?: string): number {
+  return daysBetween(toLocalDay(now, timeZone), toLocalDay(certificate.validUntil, timeZone));
 }
@@
 export function deriveCertificateStatus(
   certificate: Certificate,
   now: Instant,
+  timeZone?: string,
 ): DerivedCertificateStatus {
   if (certificate.revokedAt !== null) {
     return 'revoked';
   }

-  if (isPast(certificate.validUntil, now)) {
+  // 🩹 INCIDENTE 21. Vale hasta el final del día de `validUntil` en la hora del
+  // activo. Sin zona, `validUntil` ya es ese instante y se compara como siempre.
+  // Con zona se lee su día ahí y se cierra ahí: el del Inn, emitido con -05:00,
+  // vale hasta las 23:59:59 de Puerto Ayora sin reescribir lo emitido.
+  const until =
+    timeZone === undefined
+      ? certificate.validUntil
+      : endOfLocalDay(toLocalDay(certificate.validUntil, timeZone), timeZone);
+
+  if (isPast(until, now)) {
     return 'expired';
   }

-  const remaining = daysUntilExpiry(certificate, now);
+  const remaining = daysUntilExpiry(certificate, now, timeZone);
@@
-export function buildCertificateView(certificate: Certificate, now: Instant): CertificateView {
-  const status = deriveCertificateStatus(certificate, now);
+export function buildCertificateView(
+  certificate: Certificate,
+  now: Instant,
+  timeZone?: string,
+): CertificateView {
+  const status = deriveCertificateStatus(certificate, now, timeZone);
@@
-    daysUntilExpiry: daysUntilExpiry(certificate, now),
-    renewalDueOn: renewalDueOn(certificate.validUntil),
+    daysUntilExpiry: daysUntilExpiry(certificate, now, timeZone),
+    renewalDueOn: renewalDueOn(certificate.validUntil, timeZone),
```

¿De dónde sale la zona en la pantalla? Del único camino que existe: certificado → inspección → activo. El servicio de estado lo arma una vez:

```diff
// src/app/core/state/certificate-state.service.ts
-import { BehaviorSubject, Observable, concatMap, map, tap, throwError } from 'rxjs';
+import { BehaviorSubject, Observable, combineLatest, concatMap, map, shareReplay, tap, throwError } from 'rxjs';

+import { AssetApiService } from '../api/asset-api.service';
 import { CertificateApiService } from '../api/certificate-api.service';
+import { InspectionApiService } from '../api/inspection-api.service';
@@
   private readonly certificateApi = inject(CertificateApiService);
   private readonly inspectionState = inject(InspectionStateService);
+  private readonly assetApi = inject(AssetApiService);
+  private readonly inspectionApi = inject(InspectionApiService);
@@
-  readonly views$: Observable<readonly CertificateView[]> = this.state$.pipe(
-    map((state) => {
+  /**
+   * 🩹 INCIDENTE 21. La zona de cada certificado, por inspección y activo. Sólo
+   * entran los activos que traen `timeZone`; los demás no aparecen en el mapa y
+   * siguen por el offset de siempre.
+   */
+  private readonly timeZones$: Observable<ReadonlyMap<number, string>> = combineLatest([
+    this.inspectionApi.getAll(),
+    this.assetApi.getAll(),
+  ]).pipe(
+    map(([inspections, assets]) => {
+      const zoneByAssetId = new Map<string, string>();
+      for (const asset of assets) {
+        if (asset.timeZone !== undefined) {
+          zoneByAssetId.set(asset.id, asset.timeZone);
+        }
+      }
+
+      const zoneByInspectionId = new Map<number, string>();
+      for (const inspection of inspections) {
+        const zone = zoneByAssetId.get(inspection.assetId);
+        if (zone !== undefined) {
+          zoneByInspectionId.set(inspection.id, zone);
+        }
+      }
+
+      return zoneByInspectionId;
+    }),
+    shareReplay({ bufferSize: 1, refCount: true }),
+  );
+
+  readonly views$: Observable<readonly CertificateView[]> = combineLatest([
+    this.state$,
+    this.timeZones$,
+  ]).pipe(
+    map(([state, zones]) => {
       const now = nowInstant();

-      return state.items.map((certificate) => buildCertificateView(certificate, now));
+      return state.items.map((certificate) =>
+        buildCertificateView(certificate, now, zones.get(certificate.inspectionId)),
+      );
     }),
   );
```

**Paso 2, emitir.** La renovación de la semana que viene no puede volver a nacer con `-05:00`. La vigencia se calcula en la hora del activo, y el PDF lee el día en esa misma hora: si no, un `23:59:59-06:00` impreso con el día de Bogotá saldría como el **13**.

```diff
// src/app/core/domain/certificate-validity.ts
   addDays,
-  endOfBusinessDay,
-  toBusinessDay,
+  endOfLocalDay,
+  toLocalDay,
 } from '../time/business-day';
@@
-export function computeValidity(issuedAt: Instant): CertificateValidity {
-  const issuedDay = toBusinessDay(issuedAt);
+export function computeValidity(issuedAt: Instant, timeZone?: string): CertificateValidity {
+  // 🩹 INCIDENTE 21. El día de emisión y el final de la vigencia, en la hora del activo.
+  const issuedDay = toLocalDay(issuedAt, timeZone);

   return {
     from: issuedAt,
-    until: endOfBusinessDay(addMonths(issuedDay, CERTIFICATE_VALIDITY_MONTHS)),
+    until: endOfLocalDay(addMonths(issuedDay, CERTIFICATE_VALIDITY_MONTHS), timeZone),
   };
 }
@@
-export function renewalDueOn(validUntil: Instant): BusinessDay {
-  return toBusinessDay(validUntil);
+export function renewalDueOn(validUntil: Instant, timeZone?: string): BusinessDay {
+  return toLocalDay(validUntil, timeZone);
 }
```

```diff
// src/app/core/state/certificate-state.service.ts
-        return this.inspectionState.findingsOf(inspection).pipe(map(summarizeFindings));
+        // 🩹 INCIDENTE 21. El activo viaja con el resumen: su zona decide la vigencia.
+        return combineLatest({
+          summary: this.inspectionState.findingsOf(inspection).pipe(map(summarizeFindings)),
+          asset: this.assetApi.getById(inspection.assetId),
+        });
       }),
-      concatMap((summary) => {
+      concatMap(({ summary, asset }) => {
@@
-        const validity = computeValidity(issuedAt);
+        const validity = computeValidity(issuedAt, asset.timeZone);
```

```diff
// src/app/core/pdf/certificate-document.ts
-import { toBusinessDay } from '../time/business-day';
+import { toLocalDay } from '../time/business-day';
@@
-    `Vigencia: del ${formatInstant(view.validity.from)} al ${formatInstant(view.validity.until)}`,
+    `Vigencia: del ${formatInstant(view.validity.from, asset.timeZone)} ` +
+      `al ${formatInstant(view.validity.until, asset.timeZone)}`,
@@
-      finding.resolvedAt === null ? 'No' : formatInstant(finding.resolvedAt),
+      finding.resolvedAt === null ? 'No' : formatInstant(finding.resolvedAt, asset.timeZone),
@@
-function formatInstant(instant: string): string {
+function formatInstant(instant: string, timeZone?: string): string {
   // El documento se lee donde está el activo: se imprime el día de negocio, no el
   // instante completo, y desde luego no el UTC.
-  return toBusinessDay(instant).split('-').reverse().join('/');
+  return toLocalDay(instant, timeZone).split('-').reverse().join('/');
 }
```

```diff
// src/app/features/certificates/certificate-pdf.service.ts
-            view: buildCertificateView(parts.certificate, nowInstant()),
+            view: buildCertificateView(parts.certificate, nowInstant(), parts.asset.timeZone),
```

**La refactorización correcta**

La zona es un dato del activo, así que el país termina entrando al modelo por ahí: un `timeZone` **obligatorio**, sembrado para todos los activos —`America/Bogota`, `America/Lima`, `America/Guayaquil`, `Pacific/Galapagos`—, y `CERTCORE_TIME_ZONE_OFFSET` se jubila como el respaldo de un dato que ya no falta. Es lo que el comentario de 2022 llamaba *"este archivo entero cambia"*, y no se hace un viernes: toca la semilla, la pantalla de activos de la Fase 6 y cada función que hoy da por hecho el `-05:00`.

Mientras tanto, el panel de la Fase 11 sigue contando sin zona: `bucketCertificates` y `assetsWithoutCoverage` llaman a `deriveCertificateStatus` sin el tercer argumento, y durante esa misma hora del último día el Inn sale en la columna de vencidos. Queda en los pendientes.

**Prueba de regresión**

```ts
// src/app/core/domain/certificate-status.spec.ts — el caso del incidente 21
import { Certificate } from '../models/certificate.model';
import { deriveCertificateStatus } from './certificate-status';
import { computeValidity } from './certificate-validity';

const GALAPAGOS = 'Pacific/Galapagos';

function certificate(validUntil: string): Certificate {
  return {
    id: 'CERT-2025-000505',
    inspectionId: 505,
    issuedAt: '2025-03-12T20:40:00.000Z',
    validUntil,
    status: 'issued',
    revokedAt: null,
  };
}

describe('incidente 21: el certificado vence en la hora del activo', () => {
  // Emitido antes del fix: el instante quedó en -05:00, las 22:59:59 de la isla.
  const emittedBeforeFix = certificate('2026-03-12T23:59:59-05:00');
  const quarterPastElevenOnTheIsland = '2026-03-12T23:15:00-06:00';

  it('sigue vigente a las 23:15 de Puerto Ayora del último día', () => {
    // Antes del fix, este caso devolvía 'expired'.
    expect(deriveCertificateStatus(emittedBeforeFix, quarterPastElevenOnTheIsland, GALAPAGOS)).toBe('expiring');
  });

  it('vence a la medianoche de la isla, ni una hora antes ni una después', () => {
    expect(deriveCertificateStatus(emittedBeforeFix, '2026-03-12T23:59:59-06:00', GALAPAGOS)).toBe('expiring');
    expect(deriveCertificateStatus(emittedBeforeFix, '2026-03-13T00:00:00-06:00', GALAPAGOS)).toBe('expired');
  });

  it('sin zona, el continente sigue exactamente igual', () => {
    // El mismo instante en Quito ya es el 13 a las 00:15: ahí sí está vencido.
    expect(deriveCertificateStatus(emittedBeforeFix, quarterPastElevenOnTheIsland)).toBe('expired');
  });

  it('lo que se emite desde ahora ya lleva la hora de la isla', () => {
    // Antes del fix, este caso devolvía '2026-03-12T23:59:59-05:00'.
    expect(computeValidity('2025-03-12T20:40:00.000Z', GALAPAGOS).until).toBe('2026-03-12T23:59:59-06:00');
  });
});
```

**Prevención**

El test de arriba, que fija los dos bordes en la hora de la isla. Y una pregunta en la lista de alta de un cliente nuevo, que es donde este bug entró: **¿el activo está en UTC−5?** Si la respuesta es no, el activo lleva su `timeZone` antes de su primera inspección, no después de su primer ticket.

```bash
# Y la alarma que ya existía, para leerla cada vez que se incorpora un país o una isla:
grep -n "⚠️" src/app/core/time/business-day.ts
```

**Por qué llegó a producción**

El supuesto era verdad cuando se escribió. En 2022 los tres países de Plomada estaban en UTC−5 sin cambio de hora, y `CERTCORE_TIME_ZONE_OFFSET` era la decisión correcta: un número, en un archivo, con un aviso para el día en que dejara de serlo. Ese día llegó en 2024 por la puerta comercial —un contrato de Aurum, un cliente nuevo dado de alta desde la pantalla— y en el alta de un cliente nadie lee `business-day.ts`.

Después, el síntoma hizo el resto. Dura **una hora al año por activo**, de 23:00 a 23:59 del último día y en la hora de la isla, cuando nadie de Plomada está trabajando. La primera vez que alguien miró el certificado a esa hora fue con un cliente al lado.

**Si tu causa fue distinta a esta**

Si cambiaste `CERTCORE_TIME_ZONE_OFFSET` a `-06:00`, arreglaste el Inn y rompiste todos los demás activos: ahora el continente vence a la una de la mañana del día siguiente. Si corregiste el `validUntil` del certificado en la base de datos, el síntoma se va, pero reescribiste un documento ya emitido, y el PDF que el administrador tiene impreso dice otra cosa que el sistema. El histórico es de la auditoría. Y si concluiste que es el incidente 15 otra vez, mira la Pista 2 de aquél: aquí no hay `toISOString()` ni navegador de por medio, y el bug se reproduce igual con todas las máquinas en Bogotá.

</details>

---

