# 📖 Diccionario de código: español → inglés
## Tutorial React 16 — Rifas y chances

Documento operativo, complementario a `prompts/guia-de-estilo-y-convenciones.md`
§4. Úsalo mientras escribes código nuevo o ajustas una fase ya escrita.
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
| Nombre del dominio en la narrativa/prosa | ❌ No | sigues hablando de "rifa", "número", "liquidación" |
| Nombres de fase, archivo `.md`, títulos | ❌ No | siguen en español (`05-venta-de-numeros.md`) |

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
| premio pagado | `prizeAmount` |
| precio por número | `numberPrice` |
| total recaudado | `totalCollected` |
| margen | `margin` |
| hora de cierre | `closesAt` |
| hora de apertura | `opensAt` |
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
| Epic | `<propósito>Epic` | `pollingEpic`, `sellNumberEpic` |
| Action type (Redux clásico) | `SNAKE_CASE` | `SELL_NUMBER`, `STOP_POLLING`, `LOGOUT` |
| Selector | `select` + dominio | `selectRaffleCount`, `selectOpenRaffles` |
| Endpoint REST | sustantivo plural | `/raffles`, `/raffles/:id/numbers`, `/results` |
| Constante de configuración | `SCREAMING_SNAKE_CASE` | `CHAOS_LEVEL`, `POLLING_INTERVAL_MS` |
| `data-testid` | kebab-case descriptivo | `data-testid="number-sold"` |

**Extensiones de archivo.** Todo archivo que contenga JSX va `.jsx`
(`RaffleTable.jsx`, `NumberCell.jsx`, `DashboardPage.jsx`). Todo archivo que no
lo contenga va `.js` (`raffleSlice.js`, `pollingEpic.js`, `money.js`). Las dos
excepciones son `src/index.js` y `src/App.js`, que llegan así en el template de
CRA 4 y no se renombran: tocar los puntos de entrada para uniformar una
extensión es exactamente la clase de cambio de riesgo sin beneficio que este
curso enseña a no hacer.

**Rutas canónicas del proyecto**, para que dos fases no ubiquen el mismo archivo
en dos sitios:

- `src/api/` — instancias HTTP compartidas: `apiClient.js` (puerto 3001) y
  `apiLottery.js` (puerto 3002).
- `src/app/` — cableado de la aplicación: `store.js`, `rootEpic.js`,
  `history.js`.
- `src/features/<dominio>/` — todo lo de un dominio junto: slice, componentes,
  selectores, funciones puras, y sus epics en `epics/`.
- `src/pages/` — páginas de la era 2019 que todavía no se movieron a `features/`
  (`LoginPage.jsx`, `NotFoundPage.jsx`, …). Que convivan dos organizaciones es
  herencia, no desorden: ver `00-historia-del-sistema.md` §3.
- `src/components/` — componentes compartidos entre dominios (`Navbar.jsx`,
  `AppLayout.jsx`, `RaffleCard.jsx`).
- `mock/` — el backend: `server.js`, `chaosMiddleware.js`,
  `rafflesNumbersRouter.js`, `db.json` y `lottery/server.js`.

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

Nota que `"No hay rifas todavía…"` **no cambia**: es texto de interfaz.

### ❌ Antes (epic de venta)
```javascript
const venderNumeroEpic = (action$, state$) =>
  action$.pipe(
    ofType(VENDER_NUMERO),
    mergeMap((action) =>
      api.post(`/rifas/${action.payload.rifaId}/numeros/${action.payload.numero}/vender`).pipe(
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
      api.post(`/raffles/${action.payload.raffleId}/numbers/${action.payload.number}/sell`).pipe(
        map((res) => sellSucceeded(res)),
        catchError((err) => of(sellFailed(err)))
      )
    )
  );
```

---

## 6. Matriz de verificación por fase (copiar para ajustar fases existentes)

```markdown
| Archivo | Identificadores | Endpoints | Enums/status | Comentarios ✅ | UI ✅ | Estado |
|---|---|---|---|---|---|---|
| 00-setup-hola-mundo-cra.md | ✅ | — | ✅ | ✅ | ✅ | Ajustada |
| 01-estructura-base-router-5.md | ✅ | — | ✅ | ✅ | ✅ | Ajustada |
| 02-autenticacion-minima.md | ✅ | ✅ | ✅ | ✅ | ✅ | Ajustada |
| 03-mock-api-express-caos.md | ✅ | ✅ | ✅ | ✅ | ✅ | Ajustada |
| 04-rifas-crud.md | ✅ | ✅ | ✅ | ✅ | ✅ | Ajustada |
| 05-venta-de-numeros.md | ✅ | ✅ | ✅ | ✅ | ✅ | Ajustada |
| 06-redux-observable-a-fondo.md | ✅ | ✅ | ✅ | ✅ | ✅ | Ajustada |
| 07-cierre-polling-resultado.md | ✅ | ✅ | ✅ | ✅ | ✅ | Ajustada |
| 08-liquidacion-calculo-premio.md | ✅ | ✅ | ✅ | ✅ | ✅ | Ajustada |
| 09-dashboard.md | ✅ | ✅ | ✅ | ✅ | ✅ | Ajustada |
| 10-testing-minimo.md | ✅ | ✅ | ✅ | ✅ | ✅ | Ajustada |
| 11-cierre-puente-react-moderno.md | ✅ | ✅ | ✅ | ✅ | ✅ | Ajustada |
| A1–A13 | ✅ | ✅ | ✅ | ✅ | ✅ | Ajustados |
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

## 7bis. Anexo del track BE 🔥 — el mismo dominio, del otro lado del cable

Este anexo aplica al track opcional de backend (`be00`–`be09`). No cambia
ninguna decisión de arriba: la extiende a Go y a SQL. La regla que lo gobierna
es una sola y no admite excepción:

> 🧭 **`Raffle` significa exactamente lo mismo en el slice de React, en el struct
> de Go y en la tabla de Postgres.** El día que signifiquen cosas distintas, el
> contrato deja de ser verificable y el track pierde su razón de ser.

### 7bis.1 Las entidades en las tres capas

| Concepto | Go (tipo / campo) | SQL (tabla / columna) |
|---|---|---|
| Rifa | `Raffle`, `raffle` | `raffles` |
| Número de una rifa | `RaffleNumber` | `raffle_numbers` |
| Participante | `Participant` | `participants` |
| Venta (el hecho) | `Sale`, `sellNumber` | `sales` |
| Liquidación | `Settlement` | `settlements` |
| Pago del premio | `PrizePayout` | `prize_payouts` |
| Usuario | `User` | `users` |
| Resultado de lotería | `LotteryResult` | — (viene del `3002`, no se persiste) |

Los campos siguen el diccionario de §2.5 **con la traducción de convención que
cada capa exige, y nada más**: `closesAt` en JSON y en el struct de Go
(`ClosesAt time.Time` con etiqueta `json:"closesAt"`), `closes_at` en la
columna. La etiqueta JSON es la frontera del contrato: **es la que el frontend
ve, y por lo tanto es la que no se puede cambiar**.

### 7bis.2 Convenciones de nombrado en Go

| Artefacto | Convención | Ejemplo |
|---|---|---|
| Paquete | sustantivo corto, minúscula, singular | `raffle`, `auth`, `chaos` |
| Tipo exportado | `PascalCase` | `Raffle`, `SellNumberRequest` |
| Campo de struct | `PascalCase` + etiqueta JSON en `camelCase` | `ClosesAt` / `json:"closesAt"` |
| Handler HTTP | `<Verbo><Recurso>Handler` | `SellNumberHandler`, `ListRafflesHandler` |
| Método de servicio | verbo + dominio, igual que el thunk | `SellNumber`, `CreateRaffle`, `SettleRaffle` |
| Interfaz de persistencia | `<Dominio>Store` | `RaffleStore`, `UserStore` |
| Implementación concreta, un motor | `<motor><Dominio>Store` | `postgresRaffleStore` |
| Implementación concreta, los dos motores | `sqlStore` en el paquete del dominio | `raffle.sqlStore` |
| Error de dominio | `Err<Caso>` | `ErrNumberAlreadySold`, `ErrRaffleClosed` |
| Función de aritmética de dinero | el mismo nombre que en `settlementMath.js` | `TotalCollected`, `PrizeAmount`, `Margin`, `PrizeShare` |
| Tabla y columna SQL | `snake_case`, tabla en plural | `raffle_numbers`, `sold_at` |
| Archivo de migración | `NNNNNN_verbo_objeto.up.sql` | `000003_add_unique_number.up.sql` |
| Variable de entorno | `SCREAMING_SNAKE_CASE` | `DATABASE_URL`, `CHAOS_LEVEL`, `JWT_SECRET` |

**La correspondencia que más importa** es la del verbo de negocio: el thunk del
frontend, el método del servicio y el nombre del caso de uso en la narrativa se
llaman igual. `sellNumber` en el slice, `SellNumber` en el service,
`POST /raffles/:id/numbers/:number/sell` en la ruta. Un lector que salta de una
capa a otra no debería tener que traducir nada.

### 7bis.3 Rutas canónicas del backend

- `server/cmd/api/` — el `main.go`: configuración, cableado y arranque.
- `server/internal/http/` — router, middlewares (recuperación, CORS, logging,
  `X-Request-Id`, caos) y handlers.
- `server/internal/<dominio>/` — servicio, tipos y store de un dominio.
- `server/internal/storage/` — pool, transacciones y la costura de dialecto.
- `server/migrations/` — los `.up.sql` y `.down.sql` versionados.
- `server/internal/seed/` — siembra desde el `db.json` del alumno, y el faker
  opcional de `bea-10`.
- `server/CONTRACT.md` — el contrato auditado en `be00`: régimen estricto,
  régimen de crecimiento y hallazgos. Criterio de aceptación de `be03`.
- `server/smoke.sh` — el checklist de contrato ejecutable, en `bash` y `curl`.
  Corre igual contra el mock y contra el binario de Go.
- `server/evidence/` — capturas y evidencia de las piezas forenses (el HAR de
  `be00`, los inventarios leído y medido).

---

## 8. Duda frecuente: ¿y si necesito un término que no está acá?

Se agrega **a este archivo**, en la sección que corresponda, y recién después
se usa en una fase. Ese orden importa: un término que se inventa en la Fase 7 y
no se registra acá es el que la Fase 9 va a reinventar distinto, y ahí nacen las
inconsistencias que cuestan una tarde de `grep`.

Vale igual para el track BE: un término nuevo de Go o una columna nueva se
registran en §7bis antes de aparecer en una fase.

Para componerlo, la receta es siempre la misma: un verbo técnico de §3.1 más un
sustantivo del dominio de §2. `settle` + `Raffle` → `settleRaffle`. Si el
resultado suena raro en inglés, casi siempre es que el concepto está mal
recortado, no que falte vocabulario.

Y si dudas entre dos formas igual de correctas —`closingTime` o `closesAt`,
`pricePerNumber` o `numberPrice`—, gana **la que ya esté usada en una fase
escrita**, y se anota acá para cerrar la duda de una vez. La consistencia vale
más que la elegancia: un mantenedor puede vivir con un nombre mediocre, pero no
con dos nombres para la misma cosa.

> 📝 Los dos casos de arriba son reales y se resolvieron así: `closesAt` (contra
> `closingTime`) y `numberPrice` (contra `pricePerNumber`), porque eran las
> formas mayoritarias en las fases ya escritas.
