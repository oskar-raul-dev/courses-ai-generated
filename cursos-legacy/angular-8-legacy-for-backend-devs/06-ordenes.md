# 📋 Fase 06 — Órdenes

> Tutorial Angular 8 — Laboratorio clínico · Fase 6 de 14 · **4 horas**
> Depende de: Fase 5 — Pacientes · Habilita: Fase 7 — Muestras y cadena de custodia · Fases 10-12
> Apéndices de apoyo: [A01 (Angular Material)](./a01-material.md) · [A02 (Bootstrap 4 + Sass)](./a02-bootstrap-sass.md) · [A06 (NgRx 8)](./a06-ngrx.md) · [A07 (i18n en Angular 8)](./a07-i18n.md) · [Incidentes asociados](./cuaderno-incidentes.md): —

---

## 🎯 1. Propósito

La Fase 5 dejó un CRUD entero y, con él, un molde: componente gordo que consume
selectores y despacha acciones, formulario reactivo en diálogo, escritura que
recarga en vez de insertar. Esta fase lo aplica por segunda vez, y ese *segunda
vez* es el punto: **la mayor parte de un sistema de años no son piezas nuevas, son
la misma pieza otra vez con otro sustantivo.** Reconocer el molde en dos minutos
—y localizar en él las tres cosas que no encajan— es la habilidad que te deja
moverte por siete slices sin releerlos.

Porque hay tres cosas que no encajan, y ninguna es mecánica. Una orden tiene una
**lista dentro del formulario** —los exámenes que pide— y eso saca a los
formularios reactivos de lo que viste en pacientes. Una orden **apunta a un
paciente**, así que la tabla tiene que mostrar un dato que no está en la fila y
alguien tiene que decidir dónde se hace ese cruce. Y una orden tiene un `status`
que ya se parece a una máquina de estados aunque todavía no lo sea, lo cual la
convierte en la única pantalla del curso donde puedes hacer un salto ilegal y el
sistema te deja.

Y hay una cuarta razón, que es la que hace esta fase forense. `orders` es el
segundo slice del sistema, y con dos slices aparece por primera vez una pregunta
que con uno no existía: **¿qué pasa cuando consultas un estado que todavía no se
ha cargado?** La respuesta —`undefined`, no un array vacío— es la causa de cuatro
síntomas que parecen no tener nada que ver entre sí, y la vas a ver aquí antes de
que te muerda en el dashboard.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Navegas a `/orders` y ves una tabla con las ~40 órdenes del semillero, paginada, con el **nombre del paciente** en su columna y no su `patientId`.
- [ ] En la pestaña Network ves llegar el `.js` del módulo de órdenes la primera vez que entras, y en Redux DevTools ves aparecer el slice `orders` en el árbol de estado **en ese mismo momento**, no antes.
- [ ] Creas una orden nueva, le agregas dos exámenes con el botón de añadir, quitas el primero, y confirmas en `db.json` que `testCodes` quedó con el que esperabas y no con el otro.
- [ ] Cambias el estado de una orden de `complete` a `pending` desde el desplegable y el sistema te deja: sabes decir por qué eso es correcto hoy y en qué fase deja de serlo.
- [ ] Desde la pantalla de pacientes, consultas un selector de órdenes sin haber entrado nunca a `/orders`, y sabes explicar por qué lo que recibes no es `[]`.
- [ ] Los textos de la pantalla —encabezados de columna, etiquetas de estado, botones— salen de claves de i18n, y las de estado usan el mapa explícito de **A07 §4**, no una concatenación.

---

## 🚫 3. Qué NO entra todavía

- **Las muestras que cuelgan de una orden.** La relación existe en el `db.json` desde la Fase 4, pero nadie la recorre → **Fase 7**, que es donde `orden → muestra` se vuelve navegable.
- **Las transiciones de estado con reglas.** Aquí el `MatSelect` ofrece los seis estados y ninguno está protegido → la guarda de verdad nace en la **Fase 7** para muestras, en la **Fase 8** para resultados y en la **Fase 9** para la única transición de orden que ese capítulo necesita.
- **El vencimiento automático.** Una orden llega a `expired` porque el semillero la sembró así, no porque nadie compare `dueAt` contra la fecha de hoy. Comparar fechas de vencimiento es de la **Fase 8**, donde la zona horaria deja de ser un detalle.
- **El empuje desde los resultados** —que validar el último resultado mueva la orden— → **Fase 8 §5.6**, y es el primer cruce entre dos slices del sistema.
- **Permisos por rol** sobre quién puede crear o cerrar una orden → fuera del alcance del curso, heredado de la Fase 5.
- **El CRUD escrito línea por línea.** Esta fase muestra **lo que cambia** respecto del molde de la Fase 5 y te hace escribir el resto. Copiar quinientas líneas para cambiar cuatro palabras no enseña nada; encontrar las cuatro, sí.

---

## 🧠 4. Concepto mínimo

### El molde, y cómo se lee un slice ajeno en dos minutos

Un slice de este proyecto son cinco archivos y siempre los mismos (**A06 §1**).
Cuando abras el séptimo de tu vida no lo vas a leer entero: vas a buscar las
diferencias. Este es el orden que funciona, y sirve igual para el `orders` que vas
a escribir que para uno que heredes:

**Primero las acciones**, porque son el vocabulario. Un vistazo a
`orders.actions.ts` te dice qué le puede pasar a una orden en este sistema, y si
ves el trío `Load / Success / Failure` más los verbos de escritura ya sabes el 80%.
Lo interesante es lo que **sobra**: una acción que no está en el molde —como el
`upsertPatient` de la Fase 5, que no toca el reducer— siempre tiene una historia
detrás.

**Después el estado**, que es la interfaz al principio del reducer. Cuatro claves
te esperas (`items`, `loading`, `error`, `selectedId`); las que haya de más son
las decisiones de ese slice.

**Y por último los `case` que no reconoces.** Los de carga y escritura son
idénticos en los siete slices. Si hay uno con un `if` dentro, ahí vive una regla
de negocio, y ese es el archivo que de verdad tenías que leer.

### El `FormArray`, o qué pasa cuando un campo es una lista

Una orden pide varios exámenes. En el formulario eso no es un campo con una
cadena: es un número indeterminado de controles que el usuario añade y quita.

`FormGroup` no sirve, porque un `FormGroup` identifica a sus hijos **por nombre** y
aquí los nombres no existen: hay un primero, un segundo, un tercero. Para eso está
`FormArray`, que es exactamente lo mismo con los hijos identificados **por índice**.
Todo lo demás —validadores, estado de validez, `valueChanges`— funciona igual.

**Si vienes de backend**, un `FormArray` es la lista de líneas de un pedido: no
sabes cuántas va a haber y cada una se valida sola. La analogía aguanta hasta un
punto que conviene ver ahora, porque es la fuente del bug de esta pieza: **el
índice de un control no es estable.** Quitas el segundo de tres y el que era
tercero pasa a ser segundo. Si guardaste el índice en algún sitio —una variable,
un `data-*`, el estado de un componente hijo— ese índice ahora apunta a otra cosa,
y no hay ningún error que te avise.

### El cruce, y quién lo hace

La tabla de órdenes tiene que mostrar el nombre del paciente. El dato no está en
la orden —ahí solo hay un `patientId`— y hay tres sitios donde se puede resolver:

**En el componente**, recorriendo la lista de pacientes por cada fila. Es lo más
directo y lo más caro: se ejecuta en cada ciclo de detección de cambios y es
exactamente el patrón que la Fase 10 mide y convierte en su tema.

**En un selector que cruce los dos slices**, con un `createSelector` de dos
entradas. Es lo correcto en teoría —memoizado, calculado una vez— y trae una
consecuencia que hay que aceptar con los ojos abiertos: **acopla la pantalla de
órdenes al slice de pacientes**, así que la tabla queda vacía si el usuario entró
por enlace directo a `/orders` sin pasar nunca por `/patients`.

**En el mock**, pidiéndole que devuelva la orden con su paciente adentro. Es lo
que haría un backend de verdad, y json-server no sabe hacerlo.

Ninguna es gratis, y este curso elige la primera —por fidelidad a LabCore, que la
tiene así— dejando la segunda como ejercicio. Lo que te llevas no es cuál es
mejor: es **saber que la pregunta existe**, porque el día que una tabla se ponga
lenta o salga vacía, la primera sospecha es dónde se resolvió el cruce.

### El slice que no está

Y la pieza conceptual de la fase, que es la que más lejos llega.

`OrdersModule` carga por ruta (`loadChildren`), así que su `StoreModule.forFeature`
solo se ejecuta cuando alguien navega a `/orders`. Hasta ese momento la clave
`orders` **no existe en el store**. No está vacía: no está.

La consecuencia es que `createFeatureSelector<OrdersState>('orders')` devuelve
`undefined`, y `undefined.items` revienta en un componente que no tiene nada que
ver. No es un caso raro: es lo que pasa **siempre** la primera vez, y lo que hace
que un bug aparezca o no según por dónde entró el usuario a la aplicación.

> 🧠 **La regla que se instala aquí y vale para las nueve fases siguientes:** todo
> selector que cruce a otro feature necesita una guarda de `undefined`. No es
> paranoia ni es defensivo por deporte — es que en un sistema con módulos
> perezosos, *"el estado todavía no existe"* es un estado legítimo del sistema y
> hay que representarlo.

### Nota de época

En 2019 la carga diferida por módulo era la única forma de partir un bundle de
Angular, y arrastrar el estado con ella parecía elegante: el slice llega cuando
llega su pantalla. La contrapartida —que el estado de la aplicación dependa de por
dónde navegó el usuario— tardó años en reconocerse como problema. Hoy se resolvería
registrando en la raíz los slices que consulta más de un feature, o cargándolos con
un guard antes de entrar; las dos existían en Angular 8 y ninguna se usó, porque el
síntoma solo aparece cuando hay siete slices y alguien entra por un enlace de chat.

---

## 💻 5. Código mínimo con comentarios

Esta fase no muestra el slice entero: muestra **lo que cambia** respecto del molde
de la Fase 5, que es lo único que hay que decidir. El resto lo escribes tú
copiando, y hacerlo es el ejercicio 1.

### 5.1 El slice, y las tres decisiones que no se copian

Acciones, reducer, selectores, servicio y effects se calcan de la Fase 5 §5.4-5.8
cambiando `patient` por `order`. Estas son las tres cosas que no salen del molde:

```typescript
// src/app/orders/store/orders.reducer.ts (solo lo distinto)

export interface OrdersState {
  items: any[];
  loading: boolean;
  error: any;
  selectedId: number;
  saving: boolean;
  saveError: any;
  // 1. NO hay "filter". La tabla de ordenes filtra por estado, no por texto, y
  //    ese filtro vive en el componente porque no tiene que sobrevivir a
  //    navegar afuera: nadie vuelve a /orders esperando encontrar el filtro
  //    puesto. Compara con la Fase 5, donde el filtro SI esta en el estado y
  //    hay una razón escrita para ello.
  //
  // 2. Tampoco hay "active": una orden no se da de baja logicamente. Se vence
  //    o se entrega, y las dos cosas son estados del flujo, no un borrado. La
  //    baja logica de la Fase 5 §5.2 no se hereda porque no aplica.
}
```

```typescript
// src/app/orders/store/orders.selectors.ts (solo lo distinto)

// 3. La guarda de undefined. Este selector lo consultan pantallas que NO son la
//    de ordenes -el informe de la Fase 9, el dashboard de la Fase 10- y esas
//    pantallas pueden abrirse sin que /orders se haya visitado nunca. Sin el
//    "state &&", el error revienta lejos de acá y no menciona a este archivo.
export const selectOrdersState = createFeatureSelector<OrdersState>('orders');

export const selectAllOrders = createSelector(
  selectOrdersState,
  function (state) { return state && state.items ? state.items : []; }
);
```

> ⚠️ Fíjate en que la guarda va en el **selector derivado** y no en el
> `createFeatureSelector`. Ese devuelve `undefined` y no hay forma de evitarlo: es
> NgRx diciéndote la verdad. Lo que se decide es qué hace el consumidor con esa
> verdad, y devolver `[]` es una traducción cómoda que **esconde información**. El
> ejercicio 14 te hace medir el precio de esa comodidad.

### 5.2 `order-form.component.ts` — el `FormArray`

```typescript
// src/app/orders/order-form/order-form.component.ts (fragmento)
this.orderForm = this.fb.group({
  id: [order ? order.id : null],
  patientId: [order ? order.patientId : null, [Validators.required]],
  // El estado inicial de una orden nueva es "pending", el primero del flujo
  // canonico que fija el dominio.
  status: [order ? order.status : 'pending', [Validators.required]],
  // Un FormArray es un FormGroup cuyos hijos se identifican por indice y no
  // por nombre. Se construye desde el arreglo que llega, no se declara fijo.
  testCodes: this.fb.array(
    (order && order.testCodes ? order.testCodes : []).map(function (this: OrderFormComponent, code: string) {
      return this.fb.control(code, [Validators.required]);
    }.bind(this))
  )
});

// La plantilla necesita el FormArray tipado como tal para iterarlo.
// Este getter existe solo por eso y devuelve any: TS-0.
get testCodesArray(): any {
  return this.orderForm.get('testCodes');
}

addTestCode() {
  this.testCodesArray.push(this.fb.control('', [Validators.required]));
}

removeTestCode(index: number) {
  // removeAt cambia los índices de todo lo que viene después. Si guardas el
  // indice en alguna parte -una variable, el estado de un componente hijo- ese
  // indice queda apuntando a otra cosa y nadie te avisa. Ejercicio 17.
  this.testCodesArray.removeAt(index);
}
```

Y en la plantilla, el detalle que hace que un `FormArray` funcione y que se olvida
la primera vez:

```html
<!-- src/app/orders/order-form/order-form.component.html (fragmento) -->
<!-- formArrayName abre el ambito del arreglo; dentro, cada control se enlaza
     por su INDICE con [formControlName]="i". El corchete no es opcional: sin
     el, Angular busca un control que se llame literalmente "i". -->
<div formArrayName="testCodes">
  <div *ngFor="let control of testCodesArray.controls; let i = index">
    <mat-form-field>
      <input matInput [formControlName]="i"
             [placeholder]="'orders.fields.testCode' | translate">
    </mat-form-field>
    <button mat-icon-button type="button" (click)="removeTestCode(i)">
      <mat-icon>remove_circle</mat-icon>
    </button>
  </div>
</div>

<button mat-stroked-button type="button" (click)="addTestCode()">
  {{ 'orders.actions.addTestCode' | translate }}
</button>
```

### 5.3 `order-list.component.ts` — el cruce, resuelto donde LabCore lo resuelve

```typescript
// src/app/orders/order-list/order-list.component.ts (fragmento)

// El cruce orden -> paciente, hecho en el componente. Se llama desde la
// plantilla, o sea que corre una vez por fila y por ciclo de detección de
// cambios: con 40 ordenes son 40 busquedas lineales cada vez que algo se
// mueve en la pantalla. Con 40 no se nota; el patron es el mismo que la Fase
// 10 §5.7 mide y convierte en su tema central.
//
// Lo correcto sería un selector de dos entradas que cruzara orders y patients
// una sola vez, memoizado. Eso acopla esta pantalla al slice de pacientes, con
// la consecuencia de §4 -tabla vacia si el usuario entro por enlace directo-,
// y es el ejercicio 14.
patientNameFor(order: any): string {
  var patient = this.patients.find(function (p: any) { return p.id === order.patientId; });
  // Si el paciente no esta en la lista cargada -porque el slice de pacientes
  // no se visito, o porque fue dado de baja- se devuelve una clave, no un
  // texto vacio: una celda en blanco parece un dato que falta y esto es otra
  // cosa. La regla de A07 §7: se guarda la clave, se traduce al mostrar.
  return patient ? patient.fullName : 'common.notAvailable';
}
```

### 5.4 El `MatSelect` de estado, y la máquina que todavía no lo es

```html
<!-- La etiqueta NO se arma concatenando el valor. 'orders.status.' + status
     daria 'orders.status.in_process' y la clave del arbol es 'inProcess': el
     dato viaja en snake_case y las claves estan en camelCase. El mapa
     explicito que lo resuelve esta en A07 §4 y es lo unico que sobrevive a que
     alguien agregue un estado nuevo. -->
<mat-form-field class="w-100">
  <mat-label>{{ 'orders.fields.status' | translate }}</mat-label>
  <mat-select formControlName="status">
    <mat-option *ngFor="let option of orderStatuses" [value]="option">
      {{ statusLabelKey(option) | translate }}
    </mat-option>
  </mat-select>
</mat-form-field>
```

Los seis valores son los del flujo canónico —`pending → in_process →
partial_results → complete → delivered → expired`— y el desplegable los ofrece
**todos**, siempre. O sea que ahora mismo puedes llevar una orden de `complete` a
`pending` y el sistema te deja tan tranquilo.

**Eso es correcto hoy y conviene entender por qué.** Una máquina de estados sin
reglas no es un descuido: es el estado normal de un campo de texto que todavía no
las necesita, y es exactamente lo que vas a encontrar en el 90% de los `status` de
cualquier sistema. Las reglas llegan cuando alguien pierde datos por su ausencia, y
en este curso llegan tres veces: la **Fase 7** las escribe para las muestras y fija
dónde vive una guarda, la **Fase 8** las escribe para los resultados con una guarda
doble, y la **Fase 9** endurece la única transición de orden que necesita para
entregar un informe.

> 💸 **Deuda técnica intencional: seis estados sin ninguna guarda.** Lo correcto
> hoy sería el `order.transitions.ts` que la Fase 9 acaba escribiendo, aplicado
> desde el primer día a las seis transiciones y no solo a `complete → delivered`.
> **En Track A no se paga**, y la razón es la que hace útil este capítulo: LabCore
> creció así, y las reglas se le fueron añadiendo a las máquinas *una transición a
> la vez, cada una cuando dolió*. Lo que te llevas es el reflejo de preguntar, ante
> cualquier `status` de cualquier sistema: **¿esto tiene reglas, o solo lo parece?**
> La respuesta casi nunca está donde se guarda el dato.

> **Prueba de fuego.** Con el mock levantado, entra a `/orders` **como primera
> pantalla de la sesión** —sin pasar por `/patients`— y mira la columna del
> paciente: está vacía, porque el slice de pacientes no se ha cargado. Ahora ve a
> `/patients`, vuelve, y mírala otra vez: ahora sí. **La misma pantalla, dos
> comportamientos, y lo único que cambió fue por dónde entraste.** Esa frase es la
> fase entera, y es la que te va a ahorrar la tarde el día que un ticket diga "a
> veces sale vacío".

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**`Cannot read property 'items' of undefined`, en un componente que no es el de órdenes.**
Síntoma: la pantalla de pacientes o el dashboard revientan, y el stack trace
apunta a un selector de órdenes.
Causa: el slice `orders` no está registrado porque nadie navegó a `/orders`. El
`createFeatureSelector` devolvió `undefined`.
Fix mínimo: la guarda de §5.1 en el selector derivado.
Refactorización correcta: decidir si `orders` debería registrarse en la raíz, que
es una decisión de arquitectura y no de hotfix (**A06 §6**).

**El `FormArray` no se pinta, y la consola habla de un control que no existe.**
Síntoma: `Cannot find control with name: 'i'`.
Causa: `formControlName="i"` sin corchetes. Angular lo lee como el nombre literal
`i` en vez de como el valor de la variable.
Fix mínimo: `[formControlName]="i"`. No hay refactorización: es un corchete.

**Quito un examen del formulario y desaparece el que no era.**
Síntoma: hay tres exámenes, borras el segundo y desaparece el tercero — o el
formulario queda con un control fantasma.
Causa: se guardó el índice en algún sitio y `removeAt` corrió los demás. El caso
clásico es un `*ngFor` sin `trackBy` sobre controles que se reordenan.
Fix mínimo: no guardar índices; pasarlos siempre desde el `*ngFor` en el momento.
Refactorización correcta: identificar cada control por un id propio en vez de por
posición, que es lo que haría un `FormArray` de objetos en vez de de cadenas.

**La columna del paciente sale vacía para algunos y llena para otros.**
Síntoma: unas filas muestran el nombre y otras no, sin patrón aparente.
Causa: esos pacientes están dados de baja, y el consumidor de la lista está usando
`selectActivePatients` en vez de `selectAllPatients`. En una tabla de órdenes
**históricas** hace falta el nombre aunque el paciente ya no esté activo.
Fix mínimo: cambiar el selector en este consumidor. Es la otra cara del
**incidente 09** de la Fase 5, y las dos caras tienen razón: cuál selector
corresponde depende de si la pantalla mira el presente o el pasado.

### Pieza forense de esta fase

La pieza es **el estado que todavía no existe**, y se desarrolla completa en
[`forense-fase-06.md`](./forense-fase-06.md). Es la primera vez que el curso te
pide diagnosticar algo cuyo síntoma **depende de la ruta que tomó el usuario**, y
esa clase de bug es de las que más caro salen: no se reproduce contándole a alguien
lo que hiciste, porque lo que importa es lo que hiciste *antes*.

Los tres movimientos son estos. Primero, **confirmar que el estado no está**: se
abre Redux DevTools y se mira el árbol, y la clave `orders` sencillamente no
aparece. No está vacía —eso sería una clave con un objeto dentro—; no está la
clave. Segundo, **encontrar quién la pidió antes de tiempo**, que casi nunca es
donde revienta: el stack trace apunta a la plantilla que intentó pintar, no al
selector que devolvió `undefined`. Y tercero, **decidir de quién es el problema**:
si el consumidor tenía derecho a preguntar —el dashboard lo tiene— la guarda va en
el selector; si estaba preguntando algo que no le corresponde, la guarda tapa un
error de diseño.

**Rompe a propósito y observa.** Quita la guarda de `selectAllOrders` (§5.1),
dejando `return state.items;`. Después **cierra la pestaña y abre la aplicación
directamente en `/patients`** —el enlace directo importa— y añade a esa pantalla un
selector de órdenes cualquiera.

Lo que vas a ver en la pantalla: se cae entera, en blanco. Lo que vas a ver en la
consola: `Cannot read property 'items' of undefined`, apuntando a
`patient-list.component.html`. Lo que vas a ver en Redux DevTools: el árbol de
estado con `patients` dentro y **sin ninguna clave `orders`**.

La mentira que te cuenta la consola es que el problema está en la pantalla de
pacientes, porque es la que se rompió y es el archivo que nombra. No está ahí: está
en que alguien preguntó por un estado que aún no había nacido. Ahora navega a
`/orders`, vuelve a `/patients`, y comprueba que el mismo código funciona
perfectamente. **Ese "funciona si vengo por aquí y no si vengo por allá" es la
firma, y una vez que la reconoces la ves en todas partes.**

---

## 🧪 7. Ejercicios (25)

**🟢 Fácil (1–7)**

1. Construye el slice completo de órdenes copiando el molde de la Fase 5 §5.4-5.8: acciones, reducer en `switch`, selectores, servicio y effects. Regístralo con `StoreModule.forFeature('orders', ordersReducer)` en un `OrdersModule` con carga diferida. Al terminar, anota cuántos minutos te llevó — es la medida de lo que vale un molde.
2. Confirma en la pestaña Network que el `.js` del módulo de órdenes se descarga la primera vez que entras a `/orders` y no antes. Vuelve a `/patients` y otra vez a `/orders`: anota si se descarga de nuevo.
3. Con Redux DevTools abierto, anota el momento exacto en que aparece la clave `orders` en el árbol de estado. Compáralo con lo que hace `patients` al arrancar la aplicación.
4. Agrega las claves `orders.fields.*` y `orders.status.*` al `es.json`, usando el mapa explícito de **A07 §4** para los estados. Confirma que `in_process` se muestra traducido y no como clave cruda.
5. Construye la tabla de órdenes con columnas de paciente, estado y fecha de creación, reusando el `mat-table` de la Fase 5 §5.9.
6. Registra `OrdersModule` en el router con la sintaxis de cadena de Angular 8 (`loadChildren: './orders/orders.module#OrdersModule'`) y añade la entrada de órdenes al menú del shell, con su clave i18n. Confirma que el enlace navega y que entrar directo a `/orders` y recargar también funciona.
7. Completa el `es.json` con las claves de la pantalla —título, botones, mensaje de tabla vacía— y después pon la aplicación en francés. Todo lo que se te haya escapado va a verse como clave cruda: anota cuántas eran.

**🟡 Intermedio (8–16)**

8. Construye el formulario de órdenes con el `FormArray` de §5.2, con botones de añadir y quitar exámenes. Verifica en `db.json` que `testCodes` llega como un arreglo de cadenas y no como un objeto.
9. Añade un examen, guarda, reabre la orden para editarla y confirma que el `FormArray` se reconstruye con los valores que había. Explica en dos líneas qué línea de §5.2 hace posible eso.
10. **Diagnóstico.** Quita los corchetes de `[formControlName]="i"`. Anota el error exacto, en qué momento aparece —compilación o ejecución— y por qué el mensaje habla de un control llamado `i`.
11. Haz que el formulario no permita guardar una orden sin ningún examen. El `FormArray` tiene su propio estado de validez: encuéntralo antes de escribir un `if`.
12. Agrega un filtro por estado a la tabla, con un `mat-select` sobre los seis valores más un "todos". Decide si vive en el componente o en el store, y escribe en dos líneas por qué — la Fase 5 tomó la decisión contraria para su filtro de texto y también tenía razón.
13. Ordena la tabla por fecha de creación y confirma que funciona. Ahora mira el `dueAt` del semillero: la Fase 5 lo sembró igual al `createdAt`. Explica qué consulta se vuelve imposible por eso y qué habría que cambiar en el `seed.js`.
14. Reemplaza el `patientNameFor` de §5.3 por un `createSelector` de dos entradas que cruce `orders` y `patients` una sola vez. Mide con `console.count` cuántas veces se ejecuta cada versión al escribir en un campo cualquiera de la pantalla, y anota los dos números.
15. Duplica el effect de escritura del molde para el `PATCH` de estado y confirma en Network que después de guardar se dispara la recarga de la lista. Ahora quita la recarga, guarda otra vez, y describe qué muestra la pantalla y qué hay realmente en el store.
16. **Diagnóstico.** Cambia el `mergeMap` del effect de escritura por `switchMap`, guarda dos órdenes seguidas lo más rápido que puedas, y anota cuál de las dos se perdió. Explica por qué ni la pantalla ni la consola te avisaron de nada.

**🟠 Difícil (17–22)**

17. **Diagnóstico.** Con el selector cruzado del ejercicio 14 ya puesto, abre la aplicación directamente en `/orders` sin pasar nunca por `/patients`. Anota qué muestra la columna del paciente y por qué. Después decide: ¿es un bug del selector, del módulo, o del enlace? Justifica.
18. **Diagnóstico.** La guarda de §5.1 traduce `undefined` a `[]`, y esa traducción **pierde información**: una pantalla no puede distinguir "no hay órdenes" de "el estado no ha cargado", y las dos se pintan igual —con el mensaje de vacío—. Reprodúcelo, y después propón cómo distinguirlas sin quitar la guarda. Anota qué te costaría en el resto del curso adoptar tu propuesta.
19. **Diagnóstico.** Un ticket dice: *"la tabla de órdenes a veces sale sin nombres de paciente y hay que recargar"*. Con lo que sabes de §4 y §6, escribe las tres preguntas que le harías a quien lo reportó, en orden, y cuál de ellas descarta más posibilidades de un golpe.
20. **Diagnóstico.** Pon tres exámenes en una orden, guarda el índice del segundo en una propiedad del componente, borra el primero y usa el índice guardado. Documenta qué control acabaste tocando y por qué ningún error te avisó.
21. **Diagnóstico.** El `MatSelect` de §5.4 ofrece las seis transiciones sin guarda ninguna. Escribe la tabla de las seis y marca cuáles son ilegales según el flujo del laboratorio; después provoca la peor de todas desde la interfaz y documenta qué quedó inconsistente en `db.json`. No la arregles: eso es la Fase 7, y el contraste entre las dos fases es el material.
22. Mide lo que cuesta de verdad el cruce resuelto en el componente. Siembra cien órdenes, cuenta con `console.count` cuántas veces se ejecuta `patientNameFor` en un solo pintado de la tabla, y compara ese número con el de filas. Explica la relación entre los dos y de dónde sale el factor.

**🔴 Muy difícil (23–25)**

23. **Diagnóstico + regresión.** Reproduce el bug de índices del ejercicio 20 en su forma realista: un `*ngFor` sin `trackBy` sobre los controles del `FormArray`, quitando un elemento del medio mientras uno de los campos tiene el foco. Documenta qué le pasa al foco y al valor escrito a medias, y escribe el test de Jasmine que lo caza —es el que la Fase 12 espera encontrar ya escrito.
24. **Diagnóstico.** Sin tocar el reducer ni el effect, consigue que la tabla de órdenes muestre una orden que ya no existe en `db.json`. Documenta la cadena completa, en qué capa vive la copia vieja, y por qué el patrón de recarga completa de la Fase 5 §5.8 —que existe justamente para evitar esto— no te protegió.
25. **Diagnóstico + diseño.** El slice de órdenes no existe hasta que alguien entra a `/orders`, y a partir de la Fase 9 hay pantallas que lo leen sin haber pasado por ahí. Escribe las tres estrategias posibles —cargar el módulo al arrancar, guardar en cada selector, o resolverlo en la ruta—, implementa la que elijas, y documenta qué le cuesta a cada una de las fases siguientes. Es la decisión que el curso deja abierta a propósito.

**🔥 Opcionales**

- 🔥 Haz que el mock devuelva la orden con su paciente embebido, añadiendo una ruta propia al Express de la Fase 4 que haga el cruce del lado del servidor. Documenta qué desaparece del cliente, y por qué eso es lo que haría un backend de verdad.
- 🔥 Añade `trackBy` al `*ngFor` de la tabla y al del `FormArray`, y mide el re-render con `console.count` antes y después. Anota en cuál de los dos se nota y en cuál no, y por qué.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v8.angular.io/api/forms/FormArray — `FormArray` en la versión del curso: `push`, `removeAt`, `at`, y el estado de validez del arreglo completo. ⚠️ Enlace no verificado al cierre; si `v8.angular.io` no responde, la alternativa es `angular.io` advirtiendo que cubre una versión posterior con formularios tipados que **no** existen aquí.
- https://v8.angular.io/api/forms/FormArrayName — la directiva `formArrayName` de la plantilla, y el enlace por índice de §5.2.
- https://v8.angular.io/guide/lazy-loading-ngmodules — la carga diferida que hace que el slice no exista hasta que alguien navega. Es el mecanismo detrás de toda la §4.
- https://ngrx.io/guide/store/selectors — `createSelector` con varias entradas, para el ejercicio 14. ⚠️ Cubre versiones posteriores; el `createSelector` de la página es compatible con NgRx 8, pero `createFeature` de las guías vecinas **no existe** en tu versión.
- https://github.com/typicode/json-server/tree/v0.16.3 — filtros por campo, que es lo que reemplaza al cruce que json-server no sabe hacer.

**Orden de lectura sugerido:** antes de escribir código, la página de `FormArray`
completa —son diez minutos y evitan los tres errores de §6—. Durante, nada: esta
fase se escribe copiando la anterior. Después, la guía de carga diferida, ya con el
bug de §6 reproducido, que es cuando esa página deja de ser teoría.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos.
> Los enlaces a `v8.angular.io` están marcados como **no verificados** y arrastran
> el pendiente abierto en la Fase 3.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Quedó construido el segundo slice del sistema, y con él la prueba de que el molde
de la Fase 5 se aplica: acciones, reducer en `switch`, selectores, servicio,
effects y componente gordo, con tres diferencias que no eran mecánicas —el
`FormArray`, el cruce contra otro slice y un `status` que parece una máquina de
estados sin serlo—. Quedó declarada la deuda 💸 de las seis transiciones sin
guarda, y quedó instalado el reflejo que esta fase existe para dar: **en un sistema
con módulos perezosos, "el estado todavía no existe" es un estado legítimo, y un
bug que depende de por dónde entró el usuario no es un bug intermitente.**

La **Fase 7 — Muestras y cadena de custodia** es el paso natural por dos razones.
Una es de dominio: una muestra pertenece a una orden, y sin la orden construida no
hay de dónde colgarla — la ruta `/orders/:orderId/samples` que abre esa fase
necesita literalmente lo que acabas de escribir. La otra es de diseño: el `status`
que aquí acepta cualquier salto es lo que allá se convierte en una máquina de
estados con reglas, y la comparación entre las dos pantallas —la misma idea con y
sin guarda— es lo que hace que la lección cale.

> **La señal de que quedó bien:** cuando abras el tercer slice del sistema y en dos
> minutos sepas decir qué tiene de distinto respecto de los dos que ya conoces —y
> que esa diferencia, la que sea, tenga una historia detrás.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-06-ordenes -m "F6 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f06: …`) y los de ejercicio su
> número (`f06 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f06/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **[A]** El cruce `orden → paciente` resuelto en el componente (§5.3) es el mismo patrón que la **Fase 10** mide y convierte en su tema central. Queda como ejercicio 14 acá y como material central allá; si alguna vez se adopta el selector cruzado, hay que revisar qué pantallas quedan acopladas al slice de pacientes.
- **[B]** El `dueAt` que el semillero de la Fase 5 siembra igual al `createdAt` (ejercicio 13). Hace imposible cualquier consulta de vencimiento realista y no molesta a nadie hasta la **Fase 8**, donde las fechas empiezan a compararse de verdad → sugerido como edición retroactiva del `seed.js` cuando esa fase lo necesite.
- **[C]** `trackBy` en las filas de la tabla y en los controles del `FormArray`. Se nombra en §6 como causa de re-render y se mide en la **Fase 10**; acá queda como ejercicio 🔥.
- **[D]** El filtro por estado (ejercicio 12) toma la decisión contraria a la del filtro de texto de la Fase 5, que sí vive en el store. Las dos son defendibles y el curso no fija una regla → sugerido para el **apéndice A06** como sección de "qué va al store y qué no", que ya existe en su §8.

### Reservas para el cuaderno de incidentes

Esta fase **no toma ningún incidente nuevo**, y no por falta de material: el
síntoma que produce —la pantalla que se comporta distinto según por dónde entraste—
ya está reservado como el **candidato de A05 §📌**, *"la validación no hace nada,
pero solo si entras por el enlace que te pasaron por chat"*, que es el mismo
mecanismo un slice más adelante y con un `withLatestFrom` que se queda mudo en vez
de un `undefined` que revienta. Si alguna vez se abre el **22**, ese es su sitio, y
esta fase es donde el estudiante ya lo habría visto una vez.
