# EVIDENCIA-VERSIONES.md — be04: el salto de versión

> Fase be04. Reconstruye la cadena de PostgreSQL de CertCore, recorre el laboratorio en los cuatro escalones con el
> mismo `smoke.sh`, cita las rupturas contra las notas de release oficiales y diagnostica la cicatriz de las fechas.
> Medido el 14/10/2026 en `zz-code/angular-16-legacy-for-backend-devs-20261014-be/`, host arm64.

---

## 1. Fechas: qué se puede verificar y qué no

Las fechas de PostgreSQL se han leído de las notas de release oficiales, con la URL citada. Las fechas en que **CertCore**
subió de versión (la tabla de §5.1 de la lección: 2016, 2019, 2021, 2024) **no se han verificado**: su evidencia, según la
propia lección, es un correo, un calendario de operaciones y el `.env` de producción. Ninguno está en este entorno.

| Escalón | Lo que dice la lección sobre CertCore | Fecha de la release oficial | Fuente |
|---|---|---|---|
| 9.6 | subida en 2016 | **2016-09-29** | https://www.postgresql.org/docs/release/9.6.0/ |
| 11 | subida en 2019 | **2018-10-18** | https://www.postgresql.org/docs/release/11.0/ |
| 13 | subida en 2021 | **2020-09-24** | https://www.postgresql.org/docs/release/13.0/ |
| 16 | subida en 2024 | **2023-09-14** | https://www.postgresql.org/docs/release/16.0/ |

> ⚠️ La fecha de **release** de PostgreSQL no es la fecha de **subida** de CertCore. La tabla de la lección (be04 §5.1) da
> solo la segunda, que es ficción del curso; la primera es verificable y aquí sirve para comprobar que cada subida es
> posterior a su release (lo es, en los cuatro escalones; revisado el 20/10/2026).

**Evidencia que sí está en el entorno:** `SELECT version();` en cada escalón (§2). Es el único dato que nadie discute.

---

## 2. El recorrido en el laboratorio

Cada escalón: `POSTGRES_TAG` cambiado en `.env`, `docker compose -p certcore-be down -v` (sólo el proyecto del curso, con su
volumen), `up -d db api`, `migrate --force`, `db:seed --class=DbJsonSeeder --force`, y el `smoke.sh` sin tocar,
ejecutado en la red de compose. Salidas: `evidencia-be04-<versión>.txt`.

| Escalón | `SELECT version()` | `smoke.sh` | Qué se rompió | ¿Lo absorbió el ORM? |
|---|---|---|---|---|
| 9.6 | `PostgreSQL 9.6.24 … aarch64` | `OK: 26/26` | Nada | No hubo nada que absorber |
| 11 | `PostgreSQL 11.16 … aarch64` | `OK: 26/26` | Nada | — |
| 13 | `PostgreSQL 13.23 … aarch64` | `OK: 26/26` | Nada | — |
| 16.9 | `PostgreSQL 16.9 … aarch64` | `OK: 26/26` | Nada | — |

**Lectura honesta:** la cadena entera pasa sin una sola modificación, y eso confirma lo que la lección dice del matiz 1
(«Postgres es extraordinariamente bueno en compatibilidad hacia atrás»). Pero también significa que **este código no contiene
las consultas que se rompen**. La lección esperaba rupturas observables en el laboratorio; aquí no las hay. Que no las haya
es un dato sobre el código, no sobre el método. Las rupturas verificadas en §3 afectan a artefactos (respaldo, sintaxis
`WITH OIDS`, catálogos) que este backend no tiene.

### Lo que el laboratorio no reproduce (la advertencia de §5.2)

- **Cada escalón empieza con clúster nuevo** (`down -v`). En producción se hizo `pg_upgrade` o `dump`/`restore`
  sobre el clúster existente. La diferencia importa en una ruptura concreta: §3, PG 15.
- **La lección dice que el laboratorio "muerde" con el esquema `public` de PG 15.** Aquí no muerde: la base se crea con el
  usuario `postgres`, que es superusuario, y los permisos de `public` no afectan a un superusuario.
- **La ruptura del escalón 11 (`pg_xlog`) no se ve aquí** porque el backend no usa scripts de respaldo ni nombres de
  directorios del clúster. Es lo que la lección llama «el archivo que se rompe primero es el que sólo se usa en emergencias»,
  y no hay ningún archivo así en `zz-code/`.

---

## 3. Rupturas contra las notas de release oficiales

Las cuatro de la lección, verificadas el 14/10/2026 contra la página de cada release. Las citas son textuales.

| Versión | Ruptura | Cita (release notes) | URL | Fecha de la release |
|---|---|---|---|---|
| **10** | `pg_xlog` → `pg_wal`, `pg_clog` → `pg_xact` | «Rename write-ahead log directory `pg_xlog` to `pg_wal`, and rename transaction status directory `pg_clog` to `pg_xact`» · «`pg_switch_xlog()` becomes `pg_switch_wal()`» | https://www.postgresql.org/docs/release/10.0/ | 2017-10-05 |
| **12** | `WITH OIDS` eliminado | «that ability has been removed. […] Operations on tables that have columns created using `WITH OIDS` will need adjustment.» | https://www.postgresql.org/docs/release/12.0/ | 2019-10-03 |
| **12** | `abstime`, `reltime`, `tinterval` eliminados | «Remove data types `abstime`, `reltime`, and `tinterval`» | https://www.postgresql.org/docs/release/12.0/ | 2019-10-03 |
| **12** | `pg_constraint.consrc` y `pg_attrdef.adsrc` eliminados | «Remove obsolete `pg_constraint.consrc` column» · «Remove obsolete `pg_attrdef.adsrc` column» | https://www.postgresql.org/docs/release/12.0/ | 2019-10-03 |
| **14** | `password_encryption` por defecto `scram-sha-256` | «Change the default of the password_encryption server parameter to `scram-sha-256`» | https://www.postgresql.org/docs/release/14.0/ | 2021-09-30 |
| **15** | `PUBLIC` pierde CREATE en `public` | «Remove `PUBLIC` creation permission on the public schema» · «The change applies to new database clusters […] Upgrading a cluster or restoring a database dump will preserve `public`'s existing permissions.» | https://www.postgresql.org/docs/release/15.0/ | 2022-10-13 |
| **15** | Modo de backup exclusivo eliminado; `pg_start_backup` → `pg_backup_start` | «Remove long-deprecated exclusive backup mode» · «Functions `pg_start_backup()`/`pg_stop_backup()` have been renamed to `pg_backup_start()`/`pg_backup_stop()`» | https://www.postgresql.org/docs/release/15.0/ | 2022-10-13 |

### Las dos sospechas que la lección declara falsas

| Sospecha | Veredicto | Cita y URL | Fecha |
|---|---|---|---|
| «Se rompió el escapado manual de comillas» | ❌ **Falsa en esta cadena** | «Change the default value of standard_conforming_strings to on» · «backslashes are now ordinary characters in string literals» — https://www.postgresql.org/docs/release/9.1.0/ | 9.1 en **2011-09-12** |
| «Postgres retiró los casts implícitos» | ❌ **Falsa en esta cadena** | «This no longer happens: an explicit cast to text is now required for all non-character-string types.» — https://www.postgresql.org/docs/release/8.3.0/ | 8.3 en **2008-02-04** |

Son falsas en el sentido de la lección: las dos son anteriores a todos los escalones de la cadena (9.6 en adelante), así que
no pueden romper nada en el recorrido. Lo que queda es el hábito que dejaron en el código (el escapado manual, los `::text`).

### Lo que sí está verificado, pero no lo cubre el código

- **`WITH OIDS` y los tipos eliminados** no aparecen en `server/` ni en las migraciones. Ver `SQL-CRUDO.txt`.
- **`pg_xlog`, `pg_start_backup`** no aparecen en `server/`. No hay scripts de respaldo en `zz-code/`.

---

## 4. Por qué `git log` no muestra nada

El cambio de versión de la base no está en el árbol de fuentes: está en `.env` (`POSTGRES_TAG=16.9`), y en el laboratorio,
en el volumen de datos y en la imagen que `compose.yaml` referencia. `git log` y `git blame` sobre `server/` no ven nada
porque no hay nada que ver ahí. Lo que había que mirar desde el primer minuto:

1. `SELECT version();` en la base que corre hoy (no en la que dice el documento).
2. `.env` y cualquier variable del entorno gestionado que fije la imagen o el tag.
3. El historial del proveedor gestionado (correo de aviso de fin de soporte, ventana de mantenimiento).
4. Los artefactos que envejecen (`pg_xlog` en un script, `WITH OIDS` en un DDL): fechan el código, no la base.

Aquí, `git log` no existe: `zz-code/` no es un repositorio. La comprobación equivalente es el `.env` y `SELECT version();`.

---

## 5. El cruce con `SQL-CRUDO.txt`

Ver `SQL-CRUDO.txt`. Resultado: **0 de 6 consultas escritas a mano afectadas por las rupturas verificadas**. El cociente
del ejercicio (consultas de Eloquent rotas frente a las escritas a mano) **no se calcula**: no se ha contado el número de
consultas que genera Eloquent.

---

## 6. La cicatriz de las fechas (💸 4): diagnóstico, sin arreglar

Medido en el escalón 16.9 con los datos de la semilla. Nada se ha arreglado.

```
SELECT '2024-03-15T09:00:00-05:00'::timestamp   → 2024-03-15 09:00:00   ← el offset se pierde
SELECT '2024-03-15T09:00:00-05:00'::timestamptz → 2024-03-15 14:00:00+00 ← con zona, sí se conserva
SHOW timezone                                    → Etc/UTC
```

Y el efecto sobre el certificado `CERT-2024-000502` (`valid_until = 2025-02-10 23:59:59` guardado sin zona):

```
SET TIME ZONE 'UTC';              → vence 2025-02-10 23:59:59+00    (18:59 en Bogotá)
SET TIME ZONE 'America/Bogota';   → vence 2025-02-10 23:59:59-05
```

**Qué se perdió.** La base no guarda el offset de ningún instante. El valor guardado es la hora local de quien lo escribió.
Lo que lo convierte en un instante depende de la zona de la sesión que lo lee. Es exactamente la cicatriz de la Fase 10 del
track base: «venció ayer para el servidor y vence hoy para el navegador».

**Dónde está.** Las seis columnas `timestamp` (`inspections.started_at`, `inspections.completed_at`, `findings.resolved_at`,
`certificates.issued_at`, `certificates.valid_until`, `certificates.revoked_at`). El serializador `Instant::format()` vuelve a
poner `-05:00` al servir, así que el contrato sigue cumpliéndose (`smoke.sh` ✅) y **el error queda oculto**: un servidor en
otra zona, o una sesión de la base en otra zona, devolvería el mismo texto con otra realidad debajo.

**Qué costaría arreglarlo (sin hacerlo).** Cambiar las seis columnas a `timestamptz`, con migración que convierta las filas
existentes desde `America/Bogota` (la zona a la que se refería el 2016), y quitar el `-05:00` fijo de `Instant::format()`.
El coste es una migración sobre datos reales y un ajuste de la vigencia de los certificados: de ahí que sea be04 y no una
línea. Lo que no se sabe sin el dato de producción es **cuántas filas cambiarían de estado** al migrar.

---

## 7. Pendiente

- [x] **Las fechas de subida de CertCore** (2016, 2019, 2021, 2024): son datos de la ficción que fija la tabla de be04 §5.1 (columna «Cuándo subió»); no hay correo real que verificar. Revisado el 20/10/2026: cada release oficial de §1 es anterior a su subida, así que la tabla es coherente.
- [—] **La predicción sellada de be02** (ejercicio 21): no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026).
- [—] **El cociente de consultas de Eloquent** (§5): hace falta contar las consultas que genera el ORM; no aplica: dato del alumno; la lección deja el hueco a propósito (cierre del 20/10/2026).
- [—] `git tag be-fase-04-…`: los tags son del repositorio del alumno, no de esta validación.

---

## Actualización del 15/10/2026

Con el informe heredado (`ExpiredCertificatesReport`, SQL a mano sobre `pg_constraint.consrc`) y el guion de respaldo de 2016
ya en el laboratorio, **las rupturas sí se ven**, como pedía la lección:

| Escalón | Informe de vencidos (be-06) | Guion de respaldo (be-07) |
|---|---|---|
| 9.6 | funciona | funciona (con `wal_level=replica`) |
| 11 | funciona (`vencidos: 2 · reglas: 2`) | falla sólo `pg_switch_xlog()`, después del `tar` |
| 13 | — | falla sólo `pg_switch_xlog()` |
| 16.9 | **`column c.consrc does not exist`** | **fallan `pg_start_backup` y `pg_stop_backup`**; aun así «respaldo completado» |

Las dos son SQL escrito a mano. El cruce actualizado está en `SQL-CRUDO.txt`: 2 de 8 afectadas, 0 de las de Eloquent.
