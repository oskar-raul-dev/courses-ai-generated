# 🕵️ Forense Fase 08 — "Tomé el ticket y a mi compañero le sigue apareciendo libre" ⭐

> **Sale de:** [Fase 8 — WebSockets mínimos](08-websockets-minimos.md) ·
> **Herramientas:** Network → **WS**, dos navegadores, la consola del servidor
> de sockets · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** una pantalla se enteró y la otra no, y las dos
> creen tener la verdad.

Es la pieza estrella del curso, y no por dificultad técnica: es la única donde
el recorrido termina **encontrando una deuda 💸 que el material te había
declarado cien líneas antes**, y que probablemente leíste sin entender del todo.
Descubrirla depurando es otra cosa que leerla.

---

## 🎫 El ticket

> "Tomé el ticket #0412 hace como cinco minutos y aparece asignado a mí,
> perfecto. Pero Ana me dice que en su pantalla el ticket sigue apareciendo sin
> asignar, en la cola de pendientes. Ella no lo ha refrescado. Los tickets
> nuevos sí le aparecen solos, eso funciona bien, es cuando uno los toma que no
> se entera."
>
> — agente de soporte · **Ambiente:** desarrollo y UAT

El reporte trae el experimento de control ya hecho, y hay que aprovecharlo: **la
creación sí se propaga y la asignación no.** Eso descarta de entrada la conexión,
el servidor y la librería — si nada llegara, tampoco llegarían los tickets
nuevos.

---

## 🧭 La ruta

Del más barato al más caro: recargar la otra pestaña cuesta un segundo, mirar
los frames del socket cuesta un clic, y solo al final hace falta abrir código.

### Paso 1 — ¿es que no se propagó, o es que no se pintó?

En el navegador de Ana, sin tocar nada más, recarga con F5.

```
El ticket aparece asignado, en la cola correcta.
```

**Qué descarta.** Es el desempate más barato del track y separa dos
investigaciones completamente distintas. El dato **sí** está guardado: el PATCH
llegó a json-server y la lectura fresca lo confirma. Lo que falló es la
propagación en vivo, no la escritura. Si tras recargar el ticket siguiera libre,
esta pieza no aplicaría y habría que ir a mirar el PATCH — que es la
[Fase 9](forense-fase-09.md).

### Paso 2 — ¿pasó algo por el socket?

En el navegador que **tomó** el ticket: DevTools → Network → filtro **WS** →
selecciona la conexión a `localhost:4000` → pestaña **Messages**. Repite la
operación de tomar.

```
↑ 42["ticket:created",{…}]     ← al crear un ticket, hace un rato
(nada nuevo al tomar)
```

**Qué descarta.** Acá está el hallazgo, y llegó sin abrir un archivo: **no se
emitió nada**. No es que el evento se haya perdido, ni que Ana no lo haya
recibido: nadie lo mandó. Descarta el servidor de sockets, la red y el cliente
de Ana de una sola vez.

> ⚠️ Si la pestaña **WS** está vacía del todo, tu problema es otro y anterior:
> el socket no conectó. Mira el indicador del header y la consola del servidor.

### Paso 3 — ¿quién emite, y qué emite?

Ahora sí, pero a la consola del servidor de sockets, que es más barata que el
código:

```
🟢 cliente conectado: k3Jd…
📨 ticket:created → 47 Impresora de la sala 2
🟢 cliente conectado: p9Za…
```

Un solo tipo de evento en todo el log. Y en el cliente:

```bash
grep -rn "socketService.emit\|socketService.on" src/
```

```
src/views/TicketCreateView.vue:64:      socketService.emit("ticket:created", created);
src/views/TicketWizardView.vue:212:     socketService.emit("ticket:created", created);
src/views/TicketsView.vue:38:          socketService.on("ticket:created", this.onCreatedHandler);
```

**Qué descarta.** Cierra el caso técnico: el sistema tiene **un** evento,
`ticket:created`, y lo emite quien crea. Tomar un ticket es un PATCH, y ningún
PATCH del proyecto anuncia nada. No hay bug: hay una funcionalidad que nadie
escribió, y un sistema en vivo que solo está vivo a medias.

### Paso 4 — la pregunta incómoda: ¿y quién debería emitirlo?

Mira **dónde** está ese `emit` del paso 3. No está en el servidor: está en el
componente del navegador que acaba de hacer el POST.

```js
.then(function (created) {
  socketService.emit("ticket:created", created); // 📣 anunciar a los demás
  self.$router.push("/tickets/" + created.id);
})
```

**Qué descarta.** Descarta la idea de que agregar `ticket:updated` en el mismo
sitio sea "el arreglo". Lo sería para el síntoma, y duplicaría el problema de
fondo: **el que anuncia no es el que persiste.** Es la deuda 💸 declarada en la
fase —*el cliente mentiroso*—, y la fase la acepta a propósito porque su
servidor es un relé de veinte líneas que solo rebota. Sus consecuencias son
comprobables hoy, en el paso 5.

### Paso 5 — comprobar por qué eso importa

En la consola del navegador, con la aplicación abierta:

```js
> socketService.emit("ticket:created", { id: 999, title: "No existe", status: "open" })
```

Mira la otra pestaña.

```
Toast: "Nuevo ticket #999 — No existe"
```

**Qué descarta.** Descarta cualquier duda sobre la gravedad de la deuda. Ese
ticket **no existe en ninguna base**: lo inventó un cliente y todos los demás lo
creyeron, porque el sistema no tiene forma de distinguir un anuncio legítimo de
uno falso. El servidor rebota lo que le llega, tal cual, y el ejercicio 24 de la
fase te hace repetir esto a propósito.

Acá termina el recorrido. La deuda es correcta **hoy** —con un relé tonto no hay
alternativa mejor— y su pago vive fuera de este curso: el día que exista un
backend de verdad, quien confirma la escritura es quien anuncia, y el cliente
pasa a ser solo oyente.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Un cambio no llega a la otra pantalla, y F5 lo muestra | No se emitió: mira la pestaña WS antes que el código |
| Nada llega nunca, ni siquiera los tickets nuevos | El socket no conectó: indicador del header y consola del server |
| El evento llega y se aplica dos, tres veces | Listeners sin `off`, o `.bind(this)` distinto en el alta y en la baja |
| El evento llega y la lista no cambia | El handler escribe en el sitio equivocado, o reemplaza el arreglo entero |
| El socket conecta y no llega nada, con errores raros | Cliente y servidor de socket.io desparejados (2.x contra 3.x/4.x) |
| Aparece un ticket que no existe en `db.json` | El anuncio lo emite un cliente: 💸 el cliente mentiroso |
| Cada vez que entras a la vista se abre otra conexión | Se conecta en `mounted` de la vista en vez de una vez por sesión |
| El toast aparece en la pestaña de quien creó el ticket | `socket.broadcast.emit` cambiado por `io.emit` en el servidor |
| Al recargar, el estado en vivo se pierde y no vuelve | El socket repuebla, no reconstruye: el estado se carga por HTTP |

---

## ⚰️ Los callejones

**"Se desconectó el socket."** Es la sospecha inmediata y la pestaña WS la
tumba en un segundo: la conexión está abierta —hay frames de heartbeat— y los
tickets nuevos siguen llegando. Cuando alguien diga "se cayó el socket", pide la
pestaña Messages: una conexión viva se ve, no se argumenta.

**"El PATCH no se guardó."** El paso 1 lo descarta antes de empezar. Este orden
importa: si hubieras empezado por el PATCH habrías pasado veinte minutos en
Network mirando un request perfectamente correcto.

**"Hay que agregar `ticket:updated` y listo."** Arregla el síntoma de hoy y
consolida el error de diseño: un segundo evento emitido por el cliente es un
segundo sitio donde cualquiera puede mentir. Merece decirse en el ticket, no
solo en el código — es la diferencia entre cerrar un caso y entenderlo.

**"Es la caché del navegador de Ana."** No hay caché en juego: los datos llegaron
por XHR sin cabeceras de caché y el socket no cachea nada. Es la hipótesis
comodín cuando dos pantallas no coinciden, y casi nunca es cierta en una SPA.

---

## 🧨 Deshacer

El paso 5 deja un toast falso en la otra pestaña, nada más: no se escribió en
`db.json`. Recarga y desaparece. Si además comentaste el `off` para ver los
handlers zombis (ejercicio 6 de la fase):

```bash
git checkout -- src/views/TicketsView.vue
```

Y recarga las dos pestañas: los listeners duplicados viven en la memoria del
navegador, no en tu código.

---

## 🧠 El patrón transferible

**En un sistema en vivo hay dos preguntas, y confundirlas cuesta horas: ¿se
emitió? y ¿se aplicó?** La primera se contesta en el emisor, la segunda en el
receptor, y hay una tercera —¿se persistió?— que no tiene nada que ver con las
otras dos. El F5 del paso 1 es el desempate más barato que existe entre "el dato
no está" y "el dato está y no viajó".

Y la lección que de verdad se transfiere: **pregúntate siempre quién tiene
autoridad para anunciar un hecho.** Si el que anuncia no es el que lo hizo
cierto, tienes un sistema donde el aviso y la verdad pueden separarse — y se van
a separar. Es la misma discusión que en tu backend de siempre separaba el
commit de la publicación del evento, y acá se ve con dos navegadores abiertos.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 8](08-websockets-minimos.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); los casos completos en los
[incidentes 08 y 09](cuaderno-incidentes.md); y el ciclo de vida de las
suscripciones, que es el mismo contrato de la
[pieza de la Fase 7](forense-fase-07.md) con otra librería encima.
