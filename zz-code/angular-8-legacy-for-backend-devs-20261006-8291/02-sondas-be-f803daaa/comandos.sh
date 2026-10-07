# Comandos Bash de la sesión f803daaa-f024-4042-af34-b44d49809430, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-09T03:17:52 · Read React BE track opening files
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && head -60 be00-el-contrato-auditoria-del-mock.md && echo "=====BE01=====" && head -50 be01-go-y-la-forma-del-monolito.md

# --- 2026-09-09T03:17:53 · List prompts and read README
ls prompts/ && echo "=====" && head -80 README.md

# --- 2026-09-09T03:17:56 · Read backend phases proposal
head -120 prompts/propuesta-fases-backend.md

# --- 2026-09-09T03:17:57 · Read both Angular READMEs
cd /Users/oskar/Developer/Learning/courses-ia-generated && head -70 angular-8-legacy-for-backend-devs/README.md && echo "==========A16==========" && head -70 angular-16-legacy-for-backend-devs/README.md

# --- 2026-09-09T03:18:02 · Peek at nuevas-ideas.md
wc -l nuevas-ideas.md && head -60 nuevas-ideas.md

# --- 2026-09-09T03:18:03 · Read system histories
sed -n '1,40p' angular-8-legacy-for-backend-devs/00-historia-del-sistema.md && echo "=====A16=====" && sed -n '1,40p' angular-16-legacy-for-backend-devs/00-historia-del-sistema.md

# --- 2026-09-09T03:26:48 · Append alternatives section to ideas doc
cat >> ideas_backend_cursos_angular.md <<'EOF'

---

## 8. 🎰 Alternativas a Dart: las cinco formas de que un boom pase factura

Segunda ronda de la conversación. La pregunta era *"¿qué otra tecnología pesa
como decisión por moda, tipo Lumen?"*, y el hallazgo es que **"boom que salió
caro" no es un fallo, son cinco**, y cada candidato enseña uno distinto. Elegir
candidato es elegir lección, no elegir logo.

| Fallo | Candidato | La frase que lo resume |
|---|---|---|
| **Escasez de gente** | Dart + Conduit | "Nadie sabe esto y nadie quiere aprenderlo" |
| **Familiaridad falsa** | Lumen | "Todos creen que saben esto, y se equivocan" |
| **Riesgo legal** | Scala + Akka | "Una licencia cambió y tu arquitectura quedó ilegal" |
| **Abandono del vendor** | LoopBack 3 | "La v4 existe, pero migrar es reescribir" |
| **Muerte de la empresa** | RethinkDB | "Era excelente y aun así murió" |

### 8.1 🐘 Lumen — la familiaridad falsa

**El boom:** 2015–2018. PHP 7 acababa de doblar el rendimiento, los
microservicios estaban en su pico, y Lumen era *"Laravel pero rápido, para
servicios"*. Para una empresa mediana latinoamericana que ya tenía gente de PHP
del intranet viejo, era **la decisión sensata**: aprovechas el equipo que
tienes, la sintaxis que ya conocen, y encima es moderno.

**La factura, que es de otra clase.** Lumen ⚠️ dejó de recomendarse para
proyectos nuevos —la propia documentación de Laravel manda usar Laravel con
Octane— y el camino de vuelta a Laravel completo **no es un upgrade, es un
trasplante de bootstrap**. Pero eso es lo de menos. Lo interesante:

> 🧠 **El problema de Lumen no es que nadie lo conozca. Es que todos creen que lo
> conocen.** Llega un dev de Laravel, se siente en casa, pega una respuesta de
> StackOverflow que funciona en Laravel — y en Lumen **falla en silencio**,
> porque el contenedor, los facades, el middleware y la capa de eventos no son
> los mismos. No revienta: se comporta distinto.

Y ahí está por qué esto puede valer más que Dart para **estos** cursos. El
problema de Dart es de RRHH: una vacante abierta. El problema de Lumen es de
RRHH **y forense**: genera bugs, y bugs del tipo exacto que los cursos de
Angular ya enseñan a cazar — el ticket vago, el síntoma que no cuadra, la causa
que estaba en una suposición heredada. Un curso cuya identidad es *"reproduce el
bug desde un ticket vago"* saca más de una tecnología que **produce** bugs que de
una que produce una vacante.

**El giro de plantilla, que es el inverso del de Dart.** Devs de PHP hay de
sobra y son baratos. El coste no es contratar: es **retener**. Nadie quiere
"Lumen 2018" en su CV, así que el que entra se va en año y medio, y la rotación
te cobra el onboarding cada dieciocho meses. Es otra columna de la misma
factura y no se parece en nada a la de Dart.

**Coste logístico:** el más bajo de los cinco. `php -S`, Composer, y listo.

### 8.2 ⚡ Scala + Play + Akka — el riesgo legal

**El boom:** 2015–2019, manifiesto reactivo, halo de Spark, "concurrencia sin
locks". Para un sistema que recibe ráfagas de sincronización cuando las tablets
del inspector vuelven a tener señal, el argumento **es bueno de verdad**.

**La factura, y es la más espectacular de las cinco:** en septiembre de 2022 ⚠️
Akka cambió de Apache 2.0 a BSL. De un día para otro, seguir actualizando
costaba dinero o había que irse a Pekko, el fork Apache. Súmale Play ⚠️ salido
de manos de Lightbend, la migración 2.12 → 2.13 → 3, sbt, los tiempos de
compilación y el sobreprecio del 30% por dev.

> 🧭 **La lección que no da ningún otro candidato: tu deuda técnica la creó un
> abogado.** No hay refactor que la arregle. Y si CertCore nace en 2021, la bomba
> le estalla en 2022 — dentro de la vida del sistema, con el equipo mirando.

**El pero:** es el más caro de montar para el alumno (JVM, sbt, compilaciones
lentas), y una empresa mediana con cuatro devs eligiendo Scala en 2021 solo se
sostiene si la historia dice que lo trajo una consultora. Se arregla, pero hay
que escribirlo.

### 8.3 🪢 LoopBack 3 — el abandono del vendor

IBM/StrongLoop, boom 2016–2018, "genera tu API REST desde el modelo". LoopBack
3 ⚠️ llegó a EOL y LoopBack 4 es una **reescritura conceptual completa**: mismo
nombre, otro producto. El clásico puro — *"sí hay camino de migración, y el
camino es reescribir"*. Barato de montar (Node), pero el boom fue tibio y la
historia da menos de sí.

### 8.4 🧊 RethinkDB — la muerte del vendor

La empresa cerró en 2016 ⚠️ y el código acabó donado. Es el caso **más honesto
de los cinco**: la tecnología era excelente, la decisión fue buena, y aun así
perdiste. *"Elegiste bien y perdiste igual"* es una lección de seniority que casi
nadie enseña. Pero pertenece al eje de **datos**, así que compite con Mongo por
el mismo hueco. Encaja mejor como apéndice del track de LabCore que como columna
vertebral del de CertCore.

### 8.5 Descartados y por qué

- **Meteor** — arrastra el frontend, y aquí el frontend no se toca. Choca con la
  regla no negociable.
- **Deno** — el boom es de 2020–2021 (encajaría con la fecha de CertCore), pero
  Deno 2 está sano; no hay factura que cobrar y el curso quedaría inventando
  dolor.
- **Serverless Framework** — la historia es buenísima (cuarenta lambdas para un
  CRUD, más el cambio de licencia de la v4 ⚠️ en 2024), pero rompe la logística
  del curso: no hay un binario que el alumno levante en su portátil.
- **Elixir/Phoenix, Rails** — contratar cuesta, pero el ecosistema está vivo. El
  veredicto honesto sería *"quédate, está bien"*, y eso no da ocho fases.

### 8.6 La recomendación de esta ronda

**Lumen desplaza a Dart como candidato principal para CertCore**, por la razón
de §8.1: produce bugs, no solo vacantes, y eso lo conecta con el track forense
que los cursos de Angular ya tienen. Es además el más barato de montar y el más
creíble para una empresa mediana de la región.

**Dart no se cae, se mueve.** Sigue siendo el mejor caso de *escasez de gente*
pura y su justificación original —los modelos compartidos con la app Flutter de
campo— es la más elegante de todas. Candidato número uno si algún día hay un
tercer track, o si se quiere el pecado de RRHH sin mezcla.

**Y hay una idea estructural que salió de aquí y vale para cualquier candidato:**

> 🧠 **El backend es más viejo que el frontend.** CertCore es Angular de 2021,
> pero la API contra la que habla es de 2018. Eso es lo que pasa de verdad en las
> empresas, explica de una sola vez por qué la forma del contrato es rara, y
> además resuelve el problema de fechas de Lumen: su boom es de 2015–2018, no de
> 2021.

**Pendiente:** todo lo marcado ⚠️ en esta sección está sin verificar —el estado
oficial de Lumen, la fecha y el alcance del cambio de licencia de Akka, el EOL
de LoopBack 3 y el cierre de RethinkDB.
EOF
echo ok

# --- 2026-09-09T03:33:01 · Append Akka lab-cost section
cat >> ideas_backend_cursos_angular.md <<'EOF'

---

## 9. 🧱 Por qué Akka pierde: el coste del laboratorio

Tercera ronda. La pregunta era *"¿qué problemas tiene Akka para montar el
laboratorio?"* y la respuesta lo descarta como columna vertebral, aunque no como
contenido. Siete problemas, por gravedad real:

**1. La dificultad accidental se come a la intencional.** El que decide. El
método de los cursos es síntoma → medición → contención, y el alumno es senior
de backend que **no sabe Scala**. Los muros de Scala son de *compilación*
—implícitos, varianza, errores de tres pantallas—, así que el presupuesto
pedagógico se gasta en "por qué no compila" en vez de en "por qué esta
inspección usa la plantilla de hoy". Con Lumen, el alumno equivocado obtiene un
**bug**; con Scala obtiene un error del compilador. Lo primero es el curso; lo
segundo es otro curso.

**2. El ciclo de edición-verificación.** `php -S` es instantáneo, `go build` es
un segundo, el dev mode de Play recompila en la petición: 20–60 s por vuelta.
Por 25–35 ejercicios por fase y ocho fases, deja de ser molestia y pasa a ser
cambio de género.

**3. JDK pinneado contra ARM64.** Un stack de 2018 (Play 2.7/2.8, Scala 2.12)
quiere JDK 8 u 11, y para macOS aarch64 ⚠️ no hay Temurin de JDK 8 — toca Zulu o
Rosetta. Los cursos ya tienen `a12-arm64-m1.md` por esta misma familia de
problemas: se sabe lo que cuesta.

**4. Memoria.** sbt + JVM + Metals/Bloop se llevan 4–6 GB antes de hacer nada, y
en paralelo corren el dev server de Angular y el Docker de la base. En 16 GB va
justo; en 8 no va.

**5. El primer `sbt compile`.** Launcher, Scala y cientos de MB de árbol de
dependencias. La Fase 0 se convierte en "espera y reza", y detrás de un proxy
corporativo ni eso.

**6. Akka Cluster, si se usa el ángulo de microservicios.** El laboratorio deja
de ser "levanta un binario" y pasa a ser "levanta un clúster con split-brain
resolver y persistencia". Eso es otro curso entero.

**7. El irónico: la bomba de licencia es también una bomba de laboratorio.**
Para que el alumno *viva* el cambio hay que subir de Akka 2.6 (Apache) a 2.7+
(BSL). ⚠️ **Sospecha por verificar y bloqueante si se confirma:** que los
artefactos post-BSL se sirvan desde el repositorio propio de Akka con token, lo
que obligaría a cada alumno a registrar una cuenta comercial para hacer el
ejercicio central del track.

### 9.1 La salida: separar la lección del laboratorio

> 🧠 **La lección de la licencia no necesita el laboratorio de la licencia.**
> *"Tu deuda técnica la creó un abogado"* se enseña como caso de estudio con el
> assessment de cuatro opciones aplicado encima. Cuesta un apéndice, no una JVM.

Y tiene una casa mejor que CertCore: **el track de LabCore**. MongoDB pasó a
SSPL en octubre de 2018 ⚠️ y LabCore elige Mongo en 2019 — el equipo decidió
**justo después** del cambio, sin enterarse, y eso condiciona hoy qué proveedor
gestionado puede contratar. Si el laboratorio incorpora búsqueda, Elasticsearch
→ SSPL en enero de 2021 ⚠️ da el segundo caso **con su bifurcación real**
(OpenSearch), que sí se levanta en Docker y se puede medir. Redis → Valkey y
Terraform → OpenTofu completan el patrón sin coste de laboratorio.

### 9.2 Veredicto

**Scala + Akka es la mejor historia de las cinco y el peor laboratorio de las
cinco.** Las dos cosas se separan sin perder nada:

- **Laboratorio de CertCore → Lumen.**
- **Riesgo de licencia → contenido del track de LabCore** (SSPL de Mongo como
  caso propio, Elasticsearch/OpenSearch como caso medible).
- **Akka → párrafo de apéndice**, si acaso, como ejemplo del mismo patrón en
  otro ecosistema.
EOF
echo ok

# --- 2026-09-09T03:35:52 · Append actor taxonomy and Sinatra verdict
cat >> ideas_backend_cursos_angular.md <<'EOF'

---

## 10. 🎭 Cuarta ronda: el actor, y por qué Ruby/Sinatra gana

La aportación de esta ronda es que faltaba una columna, y era la importante:
**quién tomó la decisión**. Los cinco candidatos de §8 comparten un actor
implícito —*el mercado se equivocó*— y por eso ninguno duele del todo: hubo un
boom, una consultora, un vendor, y la culpa se diluye. Ruby/Sinatra introduce un
sexto fallo que no estaba: **deuda de autor**. No hubo boom que culpar. Hubo
**una persona con criterio propio y con autoridad suficiente para imponerlo**.

### 10.1 La tabla, ahora con actor

| Actor | Candidato | Cómo se decidió | El fallo | La frase |
|---|---|---|---|---|
| 🧑‍🎤 **El arquitecto enamorado** | Ruby + Sinatra | Gusto personal con autoridad. Nadie más lo eligió | **Deuda de autor** | "Esto no lo entiende nadie porque no lo escribió nadie más" |
| 🧑‍🔧 **El equipo pragmático** | Dart + Conduit | Coherencia técnica: el móvil ya era Flutter | Escasez de gente | "Nadie sabe esto y nadie quiere aprenderlo" |
| 🧑‍💼 **El jefe prudente** | Lumen | Economía de recursos: ya había gente de PHP | Familiaridad falsa | "Todos creen que saben esto, y se equivocan" |
| 🏢 **La consultora** | Scala + Akka | Arquitectura de referencia que llegó y se fue | Riesgo legal | "Una licencia cambió y tu arquitectura quedó ilegal" |
| 📈 **El comprador de promesas** | LoopBack 3 | Respaldo del vendor: "lo mantiene IBM" | Abandono del vendor | "La v4 existe, pero migrar es reescribir" |
| 🔭 **El early adopter con ojo** | RethinkDB | Juicio técnico correcto | Muerte de la empresa | "Elegiste bien y perdiste igual" |

> 🧠 **El eje que aparece al añadir la columna:** cada actor es un fallo de
> *gobierno* distinto — quién tuvo permiso para decidir y quién revisó. Eso
> convierte el track en algo que ningún tutorial enseña: **leer la decisión, no
> solo el código.** Todo legacy tiene autor y el autor tenía motivos.

### 10.2 Por qué Sinatra y no Rails

Rails **no sostiene ocho fases**, y el motivo es exactamente lo que lo hace
bueno: tiene convenciones. Un dev de Rails aterriza en cualquier código Rails y
en veinte minutos sabe dónde está todo, la comunidad está viva y el veredicto
honesto sería *"contrata un rubista, está bien"*. Fin del curso.

Sinatra quita precisamente eso. Son cuatrocientas líneas y **todo lo demás lo
inventó él**: su router, su capa de datos, su auth, sus plantillas. El
conocimiento no es transferible **ni siquiera a otro rubista**. Tres
consecuencias, y las tres son contenido:

**⚰️ La autopsia, y es contable.** Eligió Sinatra *sobre* Rails por purismo —
*"Rails es magia, es pesado, es opinionado; Sinatra es honesto"*. Es un
argumento real de la comunidad Ruby, dicho de buena fe, y a medias cierto. Y en
cinco años **reimplementó a mano el 60% de Rails, peor**. El alumno cuenta los
archivos: el número es la autopsia.

**Buscar no funciona.** Monkey patching y `method_missing`: el método que buscas
**no existe en ningún archivo**, y el comportamiento de una gema lo cambió
globalmente un fichero de `initializers` que nadie mira. Para un curso cuya
superpotencia es *leer código ajeno con `Ctrl+F`*, un código donde buscar falla
es el antagonista ideal. Ningún otro candidato ofrece esto.

**No hay a quién preguntar, y en 2026 eso significa algo nuevo.** No es solo que
StackOverflow no tenga tu problema: es que tu problema vive en
`lib/certcore/dispatcher.rb`, así que **un asistente tampoco puede ayudarte**.
Un modelo sabe Rails; nadie sabe el framework privado de alguien que se fue en
2021. Es una dimensión medible del coste de lo exótico que no existía cuando se
tomó la decisión, y que hoy pesa más que la mitad de los argumentos técnicos.

### 10.3 El cambio estructural: el backend es la v1, el Angular es "la versión nueva"

Segunda aportación de la ronda, y aplica a **cualquier** candidato. Arregla tres
cosas de una vez:

1. **La fecha deja de forzarse.** El backend es de 2016–2018 y el frontend de
   2021. El boom de Sinatra o de Lumen ya no tiene que coincidir con el de
   Angular, porque son dos sistemas de dos épocas.
2. **La forma rara del contrato se explica sola.** Esos endpoints se diseñaron
   para vistas ERB o para un SPA de jQuery, **no para Angular**. Por eso hay
   rutas que devuelven una pantalla en vez de un recurso, respuestas con HTML
   dentro, y paginación pensada para un `<select>`. El alumno deja de preguntarse
   por qué el contrato es feo: es feo porque **es de otro cliente**.
3. **El arco del personaje se cierra.** La modernización del frontend se decide
   en 2021, el arquitecto pierde esa discusión y se va. El backend queda como
   **monumento a alguien que ya no está**. Y —el detalle más realista de todos—
   la reescritura se quedó a medias: **hay pantallas que todavía sirve el
   sistema viejo**, en producción, hoy.

### 10.4 Veredicto: Sinatra desplaza a Lumen

Cambio la recomendación de §8.6, y el criterio nuevo es el que hace falta para
decidir entre los tres finalistas:

> 🧭 **El coste de laboratorio que importa no es el de arranque, es el de
> iteración.** Akka se cayó porque cobra 20–60 s **en cada vuelta**, y el alumno
> da miles de vueltas. Ruby cobra caro **una sola vez** —fijar un Ruby viejo,
> compilar gemas nativas, el drama conocido de ARM64 y OpenSSL 3 ⚠️— y después el
> ciclo editar-ejecutar es instantáneo. Además ese coste se encapsula en una
> imagen `linux/amd64`, y los dos cursos ya traen apéndice de contenedores
> (`a13-docker-colima.md`, `a09-docker-kubernetes.md`).

Con eso, Sinatra pasa el examen que Akka suspendió, y gana a Lumen donde de
verdad se decide: **el rendimiento forense**. Lumen produce un bug bueno
—familiaridad falsa, el fallo silencioso al pegar una respuesta de Laravel—.
Sinatra produce esa familia **y además** la de metaprogramación, la de las
convenciones inexistentes y la del framework privado. Para cursos cuya identidad
es el ticket vago, es más material y mejor.

**Lumen no se cae, se mueve.** Sigue siendo el mejor caso de *familiaridad
falsa* pura y el laboratorio más barato de los seis: primer suplente si Ruby se
complica, y candidato natural si algún día hay un tercer track.

**Estado del reparto tras esta ronda:**

| | Angular 8 · LabCore | Angular 16 · CertCore |
|---|---|---|
| Pecado | Moda de modelo de datos | **Deuda de autor** |
| Tecnología | MongoDB como store primario | **Ruby + Sinatra**, v1 del sistema |
| Actor | El equipo huyendo del DBA | **El arquitecto enamorado** |
| Extra | Riesgo de licencia (SSPL) como contenido | La reescritura que se quedó a medias |

**Nuevos ⚠️ por verificar:** el estado real de mantenimiento de Sinatra y su
última versión; la compilación de gemas nativas con Ruby 2.6/2.7 sobre ARM64 y
OpenSSL 3; y qué Rubies antiguos tienen imagen oficial `linux/arm64`.
EOF
echo ok

# --- 2026-09-09T03:40:29 · Append realism check section
cat >> ideas_backend_cursos_angular.md <<'EOF'

---

## 11. 🕵️ Quinta ronda: control de realismo sobre Sinatra

Pregunta de control: *"¿hubo proyectos reales, startups o empresas, que usaran
Sinatra?"* Es la pregunta correcta y obliga a corregir el guion.

### 11.1 Lo que sí existió

**Sinatra tuvo uso real y masivo en su nicho legítimo: el servicio pequeño
dentro de una empresa Ruby.** APIs internas, capas de API delante de un
monolito, y sobre todo **paneles de administración de gemas**. Los ejemplos
públicos son de código abierto y por tanto verificables sin depender de la
memoria de nadie:

- ⚠️ El web UI de **Resque** (de GitHub) era una app Sinatra.
- ⚠️ El web UI de **Sidekiq** lo fue durante años — y **acabó quitando la
  dependencia y reescribiéndose sobre Rack pelado**. Está en el changelog y es
  citable. *El consumidor insignia del framework se fue*: es el mejor dato duro
  disponible para el track, y no hay que inventarlo.
- ⚠️ La **API de Travis CI** era Sinatra, y es código abierto.

### 11.2 Lo que casi no existió

**Una empresa corriendo su producto central sobre Sinatra durante cinco años.**
En Ruby corporativo, "Ruby" significa Rails casi sin excepción. Así que la
versión cinematográfica de §10 —el arquitecto que impone Sinatra en un
greenfield porque le gusta `unless`— **es la parte del guion que un lector con
experiencia huele**. Hay que quitarla.

### 11.3 La corrección, que además mejora la lección

> 🧠 **Nadie decidió construir el sistema sobre Sinatra. Alguien decidió
> construir *un servicio* sobre Sinatra —y acertó— y después nadie volvió a
> decidir.**

Trescientas líneas un fin de semana para exponer los certificados al portal del
cliente. Correcto el día uno. Cinco años después son cuarenta endpoints, es el
sistema entero, y en medio no hubo una sola reunión donde alguien dijera *"esto
ya dejó de ser un servicio"*. Con el origen más verdadero que existe en
software: **"es provisional, mientras armamos el Rails"**.

Esto cambia la naturaleza de la deuda y la mejora:

> 🧭 **La deuda no la creó la decisión: la creó la ausencia de revisión.** Es un
> fallo de gobierno, no de criterio — más común y mucho menos enseñado que
> elegir mal.

**El arquitecto enamorado no se cae del reparto, cambia de papel.** El `unless`,
el purismo anti-Rails y la negativa a "meter magia" siguen ahí, pero ya no son la
causa: son **la razón por la que nadie revisó**. Cada vez que alguien propuso
pasar a Rails, él tenía un argumento bueno y ganaba la discusión. Villano
simpático y con razón parcial, que es como tienen que ser los de estos cursos.

Corrección a la tabla de §10.1, primera fila:

| Actor | Candidato | Cómo se decidió | El fallo | La frase |
|---|---|---|---|---|
| 🧑‍🎤 **El arquitecto enamorado** | Ruby + Sinatra | Nadie lo decidió: se eligió para *un servicio* y jamás se revisó | **Deuda de autor + deuda de revisión** | "Fue la decisión correcta el día uno y nadie volvió a mirarla" |

### 11.4 La alternativa de máximo realismo, y por qué no la tomo

**Rails 4.2 fosilizado.** Miles de empresas viven exactamente eso: ⚠️ EOL sin
parches de seguridad, atascado en Ruby 2.x, imposible de subir porque tres gemas
ya no existen, y el giro de familiaridad falsa de regalo — contratar *"un dev de
Rails"* no salva, porque sabe idiomas de Rails 7 que en 4.2 no existen.

Es **más creíble que Sinatra y bastante más aburrido**: se pierden las tres
cosas por las que Sinatra ganaba en §10.2 —el framework privado, las
convenciones inexistentes y el "no hay a quién preguntar"—.

**Decisión: se mantiene Sinatra con la corrección de §11.3.** Con ella ya no
necesita ser excepcional: un servicio Sinatra que creció sin supervisión es
completamente ordinario, que es justo lo que se buscaba. Rails 4.2 queda
anotado como plan B si la verificación de §11.1 sale peor de lo esperado.

**⚠️ Por verificar antes de escribir una línea:** los tres casos de §11.1 —Resque,
Sidekiq (y la versión exacta en que soltó Sinatra) y Travis CI—, más las fechas
de EOL de Rails 4.2 y Ruby 2.3 si se activa el plan B.
EOF
echo ok

# --- 2026-09-09T03:43:42 · Append Lumen verdict section
cat >> ideas_backend_cursos_angular.md <<'EOF'

---

## 12. 🐘 Sexta ronda: Lumen recupera el puesto (y por qué)

Objeción práctica: *"no quiero meter una imagen con rvm compilando cosas sobre
una Debian vieja, eso ya está en `docker-container-legacy`"*. Decide, y por dos
razones — la segunda más fuerte que la primera.

### 12.1 La razón de peso: duplicación, no fricción

`docker-container-legacy` ya cubre esto y mejor: `04-toolchain-de-compilacion.md`,
`05-python-y-node-gyp.md`, `14-abi-libc-y-prebuilds.md`,
`15-laboratorios-dependencias-nativas.md`. Y como el track BE debe ser
**autocontenido** —el de React lo declara: *"ninguna relación con otros cursos"*—
no bastaría con enlazar: habría que **reenseñarlo**. Dos fases gastadas en
repetir lo que ya está contado mejor en otro sitio.

### 12.2 El criterio técnico, que sirve para el futuro

> 🧭 **Las gemas de Ruby compilan; los paquetes de Composer no.**

`ruby:2.7` existe y hasta trae arm64 ⚠️ — Ruby nunca fue el problema. El
problema son `nokogiri`, `pg`, `mysql2`, `bcrypt`: extensiones nativas sin
binario preconstruido para ARM, que es la historia de `node-gyp` del otro curso
con otro nombre. En PHP, casi todo `composer.json` es PHP puro y lo poco nativo
se resuelve con una línea de `docker-php-ext-install` documentada en la propia
imagen oficial. `php:7.4-cli` y ya está.

### 12.3 Corrección a §10.4: fui demasiado generoso con Sinatra

Dije que Lumen producía una sola familia de bugs frente a las cuatro de Sinatra.
Falso. Produce cuatro, y el hueco forense es mucho más estrecho de lo que
escribí:

- **Facades.** `Cache::get()` no existe como método en ningún archivo: es
  `__callStatic` resolviendo contra el contenedor. **`grep` falla igual que en
  Ruby.**
- **En Lumen los facades están apagados por defecto** (`$app->withFacades()`).
  Familiaridad falsa en estado puro.
- **Magia de Eloquent:** `__get` para atributos dinámicos, `scopeActive()`
  invocado como `Model::active()`. Buscar no encuentra nada.
- **Lo que Lumen quitó de Laravel:** sesiones, parte de eventos y de middleware.
  La respuesta de internet asume que están.

### 12.4 El remate de 2026 mejora, no empeora

Con Sinatra el argumento era *"ni un modelo puede ayudarte, porque nadie conoce
el framework privado de ese señor"*. Con Lumen es peor y más enseñable:

> 🧠 **Un asistente te responde con confianza… en Laravel.** No hay ausencia de
> respuesta: hay **respuesta plausible y equivocada**. La ausencia te vuelve
> cuidadoso; lo plausible te vuelve confiado. Se demuestra en un ejercicio de
> diez minutos y es la versión más útil de la lección.

### 12.5 El actor sobrevive, con otro acento

No es el esteta del `unless`. Es alguien igual de real y de simpático: **llevaba
seis años escribiendo PHP 5.3 con `mysql_query` suelto, descubrió Laravel y le
cambió la vida** — y no exagera. Lumen era "Laravel para servicios, moderno y
rápido": su ascenso profesional y el del equipo. El pecado es idéntico al de
§11.3 y se conserva entero: **lo eligió para *un servicio*, acertó, y nadie
volvió a decidir.**

### 12.6 Dos avisos de laboratorio

**PHP 7.4 está EOL desde noviembre de 2022 ⚠️, y eso no es un problema: es la
premisa.** Un runtime sin parches de seguridad es exactamente el legacy que el
curso quiere, y regala el ticket que abre el track: *"seguridad exige subir a
PHP 8 y Lumen 5.x no arranca ahí"*.

**MySQL 5.7 puede reintroducir la fricción que se está evitando** ⚠️: su imagen
oficial fue amd64 durante mucho tiempo y en un Mac ARM se acaba emulando.
**MariaDB 10.x o PostgreSQL** tienen arm64 nativo y ahorran el apéndice entero.
Decisión a tomar ahora, no en la fase 4.

### 12.7 Reparto cerrado

| | Angular 8 · LabCore | Angular 16 · CertCore |
|---|---|---|
| **Pecado** | Moda de modelo de datos | **Ausencia de revisión** |
| **Tecnología** | MongoDB como store primario | **PHP 7.4 + Lumen**, v1 del sistema |
| **Actor** | El equipo huyendo del DBA | **El converso a Laravel** |
| **Fallo insignia** | Integridad, historia, auditoría | **Familiaridad falsa** |
| **Base de datos** | MongoDB 4.0 ⚠️ (replica set de un nodo) | **MariaDB o PostgreSQL**, nunca MySQL 5.7 |
| **Extra** | Riesgo de licencia (SSPL) como contenido | La reescritura que se quedó a medias |

**Suplentes:** Ruby/Sinatra queda como el mejor caso de *deuda de autor* pura,
descartado por coste de laboratorio y solapamiento con `docker-container-legacy`,
no por calidad narrativa. Dart sigue siendo el mejor caso de *escasez de gente*.
Scala/Akka aporta el caso de licencia, que se recoloca dentro de LabCore.

**⚠️ Verificar antes de escribir:** disponibilidad de `php:7.4-*` para arm64; la
fecha exacta de EOL de PHP 7.4; qué versión de Lumen corresponde a 2016–2018 y
en qué PHP dejó de arrancar; el estado oficial de Lumen frente a Laravel +
Octane; y la disponibilidad arm64 de MySQL 5.7 frente a MariaDB.
EOF
echo ok

# --- 2026-09-09T03:46:20 · Append PostgreSQL decision section
cat >> ideas_backend_cursos_angular.md <<'EOF'

---

## 13. 🐘 Séptima ronda: PostgreSQL, y la asimetría que lo justifica

Decisión: **PostgreSQL para CertCore**, imagen reciente. Cierra §12.6.

### 13.1 Lo de las licencias, matizado

La dualidad de MySQL no es solo legal en abstracto: **le dio forma al driver de
PHP**. `mysqlnd` existe porque `libmysqlclient` era GPL y contaminaba ⚠️. Buen
detalle, pero para este curso es una **distracción**: el tema de licencias ya
tiene dueño —LabCore, con SSPL de Mongo y Elasticsearch— y conviene que un solo
curso lo posea entero en vez de espolvorearlo por dos. Postgres deja a CertCore
concentrado en su pecado.

### 13.2 "Compatibilidad hacia arriba": cierto, con dos excepciones que muerden

SQL y protocolo de cable aguantan muy bien. Las dos que sí importan:

- **El directorio de datos no es compatible entre versiones mayores.** Da igual
  el SQL: un volumen creado con PG 15 no arranca bajo PG 16 sin `pg_upgrade` o
  dump/restore. Irrelevante si se fija una versión; relevante el día que se
  actualice el material del curso.
- **La autenticación.** Desde PG 14 el `password_encryption` por defecto es
  `scram-sha-256` ⚠️, y un cliente con `libpq` anterior a la 10 no habla SCRAM.

> 🧭 **La única verificación que decide el stack:** que el `pdo_pgsql` de
> `php:7.4` hable con un Postgres moderno. Debería —esa imagen trae la `libpq`
> de su Debian ⚠️—, pero es un `docker run` de dos minutos y hay que hacerlo
> antes de nada.

### 13.3 Imagen reciente, y la diferencia como contenido

Buscar la Postgres más antigua con soporte arm64 devuelve fricción que no enseña
nada —el pecado de CertCore no es la base de datos— y obliga a una arqueología
de tags. La alternativa aprovecha una asimetría cierta en todas las empresas:

> 🧠 **A la infraestructura sí la actualizan. A la aplicación no.** La base tiene
> dueño —un DBA, un proveedor gestionado, una auditoría— y fue subiendo de
> versión durante ocho años. La aplicación no tenía dueño y sigue en 2016.
> **CertCore es una app de 2016 hablando con una base de 2024.**

Justifica la imagen moderna sin inventar nada, refuerza la tesis del track
—nadie revisó nunca— y entrega tickets legítimos gratis:

- Código que asumía `WITH OIDS`, eliminado en PG 12 ⚠️.
- Escapado manual de comillas, de la era previa a
  `standard_conforming_strings` ⚠️.
- Comparaciones que dependían de casts implícitos que Postgres retiró ⚠️.

**Y un efecto secundario que conviene notar:** esta asimetría es reutilizable en
LabCore. Allí también hay un Mongo que alguien fue actualizando mientras la
aplicación se quedaba quieta — es el mismo motor narrativo aplicado al otro
pecado.
EOF
echo ok

# --- 2026-09-09T03:48:36 · Append DB upgrade timeline section
cat >> ideas_backend_cursos_angular.md <<'EOF'

---

## 14. 📅 Octava ronda: la base se actualizó antes que la app

Refinamiento aceptado, con fecha, motivo y culpable — un "se actualizó" genérico
no da juego; uno concreto da tres fases.

### 14.1 El motivo: nadie del equipo lo decidió

**El proveedor gestionado anunció fin de soporte y subió la versión en una
ventana de mantenimiento**, con un correo que alguien archivó. Y como CertCore
es una **empresa de certificaciones**, la ironía viene puesta: fue una auditoría
de cumplimiento la que exigió correr sobre versiones soportadas. *La
certificadora no pasaba su propia auditoría.*

> 🧭 **La base se movió porque alguien externo tenía un calendario. La aplicación
> se quedó porque nadie tenía uno.** La asimetría de §13.3 deja de ser una
> observación y pasa a ser mecánica de la historia.

### 14.2 Escalonado, no de un salto

9.6 → 11 → 13 → 16 ⚠️, cada uno con su fecha y su ventana. Más realista que un
salto único, entrega **una tabla que el alumno consulta como evidencia**, y
permite colgar bugs distintos de saltos distintos en vez de tener un evento
comodín. Va en el `historia-del-sistema` del track.

### 14.3 La propiedad forense que ninguna otra pieza da

> 🧠 **La causa y el síntoma están separados por meses, y el cambio que rompió no
> está en el repositorio.**

El upgrade migra los datos, no las suposiciones. Nadie corrió la suite contra la
versión nueva porque no hay suite. Durante meses no pasa nada, hasta que alguien
entra por un camino poco transitado. El alumno hace lo que hace siempre
—`git log`, `git blame`, revisar el último despliegue— y **no encuentra nada,
porque no hay nada**.

Es el ejercicio que rompe el reflejo. En unos cursos construidos sobre el par
`-roto`/`-fix` y el `git diff` como factura de la deuda, tener **un incidente
cuyo diff está vacío** vale mucho.

⚠️ **Atención de diseño:** ese incidente necesita convención propia para no
chocar con `00-convencion-de-git-y-tags.md`. Probablemente el "cambio" haya que
representarlo como un cambio de tag de imagen en el compose, no como un commit
de código.

### 14.4 Dos matices para que no quede como cuento

**Nada se rompió a lo grande precisamente porque Postgres es muy bueno en
compatibilidad.** El 95% siguió funcionando y por eso nadie miró. **La calidad de
la compatibilidad hacia atrás es lo que permitió el abandono**: paradoja real,
sin villanos fabricados, alineada con el criterio del repositorio.

**Los bugs se concentran donde alguien esquivó el framework.** Eloquent absorbe
casi todos los cambios de dialecto; lo que no absorbe es el `DB::select()` con
SQL a mano que alguien escribió para ir más rápido.

> 🧠 **La factura del salto de versión la paga exactamente el código que se
> saltó las convenciones.** Es la moraleja del track vista desde otro ángulo — y
> para diseñar ejercicios es un regalo, porque dice *dónde* ponerlos sin
> adivinar.
EOF
echo ok

# --- 2026-09-09T03:51:48 · Check php 7.4 image architectures on Docker Hub
for t in 7.4-cli 7.4-apache 7.4-fpm; do
  echo "=== php:$t ==="
  curl -s --max-time 20 "https://hub.docker.com/v2/repositories/library/php/tags/$t/" \
  | python3 -c "
import sys,json
try:
    d=json.load(sys.stdin)
except Exception as e:
    print('  no se pudo leer:',e); raise SystemExit
if 'images' not in d: print('  respuesta inesperada:',str(d)[:200]); raise SystemExit
for i in d['images']:
    print('  %-8s %-8s %-6s %s' % (i.get('os'), i.get('architecture'), i.get('variant') or '', i.get('status')))
print('  last_pushed:', d.get('tag_last_pushed'))
"
done

# --- 2026-09-09T03:52:15 · Check whether a Docker daemon is available
timeout 15 docker version --format '{{.Server.Os}}/{{.Server.Arch}} · engine {{.Server.Version}}' 2>&1 | head -5; echo "---"; timeout 10 docker info --format '{{.Architecture}} · {{.OperatingSystem}}' 2>&1 | head -3

# --- 2026-09-09T03:52:30 · Build PHP 7.4 arm64 image with pdo_pgsql and start Postgres 16
D=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f803daaa-f024-4042-af34-b44d49809430/scratchpad/phpcheck
mkdir -p $D && cd $D
cat > Dockerfile <<'EOF'
FROM php:7.4-cli
RUN apt-get update && apt-get install -y --no-install-recommends libpq-dev \
 && docker-php-ext-install pdo_pgsql \
 && rm -rf /var/lib/apt/lists/*
EOF
echo "### 1. levantando postgres:16 (arm64)"
docker rm -f pgcheck >/dev/null 2>&1
docker run -d --name pgcheck --platform linux/arm64 -e POSTGRES_PASSWORD=secret postgres:16 >/dev/null 2>&1 && echo "   ok"
echo "### 2. construyendo php:7.4 + pdo_pgsql (arm64)"
docker build --platform linux/arm64 -t php74check . 2>&1 | tail -4

# --- 2026-09-09T03:52:55 · Capture apt error detail and base OS
cd /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f803daaa-f024-4042-af34-b44d49809430/scratchpad/phpcheck
docker build --platform linux/arm64 --progress=plain --no-cache -t php74check . 2>&1 | grep -iE "err|fail|release|404|archive|deb\.debian" | head -20
echo "=== base OS de la imagen ==="
docker run --rm --platform linux/arm64 php:7.4-cli sh -c 'cat /etc/os-release | head -3; php -v | head -1'

# --- 2026-09-09T03:53:20 · Run PHP 7.4 to Postgres 16 connectivity test
D=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f803daaa-f024-4042-af34-b44d49809430/scratchpad/phpcheck
cd $D
cat > Dockerfile <<'EOF'
FROM php:7.4-cli
RUN apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends libpq-dev \
 && docker-php-ext-install pdo_pgsql \
 && rm -rf /var/lib/apt/lists/*
EOF
docker build --platform linux/arm64 -t php74check . 2>&1 | tail -2
echo "### prueba de conexión php 7.4 (arm64) -> postgres 16 (arm64)"
docker run --rm --platform linux/arm64 --link pgcheck:db php74check php -r '
$p = new PDO("pgsql:host=db;dbname=postgres", "postgres", "secret");
echo "  conexion:      OK\n";
echo "  servidor:      ", $p->query("SHOW server_version")->fetchColumn(), "\n";
echo "  auth del user: ", $p->query("SELECT rolpassword LIKE \"SCRAM%\" FROM pg_authid WHERE rolname=\"postgres\"")->fetchColumn() ? "SCRAM-SHA-256" : "otra", "\n";
echo "  libpq cliente: ", PHP_VERSION, " / pdo_pgsql ", phpversion("pdo_pgsql"), "\n";
$p->exec("CREATE TABLE t(id serial primary key, n text)");
$s = $p->prepare("INSERT INTO t(n) VALUES (?)"); $s->execute(["hola"]);
echo "  escritura:     ", $p->query("SELECT n FROM t")->fetchColumn(), "\n";
' 2>&1 | sed 's/^/  /'

# --- 2026-09-09T03:53:31 · Show build error detail
cd /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f803daaa-f024-4042-af34-b44d49809430/scratchpad/phpcheck
docker build --platform linux/arm64 --progress=plain -t php74check . 2>&1 | grep -iE "^#5 .*(E:|W:|err)|ERROR" | head -10

# --- 2026-09-09T03:53:51 · Build with archive.debian.org and run connectivity test
D=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f803daaa-f024-4042-af34-b44d49809430/scratchpad/phpcheck
cd $D
cat > Dockerfile <<'EOF'
FROM php:7.4-cli
RUN printf 'deb http://archive.debian.org/debian bullseye main\ndeb http://archive.debian.org/debian-security bullseye-security main\n' > /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends libpq-dev \
 && docker-php-ext-install pdo_pgsql \
 && rm -rf /var/lib/apt/lists/*
EOF
docker build --platform linux/arm64 -t php74check . 2>&1 | grep -iE "ERROR|E:|naming to|DONE" | tail -3
echo "### php 7.4 (arm64) -> postgres 16 (arm64)"
docker run --rm --platform linux/arm64 --link pgcheck:db php74check php -r '
$p = new PDO("pgsql:host=db;dbname=postgres","postgres","secret");
$q = function($s) use ($p){ return $p->query($s)->fetchColumn(); };
echo "  conexion:       OK\n";
echo "  servidor:       PostgreSQL ", $q("SHOW server_version"), "\n";
echo "  password_encr:  ", $q("SHOW password_encryption"), "\n";
echo "  hash del user:  ", substr($q("SELECT rolpassword FROM pg_authid WHERE rolname=\047postgres\047"),0,13), "\n";
echo "  php:            ", PHP_VERSION, "\n";
$p->exec("CREATE TABLE IF NOT EXISTS t(id serial primary key, n text)");
$s=$p->prepare("INSERT INTO t(n) VALUES (?)"); $s->execute(["hola"]);
echo "  escritura:      ", $q("SELECT n FROM t LIMIT 1"), "\n";
' 2>&1 | sed 's/^/  /'
docker rm -f pgcheck >/dev/null 2>&1; echo "  (postgres de prueba eliminado)"

# --- 2026-09-09T03:54:06 · Inspect apt sources and test archive repo
docker run --rm --platform linux/arm64 php:7.4-cli sh -c '
echo "--- sources.list ---"; cat /etc/apt/sources.list 2>/dev/null
echo "--- sources.list.d ---"; ls -la /etc/apt/sources.list.d/ 2>/dev/null
echo "--- prueba archive ---"
printf "deb http://archive.debian.org/debian bullseye main\ndeb http://archive.debian.org/debian-security bullseye-security main\n" > /etc/apt/sources.list
apt-get -o Acquire::Check-Valid-Until=false update 2>&1 | tail -8
' 2>&1 | head -40

# --- 2026-09-09T03:54:32 · Build with snapshot.debian.org and run the connectivity test
D=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f803daaa-f024-4042-af34-b44d49809430/scratchpad/phpcheck
cd $D
cat > Dockerfile <<'EOF'
FROM php:7.4-cli
# El Dockerfile oficial trae estas fuentes comentadas: apt congelado al dia del build.
RUN printf 'deb http://snapshot.debian.org/archive/debian/20221114T000000Z bullseye main\ndeb http://snapshot.debian.org/archive/debian-security/20221114T000000Z bullseye-security main\n' > /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends libpq-dev \
 && docker-php-ext-install pdo_pgsql \
 && rm -rf /var/lib/apt/lists/*
EOF
docker build --platform linux/arm64 -t php74check . 2>&1 | grep -iE "ERROR|E: |naming to" | tail -3
docker rm -f pgcheck >/dev/null 2>&1
docker run -d --name pgcheck --platform linux/arm64 -e POSTGRES_PASSWORD=secret postgres:16 >/dev/null && sleep 6
echo "### php 7.4 (arm64) -> postgres 16 (arm64)"
docker run --rm --platform linux/arm64 --link pgcheck:db php74check php -r '
$p = new PDO("pgsql:host=db;dbname=postgres","postgres","secret");
$q = function($s) use ($p){ return $p->query($s)->fetchColumn(); };
echo "  conexion:       OK\n";
echo "  servidor:       PostgreSQL ", $q("SHOW server_version"), "\n";
echo "  password_encr:  ", $q("SHOW password_encryption"), "\n";
echo "  hash del user:  ", substr($q("SELECT rolpassword FROM pg_authid WHERE rolname=\047postgres\047"),0,13), "...\n";
echo "  php:            ", PHP_VERSION, " (", php_uname("m"), ")\n";
$p->exec("CREATE TABLE IF NOT EXISTS t(id serial primary key, n text)");
$s=$p->prepare("INSERT INTO t(n) VALUES (?)"); $s->execute(["hola"]);
echo "  escritura:      ", $q("SELECT n FROM t LIMIT 1"), "\n";
' 2>&1 | sed 's/^/  /'
docker rm -f pgcheck >/dev/null 2>&1; echo "  (limpieza hecha)"

# --- 2026-09-09T03:56:00 · Append verification results and Symfony analysis
cat >> ideas_backend_cursos_angular.md <<'EOF'

---

## 15. ✅ Novena ronda: verificación ejecutada, el reciclado, y Symfony

### 15.1 La verificación bloqueante de §13.2: **pasa**

Ejecutada el 8/09/2026 sobre Docker Desktop 29.6.2, host `aarch64`.

**Arquitectura** (API de Docker Hub): `php:7.4-cli`, `7.4-apache` y `7.4-fpm`
publican `linux/arm64/v8` **activo**. Último push de las tres:
**2022-11-15**, es decir, la imagen se congeló al llegar PHP 7.4 a EOL. Dato
duro y citable.

**Runtime** (PHP 7.4.33 arm64 → PostgreSQL 16.9 arm64):

```
conexion:       OK
servidor:       PostgreSQL 16.9
password_encr:  scram-sha-256
hash del user:  SCRAM-SHA-256...
php:            7.4.33 (aarch64)
escritura:      hola
```

**La `libpq 13` de bullseye habla SCRAM sin problema.** La duda de §13.2 queda
cerrada y el stack es viable: PHP 7.4 + Lumen + PostgreSQL moderno, todo arm64
nativo, sin emulación.

### 15.2 Hallazgo del día: la imagen se murió mientras hablábamos

El primer `docker build` falló así:

```
E: Release file for http://deb.debian.org/debian-security/dists/bullseye-security/InRelease
   is expired (invalid since 1d 6h 39min 54s)
```

**El LTS de Debian 11 bullseye —base de `php:7.4-cli`— caducó hace poco más de
un día.** Al forzar la fecha con `-o Acquire::Check-Valid-Until=false`, el
siguiente error fue `404`: los paquetes ya se movieron a `archive.debian.org`.

No es un ejemplo didáctico: es la muerte de una imagen **en directo, con fecha y
mensaje literal**, capturada el día que ocurrió. Es exactamente la clase de
evidencia que el repositorio valora, y el track la tiene gratis.

### 15.3 La solución, que la imagen traía escrita dentro

El `/etc/apt/sources.list` de la imagen oficial incluye, **comentadas**, sus
propias fuentes de `snapshot.debian.org` fijadas al `20221114T000000Z` — el día
del build. Descomentarlas da un apt determinista, inmune al paso del tiempo, y
construyó a la primera:

```dockerfile
FROM php:7.4-cli
RUN printf 'deb http://snapshot.debian.org/archive/debian/20221114T000000Z bullseye main\ndeb http://snapshot.debian.org/archive/debian-security/20221114T000000Z bullseye-security main\n' > /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends libpq-dev \
 && docker-php-ext-install pdo_pgsql \
 && rm -rf /var/lib/apt/lists/*
```

> 🧠 **La imagen traía escrita su propia cápsula del tiempo y nadie la lee
> nunca.** Receta obligatoria del apéndice de contenedores del track, y lección
> en sí misma.

⚠️ **Nota de mantenimiento:** `archive.debian.org/debian-security` todavía no
servía `bullseye-security` en la fecha de la prueba. Si `snapshot.debian.org`
llegara a fallar, el plan B es usar solo `bullseye main` desde el archivo.

### 15.4 El "reciclado" no es solo un coste: es un clasificador

Aportación de esta ronda. El mercado de devs **PHP** es enorme; el de devs
**Lumen** no existe. Así que quien entra viene reciclado de Laravel, de Symfony
o de frameworks hoy menos populares como CakePHP — **barato y disponible, pero
con formación que hay que pagar y que se va en dieciocho meses** porque otra
consultora mejora el salario. Economía de rotación: se paga el onboarding una y
otra vez y nunca se amortiza.

Y tiene una consecuencia que es contenido puro:

> 🧠 **El dev que llega deja huella según de dónde venga.** El de Laravel asume
> facades, contenedor completo y `config()`. El de Symfony mete inyección por
> constructor y servicios donde el resto usa service locator. El de CakePHP
> arrastra Active Record y convenciones de tabla que aquí no existen.

**El bug te dice de dónde venía quien lo escribió.** El código tiene estratos
**por procedencia**, no por fecha. Eso conecta con los ejercicios 🧬 que Angular
16 ya usa —*"¿este archivo es de 2021 o de 2024?"*— girando el eje: aquí la
pregunta es *"¿de qué framework venía el autor?"*. Mismo método, otra dimensión;
los dos tracks se sienten de la misma casa sin repetirse.

### 15.5 Symfony: el grupo de control, no el paciente

Pierde como candidato por la misma razón que Rails: **no tiene problemas
suficientes**. Es enorme, está sano, y su disciplina de actualización es famosa
y buena — avisos de deprecación, LTS cada dos años (2.8, 3.4, 4.4, 5.4, 6.4 ⚠️),
Rector y herramientas de upgrade. El veredicto honesto sería *"súbelo, hay
camino"*, y eso no sostiene ocho fases.

Donde sí duele, para el registro:

- **El salto de 2/3 a 4 con Flex**, que reestructuró el proyecto entero —`app/`
  desaparece, `AppBundle` se abandona— y deja un Symfony 3 estructuralmente
  ajeno a cualquiera que aprendiera después ⚠️.
- **Cuatro eras de configuración conviviendo:** XML, YAML, anotaciones,
  atributos.
- **El contenedor de inyección compilado**, con su clásico *"funciona después de
  `cache:clear`"*.
- **Doctrine**, que es el monstruo real: migraciones que divergen de la base de
  verdad, proxies perezosos, N+1. Duele más que Symfony mismo.
- **El ecosistema de bundles de la era 2.x murió** (FOSUserBundle y compañía):
  abandono de vendor a nivel de dependencia ⚠️.

**Su papel en el proyecto es mejor que el de paciente:**

1. **Destino** en el árbol de veredicto — la opción *"reescribir a algo aburrido
   y sostenido"*.
2. **Origen** de la mitad de los reciclados de §15.4.
3. **Vara de medir:** su disciplina de deprecaciones es el contraste exacto que
   hace visible que Lumen no tenía ninguna.

### 15.6 Estado

Stack de CertCore **confirmado y medido**: PHP 7.4 + Lumen + PostgreSQL moderno,
arm64 nativo. De la lista de ⚠️ bloqueantes no queda ninguna. Las que siguen
abiertas ya solo ajustan detalle: qué versión de Lumen corresponde a 2016–2018 y
en qué PHP dejó de arrancar, y el estado oficial de Lumen frente a Laravel +
Octane.
EOF
echo ok

# --- 2026-09-09T04:02:53 · Check arm64 availability for mongo, temurin 8 and postgres tags
chk(){ curl -s --max-time 20 "https://hub.docker.com/v2/repositories/library/$1/tags/$2/" \
 | python3 -c "
import sys,json
d=json.load(sys.stdin)
if 'images' not in d: print('  %-22s NO EXISTE' % '$1:$2'); raise SystemExit
arch=sorted({i['architecture'] for i in d['images'] if i.get('status')=='active'})
mark='arm64 SI ' if 'arm64' in arch else 'arm64 NO '
print('  %-22s %s  [%s]  push %s' % ('$1:$2', mark, ','.join(arch), (d.get('tag_last_pushed') or '')[:10]))
" 2>/dev/null || echo "  $1:$2  (sin respuesta)"; }
echo "=== MongoDB ==="
for v in 3.6 4.0 4.2 4.4 5.0 6.0 7.0 8.0; do chk mongo $v; done
echo "=== JDK 8 ==="
for v in 8-jdk 8-jdk-focal 8-jdk-jammy; do chk eclipse-temurin $v; done
echo "=== PostgreSQL ==="
for v in 15 16 17 18; do chk postgres $v; done

# --- 2026-09-09T04:04:09 · Runtime check of mongo 4.0 and temurin 8 on arm64
echo "### mongo:4.0 arm64 nativo"
docker rm -f m40 >/dev/null 2>&1
docker run -d --name m40 --platform linux/arm64 mongo:4.0 >/dev/null 2>&1 && sleep 8
docker exec m40 mongo --quiet --eval '
  print("  version:    " + db.version());
  print("  arquitect.: " + db.serverBuildInfo().buildEnvironment.target_arch);
  print("  topologia:  " + (rs.status().ok ? "replica set" : "standalone"));
  var e=""; try { var s=db.getMongo().startSession(); s.startTransaction(); e="permitida"; } catch(x){ e="RECHAZADA -> " + x.message.substring(0,60); }
  print("  transaccion: " + e);
' 2>&1 | sed 's/^/  /' | head -8
docker rm -f m40 >/dev/null 2>&1
echo "### temurin 8 arm64 nativo"
docker run --rm --platform linux/arm64 eclipse-temurin:8-jdk sh -c 'java -version 2>&1 | head -2; echo "  uname: $(uname -m)"' 2>&1 | sed 's/^/  /'

# --- 2026-09-09T04:04:47 · Verify transaction rejection on standalone mongo 4.0
docker rm -f m40 >/dev/null 2>&1
docker run -d --name m40 --platform linux/arm64 mongo:4.0 >/dev/null 2>&1 && sleep 8
docker exec m40 mongo --quiet --eval '
var s = db.getMongo().startSession();
var c = s.getDatabase("lab").custody;
s.startTransaction();
try { c.insertOne({step:"recepcion"}); s.commitTransaction(); print("  RESULTADO: transaccion COMPLETADA"); }
catch(e){ print("  RESULTADO: RECHAZADA"); print("  codigo:  " + e.code + " (" + e.codeName + ")"); print("  mensaje: " + e.errmsg); }
' 2>&1 | sed 's/^/  /'
docker rm -f m40 >/dev/null 2>&1; echo "  (limpieza hecha)"

# --- 2026-09-09T04:06:08 · Append closed decisions section
cat >> ideas_backend_cursos_angular.md <<'EOF'

---

## 16. 🔒 Décima ronda: decisiones cerradas

Todo verificado el 8/09/2026 sobre Docker Desktop 29.6.2, host `aarch64`.

### 16.1 Nada necesita emulación

| Imagen | arm64 | Comprobación |
|---|---|---|
| `php:7.4-cli/apache/fpm` | ✅ | registro **y runtime** (PHP 7.4.33 aarch64 → PG 16.9, SCRAM ok) |
| `postgres:15/16/17/18` | ✅ | registro y runtime |
| `mongo:3.6/4.0/4.2/4.4/6.0/7.0/8.0` | ✅ | registro; `mongo:4.0` también en runtime (4.0.28, `aarch64`) |
| `eclipse-temurin:8-jdk` | ✅ | runtime (`1.8.0_502`, `aarch64`) |

> 🧭 **Corrige la preocupación de §9.3:** JDK 8 para **Linux**/aarch64 sí existe;
> lo que no existe es para *macOS* aarch64. Como todo corre en contenedor, es
> irrelevante. La receta es la que se planteó: un `Dockerfile`, `docker build`, y
> quien quiera el detalle que vaya a `docker-container-legacy`.

### 16.2 El artefacto central de LabCore, medido

`mongo:4.0` standalone, transacción con operación real dentro:

```
RESULTADO: RECHAZADA
codigo:  20
mensaje: Transaction numbers are only allowed on a replica set member or mongos
```

> 🧠 **El propio mensaje de error enuncia la tesis del track:** la capacidad
> existía en el producto y **una decisión de despliegue de 2019 la dejó fuera de
> alcance**. No hay que argumentarlo: se enseña.

⚠️ Detalle de método: en el shell, `startTransaction()` es perezoso y no lanza
nada; el rechazo llega en la primera operación de la sesión. La primera versión
de esta prueba dio un falso "permitida".

### 16.3 CertCore — cerrado

| | Decisión |
|---|---|
| Framework | **Lumen** sobre `php:7.4-cli` |
| Base de datos | **PostgreSQL 16** (`postgres:16.9`, digest en `decisiones-y-versiones.md`) |
| Arranque | Un `Dockerfile` con las fuentes `snapshot.debian.org` de §15.3 |

**Por qué 16 y no 15:** un año más de soporte (EOL nov-2028 frente a nov-2027
⚠️) y mejor encaje cronológico — PG 16 salió en septiembre de 2023, así que la
última subida forzada por el proveedor cae natural en 2024. Cadena definitiva:
**9.6 → 11 → 13 → 16**.

### 16.4 LabCore — cerrado, salvo un dato

| | Decisión |
|---|---|
| Lenguaje | **Java 8** (`eclipse-temurin:8-jdk`) |
| Framework | **Spring Boot 2.1** + `spring-data-mongodb`, Maven |
| Base de datos | **`mongo:4.0` standalone** para el sistema de 2019 |

**Boot 2.1 y no 1.5:** 2.1 es de octubre de 2018, lo que instalaría un equipo que
arranca en 2019. Boot 1.5 implicaría un proyecto empezado en 2017 y contradice
la historia ya escrita.

**WildFly con JEE 7/8: descartado**, por acumulación de cuatro razones:

1. Mete un **segundo pecado** —el servidor de aplicaciones— que compite con el
   de Mongo por la atención del curso.
2. Encarece el **ciclo de iteración** (desplegar un WAR frente a
   `mvn spring-boot:run`): el criterio que ya tumbó a Akka en §9.
3. **Pierde el mejor mecanismo pedagógico.** JEE no tiene equivalente de
   `@Document` + repositories para Mongo, así que desaparece el efecto *"parecía
   JPA"* que era la razón de elegir Spring en §3.5.
4. Un equipo con músculo de JPA difícilmente habría elegido una base sin JPA.

**Pero JEE se muda a la historia.** El equipo venía de WebLogic, Oracle y un DBA
que tardaba tres semanas: *eso* es de lo que huían, y explica la decisión de
2019. Mismo papel que Symfony en CertCore (§15.5) — contexto y vara de medir, no
paciente.

### 16.5 La fase que la asimetría le regala a LabCore

Aplicando §13.3 —la infraestructura tiene dueño, la aplicación no—, el track gana
una fase entera en vez de una nota al pie:

- Las primeras fases construyen el sistema de 2019 sobre **`mongo:4.0`**.
- **Una fase es la subida forzada por el proveedor**, donde el alumno descubre
  qué cambió sin que nadie tocara el código. El shell `mongo` sustituido por
  `mongosh` ⚠️ ya es un ticket por sí solo.
- Y nadie convierte un standalone en replica set durante un bump de versión: la
  topología de 2019 **sobrevive intacta** al upgrade. La transacción sigue siendo
  imposible en 2026, y ahora además el manual dice que se puede.

### 16.6 El único ⚠️ que queda, y decide contenido

**¿Hasta qué versión de servidor llega el driver Java de 2019 antes de dejar de
conectar?** Determina el destino del salto de §16.5 — 4.4, 6.0 o más.

Y la respuesta *es* contenido en cualquier caso: si el driver 3.x no alcanza, el
upgrade obligó a tocar el `pom.xml`, y entonces aparece algo mejor que "nadie
tocó nada en seis años":

> 🧠 **El único commit del repositorio en seis años es una subida de driver hecha
> con prisa y sin probar.** Objetivo perfecto para el ejercicio de arqueología
> con `git log`, y coartada perfecta para el bug que aparece meses después.

**Resto de ⚠️ abiertos, ya sin capacidad de bloquear:** qué versión de Lumen
corresponde a 2016–2018 y en qué PHP dejó de arrancar; el estado oficial de
Lumen frente a Laravel + Octane; los tres casos de uso real de §11.1 si alguna
vez se rescata Sinatra.
EOF
echo ok

# --- 2026-09-09T04:09:45 · Find mock API ports in both Angular courses
cd /Users/oskar/Developer/Learning/courses-ia-generated
for f in angular-8-legacy-for-backend-devs/04-mock-api-caos.md angular-16-legacy-for-backend-devs/03-mock-api-caos.md; do
  echo "=== $f ==="
  grep -oE "localhost:[0-9]{4}|puerto \`?[0-9]{4}|PORT[ =:]+[0-9]{4}|:[0-9]{4}/" "$f" | sort | uniq -c | sort -rn | head -6
done

# --- 2026-09-09T04:10:13 · Build and test CertCore compose stack
S=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f803daaa-f024-4042-af34-b44d49809430/scratchpad
mkdir -p $S/certcore/docker/php $S/certcore/public && cd $S/certcore
cat > .env <<'EOF'
# La version de la base vive AQUI, fuera del codigo fuente.
POSTGRES_TAG=16.9
EOF
cat > docker/php/Dockerfile <<'EOF'
FROM php:7.4-cli
# apt congelado al dia del build de la imagen oficial (ver README)
RUN printf 'deb http://snapshot.debian.org/archive/debian/20221114T000000Z bullseye main\ndeb http://snapshot.debian.org/archive/debian-security/20221114T000000Z bullseye-security main\n' > /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends libpq-dev unzip \
 && docker-php-ext-install pdo_pgsql \
 && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /app
EOF
cat > compose.yaml <<'EOF'
services:
  db:
    image: postgres:${POSTGRES_TAG}
    environment:
      POSTGRES_PASSWORD: certcore
      POSTGRES_DB: certcore
    volumes: [pgdata:/var/lib/postgresql/data]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 2s
      retries: 15
  api:
    build: ./docker/php
    ports: ["3000:3000"]
    volumes: [".:/app"]
    environment:
      DB_DSN: "pgsql:host=db;dbname=certcore"
    depends_on:
      db: {condition: service_healthy}
    command: php -S 0.0.0.0:3000 -t public
volumes:
  pgdata:
EOF
cat > public/index.php <<'EOF'
<?php
header('Content-Type: application/json');
$p = new PDO(getenv('DB_DSN'), 'postgres', 'certcore');
echo json_encode([
  'service'  => 'certcore-api (Lumen ira aqui)',
  'php'      => PHP_VERSION,
  'arch'     => php_uname('m'),
  'postgres' => $p->query('SHOW server_version')->fetchColumn(),
], JSON_PRETTY_PRINT), "\n";
EOF
echo "### docker compose up -d"
docker compose up -d 2>&1 | tail -3
sleep 4
echo "### curl localhost:3000"
curl -s --max-time 15 localhost:3000 | sed 's/^/  /'

# --- 2026-09-09T04:10:56 · Check maven temurin 8 image architectures
curl -s --max-time 15 "https://hub.docker.com/v2/repositories/library/maven/tags/3.8-eclipse-temurin-8/" | python3 -c "
import sys,json; d=json.load(sys.stdin)
print('maven:3.8-eclipse-temurin-8 ->', sorted({i['architecture'] for i in d.get('images',[]) if i.get('status')=='active'}))" 2>/dev/null || echo "tag no encontrado"

# --- 2026-09-09T04:11:13 · Set up LabCore compose and Maven probe project
S=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f803daaa-f024-4042-af34-b44d49809430/scratchpad
mkdir -p $S/labcore/src/main/java && cd $S/labcore
cat > .env <<'EOF'
# La version de la base vive AQUI, fuera del codigo fuente.
MONGO_TAG=4.0
EOF
cat > compose.yaml <<'EOF'
services:
  db:
    image: mongo:${MONGO_TAG}
    volumes: [mongodata:/data/db]
  api:
    image: maven:3.8-eclipse-temurin-8
    working_dir: /app
    ports: ["3000:3000"]
    volumes: [".:/app", "m2:/root/.m2"]
    environment:
      MONGO_URI: "mongodb://db:27017"
    depends_on: [db]
    command: mvn -q compile exec:java
volumes:
  mongodata:
  m2:
EOF
cat > pom.xml <<'EOF'
<project xmlns="http://maven.apache.org/POM/4.0.0"><modelVersion>4.0.0</modelVersion>
<groupId>lab</groupId><artifactId>probe</artifactId><version>1</version>
<properties><maven.compiler.source>8</maven.compiler.source><maven.compiler.target>8</maven.compiler.target></properties>
<dependencies><dependency>
  <groupId>org.mongodb</groupId><artifactId>mongo-java-driver</artifactId><version>3.8.2</version>
</dependency></dependencies>
<build><plugins><plugin>
  <groupId>org.codehaus.mojo</groupId><artifactId>exec-maven-plugin</artifactId><version>3.1.0</version>
  <configuration><mainClass>Probe</mainClass></configuration>
</plugin></plugins></build></project>
EOF
cat > src/main/java/Probe.java <<'EOF'
import com.mongodb.MongoClient; import com.mongodb.MongoClientURI;
import org.bson.Document;
public class Probe {
  public static void main(String[] a) {
    String uri = System.getenv("MONGO_URI");
    try (MongoClient c = new MongoClient(new MongoClientURI(uri))) {
      Document b = c.getDatabase("admin").runCommand(new Document("buildInfo", 1));
      System.out.println("  OK  driver 3.8.2 -> servidor " + b.getString("version"));
    } catch (Throwable e) {
      System.out.println("  FALLA  " + e.getClass().getSimpleName() + ": "
        + String.valueOf(e.getMessage()).replaceAll("\\s+"," ").substring(0, Math.min(150, String.valueOf(e.getMessage()).length())));
    }
  }
}
EOF
echo "### primera compilacion (baja dependencias a un volumen, ocurre una sola vez)"
docker compose run --rm -T api mvn -q compile 2>&1 | tail -3
echo "   listo"

# --- 2026-09-09T04:12:12 · Test mongo java driver 3.8 against multiple server versions
cd /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f803daaa-f024-4042-af34-b44d49809430/scratchpad/labcore
echo "### driver Java 3.8.2 (el de 2019) contra cada version de servidor"
for tag in 4.0 4.2 4.4 5.0 6.0 7.0 8.0; do
  printf "mongo:%-4s " "$tag"
  MONGO_TAG=$tag docker compose down -v >/dev/null 2>&1
  MONGO_TAG=$tag docker compose up -d db >/dev/null 2>&1
  sleep 7
  MONGO_TAG=$tag docker compose run --rm -T api mvn -q exec:java 2>&1 | grep -E "OK |FALLA " | head -2
done
docker compose down -v >/dev/null 2>&1; echo "(limpieza hecha)"

# --- 2026-09-09T04:15:10 · Check mongo vs mongosh shell availability by version
for t in 4.0 6.0 7.0; do
  printf "mongo:%-4s  " "$t"
  docker run --rm --entrypoint sh --platform linux/arm64 mongo:$t -c '
    m=$(command -v mongo >/dev/null 2>&1 && echo si || echo NO)
    s=$(command -v mongosh >/dev/null 2>&1 && echo si || echo NO)
    echo "shell \"mongo\": $m   |   \"mongosh\": $s"' 2>&1 | tail -1
done

# --- 2026-09-09T04:16:07 · Append compose stacks section to ideas doc
cd /Users/oskar/Developer/Learning/courses-ia-generated
cat >> ideas_backend_cursos_angular.md <<'MD'

---

## 17. 🐳 Undécima ronda: las dos pilas, probadas

Encargo: que ambos backends arranquen con compose y que el README traiga **solo
comandos**. Aquí no se teoriza sobre contenedores — eso tiene su tutorial.

> 🧭 **La regla para la guía de estilo del track:** si algo de contenedores
> necesita explicación, no se explica: se pone en el compose y se enlaza a
> `docker-container-legacy`. Lo único que el README enseña son los comandos.

**Puerto:** los dos cursos usan **3000** para el mock (`04-mock-api-caos.md` y
`03-mock-api-caos.md`), así que el backend ocupa el 3000. ⚠️ angular-8 menciona
un 3001 una vez: mirar para qué antes de escribir el contrato.

### 17.1 El README, en cuatro comandos idénticos para los dos cursos

```bash
docker compose up -d          # levanta la base + la API en el 3000
curl localhost:3000/health    # comprobar
docker compose logs -f api    # ver que pasa
docker compose down           # parar (con -v borra la base)
```

Lo único que hay que advertir: la primera vez tarda porque baja dependencias a
un volumen nombrado, y a partir de ahí no vuelve a hacerlo. En LabCore, además,
**el alumno nunca instala un JDK**.

### 17.2 CertCore — probado, responde

`compose.yaml`:

```yaml
services:
  db:
    image: postgres:${POSTGRES_TAG}
    environment: {POSTGRES_PASSWORD: certcore, POSTGRES_DB: certcore}
    volumes: [pgdata:/var/lib/postgresql/data]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 2s
      retries: 15
  api:
    build: ./docker/php
    ports: ["3000:3000"]
    volumes: [".:/app"]
    environment: {DB_DSN: "pgsql:host=db;dbname=certcore"}
    depends_on: {db: {condition: service_healthy}}
    command: php -S 0.0.0.0:3000 -t public
volumes: {pgdata: }
```

`docker/php/Dockerfile` — con la cápsula del tiempo de §15.3:

```dockerfile
FROM php:7.4-cli
RUN printf 'deb http://snapshot.debian.org/archive/debian/20221114T000000Z bullseye main\ndeb http://snapshot.debian.org/archive/debian-security/20221114T000000Z bullseye-security main\n' > /etc/apt/sources.list \
 && apt-get -o Acquire::Check-Valid-Until=false update \
 && apt-get install -y --no-install-recommends libpq-dev unzip \
 && docker-php-ext-install pdo_pgsql \
 && rm -rf /var/lib/apt/lists/*
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /app
```

Salida real de `curl localhost:3000` tras `docker compose up -d`:

```json
{ "php": "7.4.33", "arch": "aarch64", "postgres": "16.9 (Debian 16.9-1.pgdg130+1)" }
```

### 17.3 LabCore — probado, sin JDK en la máquina del alumno

```yaml
services:
  db:
    image: mongo:${MONGO_TAG}
    volumes: [mongodata:/data/db]
  api:
    image: maven:3.8-eclipse-temurin-8      # arm64 confirmado
    working_dir: /app
    ports: ["3000:3000"]
    volumes: [".:/app", "m2:/root/.m2"]     # cache de Maven: se baja una vez
    environment: {MONGO_URI: "mongodb://db:27017"}
    depends_on: [db]
    command: mvn -q spring-boot:run
volumes: {mongodata: , m2: }
```

El volumen `m2` es lo que hace que el ciclo de iteración sea aceptable — el
criterio de §9 que tumbó a Akka.

### 17.4 Hallazgo: la versión de la base vive en `.env`, fuera del código

```
# .env — La version de la base vive AQUI, fuera del codigo fuente.
MONGO_TAG=4.0
```

> 🧠 La fase de "subida forzada por el proveedor" (§16.5) es **cambiar una línea
> de un archivo que no es código**. El alumno hace `git log` buscando qué rompió
> y no encuentra nada, porque no hay nada en el árbol de fuentes. Entrega la
> lección de §14.3 —*el cambio que rompió no está en el repositorio*— **sin
> forzar ninguna convención de tags**, que era el ⚠️ de diseño que quedaba
> abierto ahí.

### 17.5 Corrección de §16.6: el driver de 2019 llega hasta Mongo 8.0

Medido con `mongo-java-driver` 3.8.2 y Java 8, servidor por servidor:

```
mongo:4.0  OK    mongo:5.0  OK    mongo:7.0  OK
mongo:4.2  OK    mongo:6.0  OK    mongo:8.0  OK
```

**La hipótesis de §16.6 era falsa: no hubo bump de `pom.xml`.** Nadie tocó la
aplicación, nunca, ni una línea. Y el resultado es mejor que la hipótesis, porque
refuerza la paradoja de §14.4 en lugar de debilitarla:

> 🧠 **La compatibilidad hacia atrás es tan buena que el sistema sobrevivió
> cuatro saltos mayores sin que nadie mirara. La excelencia del proveedor es lo
> que permitió el abandono.**

⚠️ **Alcance de lo medido, y es contenido:** la prueba cubre el handshake y un
comando (`buildInfo`). **Si cada operación que la app usa se comporta igual tras
cuatro saltos, eso no lo sabe nadie — averiguarlo es el trabajo del alumno.**

### 17.6 Dónde aterriza el salto: 7.0, y lo decide el shell

```
mongo:4.0   "mongo": si   "mongosh": NO
mongo:6.0   "mongo": NO   "mongosh": si
mongo:7.0   "mongo": NO   "mongosh": si
```

El shell `mongo` desaparece en 6.0. **Todo runbook, script y
`docker exec … mongo --eval` escrito en 2019 se rompe en ese salto** — ticket
gratis y muy realista.

Como el driver aguanta hasta 8.0, el destino ya no lo decide la técnica sino la
narrativa: **`mongo:7.0`**, que está soportado (coherente con *"la
infraestructura tiene dueño"*) y queda por encima del corte del shell. Cadena
definitiva de LabCore: **4.0 (2019) → 4.4 → 6.0 → 7.0**.

### 17.7 Estado

Las dos pilas están construidas y probadas; los ficheros quedaron en el
scratchpad de la sesión. **No queda ningún ⚠️ bloqueante en ninguno de los dos
tracks.** Lo abierto ya es solo de redacción: la versión de Lumen que
corresponde a 2016–2018, el estado oficial de Lumen frente a Laravel + Octane, y
el 3001 suelto de angular-8.
MD
echo ok

# --- 2026-09-09T04:19:03 · Locate stale sections and Dart mentions
cd /Users/oskar/Developer/Learning/courses-ia-generated
grep -nE "^#{2,3} |Dart|Sinatra desplaza|Inclinación|Pregunta abierta|Preguntas abiertas" ideas_backend_cursos_angular.md | head -70

# --- 2026-09-09T04:19:15 · Read exact text at anchor points
cd /Users/oskar/Developer/Learning/courses-ia-generated
sed -n '1,12p;46,60p;145,150p;163,168p;258,300p;402,414p;574,580p' ideas_backend_cursos_angular.md

# --- 2026-09-09T04:20:23 · Update stale sections and add current-decisions block
cd /Users/oskar/Developer/Learning/courses-ia-generated
python3 - <<'PY'
import io,sys
p='ideas_backend_cursos_angular.md'
s=io.open(p,encoding='utf-8').read()
orig=s
def rep(old,new,label):
    global s
    if old not in s: print('  !! NO ENCONTRADO:',label); return
    if s.count(old)>1: print('  !! AMBIGUO:',label); return
    s=s.replace(old,new); print('  ok:',label)

# --- A. cabecera + bloque de decisiones vigentes -------------------------
rep("""> **Todo dato de versión, fecha o ecosistema marcado ⚠️ está sin verificar.**

---

## 1. 🧭 La bisagra""",
"""> **Última actualización:** 8 de septiembre de 2026, tras once rondas.
> **⚠️ = sin verificar.** Lo verificado lleva su medición y su fecha.

> 📖 **Cómo leer este documento.** Es un registro **incremental** de una
> conversación: las secciones están en el orden en que se pensaron, no en el
> orden en que se decidieron. **Las decisiones vigentes son las de §0.** Las
> secciones que quedaron atrás llevan un aviso `⛔ SUPERADO` con el puntero a la
> que las reemplazó; se conservan porque el razonamiento que las descartó es
> parte del valor.

---

## 0. 📌 Decisiones vigentes

**Lo que está decidido y medido. Todo lo demás del documento es el rastro de
cómo se llegó aquí.**

| | Angular 8 · **LabCore** | Angular 16 · **CertCore** |
|---|---|---|
| **El pecado** | Moda de **modelo de datos** | **Ausencia de revisión** |
| **El actor** | El equipo huyendo del DBA de Oracle | El converso a Laravel |
| **Cómo se decidió** | "Con Mongo el esquema lo movemos nosotros" (2019) | Nadie lo decidió: se eligió para *un servicio* y jamás se revisó |
| **Lenguaje** | **Java 8** (`eclipse-temurin:8-jdk`) | **PHP 7.4** (`php:7.4-cli`) |
| **Framework** | **Spring Boot 2.1** + `spring-data-mongodb`, Maven | **Lumen** |
| **Base de datos** | **`mongo:4.0`** standalone → sube a **7.0** | **`postgres:16.9`** |
| **Fallo insignia** | Integridad, historia, auditoría | Familiaridad falsa |
| **Entregable final** | Plan de contención medido | *Assessment* de riesgo con números |
| **Extra propio** | Riesgo de licencia (SSPL) como contenido | La reescritura que se quedó a medias |

**Comunes a los dos:** el backend es **la v1 del sistema**, más viejo que el
frontend (§10.3). El frontend **no se toca** (§5). Puerto **3000**. Arranque con
`docker compose up -d` y cuatro comandos en el README (§17.1). La versión de la
base vive en `.env`, fuera del código (§17.4). La asimetría *"a la
infraestructura la actualizan, a la aplicación no"* gobierna las dos historias
(§13.3, §14).

**Descartados, con su razón** (§8, §9, §10, §11, §12):

| Candidato | Por qué no | Dónde quedó |
|---|---|---|
| **Dart + Conduit** | El fallo es solo de RRHH: produce vacantes, no bugs | Suplente: mejor caso de *escasez de gente* |
| **Ruby + Sinatra** | Coste de laboratorio y solapamiento con `docker-container-legacy` | Suplente: mejor caso de *deuda de autor* |
| **Scala + Play + Akka** | Mejor historia, peor laboratorio (coste **por iteración**) | Su lección —el riesgo de licencia— se muda a LabCore |
| **Symfony / Rails** | Sanos y con disciplina de upgrade: no sostienen ocho fases | **Grupo de control** y destino del árbol de veredicto |
| **LoopBack 3 / RethinkDB** | Boom tibio; RethinkDB compite en el eje de datos | Apéndice, si acaso |
| **Cassandra** | Modelo de acceso equivocado para LabCore | 🔴 Ejercicio adversarial + apéndice honesto (§3.4) |

**Verificado con fecha** (§15, §16, §17): todo arm64 nativo, **sin emulación** —
`php:7.4` → PG 16.9 con SCRAM; `mongo:4.0` standalone rechazando transacciones
con su mensaje literal; `temurin:8-jdk`; driver Java 3.8.2 conectando hasta
Mongo 8.0; y la caducidad del LTS de Debian 11 capturada el día que ocurrió.

---

## 1. 🧭 La bisagra""","§0 decisiones vigentes")

# --- B. tabla de §2 ------------------------------------------------------
rep("""| **La tecnología** | MongoDB como store primario | Dart en el backend, partido en servicios |
| **La factura** | Técnica: integridad, historia, auditoría | Organizacional: nadie sabe Dart, bus factor 1 |""",
"""| **La tecnología** | MongoDB como store primario | ~~Dart~~ → **PHP 7.4 + Lumen** (§12) |
| **La factura** | Técnica: integridad, historia, auditoría | Organizacional: rotación, formación que se va, familiaridad falsa |""",
"§2 tabla")

rep("""propuesta es repartir **dos clases distintas de deuda**:""",
"""propuesta es repartir **dos clases distintas de deuda**:

> ⚠️ **La columna de CertCore cambió de tecnología** —Dart fue el primer
> candidato y perdió en §8.6 y §12— **pero el eje de esta tabla se mantuvo
> intacto**: sigue siendo *"moda de datos"* contra *"moda de lenguaje y
> arquitectura"*. Ver §0.""","§2 aviso")

# --- C. §3.5 -------------------------------------------------------------
rep("""### 3.5 Pregunta abierta: ¿en qué lenguaje?""",
"""### 3.5 ✅ Pregunta cerrada: ¿en qué lenguaje?

> **Resuelta en §16.4: Java 8 + Spring Boot 2.1 + `spring-data-mongodb`**, por el
> efecto que se argumenta abajo. WildFly/JEE se evaluó y se descartó; su papel
> quedó en la historia del equipo, no en el stack.""","§3.5 cerrada")

# --- D. §4 banner --------------------------------------------------------
rep("""## 4. 🎯 Angular 16 · CertCore — "Dart, porque el equipo era de Flutter"

### 4.1 La historia, que es la mejor de las dos""",
"""## 4. 🎯 Angular 16 · CertCore — "Dart, porque el equipo era de Flutter"

> ⛔ **SUPERADO — Dart no es el stack de CertCore.** Fue el primer candidato y
> perdió: en §8.6 frente a Lumen, en §10.4 frente a Sinatra, y definitivamente
> en §12 y §16.3 → **PHP 7.4 + Lumen + PostgreSQL 16**.
>
> **Se conserva entero porque tres piezas de esta sección sobrevivieron al
> cambio de tecnología y siguen vigentes:** el análisis de la *deuda de
> ecosistema* (§4.2), el **assessment de riesgo de cuatro opciones** como
> entregable final (§4.3) —que es el cierre de CertCore, sea cual sea el
> lenguaje— y la regla de que *la respuesta correcta depende de la fecha de
> decomisión, no de la calidad del código*.
>
> Dart queda como **suplente**: el mejor caso de *escasez de gente* pura, si
> algún día hay un tercer track.

### 4.1 La historia, que es la mejor de las dos""","§4 banner")

# --- E. §6 riesgos -------------------------------------------------------
rep("""- **Que se conviertan en "curso de Mongo" y "curso de Dart".** Es el riesgo""",
"""- **Que se conviertan en "curso de Mongo" y "curso de Lumen".** Es el riesgo""","§6 riesgo 1")
rep("""- **Enseñar Dart a gente que no lo va a usar.** Es real y hay que aceptarlo de
  frente: el track no vende Dart, vende el **método** para evaluar una
  tecnología que se volvió un pasivo. Dart es el caso de estudio. Convendría
  decirlo en el README con esas palabras.""",
"""- **Enseñar una tecnología que el alumno no va a usar.** Valía para Dart y sigue
  valiendo para Lumen, aunque menos: PHP al menos es transferible. Hay que
  aceptarlo de frente — el track no vende Lumen, vende el **método** para
  diagnosticar un sistema cuya tecnología se volvió un pasivo. Conviene decirlo
  en el README con esas palabras.""","§6 riesgo 2")
rep("""- **Verificación.** Casi todo lo de §4.2 está sin comprobar. Antes de escribir
  hace falta la línea de tiempo real de Aqueduct/Conduit, las versiones de Dart
  y el estado de `dart:mirrors`, con fuentes. Igual con las transacciones de
  Mongo 4.0 y los requisitos de replica set.""",
"""- **Verificación.** ✅ Resuelto para el stack elegido: §15, §16 y §17 traen las
  mediciones con fecha, incluida la de las transacciones de Mongo 4.0 en
  standalone. Lo de Aqueduct/Conduit quedó sin comprobar y ya no hace falta,
  porque Dart no es el candidato.""","§6 verificación")

# --- F. §7 preguntas -----------------------------------------------------
rep("""## 7. ❓ Preguntas abiertas

1. **¿Java/Spring o Node para el backend de LabCore?** (§3.5) Inclinación:
   Java, por el efecto "parecía JPA".""",
"""## 7. ❓ Preguntas abiertas — **estado tras once rondas**

1. ✅ **¿Java/Spring o Node para LabCore?** **Java 8 + Spring Boot 2.1** (§16.4).""","§7 p1")
rep("""3. **¿Cuántas fases?** React usa diez. Aquí probablemente **ocho** basten, con
   la última siendo el documento de decisión y no código.
4. **¿Un curso o dos tracks?** Ambos van dentro de su curso, como el de React
   — pero el de Dart tiene identidad propia suficiente como para plantearse si
   no es en realidad un curso corto aparte sobre deuda de ecosistema.
5. **¿Hace falta `BENCHMARKS.md` en estos tracks?** Sí para LabCore (hay qué
   medir). Para CertCore lo que hay que medir son horas y dinero, no latencia —
   quizá el documento se llame distinto.""",
"""3. 🟡 **¿Cuántas fases?** React usa diez. Aquí probablemente **ocho**, con la
   última siendo el documento de decisión y no código. LabCore suma la fase del
   upgrade forzado (§16.5).
4. ✅ **¿Un curso o dos tracks?** Dos tracks, cada uno dentro de su curso, como
   el de React.
5. 🟡 **¿Hace falta `BENCHMARKS.md`?** Sí para LabCore (hay qué medir). Para
   CertCore lo que se mide son horas y dinero, no latencia — quizá se llame
   distinto.
6. 🔴 **Abierto de verdad:** la versión de Lumen que corresponde a 2016–2018 y en
   qué PHP dejó de arrancar; el estado oficial de Lumen frente a Laravel +
   Octane; y el `3001` suelto de angular-8 (§17).""","§7 p3-5")

# --- G. §8.6 -------------------------------------------------------------
rep("""### 8.6 La recomendación de esta ronda

**Lumen desplaza a Dart""",
"""### 8.6 La recomendación de esta ronda

> 📌 **Vigente en su conclusión, tras un rodeo.** Sinatra la revocó en §10.4 y
> §12 la restableció con más argumentos. El veredicto final es el de §0.

**Lumen desplaza a Dart""","§8.6 nota")

# --- H. §10.4 ------------------------------------------------------------
rep("""### 10.4 Veredicto: Sinatra desplaza a Lumen

Cambio la recomendación de §8.6""",
"""### 10.4 ⛔ SUPERADO — Veredicto: Sinatra desplaza a Lumen

> **Revocado en §12.** Sinatra cayó por coste de laboratorio y por solapamiento
> con `docker-container-legacy`; y §12.3 corrige el error de fondo de esta
> sección, que subestimaba el rendimiento forense de Lumen. **El criterio que se
> enuncia aquí —coste de iteración, no de arranque— sí quedó vigente** y es el
> que decidió también contra WildFly en §16.4.

Cambio la recomendación de §8.6""","§10.4 banner")

# --- I. §16.6 ------------------------------------------------------------
rep("""### 16.6 El único ⚠️ que queda, y decide contenido""",
"""### 16.6 ⛔ SUPERADO — El único ⚠️ que queda, y decide contenido

> **Medido en §17.5 y la hipótesis salió falsa:** el driver Java de 2019 conecta
> hasta Mongo 8.0, así que **no hubo bump de `pom.xml`**. Nadie tocó la
> aplicación, nunca. El resultado es mejor que la hipótesis — ver §17.5.""","§16.6 banner")

io.open(p,'w',encoding='utf-8').write(s)
print('\nbytes: %d -> %d' % (len(orig),len(s)))
PY

# --- 2026-09-09T04:20:35 · Mark remaining open question and audit Dart mentions
cd /Users/oskar/Developer/Learning/courses-ia-generated
python3 - <<'PY'
import io
p='ideas_backend_cursos_angular.md'
s=io.open(p,encoding='utf-8').read()
old="""2. **¿El alumno construye el backend malo, o se le entrega hecho?**"""
new="""2. 🔴 **¿El alumno construye el backend malo, o se le entrega hecho?**"""
assert s.count(old)==1
io.open(p,'w',encoding='utf-8').write(s.replace(old,new))
print("ok: §7 p2 marcada")
PY
echo "=== menciones de Dart que quedan, con contexto ==="
grep -n "Dart" ideas_backend_cursos_angular.md | sed 's/^/  /'

# --- 2026-09-09T04:20:51 · Verify updated document head and section index
cd /Users/oskar/Developer/Learning/courses-ia-generated
sed -n '1,30p' ideas_backend_cursos_angular.md
echo "..."
echo "=== índice completo ==="
grep -nE "^## " ideas_backend_cursos_angular.md | sed 's/^/  /'

# --- 2026-09-09T04:21:11 · Fix section titles and save project memory
cd /Users/oskar/Developer/Learning/courses-ia-generated
python3 - <<'PY'
import io
p='ideas_backend_cursos_angular.md'; s=io.open(p,encoding='utf-8').read()
for old,new in [
 ('## 4. 🎯 Angular 16 · CertCore — "Dart, porque el equipo era de Flutter"',
  '## 4. ⛔ CertCore con Dart — SUPERADO (se conserva por §4.2 y §4.3)'),
 ('## 10. 🎭 Cuarta ronda: el actor, y por qué Ruby/Sinatra gana',
  '## 10. 🎭 Cuarta ronda: el actor — y Ruby/Sinatra, que ganó y luego perdió'),
 ('## 8. 🎰 Alternativas a Dart: las cinco formas de que un boom pase factura',
  '## 8. 🎰 Los seis actores: las formas de que un boom pase factura'),
]:
    assert s.count(old)==1, old
    s=s.replace(old,new)
io.open(p,'w',encoding='utf-8').write(s); print('titulos corregidos')
PY
M=/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory
cat > $M/tracks-be-angular-decisiones.md <<'EOF'
---
name: tracks-be-angular-decisiones
description: Decisiones cerradas de los tracks de backend para angular-8 (LabCore) y angular-16 (CertCore), en un documento sin versionar.
metadata:
  type: project
---

Los tracks BE de los dos cursos de Angular se diseñaron el 8/09/2026 y las
decisiones viven en `ideas_backend_cursos_angular.md` (raíz del repo,
**sin versionar** — se puede perder). §0 del documento trae el resumen vigente;
el resto es el rastro de la deliberación, con avisos `⛔ SUPERADO`.

- **LabCore (angular-8):** Mongo 4.0 standalone + Java 8 + Spring Boot 2.1.
  Pecado: moda de modelo de datos.
- **CertCore (angular-16):** PHP 7.4 + Lumen + PostgreSQL 16.9. Pecado:
  ausencia de revisión. **Dart, Sinatra, Akka y Symfony se evaluaron y se
  descartaron** — si vuelve a salir el tema, la razón de cada descarte ya está
  escrita.

A diferencia del track BE de React —que es una redención, ver
[[track-be-react16-escrito]]— estos dos son "el backend es la escena del
crimen": administrar un error de arquitectura ajeno sin migrar.
EOF
echo "- [Decisiones de los tracks BE de Angular](tracks-be-angular-decisiones.md) — LabCore=Mongo+Java, CertCore=Lumen+Postgres; el documento no está versionado." >> $M/MEMORY.md
echo "memoria guardada"

