# 🕵️ Forense Fase 00 — "Instalé todo y no arranca"

> **Sale de:** [Fase 0 — Setup y Hola Mundo](00-setup-hola-mundo.md) ·
> **Herramientas:** la salida de `vue-cli-service` en la terminal, `node -v`,
> `npm ls` · **Recorrido:** cuatro pasos, ninguno abre un archivo `.vue`
>
> **El síntoma, en una línea:** la aplicación no compila, y el error habla de
> algo que tú no escribiste.

Es la investigación menos glamorosa del curso y la que más veces vas a repetir
en tu vida: llegas a un proyecto ajeno, corres `npm install && npm run serve`, y
la terminal escupe un muro que menciona archivos que no existen en tu código.
La lección es que **casi ninguno de esos errores es del proyecto: son del
entorno**, y el entorno se descarta en tres minutos si lo miras en el orden
correcto.

---

## 🎫 El ticket

> "Clonaste el repo del Mini Jira como te dije y no te arranca. A mí me
> funciona perfecto, o sea que algo hiciste mal en la instalación. Mándame el
> error y lo vemos, pero seguro es tu máquina."
>
> — el compañero que te pasó el proyecto, por chat, un lunes

Dos cosas ciertas y una falsa. Cierto: a él le funciona. Cierto: es tu máquina.
Falso: que eso signifique que hiciste algo mal.

---

## 🧭 La ruta

Los pasos van **del más barato al más caro**, y en esta fase la diferencia es
brutal: el paso 1 cuesta cinco segundos y descarta la mitad de los casos; el
reflejo que casi todo el mundo tiene primero —borrar `node_modules` y
reinstalar— cuesta diez minutos y no descarta nada.

### Paso 1 — ¿qué Node estás corriendo?

Antes que nada, en la raíz del proyecto:

```bash
node -v
cat .nvmrc
```

```
v18.19.0
14.21.3
```

**Qué descarta.** Si los dos números no coinciden, para acá: `nvm use` y vuelve
a empezar. Un Node que no es el del proyecto explica los muros de `gyp ERR!` al
instalar, los binarios que no compilan y buena parte de los "comportamientos
raros del tooling" que no tienen mejor nombre. Si coinciden, el entorno de Node
queda descartado y sigues al paso 2.

> ⚠️ En Apple Silicon el `.nvmrc` del curso puede decir `16.20.2` en vez de
> `14.21.3`, y está bien: la Fase 0 lo explica. Lo que importa es que
> `node -v` diga lo mismo que el archivo.

### Paso 2 — ¿el error habla de compilar plantillas?

Lee la **primera** línea del muro, no la última. Si aparece la palabra
`compiler`, el diagnóstico está a un comando:

```bash
npm ls vue vue-template-compiler
```

```
mini-jira@0.1.0 /Users/…/mini-jira
├── vue@2.6.14
└── vue-template-compiler@2.6.12
```

Y el error que lo delata, tal como sale:

```
Vue packages version mismatch:

- vue@2.6.14
- vue-template-compiler@2.6.12

This may cause things to work incorrectly. Make sure to use the same version
for both.
```

**Qué descarta.** Si los dos números no son idénticos —no "compatibles":
**idénticos**—, ése es tu bug y se arregla igualando las versiones y
reinstalando. Fíjate en el detalle que hace que esto pase: el error dice
*"esto puede hacer que las cosas funcionen incorrectamente"*, no *"esto está
roto"*, así que a veces compila igual y te muerde tres fases después. Si las
versiones coinciden, sigues al paso 3.

### Paso 3 — ¿es un puerto, y no un error?

Si el muro trae `EADDRINUSE`, no es un problema de dependencias:

```
Error: listen EADDRINUSE: address already in use :::8888
```

```bash
lsof -i :8888        # macOS / Linux
netstat -ano | findstr :8888   # Windows
```

**Qué descarta.** Descarta el proyecto entero. Es un proceso vivo de otra
terminal —el Stubby de la Fase 0 es el sospechoso habitual, y en la Fase 3 lo
será json-server en el 3000— que sigue escuchando porque cerraste la ventana en
vez de hacer `Ctrl+C`. Mátalo y vuelve a arrancar. Si el puerto está libre,
sigues al paso 4.

### Paso 4 — ¿compila y el problema está en el editor?

Éste es el caso que más tiempo hace perder, porque no es un error: el proyecto
arranca, pero el archivo "baila" al guardar, o el `.vue` se ve sin colores, o
aparecen subrayados rojos que `npm run serve` no reporta.

```bash
code --list-extensions | grep -i "vetur\|volar\|prettier"
```

```
esbenp.prettier-vscode
octref.vetur
Vue.volar
```

**Qué descarta.** Descarta el código: lo que ves es el editor discutiendo
consigo mismo. Volar es de **Vue 3** y con Vetur se sabotean mutuamente; y si
además Prettier y el formateador de Vetur compiten por el mismo tipo de
archivo, cada guardado te deja un diff distinto. Un solo formateador por tipo
de archivo, y Volar desinstalado mientras estés en Vue 2.

---

## 🩺 Diagnóstico por síntoma

| Lo que dice la terminal (o el editor) | Dónde está de verdad |
|---|---|
| `Vue packages version mismatch` | `package.json` — `vue` y `vue-template-compiler` desalineados |
| Muros de `gyp ERR!` al instalar | Node equivocado: falta `nvm use` |
| `EADDRINUSE :::8888` | Un mock zombi de otra terminal |
| `EADDRINUSE :::8080` | Otro `npm run serve` vivo, casi siempre en otra pestaña del IDE |
| `command not found: vue-cli-service` | No corriste `npm install`, o lo corriste con otro Node |
| El `.vue` no tiene resaltado de sintaxis | Falta Vetur, o Volar lo está peleando |
| El archivo cambia solo al guardar, siempre distinto | Dos formateadores compitiendo |
| "En mi IDE no funciona, en la terminal sí" | WebStorm apuntando a otro Node interpreter |
| El formulario del Hello World no responde y la consola pide el mock | Stubby apagado — no es un bug del código |

---

## ⚰️ Los callejones

**"Borro `node_modules` y reinstalo."** Es el reflejo universal y el peor uso
posible de diez minutos: si el problema es el Node equivocado, reinstalar con
el mismo Node equivocado reproduce el problema idéntico, y ahora además no
sabes si cambió algo. Reinstalar es la **consecuencia** de un diagnóstico
(cambiaste de Node, igualaste versiones), nunca el diagnóstico.

**"Voy a actualizar las dependencias, seguro es que están viejas."** Están
viejas **a propósito**: la tabla de versiones de la Fase 0 es el terreno del
curso. Actualizar `vue` a la 2.7 para "ver si se arregla" te cambia el problema
por otro que ya no está documentado en ninguna parte.

**"Es Windows."** A veces sí, pero casi nunca por lo que crees. El caso real es
otro: la sintaxis `CHAOS=… npm run mock` de la Fase 3 no existe en `cmd` ni en
PowerShell, y eso no es un bug del proyecto sino una diferencia de shell.

---

## 🧨 Deshacer

El paso 2 invita a romper a propósito, y conviene hacerlo hoy (es el ejercicio
4 de la fase). Para volver:

```bash
npm install vue@2.6.14 vue-template-compiler@2.6.14 --save-exact
npm run serve
```

Si además tocaste el `.nvmrc`, restáuralo con `git checkout -- .nvmrc`.

---

## 🧠 El patrón transferible

Un error críptico **nombra el síntoma, no la causa**, y casi siempre lo nombra
en el vocabulario de la herramienta que se rompió —no en el tuyo. Por eso el
orden de esta pieza no es "de lo más probable a lo menos probable", sino
**del entorno hacia adentro**: versión de runtime, versiones de paquetes,
puertos, editor. Todo eso se descarta sin leer una línea de código de la
aplicación, y cuando no lo descartas primero terminas depurando tu componente
porque el editor tenía dos formateadores.

La versión corta, para llevar: *"a mí me funciona" es la descripción de una
diferencia, y encontrarla es el trabajo.*

**Sigue por acá:** el resumen de esta ruta vive en la sección 6 de la
[Fase 0](00-setup-hola-mundo.md); el índice de síntomas de todo el curso, en
[`forense-master.md`](forense-master.md); y el caso completo, en el
[incidente 01](cuaderno-incidentes.md) del cuaderno.
