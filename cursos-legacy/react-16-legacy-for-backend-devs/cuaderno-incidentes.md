# 📓 Cuaderno de incidentes
## Tutorial React 16 — La Esclusa, la consola de Jewel Locks

> Documento vivo · Se trabaja solo · El changelog es `git log -- cuaderno-incidentes.md`
> El tiempo de los incidentes ya está contado dentro de las 98 h del track base
> (`00-alcance-del-proyecto.md` §7); no es un bloque aparte que se suma al final.

Este es el único archivo de incidentes del curso. Acá viven los enunciados, las
pistas, las soluciones de referencia y —sobre todo— tu registro de cómo llegaste
a cada una. Los veintiún incidentes vienen reservados de antemano por las fases que
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

### El post-mortem en ocho puntos

Cada incidente se cierra con un post-mortem, y es la misma estructura que piden
los ejercicios de post-mortem de las fases:

1. **Síntoma**, en palabras del usuario.
2. **Pasos de reproducción** exactos.
3. **Evidencia observable**: consola, Network, DevTools, logs.
4. **Causa raíz**, hasta la línea o el commit.
5. **Corrección** aplicada.
6. **Prueba de regresión** que falla antes del fix y pasa después.
7. **Prevención**: un test, un feature flag o una alerta.
8. **Análisis sin culpabilización** (*blameless*): se mira el sistema y el
   proceso, no a la persona.

Los puntos 1 a 6 tienen traducción exacta a git —el par de tags `-roto` / `-fix`
de `00-convencion-de-git-y-tags.md`—, y el tono baja un punto de humor: un
post-mortem es sereno y analítico.

### Convención de commits

El asunto del commit sigue este formato, para que `git log --oneline` se lea como
la línea de tiempo de tu investigación:

```
incidente(14): abre — el servidor sigue recibiendo peticiones tras el logout
incidente(14): repro — los GET /purchases/tok-oxxo-2 siguen saliendo cada 2 s, sin token
incidente(14): hipótesis descartada — no es el switchMap: después del logout no llega otro startPolling
incidente(14): causa — el takeUntil del pollingEpic no escucha el logout, y la pantalla no para al irse
incidente(14): fix — el logout en el takeUntil, último en el pipe interno
incidente(14): cierre — prueba de canicas de cancelación y post-mortem
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
| "Se compensó dos veces" | Redux DevTools: la secuencia entera | store, epic | 11 |
| "Cambió solo, nadie lo tocó" | espera sin tocar nada, mirando DevTools | temporizador, epic | 12, 14 |
| "Falló una vez y no anda más" | Network: ¿sale **alguna** petición? | epic | 13 |
| "Sigue pasando después de salir" | Network, en reposo | epic | 14, 12 |
| "La cuenta no cuadra" | la función pura, en una consola de Node | cálculo | 18 |
| "Todo se arrastra desde que abrí el tablero" | la consola del navegador, y Performance | store (middleware) | 19 |
| "La rueda no da lo que publica" | el tablero, y la bitácora por jugador | API (la regla) | 21 |
| "Verde en mi máquina, rojo en CI" | `TZ=UTC npm test` | suite, componente | 20 |

Una advertencia sobre la última columna: es una lista de **candidatos**, no un
diagnóstico. Dos incidentes de este cuaderno pueden compartir síntoma y no
compartir nada más — el 07 y el 10 son el caso arquetípico, y se separan con una
sola columna de Network—. Empezar por el candidato equivocado no es un problema
mientras la evidencia te saque de ahí rápido; empezar por el código sí lo es.

---

## 📋 Índice

Lo actualizas en el mismo commit que abre o cierra un incidente.

Los veintiún IDs vienen reservados por las fases que los producen, y el título es el
que va a llegar en el ticket — con su vaguedad incluida. Los veintiún enunciados
están redactados más abajo; el ⬜ de la última columna es **tu** estado, no el del
archivo, y arranca en "sin empezar". El ID **nunca** se reasigna.

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| 01 | 0 | Bajé el repo y `npm start` explota antes de abrir nada | Entorno | 🟢 | ⬜ |
| 02 | 0 | En la máquina de al lado compila y en la mía no | Entorno | 🟢 | ⬜ |
| 03 | 1 | Hago clic en el menú y se recarga toda la aplicación | UI / routing | 🟢 | ⬜ |
| 04 | 1 | Entro al detalle de otra rueda y sigo viendo la anterior | UI / routing | 🟡 | ⬜ |
| 05 | 2 | Después de entrar, mis peticiones salen sin token | Autenticación | 🟡 | ⬜ |
| 06 | 2 | Cerré sesión pero la pantalla sigue mostrando mi usuario | Autenticación | 🟡 | ⬜ |
| 07 | 3 | A veces no entra y no dice nada | Integración | 🟡 | ⬜ |
| 08 | 3 | Me saca a login al azar mientras estoy trabajando | Integración | 🟡 | ⬜ |
| 09 | 4 | Guardo la rueda, la pantalla se recarga y pierdo lo que escribí | Estado (store) | 🟢 | ⬜ |
| 10 | 4 | La lista de ruedas se queda cargando para siempre | Estado (store) | 🟡 | ⬜ |
| 11 | 5 | Compensamos dos veces a la misma jugadora ⭐ | Concurrencia | 🔴 | ⬜ |
| 12 | 5 | Un envío que ya estaba enviado volvió a «falló» | Concurrencia | 🟠 | ⬜ |
| 13 | 6 | Falló un envío y desde entonces no sale ninguno | RxJS / epics | 🟠 | ⬜ |
| 14 | 6 | Cerré sesión y el servidor sigue recibiendo peticiones ⭐ | RxJS / epics | 🟠 | ⬜ |
| 15 | 6 | Busco a la jugadora rápido y me muestra a otra | RxJS / epics | 🟠 | ⬜ |
| 16 | 7 | Seguimos enviando giros de una rueda que ya cerró | Tiempo | 🟠 | ⬜ |
| 17 | 7 | La compra pendiente nunca se confirma, y la consola dice que sigue consultando | RxJS / epics | 🟠 | ⬜ |
| 18 | 8 | La conciliación da un centavo de diferencia | Dinero | 🟠 | ⬜ |
| 19 | 9 | El dashboard se arrastra al final de la Semana del Canal | Performance | 🟠 | ⬜ |
| 20 | 10-11 | El test pasa en mi máquina y falla en la de al lado | Testing | 🔴 | ⬜ |
| 21 ➕ | 9 | La rueda dice 15 % y el tablero muestra 5 % | Dominio | 🟠 | ⬜ |

### 🔥 Reserva del track BE

El track opcional de backend produce sus propios incidentes, y para que nunca
choquen con los de arriba tienen **rango propio, `be-NN`**, y viven en su propio
archivo:

> 📓🔥 **[`cuaderno-incidentes-be.md`](cuaderno-incidentes-be.md)** — los
> incidentes del track BE, **redactados**, con la misma estructura, las mismas
> reglas y el mismo tono que este cuaderno.

**Por qué en un archivo aparte**, si arriba dice que este es el único archivo de
incidentes del curso: porque el track BE es opcional, y quien haga solo las 98
horas del track base no debería encontrarse los incidentes de Go y Postgres
intercalados entre los suyos. La divergencia está declarada allá y los rangos de
IDs no colisionan. Sus enunciados siguen la misma estructura que estos, con las
herramientas del backend en vez de las del navegador.

**Seis de ellos son hermanos de incidentes de este cuaderno**: mismo
síntoma, otra capa, otra causa raíz. Resolverlos en pareja enseña más que
resolverlos sueltos, y el cruce está en el índice de aquel archivo.

| Este cuaderno | Track BE | Qué cambia |
|---|---|---|
| 11 — la compensación doble ⭐ | `be-09` ⭐ | Acá el store y un chequeo en dos pasos; allá el mismo chequeo en dos pasos, dentro de una transacción que no excluye |
| 16 — los giros de una rueda que ya cerró | `be-12` | Acá la consola compara mal el instante; allá, quién tiene autoridad sobre el reloj |
| 18 — la conciliación da un centavo de diferencia | `be-13` | Acá el redondeo por fila; allá la fuente de los datos |
| 19 — el dashboard se arrastra al final de la Semana del Canal | `be-05` | Acá los chequeos de desarrollo con el volumen del evento; allá el pool de conexiones agotado |
| 20 — el test pasa en mi máquina y falla en la de al lado | `be-15` ⭐ | Acá la zona horaria del runner; allá el **motor** de la base |
| 08 — la sesión se cae sola | `be-08` | Acá el `401` del caos; allá un `exp` real sin renovación |

Sus categorías propias son **base de datos**,
**transacciones**, **despliegue** y **contrato**, y se suman a las de abajo.

Un incidente `be-NN` puede compartir síntoma con uno del track base y tener otra
causa raíz: ese paralelo es deliberado y es de lo más formativo que ofrece el
track. El caso arquetípico es el 11 —la jugadora compensada dos veces—, que en
el track base se diagnostica en el store y en el track BE se resuelve con un
índice único y una transacción.

**Categorías:** entorno · UI / routing · autenticación · integración ·
estado (store) · concurrencia · RxJS / epics · tiempo · dinero · performance ·
testing · dominio · 🔥 base de datos · 🔥 transacciones · 🔥 despliegue · 🔥 contrato.

**Dificultad:** 🟢 fácil · 🟡 intermedio · 🟠 difícil · 🔴 muy difícil.
**⭐** marca los dos incidentes más formativos del curso: la doble compensación
(11) y la suscripción zombi del epic (14). **➕** marca el que termina en una
decisión y no en un commit (21).

> 📝 **Por qué cinco de los veintiuno son de RxJS.** Los incidentes 13, 14, 15 y 17
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
- **Reproducción en contenedor:** parcial. `node-sass` 4.14.1 compila en `node:14` arm64 mientras la imagen tenga Python 2 (la trae). El `node-gyp` que falla es el de una máquina sin Python 2 o con `npm_config_python=python3`, que es el caso de un Mac; el fenómeno del USB necesita dos máquinas. Ambos se verifican a mano.
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
pinta tarjetas de ruedas, y qué paquete lo está invocando.

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

Desde que tocaron el menú de arriba, cada vez que hago clic en "Ruedas" la pantalla
se pone en blanco un segundo y después carga. Antes era instantáneo. Y hay algo
peor: si estaba llenando el formulario de una rueda y hago clic en el menú, cuando
vuelvo se me borró todo lo que había escrito.

**Reportado por:** supervisor de operación
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar la línea culpable y aplicar el hotfix. Y como ejercicio
aparte: explicar por qué *"se me borra lo que estaba escribiendo"* es la mejor
frase del ticket, mucho mejor que *"se pone en blanco"*.

### 🔧 Preparación

- **Rama:** `incidente/03`
- **Caos:** no aplica; es determinista y se reproduce el 100% de las veces.
- **Datos:** no aplica; con las ruedas de demostración alcanza.

```bash
git checkout incidente/03
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No abras el código todavía. Abre DevTools en la pestaña **Network**, marca
*Preserve log*, y haz clic en el menú. Cuenta cuántas peticiones aparecen y de
qué **tipo** son. Después haz lo mismo navegando desde un enlace de la tabla de ruedas, que no tiene el problema, y compara las dos listas.

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
un `<a href="/wheels">`? ¿Y qué le queda al árbol de componentes que estaba
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

`src/components/Navbar.jsx`: el enlace del menú es un `<a href="/wheels">` en vez
de un `<Link to="/wheels">`. Es el error común #3 de la Fase 1.

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

> 📝 **Nota de época.** El `Navbar` es de la Era 1 (2019), escrito por la
> agencia de San José contra la fecha del evento de Navidad
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

// ❌ antes: <a href="/wheels">Ruedas</a>
// ✅ ahora: el clic lo maneja Router, no el navegador.
<Link to="/wheels">Ruedas</Link>
```

**La refactorización correcta**

`NavLink` en vez de `Link` para los enlaces del menú, que además resuelve marcar
cuál está activo sin comparar rutas a mano:

```javascript
<NavLink to="/wheels" activeClassName="active">Ruedas</NavLink>
```

Y una regla de lint que prohíba `<a href>` con rutas internas, porque este bug se
reintroduce solo: es una etiqueta de tres caracteres que nadie mira en una
revisión de código sobre estilos.

**Prueba de regresión**

En jsdom un ancla no recarga nada —simplemente no navega—, y eso juega a nuestro
favor: el test falla antes del fix porque la ruta **no cambia**, y pasa después
porque `Link` sí la cambia.

```javascript
// src/components/Navbar.test.jsx (la misma prueba que corre en el repo de prueba)
import React from "react";
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { MemoryRouter, Route } from "react-router-dom";
import Navbar from "./Navbar";

test("el menú navega sin recargar el documento", () => {
  let currentPath = null;
  render(
    <MemoryRouter initialEntries={["/"]}>
      <Navbar />
      <Route path="*" render={({ location }) => { currentPath = location.pathname; return null; }} />
    </MemoryRouter>
  );
  userEvent.click(screen.getByText("Ruedas"));
  expect(currentPath).toBe("/wheels");
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

## Incidente 04 — Entro al detalle de otra rueda y sigo viendo la anterior

> **Fase:** 1 · **Categoría:** UI / routing · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min

### 🎫 El ticket

Tengo la lista de ruedas. Abro la Esclusa de Oro, la miro, vuelvo atrás y abro la Semana del Canal… y me sigue mostrando la Esclusa de Oro. Arriba, en la barra del navegador, dice que estoy en la 2, pero abajo el nombre y los datos son los de la 1. Si aprieto F5 ahí sí aparece la correcta. Yo creo que se confunde por los nombres parecidos.

**Reportado por:** operadora de soporte
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir y decidir **cuál de dos causas plausibles** lo está provocando. Las dos
producen exactamente este síntoma y las dos se "arreglan" con cambios distintos
que funcionan. El entregable no es el parche: es la evidencia que descarta una de
las dos.

Y de paso, descartar la teoría de los nombres parecidos. Los tickets suelen traer una, casi
siempre es incorrecta, y desmontarla con evidencia en vez de ignorarla es parte
del trabajo.

### 🔧 Preparación

- **Rama:** `incidente/04`
- **Caos:** no aplica; determinista.
- **Datos:** ya están en `mock/wheels.js`: `Esclusa de Oro` con `id: 1` y `Semana del Canal` con `id: 2`. Nombres bien distintos, para que el síntoma sea inconfundible.

```bash
git checkout incidente/04
npm start
# Navega: /wheels → detalle de la 1 → atrás → detalle de la 2
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

React DevTools, pestaña **Components**, selecciona `WheelDetailPage` y déjala
seleccionada mientras navegas de una rueda a la otra. Mira dos cosas **al mismo
tiempo** en el panel derecho: lo que trae `useParams` y lo que hay en el estado.
Uno de los dos cambia y el otro no. Cuál es cuál te dice casi todo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Activa **"Highlight updates when components render"** en las opciones de React
DevTools y navega otra vez. La pregunta que separa las dos causas es una sola:
¿el componente **se re-renderiza** al cambiar de rueda, o ni se entera?

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
{{params.id = ...   ·   state.wheel = ...}}
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

`src/pages/WheelDetailPage.jsx` guarda la rueda en estado local, inicializado con
el `id` de la URL, y nadie lo vuelve a tocar:

```javascript
// ❌ El inicializador de useState corre UNA sola vez, en el primer montaje.
const { id } = useParams();
const [wheel, setWheel] = useState(findWheel(id));
```

Al navegar de `/wheels/1` a `/wheels/2`, Router 5 renderiza el mismo componente
en la misma posición del árbol, así que React **reutiliza la instancia**: no la
desmonta, la vuelve a renderizar con parámetros nuevos. `useParams` devuelve
`"2"`, el componente se re-renderiza… y `useState` ignora por completo el
argumento que le pasas a partir del segundo render. El estado se quedó con la
rueda 1, para siempre.

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
  setWheel(findWheel(id));
}, [id]);
```

**La refactorización correcta**

No guardar en estado algo que es **derivado** de la URL. La rueda no es información
del usuario: es una función del `id`, y se calcula en el render.

```javascript
const { id } = useParams();
const wheel = findWheel(id);   // sin useState, sin useEffect, sin sincronizar
```

El estado local se reserva para lo que el usuario cambia y el sistema no puede
recalcular. Esta es la versión de una línea de una regla que vale para todo el
curso, y que en Fase 4 vuelve con el store de por medio.

**Prueba de regresión**

```javascript
// src/pages/WheelDetailPage.test.jsx (la misma prueba que corre en el repo de prueba)
import React from "react";
import { render, act } from "@testing-library/react";
import { MemoryRouter, Route } from "react-router-dom";
import WheelDetailPage from "./WheelDetailPage";

test("al cambiar el id de la ruta, muestra la rueda nueva", () => {
  let history = null;
  const { container } = render(
    <MemoryRouter initialEntries={["/wheels/1"]}>
      <Route path="/wheels/:id" component={WheelDetailPage} />
      <Route render={(props) => { history = props.history; return null; }} />
    </MemoryRouter>
  );
  expect(container.querySelector("h1").textContent).toBe("Esclusa de Oro");
  act(() => history.push("/wheels/2"));
  expect(container.querySelector("h1").textContent).toBe("Semana del Canal");
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
cámbiale el nombre a una de las dos ruedas por algo irreconocible y el síntoma
sigue igual. Descartada con evidencia, en treinta segundos. Si dijiste *"falta un
`exact` en la ruta"*, mira la URL: el error común #2 de la Fase 1 te dejaría
viendo el **listado**, no un detalle equivocado. Y si tu fix fue `key={id}` en la
`Route` y funcionó, lee otra vez el apartado de arriba: funciona, no es la causa,
y tiene un costo que hoy no se nota.

</details>

---

## Incidente 05 — Después de entrar, mis peticiones salen sin token

> **Fase:** 2 · **Categoría:** Autenticación · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-40 min

### 🎫 El ticket

Entro con mi usuario y mi contraseña y me deja pasar sin problema: veo el menú y arriba a la derecha aparece mi nombre. Pero las peticiones que la consola manda después de entrar no llevan nada que identifique mi sesión: en la herramienta de red no aparece ningún `Authorization`. Probé cerrando y volviendo a entrar y pasa lo mismo.

**Reportado por:** operadora de soporte
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Reproducir y localizar la capa. Hay una contradicción en el sistema —dos fuentes
que dicen cosas distintas sobre la misma sesión— y encontrarla es el noventa por
ciento del trabajo. El fix es de una línea.

### 🔧 Preparación

- **Rama:** `incidente/05`
- **Caos:** no aplica en esta fase: el mock todavía no tiene caos (llega en Fase 3).
- **Datos:** `mock/db.json`, con los usuarios de la fase.
- **Qué no se ve:** el mock no valida el token, ni en esta fase ni en ninguna del track base. El síntoma se ve en el header y en el store. El único `401` que vas a ver es el aleatorio del caos (Fase 3); la validación real del token llega con el track BE (`be04`).

```bash
git checkout incidente/05
npm run mock:api
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Hay dos lugares donde este sistema guarda la verdad sobre tu sesión, y todavía no
sabes si dicen lo mismo. Uno es el store: míralo en Redux DevTools después de
loguearte. El otro es lo que efectivamente sale por el cable: míralo en Network,
en **Request Headers** —no en Response—, de cualquier petición a una rueda.
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
petición antes de que salga; acá la petición sale sin header. El mock no valida el token en ninguna fase del track base: que la petición llegue sin header no produce un `401`, y por eso el síntoma hay que buscarlo en Network y no en un error. Y si tu fix fue guardar el token en una variable global que
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
sola y tuve que cerrarla a la fuerza. Me preocupa que en una consola compartida
quede la sesión de otro.

**Reportado por:** supervisor de operación
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir los dos síntomas —el nombre que se queda y el titileo— y decidir una
cosa antes de tocar código: **¿es un bug o son dos?** El entregable es esa
respuesta, con evidencia. Después, el fix de lo que corresponda.

Este incidente se resuelve mirando, no leyendo código. Si terminas con el editor
abierto antes de haber mirado Redux DevTools, vuelve atrás.

### 🔧 Preparación

- **Rama:** `incidente/06`
- **Caos:** no aplica en esta fase.

- **Datos:** el `db.json` de la fase. Loguéate con un usuario cuyo nombre se vea
  claramente en la barra superior.

```bash
git checkout incidente/06
npm run mock:api
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
envuelve la ruta `/login` en `src/AppRouter.jsx`. Son dos archivos distintos, y esa es
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

Y la preocupación del supervisor es correcta y no es paranoia: en una consola
compartido, el nombre de la operadora anterior queda a la vista. No es una fuga de
datos grave, pero es exactamente el tipo de detalle por el que un cliente pierde
la confianza en un sistema.

**Bug B — el titileo.** `src/AppRouter.jsx`: la ruta `/login` quedó envuelta en
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
// AppRouter.jsx — /login es pública, siempre.
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
había que probar —cerrar sesión y comprobar que ya no se puede entrar a una rueda—
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

## Incidente 07 — A veces no entra y no dice nada

> **Fase:** 3 · **Categoría:** Integración · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-50 min

### 🎫 El ticket

A veces no entro. Pongo mi usuario y mi contraseña, toco "Iniciar sesión" y el
botón se queda en "Ingresando…" para siempre. No aparece ningún error ni nada más.
Si recargo, generalmente sale bien. A mi compañera también le pasa, pero menos.

**Reportado por:** operadora de soporte
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo **cuando tú quieras**, no cuando le toque al azar. Ese es el
entregable principal: un procedimiento determinista. Después, localizar la capa y
aplicar el fix.

> 🧭 **Este es el ticket vago canónico del curso**, y por eso conviene decir en voz
> alta lo que va a sonar raro: *"a veces"* y *"para siempre"* son los dos datos
> **más valiosos** del reporte. Una frecuencia es una pista sobre el mecanismo.

### 🔧 Preparación

- **Rama:** `incidente/07`, que quita el `timeout` de la instancia de `apiClient`.
  Es un cambio de una línea y no toca ningún componente.
- **Caos:** `CHAOS_LEVEL=high` en el mock del puerto `3001`. **Obligatorio.** Con
  `low` el timeout casi no aparece, y con `off` no aparece jamás.
- **Datos:** `mock/db.json`, con los usuarios de la fase.

```bash
git checkout incidente/07
CHAOS_LEVEL=high npm run mock:api
npm start
# Entra y sale varias veces hasta que el botón se quede pegado.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes de la aplicación, mira **el mock**. "Para siempre" significa que una petición
nunca termina, y el mock es el único que decide si una petición responde. Hay un
archivo en este proyecto donde está escrito qué fallo le toca a cada respuesta.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Network, con la columna **Status** y la columna **Time** a la vista. Ordena por
Time y repite el login. Vas a encontrar una petición que no tiene status, porque no
terminó. Ahora la pregunta es de la otra orilla: ¿cuánto tiempo está dispuesto a
esperar el cliente?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Cuál es el valor por defecto de `timeout` en axios, y qué significa ese valor?
¿Y en qué estado se queda el `login` de la Fase 2 cuando su promesa nunca se
resuelve ni se rechaza?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Acá lo que se evalúa es que sea determinista. "Intentar hasta que pase" no es un
procedimiento de reproducción: es esperar. Cuenta cuántos intentos hacen falta con
la semilla que uses.}}

**Evidencia observable**
{{La fila de Network de la petición que no termina, y el estado del store mientras
tanto (`loading`, `error`).}}

```
{{status, time, y qué dice state.auth.loading}}
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

**Causa raíz**

`src/api/apiClient.js`: la instancia se crea sin `timeout`. Axios, por defecto, no
corta ninguna petición: espera a que el servidor responda, pase lo que pase. El mock,
con `CHAOS_LEVEL=high`, a veces no responde (es el fallo de tipo *timeout*: el
servidor recibe la petición y no contesta). La promesa de `authService.login` nunca
se resuelve ni se rechaza, así que el thunk `auth/login/pending` queda como la última
acción despachada: `loading` se queda en `true` para siempre y el botón en
"Ingresando…".

El síntoma "a veces" es la probabilidad del caos (2 % de timeouts en el nivel alto),
y el "para siempre" es la ausencia de un tiempo máximo. Son dos datos del mismo
defecto.

**Evidencia que lo confirma**

En Network, una petición `/users` sin status y con un tiempo que crece mientras el
botón sigue pegado. En el store, `auth/login/pending` como última acción: sin
`fulfilled` ni `rejected`.

**Parche mínimo**

```javascript
// src/api/apiClient.js — la instancia tiene un tiempo máximo
const apiClient = axios.create({
  baseURL: "http://localhost:3001",
  timeout: 5000, // sin esto, un timeout del mock cuelga la UI
});
```

**La refactorización correcta**

Tener un tiempo máximo en la instancia no basta si la UI no tiene qué hacer cuando
se agota. El tiempo máximo convierte el cuelgue en un `rejected`, y el `rejected` ya
llega a `LoginPage`: el mensaje legible de `authService` (5xx y timeouts) lo muestra.
La refactorización es que cada instancia de cliente declare su tiempo máximo según el
servicio: el de la consola, 5 s; el de un servicio externo, otro valor, medido.

**Prueba de regresión**

Con el mock en `CHAOS_LEVEL=high`, doscientos logins en paralelo no pueden quedar
colgados. Mientras el defecto exista, la prueba falla; con el timeout, pasa.

```javascript
// src/__incidentes__/inc07.test.js — el mock corre en otro contenedor con CHAOS_LEVEL=high
import { store } from "../app/store";
import { login } from "../features/auth/authSlice";

test("ninguna petición de login se queda colgada con el caos alto", async () => {
  const logins = Array.from({ length: 200 }, () =>
    store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }))
  );
  const outcome = await Promise.race([
    Promise.all(logins).then(() => "todas resueltas"),
    new Promise((resolve) => setTimeout(() => resolve("hay colgadas"), 20000)),
  ]);
  expect(outcome).toBe("todas resueltas");
}, 40000);
```

Corre la prueba con `--forceExit`: las peticiones colgadas mantienen vivo el proceso
de Jest aunque la prueba termine.

**Prevención**

Un cliente HTTP sin tiempo máximo es un defecto de revisión, y es fácil de detectar:
una regla de lint o una revisión de la instancia de axios. El cuaderno del track BE
vuelve sobre esto con el nivel de carga de `be08`.

**Si tu causa fue distinta a esta**

Si dijiste *"el servidor está lento"*, mide: el cuelgue no depende de la velocidad,
sino de que la respuesta nunca llega. Si dijiste *"falta un `.catch`"*, mira la
pregunta de la pista 3: un `.catch` no ayuda a una promesa que nunca se resuelve.

</details>

---

## Incidente 08 — Me saca a login al azar mientras estoy trabajando

> **Fase:** 3 · **Categoría:** Integración · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min
> · Hermano del incidente `be-08`, con otra causa raíz

### 🎫 El ticket

Estoy cargando una rueda nueva y de golpe me tira a la pantalla de login, sin
avisar nada. No pasa siempre, pasa de a ratos. Pierdo todo lo que había escrito y
tengo que empezar de nuevo. Vuelvo a entrar con la misma clave de siempre y entra
perfecto, así que mi usuario está bien. Alguien me dijo que "se cae la sesión",
pero no sé qué quiere decir eso.

**Reportado por:** operadora de soporte
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo de forma controlada y responder una pregunta incómoda: **¿es un bug
del sistema, o el sistema haciendo exactamente lo que debe?** Y si es lo segundo
—adelanto: en parte lo es—, decidir qué se arregla de todos modos.

### 🔧 Preparación

- **Rama:** ninguna; el comportamiento ya está en tu aplicación.
- **Caos:** `CHAOS_LEVEL=high` en `3001`. **Obligatorio**: el `401` aleatorio solo
  lo inyecta el caos alto sobre rutas protegidas.
- **Datos:** el `db.json` de la fase. En esta fase la pantalla no pide datos protegidos:
  el 401 se reproduce con el caos alto y una petición protegida (ver la preparación). Escribe algo antes de que te eche: parte del incidente es medir qué se pierde.

```bash
CHAOS_LEVEL=high npm run mock:api
npm start
# Con el caos alto, pide una petición protegida (la prueba de la pieza forense de F03 la hace).
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

`mock/chaosMiddleware.js`: la regla que da el 401 a todo lo que no es `/users`, y el valor de
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

El `401` lo inyecta a propósito el middleware de caos (`mock/chaosMiddleware.js`) sobre las
rutas que no son `/users`, para simular un token vencido. Eso **no es el bug**:
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
> consola con red mala.

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
  mock.onGet('/players/42/grants').reply(401);
  history.push('/wheels/1');

  await apiClient.get('/players/42/grants').catch(() => {});

  expect(store.getState().auth.token).toBeNull();
  expect(history.location.pathname).toBe('/login');
  expect(history.location.state).toEqual({
    reason: 'session-expired',
    from: '/wheels/1',
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

**Y acá vive el cruce con el track BE.** El incidente `be-08` —*"a Yariela la saca
de la sesión a las ocho de la noche, y a Itzel nunca"*— tiene este mismo síntoma con otra causa
raíz: allá el `401` es **real**, lo produce un `exp` de JWT sin renovación, y por
eso el fallo tiene **patrón horario**. Esa es la forma de distinguirlos en la vida
real: si las expulsiones se concentran en una franja del día, sospecha de
expiración; si están repartidas uniformemente, sospecha de fallo aleatorio o de
infraestructura. Un mismo síntoma, dos capas, dos investigaciones distintas.

</details>

---

## Incidente 09 — Guardo la rueda, la pantalla se recarga y pierdo lo que escribí

> **Fase:** 4 · **Categoría:** Estado (store) · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-30 min

### 🎫 El ticket

Cargo la rueda nueva con todos los pesos, le doy a "Crear rueda" y la pantalla
parpadea y se me borra todo el formulario. Vuelvo a la lista y la rueda no está.
Es como si se reiniciara la consola entera. Lo raro es que a veces, si vuelvo un
rato después, la rueda sí está. Ya la creé tres veces por las dudas y ahora tengo
dos repetidas.

**Reportado por:** operación
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar la línea y aplicar el fix. Y como ejercicio aparte:
explicar por qué el síntoma que reporta la operadora —"se borró todo"— no se parece
en nada a la causa, y por qué las ruedas duplicadas son consecuencia del mismo bug.

### 🔧 Preparación

- **Rama:** `incidente/09`, desde `fase-04-ruedas-crud`.
- **Caos:** `off`. Con caos encendido el ruido de los fallos aleatorios tapa la
  señal, que acá es limpísima.
- **Datos:** el `mock/db.json` de la fase. Llena el formulario entero antes de
  guardar: parte del incidente es ver qué se pierde.

```bash
git checkout incidente/09
CHAOS_LEVEL=off npm run mock:api
npm start
# /wheels → "Nueva rueda" → nombre, cierre, pesos → Crear rueda
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Network, con *Preserve log* marcado —sin eso no vas a ver nada, porque justamente
se limpia—. Guarda la rueda y cuenta las peticiones. Además de tu `POST`, hay otra.
Mira su **método** y su **tipo**, y mira la barra de direcciones del navegador
justo después de guardar.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/wheels/WheelForm.jsx`, y en particular las primeras líneas de
`handleSubmit`. Compáralo con cualquier otro `handleSubmit` que hayas escrito.

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
hacer clic en Crear rueda: es la evidencia más contundente de este incidente.}}

**Evidencia observable**
{{Las peticiones de Network con *Preserve log*, y la URL resultante.}}

```text
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

`src/features/wheels/WheelForm.jsx`: `handleSubmit` no llama a
`e.preventDefault()`.

```javascript
// ❌ El thunk sale… y el navegador hace lo suyo al mismo tiempo.
const handleSubmit = (e) => {
  if (weightErrors.length > 0) return;
  if (isEditing) {
    dispatch(updateWheel(draft));
  } else {
    dispatch(createWheel(draft));
    setDraft(EMPTY_WHEEL);
  }
};
```

Un `<form>` de HTML, si nadie lo detiene, envía sus campos por su cuenta: el
navegador arma una petición de documento a la misma URL con los valores en el
*query string*, la ejecuta y **recarga la página entera**. React se desmonta, el
borrador del formulario —que vive en memoria— se pierde, y el formulario vuelve en
blanco. Es el error común #4 de la Fase 4.

La evidencia definitiva está en la barra de direcciones: después de guardar dice
algo como `/wheels?name=Semana+del+Canal+2027&closesAt=2027-08-14T20%3A00%3A00-05%3A00&status=draft&weight-sin-premio=3000…`.
Los datos de la operadora, ahí a la vista, con cada peso. Nunca se "borraron": se
fueron a la URL.

> 🧠 **Por qué el síntoma no se parece a la causa.** La operadora reporta "se borró
> todo", que suena a un problema de guardado o de estado. La causa es una llamada
> ausente en un manejador de eventos, tres capas más abajo, que ni siquiera es de
> React. Este incidente es corto a propósito, y aun así es de los más formativos
> del cuaderno: **la distancia entre lo que el usuario describe y donde vive la
> causa es la razón de ser de todo este oficio.**

Y las ruedas duplicadas son el mismo bug: el `POST` del thunk **sí sale**, y a veces
alcanza a completarse antes de que la recarga lo cancele. De ahí el "a veces sí
está" del ticket. La operadora, viendo la pantalla en blanco, vuelve a cargarla, y
la segunda también entra. Es una carrera entre tu petición y el navegador
descargando la página de abajo.

**Parche mínimo**

```javascript
const handleSubmit = (e) => {
  e.preventDefault(); // sin esto, el navegador recarga y pierdes la SPA
  if (weightErrors.length > 0) return;
  // …
};
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
      onSubmit={(e) => {
        e.preventDefault();
        onSubmit(e);
      }}
      {...rest}
    >
      {children}
    </form>
  );
}
```

**Prueba de regresión**

```jsx
// src/features/wheels/WheelForm.test.jsx (la misma prueba que corre en el repo de prueba)
import React from "react";
import { render, screen, fireEvent } from "@testing-library/react";
import { Provider } from "react-redux";
import { configureStore } from "@reduxjs/toolkit";
import wheelReducer from "./wheelSlice";
import WheelForm from "./WheelForm";

test("guardar la rueda no recarga la página: el submit llama a preventDefault", () => {
  const store = configureStore({ reducer: { wheels: wheelReducer } });
  const originalDispatch = store.dispatch;
  store.dispatch = (action) => (typeof action === "function" ? Promise.resolve() : originalDispatch(action));
  render(<Provider store={store}><WheelForm /></Provider>);
  fireEvent.change(screen.getByLabelText("Nombre"), { target: { value: "Semana del Canal 2027" } });
  fireEvent.change(screen.getByLabelText("Cierre (ISO, con offset)"), { target: { value: "2027-08-14T20:00:00-05:00" } });
  const event = new Event("submit", { bubbles: true, cancelable: true });
  screen.getByText("Nueva rueda").closest("form").dispatchEvent(event);
  expect(event.defaultPrevented).toBe(true); // con el bug: false, y el navegador recarga
});
```

Con la rama `incidente/09`, la prueba falla (`Expected: true`, `Received: false`). Con
el `preventDefault()` de vuelta, pasa.

**Prevención**

Una regla de lint de las que valen la pena: prohibir `<form>` sin `onSubmit`, y
prohibir un `onSubmit` cuyo cuerpo no empiece con `preventDefault` —salvo que use
el componente `Form` de arriba—. Es de los pocos errores que una herramienta puede
detectar con certeza absoluta.

**Por qué llegó a producción**

Por una historia banal que se repite en todos lados: durante el desarrollo el
botón "Crear rueda" era un `<button type="button">` con un `onClick`, y funcionaba
perfecto. Después alguien pidió que se pudiera enviar con Enter, se cambió a
`type="submit"` —que es la forma correcta y accesible de hacerlo— y nadie volvió a
probar el flujo completo, porque "solo cambié el tipo de un botón". El cambio de
una palabra activó un comportamiento del navegador que llevaba dormido desde 1995.

**Si tu causa fue distinta a esta**

Si dijiste *"el thunk no está guardando"*, mira Network: el `POST` sale y a veces
hasta responde `201`. Si dijiste *"falta persistir el borrador"* tienes razón en que
sería una mejora —un borrador que sobrevive a un F5—, pero no es la causa: sin la
recarga, no habría nada que persistir. Y si tu fix fue `window.location.reload()`
después de guardar para "refrescar la lista", acabas de convertir el bug en una
funcionalidad.

</details>

---

## Incidente 10 — La lista de ruedas se queda cargando para siempre

> **Fase:** 4 · **Categoría:** Estado (store) · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min

### 🎫 El ticket

Reenvío lo que nos llegó de tres personas distintas esta semana: la lista de
ruedas se queda con el cartel de "Cargando ruedas…" y ahí se queda, para siempre.
Hay que recargar. Yo lo probé diez veces en mi máquina y anda perfecto, así que no
sé si están exagerando o si hay algo raro en las computadoras de soporte.

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

- **Rama:** `incidente/10`, desde `fase-04-ruedas-crud`, y trae **un solo**
  `addCase` de menos en el slice de ruedas. Los otros tres thunks quedan intactos:
  esa asimetría es parte del material con el que vas a trabajar.
- **Caos:** empieza en `off` **a propósito**, que es donde vive la primera mitad
  de la lección. La segunda mitad necesita `high`.
- **Datos:** el `mock/db.json` de la fase, con sus tres ruedas.

```bash
git checkout incidente/10
CHAOS_LEVEL=off npm run mock:api     # primera vuelta: intenta reproducirlo así
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Si con el caos apagado no lo reproduces, la pregunta no es *"¿dónde está el bug?"*
sino *"¿qué tiene el ambiente de ellos que el mío no tiene?"*. Enumera las
diferencias entre tu máquina y una computadora de UAT antes de abrir un archivo:
red, datos, uso simultáneo, configuración del mock.

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
el `extraReducers` de `wheelSlice` para `fetchWheels`?

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

```text
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

`src/features/wheels/wheelSlice.js`: el `extraReducers` registra `pending` y
`fulfilled` para `fetchWheels`, y no registra `rejected`.

```javascript
// ❌ Dos de tres. La que falta es justo la del día malo.
builder
  .addCase(fetchWheels.pending, (state) => {
    state.loadingList = true;
    state.error = null;
  })
  .addCase(fetchWheels.fulfilled, (state, action) => {
    state.loadingList = false;
    state.items = action.payload;
  })
  // … los otros tres thunks, con sus tres casos
```

Cuando el mock devuelve un `503`, el thunk despacha `wheels/fetch/rejected`, nadie
la escucha, `loadingList` se queda en `true` y la pantalla sigue mostrando
"Cargando ruedas…" indefinidamente. Es el error común #1 de la Fase 4, y la fase lo
llama "el más común y el más caro".

**Parche mínimo**

```javascript
.addCase(fetchWheels.rejected, (state, action) => {
  state.loadingList = false;
  // payload viene de rejectWithValue; si no, cae a un genérico.
  state.error = action.payload || { message: "Error al cargar las ruedas.", type: "unknown" };
})
```

La Fase 4 es explícita sobre cómo llamar a esto: **no es un refactor, es completar
el thunk**. Un thunk con dos de sus tres estados manejados está a medio escribir.

**La refactorización correcta**

Que olvidarse deje de ser posible. Un ayudante que registre los tres casos de
cualquier thunk de una sola vez:

```javascript
// src/app/registerThunk.js
export function registerThunk(builder, thunk, { loadingKey, onSuccess }) {
  builder
    .addCase(thunk.pending, (state) => {
      state[loadingKey] = true;
      state.error = null;
    })
    .addCase(thunk.fulfilled, (state, action) => {
      state[loadingKey] = false;
      onSuccess(state, action);
    })
    .addCase(thunk.rejected, (state, action) => {
      state[loadingKey] = false;
      state.error = action.payload;
    });
}
```

Con eso, el `rejected` no se olvida porque no se escribe. La Fase 4 eligió no
usarlo, para que el patrón se vea; es una decisión que conviene revisar cuando el
equipo ya lo tenga en los dedos.

**Prueba de regresión**

```javascript
// src/features/wheels/wheelSlice.test.js (la misma prueba que corre en el repo de prueba)
test("un 500 al cargar la lista apaga loadingList y deja el error legible", async () => {
  jest.resetModules();
  const apiClient = require("../../api/apiClient").default;
  const { store } = require("../../app/store");
  const { fetchWheels } = require("./wheelSlice");
  apiClient.defaults.adapter = (config) => {
    const err = new Error("Request failed with status code 500");
    err.config = config;
    err.response = { status: 500, headers: {}, config, data: {} };
    return Promise.reject(err);
  };
  await store.dispatch(fetchWheels());
  expect(store.getState().wheels.loadingList).toBe(false); // con el bug: true para siempre
  expect(store.getState().wheels.error).toEqual({ message: "El servidor tuvo un problema. Intenta de nuevo.", type: "http" });
});
```

Con la rama `incidente/10`, la prueba falla (`Expected: false`, `Received: true`). Con
el `addCase` de vuelta, pasa. No necesita el mock: el adapter de axios hace de
servidor que falla.

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
la demostración, y nadie la agradece hasta el día que salva un evento entero.

**Si tu causa fue distinta a esta**

Si dijiste *"el backend no responde"*, ese es el **incidente 07**, y se distinguen
en un vistazo a Network: en el 07 hay una petición **sin status**, todavía
pendiente, que nunca termina; acá la petición **terminó**, con un `503` bien
visible en rojo. Mismo síntoma en la pantalla —una espera que no acaba—, dos
lugares totalmente distintos. Tener los dos en el cuaderno y saber separarlos con
una sola columna de DevTools es exactamente el músculo que este curso entrena.

Si dijiste *"falta un `try/catch` en el componente"*, el componente no es el
problema: está pintando fielmente un `loadingList` que dice `true`. Y si tu fix
fue un `setTimeout` que apaga el cargando a los diez segundos, escondiste el error
y además le mentiste a la operadora: la carga no terminó, se rindió en silencio.

</details>

---

## Incidente 11 ⭐ — Compensamos dos veces a la misma jugadora

> **Fase:** 5 · **Categoría:** Concurrencia · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 70-90 min
> ⭐ Uno de los dos incidentes más formativos del curso · Hermano del incidente `be-09`, con otra causa raíz

### 🎫 El ticket

A Juan P. lo compensé una sola vez por la caída del martes, caso C-2210: un avatar.
Hoy me escribe contento porque le llegaron dos. Revisé en la consola y aparece una
sola vez, "Enviado". Esa noche la consola estaba lentísima y no sé si toqué el
botón una vez o dos, pero en la pantalla había uno solo. Necesito saber si hay más
jugadores así, y a cuántos les mandamos de más.

**Reportado por:** soporte
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir la secuencia **en el store** —no solo en el servidor—, nombrarla, y
separar con claridad el parche mínimo del fix correcto. En este incidente los dos
no viven en la misma fase, y ni siquiera en la misma capa, y esa es media lección.

Y una advertencia que conviene leer antes de empezar: es tentador concluir que el
problema es del servidor, que aceptó dos compensaciones del mismo caso.
**Verifícalo antes de creerlo**, y pregúntate después por qué le llegaron dos.

### 🔧 Preparación

- **Rama:** `incidente/11`, desde `fase-05-envios-manuales`.
- **Caos:** `off`. La demora que hace falta ya está en el mock: entregar un premio
  en el juego tarda `GRANT_DELIVERY_MS` (800 ms por defecto). Si quieres más margen
  para el doble clic, súbela.
- **Datos:** el `mock/db.json` de la fase, con la colección `grants` vacía.

```bash
git checkout incidente/11
GRANT_DELIVERY_MS=3000 npm run mock:api
npm start
# /grants → marca a Juan P. → caso C-2210 → motivo → Compensar
# → en la fila, doble clic en «Enviar ahora»
curl -s "http://localhost:3001/grants?caseId=C-2210"   # ¿cuántos registros?
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No abras el código todavía. Reproduce, y después mira dos cosas: la pestaña
Network (¿cuántos `POST /players/42/grants` salieron?) y la lista de acciones de
Redux DevTools **de arriba abajo, entera**, como si fuera el extracto de una cuenta
bancaria donde sobra plata.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Hay dos `grants/send/pending` para el **mismo** `grantId`. Selecciona el segundo y
usa *time-travel* para pararte justo antes: ¿en qué estado estaba el envío en ese
instante? ¿Quién debió preguntar eso antes de mandarlo?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`createAsyncThunk` acepta una opción que decide, **antes** de `pending`, si el thunk
corre o no. Busca en `grantSlice.js` si `sendGrant` la tiene. Y después mira
`registerGrant` en el mock: ¿qué pasa entre que comprueba el caso y que lo anota?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados y exactos: qué jugador, qué caso, con qué `GRANT_DELIVERY_MS`, y
cuánto tiempo pasó entre los dos clics. Si tardaste varios intentos, anota cuántos:
la frecuencia es parte de la descripción de una carrera.}}

**Evidencia observable**
{{La secuencia completa de acciones de Redux DevTools, en texto, y lo que devuelve
`GET /grants?caseId=C-2210`. Es la prueba central de este incidente; sin ella no
hay diagnóstico.}}

```text
{{la secuencia de acciones, en orden, y los registros del mock}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó. Anota especialmente si
  pasaste por "el servidor está mal" y qué parte de eso resultó cierta}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y en qué capa vive: componente, store, epic, interceptor o mock.
Puede que sean dos.}}

**Tu fix**
{{El parche mínimo del viernes a las seis. Aparte, la refactorización correcta, y
por qué no se puede hacer todavía.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Lo primero: el servidor registró dos, y no es el culpable principal**

`GET /grants?caseId=C-2210` devuelve **dos** registros con el mismo caso y el
mismo jugador. El servidor aceptó dos compensaciones. Pero mira también Network:
salieron **dos** `POST`. La consola mandó dos veces el mismo envío, y el servidor,
que comprueba el caso antes de entregar el premio, no frenó al segundo porque los
dos llegaron dentro de la demora de la entrega.

Eso reparte la investigación en dos capas, y la de la consola es la que se arregla
hoy.

**Causa raíz**

La secuencia, tal como se lee en Redux DevTools:

```text
grants/send/pending     g-1      ← primer clic: queued → sending
grants/grantSent        g-1      ← el optimista: sending → sent
grants/send/pending     g-1      ← segundo clic: nadie preguntó el origen
grants/grantSent        g-1      ← otra vez "enviado"; en la pantalla no cambia nada
grants/send/fulfilled   g-1      ← el servidor registró el primero…
grants/send/fulfilled   g-1      ← …y el segundo
```

Son dos defectos encadenados.

**El primero**, el de la consola: `sendGrant` no tiene guarda de origen. «Enviar
ahora» sigue visible mientras el servidor no confirma —es una decisión de producto,
para que el operador pueda insistir si un envío parece colgado—, y un segundo clic
crea una segunda petición sobre un envío que ya salió. Además, `grantSent` asigna
`sent` sin pasar por la tabla de transiciones. En la rama:

```javascript
// ❌ Sin condition: el thunk corre aunque el envío ya haya salido.
export const sendGrant = createAsyncThunk(
  "grants/send",
  async (grantId, { dispatch, getState, rejectWithValue }) => {
    // …
  }
);

// ❌ Y el optimista pinta encima de cualquier cosa.
grantSent(state, action) {
  state.byId[action.payload.grantId].status = "sent";
},
```

**El segundo**, el del servidor: `registerGrant` comprueba el caso, entrega el
premio en el juego (800 ms) y recién después lo anota. Dos pedidos que llegan dentro
de esa ventana ven los dos "no hay registro" y pasan los dos. Es el mismo estilo del
giro de 2019 que mediste en la Fase 3: comprobar y escribir en pasos separados.

> 🧠 **Lo que hay que llevarse.** La consola tenía la información para no mandar
> dos veces —el envío ya estaba `sent` en su propio store— y no la consultó. El
> servidor tenía la regla —un caso, una compensación— y la aplicó en dos pasos.
> Dos defensas a medias no suman una entera.

> 📝 **Nota de época.** El envío optimista es de 2020 (`00-historia-del-sistema.md`
> §3, era 2): se marca enviado al instante y se revierte si el servidor protesta.
> Funciona casi siempre. Este incidente es el "casi", y no fue una mala decisión:
> fue una decisión correcta con un caso límite mal cerrado. La noche de la Esclusa
> de Oro, con la consola lenta, el caso límite fue la norma.

**Parche mínimo**

La guarda de origen, en el `condition` del thunk: si el envío no está en cola ni
falló, no se manda.

```javascript
export const sendGrant = createAsyncThunk(
  "grants/send",
  async (grantId, { dispatch, getState, rejectWithValue }) => {
    // … sin cambios
  },
  {
    // Guarda de origen: solo se envía lo que está en cola o falló. Un segundo clic
    // sobre un envío que ya salió no llega ni a crear la petición.
    condition: (grantId, { getState }) => {
      const grant = getState().grants.byId[grantId];
      return Boolean(grant) && (grant.status === "queued" || grant.status === "failed");
    },
  }
);
```

Y que `grantSent` pase por la tabla: `transition(state.byId[action.payload.grantId], "sent")`.

**La refactorización correcta** (que en este curso no se paga en esta fase)

Que el segundo intento no exista. Un epic con `exhaustMap` ignora los clics mientras
hay un envío en vuelo: el doble clic da un solo envío, sin guardas repartidas. Eso es
la Fase 6 (`sendGrantEpic`), y es la razón por la que este incidente se enuncia en la
5 y termina de entenderse en la 6.

Y la otra mitad: **la unicidad garantizada por el servidor**, con una restricción en
la base que haga imposible registrar dos veces el mismo caso para el mismo jugador.
Eso es el track BE —`be05`—, y es también el territorio del incidente hermano.

> 🧭 **Y la conclusión honesta, que conviene decir en voz alta:** ninguna guarda en
> la consola elimina esta carrera. La achica. Dos operadores en dos consolas, el
> mismo caso, el mismo segundo: cada store está limpio, y el servidor registra dos.
> La ventana entre "comprobé" y "anoté" solo se cierra donde hay un único árbitro.

**Prueba de regresión**

```javascript
// src/features/grants/grantSlice.test.js (la misma prueba que corre en el repo de prueba)
test("doble clic en 'Enviar ahora': sale una sola petición", async () => {
  jest.resetModules();
  const apiClient = require("../../api/apiClient").default;
  const { store } = require("../../app/store");
  const { queueGrant, sendGrant } = require("./grantSlice");
  let posts = 0;
  apiClient.defaults.adapter = (config) => {
    posts += 1;
    return Promise.resolve({ status: 201, data: JSON.parse(config.data), headers: {}, config, statusText: "Created" });
  };
  const grant = store.dispatch(queueGrant({ player: { id: 42, name: "Juan P." }, caseId: "C-2210", prize: "vidas-5", reason: "caída" }));
  // Los dos clics, sin que la respuesta del primero haya llegado.
  await Promise.all([store.dispatch(sendGrant(grant.id)), store.dispatch(sendGrant(grant.id))]);
  expect(posts).toBe(1); // con el bug: 2
});
```

Es una prueba sin red: el adapter de axios hace de servidor y cuenta las
peticiones. Con la rama `incidente/11` falla (`Expected: 1`, `Received: 2`); con la
guarda, pasa. Reproducir una carrera de forma determinista es difícil en la
aplicación y trivial en el store, y ese es el argumento más fuerte a favor de
mantener la lógica de estado separada de la UI.

**Prevención**

Una máquina de estados explícita, con las transiciones permitidas declaradas en un
solo lugar (`ALLOWED_TRANSITIONS`), y una guarda en cada puerta de entrada: el
`condition` del thunk para lo que sale a la red, la tabla para lo que cambia el
store. Y una prueba por thunk que lo dispare dos veces seguidas.

**Por qué llegó a producción**

Porque el camino que falla necesita tres condiciones a la vez —un envío que ya
salió, un segundo intento, y que los dos lleguen dentro de la demora del servidor— y
ninguna de las tres ocurre en la máquina de quien programa, con un clic y un mock
rápido. La noche de la Esclusa de Oro, con la consola lenta y cientos de
compensaciones, ocurrieron todas.

**Si tu causa fue distinta a esta**

Si dijiste *"es el temporizador de la ventana"*, mira la secuencia: no hay ningún
`grants/send/pending` diez segundos después; `sendGrant` cierra la ventana al
empezar. Si dijiste *"el servidor está mal"*, tienes la mitad: su chequeo no es
atómico, pero la consola le mandó dos pedidos que no tenía por qué mandar. Y si tu
fix fue deshabilitar el botón en el componente, frenaste este doble clic, pero la
regla quedó en un botón: cualquier otro camino que despache `sendGrant` —el
temporizador de la ventana, un epic de la Fase 6— vuelve a abrir la puerta. La
guarda va donde pasan todos los caminos, en el thunk.

</details>

---

## Incidente 12 — Un envío que ya estaba enviado volvió a «falló»

> **Fase:** 5 · **Categoría:** Concurrencia · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min

### 🎫 El ticket

Compensé a Juan P. por la caída, caso C-2210, y quedó "Enviado". Una hora después
mandé la compensación masiva a la lista de afectados de la misma caída, y Juan
estaba en la lista. Ahora el envío de la mañana dice "Falló", con el mensaje "Ese
caso ya fue compensado para este jugador". ¿Falló o no falló? En el juego Juan
tiene su avatar. Y el de la lista sigue diciendo "Enviado".

**Reportado por:** soporte
**Ambiente:** UAT

### 🎯 Qué se te pide

Determinar qué acción cambió el envío de la mañana y por qué el store la aceptó. El
fix es corto; el entregable es la evidencia de que la acción que llegó **no era
de ese envío**.

### 🔧 Preparación

- **Rama:** `incidente/12`, desde `fase-05-envios-manuales`.
- **Caos:** `off`. El `409` lo da el propio mock: el caso ya está registrado.
- **Datos:** el `mock/db.json` de la fase.

```bash
git checkout incidente/12
npm run mock:api
npm start
# /grants → Juan P., caso C-2210 → Compensar → «Enviar ahora» → queda "Enviado"
# después: Juan P. y María R., mismo caso C-2210 → Compensar → «Enviar todos ahora»
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Redux DevTools. Busca el `grants/rollbackGrant` y mira dos cosas: el `grantId` de su
payload, y en el panel **Diff**, cuál envío cambió.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El reducer de `rollbackGrant` en `src/features/grants/grantSlice.js`. ¿Con qué busca
el envío que va a revertir? ¿Qué pasa si hay dos envíos del mismo caso para el
mismo jugador?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un rollback tiene que revertir **su** envío, y solo si el servidor no lo confirmó.
¿Cuál de las dos condiciones cumple el reducer?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados: qué envío salió primero, cuál después, y con qué caso.}}

**Evidencia observable**
{{La secuencia de acciones de Redux DevTools, con el payload del `rollbackGrant` y el
Diff que produjo.}}

```text
{{la secuencia, y qué envío cambió}}
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

**Lo primero: el servidor contestó bien**

El `409` del envío masivo es correcto: el caso C-2210 ya estaba compensado para Juan.
El servidor hizo su trabajo. Lo que hay que explicar es por qué ese `409`, que era
del envío de la lista, terminó marcando como fallido el envío de la mañana.

**Causa raíz**

La secuencia, tal como se lee en Redux DevTools:

```text
grants/send/pending     g-1      ← el individual de la mañana
grants/grantSent        g-1
grants/send/fulfilled   g-1      ← confirmado: confirmed = true
…
grants/send/pending     g-7      ← el masivo, mismo caso y mismo jugador
grants/grantSent        g-7
grants/rollbackGrant    { grantId: "g-7", caseId: "C-2210", playerId: 42, error: { type: "conflict" } }
grants/send/rejected    g-7
```

El `rollbackGrant` dice `g-7` en su payload, y el Diff muestra que el que cambió fue
`g-1`: de `sent` a `failed`. **Lo que dice la acción y lo que hace el reducer no
coinciden.** Son dos defectos en el mismo reducer:

```javascript
// ❌ Busca "el envío de este caso para este jugador": encuentra el primero, g-1.
rollbackGrant(state, action) {
  const { caseId, playerId, error } = action.payload;
  // El envío de este caso para este jugador.
  const grant = Object.values(state.byId).find((g) => g.caseId === caseId && g.playerId === playerId);
  if (transition(grant, "failed")) grant.error = error;
},
```

El primero: busca por caso y jugador, no por id. Quien lo escribió pensaba que un
caso tiene un solo envío, y la Fase 5 hizo posible lo contrario con el envío masivo.
El segundo: no pregunta si el envío ya estaba confirmado. `g-1` tenía
`confirmed: true`; nada debió revertirlo. Y queda un tercer daño, silencioso: `g-7`,
el que de verdad falló, se queda en "Enviado (sin confirmar)" para siempre.

**Parche mínimo**

```javascript
rollbackGrant(state, action) {
  const { grantId, error } = action.payload;
  const grant = state.byId[grantId]; // por id: el rollback es de este envío, no del caso
  if (!grant || grant.confirmed) return; // lo que el servidor confirmó no se revierte
  if (transition(grant, "failed")) grant.error = error;
},
```

**La refactorización correcta**

Un `409` no es "volvé a como estabas": es "tu foto del mundo está vieja". Lo correcto,
ante un conflicto, es volver a preguntarle al servidor por ese caso y ese jugador
(`GET /grants?caseId=…&playerId=…`) y pintar lo que el servidor diga, en vez de
inventar un estado local. Y que el envío masivo no proponga compensar un caso que ya
está compensado en la misma sesión: el asistente puede mirar el store antes de
encolar.

**Prueba de regresión**

```javascript
// src/features/grants/grantSlice.rollback.test.js (la misma prueba que corre en el repo de prueba)
import reducer, { grantQueued, sendGrant, grantSent, rollbackGrant } from "./grantSlice";

test("el rollback del envío masivo no pisa el envío individual ya confirmado", () => {
  const juan = { playerId: 42, playerName: "Juan P.", caseId: "C-2210", prize: "vidas-5", reason: "caída", confirmed: false, error: null };
  let state = reducer(undefined, grantQueued({ ...juan, id: "g-1", status: "queued" }));
  state = reducer(state, sendGrant.pending("req-1", "g-1"));
  state = reducer(state, grantSent({ grantId: "g-1" }));
  state = reducer(state, sendGrant.fulfilled({}, "req-1", "g-1")); // el individual: confirmado
  state = reducer(state, grantQueued({ ...juan, id: "g-7", status: "queued" })); // el masivo, mismo caso
  state = reducer(state, sendGrant.pending("req-7", "g-7"));
  state = reducer(state, grantSent({ grantId: "g-7" }));
  const conflict = { message: "Ese caso ya fue compensado para este jugador.", type: "conflict" };
  state = reducer(state, rollbackGrant({ grantId: "g-7", caseId: "C-2210", playerId: 42, error: conflict }));
  expect(state.byId["g-1"].status).toBe("sent"); // con el bug: "failed"
  expect(state.byId["g-7"].status).toBe("failed");
});
```

Es un test de reducer puro, sin red y sin componentes: la secuencia exacta que viste
en DevTools, escrita como código. Con la rama `incidente/12` falla (`Expected: "sent"`,
`Received: "failed"`); con el parche, pasa.

**Prevención**

Que toda acción que modifica un envío lleve su id, y que todo reducer lo use. Los
otros datos del payload —el caso, el jugador— están para que DevTools muestre de qué
se trata, no para buscar. Y la confirmación del servidor como frontera: lo que el
servidor confirmó, solo lo cambia el servidor.

**Por qué llegó a producción**

Porque el envío individual y el masivo se probaron por separado, y por separado
funcionan. El reducer se escribió cuando un caso tenía un solo envío posible; el
envío masivo llegó después y nadie volvió a leer el rollback. Es la forma más común
de que un supuesto viejo se vuelva un bug nuevo: no cambió el código que falla,
cambió lo que lo rodea.

**Si tu causa fue distinta a esta**

Si dijiste *"el servidor marcó mal el envío"*, el `409` es para `g-7`, y en Network se
ve que salió de la petición de `g-7`. Si dijiste *"es el temporizador de la ventana"*,
no hay ningún `grants/send` de `g-1` después del primero. Y si tu fix fue no mandar
nunca un `409` a `rollbackGrant`, el envío de la lista se queda "Enviado" mintiendo:
el rollback hace falta, solo que del envío correcto.

</details>

---

## Incidente 13 — Falló un envío y desde entonces no sale ninguno

> **Fase:** 6 · **Categoría:** RxJS / epics · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min

### 🎫 El ticket

Mandé una compensación, me salió "Falló" con un cartel de error, y desde ese
momento no sale nada más. Le doy a «Enviar ahora» y no pasa absolutamente nada: ni
sale, ni falla, ni se queda enviando. Nada. Cierro el navegador, vuelvo a entrar y
anda otra vez, hasta que se repite. Perdí media mañana entre cierre y cierre.

**Reportado por:** soporte
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar y arreglar. Y explicar la parte del ticket que suena
imposible: **por qué el sistema no da ningún error**. En este incidente el
silencio no es un detalle: es el síntoma principal.

Antes de terminar, comprueba una cosa más que el ticket no menciona: ¿solo dejó de
funcionar el envío, o algo más se apagó junto con él?

### 🔧 Preparación

- **Rama:** `incidente/13`, desde `fase-06-redux-observable-a-fondo`.
- **Caos:** `CHAOS_LEVEL=high`. Hace falta que un envío falle de verdad; con `off`
  no hay forma de encender el problema.
- **Datos:** los de la fase. Encola varios envíos, para poder intentar varios
  seguidos.

```bash
git checkout incidente/13
CHAOS_LEVEL=high npm run mock:api
npm start
# /grants → encola tres o cuatro envíos → «Enviar ahora» hasta que uno falle → intenta otro.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Redux DevTools abierto. Después del primer fallo, haz clic en «Enviar ahora» sobre
otro envío y responde dos preguntas por separado: ¿se despachó
`grants/sendGrantRequested`? ¿Y pasó algo **después** de ella? Si la respuesta es
"sí" y "no", ya tienes acotada la capa a una sola: la que escucha las acciones y no
reaccionó.

Y mira Network al mismo tiempo: cuenta cuántas peticiones salieron.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/grants/epics/sendGrantEpic.js`, y al lado
`src/features/grants/epics/searchPlayerEpic.js`. Los dos hacen una petición dentro
de un operador de aplanamiento. Uno tiene un operador que el otro no.

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
{{Pasos numerados. Anota cuántos envíos salieron antes del que falló, y qué
intentaste después.}}

**Evidencia observable**
{{Las acciones de Redux DevTools después del fallo, y —muy importante— cuántas
peticiones salieron por Network en cada intento posterior.}}

```text
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

`sendGrantEpic` no tiene `catchError` en el stream de cada envío. Cuando la
petición falla, el error no lo atrapa nadie, sube por el pipe hasta el `rootEpic`
y **completa el Observable con error**. A partir de ese instante, el epic ya no
está suscrito a `action$`. En la consola del navegador queda una sola línea, un
`Uncaught` con el `503`, que nadie mira porque la pantalla sigue respondiendo.

Y ahí está la explicación del silencio, que es lo que más cuesta aceptar: el epic
no falló. **Dejó de existir.** Las acciones `grants/sendGrantRequested` se siguen
despachando —lo ves en DevTools, ahí están— y no hay nadie del otro lado
escuchándolas. Un componente que despacha a un epic muerto se comporta exactamente
igual que uno que despacha a un epic que decidió no hacer nada: sin excepción en
pantalla, sin cartel, sin nada.

La evidencia definitiva es la que pedía la pista 1: **cero peticiones en Network**
en los intentos posteriores. No es que el servidor rechace el envío; es que el
envío nunca sale de la aplicación.

Es el error común #1 de la Fase 6.

**Y la parte que el ticket no menciona**

`combineEpics` combina los epics con un `merge`. Un error que mata a uno mata el
stream combinado, y con él **todos los demás epics**. Si lo comprobaste, viste que
la búsqueda de jugadores también dejó de responder, y que la ventana de deshacer ya
no manda nada solo. Soporte reportó lo que estaba haciendo en ese momento; el daño
fue mucho mayor y nadie lo notó.

Ese detalle vale por sí solo el incidente: **el alcance de un fallo casi nunca
coincide con el alcance del reporte.**

> 🧠 **El patrón a memorizar.** En RxJS, un error no es un evento que se maneja: es
> una **terminación**. La analogía de backend que hay que abandonar acá es la
> excepción atrapada en un `try/catch` dentro de un bucle, donde la iteración
> siguiente ocurre igual. Un epic no es un bucle: es una suscripción, y una
> suscripción que termina no vuelve sola.

**Parche mínimo**

El `catchError` va **dentro** del stream del envío —el de la petición—, no afuera:

```javascript
from(api.post(`/players/${grant.playerId}/grants`, { /* … */ })).pipe(
  map(() => grantConfirmed(grantId)),
  // Acá muere el error: mata solo a este envío, no al epic.
  catchError((error) =>
    of(rollbackGrant({ grantId, caseId: grant.caseId, playerId: grant.playerId, error: toReadableError(error) }))
  )
)
```

Si lo pones afuera del `exhaustMap`, atrapas el error y **igual pierdes el stream
externo**: el epic emite el rollback una vez y después se completa. Se ve arreglado
en la primera prueba y vuelve a fallar en la segunda, que es la peor forma posible
de arreglar algo.

**La refactorización correcta**

La de arriba ya es la corrección correcta para este epic. Lo que corresponde
agregar aparte es una red de seguridad para el resto, porque este error va a
volver a ocurrir en algún epic que alguien escriba el año que viene:

```javascript
// src/app/rootEpic.js
export const rootEpic = (action$, state$, deps) =>
  combineEpics(/* … */)(action$, state$, deps).pipe(
    catchError((error, source) => {
      console.error("[rootEpic] un epic murió y fue resucitado:", error);
      return source; // re-suscribe: el sistema sigue vivo
    })
  );
```

Con eso, un epic mal escrito degrada una operación en vez de apagar la consola
entera. Y el `console.error` convierte un fallo invisible en uno que deja rastro,
que es la mitad del problema de este incidente.

**Prueba de regresión**

```javascript
// src/features/grants/epics/sendGrantEpic.survival.test.js (la misma prueba que corre en el repo de prueba).
import { TestScheduler } from "rxjs/testing";
import { sendGrantEpic } from "./sendGrantEpic";
import { grantQueued, sendGrantRequested, grantSending, grantSent, grantConfirmed, rollbackGrant } from "../grantSlice";

test("un envío que falla no mata el epic: el siguiente sale igual", () => {
  const scheduler = new TestScheduler((actual, expected) => expect(actual).toEqual(expected));
  scheduler.run(({ hot, cold, expectObservable }) => {
    const a = grantQueued({ player: { id: 42, name: "Juan P." }, caseId: "C-1", prize: "vidas-5", reason: "caída" }).payload;
    const b = grantQueued({ player: { id: 43, name: "María R." }, caseId: "C-1", prize: "vidas-5", reason: "caída" }).payload;
    const state$ = { value: { grants: { byId: { [a.id]: a, [b.id]: b }, order: [a.id, b.id] } } };
    const error = Object.assign(new Error("503"), { response: { status: 503, data: {} } });
    // El primero falla con un 503; el segundo sale bien.
    const api = { post: (url, body) => (body.grantId === a.id ? cold("----#", {}, error) : cold("----r|", { r: {} })) };
    const action$ = hot("-a 10ms b", { a: sendGrantRequested(a.id), b: sendGrantRequested(b.id) });
    // Con el bug, el diagrama termina en error (#) en el frame del fallo, y b nunca sale.
    expectObservable(sendGrantEpic(action$, state$, { api })).toBe("-(st)f 6ms (uv)c", {
      s: grantSending(a.id),
      t: grantSent({ grantId: a.id }),
      f: rollbackGrant({ grantId: a.id, caseId: "C-1", playerId: 42, error: { message: "El servidor tuvo un problema. Intenta de nuevo.", type: "http" } }),
      u: grantSending(b.id),
      v: grantSent({ grantId: b.id }),
      c: grantConfirmed(b.id),
    });
  });
});
```

Lo que hace útil este test es el **segundo** envío. Un test que solo compruebe que
el fallo produce un rollback pasa con el bug adentro: el rollback llega, y recién
la operación siguiente revela que no quedó nadie escuchando. Con la rama
`incidente/13` el diagrama termina en error en el frame del fallo, y el envío de
María nunca sale. Cómo se leen estos diagramas está en `A11-marble-testing.md`.

**Prevención**

Una regla mecánica, verificable en revisión de código: **todo Observable interno
que haga entrada/salida lleva su `catchError` adentro del operador de aplanamiento
que lo creó.** Más el `catchError` del `rootEpic` como red. Y un test de
supervivencia —dos operaciones, la primera falla— por cada epic que atienda algo
repetible.

**Por qué llegó a producción**

Por una creencia razonable y equivocada: *"los errores ya los maneja el interceptor
de axios"*. Y es cierto para lo que el interceptor hace —atrapar el `401`, anotar
el `requestId`— pero el interceptor vive en la capa de transporte y no sabe nada
del ciclo de vida de un Observable. Rechaza la promesa, como debe. Lo que pasa
después de ese rechazo es asunto del epic, y nadie lo había pensado.

Y sobrevivió porque el síntoma es absurdo: *"le doy al botón y no pasa nada"* suena
a problema de interfaz, y quien lo investigó por ahí no encontró nada raro, porque
efectivamente no lo hay. El botón funciona perfecto.

**Si tu causa fue distinta a esta**

Si dijiste *"el botón se deshabilitó y no se volvió a habilitar"*, míralo en el
inspector: está habilitado, y el `onClick` se ejecuta. Si dijiste *"el backend está
rechazando todo"*, la prueba está en Network: **no sale ninguna petición**, así que
el backend ni se entera. Y si tu fix fue recargar la consola desde el código
—un `window.location.reload()` en el `catch`—, automatizaste lo que ya hacía
soporte a mano y le pusiste el mismo costo: todo lo que estaba en cola, perdido.

</details>

---

## Incidente 14 ⭐ — Cerré sesión y el servidor sigue recibiendo peticiones

> **Fase:** 6 · **Categoría:** RxJS / epics · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 55-70 min
> ⭐ Uno de los dos incidentes más formativos del curso

### 🎫 El ticket

Nos avisó el proveedor de pagos que estamos consultando compras como cuatro veces
más de lo que correspondería para la cantidad de gente que usa la consola. Miramos
el log del servicio de compras y hay consultas a las tres de la mañana, cuando no
hay nadie trabajando. Vienen sin sesión y son de compras que soporte estaba
siguiendo antes de cerrar sesión, hace horas. Nadie se quejó nunca de nada: la
consola funciona bien.

**Reportado por:** operación, a partir del aviso del proveedor
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

- **Rama:** `incidente/14`, desde `fase-07-cierre-polling-compras`. El `pollingEpic`
  nace en la Fase 7; el leak, en la Fase 6 (§5.8).
- **Caos:** `off`. Este bug no necesita que nada falle; al contrario, el caos solo
  agrega ruido a Network justo donde hay que mirar.
- **Datos:** una compra en efectivo que tarde en confirmarse. El mock de Google
  Play la deja pendiente `PLAY_PENDING_MS` milisegundos: ponlo alto, o la compra se
  confirma y el polling termina solo antes de que veas nada.

```bash
git checkout incidente/14
npm run mock:api
PLAY_PENDING_MS=600000 npm run mock:googleplay      # diez minutos de compra pendiente
curl -s -X POST localhost:3002/purchases -H 'Content-Type: application/json' \
  -d '{"purchaseToken":"tok-oxxo-2","method":"cash"}'
npm start
# Login → /purchases → consulta tok-oxxo-2 → logout → NO TOCAR NADA y mirar Network y el log del 3002.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No lo busques en el código: es de los pocos bugs que se ven antes de leer nada.
Abre Network, filtra por `purchases`, cierra sesión y **quédate quieto mirando la
pestaña**. La consola no se está usando. Si algo aparece igual, ese algo es el
incidente. Y en la terminal del mock de Google Play, el contador de consultas sin
sesión.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/purchases/epics/pollingEpic.js`. Lee sus dos salidas: el `takeWhile`
y el `takeUntil`. ¿Qué señales escucha el `takeUntil`? ¿Cuál falta?

Y después `src/features/purchases/PurchasesPage.jsx`: al cerrar sesión, la ruta
protegida la desmonta. ¿Hace algo la pantalla cuando se va?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El `timer` que abre el `switchMap` emite cada dos segundos hasta el fin de los
tiempos. ¿Quién le dice que pare cuando el operador cierra sesión, y —esta es la
parte que decide si tu fix va a funcionar— **en cuál de los dos pipes** tendría que
estar esa instrucción?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Anota cuántos minutos dejaste la pestaña quieta y cuántas
consultas contó el log del mock en ese tiempo: ese número es el que convierte este
incidente en dinero.}}

**Evidencia observable**
{{Las filas de Network después del logout, con su URL, su cadencia y sus headers.
La ausencia del `Authorization` es parte de la prueba, y las líneas
`[3002] sin sesión #…` del log del mock, la otra parte.}}

```text
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

El `takeUntil` de `src/features/purchases/epics/pollingEpic.js` **no escucha el
logout**. El `timer(0, POLLING_INTERVAL_MS)` que abre el `switchMap` emite cada dos
segundos, y solo lo cortan la confirmación de la compra y el stop del operador:

```javascript
// ❌ Solo el stop: el logout no es una señal para este polling.
takeUntil(action$.pipe(filter((other) => stopPolling.match(other))))
```

Cerrar sesión no hace nada, y ahí está el salto conceptual de toda la Fase 6: **un
epic no tiene ciclo de vida atado a la interfaz**. Vive en el middleware, que se
monta una vez con la aplicación. Al cerrar sesión, la ruta protegida desmonta la
pantalla de compras, y en esta rama la pantalla **se va sin decir nada**: no tiene
la limpieza que despacha `stopPolling` al desmontarse.

```javascript
// ❌ Lo que falta en PurchasesPage: al irse, no avisa.
useEffect(() => () => dispatch(stopPolling()), [dispatch]);
```

Ninguna de las dos salidas se dispara, así que el `timer` sigue. Sigue emitiendo
hasta que la compra se confirma o se cierra la pestaña, que es exactamente lo que
dice el log de las tres de la mañana: consolas que quedaron abiertas en el login.

Y las consultas salen **sin token** porque el interceptor de `apiStore` lee el store
en cada petición y el store ya no tiene sesión (ver el incidente 05). El servicio
las atiende igual, y el proveedor las cuenta.

**Parche mínimo**

```javascript
// Última línea del pipe INTERNO: corta este timer, no el epic.
takeUntil(action$.pipe(filter((other) => stopPolling.match(other) || logout.match(other))))
```

**Y por qué va en el pipe interno, que es la mitad de la lección**

`takeUntil` corta **todo lo que está antes de él en el pipe donde vive**. Si lo
pones en el pipe externo —cerrando el `action$.pipe(...)` del epic—, funciona una
vez: el primer logout apaga el `timer`… y también apaga el epic entero. El operador
vuelve a entrar, consulta una compra, y el polling ya no arranca nunca más, porque
no queda nadie escuchando `startPolling`.

Habrías cambiado un leak por un epic muerto, que es exactamente el **incidente
13**. Dos bugs opuestos, la misma línea, dos ubicaciones distintas dentro del
mismo `.pipe()`. Es el error común #3 de la Fase 6 y la razón por la que la regla
práctica es: **`takeUntil` casi siempre va último, y en el pipe interno**.

**La refactorización correcta**

La que la Fase 7 ya escribió: dos salidas explícitas, cada una con su operador.
`takeWhile` para la salida que viene de adentro (la compra se confirmó) y
`takeUntil` con **todas** las señales que vienen de afuera (el stop, el logout).
Y la pantalla que despacha su `stopPolling` al desmontarse, como segunda red para
cuando el operador sale de ella sin cerrar sesión.

**Prueba de regresión**

```javascript
// src/features/purchases/epics/pollingEpic.logout.test.js (la misma prueba que corre en el repo de prueba).
import { TestScheduler } from "rxjs/testing";
import { pollingEpic, POLLING_INTERVAL_MS } from "./pollingEpic";
import { startPolling } from "../purchaseSlice";
import { logout } from "../../auth/authSlice";

test("después del logout no sale ni una consulta más", () => {
  const scheduler = new TestScheduler((actual, expected) => expect(actual).toEqual(expected));
  let calls = 0;
  scheduler.run(({ hot, cold, expectObservable }) => {
    const store = { get: () => { calls += 1; return cold("r|", { r: { data: { state: "pending" } } }); } };
    const action$ = hot(`a ${POLLING_INTERVAL_MS + 500}ms L`, { a: startPolling("tok-oxxo-2"), L: logout() });
    // Se mira lo que pasa en los diez segundos siguientes al logout.
    expectObservable(pollingEpic(action$, null, { store }), `^ ${POLLING_INTERVAL_MS + 10500}ms !`).toBe(`p ${POLLING_INTERVAL_MS - 1}ms q`, {
      p: expect.objectContaining({ type: "purchases/purchaseStatusReceived" }),
      q: expect.objectContaining({ type: "purchases/purchaseStatusReceived" }),
    });
  });
  expect(calls).toBe(2); // con el bug: siguen saliendo, una cada dos segundos
});
```

> 🧭 **Lo que se prueba acá no es que el epic emita: es que el epic
> DEJE de emitir.** La segunda letra del diagrama de suscripción (`!`, diez
> segundos después del logout) y el `calls` en 2 son todo el test. Es la única
> forma práctica de verificar una cancelación, y es la razón por la que
> `A11-marble-testing.md` existe: sin canicas, "comprobar que algo no pasa nunca
> más" requiere esperar para siempre.

**Prevención**

Una regla concreta: **todo epic que crea un stream infinito** —`interval`, `timer`,
`fromEvent`, un websocket— **declara su `takeUntil` en el mismo pipe donde lo
creó, con el logout entre sus señales**, y lleva un test de cancelación como el de
arriba. Son dos líneas de prevención contra una familia de bugs que no da ninguna
otra señal.

Y una operativa que cuesta cinco minutos: revisar el volumen de consultas por
operador activo, una vez al mes. Este incidente lo encontró el aviso de un
proveedor; podría haberlo encontrado el contador del log.

**Por qué llegó a producción**

Porque **no rompe nada**. La consola funciona perfecto, el operador no percibe
absolutamente nada, no hay error en ninguna consola, y el logout faltante no
produce ningún síntoma el día que se escribe. El costo aparece meses después, lo
paga otra área, y llega expresado en una unidad —un aviso de abuso del proveedor—
que nadie asocia con una línea de código.

Ahí está la respuesta a la pregunta del enunciado: nadie se quejó porque **no hay
nadie a quien le duela**. El operador no lo sufre, el desarrollador no lo ve, y el
que lo paga no sabe leer un pipe de RxJS. Es la definición del bug caro con parche
barato, y por eso el curso lo marca con ⭐.

Es también, exactamente, el problema que empujó al equipo a adoptar
`redux-observable` en 2022 (`00-historia-del-sistema.md` §3, era 3): un
`setInterval` que seguía preguntando después del logout, para siempre. La
herramienta que vino a resolverlo trae la solución —`takeUntil`— y también la forma
de olvidarla.

**Si tu causa fue distinta a esta**

Si dijiste *"falta la limpieza del `useEffect`"*, tienes razón a medias, y conviene
comprobar la otra mitad. Pon solo la limpieza y repite: el síntoma desaparece,
porque hoy el único logout posible desmonta la pantalla. Pero el epic queda
dependiendo de que haya una pantalla montada que se acuerde de pararlo. El día que
otra parte de la consola despache `startPolling` —un botón en la ficha del jugador,
una pantalla nueva— o que un logout llegue sin desmontar nada, el leak vuelve con la
misma cara. La limpieza es del lado de React; el logout es del lado del epic, y la
corrección de verdad es la del epic: **desmontar la interfaz no cancela nada que el
epic no escuche**.

Si dijiste *"es el `switchMap`, que no cancela"*, el `switchMap` cancela el polling
anterior **cuando llega otro `startPolling`**. Después del logout no llega ninguno,
así que no tiene nada que cancelar.

</details>

---

## Incidente 15 — Busco a la jugadora rápido y me muestra a otra

> **Fase:** 6 · **Categoría:** RxJS / epics · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min

### 🎫 El ticket

Cuando busco a una jugadora en el asistente, la lista me muestra cualquier cosa.
Escribo "Anaís" y me aparece Ana, la que está suspendida. Si escribo despacio,
letra por letra, anda bien. Ayer casi le mando una compensación a la persona
equivocada porque la lista decía otra cosa de la que yo había escrito.

**Reportado por:** soporte
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar y arreglar. Y explicar dos cosas que el ticket regala:
**por qué escribir despacio lo arregla**, y por qué eso descarta de entrada la
mitad de las hipótesis.

### 🔧 Preparación

- **Rama:** `incidente/15`, desde `fase-06-redux-observable-a-fondo`.
- **Caos:** `CHAOS_LEVEL=high`. **Obligatorio**, y acá el motivo es preciso: el bug
  no existe sin latencia variable. Con el mock respondiendo en tres milisegundos,
  las respuestas vuelven en el mismo orden en que salieron y el problema es
  invisible. Este incidente **no se puede reproducir con `off`**, por mucho que
  escribas rápido.
- **Datos:** los de la fase traen a Ana (`banned`) y a Anaís (`active`). Que un
  nombre sea prefijo del otro, con estados opuestos, es lo que hace el síntoma
  inconfundible: la búsqueda de "Ana" trae a las dos.

```bash
git checkout incidente/15
CHAOS_LEVEL=high npm run mock:api
npm start
# /grants → en «Buscar jugador», escribe Anaís a velocidad normal. Repite unas cuantas veces.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No es un problema del campo de texto. Escribe con Network abierto y mira dos
columnas: cuántas búsquedas salieron, y la columna **Time** de cada una. Después
ordénalas por el momento en que **volvieron**, no por el momento en que salieron.
Ahí está todo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/grants/epics/searchPlayerEpic.js`. Compara su operador de
aplanamiento con lo que la Fase 6 dice que va en una búsqueda.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si dos búsquedas están en vuelo al mismo tiempo y la primera tarda más que la
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
{{Las búsquedas de Network con su tiempo de respuesta, y las acciones
`grants/playerSearchSucceeded` en el orden en que llegaron al store.}}

```text
{{qué salió, qué volvió, y en qué orden}}
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

`searchPlayerEpic` usa `mergeMap` donde corresponde `switchMap`.

`mergeMap` mantiene **todas** las búsquedas en vuelo a la vez y deja pasar sus
respuestas en el orden en que lleguen. Con latencia variable —que es lo que hace el
caos y lo que hace cualquier red real— la respuesta de "Ana" puede volver después
de la de "Anaís", y como el reducer aplica lo último que recibe, la lista de la
búsqueda vieja pisa a la de la nueva. El campo dice "Anaís", la lista muestra a
Ana, suspendida.

Es el error común #2 de la Fase 6, y la fase es tajante sobre cómo llamarlo: **no
es cosmético, es corrección contra bug.**

**Y por qué escribir despacio lo arregla**

Porque con pausas largas solo hay una búsqueda en vuelo por vez, y una búsqueda
sola no puede cruzarse con nadie. Esa frase del ticket —*"si escribo despacio anda
bien"*— es un regalo: descarta de un plumazo el campo de texto, el reducer, el
componente y el backend. Ninguno de ellos se comporta distinto según la velocidad
de escritura. **Lo único que cambia con la velocidad es cuántas cosas ocurren a la
vez**, y eso solo apunta a concurrencia.

**El debounce no es la causa**

La tentación es subir el `debounceTime`. Hazlo con el `mergeMap` todavía puesto: el
bug **sigue apareciendo**, solo que necesitas una pausa algo mayor en mitad del
nombre. Menos frecuente, igual de incorrecto. Al revés, con un debounce mínimo y
`switchMap`, salen muchas búsquedas —derroche de red— y **el resultado siempre es
correcto**. De ahí sale la conclusión que vale para el resto de tu carrera: **el
debounce es una optimización, el operador de aplanamiento es una decisión de
correctitud.** Se parecen porque los dos "reducen peticiones", y no son lo mismo.

**Parche mínimo**

```javascript
// src/features/grants/epics/searchPlayerEpic.js
action$.pipe(
  ofType(playerSearchRequested.type),
  debounceTime(SEARCH_DEBOUNCE_MS),
  // switchMap: cada búsqueda nueva abandona la anterior en vuelo.
  switchMap((action) => { /* … la búsqueda, igual que antes … */ })
)
```

**La refactorización correcta**

`switchMap` es la versión correcta, y es la que la Fase 6 ya tenía escrita. Lo que
se puede agregar aparte, y que revela algo más profundo, es una guarda en el
reducer:

```javascript
playerSearchSucceeded(state, action) {
  // Ignora la respuesta de una búsqueda que ya no es la que el operador está mirando.
  if (action.payload.query !== state.playerSearch.query) return;
  state.playerSearch.loading = false;
  state.playerSearch.results = action.payload.results;
},
```

Es cinturón además de tirantes, y sobre todo nombra un olor de diseño: la respuesta
ya trae la búsqueda que la originó (`query`), y el reducer no la estaba mirando.
Sin esa comparación, el store depende por completo de que el epic haya cancelado
bien.

**Prueba de regresión**

```javascript
// src/features/grants/epics/searchPlayerEpic.order.test.js (la misma prueba que corre en el repo de prueba).
import { TestScheduler } from "rxjs/testing";
import { searchPlayerEpic } from "./searchPlayerEpic";
import { playerSearchRequested, playerSearchSucceeded } from "../grantSlice";

test("buscar «Ana» y enseguida «Anaís»: solo llega la respuesta de «Anaís»", () => {
  const scheduler = new TestScheduler((actual, expected) => expect(actual).toEqual(expected));
  scheduler.run(({ hot, cold, expectObservable }) => {
    const ANA = [{ id: 44, name: "Ana", status: "banned" }, { id: 45, name: "Anaís", status: "active" }];
    const ANAIS = [{ id: 45, name: "Anaís", status: "active" }];
    // «Ana» tarda más que «Anaís»: es la latencia que el caos alto produce de vez en cuando.
    const api = {
      get: (url, { params }) =>
        params.name_like === "Ana" ? cold("500ms r|", { r: { data: ANA } }) : cold("100ms r|", { r: { data: ANAIS } }),
    };
    const action$ = hot("-a 400ms b", { a: playerSearchRequested("Ana"), b: playerSearchRequested("Anaís") });
    // Con el bug (mergeMap) llegan las dos, y la de «Ana» en último lugar.
    expectObservable(searchPlayerEpic(action$, null, { api })).toBe("802ms s", {
      s: playerSearchSucceeded({ query: "Anaís", results: ANAIS }),
    });
  });
});
```

Reproducir una inversión de orden en la consola requiere suerte y caos;
reproducirla con canicas es escribir dos búsquedas distintas. Ese es el argumento
entero a favor de `A11-marble-testing.md`.

**Prevención**

Una regla por defecto que resuelve el noventa por ciento de los casos:
**`switchMap` cuando solo importa el último resultado** —búsquedas, validaciones,
autocompletado, cualquier cosa atada a lo que el operador está mirando ahora
mismo—; **`mergeMap` solo cuando cada operación es independiente y sus resultados
no se pisan**. Y si en una revisión de código aparece un `mergeMap`, que su autor
tenga que decir en voz alta por qué no es `switchMap`.

**Por qué llegó a producción**

Porque en la máquina de quien lo escribió la latencia es de tres milisegundos y
**las respuestas siempre vuelven en orden**. El orden de llegada no es una
propiedad del código: es una propiedad de la red. Y el código se escribe sobre una
red que en la práctica no existe.

Y sobrevivió porque el síntoma parece un problema de la interfaz —"la lista me
muestra cualquier cosa"— y porque es intermitente, así que quien fue a mirarlo
escribió el nombre una vez, despacio, vio que funcionaba, y cerró el ticket.

El costo real no es cosmético: una lista que muestra a la jugadora equivocada es,
en soporte, una compensación mandada a quien no correspondía.

**Si tu causa fue distinta a esta**

Si dijiste *"es el debounce"*, lee arriba: cambia la frecuencia, no la
correctitud. Es la hipótesis más común y es una media verdad, que en depuración es
peor que una hipótesis equivocada — porque tocarla mejora el síntoma lo suficiente
como para dar por cerrado el caso.

Si dijiste *"el input pierde caracteres"*, mira el payload de las acciones
`grants/playerSearchRequested`: están todas, completas y en orden. Lo que se
desordena es la vuelta, no la ida. Y si tu fix fue deshabilitar el buscador
mientras hay una búsqueda en curso, funciona y hace la consola notablemente peor de
usar: convertiste un problema de concurrencia en un problema de ergonomía.

</details>

---

## Incidente 16 — Seguimos enviando giros de una rueda que ya cerró

> **Fase:** 7 · **Categoría:** Tiempo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min
> · Hermano del incidente `be-12`, con otra causa raíz

### 🎫 El ticket

La Rueda de fin de mes cerraba el 30 a las 8 de la noche y la consola siguió
dejando enviar giros de ella. Tenemos catorce giros manuales con fecha posterior al
cierre, y uno cayó en el avatar raro. La noche del 30, desde la oficina de Panamá, a
mí ya no me dejaba elegirla; Yariela, que a las 11 estaba atendiendo a un jugador de
Chile con la computadora configurada en su hora, dice que a ella sí. No sé si eso
tiene algo que ver. Y lo más raro: hoy en la mañana a mí también me deja.

**Reportado por:** operación
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir y localizar. Y prestarle atención a la última frase del ticket, que
parece un comentario al pasar y es el dato central: **dos personas en máquinas
distintas vieron cerrar la misma rueda en momentos distintos.**

> ⚠️ **Sin declarar la zona horaria, este incidente no se reproduce.** No es un
> detalle de la preparación: es el mecanismo del bug. Si intentas reproducirlo sin
> fijar la zona horaria, vas a concluir que no pasa.

### 🔧 Preparación

- **Rama:** `incidente/16`, desde `fase-07-cierre-polling-compras`.
- **Caos:** `off`. El bug es determinista una vez que la zona horaria está fijada.
- **Datos:** los de la fase traen la Rueda de fin de mes, `live`, con `closesAt` en
  `2026-08-30T20:00:00-05:00`. El offset explícito es parte del dato.
- **Zona horaria:** el navegador toma la del sistema operativo; la forma más simple
  es arrancar el servidor de desarrollo con `TZ` y abrir la consola en otro perfil
  de navegador, o correr la prueba de abajo con `TZ` fijado.

```bash
git checkout incidente/16
npm run mock:api
TZ=America/Panama npm start        # la consola de la oficina
# Y después, la misma prueba con:
TZ=America/Santiago npm start      # la computadora configurada en la hora de Chile
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes del código, haz el experimento que el ticket describe sin saberlo: mira la
misma rueda en el asistente, a la misma hora real, con dos zonas horarias. Y cambia
también la hora del día: a las 10 de la mañana, a las 9 de la noche. Si el
resultado cambia con la zona y con la hora, la causa está en cómo se compara el
tiempo, y no en el estado de la rueda.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/wheels/closing.js`, la función que decide si una rueda está cerrada.
Mira **con qué** compara: ¿dos instantes, o dos pedazos de fecha?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué devuelve `new Date('2026-08-30T20:00:00-05:00').getHours()` en una máquina
configurada en `America/Santiago`? ¿Y qué fecha mira esa comparación? Escríbelo en
la consola antes de contestar de memoria.

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, y **obligatorio**: la zona horaria en cada intento, la hora del
día, y el `closesAt` exacto de la rueda con su offset.}}

**Evidencia observable**
{{El resultado del mismo experimento en dos zonas horarias, lado a lado.}}

```text
{{TZ=...  → la ofrece / no la ofrece    ·    TZ=...  → la ofrece / no la ofrece}}
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

La guarda de cierre desarma la fecha en partes en vez de comparar instantes:

```javascript
// ❌ getHours() devuelve la hora EN LA ZONA DE LA MÁQUINA, y la fecha no cuenta.
export function isWheelClosed(wheel, now) {
  if (wheel.status === "ended" || wheel.status === "reconciled") return true;
  // cierra a las 8 de la noche: se compara la hora del día
  return new Date(now).getHours() >= new Date(wheel.closesAt).getHours();
}
```

Dos defectos en una línea. El primero: compara solo la hora del día. Un 15 de
octubre a las 10 de la mañana, la rueda que cerró el 30 de agosto "todavía no
cerró", porque 10 es menor que 20; a las 9 de la noche, sí. Eso explica el "hoy en la
mañana a mí también me deja". El segundo: `getHours()` no devuelve el instante,
devuelve cómo **se ve** ese instante desde la zona de la máquina que pregunta. En
`America/Santiago`, en agosto, el cierre se ve a las 21; y a las 23:15 de Panamá el
reloj de Santiago ya pasó la medianoche y marca las 0. Cero es menor que 21, y la
rueda "se reabre" en esa máquina mientras sigue cerrada en la de al lado. Por eso dos
computadoras ofrecen y niegan la misma rueda en el mismo instante. Es el error común
#1 de la Fase 7.

| Instante real (hora de Panamá) | `TZ=America/Panama` | `TZ=America/Santiago` |
|---|---|---|
| 30/08, 19:30 | abierta (19 < 20) | abierta (20 < 21) |
| 30/08, 20:30 | cerrada (20 ≥ 20) | cerrada (21 ≥ 21) |
| 30/08, 23:15 | cerrada (23 ≥ 20) | **abierta** (0 < 21) |
| 31/08, 10:00 | **abierta** (10 < 20) | **abierta** (11 < 21) |

Y por eso el comentario final del ticket —*"no sé si eso tiene algo que ver"*— era
el diagnóstico entero. **Cuando dos usuarios ven comportamientos distintos frente
al mismo dato, la diferencia está en sus máquinas, no en el dato.** Es la misma
forma de razonar del incidente 02 y del 20, en tres capas completamente distintas.

**Parche mínimo**

Comparar instantes contra instantes, que es lo que hace la `closing.js` de la fase:

```javascript
const closesAt = Date.parse(wheel.closesAt);
if (Number.isNaN(closesAt)) return true;
return now >= closesAt; // en el instante exacto del cierre, ya está cerrada
```

`Date.parse` devuelve milisegundos desde la época, idénticos en todo el planeta. La
zona horaria deja de participar de la decisión y pasa a ser lo único que debería
haber sido siempre: un asunto de **presentación**.

**La refactorización correcta**

Dos capas, y la segunda es la importante:

1. **Centralizar toda comparación de tiempo en `closing.js`** y prohibir
   `getHours()`, `getDate()` y `getMonth()` en el resto del código con una regla de
   lint. Desarmar una fecha es legítimo para mostrarla y nunca para decidir con
   ella.
2. **Que la hora la decida el servidor.** Hoy la guarda usa el reloj de la máquina,
   y el reloj de la máquina lo controla quien la usa. Toda esta guarda es una
   comodidad de la consola, no una garantía. La garantía tiene que estar del otro
   lado del cable, y eso es la deuda 💸 que la Fase 7 declara y paga `be06`.

**Prueba de regresión**

```javascript
// src/features/wheels/closing.timezone.test.js (la misma prueba que corre en el repo de prueba). Córrela con TZ=America/Panama.
import { isWheelClosed } from "./closing";

test("una rueda que cerró el 30/08 a las 20:00 sigue cerrada un 15/10 a las 10:00", () => {
  const wheel = { id: 4, status: "live", closesAt: "2026-08-30T20:00:00-05:00" };
  const now = Date.parse("2026-10-15T10:00:00-05:00");
  expect(isWheelClosed(wheel, now)).toBe(true); // con el bug: false (10 < 20, y la fecha no cuenta)
});
```

Con `TZ=America/Panama`, la rama `incidente/16` falla (`Expected: true`,
`Received: false`); con la comparación de instantes, pasa en cualquier zona. La
forma del test es la lección: **un test de tiempo que corre en una sola zona no
prueba nada sobre tiempo; prueba sobre la máquina que lo corrió**. En UTC, esta
misma prueba **pasa con el bug**: allá el cierre se ve a la 1 de la mañana y las 10
de Panamá son las 15, así que "15 ≥ 1" da cerrada por la razón equivocada. Para que sea red de verdad, córrelo en varias zonas (`TZ=… npm test`), que
es lo que lleva directo al incidente 20.

**Prevención**

La regla de lint contra los desarmadores de fecha, la prueba en varias zonas, y una
convención de datos que ahorra la mitad de estos bugs: **todas las fechas viajan y
se guardan con offset explícito** (`2026-08-30T20:00:00-05:00`), nunca como
`2026-08-30 20:00`. Una fecha sin offset no es un instante: es un texto que cada
máquina interpreta como quiere.

**Por qué llegó a producción**

Porque todo el equipo de Panamá está en la misma zona horaria, y siempre se probó
de día y el mismo día del cierre. En esas condiciones este código **parece
correcto**. Ninguna demo puede revelar el error mientras todos los relojes
coincidan y nadie pruebe después de la fecha. El bug estuvo latente hasta el primer
cierre que alguien miró al día siguiente, y la zona horaria de Yariela le agregó la
noche del 30, todo sin que cambiara una línea de código.

**Si tu causa fue distinta a esta**

Si dijiste *"la rueda sigue en `live`"*, es una hipótesis buena y hay que
descartarla mirando el store: el `status` dice `live` también con la guarda
correcta, y ahí la rueda sí aparece cerrada, porque la hora dura es independiente
del enum. El enum es del store, la hora es del reloj, y son dos preguntas
distintas.

**Y acá está el cruce con el track BE.** El incidente `be-12` —*"giros anotados
después del cierre"*— tiene el mismo síntoma con la causa una capa más abajo: allá
la comparación de instantes está bien hecha, y el problema es **quién tiene
autoridad sobre la hora**. Acá la consola se equivoca al interpretar el instante;
allá el servidor le cree al estado que deja un barrido, en vez de mirar el reloj
cuando decide. Si haces el track BE, este par enseña la diferencia entre *calcular
bien el tiempo* y *tener derecho a decidir sobre el tiempo*.

</details>

---

## Incidente 17 — La compra pendiente nunca se confirma, y la consola dice que sigue consultando

> **Fase:** 7 · **Categoría:** RxJS / epics · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min

### 🎫 El ticket

Un jugador pagó en OXXO a las 7 de la tarde y me escribió para preguntar por sus
giros. Pegué el código en la consola y se quedó en "Esperando confirmación ·
consultando…". Al ratito salió abajo un aviso en rojo, que el servidor tuvo un
problema y que intentara de nuevo, pero como seguía diciendo "consultando…" pensé
que lo estaba reintentando sola. Estuve hasta las 9 mirando la pantalla. Al final
le pedí a Carlos que revisara en la tienda, y la compra estaba confirmada desde las
7:20.

**Reportado por:** soporte
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir y decidir cuál de **dos causas plausibles** produjo este caso concreto.
Las dos dejan a soporte mirando "Esperando confirmación · consultando…"; se
distinguen con una sola observación. Después, el fix.

### 🔧 Preparación

- **Rama:** `incidente/17`, desde `fase-07-cierre-polling-compras`.
- **Caos:** `CHAOS_LEVEL=high`, y **en el mock de Google Play, el del puerto
  `3002`** —no en el `3001`—. Hace falta que un tick reciba un `500`; sin eso el
  bug no se enciende. Es el error más común al preparar este incidente: subir el
  caos en el mock equivocado y concluir que no se reproduce.
- **Datos:** una compra en efectivo creada justo antes de consultarla, con la
  demora por defecto (`PLAY_PENDING_MS=3000`).

```bash
git checkout incidente/17
npm run mock:api
CHAOS_LEVEL=high npm run mock:googleplay     # el 3002, no el 3001
curl -s -X POST localhost:3002/purchases -H 'Content-Type: application/json' \
  -d '{"purchaseToken":"tok-oxxo-7","method":"cash"}'
npm start
# /purchases → consulta tok-oxxo-7 → deja la pantalla abierta, mirando Network.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Network, filtrado por `purchases`. No mires si hay errores: **cuenta los `GET` y
fíjate en qué momento dejan de salir**. Un polling sano deja un rastro regular en
la pestaña. La hora exacta en la que ese rastro se corta es el dato que decide todo
el diagnóstico.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/purchases/epics/pollingEpic.js`. Localiza el `catchError` y responde
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
{{La secuencia de `GET /purchases/…` con sus horas y sus status, y el momento
exacto en que dejan de aparecer.}}

```text
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

**Causa A — el `catchError` envuelve al `timer`.** Cuando el primer `500` del
servicio de compras llega, el `catchError` lo atrapa, emite su `pollingFailed` y
—esto es lo que importa— **completa el stream que envuelve**, que es el `timer`
entero. El polling muere ahí. No hay más ticks, no hay más consultas, y el store se
queda con el último estado que tenía: "Esperando confirmación · consultando…",
porque el `pollingToken` nunca se limpió, y debajo el aviso del `500`, que ya no se
borra porque no llega otra respuesta que lo borre. Es el error común #2
de la Fase 7, y es el error #1 de la Fase 6 aplicado al polling: **el `catchError`
mata lo que envuelve.**

**Causa B — la espera es real.** Google Play confirma un pago en efectivo minutos u
horas después, hasta dos días en el peor caso. Si la tienda todavía no confirmó, el
polling está sano y cada consulta dice, con razón, `pending`. Es la otra forma de
quedarse mirando "Esperando confirmación". Y si el caos tira algún `500` por el
camino, el aviso rojo también aparece, y desaparece en el tick siguiente.

**Se distinguen con una sola columna de Network:**

| | Causa A — `catchError` mal ubicado | Causa B — la espera de la tienda |
|---|---|---|
| Los `GET /purchases/…` | **paran** y no vuelven nunca | **siguen saliendo** cada 2 s |
| Su respuesta | el último es un `500` | `200` con `state: "pending"` |
| El aviso rojo | se queda fijo | aparece y se borra con el tick siguiente |
| La columna «Última consulta» | **congelada** en la hora del `500` | avanza cada 2 s |
| Qué ve soporte | "Esperando confirmación · consultando…" | "Esperando confirmación · consultando…" |

El encabezado de la pantalla dice lo mismo en los dos casos, y lo que los separa
—el aviso que no se borra, la hora que no avanza— está en letra chica, justo donde
nadie mira después de la primera media hora. La red no deja dudas. **Cuando dos
causas producen la misma interfaz, la evidencia tiene que venir de una capa donde se
comporten distinto**, y esa es la razón por la que la pista 1 te manda a contar consultas en
lugar de a buscar errores.

En este incidente concreto —la compra confirmada desde las 7:20— es la **causa A**:
los `GET` se cortan en un `500` y no vuelven.

**Parche mínimo**

El `catchError` va adentro del tick, envolviendo la consulta y no al `timer`:

```javascript
timer(0, POLLING_INTERVAL_MS).pipe(
  mergeMap(() =>
    from(store.get(`/purchases/${token}`)).pipe(
      map((response) => purchaseStatusReceived({ /* … */ })),
      // Muere el tick, no el polling: el siguiente sale igual.
      catchError((error) => of(pollingFailed({ token, error: toReadableError(error) })))
    )
  ),
  takeWhile(/* … */, true),
  takeUntil(/* … */)
)
```

**La refactorización correcta**

Una cosa más, que este incidente deja al descubierto: **un límite al "esperar"**.
Si pasó una hora y la compra sigue sin confirmarse, la pantalla tiene que decirlo de
otra forma: hoy "Esperando confirmación · consultando…" significa las dos cosas a la
vez, *"la tienda todavía no confirmó"* y *"me morí hace una hora"*. **Un estado que también
significa su propio fallo es un defecto de diseño de estados**, y es literalmente
el mismo defecto del incidente 07 una capa más arriba: nadie decidió cuánto es
demasiado. El primer paso es barato: que "consultando…" dependa de que la última
consulta sea reciente, no de que exista un `pollingToken`. La hora ya está en la
columna «Última consulta»; si tiene más de dos intervalos de antigüedad, la pantalla
tiene que dejar de decir que consulta.

**Prueba de regresión**

```javascript
// src/features/purchases/epics/pollingEpic.survival.test.js (la misma prueba que corre en el repo de prueba).
import { TestScheduler } from "rxjs/testing";
import { pollingEpic, POLLING_INTERVAL_MS } from "./pollingEpic";
import { startPolling, pollingFailed } from "../purchaseSlice";

test("después de un 500, el tick siguiente pregunta igual y llega la confirmación", () => {
  const scheduler = new TestScheduler((actual, expected) => expect(actual).toEqual(expected));
  scheduler.run(({ hot, cold, expectObservable }) => {
    const error = Object.assign(new Error("500"), { response: { status: 500, data: {} } });
    let call = 0;
    const store = {
      get: () => {
        call += 1;
        return call === 1 ? cold("#", {}, error) : cold("r|", { r: { data: { state: "confirmed" } } });
      },
    };
    const action$ = hot("a", { a: startPolling("tok-efecty-1") });
    // Con el bug, el diagrama se queda en «f»: el polling murió en el primer 500.
    expectObservable(pollingEpic(action$, null, { store })).toBe(`f ${POLLING_INTERVAL_MS - 1}ms c`, {
      f: pollingFailed({ token: "tok-efecty-1", error: { message: "El servidor tuvo un problema. Intenta de nuevo.", type: "http" } }),
      c: expect.objectContaining({ type: "purchases/purchaseStatusReceived", payload: expect.objectContaining({ state: "confirmed" }) }),
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

Porque el polling se probó contra un servicio de compras sano, que es el único que
existe en la máquina de quien programa. El `500` de un tercero es exactamente el
evento que no puedes provocar en desarrollo si no construiste antes un mock que
falle a propósito —que es la razón entera por la que la Fase 3 existe, y por la que
la Fase 7 le puso caos al `3002`—.

Y llegó, sobre todo, porque el fallo se disfrazó de comportamiento normal.
"Esperando confirmación" es un mensaje legítimo y frecuente —la causa B existe de
verdad todos los días—, el aviso rojo decía "intenta de nuevo", y el "consultando…"
de al lado le prometía que eso ya estaba pasando. Soporte lo miró dos horas sin
motivo para desconfiar. Los
fallos que se ven iguales que el funcionamiento correcto no generan tickets:
generan gente esperando.

**Si tu causa fue distinta a esta**

Si dijiste *"la tienda no confirmó"*, esa es la causa B, y se descarta con Network:
los `GET` se cortaron. Si dijiste *"el `takeUntil` cortó de más"* —el operador tocó
«Dejar de consultar», o la pantalla se desmontó— es una hipótesis excelente y se
descarta mirando **qué** ocurrió justo antes del último `GET`: con un `takeUntil`
que corta, el corte coincide con una acción concreta en DevTools (`stopPolling`, el
logout); acá coincide con un `500`. El momento del corte te dice quién lo cortó.

</details>

---

## Incidente 18 — La conciliación da un centavo de diferencia

> **Fase:** 8 · **Categoría:** Dinero · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min
> · Hermano del incidente `be-13`, con otra causa raíz

### 🎫 El ticket

El prorrateo del paquete tok-ago-05 suma US$21,00 y el paquete se vendió a US$20,99.
Un centavo. Ya sé que suena a nada y que me van a decir que lo redondee, pero no
firmo una conciliación sin saber de dónde sale cada centavo. Y antes de que me lo
pregunten: revisé los otros tres paquetes de 500 de agosto, y uno da el mismo
centavo de más, otro cuadra y otro da un centavo de menos. ¿Y ese centavo de dónde
salió?

**Reportado por:** contabilidad (Licda. De Gracia)
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir con los datos exactos del reporte, localizar el cálculo culpable y
arreglarlo. Y contestarle a la contadora las dos cosas que su ticket deja planteadas:
**por qué un paquete descuadra para arriba, otro para abajo y otro no descuadra**, y
**cuánto puede llegar a ser el error**.

Este incidente es el más chico del cuaderno en tamaño del síntoma y de los más
grandes en tamaño de la causa. Esa desproporción es la lección entera.

### 🔧 Preparación

- **Rama:** `incidente/18`, desde `fase-08-conciliacion`.
- **Caos:** `off`. No hay ninguna red involucrada en el error: es aritmética.
- **Datos:** los de la fase, sembrados con `npm run seed:reconciliation`. El paquete
  `tok-ago-05` es el primero de 500 giros que la bitácora consume entero, y es el
  que la pantalla muestra.

```bash
git checkout incidente/18
npm run seed:reconciliation        # con los mocks parados
npm run mock:all
npm start
# /reconciliation → Rueda de fin de mes → mira «Prorrateo del paquete tok-ago-05» y la suma de sus filas.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No hace falta la aplicación. Copia los ocho conteos de la tabla del prorrateo, abre
una consola de Node, y calcula a mano lo que vale cada fila: los giros de la fila por
el precio de un giro. Antes de redondear nada, anota con todos sus decimales lo que
vale un giro.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/reconciliation/reconciliationSlice.js`, la línea que arma
`packageProration`, y la función a la que llama. La Fase 8 pide una regla: **el
dinero se reparte con división entera y el resto explícito**. Busca el punto exacto
donde la regla se rompe.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si redondeas cada fila al centavo más cercano, cada fila se equivoca en menos de
medio centavo, para arriba o para abajo. ¿Qué pasa con esos errores cuando sumas
ocho filas? ¿Y de qué depende hacia qué lado caigan?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, con los valores exactos: el precio, los ocho conteos, la suma que
esperabas y la que salió.}}

**Evidencia observable**
{{El resultado de correr la cuenta en la consola, fila por fila, con todos sus
decimales antes de redondear. Este es uno de los incidentes del cuaderno donde la
evidencia decisiva no está en el navegador.}}

```text
{{conteo · valor sin redondear · valor redondeado, por fila; y las dos sumas}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y en cuál de las cuatro capas de auditoría de la Fase 8 apareció:
el cálculo, sus entradas, el estado o la presentación.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta. Y la respuesta a la
contadora: por qué cada paquete descuadra distinto, y cuánto puede ser el error.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El panel prorratea con `prorateSpinPriceBroken`, la versión del ejercicio 18 de la
Fase 8 que alguien conectó "un momento" y no desconectó. Calcula el precio de un giro
en dólares y redondea cada fila:

```javascript
// ❌ 0,04198 dólares por giro, y cada fila redondeada por su cuenta.
const perSpinDollars = packagePriceCents / 100 / spins;
return counts.map((count) => Math.round(count * perSpinDollars * 100));
```

En la consola, con los conteos de `tok-ago-05`:

```text
148 giros · 621,304 → 621        57 giros · 239,286 → 239
 95 giros · 398,810 → 399        38 giros · 159,524 → 160
 71 giros · 298,058 → 298        13 giros ·  54,574 →  55
 74 giros · 310,652 → 311         4 giros ·  16,792 →  17
                                  suma: 2.100 (el paquete: 2.099)
```

Cada fila está **bien redondeada**: ninguna se equivoca en más de medio centavo. El
problema no está en ninguna fila; está en sumarlas. Cinco filas redondean para
arriba y tres para abajo, y los errores no se compensan: suman +1. El float agrega
su granito (el precio por giro es `0.041979999999999996`, no 0,04198), pero no es la
causa: con aritmética exacta, el redondeo por fila da el mismo 2.100.

La causa está en la **primera** de las cuatro capas de auditoría de la Fase 8: el
cálculo. Y por eso el diagnóstico se hace en una consola de Node, sin abrir el
navegador.

**La respuesta a la contadora**

Las dos preguntas tienen una sola respuesta: **el error depende de cómo cayeron los
giros**. Con ocho filas, cada una se equivoca entre −0,5 y +0,5 centavos, y la suma
de los errores puede dar −4, −3… hasta +4, según el reparto. En agosto, con los mismos
2.099 centavos, `tok-ago-05` da 2.100, `tok-ago-19` da 2.099 y `tok-ago-26` da
2.098. Ninguno de los tres está "más roto" que los otros: los tres usan el cálculo
equivocado, y uno tuvo suerte.

La respuesta honesta a *"¿cuánto puede ser?"* no es *"un centavo"*. Es: **hasta medio
centavo por fila, en cualquier dirección, y no se cancela por promedio**. Con ocho
filas, hasta cuatro centavos por paquete. Con un reporte por jugador en vez de por
segmento —miles de filas—, cualquier cosa. Por eso no se acota: se elimina.

> 🧠 **La desproporción es el mensaje.** El síntoma mide un centavo. La causa es
> que el cálculo reparte dinero sin garantizar que las partes sumen el todo. Un
> ticket pequeño puede tener una causa estructural, y la magnitud del síntoma no
> dice nada sobre la magnitud del problema. En dinero, esa confusión es
> especialmente cara: **el redondeo esconde el error justo lo suficiente como para
> que nadie lo investigue**, y que un paquete cuadre es lo que más lo esconde.

**Parche mínimo**

Volver a conectar el panel a `prorateSpinPrice`, que reparte con `prizeShare`:
división entera para todos los giros, y el resto —99 centavos— de a uno.

```javascript
cents: prorateSpinPrice(big.packagePriceCents, countLanded(spinsByToken.get(token), segments)),
```

Con los mismos conteos: 691, 380, 284, 296, 228, 152, 52 y 16 centavos. **2.099.**

La Fase 8 es explícita sobre cómo llamar a esto: **no es refactor, es sacar el
redondeo por fila de la línea que lo metió.**

**La refactorización correcta**

Que la versión rota no pueda volver a entrar:

1. **Borrar `prorateSpinPriceBroken`.** Una función equivocada escrita "al lado de la
   buena, para el ejercicio" es una trampa con nombre propio. El ejercicio vive en el
   repo del alumno, no en el código de la consola.
2. **La invariante en el cálculo, no en la pantalla.** `prorateSpinPrice` podría
   terminar con una aserción —que la suma de las filas sea el precio— y lanzar si no.
   Igual que `formatCents` con los floats: falla donde está el error.
3. **Repartos con resto explícito en todas partes.** Cualquier cálculo que divida
   dinero entre partes pasa por `prizeShare`. La mecánica está en
   `A10-aritmetica-de-dinero.md` §4.

**Prueba de regresión**

```javascript
// src/features/reconciliation/reconciliationSlice.proration.test.js (la misma prueba que corre en el repo de prueba)
import { store } from "../../app/store";
import { login } from "../auth/authSlice";
import { fetchReconciliation } from "./reconciliationSlice";

test("el prorrateo del paquete que muestra la conciliación suma exactamente su precio", async () => {
  await store.dispatch(login({ email: "mdegracia@esclusa.test", password: "esclusa123" }));
  await store.dispatch(fetchReconciliation(4));
  const { purchaseToken, cents, packagePriceCents } = store.getState().reconciliation.packageProration;
  expect(purchaseToken).toBe("tok-ago-05");
  expect(cents.reduce((sum, c) => sum + c, 0)).toBe(packagePriceCents); // con el bug: 2100 contra 2099
}, 20000);
```

Con la rama `incidente/18` falla (`Expected: 2099`, `Received: 2100`); con el parche,
pasa. Corre contra los dos mocks, porque lo que se prueba es lo que **la pantalla**
muestra: una prueba de `prorateSpinPrice` sola pasaba con el bug adentro, porque la
función buena nunca estuvo rota.

El detalle que hace útil esta prueba es lo que **no** usa. `toBeCloseTo` es la
herramienta correcta para medir cosas del mundo físico y la herramienta equivocada
para el dinero: una prueba de dinero que tolera aproximaciones aprueba justamente el
bug que tiene que impedir.

**Prevención**

La invariante "las partes suman el todo" escrita como prueba de propiedad (ejercicio
26 de la Fase 8): para cualquier precio y cualquier conjunto de conteos, las filas
suman el precio. Y una regla de revisión de código: un `Math.round` dentro de un
`map` sobre dinero es un hallazgo, siempre.

**Por qué llegó a producción**

Porque la versión rota **se ve bien**. Cada fila tiene un valor razonable, ninguna
tiene decimales raros, y con muchos paquetes la suma cuadra: en agosto, uno de cada
cuatro paquetes de 500 dio exacto. Quien la probó con un solo paquete pudo tener la
suerte de elegir el que cuadraba.

Y sobrevivió, sobre todo, por una reacción cultural que el ticket anticipa: *"me van
a decir que lo redondee"*. En la mayoría de los equipos, un centavo de diferencia se
cierra como "error de redondeo, no es nada". La contadora que se negó a firmar hasta
entenderlo hizo exactamente lo correcto, y es la razón por la que este incidente
existe.

**Si tu causa fue distinta a esta**

Si dijiste *"es el float de 0,04198"*, es media verdad: el float existe, y es mala
práctica, pero no explica este centavo. Haz la cuenta con fracciones exactas
(`count * 2099 / 500`) y redondea: da el mismo 2.100. Si dijiste *"falta redondear
el total"*, ese es el reflejo que hay que desarmar: redondear **es** la causa.
Agregar un redondeo más al final no arregla el reparto, lo disfraza mejor.

**Y acá está el cruce con el track BE.** El incidente `be-13` —*"la conciliación y el
reporte de la tienda no dan lo mismo"*— tiene un descuadre parecido y una causa
distinta: allá la aritmética está bien y lo que falla es **la fuente de los datos**.
Acá los datos son correctos y el cálculo los arruina. Cuando una cifra no cuadra,
esas son las dos preguntas, en este orden: *¿el cálculo está mal?* y *¿los datos que
entraron eran los de ahora?*

</details>

---

## Incidente 19 — El dashboard se arrastra al final de la Semana del Canal

> **Fase:** 9 · **Categoría:** Performance · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min
> · Hermano del incidente `be-05`, con otra causa raíz

### 🎫 El ticket

Estoy armando el tablero para el cierre de la Semana del Canal y desde que lo cargo
toda la consola se pone pesada. No solo el tablero: escribo en el buscador del
asistente de envíos y cada letra tarda en aparecer, toco «Deshacer» y tarda,
cambio de pantalla y tarda. Con la Rueda de fin de mes anda bien. Si recargo la
página sin abrir el tablero, vuela. En la consola del navegador hay un aviso
amarillo que se repite y que no entiendo.

**Reportado por:** el equipo de Juliana, preparando el evento
**Ambiente:** desarrollo (`npm start`)

### 🎯 Qué se te pide

Reproducir —que en este incidente es la mitad difícil, porque hace falta volumen—,
encontrar **quién** tarda, y arreglar. Y explicar dos frases del ticket que parecen
detalles y son el diagnóstico: *"no solo el tablero"* y *"con la Rueda de fin de
mes anda bien"*.

### 🔧 Preparación

- **Rama:** `incidente/19`, desde `fase-09-dashboard`.
- **Caos:** `off`. El caos agrega latencia de red, y lo que se mide acá es lo que
  tarda el navegador.
- **Datos, y son el corazón del incidente:** hace falta **volumen**. Con la Rueda
  de fin de mes (10.000 giros) se nota poco, y esa es la razón por la que el bug
  llegó hasta el evento. La siembra de la fase trae la Semana del Canal con un día
  de evento:

```bash
git checkout incidente/19
node mock/seed-reconciliation.js --event    # con los mocks parados: 180.000 giros en la rueda 2
npm run mock:all
npm start
# Abre /dashboard, elige «Semana del Canal», y después escribe en el buscador de /grants.
# Al terminar: git checkout -- mock/db.json mock/googlePlay/earnings.json
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes del Profiler, la consola del navegador: el aviso amarillo dice exactamente
quién tarda y cuánto. Y después, DevTools → **Performance**: graba mientras
escribes una letra en el buscador y mira qué función se lleva el tiempo. Si el
React Profiler muestra renders rápidos y la pestaña igual se traba, el tiempo no
se va en renderizar.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/app/store.js`, el `middleware` de `configureStore`. ¿Qué hace
`getDefaultMiddleware()` en cada acción, y sobre qué?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si un middleware recorre **todo el estado** en cada acción, ¿qué pasa cuando una
rama del estado tiene 180.000 objetos? ¿Y por qué ese costo aparece en pantallas que
no tienen nada que ver con el tablero?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, con el volumen: cuántos giros tenía la rueda que abriste, y qué
pantalla usaste después.}}

**Evidencia observable**
{{El aviso de la consola, literal, con su número de milisegundos. Y lo que mostró
Performance.}}

```text
{{el aviso, y cuántas veces aparece por cada letra que escribes}}
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

En la rama, el store vuelve al middleware por defecto:

```javascript
// ❌ Los chequeos de desarrollo, sobre el estado entero, en cada acción.
middleware: (getDefaultMiddleware) => getDefaultMiddleware().concat(epicMiddleware),
```

En desarrollo, `getDefaultMiddleware()` monta dos chequeos que cuidan al equipo:
uno avisa si alguien muta el estado, otro si mete algo no serializable. Los dos
**recorren el estado entero en cada acción**, y el de serialización recorre además
el payload de la acción. Mientras el estado fueron unas ruedas y unos envíos,
eran microsegundos. Con la bitácora de la Semana del Canal en `dashboard.spinLog`
—180.000 filas— son cientos de milisegundos **por acción**: medido en la corrida
del curso, la mediana de nueve acciones cualquiera fue de **213 ms**, contra
**0,1 ms** con la bitácora excluida. Y el aviso que el ticket no entendía es de
Toolkit, literal:

```text
SerializableStateInvariantMiddleware took 480ms, which is more than the warning threshold of 32ms.
If your state or actions are very large, you may want to disable the middleware as it might cause
too much of a slowdown in development mode. … It is disabled in production builds, so you don't
need to worry about that.
```

Ahí están las dos frases del ticket. *"No solo el tablero"*: el costo es por
**acción**, y toda la consola despacha acciones —cada letra del buscador es un
`playerSearchRequested`, cada «Deshacer» un `undoGrant`—. *"Con la Rueda de fin de
mes anda bien"*: con 10.000 filas el recorrido es dieciocho veces más chico, y queda
debajo de lo que alguien percibe.

**Parche mínimo**

Que los chequeos no miren esa rama, ni la acción que la trae:

```javascript
// src/app/store.js
  // F09: los chequeos de desarrollo recorren el estado entero en cada acción. La bitácora del
  // tablero tiene miles de filas que nadie muta: se excluye de los dos, solo esa rama.
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      immutableCheck: { ignoredPaths: ["dashboard.spinLog"] },
      serializableCheck: {
        ignoredPaths: ["dashboard.spinLog"],
        // y la acción que la trae: este chequeo también mira el payload de cada acción.
        ignoredActionPaths: ["meta.arg", "meta.baseQueryMeta", "payload.spinLog"],
      },
    }).concat(epicMiddleware),
```

**La refactorización correcta**

El parche deja la bitácora en el store: 180.000 objetos en memoria del navegador
para dibujar ocho barras, bajados enteros en cada cambio de rueda. La corrección de
fondo es que el store **no guarde la bitácora**, sino los conteos —como ya hace la
conciliación de la Fase 8—, o mejor, que los conteos vengan agregados del servidor
(`be07`). Es el caso que la Fase 11 trabaja en §5.3, con las dos respuestas lado a
lado.

**Prueba de regresión**

```javascript
// src/features/dashboard/dashboardSlice.devchecks.test.js (la misma prueba que corre en el repo de prueba)
// Contra los dos mocks, con la Semana del Canal sembrada: node mock/seed-reconciliation.js --event
import { store } from "../../app/store";
import { login } from "../auth/authSlice";
import { fetchDashboard } from "./dashboardSlice";
import { undoGrant } from "../grants/grantSlice";

test("cargar la bitácora del evento, y después una acción de otra pantalla, no disparan el aviso de Toolkit", async () => {
  await store.dispatch(login({ email: "ibatista@esclusa.test", password: "esclusa123" }));
  const warn = jest.spyOn(console, "warn").mockImplementation(() => {});
  await store.dispatch(fetchDashboard(2)); // la acción que trae las 180.000 filas
  expect(store.getState().dashboard.spinLog).toHaveLength(180000);
  store.dispatch(undoGrant("g-inexistente")); // cualquier acción, de cualquier pantalla
  const slow = warn.mock.calls.filter(([message]) => String(message).includes("which is more than the warning threshold"));
  warn.mockRestore();
  expect(slow).toEqual([]); // con el bug: "SerializableStateInvariantMiddleware took … ms"
}, 60000);
```

Con la rama `incidente/19` falla: el espía recoge los avisos de Toolkit de la carga
y de la acción. Con el parche, pasa. Corre contra los mocks y con la Semana del
Canal sembrada, porque sin volumen el aviso no aparece y la prueba pasaría con el
bug.

**Prevención**

Una regla de revisión: **una rama del store que puede crecer sin límite —una
bitácora, un historial, un reporte— entra al store con su `ignoredPaths`, o no
entra**. Y una prueba con volumen, como la de arriba, en la suite de desarrollo.

**Por qué llegó hasta el evento**

Porque los dos chequeos **solo existen en desarrollo**: el build de producción no
los monta, y el mismo tablero ahí vuela. El equipo prueba en desarrollo, con la
Rueda de fin de mes, y nunca había cargado un evento en el navegador. El aviso de
Toolkit es justamente el mecanismo que existe para que esto no pase, y dice en su
última línea que en producción no hay de qué preocuparse — que es cierto, y es
también por qué nadie se preocupó.

**Si tu causa fue distinta a esta**

Si dijiste *"es el `useMemo` del tablero"*, es la hipótesis más razonable con la
Fase 9 fresca, y se mide: con el `useMemo` roto de la pieza forense, cambiar el
filtro tarda 12,5 ms con la Semana del Canal, contra 2,2 ms bien memoizado. Es un
bug real y no explica este: 12 ms no traban una consola, y el `useMemo` del tablero
no corre cuando escribes en el buscador de **otra** pantalla. El tiempo se va en el
`dispatch`, antes de que React se entere: es la diferencia entre los 213 ms por
acción con el bug y los 0,1 ms con el parche, con el mismo tablero y los mismos
renders. Si dijiste *"es la red"*, Network muestra una sola carga de la
bitácora, al elegir la rueda; lo que tarda después no sale del navegador.

**Y acá está el cruce con el track BE.** El incidente `be-05` tiene el mismo
síntoma —*"todo se arrastra al final del evento"*— una capa más abajo: allá es el
pool de conexiones de PostgreSQL, agotado por los envíos repetidos de la noche del
evento, cada uno con una conexión que nadie devolvió. Las dos caras del
mismo aprendizaje: **lo que anda con los datos de prueba se comporta distinto con
los del evento**, y el volumen se prueba antes, no la noche del cierre.

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
   consecuencias. Es uno de los incidentes del cuaderno que **no termina en un
   parche**, sino en un documento que alguien firma.

> 🧭 **Se abre en la Fase 10 y se cierra en la Fase 11.** La Fase 10 te da las
> herramientas para reproducirlo; el criterio para decidir —cuándo un parche es
> profesional y cuándo es una tapadera— es lo que aporta la Fase 11. Si llegaste
> acá desde la 10, reprodúcelo y déjalo en 🟡 En análisis.

### 🔧 Preparación

- **Rama:** `incidente/20`, desde `fase-10-testing-minimo`.
- **Caos:** no aplica; no hay red en juego.
- **Datos:** ninguno del `db.json`. Lo que hace falta es cambiar **tu máquina**, y
  ahí está la primera lección: la reproducción de este incidente no se consigue
  editando archivos.
- **Y hay que declarar dos cosas** que en el resto del cuaderno son contexto y acá
  son el mecanismo: **la zona horaria** y **la hora del sistema** de la máquina que
  corre la suite.

```bash
git checkout incidente/20
TZ=America/Bogota npm test -- MetricCard      # la del equipo: pasa
TZ=UTC npm test -- MetricCard                 # la del runner: falla
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Ni el test ni el código del test cambiaron, así que lo que cambió es **dónde
corre**. Antes de abrir un archivo, escribe la lista de todo lo que difiere entre tu
máquina y el servidor de integración: sistema operativo, versión de Node,
configuración regional, **zona horaria**, hora del sistema. Después tacha las que
no puedan afectar a un componente que muestra una fecha.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`MetricCard` y su línea "Actualizado". La pregunta concreta: **¿de dónde sale el
instante que muestra, y en qué zona lo formatea?** Compara con el `git log` del
archivo.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El test congela el reloj en las 21:00 del 20 de diciembre en Panamá. ¿Qué hora es
ese mismo instante en UTC? ¿Y qué día?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, y **obligatorio**: la zona horaria en cada intento, tuya y la del
runner. Sin esos datos este incidente no se puede contar.}}

**Evidencia observable**
{{La salida del test en las dos configuraciones, con el texto esperado y el
recibido.}}

```text
{{TZ=America/Bogota → verde     ·     TZ=UTC → esperaba "…", recibió "…"}}
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

Alguien "simplificó" la tarjeta: en vez de mostrar el instante de los datos que le
llega por props, calcula "Actualizado" con `new Date()` adentro, y lo formatea **sin
zona horaria**, o sea en la de la máquina:

```javascript
// ❌ El reloj y la zona de quien la renderiza, no el instante de los datos.
const UPDATED_FORMAT = new Intl.DateTimeFormat("es-PA", { day: "2-digit", month: "2-digit", hour: "2-digit", minute: "2-digit", hourCycle: "h23" });
// …
Actualizado: {UPDATED_FORMAT.format(new Date())}
```

El test congela el reloj del sistema en las 21:00 del 20 de diciembre en Panamá y
espera `"Actualizado: 20/12 21:00"`. En tu máquina, en `-05:00`, ese instante es
exactamente eso, y pasa. En el runner, que corre en `UTC` —el valor por defecto de
prácticamente todo servidor de integración—, el mismo instante son las **02:00 del
21**, y la tarjeta dice `Actualizado: 21/12 02:00`. Medido: en `America/Bogota`
pasa 3 de 3 veces; en `UTC` falla 3 de 3.

**Y ahora la pregunta del enunciado: el test tiene razón.**

Es lo que hay que llevarse del incidente. La lectura cómoda es "el test es frágil,
arreglemos el test". La lectura correcta es que el test **descubrió un defecto real
del componente**: su salida depende de estado ambiente —el reloj y la zona horaria
de quien lo ejecuta— que nadie le pasó y que nadie eligió. Ese mismo defecto, en
producción, es el incidente 16 en otra pantalla: dos operadores en zonas distintas
ven cosas distintas sobre el mismo dato.

> 🧠 **Un test no es flaky solo porque falle donde no esperabas.** Descarta esa
> hipótesis con un número: en el runner falla el **100 %** de las veces, y en tu
> máquina el **0 %**. Eso no es aleatoriedad: es un resultado perfectamente
> determinista en dos ambientes distintos. Flaky sería fallar a veces en el
> **mismo** ambiente. Confundir las dos cosas lleva directo a la peor decisión
> posible, que es reintentar el test hasta que pase.

Y el detalle más grave del ticket no es el rojo: es que **dos personas ya lo están
salteando**. Un test que el equipo aprende a ignorar es peor que un test que no
existe, porque sigue contando en la cobertura y ya no protege nada.

**La decisión, que es el entregable**

**Opción A — el hotfix.** Fijar la zona horaria de la suite en el script:

```json
"test": "TZ=America/Bogota react-scripts test"
```

Cuesta cinco minutos, desbloquea el pipeline hoy y **no arregla nada**: el
componente sigue mostrando la hora de la máquina de cada operador. Peor todavía,
fijar una sola zona en las pruebas **esconde la familia entera de errores del
incidente 16**, porque garantiza que ninguna prueba vuelva a ejercitar otra zona.

**Opción B — la refactorización.** Volver a lo que la Fase 9 escribió: la tarjeta
recibe el instante de los datos por props (`updatedAt`) y lo formatea **en hora de
Panamá, explícita** (`timeZone: "America/Panama"`), que es la hora de presentación
del sistema (historia §9). El componente vuelve a ser una función pura de sus
entradas, y el test pasa en cualquier zona sin cambiar una línea.

**La decisión recomendada, y por qué**

Acá B es barata —el componente correcto existe en `fase-10-testing-minimo`, y el
cambio es revertir dos líneas—, así que la respuesta es **B, hoy**. A tiene sentido
cuando B cuesta semanas; en ese caso se aplica con dos condiciones que la separan
de una tapadera:

1. **La suite corre en más de una zona horaria**, no en una fija: una matriz de dos
   o tres valores en el pipeline (`TZ=UTC`, `TZ=America/Bogota`), que convierte el
   hotfix en algo que además protege.
2. **Queda anotado en `A12-mapa-de-deuda-tecnica.md`** con su fecha y su destino, y
   B se agenda. Una deuda que no está escrita no es una deuda: es un olvido con buena
   intención.

Y la parte que casi nunca se hace: **escribirlo**. Que quede dicho qué se eligió,
por qué, qué queda sin resolver y cuándo se paga.

> 🧭 **Y esto es lo que distingue a este incidente de los otros.** Acá no hay un
> `git diff` que sea la respuesta. El entregable es un párrafo, una entrada en el
> mapa de deuda y un acuerdo. En un equipo de mantenimiento real, buena parte del
> trabajo termina así — y casi nunca se practica.

**Prueba de regresión**

La de la Fase 10, sin tocarla, corrida en las dos zonas:

```javascript
// src/features/dashboard/MetricCard.test.jsx (la de la Fase 10)
import React from "react";
import { render, screen } from "@testing-library/react";
import MetricCard from "./MetricCard";

// El 20 de diciembre a las 21:00 en Panamá: en UTC ya es el 21.
const EVENING = Date.parse("2026-12-20T21:00:00-05:00");

describe("MetricCard", () => {
  // El reloj de la máquina se congela en ese instante: si el componente lo consultara,
  // vería el mismo momento que le llega por props. Lo que no se congela es la zona horaria.
  beforeEach(() => {
    jest.useFakeTimers("modern");
    jest.setSystemTime(EVENING);
  });
  afterEach(() => jest.useRealTimers());

  test("muestra título, valor y pista", () => {
    render(<MetricCard title="Giros" value="10000" hint="7566 gratis · 2434 pagos" />);
    expect(screen.getByText("Giros")).toBeInTheDocument();
    expect(screen.getByText("10000")).toBeInTheDocument();
    expect(screen.getByText("7566 gratis · 2434 pagos")).toBeInTheDocument();
  });

  test("muestra el instante de los datos en hora de Panamá, en cualquier máquina", () => {
    render(<MetricCard title="Giros" value="10000" updatedAt={EVENING} />);
    expect(screen.getByText("Actualizado: 20/12 21:00")).toBeInTheDocument();
  });
});
```

```bash
TZ=UTC npm test -- MetricCard            # con B: verde
TZ=America/Bogota npm test -- MetricCard # con B: verde
```

La forma del test **es** la corrección: el reloj congelado en un instante que cae
en días distintos según la zona, y la misma aserción en las dos. Un test de fechas
que corre en una sola zona no prueba nada sobre fechas.

**Prevención**

La matriz de zonas horarias en el pipeline, que es lo único que impide que esto
vuelva. Una regla de revisión: **`new Date()` no se llama dentro de un componente**
—el instante es un dato y llega por props, como en `MetricCard`—. Y una política
sobre los tests rojos: un test que falla se arregla o se borra, con su motivo;
saltearlo no es una tercera opción.

**Por qué llegó a integración**

Porque nadie decidió nunca cuál era la zona horaria de la suite, y el valor por
defecto es "la de quien la corra". Mientras la suite solo corrió en las máquinas del
equipo —todas en `-05:00`, de Bogotá a Panamá— la ambigüedad no tuvo consecuencias.
El día que se creó el pipeline se agregó un ejecutor más, en UTC, y la divergencia
nació ahí: **no la produjo un cambio de código, la produjo un cambio de
participantes.**

**Si tu causa fue distinta a esta**

Si dijiste *"es flaky, hay que reintentarlo"*, mira arriba: 100 % y 0 % no es
aleatoriedad. Si dijiste *"el runner tiene mal la hora"*, no: el runner tiene la hora
perfectamente bien, en UTC, que es la configuración correcta para un servidor. Si
tu fix fue cambiar el texto esperado del test para que coincida con lo que devuelve
el runner, dejaste el pipeline en verde y el componente roto en las dos zonas — y
ahora el test miente en tu máquina. Y si notaste que en el navegador la tarjeta dice
`20/12, 21:00`, con una coma que el test no tiene: es real, el formato depende del
ICU de cada motor (Node 14 contra Chromium), y es otro motivo para que una aserción
de fechas compare lo que importa y no el separador.

**Y acá está el cruce con el track BE.** El incidente `be-15` —*"la suite lleva tres
semanas en verde y ayer se rompió producción"*— es el mismo patrón con otro
sustituto: allá lo que engaña no es el reloj sino **el motor de la base**, con la
suite corriendo contra un motor y producción contra otro. Los dos incidentes enseñan
lo mismo desde orillas opuestas: **una prueba solo vale lo que valga su ambiente.**

</details>

---

## Incidente 21 ➕ — La rueda dice 15 % y el tablero muestra 5 %

> **Fase:** 9 · **Categoría:** Dominio · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 60-75 min
> · Termina en diagnóstico y decisión, no en un commit

### 🎫 El ticket

Itzel abrió el tablero de la Rueda de fin de mes para contestar la reseña, y el
avatar común, que la tabla del juego publica al 15 %, sale en el 5 % de los giros. La
barra está muy por debajo de la banda. El resto de los segmentos se mueven poco, y
la Esclusa de Oro casi bien. En la consola la rueda está configurada con 1.500
puntos básicos para el avatar común. Nadie tocó los pesos. ¿Está arreglada o no?

**Reportado por:** Itzel, operación
**Ambiente:** el tablero de la Fase 9, con una bitácora vieja

### 🎯 Qué se te pide

Diagnosticar, con lo que el repo trae, **por qué la rueda no da lo que publica**, y
escribir la decisión que le propondrías al estudio. Este incidente **no termina en
un commit** de la consola: la causa no está en la consola, y la decisión no es tuya
sola.

### 🔧 Preparación

- **Sin rama:** el incidente se prepara con un dato, no con código.
- **Sale de:** `fase-09-dashboard`.
- **Datos:** la Rueda de fin de mes con la bitácora de la regla vieja, la de 2021:

```bash
git checkout fase-09-dashboard
node mock/seed-reconciliation.js --accommodating    # con los mocks parados
npm run mock:all
npm start
# /dashboard → Rueda de fin de mes. Al terminar: git checkout -- mock/db.json mock/googlePlay/earnings.json
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes de sospechar del aleatorio, mira **a quién** le sale cada segmento, no
cuántas veces. La bitácora tiene el jugador de cada giro. Si un segmento sale poco,
pregúntate a qué jugadores **no** les sale.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`00-historia-del-sistema.md` §5, *la rueda que se acomoda*. ¿Qué haría esa regla con
el avatar más común de la rueda, en una comunidad donde muchos veteranos ya lo
tienen?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Cuenta, para el avatar común, cuántos jugadores lo sacaron **dos o más veces**. ¿Qué
número esperarías con una rueda honesta de 10.000 giros y 800 jugadores? ¿Y qué
número daría una regla que promete *"nunca te repite"*?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Evidencia observable**
{{Los conteos del tablero, el χ², y el conteo por jugador.}}

```text
{{segmento · esperado · observado     ·     jugadores que lo sacaron dos veces}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Dónde vive la regla que contradice la tabla.}}

**Tu decisión**
{{Qué le propones al estudio, con sus costos, y quién decide.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Lo que muestra el tablero**

Con la bitácora de la regla vieja, el tablero de la Fase 9 marca "Con alarma",
χ² = 808,35, y los conteos de 10.000 giros contra lo publicado:

| Segmento | Esperado | Observado |
|---|---|---|
| sin-premio | 3.000 | 3.404 |
| vidas-2 | 2.000 | 2.179 |
| avatar-comun | 1.500 | **505** |
| set-gemas-basico | 1.500 | 1.704 |
| vidas-5 | 1.000 | 1.161 |
| set-gemas-plata | 800 | 877 |
| avatar-raro | 150 | 106 |
| esclusa-de-oro | 50 | 64 |

No es un desvío de azar: la banda del avatar común con 10.000 giros va de 1.393 a
1.607 (A14 §2), y 505 está a casi veintiocho desviaciones por debajo.

**La evidencia que separa las hipótesis: a quién le sale**

El aleatorio roto daría un segmento raro en general; el patrón es otro. Con un
script de diez líneas sobre la bitácora del `db.json`:

```javascript
// scripts/repeated-landings.js — ¿a cuántos jugadores les salió dos veces el mismo segmento?
// Lee la bitácora del db.json del mock. Uso: node scripts/repeated-landings.js 4 avatar-comun
const db = require("../mock/db.json");

const wheelId = Number(process.argv[2]);
const segmentId = process.argv[3];
const perPlayer = new Map();
for (const row of db.spinLog) {
  if (row.wheelId === wheelId && row.landedSegment === segmentId) {
    perPlayer.set(row.playerId, (perPlayer.get(row.playerId) || 0) + 1);
  }
}
const landings = [...perPlayer.values()].reduce((sum, n) => sum + n, 0);
const repeated = [...perPlayer.values()].filter((n) => n >= 2).length;
console.log(`${segmentId}: ${landings} veces, en ${perPlayer.size} jugadores; ${repeated} jugadores lo sacaron dos o más veces`);
```

```bash
node scripts/repeated-landings.js 4 avatar-comun
```

```text
avatar-comun: 505 veces, en 505 jugadores; 0 jugadores lo sacaron dos o más veces
```

**Quinientas cinco veces, a quinientos cinco jugadores distintos, y ninguno dos
veces.** Con la bitácora de la regla nueva, el mismo script da `1515 veces, en 695
jugadores; 448 jugadores lo sacaron dos o más veces` —a esos se les entregó el
sustituto—. La regla vieja cumple su promesa, *"¡ahora la rueda nunca te repite!"*,
y la cumple sacando el avatar de la rueda antes de girar para quien ya lo tiene.
Con el 30 % de los jugadores veteranos que ya traían los dos avatares más comunes,
el avatar común casi desaparece de la rueda, y el raro también baja (106 contra
150). El peso que dejan se reparte entre los demás: por eso los segmentos que no
son avatares salen **de más**, y la Esclusa de Oro también (64 contra 50).

**Causa raíz**

La regla de la rueda que se acomoda (historia §5). No está en la consola: vive en el
API de 2021, que decide en cada giro con unos pesos que la consola no ve. Los pesos
configurados son verdad; la tabla del juego, no.

**Por qué no termina en un commit**

Porque no hay una línea de la consola que arreglar, y porque la decisión cambia la
promesa que el estudio les hizo a los jugadores. Las salidas, con su costo:

1. **La protección con sustituto** (la que el equipo de Juliana propone, historia
   §5): la rueda gira con los pesos publicados, y si cae en algo repetido se entrega
   el sustituto publicado. La tabla vuelve a decir la verdad y la promesa se
   mantiene. Es trabajo del API (track BE), y la bitácora nueva guarda las dos cosas.
2. **Publicar la tabla que de verdad corre.** Imposible: depende de cada jugador.
3. **Quitar la regla y la promesa.** Lo más barato y lo que más duele en la
   comunidad.

**La decisión recomendada** es la 1, y la escribe quien la va a firmar: Itzel (el
producto), Juliana (el API) y Abdiel (el estudio). El entregable del incidente es
ese documento: qué se observó, qué regla lo produce, qué se propone, cuánto cuesta,
cómo se va a verificar que quedó bien.

**Cómo se verifica, después**

Con lo que el curso ya construyó: la conciliación de la Fase 8 sobre la bitácora
nueva no tiene que dar alarma, y la prueba de la Fase 10 (`oddsAudit.test.js`) fija
las dos caras —la regla nueva dentro de la tolerancia, la vieja afuera—. Ese es el
criterio de aceptación de la decisión.

**Si tu causa fue distinta a esta**

Si dijiste *"el aleatorio está roto"*, la evidencia por jugador lo descarta: un
aleatorio roto no sabe quién tiene qué avatar. Si dijiste *"alguien cambió los
pesos"*, la consola dice 1.500 y la bitácora vieja no guarda la versión de los pesos
(A12): la hipótesis se descarta en el API, no en la consola. Y si dijiste *"es una
falsa alarma, una de cada dieciocho"*, A14 §5 te da el número: 5 % de falsas
alarmas es para desvíos de dos o tres σ, no de treinta.

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
