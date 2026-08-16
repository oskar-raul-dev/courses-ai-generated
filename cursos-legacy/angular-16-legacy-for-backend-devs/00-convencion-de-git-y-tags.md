# 🏷️ Convención de git: commits y tags de progreso
## Tutorial Angular 16 — Inspecciones y certificaciones

Cómo versionas el código que escribes mientras haces el curso. Es corto a
propósito: no es un proyecto de empresa, no hay releases ni equipo, y una
estrategia de ramas elaborada acá sobraría. Son tres cosas — un repo, commits
con un prefijo, y un tag por fase cerrada. Más tres usos de los tags que en este
curso rinden muchísimo por lo poco que cuestan: los ejercicios, los incidentes y
los puntos de retorno.

> 🔑 **La frase para memorizar:** un tag es un puntero a un commit. No ocupa
> espacio, no agrega overhead y se borra con `git tag -d`. La pregunta no es
> "¿vale la pena etiquetar esto?", es "¿por qué no?".

Nada de esto es nuevo: la **Fase 0 §9** ya fijó la regla del proyecto —*"una
etiqueta por fase"*— y la Fase 1 la usa desde su primer ejercicio. Este documento
es esa regla desarrollada, con lo que hace falta alrededor para que sirva de
verdad.

Y hay tres razones propias de este curso para tomársela en serio. La primera es
que **vas a romper cosas a propósito**: el inyector de caos de la Fase 3 existe
para que la aplicación falle, un tercio de los ejercicios de cada fase te entrega
algo roto, y el cuaderno de incidentes vive de reproducir bugs. Poder volver a un
estado sano sin pensarlo es lo que te da permiso para experimentar.

La segunda es que acá **el código se retira**. La Fase 1 borra el hola mundo
standalone que escribiste en la Fase 0 —no lo recicla, lo borra— y el tag
`fase-00` es el único sitio donde ese código sigue existiendo. El ejercicio 30 de
la Fase 1 lo recupera desde ahí. Si no etiquetaste, ese ejercicio no se puede
hacer.

Y la tercera es la que separa a este track del A: acá **la deuda 💸 se paga**.
Cada deuda declara en qué fase se salda, y la factura se lee con un `git diff`
entre los dos tags. Sin tags, esa comparación —que es medio repaso del curso— hay
que hacerla de memoria.

---

## 📦 Un repo, y el CLI ya lo abrió

No hay `git init` que hacer. El `npx @angular/cli@16.2.12 new certcore …` de la
**Fase 0 §5.2** inicializa el repositorio y deja el commit inicial con el
andamiaje, porque el CLI lo hace salvo que le pases `--skip-git`. Compruébalo
apenas entres a la carpeta:

```bash
cd certcore
git log --oneline     # un commit, el que dejó el CLI
```

Ese repo te acompaña las quince fases y todo lo que el curso construye vive
adentro: la aplicación en `src/`, el mock en `mock/` con su `db.json`, y en la
Fase 13 el `Dockerfile`, el `nginx.conf` y el `entrypoint.sh`. **Un solo repo,
sin excepciones.** El mock es código del curso y no de CertCore, pero comparte
repositorio con él por la misma razón por la que comparte máquina: los dos se
rompen juntos y se diagnostican juntos.

El `.gitignore` que dejó el CLI ya está bien —`/dist`, `/node_modules`,
`/.angular/cache`— y no hace falta tocarlo al principio. Tres cosas sí conviene
comprobar antes de tu primer commit, porque las tres son la diferencia entre un
repo que reproduce el curso y uno que no:

- **`package-lock.json` va adentro.** Es la foto exacta del árbol que produjo el
  binario que estás mirando, y lo que hace que `npm ci` signifique algo. El
  **Apéndice A03** es su dueño.
- **`.nvmrc` va adentro**, con los tres números (`18.18.2`). La Fase 0 §5.1
  explica por qué dos versiones de la misma familia de Node te instalan npm
  distintos, y el incidente **01** del cuaderno es exactamente eso pasando.
- **`mock/db.json` va adentro.** Es dato semilla del curso, no un artefacto
  generado, y de eso vive el truco de la sección 🧹 de más abajo.

Y una que no: si alguna vez sacas el secreto de firma del mock a un archivo
`.env`, ese archivo no entra al repositorio. Un secreto que entra ya no sale,
aunque borres el archivo en el commit siguiente — y da igual que sea de juguete,
porque lo que estás practicando es el reflejo.

No hace falta remoto. Si lo tienes, recuerda que **los tags no viajan solos**:
`git push --tags`.

---

## 💬 Los mensajes de commit

Un prefijo, y ya. El de las fases lo fijó la Fase 0 §9 y se respeta tal cual:
`fase 04:`. Los apéndices usan su código, `a05:`.

```bash
git commit -m "fase 04: InspectionStateService con BehaviorSubject privado"
git commit -m "fase 04: estado derivado con combineLatest y loading en el modelo"
git commit -m "fase 04 ej17: findings$ derivado sin volver a pedir al backend"
git commit -m "a05: FormRecord tipado para los ítems creados en runtime"
git commit -m "fase 07 ej22: render de una inspección v1 con la plantilla vigente"
```

Los ejercicios llevan además su número, `ej17`, y así queda claro qué es
contenido de la fase y qué es práctica tuya. Eso te deja dos búsquedas útiles:

```bash
git log --oneline --grep '^fase 04'        # todo lo de la Fase 4
git log --oneline --grep '^fase 04 ej'     # solo los ejercicios de la Fase 4
```

El mensaje va en español y el código en inglés, igual que en todo el curso: el
commit lo lee el equipo, el identificador que cita sale del código
(`templateVersion`, no `versionDePlantilla`). Commitea seguido y con mensajes
cortos. Nadie va a revisar tu historia, pero tú vas a volver a ella cuando el
formulario dinámico de la Fase 8 te deje el `FormGroup` irreconocible.

> ⚠️ **La excepción son los incidentes.** El cuaderno tiene su propia convención
> de asunto —`incidente(07): repro — …`, con verbos fijos: `abre`, `repro`,
> `hipótesis`, `hipótesis descartada`, `causa`, `fix`, `cierre`— porque ahí el
> `git log` **es** la línea de tiempo de tu investigación. Manda esa, no esta.

---

## 🏷️ Un tag por fase cerrada

**Cuando cierras una fase —con su checklist de "✅ Qué queda listo al terminar"
en verde— haces commit y creas el tag.** Uno por fase, y no hace falta más.

> 🧭 **El tag de fase es obligatorio, y no por disciplina.** Es la única pieza
> de esta convención que otro material del curso da por hecha: las ramas
> `incidente/NN` del cuaderno **salen del commit donde cerraste la fase que
> produce cada incidente**, y lo hacen nombrando el tag —
> `git switch -c incidente/08 fase-07`. Sin tag, ese commit no tiene nombre, y
> preparar el incidente pasa de un comando a bucear en `git log` a ver cuál
> era. **Dieciséis de los veinte incidentes** empiezan así, y los otros cuatro
> siguen necesitando el tag como punto de retorno cuando el diagnóstico te deja
> el sistema peor de lo que estaba. Los tags de ejercicio son tuyos y puedes
> saltártelos; éste no.

El tag se llama **`fase-` + el número de dos dígitos**, no el slug del archivo:
`fase-00`, `fase-07`, `fase-14`. Es la forma que fijó la Fase 0 y que la Fase 1
ya usa en su checklist y en dos ejercicios; cambiarla ahora rompería texto
escrito, y además acá se defiende sola — el número de la fase **es** el nombre
del archivo, así que no hay nada que recordar.

Anotado (`git tag -a`), porque así guarda fecha y mensaje, y la fecha es lo que
después te da la línea de tiempo del curso. El mensaje no se inventa: es el
checklist de la fase, con lo que efectivamente quedó funcionando.

```bash
git tag -a fase-04 -m "F4 cerrada: InspectionStateService con BehaviorSubject
privado y Observable público, estado derivado con combineLatest, loading y error
dentro del modelo, y las suscripciones cerrándose con takeUntilDestroyed.
Tests: todavía no (F12)."
```

Si al escribir el mensaje descubres que un ítem del checklist no está, no está
la fase. El tag es honesto o no sirve para nada.

Los tags van de `fase-00` a `fase-13`, más `fase-14` si haces la fase 🔥
opcional. `git tag -l 'fase-*'` te los devuelve en orden, y eso es tu barra de
progreso.

> ⚠️ **Una rama y un tag no pueden llamarse igual, y acá es fácil que pase.** La
> Fase 0 sugiere trabajar cada fase en su propia rama; si esa rama se llama
> `fase-01` y el tag también, `git checkout fase-01` se vuelve ambiguo y git te
> lo dice con un *"refname 'fase-01' is ambiguous"* que no explica gran cosa.
> Regla del curso, y vale para todo lo demás: **los tags se quedan con el nombre
> limpio y las ramas llevan prefijo** — `wip/fase-01` para tu trabajo en curso,
> `spike/<algo>` para un experimento, `incidente/NN` para el cuaderno.

> 💡 **Los apéndices normalmente no llevan tag propio.** Son consulta rápida: el
> código de Material, de los formularios tipados o del PDF lo escriben las fases,
> y los apéndices explican lo que ya está en el repo. Un tag que no apunta a un
> cambio no marca nada. Si algún apéndice llega a dejar archivos versionados
> —una configuración, un script—, ese commit sí se etiqueta con
> `apendice-aNN`; todo lo demás que salga de leer uno se commitea con el prefijo
> de la fase desde la que llegaste, para que su `git log --grep` siga completo.

### Los puntos de retorno

Los tags de fase ya son tus puntos de retorno: `git checkout fase-04` te devuelve
al sistema tal como estaba antes de que empezaras a experimentar, y
`git checkout fase-00 -- src/` te trae de vuelta un archivo concreto sin mover
nada más — que es justo lo que pide el ejercicio 30 de la Fase 1.

De todos, **`fase-00` es el que más importa**, y no por sentimentalismo: la Fase
1 retira el hola mundo standalone del proyecto, y ese tag es el único sitio donde
sigue existiendo. Ponlo antes de borrar nada.

Los experimentos que el curso te pide —el `SharedModule` sin deuda del ejercicio
28 de la Fase 1, las dos formas de proveer un servicio del 23, cualquier prueba
de la que quieras salir— van en ramas `spike/…` que se borran al terminar. El tag
sobrevive a la rama, así que si el experimento produjo un número, etiquétalo
antes de borrarla:

```bash
git switch -c spike/shared-sin-deuda
# …mides el bundle antes y después…
git tag -a ej/f01/28 -m "SharedModule troceado: bundle inicial <antes> KB →
<después> KB, medido con --stats-json."
git switch -   # de vuelta a tu rama principal
git branch -D spike/shared-sin-deuda
```

> ⚠️ **Volver a un tag te deja en `detached HEAD`.** Es normal:
> `git checkout fase-04` te pone a mirar ese estado sin estar en ninguna rama. Si
> vas a escribir desde ahí, crea una rama primero (`git switch -c wip/intento-2`).
> Para volver a tu línea principal, `git switch main` (o `master`: el CLI no elige
> el nombre, lo hereda de tu configuración de git).

---

## 🧪 Tags de ejercicios (opcional, pero baratos)

Los tags de fase son obligatorios; los de ejercicio son tuyos. Van en un
namespace aparte para que `git tag -l 'fase-*'` siga siendo un índice limpio de
progreso:

```bash
git tag ej/f04/17     # Fase 4, ejercicio 17
git tag ej/a06/3      # Apéndice A06, ejercicio 3
```

Y entonces `git tag -l 'ej/f04/*'` te lista lo que hiciste de esa fase.

Dos casos donde vale la pena de verdad. El primero, los **ejercicios de
diagnóstico** —al menos un tercio de cada fase te entrega algo roto y te pide
reproducir, localizar y explicar—, que piden dos tags en vez de uno:

```bash
git tag ej/f04/25-roto     # el bug reproducido, antes de tocar nada
git tag ej/f04/25-fix      # el fix aplicado y verificado

git diff ej/f04/25-roto ej/f04/25-fix
```

Ese `diff` es la corrección aislada del ruido, y sigue siendo legible dentro de
seis meses. En este curso además tiene un uso que no es cosmético: buena parte de
los fixes que enseña son de **una línea** —un `takeUntilDestroyed` que faltaba, un
`markForCheck()` en el sitio equivocado, una fecha comparada sin offset—, y esa
línea, vista sola en un diff, es exactamente la lección. Enterrada entre los
veinte archivos de la fase, no la vuelves a encontrar. Es también, dicho sea de
paso, el hábito que separa la corrección mínima de la refactorización (guía
§6.7): si tu diff tiene cuarenta líneas, no hiciste un hotfix.

El segundo caso son los **ejercicios de medición** —los de bundle con
`--stats-json` de la Fase 1, los del dashboard de la Fase 11, el coverage de la
Fase 12—, donde el número va en el mensaje del tag y queda pegado al commit que
lo produjo:

```bash
git tag -a ej/f12/26 -m "Coverage al cerrar la fase: <tus cifras> de statements
y de branches. Sin cubrir: el resolver de plantillas y el interceptor de caos."
```

Después, `git tag -n99 -l 'ej/f12/*'` te devuelve tu cuaderno de mediciones sin
abrir un archivo.

> ⚠️ **Un cuidado, uno solo.** No crees nunca un tag llamado literalmente
> `ej/f04`. Git guarda los refs como archivos: si existe el archivo
> `refs/tags/ej/f04`, no puede existir además el directorio `refs/tags/ej/f04/`,
> y el `git tag ej/f04/17` falla con un error confuso. Los niveles intermedios
> del namespace se quedan vacíos, siempre.

---

## 🚑 Incidentes: acá el tag sí es contenido

El cuaderno plantea **veinte incidentes** —la inspección de marzo que hoy se ve
distinta, el certificado emitido sobre una inspección rechazada, el `.nvmrc` que
tu shell no aplicó— y pide resolverlos con la estructura de post-mortem de ocho
puntos de la guía de estilo (§13): síntoma, repro, evidencia, causa raíz,
corrección, prueba de regresión, prevención, y el análisis sin culpabilización.

Esa estructura tiene una traducción exacta a git, y por eso acá el par de tags
deja de ser opcional. El namespace es **`inc/<ID>/<slug-corto>`**, con el ID que
el cuaderno ya tiene reservado —nunca uno inventado, nunca uno reasignado— y los
dos sufijos de siempre, `-roto` y `-fix`:

```bash
# Puntos 1-3: el síntoma reproducido y la prueba de regresión EN ROJO
git tag -a inc/07/version-ejecutada-roto -m "Síntoma: la inspección de marzo se
ve distinta desde ayer. Repro: abrir la inspección 500, ejecutada con
templateVersion 1, después de publicar la v2. Evidencia: el resolver pide la
plantilla vigente y el spec de regresión falla."

# Puntos 4-6: la causa raíz, el fix, y la misma prueba EN VERDE
git tag -a inc/07/version-ejecutada-fix -m "Causa raíz: el resolver lee la
versión vigente del template y no la que la inspección guardó. Fix: resolver por
(templateId, templateVersion) de la inspección. Regresión: el spec que renderiza
una inspección v1 con la v2 publicada pasa."
```

Con eso, `git diff inc/07/version-ejecutada-roto inc/07/version-ejecutada-fix`
**es** el punto 5 del post-mortem —la corrección, aislada del ruido— y los dos
mensajes de tag son los puntos 1 a 6 escritos donde no se pierden.
`git tag -n99 -l 'inc/*'` te devuelve el cuaderno entero, con causa raíz y fix,
sin abrir un archivo. Esa es la parte transferible: es exactamente lo que vas a
querer tener el día que el incidente no sea de juguete.

> 📝 **Las ramas `incidente/NN` son otra cosa.** El cuaderno reparte el sistema
> roto de tres formas —un flag del inyector de caos, un `db.incidente-NN.json`, o
> una rama— y la tercera **sale del commit donde cerraste la fase que produce el
> incidente**. Ahí es donde tu tag deja de ser un adorno:
>
> ```bash
> git switch -c incidente/01 fase-00
> ```
>
> La rama te lleva al problema; los tags marcan tu recorrido resolviéndolo.
> Conviven sin pisarse.

---

## 💸 La deuda que sí se paga (y cómo se lee la factura)

Ésta es la sección que no existiría en el Track A. Allí la deuda se declara y no
se paga; acá **cada 💸 dice en qué fase se salda**, y eso convierte a los tags en
algo más que marcadores de progreso: en los dos extremos de una comparación.

La URL hardcodeada de la Fase 0 se paga en la Fase 13. El `SharedModule` que
reexporta media librería de Material se cobra en la Fase 5 —en parte: sale lo que
no usa nadie, y el resto queda declarado y sin pagar por un motivo que esa fase
explica con el build delante—. Cuando llegues al pago, el diff entre los dos tags
**es** el material del repaso:

```bash
git diff fase-01 fase-05 -- src/app/shared
git diff fase-00 fase-13 -- src/environments src/assets
```

No es una métrica: es la respuesta a *"¿cuánto costó de verdad arreglar esto?"*,
que es la pregunta que te van a hacer la próxima vez que propongas pagar una
deuda en un sistema real. Si quieres encontrarla sin recordar en qué fase fue,
ponle además un tag al commit que la paga:

```bash
git tag -a deuda/shared-module-pagada -m "SharedModule adelgazado: fuera los
módulos de Material que no usa nadie, y el código nuevo importa lo suyo. Bundle
inicial antes: <el número que mediste en la Fase 1>."
```

Y el mismo mecanismo sirve para lo otro que define a este track, la **convivencia
de dos generaciones** 🧬. En CertCore la fecha del código es ficción y vive en
`00-historia-del-sistema.md`; en tu repositorio es real, y `git log -S` te la
cuenta:

```bash
git log --oneline -S "inject(" -- src/app        # cuándo entró el estilo nuevo
git log --oneline -S "NgModule" -- src/app       # dónde sigue vivo el heredado
```

Ese reflejo —preguntarle a la historia del repo de qué época es un archivo antes
de decidir cómo arreglarlo— es transferible tal cual a cualquier sistema que
heredes, y acá lo practicas sobre uno cuya historia escribiste tú.

---

## 🧹 El `db.json` que se ensucia (el truco que más vas a usar)

El mock guarda de verdad. Creas solicitudes, ejecutas inspecciones, emites
certificados —y todo eso se escribe en `mock/db.json`, que está versionado
porque es dato del curso. Después de media hora de ejercicios tu base de pruebas
es un campo de batalla y ya no puedes reproducir el caso limpio del enunciado.

Tienes dos formas de volver, y no son la misma:

```bash
git checkout -- mock/db.json     # deshacer lo del último rato, sin tocar nada más
npm run seed                     # regenerar los datos completos desde el script
```

La primera te devuelve el archivo tal como lo commiteaste, con tus escenarios
adentro. La segunda lo pisa entero, y ahí se pierde cualquier caso de prueba que
hubieras construido a mano.

Su corolario es el hábito que más te va a servir: cuando un ejercicio te pida un
dato particular —una inspección ejecutada con la v1 mientras la v2 ya está
vigente, un hallazgo `critical` bloqueando un certificado, una vigencia que
vence esta noche a las 23:59 con offset—, cárgalo, **commitéalo como escenario**
(`git commit -m "fase 07 ej22: escenario de inspección v1 con v2 vigente"`) y
etiquétalo si vas a volver. Reconstruir a mano un escenario que ya tuviste es el
peor uso posible de tu tiempo. Y los `db.incidente-NN.json` del cuaderno son
exactamente eso mismo, guardados con nombre.

---

## 🐳 Una cosa más, para cuando llegues a la Fase 13

La imagen que construye la Fase 13 se etiqueta por defecto como `:latest`, y el
**Apéndice A09** dedica un apartado a por qué eso te va a morder: con `:latest`
no sabes qué build estás corriendo. En tu máquina el arreglo cuesta un guion —
etiqueta la imagen con el mismo nombre del tag de git que la produjo, y podrás
contestar la pregunta que ordena el final del curso —*"¿por qué esta imagen se
comportó distinto en UAT y en PROD?"*— empezando por saber **qué código hay
adentro**. Es la mitad barata del diagnóstico, y es la que casi nadie tiene.

---

## 📈 Los comandos que hacen que esto sirva

```bash
# ¿Dónde estoy?
git tag -l 'fase-*'

# Cuándo cerré cada fase
git for-each-ref --sort=creatordate \
  --format='%(creatordate:short)  %(refname:short)' 'refs/tags/fase-*'

# Qué costó una fase, en archivos y líneas
git diff fase-03 fase-04 --stat

# Volver a un estado sano
git checkout fase-04
git checkout -- mock/db.json

# Recuperar un archivo de una fase anterior sin moverte de sitio
git checkout fase-00 -- src/

# Arrancar un incidente desde la fase que lo produce
git switch -c incidente/01 fase-00

# Los ejercicios de una fase, y el cuaderno de incidentes completo
git tag -n99 -l 'ej/f12/*'
git tag -n99 -l 'inc/*'
```

---

## ✅ Checklist de cierre de fase

- [ ] El checklist de "✅ Qué queda listo al terminar" de la fase, en verde y
      verificado a mano.
- [ ] `git status` limpio: todo lo de la fase está commiteado.
- [ ] `git tag -a fase-NN -m "…"` creado, con el checklist en el mensaje.
      **Este no es opcional:** sin él, las ramas `incidente/NN` de esta fase no
      tienen de dónde salir.
- [ ] Si la fase pagó una deuda 💸 declarada antes, el `git diff` entre los dos
      tags lo demuestra — y lo miraste.
- [ ] Si la fase dejó un incidente resuelto, su par `inc/<ID>/…-roto` /
      `inc/<ID>/…-fix` existe y sus mensajes cuentan síntoma, causa raíz y fix.
- [ ] `mock/db.json` en el estado que quieres heredar a la fase siguiente — o
      restaurado con `git checkout --` si lo dejaste hecho un desastre.

> **La señal de que quedó bien:** "vuelvo después de tres semanas, corro
> `git tag -l 'fase-*'`, y sé exactamente dónde me quedé y qué sigue — sin releer
> una sola línea del curso".

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
git switch -c incidente-be/05 be-fase-03-...
```

Los pares de tags conservan la forma del track base con el ID del cuaderno BE
adentro: `inc/be-08/status-guardado-roto` e `inc/be-08/status-guardado-fix`. Así,
`git branch --list 'incidente/*'` sigue devolviendo sólo las del track base, igual
que `git tag -l 'fase-*'`.

### ⚠️ El incidente que no tiene commit

Hay una excepción y conviene conocerla antes de topársela. La fase **be04**
—la subida de versión que nadie decidió— produce un incidente **cuyo `git diff`
está vacío**, porque el cambio que lo causó no está en el árbol de fuentes: está en
una línea del `.env`.

```
# .env — La versión de la base vive AQUÍ, fuera del código fuente.
POSTGRES_TAG=...
```

Ese incidente **no tiene par `-roto` / `-fix`**, y no es un descuido de la
convención: es su contenido. En un curso construido sobre el `git diff` como
factura de la deuda, tener un incidente cuya causa no aparece en ningún commit es
exactamente la lección — *`git log`, `git blame` y el último despliegue no siempre
tienen la respuesta*.
