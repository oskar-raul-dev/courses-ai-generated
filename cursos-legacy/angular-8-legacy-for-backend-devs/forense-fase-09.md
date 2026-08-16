# 🕵️ Forense Fase 09 — "El informe salió con un dato que ya no es el actual"

> Pieza forense de la [**Fase 9 — Entrega y PDF en cliente**](./09-entrega-pdf.md) · Recorrido: ~40 min · [Índice del track](./forense-master.md)
> Herramientas: el store frente a la propiedad del componente · un breakpoint · el PDF descargado
> Síntoma que cubre: dos partes de la misma pantalla mostrando dos verdades distintas, sin ningún error.

Hasta acá, cuando la pantalla y el store discrepaban, el culpable estaba entre los dos. En esta pieza el store está bien, la pantalla está bien, y lo que sale mal es **un archivo**. El dato equivocado no vive en ninguna de las capas que has aprendido a mirar: vive en una propiedad local de un componente, que nadie inspecciona nunca porque no aparece en ninguna herramienta.

Rastrear **en qué instante se tomó la foto** es todo el recorrido.

---

## 🎫 El ticket

> *"Corregimos el valor de un resultado y volvimos a bajar el informe. El PDF sigue trayendo el número viejo. En la pantalla se ve el nuevo."*

**Reportado por:** una analista de resultados
**Ambiente:** UAT

El ticket trae, sin saberlo, el diagnóstico entero: **"en la pantalla se ve el nuevo"**. Eso descarta el servidor, el store y la carga de datos de un plumazo — si estuvieran mal, la pantalla también lo estaría. Lo que queda es que la pantalla y el PDF no están leyendo lo mismo.

---

## 🧭 La ruta

Cinco pasos. Los tres primeros son comparaciones y no cuestan nada; el cuarto es el único que necesita un breakpoint, y es donde aparece la evidencia definitiva.

### Paso 1 — Reproducir con precisión: el orden de los actos importa

Este bug **no se reproduce** si haces las cosas en el orden natural. Hay que abrir la vista **primero** y cambiar el dato **después**, sin recargar:

1. Abre la vista de informe de un resultado validado (`/reports/9002`). No generes el PDF todavía.
2. Sin salir de la vista, en Redux DevTools despacha `enterResult` con ese `resultId` y un `value` bien distinto —de 105 a 250, para que hasta el veredicto cambie—.
3. Ahora sí, genera el PDF.

```
Pantalla:  value 250 · veredicto "crítico"
PDF:       value 105 · veredicto "dentro de rango"
```

**Qué descarta.** Muere "el PDF se genera mal": el PDF se genera perfectamente, con otros datos. Y muere "hay que recargar": recargar **arregla** el síntoma, y por eso el ticket dice "a veces" — quien recarga por costumbre no lo ve nunca. Que la reproducción dependa del orden de los actos ya es un dato: el valor se capturó en algún momento anterior.

### Paso 2 — ¿Qué dice el store en este instante?

Redux DevTools → **State**, sin tocar nada más:

```json
{
  "results": {
    "items": [
      { "id": 9002, "analyte": "tsh", "value": 250, "status": "validated", … }
    ]
  }
}
```

**Qué descarta.** El store dice 250. La pantalla dice 250. El PDF dice 105. **El store no es la fuente del PDF**, y ahí se acaba la mitad de las hipótesis: no es el reducer, no es el effect, no es el servidor, no es la caché HTTP.

Y aparece la trampa de esta pieza, que conviene nombrar ya: si sólo miras Redux DevTools, ves 250 y **asumes que todo el mundo ve 250**. La herramienta no te está mintiendo; le estás preguntando por algo que ella no gobierna.

### Paso 3 — ¿De dónde saca el PDF sus datos?

Un `grep` y una lectura de tres líneas:

```bash
grep -n "reportSnapshot" src/app/reports/report/report.component.ts
# 196:  reportSnapshot: any = null;
# 220:        if (!resultsState || this.reportSnapshot) {
# 253:        this.reportSnapshot = {
# 295:    if (!this.reportSnapshot) { return; }
# 296:    this.reportService.generate(this.reportSnapshot);
```

**Qué descarta.** El servicio que arma el PDF recibe `reportSnapshot`, no el store. Ese objeto es una **copia**, y la línea 220 es el bug hecho código:

```typescript
if (!resultsState || this.reportSnapshot) {
  return;                    // ya hay foto: no se refresca nunca más
}
```

Y acá está la crueldad del diseño, que merece leerse despacio: **la suscripción está viva**. No hay `take(1)`. El store sigue emitiendo valores frescos y el callback sigue ejecutándose con cada uno — y el `return` los descarta todos. Un lector apurado ve una suscripción abierta y asume datos frescos. La mentira no está en la suscripción: está en el `return`.

### Paso 4 — La evidencia: el breakpoint en `onGenerate`

Es el único paso caro y vale la pena porque cierra el caso sin margen de duda. Sources → `report.component.ts` → breakpoint en la línea de `this.reportService.generate(...)` → pulsa Generar → en la consola, con la ejecución detenida:

```js
this.reportSnapshot.value
// 105

// Y al mismo tiempo, lo que el store tiene ahora mismo:
// (panel State de Redux DevTools, en otra pestaña)
// results.items[0].value  ->  250
```

**Qué descarta.** Dos valores simultáneos, en el mismo instante, dentro del mismo componente. El diagnóstico está cerrado: **el lugar correcto donde mirar no era el estado global, sino la propiedad local que nadie refresca.**

Con eso la ruta termina. Y termina en un sitio que no aparece en ninguna herramienta del navegador: ni Redux DevTools ni Network conocen las propiedades de un componente, y por eso este bug sobrevive tanto tiempo en cualquier sistema.

### Paso 5 — Si el PDF sale mal pero **no** por el dato

Antes de dar el caso por cerrado, descarta el otro fallo de esta fase, que se reporta con palabras parecidas y no tiene nada que ver. Abre el PDF y mira los acentos:

```
Résultat        ← con símbolos raros
Référence       ← bien
```

**Qué descarta.** Si sólo se rompe el texto de **arriba**, no es codificación ni idioma: es orden de llamadas. `setFont` sólo afecta a lo que se dibuja **después**, así que un `registerLatinFont(doc)` colocado tras el primer `doc.text(...)` deja el encabezado en Helvetica y el resto en Roboto. Y si se rompen **todos** los acentos, la fuente no llegó a registrarse: el `.ttf` no viajó en el bundle, o el nombre de familia no coincide con el del `setFont`. Eso es el [**Apéndice A08 §3 y §5**](./a08-pdf-cliente.md), y no comparte una sola línea de causa con la foto vieja.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| PDF con dato viejo, pantalla con dato nuevo | `reportSnapshot` congelado al abrir la vista | la propiedad del componente, con un breakpoint |
| El síntoma desaparece si recargas | el componente se reconstruye y toma la foto de nuevo | el orden de los actos de la reproducción |
| El PDF trae el analito equivocado | se buscó por posición y no por id | el `find` del componente: `items[0]` frente a `r.id === …` |
| El veredicto del PDF no coincide con el de la pantalla de hoy | el informe usa `rangeVersionApplied`, no el rango vigente | correcto por diseño: reproduce el juicio original |
| Acentos rotos sólo en el encabezado | `registerLatinFont` después del primer `text` | el orden de llamadas en el servicio |
| Acentos rotos en todo el documento | la fuente no se registró o no viajó | [**A08 §5**](./a08-pdf-cliente.md), y el nombre de la familia |
| No aparece el botón de generar | el resultado no está `validated` | `status` del resultado en el store |
| No aparece el botón y el resultado sí está validado | el resultado no llegó al store | ¿se despachó `loadResults`? |
| "Entregar no hace nada" | la orden no está en `complete`: la guarda la rechazó | el `status` de la orden — no es un bug |
| Entregar no hace nada y la orden **sí** está en `complete` | el effect no está registrado en ese módulo | el `EffectsModule.forFeature` del `OrdersModule` |
| `canDeliver` siempre falso viniendo por enlace directo | el slice `orders` no existe: `undefined`, no vacío | [`forense-fase-06.md`](./forense-fase-06.md) |

---

## ⚰️ Los callejones

**"El PDF cachea."** No hay caché en juego: cada `onGenerate` construye un documento nuevo desde cero con `new jsPDF()`. Lo que persiste no es el documento, es el objeto del que se dibuja. Buscar una caché —del navegador, de la librería, del servicio— es la vía más rápida de perder media hora.

**"La suscripción se rompió."** Es la hipótesis más razonable y está deliberadamente saboteada por el propio código: la suscripción **está viva y se sigue ejecutando**. Compruébalo poniendo un `console.count` en la primera línea del callback y despachando `enterResult` tres veces — cuenta tres. El canal funciona; lo que no funciona es lo que hay dentro.

**"Hay que ponerle `take(1)`."** Sería honesto —al menos el código diría lo que hace— y no arregla nada: el snapshot seguiría tomándose una sola vez, al abrir. El `take(1)` que sí arregla es otro y va en otro sitio: dentro de `onGenerate`, leyendo el store en el instante de generar. Son dos líneas casi idénticas con efectos opuestos, y confundirlas es fácil.

**"El servidor devolvió el valor viejo."** Se descarta antes de abrir Network, con el propio ticket: la pantalla muestra el nuevo, y la pantalla lee del mismo store que se llenó desde el mismo servidor. Si el servidor mintiera, mentiría para los dos.

---

## 🧨 Deshacer

El recorrido cambia un dato real y descarga archivos:

```bash
npm run seed        # devuelve el resultado a su valor sembrado
```

Y tres avisos pequeños que ahorran confusión después:

- **Los PDF descargados se acumulan** con el mismo nombre y el navegador va numerándolos. Al comparar "el viejo" con "el nuevo", asegúrate de estar abriendo el que crees; borra la carpeta de descargas de la investigación antes de empezar.
- **Si comentaste `registerLatinFont(doc)`** para ver los acentos rotos, descoméntalo.
- **Quita el breakpoint** antes de seguir. Un breakpoint olvidado en `onGenerate` convierte la siguiente investigación en un misterio de treinta minutos.

---

## 🧠 El patrón transferible

> **Cuando dos partes de la misma pantalla muestran dos verdades, pregunta de qué fuente lee cada una.** No hay bug en ninguna de las dos: hay dos fuentes donde se creía que había una. La copia local es el patrón más común —una propiedad, una variable de módulo, un objeto que se pasó por valor— y es invisible para las herramientas que inspeccionan estado global. Ahí sólo llega un breakpoint.

Y el segundo, que es lo que este código enseña mejor que ninguna explicación: **una suscripción viva no garantiza datos frescos.** Lo que decide es qué hace el callback con lo que recibe. Un `if` con un `return` al principio puede volver sorda una suscripción perfectamente sana, y desde fuera —desde el diagrama, desde la revisión de código apurada— las dos se ven idénticas.

**Incidentes del cuaderno que usan esta ruta:** el **14** —*"el informe salió con un resultado que ya había cambiado"*, que es este ticket tal cual— y el **15** —*"los acentos del informe en francés salen como símbolos raros"*, que entra por el paso 5.
**Amplía:** el [**Apéndice A08**](./a08-pdf-cliente.md) para el registro de fuentes en el VFS de jsPDF 1.5.3 y las tres formas de que el `.ttf` no viaje, y la [**Fase 8**](./08-resultados-rangos.md) para por qué el informe usa la versión de rango congelada y no la vigente.
