# INVARIANTES.md — be05: la invariante que nadie sostenía

> Fase be05. Escribe la invariante, demuestra que la base no la sostenía, mide el censo de violaciones, compara
> tres salidas y deja puesta la recomendada. Medido el 14/10/2026 a las 19:10 (-05) sobre PostgreSQL 16.9.

---

## 1. La invariante, en una línea

> **Una inspección se lee siempre contra la versión de plantilla que estaba vigente cuando se ejecutó.**

Formal: para toda inspección `i`, existe una plantilla `t` con `(t.template_id, t.version) = (i.template_id, i.template_version)`
y `t.valid_from ≤ fecha(i.started_at) ≤ t.valid_until` (con `valid_until` nulo como «sin fin»).

**Consecuencia de negocio.** Un certificado afirma que el activo cumplía la norma vigente en la fecha de la inspección. Si la
inspección se re-renderiza con otra versión, el documento afirma algo que nunca se comprobó.

---

## 2. Quién la sostiene: nadie en la base

```
\d inspections
...
Foreign-key constraints:
    "inspections_asset_id_foreign" FOREIGN KEY (asset_id) REFERENCES assets(id)
Referenced by:
    TABLE "certificates" CONSTRAINT ... REFERENCES inspections(id)
    TABLE "findings" CONSTRAINT ... REFERENCES inspections(id)
```

Antes de be05, `inspections` no tenía **ninguna** clave foránea contra `templates`. Ni `inspections_pkey` ni índices sobre
`(template_id, template_version)`. Las dos columnas son `varchar` y `integer` sueltos. Lo sostienen, en orden:

- **El frontend:** `resolveTemplateVersion` la respeta al pintar. Es una lectura correcta, no una garantía.
- **El backend:** `InspectionController::store` guarda `templateId` y `templateVersion` tal como llegan. Es una escritura correcta, no una garantía.
- **La base:** nada.

---

## 3. El censo de violaciones

```sql
SELECT count(*) AS violaciones,
       count(*) FILTER (WHERE i.status IN ('approved', 'completed')) AS con_certificado_posible
FROM inspections i
LEFT JOIN templates t ON t.template_id = i.template_id AND t.version = i.template_version
WHERE t.template_id IS NULL;
```

| Medición | Resultado | Notas |
|---|---|---|
| Violaciones | **88** de 4005 inspecciones | 4000 sintéticas (`volume.php`, semilla `20240915`, fecha de referencia `2024-09-15`) + 5 del `db.json`. |
| Con certificado posible (`approved` o `completed`) | **88** | Todas `approved`: el diseño de bea-11 («aprobadas: el caso que de verdad duele»). |
| Qué apuntan | `elevator-annual` **v3** | Una versión que existió tres semanas y ya no está. |
| Cuándo | Del **15/04/2023 al 06/05/2023** | Concentradas en tres semanas: el `ORDER BY started_at` revela el suceso. |

> ⚠️ **Estos números son del dataset sintético, no de producción.** El **88** es un parámetro del generador (`--violations=88`),
> no un hallazgo: lo que se mide es que la consulta lo encuentra y que el generador es determinista. La regeneración con la
> misma semilla da el mismo `md5` del volumen (`370d92153dec56deb2494bc4f577725b`, dos ejecuciones desde un esquema limpio).
> **Corrección del 15/10:** la primera versión del generador inventaba ítems y criterios que no son los de las plantillas, y
> repartía las violaciones al azar. La actual lee plantillas y criterios de la base (0 respuestas fuera de su versión, 0 fuera
> de criterio, 0 versiones no vigentes, 0 aprobadas con crítico abierto) y siembra las violaciones como describe bea-11.
> Un censo real sobre CertCore no se puede dar desde este entorno.

**La regla de la lección, que se cumple:** el volumen sintético sólo añade filas a `inspections` y `findings`. `smoke.sh`
pasa 26/26 con el volumen dentro y con la restricción puesta (`evidencia-be05/smoke-con-volumen-y-restriccion.txt`).

---

## 4. Las tres salidas, costeadas y medidas

| | A · FK compuesta `NOT VALID` | B · `CHECK` con función, `NOT VALID` | C · Disciplina de aplicación |
|---|---|---|---|
| Impide filas nuevas malas | ✅ | ✅ | ⚠️ sólo si pasan por la puerta correcta |
| Impide borrar una plantilla usada | ✅ | ❌ | ❌ |
| **Coste de ponerla** (medido) | **0 s** en la migración (`NOT VALID` no lee filas) | **0,27 ms** (medido y deshecho) | Semanas de código; no medible aquí |
| **Coste de validarla** (medido) | `VALIDATE` falla en **1,09 ms** al encontrar la primera fila mala | `VALIDATE` falla en **8,4 ms** | — |
| Toca el histórico | **No** | No | No |
| Sobrevive a un volcado/restauración | ✅ | ⚠️ según el orden de carga | ✅ |
| Permite reglas más ricas | ❌ | ✅ (p. ej. vigencia en la fecha de la inspección) | ✅ |
| **Veredicto** | ⭐ **Recomendada, puesta** | Complemento | Sólo si A es imposible |

Notas de medición:

- **A**: el `VALIDATE` se midió dentro de una transacción que se deshizo (`BEGIN … ROLLBACK`). Falla con la primera fila mala, no
  con el censo completo. El censo completo son 88 filas: la consulta de §3.
- **B**: se midió con la función `template_version_exists` y se deshizo. Se borró la función al terminar.
- **C**: no hay pruebas (be06) ni forma de contar las cuatro puertas de escritura sin ellas. La medición de C es `no medible`.

**Por qué A y no B.** Sólo la foránea impide **borrar la plantilla vieja** con inspecciones apuntando a ella. Un `CHECK` sólo se
evalúa cuando cambia la fila que lo lleva, así que borrar una plantilla no lo dispara. Ese escenario es el que convierte esta
invariante en un incidente de auditoría.

---

## 5. Lo que se pone: `NOT VALID`, y lo que no se ejecuta

Migración `2026_10_14_000100_add_template_fk_not_valid.php`:

```sql
ALTER TABLE inspections
  ADD CONSTRAINT inspections_template_fk
  FOREIGN KEY (template_id, template_version)
  REFERENCES templates (template_id, version)
  NOT VALID;
```

Estado después de migrar:

```
 conname                 | convalidated
-------------------------+--------------
 inspections_template_fk | f
```

**No se ejecuta** `ALTER TABLE inspections VALIDATE CONSTRAINT inspections_template_fk`. Lo autoriza quien decida qué pasa con
las 88 filas (§7). Mientras tanto, la restricción sólo se aplica a filas nuevas o modificadas en su clave.

---

## 6. Las dos caras: una inserción mala falla, las viejas siguen ahí

Medidas con `psql` contra la base (`evidencia-be05/pruebas-fk.txt`):

| Prueba | Resultado |
|---|---|
| **P1.** Insertar una inspección nueva con `template_version = 9` | `ERROR: insert or update on table "inspections" violates foreign key constraint "inspections_template_fk"` · `Key (template_id, template_version)=(elevator-annual, 9) is not present in table "templates"` |
| **P2.** Insertar una inspección nueva con `template_version = 2` | `INSERT 0 1` (se deshizo) |
| **P3.** Cambiar solo `status` de una fila vieja violadora | `UPDATE 1` (la clave no cambia; no se reevalúa; se deshizo) |
| **P4.** Cambiar la **clave** de una fila vieja a `template_version = 8` | `ERROR` · `Key (…, 8) is not present in table "templates"` (se deshizo) |
| **Censo después de las pruebas** | **88** (intactas) |

**El efecto lateral que hay que avisar** (lección §5.5, punto 6): cualquier `UPDATE` que cambie la clave de una de las 88 falla
desde ahora. Un `UPDATE` masivo que toque `template_version` se va a estrellar contra esto.

---

## 7. El procedimiento de despliegue, con evidencia por paso

| Paso | Qué se hizo | Evidencia |
|---|---|---|
| 1. Censar | 88 violaciones, las 88 con certificado posible (§3) | §3 |
| 2. Clasificar | Concentradas entre el 15/04 y el 06/05 de 2023 y **paradas desde entonces**: algo pasó en esas tres semanas (una v3 publicada y borrada) | §3 |
| 3. Decidir qué pasa con las filas malas | **Nada**: el histórico no se reescribe y `VALIDATE` no se ejecuta. **Firmado por el autor el 15/10/2026** | §10 |
| 4. Añadir con `NOT VALID` | Migración `…000100` aplicada, 0 s | §5 |
| 5. Comprobar las dos caras | P1 falla, P2 pasa, P3 pasa, P4 falla, censo intacto | §6 |
| 6. Avisar del efecto lateral | Documentado en §6. El correo de despliegue es del autor | §6 |
| 7. Dejar `VALIDATE` preparado y no ejecutarlo | Documentado en §5. Lo autoriza el autor | §5 |

---

## 8. `certificates.status` ya no miente: es derivado, y por qué no una columna generada

La columna `certificates.status` sigue existiendo: el controlador de be02 (CakePHP) la escribe. La lectura pasa por la vista.

```sql
ALTER TABLE certificates ADD COLUMN status_derivado text GENERATED ALWAYS AS (
  CASE WHEN revoked_at IS NOT NULL THEN 'revoked' WHEN valid_until < now() THEN 'expired' ELSE 'valid' END
) STORED;
-- ERROR:  generation expression is not immutable
```

La columna generada exige una expresión **inmutable**: la misma entrada, el mismo resultado. El estado de un certificado
depende de `now()`, así que no puede serlo. Se comprobó: la misma expresión sin `now()` sí se acepta (`ALTER TABLE` en una
transacción que se deshizo). **El problema es el reloj, no la sintaxis.**

La solución es la vista `certificates_with_status` (migración `…000200`), que se evalúa al leer y calcula el estado con la
vigencia en `America/Bogota`:

| `CERT-` | `status` (vista) | `status_almacenado` (columna) |
|---|---|---|
| `CERT-2023-000501` | `expired` | `expired` |
| `CERT-2024-000502` | **`expired`** | **`valid`** |

**Divergencia visible: 1 de 2 certificados.** Es la misma que `HALLAZGOS.md` (be03) contaba. El contrato no cambia: el frontend
recibe `status` en el mismo sitio. `smoke.sh` lo sigue dando por bueno (26/26) porque su comprobación de certificados sólo mira
que `status` sea una cadena. Esa comprobación es débil y se anota aquí.

---

## 9. EXPLAIN: línea base de cinco filas (be03) frente a 4005

Consulta del censo (§3), con la misma forma en los dos casos:

| Volumen | Plan | Tiempo de ejecución |
|---|---|---|
| 5 filas (be03, `evidencia-be05/explain-base5.txt`) | `Hash Right Anti Join`, `Seq Scan` sobre `inspections` y `templates` | 0,097 ms |
| 4005 filas, con `inspections_template_fk` `NOT VALID` (volumen corregido) | `Hash Anti Join`, `Seq Scan` sobre `inspections` (4005 filas) y `templates` (3) | 1,425 ms (`evidencia-be05/medicion-volumen-v3.txt`) |

El planificador **no usa el índice** `templates_pkey` para el `LEFT JOIN` porque `templates` tiene 3 filas: un `Seq Scan` es
más barato. Con miles de plantillas la forma cambiaría. Lo que sí cambia con la restricción es el coste de **escribir**, no
el de leer: `NOT VALID` no toca la lectura.

---

## 10. Pendiente

- [x] **Decisión del histórico**, firmada por el autor el 15/10/2026: las 88 filas no se tocan y `VALIDATE CONSTRAINT` no se ejecuta.
  La restricción se queda `NOT VALID`; el efecto lateral (§6) se anuncia con cada despliegue que toque `inspections`.
- [—] **Salida C**: medirla requiere be06 (pruebas) y el censo de las cuatro puertas de escritura; no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026).
- [~] **Las 88 filas son del generador**, no de CertCore. El censo real hay que correrlo sobre el volumen de producción.
- [—] `git tag be-fase-05-…`: los tags son del repositorio del alumno, no de esta validación.
