# ⭐ Fase be05 — La invariante que no sostenía nadie

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Fase be05 de be07 · **10 horas** ⭐⭐
> Depende de: **be04 cerrada** · Habilita: be06
> Apéndices de apoyo: [`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md) · [`bea-11`](bea-11-datos-de-prueba-y-volumen.md) 🔥 · Incidentes asociados: **be-09**, **be-10**
> Estilo de esta fase: **contención, no corrección.** Se pone una restricción sobre datos que ya la violan, sin tocar el histórico

> 🔥 **Esta fase pertenece al track opcional de backend.** Es la fase insignia y la que cierra el círculo con el corazón del track base.

---

## 🎯 1. Propósito

Descubrir que el bug estrella del track base no era un bug de frontend.

La Fase 7 te enseñó el síntoma: *una inspección de hace un año se está renderizando con la plantilla de hoy*. Lo arreglaste en el frontend, con `resolveTemplateVersion`, y estuvo bien: era el arreglo correcto en la capa donde estabas. Esta fase muestra **dónde estaba la causa**.

> 🧠 **La mitad de los bugs que parecían del frontend no lo eran.**

---

## ✅ 2. Qué queda listo al terminar

- [ ] La invariante está **escrita en una línea** en `INVARIANTES.md`, con su enunciado formal y su consecuencia de negocio.
- [ ] Demostraste que **ninguna restricción de la base la sostiene**: el `\d inspections` no tiene ninguna foránea contra `templates`, y lo sabes enseñar.
- [ ] La **consulta que encuentra las violaciones** está escrita, corre sobre las cuatro mil inspecciones del volumen sintético, y devuelve un número. Ese número está en `INVARIANTES.md` con su fecha.
- [ ] Las **tres salidas están costeadas y medidas**, no descritas: clave foránea compuesta con `NOT VALID`, `CHECK` con función, y disciplina de aplicación documentada.
- [ ] La restricción recomendada **está puesta**: la foránea compuesta en `NOT VALID`, con el `smoke.sh` en verde y sin haber tocado una sola fila del histórico.
- [ ] Una inserción nueva que viole la invariante **falla**; las filas viejas que la violan **siguen ahí**. Lo comprobaste con las dos pruebas.
- [ ] `certificates.status` ya no miente: está servido como **derivado**, y sabes explicar por qué una columna generada **no podía** resolverlo.
- [ ] Tienes el `EXPLAIN` de la consulta de violaciones sobre cuatro mil filas, comparado con la línea base de cinco de be03.

---

## 🚫 3. Qué NO entra todavía

- **Limpiar los datos sucios.** En un dominio regulado el histórico no se reescribe: una inspección de 2019 se hizo como se hizo. Contener no es corregir, y ésa es la doctrina del track.
- **La reescritura a medias** → be06.
- **El *assessment*** → be07, que consume los números de esta fase.
- **`VALIDATE CONSTRAINT` sobre el histórico.** Se explica, se deja preparado, y **no se ejecuta**: validar exige decidir antes qué se hace con las filas que fallen, y esa decisión es de negocio.
- **Migrar las fechas a `TIMESTAMPTZ`** (💸 4 de be04). Sigue costeada y sin pagar; el procedimiento que aprendes aquí es el que haría falta.

---

## 🧠 4. Concepto mínimo

### La invariante, en una línea

> 🧭 **Una inspección se lee siempre contra la versión de plantilla que estaba vigente cuando se ejecutó.**

Esa frase es el corazón de CertCore. Sostiene el valor legal de todo el sistema: un certificado dice que un activo cumplía **la norma vigente en su momento**, y si la inspección se re-renderiza con la plantilla de hoy, el documento afirma algo que nunca se comprobó.

Y ahora la pregunta de esta fase, que en el track base no se podía ni formular: **¿quién sostiene esa invariante?**

- ¿El frontend? `resolveTemplateVersion` la respeta **al pintar**. Eso es una lectura correcta, no una garantía.
- ¿El backend? Guarda `template_id` y `template_version` al crear la inspección. Eso es una escritura correcta, no una garantía.
- ¿La base? Vamos a mirar.

```bash
docker compose exec db psql -U postgres certcore -c '\d inspections'
```

```
   Column          |  Type   | ...
-------------------+---------+-----
 template_id       | character varying  |
 template_version  | integer            |
...
Foreign-key constraints:
    "inspections_asset_id_foreign" FOREIGN KEY (asset_id) REFERENCES assets(id)
```

**Una foránea, a `assets`. Ninguna a `templates`.** Las dos columnas que sostienen el valor legal del sistema son dos campos sueltos que nadie comprueba: se puede escribir `template_version = 99` sin que nada proteste.

> 🧭 **Una invariante que nadie sostiene no está rota: está esperando.** CertCore funcionó ocho años porque nadie borró una plantilla vieja. El día que alguien lo haga —una limpieza, una migración, un `DELETE` con un `WHERE` de más—, la auditoría encuentra inspecciones renderizadas con la norma equivocada. Y en una certificadora eso no es un bug de interfaz.

🪞 **Tu instinto de integridad referencial dice… y esta vez se equivoca a medias.** Tu instinto dice *"pon la foránea"*, y tiene razón. Lo que el instinto no trae es qué hacer cuando **los datos ya la violan** y el sistema tiene que seguir emitiendo certificados mañana. `ALTER TABLE ... ADD FOREIGN KEY` sobre una tabla con filas sucias falla, punto. Ahí empieza el oficio de esta fase, y es lo que [`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md) desarrolla.

### Por qué nadie la declaró en 2016

No fue descuido, y la cadena de causas es rastreable —la empezaste en be02, ejercicio 23:

1. El ORM de 2016 **no sabe hablar de claves primarias compuestas** ([`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md)).
2. La salida cómoda fue aplastar `(template_id, version)` en una cadena: `"elevator-annual-v2"`, y declararla `id`.
3. Con la clave de `templates` siendo una cadena compuesta y las columnas de `inspections` siendo dos campos separados, **la foránea compuesta no se podía ni escribir**.
4. Y como todo funcionaba, nadie volvió a mirarlo.

> 🧠 **La limitación de una herramienta se convirtió en una decisión de arquitectura, y nadie la tomó.** Es el pecado que funda este track —ausencia de revisión— en su forma más pura: no hay un culpable, hay una cadena de opciones razonables que nadie reevaluó.

🩻 **Esto sí funciona igual.** Todo tu instinto relacional sirve: la foránea compuesta es la solución correcta, `NOT VALID` existe desde hace años, y el procedimiento es el de siempre. Lo único que cambia respecto de un sistema limpio es el **orden**: primero se cuenta el daño, después se contiene, y la corrección del histórico es una decisión de negocio que probablemente sea *"no se toca"*.

---

## 💻 5. Código mínimo con comentarios

### 5.1 El volumen: por qué con cinco filas no se mide nada

Con las cinco inspecciones del `db.json`, todas las consultas de esta fase tardan lo mismo —nada— y todos los planes son un `Seq Scan`. No se puede argumentar con eso.

Así que aquí, y **sólo aquí en todo el track**, se entregan datos ajenos: **cuatro mil inspecciones sintéticas, con las violaciones ya dentro**. El generador, su semilla fija y las reglas que respeta están en [`bea-11`](bea-11-datos-de-prueba-y-volumen.md).

```bash
docker compose exec api php database/seeds/volume.php --inspections=4000 --seed=20240915
#   sembradas 4000 inspecciones (3.912 válidas, 88 violando la invariante)
#   semilla 20240915 — reproducible
```

> ⚠️ **Que el track entregue datos aquí es una excepción y se declara.** Todo lo demás sale de tu propio `db.json`. El volumen sintético **no entra en ninguna colección que el `smoke.sh` audite** (la regla está en `bea-11`): si lo hiciera, el contrato dejaría de ser verificable, y este track no negocia con su juez.

### 5.2 La consulta que encuentra las violaciones

La pieza central, y son ocho líneas:

```sql
-- Inspecciones que apuntan a una versión de plantilla que NO EXISTE.
-- Es exactamente la comprobación que haría una clave foránea compuesta, y por
-- eso vale como censo previo: cuenta las filas que impedirían añadirla.
SELECT i.id, i.template_id, i.template_version, i.started_at, i.status
FROM inspections i
LEFT JOIN templates t
  ON t.template_id = i.template_id
 AND t.version     = i.template_version
WHERE t.template_id IS NULL
ORDER BY i.started_at;
```

Y la que hay que correr primero, porque el número es el que gobierna la fase:

```sql
SELECT count(*) AS violaciones,
       count(*) FILTER (WHERE i.status IN ('approved', 'completed')) AS con_certificado_posible
FROM inspections i
LEFT JOIN templates t
  ON t.template_id = i.template_id AND t.version = i.template_version
WHERE t.template_id IS NULL;
```

La segunda columna es la que asusta: una inspección huérfana en estado `requested` es un dato feo; una **aprobada** es un certificado emitido contra una norma que no se puede reconstruir.

**Detalles con intención**

- **`LEFT JOIN` + `IS NULL` y no `NOT EXISTS`**, aunque los dos sirven: el `LEFT JOIN` te deja añadir columnas de la plantilla cuando **sí** existe, y eso permite reutilizar la misma consulta para la variante del ejercicio 12 —las que apuntan a una versión que existe pero **no estaba vigente** en la fecha de la inspección, que es una violación más sutil y más frecuente.
- **`ORDER BY started_at`** no es cosmético: te dice **cuándo** empezaron a aparecer, y eso suele señalar el evento que las produjo.

**Prueba de fuego**

```sql
EXPLAIN ANALYZE
SELECT count(*) FROM inspections i
LEFT JOIN templates t ON t.template_id = i.template_id AND t.version = i.template_version
WHERE t.template_id IS NULL;
```

Compáralo con la línea base de cinco filas de be03 (ejercicio 19). Con cuatro mil, el plan ya dice algo: si ves un `Seq Scan` sobre `inspections` **está bien** —las estás mirando todas—, pero fíjate en cómo accede a `templates`: ahí sí hay una clave que usar, y el planificador debería usarla.

### 5.3 Las tres salidas, costeadas

#### Salida A — Clave foránea compuesta con `NOT VALID` ⭐ (la recomendada)

```sql
-- Se añade la restricción SIN validar el histórico. A partir de este momento:
--   · toda fila NUEVA o MODIFICADA tiene que cumplirla
--   · las 88 filas viejas que no la cumplen SIGUEN AHÍ, intactas
-- La operación toma un bloqueo breve y NO reescribe la tabla.
ALTER TABLE inspections
  ADD CONSTRAINT inspections_template_fk
  FOREIGN KEY (template_id, template_version)
  REFERENCES templates (template_id, version)
  NOT VALID;
```

Qué se gana el primer día: **la hemorragia para**. Ninguna inspección nueva puede apuntar a una plantilla inexistente, y —lo que casi nadie ve— **ya no se puede borrar una plantilla que tenga inspecciones**, que era el escenario que convertía la invariante dormida en un incidente.

Qué cuesta:

- Un bloqueo `SHARE ROW EXCLUSIVE` sobre `inspections` durante la creación. Con cuatro mil filas, imperceptible; con cuatro millones, sigue siendo rápido **porque `NOT VALID` no lee las filas** — ésa es toda la gracia.
- Las 88 filas sucias siguen siendo inválidas y ahora están **declaradas** como tales, que es mejor que estar escondidas.
- Y un efecto que hay que saber: `NOT VALID` **no se hereda hacia atrás**, pero sí se aplica a un `UPDATE` de una fila vieja. Tocar una de las 88 para cualquier otra cosa hará que falle. Eso es correcto y hay que avisarlo, porque el primer `UPDATE` masivo que alguien haga se va a estrellar contra esto.

```sql
-- Cuando el negocio decida qué hacer con las 88, se valida. NO HOY.
-- Toma un bloqueo más suave (SHARE UPDATE EXCLUSIVE) y lee la tabla entera.
ALTER TABLE inspections VALIDATE CONSTRAINT inspections_template_fk;
```

#### Salida B — `CHECK` con función

```sql
CREATE FUNCTION template_version_exists(p_template_id text, p_version integer)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM templates WHERE template_id = p_template_id AND version = p_version
  );
$$ LANGUAGE sql STABLE;

ALTER TABLE inspections
  ADD CONSTRAINT inspections_template_check
  CHECK (template_version_exists(template_id, template_version)) NOT VALID;
```

Funciona… hasta que deja de funcionar, y hay que saber exactamente por qué:

- **Un `CHECK` sólo se evalúa cuando cambia la fila que lo lleva.** Si alguien borra una plantilla, las inspecciones que la referenciaban **no se revalidan**: el `CHECK` no las mira nunca más. La foránea sí lo impide, y ésa es la diferencia que decide.
- Un `CHECK` que consulta otra tabla **miente al restaurar un volcado**: el orden de carga puede hacer que falle o que pase sin significar nada.
- A cambio, es la única salida que permite una regla más rica que "existe" — por ejemplo, *que estuviera vigente en la fecha de la inspección*.

#### Salida C — Disciplina de aplicación documentada

No poner nada en la base y garantizarlo en el código: una comprobación en el servicio que crea inspecciones, una prueba de regresión, y un documento.

Cuándo es la respuesta correcta, porque a veces lo es: cuando la restricción tiene excepciones legítimas que la base no puede expresar, cuando la tabla es tan grande que cualquier `ALTER` es un evento, o cuando el sistema tiene fecha de decomisión cercana y lo que se necesita es que no empeore.

Cuándo no lo es, que es aquí: **`certcore-api` tiene cuatro maneras distintas de escribir en `inspections`** (lo mediste en be02) y ninguna prueba (llegan en be06). Una disciplina de aplicación con cuatro puertas y sin red no es una garantía: es una intención.

| | A · FK compuesta `NOT VALID` | B · `CHECK` con función | C · Disciplina |
|---|---|---|---|
| Impide filas nuevas malas | ✅ | ✅ | ⚠️ si pasan por la puerta correcta |
| Impide borrar una plantilla usada | ✅ | ❌ | ❌ |
| Coste de ponerla hoy | Un bloqueo breve | Un bloqueo breve | Semanas de código |
| Toca el histórico | **No** | No | No |
| Sobrevive a un volcado/restauración | ✅ | ⚠️ según el orden | ✅ |
| Permite reglas más ricas | ❌ | ✅ | ✅ |
| **Veredicto del track** | ⭐ **Recomendada** | Complemento | Sólo si A es imposible |

> 🧭 **La recomendación del track es A, y el motivo es la fila que casi nadie mira:** sólo la foránea impide **borrar la plantilla vieja**, que es exactamente el escenario que convierte esta invariante dormida en un incidente de auditoría. Contener la causa vale más que comprobar el síntoma.

### 5.4 `certificates.status`, y la trampa de la columna generada

La deuda 💸 2 viene desde la Fase 10 del track base y se contó en be03: el estado está guardado y empieza a mentir al día siguiente. Ahora se arregla, y el primer intento **no funciona**:

```sql
-- LO QUE TODO EL MUNDO INTENTA PRIMERO, Y NO SE PUEDE:
ALTER TABLE certificates
  ADD COLUMN status_derivado text GENERATED ALWAYS AS (
    CASE WHEN revoked_at IS NOT NULL THEN 'revoked'
         WHEN valid_until < now()    THEN 'expired'
         ELSE 'valid' END
  ) STORED;
--   ERROR:  generation expression is not immutable
```

Y el error es **la lección**, no un obstáculo. Una columna generada se calcula **al escribir la fila** y tiene que ser inmutable: la misma entrada, el mismo resultado, siempre. `now()` no lo es. Y no puede serlo, porque el estado de un certificado **no es una función de la fila: es una función de la fila y del momento en que preguntas.**

> 🧠 **Si un valor cambia sin que nadie escriba, no es una columna: es una consulta.** Ésa es la definición operativa de "dato derivado", y explica de una vez por qué `certificates.status` llevaba ocho años mintiendo — estaba guardado en el único sitio donde no podía estar bien.

La salida correcta es una vista, que se evalúa **cada vez que se lee**:

```sql
CREATE VIEW certificates_with_status AS
SELECT
  c.id,
  c.inspection_id,
  c.issued_at,
  c.valid_until,
  c.revoked_at,
  -- El estado, calculado en el momento de preguntar. La vigencia termina al
  -- final del día calendario en America/Bogota: la frase está escrita en
  -- INVARIANTES.md y aquí sólo se implementa (bea-07).
  CASE
    WHEN c.revoked_at IS NOT NULL THEN 'revoked'
    WHEN (c.valid_until AT TIME ZONE 'America/Bogota') < now() THEN 'expired'
    WHEN (c.valid_until AT TIME ZONE 'America/Bogota') < now() + interval '30 days' THEN 'expiring'
    ELSE 'valid'
  END AS status,
  -- Se conserva el valor guardado, con otro nombre, para poder medir la
  -- divergencia durante la transición. Se borra cuando llegue a cero... o
  -- cuando alguien decida que nunca va a llegar.
  c.status AS status_almacenado
FROM certificates c;
```

Y el controlador pasa a leer de la vista. **El contrato no cambia**: el frontend sigue recibiendo un `status` en el mismo sitio con los mismos valores. Lo único que cambia es que ahora es verdad.

```
💸 DEUDA TÉCNICA INTENCIONAL — la columna `status` sigue existiendo
No se borra. Hay código heredado que la escribe (el controlador de la parcela
CakePHP de be02 §5.1) y borrarla lo rompería, sin que ninguna prueba avise.
SE PAGA EN be06, cuando haya pruebas y se haya decidido cuál de las dos
maneras de emitir un certificado es la buena. Hasta entonces la vista la deja
inofensiva: nadie la lee.
```

### 5.5 El procedimiento de despliegue, que es el entregable de verdad

Poner la restricción son tres líneas. Ponerla **sin tumbar producción** es un procedimiento, y es lo único de esta fase que te sirve en un sistema que no sea CertCore:

1. **Censar.** Corre la consulta de §5.2 y anota el número **con fecha y hora**. Sin censo no hay decisión: un `ALTER` que falla a las tres de la mañana no es una sorpresa, es una medición que no hiciste.
2. **Clasificar las violaciones.** ¿Son viejas y estables, o siguen apareciendo? El `ORDER BY started_at` lo dice. **Si siguen apareciendo, la restricción es urgente**; si pararon en 2021, ya sabes que algo se arregló solo y conviene saber qué.
3. **Decidir qué pasa con las filas malas.** Y la respuesta aquí es *nada*: en un dominio regulado el histórico no se reescribe. Esa decisión se escribe en `INVARIANTES.md` firmada por alguien, no se deja implícita.
4. **Añadir con `NOT VALID`**, en una ventana cualquiera: no reescribe la tabla.
5. **Comprobar las dos caras.** Que una inserción mala falla y que las viejas siguen ahí. Las dos pruebas, siempre: comprobar sólo una de las dos es la forma más común de creer que has puesto una restricción que no pusiste.
6. **Avisar del efecto lateral:** cualquier `UPDATE` sobre una de las filas viejas va a fallar a partir de ahora. Eso va en el correo de despliegue, no en un comentario del código.
7. **Dejar `VALIDATE` preparado y no ejecutarlo.** Documenta el comando y quién puede autorizarlo.

**El patrón a memorizar**

> Para poner una restricción sobre datos sucios no hace falta limpiar los datos. Hace falta **separar el futuro del pasado**: `NOT VALID` hace exactamente eso, y es la herramienta más infravalorada de PostgreSQL.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Intentar la foránea sin `NOT VALID`.**
*Síntoma:* `ERROR: insert or update on table "inspections" violates foreign key constraint`, y el `ALTER` no deja nada puesto.
*Causa:* PostgreSQL valida el histórico entero por defecto.
*Fix mínimo:* `NOT VALID`. Y antes, el censo — si no sabes cuántas filas fallan, tampoco sabes si el problema es de 88 filas o de 88.000.

**Limpiar los datos para que la restricción entre.**
*Síntoma:* un `UPDATE` que apunta las inspecciones huérfanas a la plantilla más parecida, y el `ALTER` ya pasa.
*Causa:* la restricción se convirtió en el objetivo, en vez de ser la herramienta.
*Fix mínimo:* revierte, y despacio. Acabas de reescribir el histórico de un sistema regulado: esas inspecciones ahora dicen que se ejecutaron contra una plantilla contra la que **no** se ejecutaron. Es peor que el problema original, porque además es indetectable.

**Creer que un `CHECK` protege de un `DELETE` en otra tabla.**
*Síntoma:* con el `CHECK` puesto, alguien borra una plantilla y las inspecciones se quedan huérfanas sin un solo error.
*Causa:* un `CHECK` sólo se evalúa cuando cambia **su propia fila**.
*Fix mínimo:* la foránea. Y la lección general: **una restricción protege en la dirección en que está escrita, no en la que te imaginas.**

**Poner la restricción y no comprobar las dos caras.**
*Síntoma:* declaras la fase cerrada y dos semanas después entra una inspección huérfana.
*Causa:* comprobaste que las filas viejas seguían ahí y no que las nuevas fallaran; o al revés.
*Fix mínimo:* las dos pruebas, siempre, en el mismo commit.

### Pieza forense de esta fase

**La fila que apunta a una plantilla que no existe.**

Llega el ticket, y viene de auditoría interna: *"la inspección 3117 no se puede reimprimir: sale vacía"*.

1. **Mira el dato, no el código.**
   ```sql
   SELECT id, template_id, template_version, status, started_at
   FROM inspections WHERE id = 3117;
   --   3117 | elevator-annual | 3 | approved | 2023-04-11 09:20:00
   ```
2. **Pregunta por lo referenciado.**
   ```sql
   SELECT template_id, version FROM templates WHERE template_id = 'elevator-annual';
   --   elevator-annual | 1
   --   elevator-annual | 2
   ```
   **No hay versión 3.** La inspección apunta a una plantilla que no existe, y está **aprobada**: hay un certificado emitido contra una norma que nadie puede reconstruir.
3. **Pregunta si es una o son muchas.** La consulta de §5.2. Ochenta y ocho. Y `ORDER BY started_at` dice que todas son de un rango de tres semanas de 2023.
4. **Busca el evento, no al culpable.** Tres semanas, un rango cerrado. Alguien publicó una v3, se emitieron inspecciones contra ella, y después **la v3 se borró** — probablemente porque se publicó por error. Las inspecciones quedaron apuntando al vacío. No hay malicia: hay un `DELETE` que la base permitió porque nadie le dijo que no podía.
5. **Y la pregunta que cierra la investigación:** ¿por qué el frontend no se enteró nunca? Porque `resolveTemplateVersion` **degrada con elegancia**: si no encuentra la versión, cae a la vigente y pinta algo. La pantalla nunca estuvo en blanco. **Durante tres años, esas inspecciones se vieron perfectas y con la plantilla equivocada.**

> 🧠 **Un frontend que degrada con elegancia oculta la corrupción de datos durante años.** Es el mismo código que en la Fase 7 celebraste por ser robusto. Robusto y silencioso son la misma propiedad vista desde dos sitios, y cuál de las dos es depende de si alguien está mirando la base.

> 🧨 **Rompe a propósito y observa.** Con la restricción puesta, intenta `DELETE FROM templates WHERE template_id = 'elevator-annual' AND version = 1`. Pega el error. Después quítala, repite el borrado, abre la inspección 501 en la aplicación **y mira la pantalla**: no hay error, no hay aviso, y los ítems que ves son los de otra versión. Anota cuánto tiempo habría tardado alguien en darse cuenta. Ésa es la respuesta a por qué esto duró ocho años.

---

## 🧪 7. Ejercicios (33)

**🟢 Fácil (1–8)**

1. Escribe la invariante en `INVARIANTES.md` con tus palabras, y debajo su consecuencia de negocio en una frase que entienda alguien de auditoría.
2. Corre `\d inspections` y señala qué foráneas hay y cuáles faltan. Pega la salida.
3. **Diagnóstico.** Siembra el volumen sintético y corre la consulta de conteo de §5.2. Anota los dos números con fecha y hora.
4. Corre la consulta de violaciones completa y mira el `ORDER BY started_at`. ¿En qué rango de fechas se concentran?
5. Intenta añadir la foránea **sin** `NOT VALID`. Pega el error literal.
6. **Diagnóstico.** Añádela con `NOT VALID` y comprueba las dos caras: una inserción mala falla, las viejas siguen. Pega las dos salidas.
7. Intenta crear la columna generada de §5.4 y pega el error de inmutabilidad. Explícalo en dos líneas.
8. Crea la vista `certificates_with_status` y compara su `status` con el almacenado. ¿Cuántos difieren?

**🟡 Intermedio (9–20)**

9. **Diagnóstico.** Investiga la inspección 3117 con los cinco pasos de §6 y escribe la ruta completa. Criterio: alguien que no haya visto la fase puede repetirla.
10. Compara el `EXPLAIN ANALYZE` de la consulta de violaciones con cinco filas y con cuatro mil. Anota los dos planes y explica qué cambió y qué no.
11. **Diagnóstico.** Intenta borrar una plantilla referenciada, con la restricción puesta y sin ella. Documenta los dos comportamientos y cuál de los dos ve el usuario.
12. Escribe la variante sutil de la consulta: inspecciones cuya versión de plantilla **existe** pero **no estaba vigente** en su `started_at`. ¿Cuántas hay? ¿Es una violación de la invariante o de otra cosa?
13. Implementa la salida B (`CHECK` con función) en una rama, y demuestra con un `DELETE` que no protege lo que la foránea sí protege.
14. **Diagnóstico.** Con la restricción puesta, intenta un `UPDATE` sobre una de las 88 filas sucias (cambia sólo el `status`). Pega el error y explica por qué es correcto que falle y por qué hay que avisarlo antes de desplegar.
15. Haz que el controlador de certificados lea de la vista y comprueba con el `smoke.sh` que el contrato no cambió.
16. **Diagnóstico.** Mide el tiempo de `GET /certificates` leyendo de la tabla y leyendo de la vista, con cuatro mil filas. ¿Cuánto cuesta la verdad?
17. Escribe el paso 3 del procedimiento —qué se hace con las filas malas— como un documento firmable: la decisión, quién la toma, y qué pasaría si se tomara la contraria.
18. **Diagnóstico.** Averigua si las violaciones siguen apareciendo hoy: inserta una inspección nueva **sin** la restricción y comprueba si algún camino del código la habría impedido. Recuerda que hay cuatro caminos (be02).
19. Documenta el efecto lateral del `UPDATE` (ejercicio 14) en el correo de despliegue que mandarías. Cinco líneas, para gente de operaciones.
20. **Diagnóstico.** Comprueba qué pasa con la restricción al restaurar un volcado: haz `pg_dump`, restaura en una base nueva, y mira si la restricción llegó como `NOT VALID` o validada. Repite el ejercicio con la salida B y compara.

**🟠 Difícil (21–28)**

21. **Diagnóstico.** Reconstruye el evento de 2023: ¿qué secuencia exacta de operaciones produce 88 inspecciones huérfanas en tres semanas? Escríbela como una línea de tiempo y después **reprodúcela** en tu laboratorio partiendo de datos limpios.
22. Costea las tres salidas con números de tu laboratorio: tiempo de `ALTER`, bloqueo tomado, filas afectadas, y qué protege cada una. Tabla de tres columnas, defendible ante alguien que prefiere la C.
23. **Diagnóstico.** Prepara el `VALIDATE CONSTRAINT` sin ejecutarlo: qué bloqueo toma, cuánto tardaría con cuatro mil filas y cuánto con cuatro millones (mídelo o extrapólalo con método), y qué haría falta decidir antes. Documéntalo.
24. Extiende la invariante a los `jsonb`: escribe la consulta que encuentra respuestas (`answers`) cuyo `itemId` no existe en la plantilla de esa inspección (be03, ejercicio 24). ¿Cuántas hay? Después responde lo difícil: **¿se puede restringir eso?** Si no, di qué se puede hacer en su lugar.
25. **Diagnóstico.** Demuestra la degradación silenciosa del frontend: borra una plantilla, abre la inspección en la aplicación, y documenta qué ve el usuario. Después propón un cambio **en el backend** —no en el frontend, que no se toca— que convierta ese silencio en ruido. ¿Es buena idea? Argumenta las dos posturas.
26. Escribe la prueba de regresión que impediría que esto vuelva a pasar, en el lenguaje que sea, y di **dónde tendría que correr** para servir de algo. Guárdala: be06 la va a necesitar.
27. **Diagnóstico.** Aplica el procedimiento de siete pasos de §5.5 a **otra** deuda del sistema: la migración a `TIMESTAMPTZ` de be04. ¿Qué paso cambia? ¿Cuál es más caro? Entrega el procedimiento adaptado.
28. Con cuarenta mil inspecciones en vez de cuatro mil ([`bea-11`](bea-11-datos-de-prueba-y-volumen.md)), repite el censo y el `ALTER`. Anota los tiempos. ¿Cambia alguna de las recomendaciones?

**🔴 Muy difícil (29–33)**

29. **Diagnóstico.** Escribe el informe para auditoría: cuántas inspecciones se renderizaron con una plantilla que no era la suya, durante cuánto tiempo, qué certificados salieron de ellas, y **qué se puede y qué no se puede reconstruir hoy**. Es el documento más incómodo del track y el más realista.
30. Diseña el esquema que CertCore debería haber tenido en 2016 para que esta invariante fuera imposible de violar. Después costea la migración desde el actual. Cierra con la pregunta honesta: **¿la habrías diseñado así tú, en 2016, con un ORM que no soporta claves compuestas?**
31. **Diagnóstico.** La invariante tiene una versión más fuerte: *una inspección se lee contra la versión que estaba **vigente** en su fecha*. Mide cuántas filas violan **esa**, decide si merece una restricción, y si decides que sí, escríbela. Si decides que no, escribe por qué — las dos respuestas son defendibles y lo que se evalúa es el criterio.
32. Con todos los números de la fase, escribe el argumento de una página titulada *"esto no era un bug del frontend"*, dirigida al equipo que arregló la Fase 7. Sin reproche: el arreglo de allí era correcto. Lo que hay que explicar es **por qué era insuficiente y qué habría hecho falta saber para verlo**.
33. **Diagnóstico adversarial.** Alguien propone borrar las 88 filas sucias *"porque son datos corruptos y no sirven para nada"*. Escribe la respuesta en tres párrafos: qué se destruiría exactamente, qué obligación legal podría estar en juego en una certificadora, y **qué parte del argumento contrario es cierta** — porque algo de razón tiene.

**🔥 Opcionales**

- 🔥 Implementa la invariante fuerte del ejercicio 31 con un `EXCLUDE` o un índice de rango sobre la vigencia de las plantillas. Mide qué cuesta y decide si vale la pena.
- 🔥 Escribe un trabajo programado que audite la invariante cada noche y avise. Después argumenta si eso sustituye a la restricción, la complementa, o es una excusa para no ponerla.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/16/ddl-constraints.html — restricciones, incluidas las compuestas. La base de toda la fase.
- https://www.postgresql.org/docs/16/sql-altertable.html — `ADD CONSTRAINT ... NOT VALID` y `VALIDATE CONSTRAINT`, con los bloqueos que toma cada uno. **Léete la sección de bloqueos entera**: es lo que separa un despliegue tranquilo de un incidente.
- https://www.postgresql.org/docs/16/ddl-generated-columns.html — columnas generadas y el requisito de inmutabilidad, que es la trampa de §5.4.
- https://www.postgresql.org/docs/16/sql-createview.html — vistas, la salida correcta para un valor que depende del reloj.
- https://www.postgresql.org/docs/16/explicit-locking.html — la tabla de conflictos entre modos de bloqueo. Es la referencia que contesta *"¿esto para producción?"*.

**Libros / artículos de referencia**
- *Refactoring Databases* (Ambler y Sadalage, 2006), capítulos sobre *transition period* — la idea de que un cambio de esquema sobre un sistema vivo se hace en dos tiempos, que es exactamente `NOT VALID` y `VALIDATE`.
- *Designing Data-Intensive Applications* (Kleppmann, O'Reilly, 2017), capítulo 12 — la distinción entre integridad y puntualidad, y por qué una restricción declarativa vale más que una comprobación de aplicación en sistemas con varios escritores.

**Video / apoyo**
- https://www.youtube.com/results?search_query=postgresql+zero+downtime+schema+migration — charlas sobre migraciones sin parada. Busca las que hablen de bloqueos y de `NOT VALID`; descarta las que sólo enseñen `ALTER TABLE`.

**Orden de lectura sugerido:** [`bea-06`](bea-06-restricciones-claves-compuestas-y-datos-sucios.md) **antes** de tocar nada — es el apéndice que sostiene esta fase → [`bea-11`](bea-11-datos-de-prueba-y-volumen.md) **cuando siembres el volumen** → la documentación de `ALTER TABLE`, sección de bloqueos, **antes** de proponer el despliegue → Kleppmann **después**, cuando quieras defender por qué la base y no el código.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. Y con `NOT VALID` en particular, **comprueba la versión**: el comportamiento de los bloqueos ha ido mejorando versión a versión, y lo que leas de PostgreSQL 9 puede ser más pesimista que lo que hace la 16.

---

## 🚀 9. Cierre y conexión con la siguiente fase

La invariante que sostiene el valor legal de CertCore lleva ocho años sin que nadie la sostenga, y ahora está declarada, censada y contenida. Ochenta y ocho filas siguen violándola y **siguen ahí**, que es lo correcto: el histórico de un dominio regulado no se reescribe. Lo que ya no puede pasar es que aparezcan más, ni que alguien borre una plantilla vieja sin enterarse.

Y el bug estrella del track base quedó explicado desde el otro lado del cable: `resolveTemplateVersion` era el arreglo correcto en su capa, y era insuficiente porque **la capa no era la suya**.

**be06** es el paso natural por una razón que se escribe allí y no antes: ahora que sabes cuál es la regla, se puede probar. Hasta hoy no se podía, porque había cuatro maneras de escribir en `inspections` y ninguna era la oficial. La próxima fase mide la reescritura que alguien empezó y no terminó, y descubre que el estado intermedio es el más caro de todos.

> **La señal de que quedó bien:** *"puse una restricción sobre una tabla cuyas filas ya la violaban, en un martes cualquiera, sin tocar el histórico y sin que nadie se enterara — y ahora una plantilla vieja no se puede borrar."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-05-la-invariante-que-no-sostenia-nadie \
>   -m "be05 cerrada: invariante enunciada y censada (88 violaciones sobre 4000);
> foránea compuesta en NOT VALID puesta, con las dos pruebas;
> certificates.status servido como derivado desde una vista;
> las tres salidas costeadas y el procedimiento de siete pasos escrito"
> ```
>
> Los commits de esta fase llevan `be05: …` y los de ejercicio `be05 ej29: …`.
>
> Esta fase paga la deuda más grande del track base —⭐ 3, la invariante de plantillas versionadas— y la factura se lee entre dos tags de **cursos distintos**, que es la primera vez que pasa:
>
> ```bash
> git diff fase-07-plantillas-versionadas be-fase-05-la-invariante-que-no-sostenia-nadie -- src/ server/
> ```
>
> El lado de `src/` sale **vacío**, y eso es exactamente el punto: la causa se arregló donde estaba, y el frontend que la sufría no cambió ni una línea. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥.

---

## 📌 Pendientes sugeridos

- **`VALIDATE CONSTRAINT` queda preparado y sin ejecutar.** No es un olvido: validar exige decidir antes qué pasa con las 88 filas, y esa decisión es de negocio. → **Documentado en `INVARIANTES.md`** con el comando y quién puede autorizarlo; se cita en be07 como riesgo aceptado.
- **La columna `certificates.status` sigue existiendo** y hay código heredado que la escribe (💸 de §5.4). → **be06**, cuando haya pruebas y se haya decidido cuál de las dos maneras de emitir es la buena.
- **Las respuestas huérfanas dentro de `answers` (`jsonb`)** son la misma clase de agujero un nivel más abajo, y **no se pueden restringir** con el modelo actual (ejercicio 24). → **`bea-10`**, como deuda aceptada con su razón; y 🔥 de be06 para quien quiera normalizar.
- **La invariante fuerte** —*vigente en su fecha*, no sólo *existente*— (ejercicio 31) se queda sin decidir a propósito: las dos respuestas son defendibles y el track no la resuelve por el lector. → **Decisión pendiente**, anotada en `INVARIANTES.md` con los argumentos de los dos lados.
- **La prueba de regresión del ejercicio 26 no tiene dónde correr todavía.** → **be06**, que es donde llega la infraestructura de pruebas.
- **El informe para auditoría (ejercicio 29) es el entregable más realista del track** y se queda como ejercicio. Si alguna vez el track gana una fase de comunicación con negocio, sale de ahí. → **📌 de autoría**, para el chat de cierre.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| **be-09** | "Una inspección de 2023 no se puede reimprimir" | Invariante · fila huérfana | 🔴 |
| **be-10** | "Después del despliegue no puedo actualizar unas inspecciones viejas" | `NOT VALID` · efecto lateral del `UPDATE` | 🟠 |
