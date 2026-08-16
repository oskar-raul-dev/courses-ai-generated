# 📓 Cuaderno de incidentes — Curso 01 · Vue 2 Legacy

> Doce tickets vagos, como llegan de verdad: en palabras de quien los sufre, sin
> pasos de reproducción y con la mitad de la información. Cada uno trae su
> preparación, tres pistas plegadas, sitio para tu investigación y una solución
> de referencia.

**El trato.** La solución viene incluida y está plegada por una razón: abrirla
antes de tiempo no te perjudica a mí, te perjudica a ti. El músculo que esto
entrena —leer un síntoma ambiguo y convertirlo en una pregunta con respuesta— no
se desarrolla leyendo respuestas. Si llevas cuarenta minutos atascado, abre la
pista 1. Si llevas otros veinte, la 2. Y si abres la solución, léela **después**
de haber escrito tu hipótesis, aunque sea la equivocada: comparar tu camino con
el de referencia es la mitad del valor.

Este cuaderno es del **Curso 01** y se resuelve entero sin salir de él. No cita
ninguna fase del Curso 02 ni necesita Mongo, Express ni Docker.

---

## 🧭 Cómo se trabaja un incidente

El método es el de [`forense-master.md`](forense-master.md), y las cuatro
preguntas van siempre en este orden, porque cada una cuesta un orden de magnitud
más que la anterior:

1. **¿Se reproduce, y con qué?** ¿Con un flag del inyector de caos, con un dato
   distinto, o hace falta otro código?
2. **¿Qué dice la evidencia observable, antes que el código?** Network, Vue
   DevTools, la consola.
3. **¿En qué capa está?** Componente, store, servicio HTTP o mock.
4. **¿De qué lado de la frontera está?** Lo que el mock promete contra lo que tu
   código asume.

### Las tres formas de tener el sistema roto

Cada incidente dice cuál usa, y usa **la más barata que sirve**:

```bash
CHAOS=malformed npm run mock            # 1 · un flag del inyector (Fase 3)
cp mock/db.incidente-05.json db.json    # 2 · un db.json alterno
git switch -c incidente/07 fase-07-metricas-minimas   # 3 · una rama, solo si hay que romper código
```

> ⚠️ Antes de pisar `db.json`, guarda el tuyo: `git checkout -- db.json` te
> devuelve el que commiteaste; `npm run mock:reset` lo regenera desde la semilla
> y se lleva por delante tus escenarios. La diferencia está en
> [la convención de git §🧹](../prompts/convencion-de-git-y-tags.md).

### La convención de commits

El asunto sigue este formato, para que `git log --oneline` se lea como la línea
de tiempo de la investigación:

```
incidente(05): abre — la etiqueta no aparece en la tabla
incidente(05): repro — solo con tickets que vienen sin el campo tags
incidente(05): hipótesis descartada — no es el mock, el PATCH devuelve todo
incidente(05): causa — la propiedad se agrega después de que el objeto entró
incidente(05): fix — Vue.set en el punto de actualización
incidente(05): cierre — test de regresión y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`,
`causa`, `fix`, `cierre`. **Commitea también los callejones sin salida**: un log
con seis commits de investigación y uno de fix es un registro honesto; uno que
solo muestra el fix no le sirve a nadie, y menos a ti dentro de seis meses.

Y marca el par de tags de la convención §🚑:

```bash
git tag -a inc/f05/etiqueta-invisible-roto -m "Síntoma, repro y la prueba en rojo."
# …el fix…
git tag -a inc/f05/etiqueta-invisible-fix  -m "Causa raíz, fix, y la prueba en verde."
```

### Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y prueba de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 📋 Índice

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| 01 | 0 | "Clonaste el repo y no me arranca, a ti sí te funciona" | Build | 🟢 | ⬜ |
| 02 | 3 | "A veces carga y a veces se queda pensando" | Integración (mock) | 🟢 | ⬜ |
| 03 | 2 | "Me sacó al login a mitad de la mañana, sin decir nada" | Estado | 🟡 | ⬜ |
| 04 | 4 | "Pongo el filtro y la tabla se queda con lo de antes" | Estado | 🟡 | ⬜ |
| 05 | 5 | "Le puse la etiqueta y la tabla no se enteró" | Reactividad | 🟡 | ⬜ |
| 06 | 6 | "Volví atrás en el asistente y perdí la descripción" | Formularios y wizard | 🟡 | ⬜ |
| 07 | 7 | "A la media hora la laptop suena como un avión" | Reactividad | 🟠 | ⬜ |
| 08 | 8 | "Se me duplican los tickets cuando entra uno nuevo" | Tiempo real | 🟠 | ⬜ |
| 09 | 9 | "Tomé el ticket y a mi compañera le sigue apareciendo libre" | Estado | 🟠 | ⬜ |
| 10 | 10 | "El contador del menú dice una cosa y la tabla otra" | Estado (Vuex) | 🟠 | ⬜ |
| 11 | 11 | "El test pasa solo cuando lo corro aislado" | Testing | 🔴 | ⬜ |
| 12 | 10 | "En el servidor de pruebas se comporta distinto que en mi máquina" | Build | 🔴 | ⬜ |

---

## 🧪 Incidentes

## Incidente 01 — "Clonaste el repo y no me arranca, a ti sí te funciona"

> **Fase:** 0 · **Categoría:** Build · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-40 min

### 🎫 El ticket

> "Me pasaron el proyecto para que empiece a mantenerlo. Corrí `npm install` y
> `npm run serve` como dice el README y me sale un muro de texto rojo que habla
> de un compilador y de plantillas. En la máquina de la persona que me lo pasó
> arranca perfecto, lo vi con mis propios ojos."

**Reportado por:** alguien que se incorpora al equipo · **Ambiente:** su máquina

### 🎯 Qué se te pide

Que arranque, y que puedas **explicar en una frase** por qué no arrancaba — la
frase importa más que el arreglo, porque este error vuelve. No vale "reinstalé
todo y ya funciona": si esa fue tu solución, no sabes qué pasó y va a repetirse
en la máquina del siguiente.

### 🔧 Preparación

La más barata de las tres: una rama, porque hay que romper el `package.json`.

```bash
git switch -c incidente/01 fase-00-setup-hola-mundo
npm install vue-template-compiler@2.6.12 --save-exact --save-dev
npm run serve
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No mires el código de la aplicación: no lo has tocado y el error aparece antes
de que se ejecute nada tuyo. Lee la **primera** línea del muro, no la última. Y
antes de leerla siquiera, contesta la pregunta más barata del track: ¿qué versión
de Node estás usando, y cuál dice el proyecto que hay que usar?

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

El error menciona dos paquetes por su nombre y sus dos versiones. Ponlas una
debajo de la otra:

```bash
npm ls vue vue-template-compiler
```

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué relación tiene que haber entre esas dos versiones? No "compatibles". La
palabra exacta que usa la Fase 0 es otra, y es más fuerte.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** `vue@2.6.14` y `vue-template-compiler@2.6.12` en el mismo
proyecto. El compilador de plantillas y el runtime tienen que ser **idénticos**,
no compatibles: cada versión de Vue 2 genera funciones de render con una forma
que su runtime espera exactamente. El propio error lo dice, con el detalle que lo
vuelve peligroso:

```
Vue packages version mismatch:

- vue@2.6.14
- vue-template-compiler@2.6.12

This may cause things to work incorrectly. Make sure to use the same version
for both.
```

Fíjate en *"may cause things to work incorrectly"*: a veces compila igual y el
fallo aparece tres fases después, en un componente al azar. Por eso conviene
tratarlo como un error duro aunque el mensaje suene tibio.

Y el "a ti sí te funciona" tiene explicación: quien te pasó el proyecto instaló
sus dependencias cuando el `package.json` estaba sano, y su `node_modules` no se
va a mover hasta que alguien reinstale.

**Parche mínimo** — el del viernes a las seis:

```bash
npm install vue@2.6.14 vue-template-compiler@2.6.14 --save-exact
npm run serve
```

**La refactorización correcta.** El parche arregla hoy; el problema de fondo es
que el proyecto **permite** que esas dos versiones se separen. Tres cosas lo
impiden, y ninguna cuesta nada:

- fijar las dos con versión exacta, sin `^`, que es lo que la Fase 0 explica al
  diseccionar el acento circunflejo que npm escribió sin preguntarte;
- commitear el `package-lock.json` (si no está, ésta es la conversación);
- un `.nvmrc` con la versión de Node del proyecto, y el hábito de `nvm use`,
  porque la mitad de los "no me arranca" restantes son de Node y no de Vue.

**Prueba de regresión.** No es un test unitario: es una comprobación de arranque.

```json
{
  "scripts": {
    "check:versions": "node -e \"var p=require('./package.json');var a=p.dependencies.vue,b=p.devDependencies['vue-template-compiler'];if(a!==b){console.error('vue '+a+' != vue-template-compiler '+b);process.exit(1)}\""
  }
}
```

Corre `npm run check:versions` en el `preserve` o en el pipeline y el
desalineamiento deja de poder llegar a otra máquina.

**Prevención.** Documenta en el README las dos líneas que hay que ejecutar para
verificar el entorno antes de reportar nada: `node -v` contra `.nvmrc`, y
`npm ls vue vue-template-compiler`. Es el paso 1 y 2 de la
[pieza forense de la Fase 0](forense-fase-00.md), y convierte este incidente en
un minuto en vez de una tarde.

**Por qué llegó a producción.** Nadie hizo nada mal. `npm install
vue-template-compiler` sin más trae la última de la línea, el `^` del
`package.json` permite que suba sola, y el mensaje de error usa un condicional
—*"puede causar"*— que invita a ignorarlo. El sistema permitía que las dos
versiones se separaran sin que nadie se enterara hasta la siguiente instalación
limpia; el arreglo es que deje de permitirlo.

**Si tu causa fue distinta a ésta.** Si tu muro hablaba de `gyp ERR!`, tu
problema era el Node y se resuelve con `nvm use` — igual de válido, y aparece en
el mismo sitio de la pieza forense. Si era `EADDRINUSE`, tenías un proceso zombi
en el puerto y ni siquiera era un problema del proyecto. Los tres se descartan en
los dos primeros pasos del recorrido, y ése es justamente el punto.

</details>

---

## Incidente 02 — "A veces carga y a veces se queda pensando"

> **Fase:** 3 · **Categoría:** Integración (mock) · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-50 min

### 🎫 El ticket

> "La lista de tickets a veces carga y a veces se queda cargando para siempre.
> No sale ningún error, se queda con la ruedita dando vueltas. Si le doy F5
> varias veces al final entra. Ah, y a veces entra pero sale vacía como si no
> hubiera tickets, y sí hay."

**Reportado por:** agente de soporte · **Ambiente:** desarrollo

### 🎯 Qué se te pide

Dos cosas, y la segunda es la que de verdad cuenta:

1. Determinar **cuántos problemas distintos** hay en ese ticket. Un reporte no
   es un bug: puede ser dos.
2. Decir, con evidencia, si tu código puede distinguir "el servidor no está" de
   "el servidor está y no contestó". Si la respuesta es no —y lo es— explica qué
   habría que cambiar para que sí, y decide si vale la pena.

Este incidente **no termina necesariamente en un fix del bug**: termina en un
diagnóstico correcto y en una mejora de diagnosticabilidad. Es un entregable
legítimo, y de los más formativos.

### 🔧 Preparación

La forma preferida: un flag del inyector de caos de la Fase 3. No toca tu código
ni tus datos, y se apaga al reiniciar el mock.

```bash
CHAOS=timeout npm run mock     # para el primer síntoma
CHAOS=empty npm run mock       # para el segundo
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No abras un archivo todavía. La pestaña Network contesta las dos mitades del
ticket, y contesta cosas distintas según cómo se vea la fila del request: hay
tres estados posibles y conviene saber nombrarlos.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Con el mock en `timeout`, mira el estado de la petición y después mira tu
componente: ¿en qué punto del ciclo `loading → datos/error` se quedó, y qué
callback no llegó a ejecutarse nunca?

Con el mock en `empty`, la petición es un `200` impecable. La pregunta es otra:
¿tu vista puede distinguir esa respuesta de una lista legítimamente vacía?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Sin `timeout` configurado en axios, ¿cuánto tiempo espera una petición? Y con el
servidor apagado del todo, ¿qué valor tiene `error.response` dentro de tu
`.catch`? Compáralo con el caso de CORS.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Son **dos** problemas, y el reporte los mezcla porque desde la
pantalla se parecen:

1. *El spinner eterno.* El servidor recibió la petición y no contestó. Sin
   `timeout` en el `apiClient`, axios espera indefinidamente: ni `.then`, ni
   `.catch`, ni `.finally` se ejecutan, así que `loading` se queda en `true`
   para siempre. En Network la fila queda en `(pending)`, que es la firma
   inconfundible.
2. *La lista vacía.* El servidor contestó `200` con `[]`. El sistema funcionó
   perfectamente y la vista no tiene forma de distinguir "no hay tickets" de "no
   llegaron tickets", porque las dos cosas producen `tickets = []`.

Y el hallazgo incómodo que hay que dejar escrito: con el servidor apagado, con
CORS bloqueando y con un timeout, tu `catch` recibe **lo mismo**
(`error.response` es `undefined` en los tres). Desde el código del cliente son
indistinguibles; solo Network y la consola los separan.

**Parche mínimo:**

```js
// services/apiClient.js
var apiClient = axios.create({
  baseURL: "http://localhost:3000",
  timeout: 8000    // el cuelgue silencioso pasa a ser un error contable
});
```

**La refactorización correcta.** El `timeout` convierte el cuelgue en un error,
pero no resuelve la ambigüedad del segundo síntoma. La vista necesita tres
estados y hoy tiene dos:

```js
// views/TicketsView.vue — en el .then del servicio
.then(function (tickets) {
  self.tickets = tickets;
  self.loaded = true;      // "sí hubo respuesta", distinto de "hay datos"
})
```

Con `loaded` y `tickets.length` la plantilla puede decir tres cosas distintas:
"cargando", "no hay tickets registrados" y "no se pudieron cargar los tickets".
Tres mensajes, tres situaciones — y el usuario deja de reportar una sola cosa
ambigua.

**Prueba de regresión.**

```js
// tests/unit/TicketsView.spec.js
it("distingue lista vacía de fallo de carga", function () {
  var wrapper = shallowMount(TicketsView, { … });
  wrapper.setData({ loading: false, loaded: true, tickets: [] });
  expect(wrapper.text()).toContain("No hay tickets");
  wrapper.setData({ loading: false, loaded: false, error: "…" });
  expect(wrapper.text()).not.toContain("No hay tickets");
});
```

**Prevención.** El inyector de caos de la Fase 3 pasa a ser parte del ritual:
antes de dar por cerrada una vista que hace HTTP, se prueba con `CHAOS=timeout`,
`CHAOS=empty` y `CHAOS=500`. Tres comandos, y cubren la familia entera.

**Por qué llegó a producción.** Porque en desarrollo el mock siempre contesta, y
contesta rápido. Los tres estados de una vista se escriben mirando el camino
feliz, y los caminos infelices no tienen quien los ejercite hasta que un usuario
los encuentra. No es descuido de nadie: es la ausencia de una herramienta que
ahora existe.

**Si tu causa fue distinta a ésta.** Si en tu reproducción viste
`(failed)` en vez de `(pending)`, tenías el mock apagado —o CORS— y el camino es
el del paso 3 de la [pieza forense de la Fase 3](forense-fase-03.md). Si viste un
`200` con cuerpo raro y un `tickets.filter is not a function`, estabas en
`CHAOS=malformed`, que es otro incidente con la misma cara.

</details>

---

## Incidente 03 — "Me sacó al login a mitad de la mañana, sin decir nada"

> **Fase:** 2 · **Categoría:** Estado · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "Estaba trabajando normal, hice clic en un ticket de la lista y me apareció la
> pantalla de login otra vez. Sin ningún mensaje. Lo raro es que arriba a la
> derecha seguía apareciendo mi nombre hasta que hice clic. Volví a entrar y
> siguió todo normal. Me pasó dos veces esta semana."

**Reportado por:** agente de soporte · **Ambiente:** desarrollo y UAT

### 🎯 Qué se te pide

Reproducirlo a voluntad —el "dos veces esta semana" tiene que convertirse en "las
veces que yo quiera"—, decir en qué **capa** vive el problema, y contestar por
escrito una pregunta de diseño: **¿cuál es la fuente de verdad de la sesión en
esta aplicación?** Si tu respuesta tiene más de un elemento, ahí está el bug.

Ojo con el detalle del nombre en el header: no es adorno del reporte, es la
evidencia principal.

### 🔧 Preparación

No hace falta romper código ni datos: basta con provocar el estado inconsistente
desde la consola del navegador, que es exactamente lo que un script de terceros,
una extensión o un `logout` a medias harían.

```js
> localStorage.removeItem("token")   // el usuario no hace esto; el sistema sí
```

Después navega a cualquier ruta protegida.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

En esta fase todavía no hay servidor, así que no hay 401 que valga: solo hay un
actor en toda la aplicación con poder para mandarte a `/login`. Búscalo y léelo
entero, incluidas las dos condiciones de su `if`.

Y mira, en paralelo, DevTools → Application → Local Storage.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Compara, al mismo tiempo, dos sitios donde vive la sesión: lo que hay en
`localStorage` y lo que dice el módulo `auth` del store en Vue DevTools. ¿Coinciden?

Si no coinciden, la pregunta ya no es "quién borró el token" sino "por qué el
sistema tiene dos copias y quién manda".

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El header lee la sesión de un sitio y el guard la lee de otro. ¿Cuál de los dos
se entera cuando el otro cambia?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** La sesión vive en **dos sitios que nadie sincroniza**:

- `router/index.js` — el guard `beforeEach` lee `localStorage.getItem("token")`;
- `store/modules/auth.js` — el store tiene su propia copia en memoria, que es la
  que alimenta el header.

Cuando el token desaparece de `localStorage` sin pasar por `clearSession()` —una
extensión, un script, una pestaña que cerró sesión, un `logout` a medias— el
store no se entera: sigue mostrando tu nombre. El guard, en cambio, lo mira en
cada navegación, y en cuanto navegas te manda a `/login` con un `next("/login")`
que **no muestra nada, no loguea nada y no deja rastro en Network**. De ahí las
dos rarezas del reporte: el silencio y el nombre que seguía ahí.

La Fase 2 declara esto sin esconderlo, en su nota legacy honesta: el guard y el
interceptor leen `localStorage` directamente aunque el store también tenga el
token, "porque es exactamente lo que vas a encontrar en bases legacy reales". Es
una 💸 deuda declarada, y este incidente es su factura.

**Parche mínimo** — el del viernes a las seis:

```js
// router/index.js
router.beforeEach(function (to, from, next) {
  var token = localStorage.getItem("token");
  var requiresAuth = to.matched.some(function (record) {
    return record.meta.requiresAuth;
  });

  if (requiresAuth && !token) {
    // Antes de expulsar, deja el sistema coherente y di por qué te vas.
    store.commit("auth/CLEAR_SESSION");
    next({ path: "/login", query: { reason: "session-expired" } });
    return;
  }
  next();
});
```

Con eso el header deja de mentir y el login puede mostrar *"Tu sesión se cerró,
vuelve a entrar"*, que es la diferencia entre un misterio y un aviso.

**La refactorización correcta.** El parche sincroniza dos copias; lo correcto es
que haya una. El `authService` pasa a ser la única puerta a `localStorage` —ya
tiene `saveSession`, `clearSession` y `getStoredSession`— y tanto el guard como
el interceptor le preguntan a él, no al almacenamiento. Es lo que propone el
ejercicio 24 de la fase, y a partir de ahí la pregunta *"¿cuál es la fuente de
verdad?"* tiene una sola respuesta escrita en un solo archivo.

Queda una segunda deuda 💸 en pie, y conviene dejarla anotada en
`SECURITY-NOTES.md` en vez de fingir que este fix la cubre: **el guard comprueba
que el token exista, no que sea válido.** Con un `localStorage.setItem("token",
"cualquier-cosa")` entras igual. Eso no se puede arreglar en el frontend: hace
falta un servidor que conteste 401.

**Prueba de regresión.**

```js
// tests/unit/router-guard.spec.js
it("limpia el store cuando expulsa por falta de token", function () {
  localStorage.setItem("token", "mock-jwt-token-123");
  store.commit("auth/SET_SESSION", { token: "mock-jwt-token-123", user: { … } });

  localStorage.removeItem("token");
  var next = jest.fn();
  guard({ path: "/tickets", matched: [{ meta: { requiresAuth: true } }] }, {}, next);

  expect(store.state.auth.token).toBe(null);
  expect(next).toHaveBeenCalledWith(
    expect.objectContaining({ path: "/login" })
  );
});
```

**Prevención.** Una regla de revisión, corta y verificable: **ningún archivo
fuera de `authService.js` puede nombrar `localStorage`**. Es un `grep` en el
pipeline, y cierra la puerta por la que entró este bug.

```bash
grep -rn "localStorage" src/ | grep -v "services/authService.js"
```

**Por qué llegó a producción.** Porque la duplicación estaba **documentada** y
justificada: evita problemas de orden de inicialización entre router y store, y
es el patrón que se ve en bases reales de la época. La decisión fue razonable; lo
que faltó fue el segundo movimiento —dejar escrito quién manda cuando las dos
copias discrepan— y una expulsión silenciosa que no le contaba a nadie lo que
había pasado. Ninguna persona se equivocó: el sistema permitía una incoherencia
y no tenía forma de reportarla.

**Si tu causa fue distinta a ésta.** Si concluiste "expiró el token", buena
hipótesis y falsa en esta fase: el token es la cadena literal
`"mock-jwt-token-123"` y no caduca. Si llegaste a "el guard corre antes que el
store", eso importa al arrancar la aplicación, no al navegar con todo montado —
la evidencia que lo tumba es el store poblado en DevTools.

</details>

---

## Incidente 04 — "Pongo el filtro y la tabla se queda con lo de antes"

> **Fase:** 4 · **Categoría:** Estado · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "Selecciono 'Abiertos' en el desplegable de estado y la tabla sigue mostrando
> todos los tickets. Pero si después escribo cualquier cosa en el buscador, ahí
> sí se actualiza y además ya sale filtrada por abiertos. Y el contador de arriba
> dice 'Mostrando 8 de 8' cuando abajo se ven 3 filas."

**Reportado por:** coordinadora de soporte · **Ambiente:** desarrollo

### 🎯 Qué se te pide

Localizar la capa y explicar **por qué un control funciona y el otro no**, que es
la parte del reporte que contiene la respuesta. Y una segunda entrega, más
valiosa que el fix: buscar si el mismo patrón está en otro sitio del proyecto y
dejarlo anotado, porque esta familia de bugs nunca viene sola.

### 🔧 Preparación

Una rama: hay que romper código, y es el anti-patrón que la Fase 4 nombra como
"la fuente #1 de que la tabla no refleje lo que hay".

```bash
git switch -c incidente/04 fase-04-dashboard-tickets
```

En `views/TicketsView.vue`, saca `filteredTickets` de `computed`, decláralo en
`data` como `[]`, y sincronízalo con un watcher sobre `search`:

```js
data: function () {
  return { tickets: [], search: "", statusFilter: "", filteredTickets: [] };
},
watch: {
  search: function () {
    var self = this;
    this.filteredTickets = this.tickets.filter(function (t) {
      return t.title.toLowerCase().indexOf(self.search.toLowerCase()) !== -1 &&
             (self.statusFilter === "" || t.status === self.statusFilter);
    });
  }
}
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Empieza por el final de la cadena y ve hacia atrás. En Vue DevTools, mira las
**props** que recibe la tabla antes y después de cambiar el filtro de estado.
Si no cambian, la tabla está pintando fielmente lo que le dan y el problema está
más arriba.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Con la vista seleccionada en DevTools, fíjate en **qué sección** del panel
aparece `filteredTickets`. No es lo mismo estar en `data` que en `computed`, y la
diferencia explica el ticket entero.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Cuántas entradas alimentan ese cálculo, y cuántas tienen quien las escuche?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** `filteredTickets` es un **dato derivado guardado como dato
crudo**. Vive en `data`, así que solo cambia cuando alguien le asigna, y el único
que le asigna es un watcher sobre `search`. `statusFilter` no tiene quien lo
escuche: cambiarlo actualiza el estado —DevTools lo confirma— y no dispara
ningún recálculo. Teclear en el buscador "arregla" el filtro de estado porque el
watcher recalcula todo de nuevo, incluida la condición que ya estaba puesta.

El contador descuadrado es el mismo bug visto desde otro consumidor: "Mostrando
X de Y" lee `filteredTickets.length` en un momento y la tabla recibe la prop en
otro, y como la copia se actualiza a mano, hay instantes en que ninguno de los
dos coincide.

**Parche mínimo:**

```js
watch: {
  search: function () { this.applyFilters(); },
  statusFilter: function () { this.applyFilters(); }   // el que faltaba
}
```

Funciona, y es exactamente lo que hay que **no** dejar así: acabas de sincronizar
la copia con dos entradas, y el día que llegue un tercer filtro —el de prioridad
del ejercicio 9— vuelve el mismo ticket con otra ropa.

**La refactorización correcta.** El derivado vuelve a ser un `computed` y los
watchers desaparecen:

```js
computed: {
  filteredTickets: function () {
    var self = this;
    return this.tickets.filter(function (t) {
      var matchesSearch = t.title.toLowerCase().indexOf(self.search.toLowerCase()) !== -1;
      var matchesStatus = self.statusFilter === "" || t.status === self.statusFilter;
      return matchesSearch && matchesStatus;
    });
  }
}
```

Vue anota qué leyó el computed —`tickets`, `search`, `statusFilter`— y lo marca
sucio cuando cualquiera cambia. Un filtro nuevo entra en la condición y se
actualiza solo: no hay nada que sincronizar porque no hay copia.

**Prueba de regresión.** El test que importa no prueba el computed —eso lo
garantiza Vue— sino el **comportamiento** que se rompió:

```js
// tests/unit/TicketsView.spec.js
it("refleja el filtro de estado sin necesidad de tocar la búsqueda", function () {
  var wrapper = shallowMount(TicketsView, { … });
  wrapper.setData({ tickets: fixtures.mixed, search: "", statusFilter: "" });
  expect(wrapper.vm.filteredTickets).toHaveLength(8);

  wrapper.setData({ statusFilter: "open" });
  expect(wrapper.vm.filteredTickets).toHaveLength(3);
});
```

**Prevención.** Una pregunta en la revisión de código, que cabe en una línea:
**¿este valor es un hecho o es una consecuencia?** Los hechos van a `data`; las
consecuencias, a `computed`. Y una señal de alarma barata: un `watch` que
**escribe** en `data` casi siempre es un `computed` mal escrito. Búscalos:

```bash
grep -rn "watch:" -A 6 src/views src/components | grep -n "this\.\w* ="
```

**Por qué llegó a producción.** Casi siempre por rendimiento mal entendido:
alguien vio que el computed se recalcula en cada tecla —cosa cierta, y visible
con 5.000 tickets— y "optimizó" guardando el resultado. La intuición era
razonable; la solución correcta a ese problema era un `debounce` sobre la
entrada, no una copia del derivado. El sistema no tenía forma de avisar de que la
copia se había quedado atrás: un `data` desactualizado se ve exactamente igual
que uno correcto.

**Si tu causa fue distinta a ésta.** Si concluiste "falta `:key` en el `v-for`",
la evidencia que lo tumba es el paso 1: la prop llegó con la misma longitud, así
que el problema no es qué fila es cuál. Y si acabaste poniendo un
`this.$forceUpdate()`, funciona y es la peor salida posible — repinta con la copia
vieja y convierte un bug reproducible en uno intermitente.

</details>

---

## Incidente 05 — "Le puse la etiqueta y la tabla no se enteró"

> **Fase:** 5 · **Categoría:** Reactividad · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "Abro el ticket #3, le agrego la etiqueta 'facturación' desde el formulario de
> edición, le doy guardar y me dice que se guardó. Pero en la tabla el ticket
> sigue sin etiqueta. Si recargo con F5 ahí sí aparece. A veces me pasa y a veces
> no, no sé de qué depende."

**Reportado por:** agente de soporte · **Ambiente:** desarrollo y UAT

### 🎯 Qué se te pide

Reproducirlo —el "a veces sí y a veces no" es un dato, no ruido del reporte:
averigua **de qué depende** antes de tocar nada—, decir en qué capa vive, y
aplicar el parche mínimo. Y después, la parte que separa el arreglo del
entendimiento: explicar por qué el mismo código funciona con unos tickets y no
con otros.

### 🔧 Preparación

Un `db.json` alterno: el bug solo se ve con tickets que **no traen** el campo
`tags` desde el mock, y la semilla actual se lo pone a todos.

```bash
git checkout -- db.json          # guarda antes lo que tengas
cp mock/db.incidente-05.json db.json
```

El archivo alterno es el `db.seed.json` con una sola diferencia: a los tickets
1 y 3 se les quitó por completo la clave `tags` (no vacía: **ausente**).

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El dato correcto ya está en la aplicación. Compara, en Vue DevTools, lo que dice
el objeto del ticket en el estado con lo que pinta la fila. No es un problema de
red: Network no tiene nada que contarte aquí, y comprobarlo cuesta cinco
segundos.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

De los tickets de la tabla, unos se actualizan y otros no. Mira qué tienen en
común los que **sí**. Fíjate en la respuesta del mock —el objeto tal como llega—,
no en el que arma el formulario.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿En qué momento exacto de la vida de ese objeto apareció la propiedad `tags`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Vue 2 hace reactivas las propiedades que **existen en el momento
en que el objeto entra en `data`**. Los tickets que el mock devuelve sin `tags`
entran sin esa propiedad, y el `ticket.tags = […]` posterior crea una propiedad
que ningún getter/setter vigila. El dato está —por eso DevTools lo muestra— y la
tabla nunca se entera. Con F5 el ticket vuelve a entrar, esta vez con `tags`
porque el mock ya lo guardó, y todo funciona: de ahí el "a veces".

Es la limitación de reactividad más famosa de Vue 2, la que Vue 3 resolvió con
Proxies, y la que explica que exista `Vue.set`.

**Parche mínimo** — el del viernes a las seis:

```js
// views/TicketsView.vue — al aplicar el ticket actualizado
onTicketUpdated: function (updated) {
  var index = this.tickets.findIndex(function (t) { return t.id === updated.id; });
  // splice y no tickets[index] = updated: la asignación por índice en un array
  // tampoco es reactiva en Vue 2. Son las dos caras de la misma limitación.
  if (index === -1) {
    this.tickets.push(updated);
  } else {
    this.tickets.splice(index, 1, updated);
  }
}
```

**La refactorización correcta.** El problema de fondo no es el `splice`: es que
el frontend acepta del mock tickets con **forma incompleta**. Normalizar en la
frontera hace que la limitación de reactividad no pueda dispararse nunca:

```js
// services/ticketService.js
function normalizeTicket(raw) {
  return {
    id: raw.id,
    title: raw.title || "",
    description: raw.description || "",
    status: raw.status || "open",
    priority: raw.priority || "medium",
    assignee: raw.assignee || null,
    tags: raw.tags || []          // ← el campo existe SIEMPRE
  };
}

function getTickets(params) {
  return apiClient.get("/tickets", { params: params }).then(function (res) {
    return res.data.map(normalizeTicket);
  });
}
```

Con eso, cada ticket entra al estado con todas sus propiedades declaradas, y la
tabla se entera de cualquier cambio sin ceremonias. **Es la misma idea que un
DTO en tu backend de siempre:** la frontera es el sitio donde los datos ajenos se
convierten en datos con forma conocida.

**Prueba de regresión.**

```js
// tests/unit/ticketService.spec.js
it("normaliza los tickets que llegan sin tags", function () {
  apiClient.get.mockResolvedValue({ data: [{ id: 1, title: "X", status: "open" }] });
  return ticketService.getTickets().then(function (tickets) {
    expect(tickets[0].tags).toEqual([]);
    expect(Object.prototype.hasOwnProperty.call(tickets[0], "tags")).toBe(true);
  });
});
```

**Prevención.** Dos hábitos, los dos baratos: normalizar en el servicio todo lo
que venga de fuera, y desconfiar de cualquier `objeto.campoNuevo = valor` sobre
algo que ya vive en el estado. El segundo se puede buscar a ojo en una revisión;
el primero se escribe una vez por servicio y protege para siempre.

**Por qué llegó a producción.** Porque en desarrollo la semilla es completa: todos
los tickets del `db.json` traen todos los campos, así que la propiedad siempre
existía cuando el objeto entraba y el bug era invisible. El primer ticket sin
`tags` lo creó un usuario meses después, por un camino que no ponía el campo.
Nadie se equivocó al escribir el código; el sistema confiaba en una forma de dato
que nadie hacía cumplir.

**Si tu causa fue distinta a ésta.** Si tu conclusión fue "el PATCH no devuelve
el ticket completo", compruébalo en Network: json-server devuelve el documento
entero, y esa evidencia lo descarta. Si acabaste en "hay que recargar la lista
tras guardar", funciona y esconde el bug detrás de un viaje a la red — y el
mismo error volverá en la primera pantalla donde recargar no sea aceptable.

</details>

---

## Incidente 06 — "Volví atrás en el asistente y perdí la descripción"

> **Fase:** 6 · **Categoría:** Formularios y wizard · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "Estoy creando un ticket con el asistente. Lleno el paso 1, paso al 2, me doy
> cuenta de que el título estaba mal y le doy 'Atrás'. El título sigue ahí, pero
> la descripción se borró. Y los avisos rojos de los campos mal llenados también
> desaparecieron, aunque siguen mal. Además, hoy me dejó llegar al final con el
> paso 2 en blanco y me creó el ticket incompleto."

**Reportado por:** agente de soporte · **Ambiente:** desarrollo

### 🎯 Qué se te pide

Son **dos** problemas en un solo ticket y hay que separarlos: lo que se pierde al
volver, y lo que el asistente deja pasar. Para el primero, explica por qué una
parte sobrevive y otra no —esa asimetría es el diagnóstico—. Para el segundo,
decide dónde tiene que vivir la validación y defiéndelo en dos líneas.

### 🔧 Preparación

Una rama: hay que quitar dos cosas que la fase pone a propósito.

```bash
git switch -c incidente/06 fase-06-wizard-minimo
```

En `views/TicketWizardView.vue`: quita el `<keep-alive>` que envuelve al
`<component :is>`, y en el método que avanza de paso, quita la llamada a
`validate()` del paso actual (deja solo la validación final).

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Pon un `console.log` en `created` del primer paso y navega adelante y atrás
mirando la consola. Lo que veas ahí contesta la primera mitad del ticket sin
abrir ningún archivo más.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Compara, en Vue DevTools, el `draft` del componente padre con el `form` del paso.
¿Qué campos coinciden y cuáles no? ¿Y en qué momento el paso le entrega sus datos
al padre?

Para la segunda mitad: ¿quién decide si se puede avanzar, y cuándo se lo
pregunta al paso?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`$v` —el estado de validación— ¿de quién es? ¿Del asistente o del paso?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos causas independientes que el reporte junta porque se ven en
la misma pantalla:

1. *Lo que se pierde.* `<component :is>` **destruye y monta** por diseño: al
   avanzar, el componente del paso 1 deja de existir; al volver, nace uno nuevo
   y vacío. Lo que sobrevive es lo que el paso ya había **entregado** al `draft`
   del padre —el título, validado y entregado al avanzar— y lo que no llegó a
   entregarse muere con el componente. El estado de validación (`$v`) es del
   componente, así que nace virgen: por eso los avisos rojos desaparecen aunque
   el campo siga mal.
2. *Lo que deja pasar.* La validación se hace solo al final, así que avanzar de
   paso no pregunta nada. El usuario descubre en el paso 3 que el 2 estaba mal —
   o directamente no lo descubre, y el ticket se crea incompleto.

**Parche mínimo:**

```vue
<keep-alive>
  <component :is="currentStepComponent" ref="stepComponent" />
</keep-alive>
```

```js
goNext: function () {
  var step = this.$refs.stepComponent;
  if (step.validate && !step.validate()) { return; }   // valida por paso
  this.draft = Object.assign({}, this.draft, step.getData());
  this.currentStep = this.currentStep + 1;
}
```

**La refactorización correcta.** Con `keep-alive` los pasos dejan de morir, y eso
cambia una regla del ciclo de vida que hay que escribir en el código o alguien la
va a pisar: `created` y `mounted` **ya no se repiten**. Si un paso necesita
refrescar algo al volver, el hook es `activated`. Conviene dejarlo comentado
justo ahí, porque es el efecto secundario que sorprende a todo el mundo.

Y una decisión de diseño que va con el segundo problema: **validar al avanzar,
nunca al retroceder**. Bloquear "Atrás" con un paso inválido es una de las peores
experiencias posibles — atrapas al usuario en un paso que no sabe arreglar.

**Prueba de regresión.**

```js
// tests/unit/TicketWizardView.spec.js
it("no avanza si el paso actual es inválido", function () {
  var wrapper = shallowMount(TicketWizardView, { … });
  wrapper.vm.$refs.stepComponent = { validate: function () { return false; },
                                     getData: function () { return {}; } };
  wrapper.vm.goNext();
  expect(wrapper.vm.currentStep).toBe(1);
});

it("conserva lo entregado al volver atrás", function () { … });
```

**Prevención.** Cuando una pantalla intercambie componentes dinámicamente,
escribe en el código —en un comentario de dos líneas— **qué muere con cada
intercambio**. Es el tipo de conocimiento que se pierde en cuanto el autor
original cambia de proyecto, y que reaparece como este ticket.

**Por qué llegó a producción.** Porque en el camino feliz no se nota: quien
prueba el asistente lo recorre hacia adelante, llena todo bien y crea el ticket.
Volver atrás con datos a medias es un camino que solo aparece cuando lo usa
gente de verdad. Y la validación al final parecía razonable —"valido cuando
tenga todo"— hasta que alguien llegó al paso 3 con el 1 roto.

**Si tu causa fue distinta a ésta.** Si concluiste que "se borra el borrador",
compruébalo en DevTools: el `draft` del padre está intacto, y esa evidencia
manda. Si tu fix fue meter el borrador en Vuex, resuelve otro problema —el de
pasos en rutas distintas— y deja este igual: `$v` seguiría muriendo con el
componente, porque nunca estuvo en el borrador.

</details>

---

## Incidente 07 — "A la media hora la laptop suena como un avión"

> **Fase:** 7 · **Categoría:** Reactividad · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1-1,5 h

### 🎫 El ticket

> "El sistema arranca bien pero se va poniendo lento durante la mañana. Sobre
> todo si entro y salgo varias veces de la pantalla de métricas: después todo va
> pesado, hasta escribir en el buscador se siente con retraso, y al rato se
> enciende el ventilador. Cierro la pestaña, la vuelvo a abrir y queda como
> nueva. No sale ningún error."

**Reportado por:** coordinadora de soporte · **Ambiente:** desarrollo y UAT

### 🎯 Qué se te pide

Un bug de degradación no se diagnostica buscando qué se rompe, sino **qué se
acumula**. Se te pide: reproducirlo de forma medible (un número antes y un número
después, no una sensación), identificar las **dos** causas —hay dos, y son
independientes—, y arreglar las dos. El entregable incluye la medición: sin ella
no puedes demostrar que lo arreglaste.

### 🔧 Preparación

Una rama, y dos roturas que la fase advierte por separado:

```bash
git switch -c incidente/07 fase-07-metricas-minimas
```

En `components/metrics/StatusDoughnut.vue` y en `AgentBarChart.vue`:

1. mueve la instancia del chart a `data` (`data: function () { return { chart: null }; }`
   y `this.chart = new Chart(...)` en `mounted`);
2. comenta el hook `beforeDestroy` entero.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Empieza por lo gratis: entra y sal de `/metrics` cinco veces con la consola
abierta. Si aparece un error de chart.js, tienes media investigación resuelta.
Si no aparece nada, estás ante la versión silenciosa y hay que medir.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

En Vue DevTools, selecciona el componente del gráfico y mira **qué aparece en el
panel de datos**. Si la instancia de la librería está ahí dentro, pregúntate qué
le hace Vue a todo lo que vive en `data`.

Y para lo que se acumula: DevTools → Memory → *Heap snapshot*, uno al cargar y
otro después de entrar y salir cinco veces. Filtra por `Chart`.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Quién le avisa a chart.js de que tu componente murió?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos, independientes, y cada una basta para producir el síntoma:

1. *La instancia en `data`.* Vue 2 observa recursivamente todo lo que pongas ahí:
   recorre el objeto entero y le pone getters y setters a cada propiedad. Una
   instancia de chart.js es un objeto enorme con referencias circulares al
   canvas, al contexto y a sus datasets internos — envolverlo cuesta memoria,
   cuesta CPU en cada cambio y puede romper la librería, que no espera que sus
   propiedades internas estén interceptadas.
2. *La ausencia de `beforeDestroy`.* Nadie llama a `chart.destroy()`, así que
   cada visita a la vista deja un gráfico vivo: con sus listeners de `resize`
   atados a `window`, sus animaciones agendadas y su canvas referenciado, de modo
   que el recolector de basura no puede llevarse nada. Cinco visitas, cinco
   charts trabajando en cada repintado. Ése es el ventilador.

**Parche mínimo** — el del viernes a las seis:

```js
// components/metrics/StatusDoughnut.vue
mounted: function () {
  // Propiedad de instancia FUERA de data: Vue no la observa.
  this.chart = new Chart(this.$refs.canvas, this.buildConfig());
},
beforeDestroy: function () {
  if (this.chart) {
    this.chart.destroy();   // el aviso que la librería no puede darse sola
    this.chart = null;
  }
}
```

**La refactorización correcta.** El patrón se repite en los dos gráficos y se va
a repetir en el siguiente, así que se extrae una vez y se deja de discutir. La
fase lo propone como mixin —muy de la época— y es el sitio natural para el
contrato de tres tablones: nacimiento en `mounted`, actualización en `watch`,
muerte en `beforeDestroy`.

```js
// mixins/chartLifecycle.js
export default {
  mounted: function () { this.chart = this.createChart(); },
  beforeDestroy: function () { if (this.chart) { this.chart.destroy(); this.chart = null; } },
  watch: {
    chartData: {
      deep: true,
      handler: function () {
        if (!this.chart) { return; }
        this.chart.data = this.buildData();
        this.chart.update();          // update, no recrear
      }
    }
  }
};
```

Y una advertencia que hay que dejar escrita en el mixin: si algún día el
componente vive dentro de un `<keep-alive>` (Fase 6), `beforeDestroy` **no
corre** y hay que usar `deactivated`. Es exactamente el mismo bug con otro ciclo
de vida.

**Prueba de regresión.**

```js
// tests/unit/StatusDoughnut.spec.js
it("destruye la instancia del chart al desmontarse", function () {
  var destroy = jest.fn();
  Chart.mockImplementation(function () { return { destroy: destroy, update: jest.fn() }; });

  var wrapper = shallowMount(StatusDoughnut, { propsData: { tickets: [] } });
  wrapper.destroy();

  expect(destroy).toHaveBeenCalledTimes(1);
});

it("no expone la instancia como dato reactivo", function () {
  var wrapper = shallowMount(StatusDoughnut, { propsData: { tickets: [] } });
  expect(Object.keys(wrapper.vm.$data)).not.toContain("chart");
});
```

**Prevención.** Una regla de revisión con nombre propio: **todo lo que se crea en
`mounted` y vive fuera de Vue, se destruye en `beforeDestroy`**. Charts, mapas,
editores, `setInterval`, listeners de `window`, suscripciones a un socket. Y una
comprobación de dos segundos en cada revisión de un componente que integre una
librería: buscar `destroy`, `clearInterval` o `off` en el archivo. Si no
aparecen, hay una pregunta que hacer.

**Por qué llegó a producción.** Porque nada falla. El componente funciona
perfectamente la primera vez, la segunda y la décima; lo único que cambia es
cuánta memoria queda. Los bugs de acumulación no tienen un momento de fallo que
alguien pueda reportar, así que se manifiestan como una queja difusa —"va
lento"— que llega semanas después y nadie asocia con una pantalla concreta. La
instancia en `data`, además, es el camino que sugiere el propio framework: es
donde uno pondría cualquier otra cosa.

**Si tu causa fue distinta a ésta.** Si tu conclusión fue "son demasiados
tickets", el snapshot lo desmiente: lo que crece son instancias de `Chart`, no
filas — y el sistema va peor con **los mismos datos** que hace diez minutos. Si
te encontraste con `Canvas is already in use`, encontraste la versión ruidosa del
mismo bug y llegaste por el camino corto: es igual de válido, dilo así en el
post-mortem.

</details>

---

## Incidente 08 — "Se me duplican los tickets cuando entra uno nuevo"

> **Fase:** 8 · **Categoría:** Tiempo real · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1-1,5 h

### 🎫 El ticket

> "Cuando alguien crea un ticket, a mí me aparece en la lista dos veces. A veces
> tres. Me pasa sobre todo al final de la mañana, cuando ya llevo un rato usando
> el sistema y he ido entrando y saliendo de las pantallas. Si recargo la página
> queda uno solo, bien."

**Reportado por:** agente de soporte · **Ambiente:** desarrollo y UAT

### 🎯 Qué se te pide

Reproducirlo de forma **determinista** —"al final de la mañana" tiene que
convertirse en tres pasos concretos—, localizar la capa y arreglarlo. Y una
segunda entrega que es la valiosa: el sistema tiene una 💸 deuda declarada que
este incidente roza. Encuéntrala, explica en dos líneas por qué es correcta hoy y
qué haría falta para pagarla.

### 🔧 Preparación

Una rama, con la rotura que la propia fase propone como experimento:

```bash
git switch -c incidente/08 fase-08-websockets-minimos
```

En `views/TicketsView.vue`, comenta la línea del `off` dentro de
`beforeDestroy`. Después: entra a `/tickets`, sal a otra vista, vuelve; repítelo
tres veces y crea un ticket desde otro navegador.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Cuenta. ¿Cuántas veces llega el evento y cuántas veces se aplica? No es la misma
pregunta, y la pestaña **WS** de Network contesta la primera sin ambigüedad: un
solo frame o varios.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Si el frame llega **una** vez y la fila aparece tres, el problema no es el
servidor ni la red: es cuántos oyentes tiene ese evento en tu navegador. ¿Qué
pasa cada vez que entras a la vista? ¿Y cada vez que sales?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Para dar de baja a un oyente hace falta pasar **la misma referencia** que se dio
de alta. ¿La tuya lo es?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El evento llega **una** vez —la pestaña WS lo confirma: un solo
frame— y se aplica N veces, una por cada vez que la vista se montó sin darse de
baja al salir. Cada `mounted` suscribe un handler nuevo al singleton del socket y
cada `beforeDestroy` que no llama a `off` deja el anterior vivo. Los handlers
zombis sobreviven al componente, y como el singleton del socket vive fuera de
Vue, nadie los limpia.

El "al final de la mañana" es el contador de navegaciones: tres entradas a la
vista, tres filas por ticket.

Hay una variante del mismo bug que produce el síntoma **aunque el `off` esté
escrito**:

```js
mounted: function () {
  socketService.on("ticket:created", this.onTicketCreated.bind(this));   // ⚠️
},
beforeDestroy: function () {
  socketService.off("ticket:created", this.onTicketCreated.bind(this));  // ⚠️ otra función
}
```

Cada `.bind(this)` crea una **función nueva**: el `off` intenta dar de baja a
alguien que nunca se suscribió, y no falla ni avisa. Por eso la fase guarda la
referencia:

**Parche mínimo:**

```js
mounted: function () {
  this.loadTickets();
  this.onCreatedHandler = this.onTicketCreated.bind(this);   // UNA referencia
  socketService.on("ticket:created", this.onCreatedHandler);
},
beforeDestroy: function () {
  socketService.off("ticket:created", this.onCreatedHandler); // la MISMA
}
```

**La refactorización correcta.** Mientras cada vista se suscriba por su cuenta,
este bug puede volver en la siguiente pantalla que escuche sockets — y el Curso
01 ya tiene dos (`TicketsView` y el panel de soporte). La solución estructural es
la de la Fase 10: **el socket alimenta al store una sola vez**, mediante un
plugin de Vuex, y las vistas dejan de suscribirse. Un solo punto de alta, ningún
punto de baja que olvidar, y todas las vistas conectadas se enteran gratis.

Como defensa adicional, el handler puede volverse idempotente:

```js
onTicketCreated: function (ticket) {
  var exists = this.tickets.some(function (t) { return t.id === ticket.id; });
  if (exists) { return; }
  this.tickets.unshift(ticket);
}
```

Eso no arregla la fuga de handlers —sigue habiendo tres— pero impide que se note
en los datos, que es lo que le importa al usuario mientras haces el arreglo de
verdad.

**Prueba de regresión.**

```js
// tests/unit/TicketsView.spec.js
it("da de baja el handler al desmontarse", function () {
  var wrapper = shallowMount(TicketsView, { … });
  var handler = wrapper.vm.onCreatedHandler;
  wrapper.destroy();
  expect(socketService.off).toHaveBeenCalledWith("ticket:created", handler);
});

it("no duplica un ticket que ya está en la lista", function () {
  var wrapper = shallowMount(TicketsView, { … });
  wrapper.setData({ tickets: [{ id: 7, title: "X" }] });
  wrapper.vm.onTicketCreated({ id: 7, title: "X" });
  expect(wrapper.vm.tickets).toHaveLength(1);
});
```

**Prevención.** La regla del [incidente 07](#incidente-07--a-la-media-hora-la-laptop-suena-como-un-avión)
otra vez, y no es casualidad: **alta y baja simétricas, con la misma
referencia**. Búscalo con un `grep` en cada revisión de un componente que
escuche algo:

```bash
grep -rn "\.on(" src/ | grep -v node_modules   # y por cada uno, su .off
```

**La deuda que este incidente roza.** Mientras investigas vas a encontrarte con
que el evento `ticket:created` **lo emite el cliente que creó el ticket**, no el
servidor: el servidor de sockets es un relé de veinte líneas que rebota lo que le
llega. Está declarado en la fase como 💸 *el cliente mentiroso*. Es correcto hoy,
porque no hay un backend que persista y anuncie; y su consecuencia es
comprobable en un segundo desde la consola:

```js
> socketService.emit("ticket:created", { id: 999, title: "No existe", status: "open" })
```

Los demás navegadores anuncian un ticket que no está en ninguna base. Para
pagarla hace falta que quien confirma la escritura sea quien anuncia — y eso
llega el día que exista un backend de verdad detrás del `baseURL`.

**Por qué llegó a producción.** Porque el `off` no tiene un fallo visible cuando
falta: la primera vez que usas la vista todo funciona. El bug necesita
**navegación repetida** para manifestarse, y nadie prueba "entrar y salir tres
veces de la misma pantalla" antes de dar por buena una funcionalidad. Y la
variante del `.bind(this)` es peor: el código *parece* correcto, tiene su alta y
su baja simétricas a la vista, y no lo es.

**Si tu causa fue distinta a ésta.** Si viste **varios frames** en la pestaña WS,
tu bug es otro: hay varias conexiones abiertas, probablemente porque alguien
conecta en el `mounted` de cada vista en vez de una vez por sesión. Es un
hallazgo legítimo y el arreglo va en `App.vue`, ligando la conexión a la sesión.

</details>

---

## Incidente 09 — "Tomé el ticket y a mi compañera le sigue apareciendo libre"

> **Fase:** 9 · **Categoría:** Estado · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1-1,5 h

### 🎫 El ticket

> "Tomé el ticket #12 en el panel de soporte. En mi pantalla quedó asignado a mí
> y pasó a 'En progreso'. Ana dice que en la suya sigue apareciendo sin asignar,
> en la cola de pendientes, y ella no ha recargado. Lo peor: hace un rato lo
> tomamos los dos casi a la vez y a los dos nos dijo que era nuestro.
>
> Otra cosa, quizá no tenga que ver: a veces cambio el estado desde el panel
> grande de la derecha y el panel se queda mostrando el estado anterior, aunque
> en la lista de la izquierda sí cambió."

**Reportado por:** agente de soporte · **Ambiente:** UAT, dos usuarios reales

### 🎯 Qué se te pide

Este ticket trae **tres** síntomas y solo dos tienen arreglo en este curso.
Sepáralos:

1. El cambio que no viaja a la otra pantalla.
2. El panel de la derecha que se queda con datos viejos.
3. Los dos agentes que tomaron el mismo ticket.

Para los dos primeros, causa raíz y fix. Para el tercero, **demuestra que no se
puede arreglar bien desde el frontend** y di qué haría falta. Terminar en "esto
no es un bug del cliente, es una garantía que falta en el servidor" es un
entregable completo y de los más útiles que vas a escribir.

### 🔧 Preparación

Sin romper nada: los tres síntomas están en el sistema tal como lo dejó la fase.
Necesitas dos navegadores (uno normal y uno en incógnito), los dos con sesión.

```bash
npm run dev        # mock + sockets + frontend
```

Para el tercer síntoma, dos pestañas con el detalle del mismo ticket libre y
hacer clic en "Tomar" casi a la vez.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Para el primer síntoma, el desempate más barato del track: que Ana recargue con
F5. Lo que veas después de esa recarga parte el problema en dos mitades muy
distintas, y una de las dos queda descartada para siempre.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Mira la pestaña **WS** de Network mientras tomas el ticket. Y después mira qué
eventos conoce el sistema entero:

```bash
grep -rn "socketService.emit\|socketService.on" src/
```

Para el segundo síntoma, compara en Vue DevTools el objeto que tiene la lista con
el que tiene el panel de la derecha. ¿Son el mismo objeto?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Primer síntoma: ¿cuántos tipos de evento emite esta aplicación, y qué acción del
usuario dispara cada uno?

Tercero: entre que tu código comprueba que el ticket está libre y que escribe la
asignación, ¿qué impide que pase algo?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Tres, independientes:

1. *El cambio no viaja.* No hay bug: **el sistema solo emite `ticket:created`**.
   Tomar un ticket es un PATCH y ningún PATCH anuncia nada, así que el sistema
   está vivo a medias — las altas se propagan, las modificaciones no. El F5 de
   Ana lo demuestra: el dato estaba guardado, lo que faltó fue el aviso.
2. *El panel con datos viejos.* El panel guarda el **objeto** del ticket
   seleccionado en vez del `id`. Cuando la lista se actualiza con la respuesta del
   PATCH, el elemento del arreglo se reemplaza por uno nuevo y la copia del panel
   se queda apuntando al viejo. En DevTools se ve directo:
   `selectedTicket === tickets[i]` da `false`.
3. *El doble "tomar".* Entre el `findOne`-equivalente del cliente —comprobar que
   `assignee` está vacío— y el PATCH que escribe hay una ventana, y los dos
   navegadores pasaron por ella. **json-server no tiene forma de rechazar el
   segundo**: aplica el PATCH que le llega, sin condiciones.

**Parche mínimo:**

```js
// views/SupportView.vue — el panel deja de guardar el objeto
data: function () {
  return { tickets: [], selectedId: null };
},
computed: {
  selectedTicket: function () {
    var id = this.selectedId;
    return this.tickets.find(function (t) { return t.id === id; }) || null;
  }
}
```

```js
// tras el PATCH de tomar, anunciar el cambio como se anuncia el alta
.then(function (updated) {
  self.onTicketUpdated(updated);
  socketService.emit("ticket:updated", updated);
})
```

Y el oyente correspondiente en las vistas que muestran listas, con la misma
disciplina de alta y baja del [incidente 08](#incidente-08--se-me-duplican-los-tickets-cuando-entra-uno-nuevo).

**La refactorización correcta.** El parche del `ticket:updated` funciona y
**consolida una deuda**: ahora hay dos eventos que emite el cliente, o sea dos
sitios donde cualquiera puede anunciar algo falso. Vale la pena escribirlo en
`SECURITY-NOTES.md` tal cual: *el que anuncia no es el que persiste*. La
refactorización correcta de verdad no cabe en este curso —requiere un servidor
que confirme la escritura y emita— y por eso este incidente termina en un
diagnóstico y una nota, no en una solución completa.

Lo que sí se refactoriza aquí es el segundo síntoma: **guardar identificadores,
nunca objetos**, y derivar el resto. Con eso, master y detail no pueden
discrepar.

Sobre el tercer síntoma, la demostración que se pide: el cliente puede
**reducir** la ventana releyendo el ticket justo antes del PATCH y abortando si
ya tiene `assignee` —el ejercicio 20 de la fase lo propone—, y eso convierte el
caso frecuente en un mensaje decente ("Ana se te adelantó"). Pero la ventana
sigue existiendo, más pequeña. La única solución real es que la escritura lleve
la **precondición dentro**: *asigna este ticket solo si sigue sin asignar*. Eso
lo tiene que ofrecer el servidor; json-server no lo hace.

**Prueba de regresión.**

```js
// tests/unit/SupportView.spec.js
it("el detalle refleja el ticket actualizado sin cambiar de selección", function () {
  var wrapper = shallowMount(SupportView, { … });
  wrapper.setData({ tickets: [{ id: 12, status: "open", assignee: null }], selectedId: 12 });

  wrapper.vm.onTicketUpdated({ id: 12, status: "in_progress", assignee: "soporte1" });

  expect(wrapper.vm.selectedTicket.status).toBe("in_progress");
  expect(wrapper.vm.selectedTicket.assignee).toBe("soporte1");
});
```

**Prevención.** Dos reglas, las dos verificables en una revisión: **guarda ids, no
objetos**, y **si un cambio de estado importa a más de una pantalla, tiene que
anunciarse**. Un inventario de eventos —qué acciones producen aviso y cuáles
no— en el README del proyecto evita descubrir el hueco cuando lo reporta un
usuario.

**Por qué llegó a producción.** Porque el tiempo real se construyó para el caso
que se veía bonito en la demo: el ticket nuevo que aparece solo, con su toast. Los
cambios de estado no se anunciaron porque nadie los pidió, y el sistema "en vivo"
pasó a estarlo a medias sin que quedara escrito en ninguna parte. Y la carrera
del doble "tomar" no podía verse en desarrollo: hace falta que dos personas hagan
clic a la vez, cosa que no ocurre cuando el equipo es una persona probando.

**Si tu causa fue distinta a ésta.** Si concluiste "el socket se desconectó", la
pestaña WS lo desmiente: la conexión está viva y los tickets nuevos siguen
llegando. Si tu explicación del segundo síntoma fue "falta `:key`", ojo: el
`:key` sobre el panel resuelve **otro** problema de la misma pantalla —los
comentarios del ticket anterior que se ven medio segundo— y no éste.

</details>

---

## Incidente 10 — "El contador del menú dice una cosa y la tabla otra"

> **Fase:** 10 · **Categoría:** Estado (Vuex) · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1-1,5 h

### 🎫 El ticket

> "El menú de la izquierda dice 'Tickets (8)' y cuando entro a la lista hay 11.
> A veces coinciden. Si recargo la página quedan iguales un rato y después se
> vuelven a descuadrar. También me pasó que el spinner de carga se quedó
> encendido en una pantalla en la que ya se veían los datos."

**Reportado por:** coordinadora de soporte · **Ambiente:** desarrollo

### 🎯 Qué se te pide

Encontrar **quién cambia el estado sin dejar rastro** y demostrarlo con
evidencia, no con lectura de código. La herramienta que resuelve este incidente
lleva dos fases instalada y casi nadie la abre; parte del entregable es que
aprendas a leerla.

Y una segunda pregunta, corta: ¿por qué el spinner que se queda encendido
pertenece a este mismo incidente?

### 🔧 Preparación

Una rama con dos roturas pequeñas:

```bash
git switch -c incidente/10 fase-10-vuex-a-fondo
```

1. En `store/index.js`, pon `strict: false`.
2. En `store/modules/ui.js`, comenta `namespaced: true`.
3. En el componente del menú lateral, escribe el contador directamente contra el
   estado: `this.$store.state.tickets.items.push(...)` en algún punto de carga —o
   más simple, haz que una vista modifique `state.tickets.items` sin pasar por
   una mutation.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Vue DevTools tiene una pestaña que hasta ahora no has usado en serio. Ábrela,
reproduce el descuadre, y mira **qué aparece y qué no aparece** en la lista de
mutations mientras el número cambia.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Si el estado cambia y no hay ninguna entrada nueva, la pregunta es quién escribió
sin pasar por el único sitio autorizado. Hay un ajuste del store que convierte
eso en un error inmediato en desarrollo: búscalo y enciéndelo.

Para el spinner: fíjate en el **nombre completo** de las mutations. ¿Todas
llevan el prefijo de su módulo?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Dos módulos con una mutation que se llama igual, y uno de los dos sin declarar su
espacio de nombres. ¿A cuál de los dos le llega el commit?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos problemas que comparten familia:

1. *El contador descuadrado.* Alguien escribe en el state **fuera de una
   mutation**. El registro de DevTools lo delata por omisión: el número cambia y
   no aparece ninguna entrada nueva. Con `strict: true` eso deja de ser
   invisible:

   ```
   Error: [vuex] do not mutate vuex store state outside mutation handlers.
   ```

2. *El spinner eterno.* El módulo `ui` perdió su `namespaced: true`, así que su
   mutation `SET_LOADING` vive en el espacio global junto a la del módulo
   `tickets`. Un `commit("SET_LOADING", false)` llega al que Vuex resuelva
   primero, y el otro se queda encendido. **No hay error**: para Vuex le pediste
   algo que existe.

**Parche mínimo:**

```js
// store/index.js
export default new Vuex.Store({
  modules: { tickets: tickets, ui: ui },
  strict: process.env.NODE_ENV !== "production"   // caro: solo en desarrollo
});
```

```js
// store/modules/ui.js
export default {
  namespaced: true,     // sin esto, sus mutations son de todos y de nadie
  state: state,
  mutations: mutations
};
```

Y el sitio que escribía directo pasa por su mutation:

```js
// antes:  this.$store.state.tickets.items.push(ticket);
this.$store.commit("tickets/UPSERT_TICKET", ticket);
```

**La refactorización correcta.** El parche cierra los dos casos; lo que evita que
vuelvan es una regla de arquitectura escrita y comprobable: **el state solo se
escribe desde mutations, y todos los módulos son `namespaced`.** Lo segundo se
audita con un `grep`; lo primero, con `strict` encendido y una pasada por la
aplicación entera —que es el ejercicio 1 de la fase y debería dar cero
advertencias.

Mientras estás ahí, vale la pena revisar la reincidencia que la fase nombra: las
actions que no devuelven su Promise. Es la misma familia de fallos silenciosos y
produce el mismo tipo de reporte ("la pantalla no reacciona después de guardar").

**Prueba de regresión.**

```js
// tests/unit/store-ui.spec.js
it("el módulo ui está namespaced", function () {
  var store = new Vuex.Store({ modules: { ui: ui, tickets: tickets }, strict: true });
  store.commit("ui/SET_LOADING", true);
  expect(store.state.ui.loading).toBe(true);
  expect(store.state.tickets.loading).toBe(false);   // no se pisaron
});

it("strict caza la escritura directa", function () {
  var store = new Vuex.Store({ modules: { tickets: tickets }, strict: true });
  expect(function () { store.state.tickets.items.push({ id: 1 }); }).toThrow();
});
```

**Prevención.** Tres líneas en la revisión de código, y ninguna cuesta tiempo:

```bash
grep -rn "\$store.state" src/ | grep -v "mapState"    # escrituras directas sospechosas
grep -rLn "namespaced" src/store/modules/             # módulos sin espacio de nombres
```

Y `strict` encendido en desarrollo, siempre. Su coste es real —clona y compara el
estado en cada cambio— y por eso está apagado en producción; su valor es que
convierte un bug invisible en un error con stack trace.

**Por qué llegó a producción.** Porque las dos causas son **silenciosas por
diseño**. Escribir en el state sin mutation funciona: Vuex no lo impide, solo
puede avisarte si se lo pides. Y un módulo sin `namespaced` no es un error de
configuración, es una opción legítima que en un proyecto pequeño hasta se usa a
propósito. Los dos fallos aparecen cuando el proyecto crece lo suficiente para
que dos módulos compartan un nombre — y para entonces nadie recuerda la decisión.

**Si tu causa fue distinta a ésta.** Si tu contador se descuadraba por una acción
con caché que devolvía datos viejos, comprueba el registro: una lectura cacheada
**no produce mutations**, así que si ves `SET_TICKETS` con datos raros no fue la
caché. Y si concluiste "hay que sacar Vuex", ojo con el razonamiento: sin Vuex
este bug seguiría existiendo y no habrías tenido registro para encontrarlo.

</details>

---

## Incidente 11 — "El test pasa solo cuando lo corro aislado"

> **Fase:** 11 · **Categoría:** Testing · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

### 🎫 El ticket

> "El test del servicio de tickets falla desde ayer. Si lo corro solo con `-t`
> pasa perfecto; con la suite entera falla. Yo no toqué ese archivo, toqué el de
> los badges. Ya borré `node_modules` y reinstalé, igual.
>
> Y ya que estamos: hay un test del dashboard que nunca ha fallado en la vida, ni
> cuando rompimos el filtro a propósito la semana pasada. ¿Eso está bien?"

**Reportado por:** un compañero del equipo · **Ambiente:** local y CI

### 🎯 Qué se te pide

Dos entregables, y el segundo vale más que el primero:

1. Arreglar el test que depende del orden, con causa raíz nombrada.
2. Demostrar si el test "que nunca falla" prueba algo. La técnica para
   demostrarlo cabe en una frase y la vas a usar el resto de tu vida
   profesional; si el test resulta ser decorativo, arréglalo o bórralo — las dos
   son respuestas válidas, "dejarlo por si acaso" no.

### 🔧 Preparación

Una rama, con las dos roturas:

```bash
git switch -c incidente/11 fase-11-testing-minimo
```

1. En `tests/unit/store-tickets.spec.js`, comenta el `jest.clearAllMocks()` del
   `beforeEach` y mueve la creación del store fuera del `beforeEach` (que se
   cree una sola vez para todo el archivo).
2. En `tests/unit/TicketsView.spec.js`, quita el `return` de la Promise en el
   test de carga:
   `it("carga tickets", function () { wrapper.vm.loadTickets(); expect(...); })`.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes que el código de los tests, confirma el fenómeno con dos comandos: el test
solo, y la suite en serie. Si en serie también falla, el paralelismo no era la
causa — solo el mensajero.

Y lee el mensaje de fallo entero: cuando dice "esperaba 1 llamada, recibí 3", ya
te está contando media historia.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

¿Qué sobrevive entre un test y el siguiente? Hay dos candidatos en este proyecto:
los mocks (que acumulan llamadas) y cualquier cosa creada **fuera** del
`beforeEach`.

Para el segundo problema: rompe a propósito lo que el test dice probar y vuelve a
correrlo.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un test que llama a una función asíncrona y afirma en la línea siguiente, ¿sobre
qué estado está afirmando?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos patologías con la misma raíz —**estado que sobrevive donde no
debía**— y síntomas opuestos:

1. *El test que depende del orden.* Los mocks son objetos vivos que acumulan
   llamadas: sin `jest.clearAllMocks()` entre tests, el segundo hereda el
   historial del primero y `toHaveBeenCalledTimes(1)` recibe 3. Y el store creado
   una sola vez para todo el archivo arrastra los datos que dejaron los tests
   anteriores, así que la action con caché decide **no** llamar al servicio
   —"ya tengo datos"— y el contador vuelve a no cuadrar. Corrido solo, el archivo
   empieza limpio y todo pasa.

2. *El test que nunca falla.* No hay `return` de la Promise, así que Jest da el
   test por terminado antes de que se resuelva: la aserción corre sobre el estado
   inicial. Rompe el filtro, rompe el servicio, rompe lo que quieras — sigue
   verde. **No es un test: es decoración.**

**Parche mínimo:**

```js
// tests/unit/store-tickets.spec.js
var store;
beforeEach(function () {
  jest.clearAllMocks();          // que un test no herede llamadas del anterior
  store = createStore();         // ni estado del anterior
});
```

```js
// tests/unit/TicketsView.spec.js
it("carga los tickets al montarse", function () {
  ticketService.getTickets.mockResolvedValue([{ id: 1, title: "X", status: "open" }]);
  var wrapper = shallowMount(TicketsView, { … });

  return wrapper.vm.loadTickets().then(function () {   // ← el return que faltaba
    expect(wrapper.vm.tickets).toHaveLength(1);
    expect(wrapper.vm.loading).toBe(false);
  });
});
```

**La refactorización correcta.** El parche arregla dos archivos; lo que evita la
reincidencia es que **cada test construya su propio mundo**. Una fábrica
`createStore()` en los helpers, un `beforeEach` que la use, y la regla de que
nada con estado se declare en el ámbito del archivo. Con eso, el orden de
ejecución deja de importar y `--runInBand` vuelve a ser lo que debe: una
herramienta de diagnóstico, no un parche permanente.

Y para el verde falso, la disciplina que lo hace imposible: **todo test que toque
código asíncrono devuelve algo** —la Promise, o usa `async/await`—. Es
verificable con una regla de ESLint (`jest/valid-expect-in-promise`,
`require-await`), que es mejor que confiar en la revisión humana.

**Prueba de regresión.** Acá la prueba de regresión es peculiar y vale la pena
entenderla: **el test de que el test funciona** es romper el código de producción
y comprobar que se pone rojo.

```bash
# rompe a propósito el filtro y corre la suite
git stash list                      # asegúrate de poder volver
# … edita computed filteredTickets para que devuelva siempre this.tickets …
npx vue-cli-service test:unit
# debe FALLAR. Si pasa, el test no prueba nada.
git checkout -- src/views/TicketsView.vue
```

**Prevención.** Dos hábitos:

- **Rompe a propósito lo que el test dice probar**, al escribirlo. Un minuto, y
  te dice si la red de seguridad existe o es un dibujo de una red.
- Un `grep` de revisión para el verde falso más común:

  ```bash
  grep -rn "it(" -A 3 tests/unit | grep -B 1 "\.then(" | grep -v "return"
  ```

**Por qué llegó a producción.** Porque los dos fallos **se ven como éxito**. Un
test que pasa por el orden pasa la mayor parte del tiempo, y cuando falla se
etiqueta como flaky y se salta. Un test que nunca falla es, para cualquier
tablero de CI, un test perfecto. Ninguna herramienta del proyecto podía
distinguirlos de los buenos: la única forma de saberlo es romper el código a
propósito, y eso no lo hace nadie salvo que sea un hábito instalado.

**Si tu causa fue distinta a ésta.** Si tu test fallaba por selectores acoplados
al DOM —`find(".col-md-6 > div:nth-child(2)")` que se rompe al cambiar la
maquetación— es otro de los errores comunes de la fase y también hay que
arreglarlo, con `data-testid`. Pero fíjate en la diferencia: ese falla
**siempre** después del cambio, no según con quién corra. Los intermitentes son
de estado compartido; los constantes, de acoplamiento.

</details>

---

## Incidente 12 — "En el servidor de pruebas se comporta distinto que en mi máquina"

> **Fase:** 10 · **Categoría:** Build · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

### 🎫 El ticket

> "Subimos la versión nueva a UAT y el dashboard se comporta raro: los contadores
> de arriba a veces se quedan con números viejos y el orden de la tabla cambia
> solo al filtrar. En mi máquina, con `npm run serve`, no pasa nunca. Lo he
> probado veinte veces. Y en UAT tampoco sale ningún error en la consola."

**Reportado por:** el compañero que hizo el despliegue · **Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir en tu máquina un bug que **solo existe en el build de producción**, lo
cual ya es la mitad del trabajo y la parte que casi nadie sabe hacer. Después:
causa raíz, fix, y una explicación en tres líneas de por qué la consola de UAT
está limpia. El entregable incluye el comando exacto con el que reprodujiste.

### 🔧 Preparación

No hace falta romper nada: el bug ya está en el proyecto, esperando el build.
Necesitas ejecutar la aplicación **compilada**, no el servidor de desarrollo.

```bash
npm run build
npx serve -s dist -l 5000     # o cualquier servidor estático
```

Y como escenario, un componente que escriba en el store sin pasar por una
mutation. Si no lo tienes, la rama del [incidente 10](#incidente-10--el-contador-del-menú-dice-una-cosa-y-la-tabla-otra)
te sirve tal cual: es exactamente esa rotura, vista desde el otro lado.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de buscar el bug, busca **la diferencia**. Enumera qué cambia entre
`npm run serve` y el build: no son diez cosas, son tres o cuatro, y una de ellas
está escrita en el `store/index.js` que llevas dos fases mirando.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

`process.env.NODE_ENV` no vale lo mismo en los dos entornos. Busca en el proyecto
todo lo que dependa de esa variable y pregúntate qué deja de hacer cada cosa en
producción.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el vigilante solo está de guardia en desarrollo, ¿qué pasa en producción con
lo que él impedía? ¿Deja de ocurrir, o deja de avisarse?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El bug existe en los dos entornos; lo que cambia es **quién
avisa**. En `store/index.js`:

```js
strict: process.env.NODE_ENV !== "production",   // caro: solo en dev
```

En desarrollo, `strict` lanza un error inmediato en cuanto alguien escribe en el
state fuera de una mutation, así que el bug se caza al primer intento y nunca
llega a manifestarse como dato incorrecto. En el build de producción `strict`
está apagado —cuesta caro, y por eso se apaga—, la escritura furtiva ocurre en
silencio, y sus consecuencias aparecen mucho después y lejos: contadores que no
cuadran, listas que se reordenan solas, y una consola impecable.

Hay un segundo efecto de la misma variable que conviene conocer, porque explica
el resto del "en mi máquina no pasa": **los warnings de Vue solo existen en
desarrollo.** El aviso de mutación de props, el de `:key` duplicada y compañía
desaparecen del bundle de producción. No es que el problema no exista: es que el
build no habla.

**Parche mínimo.** El fix es el del incidente 10 —la escritura pasa por su
mutation— pero el hallazgo de **este** incidente es otro y merece su propia
línea: el ritual de despliegue tiene que incluir una pasada por el build.

```json
{
  "scripts": {
    "preview": "npm run build && npx serve -s dist -l 5000"
  }
}
```

**La refactorización correcta.** Dos movimientos, y el segundo es el valioso:

1. Eliminar la causa (escritura fuera de mutation) y dejar `strict` encendido en
   desarrollo, que es donde tiene que cazarla.
2. Aceptar que **desarrollo y producción son entornos distintos** y tratarlos
   como tales: un paso de `preview` antes de cada despliegue, y una lista corta
   de lo que cambia entre los dos —`strict`, los warnings de Vue, la minificación,
   los source maps— pegada en el README. Esa lista es lo que convierte "en mi
   máquina funciona" en una hipótesis comprobable en vez de una discusión.

**Prueba de regresión.** El test del incidente 10 (`strict` caza la escritura
directa) cubre la causa. Para el entorno, lo que corresponde no es un test sino
una comprobación en el pipeline: que el build se genere y se sirva en CI, y que
al menos un recorrido básico se ejecute contra `dist`, no contra el dev server.

**Prevención.** Una frase, y conviene que esté escrita donde alguien la lea:
**nunca confíes en que "en producción va bien" porque en desarrollo no salió
ningún error.** Es literalmente al revés: producción es el entorno con menos
avisos. Todo lo que dependa de `NODE_ENV` merece una línea en la documentación
del proyecto diciendo qué se pierde.

**Por qué llegó a producción.** Porque el sistema está diseñado para que el
vigilante sea caro y solo esté en desarrollo — que es una decisión correcta, no
un descuido. El error de diseño no fue apagar `strict`, fue **no tener un paso
que ejercitara el build antes del despliegue**. Y el "lo probé veinte veces" del
reporte es cierto y no sirve: veinte veces en el entorno equivocado.

**Si tu causa fue distinta a ésta.** Si tu diferencia entre entornos resultó ser
otra —una variable de `baseURL` distinta, una ruta que solo funciona con el
`historyApiFallback` del dev server, un warning de reactividad que en producción
no sale— has encontrado un miembro legítimo de la misma familia. La lección es la
misma: enumera las diferencias del entorno **antes** de buscar el bug, porque el
bug casi siempre es viejo y lo nuevo es quién lo tapaba.

</details>

---

## 🪞 Retrospectiva

Cuando cierres varios incidentes, vuelve acá y llénala. No es un formalismo: la
lista de causas raíz de un sistema tiene forma, y verla es lo que convierte doce
casos sueltos en criterio.

| ID | Capa donde vivía | Pista que lo resolvió | Cuánto tardaste | Lo habrías visto antes si… |
|---|---|---|---|---|
| 01 | | | | |
| 02 | | | | |
| 03 | | | | |
| 04 | | | | |
| 05 | | | | |
| 06 | | | | |
| 07 | | | | |
| 08 | | | | |
| 09 | | | | |
| 10 | | | | |
| 11 | | | | |
| 12 | | | | |

Tres preguntas para cuando la tabla esté llena:

- **¿Qué capa concentró más incidentes?** Si es el estado —y lo va a ser—, ya
  sabes dónde mirar primero la próxima vez que un ticket sea vago.
- **¿Cuántos se resolvieron sin abrir un archivo de código?** En un curso bien
  hecho son más de la mitad, y ése es el número que justifica todo el track.
- **¿Cuántos terminaron en una deuda 💸 declarada en vez de en un bug?** Saber
  distinguir "esto está mal" de "esto está incompleto a propósito" es la
  diferencia entre un dev senior y uno que reescribe lo que no entiende.

---

## 📌 Pendientes

Lo que salió de los incidentes y no se arregló acá, con el motivo.

- **La sesión no es válida, solo existe** (incidente 03). El guard comprueba que
  el token esté, no que sirva. No se puede arreglar en el frontend: hace falta un
  servidor que conteste 401. Anotado en `SECURITY-NOTES.md`.
- **El que anuncia no es el que persiste** (incidentes 08 y 09). Los eventos de
  socket los emite el cliente que hizo el cambio, así que cualquiera puede
  anunciar algo falso. Correcto mientras el servidor sea un relé; se paga el día
  que exista un backend que confirme la escritura y emita.
- **La carrera del doble "tomar"** (incidente 09). El cliente puede reducir la
  ventana, no cerrarla. Hace falta que la escritura lleve la precondición dentro,
  y eso lo tiene que ofrecer el servidor.
- **`reporter` y `createdAt` los pone el navegador** (fases 5 y 6). Reglas de
  negocio en la capa equivocada, declaradas 💸 desde su fase. Mismo motivo: sin
  backend no hay dónde ponerlas bien.

> 🧭 Los cuatro pendientes tienen algo en común, y no es casualidad: **son
> exactamente los límites de un frontend que le habla a un mock.** Que estén
> escritos, con nombre y motivo, es lo que distingue una deuda técnica de un
> descuido.
