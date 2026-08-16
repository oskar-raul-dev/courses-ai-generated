# 📝 Fase VU2 — Migrar el CRUD a `v-form`

> **Ruta VU · Vuetify 2.6** · Migra: **F5 (CRUD de tickets)** · Consume: **VU0** (red de seguridad), **VU1** (leer Vuetify)
> Los tests de VU0 corren **sin tocarlos**. Verde o rojo. Y esa es la lección.

---

## 🧷 Antes de empezar: lo que esta fase da por hecho

Esta fase borra código y confía en piezas que otras dejaron listas. Si algo de
esto no está, no sigas: vuelve a la fase que lo entrega.

**VU1 te dejó** (si falta, es un bug de VU1, no de tu setup):

- Vuetify instalado con `vue add vuetify`, preset **"Configure (advanced)"**. **Tu
  `main.js` sigue vivo** — Vuetify no se comió el proyecto (ese fue el dato de VU1);
- `src/plugins/vuetify.js` con el objeto de configuración, el tema en JS y los
  iconos MDI declarados;
- **`<v-app>` envolviendo `App.vue`.** Grábate esto ahora, porque en esta fase te
  va a morder: sin un `<v-app>` ancestro, medio Vuetify no funciona **y no da error
  claro**. VU1 te lo advirtió; VU2 es donde se cobra;
- `Vue.use(Vuelidate)` **sigue en `main.js`**, igual que en el tronco. VU1 no lo
  tocó — a propósito. Lo vas a ver vivo antes de matarlo aquí.

**VU0 te dejó** (si falta, tus tests van a mentir):

- los tests de regresión del CRUD escritos sobre el **F5 a pelo**, con
  `data-testid`, **no** con selectores de clase de Bootstrap. Los IDs que VU0 fijó
  y que esta fase reutiliza: `ticket-title`, `ticket-description`,
  `ticket-priority`, `ticket-assignee`, `ticket-submit`, `ticket-cancel`;
- un test que verifica que `TicketForm` emite `submit` con `priority: "high"`
  (**string**, no objeto). Ese test es tu seguro contra el bug del Concepto 4;
- 🎯 **la divergencia propia de Vuetify que VU0 ya resolvió:** montar un componente
  Vuetify aislado con `mount()` **revienta** si no hay `<v-app>` ancestro. VU0
  decidió cómo darle uno al test sin acoplarlo al framework destino. Si tus tests
  de VU0 no arrancan, el problema es de VU0, no de esta migración.

> El orden de producción de la ruta es **VU0 → VU1 → VU2. Sin saltos.**

---

## 🎯 Propósito

Migrar `TicketForm.vue` de F5 a `<v-form>` + `<v-text-field>` + `<v-select>`, y el
borrado de `window.confirm` a `<v-dialog>`.

Y aquí toca ser honesto contigo desde la primera línea, porque este curso no te va
a vender humo:

> **La parte de validación de esta fase se parece muchísimo a su gemela Q2.**
> `v-form` + `:rules` ≈ `QForm` + `:rules`. Si vienes de leer Q2, medio Concepto 1
> te va a sonar. **No es pereza mía: es que Vuetify y Quasar copiaron la misma
> idea.** Reconocerlo es parte de aprender el ecosistema.

Entonces, ¿dónde está el trabajo de verdad de VU2? En dos sitios que **no** son
Quasar:

1. **`<v-dialog>`** — donde vive el CRUD (crear, editar, confirmar borrado). Este
   componente **se teletransporta en el DOM**, y eso tiene consecuencias reales
   sobre tus tests de VU0. **Es el peso alto de la fase.**
2. **La distinción `reset()` vs `resetValidation()`**, que no es la misma que en
   Quasar y que la gente confunde a diario.

Pero la **lección central** sí es idéntica de fuerte que en Q2, y no la voy a
diluir por más que el `:rules` se parezca:

> **Migrar a `:rules` no es cambiar un componente. Es sacar `vuelidate` del
> `package.json`.**

`vuelidate` **sale del proyecto en esta fase**. No porque esté roto —funciona
perfecto— sino porque `v-form` trae su propio sistema de validación, y tener los
dos es tener **dos fuentes de verdad** sobre si el formulario es válido. En un
legacy, eso es una bomba de relojería.

> La regla de la fase: **borra código propio y confía en el framework — pero
> sabiendo exactamente qué le entregaste, y qué te llevaste a cambio.**

---

## ✅ Qué queda listo al terminar

- `TicketForm.vue` reescrito con `<v-form>` + `<v-text-field>` + `<v-select>`,
  **sin vuelidate**;
- `vuelidate` desinstalado (`npm uninstall vuelidate`) y fuera de `main.js`;
- validación por campo con `:rules`, mensajes incluidos;
- `<v-form v-model="valid">`: el flag de validez **lo da el componente**, tu
  `$v.$invalid` sobra;
- prioridad como `<v-select>` que **emite el string** que el store espera, aunque
  las opciones sean objetos `{text, value}`;
- crear y editar dentro de un `<v-dialog>` (`persistent`, `max-width`, `v-model`);
- borrado con `<v-dialog>` de confirmación en vez de `window.confirm`;
- reset del formulario distinguiendo `reset()` de `resetValidation()`;
- **los tests de VU0 pasando** — o fallando, con un diagnóstico escrito de por qué
  (spoiler: si fallan por el teletransporte del `v-dialog`, no es un bug tuyo, es
  cómo funciona);
- un `MODERNIZATION.md` con la sección **"Por qué sacamos vuelidate y qué
  perdimos"**.

## 🚫 Qué NO entra todavía

- `v-data-table` — el dashboard es VU3;
- `v-stepper` / el wizard de F6 — ejercicio 🔴 de VU4;
- theming en serio (colores del tema aplicados a fondo) — llega en VU3 y VU4, aquí
  solo lo rozamos;
- `a-la-carte` / bundle — deuda 💸 de VU1, se paga en VU3;
- validación server-side de verdad — sigue siendo deuda 💸, y Vuetify no la paga.

---

## 🧠 Concepto 1: `:rules` en 5 minutos (sí, se parece a Q2 — sigamos)

En vuelidate describes las reglas **en el modelo** (bloque `validations`) y lees el
resultado **en `$v`**. En Vuetify las describes **en el template**, como array de
funciones, y no lees casi nada: el campo se pinta solo.

```vue
<v-text-field
  v-model="form.title"
  label="Título *"
  :rules="[
    v => !!v || 'El título es obligatorio.',
    v => (v && v.length >= 5) || 'Mínimo 5 caracteres.',
    v => (v && v.length <= 80) || 'Máximo 80 caracteres.'
  ]"
/>
```

🔎 **Qué hace**

- `:rules` es un **array de funciones**. Cada una recibe el valor actual.
- Devuelve `true` (o cualquier truthy) → la regla pasa.
- Devuelve un **string** → la regla falla, y **ese string es el mensaje**. De ahí
  el patrón `condición || 'mensaje'`: si la condición es `true`, devuelve `true`;
  si es `false`, JS devuelve el string. Ese cortocircuito es *todo* el API.
- Se evalúan **en orden** y **se para en la primera que falla**. El orden de tu
  array es el orden de prioridad de tus mensajes.

✅ **Buenas prácticas**

- Reglas largas dentro del template son ilegibles. Extráelas a `methods` o —mejor—
  a un `utils/rules.js` reutilizable. Lo hacemos en el código de la fase.
- `!!v` como "requerido" funciona para strings, **pero rechaza el `0`**. Si algún
  día validas un numérico donde `0` es válido, usa `v => v !== null && v !== ''`.
  Clásico bug de producción.

> ⚠️ **Aviso de honestidad.** Si lo comparas con el Concepto 1 de Q2, es
> prácticamente lo mismo cambiando `q-input` por `v-text-field`. **Lo es.** No voy
> a inventarme diferencias falsas para que VU2 parezca más gorda. La diferencia de
> peso real de esta fase no está aquí — está en el `v-dialog` (Concepto 5). Lo que
> **sí** es propio de Vuetify en validación son dos cosas concretas: el flag
> `v-model="valid"` (Concepto 2) y la pareja `reset()` / `resetValidation()`
> (Concepto 3). Todo lo demás, admítelo y sigue.

### La diferencia de UX que sí importa (y también estaba en Q2)

`:rules` se evalúa **en cada cambio del `v-model`**, no solo al enviar. En F5, con
vuelidate, el error solo aparecía cuando el campo estaba `$dirty` porque **tú**
programaste `@blur="$v.form.title.$touch()"`. Con `:rules`, escribes la primera
letra del título y ya te grita "Mínimo 5 caracteres".

Vuetify te da una válvula para eso que Quasar llama distinto: la prop
**`validate-on-blur`** en el `<v-text-field>`.

```vue
<v-text-field v-model="form.title" :rules="titleRules" validate-on-blur />
```

Con `validate-on-blur`, la regla se corre al perder el foco, no en cada tecla —
recuperas el UX de F5. **Decídelo tú, no lo padezcas.** (Ejercicio 6.)

---

## 🧠 Concepto 2: `<v-form v-model="valid">` — la validez te la da el componente

Esta **sí** es propia de Vuetify, y es donde se separa de Quasar de forma limpia.

En F5, ¿quién sabía si el formulario era válido? **Tú**, consultando
`this.$v.$invalid`. En Quasar (Q2), nadie te lo decía por una propiedad: se lo
preguntabas a `QForm.validate()` (una promesa) o esperabas a `@submit`.

En **Vuetify**, el `<v-form>` te expone la validez como un **valor reactivo** por
`v-model`:

```vue
<v-form ref="form" v-model="valid" @submit.prevent="handleSubmit">
  <!-- campos con :rules -->
  <v-btn type="submit" color="primary" :disabled="!valid" :loading="saving">
    {{ submitLabel }}
  </v-btn>
</v-form>
```

```js
data: function () {
  return { valid: false, /* ... */ };
}
```

🔎 **Qué hace**

- `valid` pasa a `true`/`false` automáticamente según pasen o no **todas** las
  reglas de **todos** los hijos con `:rules`.
- Es reactivo: puedes atarlo directo a `:disabled="!valid"` en el botón. **Esto es
  lo que en Q2 no tenías** — allí el `:disabled="$v.$invalid"` de F5 se perdía en
  la migración y era todo un ejercicio (el 21 de Q2). En Vuetify lo recuperas
  gratis. Un raro punto donde Vuetify gana a Quasar sin discusión.

### ☠️ Qué muere de F5

| Flag de F5 | ¿Sobrevive a VU2? |
|---|---|
| **`$v.$invalid`** / el bloque `validations` | ❌ **Muere.** Lo reemplaza `valid`. |
| **`formError`** (si lo tenías) — "el form tiene campos inválidos" | ❌ **Muere.** `v-form` lo sabe. |
| **`error`** — "el POST falló con 500" | ✅ **Vive.** Es error de red, no de validación. `v-form` no sabe nada de HTTP. |

Confundir los dos últimos es el error nº1 de esta migración: gente que borra el
`error` de la vista "porque Vuetify valida solo" y se queda sin feedback cuando el
servidor devuelve 500. **Vuetify valida el formulario. El servidor sigue siendo tu
problema.**

⚠️ **El matiz del `valid` que muerde:** al montar el formulario, `valid` arranca en
`false` **aunque los campos aún no se hayan evaluado**. En modo edición, donde
llegas con datos válidos, el botón puede aparecer deshabilitado un instante hasta
que Vuetify corra las reglas. Si `:disabled="!valid"` te deja el botón muerto al
abrir el diálogo de edición, no es un bug tuyo: es que las reglas aún no corrieron.
Se arregla llamando a `this.$refs.form.validate()` tras rellenar (ver Concepto 3).

---

## 🧠 Concepto 3: `validate()`, `reset()` y `resetValidation()` — **tres, no dos**

Aquí Vuetify se separa de Quasar de verdad, y es una de las dos cosas por las que
esta fase existe. Son **tres** métodos sobre `this.$refs.form`, y la gente
confunde los dos últimos **a diario**.

```js
this.$refs.form.validate()          // corre las reglas AHORA y devuelve boolean
this.$refs.form.reset()             // borra VALORES + errores
this.$refs.form.resetValidation()   // borra SOLO los errores pintados
```

### `validate()`: aquí **sí** devuelve un booleano

⚠️ **Atención si vienes de Q2:** en Quasar, `validate()` devuelve una **promesa**
(y ese era todo un concepto, porque `if (validate())` pasaba siempre por ser un
objeto truthy). En **Vuetify 2, `validate()` devuelve un booleano síncrono.**

```js
// ✅ En Vuetify esto funciona tal cual — nada de .then()
if (this.$refs.form.validate()) {
  this.enviar();
}
```

🔎 **Por qué la diferencia:** Vuetify 2 no soporta reglas asíncronas de forma
nativa en el retorno de `validate()` (la validación async se resuelve por otras
vías — Concepto 6), así que se puede permitir un retorno síncrono. Quasar decidió
lo contrario. Mismo problema, dos APIs. **Reconoce las dos, no las mezcles.**

✅ **Y como en Q2: casi nunca lo vas a llamar.** Con `v-model="valid"` +
`:disabled="!valid"`, el botón ya está bloqueado cuando el form es inválido.
`validate()` a mano se justifica en dos casos: validar un paso de wizard antes de
avanzar (`v-stepper`, ejercicio 🔴 de VU4), y **forzar la evaluación tras rellenar
programáticamente** (el matiz de `valid` del Concepto 2).

### `reset()` vs `resetValidation()`: la trampa de la fase

| Método | Borra valores | Borra errores pintados |
|---|---|---|
| `reset()` | ✅ **Sí** — deja los campos vacíos | ✅ Sí |
| `resetValidation()` | ❌ **No** — los valores se quedan | ✅ Sí |

Léelo otra vez, porque el nombre engaña: **`reset()` NO es "reset de la
validación"**. `reset()` es un reset **total**: te vacía los campos. Si lo que
querías era solo quitar los rojos y dejar lo que el usuario escribió, `reset()` te
acaba de borrar el formulario delante de sus narices.

**El caso donde `resetValidation()` te salva la tarde** (idéntico problema que en
Q2, distinto método): rellenas el formulario programáticamente en modo edición
—llega `initialTicket`, lo clonas a `form`— y Vuetify te pinta en rojo campos que
el usuario **ni ha tocado**, porque las reglas corrieron sobre el estado
intermedio. Solución:

```js
created: function () {
  var self = this;
  if (this.initialTicket) {
    this.form = Object.assign({}, this.form, this.initialTicket);
    // deja que el DOM se pinte con los valores nuevos, LUEGO olvida los errores
    this.$nextTick(function () {
      self.$refs.form.resetValidation();
    });
  }
}
```

El `$nextTick` es **obligatorio**: hay que dejar que el DOM se actualice con los
valores nuevos antes de decirle "olvida los errores". Sin él, limpias errores que
aún no existen y vuelven a aparecer en el siguiente tick.

**Mnemónico para la nevera:**

```
reset()            →  BORRA TODO (valores + errores). El botón nuclear.
resetValidation()  →  borra solo los rojos, conserva lo escrito. El que casi
                      siempre quieres tras rellenar en modo edición.
validate()         →  fuerza correr las reglas ahora (síncrono, devuelve bool).
```

---

## 🧠 Concepto 4: `<v-select>` con objetos — la media tarde 🕳️

Aquí tropieza todo el mundo, en Quasar y en Vuetify por igual. El bug es el mismo;
las props se llaman distinto. **Dedícale espacio real**, porque en un legacy ajeno
esto es lo primero que te muerde.

### El problema, en una frase

Tu `<select>` de F5 era estúpido y honesto: `form.priority` acababa valiendo
`"high"`, un string. Es lo que el store guarda, lo que la API espera, lo que
`db.json` tiene escrito.

`<v-select>` **quiere trabajar con objetos**, porque separa *lo que se ve* de *lo
que vale*:

```js
priorityOptions: [
  { text: "Baja",  value: "low" },
  { text: "Media", value: "medium" },
  { text: "Alta",  value: "high" }
]
```

> 📝 **Ojo al nombre:** Quasar usa `label`; **Vuetify usa `text`.** Mismo concepto,
> propiedad distinta. Copiar el array de Q2 tal cual y esperar que funcione es el
> primer tropiezo.

Y si haces lo ingenuo:

```vue
<!-- ❌ El bug -->
<v-select v-model="form.priority" :items="priorityOptions" label="Prioridad" />
```

...`form.priority` ahora vale **`{ text: "Alta", value: "high" }`**. Un objeto. Que
se va tal cual al `$emit("submit")`, de ahí al `payload`, de ahí al
`POST /tickets`. Y json-server, que no juzga a nadie, lo guarda:

```json
{ "id": 42, "priority": { "text": "Alta", "value": "high" } }
```

Enhorabuena: corrompiste la base de datos. El dashboard de F4 hace
`ticket.priority === "high"` para pintar el badge, ahora falla, el badge
desaparece. **Y tu test de VU0 se pone rojo.** (Ese test se acaba de ganar el
sueldo.)

Peor en **modo edición**: llega `initialTicket.priority === "high"` (string, del
servidor), se lo pasas al `v-model`, y el select aparece **vacío** —busca en
`items` un objeto igual a `"high"` y no lo encuentra. El usuario ve "Prioridad:
(vacío)", guarda, y le borra la prioridad al ticket. 💀

### Las props que lo arreglan

En Vuetify la pareja se llama **`item-text`** + **`item-value`**, y la llave del
comportamiento es **`return-object`** (o su ausencia):

```vue
<v-select
  v-model="form.priority"
  :items="priorityOptions"
  item-text="text"
  item-value="value"
  label="Prioridad *"
  :rules="[v => !!v || 'Seleccione una prioridad.']"
/>
```

🔎 **Qué hace cada una:**

| Prop | Qué hace |
|---|---|
| `item-text="text"` | "El texto a mostrar está en la propiedad `text`" (es el default de Vuetify, pero decláralo: el día que tu API devuelva `{id, name}` lo agradeces) |
| `item-value="value"` | "El valor real de cada opción está en `value`" |
| *(sin `return-object`)* | **Por defecto Vuetify emite solo el `item-value`.** `v-model` recibe `"high"`, un string. Justo lo que el store espera. |

Y aquí está el giro **que invierte lo de Quasar** y por lo que copiar Q2 con
find&replace te explota:

> En **Quasar** tenías que **añadir** `emit-value` + `map-options` para conseguir
> el string. En **Vuetify, ese es el comportamiento por defecto**: sin
> `return-object`, ya emite el valor plano y ya mapea de vuelta para pintarlo.
> **El objeto entero solo lo emites si pides `return-object` explícitamente.**

### `return-object`: el interruptor

```vue
<!-- v-model recibe el STRING "high" (default, sin return-object) -->
<v-select v-model="form.priority" :items="priorityOptions"
          item-text="text" item-value="value" />

<!-- v-model recibe el OBJETO {text:"Alta", value:"high"} (con return-object) -->
<v-select v-model="form.priority" :items="priorityOptions"
          item-text="text" item-value="value" return-object />
```

**Mnemónico:**

```
SIN return-object  →  sale el valor plano ("high").   ← lo que queremos aquí
CON return-object  →  sale el objeto entero.

En Quasar era al revés de trabajoso: allí el default era el objeto y tenías
que domarlo. Aquí el default ya es el string. Vuetify te lo pone fácil...
hasta que el store guarda objetos. Entonces return-object es tu amigo, y
llega el mismo drama de la comparación por referencia.
```

### El diagrama, porque hace falta

```
        v-select SIN item-value bien puesto      v-select con item-text/value OK
        ──────────────────────────────────       ───────────────────────────────

store/API                                         store/API
  "high"                                            "high"
    │ (v-model in)                                    │ (v-model in)
    ▼                                                 ▼
 v-select busca en items un objeto             v-select: por item-value mapea
 que sea === "high"                            "high" → la opción {text:"Alta"}
    │                                             │
    ▼                                             ▼
 ❌ no lo encuentra → SELECT VACÍO             ✅ pinta "Alta"

 usuario elige "Alta"                          usuario elige "Alta"
    │ (v-model out)                               │ (v-model out, SIN return-object)
    ▼                                             ▼
 objeto entero                                 "high"
    ▼                                             ▼
 ❌ POST con objeto → db.json corrupto         ✅ POST con string → db.json intacto
```

### Y si el store guardara objetos...

Imagina que el backend cambia y `priority` pasa a ser `{ id: 3, name: "Alta" }`
dentro del ticket. Entonces **sí** quieres `return-object`, porque es lo que el
store espera:

```vue
<v-select
  v-model="form.priority"
  :items="priorityOptions"
  item-text="name"
  item-value="id"
  return-object
  :rules="[v => !!v || 'Seleccione una prioridad.']"
/>
<!-- ⚠️ CON return-object: el v-model es un objeto de la lista.
     PERO OJO: la comparación de Vuetify para preseleccionar es por el
     item-value (aquí "id"), NO por referencia del objeto entero.
     Si initialTicket.priority viene del servidor como {id:3, name:"Alta"},
     Vuetify lo casa contra options por id → funciona MEJOR que Quasar aquí,
     PORQUE compara por item-value, no por referencia.
     El drama vuelve solo si NO declaras bien item-value y cae a comparar
     el objeto entero. Declara item-value SIEMPRE. -->
```

Este es exactamente el escenario del ejercicio 25 🔴, y es donde Vuetify y Quasar
divergen de verdad: la reconciliación del objeto entrante. En Quasar peleabas con
la comparación por referencia; en Vuetify, si declaras `item-value`, te la casa
por esa clave. Menos doloroso — **si** declaraste `item-value`. Si no, bienvenido
al mismo infierno.

**Moraleja:** `<v-select>` no es un `<select>` con estilos. Tiene **opinión sobre
tus datos**. `item-text`, `item-value` y `return-object` son cómo negocias con esa
opinión.

---

## 🧠 Concepto 5: ⭐ `<v-dialog>` — el peso alto de la fase

Aquí está el trabajo de verdad de VU2, lo que **no** es Quasar-con-otro-prefijo.

En F5, crear y editar eran **rutas** (`/tickets/new`, `/tickets/:id/edit`) y el
borrado era un `window.confirm`. En esta ruta lo llevamos a diálogos. Y `<v-dialog>`
tiene dos particularidades que te van a morder.

### Lo básico: `v-model`, `persistent`, `max-width`

```vue
<v-dialog v-model="dialog" persistent max-width="640">
  <v-card>
    <v-card-title>Nuevo ticket</v-card-title>
    <v-card-text>
      <ticket-form ... />
    </v-card-text>
  </v-card>
</v-dialog>
```

🔎 **Qué hace**

- **`v-model="dialog"`** — un booleano en tu `data()`. `true` abre, `false` cierra.
  No hay `.show()` ni `.modal('show')` de jQuery (adiós al dolor del ejercicio 18
  de F5): es estado reactivo. `this.dialog = true` y ya está.
- **`persistent`** — sin esto, un clic fuera del diálogo o la tecla `Esc` lo
  cierran. Para un formulario con datos a medio escribir, eso es un data-loss
  esperando a ocurrir. `persistent` obliga a cerrar con un botón explícito. **Úsalo
  siempre que haya un formulario dentro.**
- **`max-width="640"`** — el diálogo, por defecto, es angosto. `max-width` le da
  aire. (En F5 la vista tenía `style="max-width: 640px"`; misma intención.)

### 💥 La particularidad nº1: el `<v-dialog>` necesita un `<v-app>` ancestro

Esto **enlaza directo con VU1**. Vuetify monta muchos componentes "flotantes"
(diálogos, menús, tooltips) apoyándose en la estructura que `<v-app>` establece. Si
tu `<v-dialog>` acaba fuera de un `<v-app>` —por ejemplo en un test que monta el
componente aislado— **el diálogo no se posiciona bien, o directamente no aparece, y
no hay error que te lo diga.**

En la app normal no lo notas porque VU1 ya envolvió `App.vue` en `<v-app>`. Lo
notas en los **tests** (ver particularidad nº2 y su efecto sobre VU0).

### 💥 La particularidad nº2: el `<v-dialog>` **se teletransporta en el DOM**

Esta es la que te va a costar entender por qué tus tests fallan.

Cuando Vuetify abre un `<v-dialog>`, **el contenido del diálogo NO se renderiza
donde tú escribiste `<v-dialog>` en el template.** Vuetify lo **saca del árbol de
tu componente y lo cuelga de un contenedor global** (`v-overlay` / `v-menu`
container, cerca del `<v-app>` raíz). Es el equivalente de lo que en el mundo
moderno se llama "portal" o "teleport" — pero esto es Vuetify 2, y lo hace por su
cuenta, sin que se lo pidas.

```
Tu template dice:                    El DOM real acaba así:

<v-app>                              <v-app>
  <ticket-list>                        <ticket-list>
    <v-dialog>          ─┐               (aquí ya NO está el contenido) │
      <ticket-form/>     │  teletransporte                             │
    </v-dialog>         ─┘             </ticket-list>                   │
  </ticket-list>                       <div class="v-dialog__content"> ◄┘
</v-app>                                 <ticket-form/>   ← ¡acá vive ahora!
                                       </div>
                                     </v-app>
```

**Por qué te importa a ti, hoy, con los tests de VU0:**

Tus tests de VU0 hacen algo como `wrapper.find('[data-testid="ticket-title"]')`.
Ese `wrapper` es el subárbol de **tu** componente. Pero si el campo vive dentro de
un `<v-dialog>`, cuando el diálogo se abre, **el campo ya no está en el subárbol de
tu componente** — se teletransportó a un contenedor global que `wrapper.find()` no
alcanza. Resultado: `find()` no lo encuentra, y tu test que buscaba
`ticket-title` **falla** aunque el formulario funcione perfectamente.

🔎 **El diagnóstico correcto** (lo escribes en `MODERNIZATION.md`): el test no está
roto porque la migración rompiera la feature. Está rojo porque **el nodo se mudó de
sitio en el DOM**. Es un falso negativo causado por el teletransporte, no una
regresión real.

✅ **Cómo se resuelve** (tres caminos, elige y documenta):

1. **`attach`** — `<v-dialog attach>` (o `attach="#algo"`) le dice a Vuetify "no te
   teletransportes, quédate donde te escribí". En tests, esto devuelve el nodo al
   subárbol y `wrapper.find()` vuelve a encontrarlo. Es la vía más limpia **para
   los tests**, pero cambia el comportamiento en producción (el diálogo pierde el
   contenedor global) — úsalo con criterio.
2. **Buscar en `document`, no en `wrapper`** — en Vue Test Utils, cuando algo se
   teletransporta, lo buscas con `document.querySelector('[data-testid=...]')` en
   vez de `wrapper.find(...)`. El test se adapta al teletransporte en vez de
   evitarlo.
3. **No meter el form en el diálogo para el test** — montar `TicketForm` suelto
   (como en F5) y testear el `v-dialog` por separado. Separa "el form valida" de
   "el diálogo abre/cierra".

> Este es **exactamente** el tipo de sorpresa que VU0 no podía prever del todo: un
> test de comportamiento bien escrito (`data-testid`, no clases) **aún así** se
> rompe, no por acoplamiento al DOM sino porque el DOM literalmente se reorganiza.
> La lección de VU0 —"testea comportamiento, no estructura"— sigue siendo correcta;
> el teletransporte es un asterisco que solo Vuetify te enseña.

### El diálogo de borrado (adiós a `window.confirm`)

```vue
<v-dialog v-model="confirmDelete" max-width="420">
  <v-card>
    <v-card-title>Eliminar ticket</v-card-title>
    <v-card-text>
      ¿Seguro que quieres eliminar <strong>#{{ ticket.id }} — {{ ticket.title }}</strong>?
      Esta acción no se puede deshacer.
    </v-card-text>
    <v-card-actions>
      <v-spacer />
      <v-btn text @click="confirmDelete = false">Cancelar</v-btn>
      <v-btn color="error" :loading="deleting" @click="doDelete">Eliminar</v-btn>
    </v-card-actions>
  </v-card>
</v-dialog>
```

Fíjate: el confirm **dice qué se va a borrar** (id + título), no un genérico "¿estás
seguro?". Ese detalle venía de F5 y no se pierde en la migración. Y a diferencia
del `window.confirm` (que congela el hilo), este diálogo es asíncrono: el botón
puede mostrar `:loading="deleting"` mientras el DELETE está en vuelo.

---

## 🧠 Concepto 6: validación async (de pasada, es ejercicio 🔴)

En F5 la validación de "título duplicado" era el ejercicio 24 🔴, a mano. Vuetify 2
**no** tiene reglas async nativas en el retorno de `validate()` (por eso ese retorno
es síncrono, Concepto 3). El patrón de la época:

- disparas la consulta `GET /tickets?title=EXACTO` en un `@blur` o con `watch` +
  `debounce`;
- guardas el resultado en un flag reactivo (`titleTaken`);
- metes ese flag en la regla: `v => !titleTaken || 'Ya existe un ticket con ese título.'`

Es decir: la "async" vive **fuera** de `:rules`, y `:rules` solo lee el resultado.
Menos elegante que si fuera nativo, pero es lo que hay en v2. Ejercicio 24.

---

## 💻 Código de la fase

### Estructura que cambia

```
src/
  components/
    tickets/
      TicketForm.vue        ← reescrito (v-form, sin vuelidate)
  views/
    TicketListView.vue      ← hospeda los <v-dialog> de crear/editar/borrar
  utils/
    rules.js                ← nuevo: reglas reutilizables
```

> Nota de arquitectura: en F5, crear y editar eran **vistas con ruta propia**. Al
> pasarlas a `<v-dialog>`, el CRUD se concentra en la lista. Puedes mantener las
> rutas si quieres deep-linking (`/tickets/new` abre el diálogo) — es el
> ejercicio 17. Aquí, por simplicidad, el diálogo vive en la lista.

### `utils/rules.js`

```js
// Reglas reutilizables. Cada una es (o devuelve) una función val => true | string.
export var required = function (msg) {
  return function (v) {
    return !!v || (msg || "Campo obligatorio.");
  };
};

export var minLen = function (n, msg) {
  return function (v) {
    return (v && v.length >= n) || (msg || "Mínimo " + n + " caracteres.");
  };
};

export var maxLen = function (n, msg) {
  return function (v) {
    return (!v || v.length <= n) || (msg || "Máximo " + n + " caracteres.");
  };
};

export var oneOf = function (values, msg) {
  return function (v) {
    return values.indexOf(v) !== -1 || (msg || "Valor no permitido.");
  };
};
```

🔎 **Qué hace:** cada regla es una **fábrica** que devuelve la función que `:rules`
espera. Así el template queda legible (`:rules="titleRules"`) y las reglas son
**testeables aisladas** (ejercicio 26) — algo que con vuelidate venía gratis y que
al mover la validación al template te toca reconstruir.

### `components/tickets/TicketForm.vue`

```vue
<template>
  <v-form ref="form" v-model="valid" @submit.prevent="handleSubmit">
    <v-text-field
      v-model.trim="form.title"
      label="Título *"
      data-testid="ticket-title"
      :rules="titleRules"
    />

    <v-textarea
      v-model.trim="form.description"
      label="Descripción *"
      rows="4"
      data-testid="ticket-description"
      :rules="descriptionRules"
    />

    <v-row>
      <v-col cols="12" md="6">
        <v-select
          v-model="form.priority"
          :items="priorityOptions"
          item-text="text"
          item-value="value"
          label="Prioridad *"
          data-testid="ticket-priority"
          :rules="priorityRules"
        />
        <!-- SIN return-object: v-model emite el string "high", que es lo que
             el store espera. Ver Concepto 4. -->
      </v-col>
      <v-col cols="12" md="6">
        <v-text-field
          v-model.trim="form.assignee"
          label="Asignado a"
          data-testid="ticket-assignee"
          placeholder="(opcional)"
        />
      </v-col>
    </v-row>

    <div class="mt-3">
      <v-btn
        type="submit"
        color="primary"
        data-testid="ticket-submit"
        :disabled="!valid"
        :loading="saving"
      >
        {{ submitLabel }}
      </v-btn>
      <v-btn text data-testid="ticket-cancel" @click="$emit('cancel')">
        Cancelar
      </v-btn>
    </div>
  </v-form>
</template>

<script>
import { required, minLen, maxLen, oneOf } from "../../utils/rules";

export default {
  name: "TicketForm",
  props: {
    initialTicket: { type: Object, default: null },
    saving: { type: Boolean, default: false },
    submitLabel: { type: String, default: "Guardar" }
  },
  data: function () {
    return {
      valid: false,
      form: { title: "", description: "", priority: "", assignee: "" },
      priorityOptions: [
        { text: "Baja", value: "low" },
        { text: "Media", value: "medium" },
        { text: "Alta", value: "high" }
      ],
      // Reglas armadas una vez; el template solo las referencia.
      titleRules: [required("El título es obligatorio."), minLen(5), maxLen(80)],
      descriptionRules: [
        required("La descripción es obligatoria."),
        minLen(10, "Cuenta un poco más: mínimo 10 caracteres.")
      ],
      priorityRules: [
        required("Seleccione una prioridad."),
        oneOf(["low", "medium", "high"])
      ]
    };
  },
  created: function () {
    var self = this;
    if (this.initialTicket) {
      // copia local: NUNCA editamos la prop directamente (patrón de F5)
      this.form = Object.assign({}, this.form, this.initialTicket);
      // rellenamos programáticamente → Vuetify pinta errores de campos
      // no tocados. Los limpiamos DESPUÉS de que el DOM tenga los valores.
      this.$nextTick(function () {
        self.$refs.form.resetValidation();
      });
    }
  },
  methods: {
    handleSubmit: function () {
      // v-model="valid" + :disabled="!valid" ya bloquean el submit inválido,
      // pero validamos por si acaso (Enter, autofill, etc.).
      if (!this.$refs.form.validate()) {
        return;
      }
      this.$emit("submit", Object.assign({}, this.form));
    }
  }
};
</script>
```

Detalles con intención:

- **no hay `novalidate`** — no hace falta: no hay `<form>` HTML tuyo con validación
  nativa peleando, `<v-form>` gestiona lo suyo;
- **no hay bloque `validations`, no hay `import` de vuelidate** — esa es la
  dependencia que sale del proyecto;
- `handleSubmit` es casi vacío comparado con F5: el `$v.$touch()` + `if
  ($v.$invalid)` se fue. La red la pone `v-form`;
- `data-testid` en cada campo: son los que VU0 fijó. **No los cambies** o rompes
  los tests de regresión por tu cuenta;
- la copia local + `resetValidation` en `nextTick` es el patrón del Concepto 3, en
  vivo.

### `views/TicketListView.vue` (fragmento: los diálogos)

```vue
<template>
  <section>
    <div class="d-flex align-center mb-3">
      <h1 class="text-h5">Tickets</h1>
      <v-spacer />
      <v-btn color="primary" data-testid="ticket-new" @click="openCreate">
        Nuevo ticket
      </v-btn>
    </div>

    <!-- ... aquí sigue el listado de F4 (todavía Bootstrap; se migra en VU3) ... -->

    <!-- Diálogo CREAR / EDITAR -->
    <v-dialog v-model="formDialog" persistent max-width="640">
      <v-card>
        <v-card-title>{{ editing ? "Editar ticket" : "Nuevo ticket" }}</v-card-title>
        <v-card-text>
          <div v-if="error" class="mb-3">
            <v-alert type="error" dense text>{{ error }}</v-alert>
          </div>
          <!-- :key fuerza remontar el form al cambiar de ticket → clon limpio -->
          <ticket-form
            :key="editingId || 'new'"
            :initial-ticket="editingTicket"
            :saving="saving"
            :submit-label="editing ? 'Guardar cambios' : 'Crear ticket'"
            @submit="onSubmit"
            @cancel="closeForm"
          />
        </v-card-text>
      </v-card>
    </v-dialog>

    <!-- Diálogo BORRAR -->
    <v-dialog v-model="confirmDelete" max-width="420">
      <v-card>
        <v-card-title>Eliminar ticket</v-card-title>
        <v-card-text>
          ¿Seguro que quieres eliminar
          <strong>#{{ toDelete && toDelete.id }} — {{ toDelete && toDelete.title }}</strong>?
        </v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn text @click="confirmDelete = false">Cancelar</v-btn>
          <v-btn color="error" :loading="deleting" @click="doDelete">Eliminar</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </section>
</template>

<script>
import TicketForm from "../components/tickets/TicketForm.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketListView",
  components: { TicketForm },
  data: function () {
    return {
      formDialog: false,
      confirmDelete: false,
      editing: false,
      editingId: null,
      editingTicket: null,
      toDelete: null,
      saving: false,
      deleting: false,
      error: ""
    };
  },
  methods: {
    openCreate: function () {
      this.editing = false;
      this.editingId = null;
      this.editingTicket = null;
      this.error = "";
      this.formDialog = true;
    },
    openEdit: function (ticket) {
      this.editing = true;
      this.editingId = ticket.id;
      this.editingTicket = ticket;
      this.error = "";
      this.formDialog = true;
    },
    closeForm: function () {
      this.formDialog = false;
    },
    onSubmit: function (formData) {
      var self = this;
      this.saving = true;
      this.error = "";

      // reglas de negocio: las pone la VISTA, no el form (igual que en F5)
      var request;
      if (this.editing) {
        request = ticketService.updateTicket(this.editingId, formData);
      } else {
        var payload = Object.assign({}, formData, {
          status: "open",
          reporter: this.$store.getters["auth/currentUser"].username,
          createdAt: new Date().toISOString()
        });
        request = ticketService.createTicket(payload);
      }

      request
        .then(function () {
          self.formDialog = false;
          self.$emit("refresh"); // o recargar la lista
        })
        .catch(function () {
          self.error = "No se pudo guardar. Intenta de nuevo.";
        })
        .finally(function () {
          self.saving = false;
        });
    },
    askDelete: function (ticket) {
      this.toDelete = ticket;
      this.confirmDelete = true;
    },
    doDelete: function () {
      var self = this;
      this.deleting = true;
      ticketService
        .deleteTicket(this.toDelete.id)
        .then(function () {
          self.confirmDelete = false;
          self.$emit("refresh");
        })
        .catch(function () {
          self.error = "No se pudo eliminar.";
          self.confirmDelete = false;
        })
        .finally(function () {
          self.deleting = false;
        });
    }
  }
};
</script>
```

Detalles con intención:

- **`:key="editingId || 'new'"`** en `<ticket-form>`: fuerza a Vue a **remontar** el
  form al cambiar de ticket, garantizando un clon limpio en `created`. Sin la key,
  reusar la misma instancia entre "editar #3" y "editar #7" arrastra estado viejo.
  Truco barato, resuelve un bug caro;
- el `payload` (`status`, `reporter`, `createdAt`) lo arma **la vista**, igual que
  en F5. El formulario no decide que un ticket nace "abierto";
- el `error` de red vive en la vista y se pinta con `<v-alert type="error">`. **Ese
  `error` sobrevivió** a la migración (Concepto 2) — no lo confundas con la validez
  del form, que ahora la lleva `v-form`.

### Quitar vuelidate del proyecto

```bash
npm uninstall vuelidate
```

Y borra la línea de `main.js`:

```js
// ❌ borrar estas dos líneas
import Vuelidate from "vuelidate";
Vue.use(Vuelidate);
```

Arranca la app y busca en consola cualquier `$v` huérfano. Si algo revienta, es un
formulario que aún dependía de vuelidate y no migraste. **Encuéntralos todos antes
de dar la fase por cerrada** — una dependencia a medio quitar es peor que no
haberla tocado.

---

## 📊 Tabla comparativa: A pelo (F5) vs Vuetify (VU2)

| A pelo (F5) | Vuetify (VU2) |
|---|---|
| `<b-form-input>`/`<input class="form-control">` + vuelidate | `<v-text-field :rules>` |
| bloque `validations` + `$v.form.title.$touch()` | `:rules` en el template |
| `$v.$invalid` leído a mano | `<v-form v-model="valid">` (reactivo) |
| `@blur="$v...$touch()"` para no gritar de entrada | `validate-on-blur` en el campo |
| `:class="{ 'is-invalid': $v...$error }"` + `<div class="invalid-feedback">` | el `<v-text-field>` lo pinta solo |
| `<select>` con `<option>` (emite string, honesto) | `<v-select :items item-text item-value>` (sin `return-object` = string) |
| `$v.$reset()` | `resetValidation()` (y **ojo**, `reset()` borra también valores) |
| `window.confirm(...)` | `<v-dialog>` de confirmación |
| rutas `/tickets/new` y `/:id/edit` | `<v-dialog>` en la lista (o rutas + diálogo, ej. 17) |
| `vuelidate` en `package.json` | **fuera del `package.json`** |

---

## ⚠️ Errores comunes

- **copiar el array de opciones de Q2 con `label`** en vez de `text` → el
  `<v-select>` sale en blanco. Vuetify usa `item-text`/`item-value`, Quasar
  `option-label`/`option-value`;
- **poner `return-object` sin querer** (o dejarlo por copiar de otro ejemplo) →
  `form.priority` acaba siendo un objeto → `db.json` corrupto → badge de F4 roto →
  test de VU0 rojo;
- **confundir `reset()` con `resetValidation()`** → llamas `reset()` para "quitar
  los rojos" y le borras el formulario entero al usuario;
- **esperar que `validate()` devuelva una promesa** (porque venías de Q2) → en
  Vuetify 2 es síncrono; el `.then()` te da `undefined`;
- **buscar en `wrapper.find()` un campo que vive en un `<v-dialog>` abierto** → no
  lo encuentra por el teletransporte; usa `attach` o `document.querySelector`;
- **`<v-dialog>` sin `persistent`** en un formulario → clic fuera = data-loss;
- **olvidar el `<v-app>` ancestro** (en tests, sobre todo) → el diálogo no
  aparece y **no hay error**;
- **borrar el `error` de red "porque Vuetify valida solo"** → te quedas sin
  feedback cuando el servidor devuelve 500;
- **`:disabled="!valid"` en modo edición** deja el botón muerto al abrir hasta que
  las reglas corren → fuerza `validate()` tras rellenar;
- **quitar vuelidate a medias** → un formulario huérfano con `$v` reventando en
  consola, la peor de las dos aguas.

---

## 🧪 Ejercicios (27)

**🟢 Fácil (1–8)**

1. Añade `validate-on-blur` al campo título y compara: escribe una letra con y sin
   la prop. Documenta en un comentario qué UX prefieres (no hay respuesta única).
2. Añade una regla `maxLen(500)` a la descripción. Verifica que el mensaje sale
   con el número correcto sin tocar nada más.
3. Ata `:disabled="!valid"` al botón submit, quítalo, y vuelve a ponerlo. ¿En qué
   se diferencia esto del `:disabled` que en Q2 costaba un ejercicio entero?
4. Añade un botón "Limpiar" que llame a `this.$refs.form.reset()`. Comprueba que
   borra **valores y errores**. Ahora cámbialo a `resetValidation()` y observa la
   diferencia. Escribe cuál usarías tras rellenar en modo edición.
5. Haz obligatorio `assignee` con su mensaje. Luego revierte: no todo campo debe
   ser obligatorio, y saber cuándo NO validar es parte del oficio.
6. Añade `clearable` al `<v-select>` de prioridad. Pruébalo: al limpiarlo,
   `form.priority` queda `null`. ¿Tu regla `required` lo atrapa? Ajusta si no.
7. Cambia el `max-width` del diálogo de crear de `640` a `480` y observa cómo se
   comporta el formulario apretado. Decide un valor y justifícalo.
8. Reproduce el doble submit: quita `:disabled="!valid"` y `:loading`, dale a
   Enter dos veces rápido con el form válido, mira `db.json`. Restaura los flags y
   documenta qué pasó.

**🟡 Intermedio (9–17)**

9. Migra el `assignee` a un `<v-select>` poblado desde `GET /users?role=agent`
   (reutiliza el `userService` del ej. 9 de F5). Emite el username (string), no el
   objeto de usuario. ¿`return-object` sí o no?
10. **Migra el login (F2) a `v-form`.** Reescribe `LoginView` con `<v-text-field>`
    + `:rules`, sin vuelidate. **Usa los tests de VU0, no escribas nuevos.** Si
    fallan, diagnostica: ¿es la migración o el test estaba acoplado? ⚠️
    *(migración transversal obligatoria)*
11. Extrae los mensajes de error repetidos a `utils/rules.js` (si no lo hiciste ya)
    y reutilízalos en el login del ej. 10 y en el `TicketForm`. Cuenta cuántas
    líneas de reglas compartes.
12. Añade una regla custom `noSoloMayusculas` al título (nadie quiere tickets que
    GRITAN): rechaza títulos 100% mayúsculas de más de 10 caracteres. Es una
    función `v => ... || 'mensaje'`, nada más.
13. Añade el campo `status` al formulario **solo en modo edición** (deriva de si
    hay `initialTicket`), como `<v-select>` con `oneOf` de los 4 estados. En modo
    crear, no debe aparecer.
14. Tras crear un ticket, muestra un `<v-snackbar>` "Ticket creado ✅" que se
    auto-oculte a los 4s. Reemplaza cualquier alerta improvisada.
15. Añade "duplicar ticket": un botón que abra el diálogo de crear precargando el
    formulario con los datos de otro ticket (título con prefijo "Copia de "). Pista:
    pásalo por `initialTicket` sin `id`.
16. Valida el modo edición cuando el ticket no existe (404): cierra el diálogo y
    muestra un `<v-alert>` de error en la lista.
17. **Deep-linking del diálogo:** haz que `/tickets/new` abra el diálogo de crear
    al montar la lista (lee `$route`), y que cerrarlo haga `router.push('/tickets')`.
    Así conservas las URLs de F5 **y** el diálogo. ¿Dónde vive ahora la fuente de
    verdad de "el diálogo está abierto": en `data()` o en la ruta?

**🟠 Difícil (18–24)**

18. **El teletransporte, en carne viva.** Escribe un test que monte `TicketListView`,
    abra el diálogo de crear y busque `[data-testid="ticket-title"]` con
    `wrapper.find()`. Míralo **fallar**. Ahora arréglalo de las tres formas del
    Concepto 5 (`attach`, `document.querySelector`, montar el form suelto). Escribe
    cuál elegiste para VU0 y por qué. **Documenta el diagnóstico:** el test rojo NO
    era una regresión.
19. **El `valid` inicial.** Abre el diálogo de **edición** de un ticket válido y
    observa el botón "Guardar cambios" deshabilitado un instante. Explica por qué
    (Concepto 2). Arréglalo forzando `validate()` tras rellenar. Compara: ¿preferías
    el comportamiento de F5, donde el botón nunca dependía de un `valid` reactivo?
20. Reemplaza cualquier flash-message improvisado (o el módulo Vuex `ui` del ej. 20
    🟠 de F5, si lo hiciste) por `<v-snackbar>` global en `App.vue`. Si borras el
    módulo `ui`, cuenta las líneas eliminadas y responde: ¿es más fácil o más
    difícil **testear** un `<v-snackbar>` que una mutación de Vuex?
21. **`return-object` deliberado.** Cambia el `<v-select>` de prioridad a
    `return-object` **a propósito**, guarda un ticket, y observa `db.json`
    corromperse. Luego revierte. Escribe en `MODERNIZATION.md` por qué el default de
    Vuetify (sin `return-object`) era el correcto para este store, y en qué caso
    querrías lo contrario.
22. **Reconoce la fauna: VeeValidate.** Reescribe SOLO el campo título con
    VeeValidate 3 (la otra librería de la época). No lo integres al proyecto: es
    reconocimiento. Escribe 5 líneas comparando tres filosofías ahora que las viste
    las tres: vuelidate (modelo), `:rules` de Vuetify (template-array), VeeValidate
    (template-directivas).
23. **Bootstrap y Vuetify conviviendo, adelanto.** El diálogo es Vuetify, pero la
    lista sigue en Bootstrap (se migra en VU3). Comprueba si el `.row` de tu lista
    Bootstrap se pisa con algo de Vuetify. Documenta lo que encuentres — es el tema
    central de VU3, aquí solo lo detectas.
24. **Validación async de título duplicado** (Concepto 6): al blur del título,
    `GET /tickets?title=EXACTO`, marca `titleTaken` y mételo en `:rules`. Excluye el
    propio ticket en edición. Añade un `<v-progress-circular>` pequeño mientras
    consulta. Cuidado con el debounce. **Compara con el ej. 24 🔴 de F5:** ¿más
    corto? ¿algo que F5 podía y esto no?

**🔴 Muy difícil (25–27)**

25. **El objeto anidado.** Modifica `db.json` para que `priority` sea
    `{ "id": 3, "name": "Alta" }`. Ahora tu `<v-select>` debe: (a) preseleccionar el
    objeto que llega del servidor —recuerda que Vuetify compara por `item-value`, no
    por referencia, así que **declara `item-value="id"`**; (b) emitir el objeto
    entero (el store lo espera así) → `return-object`; (c) seguir mostrando `name`.
    **Compáralo explícitamente con el ej. 25 🔴 de Q2:** en Quasar peleabas la
    comparación por referencia; aquí, si declaras `item-value`, Vuetify te la casa.
    Documenta las dos formas y cuál duele menos. Este es el bug con el que un legacy
    real te recibe el primer día.
26. **Reglas testeables.** El coste de mover la validación al template es que dejas
    de testearla aislada (con vuelidate era gratis). Escribe una suite de Jest para
    `utils/rules.js` que cubra las 5 reglas (incluida el flag de la async, con
    `apiClient` mockeado — patrón de F11). Luego responde: **¿esto prueba que el
    formulario valida bien?** (No. Prueba que las reglas funcionan. Que estén
    *aplicadas* al campo correcto solo lo prueba un test de componente —y ahí vuelve
    el teletransporte del ej. 18. Escríbelo también.)
27. **La migración a medias, y por qué es un desastre.** Deja `TicketForm` en
    Vuetify y revierte `LoginView` a vuelidate (deshaz el ej. 10). Ahora añade la
    misma regla nueva —"el username no puede tener espacios"— a **ambos**
    formularios. Cronométralo y cuenta cuántos contextos mentales cargaste (dos
    APIs de validación, dos filosofías). **Ahora completa la migración y hazlo otra
    vez.** Este ejercicio no enseña Vuetify: enseña **por qué una migración a medias
    cuesta más que cualquiera de los dos estados puros**, y por qué "lo dejamos así
    por ahora" es la frase más cara del mantenimiento de legacy. Conclusión en
    `MODERNIZATION.md`.

---

## 📚 Referencias

> ⚠️ **CRÍTICO:** `vuetifyjs.com` sirve la documentación de **v3 (Vue 3)** por
> defecto. Nuestra versión es **v2.6**. Los enlaces de abajo apuntan a
> **`v2.vuetifyjs.com`**. Si copias código de `vuetifyjs.com` a secas, **te va a
> compilar mal o directamente no va a existir el componente**. Verifica siempre que
> estás en `v2`.

**Documentación oficial — Vuetify 2**

- `v-form` — incluye `v-model` (validez), `ref`, `validate`, `reset`,
  `resetValidation`: https://v2.vuetifyjs.com/en/components/forms/
- `v-text-field` — `:rules`, `validate-on-blur`, `clearable`, slots:
  https://v2.vuetifyjs.com/en/components/text-fields/
- `v-textarea`: https://v2.vuetifyjs.com/en/components/textareas/
- `v-select` — **`items`, `item-text`, `item-value`, `return-object`**:
  https://v2.vuetifyjs.com/en/components/selects/
- `v-dialog` — **`persistent`, `max-width`, `attach`** (el teletransporte):
  https://v2.vuetifyjs.com/en/components/dialogs/
- `v-card` / `v-card-actions`: https://v2.vuetifyjs.com/en/components/cards/
- `v-btn` — `type="submit"`, `:loading`, `:disabled`:
  https://v2.vuetifyjs.com/en/components/buttons/
- `v-snackbar`: https://v2.vuetifyjs.com/en/components/snackbars/
- `v-alert`: https://v2.vuetifyjs.com/en/components/alerts/

**Lo que estamos dejando atrás (léelo una vez más, para despedirte)**

- Vuelidate 0.x: https://vuelidate.js.org/
- Vuelidate — validadores incluidos: https://vuelidate.js.org/#sub-builtin-validators

**Del tronco, que sigue vigente**

- Vue 2 — Custom Events (`$emit` y su payload):
  https://v2.vuejs.org/v2/guide/components-custom-events.html
- Vue 2 — Props: https://v2.vuejs.org/v2/guide/components-props.html
- Vue 2 — `$nextTick`: https://v2.vuejs.org/v2/api/#vm-nextTick
- Vue Test Utils — teleport/attach y búsqueda en `document`:
  https://v1.test-utils.vuejs.org/

**Orden de lectura sugerido:** `v-form` (sección "Validation with submit &
clear") → `v-text-field` (sección "Rules") → **`v-select` (sección "Object items"
— léela dos veces, es la del Concepto 4)** → **`v-dialog` (sección "attach" — la
del teletransporte, Concepto 5)** → volver al código.

---

## 🚀 Cierre

El `TicketForm` ya es Vuetify. Y en el camino pasó algo más grande que cambiar
etiquetas:

- **`vuelidate` salió del `package.json`.** Una dependencia menos, una decisión
  documentada. Esa lección es idéntica a la de Q2 — y con razón: es la lección de
  verdad, no el prefijo de los componentes.
- **El flag de validez lo lleva `v-form`** (`v-model="valid"`), y por una vez
  Vuetify te regaló gratis el `:disabled` reactivo que en Quasar costaba sudar.
- **`<v-select>` te cobró la media tarde** que te tenía que cobrar. La próxima vez
  que veas uno en un legacy ajeno, vas a mirar `item-value` y `return-object`
  **primero**. Y vas a tener razón.
- **`reset()` no es "reset de validación".** Ya lo sabes, y ya no le vas a borrar el
  formulario a nadie sin querer.
- **El `<v-dialog>` se teletransporta**, y eso rompió tus tests de VU0 sin que
  hubiera regresión alguna. Saber diagnosticar un test rojo que **no** es un bug es
  la mitad del oficio de mantener legacy.

La señal de que quedó bien:

> "los tests de VU0 pasan **sin haberlos tocado** — y los que no pasan, sé explicar
> exactamente por qué, y la respuesta es 'el nodo se teletransportó', no 'Vuetify
> es raro'."

Y la señal de que quedó **muy** bien:

> "puedo defender por escrito qué me llevó la migración y qué me trajo, campo por
> campo, dependencia por dependencia."

---

**Siguiente parada:** 📋 **VU3 — Migrar el dashboard a `v-data-table`.**

El formulario ya es Vuetify. Ahora la tabla — y ahí la cosa se pone seria. En esta
fase, `v-form` te *ayudó*: te quitó trabajo, te regaló el `valid`, y solo te pidió
una dependencia a cambio.

`v-data-table` **te va a pelear el estado.**

Trae de fábrica su propia paginación, su propio orden, su propio filtro
(`:options.sync`). Y tu Vuex de F10 ya los tiene. **Dos dueños para el mismo dato.**
Decidir quién manda —el componente o el store— es la fase entera. Y de paso, el
diálogo Vuetify que acabas de montar va a convivir con una lista todavía en
Bootstrap: **el legacy a medio migrar, en vivo.**

Prepárate: en VU3 vas a **borrar ~150 líneas** del dashboard de F4. Y se va a
sentir muy bien, hasta que descubras a quién le pertenecen ahora.
