# 🏥 Fase 05 — Pacientes

> Tutorial Angular 8 — Laboratorio clínico · Fase 5 de 14 · **6 horas**
> Depende de: Fase 1 — Estructura base + NgRx · Fase 2 — Internacionalización · Fase 4 — Mock API + caos
> Habilita: Fase 6 — Órdenes · Fases 7-12
> Apéndices de apoyo: [A01 (Angular Material)](./a01-material.md) · [A02 (Bootstrap 4 + Sass)](./a02-bootstrap-sass.md) · [A06 (NgRx 8)](./a06-ngrx.md) · [Incidentes asociados](./cuaderno-incidentes.md): 09, 10

---

## 🎯 1. Propósito

Hasta acá el store solo supo **leer**. La lista de pacientes se carga, falla, reintenta y se vuelve a cargar, pero nadie escribió nunca un registro. Esta fase cierra el círculo: alta, edición y baja de pacientes pasando por el store, con formularios reactivos de verdad —los densos, los que tienen ocho campos, un validador asíncrono y un mensaje de error distinto por regla— y con una tabla de Material que filtra, ordena y pagina.

Lo que te importa a ti, que vas a *mantener* esto y no a construirlo, es que **el primer CRUD de un sistema fija el patrón de todos los demás**. Cuando abras la pantalla de resultados en la Fase 8 y la encuentres con la misma forma —componente gordo, validación adentro, recarga completa después de guardar— no vas a estar viendo una coincidencia: vas a estar viendo esta fase copiada y pegada seis veces. Entender bien el molde acá te ahorra entenderlo mal seis veces después.

Y hay una segunda razón, menos obvia. Un CRUD es donde el estado y la pantalla se desincronizan por primera vez. Mientras solo leías, lo que veías era lo que había. Desde que escribes, existe un momento —corto, pero existe— en el que el formulario dice una cosa, el store dice otra, y el mock dice una tercera. La mitad de los tickets que vas a recibir en tu vida nacen en ese momento.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `npm run seed && npm run mock` levanta el mock con ~25 pacientes y ~40 órdenes, y `/patients` muestra una tabla Material paginada de diez en diez.
- [ ] Escribes tres letras en el filtro y la tabla se reduce sin ir al servidor; lo confirmas porque la pestaña Network no registra ninguna petición nueva.
- [ ] Haces clic en **Nuevo**, llenas el formulario, guardas, y en Redux DevTools ves entrar `[Patients] Create Patient` → `[Patients] Create Patient Success` → `[Patients] Load Patients`, en ese orden.
- [ ] Escribes un `documentId` que ya existe y el campo se marca en rojo **después** de que el validador asíncrono responde; con `CHAOS=latency=3000` ves el spinner del campo durante tres segundos y puedes guardar igual si te apuras (ese es el bug del ejercicio 26).
- [ ] Das de baja a un paciente sin órdenes y desaparece de la tabla; intentas con uno que tiene órdenes y aparece un `MatSnackBar` traducido explicando por qué no se puede.
- [ ] En `db.json` el paciente dado de baja **sigue estando**, con `active: false`. Puedes abrirlo y verlo.
- [ ] Ordenas la columna de fecha de nacimiento y puedes explicar por qué el orden es correcto o incorrecto según el tipo del dato que llega del mock.

---

## 🚫 3. Qué NO entra todavía

- Validación cruzada entre campos —que la fecha de una cosa sea posterior a la de otra, que un valor solo sea válido según el estado de otro— → **Fase 8**, donde los rangos versionados la vuelven inevitable.
- Permisos por rol sobre los botones de acción. El `AuthService` de la Fase 3 sabe quién eres, pero nadie le pregunta → fuera del alcance del curso; se anota como pendiente en el cierre.
- Paginación, ordenamiento y filtrado **del lado del servidor**. Los difirió la Fase 4 hasta acá y acá se declaran deuda 💸, no se implementan.
- `MatTableDataSource` con `connect()` / `disconnect()` propios. El `dataSource` de esta fase es un array plano que se reasigna a mano → se explica el porqué en §5.8 y la alternativa correcta queda como ejercicio 🔥.
- Edición en línea dentro de la tabla. Todo pasa por diálogo → fuera de alcance.
- `trackBy` en las filas. Se nombra en §6 como causa de re-render y se mide en la **Fase 10**; acá no se implementa.
- **Todo lo de órdenes** → **Fase 7**, que aplica este mismo molde y añade lo que no encaja en él: el `FormArray` de los exámenes, el cruce contra el slice de pacientes, y un `status` que parece una máquina de estados sin serlo.

---

## 🧠 4. Concepto mínimo

### El problema antes que la herramienta

Un formulario de alta de paciente tiene ocho campos, tres de ellos obligatorios, uno con formato específico, uno que depende de una consulta al servidor y uno que es una fecha. Con `ngModel` —que es lo que aprendiste en la Fase 0— cada campo es una propiedad del componente y cada regla es un `*ngIf` en la plantilla comparando contra algo. Con ocho campos eso son ocho propiedades, unos quince `*ngIf`, y ninguna forma de preguntar "¿el formulario entero está válido?" que no sea escribir esa pregunta a mano.

El problema real no es la verbosidad. Es que **el estado del formulario está repartido**: parte en propiedades del componente, parte en el DOM, parte en la cabeza de quien lo escribió. Cuando llegue el ticket que dice "el botón de guardar está habilitado y no debería", no vas a tener un solo lugar donde mirar.

Los formularios reactivos resuelven eso moviendo el formulario entero a un objeto de TypeScript. `FormGroup` es el formulario, `FormControl` es cada campo, y ambos son observables: tienen valor, tienen estado de validez, tienen historial de si el usuario los tocó o no. La plantilla deja de ser la fuente de verdad y pasa a ser una proyección. Cuando el ticket llegue, pones un `console.log(this.patientForm)` y ves el formulario completo, campo por campo, con sus errores nombrados.

**Si vienes de backend**, un `FormGroup` es lo más parecido que hay en el navegador a un DTO con anotaciones de validación: un objeto que conoce su propia forma y sabe decir si cumple las reglas. La analogía funciona bien para la estructura y **se rompe en el ciclo de vida**: tu DTO se instancia, se valida una vez y se descarta; un `FormGroup` vive mientras la pantalla esté abierta y se revalida en cada tecla. Todo lo que pongas dentro de un validador se ejecuta cientos de veces por minuto. Un validador que hace una consulta —que es exactamente lo que vamos a escribir— no es un método de validación, es una fuente de tráfico.

### Los tres estados que confunde todo el mundo

Un `FormControl` tiene tres pares de banderas que se leen mal constantemente:

`valid` / `invalid` responde si el valor cumple las reglas. `touched` / `untouched` responde si el usuario alguna vez le hizo foco y lo perdió. `dirty` / `pristine` responde si el valor cambió alguna vez.

Un campo obligatorio recién montado es **inválido y prístino a la vez**: no cumple, pero el usuario no ha hecho nada mal todavía. Por eso los mensajes de error se muestran contra `touched`, no contra `invalid`. Si los muestras contra `invalid`, el formulario se abre en rojo y el usuario aprende a ignorar el rojo. Ese es un bug de producto, no de código, y es carísimo de revertir.

Hay un cuarto estado que casi nadie usa y que esta fase sí necesita: `pending`. Un control con validación asíncrona está `pending` mientras la consulta viaja. Y acá viene lo importante: **`pending` no es `invalid`**. Un formulario con un control pendiente reporta `form.valid === false`, pero también `form.invalid === false`. Si tu botón de guardar se deshabilita con `[disabled]="patientForm.invalid"`, queda **habilitado** durante toda la ventana de la consulta. Eso es el ejercicio 26 y es un bug real que vas a encontrar en producción en algún momento de tu carrera.

### Escribir en el store

Leer del store es unidireccional y limpio. Escribir introduce una pregunta que no tenía la Fase 1: **después de un POST exitoso, ¿qué hace el estado?**

Hay dos respuestas. La correcta en teoría es **insertar en el estado el registro que devolvió el servidor**: una acción `Create Patient Success` con el paciente adentro, y un reducer que hace `items: [...state.items, action.patient]`. Es una petición, es instantáneo, y el estado local queda idéntico al remoto.

La que hace LabCore —y la que vamos a escribir— es **recargar la lista entera**: el effect de creación, después del éxito, despacha `loadPatients()` otra vez. Son dos peticiones donde alcanzaba una, y la pantalla parpadea. A cambio, el estado nunca se desincroniza del servidor por un `id` mal calculado, por un campo que el backend rellenó y el cliente no sabía, o por otro usuario que insertó algo entremedio. Es una decisión de cobardía deliberada, y en un sistema con varios operadores escribiendo sobre las mismas tablas, la cobardía tiene su mérito.

Lo que necesitas retener no es cuál es mejor, sino **cómo se ve cada una en Redux DevTools**. La primera muestra dos acciones y un cambio de estado. La segunda muestra cuatro acciones y dos cambios. Cuando reconstruyas un incidente a partir del log, saber cuál de los dos patrones usa la pantalla te dice si lo que estás viendo es normal o es el bug.

### Nota de época

Angular 8 ya tenía `FormBuilder` y validadores asíncronos tal como los vas a escribir; en eso la versión no te limita. Lo que no tenía es el tipado de formularios que llegó en Angular 14: acá `patientForm.get('documentId').value` es `any`, siempre, y escribir `patientForm.get('documentID')` con la D mayúscula devuelve `null` sin que nadie te avise hasta que explote en tiempo de ejecución. Esa cadena mágica es la fuente de bugs número uno de los formularios reactivos de la época, y por eso §6 le dedica un apartado entero.

---

## 💻 5. Código mínimo con comentarios

### 5.1 `seed.js` — datos suficientes para que paginar signifique algo

El `db.json` de la Fase 4 tiene tres pacientes. Con tres pacientes, un paginador es un adorno y un filtro es un chiste: cualquier bug de paginación se esconde porque nunca hay una segunda página. Antes de escribir una línea de Angular, el semillero crece.

No editamos el `db.json` a mano —ese archivo es el que fijó la Fase 4 y sigue siendo la referencia del modelo—. Lo **generamos**, que además es honesto: los datos de demo de cualquier sistema se generan.

```javascript
// seed.js
// Genera un db.json grande a partir del modelo fijado en la Fase 4.
// Se corre a mano cuando hace falta un semillero nuevo, no en cada arranque:
// si lo corres, pierdes lo que hayas creado desde la interfaz.
const fs = require('fs');
const path = require('path');

var FIRST_NAMES = ['Marcela', 'Julian', 'Deisy', 'Andres', 'Paola', 'Ricardo', 'Luz', 'Camilo'];
var LAST_NAMES = ['Rios', 'Prada', 'Cardenas', 'Beltran', 'Osorio', 'Quintero', 'Salazar'];
var TEST_CODES = ['CBC', 'GLU', 'TSH', 'LIP', 'CREA'];
// Los estados del flujo canónico de una orden, tal como los fija el ALCANCE.
// Editado retroactivamente desde la Fase 8 (normalización del flujo) y desde
// la Fase 9 (alta de "delivered"). La versión original sembraba valores sueltos
// (created/processing/reported) que no cruzaban con la máquina de estados de la
// muestra ni con el empuje muestra->orden de la Fase 8. Se normaliza al flujo
// único, con el precedente de la Fase 3.
// "delivered" figura en el arreglo para que el estado EXISTA en la máquina y en
// el MatSelect que la Fase 6 construye, pero NO se siembra ninguna orden ya
// entregada: a "delivered" se
// llega solo entregando el informe en la Fase 9, igual que a "discarded" en
// muestras se llegaba solo descartando en la Fase 7. Sembrar una orden
// delivered haría aparecer el estado final sin la historia que lo produjo, y
// escondería el cruce results->orders que la Fase 9 construye.
var ORDER_STATUSES = ['pending', 'in_process', 'partial_results', 'complete', 'delivered', 'expired'];

// Estados que una orden PUEDE tener recién sembrada. "delivered" y "expired"
// quedan fuera: son terminales a los que se llega por una acción (entregar) o
// por el paso del tiempo (vencer), no por generación. Sembrarlos sin historia
// mentiría sobre como llegaron ahí.
var SEEDABLE_ORDER_STATUSES = ['pending', 'in_process', 'partial_results', 'complete'];

// Generador pseudoaleatorio con semilla fija. Sin esto, cada corrida produce
// datos distintos y un bug reproducible deja de serlo. La semilla es parte
// del contrato del semillero, no un detalle.
var seed = 20190902;
function random() {
  seed = (seed * 9301 + 49297) % 233280;
  return seed / 233280;
}

function pick(list) {
  return list[Math.floor(random() * list.length)];
}

function pad(value, size) {
  var text = String(value);
  while (text.length < size) { text = '0' + text; }
  return text;
}

function buildPatients(count) {
  var patients = [];
  for (var i = 1; i <= count; i++) {
    patients.push({
      id: i,
      documentId: 'CC-10' + pad(Math.floor(random() * 99999999), 8),
      fullName: pick(FIRST_NAMES) + ' ' + pick(LAST_NAMES),
      // Fecha de nacimiento como string ISO corto, igual que la Fase 4.
      // Que llegue como string y no como Date es la causa del ejercicio 18.
      birthDate: (1950 + Math.floor(random() * 55)) + '-' +
                 pad(1 + Math.floor(random() * 12), 2) + '-' +
                 pad(1 + Math.floor(random() * 28), 2),
      // Uno de cada seis sin correo: caso borde heredado de la Fase 4.
      email: random() > 0.17 ? 'paciente' + i + '@example.com' : null,
      // Campo nuevo de esta fase. Ver 5.2.
      active: true
    });
  }
  return patients;
}

function buildOrders(patients, count) {
  var orders = [];
  for (var i = 0; i < count; i++) {
    var patient = pick(patients);
    var createdAt = '2019-' + pad(1 + Math.floor(random() * 9), 2) + '-' +
                    pad(1 + Math.floor(random() * 28), 2) + 'T08:15:00-05:00';
    orders.push({
      id: 101 + i,
      patientId: patient.id,
      // Sorteo acotado: nunca nace una orden ya "delivered" ni "expired".
      // Ver SEEDABLE_ORDER_STATUSES arriba.
      status: pick(SEEDABLE_ORDER_STATUSES),
      createdAt: createdAt,
      dueAt: createdAt,          // Simplificación deliberada; la Fase 8 la corrige.
      testCodes: [pick(TEST_CODES)],
      active: true
    });
  }
  return orders;
}

var patients = buildPatients(25);
var orders = buildOrders(patients, 40);

// Las colecciones que esta fase no toca se conservan tal como las dejó la
// Fase 4: se leen del archivo actual y se vuelven a escribir sin cambios.
var current = JSON.parse(fs.readFileSync(path.join(__dirname, 'db.json'), 'utf8'));

var next = {
  patients: patients,
  orders: orders,
  samples: current.samples,
  results: current.results,
  referenceRanges: current.referenceRanges
};

fs.writeFileSync(path.join(__dirname, 'db.json'), JSON.stringify(next, null, 2));
console.log('[seed] ' + patients.length + ' pacientes, ' + orders.length + ' ordenes');
```

Y el script en `package.json`, junto a los que fijó la Fase 4:

```json
"scripts": {
  "seed": "node seed.js"
}
```

**Detalles con intención**

- El generador tiene semilla fija a propósito. Un semillero aleatorio de verdad hace que "reproduce el bug en tu máquina" sea una mentira. La reproducibilidad de los datos es tan importante como la del código.
- Los pacientes 1 a 3 del `db.json` original desaparecen y son reemplazados. Si tenías datos que te importaban desde la Fase 4, cópialos antes: el script pisa sin preguntar. Eso también es fidelidad a LabCore, donde el script de semillero de UAT ha borrado más de un caso de prueba cuidadosamente construido.

### 5.2 El campo `active` y la baja lógica

La baja de un paciente **no borra el registro**. Le pone `active: false` y la aplicación deja de mostrarlo. El registro sigue ahí, con su historia y sus órdenes colgando de él.

Esto no es una decisión estética. En un sistema donde cada registro está referenciado por otros —una orden apunta a un paciente, una muestra apunta a una orden, un resultado apunta a una muestra— un `DELETE` real deja huérfanos a los hijos, y un sistema con trazabilidad regulada no puede permitirse que una orden apunte a un paciente que ya no existe. Además, "¿quién dio de baja este registro y cuándo?" es una pregunta que alguien va a hacer, y no se puede responder sobre algo que se borró.

El precio también es real y conviene decirlo: **cada consulta del sistema tiene que acordarse de filtrar por `active`**, para siempre. La que se olvide muestra registros dados de baja, y ese bug es silencioso hasta que alguien lo nota meses después. Es exactamente el incidente 09 de esta fase.

Para el fondo del asunto —baja lógica frente a baja física, índices parciales, la variante con tabla de histórico— la referencia está en §8; acá solo lo aplicamos.

El modelo queda así, y esto es lo que heredan las Fases 7 a 11:

```json
{
  "id": 1,
  "documentId": "CC-1032456789",
  "fullName": "Marcela Rios",
  "birthDate": "1984-03-12",
  "email": "marcela.rios@example.com",
  "active": true
}
```

### 5.3 `SharedModule` — lo que hay que importar antes de nada

La Fase 1 dejó el `SharedModule` con `FormsModule` (template-driven, de la Fase 0) y tres módulos de Material. Esta fase le agrega lo suyo.

```typescript
// src/app/shared/shared.module.ts
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSortModule } from '@angular/material/sort';
import { MatDialogModule } from '@angular/material/dialog';
import { MatSnackBarModule } from '@angular/material/snack-bar';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatIconModule } from '@angular/material/icon';
// MatNativeDateModule no es un módulo de UI: es el adaptador de fechas.
// Sin el, el datepicker compila y explota al abrirse con un error que
// habla de DateAdapter y no de fechas. Ver sección 6.
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';

import { TranslateModule } from '@ngx-translate/core';

var SHARED_MODULES = [
  CommonModule,
  FormsModule,
  ReactiveFormsModule,
  TranslateModule,
  MatButtonModule,
  MatCardModule,
  MatProgressSpinnerModule,
  MatTableModule,
  MatPaginatorModule,
  MatSortModule,
  MatDialogModule,
  MatSnackBarModule,
  MatFormFieldModule,
  MatInputModule,
  // MatSelectModule no lo usa ninguna pantalla de esta fase: entra acá porque
  // el desplegable de estado de la Fase 6 lo va a necesitar y el SharedModule
  // se importa una sola vez. Es la clase de import que en LabCore nadie sabe
  // ya quién metió.
  MatSelectModule,
  MatIconModule,
  MatDatepickerModule,
  MatNativeDateModule
];

@NgModule({
  imports: SHARED_MODULES,
  exports: SHARED_MODULES
})
export class SharedModule { }
```

**Detalles con intención**

- El arreglo `SHARED_MODULES` se usa en `imports` y en `exports` a la vez. No es magia: un módulo compartido tiene que importar lo que usa y exportar lo que presta, y en este caso son lo mismo. Escribirlo dos veces es la forma segura de que un día se desincronicen.
- `MatTableModule` viene de `@angular/cdk` por debajo. Si el `package.json` tiene `@angular/cdk` en una versión distinta a `@angular/material` (ambas deberían ser **8.2.3**), el `ng serve` falla con un error de tipos que no menciona ninguna de las dos. Ejercicio 21.
- `TranslateModule` acá cierra el bucle que abrió la Fase 2: se declaró que su lugar natural eran los `exports` del `SharedModule` en vez de repetirlo en cada feature module. Este es el momento.

### 5.4 `patients.actions.ts` — el vocabulario completo

La Fase 1 dejó `loadPatients`, `loadPatientsSuccess`, `loadPatientsFailure` y `selectPatient`. Se conservan tal cual —nueve fases copian ese trío— y se agregan los verbos de escritura: **create, update, upsert, delete, select**.

```typescript
// src/app/patients/store/patients.actions.ts
import { createAction, props } from '@ngrx/store';

// --- Lectura (Fase 1, sin cambios) ---
export const loadPatients = createAction('[Patients] Load Patients');

export const loadPatientsSuccess = createAction(
  '[Patients] Load Patients Success',
  props<{ patients: any[] }>()
);

export const loadPatientsFailure = createAction(
  '[Patients] Load Patients Failure',
  props<{ error: any }>()
);

export const selectPatient = createAction(
  '[Patients] Select Patient',
  props<{ patientId: number }>()
);

// --- Escritura (Fase 5) ---

// El payload es "any" y no "Patient" porque no hay interfaz Patient. TS-0.
// El precio: nada impide despachar createPatient({ patient: 42 }).
export const createPatient = createAction(
  '[Patients] Create Patient',
  props<{ patient: any }>()
);

export const createPatientSuccess = createAction(
  '[Patients] Create Patient Success',
  props<{ patient: any }>()
);

export const createPatientFailure = createAction(
  '[Patients] Create Patient Failure',
  props<{ error: any }>()
);

export const updatePatient = createAction(
  '[Patients] Update Patient',
  props<{ patient: any }>()
);

export const updatePatientSuccess = createAction(
  '[Patients] Update Patient Success',
  props<{ patient: any }>()
);

export const updatePatientFailure = createAction(
  '[Patients] Update Patient Failure',
  props<{ error: any }>()
);

// upsert: el formulario es uno solo y no sabe si está creando o editando.
// Decide por la presencia de "id" y despacha la acción que corresponde.
// No llega al reducer nunca: es una acción que solo escuchan los effects.
export const upsertPatient = createAction(
  '[Patients] Upsert Patient',
  props<{ patient: any }>()
);

// Baja lógica. El nombre dice "delete" porque así lo llama el equipo y así
// aparece en el código real; lo que hace por dentro es un PATCH de "active".
// Esa distancia entre el nombre y el efecto es deuda de nombrado, y es la
// razón por la que alguien va a buscar un DELETE en el log de Express y no
// lo va a encontrar.
export const deletePatient = createAction(
  '[Patients] Delete Patient',
  props<{ patientId: number }>()
);

export const deletePatientSuccess = createAction(
  '[Patients] Delete Patient Success',
  props<{ patientId: number }>()
);

export const deletePatientFailure = createAction(
  '[Patients] Delete Patient Failure',
  props<{ error: any }>()
);
```

**Detalles con intención**

- El prefijo `[Patients]` es el mismo de la Fase 1. En Redux DevTools vas a poder filtrar por él y ver la vida entera de esta pantalla; si alguien escribe `[Patient]` en singular en una acción nueva, esa acción desaparece del filtro y nadie se entera. Ejercicio 23.
- `upsertPatient` es el único caso del curso donde una acción no toca el reducer. Es legítimo y frecuente: las acciones son eventos, no comandos de estado, y un evento puede interesarle solo a un effect.

### 5.5 `patients.reducer.ts` — los `case` nuevos en el mismo `switch`

```typescript
// src/app/patients/store/patients.reducer.ts
import * as PatientsActions from './patients.actions';

export interface PatientsState {
  items: any[];
  loading: boolean;
  error: any;
  selectedId: number;
  // Nuevo en Fase 5: la escritura tiene su propia bandera. Si compartiera
  // "loading" con la lectura, guardar pondría la tabla entera en spinner.
  saving: boolean;
  saveError: any;
  // El texto del filtro vive en el store, no en el componente. Así sobrevive
  // a navegar afuera y volver, y aparece en el log cuando reconstruyas un
  // incidente: vas a saber que estaba filtrando el usuario cuando fallo.
  filter: string;
}

export const initialState: PatientsState = {
  items: [],
  loading: false,
  error: null,
  selectedId: null,
  saving: false,
  saveError: null,
  filter: ''
};

export function patientsReducer(state = initialState, action: any): PatientsState {
  switch (action.type) {

    case PatientsActions.loadPatients.type:
      return { ...state, loading: true, error: null };

    case PatientsActions.loadPatientsSuccess.type:
      return { ...state, loading: false, items: action.patients };

    case PatientsActions.loadPatientsFailure.type:
      return { ...state, loading: false, error: action.error };

    case PatientsActions.selectPatient.type:
      return { ...state, selectedId: action.patientId };

    // Los tres verbos de escritura comparten el mismo estado de "guardando".
    // Caer varios "case" juntos sin "break" es intencional y es la forma
    // idiomática en un switch; si te parece un error, mira que no hay
    // "return" hasta el último.
    case PatientsActions.createPatient.type:
    case PatientsActions.updatePatient.type:
    case PatientsActions.deletePatient.type:
      return { ...state, saving: true, saveError: null };

    // Éxito de creación: NO se inserta el paciente en "items". El effect va a
    // despachar loadPatients() y la lista llegara entera desde el servidor.
    // Ver la deuda de 5.9.
    case PatientsActions.createPatientSuccess.type:
    case PatientsActions.updatePatientSuccess.type:
    case PatientsActions.deletePatientSuccess.type:
      return { ...state, saving: false };

    case PatientsActions.createPatientFailure.type:
    case PatientsActions.updatePatientFailure.type:
    case PatientsActions.deletePatientFailure.type:
      return { ...state, saving: false, saveError: action.error };

    case PatientsActions.setPatientsFilter.type:
      return { ...state, filter: action.filter };

    default:
      return state;
  }
}
```

> ⚠️ **Alto.** El `case` de `setPatientsFilter` referencia una acción que **no está en 5.4**. Es deliberado: es el ejercicio 1. Agrégala tú mismo siguiendo la convención, con `props<{ filter: string }>()`, y confirma que el `switch` compila. Si el proyecto no compila mientras lees esto, ya sabes por qué.

### 5.6 `patients.selectors.ts` — el filtro memoizado y el filtro de `active`

```typescript
// src/app/patients/store/patients.selectors.ts
import { createFeatureSelector, createSelector } from '@ngrx/store';
import { PatientsState } from './patients.reducer';

export const selectPatientsState = createFeatureSelector<PatientsState>('patients');

// Ojo: devuelve TODO, incluidos los dados de baja. Casi ningun consumidor
// debería usar este selector directamente, pero existe desde la Fase 1 y
// hay código que lo usa. Ver sección 6.
export const selectAllPatients = createSelector(
  selectPatientsState,
  function (state) { return state.items; }
);

export const selectPatientsLoading = createSelector(
  selectPatientsState,
  function (state) { return state.loading; }
);

export const selectPatientsSaving = createSelector(
  selectPatientsState,
  function (state) { return state.saving; }
);

export const selectPatientsError = createSelector(
  selectPatientsState,
  function (state) { return state.error; }
);

export const selectPatientsFilter = createSelector(
  selectPatientsState,
  function (state) { return state.filter; }
);

// El único selector que debería consumir la pantalla: activos solamente.
export const selectActivePatients = createSelector(
  selectAllPatients,
  function (patients) {
    return patients.filter(function (p) { return p.active !== false; });
  }
);

// Filtrado por texto, memoizado sobre el anterior. Si el filtro no cambio y
// la lista no cambió, esta función no se ejecuta y devuelve la referencia
// anterior. Sin memoización, cada detección de cambios recorrería 25 items
// y devolvería un array nuevo, y con 25 no se nota — con 4000 si, y eso es
// lo que mide la Fase 10.
export const selectFilteredPatients = createSelector(
  selectActivePatients,
  selectPatientsFilter,
  function (patients, filter) {
    if (!filter) { return patients; }
    var needle = filter.toLowerCase();
    return patients.filter(function (p) {
      // "any" otra vez: si fullName llega null desde el mock, esto revienta.
      // El ejercicio 19 lo provoca a propósito.
      return p.fullName.toLowerCase().indexOf(needle) >= 0 ||
             p.documentId.toLowerCase().indexOf(needle) >= 0;
    });
  }
);

export const selectSelectedPatient = createSelector(
  selectAllPatients,
  selectPatientsState,
  function (patients, state) {
    return patients.find(function (p) { return p.id === state.selectedId; }) || null;
  }
);
```

**Detalles con intención**

- `p.active !== false` y no `p.active === true`. Los tres pacientes que existían antes del `seed.js` no tienen el campo; con la comparación estricta desaparecerían de la pantalla sin explicación. Es defensa contra datos viejos, que es la mitad del trabajo en un sistema que lleva años corriendo.
- `selectAllPatients` sigue existiendo y sigue devolviendo todo. Convive con `selectActivePatients`, y esa convivencia es exactamente lo que produce el incidente 09.

### 5.7 `patients.service.ts` — POST, PATCH y la baja que no borra

```typescript
// src/app/patients/patients.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import { environment } from '../../environments/environment';

@Injectable({ providedIn: 'root' })
export class PatientsService {

  constructor(private http: HttpClient) { }

  getPatients(): Observable<any> {
    return this.http.get(environment.apiUrl + '/patients');
  }

  createPatient(patient: any): Observable<any> {
    // json-server asigna el id. Por eso el objeto que sale de acá NO lleva id
    // y el que vuelve SI: son objetos distintos y confundirlos es el bug
    // clásico de "guarde y después no lo encuentro".
    return this.http.post(environment.apiUrl + '/patients', patient);
  }

  updatePatient(patient: any): Observable<any> {
    // PUT reemplaza el recurso entero. Si el objeto que mandas no trae un
    // campo que existía, json-server lo borra. PATCH sería más seguro;
    // LabCore usa PUT y por eso acá va PUT. Ejercicio 31.
    return this.http.put(environment.apiUrl + '/patients/' + patient.id, patient);
  }

  deactivatePatient(patientId: number): Observable<any> {
    // La baja lógica: un PATCH de un solo campo. El método se llama
    // deactivate y no delete para que el nombre no mienta, aunque la acción
    // del store si se llame deletePatient.
    return this.http.patch(environment.apiUrl + '/patients/' + patientId, { active: false });
  }

  // Usado por el validador asíncrono del formulario. Devuelve un arreglo:
  // vacío si el documento está libre, con un elemento si ya existe.
  findByDocumentId(documentId: string): Observable<any> {
    return this.http.get(environment.apiUrl + '/patients?documentId=' + encodeURIComponent(documentId));
  }
}
```

### 5.8 `patients.effects.ts` — escribir y volver a leer

```typescript
// src/app/patients/store/patients.effects.ts
import { Injectable } from '@angular/core';
import { Actions, ofType, createEffect } from '@ngrx/effects';
import { of } from 'rxjs';
import { map, switchMap, mergeMap, catchError, timeout } from 'rxjs/operators';

import { PatientsService } from '../patients.service';
import * as PatientsActions from './patients.actions';

// Constante global heredada de la Fase 4, con su deuda ya declarada allí.
var REQUEST_TIMEOUT_MS = 10000;

@Injectable()
export class PatientsEffects {

  constructor(
    private actions$: Actions,
    private patientsService: PatientsService
  ) { }

  loadPatients$ = createEffect(function (this: PatientsEffects) {
    return this.actions$.pipe(
      ofType(PatientsActions.loadPatients),
      switchMap(() => {
        return this.patientsService.getPatients().pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function (patients: any) {
            return PatientsActions.loadPatientsSuccess({ patients: patients });
          }),
          catchError(function (error: any) {
            return of(PatientsActions.loadPatientsFailure({ error: error }));
          })
        );
      })
    );
  }.bind(this));

  // El effect que decide. No toca la red: solo traduce una intención en la
  // acción concreta. Por eso "map" y no "switchMap".
  upsertPatient$ = createEffect(function (this: PatientsEffects) {
    return this.actions$.pipe(
      ofType(PatientsActions.upsertPatient),
      map(function (action: any) {
        return action.patient.id
          ? PatientsActions.updatePatient({ patient: action.patient })
          : PatientsActions.createPatient({ patient: action.patient });
      })
    );
  }.bind(this));

  createPatient$ = createEffect(function (this: PatientsEffects) {
    return this.actions$.pipe(
      ofType(PatientsActions.createPatient),
      // mergeMap y no switchMap: switchMap cancelaría un guardado en curso si
      // llegara otro. En una lectura cancelar es correcto (te interesa la
      // última); en una escritura es perder datos del usuario en silencio.
      // Esta línea es la diferencia entre un bug de pantalla y un bug de
      // negocio, y es lo que se debuggea en la pieza forense.
      mergeMap((action: any) => {
        return this.patientsService.createPatient(action.patient).pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function (created: any) {
            return PatientsActions.createPatientSuccess({ patient: created });
          }),
          catchError(function (error: any) {
            return of(PatientsActions.createPatientFailure({ error: error }));
          })
        );
      })
    );
  }.bind(this));

  updatePatient$ = createEffect(function (this: PatientsEffects) {
    return this.actions$.pipe(
      ofType(PatientsActions.updatePatient),
      mergeMap((action: any) => {
        return this.patientsService.updatePatient(action.patient).pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function (updated: any) {
            return PatientsActions.updatePatientSuccess({ patient: updated });
          }),
          catchError(function (error: any) {
            return of(PatientsActions.updatePatientFailure({ error: error }));
          })
        );
      })
    );
  }.bind(this));

  deletePatient$ = createEffect(function (this: PatientsEffects) {
    return this.actions$.pipe(
      ofType(PatientsActions.deletePatient),
      mergeMap((action: any) => {
        return this.patientsService.deactivatePatient(action.patientId).pipe(
          timeout(REQUEST_TIMEOUT_MS),
          map(function () {
            return PatientsActions.deletePatientSuccess({ patientId: action.patientId });
          }),
          catchError(function (error: any) {
            return of(PatientsActions.deletePatientFailure({ error: error }));
          })
        );
      })
    );
  }.bind(this));

  // El effect más importante de la fase: después de cualquier escritura
  // exitosa, recargar la lista entera. Tres acciones distintas entran, una
  // sola acción sale.
  reloadAfterWrite$ = createEffect(function (this: PatientsEffects) {
    return this.actions$.pipe(
      ofType(
        PatientsActions.createPatientSuccess,
        PatientsActions.updatePatientSuccess,
        PatientsActions.deletePatientSuccess
      ),
      map(function () {
        return PatientsActions.loadPatients();
      })
    );
  }.bind(this));
}
```

> 💸 **Deuda técnica intencional: recargar la lista completa después de cada escritura.** Cada alta son dos viajes al servidor donde alcanzaba uno, y la tabla parpadea porque `loading` vuelve a `true` y la pantalla repinta desde cero. Con 25 registros no se nota; con cuatro mil y una conexión de sucursal, se nota mucho.
>
> **Lo correcto hoy** sería que `createPatientSuccess` insertara en el reducer el paciente que devolvió el servidor (`items: [...state.items, action.patient]`), que `updatePatientSuccess` reemplazara el elemento por `id`, y que `deletePatientSuccess` marcara el `active` localmente. Cero peticiones extra y cero parpadeo. NgRx 8 incluso traía `@ngrx/entity` con `addOne`, `updateOne` y `removeOne` ya escritos para exactamente esto.
>
> **En Track A no se paga.** El equipo eligió recargar después de un incidente en el que dos operadores editaban el mismo registro y la lista de cada uno mostraba una versión distinta durante minutos. La recarga es lenta, pero nunca miente. Cambiarla implica decidir qué hacer ante escritura concurrente, y eso es una conversación de producto. Lo que sí te llevas es el reflejo: **cuando la pantalla parpadee después de guardar, no busques un bug de render, busca una recarga.**

### 5.9 `patient-list.component.ts` — la tabla, el filtro, el paginador

```typescript
// src/app/patients/patient-list/patient-list.component.ts
import { Component, OnInit, ViewChild } from '@angular/core';
import { Store } from '@ngrx/store';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { MatSort } from '@angular/material/sort';
import { MatPaginator } from '@angular/material/paginator';
import { TranslateService } from '@ngx-translate/core';

import * as PatientsActions from '../store/patients.actions';
import * as PatientsSelectors from '../store/patients.selectors';
import { PatientFormComponent } from '../patient-form/patient-form.component';
import { PatientDeleteDialogComponent } from '../patient-delete-dialog/patient-delete-dialog.component';

@Component({
  selector: 'app-patient-list',
  templateUrl: './patient-list.component.html',
  styleUrls: ['./patient-list.component.scss']
})
export class PatientListComponent implements OnInit {

  // Las columnas son cadenas y tienen que coincidir EXACTAMENTE con los
  // matColumnDef de la plantilla. Una columna que sobre acá y no exista allá
  // revienta en tiempo de ejecución con un mensaje sobre "unknown column".
  displayedColumns: string[] = ['documentId', 'fullName', 'birthDate', 'email', 'actions'];

  // El dataSource es un arreglo plano, no un MatTableDataSource. Es lo que
  // hace LabCore. Ver la deuda al final de esta sección.
  dataSource: any[] = [];

  // Lo que realmente se pinta: la página actual del arreglo filtrado.
  pagedData: any[] = [];

  loading = false;
  loadError: any = null;
  filterText = '';

  pageSize = 10;
  pageIndex = 0;

  @ViewChild(MatPaginator, { static: false }) paginator: MatPaginator;
  @ViewChild(MatSort, { static: false }) sort: MatSort;

  constructor(
    private store: Store<any>,
    private dialog: MatDialog,
    private snackBar: MatSnackBar,
    private translate: TranslateService
  ) { }

  ngOnInit() {
    this.store.select(PatientsSelectors.selectFilteredPatients).subscribe(function (this: PatientListComponent, patients) {
      this.dataSource = patients;
      // Cada vez que llega lista nueva hay que recalcular la página. Si esto
      // falta, borras un paciente estando en la página 3 y la página 3 se
      // queda con el registro viejo. Ejercicio 12.
      this.applyPage();
    }.bind(this));

    this.store.select(PatientsSelectors.selectPatientsLoading).subscribe(function (this: PatientListComponent, loading) {
      this.loading = loading;
    }.bind(this));

    this.store.select(PatientsSelectors.selectPatientsError).subscribe(function (this: PatientListComponent, error) {
      this.loadError = error;
    }.bind(this));

    this.store.dispatch(PatientsActions.loadPatients());
  }

  // El filtro se despacha al store en cada tecla. Sin debounce: son 25
  // registros en memoria y el costo es cero. Con paginación de servidor esto
  // sería una petición por tecla, y ahí si haría falta. Ejercicio 33.
  onFilterChange(value: string) {
    this.filterText = value;
    this.pageIndex = 0;
    this.store.dispatch(PatientsActions.setPatientsFilter({ filter: value }));
  }

  onPageChange(event: any) {
    this.pageIndex = event.pageIndex;
    this.pageSize = event.pageSize;
    this.applyPage();
  }

  // Ordenamiento a mano sobre el arreglo. Compara con < y > sin mirar el
  // tipo: para cadenas y números funciona, para fechas ISO también porque
  // ordenan bien como texto. Para un campo que llegue como número en unos
  // registros y como cadena en otros, no. Ejercicio 18.
  onSortChange(event: any) {
    var field = event.active;
    var direction = event.direction === 'asc' ? 1 : -1;

    if (!event.direction) {
      this.applyPage();
      return;
    }

    // slice() antes de sort(): sort muta el arreglo original, y el original
    // viene del store. Mutarlo sería mutar el estado desde un componente,
    // que es la única regla de NgRx que este curso no negocia.
    this.dataSource = this.dataSource.slice().sort(function (a, b) {
      if (a[field] === b[field]) { return 0; }
      return (a[field] > b[field] ? 1 : -1) * direction;
    });
    this.applyPage();
  }

  applyPage() {
    var start = this.pageIndex * this.pageSize;
    this.pagedData = this.dataSource.slice(start, start + this.pageSize);
  }

  openCreate() {
    this.openForm(null);
  }

  openEdit(patient: any) {
    this.openForm(patient);
  }

  openForm(patient: any) {
    var ref = this.dialog.open(PatientFormComponent, {
      width: '640px',
      data: { patient: patient }
    });

    // afterClosed() emite una sola vez y se completa solo, así que no
    // desuscribirse acá no es un leak. En la Fase 10 vas a ver cual si lo es.
    ref.afterClosed().subscribe(function (this: PatientListComponent, result: any) {
      if (!result) { return; }   // Cerro con Cancelar o con Escape.
      this.store.dispatch(PatientsActions.upsertPatient({ patient: result }));
    }.bind(this));
  }

  // AQUÍ VIVE LA REGLA DE NEGOCIO. Un paciente con órdenes no se da de baja.
  // Un componente no debería saber esto, y menos consultarlo. Ver la deuda.
  onDelete(patient: any) {
    var ref = this.dialog.open(PatientDeleteDialogComponent, {
      width: '480px',
      data: { patient: patient }
    });

    ref.afterClosed().subscribe(function (this: PatientListComponent, confirmed: boolean) {
      if (!confirmed) { return; }
      this.store.dispatch(PatientsActions.deletePatient({ patientId: patient.id }));
      this.snackBar.open(
        this.translate.instant('patients.messages.deactivated'),
        this.translate.instant('common.actions.close'),
        { duration: 4000 }
      );
    }.bind(this));
  }

  retryLoad() {
    this.store.dispatch(PatientsActions.loadPatients());
  }
}
```

Y la plantilla, con los cuatro estados que la Fase 4 dejó como patrón:

```html
<!-- src/app/patients/patient-list/patient-list.component.html -->
<div class="d-flex justify-content-between align-items-center mb-3">
  <h2>{{ 'patients.title' | translate }}</h2>
  <button mat-raised-button color="primary" (click)="openCreate()">
    {{ 'common.actions.new' | translate }}
  </button>
</div>

<mat-form-field class="w-100 mb-2">
  <input matInput
         [ngModel]="filterText"
         (ngModelChange)="onFilterChange($event)"
         [placeholder]="'patients.filterPlaceholder' | translate">
</mat-form-field>

<div class="text-center my-4" *ngIf="loading">
  <mat-spinner diameter="40" class="mx-auto"></mat-spinner>
</div>

<div class="alert alert-warning" *ngIf="!loading && loadError">
  <p>{{ loadError.messageKey | translate }}</p>
  <small class="text-muted">{{ loadError.code }}</small>
  <button mat-stroked-button color="primary" (click)="retryLoad()">
    {{ 'patients.retry' | translate }}
  </button>
</div>

<p *ngIf="!loading && !loadError && dataSource.length === 0">
  {{ 'patients.empty' | translate }}
</p>

<table mat-table [dataSource]="pagedData" matSort (matSortChange)="onSortChange($event)"
       class="w-100" *ngIf="!loading && !loadError && dataSource.length > 0">

  <ng-container matColumnDef="documentId">
    <th mat-header-cell *matHeaderCellDef mat-sort-header>{{ 'patients.fields.documentId' | translate }}</th>
    <td mat-cell *matCellDef="let patient">{{ patient.documentId }}</td>
  </ng-container>

  <ng-container matColumnDef="fullName">
    <th mat-header-cell *matHeaderCellDef mat-sort-header>{{ 'patients.fields.fullName' | translate }}</th>
    <td mat-cell *matCellDef="let patient">{{ patient.fullName }}</td>
  </ng-container>

  <ng-container matColumnDef="birthDate">
    <th mat-header-cell *matHeaderCellDef mat-sort-header>{{ 'patients.fields.birthDate' | translate }}</th>
    <!-- El pipe date usa el LOCALE_ID que fijó la Fase 2. Si aquí vieras el
         formato del navegador y no el de la aplicación, el bug está allá. -->
    <td mat-cell *matCellDef="let patient">{{ patient.birthDate | date:'mediumDate' }}</td>
  </ng-container>

  <ng-container matColumnDef="email">
    <th mat-header-cell *matHeaderCellDef>{{ 'patients.fields.email' | translate }}</th>
    <td mat-cell *matCellDef="let patient">
      {{ patient.email || ('common.notProvided' | translate) }}
    </td>
  </ng-container>

  <ng-container matColumnDef="actions">
    <th mat-header-cell *matHeaderCellDef></th>
    <td mat-cell *matCellDef="let patient">
      <button mat-icon-button (click)="openEdit(patient)">
        <mat-icon>edit</mat-icon>
      </button>
      <button mat-icon-button color="warn" (click)="onDelete(patient)">
        <mat-icon>delete</mat-icon>
      </button>
    </td>
  </ng-container>

  <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
  <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>
</table>

<mat-paginator [length]="dataSource.length"
               [pageSize]="pageSize"
               [pageSizeOptions]="[5, 10, 25]"
               (page)="onPageChange($event)"
               *ngIf="!loading && !loadError && dataSource.length > 0">
</mat-paginator>
```

> 💸 **Deuda técnica intencional: paginación, filtro y orden hechos a mano sobre un arreglo en memoria.** El `db.json` se descarga entero en cada carga, el navegador corta las páginas con `slice()` y ordena con un comparador escrito a mano que no mira el tipo del dato. Con 25 registros es instantáneo; LabCore tiene tablas donde esto significa traer varios megabytes por pantalla.
>
> **Lo correcto hoy** sería paginación del lado del servidor —`GET /patients?_page=2&_limit=10`, que json-server soporta de fábrica— con el `MatPaginator` informando total desde la cabecera `X-Total-Count`, y el orden y el filtro también como parámetros de consulta. Y del lado del cliente, `MatTableDataSource` en vez del arreglo plano, que trae `filterPredicate` y `sortingDataAccessor` ya resueltos y conectados al paginador sin escribir `applyPage()`.
>
> **En Track A no se paga**, por una razón muy concreta: el endpoint real no pagina. Cambiar el cliente sin cambiar el servidor no arregla nada, y cambiar el servidor no está en tu alcance. Lo que sí ganas es la pregunta correcta ante un ticket de "la pantalla de X está lentísima": *¿cuántos registros trae esa petición?* Míralo en Network antes de mirar el código.

### 5.10 `patient-form.component.ts` — el formulario reactivo denso

```typescript
// src/app/patients/patient-form/patient-form.component.ts
import { Component, OnInit, Inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { of, timer } from 'rxjs';
import { map, switchMap, catchError } from 'rxjs/operators';

import { PatientsService } from '../patients.service';

@Component({
  selector: 'app-patient-form',
  templateUrl: './patient-form.component.html'
})
export class PatientFormComponent implements OnInit {

  patientForm: FormGroup;
  isEdit = false;

  constructor(
    private fb: FormBuilder,
    private patientsService: PatientsService,
    private dialogRef: MatDialogRef<PatientFormComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any
  ) { }

  ngOnInit() {
    var patient = this.data && this.data.patient ? this.data.patient : null;
    this.isEdit = !!patient;

    this.patientForm = this.fb.group({
      // El id no se edita pero viaja en el formulario: es lo que lee el
      // effect de upsert para decidir entre crear y actualizar.
      id: [patient ? patient.id : null],

      documentId: [
        patient ? patient.documentId : '',
        // Segundo argumento: validadores síncronos. Tercero: asíncronos.
        // Confundir las posiciones es el error de 6.2.
        [Validators.required, Validators.pattern(/^(CC|TI|CE)-\d{6,12}$/)],
        [this.documentIdTakenValidator()]
      ],

      fullName: [
        patient ? patient.fullName : '',
        [Validators.required, Validators.minLength(5), Validators.maxLength(80)]
      ],

      birthDate: [
        // El datepicker de Material espera un Date, no una cadena. El mock
        // devuelve cadena. Convertir acá y volver a convertir al guardar es
        // fricción pura, y es la que produce el bug de 6.3.
        patient && patient.birthDate ? new Date(patient.birthDate) : null,
        [Validators.required]
      ],

      email: [
        patient ? patient.email : '',
        [Validators.email]   // Sin required: el modelo permite email nulo.
      ],

      active: [patient ? patient.active !== false : true]
    });
  }

  // Validador asíncrono: recibe el control y devuelve un observable que emite
  // el objeto de error o null. Se ejecuta DESPUÉS de que pasen todos los
  // síncronos, no antes: si el formato está mal, nunca sale la petición.
  documentIdTakenValidator() {
    // `var self` y no `.bind(this)`: este método DEVUELVE el callback, y lo que
    // hay que atar es el `this` de la función de dentro, que se crea después.
    // Es uno de los dos sitios del curso donde el idioma cambia; el otro es el
    // AppConfigService de la Fase 13 §5.3, dentro de un .then().
    var self = this;
    return function (control: AbstractControl) {
      if (!control.value) { return of(null); }

      // timer(400) hace de debounce. Sin esto, cada tecla dispara una
      // petición y el mock recibe una ráfaga. Es la única protección que
      // tiene este formulario contra si mismo.
      return timer(400).pipe(
        switchMap(function () {
          return self.patientsService.findByDocumentId(control.value);
        }),
        map(function (found: any) {
          // Al editar, encontrarse a uno mismo no es un conflicto.
          var currentId = self.patientForm ? self.patientForm.get('id').value : null;
          var conflict = found.filter(function (p: any) { return p.id !== currentId; });
          return conflict.length > 0 ? { documentIdTaken: true } : null;
        }),
        // Si la consulta falla, el validador NO invalida el campo. Un backend
        // caído no puede impedir que el usuario guarde: eso convertiría una
        // caída de red en una perdida de trabajo. Se deja pasar y el servidor
        // decidirá. Discutible, y está discutido en el ejercicio 30.
        catchError(function () { return of(null); })
      );
    };
  }

  save() {
    // Guardia explicita: el botón puede estar habilitado si hay validación
    // pendiente (ver sección 4). Esta línea es lo único que impide guardar
    // un documento duplicado, y por eso está escrita a mano.
    if (this.patientForm.invalid || this.patientForm.pending) { return; }

    var value = this.patientForm.value;

    // La fecha vuelve a cadena ISO corta antes de salir, para que el mock
    // reciba lo mismo que entregó. toISOString() daría UTC y restaría un día
    // en America/Bogotá; por eso se corta a mano. Ver 6.3.
    var birth: Date = value.birthDate;
    var normalized = {
      ...value,
      birthDate: birth
        ? birth.getFullYear() + '-' +
          ('0' + (birth.getMonth() + 1)).slice(-2) + '-' +
          ('0' + birth.getDate()).slice(-2)
        : null,
      email: value.email ? value.email : null
    };

    // Si es creación, el id null no debe viajar: json-server lo asigna.
    if (!normalized.id) { delete normalized.id; }

    this.dialogRef.close(normalized);
  }

  cancel() {
    this.dialogRef.close(null);
  }

  // Atajo para la plantilla. Devuelve la clave de i18n del primer error del
  // control, o null. Toda la lógica de mensajes vive acá adentro.
  errorKeyFor(controlName: string): string {
    var control = this.patientForm.get(controlName);
    if (!control || !control.touched || !control.errors) { return null; }

    if (control.errors.required) { return 'validation.required'; }
    if (control.errors.pattern) { return 'validation.documentIdFormat'; }
    if (control.errors.minlength) { return 'validation.tooShort'; }
    if (control.errors.maxlength) { return 'validation.tooLong'; }
    if (control.errors.email) { return 'validation.emailFormat'; }
    if (control.errors.documentIdTaken) { return 'validation.documentIdTaken'; }
    return 'validation.invalid';
  }
}
```

```html
<!-- src/app/patients/patient-form/patient-form.component.html -->
<h2 mat-dialog-title>
  {{ (isEdit ? 'patients.form.editTitle' : 'patients.form.createTitle') | translate }}
</h2>

<div mat-dialog-content [formGroup]="patientForm">

  <mat-form-field class="w-100">
    <input matInput formControlName="documentId"
           [placeholder]="'patients.fields.documentId' | translate">
    <!-- pending: la consulta está viajando. Sin este indicador, el usuario
         ve un campo aparentemente válido durante toda la espera. -->
    <mat-spinner matSuffix diameter="16"
                 *ngIf="patientForm.get('documentId').pending"></mat-spinner>
    <mat-error *ngIf="errorKeyFor('documentId')">
      {{ errorKeyFor('documentId') | translate }}
    </mat-error>
  </mat-form-field>

  <mat-form-field class="w-100">
    <input matInput formControlName="fullName"
           [placeholder]="'patients.fields.fullName' | translate">
    <mat-error *ngIf="errorKeyFor('fullName')">
      {{ errorKeyFor('fullName') | translate }}
    </mat-error>
  </mat-form-field>

  <mat-form-field class="w-100">
    <input matInput [matDatepicker]="birthPicker" formControlName="birthDate"
           [placeholder]="'patients.fields.birthDate' | translate">
    <mat-datepicker-toggle matSuffix [for]="birthPicker"></mat-datepicker-toggle>
    <mat-datepicker #birthPicker></mat-datepicker>
    <mat-error *ngIf="errorKeyFor('birthDate')">
      {{ errorKeyFor('birthDate') | translate }}
    </mat-error>
  </mat-form-field>

  <mat-form-field class="w-100">
    <input matInput formControlName="email"
           [placeholder]="'patients.fields.email' | translate">
    <mat-error *ngIf="errorKeyFor('email')">
      {{ errorKeyFor('email') | translate }}
    </mat-error>
  </mat-form-field>

</div>

<div mat-dialog-actions align="end">
  <button mat-button (click)="cancel()">
    {{ 'common.actions.cancel' | translate }}
  </button>
  <!-- El bug del ejercicio 26 está en la línea de abajo, escrito a propósito
       tal como aparece en LabCore. -->
  <button mat-raised-button color="primary"
          [disabled]="patientForm.invalid"
          (click)="save()">
    {{ 'common.actions.save' | translate }}
  </button>
</div>
```

### 5.11 `patient-delete-dialog.component.ts` — la regla de negocio dentro del componente

```typescript
// src/app/patients/patient-delete-dialog/patient-delete-dialog.component.ts
import { Component, OnInit, Inject } from '@angular/core';
import { MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { HttpClient } from '@angular/common/http';

import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-patient-delete-dialog',
  templateUrl: './patient-delete-dialog.component.html'
})
export class PatientDeleteDialogComponent implements OnInit {

  checking = true;
  orderCount = 0;

  constructor(
    private http: HttpClient,
    private dialogRef: MatDialogRef<PatientDeleteDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any
  ) { }

  ngOnInit() {
    // HttpClient inyectado directamente en un componente de diálogo, sin
    // pasar por servicio ni por store. Es exactamente lo que hace el sistema
    // real y es la deuda declarada abajo.
    this.http.get(environment.apiUrl + '/orders?patientId=' + this.data.patient.id)
      .subscribe(function (this: PatientDeleteDialogComponent, orders: any) {
        this.orderCount = orders.length;
        this.checking = false;
      }.bind(this), function (this: PatientDeleteDialogComponent) {
        // Si la consulta falla, se asume lo peor: no se deja dar de baja.
        // Es la decisión conservadora. La contraria dejaria pasar una baja
        // que podría romper trazabilidad.
        this.orderCount = -1;
        this.checking = false;
      }.bind(this));
  }

  get canDeactivate(): boolean {
    return this.orderCount === 0;
  }

  confirm() {
    this.dialogRef.close(true);
  }

  cancel() {
    this.dialogRef.close(false);
  }
}
```

> 💸 **Deuda técnica intencional: la regla de negocio vive en el componente, y el componente habla HTTP directo.** "Un paciente con órdenes no se da de baja" es una regla del dominio, y está escrita en un diálogo de confirmación, en un `subscribe` a pelo, sin pasar por el store ni por `PatientsService`. Nadie más en el sistema conoce esa regla: si mañana se da de baja un paciente desde otra pantalla, la regla no se aplica.
>
> **Lo correcto hoy** sería que la regla viviera en el servidor —que es el único lugar donde nadie puede saltársela— y, en su defecto, en un `PatientsService` con un método `canDeactivate(patientId)` que el store consultara mediante un effect, con el resultado en el estado y el diálogo leyéndolo del store como todo lo demás.
>
> **En Track A no se paga.** Acá escribes una copia de la regla; en LabCore acabaron siendo varias, cada una escrita por quien construyó su pantalla, con consultas que se parecen y no son idénticas. Es lo que le pasa a toda regla que vive en un componente en vez de en un sitio: se replica cuando aparece la segunda pantalla que la necesita, y nadie se entera de que ya existía. Unificarlas exige primero averiguar cuál de las copias es la correcta, y eso es arqueología con el área de negocio, no un hotfix.
>
> Lo que sí te llevas, y es lo que de verdad transfiere: **cuando una regla se comporte distinto según desde qué pantalla la dispares, no busques un bug — busca la segunda copia de la regla.** El ejercicio 22 te hace vivirlo con los dos selectores de pacientes, que es el mismo problema una capa más abajo.

> **Nota de continuidad (editada desde la Fase 8).** La versión original de esta fase sembraba `status` de orden con valores sueltos (`created`, `processing`, `reported`) que no coincidían con el flujo canónico del ALCANCE. Mientras la orden era un CRUD aislado eso no molestaba a nadie; en la Fase 8, donde "la última muestra procesada empuja la orden a `partial_results`" cruza las dos máquinas de estado, esos valores no tenían a dónde empujar. Se normalizó el `seed.js` de esta fase al flujo único, con el mismo precedente con el que la Fase 3 recibió su `server.js`: una brecha de continuidad detectada tarde se corrige con una edición localizada del entregable anterior, no reabriendo su alcance.

> **Nota de continuidad (editada desde la Fase 9).** El flujo canónico del ALCANCE termina en `complete → delivered → expired`, pero la versión original de esta fase dejó `delivered` fuera del `seed.js` con el argumento —correcto— de que a ese estado solo se llega entregando el informe. La Fase 9 es donde se entrega: construye la acción `markDelivered` y el primer `order.transitions.ts` que endurece la máquina de órdenes con una guarda real. Para que ese estado destino exista en la máquina, se agregó `'delivered'` a `ORDER_STATUSES` acá —que es donde el `seed.js` de esta fase define el flujo de la orden—, sin sembrar ninguna orden ya entregada: el sorteo usa `SEEDABLE_ORDER_STATUSES`, que excluye `delivered` y `expired`. La guarda `complete → delivered` **no** vive en esta fase: nace en la Fase 9, igual que la guarda de la muestra nace en la Fase 7 y no en la fase que sembró las muestras. Y el `MatSelect` que ofrece los seis estados sin distinguir cuál es alcanzable es material de la **Fase 6 §5.4**, que es donde la máquina de órdenes se ve por primera vez y donde se declara que todavía no es una máquina.

> **Prueba de fuego.** Corre `npm run seed`, después `npm run mock`, después `npx ng serve`, y entra a `/patients`. Deberías ver 25 pacientes paginados de diez en diez. Crea uno nuevo con documento `CC-123456` y mira Redux DevTools: cuatro acciones —`Upsert`, `Create`, `Create Success`, `Load Patients`— y la lista completa llegando otra vez. Ahora da de baja y abre `db.json` en el editor: el registro sigue ahí, con `active: false`. Por último, levanta el mock con `CHAOS=latency=3000`, abre el formulario, escribe un documento que ya exista y cuenta hasta tres antes de que el campo se ponga rojo. Durante esos tres segundos el botón de guardar estuvo habilitado.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**`Can't bind to 'formGroup' since it isn't a known property of 'div'`.**
Síntoma: el proyecto compila, pero al abrir el diálogo la consola escupe ese mensaje y el formulario aparece sin ningún valor.
Causa: falta `ReactiveFormsModule` en el módulo donde está declarado el componente. `FormsModule` —el de la Fase 0— **no** lo incluye: son dos módulos distintos que resuelven el mismo problema de dos formas.
Fix mínimo: agregarlo al `SharedModule` (§5.3). La refactorización correcta no existe acá; simplemente faltaba.

**El validador asíncrono nunca se ejecuta.**
Síntoma: escribes un documento duplicado y el campo se queda verde. En Network no sale ninguna petición.
Causa: casi siempre, el validador está en la posición equivocada del arreglo de `FormBuilder`. La firma es `[valorInicial, validadoresSincronos, validadoresAsincronos]`, y meter el asíncrono en la segunda posición hace que Angular lo llame como si fuera síncrono, reciba un observable, y lo trate como un objeto de error truthy —o directamente lo ignore, según el caso.
Fix mínimo: mover el validador al tercer argumento, siempre dentro de su propio arreglo. La segunda causa en frecuencia es que un validador síncrono ya está fallando: los asíncronos solo corren cuando todos los síncronos pasan, así que un patrón mal escrito deja al asíncrono muerto para siempre y el síntoma es idéntico.

**La fecha se guarda un día antes.**
Síntoma: eliges el 12 de marzo en el datepicker, guardas, recargas, y aparece el 11.
Causa: `Date.toISOString()` convierte a UTC. En `America/Bogota` —la zona que fijó la Fase 2— la medianoche local del 12 es el 12 a las 05:00 UTC, pero cualquier hora anterior a las 19:00 local del día 11 se convierte al día 11. Con un `Date` construido a medianoche local y convertido a UTC, el resultado depende del signo del offset, y con UTC-5 el signo juega en contra.
Fix mínimo: extraer año, mes y día del `Date` con `getFullYear()`, `getMonth()` y `getDate()` —que devuelven la fecha **local**— y armar la cadena a mano, como hace `save()` en §5.10. La refactorización correcta sería no usar `Date` para representar fechas sin hora, que es el problema de fondo y es tema del incidente 07 en la Fase 8.

**El paciente dado de baja sigue apareciendo en una pantalla y en otra no.**
Síntoma: la tabla de pacientes ya no lo muestra, pero el selector de paciente del formulario de órdenes sí.
Causa: dos selectores conviviendo. La tabla consume `selectFilteredPatients`, que filtra por `active`; el otro consumidor quedó con `selectAllPatients`, que devuelve todo, tal como lo dejó la Fase 1.
Fix mínimo: cambiar el selector en el consumidor equivocado. La refactorización correcta —renombrar `selectAllPatients` a `selectAllPatientsIncludingInactive` para que el nombre no mienta— toca todos los consumidores del curso y se decide a nivel de proyecto, no de hotfix. Este es el **incidente 09**.

**`patientForm.get('documentID')` devuelve `null` y la pantalla revienta.**
Síntoma: `Cannot read property 'touched' of null`, apuntando al método `errorKeyFor`.
Causa: la cadena no coincide con ninguna clave del `FormGroup`, y en Angular 8 nada la valida. Mayúscula de más, guion bajo, un plural: el `get()` devuelve `null` en silencio.
Fix mínimo: corregir la cadena. Es el mismo patrón de la Fase 1 con `createFeatureSelector('patients')`, y no es coincidencia: en el Angular de esta época, **toda cadena que sirve de identificador es una bomba de relojería sin validación**. Cuando algo devuelva `null` sin explicación, la primera sospecha es una cadena mal escrita.

### Pieza forense de esta fase

La pieza es **reproducir un bug de usuario desde un ticket vago**, y se desarrolla completa en [`forense-fase-05.md`](./forense-fase-05.md). Acá va el gancho.

El ticket dice, literalmente: *"a veces guardo un paciente y se guarda dos veces"*. No hay pasos, no hay hora, no hay nombre del paciente. Lo que sí hay es un log de acciones de Redux DevTools que alguien tuvo la decencia de exportar.

El trabajo forense consiste en tres movimientos que se repiten en cualquier ticket de este tipo. Primero, **convertir la frase del usuario en una secuencia de acciones**: si se guardó dos veces, en el log tienen que aparecer dos `[Patients] Create Patient`. Si aparecen dos, el problema es que el usuario pudo pulsar dos veces —y eso apunta al botón, no al store—. Si aparece una sola y en `db.json` hay dos registros, el problema está del lado del servidor o del reintento HTTP, y es otra investigación completamente distinta. Esa bifurcación se decide con una mirada al log y ahorra medio día.

Segundo, **encontrar por qué el botón dejó pulsar dos veces**. En §5.10 hay una respuesta esperando: el botón se deshabilita con `patientForm.invalid` y no con `saving`. Mientras la petición viaja, el formulario sigue válido y el botón sigue vivo. Con el mock rápido es imposible de reproducir; con `CHAOS=latency=3000` sale a la primera. Ese es el patrón que se instala acá: **un bug que no reproduces no es un bug intermitente, es un bug de temporización que todavía no aprendiste a provocar.**

Tercero, **decidir el fix mínimo**. Deshabilitar el botón durante `saving` es una línea. Deduplicar en el effect con un `exhaustMap` en vez de `mergeMap` es también una línea, pero cambia el comportamiento de todas las escrituras del sistema. La primera es un hotfix; la segunda es un cambio de arquitectura disfrazado de una línea. Saber cuál estás haciendo es la mitad del oficio.

**Rompe a propósito y observa.** Cambia `mergeMap` por `switchMap` en `createPatient$` (§5.8). Después levanta el mock con `CHAOS=latency=4000`, abre el formulario, guarda un paciente, y **sin esperar** abre otro y guarda también.

Lo que vas a ver en pantalla: los dos diálogos se cierran, los dos parecen haberse guardado, aparece un `MatSnackBar` de éxito. Lo que vas a ver en Network: dos peticiones POST, una de ellas cancelada. Lo que vas a ver en Redux DevTools: dos `[Patients] Create Patient` entrando, y **un solo** `Create Patient Success`. Lo que vas a ver en `db.json`: un solo paciente.

La mentira que te va a contar la pantalla es que todo salió bien. `switchMap` canceló la primera petición porque llegó una segunda, y como la cancelación no es un error, `catchError` no se ejecutó y nadie despachó un fallo. El usuario perdió un registro y el sistema no tiene ni idea. Ahora vuelve a `mergeMap` y repite: dos POST, dos éxitos, dos pacientes.

Los **incidentes 09 y 10** del cuaderno viven de esta fase. El 09 es el paciente dado de baja que reaparece en un desplegable; el 10 es el guardado que se pierde cuando el servidor va lento.

---

## 🧪 7. Ejercicios (31)

**🟢 Fácil (1–9)**

1. Agrega la acción `setPatientsFilter` que falta en `patients.actions.ts`, siguiendo la convención del prefijo `[Patients]`, y confirma que el reducer de §5.5 compila.
2. Corre `npm run seed` y cuenta cuántos pacientes quedaron con `email: null`. Explica por qué ese número no cambia entre corridas.
3. Agrega una columna `active` a `displayedColumns` sin crear su `matColumnDef` y anota el mensaje exacto que aparece en consola. Después deshazlo.
4. Cambia `pageSizeOptions` a `[3, 6, 9]` y confirma que el paginador respeta el nuevo primer valor solo si también cambias `pageSize`.
5. **Diagnóstico.** Te entregan el formulario con `Validators.minLength(5)` en `documentId` en vez de en `fullName`. Escribe el síntoma que reportaría un usuario, sin usar la palabra "validador".
6. Traduce las claves nuevas (`patients.form.*`, `validation.*`, `common.actions.*`) al inglés y confirma que el formulario cambia de idioma sin recargar.
7. Quita `MatNativeDateModule` del `SharedModule`, abre el datepicker y anota el error. Explica por qué el proyecto compiló igual.
8. **Diagnóstico.** El botón de baja no hace nada y no hay errores en consola. Sabes que `onDelete` se ejecuta. Lista tres hipótesis y ordénalas por costo de verificación.
9. Agrega al diálogo de baja el conteo de órdenes en el texto de confirmación, usando pluralización con las claves `_zero` / `_one` / `_other` de la Fase 2.

**🟡 Intermedio (10–20)**

10. Haz que el `MatSnackBar` de baja exitosa se muestre solo cuando llega `deletePatientSuccess`, y no inmediatamente al confirmar como está ahora. Explica qué mentira contaba la versión anterior.
11. Agrega `saving` al botón de guardar (`[disabled]="patientForm.invalid || saving"`) leyendo el estado desde el store, y verifica con `CHAOS=latency=3000` que el doble guardado ya no es posible.
12. **Diagnóstico.** Ve a la página 3, da de baja a un paciente, y observa qué pasa con la página. Explica el rol de `applyPage()` en el `subscribe` del selector.
13. Implementa el filtro para que también busque por correo, y explica por qué eso rompe con el paciente que tiene `email: null`.
14. Haz que el texto del filtro sobreviva a navegar a otra ruta y volver. Ya está casi hecho: encuentra qué falta, y explica en una línea por qué esa decisión —el filtro en el store— es la contraria a la que tomará la Fase 7 con el suyo.
15. **Diagnóstico.** Cambia `p.active !== false` por `p.active === true` en `selectActivePatients`, agrega a mano un paciente sin campo `active` en `db.json`, y explica qué desapareció y por qué.
16. Agrega una fila de resumen bajo la tabla con el total de pacientes activos y el de filtrados, ambos desde selectores.
17. **Diagnóstico.** El validador asíncrono dispara una petición por tecla. Localiza qué línea lo evita hoy y qué pasa si la quitas.
18. Ordena por `birthDate` y confirma que funciona. Ahora cambia a mano una fecha del `db.json` por `"12/03/1984"` y vuelve a ordenar. Explica el resultado sin decir "está mal el dato".
19. **Diagnóstico.** Pon `fullName: null` en un paciente del `db.json`, escribe algo en el filtro, y rastrea el error hasta la línea exacta de `selectFilteredPatients`. Escribe el fix mínimo y explica por qué no es el correcto.
20. Haz que al editar un paciente el diálogo muestre el título de edición y no el de creación. Verifica que funciona tanto desde el ícono de lápiz como si abres el formulario con `data` nulo.

**🟠 Difícil (21–25)**

21. Baja `@angular/cdk` a `8.1.0` en `package.json`, corre `npm install` y `ng serve`, y anota el error completo. Explica por qué el mensaje no menciona ni a `MatTable` ni a Material. Restaura después.
22. **Diagnóstico.** El paciente dado de baja desaparece de la tabla pero sigue apareciendo al asignarlo a una orden nueva. Reprodúcelo, localiza el selector culpable y escribe el post-mortem de tres líneas. Este es el incidente 09.
23. Renombra el prefijo de una sola acción de `[Patients]` a `[Patient]`, filtra por `[Patients]` en Redux DevTools, y explica qué se rompe en una investigación forense.
24. Reemplaza el arreglo plano por un `MatTableDataSource` conectado a `MatPaginator` y `MatSort` por `@ViewChild`. Mide cuántas líneas de `patient-list.component.ts` desaparecen y explica qué ganaste y qué perdiste en control.
25. **Diagnóstico.** Con `CHAOS=fail=500@50`, guarda diez pacientes seguidos. Cuenta cuántos llegaron al `db.json`, cuántos `Failure` hay en el log, y si los dos números cuadran. Si no cuadran, explica dónde se perdió la diferencia.

**🔴 Muy difícil (26–31)**

26. Reproduce el bug de `pending`: con `CHAOS=latency=3000`, escribe un `documentId` duplicado y guarda antes de que el validador responda. Confirma que el duplicado entró al `db.json`. Escribe el fix mínimo, el fix correcto, y argumenta cuál aplicarías un viernes a las seis de la tarde.
27. Edita un paciente quitando el campo `active` del `normalized` antes de enviarlo, y observa qué le hace el `PUT` al registro. Explica la diferencia con `PATCH` y por qué LabCore eligió mal.
28. Ejecuta la pieza forense completa de §6 con `switchMap`, y escribe el post-mortem incluyendo la pregunta que le harías al usuario que reportó el ticket para confirmar tu hipótesis antes de tocar código.
29. Agrega `debounceTime` al filtro suponiendo paginación de servidor: convierte `onFilterChange` para que despache una acción que dispare un effect con `debounceTime(300)` y `switchMap`. Explica por qué acá `switchMap` sí es correcto y en la escritura no.
30. El validador asíncrono se rinde con `catchError(() => of(null))` cuando el servidor falla. Argumenta la posición contraria —invalidar el campo ante fallo de red— con un escenario concreto del laboratorio donde esa sea la decisión correcta. Después decide cuál dejarías y escribe el comentario que justifique la decisión en el código.
31. **Diagnóstico.** Sin mirar el código, te dan este log de DevTools: `Upsert Patient` → `Create Patient` → `Load Patients` → `Load Patients Success` → `Create Patient Failure`. Reconstruye qué pasó, en qué orden, y qué va a estar viendo el usuario en pantalla. Pista: el orden de las últimas dos acciones no es un error de transcripción.

**🔥 Opcionales**

- 🔥 Migra el slice de pacientes a `@ngrx/entity` con `createEntityAdapter`, `addOne` y `updateOne`, y elimina el effect `reloadAfterWrite$`. Documenta qué se rompe en las Fases 7 a 11 si esto se adopta.
- 🔥 Implementa paginación real de servidor con `_page` y `_limit` de json-server, leyendo el total desde `X-Total-Count`. Ojo con CORS: esa cabecera hay que exponerla explícitamente.
- 🔥 Escribe un guard `CanDeactivate` que impida cerrar el diálogo con cambios sin guardar, y explica por qué con `MatDialog` no alcanza con el guard del router.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v8.angular.io/guide/reactive-forms — guía de formularios reactivos de la versión exacta del curso. ⚠️ Enlace no verificado al cierre de este documento; si `v8.angular.io` no responde, la ruta alternativa es `https://angular.io/guide/reactive-forms` advirtiendo que cubre una versión posterior con formularios tipados que **no** existen en Angular 8.
- https://v8.angular.io/api/forms/AsyncValidatorFn — la firma exacta del validador asíncrono, incluido el orden de los argumentos de `FormBuilder.group()` que causa el error de §6.
- https://v8.angular.io/api/forms/FormArray — `FormArray` tal como lo usa §5.12.
- https://material.angular.io/components/table/overview — `MatTable`. ⚠️ El sitio de Material solo publica la versión actual; la API de tabla cambió poco desde la 8, pero los ejemplos usan sintaxis posterior. La documentación de la 8.2.x se consulta desde el tag `8.2.3` del repositorio: https://github.com/angular/components/tree/8.2.3/src/material/table
- https://material.angular.io/components/paginator/api y https://material.angular.io/components/sort/api — misma advertencia de versión.
- https://ngrx.io/guide/effects — effects. ⚠️ Cubre versiones posteriores; el `createEffect` de esta página es compatible con NgRx 8, pero `createFeature` y `createActionGroup` que aparecen en las guías vecinas **no existen** en la versión del curso.
- https://github.com/typicode/json-server/tree/v0.16.3 — filtros por campo (`?documentId=`), paginación (`_page`, `_limit`) y `PATCH`, en la versión que fijó la Fase 4.

**Libros / artículos de referencia**

- Martin Fowler, *Patterns of Enterprise Application Architecture* — el patrón de baja lógica aparece como variante de **Audit Log** y de **Temporal Property**. Es la referencia de fondo para §5.2.
- Baeldung, *Soft Delete in Practice* — https://www.baeldung.com/spring-jpa-soft-delete — el ejemplo es Java y JPA, no Angular, y por eso mismo le habla directo al perfil de este curso: el problema y sus costos son idénticos, cambia la capa donde se resuelve.
- Discusión canónica sobre el costo del borrado lógico: https://www.jamesshore.com/v2/blog/2005/soft-deletes-are-bad-mkay — la posición contraria, argumentada. Vale la pena leerla justo después de implementar §5.2, mientras la decisión todavía te parece obviamente correcta.

**Video / apoyo**

- *Angular Reactive Forms* de Deborah Kurata — https://www.youtube.com/results?search_query=deborah+kurata+angular+reactive+forms — material de la época y ritmo adecuado para quien viene de backend. ⚠️ Verifica la fecha del video: cualquiera posterior a 2022 va a mostrar formularios tipados.

**Orden de lectura sugerido:** antes de escribir código, la guía de formularios reactivos de v8 completa —son veinte minutos y evitan la mitad de los errores de §6—. Durante, la API de `AsyncValidatorFn` y el código fuente de `MatTable` en el tag 8.2.3 cuando la documentación oficial te muestre algo que no compila. Después, y sin saltártelo, los dos artículos sobre baja lógica: uno a favor y otro en contra, en ese orden.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido desde que se escribió esto. Los enlaces a `v8.angular.io` están marcados como **no verificados** y arrastran el pendiente abierto en la Fase 3. Cualquier documentación de Material o NgRx que consultes en su sitio oficial cubre una versión posterior a la del curso: léela sabiendo que la mitad de lo que ofrece no existe en tu `package.json`.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Quedó construido el primer CRUD completo del sistema, y con él el molde que copian las seis pantallas que vienen: componente gordo que consume selectores y despacha acciones, formulario reactivo en diálogo, escritura que recarga en vez de insertar, y reglas de negocio viviendo donde no deberían. Quedaron declaradas tres deudas 💸 que no se pagan, y quedó instalado el reflejo más útil de la fase: **cuando la pantalla y el estado no coincidan, el log de acciones dice cuál de los dos miente.**

La **Fase 6 — Órdenes** es el paso natural, y no porque el dominio lo pida: porque el molde necesita aplicarse una segunda vez para que se vea que es un molde. Esa fase copia estos cinco archivos cambiando un sustantivo y se detiene en las tres cosas que no se copian —una lista dentro del formulario, un dato que hay que cruzar contra otro slice, y un `status` que parece una máquina de estados sin serlo—. Y trae la pregunta que con un solo slice no existía: qué pasa cuando consultas un estado que todavía no se ha cargado.

> **La señal de que quedó bien:** cuando alguien te diga *"guardé y no se guardó"* y tu primer movimiento no sea abrir el código, sino pedirle el log de acciones y contar cuántos `Create` hay contra cuántos `Success`.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-05-pacientes -m "F5 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f05: …`) y los de ejercicio su
> número (`f05 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f05/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

Cosas que aparecieron escribiendo esta fase y que no caben acá:

- **[A]** Permisos por rol sobre los botones de acción. El `AuthService` de la Fase 3 sabe quién está autenticado, pero ninguna pantalla le pregunta nada → sugerido para **apéndice** de autorización o para las **pendientes de proyecto**; no es de una fase concreta.
- **[B]** `@ngrx/entity` como reemplazo del arreglo plano en el estado. Toca las Fases 5 a 11 completas si se adopta → sugerido para **apéndice A06 (NgRx 8)** como sección de "lo que existía y no usamos", más el ejercicio 🔥 ya incluido.
- **[C]** El nombre `deletePatient` para una acción que hace un `PATCH`. Es deuda de nombrado transversal → sugerido para el **cuaderno de incidentes**, como incidente de baja dificultad centrado en "busqué el DELETE en el log y no estaba".
- **[D]** Fechas sin hora representadas con `Date`. Acá se parchea a mano en `save()`; el problema de fondo es de la **Fase 8** y ya tiene su incidente 07 abierto.
- **[E]** `MatTableDataSource` con `connect()` / `disconnect()` propios y el ciclo de vida de una tabla que se destruye → **resuelto en la Fase 10 (dashboard)**. Ahí el ciclo de vida de las suscripciones deja de ser una nota al margen y se vuelve el tema central: la Fase 10 muestra la deuda 💸 de suscribirse sin cerrar (el `.subscribe()` a pelo sin `ngOnDestroy` de esta misma pantalla es el mismo patrón) y su fix con `takeUntil(this.destroy$)` o el `async` pipe, y mide el re-render con `console.count`, que es donde `trackBy` entra como una de las salidas. El `disconnect()` de un `MatTableDataSource` es exactamente ese cierre de ciclo de vida aplicado a la tabla. Los `.subscribe()` sin cerrar de `PatientListComponent` (§5.7 de esta fase) son, vistos desde la Fase 10, el mismo memory leak que el dashboard convierte en el incidente 16.
- **[F]** Concurrencia de escritura real: dos operadores editando el mismo registro. Es la razón por la que existe la deuda de recarga completa de §5.8, y no tiene lugar en este curso porque no hay backend con versionado → sugerido para el **cuaderno de incidentes** como caso de discusión sin fix.

### Reservas para el cuaderno de incidentes

Esta fase toma los incidentes **09 y 10**, no el 08: el 08 ya está reclamado por la Fase 4 en su §6, y reasignarlo habría partido un entregable cerrado. Los dos están en el índice del cuaderno y con su enunciado escrito:

- **09** · Fase 5 · *"El paciente que di de baja sigue saliendo en la lista"* · Categoría: estado (store) · Dificultad 🟡
- **10** · Fase 5 · *"Guardo y a veces no se guarda"* · Categoría: concurrencia · Dificultad 🟠 — solo el `switchMap` que cancela una escritura. Su hermano de muestras, la lista que no cambia al navegar, es el **21** y es de la Fase 7: comparten la sensación («no pasó lo que pedí») y no la causa, así que no comparten incidente.
