## Incidente 18 — La conciliación da un centavo de diferencia

> **Fase:** 8 · **Categoría:** Dinero · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min
> · Hermano del incidente `be-13`, con otra causa raíz

### 🎫 El ticket

El prorrateo del paquete tok-ago-05 suma US$21,00 y el paquete se vendió a US$20,99.
Un centavo. Ya sé que suena a nada y que me van a decir que lo redondee, pero no
firmo una conciliación sin saber de dónde sale cada centavo. Y antes de que me lo
pregunten: revisé los otros tres paquetes de 500 de agosto, y uno da el mismo
centavo de más, otro cuadra y otro da un centavo de menos. ¿Y ese centavo de dónde
salió?

**Reportado por:** contabilidad (Licda. De Gracia)
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir con los datos exactos del reporte, localizar el cálculo culpable y
arreglarlo. Y contestarle a la contadora las dos cosas que su ticket deja planteadas:
**por qué un paquete descuadra para arriba, otro para abajo y otro no descuadra**, y
**cuánto puede llegar a ser el error**.

Este incidente es el más chico del cuaderno en tamaño del síntoma y de los más
grandes en tamaño de la causa. Esa desproporción es la lección entera.

### 🔧 Preparación

- **Rama:** `incidente/18`, desde `fase-08-conciliacion`.
- **Caos:** `off`. No hay ninguna red involucrada en el error: es aritmética.
- **Datos:** los de la fase, sembrados con `npm run seed:reconciliation`. El paquete
  `tok-ago-05` es el primero de 500 giros que la bitácora consume entero, y es el
  que la pantalla muestra.

```bash
git checkout incidente/18
npm run seed:reconciliation        # con los mocks parados
npm run mock:all
npm start
# /reconciliation → Rueda de fin de mes → mira «Prorrateo del paquete tok-ago-05» y la suma de sus filas.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No hace falta la aplicación. Copia los ocho conteos de la tabla del prorrateo, abre
una consola de Node, y calcula a mano lo que vale cada fila: los giros de la fila por
el precio de un giro. Antes de redondear nada, anota con todos sus decimales lo que
vale un giro.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/reconciliation/reconciliationSlice.js`, la línea que arma
`packageProration`, y la función a la que llama. La Fase 8 pide una regla: **el
dinero se reparte con división entera y el resto explícito**. Busca el punto exacto
donde la regla se rompe.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si redondeas cada fila al centavo más cercano, cada fila se equivoca en menos de
medio centavo, para arriba o para abajo. ¿Qué pasa con esos errores cuando sumas
ocho filas? ¿Y de qué depende hacia qué lado caigan?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, con los valores exactos: el precio, los ocho conteos, la suma que
esperabas y la que salió.}}

**Evidencia observable**
{{El resultado de correr la cuenta en la consola, fila por fila, con todos sus
decimales antes de redondear. Este es uno de los incidentes del cuaderno donde la
evidencia decisiva no está en el navegador.}}

```text
{{conteo · valor sin redondear · valor redondeado, por fila; y las dos sumas}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y en cuál de las cuatro capas de auditoría de la Fase 8 apareció:
el cálculo, sus entradas, el estado o la presentación.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta. Y la respuesta a la
contadora: por qué cada paquete descuadra distinto, y cuánto puede ser el error.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El panel prorratea con `prorateSpinPriceBroken`, la versión del ejercicio 18 de la
Fase 8 que alguien conectó "un momento" y no desconectó. Calcula el precio de un giro
en dólares y redondea cada fila:

```javascript
// ❌ 0,04198 dólares por giro, y cada fila redondeada por su cuenta.
const perSpinDollars = packagePriceCents / 100 / spins;
return counts.map((count) => Math.round(count * perSpinDollars * 100));
```

En la consola, con los conteos de `tok-ago-05`:

```text
148 giros · 621,304 → 621        57 giros · 239,286 → 239
 95 giros · 398,810 → 399        38 giros · 159,524 → 160
 71 giros · 298,058 → 298        13 giros ·  54,574 →  55
 74 giros · 310,652 → 311         4 giros ·  16,792 →  17
                                  suma: 2.100 (el paquete: 2.099)
```

Cada fila está **bien redondeada**: ninguna se equivoca en más de medio centavo. El
problema no está en ninguna fila; está en sumarlas. Cinco filas redondean para
arriba y tres para abajo, y los errores no se compensan: suman +1. El float agrega
su granito (el precio por giro es `0.041979999999999996`, no 0,04198), pero no es la
causa: con aritmética exacta, el redondeo por fila da el mismo 2.100.

La causa está en la **primera** de las cuatro capas de auditoría de la Fase 8: el
cálculo. Y por eso el diagnóstico se hace en una consola de Node, sin abrir el
navegador.

**La respuesta a la contadora**

Las dos preguntas tienen una sola respuesta: **el error depende de cómo cayeron los
giros**. Con ocho filas, cada una se equivoca entre −0,5 y +0,5 centavos, y la suma
de los errores puede dar −4, −3… hasta +4, según el reparto. En agosto, con los mismos
2.099 centavos, `tok-ago-05` da 2.100, `tok-ago-19` da 2.099 y `tok-ago-26` da
2.098. Ninguno de los tres está "más roto" que los otros: los tres usan el cálculo
equivocado, y uno tuvo suerte.

La respuesta honesta a *"¿cuánto puede ser?"* no es *"un centavo"*. Es: **hasta medio
centavo por fila, en cualquier dirección, y no se cancela por promedio**. Con ocho
filas, hasta cuatro centavos por paquete. Con un reporte por jugador en vez de por
segmento —miles de filas—, cualquier cosa. Por eso no se acota: se elimina.

> 🧠 **La desproporción es el mensaje.** El síntoma mide un centavo. La causa es
> que el cálculo reparte dinero sin garantizar que las partes sumen el todo. Un
> ticket pequeño puede tener una causa estructural, y la magnitud del síntoma no
> dice nada sobre la magnitud del problema. En dinero, esa confusión es
> especialmente cara: **el redondeo esconde el error justo lo suficiente como para
> que nadie lo investigue**, y que un paquete cuadre es lo que más lo esconde.

**Parche mínimo**

Volver a conectar el panel a `prorateSpinPrice`, que reparte con `prizeShare`:
división entera para todos los giros, y el resto —99 centavos— de a uno.

```javascript
cents: prorateSpinPrice(big.packagePriceCents, countLanded(spinsByToken.get(token), segments)),
```

Con los mismos conteos: 691, 380, 284, 296, 228, 152, 52 y 16 centavos. **2.099.**

La Fase 8 es explícita sobre cómo llamar a esto: **no es refactor, es sacar el
redondeo por fila de la línea que lo metió.**

**La refactorización correcta**

Que la versión rota no pueda volver a entrar:

1. **Borrar `prorateSpinPriceBroken`.** Una función equivocada escrita "al lado de la
   buena, para el ejercicio" es una trampa con nombre propio. El ejercicio vive en el
   repo del alumno, no en el código de la consola.
2. **La invariante en el cálculo, no en la pantalla.** `prorateSpinPrice` podría
   terminar con una aserción —que la suma de las filas sea el precio— y lanzar si no.
   Igual que `formatCents` con los floats: falla donde está el error.
3. **Repartos con resto explícito en todas partes.** Cualquier cálculo que divida
   dinero entre partes pasa por `prizeShare`. La mecánica está en
   `A10-aritmetica-de-dinero.md` §4.

**Prueba de regresión**

```javascript
// src/features/reconciliation/reconciliationSlice.proration.test.js (la misma prueba que corre en el repo de prueba)
import { store } from "../../app/store";
import { login } from "../auth/authSlice";
import { fetchReconciliation } from "./reconciliationSlice";

test("el prorrateo del paquete que muestra la conciliación suma exactamente su precio", async () => {
  await store.dispatch(login({ email: "mdegracia@esclusa.test", password: "esclusa123" }));
  await store.dispatch(fetchReconciliation(4));
  const { purchaseToken, cents, packagePriceCents } = store.getState().reconciliation.packageProration;
  expect(purchaseToken).toBe("tok-ago-05");
  expect(cents.reduce((sum, c) => sum + c, 0)).toBe(packagePriceCents); // con el bug: 2100 contra 2099
}, 20000);
```

Con la rama `incidente/18` falla (`Expected: 2099`, `Received: 2100`); con el parche,
pasa. Corre contra los dos mocks, porque lo que se prueba es lo que **la pantalla**
muestra: una prueba de `prorateSpinPrice` sola pasaba con el bug adentro, porque la
función buena nunca estuvo rota.

El detalle que hace útil esta prueba es lo que **no** usa. `toBeCloseTo` es la
herramienta correcta para medir cosas del mundo físico y la herramienta equivocada
para el dinero: una prueba de dinero que tolera aproximaciones aprueba justamente el
bug que tiene que impedir.

**Prevención**

La invariante "las partes suman el todo" escrita como prueba de propiedad (ejercicio
26 de la Fase 8): para cualquier precio y cualquier conjunto de conteos, las filas
suman el precio. Y una regla de revisión de código: un `Math.round` dentro de un
`map` sobre dinero es un hallazgo, siempre.

**Por qué llegó a producción**

Porque la versión rota **se ve bien**. Cada fila tiene un valor razonable, ninguna
tiene decimales raros, y con muchos paquetes la suma cuadra: en agosto, uno de cada
cuatro paquetes de 500 dio exacto. Quien la probó con un solo paquete pudo tener la
suerte de elegir el que cuadraba.

Y sobrevivió, sobre todo, por una reacción cultural que el ticket anticipa: *"me van
a decir que lo redondee"*. En la mayoría de los equipos, un centavo de diferencia se
cierra como "error de redondeo, no es nada". La contadora que se negó a firmar hasta
entenderlo hizo exactamente lo correcto, y es la razón por la que este incidente
existe.

**Si tu causa fue distinta a esta**

Si dijiste *"es el float de 0,04198"*, es media verdad: el float existe, y es mala
práctica, pero no explica este centavo. Haz la cuenta con fracciones exactas
(`count * 2099 / 500`) y redondea: da el mismo 2.100. Si dijiste *"falta redondear
el total"*, ese es el reflejo que hay que desarmar: redondear **es** la causa.
Agregar un redondeo más al final no arregla el reparto, lo disfraza mejor.

**Y acá está el cruce con el track BE.** El incidente `be-13` —*"la conciliación y el
reporte de la tienda no dan lo mismo"*— tiene un descuadre parecido y una causa
distinta: allá la aritmética está bien y lo que falla es **la fuente de los datos**.
Acá los datos son correctos y el cálculo los arruina. Cuando una cifra no cuadra,
esas son las dos preguntas, en este orden: *¿el cálculo está mal?* y *¿los datos que
entraron eran los de ahora?*

</details>

---

