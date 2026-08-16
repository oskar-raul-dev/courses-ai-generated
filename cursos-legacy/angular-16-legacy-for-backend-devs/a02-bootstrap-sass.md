# 📎 Apéndice A02 — 🔥 Bootstrap 5 + Sass

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **2 horas**
> Usado por: ninguna fase lo asume · Versión cubierta: Bootstrap 5.3.x + dart-sass
> 🔥 **Opcional — el curso se completa sin abrir este apéndice.**

**Este apéndice no describe a CertCore.** CertCore usa Angular Material 16 y nada más: no tiene Bootstrap, ninguna fase lo instala, y ningún ejercicio del curso lo necesita. Lo que describe es **un escenario que te vas a encontrar en otro sistema heredado**, porque es de los más comunes que existen: alguien empezó con Bootstrap, alguien más añadió Material, y hoy los dos se pelean por la cascada mientras el equipo esquiva el problema añadiendo `!important`.

Si estás siguiendo el curso, sáltatelo sin remordimiento. Si heredaste un repositorio con las dos librerías dentro, esto es lo que hace falta saber para no empeorarlo.

**Qué queda fuera:** el rediseño visual de nada, la migración de una librería a la otra —que es un proyecto, no un apéndice—, y los componentes JavaScript de Bootstrap, que no se usan y cuya razón está en la §6.

---

## Índice

- [1. Cómo se llega a tener las dos](#1-cómo-se-llega-a-tener-las-dos)
- [2. El grid de Bootstrap con componentes de Material](#2-el-grid-de-bootstrap-con-componentes-de-material)
- [3. Quién gana la cascada](#3-quién-gana-la-cascada)
- [4. Una sola paleta, dos consumidores](#4-una-sola-paleta-dos-consumidores)
- [5. ⚠️ Qué recompilar tras tocar qué](#5-️-qué-recompilar-tras-tocar-qué)
- [6. Los componentes JS de Bootstrap: por qué no](#6-los-componentes-js-de-bootstrap-por-qué-no)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-6)

---

## 1. Cómo se llega a tener las dos

Casi nunca es una decisión: es una sedimentación, y reconocer cuál de las tres historias tienes delante te dice qué se puede arreglar.

**La historia A — Bootstrap primero, Material después.** El proyecto nació con Bootstrap porque el equipo venía de plantillas de servidor y ya lo conocía. Cuando llegó un formulario complejo, alguien añadió Material por sus componentes —tabla, diálogo, selector de fecha— y se quedaron los dos. Es la más frecuente y la más manejable: Bootstrap se usa sólo para el layout.

**La historia B — Material primero, Bootstrap después.** Alguien quería el grid, o `d-flex`, o los utilitarios de espaciado, y añadió Bootstrap entero para eso. Es la peor de las tres, porque trae el *Reboot* de Bootstrap —su reinicio de estilos— a un proyecto que no lo necesitaba, y ese reinicio toca `button`, `input` y la tipografía base, que es exactamente lo que Material también toca.

**La historia C — una plantilla comprada.** El sistema arrancó sobre un tema de administración de pago que traía Bootstrap dentro, y Material entró después por componentes concretos. Aquí lo que hay debajo suele ser Bootstrap **modificado**, y la primera tarea es averiguar cuánto.

> 🧭 **La primera pregunta, y hay que hacerla antes de tocar una línea de CSS: ¿para qué se usa cada una?** Si Bootstrap sólo aporta grid y utilitarios, el problema es acotado y se resuelve con la §2 y la §3. Si las dos librerías están pintando botones, campos y tarjetas, el problema no es de CSS: es que el sistema tiene dos lenguajes visuales, y eso se decide con producto, no en un `styles.scss`.

---

## 2. El grid de Bootstrap con componentes de Material

Funciona, y es la combinación que menos duele. La clave es **importar sólo lo que usas**, no Bootstrap entero.

```scss
// src/styles.scss — el orden importa y la selección más.
// 1. Lo que Bootstrap necesita para calcular cualquier cosa.
@use 'bootstrap/scss/functions' as *;
@use 'bootstrap/scss/variables' as *;
@use 'bootstrap/scss/mixins' as *;

// 2. Sólo las piezas que de verdad se usan. Sin reboot, sin componentes.
@use 'bootstrap/scss/grid';
@use 'bootstrap/scss/utilities/api';

// 3. Y después Material, entero.
@use '@angular/material' as mat;
@include mat.core();
// …el tema, como en la Fase 6 de CertCore.
```

**Lo que ganas con esa selección:** el grid (`container`, `row`, `col-*`) y los utilitarios (`d-flex`, `mt-3`, `text-end`) sin traer el *Reboot* ni un solo componente de Bootstrap. Es decir: layout de Bootstrap, componentes de Material, y casi ninguna colisión.

```html
<!-- Y en la plantilla, sin ninguna ceremonia: -->
<div class="row">
  <div class="col-12 col-md-6">
    <mat-form-field appearance="outline" class="w-100">
      <mat-label>Razón social</mat-label>
      <input matInput formControlName="legalName" />
    </mat-form-field>
  </div>
</div>
```

> ⚠️ **El `w-100` de ahí arriba es necesario y no es obvio.** Un `mat-form-field` es `inline-block` por defecto y no llena su columna; sin una anchura explícita, tu grid de Bootstrap se ve perfecto y los campos se quedan encogidos a la izquierda. Es la primera media hora que pierde todo el mundo con esta combinación.

**Lo que hay que evitar en la misma pantalla:** un `<button class="btn btn-primary">` de Bootstrap al lado de un `<button mat-raised-button>` de Material. Los dos funcionan, los dos se ven bien por separado, y juntos delatan que el sistema no tiene una decisión tomada. Si tienes que elegir uno para todo, elige el de la librería que aporta los componentes complejos — normalmente Material.

---

## 3. Quién gana la cascada

Tres mecanismos deciden, y en este orden.

**Uno — la especificidad del selector.** Gana el más específico, sin importar el orden. Bootstrap escribe selectores de clase simples (`.btn`), Material escribe selectores más largos y anidados (`.mat-mdc-raised-button.mat-primary`). **En un empate de especificidad no hay empate: casi siempre gana Material**, porque sus selectores son más específicos por construcción. Ésa es la razón real de que "Bootstrap no me aplica" sea la queja frecuente y no al revés.

**Dos — el orden de `styles[]` en `angular.json`.** A igualdad de especificidad, gana el que se cargue **último**. Y este archivo es el que nadie mira:

```jsonc
// angular.json → …architect.build.options.styles
{
  "styles": [
    "src/styles.scss"     // si aquí hubiera dos archivos, el segundo ganaría
  ]
}
```

**Tres — `@layer`, que es la herramienta correcta y casi nadie usa.** Las capas en cascada permiten declarar la prioridad **explícitamente**, en vez de dejarla a merced de la especificidad. Una capa declarada antes pierde contra una declarada después, **incluso si sus selectores son más específicos**:

```scss
// El orden de esta línea es el contrato: bootstrap pierde contra material,
// y los dos pierden contra lo tuyo. Escrito una vez, y se acabó la discusión.
@layer bootstrap, material, app;

@layer bootstrap {
  @use 'bootstrap/scss/grid';
  @use 'bootstrap/scss/utilities/api';
}
```

> 💡 **Por qué `@layer` es mejor que ganar la pelea a mano.** La alternativa que aplica todo el mundo es subir especificidad —anidar un selector de más— o poner `!important`. Las dos funcionan hoy y las dos empeoran el archivo: la primera arranca una carrera armamentística que el siguiente que pase tiene que ganar otra vez, y la segunda destruye la información de quién debería ganar. Con capas, la respuesta a "¿por qué este estilo no aplica?" está en una línea al principio del archivo en vez de repartida por trescientas.

**Y la advertencia sobre `::ng-deep`**, que aparece en cuanto quieras que un estilo de componente alcance a un componente de librería: sigue en desuso, sigue sin sustituto, y si además tienes dos librerías peleándose, un `::ng-deep` mal puesto es la forma más rápida de que un estilo se filtre a pantallas que no lo esperaban. Si lo escribes, que sea con un selector de ámbito propio delante (`:host .certcore-panel ::ng-deep …`) y con un comentario diciendo qué consigue.

---

## 4. Una sola paleta, dos consumidores

El síntoma de que esto no está resuelto es inconfundible: dos azules ligeramente distintos en la misma pantalla, y nadie sabe cuál es el correcto.

La dificultad real es que las dos librerías esperan **formas distintas** del mismo dato. Bootstrap quiere colores sueltos; Material quiere una paleta con tonos del 50 al 900 y un mapa de colores de contraste. No hay una conversión automática, así que la fuente de verdad se declara una vez y se adapta dos:

```scss
// _brand.scss — la ÚNICA fuente de verdad del color de marca.
$brand-500: #3f51b5;
$brand-700: #303f9f;
$brand-100: #c5cae9;
```

```scss
// Consumidor 1 — Bootstrap. Las variables se sobrescriben ANTES de importar
// sus variables, o el `!default` de Bootstrap ya habrá ganado.
@use 'brand' as brand;

$primary: brand.$brand-500;
$theme-colors: ('primary': $primary);

@use 'bootstrap/scss/variables' as *;
```

```scss
// Consumidor 2 — Material. Necesita el mapa completo de tonos y el de
// contraste; no hay atajo, y por eso conviene generarlo una vez y no tocarlo.
@use 'brand' as brand;
@use '@angular/material' as mat;

$brand-palette: (
  100: brand.$brand-100,
  500: brand.$brand-500,
  700: brand.$brand-700,
  contrast: (100: rgba(black, 0.87), 500: white, 700: white),
);

$primary: mat.define-palette($brand-palette, 500, 100, 700);
```

> ⚠️ **El `!default` de Sass es el detalle que arruina esto en silencio.** Las variables de Bootstrap están declaradas con `!default`, que significa "usa este valor **salvo que ya exista uno**". Si sobrescribes `$primary` **después** de importar las variables de Bootstrap, tu valor llega tarde: la variable ya tiene el suyo y tu línea no hace nada. No hay error, no hay advertencia, y el color simplemente no cambia. Es, con diferencia, la causa número uno de "toqué la variable y no pasó nada".

---

## 5. ⚠️ Qué recompilar tras tocar qué

La media hora perdida más frecuente de todo el tema, y cabe en una tabla.

| Tocaste… | ¿Se recompila solo con `ng serve`? | Qué hacer |
|---|---|---|
| Un `.scss` de componente | ✅ sí | nada |
| `src/styles.scss` o un parcial que importa | ✅ sí | nada |
| Una variable Sass en un parcial | ✅ sí, **pero** el orden manda | comprueba que la sobrescritura va **antes** del `@use` de la librería (§4) |
| `angular.json` (la lista de `styles`) | ❌ **no** | **reinicia `ng serve`**; el CLI lee ese archivo al arrancar |
| `package.json` / instalaste Bootstrap | ❌ no | `npm install` y reinicia `ng serve` |
| Nada, pero no ves el cambio | — | recarga forzando (`Cmd`/`Ctrl` + `Shift` + `R`): es el CSS cacheado |

> 🧭 **El orden de diagnóstico, cuando tocaste algo y no cambió nada.** Uno: ¿es caché del navegador? Recarga forzando. Dos: ¿tocaste `angular.json`? Reinicia el servidor. Tres: ¿la variable está **antes** del `@use` de la librería? Cuatro: ¿la está ganando otro selector? Abre el inspector, mira la regla tachada y quién la tacha. Cuatro pasos, en ese orden, y el cuarto —que es donde todo el mundo empieza— casi nunca es la respuesta.

---

## 6. Los componentes JS de Bootstrap: por qué no

Bootstrap 5 quitó jQuery y sus componentes son JavaScript propio: modales, desplegables, pestañas, *tooltips*. **En una aplicación Angular no se usan**, y hay tres razones que se acumulan:

**Manipulan el DOM por fuera de Angular.** Un modal de Bootstrap mueve nodos, añade clases y bloquea el scroll sin que Angular sepa nada. Cuando el componente que lo contenía se destruye, esos cambios se quedan — el clásico "la pantalla no responde y hay un `modal-backdrop` invisible tapándolo todo".

**Colisionan de frente con Material.** Un `MatDialog` y un modal de Bootstrap gestionan foco, `aria` y capas de superposición cada uno a su manera. Con los dos en la misma aplicación, el foco se pierde y la accesibilidad deja de funcionar en los dos.

**No hacen falta.** Material tiene diálogo, menú, pestañas y *tooltip*, integrados con el ciclo de vida y con el CDK de accesibilidad. Añadir la versión de Bootstrap es traer un segundo mecanismo para lo que ya está resuelto.

> 🧭 **La regla, y es la única de este apéndice que no admite matices: de Bootstrap se usa el CSS —grid y utilitarios—, nunca el JavaScript.** Si un sistema heredado ya lo usa, sustituirlo por el equivalente de Material es de los pocos refactores que se pagan solos, porque cada uno de esos componentes es un candidato a bug de estado.

---

## 🧭 Cuándo usar qué

| Situación | Decisión |
|---|---|
| Necesitas layout en un proyecto con Material | grid y utilitarios de Bootstrap, importados por partes |
| Vas a añadir Bootstrap entero "por comodidad" | no: el *Reboot* va a chocar con Material |
| Un estilo de Bootstrap no aplica | especificidad (§3); casi siempre gana Material |
| Quieres decidir la prioridad de una vez | `@layer bootstrap, material, app` |
| Tocaste una variable Sass y no cambió nada | ponla **antes** del `@use` de la librería (`!default`) |
| Tocaste `angular.json` y no cambió nada | reinicia `ng serve` |
| Dos azules distintos en la misma pantalla | una fuente de verdad, dos adaptaciones (§4) |
| Necesitas un modal, un menú o pestañas | Material, siempre; nunca el JS de Bootstrap |
| Las dos librerías pintan botones y campos | esto ya no es CSS: es una decisión de producto |

---

## 📚 Referencias

- https://getbootstrap.com/docs/5.3/customize/sass — cómo importar Bootstrap por partes y cómo funcionan sus variables con `!default`. Es la sección clave de la §4.
- https://getbootstrap.com/docs/5.3/layout/grid — el grid, que es lo que de verdad se usa.
- https://getbootstrap.com/docs/5.3/utilities/api — la API de utilitarios, para importar sólo los que necesitas.
- https://sass-lang.com/documentation/at-rules/use — `@use` y `with`, que es la forma moderna de configurar una librería Sass. ⚠️ Bootstrap 5.3 todavía documenta buena parte de su personalización con `@import`, que dart-sass está retirando; conviven, y mezclarlos da avisos de obsolescencia.
- https://developer.mozilla.org/es/docs/Web/CSS/@layer — las capas en cascada de la §3.
- https://v16.material.angular.io/guide/theming — el lado de Material de la §4.

> ⚠️ Las guías que encuentres sobre "Bootstrap y Angular Material juntos" son mayoritariamente anteriores a Material 15 y describen el DOM de antes de MDC. Sus selectores de `::ng-deep` no aplican aquí. Lo que sigue siendo válido de ellas es el razonamiento sobre la cascada, no el código.

**Orden de lectura sugerido:** la §1 primero, para saber qué historia tienes delante — sin eso, todo lo demás son técnicas sin diagnóstico. La §5 antes de la §3: la mitad de las veces que un estilo "no aplica", el problema es que no se recompiló. La §4 el día que aparezcan los dos azules. La §6 antes de tu primer modal.

---

## 🧪 Ejercicios (6)

1. 🟢 En un proyecto de prueba —**no en CertCore**— instala Bootstrap 5.3 e importa sólo `grid` y `utilities/api`. Comprueba que `container`, `row` y `d-flex` funcionan y que `.btn` no existe. Explica en una línea por qué eso es lo que quieres.

2. 🟢 Mete un `<mat-form-field>` dentro de un `col-md-6` sin `w-100` y con él. Captura las dos y explica la diferencia.

3. 🟡 Pon un `<button class="btn btn-primary">` junto a un `<button mat-raised-button color="primary">`. Abre el inspector, encuentra qué reglas se están aplicando a cada uno, y anota la especificidad de las dos que compiten.

4. 🟡 Sobrescribe `$primary` de Bootstrap **después** del `@use` de sus variables y comprueba que no pasa nada. Muévelo antes y comprueba que sí. Escribe en dos líneas qué hace `!default` y por qué el fallo es silencioso.

5. 🟠 Declara `@layer bootstrap, material, app` y mete cada bloque en su capa. Después crea deliberadamente un conflicto donde el selector de Bootstrap sea **más específico** que el de Material, y comprueba que aun así pierde. Explica por qué eso es mejor que ganar con `!important`.

6. 🔴 Te dan un repositorio heredado donde las dos librerías pintan botones, campos y tarjetas, y hay diecisiete `!important` repartidos. Escribe el plan de una página para desenredarlo: qué diagnosticas primero (§1), qué se puede arreglar con capas sin tocar HTML, qué exige una decisión de producto, y en qué orden lo harías para que el sistema nunca quede peor que al empezar. El criterio de éxito es que el plan se pueda ejecutar en incrementos, cada uno desplegable por su cuenta.

---

> 🏷️ **Este apéndice no lleva tag propio, y además su código no pertenece a CertCore.** Los ejercicios se hacen en un proyecto de prueba aparte; nada de lo que salga de aquí entra al repositorio del curso, porque CertCore no tiene Bootstrap y meterlo rompería la coherencia de las catorce fases. Si quieres conservar tus pruebas, van en un repositorio propio. La convención de commits y tags del curso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
