# ✍️ Guía de estilo, tono y convenciones de código
## Tutorial Angular 16 — Inspecciones y certificaciones

Esta guía es la fuente de verdad editorial del proyecto. Cualquier chat que
produzca un `.md` la sigue. Su objetivo es simple: que los ~50 documentos del
tutorial se lean como escritos por la misma mano, con la misma voz y el mismo
criterio, y que todos apunten al mismo lugar — mantener CertCore sin romperlo.

Si dudas entre dos formas de escribir algo, gana la que le sirva más a alguien
que mañana tiene que arreglar un bug en producción con el jefe mirando por
encima del hombro.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien arregle un sistema heredado sin
romperlo.**

No enseñamos Angular "bonito". No formamos arquitectos de frontend. Formamos ojo
para leer código ajeno, reproducir un bug desde un ticket vago, depurar un bundle
minificado, comparar UAT contra PROD y aplicar un hotfix que no rompa otras tres
cosas.

Y en este track hay una segunda habilidad, que no existe en el Track A y que
define al curso entero: **leer dos generaciones de estilo en el mismo repositorio
sin marearse, y decidir en cuál de las dos se escribe el fix.**

El filtro para cada párrafo es este: **¿esto ayuda a diagnosticar, depurar,
corregir o prevenir?** Si no, sobra. Aunque esté muy bien escrito. Sobre todo si
está muy bien escrito.

---

## 2. Tono

El tono es **semi formal, cálido y directo**, con humor cuando cae bien. Piensa
en un colega senior que ya sufrió este código y te lo explica con confianza, sin
solemnidad de manual corporativo, pero también sin palmaditas en la espalda.

Cómo se ve eso en la práctica:

- **Tuteo latinoamericano, siempre.** Le hablas al lector de "tú": *"apaga el
  mock y verás el error real"*. Nada de voseo (*"agregá"*, *"fijate"*), nada de
  "usted", nada de impersonal permanente ("se debe configurar…") que enfría el
  texto.
- **Semi formal.** Cercano, pero no chat de WhatsApp. Frases completas,
  puntuación correcta, cero abreviaturas de mensajería. Un "che" no, un "ojo con
  esto" sí.
- **Humor seco y con moderación.** Un 😉 bien puesto, un chiste sobre las tres
  horas que perdiste buscando un bug de estado cuando lo que fallaba era el
  mock. Regla práctica: **máximo un chiste por sección**, y si no fluye solo, se
  borra.
- **Honesto sobre lo feo, y aquí lo feo es distinto.** En este track casi no hay
  código *viejo*: hay código *inconsistente*. Dos formas correctas de hacer lo
  mismo, conviviendo, sin que nadie documentara cuál usar. Eso se dice tal cual:
  *"las dos formas funcionan, las dos están en el repo, y elegir mal no te va a
  romper nada hoy — te va a costar media hora de confusión dentro de tres meses"*.
- **Cálido sin condescendencia.** El lector es un dev senior de backend. Cálido
  significa acompañarlo en la fricción, no explicarle qué es HTTP, JSON, un token
  o una petición asíncrona.
- **Orientado a la duda real.** Anticipa el *"¿y esto por qué está así?"* y
  respóndelo, muchas veces con una 📝 **Nota de migración** que dé el contexto:
  qué versión trajo esa API, qué reemplazó, y por qué lo anterior sigue vivo en
  el repo.

Lo que evitamos: promesas vacías ("vas a dominar Angular"), motivación de coach,
solemnidad de manual, y explicar lo obvio para el perfil.

---

## 3. Idioma y forma de la narrativa

- **Español latinoamericano neutro**, técnico y claro, para todo lo que no es
  código: títulos, explicaciones, ejercicios, referencias, callouts.
- **Los términos del stack se quedan en inglés** cuando son el nombre real de la
  cosa: *standalone*, *guard*, *interceptor*, *resolver*, *pipe*, *signal*,
  *bundle*, *source map*, *memory leak*, *rolling update*. Traducirlos
  forzadamente ("guardián", "señal") confunde más de lo que aclara y no es lo que
  van a leer en el código.
- **Markdown siempre.** Nada de HTML embebido salvo que no haya alternativa —la
  excepción conocida y aceptada es el `<details>` del cuaderno de incidentes.
- **Prosa antes que listas.** Se prefiere razonar en párrafos: un párrafo que
  explica *por qué* vale más que cinco viñetas que enumeran *qué*. Las listas se
  usan cuando la cosa es de verdad una lista — pasos secuenciales, ítems
  paralelos, opciones.
- **Listas antes que tablas en comparativas extensas.** Cuando compares tres
  entornos, cuatro librerías o cinco estrategias, usa una lista con subtítulos,
  no una tabla ancha. Una tabla de siete columnas se lee mal en pantalla, peor en
  móvil, y no deja espacio para explicar el porqué de cada celda.

  Formato recomendado para comparativas:

  ```markdown
  **Opción A — Guard funcional con `inject()`**

  Qué es: una función `CanActivateFn`, sin clase ni decorador.
  Cuándo conviene: en todo código nuevo; es lo que Angular 16 documenta.
  El costo: no puedes heredar de él, y el stack trace da menos pistas.
  Veredicto: es el estilo del proyecto para todo lo que se escriba de aquí en
  adelante.
  ```

- **Tablas solo para lo que de verdad es tabular y corto.** Versiones pinneadas,
  mapeo estado → etiqueta, matriz de dificultad, tres columnas como máximo. Si
  necesitas explicar una celda, ya no es una tabla: es una lista.
- **Encabezados con emoji, con moderación.** Uno por sección de la plantilla. Un
  documento que parece un teclado de emojis pierde autoridad.

---

## 4. Pedagogía: cómo se explica

### 4.1 La regla del andamio

Todo concepto nuevo se presenta en tres tiempos, en este orden:

1. **El problema primero.** Antes de nombrar la herramienta, muestra el dolor que
   resuelve. *"Cuatro componentes necesitan saber qué plantilla está vigente hoy.
   Puedes pedirla cuatro veces al backend y rezar para que nadie publique una v3
   entre la primera y la cuarta, o puedes…"*
2. **La herramienta después.** El nombre y la definición mínima: lo justo para
   usarla hoy, no el capítulo completo de la documentación.
3. **El código que corre.** El fragmento más pequeño que demuestra el punto, con
   comentarios que explican el porqué.

Presentar la herramienta antes que el problema produce estudiantes que saben
escribir un `BehaviorSubject` pero no saben cuándo hace falta.

### 4.2 Analogías con backend, sin abusar

Un interceptor HTTP es primo de un filtro o middleware; un guard es un check de
autorización antes del handler; un servicio de estado es un singleton en memoria
con transiciones controladas; `inject()` es resolución del contenedor de DI,
igual que en Spring o en .NET, sólo que con una regla de contexto propia.

Dos límites: la analogía se usa **una vez, para abrir la puerta**, y después se
abandona; y se dice explícitamente dónde se rompe (*"hasta acá el paralelo
funciona; la diferencia es que el guard corre en el navegador y el usuario puede
saltárselo, así que no es seguridad, es experiencia de usuario"*).

### 4.3 Explica el porqué, no solo el cómo

Cada decisión relevante lleva su porqué, aunque sea media línea entre paréntesis.
Y cuando el porqué es histórico —que en un sistema migrado pasa seguido—, se dice
también: *"esto está así porque en Angular 12 era la única forma; el archivo de al
lado, escrito el año pasado, usa la nueva, y ninguno de los dos está mal"*.

### 4.4 Densidad calibrada

- Un concepto nuevo por vez. Si un bloque de código introduce tres cosas
  desconocidas, se parte en tres bloques.
- Repetir lo importante está bien. Los conceptos que sostienen el curso —el
  invariante de versión de plantilla, dónde vive el estado, quién se desuscribe,
  qué corre en el navegador y qué en el servidor— pueden reaparecer varias veces
  con otras palabras.
- Ninguna sección teórica supera las dos pantallas sin que aparezca código.

### 4.5 Cierra los bucles

Si abres un paréntesis pedagógico —*"esto lo vemos en la Fase 8"*, *"acá dejamos
deuda 💸"*— tiene que cerrarse en algún documento del curso. **Y en este track la
mayoría de las deudas se cierran de verdad** (§7.1): un 💸 sin fase de cobro es un
error de escritura, no una licencia.

---

## 5. Idioma del código fuente

> **Regla normativa y no negociable: todo el código fuente del curso se escribe
> en inglés —variables, funciones, clases, archivos, endpoints, constantes,
> enums, clases CSS— y todos los comentarios se escriben en español.** Aplica a
> cada fragmento de código del proyecto, sin excepción: fases, apéndices,
> incidentes, ejercicios resueltos, tests, `db.json`, Dockerfile y scripts.

CertCore lo escribió un equipo internacional y su código está en inglés, como el
de casi cualquier sistema que un equipo de mantenimiento hereda. Si el tutorial
usara `crearInspeccion` y `plantillasService`, el vocabulario que el estudiante
practica durante un mes no sería el que va a leer en producción.

Y la contraparte importa igual: **los comentarios van siempre en español**,
porque son el canal donde se explica el *porqué* de un patrón raro, y ese
razonamiento tiene que leerse en el idioma en que se piensa el curso. Un
comentario en inglés en este proyecto es un error de estilo, aunque el código que
acompañe esté impecable. **Con tildes**, además: es español y el resto del
documento las lleva.

**Los mensajes de error van con los comentarios, no con el código.** Un
`throw new Error(...)`, un `console.error(...)` o el cuerpo de un `400` del mock
son texto dirigido a otro desarrollador: son la continuación natural del
comentario y se escriben **en español, con tildes**. Los identificadores que los
rodean siguen en inglés. La regla la fijó la Fase 1 con el guard de doble
importación de `CoreModule` y aplica a todo el curso.

### 5.1 Los textos que ve el usuario

CertCore es **monolingüe en español** (decisión cerrada,
`alcance-del-proyecto.md` §8). Los textos de interfaz van como **literales en la
plantilla**, en español, sin claves de traducción:

```html
<!-- El título va literal: CertCore es monolingüe. Si algún día se
     internacionaliza, el apéndice A13 explica qué costaría. -->
<h2>Plantillas de checklist</h2>
```

Es la diferencia visible más grande con el Track A, y conviene decirlo una vez en
la Fase 0 y no volver a mencionarlo.

### 5.2 Diccionario mínimo del dominio

- cliente → `client`
- activo → `asset`
- plantilla (de checklist) → `template` en endpoints y campos (`/templates`,
  `templateId`, `templateVersion`); **`ChecklistTemplate` como nombre de tipo**
  (ver la excepción de abajo)
- versión de plantilla → `templateVersion`
- ítem del checklist → `checklistItem`, y `ChecklistItem` como tipo
- criterio → `criteria`
- inspección → `inspection`
- inspector → `inspector`
- respuesta → `answer`
- evidencia → `evidence`
- hallazgo → `finding`
- severidad → `severity` (`critical` | `major` | `minor`)
- no conformidad → `nonCompliance`
- certificado → `certificate`
- emisión / emitir → `issuance` / `issue`
- vigencia → `validity`, con `validFrom` y `validUntil`
- renovación → `renewal`
- estados de inspección: `requested` → `scheduled` → `in_progress` →
  `completed` → `approved` | `rejected`
- estados de certificado: `issued` → `valid` → `expiring` → `expired` | `revoked`

Los nombres de servicios y métodos se arman combinando estos términos con los
verbos habituales: `get`, `fetch`, `create`, `update`, `delete`, `publish`,
`issue`, `revoke`, `resolve`.

> ⚠️ **La excepción de `ChecklistTemplate`, y por qué existe.** En un curso de
> Angular la palabra "plantilla" ya significa otra cosa, y el lector va a leer
> las dos acepciones en el mismo párrafo durante ocho fases. Por eso las
> **interfaces** son `ChecklistTemplate` y `ChecklistItem`, mientras que el
> endpoint (`/templates`) y los campos del dominio (`templateId`,
> `templateVersion`) se quedan como manda `alcance-del-proyecto.md` §5.1.
> Cerrada en la Fase 3.

### 5.3 Convenciones de nombrado

- **Componentes:** `PascalCase` + sufijo — `TemplateEditorComponent`,
  `InspectionFormComponent`.
- **Archivos:** `kebab-case` con el sufijo de Angular —
  `template-editor.component.ts`, `certificate.service.ts`, `auth.guard.ts`.
- **Servicios de estado:** sufijo `StateService` cuando el servicio *guarda*
  estado, y sufijo `Service` a secas cuando sólo habla con HTTP.
  `TemplateStateService` frente a `TemplateApiService`. La distinción es del
  curso y se sostiene en todas las fases: es lo que evita que el estudiante
  confunda "pedir datos" con "recordar datos".
  **Única excepción, cerrada en la Fase 2: `AuthService`.** Guarda la sesión, así
  que por la regla debería ser `AuthStateService` — y no lo es, porque ningún
  proyecto del mundo lo llama así y porque renombrarlo al llegar la Fase 4
  rompería la estabilidad de nombres que exige §12. Se llama `AuthService` desde
  la Fase 2 hasta la 14.
- **Guards e interceptors funcionales:** `camelCase` con sufijo —
  `authGuard`, `authInterceptor`. No llevan `Component`-style porque no son
  clases.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` — `TOKEN_STORAGE_KEY`,
  `CHAOS_RATE`, `CHAOS_DELAY_MS`, `TOKEN_TTL_SECONDS`.
- **Endpoints REST:** sustantivo plural en inglés — `/clients`, `/assets`,
  `/templates`, `/inspections/:id/findings`.

---

## 6. El estilo de código del curso (el corazón del tutorial)

Aquí está la tentación grande, y en este track tiene dos caras: escribir todo
moderno porque "es Angular 16", o escribir todo viejo porque "es legacy". Las dos
son falsas. CertCore es mixto, **y la mezcla es la lección**.

### 6.1 La regla que ordena todo

> 🧭 **Código nuevo, estilo nuevo. Código heredado, se toca lo mínimo y en su
> propio estilo.** Un fix de tres líneas en un componente de NgModule se escribe
> como el resto de ese componente. Un componente nuevo se escribe standalone,
> aunque el de al lado no lo sea.

El corolario, que es lo que el estudiante se lleva: **mezclar estilos dentro de
un mismo archivo es peor que cualquiera de los dos estilos puros.**

### 6.2 Qué es "estilo heredado" en CertCore

Vive en las Fases 1 a 4 y en todo lo que ellas crearon. Se reconoce por:

- `NgModule` con `declarations`, `imports`, `exports`.
- `constructor(private readonly http: HttpClient)` para inyectar.
- Guards e interceptors **de clase**, con `@Injectable()` y
  `HTTP_INTERCEPTORS`.
- `RouterModule.forChild(routes)` en el módulo de feature.
- `.subscribe()` con desuscripción manual por `Subscription` o `takeUntil` con un
  `Subject` de destrucción.

Nada de esto está roto y nada se refactoriza por reflejo. Se comenta que hoy se
escribiría distinto, se enlaza al apéndice que lo explica, y se sigue.

### 6.3 Qué es "estilo nuevo" en CertCore

Vive de la Fase 5 en adelante:

- Componentes **standalone**, con `imports: [...]` en el propio decorador y
  `ChangeDetectionStrategy.OnPush` por defecto.
- **`inject()`** en vez de constructor.
- Guards e interceptors **funcionales**: `CanActivateFn`, `HttpInterceptorFn`,
  registrados con `provideHttpClient(withInterceptors([...]))`.
- Rutas con `loadComponent` y `loadChildren` apuntando a arrays de rutas.
- **`takeUntilDestroyed()`** para el ciclo de vida de las suscripciones, y
  `async` pipe siempre que la suscripción sea sólo para pintar.
- **Arrow functions.** Sin `.bind(this)`, sin `var self = this`: esas dos formas
  pertenecen al Track A y aquí serían un anacronismo.

### 6.4 TypeScript strict, y lo que eso implica

`strict: true` está activo desde la Fase 0 y **no se apaga nunca**, ni en un
ejercicio, ni para simplificar un ejemplo. `any` está prohibido en el código del
curso: donde el tipo no se conoce se usa `unknown` y se estrecha.

Esto no es rigor por rigor. Es que una familia entera de bugs del curso —el
hallazgo que no bloquea, el certificado sin fecha, el control huérfano— nace de
la diferencia entre `null`, `undefined` y "campo ausente", y esa diferencia sólo
es visible con `strict` puesto.

Dos consecuencias que se escriben siempre igual:

- **`FormControl` tipado y explícito sobre la nulabilidad.** Si el control no
  puede ser nulo, `nonNullable: true`, y se dice por qué.
- **Los modelos del dominio distinguen ausencia de vacío.** `validUntil: string
  \| null` significa "vigente indefinidamente"; `validUntil?: string` significaría
  "no me molesté en decidirlo", y eso no entra al curso.

### 6.5 RxJS: moderado, no minimalista ni virtuoso

El Track A usa RxJS al mínimo. Este no: usa los operadores que un proyecto de
2024 usa de verdad —`map`, `switchMap`, `combineLatest`, `debounceTime`,
`distinctUntilChanged`, `catchError`, `shareReplay`, `takeUntilDestroyed`— y no
uno más.

La regla de oro, que se repite cuando aplique: **no todo con `async` pipe, pero
tampoco todo con `.subscribe()` a pelo.** Si la suscripción es para pintar, va
`async` pipe. Si es para provocar un efecto —guardar, navegar, abrir un diálogo—,
va `.subscribe()`, y entonces alguien tiene que desuscribirse.

Antipatrones que el curso nombra por su nombre cuando aparecen: el `subscribe`
anidado dentro de otro `subscribe`, el `BehaviorSubject` que se expone público y
cualquiera le hace `.next()`, y el `shareReplay()` sin `refCount` que se convierte
en fuga.

### 6.6 Componentes: gordos no, pero honestos

CertCore no tiene componentes de 600 líneas: eso es Track A. Tiene componentes de
150 líneas que hacen dos cosas y media, con la lógica de negocio repartida entre
el componente y el servicio sin un criterio explícito. Es un defecto más sutil y
más común, y se muestra tal cual.

Cuando una fase construya un componente así, lo comenta —*"esta regla debería
vivir en el servicio; está aquí porque la escribió quien tenía prisa"*— y lo deja,
salvo que la deuda esté marcada para cobrarse.

### 6.7 Corrección mínima frente a refactorización

Cada vez que aparece un fix, se distingue el parche mínimo —lo que va en un
hotfix un viernes— de la refactorización correcta —lo que iría con calma y
pruebas. Es una de las lecciones más transferibles del curso, y en este track
tiene un giro propio: **el parche mínimo se escribe en el estilo del archivo que
tocas**, aunque sea el estilo viejo. Modernizar mientras arreglas es cómo se
rompen otras tres cosas.

### 6.8 Fechas

Zona horaria explícita siempre. Nunca un `new Date()` suelto donde importe el
día: la vigencia de un certificado y el "¿venció ayer?" viven de esa precisión.
Las fechas del `db.json` llevan offset (`-05:00`), no `Z`, para que el problema
sea visible desde el primer dato.

---

## 7. Marcadores y callouts

Vocabulario visual compartido por todos los documentos.

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Un atajo o patrón discutible que se deja a
  propósito. **En este track la mayoría se paga**, y cada 💸 declara dónde:
  *"se paga en la Fase 5"* o, cuando no se paga, *"no se paga en este curso, y
  aquí está el porqué"*. Un 💸 sin destino es un error de escritura.
- 🔥 **Opcional o ampliación.** Fases, apéndices, secciones y ejercicios fuera del
  alcance base. No cuentan en el calendario.
- ⭐ **Pieza central.** Las Fases 7 y 8, y los incidentes de versionado.
- 🧬 **Convivencia de estilos.** Marca el sitio exacto donde el código nuevo y el
  heredado se tocan: un standalone importado desde un NgModule, un interceptor
  funcional registrado junto a uno de clase. Es el marcador propio de este track
  y el que más se busca en un `Ctrl+F`.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil, intermedio, difícil, muy difícil.
- 🏷️ **Tag de progreso.** El recordatorio de cerrar la fase —o el apéndice— en
  git. Va **una sola vez por documento**, al final, con la forma fija de §8.1.
- 🪦 **Pendiente cerrado.** Un 📌 que se resolvió: se marca así en vez de
  borrarlo, con dónde quedó la respuesta.
- 👁️ **solo lee** y ✍️ **modifica**, en apéndices de infraestructura (A09, A12).
- 🩺 **Diagnóstico por síntoma.** Encabeza la tabla de "esto me pasó, dónde miro".
- 🧨 **Rompe a propósito.** Marca un experimento destructivo dentro de un
  apéndice, donde no hay una sección 6 que lo aloje como en las fases.

### 7.2 Callouts en blockquote

- 📝 **Nota de migración.** Qué versión trajo esta API, qué reemplazó, y por qué
  lo anterior sigue vivo en el repositorio. Es la 📝 "Nota de época" del Track A,
  adaptada a un sistema cuyo pasado es reciente.
- 📚 **Referencia rápida inline.** El enlace útil justo donde nace la duda.
- ⚠️ **Advertencia.** Algo que rompe si lo ignoras: versión incompatible,
  `inject()` fuera de contexto de inyección, config horneada en el build.
- 💡 **Truco o atajo** que ahorra tiempo real.
- 🧭 **Regla del proyecto.** Una decisión que aplica en todo el curso y que el
  estudiante debería poder citar de memoria al terminar.
- 🪦 **Retiro.** Cuando algo cumple su función y sale del proyecto.

### 7.3 Secciones narrativas recurrentes

Micro-secciones con nombre fijo, que aparecen cuando el contenido las pide:

- **Detalles con intención.** Lista corta con las decisiones deliberadas de un
  bloque de código y su porqué.
- **El patrón a memorizar.** Una o dos frases que destilan la lección
  transferible del fragmento.
- **Prueba de fuego.** Verificación manual concreta, incrustada en el flujo:
  *"publica la v2 de la plantilla, abre una inspección de la semana pasada, y
  confirma que sigue viéndose con la v1"*.
- **Mini-repaso.** Cuando la fase usa sintaxis que el dev de backend quizá no
  domina (decoradores, genéricos, tipos condicionales, operadores de RxJS), un
  repaso exprés antes de entrar al código, con su 📚 a la documentación oficial.
- **¿Nuevo o heredado?** 🧬 Micro-sección propia de este track: se muestra el
  mismo fragmento en los dos estilos, se dice cuál usarías en cada situación, y
  se cierra con la regla del §6.1. Aparece cuando la fase toca por primera vez
  una API que tiene dos formas vivas.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de cita que
  describe cómo se siente el trabajo bien hecho.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden. El
esqueleto rellenable está en `plantillas-de-capitulo.md`.

1. **🎯 Propósito** — qué resuelve la fase. Puede abrir con la situación heredada
   de la fase anterior.
2. **✅ Qué queda listo al terminar** — checklist verificable, no promesas.
3. **🚫 Qué NO entra todavía** — qué se difiere y a qué fase exacta.
4. **🧠 Concepto mínimo** — la teoría justa, anclada al dominio. Aquí caben el
   Mini-repaso, las Notas de migración y el ¿Nuevo o heredado? 🧬.
5. **💻 Código mínimo con comentarios** — el grueso. Código ejecutable con las
   versiones fijadas, identificadores en inglés, comentarios en español.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente y cómo se
   depura. Enlaza con `forense-fase-NN.md`.
7. **🧪 Ejercicios** — ver §9.
8. **📚 Referencias** — ver §10.
9. **🚀 Cierre** — qué sigue, por qué, La señal de que quedó bien y el
   recordatorio 🏷️ del tag de la fase (§8.1).

Después de la novena, y fuera de la plantilla que lee el estudiante, cada fase
cierra con **📌 Pendientes sugeridos**: lo que apareció al escribirla y no cabía
adentro, con destino explícito. Ahí abajo vive también **Reservas para el cuaderno
de incidentes**, con el ID, el título propuesto, la categoría y la dificultad de
cada incidente que la fase produce. Es material de autoría, no de lectura.

### 8.1 El recordatorio del tag, en el cierre

Toda fase termina con un bloque 🏷️ que recuerda cerrarla en git. Es de forma
fija —cambian solo el número de la fase y su etiqueta— y va **después** de La
señal de que quedó bien, justo antes del `---` que abre los 📌 Pendientes:

````markdown
> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-04 -m "F4 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 04: …`) y los de ejercicio su
> número (`fase 04 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f04/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md).
````

El nombre del tag es **`fase-` + el número de dos dígitos**, no el slug del
archivo: así lo fijó la **Fase 0 §9** y así lo usan el checklist y dos ejercicios
de la Fase 1. El prefijo de commit es `fase NN:`, con espacio, por la misma razón.
Nada de la convención se reexplica en la fase: se enlaza. Cuando la fase tenga
algo propio que decir sobre git —la que paga una deuda 💸 declarada antes, la que
produce un incidente, la que estrena la imagen— se agrega un párrafo corto al
final del mismo bloque, no un bloque nuevo.

**Los apéndices también lo llevan**, y ahí el caso normal es el contrario: como
son consulta rápida y el código que explican lo escriben las fases, **no llevan
tag propio**, y el bloque lo dice explícitamente junto con qué prefijo usar para
lo que sí salga de leerlos (`fase 06: …`, el de la fase desde la que se llegó).
Sólo si un apéndice deja archivos versionados se etiqueta, con `apendice-aNN`. Un
tag que no apunta a un cambio no marca nada.

---

Los apéndices no siguen esta plantilla: índice de salto rápido, secciones cortas,
una guía final de "cuándo usar qué" y 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: 25 mínimo, 30 ideal por fase, hasta 35 en las densas.** Las Fases 7
  y 8 llegan a 35 y ese es el techo razonable.
- **Distribución equilibrada.** Para ~30 ejercicios: unos 8 🟢, 9 🟡, 7 🟠 y 5 🔴,
  más los 🔥 aparte.
- **Numeración continua con encabezado de rango**, así:

  ```markdown
  ## 🧪 Ejercicios (30)

  **🟢 Fácil (1–8)**
  1. ...

  **🟡 Intermedio (9–17)**
  9. ...

  **🟠 Difícil (18–24)**
  18. ...

  **🔴 Muy difícil (25–30)**
  25. ...

  **🔥 Opcionales**
  - 🔥 ...
  ```

- **Accionables y verificables.** *"Haz que publicar la v3 de una plantilla no
  cambie ni un píxel de una inspección aprobada el mes pasado, y demuéstralo con
  un test"* — no *"reflexiona sobre el versionado"*.
- **Al menos un tercio son de diagnóstico**, no de construcción: se entrega algo
  roto y se pide reproducir, localizar y explicar.
- **Al menos dos por fase, desde la Fase 5, son de estilo** 🧬: dado un archivo,
  decidir si el fix va en estilo nuevo o heredado y justificarlo. Es el músculo
  propio de este track y no se entrena solo.
- **Enganchados al dominio.** Clientes, activos, plantillas, inspecciones,
  hallazgos, certificados. Nunca `foo` y `bar`.
- **Con el identificador vigente.** Si el ejercicio nombra código, usa el nombre
  en inglés que ya existe en la fase (`resolveTemplateVersion`, no
  `resolverVersionPlantilla`).

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial compatible con las versiones fijadas primero;
después libros; después blogs y videos. Siempre se advierte cuando un enlace
apunta a una versión distinta de la que usamos, que con Angular pasa casi
siempre.

### 10.1 Formato

URLs completas y clicables, nunca solo el dominio. Dentro de "Referencias" se
separa en documentación oficial, libros cuando apliquen, video y apoyo, y una
línea final de **orden de lectura sugerido**.

### 10.2 Fuentes oficiales por tema

- **Angular 16:** https://v16.angular.io/docs — es la referencia por defecto.
  ⚠️ Cuidado con caer en https://angular.dev, que documenta la 17 en adelante y
  cuyos ejemplos usan control flow y signals que aquí no existen.
- **Angular CLI 16:** https://v16.angular.io/cli
- **Angular Material 16:** https://v16.material.angular.io — el cambio a MDC es
  de la 15, así que casi cualquier artículo anterior a 2023 describe otro
  componente con el mismo nombre.
- **RxJS 7:** https://rxjs.dev
- **TypeScript:** https://www.typescriptlang.org/docs — advertir que documenta
  versiones posteriores a 5.1.
- **json-server:** https://github.com/typicode/json-server
- **Docker y nginx:** https://docs.docker.com · https://nginx.org/en/docs
- **kind:** https://kind.sigs.k8s.io
- **MDN** para JavaScript base: https://developer.mozilla.org

### 10.3 Advertencias

- Cuando se cite un artículo, libro o video específico, se aclara que el título o
  la URL pueden haber cambiado y que conviene verificarlos. No se inventan números
  de página, ISBN ni identificadores de video.
- **No usar en el código principal** APIs de Angular 17 en adelante: control flow
  `@if/@for`, deferrable views, `signal()` como estilo de estado, el builder de
  esbuild por defecto. Aparecen sólo como comparación, en la Fase 12 o en A11.
- **Signals:** en Angular 16 existen y son experimentales. Se leen, no se usan.

---

## 11. Coherencia de la ficción

El sistema heredado del curso se llama **CertCore** y es ficticio. Nació en 2021
sobre Angular 12, se migró a 16.2.12 a lo largo de 2024, hoy está en
mantenimiento. El curso lo **construye pieza por pieza**: al terminar la última
fase obligatoria, el estudiante tiene CertCore delante, en su disco, y puede abrir
cualquier archivo del que el material haya hablado.

Esa es toda la ficción, y es lo que hace el curso autocontenido. También impone
cuatro reglas.

**Regla 1 — Si el curso afirma que algo está así en CertCore, tiene que poder
mostrarlo.** *"Así lo hace CertCore"* es legítimo cuando el código está en alguna
fase, y sólo entonces. No lo es cuando describe pantallas que el curso no escribe,
porque promete un archivo que el lector no puede abrir. Es la regla que sustituye
a la coartada del NDA del documento base.

**Regla 2 — Lo que CertCore tiene y el curso no construye se cuenta como historia,
no como observación.** Hay cosas del sistema que importan y no caben en un
tutorial: los cuarenta componentes que nadie migró, la plantilla v1 de 2021 con
ítems que ya nadie entiende, el módulo de reportes que escribió un contratista. Se
cuentan **en pasado y como contexto**:

> ✅ *"CertCore arrastra cuarenta componentes que nadie migró; acá construyes tres
> y el reflejo que te llevas es no tocar los otros treinta y siete sin motivo."*
>
> ❌ *"El sistema tiene un módulo de reportes con un bug en la paginación."*

La segunda promete un código que nadie puede abrir. La primera dice lo mismo, es
igual de útil, y es verdad.

**Regla 3 — La cronología es fija.** 2021 el nacimiento en Angular 12, 2024 la
migración a 16, hoy el mantenimiento. Toda 📝 **Nota de migración** se sitúa dentro
de esa línea, y ninguna decisión de CertCore puede justificarse con algo que no
existía cuando se tomó. Un componente escrito en 2021 no pudo usar
`takeUntilDestroyed`, que llegó con la 16.

**Regla 4 — Ningún ejercicio pide algo que sólo se pueda hacer con un sistema que
el estudiante no tiene.** Ni "verifica esta versión contra tu `package.json`", ni
"compara con cómo lo resuelve tu empresa", ni "pregúntale a tu equipo". Las
versiones están fijadas; lo que un dev haría con un proyecto heredado propio es el
**Apéndice A03**, y es una sección, no una instrucción suelta.

> 🧭 **El corolario, que es lo que se gana:** el curso se puede tomar entero, de
> principio a fin, sin acceso a nada más que a este repositorio. Cualquier frase
> que rompa eso es un error de estilo, aunque esté bien escrita.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Un fragmento de la Fase 8 no puede usar
  una forma del estado distinta a la que definió la Fase 4.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y explicar por qué.
- **Nombres estables.** Archivos, servicios y componentes se mantienen idénticos
  entre fases. Si algo se renombra, se documenta el cambio y se ajustan las fases
  afectadas.
- **Fuentes de verdad, en este orden:** (1) instrucciones del proyecto,
  (2) `prompts/alcance-del-proyecto.md`, (3) `prompts/propuesta-fases-y-alcance.md`,
  (4) esta guía, (5) `prompts/plantillas-de-capitulo.md`,
  `prompts/formato-cuaderno-incidentes.md` y `00-convencion-de-git-y-tags.md`
  —este último para todo lo que toque git, repos, ramas y tags—, (6) entregables
  ya aprobados de fases anteriores, (7) decisiones explícitas del chat actual.
  `prompts/_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, su
  numeración de apéndices A1-A8 y su marco de NDA quedaron atrás.

### 12.1 Nombrar al curso hermano: dónde sí y dónde no

La regla por defecto del repositorio es que **cada curso es autocontenido**: se
lee entero sin saber que el otro existe, y un capítulo que dice *"como viste en
LabCore"* deja fuera a quien llegó directo. Este curso **diverge a propósito**, y
la divergencia tiene frontera:

- **Sí se nombra en dos sitios, y solo en dos.** El `README.md` —su sección
  *«Su curso hermano»*, que es el escaparate y se lee antes de decidir si tomas el
  curso— y el apéndice [`a10-migracion-8-16.md`](../a10-migracion-8-16.md)
  entero, **cuyo lector es exactamente quien viene de allá** y cuya razón de
  existir es traducir esos reflejos. Ahí nombrarlo no es una fuga: es el contenido.
- **No se nombra en ninguna otra parte**: ni en una fase, ni en una pieza
  forense, ni en el cuaderno, ni en el track BE. Cuando hace falta contrastar con
  un legacy más viejo, se dice *"el Track A"* sin nombrar el sistema, o se
  describe la propiedad —`strict: false`, NgRx de 2019— sin atribuirla a un curso.
- **Y nunca en la otra dirección.** Que este curso enlace a su hermano no
  autoriza a que su hermano enlace a éste: allá la decisión fue la contraria y se
  purgaron las referencias. La asimetría es deliberada y se sostiene porque
  **A10 existe aquí y no allá**.

---

## 13. Post-mortems e incidentes

Cada incidente del cuaderno sigue esta estructura de ocho puntos:

1. Síntoma, en palabras del usuario.
2. Pasos de reproducción exactos.
3. Evidencia observable: consola, Network, DevTools, logs.
4. Causa raíz, hasta la línea o el commit.
5. Corrección aplicada.
6. Prueba de regresión que falla antes del fix y pasa después.
7. Prevención: test, feature flag o alerta.
8. Post-mortem **sin culpabilización**: se analiza el sistema y el proceso, no a
   la persona.

El tono acá baja un punto de humor. Un post-mortem es sereno y analítico. El
formato completo del archivo está en `formato-cuaderno-incidentes.md`.

Los puntos 1 a 6 tienen traducción exacta a git, y conviene pedirla: el par de
tags `inc/<ID>/<slug>-roto` e `inc/<ID>/<slug>-fix` deja el síntoma y la
regresión en rojo en el primero, la causa raíz y el fix en el segundo, y el
`git diff` entre los dos **es** el punto 5 aislado del ruido de la fase. El
`<ID>` es el que el cuaderno ya tiene reservado, nunca uno inventado. El detalle
está en `00-convencion-de-git-y-tags.md`, y las fases lo enlazan desde su bloque
🏷️ sin reexplicarlo.

---

## 14. Checklist antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono semi formal y cálido, tuteo latinoamericano, humor con moderación.
- [ ] Explica el problema antes que la herramienta, y el porqué de cada decisión.
- [ ] Prosa antes que listas; listas antes que tablas en comparativas extensas.
- [ ] Todo el código corre con las versiones fijadas del stack.
- [ ] **Todo el código en inglés** y **todos los comentarios en español, con
      tildes**; textos de interfaz literales en español (§5).
- [ ] **`strict: true` respetado**: cero `any`, nulabilidad explícita, `unknown`
      donde el tipo no se conoce (§6.4).
- [ ] El estilo del fragmento corresponde a su generación: standalone e `inject()`
      si es código nuevo, NgModule y constructor si es heredado — y nunca los dos
      mezclados en el mismo archivo (§6.1).
- [ ] Cada 💸 declara dónde se paga, o por qué no se paga.
- [ ] Los puntos de contacto entre estilos van marcados con 🧬.
- [ ] Tiene 25-35 ejercicios con rangos 🟢🟡🟠🔴 equilibrados, un tercio de
      diagnóstico y al menos dos de estilo 🧬 (o 5-10 cortos en apéndices).
- [ ] Enlaza su pieza forense y los incidentes relacionados.
- [ ] Referencias con URL completa a documentación de la versión correcta
      (v16.angular.io, no angular.dev), con advertencia cuando no lo sea.
- [ ] No contradice ninguna fase anterior, ni en pedagogía ni en nombres.
- [ ] Coherencia de la ficción (§11): nada que afirme sobre CertCore algo que el
      curso no pueda mostrar, y ningún ejercicio que exija un sistema externo.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
- [ ] Lleva el bloque 🏷️ del tag al final, con el número correcto (`fase-NN`) y
      el prefijo de commit correcto (§8.1). En los apéndices, el bloque dice que
      no llevan tag propio y con qué prefijo se commitea lo que salga de leerlos.
- [ ] Si la fase paga una deuda 💸 declarada antes, dice entre qué dos tags se lee
      la factura (`git diff fase-01 fase-05 -- …`).

---

## 15. 🔥 El track opcional de backend

Sección de encuadre del **track BE**, cuyo alcance completo vive en
`prompts/propuesta-fases-backend.md` §4, §5 y §9. Acá solo va lo que esta guía
tiene que decir para que un capítulo del track se escriba igual que uno del track
base. **Si algo de abajo contradice a la propuesta, manda la propuesta.**

### 15.1 Qué se hereda sin cambios

- **La plantilla obligatoria de nueve secciones** de §8, incluido el bloque 📌 de
  autoría fuera de lo que lee el alumno.
- **La voz, el tuteo, la regla del andamio** y la prosa antes que listas (§2-§4).
- **El régimen de ejercicios** de §9: 25 mínimo, 30 ideal, hasta 35 en las densas,
  con al menos un tercio de diagnóstico y los rangos 🟢🟡🟠🔴 equilibrados.
- **Los marcadores y callouts** de §7, con una adición: las secciones narrativas
  recurrentes del repositorio —🪞 *"tu instinto dice… y esta vez se equivoca"*, 🩻
  *"esto sí funciona igual"*, ⚰️ autopsia de anti-patrón, 📖 diccionario de
  traducción— **son obligatorias donde la fase las pida** y están nombradas una a
  una en §7 de la propuesta.
- **El checklist de cierre** de §14, con los ítems de Angular sustituidos por los
  equivalentes de PHP (abajo).

### 15.2 Nombres de archivo y tags

Fases **`beNN-tema.md`** (`be00` a `be07`); apéndices **`bea-NN-tema.md`**
(`bea-01` a `bea-11`). Minúsculas con guiones, dos dígitos.

El prefijo `be` mantiene los cuatro bloques separados en el mismo directorio sin
subdirectorios: fases base (`00-` a `14-`), apéndices base (`a01-` a `a13-`),
piezas forenses (`forense-fase-NN.md`) y track BE.

> 📝 El track base usa `aNN-`, así que `beaNN-` habría rimado mejor localmente.
> Se elige `bea-NN-` porque es la convención registrada en el `CLAUDE.md` del
> repositorio. Un solo nombre para la misma cosa en todo el repositorio vale más
> que la rima local.
>
> 🪦 **Renombrado el 10/09/2026: antes era `be-a-NN-`.** Tres segmentos separados
> por guion antes del tema se leían como tres cosas en vez de una. Con `bea-`
> como prefijo único, todo archivo del repositorio tiene la misma forma
> —`<prefijo>-<número>-<tema>`, igual que `forense-fase-NN`— y el número del
> apéndice es lo primero después del prefijo. Si encuentras un `be-a-NN-` en
> algún sitio, es un resto del nombre viejo.

**Tags:** namespace propio, `be-fase-` + el slug del archivo
(`be00-el-contrato-auditoria-del-mock.md` → `be-fase-00-el-contrato-auditoria-del-mock`),
para que `git tag -l 'fase-*'` siga siendo el índice limpio del track base.
Prefijo de commit `beNN:`, y de ejercicio `beNN ejNN:`.

**No hay `forense-be-NN.md`.** Divergencia declarada: los `forense-fase-NN.md`
existen para sostener capturas de DevTools y recetas de breakpoints. La pieza
forense del track BE es un log, un `EXPLAIN` o un `grep` vacío, y **cabe en la §6
de la fase**, junto al código que la produce.

**Cuaderno propio:** `cuaderno-incidentes-be.md`, con IDs `be-01` … `be-12`
independientes de los del cuaderno base. Un alumno que solo hace el track base no
debe recibir incidentes de PHP mezclados con los suyos.

### 15.3 Estilo de código del track

Aquí la regla de "una generación por archivo" de §6.1 **no aplica** —no hay dos
generaciones de PHP conviviendo por diseño—, y en su lugar gobiernan cuatro:

- **Código en inglés, comentarios en español con tildes.** También en PHP: clases,
  métodos, rutas, nombres de tabla y de columna, y los nombres de las migraciones.
- **Nada de PHP moderno gratuito.** Sin `match`, sin enums, sin atributos, sin
  constructor property promotion, sin tipos union. El runtime es **7.4 a
  propósito**; lo de PHP 8 aparece marcado 🔥 como comparación, igual que Angular 17
  en el track base.
- **El frontend no se toca.** Ni un componente, ni un servicio, ni un
  `BehaviorSubject`, ni `environment.apiUrl`. Si un capítulo necesita cambiar el
  frontend, el capítulo está mal diseñado.
- **Autocontención estricta.** El track no remite a ningún otro curso del
  catálogo, ni siquiera al de contenedores. Todo lo necesario vive en `bea-02`.

### 15.4 Diccionario del dominio, lado servidor

Los nombres del dominio tienen que significar **exactamente lo mismo a los dos
lados del cable**. Las entidades salen de §5.2 de esta guía y del `db.json` del
mock; en el backend se escriben así:

| Concepto | Clase PHP | Tabla | Ruta |
|---|---|---|---|
| Cliente | `Client` | `clients` | `/clients` |
| Activo | `Asset` | `assets` | `/assets` |
| Plantilla de checklist | `Template` | `templates` | `/templates` |
| Inspección | `Inspection` | `inspections` | `/inspections` |
| Hallazgo | `Finding` | `findings` | `/inspections/:id/findings` |
| Certificado | `Certificate` | `certificates` | `/certificates` |

Tablas y columnas en `snake_case` (`template_version`, `issued_at`,
`valid_until`), clases en `PascalCase`, métodos en `camelCase`. **Los valores de
`status` no se traducen nunca**: son identificadores del sistema y viajan tal cual
al frontend, que es quien decide cómo se muestran.

### 15.5 Coherencia de la ficción, ampliada

§11 sigue mandando, con tres anclas nuevas que **ninguna fase del track puede
contradecir**:

- **`certcore-api` es de 2016**, es anterior a la aplicación Angular, y está
  descrita en la **Era 0** de `00-historia-del-sistema.md`.
- **La base se actualizó cuatro veces y la aplicación nunca.** Cadena
  `9.6 → 11 → 13 → 16`, movida por un proveedor con calendario propio.
- **Lumen no fue una tontería.** En 2016 fue la decisión sensata y se cobró
  durante años. El pecado fue elegirlo para *un servicio*, acertar, y que nadie
  volviera a decidir. Cualquier capítulo que se lea como *"Lumen es malo"* está mal
  escrito y se reescribe.
