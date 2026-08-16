# 📎 Apéndice bea-10 — Riesgo de licencia: SSPL y compañía

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Consulta rápida · **3 horas**
> Usado por: be07, be08 (árbol de veredicto) · Versiones cubiertas: no aplica — es un apéndice de contexto y de decisión

**Esto no se lee de corrido.** Se entra cuando alguien pregunta *"¿esto lo podemos usar?"* o cuando una noticia dice que un producto que llevas años usando cambió de licencia, y se sale sabiendo qué mirar y a quién escalarlo.

Resuelve una cosa: **enseñar a leer una licencia *antes* de elegir un producto, y a reconocer una deuda técnica que ningún refactor arregla.**

> 🧭 **La lección que no da ninguna otra pieza del track: tu deuda técnica la puede crear un abogado.** Ni una línea de tu código cambia, ni una versión de tu `pom.xml` se mueve, y las condiciones bajo las que puedes usar tu base de datos son distintas de las que había cuando se eligió. Es el mismo mecanismo de `be07` —un cambio con efecto y sin commit— llevado a su forma más pura.

**Qué queda fuera, y va dicho aquí y repetido al final: asesoría legal.** Este apéndice enseña a **detectar** el riesgo y a **escalarlo**, no a resolverlo. Ninguna frase de esta página es un dictamen sobre si tu empresa puede o no puede hacer algo; eso lo dice quien tenga la responsabilidad de decirlo, con el contrato delante.

---

## Índice

- [1. Las tres familias, en un minuto](#1-las-tres-familias-en-un-minuto)
- [2. El caso MongoDB: SSPL, 2018](#2-el-caso-mongodb-sspl-2018)
- [3. Qué significa para LabCore, en concreto](#3-qué-significa-para-labcore-en-concreto)
- [4. El caso Elasticsearch: ida y vuelta](#4-el-caso-elasticsearch-ida-y-vuelta)
- [5. El caso Akka: el más espectacular](#5-el-caso-akka-el-más-espectacular)
- [6. El caso Redis: la bifurcación que funcionó](#6-el-caso-redis-la-bifurcación-que-funcionó)
- [7. Cómo se lee la licencia de una dependencia](#7-cómo-se-lee-la-licencia-de-una-dependencia)
- [8. Las seis preguntas antes de adoptar](#8-las-seis-preguntas-antes-de-adoptar)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-6)

---

## 1. Las tres familias, en un minuto

| Familia | Qué te pide | Ejemplos |
|---|---|---|
| **Permisiva** | Que conserves el aviso de copyright. Poco más | Apache 2.0, MIT, BSD |
| **Copyleft** | Que publiques tus cambios bajo la misma licencia. La AGPL extiende eso al uso **en red** | GPL, LGPL, **AGPL** |
| **Source-available** | Ver el código sí; usarlo en producción o como servicio, **con condiciones** | **SSPL**, **BSL**, Elastic License |

La tercera no es *open source* según la definición de la Open Source Initiative, y esa distinción —que suena a discusión de terminología— tiene una consecuencia muy práctica: **muchas políticas corporativas y muchos catálogos de dependencias están escritos como "solo licencias aprobadas por la OSI"**. Un producto que sale de esa lista se convierte en un problema administrativo aunque técnicamente no cambie nada.

> 💡 **Y el detalle que hay que interiorizar:** una licencia no es una propiedad estable del producto. **Es una decisión de la empresa que lo publica, y se puede cambiar en cualquier versión nueva.** Lo que ya descargaste conserva la licencia que tenía; lo que descargues mañana, la que tenga mañana.

---

## 2. El caso MongoDB: SSPL, 2018

Los hechos, con fecha y fuente:

- El **16 de octubre de 2018**, MongoDB, Inc. anunció la **Server Side Public License (SSPL)** para MongoDB Community Server, en sustitución de la AGPLv3. La versión 1 de la licencia lleva esa misma fecha ([nota de prensa](https://www.mongodb.com/company/newsroom/press-releases/mongodb-issues-new-server-side-public-license-for-mongodb-community-server)).
- **Todas las versiones publicadas a partir de esa fecha** están bajo SSPL, incluidos los parches de líneas anteriores. En la línea 4.0, eso significa que **`4.0.3` es anterior y `4.0.4` (noviembre de 2018) ya es SSPL**.
- Debian, Red Hat Enterprise Linux y Fedora retiraron MongoDB de sus repositorios a raíz del cambio.
- La OSI **no** ha aprobado la SSPL como licencia de código abierto.

Lo que la SSPL añade respecto de la AGPL, en una frase: si **ofreces el programa como servicio a terceros**, tienes que publicar bajo la misma licencia el código de **todo lo que haga funcionar ese servicio** —herramientas de gestión, interfaces, orquestación, copias de seguridad—. Está escrito para el caso concreto de un proveedor de nube que revende la base como producto gestionado.

> ⚠️ **LabCore corre `mongo:4.0`, cuyo último parche es `4.0.28`. O sea: la base de datos que Laboratorios Andina desplegó en 2019 ya estaba bajo SSPL, y nadie lo comprobó** — ni en el despliegue inicial, ni en ninguno de los cuatro escalones de `be07`.

---

## 3. Qué significa para LabCore, en concreto

Y aquí hay que ser directo, porque la tentación de este apéndice es fabricar alarma y sería un error:

> 🧭 **Para una empresa que solo *usa* el producto —que es el caso de Laboratorios Andina— la respuesta corta es: casi nada.**

LabCore no ofrece MongoDB como servicio a terceros. Lo usa internamente, para su propio sistema, dentro de su propia operación. La cláusula que hace especial a la SSPL **no se activa** en ese escenario. No hay obligación de publicar nada, no hay que pagar nada, y no hay nada que arreglar.

Lo que sí cambia, y es lo que hay que anotar en `IRRECOVERABLE.md`:

| Consecuencia real | Por qué |
|---|---|
| **No se instala desde los repositorios de la distribución** | Debian y RHEL lo retiraron. Hay que usar el repositorio del fabricante o un contenedor — que es lo que LabCore hace |
| **Puede chocar con una política interna** | "Solo licencias aprobadas por la OSI" es una regla habitual en empresas medianas y grandes, y la SSPL no lo está |
| **Condiciona qué se puede hacer si algún día se ofrece como servicio** | Hoy no aplica. Si Laboratorios Andina vendiera LabCore a otros laboratorios, **la conversación cambia** y hay que tenerla antes, no después |
| **Y afecta a quién puede hospedarla** | Es el motivo por el que existen las alternativas gestionadas que existen y no otras |

> 🧠 **Lo interesante no es el riesgo, que es bajo. Es que nadie lo comprobó nunca, en siete años y cinco decisiones de despliegue.** La comprobación cuesta diez minutos y no se hizo ni una vez, y eso sí es un hallazgo: no sobre la licencia, sino sobre el proceso.

---

## 4. El caso Elasticsearch: ida y vuelta

Porque estos cambios no siempre van en una sola dirección, y conviene saberlo antes de tomar decisiones irreversibles.

- **14 de enero de 2021** — Elastic anunció que Elasticsearch y Kibana pasaban de Apache 2.0 a doble licencia **SSPL + Elastic License**, a partir de la versión **7.11**. Dejaron de estar bajo una licencia aprobada por la OSI.
- La reacción fue inmediata y grande: AWS bifurcó el proyecto y nació **OpenSearch**.
- **Septiembre de 2024** — Elastic añadió **AGPLv3** como opción, junto a las otras dos. Elasticsearch y Kibana vuelven a tener una opción aprobada por la OSI.

> 🧠 **Tres años y ocho meses de ida y vuelta.** Lo que hay que llevarse no es "al final salió bien": es que **durante esos tres años y medio hubo equipos que migraron a OpenSearch pagando el coste completo de la migración**, y esa decisión, tomada con la información de 2021, era razonable. Volver atrás cuesta otra migración.
>
> La lección práctica: ante un cambio de licencia, **la primera reacción correcta casi nunca es migrar**. Es determinar si te afecta —normalmente no—, documentarlo, y poner una fecha de revisión.

---

## 5. El caso Akka: el más espectacular

Es el que mejor ilustra la idea, porque el efecto fue inmediato y sobre el coste, no sobre la conformidad.

- **7 de septiembre de 2022** — Lightbend anunció que todos los módulos de Akka pasaban de **Apache 2.0** a la **Business Source License (BSL) v1.1**, a partir de Akka **2.7**, publicada en octubre de 2022.
- El modelo: las organizaciones con menos de **25 millones de dólares** de facturación anual no pagan licencia por el uso en producción, pero necesitan una licencia comercial de 0 dólares otorgada por Lightbend. Por encima de esa cifra, **licencia de pago más suscripción**.
- La BSL tiene **fecha de reversión**: cada versión publicada bajo BSL vuelve a Apache 2.0 **tres años después**.
- La comunidad bifurcó el proyecto: nació **Apache Pekko**, cuya versión 1.0.0 se publicó en julio de 2023.

> 🧠 **De un día para otro, seguir actualizando costaba dinero.** No "podría costar", no "en un escenario hipotético": una empresa por encima del umbral que quisiera el siguiente parche de seguridad de Akka tenía que firmar un contrato. Eso no aparece en ningún `pom.xml`, no lo detecta ningún análisis estático, y no lo ve venir ninguna revisión de código.
>
> Y lo que lo hace formativo: **quien eligió Akka en 2019 eligió bien**. Era Apache 2.0, un proyecto maduro, con una comunidad enorme. No hay ninguna debida diligencia técnica que hubiera anticipado esto.

---

## 6. El caso Redis: la bifurcación que funcionó

El más reciente, y el que muestra el ciclo completo.

- **Marzo de 2024** — Redis pasó de BSD-3-Clause a doble licencia **RSALv2 + SSPLv1**.
- **Abril de 2024** — la Linux Foundation lanzó **Valkey**, una bifurcación de Redis 7.2.4 bajo BSD, con el apoyo de AWS, Google Cloud y Oracle. Se consolidó en semanas.
- **Mayo de 2025** — con Redis 8, Redis añadió **AGPLv3** como tercera opción, junto a RSALv2 y SSPLv1.

> 💡 **Los tres casos —Elasticsearch, Akka y Redis— tienen la misma forma:** cambio restrictivo → bifurcación de la comunidad → en dos de los tres, marcha atrás parcial. Reconocer esa forma es lo que permite no entrar en pánico la próxima vez, y también lo que permite ver que **la bifurcación no siempre llega a tiempo ni siempre se consolida**.

---

## 7. Cómo se lee la licencia de una dependencia

La parte práctica, y en Maven es cómoda porque el `pom.xml` de cada artefacto la declara.

```bash
# El informe de licencias de todo tu árbol de dependencias, transitivas
# incluidas. Es la herramienta que resuelve el 90 % de la pregunta.
docker compose run --rm api mvn -f server/pom.xml \
  license:add-third-party -Dlicense.excludedScopes=test

# El resultado queda en:
#   server/target/generated-sources/license/THIRD-PARTY.txt
```

Y para la base de datos y el resto de la pila, que no pasan por Maven:

```bash
# La licencia va dentro de la propia imagen. Míralo ahí, no en internet:
# lo que importa es la licencia de LA VERSIÓN QUE CORRES, no la del proyecto.
docker compose exec db cat /LICENSE | head -20
docker compose exec db ls /licenses 2>/dev/null
```

Los cuatro sitios donde mirar, en orden:

1. **El artefacto que corres.** El archivo `LICENSE` dentro del `.jar` o de la imagen. Es la fuente primaria y la única que corresponde a **tu** versión.
2. **El `pom.xml` del artefacto**, que declara `<licenses>`. Cómodo, y a veces desactualizado.
3. **El repositorio del proyecto**, que tiene la licencia **de hoy** — que puede no ser la tuya.
4. **La página legal del fabricante**, que es donde se anuncian los cambios y donde están las FAQ.

> ⚠️ **El orden importa, y el error clásico es empezar por el 3.** El repositorio te dice bajo qué licencia está el código **actual**. Tú corres una versión de 2019 que puede tener otra — y al revés: puedes estar corriendo una versión nueva bajo una licencia que cambió sin que nadie del equipo lo notara, que es exactamente el caso de LabCore.

---

## 8. Las seis preguntas antes de adoptar

Lo que un equipo se pregunta **antes** de meter algo en el `pom.xml`, y que en 2019 nadie se preguntó:

1. **¿Bajo qué licencia está la versión concreta que voy a usar?** No el proyecto: la versión.
2. **¿Está aprobada por la OSI?** Y si no, **¿mi empresa tiene una política sobre eso?**
3. **¿Qué obligaciones me impone en mi escenario real?** Uso interno, distribución del producto y ofrecerlo como servicio son tres escenarios con tres respuestas distintas.
4. **¿Quién sostiene el proyecto?** Una empresa con inversores tiene incentivos para cambiar la licencia; una fundación, muchos menos.
5. **¿Qué pasa si mañana cambia?** ¿Hay bifurcación probable, alternativa compatible, o quedaría atrapado?
6. **¿Cuándo se vuelve a revisar esto?** Porque la respuesta de hoy caduca.

> 🧭 **La sexta es la única que no se hace nunca, y es la que falló en LabCore.** Las cinco primeras se contestan en una tarde al adoptar algo. La sexta exige un recordatorio en un calendario, y sin ella todo el trabajo de las otras cinco tiene fecha de caducidad silenciosa. **Comprobar la licencia de tus dependencias es una tarea recurrente, no una tarea de alta.**

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer |
|---|---|
| Vas a adoptar algo nuevo | Las seis preguntas del §8, antes de escribirlo en el `pom.xml` |
| Una noticia dice que X cambió de licencia | **No migres.** Determina si te afecta. Casi nunca te afecta |
| Tu empresa exige licencias aprobadas por la OSI | Comprueba la lista de la OSI, no la palabra "open source" del sitio web |
| Solo usas el producto internamente | La SSPL y la BSL **casi nunca se activan**. Documéntalo y sigue |
| Vas a **ofrecer** el producto como servicio | **Para.** Esa conversación es legal y va antes del código |
| Vas a distribuir tu producto con esa dependencia dentro | Familia copyleft: mira con cuidado. Permisiva: conserva los avisos |
| El proyecto lo sostiene una empresa con inversores | Cuenta el riesgo de cambio de licencia como un riesgo más |
| Han pasado dos años desde la última revisión | Vuelve a ejecutar el §7. Es lo que nadie hace |
| Tienes dudas de verdad | **Escala.** No es tu decisión y no pasa nada porque no lo sea |

---

## ⚠️ Advertencias

**Nada de este apéndice es asesoría legal.** Se lo ha ganado el sitio de la advertencia final y por eso está dos veces. Aquí se enseña a detectar el riesgo y a escalarlo. **La decisión sobre si tu empresa puede hacer algo la toma quien tenga la responsabilidad de tomarla**, con el contrato del proveedor delante y con el escenario concreto encima de la mesa. Un ingeniero que dice "esto se puede" o "esto no se puede" sobre una licencia está opinando fuera de su competencia, y eso también es un riesgo.

**Las fechas y los términos de esta página se verificaron el 10/09/2026** contra las fuentes que están en la sección de referencias. Son hechos con fecha, y las licencias cambian: si vas a citar alguno en un documento que alguien firme, **vuelve a comprobarlo**. Citar de memoria en material legal es peor que no citar.

**La licencia que te aplica es la de tu versión, no la del proyecto.** Es la confusión más común y la que hace que la gente se alarme sin motivo o se tranquilice sin motivo, según el caso.

**Y la que más cuesta interiorizar: un cambio de licencia es una deuda técnica que ningún refactor arregla.** No se puede diseñar contra ella, no se detecta en una revisión de código, y no aparece en ninguna métrica. Lo único que se puede hacer es contarla como riesgo desde el principio y volver a mirarla cada cierto tiempo.

---

## 📚 Referencias

**Fuentes primarias, con fecha de verificación (10/09/2026)**

- MongoDB — texto de la Server Side Public License: https://www.mongodb.com/legal/licensing/server-side-public-license
- MongoDB — FAQ de la SSPL, que es donde se responde el caso de uso interno: https://www.mongodb.com/legal/licensing/server-side-public-license/faq
- MongoDB — nota de prensa del 16/10/2018: https://www.mongodb.com/company/newsroom/press-releases/mongodb-issues-new-server-side-public-license-for-mongodb-community-server
- Elastic — *Doubling down on open, Part II* (14/01/2021), el anuncio del cambio: https://www.elastic.co/blog/licensing-change
- Elastic — *Elastic License Update*, la vuelta a AGPLv3 (2024): https://www.elastic.co/blog/elastic-license-update
- Lightbend/Akka — *Why we are changing the license for Akka* (07/09/2022): https://akka.io/blog/why-we-are-changing-the-license-for-akka
- Akka — FAQ de la BSL, con el umbral de facturación y la fecha de reversión: https://akka.io/bsl-license-faq
- Redis — *Redis is now available under the AGPLv3 open source license* (mayo de 2025): https://redis.io/blog/agplv3/
- Redis — página de licencias vigentes: https://redis.io/legal/licenses/
- CNCF — compra y relicencia de RethinkDB (06/02/2017): https://www.cncf.io/blog/2017/02/06/cncf-purchases-rethinkdb-source-code-contributes-linux-foundation-apache-license/

**Referencias generales**

- Open Source Initiative — la definición de código abierto y la lista de licencias aprobadas: https://opensource.org/licenses
- Business Source License 1.1, el texto: https://mariadb.com/bsl11/
- Maven License Plugin, para generar el informe del §7: https://www.mojohaus.org/license-maven-plugin/
- Heather Meeker, *Open (Source) for Business* (2ª ed., 2017) — el libro de referencia sobre licencias escrito por una abogada, legible para ingenieros.

> ⚠️ URLs, textos de licencia y condiciones cambian. **Este apéndice se escribió el 10 de septiembre de 2026** y todo lo que afirma tiene esa fecha. Es el único del track donde eso no es una fórmula.

---

## 🧪 Ejercicios (6)

Todos sobre las dependencias reales de tu propio proyecto. Ninguno requiere saber derecho.

1. Genera el informe `THIRD-PARTY.txt` de tu `server/pom.xml` y cuenta cuántas licencias distintas aparecen en tu árbol. Anota cuántas dependencias transitivas tienes frente a las que declaraste.
2. Busca en ese informe alguna dependencia que **no** esté bajo una licencia aprobada por la OSI. Si no hay ninguna, anótalo: también es un resultado.
3. Saca la licencia de la imagen de MongoDB que estás corriendo, leyéndola **dentro del contenedor**. Anota cuál es y compárala con la que tendría `mongo:4.0.3`.
4. **Diagnóstico.** Contesta por escrito, para el escenario real de Laboratorios Andina, si la SSPL le impone alguna obligación. Argumenta con la cláusula concreta, no con el titular de una noticia. Después responde la misma pregunta para el escenario hipotético de que la empresa vendiera LabCore a otros laboratorios.
5. Elige tres dependencias de tu `pom.xml` y contesta las seis preguntas del §8 para cada una. La sexta —cuándo se revisa— escríbela como una fecha concreta.
6. **Escritura.** Redacta el párrafo de `IRRECOVERABLE.md` sobre licencias: qué se comprobó, cuándo, qué se encontró, qué obligación hay (probablemente ninguna), y **quién** vuelve a comprobarlo y con qué periodicidad. Cinco líneas, sin alarma y sin minimizar. Es el entregable del apéndice.

---

> 🏷️ **Este apéndice no lleva tag propio** y tampoco produce código. Lo que sale de leerlo —el informe del ejercicio 1 y el párrafo del ejercicio 6— se commitea con el prefijo de la fase desde la que llegaste (`be07: …`, `be08: …`). El `THIRD-PARTY.txt` **sí conviene versionarlo**: un informe de licencias fechado y en el repositorio es exactamente el tipo de evidencia que nadie tiene el día que alguien la pide. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.
