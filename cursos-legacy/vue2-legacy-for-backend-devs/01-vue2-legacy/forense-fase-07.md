# 🕵️ Forense Fase 07 — "La pestaña se va poniendo lenta y el ventilador se dispara"

> **Sale de:** [Fase 7 — Métricas mínimas](07-metricas-minimas.md) ·
> **Herramientas:** Performance y Memory de Chrome, Vue DevTools, y la consola
> · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la aplicación funciona bien y se degrada con el
> uso, sin ningún error en ninguna parte.

Ésta es la primera investigación del curso que **no tiene un momento de fallo**.
No hay un clic que rompa nada, no hay una petición en rojo, no hay excepción: hay
una aplicación que a los diez minutos va peor que a los dos. Los bugs de
degradación se diagnostican al revés que los demás — no se busca qué se rompió,
se busca **qué se acumula**.

---

## 🎫 El ticket

> "El sistema arranca bien pero se va poniendo lento. Sobre todo si entro a la
> pantalla de métricas y salgo varias veces, después todo va pesado y a la
> laptop se le prende el ventilador. Cerrando la pestaña y abriendo de nuevo se
> arregla. No sale ningún error."
>
> — coordinadora de soporte · **Ambiente:** desarrollo y UAT

"Cerrando la pestaña se arregla" es la firma del caso: lo que sea que esté mal,
vive en la memoria del navegador y sobrevive a la navegación interna.

---

## 🧭 La ruta

Del más barato al más caro, y acá la escala es real: los dos primeros pasos son
gratis, el tercero cuesta un minuto, y el cuarto —el profiler de memoria— es la
herramienta más cara de esta fase. Casi nunca hace falta llegar a ella.

### Paso 1 — ¿el síntoma es acumulativo?

Antes de medir nada, delimita. Entra y sal de `/metrics` cinco veces y mira la
consola.

```
Uncaught Error: Canvas is already in use. Chart with ID '0' must be destroyed
before the canvas with ID 'statusChart' can be reused.
```

**Qué descarta.** Si ese error aparece, la investigación prácticamente terminó
en el primer paso: alguien está creando un chart nuevo sobre un canvas que
todavía cree tener uno vivo. Es la forma **ruidosa** del problema, y hay que
agradecerla. Si la consola está limpia y la lentitud igual crece, sigue al
paso 2: estás ante la forma silenciosa, que es la que trae el ticket de hoy.

### Paso 2 — ¿qué componente lo dispara?

Vue DevTools → **Components**, y navega adentro y afuera de `/metrics`.

```
<MetricsView>
  ├─ <MetricCard>
  ├─ <StatusDoughnut>
  └─ <AgentBarChart>
```

Con el componente del gráfico seleccionado, mira sus datos:

```
data
  chart: { canvas: canvas#statusChart, ctx: CanvasRenderingContext2D, config: {…},
           data: { datasets: Array[1], labels: Array[4] }, … }
```

**Qué descarta.** Descarta las otras vistas y, sobre todo, te da el hallazgo casi
completo. Que la instancia de chart.js **aparezca en el panel de datos** de
DevTools significa que está dentro de `data`, y por lo tanto que Vue la está
observando recursivamente: un objeto enorme, con referencias circulares al
canvas y a sus datasets internos, envuelto entero en getters y setters. Eso solo
ya explica la lentitud, y la fase lo advierte antes de escribir el componente.

### Paso 3 — ¿se destruyen los gráficos al salir?

Sin abrir el archivo, pregúntaselo al ciclo de vida:

```js
> // en la consola, con el componente montado:
> $vm0.$options.beforeDestroy
undefined
```

**Qué descarta.** Confirma la segunda mitad. Si no hay `beforeDestroy`, nadie
llama a `chart.destroy()`, y cada visita a la vista deja un gráfico zombi: sus
listeners de resize siguen atados a `window`, sus animaciones siguen agendadas y
su canvas sigue referenciado, así que el recolector de basura no puede llevarse
nada. **Ese es el ventilador.** Cinco visitas, cinco charts vivos, cinco veces
el trabajo por cada repintado.

### Paso 4 — medirlo, para poder contarlo

Ahora sí, la herramienta cara, y solo para tener el número que convence a
alguien más. DevTools → **Memory** → *Heap snapshot*: uno recién cargada la
aplicación, después entra y sal de `/metrics` cinco veces, y toma otro.

```
Snapshot 1     12.4 MB     Chart ×0
Snapshot 2     41.7 MB     Chart ×5      ← ninguno se fue
```

**Qué descarta.** Descarta cualquier duda sobre si "son imaginaciones": el
contador de instancias vivas de `Chart` no discute. Si en el snapshot 2 los
gráficos hubieran desaparecido, la lentitud vendría de otro sitio y habría que
mirar el paso 5.

### Paso 5 — ¿y si no es el chart?

Dos causas menores producen síntomas parecidos y conviene descartarlas antes de
cerrar:

```
El gráfico mide 30.000 píxeles de alto, o no se ve.
```

Eso no es un leak: es un `<canvas>` con `responsive: true` dentro de un
contenedor sin dimensiones, peleándose consigo mismo en cada repintado. Y el
otro:

```js
> $vm0.$refs.canvas
undefined
```

Si eso pasa en `created`, es que se intentó crear el gráfico antes de que
existiera el DOM. No degrada nada; simplemente no funciona. El hook correcto es
`mounted`, y la fase lo pone en su tabla de tres tablones.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| La pestaña se degrada con el uso, sin errores | Instancias de librería que nadie destruye |
| `Canvas is already in use` al volver a la vista | Falta `chart.destroy()` en `beforeDestroy` |
| Todo va lento apenas se pinta el primer gráfico | La instancia está en `data`: reactividad recursiva sobre un objeto enorme |
| El gráfico no se ve, o mide una barbaridad de alto | Canvas dentro de un contenedor sin dimensiones, con `responsive: true` |
| `this.$refs.canvas` es `undefined` | Se pidió en `created`: todavía no hay DOM |
| El gráfico no se actualiza cuando cambian los datos | Falta el `watch` sobre la prop, o falta `chart.update()` |
| Cambian los datos y el gráfico parpadea entero | Se está recreando el chart en vez de actualizarlo |
| El componente está dentro de `keep-alive` y el leak persiste | `beforeDestroy` no corre: los hooks son `activated`/`deactivated` |
| Un `setInterval` de refresco sigue vivo después de salir | Lo mismo que el chart, con otro disfraz: falta `clearInterval` |

---

## ⚰️ Los callejones

**"Son demasiados tickets, hay que paginar."** Es la hipótesis que todo el mundo
propone ante "va lento", y acá es falsa: el volumen de datos de esta fase son
decenas de tickets, y el snapshot del paso 4 muestra que lo que crece son
instancias de `Chart`, no filas. Cuando alguien diga "es el volumen", pide el
número: si el sistema va peor con **los mismos datos** que hace diez minutos, el
volumen no es la causa.

**"Es chart.js, que es pesado."** chart.js hace lo que se le pide y se va cuando
se le dice que se vaya. La librería no tiene forma de saber que tu componente
murió; ese aviso es tuyo, y tiene nombre: `destroy()`. Culpar a la librería acá
es no ver el patrón, que es lo único que se transfiere a Leaflet, FullCalendar o
cualquier otra.

**"Le pongo `Object.freeze` y listo."** `Object.freeze` sí resuelve la
reactividad recursiva de un objeto de datos —la fase lo enseña como escape— pero
no resuelve el leak: un chart congelado que nadie destruye sigue vivo, sigue
escuchando `resize` y sigue consumiendo. Son dos problemas, y arreglar uno deja
el ventilador encendido.

---

## 🧨 Deshacer

El paso 3 y el ejercicio 6 de la fase invitan a comentar el `beforeDestroy` para
ver el leak en carne propia. Para volver:

```bash
git checkout -- src/components/metrics/
```

Y recarga la pestaña con `Ctrl+Shift+R`: los gráficos zombi viven en la memoria
del navegador, no en tu código, así que un `git checkout` no se los lleva.

---

## 🧠 El patrón transferible

**Todo lo que se crea en `mounted` y vive fuera de Vue, se destruye en
`beforeDestroy`.** Es la regla de la fase, y el track forense la reformula como
método: cuando un sistema se degrada con el uso, no busques qué se rompe — busca
**qué se crea y no se destruye**. Charts, mapas, editores, `setInterval`,
listeners de `window`, suscripciones a un socket (que es la Fase 8, con este
mismo patrón puesto sobre otra librería).

Y la lección que va con ella, más incómoda: **un framework declarativo no puede
limpiar lo que no sabe que existe.** Cada vez que metas una librería imperativa
dentro de un componente estás firmando un contrato de tres tablones —crear,
actualizar, destruir— y el tercero es el único que nadie prueba, porque su
ausencia no se nota el primer día.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 7](07-metricas-minimas.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 07](cuaderno-incidentes.md); y el mismo contrato aplicado a sockets
en la [pieza de la Fase 8](forense-fase-08.md).
