# 🅰️ Prompts iniciales por fase — Track BE 🔥
## Tutorial Angular 16 — Inspecciones y certificaciones · Backend en PHP 7.4 + Lumen + PostgreSQL

Cada sección es el prompt completo de la fase, listo para copiar al chat que la
redacta. Los valores están rellenados con los de `propuesta-fases-backend.md` §5,
§6 y §7; si alguna vez cambian allí, se cambian aquí después y **nunca al revés**.

**Un chat, un archivo.** Si un chat no produce entregable, o sobra o se salió de
alcance.

> ⚠️ **Antes del primer chat del track.** Sube al Project Knowledge, además de los
> documentos del track base, **`prompts/propuesta-fases-backend.md`**. Sin él
> ninguna fase BE puede justificar qué deuda cobra, y esa justificación es el
> criterio que decide qué entra en cada fase.

> 📝 **Adaptación declarada respecto de `prompts-extendidos-fases.md`.** Los
> prompts del track base repiten íntegro el protocolo de tres pasos en cada
> bloque. Aquí va **comprimido a seis líneas** al final de cada prompt: ocho fases
> con el protocolo completo hacen un archivo que nadie relee. El protocolo no
> cambia —preguntas antes de escribir, redacción, autoverificación contra §14 de
> la guía—; solo se enuncia más corto.

---

## # Fase be00 — El contrato: auditoría del mock

```markdown
Este es el chat de la **Fase be00 — 📜 El contrato: auditoría del mock**, del
track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable es
`be00-el-contrato-auditoria-del-mock.md`.

## Marco (no lo repitas, aplícalo)

Fuentes de verdad, en este orden: (1) `prompts/propuesta-fases-backend.md`,
(2) `prompts/alcance-del-proyecto.md`, (3)
`prompts/guia-de-estilo-y-convenciones.md` incluida su sección del track BE,
(4) `prompts/plantillas-de-capitulo.md`, (5) `00-historia-del-sistema.md`
—en particular la **Era 0 (2016-2018)**, que es el cimiento de este track—,
(6) las fases 0-10 del track base ya escritas y aprobadas, (7) decisiones de este
chat. `_deprecado-tutorial-angular16.md` **no cuenta**.

La plantilla de fase (9 secciones, bloque 🏷️ del cierre, bloque 📌 de autoría)
se sigue literal, sin secciones extra ni reordenadas.

Reglas del track que no se negocian:
- **El frontend NO SE TOCA.** Ni un componente, ni un servicio, ni un
  `BehaviorSubject`, ni el interceptor, ni `environment.apiUrl`.
- **Código en inglés, comentarios en español con tildes.** También en PHP:
  clases, métodos, rutas, nombres de tabla y de columna.
- **Nada de PHP moderno gratuito.** Sin `match`, sin enums, sin atributos, sin
  constructor property promotion, sin tipos union. Aquí el runtime es 7.4 **a
  propósito**; lo de PHP 8 va marcado 🔥 como comparación.
- **Lumen no fue una tontería.** En 2016, para una empresa mediana
  latinoamericana con gente de PHP del intranet viejo, era la decisión sensata, y
  el beneficio se cobró durante años. El pecado no fue elegirlo: fue elegirlo
  para *un servicio*, acertar, y que nadie volviera a decidir nunca.
- **El cierre lleva el bloque 🏷️**, con el namespace propio del track:
  `be-fase-00-el-contrato-auditoria-del-mock`, prefijo de commit `be00:`.

## Identidad de esta fase

- Fase be00 de be07 — 📜 El contrato: auditoría del mock
- Horas: **6h**
- Depende de: **Fase 10 del track base terminada** (`fase-10-certificados-vigencia`)
- Habilita: be01
- Apéndices de apoyo: ninguno todavía
- Incidentes reservados: ninguno
- Estado: **Opcional 🔥** — no ocupa calendario del track base

## Alcance

- **Propósito (una línea):** Saber exactamente qué promete el servidor que se va
  a apagar, antes de escribir una línea de PHP.
- **Qué entra:** capturar el tráfico real con la pestaña Network recorriendo las
  fases 3 a 10 del track base —**capturarlo, no leer el código del mock**—;
  inventariar las seis colecciones (`clients`, `assets`, `templates`,
  `inspections`, `findings`, `certificates`) y el login; documentar el dialecto
  que el frontend consume de verdad, incluido **el `id` compuesto de las
  plantillas** (`elevator-annual-v2`, con el identificador lógico en `templateId`)
  y la ruta anidada `GET /inspections/:id/findings`; los modos del inyector de
  caos con sus vías de activación, **incluida la que manipula el TTL del token**;
  y la separación entre régimen estricto y régimen de crecimiento.
- **Qué NO entra:** una sola línea de PHP. Esta fase audita y documenta.
- **Entregables dentro del entregable:** `CONTRACT.md` y `smoke.sh` ejecutable,
  que a partir de aquí es el juez de todas las fases.
- **Aquí se cuenta de dónde salió el backend**, apoyándote en la Era 0 de
  `00-historia-del-sistema.md`: `certcore-api` es de 2016, la empresa certificaba
  antes de tener una app Angular, y **nadie la revisó nunca**. Y se cierra el
  círculo con tres rarezas que el alumno ya conoce del track base y que por fin
  tienen explicación: el objeto completo sin paginar, el `status` del certificado
  guardado como dato, y el `id` compuesto que nadie diseñó.
- **Y aquí va la defensa de Lumen**, antes de la primera factura.
- **Pieza forense:** dos peticiones que el alumno juraría que son iguales y que
  difieren en un header o en el orden de los parámetros.
- **Deuda del track base que cobra:** ninguna todavía. Prepara el terreno.
- **Ejercicios:** 25-28, con al menos un tercio de diagnóstico, anclados al
  dominio de inspecciones.

## Pendientes que pueden bloquear esta fase

- Nada bloqueante: el stack está cerrado y medido en `propuesta-fases-backend.md`
  §5, con fecha de verificación.
- ⚠️ **Hay que fijar la versión exacta de Lumen antes de be01**, pero no frena
  esta fase.

## Audiencia

Dev backend senior que ya terminó diez fases de Angular de este mismo curso. **No**
le expliques qué es HTTP, un contrato de API, CORS ni un JWT.

## Cómo quiero que trabajes

**Paso 1 — Preguntas antes de escribir.** No redactes. Devuélveme: (a) preguntas
bloqueantes numeradas, marcando cuáles puedes asumir con un valor por defecto;
(b) tu lectura del alcance y si las 6h cuadran; (c) un esbozo de la sección 5;
(d) cualquier contradicción con el track base — dímela, no la resuelvas.
**Paso 2 — Redacción**, cuando yo responda. Si aparece una duda nueva, **para y
pregunta**.
**Paso 3 — Autoverificación** contra §14 de la guía, en lista corta. Vigila: el
frontend intacto, cada 💸 con su fase de cobro, y la defensa de Lumen presente.
```

---

## # Fase be01 — Lumen sobre PHP 7.4, y la familiaridad falsa ⭐

```markdown
Este es el chat de la **Fase be01 — 🐘 Lumen sobre PHP 7.4, y la familiaridad
falsa**, del track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único
entregable es `be01-lumen-y-la-familiaridad-falsa.md`.

## Marco (no lo repitas, aplícalo)

El mismo de be00: `propuesta-fases-backend.md` manda, plantilla de 9 secciones
literal, el frontend no se toca, código en inglés y comentarios en español, nada
de PHP 8 salvo marcado 🔥, Lumen no es una tontería, y el bloque 🏷️ con
`be-fase-01-…` y prefijo `be01:`. Añade a las fuentes: **be00 ya cerrada** y su
`CONTRACT.md`.

## Identidad de esta fase

- Fase be01 de be07 — 🐘 Lumen sobre PHP 7.4, y la familiaridad falsa
- Horas: **10h**
- Depende de: be00
- Habilita: be02
- Apéndices de apoyo: **bea-01** (PHP y Lumen para quien no escribe PHP),
  **bea-02** (receta de imagen y compose), **bea-03** (el contenedor, los
  facades y por qué `grep` falla)
- Incidentes reservados: **be-01**, **be-02**
- Estado: Opcional 🔥 — **es una de las dos fases insignia del track**

## Alcance

- **Propósito (una línea):** Levantar el monolito de 2016 y descubrir, en carne
  propia, que parecerse a Laravel es peor que no parecerse a nada.
- **Qué entra:** el `composer.json` y la forma del monolito; **el bootstrap de
  Lumen, que no es el de Laravel**; rutas, middleware y el contenedor;
  `$app->withFacades()` y qué cambia según esté encendido o apagado;
  `GET /health` como primer endpoint vivo; y la reimplementación del **inyector de
  caos** con los mismos modos y vías de activación que el mock, incluida la del
  TTL del token.
- **Y la mitad de la fase son los cuatro bugs de la familiaridad falsa**,
  provocados a propósito:
  1. El `grep` de `Cache::get` que devuelve **cero resultados** sobre un método
     que sí se ejecuta — es `__callStatic` resolviendo contra el contenedor.
  2. **En Lumen los facades están apagados por defecto.** El ejemplo de internet
     funciona en Laravel y aquí lanza *class not found*… o peor, funciona a medias
     porque alguien los encendió a medias.
  3. El `scopeActive()` invocado como `Model::active()`, que no aparece buscando
     `active(`.
  4. Lo que Lumen **quitó** de Laravel: sesiones, parte de eventos y de
     middleware. La respuesta de internet asume que están.
- **El ejercicio de diez minutos que cierra la fase, y es el mejor material del
  track:** pregúntale a un asistente cómo se hace X en Lumen, copia la respuesta,
  y mide en qué falla. No falla por ignorancia: **falla porque contesta en
  Laravel, con confianza.**
  > 🧠 La ausencia de respuesta te vuelve cuidadoso; la respuesta plausible te
  > vuelve confiado.
- **Qué NO entra (se difiere a be03):** cualquier acceso a PostgreSQL. Esta fase
  sirve datos fijos.
- **Prueba de fuego:** el alumno tiene que poder repetir los ejercicios de caos de
  la Fase 3 del track base contra el backend nuevo, sin cambios.
- **Pieza forense:** el `grep` vacío. En un curso construido sobre buscar en el
  código, tener una capa donde buscar **no sirve** es el reflejo que hay que
  romper.
- **Ejercicios:** 30-35. Es una fase densa.

## Pendientes que pueden bloquear esta fase

- ⚠️ **Fijar la versión exacta de Lumen** que corresponde a 2016-2018 y **en qué
  PHP dejó de arrancar**. Decide el ticket que abre el track (*"seguridad exige
  subir a PHP 8 y Lumen 5.x no arranca ahí"*), así que hay que cerrarlo aquí.
  Verifícalo contra Packagist y el changelog, **no de memoria**.

## Audiencia

Dev backend senior que **puede no haber escrito PHP nunca**, o que escribió PHP 5
hace diez años. No le expliques qué es un framework MVC ni la inyección de
dependencias. Sí explícale lo que PHP hace distinto: el modelo de ejecución
*shared-nothing* —que es la diferencia conceptual grande con cualquier backend de
proceso persistente—, el tipado gradual, y los arrays que son dos cosas a la vez.
La sintaxis se delega a `bea-01`: enlaza, no reexpliques.

## Cómo quiero que trabajes

Protocolo de tres pasos: (1) preguntas bloqueantes numeradas, lectura del alcance
con las 10h, esbozo de la sección 5 y contradicciones — **sin redactar todavía**;
(2) redacción cuando yo responda, parando a preguntar si aparece una duda nueva;
(3) autoverificación contra §14 de la guía. Vigila especialmente que los cuatro
bugs queden **demostrados con código que se ejecuta**, no descritos.
```

---

## # Fase be02 — Estratos por procedencia: de dónde venía quien escribió esto

```markdown
Este es el chat de la **Fase be02 — 🧬 Estratos por procedencia**, del track BE
opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable es
`be02-estratos-por-procedencia.md`.

## Marco (no lo repitas, aplícalo)

El mismo del track. Añade: **be01 ya cerrada**, y los ejercicios 🧬 del track base
—*"¿este archivo es de 2021 o de 2024?"*—, que esta fase continúa girando el eje.
Bloque 🏷️ con `be-fase-02-…` y prefijo `be02:`.

## Identidad de esta fase

- Fase be02 de be07 — 🧬 Estratos por procedencia: de dónde venía quien escribió esto
- Horas: **8h**
- Depende de: be01
- Habilita: be03
- Apéndices de apoyo: **bea-09** (Symfony como vara de medir), **bea-03**
- Incidentes reservados: **be-03**
- Estado: Opcional 🔥

## Alcance

- **Propósito (una línea):** Leer el código heredado clasificándolo por la
  procedencia de quien lo escribió, y medir cuántos estilos conviven.
- **La rima con el track base, y es la razón de que esta fase exista.** Los
  ejercicios 🧬 de Angular 16 preguntan *"¿este archivo es de 2021 o de 2024?"* —
  estratos **por fecha**. Aquí la pregunta es otra:
  > 🧠 **El dev que llega deja huella según de dónde venga.** El de Laravel asume
  > facades, contenedor completo y `config()`. El de Symfony mete inyección por
  > constructor y servicios donde el resto usa *service locator*. El de CakePHP
  > arrastra Active Record y convenciones de tabla que aquí no existen. **El bug
  > te dice de dónde venía quien lo escribió.**
- **La causa, que está en la Era 0 de la historia:** el mercado de devs **PHP** es
  enorme; el de devs **Lumen** no existe. Todos los que pasaron llegaron
  reciclados de otro sitio, se formaron a costa de la empresa, y se fueron en año
  y medio. **Economía de rotación:** se paga el onboarding una y otra vez y nunca
  se amortiza.
- **Qué entra:** la clasificación archivo por archivo; el conteo —**medir, no
  suponer**— de cuántas maneras hay de hacer una consulta, de inyectar una
  dependencia y de manejar un error; y el inventario que sale de ahí, que es el
  insumo directo del *assessment* de be07.
- **Qué NO entra:** uniformar nada. Esta fase mide. Y el track nunca uniforma: esa
  es la doctrina del curso base y aquí se respeta.
- **Pieza forense:** dos endpoints vecinos que hacen lo mismo de dos maneras
  correctas y distintas. **Ninguno está mal**, exactamente como los dos estilos de
  inyección del track base. Uniformarlos no es el trabajo; saber cuál tocar sí.
- **Deuda que cobra:** la deuda de plantilla, que no se ve desde el navegador y
  que ningún material técnico trata.
- **Ejercicios:** 28-30, con peso alto en diagnóstico: casi todos son de
  clasificación y medición.

## Pendientes que pueden bloquear esta fase

- **Decide y déjalo escrito:** cuántas procedencias se modelan. Propongo tres
  —Laravel, Symfony, CakePHP— porque son las del mercado real y cada una deja una
  huella distinguible. Cuatro empieza a ser caricatura.

## Audiencia

Dev backend senior que ya tiene entrenado el ojo 🧬 del track base. Esta fase le da
un segundo eje para el mismo músculo.

## Cómo quiero que trabajes

Protocolo de tres pasos. En el paso 1 quiero **las tres huellas concretas**, con
ejemplo de código de cada una, antes de redactar: si no son distinguibles a simple
vista, la fase no funciona.
```

---

## # Fase be03 — El reemplazo: de `db.json` a Postgres 16

```markdown
Este es el chat de la **Fase be03 — 🗄️ El reemplazo: de `db.json` a Postgres 16**,
del track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable
es `be03-el-reemplazo.md`.

## Marco (no lo repitas, aplícalo)

El mismo del track. Añade: **be02 ya cerrada**. Bloque 🏷️ con `be-fase-03-…` y
prefijo `be03:`.

## Identidad de esta fase

- Fase be03 de be07 — 🗄️ El reemplazo: de `db.json` a Postgres 16
- Horas: **10h**
- Depende de: be02
- Habilita: be04
- Apéndices de apoyo: **bea-04** (Eloquent: lo que absorbe y lo que no)
- Incidentes reservados: **be-04**, **be-05**
- Estado: Opcional 🔥

## Alcance

- **Propósito (una línea):** Apagar el mock y que la aplicación no se entere.
- **Es la bisagra del track.** La señal de éxito se verifica: *"apagué `npm run
  mock`, levanté el contenedor en el 3000, y la única forma de notar el cambio fue
  que la lista de inspecciones tardó 40 ms más."*
- **Qué entra:** las migraciones y el esquema de `clients`, `assets`, `templates`,
  `inspections`, `findings`, `certificates` y `users`; los modelos de Eloquent; la
  paginación de servidor que la API nunca expuso, servida **en el dialecto del
  mock**; el `id` compuesto de las plantillas traducido a clave primaria de
  verdad; la siembra desde el `db.json` que el alumno ya tiene; y la absorción del
  login de `mock/auth.js`.
- **El hallazgo incómodo de la fase:** `certificates.status` **es una columna**. El
  track base ya lo señaló como error de diseño puesto a propósito (ejercicio 21 de
  la Fase 10). Aquí se ve la columna, **se cuenta cuántas filas mienten hoy**, y
  se difiere la corrección a be05.
- **Qué NO entra:** el salto de versión (be04), la invariante de plantillas
  (be05). Aquí solo se sirve el contrato.
- **La semilla sale del `db.json` del propio alumno**, no de un dump. Que los
  datos sean los mismos que vio en el track base —la inspección 501 con su v1, la
  503 rechazada con su hallazgo crítico— es la mitad del efecto de la fase.
- **Pieza forense:** el primer `smoke.sh` en rojo. Un `id` que salió como `7` en
  vez de `"elevator-annual-v2"` y una pantalla en blanco. El contrato es el juez.
- **Deuda del track base que cobra:** 💸 1 (el objeto completo sin paginar) y el
  diagnóstico de 💸 2 (el `status` guardado).
- **Ejercicios:** 30-32.

## Pendientes que pueden bloquear esta fase

- **Decide y déjalo escrito:** si `templates` lleva clave primaria compuesta
  (`template_id` + `version`) o una columna `id` de texto con el compuesto. Propongo
  la primera, porque es la que hace posible la clave foránea compuesta de be05 — y
  esa decisión es justamente la que el sistema de 2016 **no** tomó.

## Audiencia

Dev backend senior. Ya clasificó el código heredado en be02; ahora tiene que
servirlo respetando un contrato que no diseñó.

## Cómo quiero que trabajes

Protocolo de tres pasos. En el paso 1 quiero explícitamente **el esquema completo
de las siete tablas**, porque be04 y be05 se apoyan entero en él.
```

---

## # Fase be04 — El salto de versión que nadie corrió

```markdown
Este es el chat de la **Fase be04 — 📅 El salto de versión que nadie corrió**, del
track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable es
`be04-el-salto-de-version-que-nadie-corrio.md`.

## Marco (no lo repitas, aplícalo)

El mismo del track. Añade: **be03 ya cerrada**, la Era 0 de
`00-historia-del-sistema.md` —de donde sale la cadena de upgrades— y
`00-convencion-de-git-y-tags.md`, porque esta fase produce un incidente que **no
tiene commit**. Bloque 🏷️ con `be-fase-04-…` y prefijo `be04:`.

## Identidad de esta fase

- Fase be04 de be07 — 📅 El salto de versión que nadie corrió: 9.6 → 11 → 13 → 16
- Horas: **10h**
- Depende de: be03
- Habilita: be05
- Apéndices de apoyo: **bea-05** (dialectos y saltos de versión), **bea-04** ⭐
  (Eloquent: lo que absorbe y lo que no — es el que explica **por qué la factura
  la paga el SQL a mano**), **bea-07** (tiempo y `TIMESTAMPTZ`), **bea-02**
  (el `.env`)
- Incidentes reservados: **be-06** ⭐, **be-07**, **be-08**
- Estado: Opcional 🔥

## Alcance

- **Propósito (una línea):** Investigar un incidente cuyo `git log` está vacío.
- **La asimetría que funda la fase**, ya escrita en la Era 0: a la infraestructura
  la actualizan, a la aplicación no. La base tenía dueño; el código no tenía
  ninguno.
- **El motivo, que es concreto y con culpable:** el proveedor gestionado anunció
  fin de soporte y subió la versión en una ventana de mantenimiento, con un correo
  que alguien archivó. Con la ironía que el dominio pone gratis: fue una
  **auditoría de cumplimiento** la que lo exigió. *La certificadora no pasaba su
  propia auditoría.*
- **Qué entra:** la tabla de evidencia con los cuatro escalones y sus fechas; el
  upgrade ejecutado **cambiando una línea del `.env`**; y el inventario de lo que
  se rompió — código que asumía `WITH OIDS`, eliminado en PG 12 ⚠️; escapado
  manual de comillas, de la era previa a `standard_conforming_strings` ⚠️;
  comparaciones que dependían de casts implícitos que Postgres retiró ⚠️; y las
  columnas `timestamp` **sin zona**, de donde sale la cicatriz del certificado que
  *"venció ayer para el servidor y vence hoy"* (Fase 10 del track base).
- **Los dos matices que evitan el cuento, obligatorios los dos:**
  1. Nada se rompió a lo grande **precisamente porque Postgres es muy bueno en
     compatibilidad hacia atrás**. El 95% siguió funcionando y por eso nadie miró.
     **La calidad de la compatibilidad es lo que permitió el abandono.** Paradoja
     real, sin villanos fabricados.
  2. **La factura la paga exactamente el código que se saltó las convenciones.**
     Eloquent absorbe casi todos los cambios de dialecto; lo que no absorbe es el
     `DB::select()` con SQL a mano que alguien escribió para ir más rápido. Para
     diseñar ejercicios es un regalo: dice **dónde** ponerlos sin adivinar.
- **Pieza forense ⭐:** el incidente cuyo `git log` está vacío. El cambio no está
  en el árbol de fuentes: está en `POSTGRES_TAG` del `.env`. El alumno hace lo que
  hace siempre —`git log`, `git blame`, revisar el último despliegue— y no
  encuentra nada, **porque no hay nada**. Como el "cambio" es una línea de un
  archivo que no es código, **no fuerza ninguna convención de tags** y ese
  incidente no tiene par `-roto`/`-fix`.
- **Deuda del track base que cobra:** 💸 4 (las fechas sin zona).
- **Ejercicios:** 30-33.

## Pendientes que pueden bloquear esta fase

- ⚠️ Fijar los tags exactos de los escalones (`9.6.x`, `11.x`, `13.x`) y
  **verificar los tres cambios de dialecto** contra las notas de release
  oficiales. Son el contenido central de la fase: citarlos de memoria no vale.

## Audiencia

Dev backend senior con el reflejo de `git blame` muy entrenado. Esta fase existe
para romperlo.

## Cómo quiero que trabajes

Protocolo de tres pasos. En el paso 1 dime **cómo vas a presentar el incidente sin
que el alumno adivine el truco en el primer párrafo**, y **cuáles de los tres
cambios de dialecto has verificado** y con qué fuente.
```

---

## # Fase be05 — La invariante que no sostenía nadie ⭐

```markdown
Este es el chat de la **Fase be05 — ⭐ La invariante que no sostenía nadie**, del
track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable es
`be05-la-invariante-que-no-sostenia-nadie.md`.

## Marco (no lo repitas, aplícalo)

El mismo del track. Añade: **be04 ya cerrada**, la **Fase 7 del track base**
(`07-plantillas-versionadas.md`) que es el corazón del curso, y la Fase 10
(`10-certificados-vigencia.md`). Bloque 🏷️ con `be-fase-05-…` y prefijo `be05:`.

## Identidad de esta fase

- Fase be05 de be07 — ⭐ La invariante que no sostenía nadie
- Horas: **10h**
- Depende de: be04
- Habilita: be06
- Apéndices de apoyo: **bea-06** (restricciones, claves compuestas y datos
  sucios), **bea-11** (volumen)
- Incidentes reservados: **be-09**, **be-10**
- Estado: Opcional 🔥 — **es la fase insignia del track y la que cierra el círculo
  con el corazón del curso base**

## Alcance

- **Propósito (una línea):** Descubrir que el bug estrella del track base no era
  un bug de frontend.
- **El punto de partida está escrito y el alumno ya lo vivió.** La Fase 7 del
  curso base enseña el síntoma: *una inspección de hace un año se está renderizando
  con la plantilla de hoy*. Lo arregló en el frontend y estuvo bien. Esta fase
  muestra dónde estaba la causa.
  > 🧠 **La mitad de los bugs que parecían del frontend no lo eran.**
- **Qué entra:** la invariante enunciada en una línea —*una inspección se lee
  siempre contra la versión de plantilla que estaba vigente cuando se ejecutó*— y
  la comprobación de que **ninguna restricción de la base la sostiene**:
  `inspections` guarda `template_id` y `template_version` como dos columnas
  sueltas, sin clave foránea compuesta contra `templates`. La consulta que
  encuentra las filas que ya la violan. Y el `certificates.status` de be03,
  convertido en **derivado**.
- **Las tres salidas realistas, costeadas y medidas:** clave foránea compuesta
  (qué se rompe al añadirla sobre datos sucios, con `NOT VALID` y
  `VALIDATE CONSTRAINT`), restricción `CHECK` con función, o disciplina de
  aplicación documentada.
- 🧭 **La frase que gobierna la fase:** *una invariante que nadie sostiene no está
  rota: está esperando.* El sistema funcionó ocho años porque nadie borró una
  plantilla vieja. El día que alguien lo haga, la auditoría encuentra inspecciones
  renderizadas con la norma equivocada — y en una certificadora eso no es un bug
  de interfaz.
- **Qué NO entra:** la reescritura a medias (be06) y el *assessment* (be07).
- **Aquí se entrega volumen sintético** —cuatro mil inspecciones, con las
  violaciones ya adentro—, porque con cinco no se mide nada. Es la única vez que el
  track da datos ajenos y la fase lo declara. Generador documentado en `bea-11`.
- **Pieza forense:** la fila de `inspections` que apunta a una `template_version`
  que ya no existe, y el `EXPLAIN` de la consulta que la encuentra en cuatro mil
  filas.
- **Deuda del track base que cobra:** ⭐ 3, la invariante de plantillas
  versionadas.
- **Ejercicios:** 30-35.

## Pendientes que pueden bloquear esta fase

- Nada bloqueante. **Decide y déjalo escrito:** cuál de las tres salidas recomienda
  el track. Propongo la clave foránea compuesta con `NOT VALID`, porque es la que
  permite poner la restricción hoy sin tocar las filas sucias — y eso es
  exactamente la doctrina de contención del repositorio.

## Audiencia

Dev backend senior con reflejo de integridad referencial intacto. No le expliques
qué es una clave foránea: explícale qué haces cuando llevas ocho años sin una y los
datos ya la violan.

## Cómo quiero que trabajes

Protocolo de tres pasos. En el paso 1 quiero **la consulta que encuentra las
violaciones**, escrita, y tu plan para la restricción sobre datos sucios.
```

---

## # Fase be06 — La reescritura que se quedó a medias

```markdown
Este es el chat de la **Fase be06 — 🧱 La reescritura que se quedó a medias**, del
track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable es
`be06-la-reescritura-a-medias.md`.

## Marco (no lo repitas, aplícalo)

El mismo del track. Añade: **be05 ya cerrada**. Bloque 🏷️ con `be-fase-06-…` y
prefijo `be06:`.

## Identidad de esta fase

- Fase be06 de be07 — 🧱 La reescritura que se quedó a medias
- Horas: **8h**
- Depende de: be05
- Habilita: be07
- Apéndices de apoyo: **bea-08** (seguridad de API sobre un runtime sin parches),
  **bea-09** (Symfony como vara de medir)
- Incidentes reservados: **be-11**
- Estado: Opcional 🔥

## Alcance

- **Propósito (una línea):** Medir el coste del estado intermedio, que es el más
  caro de todos.
- **La historia:** en algún momento alguien empezó a mover el sistema hacia Laravel
  completo —o hacia servicios, o hacia lo que fuera— y se fue antes de terminar.
  Quedaron **dos maneras de hacer lo mismo, las dos vivas**, y nadie sabe cuál es
  la buena. Es la consecuencia directa de la economía de rotación de be02.
- **Qué entra:** medir la superficie de la reescritura a medias —qué endpoints se
  movieron y cuáles no—; entender por qué el camino de vuelta de Lumen a Laravel
  **no es un upgrade, es un trasplante de bootstrap**; y **las pruebas**, que
  llegan aquí y no antes por una razón que hay que escribir: *no se puede probar lo
  que no se ha decidido cuál es*.
- **La conversación honesta que la fase obliga a tener:** terminar una migración
  que otro empezó suele costar más que empezarla de cero, **y aun así casi siempre
  es la respuesta correcta**, porque el estado intermedio es el más caro de todos.
- **PHP 7.4 EOL no se arregla aquí.** Es la premisa del track, no un pendiente.
  Cualquier propuesta de subir a PHP 8 es el trasplante de bootstrap, y esa
  conversación es del *assessment* de be07. Nómbralo y difiérelo.
- **Pieza forense:** el mismo recurso servido por dos caminos, con comportamientos
  distintos ante el mismo error. El ticket dice *"a veces devuelve 500 y a veces
  422"* y **tiene razón**: depende de por dónde entres.
- **Ejercicios:** 28-30.

## Pendientes que pueden bloquear esta fase

- ⚠️ **Fijar la versión de PHPUnit** de la línea de Lumen elegida, y decidir la
  estrategia de pruebas —contra el `postgres:16.9` del compose, limpiando entre
  tests— **midiendo el tiempo de ciclo**, que es el criterio que gobierna el track.
- ⚠️ **El estado oficial de Lumen frente a Laravel + Octane.** Es una cita, y tiene
  que salir de la documentación oficial.

## Audiencia

Dev backend senior que probablemente haya heredado una migración a medias y nunca
le haya puesto número.

## Cómo quiero que trabajes

Protocolo de tres pasos. En el paso 1 dime **cómo vas a medir la superficie** de la
reescritura a medias: sin ese número la fase es una anécdota.
```

---

## # Fase be07 — El *assessment* de riesgo tecnológico

```markdown
Este es el chat de la **Fase be07 — 📊 El *assessment* de riesgo tecnológico**, del
track BE opcional 🔥 del tutorial Angular 16 + CertCore. Su único entregable es
`be07-el-assessment-de-riesgo.md`.

## Marco (no lo repitas, aplícalo)

El mismo del track. Añade: **be00 a be06 cerradas**, porque esta fase consume los
números que todas produjeron. Bloque 🏷️ con `be-fase-07-…` y prefijo `be07:`.

## Identidad de esta fase

- Fase be07 de be07 — 📊 El *assessment* de riesgo tecnológico
- Horas: **10h**
- Depende de: todas las anteriores
- Habilita: nada. Es el cierre del track.
- Apéndices de apoyo: **bea-09** (Symfony como vara de medir), **bea-10** (mapa
  de deuda del track BE), **bea-08** (seguridad de API sobre un runtime sin
  parches — el riesgo que costea la opción 4, *no hacer nada*)
- Incidentes reservados: **be-12**
- Estado: Opcional 🔥

## Alcance

- **Propósito (una línea):** Escribir y defender el documento que ningún tutorial
  de internet enseña a producir, porque todos terminan en el *happy path* del
  rewrite.
- **El cierre no es código.** Es un *assessment* con **cuatro opciones costeadas**,
  todas con los números que las siete fases anteriores produjeron:
  1. **Quedarse y formar.** Cuánto cuesta, cuánto tarda, y qué pasa si el formado
     se va también — que es lo que pasó las últimas tres veces (be02).
  2. **Reescribir a un lenguaje aburrido y sostenido.** El coste real, no el
     optimista, y qué se rompe mientras. **Symfony es la vara**: su disciplina de
     deprecaciones y sus LTS cada dos años son el contraste exacto que hace visible
     que Lumen no tenía ninguna (`bea-09`).
  3. **Estrangular por endpoint.** Un proxy delante, se migra la ruta más
     dolorosa, se mide. Probablemente la respuesta correcta y la más aburrida.
  4. **No hacer nada y documentar el riesgo.** A veces gana, y **saber cuándo gana
     es seniority**.
- 🧭 **La regla que gobierna la fase:** *la respuesta correcta depende de la fecha
  de decomisión, no de la calidad del código.* Un sistema con dos años de vida por
  delante y uno con diez no reciben la misma respuesta aunque el código sea
  idéntico.
- **El cierre honesto obligatorio: dónde Lumen de verdad ganó.** Aprovechar el
  equipo de PHP que la empresa ya tenía fue una ventaja real y medible durante
  años. **Pon el número de las dos columnas**, o el track no ha entendido su propio
  criterio.
- **El incidente be-12 es adversarial:** un *assessment* que recomienda el rewrite
  sin datos que lo sostengan. El alumno tiene que desmontarlo.
- **Ejercicios:** 25-28, con peso en los 🔴: escribir y defender el documento es el
  ejercicio final del track.

## Pendientes que pueden bloquear esta fase

- Nada bloqueante, si las seis fases anteriores dejaron sus números. **Si alguna no
  los dejó, dímelo:** este documento no se puede escribir con estimaciones
  inventadas, y eso es precisamente lo que enseña.

## Audiencia

Dev backend senior que va a tener que defender esta decisión ante alguien que
prefiere el rewrite. Dale los números para hacerlo.

## Cómo quiero que trabajes

Protocolo de tres pasos. En el paso 1 quiero **el índice del *assessment*** y, por
cada una de las cuatro opciones, **de qué fase sale el número** que la costea. Si
alguna no tiene fuente, es que falta contenido antes.
```

---

## 🧾 Recordatorio de cierre del track

Cuando las ocho fases estén escritas, quedan dos piezas fuera de este archivo:

1. ✅ **`prompts-backend-apendice.md`** — los once prompts de `bea-01` … `bea-11`
   **ya están escritos**. Lo que falta son los apéndices en sí, que se redactan
   **bajo demanda, cuando una fase los referencia**, y no en bloque ni en orden.
   Las dos listas se leen en las dos direcciones: cada fase declara sus
   *«Apéndices de apoyo»* y cada apéndice su *«Usado por»*, y **tienen que decir
   lo mismo** — si una fase gana un apéndice, el apéndice gana esa fase.
2. ✅ **`cuaderno-incidentes-be.md`** — **escrito el 11/09/2026** con los doce
   incidentes reservados en los prompts de arriba (`be-01` … `be-12`), IDs propios
   y sin mezclarse con el cuaderno base. Su material de autoría —el estado roto de
   cada uno— está en `prompts/preparaciones-de-incidentes-be.md`.
3. **Las adiciones de encuadre de §10 de `propuesta-fases-backend.md`**, que se
   hacen **antes** de escribir `be00` — incluida **§10.2**, la única que toca la
   ficción publicada y que ya está resuelta en `00-historia-del-sistema.md` con la
   Era 0.
