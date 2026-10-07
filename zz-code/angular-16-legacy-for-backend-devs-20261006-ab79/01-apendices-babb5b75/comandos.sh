# Comandos Bash de la sesión babb5b75-c366-4b28-8e94-3edf8c8289a5, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-06T22:20:22 · List prompts dir and line counts
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs && ls -la prompts && wc -l README.md prompts/*

# --- 2026-09-06T22:20:25 · Read style guide part 1
sed -n '1,250p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-06T22:20:28 · Read style guide part 2
sed -n '250,728p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-06T22:20:32 · Read propuesta de fases
sed -n '1,200p' prompts/propuesta-fases-y-alcance.md

# --- 2026-09-06T22:20:34 · Read rest of propuesta and alcance
sed -n '200,402p' prompts/propuesta-fases-y-alcance.md; echo "=========== ALCANCE ==========="; sed -n '1,180p' prompts/alcance-del-proyecto.md

# --- 2026-09-06T22:20:40 · Check course file state and phase prompt index
wc -l *.md | sort -n && echo "--- prompts fases: índice ---" && grep -n '^## ' prompts/prompts-extendidos-fases.md | head -60

# --- 2026-09-06T22:24:36 · Read appendix template
sed -n '/## .*[Aa]p.ndice/,$p' prompts/plantillas-de-capitulo.md | head -160

# --- 2026-09-06T22:24:40 · Find appendix template section
grep -n 'apéndice\|Apéndice\|plantilla de apéndice' prompts/plantillas-de-capitulo.md | head -40

# --- 2026-09-06T22:24:42 · Read full appendix template
sed -n '251,350p' prompts/plantillas-de-capitulo.md

# --- 2026-09-06T22:24:45 · Read alcance sections 8-9
sed -n '/^## 8\./,/^## 10\./p' prompts/alcance-del-proyecto.md

# --- 2026-09-06T22:24:51 · Extract headings from all phase files
for f in 0*.md 1*.md; do echo "=== $f ==="; grep -n '^## \|^### ' "$f" | sed 's/:## /: /;s/:### /:   /'; done

# --- 2026-09-06T22:24:56 · Extract pending items from all phases
for f in 0[0-9]-*.md 1[0-4]-*.md; do case $f in 00-convencion*|00-historia*) continue;; esac; echo "=== $f ==="; awk '/^## 📌 Pendientes sugeridos/,0' "$f"; done

# --- 2026-09-06T22:25:02 · Extract appendix mentions from pending items
grep -oiE '[^.]*[Aa]p.ndice [Aa]?[0-9]+[^.]*\.' /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/babb5b75-c366-4b28-8e94-3edf8c8289a5/tool-results/b2rim1c0n.txt | sed 's/^ *//' | sort -u

# --- 2026-09-06T22:25:05 · Grep appendix references in pendings
grep -oiE '.{80}A0[1-9]|.{80}A1[0-3]' /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/babb5b75-c366-4b28-8e94-3edf8c8289a5/tool-results/b2rim1c0n.txt | sed 's/^ *//' | sort -u | head -60

# --- 2026-09-06T22:25:09 · Full context of appendix notes
grep -oE '.{400}(Aviso para el chat de A[0-9]+|Candidato a párrafo fijo en A[0-9]+|Nota para el chat de A[0-9]+|párrafo fijo en \*\*A[0-9]+).{0,300}' /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/babb5b75-c366-4b28-8e94-3edf8c8289a5/tool-results/b2rim1c0n.txt

# --- 2026-09-06T22:25:15 · Lines with appendix notes
grep -nE 'Aviso para el chat de A|Candidato a párrafo fijo|Nota para el chat de A|párrafo fijo en' /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/babb5b75-c366-4b28-8e94-3edf8c8289a5/tool-results/b2rim1c0n.txt | cut -c1-700

# --- 2026-09-06T22:25:33 · List courses and exact dependency pins used
cd /Users/oskar/Developer/Learning/courses-ia-generated && ls -d */ && echo "--- pins fase 0/10/11/12 ---" && grep -hoE '"[a-z0-9@/-]+": *"[^"]+"' angular-16-legacy-for-backend-devs/0*.md angular-16-legacy-for-backend-devs/1*.md | sort -u

# --- 2026-09-06T22:25:40 · Find install pins and Track A course
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs && grep -hoE '(npm i[a-z]* [^ ]*@[0-9][^ ]*|ng add [^ ]*@[0-9][^ ]*)' *.md | sort -u; echo "--- material/jspdf/charts menciones de version ---"; grep -hoE '(material|jspdf|jspdf-autotable|ng2-charts|chart\.js|localize)[^ ]* ?[0-9]+\.[0-9]+\.[0-9x]+' *.md | sort -u | head -20; echo "--- LabCore ---"; head -5 ../angular-8-legacy-for-backend-devs/README.md 2>/dev/null; ls ../angular-8-legacy-for-backend-devs | head

# --- 2026-09-06T22:25:43 · Check jspdf and chart pins in phases
grep -n 'jspdf\|autotable' 10-certificados-vigencia.md | head -20; echo "--- charts ---"; grep -n 'ng2-charts\|chart.js\|chartjs' 11-dashboard-alertas.md | head -10

# --- 2026-09-06T22:28:35 · Inspect internal link style
grep -hoE '\[[^]]{3,60}\]\((\.?/)?[0-9a-z][^)]*\.md[^)]*\)' *.md | sort | uniq -c | sort -rn | head -25

# --- 2026-09-06T22:28:38 · See how phases reference appendices
grep -hnoE '(A0[1-9]|A1[0-3])[^.,)]{0,60}' 0[3-9]-*.md 1[0-4]-*.md | head -30; echo "=== ejemplo de referencia a fase ==="; grep -hoE '\*\*Fase [0-9]+\*\*[^.]{0,60}' 06-clientes-activos.md | head -5

# --- 2026-09-06T22:28:44 · Phase header format and template top
sed -n '1,12p' 06-clientes-activos.md; echo "..."; sed -n '1,60p' prompts/plantillas-de-capitulo.md

# --- 2026-09-06T22:28:51 · Fase 0 entorno y versiones
sed -n '106,215p' 00-setup-hola-mundo.md

# --- 2026-09-06T22:28:55 · Fase 2 concepto e interceptors/guards
sed -n '42,99p' 02-autenticacion.md; echo "......"; sed -n '537,660p' 02-autenticacion.md

# --- 2026-09-06T22:28:58 · Fase 4 concepto y servicio de estado
sed -n '44,115p' 04-estado-servicios.md; echo "......5.2/5.3......"; sed -n '168,330p' 04-estado-servicios.md

# --- 2026-09-06T22:29:01 · Fase 6 formularios tipados
sed -n '57,96p' 06-clientes-activos.md; echo "...5.7 form..."; sed -n '721,830p' 06-clientes-activos.md

# --- 2026-09-06T22:29:04 · Fase 8 FormRecord y formulario dinámico
sed -n '59,100p' 08-formulario-dinamico.md; echo "...5.3..."; sed -n '237,380p' 08-formulario-dinamico.md

# --- 2026-09-06T22:31:32 · Write A03
cat > a03-node-npm.md <<'APPENDIX_EOF'
# 📎 Apéndice A03 — Node y npm

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **2 horas**
> Usado por: Fase 0, Fase 3, Fase 12, Fase 13 · Versión cubierta: Node 18.18.2 · npm 9.8.1 · lockfile v3

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
APPENDIX_EOF
wc -l a03-node-npm.md

# --- 2026-09-06T22:31:39 · AuthService heredado y CoreModule
sed -n '251,300p' 02-autenticacion.md; echo "---- core.module 5.9 ----"; sed -n '660,712p' 02-autenticacion.md

# --- 2026-09-06T22:34:06 · Write A04
cat > a04-inject-vs-constructor.md <<'APPENDIX_EOF'
# 📎 Apéndice A04 — `inject()` frente a `constructor`

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **2 horas**
> Usado por: Fase 0, Fase 1, Fase 2, Fase 5 — y de consulta en todas · Versión cubierta: Angular 16.2.12

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve la pregunta que te vas a hacer cada vez que abras un archivo de CertCore: **cuál de las dos formas de inyectar toca aquí, y qué se rompe si eliges mal.**

Este apéndice es 🧬 de principio a fin. Casi todas sus secciones muestran el mismo caso escrito de las dos maneras, porque las dos están vivas en el repositorio y las dos son correctas — cada una en su archivo.

**Qué queda fuera:** el sistema de inyección de dependencias completo. La jerarquía de inyectores de elemento, los `multi` providers avanzados, las factories con `deps`, los inyectores de plataforma. Nada de eso hace falta para mantener CertCore, y está documentado mejor de lo que cabría aquí: https://v16.angular.io/guide/dependency-injection. Lo que sí está es todo lo que aparece en el código del curso.

---

## Índice

- [1. Qué es el contexto de inyección, y dónde termina](#1-qué-es-el-contexto-de-inyección-y-dónde-termina)
- [2. 🧬 El mismo servicio, escrito de las dos formas](#2--el-mismo-servicio-escrito-de-las-dos-formas)
- [3. Herencia: el `super()` que deja de doler](#3-herencia-el-super-que-deja-de-doler)
- [4. Guards, interceptors y resolvers funcionales](#4-guards-interceptors-y-resolvers-funcionales)
- [5. `runInInjectionContext`: cuándo es legítimo](#5-runininjectioncontext-cuándo-es-legítimo)
- [6. Las opciones de `inject()`](#6-las-opciones-de-inject)
- [7. `NG0203` traducido: los cuatro sitios donde sale](#7-ng0203-traducido-los-cuatro-sitios-donde-sale)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Qué es el contexto de inyección, y dónde termina

`inject()` no lee un registro global. Lee **el inyector que Angular tiene activo en este preciso instante**, y Angular sólo tiene un inyector activo mientras está construyendo algo. Fuera de esa ventana, `inject()` no tiene a quién preguntar y lanza `NG0203`.

La ventana está abierta exactamente en cuatro sitios:

- **En el inicializador de un campo de clase.** `private readonly http = inject(HttpClient);` — los campos se inicializan durante la construcción de la instancia, así que estás dentro.
- **En el cuerpo del constructor.** Menos común, igual de válido.
- **Dentro de una función factory.** El `useFactory` de un provider, la factory de un `APP_INITIALIZER` —la de la **Fase 13**—, y la factory implícita de un `@Injectable({ providedIn: 'root' })`.
- **Dentro de un guard, interceptor o resolver funcional.** Porque son, literalmente, factories que Angular ejecuta con el inyector puesto (§4).

Y se cierra en cuanto Angular termina. Esto **no** es contexto de inyección, aunque esté en la misma clase:

```ts
export class TemplateListComponent implements OnInit {
  private readonly templateApi = inject(TemplateApiService);   // ✅ dentro

  ngOnInit(): void {
    const router = inject(Router);   // ❌ NG0203: ya se construyó, la ventana se cerró
  }
}
```

> 🧭 **El hábito que resuelve el 90% de los casos: se inyecta arriba del todo y se usa después.** Las referencias quedan capturadas en el campo o en el closure y funcionan donde quieras — dentro de un `subscribe`, de un `catchError`, de un `setTimeout`. Lo que no funciona es *llamar a `inject()`* ahí.

> 🧠 **La analogía con backend, y dónde se rompe.** `inject()` es resolución del contenedor de DI, como el `getBean()` de Spring o el `GetService<T>()` de .NET. La diferencia que importa: aquellos leen un contenedor que existe todo el tiempo, y éste lee un contenedor que sólo existe durante la construcción. Por eso allí puedes resolver una dependencia en mitad de un método y aquí no. Hasta ahí el paralelo; a partir de ahí, la regla de arriba.

---

## 2. 🧬 El mismo servicio, escrito de las dos formas

Las dos formas están en `core/` de CertCore, y las dos están bien. La diferencia es la fecha del archivo.

```ts
// ── HEREDADO (2021) ────────────────────────────────────────────────────────
// Así está escrito AuthService, y así se queda. Las dependencias son
// parámetros del constructor, marcados `private readonly` para que TypeScript
// los convierta en campos.
@Injectable({ providedIn: 'root' })
export class AuthService {
  constructor(
    private readonly http: HttpClient,
    private readonly router: Router,
  ) {}
}
```

```ts
// ── NUEVO (2024) ───────────────────────────────────────────────────────────
// Así está escrito TemplateStateService. Sin constructor. Cada dependencia es
// un campo que se resuelve sola.
@Injectable({ providedIn: 'root' })
export class TemplateStateService {
  private readonly templateApi = inject(TemplateApiService);
  private readonly authService = inject(AuthService);
}
```

**Qué cambia de verdad, más allá de la estética:**

- **El tipo no viaja por metadatos.** El constructor con parámetros depende de `emitDecoratorMetadata` y de que el tipo sea una clase: por eso un token de inyección necesita `@Inject(TOKEN)` delante. Con `inject(TOKEN)` el token es un argumento normal y la ceremonia desaparece.
- **Se puede usar fuera de una clase.** Un guard funcional no tiene constructor. Ésa es la razón por la que `inject()` existe, y no la brevedad.
- **La herencia deja de doler** (§3).
- **El orden de los campos importa.** Los inicializadores de campo corren de arriba abajo: si un campo usa a otro, el otro tiene que estar declarado antes. Con constructor, el cuerpo corre después de que todos los parámetros existan.

Lo que **no** cambia: el `@Injectable()` sigue haciendo falta para que la clase se pueda proveer, `providedIn: 'root'` sigue significando lo mismo, y el árbol de inyectores es exactamente el mismo. `inject()` es otra sintaxis para preguntarle a quien ya estaba ahí.

> 📝 **Nota de migración.** `inject()` es público desde Angular **14**, y su motivo original fue habilitar los guards e interceptors funcionales, no ahorrar líneas en los servicios. CertCore nació en 2021 sobre Angular 12, donde ni existía; durante la migración de 2024 el equipo escribió lo nuevo con `inject()` y no tocó lo viejo. Por eso `core/` tiene hoy servicios de las dos épocas, uno al lado del otro, y ninguno de los dos está mal.

> 🧭 **Regla del proyecto (guía §6.1).** Código nuevo, estilo nuevo. Código heredado, se toca lo mínimo y en su propio estilo. **Y nunca los dos dentro del mismo archivo.** Una clase con dos dependencias en el constructor y una tercera con `inject()` es peor que cualquiera de las dos formas puras: obliga a leer el archivo entero para saber de qué depende.

---

## 3. Herencia: el `super()` que deja de doler

Éste es el sitio donde la diferencia deja de ser estilo y pasa a ser mantenimiento.

```ts
// ── HEREDADO ───────────────────────────────────────────────────────────────
@Injectable()
export abstract class BaseApiService {
  constructor(protected readonly http: HttpClient) {}
}

@Injectable({ providedIn: 'root' })
export class ClientApiService extends BaseApiService {
  // Hay que volver a declarar la dependencia del padre SÓLO para pasársela.
  constructor(http: HttpClient, private readonly logger: LoggerService) {
    super(http);
  }
}
```

El problema no es la verbosidad: es que **añadir una dependencia a la clase base obliga a tocar todas las hijas**. Cinco servicios que heredan de `BaseApiService` significan cinco constructores que cambian, cinco commits en archivos que no tenían nada que ver con el cambio, y cinco oportunidades de equivocarse en el orden de los argumentos — que además compila, porque dos `string` son intercambiables para el compilador y no para ti.

```ts
// ── NUEVO ──────────────────────────────────────────────────────────────────
@Injectable()
export abstract class BaseApiService {
  // El padre se resuelve solo. Nadie tiene que saber de qué depende.
  protected readonly http = inject(HttpClient);
}

@Injectable({ providedIn: 'root' })
export class ClientApiService extends BaseApiService {
  private readonly logger = inject(LoggerService);
  // Sin constructor. Sin super(). Sin nada.
}
```

Ahora la clase base puede añadir dependencias sin que ninguna hija se entere. Ése es el argumento entero.

> ⚠️ **El orden de inicialización sigue siendo el de JavaScript, y muerde.** Los campos de la clase base se inicializan **antes** que los de la hija. Si un campo de la base llama a un método sobrescrito que usa un campo de la hija, ese campo todavía es `undefined` — y con `strict` el compilador no te avisa, porque el tipo dice que existe. No es un problema de `inject()`: es el mismo de siempre, sólo que ahora hay más código en los inicializadores donde antes había un constructor.

---

## 4. Guards, interceptors y resolvers funcionales

Aquí `inject()` no es una alternativa: es la única forma. Un guard funcional no tiene clase, así que no tiene constructor donde pedir nada.

```ts
// Guard — CanActivateFn, Angular 14
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);   // ✅ estamos dentro de la factory
  const router = inject(Router);
  return authService.isAuthenticated() || router.createUrlTree(['/login']);
};

// Interceptor — HttpInterceptorFn, Angular 15
export const authInterceptor: HttpInterceptorFn = (request, next) => {
  const authService = inject(AuthService);   // ✅ arriba del todo, siempre
  return next(request).pipe(
    catchError((error: unknown) => {
      // ❌ Aquí ya NO. `inject(Router)` en este punto es NG0203.
      // authService funciona porque es una referencia capturada, no una llamada.
      return throwError(() => error);
    }),
  );
};

// Resolver — ResolveFn<T>, Angular 15
export const templateResolver: ResolveFn<ChecklistTemplate> = (route) => {
  const templateApi = inject(TemplateApiService);
  const templateId = route.paramMap.get('templateId') ?? '';
  return templateApi.getById(templateId);
};
```

**La equivalencia con la forma heredada**, para cuando te encuentres una:

| Nuevo | Heredado | Cómo se registra el heredado |
|---|---|---|
| `CanActivateFn` | clase con `implements CanActivate` | `canActivate: [AuthGuard]` con la clase |
| `HttpInterceptorFn` | clase con `implements HttpInterceptor` | `{ provide: HTTP_INTERCEPTORS, useClass: …, multi: true }` |
| `ResolveFn<T>` | clase con `implements Resolve<T>` | `resolve: { data: DataResolver }` con la clase |

> 🧬 **El archivo donde las dos generaciones se tocan** es `core/core.module.ts` de la **Fase 2**: un `NgModule` de 2021 registrando a la vez `provideHttpClient(withInterceptorsFromDi(), withInterceptors([authInterceptor]))`. Eso no viola la regla del §2: no hay dos estilos *escritos* en el archivo, hay un módulo heredado registrando código de las dos épocas, que es su trabajo. Por eso lleva 🧬 y no 💸.

---

## 5. `runInInjectionContext`: cuándo es legítimo

Cuando de verdad necesitas resolver algo fuera de la ventana, Angular 16 te deja abrirla a mano — siempre que tengas un inyector.

```ts
export class ReportExportService {
  private readonly injector = inject(EnvironmentInjector);   // capturado al construir

  // El caso legítimo: código que se ejecuta más tarde y cuyas dependencias no
  // se conocen al construir. Aquí, el generador del PDF se carga con import()
  // dinámico y sólo entonces sabemos qué necesita.
  async export(): Promise<void> {
    const { buildCertificatePdf } = await import('./certificate-pdf');

    runInInjectionContext(this.injector, () => {
      buildCertificatePdf();   // dentro puede llamar a inject() sin romperse
    });
  }
}
```

**Cuándo es legítimo, en una lista corta:** carga diferida con `import()` de código que inyecta; librerías o utilidades que reciben una función y la ejecutan fuera del ciclo de Angular; y tests, donde a veces es lo más limpio (**Fase 12**).

**Cuándo es un parche:** cuando lo estás usando para llamar a `inject()` dentro de un `ngOnInit`, de un `subscribe` o de un manejador de evento. Ahí la solución no es abrir la ventana otra vez: es inyectar arriba y usar la referencia. Si te encuentras un `runInInjectionContext` en una clase de CertCore, léelo como una señal de que alguien resolvió con maquinaria lo que se resolvía moviendo una línea.

> 📝 **Nota de migración.** Hasta Angular 15 esto se escribía `injector.runInContext(fn)`, un método del `EnvironmentInjector`. Angular **16** introdujo la función suelta `runInInjectionContext(injector, fn)` y dejó el método anterior en desuso. Las dos hacen lo mismo; si encuentras la forma vieja en un artículo, no está mal, está fechada.

---

## 6. Las opciones de `inject()`

El segundo argumento cambia qué pasa cuando la dependencia no aparece o dónde se busca.

```ts
// El caso normal: si no está, NG0201 (NullInjectorError) y el arranque se cae.
private readonly http = inject(HttpClient);

// optional: devuelve null en vez de reventar. El tipo lo refleja: HttpClient | null
private readonly analytics = inject(AnalyticsService, { optional: true });

// skipSelf: empieza a buscar en el inyector PADRE, saltándose el propio.
// Es lo que hace el guard de doble importación de CoreModule, en su forma de clase.
private readonly parent = inject(CoreModule, { optional: true, skipSelf: true });

// self: busca SÓLO en el inyector propio; si no está ahí, no sube.
private readonly localConfig = inject(FEATURE_CONFIG, { self: true });

// host: se detiene en el componente anfitrión. Sólo tiene sentido en directivas.
private readonly control = inject(NgControl, { optional: true, host: true });
```

| Opción | Qué hace | Dónde aparece en CertCore |
|---|---|---|
| `optional: true` | `null` en vez de error; el tipo se vuelve `T \| null` | dependencias que pueden no estar configuradas |
| `skipSelf: true` | empieza a buscar en el padre | el guard de doble importación de `CoreModule` (Fase 1, en su forma heredada con `@SkipSelf()`) |
| `self: true` | no sube al padre | providers de ruta que no deben caer al de raíz |
| `host: true` | se detiene en el componente anfitrión | directivas que hablan con el control del formulario |

La traducción a la forma heredada es uno a uno: `{ optional: true }` es `@Optional()`, `{ skipSelf: true }` es `@SkipSelf()`, `{ self: true }` es `@Self()`, `{ host: true }` es `@Host()`. Si estás arreglando un archivo de 2021, usa los decoradores; el archivo es de esa época.

> ⚠️ **`optional: true` cambia el tipo, y con `strict` eso se nota.** `inject(X, { optional: true })` devuelve `X | null`, y a partir de ahí el compilador te va a exigir decidir qué pasa cuando es `null`. Eso es exactamente lo que quieres: la mitad de los bugs de configuración del curso son "esto podía no estar y nadie lo pensó".

---

## 7. `NG0203` traducido: los cuatro sitios donde sale

El mensaje completo es `NG0203: inject() must be called from an injection context such as a constructor, a factory function, a field initializer, or a function used with runInInjectionContext`. Es de los errores más honestos que da Angular: dice el problema y la solución en la misma línea. Aun así, hay cuatro sitios donde aparece una y otra vez.

**1. Dentro de un hook del ciclo de vida.**

```ts
ngOnInit(): void {
  const router = inject(Router);   // ❌
}
```
El componente ya está construido. Sube la línea al cuerpo de la clase.

**2. Dentro de un callback de RxJS.**

```ts
return next(request).pipe(
  catchError(() => {
    const router = inject(Router);   // ❌ el callback corre mucho después
    return EMPTY;
  }),
);
```
Es el ejercicio 10 de la **Fase 2** y es el caso más común en interceptors. Inyecta arriba, usa la referencia dentro.

**3. En `takeUntilDestroyed()` sin argumento.**

```ts
ngOnInit(): void {
  this.templateState.templates$
    .pipe(takeUntilDestroyed())   // ❌ NG0203, y el mensaje no menciona takeUntilDestroyed
    .subscribe(/* … */);
}
```
Éste engaña porque el error no nombra al culpable. `takeUntilDestroyed()` sin argumento llama a `inject(DestroyRef)` por dentro, así que **sólo puede escribirse en el contexto de inyección** — típicamente en un inicializador de campo. Si lo necesitas más tarde, inyecta el `DestroyRef` arriba y pásaselo: `takeUntilDestroyed(this.destroyRef)`, que es exactamente lo que hace `ClientFormComponent` en la **Fase 6**.

**4. Dentro de una función suelta llamada desde un método.**

```ts
function buildHeaders(): HttpHeaders {
  const auth = inject(AuthService);   // ❌ si quien la llama ya no está en contexto
  return new HttpHeaders();
}
```
Una función auxiliar hereda el contexto de quien la llama: si la llamas desde un inicializador de campo, funciona; si la llamas desde un método, no. Que el mismo código funcione o falle según desde dónde se invoque es lo que hace este caso desagradable. La solución es pasar la dependencia como parámetro y dejar la función pura — que además la vuelve testeable sin `TestBed`, como las funciones de dominio de las Fases 7 a 9.

> 💡 **Cómo se depura en treinta segundos.** El stack trace de `NG0203` apunta al `inject()` que falló, no a la causa. Pon el breakpoint ahí, mira la pila hacia arriba, y busca el primer marco que **no** sea de Angular: ése es el sitio desde donde se llamó fuera de contexto. Nueve de cada diez veces es un `subscribe` o un hook.

---

## 🧭 Cuándo usar qué

| Situación | Forma | Por qué |
|---|---|---|
| Componente, servicio o directiva **nuevos** | `inject()` en campos | es el estilo del proyecto desde la Fase 5 |
| Fix de tres líneas en un archivo de 2021 | `constructor` | el parche se escribe en el estilo del archivo (guía §6.7) |
| Guard, interceptor o resolver funcional | `inject()` | no hay alternativa: no hay constructor |
| Clase base de la que heredan varios servicios | `inject()` | añadir una dependencia deja de tocar a las hijas |
| Necesitas un token con `@Inject(TOKEN)` | `inject(TOKEN)` | el token es un argumento normal, sin decorador |
| Código que corre después del arranque y necesita DI | `runInInjectionContext` con un inyector capturado | y sólo si de verdad no puedes inyectar arriba |
| Un archivo heredado al que hay que añadir **una** dependencia | `constructor`, junto a las que ya están | mezclar las dos formas en una clase es peor que cualquiera de ellas |

---

## ⚠️ Advertencias

- **Mezclar las dos formas en el mismo archivo es el único error de estilo que este apéndice llama error.** Las dos formas puras se leen bien; la mezcla obliga a recorrer la clase entera para saber de qué depende.
- **`inject()` en el inicializador de un campo que usa otro campo depende del orden de declaración.** Con constructor, el cuerpo corre cuando todos los parámetros existen; con campos, no. Si tienes que ordenar campos para que algo funcione, probablemente ese cálculo no debería estar en un inicializador.
- **Modernizar un archivo heredado "ya que estoy" es cómo se rompen otras tres cosas.** Convertir `AuthService` a `inject()` no arregla ningún bug, cambia el diff de un hotfix de tres líneas a treinta, y le quita a quien revise la posibilidad de ver qué cambió de verdad.

---

## 📚 Referencias

- https://v16.angular.io/api/core/inject — la firma de `inject()` y sus opciones, en la versión de este curso.
- https://v16.angular.io/guide/dependency-injection — la guía completa de DI, para lo que este apéndice deja fuera.
- https://v16.angular.io/errors/NG0203 — la página oficial del error, con la lista de contextos válidos.
- https://v16.angular.io/api/core/runInInjectionContext — la función de Angular 16 que sustituyó a `EnvironmentInjector.runInContext()`.
- https://v16.angular.io/api/router/CanActivateFn · https://v16.angular.io/api/common/http/HttpInterceptorFn · https://v16.angular.io/api/router/ResolveFn — las tres firmas funcionales.
- https://v16.angular.io/api/core/rxjs-interop/takeUntilDestroyed — incluida la nota sobre el `DestroyRef` explícito, que es el caso 3 de la §7.

> ⚠️ Cuidado con caer en https://angular.dev buscando `inject()`: documenta la 17 en adelante, y sus ejemplos combinan `inject()` con signals y control flow que en la 16 no existen o son experimentales. Para este curso, la referencia es siempre `v16.angular.io`.

**Orden de lectura sugerido:** la §1 y la §7 antes que nada — con esas dos ya no vuelves a pelearte con `NG0203`. La §2 cuando abras el primer archivo heredado y dudes de si tocarlo. La §3 sólo si te encuentras herencia, que en CertCore es poco frecuente y en un proyecto de verdad lo es mucho. La §5 la última, y ojalá no la necesites.

---

## 🧪 Ejercicios (8)

1. 🟢 Abre `core/auth.service.ts` y `core/state/template-state.service.ts`. Escribe en dos líneas cómo sabrías, sin mirar el historial de git, cuál de los dos se escribió en 2021 y cuál en 2024.

2. 🟢 En `authInterceptor`, mueve la línea `const router = inject(Router);` dentro del `catchError`. Provoca un 401 con el mock, anota el código de error exacto que sale en consola y el archivo y línea a los que apunta. Devuelve la línea a su sitio.

3. 🟡 Escribe un guard funcional `supervisorGuard` que sólo deje pasar si `AuthService` dice que el rol es `supervisor`, y devuelva un `UrlTree` a `/` si no. Después escribe el mismo guard en su forma heredada (clase con `implements CanActivate`) y registra los dos en rutas distintas. Compara los dos archivos y di cuál usarías hoy y por qué.

4. 🟡 Toma un componente cualquiera de la Fase 6 y añade `takeUntilDestroyed()` **sin argumento** dentro de `ngOnInit`. Anota el error. Después arréglalo de las dos formas posibles —mover el pipe a un inicializador de campo, o inyectar `DestroyRef` arriba y pasarlo— y explica en qué situación conviene cada una.

5. 🟠 Crea una clase base `BaseApiService` con `inject(HttpClient)` en un campo `protected`, haz que `ClientApiService` y `TemplateApiService` hereden de ella, y comprueba que ninguna de las dos necesita constructor. Después añade una segunda dependencia a la base y cuenta cuántos archivos tuviste que tocar. Repite el ejercicio mentalmente con la forma heredada y anota la diferencia.

6. 🟠 Inyecta un token inexistente con `inject(SOME_TOKEN)` y luego con `inject(SOME_TOKEN, { optional: true })`. Anota los dos comportamientos, el código de error del primero, y qué te obliga a escribir el segundo por culpa de `strict`.

7. 🔴 Provoca el caso 4 de la §7: escribe una función suelta que llame a `inject()`, llámala primero desde un inicializador de campo y después desde un método. Explica por qué el mismo código funciona en un sitio y no en el otro, y reescríbela como función pura que reciba la dependencia por parámetro. Argumenta en tres líneas por qué la versión pura es además la única que se puede testear sin `TestBed`.

8. 🔴 🧬 Te asignan un ticket: `CorrelationIdInterceptor` —clase, 2021— tiene que dejar de estampar la cabecera en las peticiones a `/auth/login`. Escribe el fix y justifica en un párrafo por qué **no** lo conviertes a `HttpInterceptorFn` mientras estás dentro, citando la regla del proyecto. Después escribe el párrafo contrario: qué tendría que pasar para que convertirlo sí fuera lo correcto.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y el código que explica lo escriben las fases, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 02: …`, `fase 05: …`). Si un ejercicio te deja código que quieres conservar —el `supervisorGuard` del 3, por ejemplo—, va con la forma `ej/a04/3`. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
APPENDIX_EOF
wc -l a04-inject-vs-constructor.md

# --- 2026-09-06T22:36:41 · Write A05
cat > a05-formularios-tipados.md <<'APPENDIX_EOF'
# 📎 Apéndice A05 — Formularios reactivos tipados

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: Fase 0, Fase 2, Fase 6, Fase 8, Fase 9 · Versión cubierta: Angular 16.2.12 — el tipado llegó en la 14

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve el problema que produce más tickets en CertCore después del versionado: **un formulario denso cuyo valor no es lo que tú creías que era**, casi siempre porque hay un `null` que nadie decidió o un control deshabilitado que desapareció del objeto sin avisar.

**Qué queda fuera:** los formularios por plantilla (`ngModel`, `FormsModule`). CertCore no tiene ni uno, por una razón que conviene decir aquí y no repetir: un formulario que se construye desde datos —que es lo que hace la **Fase 8** con las plantillas de checklist— no se puede declarar en el HTML, porque nadie sabe cuántos campos va a tener. Tampoco entran los componentes de formulario de Material (`mat-form-field`, `mat-select`, sus `appearance` y su densidad): eso es **A01**.

---

## Índice

- [1. `FormControl<T>` y el `| null` que nadie espera](#1-formcontrolt-y-el--null-que-nadie-espera)
- [2. `nonNullable: true`: qué cambia exactamente](#2-nonnullable-true-qué-cambia-exactamente)
- [3. `FormGroup<T>`: tipo explícito frente a inferencia](#3-formgroupt-tipo-explícito-frente-a-inferencia)
- [4. `FormRecord` y los controles que nacen en runtime](#4-formrecord-y-los-controles-que-nacen-en-runtime)
- [5. `FormArray` tipado](#5-formarray-tipado)
- [6. Validadores tipados, síncronos y asíncronos](#6-validadores-tipados-síncronos-y-asíncronos)
- [7. ⚠️ `value` frente a `getRawValue()`](#7-️-value-frente-a-getrawvalue)
- [8. Tipar un formulario que no se conoce en compilación](#8-tipar-un-formulario-que-no-se-conoce-en-compilación)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-9)

---

## 1. `FormControl<T>` y el `| null` que nadie espera

La primera sorpresa del tipado de formularios es que el tipo por defecto **no** es el que escribiste:

```ts
const legalName = new FormControl('');
// El tipo inferido es FormControl<string | null>, no FormControl<string>.
```

El `null` no es un descuido de Angular: es la consecuencia de una API que ya existía. `reset()` —sin argumentos, que es como lo llama todo el mundo— pone el control en `null`. Como el tipo tiene que describir todos los valores posibles del control a lo largo de su vida, y `null` es uno de ellos, ahí está.

Con `strict: true` puesto eso se convierte inmediatamente en trabajo:

```ts
// El compilador no te deja olvidarlo, y ésa es la gracia.
const value = legalName.value;        // string | null
const trimmed = value.trim();         // ❌ Object is possibly 'null'
```

Hay tres formas de responder a ese error y sólo dos son aceptables:

- **Decidir que el control nunca es nulo** → `nonNullable: true` (§2). Es lo que hace CertCore en el 90% de los casos.
- **Decidir que `null` significa algo** → dejarlo, y tratar el caso. `validUntil: FormControl<string | null>` donde `null` es "vigente indefinidamente" es un tipo que dice la verdad.
- **Taparlo con `!` o con `as string`** → no. La guía §6.4 lo prohíbe, y el motivo no es purismo: una familia entera de bugs del curso —el hallazgo que no bloquea, el certificado sin fecha— nace exactamente de la diferencia entre `null`, `undefined` y "campo ausente".

> 🧭 **Regla del proyecto (Fase 6).** La nulabilidad de un control se decide al escribirlo, no al usarlo. Si el campo siempre tiene un valor —aunque sea la cadena vacía—, va `nonNullable: true`. Si `null` significa algo de verdad, va sin él y el tipo lo dice. Lo que no se admite es un `| null` heredado de la migración que nadie decidió.

---

## 2. `nonNullable: true`: qué cambia exactamente

```ts
const legalName = new FormControl('', { nonNullable: true });
// FormControl<string>. El .value es string, sin uniones.
```

Cambian dos cosas, y la segunda es la que la gente descubre tarde:

**El tipo.** `value` pasa a ser `string`, y todo lo que se construye encima deja de arrastrar guardas.

**El comportamiento de `reset()`.** Un control `nonNullable` vuelve a **su valor inicial** —el que le diste al crearlo— en vez de a `null`. Que es, casualmente, lo que un usuario espera de un botón que dice "Limpiar": el formulario vuelve a como estaba, no se queda en un estado que no existía.

```ts
const withNull = new FormControl('Edificio Central');
const withoutNull = new FormControl('Edificio Central', { nonNullable: true });

withNull.reset();      // value === null
withoutNull.reset();   // value === 'Edificio Central'
```

> ⚠️ **`nonNullable` no es una validación.** No impide que el campo esté vacío: `''` es un `string` perfectamente válido. Quien exige contenido es `Validators.required`. Confundirlos produce el formulario que compila, tipa bien y se guarda vacío.

**La forma con `FormBuilder`.** Si prefieres el builder, `fb.nonNullable` es un builder entero cuyos controles nacen no nulos, y evita repetir la opción en cada línea:

```ts
private readonly fb = inject(FormBuilder);

// Cada control lleva su opción. Explícito y ruidoso.
readonly form = this.fb.group({
  legalName: this.fb.control('', { nonNullable: true, validators: [Validators.required] }),
  taxId: this.fb.control('', { nonNullable: true }),
});

// El mismo formulario, con el builder no nulo. Menos ruido, misma semántica.
readonly form2 = this.fb.nonNullable.group({
  legalName: ['', [Validators.required]],
  taxId: [''],
});
```

> 📝 **Nota de migración.** Los formularios genéricos llegaron en Angular **14**, y con ellos `nonNullable`, `FormRecord` y `NonNullableFormBuilder`. Antes existía `initialValueIsDefault: true`, que hacía la mitad —el `reset()`— y no tocaba el tipo, porque no había tipo. Si en un proyecto heredado ves `initialValueIsDefault`, estás mirando código anterior a la 14: es el mismo comportamiento con el nombre viejo, y `nonNullable` lo sustituyó. En CertCore no aparece: la migración de 2024 pasó por encima de esa era.

---

## 3. `FormGroup<T>`: tipo explícito frente a inferencia

Hay dos maneras de tipar un grupo, y en este curso conviven a propósito.

**La explícita.** Se escribe una interfaz cuyos campos son `FormControl`s, y se la pasas al `FormGroup`. Es lo que hace la **Fase 6** con `ClientForm` y la **Fase 8** con `AnswerForm`.

```ts
interface ClientForm {
  legalName: FormControl<string>;
  taxId: FormControl<string>;
}

readonly form = new FormGroup<ClientForm>({
  legalName: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
  taxId: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
});
```

Cuesta cuatro líneas más y compra tres cosas: el tipo tiene nombre y se puede exportar, `setValue` falla en compilación si mañana alguien añade un campo y olvida rellenarlo, y el error del compilador apunta a la interfaz en vez de a un objeto literal de veinte líneas.

**La inferida.** `FormBuilder.group({...})` deduce el tipo del objeto que le pasas. Es más corta y perfectamente válida para un formulario de tres campos que no sale de su componente.

```ts
readonly form = this.fb.nonNullable.group({
  legalName: ['', [Validators.required]],
  taxId: ['', [Validators.required]],
});
// El tipo existe, pero no tiene nombre: es un FormGroup<{...}> anónimo.
```

> 🧭 **Regla práctica.** Si el tipo del formulario tiene que viajar —a una función, a un servicio, a un test—, escríbelo explícito y dale nombre. Si vive y muere dentro del componente, infiérelo. La **Fase 8** es el caso extremo del primero: `InspectionForm` es un tipo exportado que usan tres archivos y una suite de tests.

**Lo que NO puedes hacer con un `FormGroup<T>` tipado**, y es la limitación que lleva directo a la §4:

```ts
form.addControl('phone', new FormControl(''));
// ❌ El compilador se queja: 'phone' no está en ClientForm.
```

Y hace bien. Un `FormGroup<T>` promete exactamente esas claves; si pudieras añadir cualquiera, el tipo sería una sugerencia. Cuando de verdad no sabes las claves, el tipo correcto es otro.

---

## 4. `FormRecord` y los controles que nacen en runtime

`FormRecord<T>` es un `FormGroup` cuyas **claves se conocen en runtime** y cuyos controles son **todos del mismo tipo `T`**. Es la respuesta oficial al `FormGroup` con `any` que antes de la 14 escribía todo el mundo.

```ts
// El tipo del formulario de una inspección, de la Fase 8.
export type InspectionForm = FormRecord<FormGroup<AnswerForm>>;

const form: InspectionForm = new FormRecord<FormGroup<AnswerForm>>({});

for (const item of template.items) {
  form.addControl(item.id, buildItemGroup(item, /* … */));   // ✅ aquí sí
}
```

Lo que ganas: `getRawValue()` devuelve un `Record<string, { answer: string; evidenceUrl: string | null; note: string | null }>`. El compilador no sabe qué claves habrá —nadie puede saberlo— pero sabe exactamente qué hay dentro de cada una. Es todo el tipado que la situación admite, y es mucho más del que parece.

Su API útil, en cuatro líneas:

```ts
form.addControl(itemId, group);      // añade; si la clave existe, no hace nada
form.setControl(itemId, group);      // añade o REEMPLAZA
form.removeControl(itemId);          // quita
form.contains(itemId);               // ¿existe y está habilitado?
```

> ⚠️ **`contains()` devuelve `false` para un control deshabilitado.** Es la respuesta a "¿este control participa en el valor?", no a "¿este control existe?". Si lo que quieres saber es lo segundo, la pregunta es `form.get(itemId) !== null`. Confundirlos produce el control huérfano que la **Fase 8** caza en su pieza forense.

> 🧭 **Regla del proyecto (Fase 8): la clave es el `itemId`, nunca la posición.** Con `FormArray` indexado por posición, reordenar los ítems de una plantilla en una v3 desplazaría las respuestas de todo el mundo. Con `FormRecord` y el `itemId` como clave, no hay nada que desplazar — y además la diferencia entre las claves del formulario y los ítems de la plantilla delata en una línea las respuestas huérfanas de un ítem retirado.

---

## 5. `FormArray` tipado

`FormArray<T>` es la estructura correcta cuando **el orden es el dato** y los elementos no tienen identidad propia: una lista de teléfonos de contacto, un conjunto de rangos de fechas, las filas de un detalle que el usuario añade y quita.

```ts
interface AssetForm {
  code: FormControl<string>;
  tags: FormArray<FormControl<string>>;
}

const form = new FormGroup<AssetForm>({
  code: new FormControl('', { nonNullable: true }),
  tags: new FormArray<FormControl<string>>([]),
});

form.controls.tags.push(new FormControl('elevator', { nonNullable: true }));
form.controls.tags.removeAt(0);
form.controls.tags.at(0)?.value;    // string | undefined — `at` puede no encontrar nada
```

En la plantilla hay una trampa que cuesta media tarde la primera vez:

```html
<!-- El índice del *ngFor no basta: formGroupName / formControlName necesitan
     el índice como cadena, y el control tiene que existir ANTES de pintarse. -->
<div formArrayName="tags">
  <input *ngFor="let control of form.controls.tags.controls; let i = index"
         [formControlName]="i" />
</div>
```

> 💡 **`FormArray` frente a `FormRecord`, en una línea.** Si puedes reordenar los elementos sin que cambie su significado, `FormArray`. Si cada elemento tiene una identidad que sobrevive al orden —un `itemId`, un `assetId`—, `FormRecord`. CertCore usa `FormRecord` en la pieza central por esa razón exacta.

---

## 6. Validadores tipados, síncronos y asíncronos

Un validador es una función que recibe un `AbstractControl` y devuelve `ValidationErrors | null`. Y aquí llega la parte que sorprende: **el `AbstractControl` que recibe NO está tipado**. Su `value` es `any`, porque el mismo validador tiene que poder aplicarse a un control, a un grupo o a un array.

```ts
/** La respuesta tiene que ser uno de los criterios del ítem. */
export function oneOfValidator(allowed: readonly string[]): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    // El valor llega sin tipar: se recibe como `unknown` y se estrecha.
    // Es la regla del proyecto desde la Fase 6, y aquí es donde más se nota.
    const value: unknown = control.value;

    if (typeof value !== 'string' || value === '') {
      // Vacío no es inválido por ESTE validador: de eso se ocupa `required`.
      // Dos errores a la vez producen dos mensajes, y el usuario lee el que no sirve.
      return null;
    }

    return allowed.includes(value) ? null : { notAllowed: { value, allowed } };
  };
}
```

**Detalles con intención**

- **`const value: unknown = control.value`** es la línea que convierte un `any` en algo con lo que `strict` puede trabajar. Sin ella, el resto del validador está tipado sobre arena.
- **Un validador hace una sola pregunta.** El de arriba no comprueba si está vacío; eso es `required`. Un validador que comprueba tres cosas devuelve tres claves de error y produce un mensaje que nadie sabe redactar.
- **El objeto de error lleva datos, no texto.** `{ notAllowed: { value, allowed } }` deja que la plantilla componga el mensaje en español. Un validador que devuelve `{ error: 'El valor no es válido' }` mezcla dominio con interfaz.

**Los asíncronos** viven en su propio parámetro, y tienen tres reglas que se olvidan las tres:

```ts
export function uniqueTaxIdValidator(
  clientApi: ClientApiService,
  currentClientId: number | null,
): AsyncValidatorFn {
  return (control: AbstractControl): Observable<ValidationErrors | null> => {
    const value: unknown = control.value;

    if (typeof value !== 'string' || value === '') {
      return of(null);
    }

    // 1. ESPERAR. Sin esto, una petición por tecla.
    return timer(400).pipe(
      switchMap(() => clientApi.findByTaxId(value)),
      map((found) =>
        found === null || found.id === currentClientId ? null : { taxIdTaken: true },
      ),
      // 2. NO INVALIDAR POR UN FALLO DE RED. Si el servidor no responde, el
      //    usuario no tiene la culpa: el error saldrá al guardar, que es donde
      //    sí se puede explicar.
      catchError(() => of(null)),
      // 3. COMPLETAR. Si no completa, el control se queda `pending` para
      //    siempre y el formulario nunca llega a ser válido.
      first(),
    );
  };
}
```

> ⚠️ **`pending` no es `invalid`.** Mientras un validador asíncrono está en vuelo, el control está `pending` y `form.invalid` es **`false`**. Un botón que sólo mira `[disabled]="form.invalid"` deja pasar el clic durante ese rato, y guarda un valor que iba a resultar inválido. La comprobación correcta es `if (this.form.invalid || this.form.pending)`, y es literalmente el bug más caro de la pantalla de clientes de la **Fase 6**.

---

## 7. ⚠️ `value` frente a `getRawValue()`

Ésta es la sección que justifica sola el apéndice.

```ts
const form = new FormGroup<ClientForm>({
  legalName: new FormControl('Edificio Central', { nonNullable: true }),
  taxId: new FormControl('900123456', { nonNullable: true }),
});

form.controls.taxId.disable();

form.value;         // { legalName: 'Edificio Central' }   ← taxId NO está
form.getRawValue(); // { legalName: 'Edificio Central', taxId: '900123456' }
```

**Un control deshabilitado desaparece de `value`.** No vale `null`, no vale `undefined`: no está la clave. Y el tipo lo dice, aunque nadie lo lea: el tipo de `value` en un `FormGroup<T>` es `Partial<…>`, precisamente porque cualquier control puede estar deshabilitado en cualquier momento.

Por qué es el bug más silencioso del tema:

1. Funciona durante meses, porque en la pantalla nadie deshabilita nada.
2. Llega un ticket normal: *"el NIT no se debe poder editar cuando el cliente ya tiene certificados emitidos"*. Alguien añade un `disable()` de dos líneas, que es exactamente el arreglo correcto.
3. A partir de ese día, guardar un cliente manda un `PATCH` **sin `taxId`**. Con `json-server` y con casi cualquier backend REST, eso significa "no lo cambies", así que no pasa nada visible.
4. Hasta que otro endpoint interpreta el campo ausente como "ponlo a nulo", y entonces se pierde el NIT de los clientes que alguien editó. Y el commit que lo rompió es un `disable()` de dos líneas que revisaron tres personas.

> 🧭 **Regla del proyecto: para construir el objeto que se envía, siempre `getRawValue()`.** `value` sirve para pintar y para decidir en pantalla; `getRawValue()` es lo que se manda al servidor. Es la misma familia de decisión que la de la **Fase 10** con el PDF: *el documento se arma desde la fuente del dato, nunca desde lo que hay pintado.*

Con `nonNullable` en todos los controles y `getRawValue()`, el objeto que sale del formulario tiene exactamente el tipo que declaraste, sin `Partial`, sin uniones con `null` y sin una sola guarda. Ésa es la recompensa completa del tipado, y llega justo en la línea donde importa.

---

## 8. Tipar un formulario que no se conoce en compilación

Es la situación de la **Fase 8** y la razón por la que este apéndice existe. El resumen del método, en cuatro decisiones:

**Uno — separa lo que sí sabes de lo que no.** No sabes cuántos ítems tendrá la plantilla; sí sabes qué campos tiene la respuesta a un ítem. Lo segundo se tipa con una interfaz (`AnswerForm`); lo primero, con `FormRecord`.

**Dos — que la construcción sea una función pura.** Recibe los datos, devuelve el formulario. No inyecta, no pide, no sabe qué pantalla la llamó:

```ts
export function buildAnswerForm(
  template: ChecklistTemplate,
  answers: readonly InspectionAnswer[],
): InspectionForm { /* … */ }
```

Eso la vuelve testeable sin `TestBed` —la **Fase 12** la prueba así— y elimina de golpe la clase de bug en la que el formulario depende de en qué orden pasaron las cosas.

**Tres — que los validadores salgan del dato, no de la pantalla.** `photoRequired: true` en la plantilla se convierte en `Validators.required` sobre `evidenceUrl`. Cambiar ese booleano en una v3 cambia la validación sin tocar una línea de código. Eso es lo que significa "derivado de la plantilla", y es lo que hace que el motor de plantillas sea un motor y no una configuración.

**Cuatro — que el camino de vuelta también sea una función.** Del formulario al modelo del dominio, con su propia decisión explícita sobre qué no viaja:

```ts
export function toAnswers(form: InspectionForm): readonly InspectionAnswer[] {
  return Object.entries(form.getRawValue())     // getRawValue, siempre (§7)
    .filter(([, value]) => value.answer !== '')  // lo no respondido no viaja
    .map(([itemId, value]) => ({ itemId, answer: value.answer, evidenceUrl: value.evidenceUrl, note: value.note }));
}
```

> 🧠 **El patrón a memorizar.** Un formulario dinámico bien hecho es una **función pura de sus datos**: misma plantilla y mismas respuestas, mismo formulario. En cuanto necesita saber en qué pantalla está o qué había antes, deja de poderse testear y empieza a acumular bugs de estado.

---

## 🧭 Cuándo usar qué

| Situación | Estructura | Por qué |
|---|---|---|
| Campos fijos, conocidos al escribir | `FormGroup<T>` con interfaz | el tipo tiene nombre y `setValue` te protege |
| Formulario chico que no sale del componente | `fb.nonNullable.group({...})` | la inferencia basta y se lee mejor |
| Claves decididas en runtime, mismo tipo de control | `FormRecord<T>` | es literalmente para esto |
| Lista ordenada, elementos sin identidad | `FormArray<T>` | el orden es el dato |
| El campo siempre tiene valor | `nonNullable: true` | el tipo deja de arrastrar `null` y `reset()` hace lo esperable |
| `null` significa algo del dominio | sin `nonNullable`, y documentarlo | "vigente indefinidamente" es un valor, no un olvido |
| Construir el objeto que se envía | `getRawValue()` | los deshabilitados también son parte del dato |
| Decidir qué pintar en pantalla | `value` | ahí sí quieres saber qué participa |
| Comprobar antes de guardar | `form.invalid \|\| form.pending` | `pending` no es `invalid`, y ahí se cuela el bug |

---

## ⚠️ Advertencias

- **Casi todos los ejemplos que hay en internet son anteriores a Angular 14** y no compilan aquí. Se reconocen a simple vista: `new FormGroup({...})` sin genérico, `this.fb.group({...})` con `Validators` en un array posicional y un `any` en el `subscribe` del `valueChanges`. No están "mal": están fechados, y traducirlos es exactamente el ejercicio 2.
- **`setValue` frente a `patchValue`.** `setValue` exige el objeto completo y falla en compilación si mañana se añade un campo y alguien olvida rellenarlo; `patchValue` lo dejaría vacío en silencio. En CertCore, `setValue` por defecto y `patchValue` sólo cuando de verdad quieres tocar una parte.
- **`disable()` y `enable()` disparan `valueChanges`** salvo que les pases `{ emitEvent: false }`. En una pantalla con autosave —la de la **Fase 8**— eso significa un guardado que nadie pidió, disparado por deshabilitar un campo.
- **Un `FormControl<Date>` es casi siempre una mala idea.** El dominio de CertCore guarda fechas como cadenas ISO con offset explícito (**Fase 7** y **Fase 10**), y meter un `Date` en el formulario introduce una conversión de zona horaria en el punto exacto donde menos la quieres.

---

## 📚 Referencias

- https://v16.angular.io/guide/typed-forms — la guía oficial de formularios tipados. Es corta, es buena, y es la referencia exacta de esta versión.
- https://v16.angular.io/api/forms/FormControl — incluida la firma de `nonNullable` y la nota sobre `reset()`.
- https://v16.angular.io/api/forms/FormRecord · https://v16.angular.io/api/forms/FormArray · https://v16.angular.io/api/forms/FormGroup — las tres estructuras, con sus métodos.
- https://v16.angular.io/api/forms/AbstractControl#getRawValue — el método de la §7, con la frase clave sobre los controles deshabilitados.
- https://v16.angular.io/api/forms/NonNullableFormBuilder — el `fb.nonNullable` de la §2.
- https://v16.angular.io/guide/form-validation — validadores síncronos y asíncronos, y el estado `pending`.

> ⚠️ La documentación en https://angular.dev cubre la 17 en adelante y mezcla los formularios con signals (`toSignal`, `linkedSignal` en versiones posteriores). Nada de eso existe aquí. Para este curso, `v16.angular.io`.

**Orden de lectura sugerido:** §1 y §2 antes de la Fase 6, que es donde escribes tu primer formulario tipado de verdad. La §7 **antes** de que te toque un ticket con un `disable()` dentro, no después. La §4 y la §8 cuando abras la Fase 8, y no antes: fuera del contexto del formulario dinámico se leen como abstracción. La §6 el día que un validador asíncrono te deje el formulario colgado en `pending`.

---

## 🧪 Ejercicios (9)

1. 🟢 Crea `new FormControl('')` y `new FormControl('', { nonNullable: true })`, pásale el ratón por encima a cada uno en el editor y anota los dos tipos inferidos. Después llama a `reset()` en los dos e imprime los valores.

2. 🟢 Toma este fragmento pre-14 y tradúcelo al estilo del proyecto, explicando cada cambio: `this.form = this.fb.group({ name: ['', Validators.required], email: [''] });`

3. 🟢 En `ClientFormComponent` (Fase 6), quita el `nonNullable: true` de `legalName` y anota todos los errores de compilación que aparecen. Devuélvelo y cuenta cuántas guardas te ahorró esa palabra.

4. 🟡 Reproduce el bug de la §7 de punta a punta: deshabilita `taxId` en el formulario de clientes, guarda un cliente con el mock corriendo, y mira en la pestaña Network qué se envió exactamente. Después arréglalo con `getRawValue()` y verifica la diferencia en el payload.

5. 🟡 Escribe un validador `notInFutureValidator` para una fecha ISO que devuelva `{ inFuture: { value } }` si la fecha es posterior a hoy. Aplícalo al campo de fecha de una inspección y comprueba que **no** se queja cuando el control está vacío.

6. 🟡 Convierte el formulario de clientes de la forma explícita (`FormGroup<ClientForm>`) a la inferida (`fb.nonNullable.group`). Compara los dos archivos y argumenta en cuatro líneas cuál dejarías, sabiendo que `ClientForm` no se exporta a ningún sitio.

7. 🟠 Construye un `FormRecord<FormControl<string>>` con tres claves, deshabilita una, y compara `value`, `getRawValue()` y `contains()` sobre esa clave. Escribe la frase de una línea que explique la diferencia entre las tres respuestas.

8. 🟠 En la pantalla de inspección de la Fase 8, añade un `disable()` a un control dentro del `subscribe` del autosave y observa cuántas peticiones salen. Después añade `{ emitEvent: false }` y vuelve a medir. Explica qué pasó con la advertencia de la §"Advertencias" en la mano.

9. 🔴 Escribe desde cero una función pura `buildAssetForm(assetType: AssetType): FormGroup<AssetForm>` que construya un formulario distinto según el tipo de activo —un ascensor pide número de paradas, una caldera pide presión máxima— usando `FormRecord` para los campos variables y `FormGroup<T>` para los fijos. Escribe además su función inversa. Los dos tienen que poder testearse sin `TestBed`, y ése es el criterio de éxito: si necesitas `TestBed`, la función no es pura y hay que rehacerla.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y los formularios que explica los escriben las Fases 6, 8 y 9, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 06: …`, `fase 08: …`). Si el ejercicio 9 te deja código que quieres conservar, va con la forma `ej/a05/9`. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
APPENDIX_EOF
wc -l a05-formularios-tipados.md

# --- 2026-09-06T22:39:47 · Write A06
cat > a06-rxjs.md <<'APPENDIX_EOF'
# 📎 Apéndice A06 — RxJS 7 idiomático

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: Fase 2, Fase 3, Fase 4, Fase 8, Fase 11 · Versión cubierta: RxJS 7.8.1

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve una pregunta muy concreta: **cuál de los ocho operadores que CertCore usa de verdad toca aquí, y qué antipatrón produce cada uno cuando se elige mal.**

RxJS tiene más de cien operadores y este apéndice cubre ocho. No es una simplificación pedagógica: son los que aparecen en el código del curso, y son los que aparecen en la inmensa mayoría de las aplicaciones Angular de producción. Si algún día necesitas el noveno, lo vas a saber, y para entonces tendrás el modelo mental para leer su documentación.

**Qué queda fuera:** marble testing y `TestScheduler` (la **Fase 12** testea el tiempo de otra forma, más simple y suficiente), los schedulers y todo lo relacionado con `observeOn`/`subscribeOn`, la creación de operadores propios, `WebSocket` y multiplexación, y los operadores de backpressure. Nada de eso está en CertCore.

---

## Índice

- [1. El modelo mental mínimo](#1-el-modelo-mental-mínimo)
- [2. `map`, y por qué casi todo empieza ahí](#2-map-y-por-qué-casi-todo-empieza-ahí)
- [3. `switchMap`, `mergeMap` y `concatMap`](#3-switchmap-mergemap-y-concatmap)
- [4. `combineLatest` y la trampa del primer valor](#4-combinelatest-y-la-trampa-del-primer-valor)
- [5. `debounceTime` + `distinctUntilChanged`](#5-debouncetime--distinctuntilchanged)
- [6. `catchError`: qué devolver, y dónde ponerlo](#6-catcherror-qué-devolver-y-dónde-ponerlo)
- [7. `shareReplay`, con y sin `refCount`](#7-sharereplay-con-y-sin-refcount)
- [8. 🧬 Las tres formas de desuscribirse](#8--las-tres-formas-de-desuscribirse)
- [9. `async` pipe frente a `.subscribe()`](#9-async-pipe-frente-a-subscribe)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-9)

---

## 1. El modelo mental mínimo

Tres preguntas responden por casi cualquier observable que te encuentres en CertCore. Vale la pena hacérselas explícitamente las primeras veces, hasta que salgan solas.

**¿Quién dispara el trabajo?** Un observable **frío** hace su trabajo *por cada suscripción*. El de `HttpClient` es el ejemplo canónico: tres suscripciones son tres peticiones HTTP. Un observable **caliente** ya está corriendo y los suscriptores se enganchan a lo que hay: un `BehaviorSubject` es caliente y además guarda el último valor, que es por lo que sirve como estado.

```ts
const templates$ = this.http.get<ChecklistTemplate[]>('/templates');   // FRÍO
templates$.subscribe();   // petición 1
templates$.subscribe();   // petición 2. No es un bug de nadie: es la definición.

readonly state$ = this.stateSubject.asObservable();   // CALIENTE
```

**¿Completa?** Un observable de `HttpClient` emite una vez y completa: no queda nada abierto, y por eso la **Fase 4** se suscribe a él sin desuscribirse y está bien. Un `BehaviorSubject` **no completa nunca**: quien se suscriba se queda suscrito hasta que alguien lo corte. Ahí es donde viven todas las fugas del curso.

**¿Quién cancela?** Si alguien puede pedir dos veces lo mismo antes de que llegue la primera respuesta, alguien tiene que decidir qué pasa con la primera. Ésa es toda la §3.

> 🧠 **Qué es una fuga, exactamente** (Fase 4). No es "una suscripción sin cerrar": es **una suscripción que sobrevive a quien la creó**. Un componente que se suscribe a un servicio raíz y se destruye sin cortar deja un zombi reaccionando a cada emisión, y diez navegaciones dejan diez. Un servicio raíz suscrito a otro servicio raíz no es una fuga: nadie sobrevive a nadie.

> 📝 **Nota de migración: RxJS 6 → 7.** Tres diferencias que hacen que un ejemplo de internet no compile aquí. **Los imports:** en RxJS 7 todos los operadores salen de `'rxjs'`; el `'rxjs/operators'` de la 6 sigue funcionando pero está en desuso, y verlo es la señal más rápida de que un artículo es viejo. **`toPromise()` está deprecado** y se sustituye por `firstValueFrom()` o `lastValueFrom()`, que además obligan a decidir cuál de los dos querías —`toPromise()` devolvía el último valor y `undefined` si no había ninguno, que es de las peores decisiones de diseño que ha tenido esta librería—. Y **`combineLatest` con argumentos sueltos** (`combineLatest(a$, b$)`) desapareció: ahora es siempre un array. CertCore nació en 2021 con RxJS 6; la migración de 2024 los actualizó todos, así que en el repositorio no queda ninguno — pero en el tuyo sí.

---

## 2. `map`, y por qué casi todo empieza ahí

`map` transforma cada valor sin tocar nada más. Es el operador que menos explicación necesita y el que más trabajo hace, y en CertCore aparece sobre todo en un sitio: **derivar estado sin duplicarlo**.

```ts
// TemplateStateService, Fase 4. Un solo BehaviorSubject, cinco vistas de él.
readonly templates$ = this.state$.pipe(map((state) => state.items), distinctUntilChanged());
readonly loading$   = this.state$.pipe(map((state) => state.loading), distinctUntilChanged());
```

El `distinctUntilChanged` que va detrás no es adorno: sin él, un cambio en `loading` hace emitir a `templates$` con el mismo array de siempre, y quien esté pintando con `OnPush` se despierta para nada. Con él, cada derivado sólo emite cuando su parte cambió.

> 🧭 **Regla del proyecto (Fases 4, 9, 10 y 11): lo que se puede calcular no se guarda.** Un dato guardado que también se puede derivar son dos fuentes de verdad que se van a desincronizar — y en un sistema cuyo dominio es la trazabilidad, eso no es un detalle. El `map` es la herramienta con la que se cumple esa regla.

**El antipatrón:** un `map` con efectos dentro. Si tu `map` navega, guarda, abre un diálogo o hace `console.log` de algo que importa, no es un `map`: es un `tap` mal puesto, o es lógica que debería estar en el `subscribe`. Un `map` que no es puro convierte cada suscripción extra en un efecto extra, y con un `async` pipe de más te encuentras guardando dos veces.

---

## 3. `switchMap`, `mergeMap` y `concatMap`

Los tres hacen lo mismo —por cada valor que entra, lanzan un observable nuevo y aplanan el resultado— y se diferencian **sólo** en qué hacen con el anterior cuando todavía está en vuelo. Elegir mal no da error: da un bug intermitente que sólo aparece con latencia, que es exactamente por lo que la **Fase 3** construye el inyector de caos.

| Operador | Con el anterior en vuelo… | El caso que lo pide |
|---|---|---|
| `switchMap` | lo **cancela** y se queda con el nuevo | buscar mientras se escribe, reaccionar a un cambio de ruta |
| `mergeMap` | lo **deja correr**, en paralelo | operaciones independientes donde el orden da igual |
| `concatMap` | lo **encola**, uno detrás de otro | escrituras que tienen que llegar en orden |

```ts
// switchMap — el parámetro de ruta cambia: la petición anterior ya no interesa.
readonly inspection$ = this.route.paramMap.pipe(
  map((params) => params.get('inspectionId') ?? ''),
  switchMap((inspectionId) => this.inspectionApi.getById(inspectionId)),
);
```

Si el inspector navega rápido entre dos inspecciones, `switchMap` **aborta** la petición HTTP anterior —de verdad: aparece como `canceled` en la pestaña Network— y sólo llega la buena. Con `mergeMap`, las dos peticiones vuelven, y pinta **la que llegue última**, que no tiene por qué ser la que pediste al final. Es el bug de "se me quedó la inspección de antes" y es imposible de reproducir en local con el mock respondiendo en dos milisegundos.

```ts
// concatMap — el orden ES el dato. Dos PATCH de la misma inspección no pueden
// cruzarse: el segundo tiene que salir cuando el primero haya vuelto.
this.saveRequests$.pipe(
  concatMap((answers) => this.inspectionApi.saveAnswers(inspectionId, answers)),
).subscribe();
```

> 💡 **El cuarto, que CertCore no usa y conviene conocer.** `exhaustMap` **ignora** lo nuevo mientras hay algo en vuelo: es la respuesta natural al doble clic en "Guardar". CertCore lo resuelve con una bandera `submitting` en el componente (Fase 6), que es más explícita para quien lee la pantalla y no requiere entender un cuarto operador. Las dos soluciones son correctas; si te encuentras `exhaustMap` en un proyecto ajeno, es esto.

**Los tres antipatrones:**

- **`subscribe` dentro de `subscribe`.** Es la forma manual de `mergeMap`, sin cancelación, sin manejo de errores y sin nada que se pueda desuscribir de golpe. Si ves uno, la traducción es directa: el interior se convierte en `switchMap` o en `concatMap` según lo que quieras que pase con el anterior.
- **`mergeMap` por defecto** porque es el que sale primero al buscar "flatten observable". Es el único de los tres que no da ninguna garantía, y por eso es el peor valor por defecto.
- **`switchMap` sobre una escritura.** Cancelar un `GET` es gratis; cancelar un `PATCH` que ya salió no cancela nada en el servidor, sólo te deja sin saber si llegó. Para escrituras, `concatMap`.

---

## 4. `combineLatest` y la trampa del primer valor

`combineLatest` toma varios observables y emite un array con el último valor de cada uno, cada vez que cualquiera emite. Es la herramienta con la que se cruzan dos partes del estado sin guardarlas juntas.

```ts
// Fase 11: el dashboard cruza certificados con clientes sin guardar el cruce.
readonly expiringByClient$ = combineLatest([
  this.certificateState.certificates$,
  this.clientState.clients$,
]).pipe(
  map(([certificates, clients]) => groupExpiringByClient(certificates, clients)),
);
```

**La trampa:** `combineLatest` **no emite absolutamente nada hasta que cada una de sus fuentes haya emitido al menos una vez**. Si una de las cinco todavía no ha emitido, la pantalla se queda en blanco, sin error, sin nada en consola, y sin ninguna pista de cuál de las cinco es la que falta.

Con `BehaviorSubject` no pasa, porque siempre tiene un valor desde el momento en que se crea — y ésa es una de las razones de peso por las que el patrón de estado de CertCore usa `BehaviorSubject` y no `Subject`. Pasa cuando metes en el `combineLatest` un `Subject` normal, un `EventEmitter`, o un observable de `HttpClient` que todavía no ha vuelto.

**Cómo se depura en un minuto:** un `tap` con etiqueta en cada fuente, antes del `combineLatest`. La que no imprima nada es la culpable.

```ts
combineLatest([
  this.a$.pipe(tap((v) => console.log('a', v))),
  this.b$.pipe(tap((v) => console.log('b', v))),   // si esto no imprime, aquí está
])
```

**El antipatrón:** `combineLatest` sobre fuentes que cambian a la vez. Si `a$` y `b$` se actualizan los dos como consecuencia de la misma acción, `combineLatest` emite **dos veces**: una con `a` nuevo y `b` viejo, y otra con los dos nuevos. Esa emisión intermedia es un estado que nunca existió, y si tiene efectos —guardar, navegar— los tiene sobre datos inconsistentes. La solución en CertCore es la de la Fase 4: **un solo objeto de estado** del que salen los derivados, en vez de varios sujetos que hay que recombinar.

---

## 5. `debounceTime` + `distinctUntilChanged`

Van juntos y en ese orden. `debounceTime(ms)` espera a que pare de llegar; `distinctUntilChanged` descarta lo que es igual a lo anterior.

```ts
// Fase 8: el autosave de una inspección en curso.
this.form.valueChanges.pipe(
  debounceTime(1500),
  map(() => toAnswers(this.form)),
  distinctUntilChanged((a, b) => serializeAnswers(a) === serializeAnswers(b)),
  concatMap((answers) => this.inspectionApi.saveAnswers(this.inspectionId, answers)),
  takeUntilDestroyed(this.destroyRef),
).subscribe();
```

**Por qué ese orden.** Con `distinctUntilChanged` delante, filtras teclas que igualmente iban a colapsarse en el debounce: gastas comparaciones para nada. Con el debounce delante, comparas una vez por pausa. Además, sin el `distinct` detrás, un `valueChanges` que emite por un `markAsTouched` o por un `disable()` te dispara un guardado con un valor idéntico al anterior.

**El comparador importa.** `distinctUntilChanged` sin argumento compara con `===`, y dos objetos con el mismo contenido nunca son `===`. Sobre un array de respuestas hace falta un comparador explícito, y en CertCore es una serialización a JSON: es O(n) sobre decenas de elementos, corre como mucho una vez cada segundo y medio, y es bastante más difícil de romper que una comparación profunda escrita a mano.

**Los antipatrones:**

- **Debounce sin `distinct`** — guardas lo mismo dos veces y no lo notas hasta que el log del servidor tiene el doble de líneas.
- **`distinct` sin comparador sobre objetos** — no filtra nada y parece que sí, que es el peor de los dos mundos.
- **Debounce en un validador asíncrono puesto con `subscribe` en vez de con `timer`** — ver **A05** §6: el validador tiene que devolver un observable que complete, y un `debounceTime` sobre un observable de un solo valor no espera nada.

---

## 6. `catchError`: qué devolver, y dónde ponerlo

`catchError` recibe el error y **tiene que devolver un observable nuevo**. Lo que devuelvas decide qué pasa con el flujo, y ésa es la parte que todo el mundo contesta mal la primera vez.

```ts
// Opción A — devolver un valor por defecto: el flujo CONTINÚA y COMPLETA.
catchError(() => of([]))

// Opción B — relanzar: el flujo muere y el error llega a quien se suscribió.
catchError((error: unknown) => throwError(() => error))

// Opción C — tragárselo en silencio: el flujo COMPLETA sin decir nada.
catchError(() => EMPTY)
```

La regla del proyecto es de la **Fase 3** y es corta: **quien traduce el error es el borde HTTP; quien decide qué hacer con él es quien llamó.** Un `*ApiService` convierte un `HttpErrorResponse` en un `ApiError` del dominio y lo relanza; el `*StateService` lo captura y lo mete en `state.error`; el componente lo pinta. Nadie se lo traga por el camino.

> ⚠️ **El error de colocación que cuesta horas.** `catchError` en el `pipe` **externo** de un flujo de larga vida lo mata para siempre. Un `valueChanges` que pasa por un `switchMap` y termina en un `catchError` externo: falla una petición, el `catchError` la maneja, y **el `valueChanges` deja de emitir**. La pantalla no da ningún error; simplemente el autosave no vuelve a funcionar hasta que recargues.
>
> ```ts
> // ❌ Un solo fallo mata el flujo entero para siempre.
> this.form.valueChanges.pipe(
>   switchMap((v) => this.api.save(v)),
>   catchError(() => of(null)),
> ).subscribe();
>
> // ✅ El catchError va DENTRO, protegiendo sólo la petición.
> this.form.valueChanges.pipe(
>   switchMap((v) => this.api.save(v).pipe(catchError(() => of(null)))),
> ).subscribe();
> ```
>
> La regla que lo resume: **el `catchError` va tan cerca de lo que puede fallar como se pueda.**

**Los antipatrones:** el `catchError(() => EMPTY)` que hace desaparecer el fallo (el componente sigue esperando una respuesta que no va a llegar, y el bug aparece tres pantallas más allá sin nada en consola); el `catchError` que devuelve un valor de dominio inventado —un array vacío que la pantalla pinta como "no hay plantillas" cuando lo que hubo fue un 500—; y el interceptor que se traga el error en vez de relanzarlo, que es el que la **Fase 2** nombra por su nombre.

---

## 7. `shareReplay`, con y sin `refCount`

Un observable derivado con `map` se recalcula **una vez por suscriptor**. Con cuatro pantallas mirando el mismo derivado, cuatro cálculos idénticos en cada emisión. `shareReplay` comparte una sola ejecución y reparte el resultado.

```ts
readonly latestVersions$ = this.templates$.pipe(
  map((templates) => /* recorre y agrupa por familia */),
  shareReplay({ bufferSize: 1, refCount: true }),
);
```

**`refCount: true` es la mitad que importa, y es la que el atajo omite.** `shareReplay(1)` —la forma corta que aparece en todos los ejemplos— equivale a `refCount: false`: la suscripción interna a la fuente **queda viva para siempre**, aunque no quede nadie escuchando. Sobre una fuente que no completa —un `BehaviorSubject`, por ejemplo— eso es una fuga con nombre y apellido, y no se ve en ningún sitio hasta que el perfilador de memoria la enseña.

Con `refCount: true`, cuando se va el último suscriptor la suscripción a la fuente se cierra; cuando llega uno nuevo, se vuelve a abrir.

| Forma | Qué hace | Cuándo |
|---|---|---|
| `shareReplay({ bufferSize: 1, refCount: true })` | comparte y se cierra al quedarse sin suscriptores | **el valor por defecto del proyecto** |
| `shareReplay(1)` | comparte y no se cierra nunca | sólo sobre fuentes que completan (una petición HTTP que se quiere cachear de por vida) |
| sin `shareReplay` | cada suscriptor recalcula | derivados baratos con un solo consumidor |

**Los antipatrones:** `shareReplay(1)` sobre un `BehaviorSubject` (la fuga de arriba); `shareReplay` sobre algo que ya es caliente y barato, que añade una capa que no comparte nada; y `shareReplay` usado como caché de una petición HTTP sin pensar en la invalidación — funciona, y el día que alguien publique una v3 la pantalla seguirá enseñando la v2 hasta que se recargue.

---

## 8. 🧬 Las tres formas de desuscribirse

Las tres están vivas en CertCore, y ésa es la lección: al abrir un archivo, la forma en que se desuscribe te dice de qué año es.

```ts
// ── HEREDADO (2021) — Subscription manual ─────────────────────────────────
export class TemplateListComponent implements OnInit, OnDestroy {
  private subscription: Subscription | null = null;

  constructor(private readonly templateApi: TemplateApiService) {}

  ngOnInit(): void {
    this.subscription = this.templateApi.getAll().subscribe(/* … */);
  }

  ngOnDestroy(): void {
    this.subscription?.unsubscribe();
  }
}
```

```ts
// ── HEREDADO (2021) — takeUntil con Subject de destrucción ────────────────
export class AssetListComponent implements OnInit, OnDestroy {
  private readonly destroy$ = new Subject<void>();

  ngOnInit(): void {
    this.assetState.assets$.pipe(takeUntil(this.destroy$)).subscribe(/* … */);
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();   // el complete() que la mitad del mundo olvida
  }
}
```

```ts
// ── NUEVO (2024) — takeUntilDestroyed ──────────────────────────────────────
export class ClientFormComponent {
  private readonly destroyRef = inject(DestroyRef);

  ngOnInit(): void {
    this.clientApi.getById(id)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe(/* … */);
  }
}
```

**Cuál usarías.** El tercero, en todo lo que escribas de aquí en adelante: no hay campo que declarar, no hay `ngOnDestroy` que recordar, y no hay forma de olvidarse la mitad. Los dos primeros, si estás arreglando un archivo que ya los tiene — arreglar no es reescribir (guía §6.1).

> ⚠️ **`takeUntilDestroyed()` sin argumento sólo se puede llamar en el contexto de inyección**, típicamente en un inicializador de campo. Llamarlo dentro de `ngOnInit` da `NG0203`, y el mensaje de error no menciona a `takeUntilDestroyed` por ningún lado. Fuera del contexto, se inyecta `DestroyRef` arriba y se le pasa. Está en **A04** §7, caso 3.

> 🧭 **Y antes de nada: ¿hace falta desuscribirse?** Si el observable completa —cualquiera de `HttpClient`—, no. Si la suscripción es sólo para pintar, no: va `async` pipe y no hay suscripción manual que gestionar. Sólo hace falta en el caso restante: una suscripción manual a un observable que no completa, hecha desde algo que se destruye.

---

## 9. `async` pipe frente a `.subscribe()`

> 🧭 **La regla de oro del curso: `async` pipe para pintar, `.subscribe()` para efectos — y entonces alguien se desuscribe.**

Si lo único que quieres es que un valor aparezca en pantalla, `async` pipe. Se suscribe al crear la vista, se desuscribe al destruirla, y además marca el componente para revisión, que es lo que hace que `OnPush` funcione sin que tengas que llamar a `markForCheck()` a mano.

```html
<!-- Un solo async, un solo objeto de estado. -->
<ng-container *ngIf="state$ | async as state">
  <mat-spinner *ngIf="state.loading"></mat-spinner>
  <cc-error-box *ngIf="state.error as error" [message]="error"></cc-error-box>
  <cc-template-table *ngIf="!state.loading" [templates]="state.items"></cc-template-table>
</ng-container>
```

**El antipatrón que más se ve:** varios `async` sobre el mismo observable frío.

```html
<!-- ❌ Tres async sobre un observable de HttpClient son TRES peticiones. -->
<span>{{ (templates$ | async)?.length }}</span>
<div *ngFor="let t of templates$ | async">…</div>
<p *ngIf="(templates$ | async)?.length === 0">No hay plantillas</p>
```

Con un `BehaviorSubject` detrás no pasa —es caliente— y por eso en CertCore casi no se nota. Con un observable de `HttpClient` directo, son tres peticiones y la pestaña Network lo enseña. Las dos soluciones son conocidas: un solo `async` con `as` (arriba), o `shareReplay` sobre el derivado (§7).

`.subscribe()` se reserva para cuando la suscripción **provoca algo**: guardar, navegar, abrir un diálogo, mostrar un snackbar. Y en ese caso vuelve la §8: alguien tiene que desuscribirse.

---

## 🧭 Cuándo usar qué

| Necesitas… | Operador | Antipatrón que evita |
|---|---|---|
| transformar un valor | `map` | guardar lo que se puede calcular |
| reaccionar a lo último y descartar lo anterior | `switchMap` | pintar la respuesta que llegó tarde |
| lanzar cosas independientes en paralelo | `mergeMap` | encolar sin motivo lo que no depende de nada |
| garantizar el orden de varias escrituras | `concatMap` | dos `PATCH` cruzados de la misma entidad |
| cruzar dos partes del estado | `combineLatest` | duplicar el cruce en un tercer sujeto |
| esperar a que el usuario pare de escribir | `debounceTime` | una petición por tecla |
| no repetir lo idéntico | `distinctUntilChanged` **con comparador** | guardar dos veces lo mismo |
| traducir o manejar un fallo | `catchError` **lo más cerca posible** | matar un flujo de larga vida |
| compartir un cálculo entre varias vistas | `shareReplay({ bufferSize: 1, refCount: true })` | recalcular por suscriptor, o la fuga del `refCount: false` |
| cortar al destruir el componente | `takeUntilDestroyed(destroyRef)` | el zombi que revive en cada navegación |
| sólo pintar | `async` pipe | la suscripción manual que nadie cierra |
| provocar un efecto | `.subscribe()` + desuscripción | el efecto duplicado por dos `async` |

---

## ⚠️ Advertencias

- **Mucho de lo que encuentres en internet es RxJS 6.** Se reconoce por los imports desde `'rxjs/operators'`, por `toPromise()`, y por `combineLatest(a$, b$)` con argumentos sueltos. Traducirlo es mecánico; el problema es no darte cuenta de que estás traduciendo.
- **Un `subscribe` anidado dentro de otro `subscribe` no es un estilo: es un operador que falta.** La guía lo nombra como antipatrón por su nombre (§6.5) y en el curso no aparece ni una vez, salvo cuando un ejercicio te pide arreglarlo.
- **Exponer un `Subject` público es un campo mutable global con pasos extra.** Cualquiera puede hacerle `next()`, y cuando el estado quede mal la lista de sospechosos es el repositorio entero. Con `asObservable()`, la lista son los métodos de un archivo (**Fase 4**, **A07**).
- **La latencia cero del mock esconde la mitad de estos bugs.** `switchMap` frente a `mergeMap` no se distingue con respuestas de dos milisegundos. Levanta el mock con `CHAOS=latency` de la **Fase 3** antes de dar por buena una elección de operador.

---

## 📚 Referencias

- https://rxjs.dev/guide/overview — la guía oficial de RxJS 7, que es la versión de este curso.
- https://rxjs.dev/api/operators/switchMap · https://rxjs.dev/api/operators/mergeMap · https://rxjs.dev/api/operators/concatMap — los tres, con sus diagramas de canicas. Verlos uno tras otro es la forma más rápida de fijar la diferencia.
- https://rxjs.dev/api/operators/shareReplay — incluida la explicación de `refCount`, que es lo que la mayoría de los tutoriales omite.
- https://rxjs.dev/api/operators/combineLatest — con la frase sobre no emitir hasta que todas las fuentes hayan emitido.
- https://rxjs.dev/deprecations — la lista oficial de lo que salió entre la 6 y la 7, `toPromise()` incluido.
- https://v16.angular.io/api/core/rxjs-interop/takeUntilDestroyed — el operador de Angular 16, con su nota sobre el contexto de inyección.
- https://v16.angular.io/api/common/AsyncPipe — el `async` pipe, y su relación con `markForCheck()`.
- https://www.learnrxjs.io — colección de recetas por caso de uso. ⚠️ Mezcla ejemplos de RxJS 6 y 7; útil para encontrar el operador, no para copiar el código.

**Orden de lectura sugerido:** la §1 antes de la Fase 4, y de verdad antes: sin las tres preguntas, el resto son recetas. La §3 y la §7 cuando llegues a la Fase 4, que es donde aparecen las dos. La §6 cuando la Fase 3 te ponga el caos delante. La §5 y la §9 con la Fase 8. La §8 se lee de un tirón el día que abras un componente heredado y no reconozcas cómo se desuscribe.

---

## 🧪 Ejercicios (9)

1. 🟢 Suscríbete dos veces al mismo `this.http.get(...)` y cuenta las peticiones en la pestaña Network. Después haz lo mismo con `state$` de `TemplateStateService`. Explica la diferencia en una frase usando las palabras "frío" y "caliente".

2. 🟢 Quita el `distinctUntilChanged` de `templates$` en `TemplateStateService`, añade un `tap(() => console.log('recalculo'))` y provoca un cambio que sólo toque `loading`. Anota cuántas veces imprime con y sin el operador.

3. 🟡 Levanta el mock con `CHAOS=latency`, navega rápido entre dos inspecciones y observa qué se pinta. Cambia el `switchMap` de la ruta por `mergeMap` y repite. Anota qué ves en Network en cada caso y cuál de las dos peticiones aparece como `canceled`.

4. 🟡 Escribe un `combineLatest` de tres fuentes donde una sea un `Subject` normal al que nadie ha hecho `next()`. Comprueba que no emite nada, y localiza la fuente culpable con la técnica del `tap` etiquetado de la §4.

5. 🟡 En el autosave de la Fase 8, invierte el orden de `debounceTime` y `distinctUntilChanged`. Escribe rápido en un campo y cuenta las peticiones en los dos órdenes. Explica el resultado.

6. 🟠 Reproduce el error de colocación de `catchError` de la §6: ponlo en el `pipe` externo del autosave, provoca un fallo con `CHAOS=error`, y comprueba que el autosave no vuelve a funcionar aunque el siguiente guardado sí funcionaría. Después muévelo dentro del `switchMap` y verifica que el flujo sobrevive.

7. 🟠 Cambia `shareReplay({ bufferSize: 1, refCount: true })` por `shareReplay(1)` en `latestVersions$`. Navega diez veces entre dos pantallas y busca en el perfilador de memoria de DevTools la diferencia. Si no consigues verla, explica por escrito por qué el bug existe igual aunque tu medición no lo capture — que es lo interesante de este ejercicio.

8. 🔴 🧬 Te dan un componente heredado con `subscribe` anidado dentro de `subscribe` y desuscripción por `Subscription` manual. El ticket es "el segundo `subscribe` a veces pinta datos de la petición anterior". Escribe el **parche mínimo** —sin cambiar el estilo del archivo— y después la **refactorización correcta** en estilo nuevo. Argumenta cuál de los dos entregarías un viernes a las seis y por qué.

9. 🔴 Escribe un flujo que combine cinco de los ocho operadores de este apéndice para resolver esto: cuando el supervisor escribe en un buscador de clientes, la pantalla busca tras 300 ms de pausa, no repite la misma búsqueda, cancela la anterior si sigue escribiendo, sobrevive a un 500 sin dejar de funcionar, comparte el resultado entre dos vistas y se corta al destruir el componente. Debe funcionar con `CHAOS=latency,error` puesto, y ése es el criterio de éxito.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y los flujos que explica los escriben las Fases 2, 3, 4, 8 y 11, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 04: …`, `fase 08: …`). Las mediciones de los ejercicios 3, 5 y 7 van en el mensaje de un tag anotado (`ej/a06/7`), que es donde un número queda fechado. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
APPENDIX_EOF
wc -l a06-rxjs.md

# --- 2026-09-06T22:39:55 · FeatureState model
sed -n '113,168p' 04-estado-servicios.md

# --- 2026-09-06T22:42:16 · Write A07
cat > a07-estado-servicios.md <<'APPENDIX_EOF'
# 📎 Apéndice A07 — Estado con servicios y `BehaviorSubject`

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: Fase 4, Fase 6, Fase 7, Fase 9, Fase 11 · Versión cubierta: Angular 16.2.12 + RxJS 7.8.1

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve dos cosas: **entender el patrón de estado de CertCore de punta a punta**, y —lo que casi ningún artículo sobre el tema hace— **saber en qué punto exacto se queda corto**.

Ese segundo objetivo no es un adorno de honestidad. Es lo que separa haber elegido un patrón de haberlo heredado sin enterarse. La §8 es obligatoria y es la mitad del valor de este documento.

**Qué queda fuera:** NgRx, NGXS, Akita y cualquier otra librería de store. Se nombra qué problema resuelven (§8) y no se implementan: CertCore no las usa, y la decisión de 2022 que lo estableció sigue vigente. Quien quiera ver NgRx en un sistema heredado de verdad lo tiene en el Track A, donde es una fase entera. Los signals como estado tampoco entran: son experimentales en Angular 16, CertCore no los usa, y el horizonte está en **A11** 🔥.

---

## Índice

- [1. El patrón, en tres reglas](#1-el-patrón-en-tres-reglas)
- [2. Por qué el `Subject` no sale del servicio](#2-por-qué-el-subject-no-sale-del-servicio)
- [3. `providedIn: 'root'` frente a provider de ruta](#3-providedin-root-frente-a-provider-de-ruta)
- [4. Actualizar sin mutar, y por qué `OnPush` te obliga](#4-actualizar-sin-mutar-y-por-qué-onpush-te-obliga)
- [5. Derivar sin duplicar](#5-derivar-sin-duplicar)
- [6. `loading` y `error` dentro del estado](#6-loading-y-error-dentro-del-estado)
- [7. El ciclo de vida de una suscripción, de punta a punta](#7-el-ciclo-de-vida-de-una-suscripción-de-punta-a-punta)
- [8. ⚠️ Dónde este patrón se queda corto](#8-️-dónde-este-patrón-se-queda-corto)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. El patrón, en tres reglas

```ts
// 1. El sujeto es PRIVADO. Sólo el servicio empuja valores.
private readonly stateSubject = new BehaviorSubject<FeatureState<T>>(createInitialState<T>());

// 2. Lo público es un Observable de SÓLO LECTURA.
readonly state$ = this.stateSubject.asObservable();

// 3. Actualizar es REEMPLAZAR el estado, nunca modificarlo en sitio.
private patch(changes: Partial<FeatureState<T>>): void {
  this.stateSubject.next({ ...this.stateSubject.value, ...changes });
}
```

Y una cuarta que no es del patrón sino del proyecto, y que decide en qué archivo va cada método:

> 🧭 **Regla del proyecto: `*StateService` recuerda, `*ApiService` pide.** Un `*ApiService` traduce HTTP a dominio y no guarda nada; si le pides dos veces lo mismo, hace dos peticiones y le parece bien. Un `*StateService` es el único que tiene memoria, y es quien decide cuándo hace falta pedir. Si un método de un `*ApiService` empieza a acordarse de algo, está en el archivo equivocado.

**Por qué `BehaviorSubject` y no `Subject`.** Porque un `BehaviorSubject` **siempre tiene un valor**: quien se suscriba tarde recibe el actual inmediatamente, sin esperar a la siguiente emisión. Eso es lo que permite que un componente que se monta a los diez minutos pinte el estado que ya existía, y es también lo que hace que un `combineLatest` de varios estados emita desde el principio en vez de quedarse callado (**A06** §4).

**Una decisión que se ve poco y se agradece.** El estado de todas las features de CertCore tiene la misma forma (`FeatureState<T>`: `items`, `selected`, `loading`, `error`), pero **no hay una clase base** de la que hereden los servicios. Es deliberado: una `AbstractStateService<T>` ahorra treinta líneas por servicio y mete herencia justo donde peor envejece — el día que una feature necesite un campo más, o que `load()` tenga que hacer dos peticiones, la clase base se llena de ganchos y banderas. Cada `*StateService` se escribe explícito y se lee entero.

> ⚠️ **`createInitialState<T>()` es una función, no una constante.** Con `export const INITIAL_STATE = { items: [], … }` todas las features compartirían el mismo objeto y el mismo array, y el primer `push` de cualquiera aparecería en las demás. Es un bug de veinte segundos de escribir y de dos horas de encontrar.

---

## 2. Por qué el `Subject` no sale del servicio

`asObservable()` no es ceremonia: es lo único que separa un estado con dueño de un campo mutable global.

```ts
// ❌ Con el sujeto público, esto compila y funciona desde cualquier componente:
this.templateState.stateSubject.next({ items: [], selected: null, loading: false, error: null });
```

El día que el estado quede mal, la lista de sospechosos es **el repositorio entero**. Con `asObservable()`, la lista de sospechosos son los métodos públicos de un archivo — y como todos ellos pasan por el único `patch()` privado, hay exactamente un sitio donde poner el breakpoint.

Esa es la razón real de que `patch()` sea privado y sea el único que llama a `next()`. No es encapsulación por gusto: es que un solo `next()` en todo el servicio convierte "el estado quedó raro" en una sesión de depuración de cinco minutos.

**Los tres nombres, y por qué se distinguen por la palabra y no por el signo:**

```ts
private readonly stateSubject = …;   // el sujeto
readonly state$ = …;                 // el observable público
this.stateSubject.value;             // el valor síncrono, sólo dentro del servicio
```

Un `state` privado y un `state$` público difieren en un carácter, y ese carácter se pierde en un `Ctrl+F` a las siete de la tarde.

> ⚠️ **`.value` es legítimo dentro del servicio y sospechoso fuera.** Dentro, es cómo `patch()` compone el estado nuevo a partir del actual. Fuera —en un componente que hace `stateSubject.value` para leer sin suscribirse— es una lectura que no reacciona a nada: funciona la primera vez y se queda vieja para siempre. Si un componente necesita el valor actual una sola vez, el operador es `first()`, no `.value`.

---

## 3. `providedIn: 'root'` frente a provider de ruta

Es la decisión que fija el ciclo de vida, y sólo tiene dos opciones.

**`providedIn: 'root'`** — una instancia por aplicación, creada la primera vez que alguien la pide y viva hasta que se cierre la pestaña. **No se destruye al navegar.** Es lo que quieres para estado compartido entre features, y es lo que usan todos los `*StateService` de CertCore.

**Provider de ruta** (`providers: [X]` en una ruta con `loadComponent` o `loadChildren`) — una instancia por activación de esa ruta, destruida al salir. Es lo que quieres para estado que *pertenece* a una pantalla y no debe sobrevivirla: el borrador de un formulario largo, un asistente de varios pasos.

| | `providedIn: 'root'` | provider de ruta |
|---|---|---|
| Instancias | una, para toda la aplicación | una por activación de la ruta |
| Al navegar fuera | sobrevive | se destruye |
| Lo ven otras features | sí | no |
| Riesgo típico | datos del usuario anterior en memoria | perder estado que sí querías conservar |

De la primera opción salen dos consecuencias que hay que mirar de frente:

**Al volver a una pantalla ves un instante los datos de la visita anterior**, antes de que llegue el refresco. No es un bug: es la definición de tener estado. Se puede evitar llamando a `reset()` al entrar, y casi nunca conviene — un parpadeo de datos viejos molesta menos que un parpadeo de pantalla vacía.

**Si cierras sesión y no limpias, el estado del usuario anterior sigue en memoria**, listo para pintarse cuando entre el siguiente. Eso sí hay que resolverlo, y la forma que no obliga a nadie a acordarse es que el propio servicio escuche el cierre de sesión:

```ts
constructor() {
  // Cuando la sesión se cierra —por el botón o por un 401 que cazó el
  // interceptor— el estado del usuario anterior desaparece. Esto no es
  // rendimiento: es privacidad. Y al hacerlo aquí, ningún sitio que llame a
  // logout() tiene que acordarse de limpiar nada.
  this.authService.currentUser$
    .pipe(filter((user) => user === null))
    .subscribe(() => this.reset());
}
```

Nadie se desuscribe de esa suscripción y **es correcto**: los dos servicios son `providedIn: 'root'` y viven lo mismo que la aplicación, así que la suscripción no sobrevive a nadie (§7).

---

## 4. Actualizar sin mutar, y por qué `OnPush` te obliga

Con `ChangeDetectionStrategy.OnPush`, Angular sólo revisa un componente cuando pasa una de cuatro cosas: cambia la **referencia** de un `@Input`, se dispara un evento dentro de su propia plantilla, emite un observable conectado con `async` pipe, o alguien llama a `markForCheck()`.

Ninguna de las cuatro incluye *"alguien mutó un array que el componente ya tenía"*.

```ts
// ❌ La referencia no cambia. Nadie emite. La vista se queda mintiendo.
this.stateSubject.value.items.push(newTemplate);

// ✅ Objeto nuevo, array nuevo. La referencia cambia, el async pipe emite,
//    OnPush se despierta.
this.patch({ items: [...this.stateSubject.value.items, newTemplate] });
```

La variante cruel de este bug, y la razón de que la **Fase 6** lo use como pago de deuda: **una pantalla con `OnPush` se queda congelada y la pantalla heredada de al lado, que no tiene `OnPush`, se refresca igual.** El mismo bug se ve en un sitio y no en el otro, y quien lo reporte va a jurar que es cosa de la pantalla nueva.

**Las tres actualizaciones que hacen falta, escritas una vez:**

```ts
// Añadir
this.patch({ items: [...items, created] });

// Reemplazar uno
this.patch({ items: items.map((item) => (item.id === updated.id ? updated : item)) });

// Quitar
this.patch({ items: items.filter((item) => item.id !== removedId) });
```

> 💸 **La deuda que la Fase 4 declara y la Fase 6 paga.** `FeatureState<T>` nace con `items: T[]` y no `readonly items: readonly T[]`: el array que sale por `state$` es el mismo que guarda el servicio, y cualquier suscriptor puede hacerle `push` o `sort`. El borde HTTP sí está protegido —los `*ApiService` de la Fase 3 devuelven `readonly T[]`—; lo que queda abierto es de la puerta para adentro. Se paga en la **Fase 6**, con la pantalla que deja de repintar delante, y la factura se lee con `git diff fase-04 fase-06 -- src/app/core/state/`.

> 🧭 **La regla que sale de todo esto, y que aplica cuatro veces en el curso: un derivado sólo es seguro si sus entradas son inmutables.** Aparece con la severidad de los hallazgos (Fase 9), con el `status` del certificado (Fase 10) y con las agregaciones del dashboard (Fase 11). Si el dato del que derivas se puede mutar por debajo, tu cálculo es correcto y su resultado es basura, y nada en el código señala al culpable.

---

## 5. Derivar sin duplicar

Lo que se puede calcular no se guarda. Guardarlo son dos fuentes de verdad que se van a desincronizar, y la que se desincronice será la que esté pintada.

```ts
// Derivados simples: una vista del estado, con su distinctUntilChanged.
readonly templates$ = this.state$.pipe(map((state) => state.items), distinctUntilChanged());
readonly loading$   = this.state$.pipe(map((state) => state.loading), distinctUntilChanged());

// Derivado con cálculo: se comparte, porque cuatro pantallas lo miran.
readonly latestVersions$ = this.templates$.pipe(
  map((templates) => /* agrupa por familia y se queda con la versión más alta */),
  shareReplay({ bufferSize: 1, refCount: true }),
);
```

Dos detalles que deciden si esto escala o no:

**El `distinctUntilChanged` de los derivados simples** evita que un cambio en `loading` despierte a quien sólo mira `items`. Sin él, cada emisión del estado despierta a todos los suscriptores de todos los derivados.

**El `refCount: true` del `shareReplay`** es la mitad que importa. `shareReplay(1)` —la forma corta— deja la suscripción interna viva para siempre aunque no quede nadie escuchando, y sobre una fuente que no completa —un `BehaviorSubject`, justo— eso es una fuga. El detalle completo está en **A06** §7.

**Cuando el derivado cruza dos servicios**, la herramienta es `combineLatest`, y sigue sin guardarse nada:

```ts
// Fase 11: certificados por vencer, agrupados por cliente. El cruce no existe
// en ningún estado; se calcula cuando alguien lo mira.
readonly expiringByClient$ = combineLatest([
  this.certificateState.certificates$,
  this.clientState.clients$,
]).pipe(
  map(([certificates, clients]) => groupExpiringByClient(certificates, clients)),
  shareReplay({ bufferSize: 1, refCount: true }),
);
```

> 💡 **Dónde va la función que calcula.** Fuera del servicio, en `core/domain/`, como función pura. El servicio la llama; no la contiene. Así la **Fase 12** puede testear la regla de negocio sin `TestBed`, sin `HttpClient` y sin montar nada — y el 80% del coverage del proyecto sale de ahí.

---

## 6. `loading` y `error` dentro del estado

Los dos viven **dentro** del objeto de estado, no como campos sueltos del componente ni como excepciones que se propagan.

```ts
load(): void {
  this.patch({ loading: true, error: null });   // limpiar el error anterior importa

  this.templateApi.getAll().subscribe({
    next: (templates) => this.patch({ items: [...templates], loading: false }),
    error: (error: unknown) => this.patch({
      loading: false,
      error: error instanceof ApiError ? error.message : 'No se pudieron cargar las plantillas.',
    }),
  });
}
```

**Por qué el error vive en el estado y no se lanza.** Porque un error que sólo existe en un `catch` local no se puede pintar en otra pantalla, y el dashboard de la **Fase 11** necesita exactamente eso: mostrar que la carga de certificados falló mientras el resto del panel sigue funcionando. Un error en el estado es un dato como cualquier otro; una excepción es un evento que ya pasó.

**Por qué se limpia el error al empezar la carga.** Sin ese `error: null`, un reintento que funciona deja el mensaje de error anterior en pantalla junto a los datos nuevos. Es de los bugs más tontos y más frecuentes del patrón.

**El límite del booleano.** `loading: boolean` responde a "¿hay algo en vuelo?", no a "¿qué hay en vuelo?". En cuanto una feature tenga dos cargas concurrentes —el listado y el detalle— un solo booleano miente: la primera en volver lo pone en `false` mientras la otra sigue viajando. La respuesta cuando llega ese día es un campo por operación, o un contador; en CertCore no llega, y por eso el booleano se queda.

---

## 7. El ciclo de vida de una suscripción, de punta a punta

La pregunta no es "¿me desuscribo?" sino **"¿esta suscripción puede sobrevivir a quien la creó?"**. Con eso, los cuatro casos del proyecto se resuelven solos:

| Quién se suscribe | A qué | ¿Hace falta cortar? | Por qué |
|---|---|---|---|
| Un `*StateService` | a un `*ApiService` (HTTP) | **No** | el observable completa al llegar la respuesta; no queda nada abierto |
| Un `*StateService` raíz | a otro servicio raíz | **No** | los dos viven lo que la aplicación; nadie sobrevive a nadie |
| Una plantilla | a `state$` con `async` pipe | **No** | el pipe se suscribe al crear la vista y se desuscribe al destruirla |
| Un componente, con `.subscribe()` | a `state$` para provocar un efecto | **Sí** | `state$` no completa nunca y el componente se destruye antes |

Sólo el último caso necesita gestión, y la forma nueva es `takeUntilDestroyed(this.destroyRef)`. Las dos formas heredadas —`Subscription` manual y `takeUntil` con un `Subject` de destrucción— están vivas en CertCore y se explican en **A06** §8.

> 🧭 **La regla de oro, que se repite en todo el curso: `async` pipe para pintar, `.subscribe()` para efectos.** Si la suscripción es sólo para que un valor aparezca en pantalla, no escribas una suscripción: escribe un `async`. En toda la Fase 4 no hay una sola suscripción manual en código de producción, y no es una casualidad de la fase.

**Cómo se caza una fuga cuando ya existe**, que es lo que de verdad vas a tener que hacer:

1. Abre la pantalla sospechosa, navega fuera y vuelve. Diez veces.
2. Pon un `tap((v) => console.log('emitió', v))` en el observable compartido y provoca **una** emisión.
3. Cuenta las líneas en consola. Si son diez, tienes diez componentes zombis vivos y acabas de localizar la fuga sin abrir el perfilador.

---

## 8. ⚠️ Dónde este patrón se queda corto

Ninguna decisión gana en todo, y ésta pierde en cuatro sitios concretos. Esta sección no es un descargo de responsabilidad: es lo que te permite defender la decisión —o cambiarla— con argumentos en vez de con preferencias.

**No hay herramientas.** No existe un devtools que te muestre el árbol de estado, ni viaje en el tiempo, ni un registro de qué acción cambió qué. Cuando el estado quede raro, tu herramienta es un `tap(console.log)` bien puesto y el breakpoint en `patch()`. Con quince servicios de estado eso sigue funcionando; con setenta, no.

**No hay trazabilidad de quién cambió qué.** El estado cambió; el porqué no está en ningún sitio. En un sistema cuyo dominio **es** la trazabilidad, la ironía duele. Es la diferencia central con un store basado en acciones: allí cada cambio tiene un nombre, y el registro de nombres *es* la historia de la sesión.

**Las cargas concurrentes no se ordenan.** Dos `load()` seguidos lanzan dos peticiones y gana **la que llegue última**, que no tiene por qué ser la última que pediste. Con el mock respondiendo en dos milisegundos no se nota; con `CHAOS=latency` sí. El arreglo dentro del patrón existe —`switchMap` sobre un sujeto de disparo en vez de un `subscribe` suelto en `load()`— y cuesta que `load()` deje de ser tres líneas legibles.

**El estado derivado se recalcula por suscriptor** salvo que lo compartas explícitamente, y compartirlo mal es la fuga del `refCount` (§5). Es una responsabilidad que el patrón te deja a ti y que un store resuelve con selectores memorizados de fábrica.

### Qué resolvería NgRx, y por qué CertCore no lo usa

Un store de acciones y reducers resuelve, punto por punto, los cuatro: trae devtools con viaje en el tiempo, cada cambio pasa por una acción con nombre, los efectos se escriben con operadores de RxJS donde la cancelación es explícita, y los selectores memorizan por defecto.

Y cobra por ello: cinco archivos por feature en vez de uno, un vocabulario que hay que aprender antes de tocar nada, y una curva que un equipo de dos personas paga entera sin repartirla.

> 📝 **La decisión, fechada.** En **2022** el equipo de CertCore evaluó NgRx y dijo que no: dos personas, un dominio chico, y una librería que exige ceremonia. Esa decisión sigue vigente y este curso la respeta — no porque sea la correcta en abstracto, sino porque es la que el sistema tiene y mantener significa trabajar con lo que hay. El Track A tomó la decisión contraria en 2019 y hoy arrastra NgRx 8 con el estilo de aquella época; ninguna de las dos empresas se equivocó.

**Cuándo tendrías que replantearlo**, con criterios y no con sensaciones: cuando más de tres features necesiten leer y escribir el mismo estado; cuando "¿quién cambió esto?" se convierta en una pregunta recurrente en los tickets; cuando las cargas concurrentes empiecen a producir bugs intermitentes de verdad; o cuando el equipo pase de dos a ocho personas y el patrón informal deje de ser el mismo patrón en la cabeza de todos.

---

## 🧭 Cuándo usar qué

| Situación | Decisión | Por qué |
|---|---|---|
| Estado que varias features leen | `*StateService` con `providedIn: 'root'` | una instancia, una verdad |
| Estado que pertenece a una pantalla | provider de ruta | se destruye al salir, que es lo que quieres |
| Pedir datos sin recordarlos | `*ApiService` | si empieza a acordarse de algo, está en el archivo equivocado |
| Un valor que se puede calcular | derivado con `map`, nunca un campo del estado | dos fuentes de verdad se desincronizan |
| Un derivado que miran varias vistas | `shareReplay({ bufferSize: 1, refCount: true })` | uno de los dos `refCount` es una fuga |
| Cruzar dos estados | `combineLatest` + función pura en `core/domain/` | testeable sin `TestBed` |
| Mostrar un fallo de carga | `error` dentro del estado | una excepción no se puede pintar en otra pantalla |
| Leer el valor actual una sola vez | `first()` | `.value` desde fuera es una lectura que no reacciona |
| Pintar | `async` pipe | no hay suscripción que gestionar |
| Provocar un efecto | `.subscribe()` + `takeUntilDestroyed` | es el único caso donde hace falta cortar |

---

## 📚 Referencias

- https://rxjs.dev/api/index/class/BehaviorSubject — la clase, y la diferencia con `Subject` en su primera frase.
- https://rxjs.dev/api/operators/shareReplay — con la explicación de `refCount` que la mayoría de los tutoriales omite.
- https://v16.angular.io/guide/dependency-injection-providers — `providedIn` y los ámbitos de la §3.
- https://v16.angular.io/guide/change-detection-skipping-subtrees — `OnPush` y las condiciones exactas que lo despiertan; es la referencia de la §4.
- https://v16.angular.io/api/core/rxjs-interop/takeUntilDestroyed — la forma nueva de cortar.
- https://ngrx.io/guide/store — para entender qué se está dejando sobre la mesa. Léelo como comparación, no como plan: este curso no lo instala.
- https://blog.angular.io/angular-v16-is-here-4d7a28ec680d — el anuncio de Angular 16, con la sección de signals que explica por qué en esta versión se leen y no se usan.

> ⚠️ Los artículos sobre "state management sin NgRx" que encuentres son casi todos posteriores a 2023 y resuelven el problema con signals. Eso es Angular 17 en adelante y no aplica aquí: en la 16 los signals son experimentales. El horizonte está en **A11** 🔥.

**Orden de lectura sugerido:** §1, §2 y §3 antes de escribir tu primer `*StateService`, que es la Fase 4. La §4 justo antes de la Fase 6, que es donde se paga la deuda de la inmutabilidad. La §7 el día que una lista se actualice dos veces. Y la §8 al terminar la Fase 11, no antes: hasta que no hayas escrito cinco servicios de estado, sus cuatro límites se leen como advertencias abstractas en vez de como cosas que ya te pasaron.

---

## 🧪 Ejercicios (8)

1. 🟢 Cambia `createInitialState<T>()` por una constante exportada `INITIAL_STATE`. Carga dos features distintas, muta el array de una, y comprueba qué le pasa a la otra. Revierte y explica en una frase por qué era una función.

2. 🟢 Haz público el `stateSubject` de `TemplateStateService` y llámale `next()` desde un componente con un estado inventado. Comprueba que compila, que funciona, y que no hay forma de saber desde el servicio quién lo hizo. Revierte.

3. 🟡 Convierte `TemplateStateService` de `providedIn: 'root'` a provider de la ruta de plantillas. Navega fuera y vuelve, y anota qué cambia en lo que ves. Después decide cuál de las dos configuraciones querría CertCore y defiéndelo en tres líneas.

4. 🟡 Reproduce el bug de `OnPush` de la §4: muta `state.items` con un `push` desde un componente y comprueba que la pantalla con `OnPush` no se entera mientras la heredada sí. Arréglalo con el reemplazo y verifica las dos pantallas.

5. 🟡 Añade un derivado `criticalTemplates$` que filtre las plantillas con al menos un ítem `photoRequired`. Suscríbete desde tres sitios con `async` y cuenta cuántas veces corre el filtro con y sin `shareReplay`. Anota las dos cifras.

6. 🟠 Levanta el mock con `CHAOS=latency` y llama a `load()` dos veces seguidas con un cambio de filtro en medio. Comprueba que gana la respuesta que llega última y no la que pediste al final. Después arréglalo dentro del patrón —con un sujeto de disparo y `switchMap`— y argumenta si el arreglo compensa la legibilidad que cuesta.

7. 🟠 Caza una fuga con el método de la §7: añade un `.subscribe()` sin cortar a `state$` en un componente, navega diez veces, provoca una emisión y cuenta las líneas de consola. Después arréglalo con `takeUntilDestroyed` y verifica que vuelve a ser una.

8. 🔴 Escribe el documento de decisión que CertCore no tiene: una página que responda a *"¿deberíamos migrar el estado a NgRx?"* con los cuatro límites de la §8 medidos sobre el proyecto real —cuántos servicios de estado hay, cuántas features comparten cuál, cuántos tickets del cuaderno son de estado— y una recomendación con su porqué. El criterio de éxito es que alguien que no conozca el sistema pueda estar en desacuerdo contigo señalando un dato concreto, no una opinión.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y los servicios de estado que explica los escriben las Fases 4, 6, 7, 9 y 11, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 04: …`, `fase 06: …`). Las mediciones de los ejercicios 5 y 7 van en el mensaje de un tag anotado (`ej/a07/5`). Y si haces el 8, es de las pocas cosas de un apéndice que merecen quedar en el repositorio: `docs/decision-estado.md`, commiteado con el prefijo de la fase desde la que llegaste. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
APPENDIX_EOF
wc -l a07-estado-servicios.md; ls a0*.md

# --- 2026-09-06T22:42:24 · Self-check appendices
for f in a0[34567]-*.md; do echo "=== $f ==="; echo -n "ejercicios: "; awk '/^## 🧪 Ejercicios/,/^---/' $f | grep -cE '^[0-9]+\. '; echo -n "bloque tag: "; grep -c '00-convencion-de-git-y-tags.md' $f; echo -n "any prohibido: "; grep -cE ': any\b|<any>|as any' $f; echo -n "angular.dev citado: "; grep -c 'angular.dev' $f; done; echo "=== enlaces a archivos ==="; grep -hoE '\]\([a-z0-9][^)]*\.md\)' a0*.md | sort -u

# --- 2026-09-06T22:55:53 · Check CHAOS invocation syntax
grep -n 'CHAOS' 03-mock-api-caos.md | head -20

# --- 2026-09-06T22:55:57 · Fase 6 tema Material y tabla
sed -n '98,152p' 06-clientes-activos.md; echo "=== 5.6 tabla ==="; sed -n '490,560p' 06-clientes-activos.md

# --- 2026-09-06T22:56:00 · Fase 6 diálogo y HTML de Material
sed -n '1011,1060p' 06-clientes-activos.md; echo "=== html tabla ==="; grep -n 'mat-table\|matColumnDef\|mat-form-field\|mat-error\|subscriptSizing\|appearance' 06-clientes-activos.md | head -25

# --- 2026-09-06T22:56:03 · Fase 10 PDF
sed -n '835,900p' 10-certificados-vigencia.md; echo "=== 5.8 pdf ==="; sed -n '1020,1080p' 10-certificados-vigencia.md

# --- 2026-09-06T22:59:07 · Write A01
cat > a01-material.md <<'APPENDIX_EOF'
# 📎 Apéndice A01 — Angular Material 16 (MDC)

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: Fase 1, Fase 6, Fase 7, Fase 8, Fase 10 · Versión cubierta: Angular Material y CDK 16.2.14

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve un problema muy específico de este track: **leer y modificar los formularios y tablas densos de CertCore sin pelearse con unos componentes que se reescribieron por dentro y conservaron el nombre por fuera.**

Ésa es la frase que hay que tener presente en todo el apéndice. Material 15 cambió de motor —pasó a MDC, la implementación de referencia de Material Design— y reescribió casi todos los componentes manteniendo selectores y clases de Angular idénticos. La consecuencia práctica: **cualquier artículo, respuesta de Stack Overflow o captura anterior a 2023 describe un componente distinto con el mismo nombre.** No está mal escrito; está describiendo otra cosa.

**Qué queda fuera:** los componentes de Material que CertCore no usa (`mat-stepper`, `mat-tree`, `mat-autocomplete`, `mat-chips`…), el rediseño visual del sistema —la paleta y la densidad quedaron cerradas en la Fase 6 y ninguna fase posterior las toca—, y Bootstrap, que es **A02** 🔥. Tampoco entra el tipado de los formularios que van dentro de un `mat-form-field`: eso es **A05**.

---

## Índice

- [1. Qué reescribió MDC, y qué de eso vive en CertCore](#1-qué-reescribió-mdc-y-qué-de-eso-vive-en-certcore)
- [2. El tema, en un archivo](#2-el-tema-en-un-archivo)
- [3. `mat-form-field`: lo que cambió y muerde](#3-mat-form-field-lo-que-cambió-y-muerde)
- [4. `mat-table`: array simple frente a `MatTableDataSource`](#4-mat-table-array-simple-frente-a-mattabledatasource)
- [5. `MatDialog`: datos de ida, resultado tipado de vuelta](#5-matdialog-datos-de-ida-resultado-tipado-de-vuelta)
- [6. `MatSnackBar`, y la duración que sí se decide](#6-matsnackbar-y-la-duración-que-sí-se-decide)
- [7. Densidad: la muesca que hace caber un formulario](#7-densidad-la-muesca-que-hace-caber-un-formulario)
- [8. Qué se puede tocar por CSS, y qué no](#8-qué-se-puede-tocar-por-css-y-qué-no)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Qué reescribió MDC, y qué de eso vive en CertCore

Lo que hay que saber para no perder una tarde, en cinco puntos:

**El DOM interno de casi todos los componentes cambió.** Las clases `.mat-form-field-infix`, `.mat-form-field-wrapper` y compañía de Material 14 ya no existen. Las nuevas llevan prefijo `.mat-mdc-` y su estructura es otra. Cualquier CSS que un proyecto heredado tuviera apuntando a las viejas dejó de aplicar **en silencio**: no hay error, sólo un estilo que ya no se ve.

**`appearance` se quedó con dos valores.** `legacy` y `standard` desaparecieron. Sólo quedan `fill` y `outline`, y el valor por defecto es `fill`. CertCore usa `outline` en todas partes.

**Los componentes crecieron.** La altura por defecto de un `mat-form-field` de MDC es mayor que la de Material 14 — es lo que manda la especificación de Material Design, pensada para móvil. En una aplicación de tablas y formularios densos eso desperdicia media pantalla, y es la razón exacta de la densidad `-1` de la Fase 6 (§7).

**`mat-error` y `mat-hint` tienen que estar dentro del `mat-form-field`.** En Material 14 quedar fuera se toleraba en algunos casos; en MDC no se pinta, y **no da ningún error**. Es la causa raíz de un error común de la Fase 6.

**Los módulos `legacy` existen en la 16 y no se usan aquí.** Material 15 publicó `@angular/material/legacy-form-field` y sus hermanos como puente para migrar sin rehacer el CSS. Siguen existiendo en la 16, en desuso, y desaparecieron después. **CertCore no tiene ni uno**: la migración de 2024 pasó directamente a los componentes MDC. Si te lo encuentras en otro sistema, ya sabes qué es y sabes que tiene fecha de caducidad.

> 📝 **Nota de migración.** El salto a MDC es de Material **15**, no de la 16. CertCore migró a Material 16.2.14 durante 2024 y se comió el cambio entero de una vez, que es lo que hace casi todo el mundo: nadie migra a la 15 para quedarse ahí. Por eso en el repositorio no hay rastro de la era intermedia, y por eso todo lo que en este apéndice se llama "lo de antes" es Material 14 y anteriores.

---

## 2. El tema, en un archivo

Todo el tema de CertCore vive en `src/styles.scss` y quedó cerrado en la Fase 6. Aquí está la anatomía, para cuando tengas que leerlo o justificar por qué no lo tocas.

```scss
// src/styles.scss
@use '@angular/material' as mat;

// mat.core() va UNA SOLA VEZ en todo el proyecto: trae los estilos base que
// comparten todos los componentes. Repetirlo duplica CSS sin avisar.
@include mat.core();

// define-palette recibe un mapa de tonos y devuelve una paleta con sus
// variantes por defecto, claras y oscuras, más los colores de contraste.
$certcore-primary: mat.define-palette(mat.$indigo-palette);
// Los tres argumentos extra son: tono por defecto, tono claro, tono oscuro.
$certcore-accent: mat.define-palette(mat.$pink-palette, A200, A100, A400);
$certcore-warn: mat.define-palette(mat.$red-palette);

$certcore-theme: mat.define-light-theme((
  color: (primary: $certcore-primary, accent: $certcore-accent, warn: $certcore-warn),
  typography: mat.define-typography-config(),
  density: -1,
));

@include mat.all-component-themes($certcore-theme);
```

**Detalles con intención**

- **`define-light-theme` con las tres claves.** Un tema al que le falte `typography` o `density` **no genera** los estilos de tipografía o densidad de los componentes, y el resultado es un formulario que se ve raro sin que nada falle. Es de los pocos sitios donde omitir una clave produce un fallo silencioso.
- **`all-component-themes` y no los mixins uno a uno.** Genera CSS para componentes que quizá no uses —y eso pesa, y en la Fase 13 se mide— a cambio de no volver a fallar nunca cuando alguien añada un componente en la Fase 10. Con los mixins individuales, ese día alguien pasa media hora buscando por qué el `mat-chip` nuevo sale sin colores.
- **La paleta no se toca a partir de aquí.** Si una fase necesita un color para "certificado por vencer", sale de `warn` o de una clase propia. Un tema que crece por acumulación de excepciones deja de ser un tema.

**La tipografía, cuando de verdad hay que ajustarla:**

```scss
$certcore-typography: mat.define-typography-config(
  $font-family: 'Roboto, sans-serif',
  // Cada nivel es una llamada a define-typography-level(tamaño, interlineado, peso).
  $body-1: mat.define-typography-level(14px, 20px, 400),
  $button: mat.define-typography-level(14px, 14px, 500),
);
```

> ⚠️ **Tocar variables Sass sin recompilar no cambia nada, y es la media hora perdida más frecuente de todo el tema.** `ng serve` sí recompila los estilos globales al guardar; lo que no se entera de nada es el navegador con el CSS viejo en caché, ni un contenedor de la Fase 13 construido antes del cambio. Si tocaste el tema y no ves diferencia, recarga forzando (`Cmd/Ctrl` + `Shift` + `R`) antes de buscar la causa en el Sass.

---

## 3. `mat-form-field`: lo que cambió y muerde

Es el componente que más aparece en CertCore y el que peor envejeció la documentación ajena.

```html
<mat-form-field appearance="outline">
  <mat-label>Razón social</mat-label>
  <input matInput formControlName="legalName" />

  <!-- Los mat-error van DENTRO del mat-form-field. Fuera no se pintan, y no
       da ningún error: simplemente el mensaje no aparece nunca. -->
  <mat-error *ngIf="form.controls.legalName.hasError('required')">
    La razón social es obligatoria.
  </mat-error>
  <mat-error *ngIf="form.controls.legalName.hasError('minlength')">
    Escribe al menos 3 caracteres.
  </mat-error>
</mat-form-field>
```

**Los cuatro puntos que hay que saber:**

**`appearance` tiene dos valores.** `fill` (por defecto) y `outline`. Si encuentras `appearance="legacy"` o `"standard"` en un ejemplo, es de Material 14 o anterior y no compila aquí — el error de plantilla lo dice, y es de los pocos que se entienden a la primera.

**`mat-error` sólo se pinta cuando el control es inválido *y* está `touched` o el formulario se envió.** Un campo que nace inválido —`required` sin valor— no muestra nada hasta que el usuario lo toca. Es correcto y desconcierta la primera vez: por eso el `submit()` de la Fase 6 llama a `markAllAsTouched()` antes de rendirse.

**`subscriptSizing` decide si el hueco del mensaje está siempre reservado.** El valor por defecto es `fixed`: bajo cada campo hay un espacio fijo para el error, aunque no haya error, y así el formulario no salta cuando aparece uno. Con `dynamic`, el hueco sólo existe cuando hay mensaje, y el layout se mueve.

```html
<!-- Un formulario que salta al validar es peor que uno un poco más alto.
     `fixed` es el valor por defecto y en CertCore se deja como está. -->
<mat-form-field appearance="outline" subscriptSizing="fixed">
```

**Y el que produce un ticket cada dos meses:** un `mat-form-field` **tiene que contener exactamente un control** con directiva de Material (`matInput`, `matSelect`, `matChipGrid`…). Ni cero —error `mat-form-field must contain a MatFormFieldControl`— ni dos. Meter dos inputs para una fecha "desde/hasta" dentro del mismo campo es la forma de encontrarse ese error, y la solución es dos `mat-form-field`.

---

## 4. `mat-table`: array simple frente a `MatTableDataSource`

`mat-table` acepta las dos cosas en `[dataSource]`, y elegir mal es la causa de la mitad de las tablas que no repintan.

```html
<table mat-table [dataSource]="view.visible" [trackBy]="trackByClientId">
  <ng-container matColumnDef="legalName">
    <th mat-header-cell *matHeaderCellDef>Razón social</th>
    <td mat-cell *matCellDef="let client">{{ client.legalName }}</td>
  </ng-container>

  <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
  <tr mat-row *matRowDef="let row; columns: displayedColumns"></tr>
</table>
```

| Opción | Qué trae | Cuándo |
|---|---|---|
| Array simple (`readonly T[]`) | nada: tú filtras, ordenas y paginas | **lo que usa CertCore**; el estado ya viene calculado del servicio |
| `MatTableDataSource<T>` | filtrado, ordenación y paginación **en cliente**, atados a `MatSort` y `MatPaginator` | prototipos y tablas pequeñas cuyo dato completo cabe en memoria |

**Por qué CertCore usa el array.** El listado de clientes filtra y pagina en el servicio de estado, con un derivado que la plantilla recibe ya resuelto (`ClientListView`). Con `MatTableDataSource` esa lógica se duplicaría dentro del componente y quedarían dos sitios donde se decide qué filas se ven — que es exactamente la clase de problema que la regla de "lo que se puede calcular no se guarda" evita.

> ⚠️ **Con `OnPush` y un array simple, la referencia lo es todo.** Si mutas el array con `push` o `sort`, la referencia no cambia, `mat-table` no se entera y la tabla se queda como estaba. Es la 💸 de la Fase 4 pagándose en la Fase 6, y la variante cruel es que la pantalla heredada de activos —que no tiene `OnPush`— **se refresca igual**, así que el mismo bug se ve en una pantalla y no en la otra.

**`trackBy` no es opcional en una tabla que se repinta seguido.** Sin él, cada emisión destruye y recrea todas las filas: se pierde el foco, se cierran los expandibles, y el scroll salta.

```ts
// El identificador estable de la fila, nunca el índice.
trackByClientId(_index: number, client: Client): number {
  return client.id;
}
```

---

## 5. `MatDialog`: datos de ida, resultado tipado de vuelta

El patrón completo de CertCore son tres piezas, y las tres están tipadas a propósito.

```ts
// 1. Lo que hay que darle al abrirlo. Una interfaz, nada de objeto suelto.
export interface ConfirmDialogData {
  readonly title: string;
  readonly message: string;
  readonly confirmLabel: string;
}

// 2. Dentro del diálogo: el token no tiene tipo, así que el genérico es
//    obligatorio. Sin él, `any` entra por la puerta grande.
readonly data = inject<ConfirmDialogData>(MAT_DIALOG_DATA);
readonly dialogRef = inject<MatDialogRef<ConfirmDialogComponent, boolean>>(MatDialogRef);
```

```ts
// 3. Al abrirlo: el segundo genérico de MatDialogRef es el tipo del resultado,
//    y es lo que permite filtrar sin un solo `as`.
this.dialog
  .open<ConfirmDialogComponent, ConfirmDialogData, boolean>(ConfirmDialogComponent, {
    data: { title: 'Dar de baja', message: '…', confirmLabel: 'Dar de baja' },
  })
  .afterClosed()
  .pipe(filter((confirmed): confirmed is true => confirmed === true))
  .subscribe(() => this.clientState.remove(clientId));
```

**Detalles con intención**

- **`afterClosed()` emite `undefined` cuando el usuario cierra con Escape o pulsando fuera**, no `false`. Por eso el filtro compara contra `true` explícitamente en vez de comprobar si hay valor: "cerró sin decidir" y "dijo que no" son lo mismo aquí, y confundirlos con un `if (result)` funciona hasta que el resultado sea un `0` o una cadena vacía.
- **El diálogo no borra nada.** Devuelve `true` o `false` y se va. Si supiera borrar clientes, no serviría para confirmar la baja de un activo, y habría dos diálogos casi iguales — que es como nacen los componentes con siete `@Input` opcionales.
- **`MatDialogModule` hay que importarlo aunque la plantilla no use ninguna de sus directivas.** `MatDialog` es un servicio provisto por ese módulo; sin el import, el `inject(MatDialog)` es un `NullInjectorError`. Es el caso que la Fase 5 anuncia: importar un `NgModule` desde un componente standalone también trae sus providers.

---

## 6. `MatSnackBar`, y la duración que sí se decide

```ts
private readonly snackBar = inject(MatSnackBar);

// Mensaje, etiqueta de la acción, opciones. La duración se decide, no se copia.
this.snackBar.open('No se pudo cargar el cliente.', 'Cerrar', { duration: 6000 });
```

**La duración es una decisión de producto y hay dos criterios.** Una confirmación de algo que salió bien puede durar 3 segundos: nadie necesita leerla dos veces. Un error que el usuario tiene que entender —y quizá reintentar— dura 6 segundos o no se cierra solo, y lleva su botón de "Cerrar". Un snackbar de error de 2 segundos es, en la práctica, un error que nadie vio.

**Lo que un snackbar no es:** el sitio donde vive un error. Un error de carga vive en `state.error` para que la pantalla lo pinte donde corresponde (**A07** §6); el snackbar es un aviso pasajero encima. Si el único rastro de un fallo desaparece a los seis segundos, la pantalla se queda diciendo que no hay clientes cuando lo que pasó fue un 500.

`MatSnackBarModule` tiene la misma peculiaridad que `MatDialogModule`: se importa por el servicio, no por las directivas.

---

## 7. Densidad: la muesca que hace caber un formulario

La densidad es un número entero entre `0` y `-5` que encoge la altura de los componentes sin tocar sus tipografías. Es el ajuste que más se nota en una aplicación como ésta y el que menos gente conoce.

```scss
// Global, dentro del tema. Es lo que hace CertCore.
$certcore-theme: mat.define-light-theme((/* … */ density: -1));

// Por componente, cuando una zona concreta necesita más.
.certcore-dense-table {
  @include mat.table-density(-3);
}
```

**Por qué `-1` y no `0` ni `-2`.** Con `0` —el valor de fábrica de MDC— un formulario de seis campos no cabe en una pantalla de portátil, y el inspector acaba haciendo scroll para ver el botón de guardar. Con `-2` se gana espacio y se pierde área táctil, que en una tablet en campo importa más que en un escritorio. `-1` es el compromiso, y está tomado con ese caso de uso en la cabeza.

> 💡 **La densidad no cambia el tamaño de la letra.** Encoge alturas, rellenos y áreas táctiles. Si lo que quieres es letra más pequeña, eso es `define-typography-config`, y son dos ajustes independientes que la gente confunde constantemente porque los dos "hacen la pantalla más compacta".

---

## 8. Qué se puede tocar por CSS, y qué no

Aquí es donde MDC cobra su factura, y conviene ser honesto sobre lo que hay.

**Lo que está soportado, por orden de preferencia:**

1. **El tema y sus mixins.** Paleta, tipografía y densidad, globales o por componente (`mat.form-field-density`, `mat.table-density`). Es la única vía que Angular garantiza entre versiones menores.
2. **Tus propias clases sobre tus propios elementos.** El `div` que envuelve la tabla es tuyo; estíralo, márgenalo y colórealo cuanto quieras.
3. **Las variables CSS `--mdc-*` que MDC expone.** Funcionan, y en Material 16 **no son API pública**: no están documentadas como contrato y pueden cambiar de nombre entre versiones. Usarlas es una decisión con fecha de revisión, no una solución.

**Lo que no está soportado, y por qué se rompe:**

```scss
// ❌ Apunta al DOM interno del componente. Funciona hoy y deja de funcionar
//    en la siguiente versión menor, sin error y sin aviso.
::ng-deep .mat-mdc-form-field-infix {
  padding: 4px 0;
}
```

`::ng-deep` está en desuso desde hace años, no tiene sustituto, y sigue siendo lo que todo el mundo usa. La regla práctica para CertCore, que es un sistema en mantenimiento y no un producto de diseño:

> 🧭 **Regla del proyecto: antes de escribir un `::ng-deep`, comprueba si el tema o un mixin de densidad resuelven el 80% del problema.** Casi siempre lo hacen. Si aun así hace falta, el `::ng-deep` va con un comentario que diga **a qué versión de Material apunta** y **qué se supone que consigue**, porque quien lo encuentre dentro de dos años necesita saber si sigue haciendo algo. Un `::ng-deep` sin comentario es CSS que nadie se va a atrever a borrar nunca.

---

## 🧭 Cuándo usar qué

| Situación | Qué usar | Por qué |
|---|---|---|
| Cambiar colores, tipografía o alturas | el tema en `styles.scss` | única vía soportada entre versiones |
| Compactar una zona concreta | `mat.<componente>-density(-N)` | no toca el resto de la aplicación |
| Mensaje de validación | `mat-error` **dentro** del `mat-form-field` | fuera no se pinta y no avisa |
| El campo salta al validar | `subscriptSizing="fixed"` (el valor por defecto) | el hueco reservado evita el salto |
| Tabla cuyo dato ya viene filtrado del estado | array simple + `trackBy` | evita duplicar la lógica de filtrado |
| Tabla pequeña, filtrado y orden en cliente | `MatTableDataSource` con `MatSort` y `MatPaginator` | trae hecho lo que necesitas |
| Confirmar una acción destructiva | `MatDialog` con datos y resultado tipados | y el diálogo no ejecuta la acción, sólo responde |
| Avisar de algo pasajero | `MatSnackBar` con duración decidida | 3 s si salió bien, 6 s y botón si salió mal |
| Un error que la pantalla debe seguir mostrando | `state.error`, no un snackbar | un aviso que se va no es un estado |
| Ajustar el interior de un componente | primero el tema; `::ng-deep` sólo comentado | el DOM interno de MDC no es contrato |

---

## ⚠️ Advertencias

- **La referencia es https://v16.material.angular.io, no `material.angular.io`.** Ésta última documenta la 17 en adelante y sus ejemplos usan control flow `@if`/`@for` y componentes standalone por defecto, que aquí no aplican.
- **Casi cualquier artículo o respuesta anterior a 2023 describe un componente distinto con el mismo nombre.** No es que esté desactualizado en los detalles: es que el DOM, las clases y varias entradas cambiaron. Antes de copiar una solución de CSS, mira su fecha.
- **Los módulos `@angular/material/legacy-*` existen en la 16 y desaparecieron después.** Si tu proyecto heredado los usa, esa migración está a medias y tiene una fecha límite. CertCore no los tiene.
- **`mat.core()` una sola vez.** Repetirlo en varios `.scss` duplica CSS base sin que nada falle, y lo notarás en el presupuesto de bundle de la Fase 13, no en desarrollo.

---

## 📚 Referencias

- https://v16.material.angular.io — la referencia por defecto de este apéndice. Cada componente tiene su pestaña de API y su pestaña de ejemplos.
- https://v16.material.angular.io/guide/theming — `define-palette`, `define-light-theme`, `mat.core()` y los mixins de componente.
- https://v16.material.angular.io/guide/typography — `define-typography-config` y `define-typography-level`.
- https://v16.material.angular.io/guide/theming-your-components — la guía sobre densidad, y sobre qué está soportado personalizar.
- https://v16.material.angular.io/components/form-field/overview — `appearance`, `subscriptSizing`, y la regla del control único.
- https://v16.material.angular.io/components/table/overview — `mat-table` con array y con `MatTableDataSource`, y `trackBy`.
- https://v16.material.angular.io/components/dialog/api — `MatDialogRef` con sus dos genéricos y `MAT_DIALOG_DATA`.
- https://github.com/angular/components/blob/16.2.x/guides/mdc-migration.md — la guía oficial de migración a MDC. Es el documento que explica, componente por componente, qué cambió; es la mejor lectura si heredas un proyecto a medio migrar.

> ⚠️ Los enlaces con `v16.` delante son estables; los que no lo llevan te van a llevar a la versión actual sin avisar. Si un ejemplo que copias no compila, comprueba la URL antes que el código.

**Orden de lectura sugerido:** la §1 antes que nada, aunque sólo sea para saber por qué lo que encuentres en internet puede estar describiendo otra cosa. La §3 con la Fase 6 abierta, que es donde escribes tu primer formulario. La §4 cuando la tabla no repinte. La §2 y la §7 sólo si tienes que justificar por qué el tema no se toca. La §8 el día que estés a punto de escribir un `::ng-deep` — y ojalá sea antes y no después.

---

## 🧪 Ejercicios (8)

1. 🟢 Cambia `appearance="outline"` por `appearance="fill"` en el formulario de clientes y compara las dos capturas. Después prueba `appearance="legacy"` y anota el error exacto que da el compilador de plantillas.

2. 🟢 Saca un `<mat-error>` fuera de su `<mat-form-field>`, deja el campo inválido y comprueba qué pasa: cuántos errores hay en consola, y qué ve el usuario. Devuélvelo dentro.

3. 🟡 Cambia `density: -1` por `0` y por `-3` en el tema, y mide en las tres configuraciones cuántos campos del formulario de clientes caben sin hacer scroll a 900 px de alto. Anota las tres cifras y defiende la elección de la Fase 6 —o discútela— con esos números delante.

4. 🟡 Añade `subscriptSizing="dynamic"` a los dos campos del formulario de clientes, provoca un error de validación y observa el salto del layout. Explica en dos líneas por qué el valor por defecto es el otro.

5. 🟡 Añade un `trackBy` a la tabla de clientes. Después quítalo, pon el foco en una fila, provoca una emisión del estado y anota qué pasa con el foco en cada caso.

6. 🟠 Reproduce el bug de la referencia: muta el array de clientes con un `push` desde el componente y comprueba que la tabla con `OnPush` no se entera. Arréglalo con el reemplazo y verifica que la pantalla heredada de activos se comportaba distinto durante todo el rato.

7. 🟠 Abre el diálogo de confirmación y ciérralo de tres formas: pulsando "Cancelar", pulsando Escape y haciendo clic fuera. Anota qué emite `afterClosed()` en cada caso y explica por qué el filtro compara contra `true` en vez de usar un `if (result)`.

8. 🔴 Te llega un ticket: *"la tabla de plantillas es demasiado alta, no caben las diez filas en la pantalla del supervisor"*. Resuélvelo **tres veces** —con `mat.table-density` sobre una clase, con el `density` global del tema, y con un `::ng-deep`— y escribe medio párrafo por cada una diciendo qué se rompe con esa solución dentro de dos años, cuando alguien actualice Material. Entrega la que elegirías y por qué.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y las pantallas que explica las escriben las Fases 6 a 10, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 06: …`, `fase 10: …`). Las mediciones de los ejercicios 3 y 8 van en el mensaje de un tag anotado (`ej/a01/3`), que es donde una cifra queda fechada y comparable. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
APPENDIX_EOF
wc -l a01-material.md

# --- 2026-09-06T23:02:01 · Write A08
cat > a08-pdf-cliente.md <<'APPENDIX_EOF'
# 📎 Apéndice A08 — PDF en cliente con jsPDF 2

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: Fase 10 · Versión cubierta: `jspdf` 2.5.1 + `jspdf-autotable` 3.8.x

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve el problema que empieza justo donde termina el ejemplo oficial: **armar el certificado en PDF desde el navegador más allá de las cinco líneas del README**, con acentos, con una tabla que pagina, con encabezado repetido, y sin meter 300 KB en el bundle inicial de todo el mundo.

Y hay una cosa que este apéndice repite aunque la Fase 10 ya la enseñe, porque es el error que todo el mundo comete **dos** veces: **el documento se arma desde la fuente del dato, nunca desde lo que hay pintado en la vista.**

**Qué queda fuera:** la firma digital real (jsPDF no la hace y no hay forma honesta de simularla), PDF/A y cualquier requisito de archivo normativo, y la generación en servidor — que se nombra en la §8 como el límite y no se implementa, porque CertCore no tiene backend propio. `pdfmake` y `html2canvas` se comparan en una tabla y **no se instalan**: el stack está cerrado.

---

## Índice

- [1. Coordenadas: por qué todo sale corrido la primera vez](#1-coordenadas-por-qué-todo-sale-corrido-la-primera-vez)
- [2. Acentos y fuentes: la mecánica exacta](#2-acentos-y-fuentes-la-mecánica-exacta)
- [3. La tabla de hallazgos con `jspdf-autotable`](#3-la-tabla-de-hallazgos-con-jspdf-autotable)
- [4. Encabezado y pie en todas las páginas](#4-encabezado-y-pie-en-todas-las-páginas)
- [5. Imágenes, y lo que pesan](#5-imágenes-y-lo-que-pesan)
- [6. Los 300 KB, y el `import()` que los difiere](#6-los-300-kb-y-el-import-que-los-difiere)
- [7. ⚠️ El documento se arma desde el dato](#7-️-el-documento-se-arma-desde-el-dato)
- [8. Los límites: cuándo esto se hace en el servidor](#8-los-límites-cuándo-esto-se-hace-en-el-servidor)
- [9. El PDF descargado no se revoca](#9-el-pdf-descargado-no-se-revoca)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-7)

---

## 1. Coordenadas: por qué todo sale corrido la primera vez

```ts
const document = new jsPDF();
// Equivale a new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' }),
// que es exactamente lo que queremos: A4 vertical, medidas en milímetros.
```

Tres cosas que hay que interiorizar de una vez, y con eso se acaba el 90% del desconcierto:

**El origen está arriba a la izquierda y la `y` crece hacia abajo.** Al revés que en las matemáticas del colegio, igual que en el DOM.

**La `y` de `text()` es la línea base, no el borde superior.** `document.text('Certificado', 20, 20)` **no** deja el texto a 20 mm del borde: deja *la base de las letras* a 20 mm, así que la primera línea empieza más arriba de lo que crees, y por eso el primer intento siempre parece desplazado hacia arriba.

**No hay flujo.** Nada empuja a nada. Si escribes dos textos en la misma `y`, se superponen y el PDF sale perfecto y con las letras encima unas de otras. Todo el trabajo de "una línea debajo de la otra" lo llevas tú, y ésa es la diferencia de fondo con generar HTML.

La consecuencia práctica es que un documento de más de tres líneas se escribe **con un cursor**, no con números sueltos:

```ts
// Un cursor y una función que avanza. Escribir `document.text(x, 20)`,
// `document.text(x, 27)`, `document.text(x, 34)` a mano es cómo se llega a un
// documento imposible de modificar: cambiar una línea desplaza catorce números.
const MARGIN_X = 20;
const LINE_HEIGHT = 7;
let cursorY = 25;

const writeLine = (text: string): void => {
  document.text(text, MARGIN_X, cursorY);
  cursorY += LINE_HEIGHT;
};

writeLine(`Certificado ${source.certificate.id}`);
writeLine(`Cliente: ${source.client.legalName}`);
writeLine(`Activo: ${source.asset.description}`);
```

**Las tres medidas que vas a necesitar sí o sí:**

```ts
const pageWidth = document.internal.pageSize.getWidth();    // 210 en A4 vertical
const pageHeight = document.internal.pageSize.getHeight();  // 297
const textWidth = document.getTextWidth('Certificado');     // en la unidad del doc
```

Con `getTextWidth` se centra o se alinea a la derecha sin adivinar, y con `splitTextToSize` se parte un texto largo en líneas que caben:

```ts
// La descripción de un hallazgo puede tener 300 caracteres. Sin esto, se sale
// del papel: jsPDF no recorta ni avisa, simplemente escribe fuera de la página.
const lines = document.splitTextToSize(finding.description, pageWidth - MARGIN_X * 2);
document.text(lines, MARGIN_X, cursorY);
cursorY += lines.length * LINE_HEIGHT;
```

> ⚠️ **jsPDF nunca se queja.** Escribir fuera de la página, superponer dos textos, pasarse del borde inferior: todo eso produce un PDF válido con el contenido mal puesto. **La única verificación posible es abrir el archivo y mirarlo.** No hay nada en consola, no hay nada en Network. Es un cambio de hábito real para quien viene de un stack donde los errores se ven.

---

## 2. Acentos y fuentes: la mecánica exacta

Éste es el tema que la Fase 10 deja explícitamente aquí, y conviene contarlo bien porque la creencia popular —"jsPDF no soporta acentos"— es falsa y hace que la gente embeba fuentes que no necesita.

**Cómo funciona.** jsPDF trae las catorce fuentes estándar del formato PDF (Helvetica, Times, Courier y sus variantes) y **no las embebe**: las referencia, y las pinta el lector de PDF. Esas fuentes usan una codificación de un solo byte —de la familia de `cp1252`/WinAnsi—, y **el español entero cabe ahí**: `á é í ó ú ü ñ Ñ ¿ ¡ °` están todos. Por eso el certificado de CertCore sale con sus tildes puestas sin hacer nada especial.

**Lo que sí se rompe**, y es lo que la gente confunde con "los acentos no funcionan":

- **Caracteres fuera de esa codificación de un byte.** Flechas (`→`), símbolos de verificación (`✓`, `✗`), emoji, y cualquier alfabeto no latino. En un certificado eso aparece el día que alguien decide que la columna de estado quede más bonita con un `✓`.
- **Texto que ya llegó mal decodificado.** Si el dato viene con *mojibake* —`MarÃ­n` en vez de `Marín`— el PDF reproduce fielmente lo que le diste. El fallo está tres capas más atrás, y la pista es que en la pantalla también se ve mal si miras con atención.
- **Una fuente de marca que no es una de las catorce**, usada sin embeber. Ahí el lector sustituye por otra y el resultado varía según quién abra el archivo.

**Cuándo hay que embeber, y cómo.** Sólo en los dos últimos casos. La mecánica son tres pasos y un archivo grande:

```ts
// 1. La fuente convertida a base64. Se genera una vez con el conversor oficial
//    de jsPDF y queda como un .js que exporta una cadena enorme.
import { robotoRegularBase64 } from './roboto-regular.font';

// 2. Se mete en el sistema de archivos virtual de jsPDF y se registra.
document.addFileToVFS('Roboto-Regular.ttf', robotoRegularBase64);
document.addFont('Roboto-Regular.ttf', 'Roboto', 'normal');

// 3. Se activa. A partir de aquí, todo el texto usa esa fuente.
document.setFont('Roboto', 'normal');
```

> ⚠️ **Una fuente embebida no es gratis: es un archivo de cientos de kilobytes que se suma al PDF y, si lo importas arriba, también al bundle.** Y hay que embeber **una variante por estilo**: la negrita es otro archivo y otro `addFont(..., 'bold')`. Antes de embeber, la pregunta correcta es *¿qué carácter concreto se está rompiendo?* — y bastante a menudo la respuesta es un `✓` que se puede escribir como "Sí".

**Cómo se verifica.** Mirando el PDF, y sólo así. Un caracter roto no produce nada en consola. Los dos textos que hay que meter siempre en el certificado de prueba son un nombre con tilde y una eñe: `Edificio Aurora S.A.S. — inspección de ascensores, señalización`.

---

## 3. La tabla de hallazgos con `jspdf-autotable`

Dibujar una tabla a mano con `text()` y `line()` es posible y es una pérdida de tiempo: `jspdf-autotable` mide las columnas, parte el texto, salta de página y repite la cabecera.

```ts
// Se importa por separado y se pasa como parámetro a la función pura que arma
// el documento, para que ese archivo no arrastre la librería. Ver la Fase 10.
const autoTable = (await import('jspdf-autotable')).default;

autoTable(document, {
  startY: cursorY + 5,
  head: [['Ítem', 'Severidad', 'Estado', 'Nota']],
  body: findings.map((finding) => [
    finding.itemTitle,
    severityLabel(finding.severity),
    finding.resolved ? 'Resuelto' : 'Pendiente',
    finding.note ?? '',
  ]),
  styles: { fontSize: 9, cellPadding: 2 },
  headStyles: { fillColor: [63, 81, 181] },   // el índigo del tema, en RGB
  // Las anchuras se fijan donde importa y se dejan libres donde no: sin esto,
  // una nota larga estruja la columna de severidad hasta hacerla ilegible.
  columnStyles: {
    0: { cellWidth: 55 },
    1: { cellWidth: 25 },
    2: { cellWidth: 25 },
    3: { cellWidth: 'auto' },
  },
  margin: { left: 20, right: 20 },
});

// Dónde terminó la tabla, para seguir escribiendo debajo. Es la propiedad que
// más se busca del plugin y la que peor se encuentra en su documentación.
cursorY = (document as unknown as { lastAutoTable: { finalY: number } }).lastAutoTable.finalY + 10;
```

**Detalles con intención**

- **`head` es un array de filas, no un array de columnas.** `head: [['A', 'B']]` es una fila de dos columnas; `head: ['A', 'B']` es otra cosa y produce una tabla desconcertante sin dar error.
- **Todo el contenido de `body` tiene que ser texto.** Un `null` o un `undefined` en una celda se pinta como vacío o como la palabra literal según la versión; convertirlos explícitamente (`finding.note ?? ''`) es lo que hace que el resultado sea el mismo siempre.
- **El acceso a `lastAutoTable`** necesita un estrechamiento porque el plugin extiende el prototipo de `jsPDF` sin que los tipos del paquete principal lo sepan. Con `strict` puesto, `as unknown as {...}` con la forma mínima es lo honesto: `any` no.

---

## 4. Encabezado y pie en todas las páginas

`autoTable` expone ganchos que corren una vez por página, y el de dibujado es donde va todo lo que se repite.

```ts
autoTable(document, {
  // …head, body, styles…
  margin: { top: 35, left: 20, right: 20, bottom: 20 },   // hueco para el encabezado
  didDrawPage: () => {
    // Encabezado: corre en cada página que la tabla genere, incluida la primera.
    document.setFontSize(10);
    document.text(`Certificado ${source.certificate.id}`, 20, 15);
    document.text(`Emitido: ${source.certificate.issuedAt}`, 20, 21);
  },
});
```

**El pie con "página X de Y" es otro problema**, y la razón es estructural: mientras dibujas la página 1 no sabes cuántas habrá. Se resuelve en dos pasadas, al final, y es la receta que vas a copiar cada vez:

```ts
// Después de todo el contenido, cuando el total ya se conoce.
const totalPages = document.getNumberOfPages();
const pageHeight = document.internal.pageSize.getHeight();

for (let page = 1; page <= totalPages; page += 1) {
  document.setPage(page);
  document.setFontSize(8);
  document.text(`Página ${page} de ${totalPages}`, 20, pageHeight - 10);
}
```

> 💡 **El pie es el sitio del rastro.** Un certificado que sale de la empresa gana mucho con una línea que diga de qué momento son sus datos: `Generado el 2026-03-14 09:41 (-05:00)`. No es adorno — es lo que permite, dentro de dos años, saber si el PDF que alguien archivó reflejaba el estado de entonces. La zona horaria explícita es la de la **Fase 10**, y por la misma razón.

---

## 5. Imágenes, y lo que pesan

```ts
// La imagen va como data URL o como HTMLImageElement ya cargado. Las medidas
// son las del PDF (mm), no píxeles: aquí el logo mide 40 mm de ancho.
document.addImage(logoDataUrl, 'PNG', 20, 10, 40, 12);
```

Tres cosas que deciden el peso del archivo, y en un certificado con logo importan más de lo que parece:

**El formato.** `PNG` conserva transparencia y comprime sin pérdida — bien para un logo, muy mal para una fotografía. `JPEG` es lo contrario. Una evidencia fotográfica de una inspección metida como PNG multiplica el tamaño del PDF por varias veces sin ganar nada visible.

**La resolución real, no la del PDF.** Pasar una imagen de 4000 px de ancho y dibujarla a 40 mm **no la reduce**: el archivo carga los 4000 px enteros. Si el PDF va a llevar fotos de evidencia, hay que reescalarlas antes —con un `canvas`— y ese redimensionado es trabajo del cliente, no de jsPDF.

**El data URL en base64 ocupa un tercio más que el binario.** Es el precio de meterlo en una cadena, y es inevitable con esta API.

> ⚠️ **Un certificado con diez fotos de evidencia a resolución de cámara es un PDF de decenas de megabytes que nadie va a poder adjuntar a un correo.** Si el requisito aparece, la conversación no es sobre jsPDF: es sobre si esas evidencias van en el documento o van enlazadas — y ésa es la primera pregunta de la §8.

---

## 6. Los 300 KB, y el `import()` que los difiere

`jspdf` con `jspdf-autotable` es, con diferencia, la dependencia más pesada que este curso instala: el orden de magnitud que mide la Fase 10 son **unos 300 KB** añadidos al bundle.

Importarla arriba —en el servicio, en el módulo, o en cualquier archivo que se cargue de forma *eager*— la mete en `main.js`, y entonces **la descarga todo el mundo**: el inspector que sólo abre el formulario, el supervisor que sólo mira la lista, y quien entra a `/login` y se equivoca de contraseña.

```ts
// ✅ Dentro de un método privado, y sólo aquí. El bundler la deja en un chunk
//    propio que no se pide hasta que alguien pulsa "Descargar PDF".
private async render(source: CertificateDocumentSource): Promise<void> {
  const { jsPDF } = await import('jspdf');
  const autoTable = (await import('jspdf-autotable')).default;

  const document = buildCertificateDocument(new jsPDF(), source, autoTable);
  document.save(`${source.certificate.id}.pdf`);
}
```

```ts
// ✅ En el archivo puro que arma el documento, sólo el TIPO. `import type`
//    desaparece en la compilación: no arrastra ni un byte.
import type { jsPDF } from 'jspdf';
```

**Cómo se comprueba, que es lo que de verdad hay que saber hacer:**

```bash
ng build --named-chunks --stats-json
grep -o '"name":"[^"]*jspdf[^"]*"' dist/certcore/stats.json | sort -u
```

Si `jspdf` aparece dentro de `main`, algún archivo lo está importando arriba, y el culpable casi siempre es un `import { jsPDF } from 'jspdf'` en la cabecera de un servicio. El síntoma en producción es que el bundle inicial engorda 300 KB **para todos los usuarios**, incluidos los que nunca descargan un certificado.

> 💡 **La primera descarga tarda un poco más, y está bien.** Diferir significa que el chunk se pide cuando el usuario pulsa el botón. En una red lenta eso son unas décimas visibles; a cambio, todos los arranques de la aplicación son 300 KB más ligeros. Si quieres las dos cosas, el chunk se puede precargar cuando el usuario entra al detalle del certificado, que es un buen momento porque ahí ya se sabe que va a descargar.

---

## 7. ⚠️ El documento se arma desde el dato

> 🧭 **Regla del proyecto: lo que hay en la pantalla es una foto de hace un rato. Está bien para mirar y está mal para imprimir. Cualquier artefacto que sobreviva a la sesión —un PDF, un correo, un export— se arma pidiendo el dato otra vez.**

Ésta es la 💸 que la **Fase 10** declara en su §5.7 y paga en su §5.8, tras el **incidente 14**, y se repite aquí porque es el error que todo el mundo comete dos veces: una al escribirlo por primera vez, y otra seis meses después, cuando hay que añadir un campo al PDF y lo más rápido es sacarlo del objeto que la pantalla ya tiene.

El fallo no se parece a un fallo. El usuario abre el detalle de un certificado, se queda en esa pestaña, otra persona resuelve un hallazgo desde otro equipo, y él pulsa "Descargar PDF" veinte minutos después. **El PDF sale perfecto**, con acentos, con la tabla alineada, y afirma que hay un hallazgo mayor sin resolver. No hay error en consola, no hay nada rojo en Network, y el documento ya está camino de un correo.

Lo que lo hace peligroso no es que el dato esté viejo: es que **el PDF es el único artefacto del sistema que sobrevive al sistema**. Una pantalla desactualizada se arregla con F5. Un PDF desactualizado se archiva, se imprime y se adjunta a la respuesta de un requerimiento normativo.

**Cómo se escribe la versión correcta**, en dos decisiones:

**Una interfaz explícita con todo lo que el documento necesita.** Que sea un tipo con nombre y no "lo que tenga el componente" es la mitad del arreglo: se ve de un vistazo que hacen falta seis cosas, y las seis tienen que venir de la fuente.

```ts
export interface CertificateDocumentSource {
  readonly certificate: Certificate;
  readonly view: CertificateView;
  readonly inspection: Inspection;
  readonly template: ChecklistTemplate;   // la versión CONGELADA de la inspección
  readonly asset: Asset;
  readonly client: Client;
  readonly findings: readonly InspectionFinding[];
}
```

**El armado es una función pura y vive en `core/pdf/`, no en la feature.** La feature sabe pedir datos y disparar una descarga; el documento es dominio. Es la misma frontera que la Fase 9 trazó entre `core/domain/` y las pantallas, y por la misma razón: lo que se puede probar sin navegador se prueba sin navegador.

**Prueba de fuego.** Abre el detalle de un certificado. Sin cerrar esa pestaña, abre otra y resuelve uno de sus hallazgos. Vuelve a la primera —que sigue mostrando el estado viejo— y descarga el PDF. **La tabla del PDF tiene que traer el hallazgo resuelto aunque la pantalla de detrás diga lo contrario.**

---

## 8. Los límites: cuándo esto se hace en el servidor

Generar en cliente tiene tres ventajas reales —no hay infraestructura, no hay latencia de red, y el dato no sale del navegador— y unos límites que conviene reconocer **antes** de haber escrito mil líneas de maquetación.

**Se queda corto cuando aparece cualquiera de estas cinco:**

- **Firma digital con validez legal.** jsPDF no la hace y ninguna librería de cliente puede: firmar exige una clave privada, y una clave privada en el navegador no es una clave privada.
- **PDF/A o cualquier requisito de archivo a largo plazo.** Es una familia de restricciones sobre fuentes embebidas, metadatos y color que jsPDF no garantiza.
- **El documento tiene que ser idéntico para todo el mundo, siempre.** En cliente depende del navegador, de la versión de la librería que tenga cacheada y de las fuentes disponibles. Si el PDF es la prueba de algo, esa variabilidad es un problema.
- **Maquetación compleja de verdad**: columnas, flotantes, texto que fluye alrededor de imágenes. jsPDF no tiene flujo (§1) y todo eso se convierte en aritmética a mano.
- **Volumen.** Un PDF por certificado está bien; cuatrocientos PDF en un lote no se generan en la pestaña de nadie.

**Las alternativas, comparadas y no instaladas:**

| | Cómo funciona | Le va bien | Le va mal |
|---|---|---|---|
| **jsPDF** (lo que usa CertCore) | dibujas con coordenadas | documentos de estructura fija y conocida | maquetación compleja, tipografía fina |
| **pdfmake** | describes el documento como un objeto y él maqueta | tablas y listas anidadas, flujo entre páginas | bundle mayor; el modelo declarativo hay que aprenderlo |
| **html2canvas + jsPDF** | captura el DOM como imagen y la mete en un PDF | reproducir exactamente lo que se ve | **el resultado es una imagen**: sin texto seleccionable, sin búsqueda, pesado, y borroso al imprimir |
| **Servidor** (Puppeteer, wkhtmltopdf, una librería de backend) | HTML o plantilla renderizados fuera | firma, PDF/A, lotes, resultado idéntico siempre | infraestructura, latencia, y un servicio más que mantener |

> ⚠️ **`html2canvas` merece un párrafo propio porque es la trampa más tentadora.** "Convertir la pantalla en PDF" suena a la solución perfecta y a menudo es la peor: produce un documento que es una foto, y una foto de un certificado no se puede buscar, no se puede copiar, pesa cinco veces más y se ve mal impresa. Además choca de frente con la regla de la §7 — armar el documento desde la vista es exactamente lo que ese enfoque hace por diseño.

---

## 9. El PDF descargado no se revoca

Merece medio párrafo porque es la mejor conversación que ofrece este tema sobre los límites de lo que un sistema puede garantizar.

Un certificado se puede **revocar** en CertCore: el estado pasa a `revoked` y todas las pantallas lo reflejan. **El PDF que alguien descargó ayer no se entera de nada.** Está en el disco de una persona, probablemente reenviado por correo, y no hay ninguna acción del sistema que lo alcance. Podrías generar uno nuevo; no puedes desandar el que salió.

Lo que sí se puede hacer, y es lo que hacen los sistemas serios, es reducir el daño:

- **Fechar el documento en el propio documento.** El pie de la §4 con la fecha y la hora de generación es lo mínimo, y convierte "este PDF miente" en "este PDF es de antes de la revocación", que es una conversación completamente distinta.
- **Poner un identificador y un punto de verificación.** Un código y una frase del tipo *"el estado vigente de este certificado se consulta en el sistema"* traslada la autoridad de vuelta a la fuente. Es lo que hace que el papel sea una copia y no el original.
- **No prometer en el PDF lo que el PDF no puede sostener.** Un documento que dice "vigente" sin más está afirmando algo sobre el futuro. Uno que dice "vigente al 14/03/2026 09:41" está afirmando algo que seguirá siendo cierto para siempre.

> 🧠 Ésta es la lección transferible del apéndice entero, y no es sobre PDF: **un artefacto que sale del sistema deja de estar bajo el control del sistema.** Todo lo que quieras poder afirmar sobre él dentro de dos años tiene que estar impreso dentro de él.

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer | Por qué |
|---|---|---|
| Documento de estructura fija | jsPDF con un cursor y funciones | es para lo que sirve |
| Una tabla que puede paginar | `jspdf-autotable` con `didDrawPage` | maquetar tablas a mano no compensa nunca |
| Texto largo en una celda o un párrafo | `splitTextToSize` | jsPDF escribe fuera del papel sin avisar |
| Texto en español | las fuentes estándar, sin tocar nada | el español cabe en su codificación |
| Un `✓`, una flecha, un emoji | cambiarlo por texto, o embeber fuente | y embeber cuesta cientos de KB |
| Un logo | PNG, reescalado antes | PNG para gráficos, JPEG para fotos |
| Fotos de evidencia | reescalar en `canvas` y JPEG | o decidir que van enlazadas y no incrustadas |
| Importar la librería | `await import()` dentro del método | 300 KB que no viajan en el arranque |
| El tipo de `jsPDF` en un archivo puro | `import type` | desaparece en la compilación |
| Componer el contenido | desde la fuente, con una interfaz explícita | la vista es una foto de hace un rato |
| Firma, PDF/A, lotes | servidor | no es una limitación de la librería: es del navegador |
| "Que salga igual que la pantalla" | replantear el requisito | `html2canvas` produce una foto, no un documento |

---

## 📚 Referencias

- https://github.com/parallax/jsPDF — el repositorio de `jspdf`. El README es el punto de partida y se queda corto enseguida, que es la razón de este apéndice.
- https://raw.githack.com/MrRio/jsPDF/master/docs/index.html — la documentación de la API generada, con `text`, `addImage`, `splitTextToSize`, `setPage` y `getNumberOfPages`. ⚠️ Documenta la rama principal; comprueba que el método que buscas exista en 2.5.1.
- https://github.com/simonbengtsson/jsPDF-AutoTable — `jspdf-autotable` 3.8.x, con sus opciones y sus ganchos. Los ejemplos de la página de demostración son la mejor referencia de `columnStyles` y `didDrawPage`.
- https://github.com/parallax/jsPDF/tree/master/fontconverter — el conversor oficial de fuentes a base64 de la §2.
- https://developer.mozilla.org/es/docs/Web/API/HTMLCanvasElement/toDataURL — para el reescalado de imágenes de la §5.
- http://pdfmake.org — la alternativa declarativa de la tabla de la §8. Se compara y no se instala.

> ⚠️ Las versiones de estas dos librerías se mueven más deprisa que su documentación, y varias respuestas populares de Stack Overflow describen la API de jsPDF 1.x, que era incompatible. La señal es `new jsPDF()` con argumentos posicionales (`new jsPDF('p', 'mm', 'a4')`): eso es la 1.x, y aunque siga tolerándose, es la marca de un ejemplo viejo.

**Orden de lectura sugerido:** la §1 antes de escribir la primera línea, porque sin las tres reglas de coordenadas todo lo demás parece magia. La §7 **antes** que la §3 y la §6 — es la única que trata de un bug con consecuencias fuera del sistema. La §2 sólo cuando algo salga con cuadros en el PDF. La §6 cuando midas el bundle en la Fase 13. La §8 y la §9 el día que alguien pregunte si el certificado tiene validez legal, que es una pregunta que llega siempre.

---

## 🧪 Ejercicios (7)

1. 🟢 Genera un PDF con tres `document.text()` en la misma `y`. Ábrelo y anota qué ves. Después arréglalo con el patrón del cursor de la §1 y explica en una línea por qué la consola no dijo nada en el primer caso.

2. 🟢 Escribe en el certificado un texto con tildes y eñes (`Edificio Aurora S.A.S. — inspección de señalización`) y otro con un `✓`. Abre el PDF y anota cuál de los dos se rompe. Explica por qué, con la §2 en la mano.

3. 🟡 Añade a la tabla de hallazgos una nota de 300 caracteres. Anota qué hace `autoTable` con ella, y qué pasa si el mismo texto lo escribes con `document.text()` sin `splitTextToSize`.

4. 🟡 Haz que el certificado ocupe tres páginas —duplicando hallazgos en la semilla— y añade el pie "Página X de Y" con la técnica de dos pasadas de la §4. Explica en dos líneas por qué no se puede hacer en una sola pasada.

5. 🟠 Mueve el `import { jsPDF } from 'jspdf'` a la cabecera del servicio. Construye con `ng build --named-chunks --stats-json`, localiza en qué chunk quedó la librería y anota el tamaño de `main.js` antes y después. Devuélvelo al `await import()` y anota la tercera cifra.

6. 🟠 Reproduce el incidente 14 completo: abre el detalle de un certificado en una pestaña, resuelve uno de sus hallazgos en otra, y descarga el PDF desde la primera. Después verifica que la versión de la Fase 10 §5.8 trae el dato correcto. Escribe el post-mortem de tres líneas: síntoma, causa raíz y prevención.

7. 🔴 Te llega el requisito: *"el certificado en PDF tiene que llevar firma digital con validez ante el ente regulador"*. Escribe la respuesta técnica de una página que le darías a tu líder: por qué no se puede hacer en el cliente, qué haría falta, qué alternativa hay mientras tanto (con la §9 como argumento), y una estimación honesta de qué implica montarlo en servidor. El criterio de éxito es que alguien de negocio entienda por qué la respuesta no es "una semana".

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y el generador de certificados lo escribe la **Fase 10**, así que lo que salga de leerlo se commitea con el prefijo de esa fase (`fase 10: …`). Las tres cifras del ejercicio 5 van en el mensaje de un tag anotado (`ej/a08/5`), que es donde una medición de bundle queda fechada y comparable con la de la Fase 13. Si haces el ejercicio 6, el par de tags del incidente 14 está reservado en el cuaderno y es donde el `git diff` entre roto y arreglado **es** el fix aislado del ruido de la fase. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
APPENDIX_EOF
wc -l a08-pdf-cliente.md

# --- 2026-09-06T23:02:08 · Self-check tanda 2
for f in a01-material.md a08-pdf-cliente.md; do echo "=== $f ==="; echo -n "ejercicios: "; awk '/^## 🧪 Ejercicios/,0' $f | grep -cE '^[0-9]+\. '; echo -n "tag block: "; grep -c '00-convencion-de-git-y-tags.md' $f; echo -n "any: "; grep -cE ': any\b|as any|<any>' $f; echo -n "v16 material/refs: "; grep -c 'v16.material.angular.io' $f; done; echo "--- enlaces a .md ---"; grep -hoE '\]\([a-z0-9][^)]*\.md\)' a01-material.md a08-pdf-cliente.md | sort -u

# --- 2026-09-06T23:12:06 · Fase 13 Dockerfile y nginx
sed -n '385,470p' 13-build-despliegue.md; echo "=== nginx 5.5 ==="; sed -n '457,525p' 13-build-despliegue.md

# --- 2026-09-06T23:12:11 · Fase 14 kind load y root
sed -n '199,260p' 14-casi-prod-kind.md; echo "=== ejercicio 15 y deuda root ==="; grep -n 'runAsNonRoot\|root\|CrashLoopBackOff\|ImagePullBackOff\|latest' 14-casi-prod-kind.md | head -25

# --- 2026-09-06T23:12:14 · Fase 14 ConfigMap y nota latest
sed -n '344,405p' 14-casi-prod-kind.md; echo "=== git tags docker latest ==="; sed -n '370,382p' 00-convencion-de-git-y-tags.md

# --- 2026-09-06T23:15:13 · Write A09
cat > a09-docker-kubernetes.md <<'APPENDIX_EOF'
# 📎 Apéndice A09 — Docker y Kubernetes para el dev de front

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: Fase 13, Fase 14 · Versión cubierta: Docker Engine 24+ · nginx 1.25 · kind (el que traiga tu runtime)

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve tres cosas muy concretas del día a día de alguien que mantiene un front y no administra un cluster: **leer un manifiesto ajeno sin adivinar, saber qué le pasa a tu imagen después del `docker build`, y hablar con el equipo de plataforma sin sentirte turista.**

Ese último objetivo es el que ordena el apéndice. No vas a operar el cluster; vas a tener que diagnosticar por qué tu aplicación no arranca en él, y a pedir lo que necesites con las palabras correctas.

**Qué queda fuera:** Helm, operadores, service mesh, autoescalado, políticas de red y todo lo que sea administración del cluster — no es tu trabajo y saberlo a medias es peor que no saberlo. Y también quedan fuera el `Dockerfile`, el `nginx.conf` y el `entrypoint.sh` concretos del proyecto: ésos los escribe y los explica la **Fase 13**, línea por línea. Aquí está lo que hace falta para entenderlos, no su repetición.

---

## Índice

- [1. Qué es una imagen, y qué le pasa después del `docker build`](#1-qué-es-una-imagen-y-qué-le-pasa-después-del-docker-build)
- [2. Tag frente a digest, y por qué `:latest` te va a morder](#2-tag-frente-a-digest-y-por-qué-latest-te-va-a-morder)
- [3. El vocabulario, en seis palabras](#3-el-vocabulario-en-seis-palabras)
- [4. Por qué un Secret no es un secreto](#4-por-qué-un-secret-no-es-un-secreto)
- [5. 👁️ ✍️ La caja de herramientas](#5-️-️-la-caja-de-herramientas)
- [6. Los estados de un pod, traducidos](#6-los-estados-de-un-pod-traducidos)
- [7. Leer los logs de un contenedor que ya murió](#7-leer-los-logs-de-un-contenedor-que-ya-murió)
- [8. ⚠️ Tu cluster no es el del libro](#8-️-tu-cluster-no-es-el-del-libro)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-8)

---

## 1. Qué es una imagen, y qué le pasa después del `docker build`

Una imagen es **un sistema de archivos congelado más una receta de arranque**. Nada más. No es un proceso, no está corriendo, y no tiene estado: es un archivo comprimido por capas con todo lo que el contenedor va a ver como su disco.

Un contenedor es esa imagen **más un proceso vivo** y una capa de escritura efímera encima. Cuando el proceso muere, la capa de escritura se va con él. Es la razón por la que un contenedor no guarda nada por su cuenta y por la que un cambio hecho con `docker exec` desaparece en el siguiente reinicio.

**Las capas son la parte que hay que entender para no perder minutos en cada build.** Cada instrucción del `Dockerfile` produce una capa, y Docker reutiliza las que no cambiaron. Por eso el Dockerfile de la **Fase 13** copia primero los manifiestos y sólo después el código:

```dockerfile
COPY package.json package-lock.json ./
RUN npm ci                              # ← esta capa se reutiliza…
COPY . .                                # ← …mientras esta línea no invalide nada
RUN npm run build -- --configuration production
```

Si copiaras todo de una vez, cualquier línea que toques en un `.ts` invalidaría la capa del `npm ci` y cada recompilación reinstalaría el árbol entero.

**Y ahora la pregunta que da título a la sección: ¿qué le pasa a la imagen después del `docker build`?**

Nada. Se queda en el almacén local de tu runtime de contenedores y **no existe en ningún otro sitio del universo**. Ni en un servidor, ni en un cluster, ni en la máquina de tu compañero. Para que exista en otro sitio, alguien tiene que moverla, y sólo hay tres formas:

- **Empujarla a un registro** (`docker push`) y que quien la necesite la baje. Es lo que se hace de verdad.
- **Cargarla a mano en un nodo** (`kind load docker-image`, o `docker save` + `kind load image-archive`). Es lo que hace la **Fase 14** para no obligarte a montar un registro.
- **Exportarla como archivo** (`docker save`) y llevarla por otro medio. Es lo que queda cuando no hay red.

> 🧠 **El patrón a memorizar, y es el mismo de la Fase 14.** Una imagen que existe en tu máquina no existe en ningún otro sitio hasta que alguien la mueve. Es la verdad detrás del `ErrImagePull` de kind, del *"funciona en mi máquina"* de siempre, y de la razón por la que existen los registros.

**La conversación que `kind load` te ahorra y que en tu empresa vas a tener igual.** En un cluster real no hay `kind load`: hay un registro —Harbor, ECR, GCR, Artifactory, el de GitLab— con autenticación, con permisos por proyecto, y con un `imagePullSecret` en el namespace que le da al kubelet las credenciales para bajar. Cuando tu pod diga `ImagePullBackOff` en el cluster de la empresa y la imagen exista, las tres preguntas son: **¿está empujada al registro correcto?**, **¿el nodo llega a ese registro por red?**, y **¿el namespace tiene el `imagePullSecret`?**. Ésa es toda la diferencia entre el laboratorio y la realidad, y sabiendo las tres preguntas ya puedes abrir el ticket bien.

---

## 2. Tag frente a digest, y por qué `:latest` te va a morder

Una imagen se puede nombrar de dos maneras, y sólo una de las dos identifica algo:

```bash
certcore:fase-13                              # un TAG: una etiqueta movible
certcore@sha256:9f2c…                         # un DIGEST: el hash del contenido
```

**Un tag es un post-it.** Se puede despegar y pegar en otra imagen. `certcore:fase-13` señala hoy a una imagen y mañana puede señalar a otra si alguien vuelve a construir con el mismo nombre. **Un digest es el contenido**: dos imágenes con el mismo digest son bit a bit la misma, siempre, en cualquier máquina.

**Y `:latest` es el peor post-it de todos**, por tres razones que se acumulan:

- **No significa "la última".** No significa nada: es el tag por defecto cuando no pones ninguno. Una imagen etiquetada `:latest` puede llevar ahí ocho meses.
- **Cambia la política de descarga.** Kubernetes usa `imagePullPolicy: IfNotPresent` para tags normales y **`Always` para `:latest`**. Con `:latest`, el nodo se va a buscar la imagen aunque ya la tenga — que en kind, donde no hay registro, significa `ErrImagePull` con la imagen delante.
- **Hace imposible la pregunta que ordena el final del curso.** *"¿Por qué esta imagen se comporta distinto en UAT y en PROD?"* empieza por saber qué código hay dentro de cada una. Con `:latest` en las dos, esa pregunta no tiene respuesta.

> 🧭 **Regla del proyecto: la imagen se etiqueta con el mismo nombre del tag de git que la produjo.** `certcore:fase-13` sale del tag `fase-13`, y un hotfix produce `certcore:hotfix-2026-03-14` o lo que corresponda. Cuesta un guion en la línea de `docker build` y te da la mitad barata de cualquier diagnóstico de ambientes. Está anunciado en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) y desarrollado aquí.

**En producción, el paso siguiente es fijar el digest.** Un Deployment que dice `image: certcore@sha256:9f2c…` corre exactamente esos bytes y nadie puede cambiárselos por debajo moviendo un tag. Es más incómodo de leer y es lo que hace que un despliegue sea reproducible. Si tu equipo de plataforma te lo pide, es por esto.

```bash
# 👁️ El digest de una imagen local, para citarla sin ambigüedad
docker images --digests | grep certcore
```

---

## 3. El vocabulario, en seis palabras

Con estas seis se lee el 95% de los manifiestos que te van a pasar. Cada una responde a una pregunta.

**Pod — *¿dónde corre mi contenedor?*** Es la unidad mínima que Kubernetes programa: uno o varios contenedores que comparten red y almacenamiento, y que viven y mueren juntos. En la práctica, para un front, es un contenedor. **Un pod es desechable**: no tiene nombre estable, no tiene IP estable, y el cluster lo mata y lo recrea sin avisarte. Todo lo que hagas dentro de un pod a mano se pierde.

**Deployment — *¿quién se encarga de que haya pods?*** Declara cuántas réplicas quieres y de qué imagen, y se ocupa de que eso sea verdad. Es también quien sabe hacer un despliegue sin cortar el servicio: crea los pods nuevos, espera a que estén listos, y retira los viejos. Cuando alguien dice "rolling update", habla de esto.

**Service — *¿qué nombre estable tienen esos pods?*** Los pods cambian de IP; el Service no. Da un nombre DNS interno y reparte el tráfico entre los pods que coincidan con su selector. En la Fase 14, `certcore-mock` es un Service, y por eso el `proxy_pass` del `nginx.conf` puede escribirlo por nombre.

**Ingress — *¿cómo se entra desde fuera?*** Es la puerta HTTP del cluster: reglas de host y de ruta que mandan el tráfico externo a un Service. **Un Ingress no hace nada por sí solo**: necesita un controlador instalado que lo lea y lo implemente. Es la causa número uno de "apliqué el Ingress y no pasa nada".

**ConfigMap — *¿de dónde salen los valores que cambian por ambiente?*** Un mapa de clave-valor que se puede exponer al contenedor como variables de entorno o montar como archivos. Es el `-e` de `docker run`, con nombre y versionado.

**Secret — *lo mismo, pero para credenciales.*** Y ahí hay que pararse (§4).

> ⚠️ **La trampa del ConfigMap consumido como variables de entorno**, que es exactamente el incidente que la Fase 14 provoca: se lee **una sola vez, al arrancar el proceso**. Cambiar el ConfigMap no toca los pods que ya corren — siguen con los valores de cuando nacieron, tan tranquilos, mientras `kubectl get configmap` te enseña los nuevos. Hace falta un `kubectl rollout restart deployment/…`. Montado como volumen sí se actualiza solo, con retraso y sin reiniciar el proceso, lo que trae su propio conjunto de sorpresas.

---

## 4. Por qué un Secret no es un secreto

Un `Secret` de Kubernetes guarda su contenido en **base64**. Base64 no es cifrado: es una forma de escribir bytes con caracteres imprimibles, y se deshace con un comando de veinte caracteres.

```bash
# 👁️ Cualquiera con permiso de lectura sobre el namespace hace esto:
kubectl get secret certcore-api-key -o jsonpath='{.data.token}' | base64 -d
```

Lo que un Secret **sí** te da, y no es poco:

- Está **separado del manifiesto**, así que el YAML del Deployment se puede commitear sin credenciales dentro.
- Tiene **permisos propios**: el control de acceso del cluster puede dejar leer ConfigMaps y no Secrets.
- **No se imprime por accidente** en un `kubectl describe`, que sí muestra el contenido de un ConfigMap.
- Puede estar **cifrado en reposo** en el almacén del cluster, si el administrador lo configuró — y ésa es la pregunta que hay que hacerle a plataforma, porque por defecto en muchas instalaciones **no lo está**.

Lo que **no** te da: confidencialidad frente a nadie que pueda leer el namespace, ni frente a quien pueda abrir una shell en el pod, ni rotación, ni auditoría de quién lo leyó.

> 🧭 **La consecuencia práctica para un dev de front, y es la que importa: un secreto que llega al navegador ya no es un secreto, venga de donde venga.** Cualquier valor que acabe en `assets/config.json`, en un bundle o en una variable del `entrypoint.sh` es público: está en el disco de todos los usuarios. La clave de una API de terceros no se pone ahí ni aunque venga de un Secret perfectamente configurado — se pone detrás de un backend que la use por ti. Es la misma frontera que la **Fase 2** traza con el guard: *un guard no es seguridad porque corre en el navegador.* Aquí es idéntico.

---

## 5. 👁️ ✍️ La caja de herramientas

Marcados por lo que hacen. Los 👁️ se pueden ejecutar en cualquier sitio sin pensarlo dos veces; los ✍️ **cambian el estado del cluster** y en el de tu empresa se ejecutan sabiendo qué namespace tienes seleccionado.

**Docker — mirar**

```bash
docker images                                    # 👁️ qué imágenes hay localmente
docker images --digests | grep certcore          # 👁️ el digest, para citar sin ambigüedad
docker ps -a                                     # 👁️ contenedores, incluidos los muertos
docker logs <contenedor>                         # 👁️ su salida estándar
docker inspect <imagen|contenedor>               # 👁️ todo: capas, variables, puertos, usuario
docker history <imagen>                          # 👁️ las capas y qué las creó
```

**Docker — tocar**

```bash
docker build -t certcore:fase-13 .               # ✍️ construye (local)
docker run --rm -p 8080:80 certcore:fase-13      # ✍️ levanta un contenedor
docker exec -it <contenedor> sh                  # ✍️ shell dentro; lo que cambies se pierde
docker save certcore:fase-13 -o certcore.tar     # ✍️ escribe un archivo
```

**Kubernetes — mirar (esto es el 90% de tu trabajo con un cluster)**

```bash
kubectl config current-context                   # 👁️ EN QUÉ CLUSTER ESTOY. Antes de nada.
kubectl get pods                                 # 👁️ qué hay corriendo y en qué estado
kubectl get pods -o wide                         # 👁️ …con nodo e IP
kubectl describe pod <pod>                       # 👁️ los EVENTOS al final: ahí está la causa
kubectl logs <pod>                               # 👁️ la salida del contenedor actual
kubectl logs <pod> --previous                    # 👁️ la del intento anterior. Ver §7.
kubectl logs deploy/certcore --tail=100 -f       # 👁️ en vivo, por Deployment
kubectl get configmap certcore-config -o yaml    # 👁️ qué valores hay de verdad
kubectl get events --sort-by=.lastTimestamp      # 👁️ qué ha pasado últimamente, en orden
kubectl get deploy,svc,ingress                   # 👁️ el mapa de la aplicación de un vistazo
```

**Kubernetes — tocar**

```bash
kubectl apply -f k8s/certcore.yaml               # ✍️ crea o actualiza lo declarado
kubectl rollout restart deployment/certcore      # ✍️ recrea los pods (releer un ConfigMap)
kubectl rollout status deployment/certcore       # 👁️ …aunque acompaña siempre al anterior
kubectl rollout undo deployment/certcore         # ✍️ vuelve a la revisión anterior
kubectl exec -it deploy/certcore -- sh           # ✍️ shell dentro de un pod
kubectl port-forward svc/certcore 8080:80        # ✍️ abre un túnel a tu máquina
kubectl delete pod <pod>                         # ✍️ lo mata; el Deployment lo recrea
```

> ⚠️ **`kubectl config current-context` antes de cualquier ✍️.** Es el equivalente de mirar en qué rama estás antes de un `push --force`, y el fallo tiene el mismo perfil: cuesta un segundo comprobarlo y cuesta una tarde muy mala no haberlo hecho. En un cluster compartido, añade `-n <namespace>` a todo o fija el namespace por defecto.

> 💡 **`kubectl describe` es el comando que más se subestima.** Su información útil está **al final**, en la sección `Events`: ahí es donde el cluster te dice, en español llano y en orden cronológico, que no encontró la imagen, que no hay nodo con recursos, o que el contenedor se murió con un código concreto. Nueve de cada diez diagnósticos empiezan y terminan ahí.

---

## 6. Los estados de un pod, traducidos

| Lo que dice `kubectl get pods` | Qué significa de verdad | Por dónde se empieza |
|---|---|---|
| `Pending` | el cluster todavía no lo ha colocado en ningún nodo | `describe`: no hay recursos, o no hay nodo que cumpla las restricciones |
| `ContainerCreating` | está bajando la imagen o montando volúmenes | normal unos segundos; si se queda, `describe` |
| `ErrImagePull` / `ImagePullBackOff` | no consiguió la imagen | ¿está empujada? ¿llega el nodo al registro? ¿hay `imagePullSecret`? (§1) |
| `Running` | el contenedor arrancó | ⚠️ **arrancar no es funcionar**: mira `READY 1/1`, no sólo el estado |
| `CrashLoopBackOff` | arrancó, se murió, y lleva varios intentos; el cluster espera cada vez más entre uno y otro | `logs --previous` (§7) |
| `OOMKilled` (en `describe`) | se pasó del límite de memoria y el kernel lo mató | subir el límite, o averiguar por qué consume eso |
| `Completed` | el proceso terminó **bien** | correcto en un Job; en un Deployment significa que tu proceso no se queda vivo |
| `Terminating` | le pidieron que se fuera y aún no se ha ido | si se queda ahí, algo no responde a la señal de apagado |

**Dos precisiones que ahorran mucho tiempo:**

**`Running` con `READY 0/1` es un pod que no sirve tráfico.** El contenedor está vivo y su prueba de disponibilidad no pasa, así que el Service no le manda nada. Si la aplicación "está desplegada" y no responde, ésta es la primera columna que hay que mirar.

**`CrashLoopBackOff` no es un error: es una consecuencia.** El error real ocurrió hace unos segundos, en el arranque anterior, y está en los logs de ese intento. El estado sólo te dice que ya ha pasado varias veces.

> 💡 **En un Mac con chip M hay un `CrashLoopBackOff` con causa propia**: la imagen está construida para amd64 y el nodo es arm64. `kubectl describe` no lo explica bien y los logs vienen vacíos. Es lo primero que hay que descartar en Apple Silicon, y el diagnóstico completo está en **A12** 🔥.

---

## 7. Leer los logs de un contenedor que ya murió

Es la técnica que separa diagnosticar de adivinar, y son dos comandos.

```bash
kubectl logs <pod>                # 👁️ el intento ACTUAL, que a lo mejor aún no ha fallado
kubectl logs <pod> --previous     # 👁️ el intento ANTERIOR: aquí está el mensaje que buscas
```

Un contenedor en `CrashLoopBackOff` arranca, falla y se reinicia. Cuando tú escribes `kubectl logs`, estás mirando el intento en curso — que puede llevar dos segundos de vida y no haber llegado todavía al error. El mensaje que explica todo está en el anterior, y `--previous` es la única forma de verlo.

**Y cuando ni eso alcanza**, tres recursos más:

```bash
# 👁️ Los eventos del pod: por qué el cluster hizo lo que hizo
kubectl describe pod <pod> | tail -30

# 👁️ Todos los eventos del namespace en orden, cuando no sabes ni qué pod mirar
kubectl get events --sort-by=.lastTimestamp

# ✍️ Arrancar el contenedor con otro comando para poder entrar a mirar.
#    Sustituye el arranque por un `sleep` y te deja una shell dentro de una
#    imagen que de otro modo se muere antes de que puedas escribir nada.
kubectl run debug --rm -it --image=certcore:fase-13 --command -- sh
```

> ⚠️ **Los logs de un pod borrado no existen.** Si el Deployment recrea el pod, el anterior se fue y sus logs con él. En un cluster de verdad eso lo resuelve un agregador —Loki, ELK, CloudWatch, el que tenga tu empresa— y **preguntar cuál es** debería ser una de las primeras cosas que hagas al llegar a un equipo. Sin agregador, cada diagnóstico es una carrera contra el reinicio.

---

## 8. ⚠️ Tu cluster no es el del libro

Esta sección es obligatoria y es la razón por la que este apéndice existe en vez de un enlace a la documentación de Kubernetes.

Todo lo anterior describe un Kubernetes de manual, y el de tu empresa **no lo es**. Tiene políticas de admisión, cuotas de recursos, namespaces con permisos que quizá no incluyan lo que necesitas, redes segmentadas, controladores de Ingress con anotaciones propias, y un conjunto de convenciones que sólo su equipo de plataforma conoce entero. Ninguna de esas cosas está mal documentada: simplemente es de ellos y no está en ningún libro.

**Y hay una que te va a pasar casi seguro, así que conviene contarla completa.**

La imagen de la **Fase 13** corre nginx como **root**, escuchando en el **puerto 80**. Eso funciona en tu máquina, funciona en kind, y en el cluster de tu empresa se va a caer, porque casi cualquier política de seguridad razonable prohíbe las dos cosas: los contenedores no corren como root, y los puertos por debajo de 1024 requieren privilegios que no vas a tener.

```yaml
# La política que lo prohíbe se parece a esto. Con añadirlo a tu pod
# reproduces el fallo en local antes de que te lo reporten:
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 101
```

El pod entra en `CrashLoopBackOff` y los logs dicen que nginx no puede escribir en `/var/cache/nginx` ni escuchar en el 80.

**El arreglo de verdad son cuatro cambios coordinados**, y ninguno es difícil:

1. **La imagen base pasa a una variante sin privilegios** — `nginxinc/nginx-unprivileged` es la oficial y ya viene preparada: corre como usuario `101` y sus directorios de caché son escribibles por ese usuario.
2. **El puerto pasa a uno por encima de 1024** — el 8080 es la convención. Cambia en el `nginx.conf` (`listen 8080;`) y en el `EXPOSE` del Dockerfile.
3. **El Deployment y el Service se ajustan** al puerto nuevo: `containerPort: 8080` y el `targetPort` del Service.
4. **El `entrypoint.sh` tiene que poder escribir donde escribe.** Genera `assets/config.json` dentro del directorio servido, y con un usuario sin privilegios eso hay que comprobarlo, no suponerlo.

> 🧭 **La instrucción que acompaña a todo esto, y es la parte importante: pregúntale al equipo de plataforma antes de improvisar.** No porque no puedas averiguarlo —acabas de leer cómo—, sino porque en un cluster compartido las decisiones ya están tomadas y hay una forma correcta de hacer cada cosa que no vas a deducir leyendo. Las cinco preguntas que valen una reunión de quince minutos y ahorran una semana:
>
> 1. **¿A qué registro empujo, y cómo se autentica el cluster contra él?**
> 2. **¿Qué políticas de seguridad se aplican a mi namespace?** (usuario, puertos, sistema de archivos de sólo lectura, capacidades)
> 3. **¿Qué probes espera el equipo, y contra qué ruta?**
> 4. **¿Dónde se ven los logs cuando el pod ya se recicló?**
> 5. **¿Quién puede desplegar, y por qué camino?** (¿aplico yo un manifiesto, o hay un pipeline?)

Y una advertencia final, que también es una liberación: **lo que la Fase 14 monta no es producción, y no pretende serlo.** No hay probes, ni límites de recursos, ni TLS, ni registro, ni políticas de admisión, ni la conversación sobre quién despliega qué. Es un ambiente "casi prod" para que entiendas las piezas, y entenderlas es exactamente lo que te permite hacer las cinco preguntas de arriba en vez de asentir.

---

## 🧭 Cuándo usar qué

| Situación | Comando o decisión | Por qué |
|---|---|---|
| Antes de cualquier comando que escriba | 👁️ `kubectl config current-context` | el `--force` a la rama equivocada, versión cluster |
| El pod no arranca y no sabes por qué | 👁️ `kubectl describe pod` y mira los `Events` | ahí está la causa, en orden cronológico |
| `CrashLoopBackOff` | 👁️ `kubectl logs --previous` | el intento actual todavía no ha fallado |
| `ImagePullBackOff` con la imagen delante | ¿empujada? ¿red? ¿`imagePullSecret`? | el nodo no ve tu almacén local |
| Cambiaste un ConfigMap y no pasa nada | ✍️ `kubectl rollout restart deployment/…` | las variables de entorno se leen al arrancar |
| Quieres ver la aplicación sin Ingress | ✍️ `kubectl port-forward svc/…` | túnel directo, sin tocar nada del cluster |
| Necesitas saber qué código hay en la imagen | etiquetar con el tag de git; en producción, digest | `:latest` no responde esa pregunta |
| Una credencial que usa el navegador | **no existe tal cosa** | lo que llega al navegador es público (§4) |
| El despliegue salió mal | ✍️ `kubectl rollout undo deployment/…` | primero recuperar el servicio, después diagnosticar |
| Cualquier duda sobre el cluster de tu empresa | preguntar a plataforma | las decisiones ya están tomadas y no se deducen |

---

## 📚 Referencias

- https://docs.docker.com/build/building/best-practices — capas, caché y por qué el orden del `Dockerfile` importa.
- https://docs.docker.com/reference/cli/docker/image/tag — tags y digests, con la explicación de por qué un tag es movible.
- https://kubernetes.io/docs/concepts/workloads/pods — Pod, y la frase clave sobre que son desechables.
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment — Deployment y rolling update.
- https://kubernetes.io/docs/concepts/services-networking/service · https://kubernetes.io/docs/concepts/services-networking/ingress — Service e Ingress, incluida la nota de que un Ingress necesita un controlador.
- https://kubernetes.io/docs/concepts/configuration/configmap — ConfigMap, con la diferencia entre consumirlo como variables y como volumen.
- https://kubernetes.io/docs/concepts/configuration/secret — Secret. ⚠️ Lee la sección *Risks*: la propia documentación oficial dice que base64 no es cifrado y que el cifrado en reposo hay que configurarlo.
- https://kubernetes.io/docs/reference/kubectl/quick-reference — la chuleta de `kubectl`, que conviene tener abierta las primeras semanas.
- https://kubernetes.io/docs/tasks/debug/debug-application/debug-pods — la guía oficial de diagnóstico de pods, que es la §6 y la §7 con más detalle.
- https://hub.docker.com/r/nginxinc/nginx-unprivileged — la imagen sin privilegios de la §8.
- https://kind.sigs.k8s.io — kind, para la Fase 14.

> ⚠️ La documentación de Kubernetes describe la versión más reciente y las cosas cambian de sitio entre versiones —sobre todo en API de red y en políticas de seguridad—. Si un campo de un manifiesto no te lo acepta el cluster, comprueba primero la versión con `kubectl version` antes de dudar del ejemplo.

**Orden de lectura sugerido:** la §1 y la §2 antes de la Fase 13, que es donde construyes tu primera imagen. La §3 antes de la Fase 14, para que los manifiestos se lean en vez de descifrarse. La §5, la §6 y la §7 el día que algo no arranque — y ese día llega. La §8 dos veces: una al terminar la Fase 14, y otra el día antes de tu primera reunión con el equipo de plataforma.

---

## 🧪 Ejercicios (8)

1. 🟢 Construye la imagen de la Fase 13, cambia una línea de un `.ts` y vuelve a construir. Anota qué capas dice Docker que reutilizó. Después mueve el `COPY . .` al principio del Dockerfile, repite, y compara los dos tiempos.

2. 🟢 Ejecuta `docker images --digests` y anota el digest de tu imagen. Vuelve a construirla sin cambiar nada y compáralo. Después cambia una línea, reconstruye con **el mismo tag**, y compara otra vez. Explica en dos líneas qué acabas de demostrar sobre los tags.

3. 🟡 Crea un Secret con `kubectl create secret generic demo --from-literal=token=abc123` y recupera su valor en claro con un solo comando. Después escribe tres líneas explicándole a un compañero qué te da un Secret y qué no.

4. 🟡 Provoca los cuatro estados de la §6 en el cluster de la Fase 14 y anota, para cada uno, qué comando te dio la causa: `ImagePullBackOff` (aplica sin cargar la imagen), `CrashLoopBackOff` (`command: ["sh", "-c", "exit 1"]`), `Running` con `READY 0/1` (una probe que apunte a una ruta que no existe) y `Pending` (pide `resources.requests` imposibles de satisfacer).

5. 🟡 Con un pod en `CrashLoopBackOff`, ejecuta `kubectl logs` y `kubectl logs --previous` y pega las dos salidas. Explica por qué la segunda es la que sirve, en una frase que un compañero pueda repetir.

6. 🟠 Cambia el ConfigMap de la Fase 14 sin reiniciar nada y comprueba que `kubectl get configmap` dice una cosa y `kubectl exec … cat config.json` dice otra. Después arréglalo con `rollout restart`. Escribe el post-mortem de tres líneas y compáralo con el del incidente de caché de la Fase 13: son el mismo bug con dos mecanismos.

7. 🟠 Etiqueta tu imagen como `:latest`, despliégala en kind y anota qué pasa. Después mira el `imagePullPolicy` efectivo con `kubectl get pod <pod> -o yaml | grep imagePullPolicy` y explica el fallo con la §2 en la mano.

8. 🔴 Cierra la 💸 que la Fase 13 dejó abierta, completa. Añade `runAsNonRoot: true` al pod y reproduce el fallo. Después aplica los cuatro cambios de la §8 —imagen base sin privilegios, puerto 8080, Deployment y Service ajustados, y comprobar que el `entrypoint.sh` puede escribir— hasta que la aplicación vuelva a funcionar con la política puesta. Entrega dos cosas: el diff de los cuatro archivos, y el párrafo que le mandarías al equipo de plataforma explicando qué cambió y por qué. El criterio de éxito del párrafo es que alguien que no conozca CertCore entienda el cambio sin abrir el diff.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y la imagen, el `nginx.conf` y los manifiestos los escriben las Fases 13 y 14, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 13: …`, `fase 14: …`). El ejercicio 8 es la excepción interesante: **deja archivos versionados** —Dockerfile, `nginx.conf` y los dos manifiestos—, así que va como un commit de fase normal y merece su propio tag de ejercicio (`ej/a09/8`), que es lo que después te permite leer el cambio entero con un `git diff fase-14 ej/a09/8`. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
APPENDIX_EOF
wc -l a09-docker-kubernetes.md; echo -n "ejercicios: "; awk '/^## 🧪 Ejercicios/,0' a09-docker-kubernetes.md | grep -cE '^[0-9]+\. '; echo -n "ojos/plumas: "; grep -c '👁️\|✍️' a09-docker-kubernetes.md

# --- 2026-09-06T23:59:29 · Explore Track A course
cd ../angular-8-legacy-for-backend-devs && ls && echo "=== README head ===" && sed -n '1,60p' README.md

# --- 2026-09-06T23:59:36 · Track A NgRx structure and mirror appendix
cd ../angular-8-legacy-for-backend-devs && grep -n '^## \|^### ' 01-estructura-base-ngrx.md | head -40; echo "=== a11 de Track A (espejo) ==="; sed -n '1,50p' a11-migracion-9-16.md

# --- 2026-09-06T23:59:44 · Track A identifiers and versions
cd ../angular-8-legacy-for-backend-devs && grep -n 'class .*Guard\|class .*Interceptor\|implements CanActivate\|implements HttpInterceptor\|FormBuilder\|FormGroup\|takeUntil\|Subscription\|\.bind(this)\|var self' 03-autenticacion.md 05-pacientes.md | head -25; echo "=== versiones ==="; grep -n '"@angular/core"\|"rxjs"\|"@ngrx/store"\|"typescript"\|"node"' 00-setup-hola-mundo.md 01-estructura-base-ngrx.md | head

# --- 2026-09-06T23:59:49 · Track A versions and domain
cd ../angular-8-legacy-for-backend-devs && grep -n '8\.2\.14\|ngrx\|rxjs.*6\.\|typescript.*3\.' README.md | head -12; echo "=== selectores/prefijo ==="; grep -n "prefix\|selector: '" 00-setup-hola-mundo.md | head -6; echo "=== dominio versionado ==="; grep -n 'rango de referencia\|referenceRange\|version' 08-resultados-rangos.md | head -8

# --- 2026-09-07T00:02:13 · Write A10
cd ../angular-16-legacy-for-backend-devs && cat > a10-migracion-9-16.md <<'APPENDIX_EOF'
# 📎 Apéndice A10 — Puente Angular 8/9 → 16

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: lectores que vienen del Track A (LabCore) · De consulta en todas las fases
> Versión cubierta: de Angular 8.2.14 / 9 hasta 16.2.12

**Esto no se lee de corrido, y además no es una guía de migración.** Es un **puente conceptual**: sirve para que alguien con los reflejos de Angular 8 puestos pueda leer el código de CertCore sin traducir mentalmente cada línea. No propone migrar nada, no explica `ng update`, y no hay ningún proyecto que llevar de una versión a la otra.

**Y es el único documento de este curso donde nombrar LabCore es correcto**, porque su lector es exactamente quien vino del Track A y trae ocho fases de laboratorio clínico en los dedos. Si llegaste directo al Track B y no sabes qué es LabCore, **este apéndice es opcional y puedes saltártelo entero**: nada del curso depende de él.

**Qué queda fuera:** el procedimiento real de migrar —`ng update` una mayor por vez, leer el diff de las schematics, `ngcc`, la ficha por dependencia, el ensayo en rama desechable—. Eso está desarrollado en el propio Track A, en sus apéndices A10 y A11, y no se repite aquí porque este documento va en la otra dirección: no cómo llegar, sino **cómo leer lo que hay al otro lado**.

---

## Índice

- [1. Para quién es esto, y para quién no](#1-para-quién-es-esto-y-para-quién-no)
- [2. Las cuatro puertas](#2-las-cuatro-puertas)
- [3. Qué desapareció y qué sólo cambió de nombre](#3-qué-desapareció-y-qué-sólo-cambió-de-nombre)
- [4. RxJS 6 → 7](#4-rxjs-6--7)
- [5. Formularios sin tipar → tipados](#5-formularios-sin-tipar--tipados)
- [6. Guards e interceptors de clase → funcionales](#6-guards-e-interceptors-de-clase--funcionales)
- [7. NgRx de 2019 → estado en servicios](#7-ngrx-de-2019--estado-en-servicios)
- [8. ⭐ Tabla de traducción LabCore → CertCore](#8--tabla-de-traducción-labcore--certcore)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-7)

---

## 1. Para quién es esto, y para quién no

**Es para ti si** acabas de terminar el Track A —o lo estás haciendo— y abres el primer archivo de CertCore con la sensación de que está escrito en otro idioma. No lo está: son las mismas ideas con siete versiones encima. Este apéndice te dice cuáles de tus reflejos siguen sirviendo, cuáles cambiaron de nombre, y cuáles hay que desaprender.

**No es para ti si** llegaste directo al Track B. Aquí no hay nada que las fases no expliquen por su cuenta, y leer sobre las carencias de Angular 8 antes de haber escrito una línea de la 16 no aclara nada.

> 🧠 **La buena noticia primero, porque es la más grande.** Lo que aprendiste en el Track A no era Angular 8: era **cómo se lee, se depura y se arregla un sistema heredado sin romperlo**. Eso no caduca con las versiones. La máquina de estados, el versionado por fecha, el ticket vago, el diff de ambientes, el post-mortem sin culpabilización — todo eso vale igual aquí. Lo que cambia es la sintaxis, y la sintaxis se traduce en una tarde.

---

## 2. Las cuatro puertas

Ocho versiones mayores suenan a ocho problemas y no lo son. Todo lo que te va a desconcertar de CertCore cabe en cuatro cambios, y los cuatro tienen fecha.

**Puerta 1 — Ivy (Angular 9).** LabCore compila con ViewEngine; CertCore con Ivy. Para ti, como lector de código, cambia poco: la sintaxis de las plantillas es la misma. Cambia mucho para lo que ves cuando algo falla — los mensajes de error de Ivy son otros, llevan código (`NG0100`, `NG0203`) y apuntan mejor— y para lo que sale del build, porque Ivy es lo que hizo posible que un componente exista sin `NgModule`, que es la puerta 3.

**Puerta 2 — `strict` (Angular 10 lo ofrece, la decisión es del proyecto).** LabCore vive con `strict: false` y `any` tolerado; CertCore tiene `strict: true` desde el primer archivo y `any` prohibido. **Ésta es la puerta que más trabajo te va a dar y la que más te va a devolver.** Una familia entera de bugs del Track A —el campo que llegó `undefined`, la cadena mágica de `patientForm.get('documentID')` con la D mayúscula— aquí sencillamente no compila.

**Puerta 3 — Standalone (estable en Angular 15).** Un componente puede declarar sus propias dependencias y no pertenecer a ningún `NgModule`. En LabCore, todo componente vive en un `declarations`; en CertCore conviven las dos formas a propósito, y decidir en cuál escribes es el músculo central del track.

**Puerta 4 — `inject()` (Angular 14).** La inyección se sale del constructor. Es la que menos cambia el comportamiento y la que más cambia el aspecto del código: un servicio de CertCore normalmente **no tiene constructor**, y la primera vez eso desconcierta.

> 📝 **Y una que no es puerta pero sí es una diferencia de proyecto.** LabCore usa NgRx montado al estilo de 2019; CertCore usa servicios con `BehaviorSubject`. Eso no es una consecuencia de la versión: es una decisión distinta que tomaron dos equipos distintos (§7). Ninguna de las dos empresas se equivocó.

---

## 3. Qué desapareció y qué sólo cambió de nombre

| En LabCore (Angular 8) | En CertCore (Angular 16) | ¿Qué pasó? |
|---|---|---|
| `platformBrowserDynamic().bootstrapModule(AppModule)` | `bootstrapApplication(AppComponent, appConfig)` | forma nueva; la vieja sigue existiendo |
| `@NgModule` obligatorio para todo | `standalone: true` en código nuevo | el `NgModule` **no desapareció**: dejó de ser obligatorio |
| `constructor(private http: HttpClient)` | `private readonly http = inject(HttpClient)` | las dos formas conviven, incluso en CertCore |
| `HttpClientModule` en `imports` | `provideHttpClient(...)` en `providers` | forma nueva; la vieja sigue funcionando |
| `RouterModule.forRoot(routes)` | `provideRouter(routes)` o `RouterModule` | conviven; CertCore usa la heredada en el raíz |
| `loadChildren: () => import(...).then(m => m.Module)` | `loadComponent` o `loadChildren` a un array de rutas | se amplió: ahora una ruta puede cargar un componente suelto |
| `ngOnDestroy` + `Subscription.unsubscribe()` | `takeUntilDestroyed(destroyRef)` | añadido en la 16; las formas viejas siguen vivas |
| `.bind(this)` / `var self = this` | arrow functions | **esto sí desaparece**: en CertCore sería un anacronismo |
| `patientForm.get('documentId').value` → `any` | `form.controls.taxId.value` → `string` | los formularios se hicieron genéricos en la 14 |
| `entryComponents` | — | **desapareció de verdad** con Ivy: ya no hace falta |
| `ViewChild(..., { static: true })` | el `static` sigue existiendo y se usa poco | Ivy cambió el valor por defecto y dejó de ser el campo minado que era |

> 🧭 **La regla que resume la tabla: casi nada desapareció; casi todo se volvió opcional.** Angular ha sido notablemente cuidadoso con la compatibilidad hacia atrás, y por eso un sistema como CertCore puede tener módulos de 2021 conviviendo con componentes de 2024 sin que nada esté roto. Tu instinto de "esto es viejo, hay que cambiarlo" es exactamente el que este curso te va a pedir que reprimas.

---

## 4. RxJS 6 → 7

LabCore usa RxJS 6.5.5; CertCore usa 7.8.1. Tres diferencias visibles y ninguna conceptual:

```ts
// LabCore (RxJS 6)
import { map, switchMap } from 'rxjs/operators';
import { of, combineLatest } from 'rxjs';
const both$ = combineLatest(a$, b$);          // argumentos sueltos
const value = await someObservable.toPromise();

// CertCore (RxJS 7)
import { map, switchMap, of, combineLatest } from 'rxjs';   // todo desde 'rxjs'
const both$ = combineLatest([a$, b$]);        // siempre un array
const value = await firstValueFrom(someObservable);
```

- **Los imports.** En la 7 todos los operadores salen de `'rxjs'`. El `'rxjs/operators'` de la 6 sigue funcionando, en desuso, y verlo es la señal más rápida de que un ejemplo es viejo.
- **`combineLatest` con argumentos sueltos desapareció.** Ahora es siempre un array.
- **`toPromise()` está deprecado** y se sustituye por `firstValueFrom()` o `lastValueFrom()`, que además te obligan a decidir cuál querías — `toPromise()` devolvía el último valor y `undefined` si no había ninguno, que es de las peores decisiones de diseño de esta librería.

**Lo que no cambió es el 95%:** `map`, `switchMap`, `combineLatest`, `catchError`, `debounceTime`, `shareReplay` se comportan igual. Si en el Track A entendiste la diferencia entre `switchMap` y `mergeMap`, aquí no tienes nada nuevo que aprender.

**Lo que sí es nuevo y te va a gustar:** `takeUntilDestroyed()`, que no es de RxJS sino de Angular 16, y que hace en una línea lo que en LabCore era un campo `destroy$`, un `ngOnDestroy` y dos líneas dentro. El tratamiento completo de los ocho operadores del curso está en **A06**.

---

## 5. Formularios sin tipar → tipados

Aquí está el cambio con mejor relación entre esfuerzo y alivio de todo el puente.

```ts
// ── LabCore (Angular 8) ────────────────────────────────────────────────────
patientForm: FormGroup;

constructor(private fb: FormBuilder) {
  this.patientForm = this.fb.group({
    documentId: ['', Validators.required],
  });
}

// `get()` recibe una cadena mágica y devuelve AbstractControl | null.
// `documentID` con la D mayúscula devuelve null y nadie te avisa.
const value = this.patientForm.get('documentId').value;   // any
```

```ts
// ── CertCore (Angular 16) ──────────────────────────────────────────────────
interface ClientForm {
  legalName: FormControl<string>;
  taxId: FormControl<string>;
}

readonly form = new FormGroup<ClientForm>({
  legalName: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
  taxId: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
});

// Acceso por propiedad, tipado. `form.controls.taxID` no compila.
const value = this.form.controls.taxId.value;   // string
```

**Los tres reflejos que hay que cambiar:**

- **`form.get('campo')` pasa a ser `form.controls.campo`.** La cadena mágica —fuente de bugs número uno de los formularios de la época— desaparece.
- **Aparece un `| null` que en LabCore no existía.** `new FormControl('')` es `FormControl<string | null>` porque `reset()` deja el control en `null`. La respuesta es `nonNullable: true`, y toda la mecánica está en **A05** §1 y §2.
- **`value` deja de ser `any` y empieza a exigirte decisiones.** Es exactamente el trabajo de la puerta 2, concentrado en el sitio donde más se nota.

> 💡 **Y una que vas a agradecer sin darte cuenta.** En LabCore, `getRawValue()` y `value` daban lo mismo desde el punto de vista del compilador, porque los dos eran `any`. En CertCore el tipo de `value` es `Partial<…>` y el de `getRawValue()` no, y esa diferencia de tipo es lo que te va a hacer descubrir el bug de los controles deshabilitados **antes** de escribirlo en vez de después (**A05** §7).

---

## 6. Guards e interceptors de clase → funcionales

```ts
// ── LabCore (Angular 8) ────────────────────────────────────────────────────
@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
    if (this.authService.isAuthenticated()) {
      return true;
    }
    this.router.navigate(['/login']);
    return false;
  }
}
// …y en la ruta: { path: 'patients', canActivate: [AuthGuard] }
```

```ts
// ── CertCore (Angular 16) ──────────────────────────────────────────────────
export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }
  // Un UrlTree en vez de navigate(): el router cancela esta navegación y
  // ejecuta la otra en un solo paso, sin dos navegaciones compitiendo.
  return router.createUrlTree(['/login'], { queryParams: { returnUrl: state.url } });
};
// …y en la ruta: { path: 'clients', canActivate: [authGuard] }
```

**Lo que hay que saber para leer CertCore:**

- **La función recibe los mismos dos parámetros** que el método de la clase. No hay nada nuevo que aprender sobre guards.
- **Las dependencias entran con `inject()`, y sólo se puede llamar arriba del todo.** Dentro de un `catchError` o de un `subscribe` da `NG0203`. Ése es el error nuevo que te vas a encontrar, y está traducido en **A04** §7.
- **Las dos formas conviven en CertCore a propósito.** El `authInterceptor` es funcional y el `CorrelationIdInterceptor` es de clase, escrito en 2021 y sin tocar desde entonces. El archivo donde se registran los dos —`core.module.ts`— va marcado 🧬 y es el archivo más característico del track.

> 🧭 **Y aquí está la diferencia grande entre los dos cursos.** En LabCore, todo lo que se escribe es de una sola generación. En CertCore, **elegir en cuál de las dos generaciones escribes el fix es la habilidad que el curso entrena**. La regla es corta: código nuevo, estilo nuevo; código heredado, se toca lo mínimo y en su propio estilo, y nunca los dos en el mismo archivo.

---

## 7. NgRx de 2019 → estado en servicios

Ésta no es una diferencia de versión: es una decisión distinta de dos equipos distintos, y merece leerse así.

| | LabCore (2019) | CertCore (2022) |
|---|---|---|
| Qué se declara | acciones, reducer, selectores, effects | un servicio con un `BehaviorSubject` privado |
| Archivos por feature | cinco | uno |
| Cómo se lee | `store.select(selectPatients)` | `templateState.templates$` |
| Cómo se escribe | `store.dispatch(loadPatients())` | `templateState.load()` |
| Lo asíncrono | un `Effect` con `switchMap` | un método que llama al `*ApiService` |
| Herramientas | Redux DevTools, viaje en el tiempo | un `tap(console.log)` y un breakpoint |
| Trazabilidad | cada cambio tiene nombre | ninguna |

**La traducción mental, en tres frases:**

- **Un selector de NgRx es un derivado con `map`.** `selectPatients` se convierte en `readonly templates$ = this.state$.pipe(map(s => s.items), distinctUntilChanged())`. Lo que NgRx memoriza de fábrica, aquí lo compartes tú con `shareReplay({ bufferSize: 1, refCount: true })`.
- **Un effect es un método del servicio.** Todo lo que en LabCore era `ofType(loadPatients)` + `switchMap` + `map(loadPatientsSuccess)` aquí es un `load()` de doce líneas que llama al API, mete el resultado en el estado y guarda el error dentro del propio estado.
- **Un reducer es el `patch()` privado.** Un solo sitio que llama a `next()`, un solo breakpoint cuando algo quede raro.

**Lo que ganas:** un archivo por feature en vez de cinco, y nada que aprender antes de tocar nada.

**Lo que pierdes, y conviene decirlo porque tú **sí** conociste lo otro:** las devtools, el viaje en el tiempo, y sobre todo el registro de qué acción cambió qué. En un sistema cuyo dominio es la trazabilidad, esa ironía es la mejor sección de **A07**, que es donde esta conversación se cierra con criterios en vez de con preferencias.

---

## 8. ⭐ Tabla de traducción LabCore → CertCore

La sección que vas a consultar de verdad. A la izquierda, lo que tienes en los dedos; a la derecha, cómo se llama lo mismo aquí.

**Del stack**

| LabCore | CertCore |
|---|---|
| Angular 8.2.14 · CLI 8.3.29 | Angular 16.2.12 · CLI 16.2.12 |
| TypeScript 3.5.3, `strict: false` | TypeScript 5.1.6, `strict: true`, cero `any` |
| RxJS 6.5.5 | RxJS 7.8.1 |
| NgRx 8.6 | servicios con `BehaviorSubject`, sin librería |
| Bootstrap 4 + Material peleándose | Material 16 (MDC); Bootstrap sólo en **A02** 🔥 |
| Prefijo de selector `app-` | prefijo `cc-` |
| Tres idiomas con i18n en runtime | monolingüe, literales en plantilla (**A13** 🔥) |
| Deuda 💸 que **no** se paga | deuda 💸 que **se paga** cuando corresponde |

**Del código**

| LabCore | CertCore |
|---|---|
| `patients.actions.ts` + `.reducer.ts` + `.selectors.ts` + `.effects.ts` | `template-state.service.ts` |
| `patients.service.ts` (habla con HTTP) | `template-api.service.ts` (mismo papel, mismo nombre en espíritu) |
| `PatientListComponent` (componente gordo) | `TemplateListComponent` (componente honesto, más flaco) |
| `AuthGuard implements CanActivate` | `authGuard: CanActivateFn` |
| `AuthInterceptor implements HttpInterceptor` | `authInterceptor: HttpInterceptorFn` — y el `CorrelationIdInterceptor` **sigue siendo de clase** |
| `core.module.ts` con los singletons | `core.module.ts`, y sigue siendo el archivo donde todo se registra 🧬 |
| `.bind(this)` y `var self = this` | arrow functions, siempre |
| `patientForm.get('documentId')` | `form.controls.taxId` |
| `destroy$` + `takeUntil` + `ngOnDestroy` | `takeUntilDestroyed(this.destroyRef)` |

**Del dominio — y ésta es la fila que más vale**

| LabCore | CertCore |
|---|---|
| Paciente | Cliente (`Client`) |
| Orden médica | Inspección (`Inspection`) |
| Muestra con cadena de custodia | Activo (`Asset`) y su trazabilidad |
| Analito y resultado | Ítem de checklist (`ChecklistItem`) y respuesta (`InspectionAnswer`) |
| **Rango de referencia versionado** | **Plantilla de checklist versionada** (`ChecklistTemplate`) |
| "¿qué rango regía el día del resultado?" | "¿qué versión aplica a esta fecha?" |
| Entrega de resultados en PDF | Certificado en PDF |
| Bitácora de auditoría | trazabilidad de quién marcó qué y cuándo |

> 🧠 **La fila en negrita es la lección que se repite y por eso importa.** Los dos sistemas versionan algo por fecha, y los dos tienen su bug estrella en la misma pregunta: *"¿por qué esto se está viendo con la versión equivocada?"*. Lo que cambia es **dónde vive la respuesta**: en LabCore la resuelve un selector de NgRx comparando `Date` en el navegador —con la zona horaria perdiéndose en silencio, que es su 💸—; en CertCore la resuelve `resolveTemplateVersion`, una función pura con la zona horaria explícita, testeada sin `TestBed` en la Fase 12.
>
> Si te llevas una sola cosa de este apéndice, que sea ésta: **el problema es el mismo, la versión de Angular no lo resolvió, y lo que cambia el resultado es dónde decidiste poner la regla.**

---

## 🧭 Cuándo usar qué

| Vienes buscando… | Ve a |
|---|---|
| "¿por qué este servicio no tiene constructor?" | §2 puerta 4, y **A04** |
| "¿dónde están las acciones y el reducer?" | §7 |
| "`form.get('x')` no me compila" | §5, y **A05** |
| "este guard es una función, ¿dónde está la clase?" | §6, y **A04** §4 |
| "el import de `rxjs/operators` no existe" | §4, y **A06** |
| "¿por qué me obliga a decidir sobre `null`?" | §2 puerta 2 |
| "¿cómo se llama aquí lo que en LabCore era X?" | §8, la tabla |
| "¿y qué viene después de la 16?" | **A11** 🔥 |
| "quiero migrar de verdad un proyecto" | los apéndices A10 y A11 **del Track A** |

---

## 📚 Referencias

- https://v16.angular.io/guide/update-to-version-16 — la guía oficial de actualización a la 16. Útil como catálogo de cambios de ruptura, aunque aquí no migres nada.
- https://update.angular.io — el asistente oficial: eliges versión de origen y de destino y te lista lo que cambia. Poner 8 y 16 es la forma más rápida de ver el tamaño real del salto.
- https://blog.angular.io/version-9-of-angular-now-available-project-ivy-has-arrived-23c97b63cfa3 — el anuncio de Ivy, la puerta 1.
- https://v16.angular.io/guide/standalone-components — standalone, la puerta 3.
- https://v16.angular.io/guide/typed-forms — el cambio de la §5, explicado por quienes lo hicieron.
- https://rxjs.dev/deprecations — lo que salió entre RxJS 6 y 7, `toPromise()` incluido.
- https://ngrx.io/guide/migration — para dimensionar la distancia entre NgRx 8 y el actual, si tu curiosidad va por ahí.

> ⚠️ Casi toda la documentación oficial que encuentres hoy describe Angular 17 o posterior. Para leer CertCore, la referencia es `v16.angular.io`; para leer LabCore, la del Track A. Un ejemplo que use `@if` o `signal()` no pertenece a ninguno de los dos.

**Orden de lectura sugerido:** la §1 y la §2 el primer día, antes de abrir un solo archivo de CertCore. La §8 déjala abierta en una pestaña durante las primeras tres fases: es la que de verdad se consulta. Las §4 a la §7, cada una cuando el curso te ponga delante ese cambio concreto — la §5 con la Fase 6, la §6 con la Fase 2, la §7 con la Fase 4. La §3 sirve de repaso el día que quieras explicarle a alguien qué separa las dos versiones.

---

## 🧪 Ejercicios (7)

1. 🟢 Abre `core/auth.service.ts` de CertCore y el `patients.service.ts` de LabCore uno al lado del otro. Escribe en cinco líneas qué hace cada uno, y cuál de las diferencias entre los dos es de versión y cuál es de decisión de equipo.

2. 🟢 Traduce este fragmento de LabCore al estilo de CertCore, explicando cada cambio: `this.subscription = this.store.select(selectPatients).subscribe(function(patients) { this.patients = patients; }.bind(this));`

3. 🟡 Toma la definición del formulario de pacientes de LabCore (Fase 5 del Track A) y reescríbela como `FormGroup<T>` tipado con `nonNullable`. Anota cuántos accesos con cadena mágica desaparecieron y cuántos `| null` tuviste que decidir.

4. 🟡 Convierte el `AuthGuard` de LabCore a `CanActivateFn`, incluyendo el cambio de `router.navigate()` a `createUrlTree()`. Explica en dos líneas por qué el segundo es mejor y qué problema del historial de navegación evita.

5. 🟠 Toma el flujo completo de "cargar pacientes" de LabCore —acción, effect, reducer, selector— y escríbelo como un `*StateService` de CertCore. Cuenta las líneas de los dos y las responsabilidades de cada uno. Después escribe el párrafo honesto: qué perdiste en el cambio, no sólo qué ganaste.

6. 🟠 Compara `resolveTemplateVersion` de la Fase 7 de CertCore con el selector de rango vigente de la Fase 8 de LabCore. Identifica dónde vive la zona horaria en cada uno, y explica por qué uno de los dos se puede testear sin navegador y el otro no.

7. 🔴 Escribe la guía de una página que le darías a un compañero que acaba de terminar el Track A y empieza el B mañana: qué reflejos conserva, cuáles tiene que desaprender, y cuál es el único error de fondo que le va a costar tiempo. El criterio de éxito es que no sea una lista de sintaxis: la sintaxis está en la §8, y una guía que sólo repita eso no aporta nada.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y no produce código del proyecto: lo que salga de leerlo —una traducción de un fragmento, un ejercicio resuelto— se commitea con el prefijo de la fase desde la que llegaste (`fase 02: …`, `fase 06: …`), y si merece conservarse va con la forma `ej/a10/5`. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
APPENDIX_EOF
wc -l a10-migracion-9-16.md

# --- 2026-09-07T00:02:27 · Fase 12 pincelada Angular 17
sed -n '1005,1041p' 12-testing-coverage.md

# --- 2026-09-07T00:04:13 · Write A11
cat > a11-puente-16-17.md <<'APPENDIX_EOF'
# 📎 Apéndice A11 — 🔥 Puente Angular 16 → 17+

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **2 horas**
> Usado por: Fase 12 (la pincelada de signals sale de aquí) · Versión cubierta: de 16.2.12 hacia 17 y posteriores
> 🔥 **Opcional — el curso se completa sin abrir este apéndice.**

**Esto no se lee de corrido, y además no es un plan.** Es un mirador. Sirve para una cosa muy concreta y muy frecuente: **buscas cómo hacer algo, encuentras un artículo de 2025, y no se parece en nada a tu código.** Este apéndice te dice en treinta segundos si estás mirando otra versión o si lo estás haciendo mal.

Casi siempre es lo primero. Y saberlo también te permite decir en una reunión, con precisión, qué separa a CertCore de lo que hoy se considera normal — que es una conversación distinta de "deberíamos migrar".

**Qué queda fuera:** el procedimiento de migración paso a paso, y **cualquier recomendación de migrar**. Este curso enseña a mantener, no a modernizar. La decisión de llevar CertCore más allá de la 16 no es técnica y no se toma leyendo un apéndice.

> ⚠️ **En Angular 16 los signals existen y son experimentales.** CertCore no los usa: aquí se leen, no se adoptan. La decisión está cerrada en `alcance-del-proyecto.md` §13 y ninguna fase la contradice.

---

## Índice

- [1. Signals de verdad](#1-signals-de-verdad)
- [2. En qué se parece un signal a un `BehaviorSubject`, y en qué no](#2-en-qué-se-parece-un-signal-a-un-behaviorsubject-y-en-qué-no)
- [3. El control flow `@if` / `@for` / `@switch`](#3-el-control-flow-if--for--switch)
- [4. Deferrable views](#4-deferrable-views)
- [5. El builder de esbuild](#5-el-builder-de-esbuild)
- [6. `provideRouter` y el bootstrap sin `NgModule`](#6-providerouter-y-el-bootstrap-sin-ngmodule)
- [7. Lo que caduca del testing de la Fase 12](#7-lo-que-caduca-del-testing-de-la-fase-12)
- [8. ⚖️ Qué costaría llevar CertCore hasta aquí](#8-️-qué-costaría-llevar-certcore-hasta-aquí)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-5)

---

## 1. Signals de verdad

Un signal es un valor que sabe quién lo está mirando. Se lee llamándolo como función, se escribe con métodos, y todo lo que dependa de él se entera solo.

```ts
// Angular 17+. NO compila en este proyecto y no hay que escribirlo.
const templates = signal<ChecklistTemplate[]>([]);

templates();                                  // leer
templates.set(nextTemplates);                 // reemplazar
templates.update((current) => [...current, created]);   // derivar del actual

// Un derivado. Se recalcula solo, y sólo cuando alguna de sus entradas cambió.
const criticalCount = computed(() => templates().filter((t) => t.hasCritical).length);

// Un efecto. Corre cuando cambia algo de lo que leyó dentro.
effect(() => console.log('plantillas:', templates().length));
```

Y en un componente, con las entradas y salidas reescritas:

```ts
@Component({ /* … */ })
export class KpiCardComponent {
  readonly value = input.required<number>();          // en vez de @Input()
  readonly selected = output<string>();               // en vez de @Output()
  readonly label = computed(() => `${this.value()} vigentes`);
}
```

Lo que esto cambia de fondo no es la sintaxis: es que **el framework sabe exactamente qué parte de la pantalla depende de qué dato**. Con `zone.js` —lo que usa CertCore— Angular no lo sabe, así que ante cualquier evento revisa todo y confía en `OnPush` para podar. Con signals, la actualización va dirigida.

---

## 2. En qué se parece un signal a un `BehaviorSubject`, y en qué no

Es la comparación que de verdad le sirve a alguien que viene de la Fase 4, y hay que hacerla con cuidado porque el parecido superficial esconde dos diferencias grandes.

**En qué se parecen:** los dos siempre tienen un valor, los dos avisan a quien los mira, y los dos sirven de base para derivados (`computed` frente a `map` + `shareReplay`).

| | `BehaviorSubject` (CertCore) | `signal` (17+) |
|---|---|---|
| Leer el valor actual | `.value`, y desde fuera es sospechoso | `templates()`, y es la forma normal |
| Suscribirse | explícito, y hay que desuscribirse | no existe: lees y ya estás enganchado |
| Derivar | `map` + `distinctUntilChanged` + `shareReplay` | `computed`, memorizado de fábrica |
| Fugas | la mitad de los bugs del curso | no aplica: no hay suscripción que quede colgando |
| Asincronía | es su especialidad: `switchMap`, `debounceTime`, cancelación | **no la maneja**: un signal es un valor, no un flujo |
| Tiempo | puedes expresar "espera 300 ms y cancela lo anterior" | necesitas RxJS igual |

**Las dos diferencias que importan de verdad:**

**Un signal no es un observable.** No hay `switchMap`, no hay `debounceTime`, no hay cancelación de una petición en vuelo. Todo lo que la Fase 8 hace con el autosave —esperar, no repetir, encolar— sigue necesitando RxJS. Angular 17+ trae puentes en las dos direcciones (`toSignal`, `toObservable`) precisamente porque las dos cosas resuelven problemas distintos y hay que combinarlas.

**Los signals eliminan una familia de bugs y no todas.** Se acaban las fugas de suscripción y los `async` duplicados; **no** se acaban las cargas concurrentes que llegan en el orden equivocado, ni la falta de trazabilidad de quién cambió qué, que son dos de los cuatro límites que **A07** §8 le pone al patrón de CertCore. Cambiar a signals no es cambiar de arquitectura de estado: es cambiar el mecanismo de notificación.

---

## 3. El control flow `@if` / `@for` / `@switch`

```html
<!-- CertCore, Angular 16 -->
<ng-container *ngIf="state$ | async as state; else loading">
  <div *ngFor="let template of state.items; trackBy: trackByTemplateId">…</div>
</ng-container>
<ng-template #loading><mat-spinner></mat-spinner></ng-template>
```

```html
<!-- Angular 17+. No compila aquí. -->
@if (state(); as state) {
  @for (template of state.items; track template.id) {
    <div>…</div>
  } @empty {
    <p>No hay plantillas</p>
  }
} @else {
  <mat-spinner />
}
```

**Qué gana, más allá de que se lea mejor:**

- **`track` es obligatorio en `@for`.** No es azúcar: es que el error de rendimiento más común de las listas —no poner `trackBy`— deja de poderse cometer.
- **`@empty` existe.** El caso de la lista vacía deja de ser un `*ngIf` paralelo que alguien olvida actualizar.
- **No hace falta importar nada.** `NgIf` y `NgFor` desaparecen de los `imports` de los componentes standalone, lo cual quita ruido de cada archivo.
- **Las directivas estructurales siguen funcionando.** No desaparecieron; el control flow es lo recomendado y hay una migración automática que las convierte.

---

## 4. Deferrable views

```html
<!-- Angular 17+. Carga diferida declarada en la plantilla. -->
@defer (on interaction) {
  <cc-certificate-pdf-button [certificate]="certificate" />
} @placeholder {
  <button>Descargar PDF</button>
} @loading (minimum 200ms) {
  <mat-spinner diameter="20" />
}
```

Es la respuesta declarativa a lo que la **Fase 10** resuelve a mano con `await import('jspdf')`: los 300 KB del generador de PDF no viajan hasta que alguien interactúa con ese botón.

**Lo que aporta frente a lo que ya haces:** el disparador se declara donde se usa (`on interaction`, `on viewport`, `on idle`, `on timer`), y el estado de carga tiene su hueco en la plantilla en vez de resolverse con una bandera. **Lo que no cambia:** la decisión sigue siendo tuya y sigue siendo la misma —qué es lo bastante pesado y lo bastante infrecuente como para diferirlo—, y esa decisión es lo difícil. `@defer` hace más cómodo lo fácil.

---

## 5. El builder de esbuild

Angular 16 construye CertCore con Webpack. A partir de la 17, el builder por defecto para proyectos nuevos usa **esbuild** con Vite en desarrollo, y en las versiones siguientes se consolidó como el camino principal.

**Qué cambia en la práctica:** los tiempos de build y sobre todo los de recompilación en desarrollo bajan mucho — es la diferencia más tangible de todo este apéndice para el día a día. **Qué se rompe:** cualquier cosa que dependiera de la configuración interna de Webpack. Un `custom-webpack` builder, un plugin propio, un `polyfills` peculiar, o el `stats.json` que la **Fase 10** usa para localizar en qué chunk quedó `jspdf` — la información sigue estando, con otro formato.

> 💡 **La conclusión útil, que no es la que parece.** Si algún día alguien plantea saltar de la 16 en adelante, el riesgo no está en los signals ni en el control flow: está aquí. Signals y `@if` son **aditivos** —tu código sigue compilando sin tocarlos—; el cambio de builder es el único que puede romper el pipeline entero de golpe. Es donde hay que mirar primero al estimar.

---

## 6. `provideRouter` y el bootstrap sin `NgModule`

```ts
// CertCore, Angular 16: el AppModule de 2021 sigue siendo el raíz.
platformBrowserDynamic().bootstrapModule(AppModule);

// Angular 17+, y ya posible en la 16: sin ningún NgModule.
bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(routes, withComponentInputBinding()),
    provideHttpClient(withInterceptors([authInterceptor])),
    provideAnimations(),
  ],
});
```

Esto **ya existe en Angular 16** —de hecho la Fase 0 arranca así, antes de que la Fase 1 traiga la herencia— y por eso es la parte del futuro que menos te va a sorprender. Lo que cambia después de la 17 es que deja de ser una alternativa y pasa a ser lo que el CLI genera por defecto y lo que la documentación asume.

`withComponentInputBinding()` merece una mención: hace que los parámetros de la ruta lleguen directamente como `@Input` del componente, y elimina la mitad del código que la **Fase 8** escribe para derivar el formulario de la ruta. Es de los añadidos que más gustan y menos se conocen.

---

## 7. Lo que caduca del testing de la Fase 12

La Fase 12 escribe su suite con tres piezas que en Angular 17 en adelante están en desuso o dejaron de tener sentido. Ninguna está mal hoy: en la 16 son lo que hay.

| Lo que usa la Fase 12 | Qué pasó después | Qué se usa en su lugar |
|---|---|---|
| `RouterTestingModule` | deprecado en Angular 17 | `provideRouter(routes)` en los `providers` del `TestBed` |
| `HttpClientTestingModule` | deprecado en versiones posteriores | `provideHttpClient()` + `provideHttpClientTesting()` |
| `TestBed` sin signals, con `detectChanges()` para leer el estado | sigue funcionando y deja de hacer falta tanto | `componentRef.setInput()` y leer el signal directamente |

**El cambio de fondo, que es el que la Fase 12 §5.9 anuncia:** con signals, **el estado deja de necesitar un ciclo de detección de cambios para ser observable**. La mitad de los `fixture.detectChanges()` de esa fase existen sólo para que el valor llegue a la plantilla; con signals el valor está antes de pintar nada.

> 🧭 **Y lo que no caduca, que es la mitad de tu suite: las funciones puras se seguirán testeando exactamente igual.** `resolveTemplateVersion`, `buildAnswerForm`, las reglas de severidad, las agregaciones del dashboard — nada de eso toca `TestBed`, así que nada de eso se ve afectado por ninguna versión de Angular. Es un argumento a favor de escribir dominio puro que ninguna presentación de signals te va a dar, y es la razón por la que el coverage de CertCore está donde está.

---

## 8. ⚖️ Qué costaría llevar CertCore hasta aquí

Una estimación honesta, con las categorías separadas, para que la conversación se pueda tener con números en vez de con entusiasmo.

**Lo que es casi automático:** subir de mayor en mayor con `ng update`, una por vez. Angular es notablemente cuidadoso con esto y las schematics hacen buena parte del trabajo. De la 16 a la 20 son cuatro saltos, y ninguno de ellos rompe conceptualmente nada de lo que CertCore tiene.

**Lo que es trabajo real y acotado:** el cambio de builder (§5), la actualización de Material —que entre la 16 y la 18 volvió a mover cosas de tema y tokens—, y la revisión de las dependencias que no son de Angular: `ng2-charts`, `jspdf` y el `zone.js` que, si algún día se quita, cambia el modelo de detección de cambios entero.

**Lo que es opcional y por eso peligroso de estimar:** convertir a signals, adoptar el control flow, quitar los `NgModule` que quedan. Nada de esto es necesario para estar en una versión nueva — el código de la 16 sigue compilando —, y por eso es donde una migración se convierte en una refactorización sin límite claro si nadie la acota antes de empezar.

> ⚖️ **El veredicto honesto, y es el que cierra el apéndice.** Migrar un sistema **en mantenimiento**, sin features nuevas previstas y con un equipo pequeño, rara vez se paga solo. Los argumentos que sí sostienen la decisión son concretos y no son técnicos: **soporte** (una versión sin actualizaciones de seguridad es un riesgo con fecha), **contratación** (cuesta más encontrar a alguien dispuesto a mantener una versión que nadie usa), y **dependencias** (el día que necesites una librería que ya sólo publica para versiones nuevas, la decisión la toma ella por ti).
>
> "Es más moderno" no está en esa lista, y **"el equipo se aburre" tampoco lo está — aunque sea un problema real que merece resolverse de otra manera**. Si alguien plantea la migración en una reunión, las tres preguntas útiles son: ¿cuánto soporte le queda a la versión actual?, ¿qué dependencia nos va a obligar primero?, y ¿quién mantiene esto dentro de dos años?

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer hoy, en la 16 |
|---|---|
| Un ejemplo usa `@if` / `@for` | traducirlo a `*ngIf` / `*ngFor`; la idea sirve, la sintaxis no |
| Un ejemplo usa `signal()` o `input()` | traducirlo a `BehaviorSubject` y `@Input`; ver §2 |
| Un ejemplo usa `@defer` | es un `await import()` en un método; **Fase 10** y **A08** §6 |
| Un artículo dice que `HttpClientTestingModule` está deprecado | tiene razón, y en la 16 sigue siendo lo correcto |
| Necesitas argumentar una migración | §8, con las tres preguntas del final |
| Necesitas argumentar **no** migrar | §8 otra vez, con las mismas tres |
| Quieres prepararte para migrar sin migrar | escribe dominio puro (§7): sobrevive a todas las versiones |

---

## 📚 Referencias

- https://angular.dev — la documentación de la 17 en adelante. Aquí sí es la referencia correcta, y es el único apéndice de este curso donde lo es.
- https://angular.dev/guide/signals — signals, `computed` y `effect`.
- https://angular.dev/guide/templates/control-flow — `@if`, `@for` con su `track` obligatorio, y `@switch`.
- https://angular.dev/guide/templates/defer — deferrable views y sus disparadores.
- https://angular.dev/tools/cli/build-system-migration — la migración al builder de esbuild, que es el punto de riesgo de la §5.
- https://update.angular.io — el asistente oficial: pon 16 como origen y la versión que quieras como destino para ver el catálogo real de cambios.
- https://angular.dev/reference/releases — el calendario de soporte. Es el dato que convierte la conversación de la §8 en una decisión con fecha.

> ⚠️ Al revés que en el resto del curso: **aquí `v16.angular.io` es la referencia equivocada.** Este apéndice habla de lo que viene después, y lo que viene después sólo está documentado en `angular.dev`. Cuando vuelvas a las fases, vuelve también a la otra URL.

**Orden de lectura sugerido:** la §2 si vienes de la Fase 4 y te preguntas si el patrón de estado de CertCore tiene los días contados (la respuesta corta es que no, y la larga está ahí). La §7 al terminar la Fase 12. La §8 sólo el día que alguien plantee la pregunta en una reunión — leerla antes convierte una curiosidad en una inquietud, y no hay nada que hacer con ella.

---

## 🧪 Ejercicios (5)

1. 🟢 Toma la plantilla del listado de plantillas de la Fase 7 y reescríbela con `@if` y `@for` **en un archivo aparte que no compile**. Anota qué tres cosas desaparecieron del componente al hacerlo.

2. 🟢 Busca en internet cómo hacer algo que ya sabes hacer en CertCore —cargar datos en un componente, por ejemplo— y clasifica el primer resultado: ¿es de la 16 o posterior? Anota las tres señales que te lo dijeron.

3. 🟡 Reescribe `TemplateStateService` con signals, en un archivo que no compila y que no se commitea al `src/`. Después responde: ¿cuáles de los cuatro límites de **A07** §8 resolvió el cambio, y cuáles siguen exactamente igual?

4. 🟠 Toma tres tests de la Fase 12 —uno de función pura, uno de servicio con `HttpClientTestingModule` y uno de componente con `detectChanges()`— y di, para cada uno, qué habría que cambiar en Angular 17+ y qué no. Ordénalos por cuánto trabajo cuesta.

5. 🔴 Escribe el documento de una página que le llevarías a tu líder si mañana te preguntara *"¿migramos CertCore?"*. Tiene que responder a las tres preguntas del cierre de la §8 con datos —cuánto soporte le queda a la 16, qué dependencia obliga primero, quién mantiene esto en dos años— y terminar con una recomendación. El criterio de éxito es que la recomendación sea defendible en las dos direcciones: si tu documento sólo puede terminar en "sí", no es un análisis.

---

> 🏷️ **Este apéndice no lleva tag propio**, y aquí la regla es más estricta que en el resto: **nada de lo que escribas leyéndolo debe acabar en `src/`.** Los ejercicios 1 y 3 producen código que no compila en este proyecto a propósito; si quieres conservarlo, va en `docs/futuro/` y se commitea con el prefijo de la fase desde la que llegaste (`fase 12: …`). Un `signal()` colado en el código del curso rompe la coherencia de las catorce fases anteriores. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
APPENDIX_EOF
wc -l a11-puente-16-17.md

# --- 2026-09-07T00:06:11 · Write A02
cat > a02-bootstrap-sass.md <<'APPENDIX_EOF'
# 📎 Apéndice A02 — 🔥 Bootstrap 5 + Sass

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **2 horas**
> Usado por: ninguna fase lo asume · Versión cubierta: Bootstrap 5.3.x + dart-sass
> 🔥 **Opcional — el curso se completa sin abrir este apéndice.**

**Este apéndice no describe a CertCore.** CertCore usa Angular Material 16 y nada más: no tiene Bootstrap, ninguna fase lo instala, y ningún ejercicio del curso lo necesita. Lo que describe es **un escenario que te vas a encontrar en otro sistema heredado**, porque es de los más comunes que existen: alguien empezó con Bootstrap, alguien más añadió Material, y hoy los dos se pelean por la cascada mientras el equipo esquiva el problema añadiendo `!important`.

Si estás siguiendo el curso, sáltatelo sin remordimiento. Si heredaste un repositorio con las dos librerías dentro, esto es lo que hace falta saber para no empeorarlo.

**Qué queda fuera:** el rediseño visual de nada, la migración de una librería a la otra —que es un proyecto, no un apéndice—, y los componentes JavaScript de Bootstrap, que no se usan y cuya razón está en la §6.

---

## Índice

- [1. Cómo se llega a tener las dos](#1-cómo-se-llega-a-tener-las-dos)
- [2. El grid de Bootstrap con componentes de Material](#2-el-grid-de-bootstrap-con-componentes-de-material)
- [3. Quién gana la cascada](#3-quién-gana-la-cascada)
- [4. Una sola paleta, dos consumidores](#4-una-sola-paleta-dos-consumidores)
- [5. ⚠️ Qué recompilar tras tocar qué](#5-️-qué-recompilar-tras-tocar-qué)
- [6. Los componentes JS de Bootstrap: por qué no](#6-los-componentes-js-de-bootstrap-por-qué-no)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-6)

---

## 1. Cómo se llega a tener las dos

Casi nunca es una decisión: es una sedimentación, y reconocer cuál de las tres historias tienes delante te dice qué se puede arreglar.

**La historia A — Bootstrap primero, Material después.** El proyecto nació con Bootstrap porque el equipo venía de plantillas de servidor y ya lo conocía. Cuando llegó un formulario complejo, alguien añadió Material por sus componentes —tabla, diálogo, selector de fecha— y se quedaron los dos. Es la más frecuente y la más manejable: Bootstrap se usa sólo para el layout.

**La historia B — Material primero, Bootstrap después.** Alguien quería el grid, o `d-flex`, o los utilitarios de espaciado, y añadió Bootstrap entero para eso. Es la peor de las tres, porque trae el *Reboot* de Bootstrap —su reinicio de estilos— a un proyecto que no lo necesitaba, y ese reinicio toca `button`, `input` y la tipografía base, que es exactamente lo que Material también toca.

**La historia C — una plantilla comprada.** El sistema arrancó sobre un tema de administración de pago que traía Bootstrap dentro, y Material entró después por componentes concretos. Aquí lo que hay debajo suele ser Bootstrap **modificado**, y la primera tarea es averiguar cuánto.

> 🧭 **La primera pregunta, y hay que hacerla antes de tocar una línea de CSS: ¿para qué se usa cada una?** Si Bootstrap sólo aporta grid y utilitarios, el problema es acotado y se resuelve con la §2 y la §3. Si las dos librerías están pintando botones, campos y tarjetas, el problema no es de CSS: es que el sistema tiene dos lenguajes visuales, y eso se decide con producto, no en un `styles.scss`.

---

## 2. El grid de Bootstrap con componentes de Material

Funciona, y es la combinación que menos duele. La clave es **importar sólo lo que usas**, no Bootstrap entero.

```scss
// src/styles.scss — el orden importa y la selección más.
// 1. Lo que Bootstrap necesita para calcular cualquier cosa.
@use 'bootstrap/scss/functions' as *;
@use 'bootstrap/scss/variables' as *;
@use 'bootstrap/scss/mixins' as *;

// 2. Sólo las piezas que de verdad se usan. Sin reboot, sin componentes.
@use 'bootstrap/scss/grid';
@use 'bootstrap/scss/utilities/api';

// 3. Y después Material, entero.
@use '@angular/material' as mat;
@include mat.core();
// …el tema, como en la Fase 6 de CertCore.
```

**Lo que ganas con esa selección:** el grid (`container`, `row`, `col-*`) y los utilitarios (`d-flex`, `mt-3`, `text-end`) sin traer el *Reboot* ni un solo componente de Bootstrap. Es decir: layout de Bootstrap, componentes de Material, y casi ninguna colisión.

```html
<!-- Y en la plantilla, sin ninguna ceremonia: -->
<div class="row">
  <div class="col-12 col-md-6">
    <mat-form-field appearance="outline" class="w-100">
      <mat-label>Razón social</mat-label>
      <input matInput formControlName="legalName" />
    </mat-form-field>
  </div>
</div>
```

> ⚠️ **El `w-100` de ahí arriba es necesario y no es obvio.** Un `mat-form-field` es `inline-block` por defecto y no llena su columna; sin una anchura explícita, tu grid de Bootstrap se ve perfecto y los campos se quedan encogidos a la izquierda. Es la primera media hora que pierde todo el mundo con esta combinación.

**Lo que hay que evitar en la misma pantalla:** un `<button class="btn btn-primary">` de Bootstrap al lado de un `<button mat-raised-button>` de Material. Los dos funcionan, los dos se ven bien por separado, y juntos delatan que el sistema no tiene una decisión tomada. Si tienes que elegir uno para todo, elige el de la librería que aporta los componentes complejos — normalmente Material.

---

## 3. Quién gana la cascada

Tres mecanismos deciden, y en este orden.

**Uno — la especificidad del selector.** Gana el más específico, sin importar el orden. Bootstrap escribe selectores de clase simples (`.btn`), Material escribe selectores más largos y anidados (`.mat-mdc-raised-button.mat-primary`). **En un empate de especificidad no hay empate: casi siempre gana Material**, porque sus selectores son más específicos por construcción. Ésa es la razón real de que "Bootstrap no me aplica" sea la queja frecuente y no al revés.

**Dos — el orden de `styles[]` en `angular.json`.** A igualdad de especificidad, gana el que se cargue **último**. Y este archivo es el que nadie mira:

```jsonc
// angular.json → …architect.build.options.styles
{
  "styles": [
    "src/styles.scss"     // si aquí hubiera dos archivos, el segundo ganaría
  ]
}
```

**Tres — `@layer`, que es la herramienta correcta y casi nadie usa.** Las capas en cascada permiten declarar la prioridad **explícitamente**, en vez de dejarla a merced de la especificidad. Una capa declarada antes pierde contra una declarada después, **incluso si sus selectores son más específicos**:

```scss
// El orden de esta línea es el contrato: bootstrap pierde contra material,
// y los dos pierden contra lo tuyo. Escrito una vez, y se acabó la discusión.
@layer bootstrap, material, app;

@layer bootstrap {
  @use 'bootstrap/scss/grid';
  @use 'bootstrap/scss/utilities/api';
}
```

> 💡 **Por qué `@layer` es mejor que ganar la pelea a mano.** La alternativa que aplica todo el mundo es subir especificidad —anidar un selector de más— o poner `!important`. Las dos funcionan hoy y las dos empeoran el archivo: la primera arranca una carrera armamentística que el siguiente que pase tiene que ganar otra vez, y la segunda destruye la información de quién debería ganar. Con capas, la respuesta a "¿por qué este estilo no aplica?" está en una línea al principio del archivo en vez de repartida por trescientas.

**Y la advertencia sobre `::ng-deep`**, que aparece en cuanto quieras que un estilo de componente alcance a un componente de librería: sigue en desuso, sigue sin sustituto, y si además tienes dos librerías peleándose, un `::ng-deep` mal puesto es la forma más rápida de que un estilo se filtre a pantallas que no lo esperaban. Si lo escribes, que sea con un selector de ámbito propio delante (`:host .certcore-panel ::ng-deep …`) y con un comentario diciendo qué consigue.

---

## 4. Una sola paleta, dos consumidores

El síntoma de que esto no está resuelto es inconfundible: dos azules ligeramente distintos en la misma pantalla, y nadie sabe cuál es el correcto.

La dificultad real es que las dos librerías esperan **formas distintas** del mismo dato. Bootstrap quiere colores sueltos; Material quiere una paleta con tonos del 50 al 900 y un mapa de colores de contraste. No hay una conversión automática, así que la fuente de verdad se declara una vez y se adapta dos:

```scss
// _brand.scss — la ÚNICA fuente de verdad del color de marca.
$brand-500: #3f51b5;
$brand-700: #303f9f;
$brand-100: #c5cae9;
```

```scss
// Consumidor 1 — Bootstrap. Las variables se sobrescriben ANTES de importar
// sus variables, o el `!default` de Bootstrap ya habrá ganado.
@use 'brand' as brand;

$primary: brand.$brand-500;
$theme-colors: ('primary': $primary);

@use 'bootstrap/scss/variables' as *;
```

```scss
// Consumidor 2 — Material. Necesita el mapa completo de tonos y el de
// contraste; no hay atajo, y por eso conviene generarlo una vez y no tocarlo.
@use 'brand' as brand;
@use '@angular/material' as mat;

$brand-palette: (
  100: brand.$brand-100,
  500: brand.$brand-500,
  700: brand.$brand-700,
  contrast: (100: rgba(black, 0.87), 500: white, 700: white),
);

$primary: mat.define-palette($brand-palette, 500, 100, 700);
```

> ⚠️ **El `!default` de Sass es el detalle que arruina esto en silencio.** Las variables de Bootstrap están declaradas con `!default`, que significa "usa este valor **salvo que ya exista uno**". Si sobrescribes `$primary` **después** de importar las variables de Bootstrap, tu valor llega tarde: la variable ya tiene el suyo y tu línea no hace nada. No hay error, no hay advertencia, y el color simplemente no cambia. Es, con diferencia, la causa número uno de "toqué la variable y no pasó nada".

---

## 5. ⚠️ Qué recompilar tras tocar qué

La media hora perdida más frecuente de todo el tema, y cabe en una tabla.

| Tocaste… | ¿Se recompila solo con `ng serve`? | Qué hacer |
|---|---|---|
| Un `.scss` de componente | ✅ sí | nada |
| `src/styles.scss` o un parcial que importa | ✅ sí | nada |
| Una variable Sass en un parcial | ✅ sí, **pero** el orden manda | comprueba que la sobrescritura va **antes** del `@use` de la librería (§4) |
| `angular.json` (la lista de `styles`) | ❌ **no** | **reinicia `ng serve`**; el CLI lee ese archivo al arrancar |
| `package.json` / instalaste Bootstrap | ❌ no | `npm install` y reinicia `ng serve` |
| Nada, pero no ves el cambio | — | recarga forzando (`Cmd`/`Ctrl` + `Shift` + `R`): es el CSS cacheado |

> 🧭 **El orden de diagnóstico, cuando tocaste algo y no cambió nada.** Uno: ¿es caché del navegador? Recarga forzando. Dos: ¿tocaste `angular.json`? Reinicia el servidor. Tres: ¿la variable está **antes** del `@use` de la librería? Cuatro: ¿la está ganando otro selector? Abre el inspector, mira la regla tachada y quién la tacha. Cuatro pasos, en ese orden, y el cuarto —que es donde todo el mundo empieza— casi nunca es la respuesta.

---

## 6. Los componentes JS de Bootstrap: por qué no

Bootstrap 5 quitó jQuery y sus componentes son JavaScript propio: modales, desplegables, pestañas, *tooltips*. **En una aplicación Angular no se usan**, y hay tres razones que se acumulan:

**Manipulan el DOM por fuera de Angular.** Un modal de Bootstrap mueve nodos, añade clases y bloquea el scroll sin que Angular sepa nada. Cuando el componente que lo contenía se destruye, esos cambios se quedan — el clásico "la pantalla no responde y hay un `modal-backdrop` invisible tapándolo todo".

**Colisionan de frente con Material.** Un `MatDialog` y un modal de Bootstrap gestionan foco, `aria` y capas de superposición cada uno a su manera. Con los dos en la misma aplicación, el foco se pierde y la accesibilidad deja de funcionar en los dos.

**No hacen falta.** Material tiene diálogo, menú, pestañas y *tooltip*, integrados con el ciclo de vida y con el CDK de accesibilidad. Añadir la versión de Bootstrap es traer un segundo mecanismo para lo que ya está resuelto.

> 🧭 **La regla, y es la única de este apéndice que no admite matices: de Bootstrap se usa el CSS —grid y utilitarios—, nunca el JavaScript.** Si un sistema heredado ya lo usa, sustituirlo por el equivalente de Material es de los pocos refactores que se pagan solos, porque cada uno de esos componentes es un candidato a bug de estado.

---

## 🧭 Cuándo usar qué

| Situación | Decisión |
|---|---|
| Necesitas layout en un proyecto con Material | grid y utilitarios de Bootstrap, importados por partes |
| Vas a añadir Bootstrap entero "por comodidad" | no: el *Reboot* va a chocar con Material |
| Un estilo de Bootstrap no aplica | especificidad (§3); casi siempre gana Material |
| Quieres decidir la prioridad de una vez | `@layer bootstrap, material, app` |
| Tocaste una variable Sass y no cambió nada | ponla **antes** del `@use` de la librería (`!default`) |
| Tocaste `angular.json` y no cambió nada | reinicia `ng serve` |
| Dos azules distintos en la misma pantalla | una fuente de verdad, dos adaptaciones (§4) |
| Necesitas un modal, un menú o pestañas | Material, siempre; nunca el JS de Bootstrap |
| Las dos librerías pintan botones y campos | esto ya no es CSS: es una decisión de producto |

---

## 📚 Referencias

- https://getbootstrap.com/docs/5.3/customize/sass — cómo importar Bootstrap por partes y cómo funcionan sus variables con `!default`. Es la sección clave de la §4.
- https://getbootstrap.com/docs/5.3/layout/grid — el grid, que es lo que de verdad se usa.
- https://getbootstrap.com/docs/5.3/utilities/api — la API de utilitarios, para importar sólo los que necesitas.
- https://sass-lang.com/documentation/at-rules/use — `@use` y `with`, que es la forma moderna de configurar una librería Sass. ⚠️ Bootstrap 5.3 todavía documenta buena parte de su personalización con `@import`, que dart-sass está retirando; conviven, y mezclarlos da avisos de obsolescencia.
- https://developer.mozilla.org/es/docs/Web/CSS/@layer — las capas en cascada de la §3.
- https://v16.material.angular.io/guide/theming — el lado de Material de la §4.

> ⚠️ Las guías que encuentres sobre "Bootstrap y Angular Material juntos" son mayoritariamente anteriores a Material 15 y describen el DOM de antes de MDC. Sus selectores de `::ng-deep` no aplican aquí. Lo que sigue siendo válido de ellas es el razonamiento sobre la cascada, no el código.

**Orden de lectura sugerido:** la §1 primero, para saber qué historia tienes delante — sin eso, todo lo demás son técnicas sin diagnóstico. La §5 antes de la §3: la mitad de las veces que un estilo "no aplica", el problema es que no se recompiló. La §4 el día que aparezcan los dos azules. La §6 antes de tu primer modal.

---

## 🧪 Ejercicios (6)

1. 🟢 En un proyecto de prueba —**no en CertCore**— instala Bootstrap 5.3 e importa sólo `grid` y `utilities/api`. Comprueba que `container`, `row` y `d-flex` funcionan y que `.btn` no existe. Explica en una línea por qué eso es lo que quieres.

2. 🟢 Mete un `<mat-form-field>` dentro de un `col-md-6` sin `w-100` y con él. Captura las dos y explica la diferencia.

3. 🟡 Pon un `<button class="btn btn-primary">` junto a un `<button mat-raised-button color="primary">`. Abre el inspector, encuentra qué reglas se están aplicando a cada uno, y anota la especificidad de las dos que compiten.

4. 🟡 Sobrescribe `$primary` de Bootstrap **después** del `@use` de sus variables y comprueba que no pasa nada. Muévelo antes y comprueba que sí. Escribe en dos líneas qué hace `!default` y por qué el fallo es silencioso.

5. 🟠 Declara `@layer bootstrap, material, app` y mete cada bloque en su capa. Después crea deliberadamente un conflicto donde el selector de Bootstrap sea **más específico** que el de Material, y comprueba que aun así pierde. Explica por qué eso es mejor que ganar con `!important`.

6. 🔴 Te dan un repositorio heredado donde las dos librerías pintan botones, campos y tarjetas, y hay diecisiete `!important` repartidos. Escribe el plan de una página para desenredarlo: qué diagnosticas primero (§1), qué se puede arreglar con capas sin tocar HTML, qué exige una decisión de producto, y en qué orden lo harías para que el sistema nunca quede peor que al empezar. El criterio de éxito es que el plan se pueda ejecutar en incrementos, cada uno desplegable por su cuenta.

---

> 🏷️ **Este apéndice no lleva tag propio, y además su código no pertenece a CertCore.** Los ejercicios se hacen en un proyecto de prueba aparte; nada de lo que salga de aquí entra al repositorio del curso, porque CertCore no tiene Bootstrap y meterlo rompería la coherencia de las catorce fases. Si quieres conservar tus pruebas, van en un repositorio propio. La convención de commits y tags del curso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
APPENDIX_EOF
wc -l a02-bootstrap-sass.md

# --- 2026-09-07T00:06:19 · Track A i18n approach
cd ../angular-8-legacy-for-backend-devs && sed -n '1,30p' 02-i18n.md | head -30; echo "=== a07 i18n apendice ==="; sed -n '1,12p' a07-i18n.md

# --- 2026-09-07T00:08:13 · Write A13
cd ../angular-16-legacy-for-backend-devs && cat > a13-i18n.md <<'APPENDIX_EOF'
# 📎 Apéndice A13 — 🔥 i18n moderno

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **2 horas**
> Usado por: ninguna fase; es lectura · Versión cubierta: `@angular/localize` 16.2.12 · `@ngx-translate/core` 15.x
> 🔥 **Opcional — el curso se completa sin abrir este apéndice.**

**CertCore no tiene i18n, y este apéndice no se lo añade.** Es monolingüe en español por decisión cerrada (`alcance-del-proyecto.md` §8): los textos de interfaz van como literales en la plantilla, sin claves de traducción, y ninguna de las catorce fases hace otra cosa. El presupuesto que un curso hermano gasta en tres idiomas, éste lo gasta en el motor de plantillas versionadas.

Entonces, ¿para qué existe este documento? Para responder a una pregunta que llega siempre, tarde o temprano, y que conviene poder responder con números: **¿qué costaría internacionalizar esto?** Es un documento de decisión, no un tutorial. No hay nada que instalar y no hay nada que ejecutar.

**Qué queda fuera:** la implementación completa —no se toca ni un archivo del proyecto—, la traducción real del contenido (que es trabajo de producto, no de ingeniería), y el soporte RTL, que es una conversación distinta y más cara que todo lo que hay aquí.

---

## Índice

- [1. El eje que ordena la decisión: compilación o ejecución](#1-el-eje-que-ordena-la-decisión-compilación-o-ejecución)
- [2. `@angular/localize`: un bundle por idioma](#2-angularlocalize-un-bundle-por-idioma)
- [3. `@ngx-translate`: carga en ejecución y cambio en caliente](#3-ngx-translate-carga-en-ejecución-y-cambio-en-caliente)
- [4. El costo real de convertir plantillas ya escritas](#4-el-costo-real-de-convertir-plantillas-ya-escritas)
- [5. ⚠️ Fechas y números por locale: donde vive el bug de verdad](#5-️-fechas-y-números-por-locale-donde-vive-el-bug-de-verdad)
- [6. Qué hace el curso hermano, y qué le cuesta](#6-qué-hace-el-curso-hermano-y-qué-le-cuesta)
- [7. ⚖️ La estimación honesta](#7-️-la-estimación-honesta)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-5)

---

## 1. El eje que ordena la decisión: compilación o ejecución

Todas las opciones caen a un lado o al otro de una sola pregunta: **¿cuándo se resuelve el texto?**

**En tiempo de compilación** (`@angular/localize`, el i18n nativo de Angular). El compilador produce **una aplicación completa por idioma**. `dist/es/`, `dist/en/`, `dist/pt/`. Cada una lleva sus textos ya dentro; no hay diccionarios que cargar y no hay nada que resolver en el navegador.

**En tiempo de ejecución** (`@ngx-translate` y similares). Se compila **una sola** aplicación que carga un diccionario JSON al arrancar y resuelve las claves sobre la marcha. Cambiar de idioma es cargar otro JSON.

| | Compilación (`@angular/localize`) | Ejecución (`@ngx-translate`) |
|---|---|---|
| Qué se despliega | N aplicaciones, una por idioma | una sola |
| Cambiar de idioma sin recargar | ❌ no: es otra URL, otro bundle | ✅ sí, en caliente |
| Peso para el usuario | sólo su idioma | la aplicación + su diccionario |
| Errores de clave faltante | **en el build**: no compila | **en ejecución**: se ve la clave en crudo |
| Añadir un idioma | otro build, otro despliegue, otra ruta en nginx | subir un JSON |
| Complejidad del despliegue | alta: rutas, `base href`, redirección por idioma | baja |
| Soporte oficial de Angular | sí | no: es una librería de la comunidad |

> 🧭 **La pregunta que decide, y no es técnica: ¿el usuario tiene que poder cambiar de idioma sin recargar?** Si la respuesta es sí —una aplicación pública, un selector en la barra— es ejecución, y no hay mucho más que discutir. Si el idioma lo determina la organización a la que pertenece el usuario y no cambia nunca durante una sesión, compilación gana en casi todo lo demás: es más rápido, pesa menos, y los errores aparecen en el build en vez de en producción.

---

## 2. `@angular/localize`: un bundle por idioma

```html
<!-- El texto se marca en la plantilla. El atributo lleva un significado y una
     descripción para quien traduce, que sin contexto se equivoca. -->
<h2 i18n="@@templates.title">Plantillas de checklist</h2>

<p i18n="Cantidad de certificados por vencer|Aparece en el panel principal">
  Tienes {count, plural, =0 {ningún certificado} =1 {un certificado} other {# certificados}}
  por vencer.
</p>
```

```bash
ng extract-i18n --output-path src/locale    # genera messages.xlf con todo lo marcado
# …se traduce cada archivo, y el build produce una aplicación por idioma
ng build --localize
```

**Lo que hace bien, y son cosas que la opción de ejecución no puede dar:**

- **Una clave que falta no compila.** El error aparece en el build, no en una pantalla de producción con `templates.title` en crudo.
- **El usuario descarga sólo su idioma.** Nada de diccionarios de idiomas que no habla.
- **Plurales y género con ICU**, que es el estándar de verdad para esto y evita la lista de `if` que todo el mundo escribe a mano.

**Lo que cuesta, y es lo que la gente subestima:** el despliegue deja de ser "copiar `dist/`". Son N carpetas, un `base href` distinto por idioma, reglas en nginx para servir cada una, y una decisión sobre qué pasa cuando alguien entra a la raíz sin idioma. En el contenedor de la **Fase 13**, eso significa un `nginx.conf` bastante más largo y un `entrypoint.sh` que ya no configura una aplicación sino varias.

---

## 3. `@ngx-translate`: carga en ejecución y cambio en caliente

```html
<h2>{{ 'templates.title' | translate }}</h2>
<p>{{ 'dashboard.expiring' | translate: { count: expiringCount } }}</p>
```

```json
// assets/i18n/es.json — el diccionario, servido como un asset más
{ "templates": { "title": "Plantillas de checklist" } }
```

**Lo que hace bien:** un solo bundle, un solo despliegue, un idioma nuevo es un JSON, y el usuario puede cambiar de idioma sin recargar. Encaja de forma natural con el `assets/config.json` que la **Fase 13** ya sirve: el mecanismo de "un archivo que se lee al arrancar" ya existe en CertCore, y añadir diccionarios sería más de lo mismo.

**Lo que cuesta:** una clave que falta se ve **en pantalla**, en crudo, delante del usuario. Y los cuatro síntomas de un texto que no aparece —falta la clave, falta el archivo, el archivo no cargó a tiempo, o el idioma activo no es el que crees— **producen exactamente el mismo resultado visual**, así que hace falta un procedimiento de diagnóstico que en la opción de compilación sencillamente no existe.

> ⚠️ **Y hay una trampa estructural que conviene conocer aunque nunca la implementes**, porque es de las que definen un sistema: `@ngx-translate` traduce **textos** y es dinámico; `LOCALE_ID` de Angular formatea **valores** —fechas, números, moneda— y se resuelve **una sola vez al arrancar**. Son dos nociones de idioma corriendo en paralelo que no se hablan. Cambiar el idioma en caliente cambia los textos y **no** cambia el formato de las fechas, y eso no es un bug pendiente: es lo que el diseño produce. Quien herede un sistema así tiene que saberlo el primer día.

---

## 4. El costo real de convertir plantillas ya escritas

Aquí está la parte que ninguna comparación de librerías cuenta, y es la que se lleva el presupuesto.

**El trabajo mecánico** —recorrer las plantillas y sustituir literales por claves o marcarlos con `i18n`— es tedioso y es lo barato. Se puede repartir, se puede revisar, y una `grep` bien hecha encuentra casi todo.

**Lo caro es lo que no está en las plantillas.** En CertCore, hoy, hay texto en español en cinco sitios más:

- **Los mensajes de error del código.** El `throw new Error('CoreModule ya está cargado…')` de la Fase 1, los mensajes que los `*ApiService` producen al traducir un fallo HTTP, y los que acaban en `state.error` y se pintan en pantalla. Éstos **sí** los ve el usuario.
- **Las etiquetas derivadas del dominio.** `severityLabel()`, `certificateStatusLabel()` y sus hermanas: funciones puras que convierten `critical` en "Crítico". Están en `core/domain/`, se testean sin `TestBed`, y traducirlas significa meterles una dependencia de traducción — o devolver claves y traducir en la vista, que es la decisión correcta y obliga a tocar cada pantalla que las usa.
- **Los textos del PDF.** El certificado de la **Fase 10** se arma con cadenas en español dentro de una función pura. Traducir ahí no es sólo cambiar el texto: es decidir **en qué idioma se emite un certificado**, que es una pregunta de negocio con consecuencias legales.
- **Los mensajes del `MatSnackBar`** y los datos del diálogo de confirmación, que viajan como objetos desde el componente.
- **Los textos del mock**, que en un backend de verdad serían del servidor y que abren la pregunta de quién traduce los errores de la API.

> 🧠 **La regla de dedo que sale de esa lista, y que sirve para estimar cualquier i18n tardío: el trabajo de las plantillas es la mitad; la otra mitad está repartida por el código, y no la encuentra ninguna herramienta.** Un proyecto que nace con i18n paga ese costo una vez, a plazos, sin darse cuenta. Uno que lo añade después lo paga junto y de golpe.

---

## 5. ⚠️ Fechas y números por locale: donde vive el bug de verdad

Los textos son trabajo; las fechas y los números son **bugs**, y en CertCore lo serían especialmente.

**Los números.** `1.234,56` en español y `1,234.56` en inglés. Un separador decimal interpretado al revés no produce un error: produce un número **mil veces mayor o menor** que se guarda tan tranquilo. En un sistema de inspecciones con lecturas de presión y tolerancias, eso es exactamente la clase de dato que nadie vuelve a revisar.

**Las fechas.** `03/04/2026` es el 3 de abril o el 4 de marzo según quién lo lea, y las dos lecturas son válidas. Y CertCore vive de fechas: la vigencia de un certificado, el `validFrom` de una versión de plantilla, el "¿venció ayer?" que la **Fase 10** convierte en una fase entera.

**La buena noticia, y es la que hace corta esta sección:** CertCore ya está preparado en el sitio que importa. La regla del proyecto —fechas como cadenas ISO con offset explícito (`-05:00`), nunca un `Date` suelto donde importe el día, y la zona horaria decidida a mano en `business-day.ts`— significa que **el dato nunca depende del locale**. Sólo dependería la presentación, que es donde se puede cambiar sin arriesgar nada.

> 🧭 **La regla que hay que llevarse aunque nunca internacionalices nada: el locale afecta a cómo se muestra un valor, jamás a cómo se guarda.** Un sistema que guarda `"03/04/2026"` porque así lo escribió el usuario ya tiene el bug puesto, exista o no i18n. Uno que guarda `"2026-04-03T00:00:00-05:00"` puede añadir veinte idiomas sin tocar un solo dato. Es la decisión más barata y más rentable de todo este apéndice, y no cuesta nada tomarla el primer día.

---

## 6. Qué hace el curso hermano, y qué le cuesta

El Track A —Angular 8, laboratorio clínico— tomó la decisión contraria: **tres idiomas, resueltos en tiempo de ejecución**, con `@ngx-translate` y un `APP_INITIALIZER` que carga el diccionario antes de pintar nada. Le dedica una fase completa de 6 horas, colocada en la **posición 2**, antes de que existan las pantallas.

Ese detalle —la posición— es la mejor lección de este apéndice: **montaron el mecanismo antes de tener cuarenta plantillas con literales dentro**, precisamente para no pagar la §4. Con las pantallas ya escritas, la misma decisión habría costado varias veces más.

Y le cuesta lo que la §3 anuncia: un incidente propio en su cuaderno, cuatro causas distintas produciendo el mismo síntoma visual, y las dos nociones de idioma que no se hablan. Nada de eso es un defecto de aquella implementación; es el precio de la rama que eligieron.

> ⚖️ **Los dos cursos son honestos y toman decisiones opuestas, y ninguna está mal.** LabCore es un laboratorio con personal que habla tres idiomas y una interfaz que tiene que cambiar en caliente. CertCore opera en un solo país, con una norma en un solo idioma, y sus certificados se emiten en español porque así los exige quien los recibe. **La decisión de i18n no la toma la arquitectura: la toma el dominio.**

---

## 7. ⚖️ La estimación honesta

Si mañana te preguntaran cuánto costaría internacionalizar CertCore, esto es lo que se puede decir con fundamento. Son órdenes de magnitud para el sistema que el curso construye, no una cotización.

**Lo acotado y previsible:**

- Montar el mecanismo, sea cual sea la rama: entre **medio día y un día**. Es lo fácil y es lo que todo el mundo estima.
- Marcar o extraer los textos de las plantillas del curso: **dos o tres días**, mecánicos.

**Lo que se subestima siempre:**

- Los cinco sitios de la §4 —errores, etiquetas de dominio, PDF, snackbars, mock—: **al menos tanto como las plantillas**, y con decisiones de diseño en medio, no sólo sustituciones.
- El despliegue, si eliges compilación: **rehacer el `nginx.conf`, el `entrypoint.sh` y el Dockerfile** de la Fase 13, más la decisión de qué pasa en la raíz sin idioma.
- La **traducción en sí**, que no es trabajo de ingeniería y que suele ser lo que bloquea la fecha de entrega.

**Lo que no se puede estimar sin producto:** en qué idioma se emite un certificado. No es una pregunta técnica y no la contesta el equipo de desarrollo.

> 🧭 **Y la conclusión que se lleva alguien que no va a internacionalizar nada, que sois casi todos: si algún día es posible que el sistema hable otro idioma, lo único que hay que hacer hoy es la §5.** Guarda fechas y números en formatos independientes del locale, y devuelve claves de dominio (`critical`) en vez de etiquetas (`Crítico`) desde la capa de dominio. Eso no cuesta nada, no compromete a nada, y es la diferencia entre añadir un idioma y reescribir el sistema.

---

## 🧭 Cuándo usar qué

| Situación | Rama | Por qué |
|---|---|---|
| El usuario cambia de idioma sin recargar | ejecución (`@ngx-translate`) | la de compilación no puede |
| El idioma lo fija la organización y no cambia | compilación (`@angular/localize`) | más rápido, más ligero, errores en el build |
| Te aterra una clave faltante en producción | compilación | no compila si falta |
| Añadir idiomas tiene que ser barato y frecuente | ejecución | un JSON más |
| El despliegue tiene que seguir siendo una carpeta | ejecución | la otra son N aplicaciones |
| Plurales y género de verdad | compilación, con ICU | es el estándar y está soportado |
| No vas a internacionalizar, pero quizá algún día | **§5, y nada más** | formatos independientes del locale, gratis |
| Alguien pregunta "¿cuánto costaría?" | §4 y §7 | y la mitad del costo no está en las plantillas |

---

## 📚 Referencias

- https://v16.angular.io/guide/i18n-overview — el i18n nativo de Angular 16, de punta a punta: marcado, extracción, build por idioma.
- https://v16.angular.io/guide/i18n-common-prepare — el atributo `i18n`, los identificadores `@@` y las descripciones para quien traduce.
- https://v16.angular.io/guide/i18n-example — ICU para plurales y selección, que es la parte que más se agradece.
- https://github.com/ngx-translate/core — `@ngx-translate/core`. ⚠️ Comprueba la compatibilidad de versiones: la línea que corresponde a Angular 16 no es la misma que la de la 8 ni la de la 17, y el README describe siempre la más reciente.
- https://v16.angular.io/api/core/LOCALE_ID — el token que decide el formato de fechas y números, y que se resuelve una sola vez al arrancar (§3).
- https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Intl — `Intl.NumberFormat` e `Intl.DateTimeFormat`, que es lo que hay debajo de todo formato por locale.
- https://unicode-org.github.io/icu/userguide/format_parse/messages — la especificación de los mensajes ICU, para cuando los plurales dejen de ser dos casos.

> ⚠️ Buena parte de lo que encuentres sobre i18n en Angular es anterior a la 9 y describe el i18n antiguo, que funcionaba distinto y tenía otras limitaciones. Para este curso, la referencia es `v16.angular.io`.

**Orden de lectura sugerido:** la §1 y la §5, que son las dos que sirven aunque nunca internacionalices nada. La §4 el día que alguien proponga añadir un idioma "que no debería costar mucho". La §7 antes de dar cualquier cifra. Las §2 y §3 sólo si de verdad vas a elegir una rama.

---

## 🧪 Ejercicios (5)

1. 🟢 Recorre las plantillas de las Fases 6 a 10 y cuenta los literales de interfaz en español. Anota la cifra: es el numerador de cualquier estimación futura.

2. 🟢 Busca en el código de CertCore texto en español **fuera** de las plantillas: mensajes de error, etiquetas de dominio, cadenas del PDF, snackbars. Compara esa cifra con la del ejercicio 1 y comprueba la regla de dedo de la §4.

3. 🟡 Toma `severityLabel()` y `certificateStatusLabel()` y reescríbelas —en un archivo aparte, sin tocar el proyecto— para que devuelvan claves en vez de etiquetas. Enumera después todas las pantallas que habría que tocar por ese cambio. Ése es el costo oculto, medido.

4. 🟠 Cambia el idioma de tu navegador a inglés y recarga CertCore. Anota qué cambió y qué no, y explica cada caso: qué depende de `LOCALE_ID`, qué es un literal, y por qué las fechas del `db.json` se ven igual pase lo que pase.

5. 🔴 Escribe el documento de decisión de una página que le llevarías a producto si mañana pidieran inglés: las dos ramas con sus consecuencias reales para el despliegue de la Fase 13, la estimación de la §7 con tus cifras de los ejercicios 1 y 2, y las tres preguntas que **producto** tiene que contestar antes de que ingeniería empiece —empezando por en qué idioma se emite un certificado—. El criterio de éxito es que ninguna de las tres preguntas se pueda responder desde el equipo de desarrollo.

---

> 🏷️ **Este apéndice no lleva tag propio y no produce código.** No se instala nada, no se toca ningún archivo del proyecto, y CertCore sigue siendo monolingüe al terminar de leerlo. Lo que salga de los ejercicios —conteos, el documento de decisión del 5— va en `docs/` y se commitea con el prefijo de la fase desde la que llegaste. Un `| translate` colado en una plantilla del curso rompería la coherencia de las catorce fases y de la decisión cerrada en `alcance-del-proyecto.md` §8. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
APPENDIX_EOF
wc -l a13-i18n.md

# --- 2026-09-07T00:10:08 · Write A12
cat > a12-arm64-m1.md <<'APPENDIX_EOF'
# 📎 Apéndice A12 — 🔥 macOS con Apple Silicon y arm64

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **2 horas**
> Usado por: Fase 0, Fase 12, Fase 13, Fase 14 · Versión cubierta: ninguna fijada; es un apéndice de plataforma
> 🔥 **Opcional por plataforma — si no trabajas en un Mac con chip de la serie M, no necesitas este documento.**

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve una sola cosa: **que alguien con un Mac de la serie M pueda seguir el curso completo, incluidas las fases de contenedor**, sin perder una tarde por un error que no menciona la arquitectura en ningún sitio.

Es corto a propósito, y la razón de que sea corto es en sí misma la primera buena noticia (§2).

**Qué queda fuera:** `node-sass` y `node-gyp`. **Y esto se dice explícitamente porque quien venga del Track A los va a buscar**: en Angular 8 eran la pesadilla de Apple Silicon, porque compilaban C++ y no había binarios precompilados para arm64. El stack de este curso **no compila nada nativo** — Angular 16 usa `sass` puro en JavaScript (dart-sass) y ninguna dependencia fijada tiene extensión nativa. Ese problema no existe aquí y no vas a tener que resolverlo. También quedan fuera el `Dockerfile` concreto del proyecto (**Fase 13**) y el cluster de kind (**Fase 14**): aquí sólo está la parte que depende de la arquitectura.

---

## Índice

- [1. Tres capas, y confundirlas es el 90% del problema](#1-tres-capas-y-confundirlas-es-el-90-del-problema)
- [2. Node 18 en arm64: por qué este apéndice es corto](#2-node-18-en-arm64-por-qué-este-apéndice-es-corto)
- [3. El Chromium de Karma, para la Fase 12](#3-el-chromium-de-karma-para-la-fase-12)
- [4. Construir la imagen para la arquitectura correcta](#4-construir-la-imagen-para-la-arquitectura-correcta)
- [5. Colima, Docker Desktop y Podman](#5-colima-docker-desktop-y-podman)
- [6. 🩺 Diagnóstico por síntoma](#6--diagnóstico-por-síntoma)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-6)

---

## 1. Tres capas, y confundirlas es el 90% del problema

Cuando algo falla por arquitectura en un Mac con chip M, la pregunta útil no es "¿mi Mac es arm?" sino **"¿cuál de las tres capas es arm y cuál no?"**. Son independientes, y cada una se pregunta con un comando distinto.

```bash
# 👁️ Capa 1 — la MÁQUINA. En un Mac de la serie M responde `arm64`.
uname -m

# 👁️ Capa 2 — el NODE que estás ejecutando. Puede ser x64 aunque la máquina
#    sea arm64: pasa si lo instalaste desde una terminal corriendo bajo Rosetta.
node -p "process.arch"

# 👁️ Capa 3 — el motor de contenedores, y por separado, cada IMAGEN.
docker version --format '{{.Server.Arch}}'
docker image inspect node:18.18.2-alpine --format '{{.Architecture}}'
```

**Las combinaciones que producen problemas, y sólo son tres:**

| Máquina | Node | Imagen | Qué pasa |
|---|---|---|---|
| arm64 | **x64** | — | todo funciona y todo va lento; y algún binario opcional se instala para la arquitectura equivocada |
| arm64 | arm64 | **amd64** | el contenedor no arranca, o arranca emulado y va muy lento |
| arm64 | arm64 | arm64 | ✅ lo normal, y lo que quieres |

> 🧠 **La segunda fila es la que produce el error más desconcertante del curso**, y llega en la Fase 14: un pod en `CrashLoopBackOff` cuyos logs vienen vacíos y cuyo `kubectl describe` no dice nada sobre arquitecturas. La causa es que la imagen es amd64 y el nodo es arm64, y el mensaje —si llegas a verlo— dice `exec format error`, que no significa nada para nadie la primera vez.

---

## 2. Node 18 en arm64: por qué este apéndice es corto

Node 18 tiene binarios oficiales para arm64 de macOS y `nvm` los instala sin trucos:

```bash
nvm install     # lee el .nvmrc de la Fase 0 → 18.18.2
node -p "process.arch"    # arm64
```

Y ninguna dependencia fijada de este curso compila C++. Ni Angular, ni RxJS, ni Material, ni `jspdf`, ni `json-server`, ni Jasmine ni Karma. El `sass` que usa Angular 16 es dart-sass, que es JavaScript. **Eso significa que el `npm ci` de la Fase 0 funciona igual en un Mac con chip M que en cualquier otra máquina**, y que no hay ninguna sección de "cómo compilar X en arm64" que escribir.

> ⚠️ **La única forma realista de acabar con un Node x64 en un Mac arm** es haberlo instalado desde una terminal corriendo bajo Rosetta —una copia de Terminal o iTerm con "Abrir con Rosetta" marcado— o desde una máquina antigua migrada con el Asistente de Migración. Si `uname -m` dice `arm64` y `node -p "process.arch"` dice `x64`, ése es tu caso. El arreglo es borrar esa instalación de Node y reinstalarla desde una terminal nativa; parchear alrededor no compensa.

> 💡 **Y si vienes del Track A, esto es lo que cambió y merece un momento.** Angular 8 arrastraba `node-sass`, que era un envoltorio de LibSass y sí compilaba C++, y en 2021 no había binarios para arm64: había que instalar herramientas de compilación, o Python 2, o rendirse y usar Rosetta. Angular 11 lo sustituyó por `sass` puro y el problema desapareció del ecosistema. Si tu instinto al empezar este curso fue buscar cómo arreglar `node-gyp`, ese instinto es correcto y ya no hace falta.

---

## 3. El Chromium de Karma, para la Fase 12

La **Fase 12** corre los tests con Karma y `karma-chrome-launcher`, que necesita un Chrome instalado. En un Mac con chip M, el Chrome que descargas de Google es arm64 nativo y funciona sin más:

```js
// karma.conf.js — el navegador por defecto de la Fase 12
browsers: ['ChromeHeadless'],
```

Lo que puede fallar son dos cosas, y ninguna es de la arquitectura del Mac:

**Que Karma no encuentre el navegador.** El lanzador busca el ejecutable en rutas conocidas y en la variable `CHROME_BIN`. Si tienes Chromium, Brave o Chrome en una ruta poco habitual, se lo dices:

```bash
# En un Mac, la ruta del Chrome instalado normalmente:
export CHROME_BIN="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
npm test
```

**Que lo corras dentro de un contenedor.** Ahí sí aparece la arquitectura, y por partida doble: la imagen tiene que ser arm64 **y** el Chromium que instales dentro tiene que existir para arm64. Las imágenes de Alpine y de Debian traen Chromium para arm64 en sus repositorios, así que se resuelve; lo que no funciona es dar por hecho que la imagen que te dieron sirve.

```js
// Y dentro de un contenedor hace falta esto, que no es de arm64 sino de correr
// como root sin espacio de nombres de usuario:
customLaunchers: {
  ChromeHeadlessCI: {
    base: 'ChromeHeadless',
    flags: ['--no-sandbox', '--disable-gpu'],
  },
},
```

> 🧭 **La regla práctica: en tu Mac, corre los tests fuera del contenedor.** Es más rápido, no tiene ninguna de estas complicaciones, y es lo que hace la Fase 12. El Chromium dentro de un contenedor es un problema de integración continua, y ahí lo resuelve quien monta el pipeline con una imagen preparada.

---

## 4. Construir la imagen para la arquitectura correcta

**El caso normal no requiere hacer nada.** `docker build` produce una imagen de la arquitectura de tu máquina, y las dos imágenes base de la **Fase 13** —`node:18.18.2-alpine` y `nginx:1.25-alpine`— publican variantes arm64 oficiales. En tu Mac construyes arm64, en tu Mac corre arm64, y en el kind de la Fase 14 también, porque el nodo hereda tu arquitectura.

**El caso que sí requiere pensar es cuando el destino no es tu máquina.** Si esa imagen va a un servidor Linux x86 —que es lo normal en producción—, la imagen que construiste no le sirve.

```bash
# 👁️ Comprobar qué construiste, que es el paso que casi nadie da
docker image inspect certcore:fase-13 --format '{{.Architecture}}'

# ✍️ Construir para una arquitectura concreta, emulando
docker build --platform=linux/amd64 -t certcore:fase-13-amd64 .

# ✍️ Construir para las dos a la vez y publicarlas bajo un solo nombre.
#    Requiere buildx y un registro: un manifiesto multi-arquitectura no se
#    puede guardar en el almacén local, y ése es el detalle que sorprende.
docker buildx build --platform linux/amd64,linux/arm64 \
  -t registro.empresa.com/certcore:fase-13 --push .
```

> ⚠️ **Construir emulado es lento, y no un poco.** Un `npm ci` bajo emulación puede tardar varias veces lo que tarda nativo, porque cada instrucción del binario se traduce. Si tienes que producir imágenes amd64 a menudo, la respuesta correcta no es aguantarlo: es construirlas en un corredor de integración continua x86, que además es donde deberían construirse las imágenes de producción de todos modos.

> 💡 **Y la comprobación que evita la tarde perdida de la Fase 14:** antes de `kind load`, `docker image inspect --format '{{.Architecture}}'`. Un segundo, y descarta la causa más desconcertante del capítulo.

---

## 5. Colima, Docker Desktop y Podman

Los tres funcionan con este curso. Lo que sigue es lo mínimo para elegir y para no quedarte atascado.

**Docker Desktop.** Lo más sencillo si no quieres pensar: instalar y funciona, con `docker` y `docker compose` incluidos. Trae emulación de amd64 integrada —Rosetta en macOS reciente— configurable desde sus ajustes. Tiene licencia de pago para empresas por encima de cierto tamaño, y es lo que hace que mucha gente busque las otras dos.

**Colima.** Una máquina virtual ligera con Docker o containerd dentro, gestionada desde la terminal. Gratis y muy usada en Mac.

```bash
brew install colima docker
colima start                          # arm64 nativo, que es lo que quieres
colima start --arch x86_64            # emulado, sólo si de verdad lo necesitas
colima start --vm-type vz --vz-rosetta   # emulación más rápida en macOS reciente
```

**Podman.** Sin demonio, compatible con la línea de comandos de Docker. También arranca una máquina virtual en Mac.

```bash
brew install podman
podman machine init && podman machine start
```

> ⚠️ **Lo que cambia según cuál elijas está en la Fase 14, y es una línea.** `kind load docker-image` consulta el almacén de imágenes de un demonio de Docker; con Podman o con ciertas configuraciones de Colima, no lo encuentra. La solución universal —que funciona con los tres porque no depende de quién guarde la imagen, sólo de un archivo— ya está en esa fase:
>
> ```bash
> docker save certcore:fase-13 -o /tmp/certcore.tar     # o `podman save`
> kind load image-archive --name certcore /tmp/certcore.tar
> ```

> 🧭 **La recomendación honesta: usa el que ya tengas.** El curso corre sobre el runtime de contenedores que tengas instalado y no se ata a ninguno. Cambiar de runtime a mitad de la Fase 13 para "hacerlo bien" es gastar una tarde en algo que no enseña nada.

---

## 6. 🩺 Diagnóstico por síntoma

| Síntoma | Causa más probable | Comprobación | Arreglo |
|---|---|---|---|
| `npm ci` va lentísimo y el ventilador no para | Node x64 bajo emulación | `node -p "process.arch"` dice `x64` | reinstalar Node desde una terminal nativa (§2) |
| `exec format error` al correr un contenedor | imagen amd64 en máquina arm64 | `docker image inspect … --format '{{.Architecture}}'` | reconstruir sin `--platform`, o instalar la emulación |
| Pod en `CrashLoopBackOff` con logs vacíos en kind | lo mismo, dentro del cluster | inspeccionar la imagen **antes** del `kind load` | reconstruir para arm64 |
| `kind load docker-image` no encuentra la imagen | tu runtime no es un demonio de Docker | `colima status` / `podman machine list` | `docker save` + `kind load image-archive` |
| Karma no arranca: "No binary for Chrome" | el lanzador no encuentra el navegador | `echo $CHROME_BIN` | exportar `CHROME_BIN` con la ruta real (§3) |
| El build de la imagen tarda diez veces más | estás construyendo emulado | ¿hay un `--platform=linux/amd64`? | construir nativo, o mover el build a integración continua |
| Buscas cómo arreglar `node-gyp` | vienes del Track A | — | no aplica: aquí nada compila C++ (§2) |
| Todo va bien pero el servidor de producción rechaza tu imagen | construiste arm64 y el destino es x86 | `docker image inspect` | `buildx` multi-arquitectura, o construir en el pipeline (§4) |

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer |
|---|---|
| Empezar el curso en un Mac con chip M | nada especial: `nvm install` y adelante (§2) |
| Correr los tests de la Fase 12 | fuera del contenedor, con el Chrome nativo |
| Construir la imagen de la Fase 13 para ti | `docker build` a secas: sale arm64 y es lo que quieres |
| Llevar esa imagen a kind (Fase 14) | comprobar la arquitectura **antes** del `kind load` |
| Producir una imagen para un servidor x86 | `buildx` con las dos plataformas, o construir en integración continua |
| Elegir runtime de contenedores | el que ya tengas |
| Un error que no menciona la arquitectura | las tres capas de la §1, en orden |

---

## 📚 Referencias

- https://nodejs.org/en/download — los binarios oficiales; la columna de macOS ARM64 existe desde Node 16.
- https://github.com/nvm-sh/nvm — nvm, que instala la arquitectura de la terminal desde la que lo ejecutas. Ese detalle es la §2 entera.
- https://docs.docker.com/build/building/multi-platform — `--platform`, `buildx` y los manifiestos multi-arquitectura de la §4.
- https://docs.docker.com/desktop/settings-and-maintenance/settings — dónde se activa la emulación en Docker Desktop.
- https://github.com/abiosoft/colima — Colima, con las opciones de `--arch` y `--vm-type`.
- https://podman.io/docs — Podman y `podman machine`.
- https://kind.sigs.k8s.io/docs/user/quick-start — kind, incluida la carga de imágenes desde un archivo.
- https://github.com/karma-runner/karma-chrome-launcher — `CHROME_BIN` y los lanzadores personalizados de la §3.

> ⚠️ Este es el apéndice del curso que envejece más rápido, porque depende de herramientas fuera del control de Angular y de un ecosistema que en Apple Silicon todavía se mueve. Si algo de aquí no coincide con lo que ves, la documentación de tu runtime manda sobre este documento, y la §1 sigue siendo válida pase lo que pase.

**Orden de lectura sugerido:** la §1 y la §2 antes de la Fase 0 — cinco minutos que te ahorran dudar más adelante. La §3 sólo si Karma no arranca. La §4 y la §6 con la Fase 13 abierta, y la §6 de nuevo el día que un pod entre en `CrashLoopBackOff` sin explicarse. La §5 únicamente si todavía no tienes runtime instalado.

---

## 🧪 Ejercicios (6)

> Estos ejercicios **requieren un Mac con Apple Silicon**. Si no lo tienes, no necesitas este documento: sáltalo entero.

1. 🟢 Ejecuta los cuatro comandos de la §1 y anota las cuatro respuestas. Guárdalas: son la línea base contra la que vas a comparar cualquier cosa rara que pase en las Fases 13 y 14.

2. 🟢 Comprueba que las dos imágenes base de la Fase 13 tienen variante arm64: `docker image inspect node:18.18.2-alpine --format '{{.Architecture}}'` y lo mismo con `nginx:1.25-alpine`. Explica en una línea por qué eso hace que el Dockerfile del curso no necesite ningún ajuste especial.

3. 🟡 Construye la imagen de la Fase 13 dos veces: una normal y otra con `--platform=linux/amd64`. Anota los dos tiempos y las dos arquitecturas. Con esas cifras delante, argumenta dónde deberían construirse las imágenes de producción.

4. 🟡 Provoca el error de la §6 a propósito: carga la imagen amd64 en el cluster de kind de la Fase 14, aplica el Deployment y anota **todo** lo que ves — el estado del pod, la salida de `logs`, la de `logs --previous` y la de `describe`. Escribe después la frase de una línea que le dirías a un compañero para que reconozca este fallo en treinta segundos.

5. 🟠 Corre los tests de la Fase 12 con `CHROME_BIN` apuntando a una ruta que no existe y anota el error. Después ponlo bien. Explica por qué este fallo no tiene nada que ver con arm64, aunque lo encuentres en un documento sobre arm64.

6. 🔴 Publica una imagen multi-arquitectura de CertCore con `buildx` en un registro —vale uno local que levantes tú— y comprueba con `docker manifest inspect` que el manifiesto lista las dos plataformas. Después explica en un párrafo por qué el manifiesto multi-arquitectura no se puede guardar en el almacén local y qué implica eso para el flujo de trabajo de un equipo mixto de Macs con chip M y portátiles x86.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida de plataforma y no produce código del proyecto: lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 13: …`, `fase 14: …`). Las mediciones del ejercicio 3 —los dos tiempos de build— van en el mensaje de un tag anotado (`ej/a12/3`), que es donde una cifra de esta clase queda fechada y comparable con la de otra máquina. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
APPENDIX_EOF
wc -l a12-arm64-m1.md; ls a*.md

# --- 2026-09-07T00:10:16 · Final self-check across 13 appendices
printf "%-32s %6s %5s %5s %5s %5s\n" ARCHIVO LINEAS EJ TAG ANY 🔥; for f in a*.md; do printf "%-32s %6s %5s %5s %5s %5s\n" "$f" "$(wc -l < $f)" "$(awk '/^## 🧪 Ejercicios/,0' $f | grep -cE '^[0-9]+\. ')" "$(grep -c '00-convencion-de-git-y-tags.md' $f)" "$(grep -cE ': any\b|as any|<any>' $f)" "$(grep -c '🔥 \*\*Opcional' $f)"; done; echo; echo "--- enlaces a .md en todos ---"; grep -hoE '\]\([a-z0-9][^)]*\.md\)' a*.md | sort | uniq -c

# --- 2026-09-07T00:33:09 · Rename A10 and find references
git mv a10-migracion-9-16.md a10-migracion-8-16.md 2>/dev/null || mv a10-migracion-9-16.md a10-migracion-8-16.md; ls a10*; echo "--- referencias al nombre viejo en todo el curso ---"; grep -rn 'a10-migracion-9-16\|migracion-9-16' . ../CLAUDE.md 2>/dev/null; echo "--- menciones de A10 con título ---"; grep -rn 'A10' prompts/*.md ../CLAUDE.md 2>/dev/null | grep -iv 'A100'

# --- 2026-09-07T00:33:21 · Propagate A10 rename and title
cd prompts && sed -i '' \
 -e 's|a10-migracion-9-16\.md|a10-migracion-8-16.md|g' \
 -e 's|Puente Angular 9 → 16|Puente Angular 8/9 → 16|g' \
 -e 's|puente 9 → 16|puente 8/9 → 16|g' \
 -e 's|A10 Puente Angular 8/9 → 16|A10 Puente Angular 8/9 → 16|g' \
 propuesta-fases-y-alcance.md prompts-extendidos-apendices.md alcance-del-proyecto.md plantillas-de-capitulo.md
sed -i '' 's|de Angular 9 a 16\.2\.12|de Angular 8.2.14 / 9 a 16.2.12|' prompts-extendidos-apendices.md
cd .. && grep -rn 'a10-migracion\|Puente Angular 8/9\|puente 8/9\|puente 9 →\|Angular 9 → 16' prompts/*.md

# --- 2026-09-07T00:33:28 · Find forensic spec references
grep -rn 'forense' prompts/*.md | grep -v _deprecado | head -30

# --- 2026-09-07T00:33:34 · Read forensic sections of two phases
sed -n '619,643p' 00-setup-hola-mundo.md; echo "======== fase 7 forense ========"; sed -n '1219,1252p' 07-plantillas-versionadas.md

# --- 2026-09-07T00:33:44 · Read incident notebook format spec
sed -n '1,120p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-07T00:33:47 · Rest of incident format spec
sed -n '120,373p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-07T00:33:50 · Collect all reserved incident IDs
for f in 0[0-9]-*.md 1[0-4]-*.md; do case $f in 00-convencion*|00-historia*) continue;; esac; awk '/^### Reservas para el cuaderno/,0' "$f" | grep -E '^\| *[0-9]+ *\|' | sed "s|^|${f%%-*} |"; done

# --- 2026-09-07T00:34:22 · Extract all forensic sections
for f in 0[0-9]-*.md 1[0-4]-*.md; do case $f in 00-convencion*|00-historia*) continue;; esac; echo "########## ${f} ##########"; awk '/^### Pieza forense de esta fase/,/^\*\*🧨|^## 🧪/' "$f" | head -40; done 2>/dev/null | head -400

# --- 2026-09-07T00:34:40 · Find all promises of forensic files
grep -n '📄' *.md

# --- 2026-09-07T00:34:57 · Fix screenshot promises and file list
sed -i '' 's|> 📄 El detalle completo, con capturas y la ruta de decisión, en `forense-fase-00.md`.|> 📄 El recorrido completo, con la salida literal de cada herramienta y la ruta de decisión, en `forense-fase-00.md`.|' 00-setup-hola-mundo.md
sed -i '' 's|con los mensajes literales y las capturas, en `forense-fase-02.md`|con los mensajes literales de cada paso, en `forense-fase-02.md`|' 02-autenticacion.md
sed -i '' 's|con capturas de cada fallo y el árbol de decisión, en `forense-fase-03.md`|con la salida literal de cada fallo y el árbol de decisión, en `forense-fase-03.md`|' 03-mock-api-caos.md
sed -i '' 's|con las capturas del panel Memory y cómo leer la cadena de retención, en `forense-fase-04.md`|con la lectura del panel Memory paso a paso y cómo seguir la cadena de retención, en `forense-fase-04.md`|' 04-estado-servicios.md
sed -i '' 's|forense-fase-00.md … forense-fase-13.md|forense-fase-00.md … forense-fase-14.md|' prompts/propuesta-fases-y-alcance.md
grep -n '📄' *.md | grep -i captura; grep -n 'forense-fase-00.md …' prompts/propuesta-fases-y-alcance.md

# --- 2026-09-07T00:36:06 · Write forensic format spec
cat > prompts/formato-piezas-forenses.md <<'SPEC_EOF'
# 🕵️ Formato de las piezas forenses
## Tutorial Angular 16 — Inspecciones y certificaciones

Este documento **no es** una pieza forense: es su especificación. Define cómo se
construyen `forense-master.md` y los quince `forense-fase-NN.md`, que son los
entregables del track forense.

> 🧭 **El track forense va embebido en las fases y desarrollado aparte.** Cada
> fase lleva su sección 6 —«⚠️ Errores comunes y pieza forense»— con el resumen
> que el estudiante lee de corrido, y termina prometiendo el recorrido completo en
> su archivo. **Esa promesa es un contrato**: la pieza forense entrega exactamente
> lo que la fase anunció, ni más ni menos.

**Presupuesto:** las horas del track forense **ya están dentro de las 108h de las
fases**. Estos archivos no añaden calendario: son el desarrollo de una sección que
ya está contada.

---

## 1. Qué es y qué no es una pieza forense

**Es** el recorrido completo de una investigación: el ticket tal como llegó, cada
paso con su salida literal, y la decisión que cada paso permite tomar. Se lee con
el navegador abierto y el proyecto corriendo.

**No es** ninguna de estas cuatro cosas, y las cuatro son la forma habitual de
arruinar el archivo:

- **No es un resumen de la fase.** La fase ya se leyó. Si un párrafo se puede
  copiar de la sección 6, sobra: enlázala.
- **No es un tutorial de DevTools.** Se usan las herramientas, no se explican.
  El lector es un dev senior de backend: sabe qué es una petición HTTP.
- **No construye código nuevo del proyecto.** El código lo escriben las fases.
  Una pieza forense puede pedir romper algo a propósito, y entonces dice cómo
  deshacerlo.
- **No inventa salidas.** Todo bloque de salida tiene que ser reproducible con el
  proyecto del curso y su semilla. Si un valor depende de la máquina —un puerto,
  un hash, una fecha— se marca con `…` o con un marcador evidente.

---

## 2. La regla que reemplaza a las capturas

> 🧭 **Texto, nunca imágenes.** Una captura no se versiona, no se busca con
> `Ctrl+F`, no se puede copiar a un ticket, y envejece con cada versión de Chrome.
> Todo lo que en una investigación real mirarías en pantalla, aquí se transcribe:
> el mensaje de consola literal, la fila de Network en texto, la salida del
> comando.

Cuando lo que hay que transmitir es **dónde** mirar y no **qué** dice, se describe
la ruta con las palabras exactas de la interfaz: *"Network → filtro `Fetch/XHR` →
la petición a `/templates` → pestaña Headers → sección Request Headers"*. Esa
frase sobrevive a un rediseño mejor que una captura, y se puede dictar por
teléfono.

---

## 3. Estructura de un `forense-fase-NN.md`

Siete bloques, en este orden. Los bloques 5 y 6 pueden faltar si la fase no da
para ellos; los otros cinco son obligatorios.

1. **Encabezado** — fase de la que sale, herramientas que usa, tiempo estimado del
   recorrido, y **el síntoma en una línea**.
2. **🎫 El ticket** — el reporte literal, con su vaguedad incluida, y quién lo
   reportó. Si la fase promete varios tickets, van todos, cada uno con su ruta.
3. **🧭 La ruta** — los pasos numerados (§4). Es el cuerpo del archivo.
4. **🩺 Diagnóstico por síntoma** — la tabla de "esto veo, aquí miro". Es lo que
   se consulta seis meses después, cuando ya no recuerdas el recorrido.
5. **⚰️ Los callejones** — las hipótesis plausibles que no eran, con la evidencia
   que las tumba. Opcional pero muy recomendable: **saber qué descartar vale tanto
   como saber qué buscar**.
6. **🧨 Deshacer** — cómo devolver el proyecto a su estado, si el recorrido pidió
   romper algo. Obligatorio en cuanto haya un solo paso destructivo.
7. **🧠 El patrón transferible** — dos o tres frases con lo que se lleva al
   trabajo real, más los enlaces: incidentes del cuaderno que usan esta ruta, y
   apéndices que amplían.

---

## 4. Cómo se escribe un paso de la ruta

Cada paso tiene tres partes y siempre en el mismo orden. Es lo que hace que el
archivo se pueda seguir con el teclado en la mano.

```markdown
### Paso N — {{la pregunta que contesta este paso}}

{{Qué haces. Una o dos frases, en imperativo, con la ruta exacta de la interfaz o
el comando completo.}}

​```
{{La salida LITERAL. Consola, cuerpo de la respuesta, línea de Network, stdout.}}
​```

**Qué descarta.** {{Qué hipótesis muere con esta salida, y a qué paso saltas según
lo que hayas visto. Un paso que no descarta nada no es un paso: es relleno.}}
```

Tres reglas sobre los pasos:

- **El orden es la lección.** Los pasos van del más barato al más caro, no del más
  probable al menos probable. Mirar una URL cuesta diez segundos; abrir el
  perfilador de memoria cuesta diez minutos. Ese orden **se dice explícitamente**
  al empezar la ruta.
- **Un paso, una pregunta.** Si un paso contesta dos cosas, son dos pasos.
- **La ruta termina cuando se sabe dónde está el bug, no cuando está arreglado.**
  El fix es de la fase o del incidente; la pieza forense localiza.

---

## 5. Qué pone la fase y qué pone la pieza

La frontera es la misma regla anti-solapamiento de los apéndices, y aquí hay que
vigilarla más porque los dos textos hablan de lo mismo.

| Va en la sección 6 de la fase | Va en `forense-fase-NN.md` |
|---|---|
| El resumen de qué se rompe y por qué | El recorrido, paso a paso |
| La tabla corta de síntomas, si es lo central de la fase | La tabla completa, con las causas raras |
| El 🧨 «Rompe a propósito» del estudiante | Cómo se lee lo que ese 🧨 produce |
| El enunciado del problema | Las salidas literales y los callejones |

Si un párrafo cabe igual de bien en los dos sitios, va en la fase y la pieza lo
enlaza. La fase se lee siempre; la pieza, sólo cuando hace falta.

---

## 6. `forense-master.md`

Es el índice y el método del track, y **no repite ninguna de las quince piezas**.
Cinco bloques:

1. **El método** — las cuatro preguntas que ordenan cualquier investigación de
   este curso, y por qué siempre en ese orden.
2. **📇 Índice de las quince piezas** — una fila por fase: síntoma, herramienta
   principal, archivo.
3. **🩺 Índice de síntomas transversal** — la tabla que cruza *"esto es lo que
   veo"* con *"esta es la pieza que lo cubre"*. Es la puerta de entrada real del
   track: nadie llega sabiendo de qué fase es su problema.
4. **🧰 Las herramientas, y en qué miente cada una** — consola, Network, Angular
   DevTools, panel Memory, panel Performance, `kubectl`. Una línea por
   herramienta, con su mentira característica.
5. **Cierre** — remite al `HOTFIX.md` que escribe la **Fase 13 §5.9**, que es el
   entregable de una página que el estudiante se lleva al trabajo real. El master
   **no lo duplica**: lo enlaza y dice cuándo se usa.

---

## 7. Convención de commits y tags

Una pieza forense no produce código del proyecto, así que lo que salga de
recorrerla se commitea con el prefijo de su fase (`fase 07: …`). Cuando el
recorrido corresponde a un incidente del cuaderno, el par de tags
`inc/<ID>/<slug>-roto` e `inc/<ID>/<slug>-fix` es el mismo que ya reserva el
cuaderno: **no se inventa otro**. El detalle está en
[`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md) y no se
reexplica en ninguna pieza.

---

## 8. Checklist antes de dar por cerrada una pieza forense

- [ ] Entrega **exactamente** lo que la línea 📄 de su fase promete: los tickets
      que anuncia, y la salida de cada paso.
- [ ] Cero capturas. Todas las evidencias en texto (§2).
- [ ] Cada paso dice qué descarta y a dónde saltar (§4).
- [ ] Los pasos van del más barato al más caro, y eso se dice.
- [ ] Ninguna salida está inventada: todo se reproduce con el proyecto del curso
      y su semilla, y lo variable va marcado.
- [ ] Si algún paso rompe algo, hay bloque 🧨 «Deshacer».
- [ ] No repite la sección 6 de su fase (§5).
- [ ] Código en inglés, comentarios y mensajes en español con tildes; `strict`
      respetado; el estilo —nuevo o heredado— del archivo que se toca.
- [ ] Enlaza los incidentes del cuaderno que usan esta ruta, por su ID reservado.
- [ ] Cierra con el patrón transferible, que es lo único que el estudiante se
      lleva si no vuelve a abrir el archivo.
SPEC_EOF
wc -l prompts/formato-piezas-forenses.md

# --- 2026-09-07T00:37:12 · Write forense-master.md
cat > forense-master.md <<'EOF'
# 🕵️ Track forense — índice y método

> Tutorial Angular 16 — Inspecciones y certificaciones · Puerta de entrada del track
> Cubre las quince piezas: `forense-fase-00.md` … `forense-fase-14.md`

Este archivo es la puerta. Nadie llega a una investigación sabiendo de qué fase es su problema: llega con un síntoma, y casi siempre con uno mal descrito. Por eso el índice que de verdad importa aquí no es el de fases (§2) sino el de **síntomas** (§3).

**Las horas del track forense ya están dentro de las 108h de las fases.** Esto no es material adicional: es el desarrollo de una sección que cada fase ya cuenta.

---

## 1. El método: cuatro preguntas, siempre en este orden

El orden no es una preferencia. Es que cada pregunta cuesta un orden de magnitud más que la anterior, y contestar la barata primero descarta la mitad de las caras.

**Pregunta 1 — ¿Se reproduce, y con qué?** Antes de mirar una línea de código: ¿esto se reproduce **con un flag** del inyector de caos, **con un dato** distinto, o hace falta **otro código**? Las tres respuestas llevan a investigaciones distintas y averiguar cuál es te ahorra la mitad del camino. Es la misma pregunta que ordena la preparación de los incidentes del cuaderno.

**Pregunta 2 — ¿Qué dice la evidencia observable, antes de lo que dice el código?** La URL de una petición, el cuerpo crudo de una respuesta, el estado de un control, el paréntesis de un `NullInjectorError`. Casi todas las rutas de este track se resuelven aquí, y ninguna requiere abrir un archivo. **El código es el paso 4, no el paso 1.**

**Pregunta 3 — ¿En qué capa está?** Plantilla, componente, servicio de estado, `*ApiService`, interceptor, guard, mock, build, contenedor. Localizar la capa es el entregable de una investigación; el fix suele ser de tres líneas y viene después.

**Pregunta 4 — ¿De qué generación es el archivo que voy a tocar?** 🧬 Ésta es la pregunta propia de este track y no existe en un sistema de una sola época. Un fix en un componente de NgModule se escribe como el resto de ese componente; uno en un standalone, con `inject()`. Contestarla antes de escribir evita el diff que mezcla dos estilos y que nadie sabe revisar.

> 🧭 **La regla que resume las cuatro:** *"funciona en mi máquina", "a veces pasa" y "desde ayer" no son descripciones de un bug: son descripciones de una diferencia.* El trabajo es encontrar cuál.

---

## 2. Índice de las quince piezas

| Fase | Síntoma que cubre | Herramienta principal | Archivo |
|---|---|---|---|
| 0 | "Le di guardar y no pasó nada" | Consola · Network · source maps | `forense-fase-00.md` |
| 1 | "La ruta funciona pero la pantalla sale en blanco" | Errores de NgModule · Network (JS) | `forense-fase-01.md` |
| 2 | "Me saca al login sin decir nada" | Breakpoints en interceptor · Headers | `forense-fase-02.md` |
| 3 | "A veces carga y a veces no" | Los seis fallos del caos · Network | `forense-fase-03.md` |
| 4 | "La lista se actualizó dos veces" | `console.count` · panel Memory | `forense-fase-04.md` |
| 5 | "No hay proveedor para…" 🧬 | Los dos `NullInjectorError` | `forense-fase-05.md` |
| 6 | "No me deja guardar y no dice por qué" | `ng.getComponent($0)` · estado del formulario | `forense-fase-06.md` |
| 7 | "Esta inspección se ve con otra plantilla" ⭐ | La URL de `/templates` | `forense-fase-07.md` |
| 8 | "Escribo y la aplicación se queda pegada" ⭐ | Network en reposo · claves del `FormRecord` | `forense-fase-08.md` |
| 9 | "Aprobó y no debía" | JSON crudo · `null` frente a `undefined` | `forense-fase-09.md` |
| 10 | "Venció ayer para uno y hoy para otro" | El offset de la cadena ISO | `forense-fase-10.md` |
| 11 | "Desde ayer el panel va lentísimo" | Los cuatro sospechosos, en orden | `forense-fase-11.md` |
| 12 | "Pasa en mi máquina y falla en el pipeline" | La semilla de Jasmine · bisección | `forense-fase-12.md` |
| 13 | "En UAT entra y en PROD no" | Digest de la imagen · `curl -I` | `forense-fase-13.md` |
| 14 | "El pod no arranca" 🔥 | `describe` frente a `logs` | `forense-fase-14.md` |

---

## 3. 🩺 Índice de síntomas transversal

La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la derecha, dónde empezar.

| Lo que ves o te cuentan | Empieza en |
|---|---|
| La pantalla se queda en blanco al entrar a una ruta | Fase 1 (módulo/declaración) → Fase 5 si el componente es standalone 🧬 |
| "Le di guardar y no pasó nada", sin errores en consola | Fase 0 — la consola miente por omisión |
| Network dice `(failed)` sin status | Fase 3 — `cors`, servidor caído o red ausente: **son indistinguibles desde el código** |
| `200` verde y la pantalla dice que el dato no tiene la forma esperada | Fase 3 — `malformed`, el fallo que miente |
| Spinner eterno, la petición en `pending` para siempre | Fase 3 — `timeout` |
| Me devuelve al login sin explicación | Fase 2 — ¿guard o interceptor? Lo dice Network en diez segundos |
| `NullInjectorError: No provider for X` | Fase 5 — el paréntesis del mensaje decide dónde buscar 🧬 |
| `NG0203: inject() must be called from an injection context` | Fase 2 · **A04** §7 — casi siempre un `subscribe` o un hook |
| "No me deja guardar y no dice por qué" | Fase 6 — el formulario contesta antes que el código |
| Un formulario que nunca llega a ser válido | Fase 6 — `PENDING` no es `INVALID`: un validador asíncrono no completó |
| Una inspección vieja se ve con la plantilla nueva | Fase 7 ⭐ — la URL de `/templates`, sin abrir un archivo |
| Una inspección vieja se ve con la plantilla vieja | Fase 7 ⭐ — **no es un bug**; hay que demostrarlo |
| La aplicación se arrastra al escribir en un formulario | Fase 8 ⭐ — Network en reposo delata el bucle |
| Aparecen campos que no son de esta inspección | Fase 8 — control huérfano: compara claves del formulario con ítems |
| `NG0100 ExpressionChangedAfterItHasBeenChecked` | Fase 8 — y ojo: **desaparece en producción**, el bug no |
| Una regla de negocio no se aplicó y no hay error | Fase 9 — `null`, `undefined` y campo ausente son tres cosas |
| Un dato cambió y volvió solo al día siguiente | Fase 9 — dato guardado frente a dato derivado |
| Un documento exportado no dice lo mismo que la pantalla | Fase 10 · **A08** §7 — se armó desde la vista |
| "Venció ayer/hoy según a quién le preguntes", y sólo por la tarde | Fase 10 — nunca es un bug de fechas: es no haber decidido a qué hora vence algo |
| La pestaña va poniéndose lenta con las horas | Fase 4 — fuga de suscripción; el panel Memory sólo si el comportamiento no basta |
| Sales de una pantalla y el servidor sigue recibiendo peticiones | Fase 11 → Fase 4 — dos minutos de Network y ya lo sabes |
| El panel va lento | Fase 11 — cuatro sospechosos, y `ChangeDetectionStrategy` es **el último** |
| Un test falla a veces | Fase 12 — reloj, azar, orden, o el DOM que quedó sucio |
| "Desplegamos el fix y la gente sigue viendo el error" | Fase 13 — caché del `index.html`, casi siempre |
| "En UAT funciona y en PROD no" | Fase 13 — configuración, caché, versiones, y **sólo al final**, código |
| Un pod no arranca 🔥 | Fase 14 — `describe` si nunca llegó a `Running`, `logs --previous` si arrancó y murió |
| `CrashLoopBackOff` sin logs, en un Mac con chip M 🔥 | **A12** §6 — casi siempre una imagen amd64 |

---

## 4. 🧰 Las herramientas, y en qué miente cada una

Ninguna herramienta miente por malicia: cada una contesta una pregunta muy concreta, y el error es preguntarle otra.

**La consola** miente **por omisión**. Un `subscribe` sin callback de `error` traga el fallo entero: la petición falló, la pantalla se congeló, y la consola está limpia. Y miente por ilegibilidad: sin source maps, el stack apunta a un bundle minificado.

**La pestaña Network** miente **por status**. Un `201` significa que el servidor contestó, no que hizo lo que crees. Y un `200` con el cuerpo cambiado —el `malformed` de la Fase 3— es el caso donde el semáforo verde te cuesta media hora.

**Angular DevTools** miente **por versión de build**. `ng.getComponent($0)` sólo existe en el build de desarrollo. En producción no está, y ésa es exactamente la diferencia que la Fase 13 te obliga a mirar de frente.

**El panel Memory** no miente, pero **contesta tarde**. Un heap snapshot cuesta minutos y casi siempre el comportamiento ya te había dado la respuesta: un `console.count` bien puesto delata una fuga sin abrir nada. Úsalo cuando el síntoma sea "va poniéndose lenta" y no haya nada visible que contar.

**El panel Performance** miente **por interpretación**. Un ciclo de detección de cambios con doscientos componentes revisados no es un problema si dura 3 ms. La columna que importa es el tiempo, no el conteo.

**`kubectl`** miente **por momento**. `kubectl logs` te enseña el intento actual, que puede llevar dos segundos de vida y no haber fallado todavía. El mensaje que buscas está en `--previous`.

**Y el `git log`**, que no es una herramienta de depuración hasta que lo es. `git log -S"resolveTemplateVersion"` encuentra el commit donde una línea apareció o desapareció, y `git bisect` encuentra el commit que rompió algo cuando ninguna de las otras herramientas te dice por qué. La convención de commits y tags del curso —incluido el par `inc/<ID>/…-roto` e `inc/<ID>/…-fix`— existe para que ese `log` sirva: está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 5. Cómo se cierra el track

Este archivo te dice **dónde empezar**. Las quince piezas te dicen **cómo recorrer** cada camino. Y el entregable que te llevas al trabajo real no está en ninguno de los dos: es el `HOTFIX.md` de una página que escribes tú en la **Fase 13 §5.9**, con sus cuatro momentos —antes de escribir código, al escribir el fix, antes de desplegar, después de desplegar—.

Ese archivo es lo único de todo el curso que sirve en un sistema que no es CertCore. El resto es entrenamiento para poder escribirlo.

> 🧭 **Y el criterio para saber si el track hizo su trabajo:** que ante un ticket vago, tu primer movimiento ya no sea abrir el editor.
EOF
wc -l forense-master.md

# --- 2026-09-07T00:37:25 · Read seed data
sed -n '143,240p' 03-mock-api-caos.md

# --- 2026-09-07T00:37:28 · Rest of seed and auth users
sed -n '240,330p' 03-mock-api-caos.md; echo "=== usuarios auth ==="; grep -n 'inspector@\|supervisor@\|password\|users' 02-autenticacion.md | head -12

# --- 2026-09-07T00:38:34 · Write forense-fase-00
cat > forense-fase-00.md <<'EOF'
# 🕵️ Forense Fase 00 — "Le di guardar y no pasó nada"

> Pieza forense de la **Fase 0 — Setup + hola mundo standalone** · Recorrido: ~25 min
> Herramientas: consola · pestaña Network · source maps
> Síntoma que cubre: el usuario pulsó un botón, no ve ningún error, y no está seguro de si se guardó.

Es el síntoma más frecuente de todos y el que menos información trae. "No pasó nada" puede significar cinco cosas distintas, y las cinco se distinguen en menos de un minuto **sin abrir un solo archivo**. Ésa es la ruta.

El resumen de en qué miente cada herramienta está en la sección 6 de la fase. Aquí está el recorrido con la salida de cada paso.

---

## 🎫 El ticket

> *"Llené el formulario de solicitud para el ascensor de la torre A, le di a Solicitar inspección y no pasó nada. No sé si quedó. Lo hice tres veces."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** desarrollo, con `npm run mock` y `ng serve` corriendo

Fíjate en el dato que el reporte trae sin saberlo: **lo hizo tres veces**. Si la petición sí salía, hay tres solicitudes en el mock. Eso ya es una comprobación.

---

## 🧭 La ruta

Cinco pasos, ordenados **del más barato al más caro**. El paso 1 cuesta diez segundos y descarta la mitad de los casos; el paso 5 cuesta un build entero. Nunca al revés.

### Paso 1 — ¿La petición llegó a salir?

DevTools → **Network** → filtro `Fetch/XHR` → *Preserve log* activado → pulsa el botón otra vez.

```
Name                    Status    Type    Initiator            Size     Time
inspection-requests     201       xhr     zone.js:xxxx         241 B    12 ms
```

**Qué descarta.** Si aparece una fila, el navegador habló con alguien: no es un problema de que el botón no esté conectado, ni de que el formulario esté inválido y no dispare. Salta al **paso 3**.
Si **no aparece ninguna fila**, la petición nunca salió y el problema está antes: paso 2.

### Paso 2 — Si no salió: ¿el botón llega a llamar al método?

El formulario de la Fase 0 no envía si es inválido. Con el formulario abierto, en la consola:

```js
// $0 es el <form> seleccionado en el inspector de elementos.
const component = ng.getComponent($0);
component.form.status;   // 'INVALID'
component.form.errors;   // null  ← el grupo está bien; el problema está en un control
Object.entries(component.form.controls)
  .filter(([, control]) => control.invalid)
  .map(([name, control]) => [name, control.errors]);
// [ [ 'assetId', { required: true } ] ]
```

**Qué descarta.** Si sale un control inválido, no hay bug: hay un campo vacío y un mensaje que no se está mostrando — que **sí** es un bug, pero de interfaz, no de guardado. Si el formulario está `VALID` y aun así no sale nada por Network, entonces el `(ngSubmit)` no está conectado o hay una excepción antes del `subscribe`, y eso sí está en la consola.

### Paso 3 — ¿A qué URL, exactamente?

Clic en la fila → pestaña **Headers** → **Request URL**. Completa, con puerto y ruta.

```
Request URL:     http://localhost:3000/inspection-requests
Request Method:  POST
Status Code:     201 Created
```

**Qué descarta.** Aquí se cazan los dos errores más tontos y más frecuentes del curso, y los dos producen síntomas distintos:

| Lo que ves | Qué pasó |
|---|---|
| `http://localhost:4200/inspection-requests` | la URL base quedó relativa: le estás pidiendo al servidor de desarrollo, no al mock |
| `http://localhost:3001/…` con el mock en el 3000 | puerto equivocado → **no hay respuesta**, y el status es `(failed)` |
| `…/inspection-request` en singular | ruta equivocada → `404`, con cuerpo `{}` |
| `http://localhost:3000/inspection-requests` con `201` | la petición está bien. Sigue al paso 4 |

### Paso 4 — Un `201` no significa que hiciera lo que crees

Pestaña **Payload** —lo que enviaste— y pestaña **Response** —lo que devolvió—. En ese orden.

```json
// Request Payload
{
  "assetId": "ASC-CENTRAL-03",
  "requestedFor": "2025-03-14"
}
```

```json
// Response
{
  "assetId": "ASC-CENTRAL-03",
  "requestedFor": "2025-03-14",
  "id": 1
}
```

**Qué descarta.** El servidor guardó. Si el ticket dice que "no quedó", ya sabes que sí quedó y que el problema es que **la pantalla no lo dijo**: falta el mensaje de confirmación, o el `subscribe` tiene `next` y no hace nada visible. Ése es el bug, y está en el componente.

Y aquí aparece el otro hallazgo, el que la fase deja marcado 💸: `requestedFor` viaja como `"2025-03-14"`, **sin offset**. El servidor no se queja, el `201` es verde, y el dato está incompleto desde el primer día. No es el bug de este ticket; es el bug de la Fase 10, sembrado aquí.

### Paso 5 — Cuando la consola está limpia y aun así algo falló

Éste es el paso que explica por qué la consola miente por omisión:

```ts
// ❌ Esto traga el fallo entero. Petición fallida, pantalla congelada,
//    consola impecable.
this.http.post<InspectionRequest>(url, payload).subscribe((created) => {
  this.saved = true;
});

// ✅ Con el callback de error puesto, el fallo tiene dónde aparecer.
this.http.post<InspectionRequest>(url, payload).subscribe({
  next: (created) => { this.saved = true; },
  error: (error: unknown) => { console.error('No se pudo guardar la solicitud', error); },
});
```

Si el código bajo investigación no tiene `error`, **la consola limpia no es evidencia de nada**. Ponlo antes de sacar conclusiones; es la primera línea que se añade en cualquier investigación de este tipo.

Y el caso que cierra el paso: en un build de producción, la consola muestra el stack minificado.

```
ERROR TypeError: Cannot read properties of null (reading 'value')
    at t.<anonymous> (main.8a1f2c.js:1:48213)
```

Con `sourceMap.hidden: true` puesto y el `.map` al lado, DevTools traduce esa línea al archivo y la línea reales. Sin él, `main.8a1f2c.js:1:48213` es todo lo que vas a tener nunca. Es la diferencia entre una investigación de diez minutos y una de dos días, y la fase la deja preparada a propósito.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves en Network | Lo que significa | Dónde miras |
|---|---|---|
| Ninguna fila | la petición no salió | el formulario y el `(ngSubmit)` — paso 2 |
| `(failed)` sin status | nadie contestó: puerto, servidor caído o CORS | la URL y si el mock está vivo |
| `(failed)` y la consola habla de `Access-Control-Allow-Origin` | CORS | Fase 3; desde el código es indistinguible de un servidor caído |
| `404` | la ruta no existe | plural, guiones, la barra final |
| `201` / `200` y la pantalla no reacciona | el servidor hizo su trabajo | el `subscribe` del componente |
| `200` con un cuerpo que no es lo que esperabas | el borde HTTP | Fase 3 — es `malformed` |
| `500` | el servidor reventó | los logs del mock, no tu código |

---

## ⚰️ Los callejones

**"Es que el mock no está corriendo."** Se descarta en cinco segundos y sin salir de la terminal:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/inspection-requests
# 200 → está vivo
# 000 → no hay nadie escuchando en ese puerto
```

**"Es que el formulario borra los datos al enviar."** Plausible y falso: si `reset()` fuera el culpable, el payload del paso 4 estaría vacío o con `null`. Está completo, así que el problema es posterior al envío.

**"Es que Angular no detectó el cambio."** El sospechoso favorito y casi nunca el culpable. En la Fase 0 no hay `OnPush` en ninguna parte, así que la detección por defecto revisa todo ante cualquier evento. Si la pantalla no cambió, es porque **nadie cambió nada que pintar**, no porque no se enteró.

---

## 🧨 Deshacer

El 🧨 de la fase te hace cambiar el puerto de `API_BASE_URL` de `3000` a `3001`. Devuélvelo a `3000` en `src/environments/environment.ts` y `ng serve` recompila solo. Si probaste también la ruta en singular, la misma línea.

Las solicitudes que se crearon durante la investigación quedan en el `db.json`; `npm run seed` lo devuelve a la semilla.

---

## 🧠 El patrón transferible

> **"No pasó nada" no es un síntoma: es la ausencia de uno.** El trabajo es convertirlo en un síntoma concreto, y la conversión cuesta un minuto: ¿salió la petición?, ¿a dónde?, ¿qué contestó?, ¿qué mandaste? Cuatro preguntas, cuatro pestañas, y ninguna requiere leer código.

Y el corolario que vale para cualquier stack: **una consola limpia sólo es evidencia si sabes que alguien estaba escuchando.** Un `catch` vacío, un `subscribe` sin `error`, un `.catch(() => {})` en un `Promise`: los tres producen exactamente este ticket.

**Incidentes del cuaderno que usan esta ruta:** 01 (el proyecto que no arranca) y 03 (la sesión que se cae sin decir nada).
**Amplía:** **A03** para el entorno y las versiones, **A06** §6 para qué hacer con el error una vez que aparece.
EOF
wc -l forense-fase-00.md

# --- 2026-09-07T00:39:45 · Write forense-fase-01
cat > forense-fase-01.md <<'EOF'
# 🕵️ Forense Fase 01 — "La ruta funciona pero la pantalla sale en blanco"

> Pieza forense de la **Fase 1 — Estructura base con NgModules** · Recorrido: ~30 min
> Herramientas: mensajes del compilador de plantillas · `grep` · pestaña Network (filtro `JS`) · `--named-chunks`
> Síntoma que cubre: la URL cambia, no hay error visible, y donde debería haber una pantalla no hay nada.

Un `NgModule` no falla como falla el código normal. Su error llega **desde el compilador de plantillas**, nombra un selector en vez de un archivo, y a veces no llega: la pantalla simplemente se queda vacía. Esta pieza es el camino desde cada uno de esos mensajes hasta el archivo que hay que tocar.

La fase resume las tres preguntas; aquí están los mensajes literales de cada error y qué hacer con cada uno.

---

## 🎫 El ticket

> *"Agregué la pantalla de activos siguiendo la de plantillas. La ruta `/assets` cambia la URL, el menú se marca, y la pantalla queda en blanco. No sale nada rojo."*

**Reportado por:** un compañero del equipo, en desarrollo
**Ambiente:** `ng serve`

---

## 🧭 La ruta

Cuatro pasos, del más barato al más caro. El paso 1 son diez segundos de consola y resuelve el 70% de los casos.

### Paso 1 — ¿Hay un mensaje del compilador, o de verdad no hay nada?

Mira **la terminal de `ng serve` antes que la consola del navegador**. El compilador de plantillas escribe ahí, y si el navegador ya tenía la aplicación cargada, puede que no haya recargado.

Los cuatro mensajes que produce el 90% de las pantallas en blanco de este curso, literales:

```
NG0304: 'cc-asset-list' is not a known element:
1. If 'cc-asset-list' is an Angular component, then verify that it is part of this module.
2. If 'cc-asset-list' is a Web Component then add 'CUSTOM_ELEMENTS_SCHEMA' to the
   '@NgModule.schemas' of this component to suppress this message.
```
→ El componente existe pero **el módulo desde el que lo usas no lo conoce**. Paso 2.

```
NG0303: Can't bind to 'formGroup' since it isn't a known property of 'form'.
```
→ El componente existe y la **directiva** no. Falta `ReactiveFormsModule` en los `imports` de este módulo. Es el mismo problema con otra cara: en Angular, una directiva se importa igual que un componente.

```
Type AssetListComponent is part of the declarations of 2 modules: AssetsModule and
SharedModule! Please consider moving AssetListComponent to a higher module that imports
AssetsModule and SharedModule.
```
→ **Declarado dos veces.** Un componente pertenece a exactamente un módulo. Éste es el error que más gente intenta arreglar añadiéndolo a un tercer módulo, que lo empeora.

```
NG0201: No provider for HttpClient found in NodeInjector.
```
→ No es de declaraciones: es de providers, y a partir de la Fase 5 hay que mirar **el paréntesis del mensaje** para saber si buscar en módulos o en rutas. Eso es `forense-fase-05.md`.

**Qué descarta.** Si hay mensaje, tienes el camino resuelto: cada uno lleva a un sitio distinto. Si la terminal está limpia y el navegador también, entonces el componente sí se declaró y el problema es la ruta o el módulo diferido: salta al **paso 3**.

### Paso 2 — Del selector al módulo, en tres saltos

El mensaje te da un selector, no un archivo. El camino es siempre el mismo y no requiere conocer el proyecto:

```bash
# 1. El selector → el archivo del componente
grep -rn "cc-asset-list" src/
# src/app/features/assets/asset-list/asset-list.component.ts:8:  selector: 'cc-asset-list',
# src/app/features/assets/assets.component.html:12:  <cc-asset-list></cc-asset-list>

# 2. La clase → el módulo que la declara
grep -rn "AssetListComponent" src/ --include="*.module.ts"
# src/app/features/assets/assets.module.ts:14:  declarations: [AssetListComponent],

# 3. Y quién puede usarla: ¿está en `exports`?
grep -n "exports" src/app/features/assets/assets.module.ts
```

**Qué descarta.** Si el paso 2 no devuelve ningún `.module.ts`, el componente **no está declarado en ninguna parte** y ése es el bug. Si está declarado en un módulo pero no exportado, sólo se puede usar dentro de ese módulo — y ésa es la causa cuando el error aparece en una plantilla de otra feature.

> 🧭 **La regla de tres frases del árbol de inyectores y declaraciones:** un componente lo ve quien lo declara y quien importa un módulo que lo exporta. Nada más. No hay alcance global, no hay herencia de declaraciones, y un `SharedModule` que reexporta media librería sólo funciona para quien importa `SharedModule`.

### Paso 3 — Si no hay error: ¿el módulo es diferido de verdad?

No se lo preguntes al código. Pregúntaselo a Network:

DevTools → **Network** → filtro `JS` → *Disable cache* activado → recarga en `/` → navega a `/assets`.

```
Name                                            Status   Type    Size      Time
src_app_features_assets_assets_module_ts.js     200      script  18.4 kB   6 ms
```

**Qué descarta.**

- **Aparece un chunk nuevo al navegar** → la carga diferida funciona. El problema está dentro del módulo o de su routing interno: paso 4.
- **No aparece nada al navegar, y el peso de `main.js` es sospechosamente grande** → el módulo se volvió *eager*: alguien lo importó desde un módulo que sí se carga al arrancar. `grep -rn "AssetsModule" src/ --include="*.module.ts"` te dice quién.
- **No aparece nada y `main.js` es normal** → la ruta no está llegando al módulo. Revisa el `loadChildren` y, sobre todo, el **orden** de las rutas: una ruta comodín (`path: '**'`) colocada antes se come todo lo que va detrás.

### Paso 4 — Dentro del módulo: el `RouterModule.forChild` y su `<router-outlet>`

Dos causas producen exactamente la misma pantalla en blanco sin ningún error:

```ts
// ❌ El módulo de feature usa forRoot() en vez de forChild(). Registra un
//    segundo router raíz; las rutas hijas no se resuelven y nadie se queja.
imports: [RouterModule.forRoot(routes)]

// ✅
imports: [RouterModule.forChild(routes)]
```

```html
<!-- ❌ El componente contenedor de la feature no tiene dónde pintar a sus hijos.
     La ruta hija se activa, el componente se construye, y no se ve. -->
<h2>Activos</h2>

<!-- ✅ -->
<h2>Activos</h2>
<router-outlet></router-outlet>
```

Y la comprobación que los distingue en un segundo, en la consola:

```js
// Si la ruta se activó, el componente existe aunque no se vea.
ng.getComponent(document.querySelector('cc-asset-list'));
// undefined  → la ruta no llegó a construirlo: es un problema de rutas
// {…}        → existe y no se pinta: falta el <router-outlet> o el CSS lo oculta
```

### Paso 5 — En producción: qué chunk es cuál

En desarrollo los chunks se llaman `src_app_features_assets_assets_module_ts.js` y se leen solos. En producción, con `outputHashing` puesto, se llaman `493.8a1f2c.js` y no dicen nada. Dos formas de resolverlo:

```bash
# Para una investigación puntual, si puedes construir tú:
ng build --named-chunks

# Cuando el build es de un pipeline y no lo puedes cambiar:
ng build --stats-json
grep -o '"name":"[^"]*assets[^"]*"' dist/certcore/stats.json | sort -u
```

**Qué descarta.** Con el nombre del chunk en la mano, la pregunta "¿este código viaja en el arranque?" tiene respuesta objetiva. Es la misma técnica que la **Fase 10** usa para comprobar que `jspdf` no está en `main.js` y la que la **Fase 13** usa para los presupuestos de bundle.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| `NG0304` con un selector tuyo | componente no declarado o no importado aquí | `declarations` / `exports` del módulo |
| `NG0304` con `router-outlet` | falta `RouterModule` en los `imports` | el módulo de la plantilla que falla |
| `NG0303` con `formGroup`, `ngIf`, `matInput` | falta el módulo de esa **directiva** | `ReactiveFormsModule`, `CommonModule`, `MatInputModule` |
| `part of the declarations of 2 modules` | declarado dos veces | quítalo de uno; no lo añadas a un tercero |
| Pantalla en blanco, sin error, chunk que sí carga | falta `<router-outlet>` o es `forRoot` | el componente contenedor de la feature |
| Pantalla en blanco, sin error, chunk que no carga | ruta que no llega, o comodín antes | orden de las rutas del router raíz |
| Todo carga y `main.js` pesa de más | un módulo diferido se volvió eager | `grep` del módulo en los `.module.ts` |

---

## ⚰️ Los callejones

**"Es que el componente está mal escrito."** El compilador de plantillas te habría dicho otra cosa. `NG0304` no habla del contenido del componente: habla de que **nadie lo conoce en este contexto**. Si el archivo tuviera un error de sintaxis, el build entero fallaría.

**"Lo agrego también al `SharedModule` y así lo ve todo el mundo."** Es la reacción natural al `NG0304` y produce el error de doble declaración. Y aunque funcionara, un `SharedModule` que declara componentes de features es la deuda 💸 que la Fase 1 deja puesta y la Fase 5 cobra midiendo el bundle.

**"El CSS lo está ocultando."** Se descarta con el `ng.getComponent()` del paso 4: si el componente no existe, no hay CSS que valga. Si existe, entonces sí conviene mirar el inspector de elementos — y suele ser un `height: 0` heredado del layout.

---

## 🧨 Deshacer

Si provocaste los errores a propósito, todos se revierten en el archivo donde los causaste y `ng serve` recompila solo. El único que deja rastro es `ng build`: borra `dist/` si no quieres que un `stats.json` viejo te confunda en la siguiente investigación — es exactamente la mentira de los source maps desactualizados de `forense-fase-00.md`, con otro archivo.

---

## 🧠 El patrón transferible

> **En Angular, "no se ve" y "no existe" son dos bugs distintos y se distinguen en una línea de consola.** Antes de mirar CSS, rutas o datos, pregunta si el objeto llegó a construirse. La mitad de las investigaciones terminan ahí.

Y el segundo, que vale para cualquier sistema modular: **el error te da el nombre del síntoma, no el del archivo.** El camino selector → componente → módulo son tres `grep` y siempre los mismos tres. Aprenderlo como un reflejo es lo que separa treinta segundos de veinte minutos.

**Incidentes del cuaderno que usan esta ruta:** 02 (la pantalla de activos en blanco) y 07 (el listado que rompe el panel 🧬).
**Amplía:** **A04** para el árbol de inyectores, y `forense-fase-05.md` para cuando el mismo síntoma llega desde un componente standalone.
EOF
wc -l forense-fase-01.md

# --- 2026-09-07T00:40:53 · Write forense-fase-02
cat > forense-fase-02.md <<'EOF'
# 🕵️ Forense Fase 02 — "Entro con mi usuario y me saca al login sin decir nada"

> Pieza forense de la **Fase 2 — Autenticación mínima** · Recorrido: ~30 min
> Herramientas: pestaña Network (Headers) · breakpoints en un interceptor funcional · `localStorage`
> Síntoma que cubre: la sesión se cae sola, o nunca llega a empezar, y no hay ningún mensaje.

Aquí hay tres piezas que pueden echarte —el guard, el interceptor y el servidor— y las tres producen el mismo síntoma en la pantalla del usuario. Distinguirlas cuesta **diez segundos en Network** y decide en cuál de tres sitios opuestos buscar.

La fase resume las dos preguntas; aquí está el recorrido con los mensajes literales.

---

## 🎫 El ticket

> *"Entro con mi correo y mi clave, veo el listado un segundo, y me devuelve a la pantalla de inicio de sesión. No dice nada. A veces entro bien y a la media hora me pasa lo mismo."*

**Reportado por:** inspector de campo
**Ambiente:** UAT

Dos datos que el reporte trae sin saberlo: **"veo el listado un segundo"** —la navegación sí ocurrió— y **"a la media hora"** —hay un patrón temporal, no es aleatorio—.

---

## 🧭 La ruta

### Paso 1 — ¿Guard o interceptor? Lo dice Network, sin abrir el código

DevTools → **Network** → filtro `Fetch/XHR` → *Preserve log* **activado**, que es imprescindible: la redirección al login borra el log si no lo está. Reproduce el ticket.

**Caso A — no hay ninguna petición fallida, y la URL acabó en `/login?returnUrl=%2Ftemplates`:**

```
Name        Status    Type
(ninguna petición en rojo)
```

Fue **el guard**. Ni siquiera se intentó hablar con el servidor: `isAuthenticated()` dijo que no y la navegación se canceló antes de empezar. El problema está del lado del cliente: token ausente, token mal leído, o un `exp` que el navegador interpreta como pasado.

**Caso B — hay una petición en rojo con `401` y después la redirección:**

```
Name         Status    Type    Initiator
templates    401       xhr     zone.js:xxxx
```

Fue **el interceptor**. El token existía y parecía válido desde el navegador; el servidor opinó distinto. El problema está del lado del servidor: firma, secreto o expiración real.

**Qué descarta.** Las dos causas no se parecen en nada y llevan a archivos opuestos. Todo lo que sigue depende de cuál de las dos tienes.

### Paso 2 (caso A) — ¿Qué tiene el navegador guardado?

En la consola, con la pantalla del login abierta:

```js
localStorage.getItem('certcore.accessToken');
// null                    → nunca se guardó, o alguien lo borró
// 'eyJhbGciOi…'           → existe: hay que mirarlo por dentro
```

Y si existe, se abre sin ninguna librería:

```js
const token = localStorage.getItem('certcore.accessToken');
const payload = JSON.parse(atob(token.split('.')[1]));
payload;
// { sub: 'INS-15', email: 'inspector@certcore.co', role: 'inspector', exp: 1742131200 }

// La comparación que hace el guard, con los dos números a la vista:
new Date(payload.exp * 1000).toISOString();   // '2025-03-16T12:00:00.000Z'
new Date().toISOString();                     // '2025-03-16T12:31:04.221Z'  ← ya venció
```

**Qué descarta.** Si `exp` está en el pasado, el guard hizo exactamente lo que debía y el ticket no es un bug: es un TTL corto sin aviso al usuario, que es un problema de producto. Si `exp` está en el futuro y aun así te echa, el bug está en cómo el guard lee o compara ese número — y `exp` va en **segundos**, no en milisegundos, que es el error clásico de un factor de mil.

### Paso 3 (caso B) — ¿Qué cabecera puso quién?

Clic en la petición con `401` → pestaña **Headers** → sección **Request Headers**:

```
Authorization:      Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9…
X-Correlation-Id:   3f2a9c1e-77b4-4a0e-9f21-8d5c6b1e0a44
```

Las dos cabeceras las ponen piezas de generaciones distintas, y eso convierte la pestaña Headers en un diagnóstico de convivencia 🧬:

| Lo que ves | Qué significa |
|---|---|
| Las dos cabeceras | las dos cadenas de interceptores corren. Todo registrado bien |
| Falta `Authorization` | el interceptor **funcional** no corre → falta `withInterceptors([authInterceptor])` |
| Falta `X-Correlation-Id` | el interceptor **de clase** no corre → falta `withInterceptorsFromDi()` |
| No falta ninguna y el 401 sigue | el token viaja y el servidor lo rechaza: es del servidor |

**Qué descarta.** El caso más traicionero es el tercero, porque **no da ningún error**: `provideHttpClient()` sin `withInterceptorsFromDi()` deja de ejecutar los interceptores de clase registrados en `HTTP_INTERCEPTORS` **en silencio**. El `CorrelationIdInterceptor` de 2021 deja de correr, nadie se entera, y la trazabilidad se corta justo donde más falta hace.

### Paso 4 — Dónde va el breakpoint en un interceptor funcional

Un interceptor funcional tiene **dos momentos**, y poner un solo breakpoint esperando ver los dos es la media hora que se pierde la primera vez.

```ts
export const authInterceptor: HttpInterceptorFn = (request, next) => {
  const authService = inject(AuthService);   // ← MOMENTO 1: al lanzar la petición.
  const router = inject(Router);             //   Aquí ves la URL, el token, la request.

  const authorizedRequest = /* … */;

  return next(authorizedRequest).pipe(
    catchError((error: unknown) => {
      // ← MOMENTO 2: al volver la respuesta, milisegundos o segundos después.
      //   Aquí ves el error. `authService` funciona porque quedó capturado en el
      //   closure, NO porque sigamos en contexto de inyección: un inject() aquí
      //   sería NG0203.
      return throwError(() => error);
    }),
  );
};
```

- **Para inspeccionar lo que sale** —URL, token, cabeceras— el breakpoint va **antes del `return`**.
- **Para inspeccionar lo que vuelve** —status, cuerpo del error— va **dentro del `catchError`**.

Y una comprobación que ahorra el breakpoint entero, con `logpoint` en vez de detenerse:

```js
// Logpoint en la primera línea del catchError (clic derecho sobre el número de
// línea → Add logpoint), sin pausar la ejecución:
`401 en ${request.url} | isLogin=${request.url.endsWith('/auth/login')}`
```

Ese `isLogin` es la mitad del bug clásico de esta fase: si el interceptor no distingue el `401` del **login** —que significa "te equivocaste de contraseña"— del `401` de **cualquier otra ruta** —que significa "tu sesión caducó"—, cada intento fallido de inicio de sesión provoca un `logout()` y una redirección a `/login`, desde `/login`. El bucle no da error; la pantalla parpadea y el usuario dice *"no me deja entrar y no dice nada"*.

### Paso 5 — Confirmar contra el servidor, fuera del navegador

Cuando la sospecha es del lado del servidor, `curl` quita al navegador de la ecuación:

```bash
# El login, tal cual:
curl -s -X POST http://localhost:3000/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"inspector@certcore.co","password":"certcore123"}'
# {"accessToken":"eyJhbGciOi…","user":{"id":"INS-15","role":"inspector"}}

# Y una ruta protegida con ese token:
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/templates \
  -H "Authorization: Bearer <pega el token aquí>"
# 200 → el token sirve; el problema es del navegador
# 401 → el token no sirve; el problema es del servidor o del propio token
```

**Qué descarta.** Es la separación limpia entre "mi cliente manda mal el token" y "mi servidor rechaza un token bueno". Sin ella, las dos hipótesis se persiguen la cola durante horas.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Quién te echó | Dónde miras |
|---|---|---|
| `/login?returnUrl=…` sin ninguna petición fallida | el guard | `localStorage` y el `exp` del token |
| Petición `401` y después la redirección | el interceptor | el token que viaja, o el servidor |
| Bucle de parpadeo en `/login` al fallar la contraseña | el interceptor, sin distinguir el login | el `isLoginRequest` |
| Falta `Authorization` en Headers | el interceptor funcional no está registrado | `withInterceptors([...])` |
| Falta `X-Correlation-Id` en Headers 🧬 | el de clase no corre, **en silencio** | `withInterceptorsFromDi()` |
| `NG0203` al reproducir | un `inject()` fuera de contexto | **A04** §7 — casi siempre dentro del `catchError` |
| Entra bien y a los N minutos se cae | TTL del token | el `exp`, y `CHAOS=expired` para reproducirlo a voluntad |

---

## ⚰️ Los callejones

**"El guard está protegiendo mal la ruta."** Casi nunca. Y conviene recordar por qué importa poco: **un guard no es seguridad**. Corre en el navegador, el usuario puede pausarlo con el depurador, y lo único que evita es que alguien vea una pantalla vacía con un error feo. Si el ticket dice "vi datos que no debía ver", el bug **no está en el guard**: está en el servidor, que los devolvió.

**"Es la caché del navegador."** No para esto. Un `401` no se cachea, y la petición aparece en Network con su status cada vez. Este callejón es real en la Fase 13, no aquí.

**"El interceptor se está tragando el error."** Comprobable en una línea: si el componente que llamó recibe el error, el interceptor lo relanzó. Si el componente se queda esperando para siempre y no hay nada en consola, entonces sí — y el culpable es un `catchError` que devuelve `EMPTY` en vez de `throwError`. Es el antipatrón que la fase nombra por su nombre.

---

## 🧨 Deshacer

`CHAOS=expired npm run mock` reproduce el token vencido sin tocar código y se apaga al reiniciar el mock. Si para investigar borraste el token a mano, `localStorage.clear()` y vuelve a entrar. Si comentaste `withInterceptorsFromDi()` en `core.module.ts` para ver el efecto, **devuélvelo**: sin esa línea el `CorrelationIdInterceptor` deja de correr y la Fase 13 te va a echar de menos esa cabecera en los logs de nginx.

---

## 🧠 El patrón transferible

> **Cuando tres piezas producen el mismo síntoma, la primera pregunta no es "¿cuál falló?" sino "¿qué evidencia distingue a una de otra?".** Aquí es una sola: si hubo o no una petición fallida. Diez segundos en Network, y el espacio de búsqueda se reduce a un tercio.

Y el segundo, que es propio de este track: **una cadena de interceptores que deja de correr no da ningún error.** Las dos mitades de `provideHttpClient()` registran dos generaciones distintas, y quitar una apaga la mitad del sistema en silencio. La pestaña Request Headers es el único sitio donde eso se ve. 🧬

**Incidentes del cuaderno que usan esta ruta:** 03 (la sesión que se cae sin decir nada).
**Amplía:** **A04** §4 y §7 para `inject()` en interceptores y el `NG0203`, **A06** §6 para qué devolver desde un `catchError`.
EOF
wc -l forense-fase-02.md

# --- 2026-09-07T00:41:58 · Write forense-fase-03
cat > forense-fase-03.md <<'EOF'
# 🕵️ Forense Fase 03 — "A veces carga y a veces se queda pensando"

> Pieza forense de la **Fase 3 — Mock API y caos** · Recorrido: ~40 min
> Herramientas: pestaña Network (Timing, Response, Status) · consola · logs del mock
> Síntoma que cubre: fallos intermitentes, y los seis que este proyecto puede producir a voluntad.

Ésta es la pieza que más se consulta durante el cuaderno de incidentes, porque casi todos los fallos intermitentes del curso son uno de estos seis. El objetivo no es memorizar la tabla: es **saber qué mirar primero** para que la tabla conteste sola.

La fase resume los seis y dice cuál miente. Aquí está el árbol de decisión completo, con la salida literal de cada uno.

---

## 🎫 El ticket

> *"La pantalla de plantillas a veces carga y a veces se queda pensando. Y una vez me salió un mensaje raro de que la respuesta no tenía la forma esperada, pero no lo pude repetir."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

El ticket describe **dos fallos distintos** y quien lo escribió cree que es uno. Eso es lo normal, y separarlos es el primer trabajo.

---

## 🧭 El árbol de decisión

Una sola pregunta al principio, y de ahí salen tres ramas. **Empieza siempre por el status**, porque cuesta un vistazo y parte el problema en tres.

```
¿Qué dice la columna Status de Network?

├─ (failed), sin número ......................... rama A — nadie contestó
├─ pending, para siempre ........................ rama B — contestaron a medias
└─ un número (200, 401, 500) .................... rama C — sí contestaron
```

### Rama A — `(failed)`, sin status

```
Name        Status      Type    Initiator          Size    Time
templates   (failed)    xhr     zone.js:xxxx       0 B     3 ms
```

Y en la consola:

```
Access to XMLHttpRequest at 'http://localhost:3000/templates' from origin
'http://localhost:4200' has been blocked by CORS policy: No 'Access-Control-Allow-Origin'
header is present on the requested resource.
```

**Lo que tu código recibe**, que es la parte importante:

```js
// El HttpErrorResponse que llega al catchError:
error.status;         // 0     ← no es 403, no es 404: es CERO
error.statusText;     // 'Unknown Error'
error.url;            // 'http://localhost:3000/templates'
```

> ⚠️ **`status: 0` es indistinguible desde el código de tres situaciones distintas:** CORS bloqueado, servidor caído, y red ausente. La información que las separa **sólo existe en la consola del navegador**, y tu código no puede leerla. Por eso el mensaje que `toApiError` produce menciona las tres posibilidades en vez de adivinar una: adivinar mandaría a quien lee el ticket a mirar el sitio equivocado dos de cada tres veces.

Cómo se separan a mano, en diez segundos:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/templates
# 200 → el servidor está vivo: era CORS (curl no aplica la política del navegador)
# 000 → no hay nadie en ese puerto: el servidor está caído o el puerto es otro
```

**Reproducir a voluntad:** `CHAOS=cors npm run mock`.

### Rama B — `pending` para siempre

```
Name        Status      Type    Size        Time
templates   pending     xhr     0 B         (contando)
```

No hay error. No hay nada en consola. El spinner gira. Es el fallo **más silencioso** de los seis y el que peor tolera un usuario, porque no puede ni reintentar.

**Lo que tu código recibe:** nada. El observable no emite, no falla y no completa. Si la pantalla no tiene tiempo límite, se queda así hasta que alguien recargue.

**Reproducir a voluntad:** `CHAOS=timeout npm run mock`.

> 💡 **La lección de diseño que sale de aquí:** un `catchError` no te protege de esto, porque nunca hay error que capturar. Lo único que protege es un `timeout(ms)` explícito en el flujo, y decidir cuántos milisegundos es una decisión de producto que casi nadie toma hasta que le pasa esto.

### Rama C — sí contestaron: el status manda

**`500`, y sólo a veces:**

```
Name        Status    Type
templates   500       xhr
templates   200       xhr
templates   500       xhr
templates   200       xhr
```

Recarga cinco veces y cuenta. Si los fallos se alternan sin patrón, es un fallo probabilístico. `CHAOS=error npm run mock` lo produce con probabilidad `CHAOS_RATE` (0.3 por defecto), y `CHAOS_RATE=1` lo hace determinista para poder investigar sin luchar contra el azar — que es el primer movimiento de cualquier investigación de intermitentes.

**`200` verde, y la pantalla dice que el dato no tiene la forma esperada:**

```
Name        Status    Type    Size
templates   200       xhr     87 B
```

```json
// Network → Response. Esperabas un array y llegó esto:
{ "data": [], "meta": { "note": "chaos" } }
```

**Éste es el que miente**, y por eso tiene su propio párrafo. Los otros cinco se anuncian: hay algo rojo, hay un status raro, hay algo que mirar. `malformed` devuelve `200` con el cuerpo cambiado, así que **la pestaña Network te dice que todo salió bien**. Si te fías del semáforo verde, te pasas media hora leyendo tu componente buscando un bug que está en el borde HTTP.

Lo que lo caza en un segundo, y por eso los `*ApiService` de la fase lo llevan puesto:

```ts
// En TemplateApiService.getAll(), antes de devolver nada.
map((response: unknown) => {
  if (!Array.isArray(response)) {
    // El mensaje nombra la FORMA, no la red: es lo que hace que el ticket
    // llegue con la palabra correcta y no como "a veces no carga".
    throw new ApiError('El servidor devolvió algo que no es una lista de plantillas.');
  }
  return response;
});
```

**Reproducir a voluntad:** `CHAOS=malformed CHAOS_RATE=1 npm run mock`.

**Todo va lento pero funciona:**

Network → clic en la petición → pestaña **Timing**:

```
Queueing              0.4 ms
Stalled               0.9 ms
Request sent          0.1 ms
Waiting (TTFB)     2503.7 ms     ← aquí está
Content Download      1.2 ms
```

**`Waiting (TTFB)` alto con el resto normal es el servidor pensando**, no la red ni el navegador. Si el que estuviera alto fuera `Content Download`, sería un cuerpo enorme; si fuera `Stalled`, sería el límite de conexiones simultáneas del navegador. Los tres se ven distintos y llevan a sitios distintos.

**Reproducir a voluntad:** `CHAOS=latency npm run mock`, con `CHAOS_DELAY_MS` para ajustar.

**Entra y te devuelve al login de inmediato:**

Es `expired`, y su ruta completa está en `forense-fase-02.md`, paso 2. Aquí sólo la forma de provocarlo: `CHAOS=expired npm run mock`.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Fallo | Cómo lo confirmas | Flag |
|---|---|---|---|
| Todo lento pero funciona | latencia | Timing → `Waiting (TTFB)` alto, el resto normal | `latency` |
| Falla una de cada tres recargas, `500` | error intermitente | recarga cinco veces; se alternan | `error` |
| `200` verde y la forma no es la esperada | respuesta malformada | Response: objeto donde esperabas array | `malformed` |
| `(failed)` sin status, consola con `Access-Control-Allow-Origin` | CORS | `error.status === 0` | `cors` |
| Te devuelve al login de inmediato | token vencido | decodifica el token: `exp` en el pasado | `expired` |
| Spinner eterno, `pending` para siempre | sin respuesta | no hay error que capturar | `timeout` |

Y las combinaciones, que es donde esto se parece de verdad a producción:

```bash
CHAOS=latency,error CHAOS_RATE=0.5 npm run mock
```

---

## ⚰️ Los callejones

**"Es mi componente."** El callejón número uno, y `malformed` es quien te mete en él. La regla que lo evita: **antes de leer una línea de tu componente, mira el cuerpo crudo de la respuesta.** Si el cuerpo no es lo que tu tipo dice, el bug está en el borde HTTP, y tu componente está haciendo lo correcto con un dato equivocado.

**"Es un `403`, no tengo permiso."** Un fallo de CORS **no es un `403`**. Un `403` es una respuesta del servidor: llegó, se leyó, y dijo que no. CORS es el navegador negándose a entregarte una respuesta que quizá llegó perfectamente. La diferencia es total y el `status: 0` es la pista.

**"Se cayó la red."** Puede ser, y por eso el mensaje de `toApiError` no lo afirma. Pero antes de aceptarlo, el `curl` del paso A: si `curl` contesta `200`, la red está bien y el problema es del navegador, que es un sitio completamente distinto donde buscar.

**"El azar no me deja investigar."** No es un callejón, es una técnica que falta: `CHAOS_RATE=1` convierte un intermitente en un determinista, y **ése es siempre el primer movimiento**. Un bug que ocurre una de cada tres veces no se investiga: se hace ocurrir siempre, y entonces se investiga.

---

## 🧨 Deshacer

Todos los fallos de esta pieza se apagan **reiniciando el mock sin el flag**: `npm run mock`. Es la razón por la que el inyector de caos es la forma de preparación preferida del cuaderno de incidentes — no toca tu código, no toca tus datos, y no deja rastro.

Si durante la investigación creaste o modificaste datos, `npm run seed` devuelve el `db.json` a la semilla.

---

## 🧠 El patrón transferible

> **Empieza siempre por el status, y sólo después por el cuerpo.** El status parte el problema en tres ramas que no se parecen en nada: nadie contestó, contestaron a medias, o contestaron. Cada rama tiene sus sospechosos y ninguno se solapa.

Y el segundo, que es el que más se olvida: **un `200` no es una garantía de nada más que de que el servidor respondió.** El semáforo verde de Network es una afirmación sobre el transporte, no sobre el contenido. El único sitio donde se comprueba el contenido es el borde HTTP de tu aplicación, y si no lo compruebas ahí, el dato malformado entra al sistema y explota tres capas más allá, dentro de un `*ngFor`, sin ninguna pista de dónde vino.

**Incidentes del cuaderno que usan esta ruta:** 04 (la pantalla que a veces carga) y, como herramienta de preparación, prácticamente todos los intermitentes de la semana 4.
**Amplía:** **A06** §6 para qué devolver desde un `catchError`, y `forense-fase-13.md` para cuando el mismo síntoma llega desde un contenedor y no desde el mock.
EOF
wc -l forense-fase-03.md

# --- 2026-09-07T00:43:09 · Write forense-fase-04
cat > forense-fase-04.md <<'EOF'
# 🕵️ Forense Fase 04 — "La lista se actualizó dos veces"

> Pieza forense de la **Fase 4 — Estado con servicios y `BehaviorSubject`** · Recorrido: ~40 min
> Herramientas: `console.count` · DevTools → Memory (heap snapshot) · Network en reposo
> Síntoma que cubre: algo ocurre más veces de las que debería, o la pestaña se va poniendo lenta con las horas.

Una fuga de suscripción no se ve. Lo que se ve son sus consecuencias, y son dos muy distintas: **un efecto que se repite** —fácil de cazar, gratis— y **una pestaña que se degrada** —más difícil, y ahí sí hace falta el perfilador—. Esta pieza recorre las dos, en ese orden, porque la primera resuelve el 80% de los casos sin abrir ninguna herramienta pesada.

La fase construye el componente con fuga y lo cierra de cuatro formas. Aquí está cómo se **encuentra** una que no sabías que tenías.

---

## 🎫 El ticket

> *"Cuando guardo una plantilla me sale el mensaje de confirmación dos veces, a veces tres. Y si dejo la pestaña abierta toda la mañana, el navegador se pone lento."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

Dos síntomas otra vez, y aquí sí son **la misma causa** vista de dos maneras. Que el reporte los junte es, por una vez, correcto.

---

## 🧭 La ruta

Cuatro pasos, del más barato al más caro. El paso 1 cuesta una línea y un minuto; el paso 4 cuesta diez minutos y un snapshot. La mayoría de las investigaciones terminan en el paso 2.

### Paso 1 — ¿Se repite un efecto? Cuéntalo

No hace falta ninguna herramienta. Un contador en el sitio donde ocurre el efecto:

```ts
// Temporal, en la suscripción sospechosa.
this.templateState.templates$.subscribe((templates) => {
  console.count('TemplateList recibió');
  // …lo que hacía…
});
```

Entra a la pantalla, sal, vuelve a entrar. Cinco veces. En la sexta, provoca **una** emisión —guardar, recargar la lista, lo que dispare un `load()`—:

```
TemplateList recibió: 1
TemplateList recibió: 2
TemplateList recibió: 3
TemplateList recibió: 4
TemplateList recibió: 5
TemplateList recibió: 6
```

**Qué descarta.** Una emisión, seis recepciones. Hay **seis componentes vivos** y cinco de ellos ya no están en pantalla. Eso es una fuga, confirmada, sin abrir DevTools más allá de la consola. Si el contador dice `1`, no hay fuga en **esta** suscripción y hay que buscar en otra.

> 🧠 **El número es información, no sólo un sí o un no.** El contador dice exactamente cuántas instancias zombis hay, y eso se corresponde con cuántas veces navegaste. Si navegaste cinco veces y el contador dice seis, cada navegación deja una: la fuga está en el ciclo de vida del componente. Si dice tres tras cinco navegaciones, algo se está limpiando a veces — y eso es un bug distinto y más interesante.

### Paso 2 — ¿Qué suscripción es? La que no completa

No todas las suscripciones pueden fugarse. La pregunta que reduce la búsqueda a un par de líneas:

| La fuente | ¿Completa? | ¿Puede fugarse? |
|---|---|---|
| `this.http.get(...)` | sí, al llegar la respuesta | **no** |
| `state$` de un `*StateService` raíz | **nunca** | **sí** |
| `form.valueChanges` | nunca | **sí**, aunque muere con el formulario |
| `route.paramMap` | nunca | **sí** |
| un `async` pipe en la plantilla | — | **no**: se desuscribe con la vista |

```bash
# Busca sólo lo que puede fugarse: subscribe manuales sobre fuentes que no completan.
grep -rn "\.subscribe(" src/app --include="*.ts" | grep -v "spec.ts"
```

**Qué descarta.** Un `subscribe` sobre `HttpClient` no es sospechoso aunque no tenga desuscripción: el observable completa solo. Un `subscribe` sobre `state$` sin `takeUntilDestroyed`, `takeUntil` ni `unsubscribe` **es la fuga**, y normalmente hay una sola en toda la pantalla.

Y el caso que parece una fuga y no lo es, que conviene reconocer para no "arreglarlo":

```ts
// TemplateStateService, constructor. Nadie se desuscribe, y es CORRECTO:
// los dos servicios son providedIn: 'root' y viven lo que la aplicación.
// Una fuga es una suscripción que sobrevive a su dueño; ésta no tiene a
// quién sobrevivir.
this.authService.currentUser$
  .pipe(filter((user) => user === null))
  .subscribe(() => this.reset());
```

### Paso 3 — Cuando el efecto no es visible: Network en reposo

Hay fugas que no cuentan nada porque su efecto no se ve. Si la suscripción dispara peticiones, se cazan sin tocar el código:

DevTools → **Network** → filtro `Fetch/XHR` → **sal de la pantalla** → espera dos minutos sin tocar nada.

```
Name          Status    Type    Time
certificates  200       xhr     14 ms
certificates  200       xhr     11 ms
certificates  200       xhr     13 ms
```

**Qué descarta.** Si sigue saliendo tráfico de una pantalla que ya no está abierta, hay una suscripción viva. Y el **ritmo** te dice cuántas: si el intervalo original era de un minuto y ves tres peticiones por minuto, hay tres zombis.

Es la misma técnica que abre la investigación del panel en `forense-fase-11.md`, y es el sospechoso número uno de "el panel va lento".

### Paso 4 — Y sólo ahora: el panel Memory

Cuando el síntoma es *"se va poniendo lenta con las horas"* y no hay ningún contador que mirar ni ninguna petición que contar, toca el perfilador. Cuesta diez minutos y es la última opción, no la primera.

DevTools → **Memory** → *Heap snapshot* → **Take snapshot** (éste es el "antes").
Navega a la pantalla sospechosa y sal, **diez veces**.
**Take snapshot** otra vez (el "después").

En el segundo snapshot, en el filtro de clase escribe el nombre del componente:

```
Constructor                  Distance   Shallow Size   Retained Size
TemplateListComponent × 10       6            720          14 328
```

**× 10 es el diagnóstico entero.** Diez instancias vivas de un componente que debería tener cero, porque saliste de la pantalla diez veces.

**Cómo se sigue la cadena de retención**, que es la parte que casi nadie hace:

1. Despliega la clase y selecciona **una** de las instancias.
2. Abajo aparece el panel **Retainers** (en algunas versiones, *Object* → la ruta con `in`).
3. Léelo **de abajo hacia arriba**: la última fila es la raíz que lo mantiene vivo.

```
TemplateListComponent
  └── in destination of Subscriber          ← quién lo sostiene
      └── in _subscriptions of Subscriber
          └── in observers of BehaviorSubject
              └── in stateSubject of TemplateStateService
                  └── in _providers of R3Injector (root)          ← la raíz
```

Esa cadena se lee como una frase: **el inyector raíz mantiene vivo al servicio, el servicio a su `BehaviorSubject`, el sujeto a la lista de observadores, y ahí dentro está tu componente destruido.** Ése es el mecanismo exacto de una fuga de suscripción, y verlo una vez vale más que leerlo cinco.

**Qué descarta.** Si el componente **no** aparece en el snapshot, no hay fuga de componentes — y entonces lo que crece es otra cosa: un array que nadie vacía, una caché sin límite, o un `shareReplay` sin `refCount` reteniendo valores. Es el mismo panel y otro filtro.

> ⚠️ **Antes de creerte un snapshot, fuerza la recolección.** DevTools ejecuta un ciclo de recolección de basura al tomar el snapshot, pero si algo está vivo sólo porque el depurador lo tiene referenciado, el resultado miente. Cierra las pausas del depurador y no dejes variables en la consola apuntando a componentes.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa probable | Herramienta, por este orden |
|---|---|---|
| Un mensaje o una acción se repite N veces | N suscripciones vivas | `console.count` — paso 1 |
| Peticiones a una pantalla que ya cerraste | suscripción con efecto de red | Network en reposo — paso 3 |
| La pestaña se degrada con las horas, sin nada visible | fuga sin efecto observable | panel Memory — paso 4 |
| El derivado se recalcula muchas veces | falta `shareReplay` o `distinctUntilChanged` | `console.count` dentro del `map` |
| La memoria crece y el componente **no** aparece | no es fuga de componentes | filtra por arrays y cachés en el snapshot |
| Al volver a una pantalla ves datos viejos un instante | **no es un bug** | es tener estado: `providedIn: 'root'` — **A07** §3 |

---

## ⚰️ Los callejones

**"Toda suscripción sin cerrar es una fuga."** Falso, y creérselo lleva a llenar el proyecto de `takeUntilDestroyed` que no hacen nada. Una fuga es una suscripción que **sobrevive a quien la creó**. Un `subscribe` a `HttpClient` completa; un servicio raíz suscrito a otro servicio raíz no tiene a quién sobrevivir. El paso 2 tiene la tabla.

**"Es que Angular no libera la memoria."** La libera. Lo que no puede liberar es un objeto al que alguien sigue apuntando, y en el paso 4 se ve exactamente quién apunta. La cadena de retención no admite discusión.

**"Le pongo `OnPush` y se arregla."** Son problemas distintos. `OnPush` decide **cuándo se revisa** un componente; una fuga es un componente que **ya no existe** y sigue recibiendo. Un componente destruido con `OnPush` sigue fugado exactamente igual.

**"Los datos viejos que aparecen un segundo al volver son la fuga."** No: eso es un `BehaviorSubject` haciendo su trabajo. Guarda el último valor y se lo da a quien se suscriba, incluido el componente nuevo. Se puede evitar con un `reset()` al entrar y casi nunca conviene: un parpadeo de datos viejos molesta menos que un parpadeo de pantalla vacía.

---

## 🧨 Deshacer

Quita los `console.count` temporales antes de commitear — un contador olvidado en producción es ruido en la consola de todo el mundo. Si montaste el `TemplateCounterComponent` con fuga que construye la fase, **no lo dejes en el árbol de rutas**: está roto a propósito y su sitio es el ejercicio, no la aplicación.

Los snapshots del panel Memory viven en la sesión de DevTools y desaparecen al cerrarla; no dejan nada en el proyecto.

---

## 🧠 El patrón transferible

> **Cuenta antes de perfilar.** Un `console.count` bien puesto cuesta una línea y contesta la pregunta en un minuto; un heap snapshot cuesta diez minutos y contesta la misma pregunta. El perfilador es para cuando el efecto **no se puede contar**, no para empezar.

Y el segundo, que vale para cualquier stack con suscripciones, oyentes o *callbacks*: **la pregunta no es "¿cerré esto?" sino "¿esto puede sobrevivirme?"**. Una fuente que completa no se puede fugar por mucho que la ignores; una que no completa se fuga aunque tengas las mejores intenciones. Saber cuál es cuál convierte una revisión de código de una hora en una de cinco minutos.

**Incidentes del cuaderno que usan esta ruta:** 05 (el estado que devuelve siempre lo mismo) y 16 (el panel cerrado que sigue pidiendo).
**Amplía:** **A07** §7 para el ciclo de vida completo de una suscripción, **A06** §7 y §8 para `shareReplay` y las tres formas de desuscribirse 🧬.
EOF
wc -l forense-fase-04.md; ls forense*

# --- 2026-09-07T00:54:23 · Locate reservation rows to edit
grep -n '| 06 \|| 07 ' 05-standalone-convivencia.md; grep -n '| 10 ' 08-formulario-dinamico.md; grep -n '| 13 ' 09-hallazgos-severidad.md; echo "--- contexto tabla fase 5 ---"; awk '/^### Reservas para el cuaderno/,0' 05-standalone-convivencia.md

# --- 2026-09-07T00:54:31 · Apply recategorization to phase reservations
sed -i '' '776s/| UI |/| Convivencia de estilos 🧬 |/' 05-standalone-convivencia.md
sed -i '' '777s/| Integración |/| Convivencia de estilos 🧬 |/' 05-standalone-convivencia.md
sed -i '' '1247s/| Formularios dinámicos |/| Versionado normativo |/' 08-formulario-dinamico.md
sed -i '' '1327s/| Trazabilidad |/| Tipos (strict) |/' 09-hallazgos-severidad.md
for f in 05-standalone-convivencia.md 08-formulario-dinamico.md 09-hallazgos-severidad.md; do echo "=== $f ==="; awk '/^### Reservas para el cuaderno/,0' $f | grep -E '^\| [0-9]'; done

# --- 2026-09-07T00:54:40 · Find versioning quota statements
grep -n 'cuatro incidentes son de versionado\|cuatro son de versionado\|Al menos cuatro' prompts/formato-cuaderno-incidentes.md prompts/propuesta-fases-y-alcance.md

# --- 2026-09-07T00:54:51 · Amend versioning quota in both specs
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import re, pathlib

f = pathlib.Path('prompts/formato-cuaderno-incidentes.md')
t = f.read_text()
old = """1. **Al menos cuatro incidentes son de versionado de plantillas.** Es el corazón
   del sistema y la fuente real de tickets. Ninguno de los cuatro se resuelve
   leyendo el mismo archivo que el anterior."""
new = """1. **Al menos tres incidentes son de versionado de plantillas.** Es el corazón
   del sistema y la fuente real de tickets, y **ninguno de los tres se resuelve
   leyendo el mismo archivo que el anterior**: uno vive en la resolución por
   fecha, otro en las ventanas de vigencia, y el tercero en el formulario que se
   construye con la versión equivocada.

   > 📝 **Por qué tres y no cuatro, que es lo que decía este documento.** Al
   > cerrar las catorce fases, las reservas dieron 08 y 09 (Fase 7) y 10
   > (Fase 8): tres incidentes con tres causas raíz distintas. El cuarto sólo se
   > conseguía forzando la causa raíz de un incidente cuya fase ya la había
   > fijado en otra cosa —el PDF de la Fase 10 se arma desde la vista, no desde
   > la versión equivocada—, y un incidente con la categoría torcida enseña peor
   > que uno menos. La cifra se bajó a tres el día que se escribió el cuaderno."""
assert old in t
f.write_text(t.replace(old, new))

f2 = pathlib.Path('prompts/propuesta-fases-y-alcance.md')
t2 = f2.read_text()
old2 = "**Al menos cuatro incidentes son de versionado de plantillas**, que es el corazón"
new2 = "**Al menos tres incidentes son de versionado de plantillas** (08, 09 y 10), que es el corazón"
assert old2 in t2
f2.write_text(t2.replace(old2, new2))
print("ok")
PY
sed -n '305,320p' prompts/propuesta-fases-y-alcance.md

# --- 2026-09-07T00:55:02 · Sync categories list in propuesta
python3 - <<'PY'
import pathlib
f = pathlib.Path('prompts/propuesta-fases-y-alcance.md')
t = f.read_text()
t = t.replace(
"**Al menos tres incidentes son de versionado de plantillas** (08, 09 y 10), que es el corazón\ndel sistema, y al menos dos son de convivencia standalone/NgModule, que es lo que\ndistingue a este track.",
"**Al menos tres incidentes son de versionado de plantillas** (08, 09 y 10), que es\nel corazón del sistema, y al menos dos son de convivencia standalone/NgModule\n(06 y 07), que es lo que distingue a este track. Dos más son de tipos bajo\n`strict` (12 y 13), que es la categoría que sólo existe porque el proyecto lo\ntiene puesto.")
t = t.replace(
"**Categorías:** máquina de estados · versionado normativo · tiempo ·\ntrazabilidad · formularios dinámicos · estado (servicios) · integración ·\nperformance · UI · tipos (strict) · despliegue · testing.",
"**Categorías:** máquina de estados · versionado normativo · tiempo ·\ntrazabilidad · formularios dinámicos · estado (servicios) · **convivencia de\nestilos 🧬** · tipos (strict) · integración · performance · UI · despliegue ·\ntesting.")
f.write_text(t)
print("ok")
PY
sed -n '308,320p' prompts/propuesta-fases-y-alcance.md

# --- 2026-09-07T00:55:10 · Verify category tally
for f in 0[0-9]-*.md 1[0-4]-*.md; do case $f in 00-convencion*|00-historia*) continue;; esac; awk '/^### Reservas para el cuaderno/,0' "$f" | grep -E '^\| *[0-9]+ *\|' | sed "s|^|${f%%-*}\t|"; done | awk -F'|' '{print $4}' | sed 's/^ *//;s/ *$//' | sort | uniq -c | sort -rn

# --- 2026-09-07T01:00:36 · Check validator and token names
grep -n 'existsByTaxId\|uniqueTaxIdValidator\|taxIdTaken\|CLIENT_LIST_PAGE_SIZE' 06-clientes-activos.md | head -12; echo "=== token ==="; grep -n 'InjectionToken' 06-clientes-activos.md 05-standalone-convivencia.md | head

# --- 2026-09-07T01:01:42 · Write forense-fase-05
cat > forense-fase-05.md <<'EOF'
# 🕵️ Forense Fase 05 — "No hay proveedor para… ¿y ahora dónde busco?" 🧬

> Pieza forense de la **Fase 5 — Standalone conviviendo con NgModules** · Recorrido: ~35 min
> Herramientas: el mensaje de `NullInjectorError` · `ng build --configuration production`
> Síntoma que cubre: la pantalla no se monta y el error dice que falta un proveedor. En un repositorio con dos generaciones, ese mensaje se lee de dos maneras y llevan a sitios opuestos.

Ésta es la pieza más propia del track, porque el error es idéntico en las dos generaciones **salvo por lo que hay entre paréntesis**, y ese paréntesis decide si vas a buscar en diez archivos o en dos.

La fase enseña a distinguir los dos mensajes. Aquí está el recorrido completo, incluido lo que queda de ellos en un build de producción minificado — que es donde de verdad los vas a leer.

---

## 🎫 El ticket

> *"Metí el listado de clientes en el panel principal, como me dijiste, y la pantalla se queda en blanco. En la consola sale algo de un inyector. A mí me funciona si entro por el menú de Clientes."*

**Reportado por:** un compañero del equipo
**Ambiente:** desarrollo

El dato que decide todo está en la última frase: **por una ruta funciona y por otra no**. Eso, en un componente standalone, tiene una sola familia de causas.

---

## 🧭 La ruta

### Paso 1 — Lee el paréntesis, no el stack

El mensaje completo, tal como sale en desarrollo. Los dos casos, uno al lado del otro:

```
ERROR NullInjectorError: R3InjectorError(AppModule)[HttpClient -> HttpClient]:
  NullInjectorError: No provider for HttpClient!
```

```
ERROR NullInjectorError: R3InjectorError(Standalone[ClientListComponent])[InjectionToken CLIENT_LIST_PAGE_SIZE -> InjectionToken CLIENT_LIST_PAGE_SIZE]:
  NullInjectorError: No provider for InjectionToken CLIENT_LIST_PAGE_SIZE!
```

**Qué descarta.** El paréntesis es el diagnóstico entero:

| Lo que dice el paréntesis | Qué inyector falló | Dónde buscas | Cuántos archivos |
|---|---|---|---|
| `AppModule`, `CoreModule`, cualquier `…Module` | el árbol de módulos | los `providers` y los `imports` de los `.module.ts` | ~10 |
| `Standalone[NombreComponente]` | el inyector del propio componente | el `imports` de su decorador y los `providers` de **la ruta que lo montó** | 2 |
| `EnvironmentInjector` | el inyector raíz | nadie lo provee en ninguna parte del arranque | 1 |

Y el corchete siguiente, `[X -> Y]`, es la **cadena de resolución**: se lee de izquierda a derecha y dice quién pidió qué. Con `[ClientApiService -> HttpClient]` sabes que el que falló no es el servicio, sino algo que el servicio necesitaba — y eso cambia el archivo que vas a abrir.

### Paso 2 — Si dice `Standalone[…]`: la pregunta no es "qué falta" sino "por qué ruta llegó"

Ésta es la parte que no se parece en nada al caso heredado. Un componente standalone resuelve sus dependencias en su propio inyector y en el de **la ruta que lo activó**. La misma clase, montada desde dos sitios, tiene dos inyectores distintos.

```ts
// La ruta de clientes SÍ provee el token.
{
  path: 'clients',
  loadComponent: () => import('./client-list.component').then((m) => m.ClientListComponent),
  providers: [{ provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 }],
}
```

```html
<!-- El panel monta el MISMO componente, y aquí no hay ninguna ruta que provea nada. -->
<cc-client-list></cc-client-list>
```

**Ésa es la causa del ticket**, y explica por qué "por el menú funciona": por el menú se pasa por la ruta que trae el provider; embebido en el panel, no.

```bash
# La comprobación, y son dos grep:
grep -rn "CLIENT_LIST_PAGE_SIZE" src/app --include="*.ts"
# …token.ts:8:  export const CLIENT_LIST_PAGE_SIZE = new InjectionToken<number>('CLIENT_LIST_PAGE_SIZE');
# …clients.routes.ts:14:  providers: [{ provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 }],
# …client-list.component.ts:31:  readonly pageSize = inject(CLIENT_LIST_PAGE_SIZE);
```

Un solo sitio que lo provee, y no está en el camino del panel. Diagnóstico cerrado sin abrir un archivo entero.

**Las tres formas de arreglarlo, y cuál elegir:**

| Arreglo | Cuándo |
|---|---|
| Añadir el provider también en la ruta del panel | si el panel necesita **otro** tamaño de página. Es la respuesta correcta cuando el valor es de la pantalla |
| Darle al token un valor por defecto: `new InjectionToken<number>('CLIENT_LIST_PAGE_SIZE', { providedIn: 'root', factory: () => 25 })` | si el token tiene un valor razonable siempre. **Es el arreglo del ticket**: un componente reutilizable no puede exigir que cada sitio que lo monte sepa configurarlo |
| `inject(CLIENT_LIST_PAGE_SIZE, { optional: true }) ?? 25` | si de verdad puede no estar. Con `strict`, el tipo pasa a `number \| null` y te obliga a decidir el valor por defecto en el sitio |

> 🧭 **La regla que sale de aquí, y que la Fase 5 fija para todo el curso: un componente standalone que exige un provider de ruta no es reutilizable, es una trampa.** Funciona por el camino que su autor probó y explota por cualquier otro, y el error no dice "te falta un provider en la ruta": dice "no hay proveedor", que suena a un problema del componente.

### Paso 3 — Si dice `…Module`: la búsqueda de siempre

Aquí el mecanismo es el heredado y el camino también:

```bash
# ¿Quién debería proveerlo?
grep -rn "provideHttpClient\|HttpClientModule" src/app --include="*.ts"

# ¿Y el módulo que aparece en el paréntesis lo importa?
grep -n "imports" src/app/core/core.module.ts
```

El caso típico de este proyecto: alguien quitó `provideHttpClient(...)` de los `providers` de `CoreModule` —donde lo dejó la Fase 2— y todo lo que pide `HttpClient` deja de resolverse. Como `CoreModule` sólo se importa en `AppModule`, el paréntesis dice `AppModule`.

### Paso 4 — Y ahora en producción, que es donde de verdad los vas a leer

Construye y sirve el `dist/`:

```bash
ng build --configuration production
npx http-server dist/certcore -p 8081
```

El mismo fallo, en producción:

```
ERROR Error: NG0201: No provider found for `t`. Find more at https://angular.io/errors/NG0201
```

**Compáralo con el de desarrollo y mira lo que se perdió:** el paréntesis con el inyector, la cadena de resolución, y el nombre. `t` es lo que quedó de `ClientApiService` después del minificador. **El mensaje de producción no te dice ni qué falta ni dónde buscar.**

Y aquí está el hallazgo práctico de toda esta pieza:

```ts
// El nombre de la CONSTANTE se minifica. La CADENA que le pasas al
// InjectionToken, no: es un literal y sobrevive al build de producción.
export const CLIENT_LIST_PAGE_SIZE = new InjectionToken<number>('CLIENT_LIST_PAGE_SIZE');
```

```
// Por eso, en producción, un token con descripción sigue diciendo su nombre:
ERROR Error: NG0201: No provider found for `InjectionToken CLIENT_LIST_PAGE_SIZE`. …
```

> 💡 **La descripción de un `InjectionToken` no es documentación: es la única pista que te va a quedar en producción.** Cuesta escribir la misma palabra dos veces y es la diferencia entre un ticket de diez minutos y uno de dos días. Un token creado como `new InjectionToken<number>('')` está tirando esa pista a la basura.

Y para los servicios, cuyo nombre sí se minifica, la herramienta es la de siempre: los source maps con `sourceMap.hidden: true` de la **Fase 13**. Sin ellos, `t` es todo lo que vas a tener.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Qué inyector | Dónde miras |
|---|---|---|
| `R3InjectorError(AppModule)[…]` | árbol de módulos | `providers` / `imports` de los `.module.ts` |
| `R3InjectorError(Standalone[X])[…]` 🧬 | el del componente | `imports` del decorador y `providers` de la ruta que lo montó |
| `R3InjectorError(EnvironmentInjector)[…]` | el raíz | el arranque: nadie lo provee en ninguna parte |
| `[A -> B]`: falla `B`, no `A` | — | abre el archivo de `A` y busca qué pide |
| Funciona por una ruta y no por otra 🧬 | provider de ruta | es el caso del ticket: paso 2 |
| `NG0201: No provider found for \`t\`` | producción minificada | source maps, o la descripción del token |
| `NG0203` en vez de `NG0201` | **no es esto** | `inject()` fuera de contexto — **A04** §7 |

---

## ⚰️ Los callejones

**"Le añado el import al `SharedModule` y listo."** No aplica: un componente standalone **no ve** lo que declara o exporta un `NgModule` a menos que lo importe él mismo. Es exactamente el cambio de modelo que la Fase 5 enseña, y el reflejo heredado manda a buscar en el archivo equivocado.

**"Falta importar el módulo de Material."** Ése es otro error y tiene otro texto: `NG0304: 'mat-form-field' is not a known element` o `NG0303: Can't bind to 'matInput'`. Un `NullInjectorError` **nunca** es un problema de plantilla: es un problema de inyección. Si lo que no aparece es un componente, mira `forense-fase-01.md`.

**"El servicio no tiene `providedIn: 'root'`."** Comprobable en cinco segundos, y cuando es cierto el error es distinto: el paréntesis dice `EnvironmentInjector` y no `Standalone[…]`, porque nadie lo provee en ningún sitio en vez de "no en este camino".

**"Es un problema de orden de imports."** Casi nunca en Angular 16. El orden importa para los interceptores registrados con `provideHttpClient()` —eso sí, y es `forense-fase-02.md`— pero no para resolver un token.

---

## 🧨 Deshacer

Si quitaste `provideHttpClient(...)` de `CoreModule` para provocar el primer error, **devuélvelo**: sin esa línea deja de funcionar todo lo que hable con el mock, y el síntoma que produce en la Fase 6 no se parece en nada a éste.

El `dist/` del paso 4 se puede borrar: `rm -rf dist/`. Un `stats.json` o un `.map` viejo confundiendo una investigación posterior es la mentira de los source maps desactualizados de `forense-fase-00.md`.

---

## 🧠 El patrón transferible

> **Cuando dos generaciones conviven, el mensaje de error tiene un campo que te dice en cuál estás.** Aquí es el paréntesis. Aprender a leerlo cuesta una tarde y ahorra una por incidente, porque decide entre buscar en diez archivos o en dos.

Y el segundo, que es de diseño y no de depuración: **lo que el minificador conserva es lo que decidas escribir como cadena.** Nombres de clase, de variable y de función se pierden; los literales sobreviven. Una descripción en un `InjectionToken`, un mensaje de error con el nombre del contexto dentro, una etiqueta en un `console.error`: son las únicas cosas que van a seguir ahí cuando el ticket llegue desde producción.

**Incidentes del cuaderno que usan esta ruta:** 06 y 07, los dos de convivencia de estilos 🧬.
**Amplía:** **A04** para el contexto de inyección y las opciones de `inject()`, `forense-fase-01.md` para el mismo síntoma en el mundo de los NgModule, y `forense-fase-13.md` para el stack minificado.
EOF
wc -l forense-fase-05.md

# --- 2026-09-07T01:02:46 · Write forense-fase-06
cat > forense-fase-06.md <<'EOF'
# 🕵️ Forense Fase 06 — "No me deja guardar el cliente nuevo y no dice por qué"

> Pieza forense de la **Fase 6 — Clientes y activos** · Recorrido: ~35 min
> Herramientas: `ng.getComponent($0)` · pestaña Network · el estado de un `FormGroup`
> Síntoma que cubre: un ticket vago, sin captura, sin navegador, sin usuario y sin acceso a producción.

Éste es el ticket que más se parece a los de verdad: **tres frases, ninguna reproducible**. La pieza es el procedimiento para convertirlo en un diagnóstico en cuatro minutos, y el truco central es que **el formulario contesta antes que el código**.

La fase resume los cuatro pasos. Aquí están las tres reproducciones y la salida literal de cada uno.

---

## 🎫 El ticket

> *"No me deja guardar el cliente nuevo y no dice por qué. Le doy a Guardar y no pasa nada. Ya lo intenté con dos clientes distintos."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT
**Lo que no trae:** qué escribió, en qué campo, con qué navegador, ni a qué hora.

---

## 🧭 La ruta

### Paso 1 — Reproducir con lo que hay: los tres casos

No preguntes qué escribió. **Prueba los tres estados que producen ese síntoma exacto** y mira cuál se comporta como dice el ticket. Son tres minutos.

**Reproducción A — un campo obligatorio vacío, sin tocar.**

```
Escribe: razón social = "Edificio Aurora", NIT = (vacío, sin hacer clic en él)
Pulsa:   Guardar
Se ve:   no pasa nada, y el campo del NIT NO está en rojo
```

Es el que más se parece al ticket, y por una razón que sorprende: **`mat-error` sólo se pinta cuando el control es inválido *y* está `touched`.** Un campo que nunca se tocó está inválido y mudo. Por eso el `submit()` de la fase llama a `markAllAsTouched()` antes de rendirse — sin esa línea, este ticket llega todas las semanas.

**Reproducción B — el NIT con formato inválido.**

```
Escribe: NIT = "9001"
Se ve:   el campo en rojo con "El NIT debe tener entre 9 y 10 dígitos" en cuanto sales del campo
```

**No es este caso**: el sistema sí dice por qué. Descartado.

**Reproducción C — un NIT que ya existe.**

```
Escribe: NIT = "900123456"   (el de Edificio Central S.A.S., que está en la semilla)
Pulsa:   Guardar deprisa, sin esperar
Se ve:   no pasa nada durante un segundo, y después el campo se pone en rojo
```

Éste **también** se parece al ticket, y es un bug distinto del A. Aquí está el paso 2.

**Qué descarta.** Ya sabes que hay dos causas candidatas, no una, y que producen el mismo "no pasa nada". Cuál de las dos es, lo dice el formulario.

### Paso 2 — Pregúntale al formulario, no al código

Con la pantalla abierta: inspector de elementos → selecciona el `<form>` → pestaña Console.

```js
// $0 es el elemento seleccionado en el inspector. `ng` sólo existe en el build
// de desarrollo; en producción no está, y eso es la Fase 13.
const component = ng.getComponent($0);

component.form.status;
// 'INVALID'   → hay un control que no cumple
// 'PENDING'   → hay un validador asíncrono en vuelo
// 'VALID'     → el formulario está bien y el problema es otro

Object.entries(component.form.controls)
  .filter(([, control]) => control.invalid || control.pending)
  .map(([name, control]) => ({ name, status: control.status, errors: control.errors }));
```

Las tres salidas posibles, y las tres son diagnósticos distintos:

```js
// Caso A — el campo vacío que nadie tocó
[ { name: 'taxId', status: 'INVALID', errors: { required: true } } ]

// Caso C — el NIT repetido, ya resuelto
[ { name: 'taxId', status: 'INVALID', errors: { taxIdTaken: true } } ]

// Caso C' — el validador asíncrono, todavía en vuelo… o colgado
[ { name: 'taxId', status: 'PENDING', errors: null } ]
```

**Qué descarta.** `INVALID` con un error nombrado es **un usuario que necesita un mensaje**: el bug es de interfaz y se arregla en la plantilla. `PENDING` que no cambia nunca es **un bug tuyo**: el validador asíncrono no completó, y se arregla en el validador. Los dos producen el mismo ticket y se arreglan en archivos opuestos.

> ⚠️ **`PENDING` no es `INVALID`, y ahí se cuela el bug más caro de esta pantalla.** Mientras un validador asíncrono está en vuelo, `form.invalid` es **`false`**. Un botón que sólo mira `[disabled]="form.invalid"` deja pasar el clic durante ese rato y guarda un NIT repetido. La comprobación correcta es `if (this.form.invalid || this.form.pending)`, y está en el `submit()` de la fase por esto.

### Paso 3 — Si es `PENDING`: qué pasó con la petición

Network → filtro `Fetch/XHR` → busca la petición del validador:

```
Name                                      Status    Type    Time
clients?taxId=900123456                   200       xhr     34 ms
```

Tres salidas, tres causas:

| Lo que ves en Network | Qué pasó | Dónde está el bug |
|---|---|---|
| La petición volvió `200` y el control sigue `PENDING` | el observable **no completó** | falta `first()` en el validador |
| La petición quedó en `pending` para siempre | el servidor no contesta | `CHAOS=timeout`, o el backend de verdad |
| La petición devolvió `500` y el control sigue `PENDING` | el error no se manejó | falta `catchError` |
| No hay ninguna petición | el validador ni se lanzó | los síncronos no pasaron: Angular no llama al asíncrono si `required` o `pattern` fallan |

La última fila es la que más desconcierta y es **comportamiento correcto**: Angular ejecuta primero los validadores síncronos y sólo llama al asíncrono si aquéllos pasaron. No se le pregunta al servidor por un NIT que ni siquiera tiene nueve dígitos.

Y las tres reglas que el validador de la fase lleva puestas por esto:

```ts
return timer(400).pipe(                                    // 1. ESPERAR
  switchMap(() => clientApi.existsByTaxId(taxId, exceptId)),
  map((exists) => (exists ? { taxIdTaken: true } : null)),
  catchError(() => of(null)),                              // 2. NO INVALIDAR POR RED
  first(),                                                 // 3. COMPLETAR
);
```

Quita cualquiera de las tres y tienes un ticket distinto: sin `timer`, una petición por tecla; sin `catchError`, el formulario se bloquea cuando el servidor tose; sin `first()`, el control se queda `PENDING` **para siempre** y el formulario no vuelve a ser válido en toda la sesión.

### Paso 4 — Si es `VALID` y aun así no guarda

Entonces el problema es posterior al formulario, y el camino es el de `forense-fase-00.md`: ¿salió la petición?, ¿a dónde?, ¿qué contestó? Con un añadido propio de esta pantalla:

```js
// ¿El botón está deshabilitado por otra razón?
component.submitting;   // true → hay un guardado en vuelo y el botón se bloqueó
```

Si `submitting` se quedó en `true` para siempre, el guardado anterior falló sin reponer la bandera — un `error` que no la baja. Es el mismo error de forma que el `PENDING` colgado: **un estado que sólo se limpia por el camino feliz**.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Estado del control | Dónde miras |
|---|---|---|
| No pasa nada y ningún campo en rojo | `INVALID` + `untouched` | falta `markAllAsTouched()` en el `submit()` |
| No pasa nada durante un segundo y luego rojo | `PENDING` → `INVALID` | comportamiento correcto: falta un indicador de "comprobando…" |
| No pasa nada nunca, y el campo no se pone rojo | `PENDING` para siempre | el validador no completó: falta `first()` |
| El formulario nunca vuelve a ser válido en toda la sesión | `PENDING` para siempre | lo mismo, y es el que peor se reporta |
| Guarda un NIT repetido si pulsas rápido | `PENDING` cuando pulsó | el botón sólo mira `invalid` y no `pending` |
| Se queda bloqueado tras un fallo | `submitting === true` | la bandera no se repone en el `error` |
| El campo se pone rojo con el valor correcto | `taxIdTaken` sobre uno mismo | falta el `exceptId` al editar |

---

## ⚰️ Los callejones

**"El usuario escribió mal el NIT."** Puede ser, y es lo primero que todo el mundo asume. La reproducción B lo descarta en veinte segundos: cuando el formato está mal, **el sistema sí lo dice**. Si el ticket insiste en que "no dice por qué", el formato no es la causa.

**"El backend está rechazando el guardado."** Descartable sin salir del navegador: si el problema fuera del backend, **habría una petición de guardado en Network**. En los casos A y C no hay ninguna: la petición nunca sale, porque el `submit()` se rinde antes.

**"Es la validación asíncrona que va lenta."** Medio callejón: sí es lenta —hay 400 ms de `timer` a propósito— y eso no bloquea nada por sí solo. Lo que bloquea es que **no complete**, que es otra cosa. La distinción es el paso 3 y se ve en una línea: si la petición volvió y el control sigue `PENDING`, el problema no es la lentitud.

**"Le pongo `updateValueAndValidity()` y se arregla."** Es el arreglo con peor relación beneficio/riesgo del tema: dispara la validación otra vez, tapa el síntoma la mayoría de las veces, y deja intacta la causa —un observable que no completa—, que va a volver en cuanto la red vaya lenta.

---

## 🧨 Deshacer

Nada de esta ruta modifica el proyecto: se mira, no se toca. Si creaste clientes probando, `npm run seed` devuelve el `db.json` a la semilla — y conviene, porque el NIT `900123456` de Edificio Central es el que usan las reproducciones y varios ejercicios.

Si probaste el caso del validador colgado quitando el `first()`, **devuélvelo antes de seguir**: con ese validador roto, el formulario de clientes no vuelve a ser válido y la Fase 7 te va a parecer rota sin serlo.

---

## 🧠 El patrón transferible

> **Un formulario reactivo sabe exactamente qué le pasa, y te lo dice en una línea de consola.** Antes de leer el componente, pregúntale al objeto: estado, controles inválidos, errores nombrados. Es la diferencia entre reproducir a ciegas y reproducir con una hipótesis.

Y el segundo, que se lleva a cualquier stack: **"no pasa nada" casi siempre significa que hay un estado intermedio que nadie está pintando.** `PENDING`, `submitting`, "cargando": los tres son estados reales del sistema, y si la interfaz sólo dibuja el éxito y el error, el usuario ve un botón muerto y escribe un ticket que no se puede reproducir.

**Incidentes del cuaderno que usan esta ruta:** ninguno directamente, y es a propósito: esta ruta es la **herramienta** con la que se resuelven varios de la semana 2 y 3. El `ng.getComponent($0)` reaparece en `forense-fase-08.md` y en `forense-fase-09.md`.
**Amplía:** **A05** §6 para validadores asíncronos y §7 para `value` frente a `getRawValue()`, **A01** §3 para por qué un `mat-error` puede no pintarse.
EOF
wc -l forense-fase-06.md

# --- 2026-09-07T01:04:04 · Write forense-fase-07
cat > forense-fase-07.md <<'EOF'
# 🕵️ Forense Fase 07 — "Esta inspección se ve con otra plantilla" ⭐

> Pieza forense de la **Fase 7 — Plantillas versionadas** · Recorrido: ~45 min
> Herramientas: la URL de la petición a `/templates` · `curl` · el `db.json`
> Síntoma que cubre: dos tickets que llegan con las mismas palabras y significan cosas opuestas. Uno **no es un bug** y hay que demostrarlo; el otro es el más grave del sistema.

Ésta es la pieza central del curso. El invariante que protege cabe en una línea —**una inspección guarda su `templateVersion` y se lee siempre con ésa**— y se rompe de seis maneras. Lo notable es que las seis se distinguen **mirando la URL de una petición**, antes de abrir un archivo.

La fase enseña las dos preguntas gemelas. Aquí están los dos tickets literales, con la salida de cada paso.

---

## 🎫 Ticket 1 — el que no es un bug

> *"Abrí la inspección 501 del ascensor de la torre A, la de agosto del año pasado, y el ítem del cable dice 'Estado del cable principal'. En las inspecciones nuevas dice 'Estado y tensión del cable principal'. ¿Está desactualizada?"*

**Reportado por:** coordinador de certificaciones · **Ambiente:** UAT

## 🎫 Ticket 2 — el que sí lo es

> *"La inspección de agosto ahora tiene un ítem más que cuando la hice. Yo respondí tres cosas y ahora aparecen cuatro, y la última está vacía. No la he vuelto a tocar."*

**Reportado por:** inspector de campo · **Ambiente:** UAT

**Las mismas palabras, la conclusión opuesta.** El ticket 1 describe el sistema funcionando; el ticket 2 describe el histórico corrompiéndose. Y quien los escribe no puede saber cuál tiene.

---

## 🧭 La ruta

Los dos tickets comparten los tres primeros pasos. Es lo que los hace eficientes: **una sola investigación contesta las dos preguntas.**

### Paso 1 — ¿Qué versión dice la inspección que usó?

Es un **campo guardado**, no un cálculo. Y por eso se puede consultar sin pasar por la aplicación:

```bash
curl -s "http://localhost:3000/inspections/501" -H "Authorization: Bearer <token>" \
  | python3 -m json.tool | head -8
```

```json
{
    "id": 501,
    "assetId": "ASC-CENTRAL-04",
    "inspectorId": "INS-15",
    "templateId": "elevator-annual",
    "templateVersion": 1,
    "status": "approved",
    "startedAt": "2023-08-02T08:30:00-05:00"
}
```

**Qué descarta.** `templateVersion: 1`. A partir de aquí hay **un solo comportamiento correcto**: esa inspección se lee con la v1, hoy y dentro de diez años, aunque la vigente sea la v9. Cualquier otra cosa es el bug. Si este campo faltara o fuera `null`, el problema sería anterior y mucho peor: una inspección sin versión guardada no se puede reconstruir nunca.

### Paso 2 — ⭐ La URL de la petición contesta antes que el código

DevTools → **Network** → filtro `Fetch/XHR` → abre la inspección → busca la petición a `/templates`.

**Éste es el paso que decide toda la investigación**, y son diez segundos:

```
✅ CORRECTO
Request URL: http://localhost:3000/templates?templateId=elevator-annual&version=1
```

```
❌ BUG — resolvió por fecha
Request URL: http://localhost:3000/templates?templateId=elevator-annual
```

```
❌ BUG — versión equivocada
Request URL: http://localhost:3000/templates?templateId=elevator-annual&version=2
```

| Lo que ves en la URL | Qué pasó | Dónde está |
|---|---|---|
| `&version=1`, igual que el campo | el sistema hizo lo correcto | **es el ticket 1**: no hay bug, salta al paso 4 |
| **No hay `version=`** | alguien resolvió por fecha, no por versión | **el 90% del ticket 2**: `resolveTemplateVersion` donde iba `getByVersion` |
| `&version=` con otro número | leyó el campo equivocado | típicamente `family.latest.version` en vez de `inspection.templateVersion` |
| No hay ninguna petición a `/templates` | la plantilla salió de un estado ya cargado | y ese estado puede tener la vigente: mira el `*StateService` |

> 🧭 **La regla que hace posible este paso, y que vale para cualquier sistema con datos versionados: la petición es la confesión.** Si la consulta no lleva la versión, no hay forma de que la respuesta sea la correcta salvo por casualidad — y la casualidad se acaba el día que alguien publica una versión nueva. Comprobarlo cuesta un vistazo, y evita leer código durante una hora.

### Paso 3 — ¿La respuesta trae lo que pidió la URL?

Clic en la petición → pestaña **Response**:

```json
[
  {
    "id": "elevator-annual-v1",
    "templateId": "elevator-annual",
    "version": 1,
    "validFrom": "2021-01-01",
    "validUntil": "2023-12-31",
    "items": [
      { "id": "main-cable", "title": "Estado del cable principal", … },
      { "id": "emergency-brake", "title": "Freno de emergencia", … },
      { "id": "door-sensor", "title": "Sensor de puerta", … }
    ]
  }
]
```

**Tres ítems**, y `main-cable` con el título **sin** "y tensión". Ésa es la v1, y ésa es la respuesta correcta para la inspección 501.

**Qué descarta.** Si la URL pedía `version=1` y la respuesta trae cuatro ítems o el título nuevo, entonces **el bug no está en el frontend**: alguien editó una versión publicada en la base de datos. Es el caso más raro y el más grave, y se confirma comparando contra la semilla:

```bash
diff <(curl -s "http://localhost:3000/templates?templateId=elevator-annual&version=1") \
     <(python3 -c "import json,sys; d=json.load(open('mock/db.seed.json')); \
        print(json.dumps([t for t in d['templates'] if t['id']=='elevator-annual-v1']))")
```

### Paso 4 (ticket 1) — Cómo se demuestra que no hay bug

Éste es un entregable tan legítimo como un fix, y hay que saber escribirlo. Tres afirmaciones, cada una con su evidencia:

1. **La inspección 501 se ejecutó el 2 de agosto de 2023** (`startedAt`), cuando la v1 era la vigente (`validFrom: 2021-01-01`, `validUntil: 2023-12-31`).
2. **Guardó `templateVersion: 1`**, y ese campo no ha cambiado.
3. **La pantalla pide la v1 y pinta tres ítems**, que es lo que la v1 tiene.

Y la frase que cierra el ticket, que es la parte difícil porque contradice a quien lo reportó:

> *"No está desactualizada: está congelada, y es lo que tiene que pasar. Una inspección firmada en 2023 dice lo que se inspeccionó en 2023. Si se re-renderizara con la norma de hoy, el certificado que salió de ella estaría afirmando algo que nadie comprobó."*

### Paso 5 (ticket 2) — Dónde está la línea

Con la URL sin `version=`, el archivo es uno de dos y la diferencia es la lección de la fase entera:

```ts
// ❌ "¿Qué versión aplica HOY?" — es una pregunta legítima, y no es ésta.
const template = resolveTemplateVersion(family, todayInBusinessZone());

// ✅ "¿Con qué versión se ejecutó ESTA inspección?" — es un campo, no un cálculo.
const template = await firstValueFrom(
  this.templateApi.getByVersion(inspection.templateId, inspection.templateVersion),
);
```

```bash
# Los dos sitios donde puede estar, y son pocos:
grep -rn "resolveTemplateVersion" src/app --include="*.ts" | grep -v spec
```

**Cada aparición de `resolveTemplateVersion` hay que justificarla.** Es correcta cuando se está **empezando** una inspección nueva —ahí sí se pregunta qué versión rige hoy— y es un bug en cualquier sitio donde se esté **leyendo** una inspección existente. La Fase 8 §5.9 tiene el único uso legítimo del curso.

### Paso 6 — El otro incidente: "el sistema dice que hay dos plantillas vigentes"

Es el incidente 09 y su ruta es distinta, porque el bug está en el **dato**, no en la lectura:

```bash
curl -s "http://localhost:3000/templates?templateId=elevator-annual" \
  | python3 -c "import json,sys; [print(t['version'], t['validFrom'], t['validUntil']) for t in json.load(sys.stdin)]"
```

```
1 2021-01-01 2023-12-31
2 2024-01-01 None
3 2025-06-01 None      ← dos ventanas abiertas a la vez
```

**Dos filas con `validUntil: null` es el bug entero**, y se ve en tres líneas de salida. `null` significa "vigente indefinidamente"; publicar la v3 sin cerrar la v2 deja dos versiones vigentes el mismo día, y `resolveTemplateVersion` tiene que elegir entre dos respuestas igualmente válidas — así que devuelve la que le toque según cómo esté escrito el desempate, y ése es el comportamiento indefinido.

> ⚠️ **Publicar una versión nueva es una operación de dos escrituras**: nace la v3 con su `validFrom` **y** se cierra la v2 poniéndole `validUntil`. Si sólo se hace la primera, no falla nada hoy y el sistema queda ambiguo para siempre. Es la clase de bug que un `strict` no puede atrapar, porque `null` es un valor perfectamente válido en las dos filas.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Dónde miras |
|---|---|---|
| Una inspección vieja con la plantilla vieja | **no es un bug** | demuéstralo con los tres puntos del paso 4 |
| Una inspección vieja con la plantilla nueva | resolución por fecha | la URL: falta `version=` |
| La URL lleva `version=` con otro número | se leyó el campo equivocado | `family.latest.version` en vez de `inspection.templateVersion` |
| La URL es correcta y el contenido no | el dato está corrompido | `diff` contra `db.seed.json` |
| No hay petición a `/templates` | vino de un estado ya cargado | el `*StateService`, que puede tener la vigente |
| "Hay dos plantillas vigentes" | dos `validUntil: null` | el `db.json`, tres líneas de salida |
| Una inspección sin `templateVersion` | mucho peor que todo lo anterior | no se puede reconstruir: es un dato perdido |

---

## ⚰️ Los callejones

**"Hay que actualizar las inspecciones viejas a la versión nueva."** Es la reacción más frecuente y **es exactamente el bug**, propuesto como arreglo. Una inspección responde a las preguntas que se le hicieron; migrarla a otra plantilla inventa respuestas que nadie dio. El histórico no se actualiza: se respeta.

**"El editor de plantillas está sobrescribiendo la v1."** Comprobable en un `diff` contra la semilla, y casi nunca es cierto: el editor de la Fase 7 sólo **crea** versiones nuevas y sólo toca `validUntil` al cerrar. Lo que sí puede sobrescribirla es un script de mantenimiento o alguien editando el `db.json` a mano — y ahí no hay ninguna defensa activa, sólo un diseño que no ofrece la operación.

**"Es la caché del navegador."** Descartable con *Disable cache* y una recarga. Y aunque lo fuera, la URL seguiría siendo la misma: si la URL no lleva `version=`, la caché no tiene nada que ver.

**"El backend devuelve mal."** Posible y raro. El paso 3 lo separa: si la URL pide `version=1` y la respuesta trae la v2, es del servidor; si la URL no pide versión, el servidor hizo lo que le pidieron.

---

## 🧨 Deshacer

Si probaste el paso 3 editando la v1 en el `db.json` —el 🧨 de la fase te lo hace hacer—, **`npm run seed`** lo devuelve todo. No lo dejes: la v1 alterada rompe la Fase 8, la Fase 10 y cuatro incidentes del cuaderno, y el síntoma que produce parece un bug de código.

Si añadiste una v3 para reproducir el paso 6, la misma orden la borra.

---

## 🧠 El patrón transferible

> **En un sistema con datos versionados, hay dos preguntas que suenan igual y no lo son: "¿cuál rige hoy?" y "¿con cuál se hizo esto?".** La primera es un cálculo sobre fechas; la segunda es leer un campo. Confundirlas no da ningún error: da un histórico que cambia solo, y nadie se entera hasta que alguien compara con un papel.

Y el segundo, que es el que ahorra las horas: **la consulta es la confesión.** Antes de leer una línea de código, mira qué se le pidió al servidor. Si la petición no lleva el discriminante, la respuesta sólo puede ser correcta por casualidad.

**Incidentes del cuaderno que usan esta ruta:** 08 (el ítem de más), 09 (dos vigentes) y 10 (los ítems de otra inspección), que son los tres de versionado del curso, y ninguno se resuelve en el mismo archivo.
**Amplía:** `forense-fase-08.md` para cuando el síntoma llega desde el formulario, y `forense-fase-12.md` para el test de regresión que reproduce el 08 **antes** del fix.
EOF
wc -l forense-fase-07.md

# --- 2026-09-07T01:05:20 · Write forense-fase-08
cat > forense-fase-08.md <<'EOF'
# 🕵️ Forense Fase 08 — "Escribo una letra y la aplicación se queda pegada" ⭐

> Pieza forense de la **Fase 8 — Formulario dinámico desde plantilla** · Recorrido: ~50 min
> Herramientas: Network en reposo · `console.count` · las claves de un `FormRecord` · `ng.getComponent($0)`
> Síntoma que cubre: tres tickets del formulario de inspección, y los tres se resuelven **mirando fuera del código**.

Un formulario construido en runtime tiene una propiedad incómoda: **su forma no está escrita en ninguna parte**. No puedes abrir el HTML y contar los campos. Por eso las tres investigaciones de esta pieza empiezan comparando el formulario con el dato que lo generó, y ninguna empieza leyendo el componente.

La fase resume las tres. Aquí están los tres tickets literales y la salida de cada paso.

---

## 🎫 Ticket A — el bucle

> *"Escribo una letra en la nota de un ítem y la aplicación se queda pegada. El ventilador del portátil se dispara. Si cierro la pestaña se arregla."*

**Reportado por:** inspector de campo · **Ambiente:** UAT · **Es el incidente 11**

## 🎫 Ticket B — el control huérfano

> *"Cambié de inspección desde el listado y me aparecieron ítems de la otra. Uno de ellos ni siquiera es de este ascensor."*

**Reportado por:** inspector de campo · **Ambiente:** UAT · **Es el incidente 10**

## 🎫 Ticket C — el error que desaparece

> *"Me sale un error rojo larguísimo en la consola cuando marco el último ítem, pero sólo en mi máquina. En el ambiente de pruebas no pasa."*

**Reportado por:** un compañero del equipo · **Ambiente:** desarrollo

---

## 🧭 Ruta A — el bucle de `valueChanges`

### Paso 1 — Network con la aplicación quieta

DevTools → **Network** → filtro `Fetch/XHR` → abre la inspección → **no toques nada** → mira treinta segundos.

```
Name                Status    Type    Time
inspections/500     200       xhr     11 ms
inspections/500     200       xhr     9 ms
inspections/500     200       xhr     12 ms
inspections/500     200       xhr     10 ms
…
```

**Qué descarta.** Si con la aplicación quieta siguen saliendo `PATCH`, hay un bucle **que pasa por la red**. No hay que leer nada todavía: ya sabes que el ciclo incluye una respuesta del servidor.

Si **no** sale nada con la aplicación quieta pero la pantalla se arrastra al escribir, el bucle es **interno** —un `valueChanges` que escribe en el mismo formulario— y ni siquiera hace falta Network. Salta al paso 2.

### Paso 2 — Dos contadores, y el ciclo queda dibujado

```ts
// Temporal, en los dos extremos del sospechoso.
this.form.valueChanges.pipe(/* … */).subscribe(() => {
  console.count('valueChanges');
});

// …y en el next del guardado:
next: () => console.count('guardado ok'),
```

```
valueChanges: 1
guardado ok: 1
valueChanges: 2      ← el guardado disparó otro valueChanges
guardado ok: 2
valueChanges: 3
…
```

**Qué descarta.** Los dos crecen a la vez y sin parar: **el ciclo pasa por el guardado**. Si sólo crece `valueChanges`, el bucle no llega a la red y el culpable es algo que escribe en el formulario dentro de la propia suscripción.

### Paso 3 — El ciclo, dibujado, y las dos formas de romperlo

```
1. El inspector escribe una letra.  →  valueChanges emite.
2. Pasa el debounce, sale el PATCH, el servidor responde con la inspección guardada.
3. "Para que quede sincronizado", alguien parchea el formulario con la respuesta.
4. patchValue dispara valueChanges.  →  vuelve al 2.
```

Cierra perfecto y **no da ningún error**. Lo que se ve es la aplicación arrastrándose y la pestaña de Network llenándose sola.

```ts
// ❌ El arreglo que parece obvio: apagar la emisión.
this.form.patchValue(saved.answers, { emitEvent: false });
```

Funciona, y sigue siendo mala idea: estás **pisando lo que el inspector tenía escrito** con lo que el servidor te devolvió. Si escribió algo durante el viaje de red, se pierde. Cambias un bug ruidoso por uno silencioso.

```ts
// ✅ El arreglo correcto: después de guardar, el formulario no se toca.
next: () => { this.lastSaved = serializeAnswers(answers); },
```

**El servidor confirma; no dicta.** El único `patchValue` de esta pantalla es el de la carga inicial — y ni siquiera hace falta, porque el formulario se construye ya con los valores dentro.

> ⚠️ **Y una causa del mismo bucle que no es un `patchValue`:** `disable()` y `enable()` **también disparan `valueChanges`** salvo que les pases `{ emitEvent: false }`. Un ítem que se deshabilita según lo que el inspector responda en otro produce exactamente este ticket, y el `patchValue` culpable no aparece por ninguna parte.

---

## 🧭 Ruta B — el control huérfano

### Paso 1 — Compara las claves del formulario con los ítems de la plantilla

Con la pantalla abierta: inspector → selecciona el `<form>` → consola.

```js
const component = ng.getComponent($0);

// Las claves del FormRecord: un control por ítem, con el itemId como clave.
Object.keys(component.currentView.form.controls);
// ['main-cable', 'emergency-brake', 'door-sensor', 'pressure-valve']

// Los ítems de la plantilla que la inspección guardó:
component.currentView.template.items.map((item) => item.id);
// ['main-cable', 'emergency-brake', 'door-sensor']
```

**Qué descarta.** `pressure-valve` sobra, y **su nombre te dice de dónde vino**: es un ítem de `boiler-annual`, la plantilla de calderas. Este formulario no se reconstruyó al cambiar de inspección: se le añadieron los controles de la nueva encima de los de la anterior.

Las tres lecturas posibles de una clave sobrante:

| La clave sobrante es… | Qué pasó | ¿Bug? |
|---|---|---|
| un `itemId` de **otra plantilla** | el formulario no se reconstruyó | **sí** — es el incidente 10 |
| un `itemId` de la **misma familia**, retirado en una versión posterior | es una respuesta de un ítem que ya no existe | **no** — es correcto, y se pinta como "ítem retirado" |
| un `itemId` que no existe en ninguna plantilla | el dato está corrompido | **sí**, y el bug no está en el frontend |

### Paso 2 — Y la comprobación gemela: la versión

Si el formulario tiene los ítems correctos pero con los **títulos** equivocados, el problema no es el `FormRecord`: es qué plantilla se usó para construirlo, y eso es `forense-fase-07.md` paso 2. La Fase 8 §5.3 lo avisa por escrito:

```ts
/**
 * ⚠️ `template` tiene que ser la versión que la inspección guardó, obtenida con
 * `getByVersion(inspection.templateId, inspection.templateVersion)`. Si le pasas
 * la vigente, esta función construye un formulario perfectamente válido con la
 * plantilla equivocada y nadie se entera.
 */
```

**Un formulario dinámico construido con la plantilla equivocada no falla: funciona.** Ése es el peligro entero.

### Paso 3 — Por qué el `FormRecord` se rehace y no se parchea

```ts
// ❌ Añadir los controles de la inspección nueva sobre el formulario que había.
for (const item of template.items) {
  this.form.addControl(item.id, buildItemGroup(item, /* … */));
}
// addControl() NO reemplaza si la clave existe, y NO quita las que sobran.

// ✅ Un formulario nuevo por inspección. Es una función pura: dale los datos y
//    devuelve un formulario. No hay estado que arrastrar.
const form = buildAnswerForm(template, inspection.answers);
```

> 🧭 **La regla del proyecto que evita esta familia entera: la clave es el `itemId`, nunca la posición.** Con `FormArray` indexado por posición, reordenar los ítems en una v3 desplazaría las respuestas de todo el mundo. Con `FormRecord` y el `itemId` como clave no hay nada que desplazar — y además, la diferencia entre las claves del formulario y los ítems de la plantilla delata al huérfano en una línea, que es justo lo que acabas de hacer.

---

## 🧭 Ruta C — `NG0100`, y su desaparición

### Paso 1 — Leer el error entero, que sí dice lo que pasa

```
ERROR Error: NG0100: ExpressionChangedAfterItHasBeenCheckedError:
Expression has changed after it was checked. Previous value for 'ngIf': 'false'.
Current value: 'true'. Expression location: InspectionFormComponent component.
Find more at https://angular.io/errors/NG0100
```

**Qué descarta.** El mensaje trae las tres cosas que hacen falta: **qué expresión** (`ngIf`), **qué valores** (`false` → `true`) y **qué componente**. No hace falta el stack. Lo que dice es: durante el ciclo de detección de cambios, algo cambió un valor **después** de que Angular ya lo hubiera comprobado.

En este formulario el sospechoso es siempre el mismo: un cálculo de progreso o de validez que se dispara desde la propia plantilla y muta algo que la plantilla ya leyó.

### Paso 2 — El experimento que enseña la lección de verdad

```bash
ng build --configuration production
npx http-server dist/certcore -p 8081
```

Repite el gesto exacto que lo provocaba.

**El error no aparece.** `NG0100` sólo existe en desarrollo: es una comprobación doble que Angular hace y que en producción se apaga.

**Y ésta es la parte importante:** lo que no aparece **tampoco** es el valor actualizado. El bug sigue estando —la pantalla muestra un dato viejo— y ahora no hay nada que te avise. En desarrollo tenías un error rojo y ningún problema visible; en producción tienes un problema visible y ninguna pista.

> 🧠 **Guarda esa sensación.** En la Fase 13 vas a ver la versión general del mismo fenómeno: el build de producción no arregla nada, sólo deja de contártelo. Un `NG0100` que "se arregló solo" al desplegar es un bug que acaba de volverse invisible.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Ruta | Primera comprobación |
|---|---|---|
| Peticiones sin parar con la aplicación quieta | A | Network en reposo, treinta segundos |
| La pantalla se arrastra al escribir y no hay tráfico | A, bucle interno | dos `console.count` |
| Aparecen campos que no son de esta inspección | B | claves del `FormRecord` frente a ítems de la plantilla |
| Los ítems son correctos y los títulos no | 07 | la URL de `/templates` |
| Un ítem aparece marcado como retirado | **no es un bug** | es una respuesta de un ítem que ya no existe |
| `NG0100` en desarrollo | C | lee la expresión y el componente del mensaje |
| `NG0100` que desapareció al desplegar | C | no se arregló: dejó de avisarte |
| El autosave guarda dos veces lo mismo | A | falta `distinctUntilChanged` **con comparador** |
| El autosave no guarda nunca más tras un fallo | — | `catchError` en el pipe externo — **A06** §6 |

---

## ⚰️ Los callejones

**"Es que `debounceTime` es muy corto."** Subirlo hace que el bucle sea más lento, no que desaparezca. Si el ciclo se realimenta, con 1500 ms tienes una petición cada segundo y medio para siempre. Un debounce nunca arregla un bucle: lo espacia.

**"Le pongo `{ emitEvent: false }` a todo."** Apaga el síntoma en varios sitios a la vez y deja el formulario silenciado de formas que nadie recuerda seis meses después. Además pierde escritura del usuario (ruta A, paso 3). Se usa donde hay una razón concreta, no como política.

**"Hay que limpiar el formulario al cambiar de inspección."** Medio callejón: es el arreglo correcto **si** se hace reconstruyéndolo entero, y es un parche frágil si se hace quitando controles a mano — porque hay que acertar cuáles quitar, y ésa es la lista que ya estaba mal.

**"El `NG0100` es un bug de Angular."** No: es Angular avisando de un bug tuyo, y sólo lo hace en desarrollo por cortesía. El experimento del paso 2 de la ruta C lo demuestra en dos minutos.

---

## 🧨 Deshacer

Quita los `console.count` antes de commitear. Si para reproducir la ruta B alteraste el `templateId` o el `templateVersion` de una inspección en el `db.json`, **`npm run seed`**: una inspección apuntando a una plantilla que no le corresponde rompe la Fase 9 y la Fase 10 con síntomas que no se parecen a éste.

El `dist/` del paso 2 de la ruta C se puede borrar (`rm -rf dist/`).

---

## 🧠 El patrón transferible

> **Un formulario construido desde datos se depura comparándolo con los datos, no leyéndolo.** Sus claves tienen que ser exactamente las del origen. Esa comparación cabe en dos líneas de consola y localiza en un segundo lo que leyendo el componente cuesta media hora.

Y el segundo, que se lleva a cualquier interfaz reactiva: **si un efecto puede disparar la causa que lo produjo, tienes un bucle aunque hoy no se note.** El dibujo de cuatro pasos de la ruta A se hace en una servilleta antes de escribir el código, y es lo único que lo evita de verdad. Después, cuando ya está escrito, lo que queda es Network en reposo.

**Incidentes del cuaderno que usan esta ruta:** 10 (los ítems de otra inspección, que es de versionado) y 11 (el bucle).
**Amplía:** **A05** §4 y §8 para `FormRecord` y los formularios que no se conocen en compilación, **A06** §5 para `debounceTime` + `distinctUntilChanged`, y `forense-fase-07.md` cuando lo que falla es la versión y no la forma.
EOF
wc -l forense-fase-08.md; ls forense-fase-*.md | wc -l

# --- 2026-09-07T01:06:03 · Update Fase 9 forensic promise to two tickets
sed -i '' 's|> 📄 El recorrido completo, con el ticket literal y la salida de cada paso, en `forense-fase-09.md`.|> 📄 El recorrido completo, con los dos tickets literales y la salida de cada paso, en `forense-fase-09.md`.|' 09-hallazgos-severidad.md
grep -n '📄' 09-hallazgos-severidad.md

# --- 2026-09-07T01:07:19 · Write forense-fase-09
cat > forense-fase-09.md <<'EOF'
# 🕵️ Forense Fase 09 — "El sistema me dejó aprobar y no debía"

> Pieza forense de la **Fase 9 — Hallazgos y severidad** · Recorrido: ~40 min
> Herramientas: el JSON crudo de la respuesta · tres comparaciones en consola · `ng.getComponent($0)`
> Síntoma que cubre: una regla de negocio que no se aplicó, sin ningún error en ninguna parte.

Los dos tickets de esta pieza son la misma familia con dos caras: **`null`, `undefined` y campo ausente son tres cosas distintas**, y bajo `strict` el compilador te protege de dos de ellas y no de la tercera. La tercera es la que llega desde la red.

La fase resume el primer recorrido. Aquí están los dos tickets y la salida de cada paso.

---

## 🎫 Ticket A — la regla que no bloqueó

> *"Aprobé la inspección del ascensor de la torre A y el sistema me dejó, pero el cable está para cambiar. Lo puse como hallazgo crítico y aun así me dejó aprobar. ¿No era que no se podía?"*

**Reportado por:** supervisor de certificaciones · **Ambiente:** UAT · **Es el incidente 12**

## 🎫 Ticket B — el cambio que se deshizo solo

> *"El supervisor subió la severidad de un hallazgo de menor a mayor el jueves, y el viernes había vuelto a bajar. Nadie lo tocó. No aparece en ningún registro."*

**Reportado por:** coordinador de certificaciones · **Ambiente:** UAT · **Es el incidente 13**

**No hay error en consola, no hay nada rojo en Network, y la pantalla muestra el dato perfectamente.** Los dos tickets describen un sistema que hace algo distinto de lo que dice hacer, en silencio.

---

## 🧭 Ruta A — la regla que no bloqueó

### Paso 1 — El JSON crudo, no lo que pinta la pantalla

Ésta es la distinción que resuelve el ticket, y hay que hacerla en ese orden: **primero el cuerpo de la respuesta, después la pantalla.** La pantalla ya aplicó tus valores por defecto; el cuerpo, no.

Network → la petición a `/findings?inspectionId=…` → pestaña **Response**:

```json
[
  {
    "id": 900,
    "inspectionId": 503,
    "itemId": "main-cable",
    "severity": "critical",
    "description": "Desgaste severo del cable principal, con hilos visibles",
    "resolvedAt": null
  },
  {
    "id": 904,
    "inspectionId": 503,
    "itemId": "door-sensor",
    "severity": "major",
    "description": "El sensor no detecta obstáculos"
  }
]
```

**Qué descarta.** Míralas por columnas, no por filas. La primera trae `resolvedAt: null`. **La segunda no trae la clave.** No es que valga `null`: es que el campo **no existe**.

Y entre el tipo que declara ese campo y el servidor que no lo manda **no hay nadie comprobando nada**:

```ts
// El tipo promete que el campo existe. TypeScript se lo cree, porque el
// tipado de una respuesta HTTP es una afirmación, no una verificación.
export interface Finding {
  readonly resolvedAt: string | null;
}
```

Ésa es la línea entera del bug: `this.http.get<Finding[]>(url)` **no valida nada**. El genérico es una promesa que tú haces al compilador sobre datos que vienen de fuera.

### Paso 2 — Las tres preguntas, y sus tres respuestas distintas

Con la pantalla de hallazgos abierta: inspector → selecciona el `<li>` del hallazgo → consola.

```js
const finding = ng.getComponent($0).finding;

finding.resolvedAt === null;    // false  ← y aquí nace el bug
finding.resolvedAt == null;     // true   ← cubre null Y undefined
'resolvedAt' in finding;        // false  ← el campo NO EXISTE
finding.resolvedAt;             // undefined
```

**Estas tres líneas son la fase entera en tres respuestas.** La primera es la que escribiste; la segunda es el fix del viernes; la tercera es la que te dice de dónde vino.

Y la regla que las une, con la comprobación culpable delante:

```ts
// ❌ La regla, escrita como se escribe siempre:
const blocking = findings.filter(
  (finding) => finding.severity === 'critical' && finding.resolvedAt === null,
);
// El hallazgo 904 tiene `undefined`, no `null`. `undefined === null` es false.
// El hallazgo no entra en la lista, no bloquea nada, y la emisión sigue.
```

> ⚠️ **`strict: true` no te salva de esto, y conviene entender por qué.** El compilador comprueba lo que **declaraste**, y tú declaraste `string | null`. Si el dato real trae `undefined`, el compilador no tiene forma de saberlo: nunca vio la respuesta. `strict` protege la frontera entre tus archivos; **la frontera con la red la tienes que defender tú.**

### Paso 3 — Dónde va el arreglo, que es la decisión de verdad

El `?? null` puede ir en tres sitios y **los tres funcionan hoy**:

```ts
// Opción 1 — en el componente, donde se manifestó.
const blocking = findings.filter((f) => f.severity === 'critical' && (f.resolvedAt ?? null) === null);

// Opción 2 — en la regla de dominio.
export function blockingFindings(findings: readonly Finding[]): readonly Finding[] { … }

// Opción 3 — en el borde HTTP, al entrar el dato al sistema.
map((raw) => raw.map((finding) => ({ ...finding, resolvedAt: finding.resolvedAt ?? null })));
```

| Opción | Arregla esta pantalla | La emisión del certificado (Fase 10) | El dashboard (Fase 11) |
|---|---|---|---|
| 1 — componente | ✅ | ❌ | ❌ |
| 2 — regla de dominio | ✅ | ✅ | ❌ si el dashboard no la usa |
| 3 — **borde HTTP** | ✅ | ✅ | ✅ |

**Sólo la tercera sigue funcionando cuando la Fase 10 lea el mismo campo para decidir si emite un certificado, y cuando la Fase 11 lo cuente en el panel.** Ponerlo en el borde no es elegancia: es no tener que acordarte dos fases más adelante, en dos archivos que todavía no existen.

> 🧭 **La regla del proyecto: lo que entra por la red se normaliza una vez, en el borde, y a partir de ahí el dominio confía.** Un `?? null` repartido por cinco componentes es cinco sitios donde alguien puede olvidarse; uno en el `*ApiService` es un sitio donde alguien puede leerlo.

---

## 🧭 Ruta B — el cambio que se deshizo solo

### Paso 1 — ¿El dato está guardado o está derivado?

La pregunta que ordena el ticket, y se contesta comparando dos cosas:

```bash
# Lo que el servidor guarda:
curl -s "http://localhost:3000/findings/901" -H "Authorization: Bearer <token>"
# { "id": 901, "inspectionId": 503, "itemId": "cabin-lighting",
#   "severity": "major", … }
```

```js
// Lo que la pantalla muestra:
ng.getComponent($0).finding.severity;   // 'minor'
```

**Guardado dice `major`. Pintado dice `minor`.** El dato existe, se guardó bien, y algo lo está recalculando por encima.

### Paso 2 — Quién manda: el dato o la regla

```ts
// La regla de derivación de la fase: la severidad sale del ítem de la
// plantilla, no del hallazgo.
export function severityOf(item: ChecklistItem, answer: string): Severity {
  return isNonCompliant(item, answer) ? item.nonComplianceSeverity : 'minor';
}
```

`cabin-lighting` tiene `nonComplianceSeverity: 'minor'` en la v2 de `elevator-annual`. La regla devuelve `minor` cada vez que se ejecuta, y **pisa el `major` que el supervisor escribió**.

**Qué descarta.** No es un bug de guardado: el `PATCH` funcionó y el dato está en el servidor. Es que **el sistema tiene dos fuentes de verdad para el mismo campo** y la derivada gana cada vez que alguien recarga.

### Paso 3 — La forma del arreglo, y por qué `undefined` vuelve a ser el culpable

Un campo de anulación explícito, y aquí está la trampa que conecta esta ruta con la A:

```ts
// ❌ Opcional: "no me molesté en decidirlo".
severityOverride?: Severity;
// Un hallazgo sin anulación trae la clave ausente; otro trae `undefined`;
// otro trae `null` si alguien la quitó. Tres formas de decir lo mismo, y la
// comprobación que las distinga se escribe mal la primera vez.

// ✅ Explícito: `null` significa "sin anulación", y es un valor decidido.
readonly severityOverride: Severity | null;

export function effectiveSeverity(finding: Finding, item: ChecklistItem, answer: string): Severity {
  // La anulación gana, y sólo si existe de verdad.
  return finding.severityOverride ?? severityOf(item, answer);
}
```

> 🧭 **La regla del proyecto (guía §6.4): los modelos del dominio distinguen ausencia de vacío.** `validUntil: string | null` significa "vigente indefinidamente"; `validUntil?: string` significaría "no me molesté en decidirlo", y eso no entra al curso. Es la misma decisión que la ruta A, tomada al escribir el modelo en vez de al depurar el ticket.

Y la mitad que este ticket deja sin resolver, que hay que decir en el post-mortem: **no aparece en ningún registro**. Aunque la anulación se guarde bien, nadie sabe quién la puso ni cuándo. En un sistema cuyo dominio **es** la trazabilidad, eso es un hallazgo de diseño, no un bug — y es exactamente el límite del patrón de estado que **A07** §8 nombra.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Primera comprobación |
|---|---|---|
| Una regla no se aplicó y no hay error | `undefined` donde esperabas `null` | `'campo' in objeto` en la consola |
| El JSON crudo no trae una clave que el tipo declara | el genérico de `HttpClient` no valida nada | normaliza en el borde HTTP |
| `x === null` es `false` y el campo está vacío | es `undefined` | `== null` cubre los dos, y es el fix del viernes |
| Guardado dice una cosa y pintado otra | hay un derivado pisando el dato | compara `curl` con `ng.getComponent` |
| Un cambio se deshace al recargar | dos fuentes de verdad para un campo | decide cuál manda, y hazlo explícito |
| El cambio se aplica y nadie sabe quién lo hizo | no hay trazabilidad | es un hallazgo de diseño — **A07** §8 |
| El mismo bug reaparece en otra pantalla | el arreglo se puso en el componente | debía ir en el borde — paso 3 de la ruta A |

---

## ⚰️ Los callejones

**"El supervisor no guardó bien."** El callejón número uno del ticket B, y es el que echa la culpa a una persona. Se descarta con un `curl`: si el servidor tiene `major`, el guardado funcionó. Y hacerlo **antes** de preguntarle a nadie es la diferencia entre un post-mortem y una conversación incómoda.

**"Faltaba un `!` o un `as`."** Es lo que sugiere el compilador cuando el tipo no cuadra, y aquí sería lo peor posible: silenciarías la única señal disponible. La guía prohíbe el aserto de no-nulo en el código del curso precisamente por esta familia de bugs.

**"El backend está mal y que lo arreglen ellos."** Puede ser cierto **y no cambia tu trabajo**. Un cliente que se cae porque el servidor omitió un campo opcional es un cliente frágil. La normalización en el borde no es suplir al backend: es no depender de que nadie cambie nunca un contrato.

**"Hay que quitar la derivación y guardar la severidad."** Tentador y peor: si la severidad se guarda, el día que la norma cambie el `nonComplianceSeverity` de un ítem, los hallazgos viejos seguirán diciendo lo de antes y nadie sabrá si eso es correcto o es un dato viejo. La derivación es la decisión correcta; lo que faltaba era **una anulación explícita**, que es otra cosa.

---

## 🧨 Deshacer

La ruta A se reproduce quitando la clave `resolvedAt` de un hallazgo en el `db.json` — es el 🧨 de la fase. **`npm run seed`** lo devuelve: un hallazgo sin ese campo hace que la Fase 10 emita certificados que no debería, y el síntoma aparece dos fases más allá sin ninguna pista de dónde vino.

La ruta B no modifica nada: se mira. Si probaste el `PATCH` de la severidad, la misma orden.

---

## 🧠 El patrón transferible

> **`strict` protege la frontera entre tus archivos, no la frontera con la red.** Un genérico en `http.get<T>()` es una promesa que tú le haces al compilador sobre datos que él nunca va a ver. Todo lo que entra por esa puerta hay que normalizarlo una vez, en el borde, y a partir de ahí el dominio puede confiar.

Y el segundo, que es de diseño: **cuando un campo tiene dos fuentes de verdad, la derivada gana siempre, y gana en silencio.** No hay error, no hay conflicto, no hay aviso: simplemente el próximo recálculo pisa lo que alguien escribió. Si quieres que un valor manual sobreviva, tiene que existir como campo propio con un valor que signifique "aquí no hay anulación" — y ese valor se decide al escribir el modelo, no al depurar el ticket.

**Incidentes del cuaderno que usan esta ruta:** 12 y 13, los dos de tipos bajo `strict`.
**Amplía:** **A05** §1 para `FormControl<T>` y el `| null` que nadie espera, **A07** §5 y §8 para derivar sin duplicar y para dónde el patrón se queda corto, y `forense-fase-10.md` para el mismo mecanismo aplicado al `status` de un certificado.
EOF
wc -l forense-fase-09.md

# --- 2026-09-07T01:08:32 · Write forense-fase-10
cat > forense-fase-10.md <<'EOF'
# 🕵️ Forense Fase 10 — "Venció ayer para el sistema y hoy para el cliente"

> Pieza forense de la **Fase 10 — Certificados, vigencia y PDF** · Recorrido: ~45 min
> Herramientas: los últimos seis caracteres de una cadena ISO · tres conversiones en consola · la zona horaria del sistema operativo
> Síntoma que cubre: dos observadores del mismo dato llegan a conclusiones distintas, y sólo a ciertas horas.

Esta pieza tiene una conclusión que conviene leer antes que el recorrido, porque cambia dónde se busca: **nunca es un bug de fechas.** `Date` hizo exactamente lo que le pidieron. Es un bug de **no haber decidido a qué hora vence algo**, y por eso el arreglo nunca es un `+1` ni un `-5`.

La fase resume los tres pasos. Aquí está el recorrido con la salida de cada uno, más el segundo ticket que la misma causa produce en el PDF.

---

## 🎫 Ticket A — el que llega mal escrito

> *"A veces el sistema dice que un certificado está vencido y el cliente nos manda una foto del papel donde dice que vence hoy. Pasa sobre todo por la tarde."*

**Reportado por:** coordinador de certificaciones · **Ambiente:** PROD · **Es el incidente 15**

Tres datos que el reporte trae sin saberlo: **"a veces"** (no siempre), **"por la tarde"** (hay un patrón horario) y **"la foto del papel"** (el PDF y la pantalla no coinciden, que es el ticket B).

## 🎫 Ticket B — el documento que no coincide

> *"Descargué el certificado y la tabla de hallazgos no dice lo mismo que la pantalla que tenía delante."*

**Reportado por:** supervisor · **Ambiente:** UAT · **Es el incidente 14**

---

## 🧭 Ruta A — la vigencia

### Paso 1 — Los últimos seis caracteres, y sólo ésos

Network → la petición a `/certificates` → pestaña **Response**. No leas el objeto: lee **el final de la cadena**.

```json
{
  "id": "CERT-2024-000502",
  "inspectionId": 502,
  "issuedAt": "2024-02-10T10:00:00-05:00",
  "validUntil": "2025-02-10T23:59:59-05:00",
  "status": "valid",
  "revokedAt": null
}
```

**Qué descarta.** Los seis últimos caracteres de `validUntil` deciden en qué mitad del sistema está el bug, y se leen en diez segundos:

| Lo que termina la cadena | Qué significa | Dónde está el bug |
|---|---|---|
| `-05:00` | el dato está completo y sin ambigüedad | en **quien lo lee**: paso 2 |
| `Z` | el instante es correcto y el **día** de negocio se perdió al escribirlo | en **quien lo emitió** |
| nada (`2025-02-10T23:59:59`) | no hay instante: hay una cadena que cada lector interpreta a su manera | en **quien lo emitió**, y es peor |
| `2025-02-10` a secas | ni siquiera hay hora | en el modelo: falta una decisión |

En CertCore todas las fechas de la semilla llevan `-05:00`, a propósito y desde la Fase 3. Así que en este ticket el bug está en la lectura — que es la mitad buena, porque se arregla sin tocar ningún dato histórico.

> ⚠️ **Y una segunda cosa en esa misma respuesta, que es un bug distinto y peor:** `status: "valid"` está **guardado**. Un estado que se calcula pero se almacena empieza a mentir al día siguiente. Ese certificado vence el 10 de febrero de 2025 y su campo dice `valid` para siempre, hasta que alguien lo actualice. La Fase 10 lo convierte en derivado por esto, y es la misma familia que el ticket B de `forense-fase-09.md`.

### Paso 2 — Las tres conversiones, y las tres son correctas

Con la pantalla abierta, en la consola:

```js
const validUntil = '2025-02-10T23:59:59-05:00';

new Date(validUntil).toISOString();
// '2025-02-11T04:59:59.000Z'      ← el MISMO instante, en UTC

new Date(validUntil).toString();
// 'Mon Feb 10 2025 23:59:59 GMT-0500 …'   ← el mismo instante, en TU huso

toBusinessDay(validUntil);
// '2025-02-10'                    ← el DÍA que ve el negocio
```

**Qué descarta.** Las tres son correctas y las tres dicen cosas distintas, y ahí está todo el bug: **alguien eligió una de las tres para decidir, y eligió sin saber que estaba eligiendo.**

Fíjate en la primera: en UTC, ese certificado vence el **11** de febrero. Si el código compara días con `toISOString().slice(0, 10)`, un usuario en Bogotá y el servidor no están hablando del mismo día — y la diferencia sólo se nota a partir de las 19:00 hora de Bogotá, que es **exactamente el "sobre todo por la tarde" del ticket**.

Esa frase del reporte, que parecía ruido, era el dato más preciso que traía.

### Paso 3 — El experimento de treinta segundos que separa dos mundos

Cambia la zona horaria de **tu sistema operativo** a Auckland (UTC+13) y recarga la aplicación.

```js
// Para comprobar que el cambio tomó efecto:
Intl.DateTimeFormat().resolvedOptions().timeZone;   // 'Pacific/Auckland'
```

**Qué descarta**, y es un corte limpio:

- **Si ningún certificado cambia de estado** → el cálculo es correcto. La única zona que participa es la del negocio, como manda `business-day.ts`, y el huso del navegador no entra en ninguna decisión.
- **Si alguno cambia** → hay un `new Date()` leyendo con el huso del navegador en algún punto del camino, y el paso 2 te dice en cuál.

```bash
# Y el sospechoso se busca así. Cada aparición hay que justificarla:
grep -rn "new Date()\|Date.now()\|toISOString()" src/app --include="*.ts" | grep -v spec
```

**Un `new Date()` suelto donde importe el día es siempre sospechoso.** No porque esté mal en abstracto, sino porque no dice de quién es el reloj que está preguntando.

### Paso 4 — Por qué el arreglo es una función y no un ajuste

```ts
// ❌ Los tres arreglos que aparecen en cualquier revisión, y los tres son peores
//    que el bug: mueven el síntoma a otra hora del día o a otro huso.
const expired = new Date(cert.validUntil) < new Date();
const expired = new Date(cert.validUntil).getTime() + 86400000 < Date.now();
const expired = cert.validUntil.slice(0, 10) < new Date().toISOString().slice(0, 10);

// ✅ Una decisión, con nombre, en un archivo, llamada desde todas partes.
export const BUSINESS_TIME_ZONE = 'America/Bogota';

export function todayInBusinessZone(): string { … }   // '2025-02-10'
export function toBusinessDay(instant: string): string { … }

const expired = toBusinessDay(cert.validUntil) < todayInBusinessZone();
```

> 🧭 **La regla del proyecto: la zona horaria de una decisión de negocio es un dato del negocio, no del entorno.** Un certificado vence al final del día **en el huso donde opera la empresa**, y eso no cambia porque el inspector esté de viaje o porque el servidor esté en otro continente. Cuando esa decisión tiene nombre y vive en un archivo, deja de tomarse por accidente en catorce sitios distintos.

---

## 🧭 Ruta B — el PDF que no coincide

### Paso 1 — Reproducir con dos pestañas

No hace falta ninguna herramienta:

1. Abre el detalle de un certificado en una pestaña. **No la cierres.**
2. En otra pestaña, marca como resuelto uno de sus hallazgos.
3. Vuelve a la primera —que sigue mostrando el estado de hace un rato— y descarga el PDF.

```
Pantalla (pestaña 1):  door-sensor · Mayor · Pendiente
PDF descargado:        door-sensor · Mayor · Pendiente
Servidor (curl):       door-sensor · Mayor · RESUELTO
```

**Qué descarta.** El PDF coincide con la **pantalla** y no con el **dato**. Eso localiza el bug sin ambigüedad: el documento se armó desde lo que había pintado, no desde la fuente.

### Paso 2 — La comprobación en el código, que es una firma

```ts
// ❌ Si la función que arma el PDF recibe lo que el componente ya tenía,
//    el bug está en la firma, antes de leer una línea del cuerpo.
download(view: CertificateView, findings: readonly InspectionFinding[]): Promise<void>

// ✅ Una interfaz explícita con todo lo que el documento necesita, y las seis
//    cosas se piden otra vez.
export interface CertificateDocumentSource {
  readonly certificate: Certificate;
  readonly view: CertificateView;
  readonly inspection: Inspection;
  readonly template: ChecklistTemplate;   // la versión CONGELADA de la inspección
  readonly asset: Asset;
  readonly client: Client;
  readonly findings: readonly InspectionFinding[];
}
```

**Que sea un tipo con nombre y no "lo que tenga el componente" es la mitad del arreglo:** se ve de un vistazo que hacen falta seis cosas, y las seis tienen que venir de la fuente.

> ⚠️ **Lo que hace peligrosa a esta deuda no es que el dato esté viejo: es que el PDF es el único artefacto del sistema que sobrevive al sistema.** Una pantalla desactualizada se arregla con F5. Un PDF desactualizado se archiva, se imprime y se adjunta a la respuesta de un requerimiento normativo, y dentro de dos años nadie va a poder decir de qué momento son sus datos. El desarrollo completo está en **A08** §7 y §9.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Primera comprobación |
|---|---|---|
| "Vence hoy" para uno y "venció ayer" para otro | se comparan días en husos distintos | los seis últimos caracteres de la cadena |
| Pasa sólo a ciertas horas | la diferencia de huso cruza la medianoche | el offset, y quién lo lee |
| Una fecha termina en `Z` | el día de negocio se perdió al escribirla | quien la emitió, no quien la lee |
| Una fecha sin offset | no hay instante, hay una cadena ambigua | el modelo: falta una decisión |
| El estado dice `valid` y la fecha dice que no | el estado está guardado, no derivado | es la misma familia que `forense-fase-09.md` |
| Cambias el huso del sistema y algo cambia | hay un `new Date()` con el reloj del navegador | `grep` de `new Date()` |
| El PDF no coincide con la pantalla | se armó desde la vista | la **firma** de la función que lo arma |
| El PDF coincide con la pantalla y no con el servidor | lo mismo, confirmado | tres pestañas, ninguna herramienta |

---

## ⚰️ Los callejones

**"Es un bug de zonas horarias de JavaScript."** El callejón más caro, porque manda a buscar librerías. `Date` es incómodo y aquí no se equivocó: convirtió correctamente entre husos, tres veces, con tres resultados correctos. El bug es que nadie decidió **cuál de los tres** era el bueno para esta decisión de negocio.

**"Guardemos todo en UTC y se acabó."** Es la respuesta estándar y resuelve el problema equivocado. UTC te da un **instante** sin ambigüedad, y eso ya lo tienes con el offset. Lo que UTC no te da es el **día de calendario del negocio**, que es lo que decide si un certificado está vencido. Un certificado que vence "el 10 de febrero" no vence a las 05:00 UTC del 11 porque sí: vence al final del día laboral de donde opera la empresa.

**"Sumemos un día."** Mueve el error de sitio. Con `+1` día el bug desaparece por la tarde en Bogotá y aparece por la mañana en Auckland. Un desplazamiento constante nunca arregla un problema de husos, sólo cambia a quién le toca.

**"El PDF está cacheado."** Descartable en un segundo: cada descarga genera el archivo desde cero en el navegador. Si el contenido es viejo, es porque los **datos** que se le dieron eran viejos, no porque el archivo lo fuera.

---

## 🧨 Deshacer

**Devuelve la zona horaria de tu sistema operativo** después del paso 3. Es el único paso de todo el track que toca algo fuera del proyecto, y olvidarlo te va a dar resultados desconcertantes en la Fase 11 y en la 12 —donde hay tests que dependen del reloj— sin ninguna relación aparente con lo que estabas haciendo.

Si marcaste hallazgos como resueltos reproduciendo la ruta B, `npm run seed`.

---

## 🧠 El patrón transferible

> **Nunca es un bug de fechas.** Es un bug de no haber decidido, y la pregunta que lo revela siempre es la misma: *¿a qué hora, y en qué huso, ocurre esto?* Si la respuesta no está escrita en un archivo con un nombre, está tomada por accidente en cada sitio donde alguien escribió `new Date()`.

Y el segundo, que vale para cualquier artefacto exportado: **lo que hay en la pantalla es una foto de hace un rato.** Está bien para mirar y está mal para imprimir. Cualquier cosa que sobreviva a la sesión —un PDF, un correo, un export— se arma pidiendo el dato otra vez, y la forma de garantizarlo es que la función que lo arma **no acepte** lo que el componente ya tenía.

**Incidentes del cuaderno que usan esta ruta:** 14 (el PDF que no coincide) y 15 (venció ayer/hoy).
**Amplía:** **A08** §7 y §9 para el PDF que se arma desde el dato y para lo que un documento exportado ya no puede desandar, y `forense-fase-09.md` para el mismo mecanismo de dato guardado frente a dato derivado.
EOF
wc -l forense-fase-10.md

# --- 2026-09-07T01:09:35 · Write forense-fase-11
cat > forense-fase-11.md <<'EOF'
# 🕵️ Forense Fase 11 — "Desde ayer el panel va lentísimo"

> Pieza forense de la **Fase 11 — Dashboard y alertas** · Recorrido: ~45 min
> Herramientas: Network en reposo · `console.time` · panel Performance · Angular DevTools Profiler
> Síntoma que cubre: una pantalla lenta, con cuatro sospechosos, y un orden de descarte que separa media hora de media tarde.

Lo que hace difícil este ticket no es encontrar la causa: es **no empezar por el sospechoso equivocado**. `ChangeDetectionStrategy` es lo primero que todo el mundo mira y casi nunca es el culpable — y cambiarla a ciegas produce un bug peor, porque un `OnPush` mal puesto no va lento: va **mal**.

La fase resume los cuatro sospechosos. Aquí está el recorrido con la salida de cada paso y el criterio de decisión de cada uno.

---

## 🎫 El ticket

> *"Desde ayer el panel tarda un montón en cargar y el ventilador se dispara. Al principio del mes iba bien. Y si lo dejo abierto y me voy a comer, cuando vuelvo está peor."*

**Reportado por:** coordinador de certificaciones · **Ambiente:** UAT

Tres datos que el reporte trae sin saberlo: **"desde ayer"** (algo cambió, o algo creció), **"al principio del mes iba bien"** (el volumen de datos importa) y **"si lo dejo abierto está peor"** (se degrada con el tiempo, que apunta a fuga y no a cálculo).

---

## 🧭 La ruta: cuatro sospechosos, en este orden

El orden es la lección entera. Cuesta más descartar al cuarto que a los tres primeros juntos.

### Sospechoso 1 — Una suscripción que no murió

El más frecuente y el más barato de descartar. **Dos minutos, sin abrir el código.**

DevTools → **Network** → filtro `Fetch/XHR` → **sal del panel** → espera dos minutos sin tocar nada.

```
Name                          Status    Type    Time
certificates                  200       xhr     14 ms
inspections                   200       xhr     22 ms
certificates                  200       xhr     11 ms
inspections                   200       xhr     19 ms
…
```

**Qué descarta.** Si sigue saliendo tráfico de una pantalla que ya no está abierta, **ya lo tienes** y no hace falta nada más. Y el ritmo te dice cuántas fugas hay: si el intervalo original era de un minuto y ves tres pares de peticiones por minuto, hay tres pantallas zombis vivas.

Eso explica también la última frase del ticket: *"si lo dejo abierto está peor"*. Cada entrada al panel deja una suscripción más, y todas siguen trabajando.

**Si no sale tráfico**, pasa al 2. La ruta completa para cazar la fuga —incluido el panel Memory— está en `forense-fase-04.md`.

### Sospechoso 2 — El cálculo

Rodea el `map` de las agregaciones con un temporizador. Sin perfilador, sin instrumentación:

```ts
// Temporal, en el map de metrics$.
console.time('buildMetrics');
const metrics = buildDashboardMetrics(certificates, inspections, clients);
console.timeEnd('buildMetrics');
return metrics;
```

```
buildMetrics: 3.8 ms
buildMetrics: 4.1 ms
buildMetrics: 3.9 ms
```

**Qué descarta**, y el criterio importa más que el número:

- **Por debajo de 16 ms**, el cálculo **no es el problema**, aunque lo parezca. 16 ms es lo que dura un fotograma a 60 fps: por debajo de eso el usuario no lo puede percibir.
- **Por encima de 16 ms**, todavía no acuses: mira **cuántas veces sale por minuto**. Un cálculo de 40 ms una vez por minuto es invisible; el mismo cálculo cinco veces por segundo es una pantalla congelada.

```ts
// La segunda mitad de la medición, y la que suele dar el diagnóstico:
console.count('buildMetrics');
```

**Un cálculo barato ejecutado muchas veces es el patrón más común de este sospechoso**, y su causa casi siempre es un derivado sin compartir: cada suscriptor recalcula. Es lo que `shareReplay({ bufferSize: 1, refCount: true })` resuelve, y lo que su ausencia produce.

Y el otro caso, que conecta con el ticket: *"al principio del mes iba bien"*. Si el cálculo es O(n²) sobre certificados e inspecciones, con la semilla de seis filas no se nota y con cuatrocientas sí. Mide con el volumen de verdad, no con el de desarrollo.

### Sospechoso 3 — El gráfico

Con el panel abierto y **quieto**: DevTools → **Performance** → graba treinta segundos → detén.

Lo que buscas en la línea de tiempo:

```
Main thread
  ⌐ requestAnimationFrame    ▮  ▮  ▮  ▮  ▮  ▮  ▮  ▮      ← picos regulares
      Animation Frame Fired      cada ~16 ms, sin que nadie toque nada
```

**Qué descarta.** Picos regulares de `requestAnimationFrame` con la pantalla quieta es **una animación corriendo en bucle**. Chart.js redibuja cuando **la identidad** de sus datos cambia, no cuando cambian los valores:

```ts
// ❌ Un objeto nuevo en cada emisión: Chart.js cree que son datos nuevos y
//    reinicia la animación. Con un observable que emite seguido, no para nunca.
readonly chartData$ = this.metrics$.pipe(
  map((metrics) => ({ labels: [...], datasets: [{ data: metrics.byMonth }] })),
);

// ✅ La misma referencia, con los valores actualizados dentro, y el gráfico
//    actualizado a mano. O, más simple: `animation: false` en las opciones.
```

Es exactamente el parpadeo que la Fase 11 §5.7 arregla, visto desde el perfilador.

### Sospechoso 4 — Y **sólo ahora**, la detección de cambios

Angular DevTools → pestaña **Profiler** → graba **una interacción** → detén.

```
Change Detection cycle
  Duration: 3.2 ms          ← la columna que importa
  Components checked: 214   ← la columna que NO importa
```

**Qué descarta**, y es el criterio que hay que memorizar:

| Ciclo | Componentes revisados | Veredicto |
|---|---|---|
| 3 ms | 214 | **no es un problema.** Revisar es barato |
| 200 ms | 4 | **sí lo es**, y el culpable está **dentro** de esos cuatro |

**Un ciclo lento con pocos componentes** apunta a lo que hay dentro: un getter que calcula en cada revisión, un `*ngFor` sin `trackBy` sobre dos mil filas, una función llamada desde la plantilla.

```html
<!-- ❌ Se ejecuta en CADA ciclo de detección de cambios, decenas de veces por segundo. -->
<span>{{ calculateExpiringCount(certificates) }}</span>

<!-- ✅ Ya calculado, una vez, en el observable. -->
<span>{{ (metrics$ | async)?.expiringCount }}</span>
```

> 🧭 **La regla que se lleva el estudiante: `ChangeDetectionStrategy` es el último sospechoso, no el primero.** Cambiarla es barato de escribir y caro de depurar, porque un componente `OnPush` mal puesto **no va lento: va mal**. Deja de pintarse cuando alguien muta un array en vez de reemplazarlo, y el bug que produce no se parece en nada al que intentabas arreglar — es el de la Fase 6, y su síntoma es "la lista no se actualiza", no "el panel va lento".

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Sospechoso | Herramienta, en este orden |
|---|---|---|
| Tráfico con la pantalla cerrada | 1 · fuga | Network en reposo, dos minutos |
| Va peor cuanto más rato lleva abierto | 1 · fuga | lo mismo |
| Empeoró al crecer los datos | 2 · cálculo | `console.time` con volumen real |
| El cálculo es rápido y se ejecuta mucho | 2 · derivado sin compartir | `console.count` — falta `shareReplay` |
| Picos regulares con la pantalla quieta | 3 · gráfico | Performance, 30 s |
| El gráfico parpadea al actualizarse | 3 · identidad de los datos | la referencia del objeto de datos |
| Ciclo lento con pocos componentes | 4 · lo que hay dentro | getters y funciones en la plantilla |
| Ciclo rápido con muchos componentes | **ninguno** | no es un problema |
| La lista no se actualiza | **no es este ticket** | es `OnPush` con un array mutado — Fase 6 |

---

## ⚰️ Los callejones

**"Hay que poner `OnPush` en todo."** El callejón favorito, y es el sospechoso 4 puesto en primer lugar. Puede que ayude y puede que no cambie nada; lo seguro es que si el problema era una fuga (sospechoso 1), `OnPush` no la toca, y ahora tienes dos investigaciones abiertas en vez de una.

**"Son demasiados datos, hay que paginar."** Puede ser cierto y hay que **medirlo antes**. El `console.time` del sospechoso 2 con el volumen real contesta en un minuto. Paginar un panel que tarda 4 ms en calcular es trabajo tirado, y encima empeora la experiencia.

**"Es el navegador del usuario."** Se descarta abriendo el mismo panel en tu máquina con las mismas condiciones. Y si de verdad sólo pasa en una máquina, la pregunta siguiente es qué extensiones tiene instaladas — no es una broma: un bloqueador agresivo interceptando peticiones produce exactamente este síntoma.

**"Vamos a memorizar el cálculo."** Es el arreglo correcto **para el sospechoso 2** y ninguno de los otros tres. Aplicado a ciegas añade complejidad y no mueve la aguja, y encima esconde el problema real durante un tiempo.

---

## 🧨 Deshacer

Quita los `console.time` y `console.count` temporales antes de commitear. Si para reproducir el sospechoso 2 inflaste el `db.json` con cuatrocientas inspecciones —que es lo que la Fase 11 §5.1 te hace hacer—, **`npm run seed`** lo devuelve: un `db.json` de ese tamaño hace lentas las demás fases sin motivo, y su lentitud parece un bug.

Las grabaciones de Performance y del Profiler viven en la sesión de DevTools y no dejan nada en el proyecto.

---

## 🧠 El patrón transferible

> **Descarta por costo, no por sospecha.** Dos minutos de Network en reposo descartan el sospechoso más frecuente sin abrir nada. Diez minutos de perfilador descartan el menos frecuente. Empezar por el perfilador porque es la herramienta que suena a "rendimiento" es cómo una tarde se va sin haber descartado nada.

Y el segundo, que es el que más se olvida: **una medición sin criterio no es una medición.** El perfilador te da un número; lo que decide si ese número es un problema es saber que 16 ms es un fotograma, que revisar componentes es barato, y que la columna que importa es el tiempo y no el conteo. Sin ese criterio, cualquier número parece grande y cualquier optimización parece justificada.

**Incidentes del cuaderno que usan esta ruta:** 16 (el panel cerrado que sigue pidiendo).
**Amplía:** `forense-fase-04.md` para cazar la fuga una vez confirmada, **A06** §7 para `shareReplay` y su `refCount`, y **A07** §5 para derivar sin duplicar.
EOF
wc -l forense-fase-11.md; ls forense-fase-*.md | wc -l

# --- 2026-09-07T01:17:57 · Rest of Fase 12 forensic section
sed -n '1085,1112p' 12-testing-coverage.md

# --- 2026-09-07T01:19:20 · Write forense-fase-12
cat > forense-fase-12.md <<'EOF'
# 🕵️ Forense Fase 12 — "Pasa en mi máquina y falla en el pipeline"

> Pieza forense de la **Fase 12 — Testing desde cero + coverage** · Recorrido: ~50 min
> Herramientas: la semilla de Jasmine · bisección de la suite · `fakeAsync` · `git bisect`
> Síntoma que cubre: dos tickets sobre tests — el que hay que escribir **antes** del fix, y el que falla una de cada diez veces.

Los tests son la única parte del sistema donde el bug puede estar **en el instrumento de medida**. Por eso las dos rutas de esta pieza empiezan igual: convirtiendo algo no determinista en determinista, porque un fallo que no se puede reproducir no se puede investigar.

La fase resume los cuatro sospechosos del intermitente. Aquí están los dos tickets y la salida de cada paso.

---

## 🎫 Ticket A — el test que va antes del fix

> *"Confirmado el bug de la inspección de agosto. Antes de tocar nada quiero el test que lo reproduce, y quiero poder ver el `git diff` del fix sin el ruido de la fase."*

**Reportado por:** tu líder técnico · **Ambiente:** — · **Cierra el incidente 08**

## 🎫 Ticket B — el intermitente

> *"El test pasa en mi máquina y falla en el pipeline, y nadie tocó nada. A veces vuelve a pasar si relanzo el job."*

**Reportado por:** un compañero del equipo · **Ambiente:** integración continua · **Es el incidente 17**

**"A veces vuelve a pasar si relanzo"** es la frase que define el ticket B, y también la que hace que mucha gente lo relance hasta que pase y siga con su día. Ésa es la decisión que esta pieza intenta que no tomes.

---

## 🧭 Ruta A — el test de regresión, y por qué va primero

### Paso 1 — La rama sale del tag de la fase, no de tu rama de trabajo

```bash
# El commit de partida es el tag que pusiste al cerrar la Fase 7: ahí el bug
# existe y nada más lo enturbia.
git switch -c inc/08/version-equivocada-roto fase-07
```

**Qué descarta.** Partir de `master` mete en el diff todo lo que hicieron las Fases 8 a 11. Partiendo del tag, el `git diff` final contiene **el bug y su fix, y nada más** — que es exactamente el punto 5 de un post-mortem.

### Paso 2 — El test, y verlo fallar

Escribirlo antes no es disciplina: es la única forma de saber que el test **prueba lo que crees**. Un test escrito después del fix pasa desde el primer momento, y no hay ninguna evidencia de que habría fallado antes.

```ts
// El test entero cabe en diez líneas y no necesita TestBed: la regla vive en
// una función pura, que es lo que hace posible esto.
it('lee una inspección con la versión que guardó, no con la vigente', () => {
  const family = [templateV1, templateV2];   // v1 hasta 2023-12-31, v2 desde 2024-01-01
  const inspection = { templateVersion: 1, templateId: 'elevator-annual' } as Inspection;

  const applied = family.find((version) => version.version === inspection.templateVersion);

  expect(applied?.version).toBe(1);
  expect(applied?.items.length).toBe(3);     // la v2 tiene cuatro
});
```

```
Chrome Headless 120.0.0: Executed 1 of 1 (1 FAILED) (0.031 secs / 0.008 secs)

TemplateResolution
  ✗ lee una inspección con la versión que guardó, no con la vigente
    Expected 2 to be 1.
```

**Qué descarta.** `Expected 2 to be 1` es la evidencia de que el test **ve** el bug. Si hubiera pasado en verde, el test no estaría probando lo que dice probar, y habrías desplegado un fix sin red.

```bash
git commit -am "incidente(08): repro — el test reproduce el bug y falla"
git tag -a inc/08/version-equivocada-roto -m "F7 inc08: el test reproduce el bug y falla"
```

### Paso 3 — El fix, y el segundo tag

```bash
# …aplicas el fix, el test pasa…
git commit -am "incidente(08): fix — leer templateVersion de la inspección, no del template"
git tag -a inc/08/version-equivocada-fix -m "F7 inc08: causa raíz y fix, con el test en verde"
```

Y ahora el entregable, que es lo que justifica los dos tags:

```bash
git diff inc/08/version-equivocada-roto inc/08/version-equivocada-fix
```

```diff
-    const template = resolveTemplateVersion(family, todayInBusinessZone());
+    const template = family.find(
+      (version) => version.version === inspection.templateVersion,
+    );
```

**Dos líneas.** Ése es el punto 5 del post-mortem, aislado del ruido de once fases, y se puede pegar en un ticket. Sin los dos tags, encontrarlo dentro de seis meses cuesta una tarde de arqueología.

> 💡 **Y el atajo para releer el cuaderno entero sin abrir un archivo:** `git tag -n99 -l 'inc/*'` lista todos los incidentes con el mensaje completo de cada tag.

---

## 🧭 Ruta B — el intermitente, en cuatro sospechosos

### Paso 0 — Antes de nada: hazlo determinista

Un fallo que ocurre una de cada diez veces no se investiga: **se hace ocurrir siempre.** Todo lo que sigue depende de este paso.

```bash
# Correr la misma suite varias veces y ver si el patrón aparece:
ng test --watch=false --browsers=ChromeHeadless
```

```
Randomized with seed 47291
Chrome Headless 120.0.0: Executed 128 of 128 SUCCESS (2.104 secs)
```

```
Randomized with seed 83104
Chrome Headless 120.0.0: Executed 128 of 128 (1 FAILED) (2.233 secs)
```

**Qué descarta.** La semilla es lo primero que Jasmine imprime y lo primero que casi nadie lee. Si con una semilla falla y con otra pasa, **el problema es el orden** (sospechoso 3). Si falla con todas o con ninguna, el orden no es el culpable y hay que mirar los otros tres.

```bash
# Y a partir de aquí, la semilla se fija y el fallo es reproducible:
ng test --watch=false --browsers=ChromeHeadless --seed=83104
```

### Sospechoso 1 — El reloj

```bash
# Búscalo en el CÓDIGO BAJO PRUEBA, no en el test. El test no pregunta la hora:
# la pregunta el código, y por eso el test depende de cuándo se ejecute.
grep -rn "new Date()\|Date.now()" src/app --include="*.ts" | grep -v spec
```

En este proyecto hay un caso exacto y vale la pena verlo:

```ts
// CertificateStateService.issue() llama a new Date() por dentro, y
// buildCertificateId saca el año de ahí.
const id = buildCertificateId(new Date());   // 'CERT-2025-000503'
```

Un test que corra a las **23:59:59 del 31 de diciembre** genera un `id` con el año siguiente. Falla una vez al año, durante un segundo, en un pipeline que probablemente no esté corriendo. Es la clase de intermitente que nadie caza nunca — y es una crítica legítima al diseño, no al test: **un método que pregunta la hora por su cuenta no se puede probar de forma determinista.**

```ts
// ✅ El arreglo, y es de diseño: el instante entra como parámetro.
issue(inspectionId: number, now: string): void { … }
```

### Sospechoso 2 — El azar

```bash
grep -rn "randomUUID\|Math.random" src/app --include="*.ts" | grep -v spec
```

El `CorrelationIdInterceptor` estampa un `crypto.randomUUID()` en cada petición. Un test que compruebe el **valor** de esa cabecera falla siempre; uno que compruebe su **forma** pasa siempre:

```ts
// ❌ expect(headers.get('X-Correlation-Id')).toBe('3f2a9c1e-…');
// ✅
expect(headers.get('X-Correlation-Id')).toMatch(/^[0-9a-f-]{36}$/);
```

### Sospechoso 3 — El orden, y la bisección

Con la semilla fija del paso 0, el fallo es reproducible. Ahora se acorrala:

```
1. Marca la mitad de los `describe` con `xdescribe` y corre con la misma semilla.
2. ¿Sigue fallando? El culpable está en la mitad que quedó. ¿Dejó de fallar?
   Está en la que quitaste.
3. Repite con esa mitad. Siete iteraciones bastan para 128 tests.
```

Lo que queda cuando el fallo desaparece es **la pareja de tests que se contaminan**, y la contaminación casi siempre es una de estas tres:

| Qué quedó sucio | Cómo se ve | Cómo se limpia |
|---|---|---|
| Un servicio `providedIn: 'root'` con estado | el segundo test ve los datos del primero | `TestBed.resetTestingModule()` (lo hace Karma solo entre `it`, no entre `describe` mal montados) |
| Un espía global | `jasmine.clock()` o un `spyOn` sobre algo compartido | `afterEach` que lo restaure |
| `localStorage` | el token del test de login sobrevive | `afterEach(() => localStorage.clear())` |

> 🧭 **Un test que sólo pasa si otro corrió antes no es un test: es media prueba.** Y su fallo aparece el día que alguien añada un `it` en otro archivo, que es cuando nadie lo va a relacionar con nada.

### Sospechoso 4 — La asincronía

El más silencioso, porque **el test pasa en verde sin haber comprobado nada**:

```ts
// ❌ El `it` es síncrono. El subscribe resuelve después de que terminó.
//    Jasmine no espera a nadie que no le hayas dicho que espere.
it('carga las plantillas', () => {
  service.load();
  service.templates$.subscribe((templates) => {
    expect(templates.length).toBe(3);   // esto puede no ejecutarse NUNCA
  });
});
```

```
Chrome Headless 120.0.0: Executed 1 of 1 SUCCESS (0.012 secs)
```

**Verde, y no probó nada.** La forma de detectarlo es brutal y eficaz: **pon una aserción imposible dentro del callback**. Si el test sigue pasando, el callback no se está ejecutando.

```ts
// ✅ Determinista: el tiempo virtual se controla.
it('carga las plantillas', fakeAsync(() => {
  service.load();
  httpMock.expectOne('/templates').flush(threeTemplates);
  tick();

  let received: readonly ChecklistTemplate[] = [];
  service.templates$.subscribe((templates) => (received = templates));
  tick();

  expect(received.length).toBe(3);
}));
```

`done` también funciona y es peor: un `done` que no se llama **tarda cinco segundos en fallar**, y con veinte tests así el pipeline pasa de dos minutos a diez sin que nadie sepa por qué.

### Paso final — Si nada de lo anterior: `git bisect`

Cuando el intermitente empezó "desde algún commit" y no sabes cuál:

```bash
git bisect start
git bisect bad HEAD
git bisect good fase-11
# En cada paso, corre la suite N veces con la semilla que falla:
git bisect run sh -c 'ng test --watch=false --browsers=ChromeHeadless --seed=83104'
```

Es el último recurso porque cuesta N ejecuciones completas de la suite, y es infalible cuando el resto no dio nada.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Sospechoso | Primera comprobación |
|---|---|---|
| Falla con una semilla y pasa con otra | 3 · orden | fija la semilla y bisecciona |
| Falla siempre en el pipeline y nunca en local | 1 · reloj, o 3 · orden | ¿qué hora es en el runner?, ¿qué semilla usa? |
| Falla una vez al año, o al cambiar de mes | 1 · reloj | `new Date()` en el código bajo prueba |
| El valor esperado nunca coincide | 2 · azar | comprueba la forma, no el valor |
| Pasa en verde y no prueba nada | 4 · asincronía | mete una aserción imposible dentro del callback |
| Un test tarda 5 s en fallar | 4 · un `done` que no se llama | `fakeAsync` + `tick` |
| El segundo test ve datos del primero | 3 · contaminación | `afterEach` que limpie estado y `localStorage` |
| Empezó a fallar y nadie tocó nada | — | `git bisect run` con la semilla fija |

---

## ⚰️ Los callejones

**"Relánzalo, a veces pasa."** No es un callejón: es la decisión de no investigar, y es la más cara de todas. Un test intermitente que se relanza hasta que pasa enseña al equipo a ignorar los fallos rojos, y el día que uno sea real nadie lo va a mirar. **Un test intermitente es un test roto**, aunque el código que prueba esté bien.

**"Es el pipeline, que es más lento."** Medio callejón. Sí es más lento, y eso **revela** intermitentes de asincronía en vez de causarlos: un `subscribe` que en tu máquina resuelve en 2 ms y en el runner en 40 ms cambia el orden de ejecución. El pipeline no rompió el test; lo destapó.

**"Le subo el timeout."** Tapa el sospechoso 4 y sólo a veces. Un test que necesita más tiempo está esperando algo que no controla, y la respuesta es controlarlo con `fakeAsync`, no darle más margen al azar.

**"Voy a poner `xit` mientras tanto."** Es legítimo **como decisión consciente y con fecha**, y es un desastre como reflejo. Un `xit` sin comentario ni ticket es un test que nadie va a volver a mirar, y encima el coverage sigue contando la línea como cubierta si otro test la toca de refilón — que es exactamente el incidente 20.

---

## 🧨 Deshacer

Quita los `xdescribe` de la bisección: uno olvidado desactiva media suite y el coverage baja sin que nadie sepa por qué. `grep -rn "xdescribe\|xit\|fdescribe\|fit" src/` antes de commitear — y `fdescribe` es peor que `xdescribe`, porque hace pasar la suite entera ejecutando **un solo bloque**.

Si terminaste una bisección: `git bisect reset`. Si dejaste ramas de incidente sin fusionar, los tags `inc/…` ya conservan los dos puntos, así que la rama se puede borrar sin perder nada.

---

## 🧠 El patrón transferible

> **Un test intermitente es un test roto.** No es una molestia del pipeline ni una peculiaridad del runner: es una prueba que a veces no prueba, y eso vale menos que no tenerla, porque además genera confianza.

Y el segundo, que es el que más cambia la forma de trabajar: **el test va antes que el fix, y el motivo no es la disciplina.** Un test escrito después pasa desde el primer momento y no hay ninguna evidencia de que habría fallado antes. Verlo en rojo es lo único que demuestra que prueba lo que dice probar — y el par de tags que lo rodea convierte esa evidencia en algo que sigue ahí dentro de seis meses.

**Incidentes del cuaderno que usan esta ruta:** 17 (el intermitente) y 20 (el coverage que no protegió), más el cierre de todos los demás: cada incidente del cuaderno termina con su test de regresión.
**Amplía:** **A11** §7 para lo que caduca de esta suite en Angular 17+, y [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) para el par de tags `-roto` / `-fix`.
EOF
wc -l forense-fase-12.md

# --- 2026-09-07T01:20:31 · Write forense-fase-13
cat > forense-fase-13.md <<'EOF'
# 🕵️ Forense Fase 13 — "En UAT funciona y en PROD no"

> Pieza forense de la **Fase 13 — Build, despliegue y cierre** · Recorrido: ~45 min
> Herramientas: `docker inspect` · `docker exec` · `curl -I` · source maps
> Síntoma que cubre: el ticket que ordena el final del curso, y su hermano — "desplegamos el fix y la gente sigue viendo el error".

Este ticket casi nunca es un bug de código. Es, **por orden de frecuencia**: configuración distinta, caché, versiones distintas creyendo ser la misma, y sólo al final, código. Ir al código primero es lo que convierte una hora en una tarde, y por eso la ruta descarta una capa entera en cada paso.

La fase resume los cuatro pasos. Aquí están los dos tickets literales y la salida de cada uno.

---

## 🎫 Ticket A — el ambiente

> *"En UAT entra bien y en producción la pantalla se queda en blanco. Es el mismo despliegue de esta mañana."*

**Reportado por:** el equipo de soporte · **Ambiente:** PROD · **Es el incidente 19**

## 🎫 Ticket B — el fix que no llegó

> *"Desplegamos el arreglo hace dos horas y la gente sigue viendo el error. A mí me funciona."*

**Reportado por:** tu líder técnico · **Ambiente:** PROD · **Es el incidente 18**

**"A mí me funciona"** es, en este ticket, un dato técnico y no una excusa: significa que quien lo dice tiene el navegador con *Disable cache* puesto desde hace meses.

---

## 🧭 La ruta

### Paso 1 — ¿Es de verdad la misma imagen?

Antes de mirar nada más. Diez segundos, y descarta la capa más grande:

```bash
docker inspect --format '{{.Image}}' certcore-prod certcore-uat
```

```
sha256:9f2c4b1e7a8d3c5f0e6b2a94d17c8e3f5a0b6d2c9e4f1a8b3d7c0e5f2a9b4c1d
sha256:9f2c4b1e7a8d3c5f0e6b2a94d17c8e3f5a0b6d2c9e4f1a8b3d7c0e5f2a9b4c1d
```

**Qué descarta.** Digests idénticos: **es el mismo artefacto**, así que ninguna diferencia de comportamiento puede venir del código. Pasa al 2.

Digests distintos: **no tienes un problema de configuración, tienes dos artefactos distintos**, y la pregunta cambia por completo — quién construyó cuál, desde qué commit, y por qué el pipeline produjo dos.

> ⚠️ **Ésta es la comprobación que la etiqueta `:latest` hace imposible**, y es la mitad de la razón por la que la convención del curso pide etiquetar la imagen con el nombre del tag de git que la produjo. Con `certcore:latest` en los dos ambientes, la pregunta *"¿qué código hay dentro de cada uno?"* no tiene respuesta. Con `certcore:fase-13` y `certcore:hotfix-2026-03-14`, se contesta leyendo. **A09** §2 lo desarrolla.

### Paso 2 — ¿Qué configuración tiene cada uno?

Los dos archivos, uno al lado del otro:

```bash
docker exec certcore-prod cat /usr/share/nginx/html/assets/config.json
docker exec certcore-uat  cat /usr/share/nginx/html/assets/config.json
```

```json
{"apiBaseUrl": "/api", "environmentName": "PROD"}
{"apiBaseUrl": "/api", "environmentName": "UAT"}
```

Y sin entrar al contenedor, que es lo que un equipo de plataforma sí te va a dejar hacer:

```bash
docker logs certcore-prod 2>&1 | grep certcore
# [certcore] configuración de arranque: PROD -> /api
```

**Qué descarta.** El `echo` del `entrypoint.sh` está en los logs exactamente por esto: contesta la pregunta sin `docker exec`, que en un cluster real puede estar prohibido.

Las tres salidas que resuelven el ticket A:

| Lo que ves | Qué pasó |
|---|---|
| El JSON con los valores esperados | la configuración está bien: pasa al 3 |
| El JSON con los valores de **otro** ambiente | la imagen se levantó con las variables equivocadas |
| **No existe el archivo** | el `entrypoint.sh` no corrió → pantalla en blanco garantizada |
| El archivo existe y está vacío o mal formado | corrió y falló a medias |

Los dos últimos son la causa clásica del ticket A, y su mecanismo merece nombrarse: `APP_INITIALIZER` **bloquea el arranque** de la aplicación hasta que resuelve. Si la petición a `assets/config.json` devuelve un `404` o un JSON inválido, la promesa se rechaza, Angular no arranca, y lo que ve el usuario es **una página en blanco sin ningún error visible** — porque el error ocurrió antes de que hubiera dónde pintarlo.

```bash
# Y la causa raíz más tonta de las tres, comprobable en un segundo:
docker exec certcore-prod ls -l /docker-entrypoint.d/
# -rw-r--r--  1 root root  412 40-certcore-config.sh    ← SIN el bit de ejecución
```

Sin `+x`, nginx **ignora el script en silencio**, arranca perfectamente, y sirve la aplicación sin `config.json`. No hay error en ningún log. Es la causa raíz del incidente 19 y es una línea del Dockerfile.

### Paso 3 — ¿Qué llega al navegador? No lo que crees: lo que llega

```bash
# Las cabeceras del index.html.
curl -I http://localhost:8080/
```

```
HTTP/1.1 200 OK
Server: nginx/1.25.3
Content-Type: text/html
Cache-Control: no-store          ← lo que TIENE que decir
```

```
Cache-Control: public, max-age=31536000    ← el incidente 18, completo
```

**Qué descarta.** Si el `index.html` se está cacheando, el ticket B está resuelto: despliegas el fix, el usuario recarga, y **sigue recibiendo el `index.html` de ayer** — que referencia los bundles de ayer, que siguen existiendo porque nadie borra nada. La aplicación vieja funciona perfectamente, y por eso nadie ve ningún error.

```bash
# Y el config.json, tal como lo ve un cliente cualquiera:
curl -s http://localhost:8080/assets/config.json
curl -I http://localhost:8080/assets/config.json | grep -i cache
```

> 🧭 **La regla que cabe en una frase y resuelve toda la política de caché de una SPA: lo que lleva hash en el nombre se cachea para siempre; lo que no lleva hash no se cachea nunca.** Los bundles (`main.8a1f2c.js`) llevan hash: un nombre distinto es un archivo distinto, así que se pueden cachear un año sin riesgo. El `index.html` y el `config.json` **no llevan hash** y cambian en cada despliegue. Equivocarse en el lado del `index.html` produce el bug más frustrante que existe: el que ya arreglaste.

**Y hazlo con `curl`, no con tu navegador.** Tu navegador lleva meses con *Disable cache* puesto y te va a mentir con la mejor intención. Ése es el mecanismo exacto del *"a mí me funciona"* del ticket B.

### Paso 4 — ¿Y la ruta profunda?

Un caso concreto del ticket A que merece su propia comprobación:

```bash
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:8080/inspections/500
# 200 → try_files está puesto
# 404 → falta, y recargar cualquier ruta profunda da 404
```

nginx busca un **archivo** llamado `inspections/500`. No existe: esa ruta sólo vive dentro del router de Angular, en el navegador. `try_files $uri $uri/ /index.html;` es la línea que lo arregla, y el síntoma que produce su ausencia es desconcertante porque **navegar funciona y recargar no**.

### Paso 5 — Y sólo ahora, el código

Si la imagen es la misma, la configuración es la esperada, las cabeceras están bien y las rutas profundas responden, **entonces sí es un bug de la aplicación**. Y lo que tienes es esto:

```
ERROR TypeError: Cannot read properties of null (reading 'validUntil')
    at t.<anonymous> (main.8a1f2c.js:1:48213)
    at Object.next (main.8a1f2c.js:1:12994)
```

Con `sourceMap.hidden: true` en la configuración de producción, el `.map` **se genera y no se sirve**: lo tienes tú, no el usuario. Dos formas de usarlo:

```
1. DevTools → Sources → clic derecho sobre el archivo → "Add source map…"
   y pega la ruta del .map que guardaste al construir.
2. O sirve el dist/ completo en local —con los .map al lado— y reproduce ahí.
```

```
// Y el mismo error, ya traducido:
ERROR TypeError: Cannot read properties of null (reading 'validUntil')
    at CertificateDetailComponent.buildView (certificate-detail.component.ts:74:31)
```

**Qué descarta.** Sin el `.map`, `main.8a1f2c.js:1:48213` es todo lo que vas a tener nunca. Con él, tienes archivo y línea. Es la diferencia entre una investigación de diez minutos y una que no se puede hacer, y es la razón por la que la Fase 13 los genera aunque no los sirva.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Causa | Comprobación |
|---|---|---|
| Digests distintos entre ambientes | dos artefactos, no un problema de config | `docker inspect --format '{{.Image}}'` |
| Pantalla en blanco, sin errores | `APP_INITIALIZER` rechazado | ¿existe `assets/config.json`? |
| `config.json` no existe | el `entrypoint.sh` no corrió | `ls -l /docker-entrypoint.d/` → falta `+x` |
| `config.json` con valores de otro ambiente | variables equivocadas al levantar | `docker logs \| grep certcore` |
| El fix desplegado no llega a los usuarios | `index.html` cacheado | `curl -I` → `Cache-Control` |
| "A mí me funciona" | *Disable cache* en el navegador de quien lo dice | usa `curl`, no el navegador |
| Navegar funciona, recargar da 404 | falta `try_files` | `curl` a una ruta profunda |
| Stack trace ilegible | sin source map cargado | `Add source map…` en Sources |
| El contenedor no arranca en el cluster | probablemente nginx como root | **A09** §8 |

---

## ⚰️ Los callejones

**"Es un bug de código, ya lo estoy mirando."** El callejón que define el ticket, y cuesta tardes. Los pasos 1 a 4 cuestan cinco minutos entre todos y descartan tres capas. Empezar por el paso 5 significa leer código buscando una diferencia que no está ahí.

**"Reconstruimos y volvemos a desplegar."** A veces "arregla" el ticket B —porque el `index.html` nuevo llega con otro momento de caché— y **no arregla nada**: la política de caché sigue mal y el mismo bug vuelve en el siguiente despliegue. Peor aún: enseña al equipo que redesplegar es un procedimiento de diagnóstico.

**"Es la CDN."** Puede ser, y se descarta en el mismo paso 3: si `curl` directo al origen ya devuelve el `Cache-Control` equivocado, la CDN está obedeciendo. Si el origen está bien y la CDN no, entonces sí es de ellos, y ya tienes la evidencia para el ticket.

**"El backend de PROD está devolviendo otra cosa."** Comprobable sin salir de la terminal, y conviene hacerlo antes de acusar a nadie: `curl` al endpoint desde dentro del contenedor de la aplicación, que es exactamente el camino que recorre el navegador a través del `proxy_pass`.

---

## 🧨 Deshacer

Si cambiaste el `nginx.conf` para reproducir el incidente 18 —quitando el `no-store` del `index.html`—, **devuélvelo y reconstruye la imagen**: una imagen con esa política mal puesta es exactamente el bug, y guardada en tu almacén local va a reaparecer en la Fase 14 sin que la relaciones.

```bash
docker rm -f certcore-prod certcore-uat
rm -rf dist/
```

Y si retiraste el `chmod +x` del Dockerfile para el paso 2, lo mismo: sin esa línea la Fase 14 despliega una aplicación sin configuración y el pod arranca perfectamente sirviendo una pantalla en blanco.

---

## 🧠 El patrón transferible

> **"Funciona en UAT y no en PROD" es una descripción de una diferencia, no de un bug.** El trabajo es encontrar cuál, y sólo hay cuatro candidatas: el artefacto, la configuración, la caché y el código. En ese orden, porque las tres primeras se descartan en cinco minutos y la cuarta cuesta una tarde.

Y el segundo, que es el que se lleva al trabajo real: **si no puedes contestar "¿qué código hay dentro de esta imagen?", no puedes investigar nada.** Etiquetar la imagen con el tag de git que la produjo cuesta un guion en la línea de `docker build` y es la mitad barata de cualquier diagnóstico de ambientes. Es la que casi nadie tiene.

**Incidentes del cuaderno que usan esta ruta:** 18 (el fix que no llegó) y 19 (blanco en PROD).
**Amplía:** **A09** §1 y §2 para imágenes, tags y digests, `forense-fase-14.md` para cuando el mismo despliegue vive en un cluster, y el `HOTFIX.md` que escribes en la Fase 13 §5.9, que es donde todo esto se convierte en una página que te llevas.
EOF
wc -l forense-fase-13.md

# --- 2026-09-07T01:21:52 · Write forense-fase-14
cat > forense-fase-14.md <<'EOF'
# 🕵️ Forense Fase 14 — 🔥 "El pod no arranca"

> Pieza forense de la **Fase 14 — Ambiente "casi prod" con kind** · Recorrido: ~40 min
> Herramientas: `kubectl describe` · `kubectl logs --previous` · `crictl images` · `kubectl get events`
> 🔥 **Opcional — esta pieza pertenece a una fase opcional.** Si no hiciste la Fase 14, no la necesitas.
> Síntoma que cubre: una aplicación que funcionaba en un contenedor y no arranca en el cluster, con un estado que no explica nada.

En un contenedor suelto, cuando algo falla, lo ves. En un cluster hay una capa entre tú y el proceso, y esa capa tiene **su propia versión de la historia**. Toda esta pieza es saber a cuál de las dos preguntarle primero.

La fase resume la regla. Aquí están los tickets literales y la salida de cada comando.

---

## 🎫 Ticket A — el que no llega a arrancar

> *"Apliqué el Deployment y el pod dice `ImagePullBackOff`. La imagen existe, la acabo de construir, `docker images` la lista."*

**Reportado por:** tú, la primera vez que usas kind · **Ambiente:** local

## 🎫 Ticket B — el que arranca y se muere

> *"El pod entra en `CrashLoopBackOff` y `kubectl logs` no dice nada útil. `kubectl describe` tampoco explica por qué."*

**Reportado por:** tú, media hora después · **Ambiente:** local, y en un Mac con chip M

---

## 🧭 La regla que ordena la pieza

**`kubectl describe pod` cuenta lo que le pasó al pod desde fuera** — si se pudo planificar, si la imagen se pudo obtener, si el contenedor arrancó, cuántas veces se reinició. Sus **eventos**, al final de la salida, son lo primero que hay que leer.

**`kubectl logs` cuenta lo que dijo el proceso desde dentro.** Existe **sólo si el contenedor llegó a arrancar.**

De ahí sale el orden, y es toda la regla:

> 🧭 **Si el pod nunca llegó a `Running`, empieza por `describe`. Si arrancó y se murió, empieza por `logs --previous`.** Y el estado te dice cuál es cuál.

```bash
kubectl get pods
# NAME                        READY   STATUS             RESTARTS   AGE
# certcore-7d4b8f9c5-x2klm    0/1     ImagePullBackOff   0          45s
```

---

## 🧭 Ruta A — `ImagePullBackOff` con la imagen delante

### Paso 1 — Los eventos, que están al final de `describe`

```bash
kubectl describe pod certcore-7d4b8f9c5-x2klm | tail -12
```

```
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  50s                default-scheduler  Successfully assigned default/certcore-… to certcore-control-plane
  Normal   Pulling    49s                kubelet            Pulling image "certcore:fase-13"
  Warning  Failed     47s                kubelet            Failed to pull image "certcore:fase-13": rpc error: code = NotFound
                                                            desc = failed to pull and unpack image "docker.io/library/certcore:fase-13":
                                                            failed to resolve reference: docker.io/library/certcore:fase-13: not found
  Warning  Failed     47s                kubelet            Error: ErrImagePull
  Normal   BackOff    12s (x3 over 46s)  kubelet            Back-off pulling image "certcore:fase-13"
```

**Qué descarta.** Fíjate en `docker.io/library/certcore:fase-13`. **El kubelet salió a internet a buscarla.** No es que no encuentre la imagen: es que no la encuentra **donde busca**, y busca en un registro público porque no la tiene en su propio almacén.

### Paso 2 — El almacén del nodo no es el tuyo

```bash
# Tu almacén:
docker images | grep certcore
# certcore   fase-13   9f2c4b1e7a8d   2 hours ago   48.3MB

# El del nodo, que es otro contenedor con su propio almacén:
docker exec certcore-control-plane crictl images | grep certcore
# (nada)
```

**Ésa es la explicación entera.** kind corre el cluster **dentro de un contenedor**, con su propio almacén de imágenes, y ese almacén no es el de tu demonio de Docker.

```bash
# La solución, si tienes un demonio de Docker escuchando:
kind load docker-image --name certcore certcore:fase-13

# La universal, que funciona con Podman o con Colima en cualquier configuración,
# porque no depende de quién guarde la imagen sino de un archivo:
docker save certcore:fase-13 -o /tmp/certcore.tar
kind load image-archive --name certcore /tmp/certcore.tar

# Y la comprobación, que es lo que convierte esto en conocimiento:
docker exec certcore-control-plane crictl images | grep certcore
# docker.io/library/certcore   fase-13   9f2c4b1e7a8d   48.3MB
```

### Paso 3 — El `:latest` que empeora el mismo problema

```bash
kubectl get pod certcore-… -o yaml | grep imagePullPolicy
# imagePullPolicy: Always
```

**Nadie escribió esa línea.** Kubernetes usa `IfNotPresent` para tags normales y **`Always` para `:latest`**. Con `certcore:latest`, el nodo intenta descargar la imagen aunque ya la tenga cargada — y en kind, donde no hay registro, eso es `ErrImagePull` **con la imagen delante y cargada**.

Es la causa raíz más desconcertante de esta ruta, y desaparece sola en cuanto la imagen tiene un tag de verdad.

### Paso 4 — Lo mismo, en el cluster de tu empresa

En un cluster real no hay `kind load`. Hay un registro con autenticación, y las tres preguntas son:

1. **¿Está empujada al registro correcto?** — `docker push` y el nombre completo con el host del registro.
2. **¿El nodo llega a ese registro por red?** — políticas de red, proxies, cortafuegos.
3. **¿El namespace tiene el `imagePullSecret`?** — sin él, el kubelet no se puede autenticar y el evento dice `unauthorized`, que es un mensaje distinto del de arriba.

Con esas tres preguntas ya puedes abrir el ticket bien, y eso es lo que esta ruta entrena. **A09** §1 lo desarrolla.

---

## 🧭 Ruta B — `CrashLoopBackOff`

### Paso 1 — El estado ya te dijo por dónde empezar

```bash
kubectl get pods
# NAME                        READY   STATUS             RESTARTS      AGE
# certcore-7d4b8f9c5-x2klm    0/1     CrashLoopBackOff   4 (32s ago)   2m
```

`RESTARTS 4` significa que **arrancó cuatro veces y se murió cuatro veces**. Arrancó: hay logs. Y el cluster está esperando cada vez más entre intentos, que es lo que significa el `BackOff`.

### Paso 2 — `--previous`, que es la mitad del valor de esta pieza

```bash
kubectl logs certcore-7d4b8f9c5-x2klm
```

```
(vacío, o dos líneas de arranque)
```

```bash
kubectl logs certcore-7d4b8f9c5-x2klm --previous
```

```
/docker-entrypoint.sh: /docker-entrypoint.d/40-certcore-config.sh: line 12:
  can't create /usr/share/nginx/html/assets/config.json: Permission denied
nginx: [emerg] bind() to 0.0.0.0:80 failed (13: Permission denied)
```

**Qué descarta.** El primer comando muestra **el intento actual**, que puede llevar dos segundos de vida y no haber llegado todavía al error. El mensaje que buscas está en el anterior, y `--previous` es la única forma de verlo.

Y lo que dice ese log es el cierre del curso: **el contenedor no puede escribir donde escribe ni escuchar en el puerto 80**, porque una política de seguridad lo obliga a correr sin privilegios. Es la 💸 que la Fase 13 dejó abierta, y su arreglo completo —imagen `nginx-unprivileged`, puerto 8080, Deployment y Service ajustados— está en **A09** §8.

### Paso 3 — El caso sin logs, que en un Mac con chip M es casi siempre el mismo

```bash
kubectl logs certcore-… --previous
# (vacío)

kubectl describe pod certcore-… | grep -A3 "Last State"
```

```
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
```

Logs vacíos, código de salida 1, y ninguna explicación. En un Mac con Apple Silicon, **eso es casi siempre una imagen amd64 en un nodo arm64**:

```bash
docker image inspect certcore:fase-13 --format '{{.Architecture}}'
# amd64          ← y tu nodo es arm64
```

El proceso no llega a ejecutarse, así que no escribe nada. Es un segundo de comprobación y descarta la causa más desconcertante del capítulo. El diagnóstico completo está en **A12** §6.

### Paso 4 — Cuando el pod ya se recicló y no queda nada

```bash
# Todos los eventos del namespace, en orden. Cuando no sabes ni qué pod mirar:
kubectl get events --sort-by=.lastTimestamp | tail -20
```

```
2m    Warning   Failed      pod/certcore-…    Error: failed to start container
1m    Normal    Pulled      pod/certcore-…    Container image already present on machine
58s   Warning   BackOff     pod/certcore-…    Back-off restarting failed container
```

Y el recurso final, cuando el contenedor se muere antes de que puedas escribir nada dentro:

```bash
# Sustituye el arranque por un `sleep` y te deja una shell dentro de una imagen
# que de otro modo no dura lo suficiente para investigarla.
kubectl run debug --rm -it --image=certcore:fase-13 --command -- sh
```

> ⚠️ **Los logs de un pod borrado no existen.** Si el Deployment lo recrea, el anterior se fue y sus logs con él. En un cluster real eso lo resuelve un agregador —Loki, ELK, CloudWatch, el que tenga tu empresa— y **preguntar cuál es** debería ser de las primeras cosas que hagas al llegar a un equipo. Sin agregador, cada diagnóstico es una carrera contra el reinicio.

---

## 🩺 Diagnóstico por síntoma

| Estado | Qué significa | Por dónde empiezas |
|---|---|---|
| `Pending` | el cluster no lo ha colocado | `describe`: recursos o restricciones |
| `ContainerCreating` (más de un minuto) | bajando imagen o montando volúmenes | `describe` |
| `ErrImagePull` / `ImagePullBackOff` | no consiguió la imagen | ruta A |
| `ImagePullBackOff` con `imagePullPolicy: Always` | es el `:latest` | ruta A, paso 3 |
| `Running` con `READY 0/1` | arrancó y su probe no pasa | el endpoint de la probe |
| `CrashLoopBackOff` con logs | arrancó y se murió | `logs --previous` |
| `CrashLoopBackOff` **sin** logs, en Mac M | arquitectura de la imagen | `docker image inspect --format '{{.Architecture}}'` |
| `Permission denied` en el 80 o en `html/` | no puede correr como root | **A09** §8 |
| `Completed` en un Deployment | tu proceso no se queda vivo | el `CMD` de la imagen |
| El ConfigMap cambió y el pod no | se lee al arrancar | `kubectl rollout restart` |

---

## ⚰️ Los callejones

**"La imagen no existe."** Existe: `docker images` la lista. Lo que no existe es **en el almacén del nodo**, y son dos almacenes distintos. Confundirlos es el tropiezo universal de kind, y la frase que lo resuelve es la de la fase: *una imagen que existe en tu máquina no existe en ningún otro sitio hasta que alguien la mueve.*

**"Es un problema del manifiesto."** Casi nunca cuando el pod llegó a crearse: un manifiesto mal formado falla en el `kubectl apply`, no después. Si el pod existe y está en `CrashLoopBackOff`, el manifiesto era válido y el problema es del contenedor.

**"Voy a borrar el pod para que se reinicie limpio."** Es la reacción natural y **destruye la evidencia**: con el pod se van sus logs anteriores, que son exactamente lo que ibas a leer con `--previous`. Lee primero, borra después. Y si el Deployment lo va a recrear igual, borrarlo no cambia nada más que tu capacidad de investigar.

**"En Docker funcionaba."** Es un dato valiosísimo, no un callejón: significa que la imagen es correcta y que lo que cambió es el **entorno de ejecución** — la política de seguridad, el usuario, el sistema de archivos de sólo lectura, los recursos. Todo eso vive en el manifiesto, no en la imagen.

---

## 🧨 Deshacer

```bash
# Lo aplicado en el cluster:
kubectl delete -f k8s/

# Y el cluster entero, si quieres empezar de cero:
kind delete cluster --name certcore
```

Si probaste el paso 3 de la ruta A etiquetando la imagen como `:latest`, **quítala** (`docker rmi certcore:latest`): una imagen `:latest` en tu almacén va a reaparecer en la siguiente investigación con el mismo `imagePullPolicy` puesto y sin que la relaciones.

Y el `/tmp/certcore.tar` del `docker save`, si lo generaste.

---

## 🧠 El patrón transferible

> **En un cluster hay dos narradores y cuentan cosas distintas.** `describe` cuenta lo que el cluster hizo con tu pod; `logs` cuenta lo que tu proceso dijo. Preguntarle al equivocado es la mitad del tiempo perdido en Kubernetes, y el estado del pod te dice cuál es cuál sin ambigüedad.

Y el segundo, que es el que vale fuera de este curso: **`--previous` no es una bandera avanzada, es la bandera por defecto de cualquier `CrashLoopBackOff`.** El intento que estás mirando todavía no ha fallado; el que te lo va a explicar ya murió. Quien no conoce esa bandera concluye que "los logs no dicen nada" y se pone a adivinar.

**Incidentes del cuaderno que usan esta ruta:** ninguno directamente — la Fase 14 es opcional y el cuaderno no depende de ella. Pero el ticket B es el final del hilo que empieza en el incidente 19.
**Amplía:** **A09** §5 a §8 para la caja de herramientas, los estados de pod y la advertencia sobre el cluster real, **A12** §6 para el diagnóstico por síntoma en Apple Silicon, y `forense-fase-13.md` para cuando el mismo despliegue vive en un contenedor suelto.
EOF
wc -l forense-fase-14.md; ls forense*.md | wc -l

# --- 2026-09-07T01:22:02 · Final verification of forensic track
echo "ARCHIVO                       LIN  PASOS  DESCARTA  CALLEJ  DESHACER"; for f in forense-fase-*.md; do printf "%-28s %4s %6s %9s %7s %9s\n" "$f" "$(wc -l < $f)" "$(grep -c '^### Paso\|^### Sospechoso\|^### Rama' $f)" "$(grep -c '\*\*Qué descarta' $f)" "$(grep -c '## ⚰️ Los callejones' $f)" "$(grep -c '## 🧨 Deshacer' $f)"; done; echo; echo "--- enlaces .md rotos? ---"; grep -hoE '\]\([a-z0-9][^)]*\.md\)' forense*.md | sort -u | tr -d '](' | while read x; do [ -f "$x" ] && echo "OK  $x" || echo "ROTO $x"; done; echo; echo "--- promesas 📄 vs archivos ---"; for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do [ -f "forense-fase-$n.md" ] || echo "FALTA $n"; done; echo "todas presentes"

# --- 2026-09-07T01:22:12 · Verify links properly
grep -hoE '\]\([a-z0-9][^)]*\.md\)' forense*.md | sed 's/^](//;s/)$//' | sort -u | while read x; do [ -f "$x" ] && echo "OK   $x" || echo "ROTO $x"; done

# --- 2026-09-07T01:22:31 · Add discard labels to fase-03 branches
python3 - <<'PY'
import pathlib
f = pathlib.Path('forense-fase-03.md')
t = f.read_text()

subs = [
("**Reproducir a voluntad:** `CHAOS=cors npm run mock`.",
 "**Qué descarta.** Con `status: 0` confirmado, quedan descartados de golpe todos los fallos que sí llegaron a contestar: no es un `500`, no es `malformed`, no es un token vencido. Lo que queda son tres causas —CORS, servidor caído, red ausente— y el `curl` de arriba las separa en dos grupos.\n\n**Reproducir a voluntad:** `CHAOS=cors npm run mock`."),

("**Reproducir a voluntad:** `CHAOS=timeout npm run mock`.",
 "**Qué descarta.** Sin error y sin respuesta queda descartado todo lo demás: cualquier otro fallo de los seis produce **algo** —un status, un cuerpo, una excepción—. Si no hay nada que capturar, el sospechoso es uno solo. Y descarta también tu `catchError`: no está fallando, es que nunca se le llamó.\n\n**Reproducir a voluntad:** `CHAOS=timeout npm run mock`."),

("**Reproducir a voluntad:** `CHAOS=malformed CHAOS_RATE=1 npm run mock`.",
 "**Qué descarta.** Un `200` con el cuerpo cambiado descarta la red entera: la petición salió, llegó y volvió. A partir de aquí el problema está en el **contenido**, y por tanto en el borde HTTP de tu aplicación o en el servidor — nunca en el componente, que está haciendo lo correcto con un dato equivocado.\n\n**Reproducir a voluntad:** `CHAOS=malformed CHAOS_RATE=1 npm run mock`."),

("**Reproducir a voluntad:** `CHAOS=latency npm run mock`, con `CHAOS_DELAY_MS` para ajustar.",
 "**Qué descarta.** Que el retraso esté concentrado en `Waiting (TTFB)` descarta la red y el navegador: los bytes viajaron rápido y el servidor tardó en empezar a contestar. Si el alto fuera `Content Download`, el sospechoso sería el tamaño del cuerpo; si fuera `Stalled`, el límite de conexiones simultáneas. Tres filas, tres investigaciones distintas.\n\n**Reproducir a voluntad:** `CHAOS=latency npm run mock`, con `CHAOS_DELAY_MS` para ajustar."),
]
for old, new in subs:
    assert old in t, old[:40]
    t = t.replace(old, new, 1)
f.write_text(t)
print("ok")
PY
printf "%-28s %4s %6s %9s\n" "$(echo forense-fase-03.md)" "$(wc -l < forense-fase-03.md)" "$(grep -c '^### ' forense-fase-03.md)" "$(grep -c '\*\*Qué descarta' forense-fase-03.md)"

# --- 2026-09-07T01:24:52 · Write notebook header, method and index
cat > cuaderno-incidentes.md <<'EOF'
# 📓 Cuaderno de incidentes — CertCore

> Tutorial Angular 16 — Inspecciones y certificaciones · **20 incidentes · 14 horas**
> ≈3.5h por semana, repartidas a lo largo del mes que dura el curso

Veinte tickets como los que llegan de verdad: vagos, escritos por alguien que no sabe qué es un resolver, y a veces describiendo dos problemas distintos como si fueran uno. Tu trabajo es convertirlos en un diagnóstico.

> 🧭 **El trato.** Cada incidente trae su solución de referencia, plegada al final. Está ahí porque trabajas sin instructor y necesitas saber si acertaste. **Abrirla antes de escribir la tuya no te ahorra tiempo: te ahorra el ejercicio**, que es lo único que estabas comprando. Lo mismo con las tres pistas: son un plan de rescate, no un atajo.

---

## 🧭 Cómo se trabaja un incidente

### El método, en cuatro preguntas

Son las mismas del track forense y van siempre en este orden, porque cada una cuesta un orden de magnitud más que la anterior:

1. **¿Se reproduce, y con qué?** — con un flag, con un dato, o hace falta otro código. Las tres respuestas llevan a investigaciones distintas.
2. **¿Qué dice la evidencia observable, antes que el código?** — la URL de una petición, el cuerpo crudo, el estado de un control, el paréntesis de un error.
3. **¿En qué capa está?** — plantilla, componente, servicio de estado, API, interceptor, guard, mock, build, contenedor.
4. **¿De qué generación es el archivo que voy a tocar?** 🧬 — porque el parche mínimo se escribe **en el estilo del archivo que tocas**, aunque sea el estilo viejo.

El índice de síntomas que cruza *"esto es lo que veo"* con *"esta es la ruta"* está en [`forense-master.md`](forense-master.md) §3. Empieza ahí cuando no sepas ni de qué fase es tu problema.

### Las tres formas de tener el sistema roto

Cada incidente dice cuál usa en su bloque **🔧 Preparación**. El orden no es casual: **se usa siempre la más barata que sirva**, porque una preparación complicada es una excusa para saltarse el incidente.

**1 · Un flag del inyector de caos** (Fase 3), cuando el fallo es de red o de respuesta. Es la preferida: no toca tu código, no toca tus datos, y se apaga sola al reiniciar el mock.

```bash
CHAOS=malformed npm run mock
```

**2 · Un `db.json` alterno**, cuando el bug está en el dato y no en el código.

```bash
cp mock/db.incidente-09.json mock/db.json    # guarda el tuyo antes, o corre npm run seed después
```

**3 · Una rama de git**, y sólo cuando haya que romper código. Sale del tag de la fase correspondiente, así que se crea sin buscar nada:

```bash
git switch -c incidente/08 fase-07
# …y el commit de la rama trae el cambio mínimo que produce el síntoma
```

> 🧭 **La regla, y sirve más allá de este cuaderno:** cuando alguien te pida reproducir un bug, la primera pregunta es *"¿esto se reproduce con un flag, con un dato, o hace falta otro código?"*. Averiguarlo te ahorra la mitad del camino antes de leer una línea.

### La convención de commits

El asunto sigue este formato, para que `git log --oneline` se lea como la línea de tiempo de la investigación:

```
incidente(08): abre — la inspección de agosto tiene un ítem más
incidente(08): repro — sólo pasa con inspecciones anteriores a 2024
incidente(08): hipótesis descartada — no es el editor, la v1 sigue intacta en db
incidente(08): causa — el detalle resuelve por fecha y no por versión guardada
incidente(08): fix — leer templateVersion de la inspección
incidente(08): cierre — test de regresión y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`, `causa`, `fix`, `cierre`.

**Commitea también los callejones sin salida.** Un `git log` con seis commits de investigación y uno de fix es un registro honesto; uno que muestra sólo el fix no le sirve a nadie, y menos a ti dentro de seis meses.

Y como el fix de casi todos estos incidentes es de una o dos líneas, márcalo con el par de tags de [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md):

```bash
git tag -a inc/08/version-ejecutada-roto -m "F7 inc08: el test reproduce el bug y falla"
# …el fix…
git tag -a inc/08/version-ejecutada-fix  -m "F7 inc08: causa raíz y fix, con el test en verde"

git diff inc/08/version-ejecutada-roto inc/08/version-ejecutada-fix   # ← el post-mortem, sin ruido
git tag -n99 -l 'inc/*'                                              # ← el cuaderno entero, sin abrir un archivo
```

> 💡 Para releer la historia de un incidente: `git log --oneline --grep "incidente(08)"`

**Regla del archivo: se agrega, no se corrige.** Una hipótesis que resultó falsa no se borra: se marca como descartada, con la evidencia que la tumbó.

### Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y test de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 📋 Índice

Actualiza la columna **Estado** en el mismo commit que abre o cierra cada incidente.

### Semana 1 · Fases 0-4

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [01](#incidente-01--cloné-el-repo-hice-npm-install-y-ng-serve-no-arranca) | 0 | "Cloné el repo, hice npm install y `ng serve` no arranca" | Despliegue | 🟢 | ⬜ |
| [02](#incidente-02--agregué-la-pantalla-de-activos-la-ruta-funciona-pero-sale-en-blanco) | 1 | "Agregué la pantalla de activos, la ruta funciona pero sale en blanco" | UI | 🟢 | ⬜ |
| [03](#incidente-03--entro-con-mi-usuario-y-me-saca-al-login-sin-decir-nada) | 2 | "Entro con mi usuario y me saca al login sin decir nada" | Integración | 🟢 | ⬜ |
| [04](#incidente-04--la-pantalla-de-plantillas-a-veces-carga-y-a-veces-se-queda-pensando) | 3 | "La pantalla de plantillas a veces carga y a veces se queda pensando" | Integración | 🟢 | ⬜ |
| [05](#incidente-05--entro-a-plantillas-y-dice-que-no-hay-ninguna-pero-en-el-mock-están-las-tres) | 4 | "Entro a Plantillas y dice que no hay ninguna, pero en el mock están las tres" | Estado (servicios) | 🟢 | ⬜ |

### Semana 2 · Fases 5-8

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [06](#incidente-06--el-botón-de-nuevo-cliente-se-ve-gris-y-plano-desde-el-martes-pero-todo-compila) | 5 | "El botón de Nuevo cliente se ve gris y plano desde el martes, pero todo compila" | Convivencia 🧬 | 🟡 | ⬜ |
| [07](#incidente-07--metí-el-listado-de-clientes-en-el-panel-y-la-pantalla-se-queda-en-blanco) | 5 | "Metí el listado de clientes en el panel y la pantalla se queda en blanco" | Convivencia 🧬 | 🟡 | ⬜ |
| [08](#incidente-08--la-inspección-de-agosto-ahora-tiene-un-ítem-más-que-cuando-la-hice) | 7 | "La inspección de agosto ahora tiene un ítem más que cuando la hice" | Versionado normativo | 🟡 | ⬜ |
| [09](#incidente-09--publiqué-la-v3-y-el-sistema-dice-que-hay-dos-plantillas-vigentes) | 7 | "Publiqué la v3 y el sistema dice que hay dos plantillas vigentes" | Versionado normativo | 🟠 | ⬜ |
| [10](#incidente-10--cambié-de-inspección-desde-el-listado-y-me-aparecieron-ítems-de-la-otra) | 8 | "Cambié de inspección desde el listado y me aparecieron ítems de la otra" | Versionado normativo | 🟠 | ⬜ |
| [11](#incidente-11--escribo-una-letra-y-la-aplicación-se-queda-pegada-el-ventilador-se-dispara) | 8 | "Escribo una letra y la aplicación se queda pegada; el ventilador se dispara" | Formularios dinámicos | 🟠 | ⬜ |

### Semana 3 · Fases 9-11

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [12](#incidente-12--aprobé-la-inspección-y-el-sistema-me-dejó-pero-el-cable-está-para-cambiar) | 9 | "Aprobé la inspección y el sistema me dejó, pero el cable está para cambiar" | Tipos (strict) | 🟠 | ⬜ |
| [13](#incidente-13--el-supervisor-subió-la-severidad-de-un-hallazgo-y-al-día-siguiente-había-vuelto-a-bajar) | 9 | "El supervisor subió la severidad de un hallazgo y al día siguiente había vuelto a bajar" | Tipos (strict) | 🟠 | ⬜ |
| [14](#incidente-14--descargué-el-certificado-y-la-tabla-de-hallazgos-no-dice-lo-mismo-que-la-pantalla) | 10 | "Descargué el certificado y la tabla de hallazgos no dice lo mismo que la pantalla" | Trazabilidad | 🟠 | ⬜ |
| [15](#incidente-15--el-certificado-venció-ayer-para-el-sistema-y-hoy-para-el-cliente-y-sólo-pasa-por-la-tarde) | 10 | "El certificado venció ayer para el sistema y hoy para el cliente, y sólo pasa por la tarde" | Tiempo | 🔴 | ⬜ |
| [16](#incidente-16--cerré-el-panel-hace-media-hora-y-el-servidor-sigue-recibiendo-peticiones-mías) | 11 | "Cerré el panel hace media hora y el servidor sigue recibiendo peticiones mías" | Performance | 🟠 | ⬜ |

### Semana 4 · Fases 12-13

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [17](#incidente-17--el-test-pasa-en-mi-máquina-y-falla-en-el-pipeline-y-nadie-tocó-nada) | 12 | "El test pasa en mi máquina y falla en el pipeline, y nadie tocó nada" | Testing | 🔴 | ⬜ |
| [18](#incidente-18--desplegamos-el-arreglo-hace-dos-horas-y-la-gente-sigue-viendo-el-error-a-mí-me-funciona) | 13 | "Desplegamos el arreglo hace dos horas y la gente sigue viendo el error; a mí me funciona" | Despliegue | 🔴 | ⬜ |
| [19](#incidente-19--en-uat-entra-bien-y-en-producción-la-pantalla-se-queda-en-blanco) | 13 | "En UAT entra bien y en producción la pantalla se queda en blanco" | Despliegue | 🔴 | ⬜ |
| [20](#incidente-20--tenemos-82--de-coverage-y-el-bug-llegó-a-producción-igual) | 12 | "Tenemos 82 % de coverage y el bug llegó a producción igual" | Testing | 🔴 | ⬜ |

**Reparto:** 3 de versionado de plantillas (08, 09, 10), 2 de convivencia de estilos 🧬 (06, 07) y 2 de tipos bajo `strict` (12, 13). **Los IDs son globales y no se reasignan nunca**, aunque un incidente se retire.

---
EOF
wc -l cuaderno-incidentes.md

# --- 2026-09-07T01:27:48 · Write incidents 01-05
cat >> cuaderno-incidentes.md <<'EOF'
## 🧪 Incidentes

---

## Incidente 01 — "Cloné el repo, hice npm install y `ng serve` no arranca"

> **Fase:** 0 · **Categoría:** Despliegue · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-30 min

### 🎫 El ticket

> *"Me pasaron el repo para que ayude con un hotfix. Cloné, hice `npm install` como siempre, y `ng serve` se cae con un error larguísimo de TypeScript. A mi compañero le funciona con el mismo repo."*

**Reportado por:** un desarrollador que se incorpora al equipo
**Ambiente:** local

### 🎯 Qué se te pide

Reproducir, explicar por qué a uno le funciona y al otro no con el mismo repositorio, y aplicar el arreglo que impide que vuelva a pasarle al siguiente que llegue.

### 🔧 Preparación

Una rama, porque hay que romper el `package.json` — que es código.

```bash
git switch -c incidente/01 fase-00
# La rama cambia una línea del package.json. Después:
rm -rf node_modules package-lock.json
npm install
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

El error no está en tu código: ninguno de los archivos que menciona es tuyo. Antes de leerlo entero, pregúntate qué tienes tú instalado que tu compañero no — y la herramienta que contesta eso no es el editor.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`npm ls typescript` y `npm ls @angular/core`. Compara los dos números con la tabla de versiones de `alcance-del-proyecto.md` §9. Después mira **cómo** están escritos en el `package.json`, que es distinto de qué versión hay instalada.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué diferencia hay entre `"typescript": "5.1.6"` y `"typescript": "^5.1.6"` el día que se publica la 5.4, y por qué tu compañero —que instaló hace tres meses y no ha vuelto a borrar `node_modules`— no lo nota?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`package.json`, línea de `devDependencies`: `"typescript": "^5.1.6"` en vez de `"typescript": "5.1.6"`. El acento circunflejo admite cualquier versión menor por encima, y Angular 16.2.12 sólo soporta TypeScript `>=4.9.3 <5.2.0`. El error literal es:

```
Error: The Angular Compiler requires TypeScript >=4.9.3 and <5.2.0 but 5.4.5 was found instead.
```

A tu compañero le funciona porque **su `node_modules` es de hace tres meses**, cuando la 5.2 todavía no existía. Los dos tienen el mismo `package.json` y árboles distintos: eso es exactamente lo que un lockfile existe para impedir, y aquí el `npm install` lo reescribió.

**Parche mínimo**

```jsonc
// package.json — el hotfix de un viernes
{
  "devDependencies": {
    "typescript": "5.1.6"
  }
}
```

```bash
rm -rf node_modules package-lock.json
npm install
git add package.json package-lock.json    # el lockfile va en el mismo commit
```

**La refactorización correcta**

Fijar la versión no impide que el siguiente que llegue lo haga con otro Node. Las dos líneas que sí lo impiden:

```jsonc
// package.json
{
  "engines": { "node": "18.18.2", "npm": "9.8.1" }
}
```

```bash
# .npmrc en la raíz. Sin esto, `engines` es decorativo: npm lo lee, no coincide,
# se encoge de hombros y sigue.
echo "engine-strict=true" > .npmrc
```

Y el cambio de hábito, que es el de verdad: **`npm ci` al clonar y al cambiar de rama; `npm install` sólo cuando añades una dependencia a propósito.** El detalle está en el **Apéndice A03** §2.

**Prueba de regresión**

Aquí no hay un `.spec.ts` que valga: lo que hay que verificar es la cadena de herramientas, y eso se comprueba antes de compilar.

```js
// scripts/check-toolchain.mjs
// Falla el arranque si el árbol instalado no es el que el proyecto fija.
// Corre antes de `ng serve` y antes de `ng build`, así que el error llega
// con un mensaje en español en vez de con un stack del compilador.
import { readFileSync } from 'node:fs';

const EXPECTED = { typescript: '5.1.6', '@angular/core': '16.2.12', rxjs: '7.8.1' };

const failures = Object.entries(EXPECTED).flatMap(([name, expected]) => {
  const installed = JSON.parse(
    readFileSync(`node_modules/${name}/package.json`, 'utf8'),
  ).version;

  return installed === expected ? [] : [`${name}: se esperaba ${expected} y hay ${installed}`];
});

if (failures.length > 0) {
  console.error('❌ El árbol de dependencias no es el del proyecto:');
  failures.forEach((failure) => console.error(`   ${failure}`));
  console.error('   Corre `npm ci` en vez de `npm install`. Ver el apéndice A03.');
  process.exit(1);
}
```

```jsonc
// package.json
{
  "scripts": {
    "check:toolchain": "node scripts/check-toolchain.mjs",
    "start": "npm run check:toolchain && ng serve",
    "build": "npm run check:toolchain && ng build"
  }
}
```

**Prevención**

El script de arriba, más `engine-strict=true`, más `npm ci` en el `Dockerfile` de la **Fase 13** — que ya lo tiene, y por esta razón exacta.

**Por qué llegó a producción**

Nadie lo desplegó: llegó a la máquina de alguien nuevo, que es donde este bug se cobra. El sistema lo permitió por dos decisiones separadas y ninguna descabellada: el proyecto arrancó con los rangos que genera el CLI, y el equipo se acostumbró a `npm install` porque durante dos años nunca dio problemas. El fallo aparece **sólo cuando alguien instala desde cero**, y en un equipo estable eso pasa una vez cada muchos meses — el tiempo justo para que nadie recuerde el anterior.

**Si tu causa fue distinta a esta**

Si concluiste "hay que actualizar Angular a una versión que soporte TS 5.4", el síntoma también encaja y el remedio es una migración no planificada disfrazada de arreglo. Si concluiste "es la versión de Node", es una hipótesis excelente y se descarta en un comando: `node -v` da lo mismo en las dos máquinas. Y si tu fix fue `--legacy-peer-deps`, taparías otra clase de error: aquí no hay ningún conflicto de peers, hay un rango que resolvió a algo incompatible.

</details>

---

## Incidente 02 — "Agregué la pantalla de activos, la ruta funciona pero sale en blanco"

> **Fase:** 1 · **Categoría:** UI · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 25-40 min

### 🎫 El ticket

> *"Copié la estructura de la pantalla de plantillas para hacer la de activos. La URL cambia a `/assets`, el menú se marca, y donde debería estar la tabla no hay nada. No sale nada rojo por ningún lado."*

**Reportado por:** un compañero del equipo
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Localizar en qué punto se rompe la cadena entre la ruta y el componente, y aplicar el fix. **No hay error en consola**, así que el entregable incluye explicar por qué no lo hay.

### 🔧 Preparación

```bash
git switch -c incidente/02 fase-01
npm start
# Entra a /assets
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Hay dos preguntas que parecen la misma y no lo son: *"¿el componente no se ve?"* y *"¿el componente no existe?"*. Contesta primero la segunda; se hace en una línea de consola y decide todo lo demás.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

En la pestaña Network, con el filtro en `JS` y *Disable cache* activado, mira si al navegar a `/assets` se descarga un chunk nuevo. Después, en la consola: `ng.getComponent(document.querySelector('cc-asset-list'))`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El chunk carga y el componente existe. Entonces la ruta hija se activó y el componente se construyó. ¿Dónde tenía que pintarse?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/app/features/assets/assets.component.html`: el componente contenedor de la feature no tiene `<router-outlet>`. La ruta hija se activa, Angular construye `AssetListComponent`, y no hay dónde pintarlo. **No hay error porque no hay nada mal**: el router hizo su trabajo y nadie pidió el resultado.

Es el mismo mecanismo que hace que un `<ng-template>` sin `ngTemplateOutlet` no muestre nada. El componente existe, y por eso `ng.getComponent()` lo devuelve.

**Parche mínimo**

```html
<!-- src/app/features/assets/assets.component.html -->
<h2>Activos</h2>

<!-- Sin esto, las rutas hijas se activan y no se pintan. Es el error que menos
     ruido hace de toda la Fase 1: no da excepción, no ensucia la consola, y el
     componente sí existe en memoria. -->
<router-outlet></router-outlet>
```

**La refactorización correcta**

Ninguna: el parche **es** el arreglo. Lo que sí conviene revisar de paso —y en otro commit— es si el resto de features tienen el suyo:

```bash
# Todo módulo de feature con rutas hijas necesita su outlet.
grep -rLn "router-outlet" src/app/features/*/[a-z]*.component.html
```

**Prueba de regresión**

```ts
// src/app/features/assets/assets.component.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { By } from '@angular/platform-browser';
import { RouterOutlet } from '@angular/router';

import { AssetsComponent } from './assets.component';

describe('AssetsComponent', () => {
  let fixture: ComponentFixture<AssetsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [AssetsComponent],
      // El outlet real, no un stub: lo que se prueba es que EXISTA.
      imports: [RouterOutlet],
    }).compileComponents();

    fixture = TestBed.createComponent(AssetsComponent);
    fixture.detectChanges();
  });

  it('tiene un router-outlet donde pintar sus rutas hijas', () => {
    // Falla antes del fix: query devuelve null y el mensaje lo dice claro.
    expect(fixture.debugElement.query(By.directive(RouterOutlet)))
      .withContext('el contenedor de la feature necesita <router-outlet>')
      .not.toBeNull();
  });
});
```

**Prevención**

El test de arriba, replicado en cada contenedor de feature. Es de los pocos tests de plantilla que valen la pena: comprueba una decisión estructural que se olvida al copiar y pegar, y su fallo tiene un mensaje que se entiende sin abrir el archivo.

**Por qué llegó a producción**

Nunca llegó: se cazó en desarrollo, que es donde se cazan los errores que no producen síntomas en el servidor. Lo que sí conviene mirar es **cómo se llegó a escribir**: copiando la estructura de otra feature y omitiendo un archivo. La plantilla de la feature de plantillas sí lo tiene; la de activos se creó a mano. Un schematic propio del proyecto —`ng generate` con un template de feature— habría evitado la clase entera.

**Si tu causa fue distinta a esta**

`RouterModule.forRoot()` en vez de `forChild()` en el módulo de feature produce **exactamente el mismo síntoma**, también sin error, y es la otra causa de esta familia. Si ésa fue tu hipótesis, compruébala: `grep -n "forRoot" src/app/features/`. Si concluiste que el componente no estaba declarado, el síntoma habría sido `NG0304` en la terminal de `ng serve` — la ausencia de ese mensaje es lo que descarta esa rama.

</details>

---

## Incidente 03 — "Entro con mi usuario y me saca al login sin decir nada"

> **Fase:** 2 · **Categoría:** Integración · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-40 min

### 🎫 El ticket

> *"Entro con mi correo y mi clave, veo el listado un segundo, y me devuelve a la pantalla de inicio de sesión. No dice nada. Pensé que era mi clave y la cambié, y sigue igual."*

**Reportado por:** inspector de campo
**Ambiente:** UAT

### 🎯 Qué se te pide

Determinar **quién** lo está echando —el guard o el interceptor— y aplicar el hotfix que hace que el usuario sepa qué pasó. La causa de fondo puede no ser tuya; el silencio sí lo es.

### 🔧 Preparación

Un flag: el fallo es de red y no hace falta tocar nada.

```bash
CHAOS=expired npm run mock
# Y en otra terminal, la aplicación como siempre:
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Hay tres piezas que pueden echarte y las tres producen el mismo síntoma en pantalla. La evidencia que las separa está en Network, no en el código — y necesitas *Preserve log* activado, porque la redirección borra el registro.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

¿Hubo o no hubo una petición fallida antes de la redirección? Sin ninguna petición en rojo, fue el guard. Con un `401` en rojo, fue el interceptor. Son dos causas que no se parecen en nada.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El interceptor hace tres cosas al recibir un `401`: cierra la sesión, navega al login y relanza el error. ¿Cuál de las tres es la que el usuario tendría que percibir, y cuál falta?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Dos capas, y conviene separarlas porque el arreglo de cada una es de un equipo distinto.

**La causa técnica** es del servidor: con `CHAOS=expired`, `/auth/login` devuelve un token cuyo `exp` ya pasó. La primera petición protegida responde `401`, el `authInterceptor` la caza y hace lo que debe.

**La causa del ticket** es del frontend, y es una omisión: `authInterceptor` cierra la sesión, navega al login y relanza el error, **y no le dice nada al usuario**. Desde la silla del inspector, la aplicación lo expulsó sin motivo — y por eso cambió su contraseña, que es tiempo perdido de dos personas.

```ts
// src/app/core/interceptors/auth.interceptor.ts — lo que hay
if (error instanceof HttpErrorResponse && error.status === 401 && !isLoginRequest) {
  authService.logout();
  void router.navigate(['/login'], { queryParams: { returnUrl: router.url } });
}
```

**Parche mínimo**

El archivo es **nuevo** (funcional, con `inject()`), así que el parche se escribe en ese estilo:

```ts
// src/app/core/interceptors/auth.interceptor.ts
export const authInterceptor: HttpInterceptorFn = (request, next) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  // Se inyecta ARRIBA: dentro del catchError ya no hay contexto de inyección.
  const snackBar = inject(MatSnackBar);

  // …

  return next(authorizedRequest).pipe(
    catchError((error: unknown) => {
      if (error instanceof HttpErrorResponse && error.status === 401 && !isLoginRequest) {
        authService.logout();
        // Seis segundos y con botón: un aviso de error que se va en dos es un
        // error que nadie vio. Ver el apéndice A01 §6.
        snackBar.open('Tu sesión caducó. Vuelve a entrar.', 'Cerrar', { duration: 6000 });
        void router.navigate(['/login'], { queryParams: { returnUrl: router.url } });
      }

      return throwError(() => error);
    }),
  );
};
```

**La refactorización correcta**

El interceptor no debería saber de `MatSnackBar`: mezcla una decisión de infraestructura con una de interfaz. Con calma, el interceptor emite un evento de sesión —un `Subject` en `AuthService`— y el `ShellComponent` decide cómo mostrarlo. Eso además permite probar el interceptor sin Material y hace que el día que el aviso tenga que ser un diálogo, se cambie en un sitio.

Y la causa de fondo, que no es del frontend: un token que nace vencido es un reloj desajustado entre el emisor y el verificador. Eso se lleva al equipo de backend con la evidencia del `exp` decodificado, no se parchea en el cliente.

**Prueba de regresión**

```ts
// src/app/core/interceptors/auth.interceptor.spec.ts
it('avisa al usuario cuando la sesión caduca', () => {
  const snackBar = TestBed.inject(MatSnackBar);
  const openSpy = spyOn(snackBar, 'open');

  httpClient.get('/templates').subscribe({ error: () => undefined });
  httpMock.expectOne('/templates').flush(null, { status: 401, statusText: 'Unauthorized' });

  // Falla antes del fix: el interceptor cerraba sesión en silencio.
  expect(openSpy).toHaveBeenCalledWith(
    'Tu sesión caducó. Vuelve a entrar.',
    'Cerrar',
    jasmine.objectContaining({ duration: 6000 }),
  );
});

it('NO avisa cuando el 401 es del propio login', () => {
  const openSpy = spyOn(TestBed.inject(MatSnackBar), 'open');

  httpClient.post('/auth/login', {}).subscribe({ error: () => undefined });
  httpMock.expectOne('/auth/login').flush(null, { status: 401, statusText: 'Unauthorized' });

  // Un 401 en el login significa "te equivocaste de contraseña", no "caducó
  // tu sesión". Sin esta distinción, cada intento fallido provoca un logout
  // y una redirección a /login desde /login: el bucle de parpadeo.
  expect(openSpy).not.toHaveBeenCalled();
});
```

**Prevención**

Los dos tests de arriba, y una regla de revisión que vale para cualquier interceptor: **si una pieza puede cambiar lo que el usuario ve, tiene que poder decírselo.** Un `logout()` silencioso, un reintento silencioso y un error tragado son la misma familia.

**Por qué llegó a producción**

El interceptor se escribió durante la migración de 2024 junto con el manejo del `401`, y en ese momento la única forma de perder la sesión era dejar la pestaña abierta toda la noche — un caso en el que "te devolvió al login" se entiende solo. El TTL corto llegó después, con otra decisión de otro equipo, y nadie volvió sobre el interceptor. **No es un descuido: es una decisión que dejó de ser correcta cuando cambió su contexto**, y ninguna revisión de código lo habría detectado porque el archivo no cambió.

**Si tu causa fue distinta a esta**

Si concluiste que fue el guard, comprueba Network: sin ninguna petición en rojo tendrías razón, y la causa sería el `exp` leído en milisegundos en vez de en segundos. Si concluiste que el bug es del backend, tienes razón **a medias** y es la mitad que no puedes arreglar tú: el ticket seguiría llegando igual, porque el usuario no sabría qué pasó. Y si tu fix fue quitar el `logout()`, deja al usuario con un token inválido en `localStorage` y con todas las pantallas fallando de una en una — cambia un síntoma claro por uno difuso.

</details>

---

## Incidente 04 — "La pantalla de plantillas a veces carga y a veces se queda pensando"

> **Fase:** 3 · **Categoría:** Integración · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-40 min

### 🎫 El ticket

> *"La pantalla de plantillas a veces carga y a veces se queda pensando para siempre. Cuando se queda, ni siquiera da error: el círculo gira y ya. Toca recargar la página entera."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir de forma determinista —un fallo que ocurre "a veces" no se investiga, se hace ocurrir siempre—, identificar cuál de los seis fallos del inyector de caos es, y explicar por qué **este** no lo caza ningún `catchError`.

### 🔧 Preparación

```bash
CHAOS=timeout CHAOS_RATE=1 npm run mock
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Empieza siempre por la columna **Status** de Network, que parte el problema en tres ramas que no se parecen en nada: nadie contestó, contestaron a medias, o contestaron. Este síntoma cae en una de las tres y la elimina casi todo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`CHAOS_RATE=1` convierte el intermitente en determinista, y ése es siempre el primer movimiento. Con la petición reproducida, mira qué recibe tu código: pon un `tap` con tres callbacks —`next`, `error`, `complete`— y observa cuál de los tres se ejecuta.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Ninguno de los tres se ejecuta. Si el observable no emite, no falla y no completa, ¿de qué te sirve un `catchError`? ¿Qué operador es el único que puede intervenir cuando **no pasa nada**?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El fallo es `timeout` del inyector de caos: el servidor **no responde nunca**. La petición se queda en `pending` en Network, sin status y sin error.

Y la causa del lado del cliente es una ausencia: **ningún flujo del proyecto tiene tiempo límite**. `TemplateStateService.load()` pone `loading: true`, lanza la petición, y espera indefinidamente una emisión que no va a llegar. El observable no emite, no falla y no completa, así que:

- El `catchError` **nunca se ejecuta**: no hay error que capturar.
- El `next` nunca se ejecuta: no hay valor.
- `loading` se queda en `true` para siempre, y con él el spinner.

> 🧭 **La lección de diseño: un `catchError` no te protege de que no pase nada.** Lo único que protege es un tiempo límite explícito, y decidir cuántos milisegundos es una decisión de producto que casi nadie toma hasta que le ocurre esto.

**Parche mínimo**

El archivo es **nuevo** (Fase 4, `inject()`), así que el parche va en ese estilo:

```ts
// src/app/core/state/template-state.service.ts
load(): void {
  this.patch({ loading: true, error: null });

  this.templateApi
    .getAll()
    .pipe(
      // 15 segundos: por encima de cualquier respuesta razonable del backend
      // y por debajo de la paciencia de un inspector en campo con mala señal.
      // El número es una decisión de producto, no una constante técnica.
      timeout(15_000),
    )
    .subscribe({
      next: (templates) => this.patch({ items: [...templates], loading: false }),
      error: (error: unknown) => {
        this.patch({
          loading: false,
          error:
            error instanceof TimeoutError
              ? 'El servidor no respondió a tiempo. Reintenta en unos segundos.'
              : toErrorMessage(error),
        });
      },
    });
}
```

**La refactorización correcta**

El tiempo límite no pertenece a `TemplateStateService`: pertenece al **borde HTTP**, donde ya vive la traducción de errores de la Fase 3. Un interceptor funcional lo aplica a todas las peticiones de una vez, y entonces ningún servicio de estado tiene que acordarse:

```ts
// src/app/core/interceptors/timeout.interceptor.ts — código nuevo
export const timeoutInterceptor: HttpInterceptorFn = (request, next) =>
  next(request).pipe(timeout(REQUEST_TIMEOUT_MS));
```

Con un matiz que hay que decidir antes de escribirlo: **quince segundos no valen para todo**. Una descarga de evidencias o un informe pesado necesitan más, y eso se resuelve con `HttpContext` en vez de con una excepción escrita a mano en el interceptor.

**Prueba de regresión**

```ts
// src/app/core/state/template-state.service.spec.ts
it('sale del estado de carga cuando el servidor no responde', fakeAsync(() => {
  service.load();
  httpMock.expectOne('/templates');   // la petición sale y nadie la responde

  // El tiempo virtual avanza hasta pasado el límite. Sin fakeAsync este test
  // tardaría quince segundos de reloj y sería el más lento de la suite.
  tick(15_001);

  let state: FeatureState<ChecklistTemplate> | null = null;
  service.state$.subscribe((value) => (state = value));

  // Antes del fix: loading seguía en true y error seguía en null, para siempre.
  expect(state!.loading).toBeFalse();
  expect(state!.error).toContain('no respondió a tiempo');
}));
```

**Prevención**

El interceptor de la refactorización, y una regla de revisión: **todo flujo que pinte un spinner tiene que tener una salida que no dependa del servidor.** Si el único camino para quitar el spinner es que llegue una respuesta, el spinner es eterno por diseño.

**Por qué llegó a producción**

El mock de desarrollo responde en dos milisegundos y nunca deja de responder. En UAT, detrás de una red corporativa y un proxy, sí ocurre — y ocurre poco, así que llega como "a veces". El sistema permitió esto porque **el caso "no pasa nada" no aparece en ninguna prueba manual**: para verlo hay que provocarlo, y provocarlo es exactamente lo que el inyector de caos de la Fase 3 existe para hacer barato.

**Si tu causa fue distinta a esta**

Si concluiste `latency`, el síntoma se parece y hay una diferencia observable: con latencia la petición **termina**, y en Timing se ve un `Waiting (TTFB)` alto. Aquí no termina nunca. Si concluiste que el bug es que falta un botón de reintentar, no te equivocas —hace falta— pero sin tiempo límite ese botón no se puede llegar a mostrar, porque la pantalla sigue creyendo que está cargando.

</details>

---

## Incidente 05 — "Entro a Plantillas y dice que no hay ninguna, pero en el mock están las tres"

> **Fase:** 4 · **Categoría:** Estado (servicios) · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 25-40 min

### 🎫 El ticket

> *"Entro a Plantillas y la pantalla dice que no hay ninguna. Pero yo veo las tres en el mock, y si entro por el editor sí aparecen. Es sólo el listado."*

**Reportado por:** un compañero del equipo
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Explicar por qué una pantalla ve el estado vacío y otra no, y arreglarlo de forma que el fix no dependa de que cada pantalla nueva se acuerde de algo.

### 🔧 Preparación

```bash
git switch -c incidente/05 fase-04
npm run mock     # sin ningún flag: el backend está perfectamente bien
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de mirar el estado, mira la red. Hay una pregunta que casi nadie hace y que aquí lo resuelve todo: ¿cuántas peticiones a `/templates` salen al entrar a esa pantalla?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

No sale ninguna. El servicio de estado tiene un `BehaviorSubject` que **siempre** entrega un valor a quien se suscriba, aunque nadie haya cargado nada. ¿Qué valor entrega en ese caso?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`createInitialState<T>()` devuelve `{ items: [], selected: null, loading: false, error: null }`. Suscribirse no carga nada: pedir y recordar son dos responsabilidades distintas. ¿Quién llama a `load()`, y qué pasa si nadie lo hace?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`TemplateListComponent` se suscribe a `templateState.templates$` y **nadie llama a `load()`**. El `BehaviorSubject` entrega su valor inicial —un array vacío— y la pantalla lo pinta con toda corrección: cero plantillas.

El editor sí funciona porque él **sí** llama a `load()` en su `ngOnInit`. Y de ahí sale el detalle que confunde al reportar: si entras primero al editor y después al listado, **el listado funciona**, porque el servicio raíz conserva el estado entre navegaciones. El bug parece intermitente y depende del orden en que abras las pantallas.

```
Network al entrar a /templates:  (ninguna petición a /templates)
Estado emitido:                  { items: [], loading: false, error: null }
```

> 🧠 **La confusión de fondo, y es la que este incidente entrena: suscribirse no es cargar.** Un `BehaviorSubject` siempre tiene un valor; que te lo entregue no significa que alguien haya ido a buscarlo. `state$` no miente: dice la verdad sobre un estado que nadie llenó.

**Parche mínimo**

```ts
// src/app/features/templates/template-list/template-list.component.ts
ngOnInit(): void {
  // Sin esta línea, la pantalla pinta el estado inicial —vacío— y no pide nada.
  this.templateState.load();
}
```

**La refactorización correcta**

El parche funciona y **traslada el problema a la siguiente pantalla que alguien escriba**. La Fase 6, la 7 y la 11 van a consumir este mismo estado, y las tres tendrían que acordarse.

La forma que no exige memoria es que el servicio cargue **la primera vez que alguien mire**:

```ts
// src/app/core/state/template-state.service.ts
/**
 * Carga perezosa: la primera suscripción dispara la petición y las siguientes
 * comparten el resultado. Ninguna pantalla tiene que acordarse de nada, y
 * quien necesite datos frescos llama a `reload()` explícitamente.
 *
 * `refCount: true` es obligatorio: sin él la suscripción interna quedaría viva
 * para siempre aunque no quede nadie mirando. Ver el apéndice A06 §7.
 */
readonly templates$: Observable<readonly ChecklistTemplate[]> = defer(() => {
  if (!this.loadedOnce) {
    this.loadedOnce = true;
    this.load();
  }
  return this.state$;
}).pipe(
  map((state) => state.items),
  distinctUntilChanged(),
  shareReplay({ bufferSize: 1, refCount: true }),
);
```

Con la contrapartida dicha en voz alta: **una carga escondida en un `defer` es más difícil de seguir en un breakpoint** que un `load()` explícito en un `ngOnInit`. Es un intercambio real —menos memoria a cambio de menos transparencia— y merece decidirse en equipo, no colarse en un hotfix.

**Prueba de regresión**

```ts
// src/app/features/templates/template-list/template-list.component.spec.ts
it('pide las plantillas al montarse', () => {
  const templateState = TestBed.inject(TemplateStateService);
  const loadSpy = spyOn(templateState, 'load');

  fixture.detectChanges();   // dispara ngOnInit

  // Falla antes del fix: nadie llamaba a load() y la pantalla pintaba vacío.
  expect(loadSpy).toHaveBeenCalledTimes(1);
});

it('no confunde "sin cargar" con "no hay ninguna"', fakeAsync(() => {
  fixture.detectChanges();
  httpMock.expectOne('/templates').flush([templateV1, templateV2, boilerV1]);
  tick();
  fixture.detectChanges();

  expect(fixture.debugElement.queryAll(By.css('[data-testid="template-row"]')).length).toBe(3);
}));
```

**Prevención**

El segundo test es el que importa a largo plazo, y su nombre es la lección: **"sin cargar" y "no hay ninguna" son dos estados distintos que hoy se pintan igual.** Un `FeatureState<T>` con un campo `loaded: boolean` los separaría, y la pantalla podría decir "cargando…" en vez de "no hay plantillas". Es un pendiente legítimo de este incidente.

**Por qué llegó a producción**

No llegó: se cazó en desarrollo. Y aun así merece post-mortem, porque el sistema **facilitó** el error de dos maneras. Primero, el estado inicial de una lista vacía es indistinguible de una lista que de verdad está vacía. Segundo, el bug es intermitente según el orden de navegación, así que quien lo reporta describe algo que a otro no le pasa — y eso desgasta la confianza en el reporte antes de que nadie mire nada.

**Si tu causa fue distinta a esta**

Si concluiste que el mock no devuelve nada, se descarta con un `curl` a `/templates`: devuelve las tres. Si concluiste que hay un `shareReplay` mal puesto, es una hipótesis razonable y produce un síntoma parecido —datos que no llegan a un segundo suscriptor— pero la evidencia lo tumba: con `shareReplay` mal puesto **habría** una petición en Network, y aquí no hay ninguna. **La ausencia de tráfico es lo que hace único a este incidente**, y es el primer sitio donde hay que mirar.

</details>

---
EOF
wc -l cuaderno-incidentes.md

# --- 2026-09-07T01:31:50 · Write incidents 06-11
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 06 — "El botón de Nuevo cliente se ve gris y plano desde el martes, pero todo compila"

> **Fase:** 5 · **Categoría:** Convivencia de estilos 🧬 · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min

### 🎫 El ticket

> *"El botón de Nuevo cliente se ve gris y plano desde el martes. Antes era azul y con sombra. No se rompió nada, funciona, pero se ve raro y el resto de botones de la aplicación sí están bien."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Explicar por qué **compila y no falla** un componente al que le falta algo, y arreglarlo. El entregable incluye decir qué cambió "el martes".

### 🔧 Preparación

```bash
git switch -c incidente/06 fase-05
npm start
# Entra a /clients y compara ese botón con cualquier otro de la aplicación
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No mires el CSS todavía. Inspecciona el elemento `<button>` y compara sus clases con las de un botón que sí se ve bien, en otra pantalla. La diferencia no está en los estilos: está en lo que le falta al elemento.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Un botón correcto tiene clases `mat-mdc-raised-button mat-primary`. El tuyo no tiene ninguna. Nadie se las puso. ¿Quién se las pone normalmente, y por qué en este componente no?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`mat-raised-button` no es un componente: es una **directiva con selector de atributo**. Un atributo que ninguna directiva reclama es HTML perfectamente válido. ¿Qué pasó "el martes" con lo que este componente importaba?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`ClientListComponent` es standalone y **no tiene `MatButtonModule` en sus `imports`**.

Y aquí está lo que hace peligroso a este bug: `mat-raised-button` es una **directiva con selector de atributo**. Si nadie la provee, `<button mat-raised-button>` es un `<button>` con un atributo desconocido — HTML válido, sin error de plantilla, sin advertencia. El compilador sólo se queja de un elemento desconocido (`NG0304`) o de una **propiedad** que no existe (`NG0303`); un atributo suelto no dispara ninguno de los dos.

```html
<!-- Lo que el navegador acaba pintando: -->
<button mat-raised-button color="primary">Nuevo cliente</button>
<!-- …sin una sola clase de Material. Un botón del sistema, gris y plano. -->
```

**Y "el martes"** fue el pago de la deuda 💸 del `SharedModule` en la Fase 5: hasta entonces, `SharedModule` reexportaba media librería de Material y **todo el que lo importara heredaba `MatButtonModule` sin pedirlo**. Al convertir este componente a standalone, esa herencia desapareció y quedó al descubierto que nunca declaró lo que usaba.

> 🧬 **Es la costura exacta entre generaciones**, y por eso este incidente no puede existir en un sistema de una sola época: en el mundo de los NgModule, importar de más funcionaba; en el mundo standalone, cada archivo declara lo que usa. El componente no se rompió al convertirlo — **ya estaba mal y el `SharedModule` lo tapaba.**

**Parche mínimo**

```ts
// src/app/features/clients/client-list/client-list.component.ts
@Component({
  selector: 'cc-client-list',
  standalone: true,
  imports: [
    AsyncPipe,
    NgIf,
    RouterLink,
    MatButtonModule,   // ← lo que faltaba. La directiva mat-raised-button vive aquí.
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatTableModule,
  ],
  // …
})
```

**La refactorización correcta**

Ninguna sobre el componente: importar lo que usas **es** el modelo standalone. Lo que sí conviene, y en otro commit, es buscar a los demás heridos del mismo pago:

```bash
# Componentes standalone que usan directivas de Material sin importar su módulo.
grep -rln "mat-raised-button\|mat-stroked-button\|mat-icon-button" src/app --include="*.html" \
  | while read -r html; do
      ts="${html%.html}.ts"
      grep -q "MatButtonModule" "$ts" || echo "FALTA MatButtonModule → $ts"
    done
```

**Prueba de regresión**

```ts
// src/app/features/clients/client-list/client-list.component.spec.ts
it('pinta el botón de nuevo cliente con el estilo de Material', () => {
  fixture.detectChanges();

  const button = fixture.debugElement.query(By.css('[data-testid="new-client"]'));

  // Falla antes del fix: sin MatButtonModule importado, la directiva no corre
  // y el elemento no recibe ninguna clase de Material. El atributo del HTML
  // sigue ahí, así que comprobar el atributo NO detectaría nada.
  expect(button.nativeElement.classList).toContain('mat-mdc-raised-button');
});
```

> 💡 **Comprobar la clase y no el atributo es toda la gracia de este test.** El atributo `mat-raised-button` está en la plantilla tanto si la directiva corre como si no; la clase `mat-mdc-raised-button` sólo aparece si corrió.

**Prevención**

El test de arriba en cada pantalla con botones de acción, y el `grep` de la refactorización convertido en una comprobación del pipeline. A largo plazo, lo que de verdad previene esta familia es una regla de revisión: **cuando un componente se convierte a standalone, sus `imports` se derivan de su plantilla, no de lo que "ya venía funcionando".**

**Por qué llegó a producción**

Porque no rompió nada. El componente compiló, los tests pasaron —no había ninguno que mirase el estilo— y la pantalla funcionaba: el botón se pulsa y navega. **Un fallo puramente visual no tiene ningún mecanismo automático que lo detecte** en este proyecto, así que la única red era que alguien mirase la pantalla, y quien hizo la conversión miró que funcionara.

El sistema lo permitió por una decisión razonable de 2021 —un `SharedModule` que reexporta Material "por comodidad"— cuyo costo real sólo se ve el día que alguien deja de importarlo. Es la definición de deuda técnica: barata al contraerla, y la factura llega en un momento que no eliges.

**Si tu causa fue distinta a esta**

Si buscaste el problema en `styles.scss` o en el tema, es exactamente donde el ticket te empuja a mirar y no hay nada: el tema está bien y el resto de botones lo demuestra. Si concluiste que faltaba `color="primary"`, el atributo está puesto — y sin la directiva tampoco haría nada. Y si tu fix fue añadir CSS propio para que se vea azul, funcionaría hasta que alguien cambie el tema, y habrías creado un botón que ya no participa del sistema de diseño.

</details>

---

## Incidente 07 — "Metí el listado de clientes en el panel y la pantalla se queda en blanco"

> **Fase:** 5 · **Categoría:** Convivencia de estilos 🧬 · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-50 min

### 🎫 El ticket

> *"Me pidieron mostrar los últimos clientes en el panel principal. Reusé el componente del listado, que ya existe. La pantalla del panel se queda en blanco. Por el menú de Clientes sigue funcionando igual de bien."*

**Reportado por:** un compañero del equipo
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Explicar por qué **el mismo componente** funciona por una ruta y no por otra, y arreglarlo de forma que el componente sea reusable de verdad.

### 🔧 Preparación

```bash
git switch -c incidente/07 fase-05
npm start
# Entra al panel principal, y después a /clients por el menú
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Hay un error en consola y su mensaje es largo. No leas el stack: lee lo que hay **entre paréntesis** justo después de `R3InjectorError`. Ese paréntesis decide si vas a buscar en diez archivos o en dos.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El paréntesis dice `Standalone[ClientListComponent]`. Eso significa que el inyector que falló es el del propio componente, y que ningún `.module.ts` va a tener la respuesta. La pregunta correcta no es "qué falta" sino **"por qué ruta llegó este componente a la pantalla"**.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`grep -rn "CLIENT_LIST_PAGE_SIZE" src/app --include="*.ts"`. Hay exactamente un sitio que lo provee. ¿Está en el camino del panel?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

```
ERROR NullInjectorError: R3InjectorError(Standalone[ClientListComponent])[InjectionToken CLIENT_LIST_PAGE_SIZE -> InjectionToken CLIENT_LIST_PAGE_SIZE]:
  NullInjectorError: No provider for InjectionToken CLIENT_LIST_PAGE_SIZE!
```

`ClientListComponent` hace `inject(CLIENT_LIST_PAGE_SIZE)`, y ese token **sólo se provee en la ruta `/clients`**:

```ts
// src/app/features/clients/clients.routes.ts
{
  path: '',
  loadComponent: () => import('./client-list/client-list.component').then((m) => m.ClientListComponent),
  providers: [{ provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 }],
}
```

Un componente standalone resuelve sus dependencias en su propio inyector y en el de **la ruta que lo activó**. Por el menú se pasa por esa ruta y el token está; embebido en la plantilla del panel, no hay ninguna ruta que lo traiga. **La misma clase, dos inyectores distintos.**

> 🧬 **Y por eso este incidente es de convivencia y no de configuración.** En el mundo de los NgModule, un provider registrado en un módulo lo veía todo lo que ese módulo declaraba, vinieras por donde vinieras. En el mundo standalone, **el camino importa**, y ése es el cambio de modelo mental que la Fase 5 entrena.

**Parche mínimo**

Sí, hay un parche de una línea, y **no es el que hay que entregar**:

```ts
// El hotfix de un viernes: proveer el token también en la ruta del panel.
{ path: '', component: DashboardComponent, providers: [{ provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 }] }
```

Funciona y deja la trampa puesta para la siguiente pantalla que reuse el componente. Se entrega **sólo** si hay que desplegar ya, y con el ticket de seguimiento abierto en el mismo commit.

**La refactorización correcta**

El token tiene un valor por defecto razonable, así que lo declara él:

```ts
// src/app/features/clients/client-list-page-size.token.ts
/**
 * Cuántas filas por página muestra el listado de clientes.
 *
 * La factory `providedIn: 'root'` es lo que hace al componente REUSABLE: quien
 * lo monte sin decir nada obtiene 25, y quien necesite otro tamaño lo provee en
 * su ruta. Sin ella, el componente sólo funciona por el camino que su autor
 * probó — y el error que da no dice "te falta un provider en la ruta", dice
 * "no hay proveedor", que suena a un problema del componente.
 */
export const CLIENT_LIST_PAGE_SIZE = new InjectionToken<number>('CLIENT_LIST_PAGE_SIZE', {
  providedIn: 'root',
  factory: () => 25,
});
```

La ruta de clientes puede seguir sobrescribiéndolo con `5`, y el panel funciona sin tocar nada.

> 🧭 **La regla que sale de aquí y que vale para todo el curso: un componente standalone que exige un provider de ruta no es reutilizable, es una trampa.** Funciona por el camino que su autor probó y explota por cualquier otro.

**Prueba de regresión**

```ts
// src/app/features/clients/client-list/client-list.component.spec.ts
it('se monta sin ningún provider de ruta', () => {
  // Ni un solo `providers`: es exactamente la situación del panel.
  TestBed.configureTestingModule({
    imports: [ClientListComponent],
    providers: [provideHttpClient(), provideHttpClientTesting()],
  });

  // Falla antes del fix con NullInjectorError. El test es el escenario, no la aserción.
  const fixture = TestBed.createComponent(ClientListComponent);
  fixture.detectChanges();

  expect(fixture.componentInstance.pageSize).toBe(25);
});

it('respeta el tamaño que provea la ruta', () => {
  TestBed.configureTestingModule({
    imports: [ClientListComponent],
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 },
    ],
  });

  expect(TestBed.createComponent(ClientListComponent).componentInstance.pageSize).toBe(5);
});
```

**Prevención**

El primer test es la prevención: **montar todo componente standalone sin ningún provider de ruta, como parte de su suite.** Si no se monta así, no es reusable, y el test lo dice antes de que alguien lo descubra embebiéndolo en otra pantalla.

**Por qué llegó a producción**

El componente se escribió para una ruta y se probó en esa ruta. Nada en el código dice "esto necesita que alguien te provea algo": la dependencia es invisible desde fuera, y el compilador no puede avisar porque el token existe y el tipo cuadra. El fallo sólo aparece en tiempo de ejecución y sólo por el camino que nadie probó.

El sistema lo permitió porque **la Fase 5 introdujo el token con provider de ruta a propósito**, para enseñar el mecanismo, y la deuda quedó declarada. Este incidente es su factura.

**Si tu causa fue distinta a esta**

Si buscaste en `SharedModule` o en `CoreModule`, el paréntesis del error te estaba diciendo que ahí no había nada que buscar — y perder diez minutos ahí la primera vez es normal: es exactamente el reflejo heredado que este track entrena a corregir. Si tu fix fue `inject(CLIENT_LIST_PAGE_SIZE, { optional: true }) ?? 25`, funciona, y con `strict` te obliga a decidir el valor por defecto **en el componente** en vez de en el token: es defendible, y el argumento en contra es que ese 25 queda escondido en una línea de inyección en vez de estar donde se define el token.

</details>

---

## Incidente 08 — "La inspección de agosto ahora tiene un ítem más que cuando la hice"

> **Fase:** 7 · **Categoría:** Versionado normativo · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> *"La inspección 501, la del ascensor de la torre A que hice en agosto del año pasado, ahora tiene un ítem más que cuando la hice. Yo respondí tres cosas y ahora aparecen cuatro, y la última está vacía. No la he vuelto a tocar. Y el título del primer ítem tampoco es el que yo leí."*

**Reportado por:** inspector de campo
**Ambiente:** UAT

### 🎯 Qué se te pide

Localizar la línea, aplicar el fix, y —**antes del fix**— escribir el test que reproduce el bug y verlo fallar. Este incidente es el que cierra el par de tags de la convención.

### 🔧 Preparación

```bash
git switch -c incidente/08 fase-07
npm run mock
npm start
# Abre la inspección 501
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No abras ningún archivo todavía. La petición que la pantalla hace al abrir la inspección contesta la pregunta entera, y está en Network.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Compara dos cosas: el campo `templateVersion` de la inspección 501, y los parámetros de la petición a `/templates`. Uno de los dos números no aparece donde debería.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`grep -rn "resolveTemplateVersion" src/app --include="*.ts"`. Esa función contesta *"¿qué versión rige hoy?"*, que es una pregunta legítima. ¿Es la pregunta que hay que hacer al **leer** una inspección que ya se ejecutó?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

La pantalla de detalle resuelve la plantilla **por fecha de hoy** en vez de leer la versión que la inspección guardó.

```
Lo que la inspección dice:   templateVersion: 1
Lo que la pantalla pide:     GET /templates?templateId=elevator-annual
                                                       ↑ sin &version=
Lo que recibe:               la v2 — cuatro ítems, y "Estado y tensión del cable principal"
```

La v1 tiene tres ítems y la v2 tiene cuatro. El cuarto (`cabin-lighting`) aparece vacío porque **nadie lo respondió: no existía en agosto de 2023**. Y el título de `main-cable` cambió con la norma, que es lo que hace el bug *visible* en vez de sólo incorrecto.

```ts
// src/app/features/inspections/inspection-detail/inspection-detail.component.ts
const template = resolveTemplateVersion(family, todayInBusinessZone());
```

> 🧭 **Las dos preguntas que suenan igual y no lo son:** *"¿qué versión rige hoy?"* es un cálculo sobre fechas y sirve para **empezar** una inspección nueva. *"¿con qué versión se ejecutó ésta?"* es leer un campo, y es lo único correcto al **abrir** una que ya existe. Confundirlas no da ningún error: da un histórico que cambia solo.

**Parche mínimo**

El archivo es **nuevo**, así que el parche va en estilo nuevo:

```ts
// src/app/features/inspections/inspection-detail/inspection-detail.component.ts
readonly view$ = this.route.paramMap.pipe(
  map((params) => Number(params.get('inspectionId'))),
  switchMap((inspectionId) => this.inspectionApi.getById(inspectionId)),
  switchMap((inspection) =>
    // La versión que la inspección GUARDÓ. Es un campo, no un cálculo: una
    // inspección se lee siempre con la plantilla con la que se ejecutó, hoy y
    // dentro de diez años, aunque la vigente sea otra.
    this.templateApi
      .getByVersion(inspection.templateId, inspection.templateVersion)
      .pipe(map((template) => ({ inspection, template }))),
  ),
);
```

**La refactorización correcta**

El parche arregla una pantalla. Lo que evita la familia entera es hacer **imposible** pedir una plantilla para una inspección sin decir su versión:

```ts
// src/app/core/api/template-api.service.ts
/**
 * La única forma soportada de obtener la plantilla de una inspección
 * existente. Recibe la inspección entera precisamente para que nadie pueda
 * llamarla sin la versión: el tipo lo impide.
 */
templateOf(inspection: Inspection): Observable<ChecklistTemplate> {
  return this.getByVersion(inspection.templateId, inspection.templateVersion);
}
```

Y la regla de revisión que la acompaña: **cada aparición de `resolveTemplateVersion` hay que justificarla en el propio código**, porque es correcta en un sitio del curso y sólo en uno —la Fase 8 §5.9, al empezar una inspección nueva—.

**Prueba de regresión**

Va **antes** del fix, y hay que verla fallar. No necesita `TestBed`: la regla vive en una función pura.

```ts
// src/app/core/domain/template-resolution.spec.ts
it('lee una inspección con la versión que guardó, no con la vigente', () => {
  const family = [templateV1, templateV2];   // v1 hasta 2023-12-31, v2 desde 2024-01-01
  const inspection = { templateId: 'elevator-annual', templateVersion: 1 } as Inspection;

  const applied = family.find((version) => version.version === inspection.templateVersion);

  expect(applied?.version).toBe(1);
  expect(applied?.items.length).toBe(3);            // la v2 tiene cuatro
  expect(applied?.items[0].title).toBe('Estado del cable principal');   // la v2 dice "y tensión"
});
```

```
Chrome Headless: Executed 1 of 1 (1 FAILED)
  ✗ lee una inspección con la versión que guardó, no con la vigente
    Expected 2 to be 1.
```

```bash
git tag -a inc/08/version-ejecutada-roto -m "F7 inc08: el test reproduce el bug y falla"
# …el fix…
git tag -a inc/08/version-ejecutada-fix  -m "F7 inc08: causa raíz y fix, con el test en verde"
git diff inc/08/version-ejecutada-roto inc/08/version-ejecutada-fix   # ← dos líneas
```

**Prevención**

El test de arriba, el método `templateOf()` de la refactorización, y un test de contrato que vale más que los dos: **ninguna petición a `/templates` originada al abrir una inspección puede salir sin `version=`.** Con `HttpTestingController` eso se comprueba en tres líneas y cubre todas las pantallas a la vez.

**Por qué llegó a producción**

Durante casi tres años **no hubo ninguna segunda versión de ninguna plantilla**. `resolveTemplateVersion(family, hoy)` devolvía la única que existía, que era también la que la inspección había usado, y el código era correcto por casualidad. El bug nació el día que se publicó la v2 de `elevator-annual`, en enero de 2024, **sin que nadie tocara una línea de la aplicación**.

Es la clase de fallo que ninguna revisión de código detecta, porque el código que se revisó no cambió: cambió el dato. Y es la razón por la que este curso repite el invariante hasta el cansancio en vez de confiar en que se deduzca.

**Si tu causa fue distinta a esta**

Si concluiste que el editor sobrescribió la v1, es la hipótesis correcta de descartar primero y se tumba con un `diff` contra `db.seed.json`: la v1 está intacta. Si concluiste que hay que "actualizar las inspecciones viejas a la versión nueva", ése es el bug propuesto como arreglo: una inspección responde a las preguntas que se le hicieron, y migrarla inventa respuestas que nadie dio. Y si tu fix fue filtrar el ítem vacío en la vista, taparías el síntoma dejando los otros dos —el título cambiado y la versión equivocada— intactos y ahora invisibles.

</details>

---

## Incidente 09 — "Publiqué la v3 y el sistema dice que hay dos plantillas vigentes"

> **Fase:** 7 · **Categoría:** Versionado normativo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-70 min

### 🎫 El ticket

> *"Publiqué la v3 de la plantilla de ascensores porque cambió la norma. Ahora, cuando empiezo una inspección nueva, unas veces me sale con los ítems de la v2 y otras con los de la v3. En el listado de plantillas aparecen las dos como vigentes."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Explicar por qué el resultado es **inconsistente entre llamadas** y arreglar la operación que dejó el sistema en ese estado. Y decidir qué hacer con el dato que ya está mal.

### 🔧 Preparación

El bug está en el dato, no en el código: un `db.json` alterno.

```bash
cp mock/db.json mock/db.mio.json          # guarda el tuyo
cp mock/db.incidente-09.json mock/db.json
npm run mock
npm start
```

Para volver: `npm run seed`, o `cp mock/db.mio.json mock/db.json`.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

"Unas veces una y otras otra" con el mismo dato de entrada no es aleatoriedad: es un desempate que nadie definió. Antes de mirar el código, mira las tres filas de la familia `elevator-annual` y sus dos campos de vigencia.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s "http://localhost:3000/templates?templateId=elevator-annual" \
  | python3 -c "import json,sys; [print(t['version'], t['validFrom'], t['validUntil']) for t in json.load(sys.stdin)]"
```

Mira la columna de la derecha. ¿Cuántas filas dicen `None`, y qué significa `null` en ese campo?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Publicar una versión nueva son **dos** escrituras: nace la v3 con su `validFrom`, y se cierra la v2 poniéndole `validUntil`. Si sólo ocurre la primera, no falla nada hoy. ¿Qué hace `resolveTemplateVersion` cuando dos versiones son válidas para la misma fecha?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

```
version  validFrom    validUntil
1        2021-01-01   2023-12-31
2        2024-01-01   None          ← sigue abierta
3        2025-06-01   None          ← y la nueva también
```

`null` en `validUntil` significa **"vigente indefinidamente"**. Dos filas con `null` a la vez son dos ventanas abiertas que se solapan desde el 1 de junio de 2025, y `resolveTemplateVersion` tiene que elegir entre dos respuestas igualmente válidas. Devuelve la que le toque según el orden en que json-server le entregue el array — que no está garantizado — y por eso el resultado cambia entre llamadas.

La operación culpable es `publish()`: **hace una escritura donde el dominio exige dos**.

```ts
// src/app/core/state/template-state.service.ts — lo que hay
publish(draft: ChecklistTemplateDraft): void {
  this.templateApi.create(draft).subscribe(/* … */);   // nace la v3, y nadie cierra la v2
}
```

> ⚠️ **Es la clase de bug que `strict` no puede atrapar**, y conviene entender por qué: `null` es un valor perfectamente válido en las dos filas. No hay ningún tipo que se viole. El invariante que se rompe —"como máximo una versión vigente por familia en cualquier fecha"— no vive en el sistema de tipos: vive en el dominio, y ahí hay que ponerlo a la fuerza.

**Parche mínimo**

```ts
// src/app/core/state/template-state.service.ts
publish(draft: ChecklistTemplateDraft): void {
  this.patch({ loading: true, error: null });

  // Publicar son DOS escrituras. `concatMap` y no `mergeMap`: el orden importa,
  // porque si la nueva versión nace antes de que la anterior se cierre, hay una
  // ventana —corta, real— en la que el sistema tiene dos vigentes.
  const closesPrevious$ = this.currentActive(draft.templateId).pipe(
    concatMap((active) =>
      active === null
        ? of(null)
        : this.templateApi.close(active.id, previousDay(draft.validFrom)),
    ),
  );

  closesPrevious$
    .pipe(concatMap(() => this.templateApi.create(draft)))
    .subscribe({
      next: () => this.load(),
      error: (error: unknown) => this.patch({ loading: false, error: toErrorMessage(error) }),
    });
}
```

Y el dato que ya está mal se corrige a mano, una vez, con su registro:

```bash
curl -s -X PATCH "http://localhost:3000/templates/elevator-annual-v2" \
  -H 'Content-Type: application/json' \
  -d '{"validUntil":"2025-05-31"}'
```

**La refactorización correcta**

Dos escrituras desde el navegador **no son atómicas**: si la segunda falla, el sistema queda en el estado inconsistente que este ticket describe, y ahora por culpa del fix. La forma correcta es un endpoint de publicación en el servidor que haga las dos cosas en una transacción — y **CertCore no tiene backend propio**, así que ésa es una conversación con el equipo de backend, no un cambio de frontend.

Lo que sí se puede hacer desde aquí, y es lo que hay que entregar junto al parche: **una comprobación que detecte el estado inconsistente en vez de asumir que no ocurre.**

```ts
// src/app/core/domain/template-family.ts
/** Devuelve las versiones que se solapan. Un array vacío es el invariante cumplido. */
export function overlappingVersions(
  family: readonly ChecklistTemplate[],
): readonly (readonly [ChecklistTemplate, ChecklistTemplate])[] { … }
```

**Prueba de regresión**

```ts
// src/app/core/domain/template-family.spec.ts
it('detecta dos versiones vigentes a la vez', () => {
  const family = [
    { version: 2, validFrom: '2024-01-01', validUntil: null },
    { version: 3, validFrom: '2025-06-01', validUntil: null },
  ] as ChecklistTemplate[];

  // Falla antes del fix: nadie comprobaba esto y el array salía vacío.
  expect(overlappingVersions(family).length).toBe(1);
});

it('publicar cierra la versión anterior', fakeAsync(() => {
  service.publish({ templateId: 'elevator-annual', validFrom: '2025-06-01', items: [] });

  // La primera petición es el CIERRE, no la creación: el orden es parte del fix.
  const close = httpMock.expectOne((r) => r.method === 'PATCH' && r.url.includes('elevator-annual-v2'));
  expect(close.request.body).toEqual({ validUntil: '2025-05-31' });
  close.flush({});
  tick();

  httpMock.expectOne((r) => r.method === 'POST' && r.url.endsWith('/templates')).flush({});
  tick();
}));
```

**Prevención**

`overlappingVersions()` ejecutado al cargar la familia, con un aviso visible en el editor cuando devuelve algo. No arregla el dato, y **hace imposible que el estado inconsistente pase desapercibido tres meses**, que es lo que ocurrió aquí.

**Por qué llegó a producción**

`publish()` se escribió cuando la familia de ascensores tenía una sola versión, y con una sola versión **una escritura basta**: no hay ninguna anterior que cerrar. La operación fue correcta durante todo 2021 y 2022. Se volvió incorrecta en enero de 2024, con la v2, y nadie lo notó porque la v1 sí tenía `validUntil` puesto — se lo había puesto alguien a mano, en una migración, sin dejar constancia de que eso era un requisito.

**El invariante existía en la cabeza del equipo original y en ningún archivo.** Ésa es la causa raíz de fondo, y por eso la prevención es una función con nombre y no un recordatorio.

**Si tu causa fue distinta a esta**

Si concluiste que `resolveTemplateVersion` está mal escrita, mírala otra vez: hace lo que puede con una entrada ambigua, y **cualquier desempate que le pongas —la más nueva, la de `validFrom` más reciente— esconde el problema real**, que es que el dato no debería ser ambiguo. Ese cambio hace que el síntoma desaparezca y que el sistema siga aceptando publicaciones incompletas, que es peor. Si concluiste que es un problema de ordenación de json-server, tienes razón en el mecanismo y no en la causa: el orden es lo que hace visible la ambigüedad, no lo que la crea.

</details>

---

## Incidente 10 — "Cambié de inspección desde el listado y me aparecieron ítems de la otra"

> **Fase:** 8 · **Categoría:** Versionado normativo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-70 min

### 🎫 El ticket

> *"Estaba llenando la inspección de la caldera y me acordé de que tenía otra a medias. Volví al listado, abrí la del ascensor, y me aparecieron mezclados ítems de las dos. Uno de ellos ni siquiera es de ascensores."*

**Reportado por:** inspector de campo
**Ambiente:** UAT

### 🎯 Qué se te pide

Localizar por qué el formulario conserva controles de la inspección anterior, y arreglarlo. El entregable incluye distinguir este caso del que **sí** es correcto: un ítem retirado de la misma familia.

### 🔧 Preparación

```bash
git switch -c incidente/10 fase-08
npm run mock
npm start
# Abre la inspección 502 (caldera), vuelve al listado, abre la 500 (ascensor)
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El formulario no está escrito en ningún HTML: se construye desde datos. Así que se depura **comparándolo con los datos**, no leyéndolo. Dos líneas de consola bastan.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```js
const component = ng.getComponent($0);   // el <form>
Object.keys(component.currentView.form.controls);
component.currentView.template.items.map((item) => item.id);
```

Las dos listas tienen que ser idénticas. ¿Qué clave sobra, y a qué plantilla pertenece?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`pressure-valve` es de `boiler-annual`. ¿Qué método se está usando para meter los controles de la inspección nueva, y qué hace ese método cuando la clave ya existe… y cuando sobra?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

```js
Object.keys(form.controls);
// ['pressure-valve', 'flue-gas', 'main-cable', 'emergency-brake', 'door-sensor', 'cabin-lighting']

template.items.map((i) => i.id);
// ['main-cable', 'emergency-brake', 'door-sensor', 'cabin-lighting']
```

`pressure-valve` y `flue-gas` son de `boiler-annual`. **El formulario no se reconstruye al cambiar de inspección: se le añaden encima los controles de la nueva.**

```ts
// src/app/features/inspections/inspection-form/inspection-form.component.ts
for (const item of template.items) {
  this.form.addControl(item.id, buildItemGroup(item, answerByItemId.get(item.id) ?? null));
}
```

`addControl()` **no reemplaza** si la clave ya existe y **no quita** las que sobran. Con un `FormRecord` que sobrevive a la navegación, cada inspección deja su sedimento.

**La distinción que hay que saber hacer**, porque hay un caso idéntico en apariencia que **es correcto**:

| La clave sobrante es… | Qué pasó | ¿Bug? |
|---|---|---|
| un `itemId` de **otra plantilla** (`pressure-valve` en un ascensor) | el formulario no se reconstruyó | **sí** — es este incidente |
| un `itemId` de la **misma familia**, retirado en una versión posterior | una respuesta de un ítem que ya no existe | **no** — se pinta como "ítem retirado" |
| un `itemId` que no existe en ninguna plantilla | el dato está corrompido | **sí**, y no está en el frontend |

**Parche mínimo**

```ts
// Un formulario nuevo por inspección. `buildAnswerForm` es una función pura:
// dale los datos y te devuelve el formulario. No hay estado que arrastrar,
// y por eso no hace falta acordarse de limpiar nada.
readonly currentView$ = this.route.paramMap.pipe(
  map((params) => Number(params.get('inspectionId'))),
  switchMap((inspectionId) => this.loadView(inspectionId)),
  map(({ inspection, template }) => ({
    inspection,
    template,
    form: buildAnswerForm(template, inspection.answers),
  })),
);
```

**La refactorización correcta**

El parche ya lo es. Lo que conviene además es **hacer imposible** el error, quitando la operación que lo permitió: si nadie llama nunca a `addControl` sobre un formulario existente, el bug no puede volver.

```ts
// src/app/core/domain/inspection-form.ts
/**
 * Único punto de construcción del formulario de una inspección. Devuelve uno
 * NUEVO siempre: no hay ninguna forma soportada de mutar uno existente, y ésa
 * es la garantía que evita el incidente 10.
 */
export function buildAnswerForm(
  template: ChecklistTemplate,
  answers: readonly InspectionAnswer[],
): InspectionForm { … }
```

**Y la conexión con el versionado**, que es por lo que este incidente está en esa categoría: la misma función, llamada con la plantilla **vigente** en vez de con la que la inspección guardó, produce un formulario perfectamente válido con los ítems equivocados y **sin ninguna clave sobrante que lo delate**. La Fase 8 §5.3 lo avisa por escrito. Ese caso es indistinguible por las claves y sólo se ve en la URL de `/templates` — es el incidente 08 visto desde aquí.

**Prueba de regresión**

```ts
// src/app/core/domain/inspection-form.spec.ts
it('construye un formulario con exactamente los ítems de su plantilla', () => {
  const form = buildAnswerForm(elevatorV2, inspection500.answers);

  // Falla antes del fix cuando el formulario se reutilizaba entre inspecciones.
  expect(Object.keys(form.controls).sort())
    .toEqual(['cabin-lighting', 'door-sensor', 'emergency-brake', 'main-cable']);
});

it('no arrastra claves entre construcciones sucesivas', () => {
  const boiler = buildAnswerForm(boilerV1, inspection502.answers);
  const elevator = buildAnswerForm(elevatorV2, inspection500.answers);

  expect(Object.keys(elevator.controls)).not.toContain('pressure-valve');
  expect(Object.keys(boiler.controls)).not.toContain('main-cable');
});
```

**Prevención**

Los dos tests, y una comprobación en la propia pantalla que convierte el bug en visible:

```ts
// Al construir la vista, en desarrollo. Un formulario cuyas claves no coinciden
// con su plantilla es un bug, y callarlo es cómo se llega a este ticket.
const orphans = Object.keys(form.controls).filter(
  (key) => !template.items.some((item) => item.id === key),
);
if (orphans.length > 0 && !environment.production) {
  console.warn('[certcore] controles huérfanos en el formulario:', orphans);
}
```

**Por qué llegó a producción**

Durante meses, el listado de inspecciones no permitía saltar de una a otra sin pasar por otra pantalla: había que volver al panel, y eso destruía el componente y con él el formulario. **El bug existía desde el principio y no era alcanzable.** Se volvió alcanzable el día que se añadió el enlace directo entre inspecciones en el listado — un cambio de tres líneas, en otra pantalla, que ninguna revisión relacionó con el formulario.

Es el patrón que más se repite en este cuaderno: **el código que falla no es el que cambió.**

**Si tu causa fue distinta a esta**

Si concluiste que hay que llamar a `form.reset()` al cambiar de ruta, no basta: `reset()` limpia los **valores** y deja los controles. Si concluiste que hay que quitar los controles sobrantes a mano, funciona y es frágil — tienes que acertar cuáles quitar, y esa lista es justamente la que ya estaba mal. Y si tu diagnóstico fue "es el incidente 08 otra vez", vale la pena mirar la diferencia: aquí la URL de `/templates` **es correcta**; lo que está mal es lo que sobrevivió en el formulario.

</details>

---

## Incidente 11 — "Escribo una letra y la aplicación se queda pegada; el ventilador se dispara"

> **Fase:** 8 · **Categoría:** Formularios dinámicos · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-70 min

### 🎫 El ticket

> *"Escribo una letra en la nota de un ítem y la aplicación se queda pegada. El ventilador del portátil se dispara y la tablet se calienta. Si cierro la pestaña y vuelvo a entrar, va bien hasta que escribo otra vez."*

**Reportado por:** inspector de campo
**Ambiente:** UAT

### 🎯 Qué se te pide

Dibujar el ciclo completo antes de tocar nada, y romperlo por el sitio correcto. Hay dos formas de romperlo y sólo una conserva lo que el usuario estaba escribiendo.

### 🔧 Preparación

```bash
git switch -c incidente/11 fase-08
npm run mock
npm start
# Abre la inspección 500 y escribe una letra en la nota de cualquier ítem
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Abre Network con el filtro en `Fetch/XHR`, escribe **una** letra, y después no toques nada durante treinta segundos. Lo que veas contesta si el ciclo pasa por la red o si es interno.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Pon un `console.count` en la suscripción de `valueChanges` y otro en el `next` del guardado. Si los dos crecen a la vez y sin parar, ya tienes el ciclo. Ahora escribe sus cuatro pasos en una servilleta.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El paso 3 del ciclo es *"para que quede sincronizado, parcheo el formulario con lo que devolvió el servidor"*. ¿Qué dispara `patchValue`? ¿Y por qué apagar esa emisión, aunque funciona, es la respuesta equivocada?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Un ciclo de cuatro pasos que cierra perfectamente y **no produce ningún error**:

```
1. El inspector escribe una letra.        → valueChanges emite.
2. Pasa el debounce, sale el PATCH,
   el servidor responde con lo guardado.
3. "Para que quede sincronizado",
   el código parchea el formulario.       → patchValue()
4. patchValue dispara valueChanges.       → vuelve al 2. Para siempre.
```

```ts
// src/app/features/inspections/inspection-form/inspection-form.component.ts
concatMap((answers) => this.inspectionApi.saveAnswers(this.inspectionId, answers)),
takeUntilDestroyed(this.destroyRef),
).subscribe((saved) => {
  // ← El paso 3. Parece prudente y es el bucle.
  this.form.patchValue(toFormValue(saved.answers));
});
```

Lo que se ve es la aplicación arrastrándose, Network llenándose sola y el ventilador. Nada rojo en ninguna parte.

**Parche mínimo**

```ts
// El único cambio: después de guardar, el formulario NO SE TOCA.
// El servidor confirma; no dicta. El único patchValue de esta pantalla es el
// de la carga inicial, y ni siquiera hace falta: el formulario se construye
// ya con los valores dentro.
).subscribe(() => {
  this.lastSavedAt = nowInstant();
});
```

**La forma que parece obvia y no se entrega:**

```ts
// ❌ Funciona, rompe el bucle, y pisa lo que el inspector tenía escrito con lo
//    que el servidor devolvió. Si escribió algo durante el viaje de red, se
//    pierde — y ahora sin ningún síntoma. Cambias un bug ruidoso por uno mudo.
this.form.patchValue(toFormValue(saved.answers), { emitEvent: false });
```

> 🧭 **La regla: el servidor confirma, no dicta.** En una pantalla con autosave, el usuario es la fuente de verdad de lo que está escribiendo. Lo único que el servidor puede decir es "recibido" o "no pude"; en cuanto empieza a devolver contenido que se pinta, la escritura del usuario compite con la red y pierde a veces.

**Y una segunda causa del mismo bucle que hay que conocer**, porque no tiene ningún `patchValue` a la vista: `disable()` y `enable()` **también disparan `valueChanges`** salvo que les pases `{ emitEvent: false }`. Un ítem que se deshabilita según lo que el inspector responda en otro produce exactamente este ticket.

**La refactorización correcta**

Además de no tocar el formulario, el flujo necesita las dos piezas que impiden guardar de más:

```ts
this.form.valueChanges.pipe(
  debounceTime(1500),
  map(() => toAnswers(this.form)),
  // Sin comparador explícito, distinctUntilChanged compara con === y dos
  // objetos con el mismo contenido nunca son ===: no filtraría nada, y
  // parecería que sí. La serialización es O(n) sobre decenas de elementos y
  // corre como mucho una vez cada segundo y medio.
  distinctUntilChanged((a, b) => serializeAnswers(a) === serializeAnswers(b)),
  // concatMap y no switchMap: cancelar un PATCH que ya salió no cancela nada
  // en el servidor, sólo te deja sin saber si llegó. Para escrituras, cola.
  concatMap((answers) =>
    this.inspectionApi.saveAnswers(this.inspectionId, answers).pipe(
      // El catchError va DENTRO, protegiendo sólo la petición. En el pipe
      // externo mataría el valueChanges para siempre: un fallo y el autosave
      // no vuelve a funcionar hasta recargar. Ver el apéndice A06 §6.
      catchError(() => of(null)),
    ),
  ),
  takeUntilDestroyed(this.destroyRef),
).subscribe();
```

**Prueba de regresión**

```ts
// src/app/features/inspections/inspection-form/inspection-form.component.spec.ts
it('no vuelve a guardar como consecuencia de haber guardado', fakeAsync(() => {
  component.form.controls['main-cable'].patchValue({ note: 'a' });
  tick(1500);

  const first = httpMock.expectOne((r) => r.method === 'PATCH');
  first.flush({ id: 500, answers: [{ itemId: 'main-cable', answer: '', evidenceUrl: null, note: 'a' }] });
  tick(3000);

  // Falla antes del fix: la respuesta parcheaba el formulario, valueChanges
  // volvía a emitir, y aquí había un segundo PATCH esperando.
  httpMock.expectNone((r) => r.method === 'PATCH');
}));

it('no guarda dos veces el mismo contenido', fakeAsync(() => {
  component.form.controls['main-cable'].patchValue({ note: 'a' });
  tick(1500);
  httpMock.expectOne((r) => r.method === 'PATCH').flush({});

  component.form.controls['main-cable'].patchValue({ note: 'a' });   // idéntico
  tick(1500);

  httpMock.expectNone((r) => r.method === 'PATCH');
}));
```

**Prevención**

El primer test es la prevención de verdad, y su nombre lo dice: *no vuelve a guardar como consecuencia de haber guardado*. Es la formulación general del bucle y se puede copiar a cualquier pantalla con autosave.

Y una regla de revisión: **cualquier escritura al formulario dentro de una suscripción que nazca del propio formulario es un bucle hasta que se demuestre lo contrario.**

**Por qué llegó a producción**

El `patchValue` se añadió con la mejor intención y por una razón real: **el servidor normaliza**. Recorta espacios, y en algún momento se decidió que la pantalla debía reflejar lo normalizado. Con el mock local respondiendo en dos milisegundos, el debounce de 1500 ms absorbía la realimentación y el bucle **no se notaba**: parecía que sólo salía una petición.

En UAT, con latencia real y un inspector escribiendo seguido, las emisiones dejaron de solaparse y el ciclo se hizo visible. **El bug estuvo siempre; lo que cambió fue el tiempo de respuesta.** Es la razón por la que el inyector de caos de la Fase 3 existe: sin latencia, media docena de bugs de este curso no se pueden ver.

**Si tu causa fue distinta a esta**

Si concluiste que el `debounceTime` es muy corto, subirlo espacia el bucle y no lo rompe: con 5000 ms tendrías una petición cada cinco segundos, para siempre. Si concluiste que falta `distinctUntilChanged`, tienes razón en que falta —y con el comparador puesto **el bucle se detendría**, porque el contenido no cambia—; es un arreglo que funciona por accidente y deja el ciclo intacto para el día que el servidor sí devuelva algo distinto. Y si tu fix fue `{ emitEvent: false }`, lee otra vez el párrafo del parche: funciona y pierde escritura del usuario.

</details>

---
EOF
wc -l cuaderno-incidentes.md

# --- 2026-09-07T01:33:56 · Write incidents 12-14
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 12 — "Aprobé la inspección y el sistema me dejó, pero el cable está para cambiar"

> **Fase:** 9 · **Categoría:** Tipos (strict) · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-70 min

### 🎫 El ticket

> *"Aprobé la inspección del ascensor de la torre A y el sistema me dejó, pero el cable está para cambiar: lo puse como hallazgo crítico. ¿No era que un crítico bloqueaba la aprobación? En la pantalla de hallazgos sale bien, en rojo y todo."*

**Reportado por:** supervisor de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Explicar por qué la pantalla muestra el hallazgo correctamente y la regla no lo ve, y decidir **en cuál de tres sitios posibles** va el arreglo. Los tres funcionan hoy; sólo uno sigue funcionando en la Fase 10 y en la 11.

### 🔧 Preparación

El bug está en el dato: un `db.json` alterno.

```bash
cp mock/db.json mock/db.mio.json
cp mock/db.incidente-12.json mock/db.json
npm run mock
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

La pantalla ya aplicó tus valores por defecto. El cuerpo crudo de la respuesta, no. Mira el JSON de `/findings?inspectionId=…` en la pestaña Response, **por columnas y no por filas**.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Una de las filas no trae la clave `resolvedAt`. No es que valga `null`: es que **no existe**. Y el tipo `Finding` la declara como `string | null`. ¿Quién comprobó eso?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

```js
finding.resolvedAt === null;    // ?
finding.resolvedAt == null;     // ?
'resolvedAt' in finding;        // ?
```

Escribe las tres en la consola. La primera es la que hay en el código.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El hallazgo llega **sin la clave `resolvedAt`**, así que su valor es `undefined`. La regla compara con `=== null`, y `undefined === null` es `false`:

```ts
// src/app/core/domain/inspection-findings.ts
const blocking = findings.filter(
  (finding) => finding.severity === 'critical' && finding.resolvedAt === null,
);
// El hallazgo crítico no entra en la lista. No bloquea. La aprobación sigue.
```

La pantalla lo muestra bien porque pinta `severity` y `description`, que sí llegan. **El campo que decide es el único que falta**, y nadie lo comprueba: entre el tipo que lo declara y el servidor que no lo manda no hay ninguna verificación.

```ts
export interface Finding {
  readonly resolvedAt: string | null;   // una promesa, no una comprobación
}
```

> ⚠️ **`strict: true` no te salva de esto, y conviene entender por qué.** El compilador comprueba lo que **declaraste**, y tú declaraste `string | null`. Nunca vio la respuesta. `this.http.get<Finding[]>(url)` **no valida nada**: el genérico es una promesa que tú le haces al compilador sobre datos que vienen de fuera. `strict` protege la frontera entre tus archivos; la frontera con la red la defiendes tú.

**Parche mínimo**

El de un viernes, en el sitio donde se manifestó:

```ts
const blocking = findings.filter(
  (finding) => finding.severity === 'critical' && (finding.resolvedAt ?? null) === null,
);
```

**La refactorización correcta**

El `?? null` puede ir en tres sitios y los tres arreglan esta pantalla:

| Dónde | Esta pantalla | La emisión (Fase 10) | El dashboard (Fase 11) |
|---|---|---|---|
| en el componente | ✅ | ❌ | ❌ |
| en la regla de dominio | ✅ | ✅ | ❌ si no la usa |
| **en el borde HTTP** | ✅ | ✅ | ✅ |

```ts
// src/app/core/api/finding-api.service.ts — el borde, donde el dato entra
getByInspection(inspectionId: number): Observable<readonly Finding[]> {
  return this.http.get<unknown>(`${this.baseUrl}/findings`, { params: { inspectionId } }).pipe(
    map((response) => {
      if (!Array.isArray(response)) {
        throw new ApiError('El servidor devolvió algo que no es una lista de hallazgos.');
      }
      // Normalizar una vez, aquí. A partir de este punto el dominio confía:
      // `resolvedAt` es `string | null` y nunca `undefined` ni ausente.
      return response.map((raw) => toFinding(raw));
    }),
  );
}
```

> 🧭 **La regla del proyecto: lo que entra por la red se normaliza una vez, en el borde, y a partir de ahí el dominio confía.** Un `?? null` repartido por cinco componentes es cinco sitios donde alguien puede olvidarse; uno en el `*ApiService` es un sitio donde alguien puede leerlo.

**Prueba de regresión**

```ts
// src/app/core/domain/inspection-findings.spec.ts
it('bloquea con un hallazgo crítico cuyo resolvedAt llega ausente', () => {
  // Así viene del servidor: SIN la clave. `as unknown as Finding` es
  // deliberado — reproduce lo que el genérico de HttpClient deja pasar.
  const finding = {
    id: 904, inspectionId: 503, itemId: 'main-cable',
    severity: 'critical', description: 'Desgaste severo',
  } as unknown as Finding;

  // Falla antes del fix: `undefined === null` es false y el array salía vacío.
  expect(blockingFindings([finding]).length).toBe(1);
});

it('no bloquea con un crítico ya resuelto', () => {
  const finding = { severity: 'critical', resolvedAt: '2024-01-10T09:00:00-05:00' } as Finding;
  expect(blockingFindings([finding]).length).toBe(0);
});
```

```ts
// src/app/core/api/finding-api.service.spec.ts — el test del borde
it('normaliza un resolvedAt ausente a null', () => {
  service.getByInspection(503).subscribe((findings) => {
    expect(findings[0].resolvedAt).toBeNull();
    expect('resolvedAt' in findings[0]).toBeTrue();
  });
  httpMock.expectOne((r) => r.url.endsWith('/findings')).flush([{ id: 904, severity: 'critical' }]);
});
```

**Prevención**

La normalización en el borde, y una regla que la sostiene: **ninguna respuesta HTTP entra al dominio sin pasar por una función `toX()` que la estreche.** Ya existe para las plantillas desde la Fase 3; lo que faltaba era aplicarla a los hallazgos.

**Por qué llegó a producción**

El campo `resolvedAt` se añadió al modelo cuando se implementó la resolución de hallazgos, y el mock lo sembró en todas las filas. La regla se escribió mirando esos datos, donde `null` siempre estaba. **Con el dato de la semilla, `=== null` es correcto.**

El fallo aparece cuando entra un hallazgo por otra vía —una carga masiva, una integración, un `POST` de un cliente que no manda el campo— y omite una clave opcional. Nada en el sistema lo rechaza, nada lo avisa, y la regla más importante del dominio deja de aplicarse en silencio.

Y hay un agravante de proceso que hay que decir: **no había ningún test que probara la regla con un dato incompleto.** Todos los tests usaban objetos construidos a mano, con todos los campos. Un test así no puede detectar esta familia jamás.

**Si tu causa fue distinta a esta**

Si concluiste que el backend está mal y que lo arreglen ellos, tienes razón **y no cambia tu trabajo**: un cliente que se cae porque el servidor omitió un campo opcional es un cliente frágil. Si tu fix fue `finding.resolvedAt!`, silenciarías la única señal disponible — y la guía prohíbe el aserto de no-nulo en este proyecto precisamente por esta familia. Si concluiste que hay que hacer el campo obligatorio en el tipo (`resolvedAt: string`), el compilador te dejaría y el dato seguiría llegando ausente: **cambiar el tipo no cambia la respuesta HTTP.**

</details>

---

## Incidente 13 — "El supervisor subió la severidad de un hallazgo y al día siguiente había vuelto a bajar"

> **Fase:** 9 · **Categoría:** Tipos (strict) · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-70 min

### 🎫 El ticket

> *"El supervisor subió la severidad del hallazgo de la iluminación de menor a mayor el jueves, porque el cliente tiene un requisito adicional. El viernes había vuelto a bajar sola. Nadie la tocó, y no aparece en ningún registro quién la cambió."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Determinar si el cambio se guardó o no —son dos investigaciones distintas— y arreglarlo. El post-mortem tiene que decir además qué parte de este ticket **no** se puede arreglar con este fix.

### 🔧 Preparación

```bash
git switch -c incidente/13 fase-09
npm run mock
npm start
# Sube la severidad del hallazgo 901 (cabin-lighting, inspección 503) y recarga
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de acusar a nadie de no haber guardado: compara lo que el servidor tiene con lo que la pantalla muestra. Son dos comandos y descartan media investigación — y hacerlo **antes** de preguntarle a una persona es la diferencia entre un post-mortem y una conversación incómoda.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s "http://localhost:3000/findings/901" -H "Authorization: Bearer <token>"
```
…y en la consola, `ng.getComponent($0).finding.severity`. Si no coinciden, el dato se guardó y algo lo está recalculando encima.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`cabin-lighting` tiene `nonComplianceSeverity: 'minor'` en la v2 de `elevator-annual`. ¿De dónde saca la pantalla la severidad que pinta: del hallazgo o del ítem de la plantilla? ¿Y qué pasa cuando el sistema tiene dos fuentes de verdad para el mismo campo?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

```bash
# Lo que el servidor guarda:
curl -s http://localhost:3000/findings/901 | grep severity
# "severity": "major"      ← el PATCH del jueves funcionó
```

```js
// Lo que la pantalla muestra:
ng.getComponent($0).finding.severity;   // 'minor'
```

El dato se guardó. Lo que ocurre es que la severidad **se deriva** del ítem de la plantilla cada vez que se lee, y la derivación pisa lo guardado:

```ts
// src/app/core/domain/finding-severity.ts
export function severityOf(item: ChecklistItem, answer: string): Severity {
  return isNonCompliant(item, answer) ? item.nonComplianceSeverity : 'minor';
}
```

`cabin-lighting` declara `nonComplianceSeverity: 'minor'` en la v2, así que la regla devuelve `minor` cada vez que alguien recarga. **El sistema tiene dos fuentes de verdad para el mismo campo y la derivada gana siempre, en silencio.** No hay error, no hay conflicto, no hay aviso.

**Y aquí está la parte de tipos**, que es por lo que este incidente vive en esa categoría: la forma natural de arreglarlo es una anulación explícita, y la forma natural de escribirla es la equivocada.

```ts
// ❌ Opcional: "no me molesté en decidirlo".
severityOverride?: Severity;
// Un hallazgo sin anulación trae la clave ausente; otro trae `undefined` porque
// alguien la puso y la quitó; otro trae `null`. Tres formas de decir lo mismo,
// y la comprobación que las distinga se escribe mal la primera vez — que es
// exactamente el incidente 12.
```

**Parche mínimo**

No hay parche honesto de una línea: el modelo necesita un campo que no existe. Lo mínimo defendible es **dejar de derivar en la lectura** mientras se decide, y eso hay que decirlo en el ticket, porque es un cambio de comportamiento:

```ts
// Hotfix declarado: la pantalla muestra lo guardado. Deja de reflejar cambios
// de la plantilla en hallazgos ya creados, que es un efecto secundario real y
// hay que avisarlo antes de desplegar.
readonly severity = finding.severity;
```

**La refactorización correcta**

```ts
// src/app/core/models/finding.model.ts
export interface Finding {
  readonly severity: Severity;
  /**
   * Anulación manual de la severidad derivada.
   *
   * `null` significa "sin anulación" y es un valor DECIDIDO, no un hueco. La
   * forma opcional (`severityOverride?: Severity`) admitiría tres estados donde
   * el negocio sólo tiene dos, y produce el incidente 12 en otro campo.
   */
  readonly severityOverride: Severity | null;
  readonly overriddenBy: string | null;
  readonly overriddenAt: string | null;
}
```

```ts
// src/app/core/domain/finding-severity.ts
/** La anulación gana, y sólo si existe de verdad. */
export function effectiveSeverity(
  finding: Finding,
  item: ChecklistItem,
  answer: string,
): Severity {
  return finding.severityOverride ?? severityOf(item, answer);
}
```

> 🧭 **La regla del proyecto (guía §6.4): los modelos del dominio distinguen ausencia de vacío.** `severityOverride: Severity | null` dice "aquí no hay anulación"; `severityOverride?: Severity` diría "no me molesté en decidirlo". Es la misma decisión que el incidente 12, tomada al escribir el modelo en vez de al depurar el ticket.

**Prueba de regresión**

```ts
// src/app/core/domain/finding-severity.spec.ts
it('la anulación manual gana sobre la derivada', () => {
  const finding = { severity: 'minor', severityOverride: 'major' } as Finding;

  // Falla antes del fix: la derivación pisaba lo guardado y devolvía 'minor'.
  expect(effectiveSeverity(finding, cabinLightingItem, 'partial')).toBe('major');
});

it('sin anulación, deriva de la plantilla', () => {
  const finding = { severity: 'minor', severityOverride: null } as Finding;
  expect(effectiveSeverity(finding, cabinLightingItem, 'partial')).toBe('minor');
});

it('una anulación ausente se comporta igual que null', () => {
  // El caso del incidente 12, aquí: el dato llega sin la clave.
  const finding = { severity: 'minor' } as unknown as Finding;
  expect(effectiveSeverity(finding, cabinLightingItem, 'partial')).toBe('minor');
});
```

**Prevención**

Los tres tests, la normalización en el borde HTTP del incidente 12 aplicada también a este campo, y una regla de revisión general: **cuando un campo se puede calcular y también se puede escribir, hace falta un tercer campo que diga cuál manda.** Sin él, el conflicto se resuelve por accidente, y se resuelve siempre a favor del cálculo.

**Por qué llegó a producción**

La derivación de severidad se diseñó bien y para un caso real: **cuando la norma cambia, los hallazgos tienen que reflejar la severidad nueva sin que nadie los toque uno a uno.** Ese requisito es correcto y sigue vigente.

Lo que nadie previó es que un supervisor necesitara **subir** la severidad de un caso concreto por un requisito del cliente. No es un caso raro: es un caso que no estaba en la conversación inicial. El sistema se diseñó para un mundo donde la plantilla siempre tiene razón, y funcionó hasta que apareció alguien con más información que la plantilla.

**Y hay una mitad de este ticket que el fix no arregla**, y el post-mortem tiene que decirlo: *"no aparece en ningún registro quién la cambió"*. Los campos `overriddenBy` y `overriddenAt` de la refactorización guardan quién y cuándo, y aun así **no hay historial**: sólo la última anulación. En un sistema cuyo dominio **es** la trazabilidad, esa ironía es el límite del patrón de estado que el **Apéndice A07** §8 nombra por escrito, y saldarlo de verdad exige una decisión de arquitectura que no cabe en un incidente.

**Si tu causa fue distinta a esta**

Si tu primera hipótesis fue "el supervisor no guardó bien", es la más natural y es la que hay que descartar **primero y con un `curl`**, no preguntando. Si concluiste que hay que quitar la derivación y guardar siempre la severidad, es tentador y peor: el día que la norma cambie el `nonComplianceSeverity` de un ítem, los hallazgos viejos seguirán diciendo lo de antes y nadie sabrá si eso es correcto o es un dato viejo. **La derivación es la decisión correcta; lo que faltaba era la anulación explícita**, que es otra cosa.

</details>

---

## Incidente 14 — "Descargué el certificado y la tabla de hallazgos no dice lo mismo que la pantalla"

> **Fase:** 10 · **Categoría:** Trazabilidad · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> *"Descargué el certificado de la 502 para mandárselo al cliente y la tabla de hallazgos dice que hay uno mayor sin resolver. Lo resolvimos ayer. La pantalla del sistema tampoco lo decía cuando lo descargué, pero yo llevaba la pestaña abierta desde la mañana."*

**Reportado por:** supervisor de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Localizar de dónde salieron los datos del PDF, arreglarlo, y explicar en el post-mortem por qué este bug es **cualitativamente distinto** de una pantalla desactualizada.

### 🔧 Preparación

```bash
git switch -c incidente/14 fase-10
npm run mock
npm start
```

Reproducción, con dos pestañas y sin ninguna herramienta:

```
1. Abre el detalle de un certificado. NO cierres la pestaña.
2. En otra pestaña, marca como resuelto uno de sus hallazgos.
3. Vuelve a la primera y descarga el PDF.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Compara tres cosas, no dos: lo que dice la pantalla, lo que dice el PDF, y lo que dice el servidor. Con esas tres, el bug queda localizado sin abrir un archivo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El PDF coincide con **la pantalla** y no con el **servidor**. Eso no deja ambigüedad: el documento no pidió los datos, los recibió de alguien que ya los tenía.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Mira la **firma** de la función que genera el PDF, no su cuerpo. ¿Qué recibe? ¿De dónde salieron esos parámetros?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

```
Pantalla (abierta desde la mañana):  door-sensor · Mayor · Pendiente
PDF descargado:                      door-sensor · Mayor · Pendiente
Servidor (curl):                     door-sensor · Mayor · RESUELTO
```

El PDF se arma **desde lo que el componente ya tenía pintado**:

```ts
// src/app/features/certificates/certificate-pdf.service.ts
async download(view: CertificateView, findings: readonly InspectionFinding[]): Promise<void> {
  // `view` y `findings` son los objetos que la pantalla cargó cuando se abrió.
  // Todo está aquí, no hace falta pedir nada, y el PDF sale en 50 ms.
}
```

**El bug está en la firma, no en el cuerpo.** Cualquier implementación que reciba lo que el componente ya tenía produce este ticket, por bien escrita que esté.

Y no falló nada: el PDF salió perfecto, con acentos, con la tabla alineada. No hay error en consola, no hay nada rojo en Network, y el documento ya está camino de un correo.

**Parche mínimo**

Aquí **no hay parche mínimo defendible**, y decirlo es parte del entregable. Un `reload()` antes de generar no basta: la pantalla se recargaría, el PDF seguiría armándose desde ella, y la ventana entre la recarga y la generación sigue existiendo. El arreglo es el de abajo.

**La refactorización correcta**

Dos decisiones, y la primera es la mitad del arreglo:

```ts
// src/app/core/pdf/certificate-document.ts
/**
 * Todo lo que el documento necesita, junto y ya resuelto. Que sea una interfaz
 * explícita y no "lo que tenga el componente" es la mitad del arreglo: aquí se
 * ve de un vistazo que hacen falta seis cosas, y las seis tienen que venir de
 * la fuente.
 */
export interface CertificateDocumentSource {
  readonly certificate: Certificate;
  readonly view: CertificateView;
  readonly inspection: Inspection;
  readonly template: ChecklistTemplate;   // la versión CONGELADA de la inspección
  readonly asset: Asset;
  readonly client: Client;
  readonly findings: readonly InspectionFinding[];
}
```

```ts
// Y el servicio pide las seis, otra vez, en el momento de generar.
download(certificateId: string): Observable<void> {
  return this.certificateApi.getById(certificateId).pipe(
    concatMap((certificate) => this.inspectionApi.getById(certificate.inspectionId).pipe(
      concatMap((inspection) => combineLatest({
        certificate: of(certificate),
        inspection: of(inspection),
        // La versión que la inspección GUARDÓ, no la vigente.
        template: this.templateApi.getByVersion(inspection.templateId, inspection.templateVersion),
        asset: this.assetApi.getById(inspection.assetId),
        findings: this.findingApi.getByInspection(inspection.id),
      })),
    )),
    concatMap((source) => from(this.render(source))),
  );
}
```

**Seis peticiones para un PDF, y está bien**: es una acción explícita del usuario, no un render. El día que sean sesenta, la respuesta es un endpoint que devuelva el certificado completo, no una caché en el cliente.

> 🧭 **La regla del proyecto: lo que hay en la pantalla es una foto de hace un rato. Está bien para mirar y está mal para imprimir.** Cualquier artefacto que sobreviva a la sesión —un PDF, un correo, un export— se arma pidiendo el dato otra vez.

**Prueba de regresión**

```ts
// src/app/features/certificates/certificate-pdf.service.spec.ts
it('pide los datos otra vez en vez de usar los de la pantalla', () => {
  service.download('CERT-2024-000502').subscribe();

  // Falla antes del fix: no salía NINGUNA petición, porque los datos llegaban
  // por parámetro. El test comprueba la firma tanto como el comportamiento.
  httpMock.expectOne((r) => r.url.includes('/certificates/CERT-2024-000502'));
  httpMock.expectOne((r) => r.url.includes('/inspections/502'));
  httpMock.expectOne((r) => r.url.includes('/findings'));
  httpMock.expectOne((r) => r.url.includes('/templates') && r.url.includes('version=1'));
});
```

**Prevención**

La firma es la prevención: **una función que no acepta datos ya cargados no puede usarlos.** Y una regla de revisión con nombre: *ningún generador de artefactos exportables recibe objetos de vista como parámetro.*

Además, y esto no previene el bug pero limita su daño: **el pie del PDF lleva la fecha y hora de generación, con zona horaria explícita.** Convierte "este PDF miente" en "este PDF es de antes de la resolución", que es una conversación completamente distinta.

**Por qué llegó a producción**

La primera versión se escribió con toda la información a mano y sin una sola petición: era rápida, simple y funcionaba en todas las pruebas — porque en una prueba nadie deja una pestaña abierta veinte minutos mientras otra persona cambia el dato desde otro equipo.

**El sistema no tiene ningún mecanismo para detectar esto.** No hay error, no hay warning, no hay test que falle. La única forma de encontrarlo es reproducir el escenario de dos pestañas, y ese escenario no se le ocurre a nadie hasta que un cliente recibe un documento equivocado.

Lo que hace peligrosa a esta deuda no es que el dato esté viejo: es que **el PDF es el único artefacto del sistema que sobrevive al sistema.** Una pantalla desactualizada se arregla con F5. Un PDF desactualizado se archiva, se imprime y se adjunta a la respuesta de un requerimiento normativo, y dentro de dos años nadie va a poder decir de qué momento son sus datos. El **Apéndice A08** §7 y §9 lo desarrolla, incluida la parte incómoda: **un PDF ya descargado no se puede revocar.**

**Si tu causa fue distinta a esta**

Si concluiste que el PDF está cacheado, se descarta en un segundo: cada descarga genera el archivo desde cero en el navegador. Si el contenido es viejo, es porque los **datos** lo eran. Si concluiste que la pantalla debería refrescarse sola —con un `interval` o con websockets—, es una mejora legítima de otra conversación y **no arregla esto**: la ventana entre el último refresco y la pulsación del botón sigue existiendo, sólo que más corta. Y una ventana más corta para un bug que produce documentos falsos no es una solución.

</details>

---
EOF
wc -l cuaderno-incidentes.md

# --- 2026-09-07T01:35:32 · Write incidents 15-16
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 15 — "El certificado venció ayer para el sistema y hoy para el cliente, y sólo pasa por la tarde"

> **Fase:** 10 · **Categoría:** Tiempo · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1h30-2h

### 🎫 El ticket

> *"A veces el sistema dice que un certificado está vencido y el cliente nos manda una foto del papel donde dice que vence hoy. Pasa sobre todo por la tarde. Por la mañana no me ha pasado nunca."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar por qué **"sobre todo por la tarde"** no es ruido sino el dato más preciso del reporte, localizar la decisión que nadie tomó, y arreglarla de forma que no dependa de dónde esté parado quien pregunta.

### 🔧 Preparación

```bash
git switch -c incidente/15 fase-10
npm run mock
npm start
```

Y el experimento que reproduce el ticket en tu máquina, que **es parte de la preparación**: cambia la zona horaria de tu sistema operativo a **Auckland (UTC+13)** y recarga. Devuélvela al terminar — hay tests de la Fase 12 que dependen del reloj.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de leer código: mira los **últimos seis caracteres** del campo `validUntil` en el cuerpo crudo de la respuesta. Deciden en qué mitad del sistema está el bug, y se leen en diez segundos.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```js
const validUntil = '2025-02-10T23:59:59-05:00';
new Date(validUntil).toISOString();   // ?
new Date(validUntil).toString();      // ?
```
Las dos son correctas y dicen días distintos. Ahora busca cuál de las dos usa el código para decidir si algo venció.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En Bogotá, `-05:00`, las 19:00 locales son las 00:00 UTC **del día siguiente**. ¿A partir de qué hora del día empiezan a discrepar una comparación hecha en UTC y una hecha en hora local?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El dato está bien: `"validUntil": "2025-02-10T23:59:59-05:00"`, con offset explícito, como toda fecha del proyecto desde la Fase 3. **El bug está en quien lo lee.**

```ts
// src/app/core/domain/certificate-status.ts
const expired = certificate.validUntil.slice(0, 10) < new Date().toISOString().slice(0, 10);
```

Esa línea compara **dos días calculados en husos distintos**:

```js
'2025-02-10T23:59:59-05:00'.slice(0, 10);        // '2025-02-10'  ← día LOCAL del dato
new Date().toISOString().slice(0, 10);            // el día en UTC
```

En Bogotá (`-05:00`), a partir de las **19:00** locales, el día en UTC ya es el siguiente. Desde esa hora, un certificado que vence hoy se compara contra el día de mañana y el sistema lo declara vencido. Antes de las 19:00 el bug no existe.

**Ése es el "sobre todo por la tarde" del ticket**, y era el dato más preciso que traía.

Y las tres conversiones, para ver que las tres son correctas y dicen cosas distintas:

```js
new Date('2025-02-10T23:59:59-05:00').toISOString();   // '2025-02-11T04:59:59.000Z' — MISMO instante
new Date('2025-02-10T23:59:59-05:00').toString();      // el mismo instante, en TU huso
toBusinessDay('2025-02-10T23:59:59-05:00');            // '2025-02-10' — el día del NEGOCIO
```

> 🧠 **Nunca es un bug de fechas.** `Date` hizo exactamente lo que le pidieron, tres veces, con tres resultados correctos. Es un bug de **no haber decidido a qué hora vence algo**, y por eso el arreglo no es un `+1` ni un `-5`.

**Parche mínimo**

No lo hay que sea honesto, y hay que decirlo: los tres arreglos de una línea que aparecen en cualquier revisión **mueven el síntoma a otra hora o a otro huso**.

```ts
// ❌ Los tres, y por qué:
new Date(cert.validUntil) < new Date();                    // compara instantes, no días:
                                                           // vence a las 23:59:59, no al final del día
new Date(cert.validUntil).getTime() + 86400000 < Date.now();  // el bug desaparece por la tarde en
                                                           // Bogotá y aparece por la mañana en Auckland
cert.validUntil.slice(0,10) < todayLocalString();          // depende del huso del navegador: dos
                                                           // usuarios ven cosas distintas
```

**La refactorización correcta**

Una decisión, con nombre, en un archivo, llamada desde todas partes:

```ts
// src/app/core/domain/business-day.ts
/**
 * La zona horaria de las decisiones de negocio de CertCore.
 *
 * No es la del navegador ni la del servidor: es la del país donde la empresa
 * opera y donde la norma aplica. Un certificado vence al final del día ahí,
 * y eso no cambia porque el inspector esté de viaje.
 */
export const BUSINESS_TIME_ZONE = 'America/Bogota';

/** El día de calendario del negocio para un instante ISO. */
export function toBusinessDay(instant: string): string {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: BUSINESS_TIME_ZONE,
    year: 'numeric', month: '2-digit', day: '2-digit',
  }).format(new Date(instant));   // 'en-CA' produce YYYY-MM-DD, que ordena como cadena
}

/** Hoy, según el negocio. */
export function todayInBusinessZone(): string {
  return toBusinessDay(new Date().toISOString());
}
```

```ts
// Y la comparación, que ahora dice lo que significa:
const expired = toBusinessDay(certificate.validUntil) < todayInBusinessZone();
```

> 🧭 **La regla del proyecto: la zona horaria de una decisión de negocio es un dato del negocio, no del entorno.** Cuando esa decisión tiene nombre y vive en un archivo, deja de tomarse por accidente en catorce sitios distintos.

**Prueba de regresión**

```ts
// src/app/core/domain/certificate-status.spec.ts
it('no depende del huso del navegador', () => {
  const certificate = { validUntil: '2025-02-10T23:59:59-05:00' } as Certificate;

  // Las 20:00 de Bogotá del día en que vence: en UTC ya es el día 11.
  // Antes del fix, este caso devolvía 'expired'.
  const bogotaEvening = '2025-02-11T01:00:00.000Z';

  expect(buildCertificateView(certificate, bogotaEvening).status).toBe('valid');
});

it('vence al terminar el día del negocio, no antes', () => {
  const certificate = { validUntil: '2025-02-10T23:59:59-05:00' } as Certificate;

  expect(buildCertificateView(certificate, '2025-02-10T04:00:00.000Z').status).toBe('valid');
  expect(buildCertificateView(certificate, '2025-02-11T06:00:00.000Z').status).toBe('expired');
});
```

> 💡 **Fíjate en que el instante entra por parámetro y no se lee de `new Date()` dentro.** Ésa es la diferencia entre un test determinista y uno que falla una vez al año a las 19:00 — que es el incidente 17.

**Prevención**

Los tests de arriba, y una regla de lint que se puede automatizar: **`new Date()` y `Date.now()` no se llaman dentro de funciones de dominio.** El instante entra siempre por parámetro. Con eso, todo el dominio de tiempo del proyecto se vuelve determinista y probable.

```bash
# La comprobación, mientras la regla de lint no exista:
grep -rn "new Date()\|Date.now()" src/app/core/domain/ && echo "❌ el dominio no pregunta la hora"
```

**Por qué llegó a producción**

Durante todo el desarrollo, la máquina de todo el equipo estuvo en `America/Bogota`. Con ese huso, `toISOString().slice(0,10)` y el día local **coinciden diecinueve horas de cada veinticuatro**, y las cinco que no coinciden son de 19:00 a medianoche — fuera del horario en que nadie estaba probando.

En PROD el patrón se invirtió: los coordinadores cierran certificaciones **a última hora de la tarde**, que es exactamente la ventana rota. El bug no llegó a producción por descuido: llegó porque **el entorno de desarrollo hacía imposible verlo**, y nadie tenía la costumbre de cambiar el reloj del sistema para probar.

Es la razón por la que este curso insiste en fechas con offset explícito desde el `db.json`: el dato correcto es lo único que permitió que el arreglo fuera una lectura y no una migración de datos históricos.

**Si tu causa fue distinta a esta**

Si concluiste "hay que guardar todo en UTC", es la respuesta estándar y resuelve el problema equivocado: UTC te da un **instante** sin ambigüedad, y eso ya lo tienes con el offset. Lo que UTC no te da es el **día de calendario del negocio**, que es lo que decide si un certificado está vencido.

Si concluiste que es un bug de `Date` y hay que meter una librería de fechas, una librería te habría dado mejores herramientas para escribir la misma decisión — y la decisión seguiría sin estar tomada. Si tu fix fue sumar un día, mueve el error de sitio: desaparece por la tarde en Bogotá y aparece por la mañana en Auckland.

Y si concluiste que el `status: "valid"` guardado en el `db.json` es el culpable, has encontrado **otro bug real** que no es éste: un estado que se calcula pero se almacena empieza a mentir al día siguiente. La Fase 10 lo convierte en derivado, y merece su propio apunte en los pendientes.

</details>

---

## Incidente 16 — "Cerré el panel hace media hora y el servidor sigue recibiendo peticiones mías"

> **Fase:** 11 · **Categoría:** Performance · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

> *"El de infraestructura me preguntó por qué mi usuario está haciendo peticiones cada minuto si yo cerré el panel a las once. Y sí: tengo la aplicación abierta, pero en otra pantalla. Además el navegador se va poniendo lento durante la mañana."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Confirmar cuántas suscripciones vivas hay —el número, no sólo el hecho—, localizar cuál es, y cerrarla en el estilo que corresponda al archivo.

### 🔧 Preparación

```bash
git switch -c incidente/16 fase-11
npm run mock
npm start
# Entra al panel, sal al listado de clientes, y repite cinco veces
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Network con el filtro en `Fetch/XHR`, **fuera** del panel, y dos minutos de paciencia sin tocar nada. No hace falta abrir el código para saber si hay una fuga y **cuántas**.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El ritmo te dice el número: si el refresco era de un minuto y ves cinco pares de peticiones por minuto, hay cinco pantallas zombis. Ahora la pregunta es qué suscripción sobrevive al componente — y no todas pueden.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un observable de `HttpClient` completa solo y no se puede fugar. ¿Cuál de los observables del panel **no completa nunca**?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

```
# Network, fuera del panel, dos minutos:
certificates   200   xhr   14 ms
inspections    200   xhr   22 ms
certificates   200   xhr   11 ms
inspections    200   xhr   19 ms
…cinco pares por minuto tras cinco visitas al panel
```

`DashboardComponent` se suscribe a un `interval` para refrescar las métricas y **no lo corta al destruirse**:

```ts
// src/app/features/dashboard/dashboard.component.ts
ngOnInit(): void {
  // `interval` NO completa nunca. Este componente sí se destruye. La
  // suscripción sobrevive a su dueño, y eso es la definición de una fuga.
  interval(60_000)
    .pipe(switchMap(() => this.dashboardState.reload()))
    .subscribe();
}
```

Cada visita al panel deja un `interval` corriendo. Cinco visitas, cinco refrescos por minuto, para siempre — y con ellos, cinco componentes que el recolector de basura no puede liberar. Eso explica las dos mitades del ticket: **el tráfico** y **el navegador que se pone lento durante la mañana**.

> 🧠 **No toda suscripción sin cerrar es una fuga.** Una fuga es una suscripción que **sobrevive a quien la creó**. El `subscribe` a `HttpClient` de dos líneas más arriba no lo es: completa al llegar la respuesta. El del `interval` sí, porque `interval` no completa nunca.

**Parche mínimo**

El archivo es **nuevo** (standalone, `inject()`), así que el parche va en estilo nuevo:

```ts
// src/app/features/dashboard/dashboard.component.ts
private readonly destroyRef = inject(DestroyRef);

ngOnInit(): void {
  interval(60_000)
    .pipe(
      switchMap(() => this.dashboardState.reload()),
      // Corta cuando Angular destruye el componente. Sin argumento sólo se
      // puede llamar en el contexto de inyección; aquí estamos en ngOnInit,
      // así que el DestroyRef va explícito. Ver el apéndice A04 §7.
      takeUntilDestroyed(this.destroyRef),
    )
    .subscribe();
}
```

**La refactorización correcta**

El refresco periódico no es del componente: es del estado. Y así, además, deja de reiniciarse cada vez que alguien entra al panel:

```ts
// src/app/core/state/dashboard-state.service.ts
/**
 * El refresco vive aquí, no en la pantalla. `providedIn: 'root'` significa que
 * hay uno solo, y `refCount: true` que sólo corre mientras alguien mire — con
 * `refCount: false` seguiría pidiendo con el panel cerrado, que es este mismo
 * incidente escrito de otra manera. Ver el apéndice A06 §7.
 */
readonly metrics$ = interval(60_000).pipe(
  startWith(0),
  switchMap(() => this.load()),
  shareReplay({ bufferSize: 1, refCount: true }),
);
```

Y el componente se queda con un `async` pipe y **ninguna suscripción manual**, que es el sitio donde este bug ya no puede existir.

**Prueba de regresión**

```ts
// src/app/features/dashboard/dashboard.component.spec.ts
it('deja de refrescar cuando se destruye', fakeAsync(() => {
  fixture.detectChanges();
  httpMock.expectOne((r) => r.url.includes('/certificates')).flush([]);

  tick(60_000);
  httpMock.expectOne((r) => r.url.includes('/certificates')).flush([]);   // el refresco periódico

  fixture.destroy();
  tick(180_000);

  // Falla antes del fix: el interval seguía vivo y aquí había tres peticiones
  // más esperando. `verify()` en el afterEach las habría delatado igual.
  httpMock.expectNone((r) => r.url.includes('/certificates'));
  discardPeriodicTasks();
}));
```

**Prevención**

El test de arriba, replicado en cualquier pantalla con refresco periódico, y una regla de revisión que se puede automatizar a medias:

```bash
# Todo subscribe manual sobre una fuente que no completa necesita corte.
grep -rn "interval(\|timer(.*,\|fromEvent(" src/app --include="*.ts" | grep -v spec
```

Y la regla de oro del curso, que es la prevención de fondo: **`async` pipe para pintar, `.subscribe()` para efectos — y entonces alguien se desuscribe.** El panel refactorizado no tiene ninguna suscripción manual, y por eso no puede fugarse.

**Por qué llegó a producción**

El refresco automático se añadió tarde, en la última semana antes de una demostración, y se probó de la única manera en que este bug es invisible: **abriendo el panel y mirándolo**. Nadie salió y volvió cinco veces.

El sistema tampoco ayuda: una fuga de suscripción **no produce ningún síntoma inmediato**. La primera visita funciona perfecto, la segunda también, y el coste se acumula tan despacio que cuando alguien lo nota ya no lo relaciona con nada que se haya desplegado. Aquí lo detectó **infraestructura**, mirando tráfico — no el equipo de desarrollo, y no un test.

**Si tu causa fue distinta a esta**

Si concluiste que hay que poner `OnPush` en el panel, es el sospechoso 4 puesto en primer lugar: `OnPush` decide cuándo se **revisa** un componente, y una fuga es un componente que **ya no existe** y sigue trabajando. No se tocan. Si concluiste que el `switchMap` cancela y por tanto no hay problema, cancela la petición **anterior de la misma suscripción**, no la suscripción: hay cinco `interval` independientes, cada uno con su `switchMap` funcionando perfectamente. Y si tu fix fue subir el intervalo a cinco minutos, espacia el tráfico y deja las cinco suscripciones vivas: el navegador se sigue poniendo lento.

</details>

---
EOF
wc -l cuaderno-incidentes.md

# --- 2026-09-07T01:37:55 · Write incidents 17-19
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 17 — "El test pasa en mi máquina y falla en el pipeline, y nadie tocó nada"

> **Fase:** 12 · **Categoría:** Testing · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1h30-2h

### 🎫 El ticket

> *"El pipeline lleva tres días fallando de forma intermitente y nadie ha tocado esos tests. A veces pasa si relanzo el job. En mi máquina siempre pasa. Ya hay gente relanzando sin mirar."*

**Reportado por:** tu líder técnico
**Ambiente:** integración continua

### 🎯 Qué se te pide

Hacerlo determinista **antes** de investigar, localizar la pareja de tests que se contamina, y arreglarla. Y el entregable incluye una frase para el equipo sobre por qué relanzar no es una opción.

### 🔧 Preparación

```bash
git switch -c incidente/17 fase-12
ng test --watch=false --browsers=ChromeHeadless
# Repítelo. Anota la semilla que Jasmine imprime al principio de cada ejecución.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Un fallo que ocurre una de cada diez veces no se investiga: **se hace ocurrir siempre**. Lo primero que Jasmine imprime es lo primero que casi nadie lee, y es exactamente lo que te permite reproducirlo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Con la semilla fija, el fallo es reproducible. Ahora bisecciona: marca la mitad de los `describe` con `xdescribe`, corre con la misma semilla, y quédate con la mitad que sigue fallando. Siete iteraciones bastan para toda la suite.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Lo que queda es una pareja de tests que no deberían conocerse. ¿Qué comparten? Piensa en qué **no** limpia el `TestBed` entre `it` de `describe` distintos: lo que vive fuera de Angular.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

```
Randomized with seed 47291
Chrome Headless 120.0.0: Executed 128 of 128 SUCCESS (2.104 secs)

Randomized with seed 83104
Chrome Headless 120.0.0: Executed 128 of 128 (1 FAILED) (2.233 secs)

  AuthGuard
    ✗ redirige al login cuando no hay sesión
      Expected UrlTree to be true.
```

Falla **según la semilla**, así que es el orden. Y con la semilla fija (`ng test --seed=83104`) más la bisección, la pareja aparece:

```ts
// auth.service.spec.ts — deja un token puesto y no lo limpia
it('guarda el token al iniciar sesión', () => {
  service.login({ email: 'inspector@certcore.co', password: 'certcore123' }).subscribe();
  httpMock.expectOne('/auth/login').flush({ accessToken: VALID_TOKEN });

  expect(localStorage.getItem('certcore.accessToken')).toBe(VALID_TOKEN);
  // …y aquí termina. El token sigue en localStorage.
});
```

```ts
// auth.guard.spec.ts — asume que no hay sesión
it('redirige al login cuando no hay sesión', () => {
  // No hay ningún setup que garantice que NO hay sesión: se da por hecho.
  expect(authGuard(route, state)).toBeInstanceOf(UrlTree);
});
```

**`localStorage` no lo limpia nadie.** `TestBed.resetTestingModule()` reconstruye el inyector entre tests y no toca el almacenamiento del navegador, que vive fuera de Angular. Si el spec del servicio corre **antes** que el del guard, el guard encuentra una sesión válida, devuelve `true`, y el test falla.

Con la semilla `47291` el orden es el contrario y todo pasa. **En tu máquina siempre pasa** porque Karma en modo `--watch` reutiliza la misma semilla mientras no reinicies.

> 🧭 **Un test que sólo pasa si otro corrió antes no es un test: es media prueba.** Y su fallo aparece el día que alguien añada un `it` en otro archivo, que es cuando nadie lo va a relacionar con nada.

**Parche mínimo**

```ts
// src/app/core/auth.service.spec.ts
afterEach(() => {
  // localStorage vive fuera de Angular: el TestBed no lo limpia.
  localStorage.clear();
});
```

**La refactorización correcta**

Un `afterEach` en el spec culpable arregla **esta** pareja y deja el mecanismo intacto para el siguiente que escriba en `localStorage`. La limpieza va donde no se pueda olvidar:

```ts
// src/test.ts — se ejecuta una vez, y aplica a toda la suite.
afterEach(() => {
  // Todo lo que vive fuera de Angular y sobrevive al TestBed.
  localStorage.clear();
  sessionStorage.clear();
});
```

Y la mitad que de verdad previene: **cada test declara el estado del que parte en vez de asumirlo.**

```ts
// src/app/core/guards/auth.guard.spec.ts
beforeEach(() => {
  // El escenario, explícito. Un test que dice de qué parte se puede leer
  // aislado, y deja de depender de en qué orden lo ejecuten.
  localStorage.removeItem('certcore.accessToken');
});
```

**Prueba de regresión**

Aquí la "prueba" es que el fallo deje de depender del orden, y eso se comprueba forzando el orden peor:

```ts
// src/app/core/guards/auth.guard.spec.ts
describe('authGuard con estado sucio de otro test', () => {
  beforeEach(() => {
    // Reproduce exactamente lo que dejaba el spec de AuthService.
    localStorage.setItem('certcore.accessToken', VALID_TOKEN);
  });

  it('parte de un estado limpio pase lo que pase antes', () => {
    // Falla antes del fix: el guard veía la sesión y devolvía true.
    // El beforeEach del propio spec tiene que ganarle al residuo.
    expect(authGuard(route, state)).toBeInstanceOf(UrlTree);
  });
});
```

Y la comprobación de que el arreglo es real, que es la que hay que dejar en el pipeline:

```bash
# La misma semilla que fallaba, tres veces. Si pasa las tres, está cerrado.
for i in 1 2 3; do ng test --watch=false --browsers=ChromeHeadless --seed=83104 || exit 1; done
```

**Prevención**

El `afterEach` global de `test.ts`, y una regla de revisión: **un test no asume el estado del que parte; lo declara.** Si un `it` necesita que no haya sesión, la quita él, aunque "obviamente" no la haya.

Y una decisión de proceso que vale más que las dos: **fijar y registrar la semilla en el pipeline.** Un pipeline que aleatoriza sin dejar rastro de la semilla produce fallos que nadie puede reproducir; uno que la imprime y la conserva convierte cada fallo en un caso investigable.

**Por qué llegó a producción**

Al pipeline, no a producción — y es un matiz importante, porque el daño de este incidente es distinto: **erosiona la confianza en la suite entera**. Cuando el equipo aprende que los rojos a veces son mentira, el día que uno sea real nadie va a mirarlo.

El sistema lo permitió por tres decisiones separadas, ninguna mala por sí sola. Jasmine aleatoriza el orden **a propósito**, para detectar exactamente esto. Karma en `--watch` reutiliza la semilla, así que en local nunca varía. Y `localStorage` es global por diseño del navegador. La combinación de las tres hace que el bug sea invisible en desarrollo y frecuente en integración continua.

**Y la frase para el equipo**, que es parte del entregable:

> *Relanzar el job hasta que pase no es una decisión neutra: es enseñarle al equipo a ignorar los rojos. Un test intermitente es un test roto, aunque el código que prueba esté bien, y vale menos que no tenerlo — porque además genera confianza.*

**Si tu causa fue distinta a esta**

Si concluiste que el pipeline es más lento y por eso falla, tienes razón en el mecanismo de otros intermitentes y no de éste: el tiempo no cambia el orden de los `describe`. Si tu hipótesis fue el reloj, se descarta en un `grep`: ningún archivo de esa pareja llama a `new Date()`. Si tu fix fue marcar el test con `xit` "mientras tanto", es legítimo **como decisión consciente y con fecha**, y un desastre como reflejo: un `xit` sin comentario ni ticket es un test que nadie va a volver a mirar — y el coverage sigue contando sus líneas si otro test las toca de refilón, que es el incidente 20.

</details>

---

## Incidente 18 — "Desplegamos el arreglo hace dos horas y la gente sigue viendo el error; a mí me funciona"

> **Fase:** 13 · **Categoría:** Despliegue · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1h-1h30

### 🎫 El ticket

> *"Desplegamos el arreglo del formulario hace dos horas y la gente sigue viendo el error. A mí me funciona perfecto. Ya le dije a dos personas que recargaran y una dice que sigue igual."*

**Reportado por:** tu líder técnico
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar por qué a unos les funciona y a otros no, y por qué **"a mí me funciona"** es en este ticket un dato técnico y no una excusa. Arreglar la causa, no el episodio.

### 🔧 Preparación

```bash
git switch -c incidente/18 fase-13
docker build -t certcore:inc18 .
docker run --rm -d --name certcore-inc18 -p 8080:80 \
  -e ENVIRONMENT_NAME=PROD -e API_BASE_URL=/api certcore:inc18
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No uses tu navegador para diagnosticar esto: lleva meses con *Disable cache* puesto y te va a mentir con la mejor intención. Usa `curl`, que no tiene opiniones.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -I http://localhost:8080/
```
Mira la cabecera `Cache-Control`. Después piensa qué archivos del `dist/` llevan hash en el nombre y cuáles no.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el navegador conserva el `index.html` de ayer, ese HTML referencia los bundles de ayer — que siguen existiendo en el servidor, porque un despliegue no borra nada. ¿Qué versión de la aplicación está ejecutando ese usuario, y produce algún error?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

```
$ curl -I http://localhost:8080/
HTTP/1.1 200 OK
Content-Type: text/html
Cache-Control: public, max-age=31536000     ← un año, sobre el index.html
```

El `nginx.conf` aplica la política de caché de los bundles **a todo**, incluido el `index.html`. Los bundles llevan hash en el nombre (`main.8a1f2c.js`) y se pueden cachear un año sin riesgo: un nombre distinto es un archivo distinto. El `index.html` **no lleva hash** y cambia en cada despliegue.

El resultado es que el navegador de cada usuario conserva el `index.html` de la última visita, que referencia los bundles de esa versión — **que siguen existiendo en el servidor, porque un despliegue no borra nada**. Esos usuarios ejecutan la aplicación de ayer, completa y funcionando, sin ningún error que delate nada.

**Y "a mí me funciona" es el dato clave:** quien lo dice tiene DevTools abierto con *Disable cache*. Es el único de todo el equipo que **nunca** ha visto este bug, y por eso es también quien lo va a descartar más rápido.

> 🧭 **La regla que cabe en una frase y resuelve toda la política de caché de una SPA: lo que lleva hash en el nombre se cachea para siempre; lo que no lleva hash no se cachea nunca.** Equivocarse en el lado del `index.html` produce el bug más frustrante que existe: el que ya arreglaste.

**Parche mínimo**

```nginx
# nginx.conf
# Los bundles llevan hash: su contenido nunca cambia. Un año, sin miedo.
location ~* \.(js|css|woff2?)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# El index.html NO lleva hash y cambia en cada despliegue.
# `no-store` y no `no-cache`: el segundo permite guardar y revalidar, y un proxy
# intermedio puede interpretar la revalidación con generosidad.
location = /index.html {
    add_header Cache-Control "no-store";
}

# Y lo mismo para la configuración de arranque, por la misma razón.
location = /assets/config.json {
    add_header Cache-Control "no-store";
}
```

```bash
docker build -t certcore:inc18-fix .
curl -I http://localhost:8080/ | grep -i cache
# Cache-Control: no-store
```

**La refactorización correcta**

El parche arregla los despliegues futuros y **no alcanza a quien ya tiene el HTML malo cacheado un año**. Para ésos hay dos caminos, y conviene saber cuál se puede:

- **Si hay una CDN o un proxy delante**, se invalida la ruta `/` y el problema se acaba en minutos.
- **Si no lo hay**, no hay forma de alcanzar esos navegadores. Lo único que queda es un mecanismo de versión en la propia aplicación: la aplicación consulta periódicamente un `version.json` **sin caché** y, si la versión no coincide con la suya, avisa al usuario de que recargue. Es feo, y es lo que hacen los sistemas que ya han pasado por esto una vez.

**Prueba de regresión**

Aquí no hay `.spec.ts`: lo que hay que verificar es la respuesta del servidor, y eso se comprueba contra la imagen construida.

```bash
#!/usr/bin/env bash
# scripts/check-cache-headers.sh — corre en el pipeline, después del build de imagen.
set -euo pipefail
BASE="${1:-http://localhost:8080}"

header() { curl -sI "$1" | tr -d '\r' | grep -i '^cache-control:' | cut -d' ' -f2-; }

# El index.html NO se cachea nunca.
[[ "$(header "$BASE/")" == *"no-store"* ]] \
  || { echo "❌ index.html cacheable: es el incidente 18"; exit 1; }

# La configuración de arranque tampoco.
[[ "$(header "$BASE/assets/config.json")" == *"no-store"* ]] \
  || { echo "❌ config.json cacheable: dos ambientes con la misma config"; exit 1; }

# Y los bundles SÍ, porque llevan hash.
BUNDLE=$(curl -s "$BASE/" | grep -o 'main\.[a-z0-9]*\.js' | head -1)
[[ "$(header "$BASE/$BUNDLE")" == *"immutable"* ]] \
  || { echo "❌ bundles sin caché: cada visita descarga todo otra vez"; exit 1; }

echo "✅ política de caché correcta"
```

**Prevención**

El script de arriba en el pipeline, **después de construir la imagen y antes de promocionarla**. Es la única forma de comprobar una decisión que no vive en el código de la aplicación sino en la configuración del servidor, y que por tanto ningún test unitario puede alcanzar.

**Por qué llegó a producción**

La regla de caché se escribió con una sola intención —que los bundles no se descarguen en cada visita, que es correcto y mejora mucho la experiencia— y se aplicó con un patrón amplio porque en ese momento **todo lo que había que servir llevaba hash**. El `index.html` quedó dentro por omisión, no por decisión.

El fallo es invisible en desarrollo (`ng serve` no cachea), invisible para quien tiene DevTools abierto (que es todo el equipo de desarrollo), y **sólo aparece en el segundo despliegue**, cuando ya hay una versión anterior que conservar. Entre la decisión y su consecuencia pasaron semanas y varios despliegues correctos.

Y hay un agravante de proceso que merece decirse: **la primera reacción del equipo fue pedirle a los usuarios que recargaran**, que no funciona —una recarga normal usa la caché— y consumió dos horas antes de que nadie mirara una cabecera.

**Si tu causa fue distinta a esta**

Si concluiste que el despliegue no llegó, se descarta en el paso 1 del recorrido de `forense-fase-13.md`: los digests de la imagen coinciden. Si concluiste que es la CDN, puede serlo **y se comprueba igual**: si `curl` directo al origen ya devuelve la cabecera mala, la CDN está obedeciendo. Y si tu fix fue reconstruir y volver a desplegar, funciona por accidente esta vez —el HTML nuevo llega con otro momento de caché para algunos— y deja la política intacta: el mismo bug vuelve en el siguiente despliegue, y ahora con el equipo convencido de que redesplegar es un procedimiento de diagnóstico.

</details>

---

## Incidente 19 — "En UAT entra bien y en producción la pantalla se queda en blanco"

> **Fase:** 13 · **Categoría:** Despliegue · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1h30-2h

### 🎫 El ticket

> *"Subimos la misma imagen a producción y la pantalla se queda en blanco. En UAT entra perfecto. No sale ningún error en la consola, o al menos yo no veo nada."*

**Reportado por:** el equipo de soporte
**Ambiente:** PROD

### 🎯 Qué se te pide

Descartar las capas en el orden correcto —el código va **al final**—, encontrar la causa, y explicar por qué una pantalla en blanco sin errores es la firma de un tipo de fallo muy concreto.

### 🔧 Preparación

```bash
git switch -c incidente/19 fase-13
docker build -t certcore:inc19 .

# UAT, que funciona:
docker run --rm -d --name certcore-uat -p 8080:80 \
  -e ENVIRONMENT_NAME=UAT -e API_BASE_URL=/api certcore:inc19

# PROD, que no:
docker run --rm -d --name certcore-prod -p 8081:80 \
  -e ENVIRONMENT_NAME=PROD -e API_BASE_URL=/api certcore:inc19
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de nada, la pregunta que descarta la capa más grande: ¿es **de verdad** la misma imagen? Un comando, diez segundos.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Es la misma. Entonces la diferencia está en lo que cada contenedor tiene dentro **después de arrancar**. Compara el `assets/config.json` de los dos y mira los logs de arranque de cada uno.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En uno de los dos, el archivo no existe. `APP_INITIALIZER` **bloquea el arranque** de Angular hasta que resuelve. ¿Qué pasa si la promesa se rechaza antes de que haya dónde pintar un error?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Los cuatro pasos, en orden, y cada uno descarta una capa entera:

```bash
# 1. ¿Es la misma imagen? Sí: los digests coinciden.
docker inspect --format '{{.Image}}' certcore-prod certcore-uat
# sha256:9f2c4b1e…
# sha256:9f2c4b1e…

# 2. ¿Qué configuración tiene cada uno?
docker exec certcore-uat  cat /usr/share/nginx/html/assets/config.json
# {"apiBaseUrl": "/api", "environmentName": "UAT"}
docker exec certcore-prod cat /usr/share/nginx/html/assets/config.json
# cat: can't open '/usr/share/nginx/html/assets/config.json': No such file or directory

# 3. ¿Qué dijo el arranque?
docker logs certcore-prod 2>&1 | grep certcore
# (nada — el script nunca corrió)

# 4. Y la causa, en un ls:
docker exec certcore-prod ls -l /docker-entrypoint.d/
# -rw-r--r--  1 root root  412 40-certcore-config.sh     ← SIN el bit de ejecución
```

El `entrypoint.sh` **llegó a la imagen sin permiso de ejecución**. El entrypoint de nginx recorre `/docker-entrypoint.d/`, encuentra un archivo que no puede ejecutar, **lo ignora en silencio**, y arranca perfectamente. nginx sirve la aplicación; sólo falta el `config.json`.

**Y ahí está la pantalla en blanco:** `APP_INITIALIZER` bloquea el arranque de Angular hasta que su promesa resuelve. La petición a `assets/config.json` devuelve `404`, la promesa se rechaza, **Angular no arranca**, y lo que ve el usuario es una página vacía sin ningún error visible — porque el fallo ocurrió antes de que hubiera dónde pintarlo.

> 🧠 **Una pantalla en blanco sin errores en consola es casi siempre un fallo en el arranque**, y en una aplicación con `APP_INITIALIZER` es casi siempre él. No hay error visible porque no hay aplicación donde mostrarlo. Es una firma muy reconocible una vez que la has visto.

**Por qué en UAT sí funciona:** el contenedor de UAT se levantó desde una imagen construida en otra máquina, donde el archivo sí tenía el bit puesto en el sistema de archivos de origen. **Los permisos de un archivo copiado con `COPY` dependen de cómo estuviera en la máquina que construyó**, y eso convierte el build en algo que depende del entorno — que es exactamente lo que una imagen existe para evitar.

**Parche mínimo**

```dockerfile
# Dockerfile
COPY entrypoint.sh /docker-entrypoint.d/40-certcore-config.sh

# El bit de ejecución se pone AQUÍ y no se hereda del sistema de archivos del
# que copiaste. Si el archivo llega sin permiso, nginx arranca igual, ignora el
# script en silencio, y la aplicación sale con la configuración ausente.
RUN chmod +x /docker-entrypoint.d/40-certcore-config.sh
```

**La refactorización correcta**

El `chmod` arregla la causa y deja el **modo de fallo** intacto: si mañana el script falla por otra razón —una variable ausente, un directorio sin permiso de escritura—, la aplicación volverá a salir en blanco sin decir nada. Dos cambios lo convierten en un fallo ruidoso:

```sh
#!/bin/sh
# entrypoint.sh
# `set -e` para que cualquier fallo detenga el arranque en vez de dejar el
# contenedor sirviendo una aplicación incompleta. Un contenedor que no arranca
# es un problema visible; uno que arranca mal es un ticket de dos horas.
set -e

: "${ENVIRONMENT_NAME:?falta la variable ENVIRONMENT_NAME}"
: "${API_BASE_URL:?falta la variable API_BASE_URL}"

cat > /usr/share/nginx/html/assets/config.json <<JSON
{"apiBaseUrl": "${API_BASE_URL}", "environmentName": "${ENVIRONMENT_NAME}"}
JSON

echo "[certcore] configuración de arranque: ${ENVIRONMENT_NAME} -> ${API_BASE_URL}"
```

Y del lado de Angular, que el fallo tenga dónde verse:

```ts
// src/app/core/config/app-config.initializer.ts
export function loadAppConfig(): Promise<void> {
  const http = inject(HttpClient);
  const config = inject(AppConfigService);

  return firstValueFrom(http.get<AppConfig>('assets/config.json'))
    .then((loaded) => config.set(loaded))
    .catch((error: unknown) => {
      // Sin esto, el fallo de arranque es una página en blanco muda.
      // Pintar a mano en el DOM es feo y es lo único que funciona: Angular
      // todavía no existe, así que no hay componente que pueda hacerlo.
      document.body.innerHTML =
        '<p style="font-family:system-ui;padding:2rem">' +
        'No se pudo cargar la configuración de la aplicación. ' +
        'Avisa al equipo de plataforma.</p>';
      throw error;
    });
}
```

**Prueba de regresión**

Contra la imagen construida, en el pipeline:

```bash
#!/usr/bin/env bash
# scripts/check-image.sh — corre después de `docker build`, antes de promocionar.
set -euo pipefail
IMAGE="${1:?uso: check-image.sh <imagen>}"

# 1. El script de configuración es ejecutable. Es el incidente 19.
docker run --rm --entrypoint sh "$IMAGE" -c \
  '[ -x /docker-entrypoint.d/40-certcore-config.sh ]' \
  || { echo "❌ el entrypoint no es ejecutable: la app saldrá en blanco"; exit 1; }

# 2. Sin las variables obligatorias, el contenedor NO arranca en silencio.
if docker run --rm -d --name certcore-check "$IMAGE" >/dev/null 2>&1; then
  sleep 2
  docker rm -f certcore-check >/dev/null
  echo "❌ arrancó sin ENVIRONMENT_NAME: falla en silencio"; exit 1
fi

# 3. Con ellas, el config.json existe y tiene los valores dados.
CID=$(docker run --rm -d -e ENVIRONMENT_NAME=TEST -e API_BASE_URL=/api "$IMAGE")
sleep 2
docker exec "$CID" cat /usr/share/nginx/html/assets/config.json | grep -q '"TEST"' \
  || { docker rm -f "$CID" >/dev/null; echo "❌ config.json no refleja las variables"; exit 1; }
docker rm -f "$CID" >/dev/null

echo "✅ imagen correcta"
```

**Prevención**

El script de arriba, y la regla que lo justifica: **todo lo que puede fallar en el arranque de un contenedor tiene que fallar ruidosamente.** Un contenedor que no arranca lo ve el orquestador y lo reporta; uno que arranca sirviendo una aplicación rota lo descubre un usuario dos horas después.

**Por qué llegó a producción**

Tres decisiones razonables que sólo juntas producen el fallo. **`COPY` conserva los permisos del origen**, lo cual es útil y hace que el build dependa de la máquina que lo ejecuta. **El entrypoint de nginx ignora lo que no puede ejecutar** en vez de fallar, que es prudente para no romper contenedores por un archivo suelto de otro. Y **`APP_INITIALIZER` bloquea el arranque**, que es exactamente lo que queremos: una aplicación que arranca sin saber a qué backend hablar es peor que una que no arranca.

Ninguna de las tres está mal. La combinación produce un contenedor sano sirviendo una aplicación muerta, sin una sola línea en ningún log.

El agravante es que **el archivo llegó bien a la imagen de UAT** —construida en otra máquina, en otro momento— así que la evidencia disponible decía "la misma imagen se comporta distinto", que es la afirmación que más tiempo hace perder cuando resulta ser falsa. En este caso era cierta: la imagen sí era la misma; lo que cambió fue **cuál de los dos contenedores se levantó desde una construcción anterior**.

**Si tu causa fue distinta a esta**

Si concluiste que las variables de entorno están mal en PROD, es la hipótesis correcta que hay que descartar **primero** y se descarta en el paso 2: el problema no es que el JSON tenga valores equivocados, es que **no existe**. Si concluiste que falta `try_files` en el `nginx.conf`, eso produce un `404` al recargar una ruta profunda, no una pantalla en blanco en la raíz — y se descarta con un `curl` a `/inspections/500`. Y si te fuiste directo al código de la aplicación, es exactamente el callejón que este incidente entrena a evitar: los cuatro pasos cuestan cinco minutos entre todos y descartan tres capas.

</details>

---
EOF
wc -l cuaderno-incidentes.md

# --- 2026-09-07T01:39:19 · Write incident 20, retrospective and pendings
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 20 — "Tenemos 82 % de coverage y el bug llegó a producción igual"

> **Fase:** 12 · **Categoría:** Testing · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1h30-2h

### 🎫 El ticket

> *"El incidente 08 se nos escapó a producción con la suite en verde y 82 % de coverage. Quiero saber cómo es posible y qué hacemos para que no vuelva a pasar. Y no quiero 'subamos el coverage al 90'."*

**Reportado por:** tu líder técnico
**Ambiente:** —

### 🎯 Qué se te pide

Este incidente **no termina en un fix de código**: termina en un diagnóstico y una decisión. Demostrar con números por qué el 82 % no protegía nada de lo que importa, y proponer un cambio concreto que sí lo haga. La frase que no se admite como respuesta es la que el propio ticket ya descarta.

### 🔧 Preparación

```bash
git switch -c incidente/20 fase-12
ng test --watch=false --code-coverage --browsers=ChromeHeadless
open coverage/certcore/index.html   # o el navegador que uses
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El número global no dice nada; la distribución sí. Ordena el informe por porcentaje y mira **qué tipos de archivo** están arriba y cuáles abajo. No es una casualidad: es una consecuencia de qué es fácil de testear.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Busca en el informe el archivo donde vivía el bug del incidente 08. ¿Qué porcentaje tiene? Y si está cubierto, abre el test que lo cubre y pregúntate **qué afirma**.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Una línea "cubierta" significa que **se ejecutó** durante la suite. No significa que alguien haya comprobado lo que hace. ¿Qué mide entonces el 82 %?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Hay dos, y la segunda es la que duele.

**Primera: el 82 % global esconde su distribución.**

```
File                          % Stmts   % Branch   % Funcs   % Lines
------------------------------------------------------------------
core/domain/                    97.4      94.1      100       97.1
core/api/                       91.2      85.7       94       90.8
core/state/                     88.6      79.3       92       88.1
features/**/components          43.2      31.5       48       42.7
------------------------------------------------------------------
All files                       82.3      74.6       86       81.9
```

El coverage del proyecto **está dominado por funciones puras**, y eso es honesto, no un truco: `resolveTemplateVersion`, `buildAnswerForm`, las reglas de severidad y las agregaciones del panel se prueban sin `TestBed`, cuestan diez líneas por test, y ahí es donde la suite se concentra sola.

El precio es que **el número global no dice nada sobre los componentes**, que es donde vive el riesgo de una SPA. Con un 43 % en `features/`, más de la mitad de las pantallas no las mira nadie — y el 82 % de la portada las deja invisibles.

**Segunda, y es la de verdad: una línea cubierta no es una línea comprobada.**

```ts
// El archivo del incidente 08 aparecía cubierto al 100 %. Éste era el test:
it('carga el detalle de la inspección', fakeAsync(() => {
  fixture.detectChanges();
  httpMock.expectOne((r) => r.url.includes('/inspections/501')).flush(inspection501);
  tick();
  httpMock.expectOne((r) => r.url.includes('/templates')).flush([templateV2]);
  tick();

  expect(component.view).toBeTruthy();   // ← esto es todo lo que afirma
}));
```

La línea `resolveTemplateVersion(family, todayInBusinessZone())` **se ejecutó**, así que cuenta como cubierta. Y el test pasa igual con la v1 que con la v2, porque **`toBeTruthy()` no mira la versión**. El bug pasó por debajo de un test verde, en una línea verde, dentro de un archivo al 100 %.

> 🧠 **El coverage mide qué código se ejecutó, no qué comportamiento se comprobó.** Es una métrica de **alcance**, no de **calidad**. Un `expect(x).toBeTruthy()` al final de un flujo largo cubre decenas de líneas y no afirma nada sobre ninguna.

**Parche mínimo**

No hay parche: el entregable es una decisión. Y la primera parte es **el test que faltaba**, que ya existe desde el incidente 08 y afirma el invariante en vez de la ausencia de excepciones:

```ts
expect(applied?.version).toBe(1);
expect(applied?.items.length).toBe(3);
```

**La refactorización correcta**

Tres cambios, en orden de valor y **ninguno es "subir el número"**:

**Uno — umbrales por carpeta, no globales.** Un solo número deja que las funciones puras paguen la factura de los componentes.

```jsonc
// karma.conf.js — coverageReporter
{
  "check": {
    "global": { "statements": 80, "branches": 70, "functions": 80, "lines": 80 },
    "each": {
      // El umbral por archivo es lo que impide que un archivo al 20 % se
      // esconda detrás de veinte al 95 %.
      "statements": 50, "branches": 40, "functions": 50, "lines": 50,
      "overrides": {
        // El dominio es barato de probar y es donde vive el negocio.
        "src/app/core/domain/**/*.ts": { "statements": 95, "branches": 90 }
      }
    }
  }
}
```

**Dos — la pregunta que sustituye al porcentaje en la revisión de código.** No *"¿subió el coverage?"* sino:

> 🧭 **¿Esta zona tiene test, o sólo tiene porcentaje?**
>
> Y su versión operativa, que se puede aplicar en cualquier revisión en treinta segundos: **cambia una constante del código y corre la suite. Si sigue en verde, ese test no protege nada.** Es mutación a mano, y es la única forma barata de saber si una aserción afirma algo.

**Tres — un test de invariante por regla de negocio, con nombre.** El proyecto tiene cuatro invariantes que ningún componente puede violar, y cada uno merece un test que lo diga en su nombre:

```ts
// src/app/core/domain/invariants.spec.ts
describe('invariantes de CertCore', () => {
  it('una inspección se lee siempre con la versión que guardó', () => { … });
  it('un hallazgo crítico sin resolver bloquea la emisión', () => { … });
  it('un certificado vence al final del día del negocio', () => { … });
  it('como máximo una versión vigente por familia en cualquier fecha', () => { … });
});
```

**Cuatro nombres que se leen como el contrato del sistema.** Si alguno se pone en rojo, nadie tiene que interpretar qué significa.

**Prueba de regresión**

La de este incidente es distinta: se prueba **el pipeline**, no el código.

```bash
#!/usr/bin/env bash
# scripts/check-coverage.sh — falla si algún archivo baja del suelo por archivo.
set -euo pipefail
ng test --watch=false --code-coverage --browsers=ChromeHeadless

node -e '
const s = require("./coverage/certcore/coverage-summary.json");
const FLOOR = 50;
const bad = Object.entries(s)
  .filter(([f]) => f !== "total" && !f.includes(".spec."))
  .filter(([, m]) => m.statements.pct < FLOOR);

if (bad.length) {
  console.error(`❌ ${bad.length} archivo(s) por debajo del ${FLOOR}%:`);
  bad.forEach(([f, m]) => console.error(`   ${m.statements.pct.toFixed(1)}%  ${f}`));
  process.exit(1);
}
console.log("✅ ningún archivo por debajo del suelo");
'
```

**Prevención**

Los umbrales por archivo, la pregunta de revisión, y los cuatro tests de invariante. Y una cuarta cosa que no es técnica y vale más que las tres: **cada incidente de este cuaderno se cierra con un test que falla antes del fix.** Veinte incidentes son veinte tests que prueban comportamiento real y no cobertura — y eso es una suite construida desde los bugs que de verdad ocurrieron, que es la única forma honesta de saber que prueba lo que importa.

**Por qué llegó a producción**

Porque el equipo midió lo que era fácil de medir. El coverage es un número automático, comparable entre proyectos y fácil de poner en un panel; *"¿este test afirma algo?"* no se automatiza y hay que preguntárselo persona a persona en cada revisión.

El sistema empujó en esa dirección sin que nadie lo decidiera: el umbral del 80 % se puso al montar la suite en la Fase 12 —una cifra razonable, tomada de la costumbre—, y a partir de ahí **la métrica se convirtió en el objetivo**. Los tests que suben el número rápido son los que ejecutan mucho código y afirman poco, así que el incentivo empujaba exactamente hacia los tests que no protegen.

No hay nadie a quien señalar aquí: hay una métrica mal elegida y un proceso que la premió durante dos años.

**Si tu causa fue distinta a esta**

Si tu conclusión fue "hay que subir el coverage al 90 %", es la que el ticket descarta de entrada y merece decir por qué: **con estos tests, el 90 % se alcanza cubriendo más componentes con más `toBeTruthy()`**, y el sistema quedaría igual de desprotegido con un número más bonito. Si concluiste que hacen falta tests end-to-end, es una conversación legítima y de otro presupuesto — y no arregla ésta: un e2e que no afirme el invariante tampoco lo habría detectado. Y si concluiste que el problema fue no haber escrito el test de regresión **antes** del fix, has llegado al mismo sitio por otro camino: verlo en rojo es lo único que demuestra que un test prueba lo que dice probar.

</details>

---

## 🪞 Retrospectiva del mes

Se llena **al terminar**, de una sola vez, releyendo tu propio `git log`. No es un informe: es la única parte de este archivo que vas a releer dentro de un año.

```bash
# El material para escribirla:
git log --oneline --grep "incidente(" | wc -l          # cuántos commits de investigación
git tag -n99 -l 'inc/*'                                # los pares roto/fix, con su mensaje
git log --oneline --grep "hipótesis descartada"        # los callejones que registraste
```

**Cuántos abriste, cuántos cerraste, cuántos quedaron ⚪**

**Cuántas veces tu causa raíz coincidió con la de referencia, y en cuáles no.**
El patrón importa más que el número. Si fallaste tres veces y las tres eran de tiempo, ya sabes qué leer.

**En qué capa te costó más**
Plantilla · componente · servicio de estado · `*ApiService` · guard · interceptor · mock · build · contenedor.

**Cuántas veces el estilo te confundió 🧬**
Cuántos incidentes perdiste buscando en un `NgModule` algo que vivía en un standalone, o al revés. **Es la métrica propia de este track** y no existe en un sistema de una sola generación.

**Qué pista abriste antes de tiempo y por qué**
Sin culpa. Es un dato sobre dónde te falta confianza, no sobre tu disciplina.

**Tu checklist de hotfix**
La de una página, reescrita con lo que aprendiste este mes. Es lo único de este archivo que te llevas al trabajo real: el `HOTFIX.md` que escribiste en la **Fase 13 §5.9**, revisado con veinte incidentes encima.

> 🧭 **Y el criterio para saber si el mes hizo su trabajo:** que ante un ticket vago, tu primer movimiento ya no sea abrir el editor.

---

## 📌 Pendientes que salieron de los incidentes

Lo que apareció investigando y no cabía en el fix.

- **[05]** "Sin cargar" y "no hay ninguna" se pintan igual. Un campo `loaded: boolean` en `FeatureState<T>` los separaría y la pantalla podría decir "cargando…" en vez de "no hay plantillas". → **Fase 4**, o decisión de proyecto.
- **[06]** Un fallo puramente visual no tiene ningún mecanismo automático que lo detecte en este proyecto. La conversación sobre pruebas de regresión visual cabe en media página. → **Fase 12** 🔥 o apéndice.
- **[09]** Publicar una versión son dos escrituras y **desde el navegador no son atómicas**. La solución real es un endpoint transaccional, y CertCore no tiene backend propio. → **Conversación con backend**, documentada en `docs/`.
- **[13]** `overriddenBy` y `overriddenAt` guardan **la última** anulación, no su historial. En un sistema cuyo dominio es la trazabilidad, eso es un límite de arquitectura. → **A07** §8 ya lo nombra; merece una decisión escrita.
- **[14]** El pie del PDF con fecha, hora y zona horaria de generación convierte "este PDF miente" en "este PDF es de antes". → **A08** §4 lo recomienda; hacerlo obligatorio en la Fase 10.
- **[15]** El `status` de un certificado está **guardado** en el `db.json` y debería ser derivado. Un estado que se calcula pero se almacena empieza a mentir al día siguiente. → **Fase 10** ya lo convierte; el dato de la semilla queda como recordatorio deliberado.
- **[15]** Regla de lint: `new Date()` y `Date.now()` prohibidos dentro de `core/domain/`. El instante entra por parámetro. → **Fase 12**, con el pipeline de calidad.
- **[17]** El pipeline aleatoriza el orden y **no registra la semilla**. Un fallo que nadie puede reproducir no se investiga. → **Fase 12**, configuración de integración continua.
- **[18]** Sin CDN delante, no hay forma de alcanzar un navegador con el `index.html` cacheado un año. Un `version.json` sin caché que avise al usuario es feo y es lo que hacen los sistemas que ya pasaron por esto. → **Fase 13** 🔥.
- **[19]** Todo lo que puede fallar en el arranque de un contenedor tiene que fallar **ruidosamente**. `set -e` y variables obligatorias en el `entrypoint.sh`. → **Fase 13**, ya incorporado en la refactorización.
- **[20]** Los cuatro invariantes del sistema merecen un `invariants.spec.ts` propio, con nombres que se lean como el contrato. → **Fase 12**.
- **[20]** Mutación a mano como paso de revisión: *cambia una constante y corre la suite; si sigue en verde, ese test no protege nada.* → **Checklist de revisión del equipo.**
EOF
wc -l cuaderno-incidentes.md; echo "--- incidentes ---"; grep -c '^## Incidente ' cuaderno-incidentes.md; echo "--- details ---"; grep -c '<details>' cuaderno-incidentes.md

# --- 2026-09-07T01:39:33 · Verify index anchors
python3 - <<'PY'
import re, pathlib, unicodedata
t = pathlib.Path('cuaderno-incidentes.md').read_text()

def anchor(h):
    s = h.strip().lower()
    s = s.replace('`','')
    # quitar todo lo que no sea alfanumérico unicode, espacio o guion
    s = ''.join(c for c in s if c.isalnum() or c in ' -_')
    return s.replace(' ', '-')

heads = re.findall(r'^## (Incidente \d+ .*)$', t, re.M)
links = re.findall(r'\]\(#(incidente-[^)]*)\)', t)
gen = [anchor(h) for h in heads]

bad = [l for l in links if l not in gen]
print(f"encabezados: {len(heads)}  enlaces: {len(links)}  rotos: {len(bad)}")
for b in bad[:5]:
    print("  ROTO:", b)
if not bad:
    print("todos los enlaces del índice resuelven")
PY

# --- 2026-09-07T01:40:44 · Write README and verify links
cat > README.md <<'EOF'
# 🏗️ Angular 16 legacy para devs de backend

> Tutorial de **122 horas** · Dominio: inspecciones y certificaciones · Español
> latinoamericano, código en inglés

Un curso para desarrolladores **backend o full-stack senior** que heredan una aplicación Angular 16 en mantenimiento. No enseña a escribir Angular moderno: enseña a **leer, depurar y arreglar** un sistema que ya es moderno y que aun así duele — porque alguien lo migró, y las cicatrices están puestas.

## 🧬 CertCore

Todo el curso gira alrededor de un sistema con nombre propio:

> **CertCore** es el sistema de inspecciones y certificaciones que tu equipo heredó. Nació en 2021 sobre Angular 12, se migró a **Angular 16.2.12** durante 2024, y hoy está en mantenimiento. Casi no entran features nuevas: entran cambios normativos, legales y hotfixes.

Administra clientes y sus activos, plantillas de checklist **versionadas**, la ejecución de inspecciones en campo, hallazgos con severidad, y la emisión de certificados con vigencia y PDF.

**CertCore es ficticio, y lo construyes tú.** Ése es el trato: cada fase levanta una pieza del sistema que después vas a mantener, con sus deudas puestas adrede. Al terminar la última fase obligatoria no tienes un ejercicio de clase: tienes un legacy completo en tu disco del que conoces cada atajo, porque lo escribiste. Cuando un capítulo diga *"así lo hace CertCore"*, puedes abrir el archivo y comprobarlo.

Y lleva puesto, a propósito, lo que hace difícil un legacy **moderno**, que no es lo mismo que uno viejo:

- **Código mixto por sedimentación.** NgModules de 2021 conviviendo con componentes standalone de 2024. `constructor(private x: X)` conviviendo con `inject(X)`. Ninguno de los dos estilos es un error; los dos están vivos.
- **`strict: true` desde el primer archivo**, y con él la familia de bugs que sólo aparece cuando `null`, `undefined` y "campo ausente" son tres cosas distintas.
- **Estado en servicios con `BehaviorSubject`**, sin librería de store: la decisión más común del ecosistema y la que más fugas de suscripción produce.
- **Un motor de plantillas versionadas** escrito por alguien que ya no está, que es el corazón del sistema y la fuente de la mitad de los tickets.
- **Formularios reactivos tipados y dinámicos**, generados desde datos, con `valueChanges` que se muerden la cola.
- **`environment.ts` horneado en tiempo de compilación**, que es la razón por la que "funciona en UAT y no en PROD".

## 🎯 Qué te llevas

Al terminar puedes abrir un archivo cualquiera y decir en diez segundos si es código de 2021 o de 2024 —y qué implica eso para el fix que vas a escribir—; recibir un ticket vago y convertirlo en un diagnóstico; rastrear una fuga hasta el `BehaviorSubject` que la sostiene; explicar por qué una inspección de hace un año se está renderizando con la plantilla de hoy y arreglarlo sin corromper el histórico; leer un stack trace minificado; y escribir el post-mortem y el test de regresión **antes** del fix.

Lo que **no** es: formación de arquitectos de frontend, promoción de patrones modernos ideales, ni un plan de migración. Angular 17 en adelante aparece sólo como comparación, en el apéndice A11 o en secciones 🔥.

## 📚 Las fases

Catorce fases obligatorias suman **108h**, más **14h** de cuaderno de incidentes. **El track forense va embebido en cada fase**, no aparte. Las horas de apéndices no cuentan en el calendario.

| Fase | Archivo | Horas |
|---|---|---|
| 🛠️ 0 · Setup + hola mundo standalone | [`00-setup-hola-mundo.md`](00-setup-hola-mundo.md) | 6h |
| 🏗️ 1 · Estructura base con NgModules | [`01-estructura-base-ngmodules.md`](01-estructura-base-ngmodules.md) | 8h |
| 🔐 2 · Autenticación mínima | [`02-autenticacion.md`](02-autenticacion.md) | 6h |
| 🧪 3 · Mock API + Express caos | [`03-mock-api-caos.md`](03-mock-api-caos.md) | 6h |
| 🧠 4 · Estado con servicios y `BehaviorSubject` | [`04-estado-servicios.md`](04-estado-servicios.md) | 7h |
| 🧩 5 · Standalone conviviendo con NgModules 🧬 | [`05-standalone-convivencia.md`](05-standalone-convivencia.md) | 6h |
| 👥 6 · Clientes y activos | [`06-clientes-activos.md`](06-clientes-activos.md) | 8h |
| 📋 7 · **Plantillas versionadas** ⭐ | [`07-plantillas-versionadas.md`](07-plantillas-versionadas.md) | 14h |
| 📝 8 · **Formulario dinámico desde plantilla** ⭐ | [`08-formulario-dinamico.md`](08-formulario-dinamico.md) | 12h |
| ⚠️ 9 · Hallazgos y severidad | [`09-hallazgos-severidad.md`](09-hallazgos-severidad.md) | 6h |
| 📜 10 · Certificados, vigencia y PDF | [`10-certificados-vigencia.md`](10-certificados-vigencia.md) | 8h |
| 📊 11 · Dashboard y alertas | [`11-dashboard-alertas.md`](11-dashboard-alertas.md) | 6h |
| ✅ 12 · Testing desde cero + coverage | [`12-testing-coverage.md`](12-testing-coverage.md) | 8h |
| 🚚 13 · Build, despliegue y cierre | [`13-build-despliegue.md`](13-build-despliegue.md) | 7h |
| 🔥 14 · Ambiente "casi prod" con kind | [`14-casi-prod-kind.md`](14-casi-prod-kind.md) | — |

Cada fase sigue la misma plantilla de nueve secciones y cierra con **25-35 ejercicios** graduados 🟢🟡🟠🔴, de los que **al menos un tercio son de diagnóstico** —se entrega algo roto y se pide reproducir, localizar y explicar— y **al menos dos, desde la Fase 5, son de estilo** 🧬: dado un archivo, decidir si el fix va en estilo nuevo o heredado, y justificarlo.

**Antes de la Fase 0** conviene leer dos documentos cortos:

- [`00-historia-del-sistema.md`](00-historia-del-sistema.md) — las tres eras de CertCore, quién dejó qué, y por qué el sistema es como es.
- [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) — un tag por fase, el par `-roto`/`-fix` de cada incidente, y cómo se lee la factura de una deuda con `git diff`.

## 🕵️ Track forense

Quince recorridos de investigación, uno por fase, con el ticket literal y la salida de cada paso. **No se leen de corrido**: se entra por el síntoma.

La puerta es [`forense-master.md`](forense-master.md), que trae el método de cuatro preguntas y —lo que de verdad se consulta— **el índice de síntomas transversal**: nadie llega sabiendo de qué fase es su problema, llega con *"la pantalla se queda en blanco"*.

| | Síntoma que cubre |
|---|---|
| [`forense-fase-00.md`](forense-fase-00.md) | "Le di guardar y no pasó nada" |
| [`forense-fase-01.md`](forense-fase-01.md) | "La ruta funciona pero la pantalla sale en blanco" |
| [`forense-fase-02.md`](forense-fase-02.md) | "Me saca al login sin decir nada" |
| [`forense-fase-03.md`](forense-fase-03.md) | Los seis fallos del caos, y cuál miente |
| [`forense-fase-04.md`](forense-fase-04.md) | "La lista se actualizó dos veces" |
| [`forense-fase-05.md`](forense-fase-05.md) | Los dos `NullInjectorError` 🧬 |
| [`forense-fase-06.md`](forense-fase-06.md) | "No me deja guardar y no dice por qué" |
| [`forense-fase-07.md`](forense-fase-07.md) | "Esta inspección se ve con otra plantilla" ⭐ |
| [`forense-fase-08.md`](forense-fase-08.md) | "Escribo y la aplicación se queda pegada" ⭐ |
| [`forense-fase-09.md`](forense-fase-09.md) | "El sistema me dejó aprobar y no debía" |
| [`forense-fase-10.md`](forense-fase-10.md) | "Venció ayer para uno y hoy para otro" |
| [`forense-fase-11.md`](forense-fase-11.md) | "Desde ayer el panel va lentísimo" |
| [`forense-fase-12.md`](forense-fase-12.md) | "Pasa en mi máquina y falla en el pipeline" |
| [`forense-fase-13.md`](forense-fase-13.md) | "En UAT entra y en PROD no" |
| [`forense-fase-14.md`](forense-fase-14.md) | "El pod no arranca" 🔥 |

## 📓 Cuaderno de incidentes

[`cuaderno-incidentes.md`](cuaderno-incidentes.md) — **20 incidentes, 14 horas**, repartidos a lo largo del mes. Cada uno trae el ticket como llegó, la preparación para tener el sistema roto, tres pistas plegadas, un espacio para tu investigación, y la solución de referencia con parche mínimo, refactorización correcta, **test de regresión en código**, prevención y post-mortem.

Tres de versionado de plantillas, dos de convivencia de estilos 🧬, dos de tipos bajo `strict`. Y una regla que es la mitad del ejercicio: **la solución viene incluida, y abrirla antes de escribir la tuya no te ahorra tiempo — te ahorra el ejercicio.**

## 📎 Apéndices

Consulta rápida. **Sus horas no cuentan en el calendario** y el curso se completa sin abrir los marcados 🔥.

| | Contenido |
|---|---|
| [`a01-material.md`](a01-material.md) | Angular Material 16 (MDC): tema, `mat-form-field`, tablas, diálogos, densidad |
| [`a02-bootstrap-sass.md`](a02-bootstrap-sass.md) 🔥 | Bootstrap 5 y Material conviviendo: quién gana la cascada |
| [`a03-node-npm.md`](a03-node-npm.md) | `.nvmrc`, `npm ci` frente a `npm i`, lockfile v3, y comparar **tu** proyecto contra el del curso |
| [`a04-inject-vs-constructor.md`](a04-inject-vs-constructor.md) | El contexto de inyección, `NG0203`, y la regla del proyecto 🧬 |
| [`a05-formularios-tipados.md`](a05-formularios-tipados.md) | `FormControl<T>`, `nonNullable`, `FormRecord`, y `getRawValue()` |
| [`a06-rxjs.md`](a06-rxjs.md) | Los ocho operadores que aparecen de verdad, y los antipatrones de cada uno |
| [`a07-estado-servicios.md`](a07-estado-servicios.md) | El patrón de estado de punta a punta, y **dónde se queda corto** |
| [`a08-pdf-cliente.md`](a08-pdf-cliente.md) | jsPDF más allá del ejemplo: acentos, tablas, los 300 KB, y los límites |
| [`a09-docker-kubernetes.md`](a09-docker-kubernetes.md) | Leer un manifiesto ajeno y hablar con plataforma sin sentirte turista |
| [`a10-migracion-8-16.md`](a10-migracion-8-16.md) | Puente Angular 8/9 → 16, para quien viene del Track A |
| [`a11-puente-16-17.md`](a11-puente-16-17.md) 🔥 | Signals, control flow, esbuild: qué viene después y qué costaría |
| [`a12-arm64-m1.md`](a12-arm64-m1.md) 🔥 | macOS con Apple Silicon: las tres capas, y el `CrashLoopBackOff` que es arquitectura |
| [`a13-i18n.md`](a13-i18n.md) 🔥 | Qué costaría internacionalizar CertCore, y por qué este curso no lo hace |

## 🧰 El stack, fijado

Ninguna versión queda al azar: es lo que hace que el material siga funcionando dentro de dos años y que tu error sea el mismo que describe el texto.

Angular y Angular CLI **16.2.12** · TypeScript **5.1.6** con `strict: true` · RxJS **7.8.1** · Angular Material y CDK **16.2.14** (MDC) · zone.js **0.13.3** · Node **18.18.2** con npm **9.8.1** · jsPDF **2.5.1** · ng2-charts **4.1.1** con Chart.js **4.4.x** · Jasmine **4.6.x** y Karma **6.4.x** · json-server **0.17.4**, Express **4.18.2** y jsonwebtoken **9.0.2** para el mock · `node:18.18.2-alpine` y `nginx:1.25-alpine` para el contenedor.

**El curso no depende de ningún `package.json` externo.** Quien llegue con un proyecto heredado propio compara su árbol contra éste con el procedimiento del apéndice **A03** §7 — y ése es el único sitio del curso donde se te pide mirar un sistema que no es CertCore.

## 👤 Para quién es

Un desarrollador **backend o full-stack senior**. Dominas JavaScript, HTML, CSS, HTTP, JSON, autenticación y APIs REST, y no hace falta que nadie te lo explique. Puedes no haber tocado Angular nunca, y casi seguro no dominas RxJS ni el ciclo de detección de cambios.

El salto conceptual real está en cinco puntos, y ahí se gasta el espacio: **RxJS de supervivencia**, **el estado compartido en servicios y su ciclo de vida**, **los formularios reactivos tipados**, **la diferencia entre lo que corre en el navegador y lo que corre en el servidor**, y uno que no existe en ningún otro curso de este repositorio: **leer dos generaciones de estilo en el mismo repositorio sin marearte**, y decidir en cuál de las dos escribes el fix.

## 🔀 Su curso hermano

[`angular-8-legacy-for-backend-devs`](../angular-8-legacy-for-backend-devs) — **LabCore**, un laboratorio clínico sobre Angular 8. Es el mismo oficio con el legacy contrario: allí el problema es la **antigüedad** (NgRx de 2019, `strict: false`, `.bind(this)`); aquí es la **convivencia** de dos generaciones.

**Los dos se pueden tomar en cualquier orden y ninguno es prerrequisito del otro.** Para quien venga del Track A existe el apéndice [`a10-migracion-8-16.md`](a10-migracion-8-16.md), que traduce los reflejos de LabCore al stack de CertCore — incluida la fila que más vale: los dos sistemas versionan algo por fecha, los dos tienen su bug estrella en la misma pregunta, y lo que cambia el resultado es **dónde decidieron poner la regla**.

---

> 🧭 **El principio que ordena las 122 horas.** No enseñamos Angular bonito ni formamos arquitectos de frontend. Formamos ojo para leer código ajeno, reproducir un bug desde un ticket vago, comparar UAT contra PROD, y aplicar un hotfix que no rompa otras tres cosas.
>
> El filtro de cada párrafo es el mismo: **¿esto ayuda a diagnosticar, depurar, corregir o prevenir?** Si no, sobra. Aunque esté muy bien escrito.
EOF
wc -l README.md; echo "--- enlaces del README ---"; grep -oE '\]\(([^)#][^)]*)\)' README.md | sed 's/^](//;s/)$//' | while read x; do [ -e "$x" ] && echo "OK   $x" || echo "ROTO $x"; done

# --- 2026-09-07T01:40:57 · Final course inventory and checks
echo "=== INVENTARIO DEL CURSO ==="; printf "%-34s %6s\n" "GRUPO" "LINEAS"
printf "%-34s %6s\n" "README + previos (3)" "$(cat README.md 00-historia-del-sistema.md 00-convencion-de-git-y-tags.md | wc -l)"
printf "%-34s %6s\n" "Fases 00-14 (15)" "$(cat 0[0-9]-[a-z]*.md 1[0-4]-*.md 2>/dev/null | grep -v x | wc -l)"
printf "%-34s %6s\n" "Apendices a01-a13 (13)" "$(cat a[01][0-9]-*.md | wc -l)"
printf "%-34s %6s\n" "Track forense (16)" "$(cat forense*.md | wc -l)"
printf "%-34s %6s\n" "Cuaderno de incidentes (1)" "$(wc -l < cuaderno-incidentes.md)"
printf "%-34s %6s\n" "Prompts y especificaciones (8)" "$(cat prompts/*.md | wc -l)"
echo; echo "TOTAL archivos .md del curso: $(ls *.md | wc -l) + $(ls prompts/*.md | wc -l) en prompts/"
echo "TOTAL lineas (sin prompts): $(cat *.md | wc -l)"
echo; echo "--- comprobaciones finales ---"
echo -n "enlaces .md rotos en todo el curso: "; grep -rhoE '\]\([a-z0-9][^)#]*\.md\)' *.md | sed 's/^](//;s/)$//' | sort -u | while read x; do [ -f "$x" ] || echo "$x"; done | wc -l
echo -n "incidentes con solucion de referencia: "; grep -c 'Solución de referencia' cuaderno-incidentes.md
echo -n "incidentes con test de regresion: "; grep -c '\*\*Prueba de regresión\*\*' cuaderno-incidentes.md
echo -n "incidentes con post-mortem: "; grep -c '\*\*Por qué llegó a producción\*\*' cuaderno-incidentes.md
echo -n "incidentes con diagnostico alternativo: "; grep -c '\*\*Si tu causa fue distinta a esta\*\*' cuaderno-incidentes.md

