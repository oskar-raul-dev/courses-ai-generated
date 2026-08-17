# 🎨 Apéndice A2 — Mini Design System con Sass

> **Material de consulta rápida, no lectura secuencial.** Lo abrís cuando una
> fase te manda acá o cuando estás por escribir estilos y no sabés dónde va
> cada cosa. No hace falta leerlo de corrido.
>
> **Prerrequisito real:** Fase 0 ya dejó `src/styles/_tokens.scss`,
> `src/index.scss` y el orden de import tokens → Bootstrap → estilos. Este
> apéndice **extiende** eso; no lo reemplaza. El [Apéndice A1](#) cubre
> Bootstrap 4 y Sass base (grid, cards, utilidades, paleta); acá damos el paso
> siguiente: convertir cuatro variables sueltas en un mini design system
> mantenible.
>
> **Stack fijado** (no negociable en código principal): React 16.14.0 · Bootstrap
> 4.6.2 · **dart-sass** (`sass` ≥ 1.32.0, nunca `node-sass`) · CRA 4.0.3.

---

## Índice

1. [Qué es —y qué no es— un mini design system](#1-qué-es-y-qué-no-es-un-mini-design-system)
2. [Anatomía de archivos](#2-anatomía-de-archivos)
3. [`@use` para lo nuestro, `@import` para Bootstrap 4](#3-use-para-lo-nuestro-import-para-bootstrap-4)
4. [Tokens](#4-tokens)
5. [Cómo el código real extiende Bootstrap](#5-cómo-el-código-real-extiende-bootstrap)
6. [Functions](#6-functions)
7. [Mixins del dominio de rifas](#7-mixins-del-dominio-de-rifas)
8. [Convenciones de nombramiento](#8-convenciones-de-nombramiento)
9. [Tabla: cuándo usar qué](#9-tabla-cuándo-usar-qué)
10. [Errores comunes en un vistazo](#10-errores-comunes-en-un-vistazo)
11. [Ejercicios](#11-ejercicios)
12. [Referencias](#12-referencias)

---

## 1. Qué es —y qué no es— un mini design system

Un mini design system, en un proyecto legacy de esta época, no es Figma ni
Storybook ni una librería publicada en npm. Es algo mucho más modesto y mucho
más útil de entender cuando mantenés: **un puñado de archivos Sass que
centralizan los valores de diseño (color, espaciado, tipografía, radios) y un
par de mixins que encapsulan patrones visuales repetidos del dominio.** Nada
más.

Su razón de existir es de mantenimiento, no de estética. Cuando el estado
"vendido" de un número deja de ser rojo `#dc3545` y pasa a ser un gris apagado
porque negocio lo pidió, querés cambiarlo **en un solo lugar** y que se propague
a la tabla de números, al badge del detalle y al dashboard. Si el color está
hardcodeado en quince `.scss` distintos, ese cambio de una línea se convierte en
una cacería y en un bug ("me olvidé del dashboard").

Lo que **no** es: no es una excusa para reescribir Bootstrap, ni para inventar
un sistema de grid propio, ni para abstraer todo "por si acaso". La regla del
proyecto aplica igual acá — **no modernizar automáticamente**. El design system
solo toca lo que el código real ya repite. Si un valor aparece una sola vez, no
es un token; es un valor.

---

## 2. Anatomía de archivos

Fase 0 arrancó con `_tokens.scss` e `index.scss`. A partir de que la app crece
(Fase 1 en adelante), la estructura estable del mini design system es:

```
src/styles/
  _tokens.scss      // valores crudos: colores, espaciado, tipografía, radios
  _functions.scss   // helpers que devuelven un valor (ej: color de estado)
  _mixins.scss      // patrones visuales reutilizables del dominio
  _bootstrap-overrides.scss  // redefine variables de Bootstrap 4 ANTES de importarlo
src/index.scss      // orquestador: junta todo en el orden correcto
```

Los archivos que empiezan con `_` son **parciales**: Sass no genera un `.css`
por cada uno, solo se incluyen desde otro archivo. `index.scss` es el único
punto de entrada que CRA compila.

> 💡 **Convención de import de parciales.** Escribís `@use "./tokens"` (sin el
> guion bajo y sin la extensión). Sass resuelve `_tokens.scss` solo. Mantené el
> guion bajo en el nombre del archivo; es la señal de "esto es un parcial, no
> lo compiles suelto".

---

## 3. `@use` para lo nuestro, `@import` para Bootstrap 4

Esta es la decisión técnica más importante del apéndice, y conviene entenderla
antes de copiar nada.

dart-sass tiene dos formas de traer código de otro archivo: el viejo `@import`
(global, todo cae en el mismo scope) y el moderno `@use` (con namespace, cada
módulo aislado). El proyecto usa **los dos, a propósito**, según de qué lado de
la frontera estés:

- **Para nuestros propios parciales** (`_tokens`, `_functions`, `_mixins`) usamos
  **`@use`**. Es código nuestro, moderno, y nos da namespaces explícitos: cuando
  ves `tokens.$primary` sabés de dónde sale la variable sin adivinar. Es la forma
  correcta de escribir Sass nuevo.

- **Para Bootstrap 4 usamos `@import`.** Y no es pereza: **Bootstrap 4.6.2 está
  escrito con `@import` y expone sus variables como globales `!default`.** Todo su
  mecanismo de customización —redefinir `$primary`, `$theme-colors`, `$spacers`
  *antes* de importar Bootstrap— depende de ese scope global. Con `@use`, las
  variables quedan namespaced y **los `!default` de Bootstrap no se dejan
  sobrescribir de la forma canónica.** Forzar `@use` sobre Bootstrap 4 no
  compila como esperás y contradice cómo se customiza esta versión.

Este híbrido no es un invento del tutorial: es exactamente la transición que
vivió muchísimo código real entre 2021 y 2022, cuando dart-sass empezó a
empujar `@use` pero las librerías (Bootstrap 4 entre ellas) seguían en
`@import`. Reconocerlo es parte del oficio de mantener esta era.

> 🔥 **Opcional / puente a moderno.** En Bootstrap 5.2+ (2022) llegó `@use` con
> `with (...)` para pasar overrides, y el modelo global quedó deprecado. Migrar
> el borde con Bootstrap a `@use` puro es un ejercicio de modernización que
> **no** hacemos en código principal — estamos en BS4.

`src/index.scss` — el orquestador, con el orden que importa:

```scss
// 1) Overrides de Bootstrap PRIMERO. Redefinen los !default de BS4,
//    así que tienen que estar en scope global ANTES de importar Bootstrap.
//    Por eso este archivo también entra con @import (globalidad).
@import "./styles/bootstrap-overrides";

// 2) Bootstrap completo. Ahora lee nuestros overrides como si fueran suyos.
//    💸 Deuda: importamos todo BS. Achicar a solo-lo-usado se ve en A1.
@import "~bootstrap/scss/bootstrap";

// 3) Nuestros estilos propios. Estos sí usan @use: son código nuestro.
@use "./styles/mixins" as mx;
@use "./styles/tokens" as tokens;

.raffle-card {
  border-top: 4px solid tokens.$primary;
  margin-bottom: tokens.$spacing * 2;
}
```

> ⚠️ **Error común.** Poner `@use` antes de los `@import` de Bootstrap. Sass
> es estricto: **todas las reglas `@use` deben ir al principio del archivo**,
> antes que cualquier `@import`. Si mezclás el orden, Sass tira
> `@use rules must be written before any other rules`. La forma de convivir es
> la de arriba: los `@import` de Bootstrap primero (porque necesitan globalidad),
> y como `@use` exige ir arriba, en la práctica el orquestador arranca con los
> overrides y Bootstrap vía `@import`, y los `@use` de nuestros módulos van
> agrupados. Si te pelea, separá: un archivo `_vendor.scss` con los `@import`
> de Bootstrap, e `index.scss` hace `@use` de todo lo nuestro y un `@import` de
> `_vendor` al final.

---

## 4. Tokens

Los tokens son los valores crudos del diseño. Fase 0 sembró cuatro; acá crecen
a un set realista pero deliberadamente chico. **La regla es la misma: un valor
es token solo si se repite.**

`src/styles/_tokens.scss`:

```scss
// Tokens del mini design system de Rifas y chances.
// Valores crudos, sin lógica. Los consume Bootstrap (vía overrides),
// las functions, los mixins y los componentes.

// --- Color de marca ---
$primary: #0066cc;   // azul de acción principal
$success: #28a745;   // verde "abierta / disponible"
$danger:  #dc3545;   // rojo "cerrada / vendido"
$warning: #f0ad4e;   // ámbar "reservado / por vencer"
$muted:   #6c757d;   // gris "resuelta / liquidada / inactivo"

// --- Espaciado (múltiplos de una unidad base) ---
$spacing: 0.5rem;          // unidad base (heredada de Fase 0)
$spacing-lg: $spacing * 3; // separaciones grandes

// --- Tipografía ---
$font-base: 1rem;
$font-mono: "SFMono-Regular", "Consolas", monospace; // para los números 0000-9999

// --- Radios y bordes ---
$radius: 0.25rem;
$border-accent: 4px;  // el filete de color arriba de las cards
```

> 💡 **Por qué `$font-mono` importa en este dominio.** Los números de rifa son
> `0000`–`9999`, siempre cuatro dígitos con ceros a la izquierda. En una fuente
> proporcional, `1111` es más angosto que `0000` y las columnas de la tabla
> bailan. Monoespaciada, todos los números ocupan lo mismo y la tabla queda
> prolija. Es una decisión de diseño con causa de dominio, no capricho.

> ⚠️ **Error común.** Meter en tokens cosas que no son valores de diseño sino
> decisiones de un componente puntual (el ancho exacto de *esa* tabla, el
> z-index de *ese* modal). Eso infla el archivo y confunde. Token = valor
> transversal que se repite. Lo demás vive en el `.scss` del componente.

---

## 5. Cómo el código real extiende Bootstrap

Este es el corazón de "cómo el código real extiende Bootstrap" que pide el plan.
No peleamos con Bootstrap 4: **le pasamos nuestros tokens como si fueran suyos**,
redefiniendo sus variables `!default` antes de importarlo.

`src/styles/_bootstrap-overrides.scss`:

```scss
// Se importa ANTES que Bootstrap (ver index.scss). Redefine los !default
// de BS4 con nuestros tokens. Bootstrap, al importarse después, los toma.
//
// Ojo: este archivo NO puede usar @use tokens porque necesita que estas
// variables queden en scope GLOBAL para que Bootstrap las vea. Por eso
// duplicamos los valores clave acá o los traemos con un @import de tokens.
@import "./tokens";

// Mapa de colores de tema de Bootstrap: la clave del asunto.
// BS4 genera .btn-primary, .badge-success, .text-danger, etc. a partir
// de este mapa. Al inyectar nuestros valores, TODAS las utilidades de
// Bootstrap quedan alineadas con la marca sin escribir CSS a mano.
$theme-colors: (
  "primary": $primary,
  "success": $success,
  "danger":  $danger,
  "warning": $warning,
  "muted":   $muted
);

// Escala de espaciado de Bootstrap (.mt-3, .p-2...) anclada a nuestra unidad.
$spacer: $spacing * 2;  // BS4 deriva .m-1..5 de $spacer

// Radio global de botones, cards, inputs.
$border-radius: $radius;
```

Con esto, `<span class="badge badge-success">Abierta</span>` usa **tu** verde,
no el verde de fábrica de Bootstrap, sin que hayas escrito una sola clase
propia. Esa es la palanca: **extender Bootstrap por sus variables, no por
CSS que lo pisa.**

> ⚠️ **Error común (y clásico de mantenimiento).** "Ganarle" a Bootstrap con
> `!important` o con selectores más específicos porque el color no cambió. El
> 90% de las veces el problema no es especificidad: es **orden**. Si redefinís
> `$theme-colors` *después* de `@import "~bootstrap/scss/bootstrap"`, Bootstrap
> ya generó su CSS con los valores viejos y tu redefinición no hace nada. La
> regla de oro de BS4: **overrides arriba, Bootstrap abajo.** Si algo no toma
> el color, lo primero que mirás es el orden de imports, no la especificidad.
> 💸 Un `!important` acá es casi siempre deuda tapando un problema de orden.

---

## 6. Functions

Una function de Sass **devuelve un valor**. En este dominio la más útil traduce
un estado de negocio a su color, para no repetir el `if` de color por todos
lados.

`src/styles/_functions.scss`:

```scss
@use "./tokens" as tokens;

// Devuelve el color asociado a un estado del dominio.
// Los estados van en INGLÉS (son valores de código, no UI): ver A5 / guía.
@function status-color($status) {
  @if $status == "available" or $status == "open" {
    @return tokens.$success;
  } @else if $status == "reserved" {
    @return tokens.$warning;
  } @else if $status == "sold" or $status == "closed" {
    @return tokens.$danger;
  } @else if $status == "settled" or $status == "resolved" {
    @return tokens.$muted;
  }
  @warn "status-color: estado no reconocido '#{$status}'";
  @return tokens.$muted; // fallback seguro
}
```

Uso:

```scss
.number-cell--sold { background: status-color("sold"); }
```

> ⚠️ **Error común.** Confundir **function** con **mixin**. La function
> *devuelve un valor* (`color: status-color("sold")`). El mixin *inyecta un
> bloque de reglas* (`@include number-state("sold")`). Si estás escribiendo
> `@return`, es function; si estás escribiendo propiedades CSS, es mixin.

---

## 7. Mixins del dominio de rifas

Un mixin inyecta un bloque de reglas reutilizable. Derivados del dominio y de
lo que el código de esta época realmente repite, estos son los patrones que
justifican un mixin. No inventamos más de los que se usan.

`src/styles/_mixins.scss`:

```scss
@use "./tokens" as tokens;
@use "./functions" as fn;

// --- 1) Filete de color arriba de una card, según estado de rifa ---
// El patrón visual "card con borde superior de color" se repite en el
// listado de rifas, el detalle y el dashboard. Un mixin lo centraliza.
@mixin raffle-accent($status) {
  border-top: tokens.$border-accent solid fn.status-color($status);
  border-radius: tokens.$radius;
}

// --- 2) Celda de número según estado (disponible/reservado/vendido) ---
// La grilla 0000-9999 pinta 10.000 celdas por estado. Este es EL mixin
// más usado de la app de rifas.
@mixin number-state($status) {
  font-family: tokens.$font-mono;   // números alineados
  background: fn.status-color($status);
  color: #fff;
  @if $status == "available" {
    cursor: pointer;                // solo lo disponible es clickeable
  } @else {
    cursor: not-allowed;
    opacity: 0.85;
  }
}

// --- 3) Badge de estado de rifa (texto + color de fondo) ---
@mixin status-badge($status) {
  display: inline-block;
  padding: (tokens.$spacing * 0.5) tokens.$spacing;
  border-radius: tokens.$radius;
  background: fn.status-color($status);
  color: #fff;
  font-size: 0.85 * tokens.$font-base;
}

// --- 4) Responsive: helper de breakpoint sobre los de Bootstrap 4 ---
// BS4 define sus breakpoints (sm 576, md 768, lg 992, xl 1200). En vez de
// hardcodear píxeles, exponemos un mixin legible. Valores alineados a BS4.
@mixin above($bp) {
  $breakpoints: ("sm": 576px, "md": 768px, "lg": 992px, "xl": 1200px);
  @if map-has-key($breakpoints, $bp) {
    @media (min-width: map-get($breakpoints, $bp)) { @content; }
  } @else {
    @warn "above: breakpoint desconocido '#{$bp}'";
  }
}
```

Uso combinado:

```scss
.raffle-card {
  @include raffle-accent("open");
}

.number-cell {
  &--available { @include number-state("available"); }
  &--reserved  { @include number-state("reserved"); }
  &--sold      { @include number-state("sold"); }
}

.raffle-status { @include status-badge("closed"); }

.number-grid {
  grid-template-columns: repeat(10, 1fr);
  @include above("md") { grid-template-columns: repeat(20, 1fr); }
}
```

> ⚠️ **Error común #1 — `@content` olvidado.** Un mixin que debe recibir un
> bloque (como `above`) necesita `@content;` adentro para inyectar lo que le
> pasás entre llaves. Sin `@content`, el `@include above("md") { ... }` compila
> pero **descarta silenciosamente** tu bloque. No hay error: simplemente tus
> estilos responsive desaparecen. Es un bug difícil de ver porque nada se queja.

> ⚠️ **Error común #2 — mixin donde alcanzaba una clase de Bootstrap.** Antes de
> escribir un mixin, preguntate si BS4 ya lo resuelve. `status-badge` casi se
> solapa con `.badge` de Bootstrap; lo justificamos solo porque atamos el color
> a `status-color` y a la fuente del dominio. Si un mixin no agrega nada que
> Bootstrap no dé, es deuda disfrazada de abstracción. 💸

> ⚠️ **Error común #3 — hardcodear breakpoints.** `@media (min-width: 768px)`
> desperdigado por diez archivos es imposible de mantener cuando BS4 cambia su
> `md`. El mixin `above` centraliza esos valores. Que estén **alineados a los
> de Bootstrap 4** no es decorativo: si tu `md` y el de Bootstrap difieren por
> 1px, tenés saltos de layout que nadie entiende.

---

## 8. Convenciones de nombramiento

Coherentes con la guía de estilo del proyecto y el diccionario código-inglés:

- **Clases, variables, mixins y functions van en inglés.** `.raffle-card`, no
  `.tarjeta-rifa`. `status-color`, no `color-estado`. Solo la narrativa y el
  texto que ve el usuario van en español.
- **Estados en inglés como valores de código.** `"open"`, `"sold"`, `"reserved"`
  — nunca `"abierta"` en un token o mixin. La traducción a español ocurre en la
  UI (ver A5 y la guía), no en el Sass.
- **Modificadores con BEM ligero.** Bloque `.number-cell`, modificador
  `.number-cell--sold` (doble guion). No mezclamos con la convención de utilidad
  de Bootstrap; las clases propias son BEM, las de Bootstrap son de Bootstrap.
- **Prefijo de dominio, sin sobre-namespacing.** El proyecto es chico y todo
  vive bajo el mismo repo, así que no hace falta prefijar todo con `rc-`. Usamos
  nombres de dominio claros (`raffle-`, `number-`, `status-`) que ya funcionan
  como namespace semántico.
- **Parciales con `_` y sin extensión al importarlos.** Archivo `_mixins.scss`,
  import `@use "./mixins"`.

---

## 9. Tabla: cuándo usar qué

| Necesito… | Herramienta | Ejemplo |
|---|---|---|
| Un valor que se repite (color, espaciado, radio) | **Token** en `_tokens.scss` | `$primary`, `$spacing` |
| Que Bootstrap use mis colores/espaciado | **Override** en `_bootstrap-overrides.scss` (antes de importar BS) | `$theme-colors`, `$spacer` |
| Traducir un dato a un valor (estado → color) | **Function** (`@return`) | `status-color("sold")` |
| Inyectar un bloque de reglas repetido | **Mixin** (`@include`) | `number-state("available")` |
| Un media query legible | **Mixin `above`** con `@content` | `@include above("md") { … }` |
| Traer código propio (parciales) | **`@use`** con namespace | `@use "./tokens" as tokens` |
| Traer / customizar Bootstrap 4 | **`@import`** (scope global) | `@import "~bootstrap/scss/bootstrap"` |
| Estilo de un solo componente, no transversal | **`.scss` del componente**, sin token | `RaffleForm.scss` |

---

## 10. Errores comunes en un vistazo

| Síntoma | Causa raíz | Fix |
|---|---|---|
| El color de marca no se aplica en botones/badges | Overrides definidos **después** de `@import` de Bootstrap | Mover overrides **arriba** de Bootstrap |
| `@use rules must be written before any other rules` | `@use` mezclado después de un `@import` | Agrupar `@use` al inicio; aislar Bootstrap en `_vendor.scss` |
| No puedo sobrescribir variables de Bootstrap | Intentaste `@use` sobre Bootstrap 4 (namespaced, no global) | Usar `@import` para el borde con BS4 |
| Los estilos responsive desaparecen sin error | Falta `@content;` dentro del mixin de breakpoint | Agregar `@content;` donde va el bloque |
| Las columnas de números "bailan" | Fuente proporcional en la grilla | Aplicar `$font-mono` vía `number-state` |
| Recompilo y nada cambia (Mac) | `node-sass` colado en vez de dart-sass | `npm i sass`, quitar `node-sass` (ver Fase 0) 💸 |
| `!important` por todos lados | Peleando especificidad cuando el problema era orden | Revisar orden de imports antes de tocar especificidad |

---

## 11. Ejercicios

Cortos, para consulta rápida. Los de 🔥 son opcionales / ampliación.

- 🟢 **1.** Agregá un token `$radius-pill: 50rem` y usalo para que los badges de
  estado sean redondeados. ¿Dónde va el token y dónde el uso?
- 🟢 **2.** El verde de "abierta" cambió a `#2e9e4f`. Cambialo en **un solo
  lugar** y verificá que se propaga a `.badge-success` de Bootstrap y a
  `number-state("available")`. ¿Por qué basta un lugar?
- 🟡 **3.** Escribí una function `status-label-color($status)` que devuelva
  `#fff` para estados oscuros y `#212529` para `"reserved"` (fondo ámbar claro).
  Integrala en `status-badge`.
- 🟡 **4.** Convertí un `@media (min-width: 992px)` hardcodeado de un componente
  a `@include above("lg")`. Confirmá que el resultado compilado es idéntico.
- 🟡 **5.** Un compañero puso `$theme-colors` **después** del `@import` de
  Bootstrap y "no anda". Reproducí el bug, explicá la causa en una frase y
  corregilo.
- 🟠 **6.** Un mixin `above("xxl")` no aplica nada y no da error. Diagnosticá por
  qué (pista: `map-has-key`) y agregá el manejo correcto.
- 🟠 **7.** Refactorizá tres bloques `.scss` que repiten el filete superior de
  color hacia el mixin `raffle-accent`. Medí cuántas líneas se eliminaron.
- 🟠 **8.** Escribí un test manual: cambiá `$spacer` y documentá qué utilidades
  de Bootstrap (`.m-*`, `.p-*`) se ven afectadas y cuáles no. ¿Por qué el grid
  no cambia?
- 🔴 **9.** Un mixin de breakpoint sin `@content` está tragándose estilos
  responsive en producción y en dev "parece andar". Reproducí, encontralo, y
  escribí una nota de prevención para el equipo.
- 🔥 **10.** *(Puente a moderno)* Investigá cómo se pasarían overrides a Bootstrap
  **5** con `@use "bootstrap" with (...)` y explicá por qué ese patrón **no** es
  aplicable a nuestra versión 4.6.2. No lo implementes en código principal.
- 🔥 **11.** *(Puente a moderno)* dart-sass emite deprecation warnings al mezclar
  `@use` con dependencias basadas en `@import`. Capturá uno de esos warnings en
  la consola de build y explicá qué te está avisando y por qué lo aceptamos acá.

---

## 12. Referencias

Documentación oficial compatible con las versiones fijadas, primero; lo demás,
después.

- **Sass — `@use`:** https://sass-lang.com/documentation/at-rules/use
- **Sass — `@import` (legacy, aún válido para BS4):** https://sass-lang.com/documentation/at-rules/import
- **Sass — mixins y `@content`:** https://sass-lang.com/documentation/at-rules/mixin
- **Sass — functions:** https://sass-lang.com/documentation/at-rules/function
- **Sass — módulo `sass:map` (`map-get`, `map-has-key`):** https://sass-lang.com/documentation/modules/map
- **Bootstrap 4.6 — Theming (customizar vía `$theme-colors`, `$spacer`):** https://getbootstrap.com/docs/4.6/getting-started/theming/
- **Bootstrap 4.6 — Sass variables por defecto:** https://getbootstrap.com/docs/4.6/getting-started/options/
- **Apéndice A1 — Bootstrap 4 + Sass** (grid, cards, utilidades, paleta base).
- **Apéndice A5 — Class vs hooks** (convención código-inglés / UI-español).
- **Fase 0** (`_tokens.scss` inicial, orden de import, dart-sass vs node-sass).

---

> 🚀 **Cómo se conecta.** Desde Fase 1 en adelante, cada vez que un componente
> necesite un color de estado, un badge de rifa o una celda de número, la
> respuesta vive acá: token, function o mixin. Si te encontrás hardcodeando un
> `#dc3545` o un `@media (min-width: 768px)` en un componente, pará y volvé a
> este apéndice — casi seguro ya existe la pieza.
