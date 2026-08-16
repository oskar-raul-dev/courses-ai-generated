# 🕵️ Forense Fase 05 — "A veces guardo un paciente y se guarda dos veces"

> Pieza forense de la [**Fase 5 — Pacientes**](./05-pacientes.md) · Recorrido: ~45 min · [Índice del track](./forense-master.md)
> Herramientas: el log de acciones · `CHAOS=latency` · Network · `db.json`
> Síntoma que cubre: un ticket sin pasos, sin hora y sin nombre, sobre un duplicado que no se reproduce.

Éste es el primer ticket del curso que llega **sin nada**: no hay error, no hay captura, no hay paciente. Lo único que hay es una frase y un log de acciones que alguien tuvo la decencia de exportar. La fase te dio los tres movimientos; acá están las salidas de cada uno y el punto exacto donde la investigación se bifurca en dos caminos que no se parecen en nada.

---

## 🎫 El ticket

> *"A veces guardo un paciente y se guarda dos veces. No siempre. Creo que pasa más a primera hora."*

**Reportado por:** una auxiliar de recepción
**Ambiente:** UAT
**Adjunto:** un `.json` exportado de Redux DevTools, sin fecha

"A primera hora" no es folclore: es el único dato técnico del ticket. A primera hora la sucursal comparte la línea con el respaldo nocturno y el servidor va lento. Guárdalo, porque es la respuesta a la primera pregunta del método.

---

## 🧭 La ruta

Seis pasos, del más barato al más caro. Los tres primeros no abren un solo archivo del proyecto; el cuarto abre uno y el quinto decide qué se cambia. **El orden importa más que de costumbre**, porque el paso 2 parte la investigación en dos ramas y equivocarse de rama cuesta medio día.

### Paso 1 — ¿Se reproduce, y con qué?

Antes de leer código: intenta reproducirlo con el mock rápido. Abre `/patients`, crea un paciente, mira la tabla.

Con el mock normal es **imposible**: la respuesta vuelve en veinte milisegundos y la ventana en la que el usuario podría equivocarse no existe. Ahora enciende la latencia y repite exactamente lo mismo:

```bash
CHAOS=latency=3000 npm run mock
```

**Qué descarta.** Si con `latency=3000` el síntoma aparece a la primera, muere la hipótesis "es intermitente y hay que esperar a que pase": no es intermitente, es de temporización, y acabas de aprender a provocarlo. Si con latencia tampoco aparece, no sigas por acá — salta al paso 6, que es la otra rama.

> 🧭 **El patrón, y es de los que más veces vas a usar:** un bug que no reproduces no es un bug intermitente, es un bug de temporización que todavía no aprendiste a provocar. "Pasa más a primera hora" y `CHAOS=latency` son la misma frase dicha por dos personas distintas.

### Paso 2 — ¿Dos acciones, o una?

Ésta es **la** pregunta de la investigación, y se contesta mirando el log exportado sin tocar nada. Redux DevTools → **Actions**, o el `.json` adjunto abierto en el editor. Cuenta las acciones de escritura:

```
[Patients] Upsert Patient
[Patients] Create Patient
[Patients] Upsert Patient
[Patients] Create Patient
[Patients] Create Patient Success
[Patients] Load Patients
[Patients] Create Patient Success
[Patients] Load Patients
[Patients] Load Patients Success
[Patients] Load Patients Success
```

**Qué descarta.** Y acá está la bifurcación completa del ticket:

- **Dos `Create Patient`** (la salida de arriba) → el usuario **pudo** pedir dos veces. El sistema hizo exactamente lo que se le pidió: dos altas. El bug está del lado del navegador —qué le dejó pedirlo dos veces— y la investigación sigue en el paso 3.
- **Una sola `Create Patient` y dos registros en `db.json`** → el navegador pidió una vez. El duplicado nació del lado del servidor o de un reintento HTTP, y ésta es **otra investigación**, con otras herramientas: los logs del mock, el `request-id` de la Fase 3, y ninguna de las cuatro pantallas que vas a mirar en los pasos siguientes. Salta al paso 6.

Una mirada al log y medio día ahorrado. Por eso este paso va segundo y no cuarto.

### Paso 3 — ¿Qué vio el usuario entre las dos acciones?

Con `latency=3000` puesto, repite el alta y **no toques nada durante los tres segundos**. Cronometra lo que ve la auxiliar:

```
t=0.0s  pulsa Guardar
t=0.0s  el dialogo se cierra           ← la unica confirmacion que recibe
t=0.0s  la tabla sigue exactamente igual
t=3.0s  POST /patients -> 201
t=3.0s  arranca la recarga de la lista (loadPatients)
t=6.0s  la tabla parpadea y aparece el paciente nuevo
```

Seis segundos de nada, con la tabla mostrando lo de antes y ningún indicador de que algo esté pasando. **Qué descarta.** Muere la hipótesis del doble clic: no hace falta pulsar dos veces el botón —el diálogo ya se cerró— para que se guarde dos veces. Basta con volver a abrir el formulario y guardar otra vez, que es exactamente lo que hace cualquiera que crea que la primera vez no funcionó. El bug no está en el botón: está en que **el sistema no tiene forma de decir "estoy trabajando"**.

Y hay un agravante que se ve en el mismo cronómetro: el paciente tarda seis segundos y no tres, porque `reloadAfterWrite$` vuelve a pedir la lista entera después de cada escritura. La deuda 💸 de §5.8 no es sólo lenta: **duplica la ventana de confusión**.

### Paso 4 — ¿Y el validador de documento duplicado, que existe para esto?

Legítimo preguntarlo: el formulario tiene un validador asíncrono que consulta si el `documentId` ya está tomado. Compruébalo en Network, filtro `XHR`, mientras escribes el documento repetido:

```
Name                                  Status  Type  Time
patients?documentId=CC-1032456789     200     xhr   3.0 s
patients                              201     xhr   3.0 s
```

**Qué descarta.** El validador salió, y aun así el duplicado entró. Tres razones, y las tres están escritas en el código de la fase: el validador consulta **antes** de que el primer POST haya llegado al servidor, así que no encuentra nada; su propia consulta viaja con la misma latencia que todo lo demás; y su `catchError` devuelve `of(null)` a propósito, es decir, **ante la duda deja pasar**. Esa decisión está discutida en el ejercicio 30 de la fase y no es un descuido: un backend caído no puede impedirle a alguien registrar un paciente.

Muere entonces la hipótesis "el validador está roto". Funciona; lo que no puede es validar contra un dato que todavía no existe.

### Paso 5 — El campo que nadie mira

Abre el estado en el panel **State** justo después de pulsar Guardar, mientras la petición viaja:

```json
{
  "patients": {
    "items": [ … ],
    "loading": false,
    "saving": true,
    "saveError": null
  }
}
```

`saving: true`. El reducer lo pone en los tres verbos de escritura y lo apaga en el éxito y en el fallo, hay un `selectPatientsSaving` exportado en `patients.selectors.ts`… y ninguna plantilla lo consume:

```bash
grep -rn "selectPatientsSaving" src/
# src/app/patients/store/patients.selectors.ts:  export const selectPatientsSaving = ...
```

Una sola línea de salida: el selector existe y nadie lo usa.

**Qué descarta.** La ruta termina acá, con el bug localizado y con algo mejor que una causa: el sistema **ya sabía** que estaba guardando y no se lo contó a nadie. No falta información; falta conectarla.

Y con eso el fix mínimo se decide solo, que es el tercer movimiento de la fase:

- **Consumir `saving` en la vista** —deshabilitar el botón, dejar el diálogo abierto hasta el éxito, o cualquier señal visible— es un hotfix de una línea de plantilla y cambia el comportamiento de una pantalla.
- **Cambiar `mergeMap` por `exhaustMap` en `createPatient$`** es también una línea, y hace que el store ignore cualquier alta que llegue mientras hay una en curso. Suena mejor, y es un cambio de arquitectura disfrazado de una línea: afecta a **todas** las escrituras del sistema, incluidas las que sí deben poder solaparse (dos recepcionistas dando de alta a dos pacientes distintos al mismo tiempo, que es el caso normal de un laboratorio a primera hora).

Saber cuál de los dos estás haciendo es la mitad del oficio. El primero es un hotfix; el segundo es un ticket con fecha.

### Paso 6 — La otra rama: una acción, dos registros

Si el paso 2 te trajo acá, olvida todo lo anterior: el navegador pidió una vez. Tres comprobaciones, en orden de costo:

```bash
# 1. ¿Cuántos POST salieron de verdad? Network, filtro XHR, columna Name.
#    Uno solo -> el navegador no reintento.

# 2. ¿Qué vio Express? El log del mock imprime una línea por petición.
#    Dos líneas con el MISMO request-id = un reintento en algún punto del camino.
#    Dos líneas con request-id DISTINTO = dos peticiones de verdad, y el paso 2
#    del log de acciones estaba mal contado.

# 3. ¿Estaba ya en el dato? El duplicado puede ser más viejo que el ticket.
grep -c '"documentId": "CC-1032456789"' db.json
```

**Qué descarta.** Si el `request-id` se repite, el duplicado lo produjo un reintento —de un proxy, del propio navegador ante una conexión cortada— y el fix no está en Angular: está en hacer la operación idempotente del lado del servidor. Si los `request-id` difieren, vuelve al paso 2 y cuenta otra vez. Y si el duplicado ya estaba en `db.json` antes del ticket, no hay bug: hay un dato sucio, y es la pregunta 🧬 del método —¿lo escribió el sistema, o llegó ya roto?— contestada del lado incómodo.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| Dos `Create Patient` en el log | el usuario pidió dos veces, y con razón | el cronómetro del paso 3 |
| Una `Create Patient` y dos registros | reintento o duplicado del servidor | el `request-id` en el log del mock |
| Dos POST en Network, uno **cancelado** | `switchMap` en una escritura: hay un alta perdida | el operador de aplanado de `createPatient$` |
| Dos `Create Patient` y un solo `Success` | lo mismo, visto desde el store | el log, contando pares |
| La tabla parpadea después de guardar | `reloadAfterWrite$`: no es un bug de render | la deuda 💸 de §5.8 |
| El botón sigue habilitado mientras se guarda | `[disabled]="patientForm.invalid"`, y `saving` no se consume | la plantilla del diálogo |
| El botón sigue habilitado con el documento duplicado a medio validar | `pending` **no es** `invalid` | el mismo `[disabled]`, y la guarda de `save()` |
| El validador asíncrono no encuentra el duplicado | consultó antes de que el primer POST llegara | Network, comparando tiempos |
| El validador asíncrono no sale en Network nunca | está en la segunda posición del `FormBuilder`, no en la tercera | la firma `[valor, sincronos, asincronos]` |

---

## ⚰️ Los callejones

**"El reducer está insertando dos veces."** Es la primera sospecha de mucha gente y se descarta en diez segundos: el reducer de esta fase **no inserta nada** en `createPatientSuccess`, sólo apaga `saving`. Los pacientes de la tabla llegan siempre de una recarga completa. Si hay dos, están en el servidor.

**"Es una condición de carrera entre los dos effects."** No hay carrera: `upsertPatient$` no toca la red, sólo traduce una intención en `createPatient` o `updatePatient` según haya `id` o no. Dos `Upsert Patient` en el log son dos intenciones del usuario, no una que se desdobló.

**"Poniendo `exhaustMap` se arregla."** Se arregla el síntoma, sí. Y de paso se rompe el caso normal del laboratorio a primera hora, cuando dos recepcionistas están dando de alta a dos pacientes distintos y la segunda alta se descarta en silencio porque la primera todavía viaja. Un operador de aplanado es una **decisión de negocio** escrita como una palabra de siete letras.

**"Hay que deshabilitar el botón al pulsarlo."** Correcto y suficiente para el hotfix, pero ojo con el orden: en esta fase el diálogo **se cierra** al pulsar, así que el botón deshabilitado no impide nada por sí solo. Lo que hay que impedir es la segunda apertura del formulario mientras la primera alta viaja, y eso se hace con `saving`, no con `disabled`.

---

## 🧨 Deshacer

El recorrido escribe en `db.json`, así que deja rastro de verdad:

```bash
npm run seed        # devuelve el dato a la semilla de la Fase 5
```

Y si probaste el 🧨 de la fase —cambiar `mergeMap` por `switchMap` en `createPatient$`—, revierte esa línea antes de seguir. Es la única del recorrido que rompe una clase entera de operaciones, y olvidada puesta te va a costar la siguiente investigación entera: con `switchMap`, un alta que se pierde **no despacha ningún fallo**, porque una cancelación de RxJS no es un error y `catchError` no se entera.

Apaga también el caos (`Ctrl+C` en el mock y arráncalo sin la variable), o vas a diagnosticar las siguientes tres fases con tres segundos de latencia y culpando a tu máquina.

---

## 🧠 El patrón transferible

> **"A veces" es una palabra sobre el reloj, no sobre la suerte.** Cuando un ticket diga "a veces", "a primera hora" o "cuando hay mucha gente", tradúcelo a latencia y reprodúcelo a voluntad. La mitad de los bugs intermitentes de una SPA son ventanas de tiempo en las que el sistema no le cuenta al usuario lo que está haciendo.

Y el segundo, que es el que decide el rumbo de la investigación: **cuenta las intenciones antes de buscar la causa**. Dos acciones en el log y dos registros en la base es un sistema obediente con una interfaz muda; una acción y dos registros es un problema de red o de servidor, y no comparte ni una sola herramienta con el anterior. Contarlas cuesta treinta segundos y es lo primero que se hace.

**Incidentes del cuaderno que usan esta ruta:** el **10** —*"guardo y a veces no se guarda"*, que es esta misma ventana vista desde el lado de la pérdida— y el **09** —*"el paciente que di de baja sigue saliendo en la lista"*, que se diagnostica con el mismo reflejo de preguntar qué selector consume cada pantalla.
**Amplía:** el [**Apéndice A05**](./a05-rxjs.md) para la diferencia entre `mergeMap`, `switchMap`, `concatMap` y `exhaustMap` con su tabla de cuándo usar cuál, y [`forense-fase-04.md`](./forense-fase-04.md) para los modos del inyector de caos que convierten un "a veces" en un "siempre".
