# 🏁 Fase 11 — Cierre + puente a React moderno

> Tutorial React 16 — La Esclusa, la consola de Jewel Locks · Fase 11 de 11 · **6 horas** · **ÚLTIMA FASE**
> Depende de: Fase 10 — Testing mínimo · Habilita: nada (es el cierre del curso)

---

## 🎯 1. Propósito

Abdiel hace la pregunta que el estudio se viene guardando desde que contrató al equipo de Colombia: *"¿apagamos la Esclusa en 2028 o la migramos?"* (`00-historia-del-sistema.md` §3, el horizonte). Hay dos caminos y ninguno es gratis: **decomisionarla** —que sus funciones pasen a herramientas dentro del editor de Unity, que es lo que el equipo de Jewel Locks sí sabe mantener— o **migrarla** a las versiones actuales de todo. La historia dice cuándo se toma esa decisión: no hoy, sino con lo que el equipo aprenda en estos dos años. Esta fase no la toma por el estudio. Te deja los criterios para tomarla con números.

Llegaste al final de 98 horas. No para aprender React —eso lo sabías al empezar—, sino para volverte alguien que puede **entrar a un sistema legacy ajeno, entenderlo, tocarlo sin romperlo y dejar registro de lo que hizo**. Esta fase cierra mirando en dos direcciones.

Hacia atrás: qué construiste, qué deuda técnica quedó **a propósito** y por qué dejarla fue una decisión de ingeniería, no un descuido. Un mantenedor que no distingue deuda deliberada de negligencia es peligroso: paga la primera creyendo que arregla la segunda, y rompe cosas que funcionaban.

Hacia adelante: un puente al React moderno —hooks en todos lados, RxJS 7, React 17 y 18—, cruzado **con la red de pruebas de la Fase 10 puesta**, y **corrido**, no imaginado: los ejemplos de esta fase se ejecutaron en copias descartables del proyecto con cada versión. La tesis cabe en una línea: **no se moderniza lo que no está probado**.

---

## ✅ 2. Qué queda listo al terminar

- [ ] El **mapa de la deuda técnica 💸** de las once fases, consolidado en `A12-mapa-de-deuda-tecnica.md`, con cada deuda marcada por lo que le pasa en el horizonte: *se paga antes del corte*, *muere con el decomiso* o *se paga al migrar*.
- [ ] El tag **`pre-modernizacion`**: el estado de la consola antes de modernizar, con la suite de la Fase 10 en verde.
- [ ] `WheelTable` **de clase a hooks**, con la prueba de la Fase 10 como oráculo: verde antes, verde después, y el archivo de la prueba sin una línea cambiada.
- [ ] Un caso trabajado de **corrección mínima contra refactorización** sobre un bug real del curso, el incidente 19, con su prueba de regresión.
- [ ] El **puente a RxJS 7**, medido: las pruebas de canicas de la Fase 10 corren sin cambios con RxJS 7.8.1 y rxjs-marbles 7.0.1.
- [ ] El **puente a React 17 y 18**, medido: el JSX nuevo, el batching automático, el doble efecto de StrictMode.
- [ ] El **veredicto de los dos años** (§9): los criterios medibles para decomisionar o migrar, y quién decide.

---

## 🚫 3. Qué queda fuera por ahora

- **Migrar de verdad a React 17 o 18, o a RxJS 7.** El código principal sigue en React 16.14.0 (D1) y RxJS 6.6.7 (D2) hasta la última línea del curso. Las otras versiones viven en copias descartables.
- **Adoptar RTK Query.** D4 la deja solo mencionada (A8 §6).
- **React Router 5 → 6.** Se menciona la diferencia de API como orientación (A8). No se migra.
- **Pagar la deuda.** El mapa **inventaría y clasifica**; no salda. Pagar deuda sin su disparador es modernización idealizada, justo lo que el curso evita.
- **Decidir por el estudio.** El veredicto da criterios y números; la decisión es de Abdiel, de Itzel y de Juliana.
- **Depurar el build de producción** → `A13-depurar-el-build-de-produccion.md`.

---

## 🧠 4. Conceptos mínimos

### La deuda técnica deliberada no es lo mismo que el descuido

A lo largo del curso marcaste deuda con 💸: el `window.confirm` en vez de un modal, la consola que baja la bitácora entera para contar, el reloj del navegador decidiendo el cierre, el detalle de una rueda que lee un arreglo de demo. Ninguna de esas cosas es un bug. Son decisiones donde alguien eligió conscientemente **no** hacer lo "correcto" todavía, porque costaba más de lo que daba.

La distinción es operativa. Frente a una línea rara, el mantenedor tiene que responder antes de tocar nada: *¿esto está así a propósito o por error?* Si es deuda deliberada, tiene un motivo escrito y a veces una prueba que fija el comportamiento actual como esperado —`formatCents`, que **lanza** con un float, y la Fase 10 lo prueba como correcto—. "Arreglarlo" rompería algo que dependía de eso. Si es descuido, no hay motivo ni prueba, y ahí sí se corrige.

### Corrección mínima contra refactorización: son dos trabajos distintos

Ante un bug hay dos respuestas legítimas y **no intercambiables**. La **corrección mínima** cambia lo menos posible para que el síntoma desaparezca: una o dos líneas, riesgo bajo, a veces hasta agrega deuda a propósito. Es lo que va a producción con el incidente abierto. La **refactorización** cambia la estructura para que esa clase de bug no vuelva a ser posible: toca más, necesita más pruebas, tiene más riesgo. Es lo que va al backlog, con la red puesta. El error no es elegir una; es **no distinguirlas**. La respuesta profesional casi siempre es *las dos, en orden*: §5.3 lo muestra.

### Modernizar es una migración con oráculo, no una reescritura con fe

Cuando te toque llevar un módulo de clase a hooks, o de RxJS 6 a 7, la pregunta que decide si el cambio es seguro no es "¿quedó más lindo?" sino "¿se comporta igual que antes?". Esa pregunta solo tiene respuesta confiable si existe algo que la responda por ti: una prueba que verifica **comportamiento, no implementación**. Las de la Fase 10 preguntan a la pantalla, invocan el reducer como función, verifican la forma del stream con canicas: ninguna sabe si adentro hay una clase o un hook, ni qué versión de RxJS. Por eso sobreviven a la migración y sirven de **oráculo**: pasan contra la versión vieja, migras, pasan contra la nueva.

### El horizonte: decomisionar o migrar

Las dos salidas de la historia no son "lo viejo" contra "lo nuevo". **Decomisionar** es reconocer que la Esclusa resolvió un problema que se puede resolver de otra forma —herramientas dentro del editor de Unity—, y que cada mes que vive es mantenimiento de una tecnología que el estudio no domina. **Migrar** es apostar a que la consola vale lo suficiente como para traerla a la versión actual de todo. Ninguna de las dos se decide por gusto: se decide con lo que se puede medir en dos años, que es justamente lo que este curso aprendió a medir. El veredicto de §9 lo ordena.

---

## 💻 5. Implementación y código comentado

Esta fase produce menos código nuevo que ninguna otra, y es correcto. Produce: un tag, una migración con oráculo, un caso trabajado de hotfix contra refactor, y un puente medido a las versiones nuevas.

### 5.1 El mapa de la deuda técnica 💸 → **A12**

Durante once fases fuiste marcando deuda con 💸. Dispersa, cada marca parece una anotación menor. Junta, es el **backlog técnico real** del sistema. El inventario completo —cada deuda con qué se hizo en su lugar, por qué se dejó, qué la vuelve exigible y **qué le pasa en el horizonte**— vive en **`A12-mapa-de-deuda-tecnica.md`**. Ábrelo ahora y vuelve.

> 🧭 **La columna que importa no es "qué se dejó" sino "qué la vuelve exigible".** Mientras el disparador no ocurra, pagar la deuda es riesgo sin retorno. El día que ocurre, la deuda deja de ser deuda y pasa a ser un bug con fecha. Y el horizonte agrega una pregunta que la cambia todo: una deuda que muere con el decomiso **no se paga**, aunque su disparador esté cerca, si el corte llega antes.

### 5.2 `WheelTable` de clase a hooks, con la red puesta

La Fase 4 escribió `WheelTable` como clase con `connect()`, a propósito, al estilo de los módulos de 2019 (la versión está en la Fase 4). Es el ejemplo canónico de **migración segura**: la Fase 10 tiene una prueba de la tabla que no sabe si adentro hay una clase o una función. Esa prueba es el oráculo, y el procedimiento tiene un orden que no se negocia:

1. **El tag.** Antes de tocar nada, se marca el estado de partida:

   ```bash
   git tag -a pre-modernizacion -m "El estado antes de modernizar: la suite de la Fase 10 en verde es el oráculo de la Fase 11"
   ```

2. **La línea base.** Se corre la prueba existente contra la clase. **Verde** (4 de 4). Esto establece "así se comporta hoy".
3. **La migración.**
4. **La misma prueba, sin tocarla**, contra la función. Si sigue verde, el comportamiento se preservó.

La versión migrada:

<<<archivo:esclusa-app/src/features/wheels/WheelTable.jsx>>>

Resultado de la corrida del 18/10/2026: el diff toca **un solo archivo** (71 líneas agregadas, 85 quitadas), `git diff pre-modernizacion -- src/features/wheels/WheelTable.test.jsx` no muestra nada, y la suite entera da **25 de 25** antes y después. El build compila sin advertencias.

**El mapa de equivalencias**, que coincide con A5:

| Clase + `connect()` | Función + hooks | Nota |
|---|---|---|
| `mapStateToProps` | un `useSelector` por porción | cada `useSelector` es una suscripción independiente |
| `mapDispatchToProps` | `const dispatch = useDispatch()` + `dispatch(action())` | el envoltorio automático de `connect()` ahora es explícito |
| `componentDidMount` | `useEffect(() => {...}, [dispatch])` | `dispatch` es estable: corre una vez |
| `componentWillUnmount` | el `return` del `useEffect` | (no aplica: `WheelTable` no limpia nada) |
| `this.props.x` | la variable `x` | ya no hay `this` |
| `connect(...)(Componente)` | el componente se exporta pelado | la conexión al store la hacen los hooks |

> **La diferencia entre corrección mínima y refactorización, aplicada acá.** Esta migración **no es un fix**: la `WheelTable` de clase no tiene ningún bug. Es una refactorización pura, motivada por consistencia, no por un incidente. Si la tabla *tuviera* un bug en producción, la respuesta **no** sería "aprovecho y la paso a hooks": sería el hotfix mínimo sobre la clase, y la migración quedaría como 💸 aparte. Mezclar un fix urgente con una refactorización opcional es multiplicar el riesgo del fix por el de la migración, justo cuando menos lo quieres. Y la deuda del `window.confirm` sigue ahí: migrar no paga deuda de interfaz.

### 5.3 Caso trabajado: corrección mínima contra refactor, sobre el mismo bug

El incidente 19 es un bug del curso medido: con la bitácora de la Semana del Canal cargada en el tablero (180.000 giros), cada acción de cualquier pantalla tarda **213 ms** en desarrollo, porque los chequeos de Toolkit recorren la bitácora entera (Fase 9 §4). Las dos respuestas, lado a lado.

**Primero, la prueba de regresión que reproduce el bug antes del fix.** Se escribe *antes* de tocar el código, y tiene que fallar con el bug presente:

<<<archivo:trabajo/publicados-19/src/features/dashboard/dashboardSlice.devchecks.test.js>>>

Con el bug falla, con el aviso literal de Toolkit (*"SerializableStateInvariantMiddleware took 480ms, which is more than the warning threshold of 32ms"*). Con el fix pasa.

**La corrección mínima** (va con el incidente abierto): que los chequeos no miren esa rama.

<<<fragmento:esclusa-app/src/app/store.js|  // F09: los chequeos de desarrollo|    }).concat(epicMiddleware),>>>

Riesgo bajo, siete líneas —dos de comentario—, la prueba pasa: 0,1 ms por acción. Pero **la bitácora sigue en el store**: 180.000 objetos en memoria del navegador para mostrar ocho barras, bajados enteros por la red en cada cambio de rueda.

**La refactorización correcta** (va al backlog, con su 💸): que el store **no guarde la bitácora**, sino los conteos —como ya hace la conciliación de la Fase 8—, y mejor todavía, que los conteos vengan agregados del servidor (`be07`). Ataca la causa: no hay una rama grande que chequear, ni que bajar, ni que recorrer. Toca el slice, los selectores y el thunk del tablero, y la prueba de memoria de la Fase 10 tiene que reescribirse, porque cambia lo que memoiza.

| | Corrección mínima | Refactorización |
|---|---|---|
| **Qué ataca** | el síntoma (los chequeos recorren la bitácora) | la causa (la bitácora en el store) |
| **Superficie** | 7 líneas en `store.js` | slice, selectores, thunk y una prueba |
| **Riesgo** | bajo | medio |
| **Cuándo** | ahora, con el incidente abierto | backlog, con la red puesta |
| **Deja deuda** | sí: la bitácora sigue bajando entera (💸) | no, o se la pasa al servidor |

La respuesta profesional es **las dos, en orden**, y anotar la 💸 de la corrección mínima. Un hotfix sin su deuda anotada es cómo un síntoma tapado se convierte en el próximo incidente.

### 5.4 Puente RxJS 6 → 7, medido

Si algún día se migra RxJS 6.6.7 → 7, las pruebas de canicas de la Fase 10 son el oráculo que confirma que **el tiempo no cambió**. Esta vez no se cuenta: se corrió. En una copia descartable del proyecto (`git worktree add`, con RxJS 7.8.1 y rxjs-marbles 7.0.1 instalados sin guardar), las pruebas de `pollingEpic` y de `searchPlayerEpic` de la Fase 10 corrieron **sin cambiar una línea**, y pasaron. Los epics tampoco cambiaron: `debounceTime`, `switchMap`, `timer`, `takeWhile`, `takeUntil` y `catchError` existen igual en las dos.

Lo que sí cambia está en la superficie, y una prueba pequeña lo fija en las dos versiones:

<<<archivo:trabajo/puente/rxjs7.test.js>>>

| Aspecto | RxJS 6.6.7 (el curso) | RxJS 7.8.1 (la copia) |
|---|---|---|
| `firstValueFrom` / `lastValueFrom` | no existen | existen |
| `toPromise()` | funciona | funciona, deprecado |
| `combineLatest([a$, b$])` | funciona | funciona (la forma con argumentos sueltos queda deprecada) |
| Los epics del curso | — | **sin cambios** |
| Las pruebas de canicas de la Fase 10 | rxjs-marbles 6.0.1 | rxjs-marbles 7.0.1, **las mismas pruebas, en verde** |

> **Por qué esto importa más que el resto del puente.** De todas las modernizaciones posibles, la de RxJS es la más traicionera, porque su bug característico —un `takeUntil` que corta un frame tarde, una suscripción que sobrevive al logout— **no se ve** en un render ni en un clic. Solo una prueba que fija el tiempo lo atrapa. Por eso el resultado de esta copia vale más que cualquier lista de cambios: las mismas canicas pasaron.

### 5.5 React 17 y 18, medidos

El curso fija React 16.14.0 (D1). Dos copias descartables más —una con React 17.0.2 y otra con 18.2.0— corrieron la misma prueba pequeña, que afirma lo que cada versión hace:

<<<archivo:trabajo/puente/react18.test.jsx>>>

| Comportamiento | React 16.14 | React 17.0.2 | React 18.2.0 |
|---|---|---|---|
| Dos `setState` dentro de un `setTimeout` | 2 renders | 2 renders | **1 render** (batching automático) |
| Un efecto bajo `<StrictMode>`, en desarrollo | corre 1 vez | 1 vez | **2 veces** (monta, desmonta y vuelve a montar) |
| `useTransition` | no existe | no existe | existe |
| Montaje | `ReactDOM.render` | `ReactDOM.render` | `createRoot(...).render` |

Y un hallazgo que corrige una creencia común: **el JSX sin `import React` ya funciona en esta consola**. React 16.14.0 trae el runtime nuevo de JSX (`react/jsx-runtime`), y CRA 4 lo usa solo si lo encuentra. Lo que sí falla es el JSX clásico: con `DISABLE_NEW_JSX_TRANSFORM=true`, el mismo componente explota con *"React is not defined"*. El detalle está en A8 §3.

> **El hilo común.** Cada modernización promete borrar código o renders, y cada una tiene un costo que no está en el diff: React 18 cambia cuántas veces corre un efecto en desarrollo (un efecto que arrancara un polling sin limpiarlo dejaría dos vivos), y el batching cambia cuántos renders cuenta una prueba. La lección no es "moderniza" ni "no modernices": es **mide el costo real, incluido el que no se ve en el código, antes de decidir**.

---

## ⚠️ 6. Errores comunes y pieza forense

### 6.1 Los errores clásicos de la última milla

**Migrar sin correr la prueba vieja primero.** Escribes la versión con hooks, corres la prueba, la ves verde y declaras victoria. Falta el paso cero: correrla contra la **clase** antes de tocar nada. Si la prueba ya estaba roja, tu "migración exitosa" pasó de rojo a rojo.

**Tocar la prueba para que pase.** El antipatrón que anula la red. Si al migrar la prueba se pone roja y tu reacción es editarla, acabas de convertir el oráculo en un espejo. Si la prueba roja es correcta —la migración cambió el comportamiento—, el que se arregla es el código.

**Aprovechar la migración para "arreglar cositas".** Estás pasando `WheelTable` a hooks y de paso cambias el `window.confirm` por un modal. Ahora el PR toca dos cosas, y si algo se rompe no sabes cuál fue. Una migración es comportamiento cero: el diff solo muestra el cambio de mecanismo.

**Confundir "la prueba pasa" con "la migración está completa".** La prueba cubre los cuatro estados de la tabla, no todo. Un `useEffect` con las dependencias mal puestas puede pasar la prueba de montaje y aun así pedir las ruedas en cada render. El oráculo reduce el riesgo; no lo elimina.

**Pagar deuda sin su disparador, o pagar la que muere con el decomiso.** Ves que el tablero baja la bitácora entera y te pica pasarlo al servidor "porque es lo correcto". Pero si la Esclusa se apaga en 2028 y el disparador no llega antes, ese trabajo no tiene retorno. A12 dice qué deuda es cuál.

### 6.2 Pieza forense de la fase: la prueba de regresión que reproduce el bug antes del fix

Es la pieza forense de la Fase 11 y el cierre del track forense del curso. No es una herramienta nueva: es la consolidación de una disciplina. Repasa la cadena: la Fase 5 te enseñó a *leer el store en el tiempo*; la 6, *el flujo de un Observable*; la 7, *a correlacionar un epic con la red*; la 8, *a auditar la aritmética del dinero*; la 9, *a auditar el rendimiento y dónde vive la caché*; la 10, *a convertir cada reproducción manual en una aserción*. La 11 le pone el broche: **todo bug se cierra con una prueba que fallaba antes del fix y pasa después**.

1. **Reproduce el bug** a mano, hasta poder provocarlo a voluntad.
2. **Escribe la prueba que lo captura**, y confirma que **falla** con el bug presente. Es el paso que la gente se salta, y el más importante: una prueba que nunca viste fallar no sabes si prueba lo que crees.
3. **Aplica el fix.**
4. **Corre la prueba.** Ahora pasa. El paso de rojo a verde es la evidencia de que *ese* cambio arregló *ese* bug.
5. **La prueba queda.** Si alguien vuelve a introducir el bug, la prueba se pone roja antes de que llegue a producción.

Los incidentes del cuaderno siguen este orden, y por eso casi todos tienen una rama `incidente/NN`: es el estado en que su prueba tiene que estar roja. Los que no la tienen —el 08, que se prepara con caos, y el 21, que termina en una decisión— son la excepción que confirma la regla.

> **El post-mortem sin culpables, como hábito de cierre.** El incidente 19 no fue "culpa de quien no puso las `ignoredPaths`": fue una interacción entre una herramienta de desarrollo que hace bien su trabajo y un volumen de datos que nadie había cargado en el navegador. La pregunta no es *quién* sino *qué del sistema lo permitió*. Un equipo que busca culpables aprende a esconder errores; uno que busca causas aprende a prevenirlos.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**
1. Crea el tag `pre-modernizacion` y confirma con `git tag -n1 -l 'pre-*'` que su mensaje nombra la suite. **Criterio:** `CI=true npm test` en ese tag da 25 de 25.
2. Corre la prueba de `WheelTable` contra la clase y anota el resultado: es tu línea base.
3. Lista tres deudas de A12 y su disparador.
4. Identifica en `WheelTable` (hooks) qué línea reemplaza a `mapStateToProps` y cuál a `componentDidMount`.
5. Explica en una frase por qué el `window.confirm` sigue igual después de la migración.
6. Corre `git diff pre-modernizacion --stat`. **Criterio:** un solo archivo, y ninguno de prueba.
7. Busca en el código de la consola un archivo con JSX que no importe React, o crea uno, y confirma que compila con CRA 4. Explica por qué (§5.5).
8. Nombra las tres salidas que A12 asigna a cada deuda.

**🟡 Intermedio (9–17)**
9. Haz la migración de §5.2 tú mismo, desde la clase, sin mirar la versión del curso. **Criterio:** la prueba de la Fase 10 pasa sin tocarla.
10. Rompe la migración a propósito (quita `dispatch` de las dependencias del `useEffect` y agrega un estado que cambie en cada render). **Criterio:** encuentras el pedido repetido en Network, y explicas por qué la prueba no lo atrapó.
11. Escribe el comentario de la 💸 que acompaña al hotfix de §5.3, con su disparador.
12. Pasa `GrantList` (o el componente de clase que quede) a hooks con el mismo procedimiento de cuatro pasos.
13. Clasifica en A12 tres deudas nuevas que hayas encontrado en el curso, con su salida en el horizonte.
14. Con la copia de RxJS 7, cambia un `toPromise()` por `firstValueFrom` y confirma que en la copia funciona y en el repo no compila.
15. En la copia de React 18, envuelve la consola en `<StrictMode>` y abre la pantalla de compras. **Criterio:** cuentas las consultas al montar y explicas por qué no son dos pollings vivos.
16. Explica con la tabla de §5.5 por qué una prueba que cuenta renders exactos puede romperse al pasar a React 18 sin que el componente haya cambiado.
17. Escribe, en una página, la lista de lo que tendría que pasar antes de mover `react` a 17 en `package.json`.

**🟠 Difícil (18–25)**
18. Haz la refactorización de §5.3: que el tablero guarde los conteos y no la bitácora. **Criterio:** la prueba del incidente 19 pasa **sin** las `ignoredPaths`, y la de memoria de la Fase 10 se reescribe con un motivo escrito en el commit.
19. Diagnóstico: una migración a hooks que "pasa las pruebas" y en producción pide las ruedas dos veces por visita. Encuentra la causa con Network y escribe la prueba que la habría atrapado.
20. Arma tu propia copia descartable con `git worktree add` y RxJS 7.8.1, y corre **toda** la suite de la Fase 10. **Criterio:** la lista de lo que pasó y de lo que no, con la causa de cada rojo.
21. En la copia de React 18, corre la suite de la Fase 10. **Criterio:** lo que se rompe, y si se rompió el componente o la prueba.
22. Mide cuánto tarda la suite entera en el repo y en la copia de React 18.
23. Escribe el plan de una migración de React Router 5 a 6 sobre `AppRouter.jsx`: qué archivos toca, en qué orden, con qué prueba de oráculo.
24. Diagnóstico: después de quitar `DISABLE_NEW_JSX_TRANSFORM` de un `.env` heredado, un componente sin import de React empieza a funcionar. Explica por qué antes fallaba y si hay algo que limpiar.
25. Escribe el post-mortem del incidente 19 sin culpables, con los ocho puntos del cuaderno.

**🔴 Muy difícil (26–30)**
26. Llena la tabla de criterios del veredicto (§9) con números reales de tu repo de prueba: cuántos incidentes, cuántas deudas por salida, cuánto tarda la suite.
27. Diseña la decomisión de una función de la consola —por ejemplo, el envío manual— como herramienta del editor de Unity: qué datos necesita, qué API, qué se pierde.
28. Diseña la migración de la misma función a React 18 con RTK Query: qué se borra, qué se agrega, y qué pruebas de la Fase 10 sobreviven.
29. Compara los dos diseños anteriores con los criterios de §9 y escribe una recomendación de una página, sin decidir por el estudio.
30. Con la copia de React 18, haz que la consola entera corra bajo `createRoot` y `<StrictMode>`, y documenta cada efecto que se dispara dos veces y si su limpieza lo deja sano.

**🔥 Opcionales**
- 🔥 Migra `searchPlayerEpic` a RxJS 7 en la copia y reescribe su import de `rxjs/operators` a `rxjs`. ¿Cambia algo en la prueba?
- 🔥 Escribe el `createApi` de RTK Query para las ruedas (Toolkit 1.8.6 ya trae `@reduxjs/toolkit/query`) en una rama, y compara con `wheelSlice`.
- 🔥 Normaliza `wheelSlice` a `byId` y mide si a cien ruedas el `find` importaba.

---

## 📚 8. Referencias

**Del curso**
- `A12-mapa-de-deuda-tecnica.md` — el inventario de la deuda, con su salida en el horizonte.
- `A8-puente-a-react-moderno.md` — React 17 y 18, RTK Query, RxJS 7, las alternativas a redux-observable.
- `A5-class-components-vs-hooks.md` — el mapa de clase a hooks, en detalle.

**Documentación oficial**
- https://legacy.reactjs.org/blog/2020/10/20/react-v17.html — React 17: el "release sin features".
- https://legacy.reactjs.org/blog/2020/09/22/introducing-the-new-jsx-transform.html — el JSX nuevo, y por qué llegó también a React 16.14.
- https://react.dev/blog/2022/03/29/react-v18 — React 18: `createRoot`, el batching automático, StrictMode.
- https://rxjs.dev/deprecations/to-promise — `toPromise` y su reemplazo.
- https://redux-toolkit.js.org/rtk-query/overview — RTK Query.

**Libros**
- *Working Effectively with Legacy Code*, de Michael Feathers — la idea de la prueba como red antes de tocar, de donde sale el oráculo de esta fase.

**Orden de lectura sugerido:** A12 → §5.2 y §5.3 de esta fase → A8 §3 y §4 → el veredicto de §9.

> ⚠️ Las URL pueden haber cambiado; verifícalas. La documentación de React vive hoy en react.dev; la de las versiones viejas, en legacy.reactjs.org.

---

## 🚀 9. Cierre del curso

Entraste a una consola de 2019 que nadie te explicó, con clases y hooks mezclados, un mock que falla a propósito y una rueda que la comunidad acusa de estar arreglada. Sales con la misma consola, sin haberla reescrito: con la sesión que sobrevive al F5, los envíos que no salen dos veces, los epics que se apagan solos, el cierre a hora exacta, la conciliación que cuadra al centavo, un tablero que muestra si la rueda da lo que publica, y una red de pruebas que te deja tocarla. Y con veintiún incidentes que aprendiste a reproducir, a explicar y a cerrar con una prueba.

### El veredicto de los dos años

La historia no deja la decisión para el final del curso, sino para dentro de dos años, y con razón: hoy no hay datos para tomarla. Lo que este curso deja son los **criterios** con que se va a tomar, y la forma de medir cada uno con lo que ya construiste. No se decide por el estudio: se le dan números.

| Criterio | Cómo se mide | A favor de decomisionar si… | A favor de migrar si… |
|---|---|---|---|
| **Incidentes por mes** de la consola | el cuaderno de incidentes y su registro | bajan a casi cero: la consola ya no cambia | siguen apareciendo: la consola está viva y se toca |
| **Funciones que el editor de Unity no puede absorber** | la lista de pantallas de la consola, una por una | todas tienen un equivalente razonable en el editor | quedan funciones de operación (conciliación, compras) que solo existen acá |
| **Deuda por salida** (A12) | contar las 💸 por *antes del corte* / *muere con el decomiso* / *al migrar* | la mayoría muere con el decomiso | la mayoría se paga al migrar y es barata |
| **Costo de un evento** | horas de soporte y de desarrollo de la última Semana del Canal | el evento se opera desde el juego sin la consola | la consola sigue siendo el centro del evento |
| **La red de pruebas** | `CI=true npm test`, el smoke y las regresiones de los incidentes | — | está en verde y cubre lo que se migraría: sin red, migrar es reescribir con fe |
| **Quién la mantiene** | las personas que la saben tocar | nadie del estudio, y el contrato del equipo de Colombia termina | el estudio puede sostener a alguien que la conozca |

Dos advertencias, para que el veredicto no se haga trampa a sí mismo. La primera: **decomisionar no es gratis**. Mover el envío manual, la conciliación y el seguimiento de compras al editor de Unity es un proyecto con sus propios incidentes, y todo lo que este curso aprendió sobre la regla que vive en un solo lugar (historia §5) aplica también ahí. La segunda: **migrar no es un número de versión**. Es el orden de A8 §10 —React 17, hooks por módulo, RTK Query por endpoint, React 18 solo si hay un problema que resuelva—, cada paso con su oráculo.

Quien decide es el estudio: Abdiel, Itzel y Juliana. Lo que tú puedes llevar a esa reunión es la tabla llena.

> **La señal de que el curso cumplió:** cuando abras un sistema legacy que no es este, encuentres una línea rara, y antes de tocarla te preguntes *¿está así a propósito?*, *¿qué prueba me diría si la rompo?* y *¿qué le pasa a esta deuda si el sistema se apaga en dos años?*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-11-cierre-puente-react-moderno -m "F11 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f11: …`) y los de ejercicio su número (`f11 ej17: …`). Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

> Material de autoría, no de lectura. Va acá abajo, fuera de la plantilla de nueve secciones, porque es lo que apareció al escribir la fase y no cabía adentro — y porque no debe competir con el cierre.

- **La tabla del veredicto no tiene umbrales.** Es deliberado: los umbrales los pone el estudio. → Si el curso se usa con un equipo real, el ejercicio 26 es el que los produce.
- **El puente no corrió toda la suite** en las copias de RxJS 7 y React 18, solo las pruebas de los epics y las del puente. → Son los ejercicios 20 y 21.

### Reservas para el cuaderno de incidentes

- **20** — *El test pasa en mi máquina y falla en la de al lado* · se abre en la Fase 10 y se **cierra acá**: la decisión entre parchear la prueba y arreglar el componente usa el criterio de corrección mínima contra refactorización de §4.
