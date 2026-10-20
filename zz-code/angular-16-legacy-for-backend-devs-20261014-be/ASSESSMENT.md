# ASSESSMENT — certcore-api · 14/10/2026

> Fase be07. Decide qué hacer con `certcore-api` a partir de las cifras medidas en be00–be06. Cada cifra dice de qué
> fase sale. Lo que no sale de ninguna fase está marcado **[inventado]** (cifra de la lección o suposición) o **[A]**
> (lo tiene que aportar quien decide).
> Las marcas [A] se cerraron el 20/10/2026 sin inventar cifras: lo que es del alumno quedó como «no aplica».

---

## 1. Resumen ejecutivo

La recomendación depende de una fecha que no está en el código: **cuándo se decomisiona el sistema**. Con decomisión en
menos de dos años, conviene **no reescribir**: congelar, contener y firmar el riesgo del runtime (opción 4). Con
decomisión entre dos y cinco años, conviene **estrangular por endpoint** (opción 3). Sólo con decomisión de más de cinco
años tiene sentido **reescribir** (opción 2). Hoy el sistema corre sobre PHP 7.4 sin parches; esa es la única urgencia técnica,
y se decide en la sección 5.

---

## 2. Estado actual (con fuente por fila)

| Dato | Valor | Fase de origen |
|---|---|---|
| Runtime PHP | 7.4.33 | be01 (`/health`) |
| Framework | Lumen 5.8.13 en `composer.lock`; reporta 5.8.12 por código | be01 |
| Avisos de seguridad en las dependencias | 7 avisos en 4 paquetes; `firebase/php-jwt 5.5.1` e `illuminate/view 5.8.36` bloqueados y forzados | be01 (`composer install`, `composer audit`) |
| Rutas servidas | 26, todas en el camino nuevo | be06 §1 |
| Caminos vivos | 2 recursos con dos caminos: `/templates` y `/findings` (el viejo en `/legacy/…`) | be06 §1 |
| Pruebas | 12, en verde, 27 aserciones, 217–308 ms | be06 §4, §7 |
| Contrato verificable | `smoke.sh` 26/26 contra el backend PHP y contra cada escalón de PostgreSQL | be00, be03, be04 |
| Tablas | 7 + `migrations` | be03 |
| Huérfanas de inspección | 88 de 4005 (sintético, por diseño del generador) | be05 §3 |
| Certificados que mienten | 1 de 2 | be03/be05 (`HALLAZGOS.md`, vista) |
| Versión de PostgreSQL | 16.9 en producción del laboratorio; cadena 9.6→16.9 probada | be04 |
| Riesgo de dependencia abierto | Dos paquetes con avisos abiertos en el lock | be01 |

**Fuentes que no son de este track:** la fecha de fin de soporte de PHP 7.4 (SEC-2291 en la lección be01) **no se ha
verificado** en esta fase. La decomisión, el número de empleados y el presupuesto **no están en ningún artefacto**: no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026).

---

## 3. Riesgos

### 3.1 R-01 · Runtime sin parches de seguridad

Ficha completa en la §5.1 de este documento (la del `bea-08`, con sus siete campos).

### 3.2 R-02 · Framework sin calendario de soporte

Lumen 5.8 es la última línea de su rama. Riesgo: un aviso de seguridad en `illuminate/*` no tendrá parche en esa rama.
**Medido:** `composer audit` ya marca `illuminate/view 5.8.36` con un aviso abierto. Probabilidad: [inventado] media;
alcance: toda la API.

### 3.3 R-03 · Deuda de plantilla · el conocimiento no se amortiza

**Medido:** la familiaridad falsa tiene cuatro familias (be01 §5.7; 4 bugs reproducidos con salida literal). Dos de ellas
(`toSql()` sin `withEloquent`, los facades apagados) tienen tiempo de descubrimiento alto. Rotaciones: **3 en ocho
años [inventado, lección be02 §5.5]**, permanencia media 18 meses **[inventado, lección]**.

### 3.4 R-04 · Reescritura a medias · dos caminos vivos

**Medido:** dos recursos con dos caminos vivos (`/templates` y `/findings`), dos rutas viejas en `/legacy/…` (be06 §1). Ya
produjeron tres incidentes reproducidos: be-01 (caché que el camino nuevo no invalida), be-03 (orden) y be-11 (500 frente a
422). El camino oficial es el nuevo para los seis recursos, firmado por el autor el 15/10/2026.

### 3.5 R-05 · Invariantes contenidas pero no validadas

**Medido:** la FK compuesta está puesta `NOT VALID`; las 88 filas violadoras siguen ahí. **Decisión firmada el 15/10/2026:** el
histórico no se toca y `VALIDATE` no se ejecuta. Riesgo que queda, y que be-10 ya mostró: todo proceso que reinserte filas
viejas choca con la restricción.

---

## 4. Opciones

Todas con el mismo formato: **coste · plazo · qué se rompe mientras · qué riesgo elimina · qué riesgo deja**.

### 4.1 Opción 1 — Quedarse y formar

- **Coste inicial:** bajo. **Coste recurrente:** alto y repetido. Por rotación: [inventado] el coste de onboarding es
  `(a) × (c) × (1 − (b))`, y (a), (b), (c) son del autor (be02 §5.5). **No se calcula aquí.**
- **Plazo:** semanas hasta ver algo.
- **Qué se rompe mientras:** nada, pero el conocimiento se pierde con la rotación.
- **Elimina:** nada de R-01 ni R-02. **Al contrario**, aumenta R-03 con cada rotación.
- **Deja:** R-01, R-02, R-03.
- **Lo que casi nadie pone:** se intentó tres veces y funcionó 18 meses cada vez **[inventado, lección be07 §5.2]**.

### 4.2 Opción 2 — Reescribir a algo aburrido y sostenido

- **Coste inicial:** alto. **No está calculado aquí:** la lección pide un equipo de cuatro personas y seis meses
  **[inventado, informe de la consultora en be-12]**, que no se han medido.
- **Plazo:** meses o años. **Riesgo de la propia opción:** que no termine (la reescritura a medias ya existió; be06).
- **Qué se rompe mientras:** el sistema viejo y el nuevo divergen; be06 §4 dice que ese intermedio es el más caro.
- **Elimina:** R-01, R-02, en gran parte R-03.
- **Deja:** el riesgo de la migración en sí, y el de que el equipo nuevo tampoco tenga pruebas hasta que se escriban.

### 4.3 Opción 3 — Estrangular por endpoint

- **Coste inicial:** medio, repartido en endpoints. **Coste por endpoint:** [inventado] una tanda de endpoint similar a un
  recurso completo de be03 (4–6 rutas + pruebas). Medido: be03 fue la construcción completa de 26 rutas y 7 tablas; con el
  contrato `smoke.sh` y las 12 pruebas, un endpoint se verifica con el mismo juez.
- **Plazo:** semanas por endpoint. **Se puede parar en cualquier momento** y lo hecho sigue sirviendo.
- **Qué se rompe mientras:** dos sistemas en paralelo durante la transición (vivir con dos sistemas).
- **Elimina:** R-01 parcialmente y de forma creciente; R-03 parcialmente.
- **Deja:** R-01 en lo que no se estrangule todavía, y el coste de mantener el proxy.
- **Condición previa, ya cumplida:** un contrato verificable (`smoke.sh`, 26/26).

### 4.4 Opción 4 — No hacer nada y documentar el riesgo

- **Coste inicial:** cero. **Recurrente:** constante, y creciendo con los incidentes del cuaderno (be-01…be-12).
- **Plazo:** inmediato.
- **Qué se rompe mientras:** nada nuevo; lo que ya se rompe sigue igual.
- **Elimina:** nada.
- **Deja:** R-01, R-02, R-03, y el peligro de que nadie firme la aceptación.
- **Gana si:** la decomisión está cerca, el sistema no crece, el riesgo está compensado y **hay una firma con nombre y fecha**.

---

## 5. Recomendación, condicional a la fecha de decomisión

### 5.1 R-01 · ficha completa (de `bea-08`)

- **Qué es:** `certcore-api` corre sobre PHP 7.4.33, sin soporte de seguridad desde el 28/11/2022 **[fecha de la lección; no
  verificada en esta fase]**.
- **Qué podría pasar:** una vulnerabilidad publicada del runtime no tendrá parche. La exposición depende de qué procese
  entrada externa: toda la API procesa entrada externa.
- **Probabilidad y alcance:** [inventado] probabilidad anual de un aviso crítico sin parche en el runtime: media. Alcance:
  los 26 endpoints y la base. **Este número es criterio, no medición.**
- **Qué se ha hecho para compensar** (medido): 26 rutas servidas, la base sin puerto publicado, PostgreSQL 16.9 (actualizado),
  `certcore-api` sin proxy ni WAF (no hay), SQL crudo revisado (6 consultas, todas con parámetros o literal fijo; `SQL-CRUDO.txt`).
  **Los 7 avisos de `composer audit` no tienen compensación activa.**
- **Qué haría falta para eliminarlo:** subir a PHP 8, que implica el trasplante de bootstrap (`SUPERFICIE.md` §7). Coste
  **[inventado]**: el de la migración completa, que no se calcula aquí.
- **Quién lo acepta y hasta cuándo:** **Hernando Gil, gerente de sistemas de CertCore.** Aceptado el **15/10/2026**; revisión el
  **15/04/2027** (seis meses). Personaje de la historia del curso (aparece en be-12); lo decidió el autor del curso.

### 5.2 Escenarios

| Decomisión | Respuesta | Por qué |
|---|---|---|
| **Menos de dos años** (escenario A, p. ej. 2028-10) | **Opción 4**, con R-01 aceptada y firmada | Reescribir no termina a tiempo. El riesgo está compensado y la decomisión está cerca. |
| **Entre dos y cinco años** (escenario B, p. ej. 2030-10) | **Opción 3**, estrangulando los endpoints más expuestos primero | Se puede parar; lo hecho sirve; el juez (`smoke.sh`) ya existe. |
| **Más de cinco años** (escenario C, p. ej. 2034-10) | **Opción 2**, reescritura, precedida de la opción 3 para los primeros endpoints | Hay tiempo para amortizar la reescritura; la deuda de plantilla justifica un stack con mercado. |

Los escenarios son ilustrativos: el umbral de dos y cinco años está en la tabla de §6 de la lección (be07 §5.3), no
calculado aquí. **La fecha real:** no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026); por eso la recomendación es condicional.

**Recomendación por defecto, si no hay fecha:** opción 3, porque es la única que se puede parar sin perder lo hecho. No es
una respuesta de largo plazo; es la que no compromete a nada mientras la fecha no existe.

---

## 6. Qué NO recomendamos, y por qué

- **«Reescribirlo en Node».** Cambia el lenguaje y el arranque; no cambia el contrato ni la invariante. Las mismas
  decisiones (FK compuesta, estado derivado, sin validación) siguen pendientes, y se añade una familia de bugs nueva. La
  lección be01 mostró que la familiaridad falsa es el coste, no la sintaxis.
- **«Subir sólo el PHP».** Lumen 5.8 no corre sobre PHP 8 sin cambios (bootstrap, facades, configuración). Es el trasplante
  de be06 disfrazado de actualización de versión.
- **«Meterle microservicios».** Con 26 rutas, 7 tablas y un solo equipo, la división en servicios añade red, despliegues
  y contratos entre servicios sin que el problema actual lo pida.

---

## 7. Qué hace falta para decidir

| Qué | Quién | Para cuándo |
|---|---|---|
| Fecha de decomisión del sistema | — no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026) | — |
| Firma de la aceptación de R-01 | ✅ Hernando Gil, 15/10/2026 | Revisión el 15/04/2027 |
| Firma del camino oficial por recurso (be06 §1) | ✅ El nuevo, para los seis recursos (15/10/2026) | — |
| Decisión sobre las 88 filas y `VALIDATE` (be05 §7) | ✅ No se tocan; no se valida (15/10/2026) | — |
| Coste de la migración a Laravel (be06 §8) | — no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026) | Sólo si se elige la opción 2 |

---

## 8. Anexo · dónde Lumen de verdad ganó

En 2016, para una empresa mediana sin equipo de software y sin ganas de pagar licencias, Lumen era una elección sensata:
corría en cualquier hosting, arrancaba rápido y compartía casi todo con Laravel. Esta tabla tiene números en las dos columnas.

| Lo que ahorró (2016–2019) | Lo que costó (2019–2026) |
|---|---|
| Licencias de Windows Server y SQL Server: **USD 5.000 el primer año [inventado, lección be07 §5.4]**. Hosting PHP: **USD 30 al mes [inventado]** | Tres rotaciones sin amortizar **[inventado, be02 §5.5]** |
| Un programador que venía de .NET levantó la API en semanas **[según la lección]** | 26 rutas y 7 tablas que hubo que reconstruir a mano en be03 (`FALSA-FAMILIARIDAD.md`) |
| Sintaxis conocida para los primeros endpoints | Cuatro familias de bugs de familiaridad falsa, reproducidas en be01 |
| Arranque ligero para una API pequeña | Un trasplante de bootstrap que hoy costaría más que la propia API (`SUPERFICIE.md` §7) |
| — | El salto de PostgreSQL 9.6 a 16.9 se recorrió sin ninguna rotura en el código (`EVIDENCIA-VERSIONES.md`): **la elección de Lumen no fue el problema de la base** |

> El pecado no fue elegir Lumen. Fue elegirlo para un servicio, acertar, y que nadie volviera a decidir.

---

## 9. El informe de la consultora (be-12), desmontado

El informe recomienda reescribir en seis meses, con cuatro personas, y dice que el sistema es inmantenible. Cada afirmación,
contrastada con lo medido:

| Afirmación del informe | Veredicto | Evidencia |
|---|---|---|
| Runtime PHP 7.4 sin soporte de seguridad | ✅ Cierta (fecha no verificada aquí) | §2 |
| Lumen 5.8 discontinuado | ⚠️ Probable, no verificada en esta fase | §3.2 |
| Sin pruebas automatizadas | ❌ Falsa desde be06 | 12 pruebas en verde |
| Sin CI | ✅ Cierta: no hay pipeline | no hay `.github/` ni equivalente |
| Sin documentación de arquitectura | ❌ Falsa | `ESTRATOS.md`, `CONTRACT.md`, `INVARIANTES.md`, `SUPERFICIE.md` |
| Código heterogéneo, al menos cuatro estilos | ✅ Cierta, con matiz | `ESTRATOS.md`: 4 etiquetas; 6 de 11 archivos son `neutro` o mezcla |
| Integridad referencial incompleta | ⚠️ Cierta hasta be05; hoy parcial | FK `NOT VALID`; 88 huérfanas |
| «Inmantenible» | ❌ Juicio, no medido. Lo medido dice lo contrario | `smoke.sh` 26/26, suite 201 ms |
| Reescritura en 6 meses, 4 personas | Sin fuente en el informe | be06 §4: el intermedio es el más caro |
| Inversión `<cifra>` | Vacío en el informe | — |

**Lo que el informe acierta** (y hay que aceptarlo para que el documento sea creíble): PHP 7.4, sin CI, y las cuatro
formas de escribir en `inspections`. **Lo que no sostiene:** «inmantenible», «sin pruebas» y «sin documentación».

---

## 10. Objeciones de quien prefiere reescribir, respondidas aquí

- **«Un sistema así no se puede mantener».** Se puede: 26/26 en el juez del contrato, 12 pruebas en verde y un juez de contrato en
  26/26. Lo que cuesta es entender el código sin formación; eso es R-03, y una reescritura no lo quita: lo traslada al
  equipo nuevo.
- **«Reescribir sale más barato a largo plazo».** Puede. El cálculo lo hace la fecha de decomisión (§5.2). Con decomisión
  en menos de dos años, no.
- **«Así no se atrae talento».** Cierto para la contratación. Por eso la opción 3 mantiene el stack y reduce el
  problema de a poco: no requiere contratar a nadie que venga a aprender Lumen en el primer año.
- **«El riesgo de seguridad es urgente».** Sí, y se atiende ya: R-01 se acepta con firma o se reduce con la opción 3. No
  requiere reescribir para empezar.

---

## 11. Honestidad sobre lo que no está medido

- Las cifras de dinero, rotación y tamaño de equipo son **de la lección** o **inventadas**, y están marcadas así.
- La probabilidad de R-01 y R-02 es **criterio**, no medición.
- La fecha de fin de soporte de PHP 7.4 no se ha verificado contra una fuente oficial en esta fase.
