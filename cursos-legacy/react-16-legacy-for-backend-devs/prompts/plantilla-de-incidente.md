# 🧩 Plantilla de incidente — track base
## Tutorial React 16 — Rifas y chances

Copia este esqueleto al redactar un incidente de `cuaderno-incidentes.md` y rellena los
`{{placeholders}}`. Borra las notas entre paréntesis antes de entregar.

Vivía embebida dentro del propio cuaderno, como "Incidente 01" con placeholders. Se
extrajo acá porque ese lugar lo ocupa el incidente real de la Fase 0, y una plantilla que
se destruye al escribir el primer caso no es una plantilla. Su hermana de backend es
`plantilla-de-incidente-be.md`: **la estructura es la misma y no se toca** —ticket → qué se
te pide → preparación → tres pistas escalonadas → tu investigación → solución de referencia
colapsada—; allá cambian las herramientas y el vocabulario, por la misma razón que cambia
la pieza forense de cada fase (`guia-de-estilo-y-convenciones.md` §16.4).

> 🔄 **Convención de idioma.** El ticket, la narrativa, las pistas y los comentarios de
> código van en **español latinoamericano con tuteo**. Los identificadores, endpoints,
> constantes y acciones van en **inglés** (`diccionario-codigo-ingles.md`).

---

## Las tres palancas de la preparación

Un incidente que no se reproduce no es un incidente: es una anécdota. En el track base hay
exactamente tres formas de dejar el laboratorio en el estado roto de partida, y **todo
incidente declara las tres**, aunque alguna diga "no aplica". Omitir una es la causa número
uno de un enunciado irreproducible.

**1. La rama `incidente/NN`.** Lleva el código al estado roto. Es distinta de los tags
`inc/<ID>/<slug>-roto|-fix`, que marcan **tu** recorrido resolviéndolo: la rama te lleva al
problema, los tags cuentan cómo saliste (`00-convencion-de-git-y-tags.md`, §🚑 y su nota 📝).

**2. El `CHAOS_LEVEL` del mock.** `off`, `low` o `high`, como los define la Fase 3. Los
bugs que dependen de latencia o de fallos intermitentes **solo** aparecen con `high`, y el
enunciado tiene que decirlo o el estudiante concluirá que el ticket estaba equivocado. Al
revés también cuenta: un incidente que se reproduce con `off` es un bug determinista, y
decirlo es media pista.

**3. El estado de `db.json`.** Qué rifa, qué números, en qué estado, a qué hora de cierre y
**en qué zona horaria**. Los incidentes de tiempo son irreproducibles sin la TZ del
navegador declarada, y los de rendimiento lo son sin volumen: si hace falta sembrar
doscientas rifas, el incidente trae el script que las siembra.


> 🧰 **El contenido de cada preparación está en
> [`preparaciones-de-incidentes.md`](preparaciones-de-incidentes.md)**: qué línea
> rompe cada una de las diecinueve ramas, qué registros hay que sembrar y cómo
> comprobar que la preparación reproduce el síntoma. Su hermano del track BE es
> [`preparaciones-de-incidentes-be.md`](preparaciones-de-incidentes-be.md). Los dos
> son material de autoría y **no se enlazan desde el cuaderno**: son la respuesta.

---

## La escala de longitud

Un incidente 🟢 con doscientas líneas aburre; uno 🔴 con ciento veinte miente sobre lo que
cuesta. La proporción es parte del contrato con el estudiante:

| Dificultad | Líneas | Tiempo sugerido |
|---|---|---|
| 🟢 fácil | 170-215 | 20-30 min |
| 🟡 intermedio | 190-240 | 30-45 min |
| 🟠 difícil | 220-270 | 45-70 min |
| 🔴 y ⭐ | 260-310 | 60-90 min |

> 📝 **Por qué el piso es 150 y no 110.** El andamiaje de la estructura
> —encabezado, ticket, qué se te pide, preparación, tres pistas, la investigación
> vacía y los siete bloques de la solución— cuesta unas noventa líneas antes de
> escribir una sola idea. Un incidente 🟢 de ciento veinte líneas no es más breve:
> es uno al que le faltan bloques. El cuaderno del track BE, con la misma
> estructura, tiene su mínimo en 188.

---

```markdown
## Incidente {{NN}} — {{Título en palabras del usuario}}

> **Fase:** {{N}} · **Categoría:** {{entorno / UI-routing / autenticación / integración / estado (store) / concurrencia / RxJS-epics / tiempo / dinero / performance / testing}} · **Dificultad:** {{🟢🟡🟠🔴}}
> **Estado:** ⬜ Sin empezar · **Abierto:** {{—}} · **Cerrado:** {{—}}
> **Tiempo sugerido:** {{20-40 min}}
> {{⭐ si es de los dos más formativos}} {{· Hermano del incidente be-{{NN}}, con otra causa raíz}}

### 🎫 El ticket

{{El reporte tal como llegó, con su vaguedad incluida. Dos o tres frases en lenguaje de
negocio, escritas por alguien que no sabe qué es un epic. "A veces no carga" es un dato
legítimo sobre la reproducibilidad, no un defecto del reporte. Si el reporte trae una
teoría del usuario sobre la causa —y suelen traerla—, consérvala: descartarla es parte del
trabajo.}}

**Reportado por:** {{rol — vendedor de rifas, supervisor, tesorería, soporte}}
**Ambiente:** {{desarrollo / UAT / PROD / varios}}

### 🎯 Qué se te pide

{{Una o dos líneas con el entregable concreto: reproducir y localizar la capa, o reproducir
y aplicar el hotfix mínimo, o explicar por qué no se reproduce. No todos los incidentes
terminan en fix.}}

### 🔧 Preparación

{{Las tres palancas, siempre las tres. Si alguna no aplica, se dice: "CHAOS_LEVEL: da igual,
el bug es determinista" es información, el silencio no.}}

- **Rama:** {{incidente/NN}}
- **Caos:** {{off / low / high — y por qué}}
- **Datos:** {{qué rifa, qué números, en qué estado, a qué hora de cierre, en qué zona horaria}}

```bash
{{git checkout incidente/NN
CHAOS_LEVEL=high npm run mock}}
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

{{Señala la capa y la herramienta, sin decir qué vas a encontrar: "esto se ve en la pestaña
Network antes que en la consola" o "el store ya tiene la respuesta; compara la acción que
entra con el estado que sale". No nombra el archivo.}}

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

{{Acota al archivo o al momento exacto, todavía sin nombrar la causa.}}

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

{{La pregunta cuya respuesta es la causa raíz. No la respuesta.}}

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución. Es la parte que se versiona y la que vas
a releer en la retrospectiva del mes. Se entrega VACÍA, con sus placeholders intactos.}}

**Reproducción**
{{Pasos numerados y exactos, con datos concretos: qué rifa, qué número, en qué estado, a
qué hora y en qué zona horaria. Si no lo lograste, escribe qué intentaste — no reproducir
también es un resultado.}}

**Evidencia observable**
{{Lo que viste, no lo que supones: consola, Network, React DevTools, Redux DevTools, logs
del mock. Texto, no capturas: el texto se versiona y se busca.}}

```
{{payload, error o secuencia de acciones despachadas}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea, o la decisión de diseño culpable. En qué capa vive: componente, store,
epic, interceptor, mock o build.}}

**Tu fix**
{{El parche mínimo que aplicarías un viernes a las seis. Aparte, en una línea, la
refactorización correcta que harías con calma.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

{{Hasta el archivo y la línea. Si la causa es una decisión de diseño, se nombra la decisión
y se explica por qué en su momento tenía sentido — 📝 nota de época, con la era de
`00-historia-del-sistema.md` que la produjo. Si la deuda está declarada en
`A12-mapa-de-deuda-tecnica.md`, se cita la entrada.}}

**Parche mínimo**

```javascript
{{el hotfix, con identificadores en inglés y comentarios en español}}
```

**La refactorización correcta** (que en este curso solo se paga si la Fase 11 la marca 💸)

{{Qué haría alguien con tiempo y pruebas, y por qué acá no se hace todavía.}}

**Prueba de regresión**

{{El test que falla antes del fix y pasa después. Código, no descripción. Si el bug es de
cancelación o de timing en un epic, va con marbles (`A11-marble-testing.md`); si es de
render, con RTL.}}

```javascript
{{test}}
```

**Prevención**

{{Test, validación en el reducer, guarda en el epic, o alerta. Lo que evita que el mismo
bug vuelva por otra puerta.}}

**Por qué llegó a producción**

{{Post-mortem sereno: qué del sistema o del proceso lo permitió. Se analiza el sistema,
nunca a la persona. Acá el humor baja un punto.}}

**Si tu causa fue distinta a esta**

{{Los diagnósticos alternativos plausibles y por qué el síntoma también encaja con ellos.
Que tu fix funcione y tu causa no coincida es información: casi siempre significa que
tapaste el síntoma una capa más arriba.}}

</details>
```

---

## Recordatorios al rellenar

- **El ID nunca se reasigna.** El rango del track base es `01` a `20` y está reservado desde
  las doce fases que los producen; el rango `be-01`–`be-16` es del track opcional y vive en
  otro archivo. Título, categoría y dificultad ya están fijados en el índice del cuaderno:
  se respetan palabra por palabra.
- **La fase indicada es la que hay que haber terminado** para poder resolverlo, no
  necesariamente la que introdujo el bug.
- **Cada incidente se lee solo.** Nada de "ver incidente 01": se repite la estructura entera
  aunque canse, porque se leen salteados y con semanas de diferencia.
- **Cada incidente tiene que poder resolverse con el laboratorio del alumno**, sin datos ni
  servicios externos (autocontención, guía §11).
- **Tres de los veinte no terminan en un commit** —el **02** cierra en documentación, el
  **10** en ⚪ "no se reproduce, y acá está la evidencia", el **20** en una decisión de la
  Fase 11— y esos tres tienen que decir explícitamente que ese desenlace es tan válido como
  un fix. Es el desenlace que menos se practica y el que más aparece en la vida real.
- **Los seis hermanos del track BE se marcan** en el encabezado: **08** (be-08), **11**
  (be-09), **16** (be-12), **18** (be-13), **19** (be-05) y **20** (be-15). Antes de
  redactar uno, se lee su hermano: aquel archivo ya está publicado y describe qué cambia
  entre las dos capas. Si divergen, gana el hermano publicado.
- **Todo el código corre con el stack fijado** (`decisiones-y-versiones.md`): React 16.14,
  react-scripts 4.0.3, Redux Toolkit 1.8.6, redux-observable 1.2.0, RxJS 6.6.7, Router
  5.3.4, axios 0.21.4, Jest 26, RTL 11, Node 14.21.3.
- **Nada de culpabilización** en el post-mortem, ni siquiera implícita (guía §13).
