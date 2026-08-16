# 🏷️ Convención de git: commits y tags de progreso
## Tutorial React 16 — Rifas y chances

Cómo versionas el código que escribes mientras haces el curso. Es corto a
propósito: no es un proyecto de empresa, no hay releases ni equipo, y una
estrategia de ramas elaborada acá sobraría. Son tres cosas — un repo, commits
con un prefijo, y un tag por fase cerrada. Más tres usos de
los tags que en este curso rinden muchísimo por lo poco que cuestan: los
ejercicios, los incidentes y los puntos de retorno.

> 🔑 **La frase para memorizar:** un tag es un puntero a un commit. No ocupa
> espacio, no agrega overhead y se borra con `git tag -d`. La pregunta no es
> "¿vale la pena etiquetar esto?", es "¿por qué no?".

Y hay una razón extra, propia de este curso: acá vas a **romper cosas a
propósito**. Un tercio de los ejercicios te entrega algo roto, el middleware de
caos de la Fase 3 existe para que falle, y el cuaderno de incidentes vive de
reproducir bugs. Poder volver a un estado sano sin pensarlo no es comodidad: es
la condición para animarte a romper.

---

## 📦 Un repo, y una raya en la arena

Al empezar la Fase 0 haces `git init` en el proyecto que crea CRA
(`raffles-app`), y ese repo te acompaña las doce fases. Si más adelante haces el
track BE opcional 🔥, el backend en Go **no estrena repositorio**: vive en
`server/` dentro del mismo proyecto, con el frontend en la raíz sin moverse
(`prompts/propuesta-fases-backend.md` §9). Un repo, dos mundos, una raya en la
arena entre ellos.

Esa raya no es cosmética, y se defiende con git. La regla que gobierna el track
BE entero —fijada en la decisión **D21**— dice que se apaga el mock, se levanta
el binario de Go en el mismo puerto `3001`, y la aplicación React **no cambia ni
un archivo**. Eso no es una promesa retórica: es una afirmación que se mide, y se
mide así.

```bash
# antes de empezar el track BE, con el frontend terminado
git tag pre-backend-go

# …y después de que be03 apague json-server y levante el binario de Go
git diff pre-backend-go..HEAD -- . ':!server'
# (vacío)
```

Ese `':!server'` es un *pathspec* de exclusión: "todo menos el backend". Si el
comando devuelve algo —una línea en `apiClient.js`, un `baseURL` retocado, un
slice "adaptado" al nuevo formato de respuesta— la fase BE está mal hecha, y el
que se corrige es el backend. Vale la pena correrlo en cada fase BE, no solo al
final: cuanto antes aparezca la línea de más, más barata es de sacar.

Dos cosas para el primer commit, que después molestan. La primera: CRA ya te
deja un `.gitignore` correcto —`node_modules/`, `build/`, `.env*.local`—, pero
confirma antes de commitear que **`package-lock.json` sí está adentro del
repo**. Es la decisión **D7** y es la que hace reproducible todo lo demás: el
lockfile se commitea y manda. La segunda, cuando llegues al track BE: `.env`, el
binario compilado de Go y el directorio de datos de Postgres se suman al
`.gitignore`. Un secreto que entra al repo ya no sale, aunque borres el archivo
en el commit siguiente.

No hace falta remoto. Si lo tienes, recuerda que **los tags no viajan solos**:
`git push --tags`.

---

## 💬 Los mensajes de commit

Un prefijo, y ya. El prefijo es el código del documento: `f04` en las fases,
`a10` en los apéndices, y `be03` / `bea-02` en el track BE.

```bash
git commit -m "f04: raffleSlice con createSlice y los tres estados de carga"
git commit -m "f04: RaffleTable con loading, error y lista vacía"
git commit -m "f04 ej17: filtro por estado de rifa en el listado"
git commit -m "a10: money.js con toCents y formatMoney"
git commit -m "f06 ej22: takeUntil en el epic de refresco del tablero"
```

Los ejercicios llevan además su número, `ej17`, y así queda claro qué es
contenido de la fase y qué es práctica tuya. Eso te deja dos búsquedas útiles:

```bash
git log --oneline --grep '^f04'        # todo lo de la Fase 4
git log --oneline --grep '^f04 ej'     # solo los ejercicios de la Fase 4
```

El mensaje va en español y el código en inglés, igual que en todo el curso: el
commit lo lee el equipo, el identificador que cita sale del código. Commitea
seguido y con mensajes cortos. Nadie va a revisar tu historia, pero tú vas a
volver a ella cuando el ejercicio de la venta concurrente te deje el store
irreconocible.

> ⚠️ **La excepción son los incidentes.** El `cuaderno-incidentes.md` tiene su
> propia convención de asunto —`incidente(14): repro — …`, con verbos fijos—
> porque ahí el `git log` **es** la línea de tiempo de tu investigación. Manda
> esa, no esta.

---

## 🏷️ Un tag por fase cerrada

**Cuando cierras una fase —con su checklist de "✅ Qué queda listo al terminar"
en verde— haces commit y creas el tag.** Uno por fase, y no hace falta más.

El tag se llama **`fase-` + el mismo slug del archivo `.md`**, así no hay que
recordar nada: el archivo que estás leyendo te dice cómo se llama su tag. Los
apéndices usan `apendice-` + el slug en minúscula.

```
04-rifas-crud.md              →   fase-04-rifas-crud
06-redux-observable-a-fondo.md →   fase-06-redux-observable-a-fondo
A10-aritmetica-de-dinero.md   →   apendice-a10-aritmetica-de-dinero
be03-crud-y-el-reemplazo.md   →   fase-be03-crud-y-el-reemplazo
```

Anotado (`git tag -a`), porque así guarda fecha y mensaje —y la fecha es lo que
después te da la línea de tiempo del curso. El mensaje no se inventa: es el
checklist de la fase, con lo que efectivamente quedó funcionando.

```bash
git tag -a fase-04-rifas-crud -m "F4 cerrada: raffleSlice con createSlice,
CRUD completo contra el mock, los tres estados de carga y el error legible.
Tests: todavía no (F10). Persistencia de sesión: pagada en §5.5."
```

Si al escribir el mensaje descubres que un ítem del checklist no está, no está
la fase. El tag es honesto o no sirve para nada.

Los tags de fase van de `fase-00-setup-hola-mundo-cra` a
`fase-11-cierre-puente-react-moderno`, y los del track BE opcional de
`fase-be00-…` a `fase-be09-…`, con el slug que tenga cada archivo. Comparten
repo y comparten línea de tiempo: `git tag -l 'fase-*'` te devuelve las
veintidós en orden.

> 💡 **Los apéndices también se etiquetan, cuando dejan código.** `A2` te deja
> un mini design system, `A10` te deja `money.js`, `A11` te deja tests de
> marbles. Si el apéndice cambió algo en el repo, hay algo que marcar. Los que
> solo se leen —`A4`, `A8`, `A12`— no dejan tag: no hay nada que apuntar.

### Los puntos de retorno

Dos momentos del curso piden un tag **antes** de tocar nada, que no es un cierre
de fase sino el punto al que vuelves cuando la cosa se tuerce:

```bash
git tag pre-backend-go       # antes de empezar el track BE (§ de arriba)
git tag pre-modernizacion    # antes de los ejercicios 🔥 de la Fase 11
```

El segundo importa más de lo que parece. La Fase 11 te propone migrar cosas
—Router 6, RTK Query, RxJS 7— en ejercicios marcados 🔥 que **no** pertenecen al
código principal. Con `pre-modernizacion` puesto, experimentar deja de ser un
riesgo: pruebas la migración, mides lo que cuesta, y si no cierra vuelves al
código de 2022 con un comando.

> ⚠️ **Volver a un tag te deja en `detached HEAD`.** Es normal:
> `git checkout fase-05-venta-de-numeros` te pone a mirar ese estado sin estar
> en ninguna rama. Si vas a escribir desde ahí, crea una rama primero
> (`git checkout -b intento-2`). Para volver a tu línea principal,
> `git checkout master`.

---

## 🧪 Tags de ejercicios (opcional, pero baratos)

Los tags de fase son obligatorios; los de ejercicio son tuyos. Van en un
namespace aparte para que `git tag -l 'fase-*'` siga siendo un índice limpio de
progreso:

```bash
git tag ej/f04/17     # Fase 4, ejercicio 17
git tag ej/a10/3      # Apéndice A10, ejercicio 3
git tag ej/be05/22    # Track BE, fase be05, ejercicio 22
```

Y entonces `git tag -l 'ej/f04/*'` te lista lo que hiciste de esa fase.

Dos casos donde vale la pena de verdad. El primero, los **ejercicios de
diagnóstico** —al menos un tercio de cada fase te entrega algo roto y te pide
reproducir, localizar y explicar—, que piden dos tags en vez de uno:

```bash
git tag ej/f06/25-roto     # el bug reproducido, antes de tocar nada
git tag ej/f06/25-fix      # el fix aplicado y verificado

git diff ej/f06/25-roto ej/f06/25-fix
```

Ese `diff` es la corrección aislada del ruido, y sigue siendo legible dentro de
seis meses. En este curso además tiene un uso que no es cosmético: buena parte
de los fixes de epics son de **una línea** —un `takeUntil` al final del `pipe`,
un `catchError` movido adentro del `mergeMap`— y esa línea, vista sola en un
diff, es exactamente la lección. Enterrada entre veinte archivos de la fase, no
la vuelves a encontrar.

El segundo caso son los **ejercicios de medición** —los 🟠 y 🔴 del dashboard,
los de bundle y source maps de `A13`—, donde el número va en el mensaje del tag
y queda pegado al commit que lo produjo:

```bash
git tag -a ej/f09/26 -m "Profiler sin useMemo: 38 renders y 240 ms de commit
al filtrar. Con el selector memoizado: 4 renders y 11 ms. Dataset: 120 rifas,
9.600 números."
```

Después, `git tag -n99 -l 'ej/f09/*'` te devuelve tu cuaderno de mediciones sin
abrir un archivo.

> ⚠️ **Un cuidado, uno solo.** No crees nunca un tag llamado literalmente
> `ej/f04`. Git guarda los refs como archivos: si existe el archivo
> `refs/tags/ej/f04`, no puede existir además el directorio `refs/tags/ej/f04/`,
> y el `git tag ej/f04/17` falla con un error confuso. Los niveles intermedios
> del namespace se quedan vacíos, siempre.

---

## 🚑 Incidentes: acá el tag sí es contenido

El `cuaderno-incidentes.md` plantea veinte incidentes —el número vendido dos
veces, el epic que sigue pidiendo al servidor después del logout, la rifa que
vendió pasada la hora de cierre— y pide resolverlos con la estructura de
post-mortem de ocho puntos de la guía de estilo (§13): síntoma, repro,
evidencia, causa raíz, corrección, prueba de regresión, prevención, y el
análisis sin culpabilización.

Esa estructura tiene una traducción exacta a git, y por eso acá el par de tags
deja de ser opcional. El namespace es **`inc/<ID>/<slug-corto>`**, con el ID que
el cuaderno ya tiene reservado —nunca uno inventado, nunca uno reasignado— y los
dos sufijos de siempre, `-roto` y `-fix`:

```bash
# Puntos 1-3: el síntoma reproducido y la prueba de regresión EN ROJO
git tag -a inc/14/suscripcion-zombi-roto -m "Síntoma: cerré sesión y el
servidor sigue recibiendo peticiones. Repro: login, abrir el tablero de la
rifa 3, logout, mirar Network. Evidencia: GET /raffles/3/numbers cada 5 s con
el tablero desmontado y sin token."

# Puntos 4-6: la causa raíz, el fix, y la misma prueba EN VERDE
git tag -a inc/14/suscripcion-zombi-fix -m "Causa raíz: boardRefreshEpic sin
takeUntil: el interval que abre el switchMap no se cancela nunca. Fix:
takeUntil(STOP_BOARD_REFRESH, LOGOUT) último en el pipe interno. Regresión:
marble test que verifica que el observable completa al llegar el logout."
```

Con eso, `git diff inc/14/suscripcion-zombi-roto inc/14/suscripcion-zombi-fix`
**es** el punto 5 del post-mortem —la corrección, aislada del ruido— y los dos
mensajes de tag son los puntos 1 a 6 escritos donde no se pierden.

Y como esos fixes son de una línea, el par de tags resuelve además el problema
práctico de tenerlos a mano: `git tag -n99 -l 'inc/*'` te devuelve el cuaderno
de incidentes entero, con causa raíz y fix, sin abrir un archivo. Esa es la
parte transferible: es exactamente lo que vas a querer tener el día que el
incidente no sea de juguete.

> 📝 **Las ramas `incidente/NN` son otra cosa.** El cuaderno usa ramas con ese
> nombre en la sección "🔧 Preparación" de cada incidente, para dejar el repo en
> el estado roto de partida. La rama te lleva al problema; los tags marcan tu
> recorrido resolviéndolo. Conviven sin pisarse.

> 🔥 **Y las del track BE llevan el `be-` adentro**, igual que los IDs de su
> cuaderno: `incidente/be-05`, `incidente/be-09`. Salen del tag `fase-beNN-…` de
> la fase que produce el incidente, y como el backend **no estrena repositorio**
> —vive en `server/`, dentro de este mismo—, conviven con las del track base sin
> pisarse. Tres de ellas tienen el `git diff` vacío a propósito: su causa no está
> en el árbol de fuentes sino en una variable de entorno, en el reloj de la
> máquina o en la zona del contenedor de Postgres. Una rama vacía también es un
> estado, y ese es justamente el aprendizaje.

```bash
git checkout -b incidente/be-09 fase-be05-venta-concurrente
```

---

## 🧹 El `db.json` que se ensucia (el truco que más vas a usar)

El mock guarda de verdad. Vendes números, liquidas rifas, cambias estados — y
todo eso se escribe en `mock/db.json`. Después de media hora de ejercicios de
venta concurrente, tu tablero es un campo de batalla y ya no puedes reproducir
el caso limpio del enunciado.

Como `db.json` está versionado —es el dato semilla del curso, no un artefacto
generado—, restaurarlo es un comando:

```bash
git checkout -- mock/db.json     # tablero limpio, sin tocar nada más
```

Ese comando vale por sí solo lo que cuesta leer este archivo. Y su corolario:
cuando un ejercicio te pida un dato particular —una rifa con 400 números
vendidos, una liquidación con centavos que no cuadran—, cárgalo, **commitéalo
como escenario** (`git commit -m "f08 ej24: escenario de descuadre por centavo"`)
y etiquétalo si vas a volver. Reconstruir a mano un escenario que ya tuviste es
el peor uso posible de tu tiempo.

---

## 📈 Los comandos que hacen que esto sirva

```bash
# ¿Dónde estoy?
git tag -l 'fase-*'

# Cuándo cerré cada fase
git for-each-ref --sort=creatordate \
  --format='%(creatordate:short)  %(refname:short)' 'refs/tags/fase-*'

# Qué costó una fase, en archivos y líneas
git diff fase-05-venta-de-numeros..fase-06-redux-observable-a-fondo --stat

# Volver a un estado sano
git checkout fase-05-venta-de-numeros
git checkout -- mock/db.json

# Los ejercicios de una fase, y el cuaderno de incidentes completo
git tag -n99 -l 'ej/f09/*'
git tag -n99 -l 'inc/*'

# La prueba de que el backend de Go honró el contrato (track BE)
git diff pre-backend-go..HEAD -- . ':!server'
```

---

## ✅ Checklist de cierre de fase

- [ ] El checklist de "✅ Qué queda listo al terminar" de la fase, en verde y
      verificado a mano.
- [ ] `git status` limpio: todo lo de la fase está commiteado.
- [ ] `git tag -a fase-NN-slug -m "…"` creado, con el checklist en el mensaje.
- [ ] Si la fase dejó un incidente resuelto, su par `inc/<ID>/…-roto` /
      `inc/<ID>/…-fix` existe y sus mensajes cuentan síntoma, causa raíz y fix.
- [ ] `mock/db.json` en el estado que quieres heredar a la fase siguiente — o
      restaurado con `git checkout --` si lo dejaste hecho un desastre.

> **La señal de que quedó bien:** "vuelvo después de tres semanas, corro
> `git tag -l 'fase-*'`, y sé exactamente dónde me quedé y qué sigue — sin
> releer una sola línea del curso".
