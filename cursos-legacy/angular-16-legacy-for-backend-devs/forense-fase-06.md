# 🕵️ Forense Fase 06 — "No me deja guardar el cliente nuevo y no dice por qué"

> Pieza forense de la **Fase 6 — Clientes y activos** · Recorrido: ~35 min
> Herramientas: `ng.getComponent($0)` · pestaña Network · el estado de un `FormGroup`
> Síntoma que cubre: un ticket vago, sin captura, sin navegador, sin usuario y sin acceso a producción.

Éste es el ticket que más se parece a los de verdad: **tres frases, ninguna reproducible**. La pieza es el procedimiento para convertirlo en un diagnóstico en cuatro minutos, y el truco central es que **el formulario contesta antes que el código**.

La fase resume los cuatro pasos. Aquí están las tres reproducciones y la salida literal de cada uno.

---

## 🎫 El ticket

> *"No me deja guardar el cliente nuevo y no dice por qué. Le doy a Guardar y no pasa nada. Ya lo intenté con dos clientes distintos."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT
**Lo que no trae:** qué escribió, en qué campo, con qué navegador, ni a qué hora.

---

## 🧭 La ruta

Cuatro pasos, **del más barato al más caro**. Preguntarle su estado al formulario desde la consola cuesta un comando y descarta la mitad de las causas de un tirón; abrir el validador asíncrono y seguir su petición cuesta bastante más, y sólo hace falta cuando el estado dice `PENDING`. El orden lo decide el coste, no la corazonada.

### Paso 1 — Reproducir con lo que hay: los tres casos

No preguntes qué escribió. **Prueba los tres estados que producen ese síntoma exacto** y mira cuál se comporta como dice el ticket. Son tres minutos.

**Reproducción A — un campo obligatorio vacío, sin tocar.**

```
Escribe: razón social = "Edificio Aurora", NIT = (vacío, sin hacer clic en él)
Pulsa:   Guardar
Se ve:   no pasa nada, y el campo del NIT NO está en rojo
```

Es el que más se parece al ticket, y por una razón que sorprende: **`mat-error` sólo se pinta cuando el control es inválido *y* está `touched`.** Un campo que nunca se tocó está inválido y mudo. Por eso el `submit()` de la fase llama a `markAllAsTouched()` antes de rendirse — sin esa línea, este ticket llega todas las semanas.

**Reproducción B — el NIT con formato inválido.**

```
Escribe: NIT = "9001"
Se ve:   el campo en rojo con "El NIT debe tener entre 9 y 10 dígitos" en cuanto sales del campo
```

**No es este caso**: el sistema sí dice por qué. Descartado.

**Reproducción C — un NIT que ya existe.**

```
Escribe: NIT = "900123456"   (el de Edificio Central S.A.S., que está en la semilla)
Pulsa:   Guardar deprisa, sin esperar
Se ve:   no pasa nada durante un segundo, y después el campo se pone en rojo
```

Éste **también** se parece al ticket, y es un bug distinto del A. Aquí está el paso 2.

**Qué descarta.** Ya sabes que hay dos causas candidatas, no una, y que producen el mismo "no pasa nada". Cuál de las dos es, lo dice el formulario.

### Paso 2 — Pregúntale al formulario, no al código

Con la pantalla abierta: inspector de elementos → selecciona el `<form>` → pestaña Console.

```js
// $0 es el elemento seleccionado en el inspector. `ng` sólo existe en el build
// de desarrollo; en producción no está, y eso es la Fase 13.
const component = ng.getComponent($0);

component.form.status;
// 'INVALID'   → hay un control que no cumple
// 'PENDING'   → hay un validador asíncrono en vuelo
// 'VALID'     → el formulario está bien y el problema es otro

Object.entries(component.form.controls)
  .filter(([, control]) => control.invalid || control.pending)
  .map(([name, control]) => ({ name, status: control.status, errors: control.errors }));
```

Las tres salidas posibles, y las tres son diagnósticos distintos:

```js
// Caso A — el campo vacío que nadie tocó
[ { name: 'taxId', status: 'INVALID', errors: { required: true } } ]

// Caso C — el NIT repetido, ya resuelto
[ { name: 'taxId', status: 'INVALID', errors: { taxIdTaken: true } } ]

// Caso C' — el validador asíncrono, todavía en vuelo… o colgado
[ { name: 'taxId', status: 'PENDING', errors: null } ]
```

**Qué descarta.** `INVALID` con un error nombrado es **un usuario que necesita un mensaje**: el bug es de interfaz y se arregla en la plantilla. `PENDING` que no cambia nunca es **un bug tuyo**: el validador asíncrono no completó, y se arregla en el validador. Los dos producen el mismo ticket y se arreglan en archivos opuestos.

> ⚠️ **`PENDING` no es `INVALID`, y ahí se cuela el bug más caro de esta pantalla.** Mientras un validador asíncrono está en vuelo, `form.invalid` es **`false`**. Un botón que sólo mira `[disabled]="form.invalid"` deja pasar el clic durante ese rato y guarda un NIT repetido. La comprobación correcta es `if (this.form.invalid || this.form.pending)`, y está en el `submit()` de la fase por esto.

### Paso 3 — Si es `PENDING`: qué pasó con la petición

Network → filtro `Fetch/XHR` → busca la petición del validador:

```
Name                                      Status    Type    Time
clients?taxId=900123456                   200       xhr     34 ms
```

Tres salidas, tres causas:

| Lo que ves en Network | Qué pasó | Dónde está el bug |
|---|---|---|
| La petición volvió `200` y el control sigue `PENDING` | el observable **no completó** | falta `first()` en el validador |
| La petición quedó en `pending` para siempre | el servidor no contesta | `CHAOS=timeout`, o el backend de verdad |
| La petición devolvió `500` y el control sigue `PENDING` | el error no se manejó | falta `catchError` |
| No hay ninguna petición | el validador ni se lanzó | los síncronos no pasaron: Angular no llama al asíncrono si `required` o `pattern` fallan |

La última fila es la que más desconcierta y es **comportamiento correcto**: Angular ejecuta primero los validadores síncronos y sólo llama al asíncrono si aquéllos pasaron. No se le pregunta al servidor por un NIT que ni siquiera tiene nueve dígitos.

Y las tres reglas que el validador de la fase lleva puestas por esto:

```ts
return timer(400).pipe(                                    // 1. ESPERAR
  switchMap(() => clientApi.existsByTaxId(taxId, exceptId)),
  map((exists) => (exists ? { taxIdTaken: true } : null)),
  catchError(() => of(null)),                              // 2. NO INVALIDAR POR RED
  first(),                                                 // 3. COMPLETAR
);
```

Quita cualquiera de las tres y tienes un ticket distinto: sin `timer`, una petición por tecla; sin `catchError`, el formulario se bloquea cuando el servidor tose; sin `first()`, el control se queda `PENDING` **para siempre** y el formulario no vuelve a ser válido en toda la sesión.

**Qué descarta.** Cuál de las tres piezas falta te dice cuál de los tres tickets tienes, y los tres se distinguen sin abrir el validador: una petición por tecla en Network es el `timer`; un `PENDING` que sobrevive a una respuesta con error es el `catchError`; y un `PENDING` eterno con la respuesta ya llegada es el `first()`. Si el validador tiene las tres y el control sigue colgado, el problema no es el validador: pasa al **Paso 4**.

### Paso 4 — Si es `VALID` y aun así no guarda

Entonces el problema es posterior al formulario, y el camino es el de `forense-fase-00.md`: ¿salió la petición?, ¿a dónde?, ¿qué contestó? Con un añadido propio de esta pantalla:

```js
// ¿El botón está deshabilitado por otra razón?
component.submitting;   // true → hay un guardado en vuelo y el botón se bloqueó
```

Si `submitting` se quedó en `true` para siempre, el guardado anterior falló sin reponer la bandera — un `error` que no la baja. Es el mismo error de forma que el `PENDING` colgado: **un estado que sólo se limpia por el camino feliz**.


**Aquí termina la ruta.** El bug está localizado: una bandera que sólo se repone por el camino feliz. Es la misma forma que el `PENDING` colgado del Paso 3, y reconocer esa forma —no este archivo— es lo que te llevas.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Estado del control | Dónde miras |
|---|---|---|
| No pasa nada y ningún campo en rojo | `INVALID` + `untouched` | falta `markAllAsTouched()` en el `submit()` |
| No pasa nada durante un segundo y luego rojo | `PENDING` → `INVALID` | comportamiento correcto: falta un indicador de "comprobando…" |
| No pasa nada nunca, y el campo no se pone rojo | `PENDING` para siempre | el validador no completó: falta `first()` |
| El formulario nunca vuelve a ser válido en toda la sesión | `PENDING` para siempre | lo mismo, y es el que peor se reporta |
| Guarda un NIT repetido si pulsas rápido | `PENDING` cuando pulsó | el botón sólo mira `invalid` y no `pending` |
| Se queda bloqueado tras un fallo | `submitting === true` | la bandera no se repone en el `error` |
| El campo se pone rojo con el valor correcto | `taxIdTaken` sobre uno mismo | falta el `exceptId` al editar |

---

## ⚰️ Los callejones

**"El usuario escribió mal el NIT."** Puede ser, y es lo primero que todo el mundo asume. La reproducción B lo descarta en veinte segundos: cuando el formato está mal, **el sistema sí lo dice**. Si el ticket insiste en que "no dice por qué", el formato no es la causa.

**"El backend está rechazando el guardado."** Descartable sin salir del navegador: si el problema fuera del backend, **habría una petición de guardado en Network**. En los casos A y C no hay ninguna: la petición nunca sale, porque el `submit()` se rinde antes.

**"Es la validación asíncrona que va lenta."** Medio callejón: sí es lenta —hay 400 ms de `timer` a propósito— y eso no bloquea nada por sí solo. Lo que bloquea es que **no complete**, que es otra cosa. La distinción es el paso 3 y se ve en una línea: si la petición volvió y el control sigue `PENDING`, el problema no es la lentitud.

**"Le pongo `updateValueAndValidity()` y se arregla."** Es el arreglo con peor relación beneficio/riesgo del tema: dispara la validación otra vez, tapa el síntoma la mayoría de las veces, y deja intacta la causa —un observable que no completa—, que va a volver en cuanto la red vaya lenta.

---

## 🧨 Deshacer

Nada de esta ruta modifica el proyecto: se mira, no se toca. Si creaste clientes probando, `npm run seed` devuelve el `db.json` a la semilla — y conviene, porque el NIT `900123456` de Edificio Central es el que usan las reproducciones y varios ejercicios.

Si probaste el caso del validador colgado quitando el `first()`, **devuélvelo antes de seguir**: con ese validador roto, el formulario de clientes no vuelve a ser válido y la Fase 7 te va a parecer rota sin serlo.

---

## 🧠 El patrón transferible

> **Un formulario reactivo sabe exactamente qué le pasa, y te lo dice en una línea de consola.** Antes de leer el componente, pregúntale al objeto: estado, controles inválidos, errores nombrados. Es la diferencia entre reproducir a ciegas y reproducir con una hipótesis.

Y el segundo, que se lleva a cualquier stack: **"no pasa nada" casi siempre significa que hay un estado intermedio que nadie está pintando.** `PENDING`, `submitting`, "cargando": los tres son estados reales del sistema, y si la interfaz sólo dibuja el éxito y el error, el usuario ve un botón muerto y escribe un ticket que no se puede reproducir.

**Incidentes del cuaderno que usan esta ruta:** ninguno directamente, y es a propósito: esta ruta es la **herramienta** con la que se resuelven varios de la semana 2 y 3. El `ng.getComponent($0)` reaparece en `forense-fase-08.md` y en `forense-fase-09.md`.
**Amplía:** **A05** §6 para validadores asíncronos y §7 para `value` frente a `getRawValue()`, **A01** §3 para por qué un `mat-error` puede no pintarse.
