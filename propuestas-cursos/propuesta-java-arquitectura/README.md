# 🏛️ Propuesta: arquitectura de software para desarrolladores Java senior

Propuesta de un curso que **no enseña Java**. Toma a alguien que lleva años
escribiendo Spring Boot y lo entrena en lo que separa a un senior de un arquitecto:
**decidir dónde van las fronteras de un sistema, defender esa decisión con datos, y
saber cuándo la respuesta correcta es no separar nada.**

> ⚠️ Borrador. Ver el [README del directorio de propuestas](../README.md) para
> entender qué implica ese estado. Hay decisiones abiertas al final de este
> documento que conviene cerrar antes de escribir una sola fase.

---

## 🎯 En una frase

Un curso donde un desarrollador Java senior aprende arquitectura **moviendo
fronteras en un sistema que ya existe** —el mismo juguete de supermercados del
[laboratorio de contenedores](../propuesta-lab-docker/)— y midiendo lo que cada
movimiento cuesta, hasta poder sentarse frente a un comité y defender una decisión
de arquitectura con números en vez de con convicciones.

---

## 🧩 El problema que resuelve

Un senior de Java con ocho o diez años sabe escribir un servicio. Lo que no ha
tenido casi nunca es **la oportunidad de decidir**, y menos aún la de equivocarse
barato. Las decisiones de arquitectura llegan hechas: alguien ya eligió
microservicios, alguien ya puso el `@Transactional` ahí, alguien ya decidió que
esos dos módulos eran dos repositorios.

Eso produce un perfil muy concreto y muy común: alguien que **implementa
arquitecturas sin haberlas diseñado**, y que en una entrevista de arquitecto
responde con patrones en vez de con criterios. *"Usaría una saga"* es una respuesta
de libro; *"depende de si el paso compensable puede fallar después de confirmado, y
en ese caso el coste de la compensación es X"* es una respuesta de arquitecto.

Este curso ataca tres huecos concretos:

**Primero: la frontera como decisión, no como herencia.** La mayor parte del dolor
arquitectónico de un sistema real viene de una frontera puesta en el sitio
equivocado —entre módulos, entre transacciones, entre servicios, entre equipos—.
Y casi nadie ha tenido que ponerlas.

**Segundo: el coste, medido.** Separar un servicio cuesta latencia, consistencia,
operación y dinero. La mayoría de los cursos de microservicios enseñan los patrones
y no el precio. Aquí cada frontera que se mueve se mide antes y después.

**Tercero: el entregable del arquitecto.** No es código: es una **decisión
documentada y defendida**. ADRs, un modelo C4, un análisis de compromisos, una
función de aptitud que impide que la arquitectura se degrade sola. El curso produce
esos artefactos porque son los que se enseñan en una entrevista y los que se usan en
el trabajo.

---

## 🧭 El eje que ordena el curso

Igual que el curso de Go gira alrededor de *"¿qué modelo de acceso tiene mi
dominio?"*, este gira alrededor de una sola pregunta:

> 🧭 **¿Dónde va esta frontera, y qué cuesta moverla después?**

Porque casi todo lo que se llama "arquitectura" es eso:

| La pregunta de siempre | Es una frontera entre… |
|---|---|
| ¿Monolito modular o microservicios? | módulos desplegables |
| ¿Dónde termina esta transacción? | unidades de consistencia |
| ¿Esto es un agregado o dos? | invariantes que se sostienen juntos |
| ¿REST, gRPC o eventos? | contratos, y su acoplamiento temporal |
| ¿Saga orquestada o coreografiada? | quién conoce el proceso completo |
| ¿Este equipo o el otro? | responsabilidad, y Conway te la impone igual |
| ¿Qué falla cuando esto falla? | dominios de fallo |

Y de ahí sale la segunda pregunta, que es la que el curso persigue fase tras fase:

> ☕ **¿Esta separación existe porque el sistema la necesita, o porque así se
> dibujan los diagramas?**

---

## 🔗 Cómo va de la mano con el laboratorio de contenedores

**Comparten dominio, servicios y repositorio.** El juguete es el mismo:
`super-inventory-lab`, con `catalog` (Go), `inventory` (Spring Boot),
`replenish` (Node) y `web-inventory` (MicroProfile).

La costura entre los dos, en una línea:

> 🧭 **El laboratorio enseña a operar el sistema. El curso enseña a decidir cómo
> debería ser el sistema.**

El detalle completo —quién se queda cada tema, qué depende de qué y en qué orden se
recorren— está en [`01-encaje-con-lab-docker.md`](01-encaje-con-lab-docker.md), que
es la pieza más importante de esta propuesta y la que hay que revisar primero.

Lo esencial: el laboratorio deja un sistema **funcionando y observable**, con
fronteras ya dibujadas y **al menos un defecto sembrado a propósito** —el
fire-and-forget entre `inventory` y `replenish`, que el propio plan maestro declara
como "la motivación real del Anillo 4"—. El curso llega, lo audita, y empieza a
mover fronteras midiendo el efecto en las métricas que el laboratorio ya expone.

Sin el laboratorio, el curso tendría que construir su propia infraestructura y se
volvería otro curso de microservicios. Con él, **puede dedicarse entero a las
decisiones**, que es lo que lo hace distinto.

---

## 👥 Público objetivo

Desarrollador **Java senior, 8+ años**, backend, con Spring Boot en producción.
Da por sabido: OOP, Spring, JPA/Hibernate, SQL, REST, pruebas, Maven/Gradle, Git, y
contenedores a nivel de uso.

**No** da por sabido: diseño estratégico de dominios, análisis de compromisos con
datos, escritura de ADRs, evaluación de arquitecturas, ni el coste real de una
frontera distribuida.

**Nunca se explica** qué es una interfaz, una transacción, un índice o una prueba
unitaria. Sí se explica —siempre— **por qué la decisión que parece obvia tiene un
precio que nadie te contó.**

---

## 📐 La regla que gobierna el material

La misma del curso de Go, y aquí muerde más:

> **Ninguna afirmación de arquitectura se escribe sin su medición.**

Vale también —y sobre todo— para las que suenan a verdad revelada:

- *"Los microservicios escalan mejor"* → ¿cuál, en qué eje, y a partir de qué carga?
- *"Las sagas resuelven la consistencia distribuida"* → ¿con qué ventana de
  inconsistencia, y qué pasa si la compensación falla?
- *"Los eventos desacoplan"* → ¿desacoplan qué exactamente, y qué acoplan a cambio?
- *"Reactivo es más eficiente"* → medido contra hebras virtuales de Java 21, en la
  misma máquina y con la JVM calentada.

Cada una de esas frases se convierte en un experimento con hipótesis falsable, y
el resultado se publica **aunque contradiga al curso**.

---

## 🎓 Lo que el curso produce

El entregable de un arquitecto no es código, así que el curso produce documentos —
y los produce **desde la primera semana**, no al final. Estos son los que se
enseñan en una entrevista:

| Artefacto | Qué demuestra |
|---|---|
| Una colección de **ADRs** con su contexto, opciones y consecuencias | Que decides y documentas, no que opinas |
| El **modelo C4** del sistema, en los cuatro niveles | Que sabes comunicar arquitectura a cuatro audiencias distintas |
| Un **mapa de contextos** con los patrones de relación | Diseño estratégico, no solo táctico |
| Las **funciones de aptitud** en CI | Que la arquitectura se defiende sola, sin depender de la revisión humana |
| El **análisis de compromisos** de la decisión central, con números | Lo que de verdad separa a un arquitecto de un senior |
| El **plan de migración** con sus pasos reversibles | Que sabes llevar un sistema de A a B sin parar el negocio |
| El **veredicto honesto**: cuándo NO separar | Criterio por encima de entusiasmo |

---

## 🚫 Fuera de alcance

- **Java y Spring como temario.** No se enseña el lenguaje ni el framework; se
  asumen. Lo que sí se explica es **qué hace Spring por debajo** cuando eso cambia
  una decisión de arquitectura.
- **Infraestructura y operación.** Es del [laboratorio](../propuesta-lab-docker/).
  Este curso no enseña Kubernetes, Helm ni certificados; los usa.
- **Frontend y experiencia de usuario.**
- **Arquitectura empresarial**, TOGAF, gobierno, y todo lo que va más allá del
  sistema.
- **Cloud gestionado y coste real de proveedor.** Se estima y se declara como
  estimación.
- **Certificaciones.** Ni AWS, ni Azure, ni iSAQB.

---

## 🔀 Relación con el curso de Go

Son complementarios y **no se solapan**, aunque compartan filosofía:

| | Go para Java senior | Este curso |
|---|---|---|
| Enseña | un lenguaje, por contraste | a decidir |
| El instrumento | Go | Java 21/25 + Spring Boot 3 |
| La pregunta central | ¿qué modelo de acceso tiene mi dominio? | ¿dónde va esta frontera? |
| El entregable | servicios que funcionan | decisiones defendidas |
| El veredicto final | cuándo NO usar Go | cuándo NO separar |

Y hay un puente real: el `catalog` del juguete está escrito en Go. Un lector que
haya hecho los dos cursos puede **evaluar una decisión políglota con criterio en
los dos lenguajes**, que es exactamente la situación de la mayoría de las
plataformas modernas.

Orden sugerido si se hacen los tres: **laboratorio → arquitectura → Go**, o
**laboratorio → Go → arquitectura**. El laboratorio va primero en los dos casos,
porque los otros dos se apoyan en que el sistema exista y se pueda observar.

---

## ❓ Decisiones abiertas

Lo que hay que cerrar antes de escribir la primera fase. No las resuelvo por mi
cuenta porque cambian el curso entero.

**1. ¿Comparte repositorio con el laboratorio, o solo dominio?**
Compartir repositorio da el máximo aprovechamiento y acopla los dos calendarios: el
curso no puede avanzar más rápido que el laboratorio. Compartir solo el dominio
—con un repositorio propio que parte de un `super-inventory` ya montado— desacopla,
a costa de duplicar infraestructura.
*Recomendación: repositorio compartido, con el curso trabajando sobre ramas.*

**2. ¿Quién se queda las sagas, gRPC y los eventos?**
Están en los Anillos 2, 3 y 4 del laboratorio **y** son material de arquitectura de
primera. La propuesta de reparto está en el documento de encaje; hay que validarla.

**3. ¿Java 21 o Java 25?**
El laboratorio arranca en 17 y migra a 25 en su Anillo 5. El curso podría arrancar
directamente en 21 —el LTS con hebras virtuales, que es lo que se pregunta hoy— o
seguir el calendario del laboratorio.
*Recomendación: 21 como base, con la migración a 25 como fase propia.*

**4. ¿Qué extensión?**
Dos tamaños posibles, y la elección depende de si esto se estudia con prisa:
- **Completo:** 16 fases, ~120 h, cuatro meses a 2 h/día.
- **Intensivo:** 10 fases, ~70 h, con los artefactos de entrevista concentrados en
  las cinco primeras semanas y el resto opcional.

**5. ¿Cuánto Spring Boot se puede dar por sabido?**
Si el lector lleva años en Spring Boot 2 y el curso va en 3.x, hay un salto real
—observabilidad con Micrometer, AOT, Jakarta— que o se cubre o se declara como
requisito previo.

---

## 📁 Contenido previsto del directorio

| Documento | Estado |
|---|---|
| `README.md` | este |
| [`01-encaje-con-lab-docker.md`](01-encaje-con-lab-docker.md) | **la costura entre los dos, tema por tema** |
| [`02-mapa-de-fases.md`](02-mapa-de-fases.md) | fases tentativas, con su decisión central y su artefacto |
| `03-guia-de-estilo.md` | pendiente, si la propuesta se promueve |
| `04-formato-de-adr.md` | pendiente |
