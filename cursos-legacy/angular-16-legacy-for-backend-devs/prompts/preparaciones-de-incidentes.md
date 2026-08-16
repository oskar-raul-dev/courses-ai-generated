# 🧰 Preparaciones de los incidentes
## Tutorial Angular 16 — Inspecciones y certificaciones

Este documento **no lo lee el estudiante**. Es material de autoría, como el bloque
📌 de cada fase: contiene el **estado roto** de cada incidente del cuaderno, o sea
exactamente la respuesta que el estudiante tiene que encontrar por su cuenta.

> ⚠️ **Quien vaya a resolver el cuaderno no abre este archivo.** Abrirlo es peor
> que abrir la pista 3: la pista 3 te deja la pregunta cuya respuesta es la causa;
> esto te deja el `git diff`. Si estás haciendo el curso, cierra la pestaña.

**Por qué existe.** La §4 de
[`formato-cuaderno-incidentes.md`](formato-cuaderno-incidentes.md) define **cómo**
llega el sistema roto a la máquina del estudiante —un flag del caos, un
`mock/db.incidente-NN.json`, o una rama `incidente/NN`—, y los veinte enunciados
usan ese mecanismo. Lo que no estaba escrito en ninguna parte era **el
contenido**: qué línea rompe cada rama y qué registros cambia cada archivo de
datos. Sin eso, dieciocho de los veinte incidentes se quedaban en la línea del
`git switch` o del `cp`.

**Quién lo aplica.** El curso se trabaja sin instructor, así que hay dos formas y
las dos son legítimas:

- **El estudiante, antes de empezar el mes.** Prepara las dieciséis ramas y los
  dos archivos de datos de una sentada, sin leer las secciones *"Qué se rompe"*
  más allá de lo necesario para aplicarlas, y no vuelve a abrir este archivo. Es
  menos limpio de lo que parece —vas a ver el diff— pero funciona sorprendentemente
  bien: un mes después, en medio de un ticket vago, nadie se acuerda de qué línea
  movió.
- **Quien coordine el onboarding**, si hay alguien. Deja las ramas y los datos
  listos en el repositorio del equipo y el estudiante sólo hace `git switch` y
  `cp`. Es la forma buena.

---

## Índice

- [1. Cómo se usa este documento](#1-cómo-se-usa-este-documento)
- [2. Mapa: qué necesita cada incidente](#2-mapa-qué-necesita-cada-incidente)
- [3. Las dieciséis ramas](#3-las-dieciséis-ramas)
- [4. Los dos `mock/db.incidente-NN.json`](#4-los-dos-mockdbincidente-nnjson)
- [5. Las dos que sólo necesitan un flag](#5-las-dos-que-sólo-necesitan-un-flag)
- [6. Verificar que la preparación sirve](#6-verificar-que-la-preparación-sirve)
- [⚠️ Advertencias](#️-advertencias)

---

## 1. Cómo se usa este documento

Cada receta trae cuatro cosas y siempre las mismas:

1. **De dónde sale** — el tag de la fase. En este curso los tags son
   **`fase-` + el número de dos dígitos** (`fase-00`, `fase-07`), sin el slug del
   archivo, según [`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md).
2. **Qué archivo se toca** — la ruta exacta dentro del proyecto.
3. **El cambio** — el antes y el después, escrito **en el estilo del archivo que
   se toca** 🧬: `constructor(private x: X)` y NgModules en lo heredado (Fases 1-4),
   `inject()` y standalone en lo nuevo (Fase 5 en adelante), y `strict: true`
   siempre — una preparación que no compila bajo `strict` no es una preparación,
   es otro bug.
4. **Cómo comprobar que la preparación quedó bien** — el síntoma que el estudiante
   tiene que ver. Una preparación que no reproduce el síntoma es peor que ninguna:
   manda a alguien a investigar un bug que no está.

El cambio es siempre **el mínimo que produce el síntoma**. Nada de reescribir un
archivo entero ni de sembrar dos bugs a la vez: una línea movida, un operador
cambiado, un `import` que falta. Hay **una sola excepción declarada** —el
incidente 02, que añade archivos— y está explicada en su receta.

> 🧭 **Y la regla que ordena las tres formas:** se usa siempre la más barata que
> sirva. Dieciséis ramas frente a dos archivos de datos y dos flags no es un
> desequilibrio: es lo que sale cuando la mayoría de los bugs de una SPA en
> mantenimiento están en el código y no en la red ni en el dato.

---

## 2. Mapa: qué necesita cada incidente

| ID | Fase | Forma | Qué hay que preparar |
|---|---|---|---|
| 01 | 0 | rama `incidente/01` | el `^` del `package.json` |
| 02 | 1 | rama `incidente/02` | la pantalla de activos sin `<router-outlet>` |
| 03 | 2 | **flag** | `CHAOS=expired` |
| 04 | 3 | **flag** | `CHAOS=timeout CHAOS_RATE=1` |
| 05 | 4 | rama `incidente/05` | el `load()` que nadie llama |
| 06 | 5 | rama `incidente/06` | `MatButtonModule` fuera de los `imports` |
| 07 | 5 | rama `incidente/07` | el listado embebido en el panel |
| 08 | 7 | rama `incidente/08` | la versión resuelta por fecha de hoy |
| 09 | 7 | **dato** `db.incidente-09.json` | la v3 publicada sin cerrar la v2 |
| 10 | 8 | rama `incidente/10` | `addControl` sobre el formulario que sobrevive |
| 11 | 8 | rama `incidente/11` | el `patchValue` de la confirmación |
| 12 | 9 | **dato** `db.incidente-12.json` | el hallazgo sin `resolvedAt` |
| 13 | 9 | rama `incidente/13` | la anulación que la derivación pisa |
| 14 | 10 | rama `incidente/14` | el PDF armado desde la vista |
| 15 | 10 | rama `incidente/15` | los dos `slice(0, 10)` en husos distintos |
| 16 | 11 | rama `incidente/16` | el `interval` que sobrevive al componente |
| 17 | 12 | rama `incidente/17` | el `localStorage` que no limpia nadie |
| 18 | 13 | rama `incidente/18` | el `max-age` de un año sobre el `index.html` |
| 19 | 13 | rama `incidente/19` | el `chmod +x` que falta |
| 20 | 12 | rama `incidente/20` | el `toBeTruthy()` y el suelo global |

Las ramas se crean todas igual y no hace falta buscar ningún commit: salen del tag
que el estudiante puso al cerrar la fase.

```bash
git switch -c incidente/08 fase-07
# …se aplica el cambio de la receta…
git commit -am "incidente(08): preparación — el detalle resuelve por fecha de hoy"
git switch master
```

> 💡 **Commitea la preparación en su rama y vuelve a `master`.** Así el estudiante
> entra al incidente con un `git switch incidente/08` y sale con un `git switch
> master`, sin arrastrar nada. Y ojo con el reflejo de mirar `git diff master` al
> entrar: eso es la solución.

---

## 3. Las dieciséis ramas

### `incidente/01` — el circunflejo que nadie ve

**De dónde sale:** `fase-00`.
**Qué se toca:** `package.json` y el lockfile.

```diff
   "devDependencies": {
-    "typescript": "5.1.6"
+    "typescript": "^5.1.6"
   }
```

Y el lockfile tiene que regenerarse en el mismo commit, porque si no el `npm ci`
del estudiante seguiría instalando la 5.1.6 y no pasaría nada:

```bash
rm -rf node_modules package-lock.json
npm install          # resuelve a la 5.4.x, que es lo que rompe
git add package.json package-lock.json
```

**Qué se rompe.** Angular 16.2.12 declara soporte de TypeScript `>=4.9.3 <5.2.0`.
El `^` admite cualquier menor por encima, así que una instalación de hoy trae la
5.4 y el compilador se planta antes de servir nada.

**Cómo comprobarlo.** `npm start` tiene que morir con este mensaje literal, no con
otro:

```
Error: The Angular Compiler requires TypeScript >=4.9.3 and <5.2.0 but 5.4.5 was found instead.
```

> ⚠️ **La mitad de este incidente es la máquina del compañero**, y no se puede
> preparar: el estudiante tiene que entender que dos árboles distintos salen del
> mismo `package.json`. Si vas a montarlo para un equipo, deja **un** `node_modules`
> viejo sin borrar en la máquina de alguien y tendrás el ticket completo.

---

### `incidente/02` — la pantalla que se activa y no se pinta

**De dónde sale:** `fase-01`.
**Qué se toca:** `src/app/features/assets/` — y es **la única preparación que
añade archivos** en todo el cuaderno.

La excepción está declarada y tiene motivo: el ticket dice *"agregué la pantalla
de activos"*, así que el estado roto **es** una pantalla nueva. En la Fase 1,
`/assets` es un placeholder plano sin rutas hijas, y sin rutas hijas no existe el
bug. La rama la convierte en contenedor con hijas, que es lo que hace cualquiera
al empezar una feature de verdad.

```ts
// src/app/features/assets/assets-routing.module.ts — estilo heredado, NgModule
const routes: Routes = [
  {
    path: '',
    component: AssetsComponent,      // ← el contenedor nuevo
    children: [{ path: '', component: AssetListComponent }],
  },
];
```

```html
<!-- src/app/features/assets/assets.component.html — el contenedor, SIN el outlet -->
<h2>Activos</h2>
```

`AssetsComponent` se declara en `AssetsModule` como cualquier componente de 2021,
con `constructor` vacío y sin `standalone`.

**Qué se rompe.** La ruta hija se activa, Angular construye `AssetListComponent`,
y no hay dónde pintarlo. **No hay error porque no hay nada mal**: el router hizo
su trabajo y nadie pidió el resultado.

**Cómo comprobarlo.** Entra a `/assets`: la URL cambia, se ve el `<h2>Activos</h2>`
y debajo no hay nada. La consola está limpia, y esto devuelve el componente —que
es lo que hace desconcertante el ticket—:

```js
ng.getComponent(document.querySelector('cc-asset-list'));   // no es null
```

---

### `incidente/05` — suscribirse no es cargar

**De dónde sale:** `fase-04`.
**Qué se toca:** `src/app/features/templates/template-list/template-list.component.ts`.

```diff
   ngOnInit(): void {
-    this.templateState.load();
   }
```

Si el `ngOnInit` se queda vacío, quítalo entero: un `ngOnInit` vacío es una pista
gratis, porque el primero que lo vea va a preguntarse qué había ahí.

**Qué se rompe.** El componente sigue suscrito a `templateState.templates$` y el
`BehaviorSubject` le entrega su valor inicial —un array vacío— con toda
corrección. La pantalla pinta cero plantillas y el mock está perfectamente bien.

**Cómo comprobarlo.** Dos cosas, y la segunda es la que hace bonito al incidente:

```bash
# 1. Entra a /templates: dice que no hay ninguna, y en Network NO sale
#    ninguna petición a /templates. Ninguna: ni fallida, ni en rojo.
# 2. Ahora entra primero al editor (que sí llama a load()) y después al listado:
#    el listado funciona. El bug parece intermitente y depende del orden.
```

---

### `incidente/06` — el atributo que nadie reclama

**De dónde sale:** `fase-05`.
**Qué se toca:** `src/app/features/clients/client-list/client-list.component.ts`.

```diff
 @Component({
   selector: 'cc-client-list',
   standalone: true,
   imports: [
     AsyncPipe,
     NgIf,
     RouterLink,
-    MatButtonModule,
     MatFormFieldModule,
     MatIconModule,
     MatInputModule,
     MatTableModule,
   ],
```

**Qué se rompe.** `mat-raised-button` es una **directiva con selector de
atributo**. Si nadie la provee, `<button mat-raised-button>` es un `<button>` con
un atributo desconocido: HTML válido, sin error de plantilla, sin advertencia.
`NG0304` es para elementos desconocidos y `NG0303` para propiedades que no
existen; un atributo suelto no dispara ninguno.

**Cómo comprobarlo.** `npm start` compila **sin un solo error** —eso es la mitad
del ticket— y el botón "Nuevo cliente" sale gris y plano. Inspecciónalo:

```html
<button mat-raised-button color="primary">Nuevo cliente</button>
<!-- …sin una sola clase mat-mdc-*. Cualquier otro botón de la aplicación sí las tiene. -->
```

> 🧬 Esta preparación sólo funciona **después** de la Fase 5, y no por casualidad:
> mientras `SharedModule` reexportaba media librería de Material, el componente
> heredaba `MatButtonModule` sin pedirlo y quitarlo de aquí no habría hecho nada.
> La rama no crea el bug: **destapa el que ya estaba**.

---

### `incidente/07` — la misma clase, dos inyectores

**De dónde sale:** `fase-05`.
**Qué se toca:** el panel, para que embeba el listado.

```ts
// src/app/features/dashboard/dashboard.component.ts
imports: [/* …lo que ya tenía… */, ClientListComponent],
```

```html
<!-- src/app/features/dashboard/dashboard.component.html -->
<cc-client-list></cc-client-list>
```

**No se toca `clients.routes.ts`.** El token `CLIENT_LIST_PAGE_SIZE` se sigue
proveyendo sólo en la ruta `/clients`, tal como la Fase 5 lo dejó — y ése es
justamente el punto.

**Qué se rompe.** Un componente standalone resuelve sus dependencias en su propio
inyector y en el de **la ruta que lo activó**. Por el menú se pasa por `/clients`
y el token está; embebido en la plantilla del panel, no hay ninguna ruta que lo
traiga.

**Cómo comprobarlo.** El panel sale en blanco y la consola trae el error con el
paréntesis que decide toda la investigación:

```
ERROR NullInjectorError: R3InjectorError(Standalone[ClientListComponent])[InjectionToken CLIENT_LIST_PAGE_SIZE …]
```

Y `/clients` por el menú **sigue funcionando**, que es lo que convierte el ticket
en "a veces sí y a veces no".

---

### `incidente/08` — la pregunta que suena igual y no lo es ⭐

**De dónde sale:** `fase-07`.
**Qué se toca:** `src/app/features/inspections/inspection-detail/inspection-detail.component.ts`.

```diff
   switchMap((inspection) =>
-    this.templateApi
-      .getByVersion(inspection.templateId, inspection.templateVersion)
-      .pipe(map((template) => ({ inspection, template }))),
+    // "¿Qué versión rige hoy?" — que es la pregunta de empezar una inspección
+    // nueva, no la de abrir una que ya existe.
+    this.templateApi
+      .getFamily(inspection.templateId)
+      .pipe(
+        map((family) => resolveTemplateVersion(family, todayInBusinessZone())),
+        map((template) => ({ inspection, template })),
+      ),
   ),
```

**Qué se rompe.** La inspección 501 se ejecutó en agosto de 2023 con la v1, que
tiene tres ítems. La vigente hoy es la v2, que tiene cuatro y le cambió el título
a `main-cable`. El detalle pide la vigente y pinta un histórico que cambió solo.

**Cómo comprobarlo.** Abre la inspección **501**:

```
Lo que la inspección dice:   templateVersion: 1
Lo que la pantalla pide:     GET /templates?templateId=elevator-annual   ← sin &version=
Lo que se ve:                cuatro ítems, con "cabin-lighting" vacío
                             y "Estado y tensión del cable principal" en vez de
                             "Estado del cable principal"
```

Si ves tres ítems, la preparación no quedó: revisa que el `db.json` esté limpio
(`npm run seed`) y que la v1 no esté editada.

---

### `incidente/10` — el formulario que sedimenta ⭐

**De dónde sale:** `fase-08`.
**Qué se toca:** `src/app/features/inspections/inspection-form/inspection-form.component.ts`.

La Fase 8 construye un formulario nuevo por inspección con `buildAnswerForm`, que
es una función pura. La rama vuelve al patrón imperativo que todo el mundo escribe
la primera vez: un `FormRecord` que vive en el componente y se va rellenando.

```diff
-  readonly currentView$ = this.route.paramMap.pipe(
-    map((params) => Number(params.get('inspectionId'))),
-    switchMap((inspectionId) => this.loadView(inspectionId)),
-    map(({ inspection, template }) => ({
-      inspection,
-      template,
-      form: buildAnswerForm(template, inspection.answers),
-    })),
-  );
+  readonly form = new FormRecord<FormGroup<AnswerControls>>({});
+
+  private applyTemplate(template: ChecklistTemplate, answers: readonly Answer[]): void {
+    const answerByItemId = new Map(answers.map((a) => [a.itemId, a]));
+
+    for (const item of template.items) {
+      // addControl NO reemplaza si la clave ya existe, y NO quita las que sobran.
+      this.form.addControl(item.id, buildItemGroup(item, answerByItemId.get(item.id) ?? null));
+    }
+  }
```

**Qué se rompe.** El formulario sobrevive a la navegación, y cada inspección deja
su sedimento encima de la anterior.

**Cómo comprobarlo.** Abre la inspección **502** (caldera), vuelve al listado, abre
la **500** (ascensor), y en la consola:

```js
Object.keys(ng.getComponent($0).form.controls);
// ['pressure-valve', 'flue-gas', 'main-cable', 'emergency-brake', 'door-sensor', 'cabin-lighting']
//   ↑ los dos primeros son de boiler-annual y no pintan nada en un ascensor
```

> ⚠️ **El orden importa para reproducir.** Caldera primero y ascensor después: al
> revés el síntoma también existe, pero los ítems sobrantes son menos visibles y
> el ticket no cuadra con lo que el enunciado describe.

---

### `incidente/11` — el bucle que cierra perfecto ⭐

**De dónde sale:** `fase-08`.
**Qué se toca:** el autosave de `inspection-form.component.ts`.

```diff
   concatMap((answers) => this.inspectionApi.saveAnswers(this.inspectionId, answers)),
   takeUntilDestroyed(this.destroyRef),
-).subscribe(() => {
-  this.lastSavedAt = nowInstant();
-});
+).subscribe((saved) => {
+  // "Para que quede sincronizado con lo que el servidor guardó."
+  this.form.patchValue(toFormValue(saved.answers));
+  this.lastSavedAt = nowInstant();
+});
```

**Qué se rompe.** Un ciclo de cuatro pasos que cierra solo: el inspector escribe →
pasa el debounce → sale el PATCH → el código parchea el formulario → `patchValue`
dispara `valueChanges` → vuelve al debounce. Para siempre, y sin un solo error.

**Cómo comprobarlo.** Abre cualquier inspección en curso, escribe **una letra** en
una nota y no toques nada más. Network se llena sola de PATCH a `/inspections/NNN`
a ritmo del debounce, la pestaña se arrastra y el ventilador arranca. Nada rojo en
ninguna parte.

> 💡 **Y la variante que conviene conocer al preparar**, porque produce el mismo
> ticket sin ningún `patchValue` a la vista: `disable()` y `enable()` también
> disparan `valueChanges` salvo con `{ emitEvent: false }`. Si algún día hace
> falta una segunda rama para este síntoma, ésa es.

---

### `incidente/13` — dos fuentes de verdad para el mismo campo

**De dónde sale:** `fase-09`.
**Qué se toca:** la pantalla de hallazgos, que gana una acción de supervisor.

La Fase 9 decidió que la severidad **se deriva** y que la `severity` guardada no
se lee nunca. La rama añade lo que pide cualquier supervisor a las dos semanas —
poder subir la severidad de un hallazgo— y la añade **de la forma natural**: un
PATCH a la fila.

```ts
// src/app/features/inspections/finding-list/finding-list.component.ts
raiseSeverity(finding: InspectionFinding, severity: FindingSeverity): void {
  // Escribe en la colección `findings`… que es justo el campo que la derivación
  // no lee. Nadie se da cuenta el día que se escribe: el PATCH responde 200 y
  // la pantalla se actualiza, porque el componente pinta lo que acaba de enviar.
  this.findingApi.patch(finding.id, { severity }).subscribe(() => this.reload());
}
```

**No se toca `finding-severity.ts` ni `inspection-findings.ts`.** La derivación
sigue exactamente como la Fase 9 la dejó, y ése es el punto: el sistema ahora
tiene dos fuentes de verdad para el mismo campo y **la derivada gana siempre, en
silencio**.

**Qué se rompe.** Al recargar, la derivación vuelve a calcular `minor` para
`cabin-lighting` —la v2 declara `nonComplianceSeverity: "minor"`— y pisa el
`major` que el supervisor escribió. No hay error, no hay conflicto, no hay aviso.

**Cómo comprobarlo.**

```bash
# Sube la severidad del hallazgo 901 desde la pantalla. Después:
curl -s http://localhost:3000/findings/901 | grep severity
# "severity": "major"      ← se guardó
```

```js
// …y lo que la pantalla muestra tras recargar:
ng.getComponent($0).finding.severity;   // 'minor'
```

---

### `incidente/14` — el documento armado desde la vista

**De dónde sale:** `fase-10`, y esta receta es distinta a todas las demás.

La Fase 10 **ya trae el bug y ya lo paga, dentro de la misma fase**: la versión de
5.7 arma el PDF desde la vista y la de 5.8 lo pide todo a la fuente. El tag
`fase-10` apunta a la segunda. Así que la rama no escribe código nuevo — **recupera
el archivo de antes del pago**, que git todavía tiene:

```bash
git switch -c incidente/14 fase-10

# El commit de 5.7, el que declara la deuda. Sale de:
git log --oneline fase-09..fase-10 -- src/app/features/certificates/certificate-pdf.service.ts
git checkout <commit-de-5.7> -- src/app/features/certificates/certificate-pdf.service.ts
```

Si el `download(certificateId)` de la versión pagada ya está cableado en el
componente, hay que devolver también la llamada a su forma vieja:

```diff
 // src/app/features/certificates/certificate-detail/certificate-detail.component.ts
-  download(certificateId: string): void {
-    this.certificatePdf.download(certificateId)
-      .pipe(takeUntilDestroyed(this.destroyRef))
-      .subscribe({ error: (error: unknown) => this.report(error) });
-  }
+  download(): void {
+    // Recibe el `view` de la pantalla, que es la firma de 5.7.
+    void this.certificatePdf.download(this.view, this.findings);
+  }
```

**Qué se rompe.** El PDF se arma con los objetos que la pantalla cargó al abrirse.
**El bug está en la firma, no en el cuerpo**: cualquier implementación que reciba
lo que el componente ya tenía produce este ticket, por bien escrita que esté.

**Cómo comprobarlo.** Hace falta una ventana de tiempo, y es la parte que hay que
montar a mano:

```bash
# 1. Abre la pantalla del certificado CERT-2023-000501 y déjala quieta.
# 2. Desde otra terminal, cambia el dato por debajo:
curl -s -X PATCH http://localhost:3000/findings/902 \
  -H 'Content-Type: application/json' \
  -d '{"resolvedAt":"2024-01-15T10:00:00-05:00"}'
# 3. Sin recargar, pulsa Descargar.
```

El PDF dice `door-sensor · Mayor · Pendiente` y el servidor dice `RESUELTO`. No
falla nada: el documento sale perfecto, con acentos y la tabla alineada, y ya va
camino de un correo.

---

### `incidente/15` — dos días calculados en husos distintos

**De dónde sale:** `fase-10`.
**Qué se toca:** `src/app/core/domain/certificate-status.ts`.

```diff
-  const expired = isAfterBusinessDay(nowInstant(), certificate.validUntil);
+  // Dos slice(0, 10) que parecen la misma operación y no lo son: el primero
+  // recorta el día LOCAL del dato, el segundo el día en UTC.
+  const expired = certificate.validUntil.slice(0, 10) < new Date().toISOString().slice(0, 10);
```

**Qué se rompe.** En Bogotá (`-05:00`), a partir de las **19:00** locales el día en
UTC ya es el siguiente, así que un certificado que vence hoy se compara contra el
día de mañana y el sistema lo declara vencido. Antes de las 19:00 el bug no
existe — y ése es el *"sobre todo por la tarde"* del ticket, que era el dato más
preciso que traía.

**Cómo comprobarlo.** No hace falta esperar a la tarde; se mueve el reloj de la
máquina o se usa el dato sembrado:

```bash
# CERT-2024-000502 vence el 2025-02-10T23:59:59-05:00.
# Pon el reloj del sistema en el 2025-02-10 a las 19:30 hora de Bogotá y recarga:
# la pantalla dice VENCIDO. Ponlo a las 10:00 del mismo día: dice VIGENTE.
```

```js
// Y las tres conversiones, que son correctas las tres y dicen cosas distintas:
new Date('2025-02-10T23:59:59-05:00').toISOString();   // '2025-02-11T04:59:59.000Z'
'2025-02-10T23:59:59-05:00'.slice(0, 10);              // '2025-02-10'
new Date().toISOString().slice(0, 10);                  // el día en UTC
```

---

### `incidente/16` — la suscripción que sobrevive a su dueño

**De dónde sale:** `fase-11`.
**Qué se toca:** `src/app/features/dashboard/dashboard.component.ts`.

El latido de la Fase 11 vive dentro de `DashboardMetricsService.metrics$` y muere
con la suscripción del `async`. La rama añade **un segundo refresco**, imperativo,
del tipo que aparece siempre con la excusa de *"para que el gráfico se actualice
aunque el `async` no emita"*:

```ts
private readonly dashboardState = inject(DashboardStateService);

ngOnInit(): void {
  // `interval` NO completa nunca. Este componente sí se destruye.
  interval(60_000)
    .pipe(switchMap(() => this.dashboardState.reload()))
    .subscribe();
}
```

Sin `takeUntilDestroyed`, sin `DestroyRef`, sin `ngOnDestroy`.

**Qué se rompe.** Cada visita al panel deja un `interval` corriendo, y con él un
componente que el recolector de basura no puede liberar. Cinco visitas, cinco
refrescos por minuto, para siempre.

**Cómo comprobarlo.** Entra al panel cinco veces, sal a otra pantalla y **deja
Network abierto dos minutos**:

```
certificates   200   xhr   14 ms
inspections    200   xhr   22 ms
certificates   200   xhr   11 ms
…cinco pares por minuto, desde fuera del panel
```

---

### `incidente/17` — el test que necesita que otro haya corrido antes

**De dónde sale:** `fase-12`.
**Qué se toca:** dos specs, y ninguno de los dos parece tener nada malo.

```diff
 // src/app/core/auth.service.spec.ts
-  afterEach(() => {
-    localStorage.clear();
-  });
```

```ts
// src/app/core/auth.guard.spec.ts — se deja EXACTAMENTE así: sin setup que
// garantice que no hay sesión. Es la mitad del bug y la que nadie mira.
it('redirige al login cuando no hay sesión', () => {
  expect(authGuard(route, state)).toBeInstanceOf(UrlTree);
});
```

**Qué se rompe.** `TestBed.resetTestingModule()` reconstruye el inyector entre
tests y **no toca `localStorage`**, que vive fuera de Angular. Si el spec del
servicio corre antes que el del guard, el guard encuentra una sesión válida,
devuelve `true`, y el test falla.

**Cómo comprobarlo.** Con `random: true` en el `karma.conf.js` —que la Fase 12 ya
dejó puesto— corre la suite cinco veces y anota las semillas:

```
Randomized with seed 47291 → 128 of 128 SUCCESS
Randomized with seed 83104 → 128 of 128 (1 FAILED)
    AuthGuard ✗ redirige al login cuando no hay sesión
      Expected UrlTree to be true.
```

Si no falla ninguna vez, fuerza el orden con `ng test --seed=<n>` hasta dar con
una que ponga el spec del servicio primero, y **anota esa semilla en la rama**: es
lo único que garantiza que el estudiante pueda reproducirlo.

> ⚠️ No pongas `random: false` para "asegurar" la preparación. Eso convierte un
> test que avisa en un test que miente, y es exactamente la reacción que el
> incidente enseña a no tener.

---

### `incidente/18` — un año de caché sobre el `index.html`

**De dónde sale:** `fase-13`.
**Qué se toca:** `nginx.conf`.

```diff
-location ~* \.(js|css|woff2?)$ {
-    expires 1y;
-    add_header Cache-Control "public, immutable";
-}
-
-location = /index.html {
-    add_header Cache-Control "no-store";
-}
-
-location = /assets/config.json {
-    add_header Cache-Control "no-store";
-}
+# La política de los bundles, aplicada a todo. Nadie la escribió pensando en el
+# index.html; simplemente nadie lo excluyó.
+location / {
+    expires 1y;
+    add_header Cache-Control "public, max-age=31536000";
+    try_files $uri $uri/ /index.html;
+}
```

**Qué se rompe.** Los bundles llevan hash en el nombre y se pueden cachear un año
sin riesgo. El `index.html` no lleva hash y cambia en cada despliegue: el navegador
de cada usuario conserva el de la última visita, que referencia los bundles de esa
versión — **que siguen existiendo, porque un despliegue no borra nada**. Esos
usuarios ejecutan la aplicación de ayer, completa y sin un solo error.

**Cómo comprobarlo.**

```bash
docker build -t certcore:inc18 .
docker run --rm -d --name certcore-inc18 -p 8080:80 certcore:inc18
curl -I http://localhost:8080/ | grep -i cache
# Cache-Control: public, max-age=31536000     ← sobre el index.html
```

Y el síntoma completo, que necesita dos despliegues: abre la aplicación **sin**
*Disable cache*, reconstruye la imagen con cualquier cambio visible, recarga, y no
verás el cambio. Con DevTools abierto y *Disable cache* sí lo ves — que es el
*"a mí me funciona"* del ticket, y es el dato clave.

---

### `incidente/19` — el bit de ejecución que no se hereda

**De dónde sale:** `fase-13`.
**Qué se toca:** `Dockerfile`.

```diff
 COPY entrypoint.sh /docker-entrypoint.d/40-certcore-config.sh
-RUN chmod +x /docker-entrypoint.d/40-certcore-config.sh
```

Y para que el contraste UAT/PROD del enunciado exista, el archivo tiene que llegar
**sin** el bit puesto desde el sistema de archivos de origen:

```bash
chmod -x entrypoint.sh
git update-index --chmod=-x entrypoint.sh   # git guarda el bit; hay que quitarlo también ahí
```

**Qué se rompe.** El entrypoint de nginx recorre `/docker-entrypoint.d/`,
encuentra un archivo que no puede ejecutar, **lo ignora en silencio** y arranca
perfectamente. nginx sirve la aplicación; sólo falta el `config.json`. Y como
`APP_INITIALIZER` bloquea el arranque de Angular hasta que su promesa resuelve, el
`404` de `assets/config.json` deja la pantalla en blanco **sin ningún error
visible** — porque el fallo ocurrió antes de que hubiera dónde pintarlo.

**Cómo comprobarlo.**

```bash
docker exec certcore-prod ls -l /docker-entrypoint.d/
# -rw-r--r--  1 root root  412 40-certcore-config.sh     ← sin la x
docker exec certcore-prod cat /usr/share/nginx/html/assets/config.json
# cat: can't open …: No such file or directory
docker logs certcore-prod 2>&1 | grep certcore
# (nada — el script nunca corrió)
```

> 💡 **Y el contraste que hace el ticket:** levanta el contenedor de UAT desde una
> imagen construida **antes** de quitar el bit. Los dos digests van a ser
> distintos, y el estudiante tiene que descubrir que ése es el primer paso —
> `docker inspect --format '{{.Image}}'`—, no el último.

---

### `incidente/20` — la línea verde que no afirma nada

**De dónde sale:** `fase-12`.
**Qué se toca:** el spec del detalle de inspección y el `karma.conf.js`.

```diff
 // src/app/features/inspections/inspection-detail/inspection-detail.component.spec.ts
-  expect(applied?.version).toBe(1);
-  expect(applied?.items.length).toBe(3);
+  expect(component.view).toBeTruthy();   // ← se ejecutó todo; no se comprobó nada
```

```diff
 // karma.conf.js
 coverageReporter: {
   check: {
     global: { statements: 80, branches: 70, functions: 80, lines: 80 },
-    each: { statements: 60, branches: 50, functions: 60, lines: 60 },
   },
 },
```

**Qué se rompe.** Dos cosas, y la segunda es la que duele. El suelo por archivo
desaparece, así que el 82 % global esconde un 43 % en `features/`. Y el spec del
archivo del incidente 08 sigue **cubriendo al 100 %** la línea culpable —se
ejecuta— mientras pasa igual con la v1 que con la v2, porque `toBeTruthy()` no
mira la versión.

**Cómo comprobarlo.**

```bash
ng test --no-watch --code-coverage
# All files                       82.3   74.6   86   81.9
# features/**/components          43.2   31.5   48   42.7
```

Y la prueba de que el coverage no protege: cambia `templateVersion` por `2` en el
fixture del spec. **La suite sigue en verde.**

---

## 4. Los dos `mock/db.incidente-NN.json`

Se generan a partir del `db.seed.json` de la Fase 3 y se editan a mano sólo los
registros de abajo. **Todo lo demás queda idéntico**: una semilla que difiera en
más de lo necesario siembra ruido, y el estudiante acaba investigando una
diferencia que no es la del ticket.

```bash
cp mock/db.seed.json mock/db.incidente-09.json
# …y se editan a mano los registros que indica cada receta
```

### `db.incidente-09.json` — dos ventanas abiertas a la vez

**Para el incidente 09** (Fase 7).
**Qué cambia:** la colección `templates` gana una fila y ninguna se cierra.

```jsonc
{
  "id": "elevator-annual-v3",
  "templateId": "elevator-annual",
  "version": 3,
  "validFrom": "2025-06-01",
  "validUntil": null,          // ← y la v2 sigue con null también
  "items": [
    { "id": "main-cable", "title": "Estado, tensión y anclaje del cable principal",
      "criteria": ["no_wear", "light_wear", "critical_wear"],
      "photoRequired": true, "nonComplianceSeverity": "critical" },
    { "id": "emergency-brake", "title": "Freno de emergencia",
      "criteria": ["ok", "needs_adjustment", "failed"],
      "photoRequired": false, "nonComplianceSeverity": "critical" },
    { "id": "door-sensor", "title": "Sensor de puerta",
      "criteria": ["ok", "intermittent", "failed"],
      "photoRequired": true, "nonComplianceSeverity": "major" },
    { "id": "cabin-lighting", "title": "Iluminación de cabina y de emergencia",
      "criteria": ["ok", "partial", "failed"],
      "photoRequired": false, "nonComplianceSeverity": "minor" }
  ]
}
```

**La v2 no se toca.** Su `validUntil` se queda en `null`, que es el bug entero: la
publicación hizo una escritura donde el dominio exige dos.

**El título de `main-cable` cambia otra vez**, y es deliberado — igual que en el
salto de la v1 a la v2. Es lo que hace *visible* el desempate cuando
`resolveTemplateVersion` devuelve una u otra: sin ese detalle, el estudiante ve
dos respuestas idénticas y no puede saber cuál le tocó.

**Cómo comprobarlo.**

```bash
curl -s "http://localhost:3000/templates?templateId=elevator-annual" \
  | python3 -c "import json,sys; [print(t['version'], t['validFrom'], t['validUntil']) for t in json.load(sys.stdin)]"
# 1 2021-01-01 2023-12-31
# 2 2024-01-01 None      ← dos None
# 3 2025-06-01 None      ←
```

Y en la pantalla de plantillas, recargando varias veces, la versión vigente que
muestra el sistema **cambia entre recargas** — porque json-server no garantiza el
orden del array y el desempate no está definido en ninguna parte.

> ⚠️ **Este archivo caduca.** `validFrom: "2025-06-01"` tiene que estar en el
> pasado para que las dos ventanas se solapen *hoy*. Si alguien toma el curso
> antes de esa fecha, el síntoma no aparece: adelanta la fecha o mueve el reloj.
> Es la única preparación del cuaderno que depende del calendario.

---

### `db.incidente-12.json` — el campo que decide, ausente

**Para el incidente 12** (Fase 9).
**Qué cambia:** un hallazgo crítico pierde la clave `resolvedAt`. **No se pone a
`null`, ni a `undefined`: se borra la clave entera.**

```diff
 { "id": 900, "inspectionId": 503, "itemId": "main-cable", "severity": "critical",
   "description": "Desgaste severo del cable principal, con hilos visibles",
-  "resolvedAt": null },
+  },
```

Y para que la inspección se pueda aprobar desde la pantalla, la 503 vuelve a un
estado que lo permita:

```diff
-{ "id": 503, …, "status": "rejected", … }
+{ "id": 503, …, "status": "completed", … }
```

**Qué se rompe.** El hallazgo llega sin la clave, así que su valor es `undefined`,
y la regla compara con `=== null`. Como `undefined === null` es `false`, el
hallazgo crítico no entra en la lista de bloqueantes y la aprobación sigue
adelante. La pantalla lo muestra bien —pinta `severity` y `description`, que sí
llegan— y **el único campo que falta es justo el que decide**.

**Cómo comprobarlo.**

```bash
curl -s http://localhost:3000/findings/900 | python3 -m json.tool
# …y NO aparece la clave resolvedAt. No es que valga null: no está.
```

En la pantalla: abre la inspección 503, pulsa Aprobar, y el sistema te deja —con
un hallazgo crítico en rojo a la vista.

> 🧭 **Por qué un dato y no una rama.** Se podría producir el mismo síntoma
> cambiando la comparación en `inspection-findings.ts`, y sería un incidente
> peor: enseñaría a revisar un `===`. Con el dato roto, la lección es la que
> importa — `this.http.get<Finding[]>(url)` **no valida nada**, el genérico es una
> promesa que le haces al compilador sobre datos que vienen de fuera, y `strict`
> protege la frontera entre tus archivos, no la frontera con la red.

---

## 5. Las dos que sólo necesitan un flag

No hay nada que preparar: el inyector de caos de la Fase 3 ya trae los seis fallos
—`latency`, `error`, `malformed`, `cors`, `expired`, `timeout`—, y **no se inventan
flags nuevos**. Si algún incidente futuro necesitara uno que no existe, la fase
tendría que haberlo construido y hay que revisar el enunciado, no el mock.

| Incidente | Comando | Qué produce |
|---|---|---|
| 03 | `CHAOS=expired npm run mock` | `/auth/login` firma un token con el `exp` en el pasado; la primera petición protegida responde `401` |
| 04 | `CHAOS=timeout CHAOS_RATE=1 npm run mock` | el servidor no responde nunca; la petición se queda en `pending` sin status y sin error |

**Cómo comprobarlo.** Que el mock imprima el flag al arrancar. Y en el 04, que
`CHAOS_RATE=1` convierta el intermitente en determinista — si sigue siendo
intermitente, el estudiante no puede investigarlo y el incidente se vuelve otra
cosa.

Los dos se apagan **reiniciando el mock sin el flag**. No tocan tu código, no
tocan tus datos y no dejan rastro: por eso son la forma preferida, y por eso da
rabia que sólo dos incidentes puedan usarla.

---

## 6. Verificar que la preparación sirve

Antes de dar por buena cualquier receta, las cuatro comprobaciones. La tercera es
la que más veces falla:

1. **Compila.** `npm start` arranca —salvo en el 01, donde no arrancar *es* el
   síntoma— y `ng build --configuration production` también. Una preparación que
   rompe el build de producción sin que el enunciado lo diga manda a investigar
   otra cosa.
2. **El síntoma se ve**, exactamente como lo describe el ticket. No "algo
   parecido": si el ticket dice "sale en blanco", tiene que salir en blanco.
3. **Y no se ve nada más.** Una preparación que además tira un error en consola
   que el enunciado no menciona regala la mitad de la investigación o manda por un
   camino falso. Abre la consola limpia y mírala.
4. **El diff es mínimo.** `git diff master` desde la rama tiene que caber en
   pantalla. Si no cabe, sobra algo.

```bash
# Volver, según la forma de preparación:
git switch master                        # rama
npm run seed                             # dato  (o cp mock/db.mio.json mock/db.json)
# …y el flag se apaga reiniciando el mock sin él.
```

---

## ⚠️ Advertencias

**El `db.json` es estado compartido entre fases, y las preparaciones lo tocan.**
Antes de copiar un `db.incidente-NN.json`, guarda el tuyo — `cp mock/db.json
mock/db.mio.json` — o asegúrate de que `npm run seed` te devuelve a algo que te
sirva. La Fase 10 emite y revoca certificados, así que después de ella el `db.json`
tiene filas que la semilla no trae.

**Las ramas caducan si el estudiante cambia lo que tocan.** Una rama `incidente/06`
creada desde `fase-05` deja de aplicar limpio si el estudiante reescribió después
`client-list.component.ts` en otra fase. Por eso salen del tag y no de `master`, y
por eso conviene crearlas **todas de una vez al principio**: en ese momento los
tags son lo único que importa y ninguna fase posterior existe todavía.

**Nunca dos bugs en la misma rama.** Es tentador —"aprovecho y dejo también el del
16"— y arruina los dos: el estudiante encuentra uno, lo arregla, el síntoma no se
va, y aprende que su diagnóstico correcto estaba mal.

**Y la advertencia que se olvida siempre:** si preparas esto para alguien, **no le
digas cuántas ramas hay ni de qué fase sale cada una**. Saber que el incidente 14
sale de `fase-10` ya es media investigación, porque acota el problema a lo que esa
fase construyó. El estudiante entra por el ticket, no por el tag.
