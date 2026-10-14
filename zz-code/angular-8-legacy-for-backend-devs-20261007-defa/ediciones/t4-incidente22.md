## Incidente 22 — La muestra llegó al laboratorio antes de que se la sacaran al paciente

> **Fase:** 7 · **Categoría:** Tiempo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-90 min · **Ruta forense:** [`forense-fase-07.md`](./forense-fase-07.md), paso 5

### 🎫 El ticket

> *"Calidad me trae la línea de custodia de varias muestras de Gatineau y dice que
> llegaron al laboratorio antes de que se las sacaran al paciente. La de esta
> mañana: tomada a las 10:00, recibida a las 9:38. El auxiliar de Gatineau jura
> que la sacó a las 9 en punto, y la agenda de allá le da la razón. No es una sola,
> y en febrero no pasaba."*

**Reportado por:** directora de operaciones
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicarle a Calidad, con evidencia, **qué hora es la verdadera**, desde cuándo
pasa y a cuántas muestras afecta. Y dejar algo que lo detecte, porque arreglarlo
no está en tus manos.

No termina en fix.

### 🔧 Preparación

Un `db.json` alterno con las muestras de esa semana: las de Gatineau, tal como las
copió al sistema la interfaz de su agenda, y una de Ottawa como control.

```bash
cp db.json db.json.mio
cp db.incidente-22.json db.json
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

La pantalla y la agenda no discrepan en el día ni en los minutos: discrepan en
**una hora exacta**. Deja la pantalla y mira el dato crudo: no qué hora dice cada
marca, sino **cómo está escrita**.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Compara el `collectedAt` de las muestras de Gatineau con el de la muestra de
Ottawa, y quién las escribió (`collectedBy`). Después busca la última muestra de
Gatineau que salió bien y la primera que salió mal.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué cambió en Ottawa entre el viernes 12 y el lunes 15 de marzo de 2021: el
desfase que escribe la agenda, o el desfase que de verdad tiene la ciudad?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```

```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

La toma de Gatineau no la escribe LabCore. El punto de toma que Andina compró en
2020 sigue registrando las tomas en la agenda de la clínica, y desde noviembre de
2020 una interfaz las copia a LabCore. Esa interfaz arma `collectedAt` con **la
hora de la pared y el `-05:00` de la Era 1 pegado**. En invierno es verdad; desde
el 14 de marzo de 2021, que es el segundo domingo de marzo, Ottawa y Gatineau
están en `-04:00`, y cada toma queda escrita **una hora más tarde** de cuando
ocurrió.

La evidencia, en el orden en que hay que producirla:

1. **Las dos marcas no se escribieron igual.**

   ```bash
   curl -s "http://localhost:3000/samples?id=7202&id=7210"
   ```

   ```
   7202  collectedBy: agenda-gatineau  collectedAt: "2021-03-15T09:00:00-05:00"
         receivedBy:  analista2        receivedAt:  "2021-03-15T13:38:00.000Z"
   7210  collectedBy: analista1        collectedAt: "2021-03-15T13:05:00.000Z"
         receivedBy:  analista2        receivedAt:  "2021-03-15T13:50:00.000Z"
   ```

   La de Ottawa la estampó el navegador, en `Z` (Fase 7 §5.5). La de Gatineau
   trae un desfase escrito a mano. Esa diferencia de formato es la huella de quién
   escribió cada cosa.

2. **La aritmética, sin pantalla de por medio.**

   ```
   collectedAt  2021-03-15T09:00:00-05:00   ==   14:00Z   ==   10:00 en Ottawa
   receivedAt   2021-03-15T13:38:00.000Z                 ==   09:38 en Ottawa
   ```

   ```js
   new Date('2021-03-15T09:00:00-05:00').toLocaleString('es', { timeZone: 'America/Toronto' })
   // '15/3/2021, 10:00:00'
   ```

   La pantalla no miente: `appDate` convierte bien y dice 10:00 porque **el dato
   dice 10:00**. El auxiliar tampoco miente: escribió 09:00 en la agenda. Lo que
   miente es el `-05:00` que la interfaz le pegó a esas 09:00 un lunes de marzo.

3. **La fecha en que empezó.** La 7201, del viernes 12, tiene el mismo formato y
   está bien: ese día Ottawa todavía estaba en `-05:00`. La 7202, del lunes 15,
   está corrida. Entre las dos hay un domingo: el **14 de marzo de 2021**, el día
   del cambio de hora. Y el problema volverá a desaparecer solo el 7 de
   noviembre, cuando la ciudad vuelva a `-05:00`, sin que nadie haya tocado nada.

> 🧬 La pregunta del método, contestada: **el sistema no escribió esto** —ni el
> reducer, ni el effect, ni el navegador—. Llegó así de otro sistema, igual que
> en el incidente **11**, y por eso ninguna línea de la Fase 7 tiene la culpa.

Que una toma de Gatineau aparezca **antes** de su recepción depende de una sola
cosa: que la muestra llegue a Ottawa en menos de una hora. Con más margen, el
orden se conserva y la hora sigue corrida sin que nada lo delate —es la 7203—.
Por eso el ticket dice *"varias"* y no *"todas"*: las corridas son todas; las que
se notan son las del mensajero de la mañana.

**Parche mínimo**

En el código de LabCore, **ninguno**: la interfaz no es nuestra. Lo que sí se
hace hoy es contener, y tiene tres partes.

La primera es **un detector**. Un `-05:00` escrito en una fecha en que Ottawa
estaba en `-04:00` es comprobable, y para comprobarlo ya tienes la función que
hace falta: el `offsetAt` del pipe de la Fase 2.

```typescript
// src/app/shared/offset-check.ts
import { offsetAt } from './app-date.pipe';

// True when an ISO string carries a hand-written offset that the zone did not
// have at that instant: the Era 1 '-05:00' written in summer. 'Z' and strings
// without an offset are not judged here.
export function offsetDoesNotMatchZone(iso: string, timeZone: string): boolean {
  var match = /([+-])(\d\d):(\d\d)$/.exec(iso);
  if (!match) { return false; }
  return match[1] + match[2] + match[3] !== offsetAt(new Date(iso), timeZone);
}
```

La segunda es **la nota, no la corrección**. Igual que en el 11, el `collectedAt`
no se reescribe: es evidencia de custodia, y cambiarla a mano es fabricar una
firma. Se agrega al lado lo que se puede sostener —la hora de la agenda,
interpretada en la zona correcta—:

```bash
curl -X PATCH http://localhost:3000/samples/7202 \
  -H "Content-Type: application/json" \
  -d '{"custodyNote":"collectedAt con -05:00 en horario de verano (incidente 22); hora de la agenda 09:00 en Ottawa = 2021-03-15T13:00:00Z"}'
```

La tercera es **el texto para Calidad**, que es el entregable de verdad: *"Toda
toma de Gatineau registrada por la agenda desde el 14 de marzo de 2021 figura una
hora más tarde de lo ocurrido. La hora válida es la de la agenda. Lo
detectamos así, son N muestras, y seguirá pasando hasta el 7 de noviembre y otra
vez desde el segundo domingo de marzo de 2022, salvo que alguien cambie la
interfaz."* El número N sale del detector, no de una estimación.

**La refactorización correcta** (que en Track A 💸 no se paga)

Que la interfaz deje de pegar un desfase: que mande el instante en UTC, o que
calcule el desfase **para esa fecha** con la zona (`ZoneId.of("America/Toronto")`
en Java, `Intl` en JavaScript). Es una línea en un sistema que escribió la
consultora y que hoy no tiene dueño: está del otro lado, como el backend. El
apéndice **`bea-08` §8** cuenta esta misma deuda vista desde el servidor.

**Prueba de regresión**

Lo que se blinda desde aquí no es la interfaz sino el detector: que encuentre el
caso y que no acuse a los que están bien.

```typescript
// src/app/shared/offset-check.spec.ts
import { offsetDoesNotMatchZone } from './offset-check';

describe('offsetDoesNotMatchZone', function () {
  var ottawa = 'America/Toronto';

  it('marca el -05:00 escrito en horario de verano', function () {
    expect(offsetDoesNotMatchZone('2021-03-15T09:00:00-05:00', ottawa)).toBe(true);
  });

  it('no marca el -05:00 de invierno, que es verdad', function () {
    expect(offsetDoesNotMatchZone('2021-03-12T09:00:00-05:00', ottawa)).toBe(false);
  });

  it('no marca un -04:00 de verano ni una marca en Z', function () {
    expect(offsetDoesNotMatchZone('2021-03-15T09:00:00-04:00', ottawa)).toBe(false);
    expect(offsetDoesNotMatchZone('2021-03-15T13:38:00.000Z', ottawa)).toBe(false);
  });
});
```

**Prevención**

Correr el detector sobre las muestras **cada segundo domingo de marzo y cada
primer domingo de noviembre**, que son las dos fechas en que esta clase de error
cambia de signo; y la regla que se lleva a cualquier sistema: **una marca de
tiempo entra como instante, o con el desfase calculado para su fecha. Nunca con
uno escrito a mano.**

**Por qué llegó a producción**

La interfaz se escribió y se probó en noviembre de 2020, en invierno, con la
constante que el resto del sistema ya usaba y que en invierno es verdad. Su primer
cambio de hora fue el domingo 14 de marzo de 2021, cuando nadie de la consultora
estaba mirando; el lunes, el mensajero de las 9:30 hizo el resto. Ningún test
habría fallado en noviembre, porque ningún test corría con una fecha de julio. Y
la constante nació en un equipo que trabajaba desde Costa Rica, donde la hora no
cambia nunca: nadie se hizo la pregunta de marzo.

**Si tu causa fue distinta a esta**

- Si dijiste **"el reloj del auxiliar está adelantado"**, compruébalo y descarta:
  la diferencia es de una hora exacta en todas las muestras de Gatineau, empezó un
  día preciso, y la agenda —que usa el mismo reloj— dice la hora buena.
- Si dijiste **"el navegador de quien recibe está en otra zona"**, descarta con la
  7210: la recepción de Ottawa está en `Z` y cuadra con el registro del mensajero.
  Las recepciones están bien; las tomas no.
- Si dijiste **"`appDate` convierte mal"**, prueba la cadena con `toLocaleString`
  fuera de Angular: da lo mismo. El pipe convierte bien un dato que está mal.
- Si **corregiste el `collectedAt` a mano**, arreglaste la pantalla y destruiste la
  evidencia. Es el mismo error que el 11 entrena a no cometer.

</details>

---

