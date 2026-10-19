# ✅ Soluciones — Fase 24: El diseño

> **Curso:** Ruta SQL · Solucionario de la [Fase 24](../24-el-diseno.md)
> **Ejercicios:** 22 · **Perfil:** M · **Motor:** Postgres 18.6 de [`a02`](../a02-compose-de-la-ruta.md)
> **Fecha de verificación ejecutada:** 15/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Los ejercicios 1 a 3 están ejecutados con `02_ejercicios.sql`, que solo lee el catálogo, en la sesión de verificación del 15/10/2026. Los de 4 a 12 se contestan con la [bitácora](../bitacora-de-medicion.md), y la solución es la respuesta completa. Los de 13 a 22 llevan rúbrica, que también está en la lección.

---

## 🟢 Fácil (1–6)

### Ejercicio 1

```sql
SELECT k.contype AS tipo, k.conname, pg_get_constraintdef(k.oid) AS definicion
FROM pg_constraint AS k
WHERE k.conrelid = 'alameda.result'::regclass AND k.conname NOT LIKE '%_not_null'
ORDER BY 1, 2;
SELECT polname, polcmd, pg_get_expr(polqual, polrelid) AS usando
FROM pg_policy WHERE polrelid = 'alameda.result'::regclass ORDER BY 1;
```

```text
 tipo |         conname          |                         definicion
------+--------------------------+--------------------------------------------------------------
 c    | result_qualifier_check   | CHECK ((qualifier = ANY (ARRAY['<'::bpchar, '>'::bpchar])))
 c    | result_sample_flag_check | CHECK (((sample_flag)::text = ANY (…'HEMOLIZADA'…'REPETIR'…'MUESTRA INSUFICIENTE'…)))
 c    | result_value_check       | CHECK ((((qualifier IS NULL) OR (value_numeric IS NOT NULL)) AND (num_nonnulls(value_numeric, value_text, sample_flag) <= 1)))
 f    | result_analyte_code_fkey | FOREIGN KEY (analyte_code) REFERENCES alameda.analyte(analyte_code)
 f    | result_lab_order_id_fkey | FOREIGN KEY (lab_order_id) REFERENCES alameda.lab_order(lab_order_id)
 p    | result_pkey              | PRIMARY KEY (result_id)

            polname             | polcmd | usando
--------------------------------+--------+----------------------------------------------------------------
 medico_carga_en_lo_suyo        | a      |
 medico_ve_resultados_derivados | r      | (lab_order_id IN ( SELECT referral.lab_order_id FROM alameda.referral
                                |        |   WHERE (referral.physician_id = (api.claim('physician_id'::text))::integer)))
 paciente_ve_sus_resultados     | r      | (EXISTS ( SELECT 1 FROM alameda.lab_order o WHERE ((o.lab_order_id = result.lab_order_id)
                                |        |   AND (o.patient_id = (api.claim('patient_id'::text))::integer))))
```

**Lectura:** tres `CHECK` definen qué es un resultado (un número con o sin calificador, un texto, una bandera de la muestra, o nada), dos claves foráneas lo atan a un protocolo y a un analito, y tres políticas deciden quién lo ve y quién lo carga. La del médico es la de subconsulta: la que [M-47](../bitacora-de-medicion.md#m-47--f23--lo-que-cuesta-la-seguridad-por-fila-y-dónde-va-el-índice) midió en 9.684 bloques.

### Ejercicio 2

```text
               conname                |                     definicion
--------------------------------------+------------------------------------------------------------------
 patient_legacy_patient_id_key        | UNIQUE (legacy_patient_id)
 patient_merged_check                 | CHECK ((((merged_into_patient_id IS NULL) = (merged_at IS NULL)) AND ((merged_at IS NULL) = (merged_by IS NULL))))
 patient_merged_into_patient_id_check | CHECK ((merged_into_patient_id <> patient_id))
 patient_mother_patient_id_check      | CHECK ((mother_patient_id <> patient_id))
 patient_sex_check                    | CHECK ((sex = ANY (ARRAY['F'::bpchar, 'M'::bpchar])))

        tgname         | definicion
-----------------------+--------------------------------------------------------------------------------
 patient_forbid_delete | CREATE TRIGGER patient_forbid_delete BEFORE DELETE ON alameda.patient FOR EACH ROW …
```

**Lectura:** una fusión registra quién y cuándo, o no registra nada (`patient_merged_check`). Nadie se fusiona consigo mismo ni es su propia madre. Una ficha de legacy entra una sola vez, y ninguna ficha se borra: el trigger lo prohíbe. Son las reglas que Rubén hacía cumplir con un formulario, y que se rompían cuando alguien entraba por otro lado.

### Ejercicio 3

```text
 fase |                    regla                    | filas
------+---------------------------------------------+--------
 07   | facturacion.practica_sin_precio_vigente     | 109496
 04   | pacientes.documento_en_nombre               |  25574
 05   | pacientes.documento_de_otro_paciente        |   9049
 04   | pacientes.dni_con_formato_invalido          |   5408
 05   | pacientes.recien_nacido_con_documento_ajeno |   5397
```

**Lectura:** la regla más grande no es de suciedad de datos sino de negocio: prácticas sin una vigencia del precio de su obra social ese día. El diseño la hace visible y no la resuelve. Es el primer punto de la sección de lo abierto, y tiene que tener dueño.

### Ejercicio 4

[M-29](../bitacora-de-medicion.md#m-29--f16--la-fila-contador-con-tres-cajas-y-diez-mil-comprobantes): tres cajas y diez mil comprobantes, autorizados del 247.582 al 257.581, con **0 repetidos y 0 huecos**. El número que la resume para un comité es otro: con el organismo a 50 ms y 900 comprobantes, `UltimoNumero` tuvo 180 rechazos, `DMax + 1` 2.404, y la fila contador 0.

### Ejercicio 5

[M-13](../bitacora-de-medicion.md#m-13--f08--el-eav-contra-el-modelo-tipado): 269.760 bloques contra 176.902, **1,5 veces**. El curso había apostado *al menos diez veces*, y perdió. Lo que sí se cumplió es la mitad de la estimación: el EAV se equivoca 6,3 veces en las filas estimadas, contra 4,6 del tipado. El documento no puede decir que el EAV "es un desastre de rendimiento": puede decir que es peor y que estima peor, con esos números.

### Ejercicio 6

La frontera transaccional cruza el número, las líneas del comprobante y el protocolo: los tres se confirman juntos o ninguno. Las consultas son conocidas y fijas (emitir, anular, listar del día). La unidad de lectura es el comprobante. Tiene uno o dos saltos (protocolo y paciente). La exactitud es total, porque un número repetido o un salto es un rechazo del organismo. **Deciden un diseño relacional con una transacción que abarca el número**: la fila contador por punto de venta, con el número tomado al autorizar. Es la sección 5.8 de la lección.

---

## 🟡 Intermedio (7–12)

### Ejercicio 7

En la corrección de un resultado: **1,46 ms en Mongo contra 2,45 ms en el modelo tipado**, 1,7 veces ([M-38](../bitacora-de-medicion.md#m-38--f20--las-cinco-operaciones-en-tres-diseños)). No decide el diseño por tres razones. Es una operación de milisegundos, y aun corrigiendo de a uno los 620 resultados de la media hora más cargada de la caja ([M-31](../bitacora-de-medicion.md#m-31--f17--la-lectura-abierta-y-la-media-hora-más-cargada-de-la-caja)), la diferencia suma unos 0,6 s en media hora: no se siente. Las operaciones que pierde Mongo pierden por un orden de magnitud o dos (cruce y auditoría). Y es un tiempo de esta máquina, no una forma: la forma que sostiene la diferencia es que el documento escribe en un lugar y el modelo en tres tablas.

### Ejercicio 8

Cualquiera de estas, con su número:

- La consulta clínica: el tipado lee 176.902 bloques contra 77.248 de `jsonb` y 29.304 de la tabla ancha ([M-13](../bitacora-de-medicion.md#m-13--f08--el-eav-contra-el-modelo-tipado)).
- La corrección: 2,45 ms contra 1,46 de Mongo y 1,83 de `jsonb` ([M-38](../bitacora-de-medicion.md#m-38--f20--las-cinco-operaciones-en-tres-diseños)).
- Leer un informe: 0,78 ms contra 0,54 de `jsonb` ([M-38](../bitacora-de-medicion.md#m-38--f20--las-cinco-operaciones-en-tres-diseños)).
- La búsqueda en el antibiograma: aun con el mejor GIN, el 27 % de la tabla ([M-35](../bitacora-de-medicion.md#m-35--f19--el-antibiograma-como-documento-en-la-búsqueda-por-un-resultado)).
- Los analitos: después de migrar las anchas, 177 de 210 son texto sin tipo (Fase 25).

### Ejercicio 9

Le ofrece tolerancia al error de tipeo con trigramas: `RODRIGES` encuentra 1.479 pacientes a 0,3, y el texto completo, 139 ([M-39](../bitacora-de-medicion.md#m-39--f21--la-búsqueda-de-nombres-like-texto-completo-prefijo-y-trigramas)). Y búsqueda por prefijo para el término corto. No le ofrece relevancia "inteligente": el vector de trigramas es léxico, y `HEMOGRAMA` se parece a `HEPATOGRAMA` ([M-40](../bitacora-de-medicion.md#m-40--f21--la-recursión-contra-el-informe-fijo-y-el-vector-léxico)). Tampoco le ofrece un umbral que no traiga ruido: a 0,2 son 6.682 resultados, y a 0,5, 43. El umbral se decide con recepción.

### Ejercicio 10

Porque la política por subconsulta a `referral` obliga a recorrer `lab_order` aunque `referral` tenga su índice: **9.684 bloques y 91 ms**, contra **5 bloques** con el médico como columna indexada de la tabla protegida ([M-47](../bitacora-de-medicion.md#m-47--f23--lo-que-cuesta-la-seguridad-por-fila-y-dónde-va-el-índice)). Se paga con *expand*: la columna nueva en `lab_order` (sin reescritura), el relleno en lotes desde `referral`, el índice con `CONCURRENTLY` y el cambio de política en una transacción corta con `lock_timeout`. Es el ejercicio 25 de la Fase 23, con el método de la Fase 25.

### Ejercicio 11

El UUID no protege nada que la seguridad por fila no proteja. El IDOR de 2018 no se arregló cambiando el identificador, sino con la política ([M-48](../bitacora-de-medicion.md#m-48--f23--la-api-con-postgrest-vista-desde-afuera)), y el MD5 del número se revirtió entero en unos 3,5 s ([M-49](../bitacora-de-medicion.md#m-49--f23--el-md5-del-portal-de-2018-revertido)). Lo que sí cuesta: en InnoDB, UUIDv7 agranda el índice primario un 23 % y UUIDv4 un 93 a 97 % ([M-16](../bitacora-de-medicion.md#m-16--f10--uuidv4-y-uuidv7-como-clave-primaria-en-innodb), [M-25](../bitacora-de-medicion.md#m-25--f10--las-claves-en-innodb-en-la-validación-del-bloque-ii)). Un identificador público no adivinable tiene sentido en la URL, y puede ser una columna aparte de la clave.

### Ejercicio 12

Porque la exportación interna no cruza la frontera de un sistema: el consumidor es de Alameda y el contrato puede ser su esquema. Para ese caso, la cola en la base consume 6.651 mensajes 2,4 a 2,9 veces más rápido que Artemis en este laboratorio, y no agrega una pieza que operar ([M-51](../bitacora-de-medicion.md#m-51--f23--el-boss-del-puente-punto-de-partida-solución-y-hacía-falta-un-broker)). El SIH es otra empresa y otro motor, y el *broker* hace que el contrato sea el mensaje. La decisión es por frontera, no por tecnología.

---

## 🟠 Avanzado (13–18) — rúbrica

### Ejercicio 13

*Una sola medición.*

**Rúbrica (sobre 3 puntos):** 1 punto por identificar la decisión y su única medición; 1 por una segunda medición que pueda contradecirla; 1 por decir qué cambiaría si la contradice.

### Ejercicio 14

*La pregunta de Verónica.*

**Solución de referencia:** reconoce que una sola fuente de verdad para pacientes y órdenes es real y que la Fase 25 mide su costo (12.364 fichas sin pareja en el cruce entre dos bases). Recuerda que 9.922 de ellas son fichas sin documento, que entrarían al SIH igual. Dice que el mecanismo de cada parte existe en Oracle (rangos, VPD, `JSON`) y que el curso no publica sus números. Y deja el costo de licencia y personas para el comité, que es la Fase 26.

**Rúbrica (sobre 4 puntos):** 1 punto por reconocer su mejor argumento; 1 por lo que sí se midió (el cruce de pacientes, la suciedad que entraría al SIH); 1 por el mecanismo de Oracle sin números (D20); 1 por dejar el costo para el comité.

### Ejercicio 15

*El informe como documento.*

**Rúbrica (sobre 4 puntos):** 1 punto por la fuente relacional; 1 por el documento derivado en la misma transacción o por outbox; 1 por la corrección que actualiza los dos; 1 por citar M-38 y M-41.

### Ejercicio 16

*La sección de operación.*

**Rúbrica (sobre 4 puntos):** 1 punto por las estadísticas extendidas (M-19); 1 por el límite a las lecturas largas (M-31); 1 por `lock_timeout` en el DDL (M-33); 1 por los slots que se vigilan (M-46).

### Ejercicio 17

*Lo abierto.*

**Rúbrica (sobre 3 puntos):** 1 punto por cada punto con dueño y fecha; 1 por no esconder uno incómodo.

### Ejercicio 18

*El particionado.*

**Solución de referencia:** se mide la consulta que se beneficiaría (el informe del mes o la presentación, que filtran por fecha y podrían podar particiones) y la que empeora (la historia de un paciente, sin fecha, que tiene que visitar todas). Se mide con un volumen que se acerque a los 140 millones de resultados, porque con 12 millones el índice por protocolo alcanza. No se particiona si la consulta por paciente es la frecuente y empeora más de lo que mejora la mensual.

**Rúbrica (sobre 4 puntos):** 1 punto por la consulta que se beneficiaría (poda por fecha); 1 por lo que empeora (consultas por paciente sin fecha); 1 por el volumen al que se mide; 1 por el criterio de no hacerlo.

---

## 🔴 Muy difícil (19–22) — rúbrica

### Ejercicio 19

*El documento.*

**Rúbrica (sobre 6 puntos):** 1 punto por las cinco preguntas en cada parte; 1 por una medición a favor y una en contra por parte; 1 por las tres propuestas con lo que gana cada una; 1 por Oracle sin números; 1 por la sección de lo abierto con dueños; 1 por quién opera cada parte.

### Ejercicio 20

*El comité.*

**Rúbrica (sobre 3 puntos):** 1 punto por pregunta difícil de verdad con una respuesta que cita una medición.

### Ejercicio 21

*Diez veces Alameda.*

**Rúbrica (sobre 4 puntos):** 1 punto por separar formas que escalan de tiempos que no; 1 por el particionado; 1 por la búsqueda; 1 por lo que no cambia (el modelo).

### Ejercicio 22

*Si gana Verónica.*

**Rúbrica (sobre 4 puntos):** 1 punto por el modelo que sobrevive casi entero; 1 por lo que cambia de mecanismo (rangos sin `WITHOUT OVERLAPS`, `jsonb`, RLS como VPD); 1 por la suciedad que entra al SIH; 1 por el costo.
