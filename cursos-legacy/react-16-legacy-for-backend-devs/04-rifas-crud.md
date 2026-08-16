# 🎲 Fase 04 — Rifas CRUD

> Tutorial React 16 — Rifas y chances · Fase 4 de 11 · **8 horas**
> Depende de: Fase 3 — Mock API + Express caos · Habilita: Fase 5 — Venta de números

---

## 🎯 1. Propósito

Hasta acá la app sabía navegar (Fase 1), autenticarse (Fase 2) y hablar con un backend que falla a propósito (Fase 3). Lo que no sabía era **hacer algo útil con datos**. Esta fase construye el primer CRUD real del sistema: administrar rifas contra `json-server`, con Redux Toolkit como store.

El objetivo no es que aprendas a escribir un slice —eso lo hace cualquiera con la doc abierta— sino que aprendas a escribir uno que **sobreviva a un backend áspero**. El mock de Fase 3 mete latencia, 500, timeouts y respuestas malformadas. Un CRUD que solo maneja el camino feliz es un bug esperando el ticket. Acá cada operación nace sabiendo que puede fallar, y el store refleja esa realidad en vez de fingir que todo sale bien.

Es CRUD honesto: crear, listar, editar y borrar rifas. Las transiciones de estado con reglas duras (`open → closed` a hora fija), la venta de números y los epics son de fases posteriores. Acá se sientan los cimientos del store sobre los que todo lo demás se va a apoyar.

> 📝 **Nota de convención (2026-07-15).** A partir de esta versión, todo el código del curso usa **identificadores en inglés** (`raffle`, `sellNumber`, `/raffles`), mientras que la narrativa, los comentarios y los textos que ve el usuario siguen en **español**. Así el vocabulario del código coincide con el que dejó el contratista que arrancó el sistema en 2019 (ver `00-historia-del-sistema.md` §3). Si venías de una versión anterior de esta fase con nombres en español (`rifasSlice`, `crearRifa`), la tabla de equivalencias está en la nota de traspaso a Fase 5.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Slice `raffleSlice` con Redux Toolkit 1.8.x: estado con lista, flags de carga y error legible, conectado al `json-server` de Fase 3.
- [ ] Cuatro `createAsyncThunk` (`fetchRaffles`, `createRaffle`, `updateRaffle`, `deleteRaffle`) sobre `apiClient`, cada uno con su rama `rejected` desde el día uno.
- [ ] Tabla de rifas (`RaffleTable`) como **class component** con `connect()`, con estados visuales de carga, error, vacío y lista.
- [ ] Formulario de alta/edición (`RaffleForm`) como **componente funcional con hooks**, controlado, reutilizable para crear y editar.
- [ ] Página contenedora (`RafflesPage`) que integra tabla y formulario y coordina qué rifa se edita, **enrutada en `/raffles`** en reemplazo del `RaffleListPage` de Fase 1.
- [ ] 💸 **Pago de deuda:** el listado deja de leer `demoRaffles` y pasa a leer del store. La deuda de datos hardcodeados que arrastra desde la Fase 0 queda saldada para el listado (el detalle se cierra en Fase 5).
- [ ] Manejo explícito del caso "respuesta malformada": el thunk valida la forma antes de confiar en `response.data`.

---

## 🚫 3. Qué queda fuera por ahora

- **Venta de números, unicidad y race conditions** → Fase 5. Acá `numbers` como mucho se lee de refilón; no se vende nada.
- **Epics de redux-observable** → Fase 6. Todo el async de esta fase es `createAsyncThunk`, que alcanza y sobra para un CRUD.
- **Transiciones de estado con reglas duras** (cierre por hora + TZ) → Fase 7. Acá `status` es un campo más del formulario.
- **Validación robusta de formulario** → se deja como deuda 💸 (ver §5). Por ahora, `required` de HTML y poco más.
- **Manejo de 401 en el slice** → no entra nunca. El interceptor de Fase 3 ya tumba la sesión globalmente ante cualquier 401. Duplicarlo en el slice sería un antipatrón (ver §4).

---

## 🧠 4. Conceptos mínimos

### CRUD sobre un backend que falla a propósito

Vienes de Fase 3, donde el mock aprendió a portarse mal. `json-server` corre en `3001` con `CHAOS_LEVEL` (default `low`): inyecta latencia, errores 500, timeouts, respuestas malformadas y 401 sobre rutas protegidas —y `/raffles` es una de ellas—. Esto no es un obstáculo para esta fase: es el escenario de esta fase.

La consecuencia de diseño es concreta y no se negocia: **todo `createAsyncThunk` de rifas maneja `rejected` desde la primera línea que escribes**. Un slice que solo define el caso `fulfilled` no es "una versión simple que después mejoramos"; es un slice roto. Con el caos en `low` ya vas a ver fallos en desarrollo. Si quieres trabajar una feature sin ruido, pon `CHAOS_LEVEL=off` en tu terminal del mock; para estresar la resiliencia, `high`. Lo que no se hace es apagar el caos en el código del proyecto: se apaga en tu entorno, temporalmente.

### Los tres errores que el slice sí maneja, y el que no

No todos los fallos son iguales, y tratarlos igual es un error. El slice de rifas distingue:

| Fallo | Cómo llega al thunk | Quién lo maneja |
|---|---|---|
| **500 / 4xx (no 401)** | Rechazo de axios con `error.response.status` | El `rejected` del thunk de rifas |
| **Timeout** | Rechazo de axios con `error.code === 'ECONNABORTED'` (no hay `response`) | El `rejected` del thunk de rifas |
| **Malformado** | `200 OK` con un body que no tiene la forma esperada | El propio thunk, validando antes de confiar |
| **401** | Response 401 sobre ruta protegida | **El interceptor global de Fase 3**, no el slice |

El 401 es el caso interesante por lo que **no** haces. `apiClient` ya tiene un interceptor de response (Fase 3) que ante cualquier 401 cierra la sesión y redirige a `/login`. Si una petición de rifas devuelve 401, la sesión se cae globalmente y tu thunk ni se entera —el interceptor corta antes—. Meter manejo de 401 en el slice de rifas duplica una responsabilidad que ya vive en un solo lugar, y peor: te deja dos verdades sobre qué significa "no autorizado". El `rejected` de tus thunks maneja los otros tres; del 401 se encarga la capa de transporte. Esa separación es la que hace mantenible el sistema.

> 📝 **Nota de época.** En 2020-2021 lo idiomático con Redux Toolkit ya era `createAsyncThunk`; los thunks a mano (`dispatch(pending()); api.get()...`) todavía se veían mucho en código de 2018-2019. Vas a encontrarte ambos en bases reales. Acá usamos `createAsyncThunk` porque el módulo de rifas es "nuevo", pero A6 muestra el estilo clásico para cuando lo encuentres.

### El fallo más silencioso: la respuesta malformada

De los cuatro fallos, el malformado es el que más caro sale, porque no explota donde ocurre. Un 500 lo ves: axios rechaza y tu `rejected` corre. Un malformado llega como `200 OK` —axios lo da por bueno— y tu código lo procesa como si fuera válido. Si el thunk hace `response.data.map(...)` a ciegas y `response.data` vino como `null` o como un objeto en vez de un array, el `.map` tira `TypeError` en un lugar que no tiene nada que ver con la red. Vas a debuggear el componente veinte minutos antes de darte cuenta de que el problema fue la forma de la respuesta.

La defensa es barata: antes de confiar en `response.data`, verificas que tenga la forma que esperas. Si no la tiene, lo tratas como un error explícito con un mensaje claro, no dejas que reviente río abajo. Lo vas a ver en `fetchRaffles` en la §5.

### Error legible, no error crudo

Un detalle de diseño del estado: guardamos el error como un objeto pequeño y legible (`{ message, type }`), no el objeto de error de axios entero. Dos razones. Primero, el objeto de axios no es serializable del todo y Redux Toolkit se queja si lo metes al store. Segundo, y más importante, la UI necesita distinguir "se cayó el servidor" de "vino mal la respuesta" para mostrar mensajes distintos, y eso se decide una sola vez —en el thunk, que sabe qué pasó— y no en cada componente que lea el error.

> ⚠️ **Ojo con el caso mixto.** La **key** del objeto va en inglés (`message`, `type`), pero el **valor** de `message` es lo que lee el usuario y va en español: `{ message: 'El servidor tardó demasiado', type: 'timeout' }`. El código en inglés, el texto de interfaz en español.

### Convivencia class/hooks en un mismo módulo

Esta fase es una buena excusa para lo que el curso viene prometiendo: código mezclado. La tabla (`RaffleTable`) va como **class component con `connect()`**, al estilo de los módulos viejos del sistema. El formulario (`RaffleForm`) va **funcional con hooks** (`useState`, `useDispatch`, `useSelector`). No es capricho: es exactamente lo que vas a encontrar en una base que evolucionó de 2019 a 2023. Aprender a leer los dos sin marearte —y a que convivan en la misma pantalla despachando al mismo store— es la habilidad real. Si quieres el mapa de equivalencias `connect()` ↔ hooks, está en A6; y si lo que te cuesta es leer la clase en sí —`this.setState`, el ciclo de vida—, el traductor completo está en `A5-class-components-vs-hooks.md`. Para las clases de tabla y formulario de Bootstrap, `A1-bootstrap-4-y-sass.md` §4 y §5.

---

## 💻 5. Implementación y código comentado

Trabajamos en `src/features/raffles/`. Cuatro archivos: el slice, la página contenedora, la tabla (clase) y el formulario (hooks).

### 5.1 El slice — `src/features/raffles/raffleSlice.js`

Empezamos por el store porque es la fuente de verdad; los componentes son consumidores.

```javascript
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import apiClient from '../../api/apiClient'; // ← la instancia de Fase 3, no una nueva

/**
 * Normaliza cualquier error de axios a un objeto legible y serializable.
 * El store nunca guarda el error crudo de axios (no es serializable y RTK
 * protesta). La UI decide qué mostrar según `type`.
 * Nota: las keys van en inglés (message, type); el valor de message va en
 * español porque lo lee el usuario.
 * @param {unknown} error - lo que rechazó axios
 * @returns {{ message: string, type: string }}
 */
function toReadableError(error) {
  // Timeout: axios aborta y no hay response. Es el ECONNABORTED de Fase 3.
  if (error.code === 'ECONNABORTED') {
    return { message: 'El servidor tardó demasiado. Reintenta.', type: 'timeout' };
  }
  // Error HTTP con respuesta (500, 404, etc.). El 401 no llega acá:
  // el interceptor global de Fase 3 lo intercepta y cae la sesión.
  if (error.response) {
    return {
      message: `El servidor respondió ${error.response.status}.`,
      type: 'http',
    };
  }
  // Malformado u otro: lo lanzamos nosotros desde el thunk con un Error normal.
  return { message: error.message || 'Ocurrió un error inesperado.', type: 'unknown' };
}

/**
 * Valida que la respuesta de la lista tenga la forma esperada.
 * El mock malformado de Fase 3 devuelve 200 con un body que no es el array
 * de rifas. Sin esta guarda, el `.map` del componente explota lejos del origen.
 * @param {unknown} data - response.data
 * @returns {boolean}
 */
function isValidRaffleList(data) {
  return Array.isArray(data) && data.every((r) => r && typeof r.id !== 'undefined');
}

// --- Thunks: cada uno con su rama rejected desde el día uno ---

export const fetchRaffles = createAsyncThunk(
  'raffles/fetch',
  async (_, { rejectWithValue }) => {
    try {
      const response = await apiClient.get('/raffles');
      // El malformado llega como 200: validamos ANTES de confiar.
      if (!isValidRaffleList(response.data)) {
        return rejectWithValue({
          message: 'La respuesta de rifas vino con forma inesperada.',
          type: 'malformed',
        });
      }
      return response.data;
    } catch (error) {
      return rejectWithValue(toReadableError(error));
    }
  }
);

export const createRaffle = createAsyncThunk(
  'raffles/create',
  async (raffle, { rejectWithValue }) => {
    try {
      const response = await apiClient.post('/raffles', raffle);
      return response.data; // json-server devuelve la rifa creada con su id
    } catch (error) {
      return rejectWithValue(toReadableError(error));
    }
  }
);

export const updateRaffle = createAsyncThunk(
  'raffles/update',
  async (raffle, { rejectWithValue }) => {
    try {
      const response = await apiClient.put(`/raffles/${raffle.id}`, raffle);
      return response.data;
    } catch (error) {
      return rejectWithValue(toReadableError(error));
    }
  }
);

export const deleteRaffle = createAsyncThunk(
  'raffles/delete',
  async (id, { rejectWithValue }) => {
    try {
      await apiClient.delete(`/raffles/${id}`);
      return id; // devolvemos el id para sacarlo del store sin re-fetch
    } catch (error) {
      return rejectWithValue(toReadableError(error));
    }
  }
);

const initialState = {
  items: [],
  loadingList: false,      // carga de la lista (fetch)
  loadingMutation: false,  // create/update/delete en vuelo
  error: null,             // { message, type } o null
  editingId: null,         // id de la rifa en edición, o null
};

const raffleSlice = createSlice({
  name: 'raffles',
  initialState,
  reducers: {
    // Reducers síncronos: coordinan la UI, no tocan la red.
    selectRaffleToEdit(state, action) {
      state.editingId = action.payload; // payload = id
    },
    cancelEdit(state) {
      state.editingId = null;
    },
    clearError(state) {
      state.error = null;
    },
  },
  extraReducers: (builder) => {
    builder
      // fetch
      .addCase(fetchRaffles.pending, (state) => {
        state.loadingList = true;
        state.error = null;
      })
      .addCase(fetchRaffles.fulfilled, (state, action) => {
        state.loadingList = false;
        state.items = action.payload;
      })
      .addCase(fetchRaffles.rejected, (state, action) => {
        state.loadingList = false;
        // payload viene de rejectWithValue; si no, cae a un genérico.
        state.error = action.payload || { message: 'Error al cargar rifas.', type: 'unknown' };
      })
      // create
      .addCase(createRaffle.pending, (state) => {
        state.loadingMutation = true;
        state.error = null;
      })
      .addCase(createRaffle.fulfilled, (state, action) => {
        state.loadingMutation = false;
        state.items.push(action.payload);
      })
      .addCase(createRaffle.rejected, (state, action) => {
        state.loadingMutation = false;
        state.error = action.payload || { message: 'Error al crear la rifa.', type: 'unknown' };
      })
      // update
      .addCase(updateRaffle.pending, (state) => {
        state.loadingMutation = true;
        state.error = null;
      })
      .addCase(updateRaffle.fulfilled, (state, action) => {
        state.loadingMutation = false;
        const i = state.items.findIndex((r) => r.id === action.payload.id);
        if (i !== -1) state.items[i] = action.payload;
        state.editingId = null; // salimos del modo edición al guardar
      })
      .addCase(updateRaffle.rejected, (state, action) => {
        state.loadingMutation = false;
        state.error = action.payload || { message: 'Error al actualizar.', type: 'unknown' };
      })
      // delete
      .addCase(deleteRaffle.pending, (state) => {
        state.loadingMutation = true;
        state.error = null;
      })
      .addCase(deleteRaffle.fulfilled, (state, action) => {
        state.loadingMutation = false;
        state.items = state.items.filter((r) => r.id !== action.payload);
      })
      .addCase(deleteRaffle.rejected, (state, action) => {
        state.loadingMutation = false;
        state.error = action.payload || { message: 'Error al eliminar.', type: 'unknown' };
      });
  },
});

export const { selectRaffleToEdit, cancelEdit, clearError } = raffleSlice.actions;

// --- Selectores: un solo lugar donde se sabe la forma del state ---
export const selectRaffles = (state) => state.raffles.items;
export const selectEditingRaffle = (state) =>
  state.raffles.items.find((r) => r.id === state.raffles.editingId) || null;
export const selectLoadingList = (state) => state.raffles.loadingList;
export const selectLoadingMutation = (state) => state.raffles.loadingMutation;
export const selectRaffleError = (state) => state.raffles.error;

export default raffleSlice.reducer;
```

> **Detalles con intención.**
> - En `deleteRaffle` devolvemos el `id`, no re-fetcheamos. Menos viajes a un backend que falla = menos superficie de error.
> - `editingId` guarda el **id**, no la rifa entera. La rifa vive en `items`; duplicarla en dos lugares es pedir que se desincronicen. El selector `selectEditingRaffle` la resuelve al vuelo.
> - `error` se limpia en cada `pending`. Si no, un error viejo sobrevive a una operación nueva que sí funcionó.

**El patrón a memorizar:** `pending` prende loading y limpia error → `fulfilled` apaga loading y aplica el cambio al `items` → `rejected` apaga loading y guarda error legible. Los cuatro thunks siguen el mismo molde. Si escribes uno sin `rejected`, no está incompleto: está mal.

Registra el reducer en el store (viene de Fase 2, solo se suma la clave):

```javascript
// src/app/store.js (extracto)
import raffleReducer from '../features/raffles/raffleSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer, // Fase 2
    raffles: raffleReducer, // ← nuevo en Fase 4
  },
});
```

### 5.2 La tabla — `src/features/raffles/RaffleTable.jsx` (class component)

El listado va como clase con `connect()`, al estilo legacy. Dispara el `fetchRaffles` en `componentDidMount` y renderiza los cuatro estados visuales: cargando, error, vacío y lista.

```javascript
import React from 'react';
import { connect } from 'react-redux';
import {
  fetchRaffles,
  deleteRaffle,
  selectRaffleToEdit,
  selectRaffles,
  selectLoadingList,
  selectRaffleError,
} from './raffleSlice';

/**
 * Traduce el status interno (inglés) a la etiqueta que ve el usuario (español).
 * El case va en inglés; el return, en español.
 * @param {string} status
 * @returns {string}
 */
function statusLabel(status) {
  switch (status) {
    case 'draft': return 'Borrador';
    case 'open': return 'Abierta';
    case 'closed': return 'Cerrada';
    case 'resolved': return 'Resuelta';
    case 'settled': return 'Liquidada';
    default: return status;
  }
}

class RaffleTable extends React.Component {
  componentDidMount() {
    // Cargamos al montar. En clase, este es el equivalente al useEffect([]) de hooks.
    this.props.fetchRaffles();
  }

  handleDelete = (id) => {
    // 💸 window.confirm nativo como placeholder. Un modal de Bootstrap sería
    // lo correcto; se deja para una fase de UI o como ejercicio 🔥. En hotfix,
    // esto no rompe nada, solo es feo.
    if (window.confirm('¿Eliminar esta rifa? No se puede deshacer.')) {
      this.props.deleteRaffle(id);
    }
  };

  render() {
    const { raffles, loadingList, error } = this.props;

    if (loadingList) {
      return <div className="alert alert-info">Cargando rifas…</div>;
    }
    if (error) {
      // Mensaje según el type que resolvió el thunk. El usuario no ve el error de axios.
      return (
        <div className="alert alert-danger" role="alert">
          {error.message}
          <button
            className="btn btn-sm btn-outline-danger ml-3"
            onClick={() => this.props.fetchRaffles()}
          >
            Reintentar
          </button>
        </div>
      );
    }
    if (raffles.length === 0) {
      return <div className="alert alert-secondary">No hay rifas todavía. Crea la primera.</div>;
    }

    return (
      <table className="table table-striped table-hover">
        <thead className="thead-dark">
          <tr>
            <th>Nombre</th>
            <th>Lotería</th>
            <th>Cierre</th>
            <th>Precio</th>
            <th>Estado</th>
            <th className="text-right">Acciones</th>
          </tr>
        </thead>
        <tbody>
          {raffles.map((raffle) => (
            <tr key={raffle.id}>
              <td>{raffle.name}</td>
              <td>{raffle.lotteryId}</td>
              <td>{raffle.closesAt}</td>
              <td>{raffle.numberPrice}</td>
              <td>
                <span className="badge badge-pill badge-secondary">
                  {statusLabel(raffle.status)}
                </span>
              </td>
              <td className="text-right">
                <button
                  className="btn btn-sm btn-outline-primary mr-2"
                  onClick={() => this.props.selectRaffleToEdit(raffle.id)}
                >
                  Editar
                </button>
                <button
                  className="btn btn-sm btn-outline-danger"
                  onClick={() => this.handleDelete(raffle.id)}
                >
                  Eliminar
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    );
  }
}

// connect() clásico: mapState + mapDispatch. Compáralo con el useSelector del form.
const mapStateToProps = (state) => ({
  raffles: selectRaffles(state),
  loadingList: selectLoadingList(state),
  error: selectRaffleError(state),
});

const mapDispatchToProps = {
  fetchRaffles,
  deleteRaffle,
  selectRaffleToEdit,
};

export default connect(mapStateToProps, mapDispatchToProps)(RaffleTable);
```

> 📝 **Nota de época.** `mapDispatchToProps` como objeto (no como función con `dispatch =>`) es el atajo que RTK y react-redux ya recomendaban. Cada acción se envuelve en `dispatch` automáticamente. En código más viejo vas a ver la forma larga `dispatch => ({ fetchRaffles: () => dispatch(fetchRaffles()) })`; hacen lo mismo.

### 5.3 El formulario — `src/features/raffles/RaffleForm.jsx` (hooks)

El formulario es funcional con hooks. Sirve para crear y para editar: si el store tiene una rifa en edición, precarga sus valores; si no, arranca vacío.

```javascript
import React, { useState, useEffect } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  createRaffle,
  updateRaffle,
  cancelEdit,
  selectEditingRaffle,
  selectLoadingMutation,
} from './raffleSlice';

// Forma vacía del borrador. status arranca en 'draft' (primer estado del flujo).
const EMPTY_RAFFLE = {
  name: '',
  lotteryId: '',
  closesAt: '',
  numberPrice: '',
  basePrize: '',
  status: 'draft',
};

function RaffleForm() {
  const dispatch = useDispatch();
  const editingRaffle = useSelector(selectEditingRaffle);
  const loadingMutation = useSelector(selectLoadingMutation);

  const [draft, setDraft] = useState(EMPTY_RAFFLE);
  const isEditing = Boolean(editingRaffle);

  // Cuando cambia la rifa en edición, sincronizamos el borrador local.
  // Si es null (nadie edita), volvemos a la forma vacía.
  useEffect(() => {
    setDraft(editingRaffle ? { ...editingRaffle } : EMPTY_RAFFLE);
  }, [editingRaffle]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setDraft((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault(); // sin esto, el navegador recarga y pierdes el SPA
    if (isEditing) {
      dispatch(updateRaffle(draft));
    } else {
      dispatch(createRaffle(draft));
      setDraft(EMPTY_RAFFLE); // limpiamos para la próxima alta
    }
  };

  const handleCancel = () => {
    dispatch(cancelEdit());
    setDraft(EMPTY_RAFFLE);
  };

  return (
    <form onSubmit={handleSubmit} className="card card-body mb-4">
      <h5>{isEditing ? 'Editar rifa' : 'Nueva rifa'}</h5>

      <div className="form-group">
        <label htmlFor="name">Nombre</label>
        <input
          id="name"
          name="name"
          className="form-control"
          value={draft.name}
          onChange={handleChange}
          required // 💸 validación mínima con HTML nativo; ver deuda abajo
        />
      </div>

      <div className="form-row">
        <div className="form-group col-md-6">
          <label htmlFor="lotteryId">Lotería</label>
          <input
            id="lotteryId"
            name="lotteryId"
            className="form-control"
            value={draft.lotteryId}
            onChange={handleChange}
            required
          />
        </div>
        <div className="form-group col-md-6">
          <label htmlFor="closesAt">Cierre (ISO)</label>
          <input
            id="closesAt"
            name="closesAt"
            className="form-control"
            placeholder="2024-03-30T22:00:00-05:00"
            value={draft.closesAt}
            onChange={handleChange}
            required
          />
        </div>
      </div>

      <div className="form-row">
        <div className="form-group col-md-4">
          <label htmlFor="numberPrice">Precio por número</label>
          <input
            id="numberPrice"
            name="numberPrice"
            type="number"
            className="form-control"
            value={draft.numberPrice}
            onChange={handleChange}
            required
          />
        </div>
        <div className="form-group col-md-4">
          <label htmlFor="basePrize">Premio base</label>
          <input
            id="basePrize"
            name="basePrize"
            type="number"
            className="form-control"
            value={draft.basePrize}
            onChange={handleChange}
            required
          />
        </div>
        <div className="form-group col-md-4">
          <label htmlFor="status">Estado</label>
          <select
            id="status"
            name="status"
            className="form-control"
            value={draft.status}
            onChange={handleChange}
          >
            {/* El value va en inglés (enum interno); la etiqueta que ve el
                usuario, en español. El CRUD deja elegir el estado libremente:
                las transiciones con reglas duras son de Fase 7. 💸 */}
            <option value="draft">Borrador</option>
            <option value="open">Abierta</option>
            <option value="closed">Cerrada</option>
            <option value="resolved">Resuelta</option>
            <option value="settled">Liquidada</option>
          </select>
        </div>
      </div>

      <div>
        <button type="submit" className="btn btn-primary" disabled={loadingMutation}>
          {loadingMutation ? 'Guardando…' : isEditing ? 'Guardar cambios' : 'Crear rifa'}
        </button>
        {isEditing && (
          <button type="button" className="btn btn-link" onClick={handleCancel}>
            Cancelar
          </button>
        )}
      </div>
    </form>
  );
}

export default RaffleForm;
```

> **Detalles con intención.**
> - Un solo `RaffleForm` sirve para crear y editar. El modo lo decide el store (`editingId`), no una prop ni una ruta. Menos componentes, una sola verdad sobre "qué se está editando".
> - `numberPrice` y `basePrize` se mandan como los devuelve el `<input type="number">` —string— y json-server los guarda tal cual. **Esto es una simplificación:** el dinero de verdad (enteros, sin floats) es tema de Fase 8. Acá no calculamos con estos valores, solo los persistimos. 💸
> - El `useEffect` que sincroniza `draft` con `editingRaffle` es el puente entre store y estado local. Es el patrón "estado derivado de props/store" bien hecho: dependencia explícita, sin bucles.

### 5.4 La página — `src/features/raffles/RafflesPage.jsx`

Contenedor mínimo que junta las dos piezas —una en clase, otra en hooks— despachando al mismo store sin saber ni les importa el estilo de la otra.

```javascript
import React from 'react';
import RaffleForm from './RaffleForm';
import RaffleTable from './RaffleTable';

function RafflesPage() {
  return (
    <div className="container mt-4">
      <h2 className="mb-4">Rifas</h2>
      <RaffleForm />
      <RaffleTable />
    </div>
  );
}

export default RafflesPage;
```

### 5.5 Conectar la ruta y jubilar los datos hardcodeados 💸 **Pago de deuda**

Falta el paso que hace visible todo lo anterior, y es el que más gente olvida:
**`RafflesPage` no está enrutada.** La ruta `/raffles` sigue apuntando a
`RaffleListPage`, la clase que la Fase 1 conectó a `demoRaffles` —el array
hardcodeado en `src/mock/raffles.js`—. Sin este cambio, escribes el CRUD entero
y no puedes abrirlo en el navegador.

Este es el momento de pagar la deuda 💸 más vieja del curso: la que declaró la
Fase 0 con `demoRaffle`, que la Fase 1 amplió a `demoRaffles`, y que la Fase 2
dejó explícitamente anotada. Recién ahora se puede pagar: la Fase 3 construyó el
backend, pero hasta que no hubo store ni thunks —o sea, hasta esta fase— no
había con qué reemplazar el array.

El cambio es de una línea en el router:

```javascript
// src/AppRouter.jsx (extracto)
// Antes:  <PrivateRoute exact path="/raffles" component={RaffleListPage} />
// Ahora:  la ruta apunta al CRUD real contra json-server.
import RafflesPage from './features/raffles/RafflesPage';

<PrivateRoute exact path="/raffles" component={RafflesPage} />
```

Y a continuación, la parte que hay que hacer con cuidado. `src/mock/raffles.js`
exporta dos cosas y **solo una queda huérfana**:

- `demoRaffles` — ya no lo usa nadie. Se borra.
- `findRaffle(id)` — lo sigue usando `RaffleDetailPage`, que esta fase **no**
  toca.

```javascript
// src/mock/raffles.js
// 💸 DEUDA PARCIALMENTE PAGADA (Fase 4). El listado ya viene del store; el
//    detalle todavía lee de acá. Este archivo NO se borra: borrarlo rompe
//    RaffleDetailPage. Ver A12-mapa-de-deuda-tecnica.md.
export function findRaffle(id) { /* … sin cambios … */ }
```

**Y acá conviene ser honesto sobre lo que queda.** El detalle no se migra en
esta fase, ni en la siguiente. La Fase 7 introduce `activeId` y
`selectActiveRaffle` en `raffleSlice`, que es lo que haría falta — pero tampoco
reescribe `RaffleDetailPage`, porque para entonces la fase tiene otro trabajo
encima (hora dura y polling) y meter una migración de pantalla en medio sería
justo lo que este curso enseña a no hacer.

Así que **la deuda queda declarada, no diferida con vaguedad**: el listado lee
del store, el detalle lee del array, y esa asimetría está registrada en
`A12-mapa-de-deuda-tecnica.md` con su disparador. Es una situación
incómodamente realista: casi todo sistema en migración tiene una pantalla que se
quedó atrás, y lo que distingue a un equipo que la controla de uno que no es
que la primera esté escrita en algún lado.

> ⚠️ **El error que este orden evita.** La tentación es borrar
> `src/mock/raffles.js` de una vez, porque «ya tenemos backend». Hazlo y
> `RaffleDetailPage` deja de compilar — y el fallo aparece en una pantalla que no
> tocaste, lo que te va a costar diez minutos entender de dónde salió. **Pagar
> una deuda es también verificar quién más dependía de ella**, y `grep` es la
> herramienta: antes de borrar un módulo, búscalo entero por el proyecto.

> 🧠 **Y el reflejo de mantenimiento que hay debajo.** Fíjate en la forma de la
> decisión, porque la vas a repetir toda tu carrera: encontraste un módulo
> heredado con dos consumidores, migraste uno, y en vez de forzar el otro
> —«ya que estoy»— dejaste el archivo con un comentario que dice exactamente
> qué queda y cuándo se cierra. Migrar de a un consumidor por vez es más lento
> de leer en el diff y muchísimo más barato de revertir si algo sale mal.

> **Prueba de fuego.** Con el mock levantado y `CHAOS_LEVEL=off`: entra a `/raffles`, crea una rifa, edítala, bórrala. Ahora sube a `CHAOS_LEVEL=high` y recarga varias veces: tienes que ver el `alert-danger` con "Reintentar" cuando cae un 500, "El servidor tardó demasiado" cuando hay timeout, y "forma inesperada" cuando llega un malformado —cada uno con su mensaje, no un genérico—. Si todos los fallos muestran el mismo texto, tu `toReadableError` no está distinguiendo tipos.

### 💸 Deuda técnica declarada en esta fase

Tres deudas intencionales, todas anotadas para pagarse después:

1. **Validación de formulario mínima** (solo `required` de HTML). Lo correcto —validar formato de fecha, que el precio sea positivo, que el nombre no sea solo espacios— se aborda cuando el dominio lo exija (la venta de Fase 5 empuja a validar en serio). En un hotfix, `required` no rompe; solo deja pasar datos flojos.
2. **`window.confirm` para eliminar** en vez de un modal de Bootstrap. Funciona, es feo, se reemplaza en una pasada de UI o como ejercicio 🔥.
3. **Precio y premio como string sin aritmética de dinero.** El manejo serio (enteros, redondeo determinista) es Fase 8. Acá solo se persisten, no se opera con ellos.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Slice que solo maneja `fulfilled`.** El más común y el más caro. Escribes los cuatro thunks, pruebas con `CHAOS_LEVEL=off`, todo anda, cierras el ticket. En producción (o en UAT con caos) el primer 500 deja el `loadingList` en `true` para siempre —nunca lo apagaste en `rejected`— y la UI queda colgada en "Cargando rifas…". *Síntoma:* spinner eterno tras un fallo de red. *Causa:* falta la rama `rejected`. *Fix mínimo:* agregar el `addCase(...rejected)` que apaga el loading y guarda el error. No es refactor: es completar el thunk.

**`.map` a ciegas sobre respuesta malformada.** El thunk hace `response.data.map(...)` sin validar. Con el mock devolviendo un malformado (200 con body que no es array), el `.map` tira `TypeError: response.data.map is not a function`. *Síntoma:* excepción en un lugar que no huele a red; el stack apunta al componente o al thunk, no a axios. *Causa:* confiaste en la forma sin verificarla. *Fix mínimo:* la guarda `isValidRaffleList` antes de usar los datos, y `rejectWithValue` si no pasa.

**Manejar el 401 en el slice.** Alguien "por las dudas" agrega en el `rejected` una rama que detecta 401 y redirige a login. Ahora hay dos lugares que manejan 401: el interceptor global y el slice. *Síntoma:* doble redirect, o un redirect que pelea con el del interceptor. *Causa:* duplicar una responsabilidad que ya vive en la capa de transporte. *Fix:* borrar esa rama del slice. El 401 no es asunto del slice de rifas.

**Perder el `e.preventDefault()` en el submit.** Sin él, el navegador recarga la página al enviar el form, se pierde el estado de Redux y parece que "no pasó nada" o que "se reinició la app". *Síntoma:* flash de recarga al crear una rifa. *Causa:* form HTML nativo haciendo su trabajo por defecto. *Fix:* `e.preventDefault()` en `handleSubmit`.

### Pieza forense de esta fase — Redux DevTools: time-travel y replay

Esta es la fase donde Redux DevTools se vuelve tu mejor herramienta. Con el store ya poblado de acciones reales, aprende a leerlas.

Abre la extensión Redux DevTools con la app corriendo y haz una operación —crea una rifa—. Vas a ver la secuencia de acciones despachadas: `raffles/create/pending` → `raffles/create/fulfilled`. Selecciona cada una y mira el panel **Diff**: te muestra exactamente qué cambió en el state con esa acción. En `pending` vas a ver `loadingMutation: false → true`; en `fulfilled`, el nuevo item empujado a `items` y el loading de vuelta en `false`.

Ahora lo interesante, con `CHAOS_LEVEL=high`. Recarga hasta que un `fetchRaffles` falle. Vas a ver `raffles/fetch/pending` → `raffles/fetch/rejected`. Selecciona el `rejected` y mira el Diff: el `error` pasó de `null` al objeto legible que armó tu thunk, y `loadingList` volvió a `false`. **Ahí está la prueba visual de que tu rama `rejected` funciona.** Si el `loadingList` quedó en `true` después del rejected, encontraste el bug del spinner eterno sin siquiera tocar la UI.

El **time-travel**: haz click en una acción vieja de la lista. La app entera vuelve a ese estado —la tabla se re-renderiza con los datos de ese momento—. Es tu máquina del tiempo para entender "¿en qué momento se rompió el estado?". Y el **replay**: puedes re-despachar una secuencia de acciones para reproducir un camino exacto. En la Fase 5, cuando aparezcan las race conditions de venta, esto va a ser la diferencia entre "no puedo reproducirlo" y "lo tengo".

> 💡 **Truco.** Con el caos en `high`, deja Redux DevTools abierto y anda haciendo operaciones. Cada `rejected` que veas es un fallo que tu slice manejó bien. Es la forma más rápida de ganar confianza en que la resiliencia funciona: no la deduces, la ves.

**Rompe a propósito y observa:** comenta la línea del `addCase(fetchRaffles.rejected, ...)` en el slice, pon `CHAOS_LEVEL=high`, y fuerza un fallo de carga. Mira en DevTools cómo `loadingList` queda en `true` y no baja nunca. Después descomenta y comprueba que vuelve a bajar. Esa es la firma visual del bug más común de la fase.

> 📓 De esta fase salen los incidentes **09** y **10** de `cuaderno-incidentes.md`. El 10 es el que acabas de provocar; el 09 es más chico y más desconcertante, porque su síntoma no se parece en nada a su causa.

---

## 🧪 7. Ejercicios (28)

**🟢 Fácil (1–8)**

1. Levanta el mock con `CHAOS_LEVEL=off`, entra a `/raffles` y crea tres rifas distintas. Confirma que aparecen en la tabla.
2. Edita una rifa: cambia su nombre y su estado. Verifica que la tabla refleja el cambio sin recargar.
3. Elimina una rifa y confirma que desaparece de la tabla y del store (míralo en Redux DevTools).
4. En Redux DevTools, despacha una creación y describe en una frase qué muestra el panel Diff en el `pending` vs el `fulfilled`.
5. Agrega una columna "Premio base" a `RaffleTable` mostrando `raffle.basePrize`.
6. Cambia el texto del estado vacío ("No hay rifas todavía…") por otro y confirma que aparece cuando la lista está vacía.
7. Identifica en el código cuál de los dos componentes (tabla o formulario) es class y cuál es funcional, y qué API de Redux usa cada uno (`connect()` vs hooks).
8. Pon `CHAOS_LEVEL=low` y recarga `/raffles` varias veces hasta ver el `alert-danger`. Anota qué mensaje mostró.

**🟡 Intermedio (9–17)**

9. Agrega un selector `selectRaffleCount` que devuelva `state.raffles.items.length` y muéstralo en un badge junto al título "Rifas".
10. Haz que el botón "Crear rifa" quede deshabilitado también cuando `name` esté vacío (además del `required`), usando estado del componente.
11. Agrega un thunk `fetchRaffleById` que traiga una sola rifa (`GET /raffles/:id`) con su rama `rejected`. No lo conectes a UI todavía; solo el slice.
12. En `toReadableError`, agrega un cuarto type `'network'` para el caso en que no hay `response` ni `ECONNABORTED` (error de red puro) y dale un mensaje propio.
13. Haz que al eliminar una rifa que estaba en edición, el formulario vuelva solo a modo "Nueva rifa" (pista: `editingId` apunta a un id que ya no existe).
14. Agrega un filtro de texto sobre la tabla (input controlado) que muestre solo las rifas cuyo `name` contenga lo tipeado. Frontend puro, sin tocar el backend.
15. Muestra el `type` del error además del mensaje, en letra chica, dentro del `alert-danger`. Verifica que distintos fallos muestran distinto type.
16. Escribe un JSDoc completo para `createRaffle` documentando el shape del parámetro `raffle`.
17. Con `CHAOS_LEVEL=high`, reproduce un timeout y confirma en DevTools que el `error.type` guardado es `'timeout'` y no `'http'`.

**🟠 Difícil (18–24)**

18. Reproduce el bug del spinner eterno: comenta la rama `rejected` de `fetchRaffles`, fuerza un fallo con caos, y documenta el síntoma exacto que ves en la UI y en DevTools. Después arréglalo.
19. Reproduce el malformado: configura el mock para que `/raffles` devuelva `200` con `{ "error": "oops" }` en vez de un array. Confirma que la guarda `isValidRaffleList` lo atrapa y muestra "forma inesperada" en vez de explotar. Quita la guarda y observa el `TypeError`.
20. Agrega manejo optimista al eliminar: saca la rifa de `items` en el `pending` y, si el thunk falla (`rejected`), vuelve a insertarla. ¿Qué problema de UX resuelve y cuál introduce?
21. Diagnóstico: te pasan un slice donde `createRaffle.fulfilled` hace `state.items = action.payload` en vez de `state.items.push(action.payload)`. Sin correrlo, explica qué bug produce y cómo se manifiesta en la tabla.
22. Con el caos en `high`, provoca un 401 sobre `/raffles` (simulando token vencido). Confirma por comportamiento que la sesión se cae y te manda a login **sin que el slice de rifas maneje el 401**. Explica qué capa lo hizo.
23. Agrega un contador de reintentos: cada vez que el usuario toca "Reintentar" tras un error de carga, incrementa un contador en el state y muéstralo. ¿Va en el slice o en el componente? Justifica.
24. Time-travel: crea tres rifas, edita una, elimina otra. En Redux DevTools, viaja a la acción anterior a la eliminación y describe qué muestra la tabla. Explica por qué el time-travel puede "resucitar" visualmente una rifa borrada.

**🔴 Muy difícil (25–28)**

25. Diagnóstico esquivo: un compañero reporta que "a veces al crear una rifa aparece duplicada en la tabla". Con `CHAOS_LEVEL=high`, reprodúcelo (pista: doble submit rápido mientras `loadingMutation` no bloquea el botón). Propón el fix mínimo y explica por qué el `disabled={loadingMutation}` no siempre alcanza.
26. Integra tabla y formulario para que, al editar una rifa y guardar mientras el caos dispara un `rejected` en el `updateRaffle`, el formulario **no** pierda los datos que el usuario había cargado. Diseña el manejo de estado que lo garantiza.
27. Escribe una prueba de regresión conceptual (en prosa o pseudo-test con Jest 26 + RTL 11) que falle si alguien vuelve a quitar la rama `rejected` de `fetchRaffles`. ¿Qué assert la hace fallar exactamente?
28. Refactor vs hotfix: te dan 30 minutos para arreglar el spinner eterno en PROD. Escribe el hotfix mínimo (una línea o dos) y, aparte, describe el refactor "correcto" que harías con más tiempo y pruebas. Marca cuál va en el hotfix y cuál queda como 💸.

**🔥 Opcionales**

- 🔥 Reescribe `RaffleTable` de class component a funcional con hooks (`useEffect` + `useSelector` + `useDispatch`). Compara línea a línea con la versión de clase y anota las equivalencias (ver A6).
- 🔥 Reemplaza el `window.confirm` de eliminación por un modal de Bootstrap 4 controlado por estado.
- 🔥 Migra el slice a `createEntityAdapter` (RTK 1.8) para normalizar `items` por id. ¿Qué selectores te regala gratis y qué cambia en los `extraReducers`?

---

## 📚 8. Referencias

**Documentación oficial**

- https://redux-toolkit.js.org/api/createAsyncThunk — patrón `pending/fulfilled/rejected` y `rejectWithValue`. Fíjate en la versión: el proyecto usa RTK **1.8.x**; la doc actual puede mostrar APIs más nuevas.
- https://redux-toolkit.js.org/api/createSlice — `reducers` vs `extraReducers` con el callback `builder`.
- https://react-redux.js.org/api/connect — `connect()`, `mapStateToProps`, `mapDispatchToProps` como objeto. Es la API que usa la tabla.
- https://react-redux.js.org/api/hooks — `useSelector` y `useDispatch`, la API que usa el formulario.
- https://legacy.reactjs.org/docs/react-component.html — `componentDidMount` y el ciclo de vida de clases (React 16). Es el equivalente al `useEffect([])` del form.
- https://getbootstrap.com/docs/4.6/content/tables/ y https://getbootstrap.com/docs/4.6/components/forms/ — clases de tabla y formulario usadas acá.

**Video / apoyo**

- Redux Toolkit — "Async Logic and Data Fetching" del tutorial oficial de Redux (busca "Redux Essentials Part 5" en redux.js.org). Cubre `createAsyncThunk` con el mismo patrón de esta fase.

**Orden de lectura sugerido:** `createAsyncThunk` (para entender las tres ramas) → `createSlice` con `extraReducers` (para ver dónde se enganchan) → `connect()` y hooks de react-redux (para comparar los dos componentes) → volver al `raffleSlice.js` de la §5.

> ⚠️ Las URLs, títulos y números de sección pueden haber cambiado o apuntar a versiones más nuevas que las fijadas. Verifica siempre que lo que lees aplique a RTK 1.8, react-redux 7.2 y React 16.14. Cuando la doc oficial muestre una API que no existe en estas versiones, es señal de que estás leyendo material más nuevo.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Ya tienes el primer CRUD real del sistema: un slice de Redux Toolkit que crea, lista, edita y borra rifas contra un backend que falla a propósito, con cada operación manejando sus tres modos de fallo desde el día uno y sin duplicar el manejo de 401 que ya vive en la capa de transporte. La tabla en clase y el formulario en hooks conviven despachando al mismo store —tu primera prueba de que el código mezclado no muerde si sabes leerlo—. Y Redux DevTools dejó de ser un adorno para volverse tu instrumento de diagnóstico.

La Fase 5 sube la apuesta con lo que hace difícil de verdad a este dominio: la **venta de números**. Vas a construir el tablero 0000-9999, la reserva temporal y —el corazón del asunto— la **unicidad estricta**: dos personas no pueden comprar el mismo número. Ahí aparecen las race conditions que el CRUD tranquilo de esta fase todavía no tenía, y el time-travel de Redux DevTools que aprendiste acá se vuelve la herramienta para cazarlas. El store que armaste es la base sobre la que se apoya todo eso.

> **La señal de que quedó bien:** si subo el caos a `high`, recargo diez veces, y cada fallo distinto me muestra su propio mensaje mientras el store nunca queda colgado en "cargando" —entonces el CRUD no es de juguete, aguanta el mundo real.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-04-rifas-crud -m "F4 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f04: …`) y los de ejercicio su
> número (`f04 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f04/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve
> secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y
> porque no debe competir con el cierre.

- **El `window.confirm` 💸 se declara acá y se mapea en Fase 11, pero sin
  disparador.** La tabla de deuda de Fase 11 pide "qué la vuelve exigible" y esta
  entrada no lo tiene escrito en su fase de origen. → Agregar la línea de
  disparador (por ejemplo: "cuando el borrado deje de ser reversible").
- **Validación de formulario 💸 mínima**, solo `required` de HTML. → Ejercicio 🔥
  o sección en `A2-mini-design-system.md`, según dónde caiga mejor el estilo de
  los mensajes de error.
- **"Manejar el 401 en el slice" es el mejor ejemplo de responsabilidad
  duplicada** de todo el curso, pero se solapa con el incidente 08 de Fase 3. →
  Mantener el incidente en Fase 3 y que acá quede como error común con
  referencia cruzada, sin desarrollar el diagnóstico dos veces.
- **Los cuatro thunks comparten estructura de `extraReducers`.** Un helper
  reduciría el ruido, pero también escondería el patrón que la fase enseña. →
  Decisión pedagógica: se deja explícito a propósito; conviene decirlo en el texto.

### Reservas para el cuaderno de incidentes

Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya
está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna.

- **09** — *Guardo la rifa, se recarga la página y pierdo todo* · Estado (store) · 🟢.
  Sale del `e.preventDefault()` olvidado en el submit. Fácil de arreglar, muy
  formativo: el síntoma ("se borró todo") no se parece en nada a la causa.
- **10** — *La lista de rifas se queda cargando para siempre* · Estado (store) · 🟡.
  Sale del error común #1: el slice que solo maneja `fulfilled`. Con
  `CHAOS_LEVEL=off` no se reproduce nunca, y esa es la mitad de la lección.
