# 🗓️ Plan de edición: Plomada y los tres países
## Tutorial Angular 16 — CertCore, de Andina de Certificaciones a Plomada Ingeniería de Inspección

Este documento dice **qué cambia en el curso por la historia nueva y por la alineación con
`zz-instrucciones/`, en qué orden y cuándo una tanda está terminada**. El curso ya existe completo
(15 fases, 13 apéndices, 15 piezas forenses, 20 incidentes; track BE de 8 fases, 11 apéndices y 12
incidentes). La edición **no toca la estructura**: cambia el contexto (empresa, gente, tres países),
corrige el origen de la API en el track BE, alinea `prompts/` con los lineamientos y agrega **dos
incidentes con código**: el 21 (Galápagos) y el 22 (el RUC).

Es un **plan de edición** y no un plan de producción, como excepción declarada (D7): son pocos
cambios de contenido sobre un curso cerrado, y la plantilla completa de
`zz-instrucciones/plantillas/plan-de-produccion.md` sobraría. Se conservan sus piezas operativas:
reglas de orden, estado, tandas, verificaciones, bitácora y checklist.

- **El qué** lo manda [`../00-historia-del-sistema.md`](../00-historia-del-sistema.md), cerrada el
  2026-10-07. **Ningún dato narrativo se inventa en una tanda**: si falta, se agrega primero ahí.
- **La forma**, [`guia-de-estilo-y-convenciones.md`](guia-de-estilo-y-convenciones.md): §11
  (coherencia de la ficción), §13 (incidentes), §14 (checklist) y §15.5 (ficción del track BE).
- **El formato de incidentes**, [`formato-cuaderno-incidentes.md`](formato-cuaderno-incidentes.md)
  y [`preparaciones-de-incidentes.md`](preparaciones-de-incidentes.md).
- **El orden**, este documento.

> **Caducidad:** desechable. **No se cita desde ninguna fase, apéndice ni README.** Al cerrar T7 se
> borra con permiso del autor; lo que deba sobrevivir pasa a la guía (§16).
>
> **Vigencia:** 2026-10-07. **Todas las decisiones están cerradas. Siguiente paso: T2.**

**Salto rápido:** [0](#0--cómo-se-retoma) · [1](#1--decisiones-todas-cerradas) · [2](#2--reglas-de-orden) · [3](#3--estado) · [4](#4--inventario-del-impacto) · [5](#5--las-tandas) · [6](#6--hechos-por-verificar) · [7](#7--bitácora) · [8](#8--checklist-final) · [9](#9--directorios-de-zz-code)

---

## 0. 🚪 Cómo se retoma

Cada sesión lee, en este orden: este plan (§1, §2, §3 y §7), la historia, `zz-instrucciones/README.md`
y `zz-instrucciones/03-lecciones-de-produccion.md`. Después abre **una** tanda de §5 y aplica el
protocolo de tres pasos de `zz-instrucciones/00-workflow-de-un-curso.md` §2: preguntas sin redactar,
redacción, autoverificación contra la guía §14. Al cerrar, actualiza §3, §7 y §8.

Prompt para pegar al abrir la sesión (cambiando `T2` por la tanda que toque):

```text
Curso: cursos-legacy/angular-16-legacy-for-backend-devs. Vamos a ejecutar la tanda T2 del plan
prompts/_desechable-plan-de-edicion.md. Lee el plan (§0–§3 y §7), la historia
00-historia-del-sistema.md, zz-instrucciones/README.md y zz-instrucciones/03-lecciones-de-produccion.md.
Todas las decisiones (D1–D20) están cerradas: no las reabras; si una no se sostiene, para y pregunta.
Paso 1: dime qué vas a tocar y tus preguntas, sin redactar. Sin agentes, git lo hago yo, pruebas en
contenedor y código en zz-code/. Al cerrar, actualiza §3, §7 y §8 del plan.
```

---

## 1. 🧭 Decisiones (todas cerradas)

### 1.1 La historia (2026-10-06 y 2026-10-07)

- **D1 — Escenario:** empresa colombiana que se vuelve regional siguiendo a un cliente: matriz en
  Bogotá (2012, acreditada por ONAC en 2013), filial en Lima (2019, compra de Inspecciones Rímac) y en
  Quito (2021, socio local; acreditada por el SAE).
- **D2 — Nombre:** **Plomada Ingeniería de Inspección S.A.S.**; filiales *Plomada Perú S.A.C.* y
  *Plomada Ecuador Cía. Ltda.* Sale "Andina de Certificaciones" (choca con *Andina Laboratories* de
  LabCore); se descartó "Cóndor" (*Cóndor MRO* de Ruta NoSQL Lite y una constructora real).
- **D3 — Cómo llegó el software:**
  - **Wilson Arévalo**, independiente que venía de .NET en un banco, escribe `certcore-api` en
    PHP/Lumen por costo de licencias y hosting (09/2016–03/2018).
  - Licitación entre dos consultoras pequeñas: gana **Teusacá Software** (bolsa de horas: **Ferney
    Castillo**, Laravel, 04/2018–09/2019; **Fernando Rubio**, CakePHP, 01/2020–06/2021); pierde
    **Sabana Labs**, que en 2021 hace el piloto Angular a precio fijo con **Diego Moncada**, **Jimena
    Galeano** y **Renzo Chávez**.
  - **Reestructuración de 2022:** una consultoría organizacional crea la **gerencia de sistemas**, con
    soporte técnico (**Wilmer Cubillos**) y desarrollo. **Wilson vuelve por horas y seis meses** como
    gerente encargado: pasa a planta a Diego y Jimena, escribe las prácticas (UAT antes de producción,
    tablero de tickets, tags por versión, despliegues los martes; pruebas "para la siguiente etapa") y
    deja la API fuera con un acta: *"certcore-api funciona; no se toca sin un plan"*.
  - **Hernando Gil**, gerente de sistemas de planta desde 2023, cancela la bolsa de Teusacá y contrata
    a la freelance limeña **Tatiana Fernández** (Symfony, 07/2023–12/2024).
  - Cada autor de la API duró **dieciocho meses**; la vuelta de Wilson no cuenta como autoría.
- **D3b — El cliente regional:** **Aurum Suites**, hoteles para ejecutivos en viaje de negocios
  (torres de suites, convenios corporativos). El certificado es un **requisito de venta**: lo exige su
  estándar de marca en todas sus propiedades.
- **D18 — Galápagos:** **Aurum Inn Galápagos** (2024), piloto de convenciones con turismo
  (convención de ventas de un laboratorio con un día de buceo; viajes de incentivo). Por la LOREG
  (2015) Aurum no construye: opera la hostería de la familia Chiriboga, residentes permanentes; el
  cliente de Plomada es *Hostería Chiriboga Cía. Ltda.*, con RUC de 13 dígitos. Sin ascensor: se
  certifican caldera (`boiler-annual-ec`), red contra incendio y tanques, porque lo pide el contrato,
  no la ley. Dos inspectores de Guayaquil, un viaje al año.
- **D15 — Escena de apertura:** la auditora regional de Aurum, desde Quito, revisa la torre de
  **Bogotá**; el ítem en blanco es de `elevator-annual` v2, plantilla colombiana.
- **D19 — Nombres:** **Jeimy Paola Rozo** (calidad, 36 años) y **Jimena Galeano**. **Vetados:**
  *Quispe*, *Lucía Cárdenas*, *Luz Marina* y *Martha Lucía* (están en otros cursos), *Ospina* (LabCore),
  *Cordillera* (curso de C#). Antes de nombrar a alguien nuevo, `grep` en todo el repo.
- **D4 — be-12:** el informe es de **Sabana Labs** y lo reporta "el gerente de sistemas", Hernando.
- **D20 — El acta de Wilson** se cita en be00 (el contrato) y be07 (el *assessment*), y be-12 la usa
  como el dato que nadie actualizó.

### 1.2 El curso (2026-10-07)

- **D5 — Sí se toca código.** **D8 — El país entra por los incidentes, no por la semilla:**
  `db.seed.json`, los modelos de F03 y el código de las fases quedan como están; el país aparece en los
  `mock/db.incidente-NN.json` y en los fixes. Es lo que dice la historia §6 ("tampoco hay país como
  concepto de primera clase").
- **D9 / D6 — Incidente 21, Galápagos.** Cuaderno base, **fase 10, 🟠, 45 min**. El certificado de un
  activo del Inn vence a las `23:59:59-05:00`, que en Puerto Ayora son las 22:59: entre las 23:00 y las
  23:59 del último día, hora local, figura vencido. Causa: `CERTCORE_TIME_ZONE_OFFSET` de F07, cuyo
  comentario ya avisa que el día que CertCore opere en otra zona "este archivo entero cambia". El fix
  lleva la zona al activo y usa `Intl` con `America/Galapagos`, sin tocar los activos continentales.
  Distinto del 15 (UTC contra hora local) y del be-08 (servidor contra PDF).
- **D10 — Incidente 22, el RUC.** Cuaderno base, **fase 06, 🟡, 30 min**. *"No me deja crear el
  cliente de Galápagos: dice que el NIT debe tener entre 9 y 10 dígitos."* El validador de F06 es
  `/^\d{9,10}$/`; el RUC tiene 11 dígitos en Perú y 13 en Ecuador. Los clientes de Lima y Quito
  entraron por script a la API (2019); la hostería es el primero que alguien crea desde la pantalla. El
  fix valida por país sin romper el chequeo asíncrono de duplicados.
- **D11 — Plantillas por país, por nombre y sin campo:** las familias sin sufijo son colombianas; las
  otras llevan `-pe` o `-ec` y solo existen en los datos de incidentes que las necesiten.
- **D12 — Sin Mermaid en esta edición.** Los diagramas de todo `cursos-legacy/` van en otra sesión.
- **D13 — `prompts/` plegado a `zz-instrucciones/` con `docker-container-legacy` como modelo:** los
  documentos y su numeración se quedan (la numeración de un documento rector es una interfaz
  publicada); la guía gana una §16 de excepciones; se copian `verificador_base.py` y una subclase
  `verificar-corpus.py`; se escribe `prompts/README.md`.
- **D14** aplicada en la historia (fechas de 18 meses). **D16** hecha (la v2 es
  `00-historia-del-sistema.md`). **D17 — Horas:** cuaderno de 14 h a 15 h; curso de 122 h a 123 h.
- **D7 — Este plan es desechable** y de edición, no de producción.

---

## 2. 🧱 Reglas de orden

1. **Las decisiones no se reabren.** Si una tanda descubre que una no se sostiene, para y consulta.
2. **Cada tanda deja el curso coherente hasta donde llega.** Si cambia un nombre, una fecha o un dato,
   cambia en la misma sesión todos los lugares que lo repiten (fase, forense, cuaderno, preparaciones,
   prompts). Lo que no se cierra se anota en §7.
3. **La aritmética de tiempo se comprueba ejecutando.** Toda conversión con `America/Galapagos`,
   `America/Bogota`, `America/Lima` o `America/Guayaquil` se verifica con Node en contenedor y la
   salida queda en `zz-code/`.
4. **Todo código que la edición toca se ejecuta antes de publicarse**, aunque el cambio sea un
   comentario o un literal. Las pruebas no reescriben el código: un script extrae del markdown los
   bloques tal como quedan en la fase y los compila o corre en contenedor —Node 18 y TypeScript para el
   track base, `php:7.4-cli` con `php -l` para el track BE—. Las pruebas van sobre las funciones puras
   de tiempo y de validación, con los modelos de F03 como tipos; no se arma la aplicación Angular
   completa. Cada fix se ve fallar antes y pasar después. Lo que no se pueda correr se marca como no
   verificado en §7.
5. **El README se toca solo en T7.**
6. **Todo en el hilo principal, en secuencia y sin agentes.** Se para al cerrar cada tanda.
7. **Git lo hace el autor.** Nada de `git mv` ni `git rm`; los borrados, con `rm`, archivo por
   archivo. Los tags de los incidentes quedan escritos para que el autor los cree.
8. **Pruebas en contenedor**, con `--label curso=angular16`, puertos altos en `127.0.0.1`, y borrado de
   lo creado (con volúmenes) al cerrar. Nada de `prune`. Nada se instala en el host.
9. **Todo el código de las sesiones va a `zz-code/`** (`python3 zz-code/nuevo.py
   angular-16-legacy-for-backend-devs`), con su `README.md` de corrida y medición. El directorio del
   rescate (`…-20261006-ab79`) está archivado y no se toca.
10. **Ningún nombre nuevo sin `grep`** en todo el repositorio (§1.1, D19).

---

## 3. 📊 Estado

- ✅ **T0 — Historia v2** (2026-10-06).
- ✅ **P1 / P2 — Decisiones D1–D20** (2026-10-06 y 2026-10-07).
- ✅ **T1 — La historia, cerrada** (2026-10-07). Revisión final de coherencia hecha (§7).
- ⬜ **T2 — El track base: el texto.**
- ⬜ **T3 — Incidente 21: Galápagos.**
- ⬜ **T4 — Incidente 22: el RUC.**
- ⬜ **T5 — El track BE.**
- ⬜ **T6 — `prompts/` a los lineamientos.**
- ⬜ **T7 — README, verificación y cierre.**

T3 y T4 pueden ir en cualquier orden, pero los dos después de T2. T6 va después de T3–T5 porque
recoge sus conteos.

---

## 4. 🔎 Inventario del impacto

Medido con `grep` el 2026-10-06 sobre los `.md` del curso (sin la historia). Los números de línea
son aproximados: se buscan por texto, no por número.

- **"Andina de Certificaciones"** — queda 1, en `prompts/propuesta-fases-backend.md` (la historia ya
  cambió).
- **El origen de la API ("el intranet viejo", "dos personas de PHP")**, que D3 reemplaza por licencias
  y hosting: `be00` (~69, ~78), `be02` (~70, ~187), `be07` (~193, ~199),
  `prompts/prompts-backend-fase.md` (~54), `prompts/propuesta-fases-backend.md` (~259, §0.4).
- **Los cuatro autores y los 18 meses**: `be02` (tabla ~70–75, §5.5 ~319, ~505), `be07` (~67, ~129),
  `cuaderno-incidentes-be` (~2019), `prompts/propuesta-fases-backend.md` (~231, ~624). Cambian los
  años de la cuarta (2023–2024), el género del segundo ("el segundo", Ferney), los nombres, y el
  origen del primero (".NET", no "la intranet"). La cifra de 18 meses y las tres rotaciones se quedan.
- **"CertCore opera en Colombia" / "Colombia no tiene horario de verano"** — 12 y 10 menciones:
  `07-plantillas-versionadas` (comentario de `CERTCORE_TIME_ZONE_OFFSET`, ~131), `10-certificados-vigencia`
  (~15, ~74, ~975, ~1275), `bea-07` (~11, ~219), `cuaderno-incidentes-be`,
  `prompts/prompts-backend-apendice.md`. El argumento se amplía: **tres países en UTC−5 sin cambio de
  hora; la excepción es Galápagos**.
- **`Bogotá` / `America/Bogota`** (75 / 33), **`-05:00`** (121), **NIT / `taxId` / `legalName` /
  `S.A.S.`** (50 / 65 / 50 / 13), **`elevator-annual`** (118). **Sin cambio** (D8, D11): Bogotá sigue
  siendo la sede y la semilla es colombiana. Solo se revisan las frases que digan "la única" o "todo
  cliente tiene NIT".
- **LabCore** — 44, casi todas en `a10-migracion-8-16`. **Sin cambio**: el puente es deliberado. El
  error `FUERA` del verificador (`README.md:229 → ../angular-8-legacy-for-backend-devs`) se declara en
  la guía §16.
- **"El jefe de tecnología"** en `be-12` → "el gerente de sistemas", Hernando (D4).
- **Las prácticas de Wilson (2022)**: sin conflicto con F12, F13 ni la convención de git. T2 revisa que
  ninguna fase diga "no hay ambientes" o "no hay proceso".
- **Verificador base** (`--perfil=courses-ia`, 2026-10-06): 1 error (`FUERA`) y 216 avisos (194
  `EMOJI` en `###`, 18 `ENCAB`, 4 `CALLOUT`). `verificar-forenses.py`: 15 piezas, 0 fallos.

---

## 5. 🧩 Las tandas

### T2 — El track base: el texto

- `07-plantillas-versionadas.md`: el comentario de `CERTCORE_TIME_ZONE_OFFSET` ("CertCore opera en
  Colombia…") pasa a "tres países en UTC−5" y conserva la advertencia que el 21 cobra; las tres
  menciones de horario de verano.
- `10-certificados-vigencia.md`: "donde opera CertCore", "en Colombia" (~15, ~74, ~975, ~1275); la
  regla de vigencia, alineada con la historia §10 ("hora local del lugar donde está el activo"); la
  cabecera suma el incidente 21.
- `06-clientes-activos.md`: la cabecera suma el 22; el texto que dé por hecho que todo cliente tiene
  NIT (el código no cambia: el validador de 9–10 dígitos es la deuda que cobra el 22).
- `forense-fase-10.md`, `forense-fase-06.md`: el pie *«Incidentes del cuaderno que usan esta ruta»*.
- `a08-pdf-cliente.md` (pie del PDF con `S.A.S.`), `a13-i18n.md` ("operación local" pasa a "tres
  países, un idioma").
- `grep` de "no hay ambientes", "no hay proceso", "Andina" y "Colombia" en todo el track base.
- **Pruebas** (regla 4): se extrae `src/app/core/time/business-day.ts` como queda tras F07 y lo que F10
  le añade (~105–139), más el bloque del PDF de F10 (~975), y se compila con `tsc --noEmit` en
  contenedor. Se guarda en `zz-code/` la **línea base**: la salida de `toBusinessDay()` y del fin de
  vigencia para un puñado de fechas (fin de día, cambio de mes, 23:00–23:59 en Bogotá). T3 la usa para
  probar que el fix no movió nada en el continente.
- **Cierra cuando:** ninguna frase del track base dice que CertCore opera solo en Colombia, las
  cabeceras de F06 y F10 nombran los incidentes nuevos (como mención en prosa si el destino todavía no
  existe: regla 7 del workflow), y los bloques tocados compilan en contenedor con la línea base
  guardada.

### T3 — Incidente 21: Galápagos

- **Paso 1** (con el autor): el texto del ticket y quién lo reporta. Propuesta: Patricio, reenviando
  el correo del administrador del Inn la noche de una convención; el activo es la caldera, con
  `boiler-annual-ec`.
- Enunciado en `cuaderno-incidentes.md` con la plantilla de `formato-cuaderno-incidentes.md` §7; el
  ID en el índice y en la escala; la escala y las horas del cuaderno (D17).
- Preparación: `mock/db.incidente-21.json` con *Hostería Chiriboga Cía. Ltda.* (RUC de 13 dígitos),
  su activo en Puerto Ayora y un certificado que vence "hoy". Se documenta en
  `prompts/preparaciones-de-incidentes.md`, incluida su caducidad si depende de la fecha (como el 09).
- `zz-code/`: las conversiones de hora (`America/Galapagos` contra `-05:00`) y el fix con su prueba de
  regresión, en contenedor; el README del directorio con la corrida. La prueba cubre:
  - **el roto**: con el código de F10 extraído, el certificado del Inn figura vencido entre las 23:00 y
    las 23:59 del último día, hora de Puerto Ayora;
  - **el fix**: el mismo caso pasa con `Intl` y `America/Galapagos`;
  - **el continente no se movió**: Bogotá, Lima y Guayaquil dan exactamente la línea base de T2;
  - **los vecinos siguen iguales**: el escenario del incidente 15 (UTC contra hora local) y el de be-08
    (servidor contra PDF) dan lo mismo antes y después del fix;
  - **la preparación carga**: `mock/db.incidente-21.json` es JSON válido y tipa contra los modelos de
    F03 (`resolveJsonModule`); si su "hoy" caduca, la prueba fija el reloj y la caducidad queda escrita.
- `Ruta forense` → `forense-fase-10.md`, y el pie recíproco de esa pieza.
- Tags `incidente-21-roto` / `incidente-21-fix` escritos para el autor.
- **Cierra cuando:** las cinco pruebas corren en contenedor (el fix se vio fallar antes y pasar
  después) y el enlace forense es recíproco.

### T4 — Incidente 22: el RUC

- **Paso 1** (con el autor): quién lo reporta. Propuesta: Jeimy Paola, al cargar a la hostería como
  cliente nuevo desde la pantalla.
- Igual que T3, con fase 06, ruta forense `forense-fase-06.md` y `mock/db.incidente-22.json` si hace
  falta (puede bastar la semilla: la pantalla falla al crear).
- El validador, extraído de F06 (~791) y corrido en contenedor con `@angular/forms@16` instalado (sin
  CLI): NIT de 9 y 10 dígitos, RUC de 11 (Perú) y de 13 terminado en `001` (Ecuador), y los casos que
  deben seguir fallando (longitudes intermedias, letras, RUC de Ecuador sin `001`). El roto rechaza el
  RUC de la hostería; el fix lo acepta.
- El chequeo asíncrono de duplicados sigue disparando con el validador nuevo: prueba con el servicio
  de F06 reemplazado por un doble que devuelve `of(...)`, sobre el RxJS de Angular 16.
- **Cierra cuando:** lo mismo que T3, con estas pruebas.

### T5 — El track BE

- `be00`: el origen de `certcore-api` (Wilson, licencias, hosting), la tabla del contrato (~69) y el
  acta de Wilson (D20).
- `be02`: tabla de autores (nombres, "el segundo", años de Tatiana), el comentario de código "Venía de
  la intranet" (~187) → "Venía de .NET", y la permanencia de 18 meses (se queda).
- `be07`: la defensa de Lumen (~193) y su tabla (~199) con la razón de licencias y hosting; el acta de
  Wilson (D20); "tres rotaciones" se queda.
- `bea-07`: "en Colombia no aplica" → los tres países, con Galápagos como la excepción.
- `cuaderno-incidentes-be.md`: `be-12` con Sabana Labs, Hernando y el acta; la mención de Colombia.
- Revisar `be03`, `be05`, `be06` donde dicen `America/Bogota` por si alguna frase dice "la única".
- **Pruebas** (regla 4): todo bloque PHP que la tanda toque —como mínimo el comentario de `be02`
  (~187)— se extrae y pasa `php -l` en `php:7.4-cli`, la imagen de las sondas del 09/09 (`bea-02`). Si
  una tanda cambia algo más que comentarios (un literal, un mensaje de error), el bloque se corre, no
  solo se valida su sintaxis.
- **Cierra cuando:** `grep` de "intranet", "Andina", "jefe de tecnología" y "La segunda" (como autora)
  en el track BE da cero, be00/be02/be07/be-12 cuentan la misma historia que §3 de la historia, y los
  bloques PHP tocados pasan en contenedor.

### T6 — `prompts/` a los lineamientos

- `propuesta-fases-backend.md` (§0.4, ~231, ~259, ~624, "Andina de Certificaciones"),
  `prompts-backend-fase.md` (~54), `prompts-backend-apendice.md`: el origen nuevo de la API y los tres
  países.
- `alcance-del-proyecto.md`, `propuesta-fases-y-alcance.md`, `prompts-extendidos-fases.md`,
  `plantillas-de-capitulo.md`: la empresa, 22 incidentes, 123 h.
- `guia-de-estilo-y-convenciones.md`:
  - §11 y §15.5 con los nombres y las invariantes nuevas (Plomada, tres países, `-05:00` salvo
    Galápagos, NIT/RUC, plantillas por sufijo de país);
  - **§16 nueva, de excepciones**, al final para no renumerar, con `docker-container-legacy` §16 como
    modelo: la tabla regla general → lo que hace el curso → por qué; D-12 (sin Mermaid por ahora);
    qué documento hace el papel de cada plantilla de `zz-instrucciones` (`diccionario-de-terminos` →
    §5.2 y §15.4; `contrato-de-nombres` → §5.3 y §15.2; `plantillas-de-capitulo` → el archivo del mismo
    nombre; `prompts-de-fase` → `prompts-extendidos-fases.md` y `prompts-backend-fase.md`;
    `prompts-de-apendice` → `prompts-extendidos-apendices.md` y `prompts-backend-apendice.md`;
    `plan-de-produccion` → no hay, por D7); el `FUERA` hacia angular-8; y cómo se verifica.
- `formato-cuaderno-incidentes.md` y `preparaciones-de-incidentes.md`: índice y conteo con 21 y 22.
- Copiar `zz-instrucciones/herramientas/verificador_base.py` y escribir `verificar-corpus.py` como
  subclase de `PerfilCoursesIA`, con `docker-container-legacy/prompts/verificar-corpus.py` como modelo
  (callouts de la guía §7.2; autocontención salvo el puente a angular-8; sin exigir vigencia en el
  encabezado si la guía no la pide).
- `prompts/README.md` sobre `zz-instrucciones/plantillas/readme-de-prompts.md`.
- `_deprecado-tutorial-angular16.md` se queda: ya se declara deprecado y no se cita.
- **Cierra cuando:** `python3 prompts/verificar-corpus.py` corre y sus errores son solo los que la
  §16 declara.

### T7 — README, verificación y cierre

- `README.md`: la empresa y el párrafo de la historia, 22 incidentes, 15 h de cuaderno, 123 h.
- `python3 prompts/verificar-corpus.py` en cero errores; `python3 prompts/verificar-forenses.py` en
  cero fallos.
- **Corrida final:** todas las pruebas de T2–T5 se repiten de cero, con contenedores nuevos y siguiendo
  solo los README de sus directorios de `zz-code/`, contra el markdown como quedó al final (un bloque
  que T6 o T7 retocaron después de su tanda se vuelve a extraer). Las salidas coinciden con las
  guardadas; si no, la tanda que las produjo se reabre. Los directorios quedan registrados en §9 con
  su estado.
- `grep` final en todo el curso, salvo este plan, en cero: "Andina de Certificaciones", "Andinean",
  "intranet" (como origen de la API), "Quispe", "Lucía Cárdenas", "Luz Marina", "Martha Lucía",
  "Johana", "Natalia", "Ospina", "Cordillera", "jefe de tecnología".
- Los hechos de §6 cerrados, o retirados de la historia.
- Memoria del proyecto al día y, con permiso del autor, `rm` de este plan.

---

## 6. 🔬 Hechos por verificar

Verificados y ya en la historia: Acuerdo 470 de 2011 (Bogotá, revisión anual, ONAC, NTC 5926-1 y
5926-2); IDIGER; Norma EM.070 (certificado de inspección anual, ITSE municipal); acreditación por
INACAL (NTP-ISO/IEC 17020); RTE INEN 095; SAE (OAE hasta el Decreto Ejecutivo 338 de 2014, NTE INEN
ISO/IEC 17020, códigos `OAE OI`/`SAE OI`); .NET Core 1.0 (27/06/2016); LOREG 2015 (nueva
infraestructura turística solo para residentes permanentes; categorías de 3 a 5 estrellas); IFPMA (sin
ocio pagado a profesionales de la salud: la historia ya no lo menciona, pero sostiene que los eventos
sean de empleados).

Pendientes (se cierran en la tanda indicada, o a más tardar en T7):

- **T3:** `America/Galapagos` = UTC−6 sin cambio de hora; `America/Lima` y `America/Guayaquil` =
  UTC−5, en la base tz del Node que se use.
- **T4:** longitud y forma del RUC de Perú (11 dígitos) y de Ecuador (13; personas jurídicas
  terminadas en `001`), con fuente oficial (SUNAT, SRI).
- **T7:** la cifra de **1.953 visitas** del distrito en Bogotá en 2024 (historia §9, hoy dice "por
  verificar"): leer la noticia de la Alcaldía o quitar la fila.
- **T7:** el nombre con que Colombia adopta la ISO/IEC 17020 (historia §8 dice "ISO/IEC 17020").
- **T7:** Galápagos (historia §2): que el permiso anual lo da el cuerpo de bomberos con visita
  propia; que no hay norma que exija inspección de tercero para calderas o redes contra incendio en un
  hotel (si existe, la historia se ajusta: sería un motivo más); la escasez de agua potable en Puerto
  Ayora. La altura de las edificaciones no se afirma.
- **T7:** la periodicidad de inspección de ascensores en Ecuador (la historia §10 ya no la afirma).
- **T7:** que *Plomada Ingeniería de Inspección*, *Teusacá Software*, *Sabana Labs*, *Aurum
  Suites*, *Aurum Inn Galápagos* y *Hostería Chiriboga* no correspondan a empresas reales (las
  búsquedas del 06–07/10 no encontraron ninguna).

---

## 7. 📓 Bitácora

- **2026-10-06** — Historia v2: opción B; nombre Plomada (el autor propuso "Cóndor Ingeniería de
  Inspección", descartado por choque); SAE verificado en la Resolución SAE-ACR-0321-2021; contratación
  con Wilson independiente y la licitación Teusacá/Sabana Labs. El autor aprueba tocar código, el
  incidente de Galápagos y un plan de edición desechable.
- **2026-10-07** — La reestructuración de 2022 (gerencia de sistemas, Wilson de vuelta por horas,
  Wilmer en soporte, Hernando en 2023); Aurum Suites como cadena de ejecutivos; el Inn de Galápagos
  sobre la LOREG y justificado por el estándar de marca, sin ascensor. El autor cierra D8–D20. T1:
  fechas de 18 meses, escena en la torre de Bogotá, plantillas por sufijo, Jeimy Paola y Jimena; la v2
  sobrescribe `00-historia-del-sistema.md`.
- **2026-10-07** — Ajuste del autor a la historia (quitó la frase sobre los códigos de ética de la
  industria farmacéutica). Revisión final de coherencia: §12 decía que la última persona de la API
  "renunció la semana en que abrieron tu vacante" (contradecía §4: terminó en diciembre), corregido;
  §10 decía "la hora local del país" y Galápagos está en Ecuador con otra zona, corregido a "del lugar"
  con la nota de que el código solo conoce el continente (es el 21); §10 afirmaba revisión anual de
  ascensores "en los tres países" sin fuente para Ecuador, corregido. Plan reescrito con todas las
  decisiones cerradas y la §0 para retomar en otra sesión.
- **2026-10-07** — El cliente regional pasa de *Andinean Suites* a **Aurum Suites** (y *Aurum Inn
  Galápagos*), por la cercanía con *Andina Laboratories* de LabCore; aplicado en la historia y en este
  plan. "Andinean" entra al `grep` final de T7. El autor pide que las pruebas de código entren en las
  tandas: la regla 4 cubre todo bloque tocado (también comentarios), T2 deja una línea base de tiempo,
  T3 y T4 detallan sus pruebas, T5 pasa `php -l`, T7 repite todo de cero, y nace la §9.

---

## 8. ✅ Checklist final

- [x] D1–D20 cerradas por el autor.
- [x] `00-historia-del-sistema.md` es la v2, sin recuadro de borrador; no queda `-v2` en el curso.
- [ ] Toda frase que diga que CertCore opera solo en Colombia dice ahora tres países, y la excepción
  de Galápagos está donde se habla de zona horaria (T2, T5).
- [ ] Incidentes 21 y 22 con enunciado, preparación, ruta forense recíproca, tags escritos y código
  corrido en contenedor, con su directorio de `zz-code/` registrado (T3, T4).
- [ ] Bloques de código tocados en T2 y T5 extraídos y compilados (`tsc`) o validados (`php -l`) en
  contenedor; línea base de tiempo de T2 guardada (T2, T5).
- [ ] Corrida final de T7 hecha de cero desde los README de `zz-code/`, con las mismas salidas; §9 al
  día (T7).
- [ ] be00, be02, be07, bea-07 y be-12 coherentes con la historia (T5).
- [ ] Guía §16 escrita; `verificar-corpus.py` en cero errores; `verificar-forenses.py` en cero fallos
  (T6, T7).
- [ ] `prompts/README.md` escrito (T6).
- [ ] README con conteos y horas nuevas (T7).
- [ ] `grep` de nombres vetados y restos en cero (T7).
- [ ] Hechos de §6 cerrados o retirados (T7).
- [ ] Contenedores y volúmenes de la edición borrados; nada fuera de lo creado.

---

## 9. 🧪 Directorios de `zz-code/`

Cada tanda que corra código crea su directorio con `python3 zz-code/nuevo.py
angular-16-legacy-for-backend-devs` (o reutiliza el de la tanda anterior, si sigue *vigente*) y lo
anota aquí con su estado: *vigente*, *extraído* o *archivado* (`zz-code/README.md`, regla 3).

| Directorio | Tanda | Qué tiene | Estado |
|---|---|---|---|
| `angular-16-legacy-for-backend-devs-20261006-ab79` | rescate | Pruebas rescatadas de las sesiones de septiembre (sondas de PHP 7.4 + PostgreSQL, verificaciones del track BE) | archivado |
| *(por crear)* | T2 | Extractor de bloques, `tsc` de `business-day.ts` y la línea base de tiempo | — |
| *(por crear o el de T2)* | T3 | Incidente 21: zonas horarias, roto/fix y regresiones | — |
| *(por crear o el de T2)* | T4 | Incidente 22: validador NIT/RUC y chequeo asíncrono | — |
| *(por crear o el de T2)* | T5 | `php -l` de los bloques PHP tocados | — |
