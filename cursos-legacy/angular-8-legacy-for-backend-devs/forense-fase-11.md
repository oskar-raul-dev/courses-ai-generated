# 🕵️ Forense Fase 11 — "El sábado la orden salió entregada sin validar el último resultado"

> Pieza forense de la [**Fase 11 — Trazabilidad y audit log**](./11-trazabilidad-audit-log.md) · Recorrido: ~45 min · [Índice del track](./forense-master.md)
> Herramientas: la bitácora (filtrar, ordenar, contar) · el log de acciones · Network
> Síntoma que cubre: una queja sobre algo que pasó hace días, sin nadie delante de la pantalla.

Todas las piezas anteriores dan por hecho que puedes reproducir. Ésta no. Acá te llega una queja **sin evidencia en vivo**: el hecho ocurrió el sábado, nadie tomó captura, y la persona que lo habría visto no estaba. Lo único que queda es la caja negra.

Aprender a leerla es lo que la fase entrena, y tiene una parte contraintuitiva: **lo que más veces resuelve un incidente no es el asiento que está, sino el que falta**.

---

## 🎫 El ticket

> *"El sábado la orden 4021 salió entregada sin que se validara el último resultado. El informe ya se le envió al paciente. Necesitamos saber quién la entregó."*

**Reportado por:** la coordinadora de calidad, el lunes
**Ambiente:** PROD
**Evidencia en vivo:** ninguna. Han pasado dos días.

> 💡 El número de orden es el del ticket. En tu proyecto será uno de los que sembró tu `db.json`; la ruta es idéntica cambiando el id.

Dos afirmaciones que hay que separar antes de empezar, porque el ticket las presenta como una sola: **(a)** la orden pasó a `delivered`, y **(b)** el último resultado no estaba validado en ese momento. La primera es comprobable en un minuto. La segunda es la que cuesta, y puede ser falsa.

---

## 🧭 La ruta

Cinco pasos. Los tres primeros son consultas a la bitácora y no tocan la aplicación; el cuarto contrasta la bitácora con el dato, y el quinto es el único que puede exigir reproducir algo.

### Paso 1 — Traer la bitácora de esa orden, ordenada

La bitácora es una colección más, así que se consulta como tal. Filtrada por entidad y ordenada por tiempo, que es la única forma en que sirve:

```bash
curl "http://localhost:3000/auditLog?entityType=order&entityId=4021&_sort=timestamp"
```

```json
[
  { "id":"a7f3…", "timestamp":"2019-09-07T09:12:04.881-05:00", "actor":"analista1",
    "action":"[Orders] Transition Order Success", "entityType":"order", "entityId":"4021",
    "before":null, "after":{ "id":4021, "status":"complete", … } },
  { "id":"b1c9…", "timestamp":"2019-09-07T09:12:31.204-05:00", "actor":"system",
    "action":"[Orders] Mark Delivered Success", "entityType":"order", "entityId":"4021",
    "before":null, "after":{ "id":4021, "status":"delivered", … } }
]
```

**Qué descarta.** La afirmación (a) queda confirmada y fechada: la orden se entregó, y hay veintisiete segundos entre pasar a `complete` y pasar a `delivered`. Y aparece lo primero que no cuadra: **el `actor` de la entrega dice `system`**, no una persona.

Si la consulta devolviera `[]`, el diagnóstico sería otro y mucho más grave: la orden cambió de estado sin dejar asiento, y eso es el paso 5.

### Paso 2 — El asiento que debería estar y no está

La queja no es sobre la entrega: es sobre el resultado sin validar. Ese asiento apunta a otra entidad, así que hay que pedirlo aparte —y ahí está el precio de una bitácora plana:

```bash
curl "http://localhost:3000/auditLog?entityType=result&_sort=timestamp" | grep -c "Validate Result Success"
```

Y para la orden concreta, la vuelta larga: sacar los resultados de sus muestras y cruzarlos a mano.

```bash
# Las muestras de la orden, y los resultados de esas muestras.
curl -s "http://localhost:3000/samples?orderId=4021"
curl -s "http://localhost:3000/results?sampleId=88"
```

**Qué descarta.** Cuenta resultados frente a asientos de validación:

- **Tres resultados y tres `Validate Result Success`** → la afirmación (b) es falsa. Todo se validó, y lo que la coordinadora vio fue otra cosa: una pantalla desactualizada, un informe generado antes de tiempo (que es el bug de la Fase 9), o un malentendido. **Un incidente que se cierra demostrando que no hubo incidente es un resultado legítimo**, y hay que escribirlo con el mismo cuidado que un fix.
- **Tres resultados y dos asientos** → falta uno. Y falta un asiento, que no es lo mismo que faltar una validación. Paso 3.

> 🧭 **La bitácora es la caja negra, no el sistema.** Un hueco en ella puede significar dos cosas opuestas: que la cosa no pasó, o que pasó y no se registró. Distinguirlas es el paso siguiente, y confundirlas es la forma más rápida de acusar a alguien de algo que no hizo.

### Paso 3 — ¿No pasó, o pasó y no se registró?

La respuesta está en el dato, no en la bitácora. Mira el resultado que no tiene asiento:

```bash
curl -s "http://localhost:3000/results/9003"
```

```json
{ "id":9003, "sampleId":88, "analyte":"glucose", "value":97, "status":"validated",
  "validatedBy":"analista1", "validatedAt":"2019-09-07T09:11:58.402-05:00",
  "rangeVersionApplied":2 }
```

**Qué descarta.** El resultado **está validado** —tiene `validatedBy`, `validatedAt` y versión de norma— y no hay asiento suyo. Luego la mutación ocurrió y la bitácora no se enteró. Muere la hipótesis de "se entregó sin validar": se validó, y lo que falló fue el registro.

Y con eso el diagnóstico apunta a la deuda que la fase declara en voz alta: **el asiento lo escribe el navegador, después de que la mutación ya pasó**. Son dos peticiones separadas, sin transacción entre ellas. Si el `PATCH` del resultado sale bien y el `POST /auditLog` falla, la cosa cambió y no quedó registrada. La bitácora tiene un hueco y nada en el sistema lo señala.

Las tres firmas de ese hueco, para reconocerlo la próxima vez:

| Firma | Qué pasó |
|---|---|
| Mutación en el dato, sin asiento | el `POST /auditLog` falló y nadie lo reintentó |
| Asiento con `entityType: "unknown"` | llegó una acción registrable sin `case` en `buildEntry` |
| Ningún asiento para una mutación nueva | esa acción ni siquiera está en el `ofType` del effect |

Las dos últimas se comprueban con un `grep` y valen la pena antes de culpar a la red:

```bash
grep -n "ofType(" -A 8 src/app/audit/store/audit.effects.ts
```

### Paso 4 — El `actor: system`, que es el otro hallazgo

Vuelve al asiento de la entrega. `actor: "system"` no es un error: es lo que `buildEntry` escribe cuando `getCurrentUser()` devuelve `null`, o sea **cuando la mutación no la disparó una sesión con token**. Y hay una consecuencia dura: si el `actor` sale del token del navegador, la bitácora sólo sabe *quién dice el cliente que fue*.

**Qué descarta.** La pregunta del ticket —"necesitamos saber quién la entregó"— **no tiene respuesta en este sistema**, y eso hay que decirlo con todas las letras en el post-mortem en vez de improvisar un nombre. Lo que sí se puede afirmar es lo que el asiento prueba: que la entrega se disparó sin sesión activa. Y ahí las causas son acotadas y comprobables:

- una pestaña con el token vencido, donde el guard todavía no había actuado;
- una mutación disparada desde la consola o desde el inyector de caos;
- un `getCurrentUser()` que devolvió `null` porque el token existía pero el `sub` no se leyó — que es el mismo tipo de bug que produce `actor: undefined`, la variante que aparece en la sección 6 de la fase.

Ése es exactamente el terreno del **incidente 17**.

### Paso 5 — Contrastar la bitácora con el reloj

Queda una afirmación del ticket sin verificar, y es la primera palabra: **"el sábado"**. El `timestamp` del asiento lo pone `new Date().toISOString()` en el navegador.

```
"timestamp": "2019-09-07T09:12:31.204-05:00"     ← con el offset explícito
```

**Qué descarta.** Compara ese `timestamp` con el `validatedAt` del dato y con el día que dice la coordinadora. Si el navegador que disparó la entrega tenía otra zona horaria —o el reloj corrido—, el asiento puede caer en otro día que el evento real, y "el sábado" puede ser el viernes por la noche visto desde otro huso. En una queja que empieza con un día de la semana, eso no es un detalle.

Si el `timestamp` viene sin offset, no lo interpretes: es la deuda de la Fase 8 llegando hasta acá, y [`forense-fase-08.md`](./forense-fase-08.md) tiene el recorrido completo de por qué una comparación de fechas se resbala.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| Mutación en el dato, sin asiento | el `POST /auditLog` falló; no hay transacción | el dato de la entidad, no la bitácora |
| Ningún asiento de ninguna clase | el `AuditModule` es lazy y nunca se cargó | dónde está registrado el `EffectsModule.forFeature` |
| **Dos** asientos por cada mutación | el módulo se importó dos veces | los `imports`, en el core y en el lazy |
| `actor: "system"` | la mutación se disparó sin sesión activa | el token, y quién más puede despachar |
| `actor: undefined` | se leyó una propiedad de un objeto nulo un nivel más abajo | el ternario de `buildEntry`: chequea **el objeto** |
| `entityType: "unknown"` | acción registrable sin `case` en `buildEntry` | el `switch`, contra el `ofType` |
| El asiento existe y la timeline no lo muestra | el filtro compara `entityId` número contra cadena | `String(...)` en los dos lados |
| El asiento aparece sólo tras recargar | el reducer no lo agregó en `logAuditEntrySuccess` | ese `case` del reducer |
| La timeline se ve impecable y el asiento está podrido | la tabla no muestra `before`/`after` | el JSON crudo del asiento |
| `before: null` en todos los asientos | el payload del `Success` no trae el estado anterior | deuda declarada: ejercicio 23 |
| Un asiento fechado en otro día del que dice el usuario | `timestamp` del reloj del cliente | el offset de la cadena ISO |

---

## ⚰️ Los callejones

**"La entrega saltó la guarda."** Es la hipótesis natural viniendo de la Fase 7, y acá es falsa: el paso 1 muestra que la orden pasó por `complete` veintisiete segundos antes, así que la transición fue legal. Cuando el ticket dice "sin validar", conviene mirar si lo que falta es la validación o el registro de la validación — son cosas distintas y el paso 3 las separa.

**"Alguien borró el asiento."** El audit log **se agrega, no se corrige**, y ninguna parte de la aplicación tiene un `DELETE /auditLog`. Un asiento ausente es casi siempre uno que nunca se escribió. La acusación exige evidencia aparte —el `git log` del `db.json`, o los logs del servidor— y el post-mortem se escribe analizando el sistema, no a la persona.

**"Como dice `system`, fue el inyector de caos."** Puede ser, y es lo primero que hay que descartar precisamente porque es lo cómodo. `system` sólo dice que no había usuario en el token: una sesión vencida en una pestaña olvidada produce exactamente el mismo asiento que un script. La bitácora no distingue esos casos, y ése es el hallazgo, no una molestia.

**"La timeline está rota."** La timeline muestra `timestamp`, `actor`, `action` y `entityId`, y eso es todo lo que muestra. Un asiento con el `after` corrupto se ve **exactamente igual** que uno sano. Si confías en la vista en vez de en el dato, no lo detectas nunca — y es justo el 🧨 que propone la fase.

---

## 🧨 Deshacer

Este recorrido escribe en la bitácora de verdad: cada mutación que hagas mientras investigas deja su asiento, y esos asientos se mezclan con los que estás analizando.

```bash
# Antes de empezar, quedate con una copia de la bitacora tal como llego.
cp db.json db.antes-del-incidente.json

# Al terminar, si el auditLog quedó lleno de ruido de la investigación:
npm run seed        # el auditLog nace vacio: no se siembra
```

Y si tocaste `buildEntry` para reproducir el asiento corrupto del 🧨 de la fase, revierte antes de seguir:

```bash
git checkout -- src/app/audit/store/audit.effects.ts
```

Comprueba la reversión mirando el dato, no la pantalla: valida un resultado y abre el asiento nuevo en `db.json`. Si el `after` trae un `type` adentro, la línea sigue puesta.

---

## 🧠 El patrón transferible

> **En una bitácora, el asiento que falta dice más que el que está.** Un registro presente confirma que algo pasó; un hueco plantea la pregunta interesante, que es si la cosa no ocurrió o si ocurrió sin registrarse. Esas dos respuestas llevan a investigaciones opuestas —una busca en el flujo de la aplicación, la otra en el camino del propio registro— y se separan contrastando la bitácora contra el dato de la entidad. Nunca contra la bitácora misma.

Y el segundo, incómodo y por eso importante: **un audit log escrito por el cliente registra lo que el cliente dice que pasó.** El actor sale de un token del navegador, la hora sale del reloj del navegador, y el asiento viaja en una petición aparte que puede fallar sola. Eso no lo hace inútil —es infinitamente mejor que nada— pero fija el límite de lo que puede afirmarse con él. Saber dónde está ese límite es lo que te deja escribir un post-mortem honesto en vez de uno que suene bien.

**Incidentes del cuaderno que usan esta ruta:** el **17** —*"el log dice que yo validé ese resultado y yo no estaba ese día"*—, que entra por el paso 4 y termina en la misma frase sobre el actor.
**Amplía:** la [**Fase 3**](./03-autenticacion.md) para de dónde sale `getCurrentUser()` y por qué guarda el `sub` y no el nombre, [`forense-fase-07.md`](./forense-fase-07.md) para cuando la pregunta 🧬 se contesta sin bitácora, y [`forense-fase-08.md`](./forense-fase-08.md) para la zona horaria que decide en qué día cae un asiento.
