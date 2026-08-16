# 📍 Prompts extendidos por fase
## Tutorial Angular 16 — Inspecciones y certificaciones

Cada sección es el prompt completo de la fase, listo para copiar al chat que la
redacta. Los valores están rellenados con los de `propuesta-fases-y-alcance.md`
§2 y §5; si alguna vez cambian allí, se cambian aquí después y nunca al revés.

**Un chat, un archivo.** Si un chat no produce entregable, o sobra o se salió de
alcance.

**Y una pieza de forma fija que ninguna fase puede olvidar:** el cierre termina
con el bloque 🏷️ que recuerda etiquetar la fase en git (`git tag -a fase-NN`),
enlazando `00-convencion-de-git-y-tags.md` sin reexplicarlo. Está especificado en
la guía de estilo §8.1 y en la plantilla, y va incluido en el recordatorio de
cada prompt de abajo. No es adorno: el tag `fase-00` es el único sitio donde
sobrevive el hola mundo que la Fase 1 retira, las ramas `incidente/NN` del
cuaderno salen del commit que cierra su fase, y la factura de cada deuda 💸 que
este track sí paga se lee con un `git diff` entre dos tags.

---

## # Fase 00

```markdown
Este es el chat de la **Fase 00 — 🛠️ Setup + hola mundo standalone** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `00-setup-hola-mundo.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 00 de 14 — 🛠️ Setup + hola mundo standalone
- Horas: **6h**
- Depende de: ninguna
- Habilita: Fase 1
- Apéndices de apoyo: A03, A04, A12
- Incidentes asociados: 01
- Estado: Obligatoria
- **Estilo de código de esta fase:** **nuevo** (standalone + `inject()`) — la fase enseña el destino antes que la herencia

## Alcance

- **Propósito (una línea):** Dejar el entorno levantado y un primer componente standalone que hable con un endpoint, con `strict` puesto desde el primer archivo.
- **Qué entra:** `.nvmrc` con Node 18.18.2, Angular CLI 16, proyecto base con `bootstrapApplication`, un componente standalone, formulario reactivo tipado, POST a un endpoint hardcodeado, `tsconfig` con `strict: true`.
- **Qué NO entra todavía:** routing, NgModules, servicios de estado, Material, mock server → Fases 1, 3, 4 y 6
- **Conceptos clave a introducir:** el CLI 16 y la estructura que genera, `bootstrapApplication` frente a `platformBrowserDynamic`, `ApplicationConfig`, formulario reactivo tipado mínimo, el primer `Object is possibly 'null'`.
- **Deuda técnica intencional 💸:** URL del backend hardcodeada en el componente.
  (Lo correcto es configuración por ambiente leída en runtime; **se paga en la Fase 13**, que es la tesis del curso — y hasta entonces el estudiante convive con ella a propósito.)
- **Pieza forense de esta fase:** consola, Network y source maps como fuente de verdad, y el primer vistazo a en qué miente cada uno.
  (enlazar a `forense-fase-00.md` cuando exista)
- **Ejercicios:** 28 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones.

## Pendientes que pueden bloquear esta fase

- Nada bloqueante: el stack está cerrado en `alcance-del-proyecto.md` §9.
- Decide y déjalo escrito: si el proyecto se genera con `--standalone` o se convierte a mano. Yo prefiero a mano, porque el estudiante ve qué archivo hace qué.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 6h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 01

```markdown
Este es el chat de la **Fase 01 — 🏗️ Estructura base con NgModules** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `01-estructura-base-ngmodules.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 01 de 14 — 🏗️ Estructura base con NgModules
- Horas: **8h**
- Depende de: Fase 0
- Habilita: Fases 2-13
- Apéndices de apoyo: A01, A04
- Incidentes asociados: 02
- Estado: Obligatoria
- **Estilo de código de esta fase:** **heredado** (NgModule + constructor) — es la herencia que llega, y se escribe tal cual

## Alcance

- **Propósito (una línea):** Montar el esqueleto de NgModules que CertCore trae de 2021, y explicar qué resolvía cada pieza antes de que existiera la alternativa moderna.
- **Qué entra:** `AppModule`, `CoreModule` con su guard de doble importación, `SharedModule`, módulos de feature con `RouterModule.forChild`, lazy loading con `loadChildren`, layout con router-outlet, y dónde vive la configuración por ambiente.
- **Qué NO entra todavía:** auth, mock API, estado, standalone → Fases 2, 3, 4 y 5
- **Conceptos clave a introducir:** NgModule y sus cuatro arrays, el árbol de inyectores, lazy loading y el chunk que genera, por qué existía `SharedModule`.
- **Deuda técnica intencional 💸:** El `SharedModule` que reexporta media librería de Material "por comodidad".
  (Lo correcto es importar lo que se usa; **se paga en la Fase 5**, y se mide la diferencia en el bundle. Es la primera deuda que el estudiante ve cobrarse de verdad.)
- **Pieza forense de esta fase:** errores de NgModule: `declarations` duplicadas, módulo no importado, y el lazy chunk que no aparece en la pestaña Network.
  (enlazar a `forense-fase-01.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones.

## Pendientes que pueden bloquear esta fase

- 🪦 **Árbol de módulos, cerrado.** Diez NgModules además de `AppModule`: `core`, `shared`, `layout` y siete features — `clients`, `assets`, `templates`, `inspections`, `certificates`, `dashboard` (los seis de esta fase) más `auth`, que crea la Fase 2. Todas las fases siguientes lo heredan, y la cuenta importa: la Fase 5 convierte uno y declara que **quedan nueve sin convertir**. Si alguien mueve `auth` dentro de `core`, ese número deja de ser cierto.
- 🪦 **Material, cerrado.** Entra en esta fase pero con lo mínimo: `ng add @angular/material@16.2.14` con **tema prefabricado**, y sólo los componentes del layout. El theming de verdad (`define-palette`, densidad, tipografía) lo fija la Fase 6, que es donde hay tablas y formularios que lo justifiquen. La deuda 💸 del `SharedModule` necesita que Material exista hoy; el resto no.
- 🪦 **El hola mundo de la Fase 0 se retira aquí** 🪦, con `git tag fase-00` antes de borrarlo. Esta fase queda de una sola generación, sin ningún punto de contacto 🧬 — el primero le pertenece a la Fase 2.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 8h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 02

```markdown
Este es el chat de la **Fase 02 — 🔐 Autenticación mínima** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `02-autenticacion.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 02 de 14 — 🔐 Autenticación mínima
- Horas: **6h**
- Depende de: Fase 1
- Habilita: Fases 3-13
- Apéndices de apoyo: A04, A06
- Incidentes asociados: 03
- Estado: Obligatoria
- **Estilo de código de esta fase:** **mixto 🧬** — la app es de NgModules y aquí entra el primer código funcional moderno

## Alcance

- **Propósito (una línea):** Poner login, token y protección de rutas, y de paso mostrar el primer punto donde el código nuevo se enchufa en una app de NgModules.
- **Qué entra:** login contra el mock, JWT en `localStorage`, `authGuard` funcional (`CanActivateFn`), `authInterceptor` funcional (`HttpInterceptorFn`), `provideHttpClient(withInterceptors([...]))` conviviendo con `HTTP_INTERCEPTORS`, y el manejo del 401.
- **Qué NO entra todavía:** roles y permisos finos, refresh token real, cierre de sesión sincronizado entre pestañas → fuera de alcance o ejercicio 🔥
- **Conceptos clave a introducir:** contexto de inyección y dónde `inject()` explota, guard funcional frente a guard de clase, interceptor como middleware, por qué un guard no es seguridad.
- **Deuda técnica intencional 💸:** Token en `localStorage` y sin refresh.
  (Lo correcto es cookie `httpOnly` con refresh del lado del servidor; **no se paga en este curso** porque no hay backend propio y el interceptor seguiría siendo el mismo. Se declara y se explica el riesgo.)
- **Pieza forense de esta fase:** debug de un interceptor funcional: dónde poner el breakpoint cuando `inject()` ya corrió, y cómo distinguir un 401 del interceptor de un 401 del backend.
  (enlazar a `forense-fase-02.md` cuando exista)
- **Ejercicios:** 28 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones.

## Pendientes que pueden bloquear esta fase

- Fija la forma del token del mock (payload, expiración) aquí; la Fase 3 la va a firmar con `jsonwebtoken` 9.0.2 y la Fase 12 la va a testear.
- Decide si el guard vive en `core/` o junto a la ruta que protege, y déjalo escrito como regla del proyecto.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 6h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 03

```markdown
Este es el chat de la **Fase 03 — 🧪 Mock API + Express caos** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `03-mock-api-caos.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 03 de 14 — 🧪 Mock API + Express caos
- Horas: **6h**
- Depende de: Fase 2
- Habilita: Fases 4-13
- Apéndices de apoyo: A03, A06
- Incidentes asociados: 04
- Estado: Obligatoria
- **Estilo de código de esta fase:** **nuevo** para los servicios de la app; el mock es Node y va aparte

## Alcance

- **Propósito (una línea):** Levantar el backend falso contra el que corre todo el curso, y construir el inyector de caos que hace que el estudiante vea fallar la aplicación de verdad.
- **Qué entra:** json-server 0.17.4 con el `db.json` del modelo de referencia, Express 4.18.2 como envoltorio, el middleware de caos construido paso a paso (latencia, 500 intermitente, payload malformado, CORS roto, token expirado, timeout), servicios `*ApiService` tipados, y los scripts npm.
- **Qué NO entra todavía:** paginación del lado del servidor, caché HTTP, reintentos automáticos, estado en la app → Fase 4 y ejercicios 🔥
- **Conceptos clave a introducir:** `HttpClient` tipado, `catchError` y qué devolver, el `unknown` de un payload que no confías, `HttpErrorResponse`, y por qué el caos se construye y no se copia.
- **Deuda técnica intencional 💸:** El mock devuelve el objeto completo en cada respuesta, sin proyecciones ni paginación.
  (Lo correcto es paginar y proyectar; **no se paga**: paginar el mock añadiría trabajo de backend que no enseña nada de Angular, y se dice así.)
- **Pieza forense de esta fase:** la SPA bajo caos: qué pinta tiene un 500 intermitente frente a un CORS roto frente a un timeout, y cuál de los tres miente en la consola.
  (enlazar a `forense-fase-03.md` cuando exista)
- **Ejercicios:** 26 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones.

## Pendientes que pueden bloquear esta fase

- 🪦 **Flags del caos, cerrados.** `CHAOS=latency|error|malformed|cors|expired|timeout`, combinables por coma, con `CHAOS_RATE` (0.3 por defecto) y `CHAOS_DELAY_MS` (2500). **El caos no toca `/auth/login`, salvo `expired`**: si no puedes entrar, no puedes diagnosticar. Un flag desconocido impide que el mock arranque, a propósito.
- 🪦 **Restauración, cerrada.** `npm run seed` es `node mock/seed.js`, que copia `mock/db.seed.json` sobre `mock/db.json`. Los dos archivos están versionados; la diferencia con `git checkout -- mock/db.json` está en `00-convencion-de-git-y-tags.md`.
- 🪦 **Dos correcciones al modelo de `alcance-del-proyecto.md` §5.1**, ya aplicadas allí: el `id` de una plantilla es compuesto (`elevator-annual-v2`) con el identificador lógico en `templateId` —si no, la v1 y la v2 colisionan en json-server—, y `findings` es una colección de primer nivel con `inspectionId`.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 6h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 04

```markdown
Este es el chat de la **Fase 04 — 🧠 Estado con servicios y BehaviorSubject** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `04-estado-servicios.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 04 de 14 — 🧠 Estado con servicios y BehaviorSubject
- Horas: **7h**
- Depende de: Fase 3
- Habilita: Fases 6-13
- Apéndices de apoyo: A06, A07
- Incidentes asociados: 05
- Estado: Obligatoria
- **Estilo de código de esta fase:** **nuevo** — es el patrón que sostiene el resto del curso

## Alcance

- **Propósito (una línea):** Fijar el patrón de estado de CertCore —un servicio por feature con `BehaviorSubject` privado— y el ciclo de vida de las suscripciones, que es donde nace la mitad de las fugas del curso.
- **Qué entra:** `*StateService` con `BehaviorSubject` privado y `Observable` público de sólo lectura, métodos que reemplazan el estado en vez de mutarlo, la distinción `*StateService` / `*ApiService`, `providedIn: 'root'` frente a provider de ruta, `takeUntilDestroyed`, `async` pipe, `shareReplay` y sus trampas.
- **Qué NO entra todavía:** NgRx u otra librería de store (no está en CertCore), signals como estado (Fase 12 y A11), estado persistido en disco → fuera de alcance
- **Conceptos clave a introducir:** estado compartido en memoria, quién se suscribe y quién se desuscribe, por qué un `BehaviorSubject` en un servicio raíz sobrevive a todas las navegaciones, inmutabilidad y `OnPush`.
- **Deuda técnica intencional 💸:** No hay inmutabilidad forzada: el servicio expone el array y un componente lo muta.
  (Lo correcto es `readonly` en el modelo y copias al actualizar; **se paga en la Fase 6**, cuando la lista deja de refrescarse con `OnPush` y el estudiante ve el costo con sus propios ojos.)
- **Pieza forense de esta fase:** cazar una suscripción viva: por qué la lista se actualizó dos veces, y cómo se ve una fuga en el panel Memory frente a cómo se ve en el comportamiento.
  (enlazar a `forense-fase-04.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones.

## Pendientes que pueden bloquear esta fase

- 🪦 **Forma del estado, cerrada.** Una interfaz genérica `FeatureState<T>` con `items: T[]`, `selected: T | null`, `loading: boolean` y `error: string | null`. **Interfaz genérica sí, clase base no**: una `AbstractStateService<T>` ahorra treinta líneas y mete herencia donde peor envejece. Las Fases 6 a 11 la heredan tal cual.
- 🪦 **El error vive en el estado**, como mensaje ya traducido por `toApiError` y no como `ApiError`: la Fase 11 necesita pintarlo, no inspeccionarlo.
- 🪦 **La 💸 de inmutabilidad, redefinida** —y hay que leerla así, porque la formulación original era imposible—. Los modelos de la Fase 3 son `readonly` de arriba abajo, así que un `items.push(...)` sobre lo que devuelve un `*ApiService` **no compila** y la deuda no existiría. Lo que se expone mutable es el **contenedor de estado**: `items: T[]`, sin `readonly` ni en la propiedad ni en el array. El `StateService` copia al escribir y luego entrega el array vivo. La Fase 6 lo cobra con el caso clásico: un componente hace `state.items.push(created)`, ni la referencia del array ni la del estado cambian, nadie emite, y con `OnPush` la lista no se refresca.
- **Vienen dos 💸 declaradas con esta fase como pagadora, y las dos hay que saldarlas aquí o reclasificarlas explicando el porqué:**
  - **De la Fase 2** — `ShellComponent` llama a `authService.getCurrentUser()` desde la plantilla y, con detección de cambios por defecto, decodifica el JWT entero en cada ciclo. Se salda exponiendo `currentUser$` en `AuthService` y pintando con el pipe `async`. El ejercicio 12 de la Fase 2 dejó el número de llamadas anotado en `deuda.md`: la prueba de que se pagó es que ese número baja.
  - **De la Fase 3** — `TemplateListComponent` habla con `TemplateApiService` directamente y guarda el resultado en un campo suyo, con `Subscription` y `ngOnDestroy` al estilo 2021. Se salda con `TemplateStateService`. Ojo: el componente es heredado, así que el fix va en su estilo salvo que esta fase declare lo contrario.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 7h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 05

```markdown
Este es el chat de la **Fase 05 — 🧩 Standalone conviviendo con NgModules** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `05-standalone-convivencia.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 05 de 14 — 🧩 Standalone conviviendo con NgModules
- Horas: **6h**
- Depende de: Fase 4
- Habilita: Fases 6-13
- Apéndices de apoyo: A01, A04
- Incidentes asociados: 06, 07
- Estado: Obligatoria
- **Estilo de código de esta fase:** **mixto 🧬 y deliberado** — es el tema de la fase

## Alcance

- **Propósito (una línea):** Aprender a vivir con las dos generaciones en el mismo repositorio: convertir un módulo de feature a standalone, dejar el resto intacto, y fijar la regla del proyecto.
- **Qué entra:** conversión del módulo que la Fase 6 va a necesitar, `imports` en el decorador, `loadComponent` en las rutas, importar un standalone desde un NgModule y al revés, providers de ruta, el pago de la deuda 💸 del `SharedModule` de la Fase 1 medido en el bundle.
- **Qué NO entra todavía:** migrar el resto de módulos (queda como ejercicio 🔥 y como decisión de proyecto), `provideRouter` completo, control flow nuevo → Fase 12 y A11
- **Conceptos clave a introducir:** qué es realmente un standalone component, cómo se resuelve un provider en cada caso, `importProvidersFrom` como puente, y la regla: código nuevo estilo nuevo, código heredado se toca lo mínimo.
- **Deuda técnica intencional 💸:** Quedan nueve módulos sin convertir y no se convierten.
  (Lo correcto sería un plan de migración; **no se paga en este curso** a propósito: el objetivo es mantener, no migrar, y la convivencia es exactamente lo que el estudiante va a encontrar el lunes.)
- **Pieza forense de esta fase:** `NullInjectorError` en standalone frente al mismo error en NgModule: no se parecen, y distinguirlos ahorra media tarde.
  (enlazar a `forense-fase-05.md` cuando exista)
- **Ejercicios:** 28 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones,
  incluyendo **al menos dos de estilo 🧬** (dado un archivo, decidir si el fix
  va en estilo nuevo o heredado y justificarlo).

## Pendientes que pueden bloquear esta fase

- Elige **qué** módulo se convierte y justifícalo con una frase; la Fase 6 depende de esa elección. El árbol lo fijó la Fase 1: diez NgModules además de `AppModule` (`core`, `shared`, `layout` + siete features), así que convertir uno deja **nueve** — el número que usa el alcance de abajo. Si conviertes más de uno, corrígelo.
- Mide el bundle antes y después con `ng build --stats-json` y deja los dos números escritos. Sin números, el pago de la deuda es una afirmación.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 6h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 06

```markdown
Este es el chat de la **Fase 06 — 👥 Clientes y activos** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `06-clientes-activos.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 06 de 14 — 👥 Clientes y activos
- Horas: **8h**
- Depende de: Fase 5
- Habilita: Fases 7-11
- Apéndices de apoyo: A01, A05
- Incidentes asociados: 07 (**lo reserva la Fase 5**; esta fase lo hereda como
  asociado y no le da un ID nuevo)
- Estado: Obligatoria
- **Estilo de código de esta fase:** **nuevo** para las vistas de esta fase; toca un NgModule heredado sólo de refilón 🧬

## Alcance

- **Propósito (una línea):** El primer CRUD completo del curso: clientes y sus activos, con formularios reactivos tipados, Material 16 y el servicio de estado de la Fase 4 haciendo su trabajo.
- **Qué entra:** listado con `mat-table`, alta y edición con `FormGroup<T>`, validación síncrona y asíncrona, borrado con confirmación en `MatDialog`, `MatSnackBar` para el resultado, `OnPush` en todas las vistas nuevas, y el pago de la deuda 💸 de inmutabilidad de la Fase 4 — que es concretamente ésta: `FeatureState<T>` expone `items: T[]` mutable, un componente lo muta en sitio, y con `OnPush` la lista deja de refrescarse. Se salda poniendo `readonly` hasta la salida y reemplazando en vez de mutar, y se demuestra con la pantalla que antes no repintaba.
- **Qué NO entra todavía:** plantillas, inspecciones, hallazgos, certificados → Fases 7 a 10; trazabilidad completa de cambios → se difiere y se declara
- **Conceptos clave a introducir:** `FormGroup<T>` y `nonNullable`, el `mat-form-field` de MDC y qué cambió respecto a Material 14, `OnPush` y cuándo no repinta, validadores tipados.
- **Deuda técnica intencional 💸:** La regla de negocio de "un activo no puede cambiar de cliente" vive en el componente.
  (Lo correcto es que viva en el servicio; **se paga en la Fase 9**, cuando la misma clase de regla aparece por tercera vez y ya no se puede sostener el argumento de la prisa.)
- **Pieza forense de esta fase:** reproducir un bug de usuario desde un ticket vago, sin acceso a producción: del "no me deja guardar" al control que está `invalid` y no se ve.
  (enlazar a `forense-fase-06.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones,
  incluyendo **al menos dos de estilo 🧬** (dado un archivo, decidir si el fix
  va en estilo nuevo o heredado y justificarlo).

## Pendientes que pueden bloquear esta fase

- Fija el tema de Material aquí (paleta, densidad, tipografía) y no lo toques en fases posteriores.
- Decide si el formulario es una ruta o un diálogo. Las Fases 7 y 8 van a copiar esa decisión, así que elígela pensando en un formulario denso.
- **Lo que la Fase 5 te dejó puesto, y que cambia cómo se escribe esta fase:** `clients` es el único módulo convertido —`clients.module.ts` y `clients-routing.module.ts` ya no existen—, así que las vistas de clientes son standalone con `imports` propios y `OnPush`, y sus rutas viven en `CLIENTS_ROUTES` (`clients.routes.ts`) con `loadComponent`. `assets` sigue siendo un `NgModule` heredado, y sus vistas nuevas se escriben standalone y se enganchan por el `imports` del módulo 🧬. `SharedModule` **ya no reexporta** `MatTableModule`, `MatDialogModule` ni `MatSnackBarModule`: cada componente que los use los importa, y los heredados los importan en su propio módulo. Existen además `EmptyStateComponent` (standalone, `shared/empty-state/`, sin pasar por `SharedModule`) y el token de ruta `CLIENT_LIST_PAGE_SIZE`, que esta fase conecta a `mat-paginator`. `ClientListComponent` es hoy un cascarón con la `mat-table` montada y sin filas: esta fase le pone `ClientStateService` y los datos.
- **Dos límites del patrón de la Fase 4 llegan sin resolver, y aquí hay una búsqueda que los provoca de forma natural:** las cargas concurrentes no se ordenan —gana la que llega última, no la última pedida— y el `loading: boolean` se queda mal cuando hay dos peticiones en vuelo. La Fase 4 los mostró a propósito (sus ejercicios 17 y 23) y dejó la solución para aquí: `switchMap` para leer, y la advertencia de que **`switchMap` es la respuesta correcta para leer y la equivocada para escribir** — cancelar un `POST` que ya salió no deshace nada en el servidor.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 8h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 07

```markdown
Este es el chat de la **Fase 07 — 📋 Plantillas versionadas** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `07-plantillas-versionadas.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 07 de 14 — 📋 Plantillas versionadas
- Horas: **14h**
- Depende de: Fase 6
- Habilita: Fases 8-11
- Apéndices de apoyo: A05, A06, A07
- Incidentes asociados: 08, 09
- Estado: Obligatoria ⭐
- **Estilo de código de esta fase:** **nuevo**

## Alcance

- **Propósito (una línea):** Construir el corazón de CertCore: la plantilla de checklist como entidad versionada, donde publicar una v2 no puede alterar ni un píxel de lo ejecutado con la v1.
- **Qué entra:** modelo `template` con `version`, `validFrom`, `validUntil` e `items[]`; el editor que crea la v2 a partir de la v1; publicación y retiro; `resolveTemplateVersion(templateId, date)` con sus casos borde; el listado de versiones; y el invariante escrito, repetido y testeado a mano.
- **Qué NO entra todavía:** el motor de render del checklist → Fase 8; hallazgos derivados → Fase 9; migración de respuestas entre versiones → fuera de alcance, y se dice por qué
- **Conceptos clave a introducir:** versionado por fecha frente a versionado por referencia, el invariante de histórico, por qué "la vigente" es una pregunta con fecha y no una propiedad del objeto.
- **Deuda técnica intencional 💸:** Las versiones se guardan completas, duplicando los ítems que no cambiaron.
  (Lo correcto sería guardar diffs; **no se paga**: el diff ahorra almacenamiento y multiplica por tres la clase de bugs que este curso quiere evitar. Se declara como decisión, no como descuido.)
- **Pieza forense de esta fase:** debug del versionado: qué versión se resolvió, con qué fecha y por qué. Y su gemela malvada — *"¿por qué esta inspección de hace un año se ve con la plantilla nueva?"*, que sí es un bug.
  (enlazar a `forense-fase-07.md` cuando exista)
- **Ejercicios:** 35 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones,
  incluyendo **al menos dos de estilo 🧬** (dado un archivo, decidir si el fix
  va en estilo nuevo o heredado y justificarlo).

## Pendientes que pueden bloquear esta fase

- Fija la firma exacta de `resolveTemplateVersion` aquí: la Fase 8, la 9, la 10 y cuatro incidentes la citan.
- **Lo que la Fase 6 te dejó puesto:** `FeatureState<T>` es ahora `readonly items: readonly T[]` —la 💸 de inmutabilidad quedó pagada, y el estado de esta fase respeta la misma regla—; el tema de Material está **cerrado** (Indigo/Pink compilado en `styles.scss`, densidad −1) y no se toca; los formularios se escriben tipados con la nulabilidad decidida (`FormGroup<T>` + `nonNullable`, nunca un `| null` heredado); el formulario vive **en una ruta propia** (`/new`, `/:id/edit`) y no en un diálogo, decisión tomada pensando en el formulario denso de la Fase 8; y ya existen dos piezas standalone reutilizables en `shared/` sin pasar por `SharedModule`: `EmptyStateComponent` y `ConfirmDialogComponent` (que devuelve `boolean` y no decide nada). Para leer se usa `switchMap`; para escribir, **no** — la Fase 6 lo dejó escrito con su porqué.
- Deja escrito qué pasa con `validUntil: null` y qué pasa si dos versiones se solapan. Los casos borde son el material de los incidentes 08 y 09.
- **Tu servicio de estado no va a encajar en el molde de la Fase 4, y eso es una oportunidad, no un problema.** `FeatureState<T>` sirve para "cargar una lista"; resolver qué versión de plantilla aplica a una fecha no es eso. La Fase 4 renunció explícitamente a una clase base genérica **pensando en esta fase**: aprovéchalo en vez de forzar el patrón, y di en voz alta en qué se aparta y por qué.
- ⚠️ **Dependencia con la Fase 10, y va en la dirección incómoda.** Resolver por fecha necesita una zona horaria de referencia, y quien la fija en un solo sitio del código es la Fase 10. La Fase 4 esquivó el tema a propósito (su derivado compara números de versión, no fechas). Si escribes esta fase antes que la 10, **fija tú la constante y avisa en tus 📌** para que la 10 la reutilice en vez de crear una segunda.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 14h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 08

```markdown
Este es el chat de la **Fase 08 — 📝 Formulario dinámico desde plantilla** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `08-formulario-dinamico.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 08 de 14 — 📝 Formulario dinámico desde plantilla
- Horas: **12h**
- Depende de: Fase 7
- Habilita: Fases 9-11
- Apéndices de apoyo: A05, A06
- Incidentes asociados: 10, 11
- Estado: Obligatoria ⭐
- **Estilo de código de esta fase:** **nuevo**

## Alcance

- **Propósito (una línea):** Generar el formulario de la inspección en runtime a partir de una plantilla, con tipos, sin perder respuestas y sin que `valueChanges` se muerda la cola.
- **Qué entra:** construcción de `FormGroup` en runtime desde `items[]`, validadores derivados de `photoRequired` y `criteria`, guardado de respuestas con su `templateVersion`, autosave con `debounceTime` + `distinctUntilChanged`, estado `dirty` que sobrevive a la navegación, y el guard de salida.
- **Qué NO entra todavía:** evidencia fotográfica real y sincronización offline → fuera de alcance; cálculo de severidad → Fase 9
- **Conceptos clave a introducir:** `FormRecord` y controles creados en runtime, tipado de un formulario que no se conoce en compilación, el ciclo `valueChanges` → guardado → `patchValue` y cómo se rompe.
- **Deuda técnica intencional 💸:** El autosave guarda el formulario entero en cada cambio, no el delta.
  (Lo correcto es un PATCH por respuesta; **se paga parcialmente en la Fase 11** al medir el costo, y se deja escrito por qué el delta completo requeriría un backend que el curso no tiene.)
- **Pieza forense de esta fase:** formularios dinámicos: el bucle infinito de `valueChanges`, el `FormControl` huérfano que quedó tras cambiar de plantilla, y `ExpressionChangedAfterItHasBeenCheckedError` en su hábitat natural.
  (enlazar a `forense-fase-08.md` cuando exista)
- **Ejercicios:** 35 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones,
  incluyendo **al menos dos de estilo 🧬** (dado un archivo, decidir si el fix
  va en estilo nuevo o heredado y justificarlo).

## Pendientes que pueden bloquear esta fase

- **Lo que la Fase 7 te dejó puesto, y es la primera línea que escribes:** para pintar una inspección **existente** se pide `templateApi.getByVersion(inspection.templateId, inspection.templateVersion)` — **nunca** `resolveTemplateVersion`, que sirve para EMPEZAR una inspección y resuelve por fecha. Confundirlas es el incidente 08. Están además disponibles: `resolveTemplateVersion(versions, day): TemplateResolution` (unión discriminada `resolved` / `none` / `ambiguous`, función pura en `core/domain/`), `TemplateFamily` con `groupIntoFamilies`, `core/time/business-day.ts` con `BusinessDay`, `CERTCORE_TIME_ZONE_OFFSET`, `toBusinessDay()`, `todayInBusinessZone()` y `addDays()`, y un `TemplateStateService` cuyo estado es un `TemplateState` propio (`versions`, `selectedFamilyId`) y no `FeatureState<T>`. `TemplatesModule` sigue siendo heredado y aloja pantallas standalone por su `imports` 🧬.
- **Decisión ya tomada que esta fase respeta:** una respuesta cuyo ítem fue retirado en una versión posterior **no se borra**; se muestra como perteneciente a un ítem retirado. Sale del ejercicio 23 de la Fase 7 y la Fase 9 la hereda igual.
- **El `CanDeactivate` que la Fase 6 dejó como ejercicio 🔥 deja de ser opcional aquí:** un formulario dinámico de veinte controles que se pierde al navegar es un ticket garantizado.
- Decide si el formulario se reconstruye o se parchea cuando cambia la plantilla. Es la decisión que produce el incidente 10; elígela y déjala escrita.
- Fija la periodicidad del autosave (`debounceTime`) con un número y un porqué; la Fase 12 va a testear ese número.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 12h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 09

```markdown
Este es el chat de la **Fase 09 — ⚠️ Hallazgos y severidad** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `09-hallazgos-severidad.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 09 de 14 — ⚠️ Hallazgos y severidad
- Horas: **6h**
- Depende de: Fase 8
- Habilita: Fases 10-11
- Apéndices de apoyo: A05, A07
- Incidentes asociados: 12, 13
- Estado: Obligatoria
- **Estilo de código de esta fase:** **nuevo**

## Alcance

- **Propósito (una línea):** Derivar hallazgos de las respuestas del checklist, calcular severidad, y hacer que un `critical` bloquee de verdad la emisión del certificado.
- **Qué entra:** modelo `finding` con `severity`, derivación desde `nonComplianceSeverity` de la plantilla, agregación por inspección, la regla de bloqueo, el estado `rejected`, y el pago de la deuda 💸 de la Fase 6 moviendo las reglas al servicio.
- **Qué NO entra todavía:** workflow de aprobación multi-nivel, plan de acción correctiva, notificaciones → fuera de alcance o ejercicio 🔥
- **Conceptos clave a introducir:** dato derivado frente a dato guardado, `null` frente a `undefined` frente a campo ausente bajo `strict`, unions discriminadas para la severidad.
- **Deuda técnica intencional 💸:** Los hallazgos se recalculan en cada lectura en vez de persistirse.
  (Lo correcto depende del negocio: si la plantilla cambió, ¿el hallazgo histórico cambia? **Se resuelve aquí**, no se difiere, porque contradecir el invariante de la Fase 7 sería un bug de diseño.)
- **Pieza forense de esta fase:** `null` frente a `undefined` bajo `strict`: el hallazgo que existía y no bloqueó nada porque alguien comparó con `==`.
  (enlazar a `forense-fase-09.md` cuando exista)
- **Ejercicios:** 26 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones,
  incluyendo **al menos dos de estilo 🧬** (dado un archivo, decidir si el fix
  va en estilo nuevo o heredado y justificarlo).

## Pendientes que pueden bloquear esta fase

- **Lo que traen las Fases 6, 7 y 8:** el pago de la 💸 de la Fase 6 es mover al servicio la regla "un activo no puede cambiar de cliente", que hoy vive en `AssetFormComponent` como un control deshabilitado —y de paso arreglar que deshabilitar un control lo saca de `form.value`—. **Son tres reglas a mudar, no una:** la Fase 8 dejó en pantallas otras dos, `templateIdForAssetType` (qué familia de plantilla corresponde a cada tipo de activo, en `InspectionStartComponent`) y la de completado (`computeProgress().canComplete`), y las tres son la misma clase de regla. De la Fase 7 heredas que una respuesta de un ítem **retirado** en una versión posterior no se borra ni se ignora: se trata como perteneciente a un ítem retirado, y eso afecta a cómo se derivan los hallazgos de una inspección vieja.
- **Herencia incómoda de la Fase 8, y es tuya:** hoy una inspección `approved` se puede abrir y editar, y el `alcance-del-proyecto.md` §5 dice que aprobar es irreversible. La Fase 8 lo dejó como ejercicio 🔥 porque los estados `approved` / `rejected` los introduce esta fase. Decide dónde vive el bloqueo —guard, formulario o estado— y si además debería estar en el mock.
- **Lo que la Fase 8 ya guarda y esta fase deriva:** `answers` con `answer`, `evidenceUrl` y `note`, más el `nonComplianceSeverity` que la plantilla trae desde la Fase 3. Están escritas y son puras `buildAnswerForm`, `toAnswers`, `computeProgress` y `findOrphanAnswers` en `core/domain/`.
- Decide si la severidad puede subir manualmente y quién puede hacerlo. Afecta a la trazabilidad y al incidente 13.
- Deja escrito qué pasa con un hallazgo `critical` en una inspección ya aprobada. Es la pregunta que produce el ticket más incómodo del curso.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 6h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 10

```markdown
Este es el chat de la **Fase 10 — 📜 Certificados, vigencia y PDF** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `10-certificados-vigencia.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 10 de 14 — 📜 Certificados, vigencia y PDF
- Horas: **8h**
- Depende de: Fase 9
- Habilita: Fase 11
- Apéndices de apoyo: A08
- Incidentes asociados: 14, 15
- Estado: Obligatoria
- **Estilo de código de esta fase:** **nuevo**

## Alcance

- **Propósito (una línea):** Emitir el certificado sólo cuando corresponde, calcular su vigencia con zona horaria explícita, y generarlo en PDF en el cliente.
- **Qué entra:** emisión bloqueada por hallazgo `critical`, `validFrom` y `validUntil` con offset, el estado `expiring`, la renovación programada, el PDF con jsPDF 2.5.1 (fuentes con acentos, tabla de hallazgos con `jspdf-autotable`), y la carga diferida de la librería.
- **Qué NO entra todavía:** firma digital real, envío por correo, registro nacional de certificaciones → fuera de alcance o ejercicio 🔥
- **Conceptos clave a introducir:** fechas con offset frente a UTC frente a hora local, a qué hora del día vence algo, generación de documentos en el navegador y qué le hace al bundle.
- **Deuda técnica intencional 💸:** El PDF se arma leyendo el estado de la vista, no volviendo a pedir el dato.
  (Lo correcto es reconstruir desde la fuente en el momento de emitir; **se paga aquí mismo** tras mostrar el bug del incidente 14, porque un certificado con datos viejos no es una deuda tolerable.)
- **Pieza forense de esta fase:** zona horaria en producción: el certificado que venció ayer para el servidor y hoy para el usuario. Nunca es un bug de fechas, es un bug de decidir a qué hora vence algo.
  (enlazar a `forense-fase-10.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones,
  incluyendo **al menos dos de estilo 🧬** (dado un archivo, decidir si el fix
  va en estilo nuevo o heredado y justificarlo).

## Pendientes que pueden bloquear esta fase

- **Herencia de la Fase 3, y es material tuyo:** en `db.seed.json` el `status` de un certificado está **almacenado** y debería derivarse de `validUntil` contra el reloj. `CERT-2024-000502` dice `"valid"` con una vigencia ya vencida. Es un antipatrón puesto a propósito y esta fase es la que lo desactiva: el estado pasa a calcularse. Si no lo haces aquí, la semilla queda mintiendo para el resto del curso.
- ⚠️ **La zona horaria ya está fijada: esta fase EXTIENDE ese archivo, no crea otro.** La Fase 7 dejó `CERTCORE_TIME_ZONE_OFFSET` y `toBusinessDay()` en `src/app/core/time/business-day.ts`, junto con `todayInBusinessZone()` y `addDays()`. Allí los días son de calendario (`'YYYY-MM-DD'`, sin hora) porque las vigencias de plantilla no la llevan; la de un certificado **sí** (`validUntil: '2025-02-10T23:59:59-05:00'`), así que lo que falte se añade a ese mismo archivo. Si la constante aparece en dos sitios, ya tienes el bug — y es el más caro y el más difícil de ver del curso.
- Decide si jsPDF se importa estático o diferido, y mide el bundle en los dos casos.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 8h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 11

```markdown
Este es el chat de la **Fase 11 — 📊 Dashboard y alertas** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `11-dashboard-alertas.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 11 de 14 — 📊 Dashboard y alertas
- Horas: **6h**
- Depende de: Fase 10
- Habilita: Fase 12
- Apéndices de apoyo: A06, A07
- Incidentes asociados: 16
- Estado: Obligatoria
- **Estilo de código de esta fase:** **nuevo**

## Alcance

- **Propósito (una línea):** Poner la vista que mira el coordinador: certificados por vencer a 30/60/90 días, tasa de rechazo por inspector, hallazgos frecuentes, y activos vencidos.
- **Qué entra:** agregaciones con `combineLatest`, gráficos con ng2-charts 4 + Chart.js 4, tarjetas de KPI, refresco periódico, y `trackBy` en las listas largas.
- **Qué NO entra todavía:** BI real, exportación a Excel, filtros persistidos por usuario → fuera de alcance o ejercicio 🔥
- **Conceptos clave a introducir:** derivar vistas del estado sin duplicarlo, el costo de recalcular en cada emisión, `ChangeDetectionStrategy` y cuándo culparla, `trackBy`.
- **Deuda técnica intencional 💸:** Los KPI se calculan en el cliente sobre la colección completa.
  (Lo correcto es agregar en el servidor; **no se paga** porque el mock no lo permite, y se declara con el número: a partir de cuántos registros esto deja de ser aceptable, medido.)
- **Pieza forense de esta fase:** performance del dashboard: cuándo culpar a `ChangeDetectionStrategy` y cuándo el culpable es un `shareReplay` sin `refCount` o un gráfico que se redibuja entero.
  (enlazar a `forense-fase-11.md` cuando exista)
- **Ejercicios:** 26 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones,
  incluyendo **al menos dos de estilo 🧬** (dado un archivo, decidir si el fix
  va en estilo nuevo o heredado y justificarlo).

## Pendientes que pueden bloquear esta fase

- **La semilla de la Fase 3 trae sólo dos certificados**, y el panel de "por vencer a 30/60/90 días" necesita más para mostrar algo. Amplíala si hace falta, pero **en `mock/db.seed.json`, nunca en `mock/db.json`**, y avisa en tus 📌 de que la semilla cambió: hay ocho fases construidas encima.
- **La 💸 de la Fase 8 se paga a medias aquí, y hay que medirla:** el autosave manda el array `answers` **entero** en cada guardado. Con el volumen que esta fase necesita para el dashboard, mide cuánto pesa un guardado con una plantilla larga y cuántos salen en una jornada. El ejercicio 31 de la Fase 8 ya deja diseñado el `PATCH` por respuesta; aquí sólo hay que poner el número que justifica —o descarta— escribirlo.
- **El mismo problema de recálculo, dos veces:** la Fase 8 recalcula el progreso entero en cada emisión de `valueChanges` y este dashboard va a recalcular agregaciones en cada emisión del estado. Es la misma decisión (memorizar, `shareReplay`, o recalcular y medir) y conviene resolverla con el mismo criterio en los dos sitios, no con dos.
- **Candidata a panel, heredada de la Fase 7:** comparar dos versiones de una plantilla —qué ítems se añadieron, cuáles cambiaron de título o de severidad, cuáles desaparecieron— es lo primero que pide quien audita un cambio normativo, y con `groupIntoFamilies` y `TemplateFamily` ya escritos cuesta poco. Allí quedó como ejercicio 🔥.
- Decide cuántos registros lleva el `db.json` de demostración. El incidente 16 necesita un volumen donde el problema se note.
- Deja escrito el umbral de "por vencer" en un solo sitio; es la clase de constante que termina duplicada en tres.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 6h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 12

```markdown
Este es el chat de la **Fase 12 — ✅ Testing desde cero + coverage** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `12-testing-coverage.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 12 de 14 — ✅ Testing desde cero + coverage
- Horas: **8h**
- Depende de: Fase 11
- Habilita: Fase 13
- Apéndices de apoyo: A05, A06, A11
- Incidentes asociados: 17, 20
- Estado: Obligatoria
- **Estilo de código de esta fase:** **mixto 🧬** — hay que testear las dos generaciones, y no se testean igual

## Alcance

- **Propósito (una línea):** Montar la suite desde cero —CertCore no tiene un solo spec— y llegar a coverage medible, con foco en el test de regresión que reproduce un bug antes del fix.
- **Qué entra:** Jasmine 4.6 y Karma 6.4, `TestBed` para standalone y para NgModule 🧬, testeo de servicios de estado con marbles simples, `HttpTestingController`, testeo de guards e interceptors funcionales, coverage al 80% con exclusiones justificadas, y el test de regresión del invariante de plantillas.
- **Qué NO entra todavía:** e2e con Playwright (fuera de alcance del curso), mutation testing, CI real → se declaran y se descartan con motivo
- **Conceptos clave a introducir:** qué merece test en un sistema que sólo recibe hotfixes, test de regresión antes del fix, cómo se testea un `BehaviorSubject`, y por qué un standalone se testea distinto a un componente declarado.
- **Deuda técnica intencional 💸:** Coverage al 80% con exclusiones, no al 100%.
  (Lo correcto depende del equipo; **no se paga**: se declara el número, se listan las exclusiones y se explica que subirlo sin criterio produce tests que sólo prueban que el código existe.)
- **Pieza forense de esta fase:** el test de regresión que reproduce el bug **antes** del fix, y cómo se escribe uno para un bug intermitente.
  (enlazar a `forense-fase-12.md` cuando exista)
- **Ejercicios:** 30 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones,
  incluyendo **al menos dos de estilo 🧬** (dado un archivo, decidir si el fix
  va en estilo nuevo o heredado y justificarlo).

## Pendientes que pueden bloquear esta fase

- **Empieza por lo que ya es puro, que es más de lo que parece.** Las Fases 7 y 8 dejaron escritas a propósito funciones sin `TestBed`: `resolveTemplateVersion` con su tabla de ocho casos borde (Fase 7 §5.3), `appliesOn`, `groupIntoFamilies`, `toBusinessDay` / `addDays`, y `buildAnswerForm`, `toAnswers`, `computeProgress` y `findOrphanAnswers` (Fase 8). Son la mitad del coverage y no necesitan navegador.
- **`AUTOSAVE_DEBOUNCE_MS` está exportada para que la testees, no para que la copies.** Un test que espere 1500 ms de verdad tarda 1500 ms; el que corresponde usa `fakeAsync` y `tick`. La Fase 8 fijó el número con su porqué escrito.
- Aquí va la **pincelada de signals** y del control flow de la 17: como lectura, con un ejemplo, y con la advertencia de que en 16 son experimentales. Enlaza a A11 y no lo conviertas en la fase de signals.
- Decide las exclusiones de coverage y escríbelas en el `karma.conf`, no en la prosa.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 8h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 13

```markdown
Este es el chat de la **Fase 13 — 🚚 Build, despliegue y cierre** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `13-build-despliegue.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 13 de 14 — 🚚 Build, despliegue y cierre
- Horas: **7h**
- Depende de: Fase 12
- Habilita: Fase 14 (🔥 opcional)
- Apéndices de apoyo: A03, A09, A12
- Incidentes asociados: 18, 19
- Estado: Obligatoria
- **Estilo de código de esta fase:** **nuevo** en la app; el resto es Docker, nginx y shell

## Alcance

- **Propósito (una línea):** Cerrar el curso donde se cierra el círculo: la misma imagen levantada dos veces con configuración distinta, comportándose distinto — que es la mitad de los "funciona en UAT y no en PROD" del mundo.
- **Qué entra:** `ng build` de producción y sus presupuestos, Dockerfile multi-stage (`node:18.18.2-alpine` → `nginx:1.25-alpine`), `try_files` y el 404 al recargar una ruta profunda, `assets/config.json` leído con `APP_INITIALIZER`, el `entrypoint.sh` que lo reescribe desde variables de entorno, source maps en producción, el pago de la deuda 💸 de la Fase 0, y el checklist de hotfix de una página.
- **Qué NO entra todavía:** orquestación, CI/CD real, CDN, SSR → Fase 14 🔥 y fuera de alcance
- **Conceptos clave a introducir:** configuración horneada en build frente a inyectada en arranque, `APP_INITIALIZER` y por qué bloquea el arranque, un stack trace minificado con y sin source maps.
- **Deuda técnica intencional 💸:** La imagen corre nginx como root en el puerto 80.
  (Lo correcto es non-root en un puerto alto; **no se paga aquí**, y A09 explica por qué en el cluster real de una empresa eso es exactamente lo que va a fallar. Es una deuda con destino documentado fuera del curso.)
- **Pieza forense de esta fase:** diff de ambientes, config horneada contra inyectada, y leer un stack trace minificado hasta la línea del `.ts`.
  (enlazar a `forense-fase-13.md` cuando exista)
- **Ejercicios:** 28 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones,
  incluyendo **al menos dos de estilo 🧬** (dado un archivo, decidir si el fix
  va en estilo nuevo o heredado y justificarlo).

## Pendientes que pueden bloquear esta fase

- **La 💸 más vieja del curso se paga aquí, y su factura ya está escrita.** La URL horneada de la Fase 0 se salda en esta fase, y `00-convencion-de-git-y-tags.md` ya dejó el comando con el que se lee: `git diff fase-00 fase-13 -- src/environments src/assets`. Ponlo en el bloque 🏷️.
- ⚠️ **`apiBaseUrl` vale `/api` en producción desde la Fase 1, y nadie sirve `/api` todavía.** El `environment.ts` de producción apunta a una ruta relativa; el de desarrollo, a `http://localhost:3000`. Cuando la aplicación viva detrás de nginx, alguien tiene que resolver esa ruta. Decide qué haces y dilo: un `proxy_pass` en el `nginx.conf`, un segundo contenedor con el mock, o los dos con Compose. **El mock es Node y hoy no está contenedorizado** —`mock/server.js` de la Fase 3 y `mock/demo.js` de la Fase 11—, así que esto no es un detalle de configuración: es una decisión de alcance que hay que tomar antes de escribir el Dockerfile.
- **La zona horaria dentro del contenedor es material de esta fase, no del apéndice.** `CERTCORE_TIME_ZONE_OFFSET` es fijo (`-05:00`, Fase 7) y eso está bien, pero `alpine` corre en UTC y el navegador del usuario corre donde esté el usuario. La Fase 10 dejó el incidente 15 con el certificado que vence un día distinto según quién pregunte; aquí aparece su gemelo de despliegue. Es el mejor candidato para uno de los dos incidentes de esta fase y encaja de lleno en la pieza forense del diff de ambientes.
- **`main.ts` sigue arrancando con `platformBrowserDynamic().bootstrapModule(AppModule)`, y la Fase 5 escribió que sería así "hasta la Fase 13".** Decide qué significa eso. `APP_INITIALIZER` funciona igual en las dos formas, así que convertir a `bootstrapApplication` no es un requisito técnico — y convertir el `AppModule` roza la regla de la Fase 5 de que los nueve módulos heredados no se convierten "ni hoy ni en el resto del curso". Si lo dejas como está, dilo en voz alta y corrige esa frase de la Fase 5 en tus 📌; si lo conviertes, justifica por qué esta excepción sí.
- **Los dos ejercicios 🧬 salen del `APP_INITIALIZER`, no hay que buscarlos.** Es un provider registrado en un `AppModule` de 2021 que carga la configuración que consume código standalone de 2025. Es la costura más limpia de la fase y la única de la que el estudiante se va a acordar.
- **Reutiliza lo que la Fase 12 ya dejó puesto.** El `ChromeHeadlessCI` con `--no-sandbox` existe desde la fase anterior precisamente porque dentro de un contenedor no hay otra forma. Y `coverage/` ya debería estar en el `.gitignore`; ahora hace falta además un `.dockerignore` que deje fuera `node_modules`, `coverage`, `mock/db.json` y `.git`, o la imagen se lleva medio disco.
- **Tres cosas quedaron anotadas para esta fase desde muy atrás y conviene no olvidarlas.** Las dos `<link>` a `fonts.googleapis.com` que el schematic de Material metió en `index.html` (Fase 1), que atan cada carga a un tercero y rompen en un despliegue sin salida a internet. El `"sourceMap": { "hidden": true }` que la Fase 0 mencionó en un 💡 y cuyo tratamiento completo —qué se sirve, qué se guarda, qué ve alguien con DevTools— es tuyo. Y la imagen base: **`node:18.18.2-alpine` exacto**, no `node:18-alpine`, o el contenedor construye con un npm distinto al de la máquina del lector (📌 de la Fase 0).
- **`deuda.md` llega aquí con cifras de cinco fases y esta fase es donde se contrastan.** Las Fases 5 y 6 midieron el `SharedModule` y el tema de Material, la 10 el chunk de jsPDF, la 11 el de Chart.js y el costo de las agregaciones, la 12 el coverage. Los presupuestos del CLI 16 son el sitio donde esos números dejan de ser anécdotas y se convierten en un build que falla.
- **Etiqueta la imagen con el tag de git que la produjo, no con `:latest`.** La convención ya lo pide (`00-convencion-de-git-y-tags.md`, sección 🐳) y **A09** explica por qué morder ese anzuelo es la mitad barata del diagnóstico de "por qué se comportó distinto en UAT".
- **Los incidentes 18 y 19 son tuyos y el cuaderno espera sus IDs.** La distribución de `propuesta-fases-y-alcance.md` §6 los sitúa en la semana 4 y sugiere el tema: config apuntando al ambiente equivocado, y el 404 al recargar una ruta profunda o la zona horaria del contenedor. Elige dos y resérvalos con su categoría y dificultad.
- El **checklist de hotfix** de una página se escribe aquí y es lo único del curso que el estudiante se lleva al trabajo. Dale el espacio que merece.
- **El cierre del curso va aquí**, y tiene que ser honesto en las dos direcciones: qué sabe hacer ahora, qué no, y el guiño hacia Angular 17 sin vender una migración. Incluye lo que el curso **no** resolvió y prometió: la trazabilidad —*"todo lo relevante deja rastro"*, `alcance-del-proyecto.md` §5— la reclamaron sin éxito las Fases 6, 9, 10 y 11; el trabajo sin conexión quedó como historia; y las alertas de la Fase 11 no alertan a nadie. Decir eso al final vale más que un párrafo de despedida.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   las 7h te cuadran con el contenido pedido.
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## # Fase 14

```markdown
Este es el chat de la **Fase 14 — 🔥 Ambiente "casi prod" con kind** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es el archivo `14-casi-prod-kind.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: instrucciones del proyecto,
`alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`,
`guia-de-estilo-y-convenciones.md`, `plantillas-de-capitulo.md`,
`formato-cuaderno-incidentes.md`, entregables de fases anteriores y decisiones de
este chat. `_deprecado-tutorial-angular16.md` **no cuenta**: su mapa de 96h, sus
apéndices A1-A8 y su marco de NDA quedaron atrás.

La plantilla de fase (9 secciones, el bloque 🏷️ del cierre y el bloque 📌 de
autoría) está en
`plantillas-de-capitulo.md`: se sigue literal, sin secciones extra ni
reordenadas. La voz, el tuteo, la regla del andamio, la prosa antes que listas y
las listas antes que tablas están en `guia-de-estilo-y-convenciones.md`.

Recordatorio de las cinco reglas que más se rompen:
- **Código en inglés, comentarios en español con tildes.** Sin excepciones, ni en
  `db.json` ni en el Dockerfile. CertCore es monolingüe: los textos de interfaz
  van como literales en español en la plantilla, sin claves de traducción.
- **Una generación por archivo.** Código nuevo: standalone, `inject()`, `OnPush`,
  guards e interceptors funcionales, `takeUntilDestroyed`, arrow functions.
  Código heredado: NgModule, `constructor`, guards e interceptors de clase,
  `RouterModule.forChild`. **Nunca los dos estilos dentro del mismo archivo**, y
  los puntos donde se tocan van marcados con 🧬.
- **`strict: true` y cero `any`.** Nulabilidad explícita en modelos y en
  `FormControl`; `unknown` con estrechamiento donde el tipo no se conoce. No se
  apaga `strict` ni para simplificar un ejemplo.
- **Coherencia de la ficción.** El sistema heredado es **CertCore** y el curso lo
  construye entero: si afirmas que algo está así en CertCore, tiene que estar en
  alguna fase. Guía §11. Cronología fija: nació en 2021 sobre Angular 12, se
  migró a 16 durante 2024.
- **El cierre lleva el bloque 🏷️ del tag**, de forma fija y sin reexplicar la
  convención: `git tag -a fase-NN`, prefijo de commit `fase NN:`, y el enlace a
  `00-convencion-de-git-y-tags.md`. Va después de La señal de que quedó bien y
  antes del `---` de los 📌 Pendientes. Guía §8.1. Si esta fase tiene algo propio
  que decir sobre git —paga una deuda 💸 declarada antes, produce un incidente
  cuya rama sale de este tag, retira código que sólo el tag conservará— se añade
  un párrafo corto al final del mismo bloque.

## Identidad de esta fase

- Número y nombre: Fase 14 de 14 — 🔥 Ambiente "casi prod" con kind
- Horas: **sin horas asignadas**
- Depende de: Fase 13
- Habilita: ninguna
- Apéndices de apoyo: A09, A12
- Incidentes asociados: ninguno
- Estado: 🔥 Opcional, sin horas
- **Estilo de código de esta fase:** infraestructura; la app no se toca

## Alcance

- **Propósito (una línea):** Ver la imagen de la Fase 13 corriendo en un Kubernetes local, sin modificarla ni una línea.
- **Qué entra:** cluster con kind, carga de la imagen local al nodo (el tropiezo de todo el mundo, convertido en ejercicio), Deployment, Service, ConfigMap montado como volumen alimentando el mismo `entrypoint.sh`, Ingress, y un rolling update en vivo.
- **Qué NO entra todavía:** cluster real de la empresa, Helm, operadores, service mesh → fuera de alcance
- **Conceptos clave a introducir:** Pod, Deployment, Service, ConfigMap, Ingress, rolling update — y que el ConfigMap hace exactamente lo mismo que el `docker run -e` de la Fase 13.
- **Deuda técnica intencional 💸:** Manifiestos mínimos, sin `resources` ni probes finas.
  (Lo correcto es liveness, readiness y límites; **no se paga**: aquí se ve cómo funciona, no cómo se pone en producción, y se dice con todas las letras.)
- **Pieza forense de esta fase:** `kubectl logs` y `kubectl describe` cuando el pod no arranca, y el `CrashLoopBackOff` de una imagen amd64 en un Mac arm64.
  (enlazar a `forense-fase-14.md` cuando exista)
- **Ejercicios:** 15 en total, repartidos 🟢🟡🟠🔴 según la guía §9, con al
  menos un tercio de diagnóstico y todos anclados al dominio de inspecciones.
  **Excepción declarada a la guía §9**, y las dos mitades importan: quince está
  por debajo del mínimo de 25 porque esta fase es 🔥 y no tiene presupuesto
  horario; y **aquí no hay ejercicios de estilo 🧬**, porque la app no se toca y
  no hay ningún archivo del que decidir si el fix va en estilo nuevo o heredado.
  En su lugar, dos de **lectura de manifiestos ajenos**, marcados 👁️ / ✍️ como
  en los apéndices de infraestructura: dado un YAML que no escribiste, decir qué
  hace y qué rompería cambiarlo.

## Pendientes que pueden bloquear esta fase

- Abre el capítulo con la línea de que **esta fase no es requisito del onboarding**; el líder la asigna a quien tenga interés.
- No te ates a un runtime de contenedores: Docker Desktop, Colima o Podman, el que el lector ya tenga. Ojo con el comando de carga: `kind load docker-image` sólo funciona si hay un demonio de Docker escuchando. Con Podman o con Colima en algunas configuraciones, la salida universal es `docker save`/`podman save` a un tar y `kind load image-archive`. Dilo una vez y no vuelvas sobre ello.
- ⚠️ **La imagen de la Fase 13 no se modifica, y eso es una prueba, no una restricción.** El `entrypoint.sh` que reescribe `assets/config.json` desde variables de entorno tiene que funcionar **igual** alimentado por un ConfigMap montado como volumen. Si no funciona —si hiciera falta tocar la imagen— el problema no es de esta fase: es un defecto del diseño de la Fase 13, y hay que decirlo allí en tus 📌 en vez de parchearlo aquí.
- **El ConfigMap hace exactamente lo mismo que el `docker run -e` de la Fase 13, y ése es todo el capítulo.** Si el lector sale con una sola idea, que sea ésa: Kubernetes no resuelve el problema de la configuración horneada en build, sólo cambia quién le pasa las variables al mismo `entrypoint.sh`. La fricción que ordena el final del curso sigue intacta ocho versiones y un orquestador después.
- **El Ingress no viene de fábrica.** kind no trae controlador, y el cluster hay que crearlo con `extraPortMappings` **antes** de instalar ninguno: si el lector crea el cluster primero y lo descubre después, tiene que borrarlo y empezar de nuevo. Escríbelo en ese orden o el ejercicio se convierte en un `kind delete cluster`.
- **En Apple Silicon, la imagen amd64 da `CrashLoopBackOff` sin explicar por qué**, y el mensaje útil está en `kubectl logs` (`exec format error`), no en `kubectl describe`. Enlaza **A12** y conviértelo en ejercicio de diagnóstico en vez de esconderlo en una advertencia.
- **Esta fase no reserva ningún ID de incidente**, y aun así tiene pieza forense. Dilo explícitamente en las 📌: `forense-fase-14.md` existe, la tabla de reservas del cuaderno va vacía con una raya, y el motivo es que un incidente del cuaderno tiene que poder reproducirlo alguien que no montó el cluster.
- **Decide si esta fase lleva tag propio y justifícalo.** Deja archivos versionados —`k8s/*.yaml`— así que por la convención sí lo lleva (`fase-14`), a diferencia de los apéndices. Pero es opcional, así que la mayoría de los lectores nunca lo van a crear: el bloque 🏷️ tiene que decir las dos cosas sin sonar contradictorio.
- **El cierre del curso ya lo escribió la Fase 13.** Ésta no cierra nada: se despide. No repitas el balance ni el checklist de hotfix; enlázalos.

Si alguno sigue abierto cuando empieces, **no lo asumas**: dímelo y propón la
mínima decisión que destraba la escritura, o marca el punto exacto del documento
que queda pendiente.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme
primero:

a) Las **preguntas bloqueantes** que necesitas resueltas para no inventar:
   nombres y firmas heredados de fases previas, decisiones de diseño que esta
   fase fija y las siguientes heredan. Numéralas y marca cuáles son bloqueantes y
   cuáles puedes asumir con un valor por defecto razonable si no contesto.
b) Tu **lectura del alcance**: qué crees que sobra o falta en lo que te di, y si
   el alcance te cuadra (esta fase es opcional y no tiene presupuesto horario).
c) Un **esbozo de la sección 5** (el código): qué archivos vas a mostrar, en qué
   orden, en qué estilo va cada uno, y qué queda fuera. Quiero verlo antes de que
   escribas mil líneas.
d) Cualquier **contradicción** que detectes con fases anteriores o con los
   documentos base. Si la hay, dímela; no la resuelvas por tu cuenta.

**Paso 2 — Redacción.** Cuando yo responda, escribe el documento completo. Si en
mitad de la redacción aparece una duda nueva, prefiero que **pares y preguntes** a
que rellenes con un supuesto plausible.

**Paso 3 — Autoverificación.** Al final, pásale al documento el checklist de §14
de la guía de estilo y repórtame en una lista corta qué ítems cumples y cuáles
no, con el motivo. Presta atención especial a tres: una sola generación de estilo
por archivo, `strict` sin `any`, y cada 💸 con su fase de cobro declarada.

**Fuera de alcance:** si aparece un tema interesante que no cabe en esta fase,
anótalo al final del entregable como "pendiente sugerido" con el chat destino
(apéndice, incidente, fase posterior o ejercicio 🔥). No infles esta fase.
```

---

## Cómo se usan estos prompts

Abre el chat de la fase que quieras redactar, copia el bloque completo de su
sección, pégalo y **espera las preguntas antes de que redacte**. El Paso 1 no es
decorativo: es donde se cazan las contradicciones con fases anteriores, que salen
mucho más caras después.

Al cerrar cada fase, dos cosas van de vuelta a los documentos base: los
**pendientes 📌** que la fase produjo y las **reservas de incidentes** con su ID,
que se copian al índice de `cuaderno-incidentes.md` aunque el enunciado todavía no
esté redactado. El ID nunca se reasigna.

### Orden de escritura sugerido

Fases 0 a 4 primero: fijan estilo, estructura, estado y mock, y todo lo demás
depende de ellas. Después 5 a 8, que son el núcleo formativo (⭐ 7 y 8). Después 9
a 13. La 14 al final, que es opcional y nada la espera.
