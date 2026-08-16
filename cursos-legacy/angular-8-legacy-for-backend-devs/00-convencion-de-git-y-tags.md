# 🏷️ Convención de git: commits y tags de progreso
## Tutorial Angular 8 — Laboratorio clínico

Cómo versionas el código que escribes mientras haces el curso. Es corto a
propósito: no es un proyecto de empresa, no hay releases ni equipo, y una
estrategia de ramas elaborada acá sobraría. Son tres cosas — un repo, commits
con un prefijo, y un tag por fase cerrada. Más tres usos de los tags que en este
curso rinden muchísimo por lo poco que cuestan: los ejercicios, los incidentes y
los puntos de retorno.

> 🔑 **La frase para memorizar:** un tag es un puntero a un commit. No ocupa
> espacio, no agrega overhead y se borra con `git tag -d`. La pregunta no es
> "¿vale la pena etiquetar esto?", es "¿por qué no?".

Y hay una razón extra, propia de este curso: acá vas a **romper cosas a
propósito**. El inyector de caos de la Fase 4 existe para que la aplicación
falle, un tercio de los ejercicios de cada fase te entrega algo roto, y el
cuaderno de incidentes vive de reproducir bugs. Poder volver a un estado sano sin
pensarlo no es comodidad: es la condición para animarte a romper.

Hay además una razón que no es pedagógica sino mecánica, y por eso los tags de
fase de acá **no son opcionales**. El cuaderno de incidentes reparte el sistema
roto de tres formas, y la tercera —la rama `incidente/NN`— sale, literalmente,
"del commit donde terminaste la fase correspondiente". Ese commit tiene que
poder nombrarse. Si no lo etiquetaste, la única forma de encontrarlo dentro de
tres semanas es leer el `git log` entero adivinando dónde terminó la Fase 7.

---

## 📦 Un repo, y el CLI ya lo abrió

No hace falta `git init`. La **Fase 0 §5.2** crea el proyecto con
`npx @angular/cli@8.3.29 new clinical-lab … --skip-git=false`, y esa bandera
—que está puesta a propósito— hace que el CLI inicialice el repositorio y deje
el commit inicial con el andamiaje. Compruébalo apenas entres a la carpeta:

```bash
cd clinical-lab
git log --oneline     # un commit: "initial commit" (o similar, según el CLI)
```

Ese repo te acompaña las quince fases y todo lo que el curso construye vive
adentro: la aplicación en `src/`, el mock en `mock-server/`, el `db.json` y el
`seed.js` en la raíz, y en la Fase 13 el `Dockerfile`, el `nginx.conf` y el
`entrypoint.sh`. **Un solo repo, sin excepciones.** El mock es código del curso y
no de LabCore, pero comparte repositorio con él por la misma razón por la que
comparte máquina: los dos se rompen juntos y se diagnostican juntos.

El `.gitignore` que dejó el CLI ya está bien —`/dist`, `/node_modules`,
`/coverage` y la basura de los editores— y no hace falta tocarlo al principio.
Dos cosas sí conviene mirar antes del primer commit tuyo. La primera:
**`package-lock.json` va adentro del repo**, y no es un detalle. La Fase 0 §1
abre con eso —el lock es lo que reproduce el árbol que produjo el binario que
estás mirando— y el **Apéndice A03 §9** insiste en que es lo único que se
comparte entre plataformas, porque un `node_modules` no. La segunda: si alguna
vez sacas el secreto de firma del mock (**Fase 3**) a un archivo `.env`, ese
archivo no entra al repositorio. Un secreto que entra ya no sale, aunque borres
el archivo en el commit siguiente — y da igual que sea de juguete: el hábito es
lo que estás practicando.

No hace falta remoto. Si lo tienes, recuerda que **los tags no viajan solos**:
`git push --tags`.

---

## 💬 Los mensajes de commit

Un prefijo, y ya. El prefijo es el código del documento: `f04` en las fases,
`a05` en los apéndices.

```bash
git commit -m "f05: PatientService y el slice de pacientes contra el mock"
git commit -m "f05: tabla de Material con paginación del lado del cliente"
git commit -m "f05 ej17: filtro por documento en el listado de pacientes"
git commit -m "a02: variables de Bootstrap redeclaradas antes del @import"
git commit -m "f08 ej24: rango v2 sembrado con vigencia solapada"
```

Los ejercicios llevan además su número, `ej17`, y así queda claro qué es
contenido de la fase y qué es práctica tuya. Eso te deja dos búsquedas útiles:

```bash
git log --oneline --grep '^f05'        # todo lo de la Fase 5
git log --oneline --grep '^f05 ej'     # solo los ejercicios de la Fase 5
```

El mensaje va en español y el código en inglés, igual que en todo el curso: el
commit lo lee el equipo, el identificador que cita sale del código
(`validateResult`, no `validarResultado`). Commitea seguido y con mensajes
cortos. Nadie va a revisar tu historia, pero tú vas a volver a ella cuando el
ejercicio de la validación concurrente te deje el store irreconocible.

> ⚠️ **La excepción son los incidentes.** El `cuaderno-incidentes.md` tiene su
> propia convención de asunto —`incidente(07): repro — …`, con verbos fijos:
> `abre`, `repro`, `hipótesis`, `hipótesis descartada`, `causa`, `fix`,
> `cierre`— porque ahí el `git log` **es** la línea de tiempo de tu
> investigación. Manda esa, no esta.

---

## 🏷️ Un tag por fase cerrada

**Cuando cierras una fase —con su checklist de "✅ Qué queda listo al terminar"
en verde— haces commit y creas el tag.** Uno por fase, y no hace falta más.

> 🧭 **El tag de fase es obligatorio, y no por disciplina.** Es la única pieza
> de esta convención que otro material del curso da por hecha: las ramas
> `incidente/NN` del cuaderno **salen del commit donde cerraste la fase que
> produce cada incidente**, y lo hacen nombrando el tag —
> `git checkout -b incidente/03 fase-01-estructura-base-ngrx`. Sin tag, ese
> commit no tiene nombre, y preparar el incidente pasa de un comando a bucear
> en `git log` a ver cuál era. **Nueve de los veintiún incidentes** empiezan
> así, y los otros doce siguen necesitando el tag como punto de retorno cuando
> el diagnóstico te deja el sistema peor de lo que estaba. Los tags de
> ejercicio son tuyos y puedes saltártelos; éste no.

El tag se llama **`fase-` + el mismo slug del archivo `.md`**, así no hay que
recordar nada: el archivo que estás leyendo te dice cómo se llama su tag.

```
03-autenticacion.md          →   fase-03-autenticacion
07-muestras-custodia.md      →   fase-07-muestras-custodia
13-build-despliegue.md       →   fase-13-build-despliegue
```

Anotado (`git tag -a`), porque así guarda fecha y mensaje —y la fecha es lo que
después te da la línea de tiempo del curso. El mensaje no se inventa: es el
checklist de la fase, con lo que efectivamente quedó funcionando.

```bash
git tag -a fase-07-muestras-custodia -m "F7 cerrada: slice de muestras con la
máquina de estados endurecida en sample.transitions.ts, timeline de custodia
en la vista, y la transición imposible rechazada también desde DevTools.
Tests: todavía no (F12)."
```

Si al escribir el mensaje descubres que un ítem del checklist no está, no está
la fase. El tag es honesto o no sirve para nada.

Los tags de fase van de `fase-00-setup-hola-mundo` a `fase-13-build-despliegue`,
más `fase-14-casi-prod-kind` si haces la fase 🔥 opcional. Catorce obligatorios y
uno más, y `git tag -l 'fase-*'` te los devuelve en orden.

> 💡 **Los apéndices normalmente no llevan tag propio.** Son consulta rápida: el
> código de Material, de Bootstrap, de NgRx o del PDF lo escriben las fases, y
> los apéndices te explican lo que ya está en el repo. Un tag que no apunta a un
> cambio no marca nada. La excepción es el **A13 §6**, que sí escribe archivos
> —el `.devcontainer/`— y cuyo destino es una decisión de proyecto abierta: si
> decides versionarlo, ese commit se etiqueta `apendice-a13-docker-colima` y ahí
> queda dicho cuándo entró y por qué. Todo lo demás que salga de leer un
> apéndice se commitea con el prefijo de la fase desde la que llegaste (`f10:
> …`), para que el `git log --oneline --grep '^f10'` de esa fase siga completo.

### Los puntos de retorno

Los tags de fase ya son tus puntos de retorno: `git checkout
fase-05-pacientes` te devuelve al sistema tal como estaba antes de que
empezaras a experimentar. Solo hay un momento del curso que pide un tag
**adicional**, antes de tocar nada, y es el ensayo de migración del
**Apéndice A10**:

```bash
git tag pre-spike-9     # antes del ejercicio 4 de A10
```

Ese apéndice te hace crear una rama `spike/angular-9`, correr
`ng update @angular/core@9 @angular/cli@9`, medir lo que costó, y **borrar la
rama al terminar** —el ejercicio 7 dice explícitamente que no está terminado
hasta que `git branch` no la muestre—. El tag sobrevive a la rama, y esa es toda
la gracia: el ejercicio 4 te pide "el commit de la foto antes de tocar nada"
para poder comparar, y un tag es esa foto con nombre.

> ⚠️ **Volver a un tag te deja en `detached HEAD`.** Es normal:
> `git checkout fase-05-pacientes` te pone a mirar ese estado sin estar en
> ninguna rama. Si vas a escribir desde ahí, crea una rama primero
> (`git checkout -b intento-2`). Para volver a tu línea principal,
> `git checkout master`.

---

## 🧪 Tags de ejercicios (opcional, pero baratos)

Los tags de fase son obligatorios; los de ejercicio son tuyos. Van en un
namespace aparte para que `git tag -l 'fase-*'` siga siendo un índice limpio de
progreso:

```bash
git tag ej/f08/25     # Fase 8, ejercicio 25
git tag ej/a04/3      # Apéndice A04, ejercicio 3
```

Y entonces `git tag -l 'ej/f08/*'` te lista lo que hiciste de esa fase.

Dos casos donde vale la pena de verdad. El primero, los **ejercicios de
diagnóstico** —al menos un tercio de cada fase te entrega algo roto y te pide
reproducir, localizar y explicar—, que piden dos tags en vez de uno:

```bash
git tag ej/f08/25-roto     # el bug reproducido, antes de tocar nada
git tag ej/f08/25-fix      # el fix aplicado y verificado

git diff ej/f08/25-roto ej/f08/25-fix
```

Ese `diff` es la corrección aislada del ruido, y sigue siendo legible dentro de
seis meses. En este curso además tiene un uso que no es cosmético: buena parte
de los fixes que enseña son de **una línea** —un `takeUntil` que faltaba, una
comparación de fecha sin zona horaria, un `$event.stopPropagation()` de más—, y
esa línea, vista sola en un diff, es exactamente la lección. Enterrada entre los
veinte archivos de la fase, no la vuelves a encontrar. Es también, dicho sea de
paso, el hábito que separa la corrección mínima de la refactorización: si tu
diff tiene cuarenta líneas, no hiciste un hotfix.

El segundo caso son los **ejercicios de medición** —los del dashboard de la Fase
10, el coverage de la Fase 12, el peso del bundle de A04—, donde el número va en
el mensaje del tag y queda pegado al commit que lo produjo:

```bash
git tag -a ej/f10/27 -m "Dashboard con 400 órdenes: 38 recomputaciones del
selector y 240 ms de scripting al filtrar. Con el selector memoizado: 2 y 11 ms.
Medido con el Performance panel, CPU throttling 4x."
```

Después, `git tag -n99 -l 'ej/f10/*'` te devuelve tu cuaderno de mediciones sin
abrir un archivo. Y para el coverage de la Fase 12 vale lo mismo: el número del
día que cerraste la fase, guardado donde no se pierde, es lo que después te deja
decir si subió o bajó sin discutir de memoria.

> ⚠️ **Un cuidado, uno solo.** No crees nunca un tag llamado literalmente
> `ej/f08`. Git guarda los refs como archivos: si existe el archivo
> `refs/tags/ej/f08`, no puede existir además el directorio `refs/tags/ej/f08/`,
> y el `git tag ej/f08/25` falla con un error confuso. Los niveles intermedios
> del namespace se quedan vacíos, siempre.

---

## 🚑 Incidentes: acá el tag sí es contenido

El `cuaderno-incidentes.md` reserva **veintiún IDs** —el paciente que se guardó y
dice que no, el resultado crítico que no alertó el sábado, la muestra con la
custodia imposible— y pide resolverlos con la estructura de post-mortem de ocho
puntos de la guía de estilo (§13): síntoma, repro, evidencia, causa raíz,
corrección, prueba de regresión, prevención, y el análisis sin culpabilización.

Esa estructura tiene una traducción exacta a git, y por eso acá el par de tags
deja de ser opcional. El namespace es **`inc/<ID>/<slug-corto>`**, con el ID que
el cuaderno ya tiene reservado —nunca uno inventado, nunca uno reasignado— y los
dos sufijos de siempre, `-roto` y `-fix`:

```bash
# Puntos 1-3: el síntoma reproducido y la prueba de regresión EN ROJO
git tag -a inc/07/alerta-del-sabado-roto -m "Síntoma: un resultado crítico del
sábado no disparó alerta. Repro: navegador en UTC-5, muestra procesada el
sábado 23:40 hora local. Evidencia: la acción entra al log de DevTools, el
selector devuelve lista vacía, y el spec de regresión falla."

# Puntos 4-6: la causa raíz, el fix, y la misma prueba EN VERDE
git tag -a inc/07/alerta-del-sabado-fix -m "Causa raíz: el selector compara la
fecha con new Date() sin normalizar zona horaria, así que el sábado tarde cae
en el día siguiente. Fix: normalizar a la zona de la aplicación antes de
comparar. Regresión: el spec con TZ fijada pasa."
```

Con eso, `git diff inc/07/alerta-del-sabado-roto inc/07/alerta-del-sabado-fix`
**es** el punto 5 del post-mortem —la corrección, aislada del ruido— y los dos
mensajes de tag son los puntos 1 a 6 escritos donde no se pierden.
`git tag -n99 -l 'inc/*'` te devuelve el cuaderno entero, con causa raíz y fix,
sin abrir un archivo. Esa es la parte transferible: es exactamente lo que vas a
querer tener el día que el incidente no sea de juguete.

> 📝 **Las ramas `incidente/NN` son otra cosa.** El cuaderno reparte el sistema
> roto de tres formas —un flag del inyector de caos, un `db.incidente-NN.json`,
> o una rama— y la tercera **sale del commit donde cerraste la fase que produce
> el incidente**. Ahí es donde tu tag deja de ser un adorno:
>
> ```bash
> git checkout -b incidente/06 fase-04-mock-api-caos
> ```
>
> La rama te lleva al problema; los tags marcan tu recorrido resolviéndolo.
> Conviven sin pisarse.

---

## 🧹 El `db.json` que se ensucia (el truco que más vas a usar)

El mock guarda de verdad. Das de alta pacientes, mueves muestras por la cadena
de custodia, validas resultados —y todo eso se escribe en `db.json`, que está en
la raíz del proyecto y **versionado**, porque es dato del curso y no un
artefacto generado. Después de media hora de ejercicios tu laboratorio es un
campo de batalla y ya no puedes reproducir el caso limpio del enunciado.

Tienes dos formas de volver, y no son la misma:

```bash
git checkout -- db.json     # deshacer lo del último rato, sin tocar nada más
npm run seed                # regenerar los datos completos desde seed.js
```

La primera te devuelve el archivo tal como lo commiteaste, con tus escenarios
adentro. La segunda lo **pisa entero**: la Fase 5 §5.1 lo advierte sin rodeos
—*"el script pisa sin preguntar"*— y ahí se pierde cualquier caso de prueba que
hubieras construido a mano. Commitea antes de sembrar, y esa advertencia se
vuelve inofensiva.

Su corolario es el hábito que más te va a servir: cuando un ejercicio te pida un
dato particular —una orden vencida sin toma, un rango de referencia con dos
versiones que se solapan, una muestra descartada que alguien intenta reactivar—,
cárgalo, **commitéalo como escenario**
(`git commit -m "f08 ej24: escenario de rango v1/v2 solapados"`) y etiquétalo si
vas a volver. Reconstruir a mano un escenario que ya tuviste es el peor uso
posible de tu tiempo. Y los `db.incidente-NN.json` del cuaderno son
exactamente eso mismo, guardados con nombre: viven junto al `db.json`, se
activan copiando, y se versionan igual.

---

## 🐳 Un tag de git y una etiqueta de imagen (Fase 13)

La Fase 13 construye la imagen con `docker build -t lab-frontend .` y esa
etiqueta implícita es `:latest`, que el **Apéndice A09 §3** llama con razón una
trampa doble: no sabes qué build estás corriendo, y cambia la política de
descarga del cluster. En tu máquina el arreglo cuesta un guion:

```bash
docker build -t lab-frontend:fase-13-build-despliegue .
```

La imagen queda etiquetada con el mismo nombre que el tag de git que la produjo,
y con eso puedes contestar la pregunta que ordena el final del curso —*"¿por qué
esta imagen se comportó distinto en UAT y en PROD?"*— empezando por saber **qué
código hay adentro**. Es la mitad barata del diagnóstico, y es la que casi nadie
tiene.

---

## 📈 Los comandos que hacen que esto sirva

```bash
# ¿Dónde estoy?
git tag -l 'fase-*'

# Cuándo cerré cada fase
git for-each-ref --sort=creatordate \
  --format='%(creatordate:short)  %(refname:short)' 'refs/tags/fase-*'

# Qué costó una fase, en archivos y líneas
git diff fase-07-muestras-custodia..fase-08-resultados-rangos --stat

# Volver a un estado sano
git checkout fase-05-pacientes
git checkout -- db.json

# Arrancar un incidente desde la fase que lo produce
git checkout -b incidente/06 fase-04-mock-api-caos

# Los ejercicios de una fase, y el cuaderno de incidentes completo
git tag -n99 -l 'ej/f10/*'
git tag -n99 -l 'inc/*'
```

---

## ✅ Checklist de cierre de fase

- [ ] El checklist de "✅ Qué queda listo al terminar" de la fase, en verde y
      verificado a mano.
- [ ] `git status` limpio: todo lo de la fase está commiteado.
- [ ] `git tag -a fase-NN-slug -m "…"` creado, con el checklist en el mensaje.
      **Este no es opcional:** sin él, las ramas `incidente/NN` de esta fase no
      tienen de dónde salir.
- [ ] Si la fase dejó un incidente resuelto, su par `inc/<ID>/…-roto` /
      `inc/<ID>/…-fix` existe y sus mensajes cuentan síntoma, causa raíz y fix.
- [ ] `db.json` en el estado que quieres heredar a la fase siguiente — o
      restaurado con `git checkout --` si lo dejaste hecho un desastre.

> **La señal de que quedó bien:** "vuelvo después de tres semanas, corro
> `git tag -l 'fase-*'`, y sé exactamente dónde me quedé y qué sigue — sin
> releer una sola línea del curso".

---

## 🔥 El track opcional de backend

Si haces el track BE, todo lo de arriba sigue valiendo con **un namespace aparte**,
para que `git tag -l 'fase-*'` siga siendo el índice limpio del track base:

```
be00-el-contrato-auditoria-del-mock.md   →   be-fase-00-el-contrato-auditoria-del-mock
be03-...                                 →   be-fase-03-...
```

Los commits llevan `beNN: …` y los de ejercicio `beNN ejNN: …`. Los apéndices del
track (`bea-NN-*.md`) **no llevan tag propio**: lo que salga de leerlos se
commitea con el prefijo de la fase desde la que llegaste. Y los incidentes del
track usan `cuaderno-incidentes-be.md`, con IDs `be-01` … `be-12` que no se cruzan
con los del cuaderno base.

Las **ramas** de esos incidentes también llevan namespace propio —`incidente-be/NN`
en vez de `incidente/NN`— y salen del tag `be-fase-*` de la fase que produce el
incidente, con el slug completo. Por eso el tag del track BE es **tan obligatorio
como el del base**, y por la misma razón mecánica:

```bash
git checkout -b incidente-be/05 be-fase-03-la-costura-y-el-reemplazo
```

Los pares de tags conservan la forma del track base con el ID del cuaderno BE
adentro: `inc/be-08/orden-contradice-roto` y `inc/be-08/orden-contradice-fix`.
Así, `git branch --list 'incidente/*'` sigue devolviendo solo las del track base.

### ⚠️ El incidente que no tiene commit

Hay una excepción y conviene conocerla antes de topársela. La fase **be07**
—la subida de versión que nadie decidió— produce un incidente **cuyo `git diff`
está vacío**, porque el cambio que lo causó no está en el árbol de fuentes: está en
una línea del `.env`.

```
# .env — La versión de la base vive AQUÍ, fuera del código fuente.
MONGO_TAG=...
```

Ese incidente **no tiene par `-roto` / `-fix`**, y no es un descuido de la
convención: es su contenido. En un curso construido sobre el `git diff` como
factura de la deuda, tener un incidente cuya causa no aparece en ningún commit es
exactamente la lección — *`git log`, `git blame` y el último despliegue no siempre
tienen la respuesta*.
