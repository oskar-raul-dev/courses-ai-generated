## Incidente 07 — A veces no entra y no dice nada

> **Fase:** 3 · **Categoría:** Integración · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-50 min

### 🎫 El ticket

A veces no entro. Pongo mi usuario y mi contraseña, toco "Iniciar sesión" y el
botón se queda en "Ingresando…" para siempre. No aparece ningún error ni nada más.
Si recargo, generalmente sale bien. A mi compañera también le pasa, pero menos.

**Reportado por:** operadora de soporte
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo **cuando tú quieras**, no cuando le toque al azar. Ese es el
entregable principal: un procedimiento determinista. Después, localizar la capa y
aplicar el fix.

> 🧭 **Este es el ticket vago canónico del curso**, y por eso conviene decir en voz
> alta lo que va a sonar raro: *"a veces"* y *"para siempre"* son los dos datos
> **más valiosos** del reporte. Una frecuencia es una pista sobre el mecanismo.

### 🔧 Preparación

- **Rama:** `incidente/07`, que quita el `timeout` de la instancia de `apiClient`.
  Es un cambio de una línea y no toca ningún componente.
- **Caos:** `CHAOS_LEVEL=high` en el mock del puerto `3001`. **Obligatorio.** Con
  `low` el timeout casi no aparece, y con `off` no aparece jamás.
- **Datos:** `mock/db.json`, con los usuarios de la fase.

```bash
git checkout incidente/07
CHAOS_LEVEL=high npm run mock:api
npm start
# Entra y sale varias veces hasta que el botón se quede pegado.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes de la aplicación, mira **el mock**. "Para siempre" significa que una petición
nunca termina, y el mock es el único que decide si una petición responde. Hay un
archivo en este proyecto donde está escrito qué fallo le toca a cada respuesta.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Network, con la columna **Status** y la columna **Time** a la vista. Ordena por
Time y repite el login. Vas a encontrar una petición que no tiene status, porque no
terminó. Ahora la pregunta es de la otra orilla: ¿cuánto tiempo está dispuesto a
esperar el cliente?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Cuál es el valor por defecto de `timeout` en axios, y qué significa ese valor?
¿Y en qué estado se queda el `login` de la Fase 2 cuando su promesa nunca se
resuelve ni se rechaza?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Acá lo que se evalúa es que sea determinista. "Intentar hasta que pase" no es un
procedimiento de reproducción: es esperar. Cuenta cuántos intentos hacen falta con
la semilla que uses.}}

**Evidencia observable**
{{La fila de Network de la petición que no termina, y el estado del store mientras
tanto (`loading`, `error`).}}

```
{{status, time, y qué dice state.auth.loading}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Ojo: puede que el archivo culpable sea uno donde *falta* algo.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/api/apiClient.js`: la instancia se crea sin `timeout`. Axios, por defecto, no
corta ninguna petición: espera a que el servidor responda, pase lo que pase. El mock,
con `CHAOS_LEVEL=high`, a veces no responde (es el fallo de tipo *timeout*: el
servidor recibe la petición y no contesta). La promesa de `authService.login` nunca
se resuelve ni se rechaza, así que el thunk `auth/login/pending` queda como la última
acción despachada: `loading` se queda en `true` para siempre y el botón en
"Ingresando…".

El síntoma "a veces" es la probabilidad del caos (2 % de timeouts en el nivel alto),
y el "para siempre" es la ausencia de un tiempo máximo. Son dos datos del mismo
defecto.

**Evidencia que lo confirma**

En Network, una petición `/users` sin status y con un tiempo que crece mientras el
botón sigue pegado. En el store, `auth/login/pending` como última acción: sin
`fulfilled` ni `rejected`.

**Parche mínimo**

```javascript
// src/api/apiClient.js — la instancia tiene un tiempo máximo
const apiClient = axios.create({
  baseURL: "http://localhost:3001",
  timeout: 5000, // sin esto, un timeout del mock cuelga la UI
});
```

**La refactorización correcta**

Tener un tiempo máximo en la instancia no basta si la UI no tiene qué hacer cuando
se agota. El tiempo máximo convierte el cuelgue en un `rejected`, y el `rejected` ya
llega a `LoginPage`: el mensaje legible de `authService` (5xx y timeouts) lo muestra.
La refactorización es que cada instancia de cliente declare su tiempo máximo según el
servicio: el de la consola, 5 s; el de un servicio externo, otro valor, medido.

**Prueba de regresión**

Con el mock en `CHAOS_LEVEL=high`, doscientos logins en paralelo no pueden quedar
colgados. Mientras el defecto exista, la prueba falla; con el timeout, pasa.

```javascript
// src/__incidentes__/inc07.test.js — el mock corre en otro contenedor con CHAOS_LEVEL=high
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";

test("ninguna petición de login se queda colgada con el caos alto", async () => {
  const promesas = Array.from({ length: 200 }, () =>
    store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }))
  );
  const estado = await Promise.race([
    Promise.all(promesas.map((p) => p.then(() => "resuelta"))).then(() => "todas resueltas"),
    new Promise((resolve) => setTimeout(() => resolve("hay colgadas"), 20000)),
  ]);
  expect(estado).toBe("todas resueltas");
}, 40000);
```

Corre la prueba con `--forceExit`: las peticiones colgadas mantienen vivo el proceso
de Jest aunque la prueba termine.

**Prevención**

Un cliente HTTP sin tiempo máximo es un defecto de revisión, y es fácil de detectar:
una regla de lint o una revisión de la instancia de axios. El cuaderno del track BE
vuelve sobre esto con el nivel de carga de `be08`.

**Si tu causa fue distinta a esta**

Si dijiste *"el servidor está lento"*, mide: el cuelgue no depende de la velocidad,
sino de que la respuesta nunca llega. Si dijiste *"falta un `.catch`"*, mira la
pregunta de la pista 3: un `.catch` no ayuda a una promesa que nunca se resuelve.

</details>

---

