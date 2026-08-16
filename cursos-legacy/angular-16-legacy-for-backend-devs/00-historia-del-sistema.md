# 🏢 Historia del sistema

> Tutorial Angular 16 — Inspecciones y certificaciones · Ficha de contexto ·
> **Se lee antes de la Fase 0**
> ~20 minutos · No hay código acá: hay motivos.

Este documento cuenta de dónde viene CertCore, el sistema que vas a mantener. No
es decoración narrativa: es la información que en un trabajo real **nadie te da**
y que te pasarías tres semanas reconstruyendo a partir de `git log` y de gente
que ya cambió de proyecto.

> 📝 **Todo lo que sigue es ficción, y a propósito.** Andina de Certificaciones
> S.A.S. no existe y CertCore tampoco. Los inventamos enteros para este curso, y
> esa es exactamente la razón de que podamos contarte la historia completa —con
> fechas, decisiones y errores incluidos— sin omitir nada. Un caso de estudio
> real siempre viene recortado por un NDA; este viene entero. Y lo que es más
> importante: **el curso construye CertCore pieza por pieza**, así que cuando el
> material diga "esto está así", vas a poder abrir el archivo y verlo.

---

## 1. 🧭 Por qué esto va antes que el código

Hay una pregunta que separa al mantenedor que sirve del que no, y aparece la
primera vez que abres un archivo raro: **¿esto está así a propósito o por
error?**

Sin contexto, no tiene respuesta. En un sistema *viejo* al menos la pista es
obvia: si el código parece de 2015, es de 2015. Pero CertCore no es viejo, es
**migrado**, y ese es otro problema. Vas a abrir dos archivos vecinos, escritos
por el mismo equipo, que resuelven lo mismo de dos maneras distintas y correctas.
Uno inyecta con `constructor`, el otro con `inject()`. Uno declara un componente
en un `NgModule`, el otro es standalone. Ninguno de los dos está mal.

Sin la historia, esa convivencia se lee como desorden y da ganas de "uniformar".
Con la historia se lee como lo que es: **una línea de tiempo**. El archivo de
`constructor` es de 2021 y el de `inject()` es de 2024, y lo que se hace con el
código fechado no es reescribirlo, es tocarlo con cuidado y saber por dónde.

Por eso esta ficha va antes que la Fase 0. Léela una vez ahora y vuelve a ella
cuando una decisión del código te parezca inexplicable. Casi siempre está acá.

---

## 2. 🏭 La empresa, en un párrafo

Andina de Certificaciones S.A.S. inspecciona y certifica activos ajenos:
ascensores, calderas, tanques, sistemas contra incendio. Un cliente tiene
activos; cada activo se inspecciona periódicamente contra una **plantilla de
checklist** que sale de una norma; el inspector va a campo, responde el
checklist, deja evidencia y registra hallazgos; si no hay ningún hallazgo
`critical`, se emite un certificado con vigencia; cuando la vigencia se acerca a
su fin, alguien tiene que llamar al cliente antes de que se venza.

El negocio es mediano y regulado: unas decenas de inspectores en campo, dos
personas en el área de calidad que administran las plantillas, y una auditoría
externa que cada tanto pide el histórico y espera que cuadre. Esa segunda parte
—la auditoría— explica más decisiones del sistema que cualquier consideración
técnica. Un dato mal guardado acá no es un bug de interfaz: es un hallazgo de
auditoría.

---

## 3. 🕰️ Las eras del código

CertCore no lo escribió una persona con un plan. Lo escribieron tres equipos en
cuatro años, cada uno resolviendo el problema que tenía delante con las
herramientas de su momento. Las capas se ven a simple vista cuando sabes qué
buscar.

Antes de esos tres equipos hay una cuarta capa que no es Angular y que casi nunca
se cuenta: **la API contra la que la aplicación habla, que es cinco años más vieja
que ella**. Empezamos por ahí, porque explica la mitad de las rarezas del
contrato.

### 🗄️ Era 0 (2016-2018) — `certcore-api`, la que ya estaba

Andina de Certificaciones **certificaba mucho antes de tener una aplicación
Angular**. Hasta 2016 la emisión se hacía con plantillas de Word y una hoja de
cálculo compartida, y el histórico vivía en una carpeta de red que nadie se
atrevía a tocar.

En 2016 se digitalizó la emisión de certificados. La empresa ya tenía dos
personas de PHP que mantenían el intranet viejo, y en ese momento **Lumen era
"Laravel pero rápido, para servicios"**: PHP 7 acababa de doblar el rendimiento,
los microservicios estaban en su pico, y aprovechar al equipo que ya tenías era
la decisión sensata. Se eligió Lumen **para un servicio** —emitir el certificado y
guardarlo— y para ese servicio fue un acierto que se cobró durante años.

Lo que pasó después es el pecado de este sistema, y no se parece a una estupidez:
**todo lo demás se fue colgando de ahí y nadie volvió a decidir nunca**. Los
clientes, los activos, las plantillas, las inspecciones y los hallazgos entraron
al mismo servicio uno tras otro, cada uno con una prisa distinta, sin que nadie se
sentara a preguntar si aquella elección de 2016 seguía siendo la buena.

La base de datos salió del mismo momento: **PostgreSQL, contratado como servicio
gestionado**. Y ahí aparece la asimetría que ordena media historia del sistema:

> 🧠 **A la infraestructura la actualizan; a la aplicación no.** La base tenía
> dueño —un proveedor con calendario propio, y una auditoría de cumplimiento que
> exige correr sobre versiones soportadas—. El código no tenía ninguno. El
> proveedor subió la versión cuatro veces en ocho años, cada una en su ventana de
> mantenimiento y cada una anunciada por un correo que alguien archivó. La
> aplicación no se movió nunca.

Con una ironía que el dominio pone gratis: fue una **auditoría de cumplimiento**
la que forzó las subidas. *La certificadora no pasaba su propia auditoría.*

Y hay un detalle de plantilla que importa tanto como el técnico. El mercado de
devs **PHP** es enorme; el de devs **Lumen** no existe. Todos los que pasaron por
`certcore-api` llegaron reciclados de otro sitio —de Laravel, de Symfony, de
CakePHP—, se formaron a costa de la empresa, y se fueron en año y medio, porque
nadie quiere "Lumen 2018" en su CV. **El código tiene estratos por procedencia, no
solo por fecha.**

> 🧠 **CertCore, la aplicación, nació en 2021. `certcore-api`, contra la que
> habla, es de 2016 y nadie la revisó nunca.**

Eso explica de una sola vez tres cosas que vas a encontrar en el curso y que, sin
esta historia, parecen caprichos: que el contrato devuelva **el objeto completo, sin paginar**
(en 2016 había doce inspecciones); que el `status` del certificado venga
**guardado como dato** en vez de calculado; y que las plantillas versionadas se
identifiquen con un `id` compuesto que nadie diseñó, sino que fue quedando.

En este curso **no tocas la API**: en la Fase 3 construyes un mock que la imita, y
con eso alcanza para todo lo demás. Pero cuando una fase diga *"esto se arregla
del otro lado"*, ya sabes de qué otro lado habla — y de qué año.

### 🪨 Era 1 (2021) — "que salga el piloto con dos clientes"

La primera versión la escribió un equipo de tres personas en unos meses, para un
piloto con dos clientes reales — y salió tan rápido en buena parte porque **había
una API esperándola**: nadie tuvo que diseñar el modelo, solo consumirlo. Angular 12 era lo estable de entonces y todo se
hizo como Angular documentaba en 2021: **`AppModule`, `CoreModule`,
`SharedModule`, un módulo por feature con `RouterModule.forChild`, componentes
declarados en `declarations`, e inyección por `constructor`**. Guards e
interceptors de clase, con `@Injectable()` y `HTTP_INTERCEPTORS`.

Una cosa la hicieron bien casi sin querer: el CLI 12 ya generaba proyectos con
`strict: true` y **nadie lo apagó**. Suena menor y no lo es. Media docena de bugs
que en otros sistemas viven años escondidos —el `null` que se coló como
`undefined`, el campo opcional que en realidad significaba otra cosa— acá el
compilador los pone sobre la mesa.

Lo que quedó de esa era y sigue vivo: la estructura de módulos, la autenticación
con el token en `localStorage`, y el `SharedModule` que reexporta media librería
de Angular Material "por comodidad" porque así nadie tenía que pensar qué
importar. Esa comodidad tiene precio y lo vas a pagar tú, en la Fase 5, con el
bundle medido antes y después.

Lo que se hizo mal: cero pruebas. Ni una. El piloto tenía fecha y las pruebas
siempre son lo primero que se recorta.

> 🧠 **Lo que te llevas de esta era.** Cuando veas un `NgModule` con
> `declarations` y un `constructor(private readonly http: HttpClient)`, no estás
> viendo a alguien anticuado: estás viendo 2021. El apéndice **A04** es el
> traductor entre las dos formas de inyectar, y **A07** explica por qué el estado
> quedó donde quedó.

### 🧱 Era 2 (2022-2023) — "cambió la norma, y va a volver a cambiar"

El piloto funcionó, entraron clientes, y con ellos llegó el problema que define
al sistema: **la norma cambió**. Los ítems del checklist de ascensores dejaron de
ser los mismos, y alguien preguntó lo correcto en el momento correcto: *¿qué pasa
con las inspecciones que ya hicimos?*

La respuesta a esa pregunta es el corazón de CertCore. Se decidió que **las
plantillas se versionan**: cuando cambia la norma nace una v2 con su `validFrom`,
la v1 queda intacta, y cada inspección guarda el `templateVersion` con el que se
ejecutó. De ahí sale el invariante que el curso repite hasta el cansancio:

> 🧭 **Una inspección se lee siempre con la versión de plantilla con la que se
> ejecutó. Siempre. Aunque haya una versión más nueva y aunque la nueva sea "la
> correcta".**

El motor que resuelve esa regla lo escribió una sola persona, en un par de
semanas intensas, y esa persona ya no está en la empresa. Funciona. Está poco
documentado. Y es la fuente de aproximadamente la mitad de los tickets que vas a
ver, porque la regla se enuncia en una línea y se rompe de seis maneras
distintas. Por eso la Fase 7 es la más pesada del curso ⭐.

Esta era también fijó dónde vive el estado. Con cuatro pantallas necesitando
saber qué plantilla está vigente, el equipo evaluó NgRx y dijo que no: dos
personas, un dominio chico, y una librería que exige ceremonia. Se quedaron con
**servicios inyectables con un `BehaviorSubject` privado y un `Observable`
público**, que es la decisión más común del ecosistema Angular y también la que
más fugas de suscripción produce. No fue una mala decisión. Fue una decisión con
un costo que se paga en suscripciones que nadie cierra, y ese costo lo vas a
cazar tú (Fase 4 y su pieza forense).

### 🔀 Era 3 (2024) — "hay que migrar antes de que se nos caiga"

Angular 12 salió de soporte, un cliente grande pidió el reporte de
vulnerabilidades de las dependencias, y la migración dejó de ser opcional. Se
hizo el camino largo, salto por salto —13, 14, 15, 16— con `ng update`, en cuatro
tandas, a lo largo de 2024. Terminó en **Angular 16.2.12**, que es donde está el
sistema hoy.

Tres cosas de esa migración te van a aparecer en la cara:

- **Material 15 trajo MDC.** Los componentes se llaman igual y por dentro son
  otros. Se rompieron estilos que nadie había tocado, y algunos se arreglaron con
  parches de CSS que siguen ahí. Cualquier artículo de Material anterior a 2023
  describe un componente distinto con el mismo nombre (**A01**).
- **Angular 14 trajo formularios tipados**, y la migración automática los dejó a
  medias: mucho `FormControl<string | null>` donde el `null` no significa nada y
  nadie puso `nonNullable`. Con `strict` activo, eso se nota (**A05**).
- **Angular 16 trajo standalone estable**, y con él la decisión que define este
  track: **no se migró nada, pero todo lo nuevo se escribe standalone.**

Esa última decisión merece un párrafo, porque es la que más te va a confundir y
la que más razón tenía. Migrar cuarenta componentes que funcionan, sin una sola
prueba que te avise si rompiste algo, para ganar consistencia estética, es gastar
riesgo sin comprar nada. Así que la regla del proyecto quedó escrita en el
README y es la que rige todo el curso:

> 🧭 **Código nuevo, estilo nuevo. Código heredado, se toca lo mínimo y en su
> propio estilo.** Y el corolario, que es lo que de verdad te llevas: mezclar los
> dos estilos dentro de un mismo archivo es peor que cualquiera de los dos
> estilos puros.

Los sitios donde las dos generaciones se tocan —un standalone importado desde un
`NgModule`, un interceptor funcional corriendo junto a uno de clase— van marcados
en todo el material con 🧬. Es el marcador que más vas a buscar con `Ctrl+F`.

### 🧊 Hoy — mantenimiento

Desde que terminó la migración casi no entran features. Entran **cambios
normativos, requerimientos legales y hotfixes**. La aplicación se despliega como
un contenedor con nginx delante, y arrastra una fricción que no es culpa de
Angular sino de cómo se construyen las SPAs: **la configuración se hornea en
tiempo de compilación y el contenedor querría inyectarla en tiempo de arranque**.
Ahí nace la mitad de los "funciona en UAT y no en PROD" del sistema, y ahí
termina el curso (Fase 13).

Nadie va a subir a Angular 17 este año. La razón es la única razón honesta que
existe: **funciona, está auditado, y no hay presupuesto para arriesgarse a que
deje de funcionar.**

---

## 4. 🔎 Quién dejó qué (y qué sabemos de por qué)

En un sistema real esto se reconstruye leyendo `git blame` y preguntando en
Slack. Acá te lo damos hecho:

- **El `SharedModule` reexporta media librería de Material.** Fue comodidad de
  2021 y funcionó durante tres años. Hoy significa que un módulo que usa un botón
  arrastra veinte componentes al bundle. Se paga en la Fase 5 💸, y es el primer
  sitio donde vas a ver una deuda cobrarse con números.

- **El estado vive en servicios con `BehaviorSubject`, sin librería.** Decisión
  deliberada de 2022, con NgRx evaluado y descartado por tamaño de equipo. No es
  ignorancia: es una decisión de escala. Lo que costó está en la Fase 4 y en
  **A07**, que además explica qué resolvería NgRx y por qué aquí no está.

- **El token vive en `localStorage` y no hay refresh token.** Decisión de 2021,
  cuando "auth" significaba un endpoint que devuelve un JWT. Está mal por
  seguridad, está documentado como tal en la Fase 2, y no se arregla en este
  curso porque arreglarlo de verdad es trabajo de backend.

- **El motor de plantillas versionadas lo escribió alguien que ya no está.** Es
  la pieza más importante y la peor documentada, en ese orden y por esa razón:
  quien la escribió tenía el modelo completo en la cabeza y no le hizo falta
  escribirlo. Cuando termines la Fase 7 vas a tener ese modelo tú.

- **Los formularios de inspección se construyen en runtime desde datos.** No hay
  un formulario de ascensores y otro de calderas: hay un `FormGroup` armado a
  partir de los ítems de la plantilla. Es la decisión correcta —si no, cada
  cambio normativo sería un release— y también la más difícil de depurar del
  sistema entero. Fase 8 ⭐.

- **Las fechas llevan zona horaria explícita en todas partes.** Esto fue una
  cicatriz: hubo un certificado que "venció ayer" para el servidor y "vence hoy"
  para el usuario, en pleno cierre de mes. Desde entonces, `-05:00` explícito
  hasta en el `db.json`, y nada de `new Date()` suelto donde importe el día.

- **La interfaz es monolingüe en español, con los textos literales en la
  plantilla.** No hay i18n ni claves de traducción, y no fue un olvido: la
  operación es local y la auditoría también. El código, en cambio, está en
  inglés, porque el equipo del piloto era mixto y la convención quedó. Es una
  mezcla rara y es la que vas a ver todo el curso.

- **El "modo caos" del mock no existe en producción.** Este es el único
  componente que no es herencia: lo construyes tú en la Fase 3. En producción el
  caos viene gratis y sin avisar, un martes a las cuatro. Acá lo hacemos
  reproducible porque el objetivo es entrenar el ojo, no sufrir al azar.

---

## 5. 🕳️ Lo que el sistema NO tiene

Tan importante como lo que hay. Si buscas alguna de estas cosas, no las vas a
encontrar, y no es que no las hayas visto todavía.

No hay librería de store. No hay pruebas hasta que las escribas tú (Fase 12). No
hay i18n. No hay signals: en Angular 16 son experimentales y CertCore no los usa.
No hay control flow `@if/@for`, que llegó con la 17. No hay backend en este
repositorio: `certcore-api` existe, es de 2016 y está descrita arriba, pero lo que
tú levantas es un mock que la imita (Fase 3). No hay refresh token, no hay firma digital
real en el PDF, no hay offline-first con service workers, no hay pruebas
end-to-end, y no hay observabilidad más allá de la consola del navegador.

Y hay algo que CertCore sí tiene y el curso no construye: **los cuarenta y pico
de componentes de las eras 1 y 2 que nadie migró**. Acá vas a escribir unos
pocos, y el reflejo que te llevas es exactamente ese — no tocar los otros sin un
motivo escrito.

Esa lista es, palabra por palabra, el backlog técnico eterno de miles de sistemas
reales. Que te resulte familiar es el punto.

---

## 6. 🎭 Tu rol en esta ficción

Entras al equipo de mantenimiento. Eres senior en backend y esta es tu primera
vez sosteniendo un frontend ajeno. Nadie te va a hacer onboarding porque no hay
quien: del equipo del piloto no queda nadie, quien escribió el motor de
plantillas se fue en 2023, y la persona que lideró la migración está asignada a
otro producto y responde cuando puede.

Tienes el código, esta ficha, y los tickets que van a ir llegando en el
`cuaderno-incidentes.md`.

El curso te hace construir el sistema fase por fase antes de pedirte que lo
mantengas, y eso es una licencia pedagógica deliberada: escribir cada capa con
sus decisiones explicadas en voz alta es la forma más rápida de que después
reconozcas esas decisiones cuando te las encuentres tomadas por otro. Fíjate en
el orden, que también es intencional: la **Fase 0 te enseña el estilo nuevo** y
la **Fase 1 te entrega la herencia**. Conoces el destino antes que el pasado,
para que puedas leer los `NgModule` preguntándote *"¿por qué está así?"* en vez
de creer que es la única forma que existe.

Al llegar a la Fase 7 ya no vas a sentir que escribiste ese código: vas a sentir
que lo heredaste. Esa es la sensación que buscamos.

> **La señal de que esta ficha hizo su trabajo:** cuando abras un archivo raro y
> tu primera reacción no sea "qué inconsistente está esto", sino "¿de qué año es
> esto, y en cuál de los dos estilos va mi fix?".
