# Plan desechable — llevar la historia de la Tiquetera a los dos cursos

> Desechable: registro de trabajo, no se cita ni se mantiene en sincronía.
> Abierto el 2026-10-06. Fuente narrativa: `../00-historia-del-sistema.md`.

## Decisión de partida

La versión con la historia nueva es para los **devs que entran desde ahora**.
Los dos devs que ya van en la versión anterior siguen con ella (la tienen en su
copia y en el historial de git). Por eso los cambios se aplican en el lugar, sin
convivencia de versiones.

## Tandas

| Tanda | Qué | Estado |
|---|---|---|
| T0 | Ajustes de la ficha contra el curso (`soporte_v1` con el histórico de Cuadre; paginación y migración "hasta que las construyas") | ✅ 2026-10-06 |
| T1 | "Mesa de soporte interna" → la mesa de Cuadre Software (README del paquete, README del curso 01, plan del curso 01, README y prompts del curso 02) | ✅ 2026-10-06 |
| T1 | "villano" → "modelo traducido" (13 archivos, incluidas las guías) | ✅ 2026-10-06 |
| T2 | Renombre Mini Jira → la Tiquetera; `minijira` → `tiquetera`; `mini-jira-*` → `tiquetera-*`; concordancia de género revisada línea por línea | ✅ 2026-10-06 |
| T3 | Personajes en los datos: `soporte1`→`lmcano`, `agente1`→`lmcorrea`, `usuario1`→`dprios`, nombres "Ana Soporte"/"Carlos Usuario"/"Usuario Demo" → Laura Marcela Cano / Diana Patricia Ríos / Andrés Felipe Ríos; las referencias rotas a propósito (`soporte2`/`usuario2`/`usuario3`) pasan a `jpmesa`/`cvelez`/`mrestrepo`, usuarios borrados de gente que se fue (explicado en F1 y el contrato del curso 02). NIT y resolución **no** entran al contrato: van por convención al comienzo del título (callout en F3 del curso 01, ejercicio 33 de la F4 del curso 02 en lugar del multi-tenant). Diagramas de q4/vu4 realineados | ✅ 2026-10-06 |
| T4 | Tabla de puntajes: F7 la construye tal como la dejó Felipe (`initialsOf`, `scoreBoard`, `ScoreBoard.vue`, tres deudas 💸 declaradas); incidente 13 "Laura dice que los puntos de la semana son de ella" en el cuaderno del curso 01 (conteos 12 → 13 en los README y documentos maestros); pago en el curso 02 como 🔥 opcional de la F9 (pipeline por username, usuarios borrados reportados, tasa de reapertura con `history`). La ficha cambió "reabrir no resta" por "lo reabierto deja de contar sin rastro", que es lo que el código hace | ✅ 2026-10-06 |
| T5 | `historia-ruta-{q,vu,nx}.md` escritas (Santiago Henao / Kevin Marín / Daniela Rojas; la rama se rescata rehaciéndola sobre el tronco de hoy; lo que pide PizzaPaisa; fin de soporte verificado de Quasar 1, Vuetify 2 y Nuxt 2); enlazadas desde la ficha, cada X0, el README y `0-ESTRUCTURA-CURSO.md`; excepción declarada en la guía §13.4; la ficha suma el plan de remediación en tres etapas | ✅ 2026-10-06 |
| T6 | Ficha renombrada a `00-historia-del-sistema.md` con todos sus enlaces; hechos verificados (TRM 4.153,91 el 20/03/2020; Resolución 000042 de mayo de 2020 con plazo al 1/11 para los sectores golpeados; Pi 2 el 02/02/2015; `mysql_*` fuera en PHP 7.0; Maestros del Web y Platzi con fundador común; curso de Vue en Platzi desde 2016); pasada de voseo sobre lo nuevo | ✅ 2026-10-06 |
| T7 | `prompts/` único: los `prompts/` de los dos cursos se movieron al del paquete (vigentes: `diccionario-codigo.md`, `instrucciones-proyecto-track-b.md`; el resto con `_desechable-`); referencias corregidas; excepción declarada en la guía §13.3 y en los README | ✅ 2026-10-06 |

## Notas

- T3: los títulos de ejemplo del `db.json` se dejaron (impresora, correo, carpeta): calzan con los tickets internos de la ficha y los usan tests y búsquedas en 15+ lugares.
- Los rescates en `zz-code/vue2-legacy-for-backend-devs-20261006-c6c0/` son
  registro histórico de la versión anterior: no se renombran.
