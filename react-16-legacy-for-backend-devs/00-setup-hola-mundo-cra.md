# 🛠️ Fase 00 — Setup + Hola mundo CRA

> Tutorial React 16 — Rifas y chances · Fase 0 de 11 · **6 horas**
> Depende de: nada (es la primera) · Habilita: Fase 1 — Estructura base + Router 5

---

## 🎯 1. Propósito

Antes de arreglar un solo bug del sistema de rifas, tenés que poder levantarlo en tu máquina. Suena trivial. No lo es. En una app legacy de 2020-2022, "clono el repo y corre" es una promesa que casi nunca se cumple a la primera: la versión de Node no coincide, un paquete nativo no compila en tu arquitectura, el `sass` que esperaba el build no es el que instalaste. Media hora perdida antes de escribir una línea de código.

Esta fase existe para que esa media hora la pierdas **ahora, a propósito y con red**, en lugar de un martes a las 6 de la tarde con PROD caído. Vas a dejar el ambiente en pie en tu plataforma —Windows, Mac con Apple Silicon o Linux—, vas a arrancar un Create React App con las versiones exactas que usa el proyecto real, y vas a montar tu primer componente: una tarjeta que muestra una rifa. Nada de routing, nada de Redux, nada de fetch. Una rifa hardcodeada y un componente que la pinta.

El objetivo no es que aprendas a construir. Es que aprendas a **poner el sistema en marcha y mirarlo por dentro** con las herramientas del oficio. Un dev de mantenimiento que no sabe levantar el proyecto no puede arreglar nada; uno que lo levanta pero no sabe abrir React DevTools trabaja a ciegas. Y como el mayor dolor de setup de esta era vive justo en Apple Silicon con `node-sass`, ese caso es, en sí mismo, el primer ejercicio forense de la fase.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Node **14.21.3** corriendo vía nvm, con un `.nvmrc` en el repo, verificado con `node -v`.
- [ ] Proyecto **CRA 4.0.3** con React 16.14.0 creado y arrancando en `localhost:3000` sin errores en consola.
- [ ] **Bootstrap 4.6.2 + dart-sass** integrados; un `_tokens.scss` propio que compila y aplica estilos visibles.
- [ ] Un componente funcional con hooks (**`RaffleCard`**) que renderiza una rifa y tiene estado local (un toggle de detalle con `useState`).
- [ ] **React DevTools** instalado y **Network tab** usado para inspeccionar el componente y ver cargar el bundle.
- [ ] Ambiente reproducible: cualquier compañero clona el repo y lo levanta con `nvm use && npm ci && npm start`.

Si podés marcar las seis, la fase está cerrada. La quinta es la que más gente saltea y la que más falta hace después.

---

## 🚫 3. Qué queda fuera por ahora

- **Routing (React Router 5)** → Fase 1. Por ahora hay una sola pantalla; no hace falta navegar a ningún lado.
- **Redux / store / slices** → Fase 2 en adelante. El estado de `RaffleCard` vive en un `useState` local y con eso sobra.
- **json-server y `db.json`** → Fase 3. La rifa de esta fase va **hardcodeada** en el código (marcada 💸 más abajo). No hay backend todavía.
- **Autenticación** → Fase 2. Cualquiera que abra `localhost:3000` ve la rifa; está bien así.
- **Middleware de caos, mock de lotería, epics, polling** → Fases 3, 6 y 7. Ni los nombres nos importan aún.

La regla de la fase es brutal en su simplicidad: **una pantalla, un componente, cero red.** Todo lo demás es ruido que sumamos después.

---

## 🧠 4. Conceptos mínimos

Sos senior y sabés qué es npm, qué es un bundler y qué es un componente. No te voy a explicar eso. Te voy a explicar las cuatro cosas de **esta** fase que muerden si las ignorás.

### Por qué Node 14 y no el que tenés instalado

El sistema real se construyó con **Create React App 4.0.3**, la última versión de CRA que soporta React 16. CRA 4 y sus `react-scripts` fueron pensados para la era de **Node 14**. Si intentás correrlo con Node 18 o 20 —lo que probablemente tengas hoy— te vas a encontrar con el famoso `error:0308010C:digital envelope routines::unsupported`, que es OpenSSL 3 peleándose con el Webpack viejo que CRA lleva escondido. Hay workarounds con flags, sí, pero en mantenimiento no querés workarounds: querés **la misma versión que corre en producción**. Por eso fijamos Node 14.21.3 y lo dejamos escrito en un `.nvmrc` para que nadie del equipo lo adivine.

> 📝 **Nota de época.** En 2020-2022, CRA era *el* default para arrancar una SPA de React. No había Vite en el radar de las empresas, Next.js todavía no era omnipresente para apps internas, y "create-react-app y a trabajar" era la respuesta obvia. El sistema que vas a mantener nació ahí. Que hoy CRA esté prácticamente jubilado 🪦 no cambia que tu trabajo es mantenerlo, no reescribirlo.

### Qué es `.nvmrc` y por qué salva reuniones

`.nvmrc` es un archivo de una sola línea con la versión de Node que el proyecto necesita (`14.21.3`). Cuando alguien clona el repo y corre `nvm use`, nvm lee ese archivo y cambia a la versión correcta. Sin él, cada dev usa "el Node que tenía puesto" y aparecen bugs que solo pasan en la máquina de uno. Es la primera línea de defensa contra el "en mi máquina funciona".

### Por qué dart-sass y no node-sass (y por qué te va a importar en Mac)

Bootstrap 4 con Sass, en 2021, típicamente se compilaba con **`node-sass`**. El problema: `node-sass` es un wrapper sobre LibSass escrito en C++ que necesita **compilar código nativo** al instalarse. Y **nunca tuvo binarios prebuilt para arm64**. En un Mac con Apple Silicon (M1/M2/M3/M4), `npm install` de `node-sass` intenta compilar con node-gyp y explota con errores de Python o de `node-gyp` que no le dicen nada a nadie.

La solución, ya confirmada para este proyecto, es usar **`sass`** (dart-sass): la implementación oficial de Sass en Dart, compilada a JavaScript puro. Sin binarios nativos, sin node-gyp, sin arquitectura que valga. CRA 4 lo detecta automáticamente: si encuentra `sass` instalado, lo usa. Funciona igual en Windows x86_64, en Linux y en Mac arm64.

> ⚠️ **Advertencia.** No instales `node-sass` "por costumbre" ni porque un tutorial viejo lo diga. En este proyecto usamos `sass`. Si ves `node-sass` en un `package.json` que heredes, es candidato a incidente, no a imitación. 💸 En el sistema real puede seguir viviendo `node-sass`; más abajo documentamos cómo esquivarlo sin tocar el resto.

### Qué hace CRA por vos (y por qué no lo tocamos)

Cuando corrés `npm start`, no estás corriendo tu código directo: estás corriendo un **Webpack** configurado, un **Babel** que transpila tu JSX, un dev server con hot reload y un montón de plumbing más, todo **oculto** detrás de `react-scripts`. Vos ves cuatro archivos; CRA maneja doscientos por debajo. Eso es cómodo y es una caja negra a la vez. Por ahora nos alcanza saber que existe. El detalle de qué hace Webpack ahí adentro, y por qué **no** hacemos `eject`, vive en el Apéndice A4 — no lo repetimos acá.

> 📚 Si querés espiar desde ya qué es CRA por dentro: https://create-react-app.dev/docs/getting-started — pero con 10 minutos alcanza para esta fase.

### Mini-repaso exprés: JSX y `useState`

Venís de backend y quizás tocaste React moderno de refilón. Antes del código, el mínimo indispensable para leer lo que sigue sin fricción:

| Concepto | Qué es en una línea | Ejemplo |
|---|---|---|
| **JSX** | HTML-como-sintaxis dentro de JS; se transpila a llamadas `React.createElement`. | `<div className="card">{raffle.name}</div>` |
| **`className`** | El atributo `class` de HTML se llama `className` en JSX (`class` es palabra reservada de JS). | `<span className="badge">` |
| **`{ }` en JSX** | Interpola una expresión JS dentro del markup. | `{raffle.pricePerNumber}` |
| **`useState`** | Hook que te da `[valor, setter]`; cambiar el valor re-renderiza el componente. | `const [isDetailOpen, setDetailOpen] = useState(false)` |
| **Props** | Los "argumentos" de un componente; entran como un objeto. | `function RaffleCard({ raffle }) { ... }` |

> 📚 Si el hook `useState` te suena a chino, 15 minutos acá y volvés: https://react.dev/reference/react/useState — cubre React ≥ 16.8, que es justo la nuestra. Ojo con ejemplos que usen APIs de 17/18.

---

## 💻 5. Implementación y código comentado

El plan es el mismo en las tres plataformas: **instalar Node 14 con un gestor de versiones → crear el CRA → sumar Bootstrap y sass → escribir `RaffleCard`**. Lo que cambia es el paso de instalar Node y aislar el ambiente, porque cada sistema tiene su fricción — y Apple Silicon tiene varias vías, cada una con su tradeoff. Empezamos por las plataformas simples y dejamos Mac para el final, que es el caso interesante.

### 5.1 🪟 Windows 11 (entorno por defecto del equipo)

En Windows el gestor de versiones es **nvm-windows** (ojo: es un proyecto distinto al nvm de Unix, mismo espíritu). Lo bajás desde su release, lo instalás, cerrás y reabrís la terminal, y después:

```bash
nvm install 14.21.3
nvm use 14.21.3
node -v   # debe imprimir v14.21.3
npm -v    # 6.x, el que viene con Node 14
```

No vas a tener dramas de arquitectura: todo es x86_64. Lo único que conviene tener a mano por si algún día un paquete nativo lo pide es Python 3 en el `PATH`; en esta fase, con `sass` (que es JS puro), no lo vas a necesitar. Setup realista: 20-30 minutos contando descargas.

> 💡 **Truco.** Si `nvm use` te dice que necesita permisos de administrador, abrí la terminal como admin **una sola vez** para el `use`; el resto del trabajo diario no lo requiere.

### 5.2 🐧 Linux amd64

El caso sin sorpresas. nvm, Node 14, listo:

```bash
nvm install 14.21.3 && nvm use 14.21.3
node -v   # v14.21.3
```

Todo nativo, sin emulación, setup en 15 minutos o menos. Si tu PROD también es Linux amd64, tenés la mejor paridad de las tres plataformas casi gratis.

### 5.3 🍎 macOS Apple Silicon (M1/M2/M3/M4) — el caso interesante

Acá es donde `node-sass` explota, y donde el setup se vuelve una decisión y no un trámite. Tenés varias vías; te las ordeno de más simple a más fiel-a-PROD para que elijas según lo que necesites hoy.

#### Camino nativo simple (recomendado para el Hola mundo)

Como en este proyecto ya decidimos usar **dart-sass** (`sass`) en vez de `node-sass`, la fricción histórica de arm64 **desaparece**: no hay nada nativo que compilar. Para la Fase 0 podés instalar Node 14 directo con nvm y trabajar nativo, sin contenedor:

```bash
# nvm ya instalado (brew install nvm o el script oficial)
nvm install 14.21.3 && nvm use 14.21.3
node -v   # v14.21.3
```

Con esto, todo el resto de la fase te funciona nativo y rápido, y no necesitás Docker para ver la tarjeta. Es la vía recomendada mientras el proyecto no tenga backend. La contra: perdés paridad con PROD (que corre en Linux) y, si más adelante entra alguna otra dependencia nativa, reaparece la fricción. Por eso, en cuanto llegue el track forense de "esto solo pasa en Linux", vas a querer uno de los caminos con contenedor de abajo.

#### Opción M1-A — arm64 nativo en Colima (recomendada cuando sumes contenedor)

Colima corre contenedores Linux **arm64 sin emulación**: casi tan rápido como nativo, sin Rosetta. Reemplazás `node-sass` por `sass` y CRA lo detecta solo. Es nuestra opción por defecto frente a Docker Desktop porque consume ~2 GB de RAM en reposo contra los 6-8 GB de Docker Desktop.

`Dockerfile.dev`:

```dockerfile
FROM node:14.21.3-bullseye

RUN apt-get update && apt-get install -y \
    build-essential python3 \
    && ln -sf /usr/bin/python3 /usr/bin/python

WORKDIR /app
EXPOSE 3000 9876
CMD ["bash"]
```

`docker-compose.yml`:

```yaml
services:
  react:
    build: .
    volumes:
      - .:/app
      - node_modules:/app/node_modules    # ← volumen dedicado, no del host
    ports: ["3000:3000"]
    stdin_open: true
    tty: true
  mock:
    image: node:14
    working_dir: /mock
    volumes: [./mock:/mock]
    command: npx json-server --host 0.0.0.0 --watch db.json
    ports: ["3001:3000"]
volumes:
  node_modules:
```

> ⚠️ El volumen dedicado `node_modules` es **clave**: si montás el `node_modules` del host (macOS arm64) dentro del contenedor Linux, los binarios no coinciden y todo falla. El volumen nombrado mantiene el `node_modules` compilado *dentro* del contenedor. Nunca compartas `node_modules` entre arquitecturas distintas.

Flujo:

```bash
brew install colima docker docker-compose
colima start --cpu 4 --memory 4 --arch aarch64
docker compose up -d
docker compose exec react bash
# ya dentro del contenedor:
npm ci --legacy-peer-deps
npm start
```

Editás en VS Code en el host (o con Dev Containers) y abrís el navegador en `localhost:3000`. El servicio `mock` ya queda declarado para la Fase 3, aunque todavía no lo conectemos a la app.

#### Opción M1-B — amd64 con Colima vz-rosetta (paridad exacta con PROD)

Si producción corre en Linux **amd64** y querés reproducir exacto —útil para bugs "solo pasan en PROD" y para los smoke tests del track forense—:

```bash
colima start --cpu 4 --memory 4 --arch x86_64 --vm-type vz --vz-rosetta
```

Y en el `Dockerfile.dev` fijás la plataforma:

```dockerfile
FROM --platform=linux/amd64 node:14.21.3-bullseye
```

El resto es igual a la Opción A. Velocidad: 2-3× más lento que arm64 nativo, pero **idéntico a PROD**. `vz` es el VZ framework de Apple y `--vz-rosetta` activa la traducción x86_64 acelerada por Rosetta 2; la combinación te da amd64 utilizable sin la lentitud de la emulación pura por software.

#### Runtime: Colima vs Docker Desktop

| | Colima (recomendado) | Docker Desktop |
|---|---|---|
| RAM en reposo | ~2 GB | 6-8 GB |
| Comandos | `docker`, `docker compose` iguales | iguales |
| amd64 | VZ + Rosetta 2 | Rosetta (activar en Settings) |
| GUI | No | Sí |
| Costo | Libre | Libre uso personal / pago empresa |

Ambos funcionan sin cambios en el proyecto: el código es agnóstico del runtime. Si usás Docker Desktop, activá "Use Rosetta for x86_64/amd64 emulation on Apple Silicon" en Settings. En esta fase se practica encender uno y apagar el otro sin romper nada.

#### 🪟 Windows dentro de macOS (solo para bugs específicos de Windows)

Si aparece un incidente que **solo pasa en Windows 11** —separadores de ruta, finales de línea CRLF, permisos NTFS—, en Apple Silicon tenés dos vías: **UTM** (gratis, basado en QEMU; Windows 11 ARM Insider Preview; setup de 1-2 h, suficiente para reproducciones puntuales) o **Parallels / VMware Fusion** (mejor integración, más pesados; Parallels es de pago, Fusion gratis para uso personal). No es requisito del tutorial: es un recurso del track forense para cuando un incidente lo justifique.

#### Tabla comparativa de entornos

| Entorno | Setup | Velocidad | RAM | Paridad PROD | Recomendación |
|---|---|---|---|---|---|
| Windows 11 nativo | Media | ⚡⚡⚡ | Baja | Alta/Media | **Default del equipo** |
| Linux nativo | Rápida | ⚡⚡⚡ | Baja | Alta | Si tenés Linux |
| M1 nativo (host) | Rápida | ⚡⚡⚡ | Baja | Baja | Solo para el Hola mundo |
| M1 + Colima arm64 (A) | Rápida | ⚡⚡⚡ | Baja | Media | **Default en Apple Silicon con contenedor** |
| M1 + Colima amd64 vz-rosetta (B) | Rápida | ⚡⚡ | Baja | Alta | **Si necesitás paridad PROD** |
| M1 + Docker Desktop | Media | ⚡⚡⚡ | Media | según arch | Si preferís GUI |
| Windows en M1 (UTM/Parallels) | Alta | ⚡ | Alta | Alta (bugs Win) | Solo cuando toque |

### 5.4 Fijar la versión en el repo

Antes de crear nada, dejá la versión escrita para que el resto del equipo no la adivine:

```bash
echo "14.21.3" > .nvmrc
```

De ahora en más, quien clone el repo corre `nvm use` en la raíz y nvm lee ese archivo. Una línea, cero reuniones sobre "¿qué Node usás vos?".

### 5.5 Crear el proyecto con CRA 4.0.3

Fijamos la versión de CRA explícitamente. No uses `npx create-react-app` a secas, porque te bajaría la última —incompatible con React 16—:

```bash
npx create-react-app@4.0.3 raffles-app --use-npm
cd raffles-app
```

Esto crea el andamiaje con `react-scripts@4.0.3`, que a su vez trae **React 16.14.0** (nuestra versión confirmada). Verificalo antes de seguir:

```bash
cat package.json | grep react
# "react": "^16.14.0",
# "react-dom": "^16.14.0",
# "react-scripts": "4.0.3"
```

Arrancá el dev server para confirmar que la base respira:

```bash
npm start
```

Se abre `localhost:3000` con el logo de React girando. Todavía no es nuestra app; es el andamiaje. Pero si esto no arranca, no sigas: resolvé el arranque primero (la sección 6 tiene los errores típicos).

> **Prueba de fuego.** Con `npm start` corriendo, abrí `localhost:3000`, después cerrá el proceso con `Ctrl+C` y recargá el navegador. La página debe morir (error de conexión). Volvé a levantar `npm start` y recargá: vuelve. Parece tonto, pero acabás de comprobar que el dev server es quien sirve la app, no un archivo estático. Esa distinción te ahorra debugging en la Fase 3.

### 5.6 Sumar Bootstrap 4.6.2 y dart-sass

Instalamos Bootstrap en su versión exacta y `sass` (dart-sass, **no** node-sass):

```bash
npm install bootstrap@4.6.2
npm install --save-dev sass
```

Ahora renombrá el `src/index.css` que trae CRA a `src/index.scss` (así usamos Sass de una vez) y creá un archivo de tokens propio. Este `_tokens.scss` es el germen del mini design system que se desarrolla en serio en el Apéndice A2; acá lo dejamos mínimo.

`src/styles/_tokens.scss`:

```scss
// Tokens del mini design system de Rifas y chances.
// Acá centralizamos los valores que después Bootstrap y nuestros
// componentes reutilizan. En Fase 0 son cuatro; en A2 crecen.

$raffle-primary: #0066cc;  // azul de marca, para acciones principales
$raffle-success: #28a745;  // verde "rifa abierta / número disponible"
$raffle-danger:  #dc3545;  // rojo "cerrada / vendido"
$raffle-spacing: 0.5rem;   // unidad base de espaciado
```

`src/index.scss`:

```scss
// 1) Primero nuestros tokens, para que estén disponibles abajo.
@import "./styles/tokens";

// 2) Bootstrap completo. En un proyecto real se importa solo lo que
//    se usa para achicar el bundle 💸 (deuda: lo optimizamos en A1),
//    pero en Fase 0 traemos todo y seguimos.
@import "~bootstrap/scss/bootstrap";

// 3) Un estilo propio que usa un token, para PROBAR que Sass compila
//    de verdad y no solo que Bootstrap se coló.
.raffle-card {
  border-top: 4px solid $raffle-primary;
  margin-bottom: $raffle-spacing * 2;
}
```

En `src/index.js`, asegurate de importar el Sass (CRA compila `.scss` sin config extra gracias a que instalamos `sass`):

```javascript
import React from "react";
import ReactDOM from "react-dom";
import "./index.scss"; // ← antes era index.css; ahora Sass
import App from "./App";

// React 16: el render clásico con ReactDOM.render.
// (En React 18 esto cambia a createRoot 💸/🔥 — lo vemos en A8,
//  pero NO lo usamos acá: estamos en 16.14.0.)
ReactDOM.render(<App />, document.getElementById("root"));
```

> **Detalles con intención.** Importamos los tokens **antes** que Bootstrap y que nuestros estilos porque Sass resuelve variables de arriba hacia abajo: si `$raffle-primary` se define después de usarlo, Sass no lo encuentra. Y renombramos a `.scss` en vez de dejar `.css` porque queremos que el pipeline de Sass esté activo desde el minuto cero, no "cuando lo necesitemos".

### 5.7 El primer componente: `RaffleCard`

Ahora sí, la estrella de la fase. Un componente funcional con hooks que recibe una rifa por props y muestra sus datos, con un botón que despliega u oculta un bloque de detalle usando `useState`.

Ojo a una convención que vas a ver en todo el curso y que arranca acá: **el código va en inglés, pero lo que ve el usuario va en español.** El estado interno de la rifa es `'open'` (un valor de enum, código), y una pequeña función `statusLabel` lo traduce a `"Abierta"` (texto de interfaz). Nunca metas `'abierta'` como valor de dato; nunca le muestres `open` al usuario.

`src/components/RaffleCard.js`:

```javascript
import React, { useState } from "react";

/**
 * Traduce el estado interno de la rifa a la etiqueta que ve el usuario.
 * El `case` va en inglés (es el valor de dato); el `return` va en
 * español (es lo que se muestra en pantalla).
 */
function statusLabel(status) {
  switch (status) {
    case "open":
      return "Abierta";
    case "closed":
      return "Cerrada";
    case "resolved":
      return "Resuelta";
    default:
      return status;
  }
}

/**
 * Tarjeta que muestra una rifa y permite desplegar su detalle.
 * Componente funcional con hooks: es el estilo que usamos para
 * módulos nuevos. (El código legacy tiene clases; las vemos en A5.)
 *
 * @param {Object} props
 * @param {Object} props.raffle - Rifa a mostrar.
 */
function RaffleCard({ raffle }) {
  // Estado local: ¿está desplegado el detalle? Arranca cerrado.
  // useState devuelve [valor, setter]; cambiar el valor re-renderiza.
  const [isDetailOpen, setDetailOpen] = useState(false);

  // Elegimos la clase del badge según el estado de la rifa.
  // Nada de lógica de negocio pesada acá: solo presentación.
  const badgeClass =
    raffle.status === "open" ? "badge-success" : "badge-secondary";

  return (
    <div className="raffle-card card p-3">
      <div className="d-flex justify-content-between align-items-center">
        <h5 className="mb-0">{raffle.name}</h5>
        {/* El valor va en inglés en el dato, pero mostramos la etiqueta
            traducida al español. */}
        <span className={`badge ${badgeClass}`}>
          {statusLabel(raffle.status)}
        </span>
      </div>

      <p className="text-muted mb-2">
        Precio por número: ${raffle.pricePerNumber}
      </p>

      <button
        className="btn btn-outline-primary btn-sm align-self-start"
        onClick={() => setDetailOpen(!isDetailOpen)}
      >
        {isDetailOpen ? "Ocultar detalle" : "Ver detalle"}
      </button>

      {/* Renderizado condicional: el detalle solo existe en el DOM
          cuando isDetailOpen es true. Es el patrón más común de
          React para mostrar/ocultar. */}
      {isDetailOpen && (
        <div className="mt-3">
          <p className="mb-1">Lotería: {raffle.lotteryId}</p>
          <p className="mb-1">Premio base: ${raffle.basePrize}</p>
          <p className="mb-0">Cierre: {raffle.closesAt}</p>
        </div>
      )}
    </div>
  );
}

export default RaffleCard;
```

Y `src/App.js`, que arma la rifa hardcodeada y monta la tarjeta:

```javascript
import React from "react";
import RaffleCard from "./components/RaffleCard";

/**
 * App raíz. En Fase 0 no hay routing ni store: montamos una sola
 * tarjeta con una rifa fija. En cuanto entre json-server (Fase 3)
 * estos datos vendrán del backend.
 */
function App() {
  // 💸 DEUDA TÉCNICA INTENCIONAL: la rifa está hardcodeada acá.
  //    Lo correcto es traerla de un backend, pero todavía no tenemos
  //    json-server (llega en Fase 3) ni store (Fase 2+). Por ahora,
  //    un objeto literal alcanza para renderizar y aprender el setup.
  //    La forma del objeto ya respeta el modelo de datos oficial
  //    (ver PLAN-DEL-CURSO, modelo JSON de referencia) para no tener
  //    que reescribir RaffleCard cuando lleguen los datos reales.
  const demoRaffle = {
    id: 1,
    name: "Rifa fin de mes",
    lotteryId: "boyaca",
    closesAt: "2024-03-30T22:00:00-05:00",
    pricePerNumber: 5000,
    basePrize: 500000,
    status: "open",
  };

  return (
    <div className="container py-4">
      <h1 className="mb-4">Rifas y chances</h1>
      <RaffleCard raffle={demoRaffle} />
    </div>
  );
}

export default App;
```

Guardá, mirá el navegador (el hot reload de CRA ya recargó), y deberías ver la tarjeta con el borde azul superior (ese borde es tu prueba de que **el token de Sass se aplicó**), el badge verde de "Abierta", y un botón que despliega el detalle al clickearlo.

> **El patrón a memorizar.** `useState` para estado local + renderizado condicional con `&&` es el 80% de la interactividad simple en React: *un booleano en el estado → un `&&` en el JSX → el bloque aparece y desaparece.* Lo vas a ver mil veces en el código que mantengas. Cuando algo "aparece y desaparece" en la UI, buscá primero un `useState` booleano y un `&&` o un ternario.

> **Detalles con intención.** El estado de la rifa vive como `'open'` (inglés, valor de dato) y `statusLabel` lo convierte a `"Abierta"` (español, UI). Esa separación no es capricho de idioma: mañana, cuando `RaffleCard` reciba la rifa de un backend, el dato que llega es `status: 'open'` y el mapeo a etiqueta sigue viviendo en un solo lugar. Si mezclaras idioma y dato, cada pantalla reinventaría la traducción.

> **Prueba de fuego.** Clickeá "Ver detalle" y confirmá que aparece el bloque. Ahora abrí React DevTools (sección 6), seleccioná `RaffleCard`, y mirá el hook `State`: dice `false` cuando está cerrado y `true` cuando está abierto. Cambialo a mano desde DevTools y mirá cómo la UI reacciona sin que hayas tocado el botón. Eso es ver el estado *manejar* la vista.

#### 💸 Nota de deuda de esta fase

Dejamos **una** deuda intencional, y la nombramos para pagarla después: la rifa está **hardcodeada** en `App.js`. Lo correcto sería traerla de un backend. No lo hacemos ahora porque el backend (json-server) no existe hasta la Fase 3 y el store (Redux) hasta la Fase 2+. La forma del objeto ya coincide con el modelo de datos oficial, así que cuando los datos lleguen de verdad, `RaffleCard` no cambia: solo cambia de dónde sale `raffle`. Esa deuda se salda en Fase 3, cuando `App` deje de inventar la rifa y la pida al mock.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**`error:0308010C:digital envelope routines::unsupported` al hacer `npm start`.**
Síntoma: el dev server no arranca y escupe ese código críptico (a veces como `ERR_OSSL_EVP_UNSUPPORTED`). Causa: estás corriendo con Node 17+ (probablemente 18 o 20), cuyo OpenSSL 3 rompe el Webpack viejo de CRA 4. Fix mínimo: `nvm use 14.21.3` y volvé a intentar. Si `nvm use` no cambia nada, confirmá que tenés el `.nvmrc` y que estás parado en la raíz del proyecto. **No** parchees esto con `NODE_OPTIONS=--openssl-legacy-provider` salvo emergencia: el fix correcto es usar la versión de Node de PROD.

**`node-sass` falla al instalar en Apple Silicon.**
Síntoma: un error de node-gyp compilando binarios arm64 al hacer `npm install`. Causa: `node-sass` no tiene prebuilts arm64. Fix: usá `sass` (dart-sass) como se indicó — `npm uninstall node-sass && npm install --save-dev sass`. Si el `package.json` heredado trae `node-sass`, quitalo y añadí `sass`; CRA 4 lo detecta solo. Recordá: en este proyecto, **siempre `sass`**.

**"Funciona en mi Mac pero no en el contenedor" (o al revés).**
Síntoma: la app compila en un lado y falla en el otro con errores de binarios. Causa casi segura: el `node_modules` del host montado dentro del contenedor. Usá el volumen nombrado del `docker-compose.yml` y nunca compartas `node_modules` entre arquitecturas distintas.

**La página carga pero se ve sin estilos (Bootstrap "no aparece").**
Síntoma: la tarjeta está ahí pero fea, sin card, sin badge, sin colores. Causa casi segura: no importaste el `.scss` en `index.js`, o el `@import "~bootstrap/scss/bootstrap"` tiene mal la ruta. Fix: revisá que `index.js` tenga `import "./index.scss"` y que el `~` esté presente (le dice a Webpack "buscá en node_modules"). El borde azul superior de `.raffle-card` es tu canario: si **ese** aparece pero Bootstrap no, el problema es el import de Bootstrap, no el de Sass.

**`Something is already running on port 3000`.**
Síntoma: CRA no puede levantar. Causa: dejaste otro `npm start` corriendo (o cualquier cosa en el 3000). Fix rápido: aceptá cuando CRA te ofrece usar otro puerto, o matá el proceso previo. En la Fase 3, cuando entren json-server y el mock de lotería, vas a hacer malabares con varios puertos; conviene acostumbrarte ahora a saber quién ocupa cuál.

> ⚠️ **Sobre CORS.** Todavía **no** vas a ver errores de CORS en esta fase, porque no hay ninguna petición a otro origen: todo es estático servido por el dev server. Lo menciono porque en la Fase 3, cuando `RaffleCard` deje de inventar la rifa y `App` la pida a json-server en otro puerto, CORS va a aparecer. Si en Fase 0 ves un error que dice "CORS", es que copiaste código de una fase futura: volvé al plan.

### Pieza forense de esta fase: aprender a mirar

Un dev de mantenimiento vive en tres herramientas antes de tocar código. Esta fase las presenta en su forma más básica. El detalle largo vive en `FORENSE-FASE-00`; acá va lo esencial.

**La consola (DevTools → Console).** Abrila con F12. Con la app corriendo sin bugs, debería estar limpia salvo algún warning benigno de CRA. Acostumbrate a tenerla abierta **siempre**: en legacy, muchos bugs gritan por la consola mucho antes de que el usuario los note. Un `console.error` rojo es una pista, no un adorno.

**El Network tab (DevTools → Network).** Recargá la página con Network abierto y mirá qué baja: el `bundle.js` (tu código + React + Bootstrap, todo empaquetado por Webpack), el HTML, los estilos. Fijate en el tamaño del bundle — vas a ver que Bootstrap completo pesa lo suyo (ahí está la deuda 💸 de "importar todo" que se optimiza en A1). Confirmá que todo carga con 200, no con 404. No hay llamadas a APIs porque no hay APIs: eso también es información. En la Fase 2, este tab va a ser tu mejor amigo para depurar el interceptor de axios.

**React DevTools (extensión del navegador).** Instalala desde la tienda de extensiones de tu navegador. Te agrega dos pestañas, ⚛️ Components y ⚛️ Profiler. Andá a **Components**, seleccioná `RaffleCard` en el árbol, y mirá el panel derecho: vas a ver sus **props** (`raffle`, con todos sus campos) y sus **hooks** (`State: false`). Clickeá el botón "Ver detalle" en la app y mirá cómo ese `State` cambia a `true` en vivo. Eso es lo que separa depurar React de depurar a ciegas: **ver el estado y las props reales de cada componente**, no adivinarlos.

**Ejercicio "rompe a propósito y observá."** En `RaffleCard`, cambiá la línea del `useState` inicial de `useState(false)` a `useState(true)`. Guardá. La tarjeta ahora arranca con el detalle **abierto**. Confirmalo en React DevTools: el hook `State` dice `true` desde el vamos. Volvé a `false`. Acabás de comprobar, con evidencia visual, quién controla ese comportamiento. Esa es la mentalidad forense: no "creo que es el estado", sino "lo vi en DevTools".

---

## 🧪 7. Ejercicios (30)

Los primeros calientan el setup; los últimos te hacen diagnosticar cosas rotas, que es el músculo real del curso. Varios son de diagnóstico: te entregan algo que no anda y tenés que reproducir y localizar, no solo construir. Cuando un ejercicio nombra código, usa el identificador en inglés vigente (`RaffleCard`, `statusLabel`, `demoRaffle`).

**🟢 Fácil (1–8)**

1. Instalá Node 14.21.3 con tu gestor de versiones y confirmá con `node -v` y `npm -v`. Anotá qué versión de npm trajo.
2. Creá el `.nvmrc` con `14.21.3`, cambiá a otra versión de Node con `nvm use 18` (o la que tengas), volvé a la raíz del proyecto y corré `nvm use` a secas. Confirmá que vuelve a 14.21.3 solo.
3. Creá el proyecto con `create-react-app@4.0.3` y verificá en `package.json` que `react` es `^16.14.0` y `react-scripts` es `4.0.3`.
4. Arrancá `npm start`, confirmá que abre en `localhost:3000`, y anotá qué imprime la consola del navegador (debería estar casi limpia).
5. Instalá `bootstrap@4.6.2` y `sass`, renombrá `index.css` a `index.scss`, y confirmá que la app sigue arrancando.
6. Creá `_tokens.scss` con los cuatro tokens y aplicá `$raffle-primary` al borde de `.raffle-card`. Confirmá visualmente que el borde azul aparece.
7. Escribí `RaffleCard` y montalo en `App` con la rifa hardcodeada `demoRaffle`. Confirmá que ves nombre, estado y precio.
8. Cambiá el `status` de `demoRaffle` de `'open'` a `'closed'` y confirmá que el badge cambia de verde a gris y la etiqueta pasa de "Abierta" a "Cerrada".

**🟡 Intermedio (9–17)**

9. Agregá un segundo objeto rifa en `App` y montá **dos** `RaffleCard`. Confirmá que cada tarjeta tiene su propio estado de "detalle" independiente (abrir una no abre la otra).
10. Instalá React DevTools, seleccioná una `RaffleCard` y cambiá su hook `State` a mano desde el panel. Documentá qué pasó en la UI.
11. Formateá `basePrize` con separador de miles usando `Intl.NumberFormat('es-CO')`. Confirmá que muestra `500.000` y no `500000`.
12. Extraé el badge a un mini-componente `StatusBadge` que reciba `status` por props, use `statusLabel` internamente y devuelva el `<span>` con la clase correcta. Usalo desde `RaffleCard`.
13. En Network tab, recargá y anotá el tamaño del `bundle.js`. Después importá solo `~bootstrap/scss/bootstrap-grid` en vez de Bootstrap completo y compará el tamaño. Revertí el cambio al terminar.
14. Agregá un `console.log(raffle.name)` dentro de `RaffleCard` y observá en la consola cuántas veces se imprime al abrir y cerrar el detalle. Explicá por qué.
15. Cambiá el `onClick` del botón para que use una función nombrada `toggleDetail` en vez de la arrow inline. Confirmá que el comportamiento es idéntico.
16. Agregá el estado `'resolved'` a `statusLabel` (devolviendo "Resuelta") y hacé que el badge lo pinte con un color propio (usá `$raffle-primary` o agregá un token).
17. Convertí la lista de campos del detalle en un array y renderizala con `.map()`. Acordate de la `key`. Confirmá que React DevTools ya no muestra warnings de key en consola.

**🟠 Difícil (18–24)**

18. **Diagnóstico:** te paso un `package.json` con `"node-sass": "^6.0.0"` en vez de `sass`. En un Mac arm64 el `npm install` falla. Reproducí el error (o razoná por qué falla), identificá la causa y aplicá el fix mínimo. Escribí dos líneas de post-mortem.
19. **Diagnóstico:** un compañero reporta que "la app no arranca, tira un error de digital envelope". Sin ver su máquina, listá las tres preguntas que le harías y cuál es la causa más probable.
20. **Diagnóstico:** la app carga pero se ve completamente sin estilos. El borde azul de `.raffle-card` **sí** aparece. ¿Dónde está el problema y por qué el borde azul es la pista clave?
21. Configurá el proyecto para que `npm start` arranque en el puerto `4000` en vez del `3000`, sin romper nada. Documentá cómo lo hiciste y por qué (pista: variable de entorno `PORT`).
22. Agregá una variable de entorno `REACT_APP_ORGANIZER` con tu nombre y mostrala en el `<h1>`. Confirmá que aparece y explicá por qué **debe** empezar con `REACT_APP_`.
23. Rompé a propósito el import de Bootstrap (quitá el `~`) y documentá exactamente qué error da y en qué herramienta lo viste primero (consola de la terminal vs consola del navegador).
24. (Apple Silicon) Levantá el proyecto con la **Opción M1-A** (Colima arm64) y confirmá que `npm start` corre dentro del contenedor y responde en `localhost:3000`.

**🔴 Muy difícil (25–30)**

25. **Diagnóstico integrado:** te entrego un repo donde `npm start` arranca pero la tarjeta muestra el precio como `undefined`. El bug está entre `App.js` y `RaffleCard.js` (pista: un campo renombrado a medias entre español e inglés). Reproducilo, localizá la capa (¿datos mal formados o componente mal escrito?) y escribí un post-mortem de cinco puntos (síntoma, reproducción, causa raíz, fix, prevención).
26. **Diagnóstico de arquitectura:** alguien "optimizó" el proyecto reemplazando `sass` por `node-sass` porque "es más rápido". En tu equipo hay Windows y Macs M2. Explicá qué se rompe, en qué máquinas, y por qué la decisión fue mala. Proponé el fix y una regla de lint o CI que lo prevenga.
27. (Apple Silicon) Cambiá de la **Opción M1-A** (Colima arm64) a la **Opción M1-B** (amd64 vz-rosetta), medí la diferencia de tiempo de arranque de `npm start` y anotala. Explicá por qué amd64 es más lento y cuándo vale la pena pagar esa lentitud.
28. **Reproducción de "en mi máquina funciona":** simulá el bug clásico. Corré la app con Node 14 (anda) y con Node 20 (falla). Documentá ambos resultados, el mensaje exacto de error, y explicá la causa raíz a nivel de OpenSSL/Webpack de forma que un junior lo entienda.
29. Configurá React DevTools para resaltar re-renders (opción "Highlight updates when components render"). Abrí y cerrá el detalle varias veces y documentá qué componentes se resaltan y cuáles no. Explicá por qué solo re-renderiza `RaffleCard` y no `App`.
30. **Cierre forense:** escribí una guía de una página titulada "Cómo levantar raffles-app desde cero en las cuatro vías", pensada para el próximo dev que entre al equipo. Debe incluir Windows, Linux, Mac nativo y Mac con Colima, los tres errores más probables con su fix, y el checklist de verificación. Este es el entregable que ojalá existiera en todo proyecto legacy y nunca existe.

**🔥 Opcionales**

- 🔥 Alterná entre Colima y Docker Desktop sin romper el proyecto; documentá los pasos para apagar uno y encender el otro, y la diferencia de consumo de RAM en tu Mac.
- 🔥 Dejá `mock/db.json` con una rifa de ejemplo y levantá json-server con el servicio `mock` del `docker-compose.yml`; confirmá que `localhost:3001/raffles` responde JSON (aún sin conectarlo a la app). Anticipa la Fase 3.
- 🔥 Reescribí `RaffleCard` como **class component** con `this.state` y `this.setState` en vez de hooks. Compará ambas versiones lado a lado. Anticipa el Apéndice A5, "leer código mezclado".
- 🔥 Escribí un script `bash` que detecte la plataforma (Windows/Linux/macOS arm64/macOS amd64) y sugiera la vía de setup correcta.
- 🔥 Configurá VS Code Dev Containers para abrir el proyecto directamente dentro del contenedor Colima.

---

## 📚 8. Referencias

**Documentación oficial**

- Create React App — https://create-react-app.dev/docs/getting-started — la doc de CRA. Cubre versiones recientes; nosotros usamos **4.0.3**, así que algunas features nuevas no aplican. Útil para entender scripts y variables de entorno (`REACT_APP_`).
- React (hooks) — https://react.dev/reference/react/useState — referencia de `useState`. Cubre React ≥ 16.8, compatible con nuestra 16.14.0. **Advertencia:** los ejemplos pueden usar patrones de React 17/18; quedate con lo básico del hook.
- React (clases, legacy) — https://legacy.reactjs.org/docs/react-component.html — para cuando quieras hacer el 🔥 de reescribir `RaffleCard` como clase.
- Bootstrap 4.6 — https://getbootstrap.com/docs/4.6/getting-started/introduction/ — la versión exacta que usamos. **No** consultes la doc de Bootstrap 5: cambian clases y utilidades.
- Sass (dart-sass) — https://sass-lang.com/documentation/ — la implementación oficial que usamos vía el paquete `sass`.
- nvm (Unix) — https://github.com/nvm-sh/nvm — para Mac y Linux.
- nvm-windows — https://github.com/coreybutler/nvm-windows — proyecto distinto, para Windows.
- Colima — https://github.com/abiosoft/colima — runtime de contenedores recomendado para Apple Silicon.
- UTM — https://mac.getutm.app/ — para levantar Windows 11 en Apple Silicon cuando un incidente lo exija.

**Video / apoyo**

- Buscá en YouTube un "Create React App crash course" reciente para ver el flujo de arranque en acción; sirve para el gesto general, aunque uses una versión más nueva de CRA que la nuestra. **Advertencia:** el video casi seguro usará Node y CRA modernos — quedate con el concepto, no con las versiones.
- Para entender contenedores rápido antes de tocar Colima, cualquier "Docker in 100 seconds" o introducción corta a Docker te ubica en 5-10 minutos. **Advertencia:** verificá el título y la URL antes de compartirlo con el equipo; pueden haber cambiado.

> ⚠️ Las URLs, títulos y contenidos de arriba pueden estar desactualizados o haber cambiado desde que se escribió esta fase. Verificá siempre contra la versión que tenés instalada. Cuando un enlace cubra una versión distinta a la nuestra (React 17/18, Bootstrap 5, CRA 5), está avisado en la nota — pero confirmá vos también. No confíes en números de versión de memoria.

**Orden de lectura sugerido:** arrancá por el getting-started de CRA (10 min, solo para ubicarte) → mirá el `useState` en react.dev si los hooks te son ajenos (15 min) → si estás en Apple Silicon, la doc de Colima → volvé al código de la sección 5 y hacelo andar → recién ahí, si te pica la curiosidad, la doc de Bootstrap 4.6 para las clases que usamos en `RaffleCard`.

---

## 🚀 9. Cierre y conexión con la Fase 1

Tenés el ambiente en pie en tu plataforma —incluso resolviste la fricción de Apple Silicon, que es la que más duele—, un CRA 4 con las versiones exactas de producción, Bootstrap y Sass compilando de verdad, y un primer componente funcional con hooks que ya sabés inspeccionar en React DevTools. Más importante que el código: sabés **levantar el sistema y mirarlo por dentro**. Ese es el piso desde el que se hace mantenimiento.

Pero una tarjeta suelta no es una app. Ahora mismo tenés una sola pantalla que muestra una sola rifa hardcodeada. Un sistema de rifas real tiene un listado, un detalle, un dashboard, una pantalla de venta — y necesitás **moverte entre ellas**. Eso es routing, y es exactamente lo que construye la **Fase 1 — Estructura base + Router 5**: vas a montar React Router 5 (la versión pre-v6, con su mezcla de rutas declarativas y hooks de router), un layout con navbar de Bootstrap, y vas a ver por primera vez cómo conviven componentes de clase y funcionales en la estructura de navegación. La rifa hardcodeada sigue ahí, esperando su backend; la deuda 💸 se paga más adelante.

> **La señal de que quedó bien:** si un compañero nuevo clona el repo, corre `nvm use && npm ci && npm start`, y ve la tarjeta de la rifa en `localhost:3000` sin preguntarte nada — entonces el setup de esta fase hizo su trabajo. El mejor ambiente de desarrollo es el que se levanta sin que tengas que explicarlo.
