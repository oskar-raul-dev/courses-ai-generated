# 🧪 Fase 03 — Mock API + Express caos

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · Fase 3 de 11 · **6 horas**
> Depende de: Fase 2 — Autenticación mínima · Habilita: Fase 4 — Ruedas CRUD

---

## 🎯 1. Propósito

La primera reunión con Juliana no es de código: es de la noche de la Esclusa de Oro, con sus 1.047 avatares de mil y sus jugadores con dos premios por un giro. Antes de proponer el API nuevo, quiere ver el viejo bajo carga: *"antes de tocar nada, quiero ver qué hace el API la noche de un evento"*. Esta fase le da ese laboratorio.

Hasta ahora la consola vivía de mentiras piadosas: un login mock que siempre respondía bien y ningún dato real detrás. Esta fase le pone un backend de mentira, pero uno que **falla como falla un backend real**: latencia variable, 503 al azar, timeouts, respuestas rotas y **401 de verdad**. No es capricho. El sistema que vas a mantener tiene un backend con sus propios malos días, y quien lo mantiene necesita practicar en un entorno que se porta igual de mal, pero de forma controlada y reproducible.

Esta fase también es donde el andamiaje de auth de la Fase 2 se enfrenta por fin a un backend áspero. Fase 2 construyó la estructura en el frontend sobre un mundo ideal donde nada fallaba. Acá se cobran dos deudas que quedaron declaradas allá: **la persistencia de sesión** y **el manejo global de 401**. La frontera de diseño es clara: Fase 2 es el andamiaje de auth en el frontend; Fase 3 es ese andamiaje enfrentado a un backend real.

Además, esta fase trae el primer dato del juego que el mock tiene que imitar mal a propósito: el **giro ingenuo de 2019**. El API que heredó la Esclusa resolvía cada giro en tres pasos sin transacción, y ese es el origen de los dobles premios y del stock que se pasa. El mock lo reproduce con sus defectos, y un **generador de tráfico** lo pone bajo la carga de una noche de evento. Y separamos el servicio externo: el mock de **Google Play** vive en su propio servidor, en su propio puerto, con su propio comportamiento.

> 📝 **Nota de convención.** El código del curso va en inglés (identificadores, endpoints, enums), y la narrativa, los comentarios y los textos de interfaz siguen en español. Por eso vas a ver `wheels`, `spinLog` y `status: 'live'` en el código, pero `"El servidor tuvo un problema. Intenta de nuevo."` como mensaje al operador.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `json-server` corre en el puerto `3001`, sirviendo `mock/db.json` (`wheels`, `segments`, `players`, `inventory`, `purchases`, `spinLog`, `stock`, `users`), con CRUD automático desde la consola.
- [ ] La ruta propia `POST /players/:id/spins` existe: es el **giro ingenuo de 2019**. Con `CHAOS_LEVEL` apagado, dos giros con la misma clave dan dos premios, y el stock se pasa de los 1.000 de la Esclusa de Oro.
- [ ] `scripts/traffic.js` pone bajo carga el giro (50 usuarios virtuales, 1.500 claves, cada una enviada dos veces) y `scripts/measure.js` cuenta los dobles y el stock excedido.
- [ ] Middleware de caos (`mock/chaosMiddleware.js`) montado sobre el `3001`: latencia, 503, 401 sobre rutas protegidas, timeouts y respuestas rotas. Se activa con `CHAOS_LEVEL=low` o `CHAOS_LEVEL=high`.
- [ ] El mock de Google Play corre en el puerto `3002` como servidor Express separado: verificación de compras, pago en efectivo que queda `pending` por una demora configurable, y notificaciones que pueden llegar dos veces. La consola **no** lo consume: es el servicio externo, y lo consume `apiStore` desde la Fase 7.
- [ ] **💸 Pago de deuda #1 (persistencia de sesión):** `token` y `user` se rehidratan desde `localStorage` al arrancar, y se sincronizan en login y logout.
- [ ] **💸 Pago de deuda #2 (manejo global de 401):** el interceptor de response de `apiClient` detecta un 401, despacha `logout` y manda a `/login`.
- [ ] Un 5xx del mock se muestra como un mensaje legible en el login, no como el texto de axios.

---

## 🚫 3. Qué queda fuera por ahora

- **Paginación server-side** en `json-server`: se difiere. Con el volumen de este curso no hace falta.
- **El epic que consuma el mock de Google Play** (polling, debounce, cancelación): Fases 6 y 7. Acá solo dejamos el mock funcionando y fallando.
- **Refresh token y renovación silenciosa de sesión**: fuera de alcance. El 401 acá termina en logout, no en un intento de renovar el token.
- **Persistencia real del mock entre reinicios**: `db.json` se restaura a mano desde su copia; no hay seed automatizado.
- **El resultado de la conciliación y los premios en dinero**: Fases 7 y 8. El giro de esta fase siempre cae en la Esclusa de Oro: lo que se mide es la carrera, no el sorteo, que llega con los pesos de la rueda.
- **Depurar el build de producción** (source maps, comparar ambientes): `A13-depurar-el-build-de-produccion.md`.

---

## 🧠 4. Conceptos mínimos

**¿Por qué dos servidores mock y no uno solo?** Porque el API de ruedas y el servicio de Google Play tienen perfiles de fallo distintos en producción. El API es tu propio backend, relativamente estable. Google Play es un servicio externo con su propio SLA, su propia latencia y sus propios apagones. Si mezclas el caos de ambos en el mismo servidor, cuando algo falle no vas a saber si el problema es "nuestro backend" o "el proveedor", y esa ambigüedad es exactamente la que un dev de mantenimiento aprende a distinguir rápido.

**`json-server`** te da un CRUD completo leyendo y escribiendo sobre un archivo `db.json`, sin que escribas una sola ruta. Lo usamos para todo lo que es lectura y escritura simple. El giro ingenuo es la excepción: es una ruta propia, porque el giro tiene reglas que el CRUD no expresa.

**El giro ingenuo, paso a paso.** El API viejo resolvía un giro en tres viajes a la base, sin transacción: (1) leer el stock, (2) decidir si queda, (3) escribir el descuento y la bitácora. Si dos peticiones leen el stock antes de que la primera escriba, las dos ganan. Y como nada guarda la clave del giro, un reintento del cliente también gana. El mock hace lo mismo y deja una pausa entre viaje y viaje, para que las peticiones se entrelacen como lo hacían en producción.

> 🧭 **Cómo se calibra la pausa.** La pausa (`STEP_DELAY_MS`, 2 ms por defecto) es el parámetro que decide cuánto dura la ventana entre leer y escribir. Con 0 ms o 1 ms, o con 2 ms, el número de dobles y de stock excedido cae en el rango que dio el mismo giro contra PostgreSQL en el laboratorio del curso. Con 3 ms ya no hay carrera apreciable. La pausa no es un número mágico: es la forma de que la ventana de 2019 exista en el mock. Por eso las cifras que el curso publica son las de la corrida de esta fase, y no se copian de otra.

**El middleware de caos** es un middleware de Express que se mete *antes* de que la petición llegue a su handler normal. Decide, con una probabilidad, si la deja pasar, la retrasa, la contesta con un 503, la deja sin respuesta (timeout), le devuelve un JSON roto, o —sobre rutas protegidas— responde `401`. No hay magia: es un generador de números aleatorios y `setTimeout()` con buen criterio, y con una semilla (`CHAOS_SEED`) la secuencia se repite.

**¿Por qué el 401 aparece recién ahora?** En la Fase 2 el manejo de 401 quedó como ejercicio, porque `json-server` no emite 401 por sí solo, y un interceptor que lo manejara habría sido código muerto. Ahora que el caos inyecta un 401 real sobre rutas protegidas, el manejo deja de ser teoría y se sube al código base.

**`CHAOS_LEVEL`** decide qué tan agresivo es el caos:

| Nivel | Latencia | 503 | 401 (rutas protegidas) | Sin respuesta (timeout) | JSON roto | Uso típico |
|---|---|---|---|---|---|---|
| `off` | 0 ms | 0 % | 0 % | 0 % | 0 % | Desarrollar features sin ruido. |
| `low` | 100–800 ms | 5 % | 0 % | 0 % | 0 % | Trabajo del día a día, algo de fricción real. |
| `high` | 300–1.500 ms | 15 % | 10 % | 2 % | 2 % | Reproducir incidentes y la pieza forense. |

> 📝 **Nota de época.** En producción este "modo caos" nunca existió como tal: el caos venía gratis, sin avisar, un martes a las 4 de la tarde. Acá lo hacemos explícito y controlable, porque el objetivo es entrenar el ojo, no sufrir al azar.

> 📝 **Nota de convivencia.** El interceptor de request de `apiClient` viene de la Fase 2 y no se reescribe. Acá le sumamos un interceptor de response para el 401, y el timeout de la instancia. Ambos conviven en la misma instancia.

---

## 💻 5. Implementación y código comentado

Vamos de abajo hacia arriba: primero los datos del mock, después el servidor, después los servicios externos y el tráfico, y al final los pagos en el frontend. Antes, instala las dependencias de la fase, con versión exacta:

```bash
npm install --save-exact history@4.10.1
npm install --save-dev --save-exact express@4.17.1 cors@2.8.5 dotenv@10.0.0 concurrently@6.5.1
```

`history` es el paquete que React Router 5 usa por debajo. Lo declaramos explícitamente porque el interceptor, que vive fuera de React, necesita el mismo objeto de historial que el router. `express` es el servidor del mock: `json-server` lo trae por dentro, pero en una versión que no fijamos nosotros, y el código de esta fase lo importa directo. `concurrently` levanta los dos mocks con un solo comando (`npm run mock:all`). `cors` y `dotenv` quedan instalados desde ya, como dice `00-decisiones-y-versiones.md` §4, aunque los usen fases posteriores.

### 5.1 Los datos del mock: `mock/db.json`

El archivo ya no es solo de usuarios. Estos son los recursos que la Fase 3 necesita, con los nombres que fija el curso (`00-decisiones-y-versiones.md` §7). Un fragmento, para leer la forma; el archivo completo está en el repo del alumno.

```json
{
  "wheels": [
    { "id": 1, "name": "Esclusa de Oro", "timezone": "America/Panama", "closesAt": "2026-10-31T20:00:00-05:00", "status": "live" }
  ],
  "segments": [
    { "id": 1, "wheelId": 1, "segmentId": "sin-premio", "prizeType": "none", "weightBp": 3000 },
    { "id": 8, "wheelId": 1, "segmentId": "esclusa-de-oro", "prizeType": "avatar", "weightBp": 50 }
  ],
  "stock": [
    { "id": 1, "wheelId": 1, "segmentId": "esclusa-de-oro", "remaining": 1000 }
  ],
  "spinLog": []
}
```

Dos cosas para mirar. Primero: `weightBp` suma 10.000 (los pesos de la Esclusa de Oro, `00-historia-del-sistema.md` §8). Segundo: `stock.remaining` es **la única fuente** del stock; el giro lo descuenta, y nada más lo toca. La bitácora (`spinLog`) empieza vacía y solo se agrega.

> ⚠️ **Restaurar el mock.** El mock escribe en `db.json` cada vez que alguien gira. Para volver al estado de la fase, restaura el archivo desde git (`git checkout -- mock/db.json`), o desde la copia que deja la fase.

### 5.2 El inyector de caos: `mock/chaosMiddleware.js`

<<<archivo:mock/chaosMiddleware.js>>>

**Detalles con intención.**
- Las probabilidades viven en una tabla (`LEVELS`), no repartidas en `if`. Cambiar un nivel es cambiar una línea.
- El 401 nunca toca `/users`: el login no puede dar 401 por el caos, o no habría forma de entrar.
- Con `CHAOS_SEED` fijo, la secuencia de fallos se repite. Sin semilla, cada corrida es distinta, que es lo que pasa en producción.

### 5.3 El servidor del API: `mock/server.js`

<<<archivo:mock/server.js>>>

**Detalles con intención.**
- El giro ingenuo tiene tres viajes a la base, separados por una pausa. La decisión se toma con el valor **leído** al principio; el descuento se hace sobre el valor **actual**. Esa diferencia es el punto: con el valor leído, dos peticiones que leen 1.000 escriben 999 las dos, y el stock deja de descontarse. Con el valor actual, el stock baja, y lo que se pasa es lo que las peticiones ya decidieron juntas.
- La clave (`idempotencyKey`) se guarda en la bitácora y **nunca se consulta**. Eso es el defecto: nadie mira si la clave ya ganó un premio.
- Todo lo demás (`/wheels`, `/players`, `/users`…) lo resuelve `json-server` con el CRUD automático, detrás del caos.

### 5.4 Medir la carga: `scripts/traffic.js` y `scripts/measure.js`

<<<archivo:scripts/traffic.js>>>

<<<archivo:scripts/measure.js>>>

**Detalles con intención.**
- La carga por defecto: 50 usuarios virtuales, 1.500 claves, cada una enviada dos veces. Es la misma forma que el reintento de un cliente que perdió la respuesta.
- El generador tiene timeout de 5 s. Sin timeout, las peticiones que el caos deja sin respuesta esperan para siempre, y el generador nunca termina. Es el mismo error que vas a estudiar en el incidente 07.
- `measure.js` cuenta los dobles por clave en la bitácora, no por petición. Y el stock excedido es lo que se pasa de los 1.000 de la Esclusa de Oro, no un número inventado.

**Cómo se corre.**

```bash
# terminal 1: el API, sin caos
npm run mock:api

# terminal 2: la carga y la medición (la base se restaura antes de cada corrida)
git checkout -- mock/db.json   # desde la fase, y antes de otra corrida
npm run traffic
npm run measure
```

Los resultados de seis corridas, con la base restaurada antes de cada una y `STEP_DELAY_MS=2`, fueron:

| Corrida | Premios | Claves con dos premios | Stock restante | Stock excedido |
|---|---|---|---|---|
| 1 | 1.014 | 507 | −14 | 14 |
| 2 | 1.031 | 515 | −31 | 31 |
| 3 | 1.047 | 523 | −47 | 47 |
| 4 | 1.000 | 500 | 0 | 0 |
| 5 | 1.034 | 517 | −34 | 34 |
| 6 | 1.029 | 514 | −29 | 29 |

Son de esta fase, fechadas el 14/10/2026 en el repo del alumno. Los dobles aparecen siempre: cada clave se manda dos veces casi a la vez, y las dos copias ganan. El stock excedido no: en una de las seis corridas el giro se quedó justo en 1.000. Las cifras cambian de corrida a corrida, y por eso el curso publica un rango y la fecha, no un número: entre 1.000 y 1.047 premios, y entre 0 y 47 de stock excedido.

### 5.5 El mock de Google Play: `mock/googlePlay/server.js`

<<<archivo:mock/googlePlay/server.js>>>

**Detalles con intención.**
- El pago en efectivo nace `pending` y pasa a `confirmed` cuando termina la demora. En Google Play real la demora va de minutos a 48 horas; el mock la deja configurable para que la Fase 7 pruebe el polling en segundos.
- Con `PLAY_DUPLICATE=1`, la misma notificación llega dos veces. Si la consola acredita giros por cada notificación, el jugador recibe dos. El track BE lo corrige con una clave de compra (`be07`).
- Este servidor no tiene caos por defecto. Es un servicio externo, y su comportamiento se elige con variables, no con un nivel.

### 5.6 Pago de deuda #1: persistencia de sesión

En la Fase 2 el `authSlice` arrancaba siempre vacío. Recargar la página perdía la sesión, y así quedó marcado. Ahora el estado inicial sale de `localStorage`, y el slice sincroniza el storage en login y logout. Todo el acceso a `localStorage` vive en un archivo, para que cambiarlo mañana sea tocar un solo lugar.

<<<archivo:src/features/auth/authStorage.js>>>

<<<archivo:src/features/auth/authSlice.js>>>

> ⚠️ **Las trampas de `localStorage`** (prometidas en el cierre de la Fase 2):
> es **legible por cualquier script** de la página (si hay un XSS, se lleva el token), así que nunca guardes ahí nada más sensible que un token de sesión de vida corta. Es **compartido entre pestañas** del mismo origen: un logout en una pestaña no limpia el estado en memoria de las otras (el storage sí se actualiza, pero el store de la otra pestaña no se entera solo). Y **no se limpia solo**: si no se llama a `clearSession()`, el token sobrevive al cierre del navegador.

**Trade-off.** Elegimos `localStorage` porque es lo que el sistema usa desde 2019, con sus trampas incluidas. `sessionStorage` se limpia al cerrar la pestaña, lo que molesta en uso normal. Mantener el token solo en memoria es lo más seguro contra un robo por XSS, pero obliga a volver a entrar en cada recarga, y para un operador que trabaja todo el día eso es inviable.

### 5.7 Pago de deuda #2: manejo global de 401

El 401 se maneja en el interceptor de response de `apiClient`, para que ningún componente tenga que saber qué es un 401. El interceptor no importa el store: recibe un callback desde `store.js`. Importar el store desde `apiClient` es la tentación obvia, y crea un ciclo (`store` → `apiClient` → `store`). La Fase 2 ya evitaba el ciclo pasando `getToken`; acá hacemos lo mismo con el logout.

Para que el interceptor pueda mandar al operador a `/login`, el router usa un historial compartido, que vive en su propio archivo:

<<<archivo:src/app/history.js>>>

<<<archivo:src/api/apiClient.js>>>

<<<archivo:src/app/store.js>>>

<<<archivo:src/AppRouter.jsx>>>

**Detalles con intención.**
- El `logout` del 401 reusa el reducer del pago #1: limpiar la sesión y borrar el `localStorage` es una sola cosa, no dos que se pueden desincronizar.
- La correlación por `requestId` sigue igual que en la Fase 2: el 401 imprime el id en consola, para cruzarlo con la línea del log del mock.
- Un 401 no es un error de login: es una sesión caída. Por eso el callback corre en el interceptor de **response**, no en el thunk.

### 5.8 Un 5xx no es "contraseña mal"

Si el mock responde 503 durante el login, el mensaje de axios no le dice nada al operador. El servicio de autenticación lo traduce:

<<<archivo:src/api/authService.js>>>

### 5.9 Los scripts del proyecto

<<<archivo:package.json>>>

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**1. Creer que el giro "no es ingenuo" porque los números dan bien con pocas claves.** Síntoma: con 50 claves, las cifras salen perfectas. Causa: la ventana entre leer y escribir solo se nota cuando hay muchas peticiones simultáneas. Fix: mide con la carga completa (`npm run traffic`), no con dos clics.

**2. Un timeout que no existe.** Síntoma: el login se queda en "Ingresando…" para siempre, y el mock no dice nada. Causa: sin timeout en la instancia de axios, una petición que el caos deja sin respuesta no termina nunca. Fix: `timeout` en `apiClient`. Es el incidente 07.

**3. Tratar un 503 como contraseña incorrecta.** Síntoma: el operador reintenta la contraseña una y otra vez. Causa: el mensaje de error no distingue el 5xx del 401 de credenciales. Fix: la traducción de `authService`.

**4. Olvidar `localStorage` en el logout.** Síntoma: cierras sesión, recargas, y vuelves a estar dentro. Causa: `logout` limpia el estado pero no el storage. Fix: `clearSession()` dentro del mismo reducer.

### Pieza forense de esta fase: simular caos y leer lo que hace la consola

Con `CHAOS_LEVEL=high` y el generador de tráfico, cada petición deja una huella distinta: un 200, un 503, un 401, un timeout o un JSON roto. La pregunta del forense es siempre la misma: **¿qué hizo la consola con cada una?** Un 503 en el login muestra el mensaje legible. Un 401 en una ruta protegida cierra la sesión y manda a `/login`. Un timeout sin el `timeout` de la instancia deja el login colgado. Y un JSON roto con código 200 pasa como éxito, porque axios no falla al recibir texto con código 200: es un defecto que solo se ve leyendo el cuerpo.

Con la correlación por `requestId` puedes cruzar cada una de esas huellas con la línea del log del mock. Esa es la diferencia entre "no sé qué pasó" y "esta petición exacta, a esta hora, devolvió 401".

---

## 🧪 7. Ejercicios (24)

Trabaja sobre el mock y la app de la fase. Varios son de diagnóstico: te entregan un bug y tienes que reproducirlo y localizarlo.

**🟢 Fácil (1–6)**

1. Levanta el mock con `CHAOS_LEVEL=low` y cuenta, en cien logins, cuántos fallan con 503. Compara con la tabla de la sección 4.
2. Cambia la semilla (`CHAOS_SEED`) y verifica que la secuencia de fallos cambia; vuelve a la misma semilla y verifica que se repite.
3. Restaura `mock/db.json` desde git y verifica que la bitácora vuelve a estar vacía.
4. Agrega un usuario nuevo a `db.json` y loguéate con él.
5. Cambia `STEP_DELAY_MS` a `0` y corre la carga. ¿Qué cambia en las cifras?
6. Haz que el generador imprima el tiempo medio de respuesta por código de estado.

**🟡 Intermedio (7–13)**

7. Escribe un nivel `medium` en `LEVELS` con valores a medio camino entre `low` y `high`, y verifica con el generador.
8. Haz que `measure.js` cuente también los premios de cada clave y muestre cuántas claves tienen tres o más.
9. Agrega al `spinLog` la hora de la petición y ordénalo para ver cuándo entraron los dobles.
10. Pon un contador de reintentos en el interceptor de request y verifica que sube con el caos alto.
11. Agrega un `GET /stock` que devuelva también el porcentaje agotado. Úsalo desde `measure.js`.
12. Haz que el mock de Google Play rechace las compras con un `purchaseToken` repetido, y verifica que la notificación duplicada sigue llegando dos veces.
13. Escribe un test de `authStorage` con basura en el storage, y verifica que `readSession` devuelve `null` sin romper.

**🟠 Difícil (14–20)**

14. **Diagnóstico.** Con `CHAOS_LEVEL=high`, la consola a veces queda en "Ingresando…". Reproduce el caso con el generador, mira qué petición no termina y explica por qué. Aplica el fix.
15. **Diagnóstico.** Tras un 401, la pantalla de login aparece, pero al entrar de nuevo la app vuelve a mandarte a `/login` aunque la contraseña sea correcta. Pista: compara qué historial usa el interceptor con el que usa el router.
16. **Diagnóstico.** Un JSON roto con código 200 llega como éxito. Reproduce el caso, muestra qué recibe el componente y escribe la validación mínima.
17. Agrega al `authSlice` una acción `sessionExpired` con un motivo, y muéstralo en la pantalla de login (pista: `location.state`).
18. Haz que el 401 guarde la ruta a la que querías ir, y que el login te devuelva ahí después de entrar.
19. Escribe una prueba de regresión para el giro ingenuo: con dos claves iguales en paralelo, hoy dan dos premios. Escribe la prueba para que falle mientras el defecto exista.
20. Implementa un nivel de caos que solo afecte a un usuario (el de `ibatista`), y verifica que los otros no se enteran.

**🔴 Muy difícil (21–24)**

21. **Diagnóstico integrador.** Te entregan la consola con el mock y el caos alto, y el reporte "a veces me saca a login". Separa, con evidencia, cuántos de esos casos son un 401 del caos y cuántos son un defecto de la consola.
22. Mide la diferencia entre la carga con `STEP_DELAY_MS=2` y con `STEP_DELAY_MS=0` en tres corridas cada una, y escribe una nota que explique por qué la ventana cambia el número de dobles.
23. Escribe un post-mortem completo (síntoma, reproducción, evidencia, causa raíz, corrección, prueba de regresión, prevención, análisis sin culpa) para "a veces no carga y no dice nada".
24. Diseña cómo sería el giro de la Esclusa **sin** el defecto (sin tocar el frontend). Describe la transacción y la clave de idempotencia, y di cuál de los dos cambios sería el parche mínimo.

**🔥 Opcionales**

- 🔥 Agrega `POST /_chaos` para cambiar el nivel de caos sin reiniciar el mock. Discute qué riesgo introduce.
- 🔥 Escribe un `mock/server.js` alternativo que use `CHAOS_LEVEL` por ruta, no por servidor.

---

## 📚 8. Referencias

**Documentación oficial**

- json-server — filtros, rutas personalizadas y middlewares: https://github.com/typicode/json-server (la versión del curso es la 0.16.3).
- Express — middlewares: https://expressjs.com/en/guide/using-middleware.html
- axios — timeout y códigos de error: https://axios-http.com/docs/handling_errors
- MDN — `localStorage` y sus límites: https://developer.mozilla.org/es/docs/Web/API/Window/localStorage
- Google Play Developer API — compras de un solo producto y estados de pago: https://developers.google.com/android-publisher (para entender qué simula el mock de la fase).

**Lectura del curso.** `A13-depurar-el-build-de-produccion.md` para comparar ambientes, `A9-entornos-y-contenedores.md` cuando el caos deba reproducirse en contenedor, y los incidentes 07 y 08 del cuaderno.

> ⚠️ Las URLs pueden haber cambiado de lugar. Verifica siempre contra la versión fijada del stack.

---

## 🚀 9. Cierre y conexión con la Fase 4

Ya tienes un backend de mentira que falla como uno real, un giro ingenuo que reproduce la carrera de 2019 y un servicio externo que se porta a su manera. También cobraste las dos deudas de auth: la sesión sobrevive a un F5, y un 401 cierra la sesión y te manda a `/login`.

La **Fase 4 — Ruedas CRUD** es donde la consola deja de tener los datos escritos a mano y empieza a pedirlos al mock. El listado de la Fase 1 (`WheelListPage`, que lee `mock/wheels.js`) deja su lugar a una tabla que lee el API a través del store. El `timeout` y el manejo de 401 que estrenaste acá son los que van a proteger esa lectura.

> **La señal de que quedó bien:** si cargas la app con `CHAOS_LEVEL=high`, un login sale con su mensaje legible en lugar de quedarse colgado, un 401 te saca a `/login` sin perder el mundo, y la carga del giro ingenuo te da dobles y stock excedido en el rango que mediste. Entonces la fase cumplió.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde:
>
> ```bash
> git tag -a fase-03-mock-api-express-caos -m "F3 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f03: …`). Los ejercicios de medición van en `ej/f03/NN` con sus cifras en el mensaje.

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura.

- **El giro ingenuo no es una deuda que se pague en esta fase.** Es el defecto que se estudia, y se paga en el track BE (be05). → Verificar que la sección 4 y el incidente 08 lo dejen claro.
- **La pausa de 2 ms es un parámetro de calibración**, no una propiedad del giro de 2019. → Documentarlo en el cuaderno de incidentes del track BE cuando llegue be05.
- **El JSON roto con código 200 pasa como éxito** en axios. El curso lo deja como ejercicio 16 y no lo corrige en la base, porque la corrección depende del contrato del API.

### Reservas para el cuaderno de incidentes

- **07** — *A veces no carga y no dice nada* · Integración · 🟡. Sale del timeout que falta en `apiClient` y del caos alto. Tiene su rama `incidente/07`.
- **08** — *Me saca a login al azar mientras estoy trabajando* · Integración · 🟡. Sale del 401 del caos sobre una ruta protegida: el sistema lo detecta y no lo comunica. No tiene rama; el comportamiento ya está en la fase.
