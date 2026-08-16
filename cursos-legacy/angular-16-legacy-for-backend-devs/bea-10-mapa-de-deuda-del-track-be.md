# 📎 Apéndice bea-10 — Mapa de deuda del track BE

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **2 horas**
> Usado por: **be07** · Se escribe **al final**, con las ocho fases cerradas
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido**, aunque es el más corto del track: se entra buscando *"¿esto era a propósito?"* y se sale con la fase que lo declaró y con el motivo por el que sigue ahí.

**Qué problema resuelve:** dejar por escrito **qué quedó feo a propósito** en el backend que acabas de construir, **qué lo vuelve exigible**, y **en qué orden se pagaría**.

> ⚠️ **Este apéndice no tiene hermano en el track base, y conviene saberlo.** El track base **no consolida su deuda en ningún sitio**: cada fase declara sus 💸 en su cuerpo y sus 📌 al cierre, y ahí se quedan (`a12` de ese curso es `a12-arm64-m1.md`, Apple Silicon, no un mapa de deuda). Así que este documento **no copia una estructura existente: la inventa**.

**Qué queda fuera:** **las deudas del track base.** No se listan ni se resumen aquí — viven repartidas en el 💸 de cada fase y en su 📌 de cierre, y duplicarlas crearía una segunda fuente de verdad para algo que ese track ya sostiene. Cuando haga falta citar una, se nombra la fase que la declaró y se enlaza ese capítulo.

---

## Índice

- [La deuda insignia: el runtime EOL](#la-deuda-insignia-el-runtime-eol)
- [El inventario, fase por fase](#el-inventario-fase-por-fase)
- [Las que no se pagan nunca, con su razón](#las-que-no-se-pagan-nunca-con-su-razón)
- [El criterio que las ordena](#el-criterio-que-las-ordena)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-6)

---

## La deuda insignia: el runtime EOL

Va primera y con apartado propio porque **no es una deuda que se pague: es una que se documenta, se compensa y se escala.**

`certcore-api` corre sobre PHP 7.4.33, sin soporte de seguridad desde el **28 de noviembre de 2022**, sobre una imagen congelada el **15 de noviembre de 2022**, con un framework —Lumen 5.8.13— cuya restricción `php ^7.1.3` **excluye PHP 8**. Subir el runtime no es subir el runtime: es el **trasplante de bootstrap** que midió [`be06`](be06-la-reescritura-a-medias.md).

| | |
|---|---|
| **Declarada en** | be01 §4 (el ticket SEC-2291) |
| **Por qué no se paga** | Porque pagarla es la opción 2 del *assessment*, y esa decisión es de negocio |
| **Compensación actual** | Reducción de superficie, red, `APP_DEBUG=false`, SQL crudo revisado — [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) |
| **Cómo se gestiona** | Ficha de riesgo `R-01` con **dueño y fecha de revisión** |
| **Dónde se decide** | [`be07`](be07-el-assessment-de-riesgo.md) |

> 🧭 **Una deuda que no se puede pagar sin una decisión de negocio no es un pendiente de ingeniería: es un riesgo con dueño.** La diferencia entre las dos cosas son dos campos —quién la acepta y hasta cuándo— y es lo único que separa "aceptada" de "escondida".

---

## El inventario, fase por fase

Cada 💸 que aparece aquí existe **literalmente** en el cuerpo de una fase, y cada 💸 de las fases aparece aquí. Si encuentras una que no cuadra, no la inventes ni la borres: **significa que una fase está mal**.

| # | Deuda | Declarada en | ¿Se paga? | Dónde / por qué no |
|---|---|---|---|---|
| **B1** | El contrato **no tiene paginación**: `GET /inspections` devuelve todo | be00 §5.3 | ✅ **Pagada** | **be03**, con el frontend intacto: sin `_page` se sigue recibiendo todo |
| **B2** | Datos fijos en una clausura anónima en `routes/web.php` | be01 §5.6 | ✅ **Pagada** | **be03**. La factura: `git diff be-fase-01-… be-fase-03-… -- server/routes/web.php` |
| **B3** | El inventario de estratos vive en un `.md` y nada lo verifica | be02 §5.3 | ❌ **Aceptada** | Un pipeline de análisis estático no se justifica en un sistema en mantenimiento sin fecha de decomisión decidida |
| **B4** | `certificates.status` es una **columna**, no un derivado | be03 §5.1 | ⚠️ **Contenida** | **be05**: servido desde una vista. La columna sigue existiendo (ver **B8**) |
| **B5** | Fechas en `timestamp` **sin zona**, con datos que traen offset `-05:00` | be03 §5.1 | ❌ **Diagnosticada y costeada, sin pagar** | **be04** §5.5 la diagnostica; convertir obliga a **elegir una zona de origen irreversible** ([`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md)) |
| **B6** | `inspections` apunta a `(template_id, template_version)` **sin clave foránea** | be03 §5.1 | ✅ **Pagada** | **be05**: foránea compuesta en `NOT VALID`, sin tocar el histórico |
| **B7** | Dominios sin `CHECK`: `status`, `severity`, `type` son texto libre | be03 §5.1 | ❌ **Aceptada** | El frontend ya valida esos valores, y meter cuatro restricciones a la vez sobre datos viejos diluiría la lección de be05 |
| **B8** | La columna `certificates.status` **no se borra** aunque ya no se lea | be05 §5.4 | ⚠️ **Diferida** | **be06** le dio pruebas y camino oficial; es el **primer candidato de limpieza** cuando be07 dé dirección |
| **B9** | Respuestas huérfanas dentro de `answers` (`jsonb`): **no se pueden restringir** | be05 §📌 | ❌ **Aceptada** | Dentro de un documento `jsonb` no hay restricciones. Normalizar `items`/`answers` es una reescritura de esquema que ninguna fase justifica |
| **B10** | **Dos caminos vivos** para los mismos recursos; se decide el oficial y no se borra el otro | be06 §5.1 | ⚠️ **Condicional** | Se paga si be07 elige *terminar la migración*; queda aceptada si elige *estrangular* o *esperar* |
| **B11** | `tools/probe.php` usa `eval()` | be01 §📌 | ⚠️ **Contenida** | Correcta en `tools/`, inaceptable en el artefacto de despliegue. Excluirla es configuración, no confianza ([`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md)) |
| **B12** | El archivo heredado con `exit` **se salta la cadena de middleware** entera | be02 §5.1, be06 §📌 | ❌ **Aceptada** | Documentada. Rompe cualquier prueba que lo toque; candidato de limpieza junto con **B10** |
| **B13** | `withFacades()` queda **apagado** y la decisión no vive en el código | be01 §5.3 | ❌ **Aceptada, por diseño** | Encenderlos cambiaría el arranque de un sistema de ocho años cuyo código heredado se acostumbró a vivir sin ellos |
| **B14** | El sembrador **no es idempotente** | be03 §📌 | ⚠️ **Diferida** | **be06**, junto con la estrategia de pruebas, que siembra y limpia en cada ciclo |
| **B15** | La cobertura de pruebas **miente** en este sistema: con dos caminos vivos mide el doble de lo mismo | be06 §📌 | ❌ **Aceptada** | Se documenta en vez de perseguir un porcentaje. Desaparece sola si se resuelve **B10** |
| **B16** | La restricción de be05 queda **`NOT VALID`**: 88 filas históricas siguen violándola | be05 §5.3 | ❌ **Aceptada, con firma** | Validar exige decidir qué se hace con esas filas, y en un dominio regulado el histórico no se reescribe. `VALIDATE` queda documentado y sin ejecutar |

**Cuatro pagadas, cinco contenidas o diferidas, siete aceptadas.** Ése es el estado real del sistema al cerrar el track, y es un resultado, no un fracaso: **un backend heredado con siete deudas aceptadas y escritas está mejor gestionado que uno con cero deudas declaradas y las mismas por debajo.**

---

## Las que no se pagan nunca, con su razón

Tres merecen destacarse porque la tentación de pagarlas es constante:

**B7 — los dominios sin `CHECK`.** Parece barato y no lo es: cada `CHECK` sobre una columna de texto libre con ocho años de datos es el procedimiento completo de [`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md), censo incluido, cuatro veces. Y el beneficio es bajo, porque el frontend ya restringe esos valores en origen. **Se acepta y se escribe.**

**B13 — los facades apagados.** Es la deuda que más gente querría "arreglar" en su primera semana, y arreglarla **empeora el sistema**: enciende treinta clases nuevas en todo el proyecto y crea una segunda convención viva junto a la que ya se usa. La autopsia está en be01 §5.7.

**B16 — la restricción sin validar.** Es la deuda más visible del track y la que menos hay que tocar: `NOT VALID` **no es un estado transitorio por definición**, y puede quedarse años siempre que esté declarada y con dueño. El día que alguien decida qué pasa con las 88 inspecciones huérfanas, se valida en una tarde.

> 🧠 **Una deuda aceptada con su razón escrita no es lo mismo que una deuda olvidada, aunque el código sea idéntico.** La diferencia está en este documento, y es la diferencia entre un sistema gestionado y uno abandonado — que es, exactamente, la tesis del track.

---

## El criterio que las ordena

No se ordenan por tamaño ni por antigüedad. Tres preguntas, en este orden:

1. **¿Crece sola?** Una deuda cuyo coste aumenta sin que nadie la toque va primera. **B1** crecía con cada inspección nueva (por eso se pagó), y la insignia —el runtime EOL— crece cada mes que pasa.
2. **¿Bloquea otra cosa?** **B6** bloqueaba cualquier garantía sobre la invariante, así que se pagó aunque no molestara a diario.
3. **¿Su coste de pago crece con el tiempo?** **B10**, la reescritura a medias, se encarece cada mes que siguen vivos los dos caminos. Las que no crecen —**B7**, **B13**— pueden esperar indefinidamente, y decirlo es más honesto que ponerlas en una lista que nadie va a atender.

Y el criterio que manda sobre los tres, el mismo de be07:

> 🧭 **El orden de pago depende de la fecha de decomisión.** Con dos años por delante, sólo se paga lo que crece solo. Con diez, se paga lo que bloquea. **Una lista de deuda sin fecha de decomisión es una lista de deseos.**

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer |
|---|---|
| *"¿Esto era a propósito?"* | Busca en la tabla. Si no está, **no era a propósito**: es un hallazgo |
| Vas a costear el *assessment* (be07) | Cada fila con su fase de origen es un insumo; las 🔴 aceptadas son las que alimentan la opción 4 |
| Alguien propone "limpiar deuda" en un sprint | Aplica el criterio de orden: sólo lo que crece solo o bloquea algo |
| Encuentras una 💸 en una fase que no está aquí | **Ni la inventes ni la borres**: una de las dos fuentes está mal. Arregla la fase |
| Encuentras aquí una que no está en ninguna fase | Lo mismo, al revés |
| Vas a cerrar el track | Corre el ejercicio 1: las dos listas tienen que cuadrar exactamente |

---

## ⚠️ Advertencias

**Este documento envejece a la primera modificación del código.** Es el mismo defecto que **B3** —un inventario en un `.md` que nada verifica—, y se acepta por la misma razón. Lo que lo mantiene vivo es que be07 lo consume: mientras alguien escriba el *assessment* a partir de aquí, esta tabla se revisa.

**Una deuda listada no es una deuda gestionada.** Sólo las que tienen dueño y fecha de revisión lo están, y en este track ésa es exactamente una: la insignia, vía la ficha `R-01`. Las otras quince están **declaradas**, que es un peldaño menos y hay que decirlo así.

**No listes aquí deudas del track base.** Viven en sus fases. Si necesitas citar una —la ⭐ 3 de la Fase 7, el `status` de la Fase 10—, nómbrala y enlaza su capítulo.

---

## 📚 Referencias

- *Technical Debt* (Kruchten, Nord, Ozkaya, Addison-Wesley, 2019) — la distinción entre deuda que se paga, que se contiene y que se documenta. Es el marco de la tabla de arriba.
- https://martinfowler.com/bliki/TechnicalDebtQuadrant.html — el cuadrante de deuda deliberada/inadvertida y prudente/imprudente. Casi todo lo de este track es **deliberada y prudente**, y merece la pena saber por qué eso importa.
- [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) — la ficha de riesgo `R-01`, que es la forma gestionada de la deuda insignia.
- [`be07`](be07-el-assessment-de-riesgo.md) — donde estas dieciséis filas se convierten en cuatro opciones costeadas.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos.

---

## 🧪 Ejercicios (6)

Todos de priorización argumentada. Ninguno es de código.

1. **Comprobación de cierre.** Extrae con `grep` todas las 💸 de las ocho fases y crúzalas con esta tabla. Tienen que cuadrar **exactamente**, en los dos sentidos. Si no cuadran, arregla la fase o esta tabla, y di cuál estaba mal.
2. Ordena las dieciséis por el criterio de §"El criterio que las ordena", **primero** con una fecha de decomisión de dos años y **después** con una de diez. Compara las dos listas: ¿cuántas cambian de posición?
3. **Diagnóstico.** Elige una de las "aceptadas" y construye el mejor argumento para pagarla. Después construye el mejor argumento para no hacerlo. Decide, y escribe qué dato te haría cambiar de opinión.
4. Para cada deuda **contenida** (**B4**, **B8**, **B11**), escribe qué pasaría si la contención desapareciera —si alguien borra la vista, si se despliega `tools/`—. ¿Cuál de las tres es más frágil?
5. **Diagnóstico.** Convierte una deuda declarada en una deuda **gestionada**: elige una, escríbele la ficha de riesgo completa de [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) con dueño y fecha de revisión, y decide a quién se la mandarías.
6. **Diagnóstico adversarial.** Alguien propone un sprint de dos semanas "de deuda técnica" para resolver todo lo que se pueda de esta tabla. Escribe la respuesta en dos párrafos: cuáles de las dieciséis se pueden cerrar de verdad en dos semanas, cuáles **no se deben** tocar aunque se pueda, y por qué un sprint de deuda sin fecha de decomisión decidida suele terminar en una tabla idéntica con otros números.

---

> 🏷️ **Este apéndice no lleva tag propio.** Se escribe al cerrar el track y se commitea con el prefijo de la última fase (`be07: …`). La comprobación del ejercicio 1 —que las dos listas cuadren— conviene correrla **antes** de etiquetar `be-fase-07-el-assessment-de-riesgo`: si no cuadran, el track no está cerrado. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
