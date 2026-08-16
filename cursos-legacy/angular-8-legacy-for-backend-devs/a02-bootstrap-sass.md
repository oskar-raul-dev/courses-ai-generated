# 📎 Apéndice A02 — Bootstrap 4 + Sass

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **3h**
> Usado por: Fases 0, 1, 4, 5, 6, 8, 10 y 13 · Versión cubierta: `bootstrap` **4.6.2** compilado con `node-sass`
> Estado: Base

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve un problema muy específico: **que Bootstrap y Material convivan sin pelearse por la cascada**, y que cuando se peleen tú sepas en treinta segundos quién ganó y desde qué archivo.

**Qué queda fuera:** la teoría de la cascada —especificidad, origen, orden— que ya explica la **Fase 0 §4** con el botón de Material deformándose en vivo. Acá no se reexplica: se enlaza y se pasa directo a la mecánica de diagnóstico. Tampoco entra el rediseño visual del proyecto: este apéndice te dice cómo funciona lo que hay, no cómo debería verse. Ni los componentes de Material en sí, que son el **Apéndice A01** completo.

---

## Índice

- [1. Qué versión estás mirando](#1-qué-versión-estás-mirando)
- [2. Qué pedazo de Bootstrap usa este proyecto (y qué no)](#2-qué-pedazo-de-bootstrap-usa-este-proyecto-y-qué-no)
- [3. El grid de Bootstrap con componentes de Material](#3-el-grid-de-bootstrap-con-componentes-de-material)
- [4. Quién gana la cascada](#4-quién-gana-la-cascada)
- [5. La paleta compartida](#5-la-paleta-compartida)
- [6. Compilación Sass con node-sass](#6-compilación-sass-con-node-sass)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Qué versión estás mirando

Dos comprobaciones antes de copiar nada de internet:

```bash
# Bootstrap tiene que responder 4.6.2. Si responde 5.x, lo que estás leyendo
# en getbootstrap.com no aplica y la mitad de las clases del proyecto ya no
# existen en la versión que tienes instalada.
npm ls bootstrap

# El compilador de Sass. Este proyecto usa node-sass, no dart-sass.
npm ls node-sass
```

> ⚠️ **`getbootstrap.com` te manda a la 5 por defecto, y la 5 rompió casi todo lo que usa este proyecto.** Las utilidades de margen y padding cambiaron de nombre (`ml-3` → `ms-3`, `mr-3` → `me-3`), `.badge-danger` desapareció en favor de `.text-bg-danger`, `.form-row` ya no existe y jQuery dejó de ser dependencia. La URL correcta lleva la versión adentro: **`https://getbootstrap.com/docs/4.6/`**. Métela en marcadores hoy; te va a ahorrar media hora de "esto no funciona y no entiendo por qué".

### 1.1 node-sass, la versión de Node y el error que parece de otra cosa

`node-sass` es un envoltorio sobre LibSass compilado en C++, y su binario está atado a la versión de Node — al *module version*, no al número que ves en `node --version`. Esto importa porque la Fase 0 fija `.nvmrc` en `14.21.3`, y **la línea de node-sass que arrastraba el CLI 8 originalmente no soporta Node 14**. El síntoma:

```
Node Sass does not yet support your current environment:
Windows 64-bit with Unsupported runtime (83)
```

Ese `83` es el *module version* de Node 14. El mensaje habla de "entorno no soportado" y no menciona ni Angular ni el archivo `.scss` que intentabas compilar, así que la primera reacción de todo el mundo es buscar el problema en el Sass. No está ahí: está en el par node-sass ↔ Node.

Fix mínimo: instalar la versión de node-sass que sí soporta tu Node —para Node 14 es la línea `4.14.x`— y borrar `node_modules` antes, porque el binario viejo se queda cacheado.

```bash
rm -rf node_modules
npm install node-sass@4.14.1 --save-dev
npm ci
```

> 🧭 **El par de LabCore es `node-sass` 4.14.1 sobre Node 14.21.3**, y es el que instalas. Lo que no conviene es memorizar la relación: el emparejamiento node-sass ↔ Node es una tabla que se consulta, vive en el README del repositorio de node-sass y es la referencia de §📚. Con Node 12.22.12 —la otra línea válida del curso en Windows y Linux— la 4.12.x también sirve, y saber **dónde** se mira eso vale más que saberse el número.

> 📝 **Nota de época.** En 2019 `node-sass` era el default y `dart-sass` la alternativa nueva. Hoy es al revés: node-sass está archivado desde 2020 y el CLI moderno usa dart-sass sin preguntar. La consecuencia práctica para ti son dos: (1) cualquier ejemplo de Sass publicado después de 2021 usa `@use` y módulos, que **en node-sass 4 no compilan** —solo existe `@import`—, y (2) node-sass no compila en arm64 sin pelearse, que es la mitad del **Apéndice A12 §3**, donde están las tres salidas ordenadas —Rosetta con el Node fijado, el contenedor, y el cambio a dart-sass declarado como **experimento sin verificar** sobre el CLI 8—. Si trabajas en una Mac con Apple Silicon, ese apéndice es tu primera parada y no este.

---

## 2. Qué pedazo de Bootstrap usa este proyecto (y qué no)

Bootstrap es enorme y este proyecto usa una esquina. Saber cuál es la esquina te ahorra buscar en la documentación cosas que en tu pantalla nunca van a aparecer.

**Lo que sí usa, y dónde:**

- **El grid** — `container`, `container-fluid`, `row`, `col-md-*`. El `container-fluid p-3` del shell viene de la **Fase 1 §5.4**; los `col-md-6` de los formularios, de las **Fases 0 y 5**.
- **Utilidades de espaciado, display, flex, texto y tamaño** — `mt-*`, `mb-*`, `my-*`, `p-*`, `d-flex`, `justify-content-between`, `align-items-center`, `text-muted`, `text-center`, `w-100`. Son las más usadas de todo el proyecto: `w-100` sobre `mat-form-field` aparece en once plantillas.
- **`.alert`** — el bloque de error de pantalla completa con botón de reintento, el patrón que fijó la **Fase 4** y que copian las Fases 1, 2 y 5.
- **`.badge`** — las etiquetas de estado de resultado de la **Fase 8**, con clases propias encima. Ver §5.2, que es donde se definen.

**Lo que no usa, y por eso no está en este apéndice:** los componentes de Bootstrap que Material ya cubre —`.btn`, `.form-control`, `.form-group`, `.input-group`, `.card`, `.table`, `.navbar`, `.nav`, `.list-group`, `.dropdown`—. Si aparece uno en una pantalla que heredes, es un caso aislado y la documentación 4.6 es el sitio, no este documento. Y si estás por escribir uno nuevo: no. Un formulario de este sistema se hace con `mat-form-field`, punto; mezclar las dos familias de controles en la misma pantalla es la única forma de hacer que la fricción de estilos que ya tienes se vuelva un problema de verdad.

### 2.1 El JavaScript de Bootstrap no está en el proyecto

Esto es lo primero que sorprende y conviene tenerlo claro antes de perder una tarde. La Fase 0 instaló el paquete y **solo importó su Sass**:

```bash
npm install bootstrap@4.6.2 --save
```

No hay jQuery, no hay Popper, y el arreglo `scripts` de `angular.json` está vacío. Consecuencia directa: **todo componente de Bootstrap que necesite JavaScript simplemente no funciona.** Modales, dropdowns, collapse, carousel, tooltips y popovers están en el CSS —las clases existen y algo se ve— pero nada responde al clic. No hay error en consola: no hay nada escuchando.

No es un olvido, es la decisión correcta: los diálogos de este sistema son `MatDialog` (**A01 §7**) y los avisos son `MatSnackBar` (**A01 §8**). Añadir jQuery a un Angular 8 para tener un modal que ya tienes es duplicar la superficie de mantenimiento a cambio de nada.

> 💡 Diagnóstico en cinco segundos cuando alguien te diga "el modal de Bootstrap no abre": abre la consola y escribe `window.jQuery`. Si responde `undefined`, ya terminaste de investigar.

---

## 3. El grid de Bootstrap con componentes de Material

El patrón del proyecto es siempre el mismo: **layout de Bootstrap por fuera, componentes de Material por dentro**. Así se ve en la Fase 5 y así lo vas a encontrar en centenares de plantillas.

```html
<!-- Estructura canonica del proyecto: container > row > col, y dentro del col
     lo que sea de Material. El container ya trae 15px de padding lateral y el
     row los compensa con margenes negativos; por eso no se saltan niveles. -->
<div class="container mt-4">
  <div class="row">
    <div class="col-md-6">

      <!-- w-100 no es decoracion: sin ella el mat-form-field NO ocupa el ancho
           de la columna. Material le da un ancho propio, no del 100%, y el
           campo queda corto dentro de una columna ancha. Es la clase de
           Bootstrap mas usada de todo el proyecto por esta unica razon. -->
      <mat-form-field class="w-100">
        <mat-label>{{ 'patients.form.documentId' | translate }}</mat-label>
        <input matInput formControlName="documentId">
      </mat-form-field>

    </div>

    <div class="col-md-6 d-flex align-items-center justify-content-between">
      <button mat-raised-button color="primary">
        {{ 'common.actions.save' | translate }}
      </button>
    </div>
  </div>
</div>
```

### 3.1 Las tres formas de romperlo

**Un `container` dentro de otro `container`.** Cada uno aporta 15px de padding lateral, así que el contenido queda 30px adentro y desalineado respecto al resto de la pantalla. Pasa con frecuencia porque el shell de la Fase 1 ya monta un `container-fluid p-3` alrededor del `<router-outlet>`: **cualquier vista que el router cargue ya está dentro de un contenedor**, y si además abre el suyo, duplica. Regla del proyecto: las vistas empiezan en `row`, no en `container`, salvo que quieran el ancho acotado a propósito.

**Un `col-*` sin `row` que lo envuelva.** El `row` es el que compensa con `margin-left: -15px; margin-right: -15px` el padding que traen las columnas. Sin él, el padding de la columna no se compensa y el contenido se corre; con anchos grandes aparece **scroll horizontal en toda la página** y el culpable está a tres niveles de distancia del síntoma. Cuando veas una barra de scroll horizontal que no debería existir, busca un `col-` huérfano antes de buscar cualquier otra cosa.

**Un componente de Material dentro de un `col` sin `w-100`.** El campo se ve corto, la columna se ve vacía a la derecha, y el reflejo es agrandar la columna —que no arregla nada, porque el campo sigue con su ancho propio—. El arreglo es la clase, no la columna.

### 3.2 Los breakpoints, y por qué los tienes escritos a mano

La Fase 0 §5.5 redeclara el mapa completo de breakpoints antes del `@import`, con los mismos valores que Bootstrap ya traía:

```scss
$grid-breakpoints: (xs: 0, sm: 576px, md: 768px, lg: 992px, xl: 1200px);
```

Redeclarar con los valores por defecto parece redundante, y lo es — pero es redundancia útil: deja el contrato a la vista en el archivo que vas a abrir, en vez de obligarte a ir a leer `_variables.scss` en `node_modules`. Lo que importa es la consecuencia: **`col-md-6` significa "media fila desde 768px, fila completa por debajo"**, y `d-none d-md-block` significa "invisible por debajo de 768px". Todo el `col-md-*` del proyecto se colapsa a ancho completo en la misma frontera.

Para usar esos mismos breakpoints dentro del `.scss` de un componente hace falta un `@import` extra, y eso es §6.3.

---

## 4. Quién gana la cascada

La teoría —especificidad, origen, orden de aparición— está en la **Fase 0 §4** y no se repite. Lo que sigue es la mecánica aplicada al orden concreto que tiene este proyecto.

### 4.1 El orden está fijado y es este

```
1. node_modules/@angular/material/prebuilt-themes/indigo-pink.css   (angular.json, arreglo "styles")
2. src/styles.scss  →  que en su primera linea hace @import de Bootstrap
```

Material entra **primero**, por el arreglo `styles` de `angular.json`. Bootstrap entra **después**, dentro de `styles.scss`. Con especificidad igual, **gana Bootstrap**: es el que aparece más abajo en el CSS final.

Ese orden no es negociable en este proyecto y no es una preferencia estética: hay centenares de plantillas escritas contra él desde 2019. La Fase 0 tiene un ejercicio (el 10) que consiste en invertirlo para ver qué se rompe — hazlo en una rama y vuelve.

### 4.2 Las utilidades de Bootstrap llevan `!important`, y eso cambia todo

Este es el hecho que más tiempo hace perder y el que menos gente sabe. **En Bootstrap 4, las utilidades de espaciado, display, flex, texto y tamaño están declaradas con `!important`.** `.w-100` no es `width: 100%`, es `width: 100% !important`. `.mt-3` es `margin-top: 1rem !important`.

Las consecuencias son concretas:

- **Ganan siempre a Material**, sin importar la especificidad del selector de Material ni el orden de las hojas. No es que Bootstrap tenga suerte con el orden: es que no hay competencia.
- **No las puedes sobreescribir con una regla normal** en el `.scss` de tu componente. Escribes `.my-thing { margin-top: 0 }`, no pasa nada, y te quedas mirando la pantalla. La única forma de ganarle a un `!important` es otro `!important`, y a partir de ahí ya estás en una guerra de la que nadie sale.
- **El arreglo correcto casi nunca es sobreescribir: es quitar la clase de la plantilla.** Si `mt-3` te estorba, borra el `mt-3`. Suena obvio escrito, y no lo es a las seis de la tarde de un viernes.

Cuando en el panel de estilos de DevTools veas la regla ganadora con `!important` al lado y el archivo `styles.scss` como origen, ya sabes que la discusión terminó.

### 4.3 Los cuatro conflictos reales del proyecto

**Reboot contra los componentes de Material.** Reboot es la normalización global de Bootstrap y no le pregunta a nadie: redefine `box-sizing` en todo el documento, `line-height` y `margin` del `body`, `margin-top: 0` en todos los encabezados y el aspecto de los controles nativos. Aplica a **todo el documento**, no solo a lo que marcas con clases de Bootstrap, así que alcanza a los componentes de Material sin que aparezca ni una clase de Bootstrap en tu plantilla. Es el choque que la Fase 0 §5.5 pone en vivo con el botón que cambia de altura.

**Reboot contra la tipografía de Material.** Los dos quieren decidir la fuente del `body`: Reboot pone la pila de fuentes del sistema, y la clase `mat-typography` del `<body>` —que puso el CLI al instalar Material, ver **A01 §2**— pone Roboto. Gana `mat-typography` porque una clase tiene más especificidad que un selector de etiqueta, y gana **independientemente del orden**. Ese es el caso donde el orden no explica el resultado, y por eso conviene tenerlo visto: si intentas razonarlo solo con "Bootstrap va después", te da la respuesta equivocada.

**Los estilos encapsulados de tu componente contra el interior de Material.** El `.scss` de un componente no alcanza el interior de un componente de Material: Angular le añade un atributo de encapsulación a tus selectores y el DOM interno de `mat-form-field` no lo lleva. Para entrar hay que usar `::ng-deep`:

```scss
// src/app/patients/patient-form/patient-form.component.scss
// ::ng-deep atraviesa la encapsulación de la vista y llega al DOM interno de
// Material. Va SIEMPRE anclado a una clase propia del componente: sin el
// :host o sin una clase que lo acote, la regla se vuelve global y pisa todos
// los formularios de la aplicación, incluidos los que no estas mirando.
:host ::ng-deep .mat-form-field-infix {
  padding-bottom: 4px;
}
```

> 📝 **Nota de época.** `::ng-deep` ya estaba marcado como deprecado en Angular 8 y sigue deprecado hoy, sin reemplazo y sin fecha de retirada. Es el caso raro de una API que se declara muerta y se queda una década porque no hay alternativa. Úsala sin culpa; acótala siempre.

**El contenedor de overlay, que no está dentro de tu aplicación.** Los diálogos y los snackbars de Material se montan en `.cdk-overlay-container`, colgado directo del `<body>` y fuera del árbol de tu componente (**A01 §2.2**). De ahí salen dos hechos con signo opuesto: los estilos **encapsulados** de tu componente **no llegan** —por eso `MatDialog` acepta `panelClass` y por eso `MatSnackBar` también—, mientras que Bootstrap, al ser global, **sí llega** y su Reboot alcanza el contenido del diálogo igual que al resto de la página. Un diálogo que se ve raro y un formulario que se ve raro tienen la misma causa, aunque el diálogo parezca un mundo aparte.

---

## 5. La paleta compartida

Acá hay que empezar por la mala noticia, porque cambia lo que puedes hacer y lo que no.

**Este proyecto usa el tema `indigo-pink` prebuilt de Material** (**Fase 0 §5.4**, **A01 §2**), que es un archivo **CSS ya compilado** dentro de `node_modules`. No es Sass, no tiene variables y no se le puede pasar nada. Bootstrap, en cambio, **sí** se compila desde Sass y sus colores son variables que puedes redefinir.

O sea: no hay una paleta compartida. Hay **dos paletas** y una sola de ellas es configurable. La única forma de que se parezcan es que la que sí puedes tocar copie a mano los valores de la que no.

Los valores del tema `indigo-pink`, que son las paletas por defecto de Material:

| Rol en Material | Paleta y tono | Hex |
|---|---|---|
| `primary` | Indigo 500 | `#3f51b5` |
| `accent` | Pink A200 | `#ff4081` |
| `warn` | Red 500 | `#f44336` |

### 5.1 Sincronizar `$theme-colors` con esos valores

En `src/styles.scss`, **antes** del `@import` de Bootstrap (el porqué del "antes" está en §6.2):

```scss
// Los colores de Bootstrap alineados a mano con el tema indigo-pink de
// Material. Los hex vienen de las paletas por defecto de Material, no de un
// diseno: si alguien cambia el tema prebuilt en angular.json, estos tres
// valores quedan mintiendo y nadie recibe un aviso. Esa es la deuda de 5.3.
$primary: #3f51b5;   // Indigo 500,  = primary de Material
$secondary: #ff4081; // Pink A200,   = accent de Material
$danger: #f44336;    // Red 500,     = warn de Material

@import "~bootstrap/scss/bootstrap";
```

Con eso, un `.alert-danger` de la Fase 4 y un `mat-error` de la Fase 5 hablan del mismo rojo, que es todo lo que se le pide a esto.

> 💡 Para **ver** el efecto antes de discutirlo con nadie: cambia `$primary` a `#009688` (Teal 500), guarda, y mira cómo un `.alert-primary` cambia mientras un `mat-raised-button color="primary"` sigue exactamente igual. Es el ejercicio 11 de la Fase 0 y es la demostración de una línea de que las dos paletas son independientes.

### 5.2 Las tres clases de la Fase 8 que faltaban

La Fase 8 pinta las etiquetas de estado de un resultado con `badge badge-critical`, `badge badge-out` y `badge badge-norange`. Esas tres clases **no están definidas en ninguna fase** del curso, y este es su sitio.

La forma barata sería escribir tres reglas CSS a mano. La forma que Bootstrap ya te regala es añadir las tres claves al mapa `$theme-colors`, porque los `@each` de Bootstrap generan las variantes de cada componente recorriendo ese mapa:

```scss
// src/styles.scss — antes del @import de Bootstrap.
// $theme-colors se declara en Bootstrap con !default y además hace map-merge
// sobre si mismo, así que lo que declares acá se AGREGA a las claves por
// defecto en vez de reemplazarlas: primary, danger y compania siguen ahí.
$theme-colors: (
  // Rojo del tema de Material: un valor crítico es lo mismo que un error.
  "critical": #f44336,
  // Ámbar 700: fuera de rango pero no crítico. No hay equivalente en la
  // paleta de Material, así que este es el único color propio del proyecto.
  "out": #ffa000,
  // Gris 600: no hay rango de referencia vigente para este examen. Es
  // ausencia de información, no un veredicto, y el color lo tiene que decir.
  "norange": #757575
);

@import "~bootstrap/scss/bootstrap";
```

Eso genera `.badge-critical`, `.badge-out` y `.badge-norange` con el contraste de texto ya calculado por Bootstrap, y las plantillas de la Fase 8 empiezan a verse como se pensaron.

> ⚠️ **El costo de hacerlo así, que hay que saberlo antes de decidir:** el mapa alimenta a **todos** los componentes que iteran sobre él, no solo a `.badge`. Añadir tres claves genera también `.alert-critical`, `.btn-critical`, `.text-critical`, `.bg-critical`, `.border-critical`, `.list-group-item-critical` y sus equivalentes para las otras dos — unas dos docenas de clases que nadie va a usar, sumadas al CSS final. Con tres claves el peso es despreciable; con veinte, ya no. Si solo quieres las tres `badge`, tres reglas a mano son más honestas.

### 5.3 💸 La deuda de tener dos paletas cosidas a mano

> 💸 **Deuda técnica intencional: la paleta de Material y la de Bootstrap se sincronizan copiando hex.**
>
> **Lo correcto hoy** sería una sola fuente de verdad: un tema propio de Material construido con Sass (`mat-palette`, `mat-light-theme`) que leyera sus colores de las mismas variables que alimentan a `$theme-colors`. Un color, un lugar, y `ng serve` propagándolo a los dos sistemas. Es perfectamente posible en Material 8 — la mecánica está descrita en la guía de theming de la 8.2.3 que enlaza **A01 §📚**.
>
> **En Track A no se paga.** El proyecto usa un tema prebuilt desde 2019 y pasar a un tema propio significa recompilar los estilos de todos los componentes de Material del sistema y revisar cada pantalla, porque un tema construido a mano nunca sale idéntico al prebuilt al primer intento. Es un proyecto de días, con riesgo visual en pantallas que nadie está mirando, y a cambio de una comodidad que se disfruta el día que alguien cambia un color — o sea, casi nunca.
>
> **Lo que sí te llevas es el reflejo:** cuando cambies un color y solo cambie la mitad de la pantalla, no busques un bug de CSS. Busca la otra paleta.

---

## 6. Compilación Sass con node-sass

### 6.1 La cadena completa, de arriba abajo

```
angular.json  →  arreglo "styles"
                   ├── node_modules/@angular/material/prebuilt-themes/indigo-pink.css
                   └── src/styles.scss
                         ├── (variables del proyecto: $primary, $theme-colors, $grid-breakpoints)
                         ├── @import "~bootstrap/scss/bootstrap"
                         └── (reglas globales propias)

*.component.scss  →  compilado aparte, encapsulado por componente,
                     SIN acceso a nada de styles.scss
```

Esa última línea es la que sorprende y §6.3 la desarrolla. El `~` de `~bootstrap/scss/bootstrap` es una convención del cargador de Sass del CLI 8: significa "resuelve desde `node_modules`". No es sintaxis de Sass y no funciona fuera de una compilación de Webpack.

### 6.2 Por qué las variables van antes del `@import`, y no después

Todas las variables de Bootstrap están declaradas con la bandera `!default`:

```scss
// dentro de node_modules/bootstrap/scss/_variables.scss
$primary: $blue !default;
```

`!default` significa **"toma este valor solo si nadie lo definió antes"**. De ahí sale la regla completa:

- Defines `$primary` **antes** del `@import` → cuando Bootstrap llega a su `!default`, la variable ya tiene valor y la respeta. Todo el CSS que genera sale con tu color. ✅
- Defines `$primary` **después** del `@import` → Bootstrap ya generó las mil reglas de su CSS con el valor por defecto. Tu asignación cambia la variable y **no cambia absolutamente nada**, porque nadie la vuelve a leer. ❌

El segundo caso es la advertencia obligatoria de este apéndice y merece decirse sin rodeos: **tocar una variable de Sass sin que se recompile lo que la usa no cambia nada, y no te avisa.** No hay error, no hay warning, no hay nada. La pantalla sigue igual y tú te quedas convencido de que el problema es la caché del navegador.

Las tres versiones del mismo síntoma, en orden de frecuencia:

1. **La asignación quedó después del `@import`.** Lo de arriba. Mueve la línea y ya.
2. **Editaste un archivo que nadie importa.** Confirma que el archivo que tocaste está en la cadena de `@import` de `styles.scss`. Un `_theme-vars.scss` creado con la mejor intención y nunca importado es CSS que no existe.
3. **Editaste `angular.json`.** El arreglo `styles` se lee **al arrancar**. `ng serve` recompila `.scss` al guardar, pero no se relee su propia configuración: hay que reiniciar el servidor. Es el ejercicio 8 de la Fase 0 y el único de los tres casos donde el problema no está en tu Sass.

> 💡 Antes de dudar de la caché, comprueba que el CSS compilado cambió. Con `ng serve` corriendo, abre `http://localhost:4200/styles.js` y busca tu hex ahí. Si tu color no está en el bundle, el navegador no tiene nada que ver: no se compiló.

### 6.3 Usar variables y mixins de Bootstrap dentro de un componente

Un `.scss` de componente se compila **por separado**. No ve `$primary`, no ve `$grid-breakpoints`, no ve nada de `styles.scss`. Escribir `color: $primary` dentro de `patient-form.component.scss` falla la compilación con `Undefined variable`, y el error confunde porque la variable *existe* — en otro archivo, que no es el tuyo.

Para tenerlas hay que importar las tres piezas sin CSS de Bootstrap. Solo esas tres, y en este orden:

```scss
// src/app/patients/patient-form/patient-form.component.scss
// functions, variables y mixins NO generan ni una regla de CSS: solo declaran.
// Por eso se pueden importar en cada componente que los necesite sin engordar
// el bundle. Importar "~bootstrap/scss/bootstrap" acá sería el error grave:
// duplicaria Bootstrap ENTERO dentro de este componente.
@import "~bootstrap/scss/functions";
@import "~bootstrap/scss/variables";
@import "~bootstrap/scss/mixins";

.patient-form-footer {
  border-top: 1px solid $gray-300;

  // media-breakpoint-up usa el mismo mapa $grid-breakpoints que el grid, así
  // que este 768px y el col-md-6 de la plantilla no se pueden desincronizar.
  // Un @media (min-width: 768px) escrito a mano si se desincroniza.
  @include media-breakpoint-up(md) {
    display: flex;
    justify-content: flex-end;
  }
}
```

> ⚠️ **El orden de esos tres `@import` no es opcional.** `_variables.scss` usa funciones que define `_functions.scss`, así que invertir los dos primeros falla con un error sobre una función que no existe. Y las variables del proyecto que redefiniste en `styles.scss` **no llegan hasta acá**: dentro del componente, `$primary` vale el azul por defecto de Bootstrap, no tu indigo. Si necesitas el color del tema en un componente, el camino corto y honesto es escribir el hex con un comentario que diga de dónde salió.

---

## 🧭 Cuándo usar qué

**El reparto, en una frase:** *Bootstrap pone el layout, Material pone los
componentes.* Casi todo lo demás sale de ahí.

**Maquetar una vista nueva:**

| Situación | Qué usas |
|---|---|
| El caso normal | `row` > `col-md-*`. El shell ya abrió el contenedor por ti |
| Ancho acotado a propósito | `container` explícito, sabiendo que vas dentro de otro (§3.1) |
| Espaciado, alineación, ocultar por tamaño | Utilidades: `mt-3`, `d-flex`, `d-none d-md-block` |
| Que un `mat-form-field` llene su columna | `class="w-100"`. Material no lo hace solo, y es la clase más usada del proyecto |
| Breakpoints dentro del `.scss` de un componente | `@import` de functions/variables/mixins, y `media-breakpoint-up` (§6.3) |

**Poner un componente.** La respuesta es Material (**A01**) salvo en tres casos,
que son los únicos donde este proyecto usa CSS de Bootstrap:

| Situación | Qué usas |
|---|---|
| Error que ocupa la pantalla, con reintento | `.alert.alert-danger`, el patrón de la **Fase 4** |
| Etiqueta de estado dentro de una fila | `.badge` con una clave de `$theme-colors` (§5.2) |
| Aviso efímero de algo que ya pasó | Nada de Bootstrap: `MatSnackBar` (**A01 §8**) |

**Cambiar un color.** Aquí es donde duele tener dos paletas (§5.3):

| Alcance | Dónde se toca |
|---|---|
| Una sola pantalla | Una regla local en el `.scss` del componente. No toques ninguna paleta por un caso |
| Toda la aplicación | `$theme-colors` en `styles.scss` **y** a mano el hex de Material. Son dos sitios y hay que tocar los dos (§5.1) |

**Cuando el CSS no te obedece.** Las tres situaciones y su salida:

| Situación | Qué haces |
|---|---|
| Necesitas entrar al DOM interno de un componente de Material | `:host ::ng-deep` **acotado**. Sin ancla es una regla global (§4.3) |
| Quieres estilar un diálogo o un snackbar | `panelClass`. Viven fuera de tu componente y la encapsulación no llega |
| Una utilidad de Bootstrap te estorba | **Quita la clase de la plantilla.** Lleva `!important` y no la vas a ganar escribiendo más CSS (§4.2) |

---

## ⚠️ Advertencias

**Tocar una variable de Sass sin que se recompile lo que la usa no cambia nada, y en silencio.** Es la advertencia central de este apéndice. Sin error, sin warning: la pantalla sigue igual. Antes de culpar a la caché del navegador, verifica las tres causas de §6.2 en ese orden —asignación después del `@import`, archivo que nadie importa, `angular.json` sin reiniciar— y confirma que tu hex está en el bundle compilado.

**La documentación de Bootstrap te lleva a la 5 por defecto.** `getbootstrap.com` publica la versión actual, donde las utilidades cambiaron de nombre, `.badge-*` desapareció y jQuery dejó de ser dependencia. La URL con la versión adentro, `https://getbootstrap.com/docs/4.6/`, es la única que te sirve.

**Las utilidades de Bootstrap llevan `!important` y no se pueden sobreescribir.** Ganan a cualquier cosa que escribas en un componente, y el arreglo es quitar la clase de la plantilla, no pelearla con más CSS.

**No sumes componentes de Bootstrap a un sistema que ya resuelve eso con Material.** Un `.btn` junto a un `mat-raised-button` en la misma pantalla no es un detalle estético: es superficie nueva que alguien va a mantener, en un sistema que lleva años con las mismas formas. Y si el componente necesita JavaScript, directamente no funciona (§2.1).

**El orden de la cascada es un contrato del proyecto, no una preferencia.** Material primero por `angular.json`, Bootstrap después dentro de `styles.scss`. Centenares de plantillas dependen de ese orden exacto. Invertirlo para probar es un ejercicio; invertirlo en un commit es romper pantallas que no estás mirando.

**Y lo de siempre con el CSS de un sistema de años: si estás por cambiar algo global, avisa antes.** Un color de `$theme-colors`, el orden de las hojas o una regla en `styles.scss` afectan pantallas que nadie tiene abiertas y que nadie va a revisar. No es una conversación larga, pero es una conversación.

---

## 📚 Referencias

- https://getbootstrap.com/docs/4.6/getting-started/theming/ — la guía de theming de la 4.6: `!default`, cómo funciona `$theme-colors` y qué genera cada mapa. Es el documento de §5 y §6.2.
- https://getbootstrap.com/docs/4.6/layout/grid/ — el grid completo: `container`, `row`, `col-*`, gutters y breakpoints.
- https://getbootstrap.com/docs/4.6/utilities/spacing/ — las utilidades de espaciado, con el `!important` declarado en la propia tabla de la página.
- https://getbootstrap.com/docs/4.6/content/reboot/ — la lista exacta de lo que Reboot redefine. Es el inventario de lo que te va a morder, y es la misma referencia de la **Fase 0 §8**.
- https://github.com/twbs/bootstrap/tree/v4.6.2/scss — el Sass tal como está en tu `node_modules`. Cuando dudes de qué genera un mapa, `_badge.scss` y `_alert.scss` se leen en dos minutos y responden mejor que la documentación.
- https://github.com/sass/node-sass#node-version-support-policy — la tabla node-sass ↔ versión de Node. Es la referencia de §1.1 y la que resuelve el error de "Unsupported runtime". ⚠️ El repositorio está archivado desde 2020: la tabla sigue siendo válida para lo que usas, pero no esperes actualizaciones.
- https://sass-lang.com/documentation/at-rules/import — el `@import` y el `!default` de Sass. ⚠️ La página documenta el sistema moderno y **declara `@import` deprecado en favor de `@use`**: eso aplica a dart-sass, no a tu node-sass 4, donde `@use` no existe.
- https://v8.angular.io/guide/workspace-config#styles-and-scripts-configuration — el arreglo `styles` de `angular.json`, que es quien fija el orden de §4.1.
- https://v8.angular.io/guide/component-styles#deprecated-deep--and-ng-deep — `::ng-deep` en la versión que usas, ya con su nota de deprecación.
- https://developer.mozilla.org/es/docs/Web/CSS/Specificity — especificidad, para el caso de §4.3 donde el orden no explica el resultado.

> ⚠️ Los enlaces y sus contenidos pueden haber cambiado o desaparecido; verifícalos. Los de `github.com/twbs/bootstrap/tree/v4.6.2` son los más estables porque apuntan a un tag inmutable, y además son exactamente el código que tienes instalado.

---

## 🧪 Ejercicios (8)

Cortos y de consulta. Con la aplicación de la Fase 5 corriendo.

1. Corre `npm ls bootstrap node-sass` y anota las dos versiones. Después abre el README de node-sass y confirma si tu par node-sass ↔ Node es uno soportado. Si no lo es, explica en una línea por qué el proyecto compila igual (o por qué no).
2. Localiza el arreglo `styles` en `angular.json` y escribe, en dos líneas, el orden exacto en que se cargan las hojas globales y quién gana los empates de especificidad. Es el contrato de §4.1.
3. Añade `mt-5` al `<div class="container">` del formulario de paciente e intenta anularlo desde el `.scss` del componente con `margin-top: 0`. Anota qué pasa, y después mira la regla en DevTools y explica por qué en una línea.
4. Quita el `w-100` de un `mat-form-field` dentro de un `col-md-6`, recarga y describe qué cambió. Después intenta arreglarlo agrandando la columna a `col-md-12` y explica por qué eso no lo arregla.
5. Provoca el scroll horizontal de §3.1: pon un `col-md-6` sin `row` que lo envuelva. Confirma la barra de scroll, localiza en DevTools el elemento que se sale, y anota qué propiedad de qué clase lo causa.
6. Cambia `$primary` a `#009688` **después** del `@import` de Bootstrap en `styles.scss`, guarda y recarga. Anota qué cambió (nada). Muévelo antes del `@import` y anota qué cambió ahora. Explica el `!default` en una línea.
7. Define las tres clases de la Fase 8 (`badge-critical`, `badge-out`, `badge-norange`) con el mapa de §5.2, y confirma en la pantalla de resultados que las etiquetas se pintan. Después busca en el CSS compilado cuántas clases más se generaron sin que las pidieras.
8. **Diagnóstico.** Te reportan: *"cambié el color en `styles.scss` y no se ve"*. Sin ver la máquina, escribe las tres preguntas que harías en orden de probabilidad, con la comprobación concreta que pedirías para cada una. Las tres están en §6.2.


> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida: el código que
> explica lo escriben las fases, y un tag que no apunta a un cambio no marca
> nada. Lo que salga de leerlo se commitea con el prefijo de la fase desde la
> que llegaste (`f00: …`), para que su `git log --oneline --grep '^f00'`
> siga completo. Y si un ejercicio produjo una medición, el número va en el
> mensaje de un tag anotado (`ej/a02/3`), que es donde no se pierde. La
> convención completa —tags de fase, de ejercicio y de incidente— está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **Tema propio de Material con una sola fuente de verdad de color** — es la deuda 💸 de §5.3 escrita al revés: un tema construido con `mat-palette` leyendo las mismas variables que `$theme-colors`. Destino corregido al escribir A10: **decisión de proyecto propia**, si alguna vez se rediseña la interfaz. No se cuelga de una migración de versión: el **Apéndice A10 §⚖️** desaconseja explícitamente mezclar un cambio visual global con un salto de framework.
- **Las clases `badge-critical` / `badge-out` / `badge-norange` de la Fase 8 no estaban definidas en ningún documento.** Quedan definidas en §5.2 de este apéndice. Destino: una línea en la **Fase 8 §5** que enlace acá, para que quien lea la fase sola no se quede con clases fantasma.
- 🪦 **Resuelto en la revisión del curso.** Este pendiente denunciaba que las Fases 1, 4 y 8 usaban Bootstrap —`container-fluid`, `.alert`, `.badge`— sin declarar A02 en su encabezado. Los encabezados quedaron alineados en las dos direcciones: las fases que usan el apéndice lo declaran, y el «Usado por» de acá las nombra a todas.
- **`bootstrap.js`, jQuery y Popper ausentes del proyecto** (§2.1). Es una decisión correcta y no documentada en ninguna fase; alguien va a intentar usar un modal de Bootstrap. Destino: **incidente** 🟢 de configuración —"el modal no abre y no hay ningún error"—, que se resuelve en dos minutos con `window.jQuery` y enseña a leer una ausencia.
- **Aislar Reboot en un contenedor con ámbito propio** — la deuda 💸 que declaró la **Fase 0 §5.5** sigue abierta y este apéndice no la paga. Destino: decisión de proyecto; si alguna vez se toca, es un cambio visual global y por lo tanto una conversación de equipo.
