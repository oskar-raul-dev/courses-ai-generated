# ✅ Soluciones — SQL Server 05: Data API builder y el tipo `json`

> **Curso:** Ruta SQL · Solucionario de [ss05](../ss05-data-api-builder-y-json.md)
> **Ejercicios:** 20 · **Perfil:** M (el modelo de la Fase 23 y los antibiogramas de la Fase 19, en `ss05`) · **Motores:** SQL Server 2025
> CU9 `mcr.microsoft.com/mssql/server@sha256:2b5b58162112…`, Data API builder 2.1.5 `…data-api-builder@sha256:d07e3e1ce53b…` (los dos
> emulados), y Postgres `pgvector/pgvector@sha256:2358fcba361e…`
> **Fecha de verificación ejecutada:** 18/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

> 🔒 **Lo que este solucionario no trae.** Lecturas y tiempos de SQL Server. Trae lo que contesta la API (códigos y conteos, que son de la
> caja), los mensajes, la estructura y todo lo de Postgres ([`a09`](../a09-licencias-publicacion-y-riesgo.md#-qué-sí-se-publica-de-oracle-y-de-sql-server)).

---

## 🟢 Fácil (1–6)

### Ejercicio 1

```text
1 · sin identidad: HTTP 403 · Authorization Failure: Access Not Allowed.
2 · paciente 39: HTTP 200 · 1284 resultados · protocolos distintos 152
3 · paciente 39 pide el protocolo -2147402959 (del paciente 12594): HTTP 200 · []
4 · médico 144: HTTP 200 · 1114 protocolos
5 · paciente 39 sin X-MS-API-ROLE: HTTP 403 · Authorization Failure: Access Not Allowed.
6 · cualquiera escribe la identidad del paciente 12594: HTTP 200 · 115 resultados ajenos
```

Los roles evaluados: 1, `Anonymous` (sin encabezado de identidad); 2, 3 y 6, `paciente` (identidad con `roles: paciente` y `X-MS-API-ROLE:
paciente`); 4, `medico`; 5, `Authenticated` (hay identidad, pero sin `X-MS-API-ROLE`). Ni `Anonymous` ni `Authenticated` tienen permisos en
`dab-config.json`, y por eso 1 y 5 son 403. Si la primera corrida después de levantar el laboratorio da un 500 en la línea 6, es el
*timeout* de un pedido con la caché fría: se repite.

### Ejercicio 2

```python
import base64, json
json.loads(base64.b64decode(principal(["paciente"], patient_id=39)))
```

```json
{"auth_typ": "aad", "name_typ": "name", "role_typ": "roles",
 "claims": [{"typ": "roles", "val": "paciente"}, {"typ": "patient_id", "val": "39"}]}
```

DAB pasa cada *claim* a `SESSION_CONTEXT` con su `typ` como clave: `roles` y `patient_id` son los que lee el predicado. La traza de la sección
5.2 muestra tres `sp_set_session_context` por pedido: los dos *claims* y uno más que agrega DAB. No hay firma ni fecha de vencimiento: es un
JSON en base64, y es todo lo que DAB necesita para creer.

### Ejercicio 3

Como `sa`, con el contexto del paciente 39, `api.resultados` devuelve **todas** las filas del modelo, 12.710.308: la última línea del
predicado (`OR IS_SRVROLEMEMBER(N'sysadmin') = 1`) deja ver todo a un administrador, con contexto o sin él. Sin esa línea, `sa` vería cero
filas sin contexto, porque la documentación dice que las políticas *"apply to all users, including dbo users"*. Para ver lo que ve el
paciente hay que conectarse como `dab_api`, que es lo que hace el ejercicio 7.

### Ejercicio 4

```graphql
{ protocolos(first: 3, orderBy: {ordered_on: DESC}) { items { lab_order_id ordered_on site_code } } }
{ resultados(filter: {lab_order_id: {eq: 11044977}, analyte_code: {eq: "GLU"}}) { items { analyte_code value_numeric } } }
```

```text
REST: /api/resultados?$filter=analyte_code eq 'GLU'&$first=3&$select=lab_order_id,analyte_code,value_numeric
```

GraphQL pide los campos y el filtro en la consulta; REST los pide en los parámetros OData (`$filter`, `$select`, `$orderby`, `$first`). Los
dos pasan por la misma autorización y la misma política: el paciente 39 recibe sus protocolos en los dos. La diferencia práctica es que
GraphQL puede traer en un pedido lo que REST trae en dos, y que su respuesta tiene la forma de la consulta.

### Ejercicio 5

```text
{"MEROPENEM": "R",}    Msg 13609 … Unexpected character '}' is found at position 18.
{'AMPICILINA': "R"}    Msg 13609 … Unexpected character ''' is found at position 1.
{AMPICILINA: "R"}      Msg 13609 … Unexpected character 'A' is found at position 1.
```

Los tres inválidos dan el mismo error con la posición del primer carácter que no entiende. En Postgres, los tres fallan con `invalid input
syntax for type json`. El repetido es válido en los dos, y no da lo mismo: en Postgres,

```sql
SELECT '{"AMPICILINA": "R", "AMPICILINA": "S"}'::jsonb;    -- {"AMPICILINA": "S"}
```

queda el **último**, como dice la documentación de `jsonb`. Qué queda en el `json` de SQL Server lo ves con `SELECT CAST(antibiogram AS
nvarchar(max))` después de insertarlo; si es otro valor, un documento con claves repetidas migrado entre los dos motores cambia de dato sin
ningún error. No publiques lo que da SQL Server; la decisión es la misma con cualquier resultado: rechazar las claves repetidas antes de
cargar.

### Ejercicio 6

```sql
-- postgres
SELECT count(*) FILTER (WHERE r.result_id >= 1000000000) AS de_las_anchas, count(*) AS total, count(DISTINCT r.lab_order_id) AS protocolos
FROM alameda.result r JOIN alameda.lab_order o USING (lab_order_id) WHERE o.patient_id = 39;
```

```text
 de_las_anchas | total | protocolos
           858 |  1284 |        152
```

De los 1.284 resultados del paciente 39, 858 vinieron de las tablas anchas: la [Fase 25](../25-la-migracion-sin-parar.md) los numeró desde
mil millones para no chocar con legacy. Los 426 restantes son los que la Fase 23 contó antes de la migración. Los mismos 1.284 que devuelve
DAB: el contrato es el mismo y el dato es el mismo.

---

## 🟡 Intermedio (7–12)

### Ejercicio 7

```text
conectado como dab_api:
sin contexto                          0
roles = paciente, patient_id = 39      1284
patient_id = 12594 (otra vez)          115
patient_id = 39 con @read_only = 1, y después 12594:
Msg 15664, Level 16, State 1 … Cannot set key 'patient_id' in the session context. The key has been set as read_only for this session.
```

Sin contexto, el predicado no encuentra rol y no deja ver nada. Con el contexto de 39, lo suyo. Si cualquier código que corra en la conexión
vuelve a fijar `patient_id`, la política filtra por el valor nuevo: el contexto es la identidad, y es escribible. Con `@read_only = 1`, el
segundo intento falla. Para que el primer caso fuera un problema, DAB tendría que exponer algo que ejecute SQL elegido por el cliente o un
procedimiento que llame a `sp_set_session_context`; no lo hace, y el supuesto queda fuera de lo que la base puede comprobar.

### Ejercicio 8

```python
base64.b64decode("W3siRW50aXR5TmFtZSI6InJlc3VsdGFkb3MiLCJGaWVsZE5hbWUiOiJyZXN1bHRfaWQiLCJGaWVsZFZhbHVlIjo1MzUyOSwiRGlyZWN0aW9uIjowfV0=")
```

```json
[{"EntityName":"resultados","FieldName":"result_id","FieldValue":53529,"Direction":0}]
```

Es paginación **por clave** (*keyset*), la de la [Fase 14](../14-la-base-no-estaba-lenta.md): la página siguiente empieza después del último
`result_id` visto, y no cuenta filas desde el principio. Lo que revela: el nombre de la entidad, la columna de la clave y el último valor, en
base64, que no es cifrado. Para un `result_id` secuencial no es un secreto; para una clave que no se quiere exponer, es una filtración.

### Ejercicio 9

```python
from datetime import datetime
from zoneinfo import ZoneInfo
datetime.fromisoformat("2025-10-20T00:00:00Z").astimezone(ZoneInfo("America/Argentina/Cordoba"))
# datetime(2025, 10, 19, 21, 0, tzinfo=…Cordoba)
```

Medianoche UTC es el 19 de octubre a las 21 en Córdoba: el protocolo aparece un día antes. Dos salidas. **En la vista:** devolver la fecha
como texto (`CONVERT(char(10), o.ordered_on, 23) AS ordered_on`), que DAB publica sin zona. **En el cliente:** leer el campo como fecha
(`date.fromisoformat(valor[:10])`) y no convertirlo nunca de zona. La primera es mejor, porque arregla el contrato para todos los clientes.

### Ejercicio 10

**Solución de referencia.** Un tercer caso en el predicado y la entidad con el rol nuevo:

```sql
   OR (CAST(SESSION_CONTEXT(N'roles') AS nvarchar(20)) = N'sede'
       AND EXISTS (SELECT 1 FROM alameda.lab_order AS x WHERE x.lab_order_id = @lab_order_id
                     AND x.site_code = CAST(SESSION_CONTEXT(N'site_code') AS nchar(1))))
```

```json
{ "role": "sede", "actions": [ "read" ] }
```

Para cambiar el predicado hay que quitar la política (`DROP SECURITY POLICY api.portal`), porque *"Attempts to modify a function that is
used as a predicate on a table within a schema bound security policy results in an error"*, alterar la función y volver a crearla.

**Rúbrica.** El pedido con `roles: sede`, `site_code: V` y `X-MS-API-ROLE: sede` devuelve solo protocolos con `site_code = 'V'`, y ninguno del
central; la política se recrea; DAB se reinicia para leer el rol nuevo.

### Ejercicio 11

```sql
-- sqlserver
SELECT COUNT(*) FROM staging.culture_doc
WHERE JSON_CONTAINS(antibiogram, 'R', '$.AMPICILINA') = 1 AND JSON_CONTAINS(antibiogram, 'S', '$.GENTAMICINA') = 1;
-- postgres
SELECT count(*) FROM staging.culture_doc WHERE antibiogram @> '{"AMPICILINA": "R", "GENTAMICINA": "S"}';
```

**22.891** en los dos: el mismo dato, contado en dos motores. `@>` toma las dos condiciones en un documento; `JSON_CONTAINS` va una vez por
ruta.

### Ejercicio 12

```sql
-- sqlserver
SELECT c.culture_id, j.[key] AS antibiotic, j.[value] AS sensitivity
FROM staging.culture_doc AS c CROSS APPLY OPENJSON(c.antibiogram) AS j;
```

**469.863** filas, las mismas que `staging.antibiogram_long` de la Fase 19 en Postgres (`SELECT count(*) FROM staging.antibiogram_long`). Es
la ida y vuelta entre las dos formas sin perder nada. Una advertencia de esta verificación: en el Mac, con la emulación, recorrer entera una
tabla grande una y otra vez llevó al contenedor de SQL Server al límite de memoria (a08, E-98); esta consulta se corre de a una.

---

## 🟠 Difícil (13–17)

### Ejercicio 13

**Solución.** `SET STATISTICS IO ON` antes de cada consulta de la búsqueda, con los dos índices de `04_json.sql`, y con ellos borrados para el
recorrido. Lo que hay que explicar con la estructura de la sección 5.4: el índice JSON busca en su tabla interna la ruta y el valor, y
después cruza con la tabla para contar; la columna calculada es un `Index Seek` directo. Para meropenem (600 de 60.001), las dos tienen que
leer una fracción chica del recorrido; para ciprofloxacina (13.303), la fracción crece, como en M-35. No publiques los números.

### Ejercicio 14

**Solución.** Conectado como `dab_api`, `sp_set_session_context` a mano con el paciente 39 y con el médico 144, la consulta del portal con
`SET STATISTICS IO ON`, y lo mismo con la política apagada (`ALTER SECURITY POLICY api.portal WITH (STATE = OFF)`, como `sa`). La predicción
es la de M-47: el paciente, con índice en `lab_order.patient_id`, cuesta casi lo mismo con política que sin ella; el médico, cuyo predicado
pasa por `referral`, cuesta más, y el índice que lo arregla está en la tabla protegida, no en la tabla de la subconsulta.

**Rúbrica.** Mide los cuatro casos, los compara con M-47 sin publicar los números, y nombra el índice.

### Ejercicio 15

**Rúbrica (sobre 4 puntos):** 1 punto por el emisor de laboratorio (un servicio que publique `/.well-known/openid-configuration` y un
`jwks.json` con una clave RSA pública, en la red del laboratorio); 1 por `"provider": "Custom"` con `issuer` y `audience` en `dab-config.json`;
1 por la línea 6 con un JWT firmado con otra clave, que da 401 (la matriz de la documentación: *"Yes (invalid) … Rejected (401
Unauthorized)"*); 1 por la línea 2 con un JWT válido que lleva `roles` y `patient_id`, que sigue dando los 1.284 resultados.

### Ejercicio 16

```sql
CREATE SECURITY POLICY api.escritura
ADD BLOCK PREDICATE api.medico_puede_escribir(lab_order_id) ON alameda.result_nuevo AFTER INSERT WITH (STATE = ON);
```

Con `physician_id = 144` en el contexto, el resultado de un protocolo que derivó entra; el de un protocolo de otro médico:

```text
Msg 33504, Level 16, State 1, Server a07be756749e, Line 6
The attempted operation failed because the target object 'ss05.alameda.result_nuevo' has a block predicate that conflicts with this
operation. If the operation is performed on a view, the block predicate might be enforced on the underlying table. Modify the operation to
target only the rows that are allowed by the block predicate.
The statement has been terminated.
```

Es el `new row violates row-level security policy for table "result"` de la Fase 23. Por DAB, el mismo rechazo llega como un error del `POST`;
la entidad necesita `"actions": ["read", "create"]` para el rol `medico`, y la tabla, una clave que DAB conozca.

### Ejercicio 17

**Rúbrica (sobre 3 puntos):** 1 punto por demostrar, con `dbo.resultado` de ss04 y un predicado de filtro sobre la tabla actual, que
`dbo.resultado_historia` sigue mostrando todas las filas a quien la consulta directamente; 1 por citar la documentación de RLS (*"security
predicates on the current table aren't automatically replicated to the history table"*); 1 por la política que agrega el mismo predicado
sobre las dos tablas (`ADD FILTER PREDICATE … ON dbo.resultado, ADD FILTER PREDICATE … ON dbo.resultado_historia`), con la columna que el
predicado necesita presente en las dos.

---

## 🔴 Muy difícil (18–20) — rúbrica

### Ejercicio 18

*PostgREST, DAB o un servicio.*

**Rúbrica (sobre 4 puntos):** 1 punto por cada escenario con su recomendación y su contraargumento (Alameda en Postgres: PostgREST, contra un
servicio propio si la app necesita lógica que no es de la base; en SQL Server con Entra: DAB con `EntraID`, contra el costo de depender de
Azure; en SQL Server sin Entra: DAB con `Custom` contra el proveedor que ya autentica a la app, o un servicio propio, contra el código que
hay que mantener); 1 por exigir en los tres la prueba del ejercicio 20.

### Ejercicio 19

*La propuesta de Florencia, en SQL Server.*

**Rúbrica (sobre 5 puntos):** 1 punto por cada operación de la Fase 20 (buscar por resultado, corregir un antibiótico, el informe del
paciente, el cruce con la forma larga, la escritura concurrente) con la apuesta escrita antes de medir, resuelta en la máquina del lector y
explicada con el plan; ningún número de SQL Server en la respuesta. La conclusión que se espera: el tipo `json` acerca a SQL Server a lo que
`jsonb` ya hacía, y el veredicto de la Fase 20 no cambia porque se apoyaba en la auditoría y el cruce, que siguen siendo relacionales.

### Ejercicio 20

*La prueba que tiene que fallar.*

**Rúbrica (sobre 4 puntos):** 1 punto por la prueba (fabrica un `X-MS-CLIENT-PRINCIPAL` y un JWT firmado con otra clave, y exige 401 en los
dos); 1 por correr contra la API desplegada, no contra un DAB de pruebas; 1 por el lugar (después del despliegue a cada ambiente, antes de
abrir tráfico); 1 por lo que hace si falla: revierte el despliegue y avisa, porque una API que acepta identidades fabricadas no puede quedar
abierta ni un minuto.

---

## 🔥 Opcionales

### Ejercicio 🔥 1

**Rúbrica.** La entidad `cultivos` sobre `staging.culture_doc`, con una política que compare `person_id` con un *claim* (la verdad del
generador une persona y paciente; el portal usa el `patient_id`, así que hace falta la tabla que los une). La respuesta dice cómo devuelve DAB
la columna `json` (como texto JSON dentro del campo, o como objeto anidado), comprobado con un pedido, y que el cliente tiene que leer cada
caso distinto.
