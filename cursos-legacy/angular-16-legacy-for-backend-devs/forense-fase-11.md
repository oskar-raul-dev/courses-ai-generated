# 🕵️ Forense Fase 11 — "Desde ayer el panel va lentísimo"

> Pieza forense de la **Fase 11 — Dashboard y alertas** · Recorrido: ~45 min
> Herramientas: Network en reposo · `console.time` · panel Performance · Angular DevTools Profiler
> Síntoma que cubre: una pantalla lenta, con cuatro sospechosos, y un orden de descarte que separa media hora de media tarde.

Lo que hace difícil este ticket no es encontrar la causa: es **no empezar por el sospechoso equivocado**. `ChangeDetectionStrategy` es lo primero que todo el mundo mira y casi nunca es el culpable — y cambiarla a ciegas produce un bug peor, porque un `OnPush` mal puesto no va lento: va **mal**.

La fase resume los cuatro sospechosos. Aquí está el recorrido con la salida de cada paso y el criterio de decisión de cada uno.

---

## 🎫 El ticket

> *"Desde ayer el panel tarda un montón en cargar y el ventilador se dispara. Al principio del mes iba bien. Y si lo dejo abierto y me voy a comer, cuando vuelvo está peor."*

**Reportado por:** coordinador de certificaciones · **Ambiente:** UAT

Tres datos que el reporte trae sin saberlo: **"desde ayer"** (algo cambió, o algo creció), **"al principio del mes iba bien"** (el volumen de datos importa) y **"si lo dejo abierto está peor"** (se degrada con el tiempo, que apunta a fuga y no a cálculo).

---

## 🧭 La ruta: cuatro sospechosos, en este orden

El orden es la lección entera. Cuesta más descartar al cuarto que a los tres primeros juntos.

### Sospechoso 1 — Una suscripción que no murió

El más frecuente y el más barato de descartar. **Dos minutos, sin abrir el código.**

DevTools → **Network** → filtro `Fetch/XHR` → **sal del panel** → espera dos minutos sin tocar nada.

```
Name                          Status    Type    Time
certificates                  200       xhr     14 ms
inspections                   200       xhr     22 ms
certificates                  200       xhr     11 ms
inspections                   200       xhr     19 ms
…
```

**Qué descarta.** Si sigue saliendo tráfico de una pantalla que ya no está abierta, **ya lo tienes** y no hace falta nada más. Y el ritmo te dice cuántas fugas hay: si el intervalo original era de un minuto y ves tres pares de peticiones por minuto, hay tres pantallas zombis vivas.

Eso explica también la última frase del ticket: *"si lo dejo abierto está peor"*. Cada entrada al panel deja una suscripción más, y todas siguen trabajando.

**Si no sale tráfico**, pasa al 2. La ruta completa para cazar la fuga —incluido el panel Memory— está en `forense-fase-04.md`.

### Sospechoso 2 — El cálculo

Rodea el `map` de las agregaciones con un temporizador. Sin perfilador, sin instrumentación:

```ts
// Temporal, en el map de metrics$.
console.time('buildMetrics');
const metrics = buildDashboardMetrics(certificates, inspections, clients);
console.timeEnd('buildMetrics');
return metrics;
```

```
buildMetrics: 3.8 ms
buildMetrics: 4.1 ms
buildMetrics: 3.9 ms
```

**Qué descarta**, y el criterio importa más que el número:

- **Por debajo de 16 ms**, el cálculo **no es el problema**, aunque lo parezca. 16 ms es lo que dura un fotograma a 60 fps: por debajo de eso el usuario no lo puede percibir.
- **Por encima de 16 ms**, todavía no acuses: mira **cuántas veces sale por minuto**. Un cálculo de 40 ms una vez por minuto es invisible; el mismo cálculo cinco veces por segundo es una pantalla congelada.

```ts
// La segunda mitad de la medición, y la que suele dar el diagnóstico:
console.count('buildMetrics');
```

**Un cálculo barato ejecutado muchas veces es el patrón más común de este sospechoso**, y su causa casi siempre es un derivado sin compartir: cada suscriptor recalcula. Es lo que `shareReplay({ bufferSize: 1, refCount: true })` resuelve, y lo que su ausencia produce.

Y el otro caso, que conecta con el ticket: *"al principio del mes iba bien"*. Si el cálculo es O(n²) sobre certificados e inspecciones, con la semilla de seis filas no se nota y con cuatrocientas sí. Mide con el volumen de verdad, no con el de desarrollo.

### Sospechoso 3 — El gráfico

Con el panel abierto y **quieto**: DevTools → **Performance** → graba treinta segundos → detén.

Lo que buscas en la línea de tiempo:

```
Main thread
  ⌐ requestAnimationFrame    ▮  ▮  ▮  ▮  ▮  ▮  ▮  ▮      ← picos regulares
      Animation Frame Fired      cada ~16 ms, sin que nadie toque nada
```

**Qué descarta.** Picos regulares de `requestAnimationFrame` con la pantalla quieta es **una animación corriendo en bucle**. Chart.js redibuja cuando **la identidad** de sus datos cambia, no cuando cambian los valores:

```ts
// ❌ Un objeto nuevo en cada emisión: Chart.js cree que son datos nuevos y
//    reinicia la animación. Con un observable que emite seguido, no para nunca.
readonly chartData$ = this.metrics$.pipe(
  map((metrics) => ({ labels: [...], datasets: [{ data: metrics.byMonth }] })),
);

// ✅ La misma referencia, con los valores actualizados dentro, y el gráfico
//    actualizado a mano. O, más simple: `animation: false` en las opciones.
```

Es exactamente el parpadeo que la Fase 11 §5.7 arregla, visto desde el perfilador.

### Sospechoso 4 — Y **sólo ahora**, la detección de cambios

Angular DevTools → pestaña **Profiler** → graba **una interacción** → detén.

```
Change Detection cycle
  Duration: 3.2 ms          ← la columna que importa
  Components checked: 214   ← la columna que NO importa
```

**Qué descarta**, y es el criterio que hay que memorizar:

| Ciclo | Componentes revisados | Veredicto |
|---|---|---|
| 3 ms | 214 | **no es un problema.** Revisar es barato |
| 200 ms | 4 | **sí lo es**, y el culpable está **dentro** de esos cuatro |

**Un ciclo lento con pocos componentes** apunta a lo que hay dentro: un getter que calcula en cada revisión, un `*ngFor` sin `trackBy` sobre dos mil filas, una función llamada desde la plantilla.

```html
<!-- ❌ Se ejecuta en CADA ciclo de detección de cambios, decenas de veces por segundo. -->
<span>{{ calculateExpiringCount(certificates) }}</span>

<!-- ✅ Ya calculado, una vez, en el observable. -->
<span>{{ (metrics$ | async)?.expiringCount }}</span>
```

> 🧭 **La regla que se lleva el estudiante: `ChangeDetectionStrategy` es el último sospechoso, no el primero.** Cambiarla es barato de escribir y caro de depurar, porque un componente `OnPush` mal puesto **no va lento: va mal**. Deja de pintarse cuando alguien muta un array en vez de reemplazarlo, y el bug que produce no se parece en nada al que intentabas arreglar — es el de la Fase 6, y su síntoma es "la lista no se actualiza", no "el panel va lento".

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Sospechoso | Herramienta, en este orden |
|---|---|---|
| Tráfico con la pantalla cerrada | 1 · fuga | Network en reposo, dos minutos |
| Va peor cuanto más rato lleva abierto | 1 · fuga | lo mismo |
| Empeoró al crecer los datos | 2 · cálculo | `console.time` con volumen real |
| El cálculo es rápido y se ejecuta mucho | 2 · derivado sin compartir | `console.count` — falta `shareReplay` |
| Picos regulares con la pantalla quieta | 3 · gráfico | Performance, 30 s |
| El gráfico parpadea al actualizarse | 3 · identidad de los datos | la referencia del objeto de datos |
| Ciclo lento con pocos componentes | 4 · lo que hay dentro | getters y funciones en la plantilla |
| Ciclo rápido con muchos componentes | **ninguno** | no es un problema |
| La lista no se actualiza | **no es este ticket** | es `OnPush` con un array mutado — Fase 6 |

---

## ⚰️ Los callejones

**"Hay que poner `OnPush` en todo."** El callejón favorito, y es el sospechoso 4 puesto en primer lugar. Puede que ayude y puede que no cambie nada; lo seguro es que si el problema era una fuga (sospechoso 1), `OnPush` no la toca, y ahora tienes dos investigaciones abiertas en vez de una.

**"Son demasiados datos, hay que paginar."** Puede ser cierto y hay que **medirlo antes**. El `console.time` del sospechoso 2 con el volumen real contesta en un minuto. Paginar un panel que tarda 4 ms en calcular es trabajo tirado, y encima empeora la experiencia.

**"Es el navegador del usuario."** Se descarta abriendo el mismo panel en tu máquina con las mismas condiciones. Y si de verdad sólo pasa en una máquina, la pregunta siguiente es qué extensiones tiene instaladas — no es una broma: un bloqueador agresivo interceptando peticiones produce exactamente este síntoma.

**"Vamos a memorizar el cálculo."** Es el arreglo correcto **para el sospechoso 2** y ninguno de los otros tres. Aplicado a ciegas añade complejidad y no mueve la aguja, y encima esconde el problema real durante un tiempo.

---

## 🧨 Deshacer

Quita los `console.time` y `console.count` temporales antes de commitear. Si para reproducir el sospechoso 2 inflaste el `db.json` con cuatrocientas inspecciones —que es lo que la Fase 11 §5.1 te hace hacer—, **`npm run seed`** lo devuelve: un `db.json` de ese tamaño hace lentas las demás fases sin motivo, y su lentitud parece un bug.

Las grabaciones de Performance y del Profiler viven en la sesión de DevTools y no dejan nada en el proyecto.

---

## 🧠 El patrón transferible

> **Descarta por costo, no por sospecha.** Dos minutos de Network en reposo descartan el sospechoso más frecuente sin abrir nada. Diez minutos de perfilador descartan el menos frecuente. Empezar por el perfilador porque es la herramienta que suena a "rendimiento" es cómo una tarde se va sin haber descartado nada.

Y el segundo, que es el que más se olvida: **una medición sin criterio no es una medición.** El perfilador te da un número; lo que decide si ese número es un problema es saber que 16 ms es un fotograma, que revisar componentes es barato, y que la columna que importa es el tiempo y no el conteo. Sin ese criterio, cualquier número parece grande y cualquier optimización parece justificada.

**Incidentes del cuaderno que usan esta ruta:** 16 (el panel cerrado que sigue pidiendo).
**Amplía:** `forense-fase-04.md` para cazar la fuga una vez confirmada, **A06** §7 para `shareReplay` y su `refCount`, y **A07** §5 para derivar sin duplicar.
