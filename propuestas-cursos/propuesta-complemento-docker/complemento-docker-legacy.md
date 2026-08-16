# ☕ Complemento geek para `docker-container-legacy` — la conversación del café

> **Qué es esto:** una discusión de trabajo, no un plan aprobado. Retoma
> [`nuevas-ideas.md`](../nuevas-ideas.md) §7, que ya auditó los trece documentos de esta
> carpeta contra las 36 fases y 16 apéndices del curso, y le añade las dos cosas que esa
> auditoría no cubría: **compilar Node *actual*** y **la VM Linux "todo desde fuente"**.
> **Fecha:** 10 de septiembre de 2026
> **Estado:** documento de trabajo, sin versionar, igual que sus vecinos.
> **Si vienes a hacer algo y no a leer:** §9 — el protocolo de laboratorio para las cuatro
> corridas de compilación con las que se escribirá el `a17`.
> **Lo que no se re-litiga:** el veredicto de §7.1 —doce documentos ya cubiertos, uno con
> hueco real— y la regla de §7.2: *el material entra reescrito y ejecutado, o no entra*.

---

## 0. ✅ Lo que ya se ejecutó sobre el curso (10 de septiembre de 2026)

Tres huecos menores que salieron al revisar si `glibc`/`musl` estaba cubierto —lo está, y en
tres capas: la decisión en [F01](../docker-container-legacy/01-decisiones-debian-zonas-node.md) §4.2, el mecanismo en
[F14](../docker-container-legacy/14-abi-libc-y-prebuilds.md) §6 y §6.1, y el refuerzo en F32 §7.5, el glosario y el boss fight de
F14—. No hacía falta apéndice nuevo; hacía falta completar lo escrito:

- **F14 §6** — añadido el porqué específico del legacy: las versiones de `node-pre-gyp` y
  `prebuild-install` de 2018 son anteriores a la detección de libc, así que **no caen a
  compilar: descargan el binario de glibc, el `npm install` termina en verde y el fallo se muda
  al `require()`**. Más la trampa de que la Alpine que te serviría (≤3.12, la última con
  Python 2) también está sin parches, y una línea sobre las *unofficial builds* de Node para
  musl, que antes no se mencionaban en ninguna parte del curso.
- **a09 §1.1** — **PhantomJS**, que no aparecía en las 36 fases ni en los 16 apéndices pese a
  ser el runner de la época de Karma. Entra como caso D de F14 §4.4, con la migración a
  `ChromeHeadless` y la advertencia de que cambiar de navegador cambia los resultados.
- **a09 — guía rápida y §7** — la fila y el síntoma correspondientes, para que se encuentre
  desde el error literal y no solo leyendo el apéndice entero.

Sin ejercicios nuevos: los que existen ya cubren el terreno —F14 ej. 11, 12 y el 💀 28 sobre
Alpine— y `check-course.sh` sigue pasando 12 de 13 (el fallo restante es previo y ajeno: el
enlace muerto a `mejoras_v2.md` desde `ajuste_estructura.md`, que está deprecado).

Y en una segunda pasada, los dos pendientes que este documento había dejado abiertos:

- **a13 §4 — el proxy corporativo** (§2 de aquí). Entra como el escalón anterior al air-gap, con
  el detalle que hace que el arreglo a medias parezca no funcionar: **son dos almacenes de
  certificados, el del sistema y el de Node**, y tocar solo el primero deja `npm install`
  fallando igual — que es como se acaba en el anti-patrón de `strict-ssl false` que F31 §7.6 ya
  condenaba sin dar la alternativa. Más el proxy en `ARG` y no en `ENV`, y por qué. Con punteros
  desde F31 §7.5 y §7.6 y desde F03 §10, para que se llegue desde el error literal.
- **F22 §5.1 — el dato de macOS 27** (§8.3 de aquí). La advertencia de "está por ver" pasa a ser
  una tabla de dos filas con los dos componentes yendo a sitios distintos, el hecho documentado
  de la integración en macOS 27, las tres cautelas honestas —Apple no promete permanencia, los
  runtimes tienen que ponerse al día, y la comprobación que le toca al lector tras cada
  actualización— y la consecuencia dicha claro: **el baseline `linux/amd64` no tiene fecha de
  caducidad anunciada en Mac.** Se actualizó también la URL de la fuente, la cabecera con su
  fecha de revisión de documentación externa y el resumen de cierre de la fase.

De paso quedó arreglado el único fallo que arrastraba `check-course.sh`: el enlace muerto a
`mejoras_v2.md` desde `ajuste_estructura.md`, que ya no está en el árbol. **El curso pasa ahora
13 de 13.**

**Lo que NO se escribió, y a propósito:** el `a17`. Ese apéndice necesita una sesión con la VM
abierta —qué plantilla, qué falla, cuántos minutos, cuánta RAM— y el curso no publica un
documento con números inventados. La lista de lo que hay que verificar está en §7, y **el plan
de laboratorio completo —las dos VM por máquina, el guion común y la hoja de captura— en §9**,
que es la parte accionable de este documento.

---

## 1. 🧭 Dónde retomamos

La mitad de tu pregunta ya tiene respuesta escrita y sigue siendo la buena. `nuevas-ideas.md`
§7.4 propone un apéndice `a17-compilar-node-desde-fuente.md` de unas 2.000 palabras dentro del
curso, y §7.7 recomienda hacerlo ya porque es barato, cierra un hueco declarado y encaja sin
tocar la estructura. Nada de lo que he mirado hoy me hace cambiar eso.

Lo que **no** estaba en esa auditoría, y es lo que traes nuevo, son dos cosas de distinto peso:

- **Compilar Node actual, no solo el 14.** §7.8 solo pide verificar que el 14 compila. Tú lo
  planteas como comparación de eras, y eso lo cambia bastante — lo desarrollo en §4.
- **La VM Linux "todo desde fuente", LFS *u otro con mayor valor pedagógico*.** Esa segunda
  mitad de la frase es la pregunta interesante, porque §7.6 dice qué le pasa a LFS como
  contenido pero nunca llega a nombrar la alternativa. Va en §5.

Y hay una tercera que mencionas de pasada y conviene despachar primero, porque la respuesta es
que ahí no hay nada que traer.

---

## 2. 🌐 El networking: aquí gana el curso, y conviene decirlo

Repasé la carpeta buscando el material de red del que hablas y **no existe como tal**. Lo que
hay disperso en los documentos 06 y 10 son tres cosas: la advertencia de no montar
`node_modules` del host, el `--platform` para elegir arquitectura, y el Template 6 con
certificado raíz corporativo. Las dos primeras no son networking; la tercera sí, y es la única
con contenido.

Enfrentado a lo que el curso ya tiene, no hay competencia:

| Lo que la propuesta insinúa | Dónde vive ya, y con cuánto |
|---|---|
| "el contenedor no ve tu `localhost`" | [F18](../docker-container-legacy/18-networking-de-contenedores.md) entera: `0.0.0.0` contra `127.0.0.1`, qué hace `-p` de verdad, `EXPOSE` que no expone, redes de usuario, `host.docker.internal`, logs y `attach` — 3.500 palabras y 20 ejercicios |
| diferencias de red entre motores | [F24](../docker-container-legacy/24-docker-y-podman-arquitectura.md), a la que F18 §3 remite explícitamente |
| proxy corporativo y TLS | [F31](../docker-container-legacy/31-catalogo-de-fallos-i.md), a la que F18 §3 también remite |

O sea que el curso no solo lo cubre: **ya decidió dónde va cada pieza y lo dejó escrito en el
"qué NO entra" de la fase.** Eso es exactamente lo que uno quiere encontrarse.

El único hueco real que veo, y es pequeño, es que **el proxy corporativo con inspección TLS
está tratado como entrada de catálogo, no como receta.** En F31 aparece como causa de un fallo
(`ca-certificates` ausente, certificado no confiado) y como el ejercicio 9, pero no hay en
ninguna parte el "así se inyecta el CA de tu empresa en el build y así verificas que `npm`,
`apt` y `curl` lo respetan los tres". Es media página. Mi voto: **una sección nueva en
[a13](../docker-container-legacy/a13-air-gapped.md)**, que ya es el apéndice de "tu máquina no
habla con Internet como el resto del mundo", en lugar de un apéndice propio. Ahí queda al lado
de la vendorización, que es el problema hermano.

> ✅ **Hecho** — `a13` §4, §4.1, §4.2 y §4.3, con las entradas de retorno desde F31 y F03. Ver §0.

---

## 3. 🔩 El `a17`, con una corrección al plan de §7.8

El diseño de §7.4 me parece correcto entero —Lima porque el lector ya la tiene arrancada de
[a07](../docker-container-legacy/a07-colima-y-lima.md), `./configure` como material didáctico,
los fallos con mensaje literal, cerrar el bucle con las herramientas de
[a03](../docker-container-legacy/a03-binutils-y-elf.md), y el multi-stage al final— y no lo
toco. Le hago una sola enmienda, en la parte de verificación.

§7.8 deja abierto en qué VM arrancar y menciona `bullseye` o una VM `debian/eol:buster` como
plan B si `bookworm` rompe. **Yo apostaría directamente por Debian 11 bullseye, y creo que el
plan B es el que hay que descartar.** El razonamiento:

- **Bookworm rompe por dos sitios a la vez**, no por uno. No empaqueta `python2.7`, que Node 14
  necesita para su `configure`; y su OpenSSL es la rama 3.x, mientras Node 14 espera 1.1.1. Con
  `--shared-openssl` eso no es un aviso, es un fallo de compilación.
- **Bullseye tiene las dos piezas en su sitio**: `python2.7` todavía empaquetado y OpenSSL
  1.1.1. Es el último Debian donde Node 14 compila sin pelear con el sistema.
- **Buster como VM es peor idea de lo que parece.** Dentro de un contenedor es perfecto —el
  curso entero lo demuestra—, pero como sistema de una VM con kernel propio y repositorios en
  el archivo, añades arqueología de distribución a un ejercicio que va de compilar Node. Dos
  problemas por el precio de uno, y solo uno de ellos es el contenido.

Las tres afirmaciones son verificables en una sesión y hay que verificarlas antes de escribir
nada — son hipótesis mías, no hechos que haya ejecutado. Pero si se confirman, **el intento
fallido en bookworm es contenido de primera**: es el ejemplo perfecto de por qué la versión de
la libc y de OpenSSL del sistema deciden qué puedes compilar, que es literalmente la tesis de
[F14](../docker-container-legacy/14-abi-libc-y-prebuilds.md) vista desde el otro lado. Yo lo
dejaría en el apéndice con su mensaje de error entero, no lo escondería.

> ⚠️ **Y una que la propuesta original tiene mal y conviene no arrastrar.** El documento 09
> vende compilar como plan de supervivencia para ARM64, y no lo es: **`node-v14.21.3-linux-arm64.tar.xz`
> existe**, está en `nodejs.org/dist`, y [F06](../docker-container-legacy/06-instalacion-node.md)
> ya lo sabe —usa `linux-x64` a propósito y explica en su §21 qué pasa si pides el que no es—.
> El que no existe es `darwin-arm64`, que es otro problema y se resuelve con el contenedor. Esto
> **refuerza** tu encuadre en vez de debilitarlo: el `a17` es un ejercicio de comprensión, no
> una vía de escape, y decirlo en la primera línea del apéndice lo hace más honesto, no menos
> atractivo.

---

## 4. 🆕 Node actual: no es un bonus, es la mitad que faltaba

Aquí es donde tu versión mejora la de §7. Compilar Node 14 solo es un ejercicio de arqueología:
sale un binario, se verifica con `readelf`, y ya. **Compilar Node 14 y Node actual en la misma
VM, con el mismo comando, es un experimento controlado** — y experimento controlado es la marca
de la casa (§1.4 de `nuevas-ideas.md`: medir en lugar de suponer).

Lo que la comparación pone sobre la mesa, sin que haya que forzarla:

- **Qué se volvió más fácil.** Desaparece Python 2 del `configure`. Desaparece la pelea con
  OpenSSL del sistema si compilas vendorizado. Los avisos del compilador se reducen a la mitad.
- **Qué se volvió más caro.** El estándar de C++ que exige V8 subió de generación, el árbol de
  fuentes es varias veces más grande, y —esto es lo que sospecho que da el mejor material— **el
  enlazado de V8 moderno tiene un pico de RAM que revienta una VM pequeña**. Un fallo de
  `virtual memory exhausted` o un OOM killer en una VM de 4 GB es un ejercicio buenísimo,
  porque el error no menciona la RAM por ninguna parte.
- **Los dos números que nadie publica**: minutos de `make -j` y pico de memoria, misma máquina,
  dos eras. Eso es exactamente lo que
  [F21 §7.4](../docker-container-legacy/21-arquitecturas-y-emulacion.md) hizo con la emulación
  —18× en CPU, 1,5× en I/O, medido— y por lo que ese apartado es de lo mejor del curso.

Y el cierre honesto se escribe solo, que es la señal de que el apéndice está bien planteado:
compilar Node 14 lo haces una vez para entender; compilar Node actual **no lo haces nunca**,
porque el binario oficial existe para tu plataforma, está firmado y lo parchean otros. El
ejercicio demuestra su propia inutilidad práctica, y eso es un final mucho mejor que "ya sabes
compilar Node".

**Cabe en el `a17` sin partirlo**, si va como su sección de cierre más dos ejercicios, y no como
una segunda mitad simétrica. Las 2.000 palabras del formato de apéndice se estiran a 2.500 o
3.000 —a03 y a07 están en ese orden— y sigue siendo una tarde de escritura sobre una tarde de
compilación.

---

## 5. 🐧 "LFS u otro con mayor valor pedagógico" — mi respuesta a la segunda mitad

La pregunta de verdad está en el "u otro", así que empiezo por ahí y dejo LFS para el final.

### 5.1 El problema de LFS no es que sea difícil, es que no tiene decisiones

`nuevas-ideas.md` §7.6 ya lo dice y suscribo cada palabra: **LFS es teclear durante veinte horas
lo que otro ya escribió, sin una sola variable que medir.** No hay trade-off, no hay dos
opciones que comparar, no hay un número que cambie según lo que elijas. Es el modo de fallo
contra el que avisa la guía del repositorio —degenerar en resumen de documentación— en su
versión más laboriosa. Y encima el libro original está mejor escrito de lo que quedaría
cualquier resumen.

Lo que sí tiene LFS, y es real, es **una idea que no está commoditizada**: un contenedor no trae
kernel, trae *el resto*; LFS construye exactamente ese resto a mano. Así que la pregunta útil no
es "¿hacemos LFS?" sino **"¿cuál es el trozo más pequeño de LFS que entrega esa idea?"**.

### 5.2 Los cuatro candidatos, medidos por lo que cuestan

| Candidato | Qué enseña que el curso no tiene | Coste real | Veredicto |
|---|---|---|---|
| **`debootstrap` + `FROM scratch`** | Que una imagen base es un `tar` de un userland, y nada más | Una tarde | 🥈 Barato y perenne, pero §3.3 ya lo reclamó para el Docker moderno |
| **El mismo Node contra musl** | Que la libc no es un detalle de empaquetado: cambia el binario, y lo ves en el ELF | Media tarde sobre el `a17` | 🥇 **El mejor ratio de los cuatro.** Es F14 con las manos |
| **Gentoo stage3 + un `USE` flag** | Que las banderas de compilación deciden contra qué enlaza el binario — el ancestro directo del `--shared-openssl` del `a17` | Una tarde larga, la VM arranca en una hora | 🥉 Elegante, pero añade una distro nueva al vocabulario del curso |
| **LFS completo** | La idea del §5.1… enterrada bajo veinte horas de transcripción | 20–40 h | ❌ Como contenido del repositorio, no |

### 5.3 Lo que yo haría: el capítulo 5, no el libro

Si tuviera que quedarme con un solo trozo de LFS, sería **la construcción del toolchain
temporal**: compilar un compilador con el compilador del sistema, y después usar ese compilador
para compilarse a sí mismo otra vez, aislado de la máquina anfitriona. Es la parte donde LFS
deja de ser transcripción y se convierte en una idea difícil de encontrar explicada en otro
sitio — **de dónde sale el compilador que compila el compilador**, y por qué hacen falta tres
pasadas y no una.

Son unas cuatro horas, no veinte. Y rima con el curso de una forma que no es casualidad: el
lema del curso es *el contenedor contiene el toolchain, no el proyecto*, y esa parte de LFS es,
literalmente, construir el toolchain. Cierra el círculo desde el otro extremo.

El resto del libro —instalar los ochenta paquetes del userland, configurar el arranque— es
exactamente lo que apt te regala, y para entender que apt te lo regala basta con haberlo hecho
una vez con **dos** paquetes, no con ochenta.

> 🧠 **El ángulo que hace publicable todo esto, y que es el de §7.5.** El contenido no es la
> construcción, es **la comparación**: "esto es lo que `debian/eol:buster` te trae hecho, y esto
> tuve que fabricarlo yo". Si el material es "hora 14 de LFS", no hay nada. Si es un inventario
> de lo que hay dentro de una imagen base y de quién lo puso ahí, hay una tesis — y encima es la
> tesis que el curso ya defiende.

### 5.4 Dónde acaba encajando

En la escalera de §7.5, que sigue pareciéndome la ordenación correcta, esto **no es un peldaño
nuevo**: es el peldaño 5 reducido de veinte horas a cuatro y con un ángulo comparativo encima.
Y §7.7 ya decidió que esa escalera no se hace ahora como curso propio, sino plegada dentro del
Docker moderno como Parte III. Sigo estando de acuerdo, con una salvedad de la que hablo en §6.

---

## 6. 📐 La forma concreta que propongo

Tres piezas, en orden de coste creciente, y solo la primera es un compromiso.

**`a17-compilar-node-desde-fuente.md` — se escribe ahora.** El diseño de §7.4 con la enmienda de
bullseye de §3 y la comparación con Node actual de §4 como sección de cierre. Formato de
apéndice: índice de salto rápido, secciones cortas, guía de "cuándo usar qué", **6 a 8
ejercicios**, no los 20–35 de una fase. Y esto último no es pereza: un ejercicio que cuesta
veinticinco minutos de `make -j` no admite veinticinco hermanos, y forzarlo produciría un
aparato de ejercicios falso. El formato de apéndice existe justamente para esto.

**`a18-que-hay-dentro-de-una-imagen-base.md` — el mapa, no el tutorial.** Aquí está mi salvedad
a §7.7. Guardar la vía geek entera para el Docker moderno es lo correcto, pero **el lector que
termina el `a17` va a hacerse la pregunta esa misma tarde**, y dejarlo sin una página que le
diga a dónde ir es dejar un bucle abierto — que es justo lo que la guía de estilo prohíbe. Lo
que propongo es barato: **un apéndice de ruta, de unas 1.500 palabras, que no compila nada.**
Inventaría qué trae `debian/eol:buster` y quién lo puso ahí, nombra la escalera de §7.5 con lo
que cuesta cada peldaño y para qué sirve, señala el capítulo del toolchain de LFS como la parte
que vale la pena, y **dice con todas las letras dónde bajarse.** Es la pieza más honesta que
puede tener el curso sobre este tema y no compromete calendario.

**El resto —`FROM scratch`, `debootstrap`, el contenedor a mano con `unshare` y `pivot_root`,
LFS— sigue donde §7.7 lo dejó**: dentro del Docker moderno, cuando le toque. No lo abro aquí.

Y una decisión de nombres que conviene tomar ahora aunque parezca trivial: **esto son apéndices
`aNN`, no un track con prefijo propio** al estilo de los `beNN` de los cursos de Angular y
React. El track existe cuando hay una secuencia de fases con su propio aparato de ejercicios, su
namespace de etiquetas y su cuaderno de incidentes. Esto son dos documentos de consulta que
nadie tiene que hacer en orden. Meterlos en un track sería prometer una estructura que no van a
sostener.

---

## 7. 🧪 Lo que hay que ejecutar antes de escribir una línea

A los tres puntos de §7.8 —que Node 14 compila y en qué VM, cuánto tarda de verdad en la máquina
de referencia con y sin `ccache`, y que el binario resultante hace `npm ci` y `build` de un
fixture del curso— le añado los que salen de este documento:

- **Que bullseye es la respuesta** y bookworm el fallo instructivo (§3). Si bullseye también
  pelea, el apéndice cambia de plan y hay que saberlo antes, no a mitad de escribir.
- **Node actual en la misma VM**: si compila, cuánto tarda, y **cuánto pico de RAM** (§4). Si mi
  sospecha del OOM en el enlazado de V8 se confirma, eso es el mejor ejercicio del apéndice; si
  no se confirma, se cae y no pasa nada.
- **El diff de los dos ELF**, el de Node 14 y el de Node actual, con las herramientas de a03. Si
  ahí no se ve nada interesante, el cierre del §4 se apoya solo en los tiempos.

Ninguna de estas es opinable y todas caben en una sesión con la VM abierta. El apéndice se
escribe **después**, con la salida pegada, que es como está escrito el resto del curso.

👉 **El plan concreto para ejecutarlo —qué VM levantar en cada máquina, el guion común y qué
capturar— está en [§9](#9--protocolo-de-laboratorio-las-dos-vm-y-qué-traer-de-vuelta).**

---

## 8. 🤔 Lo que decidiría contigo hoy

Cuatro cosas, y ninguna es urgente salvo la última:

1. **¿El `a18` entra o no?** Yo digo que sí y que es barato; también entiendo el argumento
   contrario, que es no abrir la puerta a la vía geek hasta que le toque su turno en el
   calendario. Es una decisión de disciplina, no de contenido.
2. **¿La sección de proxy corporativo (§2) se hace ya?** Es la más barata de todo el documento y
   la única que no depende de compilar nada.
3. ~~**¿F22 §5 se actualiza con el dato de macOS 27?**~~ ✅ **Hecho**, como §5.1 de la fase —
   ver §0. Con eso, **la única pieza de esta carpeta que el curso todavía le debe es el
   documento 09**, y solo cuando esté ejecutado.
4. **Qué se hace con esta carpeta después.** §8 lo dejó abierto entre archivar y borrar. Mi voto
   es **borrar en cuanto el `a17` esté escrito**, y por el argumento que ese mismo párrafo ya
   apunta: contiene afirmaciones que el curso desmintió con medición —el "Rosetta desaparece en
   macOS 28" de los documentos 02, 06 y 07, y los números de emulación heredados— y nadie relee
   la advertencia antes de copiar y pegar. La trazabilidad ya está a salvo en `nuevas-ideas.md`
   §7.2, que registra pieza por pieza qué se descartó y por qué. El documento 13, el de compra
   de hardware, es logística personal y sale de aquí con o sin decisión: no es contenido de
   curso.

> ⚖️ **Y el recordatorio de calendario, que es el que de verdad importa.** Hay 29 semanas
> comprometidas con la ruta NoSQL light y un orden de trabajo acordado que esto no encabeza. La
> vía geek es atractiva precisamente porque es divertida, y por eso es la candidata perfecta a
> convertirse en un frente que no cierra ninguno de los tres abiertos. La forma de tenerla sin
> pagarla sigue siendo la de §7.7: **una tarde de compilación, un apéndice, y el mapa de
> `a18` para el que quiera seguir solo.** El resto, cuando toque.

---

## 9. 🧰 Protocolo de laboratorio: las dos VM, y qué traer de vuelta

Esta sección existe porque el `a17` **no se puede escribir sin ejecutarlo**. El curso publica
salidas reales con fecha de verificación en la cabecera, y un apéndice con tiempos inventados
sería justo la clase de documento que el resto del curso desmiente. Así que aquí está el plan
de laboratorio: qué levantar en cada máquina, qué correr dentro, y qué capturar para que el
apéndice se escriba solo después.

### 9.1 Las cuatro corridas, y por qué son cuatro

Dos ejes: **arquitectura** —que te la dan las dos máquinas que ya tienes, sin comprar nada— y
**era de Node**.

| | macOS Apple Silicon → `arm64` | Windows 11 → `amd64` |
|---|---|---|
| **Node 14.21.3** | corrida 1 | corrida 2 |
| **Node LTS actual** | corrida 3 | corrida 4 |

> ⚠️ **Y aquí va la restricción que conviene saber antes de empezar, porque obliga a dos VM por
> máquina y no una.** La idea bonita era "misma VM, mismo comando, dos eras". No se puede, y el
> motivo es contenido: **Node 14 necesita Python 2 y OpenSSL 1.1.1, y el Node moderno necesita
> un GCC bastante más nuevo del que trae esa misma distribución.** El toolchain que compila uno
> no compila el otro. Eso no estropea la comparación: **es el hallazgo**. Lo que se mantiene
> constante es el hardware y el método, y lo que cambia —la distro— cambia porque tuvo que
> cambiar. Dilo así en el apéndice y es una sección; escóndelo y es una trampa.

Concretamente, y esto vale igual para las VM de Lima y para las distros de WSL2:

| Corrida | Distro | El motivo, en una línea |
|---|---|---|
| Node 14 | **Debian 11 bullseye** | el último Debian con `python2.7` empaquetado y OpenSSL 1.1.1 — las dos cosas que el `configure` de Node 14 espera |
| Node moderno | **Debian 12 bookworm**, o **13 trixie** si hace falta | GCC 12 y GCC 14 respectivamente; elige mirando el mínimo que declara el `BUILDING.md` de la versión que vayas a compilar |

Ese contraste entre lo que Node exige y lo que la distro empaqueta es, literalmente, el primer
párrafo del apéndice. Y las distros que **no**, porque las preguntas salen solas:

- **Alpine no**, aquí. Compilar Node contra `musl` es un experimento excelente —es el candidato
  🥇 de §5.2— pero es **otro** experimento, y meterlo en la corrida base mezclaría dos variables.
- **Ubuntu funciona**, pero añade un segundo vocabulario de empaquetado a cambio de nada: el
  curso entero es Debian, su baseline es `debian/eol:buster` y [F01](../docker-container-legacy/01-decisiones-debian-zonas-node.md) §4 ya argumenta por qué.
  Que las versiones de GCC y OpenSSL que veas mapeen sobre lo que el lector ya conoce no es
  estética, es continuidad pedagógica.
- **Arch o Fedora tampoco**: rolling o de ciclo rápido, no puedes fijar un toolchain de 2021.
- **Buster (Debian 10), el baseline del curso, es la tentación simétrica y también se descarta**,
  por lo que ya dice §3: dentro de un contenedor es perfecto, pero como sistema de trabajo mete
  arqueología de distribución —repositorios en el archivo, claves vencidas— en un ejercicio que
  va de compilar Node. Un problema a la vez.

### 9.2 macOS Apple Silicon — Lima, paso a paso

**Lima** (Apache-2.0) es la elección, y no por purismo: el curso ya la instala y la explica en
[a07](../docker-container-legacy/a07-colima-y-lima.md), así que el apéndice no añade herramienta nueva al lector. Sobre Apple Silicon
usa el framework de virtualización del propio macOS y te da una VM Linux **`arm64` nativa, sin
emulación** — que es exactamente lo que queremos medir.

#### Paso 1 — Comprueba el terreno antes de instalar nada

```bash
uname -m          # arm64  → estás en Apple Silicon, es lo que queremos
sw_vers           # ProductVersion: a partir de 13 el backend vz va fino
sysctl -n hw.ncpu hw.memsize   # núcleos y RAM del host, en bytes
```

Apunta esas tres salidas: son la fila "Host" de la hoja de captura de §9.6, y sin ellas los
minutos que midas no significan nada.

#### Paso 2 — Instala Lima

```bash
brew install lima
limactl --version
```

Si no tienes Homebrew, está en https://brew.sh. Lima no necesita nada más: no hay demonio que
arrancar ni extensión de kernel que autorizar — usa `Virtualization.framework`, que ya viene en
tu macOS.

#### Paso 3 — Mira qué plantillas trae tu versión

```bash
limactl start --list-templates
```

Cambian entre versiones de Lima, así que esto decide si el paso siguiente es una línea o un
archivo YAML.

#### Paso 4 — Configura **antes** de arrancar, que es donde se decide el experimento

Este es el paso que la gente se salta y luego repite la compilación. Los valores por defecto de
Lima son modestos —pensados para probar cosas, no para compilar V8— y arrancar primero y ajustar
después implica recrear la VM.

Cuatro parámetros, y los cuatro tienen consecuencia directa en lo que vas a medir:

| Parámetro | Qué poner | Por qué |
|---|---|---|
| `cpus` | 8 (o los que tengas) | es el `-j` de tu `make`; si difiere entre las dos VM, los minutos no se pueden comparar |
| `memory` | 12–16 GiB | el enlazado de V8 moderno es el pico, y con poco verás un OOM que no dice que es de RAM |
| `disk` | 60 GiB | el árbol de fuentes más los objetos intermedios crecen mucho más de lo que parece |
| `vmType` | `vz` | el framework de Apple, nativo. `qemu` funciona pero emula y te falsea los tiempos |

Para la VM del **Node moderno**, si hay plantilla de bookworm o trixie, es una línea:

```bash
limactl start --name=node-moderno --cpus=8 --memory=16 --disk=60 --vm-type=vz template://debian-12
limactl shell node-moderno
```

Para la de **bullseye**, que probablemente no venga de plantilla, se arranca desde la imagen
cloud oficial de Debian con un YAML propio:

```yaml
# node14-bullseye.yaml
vmType: "vz"
images:
  - location: "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-arm64.qcow2"
    arch: "aarch64"
cpus: 8
memory: "12GiB"
disk: "60GiB"
mountType: "virtiofs"
mounts:
  - location: "~/lab-node"     # aquí dejarás los logs que hay que traer de vuelta
    writable: true
```

```bash
mkdir -p ~/lab-node
limactl start --name=node14 node14-bullseye.yaml
limactl shell node14
```

⚠️ Verifica la URL contra el índice de `cloud.debian.org` antes de pegarla: las rutas bajo
`latest/` se renombran con cada point release, y un 404 ahí parece un fallo de Lima cuando no
lo es.

#### Paso 5 — Comandos que vas a usar todo el rato

```bash
limactl list                     # qué VM tienes y en qué estado
limactl shell node14             # entrar
limactl stop node14              # parar sin borrar
limactl delete node14            # borrar; recrear desde el YAML son dos minutos
```

Ese último par es tu equivalente a los snapshots: si una corrida se contamina, borras y
recreas desde el mismo YAML, y vuelves a un estado idéntico y documentado — que para un
experimento reproducible es mejor que un snapshot, porque el estado vive en un archivo de texto
que puedes publicar con el apéndice.

📖 Documentación oficial: https://lima-vm.io/docs/ · plantillas y referencia de configuración:
https://lima-vm.io/docs/config/ · imágenes cloud de Debian: https://cloud.debian.org/images/cloud/

---

### 9.3 Windows 11 — WSL2, paso a paso, sin tocar tu Ubuntu

La duda razonable es si WSL2 basta o hace falta una VM de verdad. Basta, y §9.4 explica por qué
con detalle. Lo que sigue es el montaje.

> 🧭 **Lo primero, porque es la preocupación real:** nada de esto toca la distro que ya usas.
> `wsl --import` **añade** distros; tu Ubuntu de trabajo sigue donde está, con sus archivos y su
> configuración intactos. La única pieza compartida es la memoria de la VM, y de eso avisa el
> paso 5.

#### Paso 1 — Comprueba qué tienes ya

```powershell
wsl --version        # versión de WSL, del kernel y de WSLg
wsl --status         # versión por defecto y distro por defecto
wsl -l -v            # tus distros, su versión de WSL y cuál es la default (el *)
```

Tres resultados posibles:

- **`wsl --version` responde con números** → tienes WSL moderno. Solo actualiza: `wsl --update`.
- **`wsl --version` no se reconoce pero `wsl -l -v` sí** → tienes la versión vieja integrada en
  Windows. `wsl --update` la migra al WSL del Store, que es el que queremos.
- **No se reconoce nada** → no está instalado. Paso 2.

Y en `wsl -l -v`, la columna **VERSION tiene que decir 2**. Si alguna de tus distros dice 1, no
la toques —es tu entorno de trabajo— pero asegúrate de que las nuevas nacen en 2:

```powershell
wsl --set-default-version 2
```

#### Paso 2 — Si no lo tienes, instálalo **sin distro**

```powershell
wsl --install --no-distribution
```

Ese `--no-distribution` es deliberado: el `wsl --install` a secas te instala Ubuntu, que es lo
que casi toda la documentación asume y aquí no queremos. Reinicia cuando lo pida.

Si falla, casi siempre es una de dos: la virtualización está desactivada en la UEFI/BIOS, o
faltan las características de Windows *Plataforma de máquina virtual* y *Subsistema de Windows
para Linux*. La guía oficial cubre los dos casos.

📖 Instalación: https://learn.microsoft.com/windows/wsl/install ·
comandos básicos: https://learn.microsoft.com/windows/wsl/basic-commands ·
solución de problemas: https://learn.microsoft.com/windows/wsl/troubleshooting

#### Paso 3 — Las dos Debian, importadas desde imágenes de contenedor

La Debian de la Microsoft Store **no sirve** para esto: te da el Debian vigente del día y no te
deja elegir bullseye, que es justo lo que el experimento necesita. El rootfs se saca de una
imagen de contenedor, que ya sabes manejar:

```powershell
mkdir C:\lab\wsl

# --- Debian 11 bullseye, para Node 14 ---
docker create --name tmp-bullseye debian:bullseye
docker export tmp-bullseye -o C:\lab\bullseye.tar
docker rm tmp-bullseye
wsl --import node14 C:\lab\wsl\node14 C:\lab\bullseye.tar --version 2

# --- Debian 12 bookworm, para el Node moderno ---
docker create --name tmp-bookworm debian:bookworm
docker export tmp-bookworm -o C:\lab\bookworm.tar
docker rm tmp-bookworm
wsl --import node-moderno C:\lab\wsl\moderno C:\lab\bookworm.tar --version 2

wsl -l -v      # deben aparecer las dos nuevas, y tu Ubuntu intacta con su *
```

Si no tienes Docker en el host, el mismo tar se puede bajar directamente del rootfs oficial de
Debian; la ruta está en el wiki de Debian enlazado abajo.

Para entrar en una sin cambiar tu distro por defecto:

```powershell
wsl -d node14
```

📖 Importar una distro propia: https://learn.microsoft.com/windows/wsl/use-custom-distro ·
Debian en WSL: https://wiki.debian.org/InstallingDebianOn/Microsoft/Windows/SubsystemForLinux

#### Paso 4 — Ajusta la distro recién importada

Un rootfs exportado de un contenedor entra pelado: eres `root`, no hay usuario, y no hay
`systemd`. Para este ejercicio está bien así, pero conviene dejar constancia y, si te incomoda
trabajar como root, crear tu usuario:

```bash
# dentro de wsl -d node14
apt-get update            # ← el primer aviso importante, ver abajo
apt-get install -y sudo adduser
adduser oskar && usermod -aG sudo oskar
printf '[user]\ndefault=oskar\n' >> /etc/wsl.conf
```

```powershell
wsl --terminate node14    # para que /etc/wsl.conf surta efecto
```

> ⚠️ **Y lo que va a pasar en ese `apt-get update` de bullseye.** El soporte LTS de Debian 11
> terminaba a finales de agosto de 2026, así que sus repositorios pueden haber salido ya hacia
> `archive.debian.org`. Si el update falla, el arreglo es el mismo `sed` sobre `sources.list` que
> enseña [F03](../docker-container-legacy/03-apt-y-utilidades.md) y detalla [a01](../docker-container-legacy/a01-debian-y-apt-a-fondo.md). **Captura la salida literal antes de arreglarlo**: es
> una nota al pie del apéndice que se escribe sola y que refuerza su tesis.

#### Paso 5 — Fija la memoria, que es lo único compartido

Todas las distros de WSL2 corren dentro de **una sola VM**. Eso es una ventaja para el
experimento —las dos eras comparten kernel, núcleos y memoria, o sea condiciones idénticas por
construcción, algo que con dos VM separadas tendrías que igualar a mano— pero implica que el
ajuste es global:

```ini
; %UserProfile%\.wslconfig
[wsl2]
memory=12GB
processors=8
swap=0
```

```powershell
wsl --shutdown     # obligatorio para que tome los cambios
```

> ⚠️ **Esto también afecta a tu Ubuntu de trabajo**, que es la única forma en que este montaje la
> toca. Anota qué tenías antes —o si el archivo no existía, que es lo normal— para poder
> devolverlo al terminar.

Fijar `memory` y `processors` no es opcional aquí: por defecto WSL2 asigna memoria de forma
dinámica, y eso **puede enmascarar el OOM del enlazado de V8** que queremos observar. Con los
valores fijos la corrida es tan reproducible para el lector como la de una VM tradicional — y
además puedes bajar a `memory=4GB` a propósito para **provocar** el fallo y capturarlo.

📖 Configuración avanzada y `.wslconfig`: https://learn.microsoft.com/windows/wsl/wsl-config

#### Paso 6 — Dónde viven las fuentes

```bash
cd ~          # ✅ dentro del ext4 de la distro
# NO:  cd /mnt/c/...
```

Es la trampa que más tiempo cuesta de todo el montaje. Cruzar a NTFS en cada uno de los miles de
archivos de V8 multiplica el tiempo de compilación por un factor que no te va a gustar — es lo
que [a08](../docker-container-legacy/a08-windows-y-powershell.md) §1 ya advierte para el proyecto del curso, y aquí pesa mucho más.

Y tu equivalente a los snapshots, por si una corrida se contamina:

```powershell
wsl --unregister node14
wsl --import node14 C:\lab\wsl\node14 C:\lab\bullseye.tar --version 2
```

Un minuto, y vuelves a un estado limpio y documentado.

---

### 9.4 Por qué VMware, VirtualBox, Parallels y compañía no suman aquí

Conviene argumentarlo, porque la intuición dice lo contrario: si el ejercicio se llama "casi
bare metal", suena a que una VM *de verdad* debería ser más fiel que WSL2 o que Lima. No lo es, y
el motivo es el mismo en las dos plataformas.

**Primero, deshagamos la confusión de base: WSL2 y Lima ya son máquinas virtuales.** WSL2 corre
sobre la plataforma Hyper-V, con su kernel Linux y su ext4 dentro de un VHDX —lo que era una capa
de compatibilidad, sin kernel Linux, era WSL1—. Lima levanta una VM sobre el framework de
virtualización de Apple. Ninguna de las dos es un emulador ni una traducción de llamadas al
sistema.

**Segundo: todas se apoyan en la misma virtualización por hardware.** VT-x/AMD-V en el PC, las
extensiones de virtualización del Apple Silicon en el Mac. Ni Parallels, ni VMware, ni VirtualBox
tienen una vía privilegiada al procesador que las demás no tengan. **Ninguna está "más cerca del
metal"**; lo que las diferencia es el empaquetado, la interfaz gráfica, la licencia y lo
scriptables que son.

**Y tercero, lo que decide el asunto: lo que aquí se compila es userland.** Node se construye
contra la libc y las cabeceras de la distribución, no contra el kernel. Cambiar de kernel no
cambia el binario resultante, ni los minutos, ni el pico de memoria de forma apreciable. El único
eje en el que estas herramientas se diferencian de verdad —de quién es el kernel— es justo el que
no interviene en la medición.

Pieza a pieza, y sin adornos:

| Opción | Licencia | Qué aportaría | Qué cuesta |
|---|---|---|---|
| **VirtualBox** (Windows) | GPL ✅ | el kernel de la distro, y un instalador completo | **se pelea con Hyper-V**: desactivarlo te deja sin WSL2 **y sin Docker Desktop** |
| **VMware Workstation Pro** (Windows) | propietario, gratis para uso personal | nada que WSL2 no dé | licencia propietaria; y conviviendo con Hyper-V rinde peor |
| **Parallels Desktop** (macOS) | propietario, de suscripción | excelente para escritorios Linux o Windows | pagas por una GUI que un Debian headless no usa; y por debajo es la misma virtualización que Lima |
| **VMware Fusion** (macOS) | propietario, gratis para uso personal | lo mismo que Parallels, sin la suscripción | propietario, y nada que Lima no dé |
| **VirtualBox en Apple Silicon** | GPL ✅ | — | el soporte ARM lleva años en calidad de vista previa; no es una opción seria para un invitado `arm64` |
| **UTM** (macOS) | Apache-2.0 ✅ | la opción open source con ventana, sobre QEMU o el framework de Apple | más clics y menos guionizable que Lima |

Ese último renglón encierra el criterio que de verdad decide: **el apéndice tiene que ser
reproducible desde un archivo de texto.** Lima se describe entera en un YAML y WSL2 en cuatro
comandos de PowerShell; el lector copia, pega y obtiene tu misma máquina. Una secuencia de
capturas de pantalla de un instalador gráfico no se puede publicar como procedimiento, y el
curso mide precisamente por eso.

> ⚖️ **Cuándo sí levantaría una VM completa, para que quede dicho y no suene a dogma.** Cuando la
> lección sea **otra**: particionar un disco, instalar un bootloader, compilar un kernel,
> cacharrear con módulos, o medir algo que dependa de la configuración del kernel. Ahí el
> instalador y el kernel propio **son** el contenido, y WSL2 se queda corto de verdad. Eso es el
> peldaño 5 de §5, no el `a17`.

---

### 9.5 El guion, idéntico en las cuatro corridas

Lo importante es que **sea el mismo en los cuatro sitios**, porque si no, no hay comparación.

```bash
# 1. toolchain
sudo apt-get update
sudo apt-get install -y build-essential curl ca-certificates git ccache pkg-config
sudo apt-get install -y python2.7    # SOLO en la VM de Node 14 (bullseye)

# 2. deja constancia de con qué compilas, ANTES de compilar
gcc --version | head -1;  ldd --version | head -1
python2 --version 2>&1 || python3 --version
openssl version;  nproc;  free -h | head -2

# 3. fuentes
NODE_VERSION=14.21.3        # o la LTS actual en la otra VM
cd ~ && curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.xz" | tar -xJ
cd "node-v${NODE_VERSION}"

# 4. configure — las mismas banderas en las cuatro
./configure --prefix="$HOME/opt/node-${NODE_VERSION}" --with-intl=small-icu 2>&1 | tee ~/configure.log

# 5. primera pasada, cronometrada y con pico de memoria
/usr/bin/time -v make -j"$(nproc)" 2>&1 | tee ~/make-1.log

# 6. segunda pasada con ccache, para el número que de verdad importa
make clean
/usr/bin/time -v make -j"$(nproc)" CC="ccache gcc" CXX="ccache g++" 2>&1 | tee ~/make-2.log

# 7. instalar y verificar
make install
"$HOME/opt/node-${NODE_VERSION}/bin/node" --version
file "$HOME/opt/node-${NODE_VERSION}/bin/node"
```

Dos notas sobre el guion. **`--with-intl=small-icu` en las cuatro**, aunque el Node moderno traiga
otro valor por defecto: si no fijas la misma bandera, estás comparando compilaciones distintas.
Y **nada de `--shared-openssl`**: el documento 09 lo recomienda y es justamente lo que ata la
compilación a la OpenSSL del sistema. Compilar vendorizado hace la corrida reproducible; el
`--shared-openssl` merece una corrida extra aparte, deliberada, para ver el fallo.

El dato que nadie publica sale del paso 5: **`Maximum resident set size`**, que `/usr/bin/time -v`
imprime al final. Es el pico del proceso hijo más grande —típicamente el enlazado de V8— y es la
cifra que decide si esto cabe en una VM de 4 GB.

### 9.6 Qué traer de vuelta

Por cada una de las cuatro corridas, esto y nada más:

```text
[ ] Host: máquina, CPU, RAM, sistema y versión
[ ] VM: herramienta y versión, distro, kernel (uname -a), cpus/memoria asignadas
[ ] Toolchain: la salida literal del paso 2 completa
[ ] Node: versión compilada
[ ] configure.log — las últimas 30 líneas (el "Configure summary")
[ ] make-1: minutos reales y Maximum resident set size
[ ] make-2 (ccache): minutos reales
[ ] file sobre el binario: la línea entera
[ ] Si falló: el mensaje LITERAL, entero, sin recortar ni traducir
```

Ese último punto es el más importante de la lista. **Un fallo capturado vale más que una corrida
limpia**, porque el catálogo de F31 y F32 se alimenta de mensajes literales y porque el apéndice
sin fallos sería un tutorial más. Si algo revienta, no lo arregles en silencio: guarda el error,
arréglalo, y guarda también qué lo arregló.

### 9.7 Lo que espero que pase, para que no te pille desprevenido

Cuatro hipótesis. Ninguna está verificada — esa es exactamente la razón de hacer el laboratorio —
y **cualquiera de ellas, si se confirma, es una sección del apéndice**:

- **Node 14 en bookworm falla** por `python2.7` ausente, y si insistes con `--shared-openssl`,
  otra vez por la rama 3.x de OpenSSL. Es el fallo que justifica bullseye, y merece ir con su
  mensaje entero.
- **El Node moderno no compila en bullseye** porque su GCC 10 se queda corto para el V8 de hoy.
  El error de C++ será largo y feo; cópialo igual.
- **El enlazado de V8 moderno se come varios GB.** Si la VM va justa, el síntoma no menciona la
  RAM: se muere el `cc1plus`, o lo mata el OOM killer, o sale un `virtual memory exhausted`. Es
  el ejercicio de diagnóstico más bonito de todo el apéndice — y para provocarlo a voluntad
  tienes `memory=` en `.wslconfig` (§9.3) y `--memory` en Lima (§9.2).
- **La segunda pasada con `ccache` baja de veintitantos minutos a unos pocos.** Si no baja,
  `ccache -s` dirá por qué, y eso también es contenido.

### 9.8 Lo que cuesta, en tiempo real tuyo

Montar el laboratorio: una hora larga en total —las dos VM de Lima son lo que más tarda; las dos
distros de WSL2 son quince minutos entre las dos—. Las compilaciones son
tiempo de máquina, no tuyo — arráncalas y vete. Con eso en la mano, el `a17` se escribe en una
sesión, y se escribe con la cabecera de **fecha de verificación ejecutada** que llevan las ocho
fases medidas del curso. Que es, al final, la única razón por la que este apéndice merece existir
dentro de este curso y no en cualquier blog.
