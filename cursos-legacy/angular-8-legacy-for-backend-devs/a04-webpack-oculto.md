# 📎 Apéndice A04 — Webpack oculto

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **2h**
> Usado por: Fases 10 y 13 · Versiones cubiertas: Angular CLI **8.3.29**, `@angular-devkit/build-angular` **~0.803.29**, Webpack **4.x**
> Estado: Base

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve una sola pregunta, la que aparece el día que el build falla y nadie tocó el build: **qué está haciendo el CLI por debajo cuando dice eso**.

Tu `package.json` no menciona Webpack por ninguna parte, y sin embargo tienes uno. Pesa, decide el nombre de cada archivo de `dist/`, y es quien te falla el `docker build` de la Fase 13 con un mensaje sobre presupuestos que nadie configuró. Este apéndice te enseña a leer lo que ya está pasando, no a configurarlo.

**Qué queda fuera:** **escribir configuración de Webpack a mano.** No hay un `webpack.config.js` de ejemplo en este apéndice y no lo va a haber, porque en Angular 8 esa puerta está cerrada por diseño y forzarla cuesta más de lo que ahorra (§8). Tampoco entra el peso de la **imagen** de Docker —que es otra cosa que el peso del bundle, y vive en la **Fase 13 §5.6**—, ni `npm ci` y el lockfile (**Apéndice A03**), ni la exclusión de coverage del `angular.json` (**Fase 12**).

---

## Índice

- [1. Qué hay debajo de `ng build`](#1-qué-hay-debajo-de-ng-build)
- [2. Leer la salida del build sin adivinar](#2-leer-la-salida-del-build-sin-adivinar)
- [3. El interruptor que duplica tu `dist/`](#3-el-interruptor-que-duplica-tu-dist)
- [4. Budgets: el build que falla por gordo](#4-budgets-el-build-que-falla-por-gordo)
- [5. Medir el bundle de verdad](#5-medir-el-bundle-de-verdad)
- [6. Source maps y el stack trace de PROD](#6-source-maps-y-el-stack-trace-de-prod)
- [7. Dónde vive el `ng eject` que ya no existe](#7-dónde-vive-el-ng-eject-que-ya-no-existe)
- [8. Las tres salidas cuando el CLI no te deja](#8-las-tres-salidas-cuando-el-cli-no-te-deja)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-6)

---

## 1. Qué hay debajo de `ng build`

`ng build` no compila nada. Es un despachador: lee `angular.json`, busca qué *builder* le toca al target que le pediste, y le pasa el trabajo. El builder es el que arma una configuración de Webpack **en memoria**, la ejecuta, y te devuelve la salida.

La cadena completa, que conviene tener en la cabeza porque cada eslabón falla distinto:

```
ng build --prod
   │
   ├─ @angular/cli (8.3.29) ......... parsea el comando, no compila
   │
   ├─ angular.json .................. projects > clinical-lab > architect > build
   │     "builder": "@angular-devkit/build-angular:browser"
   │     "configurations": { "production": { ...opciones... } }
   │
   ├─ @angular-devkit/build-angular (~0.803.29)
   │     genera la config de Webpack EN MEMORIA a partir de esas opciones
   │     + @ngtools/webpack .......... el loader que compila TypeScript con AOT
   │
   └─ webpack (4.x) ................. lo unico que de verdad empaqueta
```

Tres consecuencias prácticas de este dibujo:

- **Un error de Webpack te llega envuelto.** Cuando el mensaje habla de *chunks*, *modules* o *loaders*, estás leyendo a Webpack, no a Angular. Cuando habla de *metadata*, *decorators* o factories, es el compilador AOT vía `@ngtools/webpack`. Saber de quién es la voz te ahorra la mitad de la búsqueda.
- **La numeración `0.803.29` no es un error de tipeo.** El devkit va una mayor por detrás con un cero delante: `0.803.x` es la línea que acompaña al CLI `8.3.x`. Si alguna vez ves un `0.900.x` en el `package.json`, alguien empezó una migración a Angular 9 y no la terminó.
- **No hay archivo que abrir.** La configuración no existe en disco. Vive dentro de `node_modules`, en forma de código que la construye; en §7 está dónde y cómo leerla.

### 1.1 Confirmar qué Webpack tienes, sin creerle a nadie

Webpack no está en tu `package.json`: entra como dependencia transitiva del devkit. Se ve así:

```bash
# Que Webpack hay realmente instalado, y quien lo trajo.
npm ls webpack
```

```
clinical-lab@0.0.0 /home/you/clinical-lab
└─┬ @angular-devkit/build-angular@0.803.29
  └── webpack@4.39.2
```

> ⚠️ **El número exacto de Webpack se lee, no se recuerda.** La línea de arriba es la que resuelve `@angular/cli@8.3.29` en una instalación limpia, pero lo único que este apéndice afirma sin condiciones es que es un **Webpack 4**. La diferencia entre 4 y 5 importa —cambian los nombres de los chunks, la caché y el algoritmo de hash—, así que si algún día ese comando imprime un `5.x`, la mitad de este apéndice deja de aplicar. El número de parche sale de tu máquina con `npm ls webpack`, y es el ejercicio 1.

### 1.2 El error de Node 17 es un error de Webpack 4

El `error:0308010C:digital envelope routines::unsupported` que documenta la **Fase 0 §6** no es de Angular: Webpack 4 calcula los hashes de los archivos con **md4**, y OpenSSL 3 —que llega con Node 17— dejó de ofrecer md4. El CLI solo es el mensajero. Es el ejemplo más limpio de por qué conviene saber quién está debajo: buscar el error con la palabra "Angular" no lleva a ninguna parte, y con la palabra "webpack md4" lo resuelve la primera respuesta. La cura sigue siendo la de la Fase 0 —quedarte en Node 14—, no un flag.

---

## 2. Leer la salida del build sin adivinar

Esto es lo que imprime `npx ng build --prod` cuando todo va bien, y casi nadie lo lee:

```
chunk {0} runtime.a2d1c0f3e5b7.js (runtime) 1.45 kB [entry] [rendered]
chunk {1} main.9c4f2b1e77a0.js (main) 1.28 MB [initial] [rendered]
chunk {2} polyfills.55b1e0c9d4f2.js (polyfills) 130 kB [initial] [rendered]
chunk {3} styles.61a8f0c2d3e4.css (styles) 285 kB [initial] [rendered]
chunk {6} 6.d1e2f3a4b5c6.js () 412 kB  [rendered]
chunk {7} 7.0f9e8d7c6b5a.js () 88 kB  [rendered]

Date: 2019-11-08T14:22:31.104Z - Hash: 9c4f2b1e77a0 - Time: 94213ms
```

Qué te está diciendo, columna por columna:

| Pieza | Qué es | Cuándo te importa |
|---|---|---|
| `runtime` | El cargador de Webpack. Sabe qué chunk pedir cuando el router entra a una ruta *lazy*. Diminuto y obligatorio | Si falta en el `index.html`, la app no arranca y la consola no dice por qué |
| `main` | **Tu** código más todo lo que importas desde él. En `--prod` incluye las librerías | Es el número que crece solo. El de la §4 y el de la §5 |
| `polyfills` | El relleno de compatibilidad que arma `polyfills.ts` (`zone.js` vive acá) | Crece cuando alguien descomenta líneas de ese archivo sin saber por qué |
| `styles` | El CSS global: el arreglo `styles` del `angular.json` más `styles.scss` (**Fase 0**, **A02**) | Material y Bootstrap juntos pesan, y pesan acá |
| `[initial]` | Se descarga **antes** de que el usuario vea nada | Es lo único que cuentan los budgets (§4) |
| `[rendered]` sin `[initial]` | Chunk *lazy*: se descarga cuando el router entra a esa ruta | Aquí viven `patients`, `orders`, `samples`, `results` y `dashboard` |
| `Hash: 9c4f...` | La huella del build completo | Es lo que compara el ejercicio 24 de la **Fase 13** entre dos ambientes |

### 2.1 Por qué el chunk lazy se llama `6.js` y no `dashboard.js`

Porque en producción el CLI 8 genera el `angular.json` con `"namedChunks": false`. En desarrollo los chunks salen con nombre —`dashboard-dashboard-module.js`, legible— y en `--prod` salen numerados. No es un capricho: el nombre del módulo es información sobre tu código, y el número no.

El efecto secundario es el que te va a morder: **frente a un `dist/` de producción no puedes saber qué hay dentro de `6.d1e2f3a4b5c6.js` mirando el nombre.** Esa es exactamente la pregunta que responde el analizador de la §5, y la razón por la que existe esa sección.

Y hay otra pareja de opciones que cambia la foto entre dev y prod:

```jsonc
// angular.json -> architect -> build -> configurations -> production
// Así lo genera el CLI 8.3.29. No lo hemos tocado.
{
  "optimization": true,        // minifica y activa el buildOptimizer
  "outputHashing": "all",      // el hash en el nombre de cada archivo
  "sourceMap": true,           // ver sección 6: el CLI lo genera en false
  "extractCss": true,          // el CSS sale a .css, no embebido en el .js
  "namedChunks": false,        // por eso el chunk lazy se llama 6.js
  "aot": true,                 // en dev es false: ver 2.2
  "extractLicenses": true,     // genera 3rdpartylicenses.txt en dist/
  "vendorChunk": false,        // por eso NO hay vendor.js en producción
  "buildOptimizer": true
}
```

`vendorChunk: false` es el que más confunde: en `ng serve` ves un `vendor.js` enorme separado, y en `--prod` desaparece. No se fue a ninguna parte — está **dentro de `main.js`**. Por eso el `main` de producción pesa 1.28 MB y el de desarrollo parecía inocente.

### 2.2 En desarrollo compila otra cosa

`aot: false` en desarrollo y `true` en producción significa que `ng serve` y `docker build` **no compilan lo mismo**. Es la raíz de la trampa que ya sufriste en la **Fase 2** (`httpLoaderFactory`) y que la **Fase 13 §5.4** repite con `appConfigInitializer`: una arrow anónima en un `useFactory` pasa entera por JIT y revienta en AOT.

Dicho de otra forma: **`ng serve` no prueba que tu build de producción funcione.** Si quieres saberlo antes de esperar el `docker build`, el comando es `npx ng build --prod`, y tarda lo que tarda.

> 📝 **Nota de época.** Que AOT sea opcional y esté apagado en desarrollo es propio de la era pre-Ivy. Desde Angular 9, Ivy compila AOT siempre, también en `ng serve`, y esta clase entera de "compila en dev, falla en prod" se evapora. Es el argumento más fuerte a favor de migrar y está desarrollado en el **Apéndice A10 §2.1**, junto con lo que aparece en su lugar: un primer build más lento y un actor nuevo, `ngcc`, que sí puede hacer que CI falle distinto que tu máquina (**A10 §4**).

---

## 3. El interruptor que duplica tu `dist/`

*Differential loading* es la característica insignia del CLI 8 y la respuesta a la pregunta "¿por qué este `dist/` tiene el doble de archivos y el build tardó el doble?" — cuando la respuesta es esa.

**En este proyecto está apagado**, porque el `browserslist` es el que genera `ng new` y trae las líneas de IE comentadas:

```
# browserslist (raiz del proyecto, tal como lo genera el CLI 8.3.29)
> 0.5%
last 2 versions
Firefox ESR
not dead
# IE 9-11 support: descomentar la línea de abajo enciende differential loading
# IE 11
```

El CLI mira dos cosas antes de compilar: el `target` del `tsconfig.json` (acá `es2015`) y ese archivo. Si el target es `es2015` **y** en la lista queda al menos un navegador que no entiende ES2015 —en la práctica, IE 11—, compila la aplicación **dos veces** y emite los dos juegos:

```
dist/clinical-lab/
  main-es2015.9c4f.js      polyfills-es2015.55b1.js
  main-es5.9c4f.js         polyfills-es5.55b1.js      <-- el relleno pesado
```

Y en el `index.html` deja que el navegador elija solo, sin `if` ni sniffing de user-agent:

```html
<!-- El navegador moderno entiende type="module" y carga este. -->
<script src="main-es2015.9c4f.js" type="module"></script>
<!-- ...y por eso mismo ignora el nomodule. IE 11 hace exactamente lo contrario. -->
<script src="main-es5.9c4f.js" nomodule defer></script>
```

**Cómo saber en diez segundos si un proyecto ajeno lo tiene encendido:** mira si hay archivos con `-es5` en el `dist/`, o `grep nomodule index.html`. No hace falta abrir ninguna configuración.

> ⚠️ **`ng serve` nunca hace differential loading.** En desarrollo se sirve un solo juego, el moderno. Eso significa que en un proyecto con IE 11 en la lista existe una clase entera de bugs —los que solo ocurren en el bundle es5— que **no puede reproducirse con `ng serve` ni una sola vez**, y que aparecen únicamente en la imagen desplegada. Si alguien reporta "en mi máquina no pasa", esta es una de las pocas veces en que tiene razón por una causa estructural.

Apagarlo también es un interruptor: poner `"target": "es5"` en el `tsconfig.json` desactiva el mecanismo aunque IE 11 esté en la lista, porque ya no hay dos targets que producir. El build vuelve a tardar la mitad, y **todos** los usuarios —incluidos los modernos— cargan el bundle viejo y gordo. Es el atajo que tomaron muchos equipos de 2019 cuando el CI se les hizo insoportable, y conviene saber reconocerlo antes de celebrar que "acá el build es rápido".

---

## 4. Budgets: el build que falla por gordo

Un *budget* es un límite de tamaño que el CLI verifica al final del build. Si lo pasas, avisa; si pasas el límite duro, **falla el build con código de salida distinto de cero**, que dentro del Dockerfile de la **Fase 13 §5.6** significa que la imagen no se construye.

Nadie los configuró en este proyecto: son los que trae `ng new`.

```jsonc
// angular.json -> architect -> build -> configurations -> production
"budgets": [
  {
    "type": "initial",              // solo lo que se descarga antes de ver algo
    "maximumWarning": "2mb",
    "maximumError": "5mb"
  },
  {
    "type": "anyComponentStyle",    // el .scss de CADA componente, por separado
    "maximumWarning": "6kb",
    "maximumError": "10kb"
  }
]
```

Y así se ve cuando saltan:

```
WARNING in budgets: maximum exceeded for initial. Budget 2 MB was not met by 340 kB
        with a total of 2.34 MB.

ERROR in budgets: maximum exceeded for anyComponentStyle.
        Budget 10 kB was not met by 3.2 kB with a total of 13.2 kB.
        (src/app/dashboard/dashboard.component.scss)
```

Dos lecturas que evitan la mitad de los malentendidos:

- **`initial` no cuenta los chunks lazy.** Puedes tener un chunk de dashboard de 400 kB y el budget `initial` tan contento. Eso es intencional —lo lazy no retrasa la primera pantalla—, pero también significa que **el budget no te va a avisar de la deuda de la Fase 10 §5.6**, donde d3 viaja en el chunk lazy del dashboard. Para eso está la §5.
- **`anyComponentStyle` mide archivo por archivo**, no el total. Un solo `.scss` de componente gordo revienta el build entero, y el mensaje te dice cuál.

Los tipos que acepta el CLI 8, para cuando necesites uno más fino:

| `type` | Qué mide |
|---|---|
| `initial` | El total de lo que se descarga antes de la primera pantalla |
| `all` | Todo lo generado, lazy incluido |
| `allScript` | Todo el JavaScript, lazy incluido |
| `anyScript` | Cada `.js` por separado |
| `any` | Cada archivo por separado |
| `anyComponentStyle` | Cada `.scss`/`.css` de componente por separado |
| `bundle` | Un bundle concreto, por nombre (requiere `"name": "..."`) |

> 🧭 **El fix mínimo de un budget no es subir el número.** Subirlo es el reflejo, se hace en veinte segundos y funciona: el build vuelve a pasar y nadie se entera de nada, hasta que alguien mide la aplicación en la red del laboratorio y pregunta por qué tarda ocho segundos en abrir. Un budget que salta es un dato, no un obstáculo. **Primero mides (§5), después decides.** Si tras medir la conclusión honesta es que 2 MB era un límite irreal para esta aplicación, subirlo es correcto — pero se sube con el número medido y un comentario que diga por qué, no a ojo.

💸 **Deuda intencional del curso.** Este proyecto deja los budgets en sus valores default y nunca los ajusta al tamaño real de la aplicación. Lo correcto sería fijarlos un poco por encima del tamaño medido, para que el límite avise cuando algo crece de golpe. En un legacy en mantenimiento no se paga: nadie va a defender ante su jefe media tarde de tocar `angular.json` para mover un número que hoy no molesta.

---

## 5. Medir el bundle de verdad

Esta es la sección que se consulta el día que un budget saltó, que el `main.js` creció 300 kB sin que nadie agregara nada, o que hay que responder qué pesa dentro de `6.d1e2f3a4b5c6.js`.

Hay dos herramientas y ninguna viene instalada. Cuál te toca depende de lo que quieras responder.

### 5.1 `webpack-bundle-analyzer` — qué hay dentro de cada chunk

Necesita que el build deje escrito su mapa interno, y para eso está el flag `--stats-json`:

```bash
# Compila y además escribe dist/clinical-lab/stats.json con el detalle
# de que modulo entro en que chunk.
npx ng build --prod --stats-json
```

Y después, en dos sabores según lo que tengas a mano:

```bash
# Sin instalar nada. Es lo que quieres para una consulta puntual: npx lo baja,
# lo corre y no toca tu package.json ni tu lockfile.
npx webpack-bundle-analyzer dist/clinical-lab/stats.json
```

```bash
# Si el equipo lo va a usar seguido, mejor fijarlo como devDependency
# y darle un script. Así todos miden con la misma versión.
npm install --save-dev webpack-bundle-analyzer@3.9.0
```

```jsonc
// package.json -> scripts
// Ojo con el "--": sin el, npm se come el flag. Ver Apéndice A03 sección 7.2.
"scripts": {
  "build:stats": "ng build --prod --stats-json",
  "analyze": "webpack-bundle-analyzer dist/clinical-lab/stats.json"
}
```

Abre un treemap en el navegador: cada rectángulo es un módulo, y su área es su peso. **El chunk numerado deja de ser anónimo**: haces clic en `6.js` y ves los nombres de los paquetes que hay dentro.

> ⚠️ **El número grande que muestra por defecto es el que menos te sirve.** El analizador ofrece tres tamaños y hay que cambiar el selector a mano: *stat* es el original antes de minificar, *parsed* es lo que de verdad hay en tu `.js`, y *gzipped* es lo que viaja por la red. Discutir el peso de una librería citando el *stat* es la forma más común de exagerar el problema por tres. **Para decidir, se mira *gzipped*; para comparar dos builds, *parsed*.**

Este es el instrumento que cierra el ejercicio 28 de la **Fase 10**: abrir el chunk lazy del dashboard y ver, con dos rectángulos uno al lado del otro, cuánto pesa d3 —que llega por `@swimlane/ngx-charts`, por un solo gráfico heredado— frente a Chart.js, que dibuja todo lo demás. La deuda 💸 de la Fase 10 §5.6 deja de ser una afirmación y pasa a ser un número que puedes escribir en un ticket.

### 5.2 `source-map-explorer` — qué archivo *tuyo* pesa

El analizador razona en módulos de Webpack. Cuando la pregunta es "¿qué parte de **mi** código ocupa este `main.js`?", la herramienta es otra, y funciona porque este proyecto genera source maps en producción (§6):

```bash
# Lee el .map y atribuye cada byte del bundle a su archivo fuente original.
npx source-map-explorer dist/clinical-lab/main.*.js
```

| Pregunta | Herramienta | Por qué |
|---|---|---|
| ¿Qué librería me está pesando? | `webpack-bundle-analyzer` | Razona en paquetes de `node_modules` |
| ¿Qué hay dentro del chunk `6.js`? | `webpack-bundle-analyzer` | Es el único que rompe el anonimato del chunk numerado |
| ¿Qué archivo mío ocupa más? | `source-map-explorer` | Atribuye bytes a rutas de `src/` |
| ¿Creció el bundle entre dos commits? | Cualquiera de los dos, en *parsed* | Lo que importa es medir igual las dos veces |

---

## 6. Source maps y el stack trace de PROD

> 🕵️ **El recorrido de un source map que miente** —el desfase entre el `.map` y el bundle que sirve producción, y su firma: un breakpoint que no dispara sobre código que sí corre— está en [`forense-fase-08.md`](forense-fase-08.md). Acá está el mecanismo; allá, la investigación.

Un source map es un archivo `.map` que traduce una posición del bundle minificado —`main.9c4f.js:1:284712`— a la línea y columna del `.ts` original. Sin él, el stack trace de un error de producción es una coordenada dentro de una sola línea de 1.2 MB, y no sirve para nada.

**Este proyecto los genera en producción y los deja viajar dentro de la imagen.** El CLI 8 genera `"sourceMap": false` en su configuración de producción; acá está en `true` a propósito:

```jsonc
// angular.json -> architect -> build -> configurations -> production
"sourceMap": true
```

El efecto es directo y es el que se quería: abres las DevTools contra el contenedor desplegado, vas a *Sources*, y ves tus `.ts` originales con nombres de variable de verdad. Un stack trace del log de un usuario se traduce solo. No hace falta recompilar nada ni cruzar hashes a mano.

> ⚠️ **Esto publica tu código fuente.** Cualquiera que abra las DevTools contra el ambiente desplegado puede leer el TypeScript completo de la aplicación: nombres, comentarios, lógica de negocio. Es una decisión, no un descuido, y para una aplicación interna es una decisión perfectamente defendible — el que puede abrir la aplicación ya está dentro de la red. Pero es una decisión que **se toma con el equipo, no en un commit tuyo de un martes**. En una aplicación expuesta a internet, la respuesta normal es la contraria.

💸 **Deuda intencional del curso.** Lo correcto en un sistema con más gente mirando sería `"sourceMap": { "scripts": true, "hidden": true }`: genera los `.map` pero **no** escribe el comentario `//# sourceMappingURL=` al final del bundle, así que el navegador no los pide solo y solo los usa quien los tiene. Eso obliga a archivar los `.map` en algún lado y a cruzarlos por hash cuando llega un stack trace, o sea: infraestructura. Acá no se paga. Los `.map` viajan en la imagen, cualquiera los descarga, y a cambio el curso no tiene que inventar un almacén de artefactos.

La forma de objeto acepta cuatro claves, y hay una que casi nadie conoce y sirve mucho:

| Clave | Qué hace | Cuándo la quieres |
|---|---|---|
| `scripts` | Mapas para el JavaScript | Siempre que quieras mapas |
| `styles` | Mapas para el CSS | Depurando de dónde salió una regla (**A02**) |
| `hidden` | Genera el `.map` pero no lo enlaza desde el bundle | Cuando no quieres publicar el fuente |
| `vendor` | Mapas también para lo de `node_modules` | El día que el stack trace muere dentro de una librería y necesitas ver *dónde* |

**El costo, para que no te sorprenda:** los mapas engordan el `dist/` de forma notable —un `.map` puede pesar más que el `.js` que describe— y suman tiempo de build. En este proyecto eso se traduce en una imagen más gorda, que es el mismo `dist/` que copia el Dockerfile de la Fase 13. No afecta a lo que descarga el usuario: el navegador solo pide un `.map` si tienes las DevTools abiertas.

---

## 7. Dónde vive el `ng eject` que ya no existe

`ng eject` era un comando de las primeras versiones del CLI: escribía en disco el `webpack.config.js` que el CLI usaba por dentro y te dejaba a solas con él. Se deprecó en el CLI 6 y **para el 8.3.29 ya no existe**. No es que esté desaconsejado: no es un comando.

```bash
# Confírmalo en tu máquina en vez de creérmelo. Ninguna de las dos
# lo va a listar ni a aceptar.
npx ng help
npx ng eject
```

La razón de fondo importa más que el dato: a partir del CLI 6 la configuración de Webpack pasó a ser un **detalle interno** del devkit, algo que cambia entre parches sin avisar porque nadie debería depender de su forma. Un `webpack.config.js` ejectado es una foto de un momento; el día que subes de versión el devkit, tu foto y la realidad ya no coinciden, y el CLI no puede ayudarte porque dejaste de usarlo.

### 7.1 Leerla sin tocarla

Que no puedas ejectarla no significa que no puedas leerla. Está en `node_modules`, en forma de funciones que la construyen por partes:

```bash
# Localiza los archivos que arman la config. La ruta exacta cambia entre
# versiones del devkit: por eso se busca, no se memoriza.
find node_modules/@angular-devkit/build-angular -name 'webpack-configs' -type d
```

En la línea `0.803.x` la respuesta es `node_modules/@angular-devkit/build-angular/src/angular-cli-files/models/webpack-configs/`, y adentro hay un archivo por área:

| Archivo | Qué arma | Qué se responde ahí |
|---|---|---|
| `common.js` | Entradas, salida, `optimization`, plugins base | De dónde salen `runtime`, `main` y los nombres con hash |
| `browser.js` | Lo específico del target navegador | Cómo se decide el juego de bundles de la §3 |
| `styles.js` | La cadena de loaders de CSS/Sass | Por qué el `.scss` de un componente se aísla y el global no (**A02**) |
| `typescript.js` | El enganche de `@ngtools/webpack` | De dónde vienen los errores de AOT de la §2.2 |
| `stats.js` | El formato de la tabla que imprime el build | Qué significa exactamente cada columna de la §2 |

Es lectura de consulta, no de estudio: se entra con una pregunta concreta —"¿quién decide el nombre de este archivo?"— y se sale con la respuesta.

> ⚠️ **Leer sí; editar, jamás.** Un cambio dentro de `node_modules` no está en git, no sobrevive al `npm ci` del Dockerfile ni al del compañero, y produce el peor bug posible: *funciona en tu máquina y solo en tu máquina*, sin ninguna línea en el diff que lo explique. Si estás tentado de tocar un archivo de ahí, lo que necesitas está en la §8.

---

## 8. Las tres salidas cuando el CLI no te deja

Llega el día en que alguien pide algo que las opciones del `angular.json` no cubren. Hay tres caminos, y este apéndice **no escribe configuración de Webpack a mano** en ninguno: los enuncia con su costo para que la conversación se dé con los números delante.

**1. `angular.json` y `ng config`.** La superficie soportada, y sorprendentemente ancha: `budgets`, `sourceMap`, `optimization`, `assets`, `styles`, `scripts`, `fileReplacements`, `outputHashing`, `namedChunks`, `vendorChunk`, `extractCss`. Cuesta cero. **Es la respuesta el 95% de las veces**, y merece agotarse antes de mirar las otras dos.

```bash
# Leer y escribir angular.json sin abrirlo. La ruta es la del JSON.
npx ng config projects.clinical-lab.architect.build.configurations.production.sourceMap
```

**2. Un builder de terceros** (`@angular-builders/custom-webpack`, `ngx-build-plus`, en su línea 8). Reemplazan el builder del devkit por uno que además fusiona un `webpack.config.js` tuyo. Funciona, y es la única opción legítima si de verdad hace falta un plugin de Webpack. El costo: una dependencia más atada a tu versión exacta del CLI, que hay que migrar el día del `ng update` y que ningún compañero nuevo espera encontrar. **No está en este proyecto y no lo va a estar.**

**3. Parchear el devkit** (`patch-package` o un fork). Existe, se hace, y es la opción que más caro sale: heredas el mantenimiento de una pieza que no escribiste, y el siguiente que llegue no va a saber que existe hasta que le explote.

> 🧭 **En un legacy en mantenimiento, la respuesta correcta a "¿podemos meter mano a Webpack?" es casi siempre no.** No por pereza: porque el beneficio es un ajuste de build y el costo es que este proyecto deje de ser un Angular 8 estándar que cualquiera puede recoger. Lo que sí conviene es poder explicar en dos minutos **por qué** no, y para eso sirven las siete secciones anteriores.

---

## 🧭 Cuándo usar qué

Entrada por síntoma. Cada fila responde "esto me pasó, ¿dónde miro primero?".

| Situación | Dónde miras | Por qué |
|---|---|---|
| El build falla con `budgets: maximum exceeded ... ERROR` | §4, y después §5 | El límite es un dato. Mide antes de subir el número |
| Salta un warning de budget y no sabes qué creció | §5.1 con `--stats-json` | El budget dice cuánto, el analizador dice quién |
| Un `.scss` de componente revienta el build | §4, `anyComponentStyle` | El mensaje trae el archivo culpable |
| Compila en `ng serve` pero falla en `--prod` | §2.2, y **Fase 13 §6** | Dev es JIT, prod es AOT. No compilan lo mismo |
| No sabes qué hay dentro de `6.d1e2f3a4b5c6.js` | §2.1 y §5.1 | `namedChunks: false` lo hizo anónimo a propósito |
| Desapareció el `vendor.js` al compilar con `--prod` | §2.1 | `vendorChunk: false`. Está dentro de `main.js` |
| El `dist/` tiene archivos `-es5` y `-es2015` | §3 | Differential loading encendido en el `browserslist` |
| Un bug que solo pasa en el ambiente desplegado, nunca en `ng serve` | §3 | `ng serve` no sirve el bundle es5 jamás |
| Te llega `main.9c4f.js:1:284712` en un reporte | §6 | Con `sourceMap: true` las DevTools lo traducen solas |
| El stack trace muere dentro de `node_modules` | §6, `vendor: true` | Sin ese flag no hay mapas para las librerías |
| El build revienta con `digital envelope routines` | §1.2, y **Fase 0 §6** | Es md4 de Webpack 4 contra OpenSSL 3. Baja a Node 14 |
| Quieres saber qué Webpack tienes | §1.1, `npm ls webpack` | No está en `package.json`; llega por el devkit |
| "¿Y si ejectamos y configuramos a mano?" | §7 y §8 | El comando no existe. Y aunque existiera |
| Necesitas un plugin de Webpack de verdad | §8, opción 2 | Builder de terceros, con su costo declarado |
| Quieres saber quién decide el nombre de un archivo del build | §7.1 | Se lee la config del devkit. Se lee, no se edita |

---

## ⚠️ Advertencias

**Ejectar no es una opción en Angular 8, y no hay forma de que lo sea.** Es la advertencia central de este apéndice, porque es la propuesta que alguien va a hacer en la primera reunión donde el build moleste. `ng eject` no existe en el CLI 8.3.29 —no está deprecado: no es un comando—, y la configuración de Webpack es un detalle interno del devkit que cambia entre parches. Cualquier cosa que se parezca a "sacamos la config y la manejamos nosotros" significa, en la práctica, salirse del CLI: perder `ng update`, perder los builders de test y de serve, y heredar el mantenimiento de una pieza que hoy mantiene otro gratis. Si el argumento es que hace falta un plugin concreto, el camino es un builder de terceros (§8), con su costo dicho en voz alta.

**Nunca edites nada dentro de `node_modules`.** Ni para probar. El cambio no está en git, no sobrevive al `npm ci` del Dockerfile ni al de tu compañero, y produce un "funciona en mi máquina" que no deja rastro en ningún diff. Leer la configuración del devkit (§7.1) es sano y recomendable; escribirla es cómo se pierde una tarde y se gana un misterio.

**Un budget que salta no se arregla subiendo el número.** Se mide primero (§5), se decide después. Subir el límite es correcto solo cuando el número medido demuestra que el límite era irreal, y se sube con un comentario que diga por qué y cuándo. Subirlo a ojo para desbloquear el build convierte la única alarma automática de tamaño que tiene el proyecto en un adorno.

**Los source maps de este proyecto publican el código fuente, y eso fue una decisión.** Van dentro de la imagen y cualquiera con DevTools lee el TypeScript completo del sistema. Para una aplicación interna es defendible; para una expuesta a internet, no. Antes de replicar este arreglo en otro proyecto, esa conversación se tiene con el equipo, no se hereda copiando el `angular.json`.

**El peso del bundle y el peso de la imagen son problemas distintos.** El bundle es lo que descarga el navegador del usuario y se ataca con las §§4-5. La imagen es lo que se descarga el clúster y se ataca con el multi-stage de la **Fase 13 §5.6**. Se confunden todo el tiempo, y confundirlos lleva a optimizar el que no dolía: una imagen de 300 MB con un `main.js` de 1.2 MB y una de 80 MB con el mismo `main.js` se sienten exactamente igual de lentas para quien usa la aplicación.

---

## 📚 Referencias

- https://v8.angular.io/guide/workspace-config — el `angular.json` completo en la versión que usas: todas las opciones del builder `browser`, una por una. Es la fuente de la §2.1 y la §8. ⚠️ Ojo con el dominio: `angular.io` sin el `v8.` te sirve la versión actual, que ya no tiene la mitad de estas opciones.
- https://v8.angular.io/guide/build — configuraciones por ambiente y *file replacement*, que es lo que la **Fase 13 §4** da por sabido.
- https://v8.angular.io/guide/deployment#configure-size-budgets — los budgets con la tabla de tipos de la §4, en la doc de la versión correcta.
- https://v8.angular.io/guide/deployment#differential-loading — differential loading explicado por quien lo escribió, incluida la tabla de qué combinación de `target` y `browserslist` lo dispara (§3).
- https://webpack.js.org/concepts/ — los conceptos de Webpack 4 (entry, output, loaders, plugins, chunks). ⚠️ `webpack.js.org` documenta la versión 5 por defecto y **no** avisa de forma visible; para la 4 hay que entrar por https://v4.webpack.js.org/.
- https://github.com/webpack-contrib/webpack-bundle-analyzer — el analizador de la §5.1, con la explicación de la diferencia entre *stat*, *parsed* y *gzipped*, que es lo que más se malinterpreta.
- https://github.com/danvk/source-map-explorer — la herramienta de la §5.2, para atribuir bytes a archivos de `src/`.
- https://github.com/angular/angular-cli/tree/v8.3.29/packages/angular_devkit/build_angular — el código del devkit en el tag exacto de tu versión. Es la misma configuración que tienes en `node_modules`, pero navegable y con historia de commits: si necesitas saber por qué algo se decide así, el `git blame` de este repositorio lo dice.
- https://github.com/just-jeb/angular-builders/tree/master/packages/custom-webpack — el builder de terceros de la §8, opción 2. ⚠️ Necesitas su línea 8; el `master` del repositorio va por versiones de Angular muy posteriores.
- https://github.com/browserslist/browserslist — la sintaxis del archivo `browserslist` de la §3, y la calculadora para ver qué navegadores entran realmente con tus reglas.
- https://github.com/angular/angular-cli/issues/1656 — la discusión histórica sobre la eliminación de `ng eject`. Vale la pena por los argumentos del equipo del CLI, que son los de la §7. ⚠️ Es un hilo viejo y largo; la conclusión está al final, no al principio.

> ⚠️ Los enlaces y sus contenidos pueden haber cambiado o desaparecido; verifícalos. Acá el riesgo es doble y conviene repetirlo: **la doc de Angular y la de Webpack sirven por defecto una versión muy posterior a la tuya**. Si la URL de Angular no empieza por `v8.`, o la de Webpack no empieza por `v4.`, estás leyendo sobre otro producto que se llama igual.

---

## 🧪 Ejercicios (6)

Cortos y de consulta. Sobre el proyecto del laboratorio, con `node_modules` instalado. Varios se resuelven sin escribir una línea de código.

1. Corre `npm ls webpack` y anota la versión exacta y quién la trajo. Después corre `npx ng version` y confirma que el `@angular-devkit/build-angular` que imprime es de la línea `0.803.x`. Explica en una línea por qué Webpack no aparece en tu `package.json` aunque lo tengas instalado.
2. Compila con `npx ng build --prod` y copia la tabla de chunks a tu cuaderno. Identifica cuál es *initial* y cuál es lazy, y anota el peso del `main`. Después compila con `npx ng build` (sin `--prod`) y responde: **¿de dónde salió el `vendor.js` que apareció, y por qué el `main` es tan distinto?** La respuesta está en §2.1.
3. Descomenta la línea `IE 11` del `browserslist`, compila con `--prod` y compara con el ejercicio 2: cuántos archivos hay ahora en `dist/`, cuánto tardó el build, y qué dos etiquetas `<script>` aparecen en el `index.html`. Revierte el cambio. Después responde sin compilar: **¿por qué `ng serve` no te habría mostrado ninguna diferencia?**
4. Baja el budget `initial` a `500kb` de `maximumError` en el `angular.json` y compila. Copia el mensaje de error exacto. Ahora **sin** subir el budget, corre `npx ng build --prod --stats-json` y `npx webpack-bundle-analyzer` sobre el resultado, y anota los tres paquetes más pesados con su tamaño *gzipped* (no el que sale por defecto). Revierte el budget.
5. Con el analizador todavía abierto, localiza el chunk lazy del dashboard y anota cuánto pesa d3 —que entra por `@swimlane/ngx-charts`— frente a Chart.js. Escribe las dos líneas que pondrías en un ticket para justificar la unificación que la **Fase 10 §5.6** dejó pendiente. Números, no adjetivos.
6. **Diagnóstico.** Te llega un reporte de producción con una sola línea: `TypeError: Cannot read property 'name' of undefined at main.9c4f2b1e77a0.js:1:284712`. Sin tocar código, escribe: qué archivo del `dist/` desplegado necesitas para traducir esa coordenada, por qué en este proyecto ya lo tienes disponible sin recompilar nada, qué opción del `angular.json` lo hizo posible, y qué habrías tenido que hacer si esa opción estuviera en `false`. Las cuatro respuestas están en §6.


> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida: el código que
> explica lo escriben las fases, y un tag que no apunta a un cambio no marca
> nada. Lo que salga de leerlo se commitea con el prefijo de la fase desde la
> que llegaste (`f10: …`), para que su `git log --oneline --grep '^f10'`
> siga completo. Y si un ejercicio produjo una medición, el número va en el
> mensaje de un tag anotado (`ej/a04/3`), que es donde no se pierde. La
> convención completa —tags de fase, de ejercicio y de incidente— está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- 🪦 **Los tres huecos de configuración que este apéndice destapó: cerrados.** El
  `dist/` tenía dos nombres —la Fase 0 crea `clinical-lab` y el Dockerfile copiaba
  `lab-frontend`— y hoy es uno solo, el que sale del `ng new`. El `target: es2015` y
  el `browserslist` los fija la **Fase 0 §5.3**, que es la fase que crea el proyecto,
  con el mecanismo de la §3 resumido y enlazado aquí. Y el `sourceMap: true` de
  producción lo enciende la **Fase 13 §5.6.1**, con su ⚠️ de exposición del código,
  antes del primer `docker build` — que es cuando importa, porque los `.map` viajan
  dentro de la imagen.
- **El bundle es5 que `ng serve` no puede servir** (§3) es un incidente 🟠 esperando a ser escrito: "funciona en todas las máquinas del equipo y falla en el navegador de un usuario", con la particularidad de que ninguna cantidad de `ng serve` lo reproduce. Destino: **cuaderno de incidentes**.
- **El budget subido a mano para desbloquear un despliegue** (§4) es el otro incidente natural de este apéndice, 🟡: la aplicación se pone lenta a lo largo de tres sprints sin que nadie note un salto, porque la única alarma se apagó en el primero. Emparentado con los incidentes 19 y 20 de la Fase 13.
- 🪦 **Cerrado acá.** El pendiente final del **Apéndice A03** —"la auditoría de peso del bundle no existe todavía"— queda resuelto por la §5.
