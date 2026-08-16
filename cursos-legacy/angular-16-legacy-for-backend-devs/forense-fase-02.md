# 🕵️ Forense Fase 02 — "Entro con mi usuario y me saca al login sin decir nada"

> Pieza forense de la **Fase 2 — Autenticación mínima** · Recorrido: ~30 min
> Herramientas: pestaña Network (Headers) · breakpoints en un interceptor funcional · `localStorage`
> Síntoma que cubre: la sesión se cae sola, o nunca llega a empezar, y no hay ningún mensaje.

Aquí hay tres piezas que pueden echarte —el guard, el interceptor y el servidor— y las tres producen el mismo síntoma en la pantalla del usuario. Distinguirlas cuesta **diez segundos en Network** y decide en cuál de tres sitios opuestos buscar.

La fase resume las dos preguntas; aquí está el recorrido con los mensajes literales.

---

## 🎫 El ticket

> *"Entro con mi correo y mi clave, veo el listado un segundo, y me devuelve a la pantalla de inicio de sesión. No dice nada. A veces entro bien y a la media hora me pasa lo mismo."*

**Reportado por:** inspector de campo
**Ambiente:** UAT

Dos datos que el reporte trae sin saberlo: **"veo el listado un segundo"** —la navegación sí ocurrió— y **"a la media hora"** —hay un patrón temporal, no es aleatorio—.

---

## 🧭 La ruta

Los cinco pasos van **del más barato al más caro**, no del más probable al menos probable. Mirar una columna de Network cuesta diez segundos y ya parte el problema en dos; poner un breakpoint dentro de un interceptor cuesta diez minutos y sólo se hace cuando los tres primeros no bastaron. El último sale del navegador entero, que es donde se comprueba quién miente.

### Paso 1 — ¿Guard o interceptor? Lo dice Network, sin abrir el código

DevTools → **Network** → filtro `Fetch/XHR` → *Preserve log* **activado**, que es imprescindible: la redirección al login borra el log si no lo está. Reproduce el ticket.

**Caso A — no hay ninguna petición fallida, y la URL acabó en `/login?returnUrl=%2Ftemplates`:**

```
Name        Status    Type
(ninguna petición en rojo)
```

Fue **el guard**. Ni siquiera se intentó hablar con el servidor: `isAuthenticated()` dijo que no y la navegación se canceló antes de empezar. El problema está del lado del cliente: token ausente, token mal leído, o un `exp` que el navegador interpreta como pasado.

**Caso B — hay una petición en rojo con `401` y después la redirección:**

```
Name         Status    Type    Initiator
templates    401       xhr     zone.js:xxxx
```

Fue **el interceptor**. El token existía y parecía válido desde el navegador; el servidor opinó distinto. El problema está del lado del servidor: firma, secreto o expiración real.

**Qué descarta.** Las dos causas no se parecen en nada y llevan a archivos opuestos. Todo lo que sigue depende de cuál de las dos tienes.

### Paso 2 (caso A) — ¿Qué tiene el navegador guardado?

En la consola, con la pantalla del login abierta:

```js
localStorage.getItem('certcore.accessToken');
// null                    → nunca se guardó, o alguien lo borró
// 'eyJhbGciOi…'           → existe: hay que mirarlo por dentro
```

Y si existe, se abre sin ninguna librería:

```js
const token = localStorage.getItem('certcore.accessToken');
const payload = JSON.parse(atob(token.split('.')[1]));
payload;
// { sub: 'INS-15', email: 'inspector@certcore.co', role: 'inspector', exp: 1742131200 }

// La comparación que hace el guard, con los dos números a la vista:
new Date(payload.exp * 1000).toISOString();   // '2025-03-16T12:00:00.000Z'
new Date().toISOString();                     // '2025-03-16T12:31:04.221Z'  ← ya venció
```

**Qué descarta.** Si `exp` está en el pasado, el guard hizo exactamente lo que debía y el ticket no es un bug: es un TTL corto sin aviso al usuario, que es un problema de producto. Si `exp` está en el futuro y aun así te echa, el bug está en cómo el guard lee o compara ese número — y `exp` va en **segundos**, no en milisegundos, que es el error clásico de un factor de mil.

### Paso 3 (caso B) — ¿Qué cabecera puso quién?

Clic en la petición con `401` → pestaña **Headers** → sección **Request Headers**:

```
Authorization:      Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9…
X-Correlation-Id:   3f2a9c1e-77b4-4a0e-9f21-8d5c6b1e0a44
```

Las dos cabeceras las ponen piezas de generaciones distintas, y eso convierte la pestaña Headers en un diagnóstico de convivencia 🧬:

| Lo que ves | Qué significa |
|---|---|
| Las dos cabeceras | las dos cadenas de interceptores corren. Todo registrado bien |
| Falta `Authorization` | el interceptor **funcional** no corre → falta `withInterceptors([authInterceptor])` |
| Falta `X-Correlation-Id` | el interceptor **de clase** no corre → falta `withInterceptorsFromDi()` |
| No falta ninguna y el 401 sigue | el token viaja y el servidor lo rechaza: es del servidor |

**Qué descarta.** El caso más traicionero es el tercero, porque **no da ningún error**: `provideHttpClient()` sin `withInterceptorsFromDi()` deja de ejecutar los interceptores de clase registrados en `HTTP_INTERCEPTORS` **en silencio**. El `CorrelationIdInterceptor` de 2021 deja de correr, nadie se entera, y la trazabilidad se corta justo donde más falta hace.

### Paso 4 — Dónde va el breakpoint en un interceptor funcional

Un interceptor funcional tiene **dos momentos**, y poner un solo breakpoint esperando ver los dos es la media hora que se pierde la primera vez.

```ts
export const authInterceptor: HttpInterceptorFn = (request, next) => {
  const authService = inject(AuthService);   // ← MOMENTO 1: al lanzar la petición.
  const router = inject(Router);             //   Aquí ves la URL, el token, la request.

  const authorizedRequest = /* … */;

  return next(authorizedRequest).pipe(
    catchError((error: unknown) => {
      // ← MOMENTO 2: al volver la respuesta, milisegundos o segundos después.
      //   Aquí ves el error. `authService` funciona porque quedó capturado en el
      //   closure, NO porque sigamos en contexto de inyección: un inject() aquí
      //   sería NG0203.
      return throwError(() => error);
    }),
  );
};
```

- **Para inspeccionar lo que sale** —URL, token, cabeceras— el breakpoint va **antes del `return`**.
- **Para inspeccionar lo que vuelve** —status, cuerpo del error— va **dentro del `catchError`**.

Y una comprobación que ahorra el breakpoint entero, con `logpoint` en vez de detenerse:

```js
// Logpoint en la primera línea del catchError (clic derecho sobre el número de
// línea → Add logpoint), sin pausar la ejecución:
`401 en ${request.url} | isLogin=${request.url.endsWith('/auth/login')}`
```

Ese `isLogin` es la mitad del bug clásico de esta fase: si el interceptor no distingue el `401` del **login** —que significa "te equivocaste de contraseña"— del `401` de **cualquier otra ruta** —que significa "tu sesión caducó"—, cada intento fallido de inicio de sesión provoca un `logout()` y una redirección a `/login`, desde `/login`. El bucle no da error; la pantalla parpadea y el usuario dice *"no me deja entrar y no dice nada"*.

**Qué descarta.** Cada momento descarta una cosa distinta, y por eso hacen falta los dos. Si en el **momento 1** la petición ya sale sin `Authorization`, el problema es del token —no llegó, no se guardó, o el servicio lo devuelve vacío— y el interceptor está haciendo su trabajo. Si sale con el token puesto, eso queda descartado y la respuesta manda: el **momento 2** te dice si el `401` viene del login o de otra ruta, que es la distinción que separa el bug clásico de una contraseña mal escrita. Con las dos respuestas, el **Paso 5** confirma contra el servidor quién de los dos miente.

### Paso 5 — Confirmar contra el servidor, fuera del navegador

Cuando la sospecha es del lado del servidor, `curl` quita al navegador de la ecuación:

```bash
# El login, tal cual:
curl -s -X POST http://localhost:3000/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"inspector@certcore.co","password":"certcore123"}'
# {"accessToken":"eyJhbGciOi…","user":{"id":"INS-15","role":"inspector"}}

# Y una ruta protegida con ese token:
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/templates \
  -H "Authorization: Bearer <pega el token aquí>"
# 200 → el token sirve; el problema es del navegador
# 401 → el token no sirve; el problema es del servidor o del propio token
```

**Qué descarta.** Es la separación limpia entre "mi cliente manda mal el token" y "mi servidor rechaza un token bueno". Sin ella, las dos hipótesis se persiguen la cola durante horas.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Quién te echó | Dónde miras |
|---|---|---|
| `/login?returnUrl=…` sin ninguna petición fallida | el guard | `localStorage` y el `exp` del token |
| Petición `401` y después la redirección | el interceptor | el token que viaja, o el servidor |
| Bucle de parpadeo en `/login` al fallar la contraseña | el interceptor, sin distinguir el login | el `isLoginRequest` |
| Falta `Authorization` en Headers | el interceptor funcional no está registrado | `withInterceptors([...])` |
| Falta `X-Correlation-Id` en Headers 🧬 | el de clase no corre, **en silencio** | `withInterceptorsFromDi()` |
| `NG0203` al reproducir | un `inject()` fuera de contexto | **A04** §7 — casi siempre dentro del `catchError` |
| Entra bien y a los N minutos se cae | TTL del token | el `exp`, y `CHAOS=expired` para reproducirlo a voluntad |

---

## ⚰️ Los callejones

**"El guard está protegiendo mal la ruta."** Casi nunca. Y conviene recordar por qué importa poco: **un guard no es seguridad**. Corre en el navegador, el usuario puede pausarlo con el depurador, y lo único que evita es que alguien vea una pantalla vacía con un error feo. Si el ticket dice "vi datos que no debía ver", el bug **no está en el guard**: está en el servidor, que los devolvió.

**"Es la caché del navegador."** No para esto. Un `401` no se cachea, y la petición aparece en Network con su status cada vez. Este callejón es real en la Fase 13, no aquí.

**"El interceptor se está tragando el error."** Comprobable en una línea: si el componente que llamó recibe el error, el interceptor lo relanzó. Si el componente se queda esperando para siempre y no hay nada en consola, entonces sí — y el culpable es un `catchError` que devuelve `EMPTY` en vez de `throwError`. Es el antipatrón que la fase nombra por su nombre.

---

## 🧨 Deshacer

`CHAOS=expired npm run mock` reproduce el token vencido sin tocar código y se apaga al reiniciar el mock. Si para investigar borraste el token a mano, `localStorage.clear()` y vuelve a entrar. Si comentaste `withInterceptorsFromDi()` en `core.module.ts` para ver el efecto, **devuélvelo**: sin esa línea el `CorrelationIdInterceptor` deja de correr y la Fase 13 te va a echar de menos esa cabecera en los logs de nginx.

---

## 🧠 El patrón transferible

> **Cuando tres piezas producen el mismo síntoma, la primera pregunta no es "¿cuál falló?" sino "¿qué evidencia distingue a una de otra?".** Aquí es una sola: si hubo o no una petición fallida. Diez segundos en Network, y el espacio de búsqueda se reduce a un tercio.

Y el segundo, que es propio de este track: **una cadena de interceptores que deja de correr no da ningún error.** Las dos mitades de `provideHttpClient()` registran dos generaciones distintas, y quitar una apaga la mitad del sistema en silencio. La pestaña Request Headers es el único sitio donde eso se ve. 🧬

**Incidentes del cuaderno que usan esta ruta:** 03 (la sesión que se cae sin decir nada).
**Amplía:** **A04** §4 y §7 para `inject()` en interceptores y el `NG0203`, **A06** §6 para qué devolver desde un `catchError`.
