# 📓 Cuaderno de incidentes
## Tutorial React 16 — Rifas y chances

> Documento vivo · Se trabaja solo · El changelog es `git log -- cuaderno-incidentes.md`
> El tiempo de los incidentes ya está contado dentro de las 96 h del track forense
> (`00-alcance-del-proyecto.md` §7); no es un bloque aparte que se suma al final.

Este es el único archivo de incidentes del curso. Acá viven los enunciados, las
pistas, las soluciones de referencia y —sobre todo— tu registro de cómo llegaste
a cada una. Los veinte incidentes vienen reservados de antemano por las fases que
los producen; lo que agregas tú es la parte de abajo de cada entrada: tu
reproducción, tus hipótesis, tu causa raíz, tu fix.

**El curso asume que lo haces sin instructor.** Por eso cada incidente trae su
solución adentro, colapsada. Ese es el trato: la respuesta está a un clic y aun
así abrirla antes de tiempo solo te perjudica a ti. El músculo que este curso
entrena —recibir un ticket vago y encontrar la capa culpable— no se desarrolla
leyendo respuestas correctas, igual que nadie aprendió a depurar mirando a otro
depurar. 😉

---

## 🧭 Cómo se trabaja un incidente

Lees el ticket, reproduces, investigas, escribes tu diagnóstico en el bloque "Tu
investigación", y **recién entonces** abres la solución para compararla. Si tu
causa raíz coincide con la de referencia, perfecto. Si no coincide pero tu fix
funciona, también es información valiosa: anótalo, porque en producción eso pasa
seguido y casi siempre significa que tapaste el síntoma una capa más arriba de
donde estaba el problema.

Las pistas están escalonadas: la primera te dice **dónde** mirar, la segunda
**qué** mirar, la tercera casi te lo cuenta. Ábrelas en orden y solo cuando estés
realmente trabado — trabado quiere decir veinte minutos sin una idea nueva, no
cinco minutos de incomodidad.

Regla del archivo: se **agrega**, no se corrige. Una hipótesis que resultó falsa
no se borra: se marca como descartada, con la evidencia que la tumbó al lado.
Dentro de tres semanas, releer tus descartes es la mejor forma de ver cómo
cambió tu criterio.

> 🧭 **La distinción que atraviesa todo el cuaderno.** Cada fix se escribe dos
> veces: el **parche mínimo** —lo que aplicarías un viernes a las seis— y la
> **refactorización correcta** —lo que harías con calma y pruebas. Distinguirlas
> es la lección más transferible del curso, y es lo primero que te van a pedir en
> un equipo de mantenimiento real.

### Convención de commits

El asunto del commit sigue este formato, para que `git log --oneline` se lea como
la línea de tiempo de tu investigación:

```
incidente(14): abre — el servidor sigue recibiendo peticiones tras el logout
incidente(14): repro — los GET /numbers siguen saliendo cada 5s sin tablero montado
incidente(14): hipótesis descartada — no es el componente, desmontarlo no corta nada
incidente(14): causa — boardRefreshEpic sin takeUntil: el interval nunca se corta
incidente(14): fix — takeUntil(STOP_BOARD_REFRESH, LOGOUT) al final del pipe interno
incidente(14): cierre — marble test de cancelación y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`,
`causa`, `fix`, `cierre`.

Commitea también los callejones sin salida. Un `git log` que muestra seis commits
de investigación y uno de fix es un registro honesto; uno que muestra solo el fix
no le sirve a nadie, y menos a ti dentro de seis meses.

Y como el fix de casi todos estos incidentes es de una o dos líneas, conviene
marcarlo además con el par de tags de `00-convencion-de-git-y-tags.md`:
`inc/14/suscripcion-zombi-roto` con el síntoma reproducido y la regresión en
rojo, `inc/14/suscripcion-zombi-fix` con la causa raíz y el fix en verde. El
`git diff` entre los dos **es** el punto 5 del post-mortem, aislado del ruido de
la fase, y `git tag -n99 -l 'inc/*'` te devuelve el cuaderno entero sin abrir un
archivo.

> 💡 Para releer la historia de un incidente:
> `git log --oneline --grep "incidente(14)" -- cuaderno-incidentes.md`
> Para ver el archivo como estaba al cerrar la Fase 6:
> `git show <sha>:cuaderno-incidentes.md`

### Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y test de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 🩺 Entrar por el síntoma

Nadie llega a una investigación sabiendo de qué fase es su problema. Llega con una
frase vaga y con prisa. Por eso el índice que de verdad se usa no es el de más
abajo, ordenado por ID, sino este: **el que va del síntoma a la primera
herramienta**.

### El método: cuatro preguntas, siempre en este orden

El orden no es una preferencia. Cada pregunta cuesta bastante más que la anterior,
y contestar las baratas primero descarta la mitad de las caras.

**1. ¿Se reproduce, y con qué?** Antes de abrir un archivo: ¿esto aparece con un
**flag** —el `CHAOS_LEVEL` del mock—, con un **dato** distinto en `db.json`, con una
**configuración de la máquina** (zona horaria, versión de Node), o hace falta **otro
código**? Las cuatro respuestas llevan a investigaciones distintas, y averiguar
cuál te ahorra la mitad del camino. Es la misma pregunta que ordena la sección 🔧
Preparación de cada incidente.

**2. ¿Qué dice la evidencia observable, antes que el código?** Una petición en
Network, un header, el *Diff* de una acción en Redux DevTools, un `console.count`.
La mayoría de los incidentes de este cuaderno se localizan acá, y ninguno de ellos
necesita abrir un editor para eso. **El código es el paso cuatro, no el primero.**

**3. ¿En qué capa vive?** Componente, store, epic, interceptor, mock o build. Nombrar
la capa **es** el entregable de una investigación; el fix suele ser de una línea y
viene después. Un truco que resuelve muchos casos: si aparece una acción en Redux
DevTools y **no hay ninguna petición al lado en Network**, nació dentro del
navegador.

**4. ¿De qué era es el archivo que voy a tocar?** 🧬 Esta es la pregunta propia de
este sistema y no existiría en uno escrito de una sola vez. Un fix sobre un *class
component* con `connect()` se escribe como el resto de ese archivo; uno sobre un
slice de Redux Toolkit, con las convenciones de 2021; uno sobre un epic, con las de
2022. Las tres eras están en `00-historia-del-sistema.md` §3, y el traductor entre
las dos primeras es `A5-class-components-vs-hooks.md`.

> 🧭 **La regla que resume las cuatro:** *"funciona en mi máquina", "a veces pasa" y
> "desde ayer" no describen un bug: describen una **diferencia**.* Todo el trabajo
> consiste en encontrar cuál.

### La tabla, del síntoma a la primera herramienta

| Lo que llega en el ticket | Primero mira | Capa más probable | Candidatos |
|---|---|---|---|
| "No arranca / explota antes de abrir" | la terminal, entera | build, entorno | 01, 02 |
| "Anda en tu máquina y en la mía no" | zona horaria, `node -v`, `process.arch` | entorno, suite | 02, 16, 20 |
| "Parpadea y pierdo lo que escribí" | Network, *Preserve log* | componente | 03, 09 |
| "Veo datos de otra cosa" | React DevTools: props contra estado | componente, epic | 04, 15 |
| "Me dice que no tengo permiso" | Network → **Request** Headers | interceptor | 05 |
| "Cerré sesión y algo quedó" | Redux DevTools → *Diff* | store, epic | 06, 14 |
| "A veces no carga y no dice nada" | Network: la fila **sin status** | transporte, store | 07, 10, 17 |
| "Me saca a login sin avisar" | el `request-id`, en los dos lados | mock, interceptor | 08 |
| "Se quedó cargando para siempre" | Redux DevTools: la última acción | store | 10, 07 |
| "Se vendió dos veces" | Redux DevTools: la secuencia entera | store, epic | 11 |
| "Cambió solo, nadie lo tocó" | espera sin tocar nada, mirando DevTools | temporizador, epic | 12, 14 |
| "Falló una vez y no anda más" | Network: ¿sale **alguna** petición? | epic | 13 |
| "Sigue pasando después de salir" | Network, en reposo | epic | 14, 12 |
| "La cuenta no cuadra" | la función pura, en una consola de Node | cálculo | 18 |
| "Va lento al final del día" | Profiler + `console.count` | componente, selector | 19 |
| "Verde en mi máquina, rojo en CI" | `TZ=UTC npm test` | suite, componente | 20 |

Una advertencia sobre la última columna: es una lista de **candidatos**, no un
diagnóstico. Dos incidentes de este cuaderno pueden compartir síntoma y no
compartir nada más — el 07 y el 10 son el caso arquetípico, y se separan con una
sola columna de Network—. Empezar por el candidato equivocado no es un problema
mientras la evidencia te saque de ahí rápido; empezar por el código sí lo es.

---

## 📋 Índice

Lo actualizas en el mismo commit que abre o cierra un incidente.

Los veinte IDs vienen reservados por las fases que los producen, y el título es el
que va a llegar en el ticket — con su vaguedad incluida. Los veinte enunciados
están redactados más abajo; el ⬜ de la última columna es **tu** estado, no el del
archivo, y arranca en "sin empezar". El ID **nunca** se reasigna.

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| 01 | 0 | Bajé el repo y `npm start` explota antes de abrir nada | Entorno | 🟢 | ⬜ |
| 02 | 0 | En la máquina de al lado compila y en la mía no | Entorno | 🟢 | ⬜ |
| 03 | 1 | Hago clic en el menú y se recarga toda la aplicación | UI / routing | 🟢 | ⬜ |
| 04 | 1 | Entro al detalle de otra rifa y sigo viendo la anterior | UI / routing | 🟡 | ⬜ |
| 05 | 2 | Las peticiones salen sin token y el servidor las rebota | Autenticación | 🟡 | ⬜ |
| 06 | 2 | Cerré sesión pero la pantalla sigue mostrando mi usuario | Autenticación | 🟡 | ⬜ |
| 07 | 3 | A veces no carga y no dice nada | Integración | 🟡 | ⬜ |
| 08 | 3 | Me saca a login al azar mientras estoy trabajando | Integración | 🟡 | ⬜ |
| 09 | 4 | Guardo la rifa, se recarga la página y pierdo todo | Estado (store) | 🟢 | ⬜ |
| 10 | 4 | La lista de rifas se queda cargando para siempre | Estado (store) | 🟡 | ⬜ |
| 11 | 5 | Vendimos el número 0347 dos veces ⭐ | Concurrencia | 🔴 | ⬜ |
| 12 | 5 | Un número que ya estaba vendido volvió solo a disponible | Concurrencia | 🟠 | ⬜ |
| 13 | 6 | Falló una venta y desde entonces no funciona ninguna | RxJS / epics | 🟠 | ⬜ |
| 14 | 6 | Cerré sesión y el servidor sigue recibiendo peticiones ⭐ | RxJS / epics | 🟠 | ⬜ |
| 15 | 6 | Escribo el número rápido y me valida uno viejo | RxJS / epics | 🟠 | ⬜ |
| 16 | 7 | La rifa siguió vendiendo después de la hora de cierre | Tiempo | 🟠 | ⬜ |
| 17 | 7 | El resultado nunca llega y no aparece ningún error | RxJS / epics | 🟠 | ⬜ |
| 18 | 8 | La liquidación da un centavo de diferencia | Dinero | 🟠 | ⬜ |
| 19 | 9 | El dashboard se arrastra al final del día | Performance | 🟠 | ⬜ |
| 20 | 10-11 | El test pasa en mi máquina y falla en la de al lado | Testing | 🔴 | ⬜ |

### 🔥 Reserva del track BE

El track opcional de backend produce sus propios incidentes, y para que nunca
choquen con los veinte de arriba tienen **rango propio: `be-01` a `be-16`**, y
viven en su propio archivo:

> 📓🔥 **[`cuaderno-incidentes-be.md`](cuaderno-incidentes-be.md)** — los dieciséis
> incidentes del track BE, **redactados**, con la misma estructura, las mismas
> reglas y el mismo tono que este cuaderno.

**Por qué en un archivo aparte**, si arriba dice que este es el único archivo de
incidentes del curso: porque el track BE es opcional, y quien haga solo las 96
horas del track base no debería encontrarse dieciséis incidentes de Go y Postgres
intercalados entre los suyos. La divergencia está declarada allá y los rangos de
IDs no colisionan. Su plantilla —igual a esta, con las herramientas del backend en
vez de las del navegador— está en `prompts/plantilla-de-incidente-be.md`.

**Seis de los dieciséis son hermanos de incidentes de este cuaderno**: mismo
síntoma, otra capa, otra causa raíz. Resolverlos en pareja enseña más que
resolverlos sueltos, y el cruce está en el índice de aquel archivo.

| Este cuaderno | Track BE | Qué cambia |
|---|---|---|
| 11 — el `0347` vendido dos veces ⭐ | `be-09` ⭐ | Allá el store; acá el índice único y la transacción |
| 16 — la rifa siguió vendiendo tras el cierre | `be-12` | Allá el reloj del navegador; acá la autoridad del servidor |
| 18 — la liquidación da un centavo de diferencia | `be-13` | Allá el redondeo; acá el cliente calculando con datos viejos |
| 19 — el dashboard se arrastra al final del día | `be-05` | Allá memoización; acá el pool de conexiones agotado |
| 20 — el test pasa en mi máquina y falla en la de al lado | `be-15` ⭐ | Allá el entorno; acá el **motor** de la base |
| 08 — la sesión se cae sola | `be-08` | Allá el `401` del caos; acá un `exp` real sin renovación | Sus categorías propias son **base de datos**,
**transacciones**, **despliegue** y **contrato**, y se suman a las de abajo.

Un incidente `be-NN` puede compartir síntoma con uno del track base y tener otra
causa raíz: ese paralelo es deliberado y es de lo más formativo que ofrece el
track. El caso arquetípico es el 11 —el número 0347 vendido dos veces—, que en
el track base se diagnostica en el store y en el track BE se resuelve con un
índice único y una transacción.

**Categorías:** entorno · UI / routing · autenticación · integración ·
estado (store) · concurrencia · RxJS / epics · tiempo · dinero · performance ·
testing · 🔥 base de datos · 🔥 transacciones · 🔥 despliegue · 🔥 contrato.

**Dificultad:** 🟢 fácil · 🟡 intermedio · 🟠 difícil · 🔴 muy difícil.
**⭐** marca los dos incidentes más formativos del curso: la race condition de
venta (11) y la suscripción zombi del epic (14).

> 📝 **Por qué cinco de los veinte son de RxJS.** Los incidentes 13, 14, 15 y 17
> —más el 12, que se resuelve con cancelación— cubren el terreno que el
> `00-alcance-del-proyecto.md` §7 marca como mínimo obligatorio. No es capricho:
> `catchError` faltante, `takeUntil` mal ubicado, `mergeMap` donde iba
> `switchMap` y suscripciones que nadie corta son los cuatro bugs de epics que
> más caro salen en producción, y los cuatro son invisibles en la consola.

---

# 🧪 Incidentes

Ordenados por ID, que es también el orden sugerido: cada uno se puede resolver
con lo que sabes al terminar la fase indicada. Adelantarte a un incidente de la
Fase 9 estando en la 4 no es imposible, pero vas a pelear con herramientas que
todavía no conoces.

El ID nunca se reasigna.

---

## Incidente 01 — Bajé el repo y `npm start` explota antes de abrir nada

> **Fase:** 0 · **Categoría:** Entorno · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-30 min

### 🎫 El ticket

Me pasaron el repositorio el lunes. Seguí el README paso por paso, hice el `npm
install` y cuando corro `npm start` se muere solo, con un montón de letras y
números que no significan nada para mí. No llegué a ver la aplicación ni una vez.
En la máquina de mi compañero arranca sin problema, y estamos en el mismo commit.

**Reportado por:** nuevo integrante del equipo, primer día
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Reproducir, localizar en qué capa vive la causa —adelanto: no está en `src/`— y
aplicar el hotfix que lo desbloquee hoy. Después, en una línea aparte, cuál es la
corrección correcta. En este incidente las dos no son lo mismo, y la Fase 0 tiene
opinión al respecto.

### 🔧 Preparación

- **Rama:** `incidente/01`
- **Caos:** no aplica. En Fase 0 todavía no existe el mock, y el fallo es
  determinista: pasa siempre o no pasa nunca.
- **Datos:** no aplica.

La rama trae el `.nvmrc` borrado a propósito, que es justo lo que hace que el
problema dependa de con qué Node estés parado.

```bash
git checkout incidente/01
nvm use 20        # o cualquier Node 17+; ese es el detonante
npm install
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

El error no lo produce tu código: lee el volcado entero y fíjate si alguna línea
menciona un archivo de `src/`. Ninguna. Antes de abrir un editor, pregúntate qué
es lo único que puede diferir entre tu máquina y la de tu compañero si el
repositorio y el commit son idénticos.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Lee el volcado hasta el final, no las tres primeras líneas. El módulo que falla
pertenece a webpack, y hay dos palabras que se repiten: `digital envelope` y
`openssl`. Ahora corre `node --version` en tu máquina y en la de tu compañero.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué versión de OpenSSL trae Node 17 en adelante, qué algoritmo de hash usa
webpack 4 para nombrar sus módulos, y qué pasó con ese algoritmo en OpenSSL 3?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados y exactos. Anota tu versión de Node y tu sistema operativo:
en este incidente son el dato, no el contexto.}}

**Evidencia observable**
{{El volcado completo, en texto. No la captura: el texto se busca.}}

```
{{el error tal cual salió por la terminal}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{¿En qué capa vive? Componente, store, epic, mock, build… o ninguna de esas.}}

**Tu fix**
{{El parche mínimo del viernes a las seis. Aparte, la corrección correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

No hay archivo culpable. La causa es una incompatibilidad entre el **runtime** y
una dependencia de build: Node 17 y posteriores traen OpenSSL 3, que retiró MD4
del proveedor por defecto, y el webpack 4 que empaqueta `react-scripts@4.0.3` usa
justamente MD4 para hashear los identificadores de módulo. El resultado es
`error:0308010C:digital envelope routines::unsupported`, a veces disfrazado de
`ERR_OSSL_EVP_UNSUPPORTED`.

> 📝 **Nota de época.** `react-scripts@4.0.3` es de 2021, cuando Node 14 era LTS y
> nadie tenía OpenSSL 3 en su máquina. El sistema se congeló en 2023
> (`00-historia-del-sistema.md` §3, cierre de la Era 3) con esa combinación
> funcionando. No envejeció el proyecto: envejeció el mundo alrededor.

**Parche mínimo**

```bash
# El viernes a las seis, para desbloquear a alguien que necesita trabajar hoy.
NODE_OPTIONS=--openssl-legacy-provider npm start
```

Y conviene decirlo con todas las letras, porque la Fase 0 ya lo advirtió: **esto
no es el fix**. Es reactivar un proveedor criptográfico obsoleto en toda la
sesión de Node para que un hasher de 2016 siga funcionando. Sirve para hoy.

**La refactorización correcta**

Usar la versión de Node de producción, que es la única que garantiza que lo que
compila en tu máquina es lo que compila en el pipeline:

```bash
echo "14.21.3" > .nvmrc
nvm use          # ahora lee el archivo, no tu memoria
```

Y dejarlo declarado en `package.json`, para que el error deje de ser críptico:

```json
"engines": { "node": "14.21.3" }
```

**Prueba de regresión**

Acá no hay test de Jest que valga: el fallo ocurre antes de que exista un
proceso de pruebas. La regresión es una comprobación de entorno que corre antes
del arranque.

```javascript
// scripts/checkNodeVersion.js — se engancha en el prestart del package.json.
const fs = require('fs');

const expected = fs.readFileSync('.nvmrc', 'utf8').trim();
const actual = process.versions.node;

if (actual !== expected) {
  console.error(
    `\n⛔ Este proyecto necesita Node ${expected} y estás en ${actual}.` +
    `\n   Corre "nvm use" desde la raíz del repositorio.\n`
  );
  process.exit(1);
}
```

**Prevención**

El script de arriba en `prestart` y `pretest`, el `.nvmrc` versionado, y el
pipeline usando esa misma versión. Un mensaje de error que dice qué hacer vale
más que cualquier página de documentación.

**Por qué llegó a producción**

No llegó: es un fallo de incorporación, y esos no tienen dueño. Quien ya tiene el
entorno armado no lo reproduce nunca, así que el problema solo lo sufre quien
llega — y quien llega todavía no tiene el crédito para decir que algo del equipo
está mal. El sistema no falló. Falló que la versión de Node viviera en la
memoria colectiva del equipo en lugar de en un archivo del repositorio.

**Si tu causa fue distinta a esta**

Si concluiste *"el `node_modules` quedó corrupto"* y borrarlo y reinstalar te lo
arregló, revisa qué Node tenías activo en ese segundo intento: es muy probable
que un `nvm use` de otra terminal te hubiera cambiado de versión sin que lo
notaras, y estés atribuyendo el arreglo a la reinstalación. Si concluiste *"falta
una dependencia"*, el `npm ci` habría fallado antes, en la instalación, y con
otro mensaje.

</details>

---

## Incidente 02 — En la máquina de al lado compila y en la mía no

> **Fase:** 0 · **Categoría:** Entorno · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 25-35 min

### 🎫 El ticket

Somos dos haciendo exactamente lo mismo. A ella el proyecto le instala y le
compila; a mí me revienta el `npm install` con errores de un tal `node-gyp`.
Probamos borrar la carpeta y reinstalar tres veces, igual. Al final le copié su
carpeta `node_modules` por USB y ahí sí me arrancó. Lo raro es que desde ese día
a ella empezó a pasarle lo mismo que a mí.

**Reportado por:** dos desarrolladores del equipo
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Reproducir, y sobre todo **explicar el fenómeno del USB**: por qué copiar
`node_modules` arregló una máquina y rompió la otra. Ese es el entregable.

> ⚠️ **Este incidente no termina en un commit de código, y no es un defecto del
> enunciado.** Termina en una nota de documentación y en una regla de equipo. Es
> uno de los tres del cuaderno con ese desenlace, y en la vida real es el
> desenlace más frecuente de los problemas de entorno: nadie te va a aceptar un
> *pull request* que arregle la CPU de tu compañero.

### 🔧 Preparación

- **Rama:** `incidente/02`, que restituye `node-sass` en el `package.json`
- **Caos:** no aplica.
- **Datos:** no aplica.
- **Hace falta un dato que no es del repositorio:** dos máquinas con arquitecturas
  distintas, o una máquina y un contenedor. Si solo tienes una, el contenedor
  hace de segunda: `docker run --rm -it -v "$PWD":/app -w /app node:14 bash`.

```bash
git checkout incidente/02
node -p process.arch      # anota esto: es la mitad del diagnóstico
rm -rf node_modules
npm install
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

El error no es de JavaScript. Es de un compilador de C++ que se llama `node-gyp`.
Pregúntate qué hace un compilador de C++ dentro de un proyecto que por ahora solo
pinta tarjetas de rifas, y qué paquete lo está invocando.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El paquete es `node-sass`. Busca su tabla de compatibilidad —qué versión de
`node-sass` con qué versión de Node— y crúzala con lo que te devolvió
`node -p process.arch`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si `node_modules` contiene binarios compilados para una arquitectura de CPU
concreta, ¿qué es exactamente lo que copiaste por USB, y qué tenía que pasar la
próxima vez que cualquiera de las dos máquinas reinstalara?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Anota `process.arch`, `node --version` y el sistema operativo
de las dos máquinas: sin esos tres datos el incidente no se puede contar.}}

**Evidencia observable**
{{La salida de `npm install` desde la primera línea de `node-gyp`.}}

```
{{el error de compilación}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{¿Es del código, de la dependencia, de la máquina, o del procedimiento?}}

**Tu fix**
{{Y si tu conclusión es que no hay fix de código, escríbelo así, con esas
palabras, y di qué entregas en su lugar.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Dos causas encadenadas, y la segunda es la interesante.

La primera: el `package.json` heredado trae **`node-sass`**, que no es JavaScript
sino un envoltorio de LibSass que hay que **compilar** en cada máquina. Para las
combinaciones de Node y arquitectura que tienen binario precompilado, el
instalador lo baja y listo; para las que no —y `arm64` de Apple Silicon es la que
más falta— intenta compilarlo con `node-gyp` y falla.

La segunda, la del USB: **`node_modules` no es código fuente, es un artefacto de
compilación**. Al copiarlo llevaste binarios compilados para una arquitectura a
una máquina de otra. Funcionó por casualidad —o funcionó a medias, hasta que algo
tocó ese binario— y la máquina que lo entregó quedó contaminada en cuanto alguien
volvió a instalar sobre esa carpeta mezclada. Es exactamente el mismo mecanismo
del `node_modules` del host montado dentro de un contenedor, que
`A9-entornos-y-contenedores.md` §7 documenta como el error de entorno que más
caro sale.

**El desenlace, que no es un parche**

El cambio de dependencia —`node-sass` fuera, `sass` (dart-sass, JavaScript puro,
sin compilar nada) adentro— **ya está tomado como decisión del stack en la Fase
0**, y por eso el `package.json` del curso no lo trae. Sobre el código vigente
este bug no puede volver. Lo que este incidente entrega es lo otro, que es lo que
sí se transfiere:

1. **Una nota en `A3-node-y-npm.md`**: qué es un paquete con binario nativo, cómo
   se reconoce en el `package.json` antes de instalarlo, y por qué `sass` le gana
   a `node-sass` en un proyecto congelado.
2. **El `.nvmrc`** con `14.21.3`, que también resuelve la mitad del incidente 01.
3. **Una regla, escrita donde el equipo la lea:** `node_modules` **jamás** se
   copia entre máquinas ni se sube al repositorio. Se reconstruye con `npm ci`,
   que además respeta el `package-lock.json` al pie de la letra.

Y decir *"esto no se arregla con un commit"* es una respuesta profesional
completa. Practícala: cuesta más de lo que parece.

**Prueba de regresión**

No hay test que atrape esto, porque el fallo ocurre antes de que exista una suite.
Lo que hace las veces de regresión es un `npm ci` sobre un `node_modules`
inexistente, corriendo en la arquitectura objetivo dentro del pipeline. Si eso
pasa en limpio, el bug no puede reaparecer por esta puerta.

**Prevención**

`node_modules` en el `.gitignore` (ya lo está), `engines` en el `package.json`,
`.nvmrc` versionado, `npm ci` en vez de `npm install` en cualquier entorno
automatizado, y la sección §7 de `A9` enlazada desde el README para el día que
alguien monte un contenedor.

**Por qué llegó a producción**

No llegó a producción, y aun así costó dos días de trabajo de dos personas. Lo que
lo permitió no fue una decisión mala sino una ausencia: nadie escribió nunca cuál
era el procedimiento para preparar una máquina, así que cada quien improvisó, y
la improvisación más razonable del mundo —*"copiémosle la carpeta que a ella le
anda"*— era justo la que rompía las dos. El análisis acá no es sobre las dos
personas: es sobre un equipo que dejó el procedimiento sin escribir.

**Si tu causa fue distinta a esta**

Si dijiste *"es el proxy corporativo o el registro de npm"*, la instalación habría
fallado al **descargar**, con un error de red y sin llegar nunca a invocar el
compilador. Si dijiste *"falta Python o las herramientas de compilación"*, vas
bien encaminado pero te quedaste a mitad: instalarlas puede hacer que compile, y
eso tapa el síntoma dejándote una dependencia nativa que volverá a morder en la
próxima máquina distinta.

</details>

---

## Incidente 03 — Hago clic en el menú y se recarga toda la aplicación

> **Fase:** 1 · **Categoría:** UI / routing · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-30 min

### 🎫 El ticket

Desde que tocaron el menú de arriba, cada vez que hago clic en "Rifas" la pantalla
se pone en blanco un segundo y después carga. Antes era instantáneo. Y hay algo
peor: si estaba llenando el formulario de una rifa y hago clic en el menú, cuando
vuelvo se me borró todo lo que había escrito.

**Reportado por:** supervisor de ventas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar la línea culpable y aplicar el hotfix. Y como ejercicio
aparte: explicar por qué *"se me borra lo que estaba escribiendo"* es la mejor
frase del ticket, mucho mejor que *"se pone en blanco"*.

### 🔧 Preparación

- **Rama:** `incidente/03`
- **Caos:** no aplica; es determinista y se reproduce el 100% de las veces.
- **Datos:** no aplica; con las rifas de demostración alcanza.

```bash
git checkout incidente/03
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No abras el código todavía. Abre DevTools en la pestaña **Network**, marca
*Preserve log*, y haz clic en el menú. Cuenta cuántas peticiones aparecen y de
qué **tipo** son. Después haz lo mismo navegando desde un enlace de la tabla de
rifas, que no tiene el problema, y compara las dos listas.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/components/Navbar.jsx`. Los enlaces de ese componente no son todos iguales:
míralos uno por uno y agrúpalos en dos familias. El que parpadea está en una de
las dos.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué hace el navegador, por su cuenta y antes de que React se entere de nada, con
un `<a href="/raffles">`? ¿Y qué le queda al árbol de componentes que estaba
montado en memoria después de eso?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados y exactos, incluyendo desde qué pantalla saliste.}}

**Evidencia observable**
{{Lo que muestra Network con *Preserve log* activo, en texto.}}

```
{{las peticiones, con su tipo y su tamaño}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. ¿En qué capa vive: componente, store, epic, mock o build?}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/components/Navbar.jsx`: el enlace del menú es un `<a href="/raffles">` en vez
de un `<Link to="/raffles">`. Es el error común #3 de la Fase 1.

Un ancla común es una instrucción para el **navegador**, no para React Router: el
navegador pide el documento al servidor, recibe el `index.html`, descarta la
página que tenía y arranca de cero. El árbol de React se destruye entero y se
vuelve a montar, el `bundle.js` se vuelve a evaluar, y todo lo que vivía en
memoria —el estado de cada componente, incluido el formulario a medio llenar— se
va con él. Router 5 nunca llega a intervenir: para cuando su `history` podría
haber interceptado el clic, el documento ya se está descargando.

Por eso *"se me borra lo que estaba escribiendo"* es la mejor pista del ticket:
"se pone en blanco" también lo produciría un error de render o una pantalla lenta,
pero **perder el estado en memoria solo pasa si el árbol se destruyó**. El
supervisor, sin saberlo, te entregó el diagnóstico.

> 📝 **Nota de época.** El `Navbar` es de la Era 1 (2019), escrito por el
> contratista contra la fecha del sorteo de diciembre
> (`00-historia-del-sistema.md` §3). Un `<a href>` era lo natural para alguien que
> venía de páginas server-side y estaba aprendiendo Router sobre la marcha.

**Evidencia que lo confirma**

En Network con *Preserve log*: aparece una petición de tipo `document` seguida del
`bundle.js` completo y de los estilos. Navegando con un `<Link>` correcto la lista
no crece ni una fila: cero peticiones, porque no hay nada que pedir.

**Parche mínimo**

```javascript
// src/components/Navbar.jsx
import { Link } from 'react-router-dom';

// ❌ antes: <a href="/raffles">Rifas</a>
// ✅ ahora: el clic lo maneja Router, no el navegador.
<Link to="/raffles">Rifas</Link>
```

**La refactorización correcta**

`NavLink` en vez de `Link` para los enlaces del menú, que además resuelve marcar
cuál está activo sin comparar rutas a mano:

```javascript
<NavLink to="/raffles" activeClassName="active">Rifas</NavLink>
```

Y una regla de lint que prohíba `<a href>` con rutas internas, porque este bug se
reintroduce solo: es una etiqueta de tres caracteres que nadie mira en una
revisión de código sobre estilos.

**Prueba de regresión**

En jsdom un ancla no recarga nada —simplemente no navega—, y eso juega a nuestro
favor: el test falla antes del fix porque la ruta **no cambia**, y pasa después
porque `Link` sí la cambia.

```javascript
// src/components/Navbar.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route } from 'react-router-dom';
import Navbar from './Navbar';

test('el menú navega sin recargar el documento', () => {
  let currentPath = null;

  render(
    <MemoryRouter initialEntries={['/']}>
      <Navbar />
      <Route path="*" render={({ location }) => {
        currentPath = location.pathname;
        return null;
      }} />
    </MemoryRouter>
  );

  userEvent.click(screen.getByText('Rifas'));

  // Con <a href> la ruta del router no se entera: sigue en "/".
  expect(currentPath).toBe('/raffles');
});
```

**Prevención**

La regla de lint, y un test como el de arriba por cada enlace del menú. Es de los
pocos casos donde una prueba de tres líneas cubre una familia entera de fallos.

**Por qué llegó a producción**

Porque el enlace **funciona**: te lleva a la pantalla correcta. El costo es
invisible en una demostración de dos clics sobre una aplicación recién cargada, y
solo se manifiesta cuando alguien tiene trabajo a medio hacer en memoria — es
decir, con usuarios reales y nunca con quien lo programó. Ninguna revisión de
código mira las etiquetas de un `Navbar` cuando el cambio venía titulado "ajustes
de estilo del menú".

**Si tu causa fue distinta a esta**

Si dijiste *"el servidor está lento"*, mide: el parpadeo es idéntico con el
servidor local y con el de UAT, porque el costo no es la red sino volver a montar
la aplicación entera. Si dijiste *"falta memoización"*, ojo con la distinción que
vale para todo el curso: un **re-render** es que React vuelva a pintar un
componente vivo; un **remontaje** es que lo destruya y lo cree de nuevo. La
memoización actúa sobre lo primero y no puede hacer nada contra lo segundo.

</details>

---

## Incidente 04 — Entro al detalle de otra rifa y sigo viendo la anterior

> **Fase:** 1 · **Categoría:** UI / routing · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min

### 🎫 El ticket

Tengo la lista de rifas. Abro la de Navidad, la miro, vuelvo atrás y abro la de
Año Nuevo… y me sigue mostrando la de Navidad. Arriba, en la barra del navegador,
dice que estoy en la 2, pero abajo el nombre y los datos son los de la 1. Si
aprieto F5 ahí sí aparece la correcta. Yo creo que se confunde por los nombres
parecidos.

**Reportado por:** vendedor de rifas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir y decidir **cuál de dos causas plausibles** lo está provocando. Las dos
producen exactamente este síntoma y las dos se "arreglan" con cambios distintos
que funcionan. El entregable no es el parche: es la evidencia que descarta una de
las dos.

Y de paso, descartar la teoría del vendedor. Los tickets suelen traer una, casi
siempre es incorrecta, y desmontarla con evidencia en vez de ignorarla es parte
del trabajo.

### 🔧 Preparación

- **Rama:** `incidente/04`
- **Caos:** no aplica; determinista.
- **Datos:** hacen falta al menos dos rifas en `mock/raffles.js` con nombres bien
  distintos —`Rifa de Navidad` con `id: 1` y `Rifa de Año Nuevo` con `id: 2`— para
  que el síntoma sea inconfundible. La rama ya las trae.

```bash
git checkout incidente/04
npm start
# Navega: /raffles → detalle de la 1 → atrás → detalle de la 2
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

React DevTools, pestaña **Components**, selecciona `RaffleDetailPage` y déjala
seleccionada mientras navegas de una rifa a la otra. Mira dos cosas **al mismo
tiempo** en el panel derecho: lo que trae `useParams` y lo que hay en el estado.
Uno de los dos cambia y el otro no. Cuál es cuál te dice casi todo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Activa **"Highlight updates when components render"** en las opciones de React
DevTools y navega otra vez. La pregunta que separa las dos causas es una sola:
¿el componente **se re-renderiza** al cambiar de rifa, o ni se entera?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el componente sí se re-renderiza y el estado sigue viejo: ¿quién tenía que
haber actualizado ese estado, y cuántas veces corre en la vida de un componente
la función que le pasas a `useState`?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Di explícitamente si navegaste con los enlaces de la lista o
escribiendo la URL a mano: no es lo mismo y una de las dos no reproduce.}}

**Evidencia observable**
{{Lo que muestra React DevTools: params y estado, lado a lado, antes y después de
navegar. Y si el borde de *highlight* se encendió o no.}}

```
{{params.id = ...   ·   state.raffle = ...}}
```

**Hipótesis**
- ❌ Descartada: {{cuál de las dos causas plausibles descartaste, y con qué}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta. Y si encontraste más de
un cambio que hace desaparecer el síntoma, anótalos todos: eso importa.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/pages/RaffleDetailPage.jsx` guarda la rifa en estado local, inicializado con
el `id` de la URL, y nadie lo vuelve a tocar:

```javascript
// ❌ El inicializador de useState corre UNA sola vez, en el primer montaje.
const { id } = useParams();
const [raffle, setRaffle] = useState(findRaffle(id));
```

Al navegar de `/raffles/1` a `/raffles/2`, Router 5 renderiza el mismo componente
en la misma posición del árbol, así que React **reutiliza la instancia**: no la
desmonta, la vuelve a renderizar con parámetros nuevos. `useParams` devuelve
`"2"`, el componente se re-renderiza… y `useState` ignora por completo el
argumento que le pasas a partir del segundo render. El estado se quedó con la
rifa 1, para siempre.

Es, textualmente, el "rompe a propósito" de la pieza forense de la Fase 1.

Y explica el F5: recargar destruye la aplicación y la monta de nuevo, así que el
inicializador vuelve a correr —esta vez con el `id` correcto— y todo parece
funcionar. **Que un F5 lo arregle es la firma del estado que no se sincroniza.**

**La otra causa plausible, y cómo se descartan**

La segunda hipótesis razonable es que el componente **ni siquiera se re-renderiza**
porque React lo está tratando como "el mismo" nodo y algo aguas arriba —una lista
con `key={index}`, un `React.memo` mal puesto— le impide enterarse del cambio.
Produce el mismo síntoma exacto.

Se separan con una sola observación, la de la pista 2: **activa *Highlight
updates* y navega**. Si el borde se enciende, el componente se re-renderizó y la
causa es el estado congelado. Si no se enciende, ni llegó a re-renderizar y hay
que subir en el árbol.

Lo que vuelve formativo a este incidente es que **los dos fixes funcionan**. Poner
`key={id}` en la `Route` fuerza a React a desmontar y montar de nuevo, el
inicializador vuelve a correr y el síntoma desaparece — sin que hayas tocado la
causa. Eso es tapar el problema una capa más arriba, y se paga el día que el
componente tenga además un formulario o un filtro en estado local: el remontaje se
los lleva puestos, y vas a estar depurando el incidente 03 otra vez, con otra
puerta de entrada.

**Parche mínimo**

```javascript
// El estado sigue existiendo, pero ahora alguien lo sincroniza.
useEffect(() => {
  setRaffle(findRaffle(id));
}, [id]);
```

**La refactorización correcta**

No guardar en estado algo que es **derivado** de la URL. La rifa no es información
del usuario: es una función del `id`, y se calcula en el render.

```javascript
const { id } = useParams();
const raffle = findRaffle(id);   // sin useState, sin useEffect, sin sincronizar
```

El estado local se reserva para lo que el usuario cambia y el sistema no puede
recalcular. Esta es la versión de una línea de una regla que vale para todo el
curso, y que en Fase 4 vuelve con el store de por medio.

**Prueba de regresión**

```javascript
// src/pages/RaffleDetailPage.test.jsx
import { render, screen } from '@testing-library/react';
import { MemoryRouter, Route } from 'react-router-dom';
import RaffleDetailPage from './RaffleDetailPage';

test('al cambiar el id de la ruta, muestra la rifa nueva', () => {
  const { rerender } = render(
    <MemoryRouter initialEntries={['/raffles/1']}>
      <Route path="/raffles/:id" component={RaffleDetailPage} />
    </MemoryRouter>
  );
  expect(screen.getByText('Rifa de Navidad')).toBeInTheDocument();

  // Sin desmontar: es exactamente lo que hace Router al navegar.
  rerender(
    <MemoryRouter initialEntries={['/raffles/2']}>
      <Route path="/raffles/:id" component={RaffleDetailPage} />
    </MemoryRouter>
  );
  expect(screen.getByText('Rifa de Año Nuevo')).toBeInTheDocument();
});
```

El detalle que hace útil este test es que **no desmonta**. Un test que renderice
dos veces desde cero pasa incluso con el bug presente, y te deja tranquilo con el
error adentro.

**Prevención**

Una regla de revisión fácil de aplicar: si el argumento de un `useState` depende
de props, de `useParams` o del store, hay que justificar por qué no se calcula en
el render. Y si de verdad hace falta copiarlo a estado, el `useEffect` que lo
sincroniza va pegado, en la línea siguiente, no doscientas líneas abajo.

**Por qué llegó a producción**

Porque el F5 lo tapa, y quien lo escribió probó recargando. El bug solo aparece
navegando dentro de la aplicación, que es justamente lo que hace un usuario y lo
que no hace quien está programando con el editor al lado y guardando cada treinta
segundos.

Hay además una razón de fondo, y es de época: copiar datos a estado local en el
montaje es el patrón natural de un *class component* de la Era 1, donde se hacía
en `componentDidMount`. El error clásico de entonces era olvidar
`componentDidUpdate`; el de hoy es olvidar el `useEffect` con su dependencia. **Es
el mismo bug con otra sintaxis**, y la traducción entre las dos formas está en
`A5-class-components-vs-hooks.md`.

**Si tu causa fue distinta a esta**

Si tu diagnóstico fue *"los nombres se confunden"*, esa era la teoría del ticket:
cámbiale el nombre a una de las dos rifas por algo irreconocible y el síntoma
sigue igual. Descartada con evidencia, en treinta segundos. Si dijiste *"falta un
`exact` en la ruta"*, mira la URL: el error común #2 de la Fase 1 te dejaría
viendo el **listado**, no un detalle equivocado. Y si tu fix fue `key={id}` en la
`Route` y funcionó, lee otra vez el apartado de arriba: funciona, no es la causa,
y tiene un costo que hoy no se nota.

</details>

---

## Incidente 05 — Las peticiones salen sin token y el servidor las rebota

> **Fase:** 2 · **Categoría:** Autenticación · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-40 min

### 🎫 El ticket

Entro con mi usuario y mi contraseña y me deja pasar sin problema: veo el menú y
arriba a la derecha aparece mi nombre. Pero apenas hago clic en cualquier rifa me
dice que no tengo permiso. Es raro, porque acabo de entrar. Probé cerrando y
volviendo a entrar y pasa lo mismo.

**Reportado por:** vendedor de rifas
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Reproducir y localizar la capa. Hay una contradicción en el sistema —dos fuentes
que dicen cosas distintas sobre la misma sesión— y encontrarla es el noventa por
ciento del trabajo. El fix es de una línea.

### 🔧 Preparación

- **Rama:** `incidente/05`
- **Caos:** `off`. Este bug es determinista y con caos encendido se confunde con
  el incidente 08: apágalo antes de empezar.
- **Datos:** el `db.json` de la fase, con al menos un usuario válido.

```bash
git checkout incidente/05
CHAOS_LEVEL=off npm run mock
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Hay dos lugares donde este sistema guarda la verdad sobre tu sesión, y todavía no
sabes si dicen lo mismo. Uno es el store: míralo en Redux DevTools después de
loguearte. El otro es lo que efectivamente sale por el cable: míralo en Network,
en **Request Headers** —no en Response—, de cualquier petición a una rifa.
Compáralos antes de abrir un archivo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/api/apiClient.js`. El interceptor de petición lee el token de algún lado.
No mires *qué* lee: mira **en qué momento de la vida del módulo** se ejecuta esa
lectura.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Cuántas veces se ejecuta el cuerpo de un módulo de JavaScript, y cuántas veces se
ejecuta la función que le pasas a `interceptors.request.use`? ¿Y qué había en el
store la única vez que corrió la primera?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados y exactos.}}

**Evidencia observable**
{{Los dos lados de la contradicción, uno al lado del otro: lo que dice
`state.auth.token` en Redux DevTools y lo que dice el header `Authorization` en
Network.}}

```
{{store: ...    ·    Request Headers: ...}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. ¿En qué capa vive: componente, store, epic, interceptor o mock?}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/api/apiClient.js`. El token se lee **en el cuerpo del módulo**, no dentro del
interceptor:

```javascript
// ❌ Esto corre UNA vez: cuando alguien importa este módulo por primera vez.
const token = store.getState().auth.token;

apiClient.interceptors.request.use((config) => {
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

El cuerpo de un módulo de JavaScript se evalúa una sola vez, en el primer
`import`. Y `apiClient` se importa cuando arranca la aplicación —mucho antes de
que exista un usuario—, así que `token` queda congelado en `null` para siempre. El
interceptor, en cambio, corre en **cada** petición… leyendo una variable que ya no
va a cambiar nunca.

De ahí la contradicción que la pista 1 te hace ver: el store tiene el token
correcto (el login funcionó, `auth/login/fulfilled` lo dejó ahí) y la petición
sale sin `Authorization`. Es el error común #1 de la Fase 2.

> 🧠 **La forma del bug, que vale más que el bug.** "Leí el valor una vez y lo
> guardé" es una familia entera de fallos, no un caso. Vas a reencontrarla en el
> incidente 04 con `useState`, y en el 19 con `useMemo`. Cambia la sintaxis, no el
> error: **capturar un valor que todavía no existe y no volver a preguntar.**

**Parche mínimo**

```javascript
apiClient.interceptors.request.use((config) => {
  // Ahora se lee en cada petición, que es cuando importa.
  const token = store.getState().auth.token;
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

**La refactorización correcta**

Que el interceptor no conozca el store. Un `getToken()` exportado por el módulo de
autenticación es el único que sabe dónde vive el token, y el día que se mueva a
`sessionStorage` —o a una cookie, o a un contexto— cambia un archivo y no diez:

```javascript
import { getToken } from '../features/auth/authService';

apiClient.interceptors.request.use((config) => {
  const token = getToken();
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

**Prueba de regresión**

```javascript
// src/api/apiClient.test.js
import apiClient from './apiClient';
import store from '../store';
import { loginSucceeded } from '../features/auth/authSlice';

test('el interceptor adjunta el token que hay en el store AHORA', async () => {
  // El cliente ya se importó (y con el bug, ya capturó null). Recién ahora
  // aparece la sesión: es exactamente el orden de la vida real.
  store.dispatch(loginSucceeded({ user: { id: 1 }, token: 'tok-123' }));

  const config = await apiClient.interceptors.request.handlers[0].fulfilled({
    headers: {},
  });

  expect(config.headers.Authorization).toBe('Bearer tok-123');
});
```

El detalle que hace útil este test es el **orden**: el módulo se importa antes del
login. Un test que despache el login primero pasa incluso con el bug adentro.

**Prevención**

Una regla de revisión concreta: `store.getState()` no se llama nunca en el nivel
superior de un módulo. Si aparece ahí, o está congelando un valor o está creando
una dependencia circular con el store; las dos cosas terminan mal.

**Por qué llegó a producción**

Por una optimización que nadie pidió. Leer el store en cada petición parecía
derrochador —"¿para qué preguntar mil veces lo mismo?"— y sacarlo afuera parecía
la versión limpia. Cuesta nanosegundos y compra correctitud. En un sistema con
sesión, **el estado es justamente lo que cambia**, y guardar una foto de algo que
cambia es la definición del bug.

Y sobrevivió porque el login sí funciona: la pantalla se ve bien, el nombre
aparece, no hay error rojo en ningún lado. Lo único roto está en un header que
nadie mira si no lo va a buscar.

**Si tu causa fue distinta a esta**

Si dijiste *"el backend no está validando bien el token"*, abre Request Headers:
el header no está. No se puede validar mal algo que no llegó. Si dijiste *"es
CORS"*, un fallo de CORS trae su propio mensaje en la consola y bloquea la
petición antes de que salga; acá la petición sale, llega y la rechazan con un
`401` bien formado. Y si tu fix fue guardar el token en una variable global que
el login actualiza, funciona — pero acabas de crear una segunda fuente de verdad
que se va a desincronizar del store el día que alguien despache `logout` sin
pasar por tu función.

</details>

---

## Incidente 06 — Cerré sesión pero la pantalla sigue mostrando mi usuario

> **Fase:** 2 · **Categoría:** Autenticación · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min

### 🎫 El ticket

Hago clic en "Cerrar sesión" y arriba a la derecha me sigue apareciendo mi nombre.
Si después hago clic en cualquier cosa me manda al login, pero el nombre sigue ahí
arriba, como si no me hubiera ido. Una vez, además, la pestaña se quedó titilando
sola y tuve que cerrarla a la fuerza. Me preocupa que en el kiosco compartido
quede la sesión de otro.

**Reportado por:** supervisor de ventas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir los dos síntomas —el nombre que se queda y el titileo— y decidir una
cosa antes de tocar código: **¿es un bug o son dos?** El entregable es esa
respuesta, con evidencia. Después, el fix de lo que corresponda.

Este incidente se resuelve mirando, no leyendo código. Si terminas con el editor
abierto antes de haber mirado Redux DevTools, vuelve atrás.

### 🔧 Preparación

- **Rama:** `incidente/06`
- **Caos:** `off`.
- **Datos:** el `db.json` de la fase. Loguéate con un usuario cuyo nombre se vea
  claramente en la barra superior.

```bash
git checkout incidente/06
CHAOS_LEVEL=off npm run mock
npm start
# Logueate, mira la barra superior, y recién ahí cierra sesión.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Redux DevTools, pestaña Redux. Cierra sesión con el panel abierto, selecciona la
acción que se despachó y abre la vista **Diff**. Esa vista te dice exactamente qué
claves del estado cambiaron. Cuéntalas y compáralas con las que *deberían* haber
cambiado.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Para el primer síntoma: el reducer de `logout` en `src/features/auth/authSlice.js`,
y qué campo lee la barra superior para pintar el nombre. Para el segundo: quién
envuelve la ruta `/login` en `src/App.jsx`. Son dos archivos distintos, y esa es
media respuesta.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si `selectIsAuthenticated` mira `token` y la barra superior mira `user`, ¿qué pasa
cuando el `logout` limpia uno solo de los dos? Y por separado: si `/login` exige
sesión para poder mostrarse, ¿a dónde te manda cuando no tienes sesión?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados para cada uno de los dos síntomas. Si uno de los dos no lo
lograste reproducir, dilo: puede que dependa de por dónde estabas navegando.}}

**Evidencia observable**
{{El *Diff* de Redux DevTools sobre la acción de logout, en texto.}}

```
{{qué claves cambiaron y cuáles no}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{¿Una o dos? Nómbralas por separado, con archivo y línea cada una.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Son **dos bugs distintos** que el mismo clic destapa, y confundirlos en uno solo
lleva a un fix que arregla la mitad.

**Bug A — el logout limpia de a un campo.** `src/features/auth/authSlice.js`:

```javascript
// ❌ Se limpió lo que hacía falta para "salir"… y nada más.
logout(state) {
  state.token = null;
}
```

`selectIsAuthenticated` mira `token`, así que la protección de rutas funciona
perfecto y te saca. Pero la barra superior lee `state.auth.user`, que sigue con
tus datos adentro. Dos consumidores del mismo estado, cada uno mirando una clave
distinta, y el logout solo se acordó de una. El *Diff* de DevTools lo muestra en
un segundo: una sola clave en verde.

Y la preocupación del supervisor es correcta y no es paranoia: en un kiosco
compartido, el nombre del vendedor anterior queda a la vista. No es una fuga de
datos grave, pero es exactamente el tipo de detalle por el que un cliente pierde
la confianza en un sistema.

**Bug B — el titileo.** `src/App.jsx`: la ruta `/login` quedó envuelta en
`PrivateRoute`. Sin sesión, `PrivateRoute` te redirige a `/login`… que exige
sesión… que te redirige a `/login`. Es el error común #2 de la Fase 2, y explica
por qué el nombre se queda **visible**: sin el bucle, el redirect es tan rápido que
apenas se alcanza a ver.

> 📝 **Nota de época.** El `authSlice` es de la Era 2 (2020-2021), escrito con
> Redux Toolkit por el equipo interno. Immer permite mutar el borrador campo por
> campo, y eso —que es una comodidad enorme— hace que "limpiar el estado" se
> escriba naturalmente como una lista de asignaciones. Cada campo nuevo que alguien
> agregue al slice de aquí en adelante nace olvidado en el logout.

**Parche mínimo**

```javascript
// authSlice.js — que no quede nada.
logout() {
  return initialState;
}
```

```javascript
// App.jsx — /login es pública, siempre.
<Route path="/login" component={LoginPage} />
```

**La refactorización correcta**

El parche de arriba **ya es** la corrección correcta para el bug A, y conviene
notarlo porque no siempre pasa: `return initialState` no arregla un campo, arregla
la familia entera —incluidos los campos que todavía no existen—. Cuando el parche
mínimo y el refactor coinciden, se aplica sin pensarlo.

Lo que sí queda pendiente es más grande y no se paga acá: **el estado de sesión no
sobrevive a un F5** (deuda 💸 de esta fase), así que hoy recargar la página es un
logout involuntario. La persistencia llega en la Fase 3, y con ella un tercer
hermano de este bug: limpiar el store y olvidarse del almacenamiento.

**Prueba de regresión**

```javascript
// src/features/auth/authSlice.test.js
import reducer, { logout, initialState } from './authSlice';

test('logout deja el estado exactamente como al principio', () => {
  const loggedIn = {
    ...initialState,
    user: { id: 7, name: 'Ana' },
    token: 'tok-123',
  };

  // Comparar contra initialState ENTERO, no campo por campo: así el test
  // también protege los campos que alguien agregue el año que viene.
  expect(reducer(loggedIn, logout())).toEqual(initialState);
});
```

**Prevención**

Dos reglas baratas. La primera: todo reducer que "limpia" devuelve el
`initialState` completo, nunca una lista de asignaciones. La segunda: un test que
recorra las rutas y verifique que `/login` no está envuelta en `PrivateRoute` —una
línea, y cierra para siempre una clase de bug que cuelga la pestaña del usuario.

**Por qué llegó a producción**

Porque el logout **cumple su objetivo**: te saca. Quien lo escribió probó lo que
había que probar —cerrar sesión y comprobar que ya no se puede entrar a una rifa—
y eso funciona. Nadie mira el resto del estado después de una acción que "anduvo".

El bucle de `/login` es de la misma familia: se agregó la protección de rutas de
una pasada, envolviendo todo lo que había, y `/login` cayó adentro por estar en la
misma lista. Es un error de copiar y pegar en un archivo de configuración, del
tipo que ninguna revisión de código detecta porque el diff se ve perfectamente
razonable.

**Si tu causa fue distinta a esta**

Si dijiste *"no se limpia el `localStorage`"*, en esta fase todavía no hay
persistencia —llega en la Fase 3—, así que no puede ser eso; pero si tu aplicación
ya la tiene porque avanzaste, acabas de encontrar el tercer hermano y vale la pena
anotarlo. Si dijiste *"falta un `window.location.reload()` después del logout"*,
funciona y es un martillazo: recargar la aplicación entera para limpiar dos campos
del store descarta también todo lo demás, y te va a morder en la Fase 4 cuando
haya un formulario abierto. Y si diagnosticaste solo uno de los dos bugs, no está
mal: quiere decir que reprodujiste uno solo. Vuelve y busca el otro.

</details>

---

## Incidente 07 — A veces no carga y no dice nada

> **Fase:** 3 · **Categoría:** Integración · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-50 min

### 🎫 El ticket

A veces no carga y no dice nada. Me pasa como una de cada cinco veces, no sé bien.
Abro la lista de rifas y me quedo mirando la pantalla, y no aparece nada: ni las
rifas ni un error ni un cartel ni nada. Si recargo, generalmente sale bien. A mi
compañera también le pasa pero menos.

**Reportado por:** vendedor de rifas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo **cuando tú quieras**, no cuando le toque al azar. Ese es el
entregable principal: un procedimiento determinista. Después, localizar la capa y
aplicar el fix.

> 🧭 **Este es el ticket vago canónico del curso**, y por eso conviene decir en voz
> alta lo que va a sonar raro: *"a veces"* y *"una de cada cinco"* son los dos
> datos **más valiosos** del reporte, no sus defectos. Una frecuencia es una pista
> sobre el mecanismo. Un reporte que dijera "no carga" a secas sería mucho peor.

### 🔧 Preparación

- **Rama:** `incidente/07`, que devuelve `apiClient` a una sola de sus opciones de
  creación. Es un cambio de una línea y no toca ningún componente.
- **Caos:** `CHAOS_LEVEL=high` en el mock del puerto `3001`. **Obligatorio.** Con
  `low` tarda mucho en aparecer y con `off` no aparece jamás.
- **Datos:** el `db.json` de la fase, con varias rifas cargadas.

```bash
git checkout incidente/07
CHAOS_LEVEL=high npm run mock
npm start
# Abre /raffles y recarga varias veces hasta que te toque.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes de la aplicación, mira **el mock**. "Una de cada cinco veces" es una
probabilidad, y hay un archivo en este proyecto donde esa probabilidad está
escrita y donde se decide qué tipo de fallo toca. Encontrarlo convierte el azar en
un interruptor.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Network, con la columna **Status** y la columna **Time** a la vista. Ordena por
Time y reproduce el fallo. Vas a encontrar una petición que no tiene status,
porque no terminó. Ahora la pregunta es de la otra orilla: ¿cuánto tiempo está
dispuesto a esperar el cliente?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Cuál es el valor por defecto de `timeout` en axios, y qué significa ese valor?
¿Y en qué estado se queda un `createAsyncThunk` cuya promesa nunca se resuelve ni
se rechaza?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Acá lo que se evalúa es que sea determinista. "Recargar hasta que pase" no es
un procedimiento de reproducción: es esperar.}}

**Evidencia observable**
{{La fila de Network de la petición que no termina, y el estado del store mientras
tanto.}}

```
{{status, time, y qué dice state.raffles.loading}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Ojo: puede que el archivo culpable sea uno donde *falta* algo.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Cómo se reproduce sin esperar al azar**

En `mock/server.js`, haz que el selector de fallo devuelva siempre el que te
interesa:

```javascript
// Temporalmente, para investigar. Revertir al terminar.
function pickFailureType() {
  return 'timeout';
}
```

Ahora el fallo es un interruptor. **Convertir "a veces" en "siempre" es la primera
mitad de cualquier investigación de intermitencias**, y casi nunca requiere tocar
la aplicación: requiere entender qué la rodea.

**Causa raíz**

El mock, con `CHAOS_LEVEL=high`, inyecta un fallo de tipo *timeout*: recibe la
petición y sencillamente **no responde nunca**. Del otro lado, `src/api/apiClient.js`
crea el cliente de axios sin la opción `timeout`, y el valor por defecto de axios
es `0`, que significa *esperar indefinidamente*.

La consecuencia en cadena: la promesa del `createAsyncThunk` no se resuelve ni se
rechaza, la acción `raffles/fetch/pending` queda como la última despachada,
`loading` se queda en `true` y `error` en `null`. La pantalla no muestra rifas
porque no llegaron, y no muestra un error porque —desde el punto de vista de la
aplicación— **no hubo ningún error: la petición sigue en curso**.

> 🧠 **El silencio no es un olvido, es un estado.** La lectura fácil de este bug es
> "la aplicación se olvidó de avisar". La correcta es que la aplicación está
> reportando fielmente lo que cree: que sigue cargando. El defecto no está en el
> mensaje que falta: está en que nadie decidió cuánto es demasiado.

Es el error común #2 de la Fase 3.

**Parche mínimo**

```javascript
// src/api/apiClient.js
const apiClient = axios.create({
  baseURL: process.env.REACT_APP_API_URL,
  timeout: 5000,   // pasado este punto, es un error y se trata como tal
});
```

Con eso axios aborta la petición con `ECONNABORTED`, el thunk cae en `rejected`,
`loading` vuelve a `false` y la pantalla puede mostrar el error que ya sabía
mostrar.

**La refactorización correcta**

Dos capas más, ninguna de las cuales se paga en esta fase:

1. Un interceptor de respuesta que traduzca `ECONNABORTED` a un mensaje que un
   vendedor entienda —"el servidor no respondió a tiempo, intenta de nuevo"— en
   vez del texto crudo de axios.
2. Reintento con espera creciente para las lecturas, que son idempotentes y se
   pueden repetir sin riesgo. Eso **no** se hace acá: requiere cancelación de
   verdad, y la cancelación de verdad es RxJS. Llega en la Fase 7, con `timer` y
   `takeUntil`.

**Prueba de regresión**

```javascript
// src/features/raffles/raffleSlice.test.js
import MockAdapter from 'axios-mock-adapter';
import apiClient from '../../api/apiClient';
import store from '../../store';
import { fetchRaffles } from './raffleSlice';

test('una petición que nunca responde termina en rejected, no colgada', async () => {
  const mock = new MockAdapter(apiClient);
  mock.onGet('/raffles').timeout();   // simula exactamente el caos del mock

  await store.dispatch(fetchRaffles());

  const state = store.getState().raffles;
  expect(state.loading).toBe(false);   // con el bug, se queda en true para siempre
  expect(state.error).not.toBeNull();
});
```

**Prevención**

El `timeout` va en la **creación del cliente**, no en cada llamada: puesto por
llamada, el primer endpoint que alguien agregue mañana nace sin él. Y toda
pantalla que cargue datos necesita tres estados dibujados, no dos: cargando,
error, y vacío. La mayoría de las pantallas legacy tienen dos, y el tercero es el
que se descubre en producción.

**Por qué llegó a producción**

Porque en desarrollo todo responde en tres milisegundos, y un `timeout` es
invisible mientras no haga falta. Pero el mecanismo de fondo merece un párrafo
propio: **este bug no se escribió, se dejó de escribir.** No hay una línea
equivocada que un revisor pudiera haber señalado; hay una opción ausente cuyo
valor por defecto —"esperar para siempre"— nadie eligió conscientemente. Los
errores de configuración por omisión son los más difíciles de encontrar en una
revisión de código, porque no aparecen en el diff.

Y llegó también porque el síntoma es amable: no hay pantalla roja, no hay
excepción, no hay nada en la consola. Solo un usuario esperando, que después de un
rato recarga y sigue trabajando. Nadie abre un ticket por eso hasta que pasa
cincuenta veces por día.

**Si tu causa fue distinta a esta**

Si dijiste *"el servidor está lento"*, mídelo: lento tiene un final, esto no lo
tiene. Deja la pestaña abierta diez minutos y la petición va a seguir ahí. Si
dijiste *"es un 500 que no se está manejando"*, el 500 del caos **sí** llega, sí
rechaza el thunk y sí deja rastro en la consola: es un fallo distinto del mismo
mock, y compararlos lado a lado es un ejercicio de veinte minutos que vale la
pena. Y si tu fix fue poner un `setTimeout` en el componente para mostrar un
cartel a los cinco segundos, tapaste el síntoma con precisión quirúrgica: la
petición sigue viva, sigue ocupando una conexión y va a resolver —o no— cuando se
le antoje, con el usuario ya en otra pantalla.

</details>

---

## Incidente 08 — Me saca a login al azar mientras estoy trabajando

> **Fase:** 3 · **Categoría:** Integración · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min
> · Hermano del incidente `be-08`, con otra causa raíz

### 🎫 El ticket

Estoy cargando una rifa nueva y de golpe me tira a la pantalla de login, sin
avisar nada. No pasa siempre, pasa de a ratos. Pierdo todo lo que había escrito y
tengo que empezar de nuevo. Vuelvo a entrar con la misma clave de siempre y entra
perfecto, así que mi usuario está bien. Alguien me dijo que "se cae la sesión",
pero no sé qué quiere decir eso.

**Reportado por:** vendedor de rifas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo de forma controlada y responder una pregunta incómoda: **¿es un bug
del sistema, o el sistema haciendo exactamente lo que debe?** Y si es lo segundo
—adelanto: en parte lo es—, decidir qué se arregla de todos modos.

### 🔧 Preparación

- **Rama:** ninguna; el comportamiento ya está en tu aplicación.
- **Caos:** `CHAOS_LEVEL=high` en `3001`. **Obligatorio**: el `401` aleatorio solo
  lo inyecta el caos alto sobre rutas protegidas.
- **Datos:** el `db.json` de la fase. Empieza el formulario de una rifa nueva y
  escribe algo antes de que te eche: parte del incidente es medir qué se pierde.

```bash
CHAOS_LEVEL=high npm run mock
npm start
# Abre el formulario de rifa nueva, escribe, y sigue navegando hasta que te saque.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Hay dos capas capaces de producir esto: la que **emite** el `401` y la que
**reacciona** al `401`. Empieza por la primera, y hazlo con la herramienta de la
Fase 2: agarra el `request-id` que el interceptor escribe en la consola y búscalo
en el log del mock. Vas a ver quién lo generó y por qué.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`mock/server.js`: el middleware de caos, la lista `PROTECTED_ROUTES` y el valor de
`CHAOS_LEVEL`. Después, y solo después, el interceptor de respuesta en
`src/api/apiClient.js`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el `401` es deliberado y correcto —y lo es—, entonces el defecto está en otra
parte. ¿Qué perdió exactamente el usuario, qué no se le dijo, y a dónde volvió
después de loguearse de nuevo?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, con el `CHAOS_LEVEL` que usaste. Anota también qué habías
escrito en el formulario antes de que te echara.}}

**Evidencia observable**
{{El `request-id` de la consola y su línea correspondiente en el log del mock.
Esos dos, juntos, son la prueba de quién emitió el `401`.}}

```
{{consola del navegador   ·   log del mock}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Y una respuesta explícita: ¿el sistema se equivocó, o hizo lo correcto?}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El `401` lo inyecta a propósito el middleware de caos de `mock/server.js` sobre las
rutas de `PROTECTED_ROUTES`, para simular un token vencido. Eso **no es el bug**:
es la Fase 3 haciendo su trabajo, y es el error común #3 de esa fase. Un backend
real hace exactamente lo mismo cuando la sesión expira.

El defecto está una capa más allá, en cómo reacciona el interceptor de respuesta:
despacha `logout`, redirige a `/login` y ahí termina su participación. No dice por
qué, no recuerda a dónde ibas, y no hace nada con lo que estabas escribiendo.

> 🧠 **El sistema detectó bien y comunicó mal.** Es una distinción que vale para
> toda tu carrera: la detección y la comunicación son dos responsabilidades
> separadas, y la segunda casi nunca se prueba. Un `401` correctamente manejado que
> deja al usuario sin explicación y sin su trabajo sigue siendo un incidente,
> aunque cada línea de código haga lo que dice.

> 📝 **Nota de época.** El interceptor global es de la Era 2 (2020-2021). Entonces
> la sesión duraba ocho horas y un `401` inesperado era tan raro que ocuparse de
> "avisar bien" parecía sobre-ingeniería. La suposición no era tonta: era correcta
> para el mundo de 2020, y dejó de serlo cuando el sistema empezó a vivir en un
> kiosco con red mala.

**Parche mínimo**

Que el redirect lleve el motivo y el origen:

```javascript
// src/api/apiClient.js — en el interceptor de respuesta, ante un 401.
store.dispatch(logout());
history.replace('/login', {
  reason: 'session-expired',
  from: history.location.pathname,
});
```

Y que `LoginPage` lea ese estado: muestra *"Tu sesión venció. Vuelve a entrar."* en
vez de un formulario mudo, y después del login te devuelve a `from` en lugar de
dejarte en el inicio. Son unas diez líneas entre los dos archivos, y cambian por
completo la experiencia de un fallo que va a seguir ocurriendo.

**La refactorización correcta**

No perder el trabajo. Antes de redirigir, el borrador del formulario se guarda —en
el store o en `sessionStorage`— y se restituye al volver. Es más código y más
casos límite, y por eso no se paga en esta fase; pero es lo que convierte un
`401` de catástrofe en molestia.

Y una distinción que hoy el sistema no hace: **un `401` de credenciales
equivocadas y un `401` de sesión vencida no son lo mismo** y no merecen el mismo
mensaje. El primero es culpa de quien escribe; el segundo, de nadie.

**Prueba de regresión**

```javascript
// src/api/apiClient.test.js
test('un 401 informa el motivo y de dónde venías', async () => {
  const mock = new MockAdapter(apiClient);
  mock.onGet('/raffles').reply(401);
  history.push('/raffles/7/numbers');

  await apiClient.get('/raffles').catch(() => {});

  expect(store.getState().auth.token).toBeNull();
  expect(history.location.pathname).toBe('/login');
  expect(history.location.state).toEqual({
    reason: 'session-expired',
    from: '/raffles/7/numbers',
  });
});
```

**Prevención**

Una regla de una línea, y sorprendentemente rara: **ningún redirect automático sin
motivo**. Si el sistema mueve al usuario de pantalla por su cuenta, tiene que
poder explicar por qué. Y un único lugar que maneje el `401` —el interceptor—, para
que la explicación no dependa de qué componente disparó la petición.

**Por qué llegó a producción**

Porque *"te saca a login"* **es** el comportamiento correcto, y por eso nadie lo
revisó nunca. Los defectos que viven adentro de un comportamiento correcto son los
más difíciles de ver: no hay excepción, no hay log rojo, no hay test en rojo. Solo
un usuario que perdió veinte minutos de trabajo y que, encima, no tiene vocabulario
para reportarlo —fíjate que el ticket dice *"alguien me dijo que se cae la sesión,
pero no sé qué quiere decir eso"*—.

**Si tu causa fue distinta a esta**

Si dijiste *"el token está mal generado"* o *"el interceptor de la Fase 2 no
adjunta el token"*, eso es el incidente 05, y se descarta en un segundo: apaga el
caos con `CHAOS_LEVEL=off` y el síntoma desaparece por completo. Si desaparece, era
el caos; si persiste, era el token.

**Y acá vive el cruce con el track BE.** El incidente `be-08` —*"a algunos los saca
de la sesión al mediodía y a otros nunca"*— tiene este mismo síntoma con otra causa
raíz: allá el `401` es **real**, lo produce un `exp` de JWT sin renovación, y por
eso el fallo tiene **patrón horario**. Esa es la forma de distinguirlos en la vida
real: si las expulsiones se concentran en una franja del día, sospecha de
expiración; si están repartidas uniformemente, sospecha de fallo aleatorio o de
infraestructura. Un mismo síntoma, dos capas, dos investigaciones distintas.

</details>

---

## Incidente 09 — Guardo la rifa, se recarga la página y pierdo todo

> **Fase:** 4 · **Categoría:** Estado (store) · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-30 min

### 🎫 El ticket

Cargo la rifa nueva con todos los datos, le doy a "Guardar" y la pantalla
parpadea y se me borra todo el formulario. Vuelvo a la lista y la rifa no está.
Es como si se reiniciara el programa entero. Lo raro es que a veces, si vuelvo un
rato después, la rifa sí está cargada. Ya la creé tres veces por las dudas y
ahora tengo dos repetidas.

**Reportado por:** supervisor de ventas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar la línea y aplicar el fix. Y como ejercicio aparte:
explicar por qué el síntoma que reporta el usuario —"se borró todo"— no se parece
en nada a la causa, y por qué las rifas duplicadas son consecuencia del mismo bug.

### 🔧 Preparación

- **Rama:** `incidente/09`
- **Caos:** `off`. Con caos encendido el ruido de los fallos aleatorios tapa la
  señal, que acá es limpísima.
- **Datos:** el `db.json` de la fase. Llena el formulario entero antes de guardar:
  parte del incidente es ver qué se pierde.

```bash
git checkout incidente/09
CHAOS_LEVEL=off npm run mock
npm start
# /raffles → "Nueva rifa" → llena todo → Guardar
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Network, con *Preserve log* marcado —sin eso no vas a ver nada, porque justamente
se limpia—. Guarda la rifa y cuenta las peticiones. Además de tu `POST`, hay otra.
Mira su **método** y su **tipo**, y mira la barra de direcciones del navegador
justo después de guardar.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/raffles/RaffleForm.jsx`, y en particular las dos primeras líneas de
`handleSubmit`. Comparalo con cualquier otro `handleSubmit` que hayas escrito.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué hace un `<form>` de HTML cuando alguien lo envía y nadie se lo impide? Esa
pregunta no es sobre React: es sobre el navegador, y ahí está la respuesta.

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Anota qué había en la barra de direcciones antes y después de
hacer clic en Guardar: es la evidencia más contundente de este incidente.}}

**Evidencia observable**
{{Las peticiones de Network con *Preserve log*, y la URL resultante.}}

```
{{método, tipo y URL de cada petición}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/features/raffles/RaffleForm.jsx`: `handleSubmit` no llama a
`e.preventDefault()`.

```javascript
// ❌ El thunk sale… y el navegador hace lo suyo al mismo tiempo.
function handleSubmit(e) {
  dispatch(createRaffle(form));
}
```

Un `<form>` de HTML, si nadie lo detiene, envía sus campos por su cuenta: el
navegador arma una petición de documento a la misma URL con los valores en el
*query string*, la ejecuta y **recarga la página entera**. React se desmonta, el
store —que vive en memoria y no se persiste— se vacía, y el formulario vuelve en
blanco. Es el error común #4 de la Fase 4.

La evidencia definitiva está en la barra de direcciones: después de guardar dice
algo como `/raffles/new?name=Rifa+de+Navidad&closesAt=2024-12-20`. Los datos del
usuario, ahí a la vista. Nunca se "borraron": se fueron a la URL.

> 🧠 **Por qué el síntoma no se parece a la causa.** El usuario reporta "se borró
> todo", que suena a un problema de guardado o de estado. La causa es una llamada
> ausente en un manejador de eventos, tres capas más abajo, que ni siquiera es de
> React. Este incidente es corto a propósito, y aun así es de los más formativos
> del cuaderno: **la distancia entre lo que el usuario describe y donde vive la
> causa es la razón de ser de todo este oficio.**

Y las rifas duplicadas son el mismo bug: el `POST` del thunk **sí sale**, y a veces
alcanza a completarse antes de que la recarga lo cancele. De ahí el "a veces sí
está" del ticket. El usuario, viendo la pantalla en blanco, vuelve a cargarla, y
la segunda también entra. Es una carrera entre tu petición y el navegador
descargando la página de abajo.

**Parche mínimo**

```javascript
function handleSubmit(e) {
  e.preventDefault();          // el navegador no tiene nada que hacer acá
  dispatch(createRaffle(form));
}
```

**La refactorización correcta**

El parche es correcto y suficiente, pero se reintroduce solo: cada formulario
nuevo nace con la misma posibilidad de olvidarlo. Lo que cierra la puerta es que
nadie tenga que acordarse — un componente `<Form onSubmit={…}>` propio, que llame
al `preventDefault` y delegue después:

```javascript
// src/components/Form.jsx
export function Form({ onSubmit, children, ...rest }) {
  return (
    <form
      onSubmit={(e) => { e.preventDefault(); onSubmit(e); }}
      {...rest}
    >
      {children}
    </form>
  );
}
```

**Prueba de regresión**

```javascript
// src/features/raffles/RaffleForm.test.jsx
import { render, screen, fireEvent, createEvent } from '@testing-library/react';

test('el submit no deja que el navegador recargue', () => {
  render(<RaffleForm />);
  const form = screen.getByTestId('raffle-form');

  const submitEvent = createEvent.submit(form);
  fireEvent(form, submitEvent);

  // Con el bug, defaultPrevented es false y el navegador se lleva la página.
  expect(submitEvent.defaultPrevented).toBe(true);
});
```

**Prevención**

Una regla de lint de las que valen la pena: prohibir `<form>` sin `onSubmit`, y
prohibir un `onSubmit` cuyo cuerpo no empiece con `preventDefault` —salvo que use
el componente `Form` de arriba—. Es de los pocos errores que una herramienta puede
detectar con certeza absoluta.

**Por qué llegó a producción**

Por una historia banal que se repite en todos lados: durante el desarrollo el
botón "Guardar" era un `<button type="button">` con un `onClick`, y funcionaba
perfecto. Después alguien pidió que se pudiera enviar con Enter, se cambió a
`type="submit"` —que es la forma correcta y accesible de hacerlo— y nadie volvió a
probar el flujo completo, porque "solo cambié el tipo de un botón". El cambio de
una palabra activó un comportamiento del navegador que llevaba dormido desde 1995.

**Si tu causa fue distinta a esta**

Si dijiste *"el thunk no está guardando"*, mira Network: el `POST` sale y a veces
hasta responde `201`. Si dijiste *"falta persistir el store"* tienes razón en que
es una deuda real —el store no sobrevive a un F5 y eso se paga en otra parte—,
pero no es la causa: sin la recarga, no habría nada que persistir. Y si tu fix fue
`window.location.reload()` después de guardar para "refrescar la lista", acabas de
convertir el bug en una funcionalidad.

</details>

---

## Incidente 10 — La lista de rifas se queda cargando para siempre

> **Fase:** 4 · **Categoría:** Estado (store) · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min

### 🎫 El ticket

Reenvío lo que nos llegó de tres vendedores distintos esta semana: la lista de
rifas se queda con el cartel de "Cargando rifas…" y ahí se queda, para siempre. Hay
que recargar. Yo lo probé diez veces en mi máquina y anda perfecto, así que no sé
si están exagerando o si hay algo raro en las máquinas del kiosco.

**Reportado por:** soporte, reenviando reportes de UAT
**Ambiente:** UAT (en desarrollo "no pasa")

### 🎯 Qué se te pide

Este incidente tiene **dos entregables, en orden**, y el primero es el que casi
nadie practica.

1. **Decidir si se reproduce, con evidencia.** Si con lo que tienes montado no
   pasa, el resultado legítimo es cerrarlo en ⚪ *Descartado* con un reporte que
   diga qué probaste, cuántas veces, en qué condiciones, y —lo más importante—
   **qué le preguntas a quien lo reportó**. Escribe ese reporte de verdad, aunque
   te dé pereza: es el entregable.
2. **Recién después**, encontrar la condición que lo despierta, reabrirlo y
   arreglarlo.

> 🧭 **"No se reproduce" es una conclusión, no una excusa** — pero solo si viene
> con la evidencia y con la pregunta de vuelta. Sin eso es un encogimiento de
> hombros, y es la forma más común de que un incidente real muera sin resolverse.

### 🔧 Preparación

- **Rama:** `incidente/10`, y trae **un solo** `addCase` de menos en el slice de
  rifas. Los otros tres thunks quedan intactos: esa asimetría es parte del
  material con el que vas a trabajar.
- **Caos:** empieza en `off` **a propósito**, que es donde vive la primera mitad
  de la lección. La segunda mitad necesita `high`.
- **Datos:** el `db.json` de la fase, con varias rifas.

```bash
git checkout incidente/10
CHAOS_LEVEL=off npm run mock     # primera vuelta: intenta reproducirlo así
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Si con el caos apagado no lo reproduces, la pregunta no es *"¿dónde está el bug?"*
sino *"¿qué tiene el ambiente de ellos que el mío no tiene?"*. Enumera las
diferencias entre tu máquina y un kiosco de UAT antes de abrir un archivo: red,
datos, uso simultáneo, configuración del mock.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Con `CHAOS_LEVEL=high`, abre Redux DevTools y recarga hasta que la carga falle.
Mira la última acción despachada y su panel **Diff**: te va a decir qué pasó con
`loadingList` y qué pasó con `error`. Una de las dos cosas no pasó.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un `createAsyncThunk` genera tres acciones. ¿Cuántas de las tres tiene registradas
el `extraReducers` de `raffleSlice`?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Primero el intento fallido, con sus condiciones y su número de intentos. Después,
si llegaste, el procedimiento que sí lo despierta. Los dos: el primero es tan
entregable como el segundo.}}

**Tu reporte de "no reproduce"**
{{Escríbelo como se lo mandarías a soporte: qué probaste, con qué configuración,
cuántas veces, y qué tres datos necesitas de quien lo reportó.}}

**Evidencia observable**
{{El Diff de la última acción, y el valor de `loadingList` después de ella.}}

```
{{acción, y qué cambió}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Ojo: puede que lo culpable sea algo que no está escrito.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Por qué no se reproduce en desarrollo**

Porque el ambiente de desarrollo **no falla nunca**. Con `CHAOS_LEVEL=off` el mock
responde siempre `200`, y el camino de código que tiene el bug es el que solo se
recorre cuando algo sale mal. Una rama que únicamente se ejecuta ante un fallo, en
un ambiente donde nunca hay fallos, es una rama que **jamás se ejecutó** — ni
siquiera una vez, ni durante el desarrollo ni durante la revisión.

Ese es el motivo por el que la Fase 3 construyó un mock que falla a propósito. No
es una excentricidad didáctica: es la única forma de que ese código exista de
verdad antes de que un usuario lo descubra.

**Causa raíz**

`src/features/raffles/raffleSlice.js`: el `extraReducers` registra `pending` y
`fulfilled`, y no registra `rejected`.

```javascript
// ❌ Dos de tres. La que falta es justo la del día malo.
extraReducers: (builder) => {
  builder
    .addCase(fetchRaffles.pending,   (state) => { state.loadingList = true; })
    .addCase(fetchRaffles.fulfilled, (state, action) => {
      state.loadingList = false;
      state.items = action.payload;
    });
}
```

Cuando el mock devuelve `500`, el thunk despacha `raffles/fetch/rejected`,
nadie la escucha, `loadingList` se queda en `true` y la pantalla sigue mostrando
"Cargando rifas…" indefinidamente. Es el error común #1 de la Fase 4, y la fase lo
llama "el más común y el más caro".

**Parche mínimo**

```javascript
.addCase(fetchRaffles.rejected, (state, action) => {
  state.loadingList = false;
  state.error = action.payload ?? 'No pudimos cargar las rifas.';
});
```

La Fase 4 es explícita sobre cómo llamar a esto: **no es un refactor, es completar
el thunk**. Un thunk con dos de sus tres estados manejados está a medio escribir.

**La refactorización correcta**

Que olvidarse deje de ser posible. Un ayudante que registre los tres casos de
cualquier thunk de una sola vez:

```javascript
// src/store/registerThunk.js
export function registerThunk(builder, thunk, { loadingKey, onSuccess }) {
  builder
    .addCase(thunk.pending,   (s) => { s[loadingKey] = true; s.error = null; })
    .addCase(thunk.fulfilled, (s, a) => { s[loadingKey] = false; onSuccess(s, a); })
    .addCase(thunk.rejected,  (s, a) => { s[loadingKey] = false; s.error = a.payload; });
}
```

Con eso, el `rejected` no se olvida porque no se escribe.

**Prueba de regresión**

```javascript
// src/features/raffles/raffleSlice.test.js
test('un 500 apaga el loading y deja un error legible', async () => {
  const mock = new MockAdapter(apiClient);
  mock.onGet('/raffles').reply(500);

  await store.dispatch(fetchRaffles());

  const state = store.getState().raffles;
  expect(state.loadingList).toBe(false);   // con el bug: true, para siempre
  expect(state.error).toBeTruthy();
});
```

**Prevención**

El ayudante de arriba, y una prueba por thunk que ejercite el camino del fallo. La
regla general, que vale más que este caso: **todo estado de carga necesita un test
que lo apague**. Encenderlo lo prueba el camino feliz solo; apagarlo, nunca.

**Por qué llegó a producción**

Por la razón que el propio ticket deja escrita sin querer: *"yo lo probé diez veces
en mi máquina y anda perfecto"*. Esa frase suele leerse como pereza, y casi nunca
lo es — acá describe un hecho técnico exacto: **el ambiente donde se programa no
produce las condiciones donde vive el bug**. Diez intentos en desarrollo son diez
recorridos por el mismo camino feliz.

Y el segundo motivo es cultural: cerrar el ticket cuando la funcionalidad "anda"
es lo que se premia. Escribir la rama del error cuesta cinco minutos, no se ve en
la demostración, y nadie la agradece hasta el día que salva un turno entero.

**Si tu causa fue distinta a esta**

Si dijiste *"el backend no responde"*, ese es el **incidente 07**, y se distinguen
en un vistazo a Network: en el 07 hay una petición **sin status**, todavía
pendiente, que nunca termina; acá la petición **terminó**, con un `500` bien
visible en rojo. Mismo síntoma en la pantalla —una espera que no acaba—, dos
lugares totalmente distintos. Tener los dos en el cuaderno y saber separarlos con
una sola columna de DevTools es exactamente el músculo que este curso entrena.

Si dijiste *"falta un `try/catch` en el componente"*, el componente no es el
problema: está pintando fielmente un `loadingList` que dice `true`. Y si tu fix
fue un `setTimeout` que apaga el cargando a los diez segundos, escondiste el error
y además le mentiste al usuario: la carga no terminó, se rindió en silencio.

</details>

---

## Incidente 11 ⭐ — Vendimos el número 0347 dos veces

> **Fase:** 5 · **Categoría:** Concurrencia · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 70-90 min
> ⭐ Uno de los dos incidentes más formativos del curso · Hermano del incidente `be-09`, con otra causa raíz

### 🎫 El ticket

Tenemos dos comprobantes del número 0347 de la Rifa de Navidad, a nombre de dos
personas distintas, emitidos con dos minutos de diferencia. Los dos pagaron y los
dos tienen su papel. El sorteo es el viernes. Necesito saber qué pasó, si hay más
números en la misma situación, y a cuál de los dos señores le vamos a tener que
explicar que su número no vale.

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir la secuencia **en el store** —no en el backend—, nombrarla, y separar
con claridad el parche mínimo del fix correcto. En este incidente los dos no viven
en la misma fase, y esa es media lección.

Y una advertencia que conviene leer antes de empezar: es tentador concluir que el
backend aceptó dos ventas. **Verifícalo antes de creerlo.** Si esa hipótesis
resulta falsa —y lo va a ser—, el lugar donde vive la causa cambia por completo.

### 🔧 Preparación

- **Rama:** `incidente/11`
- **Caos:** `CHAOS_LEVEL=high`. Hace falta latencia: sin ella la ventana entre las
  dos ventas es demasiado angosta para que la aciertes con el mouse.
- **Datos:** la Rifa de Navidad (`id: 1`) en estado `open`, con el número `0347` en
  `reserved`. La rama lo deja así.
- **Además:** dos pestañas del navegador sobre el mismo tablero. No hace falta que
  sean usuarios distintos; alcanza con que sean dos operaciones simultáneas.

```bash
git checkout incidente/11
CHAOS_LEVEL=high npm run mock
npm start
# Dos pestañas en /raffles/1/numbers. Vender el 0347 en las dos, casi a la vez.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No abras el código todavía. Reproduce con las dos pestañas, y después lee la lista
de acciones de Redux DevTools **de arriba abajo, entera**, como si fuera el
extracto de una cuenta bancaria donde falta plata. La secuencia completa te cuenta
la historia sin que tengas que interpretarla.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Hay una acción, casi al final de la secuencia, que **revierte algo que otra acción
ya había confirmado**. Selecciónala y usa *time-travel* para pararte justo antes:
mira en qué estado estaba el número `0347` en ese instante exacto, y compáralo con
el valor al que la acción lo está devolviendo.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`rollbackSale` recibe un `previousStatus`. ¿En qué momento se capturó ese valor, y
qué le pasó al número entre esa captura y el instante en que el rollback se
ejecuta?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados y exactos: qué rifa, qué número, en qué estado de partida, con
qué `CHAOS_LEVEL`, y cuánta separación hubo entre los dos clics. Si tardaste
varios intentos, anota cuántos: la frecuencia es parte de la descripción de una
carrera.}}

**Evidencia observable**
{{La secuencia completa de acciones de Redux DevTools, en texto, con el payload de
cada una. Es la prueba central de este incidente; sin ella no hay diagnóstico.}}

```
{{la secuencia de acciones, en orden}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó. Anota especialmente si
  pasaste por "el backend aceptó las dos" y cómo la descartaste}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y en qué capa vive: componente, store, epic, interceptor o mock.}}

**Tu fix**
{{El parche mínimo del viernes a las seis. Aparte, la refactorización correcta, y
por qué no se puede hacer todavía.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Lo primero: el backend se defendió bien**

Antes que nada, la hipótesis que hay que descartar. Mira el log del mock: la
segunda venta recibió un **`409`**. El servidor detectó el conflicto y lo rechazó,
tal como la Fase 5 lo diseñó. **El backend hizo su trabajo.**

Eso reubica la investigación entera. No estamos buscando por qué el servidor
aceptó dos ventas: estamos buscando por qué, habiéndolas rechazado correctamente,
igual terminaron existiendo dos comprobantes.

**Causa raíz**

La secuencia, tal como se lee en Redux DevTools:

```
sales/sellNumber/pending
numberSoldOptimistic     { number: '0347' }      ← pestaña A pinta sold
sales/sellNumber/pending
numberSoldOptimistic     { number: '0347' }      ← pestaña B, sin guarda de origen
sales/sellNumber/fulfilled                       ← A ganó: venta real, confirmada
sales/sellNumber/rejected  { type: 'conflict' }  ← B perdió: el 409
rollbackSale  { number: '0347', previousStatus: 'reserved' }   ← ⚠️ acá
```

Son dos defectos encadenados, y el segundo es el grave.

**El primero**, cosmético: `numberSoldOptimistic` asigna `sold` sin verificar el
estado de origen. La pestaña B repinta un número que ya estaba vendido. Es el
error común #1 de la Fase 5 y por sí solo no habría causado el incidente.

**El segundo**, el que produce los dos comprobantes: `rollbackSale` revierte al
`previousStatus` que se capturó **antes** de que existiera la venta ganadora. Para
cuando el rollback se ejecuta, el `0347` ya estaba vendido de verdad, con
confirmación del servidor — y el rollback lo devuelve a `reserved` igual, pisando
una venta legítima. Es el error común #2 de la fase.

Y ahí nace el segundo comprobante: la UI vuelve a mostrar el `0347` como
disponible para reservar. Alguien lo vende otra vez, esta vez sin carrera y sin
`409`, porque han pasado dos minutos y el backend… también lo rechaza. Pero el
vendedor ya imprimió el papel mirando la pantalla.

> 🧠 **Lo que hay que llevarse.** El fallo no fue no detectar el conflicto: fue
> **deshacer la detección**. El sistema tenía la información correcta y la
> descartó al revertir a ciegas. En concurrencia, el rollback es tan peligroso como
> la operación que revierte, y casi nunca se le presta la mitad de atención.

> 📝 **Nota de época.** Esto es de la Era 2 (2020-2021), y
> `00-historia-del-sistema.md` §3 lo nombra sin rodeos: cuando la venta pasó de un
> kiosco a tres, aparecieron los números vendidos dos veces, y la solución de
> entonces fue optimista —pintar al instante y revertir si el servidor protesta—.
> Funciona el 99% de las veces. Este incidente es el 1% restante, y no fue una
> mala decisión: fue una decisión correcta con un caso límite mal cerrado.

**Parche mínimo**

Que el `fulfilled` deje constancia de que la venta fue confirmada, y que el
rollback la respete:

```javascript
// saleSlice.js
[sellNumber.fulfilled]: (state, action) => {
  const { number } = action.payload;
  state.byNumber[number] = 'sold';
  state.confirmed[number] = true;        // esta venta la ratificó el servidor
},

rollbackSale(state, action) {
  const { number, previousStatus } = action.payload;
  // No se revierte lo que otro actor ya confirmó.
  if (state.confirmed[number]) return;
  state.byNumber[number] = previousStatus;
},
```

Y la guarda de origen, que es de una línea y cuesta nada:

```javascript
numberSoldOptimistic(state, action) {
  const { number } = action.payload;
  if (state.byNumber[number] !== 'reserved') return;   // solo desde reserved
  state.byNumber[number] = 'sold';
},
```

**La refactorización correcta** (que en este curso no se paga en esta fase)

No revertir localmente: cuando llega un `409`, el cliente no sabe cuál es el estado
verdadero del número, así que **no debería inventarlo**. Lo correcto es
re-sincronizar ese número desde el servidor y pintar lo que el servidor diga. Un
`409` no es "volvé a como estabas": es "tu foto del mundo está vieja".

Y estructuralmente hay dos piezas más, ninguna disponible todavía:

1. **Cancelar la operación perdedora en el origen**, con un `switchMap` por número
   en un epic. Eso es Fase 6, y es la razón por la que este incidente se enuncia en
   la 5 y termina de entenderse en la 6.
2. **La unicidad garantizada por el servidor**: un índice único y una transacción,
   que es lo único que cierra la ventana de verdad. Eso es el track BE (`be05`), y
   es también el incidente hermano.

> 🧭 **Y la conclusión honesta, que conviene decir en voz alta:** ninguna guarda en
> el frontend elimina esta carrera. La achica. La ventana entre "leí el estado" y
> "escribí el estado" existe en cuanto hay dos clientes, y solo se cierra donde hay
> un único árbitro. Todo lo que hagas acá es mitigación.

**Prueba de regresión**

```javascript
// src/features/sales/saleSlice.test.js
test('el rollback del perdedor no pisa la venta confirmada del ganador', () => {
  let state = reducer(undefined, setNumberStatus({ number: '0347', status: 'reserved' }));

  state = reducer(state, numberSoldOptimistic({ number: '0347' }));   // A
  state = reducer(state, numberSoldOptimistic({ number: '0347' }));   // B
  state = reducer(state, sellNumber.fulfilled({ number: '0347' }));   // A gana
  state = reducer(state, rollbackSale({ number: '0347', previousStatus: 'reserved' })); // B

  expect(state.byNumber['0347']).toBe('sold');   // con el bug: 'reserved'
});
```

Es un test de reducer puro, sin red y sin componentes: la secuencia exacta que
viste en DevTools, escrita como código. Reproducir una carrera de forma
determinista es difícil en la aplicación y trivial en el reducer, y ese es el
argumento más fuerte a favor de mantener la lógica de estado separada de la UI.

**Prevención**

Una máquina de estados explícita, con las transiciones permitidas declaradas en un
solo lugar, en vez de asignaciones sueltas repartidas por el slice:

```javascript
const ALLOWED = {
  available: ['reserved'],
  reserved:  ['sold', 'available'],
  sold:      [],                      // vendido es terminal: de acá no se vuelve
};
```

Con `sold` declarado como estado terminal, **el bug es inexpresable**: el rollback
no tiene a dónde ir. Es más código que la guarda, y a cambio protege también los
caminos que todavía no existen.

**Por qué llegó a producción**

Porque el camino que falla necesita tres condiciones simultáneas —dos actores, el
mismo número, y latencia suficiente para que las respuestas se crucen— y ninguna
de las tres ocurre en la máquina de quien programa. Con un kiosco no pasaba nunca;
con tres empezó a pasar, y para entonces el código llevaba un año funcionando y
nadie lo miraba.

Y hay una causa más de fondo, que no es de este código sino del proyecto: **no hay
tests**. La Era 1 no dejó ninguno (`00-historia-del-sistema.md` §3), y sin una
suite donde escribir la secuencia de arriba, la única forma de descubrir esta
carrera es que la sufra tesorería.

El análisis no es sobre quien escribió el rollback. Un rollback a ciegas es el
comportamiento razonable por defecto y está en la mitad de los tutoriales de
actualización optimista que había en 2020.

**Si tu causa fue distinta a esta**

Si concluiste *"el backend aceptó dos ventas"*, el log del mock lo desmiente: hay
un `409`. Es la hipótesis más natural del mundo y descartarla con evidencia, en
vez de asumirla, es la mitad del valor de este incidente.

Si tu fix fue **bloquear el botón de vender mientras hay una venta en curso**,
funciona para las dos pestañas del mismo navegador y no hace nada contra dos
kioscos distintos, que es el caso real del ticket. Tapaste el síntoma en la capa
de la UI.

**Y acá está el cruce más importante del curso.** El incidente `be-09` del track BE
—*"vendimos tres números dos veces, y solo los redondos"*— tiene el mismo síntoma y
la causa **opuesta**: allá el backend **no** se defiende, porque falta el índice
único, y las dos ventas entran de verdad en la base. Acá el backend se defiende
bien y el frontend arruina la defensa. Mismo comprobante duplicado, dos culpables
en orillas contrarias del cable. Si vas a hacer el track BE, resolver estos dos en
pareja enseña más sobre concurrencia que cualquier explicación.

</details>

---

## Incidente 12 — Un número que ya estaba vendido volvió solo a disponible

> **Fase:** 5 · **Categoría:** Concurrencia · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min

### 🎫 El ticket

Un número que ya estaba vendido volvió solo a disponible. Nadie lo tocó, yo estaba
mirando la pantalla. Estaba pintado como vendido y al rato apareció otra vez en
blanco, como si nunca lo hubieran comprado. Fue en la Rifa de Navidad. Y me parece
que también lo vi en otra rifa el martes, pero no estoy seguro.

**Reportado por:** vendedor de rifas
**Ambiente:** UAT

### 🎯 Qué se te pide

**Dos causas distintas producen exactamente este síntoma.** El entregable de este
incidente no es el parche: es determinar cuál de las dos estás viendo, con la
evidencia que descarta la otra. El fix, una vez que sabes cuál es, es de una línea
en ambos casos.

Y no ignores la última frase del ticket —*"me parece que también lo vi en otra
rifa"*—. Los vendedores suelen disculparse por lo que no recuerdan bien; ese detalle
inseguro es, en este incidente, el que más información trae.

### 🔧 Preparación

- **Rama:** `incidente/12`
- **Caos:** `low`. Con `high` se mezclan los fallos de venta y cuesta separar las
  dos causas; con `off` no se reproduce una de ellas.
- **Datos:** dos rifas en `open`, la 1 y la 2, cada una con algún número en
  `reserved` y alguno en `sold`. La rama las deja así.
- **Y algo que no es un dato sino una instrucción:** parte del procedimiento es
  **esperar sin tocar nada**. Deja el tablero quieto varios minutos.

```bash
git checkout incidente/12
CHAOS_LEVEL=low npm run mock
npm start
# Reserva un número en la rifa 1, navega a la rifa 2, y espera mirando DevTools.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Redux DevTools abierto, y paciencia: deja de interactuar con la aplicación durante
unos minutos, mirando la lista de acciones. Si aparece una acción que **nadie
pidió**, ya sabes por dónde va. Y mira Network al mismo tiempo: si esa acción no
tiene ninguna petición al lado, nació dentro del navegador.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El **payload** de esa acción huérfana: ¿de qué rifa habla? Compáralo con la rifa
que tienes en pantalla. Y en el otro camino: ¿qué acción viene inmediatamente
después de un `sellNumber/rejected`?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Una de las dos causas llega **tarde, desde otro lado**; la otra llega **a tiempo,
con información vieja**. Una aparece en silencio minutos después; la otra, al
instante de una venta fallida. ¿Cuál de las dos viste?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, incluyendo cuántos minutos esperaste y en qué rifa estabas
parado cuando apareció el síntoma. Ese último dato decide el diagnóstico.}}

**Evidencia observable**
{{La acción huérfana con su payload completo, y si hubo o no una petición en
Network en ese mismo instante.}}

```
{{acción, payload, y qué había en Network}}
```

**Hipótesis**
- ❌ Descartada: {{cuál de las dos causas descartaste, y con qué evidencia}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Las dos causas, y cómo se separan**

**Causa A — el temporizador que sobrevivió al desmontaje.** El `setTimeout` que
expira una reserva se crea en el `useEffect` del tablero y no se cancela al
desmontarlo. Navegas de la rifa 1 a la rifa 2, el temporizador de la rifa 1 sigue
vivo y minutos después dispara `reservationExpired` con el número de la rifa vieja.
Y como el reducer indexa por número —`state.byNumber['0347']`— y no por rifa, la
expiración de la rifa 1 se aplica sobre el tablero de la rifa 2, si comparten ese
número. Es el error común #3 de la Fase 5, con un agravante de diseño encima.

Ahí está la frase del ticket que parecía un titubeo: *"también lo vi en otra
rifa"*. No era una confusión del vendedor. Era el bug describiéndose solo.

**Causa B — el rollback a ciegas.** Es el error común #2 de la Fase 5 y el segundo
defecto del incidente 11: tras un `sellNumber/rejected`, `rollbackSale` devuelve el
número a un `previousStatus` capturado antes, sin comprobar qué pasó entre medio.

**Cómo se distinguen, en un vistazo:**

| | Causa A — temporizador huérfano | Causa B — rollback a ciegas |
|---|---|---|
| Acción que aparece | `reservationExpired` | `rollbackSale` |
| Cuándo | minutos después, sin que hagas nada | al instante, tras una venta fallida |
| En Network | **nada**: no hay petición asociada | un `409` o un `500` justo antes |
| El payload | menciona **otra** rifa | menciona la rifa en pantalla |

La columna de Network es la más rápida: **una acción sin petición al lado nació
dentro del navegador**, y eso descarta la mitad de las hipótesis de un plumazo.

**Parche mínimo**

Para A, limpiar al desmontar:

```javascript
useEffect(() => {
  scheduleExpiration(raffleId, number);
  return () => cancelAllExpirations();   // el temporizador muere con el tablero
}, [raffleId]);
```

Para B, la guarda del incidente 11.

**La refactorización correcta**

Para A hay dos capas, y conviene no confundirlas:

1. **Que el temporizador no sea responsabilidad del componente.** Un `setTimeout`
   dentro de un `useEffect` obliga a acordarse de limpiarlo, y acordarse no es una
   estrategia. En la Fase 6 esto se convierte en un epic que se apaga solo con
   `takeUntil`, y el problema deja de existir en vez de quedar resuelto.
2. **Que el estado se indexe por rifa y número**, no por número a secas. Que la
   expiración de una rifa pueda tocar el tablero de otra no es un accidente del
   temporizador: es una clave mal elegida. Con `state.byNumber['1:0347']` el bug
   pierde el vehículo.

**Prueba de regresión**

```javascript
// src/features/sales/NumberBoard.test.jsx
jest.useFakeTimers();

test('al desmontar el tablero, sus expiraciones no disparan nada', () => {
  const { unmount } = render(<NumberBoard raffleId={1} />);
  act(() => { fireEvent.click(screen.getByTestId('cell-0347')); });  // reserva

  unmount();
  const before = store.getState().sales.byNumber;

  act(() => { jest.advanceTimersByTime(5 * 60 * 1000); });

  // Con el bug, acá apareció un reservationExpired de la rifa 1.
  expect(store.getState().sales.byNumber).toEqual(before);
});
```

`jest.advanceTimersByTime` es lo que vuelve barato probar esto: el bug tarda
minutos en la vida real y milisegundos en la suite.

**Prevención**

Una regla que vale para todo el curso y para todo lo que escribas después: **todo
lo que se agenda se cancela, en el mismo archivo donde se agendó**. Si un
`useEffect` crea un `setTimeout`, un `setInterval` o una suscripción y no devuelve
una función de limpieza, es un defecto — no un descuido de estilo. Y como
prevención estructural, la clave compuesta por rifa y número.

**Por qué llegó a producción**

Porque los temporizadores no dejan rastro. Un `setTimeout` huérfano no lanza
excepciones, no escribe en la consola, no aparece en ningún log, y su efecto ocurre
**minutos después** del código que lo creó. Esa distancia entre causa y efecto es
lo que vuelve carísima esta familia de bugs: cuando el síntoma aparece, quien lo
ve ya está en otra pantalla haciendo otra cosa, y no tiene ninguna razón para
sospechar de algo que hizo hace cinco minutos.

Es, exactamente, el problema que empujó al equipo hacia `redux-observable` en 2022
(`00-historia-del-sistema.md` §3, Era 3). La cancelación dejó de ser algo que había
que recordar y pasó a ser algo que el operador hace por vos. A cambio, la Era 3
trajo su propia familia de bugs invisibles — que son los incidentes 13, 14, 15 y
17.

**Si tu causa fue distinta a esta**

Si dijiste *"el backend liberó la reserva por su cuenta"*, mira Network en el
instante del síntoma: no salió ninguna petición. La acción se despachó desde el
navegador. Si dijiste *"otro vendedor lo liberó desde su máquina"*, plausible y
falso en este sistema: la aplicación no tiene ningún canal por el que le lleguen
cambios de otros clientes —no hay websockets ni polling del tablero todavía—, así
que nada de lo que haga otro puede modificar tu store sin que tú preguntes. Notar
eso, por sí solo, ya elimina una familia entera de hipótesis.

</details>

---

## Incidente 13 — Falló una venta y desde entonces no funciona ninguna

> **Fase:** 6 · **Categoría:** RxJS / epics · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min

### 🎫 El ticket

Vendí un número, me salió un cartel de error rojo, y desde ese momento no puedo
vender nada más. Le doy al botón y no pasa absolutamente nada: ni se vende, ni me
da error, ni se queda cargando. Nada. Cierro el navegador, vuelvo a entrar y anda
otra vez, hasta que se repite. Perdí media mañana entre cierre y cierre del
navegador.

**Reportado por:** vendedor de rifas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar y arreglar. Y explicar la parte del ticket que suena
imposible: **por qué el sistema no da ningún error**. En este incidente el
silencio no es un detalle: es el síntoma principal.

Antes de terminar, comprueba una cosa más que el ticket no menciona: ¿solo dejó de
funcionar la venta, o algo más se apagó junto con ella?

### 🔧 Preparación

- **Rama:** `incidente/13`
- **Caos:** `CHAOS_LEVEL=high`. Hace falta que una venta falle de verdad; con `off`
  no hay forma de encender el problema.
- **Datos:** una rifa en `open` con varios números `reserved`, para poder intentar
  varias ventas seguidas.

```bash
git checkout incidente/13
CHAOS_LEVEL=high npm run mock
npm start
# Vende hasta que una falle. Después intenta vender otro número cualquiera.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Redux DevTools abierto. Después del primer fallo, haz clic en vender otro número y
responde dos preguntas por separado: ¿se despachó la acción `SELL_NUMBER`? ¿Y pasó
algo **después** de ella? Si la respuesta es "sí" y "no", ya tienes acotada la capa
a una sola: la que escucha las acciones y no reaccionó.

Y mira Network al mismo tiempo: cuenta cuántas peticiones salieron.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/sales/epics/sellNumberEpic.js`, y al lado
`src/features/sales/epics/validateNumberEpic.js`. Los dos hacen una petición
dentro de un `switchMap`. Uno tiene un operador que el otro no.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué le pasa a un Observable cuando un error lo recorre entero sin que nadie lo
atrape? ¿Y qué le queda al epic que estaba suscrito a `action$` a través de ese
Observable?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Anota cuántas ventas hiciste antes de la que falló, y qué
intentaste después.}}

**Evidencia observable**
{{Las acciones de Redux DevTools después del fallo, y —muy importante— cuántas
peticiones salieron por Network en cada intento posterior.}}

```
{{acciones despachadas   ·   peticiones en Network}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y una respuesta explícita: ¿qué dejó de existir exactamente?}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`sellNumberEpic` no tiene `catchError` dentro de su `switchMap`. Cuando la petición
de venta falla, el error no lo atrapa nadie, sube por el pipe hasta el `rootEpic`
y **completa el Observable con error**. A partir de ese instante, el epic ya no
está suscrito a `action$`.

Y ahí está la explicación del silencio, que es lo que más cuesta aceptar: el epic
no falló. **Dejó de existir.** Las acciones `SELL_NUMBER` se siguen despachando —lo
ves en DevTools, ahí están— y no hay nadie del otro lado escuchándolas. Un
componente que despacha a un epic muerto se comporta exactamente igual que un
componente que despacha a un epic que decidió no hacer nada: sin excepción, sin
log, sin nada.

La evidencia definitiva es la que pedía la pista 1: **cero peticiones en Network**
en los intentos posteriores. No es que el servidor rechace la venta; es que la
venta nunca sale de la aplicación.

Es el error común #1 de la Fase 6.

**Y la parte que el ticket no menciona**

`combineEpics` combina los epics con un `merge`. Un error que mata a uno mata el
stream combinado, y con él **todos los demás epics**. Si lo comprobaste, viste que
la validación del número en tiempo real también dejó de responder, y la expiración
de reservas también. El vendedor solo reportó lo que estaba haciendo en ese
momento; el daño fue mucho mayor y nadie lo notó.

Ese detalle vale por sí solo el incidente: **el alcance de un fallo casi nunca
coincide con el alcance del reporte.**

> 🧠 **El patrón a memorizar.** En RxJS, un error no es un evento que se maneja: es
> una **terminación**. La analogía de backend que hay que abandonar acá es la
> excepción atrapada en un `try/catch` dentro de un bucle, donde la iteración
> siguiente ocurre igual. Un epic no es un bucle: es una suscripción, y una
> suscripción que termina no vuelve sola.

**Parche mínimo**

El `catchError` va **dentro** del `switchMap`, envolviendo al Observable interno —el
de la petición—, no al externo:

```javascript
switchMap((action) => {
  const { raffleId, number, participant } = action.payload;
  return from(
    apiClient.post(`/raffles/${raffleId}/numbers/${number}/sell`, { participant })
  ).pipe(
    map((response) => numberSoldOptimistic({ /* … */ })),
    // Acá muere el error: mata solo a esta venta, no al epic.
    catchError((error) => of(rollbackSale({ raffleId, number, error: toReadableError(error) })))
  );
})
```

Si lo pones afuera del `switchMap`, atrapas el error y **igual pierdes el stream
externo**: el epic emite el rollback una vez y después se completa. Se ve arreglado
en la primera prueba y vuelve a fallar en la segunda, que es la peor forma
posible de arreglar algo.

**La refactorización correcta**

La de arriba ya es la corrección correcta para este epic. Lo que corresponde
agregar aparte es una red de seguridad para el resto, porque este error va a
volver a ocurrir en algún epic que alguien escriba el año que viene:

```javascript
// src/app/rootEpic.js
export const rootEpic = (action$, store$, deps) =>
  combineEpics(/* … */)(action$, store$, deps).pipe(
    catchError((error, source) => {
      console.error('[rootEpic] un epic murió y fue resucitado:', error);
      return source;      // re-suscribe: el sistema sigue vivo
    })
  );
```

Con eso, un epic mal escrito degrada una operación en vez de apagar la aplicación
entera. Y el `console.error` convierte un fallo invisible en uno que deja rastro,
que es la mitad del problema de este incidente.

**Prueba de regresión**

```javascript
// src/features/sales/epics/sellNumberEpic.test.js
import { TestScheduler } from 'rxjs/testing';
import { ActionsObservable } from 'redux-observable';

test('una venta que falla no mata el epic: la siguiente se sigue atendiendo', () => {
  const scheduler = new TestScheduler((actual, expected) =>
    expect(actual).toEqual(expected)
  );

  scheduler.run(({ hot, expectObservable }) => {
    const action$ = new ActionsObservable(
      hot('a 20ms b', { a: sellNumber('0347'), b: sellNumber('0348') })
    );
    // La primera petición falla, la segunda funciona.
    const output$ = sellNumberEpic(action$, null, { api: apiThatFailsOnce() });

    // Con el bug, el segundo marble no aparece: el epic ya estaba muerto.
    expectObservable(output$).toBe('10ms r 20ms s', {
      r: rollbackSale({ number: '0347' }),
      s: numberSoldOptimistic({ number: '0348' }),
    });
  });
});
```

Lo que hace útil este test es la **segunda** venta. Un test que solo compruebe que
el fallo produce un rollback pasa con el bug adentro: el rollback llega, y recién
la operación siguiente revela que no quedó nadie escuchando. El detalle de cómo se
leen estos diagramas está en `A11-marble-testing.md`.

**Prevención**

Una regla mecánica, verificable en revisión de código: **todo Observable interno
que haga entrada/salida lleva su `catchError` adentro del operador de aplanamiento
que lo creó.** Más el `catchError` del `rootEpic` como red. Y un test de
supervivencia —dos operaciones, la primera falla— por cada epic que atienda algo
repetible.

**Por qué llegó a producción**

Por una creencia razonable y equivocada: *"los errores ya los maneja el interceptor
de axios"*. Y es cierto para lo que el interceptor hace —traducir el `401`,
normalizar el mensaje— pero el interceptor vive en la capa de transporte y no sabe
nada del ciclo de vida de un Observable. Rechaza la promesa, como debe. Lo que pasa
después de ese rechazo es asunto del epic, y nadie lo había pensado.

Y sobrevivió porque el síntoma es absurdo: *"le doy al botón y no pasa nada"* suena
a problema de interfaz, y quien lo investigó por ahí no encontró nada raro, porque
efectivamente no lo hay. El botón funciona perfecto.

**Si tu causa fue distinta a esta**

Si dijiste *"el botón se deshabilitó y no se volvió a habilitar"*, míralo en el
inspector: está habilitado, y el `onClick` se ejecuta. Si dijiste *"el backend está
rechazando todo"*, la prueba está en Network: **no sale ninguna petición**, así que
el backend ni se entera. Y si tu fix fue recargar la aplicación desde el código
—un `window.location.reload()` en el `catch`—, automatizaste lo que ya hacía el
vendedor a mano y le pusiste el mismo costo: todo el estado en memoria, perdido.

</details>

---

## Incidente 14 ⭐ — Cerré sesión y el servidor sigue recibiendo peticiones

> **Fase:** 6 · **Categoría:** RxJS / epics · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 55-70 min
> ⭐ Uno de los dos incidentes más formativos del curso

### 🎫 El ticket

Nos avisó el proveedor de infraestructura que estamos haciendo como cuatro veces
más peticiones de las que correspondería para la cantidad de gente que usa el
sistema. Miramos el log del servidor y hay pedidos de tableros de rifas a las tres
de la mañana, cuando no hay nadie trabajando. Vienen sin token y son de usuarios
que cerraron sesión hacía horas. Nadie se quejó nunca de nada: la aplicación
funciona bien.

**Reportado por:** infraestructura, a partir de la factura
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducirlo en Network en menos de un minuto, localizar la línea y aplicar el fix
—que es de una línea— y escribir el post-mortem completo. Este es **el** incidente
que el curso usa como ejemplo de la convención de tags: cuando lo cierres, el par
`inc/14/suscripcion-zombi-roto` / `-fix` tiene que existir, y sus mensajes están
redactados como referencia en `00-convencion-de-git-y-tags.md` §🚑.

Y hay una pregunta de fondo que conviene contestar por escrito: **¿por qué nadie
se quejó nunca?**

### 🔧 Preparación

- **Rama:** `incidente/14`, que trae el `boardRefreshEpic` en su versión con leak
  (la de §5.8 de la Fase 6).
- **Caos:** `off`. Este bug no necesita que nada falle; al contrario, el caos solo
  agrega ruido a Network justo donde hay que mirar.
- **Datos:** una rifa en `open`, la 3, para tener su tablero.

```bash
git checkout incidente/14
CHAOS_LEVEL=off npm run mock
npm start
# Login → abrir el tablero de la rifa 3 → logout → NO TOCAR NADA y mirar Network.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No lo busques en el código: es de los pocos bugs que se ven antes de leer nada.
Abre Network, filtra por `numbers`, cierra sesión y **quédate quieto mirando la
pestaña**. La aplicación no se está usando. Si algo aparece igual, ese algo es el
incidente.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/sales/epics/boardRefreshEpic.js`. Pon su `.pipe()` al lado del de
`reservationExpirationEpic`, que sí se apaga. Los dos crean un stream que emite
para siempre; uno de los dos tiene una instrucción de apagado.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El `interval` que abre el `switchMap` emite cada cinco segundos hasta el fin de los
tiempos. ¿Quién le dice que pare, y —esta es la parte que decide si tu fix va a
funcionar— **en cuál de los dos pipes** tendría que estar esa instrucción?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Anota cuántos minutos dejaste la pestaña quieta y cuántas
peticiones contaste en ese tiempo: ese número es el que convierte este incidente
en dinero.}}

**Evidencia observable**
{{Las filas de Network después del logout, con su URL, su cadencia y sus headers.
La ausencia del `Authorization` es parte de la prueba.}}

```
{{las peticiones que no deberían existir}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Y responde: ¿por qué ahí y no en el otro pipe?}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/features/sales/epics/boardRefreshEpic.js` **no tiene `takeUntil`**. El
`interval(5000)` que abre el `switchMap` emite indefinidamente, y nadie lo corta
nunca:

```javascript
// ❌ VERSIÓN CON LEAK (Fase 6, §5.8)
export const boardRefreshEpic = (action$) =>
  action$.pipe(
    ofType('START_BOARD_REFRESH'),
    switchMap(({ payload }) =>
      interval(5000).pipe(map(() => fetchNumbers(payload.raffleId)))
    )   // <-- acá falta el takeUntil. Ese es el leak.
  );
```

Desmontar el tablero no hace nada, y ahí está el salto conceptual de toda la Fase
6: **un epic no tiene ciclo de vida atado a la interfaz**. Vive en el middleware,
que se monta una vez con la aplicación. El componente que despachó
`START_BOARD_REFRESH` puede desaparecer, el usuario puede cerrar sesión, puede
navegar a otra sección — el `interval` sigue emitiendo, porque nada de eso es una
señal para él. Sigue emitiendo hasta que se cierra la pestaña, que es exactamente
lo que dice el log de las tres de la mañana: máquinas de kiosco que quedaron
prendidas.

Y las peticiones salen **sin token** porque el interceptor lee el store en cada
petición y el store ya no tiene sesión (ver el incidente 05). Un `401` por cada
tick, cada cinco segundos, toda la noche. La aplicación las descarta en silencio;
el servidor las atiende igual, y las cobra.

**Parche mínimo**

```javascript
switchMap(({ payload }) =>
  interval(5000).pipe(
    map(() => fetchNumbers(payload.raffleId)),
    // Última línea del pipe INTERNO: corta este interval, no el epic.
    takeUntil(action$.pipe(ofType('STOP_BOARD_REFRESH', logout.type)))
  )
)
```

**Y por qué va en el pipe interno, que es la mitad de la lección**

`takeUntil` corta **todo lo que está antes de él en el pipe donde vive**. Si lo
pones en el pipe externo —cerrando el `action$.pipe(...)` del epic—, funciona una
vez: el primer logout apaga el `interval`… y también apaga el epic entero. El
usuario vuelve a entrar, abre un tablero, y el refresco ya no arranca nunca más,
porque no queda nadie escuchando `START_BOARD_REFRESH`.

Habrías cambiado un leak por un epic muerto, que es exactamente el **incidente
13**. Dos bugs opuestos, la misma línea, dos ubicaciones distintas dentro del
mismo `.pipe()`. Es el error común #3 de la Fase 6 y la razón por la que la regla
práctica es: **`takeUntil` casi siempre va último, y en el pipe interno**.

**La refactorización correcta**

La versión de producción, que la Fase 7 consolida en §5.10 al pagar esta deuda 💸:
`timer(0, 5000)` en lugar de `interval(5000)` —para refrescar de entrada, sin
esperar el primer intervalo— y el mismo `takeUntil` con todas las señales que
tengan sentido para el tablero: `STOP_BOARD_REFRESH`, `logout`, el cierre de la
rifa. Mismo esqueleto que el `pollingEpic`.

**Prueba de regresión**

```javascript
// src/features/sales/epics/boardRefreshEpic.test.js
import { TestScheduler } from 'rxjs/testing';
import { ActionsObservable } from 'redux-observable';

test('el refresco del tablero completa al llegar el logout', () => {
  const scheduler = new TestScheduler((actual, expected) =>
    expect(actual).toEqual(expected)
  );

  scheduler.run(({ hot, expectObservable }) => {
    const action$ = new ActionsObservable(
      hot('a 12s b', { a: startBoardRefresh({ raffleId: 3 }), b: logout() })
    );

    // Dos ticks (5s y 10s) y después NADA: el "|" es el punto del test.
    expectObservable(boardRefreshEpic(action$)).toBe('5s x 4999ms y 2s |', {
      x: fetchNumbers(3),
      y: fetchNumbers(3),
    });
  });
});
```

> 🧭 **Lo que se prueba acá no es que el epic emita: es que el epic
> DEJE de emitir.** Esa barra vertical al final del diagrama es todo el test. Es la
> única forma práctica de verificar una cancelación, y es la razón por la que
> `A11-marble-testing.md` existe: sin marbles, "comprobar que algo no pasa nunca
> más" requiere esperar para siempre.

**Prevención**

Una regla concreta: **todo epic que crea un stream infinito** —`interval`, `timer`,
`fromEvent`, un websocket— **declara su `takeUntil` en el mismo pipe donde lo
creó**, y lleva un test de cancelación como el de arriba. Son dos líneas de
prevención contra una familia de bugs que no da ninguna otra señal.

Y una operativa que cuesta cinco minutos: revisar el volumen de peticiones por
usuario activo, una vez al mes. Este incidente lo encontró una factura; podría
haberlo encontrado un gráfico.

**Por qué llegó a producción**

Porque **no rompe nada**. La aplicación funciona perfecto, el usuario no percibe
absolutamente nada, no hay error en ninguna consola, y el `takeUntil` faltante no
produce ningún síntoma el día que se escribe. El costo aparece meses después, lo
paga otra área, y llega expresado en una unidad —una factura de infraestructura—
que nadie asocia con una línea de código.

Ahí está la respuesta a la pregunta del enunciado: nadie se quejó porque **no hay
nadie a quien le duela**. El usuario no lo sufre, el desarrollador no lo ve, y el
que lo paga no sabe leer un pipe de RxJS. Es la definición del bug caro con parche
barato, y por eso el curso lo marca con ⭐.

Es también, exactamente, el problema que empujó al equipo a adoptar
`redux-observable` en 2022 (`00-historia-del-sistema.md` §3, Era 3): un
`setInterval` que seguía preguntando después del logout, para siempre. La
herramienta que vino a resolverlo trae la solución —`takeUntil`— y también la forma
de olvidarla.

**Si tu causa fue distinta a esta**

Si dijiste *"el componente del tablero no se desmonta"*, compruébalo con React
DevTools: se desmonta perfectamente. Y aunque no lo hiciera, daría igual — el
`interval` no vive en el componente. Interiorizar eso es el objetivo del incidente:
en un sistema con epics, **desmontar la interfaz no cancela nada**.

Si dijiste *"falta limpiar el `useEffect`"*, ese diagnóstico es correcto para el
**incidente 12**, donde el temporizador sí vive en el componente. Tener los dos en
el cuaderno y saber cuál es cuál —el mismo síntoma de "algo sigue vivo", en dos
capas distintas— es una de las distinciones más útiles que te llevas del curso.

</details>

---

## Incidente 15 — Escribo el número rápido y me valida uno viejo

> **Fase:** 6 · **Categoría:** RxJS / epics · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min

### 🎫 El ticket

Cuando escribo el número que quiero vender, el cartelito de al lado me dice
cualquier cosa. Escribo 0347 y me dice que el 034 está vendido. Si escribo
despacio, letra por letra, anda bien. Ayer no le vendí un número a un cliente
porque el cartel decía que no estaba disponible, y después resulta que sí lo
estaba. Perdimos la venta.

**Reportado por:** vendedor de rifas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar y arreglar. Y explicar dos cosas que el ticket regala:
**por qué escribir despacio lo arregla**, y por qué eso descarta de entrada la
mitad de las hipótesis.

Ojo: en el pipe de este epic hay **dos** cosas cambiadas respecto de la versión
que escribiste en la Fase 6, y solo una de las dos causa la respuesta equivocada.
Separarlas es parte del trabajo.

### 🔧 Preparación

- **Rama:** `incidente/15`
- **Caos:** `CHAOS_LEVEL=high`. **Obligatorio**, y acá el motivo es preciso: el bug
  no existe sin latencia variable. Con el mock respondiendo en tres milisegundos,
  las respuestas vuelven en el mismo orden en que salieron y el problema es
  invisible. Este incidente **no se puede reproducir con `off`**, por mucho que
  escribas rápido.
- **Datos:** una rifa en `open` donde el número `034` esté `sold` y el `0347` esté
  `available`. La rama los deja así, y esa combinación es la que hace el síntoma
  inconfundible.

```bash
git checkout incidente/15
CHAOS_LEVEL=high npm run mock
npm start
# En el campo de venta, escribe 0347 a velocidad normal. Repite unas cuantas veces.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No es un problema del campo de texto. Escribe con Network abierto y mira dos
columnas: cuántas peticiones salieron, y la columna **Time** de cada una. Después
ordénalas por el momento en que **volvieron**, no por el momento en que salieron.
Ahí está todo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/sales/epics/validateNumberEpic.js`. Compara su operador de
aplanamiento con el de `sellNumberEpic`. Y fíjate qué le pasó al primer operador
del pipe, el que controlaba cada cuánto se dispara la validación.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si dos peticiones están en vuelo al mismo tiempo y la primera tarda más que la
segunda, ¿cuál de las dos respuestas llega última? ¿Y cuál de las dos termina
pintando el store?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Anota a qué velocidad escribiste y cuántos intentos hicieron
falta: en un bug que depende de latencia, la frecuencia es parte de la descripción.}}

**Evidencia observable**
{{Las peticiones de Network con su tiempo de respuesta, y las acciones
`numberValidationSucceeded` en el orden en que llegaron al store.}}

```
{{qué salió, qué volvió, y en qué orden}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y de los dos cambios que hay en ese pipe, cuál es la causa y
cuál es solo un amplificador.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`validateNumberEpic` usa `mergeMap` donde corresponde `switchMap`.

`mergeMap` mantiene **todas** las peticiones en vuelo a la vez y deja pasar sus
respuestas en el orden en que lleguen. Con latencia variable —que es lo que hace el
caos y lo que hace cualquier red real— la respuesta de `034` puede volver después
de la de `0347`, y como el reducer aplica lo último que recibe, el estado del
número viejo pisa al del nuevo. El campo dice `0347`, el cartel describe el `034`.

Es el error común #2 de la Fase 6, y la fase es tajante sobre cómo llamarlo: **no
es cosmético, es corrección contra bug.**

**Los dos cambios, y cuál es cuál**

El otro cambio en ese pipe es que `debounceTime(300)` fue reducido —alguien lo
bajó porque "se sentía lento"—. Eso **no es la causa**: es un amplificador. El
debounce controla *cuántas* validaciones se disparan; el operador de aplanamiento
controla *cuál gana*. Compruébalo en dos pasos:

- Restituye el `debounceTime(300)` y deja el `mergeMap`: el bug **sigue apareciendo**,
  solo que necesitas hacer una pausa de poco más de trescientos milisegundos en
  mitad del número. Menos frecuente, igual de incorrecto.
- Deja el debounce corto y pon `switchMap`: se disparan muchas peticiones —derroche
  de red— y **el resultado siempre es correcto**.

De ahí sale la conclusión que vale para el resto de tu carrera: **el debounce es una
optimización, el operador de aplanamiento es una decisión de correctitud.** Se
parecen porque los dos "reducen peticiones", y no son lo mismo.

**Y por qué escribir despacio lo arregla**

Porque con pausas largas solo hay una petición en vuelo por vez, y una petición
sola no puede cruzarse con nadie. Esa frase del ticket —*"si escribo despacio anda
bien"*— es un regalo: descarta de un plumazo el campo de texto, el reducer, el
componente y el backend. Ninguno de ellos se comporta distinto según la velocidad
de tipeo. **Lo único que cambia con la velocidad es cuántas cosas ocurren a la
vez**, y eso solo apunta a concurrencia.

**Parche mínimo**

```javascript
// src/features/sales/epics/validateNumberEpic.js
action$.pipe(
  ofType(numberValidationRequested.type),
  debounceTime(300),
  // switchMap: cada número nuevo CANCELA la validación anterior en vuelo.
  switchMap((action) => { /* … la petición, igual que antes … */ })
)
```

**La refactorización correcta**

`switchMap` con el `debounceTime(300)` restituido es la versión correcta y es la
que la Fase 6 ya tenía escrita. Lo que se puede agregar aparte, y que revela algo
más profundo, es una guarda en el reducer:

```javascript
numberValidationSucceeded(state, action) {
  // Ignora la respuesta de un número que ya no es el que el usuario está mirando.
  if (action.payload.number !== state.currentInput) return;
  state.validation = action.payload.status;
}
```

Es cinturón además de tirantes, y sobre todo es un olor a diseño que conviene
nombrar: **la acción no lleva ninguna identidad de la petición que la originó**.
Sin esa identidad, el store no tiene forma de saber si lo que le llega es actual o
llegó tarde, y depende por completo de que el epic haya cancelado bien.

**Prueba de regresión**

```javascript
// src/features/sales/epics/validateNumberEpic.test.js
test('la respuesta lenta de un número viejo no pisa a la del número nuevo', () => {
  const scheduler = new TestScheduler((actual, expected) =>
    expect(actual).toEqual(expected)
  );

  scheduler.run(({ hot, cold, expectObservable }) => {
    const action$ = new ActionsObservable(
      hot('a 400ms b', {
        a: numberValidationRequested({ number: '034' }),
        b: numberValidationRequested({ number: '0347' }),
      })
    );
    // El '034' tarda 900ms; el '0347', 100ms. Se cruzan a propósito.
    const api = { get: (n) => (n === '034' ? cold('900ms r') : cold('100ms r')) };

    // Solo debe emitir la validación del 0347. Con mergeMap aparecen las dos,
    // y la del 034 llega DESPUÉS.
    expectObservable(validateNumberEpic(action$, null, { api })).toBe(
      '801ms s', { s: numberValidationSucceeded({ number: '0347' }) }
    );
  });
});
```

Reproducir una inversión de orden en la aplicación requiere suerte y caos;
reproducirla con marbles es escribir dos números distintos. Ese es el argumento
entero a favor de `A11-marble-testing.md`.

**Prevención**

Una regla por defecto que resuelve el noventa por ciento de los casos:
**`switchMap` cuando solo importa el último resultado** —búsquedas, validaciones,
autocompletado, cualquier cosa atada a lo que el usuario está mirando ahora
mismo—; **`mergeMap` solo cuando cada operación es independiente y sus resultados
no se pisan** —enviar eventos, registrar métricas—. Y si en una revisión de código
aparece un `mergeMap`, que su autor tenga que decir en voz alta por qué no es
`switchMap`.

**Por qué llegó a producción**

Porque en la máquina de quien lo escribió la latencia es de tres milisegundos y
**las respuestas siempre vuelven en orden**. El orden de llegada no es una
propiedad del código: es una propiedad de la red. Y el código se escribe sobre una
red que en la práctica no existe.

Y sobrevivió porque el síntoma parece un problema de la interfaz —"el cartelito
dice cualquier cosa"— y porque es intermitente, así que quien fue a mirarlo escribió
el número una vez, despacio, vio que funcionaba, y cerró el ticket.

El costo real, en cambio, no es cosmético en absoluto: el ticket dice que se
perdió una venta. Un cartel que miente sobre la disponibilidad de un número es, en
este negocio, una decisión comercial tomada con datos falsos.

**Si tu causa fue distinta a esta**

Si dijiste *"es el debounce"*, lee arriba: cambia la frecuencia, no la
correctitud. Es la hipótesis más común y es una media verdad, que en depuración es
peor que una hipótesis equivocada — porque tocarla mejora el síntoma lo suficiente
como para dar por cerrado el caso.

Si dijiste *"el input pierde caracteres"*, mira el payload de las acciones
`numberValidationRequested`: están todas, completas y en orden. Lo que se desordena
es la vuelta, no la ida. Y si tu fix fue deshabilitar el campo mientras hay una
validación en curso, funciona y hace la aplicación notablemente peor de usar:
convertiste un problema de concurrencia en un problema de ergonomía.

</details>

---

## Incidente 16 — La rifa siguió vendiendo después de la hora de cierre

> **Fase:** 7 · **Categoría:** Tiempo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min
> · Hermano del incidente `be-12`, con otra causa raíz

### 🎫 El ticket

La Rifa de Navidad cerraba a las 8 de la noche y el sistema siguió aceptando
ventas después. Tenemos catorce números vendidos con hora posterior al cierre, y
uno de ellos salió sorteado. El vendedor de la costa dice que a él le cerró a la
hora que correspondía; el de la capital dice que le siguió dejando vender un rato
más. No sé si eso tiene algo que ver.

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir y localizar. Y prestarle atención a la última frase del ticket, que
parece un comentario al pasar y es el dato central: **dos vendedores en lugares
distintos vieron cerrar la misma rifa en momentos distintos.**

> ⚠️ **Sin declarar la zona horaria del navegador, este incidente no se
> reproduce.** No es un detalle de la preparación: es el mecanismo del bug. Si
> intentas reproducirlo sin fijar la zona horaria, vas a concluir que no pasa.

### 🔧 Preparación

- **Rama:** `incidente/16`
- **Caos:** `off`. El bug es determinista una vez que la zona horaria está fijada.
- **Datos:** una rifa con `closesAt` en `2024-12-20T20:00:00-05:00` y números
  disponibles para vender. La rama la deja cargada.
- **Zona horaria del navegador:** hay que cambiarla, y ahí está el experimento. En
  Chrome: DevTools → menú de tres puntos → More tools → Sensors → Location, o más
  simple, arrancar el navegador con la variable de entorno:

```bash
git checkout incidente/16
CHAOS_LEVEL=off npm run mock
TZ=America/Bogota npm start        # -05:00, la del cierre
# Y después, la misma prueba con:
TZ=America/Argentina/Buenos_Aires npm start    # -03:00
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes del código, haz el experimento que el ticket describe sin saberlo: reproduce
la misma venta, sobre la misma rifa, con dos zonas horarias distintas en el
navegador. Si el resultado cambia, ya sabes que la causa está en cómo se compara
el tiempo, y no en el estado de la rifa.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

La guarda que decide si una rifa admite ventas. Busca dónde se compara la hora de
cierre con la hora actual, y mira **con qué** se comparan: ¿dos instantes, o dos
pedazos de fecha?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué devuelve `new Date('2024-12-20T20:00:00-05:00').getHours()` en un navegador
configurado en `-03:00`? Escríbelo en la consola antes de contestar de memoria.

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, y **obligatorio**: la zona horaria del navegador en cada
intento, y el `closesAt` exacto de la rifa con su offset.}}

**Evidencia observable**
{{El resultado del mismo experimento en dos zonas horarias, lado a lado.}}

```
{{TZ=...  → vendió / no vendió    ·    TZ=...  → vendió / no vendió}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

La guarda de cierre desarma la fecha en componentes en vez de comparar instantes:

```javascript
// ❌ getHours() devuelve la hora EN LA ZONA DEL NAVEGADOR, no en la del cierre.
const closing = new Date(raffle.closesAt);
if (new Date().getHours() < closing.getHours()) {
  // …permitir la venta
}
```

Un instante en el tiempo es un número absoluto: el momento en que ocurre el cierre
es el mismo para todo el mundo. Pero `getHours()` no devuelve ese número: devuelve
cómo **se ve** ese instante desde donde está el reloj que pregunta. Las 20:00 de
`-05:00` son las 22:00 en `-03:00`, y por eso el vendedor de la capital pudo seguir
vendiendo dos horas más que el de la costa. Es el error común #1 de la Fase 7.

Y por eso el comentario final del ticket —*"no sé si eso tiene algo que ver"*— era
el diagnóstico entero. **Cuando dos usuarios ven comportamientos distintos frente
al mismo dato, la diferencia está en sus máquinas, no en el dato.** Es la misma
forma de razonar del incidente 02 y del 20, en tres capas completamente distintas.

**Parche mínimo**

Comparar instantes contra instantes, que es lo que hace `isPastClosing`:

```javascript
// src/features/raffles/closing.js
export function isPastClosing(closesAt) {
  return Date.now() >= new Date(closesAt).getTime();
}
```

`getTime()` devuelve milisegundos desde la época, en UTC, idéntico en todo el
planeta. La zona horaria deja de participar de la decisión y pasa a ser lo único
que debería haber sido siempre: un asunto de **presentación**.

**La refactorización correcta**

Dos capas, y la segunda es la importante:

1. **Centralizar toda comparación de tiempo en `closing.js`** y prohibir
   `getHours()`, `getDate()` y `getMonth()` en el resto del código con una regla de
   lint. Desarmar una fecha es legítimo para mostrarla y nunca para decidir con
   ella.
2. **Que la hora la decida el servidor.** Hoy la guarda usa el reloj del navegador,
   y el reloj del navegador lo controla el usuario: adelantarlo dos horas es un
   ajuste de la configuración del sistema operativo. Toda esta guarda es una
   comodidad de la interfaz, no una garantía. La garantía tiene que estar del otro
   lado del cable, y eso es la deuda 💸 de `serverNow` que la Fase 7 declara y no
   paga.

**Prueba de regresión**

```javascript
// src/features/raffles/closing.test.js
describe('isPastClosing', () => {
  const closesAt = '2024-12-20T20:00:00-05:00';   // 01:00 UTC del 21

  test.each([
    'America/Bogota',                  // -05:00
    'America/Argentina/Buenos_Aires',  // -03:00
    'Europe/Madrid',                   // +01:00
    'Asia/Tokyo',                      // +09:00
  ])('da el mismo resultado en %s', (tz) => {
    process.env.TZ = tz;
    // Un instante indiscutiblemente posterior al cierre.
    jest.setSystemTime(new Date('2024-12-21T02:00:00Z'));

    expect(isPastClosing(closesAt)).toBe(true);
  });
});
```

La forma del test es la lección: **la misma aserción, repetida en cuatro zonas
horarias**. Un test de tiempo que corre en una sola zona no prueba nada sobre
tiempo; prueba sobre la máquina que lo corrió — y eso lleva directo al incidente 20.

**Prevención**

La regla de lint contra los desarmadores de fecha, los cuatro casos de prueba por
zona, y una convención de datos que ahorra la mitad de estos bugs: **todas las
fechas viajan y se guardan con offset explícito** (`2024-12-20T20:00:00-05:00`),
nunca como `2024-12-20 20:00`. Una fecha sin offset no es un instante: es un texto
que cada máquina interpreta como quiere.

**Por qué llegó a producción**

Porque todo el equipo está en la misma zona horaria, y en una sola zona horaria
este código **es correcto**. No hay ninguna prueba, ninguna revisión y ninguna demo
que pueda revelar el error mientras todos los relojes coincidan. El bug estuvo
latente desde el primer día y se activó el día que se vendió una rifa desde otra
provincia — sin que cambiara una línea de código.

Y llegó, además, porque el descuadre es pequeño y tardío: dos horas de más en un
cierre no llaman la atención hasta que alguien cruza las horas de venta con la
hora de cierre, que es algo que solo pasa cuando ya hay un problema.

**Si tu causa fue distinta a esta**

Si dijiste *"el estado de la rifa no se actualizó a `closed`"*, es una hipótesis
buena y hay que descartarla mirando el store: el `status` puede estar correcto y la
venta pasar igual, porque la guarda de la hora dura es independiente del enum. De
hecho la Fase 7 lo dice explícitamente al explicar por qué el selector **no** llama
a `isPastClosing`: el enum es del store, la hora es del reloj, y son dos preguntas
distintas.

**Y acá está el cruce con el track BE.** El incidente `be-12` —*"vendimos doscientos
números después del cierre"*— tiene el mismo síntoma con la causa una capa más
abajo: allá la comparación de instantes está bien hecha, y el problema es **quién
tiene autoridad sobre la hora**. Acá el navegador se equivoca al interpretar el
instante; allá el navegador acierta y aun así no debería ser él quien decida. Si
haces el track BE, este par enseña la diferencia entre *calcular bien el tiempo* y
*tener derecho a decidir sobre el tiempo*.

</details>

---

## Incidente 17 — El resultado nunca llega y no aparece ningún error

> **Fase:** 7 · **Categoría:** RxJS / epics · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min

### 🎫 El ticket

Cerramos la rifa de las 8 de la noche y el sistema tenía que traer solo el
resultado de la lotería. Nunca lo trajo. Estuvimos hasta las 9 mirando la pantalla,
que decía "esperando resultado" todo el tiempo. Al final lo cargamos a mano
mirando la página de la lotería. En ningún momento salió ningún error ni ningún
aviso: solo decía esperando.

**Reportado por:** supervisor de ventas
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir y decidir cuál de **dos causas plausibles** produjo este caso concreto.
Las dos dejan al usuario mirando "esperando resultado"; se distinguen con una sola
observación. Después, el fix.

### 🔧 Preparación

- **Rama:** `incidente/17`
- **Caos:** `CHAOS_LEVEL=high`, y **en el mock de la lotería, el del puerto
  `3002`** —no en el `3001`—. Hace falta que un tick reciba un `500`; sin eso el
  bug no se enciende. Es el error más común al preparar este incidente: subir el
  caos en el mock equivocado y concluir que no se reproduce.
- **Datos:** una rifa que acabe de pasar a `closed`, con el resultado ya disponible
  en el mock de lotería.

```bash
git checkout incidente/17
CHAOS_LEVEL=high npm run mock:lottery     # el 3002, no el 3001
npm start
# Cierra la rifa y deja la pantalla de resultado abierta, mirando Network.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Network, filtrado por `results`. No mires si hay errores: **cuenta los `GET` y fíjate
en qué momento dejan de salir**. Un polling sano deja un rastro regular en la
pestaña. La hora exacta en la que ese rastro se corta es el dato que decide todo el
diagnóstico.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/raffles/epics/pollingEpic.js`. Localiza el `catchError` y responde
una sola pregunta: ¿está adentro del tick, o envuelve al `timer` entero?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Cuando un `catchError` se dispara, emite su valor de reemplazo y **completa el
stream que envuelve**. Si lo que envuelve es el `timer`, ¿qué queda vivo después
del primer error?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, con el `CHAOS_LEVEL` y —explícitamente— **en qué mock** lo
pusiste.}}

**Evidencia observable**
{{La secuencia de `GET /results` con sus horas y sus status, y el momento exacto en
que dejan de aparecer.}}

```
{{los ticks, hasta que se cortan}}
```

**Hipótesis**
- ❌ Descartada: {{cuál de las dos causas descartaste, y con qué evidencia}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Las dos causas, y la observación que las separa**

**Causa A — el `catchError` envuelve al `timer`.** Cuando el primer `500` de la
lotería llega, el `catchError` lo atrapa, emite su acción de reemplazo y —esto es
lo que importa— **completa el stream que envuelve**, que es el `timer` entero. El
polling muere ahí. No hay más ticks, no hay más peticiones, y el store se queda
con el último estado que tenía: "esperando resultado". Es el error común #2 de la
Fase 7, y es el error #1 de la Fase 6 aplicado al polling: **el `catchError` mata
lo que envuelve.**

**Causa B — el `204` tratado como error.** La lotería devuelve `204` cuando el
sorteo todavía no salió, que es información legítima y frecuente: significa "sigue
preguntando". Si el epic lo trata como fallo, el store se llena de `pollingFailed`
mientras no pasa nada malo. Es el error común #4 de la Fase 7.

**Se distinguen con una sola columna de Network:**

| | Causa A — `catchError` mal ubicado | Causa B — el `204` como error |
|---|---|---|
| Los `GET /results` | **paran** y no vuelven nunca | **siguen saliendo** cada 3 s |
| En el store | nada nuevo tras el corte | `pollingFailed` acumulándose |
| Qué ve el usuario | "esperando resultado" | "esperando resultado" |

La pantalla dice lo mismo en los dos casos. La red no. **Cuando dos causas producen
la misma interfaz, la evidencia tiene que venir de una capa donde se comporten
distinto**, y esa es la razón por la que la pista 1 te manda a contar peticiones en
lugar de a buscar errores.

En este incidente concreto —el de las ocho de la noche— es la **causa A**: los
`GET` se cortan y no vuelven.

**Parche mínimo**

El `catchError` va adentro del tick, envolviendo la petición y no al `timer`:

```javascript
timer(0, POLLING_INTERVAL_MS).pipe(
  mergeMap(() =>
    from(apiLottery.get(`/results/${raffleId}`)).pipe(
      filter((res) => res.status === 200 && res.data),
      map((res) => resultReceived(res.data)),
      // Muere el tick, no el polling: el siguiente sale igual.
      catchError((error) => of(pollingFailed(toReadableError(error))))
    )
  ),
  takeUntil(/* … */)
)
```

**La refactorización correcta**

Dos cosas más, y la segunda es la que este incidente deja al descubierto:

1. **Reintento con espera creciente por tick**, que la Fase 7 ya trae: `500`, `1s`,
   `2s` antes de rendirse con ese tick. Un `500` aislado deja de tener consecuencia
   alguna.
2. **Un límite al "esperar"**. Si pasaron veinte minutos desde el cierre y no hay
   resultado, el sistema tiene que decirlo. Hoy "esperando resultado" significa las
   dos cosas a la vez: *"todavía no salió"* y *"me morí hace una hora"*. **Un
   estado que también significa su propio fallo es un defecto de diseño de
   estados**, y es literalmente el mismo defecto del incidente 07 una capa más
   arriba: nadie decidió cuánto es demasiado.

**Prueba de regresión**

```javascript
// src/features/raffles/epics/pollingEpic.test.js
test('un tick que falla no mata el polling: el siguiente sale igual', () => {
  const scheduler = new TestScheduler((actual, expected) =>
    expect(actual).toEqual(expected)
  );

  scheduler.run(({ hot, expectObservable }) => {
    const action$ = new ActionsObservable(hot('a', { a: startPolling({ raffleId: 1 }) }));
    // Primer tick: 500. Segundo tick: el resultado.
    const api = apiThatFailsOnce();

    // Con el bug, después de la 'f' no hay nada más: el timer murió.
    expectObservable(pollingEpic(action$, null, { api })).toBe('f 2999ms r', {
      f: pollingFailed(expect.anything()),
      r: resultReceived(expect.anything()),
    });
  });
});
```

Igual que en el incidente 13, lo que hace útil al test es **el segundo tick**. Un
test que solo verifique que un `500` produce un `pollingFailed` pasa con el bug
adentro.

**Prevención**

La regla, que conviene memorizar con estas palabras: **el `catchError` va donde
quieras que el error muera, y casi siempre eso es el Observable interno.** Ponerlo
más afuera no es "más seguro": es más destructivo.

Y para los epics de vida larga, un test de supervivencia obligatorio: un fallo, y
después la comprobación de que el siguiente ciclo ocurre igual.

**Por qué llegó a producción**

Porque el polling se probó contra una lotería sana, que es la única que existe en
la máquina de quien programa. El `500` de un tercero es exactamente el evento que
no puedes provocar en desarrollo si no construiste antes un mock que falle a
propósito — que es la razón entera por la que la Fase 3 existe.

Y llegó, sobre todo, porque el fallo se disfrazó de comportamiento normal. "Esperando
resultado" es un mensaje legítimo, tranquilizador, que el supervisor miró durante
una hora sin motivo para desconfiar. Los fallos que se ven iguales que el
funcionamiento correcto no generan tickets: generan gente esperando.

**Si tu causa fue distinta a esta**

Si dijiste *"la lotería no publicó el resultado"*, revisa el mock: el resultado
estaba ahí, con un `200` y su ganador, esperando a que alguien fuera a buscarlo.
Nadie fue. Si dijiste *"el `takeUntil` cortó de más"* —que sería el error común #3
de la Fase 7— es una hipótesis excelente y se descarta mirando **qué** ocurrió justo
antes del último `GET`: con un `takeUntil` de más, el corte coincide con un evento
concreto (el cierre, el logout, recibir el resultado); acá coincide con un `500`.
El momento del corte te dice quién lo cortó.

</details>

---

## Incidente 18 — La liquidación da un centavo de diferencia

> **Fase:** 8 · **Categoría:** Dinero · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min
> · Hermano del incidente `be-13`, con otra causa raíz

### 🎫 El ticket

La liquidación de la rifa chica de la semana pasada da un centavo de diferencia
contra lo que sumamos a mano. Un centavo. Ya sé que suena a nada y que van a
decirme que lo redondee, pero necesito entender de dónde sale antes de firmarla,
porque si es un centavo con tres números, no sé cuánto es con diez mil.

**Reportado por:** tesorería
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir con los datos exactos del reporte, localizar el cálculo culpable y
arreglarlo. Y contestarle a tesorería la pregunta que hizo, que es la correcta:
**¿cuánto es este error con diez mil números?**

Este incidente es el más chico del cuaderno en tamaño del síntoma y de los más
grandes en tamaño de la causa. Esa desproporción es la lección entera.

### 🔧 Preparación

- **Rama:** `incidente/18`
- **Caos:** `off`. No hay ninguna red involucrada en el error: es aritmética.
- **Datos, y son exactos:** una rifa con `numberPriceInPesos: 0.1` y **tres**
  números vendidos. Sí, diez centavos por número: es el precio más ridículo
  posible y es justo el que hace visible el problema en el primer decimal.

```bash
git checkout incidente/18
CHAOS_LEVEL=off npm run mock
npm start
# Liquida esa rifa y compara el total con lo que dan tres veces diez centavos.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No hace falta la aplicación. Abre una consola de Node y escribe `0.1 + 0.1 + 0.1`.
Mira el resultado con atención, hasta el último dígito. Si eso te sorprende, ya
tienes la causa; si no te sorprende, ya sabes dónde buscarla en el código.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`calculateTotalCollected` y todo lo que la alimenta. La Fase 8 pide una regla:
**el dinero vive en centavos enteros**. Busca el punto exacto del recorrido donde
esa regla se rompe — dónde entra un número con coma, o dónde una división deja de
ser entera.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un número de punto flotante de doble precisión no puede representar 0,1 de forma
exacta, del mismo modo que en decimal no puedes escribir un tercio con una
cantidad finita de dígitos. ¿Qué pasa entonces cuando sumas tres de esos, y qué
pasa cuando multiplicas el resultado por cien para "pasarlo a centavos"?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, con los valores exactos: precio, cantidad de números y el total
que esperabas contra el que salió.}}

**Evidencia observable**
{{El resultado de correr la función pura en la consola, con esos mismos datos.
Este es el único incidente del cuaderno donde la evidencia decisiva no está en el
navegador.}}

```
{{entrada, salida esperada, salida real, con todos sus decimales}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y en cuál de las cuatro capas de auditoría de la Fase 8 apareció:
el cálculo, sus entradas, el estado o la presentación.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta. Y la respuesta a
tesorería: cuánto es el error con diez mil números.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`calculateTotalCollectedBroken` hace la aritmética en pesos con decimales y
convierte a centavos al final:

```javascript
// ❌ 0.1 no existe en binario. Ni 0.2. Ni 0.3.
const totalInPesos = soldNumbers.length * raffle.numberPriceInPesos;
const totalInCents = Math.round(totalInPesos * 100);
```

En la consola:

```
> 0.1 + 0.1 + 0.1
0.30000000000000004
> 3 * 0.1 * 100
30.000000000000004
```

Un `double` de la IEEE 754 no puede representar 0,1 exactamente, igual que en
decimal no puedes escribir un tercio con dígitos finitos. La representación real
es un poquito mayor, y al multiplicar por cien ese poquito sale a la superficie. El
`Math.round` a veces lo tapa y a veces no, según hacia qué lado caiga el error —y
eso explica que la diferencia aparezca en unas liquidaciones y en otras no—.

La causa está en la **primera** de las cuatro capas de auditoría de la Fase 8: la
función pura. Y por eso el diagnóstico se hace en una consola de Node, sin abrir el
navegador. Cuando el descuadre aparece ahí, no es React, no es Redux y no es la
red: es aritmética, y terminaste.

**La respuesta a tesorería**

Es la pregunta más importante del ticket y merece un número, no una tranquilización.
El error de representación no es constante ni crece de forma predecible: **depende
de los valores**, y puede cancelarse o acumularse. Con tres números da un centavo;
con diez mil puede dar cero, o puede dar decenas — y, lo que es peor, el mismo
cálculo con los mismos datos da siempre lo mismo, así que parece estable hasta que
un día no lo es.

La respuesta honesta no es *"con diez mil números serían N centavos"*. Es: **este
cálculo no tiene una cota de error que podamos prometer, y por eso hay que sacar el
float en vez de acotarlo.**

> 🧠 **La desproporción es el mensaje.** El síntoma mide un centavo. La causa es
> que el sistema entero está haciendo aritmética de dinero sobre un tipo que no
> puede representar dinero. Un ticket pequeño puede tener una causa estructural, y
> la magnitud del síntoma no dice nada sobre la magnitud del problema. En dinero,
> esa confusión es especialmente cara: **el redondeo esconde el error justo lo
> suficiente como para que nadie lo investigue.**

**Parche mínimo**

Enteros de punta a punta. El precio se guarda en centavos, y no hay ninguna
multiplicación por cien en ningún lado:

```javascript
// El dato entra en centavos y no vuelve a salir de ahí.
const totalInCents = soldNumbers.length * raffle.numberPriceInCents;   // 3 * 10 = 30
```

La Fase 8 es explícita sobre cómo llamar a esto: **no es refactor, es sacar el
float de la línea que lo metió.**

**La refactorización correcta**

Que el float no pueda entrar. Tres piezas:

1. **Un solo tipo de dinero en todo el sistema**, en centavos enteros, con el
   sufijo en el nombre (`numberPriceInCents`, `prizeAmountInCents`). El nombre es
   la mitad de la prevención: `price` a secas no le dice a nadie en qué unidad
   está.
2. **`formatCents` con su aserción de entero**, que es la alarma: si explota, no es
   un bug de `formatCents` sino la prueba de que un cálculo de más arriba devolvió
   un decimal. Es el error común #2 de la Fase 8 y conviene resistir la tentación
   de "arreglarlo" ablandando la aserción.
3. **Repartos con resto explícito.** Al dividir un premio entre ganadores, la
   división entera deja un resto que hay que asignar a alguien por una regla
   escrita, no perderlo en un redondeo. La mecánica está en
   `A10-aritmetica-de-dinero.md`.

**Prueba de regresión**

```javascript
// src/features/settlements/money.test.js
test('el total de tres números a diez centavos es exactamente 30', () => {
  const raffle = { numberPriceInCents: 10 };
  const sold = ['0001', '0002', '0003'];

  const total = calculateTotalCollected(raffle, sold);

  expect(total).toBe(30);              // no toBeCloseTo: exacto o nada
  expect(Number.isInteger(total)).toBe(true);
});
```

El detalle que hace útil este test es lo que **no** usa. `toBeCloseTo` es la
herramienta correcta para medir cosas del mundo físico y la herramienta
equivocada para el dinero: un test de dinero que tolera aproximaciones es un test
que aprueba justamente el bug que tiene que impedir.

**Prevención**

La aserción de entero en la frontera de presentación, el sufijo de unidad en todos
los nombres, y una regla de lint que prohíba multiplicar o dividir cualquier
identificador que termine en `Cents` sin pasar por los ayudantes de `money.js`. Y
un test de propiedad barato: para cualquier precio entero y cualquier cantidad, el
total tiene que ser entero.

**Por qué llegó a producción**

Porque durante años los precios fueron números redondos —mil pesos, dos mil
quinientos—, y con valores así el error de representación se esconde debajo del
redondeo y nunca sale. El bug estuvo escrito y latente durante toda la vida del
sistema, y lo despertó una decisión de negocio: la rifa chica, con números a diez
centavos, que nadie consultó con nadie porque no tenía por qué consultarla.

Y sobrevivió, sobre todo, por una reacción cultural que el ticket anticipa con una
lucidez notable: *"van a decirme que lo redondee"*. En la mayoría de los equipos,
un centavo de diferencia se cierra como "error de redondeo, no es nada". La persona
de tesorería que se negó a firmar hasta entenderlo hizo exactamente lo correcto, y
es la razón por la que este incidente existe.

**Si tu causa fue distinta a esta**

Si dijiste *"falta redondear"*, ese es el reflejo que hay que desarmar: redondear
**es** la causa de que el error se vuelva invisible en unos casos y visible en
otros. Agregar más redondeo no arregla la aritmética, la disfraza mejor. Si dijiste
*"el margen negativo también está mal"* —el error común #4 de la Fase 8—, cuidado:
un margen negativo es un hecho, no un defecto. La casa pagó más premio del que
recaudó, y esconderlo con un `Math.max(0, margin)` es falsear la liquidación.

**Y acá está el cruce con el track BE.** El incidente `be-13` —*"la liquidación dice
340.000 y las ventas suman 355.000"*— tiene un descuadre parecido y una causa
distinta: allá la aritmética está bien y lo que falla es **la fuente de los
datos**, un cliente calculando con una foto vieja. Acá los datos son correctos y el
cálculo los arruina. Cuando una cifra no cuadra, esas son las dos preguntas, en
este orden: *¿el cálculo está mal?* y *¿los datos que entraron eran los de ahora?*

</details>

---

## Incidente 19 — El dashboard se arrastra al final del día

> **Fase:** 9 · **Categoría:** Performance · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min
> · Hermano del incidente `be-05`, con otra causa raíz

### 🎫 El ticket

El tablero de control se arrastra a partir de las seis de la tarde. A la mañana
vuela y a la tarde tengo que esperar dos o tres segundos cada vez que hago clic en
algo, y el ventilador de la máquina se pone a soplar. Al otro día a primera hora
vuelve a andar bien. Las máquinas son las mismas de siempre.

**Reportado por:** supervisor de ventas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir —que en este incidente es la mitad difícil, porque hace falta volumen—,
medir con el Profiler, y arreglar. Y explicar por qué "a la mañana vuela y a la
tarde no" es una descripción precisa del mecanismo, no una exageración.

### 🔧 Preparación

- **Rama:** `incidente/19`
- **Caos:** `off`. El caos agrega latencia de red y acá lo que se mide es tiempo de
  render: mezclarlos hace imposible leer el Profiler.
- **Datos, y son el corazón del incidente:** hace falta **volumen**. Con las tres
  rifas de demostración no se nota nada, y esa es exactamente la razón por la que
  el bug llegó a producción. La rama trae un script que siembra un día completo de
  ventas:

```bash
git checkout incidente/19
node scripts/seedHeavyDay.js       # 40 rifas · ~12.000 números vendidos
CHAOS_LEVEL=off npm run mock
npm start
# Abre /dashboard y cambia de rifa varias veces con el Profiler grabando.
```

> 🧭 Si el script no existe en tu repositorio todavía, escríbelo: es parte del
> incidente. Un bug de rendimiento sin datos que lo despierten es un bug que no
> puedes investigar, y armar el juego de datos es tan trabajo forense como leer el
> Profiler.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

React DevTools → **Profiler**. Graba, interactúa con el tablero, frena, y mira dos
cosas: qué componentes se volvieron a renderizar y —el panel te lo dice— **por
qué**. Un componente que se re-renderiza porque cambió una parte del store que no
usa es una señal fuerte.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Pon un `console.count('computeTopNumbers')` dentro de la función pura, temporalmente,
y cuenta cuántas veces corre por cada interacción. Compara ese número con cuántas
veces **debería** correr, que es: solo cuando cambian los datos de los que depende.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

La memoización está puesta. Mira su array de dependencias con mucha atención y
pregúntate: ese valor que está ahí adentro, ¿es el mismo objeto entre un render y
el siguiente, o es uno nuevo con el mismo contenido?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, y **obligatorio**: cuántas rifas y cuántos números vendidos hay
en el `db.json` con el que reprodujiste. Sin ese número, tu reproducción no la
puede repetir nadie.}}

**Evidencia observable**
{{Los tiempos del Profiler y el número del `console.count`. Este incidente se
diagnostica con dos números, no con una impresión.}}

```
{{render de X ms   ·   computeTopNumbers corrió N veces}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`DashboardPage` memoiza un cálculo caro con una dependencia que se **crea nueva en
cada render**:

```javascript
// ❌ Object.values(...) devuelve un array nuevo cada vez que corre esta línea.
const topNumbers = useMemo(
  () => computeTopNumbers(byNumber),
  [Object.values(byNumber)]
);
```

`useMemo` compara sus dependencias por identidad referencial. Un array recién
creado nunca es idéntico al de la vuelta anterior, aunque tenga exactamente el
mismo contenido, así que la caché se invalida **siempre**. El `console.count` lo
muestra sin ambigüedad: `computeTopNumbers` corre en cada render.

**La memoización existe y no sirve para nada.** Es peor que no tenerla, porque paga
el costo del cálculo y además el de mantener y comparar la caché — y, sobre todo,
porque parece resuelto. Nadie va a sospechar de un `useMemo` que está ahí,
prolijamente escrito, en la línea correcta. Es el error común #1 de la Fase 9.

**Y por qué "a la mañana vuela y a la tarde no"**

Porque el costo de `computeTopNumbers` crece con la cantidad de números vendidos, y
esa cantidad crece a lo largo del día. A las nueve de la mañana el cálculo inútil
tarda un milisegundo y nadie lo nota; a las seis de la tarde, con doce mil ventas
en el store, tarda cientos de milisegundos y ocurre en cada render.

La observación del supervisor es exacta: **no cambió la aplicación, cambió el
tamaño de los datos**. Un bug de rendimiento casi nunca es "el sistema está lento";
es "hay una operación cuyo costo depende de algo que crece". Y por eso el ticket
trae la hora del día: es la variable independiente, servida en bandeja.

> 🧠 **Este es el mismo error del incidente 05 con otra sintaxis.** Allá se
> capturaba un valor una sola vez y no se volvía a preguntar; acá se pregunta
> siempre porque la clave de comparación nunca coincide. Los dos son fallos de
> *identidad*: confundir "el mismo contenido" con "el mismo objeto" es una de las
> dos o tres confusiones que producen más bugs en JavaScript.

**Parche mínimo**

Depender del objeto del store, que sí mantiene su referencia mientras no cambie:

```javascript
const topNumbers = useMemo(() => computeTopNumbers(byNumber), [byNumber]);
```

**La refactorización correcta**

Sacar el cálculo del componente. Un `createSelector` de Reselect memoiza contra el
store, garantiza referencia estable y —lo más importante— **el cálculo del dominio
deja de vivir en la capa de presentación**:

```javascript
// src/features/sales/selectors.js
export const selectTopSoldNumbers = createSelector(
  [(state) => state.sales.byNumber],
  computeTopNumbers
);
```

```javascript
// DashboardPage.jsx — sin useMemo, sin dependencias que vigilar.
const topNumbers = useSelector(selectTopSoldNumbers);
```

La Fase 9 es clara en que esta es la corrección correcta y no un lujo: el
`useMemo` bien puesto arregla este caso, y el selector hace que el caso no pueda
volver a existir desde ningún otro componente que necesite el mismo dato.

**Prueba de regresión**

```javascript
// src/features/sales/selectors.test.js
test('el selector no recalcula si los datos no cambiaron', () => {
  const state = { sales: { byNumber: { '0347': 'sold' } } };

  const first = selectTopSoldNumbers(state);
  const second = selectTopSoldNumbers(state);

  // toBe, no toEqual: lo que se prueba es la IDENTIDAD, no el valor.
  expect(second).toBe(first);
});
```

`toEqual` acá pasaría siempre, incluso con la memoización rota, porque dos
recálculos del mismo dato dan el mismo contenido. Es el error común #3 de la Fase
10, y es la trampa más silenciosa de los tests de memoización: un test verde que no
prueba nada.

**Prevención**

Una regla concreta para las revisiones de código: **en el array de dependencias de
un `useMemo` o un `useCallback` no puede aparecer una llamada a función**.
`[Object.values(x)]`, `[items.filter(…)]`, `[{ id }]` son todos el mismo error. Si
la dependencia hay que calcularla, o se memoiza también, o —mejor— el cálculo entero
se va a un selector.

Y una operativa: medir el tablero con el juego de datos de un día cargado, no con
tres rifas de ejemplo. Un banco de datos realista debería ser parte del repositorio,
no algo que se improvisa el día del incidente.

**Por qué llegó a producción**

Porque en desarrollo hay tres rifas. El `useMemo` se agregó de buena fe —alguien vio
un cálculo caro y lo memoizó, que es exactamente lo que hay que hacer—, se probó, la
pantalla anduvo rápido, y ahí terminó todo. **Con datos de juguete, la memoización
rota y la memoización correcta se comportan igual.** No hay forma de distinguirlas
mirando la pantalla; solo el `console.count` o el Profiler las separan, y nadie los
abre cuando algo va rápido.

Y el segundo motivo es que el rendimiento se degrada gradualmente. No hay un día en
que "se rompió": hay meses en que fue empeorando, y cada semana el sistema estuvo
apenas un poco peor que la anterior, que es la velocidad exacta a la que un equipo
se acostumbra a cualquier cosa.

**Si tu causa fue distinta a esta**

Si dijiste *"faltan `React.memo` en los componentes hijos"*, puede ser cierto y no
es lo principal: mide primero. Agregar memoización sin medir es cómo se llega a este
bug, no cómo se sale de él. Si dijiste *"hay que paginar la tabla"*, también es
razonable y no cambia nada mientras el cálculo se rehaga en cada render: estarías
pintando menos filas y calculando lo mismo. Y si tu fix fue subir el intervalo del
refresco para que haya menos renders, tapaste el síntoma reduciendo la frecuencia
con la que se manifiesta.

**Y acá está el cruce con el track BE.** El incidente `be-05` —*"todo funciona hasta
que hay gente"*— comparte el patrón *"anda bien hasta que crece"* y la causa vive
del otro lado del cable: el pool de conexiones agotado. Cuando algo se degrada con
el volumen, las dos preguntas son *¿qué crece?* y *¿en qué orilla está el recurso
que se acabó?* — acá es tiempo de CPU en el navegador, allá son conexiones a la
base.

</details>

---

## Incidente 20 — El test pasa en mi máquina y falla en la de al lado

> **Fase:** 10 (se abre) · 11 (se cierra) · **Categoría:** Testing · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 70-90 min
> · Hermano del incidente `be-15`, con otra causa raíz

### 🎫 El ticket

Subí un cambio que no toca nada de fechas y el pipeline se puso en rojo con un test
de `MetricCard` que yo ni miré. En mi máquina pasa. Le pedí a un compañero que lo
corriera y a él también le pasa. En el servidor de integración falla siempre.
Llevamos tres días sin poder integrar nada y ya hay dos personas corriendo la suite
con el test salteado para poder trabajar.

**Reportado por:** el propio equipo
**Ambiente:** CI (en desarrollo "pasa")

### 🎯 Qué se te pide

Este incidente cierra el arco del cuaderno y es el único que **no se reproduce en
la aplicación sino en la suite de pruebas**. El entregable tiene tres partes, y la
tercera es la que importa:

1. Reproducirlo **en tu máquina**, que —adelanto— no se logra tocando el código.
2. Localizar la causa, y contestar una pregunta que suena filosófica y es
   perfectamente práctica: **¿el test está mal, o el test tiene razón?**
3. **Tomar una decisión y escribirla**: hotfix o refactorización, con sus
   consecuencias. Este es uno de los tres incidentes del cuaderno que **no termina
   en un parche**, sino en un documento que alguien firma.

> 🧭 **Se abre en la Fase 10 y se cierra en la Fase 11.** La Fase 10 te da las
> herramientas para reproducirlo; el criterio para decidir —cuándo un parche es
> profesional y cuándo es una tapadera— es lo que aporta la Fase 11. Si llegaste
> acá desde la 10, reprodúcelo y déjalo en 🟡 En análisis.

### 🔧 Preparación

- **Rama:** `incidente/20`
- **Caos:** no aplica; no hay red en juego.
- **Datos:** ninguno del `db.json`. Lo que hace falta es cambiar **tu máquina**, y
  ahí está la primera lección: la reproducción de este incidente no se consigue
  editando archivos.
- **Y hay que declarar dos cosas** que en el resto del cuaderno son contexto y acá
  son el mecanismo: **la zona horaria** y **la hora del sistema** de la máquina que
  corre la suite.

```bash
git checkout incidente/20
npm test -- MetricCard                          # tu zona horaria: pasa
TZ=UTC npm test -- MetricCard                   # la del runner: falla
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Ni el test ni el código cambiaron, así que lo que cambió es **dónde corre**. Antes
de abrir un archivo, escribe la lista de todo lo que difiere entre tu máquina y el
servidor de integración: sistema operativo, versión de Node, configuración
regional, **zona horaria**, hora del sistema. Después tacha las que no puedan
afectar a un componente que muestra una fecha.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El `MetricCard` de fechas y lo que le llega por props. La pregunta concreta:
**¿quién decide qué día es "hoy"?** Busca de dónde sale ese dato y cuántas veces
podría dar respuestas distintas para el mismo instante.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Corre el test con `TZ=UTC` delante. Si cambia el resultado, la pregunta ya no es
"por qué falla el test" sino **"por qué el resultado del componente depende de la
máquina que lo ejecuta"**.

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, y **obligatorio**: la zona horaria y la hora del sistema en cada
intento, tuyas y las del runner. Sin esos cuatro datos este incidente no se puede
contar.}}

**Evidencia observable**
{{La salida del test en las dos configuraciones, con el texto esperado y el
recibido.}}

```
{{TZ=...  → verde     ·     TZ=UTC  → esperaba "20/12", recibió "21/12"}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó. Anota especialmente si
  pasaste por "es un test flaky" y cómo lo descartaste}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y la respuesta a la pregunta: ¿el test está mal o tiene razón?}}

**Tu decisión**
{{Acá no va un parche: va una decisión argumentada. Cuál de los dos caminos tomas,
qué te cuesta, qué queda sin resolver, quién tiene que estar de acuerdo, y en qué
fase se paga lo que dejas pendiente. Escríbelo como se lo mandarías a tu equipo.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El `MetricCard` de fechas calcula "hoy" con `new Date()` adentro del componente y
lo formatea con la zona horaria de la máquina. El test asegura un texto concreto.
En tu máquina, en `-05:00`, el instante de la prueba cae el día 20; en el runner,
que corre en `UTC` —el valor por defecto de prácticamente todos los servidores de
integración—, el mismo instante cae el día 21. El test dice que esperaba `20/12` y
recibió `21/12`, y las dos afirmaciones son correctas.

**Y ahora la pregunta del enunciado: el test tiene razón.**

Esto es lo que hay que llevarse del incidente. La lectura cómoda es "el test es
frágil, arreglemos el test". La lectura correcta es que el test **descubrió un
defecto real del componente**: su salida depende de estado ambiente —el reloj y la
zona horaria de quien lo ejecuta— que nadie le pasó y que nadie eligió. Ese mismo
defecto, en producción, es el incidente 16 en otra pantalla: dos usuarios en
provincias distintas ven cosas distintas sobre el mismo dato.

> 🧠 **Un test no es flaky solo porque falle donde no esperabas.** Descarta esa
> hipótesis con un número: en el runner falla el **100%** de las veces, y en tu
> máquina el **0%**. Eso no es aleatoriedad: es un resultado perfectamente
> determinista en dos ambientes distintos. Flaky sería fallar a veces en el
> **mismo** ambiente. Confundir las dos cosas lleva directo a la peor decisión
> posible, que es reintentar el test hasta que pase.

Y el detalle más grave del ticket no es el rojo: es que **dos personas ya lo están
salteando**. Un test que el equipo aprende a ignorar es peor que un test que no
existe, porque sigue contando en la cobertura y ya no protege nada. Cada día que
el rojo sobrevive, más gente aprende a convivir con él.

**La decisión, que es el entregable**

**Opción A — el hotfix.** Fijar el ambiente de la suite: la zona horaria y el reloj,
en la configuración de Jest.

```javascript
// jest.setup.js
process.env.TZ = 'America/Bogota';
jest.useFakeTimers().setSystemTime(new Date('2024-12-20T15:00:00-05:00'));
```

Cuesta quince minutos, desbloquea el pipeline hoy y **no arregla nada**: el
componente sigue siendo no determinista en producción. Peor todavía, fijar una sola
zona horaria en los tests **esconde la familia entera de errores del incidente
16**, porque garantiza que ninguna prueba vuelva a ejercitar otra zona.

**Opción B — la refactorización.** Que el reloj sea una dependencia explícita: el
`MetricCard` recibe `now` por props o por contexto, y no llama a `new Date()` nunca.
El componente se vuelve una función pura de sus entradas, el test deja de depender
de la máquina, y de paso queda abierto el camino para pagar la deuda 💸 de
`serverNow` que la Fase 7 declaró: que la hora de referencia venga del servidor y
no del navegador.

Cuesta más, toca varios componentes y no se termina en una tarde.

**La decisión recomendada, y por qué**

Aplicar **A hoy**, con dos condiciones que son las que la separan de una tapadera:

1. **La suite corre en más de una zona horaria**, no en una fija. Es una matriz de
   dos o tres valores en el pipeline, y convierte el hotfix en algo que además
   protege:

```javascript
// jest.setup.js — la zona la decide el pipeline, no el archivo.
process.env.TZ = process.env.TEST_TZ || 'UTC';
```

2. **Queda anotado en `A12-mapa-de-deuda-tecnica.md`** con su fecha y su destino, y
   **B se agenda en la Fase 11**, que es donde el curso paga deuda. Una deuda que
   no está escrita no es una deuda: es un olvido con buena intención.

Y la parte que casi nunca se hace: **escribirlo**. Que quede dicho que se eligió el
parche a sabiendas, qué queda sin resolver y cuándo se paga. Un hotfix documentado
y agendado es una decisión profesional; el mismo hotfix sin escribir es cómo nace
la deuda que nadie recuerda haber contraído.

> 🧭 **Y esto es lo que distingue a este incidente de los otros diecinueve.** Acá no
> hay un `git diff` que sea la respuesta. El entregable es un párrafo, una entrada
> en el mapa de deuda y un acuerdo. En un equipo de mantenimiento real, buena parte
> del trabajo termina así — y casi nunca se practica.

**Prueba de regresión**

```javascript
// src/features/dashboard/MetricCard.test.jsx
describe.each(['UTC', 'America/Bogota', 'Asia/Tokyo'])('en %s', (tz) => {
  beforeAll(() => { process.env.TZ = tz; });

  test('muestra la fecha del cierre, no la de la máquina', () => {
    render(<MetricCard label="Cierre" date="2024-12-20T20:00:00-05:00" now={FIXED_NOW} />);

    // El mismo texto en las tres zonas: eso es lo que se está probando.
    expect(screen.getByText('20/12/2024')).toBeInTheDocument();
  });
});
```

Igual que en el incidente 16, la forma del test **es** la corrección: la misma
aserción repetida en varias zonas horarias. Un test de fechas que corre en una sola
zona no prueba nada sobre fechas.

**Prevención**

Tres cosas, en orden de valor. La matriz de zonas horarias en el pipeline, que es
lo único que impide que esto vuelva. Una regla de revisión: **`new Date()` no se
llama dentro de un componente** — el reloj es una dependencia y se inyecta como
cualquier otra. Y una política sobre los tests rojos: un test que falla se arregla
o se borra, con su motivo; saltearlo no es una tercera opción.

**Por qué llegó a producción**

Porque nadie decidió nunca cuál era la zona horaria de la suite, y el valor por
defecto es "la de quien la corra". Mientras la suite solo corrió en las máquinas
del equipo —todas en la misma zona— la ambigüedad no tuvo consecuencias. El día que
se creó el pipeline se agregó un ejecutor más, en UTC, y la divergencia nació ahí:
**no la produjo un cambio de código, la produjo un cambio de participantes.**

Y el segundo motivo es que el sistema no tuvo tests durante años
(`00-historia-del-sistema.md` §3: la Era 1 no dejó ninguno). Una suite joven sobre
un código viejo va a encontrar defectos que llevaban años ahí, y los va a reportar
todos juntos, en forma de rojos que parecen problemas de la suite. Sostener que el
test tiene razón, en ese contexto, requiere más carácter que conocimiento.

**Si tu causa fue distinta a esta**

Si dijiste *"es flaky, hay que reintentarlo"*, mira arriba: 100% y 0% no es
aleatoriedad. Si dijiste *"el runner tiene mal la hora"*, no: el runner tiene la
hora perfectamente bien, en UTC, que es la configuración correcta para un servidor.
El que hace una suposición indebida es el componente. Y si tu fix fue cambiar el
texto esperado del test para que coincida con lo que devuelve el runner, dejaste el
pipeline en verde y el componente roto en las dos zonas — y ahora el test miente en
tu máquina.

**Y acá está el cruce con el track BE.** El incidente `be-15` —*"la suite lleva tres
semanas en verde y ayer se rompió producción"*— es el mismo patrón con otro
sustituto: allá lo que engaña no es el reloj sino **el motor de la base**, con la
suite corriendo contra SQLite y producción contra PostgreSQL. Los dos incidentes
enseñan lo mismo desde orillas opuestas: **una prueba solo vale lo que valga su
parecido con el ambiente real**, y cada diferencia que aceptas —el reloj, la zona,
el motor, la latencia— es una clase de bug que tu suite no va a encontrar jamás.

Y hay una simetría que vale la pena notar: en `be-15` la suite estaba **verde** y
mentía; acá está **roja** y dice la verdad. La reacción instintiva es desconfiar del
rojo y confiar en el verde, y en los dos casos es la reacción equivocada.

</details>

---

# 🪞 Retrospectiva del mes

Se llena al terminar, de una sola vez, releyendo tu propio `git log`.

- **Cuántos abriste, cuántos cerraste, cuántos quedaron ⚪.**
- **Cuántas veces tu causa raíz coincidió con la de referencia**, y en cuáles no.
  El patrón importa más que el número.
- **En qué capa te costó más**: componente, store, epic, interceptor, mock,
  build. Si la respuesta es "epic", estás en buena compañía.
- **Qué pista abriste antes de tiempo y por qué.** Sin culpa; es un dato sobre
  dónde te falta confianza, no sobre tu disciplina.
- **Tu checklist de hotfix**, la de una página, reescrita con lo que aprendiste
  acá. Es lo único de este archivo que te llevas al trabajo real.

> **La señal de que quedó bien:** cuando te llegue un ticket que dice "a veces no
> anda" y tu primera reacción no sea abrir el código, sino preguntar *"¿en qué
> ambiente, a qué hora y qué viste en la pantalla?"*.

---

# 📌 Pendientes que salieron de los incidentes

Lo que apareció investigando y no cabía en el fix, con el ID que lo originó y su
destino sugerido.

- **[NN]** {{pendiente}} → sugerido para {{apéndice / fase / ejercicio 🔥}}.
