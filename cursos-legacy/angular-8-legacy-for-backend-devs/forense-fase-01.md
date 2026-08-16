# 🕵️ Forense Fase 01 — "Cambié el paciente y la lista no se entera"

> Pieza forense de la [**Fase 1 — Estructura base + NgRx**](./01-estructura-base-ngrx.md) · Recorrido: ~35 min · [Índice del track](./forense-master.md)
> Herramientas: Redux DevTools (Actions · Diff · el deslizador) · consola · Network
> Síntoma que cubre: el estado es correcto, nadie lanza un error, y la pantalla muestra lo de antes.

Redux DevTools no es una herramienta de desarrollo: es la **reconstrucción de lo que hizo el usuario**. Un `500` en Network se pierde cuando cierras la pestaña; `[Patients] Load Patients Failure` con su carga útil queda en el log, ordenado respecto de todo lo demás que pasó. Cuando reconstruyas un incidente a partir de un reporte, no vas a tener la pestaña Network del coordinador — vas a tener, con suerte, esa secuencia.

Esta pieza es el recorrido completo de la clase de bug que **no produce un error, produce un silencio**. La fase te dijo que el silencio existe; acá lo persigues hasta la línea.

---

## 🎫 El ticket

> *"Marqué a un paciente en la lista, volví, y la lista sigue igual que antes. Le di dos veces por si acaso. Después recargué la página y ahí sí apareció bien. No sale nada raro en la pantalla."*

**Reportado por:** una auxiliar de recepción
**Ambiente:** desarrollo, con el mock de la Fase 0 corriendo

Tres datos, y los tres importan. **"La lista sigue igual"** dice que hay un estado que no llegó a la vista. **"Le di dos veces"** dice que el log va a tener dos acciones donde el usuario cree que hubo una — y eso, que parece ruido, es la mitad de la evidencia. **"Recargué y apareció bien"** dice que el dato del servidor estaba correcto todo el tiempo: lo que falló fue la notificación, no la carga.

---

## 🧭 La ruta

Cinco pasos, del más barato al más caro. El paso 1 son treinta segundos de log y decide de qué lado del sistema está el problema; el paso 5 es el único que abre un archivo, y para entonces ya sabes cuál.

### Paso 1 — ¿La acción llegó?

Abre Redux DevTools con la aplicación en `/patients`, pestaña **Actions**, y reproduce lo que contó la auxiliar: recarga, y pulsa una tarjeta.

```
@ngrx/store/init
@ngrx/store/update-reducers
[Patients] Load Patients
[Patients] Load Patients Success
[Patients] Select Patient
```

**Qué descarta.** Si la acción **no** aparece, el problema está antes del store —el `(click)` que no dispara, el botón deshabilitado, el `dispatch` que nunca se escribió— y esta ruta se acaba acá: el bug es del componente. Si aparece, como en la salida de arriba, el store recibió el evento y la investigación sigue del store hacia la vista. Sigue al paso 2.

> 💡 Si el ticket dice *"le di dos veces"*, cuenta las acciones antes de seguir. Dos `[Patients] Load Patients` seguidas significan que el usuario pudo pulsar dos veces y eso apunta al botón; una sola acción con dos efectos en el servidor es otra investigación completamente distinta. En esta fase el botón repetible es el de reintentar; la versión cara de esa bifurcación —dos guardados de un paciente— es [`forense-fase-05.md`](./forense-fase-05.md).

### Paso 2 — ¿El estado cambió, y cuánto?

Selecciona la última acción y abre la pestaña **Diff**. Es más rápida de leer que el estado completo: sólo muestra lo que se movió entre una acción y la siguiente.

```
patients
  selectedId:  null → 2
```

**Qué descarta.** El reducer hizo su trabajo: recibió la acción y produjo un estado distinto. Muere la hipótesis "el reducer no maneja ese `case`" —que habría dejado el Diff vacío— y muere también "el payload llega vacío", porque el `2` está ahí. El problema está entre el estado y la pantalla. Paso 3.

Y si el Diff **sí** sale vacío con la acción presente, la causa es una de dos: el `case` no existe y cayó en el `default`, o el `type` de la acción no coincide con el del `case`. Las dos se confirman en el paso 5, y ninguna necesita depurador.

### Paso 3 — ¿La pantalla miente, o el estado miente?

Con el estado nuevo en el store, mira la lista. Si la tarjeta no se marcó, hay dos verdades simultáneas y contradictorias, que es la forma exacta de este bug: **el store dice una cosa y el DOM dice otra**.

Compruébalo sin código intermedio: en la misma extensión, pestaña **State**, con la última acción seleccionada. Es el estado que el store considera actual, sin pasar por ninguna plantilla:

```json
{
  "patients": {
    "items": [ { "id": 1, "fullName": "…" }, { "id": 2, "fullName": "…" } ],
    "loading": false,
    "error": null,
    "selectedId": 2
  }
}
```

**Qué descarta.** `selectedId: 2` en el store y ninguna tarjeta marcada en pantalla descarta el servidor, el effect y el reducer de un golpe: los tres hicieron lo suyo. Lo que no ocurrió es la **emisión del selector**. Paso 4.

### Paso 4 — El deslizador: ¿se pinta si el estado vuelve a llegar?

Abajo del panel está el control deslizante. Arrástralo hasta la acción anterior y suéltalo hacia adelante otra vez: la aplicación se redibuja con cada estado por el que pasas.

**Qué descarta.** Acá el resultado parte la investigación en dos, y es el paso más informativo del recorrido:

- **La tarjeta se marca al mover el deslizador** → el estado siempre fue correcto y la vista sabe pintarlo. Lo que falló fue **avisar**: el selector no emitió en su momento porque comparó referencias y encontró la misma. Es una mutación en el reducer. Paso 5.
- **La tarjeta no se marca ni con el deslizador** → el estado no es el problema en absoluto; la plantilla no está leyendo `selectedId` o lo compara mal (un `===` entre número y string es el clásico). Sal de esta ruta y abre la plantilla.

> ⚠️ **Lo que el deslizador no deshace.** Repone el estado, no el mundo. Las peticiones que ya salieron siguen habiendo salido, y lo que el mock escribió en `db.json` sigue escrito. Es una máquina del tiempo para el estado, no para los efectos — y confundir las dos cosas es cómo alguien acaba "reproduciendo" un bug de escritura tres veces sin darse cuenta de que dejó tres registros.

### Paso 5 — El `case` culpable, en un `grep`

Sólo ahora se abre un archivo, y ya sabes cuál: el reducer del slice que aparece en el Diff.

```bash
grep -n "state\." src/app/patients/store/patients.reducer.ts
```

Lo que buscas es una asignación, no una lectura. Un `case` sano devuelve un objeto nuevo; el culpable escribe sobre el que recibió:

```typescript
case PatientsActions.selectPatient.type:
  state.selectedId = action.patientId;   // ❌ misma referencia: nadie se entera
  return state;

case PatientsActions.selectPatient.type:
  return { ...state, selectedId: action.patientId };   // ✅
```

**Qué descarta.** Con la línea localizada la ruta termina: sabes **dónde** está el bug. El fix —devolver el objeto nuevo con spread— es de la fase, y acá no hay refactorización alternativa que discutir: mutar es un bug, no un estilo.

### Paso 5 bis — La prueba que lo convierte en excepción

Si quieres que el siguiente caso de esta familia se diagnostique en diez segundos en vez de en treinta minutos, enciende la comprobación en tu rama antes de buscar:

```typescript
// app.module.ts, solo mientras investigas
StoreModule.forRoot({}, {
  runtimeChecks: { strictStateImmutability: true }
})
```

Con eso, la mutación deja de producir silencio y produce una excepción con nombre y línea en el instante en que ocurre. **No lo dejes encendido en un hotfix:** sobre siete slices escritos por gente distinta va a hacer fallar el arranque en algún sitio que nadie ha tocado en meses, y eso es un ticket con fecha, no una línea que se cuela un viernes. El catálogo completo está en el [**Apéndice A06 §9.4**](./a06-ngrx.md).

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| La acción no aparece en el log | el `dispatch` nunca ocurrió | el `(click)` y el método del componente |
| La acción aparece y el Diff está vacío | el `case` no existe, o el `type` no coincide | el `switch` del reducer, y el `default` |
| Diff correcto y pantalla vieja, se arregla con el deslizador | mutación del estado: el selector no emitió | el `case` que asigna en vez de devolver |
| Diff correcto y pantalla vieja, **no** se arregla con el deslizador | la plantilla no lee o compara mal ese campo | el `.html` del componente |
| El estado entero se ve como `undefined` en el árbol | la cadena de `createFeatureSelector` no coincide con la de `forFeature` | las dos cadenas, que son strings sueltas |
| Todo se ve bien y la pantalla quedó vacía sin error | el módulo diferido no cargó | Network, filtro `JS`, al navegar |
| El primer fallo se ve y el botón de reintentar no hace nada nunca más | `catchError` fuera del `switchMap`: el effect murió | el `pipe` del effect, y el log, que se queda mudo |

Esa última fila merece su propia comprobación, porque es la que más se confunde con un problema de red: apaga el mock, recarga, mira `[Patients] Load Patients Failure` en el log, vuelve a levantar el mock y pulsa reintentar **sin recargar**. Si el log no registra ninguna acción nueva, el effect ya no está escuchando y el problema no es el servidor: es que el error subió hasta el observable de acciones y lo completó.

---

## ⚰️ Los callejones

**"Es que el mock devolvió mal los datos."** El paso 2 lo tumba antes de abrir Network: si el Diff muestra el valor correcto dentro del estado, el dato llegó bien. Y el propio ticket lo decía —"recargué y apareció bien"—, que es la forma que tiene un usuario de contarte que el servidor nunca fue el problema.

**"La suscripción se rompió."** Plausible, porque el componente de esta fase se suscribe tres veces a pelo y no se desuscribe nunca. Pero una suscripción rota no se arregla moviendo el deslizador, y acá se arregla: el canal está vivo, lo que no hubo fue emisión. La familia de bugs que sí produce ese leak se mide en [`forense-fase-10.md`](./forense-fase-10.md).

**"Hay que ponerle `OnPush` / quitarle `OnPush`."** Es la respuesta refleja a cualquier "no se actualiza la pantalla", y en este curso casi nunca es la causa. La detección de cambios sólo entra en la conversación cuando el selector **sí** emitió y aun así el DOM no cambió, que es un caso distinto y se persigue en la Fase 10.

**"Se pulsó dos veces, así que hay una carrera."** Dos acciones seguidas en el log describen lo que hizo el usuario, no una condición de carrera. En esta fase el `switchMap` del effect cancela la primera carga y la segunda gana, sin pérdida visible. Donde ese mismo "le di dos veces" sí cuesta un registro es en las escrituras, y eso es la Fase 5.

---

## 🧨 Deshacer

Si provocaste la mutación a propósito, se revierte en el mismo `case` donde la escribiste y `ng serve` recompila solo. Dos avisos:

- **El deslizador deja la aplicación en un estado del pasado.** Suéltalo en la última acción antes de seguir trabajando, o recarga: si no, vas a diagnosticar la siguiente cosa sobre un estado congelado y no vas a entender nada.
- **Si encendiste `runtimeChecks`,** quítalo antes de commitear. Es una decisión de proyecto, no un cambio de investigación, y colarlo en un commit de hotfix es exactamente lo que la fase te pide no hacer.

---

## 🧠 El patrón transferible

> **Un estado correcto que nadie mira no es un estado correcto.** Antes de buscar por qué un dato está mal, pregunta si el dato está bien y lo que falló fue el aviso. En un store inmutable, "no se enteró nadie" y "el valor es incorrecto" son dos bugs con causas opuestas, y el deslizador los separa en cinco segundos sin abrir un archivo.

Y el segundo, que vale para cualquier sistema con log de eventos: **el log de acciones es el testimonio del usuario, traducido**. "Le di dos veces" es una frase vaga; dos acciones consecutivas con su marca de tiempo no lo son. Aprender a convertir una en la otra es lo que te deja empezar una investigación sin haber podido hablar con quien reportó.

**Incidentes del cuaderno que usan esta ruta:** el **03** —*"cambié el paciente y la lista no se entera"*—, que es este mismo síntoma con la causa escondida un poco más lejos.
**Amplía:** el [**Apéndice A06**](./a06-ngrx.md) para el catálogo de `runtimeChecks` y el detalle de la memoización de `createSelector`, y el [**A05**](./a05-rxjs.md) para por qué un `catchError` mal colocado mata un effect. La convención de commits con la que se registra una investigación está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
