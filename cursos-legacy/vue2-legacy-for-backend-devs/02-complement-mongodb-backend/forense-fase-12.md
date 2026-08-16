# 🕵️ Forense Fase 12 — "Por socket llega distinto que por HTTP"

> **Sale de:** [Fase 12 — El backend habla](12-el-backend-habla.md) ·
> **Herramientas:** el cliente de socket y `curl` lado a lado, y el log del
> servidor · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la misma información llega con dos formas
> distintas según por dónde entre, y solo una de las dos rompe la pantalla.

Un backend que habla por dos canales tiene **dos fronteras**, y casi siempre solo
la primera está bien vigilada. Esta pieza va de esa asimetría: el serializer que
todo el mundo aplica al responder un HTTP y nadie recuerda aplicar al emitir un
evento.

---

## 🎫 El ticket

> "Los tickets que llegan en vivo salen mal en la pantalla: el enlace no
> funciona y la fecha aparece rarísima. Si recargo la página, el mismo ticket se
> ve perfecto. Solo pasa con los que llegan solos."
>
> — agente de soporte · **Ambiente:** UAT

"Solo pasa con los que llegan solos" delimita el caso entero: los datos que
entran por HTTP están bien, los que entran por socket no. Dos caminos, un solo
destino.

---

## 🧭 La ruta

Del más barato al más caro: comparar los dos canales cuesta dos comandos, el log
del servidor está escrito, y el código es lo último.

### Paso 1 — pon los dos canales lado a lado

```bash
curl -s http://localhost:4000/tickets/5f8a1c2e4b3d2f0012a4e991
```

```json
{"id":"5f8a1c2e4b3d2f0012a4e991","title":"La impresora no imprime",
 "createdAt":"2020-03-10T10:00:00.000Z","status":"open"}
```

Y en la consola del navegador, escuchando el evento:

```js
> socket.on("ticket:created", function (t) { console.log(t); })
{ _id: "5f8a1c2e4b3d2f0012a4e991", title: "La impresora no imprime",
  createdAt: "2020-03-10T10:00:00.000Z", status: "open", history: [ … ],
  schemaVersion: 2 }
```

**Qué descarta.** Descarta el frontend y cierra medio caso en el primer paso.
Por HTTP llega `id`; por socket llega `_id` y, de regalo, campos internos que el
contrato no menciona. El enlace no funciona porque el componente construye la
ruta con `ticket.id`, que por este camino es `undefined`.

### Paso 2 — ¿dónde se emite?

```bash
grep -rn "emit(" src/ | grep -v node_modules
```

```
src/realtime/index.js:18:  io.emit(event, payload);
src/services/tickets.service.js:64:  realtime.emit("ticket:created", doc);
```

**Qué descarta.** Descarta el transporte: el evento sale bien, con el payload que
le dan. Lo que falta es la traducción — `doc` es el documento **crudo** de Mongo,
y el serializer que la [Fase 10](forense-fase-10.md) aplica en cada respuesta
HTTP no se aplicó acá. Una frontera vigilada, la otra no.

### Paso 3 — ¿se emite antes o después de escribir?

Con el mismo `grep` a la vista, mira el orden dentro de la función:

```js
realtime.emit("ticket:created", doc);        // ⚠️ antes
var result = await tickets.insertOne(doc);
```

**Qué descarta.** Descarta que sea solo un problema de forma. Emitir antes de
persistir reconstruye el **cliente mentiroso** del Curso 01 con más pasos: si la
escritura falla, todos los navegadores ya recibieron un ticket que no existe. El
orden correcto —escribir y después anunciar— es justamente la deuda 💸 que esta
fase viene a pagar, y hacerlo al revés la deja sin pagar.

### Paso 4 — el evento que llega dos veces

Otro reporte del mismo día, distinta causa:

```
Toast: "Nuevo ticket #47"
Toast: "Nuevo ticket #47"
```

```bash
lsof -i :4000
```

```
node    2211  oskar  … TCP *:4000 (LISTEN)
```

**Qué descarta.** Si hay un solo proceso escuchando y el evento igual llega
doble, el sospechoso es el **relé tonto** heredado: el servidor de sockets de
veinte líneas que el frontend traía sigue encendido y rebotando lo que el cliente
emite, mientras el backend nuevo emite lo suyo. Dos emisores para el mismo
hecho. Apagar el relé es parte de la fase, y olvidarlo produce exactamente este
síntoma.

Si el proceso viejo ya no está, la causa es la del Curso 01: handlers suscritos
sin dar de baja.

### Paso 5 — el socket conecta y no llega nada

Última rama, y la que más tiempo hace perder porque no se parece a un problema
de versiones:

```
(el cliente reintenta, sin mensajes claros)
```

```bash
grep -n "socket.io" package.json
```

```
"socket.io": "^4.5.0"          ← servidor
"socket.io-client": "2.4.0"    ← el del frontend, Curso 01
```

**Qué descarta.** Descarta tu código entero: el handshake de socket.io **3.x/4.x
no es compatible con el cliente 2.x**, y el fallo se manifiesta como silencio,
no como error. Media jornada garantizada si no lo conoces. El servidor tiene que
hablar la versión del cliente que ya existe, y ése es el criterio del curso: el
frontend heredado no se toca.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Por socket llega `_id` y por HTTP llega `id` | Falta el serializer en el emit |
| Campos internos que aparecen solo en vivo | Se emitió el documento crudo |
| Aparece un ticket que no está en la base | Se emitió antes de persistir |
| El mismo evento llega dos veces | Dos emisores: el relé viejo sigue encendido |
| El socket conecta y no llega nada | Versiones desparejadas: servidor 3.x/4.x contra cliente 2.4 |
| Dependencia circular al importar `io` | El singleton de `realtime/` existe para eso |
| El servidor se queda sin memoria al servir un adjunto | Se cargó el archivo entero en vez de usar el stream |
| Uploads que tumban el proceso | multer sin `limits`: es un vector de denegación de servicio |
| Adjuntos huérfanos en GridFS | La metadata va en el `openUploadStream`, no en un update posterior |

---

## ⚰️ Los callejones

**"El frontend está mal escrito."** El frontend hace lo que el contrato dice, y
el paso 1 lo demuestra: por HTTP funciona. Cuando el mismo componente pinta bien
un dato y mal el otro, el problema no es el componente — es que le llegaron dos
formas distintas de la misma cosa.

**"Emito el documento crudo y que el frontend elija lo que necesita."** Es
tentador y rompe el contrato en silencio: obliga a cada consumidor a conocer la
forma interna de tu base, y el día que cambies un campo interno romperás
pantallas que no sabías que lo usaban. **El payload de un evento es una respuesta
de API**, con la misma frontera y el mismo serializer.

**"Actualizo el cliente de socket.io a la 4 y listo."** Eso es modificar el
frontend heredado, que es exactamente lo que el paquete no hace: la promesa es
que se cambia el `baseURL` y la aplicación no se entera. El backend se adapta al
cliente que existe.

---

## 🧠 El patrón transferible

**Cada canal de salida es una frontera, y todas necesitan el mismo guardián.** Es
fácil recordar el serializer en el sitio donde se escribió la primera vez —el
handler HTTP— y olvidarlo en el segundo canal, que suele añadirse meses después:
un socket, una cola, un webhook, un correo. El resultado es siempre el mismo:
consumidores que reciben dos versiones de la verdad y bugs que solo pasan "cuando
llega en vivo".

Y la regla de oro del tiempo real, que ya venías arrastrando desde el Curso 01:
**anuncia lo que ya es cierto.** Emitir antes de confirmar la escritura es
prometer en nombre de una operación que todavía puede fallar — y quien escuche no
tiene forma de saber que le mentiste.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 12](12-el-backend-habla.md); el contrato en
[`00-audit-contrato.md`](00-audit-contrato.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); y el caso completo en el
[incidente 11](cuaderno-incidentes.md), que es de costura y autocontenido.
