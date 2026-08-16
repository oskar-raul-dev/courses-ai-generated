# 🕵️ Forense Fase 02 — "Me saca al login sin decir nada"

> **Sale de:** [Fase 2 — Autenticación mínima](02-autenticacion-minima.md) ·
> **Herramientas:** DevTools → Application → `localStorage`, Vue DevTools →
> Vuex, y el guard del router · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la aplicación te devuelve a `/login` sin
> mensaje, sin error en consola y sin nada en Network.

Es el primer caso del curso donde **dos copias del mismo dato** no coinciden, y
donde el sistema toma una decisión importante sin dejar rastro. Las dos cosas
son la firma de los bugs de sesión: nadie registra nada, porque el código que
te expulsa no considera que haya pasado algo digno de contarse.

---

## 🎫 El ticket

> "Estaba trabajando normal, le di clic a un ticket de la lista y de golpe me
> apareció la pantalla de login otra vez. No salió ningún mensaje. Volví a
> entrar con mi usuario y ahí sí, todo normal. Me pasó dos veces esta semana,
> las dos como a media mañana."
>
> — agente de soporte · **Ambiente:** desarrollo y UAT

Guarda "no salió ningún mensaje": es el dato más informativo del reporte, y el
que va a orientar el paso 2.

---

## 🧭 La ruta

De lo más barato a lo más caro: primero se mira el almacenamiento (dos clics),
después quién decide la expulsión, después la segunda copia del dato, y solo al
final se toca el código.

### Paso 1 — ¿el token está?

DevTools → **Application** → Storage → Local Storage → `http://localhost:8080`.

```
Key      Value
─────────────────────────────
user     {"username":"admin","name":"Usuario Demo"}
```

**Qué descarta.** Descarta media investigación de una sentada. Si `token` no
está y `user` sí, ya sabes tres cosas: no fue un `logout` (que borra los dos con
`clearSession`), no fue el navegador limpiando el dominio (se habría llevado los
dos), y la sesión quedó **a medias**. Si estuvieran los dos, el problema sería
otro y saltarías al paso 4.

### Paso 2 — ¿quién te sacó?

En esta fase hay exactamente un actor con poder de redirigir, y está en
`router/index.js`:

```js
router.beforeEach(function (to, from, next) {
  var token = localStorage.getItem("token");
  // …
  if (requiresAuth && !token) {
    next("/login");
    return;
  }
```

**Qué descarta.** Descarta el backend, la red y cualquier 401: en la Fase 2 no
hay servidor todavía, y el interceptor de respuesta que expulsa por 401 es la
deuda 💸 que se paga en el ejercicio 24 de la Fase 3. También explica el "sin
mensaje" del reporte: `next("/login")` no muestra nada, no loguea nada y no
pone nada en Network. **El silencio no es un bug del guard: es su diseño.**

### Paso 3 — ¿y el store qué opina?

Vue DevTools → pestaña **Vuex** → módulo `auth`.

```
auth
  token: "mock-jwt-token-123"
  user: { username: "admin", name: "Usuario Demo" }
```

**Qué descarta.** Acá está el hallazgo. El store cree que la sesión sigue viva
—por eso el header seguía mostrando tu nombre hasta que navegaste— y el guard
cree que no hay sesión. Los dos tienen razón, porque **leen de sitios
distintos**: el guard va a `localStorage` y el store tiene su copia en memoria.
La Fase 2 lo dice sin esconderlo en su nota legacy honesta, y ésta es la
consecuencia práctica.

Descarta también "el store se limpió solo", que es la hipótesis natural cuando
uno cree que hay una sola fuente de verdad.

### Paso 4 — ¿y si el token está pero no sirve?

Prueba el caso contrario, que es el que nadie reporta porque no molesta:

```js
> localStorage.setItem("token", "cualquier-cosa")
> // navega a /tickets
```

Entras sin problema.

**Qué descarta.** Descarta la idea de que el guard "valide la sesión". No la
valida: comprueba que la clave `token` exista. Existencia no es validez, y hasta
que en la Fase 3 haya un servidor que conteste 401, nadie en el sistema es capaz
de desmentir un token inventado. Esto no es un fallo de esta fase —está
declarado en sus errores comunes— pero es el que va a producir el reporte
gemelo: *"un usuario dado de baja siguió entrando toda la tarde"*.

### Paso 5 — la reproducción, para poder cerrarlo

Con lo anterior ya sabes dónde está. Falta poder contárselo a alguien, y para
eso hay que reproducirlo a voluntad:

```js
> localStorage.removeItem("token")   // el usuario no hace esto…
> // …pero un script de la página, una extensión o un logout a medias, sí
```

Navega a cualquier ruta con `meta.requiresAuth` y verás la expulsión limpia, sin
mensaje. Ese es el reporte de la agente, reproducido en dos líneas.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves o te cuentan | Dónde empezar |
|---|---|
| Te manda a `/login` sin mensaje y sin nada en Network | El guard: `requiresAuth && !token` |
| El header sigue mostrando tu nombre después de la expulsión | El store conserva su copia; el guard lee `localStorage` |
| Entras con un token inventado | El guard comprueba existencia, no validez |
| Cierras sesión y al volver atrás con el navegador se ve la pantalla anterior | El componente ya estaba montado; la navegación hacia atrás no siempre dispara el guard como esperas |
| Estás en `/login` con sesión válida y te rebota a `/` | Es el segundo `if` del guard, y está haciendo lo correcto |
| Recargas y pierdes la sesión | `getStoredSession` no se está llamando al arrancar la app |
| El request sale sin `Authorization` | El interceptor lee `localStorage`, no el store: si están desincronizados, gana el vacío |

---

## ⚰️ Los callejones

**"Expiró el token."** No hay expiración en esta fase: el token es la cadena
literal `"mock-jwt-token-123"` y no caduca nunca. Lo que sí existe es el
ejercicio 17, que agrega un `expiresAt` — y ahí la hipótesis se vuelve
comprobable. Pídele siempre al reporte una hora: "como a media mañana" invita a
pensar en expiración, y no siempre lo es.

**"Es que el guard corre antes que el store."** Suena bien y es medio cierto,
pero no explica **este** síntoma: el orden de inicialización importa al
arrancar la aplicación, no al navegar entre rutas con todo ya montado. La
evidencia que lo tumba es el paso 3: el store estaba poblado.

**"Hay que mover el token a Vuex y listo."** Es la refactorización correcta
—el ejercicio 24 la propone— pero no es el diagnóstico, y aplicarla a ciegas
puede esconder el síntoma sin explicarlo. Primero se entiende por qué había dos
copias; después se elige cuál sobrevive.

---

## 🧨 Deshacer

Los pasos 4 y 5 te dejan la sesión sucia. Para volver a un estado sano:

```js
> localStorage.clear()
```

Y vuelve a iniciar sesión con `admin` / `1234`. Si además tocaste el guard para
probar, `git checkout -- src/router/index.js`.

---

## 🧠 El patrón transferible

**Cuando el mismo dato vive en dos sitios, el bug no está en ninguno de los
dos: está en que no hay contrato sobre cuál manda.** El guard no está mal
escrito, el store tampoco; lo que falta es la frase "la fuente de verdad de la
sesión es X" escrita en alguna parte y respetada por todos.

Y una segunda cosa, más útil todavía: **las decisiones silenciosas son las más
caras de depurar**. Un `next("/login")` sin log es un sistema tomando una
decisión de seguridad sin dejar rastro; cuando llegues a un legacy ajeno, busca
temprano esos puntos —redirecciones, `catch` vacíos, valores por defecto
silenciosos— porque son los sitios donde el sistema hace cosas que nadie puede
contar después.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 2](02-autenticacion-minima.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo, en el
[incidente 03](cuaderno-incidentes.md); y la continuación natural en la
[pieza de la Fase 3](forense-fase-03.md), donde por fin hay un servidor capaz
de decir que no.
