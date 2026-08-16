# 📅 Fase be07 — La subida que nadie decidió: 4.0 → 4.4 → 6.0 → 7.0

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Fase be07 de be08 · **8 horas**
> Depende de: be06 — el corte de los rangos está hecho y la pérdida delimitada
> Habilita: be08
> Apéndices de apoyo: [bea-02 (el `.env` y el compose)](./bea-02-receta-de-imagen-y-compose.md) · [bea-10 (riesgo de licencia)](./bea-10-riesgo-de-licencia-sspl.md) · [Incidentes asociados](./cuaderno-incidentes-be.md): be-11 ⭐

---

## 🎯 1. Propósito

Investigar un incidente cuyo `git log` está vacío.

Vas a hacer lo que haces siempre: `git log` sobre el archivo sospechoso, `git blame` sobre la línea, revisar qué se desplegó la semana pasada, buscar el ticket. Y no vas a encontrar nada. **Porque no hay nada.** El cambio que rompió el sistema no está en el árbol de fuentes, no tiene commit, no tiene autor y no tiene revisor.

Está en una línea de un archivo que no es código:

```
MONGO_TAG=4.0
```

Esta fase existe para instalar un reflejo que casi nadie tiene: **cuando el `git log` está vacío, la causa está fuera del repositorio**, y hay que saber dónde buscar. En LabCore, lo que estuvo cambiando durante siete años sin que nadie lo decidiera fue la base de datos: el proveedor la subió cuatro versiones mayores —4.0 → 4.4 → 6.0 → 7.0—, cada una en su ventana de mantenimiento y cada una anunciada por un correo que alguien archivó.

> 🧠 **A la infraestructura la actualizan; a la aplicación no.** La base tenía dueño: un proveedor, un contrato, una auditoría y un calendario ajeno. El código no tenía ninguno. Esa asimetría es la que explica por qué, en siete años, la mitad del sistema se movió cuatro veces y la otra mitad no se movió nunca.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Tienes la tabla de evidencia con los cuatro escalones: versión, tag exacto, fecha de la ventana de mantenimiento, y de dónde sacaste cada fecha.
- [ ] Ejecutaste el upgrade escalonado tú mismo, cambiando **una línea del `.env`** y nada más, y `smoke.sh` te dijo en cada escalón qué seguía funcionando.
- [ ] Tienes el inventario de lo que se rompió, separado en dos: lo que rompió de verdad y lo que solo dejó de existir en las herramientas.
- [ ] Puedes demostrar que el driver de 2019 —`mongo-java-driver` 3.8.2— conecta contra las cuatro versiones sin que nadie tocara jamás el `pom.xml`, y sabes explicar por qué eso es la causa del abandono y no su consecuencia.
- [ ] Sabes exactamente **hasta dónde llega** lo que el curso midió y dónde empieza lo que tienes que medir tú.
- [ ] Reescribiste todos los runbooks del track —las agregaciones de `be02`, la demostración de `be05`, la delimitación de `be06`— para que funcionen en `mongosh`, y sabes cuántos comandos había que tocar.
- [ ] Puedes explicar por qué la transacción de `be05` sigue siendo imposible después de cuatro saltos mayores, y por qué ahora es **peor** que antes.
- [ ] Sabes bajo qué licencia corre la base de datos de la que depende el sistema, desde cuándo, y quién lo comprobó (nadie).

---

## 🚫 3. Qué NO entra todavía

- **Decidir si el sistema se queda en 7.0 o se mueve.** Se documenta el estado y el riesgo → **be08**.
- **Actualizar el `pom.xml` o el driver.** El punto de la fase es precisamente que nunca hizo falta. Tocar el driver ahora, sin una razón medida, sería repetir el error contrario.
- **Convertir a replica set aprovechando el bump.** Nadie lo hizo en ninguno de los cuatro escalones y esa es una observación de la fase, no una tarea → la recomendación va en `be08`.
- **La declaración de lo irrecuperable** → **be08**. Aquí se produce el material.
- **Tocar el frontend.** Sigue sin tocarse. En toda esta fase, la aplicación Angular no se entera de nada — y que no se entere de cuatro saltos mayores de la base es, en sí mismo, un dato.

---

## 🧠 4. Concepto mínimo

### 4.1 Lo que el `git log` no puede saber

`git blame` contesta una pregunta muy concreta: *¿quién cambió esta línea del código?*. Es tan útil que se convierte en reflejo, y el reflejo tiene un punto ciego enorme: **casi ningún sistema moderno está definido solo por su código**.

En LabCore, lo que decide cómo se comporta el sistema en producción está repartido en cuatro sitios y solo uno de ellos tiene historia:

| Dónde vive | ¿Está en git? | ¿Quién lo cambia? |
|---|---|---|
| El código de la aplicación | Sí | Tú, con revisión |
| El `pom.xml` y sus versiones | Sí | Nadie desde 2019 |
| **La versión de la base (`MONGO_TAG`)** | **No** | **El proveedor, en su ventana** |
| La configuración del ambiente | A medias | Operaciones, a veces |

La tercera fila es la fase. Y fíjate en lo que la hace especialmente traicionera: **el cambio tiene un efecto observable —el comportamiento del sistema cambia— y una causa invisible**. Todas las herramientas de investigación que tienes están construidas sobre el supuesto de que la causa está en el árbol de fuentes.

> 🧭 **La regla que hay que llevarse, y sirve muchísimo más allá de este curso:** cuando el síntoma es claro y el `git log` está limpio, deja de buscar en el código y hazte otra pregunta: *¿qué cambió que no pasa por mi repositorio?* La lista es siempre parecida — una imagen base, una versión de runtime, un certificado, una cuota, una regla de red, una política del proveedor, una zona horaria del sistema operativo. Casi nada de eso tiene commit.

### 4.2 La paradoja: la excelencia del proveedor permitió el abandono

Aquí hay que decir algo que va contra la narrativa fácil de la fase.

Entre 2019 y 2026, la base de datos de LabCore subió cuatro versiones mayores. **No pasó casi nada.** El sistema siguió funcionando, los informes siguieron saliendo, y nadie tuvo que arreglar nada urgente. El 95 % siguió funcionando exactamente igual.

Y eso es un mérito enorme de MongoDB: la compatibilidad hacia atrás entre versiones mayores es de las mejores del ecosistema, con un mecanismo explícito —`featureCompatibilityVersion`— que permite subir el binario manteniendo el comportamiento antiguo hasta que decidas cambiarlo.

> 🧠 **Y ahí está la paradoja incómoda de la fase: la excelencia del proveedor es lo que permitió el abandono.** Si el salto de 4.0 a 4.4 hubiera roto algo ruidosamente, alguien habría tenido que mirar el sistema en 2021, y habría encontrado el `$set` de los rangos, y el standalone sin replica set, y las cinco formas del documento de paciente. **Nada se rompió, así que nadie miró.** Un sistema que falla llama la atención; uno que aguanta se vuelve invisible.

No es un argumento contra la compatibilidad hacia atrás, que es una virtud. Es un argumento a favor de mirar los sistemas que no se quejan, que es mucho más difícil de defender en una reunión de priorización.

### 4.3 Dónde se rompen las cosas: allí donde alguien esquivó el framework

Los fallos que sí aparecen tras cuatro saltos mayores no están repartidos al azar. Se concentran, y el criterio es limpio:

**Lo que pasa por `spring-data` casi siempre sobrevive.** Un repositorio derivado del nombre del método, un `findByLegacyId`, un `save()`: el framework traduce a la API del driver y el driver habla con el servidor negociando lo que hay. Cuatro versiones mayores después, siguen funcionando.

**Lo que esquiva el framework es lo que se rompe.** Un `MongoTemplate` con un `Document` armado a mano, un comando ejecutado con `runCommand`, un `$eval`, una consulta que usa un operador que dejó de existir. Ahí no hay nadie traduciendo: estás hablando con el servidor en su idioma, y el servidor cambió de idioma.

> 🧭 **La regla, que es una de las más útiles del track entero:** *la abstracción que te resultaba molesta es la que te salvó.* Todas las veces que en 2019 alguien pensó "esto es más rápido con `mongoTemplate` directamente" crearon una deuda que se cobró siete años después. Y no se cobró por la deuda en sí, sino porque **el código que esquiva el framework no se beneficia de que el framework se actualice** — aunque en este caso ni siquiera se actualizó, y aun así absorbió los cambios.

### 4.4 ⚠️ El alcance exacto de lo que el curso midió

Esto es contenido, y es la parte más importante del §4.

El track verificó que `mongo-java-driver` 3.8.2, sobre Java 8, **conecta** contra `mongo:4.0`, `4.2`, `5.0`, `6.0`, `7.0` y `8.0`. La verificación cubre el *handshake* y un comando: `buildInfo`. Está fechada en `propuesta-fases-backend.md` §5.2 y es real.

**Y ahí termina lo que sabe el curso.**

> ⚠️ **Si cada operación que la aplicación usa se comporta igual tras cuatro saltos mayores, eso no lo sabe nadie. Averiguarlo es tu trabajo en esta fase.**
>
> Que el driver conecte significa que los dos extremos se ponen de acuerdo en un protocolo. No significa que un `$lookup` devuelva lo mismo, que un índice se use igual, que el orden de un `$group` sin `$sort` sea el mismo, ni que un error tenga el mismo código. Nada de eso está medido, y creer que sí lo está —porque "conecta"— es exactamente el falso positivo del `startTransaction()` perezoso de `be05`, con otro disfraz.

Esa distinción entre *"comprobamos que conecta"* y *"comprobamos que funciona"* es la que separa un informe de compatibilidad útil de uno que da confianza sin fundamento. Y es la que vas a tener que escribir con precisión en `be08`.

---

## 💻 5. Código mínimo con comentarios

### 5.1 La tabla de evidencia

Reconstruirla es el primer trabajo, y la lección de método es que **ninguna de las fechas sale de la base de datos**.

| Escalón | Tag exacto | Ventana de mantenimiento | De dónde sale la fecha |
|---|---|---|---|
| Despliegue inicial | `4.0.28` | septiembre de 2019 | El acta de puesta en producción |
| 4.0 → 4.4 | `4.4.30` | marzo de 2021 | Correo del proveedor, archivado |
| 4.4 → 6.0 | `6.0.28` | agosto de 2023 | Correo del proveedor + ticket de Operaciones |
| 6.0 → 7.0 | `7.0.41` | febrero de 2025 | Correo del proveedor |

> 📝 Los tags de la tabla son los últimos parches visibles de cada línea a **10/09/2026**, comprobados en el registro y no de memoria. Los vas a volver a comprobar tú en el ejercicio 2, porque van a haber cambiado: un tag flotante como `mongo:6.0` apunta hoy a un parche y mañana a otro, y **eso también es un cambio que nadie decide**.

Las cuatro ventanas tienen una cosa en común y hay que nombrarla: **cada salto ocurrió porque la versión anterior llegó a fin de soporte**. Nadie en Laboratorios Andina decidió subir; el proveedor dejó de sostener lo viejo y avisó. La decisión existía —se podía haber pedido quedarse, pagar soporte extendido, o migrar a otro proveedor— pero para tomarla había que leer el correo, y el correo llegaba a una lista de distribución de Operaciones.

### 5.2 El upgrade, en una línea

```bash
# .env — La versión de la base vive AQUÍ, fuera del código fuente.
MONGO_TAG=4.0
```

```bash
# El escalón. Una línea, un reinicio del contenedor.
sed -i '' 's/MONGO_TAG=4.0/MONGO_TAG=4.4/' .env
docker compose up -d db

# Y el juez de siempre, que a partir de aquí trabaja para ti.
./smoke.sh
```

**Se sube escalonado y no de un salto**, y la razón es técnica y no ceremonial: MongoDB solo garantiza el upgrade entre versiones mayores **consecutivas**. Saltar de 4.0 a 7.0 directamente no está soportado, y el binario nuevo puede no entender el formato de datos del viejo. El proveedor lo hizo escalonado por la misma razón, y por eso hay cuatro correos y no uno.

```bash
# La escalera completa. Después de cada escalón, smoke.sh y un vistazo al log.
for tag in 4.4 6.0 7.0; do
  sed -i '' "s/^MONGO_TAG=.*/MONGO_TAG=$tag/" .env
  docker compose up -d db
  sleep 10
  echo "== escalón $tag =="
  ./smoke.sh || echo ">>> ALGO SE ROMPIÓ EN $tag <<<"
done
```

**Detalles con intención**

- El `sleep 10` es tosco y está ahí para que se vea el problema: **no hay ninguna señal de que la base terminó de arrancar**. En un despliegue de verdad esto es un `healthcheck` del compose, y `bea-02` lo tiene. Aquí se deja crudo porque el ejercicio 8 lo arregla.
- `smoke.sh` corre **contra la aplicación**, no contra la base. Es la comprobación correcta: lo que importa no es que Mongo arranque, sino que el contrato siga cumpliéndose. Eso es lo que `be00` compró.
- Si un escalón deja la base sin arrancar, mira el log de `mongod` **antes** de tocar nada. El mensaje suele ser explícito sobre `featureCompatibilityVersion`, y es el ejercicio 12.

### 5.3 El inventario de lo que se rompió

Y aquí llega el hallazgo, que no está donde uno lo buscaría.

**Nada de la aplicación se rompió.** `smoke.sh` pasa entero en los cuatro escalones. El backend de `be03` sirve el contrato igual sobre 7.0 que sobre 4.0.

**Lo que se rompió son las herramientas.** El shell `mongo` desapareció en la 6.0, sustituido por `mongosh`. Medido:

```
mongo:4.0   "mongo": sí   "mongosh": NO
mongo:6.0   "mongo": NO   "mongosh": sí
mongo:7.0   "mongo": NO   "mongosh": sí
```

Léelo despacio, porque la consecuencia es mayor de lo que parece: **todo runbook, todo script de operación y todo `docker exec … mongo --eval` escrito entre 2019 y 2023 está roto**. No fallan con un error de sintaxis: fallan con `executable file not found`, que es el error que más tiempo hace perder porque parece un problema de la máquina.

Haz tu propio inventario, y empieza por lo que has escrito tú en este track:

| Dónde | Qué se rompe |
|---|---|
| `be02` §5.1-§5.7 | Todas las agregaciones de medición: `docker compose exec db mongo` |
| `be05` §5.2 | La demostración de la transacción rechazada, que es la pieza más citada del track |
| `be05` §5.3 | El `rs.initiate()` del replica set de un nodo |
| `be06` §5.2-§5.4 | Las tres consultas de delimitación de la ventana |
| Runbooks de Operaciones | Todo lo que hay, sin excepción |

> 🧠 **Y ahí está el segundo hallazgo, que es más incómodo que el primero: los tickets que este salto entrega gratis no son de la aplicación, son de la capacidad de operar la aplicación.** El sistema sigue funcionando perfectamente y ha perdido la mitad de sus herramientas de diagnóstico. Es un tipo de daño que ningún monitor detecta, porque no hay ninguna métrica que baje.

La conversión es casi mecánica —`mongosh` es compatible con la mayor parte de lo que escribías— pero hay diferencias reales, y el ejercicio 14 las busca: el manejo de números largos, la salida por defecto, y el comportamiento de algunos ayudantes. Que sea "casi" es justo lo que lo hace peligroso.

### 5.4 El driver que nunca cambió

```bash
# La comprobación, servidor por servidor, con el driver de 2019.
# Es la que el track ya midió y que aquí repites tú, porque un dato que no
# has reproducido no es tuyo.
mongo:4.0  OK    mongo:5.0  OK    mongo:7.0  OK
mongo:4.2  OK    mongo:6.0  OK    mongo:8.0  OK
```

```xml
<!-- Y el pom.xml, entero, sin una sola línea que mencione a MongoDB salvo
     el starter. La versión del driver la fija el BOM del parent 2.1.18, que
     nadie ha tocado desde 2019. -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
```

> 🧠 **Esta es la respuesta a "¿por qué nadie miró?", y es más simple y más incómoda de lo que parece: no había una línea que mirar.** Si el driver hubiera estado declarado con su versión en el `pom.xml`, cualquier revisión de dependencias —un Dependabot, una auditoría de seguridad, un `mvn versions:display-dependency-updates`— lo habría señalado. Como llega dentro de un BOM que llega dentro de un parent, es invisible para casi todas las herramientas que la gente usa para vigilar sus dependencias.
>
> No es un defecto de Spring Boot: la gestión centralizada de versiones es lo que evita el infierno de dependencias incompatibles, y es una de las mejores ideas del ecosistema. **Pero tiene un coste que casi nadie contabiliza: mueve las decisiones de versión a un lugar donde no se ven.**

### 5.5 Lo que sí hay que ir a medir

El §4.4 dijo que la compatibilidad de las operaciones no está medida. Este es el trabajo, y el método es siempre el mismo: **la misma operación, contra las dos versiones, comparando salidas byte a byte**.

```bash
# Patrón general. Se ejecuta la misma consulta contra dos contenedores con
# versiones distintas y se comparan las salidas. Lo que difiere, se investiga.
docker exec mongo-40 mongo   labcore --quiet --eval "$CONSULTA" > /tmp/salida-40.txt
docker exec mongo-70 mongosh labcore --quiet --eval "$CONSULTA" > /tmp/salida-70.txt
diff /tmp/salida-40.txt /tmp/salida-70.txt
```

Los candidatos que hay que probar, en orden de probabilidad de dar un susto:

1. **Comandos retirados.** Entre 4.0 y 7.0 desaparecieron varios comandos de la vieja escuela —`$eval`, `geoNear` como comando, `copydb`/`clone`— y map-reduce quedó desaconsejado. Si algo del sistema los usa, falla; si no los usa, no. **Búscalo con `grep` en tu propio código antes de suponerlo.**
2. **El orden sin `$sort`.** Una agregación sin ordenación explícita no promete ningún orden, y el orden real depende del plan de ejecución, que cambia entre versiones. Si alguna pantalla depende del orden "natural", el salto lo rompe y el síntoma es cosmético e intermitente. Es el peor de todos.
3. **Los planes de consulta.** El mismo `explain()` sobre la misma consulta puede elegir otro índice. Compara los `executionStats` de `be02` y `be03` en 4.0 y en 7.0: si alguno cambió de `IXSCAN` a `COLLSCAN`, tienes un problema de rendimiento latente.
4. **Los códigos y mensajes de error.** El error 20 de `be05` es una cita literal en el material del track. Comprueba que el mensaje sigue siendo exactamente ese en 7.0. Si cambió, hay documentación que corregir — y una lección sobre citar mensajes de error como si fueran API.
5. **Los valores por defecto.** `readConcern`, `writeConcern` y el manejo de sesiones tienen defaults que se han movido entre versiones. Los tuyos están escritos en pocos sitios; compruébalos.

> 🧭 **El criterio para decidir qué medir, porque medirlo todo no es posible:** *ordena por lo que rompería sin avisar.* Un comando retirado falla ruidosamente y se arregla en una tarde. Un orden que cambia en silencio produce un ticket dentro de tres meses que nadie va a relacionar con el upgrade de hace tres meses. **Lo que se mide primero es lo silencioso**, no lo grave.

### 5.6 El remate: la topología sobrevivió intacta

```bash
# Después de cuatro saltos mayores, la pregunta de be05, otra vez.
docker compose exec db mongosh --quiet --eval 'db.serverStatus().repl'
```

```
undefined
```

Sigue siendo un standalone. **Nadie convierte un standalone en replica set durante un bump de versión**, porque un bump de versión es una operación de mantenimiento con una ventana ajustada y un plan de reversión, y cambiar la topología es un proyecto con otro riesgo y otra aprobación. Así que la decisión de una tarde de 2019 sobrevivió intacta a cuatro oportunidades de revisarse.

Y ahora vuelve a correr la demostración de `be05` sobre 7.0 —traducida a `mongosh`, claro—:

```
RESULTADO: RECHAZADA
codigo:  20
mensaje: Transaction numbers are only allowed on a replica set member or mongos
```

> 🧠 **La transacción sigue siendo imposible en 2026, y ahora además el manual dice que se puede.** Ese es el remate de la fase y el que cierra el círculo con `be05`. En 2019, "MongoDB no tiene transacciones multidocumento" era casi cierto y se podía decir en una reunión sin que nadie te discutiera. En 2026 es falso: las tiene, están documentadas, todo el mundo las usa, y cualquier desarrollador nuevo que entre al equipo va a escribir `@Transactional` dando por supuesto que funciona. **El sistema no solo tiene una carencia: tiene una carencia que contradice lo que el manual del producto promete**, y eso convierte cada incorporación al equipo en un incidente potencial.
>
> Anótalo con esas palabras para `be08`: la deuda ya no es solo técnica, es **una trampa para el próximo que llegue**.

### 5.7 Y la pregunta que nadie hizo en siete años: ¿bajo qué licencia corre esto?

```bash
docker exec mongo-70 cat /LICENSE | head -5
```

MongoDB pasó de AGPL a **SSPL** en octubre de 2018, con efecto sobre las versiones publicadas a partir de entonces. Es decir: **la versión que LabCore desplegó en 2019 ya era SSPL**, y nadie lo comprobó ni en el despliegue inicial ni en ninguno de los cuatro escalones.

Para una empresa que solo *usa* el producto —que es el caso de Laboratorios Andina— el impacto práctico es limitado, y `bea-10` explica por qué con precisión. Lo que importa aquí es otra cosa:

> 🧭 **Tu deuda técnica la puede crear un abogado.** Ni una línea de tu código cambió, ni una versión de tu `pom.xml` se movió, y las condiciones bajo las que puedes usar tu base de datos son distintas de las que había cuando se eligió. Es el mismo mecanismo de esta fase —un cambio con efecto y sin commit— llevado a su forma más pura, y la lista de precedentes es larga: Elasticsearch, Redis, Terraform, Akka pasando a BSL en 2022. **Comprobar la licencia de tus dependencias tiene fecha de caducidad**, y casi nadie la vuelve a comprobar.

> **Prueba de fuego.** Con el sistema en `MONGO_TAG=4.0` y todo en verde, ejecuta la escalera completa del §5.2 sin mirar nada más. Al terminar, sin haber tocado una línea de Java, comprueba tres cosas: que `smoke.sh` sigue entero en verde sobre 7.0, que la aplicación Angular funciona igual —haz el recorrido de once pasos de `be00`—, y que **ninguno** de tus comandos de `mongo` de las fases anteriores funciona. Después haz `git log --oneline -5` y `git status`. Los dos limpios. **Acabas de cambiar la versión mayor de la base de datos cuatro veces y tu repositorio no lo sabe.**

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma: `executable file not found in $PATH: mongo`.**
Causa: estás en 6.0 o superior y el shell se llama `mongosh`. Fix mínimo: cambiar el comando. Y después haz el inventario del §5.3, porque si un runbook está roto, están rotos todos.

**Síntoma: la base no arranca tras un escalón y el log habla de `featureCompatibilityVersion`.**
Causa: se saltó un escalón, o el anterior no llegó a completar su `setFeatureCompatibilityVersion`. Fix mínimo: volver al tag anterior, comprobar la FCV, subirla, y **después** escalar. Es el ejercicio 12 y es el fallo más caro de esta fase, porque con datos de verdad puede necesitar restaurar una copia.

**Síntoma: `smoke.sh` pasa pero una pantalla muestra los datos en otro orden.**
Causa: una agregación sin `$sort` explícito. El plan cambió con la versión. Fix mínimo: añadir el `$sort`. Y anota el hallazgo entero, porque es el ejemplo perfecto de lo que `smoke.sh` **no** cubre: el contrato no dice nada del orden, así que el guion no puede.

**Síntoma: el upgrade "funcionó" y tres semanas después aparece un incidente raro.**
Causa: casi siempre, un cambio de comportamiento silencioso de los del §5.5. Fix mínimo: ninguno inmediato — lo que hay es un método, y es preguntar *"¿qué cambió en la infraestructura hace tres semanas?"* antes que *"¿qué desplegamos ayer?"*.

**Síntoma: alguien "aprovechó" para subir el driver a la última.**
Causa: buena intención. Fix mínimo: revertir. Un cambio de driver sin una razón medida convierte un upgrade con una variable en un upgrade con dos, y si algo falla ya no sabes cuál fue.

### Pieza forense de esta fase ⭐

**El incidente cuyo `git log` está vacío.**

Esta es la pieza más valiosa del track y hay que trabajarla sin saber la respuesta. Si ya leíste el §5, hazla con un compañero: que él prepare el escenario y tú investigues.

**El ticket, tal como llega:**

> *"Desde el fin de semana, el script nocturno de conciliación falla. No hemos desplegado nada. El log dice `executable file not found`."*

**Lo que hace cualquiera, en orden, y por qué no lleva a ninguna parte:**

1. `git log --since='2 weeks ago'` sobre el repositorio entero. **Vacío.** Nadie desplegó nada, y el que reportó tenía razón.
2. `git blame` sobre el script de conciliación. La última modificación es de 2021 y es un cambio de una ruta.
3. Revisar el pipeline de despliegue. La última ejecución fue hace mes y medio y salió bien.
4. Revisar los logs de la aplicación. **Impecables.** El backend sirve el contrato, `smoke.sh` está en verde, no hay una sola excepción.

**Cuatro caminos, ninguna pista.** Y ese es exactamente el momento que la fase quiere producir, porque es el momento en el que la mayoría de la gente empieza a dudar del que reportó el ticket.

**Las cuatro preguntas del método, contestadas:**

- **¿Qué se ve?** Un ejecutable que no existe, en una máquina que nadie tocó.
- **¿Qué capa lo produce?** Ninguna capa del sistema. **La imagen del contenedor de la base de datos**, que no es parte del sistema en ningún diagrama que exista.
- **🧬 ¿Lo escribió el sistema o llegó roto en el dato?** Ninguna de las dos, otra vez. Aquí ni siquiera hay un dato: hay una **herramienta** que dejó de venir dentro de una imagen. El daño no está en los datos ni en el código: está en la capacidad de operar.
- **¿Con qué se demuestra?** Con `docker compose exec db mongod --version` de hoy y con el `.env` — y, si tienes suerte, con el correo del proveedor. **La prueba está fuera del repositorio, y la mitad de las veces está fuera de la empresa.**

**Cómo se llega, y es una sola pregunta bien hecha:** *"¿qué cambió que no pasa por mi repositorio?"* Con esa pregunta encima de la mesa, el `.env` aparece en dos minutos.

> 🧠 **Y el hallazgo que hace que este incidente valga por sí solo la fase: en un curso construido sobre el par `-roto`/`-fix` y el `git diff` como factura de la deuda, este es el único incidente cuyo diff está vacío.** No tiene par. No se puede etiquetar como los demás porque no hay dos commits que comparar. Esa anomalía es deliberada y está declarada en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md): un tag que no apunta a un cambio no marca nada, y aquí no hay cambio que marcar. **Lo que se versiona de este incidente es el runbook corregido, no el arreglo.**

🧨 **Rompe a propósito.** Prepara el escenario para otra persona: deja el sistema en `MONGO_TAG=7.0`, con todos los runbooks del track intactos —o sea, escritos para `mongo`— y sin decirle nada. Dale el ticket del §6 tal cual. Cronometra cuánto tarda en encontrarlo y anota por dónde buscó primero. Ese dato, sobre gente de verdad, es la mejor prueba de que la fase enseña algo.

---

## 🧪 7. Ejercicios (29)

**🟢 Fácil (1–8)**

1. Localiza el `.env` de tu proyecto y confirma que `MONGO_TAG` no está en ninguna parte del código Java. Búscalo con `grep -r` para estar seguro.
2. Comprueba en el registro los últimos tags de las líneas 4.0, 4.4, 6.0 y 7.0 **hoy**, y compáralos con la tabla del §5.1. Anota las diferencias: cada una es un cambio que nadie decidió.
3. Sube un solo escalón, de 4.0 a 4.4, y corre `smoke.sh`. Anota el resultado y el tiempo de arranque de la base.
4. Comprueba en cada escalón si existen `mongo` y `mongosh` dentro de la imagen. Reproduce la tabla del §5.3.
5. Ejecuta la escalera completa y confirma que `smoke.sh` pasa en los cuatro escalones.
6. Con el sistema en 7.0, haz `git log --oneline -10` y `git status`. Captura la pantalla: es la ilustración de la fase.
7. Reproduce la comprobación del driver contra las seis versiones y anota los resultados. No te fíes de la tabla del curso.
8. Sustituye el `sleep 10` del §5.2 por un `healthcheck` en el `compose.yaml` (ver `bea-02`) y comprueba que la escalera sigue funcionando.

**🟡 Intermedio (9–17)**

9. Haz el inventario completo de tus propios comandos rotos: `grep -rn 'mongo ' ` sobre todo el material del track y sobre tus notas. Cuenta cuántos hay.
10. Convierte todas las agregaciones de `be02` a `mongosh` y confirma que dan **exactamente** los mismos números. Cualquier diferencia es un hallazgo.
11. Convierte la demostración de la transacción de `be05` y confirma que el código y el mensaje de error siguen siendo los mismos en 7.0. Si cambiaron, corrige la cita en tus notas.
12. **Diagnóstico.** Salta de 4.0 directamente a 7.0, sin escalones. Anota qué pasa exactamente, qué dice el log de `mongod`, y cómo lo recuperas. Hazlo con una base que puedas perder.
13. **Diagnóstico.** Investiga `featureCompatibilityVersion`: qué valor tiene tu base tras la escalera, qué habría pasado si no se hubiera subido en cada escalón, y por qué existe ese mecanismo.
14. Busca tres diferencias reales entre `mongo` y `mongosh` que afecten a algo que hayas escrito en este track. Documéntalas.
15. **Diagnóstico.** Compara el `explain()` de las consultas de `be03` en 4.0 y en 7.0. Anota si algún plan cambió. Si ninguno cambió, di qué habrías hecho si alguno hubiera cambiado.
16. Redacta el runbook corregido de operaciones —los comandos de diagnóstico más usados, en `mongosh`— y **versiónalo**. Es lo único de este incidente que tiene commit.
17. Comprueba la licencia de la imagen que estás corriendo y anota desde qué versión aplica. Apóyate en [`bea-10`](./bea-10-riesgo-de-licencia-sspl.md).

**🟠 Difícil (18–24)**

18. **Diagnóstico ⭐.** Ejecuta la pieza forense con un compañero, en los dos papeles. Anota por dónde buscó primero cada uno y cuánto tardó.
19. **Diagnóstico.** Busca en tu propio código toda operación que **esquive** el framework: `mongoTemplate` con `Document` a mano, `runCommand`, cualquier cosa que no pase por un repositorio derivado. Haz la lista y prueba cada una en 4.0 y en 7.0.
20. **Diagnóstico.** Encuentra una agregación sin `$sort` explícito en el material del track o en tu código. Ejecútala cien veces en 4.0 y cien en 7.0 y compara el orden. Explica por qué este es el fallo más peligroso de todos.
21. Escribe el guion `version-diff.sh` que ejecuta una lista de consultas contra dos contenedores de versiones distintas y reporta las diferencias. Es el hermano de `contract-diff.sh` del ejercicio 23 de `be00`, y es lo que habría convertido cada uno de los cuatro escalones en una tarde de trabajo en vez de en un salto de fe.
22. **Diagnóstico.** Mide el rendimiento de las tres consultas más frecuentes en 4.0 y en 7.0, con el mismo volumen de datos. Anota si alguna empeoró. Un upgrade que mejora el 95 % y empeora una consulta crítica es un upgrade que hay que revisar.
23. **Diseño.** Escribe el procedimiento que Laboratorios Andina debería seguir la próxima vez que llegue un correo del proveedor: quién lo recibe, qué se comprueba, con qué guion, en qué ambiente y con qué criterio se aprueba. Una página. Es un entregable de `be08`.
24. **Diagnóstico.** Averigua cuál es la fecha de fin de soporte de la versión que corres hoy, en la documentación oficial del producto. Si ya pasó o está cerca, tienes un quinto escalón en el horizonte y nadie lo sabe. Esa comprobación es una fila de `be08`.

**🔴 Muy difícil (25–29)**

25. **Adversarial.** Argumenta bien la posición contraria: *"que el proveedor mantenga la base actualizada es exactamente lo que se contrató; el sistema lleva siete años sin un incidente por esa causa, así que el modelo funciona"*. Es un argumento fuerte y hay datos a su favor. Después refútalo con lo que esta fase encontró: no con un fallo, sino con la ausencia de capacidad de detectar uno.
26. **Diseño.** El `pom.xml` no declara la versión del driver y por eso ninguna herramienta lo vigila. Propón tres formas de hacerlo visible sin cambiarlo, con su costo. Implementa una y demuestra que ahora aparece en un informe.
27. **Escritura.** Redacta el párrafo de `be08` que explica la asimetría del §4.1 a alguien de dirección: por qué la mitad del sistema se actualizó cuatro veces y la otra ninguna, y qué decisión hay que tomar al respecto. Sin culpar a Operaciones, que hizo su trabajo.
28. **Diagnóstico y escritura.** Escribe el post-mortem de ocho puntos del incidente **be-11** con el formato del cuaderno. El punto difícil es el del test de regresión: **no puede haber uno en el repositorio**, porque el cambio no ocurre en el repositorio. Escribe qué hay en su lugar y por qué es más débil.
29. **La medición que cierra la fase.** Escribe la página *"Qué cambió en LabCore sin que nadie lo decidiera"*, con una fila por cada cosa que se movió fuera del control del equipo entre 2019 y hoy: versión de base, tags flotantes, licencia, fin de soporte, y lo que encuentres tú. Es el capítulo de `be08` que más incomoda y el que mejor explica por qué un sistema "congelado" no está quieto.

**🔥 Opcionales**

- 🔥 Sube a `mongo:8.0` —un escalón más allá de lo que hizo el proveedor— y anota qué se rompe. Es el ensayo del próximo correo, y hacerlo antes de recibirlo es la diferencia entre una ventana de mantenimiento y una noche.
- 🔥 Ancla `MONGO_TAG` a un digest (`mongo@sha256:…`) en vez de a un tag flotante y explica qué ganas y qué pierdes. Después decide si LabCore debería hacerlo, sabiendo quién opera la base de verdad.
- 🔥 Busca en el resto del proyecto todo lo que dependa de un tag flotante o de una versión no fijada —imágenes base, acciones de CI, `latest` en cualquier sitio— y haz la lista. Cada línea es un `MONGO_TAG` esperando su turno.

---

## 📚 8. Referencias

**Documentación oficial**

- MongoDB — notas de versión de 4.4, 5.0, 6.0 y 7.0, con las secciones de *Compatibility Changes* y *Removed Commands*, que son las que hay que leer de verdad: https://www.mongodb.com/docs/manual/release-notes/
- Upgrade de una versión mayor a la siguiente, y por qué tiene que ser escalonado: https://www.mongodb.com/docs/manual/release-notes/7.0-upgrade-standalone/
- `setFeatureCompatibilityVersion` — el mecanismo que hace posible subir el binario sin cambiar el comportamiento: https://www.mongodb.com/docs/manual/reference/command/setFeatureCompatibilityVersion/
- `mongosh` y las diferencias con el shell antiguo: https://www.mongodb.com/docs/mongodb-shell/
- Ciclo de vida y fechas de fin de soporte de cada versión: https://www.mongodb.com/legal/support-policy/lifecycles ⚠️ **Compruébalo tú:** las fechas se mueven y este curso no las cita de memoria.
- Server Side Public License (SSPL), vigente desde octubre de 2018: https://www.mongodb.com/legal/licensing/server-side-public-license
- Maven — cómo un BOM heredado del parent fija versiones que no aparecen en tu `pom.xml`: https://maven.apache.org/guides/introduction/introduction-to-dependency-mechanism.html#bill-of-materials-bom-poms

**Libros y artículos de referencia**

- Michael Nygard, *Release It!*, 2ª ed. (2018) — el capítulo sobre despliegues y el concepto de *versionless* dependencies. Su tesis, que es la de esta fase: los sistemas fallan en las costuras entre lo que controlas y lo que no.
- Jez Humble y David Farley, *Continuous Delivery* (2010), capítulo 2 — *"si no está en control de versiones, no existe"*. Este capítulo se lee distinto cuando acabas de vivir un cambio que no estaba en control de versiones.
- Sobre licencias que cambian bajo los pies, `bea-10` lo desarrolla entero, con el precedente de Elasticsearch, el de Akka en 2022 y la nota de RethinkDB: *elegiste bien y perdiste igual*.

**Video y apoyo**

- Charlas sobre gestión de dependencias transitivas y BOM en el ecosistema JVM (2019-2023): https://www.youtube.com/results?search_query=maven+bom+dependency+management — útiles para entender por qué el driver era invisible.

**Orden de lectura sugerido:** las notas de versión de 6.0, sección *Removed Commands*, **antes** de subir el escalón, para saber qué buscar → la página de `featureCompatibilityVersion` cuando el ejercicio 12 te deje la base sin arrancar → la política de ciclo de vida en el ejercicio 24, comprobándola tú → `bea-10` al final, cuando la conversación deje de ser técnica.

> ⚠️ URLs y contenidos cambian —y en esta fase eso no es una advertencia genérica, es el tema—. Las fechas de fin de soporte, los tags del registro y las condiciones de licencia se mueven, y este capítulo se escribió el 10 de septiembre de 2026. Comprueba cada dato antes de citarlo en un documento que alguien vaya a firmar.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Subiste la base cuatro versiones mayores cambiando una línea de un archivo que no es código, el sistema siguió funcionando, y tu repositorio no se enteró de nada. Por el camino perdiste todas tus herramientas de diagnóstico sin que ningún monitor lo detectara, y confirmaste que el standalone de 2019 sobrevivió intacto a cuatro oportunidades de revisarse.

El reflejo que instala esta fase es uno y es corto: **cuando el `git log` está limpio y el síntoma es real, la causa está fuera del repositorio.** Con eso en la cabeza, la lista de sospechosos —imagen base, versión de runtime, certificado, cuota, política del proveedor, licencia— aparece sola, y lo que antes eran cuatro horas de desconcierto son dos preguntas.

Y con esta fase termina la parte de investigar. Tienes ocho fases de números: cinco formas del documento de paciente, 37 órdenes huérfanas, tres poblaciones de vacío, la divergencia de las dos bitácoras, 23 cadenas rotas y 9 órdenes atrasadas, 14 meses de historia de rangos con 37 veredictos irreproducibles, y una base que se movió cuatro veces sola.

**be08** no añade ni un número: los gasta. Es el cierre, y llega con tres piezas construidas —el retrofit de `$jsonSchema` en modo `warn`, el outbox hacia un Postgres de lectura, y el libro de correcciones ya en producción— y con un entregable escrito que es lo más valioso de todo el track: **la declaración de lo irrecuperable**, firmada, fechada y con números. Más el árbol de veredicto honesto con las cuatro opciones costeadas, gobernado por una regla que ya puedes anticipar: *la respuesta correcta depende de la fecha de decomisión, no de la calidad del código*.

> **La señal de que quedó bien:** *"cuando el `git log` está limpio, ya no dudo del que reportó el ticket: pregunto qué cambió fuera de mi repositorio."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-07-la-subida-que-nadie-decidio -m "be07 cerrada: tabla de evidencia de los cuatro escalones; escalera ejecutada desde el .env; inventario de runbooks rotos por la desaparicion del shell; driver 3.8.2 verificado contra las seis versiones; topologia intacta y transaccion aun imposible; licencia comprobada"
> ```
>
> Los commits de la fase llevan su prefijo (`be07: …`) y los de ejercicio su número (`be07 ej21: …`).
>
> ⚠️ **Y esta fase tiene una anomalía declarada:** su incidente `be-11` **no tiene par `-roto` / `-fix`**, porque el cambio que lo provoca no es un commit. Lo único que se versiona es el runbook corregido del ejercicio 16. Un tag que no apunta a un cambio no marca nada, y aquí no hay cambio que marcar. Está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.

---

## 📌 Pendientes sugeridos

- **[A] El sistema queda en `MONGO_TAG=7.0`** y ahí se queda. Si el ejercicio 24 revela que 7.0 está cerca de su fin de soporte, eso es una fila de `be08` con fecha, no una tarea de esta fase.
- **[B] Todos los runbooks del track están reescritos para `mongosh`** a partir de aquí. Si una fase anterior se edita, hay que revisar sus comandos: `be02`, `be05` y `be06` son las afectadas.
- **[C] El guion `version-diff.sh`** del ejercicio 21 debería existir antes del próximo correo del proveedor. Es la contramedida más barata de todo el track y la única que convierte un salto de fe en una tarde de trabajo.
- **[D] El driver invisible.** La propuesta del ejercicio 26 —hacer visible la versión sin cambiarla— tiene que llegar a `be08` como recomendación fechada.
- **[E] La cita literal del error 20** aparece en `be05`, en la propuesta del track y en este capítulo. Si alguna vez cambia el mensaje en una versión futura, hay que corregir los tres sitios a la vez. Citar un mensaje de error como si fuera API tiene ese costo, y se acepta a sabiendas porque el valor pedagógico lo justifica.
- **[F] La licencia** se comprobó aquí por primera vez en siete años. `be08` tiene que decir quién la comprueba a partir de ahora y con qué periodicidad, o dentro de tres años estaremos igual.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dificultad |
|---|---|---|---|
| **be-11** ⭐ | *"No desplegamos nada y dejó de funcionar"* | Cambio fuera del repositorio | 🔴 |

Es la pieza forense de la sección 6 entregada como ticket, y es **el incidente insignia del cuaderno del track BE**. Llega sin ninguna pista útil: el script nocturno falla, nadie desplegó nada, el `git log` está limpio y los logs de la aplicación están impecables. Los cuatro primeros movimientos del investigador —`git log`, `git blame`, el pipeline, los logs— no llevan a ninguna parte, y ese callejón está diseñado.

**Este incidente no tiene par `-roto` / `-fix`**, y esa anomalía es su mejor propiedad: en un curso construido sobre el `git diff` como factura de la deuda, hay exactamente uno cuyo diff está vacío. El post-mortem tiene que llegar a la pregunta que lo resuelve —*¿qué cambió que no pasa por mi repositorio?*— y a la conclusión incómoda de que el test de regresión no puede vivir en el código: lo más parecido que existe es un guion de comparación entre versiones y un procedimiento para cuando llegue el próximo correo.
