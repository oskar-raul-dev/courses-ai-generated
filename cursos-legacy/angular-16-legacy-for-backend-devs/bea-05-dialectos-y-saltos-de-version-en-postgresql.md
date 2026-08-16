# 📎 Apéndice bea-05 — Dialectos y saltos de versión en PostgreSQL

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **4 horas**
> Usado por: **be04** ⭐ · Versiones cubiertas: la cadena **9.6 → 11 → 13 → 16**
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido.** Se entra con una pregunta —*"¿esto me afecta?"*, *"¿por qué no arranca con el volumen viejo?"*— y se sale con la respuesta y con la nota de release que la sostiene.

**Qué problema resuelve:** saber **qué cambia de verdad** entre versiones mayores de PostgreSQL, y por qué el 95% no cambia nada — que es justamente lo peligroso.

**Qué queda fuera:** replicación, alta disponibilidad y *tuning*; y la **ejecución real de un `pg_upgrade`**, que aquí se explica pero no se hace — en el laboratorio la versión se cambia con una línea del `.env` y un volumen nuevo ([`bea-02`](bea-02-receta-de-imagen-y-compose.md)), y la diferencia entre las dos cosas es contenido, no atajo.

---

## Índice

- [🩻 Esto sí funciona igual, y es casi todo](#-esto-sí-funciona-igual-y-es-casi-todo)
- [El directorio de datos no es compatible entre versiones mayores](#el-directorio-de-datos-no-es-compatible-entre-versiones-mayores)
- [`pg_upgrade` frente a `dump`/`restore`](#pg_upgrade-frente-a-dumprestore)
- [La autenticación: SCRAM desde PG 14](#la-autenticación-scram-desde-pg-14)
- [Las rupturas reales de esta cadena, con cita](#las-rupturas-reales-de-esta-cadena-con-cita)
- [Dos rupturas que todo el mundo cita y no son de esta cadena](#dos-rupturas-que-todo-el-mundo-cita-y-no-son-de-esta-cadena)
- [Cómo se lee una nota de release en diez minutos](#cómo-se-lee-una-nota-de-release-en-diez-minutos)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-9)

---

## 🩻 Esto sí funciona igual, y es casi todo

Esta sección es larga a propósito, porque es la que explica la historia de CertCore.

Entre PostgreSQL 9.6 (2016) y 16 (2023) hay siete versiones mayores, y lo que **no** cambió incluye prácticamente todo lo que una aplicación normal toca:

- **El SQL estándar.** `SELECT`, `JOIN`, `GROUP BY`, subconsultas, `CTE`, funciones de ventana: igual. Una consulta escrita en 2016 contra 9.6 corre hoy contra 16 sin tocarla.
- **El protocolo de cable.** Un cliente de la era 9.6 se conecta a un servidor 16 y se entiende con él (con el matiz de SCRAM, abajo).
- **Los tipos de datos de siempre.** `integer`, `text`, `varchar`, `numeric`, `date`, `timestamp`, `boolean`, `jsonb`: mismo comportamiento, mismo almacenamiento lógico.
- **Las restricciones.** `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `NOT NULL`: idénticas.
- **Las transacciones y los niveles de aislamiento.** Igual.
- **`EXPLAIN`.** Los planes mejoran —el planificador es más listo—, pero se leen igual.
- **La sintaxis de índices**, incluidos los parciales y los de expresión.

Lo que cambió es, casi siempre, **administración**: nombres de directorios y funciones de WAL, columnas de catálogo deprecadas, opciones de configuración, valores por defecto, tipos obsoletos de los años noventa.

> 🧠 **La calidad de la compatibilidad hacia atrás de PostgreSQL es lo que permitió el abandono de CertCore.** Paradoja real, sin villanos: si actualizar hubiera roto la aplicación en 2019, alguien habría tenido que mirarla. Como no rompió nada, nadie miró nunca — y ocho años después el problema no es la base, es todo lo demás.

---

## El directorio de datos no es compatible entre versiones mayores

La confusión más común de todas, y la que produce el error del ejercicio 7 de [`bea-02`](bea-02-receta-de-imagen-y-compose.md):

> **Que el SQL sea compatible no significa que el formato en disco lo sea.** Un directorio de datos creado por PG 15 **no arranca** bajo PG 16. El servidor se niega, y hace bien.

```
FATAL:  database files are incompatible with server
DETAIL: The data directory was initialized by PostgreSQL version 15,
        which is not compatible with this version 16.9.
```

El número que manda está en un archivo de una línea:

```bash
docker compose exec db cat /var/lib/postgresql/data/PG_VERSION
#   16
```

Y la consecuencia para el laboratorio: **cambiar `POSTGRES_TAG` sin cambiar el volumen no es una subida de versión, es un error de arranque.** La subida son dos pasos: `docker compose down -v` (volumen nuevo) y volver a migrar y sembrar. En producción eso no es una opción, y de ahí la sección siguiente.

---

## `pg_upgrade` frente a `dump`/`restore`

Las dos formas reales de subir de versión mayor sin perder los datos:

| | `pg_upgrade` | `dump` / `restore` |
|---|---|---|
| Qué hace | Reescribe los catálogos y **reutiliza los archivos de datos** (con `--link`, sin copiarlos) | Exporta todo a SQL y lo vuelve a insertar |
| Tiempo de parada | Minutos, casi independiente del tamaño | Horas, proporcional al tamaño |
| Riesgo | Con `--link`, **no hay vuelta atrás fácil**: los archivos se comparten | Bajo: el origen queda intacto |
| Efecto secundario | **Conserva permisos, propietarios y configuración del clúster** | Reconstruye desde cero lo que el volcado incluya |
| Cuándo | Bases grandes, ventanas cortas | Bases pequeñas, o cuando quieres empezar limpio |

La fila que más importa es la penúltima, y es la que explica una ruptura entera de [`be04`](be04-el-salto-de-version-que-nadie-corrio.md): el cambio de permisos del esquema `public` de PG 15 **sólo afecta a clústeres y bases nuevos**. Un `pg_upgrade` conserva los permisos existentes; un laboratorio con volumen nuevo, no.

> 🧭 **Dos sistemas en la misma versión pueden comportarse distinto según cómo llegaron a ella.** Es la clase de diferencia que hace que un diagnóstico correcto en tu máquina sea falso en producción — y al revés.

---

## La autenticación: SCRAM desde PG 14

Desde **PostgreSQL 14**, el valor por defecto de `password_encryption` es `scram-sha-256` en lugar de `md5`. Un cliente cuya `libpq` sea anterior a la 10 **no sabe hablar SCRAM** y falla al autenticarse, con un mensaje que no siempre lo dice claro.

```bash
docker compose exec db psql -U postgres -c "SHOW password_encryption;"
docker compose exec db psql -U postgres -c \
  "SELECT rolname, substring(rolpassword for 14) FROM pg_authid WHERE rolname='postgres';"
#   SCRAM-SHA-256...
```

**Dato verificado, con fecha (8/09/2026):** la `libpq 13` que trae `php:7.4-cli` —base Debian bullseye— **sí habla SCRAM** contra un `postgres:16.9`. Era la verificación que decidía si el stack entero de este track era viable, y salió que sí:

```
conexion:       OK
servidor:       PostgreSQL 16.9
password_encr:  scram-sha-256
php:            7.4.33 (aarch64)
```

> ⚠️ **Si alguna vez ves este fallo, la tentación es bajar `password_encryption` a `md5`.** Funciona y es exactamente la decisión equivocada: estás degradando la seguridad del servidor para acomodar un cliente viejo. La respuesta correcta es subir el cliente; si no se puede, es una excepción documentada con fecha de revisión, no una configuración. [`bea-08`](bea-08-seguridad-de-api-sobre-un-runtime-sin-parches.md) trata esa conversación entera.

---

## Las rupturas reales de esta cadena, con cita

Verificadas contra las notas de release oficiales el 11/09/2026. Son las que `be04` usa, y las únicas que se pueden afirmar.

### PG 10 — el vocabulario del WAL

> *"Rename write-ahead log directory `pg_xlog` to `pg_wal`, and rename transaction status directory `pg_clog` to `pg_xact`"*
> *"Rename SQL functions, tools, and options that reference "xlog" to "wal". For example, `pg_switch_xlog()` becomes `pg_switch_wal()`, pg_receivexlog becomes pg_receivewal, and `--xlogdir` becomes `--waldir`."*

También se renombró `location` a `lsn` en las funciones y vistas de WAL, se retiró `contrib/tsearch2`, y desaparecieron las marcas de tiempo en coma flotante.

**A quién le duele:** a los scripts de respaldo, supervisión y mantenimiento. **A la aplicación, casi nunca.**

### PG 12 — `WITH OIDS` y los tipos de los años noventa

> *"Previously, a normally-invisible `oid` column could be specified during table creation using `WITH OIDS`; that ability has been removed. Columns can still be explicitly declared as type `oid`. Operations on tables that have columns created using `WITH OIDS` will need adjustment."*

> *"Remove obsolete data types `abstime`, `reltime`, and `tinterval`. Use the SQL-standard types such as `timestamp` instead."*

> *"Remove deprecated `pg_constraint.consrc` and `pg_attrdef.adsrc` columns"* — hay que usar `pg_get_expr()` o `pg_get_constraintdef()` en su lugar.

**A quién le duele:** a tablas creadas antes de 2019, a código que introspecciona el esquema, y a cualquiera que guardara intervalos con los tipos viejos. También cambió el comportamiento *greedy* de `substring()` con patrones SQL (`%#"aa*#"%`), que es la única ruptura de manejo de cadenas real de esta cadena.

### PG 14 — SCRAM por defecto

Ver la sección de arriba. En este stack **no rompió**, y saber por qué no rompió vale tanto como saber por qué podría.

### PG 15 — el esquema `public` deja de ser de todos

> *"Remove `PUBLIC` creation permission on the `public` schema […] The change applies to new database clusters and to newly-created databases in existing clusters. Upgrading a cluster or restoring a database dump will preserve `public`'s existing permissions."*

> *"Remove long-deprecated exclusive backup mode […] Functions `pg_start_backup()`/`pg_stop_backup()` have been renamed to `pg_backup_start()`/`pg_backup_stop()`, and the functions `pg_backup_start_time()` and `pg_is_in_backup()` have been removed."*

**A quién le duele:** a las migraciones que corren con un usuario que no es el propietario de la base (el primero) y **otra vez al script de respaldo** (el segundo). Es el mismo archivo roto por segunda vez en la misma cadena, y sigue sin que nadie se entere, porque un respaldo sólo falla el día que hay que restaurar.

---

## Dos rupturas que todo el mundo cita y no son de esta cadena

Esto es lo más útil del apéndice y por eso tiene sección propia.

**1. "El escapado manual de comillas se rompió."** `standard_conforming_strings` pasó a `on` por defecto en **PostgreSQL 9.1, en 2011** — cinco años antes de que naciera `certcore-api`. El escapado defensivo con barras que ves en el SQL crudo del sistema es una **cicatriz heredada** de alguien que vivió aquel cambio, no algo que se rompiera aquí.

**2. "Postgres retiró los casts implícitos."** La retirada masiva de casts implícitos a `text` fue de **PostgreSQL 8.3, en 2008**. Los `::text` explícitos repartidos por el código son de la misma familia: reflejos de una época anterior, escritos por alguien que ya se había quemado.

> 🧭 **Las dos son ciertas como hechos históricos y falsas como diagnóstico de esta cadena.** Es la trampa más común del oficio: una afirmación verdadera **en otro contexto**, repetida en foros durante quince años, aplicada a un caso donde no toca. Por eso la regla del track es la que es — **la nota de release, con versión y URL, o no entra en el documento**.

---

## Cómo se lee una nota de release en diez minutos

Las notas de PostgreSQL son larguísimas y el 90% son mejoras que no te rompen nada. El procedimiento:

1. **Entra por `postgresql.org/docs/release/<N>.0/`.** La sección **"Migration to Version N"** está siempre al principio: es la única que importa.
2. **Lee sólo esa sección, entera.** Suele tener entre diez y treinta ítems.
3. **Clasifica cada ítem en tres cubos:** *no me afecta* (replicación, extensiones que no uso), *me afecta si…* (usas tal función, tal tipo, tal columna de catálogo), *me afecta seguro* (valores por defecto, permisos).
4. **Para cada ítem del segundo cubo, busca en tu código.** Un `grep` por el nombre de la función o el tipo. Treinta segundos por ítem.
5. **Anota los que descartes y por qué.** El descarte razonado vale tanto como el hallazgo, y es lo que hace revisable tu trabajo.
6. **Salta de versión en versión, sin atajos.** Si vas de 9.6 a 16 tienes que leer las siete secciones de migración. No hay un resumen acumulado fiable, y los que circulan por ahí son de dónde salen las dos falsas de arriba.

---

## 🧭 Cuándo usar qué

| Situación | Qué hacer | Por qué |
|---|---|---|
| El servidor no arranca tras cambiar el tag | Mirar `PG_VERSION` en el directorio de datos | Es incompatibilidad de formato, no de SQL |
| Subir de versión en el laboratorio | `down -v` + volumen nuevo + migrar y sembrar | Rápido, reproducible, y **no es lo que hace producción** |
| Subir de versión en producción, base grande | `pg_upgrade` | Minutos de parada en vez de horas |
| Subir de versión y querer empezar limpio | `dump` / `restore` | Reconstruye permisos y catálogos |
| Saber si una versión te afecta | Sólo la sección "Migration to Version N" | El resto son mejoras |
| Un error de autenticación tras subir | Comprobar `password_encryption` y la `libpq` del cliente | Casi siempre es SCRAM desde PG 14 |
| Fechar un archivo sin `git log` | Buscar sintaxis retirada (`pg_xlog`, `WITH OIDS`) | Un fósil datable: se escribió antes de esa versión |
| Alguien cita una ruptura de memoria | Pedir versión y URL | Dos de las más citadas no son de esta cadena |

---

## ⚠️ Advertencias

**Este apéndice cubre una cadena concreta: 9.6 → 16.** Si trabajas con otra, el método sirve y la lista no. Vuelve al procedimiento de los diez minutos y constrúyete la tuya.

**Las rupturas que no rompen nada son las peligrosas.** El 95% de compatibilidad es lo que hace que nadie mire; el 5% restante se cobra en el artefacto que sólo se usa en emergencias. Cuando subas una versión mayor, **ejercita el respaldo y la restauración antes de dar por buena la subida**, aunque el sistema esté verde.

**El laboratorio no es producción y la diferencia está documentada** (los permisos del esquema `public`). Antes de llevarte un diagnóstico de aquí a un sistema real, escribe en qué difieren los dos. Si no puedes escribirlo, no puedes llevártelo.

---

## 📚 Referencias

- https://www.postgresql.org/docs/release/10.0/ · https://www.postgresql.org/docs/release/12.0/ · https://www.postgresql.org/docs/release/15.0/ — las tres notas de release de donde salen todas las citas de este apéndice. Verificadas el 11/09/2026.
- https://www.postgresql.org/support/versioning/ — la política: una versión mayor al año, cinco años de soporte cada una. Es el calendario que movió la base de CertCore.
- https://www.postgresql.org/docs/16/pgupgrade.html — `pg_upgrade`, con la explicación de `--link` y sus consecuencias.
- https://www.postgresql.org/docs/16/auth-password.html — `password_encryption`, SCRAM y `md5`.
- https://www.postgresql.org/docs/16/ddl-schemas.html — el esquema `public` y los patrones de uso seguros que motivaron el cambio de PG 15.
- https://www.postgresql.org/docs/9.1/release-9-1.html — para comprobar por ti mismo la primera de las dos falsas: `standard_conforming_strings` en 2011.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos. Y el reflejo de siempre: **`/docs/current/` no es `/docs/16/`**, y en este apéndice esa diferencia es literalmente el tema.

---

## 🧪 Ejercicios (9)

1. Levanta la base en 9.6 y en 16.9 y compara: `SELECT version()`, `SHOW password_encryption`, y el contenido de `PG_VERSION`. Pega las seis salidas.
2. **Diagnóstico.** Provoca el error de incompatibilidad del directorio de datos: cambia `POSTGRES_TAG` sin borrar el volumen. Pega el mensaje literal y señala qué dos versiones nombra.
3. Crea una tabla con `WITH OIDS` bajo 9.6, comprueba que funciona, y repite bajo 12. Anota el mensaje exacto.
4. **Diagnóstico.** Escribe una consulta que use `pg_constraint.consrc` bajo 9.6 y tradúcela a `pg_get_constraintdef()`. Comprueba las dos bajo 16.
5. Lee la sección "Migration to Version 13" completa con el procedimiento de los diez minutos y clasifica cada ítem en los tres cubos. ¿Cuántos caen en "me afecta seguro"?
6. **Diagnóstico.** Comprueba la ruptura del esquema `public` de dos formas: en un clúster nuevo y en uno restaurado desde un volcado de la versión anterior. Documenta los dos comportamientos y explica cuál se parece a producción.
7. Busca en el proyecto todos los "fósiles datables" —sintaxis retirada— y úsalos para fechar cada archivo. Contrasta con `git log` cuando exista.
8. **Diagnóstico.** Escribe el script de respaldo con `pg_start_backup()` y ejecútalo contra 9.6, 13 y 16.9. Anota en qué versión dejó de funcionar y qué habría avisado antes.
9. **Diagnóstico.** Toma una de las dos rupturas falsas de este apéndice, busca tres páginas en internet que la afirmen sin versión, y escribe en cinco líneas por qué la afirmación sigue circulando. Después escribe la versión correcta de esa afirmación, la que sí es cierta.

---

> 🏷️ **Este apéndice no lleva tag propio.** Lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be04: …`). La tabla de clasificación del ejercicio 5 y el fechado del ejercicio 7 conviene conservarlos en `EVIDENCIA-VERSIONES.md`, que sí es entregable de be04. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
