# 📎 Apéndice A01 — Angular Material 16 (MDC)

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: [Fase 1](01-estructura-base-ngmodules.md), [Fase 5](05-standalone-convivencia.md), [Fase 6](06-clientes-activos.md) · Versión cubierta: Angular Material y CDK 16.2.14

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve un problema muy específico de este track: **leer y modificar los formularios y tablas densos de CertCore sin pelearse con unos componentes que se reescribieron por dentro y conservaron el nombre por fuera.**

Ésa es la frase que hay que tener presente en todo el apéndice. Material 15 cambió de motor —pasó a MDC, la implementación de referencia de Material Design— y reescribió casi todos los componentes manteniendo selectores y clases de Angular idénticos. La consecuencia práctica: **cualquier artículo, respuesta de Stack Overflow o captura anterior a 2023 describe un componente distinto con el mismo nombre.** No está mal escrito; está describiendo otra cosa.

**Qué queda fuera:** los componentes de Material que CertCore no usa (`mat-stepper`, `mat-tree`, `mat-autocomplete`, `mat-chips`…), el rediseño visual del sistema —la paleta y la densidad quedaron cerradas en la Fase 6 y ninguna fase posterior las toca—, y Bootstrap, que es **A02** 🔥. Tampoco entra el tipado de los formularios que van dentro de un `mat-form-field`: eso es **A05**.

---

## Índice

- [1. Qué reescribió MDC, y qué de eso vive en CertCore](#1-qué-reescribió-mdc-y-qué-de-eso-vive-en-certcore)
- [2. El tema, en un archivo](#2-el-tema-en-un-archivo)
- [3. `mat-form-field`: lo que cambió y muerde](#3-mat-form-field-lo-que-cambió-y-muerde)
- [4. `mat-table`: array simple frente a `MatTableDataSource`](#4-mat-table-array-simple-frente-a-mattabledatasource)
- [5. `MatDialog`: datos de ida, resultado tipado de vuelta](#5-matdialog-datos-de-ida-resultado-tipado-de-vuelta)
- [6. `MatSnackBar`, y la duración que sí se decide](#6-matsnackbar-y-la-duración-que-sí-se-decide)
- [7. Densidad: la muesca que hace caber un formulario](#7-densidad-la-muesca-que-hace-caber-un-formulario)
- [8. Qué se puede tocar por CSS, y qué no](#8-qué-se-puede-tocar-por-css-y-qué-no)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Qué reescribió MDC, y qué de eso vive en CertCore

Lo que hay que saber para no perder una tarde, en cinco puntos:

**El DOM interno de casi todos los componentes cambió.** Las clases `.mat-form-field-infix`, `.mat-form-field-wrapper` y compañía de Material 14 ya no existen. Las nuevas llevan prefijo `.mat-mdc-` y su estructura es otra. Cualquier CSS que un proyecto heredado tuviera apuntando a las viejas dejó de aplicar **en silencio**: no hay error, sólo un estilo que ya no se ve.

**`appearance` se quedó con dos valores.** `legacy` y `standard` desaparecieron. Sólo quedan `fill` y `outline`, y el valor por defecto es `fill`. CertCore usa `outline` en todas partes.

**Los componentes crecieron.** La altura por defecto de un `mat-form-field` de MDC es mayor que la de Material 14 — es lo que manda la especificación de Material Design, pensada para móvil. En una aplicación de tablas y formularios densos eso desperdicia media pantalla, y es la razón exacta de la densidad `-1` de la Fase 6 (§7).

**`mat-error` y `mat-hint` tienen que estar dentro del `mat-form-field`.** En Material 14 quedar fuera se toleraba en algunos casos; en MDC no se pinta, y **no da ningún error**. Es la causa raíz de un error común de la Fase 6.

**Los módulos `legacy` existen en la 16 y no se usan aquí.** Material 15 publicó `@angular/material/legacy-form-field` y sus hermanos como puente para migrar sin rehacer el CSS. Siguen existiendo en la 16, en desuso, y desaparecieron después. **CertCore no tiene ni uno**: la migración de 2024 pasó directamente a los componentes MDC. Si te lo encuentras en otro sistema, ya sabes qué es y sabes que tiene fecha de caducidad.

> 📝 **Nota de migración.** El salto a MDC es de Material **15**, no de la 16. CertCore migró a Material 16.2.14 durante 2024 y se comió el cambio entero de una vez, que es lo que hace casi todo el mundo: nadie migra a la 15 para quedarse ahí. Por eso en el repositorio no hay rastro de la era intermedia, y por eso todo lo que en este apéndice se llama "lo de antes" es Material 14 y anteriores.

---

## 2. El tema, en un archivo

Todo el tema de CertCore vive en `src/styles.scss` y quedó cerrado en la Fase 6. Aquí está la anatomía, para cuando tengas que leerlo o justificar por qué no lo tocas.

```scss
// src/styles.scss
@use '@angular/material' as mat;

// mat.core() va UNA SOLA VEZ en todo el proyecto: trae los estilos base que
// comparten todos los componentes. Repetirlo duplica CSS sin avisar.
@include mat.core();

// define-palette recibe un mapa de tonos y devuelve una paleta con sus
// variantes por defecto, claras y oscuras, más los colores de contraste.
$certcore-primary: mat.define-palette(mat.$indigo-palette);
// Los tres argumentos extra son: tono por defecto, tono claro, tono oscuro.
$certcore-accent: mat.define-palette(mat.$pink-palette, A200, A100, A400);
$certcore-warn: mat.define-palette(mat.$red-palette);

$certcore-theme: mat.define-light-theme((
  color: (primary: $certcore-primary, accent: $certcore-accent, warn: $certcore-warn),
  typography: mat.define-typography-config(),
  density: -1,
));

@include mat.all-component-themes($certcore-theme);
```

**Detalles con intención**

- **`define-light-theme` con las tres claves.** Un tema al que le falte `typography` o `density` **no genera** los estilos de tipografía o densidad de los componentes, y el resultado es un formulario que se ve raro sin que nada falle. Es de los pocos sitios donde omitir una clave produce un fallo silencioso.
- **`all-component-themes` y no los mixins uno a uno.** Genera CSS para componentes que quizá no uses —y eso pesa, y en la Fase 13 se mide— a cambio de no volver a fallar nunca cuando alguien añada un componente en la Fase 10. Con los mixins individuales, ese día alguien pasa media hora buscando por qué el `mat-chip` nuevo sale sin colores.
- **La paleta no se toca a partir de aquí.** Si una fase necesita un color para "certificado por vencer", sale de `warn` o de una clase propia. Un tema que crece por acumulación de excepciones deja de ser un tema.

**La tipografía, cuando de verdad hay que ajustarla:**

```scss
$certcore-typography: mat.define-typography-config(
  $font-family: 'Roboto, sans-serif',
  // Cada nivel es una llamada a define-typography-level(tamaño, interlineado, peso).
  $body-1: mat.define-typography-level(14px, 20px, 400),
  $button: mat.define-typography-level(14px, 14px, 500),
);
```

> ⚠️ **Tocar variables Sass sin recompilar no cambia nada, y es la media hora perdida más frecuente de todo el tema.** `ng serve` sí recompila los estilos globales al guardar; lo que no se entera de nada es el navegador con el CSS viejo en caché, ni un contenedor de la Fase 13 construido antes del cambio. Si tocaste el tema y no ves diferencia, recarga forzando (`Cmd/Ctrl` + `Shift` + `R`) antes de buscar la causa en el Sass.

---

## 3. `mat-form-field`: lo que cambió y muerde

Es el componente que más aparece en CertCore y el que peor envejeció la documentación ajena.

```html
<mat-form-field appearance="outline">
  <mat-label>Razón social</mat-label>
  <input matInput formControlName="legalName" />

  <!-- Los mat-error van DENTRO del mat-form-field. Fuera no se pintan, y no
       da ningún error: simplemente el mensaje no aparece nunca. -->
  <mat-error *ngIf="form.controls.legalName.hasError('required')">
    La razón social es obligatoria.
  </mat-error>
  <mat-error *ngIf="form.controls.legalName.hasError('minlength')">
    Escribe al menos 3 caracteres.
  </mat-error>
</mat-form-field>
```

**Los cuatro puntos que hay que saber:**

**`appearance` tiene dos valores.** `fill` (por defecto) y `outline`. Si encuentras `appearance="legacy"` o `"standard"` en un ejemplo, es de Material 14 o anterior y no compila aquí — el error de plantilla lo dice, y es de los pocos que se entienden a la primera.

**`mat-error` sólo se pinta cuando el control es inválido *y* está `touched` o el formulario se envió.** Un campo que nace inválido —`required` sin valor— no muestra nada hasta que el usuario lo toca. Es correcto y desconcierta la primera vez: por eso el `submit()` de la Fase 6 llama a `markAllAsTouched()` antes de rendirse.

**`subscriptSizing` decide si el hueco del mensaje está siempre reservado.** El valor por defecto es `fixed`: bajo cada campo hay un espacio fijo para el error, aunque no haya error, y así el formulario no salta cuando aparece uno. Con `dynamic`, el hueco sólo existe cuando hay mensaje, y el layout se mueve.

```html
<!-- Un formulario que salta al validar es peor que uno un poco más alto.
     `fixed` es el valor por defecto y en CertCore se deja como está. -->
<mat-form-field appearance="outline" subscriptSizing="fixed">
```

**Y el que produce un ticket cada dos meses:** un `mat-form-field` **tiene que contener exactamente un control** con directiva de Material (`matInput`, `matSelect`, `matChipGrid`…). Ni cero —error `mat-form-field must contain a MatFormFieldControl`— ni dos. Meter dos inputs para una fecha "desde/hasta" dentro del mismo campo es la forma de encontrarse ese error, y la solución es dos `mat-form-field`.

---

## 4. `mat-table`: array simple frente a `MatTableDataSource`

`mat-table` acepta las dos cosas en `[dataSource]`, y elegir mal es la causa de la mitad de las tablas que no repintan.

```html
<table mat-table [dataSource]="view.visible" [trackBy]="trackByClientId">
  <ng-container matColumnDef="legalName">
    <th mat-header-cell *matHeaderCellDef>Razón social</th>
    <td mat-cell *matCellDef="let client">{{ client.legalName }}</td>
  </ng-container>

  <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
  <tr mat-row *matRowDef="let row; columns: displayedColumns"></tr>
</table>
```

| Opción | Qué trae | Cuándo |
|---|---|---|
| Array simple (`readonly T[]`) | nada: tú filtras, ordenas y paginas | **lo que usa CertCore**; el estado ya viene calculado del servicio |
| `MatTableDataSource<T>` | filtrado, ordenación y paginación **en cliente**, atados a `MatSort` y `MatPaginator` | prototipos y tablas pequeñas cuyo dato completo cabe en memoria |

**Por qué CertCore usa el array.** El listado de clientes filtra y pagina en el servicio de estado, con un derivado que la plantilla recibe ya resuelto (`ClientListView`). Con `MatTableDataSource` esa lógica se duplicaría dentro del componente y quedarían dos sitios donde se decide qué filas se ven — que es exactamente la clase de problema que la regla de "lo que se puede calcular no se guarda" evita.

> ⚠️ **Con `OnPush` y un array simple, la referencia lo es todo.** Si mutas el array con `push` o `sort`, la referencia no cambia, `mat-table` no se entera y la tabla se queda como estaba. Es la 💸 de la Fase 4 pagándose en la Fase 6, y la variante cruel es que la pantalla heredada de activos —que no tiene `OnPush`— **se refresca igual**, así que el mismo bug se ve en una pantalla y no en la otra.

**`trackBy` no es opcional en una tabla que se repinta seguido.** Sin él, cada emisión destruye y recrea todas las filas: se pierde el foco, se cierran los expandibles, y el scroll salta.

```ts
// El identificador estable de la fila, nunca el índice.
trackByClientId(_index: number, client: Client): number {
  return client.id;
}
```

---

## 5. `MatDialog`: datos de ida, resultado tipado de vuelta

El patrón completo de CertCore son tres piezas, y las tres están tipadas a propósito.

```ts
// 1. Lo que hay que darle al abrirlo. Una interfaz, nada de objeto suelto.
export interface ConfirmDialogData {
  readonly title: string;
  readonly message: string;
  readonly confirmLabel: string;
}

// 2. Dentro del diálogo: el token no tiene tipo, así que el genérico es
//    obligatorio. Sin él, `any` entra por la puerta grande.
readonly data = inject<ConfirmDialogData>(MAT_DIALOG_DATA);
readonly dialogRef = inject<MatDialogRef<ConfirmDialogComponent, boolean>>(MatDialogRef);
```

```ts
// 3. Al abrirlo: el segundo genérico de MatDialogRef es el tipo del resultado,
//    y es lo que permite filtrar sin un solo `as`.
this.dialog
  .open<ConfirmDialogComponent, ConfirmDialogData, boolean>(ConfirmDialogComponent, {
    data: { title: 'Dar de baja', message: '…', confirmLabel: 'Dar de baja' },
  })
  .afterClosed()
  .pipe(filter((confirmed): confirmed is true => confirmed === true))
  .subscribe(() => this.clientState.remove(clientId));
```

**Detalles con intención**

- **`afterClosed()` emite `undefined` cuando el usuario cierra con Escape o pulsando fuera**, no `false`. Por eso el filtro compara contra `true` explícitamente en vez de comprobar si hay valor: "cerró sin decidir" y "dijo que no" son lo mismo aquí, y confundirlos con un `if (result)` funciona hasta que el resultado sea un `0` o una cadena vacía.
- **El diálogo no borra nada.** Devuelve `true` o `false` y se va. Si supiera borrar clientes, no serviría para confirmar la baja de un activo, y habría dos diálogos casi iguales — que es como nacen los componentes con siete `@Input` opcionales.
- **`MatDialogModule` hay que importarlo aunque la plantilla no use ninguna de sus directivas.** `MatDialog` es un servicio provisto por ese módulo; sin el import, el `inject(MatDialog)` es un `NullInjectorError`. Es el caso que la Fase 5 anuncia: importar un `NgModule` desde un componente standalone también trae sus providers.

---

## 6. `MatSnackBar`, y la duración que sí se decide

```ts
private readonly snackBar = inject(MatSnackBar);

// Mensaje, etiqueta de la acción, opciones. La duración se decide, no se copia.
this.snackBar.open('No se pudo cargar el cliente.', 'Cerrar', { duration: 6000 });
```

**La duración es una decisión de producto y hay dos criterios.** Una confirmación de algo que salió bien puede durar 3 segundos: nadie necesita leerla dos veces. Un error que el usuario tiene que entender —y quizá reintentar— dura 6 segundos o no se cierra solo, y lleva su botón de "Cerrar". Un snackbar de error de 2 segundos es, en la práctica, un error que nadie vio.

**Lo que un snackbar no es:** el sitio donde vive un error. Un error de carga vive en `state.error` para que la pantalla lo pinte donde corresponde (**A07** §6); el snackbar es un aviso pasajero encima. Si el único rastro de un fallo desaparece a los seis segundos, la pantalla se queda diciendo que no hay clientes cuando lo que pasó fue un 500.

`MatSnackBarModule` tiene la misma peculiaridad que `MatDialogModule`: se importa por el servicio, no por las directivas.

---

## 7. Densidad: la muesca que hace caber un formulario

La densidad es un número entero entre `0` y `-5` que encoge la altura de los componentes sin tocar sus tipografías. Es el ajuste que más se nota en una aplicación como ésta y el que menos gente conoce.

```scss
// Global, dentro del tema. Es lo que hace CertCore.
$certcore-theme: mat.define-light-theme((/* … */ density: -1));

// Por componente, cuando una zona concreta necesita más.
.certcore-dense-table {
  @include mat.table-density(-3);
}
```

**Por qué `-1` y no `0` ni `-2`.** Con `0` —el valor de fábrica de MDC— un formulario de seis campos no cabe en una pantalla de portátil, y el inspector acaba haciendo scroll para ver el botón de guardar. Con `-2` se gana espacio y se pierde área táctil, que en una tablet en campo importa más que en un escritorio. `-1` es el compromiso, y está tomado con ese caso de uso en la cabeza.

> 💡 **La densidad no cambia el tamaño de la letra.** Encoge alturas, rellenos y áreas táctiles. Si lo que quieres es letra más pequeña, eso es `define-typography-config`, y son dos ajustes independientes que la gente confunde constantemente porque los dos "hacen la pantalla más compacta".

---

## 8. Qué se puede tocar por CSS, y qué no

Aquí es donde MDC cobra su factura, y conviene ser honesto sobre lo que hay.

**Lo que está soportado, por orden de preferencia:**

1. **El tema y sus mixins.** Paleta, tipografía y densidad, globales o por componente (`mat.form-field-density`, `mat.table-density`). Es la única vía que Angular garantiza entre versiones menores.
2. **Tus propias clases sobre tus propios elementos.** El `div` que envuelve la tabla es tuyo; estíralo, márgenalo y colórealo cuanto quieras.
3. **Las variables CSS `--mdc-*` que MDC expone.** Funcionan, y en Material 16 **no son API pública**: no están documentadas como contrato y pueden cambiar de nombre entre versiones. Usarlas es una decisión con fecha de revisión, no una solución.

**Lo que no está soportado, y por qué se rompe:**

```scss
// ❌ Apunta al DOM interno del componente. Funciona hoy y deja de funcionar
//    en la siguiente versión menor, sin error y sin aviso.
::ng-deep .mat-mdc-form-field-infix {
  padding: 4px 0;
}
```

`::ng-deep` está en desuso desde hace años, no tiene sustituto, y sigue siendo lo que todo el mundo usa. La regla práctica para CertCore, que es un sistema en mantenimiento y no un producto de diseño:

> 🧭 **Regla del proyecto: antes de escribir un `::ng-deep`, comprueba si el tema o un mixin de densidad resuelven el 80% del problema.** Casi siempre lo hacen. Si aun así hace falta, el `::ng-deep` va con un comentario que diga **a qué versión de Material apunta** y **qué se supone que consigue**, porque quien lo encuentre dentro de dos años necesita saber si sigue haciendo algo. Un `::ng-deep` sin comentario es CSS que nadie se va a atrever a borrar nunca.

---

## 🧭 Cuándo usar qué

| Situación | Qué usar | Por qué |
|---|---|---|
| Cambiar colores, tipografía o alturas | el tema en `styles.scss` | única vía soportada entre versiones |
| Compactar una zona concreta | `mat.<componente>-density(-N)` | no toca el resto de la aplicación |
| Mensaje de validación | `mat-error` **dentro** del `mat-form-field` | fuera no se pinta y no avisa |
| El campo salta al validar | `subscriptSizing="fixed"` (el valor por defecto) | el hueco reservado evita el salto |
| Tabla cuyo dato ya viene filtrado del estado | array simple + `trackBy` | evita duplicar la lógica de filtrado |
| Tabla pequeña, filtrado y orden en cliente | `MatTableDataSource` con `MatSort` y `MatPaginator` | trae hecho lo que necesitas |
| Confirmar una acción destructiva | `MatDialog` con datos y resultado tipados | y el diálogo no ejecuta la acción, sólo responde |
| Avisar de algo pasajero | `MatSnackBar` con duración decidida | 3 s si salió bien, 6 s y botón si salió mal |
| Un error que la pantalla debe seguir mostrando | `state.error`, no un snackbar | un aviso que se va no es un estado |
| Ajustar el interior de un componente | primero el tema; `::ng-deep` sólo comentado | el DOM interno de MDC no es contrato |

---

## ⚠️ Advertencias

- **La referencia es https://v16.material.angular.io, no `material.angular.io`.** Ésta última documenta la 17 en adelante y sus ejemplos usan control flow `@if`/`@for` y componentes standalone por defecto, que aquí no aplican.
- **Casi cualquier artículo o respuesta anterior a 2023 describe un componente distinto con el mismo nombre.** No es que esté desactualizado en los detalles: es que el DOM, las clases y varias entradas cambiaron. Antes de copiar una solución de CSS, mira su fecha.
- **Los módulos `@angular/material/legacy-*` existen en la 16 y desaparecieron después.** Si tu proyecto heredado los usa, esa migración está a medias y tiene una fecha límite. CertCore no los tiene.
- **`mat.core()` una sola vez.** Repetirlo en varios `.scss` duplica CSS base sin que nada falle, y lo notarás en el presupuesto de bundle de la Fase 13, no en desarrollo.

---

## 📚 Referencias

- https://v16.material.angular.io — la referencia por defecto de este apéndice. Cada componente tiene su pestaña de API y su pestaña de ejemplos.
- https://v16.material.angular.io/guide/theming — `define-palette`, `define-light-theme`, `mat.core()` y los mixins de componente.
- https://v16.material.angular.io/guide/typography — `define-typography-config` y `define-typography-level`.
- https://v16.material.angular.io/guide/theming-your-components — la guía sobre densidad, y sobre qué está soportado personalizar.
- https://v16.material.angular.io/components/form-field/overview — `appearance`, `subscriptSizing`, y la regla del control único.
- https://v16.material.angular.io/components/table/overview — `mat-table` con array y con `MatTableDataSource`, y `trackBy`.
- https://v16.material.angular.io/components/dialog/api — `MatDialogRef` con sus dos genéricos y `MAT_DIALOG_DATA`.
- https://github.com/angular/components/blob/16.2.x/guides/mdc-migration.md — la guía oficial de migración a MDC. Es el documento que explica, componente por componente, qué cambió; es la mejor lectura si heredas un proyecto a medio migrar.

> ⚠️ Los enlaces con `v16.` delante son estables; los que no lo llevan te van a llevar a la versión actual sin avisar. Si un ejemplo que copias no compila, comprueba la URL antes que el código.

**Orden de lectura sugerido:** la §1 antes que nada, aunque sólo sea para saber por qué lo que encuentres en internet puede estar describiendo otra cosa. La §3 con la Fase 6 abierta, que es donde escribes tu primer formulario. La §4 cuando la tabla no repinte. La §2 y la §7 sólo si tienes que justificar por qué el tema no se toca. La §8 el día que estés a punto de escribir un `::ng-deep` — y ojalá sea antes y no después.

---

## 🧪 Ejercicios (8)

1. 🟢 Cambia `appearance="outline"` por `appearance="fill"` en el formulario de clientes y compara las dos capturas. Después prueba `appearance="legacy"` y anota el error exacto que da el compilador de plantillas.

2. 🟢 Saca un `<mat-error>` fuera de su `<mat-form-field>`, deja el campo inválido y comprueba qué pasa: cuántos errores hay en consola, y qué ve el usuario. Devuélvelo dentro.

3. 🟡 Cambia `density: -1` por `0` y por `-3` en el tema, y mide en las tres configuraciones cuántos campos del formulario de clientes caben sin hacer scroll a 900 px de alto. Anota las tres cifras y defiende la elección de la Fase 6 —o discútela— con esos números delante.

4. 🟡 Añade `subscriptSizing="dynamic"` a los dos campos del formulario de clientes, provoca un error de validación y observa el salto del layout. Explica en dos líneas por qué el valor por defecto es el otro.

5. 🟡 Añade un `trackBy` a la tabla de clientes. Después quítalo, pon el foco en una fila, provoca una emisión del estado y anota qué pasa con el foco en cada caso.

6. 🟠 Reproduce el bug de la referencia: muta el array de clientes con un `push` desde el componente y comprueba que la tabla con `OnPush` no se entera. Arréglalo con el reemplazo y verifica que la pantalla heredada de activos se comportaba distinto durante todo el rato.

7. 🟠 Abre el diálogo de confirmación y ciérralo de tres formas: pulsando "Cancelar", pulsando Escape y haciendo clic fuera. Anota qué emite `afterClosed()` en cada caso y explica por qué el filtro compara contra `true` en vez de usar un `if (result)`.

8. 🔴 Te llega un ticket: *"la tabla de plantillas es demasiado alta, no caben las diez filas en la pantalla del supervisor"*. Resuélvelo **tres veces** —con `mat.table-density` sobre una clase, con el `density` global del tema, y con un `::ng-deep`— y escribe medio párrafo por cada una diciendo qué se rompe con esa solución dentro de dos años, cuando alguien actualice Material. Entrega la que elegirías y por qué.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y las pantallas que explica las escriben las Fases 6 a 10, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 06: …`, `fase 10: …`). Las mediciones de los ejercicios 3 y 8 van en el mensaje de un tag anotado (`ej/a01/3`), que es donde una cifra queda fechada y comparable. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
