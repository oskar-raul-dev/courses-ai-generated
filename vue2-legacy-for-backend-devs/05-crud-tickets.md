# 📝 Fase 5 — CRUD mínimo de tickets

## 🎯 Propósito

El dashboard de la Fase 4 es de solo lectura. Hoy el Mini Jira aprende a
**crear, editar y eliminar** tickets — y de paso, **vuelidate** paga por fin
la instalación que hicimos en la Fase 0 🎉.

Lo que realmente se aprende aquí:

- **un solo formulario para crear y editar** (el patrón que separa a un CRUD
  mantenible de uno copy-pasteado);
- **validación declarativa con vuelidate**: la librería de validación más
  común en bases Vue 2 de la época;
- el ciclo completo **formulario → servicio → API → redirección → feedback**;
- borrado con confirmación (y por qué "borrar sin preguntar" es un bug, no
  una feature).

> La regla de la fase: el formulario no sabe de HTTP ni de rutas.
> Captura, valida y emite. El resto es problema de la vista.

---

## ✅ Qué queda listo al terminar

- ruta `/tickets/new` con formulario de creación validado;
- ruta `/tickets/:id/edit` reutilizando **el mismo formulario**;
- botones de editar y eliminar en el detalle del ticket;
- eliminación con confirmación;
- validaciones: requeridos, longitudes mínima/máxima, valores permitidos;
- errores mostrados por campo, solo después de tocar el campo o intentar
  enviar (no antes: eso es hostil);
- estados de guardado (`saving`) con botón deshabilitado.

## 🚫 Qué NO entra todavía

- permisos ("¿quién puede borrar?") — apenas roles mock existen;
- soft-delete / papelera;
- optimistic UI (actualizar la tabla antes de que responda el server);
- validación asíncrona (¿título duplicado?) — ejercicio 🔴;
- creación en varios pasos — eso es el wizard de la Fase 6;
- modales de Bootstrap con jQuery — ejercicio 🟠, no contenido central.

---

## 🧠 Concepto 1: vuelidate en 5 minutos

Vuelidate es **validación basada en el modelo**, no en el template: describes
las reglas como un objeto y la librería te da un objeto reactivo `$v` con el
estado de validación de cada campo.

### Activarlo (una vez, en `main.js`)

```js
import Vuelidate from "vuelidate";
Vue.use(Vuelidate);
```

### Declarar reglas en el componente

```js
import { required, minLength, maxLength } from "vuelidate/lib/validators";

export default {
  data: function () {
    return {
      form: { title: "", description: "" }
    };
  },
  validations: {
    form: {
      title: { required: required, minLength: minLength(5), maxLength: maxLength(80) },
      description: { required: required, minLength: minLength(10) }
    }
  }
};
```

### Leer el estado en `this.$v`

| Propiedad | Qué dice |
|---|---|
| `$v.form.title.$invalid` | ¿el campo viola alguna regla **ahora**? |
| `$v.form.title.$dirty` | ¿el usuario ya lo tocó (o forzamos `$touch()`)? |
| `$v.form.title.$error` | `$invalid && $dirty` → **esto es lo que se muestra en UI** |
| `$v.form.title.required` | `false` si falla esa regla concreta |
| `$v.form.title.$params.minLength.min` | los parámetros de la regla (para el mensaje) |
| `$v.$invalid` | ¿el formulario completo es inválido? |
| `$v.$touch()` | marca todo como dirty (se usa al intentar enviar) |

**El patrón UX correcto** (grábatelo, es el 95% del uso real):

1. No muestres errores de entrada (`$error`, no `$invalid`).
2. Marca el campo como dirty al salir de él: `@blur="$v.form.title.$touch()"`.
3. Al enviar: `this.$v.$touch()`; si `this.$v.$invalid`, no envíes.

⚰️ Dato de época: esto es vuelidate **0.x** (la de Vue 2). Vuelidate 2.x es
para Vue 3 y cambia el API. En legacy verás también VeeValidate — otra
filosofía (validación en template con directivas) que conviene reconocer
(ejercicio 22).

## 🧠 Concepto 2: un formulario, dos modos

El error clásico legacy: `TicketCreateForm.vue` y `TicketEditForm.vue`
duplicados al 95%. Seis meses después alguien agrega un campo en uno y no en
el otro. 💀

La solución: **un** `TicketForm.vue` que:

- recibe por prop un ticket inicial (vacío = crear, con datos = editar);
- valida y emite `submit` con los datos limpios;
- no sabe si el padre hará POST o PATCH — *ese no es su problema*.

Las vistas `TicketCreateView` y `TicketEditView` quedan diminutas: cargar
datos si toca, escuchar el `submit`, llamar al servicio correcto, redirigir.

---

## 🧩 Mini repaso: los `.vue` de esta fase (lo nuevo respecto a la Fase 3)

El código de esta fase usa varias piezas de Vue que todavía no habíamos
explicado en detalle. Repaso exprés antes de leer el código:

### `created` vs `mounted` — ¿cuál hook y cuándo?

Ambos son hooks del ciclo de vida, pero corren en momentos distintos:

```
new Vue / componente creado
   ↓
beforeCreate
   ↓
created      ← ya existe this, data, props, computed. NO existe el DOM.
   ↓
(compila template, monta en el DOM)
   ↓
mounted      ← el componente ya está en la página. this.$el existe.
```

| Hook | Cuándo usarlo | En esta fase |
|---|---|---|
| `created` | inicializar **estado** a partir de props, suscripciones, cosas que no tocan el DOM | `TicketForm` clona `initialTicket` → `form` |
| `mounted` | cosas que necesitan el DOM o que disparan la carga inicial de datos | las vistas llaman `loadTicket()` |

¿Por qué `TicketForm` clona en `created` y no en `mounted`? Porque el clon no
necesita DOM, y hacerlo lo antes posible evita un render con el formulario
vacío antes de rellenarlo. Regla mental: **estado en `created`, DOM y HTTP en
`mounted`** (HTTP en `mounted` es la convención de la época; técnicamente en
`created` también funciona).

### Eventos nativos vs eventos personalizados (la parte que más confunde)

En esta fase conviven dos tipos de `@algo` que se ven iguales pero no lo son:

```vue
<!-- 1️⃣ EVENTO NATIVO del DOM: el <form> HTML emite "submit" -->
<form @submit.prevent="handleSubmit">

<!-- 2️⃣ EVENTO PERSONALIZADO: TicketForm (componente) emite "submit" con $emit -->
<ticket-form @submit="createTicket" @cancel="..." />
```

| | Nativo (en etiquetas HTML) | Personalizado (en componentes) |
|---|---|---|
| Quién lo emite | el navegador | tu código, con `this.$emit("nombre", payload)` |
| Modificadores `.prevent`, `.stop` | ✅ aplican | ❌ no aplican (no hay default que prevenir) |
| Payload | el objeto `Event` del DOM | lo que tú pongas en el `$emit` |
| Burbujea por el árbol | sí (comportamiento DOM) | **no**: solo lo oye el padre directo |

El flujo completo dentro de `TicketForm` encadena los dos:

```
click en el botón type="submit"
  → el <form> emite el evento NATIVO "submit"
  → .prevent cancela el envío clásico del navegador (recarga de página)
  → handleSubmit() valida con vuelidate
  → si pasa: this.$emit("submit", {...form})   ← evento PERSONALIZADO
  → el padre (la vista) lo recibe en @submit="createTicket"
```

Dos eventos llamados "submit", dos mundos. En legacy, confundirlos produce el
clásico "le puse `.prevent` a mi componente y no hace nada" — ahora sabes por
qué: `.prevent` no aplica a eventos personalizados.

📦 **El payload viaja solo:** `$emit("submit", datos)` hace que `datos` llegue
como primer argumento del handler. `@submit="createTicket"` equivale a
`@submit="createTicket($event)"` — por eso `createTicket(formData)` recibe el
objeto sin que escribamos nada extra.

### `v-model` y sus modificadores

`v-model` es azúcar sintáctica. En un input de texto:

```vue
<input v-model="form.title" />
<!-- equivale a: -->
<input :value="form.title" @input="form.title = $event.target.value" />
```

Los modificadores que usa esta fase:

| Modificador | Qué hace | Dónde lo usamos |
|---|---|---|
| `.trim` | recorta espacios al inicio/fin automáticamente | título, descripción, assignee |
| `.number` | convierte a número (útil para inputs numéricos) | ejercicios |
| `.lazy` | sincroniza en `change` en vez de cada `input` (menos reactividad, útil con validación costosa) | ejercicio 24 (validación async) |

Y en un `<select>`, `v-model` escucha `change` y sincroniza con el `value`
del `<option>` seleccionado — por eso el `<option value="">Seleccione...</option>`
deja el modelo en `""` y `required` lo atrapa. 👌

### Props: contrato, kebab-case y el patrón prop → copia local

```js
props: {
  initialTicket: { type: Object, default: null },
  saving: { type: Boolean, default: false },
  submitLabel: { type: String, default: "Guardar" }
}
```

- Declarar `type` y `default` convierte las props en **contrato documentado**:
  Vue avisa en consola si el padre manda cualquier cosa.
- En el template del padre se escriben en **kebab-case**:
  `submit-label="Crear ticket"`, `:initial-ticket="ticket"`. Vue traduce a
  camelCase solo. (HTML no distingue mayúsculas; error clásico de novato
  legacy: escribir `:initialTicket` en un template en archivo `.html` y que
  nunca llegue.)
- **El patrón prop → copia local**, la joya de la fase:

```
padre                          hijo (TicketForm)
ticket ──(prop initialTicket)──→ created: this.form = {...initialTicket}
                                 el usuario edita form (copia local)
       ←──($emit submit form)──  al enviar, devuelve la copia
padre decide: POST o PATCH
```

El hijo **nunca** toca la prop: edita su copia y la devuelve por evento. Así
el padre conserva el original intacto (útil para "cancelar", para detectar
cambios sin guardar — ejercicio 17 — y para no disparar reactividad fantasma
en el padre mientras se edita).

### `:class` con objeto — la clase condicional

```vue
:class="{ 'is-invalid': $v.form.title.$error }"
```

Se lee: "agrega la clase `is-invalid` cuando la expresión sea truthy". Se
combina sin conflicto con `class="form-control"` estático: Vue las fusiona.
Es el pegamento entre vuelidate ($error) y Bootstrap (`.is-invalid` +
`.invalid-feedback`).

---

## 💻 Código de la fase

### Estructura que se agrega

```
src/
  components/
    tickets/
      TicketForm.vue          ← nuevo (la estrella)
  views/
    TicketCreateView.vue      ← nuevo
    TicketEditView.vue        ← nuevo
```

### `components/tickets/TicketForm.vue`

```vue
<template>
  <form @submit.prevent="handleSubmit" novalidate>
    <!-- Título -->
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
        <span v-else-if="!$v.form.title.minLength">
          Mínimo {{ $v.form.title.$params.minLength.min }} caracteres.
        </span>
        <span v-else-if="!$v.form.title.maxLength">
          Máximo {{ $v.form.title.$params.maxLength.max }} caracteres.
        </span>
      </div>
    </div>

    <!-- Descripción -->
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
        <span v-if="!$v.form.description.required">La descripción es obligatoria.</span>
        <span v-else>Cuenta un poco más: mínimo 10 caracteres.</span>
      </div>
    </div>

    <div class="form-row">
      <!-- Prioridad -->
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
          Seleccione una prioridad válida.
        </div>
      </div>

      <!-- Asignado -->
      <div class="form-group col-md-6">
        <label for="assignee">Asignado a</label>
        <input
          id="assignee"
          v-model.trim="form.assignee"
          type="text"
          class="form-control"
          placeholder="(opcional)"
        />
      </div>
    </div>

    <div class="mt-3">
      <button type="submit" class="btn btn-primary" :disabled="saving">
        {{ saving ? "Guardando..." : submitLabel }}
      </button>
      <button type="button" class="btn btn-link" @click="$emit('cancel')">
        Cancelar
      </button>
    </div>
  </form>
</template>

<script>
import { required, minLength, maxLength } from "vuelidate/lib/validators";

// Validador custom: valor dentro de una lista permitida.
function oneOf(values) {
  return function (value) {
    return values.indexOf(value) !== -1;
  };
}

export default {
  name: "TicketForm",
  props: {
    // vacío para crear, con datos para editar
    initialTicket: { type: Object, default: null },
    saving: { type: Boolean, default: false },
    submitLabel: { type: String, default: "Guardar" }
  },
  data: function () {
    return {
      // copia local: NUNCA editamos la prop directamente
      form: {
        title: "",
        description: "",
        priority: "",
        assignee: ""
      }
    };
  },
  validations: {
    form: {
      title: { required: required, minLength: minLength(5), maxLength: maxLength(80) },
      description: { required: required, minLength: minLength(10) },
      priority: { required: required, oneOf: oneOf(["low", "medium", "high"]) }
    }
  },
  created: function () {
    if (this.initialTicket) {
      // clonado superficial suficiente para un objeto plano
      this.form = Object.assign({}, this.form, this.initialTicket);
    }
  },
  methods: {
    handleSubmit: function () {
      this.$v.$touch();
      if (this.$v.$invalid) {
        return; // los errores ya se pintan solos vía $error
      }
      this.$emit("submit", Object.assign({}, this.form));
    }
  }
};
</script>
```

Detalles con intención:

- `novalidate` en el `<form>`: apagamos la validación nativa del navegador
  para que mande vuelidate (si no, compiten y queda raro);
- `v-model.trim` recorta espacios gratis;
- la prop `initialTicket` se **clona** a `form` en `created` — mutar props es
  pecado (Fase 4) y aquí se ve la técnica para evitarlo;
- el validador custom `oneOf` muestra que vuelidate acepta cualquier función
  que devuelva boolean: no hay magia;
- `saving` viene por prop: el formulario muestra el estado, la vista lo
  controla. Coherente con "el formulario no sabe de HTTP".

### `views/TicketCreateView.vue`

```vue
<template>
  <section style="max-width: 640px;">
    <page-title title="Nuevo ticket" />

    <div v-if="error" class="alert alert-danger">{{ error }}</div>

    <ticket-form
      :saving="saving"
      submit-label="Crear ticket"
      @submit="createTicket"
      @cancel="$router.push('/tickets')"
    />
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import TicketForm from "../components/tickets/TicketForm.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketCreateView",
  components: { PageTitle, TicketForm },
  data: function () {
    return { saving: false, error: "" };
  },
  methods: {
    createTicket: function (formData) {
      var self = this;
      this.saving = true;
      this.error = "";

      var payload = Object.assign({}, formData, {
        status: "open", // todo ticket nace abierto: regla de negocio, no del form
        reporter: this.$store.getters["auth/currentUser"].username,
        createdAt: new Date().toISOString()
      });

      ticketService
        .createTicket(payload)
        .then(function (created) {
          self.$router.push("/tickets/" + created.id);
        })
        .catch(function () {
          self.error = "No se pudo crear el ticket. Intenta de nuevo.";
        })
        .finally(function () {
          self.saving = false;
        });
    }
  }
};
</script>
```

Ojo al `payload`: `status`, `reporter` y `createdAt` los pone **la vista**,
no el formulario. El usuario no elige que su ticket nazca "resuelto" 😄. En
un backend real esto lo impondría el servidor — aquí lo simulamos, y el
ejercicio 26 explora qué pasa cuando el cliente miente.

### `views/TicketEditView.vue`

```vue
<template>
  <section style="max-width: 640px;">
    <page-title :title="'Editar ticket #' + $route.params.id" />

    <div v-if="loading" class="spinner-border text-primary"></div>

    <div v-else-if="error" class="alert alert-danger">{{ error }}</div>

    <ticket-form
      v-else-if="ticket"
      :initial-ticket="ticket"
      :saving="saving"
      submit-label="Guardar cambios"
      @submit="updateTicket"
      @cancel="$router.push('/tickets/' + $route.params.id)"
    />
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import TicketForm from "../components/tickets/TicketForm.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketEditView",
  components: { PageTitle, TicketForm },
  data: function () {
    return { ticket: null, loading: false, saving: false, error: "" };
  },
  mounted: function () {
    this.loadTicket();
  },
  methods: {
    loadTicket: function () {
      var self = this;
      this.loading = true;

      ticketService
        .getTicketById(this.$route.params.id)
        .then(function (ticket) {
          self.ticket = ticket;
        })
        .catch(function () {
          self.error = "No se pudo cargar el ticket.";
        })
        .finally(function () {
          self.loading = false;
        });
    },
    updateTicket: function (formData) {
      var self = this;
      this.saving = true;
      this.error = "";

      ticketService
        .updateTicket(this.$route.params.id, formData)
        .then(function () {
          self.$router.push("/tickets/" + self.$route.params.id);
        })
        .catch(function () {
          self.error = "No se pudieron guardar los cambios.";
        })
        .finally(function () {
          self.saving = false;
        });
    }
  }
};
</script>
```

Misma forma, distinto verbo: la creación hace POST, la edición hace PATCH
(el `updateTicket` de la Fase 3). El formulario ni se enteró. ✅

### `router/index.js` — nuevas rutas (¡el orden importa!)

```js
// ...imports previos
import TicketCreateView from "../views/TicketCreateView.vue";
import TicketEditView from "../views/TicketEditView.vue";

// dentro de routes:
{ path: "/tickets", name: "tickets", component: TicketsView, meta: { requiresAuth: true } },

// ⚠️ /tickets/new ANTES que /tickets/:id — si no, "new" se interpreta
// como un :id (lo viste venir en el ejercicio 22 de la Fase 1 😉)
{ path: "/tickets/new", name: "ticket-create", component: TicketCreateView, meta: { requiresAuth: true } },
{ path: "/tickets/:id", name: "ticket-detail", component: TicketDetailView, meta: { requiresAuth: true } },
{ path: "/tickets/:id/edit", name: "ticket-edit", component: TicketEditView, meta: { requiresAuth: true } },
```

### Botones en el detalle + eliminación con confirmación

Agregar a `views/TicketDetailView.vue` (dentro del bloque `v-else-if="ticket"`):

```vue
<div class="mt-4">
  <router-link
    :to="'/tickets/' + ticket.id + '/edit'"
    class="btn btn-outline-primary mr-2"
  >
    ✏️ Editar
  </router-link>
  <button class="btn btn-outline-danger" :disabled="deleting" @click="removeTicket">
    {{ deleting ? "Eliminando..." : "🗑️ Eliminar" }}
  </button>
</div>
```

```js
// data: agregar deleting: false
// methods: agregar
removeTicket: function () {
  var self = this;

  var ok = window.confirm(
    "¿Eliminar el ticket #" + this.ticket.id + "? Esta acción no se puede deshacer."
  );
  if (!ok) return;

  this.deleting = true;

  ticketService
    .deleteTicket(this.ticket.id)
    .then(function () {
      self.$router.push("/tickets");
    })
    .catch(function () {
      self.error = "No se pudo eliminar el ticket.";
      self.deleting = false;
    });
}
```

¿`window.confirm`? Sí: feo pero honesto, y **muy** de la época para acciones
internas. El modal Bootstrap bonito es el ejercicio 18 — y ahí por fin
trabajan el jQuery y popper.js que instalamos en la Fase 0.

### Botón "Nuevo ticket" en el dashboard

En `TicketsView.vue`, junto al título:

```vue
<router-link to="/tickets/new" class="btn btn-primary mb-3">
  ➕ Nuevo ticket
</router-link>
```

---

## 🔄 Los tres flujos, paso a paso

El resumen general es siempre el mismo — capturar → validar → emitir →
servicio → redirigir — pero vale la pena seguir cada operación evento por
evento, porque ahí es donde se entiende (y se debuggea) un CRUD legacy.

### ➕ Creación, evento por evento

```
1. usuario navega a /tickets/new
   └─ el router monta TicketCreateView → monta TicketForm
      └─ created de TicketForm: initialTicket es null → form queda vacío

2. usuario escribe en el título y sale del campo
   └─ evento nativo "input" en cada tecla → v-model.trim actualiza form.title
   └─ evento nativo "blur" al salir → $v.form.title.$touch() → $dirty = true
      └─ si viola reglas: $error = true → :class pinta is-invalid
         → el <div class="invalid-feedback"> se hace visible

3. usuario hace clic en "Crear ticket" (type="submit")
   └─ el <form> emite el evento NATIVO "submit"
      └─ .prevent evita la recarga de página
      └─ handleSubmit():
         a. this.$v.$touch()        → TODOS los campos quedan $dirty
         b. if ($v.$invalid) return → los errores ya se pintan solos; fin
         c. this.$emit("submit", {...form})  → evento PERSONALIZADO hacia arriba

4. TicketCreateView recibe @submit="createTicket"
   └─ createTicket(formData):
      a. saving = true            → el botón (vía prop) muestra "Guardando..." y se deshabilita
      b. arma payload: formData + status:"open" + reporter + createdAt
      c. ticketService.createTicket(payload) → POST /tickets
         └─ el interceptor (Fase 2) agrega Authorization: Bearer ...

5a. ÉXITO (201): json-server devuelve el ticket CON id asignado
    └─ .then(created) → $router.push("/tickets/" + created.id)
       └─ el guard verifica sesión → monta TicketDetailView → mounted → GET del ticket

5b. ERROR (red caída, 500...):
    └─ .catch → error = "No se pudo crear..." → alerta roja en la vista
       └─ el formulario SIGUE MONTADO con todo lo escrito: nada se pierde

6. siempre: .finally → saving = false → botón habilitado de nuevo
```

Detalles que importan al debuggear:

- el **id lo asigna json-server** (como haría un backend real): por eso
  redirigimos con `created.id` de la respuesta, no con algo local;
- entre el paso 4 y el 5 el botón está deshabilitado — quita eso y tienes la
  condición de carrera del doble submit (ejercicio 8);
- si en el paso 3b "no pasa nada" al hacer clic, el 99% de las veces es que
  faltó `$touch()` o que el form está inválido sin errores visibles.

### ✏️ Edición: igual, pero con carga previa y clon

```
1. usuario hace clic en "✏️ Editar" en el detalle
   └─ router-link navega a /tickets/:id/edit → monta TicketEditView
      └─ ticket = null → el v-else-if="ticket" NO monta el formulario todavía

2. mounted de la vista → loadTicket()
   └─ GET /tickets/:id → .then → this.ticket = respuesta
      └─ AHORA la reactividad monta <ticket-form :initial-ticket="ticket">
         └─ created de TicketForm: clona la prop → form = {...initialTicket}

3. usuario edita → modifica form (la COPIA), nunca la prop
   └─ this.ticket en la vista sigue intacto (por eso "Cancelar" no deja rastro)

4. submit → misma cadena que en creación (nativo → prevent → $touch → $emit)

5. TicketEditView recibe @submit="updateTicket"
   └─ PATCH /tickets/:id con formData (parcial: solo lo que el form maneja)
   └─ éxito → redirigir al detalle │ error → alerta, formulario sigue con los cambios
```

El matiz clave está en el paso 1–2: el formulario **no se monta hasta tener
datos** (`v-else-if="ticket"`). Si lo montaras vacío y "rellenaras después",
el `created` ya habría corrido con `initialTicket` null y el clon no
ocurriría. Este es un bug real y frecuente en legacy — la alternativa de la
época era un `watch` sobre la prop, más frágil. Montar tarde es más simple.

También fíjate en la simetría: **crear = POST con payload completo armado por
la vista; editar = PATCH parcial con lo que el formulario maneja**. Campos
como `reporter` o `createdAt` no viajan en el PATCH y por eso no se pisan.

### 🗑️ Eliminación: corta pero con dos salidas

```
1. clic en "🗑️ Eliminar" (evento nativo "click")
   └─ removeTicket():
      a. window.confirm(mensaje con el id)  ← SÍNCRONO: bloquea hasta responder
         └─ Cancelar → return: no pasó nada, cero requests
      b. deleting = true → botón muestra "Eliminando..." y se deshabilita

2. DELETE /tickets/:id

3a. ÉXITO → $router.push("/tickets")
    └─ NO reseteamos deleting: el componente se destruye al navegar (beforeDestroy)
       y su estado muere con él

3b. ERROR → error = mensaje + deleting = false
    └─ aquí SÍ hay que resetear deleting: seguimos en la vista y el usuario
       debe poder reintentar
```

Esa asimetría del paso 3 (resetear `deleting` solo en el error) es sutil pero
deliberada: es el tipo de detalle que en una revisión de código legacy
distingue a quien entiende el ciclo de vida de quien copia patrones. En el
camino feliz, resetearlo causaría un parpadeo del botón justo antes de
navegar; en el camino triste, no resetearlo deja el botón muerto para siempre.

### 📌 El resumen para la nevera

```
usuario escribe → vuelidate valida ($touch al blur / al enviar)
      → form emite submit con datos limpios (evento personalizado)
      → la vista arma el payload (reglas de negocio)
      → servicio hace POST/PATCH/DELETE (token vía interceptor)
      → éxito: redirigir │ error: mensaje + no perder lo escrito
```

---

## ⚠️ Errores comunes

- duplicar el formulario para crear y editar (el pecado capital de la fase);
- mostrar errores con `$invalid` en vez de `$error` → formulario en rojo
  antes de que el usuario escriba una letra;
- olvidar `this.$v.$touch()` en el submit → el form inválido "no hace nada"
  y nadie sabe por qué;
- mutar `initialTicket` directamente en vez de clonarlo a `form`;
- dejar que el formulario ponga `status`, `reporter` o `createdAt` (reglas de
  negocio en el lugar equivocado);
- botón de guardar sin `disabled` durante el request → doble submit → tickets
  duplicados (pruébalo: es aleccionador);
- eliminar sin confirmación, o confirmar con un mensaje genérico que no dice
  **qué** se va a borrar;
- olvidar `novalidate` y pelear contra los tooltips nativos del navegador.

---

## 🧪 Ejercicios (26)

**🟢 Fácil (1–8)**

1. Agrega un contador "N/80" bajo el campo título que muestre los caracteres
   usados (rojo si se pasa).
2. Haz obligatorio el campo `assignee` y agrega su mensaje de error.
3. Cambia el mínimo de la descripción a 20 caracteres y verifica que el
   mensaje se actualiza solo (gracias a `$params`).
4. Agrega un botón "Limpiar" al formulario que resetee `form` **y**
   `this.$v.$reset()`. ¿Qué pasa si olvidas el `$reset()`?
5. Después de crear un ticket, muestra `?created=1` en la URL del detalle y
   una alerta verde "Ticket creado ✅" si ese query param existe.
6. Deshabilita el botón de submit cuando `$v.$invalid` sea true. Luego
   revierte y deja solo el patrón `$touch` al enviar. ¿Cuál UX prefieres y
   por qué? (No hay respuesta única.)
7. Cancela desde el formulario de edición y verifica que vuelves al detalle,
   no al listado.
8. Prueba el doble submit: quita el `:disabled="saving"`, dale clic rápido
   dos veces a "Crear" y mira `db.json`. Restaura el disabled y documenta
   en un comentario qué pasó.

**🟡 Intermedio (9–17)**

9. Convierte el campo `assignee` en un `<select>` poblado desde
   `GET /users` con un `userService.js` nuevo (solo agentes: `?role=agent`).
10. Agrega el campo `status` al formulario **solo en modo edición** (prop
    `mode` o derivado de si hay `initialTicket`), con validador `oneOf` de los
    4 estados.
11. Extrae los mensajes de error a un componente `FieldError.vue` que reciba
    el objeto `$v.form.campo` y pinte el mensaje que toca. Úsalo en los 3
    campos validados.
12. Agrega un validador custom `noSoloMayusculas` para el título (nadie quiere
    tickets que GRITAN). Rechaza títulos 100% en mayúsculas de más de 10
    caracteres.
13. En el confirm de borrado, incluye el **título** del ticket, no solo el id.
14. Después de eliminar, muestra en el listado una alerta "Ticket #X
    eliminado" (pista: query param o un flash message simple en el store).
15. Agrega "duplicar ticket": botón en el detalle que navegue a
    `/tickets/new?from=ID` y el create view precargue el formulario con los
    datos de ese ticket (título con prefijo "Copia de ...").
16. Valida en el edit view el caso "el ticket no existe" (404) mostrando error
    y un link de vuelta al listado.
17. Agrega `beforeRouteLeave` al create view: si el formulario tiene cambios
    sin guardar, pregunta con `confirm` antes de abandonar. Pista: compara
    `form` contra su estado inicial con `lodash.isEqual`.

**🟠 Difícil (18–23)**

18. Reemplaza el `window.confirm` de borrado por un **modal Bootstrap 4 real**
    (con jQuery: `$('#confirmModal').modal('show')`). Envuélvelo en un
    componente `ConfirmModal.vue` que emita `confirm`/`cancel`. Documenta en
    un comentario la incomodidad de mezclar jQuery con Vue — es el dolor
    legacy más auténtico del curso.
19. Cambia el estado del ticket desde el **detalle** con botones de transición
    válida (open→in_progress→resolved→closed, y reopen desde
    resolved/closed→open). Las transiciones inválidas ni se muestran. Usa
    PATCH solo del campo `status`.
20. Implementa un mini flash-message global: módulo Vuex `ui` con
    `message`/`type`, componente `FlashMessage.vue` en `App.vue` que se
    auto-oculta a los 4 segundos. Reemplaza los avisos de los ejercicios 5 y 14.
21. Crea `withSaving`, un helper/mixin que encapsule el patrón
    `saving=true → promesa → finally saving=false` y refactoriza las tres
    vistas CRUD para usarlo. Compara líneas antes/después.
22. Investiga VeeValidate 3 (la otra librería de la época): reescribe SOLO el
    campo título con su enfoque de template y escribe 5 líneas comparando
    filosofías (modelo vs template). No lo integres al proyecto: es
    reconocimiento de fauna legacy.
23. Agrega validación de negocio en el submit del edit: un ticket `closed` no
    se puede editar (json-server no lo impide, hazlo en la vista). Muestra el
    formulario en modo solo-lectura con un aviso.

**🔴 Muy difícil (24–26)**

24. Validación **asíncrona** de título duplicado: al blur del título, consulta
    `GET /tickets?title=EXACTO` y marca error si existe otro con el mismo
    título (excluyendo el propio en modo edición). Vuelidate 0.x soporta
    validadores que devuelven Promise — investiga cómo, y agrega un spinner
    pequeño mientras valida. Cuidado con el debounce.
25. Manejo de conflicto de edición (versión pobre del optimistic locking):
    guarda `updatedAt` en cada PATCH; antes de guardar, vuelve a pedir el
    ticket y si el `updatedAt` del servidor cambió desde que cargaste el
    formulario, avisa "Alguien modificó este ticket" y ofrece recargar o
    sobrescribir. Simúlalo editando `db.json` a mano en paralelo.
26. Seguridad de juguete: con el interceptor/middleware del ejercicio 24 de la
    Fase 3, haz que json-server rechace con 403 cualquier POST donde
    `reporter` ≠ el usuario del token mock (tendrás que codificar el username
    en el token falso del ejercicio 25 de la Fase 2). Escribe la moraleja en
    `SECURITY-NOTES.md`: *por qué el payload que arma el cliente jamás es
    confiable*.

---

## 📚 Referencias

**Documentación oficial**

- Vuelidate 0.x (¡la de Vue 2!): https://vuelidate.js.org/
- Vuelidate — validadores incluidos: https://vuelidate.js.org/#sub-builtin-validators
- Vue 2 — Diagrama del ciclo de vida (created, mounted, beforeDestroy):
  https://v2.vuejs.org/v2/guide/instance.html#Lifecycle-Diagram
- Vue 2 — Event Handling (eventos nativos y modificadores):
  https://v2.vuejs.org/v2/guide/events.html
- Vue 2 — Custom Events ($emit y su payload):
  https://v2.vuejs.org/v2/guide/components-custom-events.html
- Vue 2 — Form Input Bindings (v-model y modificadores):
  https://v2.vuejs.org/v2/guide/forms.html
- Vue 2 — Props (validación de props): https://v2.vuejs.org/v2/guide/components-props.html
- Vue Router 3 — In-Component Guards (beforeRouteLeave):
  https://v3.router.vuejs.org/guide/advanced/navigation-guards.html#in-component-guards
- Bootstrap 4.6 — Forms y validación visual:
  https://getbootstrap.com/docs/4.6/components/forms/#validation
- Bootstrap 4.6 — Modal: https://getbootstrap.com/docs/4.6/components/modal/

**Video / apoyo**

- Form validation con Vuelidate: https://www.youtube.com/watch?v=WP4-WgHqbPQ
- Net Ninja — Vue JS 2: episodios de formularios (playlist en YouTube)

**Orden de lectura sugerido:** Form Input Bindings → vuelidate (getting
started + builtin validators) → volver al código → Bootstrap validation solo
para las clases CSS.

---

## 🚀 Cierre

El Mini Jira ya es un CRUD completo: nace, se edita y muere un ticket sin
tocar `db.json` a mano. Y las piezas quedaron donde deben:

- **`TicketForm`** captura y valida (un solo formulario, dos modos),
- **las vistas** orquestan y ponen las reglas de negocio,
- **el servicio** habla HTTP,
- **vuelidate** valida declarativamente con el patrón `$touch`/`$error`.

La señal de que quedó bien:

> "agregar un campo al ticket significa tocar el formulario UNA vez,
> y crear/editar lo heredan gratis".

**Siguiente parada:** 🪜 Fase 6 — Wizard mínimo: la creación de tickets crece
a 3 pasos (datos → clasificación → confirmación) y aparece la pregunta
incómoda: ¿el estado del wizard vive en el componente o en el store?
