# 🎨 Apéndice A1 — Bootstrap 4 y Sass

> Tutorial React 16 — Rifas y chances · Apéndice de **consulta rápida** · **3 horas**
> Lo usan: Fase 0 en adelante · No es lectura secuencial: saltá al bloque que necesites.

Este apéndice no se lee de corrido. Es la chuleta que abrís cuando estás
tocando una vista y no te acordás si el gutter de la grilla es `no-gutters`
o `g-0` (spoiler: en Bootstrap 4 es `no-gutters`; el `g-0` es de la 5, que
**no** usamos). Cubre **solo** lo que aparece en el código real que vas a
mantener: la grilla, las cards, las tablas, los forms, un puñado de
utilidades y la customización de la paleta con Sass. Nada de tourguide por
todos los componentes de Bootstrap: si algo no está en el código del curso,
no está acá.

Dos anclas que no cambian nunca en este proyecto:

- **Bootstrap 4.6.2.** No 5. Las clases cambian entre 4 y 5 (`ml-*`→`ms-*`,
  `thead-dark`→`table-dark`, el sistema de forms se reescribió). Si copiás
  de la doc de Bootstrap 5, se te va a romper en silencio: la clase
  simplemente no existe y no pasa nada. Consultá **siempre**
  `https://getbootstrap.com/docs/4.6`.
- **Sass vía `sass` (dart-sass), nunca `node-sass`** (decisión D11). El
  porqué está en la Fase 0; acá lo damos por hecho.

---

## 🧭 Índice de salto rápido

- [1. Cómo se conecta Sass con CRA (el pipeline en 30 segundos)](#1-cómo-se-conecta-sass-con-cra)
- [2. Grid: `container`, `row`, `col`](#2-grid)
- [3. Cards](#3-cards)
- [4. Tablas](#4-tablas)
- [5. Forms controlados](#5-forms)
- [6. Utilidades que vas a ver todo el tiempo](#6-utilidades)
- [7. Customización de la paleta con Sass](#7-customización-de-la-paleta-con-sass)
- [🧩 Tabla: cuándo usar qué](#-cuándo-usar-qué)
- [🧪 Ejercicios](#-ejercicios-8)
- [📚 Referencias](#-referencias)

---

## 1. Cómo se conecta Sass con CRA

No hay magia ni webpack config que tocar. CRA 4, si encuentra el paquete
`sass` instalado, compila cualquier `.scss` que importes sin más. El
germen del pipeline ya lo montaste en la Fase 0; acá está el resumen para
que no vuelvas a leer la fase entera.

El orden de `@import` en tu hoja raíz **importa** (literal): Sass resuelve
variables de arriba hacia abajo, así que tus tokens y tus overrides van
**antes** de Bootstrap, y tus estilos propios **después**.

```scss
// src/index.scss
// 1) Tus tokens y overrides de variables de Bootstrap PRIMERO,
//    para que Bootstrap los lea al compilar sus propios estilos.
@import "./styles/tokens";

// 2) Bootstrap completo (o solo los partials que uses; ver §7).
@import "~bootstrap/scss/bootstrap";

// 3) Tus estilos propios AL FINAL: acá ya podés usar los tokens
//    y pisar lo que haga falta de Bootstrap.
.raffle-card {
  border-top: 4px solid $raffle-primary;
  margin-bottom: $raffle-spacing * 2;
}
```

El `~` en `~bootstrap/scss/bootstrap` le dice al resolver de CRA "esto está
en `node_modules`, no es una ruta relativa". Es el error más común de
todos: quitar el `~` y ver el build romperse con un `Can't resolve
'bootstrap/scss/bootstrap'` que no aclara que le falta el tilde.

**Error común.** Definir un token *después* de importar Bootstrap y esperar
que Bootstrap lo use. No lo va a usar: Bootstrap ya compiló sus estilos con
el valor por defecto para cuando tu línea corre. Si querés que Bootstrap
lea tu valor (por ejemplo, tu `$primary`), tiene que estar **antes** del
`@import "~bootstrap/scss/bootstrap"`. Ver §7.

---

## 2. Grid

El sistema de 12 columnas. Tres piezas: un `.container` (o
`.container-fluid` para ancho completo), filas `.row`, y columnas `.col`.

```jsx
<div className="container py-4">
  <div className="row">
    {/* col-md-8: 8/12 en pantallas ≥768px, 12/12 debajo */}
    <div className="col-md-8">Listado de rifas</div>
    <div className="col-md-4">Panel lateral</div>
  </div>
</div>
```

Breakpoints de Bootstrap 4 (memorizalos, se usan en todos lados):
`sm` ≥576px, `md` ≥768px, `lg` ≥992px, `xl` ≥1200px. Una `.col` sin
sufijo reparte el espacio en partes iguales automáticamente.

En los forms del curso vas a ver `form-row` con `col-md-6` / `col-md-4`
para poner campos lado a lado (ver §5) — es la grilla aplicada dentro de
un formulario.

**Error común.** Poner `.col` sin `.row` que la envuelva, o `.row` sin
`.container`. La grilla usa márgenes negativos: sin el `.row`, tus columnas
se pegan al borde y se comen unos pixeles; sin el `.container` que
compensa, el contenido se sale hacia los lados. Si ves scroll horizontal
fantasma, casi siempre es una `.row` sin contenedor.

> ⚠️ **Gutters en Bootstrap 4, no en 5.** Para quitar el espacio entre
> columnas, en la 4 se usa `no-gutters` sobre la `.row`. El `g-0`, `gx-*`,
> `gy-*` es sintaxis de Bootstrap 5 y acá **no compila a nada**. Es el
> desliz más típico al copiar de un tutorial reciente.

---

## 3. Cards

La `RaffleCard` de la Fase 0 es una card. El patrón base:

```jsx
<div className="card">
  <div className="card-body">
    <h5 className="card-title">Rifa fin de mes</h5>
    <p className="card-text text-muted">Precio por número: $5000</p>
    <button className="btn btn-outline-primary btn-sm">Ver detalle</button>
  </div>
</div>
```

En el curso vas a ver un atajo muy usado: `card card-body` juntas en el
mismo elemento cuando la card es solo un contenedor con padding y no
necesita header/footer. El `RaffleForm` de la Fase 4, por ejemplo, es un
`<form className="card card-body mb-4">` — la card le da el marco y el
padding al formulario de una.

Variantes útiles que aparecen: `card-header` / `card-footer` para franjas
arriba/abajo, y las utilidades de spacing (`p-3`, `mb-4`) para separar
cards entre sí.

**Error común.** Meter el contenido directo en `.card` sin `.card-body`.
La `.card` no trae padding propio: tu texto queda pegado al borde. O ponés
`.card-body`, o usás el atajo `card card-body` en el mismo div.

---

## 4. Tablas

El listado de rifas (Fase 4) es una tabla Bootstrap. Las clases que usa el
código real:

```jsx
<table className="table table-striped table-hover">
  <thead className="thead-dark">
    <tr>
      <th>Nombre</th>
      <th>Estado</th>
      <th className="text-right">Acciones</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Rifa fin de mes</td>
      <td>
        <span className="badge badge-pill badge-secondary">Abierta</span>
      </td>
      <td className="text-right">
        <button className="btn btn-sm btn-outline-primary mr-2">Editar</button>
        <button className="btn btn-sm btn-outline-danger">Eliminar</button>
      </td>
    </tr>
  </tbody>
</table>
```

- `table` es obligatoria: sin ella Bootstrap no estiliza nada.
- `table-striped` alterna el fondo de las filas; `table-hover` las resalta
  al pasar el mouse.
- `thead-dark` pinta el header oscuro. En Bootstrap 5 esto se llama
  `table-dark` sobre el `thead` — otra que cambia entre versiones.
- `text-right` en la última columna alinea los botones de acciones a la
  derecha (patrón que se repite en todo el curso).

**Error común.** Olvidar el `<tbody>` y meter los `<tr>` sueltos bajo la
`<table>`. El navegador te "arregla" el HTML insertando un `tbody`
implícito, así que a veces funciona… hasta que `table-striped` cuenta mal
las filas y raya el header. Ponelo siempre explícito.

---

## 5. Forms

Los formularios del curso son **controlados** (el valor vive en el estado
de React, no en el DOM). Bootstrap 4 aporta las clases; React aporta el
`value` + `onChange`. La estructura canónica que vas a ver en el
`RaffleForm`:

```jsx
<form onSubmit={handleSubmit} className="card card-body mb-4">
  <div className="form-group">
    <label htmlFor="name">Nombre de la rifa</label>
    <input
      id="name"
      className="form-control"
      value={name}
      onChange={(e) => setName(e.target.value)}
    />
  </div>

  {/* form-row + col-md-* pone dos campos lado a lado */}
  <div className="form-row">
    <div className="form-group col-md-6">
      <label htmlFor="pricePerNumber">Precio por número</label>
      <input
        id="pricePerNumber"
        type="number"
        className="form-control"
        value={pricePerNumber}
        onChange={(e) => setPricePerNumber(e.target.value)}
      />
    </div>
    <div className="form-group col-md-6">
      <label htmlFor="lotteryId">Lotería</label>
      <select
        id="lotteryId"
        className="form-control"
        value={lotteryId}
        onChange={(e) => setLotteryId(e.target.value)}
      >
        <option value="boyaca">Boyacá</option>
        <option value="cundinamarca">Cundinamarca</option>
      </select>
    </div>
  </div>

  <button type="submit" className="btn btn-primary">Guardar</button>
</form>
```

Las clases clave:

- `form-group` agrupa label + input y les da el margen inferior.
- `form-control` es la que estiliza inputs, selects y textareas. Sin ella,
  el input se ve como HTML crudo.
- `form-row` es una `.row` con gutters más chicos, pensada para forms; las
  columnas van con `col-md-*` como en la grilla normal.

> 💡 **`htmlFor`, no `for`.** En JSX el atributo del label es `htmlFor`
> (porque `for` es palabra reservada de JS). Enlaza el label con el input
> por `id`, y de paso hace clickeable el label. Es un olvido clásico que no
> rompe nada visible pero te deja el label muerto.

**Error común.** Poner `className="form-control"` en un `<input
type="checkbox">` o `type="radio"`. Para esos Bootstrap 4 usa
`form-check` + `form-check-input` + `form-check-label`; el `form-control`
los deforma. Los text/number/select van con `form-control`; los
check/radio, con `form-check`.

---

## 6. Utilidades

El 80% del "acomodá esto acá" en el curso se hace con clases utilitarias,
sin escribir CSS. Las que aparecen de verdad en el código:

**Spacing.** El patrón es `{propiedad}{lado}-{escala}`. Propiedad: `m`
(margin) o `p` (padding). Lado: `t` `b` `l` `r` `x` `y` o nada (todos).
Escala: `0` a `5`. Ejemplos que ya viste: `mb-4` (margin-bottom grande),
`mr-2` / `ml-3` (separar botones), `py-4` (padding vertical), `p-3`
(padding en los cuatro lados).

> ⚠️ **`ml-*` / `mr-*`, no `ms-*` / `me-*`.** Bootstrap 4 usa `l`/`r`
> (left/right). La 5 pasó a `s`/`e` (start/end) para soportar RTL. Todo el
> código del curso está en 4: es `mr-2`, no `me-2`.

**Flexbox.** Para alinear sin pelear con CSS: `d-flex` activa el flex,
`justify-content-between` empuja los extremos a los bordes,
`align-items-center` centra vertical. El header de la `RaffleCard` usa
exactamente `d-flex justify-content-between align-items-center` para poner
el título a la izquierda y el badge a la derecha.

**Texto.** `text-muted` (gris tenue, para datos secundarios), `text-right`
/ `text-center` (alineación), `text-truncate` (corta con puntos
suspensivos).

**Colores contextuales.** Los `alert alert-{tipo}`, `badge badge-{tipo}`,
`btn btn-{tipo}` y `btn btn-outline-{tipo}` comparten la misma paleta de
tipos: `primary`, `secondary`, `success`, `danger`, `warning`, `info`,
`light`, `dark`. En el curso el estado de las rifas se mapea a estos: una
rifa `open` va con `badge-success`, una `closed` con `badge-secondary`, un
error de carga con `alert alert-danger`. Ese mapeo dato→color es el que
customizás en §7.

**Error común.** Reinventar con CSS propio lo que ya existe como utilidad
—escribir un `.mt-grande { margin-top: 24px }` cuando `mt-4` ya lo hace—.
En una app de transición eso genera dos sistemas de spacing que se pisan.
Regla: si Bootstrap ya tiene la utilidad, usala; el Sass propio se reserva
para lo que Bootstrap no cubre (§7 y el mini design system de A2).

---

## 7. Customización de la paleta con Sass

Acá está el corazón "de sistema" de este apéndice y la línea que lo separa
del A2. **A1 cubre cómo hacer que la paleta de marca (`$raffle-*`) alimente
las utilidades de Bootstrap** para que `btn-primary`, `badge-success`,
`alert-danger` reflejen tus colores. El design system completo —mixins,
tokens jerárquicos, cómo el equipo estructura todo esto en serio— vive en
el **Apéndice A2**; no lo repetimos.

### 7.1 El truco: pisar variables de Bootstrap *antes* del `@import`

Bootstrap 4 define sus colores en variables Sass (`$primary`, `$success`,
`$danger`, …) y de ahí deriva **todas** las clases contextuales. Si
declarás tu valor **antes** de importar Bootstrap, Bootstrap compila sus
utilidades con tu color. Un `.btn-primary` pasa a usar tu azul sin que
toques ni una clase en el JSX.

```scss
// src/styles/_tokens.scss
// Paleta de marca de Rifas y chances (ya viene de la Fase 0).
$raffle-primary: #0066cc;  // azul de marca
$raffle-success: #28a745;  // "rifa abierta / número disponible"
$raffle-danger:  #dc3545;  // "cerrada / vendido"
$raffle-spacing: 0.5rem;   // unidad base de espaciado

// Mapeamos NUESTROS tokens a las variables que Bootstrap espera.
// Estas líneas van ANTES del @import de Bootstrap en index.scss,
// por eso Bootstrap las lee al construir sus clases.
$primary: $raffle-primary;
$success: $raffle-success;
$danger:  $raffle-danger;
```

Con eso, y el `@import "./styles/tokens"` antes de Bootstrap en tu
`index.scss` (ver §1), cada `btn-primary`, `badge-success` y `alert-danger`
del curso queda pintado con la marca. Cero cambios en los componentes.

### 7.2 `$theme-colors`: agregar colores propios al set contextual

Pisar `$primary` cambia un color existente. Pero a veces querés un color
**nuevo** que genere su propia familia de clases —un `btn-raffle`,
`badge-raffle`—. Para eso Bootstrap 4 expone el mapa `$theme-colors`:
extendelo antes del `@import` y Bootstrap te genera las clases
automáticamente.

```scss
// _tokens.scss — sigue ANTES del @import de Bootstrap.
// map-merge conserva los colores de Bootstrap y suma los nuestros.
$theme-colors: map-merge(
  $theme-colors,
  (
    "raffle":  $raffle-primary,
    "sold":    $raffle-danger,
    "available": $raffle-success,
  )
);
```

Ahora existen `btn-raffle`, `bg-sold`, `text-available`, `badge-available`,
etc., derivadas por Bootstrap con sus estados de hover/focus incluidos. Es
más limpio que escribir esas variantes a mano, y mantiene un solo origen de
verdad para el color.

> 💡 **Por qué antes del `@import` y no después.** Después del import solo
> podés *tapar* estilos ya generados con más CSS (mayor especificidad, más
> peso). Antes del import, en cambio, cambiás el **insumo** con el que
> Bootstrap genera todo, y obtenés estados y variantes gratis y coherentes.
> Tapar después es parchar; customizar antes es configurar. En una app de
> mantenimiento, preferís configurar.

### 7.3 💸 Pago de deuda: importar solo los partials que usás

En la Fase 0 dejamos una deuda marcada: importábamos Bootstrap **completo**
(`@import "~bootstrap/scss/bootstrap"`) para no frenar el setup. Ahora la
pagamos. Bootstrap 4 está partido en módulos Sass; podés importar solo los
que el código usa y achicar el bundle.

```scss
// index.scss — versión selectiva.
@import "./styles/tokens";           // tokens + overrides + $theme-colors

// Obligatorios: functions/variables/mixins alimentan todo lo demás.
@import "~bootstrap/scss/functions";
@import "~bootstrap/scss/variables";
@import "~bootstrap/scss/mixins";

// Solo lo que el curso usa de verdad:
@import "~bootstrap/scss/root";
@import "~bootstrap/scss/reboot";
@import "~bootstrap/scss/grid";       // §2
@import "~bootstrap/scss/card";       // §3
@import "~bootstrap/scss/tables";     // §4
@import "~bootstrap/scss/forms";      // §5
@import "~bootstrap/scss/buttons";
@import "~bootstrap/scss/badge";
@import "~bootstrap/scss/alert";
@import "~bootstrap/scss/utilities";  // §6 (spacing, flex, text…)

// Tus estilos propios al final.
.raffle-card { border-top: 4px solid $raffle-primary; }
```

**Error común.** Importar `grid` o `buttons` **sin** `functions`,
`variables` y `mixins` antes. Esos tres son la base de la que todo lo
demás depende; si faltan, el build revienta con un `Undefined variable` o
`Undefined mixin` que no dice "te olvidaste la base", solo el nombre de la
primera variable que no encontró. Regla: `functions` → `variables` →
`mixins` **siempre primero**, en ese orden, y después lo que quieras.

> 🔥 **Opcional.** Medí el `bundle.css` antes y después de la importación
> selectiva (Network tab, o `ls -la build/static/css`). El ahorro real
> depende de cuánto descartás; documentalo. Es el mismo gesto que el
> ejercicio 13 de la Fase 0 hacía con `bootstrap-grid`.

---

## 🧩 Cuándo usar qué

Referencia de decisión rápida. Todo con clases de Bootstrap **4.6**.

| Querés… | Usás | No confundir con (Bootstrap 5) |
|---|---|---|
| Layout de columnas | `container` + `row` + `col-md-*` | — |
| Quitar espacio entre columnas | `no-gutters` en la `.row` | `g-0` / `gx-*` (es de la 5) |
| Contenedor con marco y padding | `card` + `card-body` | — |
| Listado tabular | `table table-striped table-hover` | — |
| Header de tabla oscuro | `thead-dark` en el `<thead>` | `table-dark` (es de la 5) |
| Input de texto/número/select | `form-group` + `form-control` | — |
| Checkbox / radio | `form-check` + `form-check-input` | `form-control` (los deforma) |
| Dos campos lado a lado en un form | `form-row` + `col-md-6` | — |
| Separar/espaciar elementos | `mb-4`, `mr-2`, `p-3`, `py-4` | `me-2` / `ms-2` (son de la 5) |
| Alinear con flex | `d-flex justify-content-between align-items-center` | — |
| Estado de rifa como color | `badge-success`/`-secondary`/`-danger` | — |
| Cambiar un color de marca global | pisar `$primary` **antes** del `@import` | tapar con CSS después (parche) |
| Agregar un color nuevo con sus clases | `map-merge` sobre `$theme-colors` | escribir cada variante a mano |
| Reducir el bundle | importar partials Sass sueltos | importar `bootstrap` completo |

---

## 🧪 Ejercicios (8)

Cortos, de consulta: comprobás que sabés dónde mirar, no construís features.

**🟢 Básico**

1. Tomá la `RaffleCard` de la Fase 0 y envolvé el título y el badge en un
   `d-flex justify-content-between align-items-center`. Confirmá que el
   badge queda pegado a la derecha sin escribir CSS.
2. Armá una `.row` con tres `.col-md-4` que muestren tres rifas de mentira,
   una al lado de la otra en desktop y apiladas en móvil. Redimensioná la
   ventana para verlo colapsar en el breakpoint `md`.
3. Convertí un listado de rifas en una `<table table-striped table-hover>`
   con `thead-dark`, columnas Nombre / Estado / Acciones, y `text-right` en
   la última.

**🟡 Intermedio**

4. Pisá `$primary` con `$raffle-primary` (#0066cc) en `_tokens.scss`,
   **antes** del `@import` de Bootstrap. Confirmá que todos los
   `btn-primary` del curso cambian de azul sin tocar ningún JSX. Después
   moviste la línea a *después* del import y explicá por qué deja de
   funcionar.
5. Agregá un color `"available"` (verde) al mapa `$theme-colors` con
   `map-merge` y usá la clase generada `badge-available` en el estado
   "disponible" de un número. Verificá que Bootstrap generó también el
   hover.
6. Reescribí un form de dos campos (precio y lotería) usando `form-row` +
   `col-md-6` para ponerlos lado a lado, con `form-group` y `form-control`
   en cada uno. Enlazá cada `label` con su input por `htmlFor`.

**🟠 Difícil**

7. **Diagnóstico:** te paso un `index.scss` donde la línea `$primary:
   $raffle-primary;` está **después** del `@import "~bootstrap/scss/bootstrap"`.
   Los botones salen azul-Bootstrap, no azul-marca. Identificá por qué,
   corregilo con el cambio mínimo, y escribí dos líneas de post-mortem
   sobre por qué el orden de imports en Sass no es cosmético.
8. **Pago de deuda:** partí el `@import "~bootstrap/scss/bootstrap"` completo
   en imports selectivos (§7.3) dejando solo grid, card, tables, forms,
   buttons, badge, alert y utilities (con functions/variables/mixins de
   base). Confirmá que la app se ve idéntica y anotá la diferencia de
   tamaño del CSS. Si algo desaparece visualmente, identificá qué partial
   te faltó.

**🔥 Opcionales**

- 🔥 Reproducí el error de quitar el `~` del import de Bootstrap: documentá
  el mensaje exacto y en qué consola aparece primero (terminal vs
  navegador).
- 🔥 Buscá en el código de una fase posterior (4 en adelante) una clase que
  sea de Bootstrap 5 por error (`ms-*`, `me-*`, `g-*`, `table-dark`). Si no
  hay ninguna, confirmá por qué el curso está consistentemente en 4.6.

---

## 📚 Referencias

**Documentación oficial**

- Bootstrap 4.6 — https://getbootstrap.com/docs/4.6/getting-started/introduction/ — la versión exacta del proyecto. **No** consultes la 5.x: cambian clases (`ml-*`→`ms-*`, `thead-dark`→`table-dark`, forms reescritos, gutters `no-gutters`→`g-*`).
- Bootstrap 4.6 · Grid — https://getbootstrap.com/docs/4.6/layout/grid/
- Bootstrap 4.6 · Utilities (spacing) — https://getbootstrap.com/docs/4.6/utilities/spacing/
- Bootstrap 4.6 · Theming (Sass, `$theme-colors`) — https://getbootstrap.com/docs/4.6/getting-started/theming/ — la fuente para §7, incluido el patrón de `map-merge`.
- Sass (dart-sass) — https://sass-lang.com/documentation/ — la implementación oficial que usamos vía el paquete `sass`. Mirá especialmente `@import` (y su reemplazo moderno `@use`, que **no** usamos acá para no cambiar el pipeline heredado) y `map-merge`.

**Video / apoyo**

- Cualquier "Bootstrap 4 grid crash course" reciente sirve para el gesto general de la grilla. **Advertencia:** confirmá que sea de la **4**, no de la 5 — muchos títulos no lo aclaran y las clases difieren.

> ⚠️ Las URLs, títulos y contenidos de arriba pueden estar desactualizados
> o haber cambiado. Verificá siempre contra la versión instalada
> (Bootstrap **4.6.2**). Cuando un enlace o video cubra Bootstrap 5, está
> avisado — pero confirmá vos también. No confíes en clases de memoria si
> venís de la 5.

**Orden de lectura sugerido:** §1 (pipeline) para entender dónde vive todo
→ el bloque que necesites ahora mismo (grid, card, table o form) → §7 solo
cuando toques colores o quieras pagar la deuda del bundle. Para el sistema
de diseño completo, seguí con el **Apéndice A2**.

---

> **La señal de que quedó bien:** cuando estés tocando una vista y no
> necesites abrir la doc de Bootstrap — porque este apéndice ya te dice qué
> clase de la **4.6** usar y cuál es su trampa frente a la 5 — el apéndice
> hizo su trabajo. Es una chuleta, no un curso: se mide por lo rápido que
> te devuelve al código.
