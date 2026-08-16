# 🕵️ Forense Fase 07 — "Figura como procesada y el analista jura que nunca la recibió" ⭐

> Pieza forense de la [**Fase 7 — Muestras y cadena de custodia**](./07-muestras-custodia.md) · Recorrido: ~50 min · [Índice del track](./forense-master.md)
> Herramientas: la línea de custodia · el log de acciones · `SAMPLE_TRANSITIONS` · Network · `db.json`
> Síntoma que cubre: un dato que es **imposible** según las reglas del dominio, sin un solo error en ninguna parte.

Ésta es la pieza donde el track cambia de naturaleza. Hasta acá, un bug se veía: una pantalla vacía, un botón muerto, un spinner eterno. A partir de acá el bug se ve como **un dato correcto que no puede existir**, y sólo lo detecta quien conoce las reglas. Nada grita. Nada es rojo. La muestra dice `processed` y el flujo dice que eso era imposible.

Y es la pieza que estrena la pregunta propia de este track: 🧬 **¿esto lo escribió el sistema, o llegó ya roto en el dato?** Es la primera bifurcación y la más cara de equivocar.

---

## 🎫 El ticket

> *"Hay una muestra que figura como procesada pero el analista de la tarde jura que nunca la recibió. Dice que él no la tuvo en la mano. La orden ya salió con resultado."*

**Reportado por:** la coordinadora del turno de la tarde
**Ambiente:** UAT
**Dato duro que trae el ticket:** ninguno. Ni el id de la muestra, ni la hora.

Que el analista "jure" es información, no ruido: en un laboratorio con custodia regulada, el paso `received` **es** la firma de que alguien tomó posesión física del tubo. Si la muestra está `processed` sin haber pasado por `received`, o el sistema estampó una firma que nadie puso, o el analista se equivoca. Las dos posibilidades son investigables y una de ellas es grave.

---

## 🧭 La ruta

Seis pasos. El primero es mirar la pantalla treinta segundos, el segundo decide de qué investigación estamos hablando, y sólo el cuarto abre un archivo del proyecto. **Si haces el paso 2 al final, como es la tentación, puedes pasarte medio día leyendo un reducer que nunca corrió.**

### Paso 1 — La línea de custodia: ¿hay hueco, y dónde?

Abre la orden y mira la línea de tiempo de la muestra. Lo que dibuja `custodyEvents` no son estados: son **eventos que dejaron firma**, y por eso el hueco es visible.

```
Muestra 501 — estado actual: processed

  Recogida    analista1    2019-09-02 10:05
  Procesada   analista1    2019-09-02 16:40
```

Dos eventos donde tendría que haber tres. Falta **Recibida**, que es justo el paso que el analista niega.

**Qué descarta.** Confirma el ticket y lo convierte en algo medible: no es una impresión de la coordinadora, es un registro con un agujero. Y descarta de entrada la hipótesis perezosa de "la línea no pinta bien": `custodyEvents` sólo empuja un evento si el campo `receivedBy` tiene valor, así que el hueco en la pantalla significa **campo vacío en el dato**, no un problema de plantilla.

> 💡 Si la línea muestra los tres eventos y el estado igual parece raro, no sigas por esta ruta: no hay transición ilegal. Lo que hay es un desacuerdo sobre quién hizo qué, y eso se resuelve en la bitácora — [`forense-fase-11.md`](./forense-fase-11.md).

### Paso 2 — 🧬 ¿Lo escribió el sistema, o llegó ya roto?

**El paso que decide la investigación entera.** Abre Redux DevTools → **Actions** y busca cualquier intento de transición sobre esa muestra. Si el incidente es viejo y no tienes el log en vivo, la pregunta se le hace al `db.json` en el paso 5; si puedes reproducir, se le hace al log.

```
[Samples] Load Samples
[Samples] Load Samples Success
[Samples] Transition Sample        { sampleId: 501, toStatus: "processed" }
[Samples] Transition Sample Success
[Samples] Load Samples
```

**Qué descarta.** Tres salidas posibles y tres investigaciones distintas:

- **Hay intento y hay éxito** (la salida de arriba) → el sistema aceptó una transición que el mapa prohíbe. **La guarda falló**, y eso es lo grave. Paso 3.
- **Hay intento y NO hay éxito** → la guarda funcionó: el reducer devolvió el estado intacto, no encendió `saving` y no despachó nada. El usuario vio que el control no reaccionaba y no supo por qué, pero el dato quedó sano. Ese silencio es una decisión declarada de la fase, no un bug — y es material del ejercicio 27.
- **No hay ni intento** → nadie transicionó nada acá. La muestra **llegó rota**: del `db.json`, de una migración, del semillero, o de un analizador externo. Salta al paso 5 y olvídate del reducer.

Medio día se ahorra o se pierde en este paso.

### Paso 3 — Si la guarda falló: ¿contra qué mapa se validó?

Sólo hay tres formas de que `canTransition` diga que sí a `scheduled → processed`, y se comprueban en este orden porque cuestan eso: segundos, un minuto, y cinco minutos.

**(a) Alguien editó el mapa.** Es lo primero porque es lo más barato de mirar y lo más frecuente en un legacy:

```bash
git diff HEAD -- src/app/samples/store/sample.transitions.ts
git log -S"processed" --oneline -- src/app/samples/store/sample.transitions.ts
```

Una línea como `scheduled: ['collected', 'processed'],` explica el ticket completo y termina la investigación. El `git log -S` sirve además para lo que de verdad importa después: **cuándo** entró y en qué commit.

**(b) Se validó contra un estado que ya no era el real.** El reducer busca la muestra en `state.items` y compara contra el `status` que tiene **el store**, no el servidor. Si se despacharon dos transiciones muy seguidas, la segunda validó contra un estado intermedio. Se detecta contando en el log:

```
[Samples] Transition Sample          { sampleId: 501, toStatus: "in_process" }
[Samples] Transition Sample          { sampleId: 501, toStatus: "processed" }   ← antes del Success anterior
[Samples] Transition Sample Success
[Samples] Transition Sample Success
```

Dos intentos antes de que llegara el primer éxito. Con `CHAOS=latency=3000` esto se provoca a voluntad, igual que el duplicado de la Fase 5.

**(c) El `find` no encontró la muestra.** `state.items.find(s => s.id === action.sampleId)` compara con `===` sobre `any`. Un `sampleId` que llegue como cadena —de un `paramMap`, de una plantilla— no es igual a un `id` numérico, y `find` devuelve `undefined`. En el reducer tal como lo escribe la fase eso es inofensivo (`!sample` corta y devuelve el estado); en una versión donde alguien "simplificó" esa guarda, el `undefined` se convierte en vía libre. Compruébalo en el log, mirando el tipo del payload:

```json
{ "sampleId": "501", "toStatus": "processed" }
```

Las comillas alrededor del `501` son toda la evidencia que necesitas.

**Qué descarta.** Cada una de las tres deja una firma distinta y no se confunden entre sí: (a) está en el `git diff`, (b) está en el orden del log, (c) está en las comillas del payload. Si ninguna de las tres aparece, vuelve al paso 2: probablemente había intento y no éxito, y estás persiguiendo un fantasma.

### Paso 4 — Qué se escribió de verdad: el PATCH

Network → filtro `XHR` → la petición `PATCH /samples/501` → pestaña **Payload** (o **Request** según el navegador):

```json
{
  "status": "processed",
  "processedBy": "analista1",
  "processedAt": "2019-09-02T16:40:12.418-05:00"
}
```

**Qué descarta.** Confirma la mecánica del daño y explica el hueco: el effect estampa **sólo** el campo de custodia del estado destino, el que le dice `CUSTODY_FIELD`. Saltarse `received` no es sólo un estado que no se recorrió: es una firma que nunca se pidió a nadie. Por eso el hueco de la línea es permanente y no se rellena solo — no hay ningún sitio de donde sacar quién recibió el tubo, porque nadie lo recibió.

Y de paso muere la hipótesis "el servidor lo cambió por su cuenta": el cuerpo que salió del navegador ya traía `processed`.

### Paso 5 — La otra rama: el dato que llegó roto

Si el paso 2 dijo que no hubo intento, la pregunta ya no es qué hizo la aplicación sino **de dónde salió ese registro**. Tres comprobaciones, de la más barata a la más cara:

```bash
# 1. El registro tal cual esta hoy. ¿Tiene processedBy sin receivedBy?
grep -n -A6 '"id": 501' db.json

# 2. ¿Lo puso el semillero? El seed tiene semilla fija: si el estado
#    inconsistente sale de un `npm run seed` limpio, no lo escribio nadie.
npm run seed && grep -n -A6 '"id": 501' db.json

# 3. ¿Estas sobre un db.json de incidente y no sobre el tuyo?
ls db.incidente-*.json
```

**Qué descarta.** Si el registro inconsistente reaparece tras un `seed` limpio, la aplicación queda descartada por completo: el dato nace así. Si no reaparece, alguien lo escribió —a mano, con un PATCH suelto, con un `db.incidente-NN.json` copiado y olvidado— y la investigación se vuelve de trazabilidad, no de código.

Cuando llegues a la Fase 11 esta rama se acorta muchísimo: el `auditLog` guarda el `before`/`after` de cada mutación, y la pregunta "¿quién escribió esto?" deja de necesitar arqueología. Mientras tanto, el `git log` del `db.json` es lo más parecido que hay.

### Paso 6 — El fix mínimo, que depende de cuál de las cinco fue

La ruta termina cuando sabes **dónde** está el bug, y acá terminó. Pero conviene ver, en una línea cada uno, por qué el diagnóstico manda sobre el parche:

- **Mapa editado** → revertir esa línea. Una línea, cero discusión.
- **Validación contra estado viejo** → el fix barato es impedir el segundo despacho desde la interfaz; el correcto es validar contra el servidor, y eso es un cambio de contrato con el backend.
- **`find` con tipos distintos** → normalizar el id. Y buscar los otros seis sitios del curso donde se compara un id con `===` sobre `any`.
- **Dato roto de origen** → un PATCH que corrige esa muestra, y la pregunta incómoda de cuántas más hay. `db.json` se puede recorrer entero buscando el mismo patrón: `processedBy` sin `receivedBy`.

Y en los cinco casos, la misma pregunta de cierre: **¿el rechazo debería ser visible?** Hoy el reducer devuelve el estado intacto y nadie se entera. Hacerlo visible es un cambio de interfaz y está discutido en la fase; **no es material de hotfix**, aunque siempre haya alguien que lo proponga como si lo fuera.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| Hueco en la línea de custodia | falta el campo `*By` de ese paso | el registro en `db.json`, no la plantilla |
| Intento en el log **sin** éxito detrás | la guarda funcionó; el usuario no vio por qué | nada que arreglar en el dato; ejercicio 27 |
| Intento **con** éxito sobre una transición imposible | la guarda no aplicó | las tres causas del paso 3 |
| Ni intento ni éxito, y el dato es imposible 🧬 | llegó roto del `db.json` o de una migración | el semillero y el `git log` del dato |
| Dos intentos seguidos y dos éxitos | se validó contra un estado intermedio | el orden del log, con latencia encendida |
| `sampleId` entre comillas en el payload | id como cadena: `find` con `===` no encuentra | el tipo del parámetro de la ruta |
| `Cannot read property 'indexOf' of undefined` en `canTransition` | la muestra tiene un `status` que no es clave del mapa | el `|| []` de guarda de `allowedTargets` |
| Los botones de transición ofrecen algo imposible | el componente y el reducer leen el mismo mapa: si uno miente, mienten los dos | `SAMPLE_TRANSITIONS`, que es la única fuente |
| El descarte no estampa "por quién" | `discarded` no está en `CUSTODY_FIELD`, a propósito | la tabla del effect, §5.5 |
| La lista no cambia al pasar de una orden a otra | `snapshot` en vez de `paramMap.subscribe` | el `ngOnInit` del componente |

---

## ⚰️ Los callejones

**"El servidor cambió el estado por su cuenta."** json-server no tiene lógica: escribe lo que le mandan. El paso 4 lo demuestra en diez segundos leyendo el cuerpo del PATCH, y conviene hacerlo temprano porque es la hipótesis que más gente propone en una reunión.

**"La línea de custodia está mal programada."** Tentador, porque la línea es lo único que se ve raro. Pero `custodyEvents` sólo pinta lo que existe: si falta "Recibida", falta `receivedBy` en el dato. La plantilla está contando la verdad — la incómoda.

**"Alguien lo cambió a mano en la base."** Puede ser, y es exactamente lo que investiga el paso 5. Pero es una acusación, no una hipótesis, hasta que el `seed` limpio o el `git log` la sostengan. En un post-mortem sin culpabilización esto se escribe como *"el dato pudo escribirse fuera de la aplicación y hoy el sistema no puede distinguirlo"*, que además es la verdad y apunta al hueco de trazabilidad que la Fase 11 viene a tapar.

**"Es un problema de concurrencia."** Sólo si el log muestra dos intentos solapados (paso 3b). Con un solo intento no hay carrera posible: el reducer es una función pura y síncrona, y entre que lee `state.items` y devuelve el estado nuevo no se ejecuta nada más. La concurrencia de este dominio está en otro sitio —dos analistas validando el mismo resultado— y eso es la Fase 8.

---

## 🧨 Deshacer

El recorrido puede haber tocado dos cosas, y las dos hay que devolver:

```bash
# 1. El mapa de transiciones, si metiste la transición ilegal a mano.
git checkout -- src/app/samples/store/sample.transitions.ts

# 2. El dato, que si quedó con la muestra en un estado imposible.
npm run seed
```

Comprueba el primero con la interfaz y no con el editor: abre una muestra en `scheduled` y confirma que **ya no ofrece** `processed` entre sus destinos. Es la misma comprobación que hace el reducer, hecha con los ojos.

Y si encendiste `CHAOS=latency` para provocar la doble transición, apágalo antes de seguir.

---

## 🧠 El patrón transferible

> **En un sistema con máquina de estados, el bug no siempre se ve como un error: a veces se ve como un dato que es imposible.** Y sólo lo ve quien conoce las reglas. Por eso lo primero que se aprende de un sistema heredado con estados no es el código: es el diagrama de lo que puede pasar y lo que no. Sin eso, un registro imposible parece un registro normal.

Y el segundo, que es la pregunta 🧬 del método y vale para cualquier sistema con log de eventos: **antes de buscar quién lo hizo mal, pregunta si alguien lo hizo.** Un intento registrado y un dato roto sin ningún intento son dos mundos distintos: uno se arregla en el código y el otro en el dato, y no comparten ni una sola herramienta. Contestar esa pregunta cuesta una mirada al log; equivocarse cuesta medio día.

**Incidentes del cuaderno que usan esta ruta:** el **11** —*"la muestra figura procesada pero nunca se recibió"*, que llega con un `db.json` alterno y por lo tanto entra por la rama del paso 5— y el **21** —*"la lista no cambia al cambiar de orden"*, que es el `snapshot` de la última fila de la tabla.
**Amplía:** la [**Fase 11**](./11-trazabilidad-audit-log.md) para cuando la pregunta "¿quién escribió esto?" tenga respuesta en el sistema y no en el `git log`, y el [**Apéndice A06**](./a06-ngrx.md) para por qué una guarda en el reducer es más fuerte que una guarda en la interfaz.
