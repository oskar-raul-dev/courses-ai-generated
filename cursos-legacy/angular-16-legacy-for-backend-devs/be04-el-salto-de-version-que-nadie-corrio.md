# 📅 Fase be04 — El salto de versión que nadie corrió

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Fase be04 de be07 · **10 horas**
> Depende de: **be03 cerrada** (`smoke.sh` en `24/24` contra PostgreSQL) · Habilita: be05
> Apéndices de apoyo: [`bea-05`](bea-05-dialectos-y-saltos-de-version-en-postgresql.md) · [`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md) ⭐ · [`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md) · [`bea-02`](bea-02-receta-de-imagen-y-compose.md) · Incidentes asociados: **be-06** ⭐, **be-07**, **be-08**
> Estilo de esta fase: **investigación.** Se escribe poco código y se leen muchas notas de release

> 🔥 **Esta fase pertenece al track opcional de backend.** El track base se completa sin abrirla.

---

## 🎯 1. Propósito

Investigar un incidente cuyo `git log` está vacío.

Durante quince fases del track base y tres de éste, tu reflejo ante un fallo ha sido el mismo: buscar el cambio. `git log`, `git blame`, `git bisect`, el diff entre dos tags. Esta fase existe para romper ese reflejo una vez, en un entorno controlado, **porque la causa no está en el repositorio y no hay forma de que lo esté.**

> 🧠 **A la infraestructura sí la actualizan. A la aplicación no.** La base tenía dueño —un proveedor gestionado, una auditoría, un calendario ajeno— y subió cuatro veces en ocho años. La aplicación no tenía dueño y sigue en 2016.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `EVIDENCIA-VERSIONES.md` existe y reconstruye los **cuatro escalones** con fecha y con la evidencia que sostiene cada uno. Ninguna fecha viene de la memoria de nadie.
- [ ] Recorriste la cadena **en tu laboratorio**: `POSTGRES_TAG` en `9.6`, `11`, `13` y `16`, sembrando en cada escalón, y anotaste qué se rompió en cada uno.
- [ ] Las rupturas están **verificadas contra las notas de release oficiales**, con la cita y la URL. Las que resultaron ser falsas también están anotadas **como falsas** — y son dos.
- [ ] `SQL-CRUDO.txt` (de [`bea-04`](bea-04-eloquent-lo-que-absorbe-y-lo-que-no.md) §ejercicio 5) está cruzado con las rupturas: para cada consulta cruda, si le afecta o no y por qué.
- [ ] La **predicción sellada de be02** (ejercicio 21) está abierta y comparada con lo que pasó de verdad.
- [ ] Sabes explicar, sin mirar, **por qué `git log` no muestra nada** y qué habrías tenido que mirar en su lugar desde el primer minuto.
- [ ] La cicatriz de las fechas (💸 4) está diagnosticada: sabes qué se perdió, dónde, y qué costaría arreglarlo — **sin arreglarlo**.

---

## 🚫 3. Qué NO entra todavía

- **Migrar las columnas a `TIMESTAMPTZ`.** Se diagnostica, se costea y se difiere: tocar el tipo de una columna de fechas sobre ocho años de datos es el mismo problema que la invariante de be05, y se hace una vez, allí, con procedimiento.
- **La invariante de plantillas** → be05.
- **`pg_upgrade` de verdad.** En el laboratorio la versión cambia con una línea y un volumen nuevo. Se explica cómo sería en producción y **no se ejecuta**: ver la advertencia grande de §5.4, que es contenido y no un atajo.
- **Las pruebas** → be06.
- **Subir PHP.** Sigue siendo la premisa, no un pendiente.

---

## 🧠 4. Concepto mínimo

### El ticket, y por qué no se parece a un ticket

> **OPS-4412 · Prioridad media.** *"El informe mensual de certificados vencidos lleva fallando desde el fin de semana. No hemos desplegado nada. El equipo de infraestructura dice que no tocaron nada tampoco."*

Dos frases que en cualquier otro contexto serían ruido —*"no hemos desplegado nada"*, *"no tocaron nada"*— y que aquí son **las dos pistas buenas**, porque las dos son ciertas.

🪞 **Tu instinto dice `git log`… y esta vez se equivoca.** Vas a hacer lo que haces siempre: `git log --since`, `git blame` sobre el informe, revisar el último despliegue, comparar los dos últimos tags. Y no vas a encontrar nada, **porque no hay nada**. El árbol de fuentes no cambió. El cambio está en una línea de un archivo que no es código:

```bash
# .env — La versión de la base vive AQUÍ, fuera del código fuente.
POSTGRES_TAG=16.9
```

> 🧭 **Lo que no está en el repositorio también despliega.** Un `.env`, una variable del entorno gestionado, un tag de imagen, una política del proveedor. Cuando un incidente no aparece en ningún log de git, la pregunta correcta deja de ser *"¿quién lo tocó?"* y pasa a ser **"¿qué parte de este sistema no es código?"**.

### Quién subió la base, y la ironía que pone el dominio

No fue un fantasma y no fue negligencia: fue un calendario ajeno. El proveedor gestionado anunció fin de soporte de la versión mayor, dio una ventana de mantenimiento, y subió. Hay un correo. Alguien lo archivó.

Y el motivo de fondo lo pone el propio negocio, con una ironía que no hubo que inventar: fue una **auditoría de cumplimiento** la que exigió correr sobre versiones soportadas.

> 🧠 **La certificadora no pasaba su propia auditoría.** La empresa que emite certificados de conformidad corría su sistema sobre componentes fuera de soporte. Lo que arregló la base —una auditoría con poder— es exactamente lo que nunca se aplicó a la aplicación.

### Los dos matices que evitan el cuento, y son obligatorios los dos

**Matiz 1 — nada se rompió a lo grande, y ése es el problema.**

> 🧠 **Postgres es extraordinariamente bueno en compatibilidad hacia atrás. El 95% siguió funcionando y por eso nadie miró. La calidad de la compatibilidad es lo que permitió el abandono.**

No hay villano. Cuatro versiones mayores, ocho años, y la aplicación no se enteró casi de nada. Si se hubiera roto entera en 2019, alguien habría tenido que mirarla — y hoy no estaríamos aquí. 🩻 La sección *"esto sí funciona igual"* de [`bea-05`](bea-05-dialectos-y-saltos-de-version-en-postgresql.md) es larga a propósito: el SQL estándar, el protocolo de cable y los tipos básicos aguantan sin despeinarse.

**Matiz 2 — la factura la paga el código que se saltó las convenciones.**

> 🧠 **Eloquent absorbe casi todos los cambios de dialecto. Lo que no absorbe es el `DB::select()` con SQL a mano que alguien escribió para ir más rápido.**

Y eso, para diagnosticar, es un regalo: **ya tienes la lista**. `SQL-CRUDO.txt` salió del ejercicio 5 de `bea-04`, y la predicción que sellaste en be02 decía en qué archivos iban a aparecer los bugs. Esta fase es donde se abre el sobre.

### Dos de las tres pistas que traías son falsas

Esto es lo más forense de la fase, así que se dice antes de empezar: **al verificar contra las notas de release, dos de las sospechas habituales se caen.**

| Sospecha | Veredicto | Por qué |
|---|---|---|
| *"Se rompió el escapado manual de comillas"* | ❌ **Falsa en esta cadena** | `standard_conforming_strings` pasó a `on` por defecto en **PostgreSQL 9.1 (2011)**, cinco años antes de que naciera este sistema. El escapado defensivo que ves en el código es una **cicatriz heredada** de quien vivió aquel cambio, no algo que se rompiera aquí |
| *"Postgres retiró los casts implícitos"* | ❌ **Falsa en esta cadena** | La retirada masiva de casts implícitos a `text` fue de **PostgreSQL 8.3 (2008)**. Los `::text` explícitos repartidos por el SQL crudo son de la misma familia: reflejos de una época anterior |
| *"`WITH OIDS` dejó de existir"* | ✅ **Cierta, PG 12** | Y está verificada abajo, con cita |

> 🧭 **Una pista heredada que nadie verificó es indistinguible de una pista buena.** Las dos falsas de arriba circulan en foros desde hace quince años y suenan razonables. Verificarlas cuesta diez minutos; no verificarlas cuesta media fase buscando en el sitio equivocado. **Esto es la fase entera en una tabla.**

---

## 💻 5. Código mínimo con comentarios

### 5.1 La tabla de evidencia

No se construye con recuerdos. Cada fila tiene que apoyarse en algo que se pueda enseñar.

| Escalón | Cuándo subió | Evidencia que lo prueba | Dónde está |
|---|---|---|---|
| **9.6** | 2016 | El `composer.lock` inicial y el primer `compose.yaml` | Repositorio |
| **11** | 2019 | El correo de fin de soporte del proveedor | Buzón de alguien |
| **13** | 2021 | La ventana de mantenimiento en el calendario de operaciones | Fuera del repositorio |
| **16** | 2024 | `SELECT version();` **hoy**, y el `POSTGRES_TAG` actual | La base y el `.env` |

Y el procedimiento para reconstruirla cuando no tienes ni el correo ni el calendario —que es lo normal—, en orden de coste:

```sql
-- 1. Qué corre AHORA. Es el único dato que nadie puede discutir.
SELECT version();

-- 2. Cuándo se creó el clúster: una cota inferior para la última subida.
SELECT pg_postmaster_start_time();   -- sólo dice el último arranque
-- Mejor, si tienes acceso al directorio de datos:
--   docker compose exec db cat /var/lib/postgresql/data/PG_VERSION
```

```bash
# 3. Los artefactos que envejecen y delatan la ÉPOCA en que se escribieron:
grep -rn "pg_start_backup\|pg_xlog\|pg_switch_xlog" server/ scripts/ 2>/dev/null
#    → un script que usa nombres retirados en PG 10 se escribió ANTES de PG 10

grep -rn "WITH OIDS\|oids=true" server/ 2>/dev/null
#    → sintaxis imposible desde PG 12: data el código antes de 2019
```

> 💡 **Un artefacto que usa una sintaxis retirada es un fósil datable.** No te dice cuándo se subió la base; te dice **antes de qué versión se escribió ese archivo**, que muchas veces es la única fecha fiable que vas a conseguir.

### 5.2 El recorrido, en tu laboratorio

La cadena se reproduce entera cambiando una línea. Cada escalón: volumen nuevo, migraciones, siembra, `smoke.sh`, y anotar.

```bash
# ── Escalón 1: como en 2016 ────────────────────────────────────────────────
sed -i '' 's/^POSTGRES_TAG=.*/POSTGRES_TAG=9.6/' .env    # (en Linux: sed -i 's/…/')
docker compose down -v && docker compose up -d
docker compose exec api php artisan migrate --seed
BASE_URL=http://localhost:3000 ./smoke.sh | tail -1
docker compose exec db psql -U postgres certcore -c 'SELECT version();'

# ── Escalones 2, 3 y 4: idéntico, con 11, 13 y 16.9 ───────────────────────
```

Y la anotación, que es el entregable:

| Escalón | `smoke.sh` | Qué se rompió | ¿Lo absorbió el ORM? |
|---|---|---|---|
| 9.6 | | | |
| 11 | | | |
| 13 | | | |
| 16.9 | | | |

> ⚠️ **Tu laboratorio no reproduce producción, y la diferencia importa.** Aquí cada escalón empieza con un **volumen nuevo** (`down -v`): es un clúster recién creado. En producción el proveedor hizo `pg_upgrade` o un `dump`/`restore` **sobre el clúster existente**, y hay al menos una ruptura que se comporta distinto según cuál de las dos cosas hagas — la de PG 15, en §5.3. Anota esta diferencia en `EVIDENCIA-VERSIONES.md` antes de sacar conclusiones: **un laboratorio que no sabe en qué difiere del sistema real produce diagnósticos con mucha confianza y poca validez.**

### 5.3 Lo que se rompió de verdad, con cita

Cuatro rupturas, las cuatro verificadas contra las notas de release oficiales el 11/09/2026. El desarrollo completo está en [`bea-05`](bea-05-dialectos-y-saltos-de-version-en-postgresql.md); aquí va lo que esta fase necesita.

**PG 10 (escalón de 2019) — el vocabulario del WAL cambió de nombre.**

> *"Rename write-ahead log directory `pg_xlog` to `pg_wal`, and rename transaction status directory `pg_clog` to `pg_xact`"* · *"Rename SQL functions, tools, and options that reference "xlog" to "wal". For example, `pg_switch_xlog()` becomes `pg_switch_wal()`"*

**A la aplicación no le afectó nada.** Al script de respaldo de 2016, sí — y nadie lo notó hasta que hizo falta restaurar. Es el patrón más peligroso del oficio: **lo que se rompe primero es lo que sólo se usa en emergencias.**

**PG 12 (escalón de 2021) — `WITH OIDS` y los tipos que se fueron.**

> *"Previously, a normally-invisible `oid` column could be specified during table creation using `WITH OIDS`; that ability has been removed. […] Operations on tables that have columns created using `WITH OIDS` will need adjustment."*

Y en la misma versión, dos que golpean a código de 2016 con más frecuencia de la que nadie espera:

> *"Remove obsolete data types `abstime`, `reltime`, and `tinterval`. Use the SQL-standard types such as `timestamp` instead."*
> *"Remove deprecated `pg_constraint.consrc` and `pg_attrdef.adsrc` columns"* — quien introspeccionaba el esquema con esas columnas se quedó sin ellas.

**PG 14 (dentro del escalón de 2024) — la autenticación.** El valor por defecto de `password_encryption` pasó a `scram-sha-256`, y un cliente con `libpq` anterior a la 10 no lo habla. Aquí **no rompió** —la `libpq 13` de la imagen sí lo habla, verificado el 8/09/2026—, y conviene saber por qué no rompió tanto como por qué podría haberlo hecho.

**PG 15 (dentro del escalón de 2024) — el esquema `public` dejó de ser de todos.**

> *"Remove `PUBLIC` creation permission on the `public` schema […] The change applies to new database clusters and to newly-created databases in existing clusters. Upgrading a cluster or restoring a database dump will preserve `public`'s existing permissions."*

Léelo dos veces, porque es la ruptura más interesante de la cadena: **en tu laboratorio muerde** —creas clústeres nuevos— **y en la producción de CertCore no mordió**, porque allí se actualizó el clúster existente. Dos sistemas, la misma versión, comportamientos distintos, y la diferencia está en cómo llegaste a ella, no en dónde estás.

Y de la misma versión, la que se lleva al script de respaldo otra vez:

> *"Remove long-deprecated exclusive backup mode. Functions `pg_start_backup()`/`pg_stop_backup()` have been renamed to `pg_backup_start()`/`pg_backup_stop()`"*

> 🧠 **El mismo archivo se rompió dos veces, en PG 10 y en PG 15, y nadie se enteró ninguna de las dos.** Un script de respaldo sólo falla el día que hay que restaurar. Si esta fase te deja una sola cosa aplicable a tu trabajo real, que sea ésta: **los artefactos de emergencia hay que ejercitarlos en calma, porque son los que más envejecen y los únicos cuyo fallo no avisa.**

### 5.4 El cruce con `SQL-CRUDO.txt`

Aquí se comprueba el matiz 2, y se comprueba con números.

```bash
# Para cada consulta cruda, ¿usa algo que cambió?
grep -n "pg_xlog\|WITH OIDS\|abstime\|reltime\|consrc\|adsrc\|pg_start_backup" SQL-CRUDO.txt
```

Y la tabla que sale:

| Consulta cruda | Archivo | ¿Le afecta? | Qué versión |
|---|---|---|---|
| | | | |

La conclusión que buscas es un cociente: **cuántas de las consultas construidas por Eloquent se rompieron, frente a cuántas de las escritas a mano.** Si la primera cifra es cero, acabas de medir exactamente lo que el ORM te estaba comprando durante ocho años — que es, de paso, el argumento más honesto a favor de usar uno.

### 5.5 La cicatriz de las fechas (💸 4)

Esto no es una ruptura de versión: es un defecto de diseño de 2016 que **ninguna subida arregló ni empeoró**, y que produce el bug más famoso del track base.

```sql
-- La columna es `timestamp` SIN zona. Mira qué guardó de verdad:
SELECT id, valid_until, pg_typeof(valid_until) FROM certificates LIMIT 3;
--   valid_until        | timestamp without time zone
--   2024-06-30 12:00:00    ← el "-05:00" del db.json SE PERDIÓ, en silencio
```

El JSON traía `2024-06-30T12:00:00-05:00`. La columna se quedó con `2024-06-30 12:00:00` **sin ninguna indicación de zona**, así que el mismo instante significa cosas distintas según quién lo lea: PHP lo interpreta con el TZ del contenedor, el navegador con el del usuario, y `now()` en la base con el del servidor.

> 🧠 **Una fecha sin zona no es una fecha ambigua: es una fecha que significa cosas distintas según quién la lea, y ninguna lectura es detectablemente errónea.** De ahí sale, literalmente, *"venció ayer para el servidor y vence hoy para el navegador"* de la Fase 10 del track base. El desarrollo completo —`AT TIME ZONE`, el TZ del contenedor, `America/Bogota`, y la vigencia como intervalo— está en [`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md).

```
💸 DEUDA TÉCNICA INTENCIONAL — timestamp sin zona, diagnosticada y no pagada
Lo correcto es TIMESTAMPTZ en las seis columnas de fecha con hora. El cambio
de tipo es una sola sentencia por columna... y reescribe la tabla entera, con
bloqueo, sobre datos cuya zona de origen hay que ASUMIR (-05:00) porque no
está guardada en ningún sitio.
NO SE PAGA EN ESTA FASE, a propósito: es el mismo problema de procedimiento
que la invariante de be05 —cambiar algo estructural sobre ocho años de datos
sin tumbar producción—, y el track lo enseña UNA vez, allí, completo.
Aquí se diagnostica, se costea y se anota en `bea-10`.
```

**Prueba de fuego**

Con la base en `16.9` y el sistema sembrado, corre esto:

```bash
docker compose exec db psql -U postgres certcore -c \
  "SELECT now(), current_setting('TimeZone');"
docker compose exec api php -r 'echo date_default_timezone_get(), " ", date("c"), "\n";'
```

Si las dos zonas no coinciden, acabas de reproducir la cicatriz **sin tocar una línea de código**: el mismo certificado vence en dos momentos distintos según quién pregunte. Y si coinciden, cámbiale el TZ al contenedor de PHP y repite — porque en producción nadie te garantiza que coincidan, y ése es el punto.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Buscar el cambio en el repositorio hasta agotarlo.**
*Síntoma:* cuarenta minutos de `git log`, `git blame` y `git bisect` sin un solo candidato.
*Causa:* el reflejo correcto aplicado a un sistema donde parte de la configuración vive fuera del árbol de fuentes.
*Fix mínimo:* pon un límite. **Diez minutos de git y, si no hay candidato, cambia de pregunta**: *¿qué de esto no es código?* — el `.env`, la imagen, la versión de la base, una política del proveedor, un certificado que caducó.

**Citar una ruptura de memoria.**
*Síntoma:* escribes "los casts implícitos se retiraron en la 12" y encima suena bien.
*Causa:* la sospecha circula desde hace quince años y nadie la verifica.
*Fix mínimo:* la nota de release, con URL y versión, o no entra en el documento. En esta fase eso no es rigor académico: **dos de las tres pistas que traías eran falsas**, y con ellas habrías buscado en el sitio equivocado.

**Confundir "no se rompió" con "no le afectó".**
*Síntoma:* das por bueno un escalón porque el `smoke.sh` sigue verde.
*Causa:* el juez del contrato comprueba el contrato, y hay cosas —el script de respaldo, un informe mensual, un trabajo programado— que no pasan por ninguna ruta HTTP.
*Fix mínimo:* haz la lista de lo que **no** cubre el `smoke.sh` antes de declarar un escalón limpio. Esa lista es, casi exactamente, la lista de lo que va a fallar en el peor momento.

**Arreglar las fechas "ya que estamos".**
*Síntoma:* un `ALTER TABLE ... TYPE timestamptz` en medio de la investigación.
*Causa:* está claro cuál es el arreglo y parece barato.
*Fix mínimo:* revierte. Cambiar el tipo reescribe la tabla, asume una zona de origen que no está guardada, y mezcla dos cosas en el mismo cambio: la investigación y la corrección. **Primero se sabe qué pasó; después se decide qué hacer.**

### Pieza forense de esta fase ⭐

**El incidente cuyo `git log` está vacío.**

El informe mensual falla. Nadie desplegó. Nadie tocó nada. Y las dos afirmaciones son ciertas.

La ruta, en cinco pasos, y el valor está en el **orden**:

1. **Reproduce y acota.** ¿Falla siempre o sólo el informe? ¿Desde cuándo exactamente? El "desde el fin de semana" del ticket es la pista de calendario y hay que fecharla con precisión: la primera ejecución fallida es una hora concreta, y esa hora se compara con otras cosas que pasaron esa noche.
2. **Diez minutos de git, y se acabó.** `git log --since`, `git blame` sobre el informe. Si no hay candidato, **para**. No sigas por inercia.
3. **Cambia la pregunta: ¿qué de este sistema no es código?** El `.env`, el tag de la imagen, la versión de la base, la configuración del proveedor, un secreto que rotó, un certificado TLS que caducó. Esa lista se escribe una vez y sirve toda la vida.
4. **Pregúntale al sistema qué versión es.** `SELECT version();` y `docker compose exec db cat /var/lib/postgresql/data/PG_VERSION`. Compáralo con lo que creías. **Aquí termina el 90% de estas investigaciones.**
5. **Confirma con la nota de release**, no con la intuición: busca en la versión nueva la función o la sintaxis que usa el informe.

**Y lo que hace única a esta pieza:** el arreglo no tiene par `-roto`/`-fix`. No hay diff, no hay commit que revertir, no hay factura que leer con `git diff` entre dos tags. En un curso construido sobre el par `-roto`/`-fix` y el diff como factura de la deuda, **tener un incidente cuyo cambio no es código vale mucho** — porque en la vida real son un tercio de los incidentes y el curso, hasta ahora, no te había enseñado ninguno.

> 🧭 **Cuando el `git log` está vacío y el sistema falla, el sistema tiene razón.** Lo que falta es tu inventario de lo que puede cambiar sin pasar por un commit.

> 🧨 **Rompe a propósito y observa.** Cambia `POSTGRES_TAG` a `13.15`, deja el volumen existente (**sin** `-v`), y levanta. Pega el error literal —es el del ejercicio 7 de [`bea-02`](bea-02-receta-de-imagen-y-compose.md), y ahora ya sabes por qué—. Después responde tres cosas: qué dice exactamente el log del contenedor de la base, **por qué el directorio de datos no es compatible aunque el SQL sí lo sea**, y qué habría hecho falta en producción para pasar de 13 a 16 sin perder los datos. Esa tercera pregunta es `pg_upgrade` frente a `dump`/`restore`, y está en [`bea-05`](bea-05-dialectos-y-saltos-de-version-en-postgresql.md).

---

## 🧪 7. Ejercicios (32)

**🟢 Fácil (1–8)**

1. Corre `SELECT version();` y `cat /var/lib/postgresql/data/PG_VERSION`. Anota las dos salidas y explica en una línea por qué hay dos sitios donde preguntarlo.
2. Baja a `POSTGRES_TAG=9.6` con volumen nuevo, migra y siembra. Corre el `smoke.sh` y anota el resultado.
3. **Diagnóstico.** Recorre los cuatro escalones y rellena la tabla de §5.2. Anota el resultado del `smoke.sh` en cada uno.
4. Busca en las notas de release de PG 12 el párrafo de `WITH OIDS` y cópialo literal en `EVIDENCIA-VERSIONES.md`, con la URL.
5. **Diagnóstico.** Busca `pg_xlog`, `pg_start_backup` y `WITH OIDS` en todo el proyecto. Para cada resultado, di **antes de qué versión** se escribió ese archivo.
6. Corre la comprobación de zonas de la prueba de fuego y anota las dos salidas. ¿Coinciden?
7. Abre la predicción sellada de be02 (ejercicio 21) y compárala con lo que encontraste. Anota los aciertos y los fallos, sin corregir la predicción.
8. Lista tres cosas del sistema que pueden cambiar **sin pasar por un commit**. Después amplíala a diez con ayuda de [`bea-02`](bea-02-receta-de-imagen-y-compose.md).

**🟡 Intermedio (9–20)**

9. **Diagnóstico.** Reproduce el incidente OPS-4412 completo con los cinco pasos de §6 y cronometra cada uno. ¿Cuánto tardaste en abandonar git? Sé honesto: ése es el número que mide el reflejo.
10. Verifica las dos pistas falsas de §4 contra las notas de release. Cita versión, fecha y URL de cada una. Escribe en una línea por qué las dos siguen circulando.
11. **Diagnóstico.** Crea una tabla con `WITH OIDS` bajo 9.6, siembra, y sube a 11 y a 13. ¿En cuál falla exactamente, y con qué mensaje?
12. Cruza `SQL-CRUDO.txt` con las cuatro rupturas y rellena la tabla de §5.4. Calcula el cociente entre consultas del ORM rotas y consultas crudas rotas.
13. **Diagnóstico.** Con la base en 15 o superior y un clúster nuevo, intenta crear una tabla con un usuario que no sea el propietario. Pega el error. Después explica por qué en la producción de CertCore ese error **no** apareció.
14. Escribe el script de respaldo de 2016 —con `pg_start_backup()`— y ejecútalo contra 9.6 y contra 16.9. Anota los dos resultados y la versión en la que dejó de funcionar.
15. **Diagnóstico.** Con la base en 9.6, comprueba qué `password_encryption` usa por defecto; repítelo en 16.9. Explica por qué el cambio no rompió nada aquí y en qué escenario sí habría roto.
16. Reconstruye `EVIDENCIA-VERSIONES.md` entero, con las cuatro filas y su evidencia. Marca explícitamente qué fila se apoya en un artefacto y cuál en un testimonio.
17. **Diagnóstico.** Mide el mismo `EXPLAIN ANALYZE` de `GET /inspections` (be03, ejercicio 19) en 9.6 y en 16.9. ¿Cambió el plan? ¿Cambió el tiempo? Anótalo aunque no cambie nada.
18. Escribe la consulta que demuestra que el offset `-05:00` se perdió al sembrar, comparando el `db.json` con lo que hay en la tabla.
19. **Diagnóstico.** Cambia el TZ del contenedor de PHP a `UTC` y vuelve a abrir la pantalla de certificados. Anota cuántos cambiaron de estado **sin que nadie tocara un dato**.
20. Haz la lista de lo que el `smoke.sh` **no** cubre. Compárala con la lista de lo que se rompió de verdad en la cadena.

**🟠 Difícil (21–27)**

21. **Diagnóstico.** Escribe el post-mortem de OPS-4412 con el formato del track base: qué pasó, cómo se detectó, cuánto tardó el diagnóstico, **cuál fue el paso que más tiempo desperdició** y qué habría que cambiar para que la próxima vez cueste diez minutos.
22. Costea la migración de las seis columnas de fecha a `TIMESTAMPTZ`: cuántas filas, qué bloqueo, qué zona hay que asumir y en qué se apoya esa suposición, y qué se rompería en el frontend. **No la ejecutes.** Guarda el costeo: es un insumo de be07.
23. **Diagnóstico.** Diseña el procedimiento de subida de versión que CertCore no tuvo: qué se comprueba antes, qué se ejecuta, qué se verifica después, y quién decide. Una página. Después responde lo incómodo: **¿qué de ese procedimiento habría detectado el fallo del script de respaldo?**
24. Reproduce la diferencia clúster-nuevo / clúster-actualizado con la ruptura de PG 15: en una base nueva y en una restaurada desde un `dump` de la anterior. Documenta los dos comportamientos.
25. **Diagnóstico.** Encuentra en el sistema **otro** artefacto que sólo se use en emergencias y que nadie haya ejercitado. Compruébalo. Si funciona, di desde cuándo no se probaba y cómo lo sabes.
26. Escribe el correo que el proveedor mandó en 2024 anunciando la subida, tal como te gustaría haberlo recibido: qué tendría que haber dicho para que alguien en CertCore actuara. Después responde lo difícil: **¿lo habría leído alguien igualmente?** Y si no, ¿qué canal sí habría funcionado?
27. **Diagnóstico adversarial.** Alguien propone fijar la versión de la base *"para que esto no vuelva a pasar"*. Escribe la respuesta en dos párrafos: qué problema resuelve de verdad, qué problema **crea** (pista: el runtime de PHP de este mismo proyecto lleva fijado desde 2019), y cuál es la política que sí funciona.

**🔴 Muy difícil (28–32)**

28. **Diagnóstico.** Reconstruye la cadena entera sin usar ninguna fuente externa al sistema: sólo artefactos, código y datos. Después compárala con la tabla de §5.1 y anota qué escalón no pudiste fechar y por qué.
29. Escribe la sección *"lo que no es código"* del `HOTFIX.md` de la Fase 13 del track base: el inventario de todo lo que puede cambiar sin un commit en un sistema como CertCore, con cómo se comprueba cada cosa. **Es el único entregable de esta fase que te sirve en un sistema que no sea CertCore.**
30. **Diagnóstico.** Simula el escalón que no ocurrió: sube la aplicación de Lumen 5.8 a 6.0 en una rama y anota cada ruptura. Compara el número de rupturas con las cuatro de la base en ocho años. **Ese contraste es el argumento central del track**, y ahora lo tienes medido.
31. Con todo lo medido, escribe una página para la dirección titulada *"por qué la base está al día y la aplicación no"*. Sin culpables, con mecanismos. Tiene que poder leerla alguien que no sabe qué es Postgres.
32. **Diagnóstico adversarial.** Un consultor afirma que la subida de la base fue temeraria y que el proveedor debería responder por el incidente. Desmóntalo con las notas de release en la mano —qué se rompió de verdad, cuánto, y qué lo permitió—, y después **concede lo que tiene razón**: hubo una comunicación que no funcionó. ¿De quién era la responsabilidad de que funcionara?

**🔥 Opcionales**

- 🔥 Ejecuta un `pg_upgrade` de verdad entre dos escalones, fuera del flujo del laboratorio. Mide el tiempo de parada y compáralo con `dump`/`restore` sobre los mismos datos.
- 🔥 Monta una comprobación automática que compare la versión de la base con la esperada y falle ruidosamente si no coinciden. Después argumenta dónde debería vivir: en el arranque de la aplicación, en el `smoke.sh`, o en la supervisión.

---

## 📚 8. Referencias

**Documentación oficial**
- https://www.postgresql.org/docs/release/10.0/ — las notas de la 10, con el cambio de `pg_xlog` a `pg_wal` y el renombrado de funciones. Verificado el 11/09/2026.
- https://www.postgresql.org/docs/release/12.0/ — `WITH OIDS`, los tipos `abstime`/`reltime`/`tinterval`, y `consrc`/`adsrc`. Verificado el 11/09/2026.
- https://www.postgresql.org/docs/release/15.0/ — el permiso de creación en el esquema `public` y el fin del modo de respaldo exclusivo. Verificado el 11/09/2026.
- https://www.postgresql.org/support/versioning/ — la política de versiones: cinco años de soporte por versión mayor, y una mayor al año. Es el calendario ajeno que movió esta historia.
- https://www.postgresql.org/docs/16/pgupgrade.html — `pg_upgrade`, para el ejercicio 🔥 y para entender qué hizo el proveedor.

**Libros / artículos de referencia**
- *Database Reliability Engineering* (Campbell y Majors, O'Reilly, 2017), capítulos sobre gestión del cambio y sobre *release management* — el marco de por qué la infraestructura tiene calendario y las aplicaciones no.
- *The Field Guide to Understanding Human Error* (Sidney Dekker, 4.ª ed., 2023) — para escribir el post-mortem del ejercicio 21 sin culpables. El correo archivado no es negligencia de nadie: es un sistema de comunicación que no funcionó.

**Video / apoyo**
- https://www.youtube.com/results?search_query=postgresql+major+version+upgrade+strategy — charlas sobre estrategias de subida en producción. Busca las que hablen de ventanas y de vuelta atrás, no las que enseñan el comando.

**Orden de lectura sugerido:** [`bea-05`](bea-05-dialectos-y-saltos-de-version-en-postgresql.md) **antes** de recorrer la cadena, para saber qué mirar → las notas de release **durante**, una por escalón, y sólo la sección de migración → [`bea-07`](bea-07-tiempo-zonas-y-timestamptz.md) **cuando llegues a §5.5**, no antes → Dekker **después**, para el post-mortem.

> ⚠️ URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. Y una advertencia propia de esta fase: **las notas de release de PostgreSQL son largas y sólo interesa la sección "Migration to Version X"**, que está siempre al principio. Todo lo demás son mejoras, y ninguna mejora te rompe nada.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Reconstruiste una cadena de ocho años sin un solo commit que la documentara, verificaste cuatro rupturas contra las notas oficiales, descartaste dos sospechas heredadas que llevaban quince años circulando, y mediste lo que un ORM te estaba comprando sin que nadie lo hubiera agradecido nunca.

Y dejaste una cosa diagnosticada y sin arreglar, otra vez a propósito: las fechas sin zona. Está costeada, está anotada, y su corrección es un procedimiento —cambiar algo estructural sobre ocho años de datos sin tumbar producción— que el track enseña **una vez**, entero, en la fase siguiente.

**be05** es el paso natural y es la fase insignia. Vas a mirar de frente la invariante que sostiene el sistema entero —*una inspección se lee siempre contra la versión de plantilla que estaba vigente cuando se ejecutó*— y a descubrir que **ninguna restricción de la base la sostiene**. El bug estrella del track base, el de la Fase 7, nunca fue del frontend.

> **La señal de que quedó bien:** *"el `git log` estaba vacío, dejé de buscar a los diez minutos, y encontré la causa preguntándole al sistema en vez de al repositorio."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en verde y `git status` limpio:
>
> ```bash
> git tag -a be-fase-04-el-salto-de-version-que-nadie-corrio \
>   -m "be04 cerrada: cadena 9.6->11->13->16 recorrida en el laboratorio;
> cuatro rupturas verificadas contra las notas de release y dos sospechas descartadas;
> SQL-CRUDO.txt cruzado; cicatriz de fechas diagnosticada y costeada sin pagar"
> ```
>
> Los commits de esta fase llevan `be04: …` y los de ejercicio `be04 ej22: …`.
>
> Y esta fase tiene algo propio que decir sobre git, que es justo lo contrario de lo habitual: **el incidente `be-06` no tiene par `-roto`/`-fix`.** El "cambio" que lo provocó es una línea de un archivo que no es código, así que no hay diff que enseñar ni convención de tags que aplicar. Es la única excepción declarada del track, y está prevista en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md) §🔥. Lo que sí conviene etiquetar es el costeo del ejercicio 22 (`ej/be04/22`), porque be07 lo va a citar.

---

## 📌 Pendientes sugeridos

- **La migración a `TIMESTAMPTZ` queda costeada y sin ejecutar** (💸 4). Es deliberado: el procedimiento de cambio estructural sobre datos sucios se enseña completo en be05. → **be05** para el método, **`bea-10`** para el registro de la deuda, **be07** para el número.
- **El script de respaldo se rompió dos veces y nadie se enteró.** El hallazgo es más grande que esta fase: ningún artefacto de emergencia del sistema está ejercitado. → **be06**, junto con las pruebas; y una línea en el `HOTFIX.md` del track base (ejercicio 29).
- **No hay comprobación de la versión de la base en ningún sitio** (ejercicio 🔥). Dónde debería vivir es una decisión de diseño con tres respuestas defendibles. → **be06** si se decide que es una prueba, **be07** si se decide que es supervisión.
- **La diferencia entre el laboratorio y producción** —clúster nuevo frente a clúster actualizado— afecta al menos a una ruptura y podría afectar a más. Este track no puede reproducir `pg_upgrade` sin salirse de su alcance. → **Declarado como límite conocido** en `EVIDENCIA-VERSIONES.md` y en `bea-05`.
- **La subida de Lumen 5.8 → 6.0 del ejercicio 30 se queda en una rama.** Es material excelente y no cabe aquí. → **be07**, como dato duro de la opción 2 del *assessment*.

### Reservas para el cuaderno de incidentes

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| **be-06** ⭐ | "El informe falla y no hemos desplegado nada" | Cambio fuera del repositorio · sin par `-roto`/`-fix` | 🔴 |
| **be-07** | "El respaldo de anoche no se puede restaurar" | Artefacto de emergencia envejecido | 🟠 |
| **be-08** | "El certificado dice que vence hoy y en el PDF dice ayer" | Fechas sin zona · TZ del contenedor | 🟠 |
