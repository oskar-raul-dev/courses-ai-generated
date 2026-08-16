# 🏷️ Convención de git: commits y tags de progreso
## Paquete Mini Jira — Curso 01 (Vue 2 legacy) + Curso 02 (MongoDB/Express)

Cómo versionas el código que escribes mientras haces los cursos. Es corto a
propósito: no es un proyecto de empresa, no hay releases ni equipo, y una
estrategia de ramas elaborada acá sobraría. Son tres cosas — un repo por curso,
commits con un prefijo, y un tag por fase cerrada. Más tres usos de los tags que
rinden mucho por lo poco que cuestan: los ejercicios, los incidentes y las
deudas 💸 que un curso le deja al otro.

> 🔑 **La frase para memorizar:** un tag es un puntero a un commit. No ocupa
> espacio, no agrega overhead y se borra con `git tag -d`. La pregunta no es
> "¿vale la pena etiquetar esto?", es "¿por qué no?".

---

## 📦 Un repo por curso

Al empezar el Curso 01 haces `git init` en el proyecto que crea Vue CLI
(`mini-jira-legacy`). Al empezar el Curso 02, otro `git init` en el del backend
(`minijira-backend`). **Dos repos, no uno.**

No es una preferencia estética. La señal de éxito del paquete se mide con git:
se apaga json-server, se cambia el `baseURL` y **el `git diff` del frontend
tiene exactamente una línea** —lo firmado en
[`../02-complement-mongodb-backend/00-audit-contrato.md`](../02-complement-mongodb-backend/00-audit-contrato.md)
y ejecutado en la Fase 10 del Curso 02. En un monorepo ese `git diff` te
devuelve además todo el backend que acabas de escribir, y la medición se
convierte en humo.

Dos cosas para el primer commit, que después molestan: `node_modules/` y
`dist/` fuera (Vue CLI ya te deja el `.gitignore` hecho), y en el Curso 02
también `.env` y `mongo-data/`. Un secreto que entra al repo ya no sale, aunque
borres el archivo en el commit siguiente.

No hace falta remoto. Si lo tienes, recuerda que **los tags no viajan solos**:
`git push --tags`.

---

## 💬 Los mensajes de commit

Un prefijo, y ya. El prefijo es el código de la fase: `f04` en las numeradas,
`q3` / `vu2` / `nx1` en las de ruta.

```bash
git commit -m "f04: tabla de tickets con badges de estado"
git commit -m "f04: filtros por estado y búsqueda con computed"
git commit -m "f04 ej17: filtro por prioridad en el dashboard"
git commit -m "q3: QTable con paginación en servidor"
git commit -m "f07 ej22: índice ESR sobre status + createdAt"
```

Los ejercicios llevan además su número, `ej17`, y así queda claro qué es
contenido de la fase y qué es práctica tuya. Eso te deja dos búsquedas útiles:

```bash
git log --oneline --grep '^f04'        # todo lo de la Fase 4
git log --oneline --grep '^f04 ej'     # solo los ejercicios de la Fase 4
```

Commitea seguido y con mensajes cortos. Nadie va a revisar tu historia, pero tú
vas a volver a ella cuando el ejercicio 22 te deje el proyecto irreconocible.

### Los apéndices

Lo que sale de leer un apéndice también se commitea, y lleva su propio código de
prefijo: `a4` en el Curso 01, `a02` en el Curso 02 —un dígito y dos dígitos,
respetando cómo se llama cada archivo.

```bash
git commit -m "a4: interceptor de axios con reintento"
git commit -m "a02: pipeline de agregación probado en Compass"
```

**Los apéndices no cierran con tag**, y no es un olvido: un tag marca un cambio
en el repositorio, y un apéndice explica lo que ya está ahí. Un tag que no marca
un cambio no marca nada. Por eso ningún apéndice trae el bloque 🏷️ de cierre que
sí traen las fases — está dicho en la
[guía de estilo §9.1](guia-de-estilo-y-convenciones.md).

> 💡 **Si un apéndice te deja archivos versionados** —el `docker-compose.yml`
> de A01, los scripts de `package.json` que arma A3— y quieres poder volver a
> ese punto, `apendice-a01` / `apendice-a3` existe como opción tuya. Ningún
> apéndice te lo va a pedir: es un atajo disponible, no un paso del curso.

---

## 🏷️ Un tag por fase cerrada

**Cuando cierras una fase —con su checklist de "✅ Qué queda listo al terminar"
en verde— haces commit y creas el tag.** Uno por fase, y no hace falta más.

El tag se llama **`fase-` + el mismo slug del archivo `.md`**, así no hay que
recordar nada: el archivo que estás leyendo te dice cómo se llama su tag.

```
04-dashboard-tickets.md   →   fase-04-dashboard-tickets
q2-migrar-crud-qform.md   →   fase-q2-migrar-crud-qform
07-indices.md             →   fase-07-indices
```

Anotado (`git tag -a`), porque así guarda fecha y mensaje —y la fecha es lo que
después te da la línea de tiempo del curso. El mensaje no se inventa: es el
checklist de la fase, con lo que efectivamente quedó funcionando.

```bash
git tag -a fase-04-dashboard-tickets -m "F4 cerrada: tabla con badges, filtros
con computed, estados de loading y error. Tests: todavía no (F11)."
```

Si al escribir el mensaje descubres que un ítem del checklist no está, no está
la fase. El tag es honesto o no sirve para nada.

Los tags de fase del Curso 01 van de `fase-00-setup-hola-mundo` a
`fase-11-testing-minimo`, más los de la ruta que elijas (`fase-q0-…` a
`fase-q4-…`, o sus equivalentes `vu` y `nx`). Los del Curso 02, de
`fase-00-preliminares` a `fase-15-el-veredicto-honesto`.

> 💡 **Las fases sin código también se etiquetan.** La Fase 8 del Curso 02
> produce `AUTOPSIA.md` y una base rediseñada; la 15 produce criterio y
> `MODERNIZATION.md`. Si la fase cambió algo en el repo, hay algo que marcar.

### Los puntos de retorno de las rutas

Las tres fases X0 piden además un tag **antes** de migrar nada, que no es un
cierre de fase sino el punto al que vuelves cuando la migración se tuerce:

```bash
git tag pre-quasar     # antes de Q1  (lo pide q0-red-de-seguridad.md)
git tag pre-vuetify    # antes de VU1 (lo pide vu0-red-de-seguridad.md)
git tag pre-nuxt       # antes de NX1 (lo pide nx0-red-de-seguridad.md)
```

Van en el mismo commit que el `fase-x0-red-de-seguridad`. Son dos nombres para
el mismo punto: uno dice "terminé la fase", el otro "acá es donde vuelvo".

> ⚠️ **Volver a un tag te deja en `detached HEAD`.** Es normal:
> `git checkout fase-05-crud-tickets` te pone a mirar ese estado sin estar en
> ninguna rama. Si vas a escribir desde ahí, crea una rama primero
> (`git checkout -b intento-2`). Para volver a tu línea principal,
> `git checkout master`.

---

## 🧪 Tags de ejercicios (opcional, pero baratos)

Los tags de fase son obligatorios; los de ejercicio son tuyos. Van en un
namespace aparte para que `git tag -l 'fase-*'` siga siendo un índice limpio de
progreso:

```bash
git tag ej/f04/17     # Curso 01 tronco, Fase 4, ejercicio 17
git tag ej/q3/22      # Curso 01 ruta Q, fase Q3, ejercicio 22
git tag ej/f07/22     # Curso 02, Fase 7, ejercicio 22
git tag ej/a01/3      # Curso 02, apéndice A01, ejercicio 3
```

Y entonces `git tag -l 'ej/f04/*'` te lista lo que hiciste de esa fase.

> 📝 Los dos cursos numeran sus fases desde cero, así que `ej/f07/…` significa
> una cosa en un repo y otra en el otro. No colisionan porque **son repos
> distintos**; leído del tirón, arriba, parece un error y no lo es.

Dos casos donde vale la pena de verdad. El primero, los **ejercicios de
diagnóstico** —al menos un tercio del paquete te entrega algo roto y te pide
reproducir, localizar y explicar—, que piden dos tags en vez de uno:

```bash
git tag ej/f08/25-roto     # el bug reproducido, antes de tocar nada
git tag ej/f08/25-fix      # el fix aplicado y verificado

git diff ej/f08/25-roto ej/f08/25-fix
```

Ese `diff` es la corrección aislada del ruido, y sigue siendo legible dentro de
seis meses. El segundo caso son los **ejercicios de medición** —buena parte de
los 🔴 del Curso 02—, donde el número va en el mensaje del tag y queda pegado
al commit que lo produjo:

```bash
git tag -a ej/f07/22 -m "explain() sin índice: 14.200 docsExamined / 380 ms.
Con status_1_createdAt_-1 (ESR): 42 examined / 3 ms. Dataset: 50k tickets."
```

Después, `git tag -n99 -l 'ej/f07/*'` te devuelve tu cuaderno de mediciones sin
abrir un archivo. Para el arco de `soporte_v1` —que se huele en F3, se mide en
F5, se indexa en F7 y se opera en F8— eso es directamente el insumo de la
autopsia: los números de antes están en los tags de la 5 y la 7.

> ⚠️ **Un cuidado, uno solo.** No crees nunca un tag llamado literalmente
> `ej/f04`. Git guarda los refs como archivos: si existe el archivo
> `refs/tags/ej/f04`, no puede existir además el directorio `refs/tags/ej/f04/`,
> y el `git tag ej/f04/17` falla con un error confuso. Los niveles intermedios
> del namespace se quedan vacíos, siempre.

---

## 🚑 Incidentes: acá el tag sí es contenido

Los cursos plantean **incidentes de juguete** —el mock caído que parece un bug
del frontend, el test que descarga medio internet la primera vez, la query
fugitiva de la guardia simulada de F14— y piden resolverlos con la estructura
de post-mortem de ocho puntos de la guía de estilo (§14): síntoma, repro,
evidencia, causa raíz, corrección, prueba de regresión, prevención, y el
análisis sin culpabilización.

Esa estructura tiene una traducción exacta a git, y por eso acá el par de tags
deja de ser opcional:

```bash
# Puntos 1–3: el síntoma reproducido y la prueba de regresión EN ROJO
git tag -a inc/f13/descarga-silenciosa-roto -m "Síntoma: la suite tarda 90s la
primera vez y falla por timeout. Repro: borrar ~/.cache/mongodb-binaries y
correr npm test. Evidencia: el log de mongodb-memory-server descargando 4.4."

# Puntos 4–6: la causa raíz, el fix, y la misma prueba EN VERDE
git tag -a inc/f13/descarga-silenciosa-fix -m "Causa raíz: el default del
paquete descarga el binario en el primer arranque, dentro del timeout de Jest.
Fix: binario precargado en el postinstall + testTimeout explícito.
Regresión: la suite corre en 6s en una caché limpia."
```

El namespace es `inc/<fase>/<slug-corto>` y los dos sufijos son siempre los
mismos: `-roto` y `-fix`. Con eso, `git diff inc/f13/descarga-silenciosa-roto
inc/f13/descarga-silenciosa-fix` **es** el punto 5 del post-mortem —la
corrección, aislada del ruido— y los dos mensajes de tag son los puntos 1 a 6
escritos donde no se pierden.

`git tag -n99 -l 'inc/*'` te devuelve tu bitácora entera sin abrir un archivo, y
ésa es la parte transferible: es exactamente lo que vas a querer tener el día
que el incidente no sea de juguete.

Los enunciados viven en el `cuaderno-incidentes.md` de tu curso —doce por
cuaderno, con su preparación, sus pistas y su solución de referencia— y el
reparto es claro: **el archivo es el enunciado y tu investigación escrita; los
tags son la misma investigación, ejecutable.** El `git diff` entre el par
`-roto` y `-fix` es lo único que no se puede falsificar.

---

## 🕵️ Lo que se commitea al recorrer una pieza forense

Poco, y por eso esta sección es corta. Una pieza forense **no produce código del
proyecto**: el código lo escriben las fases, y la pieza te enseña a encontrar
dónde está el problema. Lo que salga de recorrerla —una nota, un script de
diagnóstico, un `console.count` que dejaste puesto— se commitea con el prefijo
de su fase, `f08:`, como cualquier otra cosa de esa fase.

Los dos casos que sí dejan marca ya tienen su namespace más arriba y **no se
inventa uno nuevo**:

- Si el recorrido corresponde a un incidente del cuaderno, va el par
  `inc/<fase>/<slug>-roto` / `-fix` que el cuaderno ya reservó.
- Si sale de un ejercicio de "rompe a propósito", va el par
  `ej/f08/25-roto` / `ej/f08/25-fix`.

No existe un namespace `forense/`, y no debería: un tag marca un cambio, y
mirar no cambia nada. El detalle de cómo se escriben las piezas y el cuaderno
vive en `formato-piezas-forenses.md` y `formato-cuaderno-incidentes.md`, no acá.

---

## 💸 La deuda que sí se paga (y cómo se lee la factura)

Los dos cursos declaran deuda técnica a propósito, la marcan 💸 y dicen en qué
fase se salda. Eso convierte a los tags en algo más que marcadores de progreso:
en los dos extremos de una comparación. Y hay dos casos, que se leen distinto.

**Cuando la deuda nace y muere en el mismo repo.** La Fase 2 del Curso 01 deja
el `login` como una action síncrona porque todavía no hay red, y la Fase 3 lo
paga cuando llega json-server. El diff entre los dos tags de fase, acotado a la
carpeta que cambió, **es** el material del repaso:

```bash
git diff fase-02-autenticacion-minima fase-03-mock-api-minima -- src/store
```

No es una métrica. Es la respuesta a *"¿cuánto costó de verdad arreglar esto?"*,
que es la pregunta que te van a hacer la próxima vez que propongas pagar una
deuda en un sistema real.

**Cuando la deuda cruza los dos repos.** Acá está la deuda estrella del paquete,
y `git diff` no te sirve: la Fase 8 del Curso 01 deja al cliente emitiendo el
evento de socket que debería emitir el servidor —el *cliente mentiroso*— y eso
se paga en la Fase 12 del **otro** curso, en otro repositorio. `git diff` no
cruza repos, así que la comparación hay que armarla a mano… o dejar escritas las
dos mitades donde no se pierden:

```bash
# Repo del Curso 01, al cerrar la fase que declara la deuda:
git tag -a deuda/cliente-mentiroso-declarada -m "F8: el cliente emite
ticket:updated, que debería emitir el servidor. Se paga en el repo del Curso 02,
Fase 12."

# Repo del Curso 02, en el commit que la salda:
git tag -a deuda/cliente-mentiroso-pagada -m "F12: el io.emit sale del servidor
después del write. Cierra deuda/cliente-mentiroso-declarada del repo del
Curso 01 (F8)."
```

El que declara dice qué se debe y dónde se paga; el que paga dice qué cerró y de
dónde venía. Con eso, `git tag -n99 -l 'deuda/*'` te devuelve en cada repo su
mitad del libro mayor, y las dos juntas son la factura completa.

> 💡 **Y esto le da mecánica a algo que ya venías escribiendo.**
> `SECURITY-NOTES.md` acumula desde la Fase 2 del Curso 01 todo lo que "lo
> debería hacer el backend", y la
> [Fase 11 del Curso 02](../02-complement-mongodb-backend/11-auth-real-y-pago-de-deudas.md)
> te pide tachar cada deuda **referenciando el commit que la resolvió**. Ese
> commit es exactamente el que lleva el tag `deuda/…-pagada`: en vez de buscarlo
> en el log, lo nombras.

---

## 🧹 El `db.json` que se ensucia (el truco que más vas a usar)

json-server escribe de verdad. Creas tickets, tomas otros, dejas comentarios — y
todo eso se guarda en `db.json`, que está versionado porque es dato del curso.
Después de media hora de ejercicios tu base de pruebas es un campo de batalla y
ya no puedes reproducir el caso limpio del enunciado.

Tienes dos formas de volver, y **no son la misma**:

```bash
git checkout -- db.json     # te devuelve el archivo como lo commiteaste
npm run mock:reset          # lo pisa entero desde db.seed.json
```

La primera te deja el archivo tal como estaba en tu último commit, con los
escenarios que hubieras construido dentro. La segunda lo regenera desde la
semilla y se los lleva por delante. `db.seed.json` y el script `mock:reset` los
creas tú en el ejercicio 14 de la
[Fase 3](../01-vue2-legacy/03-mock-api-minima.md), y ésa es la razón por la que
ese ejercicio no es opcional.

De ahí sale el hábito que más te va a servir: cuando un ejercicio te pida un dato
particular —un ticket que llega sin el campo `tags`, dos agentes con el mismo
ticket asignado, un comentario cuyo ticket ya no existe—, cárgalo, **commitéalo
como escenario** y etiquétalo si vas a volver:

```bash
git commit -m "f05 ej22: escenario de ticket sin tags"
```

Reconstruir a mano un escenario que ya tuviste es el peor uso posible de tu
tiempo.

> 📝 **En el Curso 02 el estado sucio no está en un archivo, está en la base.**
> Se vuelve con `npm run seed`, o levantando el contenedor de cero cuando la
> cosa se puso fea de verdad
> ([A01](../02-complement-mongodb-backend/a01-docker.md)).

---

## 🐳 Una cosa más, para la Fase 14 del Curso 02

El compose final de la
[Fase 14](../02-complement-mongodb-backend/14-operacion.md) empaqueta el sistema
entero, y el Dockerfile de la API aparece ahí. Cuando llegues, **no dejes esa
imagen en `:latest`**: etiquétala con el mismo nombre del tag de git que la
produjo.

```bash
docker build -t minijira-api:fase-14-operacion .
```

Es el mismo reflejo que ya practicaste sin darte cuenta al fijar
`MONGO_VERSION` en vez de aceptar `mongo:latest`
([A01](../02-complement-mongodb-backend/a01-docker.md)) — solo que ahora la
imagen sin versionar es la tuya. El día que algo se comporte distinto de como se comportaba
ayer, la primera pregunta es *"¿qué código hay adentro?"*, y con `:latest` no
tienes cómo contestarla. Es la mitad barata del diagnóstico, y es la que casi
nadie tiene.

---

## 📈 Los comandos que hacen que esto sirva

```bash
# ¿Dónde estoy?
git tag -l 'fase-*'

# Cuándo cerré cada fase
git for-each-ref --sort=creatordate \
  --format='%(creatordate:short)  %(refname:short)' 'refs/tags/fase-*'

# Qué costó una fase, en archivos y líneas
git diff fase-03-mock-api-minima..fase-04-dashboard-tickets --stat

# Volver a un estado sano
git checkout fase-05-crud-tickets

# Recuperar un archivo de una fase anterior sin moverte de sitio
git checkout fase-05-crud-tickets -- src/components/tickets/TicketForm.vue

# Arrancar un incidente desde la fase que lo produce
git switch -c incidente/07 fase-04-dashboard-tickets

# Los ejercicios de una fase, el cuaderno de incidentes, y el libro de deudas
git tag -n99 -l 'ej/f07/*'
git tag -n99 -l 'inc/*'
git tag -n99 -l 'deuda/*'
```

---

## ✅ Checklist de cierre de fase

- [ ] El checklist de "✅ Qué queda listo al terminar" de la fase, en verde y
      verificado a mano.
- [ ] `git status` limpio: todo lo de la fase está commiteado.
- [ ] `git tag -a fase-NN-slug -m "…"` creado, con el checklist en el mensaje.
- [ ] Si la fase dejó un incidente resuelto, su par `inc/…-roto` / `inc/…-fix`
      existe y sus mensajes cuentan síntoma, causa raíz y fix.
- [ ] Si la fase **declara** una deuda 💸, tiene su tag `deuda/<slug>-declarada`
      y el mensaje dice en qué curso y en qué fase se paga.
- [ ] Si la fase **paga** una deuda, tiene su tag `deuda/<slug>-pagada`, el
      mensaje nombra al tag hermano, y `SECURITY-NOTES.md` quedó tachado.

> **La señal de que quedó bien:** "vuelvo después de tres semanas, corro
> `git tag -l 'fase-*'`, y sé exactamente dónde me quedé y qué sigue — sin
> releer una sola línea del curso".
