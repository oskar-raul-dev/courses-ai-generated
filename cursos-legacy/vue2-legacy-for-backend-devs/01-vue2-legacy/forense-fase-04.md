# 🕵️ Forense Fase 04 — "Cambié el filtro y la tabla se quedó igual" ⭐

> **Sale de:** [Fase 4 — Dashboard de tickets](04-dashboard-tickets.md) ·
> **Herramientas:** Vue DevTools → Components, Network (para descartarla) y
> `git log -S` · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el control cambia, el estado cambia, y lo que
> se pinta se quedó en la versión anterior.

Es una de las tres piezas estrella del curso, y la que más veces vas a
reencontrar en un legacy ajeno. El bug no es de Vue: es de **arquitectura de
estado**. Alguien guardó un dato derivado como si fuera un dato crudo, y a
partir de ahí el sistema tiene dos verdades que hay que sincronizar a mano —y
la mano se olvida.

---

## 🎫 El ticket

> "Pongo el filtro en 'Abiertos' y la tabla no cambia, sigue mostrando todo. Si
> además escribo algo en el buscador, ahí sí se actualiza y entonces el filtro
> de estado se aplica bien. O sea que funciona, pero hay que hacerle dos cosas
> para que haga una."
>
> — coordinadora de soporte · **Ambiente:** desarrollo

Ese "si además escribo algo, ahí sí" es el dato de oro del reporte: **un
control funciona y el otro no**, y los dos alimentan la misma tabla. Cuando dos
entradas al mismo cálculo se comportan distinto, el cálculo no es un cálculo:
es una copia que alguien actualiza a veces.

---

## 🧭 La ruta

De lo más barato a lo más caro: mirar el estado en DevTools cuesta un clic;
buscar quién lo escribe cuesta un `grep`; abrir el archivo es lo último.

### Paso 1 — ¿la tabla está recibiendo datos distintos?

Vue DevTools → **Components** → selecciona `<TicketsTable>` y mira sus props
antes y después de cambiar el `<select>` de estado.

```
props
  tickets: Array[8]      ← antes de filtrar
  tickets: Array[8]      ← después de elegir "Abiertos"
```

**Qué descarta.** Descarta a `TicketsTable` entera —el `v-for`, el `:key`, el
`v-if` del estado vacío— y descarta la plantilla del padre. El componente pinta
fielmente lo que le llega; lo que le llega no cambió. El problema está aguas
arriba, en quien produce esa prop.

### Paso 2 — ¿es un `computed` o es un `data`?

Con `<TicketsView>` seleccionado, mira el panel: DevTools separa `data` de
`computed` en dos secciones distintas, y ahí está el hallazgo.

```
data
  tickets: Array[8]
  search: ""
  statusFilter: "open"
  filteredTickets: Array[8]      ← ⚠️ esto no debería estar acá

computed
  (vacío)
```

**Qué descarta.** Descarta la reactividad de Vue: `statusFilter` **sí** cambió a
`"open"`, así que el `v-model` funcionó y el sistema reactivo hizo su trabajo.
Lo que no ocurrió es el recálculo, porque `filteredTickets` no se calcula: se
guarda. Un `computed` se marca sucio cuando cambia cualquier dependencia que
leyó; un `data` solo cambia si alguien le asigna.

### Paso 3 — ¿quién le asigna, y cuándo?

No abras todavía el componente: pregúntale a git quién toca esa variable.

```bash
git log --oneline -S "filteredTickets"
```

```
a3f9c21 f04 ej19: debounce en la búsqueda
7b2e5d4 f04: dashboard con filtros
```

Y en el archivo, solo la parte que asigna:

```bash
grep -n "filteredTickets" src/views/TicketsView.vue
```

```
42:      filteredTickets: [],
88:    search: function (value) {
93:        this.filteredTickets = this.tickets.filter(…);
```

**Qué descarta.** Cierra el caso: hay **un** watcher, y vigila **una** entrada.
`search` tiene quien lo escuche; `statusFilter` no. Por eso teclear en el
buscador "arregla" el filtro de estado: el watcher de `search` recalcula todo,
incluida la condición de estado que ya estaba puesta. El bug no es que el filtro
de estado no funcione, es que **nadie le avisa a la copia**.

### Paso 4 — ¿es filtrado de cliente o de servidor?

Antes de proponer un arreglo, mira Network mientras cambias el `<select>`.

```
(sin peticiones nuevas)
```

**Qué descarta.** Descarta el mock y el servicio: en esta fase el filtrado es
**en el cliente**, sobre el arreglo que ya está en memoria — la fase lo compara
con el filtrado en servidor en su sección ⚖️. Si hubieras visto un `GET
/tickets?status=open` en Network, la investigación se iría a otra parte
completamente: a los params del servicio.

### Paso 5 — ¿cuántas copias hay en total?

Con el patrón identificado, vale diez segundos preguntarse si es el único caso:

```bash
grep -rn "watch:" src/views src/components
```

```
src/views/TicketsView.vue:87:  watch: {
```

**Qué descarta.** Descarta —o confirma— que sea un incidente aislado. Un
proyecto con un watcher que sincroniza un derivado suele tener tres, y el
siguiente reporte va a ser el mismo síntoma con otro control. Acá termina el
recorrido: ya sabes **dónde** y **por qué**. El fix es de la fase: el derivado
vuelve a ser un `computed` y el watcher desaparece.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Cambias un filtro y la tabla no reacciona; otro filtro sí | Estado derivado en `data` con watchers parciales |
| La tabla se actualiza "con un cambio de retraso" | El watcher escribe antes de que la dependencia termine de cambiar |
| El contador "Mostrando X de Y" no coincide con las filas | Dos consumidores leyendo copias distintas del mismo derivado |
| Las filas conservan estado al reordenar o filtrar | `:key` ausente o puesto sobre el índice del `v-for` |
| Vue grita en consola que estás mutando una prop | El hijo escribe lo que debería emitir hacia arriba |
| Tabla vacía sin mensaje, que parece rota | Falta el estado vacío. No es un bug, y hay que demostrarlo |
| Al teclear se siente pesado con muchos tickets | El computed recalcula por tecla: es correcto, y pide debounce |
| Cambia la URL con los filtros pero no la tabla | Los query params se leen en `mounted` y nadie los vuelve a mirar |

---

## ⚰️ Los callejones

**"Falta el `:key` en el `v-for`."** Es el reflejo más común ante cualquier
problema de listas, y acá es falso: el `:key` decide **qué fila es cuál** cuando
la lista cambia, no **cuántas filas hay**. La evidencia que lo tumba está en el
paso 1: la prop llegó con la misma longitud. Si el problema fuera el `:key`,
verías el número correcto de filas con el contenido mezclado.

**"Es la reactividad de Vue 2, que no ve el cambio."** Tentador, porque la Fase 9
enseña que Vue 2 tiene puntos ciegos de verdad. Pero acá no aplica: el paso 2
muestra `statusFilter` con su valor nuevo, así que Vue vio el cambio
perfectamente. Vue no falló; falló la cadena que va del dato al derivado.

**"Le pongo un `this.$forceUpdate()` y sigue."** Funciona, y es la peor decisión
posible: repinta el componente con la copia vieja recalculada por casualidad, y
convierte un bug reproducible en uno intermitente. Cuando encuentres un
`$forceUpdate` en un proyecto ajeno, casi siempre estás mirando la cicatriz de
este mismo caso.

---

## 🧨 Deshacer

Si llegaste acá desde el ejercicio de "rompe a propósito" de la fase, o desde el
incidente 04:

```bash
git checkout -- src/views/TicketsView.vue
```

Y si prefieres verlo al revés —convertir el `computed` correcto en un `data` con
watcher para sentir el bug en carne propia—, hazlo en una rama:

```bash
git switch -c experimento/estado-duplicado
```

---

## 🧠 El patrón transferible

**Todo dato que se puede calcular y además se guarda es un bug esperando su
turno.** No importa el framework: en Vue se llama `computed` contra `data`, en
React `useMemo` contra `useState`, en un backend una vista materializada contra
una consulta — el problema es idéntico, y el síntoma también: dos verdades que
alguien tiene que sincronizar, hasta que se olvida de una entrada.

La pregunta que resuelve esta familia entera de bugs, y que conviene hacerse
antes de escribir el código: **¿este valor es un hecho o es una consecuencia?**
Los hechos se guardan. Las consecuencias se calculan, siempre, aunque cueste.

Y la señal para reconocerlo en un legacy ajeno, sin leer una línea: cuando un
control funciona y otro que alimenta lo mismo no, deja de buscar el bug del
control. Busca la copia.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 4](04-dashboard-tickets.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 04](cuaderno-incidentes.md); y el mismo patrón, con Vuex de por
medio y a mayor escala, en la [pieza de la Fase 10](forense-fase-10.md).
