# 🧪 vue2-legacy-for-backend-devs-20261020-2aca · cómo correr estas pruebas

> **Curso:** vue2-legacy-for-backend-devs · **Tanda:** inc05 y navegador (cierre del 20/10/2026) · **Creado:** 2026-10-20
> **Propósito:** el rediseño del incidente 05 del Curso 01 (rama `incidente/05` reproducible en la Fase 5) y los
> ayudantes para las pruebas de navegador que hace una sesión `claude --chrome` con
> `prompts/_desechable-pruebas-de-navegador.md` del paquete.

## 1. 🎯 Qué se prueba y para qué

| Prueba | Script | Alimenta | Hallazgo |
|---|---|---|---|
| La rama del 05: síntoma, parche `$set`, build y lint | `rama-incidente-05.py`, `t-inc05.sh` | cuaderno 05, preparaciones fila 05 | H-1 |
| La refactorización del cuaderno (`normalizeTicket`) con la rama | `t-inc05-normalizado.sh` | cuaderno 05 | H-2 |
| El incidente 05 reescrito en el cuaderno | `inc05-cuaderno.py` | cuaderno 05 | — |
| Que cada alias de navegador arranque | `navegador/levantar.sh`, `bajar.sh`, `probar-alias.sh` | el desechable de navegador | H-3 |

- **H-1** (`salidas/t-inc05.log`): sobre el estado final de F7 (F5 sin cambios en la lista) con la rama, la prueba interna
  de la vista (`f05-rama/tests/unit/inc05-vista.spec.js`, `ticketService` mockeado) da el ticket 2 (con `tags`) repintado
  y el 3 (sin la clave) **no**: `tags` queda en el objeto y sin getter, 0 repintados. Con `$set`, los dos. Build y lint
  de la rama en verde. Dos falsos verdes corregidos en la prueba: el texto del botón también dice «facturación», y
  `badge-info`/`badge-light` los usan los badges de prioridad y estado; por eso las etiquetas llevan la clase `ticket-tag`.
- **H-2** (`salidas/t-inc05-normalizado.log`): con `apiClient` mockeado, la rama sin `$set` no repinta el 3 con el servicio
  de F5 y sí con `normalizeTicket` (el código de la refactorización del cuaderno).
- **H-3** (`salidas/nav-f11.log`, `salidas/nav-alias.log`): ver §7.
- La semilla de F3–F11 no trae `tags` en ningún ticket (el cuaderno decía lo contrario); el `db.json` del incidente le
  pone `["correo"]` solo al 2.

### Segunda tanda (20/10/2026, tarde): los arreglos que pidió la prueba de navegador

| Arreglo | Script | Resultado |
|---|---|---|
| `ticket:created` en VU3, Q2 y Q3 (docs y árboles) | `anunciar-creados.py` | redes VU0/Q0 66/66 y builds en verde (`t-rutas-r2.sh`, `salidas/t-rutas-r2.log`) |
| Cortafuegos CSS de Q3 | `t-qcss.sh` sobre `qcss/` (copia del árbol Q con `/css-prueba`) | `salidas/qcss/antes.png` (botón desbordado, etiquetas cortadas) y `despues.png` (bien); bloque en `salidas/qcss/cortafuegos.scss` |
| Idioma de Vuetify y de Quasar, fecha `es-CO`, `productName` | ediciones a mano en los árboles; docs en VU1/VU3/VU4/Q1/Q4 | bundles con «Filas por página»; título «Tiquetera» |
| NX: `bootstrap` 4.6.2 y `socket.io` 2.4.1 en su `package.json`, CSS global | `npm install --save-exact` en contenedor | sockets 200, Bootstrap en el HTML del servidor (`salidas/nav-nx-r2.log`) |
| Autor de los comentarios desde el token (unión de V7) | `t-comments.sh` | 401 sin token; con token, `author: "admin"` aunque el body diga otro (`salidas/t-comments.log`) |
| Alias `backend` con el login real (ej. 9 de F11 del Curso 02) | `navegador/login-real.py` | frontend, API y sockets 200 (`salidas/nav-backend-r2.log`) |

### Tercera tanda (20/10/2026, noche): cortafuegos completo y lo que quedaba

- **Banco de medidas** (`t-qbanco.sh A|B|C`, `q-banco-compara.py [--visual]`): `qcss/src/pages/CssPrueba.vue` monta todos los
  componentes que registra la Tiquetera y un grid de Bootstrap; A sin el CSS de Bootstrap, B con él, C con él y el
  cortafuegos (`salidas/qcss/cortafuegos.scss`). Estilos computados de cada elemento con Chromium headless.
  Resultados en `salidas/qbanco/`: Bootstrap alteraba 60 elementos de Quasar (`compara-r1.txt`); el cortafuegos v1
  (solo `q-btn`/`q-field`) dejaba 58; la versión general sin `:where()` dejaba 14 (la especificidad de los `:not()`
  le ganaba a las restauraciones, `compara-r2.txt`); con `:where()` y los gutters, 4 (`compara-r3.txt`); con el margen
  del timeline en 14 px, 3: el píxel declarado del `q-btn__wrapper` (`compara-final.txt`). El grid de Bootstrap: 0
  cambios en todas. Capturas `A.png`, `B.png`, `C.png`.
- **NX4:** el indicador «🔴 histórico» es deuda declarada del curso (ejercicio 12); se agregó a su ✅, sin tocar el código.
- **Alias `f00`** con el Stubby de la Fase 0 (`salidas/nav-f00.log`).
- Redes VU0/Q0 66/66 y builds en verde con el cortafuegos final (`salidas/t-rutas-r3.log`).

La imagen `zenika/alpine-chrome:124` se bajó para los bancos de CSS y se borró al terminar (dos veces).

## 2. 🛠️ Prerrequisitos

Docker Desktop (arm64), `node:14.21.3` y `mongo:4.4` (las baja Docker si no están). Árboles de partida en
`../vue2-legacy-for-backend-devs-20261014-b44a/`: `k/snap/<fase>/tiquetera-legacy` (F0–F3, F7–F11), `rutas/q/tiquetera-q`,
`rutas/vu/tiquetera-legacy`, `rutas/nx1/tiquetera-nx` y `backend/tiquetera-backend`. `tiquetera-legacy/` aquí es la copia
de F7; `f05-rama/` es F7 + la rama + el plugin de Jest de F11 en su `package.json` (solo para las pruebas internas).

## 3. 🧭 Reglas antes de correr

Etiquetas `curso=vue2-legacy` y `tanda=inc05` o `tanda=navegador`. Los alias de navegador publican **3000 y 4000 fijos en
127.0.0.1** (el frontend los tiene escritos) solo si están libres, y el dev server en un puerto aleatorio. Un alias a la
vez. Nunca `prune`.

## 4. ▶️ Cómo se corre

```bash
cp -R tiquetera-legacy f05-rama && python3 -I rama-incidente-05.py f05-rama
cp ../vue2-legacy-for-backend-devs-20261014-b44a/k/snap/11-testing-minimo/tiquetera-legacy/jest.config.js f05-rama/
./t-inc05.sh > salidas/t-inc05.log 2>&1
./t-inc05-normalizado.sh > salidas/t-inc05-normalizado.log 2>&1
python3 -I inc05-cuaderno.py ../../cursos-legacy/vue2-legacy-for-backend-devs/01-vue2-legacy/cuaderno-incidentes.md   # una vez
navegador/levantar.sh f11 | tee salidas/nav-f11.log; navegador/bajar.sh
navegador/probar-alias.sh inc05 f03 f07 f09 vu q nx backend > salidas/nav-alias.log 2>&1
```

## 5. 📏 Cómo se mide

No se mide tiempo: resultados de Jest (pasa o falla) y códigos HTTP de `curl`.

## 6. 🧮 Los intermedios que amasan la salida

`grep` de `✓`, `✕`, `Tests:` y `DONE` en los logs; en los alias, las líneas `Frontend/API/Sockets` de `levantar.sh`.

## 7. ✅ Qué se espera ver

Lo de §1. Los alias: frontend 200, API 200 en `/tickets` y sockets 200 en el polling de socket.io.

## 8. 📂 Salidas

`salidas/`: los logs de arriba, `rama-incidente-05.diff`, `TicketsView-rama.vue`, `ticketService-f05.js`, `package-f07.json`.

## 9. 🧹 Limpieza

`navegador/bajar.sh --todo` (contenedores, red y volúmenes de la tanda navegador) y `docker volume rm vue2-inc05-nm`.
`navegador/trabajo/` y `f05-rama/` se regeneran con §4.

## 10. 🚫 Qué se dejó fuera

Las pruebas de navegador en sí: las hace la sesión `claude --chrome` con el desechable.
