# 🧱 Fase 04 — Ruedas CRUD

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · Fase 4 de 11 · **6 horas**
> Depende de: Fase 3 — Mock API y Express caos · Habilita: Fase 5 — Concurrencia y UI optimista

---

## 🎯 1. Propósito

En la Fase 1 las ruedas vivían en un array dentro del código, y en la Fase 3 el mock las sirvió por la red. Esta fase cierra esa brecha: el listado de ruedas deja de leer un archivo del frontend y pasa por el **store**, que pide los datos al API. Es la primera vez que la consola escribe algo que no puede deshacerse con un refresco: **los pesos de una rueda**, que deciden cuánto vale cada premio.

Los pesos son el corazón del dominio. Una rueda suma exactamente 10.000 puntos básicos, y en cuanto está en vivo sus pesos no cambian: para cambiarlos se publica una versión nueva. Si la consola deja pasar un 9.999, o si un operador edita los pesos de una rueda que ya está girando, el problema no es visual: es una probabilidad que cambia sin aviso. Por eso la regla vive en tres lugares, y los tres coinciden: una función pura en el frontend, el mensaje de error del mock, y la lista de casos de borde que la fase prueba.

Esta fase también es donde el primer slice con datos del servidor se vuelve real: `wheelSlice` tiene un thunk que pide la lista, el estado de carga, y el error legible. Y la lista sigue siendo una **clase** conectada al store con `connect()`, porque el código que vas a mantener es mixto.

> 📝 **Nota de convención.** Los nombres del código están en inglés (`wheelSlice`, `validateWeights`, `weightBp`), y los textos que ve el operador en español.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `WheelListPage` (clase) lee la lista de ruedas del store, y el store la pide al API en `GET /wheels` y `GET /segments`.
- [ ] `validateWeights` (función pura) rechaza: suma 9.999, suma 10.001, pesos no enteros, pesos cero o negativos.
- [ ] `WheelEditPage` (funcional, con hooks) edita los pesos, con la suma a la vista; una rueda en vivo deshabilita los campos.
- [ ] El mock rechaza `PUT /wheels/:id/segments` con 409 sobre una rueda en vivo y con 422 con una suma incorrecta; el 422 llega a la pantalla con su mensaje.
- [ ] Una respuesta del servidor que no es una lista se muestra como error legible, no como datos.
- [ ] Pruebas de las reglas, del mock y del slice en verde contra el mock real.

---

## 🚫 3. Qué queda fuera por ahora

- **Crear una rueda desde la consola**: el alta de ruedas nueva entra con el CRUD automático de json-server; la pantalla de alta llega con la conciliación de la Fase 8.
- **El detalle de la rueda**: `WheelDetailPage` sigue con `findWheel` sobre `mock/wheels.js`. Es una deuda declarada en `A12-mapa-de-deuda-tecnica.md`, con su disparador: pagarla cuando el detalle necesite datos que el listado no trae.
- **Envíos de premios**: Fase 5. Acá la rueda solo se configura.
- **Versiones de la rueda**: el cambio de pesos de una rueda en vivo, que genera una versión nueva, llega en el track BE (be02).

---

## 🧠 4. Conceptos mínimos

**Un store con datos del servidor.** Hasta acá el store tenía la sesión, que vive en el navegador. Las ruedas viven en el servidor, y el store es la copia que la consola usa. Esa copia tiene tres estados: cargando, lista lista, y error. Un thunk (`createAsyncThunk`) produce los tres estados sin escribir la máquina a mano, y el reducer decide cómo queda cada uno.

**La validación como función pura.** Las reglas de los pesos no dependen de React ni de la red. Una función que recibe segmentos y devuelve errores se prueba en milisegundos, y se puede reusar en la pantalla, en el thunk y en las pruebas. La regla del servidor es la misma regla: el frontend ayuda al operador, el servidor es quien decide.

**Clase y hooks conviviendo.** `WheelListPage` es una clase: pide la lista en `componentDidMount` y se conecta al store con `connect()`. `WheelEditPage` es una función: el borrador de pesos es estado local, y el store lo sincroniza con `useEffect`. Las dos dan el mismo resultado, con dos estilos distintos.

> 🧭 **Por qué la lista sigue siendo clase.** El código heredado está lleno de clases conectadas con `connect()`. Reescribir la lista como función sería una migración, y una migración no es parte de esta fase. Lo que sí hace la fase es conectarla al store sin tocar su forma.

---

## 💻 5. Implementación y código comentado

Vamos de abajo hacia arriba: primero las reglas, después el mock, el servicio, el slice, y al final las pantallas. No se instala ninguna dependencia nueva: `react-redux`, `@reduxjs/toolkit` y `axios` ya están desde la Fase 2.

### 5.1 Las reglas de pesaje: `src/features/wheels/weightRules.js`

<<<archivo:src/features/wheels/weightRules.js>>>

**Detalles con intención.**
- Un peso de cero no se acepta: un segmento sin probabilidad es un segmento que nunca sale, y eso es otra rueda. La regla es "cada segmento pesa al menos 1 punto básico".
- Un peso no entero se rechaza antes de sumar. Sumar decimales y comparar con 10.000 produce errores de redondeo que no se ven; por eso la suma se hace solo con enteros.
- `canEditWeights` mira el estado de la rueda, no la pantalla: el mismo criterio sirve para la consola, para el mock y para las pruebas.

### 5.2 El mock de los segmentos: `mock/server.js`

El CRUD automático de json-server no genera rutas anidadas, así que los segmentos de una rueda se escriben a mano, con sus reglas. Este es el bloque que la fase agrega (el resto del archivo es el de la Fase 3):

<<<fragmento:mock/server.js|// Segmentos de una rueda.|server.use(router);>>>

**Detalles con intención.**
- El `PUT` reemplaza los segmentos completos. Es una operación idempotente: enviarla dos veces deja el mismo estado.
- El orden de las validaciones importa: primero existe la rueda (404), después está en vivo (409), y solo después se mira la forma de los pesos (422). Un 409 nunca esconde un 422.
- La regla del servidor repite la del frontend a propósito. El frontend ahorra un viaje; el servidor es quien tiene la última palabra.

### 5.3 El servicio: `src/api/wheelService.js`

<<<archivo:src/api/wheelService.js>>>

**Detalles con intención.**
- `esperarLista` convierte una respuesta que no es un arreglo en un error legible. Sin esto, un servidor que devuelve un objeto de error con código 200 llega al slice como si fueran ruedas, y la pantalla explota en otro lado.
- `mensajeDe` prefiere el mensaje del servidor (el 409 dice por qué), y solo cae al genérico cuando no hay ninguno.
- `fetchWheelsWithSegments` pide las dos listas en paralelo y las une por `wheelId`. Es un viaje extra y un join en el cliente; el día que el API tenga el join, este archivo se acorta.

### 5.4 El slice: `src/features/wheels/wheelSlice.js`

<<<archivo:src/features/wheels/wheelSlice.js>>>

**Detalles con intención.**
- Cada thunk tiene sus tres casos (`pending`, `fulfilled`, `rejected`). Un thunk sin el caso de `fulfilled` deja la pantalla cargando para siempre: es el incidente 10.
- `saveWheelSegments` reemplaza solo los segmentos de la rueda afectada. Las demás ruedas no se tocan, y la lista no vuelve a pedirse.
- El error del thunk es un mensaje legible; el slice nunca guarda un objeto de error de axios.

### 5.5 La lista: `src/pages/WheelListPage.jsx`

<<<archivo:src/pages/WheelListPage.jsx>>>

**Detalles con intención.**
- `componentDidMount` pide la lista al montar. Es el momento de la clase para una petición inicial; un `useEffect` con `[]` haría lo mismo.
- `mapStateToProps` lee solo lo que la pantalla usa. Leer el estado entero hace que la clase se vuelva a pintar con cualquier cambio.
- `withRouter` se usa solo para `history`. La clase no necesita `connect()` para navegar, y conviene que el lector vea que son dos cosas distintas.

### 5.6 La edición de pesos: `src/pages/WheelEditPage.jsx`

<<<archivo:src/pages/WheelEditPage.jsx>>>

**Detalles con intención.**
- El borrador vive en estado local. La rueda del store no se toca mientras el operador escribe: si se tocara, cada tecla dispararía una petición.
- Hay dos `useEffect`, con dependencias distintas. El primero pide la lista si el operador llegó directo a la URL. El segundo copia la rueda del store al borrador cuando la rueda cambia. Si la dependencia del segundo fuera `[]`, la pantalla mostraría los segmentos de una carga anterior: es el patrón del incidente 04 con otra cara.
- `disabled={!editable}` bloquea los campos de una rueda en vivo, y el botón de guardar también. La regla está en `canEditWeights`, no en el JSX: un cambio de regla no obliga a tocar la pantalla.

### 5.7 Conectar el store: `src/app/store.js` y `src/AppRouter.jsx`

<<<archivo:src/app/store.js>>>

La ruta de edición va antes de la del detalle, porque `/wheels/:id` no es exacta y `/wheels/1/edit` también la matchea:

<<<fragmento:src/AppRouter.jsx|<PrivateRoute exact path="/wheels/:id/edit"|<PrivateRoute path="/wheels/:id" component={WheelDetailPage} />>>>

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. La suma que "casi" da 10.000.** Síntoma: el operador ve "Suma: 9999" y piensa que es un redondeo. Causa: los pesos se guardaron como decimales, o alguien redondeó en la pantalla. Fix: la regla pide enteros y la suma se compara exacta.

**2. La rueda en vivo que acepta cambios.** Síntoma: los campos están deshabilitados, pero una petición directa cambia los pesos. Causa: la regla vive solo en la pantalla. Fix: el servidor responde 409, y la prueba de la fase lo fija.

**3. La lista que se queda cargando.** Síntoma: el cartel de "Cargando ruedas…" no desaparece. Causa: falta el caso `fulfilled` del thunk. Es el incidente 10.

**4. El borrador que muestra otra rueda.** Síntoma: abres la rueda 2 y los pesos son los de la 1. Causa: un `useEffect` sin la rueda como dependencia. Es el patrón del incidente 04.

### Pieza forense de esta fase: el store, paso a paso

Redux DevTools muestra el estado antes y después de cada acción. Para esta fase, la secuencia que hay que saber leer es la de guardar pesos: `wheels/saveSegments/pending` (la pantalla deshabilita el botón), después `wheels/saveSegments/fulfilled` (la rueda 2 trae sus segmentos nuevos), o `rejected` con el mensaje del 422. Mirar qué cambió en el diff te dice si la pantalla y el servidor están de acuerdo.

El **time-travel** es la prueba: vuelve a un estado anterior con la línea de tiempo de Redux DevTools y comprueba que la pantalla sigue a ese estado, sin que nada se quede pegado. Esa comprobación es a mano (ver la verificación de la fase).

---

## 🧪 7. Ejercicios (24)

Trabaja sobre la app de la fase. Varios son de diagnóstico.

**🟢 Fácil (1–6)**

1. Muestra en la lista el número de segmentos de cada rueda y compara con el mock.
2. Cambia el mensaje de "Cargando ruedas…" por un esqueleto de tres filas.
3. Agrega una rueda `draft` al mock y verifica que aparece en el listado.
4. Cambia el mínimo de un segmento de 1 a 10 puntos básicos y verifica que la regla lo rechaza.
5. Muestra la suma en rojo cuando no sea 10.000 y en verde cuando sí.
6. Agrega un botón "Restablecer" que vuelva el borrador a los pesos de la rueda del store.

**🟡 Intermedio (7–14)**

7. Escribe una prueba para `validateWeights` con 10.000 pesos de 1 (suma 10.000): ¿qué devuelve y por qué?
8. Haz que el servicio reintente una vez los errores 5xx, sin reintentar los 4xx. Justifica la diferencia.
9. Agrega al slice un selector `selectWheelsByStatus(status)` y úsalo en la lista.
10. Convierte `WheelEditPage` para que el borrador se inicialice con `useState(() => …)` en vez de un `useEffect`. ¿Qué cambia cuando la rueda llega después del montaje?
11. Quita la dependencia `wheel` del segundo `useEffect` y observa qué rueda muestra la pantalla al cambiar de URL.
12. Agrega un contador de peticiones a `fetchWheels` y verifica que `componentDidMount` lo llama una vez.
13. Escribe un test que haga que la lista muestre el error legible cuando el servidor devuelve un objeto y no un arreglo.
14. Muestra en la lista un indicador de "en vivo" con el color del badge de estado.

**🟠 Difícil (15–20)**

15. **Diagnóstico.** La lista aparece vacía, pero el mock tiene ruedas. Reproduce el caso y localiza la línea que falla (pista: el caso `fulfilled` del thunk).
16. **Diagnóstico.** Guardas los pesos de la rueda 2, vuelves a la lista y la rueda aparece con los pesos anteriores. Reproduce el caso y explica por qué el slice no lo ve.
17. **Diagnóstico.** Abre `/wheels/2/edit` directamente en una pestaña nueva y la pantalla se queda en "Cargando rueda…". Pista: el primer `useEffect` y la dependencia `wheel`.
18. Agrega al mock un `PUT` que acepte una rueda `live` si el cuerpo trae `force: true`. ¿Qué regla rompe eso y qué habría que decidir antes?
19. Migra `WheelListPage` a función con `useSelector`/`useDispatch`. Compara las dos versiones y anota qué desaparece.
20. Escribe la prueba de regresión del incidente 09 (el formulario no recarga la página) y verifica que falla sin el `preventDefault()`.

**🔴 Muy difícil (21–24)**

21. **Diagnóstico integrador.** Dos operadores editan los pesos de la misma rueda en paralelo. ¿Qué pasa con el último que guarda? Describe el resultado y propón la corrección mínima.
22. Mide cuánto tarda `validateWeights` con 100.000 segmentos (sintético) y explica si importa para la consola.
23. Escribe un post-mortem completo (síntoma, reproducción, evidencia, causa raíz, corrección, prueba, prevención, análisis sin culpa) para "las ruedas que ya giraron cambiaron de probabilidad".
24. Diseña la versión de la rueda: qué cambia en la tabla de segmentos cuando se publica una versión nueva, y qué pasa con los giros de la versión anterior.

**🔥 Opcionales**

- 🔥 Agrega un `GET /wheels/:id/segments?sum=true` que devuelva la suma. ¿Debe la consola usarlo, o la suma es una regla del cliente?
- 🔥 Escribe la validación de pesos en TypeScript y compara los errores que atrapa.

---

## 📚 8. Referencias

- Redux Toolkit — `createAsyncThunk`: https://redux-toolkit.js.org/api/createAsyncThunk
- Redux Toolkit — `createSlice` y reducers con casos: https://redux-toolkit.js.org/api/createSlice
- React Redux — `connect`: https://react-redux.js.org/api/connect
- React — `useEffect` y sus dependencias: https://legacy.reactjs.org/docs/hooks-effect.html
- `A6-redux-clasico-vs-toolkit.md`, para la diferencia entre el thunk manual y `createAsyncThunk`.
- `A5-class-components-vs-hooks.md`, para la convivencia de la lista (clase) y la edición (función).
- `A12-mapa-de-deuda-tecnica.md`, para el detalle de la rueda que queda como deuda.

---

## 🚀 9. Cierre y conexión con la Fase 5

La consola ya lee las ruedas del servidor, y las guarda con reglas que el servidor también aplica. Un 9.999 no pasa, una rueda en vivo no cambia, y una respuesta rara se ve como error. Lo que todavía no existe es el operador que manda premios: esa es la Fase 5, donde las acciones se vuelven concurrentes y el estado de cada envío empieza a cambiar mientras la pantalla se usa.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde:
>
> ```bash
> git tag -a fase-04-ruedas-crud -m "F4 cerrada: <el checklist, en una línea por ítem>"
> ```

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura.

- **El detalle de la rueda sigue con datos de archivo** (`findWheel`). Es una deuda declarada en `A12`, no un descuido. → Verificar que A12 la tenga con su disparador.
- **La suma de pesos se valida en dos lugares**, el cliente y el servidor. → La fase lo justifica; un test de contrato entre los dos queda para be00.

### Reservas para el cuaderno de incidentes

- **09** — *Guardo la rueda, la pantalla se recarga y pierdo lo que escribí* · Estado (store) · 🟢. Sale del `preventDefault()` que falta en el formulario de pesos. Tiene su rama `incidente/09`.
- **10** — *La lista de ruedas se queda cargando para siempre* · Estado (store) · 🟡. Sale del caso `fulfilled` que falta en el slice. Tiene su rama `incidente/10`.
