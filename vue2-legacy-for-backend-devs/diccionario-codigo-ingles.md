# 📖 Diccionario de código: español → inglés
## Tutorial React 16 — Rifas y chances

Documento operativo, complementario a `GUIA-DE-ESTILO-Y-CONVENCIONES.md`
§4. Úsalo mientras escribís código nuevo o ajustás una fase ya escrita.
Regla de una línea: **el código en inglés, todo lo demás (comentarios,
narrativa, textos de interfaz) en español.**

---

## 1. Qué se traduce y qué no (referencia rápida)

| Cosa | ¿Traducir a inglés? | Ejemplo |
|---|---|---|
| `function nombreDeFuncion()` | ✅ Sí | `function sellNumber()` |
| `const variable = ...` | ✅ Sí | `const isLoading = false` |
| Propiedad de estado / prop | ✅ Sí | `state.raffles.items`, `<RaffleForm initialRaffle={...} />` |
| Endpoint / ruta de API | ✅ Sí | `apiClient.get('/raffles')` |
| Nombre de componente / archivo | ✅ Sí | `RaffleTable.jsx` |
| Nombre de slice / epic | ✅ Sí | `raffleSlice.js`, `pollingEpic.js` |
| `action type` (Redux clásico) | ✅ Sí | `SELL_NUMBER` |
| Valor de enum / status interno | ✅ Sí | `status: 'open'` |
| Clase CSS/Sass propia del proyecto | ✅ Sí | `.raffle-card` |
| `data-testid` | ✅ Sí | `data-testid="number-sold"` |
| `// comentario explicando el porqué` | ❌ No | se queda en español |
| Texto que ve el usuario (`<button>`, `alert`, `label`) | ❌ No | `"Vender número"` |
| Valor de un mensaje de error legible | ❌ No | `{ message: 'No se pudo cargar la rifa' }` — la *key* en inglés, el *valor* en español |
| `case` de un mapeo estado→etiqueta | ⚠️ Parcial | `case 'open': return 'Abierta'` — el `case` en inglés, el `return` (lo que ve el usuario) en español |
| Nombre del dominio en la narrativa/prosa | ❌ No | seguís hablando de "rifa", "número", "liquidación" |
| Nombres de fase, archivo `.md`, títulos | ❌ No | siguen en español (`fase-05-venta-de-numeros.md`) |

---

## 2. Diccionario del dominio (rifas y chances)

### 2.1 Entidades principales

| Español | Inglés (código) |
|---|---|
| rifa / rifas | `raffle` / `raffles` |
| número / números | `number` / `numbers` |
| participante | `participant` |
| resultado (de sorteo) | `result` / `drawResult` |
| liquidación | `settlement` |
| pago | `payment` |
| indicador / métrica | `metric` |
| dashboard | `dashboard` |
| sorteo | `draw` |
| ganador | `winner` |

### 2.2 Estados del flujo principal

| Español | Inglés (código) | Nota |
|---|---|---|
| borrador | `draft` | valor de enum, no de UI |
| abierta | `open` | idem |
| cerrada | `closed` | idem |
| resuelta | `resolved` | idem |
| liquidada | `settled` | idem |

> ⚠️ La **etiqueta que ve el usuario** ("Abierta", "Cerrada") sigue en
> español y vive separada del valor interno, típicamente en una función
> de mapeo: `function statusLabel(status) { switch (status) { case 'open': return 'Abierta'; ... } }`.

### 2.3 Estados de un número

| Español | Inglés (código) |
|---|---|
| disponible | `available` |
| reservado | `reserved` |
| vendido | `sold` |
| expirado (reserva) | `expired` |

### 2.4 Verbos de negocio

| Español | Inglés (código) |
|---|---|
| vender | `sell` |
| reservar | `reserve` |
| expirar | `expire` |
| liquidar | `settle` |
| sortear | `draw` |
| consultar resultado | `checkResult` / `fetchResult` |

### 2.5 Campos frecuentes

| Español | Inglés (código) |
|---|---|
| nombre | `name` |
| estado | `status` |
| tipo | `type` |
| mensaje | `message` |
| premio / premio base | `prize` / `basePrize` |
| hora de cierre | `closingTime` / `closesAt` |
| hora de apertura | `openingTime` / `opensAt` |
| zona horaria | `timezone` |
| fecha de creación | `createdAt` |
| fecha de actualización | `updatedAt` |

---

## 3. Diccionario técnico general (frontend / store / auth)

| Español | Inglés (código) |
|---|---|
| usuario | `user` |
| sesión | `session` |
| iniciar sesión | `login` |
| cerrar sesión | `logout` |
| cargando / carga | `loading` |
| guardando | `saving` |
| formulario | `form` |
| validar | `validate` |
| enviar (submit) | `submit` |
| cancelar | `cancel` |
| reintentar | `retry` |
| obtener / traer | `get` / `fetch` |
| crear | `create` |
| actualizar | `update` |
| eliminar / borrar | `delete` |
| listar | `list` |
| buscar | `search` |
| en edición | `editing` |
| lista vacía | `empty` |

### 3.1 Verbos técnicos habituales para componer nombres

Combina un verbo con el sustantivo del dominio: `get` + `Raffles` →
`getRaffles`; `sell` + `Number` → `sellNumber`. Los verbos técnicos más
usados en el curso:

`get`, `fetch`, `create`, `update`, `delete`, `list`, `search`, `select`,
`sell`, `reserve`, `expire`, `settle`, `check`, `poll`, `subscribe`,
`unsubscribe`, `cancel`, `retry`, `validate`.

---

## 4. Convenciones de nombrado por tipo de artefacto

| Artefacto | Convención | Ejemplo |
|---|---|---|
| Componente (clase o función) | `PascalCase` | `RaffleTable`, `RaffleForm`, `SaleWizard` |
| Archivo de componente | igual al componente | `RaffleTable.jsx` |
| Función / variable | `camelCase` | `sellNumber`, `isRaffleOpen` |
| Slice | `<dominio>Slice.js` | `raffleSlice.js`, `saleSlice.js` |
| Thunk | verbo + dominio | `fetchRaffles`, `createRaffle`, `sellNumber` |
| Epic | `<propósito>Epic` | `pollingEpic`, `saleEpic` |
| Action type (Redux clásico) | `SNAKE_CASE` | `SELL_NUMBER`, `STOP_POLLING`, `LOGOUT` |
| Selector | `select` + dominio | `selectRaffleCount`, `selectOpenRaffles` |
| Endpoint REST | sustantivo plural | `/raffles`, `/raffles/:id/numbers`, `/results` |
| Constante de configuración | `SCREAMING_SNAKE_CASE` | `CHAOS_LEVEL`, `POLLING_INTERVAL_MS` |
| `data-testid` | kebab-case descriptivo | `data-testid="number-sold"` |

---

## 5. Ejemplos antes/después (basados en fases ya escritas)

Estos ejemplos parten de identificadores reales usados en las fases 4 y 5
del proyecto, para que sirvan de referencia directa al ajustarlas.

### ❌ Antes (español)
```javascript
// src/features/rifas/rifasSlice.js
const rifasSlice = createSlice({
  name: 'rifas',
  initialState: { items: [], loadingList: false, loadingMutation: false, error: null },
  reducers: {},
  extraReducers: (builder) => {
    builder.addCase(fetchRifas.fulfilled, (state, action) => {
      // guarda el listado ya validado
      state.items = action.payload;
    });
  }
});

export const crearRifa = createAsyncThunk('rifas/crear', async (rifa) => {
  const response = await apiClient.post('/rifas', rifa);
  return response.data;
});

function aErrorLegible(error) {
  if (error.code === 'ECONNABORTED') {
    return { mensaje: 'El servidor no respondió a tiempo', tipo: 'timeout' };
  }
  return { mensaje: 'Ocurrió un error inesperado', tipo: 'http' };
}
```

### ✅ Después (inglés en código, español en comentarios y UI)
```javascript
// src/features/raffles/raffleSlice.js
const raffleSlice = createSlice({
  name: 'raffles',
  initialState: { items: [], loadingList: false, loadingMutation: false, error: null },
  reducers: {},
  extraReducers: (builder) => {
    builder.addCase(fetchRaffles.fulfilled, (state, action) => {
      // guarda el listado ya validado
      state.items = action.payload;
    });
  }
});

export const createRaffle = createAsyncThunk('raffles/create', async (raffle) => {
  const response = await apiClient.post('/raffles', raffle);
  return response.data;
});

function toReadableError(error) {
  if (error.code === 'ECONNABORTED') {
    // el valor del mensaje queda en español: lo lee el usuario final
    return { message: 'El servidor no respondió a tiempo', type: 'timeout' };
  }
  return { message: 'Ocurrió un error inesperado', type: 'http' };
}
```

### ❌ Antes (español)
```javascript
class RifasTabla extends React.Component {
  render() {
    if (this.props.loadingList) return <Spinner />;
    if (this.props.error) return <div className="alert-danger">{this.props.error.mensaje}</div>;
    if (this.props.rifas.length === 0) return <p>No hay rifas todavía…</p>;
    return (
      <table>
        {this.props.rifas.map((rifa) => (
          <tr key={rifa.id}><td>{rifa.nombre}</td><td>{rifa.estado}</td></tr>
        ))}
      </table>
    );
  }
}
```

### ✅ Después
```javascript
class RaffleTable extends React.Component {
  render() {
    if (this.props.loadingList) return <Spinner />;
    if (this.props.error) return <div className="alert-danger">{this.props.error.message}</div>;
    if (this.props.raffles.length === 0) return <p>No hay rifas todavía…</p>;
    return (
      <table>
        {this.props.raffles.map((raffle) => (
          <tr key={raffle.id}><td>{raffle.name}</td><td>{statusLabel(raffle.status)}</td></tr>
        ))}
      </table>
    );
  }
}
```

Notá que `"No hay rifas todavía…"` **no cambia**: es texto de interfaz.

### ❌ Antes (epic de venta)
```javascript
const venderNumeroEpic = (action$, state$) =>
  action$.pipe(
    ofType(VENDER_NUMERO),
    mergeMap((action) =>
      api.post('/vender', action.payload).pipe(
        map((res) => vendidoExitoso(res)),
        catchError((err) => of(vendidoFallo(err)))
      )
    )
  );
```

### ✅ Después
```javascript
const sellNumberEpic = (action$, state$) =>
  action$.pipe(
    ofType(SELL_NUMBER),
    mergeMap((action) =>
      api.post('/sell', action.payload).pipe(
        map((res) => sellSucceeded(res)),
        catchError((err) => of(sellFailed(err)))
      )
    )
  );
```

---

## 6. Matriz de verificación por fase (copiar para ajustar fases existentes)

```markdown
| Fase | Slices/Thunks | Componentes | Endpoints | Enums/status | Comentarios ✅ | UI ✅ | Estado |
|---|---|---|---|---|---|---|---|
| fase-00-setup-hola-mundo-cra.md | — | — | — | — | ✅ | ✅ | TODO |
| fase-01-estructura-base-router-5.md | — | — | — | — | — | — | TODO |
| fase-03-mock-api-express-caos.md | — | — | — | — | — | — | TODO |
| fase-04-rifas-crud.md | — | — | — | — | — | — | TODO |
| fase-05-venta-de-numeros.md | — | — | — | — | — | — | TODO |
```

Marca ✅ en cada columna cuando confirmes que ese aspecto del archivo ya
está en inglés (o, para las columnas de comentarios/UI, que siguen
intactos en español).

---

## 7. Checklist antes de dar por ajustada una fase

- [ ] Ningún `function`, `const`, `class` o `useState` con nombre en español.
- [ ] Ningún endpoint (`apiClient.get/post/put/delete`) con ruta en español.
- [ ] Ningún valor de `status`/`type`/enum interno en español.
- [ ] Nombres de componente y archivo en `PascalCase` inglés.
- [ ] `action types` en `SCREAMING_SNAKE_CASE` inglés.
- [ ] Comentarios de código 100% en español, explicando el porqué.
- [ ] Textos de interfaz (botones, labels, alertas, placeholders) 100% en español.
- [ ] Narrativa del archivo (títulos, párrafos, ejercicios) sin cambios de contenido, solo referencias de código actualizadas.
- [ ] Consistencia con otras fases ya ajustadas (mismo nombre de thunk/slice/endpoint para el mismo concepto).
- [ ] Ejercicios que mencionan identificadores de código actualizados al nuevo nombre.

---

## 8. Duda frecuente: ¿y si el sistema real usa otro nombre?

No importa. Este diccionario fija el vocabulario del **dominio pedagógico**
(rifas y chances), no el del sistema real bajo NDA. La regla de idioma
(código en inglés) sí refleja una característica real del sistema, pero los
nombres concretos (`raffle`, `sellNumber`, `/raffles`) son inventados para
este curso y no deben acercarse al vocabulario del dominio real.
