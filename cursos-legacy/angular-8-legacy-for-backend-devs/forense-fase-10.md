# 🕵️ Forense Fase 10 — "El dashboard se arrastra al final del turno"

> Pieza forense de la [**Fase 10 — Dashboard**](./10-dashboard.md) · Recorrido: ~50 min · [Índice del track](./forense-master.md)
> Herramientas: `console.count` · panel Performance · panel Memory (y sólo al final)
> Síntoma que cubre: una pantalla que va poniéndose lenta con las horas y se cura cerrando la pestaña.

Tres cosas distintas producen la queja "va lento", tienen tres fixes que no son intercambiables, y **el orden en que las descartas decide si esto te cuesta veinte minutos o una tarde**. La trampa de esta pieza es que la herramienta más impresionante —el heap snapshot— es la última que hay que abrir, y casi nunca hace falta.

---

## 🎫 El ticket

> *"El dashboard se pone lentísimo al final del turno. Por la mañana va bien. Si cierro el navegador y lo vuelvo a abrir, funciona otra vez un rato."*

**Reportado por:** el coordinador de turno
**Ambiente:** PROD

**"Cerrar y reabrir lo cura"** es el dato más valioso del ticket y hay que saber leerlo: descarta el servidor, los datos y la red —ninguno se arregla cerrando una pestaña— y apunta a algo que **se acumula en la memoria del navegador**. Y "por la mañana va bien" fecha el crecimiento: es proporcional al uso, no a la hora.

---

## 🧭 La ruta

Cinco pasos, y el orden es literalmente de más barato a más caro: contar cuesta una línea, mirar Network en reposo cuesta treinta segundos, el panel Performance cuesta un par de minutos, y el heap snapshot cuesta diez. **Los tres sospechosos, en orden, y el panel Memory es el último.**

### Paso 1 — Los tres sospechosos, y cómo se distinguen sin herramientas

Antes de medir nada, ten claro qué estás buscando. Un dashboard lento en este stack es una de estas tres cosas y sólo una:

| Firma | Qué se acumula | Cómo se ve |
|---|---|---|
| **Recomputación** | nada; se recalcula de más | lento desde el primer minuto, siempre igual |
| **Re-render** | nada; se redibuja de más | parpadeo al escribir o al mover el ratón en otra parte |
| **Suscripción huérfana** | canales abiertos | **empeora con el uso** y se cura cerrando la pestaña |

**Qué descarta.** El ticket dice "empeora con las horas" y "se cura cerrando la pestaña": eso apunta a la tercera y desafina las dos primeras. Pero no las elimina —pueden convivir— y por eso los pasos siguientes las comprueban de todos modos, en orden de costo.

### Paso 2 — `console.count`: la herramienta que resuelve el 80% de los casos

Una línea, dos sitios. En el cuerpo del selector y en el `ngOnInit` del componente:

```js
// Dentro del cuerpo de selectOrdersByStatusCount, temporalmente:
console.count('KPI orders');

// Y en la primera línea del ngOnInit del DashboardComponent:
console.count('dashboard ngOnInit');
```

Ahora entra y sal del dashboard cinco veces, y provoca cambios en otro slice —marca una muestra— sin volver a entrar:

```
dashboard ngOnInit: 1
dashboard ngOnInit: 2
dashboard ngOnInit: 3
dashboard ngOnInit: 4
dashboard ngOnInit: 5
KPI orders: 5          ← una por entrada… y sigue subiendo con la app cerrada
KPI orders: 6
KPI orders: 7
```

**Qué descarta.** Ésta es la salida que cierra el caso, y hay que leerla con cuidado:

- **El contador del KPI sube estando fuera del dashboard** → hay suscripciones vivas de componentes que ya no están en pantalla. **Cinco entradas, cuatro canales cada una, veinte callbacks ejecutándose sobre instancias muertas.** Ése es el leak.
- **El contador sube en cada tecla o en cada movimiento, estando dentro** → recomputación: algo llama al selector desde la plantilla, o la memoización no está funcionando porque alguien devuelve una referencia nueva siempre.
- **El contador no se mueve al cambiar otro slice** → la memoización de `createSelector` está haciendo su trabajo y esa hipótesis muere.

Y con eso ya sabes cuál de los tres sospechosos es, sin haber abierto un solo panel caro.

> 🧭 **Por qué esto va antes que el heap snapshot.** Un snapshot cuesta minutos, produce un árbol que hay que saber leer y contesta "cuánta memoria hay retenida". `console.count` cuesta una línea y contesta "cuántas veces se está ejecutando esto", que es la pregunta que de verdad tenías.

### Paso 3 — Network en reposo, por si el leak es de peticiones

Con el dashboard **cerrado** —navegado fuera— deja la pestaña Network abierta y no toques nada durante un minuto.

**Qué descarta.** Si siguen saliendo peticiones sin nadie en la pantalla, el leak no es sólo de memoria: hay callbacks vivos que además despachan acciones y llegan al servidor. En este dashboard no hay polling, así que la lista debería quedar en silencio absoluto; cualquier fila que aparezca es un canal que quedó abierto y sigue trabajando.

Es una comprobación de treinta segundos que además cambia la severidad del ticket: un leak que sólo consume memoria es un problema del navegador del coordinador; uno que además pega al servidor es un problema de todos.

### Paso 4 — El panel Performance: cuánto cuesta, de verdad

Sólo si el paso 2 apuntó a recomputación o re-render. Performance → grabar cinco segundos mientras escribes en un campo de otra parte de la pantalla → parar.

Lo que se busca no es el número de ciclos, es **el tiempo**:

```
Scripting     4.812 ms      ← lo que importa
Rendering     1.203 ms
Painting        340 ms
Idle              …
```

**Qué descarta.** Un ciclo de detección de cambios que revisa doscientos componentes **no es un problema si dura 3 ms**. La columna que decide es el tiempo, no el conteo, y ésa es la mentira característica de este panel: enseña una cantidad enorme de actividad que casi siempre es irrelevante. Abre el árbol de llamadas y busca funciones tuyas, no de Angular: si `buildOrdersChartData` o un `verdictFor` aparecen con tiempo propio acumulado, tienes recomputación desde plantilla.

### Paso 5 — El heap snapshot, y sólo ahora

El más caro y el que hay que saber ejecutar aunque casi nunca haga falta. Memory → *Heap snapshot* → **tómalo con el dashboard cerrado**, para no contar lo que está legítimamente en pantalla.

1. Snapshot 1, con la aplicación en `/patients`.
2. Entrar y salir del dashboard cinco veces.
3. Volver a `/patients`. Snapshot 2.
4. En el desplegable de comparación, **Comparison** contra el snapshot 1.

```
Constructor              # New   # Deleted   # Delta
DashboardComponent          5          0         +5
Subscriber                 20          0        +20
```

**Qué descarta.** Cinco `DashboardComponent` retenidos después de haber salido cinco veces es la prueba dura: las instancias no se liberan porque algo las referencia — y ese algo son los cuatro `Subscriber` de cada una, vivos dentro del store. Veinte suscriptores por cinco visitas. Con eso el diagnóstico está cerrado y cuantificado, que es lo que hace falta para un post-mortem.

**El fix, que depende de cuál de los tres fue.** Y no son intercambiables:

- **Suscripción huérfana** → gestión de ciclo de vida: `async` pipe, o `takeUntil(this.destroy$)` con un `Subject` que emite en `ngOnDestroy`.
- **Re-render** → datos precalculados en una propiedad, `OnPush`, o un pipe puro.
- **Recomputación** → selectores memoizados, y comprobar que nadie devuelve una referencia nueva en cada llamada.

Meter `OnPush` para arreglar un leak, o cerrar suscripciones para arreglar un re-render, es el error de diagnóstico que esta fase entrena a no cometer.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| Empeora con el uso, se cura cerrando la pestaña | suscripción huérfana | `console.count` en el `ngOnInit` |
| Lento desde el primer minuto, constante | recomputación o re-render | `console.count` dentro del selector |
| Parpadeo de gráficos al escribir en otra parte | un método de plantilla devuelve referencia nueva | el `[data]` del gráfico: ¿propiedad o método? |
| El KPI se recalcula al cambiar un slice ajeno | la memoización no aplica: entrada nueva cada vez | qué devuelve el selector de entrada |
| Peticiones saliendo con el dashboard cerrado | callbacks vivos que además despachan | Network en reposo, un minuto |
| Muchos ciclos de detección y todo va bien | no es un problema: mira el tiempo, no el conteo | la columna Scripting |
| El dashboard revienta al abrirlo como primera pantalla | slice lazy sin cargar: `undefined`, no `[]` | [`forense-fase-06.md`](./forense-fase-06.md) |
| El heap no crece pero la pantalla va lenta igual | no es un leak: es recomputación | vuelve al paso 2 |
| Todo se arregla al recargar y vuelve al rato | acumulación, no estado corrupto | el crecimiento entre dos snapshots |

---

## ⚰️ Los callejones

**"Hay que ponerle `OnPush`."** Es la primera propuesta en cualquier reunión sobre una pantalla lenta y en este caso no arregla nada: `OnPush` reduce cuántas veces se revisa la plantilla, y las suscripciones huérfanas siguen abiertas exactamente igual, ejecutando callbacks sobre componentes que ya no existen. Arregla la segunda firma, no la tercera.

**"Son demasiados datos."** Se descarta contando: cuatro KPIs sobre unas decenas de registros del semillero. Si el volumen fuera la causa, la pantalla iría igual de lenta a las nueve de la mañana — y el ticket dice lo contrario.

**"El servidor está lento."** El ticket ya lo tumbó: cerrar y reabrir el navegador no cambia nada del servidor. Y el paso 3 lo confirma desde el otro lado.

**"Empecemos por el heap snapshot."** Es la tentación de la herramienta impresionante. Un snapshot cuesta minutos, exige saber leer el árbol de retenedores, y llega a la misma conclusión que dos `console.count` puestos en treinta segundos. Úsalo para **cuantificar** algo que ya sabes, no para descubrirlo.

**"Es el `ChangeDetectionStrategy`."** En este curso casi nunca es la causa raíz y sí es la primera sospecha de mucha gente. La detección de cambios entra en la conversación cuando el selector **sí** emitió y aun así la pantalla no responde, o cuando el panel Performance muestra tiempo propio de scripting relevante. Antes de eso es ruido.

---

## 🧨 Deshacer

El recorrido añade instrumentación y deja el navegador cargado:

```bash
# Los console.count temporales del selector y del componente.
git checkout -- src/app/dashboard/dashboard.selectors.ts src/app/dashboard/dashboard.component.ts
```

Y dos avisos de higiene que importan más de lo que parece:

- **Recarga la pestaña antes de medir otra cosa.** Después de este recorrido tienes veinte suscripciones vivas que vas a arrastrar a la siguiente investigación, y van a falsear cualquier medición.
- **Un `console.log` dentro de un `map` de RxJS o de un selector es, él mismo, una causa de lentitud** cuando se olvida puesto. No es una hipótesis abstracta: es una de las razones reales por las que un sistema "va lento desde ayer".

---

## 🧠 El patrón transferible

> **Ante "va lento", la primera pregunta no es dónde, es qué se acumula.** Si algo empeora con el uso y se cura reiniciando, hay acumulación y el culpable es un recurso que nadie libera. Si va igual de lento siempre, no hay acumulación: hay trabajo de más en cada ciclo. Son dos investigaciones con dos herramientas y dos fixes distintos, y la frase del usuario —*"si lo cierro y lo abro funciona un rato"*— ya te dice cuál es antes de medir nada.

Y el segundo, que es el orden que esta pieza defiende: **contar es más barato que medir, y casi siempre alcanza.** Un `console.count` bien puesto delata una fuga en treinta segundos; el panel Memory contesta tarde y contesta otra pregunta. Guarda la herramienta cara para cuantificar lo que ya diagnosticaste — que es exactamente lo que necesitas para escribir el post-mortem.

**Incidentes del cuaderno que usan esta ruta:** el **16** —*"el dashboard se arrastra al final del turno"*—, que es este ticket con el crecimiento ya medido.
**Amplía:** el [**Apéndice A05**](./a05-rxjs.md) para `takeUntil`, el `async` pipe y por qué un `Subject` de destrucción cierra todo a la vez, y el [**Apéndice A06**](./a06-ngrx.md) para cómo funciona la memoización de `createSelector` y qué la rompe.

**📚 Las dos referencias que la §8 de la fase te manda a buscar acá:**

- https://developer.chrome.com/docs/devtools/memory-problems/heap-snapshots — cómo se toma un heap snapshot, qué significan las columnas *Shallow size* y *Retained size*, y cómo se lee la vista **Comparison** del paso 5. ⚠️ Enlace no verificado al cierre; si la ruta cambió, busca *"heap snapshot"* en la documentación de Chrome DevTools.
- https://v8.angular.io/api/core/ChangeDetectionStrategy — `OnPush` y el ciclo de detección de cambios, en la versión del curso. ⚠️ Enlace no verificado al cierre; si `v8.angular.io` no responde, la alternativa es `angular.io` marcando la versión 8 en el selector, con la advertencia de que la página por defecto documenta versiones posteriores.
