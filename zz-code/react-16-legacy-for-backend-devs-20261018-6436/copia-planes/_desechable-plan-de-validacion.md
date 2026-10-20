# 🧪 Plan de revalidación por ejecución — desechable
## React 16 Legacy — Rifas y chances

> **Qué es:** las tandas para volver a ejecutar el curso de punta a punta y dejar constancia de que
> lo que publica corre. Es **desechable**: no se cita desde ningún documento, y se borra (con permiso
> del autor) cuando la revalidación termine y su resultado quede en la guía §17.4.
> **Por qué existe:** las salidas del curso se ejecutaron al escribirlo, pero el curso es anterior al
> método de tandas con casillas *escrita* y *corrida*, y no quedó registro de qué se corrió, con qué
> versiones ni cuándo. Este plan es ese registro, hecho de nuevo.
> **Creado:** 05/10/2026. **Estado:** sin empezar; se hará en sesiones futuras.

---

## 1. 🧭 Reglas de la revalidación

- **Una tanda por sesión**, en orden, sin agentes. Al cerrar cada una se actualiza §4 (estado) y §5
  (bitácora) y se para hasta que el autor diga.
- **Todo corre en contenedores**, nunca en el host: imágenes oficiales con la versión congelada de
  `00-decisiones-y-versiones.md`, etiquetadas `--label curso=react16`, y puertos altos y aleatorios
  ligados a `127.0.0.1` (`-p 127.0.0.1::3000`, leído con `docker port`). El curso publica 3000, 3001,
  3002 y 5432; la prueba no los usa en el host.
- **Inventario de Docker al empezar cada sesión**, a un log, y al cerrar se borra solo lo creado
  (`docker rm -v`, `docker compose down -v`), comparando contra el inventario. Nada de `prune`.
- **El código va a `zz-code/`**, en un directorio por sesión creado con
  `python3 zz-code/nuevo.py react-16-legacy-for-backend-devs`. Ahí vive el repo del "alumno" que se
  construye fase a fase (`raffles-app/`, con `server/` desde be01), con sus tags `fase-…`, y lo
  efímero en `salidas/`. El curso nunca cita `zz-code/`.
- **Se ejecuta lo que el lector ejecuta**, copiado del documento tal cual: comandos, archivos y
  pasos. Lo que no está escrito no se inventa para que funcione: si hace falta, es un hallazgo.
- **El error se anota literal antes de arreglarlo**, con la línea del documento que lo produjo.
- **La fase gana, salvo que esté mal.** Si la salida real difiere de la publicada, se corrige la fase
  con la salida real; si cambia una versión o una decisión, se corrige primero
  `00-decisiones-y-versiones.md` y después la fase (orden de autoridad, guía §12).
- **Ninguna salida reconstruida de memoria.** Lo que no se pueda ejecutar se marca en la fase con
  «no verificado por ejecución; escrito desde la documentación oficial» y queda ⬜ en §4.
- **Al cerrar cada tanda:** `python3 prompts/verificar-corpus.py` y `--publicacion` en cero.

---

## 2. ⚠️ Lo que hay que resolver antes de V1

- **Node 14.21.3 en Apple Silicon.** La máquina del autor es arm64. Comprobar en V0 que la imagen
  `node:14.21.3-bullseye` tiene variante `linux/arm64`; si no, correr con
  `--platform linux/amd64` y anotar la emulación en la bitácora, porque cambia tiempos y algunos
  mensajes. F00 §5.3 describe el caso nativo en macOS: esa sección se valida contra la
  documentación, no en contenedor.
- **CRA 4 sin `create-react-app` global.** F00 §5.5 crea el proyecto con
  `npx create-react-app@4.0.3 raffles-app --use-npm`: dentro del contenedor, con npm 6, y comprobando
  que lo que baja hoy sigue siendo React 16.14.0 tras fijar las versiones de la fase.
- **Cypress 10.11.0.** Necesita navegador y dependencias de sistema. Comprobar en V0 qué imagen
  oficial existe para esa versión y arquitectura (`cypress/included:10.11.0` u otra) antes de
  planificar V5. Si no hay forma sin instalar nada en el host, el smoke de F10 se marca no verificado.
- **DevTools.** Las piezas forenses que se miran en Chrome (React DevTools, Redux DevTools, Network)
  no se automatizan: se validan a mano en el navegador del autor, contra el contenedor, y se anotan
  como «verificado a mano».
- **GitHub Actions (be09, D23).** El workflow no se puede correr sin un repositorio y un runner.
  Se valida lo que corre local (los mismos comandos dentro de `golang:1.19` y `postgres:13`) y el
  YAML se revisa contra la documentación vigente de cada acción. Instalar `act` o `actionlint` en el
  host requiere permiso del autor.

---

## 3. 🗂️ Las tandas

| Tanda | Qué se ejecuta | Documentos | Necesita |
|---|---|---|---|
| **V0** | Preparación: inventario de Docker, imágenes y su arquitectura, directorio de `zz-code/`, script que extrae los bloques de código de un `.md` a archivos | §2 de este plan | — |
| **V1** | Ambiente, CRA 4, Bootstrap y dart-sass, Router 5, auth con interceptores | F00, F01, F02 | V0 |
| **V2** | El mock con caos (`json-server` + Express en 3001 y 3002) y el CRUD de rifas | F03, F04 | V1 |
| **V3** ⭐ | Venta concurrente, reservas, rollback; redux-observable y cancelación | F05, F06 | V2 |
| **V4** | Cierre y polling, liquidación en enteros, dashboard con chart.js 2 | F07, F08, F09 | V3 |
| **V5** | Jest 26, RTL 11, marbles, smoke de Cypress; refactor de F11 con `pre-modernizacion` | F10, F11 | V4 |
| **V6** | Apéndices que dejan código o comandos: A1, A2, A10, A11; y los comandos de A3, A4, A9, A13 (incluido el `build` con source maps) | A1–A13 | V5 |
| **V7** | Las 19 ramas `incidente/NN` del track base: que cada una reproduzca su síntoma | `cuaderno-incidentes.md` y `preparaciones-de-incidentes.md` | V6 |
| **V8** | Contrato y `smoke.sh` contra el mock; Go 1.19, la costura de datos con PostgreSQL 13 y SQLite, el reemplazo del mock | be00, be01, be02, be03 | V5 |
| **V9** | bcrypt y JWT (con la migración de `jwt-go`), venta concurrente con `go test -race`, hora dura | be04, be05, be06 | V8 |
| **V10** | Liquidación transaccional, pruebas por niveles y la regla del motor, imagen y pipeline | be07, be08, be09 | V9 |
| **V11** | Los apéndices del track BE | bea-01 a bea-10 | V10 |
| **V12** | Las ramas `incidente/be-NN` del track BE | `cuaderno-incidentes-be.md` y `preparaciones-de-incidentes-be.md` | V11 |
| **V13** | Cierre: resultados a la guía §17.4, README si cambió algo, `zz-code/` cerrado, borrar este plan | — | todas |

Qué se comprueba en cada documento, en este orden:

1. **Las versiones**: lo que se instala coincide con §4 y §7.3 de `00-decisiones-y-versiones.md`, y
   el `package.json` y el `go.mod` al cerrar la tanda coinciden con los de referencia en lo que ya
   debería estar.
2. **Los comandos** corren tal cual, y su salida coincide con la publicada (salvo lo que cambia de una
   corrida a otra: rutas, tiempos, hashes, que se comparan en forma).
3. **El checklist de la sección 2** de cada fase se cumple, y el tag `fase-…` se puede poner con
   `git status` limpio.
4. **La Prueba de fuego** y la **pieza forense** se reproducen como las cuenta la fase.
5. **Los errores provocados a propósito** salen con el mensaje literal que publica la fase.
6. **Ejercicios:** no se resuelven los 855; se ejecutan los que la fase da por reproducibles (los
   «rompe a propósito y observa») y se comprueba que el criterio de cada 🔴 es verificable.
7. **En el track BE**, la regla que lo ordena: `git diff pre-backend-go..HEAD -- . ':!server'` vacío,
   con la exclusión de `src/api/authService.js` desde be04 (D27).

---

## 4. ✅ Estado

✅ hecho · ⏳ en curso · ⬜ pendiente · ⚪ no se puede ejecutar (marcado en el documento)

| Documento | Escrita | Corrida | Documento | Escrita | Corrida |
|---|---|---|---|---|---|
| F00 | ✅ | ⬜ | be00 | ✅ | ⬜ |
| F01 | ✅ | ⬜ | be01 | ✅ | ⬜ |
| F02 | ✅ | ⬜ | be02 | ✅ | ⬜ |
| F03 | ✅ | ⬜ | be03 | ✅ | ⬜ |
| F04 | ✅ | ⬜ | be04 | ✅ | ⬜ |
| F05 | ✅ | ⬜ | be05 | ✅ | ⬜ |
| F06 | ✅ | ⬜ | be06 | ✅ | ⬜ |
| F07 | ✅ | ⬜ | be07 | ✅ | ⬜ |
| F08 | ✅ | ⬜ | be08 | ✅ | ⬜ |
| F09 | ✅ | ⬜ | be09 | ✅ | ⬜ |
| F10 | ✅ | ⬜ | bea-01 a bea-10 | ✅ | ⬜ |
| F11 | ✅ | ⬜ | cuaderno BE (16) | ✅ | ⬜ |
| A1–A13 | ✅ | ⬜ | | | |
| cuaderno base (20) | ✅ | ⬜ | | | |

---

## 5. 📓 Bitácora

Una entrada por sesión: fecha, tanda, directorio de `zz-code/`, qué se corrió, qué difirió (con el
error literal), qué se corrigió y dónde, y las **trampas** que la siguiente sesión tiene que saber.

*(vacía)*
