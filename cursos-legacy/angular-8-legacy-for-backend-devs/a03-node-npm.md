# 📎 Apéndice A03 — Node y npm

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **2h**
> Usado por: Fases 0, 4, 12, 13 y 14 · Versiones cubiertas: Node **12.22.12** (npm 6.14.16) y **14.21.3** (npm 6.14.18)
> Estado: Base

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve dos preguntas. La primera aparece la primera semana de cualquier equipo:
**por qué el `npm install` de tu compañero produjo otro `node_modules` que el
tuyo**. La segunda aparece el primer día de un proyecto que no escribiste: **en qué
se parece lo que acabas de clonar a lo que aprendiste, y en qué no** (§8).

**Qué queda fuera:** publicar paquetes. Nadie en mantenimiento publica al registro, y `npm publish`, los scopes y las versiones `beta` son un mundo aparte que no te va a tocar. Tampoco entra el gestor de versiones de Node en sí —`nvm` y `nvm-windows` están en la **Fase 0 §5.1**—, ni `node-gyp` con Python y las build tools, que es la ⚠️ de esa misma sección y el **Apéndice A12 §4**, donde está desarrollada para las tres plataformas.

---

## Índice

- [1. Qué versión estás mirando](#1-qué-versión-estás-mirando)
- [2. Tu `package.json` no fija nada](#2-tu-packagejson-no-fija-nada)
- [3. El lockfile](#3-el-lockfile)
- [4. `npm install` vs `npm ci`](#4-npm-install-vs-npm-ci)
- [5. `dependencies` vs `devDependencies`](#5-dependencies-vs-devdependencies)
- [6. `--legacy-peer-deps` y el día que alguien llegue con npm 7](#6---legacy-peer-deps-y-el-día-que-alguien-llegue-con-npm-7)
- [7. Scripts, el `--` y las variables de entorno](#7-scripts-el----y-las-variables-de-entorno)
- [8. Comparar tu proyecto heredado contra este stack](#8-comparar-tu-proyecto-heredado-contra-este-stack)
- [9. Lo que no se comparte y lo que no compila](#9-lo-que-no-se-comparte-y-lo-que-no-compila)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-7)

---

## 1. Qué versión estás mirando

> 🕵️ Los errores de arranque de esta familia —`ERR_OSSL_EVP_UNSUPPORTED` y compañía— aparecen en el índice de síntomas de [`forense-master.md`](forense-master.md) §3, que dice a qué apéndice o fase manda cada uno.

Dos comandos, siempre los mismos, antes de creerle nada a tu `node_modules`:

```bash
node -v && npm -v
```

### 1.1 Las dos líneas del curso, y por qué son dos

El curso fija **dos** combinaciones válidas, y cuál te toca depende de en qué máquina estés:

| Sistema | Node | npm | Por qué esa |
|---|---|---|---|
| Windows 11, Linux amd64 | **12.22.12** | **6.14.16** | Es la de la época del stack. El tooling nativo compila sin pelearse |
| macOS Apple Silicon | **14.21.3** | **6.14.18** | Con la 12 no hay forma. Ver 1.2 |

El proyecto declara la **14 como referencia** y tolera la 12 explícitamente:

```
14.21.3
```

```json
"engines": {
  "node": ">=12.22.12 <15",
  "npm": ">=6.14.0 <7"
}
```

El `.nvmrc` lleva `14.21.3` porque es el mínimo común que funciona en las tres plataformas. El rango de `engines` deja entrar la 12 porque en Windows y Linux sigue siendo perfectamente válida, y cierra la puerta arriba en la 15: de Node 16 en adelante el CLI 8 se rompe con el error de OpenSSL que documenta la **Fase 0 §6**.

> ⚠️ **`engines` no bloquea nada por defecto.** npm 6 lo lee, imprime un *warning* si no coincide y **sigue instalando**. Si quieres que falle de verdad, hace falta un `.npmrc` con `engine-strict=true` en el repo. Está fuera del alcance de este curso, pero es la respuesta a "¿y si un compañero lo ignora?": sí, puede, y no se va a enterar.

### 1.2 macOS Apple Silicon: por qué la 12 no es una opción

**Node no publicó binarios nativos para arm64 en macOS hasta la versión 16.** Ni la 12 ni la 14 tienen uno: las dos corren bajo **Rosetta 2**, traducidas de x64. Ahí termina el parecido, porque lo que cambia es el tooling nativo que hay que compilar:

- Con **Node 12** bajo Rosetta, `node-gyp` y todo lo que dependa de él —`node-sass` a la cabeza— falla al compilar. El mensaje de error habla del compilador, de Python o de un binario que no existe, y no menciona ni Rosetta ni la arquitectura. Es media hora de diagnóstico si no sabes de antemano dónde estás parado.
- Con **Node 14.21.3** el mismo tooling sale adelante. No es elegante y no es nativo, pero compila.

De ahí la regla: **si estás en una Mac con Apple Silicon, tu número es 14.21.3 y no hay conversación.** (Con una nota de calendario, no de hoy: esa regla se apoya en Rosetta, que Apple retira en gran parte a partir de macOS 28. Qué queda entonces —un Node arm64 nativo, o trabajar dentro del contenedor— está en el **Apéndice A13 §2**.) El desarrollo completo de esto —qué se rompe exactamente, qué se puede pinnear y cuándo conviene meterse en un contenedor— vive en los apéndices **A12** (dependencias problemáticas en arm64; su §1 explica el mecanismo detrás de esta regla: bajo Rosetta tu Node es x64 y por eso los binarios de Intel sí existen) y **A13** (Docker + Colima en Apple Silicon).

> 📚 El caso concreto y verificable de todo esto es `node-sass`, y está escrito en el **Apéndice A02 §1.1**: su binario está atado al *module version* de Node, no al número que lees en `node -v`, y el error que da —`Unsupported runtime (83)`— no menciona ni tu Sass ni Angular.

### 1.3 Por qué acá la versión de **npm** importa más que la de Node

Esto es contraintuitivo y es la razón por la que este apéndice empieza con `npm -v` y no con `node -v`.

La versión de Node afecta a **tu** máquina: si compila o no, si arranca o no. Molesta, la ves, la arreglas. La versión de **npm** afecta a **todo el equipo**, porque npm escribe el `package-lock.json` y ese archivo se commitea. Un compañero con npm 7 no solo instala distinto: **reescribe el lockfile en un formato nuevo**, lo sube, y a partir de ahí nadie puede leer un diff. Eso está en §6.

Y el tercer comando, el que se usa más que los dos primeros:

```bash
# Qué versión quedó REALMENTE instalada de un paquete, que no es lo mismo
# que lo que dice package.json. Ver sección 2.
npm ls @angular/core

# El árbol de primer nivel, sin las 1200 dependencias transitivas.
npm ls --depth=0
```

---

## 2. Tu `package.json` no fija nada

Acá empieza la respuesta a la pregunta del apéndice, y no está en el lockfile: está un paso antes.

Si vienes de backend, tu instinto dice que un manifiesto de dependencias declara **coordenadas exactas** —un `groupId:artifactId:version`, un paquete con su número— y que dos personas con el mismo manifiesto obtienen lo mismo. En npm eso es falso por diseño: lo que declaras casi nunca es una versión, es un **rango**.

```json
"dependencies": {
  "@angular/core": "~8.2.14",
  "rxjs": "~6.5.5"
},
"devDependencies": {
  "@angular/cli": "~8.3.29",
  "json-server": "^0.16.3",
  "typescript": "~3.5.3"
}
```

Los tres operadores que vas a ver, y qué permite cada uno:

- **`~8.2.14`** — "el último parche de la 8.2": acepta `8.2.15`, rechaza `8.3.0`. Es lo que usa Angular para sus propios paquetes y para el CLI.
- **`^8.2.14`** — "cualquier cosa que no rompa la 8": acepta `8.3.0` y `8.9.9`, rechaza `9.0.0`. Es el operador por defecto de `npm install`.
- **`8.2.14`** a secas — exacta. Nadie la usa a mano en todos lados, y en §2.2 está el porqué.

> ⚠️ **`^` cambia de significado por debajo de la 1.0.0, y ese es el caso de la mitad de las herramientas de un proyecto de 2019.** En semver, todo lo `0.x` se considera inestable, así que `^0.16.3` **no** acepta la `0.17.0`: se comporta como `~` y solo sube parches. Con `json-server` en `^0.16.3` estás protegido; con `^1.2.3` no. Si asumes que `^` significa siempre lo mismo, un día te llevas una menor entera sin querer.

### 2.1 Y de ahí sale el otro `node_modules`

Con rangos en el manifiesto, dos instalaciones honestas del **mismo** `package.json` en fechas distintas resuelven versiones distintas: la tuya de marzo agarró `8.2.14`, la de tu compañero de agosto agarró `8.2.15`, porque salió entremedio y el rango la acepta. Nadie hizo nada mal. Los dos `node_modules` son legítimos y distintos.

Multiplica eso por las **dependencias transitivas**, que son las que de verdad ocupan el disco: tus treinta paquetes declarados arrastran más de mil, cada uno con **sus** rangos, resueltos el día que instalaste. La superficie de deriva no es tu lista: es el árbol completo.

Para verlo con tus propios ojos, sin instalar nada:

```bash
# Todas las versiones publicadas de un paquete. La última que cabe en tu
# rango es la que te va a tocar en una instalación limpia de hoy.
npm view @angular/core versions --json

# Que hay instalado, que pide package.json y que hay publicado, en tres
# columnas. En un stack de 2019 la última columna es puro ruido: no vas a
# actualizar a Angular 17. Míralo solo dentro de tu propia línea.
npm outdated
```

### 2.2 Por qué no se arregla pinneando todo a mano

La tentación es obvia: quito los `~`, escribo versiones exactas, fin del problema. No funciona, por dos razones. La primera es que **solo controlarías el primer nivel**: las mil dependencias transitivas siguen declarando sus propios rangos y siguen derivando. La segunda es que un `package.json` con cuarenta versiones exactas es un archivo que nadie puede actualizar sin un día de trabajo, y lo que pasa en la práctica es que nadie lo actualiza nunca.

La solución que npm eligió es otra: dejar los rangos en el manifiesto —que expresa **intención**— y congelar el árbol resuelto en un segundo archivo. Ese archivo es la sección 3.

---

## 3. El lockfile

`package-lock.json` es la foto del árbol que se resolvió. No expresa lo que quieres: expresa **lo que hay**, hasta la última dependencia transitiva.

Un fragmento, que es lo único que hace falta leer para entenderlo:

```json
{
  "name": "clinical-lab",
  "version": "0.0.0",
  "lockfileVersion": 1,
  "requires": true,
  "dependencies": {
    "@angular/core": {
      "version": "8.2.14",
      "resolved": "https://registry.npmjs.org/@angular/core/-/core-8.2.14.tgz",
      "integrity": "sha512-yTOjP4h4h/W0pjZ+CVfoZKUuS7...",
      "requires": {
        "tslib": "^1.9.0"
      }
    }
  }
}
```

Las cuatro cosas que guarda cada entrada, y para qué sirve cada una:

- **`version`** — la versión exacta que se resolvió. Es el dato que te importa el 90% de las veces.
- **`resolved`** — de dónde salió el tarball. Es lo que hace que la instalación no tenga que volver a resolver nada.
- **`integrity`** — el hash del paquete descargado. Si el tarball no coincide, la instalación **falla**. Es tu garantía de que nadie cambió el contenido de una versión ya publicada.
- **`requires` / `dependencies`** — el árbol: quién pidió qué y con qué rango.

Y el campo de arriba, `lockfileVersion: 1`, es el que va a causar problemas en §6: **es el formato que escribe npm 6**.

### 3.1 Se commitea. No es negociable

`package-lock.json` va al repositorio, siempre. Es el único artefacto que responde "¿qué había instalado cuando esto funcionaba?", y sin él el `npm ci` de la sección 4 y el `docker build` de la **Fase 13 §5.6** no tienen nada de dónde partir.

El anti-patrón que hay que reconocer: un repo con `package-lock.json` en el `.gitignore`. Casi siempre nació de alguien harto de resolver conflictos en ese archivo, que son feos y frecuentes. El precio de esa comodidad es que el proyecto deja de ser reproducible: **cada máquina y cada build tienen su propia versión del árbol, y "en mi máquina funciona" pasa de chiste a diagnóstico válido.**

### 3.2 Cómo se lee un `git diff` del lockfile sin desesperarse

Un diff de lockfile son cientos o miles de líneas y el 95% es ruido. La técnica es filtrar por la única línea que dice algo:

```bash
# Solo los cambios de versión. Es la señal; todo lo demas es consecuencia.
git diff package-lock.json | grep '"version"'

# El tamaño del cambio, para saber a que te enfrentas antes de abrirlo.
git diff --stat package-lock.json
```

Tres formas del diff, y qué significa cada una:

- **Unas pocas líneas de `version` cambiadas** — alguien actualizó algo, a propósito o no. Legítimo y revisable.
- **Cientos de líneas cambiadas pero ninguna `version`** — reordenamiento o cambio de `resolved`/`integrity`. Suele ser otra versión de npm reescribiendo el archivo a su manera.
- **El archivo entero cambiado, con `lockfileVersion` de 1 a 2** — npm 7 o superior. Esto es §6 y es el caso grave.

> 💡 Cuando un merge deje el lockfile en conflicto, no lo edites a mano nunca. Toma la versión de la rama base, aplica los cambios de `package.json` y regenera: `git checkout --theirs package-lock.json && npm install`. Resolver un lockfile a mano es cómo se produce un árbol que no corresponde a ningún estado real.

---

## 4. `npm install` vs `npm ci`

La diferencia de una línea: **`npm install` obedece a `package.json` y puede reescribir el lockfile; `npm ci` obedece al lockfile y nunca lo toca.**

**`npm install` (o `npm i`):**

Lee `package.json`, lo reconcilia con el lockfile, y si hay un paquete que el lock no cubre o un rango que ya no cuadra, **resuelve e escribe el lockfile**. Instala de forma incremental encima del `node_modules` que ya tengas. Es la herramienta correcta cuando quieres **cambiar** algo: agregar un paquete, subir una versión.

**`npm ci`** (de *clean install*):

Exige que exista `package-lock.json`. **Borra `node_modules` entero** y lo reconstruye desde el lock, versión por versión, sin mirar los rangos de `package.json`. No escribe el lockfile jamás. Y si el manifiesto y el lock se contradicen —agregaste una dependencia y no regeneraste—, **falla en vez de arreglarlo por su cuenta**. Es la herramienta correcta cuando quieres **reproducir** algo.

De ahí sale por qué es más rápido, que es lo que pide el ejercicio 16 de la Fase 0: `npm ci` se salta la fase de resolución completa —ya sabe qué bajar y de dónde— y no tiene que reconciliar nada con lo que había en disco. Lo que pierde es la instalación incremental: siempre baja todo, aunque no haya cambiado nada.

Los cuatro escenarios reales del curso:

- **Agregar Express al proyecto** (Fase 4 §5.2) → `npm install express@4.17.1 --save-dev`. Quieres cambiar el manifiesto y el lock; es exactamente su trabajo.
- **Dentro del Dockerfile** (Fase 13 §5.6) → `npm ci`. Un build tiene que dar el mismo resultado hoy y en seis meses, y un `npm install` ahí podría resolver otra versión y hornearla en la imagen sin que nadie se enterara. Además, al no escribir el lockfile, la capa de Docker se cachea de verdad.
- **Reproducir el bug de un compañero** → `npm ci`, después de un `git checkout` del commit que él tenía. Es la única forma de estar seguro de que estás mirando el mismo árbol.
- **Clonar el repo por primera vez** → `npm ci`. Es más rápido y te deja exactamente lo que el repo declara.

> ⚠️ **El efecto secundario silencioso de `npm install`.** Corres `npm install` sin argumentos, "para instalar lo que falta", y el comando aprovecha para reescribir el lockfile. Después haces `git status` y ahí está, modificado, sin que tú hayas pedido nada. Eso **no** es un archivo que se ignora: o entiendes el cambio y lo commiteas, o lo descartas con `git checkout -- package-lock.json`. Dejarlo a medias es cómo un cambio de versión que nadie decidió llega a `master`.

---

## 5. `dependencies` vs `devDependencies`

Sobre el papel es simple: `dependencies` es lo que la aplicación necesita para funcionar, `devDependencies` lo que solo hace falta para construirla o probarla. En este proyecto, el reparto:

- **`dependencies`** — `@angular/core`, `@angular/common`, `@angular/router`, `@angular/material`, `@angular/cdk`, `rxjs`, `rxjs-compat`, `zone.js`, `@ngrx/store`, `@ngx-translate/core`, `bootstrap`, `jspdf`. Todo lo que aparece en un `import` de `src/`. La excepción es `rxjs-compat`, que **no** se importa desde ningún sitio y aun así vive acá: parchea el prototipo de `Observable` en tiempo de ejecución para que la sintaxis anterior a RxJS 6 siga compilando. Por qué sigue instalado y qué pasa si lo quitas, en el **Apéndice A05 §2**.
- **`devDependencies`** — `@angular/cli`, `@angular-devkit/build-angular`, `typescript`, `karma` y sus plugins, `jasmine-core`, y las tres del mock que fijó la **Fase 4 §5.2**: `express`, `json-server`, `jsonwebtoken`. Nada de esto se importa desde `src/`.

**La regla práctica que resuelve el 99% de las dudas:** ¿el paquete aparece en un `import` de algo que vive en `src/`? → `dependencies`. ¿Solo corre en la terminal, en un `.spec.ts` o en el servidor de mock? → `devDependencies`.

### 5.1 Y ahora la parte donde tu instinto de backend miente

En backend, la frontera es funcional y se cobra en producción: instalas sin las dependencias de desarrollo en el servidor, la imagen adelgaza, la superficie de ataque baja. `--only=production` es higiene básica.

En un frontend compilado eso **no aplica**, y conviene entender por qué antes de "optimizar" un Dockerfile:

**El artefacto de producción es `dist/`, y lo produce una `devDependency`.** El CLI de Angular es una dependencia de desarrollo, así que un `npm ci --only=production` en la etapa 1 de la Fase 13 instala todo lo que no hace falta y deja fuera precisamente lo que sí: el build revienta con un `ng: not found` que no explica nada. Es el ejercicio 4 de este apéndice, y es un error que se comete con la mejor intención.

**Y del otro lado, nada de `node_modules` llega a producción.** La imagen final de la Fase 13 parte de nginx y contiene HTML, JS y CSS: **no tiene `node_modules`, ni Node**. Lo que sí llegó al `dist/` es el código de tus `dependencies` que el bundler decidió incluir, ya minificado y mezclado.

Entonces, ¿la frontera es cosmética? Casi, y ese "casi" importa: **es documentación ejecutable.** Es lo que le dice a quien llegue después qué es herramienta y qué termina en el bundle del usuario. Poner `jspdf` en `devDependencies` no rompe el build —el bundler lo encuentra igual— pero convierte una librería de 200 KB que sí viaja al navegador en algo que parece toolchain. El día que alguien audite el peso del bundle (**Apéndice A04**), esa mentira le va a costar una hora.

---

## 6. `--legacy-peer-deps` y el día que alguien llegue con npm 7

### 6.1 Qué es una peer dependency

Cuando una librería declara una `peerDependency`, está diciendo: *"yo funciono con esta versión de esto, pero no lo instalo yo — instálalo tú"*. Es el mecanismo con el que un plugin declara contra qué anfitrión sirve. En este stack, `@ngrx/store@8.6.0` declara algo del estilo `"@angular/core": "^8.0.0"`, y `@ngx-translate/core@11.0.1` lo mismo. Por eso las versiones del stack no son arbitrarias: son las últimas líneas de cada librería que todavía declaran Angular 8 como *peer*.

### 6.2 El cambio de npm 6 a npm 7, que es el problema de verdad

- **npm 6** (el tuyo): **no instala** las peer dependencies, y si detecta un conflicto imprime un `WARN` y sigue adelante. Vive y deja vivir.
- **npm 7 y superiores**: **instalan** las peers automáticamente y tratan el conflicto como **error**, con un `ERESOLVE unable to resolve dependency tree` que aborta la instalación.

En un stack de 2019 con librerías que ya nadie mantiene, ese cambio significa que **un `npm install` con npm 7+ sobre este repositorio no termina**. Y de ahí viene `--legacy-peer-deps`: el flag que le dice a npm 7+ "compórtate como npm 6 y no valides peers".

```bash
# El parche cuando estas atrapado en un npm moderno y necesitas instalar YA.
npm install --legacy-peer-deps
```

### 6.3 Por qué el flag no es la solución, sino el parche

Funciona, y esa es la trampa. Porque esa persona instaló, sí, pero su npm además **reescribió el lockfile a `lockfileVersion: 2`**, que es el formato de npm 7. El archivo pasa a tener el doble de tamaño y una sección `"packages"` nueva. Cuando lo suba:

- El diff es el archivo entero. Nadie puede revisar qué cambió de verdad.
- Los que están en npm 6 hacen `npm ci` sobre un lock v2. npm 6 lee la parte vieja del archivo, que sigue ahí por compatibilidad, así que **más o menos funciona** — y "más o menos" en un lockfile es la peor de las respuestas.
- El siguiente `npm install` desde npm 6 lo vuelve a reescribir a v1. Y así, con el lockfile cambiando de formato en cada commit según quién lo tocó de último.

**El arreglo de fondo es alinear la versión de npm, no repartir flags.** Si la máquina de alguien está en Node 16+ y no puede bajar, `nvm` resuelve el problema de raíz; y si el problema es solo el npm, se puede fijar sin tocar Node:

```bash
# Bajar npm dentro de la versión de Node que ya tienes.
npm install -g npm@6.14.18
npm -v   # 6.14.18
```

> 🧭 **La regla del equipo:** el `--legacy-peer-deps` se usa para desbloquear una máquina hoy, y se acompaña de `git checkout -- package-lock.json` antes de commitear. Un lockfile v2 en el repositorio es un problema de todos; un flag en la terminal de alguien es un problema de uno.

---

## 7. Scripts, el `--` y las variables de entorno

### 7.1 Por qué `ng` funciona sin instalarlo global

`npm run` ejecuta el script con `node_modules/.bin` añadido al `PATH`. De ahí que un script pueda decir `ng build` aunque no tengas Angular CLI instalado globalmente: el `ng` que corre es el de tu proyecto, el de la versión que declara tu `package.json`.

Es la razón por la que la Fase 0 usa `npx ng serve` y no `ng serve`: `npx` hace lo mismo para un comando suelto que no está en un script. Y es también el diagnóstico de "en mi máquina el CLI es otra versión": si escribes `ng` a secas en la terminal, estás usando el global, que puede ser cualquier cosa.

Los scripts del proyecto, tal como los dejaron las fases:

```json
"scripts": {
  "start": "ng serve",
  "build": "ng build",
  "test": "ng test",
  "mock": "node mock-server/server.js",
  "mock:chaos": "node mock-server/server.js",
  "seed": "node seed.js"
}
```

`start` y `test` son nombres reservados y se invocan sin `run` (`npm start`, `npm test`). Todo lo demás necesita `npm run <nombre>`.

### 7.2 El `--`, que rompe builds y no está explicado en ningún sitio

La Fase 13 §5.6 compila con esta línea, y los dos guiones sueltos del medio no son un adorno:

```bash
npm run build -- --prod
```

En npm, **todo lo que va después de `--` se pasa al script; todo lo que va antes lo interpreta npm**. Sin los guiones, `npm run build --prod` hace que npm se coma el `--prod` como si fuera un flag suyo, no se lo pase a nadie, y `ng build` corra **sin** modo producción. No hay error. El comando termina bien, tarda menos de lo normal, y produces un `dist/` de desarrollo — sin minificar, sin AOT, con los `environment.ts` equivocados.

Ese es exactamente el tipo de fallo que este curso persigue: **salió bien y está mal.** La señal es el tiempo de compilación y el peso del `dist/`; si un build de producción tarda lo mismo que uno de desarrollo, no fue de producción.

### 7.3 Variables de entorno: la línea que no funciona en Windows

La Fase 4 arranca el mock con caos así:

```bash
CHAOS=latency=3000 npm run mock
```

Esa sintaxis —variable delante del comando— es de shells POSIX: `bash`, `zsh`, `sh`. **En `cmd` de Windows no existe**, y el síntoma no es un error claro sino un `'CHAOS' no se reconoce como un comando interno o externo`. En PowerShell tampoco funciona, y ahí el mensaje es distinto y peor.

Los tres equivalentes, y el proyecto **no** tiene `cross-env`, así que estos son los caminos reales:

```bash
# bash / zsh (macOS, Linux, Git Bash en Windows)
CHAOS=latency=3000 npm run mock
```

```cmd
:: cmd de Windows: dos comandos, y la variable queda viva en esa terminal
:: hasta que la cierres. Eso ultimo es la mitad de los "pero yo lo apague":
:: apagaste el mock, no la variable.
set CHAOS=latency=3000
npm run mock
```

```powershell
# PowerShell
$env:CHAOS = "latency=3000"
npm run mock
```

> 💡 En Windows, la salida más limpia es usar **Git Bash** para todo lo que involucre variables de entorno, y dejar `cmd` para lo demás. Si el equipo prefiere una sola sintaxis que funcione en las tres plataformas, la respuesta es agregar `cross-env` a `devDependencies` y escribir `cross-env CHAOS=latency=3000 node mock-server/server.js` dentro del script — una dependencia más, y el ejercicio 17 de la Fase 4 pide resolverlo justamente **sin** ella, porque saber por qué falla vale más que taparlo.

### 7.4 Los hooks que puedes heredar sin saberlo

npm ejecuta automáticamente un script llamado `pre<algo>` antes de `<algo>` y `post<algo>` después. Un `prebuild` corre antes de cada `npm run build`, y un `postinstall` corre **después de cada `npm install` y de cada `npm ci`**, en tu máquina y dentro del Dockerfile.

No hay ninguno en este proyecto, y lo digo porque conviene saber buscarlos: un `postinstall` heredado es la explicación de "el `npm ci` hizo algo raro". Antes de investigar más lejos, `grep` a la sección `scripts` del `package.json` — hay una línea ahí o no la hay.

---

## 8. Comparar tu proyecto heredado contra este stack

Las siete secciones anteriores explican cómo funciona npm. Esta responde la
pregunta que las usa todas juntas, y es la que de verdad te va a tocar el primer
día de un proyecto que no escribiste: **¿en qué se parece lo que acabo de clonar a
lo que aprendí, y en qué no?**

LabCore es un legacy de 2019 y el tuyo probablemente también lo sea, pero no van a
ser el mismo. La diferencia no es un problema: es el inventario con el que empiezas.

### 8.1 El `package.json` de LabCore, comentado

Es el estado al terminar la última fase obligatoria. Los `~` no son decoración:
son la intención con la que se escribió cada línea (§2).

```jsonc
{
  "name": "clinical-lab",
  "version": "0.0.0",
  "engines": {
    // Node 16+ rompe el CLI 8 con el error de OpenSSL de la Fase 0 §6.
    "node": ">=12.22.12 <15",
    // npm 7 trata los conflictos de peers como error y no termina (§6).
    "npm": ">=6.14.0 <7"
  },
  "dependencies": {
    // El núcleo. Los seis suben juntos o no suben: son un solo release.
    "@angular/animations": "~8.2.14",
    "@angular/common": "~8.2.14",
    "@angular/compiler": "~8.2.14",
    "@angular/core": "~8.2.14",
    "@angular/forms": "~8.2.14",
    "@angular/platform-browser": "~8.2.14",
    "@angular/platform-browser-dynamic": "~8.2.14",
    "@angular/router": "~8.2.14",

    // Material y el CDK, siempre en la misma versión (A01 §1).
    "@angular/material": "8.2.3",
    "@angular/cdk": "8.2.3",

    // El store. 8.6.0 es la última de la línea 8 (Fase 1 §5.1).
    "@ngrx/store": "8.6.0",
    "@ngrx/effects": "8.6.0",
    "@ngrx/store-devtools": "8.6.0",

    // i18n en runtime. Las últimas líneas que declaran Angular 8 como peer
    // (Fase 2 §5.1); la 12 de core ya exige Angular 9.
    "@ngx-translate/core": "11.0.1",
    "@ngx-translate/http-loader": "4.0.0",

    // Gráficos. Fíjate en las fechas de estas dos: ng2-charts se actualizó en
    // 2021, ngx-charts se quedó en 2019. Esa distancia es la deuda 💸 de la
    // Fase 10 §5.6 escrita en el manifiesto.
    "ng2-charts": "2.4.3",
    "chart.js": "2.9.4",
    "@swimlane/ngx-charts": "12.1.0",

    // PDF en cliente (Fase 9 · A08). La 2.x cambia el import entero.
    "jspdf": "1.5.3",

    // Estilos. Bootstrap se compila desde Sass, no se consume su CSS (A02).
    "bootstrap": "4.6.2",

    // rxjs-compat NO se importa desde ningún sitio y aun así está: parchea el
    // prototipo de Observable para que la sintaxis anterior a RxJS 6 siga
    // compilando. Es andamiaje de una migración que nadie retiró (A05 §2).
    "rxjs": "~6.5.5",
    "rxjs-compat": "~6.5.5",
    "zone.js": "~0.9.1",
    "core-js": "^2.5.4",
    "tslib": "^1.9.0"
  },
  "devDependencies": {
    // El CLI y su devkit van una mayor por detrás con un cero delante:
    // 0.803.x acompaña al CLI 8.3.x. Si ves un 0.900.x, alguien empezó una
    // migración a Angular 9 y no la terminó (A04 §1).
    "@angular/cli": "~8.3.29",
    "@angular-devkit/build-angular": "~0.803.29",
    "@angular/compiler-cli": "~8.2.14",
    "@angular/language-service": "~8.2.14",
    "typescript": "~3.5.3",

    // Sass. El par node-sass ↔ Node es una tabla que se consulta (A02 §1.1).
    "node-sass": "4.14.1",

    // Testing (Fase 12). Sin lcov: no hay CI.
    "jasmine-core": "~3.4.0",
    "karma": "~4.1.0",
    "karma-chrome-launcher": "~2.2.0",
    "karma-jasmine": "~2.0.1",
    "karma-coverage-istanbul-reporter": "~2.0.1",

    // El mock. Es código de ESTE CURSO, no de LabCore: nace en la Fase 3 y
    // desaparece el día que el proyecto se cierre.
    "express": "4.17.1",
    "json-server": "0.16.3",
    "jsonwebtoken": "8.5.1"
  }
}
```

### 8.2 El diff, en tres comandos

Con el proyecto heredado clonado y las dependencias instaladas:

```bash
# 1. Su árbol de primer nivel. Es la lista que vas a comparar.
npm ls --depth=0

# 2. Su versión de Angular, que es la que ordena todo lo demas.
npm ls @angular/core

# 3. Y la pregunta que decide si puedes leer la documentación del curso:
#    ¿el CLI es de la misma línea que el core?
npx ng version
```

Después, la comparación honesta es contra la lista de §8.1, y solo hay **tres
resultados posibles** para cada línea.

### 8.3 Las tres formas del desajuste

**(a) Misma línea, otro parche** — su `@angular/material` es `8.2.1` y el de aquí
`8.2.3`; su `bootstrap` es `4.3.1` y el de aquí `4.6.2`. **Inocuo casi siempre**, y
la palabra clave es *casi*: entre menores de Bootstrap 4 cambiaron nombres de
variables de Sass, así que un `styles.scss` copiado de este curso puede no
compilar allá. Qué hacer: nada, salvo anotarlo. Todo lo que enseña el curso aplica.

**(b) Otra línea** — su NgRx es la 7, su Angular es la 9, su `@ngx-translate` es la
12. **Aquí hay que leer**, y la herramienta es el changelog de *esa* librería, no
el de Angular. Lo importante es saber qué se te mueve: entre NgRx 7 y 8 aparecen
`createAction` y `createEffect`, así que en la 7 vas a encontrar clases de acción y
el decorador `@Effect()` (A06 §2 y §5). Entre Angular 8 y 9 llega Ivy y desaparece
`entryComponents` (A10). Qué hacer: para cada línea distinta, una ficha como la de
**A10 §6**.

**(c) Un paquete que LabCore no tiene** — o al revés, uno de aquí que allá no está.
Es el caso más interesante y el que más rápido te sitúa. Un `@ngrx/entity` que aquí
no existe significa que su estado no son arrays sino `{ ids, entities }`, y que la
mitad de los selectores que sabes escribir allá se escriben distinto (A06 §9.1). Un
`moment` significa fechas manejadas de otra forma que la Fase 8. Un `lodash`
significa que alguien no quiso pelear con `Array.prototype` y probablemente tenga
razón. Qué hacer: `grep -rl "<paquete>" src/ | wc -l` para saber cuánto pesa en su
código, que es el único dato que importa antes de opinar.

> 🧭 **El orden en que se mira, y no es el orden de la lista.** Primero Angular y el
> CLI, porque deciden qué documentación sirve. Después las tres o cuatro librerías
> que aparecen en más archivos —el `grep -rl` de arriba te lo dice en un minuto—,
> porque son las que vas a tocar. Y el resto, **nunca**: un legacy tiene cuarenta
> dependencias y treinta y cinco no las vas a abrir jamás. Inventariarlas todas es
> la forma más elegante de no empezar.

### 8.4 Lo que NO se compara

Dos cosas, y las dos por la misma razón: no dicen nada.

**El `package-lock.json`.** El suyo tiene mil entradas y el de aquí también, y
ninguna de las dos listas es una decisión de nadie: son el árbol que npm resolvió
un día concreto (§3). Compararlos produce miles de líneas de diff y cero
información. El lockfile se lee para responder *"¿qué había instalado cuando esto
funcionaba?"*, no para comparar proyectos.

**El número de dependencias.** Que su proyecto tenga sesenta y este cuarenta no
significa nada sobre ninguno de los dos. Un `@angular/material` arrastra cientos de
paquetes transitivos y cuenta como uno.

> ⚠️ **Y una advertencia que vale más que toda la sección: no "alinees" su
> proyecto con este.** La tentación aparece rápido —*"acá usamos NgRx 8, subamos el
> suyo"*— y es exactamente el error que **A10 §⚖️** desaconseja: cambiar versiones
> en un sistema que no conoces, sin red de pruebas, para parecerte a un material de
> formación. Este stack es la referencia con la que aprendiste a leer, no el destino
> al que hay que llevar nada.

---

## 9. Lo que no se comparte y lo que no compila

**Un `node_modules` no se comparte entre arquitecturas ni entre sistemas operativos. Nunca.** Es la advertencia central de este apéndice. La carpeta no es solo JavaScript: contiene **binarios compilados** para una combinación concreta de sistema operativo, arquitectura y *module version* de Node. `node-sass` es el caso obvio, pero cualquier paquete que pase por `node-gyp` está igual.

Las tres formas de tropezar con esto, en orden de frecuencia:

- **Copiar la carpeta** de una máquina a otra, o restaurarla de un respaldo, porque "así no espero la instalación". Falla, y el error habla del binario, no de la copia.
- **Montar el proyecto en un contenedor con un *bind mount*** desde el host: tu `node_modules` de macOS aparece dentro de un Linux y nada compila. Por eso la **Fase 13 §5.6** pone `node_modules` en el `.dockerignore` — no es limpieza, es defensa.
- **Cambiar de versión de Node** y seguir con el `node_modules` viejo. Cambió el *module version*; los binarios que había ya no sirven.

En los tres casos la cura es la misma y no tiene atajo: `rm -rf node_modules && npm ci`.

**Docker: usa una imagen basada en Debian, no en Alpine.** Alpine usa `musl` como biblioteca C en vez de `glibc`, y el tooling nativo de Node de esta época —`node-gyp` y todo lo que compila detrás— falla o produce binarios que se comportan distinto. Para un stack de 2019 la variante `-bullseye-slim` es la que da menos guerra; el ahorro de tamaño de Alpine no compensa una tarde de compilación fallida. El ejercicio 🔥 de la Fase 0 que propone armar el ambiente sobre Alpine a mano es útil justamente por eso: se hace para **ver** dónde se rompe.

---

## 🧭 Cuándo usar qué

| Situación | Comando | Por qué |
|---|---|---|
| Clonaste el repo | `npm ci` | Más rápido y te deja exactamente lo que el repo declara |
| Reproducir el árbol de un compañero o de un build | `npm ci` sobre su commit | Es la única forma de estar seguro. Ignora los rangos |
| Dentro de un Dockerfile | `npm ci` | Reproducible en seis meses, y la capa se cachea (**Fase 13 §5.6**) |
| Agregar o subir un paquete | `npm install <pkg>@<version>` | Tiene que escribir el manifiesto y el lock. Es su trabajo |
| "Instalar lo que falta" | `npm ci` | `npm install` funcionaría, pero te reescribe el lockfile de regalo |
| El `node_modules` quedó raro | `rm -rf node_modules && npm ci` | Sin borrar, arrastras lo que había. `npm ci` borra solo |
| Saber qué versión hay instalada | `npm ls <pkg>` | `package.json` dice el rango, no la versión |
| Saber qué resolvería una instalación limpia hoy | `npm view <pkg> versions` | Sin tocar tu `node_modules` |
| Un paquete que se importa desde `src/` | `dependencies` | Viaja al bundle del usuario (§5) |
| Una herramienta, un spec o el mock | `devDependencies` | Solo corre en tu terminal |
| Adelgazar la etapa de build de Docker | **Nada.** No uses `--only=production` | El CLI es una `devDependency`: el build revienta (§5.1) |
| npm 7+ y no puedes bajarlo hoy | `npm install --legacy-peer-deps` | Parche de una máquina. Descarta el lockfile antes de commitear |
| npm 7+ y sí puedes arreglarlo | `npm install -g npm@6.14.18` | Arreglo de raíz. El lockfile deja de cambiar de formato |
| Pasar flags a un script | `npm run build -- --prod` | Sin `--`, npm se los come y el build sale mal y sin avisar |
| Variables de entorno en Windows | `set VAR=...` en línea aparte, o Git Bash | La sintaxis POSIX no existe en `cmd` (§7.3) |

---

## ⚠️ Advertencias

**No borres el `package-lock.json` "para arreglar" nada.** Es el reflejo más común y el más caro: borras el lock, `npm install` resuelve el árbol otra vez desde cero contra el registro de hoy, y el problema que tenías se convierte en un problema distinto con cuarenta versiones nuevas de regalo. Si sospechas del árbol, borra `node_modules` —que se regenera— y no el lockfile, que es el registro histórico.

**`npm install` puede modificar el lockfile sin que se lo pidas.** Después de correrlo, `git status` es obligatorio. Entiendes el cambio y lo commiteas, o lo descartas. Nunca lo dejas ahí.

**`npm audit fix` sobre un stack de 2019 no es una buena idea.** Va a proponerte subir de mayor la mitad del árbol para cerrar vulnerabilidades en dependencias de desarrollo que nunca ven una petición. `npm audit` para **leer** es útil; `--fix` en un proyecto que no vas a migrar es cómo se rompe un build que llevaba tres años compilando. Si hay que atender un aviso real, se atiende ese, a mano, y se anota por qué.

---

## 📚 Referencias

- https://docs.npmjs.com/cli/v6/commands/npm-ci — `npm ci` en la versión que usas, con la lista exacta de en qué se diferencia de `npm install`. ⚠️ `docs.npmjs.com` sirve la versión más reciente por defecto: el `/v6/` de la URL no es opcional.
- https://docs.npmjs.com/cli/v6/configuring-npm/package-lock-json — qué guarda el lockfile y qué significa cada campo del fragmento de §3.
- https://docs.npmjs.com/cli/v6/configuring-npm/package-json — `dependencies`, `devDependencies`, `peerDependencies`, `engines` y `scripts`, todo en una página.
- https://semver.npmjs.com — la calculadora de rangos: pegas `~8.2.14` y te dice exactamente qué versiones publicadas caben. Es la forma más rápida de resolver el ejercicio 2.
- https://semver.org/lang/es/ — la especificación de semver en español, para el caso de `^0.x` de §2.
- https://nodejs.org/en/download/releases — la lista de releases de Node con su fecha y el npm que trae cada una. Es donde se confirma el par Node ↔ npm de §1.1 sin creerle a nadie.
- https://github.com/nodejs/node-gyp#installation — qué hace falta para compilar dependencias nativas en cada sistema. Es el complemento de la ⚠️ de la **Fase 0 §5.1** y la puerta al **Apéndice A12**.
- https://github.com/coreybutler/nvm-windows — el gestor de versiones de Node en Windows, ya citado por la Fase 0.
- https://hub.docker.com/_/node — las variantes de la imagen oficial de Node. La tabla de tags es donde se ve la diferencia entre `-alpine`, `-slim` y `-bullseye-slim` de la sección de advertencias.
- https://blog.npmjs.org/post/626173315965468672/npm-v7-series-beta-release-and-semver-major — el anuncio del cambio de comportamiento de peer dependencies en npm 7. ⚠️ Es una entrada de blog de 2020 y las URLs de `blog.npmjs.org` se han movido más de una vez; si no resuelve, la búsqueda es "npm 7 peer dependencies breaking change".

> ⚠️ Los enlaces y sus contenidos pueden haber cambiado o desaparecido; verifícalos. Con npm el riesgo es específico y conviene repetirlo: la documentación oficial **redirige a la versión actual**, que a estas alturas está ocho mayores por encima de la tuya. Si una página que abriste no lleva `/v6/` en la URL, estás leyendo sobre otro npm.

---

## 🧪 Ejercicios (7)

Cortos y de consulta. Sobre el proyecto del laboratorio, con `node_modules` instalado.

1. Corre `node -v && npm -v` y compara la salida con la tabla de §1.1 y con el `engines` del `package.json`. Después provoca el *warning*: cambia el `engines` a `">=16"`, corre `npm install`, y anota qué imprime npm y si la instalación se completa igual. Revierte.
2. Sin instalar nada, usa la calculadora de semver para responder qué versiones caben en `~8.2.14`, en `^8.2.14` y en `^0.16.3`. Después corre `npm ls @angular/core json-server` y anota qué versiones tienes en realidad. Explica en una línea por qué `^0.16.3` no se comporta como `^8.2.14`.
3. Corre `npm ci` y cronométralo. Después `rm -rf node_modules && npm install` y cronometra otra vez. Anota los dos tiempos, de dónde sale la diferencia, y **si `git status` quedó limpio en los dos casos**. Ese último dato es el más importante de los tres. Cierra el ejercicio 16 de la Fase 0.
4. Corre `npm ci --only=production` y después intenta `npm run build`. Anota el error exacto y explica en dos líneas por qué en un backend ese mismo comando es una buena práctica y acá rompe el build.
5. Compila dos veces: `npm run build --prod` y `npm run build -- --prod`. Compara el tiempo de cada una y el peso total de `dist/`. Anota cuál de las dos hizo lo que tú creías que pedías, y qué señal te habría avisado del error sin mirar el `dist/`.
6. **Diagnóstico.** Un compañero te dice: *"clonaste mal el repo, a mí sí me compila"*. Te enteras de que él está en Node 16 y que el último commit del lockfile es suyo. Sin ver su máquina, escribe: qué comando le pides que corra primero, qué campo del `package-lock.json` mirarías tú antes que nada, y cuál es el arreglo de raíz frente al parche del día. Las tres respuestas están en §6.
7. **El diff que vas a hacer de verdad.** Busca un proyecto Angular de la época que no sea este —uno tuyo de otro trabajo, o cualquiera público de 2019-2021— y aplícale §8: corre los tres comandos de §8.2 y clasifica **solo las cinco librerías que más archivos suyos importan** (`grep -rl` de §8.3) en (a) mismo, (b) otra línea, (c) no está aquí. Anota, para cada una de las cinco, qué apéndice de este curso te serviría igual y cuál dejaría de servirte. Es el ejercicio más transferible del apéndice y el único que se hace fuera de este repositorio.


> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida: el código que
> explica lo escriben las fases, y un tag que no apunta a un cambio no marca
> nada. Lo que salga de leerlo se commitea con el prefijo de la fase desde la
> que llegaste (`f00: …`), para que su `git log --oneline --grep '^f00'`
> siga completo. Y si un ejercicio produjo una medición, el número va en el
> mensaje de un tag anotado (`ej/a03/3`), que es donde no se pierde. La
> convención completa —tags de fase, de ejercicio y de incidente— está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **El `--` de `npm run build -- --prod` produce un build de desarrollo sin avisar** (§7.2). Es un fallo silencioso perfecto —termina bien, tarda menos, el `dist/` está mal— y da para un **incidente** 🟡 de despliegue: "la aplicación va lentísima en UAT y en local va bien". Emparentado con los incidentes 19 y 20 de la Fase 13.
- **`engine-strict=true` en un `.npmrc` del repositorio** — convertiría el *warning* de `engines` en un error y evitaría que alguien instale con la versión equivocada. Es una decisión de proyecto con efecto sobre todo el equipo. Destino: nota en la **Fase 0 §5.1**.
- 🪦 **Corregido al escribir este apéndice.** La Fase 13 §5.6 compilaba sobre `node:14-alpine` y el ejercicio 🔥 de la Fase 0 montaba el ambiente sobre Alpine. Los dos pasaron a **Debian** (`node:14.21.3-bullseye-slim`) por el asunto de `musl`. La etapa 2 de la Fase 13 sigue en `nginx:stable-alpine` a propósito: ahí no se compila nada.
- **`cross-env` no está en el proyecto** y la sintaxis de variables de entorno queda repartida en tres shells (§7.3). Si alguna vez se agrega, hay que tocar los scripts de la Fase 4 y este apéndice a la vez. Destino: decisión de proyecto.
- **Auditoría de peso del bundle** — §5.1 promete que quien mida el bundle va a agradecer que `dependencies` esté bien repartido, y ese análisis no existe todavía. Destino: **Apéndice A04 (Webpack oculto)**.
