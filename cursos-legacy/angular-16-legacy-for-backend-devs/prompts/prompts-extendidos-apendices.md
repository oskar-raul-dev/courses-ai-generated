# 📍 Prompts extendidos por apéndice
## Tutorial Angular 16 — Inspecciones y certificaciones

Cada sección es el prompt completo del apéndice, listo para copiar al chat que lo
redacta. Los valores están rellenados con los de `propuesta-fases-y-alcance.md`
§4; si alguna vez cambian allí, se cambian aquí después y nunca al revés.

Las horas de los apéndices **no cuentan** dentro de las 122h del calendario: son
consulta bajo demanda.

**Y una pieza de forma fija que ningún apéndice puede olvidar:** el cierre
termina con el bloque 🏷️, que en un apéndice va casi siempre en su variante
negativa —*este apéndice no lleva tag propio, porque el código que explica lo
escriben las fases*— y dice con qué prefijo se commitea lo que sí salga de
leerlo: el de la fase desde la que se llegó. Sólo se etiqueta
(`apendice-aNN`) el apéndice que deje archivos versionados en el repositorio.
Está especificado en la guía de estilo §8.1, en la plantilla de apéndice, y
enlaza `00-convencion-de-git-y-tags.md` sin reexplicarlo.

---

## # Apéndice A01

```markdown
Este es el chat del **Apéndice A01 — Angular Material 16 (MDC)** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a01-material.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A01 — Angular Material 16 (MDC)
- Horas de referencia: **3h** (no cuentan en el calendario de 122h)
- Versión cubierta: Angular Material y CDK 16.2.14
- Usado por: Fases 1, 6, 7, 8, 10
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** Leer y modificar los formularios y tablas densos de CertCore sin pelearse con los componentes MDC.
- **Secciones esperadas:** theming con `define-palette` y `define-typography-config`, qué cambió al pasar a MDC en la 15 y qué se rompió en CertCore durante la migración, `mat-form-field` moderno y sus `appearance`, `mat-table` con `dataSource`, `MatDialog`, `MatSnackBar`, densidad, y los tokens CSS que sí se pueden tocar.
- **Qué queda explícitamente fuera:** los componentes de Material que CertCore no usa; el rediseño visual; Bootstrap (A02).
- **Advertencias obligatorias:** material.angular.io documenta la 17+ y sus ejemplos usan control flow; la referencia es https://v16.material.angular.io. Y casi cualquier artículo anterior a 2023 describe un componente distinto con el mismo nombre, porque MDC lo reescribió.
- **Ejercicios:** 8 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(Fases 1, 6, 7, 8, 10) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 3h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## # Apéndice A02

```markdown
Este es el chat del **Apéndice A02 — Bootstrap 5 + Sass** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a02-bootstrap-sass.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A02 — Bootstrap 5 + Sass
- Horas de referencia: **2h** (no cuentan en el calendario de 122h)
- Versión cubierta: Bootstrap 5.3.x + dart-sass
- Usado por: ninguna fase lo asume; se ofrece a quien lo herede
- Estado: 🔥 Opcional

## Alcance

- **Qué problema resuelve (una línea):** Que Bootstrap y Material convivan sin pelearse por la cascada, si el sistema que heredaste los tiene a los dos.
- **Secciones esperadas:** por qué CertCore no lo usa y por qué aun así este apéndice existe, grid de Bootstrap con componentes de Material, quién gana la especificidad y por qué, capas con `@layer`, variables Sass compartidas para una sola paleta, y qué recompilar tras tocar qué.
- **Qué queda explícitamente fuera:** el rediseño visual del proyecto; los componentes JS de Bootstrap (no se usan: colisionan con los de Material).
- **Advertencias obligatorias:** tocar variables de Sass sin recompilar no cambia nada, y es la media hora perdida más frecuente del tema. Además, este apéndice **no** describe a CertCore: describe un escenario que el lector puede encontrar en otro sistema, y eso se dice en la primera línea (guía §11).
- **Ejercicios:** 6 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(ninguna fase lo asume; se ofrece a quien lo herede) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 2h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## # Apéndice A03

```markdown
Este es el chat del **Apéndice A03 — Node y npm** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a03-node-npm.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A03 — Node y npm
- Horas de referencia: **2h** (no cuentan en el calendario de 122h)
- Versión cubierta: Node 18.18.2, npm 9.8.1, lockfile v3
- Usado por: Fases 0, 3, 12, 13
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** Que el proyecto instale igual en las tres plataformas y que el estudiante sepa comparar su árbol de dependencias con el del curso.
- **Secciones esperadas:** `.nvmrc` y nvm / nvm-windows, `npm ci` frente a `npm i` y cuándo cada uno, el lockfile v3 y qué significa cada campo, `dependencies` frente a `devDependencies` en un proyecto que se compila a estáticos, peer deps en la era npm 9 y el `--legacy-peer-deps` que no deberías escribir por reflejo, `npm ls` y `npm outdated` leídos con criterio, y **cómo comparar el árbol de un proyecto heredado propio contra el del curso**.
- **Qué queda explícitamente fuera:** monorepos, workspaces, pnpm y yarn (se nombran y no se comparan); publicación de paquetes.
- **Advertencias obligatorias:** la última sección es la que responde a "pero mi proyecto no es este": es una sección, no una instrucción suelta, y es lo que evita que ningún ejercicio del curso pida un sistema externo (guía §11, regla 4).
- **Ejercicios:** 7 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(Fases 0, 3, 12, 13) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 2h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## # Apéndice A04

```markdown
Este es el chat del **Apéndice A04 — inject() vs constructor** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a04-inject-vs-constructor.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A04 — inject() vs constructor
- Horas de referencia: **2h** (no cuentan en el calendario de 122h)
- Versión cubierta: Angular 16.2.12
- Usado por: Fases 0, 1, 2, 5 — y de consulta en todas
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** Decidir en dos segundos cuál de las dos formas usar en el archivo que tienes abierto, y entender qué se rompe si eliges mal.
- **Secciones esperadas:** qué es el contexto de inyección y dónde exactamente termina, `inject()` en campo de clase frente a en constructor, herencia sin `super()` interminable, `inject()` dentro de guards, interceptors y resolvers funcionales, `runInInjectionContext` y cuándo es legítimo, `inject(TOKEN, { optional: true })` y las demás opciones, el error `NG0203` traducido, y la regla del proyecto.
- **Qué queda explícitamente fuera:** el sistema de DI completo (jerarquía de inyectores, multi providers avanzados): se enlaza a la doc; aquí sólo lo que aparece en CertCore.
- **Advertencias obligatorias:** este apéndice es 🧬 casi de principio a fin: cada sección muestra la forma nueva y la heredada del mismo caso. Termina con la regla del §6.1 de la guía y con la advertencia de que mezclar las dos en el mismo archivo es peor que cualquiera de las dos.
- **Ejercicios:** 8 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(Fases 0, 1, 2, 5 — y de consulta en todas) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 2h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## # Apéndice A05

```markdown
Este es el chat del **Apéndice A05 — Formularios reactivos tipados** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a05-formularios-tipados.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A05 — Formularios reactivos tipados
- Horas de referencia: **3h** (no cuentan en el calendario de 122h)
- Versión cubierta: Angular 16.2.12 — tipado disponible desde la 14
- Usado por: Fases 0, 2, 6, 8, 9
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** Escribir y depurar los formularios densos de CertCore sin que el tipo se te escape por un `any`.
- **Secciones esperadas:** `FormControl<T>` y el `| null` que casi nadie espera, `nonNullable: true` y cuándo sí, `FormGroup<T>` y la inferencia con `FormBuilder`, `FormRecord` y controles creados en runtime, `FormArray` tipado, validadores tipados y validadores asíncronos, `getRawValue()` frente a `value` (y por qué el segundo miente cuando hay controles deshabilitados), y el tipado de un formulario que no se conoce en compilación.
- **Qué queda explícitamente fuera:** formularios por plantilla (`ngModel`): CertCore no los usa y se dice; componentes de formulario de Material (A01).
- **Advertencias obligatorias:** la mayoría de los ejemplos que hay en internet son pre-14 y no compilan bajo `strict`. Advertirlo, y advertir que `getRawValue()` es la fuente del bug más silencioso del tema.
- **Ejercicios:** 9 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(Fases 0, 2, 6, 8, 9) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 3h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## # Apéndice A06

```markdown
Este es el chat del **Apéndice A06 — RxJS 7 idiomático** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a06-rxjs.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A06 — RxJS 7 idiomático
- Horas de referencia: **3h** (no cuentan en el calendario de 122h)
- Versión cubierta: RxJS 7.8.1
- Usado por: Fases 2, 3, 4, 8, 11
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** Usar los seis operadores que aparecen de verdad en CertCore, y reconocer los tres antipatrones que produce cada uno.
- **Secciones esperadas:** el modelo mental mínimo (frío/caliente, quién dispara y quién cancela), `map`, `switchMap` frente a `mergeMap` frente a `concatMap` con el caso que los distingue, `combineLatest` y su trampa del primer valor, `debounceTime` + `distinctUntilChanged`, `catchError` y qué devolver, `shareReplay` con y sin `refCount`, `takeUntilDestroyed`, y el `async` pipe frente al `.subscribe()`.
- **Qué queda explícitamente fuera:** marbles avanzados, operadores de scheduling, creación de operadores propios; testing con `TestScheduler` (Fase 12).
- **Advertencias obligatorias:** mucha documentación y muchos ejemplos son de RxJS 6 y difieren en imports y en operadores retirados. Y la regla del curso se repite aquí: `async` pipe para pintar, `.subscribe()` para efectos — y entonces alguien se desuscribe.
- **Ejercicios:** 9 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(Fases 2, 3, 4, 8, 11) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 3h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## # Apéndice A07

```markdown
Este es el chat del **Apéndice A07 — Estado con servicios y BehaviorSubject** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a07-estado-servicios.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A07 — Estado con servicios y BehaviorSubject
- Horas de referencia: **3h** (no cuentan en el calendario de 122h)
- Versión cubierta: Angular 16.2.12 + RxJS 7.8.1
- Usado por: Fases 4, 6, 7, 9, 11
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** Entender el patrón de estado de CertCore de punta a punta, y saber en qué punto exacto se queda corto.
- **Secciones esperadas:** el patrón (`BehaviorSubject` privado + `Observable` público de sólo lectura), por qué nunca se expone el `Subject`, `providedIn: 'root'` frente a provider de ruta y qué implica para el ciclo de vida, actualizar sin mutar, estado derivado con `combineLatest`, `loading` y `error` dentro del estado, el ciclo de vida completo de una suscripción, y **dónde el patrón se queda corto** — devtools, time-travel, trazabilidad de quién cambió qué.
- **Qué queda explícitamente fuera:** NgRx y cualquier otra librería de store: se nombra qué problema resolvería y se dice que CertCore no la usa (el Track A sí, y ahí vive esa enseñanza). Signals como estado: A11.
- **Advertencias obligatorias:** la sección de "dónde se queda corto" es obligatoria y honesta: sin ella este apéndice se lee como una defensa del patrón, y no lo es. También va la advertencia de que un `BehaviorSubject` en un servicio raíz sobrevive a todas las navegaciones, que es de donde salen las fugas del curso.
- **Ejercicios:** 8 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(Fases 4, 6, 7, 9, 11) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 3h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## # Apéndice A08

```markdown
Este es el chat del **Apéndice A08 — PDF en cliente con jsPDF 2** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a08-pdf-cliente.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A08 — PDF en cliente con jsPDF 2
- Horas de referencia: **3h** (no cuentan en el calendario de 122h)
- Versión cubierta: jspdf 2.5.1 + jspdf-autotable 3.8.x
- Usado por: Fase 10
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** Armar el certificado en PDF desde el navegador más allá de las cinco líneas del ejemplo oficial.
- **Secciones esperadas:** el modelo de coordenadas y por qué todo sale corrido la primera vez, fuentes embebidas y la mecánica exacta de los acentos rotos, tabla de hallazgos con `jspdf-autotable`, encabezado y pie repetidos, imágenes y su peso, el bundle que crece 300 KB y cómo diferirlo con `import()`, y los límites de la librería —cuándo toca generar el PDF en el servidor.
- **Qué queda explícitamente fuera:** firma digital real, PDF/A, generación en servidor (se nombra como el límite y no se implementa); `pdfmake` y `html2canvas` se comparan en una tabla y no se instalan.
- **Advertencias obligatorias:** el PDF se arma desde la fuente del dato, nunca desde lo que hay pintado en la vista — es la deuda 💸 que la Fase 10 paga tras el incidente 14, y aquí se repite porque es el error que todo el mundo comete dos veces.
- **Ejercicios:** 7 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(Fase 10) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 3h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## # Apéndice A09

```markdown
Este es el chat del **Apéndice A09 — Docker y Kubernetes para el dev de front** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a09-docker-kubernetes.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A09 — Docker y Kubernetes para el dev de front
- Horas de referencia: **3h** (no cuentan en el calendario de 122h)
- Versión cubierta: Docker Engine 24+, nginx 1.25, kind (sin versión fijada)
- Usado por: Fases 13 y 14
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** Leer un manifiesto ajeno, saber qué le pasa a tu imagen después del build, y hablar con plataforma sin sentirte turista.
- **Secciones esperadas:** qué es una imagen y qué le pasa después del `docker build` (registry, tag frente a digest, por qué `latest` te va a morder), el vocabulario completo (Pod, Deployment, Service, Ingress, ConfigMap, Secret), por qué un Secret no es un secreto, la caja de herramientas marcada 👁️ solo lee / ✍️ modifica, los estados de un pod traducidos a lenguaje humano (`ImagePullBackOff`, `CrashLoopBackOff`, `Pending`), y cómo leer logs de un contenedor que ya murió.
- **Qué queda explícitamente fuera:** Helm, operadores, service mesh, administración del cluster; el Dockerfile y el `entrypoint.sh` concretos del proyecto (Fase 13).
- **Advertencias obligatorias:** **advertencia obligatoria al cierre**: el cluster real de la empresa tiene particularidades que el Kubernetes de libro no cubre —el contenedor puede no correr como root, y eso rompe nginx en el puerto 80, que es exactamente la deuda 💸 que la Fase 13 deja abierta—. Con la instrucción explícita de preguntarle al equipo de plataforma antes de improvisar.
- **Ejercicios:** 8 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(Fases 13 y 14) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 3h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## # Apéndice A10

```markdown
Este es el chat del **Apéndice A10 — Puente Angular 8/9 → 16** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a10-migracion-8-16.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A10 — Puente Angular 8/9 → 16
- Horas de referencia: **3h** (no cuentan en el calendario de 122h)
- Versión cubierta: de Angular 8.2.14 / 9 a 16.2.12
- Usado por: lectores que vienen del Track A (LabCore); de consulta en todas las fases
- Estado: Base

## Alcance

- **Qué problema resuelve (una línea):** Que alguien con los reflejos de un Angular 8/9 pueda leer el código de CertCore sin traducir mentalmente cada línea.
- **Secciones esperadas:** las cuatro puertas del camino largo (Ivy, `strict`, standalone, `inject()`), qué desapareció y qué sólo cambió de nombre, RxJS 6 → 7 (imports, operadores retirados, `toPromise`), formularios sin tipar → tipados, guards e interceptors de clase → funcionales, NgRx de 2019 → estado en servicios, y una **tabla de traducción** que convierte un ejemplo de LabCore en su equivalente de CertCore.
- **Qué queda explícitamente fuera:** el procedimiento real de migración con `ng update` versión por versión: esto es un puente conceptual, no una guía de migración, y se dice en la primera línea.
- **Advertencias obligatorias:** este es **el único documento del curso donde nombrar LabCore es correcto**, porque su lector es alguien que viene del Track A. Escríbelo hablándole a esa persona. Para quien llegue directo al Track B, el apéndice es opcional y hay que decírselo.
- **Ejercicios:** 7 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(lectores que vienen del Track A (LabCore); de consulta en todas las fases) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 3h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## # Apéndice A11

```markdown
Este es el chat del **Apéndice A11 — Puente Angular 16 → 17+** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a11-puente-16-17.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A11 — Puente Angular 16 → 17+
- Horas de referencia: **2h** (no cuentan en el calendario de 122h)
- Versión cubierta: de 16.2.12 hacia 17 y posteriores
- Usado por: Fase 12 (la pincelada de signals sale de aquí)
- Estado: 🔥 Opcional

## Alcance

- **Qué problema resuelve (una línea):** Saber qué viene después, para leer sin tropezar la documentación y los artículos que ya sólo hablan de la versión nueva.
- **Secciones esperadas:** signals de verdad (`signal`, `computed`, `effect`) y en qué se parecen y en qué no a un `BehaviorSubject`, el control flow `@if/@for/@switch` y qué gana frente a las directivas estructurales, deferrable views, el builder de esbuild y qué cambia en los tiempos de build, `provideRouter` y el bootstrap sin NgModule, y qué costaría llevar CertCore hasta ahí.
- **Qué queda explícitamente fuera:** una guía de migración paso a paso; cualquier recomendación de migrar. El curso enseña a mantener, no a migrar, y este apéndice es horizonte, no plan.
- **Advertencias obligatorias:** en Angular 16 los signals son **experimentales** y CertCore no los usa: aquí se leen, no se adoptan. Y cerrar con la advertencia honesta de que migrar un sistema en mantenimiento con decomisión prevista rara vez se paga solo.
- **Ejercicios:** 5 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(Fase 12 (la pincelada de signals sale de aquí)) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 2h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## # Apéndice A12

```markdown
Este es el chat del **Apéndice A12 — macOS Apple Silicon y arm64** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a12-arm64-m1.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A12 — macOS Apple Silicon y arm64
- Horas de referencia: **2h** (no cuentan en el calendario de 122h)
- Versión cubierta: sin versiones fijadas: es un apéndice de plataforma
- Usado por: Fases 0, 12, 13, 14
- Estado: 🔥 Opcional por plataforma

## Alcance

- **Qué problema resuelve (una línea):** Que alguien con un Mac de la serie M pueda seguir el curso completo, incluidas las fases de contenedor.
- **Secciones esperadas:** dónde estás parado en tres capas (máquina, Node, imagen) y por qué confundirlas es el 90% del problema, Node 18 en arm64 —que a diferencia de Node 12 no compila nada y por eso este apéndice es corto—, el Chromium de Karma en arm64 para la Fase 12, construir la imagen de la Fase 13 para la arquitectura correcta (`--platform`, `buildx`), Colima frente a Docker Desktop frente a Podman en dos líneas cada uno, y 🩺 diagnóstico por síntoma.
- **Qué queda explícitamente fuera:** `node-sass` y `node-gyp` (no aplican: el stack de este curso no compila C++, y eso se dice explícitamente porque quien venga del Track A lo va a buscar); el Dockerfile del proyecto (Fase 13); kind (Fase 14).
- **Advertencias obligatorias:** el `CrashLoopBackOff` de la Fase 14 en un Mac arm64 casi siempre es una imagen amd64, y esa es la advertencia que más tiempo ahorra del apéndice. Los ejercicios requieren un Mac con Apple Silicon y se dice explícitamente que quien no lo tenga no necesita este documento.
- **Ejercicios:** 6 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(Fases 0, 12, 13, 14) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 2h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## # Apéndice A13

```markdown
Este es el chat del **Apéndice A13 — i18n moderno** del tutorial Angular 16 +
Inspecciones y certificaciones. Su único entregable es `a13-i18n.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad y estilo: los mismos del proyecto —`alcance-del-proyecto.md`,
`propuesta-fases-y-alcance.md`, `guia-de-estilo-y-convenciones.md`. Aquí manda la
**plantilla de apéndice** de `plantillas-de-capitulo.md`, que es deliberadamente
laxa: encabezado, índice de salto rápido, secciones cortas con ejemplo mínimo
ejecutable, tabla de "cuándo usar qué", advertencias si aplica, referencias y
5-10 ejercicios cortos.

Un apéndice **no se lee de corrido**: se entra por el índice buscando algo
concreto y se sale. Escríbelo pensando en alguien con el jefe mirando por encima
del hombro, no en alguien estudiando el domingo.

Reglas que no cambian: código en inglés y comentarios en español con tildes;
`strict: true` y cero `any`; una sola generación de estilo por archivo —nuevo
(standalone, `inject()`, funcional) o heredado (NgModule, `constructor`, clases)—
con 🧬 donde se tocan; y coherencia de la ficción de CertCore (guía §11).

Y el cierre lleva su bloque 🏷️ (guía §8.1), en la variante que corresponda: sin
tag propio si es consulta pura —diciendo con qué prefijo de fase se commitea lo
que salga de leerlo—, con `apendice-aNN` sólo si el apéndice deja archivos
versionados. Enlaza `00-convencion-de-git-y-tags.md`; no lo reexpliques.

## Identidad

- Apéndice A13 — i18n moderno
- Horas de referencia: **2h** (no cuentan en el calendario de 122h)
- Versión cubierta: `@angular/localize` 16.2.12 · `@ngx-translate/core` 15.x
- Usado por: ninguna fase; es lectura
- Estado: 🔥 Opcional

## Alcance

- **Qué problema resuelve (una línea):** Saber qué costaría internacionalizar CertCore, y por qué este curso decidió no hacerlo.
- **Secciones esperadas:** la decisión en un eje (compile-time frente a runtime) y qué implica cada rama para el build y el despliegue, `@angular/localize` con `$localize` y un bundle por idioma, `@ngx-translate` 15 con carga en runtime y selector en caliente, el costo real de convertir plantillas ya escritas, formatos de fecha y número por locale —que es donde vive el bug de verdad—, y una estimación honesta de horas.
- **Qué queda explícitamente fuera:** la implementación completa: este apéndice **no** se implementa en CertCore, que es monolingüe por decisión cerrada (alcance §8). Es un documento de decisión, no un tutorial.
- **Advertencias obligatorias:** decirlo en la primera línea: CertCore no tiene i18n y este apéndice no lo añade. Si el lector viene del Track A, allí sí es una fase completa con tres idiomas, y ese contraste es la mejor forma de explicar el costo.
- **Ejercicios:** 5 cortos, de consulta.

## Regla anti-solapamiento

Un apéndice **no repite lo que ya explica una fase: enlaza**. Antes de escribir,
dime qué partes de tu esquema crees que ya viven en las fases que lo usan
(ninguna fase; es lectura) y propón si las enlazas o las reescribes desde otro ángulo. Si no
tienes el entregable de esa fase a la vista, pídemelo.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes todavía. Devuélveme:

a) Preguntas bloqueantes, sobre todo **versión exacta a cubrir** (nada de dar una
   versión por buena de memoria; se toma del stack fijado en
   `alcance-del-proyecto.md` §9).
b) Qué convenciones de CertCore das por conocidas y por eso no repites.
c) El **índice propuesto** del apéndice, con una línea por sección, para que lo
   apruebe antes de que escribas.
d) Qué crees que sobra o falta en el alcance que te di, y si las 2h cuadran.

**Paso 2 — Redacción** cuando yo responda. Duda nueva a mitad de camino: paras y
preguntas.

**Paso 3 — Autoverificación** contra el checklist de la guía de estilo, en la
parte que aplica a apéndices, reportada en lista corta.

Si aparece material que da para fase o incidente, anótalo como pendiente sugerido
al final. No infles el apéndice.
```

---

## Cómo se usan estos prompts

Abre el chat del apéndice que quieras redactar, copia el bloque completo de su
sección, pégalo y **espera el índice propuesto antes de que redacte**. En un
apéndice el índice es el 80% de la calidad: si el índice está bien, se consulta;
si está mal, se lee de corrido y entonces ya falló.

### Orden de escritura sugerido

**A03, A04, A05, A06 y A07 primero**, porque las Fases 0 a 8 los citan y conviene
que existan cuando alguien siga esas citas. Después **A01** (lo necesita la Fase
6) y **A08** (la Fase 10). Después **A09**, que sostiene las Fases 13 y 14. Al
final los cuatro opcionales: **A02, A10, A11 y A13** —A10 antes que los otros si
hay lectores llegando desde el Track A— y **A12**, que se escribe cuando haya
alguien con un Mac que lo pruebe.
