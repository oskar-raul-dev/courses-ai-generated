# 📎 Apéndice bea-11 — Mapa de deuda del track BE

> Tutorial Angular 8 — Laboratorio clínico · 🔥 Track BE · Consulta rápida · **2 horas**
> Usado por: be08 · **El track base no tiene un mapa equivalente**: sus 💸 viven declaradas dentro de cada fase (ver más abajo)

**Esto no se lee de corrido**, aunque este es el apéndice que más se acerca a poder leerse así. Se entra buscando *"¿por qué esto está feo?"* o *"¿qué arreglaríamos primero si hubiera presupuesto?"*, y se sale con la respuesta y con la razón por la que nadie la arregló.

Resuelve una cosa: **dejar por escrito qué quedó feo a propósito en el backend que acabas de construir, qué lo vuelve exigible, y en qué orden se pagaría.**

**Qué queda fuera:** las deudas del **track base** —las del frontend de Angular—, que están declaradas con 💸 dentro de cada fase que las contrajo y no se repiten aquí. Lo que sí aparece es **qué pasó con las cuatro que el track BE vino a cobrar**, porque cerrar ese círculo es media razón de que el track exista.

> 📝 **Divergencia declarada, y conviene saberla:** el track base de este curso **no tiene un apéndice de mapa de deuda** —sus trece apéndices son de consulta técnica, y `a12` es el de arm64/Apple Silicon—. Sus 💸 se declaran en el sitio donde nacen, dentro de cada fase, y el inventario consolidado no existe. Este apéndice es, por tanto, **el primero del curso que consolida deuda**, y lo hace solo para el backend. Si algún día se escribe el del track base, esta tabla del §1 es el punto por donde se enganchan los dos.

> 🧭 **Regla de coherencia dura, y se verifica:** cada 💸 de esta página existe literalmente en alguna fase, y cada 💸 de las nueve fases aparece aquí. El ejercicio 1 comprueba las dos direcciones. Si al hacerlo encuentras una que no cuadra, **no la inventes ni la borres**: significa que una fase está mal y hay que arreglar la fase.

---

## Índice

- [1. Primero: las cuatro deudas que el track vino a cobrar](#1-primero-las-cuatro-deudas-que-el-track-vino-a-cobrar)
- [2. El inventario: las deudas del backend nuevo](#2-el-inventario-las-deudas-del-backend-nuevo)
- [3. Las que no son 💸 pero pesan igual](#3-las-que-no-son--pero-pesan-igual)
- [4. El criterio que las ordena](#4-el-criterio-que-las-ordena)
- [5. El orden, si mañana hubiera presupuesto](#5-el-orden-si-mañana-hubiera-presupuesto)
- [6. Las que no se pagan nunca](#6-las-que-no-se-pagan-nunca)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-6)

---

## 1. Primero: las cuatro deudas que el track vino a cobrar

Son del track base y no se inventarían aquí. Lo que sí se dice es **qué se consiguió con cada una**, con el verbo preciso de `be08` §4.1 —prevenir, detectar, compensar, declarar— porque usar el verbo equivocado es lo que hace que un informe no valga.

| Deuda del track base | Fase que la cobró | Resultado | Verbo |
|---|---|---|---|
| 💸 1 · El audit log lo escribe el frontend | `be04` | Bitácora del servidor en la sombra, con actor del token y reloj propio. **La del cliente sigue ahí** | **Detectar** (y prevenir hacia delante) |
| 💸 2 · El timestamp y el "quién" de la custodia los pone el navegador | `be05` | La ventana de fallo se redujo, no se cerró. Libro de correcciones | **Compensar** |
| 💸 3 · Paginar, filtrar y ordenar en el navegador | `be03` | Paginación de servidor implementada y **sin consumidor**. Deuda *hecha pagable* | **Declarar** |
| 💸 4 · Los rangos versionados leídos contra la vigente | `be06` | Append-only desde hoy. Los 14 meses perdidos **no se recuperan** | **Declarar** |

> 🧠 **Ninguna de las cuatro se pagó entera, y eso no es un fracaso del track: es su tesis.** Con el frontend intacto como restricción y dos años de decomisión por delante, lo que se puede hacer es reducir, contener y declarar. **Un mapa de deuda que dijera "pagadas" sería un mapa falso.**

---

## 2. El inventario: las deudas del backend nuevo

Las 💸 que declaran las nueve fases sobre el código que **tú** escribiste. Ocho, cada una con su fase y su motivo.

| # | Deuda | Fase | Qué sería lo correcto | Por qué no se paga |
|---|---|---|---|---|
| **BE-1** | Sin `spring-boot-starter-validation`: se valida a mano con `if` en el service | `be01` §5.1 | `@Valid` con Bean Validation | Funciona, y el sistema tiene dos años. Añadir el starter cambia el formato de los errores, que **está en el contrato** |
| **BE-2** | El origen de CORS (`http://localhost:4200`) escrito literal | `be01` §5.5 | Una propiedad de configuración | Hay un solo origen. Ponerlo en configuración **invita a que difiera entre ambientes**, que es el incidente 19 del track base |
| **BE-3** | Un modo de caos desconocido se ignora en silencio | `be01` §5.7 | Fallar al arrancar | **Es un defecto heredado del mock y se copia a propósito.** El reemplazo tiene que comportarse igual, incluso mal. Ver `be01` ej. 24 |
| **BE-4** | El secreto de firma del JWT, literal en el código | `be03` §5.9 | Variable de entorno | El secreto es de mentira y está impreso en el material. Y no hay ningún gestor de secretos al que llevarlo |
| **BE-5** | La ruta `../db.json` del `SeedRunner`, escrita a pelo | `be03` §5.5 | Una propiedad con la ruta | El semillero es **andamiaje del curso**, no código de LabCore. Muere con el curso |
| **BE-6** | `RequestContext` como `ThreadLocal`: estado global disfrazado | `be04` §5.1 | Un bean con ámbito de petición | Quince líneas contra una cadena de firmas atravesando cuatro capas. Se revisa **solo** si la estrategia de pruebas lo estorba |
| **BE-7** | `@Scheduled` sin bloqueo distribuido en el detector de integridad | `be05` §5.6 | Un bloqueo, o un job externo | Correcto con **una** instancia, y LabCore corre en una hasta que muera. **Con dos, se rompe en silencio** |
| **BE-8** | El evento del outbox se escribe sin transacción junto a la mutación | `be08` §5.3 | Outbox transaccional de verdad | El read-model es **derivado**: si se pierde un evento, el reconciliador lo detecta y reconstruye. **Perder un derivado es recuperable; perder un hecho no** |

> 💡 **Fíjate en que BE-3 es de otra naturaleza que las demás.** Las siete restantes son atajos que se aceptan; BE-3 es un defecto **copiado a propósito** para que el reemplazo sea fiel. No es la misma clase de deuda y no se prioriza con el mismo criterio: arreglarla sería **romper la paridad con el mock**, que es lo que `be00` compró. Un mapa que las mezclara sin decirlo estaría mal.

---

## 3. Las que no son 💸 pero pesan igual

Cosas declaradas como 📌 en las fases y que en una revisión de arquitectura irían en la misma tabla. Se listan aquí porque un mapa de deuda que solo recoge lo que lleva la etiqueta correcta es un mapa incompleto.

| # | Asunto | Fase | Riesgo real |
|---|---|---|---|
| **P-1** | `response.setHeader(name, null)` para quitar una cabecera es **específico de Tomcat** | `be01` 📌[A] | Si el contenedor cambia, el modo `nocors` deja de funcionar **en silencio** |
| **P-2** | El libro de correcciones es append-only **por disciplina, no por el motor** | `be05` 📌[B] | Un `$set` desde el shell lo rompe entero. Y es el documento que sostiene la auditoría |
| **P-3** | La guarda de inmutabilidad de rangos **no cubre el shell** | `be06` 📌[B] | Lo mismo. Se resuelve con permisos (`be08` §5.4), no con código |
| **P-4** | Credenciales literales en el `compose.yaml` | `bea-02` | Cero, mientras sea un laboratorio en un portátil. Todo, si alguien lo copia a un servidor |
| **P-5** | `smoke.sh` deja basura en `/auditLog` en cada ejecución | `be00` 📌[C] | Contamina una colección que es evidencia. Declarado y no resuelto |
| **P-6** | La cuenta administrativa de la base la tienen el proveedor y dos personas | `be08` §5.4 | La contención por permisos protege del error, **no de la intención** |

> ⚠️ **P-2 y P-3 son la misma deuda con dos caras, y es la más incómoda del track**: las dos protecciones que sostienen la integridad histórica de LabCore están escritas en la aplicación y **cualquiera con acceso al shell las esquiva**. `be08` §5.4 lo resuelve a medias quitando el permiso de `update` sobre `referenceRanges`; el libro de correcciones sigue sin esa protección.

---

## 4. El criterio que las ordena

No se ordenan por gravedad ni por incomodidad. Se ordenan por un cociente:

> ⚖️ **coste de convivir con ella** ÷ **coste de pagarla** — y el resultado se compara con **la vida restante del sistema**.

- **Coste de convivir** = incidentes al año × coste por incidente, más el riesgo de que uno de ellos sea un hallazgo de auditoría en vez de un ticket.
- **Coste de pagarla** = horas, más el riesgo de tocar un sistema **sin una sola prueba de regresión**, que no es cero y casi nunca se cuenta.

Y la regla que gobierna la comparación, que es la de `be08` §4.4:

> ⚖️ **La respuesta correcta depende de la fecha de decomisión, no de la calidad del código.** Con diez años por delante, casi todas estas deudas se pagan. **Con dos, casi ninguna.** No porque no sean reales —lo son, y están medidas— sino porque el retorno no cabe en el tiempo que queda mientras el riesgo de tocar es inmediato.

---

## 5. El orden, si mañana hubiera presupuesto

Suponiendo ocho horas al trimestre para deuda, que es lo que un equipo de mantenimiento real tiene:

**1.º — La conversión a replica set.** No está en la tabla de arriba porque **no es una deuda del código**: es una decisión de despliegue de 2019. Y aun así es lo primero, por mucho. Dos días de trabajo, arregla la atomicidad de golpe, y desactiva la trampa de `be07` —el `@Transactional` que el manual promete y el despliegue niega—. Se paga en meses, no en años. **Es la única recomendación fuerte del track**, y lo que la bloquea no es técnico: la base es un servicio gestionado y la decisión es de quien paga el contrato.

**2.º — P-2 y P-3: proteger las protecciones.** Quitarle a la cuenta de la aplicación el permiso de `update` sobre `referenceRanges` y sobre `corrections`. Una tarde. Convierte dos reglas que dependen de que todo el mundo se acuerde en dos reglas que el motor impone. **Es la mejor relación coste-beneficio de la lista entera.**

**3.º — BE-7: el bloqueo del detector.** Solo si alguna vez se plantea una segunda instancia. Mientras haya una, es correcto y no hay nada que hacer — pero la rotura sería silenciosa, así que **la mitad del trabajo es dejarlo escrito donde alguien lo vea antes de escalar**, no implementar el bloqueo.

**4.º — P-5: la basura de `smoke.sh`.** Media hora, y limpia una colección que es evidencia. Está por encima de las demás no por su coste sino por dónde escribe.

**5.º en adelante — el resto.** BE-1, BE-2, BE-4, BE-5, BE-6 y BE-8 no llegan al umbral con dos años de vida. Se dejan escritas y se revisan **solo** si la fecha de decomisión se mueve más de un año.

> 🧠 **Y la observación que hay que llevarse de este orden: los dos primeros puestos no son de código.** Uno es un parámetro de arranque y el otro es una línea de permisos. **En un sistema heredado, las deudas más rentables de pagar casi nunca están en el código** — están en la configuración, en los permisos y en el despliegue, que es precisamente donde nadie mira porque no sale en el `git log`. Es la misma lección de `be07` por otro camino.

---

## 6. Las que no se pagan nunca

No "no se pagan ahora": **nunca**. Y cada una con su razón, porque una deuda que se declara impagable sin motivo escrito es una excusa.

| Deuda | Por qué nunca |
|---|---|
| **BE-3** (caos silencioso) | Arreglarla rompe la paridad con el mock, que es lo que hace verificable el reemplazo. **Es fidelidad, no descuido** |
| **BE-5** (la ruta del `SeedRunner`) | El semillero es andamiaje del curso y muere con él. Pagar deuda de código desechable es la definición de trabajo desperdiciado |
| **BE-2** (el origen de CORS literal) | Pagarla **empeora** el sistema: mete en configuración un valor que entonces puede diferir entre ambientes. Es el incidente 19 del track base, comprado voluntariamente |
| Los **14 meses de historia de rangos** | No es una deuda: es una **pérdida**. No hay nada que pagar. Se declara en `IRRECOVERABLE.md` y ahí termina |
| Las **37 órdenes huérfanas** y las **23 cadenas rotas** | Se detectan y se compensan. **Sobrescribirlas destruiría la evidencia**, que es peor que el problema. `be05` §4.4 |

> 🧭 **"No se paga nunca" es una decisión legítima y hay que saber escribirla.** Un mapa de deuda cuyas filas son todas "pendiente" no es un mapa: es una lista de deseos que nadie va a mirar. **Declarar que algo no se arregla, con su motivo, es lo que hace que el resto de la lista se lea.**

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer |
|---|---|
| Entra alguien nuevo y pregunta por qué algo está feo | Búscalo en la tabla del §2. Si no está, **es un bug, no una deuda** |
| Hay ocho horas de presupuesto | El orden del §5. Los dos primeros puestos, y no son de código |
| Alguien propone "limpiar" algo | Mira si está en el §6. Puede que limpiarlo empeore el sistema |
| Se mueve la fecha de decomisión | **Recalcula el §4 entero.** Es lo único que cambia el orden |
| Vas a escribir `IRRECOVERABLE.md` | El §1 da los verbos y el §6 da lo que no tiene arreglo |
| Encuentras una 💸 en una fase que no está aquí | **La fase o el mapa están mal.** Arréglalo, no lo inventes |

---

## ⚠️ Advertencias

**Este mapa caduca.** Está escrito con la decomisión a dos años y con el frontend intacto como restricción. Si cualquiera de las dos cosas cambia, el orden del §5 cambia entero — y el §6 deja de tener la mitad de sus filas. **Ponle fecha de revisión**, que es exactamente lo que nadie hizo con el sistema de 2019.

**Una deuda declarada no es una deuda aceptable.** Que esté en esta tabla significa que alguien la vio, la midió y decidió no pagarla **con una razón escrita**. No significa que esté bien. La diferencia entre las dos cosas es lo que separa un equipo que administra su deuda de uno que la acumula.

**Y las deudas de este mapa son las del backend que tú escribiste**, no las del sistema de 2019. Las de 2019 —cinco formas de documento, el standalone, el `$set` sobre los rangos— no son deuda: son **hallazgos**, están en `MEASUREMENTS.md`, y su destino es `IRRECOVERABLE.md`. Mezclarlos haría ilegibles los dos documentos.

---

## 📚 Referencias

- https://wiki.c2.com/?TechnicalDebt — la formulación original de Ward Cunningham, en cuatro párrafos. Vale la pena leerla porque dice algo que la versión popular perdió: la deuda se toma **a propósito y para entregar antes**, y lo que la vuelve tóxica es no devolverla ni declararla. Es exactamente el criterio del §1.
- https://martinfowler.com/bliki/TechnicalDebtQuadrant.html — el cuadrante prudente/temerario × deliberada/inadvertida. Las filas del §2 son todas del cuadrante **prudente-deliberada**; las de 2019 que este mapa no recoge son, casi todas, prudente-inadvertida, y por eso se llaman hallazgos y no deuda.
- https://www.mongodb.com/docs/v4.0/tutorial/convert-standalone-to-replica-set/ — el procedimiento de la deuda número uno del §5, para costearla con el documento delante en vez de con una estimación de pasillo. ⚠️ La URL apunta a `/v4.0/`, que es la convención del track: el procedimiento se lee para la versión en la que la deuda nació. Si la costeas después de `be07`, cambia el número por el tuyo — el tutorial no es el mismo entre versiones.
- https://martinfowler.com/bliki/StranglerFigApplication.html — el patrón que sostiene el §6: lo que no se paga se rodea. Es el mismo que `be08` §4.2 aplica por read-model.

> ⚠️ Los dos enlaces de `martinfowler.com` son de 2003 y 2009 y siguen vivos en esa URL; si alguno se mueve, el título es suficiente para encontrarlo. La documentación de MongoDB, en cambio, **rota con cada versión**: verifica siempre que el número de la URL es el tuyo.

## 🧪 Ejercicios (6)

1. **Verificación de coherencia.** Haz `grep -n '💸' be0*.md` y comprueba las dos direcciones: que cada 💸 de las fases está en el §2, y que cada fila del §2 existe en su fase. Anota las discrepancias — si hay alguna, una fase está mal.
2. Calcula el cociente del §4 para tres deudas del §2 que elijas: horas de pagarla contra incidentes al año de convivir con ella. Con los números, di a partir de cuántos años de vida restante entrarían.
3. **Priorización argumentada.** Defiende el primer puesto del §5 —la conversión a replica set— ante alguien que sostenga que lo primero es la integridad referencial de las 37 huérfanas. Usa la fecha de decomisión como argumento.
4. **Adversarial.** Elige la fila del §6 que te parezca más discutible y argumenta que **sí** debería pagarse. Si te convences a ti mismo, mueve la fila y escribe por qué.
5. Añade al mapa las deudas que hayas creado tú al hacer los ejercicios del track —el filtro de validación del 🔥 de `be01`, el índice del ejercicio 19 de `be02`, lo que sea que hayas dejado a medias—. Un mapa que solo recoge las deudas del material no es tu mapa.
6. **Escritura.** Toma la tabla del §1 y escribe, en un párrafo por fila, qué le contestarías a alguien de dirección que pregunte *"entonces, ¿lo arreglaron o no?"*. Usa el verbo exacto de `be08` §4.1 en cada una, sin suavizar ninguno. Es el ejercicio que cierra el track.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida, y lo que describe no es código sino decisiones tomadas en las nueve fases. Lo que salga de leerlo se commitea con el prefijo de la fase que corresponda, y las adiciones del ejercicio 5 con `be08: …`, que es desde donde se llega. **El mapa sí se versiona**, y esa es la única forma de que dentro de dos años alguien pueda saber qué se decidió a propósito y qué se dejó por descuido. La convención completa está en [`00-convencion-de-git-y-tags.md`](./00-convencion-de-git-y-tags.md) §10.
