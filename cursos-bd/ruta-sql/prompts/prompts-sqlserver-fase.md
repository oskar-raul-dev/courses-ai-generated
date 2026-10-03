# 🪟 Prompts del track SQL Server
## Ruta SQL — 5 fases y 1 apéndice, opcionales

Los prompts del track opcional. Siguen la convención del repositorio para tracks: **archivos
propios, nunca añadidos a los del camino base**, para que una sesión del camino base no arrastre este
contexto. Las fichas están en [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) §10.

> ⚠️ **Antes de la primera sesión del track.** El camino base hasta F18, la imagen de SQL Server
> verificada en P8 (con emulación en Apple Silicon, en Docker Desktop **y** en Podman) y el perfil
> `sqlserver` del compose.

---

## 🧱 El marco del track

```markdown
## Marco (no lo repitas, aplícalo)

El marco común de `prompts/prompts-de-fase.md`, con tres cambios:

- **Todo resultado de SQL Server va sin resolver** (🪞🔒). Ni lecturas, ni filas reales, ni tiempos,
  ni tamaños medidos. El mecanismo se cita de la documentación oficial de Microsoft; la nota de
  licencia va la primera vez en cada fase. Los mensajes de error sí se publican.
- **El contraste es contra Postgres**, que es el motor que sí publica números, con las mediciones
  que el camino base ya tiene en la bitácora.
- **Plantilla:** la del track, en `plantillas-de-capitulo.md`. Tag `ss-fase-NN-<slug>`, prefijo
  `ssNN:`. Nada del track se escribe en un archivo del camino base.
```

El protocolo de tres pasos es el de `prompts-de-fase.md`.

---

## # ss01 — La base en su motor original

```markdown
Esta es la sesión de **ss01 — 🪟 La base en su motor original**. Entregable:
`ss01-la-base-en-su-motor-original.md`. **8 h · 20 ejercicios.** Requisito: F04.

{{marco del track}}

## Alcance
La ficha ss01. Cargar la caja en SQL Server con `bcp` y el DDL que generó SSMS; correr el T-SQL de
Matías tal cual, parser incluido; ver en vivo la ventana del año de dos dígitos (*two digit year
cutoff*, 2049 por defecto) contra la de VBA.

## Qué vigilar
- Es el único lugar del curso donde el lector ve "la base" en su motor original: la fase lo
  aprovecha para mostrar qué **no** cambia al migrar (🩻).
- La emulación en Apple Silicon se declara en el encabezado.

{{protocolo}}
```

---

## # ss02 — Pesimista contra RCSI

```markdown
Esta es la sesión de **ss02 — 🪟 Pesimista contra RCSI**. Entregable: `ss02-pesimista-contra-rcsi.md`.
**8 h · 22 ejercicios.** Requisito: F18.

{{marco del track}}

## Alcance
La ficha ss02: `READ COMMITTED` con bloqueos por defecto, el formulario del almuerzo que bloquea a
los lectores, `READ_COMMITTED_SNAPSHOT`, `SNAPSHOT` y el *version store*.

## Qué vigilar
- Las anomalías se reproducen con `lab race`, igual que en F15, para que la comparación con
  Postgres sea por comportamiento observado.

{{protocolo}}
```

---

## # ss03 — Query Store y *parameter sniffing*

```markdown
Esta es la sesión de **ss03 — 🪟 Query Store y parameter sniffing**. Entregable:
`ss03-query-store-y-parameter-sniffing.md`. **8 h · 22 ejercicios.** Requisito: F13.

{{marco del track}}

## Alcance
La ficha ss03: regresiones de plan, Query Store, planes forzados, `OPTIMIZE FOR` y las mejoras
recientes contra el *sniffing* (verificadas en la versión del curso).

## Qué vigilar
- La consulta por sede de F13 es el caso, para que el lector compare mecanismos sobre el mismo
  problema.

{{protocolo}}
```

---

## # ss04 — Clustered, `NEWSEQUENTIALID` y tablas temporales

```markdown
Esta es la sesión de **ss04 — 🪟 Clustered, NEWSEQUENTIALID y tablas temporales**. Entregable:
`ss04-clustered-newsequentialid-y-temporales.md`. **8 h · 20 ejercicios.** Requisitos: F07 y F10.

{{marco del track}}

## Alcance
La ficha ss04: el índice *clustered* sobre `uniqueidentifier` con `NEWID()` contra
`NEWSEQUENTIALID()`, y las tablas versionadas por sistema para la auditoría de resultados.

## Qué vigilar
- El contraste con MySQL de F10 es el más rico del track: los dos son *clustered*, y MySQL sí se
  publica.

{{protocolo}}
```

---

## # ss05 — Data API builder y el tipo `json`

```markdown
Esta es la sesión de **ss05 — 🪟 Data API builder y el tipo json**. Entregable:
`ss05-data-api-builder-y-json.md`. **8 h · 20 ejercicios.** Requisitos: F19 y F23.

{{marco del track}}

## Alcance
La ficha ss05: DAB contra PostgREST sobre el mismo esquema de Alameda, y el tipo `json` nativo de
SQL Server 2025, si la versión del curso lo trae (se verifica).

{{protocolo}}
```

---

## # ssa-01 — Qué cambia en Windows

```markdown
Esta es la sesión del **Apéndice ssa-01 — 🪟 Qué cambia en Windows**. Entregable:
`ssa-01-que-cambia-en-windows.md`. **1 h · 6 ejercicios.**

{{marco común de prompts-de-apendice.md}}

## Alcance
La ficha ssa-01 de la propuesta de apéndices: autenticación integrada, WSFC contra Pacemaker, SSMS,
`sqlcmd` y lo que no existe en Linux. Operación, no motor.

{{protocolo}}
```
