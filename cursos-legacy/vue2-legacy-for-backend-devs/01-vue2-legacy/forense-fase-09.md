# 🕵️ Forense Fase 09 — "Cambié el estado y el detalle no se enteró"

> **Sale de:** [Fase 9 — Panel de soporte](09-panel-soporte.md) ·
> **Herramientas:** Vue DevTools → Components, Network, y la consola ·
> **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el PATCH salió bien, la lista se actualizó, y
> el panel de al lado sigue mostrando lo de antes.

La Fase 9 pone dos vistas del mismo dato en la misma pantalla —la cola y el
workspace— y ahí es donde los bugs de identidad dejan de ser teóricos. Todos los
casos de esta pieza son variantes de una sola pregunta: **¿los dos paneles están
mirando el mismo objeto, o cada uno tiene el suyo?**

---

## 🎫 El ticket

> "Estoy en el panel de soporte, selecciono un ticket de la cola, le cambio el
> estado a 'Resuelto' y el ticket de la lista de la izquierda cambia bien. Pero
> el panel de la derecha, el grande, sigue diciendo 'En progreso'. Si selecciono
> otro ticket y vuelvo, ahí sí aparece bien."
>
> — agente de soporte · **Ambiente:** desarrollo

"Si selecciono otro y vuelvo, ahí sí" es la firma de una copia obsoleta: el dato
correcto existe en alguna parte, y el panel lo lee **solo cuando vuelve a
nacer**.

---

## 🧭 La ruta

Del más barato al más caro: Network descarta la escritura, DevTools compara las
dos copias, y el código es lo último.

### Paso 1 — ¿la escritura llegó?

DevTools → **Network** → filtro `XHR`, y cambia el estado.

```
Name         Status   Type   Size
tickets/12   200      xhr    486 B
```

Y en la pestaña Response:

```json
{ "id": 12, "title": "No me llega el correo", "status": "resolved",
  "assignee": "soporte1", … }
```

**Qué descarta.** Descarta el servicio, el mock y la escritura entera: el
servidor recibió el PATCH, lo aplicó y devolvió el ticket completo con
`status: "resolved"`. Todo lo que sigue pasa **dentro** del navegador. Si el
status hubiera sido 404 o el cuerpo hubiera venido a medias, ésta sería otra
investigación.

### Paso 2 — ¿quién tiene qué?

Vue DevTools → Components. Compara las tres copias que hay en pantalla:

```
<SupportView>
  data
    tickets: Array[8]              → tickets[3].status: "resolved"   ✅
    selectedTicket: { id: 12, status: "in_progress" }   ⚠️ objeto viejo

  <TicketQueue>   props.tickets[3].status: "resolved"   ✅
  <TicketWorkspace>  props.ticket.status: "in_progress" ⚠️
```

**Qué descarta.** Ahí está el caso, y no hizo falta abrir un archivo. La lista
maestra se actualizó; `selectedTicket` no. Descarta la reactividad como culpable
—la cola se enteró perfectamente— y descarta el `:key`, que en esta fase se usa
para recrear el workspace al cambiar de ticket, no para actualizarlo.

### Paso 3 — ¿es una copia o es una referencia?

La pregunta que decide el diagnóstico. En la consola:

```js
> $vm0.selectedTicket === $vm0.tickets[3]
false
```

**Qué descarta.** Cierra el caso. `selectedTicket` es un **objeto guardado**, no
una referencia viva a la lista: cuando el update reemplazó el elemento del
arreglo —`splice(i, 1, updated)`, que sí es reactivo— la lista pasó a apuntar a
un objeto nuevo, y `selectedTicket` se quedó apuntando al viejo. La fase lo dice
en sus errores comunes con todas las letras: **se guardó el objeto en vez del
id.** Con un `selectedId` y un computed que lo busque en la lista, esto no puede
pasar: hay una sola fuente y N lectores.

Si la comparación hubiera dado `true`, el problema sería otro —una mutación que
Vue no ve— y saltarías al paso 5.

### Paso 4 — el caso vecino: el workspace con datos ajenos

Otro reporte de la misma pantalla, misma familia:

```
"Al cambiar de ticket veo medio segundo los comentarios del anterior, y a veces
el textarea trae texto que yo no escribí ahí."
```

Compruébalo en DevTools mirando si el componente se recrea o se reutiliza al
cambiar de selección:

```
<TicketWorkspace>   ← la misma instancia, con la prop nueva
```

**Qué descarta.** Descarta los comentarios, el servicio y el `v-model`: el
componente **no nació de nuevo**, así que su estado local —comentarios cargados,
borrador del textarea— sobrevivió al cambio de ticket. Es lo contrario del bug
de la [Fase 6](forense-fase-06.md): allá el componente moría cuando no debía,
acá sobrevive cuando debía morir. La herramienta es la misma, `:key`, usada al
revés: `:key="selectedTicket.id"` fuerza una instancia nueva por ticket.

### Paso 5 — el silencio reactivo

Última variante, y la más muda de todas. Si el handler del update hiciera esto:

```js
onTicketUpdated: function (updated) {
  var i = this.tickets.findIndex(function (t) { return t.id === updated.id; });
  this.tickets[i] = updated;    // ⚠️ ni un error, ni un repintado
}
```

```
La lista no cambia. La consola está limpia. Network dice 200.
```

**Qué descarta.** Descarta absolutamente todo lo anterior y apunta a la
limitación de Vue 2 que la Fase 8 ya había advertido: **la asignación por índice
en un arreglo no es reactiva.** El dato está en el arreglo —compruébalo en
DevTools, ahí se ve— y nadie repinta. Se arregla con `splice`, que es uno de los
métodos parcheados, o con `Vue.set`.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| La lista se actualiza y el detalle no | `selectedTicket` guarda el objeto en vez del id |
| El detalle se actualiza al cambiar de ticket y volver | Confirma lo anterior: solo se refresca al recrearse |
| Ves medio segundo datos del ticket anterior | Falta `:key`: instancia reutilizada sin reset |
| El textarea trae texto de otro ticket | Lo mismo: estado local que sobrevivió al cambio de selección |
| Asignaste por índice y no pasó nada | Vue 2 no ve `array[i] = x`: usa `splice` o `Vue.set` |
| Vue grita que estás mutando una prop | El workspace escribe el ticket en vez de emitir hacia arriba |
| "Tomar" deja el ticket asignado pero en estado viejo | Dos PATCH encadenados en vez de uno: si van juntos, viajan juntos |
| Dos agentes toman el mismo ticket y ninguno se entera | No hay candado ni precondición: 💸 deuda, hace falta un backend |
| El ticket cambia de sección de la cola "solo" | No es un bug: es la cadena reactiva de los computed haciendo su trabajo |

---

## ⚰️ Los callejones

**"Falta recargar la lista después del PATCH."** Funciona, y es exactamente lo
que no hay que hacer: un `loadData()` después de cada escritura esconde el bug
de identidad detrás de un viaje a la red, y convierte una pantalla reactiva en
una pantalla que parpadea. Cuando veas ese reflejo en un legacy ajeno,
pregúntate qué estaba mal de verdad — casi siempre es esta pieza.

**"Es que json-server devuelve mal el PATCH."** El paso 1 lo descarta con el
cuerpo de la respuesta a la vista. Cuesta diez segundos y evita media hora de
sospechas sobre el mock, que en este proyecto casi nunca tiene la culpa porque
casi no hace nada.

**"Hay que meter el ticket seleccionado en Vuex."** No arregla nada por sí solo:
si en Vuex guardas otra vez el **objeto**, tienes el mismo bug con más
ceremonia. El problema no es dónde vive la selección, es **qué guardas**: el id
o la cosa.

---

## 🧨 Deshacer

Si reprodujiste el paso 5 a propósito:

```bash
git checkout -- src/views/SupportView.vue
```

Y si probaste tomando tickets, el `db.json` quedó con asignaciones nuevas:
`git checkout -- db.json` recupera tus escenarios; `npm run mock:reset` los
borra y regenera desde la semilla.

---

## 🧠 El patrón transferible

**Guarda identificadores, no objetos.** Un id es un puntero estable a una
verdad que vive en un solo sitio; un objeto guardado es una fotografía que
envejece sin avisar. La regla vale para la selección de una lista, para el
usuario "actual", para el ticket de un formulario y para cualquier caché que
hayas escrito en cualquier lenguaje: en cuanto hay dos copias del mismo hecho,
alguien tiene que sincronizarlas, y ese alguien se va a olvidar.

Y la segunda, específica de las pantallas maestro-detalle: **un solo camino de
escritura, N caminos de lectura.** Si el detalle escribe por su cuenta y la
lista también, no hay forma de que no discrepen. Cuando heredes una pantalla
así, dibuja las flechas antes de tocar nada: dónde se escribe, quién deriva de
qué. El bug casi siempre está en una flecha que va en los dos sentidos.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 9](09-panel-soporte.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 09](cuaderno-incidentes.md); y la misma discusión, subida a estado
global, en la [pieza de la Fase 10](forense-fase-10.md).
