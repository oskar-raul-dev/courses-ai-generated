# 🪜 Fase 6 — Wizard mínimo

## 🎯 Propósito

El formulario de creación de la Fase 5 funciona, pero en mesas de soporte
reales el alta de un ticket suele guiarse por pasos: primero qué pasó, luego
cómo clasificarlo, y al final confirmar. Hoy construimos ese **wizard de 3
pasos**:

```
Paso 1: Datos básicos  →  Paso 2: Clasificación  →  Paso 3: Confirmación
(título, descripción)     (prioridad, asignado)      (resumen + crear)
```

Pero como siempre, el wizard es la excusa. Lo que realmente se aprende:

- **componentes dinámicos** (`<component :is>`): el mecanismo de la época para
  intercambiar vistas sin router;
- **`keep-alive`**: mantener vivo el estado de los pasos al ir y volver;
- **`$refs`**: la puerta trasera de Vue — cuándo es legítima y cuándo es olor;
- la pregunta incómoda de la fase: **¿el borrador del wizard vive en el
  componente o en el store?** (spoiler: aquí, en el componente — y sabrás
  defender por qué).

> La regla de la fase: el wizard es dueño del borrador y de la navegación.
> Los pasos capturan y validan su pedazo. Nadie más se entera.

---

## ✅ Qué queda listo al terminar

- ruta `/tickets/wizard` con el wizard de 3 pasos funcionando;
- indicador visual de progreso (en qué paso voy, cuáles completé);
- validación **por paso**: no avanzas si tu paso está inválido;
- "Atrás" sin perder lo escrito (gracias a `keep-alive`);
- paso de confirmación con resumen de solo lectura;
- creación final reutilizando `ticketService` y las reglas de payload de la
  Fase 5;
- protección contra abandono con borrador a medias (`beforeRouteLeave`);
- criterio claro y defendible de estado local vs store para este caso.

## 🚫 Qué NO entra todavía

- librerías de wizard/steppers (el punto es construirlo a mano);
- guardar borradores en el servidor;
- pasos condicionales o ramificados (ejercicio 🔴);
- transiciones animadas entre pasos (ejercicio 🟠);
- migrar el borrador a Vuex — aquí se **discute**, la Fase 10 decide.

---

## 🧠 Concepto: ¿dónde vive el estado de un wizard?

La decisión de arquitectura de la fase, antes de una línea de código.
Opciones reales que verás en legacy:

| Dónde vive el borrador | Sobrevive a "Atrás" | Sobrevive a navegar fuera | Sobrevive a F5 (recarga) | Complejidad | Cuándo tiene sentido |
|---|---|---|---|---|---|
| 🧩 Componente wizard (padre) | ✅ | ❌ (muere con la vista) | ❌ | mínima | wizard contenido en UNA vista — **nuestro caso** |
| 🗂️ Módulo Vuex | ✅ | ✅ | ❌ | media | pasos en **rutas distintas**, o preview del borrador en otro lugar de la app |
| 💾 Vuex + sessionStorage | ✅ | ✅ | ✅ | alta | flujos largos donde perder el borrador es caro (ej. formularios de 20 min) |

**Nuestra decisión:** el borrador vive en `data` del componente wizard. Los
tres pasos ocurren dentro de la misma ruta, nadie más necesita ver el
borrador, y que muera al abandonar es aceptable (lo protegemos con un
`confirm`). Meterlo en Vuex aquí sería el clásico sobre-uso del store que
advertimos desde la Fase 1.

La señal para migrar a Vuex sería que apareciera **cualquiera** de estas:
pasos en rutas separadas (`/wizard/step-1`), un panel externo que muestre
el borrador, o el requisito "retomar donde quedé". El ejercicio 24 te hace
hacer esa migración para que compares en carne propia.

---

## 🧩 Mini repaso: los `.vue` de esta fase (lo nuevo respecto a la Fase 5)

### `<component :is>` — componentes dinámicos

El mecanismo estrella del wizard: un solo punto de montaje que intercambia
componentes según una variable.

```vue
<component :is="currentStepComponent" />
```

```js
computed: {
  currentStepComponent: function () {
    // puede devolver el nombre registrado o el objeto componente importado
    return this.steps[this.currentStep - 1].component;
  }
}
```

Cuando `currentStep` cambia, Vue **destruye** el componente actual y **monta**
el nuevo. Es el mismo patrón que usan los tabs de la época. Ojo al verbo:
*destruye* — el estado local del paso muere en cada cambio… salvo que entre
`keep-alive`. 👇

### `keep-alive` — congelar componentes en vez de destruirlos

```vue
<keep-alive>
  <component :is="currentStepComponent" ref="stepComponent" />
</keep-alive>
```

Envuelto en `keep-alive`, el componente que sale **no se destruye: se
desactiva** y queda cacheado con todo su estado (`data`, `$v` de vuelidate,
scroll interno). Al volver, se reactiva tal cual estaba.

Cambian los hooks del ciclo de vida:

| Sin keep-alive | Con keep-alive |
|---|---|
| salir del paso → `beforeDestroy` / `destroyed` | salir → `deactivated` (el componente sigue vivo) |
| volver al paso → `created` + `mounted` **de cero** | volver → `activated` (created/mounted NO se repiten) |

Consecuencia práctica que muerde en legacy: si un paso carga datos en
`mounted`, con `keep-alive` esa carga corre **una sola vez**. Si necesitas
refrescar al volver, el hook es `activated`. Este detalle explica muchos
"volví a la pestaña y muestra datos viejos" en apps de la época.

### `$refs` — la puerta trasera (usar con juicio)

```vue
<component :is="currentStepComponent" ref="stepComponent" />
```

```js
var step = this.$refs.stepComponent;   // instancia del componente hijo
if (step.validate && !step.validate()) return;
```

`ref` da acceso **directo** a la instancia del hijo: sus datos, sus métodos,
todo. Es la excepción deliberada a "props abajo, eventos arriba".

| Uso de `$refs` | Veredicto |
|---|---|
| el padre invoca una **acción puntual** del hijo: `validate()`, `focus()`, `reset()` | ✅ legítimo y muy de la época |
| acceder a un elemento DOM (`this.$refs.input.focus()`) | ✅ para eso existe |
| el padre **lee o muta el estado** del hijo (`this.$refs.step.form.title = ...`) | 🚨 olor: eso debía ser prop/evento |
| refs encadenados (`$refs.a.$refs.b`) o `$parent` | 💀 encontraste el epicentro del legacy |

Dos advertencias técnicas: `$refs` **no es reactivo** (no lo uses en computed
ni templates) y solo existe **después** de montar (en `mounted`, no en
`created`). Dentro de `v-if`/`component :is`, puede ser `undefined` en el
instante del cambio — por eso el `step.validate &&` defensivo.

### `watch` — reaccionar a cambios (por fin formalmente)

Lo rozamos en el ejercicio 17 de la Fase 4; el wizard le da su primer uso
legítimo en el curso:

```js
watch: {
  currentStep: function (newVal, oldVal) {
    // efecto secundario al cambiar de paso: scroll arriba
    window.scrollTo(0, 0);
  }
}
```

La regla para no confundirlo con computed:

| | `computed` | `watch` |
|---|---|---|
| Devuelve | un valor derivado | nada: ejecuta efectos |
| Para | transformar estado en otra cosa | reaccionar: HTTP, timers, DOM, logging |
| Pregunta clave | "¿qué ES esto en función de aquello?" | "¿qué HAGO cuando aquello cambie?" |

Si tu watch termina asignando a otra propiedad de `data` que solo depende de
lo observado… era un computed. El 80% de los watchers en legacy fallan esa
prueba.

---

## 💻 Código de la fase

### Estructura que se agrega

```
src/
  components/
    tickets/
      wizard/
        WizardProgress.vue       ← indicador de pasos
        StepData.vue            ← paso 1
        StepClassification.vue    ← paso 2
        StepConfirmation.vue     ← paso 3
  views/
    TicketWizardView.vue         ← el orquestador
```

### `components/tickets/wizard/WizardProgress.vue`

Presentacional puro: recibe dónde vamos, pinta el camino.

```vue
<template>
  <div class="d-flex justify-content-between mb-4">
    <div
      v-for="step in steps"
      :key="step.number"
      class="text-center flex-fill"
    >
      <div
        class="rounded-circle d-inline-flex align-items-center justify-content-center"
        style="width: 36px; height: 36px;"
        :class="circleClass(step.number)"
      >
        <span v-if="step.number < current">✓</span>
        <span v-else>{{ step.number }}</span>
      </div>
      <div class="small mt-1" :class="{ 'font-weight-bold': step.number === current }">
        {{ step.label }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: "WizardProgress",
  props: {
    steps: { type: Array, required: true },   // [{ number, label }]
    current: { type: Number, required: true }
  },
  methods: {
    circleClass: function (number) {
      if (number < this.current) return "bg-success text-white";
      if (number === this.current) return "bg-primary text-white";
      return "bg-light border text-muted";
    }
  }
};
</script>
```

**🔎 Qué hace:** recibe la definición de pasos y el actual; para cada círculo
decide su cara (✓ verde si ya pasó, número azul si es el actual, gris si
falta) y resalta el label activo. Cero estado propio: todo lo que pinta viene
de props.

**✅ Buenas prácticas aplicadas:**
- `circleClass` es un **method y no un computed** porque recibe argumento —
  los computed no aceptan parámetros (limitación clásica que confunde). Regla:
  derivación por-item dentro de un `v-for` → method con argumento; derivación
  global → computed.
- El componente no sabe qué hay en cada paso ni cómo se navega: si mañana el
  wizard tiene 5 pasos o los pasos cambian de orden, este archivo no se toca.
- Los estilos condicionales van por clases Bootstrap (`bg-success`,
  `bg-light`), no por `style` inline calculado: más legible y theme-able.

### `components/tickets/wizard/StepData.vue`

Cada paso repite el patrón de la Fase 5 (prop → copia local + vuelidate),
más dos métodos públicos que el wizard invocará vía `$refs`: `validate()` y
`getData()`.

```vue
<template>
  <div>
    <h5 class="mb-3">¿Qué pasó?</h5>

    <div class="form-group">
      <label for="title">Título *</label>
      <input
        id="title"
        v-model.trim="form.title"
        type="text"
        class="form-control"
        :class="{ 'is-invalid': $v.form.title.$error }"
        @blur="$v.form.title.$touch()"
      />
      <div v-if="$v.form.title.$error" class="invalid-feedback">
        <span v-if="!$v.form.title.required">El título es obligatorio.</span>
        <span v-else>Entre 5 y 80 caracteres.</span>
      </div>
    </div>

    <div class="form-group">
      <label for="description">Descripción *</label>
      <textarea
        id="description"
        v-model.trim="form.description"
        rows="4"
        class="form-control"
        :class="{ 'is-invalid': $v.form.description.$error }"
        @blur="$v.form.description.$touch()"
      ></textarea>
      <div v-if="$v.form.description.$error" class="invalid-feedback">
        Cuenta qué pasó: mínimo 10 caracteres.
      </div>
    </div>
  </div>
</template>

<script>
import { required, minLength, maxLength } from "vuelidate/lib/validators";

export default {
  name: "StepData",
  props: {
    draft: { type: Object, required: true }
  },
  data: function () {
    return {
      form: {
        title: this.draft.title,
        description: this.draft.description
      }
    };
  },
  validations: {
    form: {
      title: { required: required, minLength: minLength(5), maxLength: maxLength(80) },
      description: { required: required, minLength: minLength(10) }
    }
  },
  methods: {
    // API pública del paso: el wizard la invoca por $refs
    validate: function () {
      this.$v.$touch();
      return !this.$v.$invalid;
    },
    getData: function () {
      return Object.assign({}, this.form);
    }
  }
};
</script>
```

**🔎 Qué hace:** captura título y descripción sobre una **copia local** del
draft (`form`), valida con vuelidate como en la Fase 5, y expone dos métodos
públicos — `validate()` (fuerza `$touch` y responde si el paso está bien) y
`getData()` (devuelve una copia de lo capturado). El wizard los invocará por
`$refs`; el paso nunca sabe qué hay antes ni después de él.

Nota el atajo respecto a la Fase 5: como la prop `draft` siempre existe,
inicializamos `form` directamente en `data` leyendo `this.draft` — en `data`
las props ya están disponibles. Mismo patrón prop → copia local, una línea
menos de `created`.

**✅ Buenas prácticas aplicadas:**
- `validate()` y `getData()` son un **contrato informal**: todo paso del
  wizard los implementa con la misma firma. En Vue 2 no hay interfaces; la
  convención documentada ES la interfaz — por eso el nombre y la firma
  importan tanto (y por eso el ejercicio 18 mide si el contrato aguanta un
  paso nuevo).
- `getData()` devuelve `Object.assign({}, this.form)` — una **copia**, no la
  referencia. Si devolviera `this.form` directo, el wizard y el paso
  compartirían el mismo objeto y las ediciones futuras del paso mutarían el
  draft "oficial" por debajo de la mesa. Copias en las fronteras: barato hoy,
  impagable en debugging mañana.
- Los mensajes de error viven **dentro del paso**, junto a sus reglas. El
  wizard recibe un simple `true/false` de `validate()`: no necesita saber qué
  falló para decidir si avanza.

### `components/tickets/wizard/StepClassification.vue`

```vue
<template>
  <div>
    <h5 class="mb-3">Clasifica el ticket</h5>

    <div class="form-row">
      <div class="form-group col-md-6">
        <label for="priority">Prioridad *</label>
        <select
          id="priority"
          v-model="form.priority"
          class="form-control"
          :class="{ 'is-invalid': $v.form.priority.$error }"
          @blur="$v.form.priority.$touch()"
        >
          <option value="">Seleccione...</option>
          <option value="low">Baja</option>
          <option value="medium">Media</option>
          <option value="high">Alta</option>
        </select>
        <div v-if="$v.form.priority.$error" class="invalid-feedback">
          Seleccione una prioridad.
        </div>
      </div>

      <div class="form-group col-md-6">
        <label for="assignee">Asignar a</label>
        <input
          id="assignee"
          v-model.trim="form.assignee"
          class="form-control"
          placeholder="(opcional, soporte lo asignará)"
        />
      </div>
    </div>

    <div v-if="form.priority === 'high'" class="alert alert-warning">
      ⚠️ Los tickets de prioridad alta notifican al equipo de guardia.
      Úsala solo si bloquea tu trabajo.
    </div>
  </div>
</template>

<script>
import { required } from "vuelidate/lib/validators";

function oneOf(values) {
  return function (value) {
    return values.indexOf(value) !== -1;
  };
}

export default {
  name: "StepClassification",
  props: {
    draft: { type: Object, required: true }
  },
  data: function () {
    return {
      form: {
        priority: this.draft.priority,
        assignee: this.draft.assignee
      }
    };
  },
  validations: {
    form: {
      priority: { required: required, oneOf: oneOf(["low", "medium", "high"]) }
    }
  },
  methods: {
    validate: function () {
      this.$v.$touch();
      return !this.$v.$invalid;
    },
    getData: function () {
      return Object.assign({}, this.form);
    }
  }
};
</script>
```

**🔎 Qué hace:** mismo contrato que el paso 1 (copia local + `validate()` +
`getData()`), con dos detalles nuevos: solo valida `priority` (asignar es
opcional), y muestra una **advertencia reactiva** — el `v-if` sobre
`form.priority === 'high'` hace aparecer la alerta en el instante en que el
usuario selecciona alta, sin watch ni evento: pura cadena reactiva de la
Fase 4 aplicada a UX de formulario.

**✅ Buenas prácticas (y una deuda a la vista):**
- La advertencia de prioridad alta es **educación en el punto de decisión**:
  mejor que validar después o que un tooltip que nadie lee. Patrón barato y
  muy efectivo en sistemas internos.
- 💸 Confesión: el validador `oneOf` está **duplicado** respecto al
  `TicketForm` de la Fase 5. Dos copias de la misma función es la señal
  clásica para extraer a `utils/validators.js` — lo dejamos así para que la
  duplicación se sienta; extráela tú y consume desde ambos formularios (mini
  ejercicio implícito). Regla: a la segunda copia se extrae; a la primera
  todavía no (no adivines reutilización).

### `components/tickets/wizard/StepConfirmation.vue`

Solo lectura: sin vuelidate, sin `getData`. Su `validate()` siempre pasa (el
wizard lo llama defensivamente igual).

```vue
<template>
  <div>
    <h5 class="mb-3">Confirma antes de crear</h5>

    <dl class="row">
      <dt class="col-sm-3">Título</dt>
      <dd class="col-sm-9">{{ draft.title }}</dd>

      <dt class="col-sm-3">Descripción</dt>
      <dd class="col-sm-9" style="white-space: pre-line;">{{ draft.description }}</dd>

      <dt class="col-sm-3">Prioridad</dt>
      <dd class="col-sm-9">
        <ticket-priority-badge :priority="draft.priority" />
      </dd>

      <dt class="col-sm-3">Asignado a</dt>
      <dd class="col-sm-9">{{ draft.assignee || "Sin asignar" }}</dd>
    </dl>

    <div class="alert alert-info">
      El ticket se creará con estado <strong>Abierto</strong> a nombre de
      <strong>{{ reporterName }}</strong>.
    </div>
  </div>
</template>

<script>
import TicketPriorityBadge from "../TicketPriorityBadge.vue";

export default {
  name: "StepConfirmation",
  components: { TicketPriorityBadge },
  props: {
    draft: { type: Object, required: true }
  },
  computed: {
    reporterName: function () {
      var user = this.$store.getters["auth/currentUser"];
      return user ? user.name : "";
    }
  }
};
</script>
```

**🔎 Qué hace:** presenta el `draft` completo en un `<dl>` de definición
(el elemento HTML correcto para pares etiqueta/valor — semántica gratis),
reutiliza el badge de prioridad de la Fase 4, y lee del store quién será el
reporter para que el usuario confirme con toda la información. No tiene
`getData()` porque no captura nada, y el wizard llama `validate()` de forma
defensiva con el `step.validate &&`.

**✅ Buenas prácticas aplicadas:**
- `white-space: pre-line` respeta los saltos de línea que el usuario escribió
  en la descripción — detalle diminuto que evita el clásico "escribí tres
  párrafos y me lo mostraron como sopa".
- El computed `reporterName` maneja el caso `user == null` con un fallback:
  los getters de store pueden devolver null en instantes raros (logout en
  otra pestaña) y un template que hace `user.name` a secas revienta.
- (Reutilizamos `TicketPriorityBadge` de la Fase 4 sin tocarlo: los
  componentes de presentación bien hechos pagan dividendos. 💰)

### `views/TicketWizardView.vue` — el orquestador

```vue
<template>
  <section style="max-width: 640px;">
    <page-title title="Nuevo ticket" subtitle="Asistente paso a paso" />

    <wizard-progress :steps="stepDefs" :current="currentStep" />

    <div class="card">
      <div class="card-body">
        <div v-if="error" class="alert alert-danger">{{ error }}</div>

        <keep-alive>
          <component
            :is="currentStepComponent"
            ref="stepComponent"
            :draft="draft"
          />
        </keep-alive>
      </div>

      <div class="card-footer d-flex justify-content-between">
        <button
          class="btn btn-outline-secondary"
          :disabled="currentStep === 1 || saving"
          @click="back"
        >
          ← Atrás
        </button>

        <button
          v-if="currentStep < stepDefs.length"
          class="btn btn-primary"
          @click="next"
        >
          Siguiente →
        </button>
        <button
          v-else
          class="btn btn-success"
          :disabled="saving"
          @click="finish"
        >
          {{ saving ? "Creando..." : "✅ Crear ticket" }}
        </button>
      </div>
    </div>
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import WizardProgress from "../components/tickets/wizard/WizardProgress.vue";
import StepData from "../components/tickets/wizard/StepData.vue";
import StepClassification from "../components/tickets/wizard/StepClassification.vue";
import StepConfirmation from "../components/tickets/wizard/StepConfirmation.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketWizardView",
  components: { PageTitle, WizardProgress, StepData, StepClassification, StepConfirmation },
  data: function () {
    return {
      currentStep: 1,
      stepDefs: [
        { number: 1, label: "Datos", component: StepData },
        { number: 2, label: "Clasificación", component: StepClassification },
        { number: 3, label: "Confirmación", component: StepConfirmation }
      ],
      // ÚNICA fuente de verdad del borrador
      draft: {
        title: "",
        description: "",
        priority: "",
        assignee: ""
      },
      saving: false,
      error: "",
      created: false // para no molestar con el confirm tras crear
    };
  },
  computed: {
    currentStepComponent: function () {
      return this.stepDefs[this.currentStep - 1].component;
    },
    hasChanges: function () {
      return !!(this.draft.title || this.draft.description ||
                this.draft.priority || this.draft.assignee);
    }
  },
  watch: {
    currentStep: function () {
      window.scrollTo(0, 0);
    }
  },
  beforeRouteLeave: function (to, from, next) {
    if (this.created || !this.hasChanges) {
      next();
      return;
    }
    var ok = window.confirm("Tienes un ticket a medias. ¿Salir y perder el borrador?");
    next(ok);
  },
  methods: {
    mergeCurrentStep: function () {
      var step = this.$refs.stepComponent;
      if (step && step.getData) {
        this.draft = Object.assign({}, this.draft, step.getData());
      }
    },
    next: function () {
      var step = this.$refs.stepComponent;
      if (step && step.validate && !step.validate()) {
        return; // el paso pinta sus propios errores
      }
      this.mergeCurrentStep();
      this.currentStep++;
    },
    back: function () {
      this.mergeCurrentStep(); // no perder lo escrito aunque esté inválido
      this.currentStep--;
    },
    finish: function () {
      var self = this;
      this.saving = true;
      this.error = "";

      var payload = Object.assign({}, this.draft, {
        status: "open",
        reporter: this.$store.getters["auth/currentUser"].username,
        createdAt: new Date().toISOString()
      });

      ticketService
        .createTicket(payload)
        .then(function (created) {
          self.created = true;
          self.$router.push("/tickets/" + created.id + "?created=1");
        })
        .catch(function () {
          self.error = "No se pudo crear el ticket. Tu borrador sigue aquí.";
        })
        .finally(function () {
          self.saving = false;
        });
    }
  }
};
</script>
```

**🔎 Qué hace, pieza por pieza:**

| Pieza | Su trabajo |
|---|---|
| `stepDefs` en `data` | la definición del wizard **como configuración**: número, label y componente de cada paso. Agregar un paso = agregar una entrada |
| `draft` | la única fuente de verdad del borrador; los pasos reciben rebanadas y devuelven rebanadas |
| `currentStepComponent` (computed) | traduce el número de paso al componente que `<component :is>` debe montar |
| `hasChanges` (computed) | ¿hay algo escrito? — alimenta el guard de abandono sin duplicar lógica |
| `mergeCurrentStep()` | el único punto donde el draft absorbe datos de un paso (vía `$refs` + `getData()`) |
| `created` (flag) | recuerda que el ticket ya se creó para que el guard no moleste tras el éxito |

**✅ Buenas prácticas aplicadas:**
- **Configuración sobre condicionales:** sin `stepDefs`, el template tendría
  tres `v-if="currentStep === n"` y la lógica de avance estaría regada. Con
  la lista, `next()`/`back()` son aritmética y el render es una línea. Este
  patrón (datos que describen la UI) escala a menús, tabs y formularios
  dinámicos — reconócelo en legacy y úsalo al refactorizar.
- Los botones de navegación viven en el `card-footer` del wizard, **una sola
  vez**, con su estado (`disabled` en el paso 1, cambio a "Crear" en el
  último) derivado de `currentStep`. Botones dentro de cada paso = tres
  copias del mismo layout desincronizándose con el tiempo.
- El guard `beforeRouteLeave` consulta `hasChanges` (computed) en vez de
  comparar campos a mano ahí dentro: la pregunta "¿hay cambios?" tiene UN
  dueño, y quien la necesite (el guard hoy, un asterisco en el título mañana)
  la reutiliza.
- El `catch` de `finish()` dice la verdad útil: "Tu borrador sigue aquí" —
  y es cierto por diseño (draft intacto + pasos cacheados). Mensajes de error
  que informan qué NO se perdió reducen el pánico del usuario más que
  cualquier spinner bonito.

### Ruta y acceso

```js
// router/index.js — junto a las otras rutas de tickets (antes de /tickets/:id)
{
  path: "/tickets/wizard",
  name: "ticket-wizard",
  component: TicketWizardView,
  meta: { requiresAuth: true }
}
```

Y en el dashboard, junto al botón existente:

```vue
<router-link to="/tickets/wizard" class="btn btn-outline-primary mb-3 ml-2">
  🪜 Asistente
</router-link>
```

Por ahora conviven el formulario simple (`/tickets/new`) y el asistente.
El ejercicio 13 te hace decidir cuál sobrevive — como en la vida real, donde
"temporal" es el estado más permanente del software. 😄

---

## 🔄 Los flujos del wizard, paso a paso

### ➡️ Avanzar de paso (el flujo que junta todo lo nuevo)

```
1. clic en "Siguiente" (el botón vive en el WIZARD, no en el paso)
   └─ next():
      a. this.$refs.stepComponent → instancia viva del paso actual
      b. step.validate() → $touch() interno → ¿$invalid?
         ├─ SÍ → return: los errores ya se pintaron DENTRO del paso.
         │        El wizard no sabe qué falló ni le importa.
         └─ NO → sigue
      c. mergeCurrentStep(): draft = {...draft, ...step.getData()}
         └─ el borrador del wizard absorbe el pedazo del paso
      d. currentStep++

2. la reactividad hace su cadena:
   └─ currentStepComponent (computed) se recalcula
      └─ <component :is> cambia de componente
         ├─ el paso saliente NO se destruye: keep-alive → deactivated
         └─ el paso entrante:
             ├─ primera visita → created + mounted (lee draft, ya con lo mergeado)
             └─ visita repetida → activated (conserva TODO su estado anterior)
   └─ watch de currentStep dispara → scroll arriba
   └─ WizardProgress recibe la prop nueva → pinta el ✓ verde
```

El detalle fino está en 2: hay **dos mecanismos de memoria** cooperando. El
`draft` del padre es la memoria *oficial* (lo validado y mergeado);
`keep-alive` es la memoria *de trabajo* (lo tecleado, aunque esté inválido).
Por eso `back()` también hace merge: para que la memoria oficial no se quede
atrás de lo que el usuario ve.

### ⬅️ Volver atrás

```
1. clic en "Atrás" → mergeCurrentStep() SIN validar → currentStep--
2. keep-alive reactiva la instancia previa del paso → activated
   └─ el formulario aparece EXACTAMENTE como lo dejaste
      (incluidos los errores de vuelidate si los había: $v vive en la instancia)
```

¿Por qué merge sin validar al ir atrás? Porque bloquear el retroceso por un
campo inválido es UX hostil — el usuario quizá vuelve justamente a revisar
algo para decidir qué poner aquí.

### ✅ Finalizar

```
1. paso 3 visible → el botón cambia a "Crear ticket" (v-if sobre currentStep)
2. finish() → mismo ritual de la Fase 5:
   saving=true → payload (draft + status/reporter/createdAt) → POST
3a. éxito → created=true → redirect al detalle con ?created=1
    └─ created=true hace que beforeRouteLeave deje pasar SIN preguntar
3b. error → mensaje "tu borrador sigue aquí" (y es verdad: draft intacto,
    pasos cacheados — el usuario puede ir atrás, corregir y reintentar)
```

### 🚪 Intentar abandonar a medias

```
1. clic en "Tickets" del sidebar (o back del navegador)
2. beforeRouteLeave intercepta ANTES de desmontar:
   ├─ created=true o borrador vacío → next() → adiós sin drama
   └─ hay cambios → confirm()
       ├─ Aceptar → next(true) → la vista se destruye → keep-alive y draft mueren juntos
       └─ Cancelar → next(false) → la navegación se CANCELA, sigues donde estabas
```

`next(false)` es la parte que sorprende: el router aborta la transición
completa — la URL ni cambia. Es el mismo guard in-component del ejercicio 17
de la Fase 5, ahora en su hábitat natural.

---

## ⚠️ Errores comunes

- botones de navegación **dentro** de cada paso → tres copias del mismo layout
  y lógica de avance regada por todas partes;
- olvidar `keep-alive` → "Atrás" muestra el paso vacío (created corre de nuevo
  y el clon parte del draft… que sí tiene los datos mergeados, pero se pierden
  los no validados y el estado de $v — pruébalo quitándolo);
- usar `$refs` para **leer estado** del paso continuamente en vez de invocar
  `validate()/getData()` puntuales — de puerta trasera a puerta principal;
- validar todo el borrador solo al final → el usuario descubre en el paso 3
  que el paso 1 estaba mal;
- bloquear "Atrás" si el paso actual es inválido;
- meter el borrador en Vuex "por si acaso" — el caso no lo pide y ahora tienes
  estado global que limpiar a mano al salir;
- olvidar el caso "creé el ticket" en `beforeRouteLeave` → confirm molesto
  después del éxito.

---

## 🧪 Ejercicios (26)

**🟢 Fácil (1–8)**

1. Agrega un contador "Paso X de Y" bajo el indicador de progreso.
2. Cambia el texto del botón final según prioridad: "Crear ticket urgente 🚨"
   si es `high`.
3. Haz que el título de la página (`page-title`) muestre el label del paso
   actual como subtitle.
4. En el paso de confirmación, muestra también la fecha de creación estimada
   (hoy) con el filtro `formatDate` de la Fase 4.
5. Agrega el hook `activated` al paso 1 con un `console.log` y verifica en
   consola que al volver NO se ejecutan `created`/`mounted`.
6. Quita el `keep-alive`, ve al paso 2, vuelve, y documenta en un comentario
   exactamente qué se perdió. Restáuralo.
7. Deshabilita "Siguiente" mientras `saving` (edge case: no aplica hoy, pero
   déjalo defensivo).
8. Haz que Escape… no, mejor: agrega un botón "Cancelar" que navegue a
   `/tickets` (y verifica que `beforeRouteLeave` pregunta).

**🟡 Intermedio (9–17)**

9. Convierte el indicador de progreso en una barra Bootstrap (`progress`)
   con porcentaje real (paso/total).
10. Permite clic en los círculos del `WizardProgress` para saltar — pero solo
    a pasos **ya visitados** (emite `go` con el número; el wizard valida y
    mergea el actual antes de saltar). Los futuros, deshabilitados.
11. En el paso 2, puebla el campo asignado con el `<select>` de agentes del
    ejercicio 9 de la Fase 5 (reutiliza `userService`).
12. Agrega validación cruzada: si `priority === "high"`, la descripción exige
    mínimo 30 caracteres ("justifica la urgencia"). Pista: en vuelidate las
    reglas pueden ser funciones que reciben `this` vía closure o usar
    `requiredIf`-style custom.
13. Toma la decisión de producto: elimina `/tickets/new` (el form simple) y
    deja solo el asistente, O al revés. Ajusta rutas, botones y escribe 3
    líneas justificando. No hay respuesta correcta; hay decisión defendida.
14. Persiste el `draft` en `sessionStorage` en cada merge y restáuralo al
    montar el wizard: ahora sobrevive a F5. Límpialo al crear o abandonar.
15. Agrega un mini-resumen lateral (visible en pasos 1 y 2) que muestre el
    draft acumulado hasta ahora — en tiempo real no: **solo lo mergeado**.
    Reflexiona: ¿por qué "en tiempo real" exigiría cambiar la arquitectura?
16. Emite un evento `step-changed` desde el wizard y úsalo para loguear
    analytics de mentira: `console.log("wizard_step", n, Date.now())`.
17. Agrega transición animada entre pasos con `<transition name="fade">`
    alrededor del `<component>` (CSS: opacity + 0.2s). Cuidado con el modo
    `out-in`.

**🟠 Difícil (18–23)**

18. Paso 4 nuevo: "Adjuntos (mock)" — un input file que NO sube nada, solo
    lista nombres y tamaños en el draft (`attachments: [{name, size}]`).
    Confirmación los muestra. Todo el punto: medir cuánto cuesta agregar un
    paso con tu arquitectura (debería ser: crear componente + una línea en
    `stepDefs`).
19. Extrae la maquinaria (progress + keep-alive + botones + next/back/refs) a
    un componente genérico `WizardShell.vue` que reciba `stepDefs` y el draft
    por props, y emita `finish`. El wizard de tickets queda como configuración.
    Pista: necesitarás un **slot** o pasar los componentes en la definición —
    tu primer contacto serio con slots.
20. Validación asíncrona en el paso 1: reutiliza el validador de título
    duplicado del ejercicio 24 de la Fase 5. El botón "Siguiente" debe esperar
    la validación (`validate()` ahora devuelve una Promise — ajusta `next()`).
21. Guarda el paso actual en la URL como query (`?paso=2`) con
    `router.replace`, y al montar, restaura paso + draft (combinado con el
    ejercicio 14). El botón "atrás" del navegador ahora retrocede pasos.
    Cuidado con el loop replace↔watch.
22. Modo edición: `/tickets/:id/wizard` carga un ticket existente al draft
    y el botón final hace PATCH. ¿Cuánto de tu wizard era reutilizable de
    verdad?
23. Pasos condicionales: agrega al paso 2 un check "es incidente de seguridad";
    si está marcado, aparece un paso extra "Detalles de seguridad" entre el 2
    y el 3. `stepDefs` pasa a ser un computed. El indicador de progreso debe
    reaccionar bien.

**🔴 Muy difícil (24–26)**

24. Migra el borrador a un módulo Vuex `ticketDraft` (state, mutations
    `MERGE_DRAFT`/`RESET_DRAFT`, getters). Los pasos leen del store; el merge
    hace commit. Al terminar, escribe una comparación honesta de 5 líneas:
    ¿qué mejoró, qué se complicó, cuándo lo justificarías? (Guárdala: la
    Fase 10 retoma esta discusión con tu experiencia ya hecha.)
25. Divide el wizard en rutas hijas (`/tickets/wizard/data`,
    `/classification`, `/confirmation`) con nested routes de Vue Router y
    `<router-view>` en lugar de `<component :is>`. El draft ahora SÍ necesita
    el store del ejercicio 24 (o un padre común). Compara: ¿qué ganaste
    (deep-linking, back del navegador gratis) y qué perdiste (keep-alive ya
    no aplica igual — investiga `<keep-alive><router-view/></keep-alive>`)?
26. Auto-guardado de borrador en servidor: colección `drafts` en json-server;
    cada merge hace PUT de `drafts/{username}` con debounce de 2s; al entrar
    al wizard, si existe borrador, ofrece "Retomar donde quedaste". Maneja el
    caso de crear el ticket → DELETE del draft. Acabas de construir la feature
    que las tablas de la sección de concepto marcaban como "alta complejidad"
    — evalúa si valió la pena.

---

## 📚 Referencias

**Documentación oficial**

- Vue 2 — Dynamic Components: https://v2.vuejs.org/v2/guide/components-dynamic-async.html
- Vue 2 — keep-alive (API): https://v2.vuejs.org/v2/api/#keep-alive
- Vue 2 — activated/deactivated: https://v2.vuejs.org/v2/api/#activated
- Vue 2 — refs: https://v2.vuejs.org/v2/api/#ref
- Vue 2 — Watchers: https://v2.vuejs.org/v2/guide/computed.html#Watchers
- Vue 2 — Transitions (para el ejercicio 17):
  https://v2.vuejs.org/v2/guide/transitions.html
- Vue 2 — Slots (para el ejercicio 19): https://v2.vuejs.org/v2/guide/components-slots.html
- Vue Router 3 — Nested Routes (para el ejercicio 25):
  https://v3.router.vuejs.org/guide/essentials/nested-routes.html

**Video / apoyo**

- Vue Mastery — Intro to Vue 2 (tabs con dynamic components):
  https://www.vuemastery.com/courses/intro-to-vue-js/vue-instance/
- Net Ninja — Vue JS 2: episodios de refs y ciclo de vida (playlist en YouTube)

**Orden de lectura sugerido:** Dynamic Components → keep-alive →
ref → volver al código. Slots y Nested Routes solo si haces los ejercicios
🟠/🔴 correspondientes.

---

## 🚀 Cierre

El Mini Jira ya guía al usuario paso a paso, y tú te llevas cuatro
herramientas y una decisión:

- **`<component :is>`** para intercambiar componentes sin router,
- **`keep-alive`** y sus hooks `activated`/`deactivated` para no perder estado,
- **`$refs`** como puerta trasera con reglas de uso claras,
- **`watch`** para efectos, con la prueba del ácido vs computed,
- y la decisión defendida: **el borrador vive local**, con la lista exacta de
  señales que justificarían moverlo al store.

La señal de que quedó bien:

> "agregar un paso al wizard es crear un componente con `validate()` y
> `getData()`, y sumar una línea a `stepDefs`. Nada más se toca."

**Siguiente parada:** 📊 Fase 7 — Métricas mínimas: chart.js 2.x entra al
proyecto y el dashboard aprende a contar historias con tickets por estado y
por agente.
