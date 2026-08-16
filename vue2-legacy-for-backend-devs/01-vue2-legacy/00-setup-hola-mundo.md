# 🛠️ Fase 0 — Setup + Hola Mundo

## 🎯 Propósito

Dejar un **ambiente legacy funcional** en menos de una hora: Node 14 con NVM,
Vue CLI, las dependencias exactas de la época, el editor configurado (VS Code
**o** WebStorm) y los lineamientos de código que regirán todo el curso. Y
cerrarlo con un **Hello World honesto**: una vista, un formulario, validación
básica y una llamada HTTP a un mock — el ciclo completo de una app real, en
miniatura.

Esta fase no es una guía exhaustiva de Node, npm o webpack (para eso están los
apéndices 🟢📦⚙️). Es el criterio de simplicidad aplicado desde el minuto uno:
ante cualquier duda, aquí gana la opción **más corta, más fácil de ejecutar,
más cercana a un legacy real y suficiente para dejar el ambiente andando**.

> La regla de la fase: primero que corra, después que sea bonito.
> El proyecto que no arranca no enseña nada.

---

## ✅ Qué queda listo al terminar

- NVM instalado y **Node 14.21.3** activo (16.20.2 en macOS Apple Silicon),
  documentado en `.nvmrc`;
- proyecto Vue 2 creado con Vue CLI, con **todas las dependencias del curso**
  instaladas en sus versiones exactas;
- editor configurado (VS Code o WebStorm) con formateo automático al guardar;
- los **lineamientos de código** del curso, acordados y aplicados (código en
  inglés, comentarios y UI en español, Prettier, convenciones de época);
- Bootstrap importado y funcionando;
- un mock HTTP con **Stubby** respondiendo en `:8888`;
- el Hello World completo: vista + formulario + validación + POST + respuesta
  en pantalla.

## 🚫 Qué NO entra todavía

- vue-router y vuex (se instalan en la Fase 1, se usan a partir de ahí);
- estructura completa de carpetas (Fase 1);
- json-server (llega en la Fase 3 — 💸 **Stubby es temporal**: se jubila
  formalmente ahí);
- vuelidate en serio (se **instala hoy**, se usa en la Fase 5 — instalar ahora,
  profundizar después);
- el JavaScript de Bootstrap con jQuery/popper (instalados hoy, dormidos hasta
  la Fase 5);
- testing, webpack a fondo, deploy.

---

## 🧠 Concepto 1: ¿qué es Node y qué pinta en un curso de FRONTEND?

Empecemos por la paradoja: vamos a construir una app que corre **en el
navegador**… y lo primero que instalamos es Node, que corre **en tu máquina**.
¿Por qué?

JavaScript nació dentro del navegador y durante años solo vivió ahí. En 2009
alguien tomó el motor de JavaScript de Chrome (V8) y lo sacó del navegador:
eso es **Node.js** — el mismo lenguaje, pero corriendo en tu computadora como
cualquier programa, con permisos para leer archivos, abrir servidores y hablar
con el sistema operativo (cosas que un navegador, por seguridad, jamás
permite).

**La analogía que ordena todo el curso:**

> 🏭 **Node es el taller. 🛣️ El navegador es la carretera.**
> El coche (tu app) anda por la carretera — pero se fabrica en el taller.

En este proyecto, Node es el taller donde viven:

- las **herramientas** que construyen la app (Vue CLI, el dev server, el
  empaquetador que traduce tus archivos a algo que el navegador entienda);
- los **mocks** que simulan un backend (Stubby hoy, json-server en la F3);
- y **npm**, el gestor de paquetes que viene incluido con Node y que instala
  todo lo anterior.

Ni una línea de tu carpeta `src/` corre en Node — pero sin Node, `src/` no
llega nunca al navegador. Guárdate la analogía: cuando algo falle, la primera
pregunta del diagnóstico siempre será *"¿esto se rompió en el taller (la
terminal) o en la carretera (la consola del navegador)?"*

📖 Las demás piezas del taller — **npm, el `package.json`, el YAML de
configuración, la anatomía de un componente Vue** — no van aquí en teoría:
se explican **dentro de los pasos**, en el momento exacto en que las tengas
frente a los ojos. La idea de esta fase no es que copies y pegues: es que al
final puedas explicar qué hace cada archivo que creaste.

## 🧠 Concepto 2: por qué versiones viejas (y cuáles)

En un laboratorio legacy nos interesa más la **compatibilidad del stack** que
la modernidad: el objetivo es practicar sobre el mismo terreno que vas a
heredar. La tabla completa y oficial vive en el
[plan del curso](0-plan-del-curso.md); el resumen operativo de hoy:

| Herramienta | Versión | Por qué |
|---|---|---|
| Node.js | **14.21.3** | la era del stack; el tooling viejo rompe con Node modernos |
| Node (Apple Silicon) | 16.20.2 | binarios nativos para M1/M2/M3; evita compilaciones fallidas |
| npm | el que trae Node 14 (v6) | no se fija a mano |
| @vue/cli | 3.x (global) | el generador de proyectos de la época |
| **vue** | **2.6.14** | última 2.6: 100% legacy, sin los bugs de la era 2.4 |
| **vue-template-compiler** | **2.6.14** | **SIEMPRE idéntico a vue** — divergen y el build revienta con un error críptico |
| axios | 0.21.1 | el cliente HTTP de la época |
| bootstrap | 4.6.2 | maquetación rápida, omnipresente en legacy |
| jquery / popper.js | 3.6.0 / 1.16.1 | para los componentes JS de Bootstrap (más adelante) |
| lodash | 4.17.21 | utilidades; paga su instalación en las Fases 4 y 7 |
| vuelidate | 0.7.7 | validación; paga en la Fase 5 |
| stubby | última | el mock de HOY (💸 se jubila en la F3) |

---

## 1️⃣ Node con NVM

**NVM** administra varias versiones de Node en la misma máquina —
indispensable cuando convives con proyectos modernos y legacy. El ritual que
usarás toda la vida al abrir un proyecto ajeno: `cat .nvmrc` → `nvm use` →
`node -v`.

¿Por qué no basta con instalar "un" Node y ya? Porque en la vida real de un
equipo de desarrollo los proyectos **no envejecen al mismo ritmo**: hoy
mantienes este legacy con Node 14, mañana entras a un proyecto nuevo que pide
Node 20, y la semana que viene alguien te pide revisar un tercer repo
congelado en Node 12 porque nadie tuvo tiempo de migrarlo. Sin NVM, cambiar
de proyecto significaría desinstalar y reinstalar Node cada vez (o, peor,
"forzar" un proyecto viejo a correr con un Node nuevo y toparte con errores
crípticos de compatibilidad). Con NVM, cada proyecto simplemente declara su
versión en `.nvmrc` y un `nvm use` te deja exactamente en el terreno correcto
en segundos — sin pisar la versión que usan tus otros proyectos ni la de tus
compañeros de equipo, que pueden estar en máquinas distintas con sus propias
combinaciones de versiones activas.

### Windows (nvm-windows)

1. Descarga el instalador: https://github.com/coreybutler/nvm-windows
2. Instala, **cierra y reabre la terminal**, verifica: `nvm version`

```bash
nvm install 14.21.3
nvm use 14.21.3
node -v   # v14.21.3
npm -v    # 6.x
```

⚠️ nvm-windows **no lee `.nvmrc` automáticamente**: el archivo igual se crea
(documenta la versión esperada), pero el `nvm use 14.21.3` es manual. En la
práctica esto significa que, cada vez que abras (o clones) un proyecto en
Windows, tu ritual tiene un paso extra de inspección manual:

1. Abre `.nvmrc` con tu editor (es un archivo de una sola línea, texto
   plano — no hace falta nada especial para leerlo).
2. Copia el número de versión que ves ahí (por ejemplo `14.21.3`).
3. Ejecútalo tú mismo: `nvm use 14.21.3` (o `nvm install 14.21.3` primero, si
   no la tienes instalada).

No hay atajo automático como en Linux/macOS: si el proyecto actualiza su
`.nvmrc` (por ejemplo, sube de versión en una fase futura del curso), en
Windows **te enterarás solo si abres el archivo y lo comparas** con la
versión que tienes activa (`node -v`). Es un buen hábito revisarlo cada vez
que hagas `git pull` en un proyecto ajeno.

### Linux / macOS (nvm-sh)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# cerrar/reabrir terminal, o:
source ~/.bashrc     # (o ~/.zshrc en zsh)
command -v nvm       # debe responder "nvm"

nvm install 14.21.3
nvm use 14.21.3
nvm alias default 14.21.3   # opcional: que sea la versión por defecto
node -v && npm -v
```

### 🍎 macOS Apple Silicon (M1/M2/M3)

Node 14 no tiene binarios nativos ARM: `nvm install 14.21.3` puede intentar
**compilar desde fuente** y fallar con murallas de `gyp ERR!`. La alternativa
oficial del curso:

```bash
nvm install 16.20.2
nvm use 16.20.2
```

Para este taller (Vue 2 + axios + mocks) no hay diferencia funcional relevante.
El proyecto **sigue documentando 14.21.3 en `.nvmrc`** por fidelidad legacy.

### `.nvmrc` — la versión, por escrito

Crea en la raíz del proyecto (cuando exista — paso 2) el archivo `.nvmrc` con
una sola línea:

```
14.21.3
```

En Linux/macOS, entrar a la carpeta y correr `nvm use` (sin argumentos) lee el
archivo solo. Si la versión no está instalada: `nvm install && nvm use`.

---

## 2️⃣ Vue CLI, el proyecto… y la disección del `package.json`

### Crear el proyecto

**Vue CLI** es el generador de proyectos de la época: te entrega un proyecto
Vue con todo el taller (empaquetador, transpilador, dev server) ya armado y
escondido, para que tú solo escribas componentes.

```bash
npm install -g @vue/cli@3
```

Primer comando npm del curso, así que detengámonos un momento en qué es
realmente **npm**: es el gestor de paquetes que viene incluido con Node (lo
instalaste en el paso 1) y resuelve un problema muy concreto — nadie escribe
todo su código desde cero. **npm** te da acceso a un registro público con
cientos de miles de paquetes (librerías, herramientas, frameworks) y un
comando para traerlos a tu proyecto: `npm install <paquete>`. Sin él, cada
`import axios from "axios"` que verás más adelante sería una promesa vacía —
alguien tendría que descargar, ubicar y versionar esa librería a mano.

Cada vez que instalas algo, npm dialoga con dos archivos que vas a ver
nacer y crecer durante todo el curso: **`package.json`** (la lista, escrita a
mano o por npm, de qué depende tu proyecto y con qué versiones — lo
disecamos en detalle un poco más abajo) y **`node_modules/`** (la carpeta
donde efectivamente aterriza el código descargado: el paquete que pediste,
más TODOS los paquetes de los que ese paquete depende, en cascada). Por
ahora basta con la intuición: `package.json` es la **lista de compras**,
`node_modules/` es la **despensa ya llena**. Nunca edites `node_modules/` a
mano ni la subas a git — se regenera por completo con `npm install` a partir
del `package.json` (y, como verás, del `package-lock.json`).

El flag **`-g` (global)** de este primer comando lo instala "en tu máquina"
en vez de "en un proyecto" — necesario aquí porque esta herramienta **crea**
proyectos: la necesitas antes de que exista uno donde instalarla localmente.
Es de las pocas instalaciones globales legítimas del curso (el 📦 A3 explica
por qué casi todo lo demás va local, dentro de cada proyecto).

```bash
vue create mini-jira-legacy
#   → elegir el preset "default (babel, eslint)": suficiente para el curso
cd mini-jira-legacy
```

### 🔬 Disección: el `package.json` que acaba de nacer

Abre el `package.json` que Vue CLI generó. Este archivo es **el documento de
identidad del proyecto** — cuando heredes un legacy, leerlo completo será
siempre tu primer acto. Campo por campo:

```json
{
  "name": "mini-jira-legacy",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "serve": "vue-cli-service serve",
    "build": "vue-cli-service build",
    "lint": "vue-cli-service lint"
  },
  "dependencies": {
    "core-js": "^2.6.5",
    "vue": "^2.6.10"
  },
  "devDependencies": {
    "@vue/cli-plugin-babel": "^3.12.0",
    "@vue/cli-plugin-eslint": "^3.12.0",
    "@vue/cli-service": "^3.12.0",
    "vue-template-compiler": "^2.6.10"
  }
}
```

*(Las versiones exactas pueden variar un poco; la estructura es esta.)*

**`name` y `version`** — identifican el proyecto. La versión sigue el formato
**semver**: `MAYOR.MENOR.PARCHE` (más sobre esto en un minuto).

**`private: true`** — un candado: impide publicar el proyecto por accidente al
registro público de npm. Tu app no es una librería; este candado se queda.

**`scripts`** — los **verbos del proyecto**: alias con nombre para comandos
largos. `npm run serve` ejecuta lo que diga la llave `serve`. Dos ideas clave:

1. **Es documentación ejecutable**: en cualquier legacy, `npm run` (sin
   argumentos) lista los scripts — el menú de cosas que el proyecto sabe hacer.
2. **El truco del PATH**: fíjate que el script dice `vue-cli-service serve`, y
   ese comando **no existe** en tu terminal (pruébalo: `vue-cli-service` a
   secas → *command not found*). Funciona dentro del script porque npm agrega
   temporalmente la carpeta `node_modules/.bin/` — donde viven los ejecutables
   de las dependencias — al PATH. Regla práctica: **los binarios de las
   dependencias se usan vía scripts** (o `npx`), nunca instalándolos globales.

**`dependencies` vs `devDependencies`** — la distinción que confunde a todo
recién llegado, resuelta con UNA pregunta:

> **¿Este código termina viajando al navegador (o la app lo necesita para
> correr)?** Sí → `dependencies`. ¿Es herramienta del taller (build, mock,
> test)? → `devDependencies`.

Con lo que ya hay: `vue` es dependencia (ES la app); `@vue/cli-service` es del
taller; y `vue-template-compiler` es el caso instructivo — compila tus
templates **durante el build**, el navegador nunca lo ve → devDependency,
aunque sin él nada compile.

### 🔬 Disección: qué pasa cuando corres `npm install`

Ahora instala las dependencias del curso, con versiones exactas:

```bash
npm install vue@2.6.14 axios@0.21.1 bootstrap@4.6.2 jquery@3.6.0 popper.js@1.16.1 lodash@4.17.21 vuelidate@0.7.7
npm install --save-dev vue-template-compiler@2.6.14
```

Mientras corre, esto es lo que hace por debajo:

1. **Resuelve el árbol completo**: axios no viene solo — cada paquete declara
   sus propias dependencias, y npm calcula el árbol entero (decenas o cientos
   de paquetes que tú nunca pediste explícitamente).
2. **Descarga todo a `node_modules/`**. Ábrela: pesa decenas de MB y tiene
   cientos de carpetas. Por eso **jamás se versiona** en git (Vue CLI ya la
   puso en `.gitignore`) — es regenerable: con el punto 4, cualquiera la
   reconstruye idéntica.
3. **Anota lo que pediste en `package.json`**: tus dependencias directas, en
   la sección que corresponda según el flag (`--save-dev` → devDependencies).
4. **Fotografía TODO en `package-lock.json`**: cada paquete del árbol —
   incluidos los que no pediste — con su versión exacta y su huella digital.
   Este archivo **SÍ se versiona**: es la garantía de que otra máquina (u otro
   año) instala byte a byte lo mismo. Junto con `.nvmrc`, es la vacuna
   completa contra el "en mi máquina sí funciona".

### 🔬 Y un detalle con colmillo: el `^` que npm escribió sin preguntarte

Abre `package.json` de nuevo. Pediste `vue@2.6.14` exacto… y npm anotó
`"vue": "^2.6.14"`. Ese sombrerito no es decorativo:

| Escrito | npm puede instalar | Léelo como |
|---|---|---|
| `"2.6.14"` | exactamente esa | "esta y punto" |
| `"~2.6.14"` | 2.6.x (parches) | "acepto arreglos" |
| `"^2.6.14"` | 2.x.x (≥ 2.6.14) | "acepto features" — **el default de npm** |

El `^` confía en la promesa de semver ("los cambios menores no rompen nada").
En un proyecto de mantenimiento, esa confianza se administra con cuidado: una
"menor" que rompe existe, y sobre todo, **`vue` y `vue-template-compiler`
deben ser idénticos siempre** — un `^` podría moverlos por separado en
máquinas distintas. Así que edita el `package.json` y quítales el `^` a esos
dos (déjalos en `"2.6.14"` pelado). El resto puede conservar su `^`: ya el
lockfile los clava de todas formas.

**✅ La regla de oro de esta instalación:** `vue` y `vue-template-compiler`
**idénticos, siempre**. Si algún día ves `Vue packages version mismatch`, ya
sabes qué pasó y cómo se arregla.

### Verificación antes de seguir

Crea el `.nvmrc` (paso 1) aquí en la raíz, y luego:

```bash
npm run serve
# → abre http://localhost:8080 : la página de bienvenida de Vue CLI
```

Si eso carga, el taller completo funciona: npm encontró `vue-cli-service` en
`.bin`, este compiló `src/`, levantó un servidor local y te sirvió la app.
`Ctrl+C` para detenerlo y seguimos.

### Estructura mínima de hoy

```
mini-jira-legacy/
  .nvmrc              ← la versión de Node, por escrito
  package.json        ← identidad, verbos y dependencias del proyecto
  package-lock.json   ← la foto exacta del árbol (se versiona)
  node_modules/       ← el árbol descargado (NO se versiona)
  stubby.yml          ← lo creamos en el paso 5
  public/
    index.html        ← el ÚNICO html de la app (lo veremos en el paso 6)
  src/
    main.js           ← el punto de arranque
    App.vue           ← nuestro Hello World reemplaza el de bienvenida
```

Las carpetas `components/`, `views/`, `services/`, `router/`, `store/` llegan
en la Fase 1 — hoy no hacen falta, y crearlas vacías "por si acaso" es
exactamente el reflejo que este curso combate.

**✅ Aclaración importante:** a diferencia de otros frameworks que imponen una
estructura de carpetas ("opinionados" — te obligan a organizar tu código de
una forma específica), Vue **no impone nada**: `src/` podría organizarse de
mil maneras distintas y la app funcionaría igual. La estructura que vas a ir
armando fase a fase en este curso (`components/`, `views/`, `services/`,
`router/`, `store/`…) es **una convención pedagógica**, elegida porque es
clara para aprender y común en proyectos legacy de la época — no "la forma
correcta" de estructurar cualquier proyecto Vue. En tu trabajo real vas a
encontrar (y quizás elegir) organizaciones distintas — por dominio/feature en
vez de por tipo de archivo, por ejemplo. Toma esta estructura como **una
guía razonable para seguir el curso**, no como dogma a replicar en todo
proyecto que toques después.

---

## 3️⃣ El editor: VS Code o WebStorm

Ambos funcionan de maravilla con Vue 2. Configura **uno** (el tuyo) y sigue.

### 🟦 VS Code

**Extensiones** (todas del marketplace):

| Extensión | Para qué |
|---|---|
| **Vetur** (octref.vetur) | soporte de `.vue` para **Vue 2** — ⚠️ NO instalar Volar (es para Vue 3; juntos se pelean) |
| **ESLint** (dbaeumer.vscode-eslint) | linting en vivo |
| **Prettier** (esbenp.prettier-vscode) | formateo |
| **EditorConfig** | respeta el `.editorconfig` del proyecto |
| Path Intellisense | autocompletado de rutas |
| *(navegador)* Vue.js Devtools | inspección de componentes/estado — instálala YA, la usarás desde la Fase 1 |

**Workspaces**: trabajamos con **Workspace settings**, no con tu
configuración global de usuario. La diferencia importa: los settings
globales de VS Code (los tuyos, los que ya tengas acomodados a tu gusto en
otros proyectos) quedan intactos, y este proyecto trae los suyos propios en
un archivo que vive **dentro del repo** — así cualquiera que lo clone hereda
exactamente el mismo comportamiento del editor, sin pisar tus preferencias
personales ni depender de que cada dev configure todo a mano.

**`settings.json`** (workspace: crea `.vscode/settings.json` en el proyecto,
así viaja con el repo):

```json
{
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.tabSize": 2,
  "eslint.validate": ["javascript", "vue"],
  "[vue]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "vetur.validation.template": true,
  "vetur.validation.script": true,
  "vetur.format.enable": false
}
```

*(Vetur valida, Prettier formatea: cada uno a lo suyo — tenerlos a ambos
formateando es la fuente clásica de "guardo y el archivo baila".)*

Este `settings.json` no salió de la nada: son **settings sufridos** — cada
línea existe porque en algún proyecto real alguien perdió tiempo
diagnosticando el problema que esa línea previene (el archivo que "baila" al
guardar, el ESLint que no valida `.vue`, Vetur formateando por su cuenta y
peleándose con Prettier). Cópialos tal cual la primera vez; entenderás el
"por qué" de cada uno la primera vez que lo desactives sin querer y el
síntoma reaparezca.

En la Fase 1 se agrega un `jsconfig.json` para el alias `@` — no hace falta
hoy.

### 🟪 WebStorm (o IntelliJ IDEA Ultimate)

Buena noticia: **casi todo viene de fábrica**. El soporte de Vue, ESLint y
Prettier es nativo; es cuestión de encenderlo:

| Ajuste | Dónde |
|---|---|
| Plugin **Vue.js** | Settings → Plugins (bundled en WebStorm; en IDEA instálalo) — detecta `.vue` solo |
| **Node interpreter** | Settings → Languages & Frameworks → Node.js → apuntar al Node de NVM (`~/.nvm/versions/node/v14.21.3/bin/node`) — si no, la terminal integrada y los run configs usan otro Node 💀 |
| **ESLint** | Settings → … → JavaScript → Code Quality Tools → ESLint → **Automatic configuration** |
| **Prettier** | Settings → … → JavaScript → Prettier → marcar **On save** (y "Run on 'Reformat Code'") con el patrón `{**/*,*}.{js,vue,json,css,md}` |
| Formateo nativo | al activar Prettier on-save, WebStorm cede el formateo — no configures reglas de estilo propias que compitan |

Plugins opcionales que suman: **.env files support** (para el Apéndice A5),
**Rainbow Brackets** (gusto personal), **GitToolBox**.

*(¿Cuál elegir si no tienes preferencia? VS Code: gratis y es lo que verás en
el 90% de los tutoriales de la época. WebStorm: si ya vives en JetBrains por
tu backend, quédate — su refactoring y navegación en proyectos Vue legacy
grandes es superior.)*

---

## 4️⃣ Lineamientos de código del curso

Acordados **hoy**, respetados las 12 fases. En un legacy real esto sería el
`CONTRIBUTING.md` que ojalá alguien hubiera escrito.

### Idioma: la regla de las dos lenguas

| Qué | Idioma | Ejemplo |
|---|---|---|
| **Código**: variables, funciones, componentes, archivos, rutas de API, commits | 🇬🇧 **inglés** | `loadTickets`, `TicketStatusBadge.vue`, `isNameValid` |
| **Comentarios** del código | 🇪🇸 **español** | `// el token se adjunta vía interceptor` |
| **Textos de UI** (labels, botones, mensajes) | 🇪🇸 **español** | `"El nombre es obligatorio."` |

¿Por qué? El código en inglés es el estándar de facto (las APIs, la
documentación y los futuros colegas lo esperan); los comentarios y la UI en
el idioma del equipo/usuario maximizan comprensión. Es la convención más común
en equipos hispanohablantes — y mezclar (`cargarTickets`, `getUsuarios`) es el
olor legacy que NO vamos a producir.

### Convenciones de nombres

- Componentes: **PascalCase y multi-palabra** (`AppHeader.vue`,
  `TicketForm.vue` — nunca `Header.vue`: colisiona con elementos HTML).
- Vistas: sufijo `View` (`TicketsView.vue`) — distingue pantalla de pieza.
- Métodos: verbos (`loadTickets`, `submitLogin`); booleanos con prefijo
  `is/has` (`isNameValid`, `hasChanges`).
- Constantes de módulo: `UPPER_SNAKE` (`MOCK_USER`, `STATUS_COLORS`).

### Sabor de época (deliberado)

- `function () {}` en componentes y `var self = this` para el `this` en
  callbacks — **a propósito**: es lo que vas a leer en bases 2018–2021, y las
  arrow functions en las opciones de un componente Vue son una trampa de
  `this` que conviene conocer desde ya (la F3 lo explica a fondo).
- `var` en el código de ejemplo por fidelidad; `let/const` no están
  prohibidos en tus ejercicios.

### Formateo: Prettier decide, nadie discute

Crea **`.prettierrc`** en la raíz:

```json
{
  "semi": true,
  "singleQuote": false,
  "tabWidth": 2,
  "printWidth": 80,
  "trailingComma": "none",
  "arrowParens": "always"
}
```

Y **`.editorconfig`** (lo respetan ambos editores y hasta el que no tenga
Prettier):

```ini
root = true

[*]
charset = utf-8
indent_style = space
indent_size = 2
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true
```

**✅ El punto de Prettier no es que estas reglas sean las mejores:** es que
**la discusión de estilo muere aquí**. Formateo automático al guardar =
diffs limpios = code reviews sobre lógica y no sobre comas. En un legacy con
cinco manos, es la diferencia entre un repo y un campo de batalla.

### Otras dos que ahorran dolores

- **Un componente por archivo**, el archivo se llama como el componente.
- **Nada de código muerto commiteado**: se borra, no se comenta "por si
  acaso" — para eso existe git.

---

## 5️⃣ El arranque de la app, Bootstrap y el mock Stubby

### 🔬 Disección: `main.js`, el punto de arranque, línea por línea

Antes de tocar nada, entendamos qué hay. Reemplaza `src/main.js` por esto —
pero primero léelo conmigo:

```js
import Vue from "vue";
import App from "./App.vue";
import "bootstrap/dist/css/bootstrap.min.css";

Vue.config.productionTip = false;

new Vue({
  render: function (h) {
    return h(App);
  }
}).$mount("#app");
```

**Línea 1 — `import Vue from "vue"`.** Trae la librería Vue desde
`node_modules`. Nota que dice `"vue"` a secas, sin ruta: cuando un import no
empieza con `./` o `/`, el empaquetador lo busca en `node_modules/` — así es
como el `npm install` de hace un rato se conecta con tu código.

**Línea 2 — `import App from "./App.vue"`.** Trae TU componente raíz. Esta sí
tiene `./`: ruta relativa, archivo tuyo.

**Línea 3 — importar… ¿un CSS desde JavaScript? 🤨** En un navegador puro
esto es ilegal. Funciona porque el taller (webpack, escondido tras Vue CLI) lo
intercepta y convierte en una hoja de estilos real. Es la línea que activa
Bootstrap en toda la app — y una probadita de lo que el Apéndice ⚙️ A5
explica a fondo. Por ahora, quédate con la idea: **en `src/`, `import` no es
"lo que el navegador entiende" sino "lo que el taller sabe traducir"**.

**Línea 5 — apagar el tip de producción.** Cosmético: silencia un aviso de
consola. Lo verás en todo legacy.

**Líneas 7–11 — el montaje.** `new Vue({...})` crea la instancia raíz de la
aplicación; `render: function (h) { return h(App); }` es la forma de época de
decir "mi contenido es el componente App" (la `h` viene de *hyperscript* —
crea elementos; no hace falta más detalle hoy); y `.$mount("#app")` la engancha
al elemento del HTML cuyo id es `app`. ¿Cuál HTML? 👇

### 🔬 Disección: `public/index.html` — la única página de la SPA

Ábrelo. Es sorprendentemente vacío:

```html
<body>
  <div id="app"></div>
  <!-- built files will be auto injected -->
</body>
```

Ahí está el `#app` donde `$mount` engancha todo. Y el comentario dice la otra
mitad: los `<script>` con tu código compilado **los inyecta el taller** al
servir o construir — tú nunca los escribes. Esta es la esencia de una **SPA**
(*Single Page Application*): UNA página HTML casi vacía, y JavaScript
construyendo y cambiando todo lo demás. Cuando en la Fase 1 "naveguemos" entre
vistas, el navegador nunca cargará otra página: Vue intercambiará componentes
dentro de este único `div`.

**✅ Nota de contención sobre Bootstrap:** jQuery y popper quedan instalados
pero **no se importan** — solo hacen falta para los componentes JS de
Bootstrap (modales, dropdowns), que llegan en la Fase 5. Importar lo que no
usas es peso muerto que viaja al navegador.

### El mock: ¿qué es y por qué empezamos con uno?

Nuestra app querrá hablar con un servidor… que no existe. Un **mock** es un
actor que se aprendió un guion: le dices "cuando te pregunten ESTO, responde
ESTO OTRO", y la app puede desarrollarse como si el backend existiera. Es el
pan de cada día del frontend real (el backend "siempre llega tarde").

**Stubby** es, concretamente, un pequeño servidor HTTP que corre en tu
máquina (en Node, por supuesto — otro habitante del taller) y que no sabe
programar nada: solo sabe leer un archivo de configuración (el "guion", en
YAML) donde tú describes pares de *"si me llega esta petición → respondo
esto"*. No hay lógica, no hay base de datos, no hay estado entre peticiones
— cada vez que Stubby responde, responde exactamente lo mismo que declaraste,
sin importar cuántas veces se lo pidas. Eso es justamente su virtud hoy: cero
curva de aprendizaje, cero código, y tu frontend puede probar el ciclo
completo de una petición HTTP (loading → éxito/error → repintar la UI) sin
que exista todavía una sola línea de backend real. La otra cara de la
moneda — que no persiste nada, que no simula un CRUD de verdad — es
justamente la limitación que la Fase 3 va a resolver con json-server (el
ejercicio 25 te la hace sentir en carne propia).

```bash
npm install --save-dev stubby
```

(`--save-dev`: es taller puro — jamás viaja al navegador.)

### 🔬 Mini-curso de YAML en 90 segundos (lo vas a ver en TODOS lados)

El guion de Stubby se escribe en **YAML**, un formato de configuración
omnipresente (Docker, CI, linters…). Cuatro reglas y ya lo lees:

1. **`clave: valor`** — como JSON, sin llaves ni comillas obligatorias.
2. **La indentación ES la sintaxis**: anidar = indentar (2 espacios,
   consistentes). Un espacio de más o de menos **cambia el significado** — el
   error #1 de todo YAML.
3. **`- ` inicia un elemento de lista** (el guion + espacio).
4. **`>` significa "lo que sigue, indentado, es un bloque de texto
   multilínea"**.

### El guion: `stubby.yml`, clave por clave

Crea en la raíz:

```yaml
- request:                        # ← el "-" dice: primer elemento de una LISTA de stubs
    method: POST                  #    condición 1: debe ser un POST...
    url: /api/hello               #    condición 2: ...a esta ruta exacta
  response:                       # ← si el request calza, responde así:
    status: 200                   #    código HTTP de éxito
    headers:
      content-type: application/json   # sin esto, axios no sabría que es JSON
    latency: 400                  #    espera 400 ms antes de responder (red simulada)
    body: >                       #    el cuerpo: bloque multilínea ↓
      {
        "message": "Hola desde el mock 👋"
      }
```

Léelo completo en voz alta: *"tengo una lista de stubs; el primero dice: si
llega un POST a /api/hello, espera 400 ms y devuelve 200 con este JSON"*. Eso
es todo el archivo. ¿Quieres otro endpoint? Otro `- request:` debajo — otro
elemento de la lista (ejercicio 6).

¿Por qué la `latency: 400`? Para que el Hello World se sienta como una app
real y no como un espejismo instantáneo: sin latencia, jamás verías el estado
"Enviando…" ni entenderías para qué existe.

### El script `mock`: los verbos crecen

Agrega el script al `package.json`:

```json
{
  "scripts": {
    "serve": "vue-cli-service serve",
    "build": "vue-cli-service build",
    "mock": "stubby -d stubby.yml -s 8888"
  }
}
```

Ya sabes leerlo con lo del paso 2: `stubby` no existe en tu terminal, pero
dentro del script npm lo encuentra en `node_modules/.bin/`. Los flags:
**`-d`** = el archivo de datos (el guion), **`-s`** = el puerto donde
responderá los stubs (8888, para no chocar con el 8080 del dev server).

**✅ Deuda declarada 💸:** Stubby es perfecto para HOY (un endpoint, cero
config) e insuficiente para el proyecto (no persiste, no hace CRUD — el
ejercicio 25 te lo hace comprobar en carne propia). **Se jubila formalmente
en la Fase 3**, cuando json-server tome el puerto 3000 como Mock API oficial.
Lo usamos igual porque así se ve la progresión: mock simple → mock con
estado → backend real.

---

## 6️⃣ El Hello World

### 🔬 Disección previa: ¿qué es un archivo `.vue`?

Un `.vue` es un **Single File Component (SFC)**: un pedazo de pantalla con su
HTML, su lógica y (opcionalmente) su estilo, **en un solo archivo**, dividido
en tres bloques:

```vue
<template>  <!-- el HTML del componente, con superpoderes (directivas) -->
<script>    <!-- la lógica: exporta un OBJETO que describe el componente -->
<style>     <!-- CSS opcional; hoy no lo usamos: Bootstrap trabaja por nosotros -->
```

El navegador no entiende este formato — el taller lo compila (ahí trabaja el
`vue-template-compiler` que emparejamos con tanto celo). Toda la app del curso
será una composición de estos archivos.

**Una intuición informal que te va a acompañar todo el curso:** cuando creas
`App.vue` y lo montas con `h(App)` en `main.js`, en la práctica estás
definiendo, de forma no oficial, un **nuevo "tag" HTML** — algo así como
`<App>` — que a partir de ahora puedes usar como si fuera cualquier otro
elemento (`<div>`, `<p>`, `<form>`), pero que en vez de venir del navegador lo
escribiste tú. Ese "tag" empaqueta HTML, lógica y (opcionalmente) estilo en
**un solo bloque autocontenido** — un **todo** con una sola responsabilidad
(mostrar el saludo, el formulario y el resultado) que puede usarse, moverse o
reemplazarse sin tener que entender el resto de la app. Hoy tu app entera es
UN solo componente (`App.vue`), así que esta idea todavía no se nota mucho —
pero en la Fase 1, cuando aparezcan `AppHeader.vue`, `TicketForm.vue`, etc.,
vas a ver literalmente `<AppHeader />` y `<TicketForm />` escritos dentro de
otro `<template>`, exactamente como si fueran tags nativos del HTML. Ese es
el superpoder central de un framework de componentes: **extender el
vocabulario del HTML con tus propias piezas**, cada una un "todo" cerrado y
reutilizable.

### Las cuatro ideas de Vue que el Hello World usa

**1. El estado vive en `data` — y es una FUNCIÓN.** El objeto que devuelve
`data()` es el estado del componente: lo que puede cambiar. ¿Por qué función y
no objeto directo? Porque un componente puede usarse muchas veces (piensa en
las filas de una tabla), y **cada instancia necesita SU copia del estado** —
la función fabrica una copia nueva por instancia. Un objeto compartido haría
que escribir en una fila escribiera en todas. Es de las primeras preguntas de
toda entrevista de Vue; ya la tienes.

**2. Reactividad: cambias el dato, Vue repinta.** No hay
`document.getElementById(...).innerText = ...` en ninguna parte del curso.
Escribes en el estado (`this.name = "Ana"`) y todo lo que dependa de él en el
template se actualiza solo. Este contrato — **tú tocas datos, Vue toca el
DOM** — es EL cambio mental respecto al jQuery de la época anterior.

**3. Las directivas: HTML con superpoderes.** Los atributos que empiezan con
`v-`, `:` o `@`. Las de hoy, en versión "léelo así":

| Directiva | Léela así |
|---|---|
| `{{ greeting }}` | "pinta aquí el valor de greeting (y repinta si cambia)" |
| `v-model="name"` | "este input y el dato `name` son espejos: uno cambia, el otro también" |
| `@submit.prevent="submit"` | "cuando el form emita submit, cancela la recarga clásica y llama mi método" |
| `:class="{ 'is-invalid': cond }"` | "agrega la clase is-invalid solo cuando la condición sea verdadera" |
| `v-if="response"` | "este elemento existe solo si response tiene algo" |
| `:disabled="loading"` | "el atributo disabled sigue al valor de loading" |

**4. `computed`: valores que se derivan solos.** `isNameValid` no se asigna
nunca — se **calcula** a partir de `name`, y Vue lo recalcula automáticamente
cuando `name` cambia. Estado crudo en `data`, derivados en `computed`: esta
división será un mantra del curso (la F4 la explota a fondo).

Con esas cuatro ideas, el código de abajo se lee solo. Reemplaza el contenido
de **`src/App.vue`**:

```vue
<template>
  <div class="container mt-5">
    <div class="row justify-content-center">
      <div class="col-md-6">
        <div class="card shadow-sm">
          <div class="card-body">
            <h1 class="h3 mb-3">{{ greeting }}</h1>

            <form @submit.prevent="submit" novalidate>
              <div class="form-group">
                <label for="name">Nombre</label>
                <input
                  id="name"
                  v-model.trim="name"
                  type="text"
                  class="form-control"
                  :class="{ 'is-invalid': submitted && !isNameValid }"
                  placeholder="Escribe tu nombre"
                />
                <div class="invalid-feedback">El nombre es obligatorio.</div>
              </div>

              <button class="btn btn-primary" type="submit" :disabled="loading">
                {{ loading ? "Enviando..." : "Enviar" }}
              </button>
            </form>

            <p v-if="response" class="alert alert-success mt-3 mb-0">
              {{ response }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "App",
  data: function () {
    return {
      greeting: "Hola mundo legacy",
      name: "",
      response: "",
      submitted: false,
      loading: false
    };
  },
  computed: {
    // derivado del estado: se recalcula solo cuando cambia name
    isNameValid: function () {
      return this.name.length > 0;
    }
  },
  methods: {
    submit: function () {
      // guardamos this: dentro del .then, this ya no es el componente
      var self = this;
      this.submitted = true;

      if (!this.isNameValid) {
        return; // la clase is-invalid ya pinta el error sola
      }

      this.loading = true;
      this.response = "";

      axios
        .post("http://localhost:8888/api/hello", { name: this.name })
        .then(function (res) {
          self.response = res.data.message + " " + self.name;
        })
        .catch(function () {
          self.response = "";
          window.alert("¿Está corriendo el mock? (npm run mock)");
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};
</script>
```

**🔎 Qué hace, pieza por pieza** (versión aperitivo — cada una tiene su fase):

| Pieza | Su trabajo | Se profundiza en |
|---|---|---|
| `data` | el estado reactivo: cambia y el HTML se repinta solo | F3 |
| `v-model.trim` | enlaza el input con `name` en ambas direcciones, recortando espacios | F5 |
| `computed isNameValid` | validación derivada del estado, con caché | F4 |
| `@submit.prevent` | intercepta el submit nativo y evita la recarga de página | F5 |
| `:class` condicional | prende `is-invalid` (y con ella el mensaje de Bootstrap) solo tras intentar enviar | F4/F5 |
| `axios.post → then/catch/finally` | el ciclo HTTP completo con estados de carga y error | F3 |
| `var self = this` | el truco de época para conservar el componente dentro de callbacks | F3 |

**✅ Buenas prácticas aplicadas (sí, desde el Hello World):**
- El error **no se muestra antes de tiempo**: `submitted && !isNameValid` —
  un formulario en rojo antes de que escribas una letra es hostil (la F5 lo
  eleva a sistema con vuelidate).
- El botón se **deshabilita durante el request** y dice "Enviando..." — la
  vacuna contra el doble submit, instalada desde el día cero.
- `import axios from "axios"` (no `var axios = require("axios")` que verás en
  legacy viejo): en `src/` mandan los ES Modules; el `require` vive en el
  mundo Node (Apéndice A2 explica los dos idiomas).
- El `catch` dice algo **útil** ("¿está corriendo el mock?") en vez de
  tragarse el error — el mensaje de error que diagnostica es marca de la casa.
- ⚠️ Confesión de Hello World: axios importado **directo en el componente** y
  URL hardcodeada son pecados que la Fase 3 absuelve con la capa de servicios.
  Hoy, en un solo archivo, se permiten — y ahora sabes que son temporales.

### Arrancar todo (dos terminales)

```bash
# Terminal 1
npm run mock

# Terminal 2
npm run serve
```

Abre `http://localhost:8080`, escribe tu nombre, envía →
**"Hola desde el mock 👋 TuNombre"** en verde. 🎉

---

## 🔄 El flujo del Hello World, paso a paso

El primer "evento por evento" del curso — guárdalo: es el esqueleto de todo lo
que viene.

```
1. escribes en el input
   └─ cada tecla: evento nativo "input" → v-model.trim actualiza name
      └─ isNameValid (computed) se recalcula solo — nadie lo llamó

2. clic en "Enviar" con el campo VACÍO
   └─ el <form> emite "submit" → .prevent cancela la recarga clásica
   └─ submitted = true → la condición del :class se vuelve verdadera
      → is-invalid pinta el borde rojo Y hace visible el invalid-feedback
   └─ return: no hubo HTTP. La validación más barata es la que evita el viaje.

3. clic con nombre válido
   └─ loading = true → el botón se apaga y cambia su texto (reactividad pura)
   └─ axios.post arma el request → viaja a :8888 → Stubby espera 400 ms (latency)

4a. ÉXITO → .then: response = mensaje + nombre → el v-if lo revela en verde
4b. MOCK APAGADO → .catch: alerta con diagnóstico accionable
5.  SIEMPRE → .finally: loading = false → botón vivo de nuevo
```

Si este flujo te quedó claro, ya entendiste el 60% del patrón que las Fases
3, 4 y 5 van a industrializar. Si no — perfecto también: para eso existen.

---

## ⚠️ Errores comunes

- `vue` y `vue-template-compiler` en versiones distintas → error críptico al
  compilar (`Vue packages version mismatch`): iguálalos y reinstala;
- Node equivocado (¿corriste `nvm use`?) → murallas de `gyp ERR!` al instalar
  o comportamientos raros del tooling;
- probar el formulario **sin levantar el mock** y culpar al código — por eso
  el catch pregunta por él;
- instalar Volar en VS Code "porque es el de Vue" → es el de Vue **3**; con
  Vetur se sabotean mutuamente;
- Prettier y el formateador del editor/Vetur compitiendo → el archivo "baila"
  al guardar: un solo formateador por tipo de archivo;
- en WebStorm, olvidar apuntar el Node interpreter al de NVM → la terminal
  integrada usa otro Node y "en mi IDE no funciona";
- crear carpetas/estructura "para después" → hoy solo `main.js` y `App.vue`;
- puerto 8888 ocupado (`EADDRINUSE`) → un Stubby zombie de otra terminal.

---

## 🧪 Ejercicios (26)

**🟢 Fácil (1–8)**

1. Cambia el saludo por uno con tu nombre y un emoji, y verifica el
   hot-reload: guarda y mira el navegador sin refrescar.
2. Agrega un campo `email` con la misma validación de "obligatorio" (su
   propio `invalid-feedback`).
3. Cambia la `latency` de Stubby a 3000 ms y aprecia el valor del botón
   deshabilitado (luego déjala en 400).
4. Rompe a propósito el emparejamiento: `vue-template-compiler@2.6.12`,
   reinstala, corre `serve`, **captura el error exacto**, restaura. Es un
   viejo conocido de todo dev Vue 2 — mejor conocerlo hoy.
5. Apaga el mock y envía el formulario: verifica el mensaje del catch. Ahora
   entiendes por qué diagnostica en vez de decir "Error".
6. Agrega un segundo endpoint a `stubby.yml` (`GET /api/status` → algún JSON)
   y pruébalo desde el navegador directamente.
7. Verifica tu formateo: desordena a mano la indentación de `App.vue`, guarda,
   y confirma que Prettier lo arregla solo. Si no, tu editor quedó mal
   configurado — arréglalo AHORA, no en la Fase 4.
8. Comprueba el `.nvmrc`: abre una terminal nueva, `cd` al proyecto,
   `nvm use`, y confirma la versión (en Windows: hazlo manual y anota la
   diferencia).

**🟡 Intermedio (9–17)**

9. Lee un query param al cargar: si la URL trae `?name=Ana`, el saludo dice
   "Hola Ana" (pista: `URLSearchParams` + el hook `mounted`).
10. Agrega validación de longitud: el nombre requiere mínimo 3 caracteres,
    con **mensaje distinto** al de obligatorio (dos `<span>` bajo el mismo
    invalid-feedback, como hará la F5).
11. Limpia el resultado al volver a escribir: si `response` tiene algo y el
    usuario modifica el nombre, la alerta verde desaparece (pista: hazlo en
    el flujo existente, sin watch — piensa dónde).
12. Botón "Limpiar" que resetee nombre, `submitted` y `response`. ¿Qué pasa
    con el borde rojo? ¿Por qué?
13. Muestra la respuesta cruda: `console.log(res)` en el then y explora en la
    consola las cuatro partes de la respuesta de axios (data, status,
    headers, config). El Apéndice A4 te espera.
14. Haz que Stubby responda distinto según el body: investiga en su README el
    matching por `post` y agrega una respuesta especial cuando
    `name = "admin"`.
15. Contador de envíos exitosos ("Enviado N veces") — decide si va en `data`
    y por qué no puede ser un computed.
16. Extrae el formulario a un componente `HelloForm.vue` en `src/` que emita
    un evento `submit` con el nombre, y deja en `App.vue` el HTTP. Acabas de
    hacer, a ciegas, el patrón central de la Fase 5 — guárdalo y compara
    cuando llegues.
17. Escribe el `README.md` inicial del proyecto: requisitos (Node/NVM), los
    tres comandos, y qué es cada archivo de la raíz. Dáselo a alguien (o a tu
    yo de mañana) y mide si arranca sin preguntarte nada.

**🟠 Difícil (18–23)**

18. Estado de "sin conexión" fino: distingue en el catch entre "el mock no
    responde" y "el mock respondió con error" (agrega a `stubby.yml` un
    endpoint que devuelva `status: 500` y pruébalo). Pista: `error.response`.
    Es el árbol de diagnóstico del A4, descubierto por tu cuenta.
19. Doble submit demostrado: quita el `:disabled`, baja la latency a 2000,
    dale clic 3 veces rápido y cuenta los requests en la pestaña Network.
    Restaura y documenta en un comentario qué previene el disabled.
20. Valida "en vivo" después del primer intento: tras el primer submit
    fallido, el borde rojo se quita **mientras escribes** en cuanto el nombre
    es válido (ya funciona — explica POR QUÉ funciona sin código extra;
    la respuesta es la palabra "computed").
21. Persiste el último nombre enviado en `localStorage` y precárgalo al abrir.
    Anticipo casero de la sesión de la Fase 2.
22. Instala y configura ESLint + Prettier **sin pelearse**: agrega
    `eslint-config-prettier` para que ESLint no marque reglas de formato.
    Documenta en 3 líneas quién hace qué.
23. Crea un `CONTRIBUTING.md` con los lineamientos de la sección 4 (idiomas,
    nombres, formateo, época) redactados como reglas de equipo, con un
    ejemplo bueno/malo por regla. Este documento crecerá con el curso.

**🔴 Muy difícil (24–26)**

24. **Vue sin tooling**: recrea este mismo Hello World en UN archivo
    `hello.html` con Vue 2 por CDN (`<script src="https://cdn.jsdelivr.net/npm/vue@2.6.14">`),
    Bootstrap por CDN y `new Vue({ el: "#app", ... })` — sin Vue CLI, sin
    npm, sin build. Funciona abriendo el archivo. Compara ambas versiones y
    escribe 5 líneas: ¿qué te da exactamente todo el tooling que instalaste
    hoy? (El Apéndice A5 es la respuesta larga; esta es tu respuesta corta.)
25. Mock con memoria de juguete: Stubby no persiste — demuéstralo intentando
    un flujo de "registrar y listar" con dos endpoints, documenta contra qué
    pared chocaste, y escribe el mini-informe "por qué la Fase 3 necesita
    json-server" ANTES de leer la Fase 3. Compara después.
26. La máquina de un colega: consigue que otra persona (u otra máquina/VM
    tuya) clone el repo y lo levante usando SOLO tu README del ejercicio 17 +
    `.nvmrc` + lockfile. Cronometra y anota cada fricción. Cada minuto
    perdido es documentación o automatización que falta — el "en mi máquina
    funciona", medido en vez de sufrido.

---

## 📚 Referencias

**Documentación oficial**

- Vue 2 — guía: https://v2.vuejs.org/v2/guide/
- Vue 2 — instalación: https://v2.vuejs.org/v2/guide/installation
- Vue CLI: https://cli.vuejs.org/guide/installation.html
- axios: https://axios-http.com/docs/intro
- Bootstrap 4.6 — introducción: https://getbootstrap.com/docs/4.6/getting-started/introduction/
- Bootstrap 4.6 — forms (la validación visual): https://getbootstrap.com/docs/4.6/components/forms/#validation
- Stubby4node: https://github.com/mrak/stubby4node
- NVM: https://github.com/nvm-sh/nvm · nvm-windows: https://github.com/coreybutler/nvm-windows
- Prettier: https://prettier.io/docs/en/options.html
- EditorConfig: https://editorconfig.org/
- Vetur: https://vuejs.github.io/vetur/
- WebStorm + Vue: https://www.jetbrains.com/help/webstorm/vue-js.html

**Video / apoyo (verifica que sean de la era Vue 2)**

- Traversy Media — Vue JS Crash Course (2019)
- Net Ninja — Vue JS 2 Tutorial (playlist)

**Estilo y convenciones**

- Vue 2 Style Guide (la guía oficial de nombres y convenciones — nuestra
  sección 4 es su versión destilada): https://v2.vuejs.org/v2/style-guide/

---

## 🚀 Cierre

En una hora pasaste de máquina limpia a **ambiente legacy completo**: Node de
época administrado por NVM, proyecto Vue 2 con versiones exactas y
emparejadas, editor formateando solo, lineamientos por escrito, y un Hello
World que ya contiene — en miniatura — el ciclo completo de toda la app que
viene: estado reactivo, validación, HTTP con loading y error, y feedback al
usuario.

La señal de que quedó bien:

> "puedo borrar la carpeta del proyecto, clonarlo de nuevo y tenerlo corriendo
> en 5 minutos sin pensar — porque `.nvmrc`, el lockfile y el README piensan
> por mí."

**Siguiente parada:** 🏗️ Fase 1 — Estructura base legacy: este Hello World se
muda a una estructura de proyecto real (carpetas, layout con header y sidebar,
router), y el `App.vue` de hoy se jubila con honores.
