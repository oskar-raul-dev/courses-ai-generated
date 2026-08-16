# 🕵️ Forense Fase 08 — "Escribo una letra y la aplicación se queda pegada" ⭐

> Pieza forense de la **Fase 8 — Formulario dinámico desde plantilla** · Recorrido: ~50 min
> Herramientas: Network en reposo · `console.count` · las claves de un `FormRecord` · `ng.getComponent($0)`
> Síntoma que cubre: tres tickets del formulario de inspección, y los tres se resuelven **mirando fuera del código**.

Un formulario construido en runtime tiene una propiedad incómoda: **su forma no está escrita en ninguna parte**. No puedes abrir el HTML y contar los campos. Por eso las tres investigaciones de esta pieza empiezan comparando el formulario con el dato que lo generó, y ninguna empieza leyendo el componente.

La fase resume las tres. Aquí están los tres tickets literales y la salida de cada paso.

---

## 🎫 Ticket A — el bucle

> *"Escribo una letra en la nota de un ítem y la aplicación se queda pegada. El ventilador del portátil se dispara. Si cierro la pestaña se arregla."*

**Reportado por:** inspector de campo · **Ambiente:** UAT · **Es el incidente 11**

## 🎫 Ticket B — el control huérfano

> *"Cambié de inspección desde el listado y me aparecieron ítems de la otra. Uno de ellos ni siquiera es de este ascensor."*

**Reportado por:** inspector de campo · **Ambiente:** UAT · **Es el incidente 10**

## 🎫 Ticket C — el error que desaparece

> *"Me sale un error rojo larguísimo en la consola cuando marco el último ítem, pero sólo en mi máquina. En el ambiente de pruebas no pasa."*

**Reportado por:** un compañero del equipo · **Ambiente:** desarrollo

---

Tres rutas, y **cuál te toca lo decide el síntoma, no el orden de lectura**: si la aplicación quieta habla con el servidor, ruta A; si falta o sobra un control, ruta B; si hay un error rojo que se va solo en el ambiente de pruebas, ruta C. Dentro de cada una los pasos van del más barato al más caro: mirar Network con la aplicación en reposo no cuesta nada y ya separa el bucle de red del de render; el experimento de la ruta C obliga a construir para producción y por eso va el último.

---

## 🧭 Ruta A — el bucle de `valueChanges`

### Paso 1 — Network con la aplicación quieta

DevTools → **Network** → filtro `Fetch/XHR` → abre la inspección → **no toques nada** → mira treinta segundos.

```
Name                Status    Type    Time
inspections/500     200       xhr     11 ms
inspections/500     200       xhr     9 ms
inspections/500     200       xhr     12 ms
inspections/500     200       xhr     10 ms
…
```

**Qué descarta.** Si con la aplicación quieta siguen saliendo `PATCH`, hay un bucle **que pasa por la red**. No hay que leer nada todavía: ya sabes que el ciclo incluye una respuesta del servidor.

Si **no** sale nada con la aplicación quieta pero la pantalla se arrastra al escribir, el bucle es **interno** —un `valueChanges` que escribe en el mismo formulario— y ni siquiera hace falta Network. Salta al paso 2.

### Paso 2 — Dos contadores, y el ciclo queda dibujado

```ts
// Temporal, en los dos extremos del sospechoso.
this.form.valueChanges.pipe(/* … */).subscribe(() => {
  console.count('valueChanges');
});

// …y en el next del guardado:
next: () => console.count('guardado ok'),
```

```
valueChanges: 1
guardado ok: 1
valueChanges: 2      ← el guardado disparó otro valueChanges
guardado ok: 2
valueChanges: 3
…
```

**Qué descarta.** Los dos crecen a la vez y sin parar: **el ciclo pasa por el guardado**. Si sólo crece `valueChanges`, el bucle no llega a la red y el culpable es algo que escribe en el formulario dentro de la propia suscripción.

### Paso 3 — El ciclo, dibujado, y las dos formas de romperlo

```
1. El inspector escribe una letra.  →  valueChanges emite.
2. Pasa el debounce, sale el PATCH, el servidor responde con la inspección guardada.
3. "Para que quede sincronizado", alguien parchea el formulario con la respuesta.
4. patchValue dispara valueChanges.  →  vuelve al 2.
```

Cierra perfecto y **no da ningún error**. Lo que se ve es la aplicación arrastrándose y la pestaña de Network llenándose sola.

```ts
// ❌ El arreglo que parece obvio: apagar la emisión.
this.form.patchValue(saved.answers, { emitEvent: false });
```

Funciona, y sigue siendo mala idea: estás **pisando lo que el inspector tenía escrito** con lo que el servidor te devolvió. Si escribió algo durante el viaje de red, se pierde. Cambias un bug ruidoso por uno silencioso.

```ts
// ✅ El arreglo correcto: después de guardar, el formulario no se toca.
next: () => { this.lastSaved = serializeAnswers(answers); },
```

**El servidor confirma; no dicta.** El único `patchValue` de esta pantalla es el de la carga inicial — y ni siquiera hace falta, porque el formulario se construye ya con los valores dentro.

> ⚠️ **Y una causa del mismo bucle que no es un `patchValue`:** `disable()` y `enable()` **también disparan `valueChanges`** salvo que les pases `{ emitEvent: false }`. Un ítem que se deshabilita según lo que el inspector responda en otro produce exactamente este ticket, y el `patchValue` culpable no aparece por ninguna parte.


**Aquí termina la ruta A.** El bucle está localizado y tiene dos formas de romperse, las dos escritas arriba. Si tu síntoma no era la aplicación hablando sola sino un control que falta o sobra, la tuya es la **ruta B**.

---

## 🧭 Ruta B — el control huérfano

### Paso 1 — Compara las claves del formulario con los ítems de la plantilla

Con la pantalla abierta: inspector → selecciona el `<form>` → consola.

```js
const component = ng.getComponent($0);

// Las claves del FormRecord: un control por ítem, con el itemId como clave.
Object.keys(component.currentView.form.controls);
// ['main-cable', 'emergency-brake', 'door-sensor', 'pressure-valve']

// Los ítems de la plantilla que la inspección guardó:
component.currentView.template.items.map((item) => item.id);
// ['main-cable', 'emergency-brake', 'door-sensor']
```

**Qué descarta.** `pressure-valve` sobra, y **su nombre te dice de dónde vino**: es un ítem de `boiler-annual`, la plantilla de calderas. Este formulario no se reconstruyó al cambiar de inspección: se le añadieron los controles de la nueva encima de los de la anterior.

Las tres lecturas posibles de una clave sobrante:

| La clave sobrante es… | Qué pasó | ¿Bug? |
|---|---|---|
| un `itemId` de **otra plantilla** | el formulario no se reconstruyó | **sí** — es el incidente 10 |
| un `itemId` de la **misma familia**, retirado en una versión posterior | es una respuesta de un ítem que ya no existe | **no** — es correcto, y se pinta como "ítem retirado" |
| un `itemId` que no existe en ninguna plantilla | el dato está corrompido | **sí**, y el bug no está en el frontend |

### Paso 2 — Y la comprobación gemela: la versión

Si el formulario tiene los ítems correctos pero con los **títulos** equivocados, el problema no es el `FormRecord`: es qué plantilla se usó para construirlo, y eso es `forense-fase-07.md` paso 2. La Fase 8 §5.3 lo avisa por escrito:

```ts
/**
 * ⚠️ `template` tiene que ser la versión que la inspección guardó, obtenida con
 * `getByVersion(inspection.templateId, inspection.templateVersion)`. Si le pasas
 * la vigente, esta función construye un formulario perfectamente válido con la
 * plantilla equivocada y nadie se entera.
 */
```

**Un formulario dinámico construido con la plantilla equivocada no falla: funciona.** Ése es el peligro entero.

**Qué descarta.** Si las claves del formulario son las de otra versión, descarta el bucle de la ruta A y el `NG0100` de la ruta C: no es un problema de emisión ni de detección de cambios, es que el formulario se construyó con la plantilla que no era. El **Paso 3** dice por qué eso se arregla rehaciendo el `FormRecord` y no parcheándolo.

### Paso 3 — Por qué el `FormRecord` se rehace y no se parchea

```ts
// ❌ Añadir los controles de la inspección nueva sobre el formulario que había.
for (const item of template.items) {
  this.form.addControl(item.id, buildItemGroup(item, /* … */));
}
// addControl() NO reemplaza si la clave existe, y NO quita las que sobran.

// ✅ Un formulario nuevo por inspección. Es una función pura: dale los datos y
//    devuelve un formulario. No hay estado que arrastrar.
const form = buildAnswerForm(template, inspection.answers);
```

> 🧭 **La regla del proyecto que evita esta familia entera: la clave es el `itemId`, nunca la posición.** Con `FormArray` indexado por posición, reordenar los ítems en una v3 desplazaría las respuestas de todo el mundo. Con `FormRecord` y el `itemId` como clave no hay nada que desplazar — y además, la diferencia entre las claves del formulario y los ítems de la plantilla delata al huérfano en una línea, que es justo lo que acabas de hacer.


**Aquí termina la ruta B.** El control huérfano está explicado y con él la regla que evita la familia entera. Si además veías un error rojo que desaparece al desplegar, queda la **ruta C**.

---

## 🧭 Ruta C — `NG0100`, y su desaparición

### Paso 1 — Leer el error entero, que sí dice lo que pasa

```
ERROR Error: NG0100: ExpressionChangedAfterItHasBeenCheckedError:
Expression has changed after it was checked. Previous value for 'ngIf': 'false'.
Current value: 'true'. Expression location: InspectionFormComponent component.
Find more at https://angular.io/errors/NG0100
```

**Qué descarta.** El mensaje trae las tres cosas que hacen falta: **qué expresión** (`ngIf`), **qué valores** (`false` → `true`) y **qué componente**. No hace falta el stack. Lo que dice es: durante el ciclo de detección de cambios, algo cambió un valor **después** de que Angular ya lo hubiera comprobado.

En este formulario el sospechoso es siempre el mismo: un cálculo de progreso o de validez que se dispara desde la propia plantilla y muta algo que la plantilla ya leyó.

### Paso 2 — El experimento que enseña la lección de verdad

```bash
ng build --configuration production
npx http-server dist/certcore -p 8081
```

Repite el gesto exacto que lo provocaba.

**El error no aparece.** `NG0100` sólo existe en desarrollo: es una comprobación doble que Angular hace y que en producción se apaga.

**Y ésta es la parte importante:** lo que no aparece **tampoco** es el valor actualizado. El bug sigue estando —la pantalla muestra un dato viejo— y ahora no hay nada que te avise. En desarrollo tenías un error rojo y ningún problema visible; en producción tienes un problema visible y ninguna pista.

> 🧠 **Guarda esa sensación.** En la Fase 13 vas a ver la versión general del mismo fenómeno: el build de producción no arregla nada, sólo deja de contártelo. Un `NG0100` que "se arregló solo" al desplegar es un bug que acaba de volverse invisible.


**Aquí termina la ruta C.** Y termina con la conclusión incómoda: el `NG0100` no se arregló, dejó de contarse. El bug que lo producía sigue ahí y ahora es silencioso, que es exactamente lo que la Fase 13 vuelve a enseñar con el build de producción.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Ruta | Primera comprobación |
|---|---|---|
| Peticiones sin parar con la aplicación quieta | A | Network en reposo, treinta segundos |
| La pantalla se arrastra al escribir y no hay tráfico | A, bucle interno | dos `console.count` |
| Aparecen campos que no son de esta inspección | B | claves del `FormRecord` frente a ítems de la plantilla |
| Los ítems son correctos y los títulos no | 07 | la URL de `/templates` |
| Un ítem aparece marcado como retirado | **no es un bug** | es una respuesta de un ítem que ya no existe |
| `NG0100` en desarrollo | C | lee la expresión y el componente del mensaje |
| `NG0100` que desapareció al desplegar | C | no se arregló: dejó de avisarte |
| El autosave guarda dos veces lo mismo | A | falta `distinctUntilChanged` **con comparador** |
| El autosave no guarda nunca más tras un fallo | — | `catchError` en el pipe externo — **A06** §6 |

---

## ⚰️ Los callejones

**"Es que `debounceTime` es muy corto."** Subirlo hace que el bucle sea más lento, no que desaparezca. Si el ciclo se realimenta, con 1500 ms tienes una petición cada segundo y medio para siempre. Un debounce nunca arregla un bucle: lo espacia.

**"Le pongo `{ emitEvent: false }` a todo."** Apaga el síntoma en varios sitios a la vez y deja el formulario silenciado de formas que nadie recuerda seis meses después. Además pierde escritura del usuario (ruta A, paso 3). Se usa donde hay una razón concreta, no como política.

**"Hay que limpiar el formulario al cambiar de inspección."** Medio callejón: es el arreglo correcto **si** se hace reconstruyéndolo entero, y es un parche frágil si se hace quitando controles a mano — porque hay que acertar cuáles quitar, y ésa es la lista que ya estaba mal.

**"El `NG0100` es un bug de Angular."** No: es Angular avisando de un bug tuyo, y sólo lo hace en desarrollo por cortesía. El experimento del paso 2 de la ruta C lo demuestra en dos minutos.

---

## 🧨 Deshacer

Quita los `console.count` antes de commitear. Si para reproducir la ruta B alteraste el `templateId` o el `templateVersion` de una inspección en el `db.json`, **`npm run seed`**: una inspección apuntando a una plantilla que no le corresponde rompe la Fase 9 y la Fase 10 con síntomas que no se parecen a éste.

El `dist/` del paso 2 de la ruta C se puede borrar (`rm -rf dist/`).

---

## 🧠 El patrón transferible

> **Un formulario construido desde datos se depura comparándolo con los datos, no leyéndolo.** Sus claves tienen que ser exactamente las del origen. Esa comparación cabe en dos líneas de consola y localiza en un segundo lo que leyendo el componente cuesta media hora.

Y el segundo, que se lleva a cualquier interfaz reactiva: **si un efecto puede disparar la causa que lo produjo, tienes un bucle aunque hoy no se note.** El dibujo de cuatro pasos de la ruta A se hace en una servilleta antes de escribir el código, y es lo único que lo evita de verdad. Después, cuando ya está escrito, lo que queda es Network en reposo.

**Incidentes del cuaderno que usan esta ruta:** 10 (los ítems de otra inspección, que es de versionado) y 11 (el bucle).
**Amplía:** **A05** §4 y §8 para `FormRecord` y los formularios que no se conocen en compilación, **A06** §5 para `debounceTime` + `distinctUntilChanged`, y `forense-fase-07.md` cuando lo que falla es la versión y no la forma.
