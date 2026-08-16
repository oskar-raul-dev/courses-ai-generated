# 📦 Fase 09 — Entrega y PDF en cliente

> Tutorial Angular 8 — Laboratorio clínico · Fase 9 de 14 · **8 horas**
> Depende de: Fase 8 — Resultados y rangos versionados
> Habilita: Fase 11 — Trazabilidad y audit log · Fase 12 — Testing desde cero + coverage
> Apéndices de apoyo: [A08 (PDF en cliente)](./a08-pdf-cliente.md) · [A07 (i18n en Angular 8)](./a07-i18n.md) · [A06 (NgRx 8)](./a06-ngrx.md) · [A05 (RxJS de supervivencia)](./a05-rxjs.md) · [Incidentes asociados](./cuaderno-incidentes.md): 14, 15

---

## 🎯 1. Propósito

La Fase 8 dejó un resultado validado: un número con un veredicto congelado, firmado por alguien, contra una versión de rango que ya no se mueve. Todo eso vive adentro del sistema. Esta fase lo saca: toma ese resultado y lo imprime en un documento que se le entrega a alguien —un PDF que se descarga, se adjunta, se archiva—, y cuando la orden se entrega, la empuja a su estado terminal `delivered`. Es la primera vez que un dato del sistema cruza la frontera hacia afuera en un formato que ya no es una pantalla de Angular, sino un archivo que sobrevive por su cuenta.

Lo que te importa a ti, que vas a *mantener* esto, es que un informe entregado es una foto, y las fotos mienten de una manera muy específica: muestran el momento en que se tomaron, no el momento en que las miras. El bug central de esta fase no es que el PDF salga feo ni que reviente: es que el PDF sale **con datos viejos**. Alguien abre la vista del informe, se distrae, mientras tanto el resultado cambia en otra pestaña o por otro usuario, y cuando por fin genera el PDF, el documento imprime lo que había cuando abrió la vista, no lo que hay ahora. En un sistema clínico eso es un informe entregado con un valor que ya no es cierto, y nadie se entera hasta que alguien compara el papel con la pantalla. Aprender a rastrear de dónde salió esa copia vieja —a distinguir entre lo que está en el store y lo que se congeló al abrir la vista— es el músculo de esta fase.

Hay una segunda razón, más terrena: los acentos. El informe sale en tres idiomas, y el francés está lleno de `é`, `à`, `ç`, `ê`. La librería de PDF que usa LabCore no embebe por defecto una fuente que sepa dibujar esos glifos, así que salen como símbolos raros o cuadraditos. Es un bug clásico de encoding, muy visible, muy reproducible, y es el incidente 15. Saber por qué pasa —y por qué solo pasa en francés y no en español, aunque el español también tenga acentos— te enseña algo sobre cómo un PDF no es texto, es dibujo.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Navegas a la vista de informe de un resultado **validado** y ves un botón "Generar PDF". Al presionarlo, el navegador descarga un archivo `.pdf` con el `value`, la `unit`, el veredicto (dentro / fuera / crítico), la versión de rango aplicada (`rangeVersionApplied`), y quién y cuándo lo validó.
- [ ] El PDF sale en el idioma activo de la aplicación: si cambias el selector de idioma a francés y regeneras, las etiquetas del documento salen en francés, resueltas desde las mismas claves i18n de la interfaz.
- [ ] Un resultado que **no** está validado no ofrece el botón de generar: un informe es la foto de algo firmado, y lo que no está firmado todavía puede cambiar.
- [ ] Con la fuente por defecto de la librería, las etiquetas en francés muestran los acentos rotos (símbolos raros en lugar de `é`, `à`, `ç`). Tras registrar la fuente embebida del apéndice A08, los mismos acentos salen bien. Puedes ver la diferencia abriendo el PDF antes y después del registro.
- [ ] Entregas un informe de una orden que está en `complete` y en Redux DevTools ves entrar `[Orders] Mark Delivered` → `[Orders] Mark Delivered Success` → recarga de la orden, y su `status` pasa a `delivered`. El registro guarda `deliveredBy` y `deliveredAt`.
- [ ] Intentas entregar una orden que **no** está en `complete` (por ejemplo `partial_results`) despachando `markDelivered` a mano desde DevTools, y el reducer lo rechaza en silencio: no cambia el estado, no sale acción de éxito, no hay `PATCH` en Network. La guarda `complete → delivered` vive en el reducer, no en el botón.
- [ ] Reproduces el dato stale: abres la vista del informe, cambias el `value` del resultado por otra vía (DevTools o una segunda pestaña), generas el PDF, y el documento sale con el valor **viejo** —el que había al abrir la vista—, no con el nuevo. Localizas en el código la línea donde se tomó la copia.

---

## 🚫 3. Qué NO entra todavía

- La **firma digital real** del PDF —una firma criptográfica que garantice que el documento no se alteró— → **fuera de alcance del curso** (ALCANCE §8). Acá "firmar" sigue siendo estampar quién y cuándo, igual que en la Fase 8; el PDF es un documento sin protección criptográfica.
- El **envío por correo** del informe —mandarlo a un destinatario, adjuntarlo a un mail— → **fuera de alcance**. Acá el informe se **genera y se descarga** en el navegador; qué se hace con el archivo después no es problema de esta fase.
- El **audit log de la entrega** —registrar el evento de entrega en una bitácora reconstruible— → **Fase 11**. Acá la entrega estampa `deliveredBy`/`deliveredAt` en la orden, pero no deja un asiento de auditoría aparte. El cruce results→orders de la Fase 8 y la entrega de esta fase son justamente dos de los eventos que el audit log de la Fase 11 tendrá que reconstruir.
- El **conteo fino de "¿la orden está lista para entregarse?"** —verificar que todas sus muestras estén procesadas y todos sus resultados validados antes de permitir `complete → delivered`— → hereda el esqueleto del `pushOrderAfterValidate$` de la Fase 8 (que quedó como gancho) y se deja como ejercicio. Acá la guarda protege la transición `complete → delivered`; que la orden *haya llegado* legítimamente a `complete` es responsabilidad del cruce de la Fase 8.
- El **tamaño del bundle** que la librería de PDF agrega, y la carga diferida para que no infle el arranque → **apéndice A08**. Acá se importa directo; que eso pese lo discute el apéndice.
- La **generación en servidor** del PDF —armarlo en un backend con acceso a datos frescos, que sería la cura de raíz del stale— → no existe backend propio (ALCANCE §8). Se menciona como "lo correcto hoy" en la deuda 💸 y no se construye.

---

## 🧠 4. Concepto mínimo

### El problema antes que la herramienta

Hasta acá, todo lo que el sistema mostraba lo leía del store en el momento de mostrarlo. Abres la lista de resultados y ves lo que hay *ahora*; si algo cambia, la vista se entera porque está suscrita al store. Esa es la promesa de NgRx: una sola fuente de verdad, y todas las vistas reflejándola en vivo.

Un PDF rompe esa promesa, y la rompe por su naturaleza. Un PDF no es una vista suscrita: es un archivo que se arma una vez, con los datos que había en el instante exacto de armarlo, y a partir de ahí es piedra. No se actualiza. No se entera de nada. Si el dato cambia después de generarlo, el PDF sigue diciendo lo que decía. Eso, por sí solo, no es un bug: es lo que un documento *es*. El bug aparece cuando la copia que el PDF imprime no es la del instante de generar, sino una **más vieja todavía**.

Y así es exactamente como lo hace LabCore. La vista del informe, al abrirse, toma una copia del resultado y la guarda en una propiedad del componente. El botón "Generar PDF" arma el documento desde esa copia. Entre que abres la vista y presionas el botón pueden pasar segundos o minutos, y en ese lapso el resultado pudo cambiar —otro usuario lo tocó, tú lo editaste en otra pestaña, una recarga trajo datos nuevos—. El PDF no imprime lo que hay cuando presionas el botón; imprime lo que había cuando abriste la vista. Esa distancia entre "cuándo se tomó la copia" y "cuándo se usó la copia" es la deuda 💸 de esta fase, y es la raíz del incidente 14.

La pregunta que tienes que aprender a hacerte no es "¿por qué el PDF tiene datos viejos?" sino "¿en qué instante se tomó la foto?". Casi siempre la respuesta está en un `ngOnInit` que copió el estado a una variable local y nunca lo volvió a mirar.

### Los acentos: un PDF no es texto, es dibujo

El segundo concepto es más concreto. Cuando escribes texto en una página HTML, el navegador tiene todas las fuentes del sistema y sabe dibujar cualquier glifo. Un PDF no: un PDF **embebe** las fuentes que usa, o referencia un puñado de fuentes "estándar" que se supone que todo lector de PDF tiene. Esas fuentes estándar —Helvetica, Times, Courier— nacieron para el alfabeto latino básico y cubren bien el inglés, razonablemente el español, y mal otros idiomas. Cuando le pides que dibuje un glifo que no tiene, o cuando el texto llega codificado de una forma que la fuente no espera, sale un símbolo de reemplazo: un cuadradito, un signo raro, nada.

El francés es donde más duele porque acumula acentos y diacríticos que caen fuera del set básico según cómo se codifique el texto, y porque las etiquetas del informe en francés (`Résultat`, `Référence`, `Validé par`) los llevan casi todas. La solución no es "arreglar el acento": es **embeber una fuente que sepa dibujarlo**, registrándola en la librería antes de escribir texto. Eso es plomería, vive en el apéndice A08, y acá se muestra el mínimo para que funcione y para entender por qué sin ese paso el PDF miente en francés.

### La entrega: la máquina de órdenes se endurece, por fin

La tercera pieza es el marcado de entrega. El flujo canónico de una orden termina en `pending → in_process → partial_results → complete → delivered → expired`. Las Fases 5, 7 y 8 construyeron casi todo ese flujo, pero `delivered` quedó siempre para después: la Fase 5 lo dejó fuera del seed a propósito, la Fase 8 empujó la orden solo hasta `complete`. Esta fase es donde `complete → delivered` por fin ocurre, y es la primera transición de la máquina de **órdenes** que se protege con una guarda de reducer real.

Fíjate en el paralelo con lo que ya sabes. La muestra endureció su máquina en la Fase 7 con `sample.transitions.ts` y `canTransition`. El resultado endureció la suya en la Fase 8 con `result.transitions.ts` y `canValidate`. La orden lo hace acá, con un `order.transitions.ts` y su propio `canTransition` —misma forma, misma lección—. Que esas tres funciones tengan la misma estructura y ninguna esté factorizada en una utilidad común es la misma deuda de dispersión que la Fase 7 declaró y la 8 repitió: acá se repite una tercera vez, por fidelidad a LabCore.

### Nota de época

En 2019, generar PDFs en el cliente con jsPDF era la opción de bajo esfuerzo: una librería, un `import`, y `doc.text(...)` / `doc.save(...)`. La alternativa —generar en el servidor con algo como wkhtmltopdf o un headless Chrome— daba PDFs impecables con acentos y layout de verdad, pero exigía un backend que armara documentos, y el equipo no lo tenía ni lo quería. Así que el PDF se arma en el navegador, con las limitaciones de fuente que eso trae, y con el dato que el componente tenga a mano —que resultó ser el dato viejo—. Hoy la decisión sería la misma si sigues sin backend; y si tuvieras backend, el stale desaparecería casi solo, porque el servidor leería el dato fresco al momento de armar el PDF. No vas a migrar: vas a mantener el jsPDF que ya está.

---

## 💻 5. Código mínimo con comentarios

Esta fase tiene una pieza genuinamente nueva —el armado del PDF en un servicio (§5.1)— y tres que reusan moldes conocidos: el componente gordo que copia el estado y dispara la generación (§5.2), el registro de fuente para los acentos (§5.3), y el marcado de entrega, que es el molde de acciones/reducer/effect de la Fase 8 aplicado a una transición de orden (§5.4).

> **Versión de la librería.** LabCore usa **`jspdf@1.5.3`**, la línea de la época (2018-2019) y la que empareja con el resto del stack. La API es la de esa versión: `new jsPDF()` como constructor, `.text(text, x, y)`, `.setFont(...)`, `.addFileToVFS(...)` / `.addFont(...)` para fuentes, `.save(filename)`. ⚠️ La `2.x` cambió los imports (`import { jsPDF } from 'jspdf'`) y varios métodos; si la doc que consultas usa esa forma, no es la tuya — y esa diferencia de `import` es, de hecho, la forma más rápida de fechar cualquier respuesta que encuentres sobre jsPDF (**A08 §⚠️**).

### 5.1 `report.service.ts` — armar el documento

El servicio recibe un **snapshot ya congelado** del resultado —no lee del store— y devuelve el PDF listo para descargar. Que reciba los datos en vez de buscarlos es deliberado y es media lección de la fase: el servicio no decide *cuándo* se tomó la foto, solo la dibuja. Quién le pasa el snapshot, y de qué instante es, lo decide el componente (§5.2), y ahí está la deuda.

```typescript
// src/app/reports/report.service.ts
import { Injectable } from '@angular/core';
import { TranslateService } from '@ngx-translate/core';
import * as jsPDF from 'jspdf';

import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class ReportService {

  constructor(private translate: TranslateService) { }

  // Recibe un snapshot -un objeto plano con los datos del resultado tal como
  // estaban cuando el componente lo copio- y arma el PDF. NO lee del store: si
  // lo leyera acá, el dato sería fresco y no habría bug que enseñar, pero
  // tampoco reflejaría como funciona LabCore, que copia en la vista y
  // arma desde la copia. El instante de la foto lo fija el componente, no este
  // servicio.
  generate(snapshot: any): void {
    // Constructor de la 1.5.3. En la 2.x sería new jsPDF({ ... }) con imports
    // distintos; ver la nota de versión arriba.
    var doc = new (jsPDF as any)();

    // Las etiquetas salen de i18n, resueltas AHORA con instant() porque un PDF
    // es texto plano: no hay pipe translate ni binding que reaccione. Se toma
    // el idioma activo de la aplicación tal como quedó en la Fase 2.
    var t = this.translate;

    // Título del informe.
    doc.setFontSize(16);
    doc.text(t.instant('report.title'), 20, 20);

    // Cuerpo. Cada línea es una etiqueta i18n + un dato del snapshot. Se dibuja
    // a mano con coordenadas absolutas: jsPDF no tiene layout, tiene un lápiz y
    // un plano cartesiano. La y crece hacia abajo.
    doc.setFontSize(11);

    doc.text(t.instant('report.value') + ': ' + snapshot.value + ' ' + snapshot.unit, 20, 40);

    // El veredicto ya viene resuelto a una clave i18n en el snapshot (dentro /
    // fuera / crítico / sin rango). El componente lo calculó con evaluateResult
    // de la Fase 8 al tomar la foto; acá solo se traduce la clave.
    // report.verdictLabel es el rotulo ("Veredicto"); report.verdict.* son los
    // cuatro valores. Tienen que ser claves distintas: en un árbol JSON anidado,
    // "report.verdict" no puede ser una cadena y un objeto a la vez, y si alguien
    // lo intenta el pipe devuelve [object Object] (A07 §4).
    doc.text(t.instant('report.verdictLabel') + ': ' + t.instant(snapshot.verdictKey), 20, 50);

    // La versión de rango que se aplicó al validar. Es el dato que hace al
    // informe reconstruible: dice contra qué norma se juzgó este número.
    doc.text(t.instant('report.rangeVersion') + ': ' + snapshot.rangeVersionApplied, 20, 60);

    // Quién y cuándo validó, formateado en la zona de la aplicación. La fecha se
    // formatea a mano porque acá no hay pipe date: se usa el mismo timeZone de
    // environment que la Fase 2 fijo, vía toLocaleString con timeZone explicito.
    doc.text(t.instant('report.validatedBy') + ': ' + snapshot.validatedBy, 20, 70);
    doc.text(
      t.instant('report.validatedAt') + ': ' + this.formatDate(snapshot.validatedAt),
      20, 80
    );

    // save() dispara la descarga en el navegador. El nombre del archivo lleva el
    // id del resultado para que dos informes no se pisen en la carpeta de
    // descargas.
    doc.save('report-' + snapshot.resultId + '.pdf');
  }

  // Formatea una fecha ISO en la zona de la aplicación (America/Bogotá, fijada
  // en environment desde la Fase 2). Se usa toLocaleString con timeZone porque
  // acá no corre el pipe date de Angular: estamos fuera de una plantilla.
  // 💸 Misma deuda de fondo que 5.3 de la Fase 8: la zona está bien fijada acá,
  // pero el validatedAt que llega fue estampado en cliente al validar, así que
  // arrastra la imprecisión de origen. No se paga en Track A.
  formatDate(iso: string): string {
    if (!iso) { return ''; }
    return new Date(iso).toLocaleString('es-CO', { timeZone: environment.timeZone });
  }
}
```

**Detalles con intención**

- `import * as jsPDF from 'jspdf'` y `new (jsPDF as any)()` son la forma de la `1.5.3` bajo TypeScript 3.5 con `esModuleInterop` no siempre activo. El `as any` es TS-0 puro y va comentado: la librería de la época no trae tipos limpios para esta forma de importar, y forzarla es más barato que pelear con la configuración del compilador. En la `2.x` esto se escribe distinto; no es tu versión.
- El servicio **recibe** el snapshot, no lo busca. Esa es la decisión que hace posible el bug: si `generate()` inyectara el `Store` y leyera el resultado fresco, no habría stale. Al recibirlo, delega en el componente la responsabilidad de *cuándo* se tomó la foto, y el componente la toma mal (§5.2).
- El veredicto viaja como **clave i18n ya resuelta** (`verdictKey`), no como el valor comparado. El cálculo (`evaluateResult` de la Fase 8) se hizo al tomar la foto; el servicio no recalcula nada, solo traduce. Si recalculara acá contra el rango vigente *hoy*, un informe de marzo podría cambiar de veredicto en junio, que es exactamente lo que la Fase 8 prohibió.

### 5.2 `ReportComponent` — la copia del estado y la deuda 💸 del stale

El componente carga el resultado al abrir la vista, **copia** los datos que el informe va a necesitar a una propiedad local `reportSnapshot`, y el botón genera el PDF desde esa copia. Toda la lógica adentro del componente, como manda el estilo de LabCore.

```typescript
// src/app/reports/report/report.component.ts
import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { Store } from '@ngrx/store';

import { ReportService } from '../report.service';
import { selectActiveRange, evaluateResult } from '../../results/store/reference-range.selector';

@Component({
  selector: 'app-report',
  templateUrl: './report.component.html'
})
export class ReportComponent implements OnInit {

  resultId: number = null;

  // La FOTO. Se llena una sola vez, al abrir la vista, y de acá sale el PDF.
  // 💸 DEUDA INTENCIONAL: esta copia se toma en ngOnInit y no se vuelve a
  // refrescar. Si el resultado cambia después -otro usuario, otra pestaña, una
  // recarga- este snapshot sigue teniendo el valor viejo, y el PDF sale con el
  // valor viejo. Es el incidente 14.
  reportSnapshot: any = null;

  canDeliver: boolean = false;

  constructor(
    private route: ActivatedRoute,
    private store: Store<any>,
    private reportService: ReportService
  ) { }

  ngOnInit() {
    // El id del resultado y el de su orden vienen de la ruta: /reports/:resultId.
    // Se leen con snapshot y no con paramMap porque esta vista NO se reusa entre
    // resultados -se entra desde el listado y se sale-, así que el componente se
    // construye de nuevo cada vez. Si algun día se pudiera navegar de un informe
    // a otro sin salir, esto sería el bug de la Fase 7 §6.
    this.resultId = Number(this.route.snapshot.paramMap.get('resultId'));

    // Se lee el resultado del store UNA vez, al abrir la vista. take(1) NO
    // está: es una suscripción viva, pero el snapshot se arma solo la primera
    // vez que llega un valor, y después no se vuelve a tocar. Esa es la trampa:
    // el store sigue emitiendo valores frescos, pero nadie los mira.
    this.store.select(function (state: any) { return state.results; })
      .subscribe(function (this: ReportComponent, resultsState: any) {
        if (!resultsState || this.reportSnapshot) {
          // Si ya hay snapshot, no se refresca. Acá está el bug hecho código:
          // el "if (this.reportSnapshot) return" congela la foto en el primer
          // valor y descarta todos los siguientes.
          return;
        }

        // Por id, no por posición. Un items[0] funciona mientras la muestra
        // tenga un solo resultado y produce el informe del analito equivocado en
        // cuanto tenga dos, que es el caso normal (Fase 8 §5.1 siembra glucosa y
        // TSH sobre la misma muestra).
        var items = resultsState.items || [];
        var result = items.find(function (this: ReportComponent, r: any) {
          return r.id === this.resultId;
        }.bind(this));

        if (!result || result.status !== 'validated') {
          // Un informe solo se genera de un resultado validado. Sin validar, no
          // hay foto y el botón no aparece (ver plantilla).
          return;
        }

        // Se calcula el veredicto AL TOMAR LA FOTO, contra el rango que aplicó
        // al validar. Se usa rangeVersionApplied congelado en la Fase 8, no el
        // rango vigente hoy: el informe reproduce el juicio original.
        var ranges = resultsState.referenceRanges || [];
        var appliedRange = ranges.find(function (r: any) {
          return r.analyte === result.analyte && r.version === result.rangeVersionApplied;
        });
        var verdict = evaluateResult(result.value, appliedRange);

        // El snapshot lleva SOLO lo que el PDF necesita, ya resuelto. A partir
        // de acá el ReportService no necesita el store para nada.
        this.reportSnapshot = {
          resultId: result.id,
          value: result.value,
          unit: result.unit,
          verdictKey: this.verdictToKey(verdict),
          rangeVersionApplied: result.rangeVersionApplied,
          validatedBy: result.validatedBy,
          validatedAt: result.validatedAt
        };
      }.bind(this));

    // Si la orden de este resultado está en complete, se puede entregar. Se lee
    // aparte del slice de órdenes. Misma foto-al-abrir: tampoco se refresca.
    //
    // El slice de ordenes tiene la forma que fijo la Fase 6: { items, loading,
    // error, selectedId, saving, saveError, filter }. NO tiene un "current": el
    // molde del curso guarda el id y deriva el objeto con un selector, que es la
    // regla de A06 §8. Y ojo con el otro caso: si el usuario entro por enlace
    // directo sin pasar por /orders, el slice no esta registrado y "ordersState"
    // llega undefined, no vacío (A06 §6).
    this.store.select(function (state: any) { return state.orders; })
      .subscribe(function (this: ReportComponent, ordersState: any) {
        var orders = (ordersState && ordersState.items) || [];
        var order = orders.find(function (this: ReportComponent, o: any) {
          return this.reportSnapshot && o.id === this.reportSnapshot.orderId;
        }.bind(this));
        this.canDeliver = !!order && order.status === 'complete';
      }.bind(this));
  }

  // Traduce el resultado de evaluateResult a una clave i18n. Cuatro casos, como
  // en la Fase 8: sin rango, crítico, fuera, dentro.
  verdictToKey(verdict: any): string {
    if (!verdict.hasRange) { return 'report.verdict.noRange'; }
    if (verdict.critical) { return 'report.verdict.critical'; }
    if (verdict.outOfRange) { return 'report.verdict.outOfRange'; }
    return 'report.verdict.inRange';
  }

  // El botón. Genera desde el snapshot, no desde el store. Si el resultado
  // cambio desde que se abrió la vista, este PDF NO se entera.
  onGenerate() {
    if (!this.reportSnapshot) { return; }
    this.reportService.generate(this.reportSnapshot);
  }

  // Entregar la orden. Despacha markDelivered; la guarda del reducer decide si
  // procede. El componente no verifica el estado: eso es del reducer (5.4).
  onDeliver(orderId: number) {
    this.store.dispatch({ type: '[Orders] Mark Delivered', orderId: orderId });
  }
}
```

**Detalles con intención**

- El `if (this.reportSnapshot) return` es la deuda escrita en una línea. Congela la foto en el primer valor que llega del store y descarta todo lo posterior. **Lo correcto hoy** sería no guardar un snapshot en el componente y, en su lugar, leer el resultado fresco del store en el instante de generar (un `select(...).pipe(take(1))` dentro de `onGenerate`), o —mejor— armar el PDF en un servidor que lea el dato al momento. **En Track A no se paga** porque LabCore copia en la vista exactamente así, y el informe con datos viejos que produce es el incidente 14, que tienes que aprender a reproducir y localizar. Arreglarlo acá borraría el ejercicio.
- La suscripción **no** lleva `take(1)`, y eso es a propósito y es cruel: parece que el componente está escuchando el store en vivo (la suscripción está abierta), pero el `if (this.reportSnapshot) return` la vuelve sorda después del primer valor. Un lector apurado ve la suscripción viva y asume datos frescos. La mentira está en el `return`, no en la suscripción. Es material del forense de §6.
- La suscripción tampoco se limpia en `ngOnDestroy`. Es la deuda de suscripción huérfana que la Fase 10 (dashboard) convierte en su tema central; acá queda anotada. Ejercicio 23.
- El veredicto se congela en el snapshot contra `rangeVersionApplied`, no contra el rango de hoy. Si lo recalcularas contra el vigente, un informe reimpreso meses después podría cambiar de color. La Fase 8 congeló la versión justamente para que esto no pase; el informe la respeta.

### 5.3 Fuentes y acentos — el mínimo para que el francés no se rompa

Por defecto jsPDF usa Helvetica, que dibuja mal los acentos según cómo llegue codificado el texto. Se arregla registrando una fuente TrueType embebida —acá **Roboto**, por licencia Apache 2.0 y por cubrir el latín extendido completo— en el VFS de la librería, antes de escribir texto. El registro completo —de dónde sale el `.ttf`, cómo se convierte a base64, la variante `bold` y las tres formas de que la fuente no viaje en el arranque— vive en el **apéndice A08 §3 y §5**. Acá está el mínimo ejecutable y por qué hace falta.

```typescript
// src/app/reports/report-fonts.ts

// El .ttf convertido a base64. En LabCore este string vive en su propio
// archivo (pesa cientos de KB) y se importa. Acá se muestra recortado.
// El detalle de cómo se genera está en el apéndice A08.
export var ROBOTO_REGULAR_BASE64 = 'AAEAAAARAQAABAAQ...'; // (recortado)

// Registra la fuente en el VFS de jsPDF y la deja disponible por nombre. Hay
// que llamar esto ANTES de escribir cualquier texto con acentos. Recibe la
// instancia de doc porque en la 1.5.3 el VFS es por instancia.
export function registerLatinFont(doc: any): void {
  // addFileToVFS mete el binario (en base64) en el sistema de archivos virtual
  // de jsPDF con un nombre de archivo. addFont lo asocia a una familia y estilo
  // usables con setFont. Sin estos dos pasos, setFont('Roboto') no encuentra
  // nada y jsPDF cae de vuelta a Helvetica, que rompe los acentos.
  doc.addFileToVFS('Roboto-Regular.ttf', ROBOTO_REGULAR_BASE64);
  doc.addFont('Roboto-Regular.ttf', 'Roboto', 'normal');
  doc.setFont('Roboto');
  // Acá se registra SOLO la variante normal, que es lo que este informe usa.
  // Si alguien escribe un título con setFont('Roboto', 'bold') sin registrar
  // esa variante, jsPDF cae en silencio a Helvetica y los acentos se rompen
  // solo en negrita. El registro completo está en el apéndice A08 §3.
}
```

Y en el servicio (§5.1), la primera línea después de crear el `doc`:

```typescript
    var doc = new (jsPDF as any)();

    // Registrar la fuente latina ANTES de escribir. Si esta línea falta o corre
    // después del primer text(), los acentos del francés salen rotos: el
    // incidente 15. El orden importa porque setFont solo afecta al texto que
    // viene DESPUÉS de llamarlo.
    registerLatinFont(doc);
```

**Detalles con intención**

- El orden es todo. `setFont` solo afecta al texto dibujado *después* de la llamada. Si registras la fuente después del primer `doc.text(...)`, ese primer texto ya salió en Helvetica con los acentos rotos, y los siguientes salen bien: un PDF donde el título está roto y el cuerpo está sano. Ese síntoma parcial es una pista forense (§6).
- El español "casi" no se rompe y el francés sí, y eso confunde. Muchos acentos españoles (`á`, `é`, `í`, `ó`, `ú`, `ñ`) caen dentro o cerca del set que Helvetica maneja en la codificación por defecto; varios diacríticos franceses no. Por eso el bug "solo aparece en francés" aunque el español también lleve tildes: no es que el francés sea especial, es que el francés cruza más seguido el borde del set básico.
- La fuente pesa. Cientos de KB en base64 dentro del bundle, cargados aunque el usuario nunca genere un PDF. Eso es material del apéndice A08 (PDF en cliente), donde se mide el peso real y se discute la carga diferida del módulo de reportes. Acá se importa directo y se anota la deuda; ejercicio 28.

### 5.4 Marcado de entrega — la máquina de órdenes se endurece

Acá nace `order.transitions.ts`, el tercer mapa de transiciones del curso, y la guarda `complete → delivered` en el reducer de órdenes. Sigue el molde exacto de la Fase 8: acción, guarda en el reducer, effect que hace el `PATCH` con la evidencia de custodia.

```typescript
// src/app/orders/store/order.transitions.ts

// Misma forma que sample.transitions.ts (Fase 7) y result.transitions.ts
// (Fase 8). Un mapa plano de estado -> estados a los que puede ir. Que esta sea
// la tercera copia de la misma idea, sin factorizar, es la deuda de dispersión
// que la Fase 7 declaró; se repite por fidelidad a LabCore. Ejercicio 26.
var ORDER_TRANSITIONS: any = {
  pending: ['in_process', 'expired'],
  in_process: ['partial_results', 'expired'],
  partial_results: ['complete', 'expired'],
  // La transición que esta fase construye. complete solo puede ir a delivered
  // (entregar) o a expired (vencer sin entregar). No vuelve atrás.
  complete: ['delivered', 'expired'],
  // delivered es terminal: un informe entregado no se "desentrega". Igual que
  // validated en resultados y discarded en muestras.
  delivered: [],
  expired: []
};

// Un estado de origen desconocido devuelve false: defensa contra órdenes viejas
// con un status que ya no existe en el flujo. Misma lección que la Fase 7.
export function canTransition(from: string, to: string): boolean {
  var allowed = ORDER_TRANSITIONS[from];
  return !!allowed && allowed.indexOf(to) >= 0;
}
```

```typescript
// src/app/orders/store/orders.actions.ts (fragmentos que se agregan)
import { createAction, props } from '@ngrx/store';

// Entregar una orden: la lleva de complete a delivered. El "por quien" y el
// "cuando" los resuelve el effect al momento del PATCH, igual que validateResult
// en la Fase 8. La acción lleva solo el id.
export const markDelivered = createAction(
  '[Orders] Mark Delivered',
  props<{ orderId: number }>()
);

export const markDeliveredSuccess = createAction(
  '[Orders] Mark Delivered Success',
  props<{ order: any }>()
);

export const markDeliveredFailure = createAction(
  '[Orders] Mark Delivered Failure',
  props<{ error: any }>()
);
```

```typescript
// src/app/orders/store/orders.reducer.ts (el case que se agrega)
import { canTransition } from './order.transitions';

// ... dentro del switch (action.type) del ordersReducer:

    // La guarda de entrega. Se busca la orden, se consulta canTransition
    // (complete -> delivered legal; cualquier otra cosa -> ilegal), y si no
    // procede se devuelve el estado intacto: la orden no se mueve, "saving" no
    // se enciende, no hay éxito que despachar. Esto hace IMPOSIBLE por
    // construcción entregar una orden que no está en complete, venga la acción
    // de un botón o de alguien tecleando en DevTools.
    case OrdersActions.markDelivered.type: {
      var target = state.items.find(function (o: any) { return o.id === action.orderId; });
      if (!target || !canTransition(target.status, 'delivered')) {
        return state;
      }
      return { ...state, saving: true, saveError: null };
    }

    case OrdersActions.markDeliveredSuccess.type:
      return { ...state, saving: false };

    case OrdersActions.markDeliveredFailure.type:
      return { ...state, saving: false, saveError: action.error };
```

```typescript
// src/app/orders/store/orders.effects.ts (el effect que se agrega)

  markDelivered$ = createEffect(function (this: OrdersEffects) {
    return this.actions$.pipe(
      ofType(OrdersActions.markDelivered),
      mergeMap((action: any) => {
        // El PATCH lleva el estado nuevo Y la evidencia de custodia: quien
        // entregó y cuándo. Mismo estampado en cliente de la Fase 8, misma
        // deuda 💸: en un sistema serio el deliveredAt lo pone el servidor, no
        // el navegador. No se paga en Track A.
        var patch: any = {
          status: 'delivered',
          deliveredBy: this.authService.getCurrentUser(),
          deliveredAt: new Date().toISOString()
        };
        return this.ordersService.update(action.orderId, patch).pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function (updated: any) {
            return OrdersActions.markDeliveredSuccess({ order: updated });
          }),
          catchError(function (error: any) {
            return of(OrdersActions.markDeliveredFailure({ error: error }));
          })
        );
      })
    );
  }.bind(this));
```

**Detalles con intención**

- La guarda vive en el **reducer**, no en el botón. El componente (§5.2) despacha `markDelivered` sin verificar nada; el reducer decide. Por eso `canDeliver` en el componente es solo para *mostrar u ocultar el botón* (experiencia de usuario), no una defensa: si alguien despacha la acción a mano sobre una orden en `partial_results`, la guarda la frena igual. Es la misma separación que la Fase 7 enseñó entre deshabilitar una opción y protegerla.
- `ORDER_TRANSITIONS` es la tercera copia del mismo patrón, sin factorizar. La Fase 7 ya declaró esta deuda de dispersión, la 8 la repitió con `canValidate`, y acá se repite una vez más. Unificar las tres en una utilidad genérica es tentador y es el ejercicio 26 — con la advertencia de que no son tan iguales como parecen, y las diferencias las tienes delante: la de muestras tiene un estado (`discarded`) alcanzable desde cuatro sitios distintos, la de resultados tiene una sola transición legal en todo el mapa, y esta tiene dos terminales en vez de uno. Una unificación apresurada las aplana y descubres cuál importaba tres meses después.
- El effect reusa `this.ordersService.update` —el mismo método `PATCH` del CRUD de órdenes que construiste en el ejercicio 1 de la Fase 6—. Si tu `OrdersService` no tiene `update`, es el método genérico de `PATCH` que la Fase 5 dejó como molde y la 6 copió; acá se le pasa un patch con tres campos en vez de uno.

> **Prueba de fuego.** Levanta el mock, entra a la vista de informe de un resultado validado y genera el PDF: se descarga con el valor, el veredicto y la firma. Cambia el idioma a francés y regenera: las etiquetas salen en francés y, si registraste la fuente, con los acentos bien. Ahora comenta la línea `registerLatinFont(doc)` y regenera en francés: los acentos se rompen. Vuelve a activarla. Por último, con la vista abierta, cambia el `value` del resultado desde Redux DevTools despachando `enterResult`, y sin recargar la página vuelve a generar el PDF: sale con el valor **viejo**. Esa es la foto vieja del incidente 14.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**El PDF sale con los acentos rotos solo en el título, el resto bien.**
Síntoma: `Résultat` en el encabezado sale con símbolos raros, pero `Référence` tres líneas abajo sale bien. Causa: `registerLatinFont(doc)` corre *después* del primer `doc.text(...)`. `setFont` solo afecta al texto dibujado después de la llamada, así que lo que se escribió antes quedó en Helvetica. Fix mínimo: mover el registro de la fuente a la primera línea después de `new jsPDF()`, antes de cualquier `text`. Fix correcto (que no harás en Track A): centralizar la creación del `doc` en una fábrica que registre la fuente siempre, para que sea imposible olvidarlo.

**El PDF sale con datos viejos aunque la pantalla muestre los nuevos.**
Síntoma: la vista muestra `value: 118` pero el PDF descargado dice `value: 105`. Causa: el `reportSnapshot` se tomó al abrir la vista, cuando el valor era 105, y el `if (this.reportSnapshot) return` impidió que se refrescara cuando llegó 118. La pantalla muestra 118 porque *otra* parte de la app sí está suscrita en vivo; el informe no. Fix mínimo para un hotfix urgente: refrescar el snapshot en `onGenerate` leyendo el store con `take(1)` en ese instante. Fix correcto: no guardar snapshot en el componente. Ver la deuda 💸 de §5.2 y el incidente 14.

**El botón "Generar PDF" no aparece.**
Síntoma: la vista carga pero no hay botón. Causa casi siempre: el resultado no está `validated`, y §5.2 no arma `reportSnapshot` para resultados sin validar. Menos frecuente: el resultado no llegó al store porque no se despachó `loadResults`. Fix: confirmar en DevTools que hay un resultado en `state.results.items` y que su `status` es `validated`. No es un bug del informe; es que no hay nada firmado que imprimir.

**Entregar una orden "no hace nada".**
Síntoma: presionas entregar (o despachas `markDelivered`) y el estado no cambia, sin error. Causa: la orden no está en `complete`, y la guarda `canTransition(from, 'delivered')` la rechazó devolviendo el estado intacto. Esto **no es un bug**: es la guarda funcionando. Fix: verificar el `status` de la orden antes de asumir que el botón está roto. Si la orden *sí* está en `complete` y aun así no pasa nada, entonces sí hay algo que mirar: revisar que el effect esté registrado en el `EffectsModule.forFeature` del `OrdersModule`.

### Pieza forense de esta fase

Lo que se debuggea acá es el **origen de la copia vieja del estado**: dado un PDF que salió con un dato que ya no es el actual, rastrear en qué instante se tomó la foto y por qué no se refrescó. El desarrollo completo —con la salida de DevTools transcrita, el diff entre `state.results.items` y `reportSnapshot`, y el paso a paso de la reproducción— vive en [`forense-fase-09.md`](./forense-fase-09.md). Acá queda el ejercicio de "rompe a propósito y observa".

**Rompe a propósito.** Abre la vista de informe de un resultado validado y deja el PDF sin generar. En Redux DevTools, despacha `enterResult` con el `resultId` de ese resultado y un `value` nuevo bien distinto (de 105 a 250, para que el veredicto cambie de "dentro" a "crítico"). Observa que `state.results.items` ahora tiene 250, y que la pantalla —si tiene una vista en vivo abierta— lo refleja. Ahora genera el PDF.

Lo que esperas ver: el PDF sale con **105** y veredicto "dentro", no con 250 y "crítico". La mentira que te va a contar la pantalla: si miras solo Redux DevTools, ves 250 y asumes que todo el mundo ve 250. El PDF no vive en el store: vive en `this.reportSnapshot`, que se congeló en 105 al abrir la vista. Para ver la verdad tienes que inspeccionar el componente, no el store —poner un breakpoint en `onGenerate` y mirar `this.reportSnapshot.value`, que sigue en 105 mientras el store grita 250—. El lugar correcto donde mirar no es el estado global; es la propiedad local del componente que nadie refresca.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Genera el PDF de tres resultados validados distintos y confirma que cada archivo descargado lleva el `resultId` correcto en su nombre. Abre uno y verifica que el `value` y la `unit` coinciden con los del store.
2. Cambia el idioma a inglés, luego a francés, y regenera el mismo informe cada vez. Anota qué etiquetas cambian y cuáles no, y explica por qué las que no cambian son un bug de i18n (una clave sin traducir cae al idioma por defecto).
3. Agrega una línea al PDF que imprima la unidad del resultado en una posición propia, con su etiqueta i18n `report.unit`. Verifica que la `y` que elijas no pise otra línea.
4. En `report.service.ts`, cambia el `doc.setFontSize(16)` del título a 22 y regenera. Confirma que solo el título cambia de tamaño y el cuerpo sigue en 11, y explica por qué `setFontSize` se comporta como `setFont`.
5. Comenta la línea `registerLatinFont(doc)` y genera un informe en francés. Describe exactamente qué ves en lugar de los acentos. Vuelve a activarla y confirma que se arreglan.
6. Localiza en `order.transitions.ts` qué devuelve `canTransition('complete', 'delivered')` y qué devuelve `canTransition('partial_results', 'delivered')`. Explica en una frase por qué la segunda es `false`.
7. Despacha `markDelivered` desde Redux DevTools sobre una orden que está en `complete` y confirma en Network que sale un solo `PATCH` con `status`, `deliveredBy` y `deliveredAt`. Luego abre `db.json` y verifica que la orden quedó en `delivered`.
8. Agrega la clave `report.title` a los tres archivos de traducción (es, en, fr) y confirma que el título del PDF sale traducido en cada idioma. Deja el francés con un acento (`Rapport de résultat`) para tener un caso de acento en el título.

**🟡 Intermedio (9–17)**

9. Reproduce el bug de acentos parciales: mueve `registerLatinFont(doc)` para que corra *después* del primer `doc.text(...)`. Confirma que el título sale roto y el cuerpo sano, y explica por qué el orden de las llamadas produce ese síntoma exacto.
10. Entrega una orden en `complete` y confirma que su `status` pasa a `delivered`. Después intenta entregarla otra vez despachando `markDelivered` de nuevo: confirma que el reducer la rechaza (ya no está en `complete`, está en `delivered`, que es terminal) y que no sale segundo `PATCH`.
11. En `report.component.ts`, el `if (this.reportSnapshot) return` congela la foto. Reemplázalo temporalmente por una versión que refresque el snapshot en cada emisión del store, genera un PDF tras cambiar el valor, y confirma que ahora sí sale fresco. Después revierte: entiende qué acabas de "arreglar" y por qué en Track A no se hace.
12. Formatea `validatedAt` en el PDF con y sin el `timeZone: environment.timeZone`. Con una fecha ISO cercana a medianoche, muestra que el día cambia según se aplique la zona o no, y conecta esto con la deuda de zona horaria de la Fase 8.
13. Agrega al PDF la versión de rango aplicada con su etiqueta `report.rangeVersion`. Genera un informe de un resultado validado contra la v1 de glucosa y otro contra la v2, y confirma que cada PDF imprime la versión que le corresponde, no la vigente hoy.
14. El `canDeliver` del componente muestra u oculta el botón, pero no protege nada. Demuéstralo: fuerza `canDeliver = false` en el componente, confirma que el botón desaparece, y aun así entrega la orden despachando la acción desde DevTools. Explica qué capa sí protege.
15. Genera un PDF de un resultado con veredicto "sin rango" (un analito sin rango vigente para su fecha). Confirma que el informe imprime la etiqueta `report.verdict.noRange` y no un veredicto en rojo o verde. Después, en el `es.json`, intenta poner una cadena en `report.verdict` **además** de la rama con los cuatro valores: anota qué imprime el PDF y por qué (A07 §4).
16. El effect `markDelivered$` usa `mergeMap`. Cambia a `switchMap`, entrega dos órdenes muy rápido, y razona si en este caso puntual la diferencia importa o no (¿se cancelan entregas de órdenes distintas?). Documenta tu conclusión.
17. **Diagnóstico.** Te pasan un informe donde `Validé par` sale con acento roto pero el resto del francés está bien. Sin ver el código, formula tres hipótesis de por qué solo esa línea falla, ordénalas por probabilidad, y di qué mirarías primero para confirmar.

**🟠 Difícil (18–24)**

18. **Diagnóstico.** Un usuario reporta: "generé el informe, dice glucosa 105 normal, pero en pantalla veo 118 fuera de rango". Reprodúcelo desde cero: abre la vista, cambia el valor por otra vía, genera. Localiza la línea exacta donde se tomó la foto vieja y explica por qué la pantalla y el PDF discrepan.
19. **Diagnóstico.** Sin tocar el store, demuestra con un breakpoint que `this.reportSnapshot.value` y `state.results.items[0].value` tienen valores distintos en el mismo instante. Captura ambos y explica cuál gana en el PDF y por qué.
20. Escribe el ejercicio-espejo del conteo que la Fase 8 dejó como gancho: antes de permitir entregar, verifica que **todos** los resultados de todas las muestras de la orden estén `validated`. Decide si esa verificación va en el componente (UX) o en la guarda del reducer (defensa), y justifica.
21. **Diagnóstico.** El PDF de un idioma sale con etiquetas mezcladas: unas en francés, otras en inglés. Reproduce sembrando una clave i18n que falte solo en el archivo `fr`. Explica el mecanismo de fallback de `@ngx-translate` que produce la mezcla y cómo se detecta en consola.
22. Un resultado validado se muestra en la vista, pero al generar el PDF, `snapshot.rangeVersionApplied` sale `null`. Conecta esto con el incidente 12 de la Fase 8 (un resultado validado sin versión de rango) y explica cómo un dato imposible sembrado en la Fase 8 llega a manifestarse como un PDF incompleto acá.
23. La suscripción de `ngOnInit` en `report.component.ts` no se limpia en `ngOnDestroy`. Demuestra la fuga: navega a la vista y sal de ella varias veces, y muestra en el Performance/Memory panel que las suscripciones se acumulan. Conecta con el tema central de la Fase 10. (Fix correcto: `takeUntil` con un `Subject` de destrucción; no obligatorio acá.)
24. **Diagnóstico.** Entregar una orden funciona en local pero "no hace nada" en un build de producción. Sin más pistas, enumera las causas plausibles (effect no registrado, `environment.apiUrl` distinto, guarda rechazando por un `status` que llegó diferente del backend) y di cómo descartarías cada una.

**🔴 Muy difícil (25–30)**

25. **Diagnóstico.** Te dan un PDF entregado hace un mes que un auditor dice que "está mal": el valor no coincide con lo que el sistema muestra hoy para ese resultado. Pero el resultado está `validated` y es irreversible, así que no debería haber cambiado. Investiga las dos explicaciones posibles —el PDF salió stale al generarse, o el resultado se alteró por fuera del store (incidente futuro de la Fase 11)— y di qué evidencia distinguiría una de la otra.
26. Factoriza los tres mapas de transición (`sample.transitions.ts`, `result.transitions.ts`, `order.transitions.ts`) en una única utilidad genérica `makeTransitionChecker(map)`. Después documenta qué diferencia sutil de cada uno se pierde o se vuelve incómoda con la unificación, y argumenta si en LabCore conviene o no unificar.
27. **Diagnóstico.** Un informe generado en francés sale con los acentos bien en el título y el cuerpo, pero rotos en una sola etiqueta que se agregó después. Descubre que esa etiqueta se dibuja con un `doc.text` que corre tras un `doc.setFont('helvetica')` metido en medio del servicio. Explica cómo un `setFont` intermedio revierte el registro previo, y da el fix mínimo y el correcto.
28. Mueve el módulo de reportes a carga diferida (`loadChildren`) para que la fuente base64 no infle el bundle inicial. Mide el tamaño del chunk principal antes y después con `ng build --stats-json` y confirma que la fuente ya no viaja en el arranque. Enlaza con el apéndice A08.
29. **Diagnóstico.** El PDF sale bien para el usuario A y con datos viejos para el usuario B, en la misma orden, al mismo tiempo. Reconstruye qué secuencia de "abrir vista / cambiar dato / generar" de cada uno produce la discrepancia, y explica por qué el stale es un bug que depende del *tiempo entre abrir y generar*, no del dato en sí.
30. Implementa el fix correcto completo del stale: elimina `reportSnapshot`, haz que `onGenerate` lea el resultado fresco del store con `take(1)` en el instante de generar, y calcule el veredicto ahí. Después argumenta por qué, aun con este fix, un PDF sigue siendo una foto (no se actualiza tras generarse) y qué problema del stale **no** resuelve.

**🔥 Opcionales**

- 🔥 **Migra de jsPDF a pdfmake** y observa qué desaparece del dolor de esta fase. `pdfmake` embebe Roboto con glifos latinos completos por defecto, así que los acentos del francés salen bien **sin** registrar ninguna fuente: todo §5.3 se evapora. El documento se declara como un objeto (`docDefinition`) en vez de dibujarse con coordenadas, lo que también borra el bug de "acentos parciales por orden de llamadas" del ejercicio 9. La trampa —y el punto del ejercicio— es esta: **cambiar de librería arregla los acentos, pero no toca el stale.** El `reportSnapshot` congelado en `ngOnInit` sigue igual de viejo con pdfmake que con jsPDF, porque el stale no es un problema de la librería de PDF, es un problema de *cuándo el componente toma la foto*. Documenta explícitamente qué de lo que rompía sigue roto después de migrar.

  <details>
  <summary>💡 Pistas (ábrelas en orden si te trabas)</summary>

  - **Pista 1 — qué es pdfmake.** Es otra librería de PDF en cliente, contemporánea de jsPDF, con un modelo distinto: en vez de un lápiz que dibuja en coordenadas, describes el documento como una estructura de datos (`{ content: [ ... ] }`) y la librería lo maqueta. Instálala como `pdfmake` y su archivo de fuentes `vfs_fonts`.
  - **Pista 2 — el docDefinition.** El cuerpo del informe se vuelve un arreglo de objetos de texto: `{ text: label + ': ' + value }`. Reemplaza los cinco `doc.text(..., x, y)` de §5.1 por cinco entradas en `content`. No hay coordenadas: el flujo es vertical automático.
  - **Pista 3 — dónde ya no hace falta el VFS.** `pdfmake` trae Roboto embebida en `vfs_fonts`. No llamas a `addFileToVFS` ni `addFont`: los acentos del francés salen bien de entrada. Todo `report-fonts.ts` y la llamada a `registerLatinFont` desaparecen.
  - **Pista 4 — la pregunta trampa.** Después de migrar, reproduce el ejercicio 18: abre la vista, cambia el valor por otra vía, genera. ¿El PDF sale fresco o viejo? Si sale viejo, entendiste el punto: la migración no tocó `reportSnapshot`.
  </details>

  <details>
  <summary>✅ Solución de referencia</summary>

  El `report.service.ts` migrado arma un `docDefinition` y llama `pdfMake.createPdf(docDefinition).download('report-' + snapshot.resultId + '.pdf')`. Las etiquetas siguen saliendo de `translate.instant(...)`; el idioma funciona igual. El `report-fonts.ts` se borra entero y la línea `registerLatinFont(doc)` se elimina del servicio, porque Roboto de `vfs_fonts` ya cubre los acentos latinos.

  Lo que **no** cambia: el `ReportComponent` de §5.2 queda idéntico. `reportSnapshot` se sigue tomando en `ngOnInit`, el `if (this.reportSnapshot) return` sigue congelando la foto, y `onGenerate` sigue pasándole al servicio la copia vieja. El ejercicio 18 se reproduce sin ninguna diferencia: el PDF sale con el valor viejo. Conclusión que hay que escribir: el bug de acentos vivía en la **capa de dibujo** (qué librería, qué fuente) y la migración lo resuelve; el bug de stale vive en la **capa de componente** (cuándo se copia el estado) y la migración ni lo toca. Son dos deudas independientes que la fase junta en un mismo documento, y confundirlas —creer que "cambiar la librería arregla el PDF"— es el error conceptual que este 🔥 previene.
  </details>

- 🔥 Genera el PDF desde un effect en vez de desde el componente: despacha una acción `[Reports] Generate`, y un effect lee el resultado **fresco** del store con `withLatestFrom` y llama al `ReportService`. Documenta cómo esto mueve la foto del `ngOnInit` al instante de generar y por qué eso, por sí solo, mata el stale sin tocar la librería.

---

## 📚 8. Referencias

**Documentación oficial**

- https://github.com/MrRio/jsPDF/tree/v1.5.3 — el repositorio en la versión fijada. La API de `text`, `setFont`, `addFileToVFS` y `save` de esta línea. ⚠️ La rama por defecto del repo hoy documenta la `2.x`, con imports y métodos distintos: asegúrate de estar mirando el tag `v1.5.3`.
- https://raw.githack.com/MrRio/jsPDF/v1.5.3/docs/index.html — la documentación de API generada para la 1.5.3, si el enlace sigue vivo. ⚠️ Enlace no verificado al cierre; si no responde, el `README` del tag `v1.5.3` cubre lo esencial.
- https://v8.angular.io/api/router/ActivatedRoute — para leer el id del resultado desde la URL en `ReportComponent`. ⚠️ Arrastra el pendiente de `v8.angular.io` abierto desde la Fase 3.
- https://github.com/ngx-translate/core/tree/v11.0.1 — `TranslateService.instant()` para resolver claves fuera de una plantilla, que es como el PDF traduce sus etiquetas. Es la versión que fijó la Fase 2.
- https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Date/toLocaleString — el formateo de fecha con `timeZone`, usado para `validatedAt` en el PDF. Léelo sabiendo que la zona formatea la *visualización*, no cambia el instante guardado.

**Libros / artículos de referencia**

- Sobre por qué un PDF embebe fuentes y qué son las "14 fuentes estándar" de PostScript/PDF —el trasfondo de por qué Helvetica rompe los acentos—, cualquier material introductorio sobre el modelo de fuentes de PDF. ⚠️ No es específico de jsPDF; es del formato PDF, y por eso es estable en el tiempo.

**Video / apoyo**

- Búsquedas de la época sobre "jsPDF accents special characters" (2018-2020) — https://www.google.com/search?q=jspdf+accents+special+characters+font — el problema del incidente 15 es un clásico con muchas soluciones parciales dando vueltas. ⚠️ Varias respuestas apuntan a la `2.x`; verifica que la solución que copies sea de la `1.5.3`.

**Orden de lectura sugerido:** antes de escribir código, el `README` del tag `v1.5.3` de jsPDF para tener la API correcta en la cabeza. Durante, la doc de `addFileToVFS`/`addFont` cuando llegues a §5.3, y la de `instant()` de ngx-translate para §5.1. Después, y solo si vas al forense, el paso a paso de [`forense-fase-09.md`](./forense-fase-09.md).

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido desde que se escribió esto. Los enlaces a `v8.angular.io` están marcados como **no verificados** y arrastran el pendiente de la Fase 3. La documentación de jsPDF en su repositorio cubre por defecto la `2.x`: la API que usa esta fase es la del tag `v1.5.3`, donde el constructor es `new jsPDF()` y no `new jsPDF()` importado con nombre.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Quedó construido el camino de salida del sistema: un `ReportService` que arma un PDF en el cliente desde un snapshot congelado, un `ReportComponent` que toma ese snapshot al abrir la vista —y ahí, en el instante de la foto, deja plantada la deuda 💸 del dato stale—, un registro de fuente que hace que los acentos del francés salgan bien y cuya ausencia es el incidente 15, y la primera guarda real de la máquina de órdenes: `complete → delivered` en `order.transitions.ts`, con su acción `markDelivered`, su reducer que la protege y su effect que estampa `deliveredBy`/`deliveredAt`. Quedó instalado el reflejo central de la fase: **un informe es una foto, y cuando sale con datos viejos el bug no está en el PDF ni en la librería, sino en el instante en que el componente copió el estado y dejó de mirarlo.**

La siguiente en el orden de lectura es la **Fase 10 — Dashboard**, y conviene decir por qué no continúa este hilo: el dashboard no depende de nada de lo que acabas de construir. Es una pantalla de solo lectura que se apoya en los slices de las Fases 5, 7 y 8 y que existe para enseñar otra cosa —dónde se pone lenta una aplicación Angular y cómo se mide—. Se lee ahí porque el curso alterna construcción con diagnóstico, no porque el informe la habilite. Si te tienta seguir el hilo del dominio en vez del calendario, puedes leer la Fase 11 antes que la 10 sin perder nada; el orden de archivos es una convención, no una dependencia.

El hilo del dominio, entonces, sigue en la **Fase 11 — Trazabilidad y audit log**, y es el paso natural porque acaba de nacer el segundo evento del sistema que cambia el estado desde afuera del flujo normal: la entrega. El primero fue el cruce results→orders de la Fase 8; este es la orden pasando a `delivered` con una firma de custodia estampada en cliente. El audit log de la Fase 11 tiene que reconstruir ambos —quién entregó qué y cuándo, y contra qué versión de rango se validó lo que se entregó—, y va a chocar de frente con que esas firmas se estamparon en el navegador y no en el servidor. La deuda de custodia que las Fases 7, 8 y 9 fueron dejando (`collectedAt`, `validatedAt`, `deliveredAt`, todos de cliente) es exactamente lo que la trazabilidad no puede dar por confiable, y ese es el problema que abre la Fase 11.

> **La señal de que quedó bien:** cuando alguien te muestre un informe "equivocado" y tu primer movimiento no sea abrir el PDF ni sospechar de la librería, sino preguntar *cuándo se abrió la vista y cuándo se generó* —y buscar la copia del estado que quedó vieja en el medio.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-09-entrega-pdf -m "F9 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f09: …`) y los de ejercicio su
> número (`f09 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f09/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

Cosas que aparecieron escribiendo esta fase y que no caben acá:

- **[A]** El **conteo completo de "orden lista para entregar"** (todas las muestras procesadas, todos los resultados validados) → hereda el esqueleto del `pushOrderAfterValidate$` de la Fase 8; queda como **ejercicio 20** acá y como material del cruce que la **Fase 11** tiene que auditar. No se construye entero acá.
- **[B]** 🪦 **Resuelto.** La **carga diferida del módulo de reportes** para que la fuente base64 no infle el bundle inicial quedó desarrollada en el **Apéndice A08 §5**, con las tres estrategias y su costo. La **medición** sigue abierta a propósito: no hay cifras inventadas en el curso, se toman sobre el proyecto montado con las herramientas de **A04 §5** — es el **ejercicio 28** de acá y el **ejercicio 7** de A08.
- **[C]** La **suscripción sin `ngOnDestroy`** de `ReportComponent` → es la fuga de suscripción huérfana que la **Fase 10 (dashboard)** convierte en tema central; anotada como **ejercicio 23**. En Track A no se paga acá.
- **[D]** El **`deliveredAt`/`validatedAt` estampados en cliente** → deuda de custodia acumulada desde la Fase 7, que la **Fase 11** no puede dar por confiable. Sugerido como material central del audit log. En Track A no se paga.
- **[E]** 🪦 **Resuelto.** La **doble grafía** `delivered` (dato) vs la clave i18n `orders.status.delivered` quedó documentada en el **Apéndice A07 §4**, junto con la regla que este PDF ya aplica: se guarda la clave (`verdictKey`) y se traduce al dibujar, nunca al revés (**A07 §7**).
- 🪦 **[F] Ya estaba pagado acá.** La decisión de unificar o no las tres copias de los mapas de transición se argumenta en **§5.4** —con la advertencia de que las tres tienen diferencias sutiles que una unificación apresurada borra— y el **ejercicio 26** pide hacerlo y documentar qué se pierde. No es material de A06: es diseño de dominio, no NgRx.

### 🩹 Nota de continuidad hacia la Fase 5

Esta fase requiere que el estado `delivered` exista en `ORDER_STATUSES` y en el `MatSelect` de órdenes. Ese estado se agregó al `seed.js` de la Fase 5 mediante una **edición localizada**, documentada en la *Nota de continuidad* de §5.11 de esa misma fase, con el mismo precedente de la Fase 3 (`server.js`) y la Fase 8 (normalización del flujo): una brecha de continuidad detectada tarde se corrige editando el entregable anterior, no reabriendo su alcance. La **guarda** `complete → delivered` **no** se agregó a la Fase 6: nace acá, en `order.transitions.ts`, igual que la guarda de la muestra nació en la Fase 7 y la del resultado en la 8. La máquina de órdenes de la Fase 6 sigue siendo incipiente; esta fase endurece solo la transición que necesita.

### Reservas para el cuaderno de incidentes

Esta fase toma los incidentes **14 y 15**, ambos nuevos. Los dos están en el índice del cuaderno y con su enunciado escrito:

- **14** · Fase 9 · *"El informe salió con un resultado que ya había cambiado"* · Categoría: estado (store) · Dificultad 🟠
- **15** · Fase 9 · *"Los acentos del informe en francés salen como símbolos raros"* · Categoría: i18n · Dificultad 🟡
