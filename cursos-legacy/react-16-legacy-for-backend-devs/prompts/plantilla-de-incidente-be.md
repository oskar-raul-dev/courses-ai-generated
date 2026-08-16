# 🧩 Plantilla de incidente — Track BE 🔥
## Tutorial React 16 — Rifas y chances

Copia este esqueleto al redactar un incidente del track BE y rellena los
`{{placeholders}}`. Borra las notas entre paréntesis antes de entregar.

Es la variante backend de `plantilla-de-incidente.md`, la del track base.
**La estructura es la misma y no se toca**: ticket → qué se te pide →
preparación → tres pistas escalonadas → tu investigación → solución de
referencia colapsada. Lo que cambia son las herramientas y el vocabulario, por la
misma razón que cambia la pieza forense de cada fase
(`guia-de-estilo-y-convenciones.md` §16.4).

> 🔄 **Convención de idioma.** El ticket, la narrativa, las pistas y los
> comentarios de código van en **español**. Los identificadores, nombres de
> tabla, columnas, endpoints y errores de dominio van en **inglés**
> (`diccionario-codigo-ingles.md` §7bis).

---

## Lo que cambia respecto del track base

| | Track base | Track BE |
|---|---|---|
| Ambientes | navegador, mock | navegador, **binario, Postgres, contenedor, CI** |
| Evidencia | consola, Network, React/Redux DevTools | **log del backend, `psql`, `pg_stat_activity`, `EXPLAIN`, `go test -race`, `docker logs`** |
| Capas a distinguir | componente / store / epic / mock | **handler / service / store / base / infraestructura** — y **frontend contra backend**, que es la primera pregunta |
| Preparación | rama, `CHAOS_LEVEL`, dato en `db.json` | rama, `CHAOS_LEVEL`, **estado de la base, migración aplicada, variables de entorno** |
| Fix | parche mínimo / refactorización | igual, **más: ¿va en el código, en el esquema o en la configuración?** |
| Regresión | Jest, RTL, marbles | **`go test`, y con el motor correcto** (`D18`) |

Y una pregunta propia que el track base no puede hacer, que va **siempre** en la
sección "Qué se te pide":

> 🧭 **¿De qué lado del cable está la causa?** Antes de abrir un archivo. El
> `X-Request-Id` es la herramienta que cruza el corte sin perder el hilo
> (`bea-07`).

> 🧰 **El contenido de cada preparación está en
> [`preparaciones-de-incidentes-be.md`](preparaciones-de-incidentes-be.md)**: las
> once ramas con cambio de código, las tres de diff vacío, los dos que se
> reproducen contra el mock y la barrera de concurrencia sin la cual `be-09` no
> aparece. Es material de autoría y **no se enlaza desde el cuaderno**: es la
> respuesta.

---

```markdown
## Incidente be-{{NN}} — {{Título en palabras del usuario}}

> **Fase:** {{beNN}} · **Categoría:** 🔥 {{base de datos / transacciones / despliegue / contrato / autenticación / tiempo / dinero}} · **Dificultad:** {{🟢🟡🟠🔴}}
> **Estado:** ⬜ Sin empezar · **Abierto:** {{—}} · **Cerrado:** {{—}}
> **Tiempo sugerido:** {{30-60 min}}
> {{⭐ si es de los más formativos}} {{· Hermano del incidente {{NN}} del track base, con otra causa raíz}}

### 🎫 El ticket

{{El reporte tal como llegó, con su vaguedad incluida. Dos o tres frases en
lenguaje de negocio, escritas por alguien que no sabe qué es una transacción.
"A veces" y "creo que" son datos legítimos, no defectos del reporte. Si el
reporte incluye una teoría del usuario sobre la causa —y suelen incluirla—,
consérvala: descartarla es parte del trabajo.}}

**Reportado por:** {{rol — vendedor, supervisor, tesorería, soporte, el propio equipo}}
**Ambiente:** {{desarrollo / QA / UAT / PROD / CI / varios}}

### 🎯 Qué se te pide

{{Una o dos líneas con el entregable concreto. Y siempre, explícitamente: de qué
lado del cable está la causa. No todos los incidentes terminan en fix: algunos
terminan en "el sistema hizo lo correcto y hay que explicárselo a alguien".}}

### 🔧 Preparación

{{Cómo poner el laboratorio en el estado roto: rama, migración, estado de la
base, variables de entorno, volumen de datos si hace falta.}}

```bash
{{git checkout incidente/be-NN
migrate -path server/migrations/postgres -database "$DATABASE_URL" up
CHAOS_LEVEL=off go run ./cmd/api}}
```

---

<details>
<summary>💡 <b>Pista 1</b> — de qué lado del cable (ábrela si llevas 20 min sin una idea nueva)</summary>

{{Señala la orilla y la herramienta, sin decir qué vas a encontrar. En este track
la primera pista casi siempre es la misma pregunta: ¿la petición salió, y qué
volvió?}}

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

{{Acota a la capa, al archivo o al momento exacto, todavía sin nombrar la causa.}}

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

{{La pregunta cuya respuesta es la causa raíz.}}

</details>

---

### 📝 Tu investigación

**Reproducción**
{{Pasos numerados y exactos, con datos concretos: qué rifa, qué número, en qué
estado, a qué hora, con qué usuario, con cuántos clientes concurrentes. Si no lo
lograste, escribe qué intentaste — no reproducir también es un resultado, y en
concurrencia es el resultado más frecuente al principio.}}

**Evidencia observable**
{{Lo que viste, no lo que supones. Texto, no capturas: el texto se versiona y se
busca. Y siempre que puedas, el `X-Request-Id` que ata las dos orillas.}}

```
{{línea de log, salida de psql, informe de -race, mensaje de docker}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea, o la decisión de diseño culpable. En qué capa vive: handler,
service, store, esquema, configuración o infraestructura. Y de qué lado del
cable.}}

**Tu fix**
{{El parche mínimo que aplicarías un viernes a las seis. Aparte, en una línea, la
corrección correcta. Y di dónde va: código, esquema o configuración — en el
backend, esa distinción decide si hace falta una migración y un despliegue o
solo un reinicio.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

{{Hasta el archivo y la línea. Si es una decisión de diseño, se nombra y se
explica por qué tenía sentido — 📝 nota de época. Si la deuda está declarada en
`bea-09`, se cita la entrada.}}

**Parche mínimo**

```go
{{el hotfix, con identificadores en inglés y comentarios en español}}
```

**La corrección correcta**

{{Qué haría alguien con tiempo y pruebas, y por qué acá no se hace todavía. Si
toca el esquema, la migración. Si toca el frontend, decir explícitamente que
choca con la regla del track y con `D27`.}}

**Prueba de regresión**

{{El test que falla antes del fix y pasa después. Código, no descripción. Y
declara contra qué motor corre y por qué (`D18`, regla del motor).}}

```go
{{test}}
```

**Prevención**

{{Restricción en la base, prueba, comprobación en el servicio, o alerta. Lo que
evita que el mismo bug vuelva por otra puerta. En este track, la prevención más
fuerte casi siempre es una restricción de la base: protege también los caminos
que todavía no existen.}}

**Por qué llegó a producción**

{{Post-mortem sereno: qué del sistema o del proceso lo permitió. Se analiza el
sistema, nunca a la persona. Acá el humor baja un punto.}}

**Si tu causa fue distinta a esta**

{{Los diagnósticos alternativos plausibles y por qué el síntoma también encaja
con ellos.}}

</details>
```

---

## Recordatorios al rellenar

- **El ID nunca se reasigna.** El rango del track BE es `be-01` a `be-16` y está
  reservado en `cuaderno-incidentes.md`.
- **La fase indicada es la que hay que haber terminado** para poder resolverlo,
  no necesariamente la que introdujo el bug.
- **Cada incidente tiene que poder resolverse con el laboratorio del alumno**, sin
  datos ni servicios externos (autocontención, guía §11).
- **Al menos un tercio son de diagnóstico puro**: reproducir y localizar, sin
  fix. Y al menos uno tiene que terminar en *"el sistema hizo lo correcto"*, que
  es un desenlace real y el que menos se practica.
- **Los hermanos del track base se marcan.** El paralelo —mismo síntoma, otra
  capa, otra causa raíz— es de lo más formativo que ofrece el track
  (`cuaderno-incidentes.md`, reserva del track BE).
- **La prueba de regresión declara su motor.** Si toca concurrencia, bloqueos,
  zonas horarias o SQL específico, corre contra PostgreSQL o no vale (`D18`).
- **Nada de culpabilización** en el post-mortem, ni siquiera implícita (guía §13).
