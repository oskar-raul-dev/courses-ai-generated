# 🔍 Apéndice A13 — Depurar el build de producción

> Tutorial React 16 — Rifas y chances · Apéndice de **consulta rápida** · **~3 horas**
> Lo usan: el track forense desde la Fase 3 · Prioridad: 🔴 Alta
> Requiere: la app corriendo (Fase 0) y el mock de la Fase 3.

Hasta acá todo el curso depuró en **desarrollo**: `npm start`, hot reload,
nombres de variable intactos, React DevTools mostrándote el árbol con los
nombres que escribiste. Cómodo, y a la vez engañoso — porque el bug que te van a
reportar no ocurrió ahí.

Ocurrió en un bundle minificado, servido desde un dominio distinto, con
variables de entorno distintas, y el stack trace que te llega dice
`t.value is not a function` en `main.8f3a2b1c.js:2:14853`. Este apéndice es
sobre eso: **cómo se depura lo que ya no se parece a tu código.**

> 📝 **Por qué existe este apéndice.** Dos de los ocho objetivos pedagógicos que
> declara `00-alcance-del-proyecto.md` §3 —«depurar código productivo, incluso
> minificado, con source maps» y «comparar ambientes y explicar por qué algo
> funciona en UAT pero no en PROD»— no tenían contenido en ninguna fase: el curso
> nunca llegaba a correr `npm run build`. Este archivo cubre ese hueco.

---

## 🧭 Índice de salto rápido

1. [Qué le pasa a tu código cuando se construye](#1-qué-le-pasa-a-tu-código-cuando-se-construye)
2. [Correr el build y servirlo](#2-correr-el-build-y-servirlo)
3. [Source maps: qué son y qué exponen](#3-source-maps-qué-son-y-qué-exponen)
4. [Depurar un stack trace minificado, paso a paso](#4-depurar-un-stack-trace-minificado-paso-a-paso)
5. [Los tres ambientes y en qué se diferencian de verdad](#5-los-tres-ambientes-y-en-qué-se-diferencian-de-verdad)
6. [«Funciona en UAT pero no en PROD»: el árbol de diagnóstico](#6-funciona-en-uat-pero-no-en-prod-el-árbol-de-diagnóstico)
7. [Lo que solo se rompe en el build](#7-lo-que-solo-se-rompe-en-el-build)
8. [🧩 Cuándo usar qué](#-cuándo-usar-qué)
9. [🧪 Ejercicios](#-ejercicios-9)

---

## 1. Qué le pasa a tu código cuando se construye

`npm run build` no es «lo mismo pero comprimido». Webpack le hace a tu código
cuatro cosas, y cada una rompe una suposición distinta que tenías al depurar:

**Minifica.** Los nombres locales desaparecen: `raffleId` pasa a ser `t`,
`toReadableError` a `n`. Los nombres de módulos y de propiedades de objeto
sobreviven —por eso `state.raffles.items` sigue reconocible—, pero todo lo local
se pierde. Esto es lo que convierte un stack trace en jeroglífico.

**Concatena.** Tus doscientos archivos se vuelven dos o tres. Un error que en
desarrollo decía `saleSlice.js:47` ahora dice `main.8f3a2b1c.js:2:14853`, donde
la línea 2 tiene medio megabyte.

**Elimina el código de desarrollo.** `process.env.NODE_ENV === 'production'`
hace que React quite sus warnings, sus validaciones de `propTypes` y sus mensajes
de error legibles — que pasan a ser códigos numéricos con un enlace. Esta es la
razón número uno de que un bug «solo aparezca en producción»: **en desarrollo
React te avisaba y en producción se calla.**

**Hornea las variables de entorno.** Todo lo que empiece con `REACT_APP_` se
sustituye por su valor literal **en el momento del build**. No se lee en runtime.
Un build hecho apuntando a UAT sigue apuntando a UAT aunque lo subas a
producción, y ese es el §6 entero.

> 🧠 **La consecuencia que hay que interiorizar.** El artefacto que corre en
> producción **no es tu código**: es una traducción suya. Depurarlo sin source
> maps es como depurar la traducción sin ver el original — se puede, pero
> adivinas. Todo lo demás en este apéndice sale de ahí.

---

## 2. Correr el build y servirlo

```bash
npm run build
```

Te deja `build/` con el HTML, los assets y `build/static/js/main.<hash>.js`.
Mira el tamaño y el hash: **el hash es el contenido**. Dos builds del mismo
código dan el mismo hash; si cambia el hash, cambió algo. Es el primer dato que
pides cuando alguien reporta un bug de producción: *¿qué hash tiene el bundle que
estás viendo?*

Servirlo es el paso que casi nadie da y que descubre bugs propios:

```bash
npx serve -s build -l 5000
```

El `-s` importa: le dice a `serve` que redirija cualquier ruta desconocida a
`index.html`. **Sin ese flag, recargar en `/raffles/1` da 404** — y ese es el bug
de deploy que la Fase 1 anticipa en su ejercicio 26. Acá es donde se ve de
verdad: en `npm start` el dev server hace ese fallback solo, y por eso el
problema no existe hasta que despliegas.

> ⚠️ **El build no habla con tu mock.** `apiClient` apunta a `localhost:3001`;
> si construiste sin `REACT_APP_API_URL`, el bundle tiene esa URL horneada.
> Levanta el mock (`npm run mock:all`) antes de probar el build, o vas a
> diagnosticar como bug de build lo que es un servidor apagado — que es, con
> diferencia, la media hora más tonta que se pierde en este oficio.

---

## 3. Source maps: qué son y qué exponen

Un source map es un archivo (`main.<hash>.js.map`) que dice, para cada posición
del bundle, de qué archivo y línea de tu código venía. El navegador lo carga si
lo encuentra, y a partir de ahí las DevTools te muestran **tu código original**
en el panel Sources, con tus nombres y tus breakpoints funcionando.

CRA 4 los genera por defecto en el build, y se controlan con una variable:

```bash
# Build de producción SIN source maps: no expones tu código fuente.
GENERATE_SOURCEMAP=false npm run build
```

Y acá está el compromiso que hay que entender, porque es una decisión real que
todo equipo toma y casi ninguno documenta:

**Con source maps públicos**, cualquiera que abra DevTools en tu sitio lee tu
código fuente completo, con comentarios incluidos. No es una brecha de seguridad
por sí misma —el bundle ya es público, y un secreto en el frontend ya estaba
expuesto con o sin map—, pero sí regala tu lógica de negocio y tus comentarios
internos a quien quiera leerlos.

**Sin source maps**, tu código está protegido y **tú también estás ciego**: el
stack trace de un error real de un usuario es ilegible.

La salida intermedia, que es lo que hace la mayoría de los equipos serios:
**genera los source maps, no los publiques**. Se suben a la herramienta de
monitoreo de errores (Sentry y similares), que los usa para des-minificar los
stack traces del lado del servidor, y se borran del directorio público antes de
desplegar.

> 🧭 **La regla para este proyecto.** En desarrollo y UAT, source maps activados
> y servidos: la depurabilidad vale más que la exposición en un ambiente interno.
> En producción, generados y **no** publicados. Si tu equipo no tiene herramienta
> de monitoreo todavía, la decisión honesta es dejarlos públicos y saberlo,
> antes que quedarse ciego y no saberlo. 💸

---

## 4. Depurar un stack trace minificado, paso a paso

Te llega esto en un reporte:

```
TypeError: Cannot read property 'number' of undefined
    at t (main.8f3a2b1c.js:2:14853)
    at Object.n [as sell] (main.8f3a2b1c.js:2:9271)
```

El procedimiento, de más barato a más caro:

**Uno: confirma el hash.** ¿`8f3a2b1c` es el build que está desplegado ahora?
Si el usuario tenía la pestaña abierta desde ayer, puede estar corriendo un
bundle viejo y estás persiguiendo un bug ya arreglado. Un `Ctrl+Shift+R` del
reportante resuelve más incidentes de los que parece.

**Dos: reproduce contra el build local.** `npm run build && npx serve -s build`.
Si el bug aparece, tienes el ciclo completo en tu máquina y el resto es
mecánico. Si **no** aparece, ya sabes algo enorme: la diferencia no está en el
código, está en el ambiente (§6).

**Tres: abre el map en Sources.** Con `GENERATE_SOURCEMAP` activo, las DevTools
resuelven solo: pegas la posición `2:14853` en el panel Sources y te lleva a
`saleSlice.js:47`, con tu variable llamándose `raffleId` otra vez. A partir de
ahí depuras como siempre: breakpoint, watch, step.

**Cuatro, si no hay map: el bundle crudo.** Abre `main.<hash>.js` en DevTools y
usa el botón `{}` («Pretty print») abajo a la izquierda. No te devuelve los
nombres, pero sí la estructura, y con la posición del stack llegas a la función
culpable. Buscar por strings que sobrevivieron a la minificación es la técnica
que salva acá: los **textos de interfaz en español y las claves de objeto** no se
minifican. Buscar `"Ese número ya fue vendido"` dentro del bundle te deja parado
justo al lado del código que quieres leer.

> 💡 **Ese último truco es la razón práctica de una convención del curso.** Los
> textos de interfaz van en español y las claves en inglés (guía §4). En un
> bundle minificado eso te da dos alfabetos de anclas para buscar, y ninguno se
> minifica. No fue el motivo de la regla, pero es un beneficio real.

---

## 5. Los tres ambientes y en qué se diferencian de verdad

«Ambiente» suena a servidor, y ahí empieza la confusión. Para un frontend, un
ambiente se define por **cinco variables**, y casi ningún bug de «funciona en X
pero no en Y» está en la que primero se mira:

**El código.** ¿Es el mismo commit? Se verifica con el hash del bundle. Es lo
primero que se descarta y lo que más veces resulta ser la causa.

**Las variables de entorno horneadas.** `REACT_APP_API_URL` y compañía, fijadas
en el momento del build. Un mismo commit construido dos veces con `.env`
distintos produce dos aplicaciones distintas.

**El backend contra el que corre.** Distinta versión de la API, distintos datos,
distinta latencia. El frontend puede ser idéntico y el comportamiento no serlo.

**El servidor que sirve los estáticos.** Configuración de fallback a
`index.html`, cabeceras de caché, compresión, HTTPS. El bug de recarga en
`/raffles/1` vive exactamente acá.

**El navegador y la máquina del usuario.** Versión, extensiones, zona horaria,
reloj. La zona horaria es la que más caro sale en este dominio: toda la Fase 7
depende del reloj del cliente, y esa deuda está anotada en el A12.

En este curso los ambientes se simulan así, y con eso alcanza para entrenar el
ojo: **desarrollo** es `npm start` con `CHAOS_LEVEL=off`; **UAT** es el build
servido con `serve` contra el mock con `CHAOS_LEVEL=low`; **producción** es el
mismo build con `CHAOS_LEVEL=high` y source maps desactivados. Tres
configuraciones del mismo repositorio, que es exactamente la relación que tienen
en la vida real.

---

## 6. «Funciona en UAT pero no en PROD»: el árbol de diagnóstico

Es el reporte más frustrante que existe, porque el reportante te está dando una
conclusión («es PROD») en vez de una observación. El árbol para desarmarlo, en
orden estricto — cada paso descarta una de las cinco variables de §5:

**1. ¿Es el mismo código?** Compara el hash del bundle en los dos ambientes. Si
difieren, terminaste: no es un bug de ambiente, es un despliegue desactualizado.
Sorprende cuántas veces es esto.

**2. ¿Es la misma configuración?** Abre la consola en ambos y mira a dónde
apuntan las peticiones en Network. Un `REACT_APP_API_URL` mal horneado hace que
PROD hable con el backend de UAT, o al revés — y el síntoma puede ser
cualquiera, incluido «a veces trae datos raros».

**3. ¿Es el mismo backend, respondiendo lo mismo?** Con Network abierto en los
dos, compara **la misma petición**: código de estado, cuerpo, cabeceras. Si el
cuerpo difiere en forma —no en datos—, encontraste la causa y no está en el
frontend.

**4. ¿Es el modo de build?** Este es el paso que casi nadie da y el que explica
los bugs más raros. Si UAT corre `npm start` (modo desarrollo) y PROD corre el
build, **no estás comparando ambientes: estás comparando dos versiones de
React**. La de desarrollo valida props, avisa de estados imposibles y te grita
en consola; la de producción hace nada de eso. Un componente que en desarrollo
mostraba un warning rojo y funcionaba «igual» puede romperse de verdad en
producción. Ver §7.

**5. ¿Es el servidor o el cliente?** Recarga profunda en una ruta anidada
(fallback), revisa cabeceras de caché (¿estás viendo un bundle viejo cacheado?),
y pregunta zona horaria y hora del sistema al reportante.

> 🧭 **La regla que ordena todo el árbol.** No busques el bug: **busca la
> diferencia.** «Funciona acá y no allá» es, por definición, un problema de
> diferencia, y solo hay cinco candidatas. Descártalas en orden y la causa cae
> sola. Empezar por leer el código —que es el instinto— es empezar por la
> variable que el paso 1 suele descartar en treinta segundos.

---

## 7. Lo que solo se rompe en el build

Cuatro familias, todas con la misma firma: en desarrollo pasan desapercibidas.

**Lo que React solo valida en desarrollo.** Warnings de `key` faltante, de
`propTypes`, de estado actualizado tras el desmontaje, de hooks en orden
condicional. En producción esos avisos no existen, y el síntoma pasa de «un
warning amarillo» a «la lista se reordena sola» o «la app se congela».

**Lo que depende del nombre de una función o una clase.** Cualquier código que
haga `fn.name`, `constructor.name` o compare `component.displayName` deja de
funcionar cuando la minificación renombra todo a una letra. Es raro pero
devastador, porque falla en silencio.

**Lo que depende del orden de importación de CSS.** Webpack concatena y puede
reordenar; una regla que en desarrollo ganaba por orden puede perder en el
build. Es el clásico «se ve distinto en producción» sin ningún error en consola,
y es el que menciona el A2.

**Lo que depende de una variable de entorno ausente.** `process.env.REACT_APP_X`
sin definir no es un error: es `undefined`, que se hornea literalmente. Terminas
con una petición a `undefined/raffles` y un 404 desconcertante.

> ⚠️ **Y la regla de oro que se deriva de todas.** Un warning de React en
> desarrollo **no es ruido**: es producción avisándote con anticipación y en un
> idioma que todavía entiendes. Una consola de desarrollo con veinte warnings
> amarillos es una lista de bugs de producción esperando turno. Lo que este
> apéndice te pide, más que cualquier técnica, es dejar de ignorarlos.

---

## 🧩 Cuándo usar qué

- **Un bug reportado desde producción** → §4, y empieza siempre por confirmar el
  hash del bundle.
- **«Funciona en mi máquina» entre dos ambientes** → §6, el árbol completo, en
  orden.
- **Un stack trace ilegible** → §3 para activar los maps, §4 si no los tienes.
- **La app funciona en `npm start` y falla construida** → §7, y sospecha primero
  de un warning de desarrollo que venías ignorando.
- **Recargar una ruta anidada da 404** → §2, el fallback a `index.html`. Es
  configuración de servidor, no código.
- **Decidir si publicar los source maps** → §3, y déjalo escrito en algún lado.

---

## 🧪 Ejercicios (9)

1. **🟢** Corre `npm run build`. Anota el tamaño de `main.<hash>.js` y el hash.
   Vuelve a construir sin cambiar nada y confirma que el hash **no** cambió.
   Cambia una línea, reconstruye y confirma que sí cambió.
2. **🟢** Sirve el build con `npx serve -s build`. Navega a `/raffles/1` y
   recarga. Ahora sírvelo **sin** el flag `-s` y recarga otra vez. Documenta la
   diferencia y explica por qué `npm start` no tenía este problema.
3. **🟢** Abre el bundle en DevTools → Sources, dale a «Pretty print» y busca el
   texto `"Ese número ya fue vendido"`. Anota qué código hay alrededor y cuánto
   tardaste en encontrarlo.
4. **🟡** Construye con `GENERATE_SOURCEMAP=false` y compara el contenido de
   `build/static/js/` con el build normal. Provoca un error en la app servida y
   compara el stack trace de los dos builds, lado a lado.
5. **🟡** Define `REACT_APP_API_URL` en un `.env`, construye, y **busca la URL
   literal dentro del bundle** con `grep`. Explica en dos líneas por qué esto
   descalifica a `REACT_APP_` como lugar para guardar un secreto.
6. **🟠 Diagnóstico.** Provoca a propósito un bug que solo aparezca en el build:
   quita una `key` de una lista renderizada con `.map()`. Confirma el warning en
   desarrollo, construye, y verifica que en producción el warning desaparece.
   Después encuentra un caso de reordenamiento donde la ausencia de `key`
   produzca un comportamiento **visiblemente** incorrecto.
7. **🟠** Simula los tres ambientes de §5 al mismo tiempo: `npm start` en el
   3000, el build servido en el 5000 contra `CHAOS_LEVEL=low`, y otro build
   contra `CHAOS_LEVEL=high`. Documenta tres diferencias observables de
   comportamiento entre ellos, con evidencia de Network o consola.
8. **🔴 Diagnóstico integrado.** Te llega este ticket: *«desde ayer, algunos
   usuarios ven la lista de rifas vacía, pero a otros les funciona. En UAT no
   pasa.»* Aplica el árbol de §6 completo: escribe qué preguntas haces, en qué
   orden, qué evidencia pides en cada paso, y qué causa descarta cada respuesta.
   El entregable es el árbol de decisión, no una respuesta.
9. **🔴** Escribe el documento de una página «Cómo depurar un bug de producción
   en raffles-app» para el próximo que entre al equipo: cómo obtener el hash,
   dónde están los source maps, cómo levantar el build local, el árbol de §6
   resumido, y la política de source maps del proyecto. Es el artefacto que
   convierte este apéndice en algo que el equipo usa en vez de leer.

**🔥 Opcionales**

- 🔥 Integra una herramienta de monitoreo de errores en modo local, sube los
  source maps y confirma que des-minifica un stack trace real. Es el flujo
  completo que §3 describe pero no ejecuta.
- 🔥 Escribe un script que compare dos builds (hashes, tamaños y variables
  `REACT_APP_` horneadas) e imprima las diferencias. Es el paso 1 y 2 de §6
  automatizados.

---

## 📚 Referencias

**Documentación oficial**

- CRA — variables de entorno:
  https://create-react-app.dev/docs/adding-custom-environment-variables/ — el
  horneado en build-time y por qué el prefijo `REACT_APP_`.
- CRA — despliegue:
  https://create-react-app.dev/docs/deployment/ — el fallback a `index.html` por
  tipo de servidor. La doc cubre CRA 5; para esto no cambia nada respecto a la
  4.0.3.
- Chrome DevTools — mapear código minificado:
  https://developer.chrome.com/docs/devtools/javascript/source-maps/ — el panel
  Sources y la carga de maps.
- React — errores en producción:
  https://react.dev/errors — el descodificador de los códigos numéricos que React
  emite en el build en vez del mensaje completo. Guárdalo en marcadores.

**Del curso**
- `A4-cra-por-dentro.md` §3 y §7 — variables de entorno y la configuración de
  `GENERATE_SOURCEMAP`. Este apéndice es el uso forense de lo que aquel explica.
- `A9-entornos-y-contenedores.md` — cuando la diferencia entre ambientes es el
  sistema operativo y no la configuración.

**Orden de lectura sugerido:** §1 (qué le pasa a tu código) → §2, construyendo
de verdad mientras lees → §4 con un error provocado por ti → §6 el día que
llegue el primer ticket de producción.

> ⚠️ Las URLs de CRA y de Chrome DevTools cambian de estructura cada tanto, y la
> doc de CRA cubre la versión 5. Verifica al abrirlas; el comportamiento descrito
> acá corresponde a `react-scripts` 4.0.3, que es el que fija el proyecto.

---

## 🚀 Y ahora, de vuelta al código

Este apéndice no tiene fase propia: se usa desde el track forense de cualquier
fase, en cuanto un bug deje de reproducirse en desarrollo. Los incidentes **07**
(«a veces no carga y no dice nada») y **20** («el test pasa en mi máquina y falla
en la de al lado») del `cuaderno-incidentes.md` son los que más directamente
piden lo de acá.

> **La señal de que quedó bien:** cuando te llegue un stack trace minificado y no
> sientas que te falta información, sino que te falta **ejecutar el
> procedimiento** — hash, build local, source map, árbol de diferencias. En ese
> orden, y sin abrir el código hasta el tercer paso.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es material de consulta: si no
> cambia el repo, no hay nada que apuntar. Cuando de leerlo sí salga código
> —un script de análisis de bundle, un `.env` de UAT—, commitéalo con el prefijo de la
> fase desde la que llegaste (`f06: …`), no con el del apéndice, para que el
> `git log --oneline --grep '^f06'` de esa fase siga estando completo. Y si el
> ejercicio produjo una medición, el número va en el mensaje del tag
> (`ej/a13/3`), que es donde no se pierde. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
