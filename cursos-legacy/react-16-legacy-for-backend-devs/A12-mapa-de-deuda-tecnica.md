# 💸 Apéndice A12 — Mapa de deuda técnica
## Tutorial React 16 — La Esclusa, la consola de Jewel Locks

> **Registro vivo** · **~1,5 horas** la primera lectura · Lo produce la Fase 11 · Lo citan las Fases 1, 2, 4, 5, 6, 7, 8,
> 9 y 11 · Lo alimentan todas · Se consulta antes de cada cambio.

Este archivo es el **inventario de decisiones deliberadas** de la Esclusa. No lista bugs: ninguna de estas líneas está
rota. Lista sitios donde alguien eligió conscientemente no hacer lo "correcto" todavía, porque el costo superaba al
beneficio en ese momento.

Es el artefacto más directamente transferible del curso. En un equipo real, este archivo es lo que convierte "el código
está lleno de cosas raras" en un backlog priorizable, y lo que le permite a quien entra mañana responder la pregunta que
decide todo: **¿esto está así a propósito o por error?**

Y en esta consola tiene una pregunta más, que la historia le impone: la Esclusa tiene **dos años de horizonte** (§3 de
la historia). En 2028 se decomisiona —sus funciones pasan al editor de Unity— o se migra a la versión actual de todo.
Una deuda que muere con el decomiso no se paga igual que una que sobrevive a cualquiera de los dos caminos.

---

## 1. Cómo se lee este mapa

Cada entrada tiene cinco partes, y **las dos últimas son las que importan**:

- **Qué se hizo en su lugar** — la solución que está en el código hoy.
- **Por qué se dejó** — el razonamiento de quien decidió. Sin esto, la entrada es inútil: dentro de un año nadie
  recordará si fue criterio o pereza.
- **Fase** — dónde está documentada en detalle.
- **Qué la vuelve exigible** — el **disparador**: la condición concreta que convierte esta deuda en un bug con fecha.
- **En el horizonte** — qué le pasa en 2028, con una de tres marcas:
  - 🔴 **Se paga antes del corte.** Duele dentro de los dos años, decida lo que decida el estudio: seguridad, dinero, el
    próximo evento. No espera.
  - ⚪ **Muere con el decomiso.** Solo importa si la consola sigue viva. Si se apaga, pagarla es trabajo tirado.
  - 🟢 **Se paga al migrar.** La migración la paga de paso, porque reescribe esa parte; pagarla antes es pagarla dos
    veces.

El trabajo del equipo no es pagar todo. Es **vigilar los disparadores**, y saber cuáles no hay que pagar nunca.

> 🧭 **La distinción operativa que gobierna todo el archivo.** La deuda deliberada tiene un motivo documentado y, con
> frecuencia, una prueba que fija el comportamiento actual como *esperado* —`formatCents`, que **lanza** con un float, y
> la Fase 10 lo prueba como correcto—. "Arreglarla" rompería algo que dependía de eso. El descuido no tiene motivo ni
> prueba, y ahí sí se corrige sin preguntar. Confundir las dos es la forma más común de que un hotfix bienintencionado
> genere el próximo incidente.

---

## 2. El inventario

### 2.1 En la consola

#### 💸 `window.confirm` para borrar una rueda

**Fase 4.** La confirmación nativa del navegador en vez de un modal de Bootstrap. Se dejó porque un modal es interfaz
pura: no cambia una línea de lógica, y diferirlo costaba cero. Es feo y bloquea el hilo, pero es honesto sobre lo que
hace. La Fase 11 lo conservó a propósito al migrar `WheelTable` a hooks: migrar no paga deuda de interfaz.

**Se vuelve exigible** cuando borrar una rueda deje de ser reversible desde el backend, o cuando el smoke de Cypress
tenga que cubrir el borrado (`cy` no interactúa con un `confirm` nativo sin simularlo).

**En el horizonte:** ⚪ muere con el decomiso; 🟢 si se migra, un modal es una línea del rediseño.

#### 💸 Validación mínima del formulario de ruedas

**Fase 4.** `required` de HTML y la regla de los pesos (que sumen 10.000). No se valida el formato de la fecha de cierre
ni que el nombre no sea solo espacios. Se dejó porque la regla que importa —los pesos— sí está, en la consola y en el
mock.

**Se vuelve exigible** el día que una rueda mal cargada llegue a `live`.

**En el horizonte:** ⚪ muere con el decomiso.

#### 💸 El estado de una rueda se elige libre en el formulario

**Fase 4.** Cualquier rueda pasa a cualquier estado desde el formulario; la consola no hace cumplir
`draft → scheduled → live → ended → reconciled`, salvo la última transición (Fase 8). Se dejó porque las transiciones
con reglas son del servidor (track BE).

**Se vuelve exigible** cuando alguien pase una rueda de `ended` a `live` sin querer y la Fase 7 vuelva a ofrecer giros
de ella.

**En el horizonte:** 🔴 antes del corte, del lado del servidor (track BE): es una regla de negocio, no de interfaz.

#### 💸 El detalle de una rueda lee un arreglo de demo

**Fases 1 a 4.** `WheelDetailPage` busca la rueda con `findWheel` en `src/mock/wheels.js`, no en el API. La Fase 4 migró
el listado y dejó el detalle, a propósito: migrar de a un consumidor por vez.

**Se vuelve exigible** el día que un operador necesite ver el detalle de una rueda creada desde la consola (hoy dice que
no existe).

**En el horizonte:** ⚪ muere con el decomiso; 🟢 si se migra, es lo primero que se reescribe.

#### 💸 La pantalla *Jugadores* sigue con `demoPlayers`

**Fases 1 a 5.** El asistente de envíos ya lee los jugadores del API (Fase 5); la pantalla de jugadores, no.

**Se vuelve exigible** cuando soporte use esa pantalla para buscar a alguien y confíe en lo que ve.

**En el horizonte:** ⚪ muere con el decomiso.

#### 💸 Sin roles ni permisos

**Fase 2.** Cualquiera con usuario puede enviar giros y conciliar ruedas (historia §11). Se dejó porque la consola la
usan unas diez personas, todas de confianza, y los roles son un cambio de modelo, no de pantalla.

**Se vuelve exigible** el día que entre a la consola alguien que no deba poder compensar, o que una auditoría pregunte
quién concilió.

**En el horizonte:** 🔴 antes del corte si entra gente nueva; del lado del servidor.

#### 💸 La contraseña en claro, el token como constante, y la sesión en `localStorage` sin expiración

**Fases 2 y 3.** json-server compara strings; el token es una etiqueta fija; la sesión persiste en `localStorage` sin
fecha de vencimiento. Se dejó porque el foco del track base es el flujo de autenticación en el frontend, no un servidor de
identidad. **Esta no es una deuda cualquiera: es un hallazgo de seguridad**, que está acá porque el curso lo declara como
simplificación consciente, no porque sea aceptable en producción.

**Se vuelve exigible** ya. El track BE la paga en `be04`, con un JWT firmado y su expiración.

**En el horizonte:** 🔴 antes del corte, sin discusión.

#### 💸 La cola de envíos no sobrevive a un F5

**Fase 5.** Un envío en su ventana de deshacer vive en el store; si el operador recarga, se pierde, no sale nunca y nadie
se entera.

**Se vuelve exigible** el día que un operador pierda un envío en un evento, que es exactamente cuando más recarga.

**En el horizonte:** 🔴 antes del próximo evento si la consola sigue operando eventos; ⚪ si no.

#### 💸 El registro manual de epics

**Fase 6.** Cada epic se importa a mano en `rootEpic.js`. Con seis epics, el explícito se lee mejor que un registro
automático.

**Se vuelve exigible** cuando haya decenas, o cuando alguien escriba un epic y se olvide de registrarlo.

**En el horizonte:** ⚪ muere con el decomiso.

#### 💸 `sendGrantEpic` y `retryGrantEpic` comparten el cuerpo

**Fase 6, y A7.** El optimista, la petición y el rollback están escritos dos veces. Se dejó para que los dos flujos se
lean completos lado a lado; la extracción (`grantRequest$`) es el ejercicio 27 de la Fase 6.

**Se vuelve exigible** el día que alguien arregle un bug en uno y se olvide del otro, o que haga falta un tercer epic
con el mismo ciclo.

**En el horizonte:** ⚪ muere con el decomiso; 🟢 si se migra.

#### 💸 `groupBy` sin `durationSelector`

**Fase 6.** El doble clic se resuelve con un grupo por envío, y los grupos no se cierran mientras la consola esté
abierta.

**Se vuelve exigible** si una sesión de soporte llega a miles de envíos sin recargar.

**En el horizonte:** ⚪ muere con el decomiso.

#### 💸 El reloj del navegador decide el cierre

**Fase 7.** `isWheelClosed` compara bien los instantes, pero contra `Date.now()` de la máquina del operador. Un operador
con la hora corrida decide mal el cierre. Se dejó porque la autoridad del tiempo es del servidor, y la consola no tiene
servidor propio.

**Se vuelve exigible** con el primer giro mandado después del cierre por una máquina con la hora mal. Tiene consecuencia
económica directa, y es el incidente `be-12`.

**En el horizonte:** 🔴 antes del corte, en `be06`.

#### 💸 Un código de compra equivocado polea para siempre

**Fase 7.** El servicio responde `404` en cada tick, el `catchError` lo vuelve un `pollingFailed` y el `timer` sigue.

**Se vuelve exigible** cuando soporte pegue un código mal y deje la pestaña abierta (el ejercicio 21 de la Fase 7).

**En el horizonte:** ⚪ muere con el decomiso.

#### 💸 Las compras que soporte sigue viven en el store, y el intervalo es fijo

**Fase 7.** Un F5 pierde el seguimiento, y el polling pregunta cada dos segundos aunque la compra tarde horas.

**Se vuelve exigible** cuando el proveedor cuente consultas, como en el incidente 14.

**En el horizonte:** ⚪ muere con el decomiso.

#### 💸 La consola baja la bitácora entera para contar

**Fases 8 y 9.** La conciliación y el tablero piden todos los giros de una rueda y cuentan en el navegador. Con una
rueda de semanas alcanza; con la Semana del Canal son 180.000 filas. La Fase 9 las guarda fuera de los chequeos de
desarrollo (`ignoredPaths`), y la Fase 11 deja escrito por qué eso es la corrección mínima y no la refactorización.

**Se vuelve exigible** cuando el tablero tarde más de un segundo en cargar una rueda, o cuando la consola tenga que
mostrar varias ruedas a la vez.

**En el horizonte:** 🟢 se paga al migrar, o en `be07` con la consulta agregada; ⚪ muere con el decomiso.

#### 💸 La bitácora no guarda la versión de los pesos ni los segmentos elegibles

**Fase 8.** La historia §9 pide las dos cosas; la bitácora del laboratorio no las tiene, porque con una sola versión de
pesos por rueda no hacen falta para auditar.

**Se vuelve exigible** el día que una rueda publique una versión nueva de pesos a mitad de un evento: conciliar las dos
versiones juntas da una alarma falsa (ejercicio 25 de la Fase 8).

**En el horizonte:** 🔴 antes del corte, en el API (`be07`): es la bitácora de auditoría, y sobrevive a la consola.

#### 💸 El reporte de la tienda se lee completo, y un gráfico hecho a medida

**Fases 8 y 9.** La conciliación lee todo el reporte de ganancias sin filtrar por mes; `BandChart` es un wrapper de
chart.js para un solo gráfico.

**Se vuelve exigible** con el segundo mes de reporte, o con el tercer tipo de gráfico.

**En el horizonte:** ⚪ muere con el decomiso.

#### 💸 El smoke necesita levantar los servicios a mano

**Fase 10.** El smoke de Cypress corre contra los mocks reales, pero hay que levantar los dos mocks y el servidor de
desarrollo antes. No hay un script que los orqueste.

**Se vuelve exigible** cuando el smoke tenga que correr en integración continua.

**En el horizonte:** 🟢 se paga al migrar, porque la migración necesita esa red corriendo sola.

### 2.2 En el API heredado (la parte que la consola no ve)

Estas no están en el código de la consola, y por eso son las más peligrosas: la consola las muestra sin saber que
existen (historia §5). El track BE las paga.

#### 💸 La rueda que se acomoda

**API de 2021, historia §5.** Al girar, el API saca los premios que el jugador ya tiene y reparte su peso entre los demás.
La tabla del juego dice una cosa y la rueda hace otra. La salida que propone el equipo es la protección de duplicados con
sustituto. La Fase 8 la detecta (χ² = 808 con la regla vieja) y el incidente 21 la muestra en el tablero.

**Se vuelve exigible** ya: es la reseña de *"la rueda está arreglada"*, y la tienda exige que las probabilidades
publicadas sean verdad.

**En el horizonte:** 🔴 antes del corte. Sobrevive a la consola: es del juego.

#### 💸 La consola no conoce la regla

**Historia §5.** La consola muestra los pesos tal como se configuraron, y nadie que la mire puede saber que en producción
la rueda corre con otros. La Fase 8 y la 9 lo pagan a medias: la conciliación y el tablero muestran lo que pasó, no solo
lo configurado.

**Se vuelve exigible** cada vez que alguien conteste una reseña mirando solo la configuración.

**En el horizonte:** 🔴 la parte del API; ⚪ la de la consola.

#### 💸 La bitácora vieja guardaba solo el premio entregado

**API de 2021.** Con eso no hay forma de reconstruir en qué segmento cayó la rueda ni qué probabilidad tenía cada giro.
La Fase 8 muestra por qué hacen falta las dos columnas: auditar el premio entregado acusa a una rueda honesta.

**Se vuelve exigible** con la primera auditoría externa de las probabilidades.

**En el horizonte:** 🔴 antes del corte, en el API.

#### 💸 El giro sin transacción

**API de 2019, Fase 3.** El giro lee el stock, decide y escribe en tres viajes, sin transacción, y la clave de
idempotencia se anota pero nadie la hace cumplir. Es lo que entregó 1.047 Esclusas de Oro de un stock de 1.000.

**Se vuelve exigible** con el próximo evento. Lo paga `be05`.

**En el horizonte:** 🔴 antes del corte, sin discusión.

#### 💸 El chequeo del caso de compensación no es atómico

**Fase 5, incidente 11.** El mock —y el API— comprueban si el caso ya fue compensado y recién después anotan; dos pedidos
simultáneos pasan los dos. La consola cierra el doble clic en el origen (Fase 6), pero la garantía tiene que ser del
servidor.

**Se vuelve exigible** con el primer jugador compensado dos veces por dos operadores distintos.

**En el horizonte:** 🔴 antes del corte, con una restricción en la base (track BE).

---

## 3. Las que ya se pagaron ✅

No se borran: se marcan con qué las disparó y cómo se pagaron. El registro de deudas pagadas es lo que enseña cómo se
paga una, y evita que alguien la reintroduzca sin saber que ya se discutió.

- ✅ **La rueda escrita a mano en el componente** (Fase 0) → el listado lee el API desde la Fase 4. Quedan el detalle y
  la pantalla de jugadores (§2.1).
- ✅ **La sesión que no sobrevivía al F5** (Fase 2) → pagada en la Fase 3, con la persistencia en `localStorage` (que
  dejó su propia deuda de seguridad, §2.1).
- ✅ **Los temporizadores de la ventana de deshacer en un `Map` de módulo** (Fase 5) → pagados en la Fase 6 con
  `undoWindowEpic`, que se limpia solo con `takeUntil`.
- ✅ **El refresco de compras con leak** (Fase 6, a propósito) → pagado en la Fase 7 con `pollingEpic` y sus dos salidas.
- ✅ **Las versiones de `rxjs-marbles` y `cypress` sin fijar** → fijadas en la Fase 10 con `--save-exact` (6.0.1 y
  10.11.0), como pide D9.
- ✅ **El smoke que simulaba la red** → la Fase 10 lo corre contra los mocks reales, con su interceptor y su
  `Authorization`.

---

## 4. El horizonte, en números

Contar las entradas por su marca es la mitad del veredicto de la Fase 11 (§9):

| En el horizonte | Entradas | Qué quiere decir |
|---|---|---|
| 🔴 Se paga antes del corte | 11 (6 de la consola o su servidor, 5 del API) | trabajo que hay que hacer en cualquiera de los dos caminos |
| ⚪ Muere con el decomiso | 13 | trabajo que no se hace si la consola se apaga |
| 🟢 Se paga al migrar | 5 | trabajo que la migración hace de paso |

(Son 23 entradas, y algunas llevan dos marcas, una por camino: por eso la suma no da 23.)

Lo que dice la tabla, sin decidir nada: **casi todo lo urgente vive del lado del servidor y del API**, y sobrevive a
cualquier decisión sobre la consola. Lo que muere con el decomiso es, en su mayoría, comodidad de la consola. Es un dato
para la reunión de Abdiel, Itzel y Juliana, no una conclusión.

> 🧠 **"Esto no lo vamos a hacer, y estas son las condiciones bajo las que lo reconsideraríamos" es una decisión de
> ingeniería.** "Esto lo hacemos más adelante" repetido durante dos años es la forma en que un backlog técnico se vuelve
> invisible hasta que explota. La marca ⚪ es la forma honesta de decir lo primero.

---

## 5. Cómo se mantiene este archivo

**Cuando declares una deuda nueva** (una 💸 en cualquier fase o incidente), agrégala acá con sus cinco partes. Una 💸
que solo existe en un comentario del código es una 💸 que nadie va a encontrar.

**Cuando pagues una**, no la borres: muévela a §3 con qué la disparó y cómo se pagó.

**Cuando un disparador ocurra**, la entrada deja de ser deuda y pasa a ser un ticket. Ese es el único momento en que este
archivo genera trabajo, y es exactamente cuando debe generarlo.

**Cuando el estudio decida el horizonte**, las marcas ⚪ o 🟢 de la opción que no se tomó se tachan, y la tabla de §4
se rehace. Ese día este archivo pasa a ser el plan de trabajo de los dos años.

**Revísalo antes de cada cambio grande.** Son cinco minutos y responden por adelantado la pregunta que más tiempo hace
perder en mantenimiento: *¿esto está así a propósito?*

---

## 🧪 Ejercicios (6)

1. **🟢** Recorre las once fases buscando cada 💸 en el texto. Compara tu lista con el inventario de §2. **Criterio:**
   toda 💸 que encuentres y no esté acá es un hallazgo; agrégala con sus cinco partes.
2. **🟢** Para cada entrada de §2, escribe en una línea **cómo detectarías** que su disparador ocurrió. **Criterio:** si
   para alguna no se te ocurre nada observable, el disparador está mal formulado: reescríbelo.
3. **🟡** Ordena las 🔴 por riesgo real —probabilidad de que el disparador ocurra por costo si ocurre— y defiende tu
   orden en un párrafo. Lo que se evalúa es el criterio.
4. **🟠** Toma la deuda del reloj del navegador y escribe el ticket que abrirías el día que se dispare: síntoma
   esperado, cómo reproducirlo, qué capa tocar, qué prueba escribir primero y el estimado.
5. **🟠** Elige una entrada y escribe **la prueba que fija el comportamiento actual como esperado** (como la de
   `formatCents`). **Criterio:** la prueba falla si alguien "arregla" la deuda por accidente en un refactor.
6. **🔴** Para la deuda de la sesión en `localStorage`, escribe el análisis que le presentarías a alguien de
   seguridad: qué expone, qué ataque habilita, qué mitigaciones existen del lado de la consola y cuáles **no** pueden
   resolverse sin el servidor. Distingue lo que es decisión de producto de lo que es limitación técnica.

---

## 📚 Referencias

**Del curso**
- Fase 11 §5.3 — el caso trabajado de corrección mínima contra refactorización, sobre el incidente 19.
- Fase 11 §9 — el veredicto de los dos años, que usa la tabla de §4.
- `00-historia-del-sistema.md` §5 y §11 — por qué cada cosa quedó como quedó, y lo que el sistema no tiene.
- `00-decisiones-y-versiones.md` — las decisiones que **no** son deuda sino restricciones del proyecto. Una restricción
  no se paga: se respeta.

**Lectura de fondo**
- Ward Cunningham, *"The WyCash Portfolio Management System"* (OOPSLA 1992), donde aparece la metáfora de la deuda: la
  que se asume a conciencia para entregar antes, sabiendo que se pagan intereses.
- Martin Fowler, *Technical Debt Quadrant* — https://martinfowler.com/bliki/TechnicalDebtQuadrant.html — el cruce de
  deliberado/inadvertido con prudente/temerario. Este archivo inventaría el cuadrante deliberado y prudente; los otros
  tres no se declaran, se descubren.

> ⚠️ Verifica autor, fecha y formulación exacta antes de citarlas en una discusión de equipo.

---

> **La señal de que este archivo hace su trabajo:** cuando alguien nuevo abra el proyecto, encuentre una línea rara,
> venga acá, la encuentre explicada —y sepa, además, si vale la pena tocarla antes de 2028.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es material de consulta: si no cambia el repo, no hay nada que apuntar.
> Cuando de leerlo sí salga código —una deuda pagada o una nueva declarada—, commitéalo con el prefijo de la fase desde
> la que llegaste (`f06: …`), no con el del apéndice, para que el `git log --oneline --grep '^f06'` de esa fase siga
> completo. Y si el ejercicio produjo una medición, el número va en el mensaje del tag (`ej/a12/3`), que es donde no se
> pierde. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
