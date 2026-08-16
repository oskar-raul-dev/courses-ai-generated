# 🕵️ Forense Fase 01 — "La ruta funciona pero la pantalla sale en blanco"

> Pieza forense de la **Fase 1 — Estructura base con NgModules** · Recorrido: ~30 min
> Herramientas: mensajes del compilador de plantillas · `grep` · pestaña Network (filtro `JS`) · `--named-chunks`
> Síntoma que cubre: la URL cambia, no hay error visible, y donde debería haber una pantalla no hay nada.

Un `NgModule` no falla como falla el código normal. Su error llega **desde el compilador de plantillas**, nombra un selector en vez de un archivo, y a veces no llega: la pantalla simplemente se queda vacía. Esta pieza es el camino desde cada uno de esos mensajes hasta el archivo que hay que tocar.

La fase resume las tres preguntas; aquí están los mensajes literales de cada error y qué hacer con cada uno.

---

## 🎫 El ticket

> *"Agregué la pantalla de activos siguiendo la de plantillas. La ruta `/assets` cambia la URL, el menú se marca, y la pantalla queda en blanco. No sale nada rojo."*

**Reportado por:** un compañero del equipo, en desarrollo
**Ambiente:** `ng serve`

---

## 🧭 La ruta

Cuatro pasos, del más barato al más caro. El paso 1 son diez segundos de consola y resuelve el 70% de los casos.

### Paso 1 — ¿Hay un mensaje del compilador, o de verdad no hay nada?

Mira **la terminal de `ng serve` antes que la consola del navegador**. El compilador de plantillas escribe ahí, y si el navegador ya tenía la aplicación cargada, puede que no haya recargado.

Los cuatro mensajes que produce el 90% de las pantallas en blanco de este curso, literales:

```
NG0304: 'cc-asset-list' is not a known element:
1. If 'cc-asset-list' is an Angular component, then verify that it is part of this module.
2. If 'cc-asset-list' is a Web Component then add 'CUSTOM_ELEMENTS_SCHEMA' to the
   '@NgModule.schemas' of this component to suppress this message.
```
→ El componente existe pero **el módulo desde el que lo usas no lo conoce**. Paso 2.

```
NG0303: Can't bind to 'formGroup' since it isn't a known property of 'form'.
```
→ El componente existe y la **directiva** no. Falta `ReactiveFormsModule` en los `imports` de este módulo. Es el mismo problema con otra cara: en Angular, una directiva se importa igual que un componente.

```
Type AssetListComponent is part of the declarations of 2 modules: AssetsModule and
SharedModule! Please consider moving AssetListComponent to a higher module that imports
AssetsModule and SharedModule.
```
→ **Declarado dos veces.** Un componente pertenece a exactamente un módulo. Éste es el error que más gente intenta arreglar añadiéndolo a un tercer módulo, que lo empeora.

```
NG0201: No provider for HttpClient found in NodeInjector.
```
→ No es de declaraciones: es de providers, y a partir de la Fase 5 hay que mirar **el paréntesis del mensaje** para saber si buscar en módulos o en rutas. Eso es `forense-fase-05.md`.

**Qué descarta.** Si hay mensaje, tienes el camino resuelto: cada uno lleva a un sitio distinto. Si la terminal está limpia y el navegador también, entonces el componente sí se declaró y el problema es la ruta o el módulo diferido: salta al **paso 3**.

### Paso 2 — Del selector al módulo, en tres saltos

El mensaje te da un selector, no un archivo. El camino es siempre el mismo y no requiere conocer el proyecto:

```bash
# 1. El selector → el archivo del componente
grep -rn "cc-asset-list" src/
# src/app/features/assets/asset-list/asset-list.component.ts:8:  selector: 'cc-asset-list',
# src/app/features/assets/assets.component.html:12:  <cc-asset-list></cc-asset-list>

# 2. La clase → el módulo que la declara
grep -rn "AssetListComponent" src/ --include="*.module.ts"
# src/app/features/assets/assets.module.ts:14:  declarations: [AssetListComponent],

# 3. Y quién puede usarla: ¿está en `exports`?
grep -n "exports" src/app/features/assets/assets.module.ts
```

**Qué descarta.** Si el paso 2 no devuelve ningún `.module.ts`, el componente **no está declarado en ninguna parte** y ése es el bug. Si está declarado en un módulo pero no exportado, sólo se puede usar dentro de ese módulo — y ésa es la causa cuando el error aparece en una plantilla de otra feature.

> 🧭 **La regla de tres frases del árbol de inyectores y declaraciones:** un componente lo ve quien lo declara y quien importa un módulo que lo exporta. Nada más. No hay alcance global, no hay herencia de declaraciones, y un `SharedModule` que reexporta media librería sólo funciona para quien importa `SharedModule`.

### Paso 3 — Si no hay error: ¿el módulo es diferido de verdad?

No se lo preguntes al código. Pregúntaselo a Network:

DevTools → **Network** → filtro `JS` → *Disable cache* activado → recarga en `/` → navega a `/assets`.

```
Name                                            Status   Type    Size      Time
src_app_features_assets_assets_module_ts.js     200      script  18.4 kB   6 ms
```

**Qué descarta.**

- **Aparece un chunk nuevo al navegar** → la carga diferida funciona. El problema está dentro del módulo o de su routing interno: paso 4.
- **No aparece nada al navegar, y el peso de `main.js` es sospechosamente grande** → el módulo se volvió *eager*: alguien lo importó desde un módulo que sí se carga al arrancar. `grep -rn "AssetsModule" src/ --include="*.module.ts"` te dice quién.
- **No aparece nada y `main.js` es normal** → la ruta no está llegando al módulo. Revisa el `loadChildren` y, sobre todo, el **orden** de las rutas: una ruta comodín (`path: '**'`) colocada antes se come todo lo que va detrás.

### Paso 4 — Dentro del módulo: el `RouterModule.forChild` y su `<router-outlet>`

Dos causas producen exactamente la misma pantalla en blanco sin ningún error:

```ts
// ❌ El módulo de feature usa forRoot() en vez de forChild(). Registra un
//    segundo router raíz; las rutas hijas no se resuelven y nadie se queja.
imports: [RouterModule.forRoot(routes)]

// ✅
imports: [RouterModule.forChild(routes)]
```

```html
<!-- ❌ El componente contenedor de la feature no tiene dónde pintar a sus hijos.
     La ruta hija se activa, el componente se construye, y no se ve. -->
<h2>Activos</h2>

<!-- ✅ -->
<h2>Activos</h2>
<router-outlet></router-outlet>
```

Y la comprobación que los distingue en un segundo, en la consola:

```js
// Si la ruta se activó, el componente existe aunque no se vea.
ng.getComponent(document.querySelector('cc-asset-list'));
// undefined  → la ruta no llegó a construirlo: es un problema de rutas
// {…}        → existe y no se pinta: falta el <router-outlet> o el CSS lo oculta
```

**Qué descarta.** `undefined` descarta el `<router-outlet>` y el CSS: el componente nunca llegó a construirse, así que el problema es de rutas y vuelves al **Paso 3** con el `forChild` delante. Un objeto descarta lo contrario —la ruta funcionó— y deja dos culpables, el outlet ausente o el estilo que lo oculta, que se confirman en el **Paso 5** contra un build de producción.

### Paso 5 — En producción: qué chunk es cuál

En desarrollo los chunks se llaman `src_app_features_assets_assets_module_ts.js` y se leen solos. En producción, con `outputHashing` puesto, se llaman `493.8a1f2c.js` y no dicen nada. Dos formas de resolverlo:

```bash
# Para una investigación puntual, si puedes construir tú:
ng build --named-chunks

# Cuando el build es de un pipeline y no lo puedes cambiar:
ng build --stats-json
grep -o '"name":"[^"]*assets[^"]*"' dist/certcore/stats.json | sort -u
```

**Qué descarta.** Con el nombre del chunk en la mano, la pregunta "¿este código viaja en el arranque?" tiene respuesta objetiva. Es la misma técnica que la **Fase 10** usa para comprobar que `jspdf` no está en `main.js` y la que la **Fase 13** usa para los presupuestos de bundle.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| `NG0304` con un selector tuyo | componente no declarado o no importado aquí | `declarations` / `exports` del módulo |
| `NG0304` con `router-outlet` | falta `RouterModule` en los `imports` | el módulo de la plantilla que falla |
| `NG0303` con `formGroup`, `ngIf`, `matInput` | falta el módulo de esa **directiva** | `ReactiveFormsModule`, `CommonModule`, `MatInputModule` |
| `part of the declarations of 2 modules` | declarado dos veces | quítalo de uno; no lo añadas a un tercero |
| Pantalla en blanco, sin error, chunk que sí carga | falta `<router-outlet>` o es `forRoot` | el componente contenedor de la feature |
| Pantalla en blanco, sin error, chunk que no carga | ruta que no llega, o comodín antes | orden de las rutas del router raíz |
| Todo carga y `main.js` pesa de más | un módulo diferido se volvió eager | `grep` del módulo en los `.module.ts` |

---

## ⚰️ Los callejones

**"Es que el componente está mal escrito."** El compilador de plantillas te habría dicho otra cosa. `NG0304` no habla del contenido del componente: habla de que **nadie lo conoce en este contexto**. Si el archivo tuviera un error de sintaxis, el build entero fallaría.

**"Lo agrego también al `SharedModule` y así lo ve todo el mundo."** Es la reacción natural al `NG0304` y produce el error de doble declaración. Y aunque funcionara, un `SharedModule` que declara componentes de features es la deuda 💸 que la Fase 1 deja puesta y la Fase 5 cobra midiendo el bundle.

**"El CSS lo está ocultando."** Se descarta con el `ng.getComponent()` del paso 4: si el componente no existe, no hay CSS que valga. Si existe, entonces sí conviene mirar el inspector de elementos — y suele ser un `height: 0` heredado del layout.

---

## 🧨 Deshacer

Si provocaste los errores a propósito, todos se revierten en el archivo donde los causaste y `ng serve` recompila solo. El único que deja rastro es `ng build`: borra `dist/` si no quieres que un `stats.json` viejo te confunda en la siguiente investigación — es exactamente la mentira de los source maps desactualizados de `forense-fase-00.md`, con otro archivo.

---

## 🧠 El patrón transferible

> **En Angular, "no se ve" y "no existe" son dos bugs distintos y se distinguen en una línea de consola.** Antes de mirar CSS, rutas o datos, pregunta si el objeto llegó a construirse. La mitad de las investigaciones terminan ahí.

Y el segundo, que vale para cualquier sistema modular: **el error te da el nombre del síntoma, no el del archivo.** El camino selector → componente → módulo son tres `grep` y siempre los mismos tres. Aprenderlo como un reflejo es lo que separa treinta segundos de veinte minutos.

**Incidentes del cuaderno que usan esta ruta:** 02 (la pantalla de activos en blanco) y 07 (el listado que rompe el panel 🧬).
**Amplía:** **A04** para el árbol de inyectores, y `forense-fase-05.md` para cuando el mismo síntoma llega desde un componente standalone.
