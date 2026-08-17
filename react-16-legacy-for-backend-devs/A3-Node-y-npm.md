# 📦 Apéndice A3 — Node y npm

> Tutorial React 16 — Rifas y chances · Apéndice de consulta rápida · **~1h**
> Lo usa: **Fase 0 (setup)** · Prioridad: 🔴 Alta

Esto **no** se lee de corrido. Es la página que abrís cuando `npm ci` te
tira un error raro, cuando un compañero instaló otra versión de algo y "en
su máquina anda", o cuando no te acordás si el lockfile se commitea (sí, se
commitea). Saltá directo a la sección que necesitás.

---

## 🧭 Índice de salto rápido

- [1. `package.json`: qué mirar y qué no](#1-packagejson-qué-mirar-y-qué-no)
- [2. semver y los rangos `^` `~`](#2-semver-y-los-rangos--)
- [3. `package-lock.json`: la fuente de verdad](#3-package-lockjson-la-fuente-de-verdad)
- [4. `npm ci` vs `npm i`](#4-npm-ci-vs-npm-i)
- [5. `.nvmrc` y fijar la versión de Node](#5-nvmrc-y-fijar-la-versión-de-node)
- [6. npm 6 vs npm 7: por qué aparece `--legacy-peer-deps`](#6-npm-6-vs-npm-7-por-qué-aparece---legacy-peer-deps)
- [7. Reproducibilidad: el checklist de "en mi máquina funciona"](#7-reproducibilidad-el-checklist-de-en-mi-máquina-funciona)
- [🧪 Ejercicios](#-ejercicios-8)
- [📚 Referencias](#-referencias)

---

## 1. `package.json`: qué mirar y qué no

Sos senior, así que no te voy a explicar qué es un `package.json`. Lo que
importa en mantenimiento es **dónde mirar primero** cuando algo no cuadra.
Tres campos deciden casi todo:

```json
{
  "dependencies": {
    "react": "16.14.0",
    "react-scripts": "4.0.3",
    "sass": "^1.32.0"
  },
  "devDependencies": {
    "@testing-library/react": "^11.2.0"
  },
  "engines": {
    "node": "14.21.3"
  }
}
```

- **`dependencies`** son las que necesita la app para correr en producción.
- **`devDependencies`** son las que solo necesitás para desarrollar y testear (Testing Library, linters). No van al bundle de producción.
- **`engines`** declara qué Node espera el proyecto. No es obligatorio, pero es documentación viva: si está y no coincide con tu Node, ya sabés por dónde empezar a buscar.

Fijate que `react` está **sin caret**: `"16.14.0"` exacto, no `"^16.14.0"`.
Eso es deliberado (decisión D1: React 16.14.0 es la única fuente de verdad
para APIs de clase). El resto de la sección explica por qué esa distinción
importa tanto.

> 💡 En un proyecto legacy, `package.json` te dice qué versiones *pidió*
> alguien alguna vez. `package-lock.json` te dice qué versiones
> *realmente están instaladas*. Cuando difieren, casi siempre el bug vive
> en esa grieta.

**Error común.** Editar a mano una versión en `package.json` y correr
`npm start` esperando que cambie algo. No cambia: hasta que no corras un
`npm install`, el `node_modules` sigue teniendo lo viejo, y el lockfile
también. Editar el manifest no reinstala nada por sí solo.

---

## 2. semver y los rangos `^` `~`

**semver** (versionado semántico) es `MAJOR.MINOR.PATCH`: por ejemplo
`1.32.5`. La teoría dice que `MAJOR` rompe compatibilidad, `MINOR` agrega
features compatibles y `PATCH` corrige bugs sin romper nada. En la práctica
legacy, "sin romper nada" es un acto de fe, y por eso los rangos importan:

| Rango en `package.json` | Significa "aceptá…" | Ejemplo con `1.32.5` | Puede instalar |
|---|---|---|---|
| `1.32.5` (exacto) | exactamente esta | solo `1.32.5` | `1.32.5` |
| `~1.32.5` (tilde) | parches de esta minor | `>=1.32.5 <1.33.0` | `1.32.9`, no `1.33.0` |
| `^1.32.5` (caret) | minors y parches de esta major | `>=1.32.5 <2.0.0` | `1.45.0`, no `2.0.0` |
| `*` / `latest` | lo que sea | cualquiera | 🙈 |

El caret `^` es el default de npm y el que más sorpresas da: aceptás
cualquier minor futura. Para una app que se reinstala hoy con las mismas
versiones que hace dos años, esa flexibilidad es justo lo que **no**
querés. Por eso existe el lockfile.

> 📝 **Nota de época.** En 2020-2022, CRA generaba casi todo con caret. Era
> lo normal: se asumía que las minors eran seguras. Un mantenedor de hoy
> sabe que "seguro" duró hasta el primer `npm install` en una máquina
> nueva seis meses después, con una minor recién publicada que rompía el
> build. El lockfile es la respuesta del ecosistema a ese dolor.

**Error común.** Leer `^1.32.5` y pensar "estoy clavado en 1.32.5". No:
estás clavado en *cualquier cosa por debajo de 2.0.0*. Sin lockfile, dos
personas que clonan el mismo repo con una semana de diferencia pueden
terminar con `sass` distintos.

---

## 3. `package-lock.json`: la fuente de verdad

> **Decisión D7 — `package-lock.json` es norma.** Reproducibilidad exacta
> en todos los entornos. No se tocan versiones sin justificar. Si aparece
> un paquete con CVE, se documenta como incidente y se marca 💸.

El `package-lock.json` registra el **árbol completo y exacto** de
dependencias: no solo lo que pediste vos, sino cada dependencia de cada
dependencia, con su versión precisa y su hash de integridad. Es la
diferencia entre "quiero `sass` compatible con 1.32" y "instalá
exactamente `sass@1.32.5` con este hash y estas 40 sub-dependencias
clavadas".

Reglas prácticas de mantenimiento:

- **Se commitea. Siempre.** Un lockfile fuera del control de versiones no sirve para nada; su único propósito es que todo el equipo instale lo mismo.
- **No se edita a mano.** Es un archivo generado. Si necesitás cambiar una versión, cambiás `package.json` y dejás que npm regenere el lock (y revisás el diff antes de commitear).
- **Su diff es información forense.** Cuando un `npm install` "de la nada" modifica el lock, ese diff te dice exactamente qué se movió. En una PR, un lock que cambia sin que nadie tocara dependencias es una señal de alerta.

**Error común.** Alguien corre `npm install` para agregar un solo paquete,
npm aprovecha para "actualizar" medio árbol dentro de los rangos caret, y
el diff del lockfile toca 200 líneas. Se mergea sin mirar. Dos días después
el build de CI falla y nadie sabe por qué. La causa raíz estaba en ese diff
que nadie leyó.

> 💡 Antes de commitear un cambio de dependencias, mirá el diff del
> `package-lock.json` como mirarías el de cualquier código. Si cambió algo
> que no esperabas, entendé por qué *antes* de mergear, no después de que
> CI se ponga rojo.

---

## 4. `npm ci` vs `npm i`

Estos dos comandos parecen intercambiables y no lo son. La diferencia es la
que separa "instalá lo que el lockfile dice" de "resolvé las dependencias y
quizá actualizá el lockfile de paso".

| | `npm ci` | `npm install` (`npm i`) |
|---|---|---|
| **Fuente de verdad** | `package-lock.json` | `package.json` (respetando rangos) |
| **¿Puede modificar el lockfile?** | ❌ Nunca. Si `package.json` y el lock no concuerdan, **falla** | ✅ Sí, lo regenera/actualiza |
| **`node_modules` previo** | lo borra entero y reinstala limpio | instala incremental sobre lo que haya |
| **¿Requiere lockfile?** | Sí, o no corre | No |
| **Velocidad** | más rápido y determinista | más lento, resuelve el árbol |
| **Para qué sirve** | CI, Docker, onboarding, cualquier build reproducible | agregar/quitar/actualizar una dependencia |

La regla mental es simple: **`npm ci` para instalar lo que ya está
decidido; `npm i` para decidir algo nuevo.**

En este curso, el flujo de arranque de la Fase 0 es
`nvm use && npm ci && npm start` justamente por esto: `npm ci` garantiza
que clones el repo y obtengas *exactamente* el mismo `node_modules` que
tenía quien lo dejó andando. Cero deriva.

**Error común 1.** Correr `npm ci` sin lockfile (o con uno desincronizado
del `package.json`). Falla con un mensaje del estilo *"can only install with
an existing package-lock.json"* o *"package-lock.json and package.json are
in sync"*-invertido. No es un bug: es `npm ci` haciendo su trabajo. El fix
no es forzar la instalación, es entender por qué el lock no coincide.

**Error común 2.** Usar `npm install` en CI "porque siempre funcionó". Un
día una minor nueva dentro de un rango caret entra en el árbol, el build de
CI queda distinto del de tu máquina, y aparece un bug que solo pasa en CI.
En CI, Docker y cualquier entorno que deba ser reproducible, va `npm ci`.

---

## 5. `.nvmrc` y fijar la versión de Node

El `.nvmrc` es un archivo de una sola línea con la versión de Node que el
proyecto espera:

```bash
echo "14.21.3" > .nvmrc
```

Quien clona el repo corre `nvm use` en la raíz y nvm lee ese archivo:

```bash
nvm use
# Now using node v14.21.3 (npm v6.14.18)
```

Si no tiene esa versión instalada:

```bash
nvm install    # sin argumento: instala la del .nvmrc
```

Parece trivial, pero es la primera línea de defensa contra el bug legacy
más clásico de todos: el proyecto se construyó con Node 14 y vos tenés Node
20 por default. Con Node 17+, Webpack 4 (el que trae CRA 4) explota con el
famoso error de OpenSSL:

```
Error: error:0308010C:digital envelope routines::unsupported
```

Ese error **no** significa que tu código esté mal. Significa que estás
corriendo un Webpack viejo sobre un Node nuevo. El fix correcto no es
`NODE_OPTIONS=--openssl-legacy-provider` (ese es el parche); el fix
correcto es usar el Node que el proyecto declara. Para eso está el
`.nvmrc`.

> ⚠️ El `.nvmrc` **documenta y facilita**, pero no **fuerza**. `nvm` no se
> activa solo al entrar a la carpeta salvo que configures el shell hook.
> Si abrís una terminal nueva y te olvidás el `nvm use`, seguís con tu Node
> global. Cuando algo "raro" pase, `node -v` es siempre de las tres
> primeras cosas que revisás.

> 💡 `engines` en `package.json` + `.nvmrc` cuentan la misma verdad desde
> dos lugares. `.nvmrc` la hace *accionable* (`nvm use`); `engines` la deja
> *auditable* (npm puede avisar, o fallar, si no coincide). Tener ambos no
> es redundancia, es defensa en profundidad.

---

## 6. npm 6 vs npm 7: por qué aparece `--legacy-peer-deps`

Este curso usa **npm 6** (el que viene con Node 14.21.3). Es importante
saberlo porque npm cambió una regla de fondo en la versión 7, y ese cambio
es la razón por la que en la Fase 0, dentro del contenedor, aparece un
`npm ci --legacy-peer-deps` que de otro modo parecería magia.

El cambio en una frase: **npm 6 ignora los conflictos de
`peerDependencies`; npm 7+ los trata como error y aborta la instalación.**

Un `peerDependency` es una dependencia que un paquete *espera que vos ya
tengas*, en lugar de traérsela él (típico de plugins: un plugin de React
espera que vos aportes React). En el ecosistema CRA 4 / React 16 hay
paquetes cuyos rangos de peer no cierran perfecto entre sí. npm 6 se
encogía de hombros y seguía. npm 7 se planta:

```
npm ERR! ERESOLVE unable to resolve dependency tree
npm ERR! Could not resolve dependency:
npm ERR! peer react@"^17.0.0" from some-package@...
```

`--legacy-peer-deps` le pide a npm 7+ que se comporte como npm 6 ante los
peers: ignorar el conflicto y seguir. No es una mala práctica en sí; en un
proyecto legacy con árbol congelado es exactamente lo que querés, porque el
árbol ya lo resolvió el lockfile.

| | npm 6 (este curso) | npm 7+ |
|---|---|---|
| **Conflictos de `peerDependencies`** | los ignora | falla con `ERESOLVE` |
| **Instala peers automáticamente** | no | sí |
| **Necesita `--legacy-peer-deps`** | no (ya se comporta así) | sí, para replicar npm 6 |
| **Formato del lockfile** | `lockfileVersion: 1` | `lockfileVersion: 2/3` |

> 📝 **Nota de época.** Si en tu máquina tenés Node 16+ (npm 7/8/9) pero el
> proyecto es de la era npm 6, vas a chocar con `ERESOLVE` casi seguro. Dos
> caminos: usar el Node del `.nvmrc` (npm 6, sin flags) o quedarte en tu
> Node moderno y agregar `--legacy-peer-deps`. El primero es más fiel al
> proyecto; el segundo es el parche cuando no podés cambiar de Node. Por eso
> la Fase 0 lo usa dentro del contenedor: ahí la imagen base puede traer un
> npm más nuevo, y el flag replica el comportamiento de npm 6 sin drama.

> ⚠️ Un lockfile `lockfileVersion: 1` (npm 6) reabierto con npm 7+ se
> **reescribe** a v2/v3 en el próximo `install`. Ese cambio ensucia el diff
> y puede desincronizar al equipo si unos usan npm 6 y otros no. Es otra
> razón para alinear todos en el Node del `.nvmrc`.

---

## 7. Reproducibilidad: el checklist de "en mi máquina funciona"

Todo lo anterior converge en una sola meta: que cualquiera clone el repo y
obtenga **el mismo build que vos**, sin sorpresas. Cuando alguien reporta
"en mi máquina no compila", recorré esto en orden:

1. **`node -v`** — ¿coincide con `.nvmrc`? Es la causa nº1. `nvm use` y reintentá.
2. **`npm -v`** — ¿npm 6, o npm 7+ metiendo `ERESOLVE`? (ver §6).
3. **¿Corriste `npm ci` o `npm install`?** Para reproducir, siempre `npm ci` (§4).
4. **¿El `package-lock.json` está commiteado y sin cambios locales?** `git status` sobre el lock. Si mutó solo, algo lo tocó.
5. **`node_modules` sospechoso** — borralo y `npm ci` limpio. Nunca compartas un `node_modules` entre arquitecturas distintas (macOS arm64 vs Linux amd64 dentro de un contenedor): los binarios nativos no coinciden.

> 💡 **El patrón a memorizar.** Node correcto (`.nvmrc`) + lockfile
> commiteado + `npm ci` = build reproducible. Si los tres están, "en mi
> máquina funciona" deja de ser una excusa y pasa a ser una verdad
> verificable. Quitá cualquiera de los tres y volvés a la lotería.

---

## 🧪 Ejercicios (8)

Cortos, de consulta y diagnóstico. Resolvelos sobre el repo de la Fase 0.

**🟢 Fácil (1–3)**

1. Abrí el `package.json` del proyecto de la Fase 0 y localizá tres cosas: la versión exacta de `react`, el rango de `sass` y si existe un campo `engines`. Anotá cuál está clavada exacta y cuál con rango, y por qué (pista: D1).
2. Corré `node -v` y `npm -v`. Confirmá que coinciden con `.nvmrc` (Node) y con npm 6. Si tenés otro Node activo, arreglalo con `nvm use` y volvé a verificar.
3. Dado `"sass": "^1.32.5"`, escribí qué versiones podría instalar npm y cuáles **no**. Después hacé el mismo ejercicio mental con `~1.32.5`.

**🟡 Intermedio (4–6)**

4. **Diagnóstico:** un compañero editó `"react": "16.14.0"` a `"16.13.0"` en `package.json`, corrió `npm start` y jura que "sigue usando la 16.14". Explicá por qué el cambio no tuvo efecto y qué comando faltó correr. (Pista: §1.)
5. **Diagnóstico:** clonás el repo en una máquina limpia, corrés `npm ci` y falla con un error sobre `package-lock.json`. Listá las dos causas más probables y cómo distinguís una de la otra sin tocar nada todavía.
6. Borrá tu `node_modules` y corré `npm ci`. Cronometralo. Después borralo de nuevo y corré `npm install`. Compará tiempos y explicá por qué `npm ci` suele ganar y por qué solo uno de los dos puede tocar el lockfile.

**🟠 Difícil (7–8)**

7. **Reproducción del bug de OpenSSL:** levantá el proyecto con el Node del `.nvmrc` (anda) y después con Node 18 o 20 (falla con `digital envelope routines::unsupported`). Documentá el mensaje exacto, explicá la causa raíz a nivel Webpack/OpenSSL y decí por qué usar el `.nvmrc` es mejor fix que `NODE_OPTIONS=--openssl-legacy-provider`.
8. **Reproducción de `ERESOLVE`:** con un Node que traiga npm 7+, corré `npm ci` sin flags sobre el proyecto y provocá el error de peer deps. Después hacelo andar con `--legacy-peer-deps`. Explicá qué cambió npm 7 respecto de npm 6 y por qué el flag replica el comportamiento viejo. Anotá dos líneas de post-mortem sin culpabilización.

---

## 📚 Referencias

### Documentación oficial

- **npm 6 (CLI del curso):** https://docs.npmjs.com/cli/v6 — la versión que trae Node 14. Ojo: si buscás en Google caés casi siempre en la doc de la última; verificá que la URL diga `/v6`.
- **`npm ci`:** https://docs.npmjs.com/cli/v6/commands/npm-ci
- **`npm install`:** https://docs.npmjs.com/cli/v6/commands/npm-install
- **`package-lock.json`:** https://docs.npmjs.com/cli/v6/configuring-npm/package-lock-json
- **`package.json`:** https://docs.npmjs.com/cli/v6/configuring-npm/package-json
- **semver (rangos y calculadora):** https://semver.org · https://semver.npmjs.com
- **nvm (`.nvmrc`, Linux/macOS):** https://github.com/nvm-sh/nvm#nvmrc
- **nvm-windows:** https://github.com/coreybutler/nvm-windows
- **Cambios de npm 7 (peer deps, `lockfileVersion`):** https://docs.npmjs.com/cli/v7/using-npm/changelog

> Las URLs y títulos pueden haber cambiado; verificá que la versión de la
> doc (`/v6` vs `/v7`) sea la que estás usando antes de confiar en un flag.

### Orden de lectura sugerido

semver (entender rangos) → `package-lock.json` (qué congela) → `npm ci` vs
`npm install` (cómo se consume ese lock) → nota de npm 7 (por qué aparece
`--legacy-peer-deps`). Con eso cubierto, volvé a la Fase 0 y el
`nvm use && npm ci && npm start` deja de ser un conjuro y pasa a ser una
decisión que entendés.

---

> **La señal de que quedó bien:** si un compañero te dice "en mi máquina no
> compila", ya sabés cuáles son las tres primeras preguntas y en qué orden
> hacerlas — y ninguna empieza con "probá reinstalando a ver".
