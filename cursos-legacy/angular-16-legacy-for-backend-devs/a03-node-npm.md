# 📎 Apéndice A03 — Node y npm

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **2 horas**
> Usado por: [Fase 0](00-setup-hola-mundo.md), [Fase 3](03-mock-api-caos.md), [Fase 13](13-build-despliegue.md) · Versión cubierta: Node 18.18.2 · npm 9.8.1 · lockfile v3

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve una pregunta que en un equipo de mantenimiento aparece cada dos semanas: **por qué el proyecto se instala distinto en tu máquina que en la del compañero, y cómo se demuestra cuál de las dos está mal.**

Hay una sección que no es sobre CertCore: la §7. Ahí está el procedimiento para comparar el árbol de dependencias de **tu** proyecto heredado —ése que sí tiene un `package.json` de verdad, con siete años de sedimento— contra el del curso. Es el sitio donde este tutorial reconoce que tienes un trabajo fuera de él.

**Qué queda fuera:** monorepos y npm workspaces, pnpm y yarn (se nombran en la §7 y no se comparan), la publicación de paquetes, y el arte de auditar vulnerabilidades más allá de leer un `npm audit`. Nada de eso aparece en CertCore, y meterlo aquí convertiría una página de consulta en un curso de empaquetado.

---

## Índice

- [1. El `.nvmrc` y los tres números](#1-el-nvmrc-y-los-tres-números)
- [2. `npm ci` frente a `npm i`](#2-npm-ci-frente-a-npm-i)
- [3. El lockfile v3, campo por campo](#3-el-lockfile-v3-campo-por-campo)
- [4. `dependencies` y `devDependencies` cuando el entregable son estáticos](#4-dependencies-y-devdependencies-cuando-el-entregable-son-estáticos)
- [5. Peer dependencies en npm 9](#5-peer-dependencies-en-npm-9)
- [6. `npm ls` y `npm outdated`, leídos con criterio](#6-npm-ls-y-npm-outdated-leídos-con-criterio)
- [7. ⭐ Comparar tu proyecto heredado contra el del curso](#7--comparar-tu-proyecto-heredado-contra-el-del-curso)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-7)

---

## 1. El `.nvmrc` y los tres números

La Fase 0 escribe `18.18.2` en el `.nvmrc` y explica por qué son tres números y no dos. Aquí va la parte operativa: qué hace cada herramienta y qué haces cuando la tuya no coopera.

```bash
# El archivo es esto y nada más: una línea, sin `v`, sin comillas.
cat .nvmrc      # 18.18.2

nvm install     # lee .nvmrc, descarga esa versión exacta si no la tienes
nvm use         # la activa EN ESTA TERMINAL, y sólo en ésta
```

La trampa está en la última frase. `nvm use` es por sesión de terminal: abres otra pestaña, vuelves a la versión por defecto de tu sistema, y de repente `npm ci` instala un árbol distinto sin decirte nada. Hay dos maneras honestas de vivir con eso:

- **Automatizarlo.** `zsh` y `bash` admiten un hook que ejecuta `nvm use` al entrar a un directorio con `.nvmrc`. Está documentado en el README de nvm, sección *Deeper Shell Integration*.
- **Verificarlo.** Añadir la comprobación al arranque del proyecto, que es lo que hace el `engines` del `package.json` de la Fase 0 combinado con lo de abajo.

```jsonc
// package.json — la parte que convierte una recomendación en un error
{
  "engines": {
    "node": "18.18.2",
    "npm": "9.8.1"
  }
}
```

```bash
# .npmrc en la raíz del repositorio. Sin esto, `engines` es decorativo:
# npm lo lee, y si no coincide, se encoge de hombros y sigue.
echo "engine-strict=true" > .npmrc
```

Con `engine-strict=true`, un `npm install` desde la versión equivocada de Node falla con `EBADENGINE` en vez de instalarte un árbol silenciosamente distinto. Es una línea, y ahorra la conversación de "a mí me funciona" entera.

> 💡 **En Windows la herramienta es otra.** `nvm-windows` es un proyecto distinto, con la misma idea y sintaxis parecida (`nvm install 18.18.2`, `nvm use 18.18.2`), pero **no lee `.nvmrc`**: el argumento va a mano. Si tu equipo es mixto, el `.nvmrc` sigue valiendo como documentación del número, y el `engines` + `engine-strict` es lo que de verdad hace cumplir la regla en las tres plataformas.

> ⚠️ **Nunca actualices npm por dentro de una versión de Node.** Si `npm -v` te responde `10.x`, la respuesta no es `npm install -g npm@9`: es que estás en la versión de Node equivocada. Cada versión de Node empaqueta su npm, y desparejarlos te deja en una combinación que no tiene nadie más del equipo — el peor sitio donde estar cuando algo falla.

---

## 2. `npm ci` frente a `npm i`

La diferencia se explica en una frase: **`npm i` puede cambiar el lockfile; `npm ci` lo obedece.**

`npm i` (o `npm install`) lee el `package.json`, resuelve los rangos, y si encuentra algo que encaja mejor que lo que dice el lockfile, actualiza el lockfile. Es lo que quieres cuando estás añadiendo una dependencia.

`npm ci` borra `node_modules` entero, lee **sólo** el `package-lock.json` e instala exactamente esos árboles y esas versiones. Si el lockfile y el `package.json` no se pueden reconciliar, falla en vez de arreglarlo por su cuenta. Es lo que quieres en todos los demás casos.

```bash
npm ci          # CI, Docker, tu máquina cuando clonas, y cuando cambias de rama
npm i           # sólo cuando añades o subes una dependencia a propósito
```

En este curso `npm ci` aparece dos veces con papel protagonista: en el `Dockerfile` de la **Fase 13**, donde la reproducibilidad del build es el punto entero, y cada vez que cambias de rama entre incidentes. Un `npm i` en el Dockerfile es un bug latente: la imagen que construyas dentro de tres meses no tendrá el mismo árbol que la de hoy, y la diferencia aparecerá en producción sin que nada en el repositorio haya cambiado.

**Detalles con intención**

- `npm ci` **exige** que exista `package-lock.json`. Si no existe, no lo genera: falla. Eso es una virtud, no una molestia.
- `npm ci` **borra** `node_modules` sin preguntar. Por eso es más lento la primera vez y más rápido que un `rm -rf` manual seguido de `npm i`.
- `npm ci --omit=dev` instala sólo `dependencies`. Para una SPA sirve de poco (§4), pero es el comando que vas a ver en Dockerfiles de backend y conviene reconocerlo.

---

## 3. El lockfile v3, campo por campo

npm 7 estrenó el lockfile v2 y npm 9 usa el **v3**, que es el mismo formato con la sección de compatibilidad hacia atrás retirada. Lo importante: **el lockfile no es un artefacto de build, es código fuente.** Se commitea, se revisa en el pull request, y un cambio inesperado ahí es tan sospechoso como un cambio inesperado en un `.ts`.

```jsonc
// package-lock.json — un paquete, con todo lo que dice de él
{
  "lockfileVersion": 3,
  "packages": {
    "node_modules/rxjs": {
      "version": "7.8.1",
      "resolved": "https://registry.npmjs.org/rxjs/-/rxjs-7.8.1.tgz",
      "integrity": "sha512-…",
      "dependencies": { "tslib": "^2.1.0" }
    }
  }
}
```

- **`version`** — la versión exacta que se instaló. Es la que responde a "¿qué tengo yo?".
- **`resolved`** — de dónde salió el tarball. Si tu empresa tiene un registro interno (Artifactory, Nexus, Verdaccio), aquí aparece su URL, y ése es el campo que te dice si tu compañero y tú estáis bajando de sitios distintos.
- **`integrity`** — el hash del contenido. Si no coincide, npm aborta. Es lo que hace que "la misma versión" signifique de verdad "los mismos bytes".
- **`dependencies`** — lo que ese paquete pide, con su rango sin resolver.

> 🧠 **Por qué un conflicto de merge en el lockfile no se arregla a mano.** Es tentador editar las líneas en rojo y seguir. El resultado casi siempre es un árbol que ninguna resolución de npm habría producido, con un `integrity` que ya no describe nada. La forma correcta es descartar el lockfile del conflicto, quedarse con el `package.json` fusionado, y regenerarlo:
>
> ```bash
> git checkout --theirs package-lock.json   # o --ours; da igual cuál
> npm install                               # regenera desde el package.json fusionado
> git add package-lock.json
> ```

---

## 4. `dependencies` y `devDependencies` cuando el entregable son estáticos

En un backend de Node la distinción tiene consecuencias directas: lo que está en `dependencies` viaja a producción y lo que está en `devDependencies` no. En una SPA **no**, y conviene decirlo claro porque es una de las cosas que peor se traducen desde el backend.

Lo que se despliega de CertCore es la carpeta `dist/`: un puñado de `.js`, `.css` y `.html` que salieron del build. **Ninguna de las dos listas viaja.** El navegador no ejecuta `node_modules`; ejecuta lo que Webpack metió en el bundle. Y lo que Webpack mete en el bundle no lo decide el `package.json`: lo deciden los `import` de tu código.

De ahí salen dos consecuencias que sí importan:

**La distinción sigue valiendo, pero por otra razón.** Sirve como documentación —qué necesita el build y qué necesita la aplicación— y sirve en el `Dockerfile` de la Fase 13, donde la etapa de build instala todo y la etapa final no instala nada porque ya sólo copia `dist/`. Poner `@angular/cli` en `dependencies` no rompe nada; simplemente miente sobre para qué sirve.

**El tamaño del bundle no tiene nada que ver con el tamaño de `node_modules`.** Tus 400 MB de `node_modules` conviven perfectamente con un `main.js` de 500 KB. La pregunta "¿cuánto pesa esta librería?" sólo se responde midiendo el bundle, y eso se hace con `ng build --stats-json`, no leyendo el `package.json`. La **Fase 10** lo mide de verdad con jsPDF, y la **Fase 13** fija los presupuestos del CLI que hacen fallar el build cuando alguien se pasa.

---

## 5. Peer dependencies en npm 9

Una `peerDependency` es un paquete que dice: *"yo funciono con Angular 16, pero no lo instalo yo; instálalo tú y asegúrate de que sea ése."* Todo el ecosistema de Angular funciona así: `@angular/material` declara un peer sobre `@angular/core`, `ng2-charts` sobre `chart.js`, y así.

El comportamiento cambió dos veces y hay que saber en cuál estás:

- **npm 6 y anteriores:** los peers se ignoraban con un warning. Nadie los leía.
- **npm 7 y posteriores** —incluido el **9.8.1** de este curso—: npm intenta instalarlos automáticamente y **falla el install** si hay un conflicto irresoluble. `ERESOLVE unable to resolve dependency tree`.

Ese fallo es una función, no un defecto. Te está diciendo que dos paquetes piden versiones incompatibles del mismo tercero, y que el árbol resultante sería una combinación que nadie ha probado.

> ⚠️ **`--legacy-peer-deps` no arregla nada; apaga la alarma.** Le dice a npm que se comporte como npm 6: ignora los peers y monta el árbol igual. A veces es la respuesta correcta —una librería sin mantenimiento que declara un peer viejo pero funciona— y para saberlo hay que mirar. Lo que no se admite es escribirlo por reflejo en cuanto sale un `ERESOLVE`, ni dejarlo puesto en el `.npmrc` del proyecto, que es cómo un equipo pierde la capacidad de enterarse de nada.

El orden correcto cuando aparece un `ERESOLVE`:

1. **Léelo.** El mensaje dice literalmente qué paquete pide qué y quién no está de acuerdo. Es feo y es exacto.
2. **Comprueba si hay una versión que encaje.** `npm view <paquete> peerDependencies` te dice qué pide cada versión publicada.
3. **Si la incompatibilidad es real y la librería funciona igual**, instala con `--legacy-peer-deps` **en ese comando**, y deja un comentario en el `package.json` o en el PR diciendo por qué. Nunca en el `.npmrc`.
4. **Si no sabes si funciona**, esto no es un problema de npm: es una decisión de proyecto, y se toma con alguien más mirando.

---

## 6. `npm ls` y `npm outdated`, leídos con criterio

```bash
# 👁️ ¿Qué versión de Angular tengo REALMENTE instalada?
npm ls @angular/core
# certcore@0.0.0 /Users/tu/certcore
# └── @angular/core@16.2.12

# 👁️ ¿Quién está pidiendo esta librería, y por qué hay dos copias?
npm ls rxjs --all

# 👁️ ¿Qué está desactualizado, y cuánto?
npm outdated
```

`npm ls <paquete>` es la herramienta de diagnóstico más subestimada del ecosistema. Responde a la pregunta que importa —qué hay en el disco— en vez de a la que responde el `package.json` —qué se pidió—. Cuando un error de Angular no tiene sentido, ése es el primer comando, y la Fase 0 ya te lo hace escribir.

`npm outdated` tiene tres columnas y sólo dos se leen bien:

| Columna | Qué significa | Cómo se lee |
|---|---|---|
| `Current` | lo que hay instalado | la verdad |
| `Wanted` | lo máximo que permite tu rango en `package.json` | en este curso siempre es igual a `Current`: las versiones están fijadas exactas |
| `Latest` | lo último publicado en el registro | información, no una instrucción |

> 🧭 **Regla del proyecto: `Latest` no es un objetivo.** En un sistema en mantenimiento, actualizar tiene un costo y un riesgo, y el beneficio hay que argumentarlo. Este curso está fijado en Angular 16.2.12 y ahí se queda; la conversación de qué costaría ir más allá vive en **A11** 🔥. Un `npm outdated` con veinte líneas en rojo no es una lista de tareas: es una foto del ecosistema moviéndose, que es lo que hace siempre.

---

## 7. ⭐ Comparar tu proyecto heredado contra el del curso

Ésta es la sección que responde a *"pero mi proyecto no es éste"*, y existe para que no haga falta preguntárselo a nadie a mitad de un ejercicio. Ningún ejercicio del curso te va a pedir que abras tu repositorio del trabajo; esto es lo que haces **si quieres**, cuando el curso te haya dado el vocabulario.

El objetivo no es que tu proyecto se parezca a CertCore. Es responder a tres preguntas concretas sobre el tuyo.

**Pregunta 1 — ¿En qué generación de Angular estoy, de verdad?**

```bash
# 👁️ En el repositorio de tu proyecto
npm ls @angular/core typescript rxjs
node -v && npm -v
```

Con esos cinco números ya puedes situarte. Angular 14 o superior significa que los formularios tipados de **A05** te aplican. Angular 15 o superior, que los interceptors funcionales de **A04** existen en tu versión. Angular 16, que `takeUntilDestroyed` está disponible. Por debajo de la 14, el puente conceptual está en **A10**.

**Pregunta 2 — ¿Cuánto de mi árbol está fijado y cuánto está al azar?**

```bash
# 👁️ ¿Cuántas dependencias llevan un rango abierto?
grep -cE '"\^|"~' package.json

# 👁️ ¿Existe lockfile y de qué versión?
grep '"lockfileVersion"' package-lock.json
```

Un proyecto con rangos `^` en todo y sin lockfile commiteado no tiene un árbol: tiene una lotería que se sortea en cada `npm install`. Ése suele ser el primer arreglo con mejor relación beneficio/riesgo de un sistema heredado, y es barato: commitear el lockfile y cambiar el `npm i` del pipeline por `npm ci`.

**Pregunta 3 — ¿Por qué tengo dos copias de la misma librería?**

```bash
# 👁️ Duplicados: la fuente de los bugs más raros del ecosistema
npm ls --all 2>&1 | grep -E 'deduped|invalid' | head -40
```

Dos copias de RxJS en el árbol producen el error más desconcertante que da Angular: un `instanceof` que falla contra una clase que *es* la misma clase, sólo que de otra copia. Si alguna vez ves un `Observable` que no es un `Observable`, es esto.

> 📝 **Sobre pnpm y yarn.** Existen, resuelven problemas reales —sobre todo de espacio en disco y de monorepos— y este curso no los usa ni los compara. Si tu proyecto heredado usa uno de ellos, todo lo de arriba tiene equivalente directo (`pnpm why`, `yarn why`), y la única diferencia conceptual que te va a morder es que **pnpm no aplana `node_modules`**: una librería que funcionaba por accidente porque encontraba una dependencia que nunca declaró, con pnpm deja de funcionar. Eso es correcto y es incómodo el primer día.

---

## 🧭 Cuándo usar qué

| Situación | Comando | Por qué |
|---|---|---|
| Acabas de clonar el repositorio | `npm ci` | instala exactamente el árbol del lockfile, sin sorpresas |
| Cambiaste de rama y algo raro pasa | `npm ci` | el `node_modules` de la otra rama no es el de ésta |
| Añades una dependencia nueva | `npm i <pkg>@<versión exacta>` | y commiteas el lockfile en el mismo commit |
| El Dockerfile de la Fase 13 | `npm ci` | reproducibilidad; un `npm i` ahí es un bug con fecha diferida |
| No entiendes qué versión tienes | `npm ls <pkg>` | responde por el disco, no por el `package.json` |
| Sale `ERESOLVE` | leerlo antes que taparlo | `--legacy-peer-deps` es una decisión, no un reflejo |
| Conflicto de merge en el lockfile | descartar y regenerar | editarlo a mano produce árboles que nadie ha probado |

---

## ⚠️ Advertencias

- **`npm audit fix --force` puede subir versiones mayores.** En un sistema en mantenimiento eso no es una corrección de seguridad: es una migración no planificada disfrazada. `npm audit` para leer, `npm audit fix` sin `--force` para arreglar lo que cabe dentro de los rangos, y cualquier cosa más grande pasa por una decisión.
- **El `node_modules` no se commitea, y el `package-lock.json` sí.** Parece obvio y sigue apareciendo en repositorios heredados de los dos modos equivocados.
- **Borrar `node_modules` no es una técnica de depuración; es un reinicio.** Funciona seguido, y cada vez que funciona te quedas sin saber qué pasaba. Antes de borrarlo, un `npm ls` cuesta cinco segundos y a veces te da la respuesta entera.

---

## 📚 Referencias

- https://docs.npmjs.com/cli/v9 — documentación de npm 9, que es la versión exacta de este curso. Los comandos cambian de comportamiento entre versiones mayores más de lo que la gente supone.
- https://docs.npmjs.com/cli/v9/commands/npm-ci — `npm ci` con todas sus banderas.
- https://docs.npmjs.com/cli/v9/configuring-npm/package-lock-json — el formato del lockfile, incluida la explicación oficial del salto v2 → v3.
- https://docs.npmjs.com/cli/v9/configuring-npm/package-json#engines — `engines`, y su nota sobre `engine-strict`.
- https://github.com/nvm-sh/nvm — nvm para macOS y Linux. La sección *Deeper Shell Integration* es la del `nvm use` automático.
- https://github.com/coreybutler/nvm-windows — nvm-windows. ⚠️ Proyecto distinto, no lee `.nvmrc`.
- https://nodejs.org/en/about/previous-releases — el calendario de soporte de Node. Útil para argumentar una actualización con datos en vez de con ganas.

> ⚠️ Los enlaces de `docs.npmjs.com` redirigen por defecto a la última versión del CLI. Si el comando que estás leyendo se comporta distinto de como lo describe esta página, comprueba que la URL lleve `/v9` — es la diferencia entre leer tu documentación y leer la de otro.

**Orden de lectura sugerido:** la §1 antes de la Fase 0 si `nvm` te es nuevo. La §2 y la §3 cuando llegues al `Dockerfile` de la Fase 13, que es donde `npm ci` deja de ser una recomendación. La §5 sólo cuando te salga un `ERESOLVE`, y entonces entera. La §7 el día que quieras mirar tu propio proyecto con esto puesto — no antes: sin el vocabulario del curso, esa sección es una lista de comandos.

---

## 🧪 Ejercicios (7)

1. 🟢 Cambia a una versión de Node distinta con `nvm use 20` (o la que tengas a mano), ejecuta `npm install` en el proyecto del curso y anota el mensaje exacto. Después añade `engine-strict=true` al `.npmrc` y repítelo. Explica en dos líneas qué cambió y por qué el segundo mensaje es más útil.

2. 🟢 Ejecuta `npm ls @angular/core rxjs typescript` y compara los tres números con la tabla de `alcance-del-proyecto.md` §9. Si alguno no coincide, averigua por qué antes de arreglarlo.

3. 🟡 Borra `node_modules` y `package-lock.json`, ejecuta `npm install`, y haz `git diff package-lock.json`. Anota cuántas líneas cambiaron y si alguna versión se movió. Guarda la cifra en el mensaje de un tag anotado `ej/a03/3` — es el dato que convierte "el lockfile es importante" en una afirmación con número.

4. 🟡 Abre `package-lock.json`, busca la entrada de `rxjs` y localiza sus cuatro campos de la §3. Después cambia a mano el `version` a `7.8.0`, ejecuta `npm ci`, y explica qué pasó y por qué es exactamente lo que quieres que pase.

5. 🟠 Instala una librería que declare un peer incompatible con Angular 16 —`ng2-charts@5` sirve, porque pide Angular 17— y lee el `ERESOLVE` completo. Identifica en el mensaje: qué paquete pide qué, quién no está de acuerdo, y qué versión sí encajaría. No lo instales con `--legacy-peer-deps`: desinstala y escribe en tres líneas qué habrías hecho si esa librería fuera un requisito de negocio.

6. 🟠 Con el proyecto de la Fase 13 construido, compara el peso de `node_modules` (`du -sh node_modules`) con el de `dist/` (`du -sh dist`). Explica la diferencia usando la §4, y di qué comando responde de verdad a "¿cuánto pesa esta librería para el usuario?".

7. 🔴 Toma el `package.json` de un proyecto Angular heredado —el tuyo del trabajo, o cualquiera público de GitHub— y responde por escrito a las tres preguntas de la §7, con los comandos y sus salidas. Cierra con la única recomendación que harías si mañana te asignaran su mantenimiento, y por qué ésa y no otra.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y el código que explica lo escriben las fases, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 00: …`, `fase 13: …`). Las mediciones de los ejercicios 3 y 6 van en el mensaje de un tag anotado (`ej/a03/3`), que es donde un número queda fechado y localizable. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
