# 📎 Apéndice A01 — Angular Material

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **3h**
> Usado por: Fases 3, 5, 6, 7 y 8 · Versión cubierta: `@angular/material` y `@angular/cdk` **8.2.3**
> Estado: Base

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve un problema muy específico: **leer y modificar los formularios y las tablas densos de LabCore sin romper nada**, cuando la documentación oficial te muestra una API que en tu proyecto no existe.

> 🪦 **Corregido.** El primer borrador de este apéndice describía un **tema propio con tipografía personalizada** y por eso subía a 4h. No sobrevivió a la verificación: el proyecto usa el tema **`indigo-pink` prebuilt**, tal como lo instala la **Fase 0 §5.4**. El apartado 2 quedó reescrito completo y las horas vuelven a las **3h** de `propuesta-fases-y-alcance.md`. Como todos los apéndices, no cuentan en el calendario de 122h.

**Qué queda fuera:** los componentes de Material que este proyecto **no usa** —`MatStepper`, `MatTabs`, `MatExpansionPanel`, `MatAutocomplete`, `MatChips`, `MatTree`, `MatBottomSheet`— y que por lo tanto no vas a tener que mantener. Si alguno aparece en una pantalla que heredes, la documentación oficial es el sitio, no este apéndice. Tampoco entra la convivencia con Bootstrap ni quién gana en la cascada: eso es el **Apéndice A02** completo. Ni los formularios reactivos en sí (`FormBuilder`, validadores, `valueChanges`), que son de la **Fase 5 §5.10**.

---

## Índice

- [1. Qué versión estás mirando](#1-qué-versión-estás-mirando)
- [2. El tema](#2-el-tema)
- [3. Qué módulo importar para qué etiqueta](#3-qué-módulo-importar-para-qué-etiqueta)
- [4. `mat-form-field`](#4-mat-form-field)
- [5. Controles de formulario](#5-controles-de-formulario)
- [6. `mat-table`](#6-mat-table)
- [7. `MatDialog`](#7-matdialog)
- [8. `MatSnackBar`](#8-matsnackbar)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Qué versión estás mirando

Antes de copiar nada de internet, tres segundos de verificación:

```bash
# Las dos tienen que coincidir. Material se apoya en el CDK y no tolera
# versiones cruzadas: un CDK desalineado rompe con un error de tipos que no
# menciona ni a Material ni al CDK. Es el ejercicio 21 de la Fase 5.
npm ls @angular/material @angular/cdk
```

Debe responder `8.2.3` en las dos. Si no coinciden, eso es lo primero que hay que arreglar y no hace falta seguir leyendo.

> ⚠️ **La documentación oficial te va a mentir, y hay que saber cómo.** `material.angular.io` publica la versión actual, que a estas alturas va por encima de la 15. Todo lo que veas ahí sobre `@use '@angular/material' as mat`, `mat.define-palette`, componentes standalone, MDC o densidad **no existe en tu proyecto**. La fuente confiable para la 8.2.3 es el código y las guías del repositorio en su tag: `https://github.com/angular/components/tree/8.2.3`. Es la misma técnica que usa la Fase 5 y funciona siempre, aunque el sitio de documentación cambie de forma.

---

## 2. El tema

Este proyecto usa el tema **`indigo-pink` prebuilt**, y esa frase tiene una consecuencia que conviene entender antes de intentar cambiar cualquier color: **no hay un archivo de tema que puedas leer ni tocar.** Un tema prebuilt es un `.css` ya compilado dentro de `node_modules`, sin variables de Sass y sin nada que se le pueda pasar.

Si buscas el tema con `grep -rn "mat-core" src/` no vas a encontrar nada. No está mal tu comando: no existe el archivo.

### 2.1 Dónde está, entonces

En el arreglo `styles` de `angular.json`, que es lo que puso el CLI al correr `ng add @angular/material@8.2.3` en la **Fase 0 §5.4**:

```json
"styles": [
  "node_modules/@angular/material/prebuilt-themes/indigo-pink.css",
  "src/styles.scss"
]
```

Y en `index.html`, dos cosas más que el mismo asistente añadió y que se olvidan enseguida porque nadie las vuelve a abrir:

```html
<!-- src/index.html -->
<!-- La fuente y los iconos se cargan desde Google Fonts. Sin salida a
     internet no obtienes un error: obtienes otra fuente y los nombres de los
     iconos escritos en texto plano. Ver la seccion de Advertencias. -->
<link href="https://fonts.googleapis.com/css?family=Roboto:300,400,500&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

<!-- La clase mat-typography en el body es lo que hace que la tipografia de
     Material alcance a los elementos nativos. Ver 2.2. -->
<body class="mat-typography">
```

Los cuatro archivos prebuilt que trae Material 8 son `indigo-pink`, `deeppurple-amber`, `pink-bluegrey` y `purple-green`. Cambiar de uno a otro es editar esa línea de `angular.json` — y **reiniciar `ng serve`**, porque el arreglo `styles` se lee al arrancar y no se recarga al guardar. Ese es el ejercicio 8 de la Fase 0.

> ⚠️ El orden de esa lista fija la cascada de todo el proyecto: Material primero, `styles.scss` —con Bootstrap adentro— después. Es un contrato del que dependen centenares de plantillas y es asunto del **Apéndice A02 §4**, no de este.

### 2.2 La tipografía: qué hace la clase `mat-typography` y qué no

Un tema prebuilt trae los niveles de tipografía por defecto de Material —Roboto, con sus tamaños para `headline`, `title`, `body-1`, `caption` y `button`— y no se pueden cambiar. Lo único que decides es **a quién alcanzan**.

Y ahí está la parte que sí hay que saber: `mat-typography` aplica los niveles a los componentes de Material sin ayuda, pero un `<h1>`, un `<h2>` o un `<p>` sueltos en tu plantilla **no son componentes de Material y no se enteran de nada**. Para que los alcance, la clase tiene que estar en un ancestro; en este proyecto está en el `<body>`. Si ves que los títulos dentro de un `mat-card` respetan la tipografía del sistema y los de una vista suelta no, empieza por confirmar que la clase sigue en su sitio.

Dos consecuencias prácticas de trabajar con la tipografía del prebuilt:

**Cambiar un tamaño de letra global no tiene camino corto.** Sin archivo de tema no hay `mat-typography-config`, así que las opciones son una regla en `styles.scss` que pise el nivel concreto —local, fea y honesta— o migrar a un tema propio, que es una conversación de equipo y está en los pendientes del cierre. Lo que **no** funciona es buscar la variable de Sass: no hay ninguna.

**Reboot de Bootstrap también quiere decidir la fuente del `body`.** Los dos ponen `font-family`, `font-size` y `line-height` en el mismo sitio, y gana `mat-typography` porque una clase tiene más especificidad que un selector de etiqueta — **independientemente del orden de las hojas**. Es el caso donde razonar solo con "Bootstrap va después" te da la respuesta equivocada, y está desarrollado en el **Apéndice A02 §4.3**.

### 2.3 Las dos cosas que hay que saber antes de tocar un color

**El `primary`, el `accent` y el `warn` no son "tres colores".** Son tres paletas de catorce tonos cada una, y los componentes eligen el tono según el contexto. En `indigo-pink` son Indigo, Pink y Red, y los valores de referencia —los que hacen falta para alinear Bootstrap, en **A02 §5**— son `#3f51b5`, `#ff4081` y `#f44336`.

El `warn` es el que más se cruza en tu camino: lo usan `mat-error`, el borde de los campos inválidos, el icono de advertencia y los botones `color="warn"`, todos a la vez. Con un tema prebuilt no lo puedes cambiar, y eso en la práctica es una protección: **la respuesta a "quiero otro rojo en esta pantalla" es una regla CSS local**, que además es lo correcto. Cuando alguien quiera otro rojo en toda la aplicación, ya no es CSS: es la conversación del tema propio.

**Los diálogos y los snackbars no viven dentro de tu componente.** Material los monta en `.cdk-overlay-container`, colgado directo del `<body>` y fuera del árbol de tu aplicación. De ahí salen dos hechos que explican bugs que parecen inexplicables: los estilos **encapsulados** de tu componente **no llegan** hasta ahí —por eso `MatDialog` y `MatSnackBar` aceptan `panelClass`—, y los estilos **globales**, Bootstrap incluido, **sí llegan**, así que Reboot alcanza el contenido de un diálogo igual que al resto de la página. Un diálogo que se ve raro casi nunca es un problema del diálogo.

> 💡 Si quieres **ver** qué hace cada paleta antes de discutir nada, cambia `indigo-pink.css` por `deeppurple-amber.css` en `angular.json`, reinicia el servidor y mira. Es un cambio de una línea, reversible con Ctrl+Z, y responde en treinta segundos la pregunta de qué partes de la pantalla dependen del tema y cuáles tenían el color escrito a mano en algún `.scss`. Eso último es lo interesante del ejercicio.

> 📝 **Nota de época.** Los temas prebuilt existen desde las primeras versiones de Material y siguen existiendo hoy, pero **la ruta cambió**: en la v8 son `@angular/material/prebuilt-themes/*.css` y a partir de la v15 viven en `@angular/material/prebuilt-themes/` con otros nombres, ya sobre MDC. Y si algún día se abre la conversación del tema propio, la API de la época es `@import '~@angular/material/theming'` con `mat-core`, `mat-palette` y `mat-light-theme`: nada del `@use ... as mat` y `mat.define-palette` que verás en cualquier ejemplo publicado después de 2021, que llegó en la v12 y **aquí no compila**.

---

## 3. Qué módulo importar para qué etiqueta

La consulta número uno, y la causa del error más frecuente de todo Material: `'mat-algo' is not a known element`. Ese mensaje **siempre** significa lo mismo —el módulo no está importado en el `NgModule` donde vive tu componente— y nunca significa que Material esté mal instalado.

En este proyecto los módulos se importan y reexportan desde el `SharedModule` (**Fase 5 §5.3**), así que lo normal es que ya estén todos. Si añades un componente nuevo, esta es la tabla:

| Etiqueta o servicio en tu código | Módulo | Ruta del import |
|---|---|---|
| `<button mat-button>`, `mat-raised-button`, `mat-icon-button` | `MatButtonModule` | `@angular/material/button` |
| `<mat-card>` | `MatCardModule` | `@angular/material/card` |
| `<mat-form-field>` | `MatFormFieldModule` | `@angular/material/form-field` |
| `<input matInput>`, `<textarea matInput>` | `MatInputModule` | `@angular/material/input` |
| `<mat-select>`, `<mat-option>` | `MatSelectModule` | `@angular/material/select` |
| `<mat-datepicker>`, `matDatepicker` | `MatDatepickerModule` **+** `MatNativeDateModule` | `@angular/material/datepicker` y `@angular/material/core` |
| `<mat-checkbox>` | `MatCheckboxModule` | `@angular/material/checkbox` |
| `<mat-radio-group>`, `<mat-radio-button>` | `MatRadioModule` | `@angular/material/radio` |
| `<table mat-table>` | `MatTableModule` | `@angular/material/table` |
| `<mat-paginator>` | `MatPaginatorModule` | `@angular/material/paginator` |
| `matSort`, `mat-sort-header` | `MatSortModule` | `@angular/material/sort` |
| `<mat-icon>` | `MatIconModule` | `@angular/material/icon` |
| `<mat-spinner>`, `<mat-progress-spinner>` | `MatProgressSpinnerModule` | `@angular/material/progress-spinner` |
| `<mat-toolbar>` | `MatToolbarModule` | `@angular/material/toolbar` |
| `<mat-sidenav-container>` | `MatSidenavModule` | `@angular/material/sidenav` |
| `<mat-list>`, `<mat-nav-list>` | `MatListModule` | `@angular/material/list` |
| `MatDialog` (servicio) | `MatDialogModule` | `@angular/material/dialog` |
| `MatSnackBar` (servicio) | `MatSnackBarModule` | `@angular/material/snack-bar` |

**Dos trampas de esta tabla:**

`MatInputModule` y `MatFormFieldModule` son cosas distintas y casi siempre se necesitan juntas. Un `<mat-form-field>` sin nada adentro que Material reconozca lanza en tiempo de ejecución `mat-form-field must contain a MatFormFieldControl`: el error no dice "te falta `matInput` en el input", pero eso es exactamente lo que dice.

`MatDatepickerModule` **no basta**. Sin `MatNativeDateModule` (o algún otro adaptador de fechas), el calendario compila sin quejarse y explota al abrirlo, con un error sobre `DateAdapter` que no menciona el módulo que falta. Ya está comentado en la Fase 5 §5.3 y se repite aquí porque es de las cosas que se vienen a buscar con prisa.

---

## 4. `mat-form-field`

### 4.1 Anatomía

```html
<!-- El campo tal como aparece en los formularios de la Fase 5. Los textos
     visibles salen SIEMPRE por clave de i18n, nunca literales. -->
<mat-form-field class="w-100">
  <mat-label>{{ 'patients.form.documentId' | translate }}</mat-label>
  <input matInput formControlName="documentId" required>
  <mat-hint>{{ 'patients.form.documentIdHint' | translate }}</mat-hint>
  <mat-error *ngIf="errorKeyFor('documentId')">
    {{ errorKeyFor('documentId') | translate }}
  </mat-error>
</mat-form-field>
```

Las piezas y sus reglas: **una sola** `mat-label`, **un solo** control (`matInput`, `mat-select`, etc.), `mat-hint` y `mat-error` **nunca se ven a la vez** —cuando el error aparece, Material esconde el hint—, y `matSuffix` / `matPrefix` para iconos y botones dentro del campo.

### 4.2 Cuándo aparece el `mat-error` (y por qué a veces no aparece)

El `*ngIf` de tu plantilla no es lo único que decide. Material solo muestra el bloque de error si **él** considera que el control está en estado de error, y su criterio por defecto es: el control es inválido **y** (fue tocado **o** el formulario fue enviado).

De ahí sale la queja clásica: *"el campo está vacío y es requerido, pero el error no sale"*. Correcto: nadie lo ha tocado todavía. Si quieres que se muestre igual —típico al cargar un registro incompleto para editarlo— tienes dos caminos: marcar los controles con `markAllAsTouched()` al abrir el formulario, o cambiar el criterio con un `ErrorStateMatcher`:

```typescript
// src/app/shared/validation/immediate-error-state.matcher.ts
import { ErrorStateMatcher } from '@angular/material/core';
import { FormControl, FormGroupDirective, NgForm } from '@angular/forms';

// Muestra el error en cuanto el control es invalido, sin esperar a que lo
// toquen. Útil en pantallas de edición donde los datos llegan ya rotos del
// backend y el usuario tiene que ver que hay que corregir antes de tocar nada.
export class ImmediateErrorStateMatcher implements ErrorStateMatcher {
  isErrorState(control: FormControl | null, form: FormGroupDirective | NgForm | null): boolean {
    return !!(control && control.invalid);
  }
}
```

Se aplica por campo (`<input matInput [errorStateMatcher]="matcher">`) o global, proveyendo `ErrorStateMatcher` en el módulo. Global cambia el comportamiento de todos los formularios del sistema, así que piénsalo dos veces.

### 4.3 `appearance`

En Material 8 el valor por defecto es `legacy`: el subrayado con el label que flota al enfocar. Este proyecto no declara ninguno, así que está en `legacy` en todas partes.

| `appearance` | Cómo se ve | Nota |
|---|---|---|
| `legacy` | Subrayado, label flotante | **El de este proyecto.** Deprecado a partir de v11, eliminado en v15 |
| `standard` | Como legacy pero con espaciados corregidos | El sucesor natural de legacy |
| `fill` | Fondo gris, subrayado | El que hoy recomienda Material |
| `outline` | Borde completo alrededor | El más denso visualmente; útil en formularios con muchos campos |

Mezclar apariencias en una misma pantalla se ve mal y es el tipo de cambio que parece inocente y termina en una discusión de diseño. Si vas a cambiarla, cámbiala en todo el sistema de una vez proveyendo `MAT_FORM_FIELD_DEFAULT_OPTIONS`, y avisa antes.

---

## 5. Controles de formulario

### 5.1 `mat-select` y el `compareWith` que hace falta cuando enlazas objetos

```html
<!-- El estado de una orden, del formulario de la Fase 6 §5.4. Fíjate en que la
     etiqueta NO se arma concatenando el valor: 'orders.status.' + status daria
     'orders.status.in_process', y la clave del arbol es 'inProcess'. El mapa
     explicito vive en A07 §4 y es la unica forma que sobrevive a que alguien
     agregue un estado. -->
<mat-form-field>
  <mat-label>{{ 'orders.fields.status' | translate }}</mat-label>
  <mat-select formControlName="status">
    <mat-option *ngFor="let option of orderStatuses" [value]="option">
      {{ statusLabelKey(option) | translate }}
    </mat-option>
  </mat-select>
</mat-form-field>
```

Con cadenas —que es lo que hace este proyecto para todos sus estados— no hay nada más que saber sobre el `mat-select`. La **Fase 7** resuelve lo mismo para las muestras con botones deshabilitados en vez de un desplegable, y explica por qué: con una máquina de estados, deshabilitar y no ocultar deja que el usuario **vea** el flujo completo aunque no pueda usarlo entero. El problema aparece cuando el `[value]` es un **objeto**: Material compara por identidad de referencia, así que el objeto que viene del backend nunca es el mismo objeto que está en tu lista de opciones, y el `mat-select` se muestra vacío aunque el valor esté ahí. La cura es decirle cómo comparar:

```typescript
// Le enseña al mat-select a comparar por id en vez de por referencia. Sin esto,
// el select "no selecciona nada" con el valor correcto cargado en el control.
compareById(a: any, b: any): boolean {
  return a && b ? a.id === b.id : a === b;
}
```

Y en la plantilla: `<mat-select [compareWith]="compareById" ...>`.

### 5.2 El datepicker, el `MatNativeDateModule` y el idioma

Montaje mínimo, con las tres piezas que tienen que estar:

```html
<mat-form-field>
  <mat-label>{{ 'patients.form.birthDate' | translate }}</mat-label>
  <input matInput [matDatepicker]="birthDatePicker" formControlName="birthDate">
  <mat-datepicker-toggle matSuffix [for]="birthDatePicker"></mat-datepicker-toggle>
  <mat-datepicker #birthDatePicker></mat-datepicker>
</mat-form-field>
```

**El control guarda un `Date`, no una cadena.** El mock devuelve `"1985-03-12"` y hay que convertirlo al cargar el formulario y volver a formatearlo al guardar; la Fase 5 §5.10 lo hace y explica por qué.

**Y ahora el problema que no está en ninguna fase.** La Fase 2 registra los tres locales del curso (`es`, `en`, `fr`) con `registerLocaleData` y provee `LOCALE_ID`. Eso alcanza a los pipes de Angular —`date`, `number`, `currency`— y **no alcanza al datepicker**, que tiene su propio sistema de fechas. Resultado: cambias el idioma con `ngx-translate`, toda la aplicación se traduce, y el calendario sigue con los meses en inglés y la semana empezando en domingo.

Se arregla en dos partes. La estática, en el módulo:

```typescript
import { MAT_DATE_LOCALE } from '@angular/material/core';

// ...
  providers: [
    // El locale inicial del datepicker. OJO: es independiente de LOCALE_ID;
    // que uno este en 'es' no implica nada sobre el otro.
    { provide: MAT_DATE_LOCALE, useValue: 'es' }
  ]
```

Y la dinámica, para que siga los cambios de idioma en caliente, en el componente raíz:

```typescript
import { DateAdapter } from '@angular/material/core';
import { TranslateService } from '@ngx-translate/core';

// ...
  constructor(
    private dateAdapter: DateAdapter<any>,
    private translate: TranslateService
  ) {
    this.dateAdapter.setLocale(this.translate.currentLang);

    // Cuando el usuario cambia de idioma, el calendario tiene que cambiar con
    // el. Sin esta suscripción, el resto de la app se traduce y el datepicker
    // se queda en el idioma con el que arranco la sesión.
    this.translate.onLangChange.subscribe(function (this: AppComponent, event: any) {
      this.dateAdapter.setLocale(event.lang);
    }.bind(this));
  }
```

> ⚠️ El `MatNativeDateModule` delega el formato en el `Intl` del navegador, así que el formato exacto de la fecha **depende del navegador y del sistema operativo del usuario**. Si en algún momento hace falta un formato fijo e idéntico en todas las máquinas —cosa habitual cuando un informe tiene que coincidir con lo que se ve en pantalla—, la respuesta es `@angular/material-moment-adapter` en su versión 8.2.3 con `MAT_DATE_FORMATS`. Es una dependencia más y no está en este proyecto; queda anotado como pendiente al final.

### 5.3 Checkbox y radio

Poco que decir, y eso es una buena noticia. `<mat-checkbox formControlName="active">` funciona con un booleano y `<mat-radio-group>` con cualquier valor primitivo. La única trampa: el texto va **dentro** de la etiqueta, no en un `<label>` aparte, y como todo texto visible, va por clave de i18n.

---

## 6. `mat-table`

### 6.1 Anatomía de las tres partes

Una `mat-table` se escribe en un orden que no es el orden en que se pinta, y eso desconcierta la primera vez. Declaras **columnas** por un lado, **filas** por otro, y una lista que dice **cuáles columnas y en qué orden**:

```html
<table mat-table [dataSource]="dataSource" matSort class="w-100">

  <!-- Una definicion por columna. El nombre del matColumnDef es la clave que
       enlaza con displayedColumns; si no coinciden, la columna no aparece y no
       hay ningun error. -->
  <ng-container matColumnDef="documentId">
    <th mat-header-cell *matHeaderCellDef mat-sort-header>
      {{ 'patients.table.documentId' | translate }}
    </th>
    <td mat-cell *matCellDef="let patient">{{ patient.documentId }}</td>
  </ng-container>

  <ng-container matColumnDef="fullName">
    <th mat-header-cell *matHeaderCellDef mat-sort-header>
      {{ 'patients.table.fullName' | translate }}
    </th>
    <td mat-cell *matCellDef="let patient">{{ patient.fullName }}</td>
  </ng-container>

  <!-- displayedColumns decide qué columnas se pintan y en qué orden. Puedes
       definir más columnas de las que muestras: las que no están en la lista
       simplemente no se dibujan. Es como se hacen tablas con columnas
       opcionales por rol sin *ngIf en el HTML. -->
  <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
  <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
</table>
```

**El fallo silencioso más común:** un typo entre `matColumnDef="documentId"` y la cadena `'documentId'` de `displayedColumns`. No hay error en consola —o hay uno sobre una columna que no existe, según el caso—, simplemente falta una columna. Cuando falte una columna, empieza por comparar esas dos cadenas.

### 6.2 `MatTableDataSource`: lo que verás en la documentación y en código ajeno

En este proyecto el `dataSource` es un **arreglo plano** con la paginación y el orden escritos a mano (**Fase 5 §5.9**), y eso está declarado como 💸 deuda intencional que no se paga. Pero la documentación oficial, la mitad de los ejemplos de internet y probablemente otras pantallas que heredes usan `MatTableDataSource`, así que hay que saber leerlo.

```typescript
import { MatTableDataSource } from '@angular/material/table';
import { MatPaginator } from '@angular/material/paginator';
import { MatSort } from '@angular/material/sort';

export class PatientListComponent implements OnInit, AfterViewInit {

  displayedColumns: string[] = ['documentId', 'fullName', 'birthDate', 'actions'];
  dataSource = new MatTableDataSource<any>([]);

  // El { static: false } es OBLIGATORIO en Angular 8 y es lo primero que
  // distingue un ejemplo de la epoca de uno anterior o posterior: la v8 lo
  // introdujo como bandera explicita y la v9 volvio a hacerlo opcional.
  // static: false = resuelto después del primer ciclo de detección de cambios,
  // que es lo que necesitas cuando el elemento vive detras de un *ngIf.
  @ViewChild(MatPaginator, { static: false }) paginator: MatPaginator;
  @ViewChild(MatSort, { static: false }) sort: MatSort;

  ngOnInit() {
    this.store.select(selectAllPatients).subscribe(function (this: PatientListComponent, patients: any[]) {
      // Se asigna .data, NO se reemplaza el dataSource entero: reemplazarlo
      // desconecta el paginador y el sort, que quedan enlazados al objeto viejo.
      this.dataSource.data = patients;
    }.bind(this));
  }

  ngAfterViewInit() {
    // Aquí y no en ngOnInit: el paginador y el sort son elementos de la vista y
    // en ngOnInit todavía son undefined. El síntoma de hacerlo antes es una
    // tabla que página "de mentira" o un sort que no ordena nada.
    this.dataSource.paginator = this.paginator;
    this.dataSource.sort = this.sort;
  }
}
```

Con eso, `MatTableDataSource` te regala tres cosas que en la Fase 5 están escritas a mano: **paginación** (se conecta sola al `MatPaginator` y calcula el `length`), **orden** (obedece al `matSort` sin escribir un comparador) y **filtro**, que se dispara asignando la cadena:

```typescript
applyFilter(value: string) {
  // Trim y minusculas por convención: el filterPredicate por defecto compara
  // contra el JSON de la fila entera, ya normalizado en minusculas.
  this.dataSource.filter = value.trim().toLowerCase();
}
```

Los dos ganchos que hay que conocer, porque el comportamiento por defecto se queda corto enseguida:

```typescript
// Filtrar solo por las columnas que le importan al usuario. Por defecto, el
// filtro busca en TODAS las propiedades del objeto, incluidos ids internos y
// campos que no se muestran: buscar "3" te devuelve media tabla.
this.dataSource.filterPredicate = function (patient: any, filter: string): boolean {
  return (patient.documentId + ' ' + patient.fullName).toLowerCase().indexOf(filter) >= 0;
};

// Ordenar por algo que no es una propiedad plana: una fecha que llega como
// cadena, o un campo anidado. Sin esto, ordenar por fecha ordena
// alfabeticamente, que casi siempre coincide y por eso el bug tarda en salir.
this.dataSource.sortingDataAccessor = function (patient: any, columnId: string): any {
  if (columnId === 'birthDate') {
    return new Date(patient.birthDate).getTime();
  }
  return patient[columnId];
};
```

> ⚠️ **`MatTableDataSource` es paginación y filtrado en el cliente.** Se trae todo y ordena en memoria. Con las órdenes de un turno va bien; con un histórico completo, no. El día que haya que paginar del lado del servidor —`GET /patients?_page=2&_limit=10`, que json-server soporta—, `MatTableDataSource` deja de ser la herramienta y hay que volver al arreglo plano con el `MatPaginator` informando el total desde la cabecera `X-Total-Count`. O sea: la deuda de la Fase 5 es la solución del caso grande. Que a veces pasa.

---

## 7. `MatDialog`

### 7.1 Abrir, pasar datos, recibir respuesta

```typescript
import { MatDialog } from '@angular/material/dialog';

// ...
confirmDelete(patient: any) {
  var ref = this.dialog.open(PatientDeleteDialogComponent, {
    width: '420px',
    // data es como viajan los datos hacia el dialogo. Llega por inyección con
    // el token MAT_DIALOG_DATA.
    data: { patient: patient },
    // disableClose evita que se cierre con ESC o clic fuera. Se usa cuando hay
    // algo en curso que no se puede interrumpir a medias; para una confirmación
    // normal es una molestia.
    disableClose: false
  });

  // afterClosed emite UNA vez y se completa solo, así que no hace falta
  // desuscribirse. Es la excepción, no la regla.
  ref.afterClosed().subscribe(function (this: PatientListComponent, confirmed: boolean) {
    // OJO: si el usuario cierra con ESC o clicando fuera, aquí llega undefined,
    // no false. Comparar con === false te deja el caso "cerro sin decidir"
    // sin cubrir. Por eso se comprueba la verdad, no la falsedad.
    if (!confirmed) {
      return;
    }
    this.store.dispatch(PatientsActions.deletePatient({ patientId: patient.id }));
  }.bind(this));
}
```

Y del lado del diálogo, la mitad de recibir y responder:

```typescript
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';

// ...
  constructor(
    private ref: MatDialogRef<PatientDeleteDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any
  ) {}

  // Lo que le pases a close() es lo que llega a afterClosed().
  accept() {
    this.ref.close(true);
  }
```

### 7.2 El error de v8 que no existe en versiones posteriores

```
No component factory found for PatientDeleteDialogComponent.
Did you add it to @NgModule.entryComponents?
```

Si aparece, no busques más: en Angular 8 todo componente que se crea **dinámicamente** —los diálogos, y los snackbars con `openFromComponent`— tiene que estar declarado en `entryComponents` del módulo, además de en `declarations`. El compilador no puede saber que ese componente se va a instanciar, porque no aparece en ninguna plantilla, y sin `entryComponents` no genera la factoría.

```typescript
@NgModule({
  declarations: [PatientDeleteDialogComponent],
  // Obligatorio en Angular 8 con ViewEngine. Ivy (v9+) lo hizo innecesario y
  // por eso ningún ejemplo moderno lo menciona: el tuyo si lo necesita.
  entryComponents: [PatientDeleteDialogComponent]
})
```

> 📝 **Nota de época.** Este es probablemente el requisito de Angular 8 que peor envejeció: desapareció en la v9 con Ivy, así que cualquier tutorial posterior a 2020 lo omite y quien copie de ahí se va a estrellar contra este error sin entender por qué. Cuando llegue la conversación de migrar, esta es una de las cosas que Ivy se lleva por delante para bien — y de las pocas que se pagan **gratis**, porque la schematic de `ng update` borra el campo por ti (**Apéndice A10 §2.2 y §3**).

### 7.3 El tipado que casi nadie pone

`dialog.open()` acepta genéricos: `open<TComponent, TData, TResult>`. En este proyecto se usa `any` a discreción y eso está declarado como estilo de la época, pero si escribes un diálogo nuevo y quieres que el `afterClosed()` te devuelva algo tipado en vez de `any`, ahí está la puerta. Es un cambio local que no obliga a nada más.

---

## 8. `MatSnackBar`

El aviso efímero del sistema: aparece abajo, dura unos segundos y se va. En este proyecto se usa para explicar por qué **no** se pudo hacer algo —dar de baja un paciente con órdenes asociadas, en la Fase 5—.

```typescript
import { MatSnackBar } from '@angular/material/snack-bar';

// ...
notifyBlocked() {
  this.snackBar.open(
    // El texto va traducido con instant(): el snackbar recibe una cadena, no
    // una plantilla, así que el pipe translate no sirve aquí.
    this.translate.instant('patients.errors.hasOrders'),
    // Segundo argumento: el texto del boton de acción. Si pasas null o lo
    // omites, el snackbar sale sin boton.
    this.translate.instant('common.actions.close'),
    {
      // Sin duration, el snackbar se queda en pantalla para siempre esperando
      // que alguien lo cierre. Para un aviso informativo eso es un error;
      // para uno que exige acción, es deliberado.
      duration: 5000,
      panelClass: ['lab-snackbar-error']
    }
  );
}
```

**Tres cosas que hay que saber y no son obvias:**

Solo hay **un** snackbar a la vez. Si abres uno mientras hay otro en pantalla, el primero se cierra sin avisar. Disparar snackbars dentro de un bucle o desde un effect que emite varias veces significa que el usuario ve el último y nada más.

Para reaccionar al botón está `onAction()`, que emite si el usuario lo pulsa: es la forma barata de hacer un "deshacer". Y `afterDismissed()` te dice cómo se cerró.

Para algo más que un texto y un botón —un icono, dos acciones, formato— existe `openFromComponent()`, y entonces ese componente necesita ir en `entryComponents`, por lo mismo del apartado 7.2.

---

## 🧭 Cuándo usar qué

**Avisarle algo al usuario.** Cuatro formas y no son intercambiables:

| Situación | Qué usas |
|---|---|
| Tiene que decidir antes de continuar | `MatDialog` — bloquea el flujo, y es el único que garantiza que la decisión se tomó |
| Confirmar algo irreversible (una baja, una validación) | `MatDialog`, ver **Fase 5 §5.11** y **Fase 8** |
| Algo que ya pasó y no requiere acción | `MatSnackBar` con `duration` |
| Explicar por qué una acción **no** se ejecutó | `MatSnackBar` con acción de cerrar |

La regla que las ordena: un diálogo **interrumpe** y un snackbar **acompaña**.
Usar diálogo para informar castiga al usuario dos veces —le pasó algo y encima
tiene que cerrarlo—; usar snackbar para decidir significa que la decisión se puede
perder porque el aviso se fue solo a los cuatro segundos.

**Mostrar un error.** Depende de a qué alcance:

| Alcance | Dónde va |
|---|---|
| Un campo del formulario | `mat-error` dentro de su `mat-form-field` |
| La pantalla entera | Un bloque propio con botón de reintento, el patrón de la **Fase 4** |

Y el porqué es el mismo en los dos casos: **el error vive junto a lo que falló.**
Un snackbar para un campo inválido obliga al usuario a recordar cuál era.

**Listar datos.** Cuatro decisiones encadenadas:

| Situación | Qué usas |
|---|---|
| Muchas filas, columnas comparables | `mat-table` — densidad, que es lo que espera quien pasa ocho horas aquí |
| Pocos elementos con mucha información cada uno | `mat-card` en `*ngFor`, como la **Fase 7** con las muestras |
| Los datos caben en memoria | `MatTableDataSource`: filtro, orden y paginación gratis |
| Histórico grande, o el filtro tiene que ir al backend | Arreglo plano y paginación de servidor |

La última fila es la interesante: es la 💸 de la **Fase 5**, y en ese caso resulta
ser el camino correcto.

**Tocar el aspecto.** Aquí el tema prebuilt decide casi todo (§2):

| Qué quieres cambiar | Qué se puede hacer |
|---|---|
| Un color en una pantalla concreta | Una regla CSS local en el componente. Es el único camino y además es el correcto |
| Un color de Material en toda la aplicación | **No se puede.** El prebuilt es CSS compilado; exige tema propio, y eso es una conversación de equipo (§2.3) |
| Un tamaño de letra global | Una regla en `styles.scss` que pise el nivel. No hay variable de Sass que buscar (§2.2), y avisa antes |
| El aspecto de un diálogo o un snackbar | `panelClass`: viven fuera de tu componente y la encapsulación no los alcanza (§2.3) |

---

## ⚠️ Advertencias

**La documentación oficial cubre versiones muy posteriores.** Es la advertencia central de este apéndice y se repite a propósito: `material.angular.io` publica la versión actual. Si un ejemplo usa `@use '@angular/material' as mat`, `mat.define-palette`, `provideAnimations()`, tokens de densidad o componentes standalone, **no es para ti**. La referencia buena para 8.2.3 es el tag del repositorio.

**Los iconos son una fuente que hay que cargar aparte.** `MatIconModule` dibuja `<mat-icon>delete</mat-icon>` contando con que la fuente *Material Icons* esté disponible; normalmente se carga con un `<link>` a `fonts.googleapis.com` en `index.html`. Si la máquina está en una red corporativa sin salida a internet, no obtienes un error: obtienes la palabra `delete` escrita en la celda, en texto plano. Diagnóstico en cinco segundos: pestaña Network, busca la petición a `fonts.googleapis.com` y mira si falló. La solución de fondo —servir la fuente desde los assets del proyecto— es una decisión de infraestructura, no un arreglo que se hace un martes por la tarde.

**No busques el archivo de tema: no existe.** El tema es un CSS prebuilt dentro de `node_modules` (§2.1), así que no hay variables de Sass que tocar ni paletas que redefinir. El corolario práctico: si cambiaste el nombre del prebuilt en `angular.json` y no ves nada, es porque ese arreglo se lee **al arrancar** y hay que reiniciar `ng serve`. Y si lo que editaste fue un `.scss` propio, la lista de causas de "toqué el color y no cambió" está en el **Apéndice A02 §6.2**, que es donde vive la compilación de Sass.

**El `entryComponents` no es opcional en este proyecto.** Todo componente que se instancia dinámicamente lo necesita. Es el error de v8 que más tiempo hace perder a quien viene de tutoriales modernos.

**No inventes componentes que el proyecto no usa.** Añadir `MatTabsModule` porque queda bien es añadir superficie que alguien va a tener que mantener, y rompe la coherencia visual de un sistema que lleva años con las mismas cuatro formas. Si crees que hace falta uno nuevo, es una conversación con el equipo, no un commit.

---

## 📚 Referencias

- https://github.com/angular/components/tree/8.2.3 — **la fuente de verdad para esta versión.** El código y las guías tal como estaban en la 8.2.3. Cuando la documentación oficial y tu proyecto no coincidan, gana esto.
- https://github.com/angular/components/blob/8.2.3/guides/theming.md — la guía de theming de la época. Lista los cuatro temas prebuilt y sus rutas, que es lo que necesitas del apartado 2; el resto —`mat-core`, `mat-palette`, `mat-light-theme`— es para el día que se abra la conversación del tema propio.
- https://github.com/angular/components/blob/8.2.3/guides/typography.md — los niveles de tipografía por defecto y la clase `mat-typography` del apartado 2.2. Los tamaños exactos de cada nivel salen de acá.
- https://github.com/angular/components/blob/8.2.3/src/material/table/ — el código de `MatTable` y `MatTableDataSource`. Leer `table-data-source.ts` responde en dos minutos cualquier duda sobre `filterPredicate` y `sortingDataAccessor`.
- https://material.angular.io/components/categories — el catálogo con ejemplos vivos. ⚠️ Versión actual, muy posterior a la tuya: úsalo para **ver** qué hace un componente, nunca para copiar código.
- https://v8.material.angular.io/ — el sitio archivado de la v8, si sigue en pie. Verifica que resuelve antes de confiar en él; los sitios de documentación archivada tienden a desaparecer sin aviso.
- https://v8.angular.io/api/core/ViewChild — el `static` obligatorio de Angular 8, que aparece en todos los `@ViewChild` del apartado 6.2.
- https://fonts.google.com/icons — el catálogo de nombres de iconos para `<mat-icon>`.

> ⚠️ Los enlaces y sus contenidos pueden haber cambiado o desaparecido; verifícalos. Los de `github.com/angular/components/tree/8.2.3` son los más estables porque apuntan a un tag inmutable: si algo se mueve, muévete tú hacia ellos.

---

## 🧪 Ejercicios (8)

Cortos y de consulta. Todos sobre el proyecto del laboratorio, con la aplicación de las Fases 5 a 8 corriendo.

1. Corre `grep -rn "mat-core" src/` y confirma que no devuelve nada. Después localiza el tema en `angular.json` y anota la ruta exacta del prebuilt y qué hoja se carga inmediatamente después. Explica en una línea por qué no hay archivo de tema que leer.
2. Cambia el prebuilt a `deeppurple-amber.css` y recarga **sin** reiniciar el servidor: anota qué pasa. Reinicia y anota ahora **todos** los sitios donde cambió algo — y al menos uno donde no cambió nada. Ese que no cambió tiene el color escrito a mano en algún `.scss`; localízalo. Revierte después.
3. Quita la clase `mat-typography` del `<body>` en `index.html` y compara un `<h2>` que esté dentro de un `mat-card` con uno que esté fuera. Explica en una línea por qué solo uno cambió.
4. En el formulario de paciente, borra el `matInput` del campo de documento dejando el `<input>` normal. Anota el error exacto que aparece y en qué momento aparece —compilación o ejecución—. Es el error del apartado 3.
5. Reemplaza el arreglo plano del listado de pacientes por un `MatTableDataSource` con `filterPredicate` que busque solo por documento y nombre. Verifica que el filtro ya **no** encuentra pacientes al escribir el id interno. Es la 💸 de la Fase 5 pagada por curiosidad, en una rama que no vas a mergear.
6. Ordena la tabla de pacientes por fecha de nacimiento sin `sortingDataAccessor` y busca un caso donde el orden alfabético de la cadena y el orden cronológico real **no** coincidan. Después arréglalo con el accessor del apartado 6.2 y confirma que ese caso ahora sale bien.
7. Añade el `MAT_DATE_LOCALE` y el `dateAdapter.setLocale()` del apartado 5.2. Cambia el idioma a francés con el selector de la Fase 2 y confirma que el calendario cambia de idioma y de primer día de la semana. Anota qué pasaba antes de tu cambio.
8. **Diagnóstico.** Quita `PatientDeleteDialogComponent` de `entryComponents` sin quitarlo de `declarations`, y abre el diálogo. Anota el error completo, el momento en que aparece, y por qué ningún tutorial publicado después de 2020 lo menciona.


> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida: el código que
> explica lo escriben las fases, y un tag que no apunta a un cambio no marca
> nada. Lo que salga de leerlo se commitea con el prefijo de la fase desde la
> que llegaste (`f03: …`), para que su `git log --oneline --grep '^f03'`
> siga completo. Y si un ejercicio produjo una medición, el número va en el
> mensaje de un tag anotado (`ej/a01/3`), que es donde no se pierde. La
> convención completa —tags de fase, de ejercicio y de incidente— está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **`@angular/material-moment-adapter` y `MAT_DATE_FORMATS`** — para un formato de fecha idéntico en todas las máquinas, independiente del `Intl` del navegador. Es una dependencia nueva y una decisión de proyecto; destino natural: **incidente** sobre fechas que no coinciden entre pantalla e informe, emparentado con la deuda de zona horaria de la **Fase 8**.
- **Tema propio de Material en vez del prebuilt** — es lo que desbloquea cambiar colores y tipografía de verdad (§2.2, §2.3) y lo que permitiría una sola fuente de verdad de color con Bootstrap, tal como lo plantea la deuda 💸 del **Apéndice A02 §5.3**. Es un cambio visual global con riesgo en pantallas que nadie está mirando. Destino corregido al escribir A10: **decisión de proyecto propia**, antes o después de una migración pero **nunca durante** — el **Apéndice A10 §⚖️** explica por qué mezclar un cambio visual global con un salto de versión hace imposible saber qué rompió qué.
- **Servir la fuente y los iconos desde los assets** en vez de desde `fonts.googleapis.com` (§2.1) — decisión de infraestructura, con implicaciones de red corporativa. Destino: una nota en la **Fase 0 §5.4** y un **incidente** 🟢 de configuración —"los iconos salen como palabras"—, que se diagnostica en la pestaña Network en cinco segundos.
- **`MAT_FORM_FIELD_DEFAULT_OPTIONS` para migrar de `legacy` a `outline`** en todo el sistema — es un cambio visual global y por lo tanto una conversación de equipo. Destino corregido al escribir A10: **decisión de proyecto propia**, por la misma razón que el punto anterior (**A10 §⚖️** y sus pendientes).
- **Accesibilidad de los componentes de Material** —`aria-label` en botones de solo icono, foco al abrir un diálogo, anuncio del snackbar a lectores de pantalla— no cabe en un apéndice de consulta y da para su propio documento. Destino: **apéndice nuevo** o sección 🔥, si el alcance del curso se amplía alguna vez.
