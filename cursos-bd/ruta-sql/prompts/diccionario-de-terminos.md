# 📖 Diccionario de términos
## Ruta SQL

> **Qué es este documento:** qué palabra se usa para cada concepto en la prosa del curso, qué se
> queda en inglés, qué se queda en el español de Alameda y cómo se nombra el código del dominio. Es la
> herramienta de quien escribe; para el lector, el diccionario se publica en `a07` (diccionario de
> traducción y glosario), que crece con el curso.
> **Origen:** agregado el 06/10/2026, antes de T0, en la revisión contra los lineamientos de
> producción del repositorio. Junta lo que ya fijaban la guía §3 y §5, el alcance §7 y el glosario
> mínimo de la historia §1. **No cambia nada**: si algo de aquí contradice a la guía, manda la guía y
> se corrige este documento.
> **Precedencia:** por debajo del [alcance](alcance-del-proyecto.md) y de la
> [guía](guia-de-estilo-y-convenciones.md); al lado del [contrato de nombres](contrato-de-nombres.md),
> que fija los identificadores del laboratorio.
> **Vigencia:** 2026-10-06.

---

## 1. 🧭 Cómo se decide

Cuatro reglas, de la guía §3:

1. **El término del oficio se queda en inglés cuando es el nombre real de la cosa**: el que el lector
   lee en la documentación del motor y en sus mensajes de error.
2. **Lo que tiene traducción asentada se escribe en español.**
3. **Los términos del negocio se quedan en el español de Alameda**, aunque el lector sea de otro país:
   son los de la historia, y `a07` los traduce.
4. **No se inventa vocabulario.** Si una palabra no está aquí ni en la guía, se busca cómo la escribe
   la documentación oficial del motor y se agrega aquí antes de usarla.

---

## 2. ✍️ Lo que se queda en inglés y lo que se traduce

**Se quedan en inglés:** *page split*, *fillfactor*, *heap*, *clustered index*, *write skew*, *lost
update*, *phantom read*, *deadlock*, *snapshot isolation*, *bloat*, *vacuum*, *undo*, *redo*,
*outbox*, *upsert*, *keyset pagination*, *parameter sniffing*, *healthcheck*, *digest* y *tag*.

**Se escriben en español:** índice, consulta, plan (de ejecución), bloqueo, aislamiento,
particionado, clave foránea, clave primaria, restricción, transacción, esquema, vista, secuencia,
punto de rotura, línea base, apuesta, veredicto.

- **Los niveles de aislamiento** se escriben con su nombre SQL en mayúsculas cuando se habla del
  estándar (`READ COMMITTED`, `SERIALIZABLE`), y en prosa cuando se habla del comportamiento real de
  un motor, que es lo que el Bloque III mide.
- **"Motor"** es el producto (Postgres, MySQL, Oracle, SQL Server); **"base"** es la base de datos de
  Alameda. Una fase no dice "la base" cuando habla del producto.

---

## 3. 🏥 El español de Alameda

Términos del negocio, tal como los usa la historia. `a07` publica su equivalente en otros países.

| En la prosa | Qué es | Entidad |
|---|---|---|
| protocolo | la orden que entra al laboratorio, y su número | `lab_order` (`protocol_number`) |
| práctica | lo que se solicita y se factura, del nomenclador | `practice`, `order_item` |
| determinación | lo que mide un equipo, con su unidad | `analyte` |
| resultado | el valor informado de una determinación en un protocolo | `result` |
| obra social, prepaga | quien paga la cobertura | `payer` |
| convenio | el acuerdo de precios entre un pagador y el laboratorio | `agreement` |
| nomenclador, UB | la lista oficial de prácticas y su unidad de valor | `practice` (catálogo versionado) |
| débito | lo que la obra social descuenta por una práctica mal presentada | — |
| sede, centro de extracción | dónde se atiende o se toma la muestra | `site` |
| médico derivante | quien pide el análisis | `physician` |
| turno | la cita | `appointment` |
| DNI, Libreta Cívica, pasaporte | documentos de identidad, con tipo, país y número | `identity_document` |
| la caja | el volcado en CSV del sistema heredado | esquema `legacy` |

---

## 4. 💻 El código del dominio

### 4.1 Las entidades

Fijas en todo el curso, en inglés, en `snake_case` y en singular en los tres motores (guía §5, D10),
con palabras completas: `patient`, `identity_document`, `lab_order`, `order_item`, `practice`,
`analyte`, `result`, `reference_range`, `specimen`, `payer`, `agreement`, `site`, `physician`,
`invoice`, `appointment`. Qué es cada una está en el alcance §7. **Ninguna fase las renombra.**

### 4.2 Convenciones

- Restricciones e índices: `<tabla>_<columnas>_<sufijo>`, con los sufijos de Postgres (`pkey`, `key`,
  `fkey`, `check`, `idx`, `excl`).
- SQL: palabras clave en MAYÚSCULAS, identificadores en minúsculas, alias cortos con sentido (`p` para
  `patient`). Un bloque de un motor concreto lo dice en su primera línea (`-- mysql`).
- El esquema `legacy` conserva los nombres originales de la caja, entre comillas donde haga falta
  (guía §17, excepción 5).
- Comentarios de código en español con tildes (guía §17, excepción 8).

---

## 5. 🚫 Calcos y falsos amigos

| No | Sí | Por qué |
|---|---|---|
| ordenador, vale, vosotros | computadora, de acuerdo, ustedes | español latinoamericano neutro (`CLAUDE.md`) |
| *performance* en la prosa | rendimiento | hay traducción asentada |
| "la base es lenta" | qué consulta, con qué plan y cuántas filas | la F14 entera existe para desmontar esa frase |
| voseo en los personajes | tuteo, también en los diálogos | guía §2: la historia pasa en Córdoba, pero se escribe en tuteo |

---

## 6. ➕ Cómo se agrega un término

1. Se busca aquí, en la guía §3 y en `a07`.
2. Si no está, se mira cómo lo escribe la documentación oficial del motor de la fase.
3. Se agrega aquí, con la fase que lo estrena, y la fase lo publica en `a07`.
