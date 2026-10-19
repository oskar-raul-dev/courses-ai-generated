# 🪟 SQL Server 05 — Data API builder y el tipo `json`: el contrato de la Fase 23 sobre el motor original, y el antibiograma como documento

> **Curso:** Ruta SQL · Track SQL Server · ss05 de ss05 · **8 h** · opcional
> **Motor:** SQL Server 2025 CU9 (17.0.5005.3), Enterprise Developer, `mcr.microsoft.com/mssql/server@sha256:2b5b58162112…` · Data API builder 2.1.5, `mcr.microsoft.com/azure-databases/data-api-builder@sha256:d07e3e1ce53b…` · los dos emulados en Apple Silicon
> **Entorno de ejecución:** SQL (T-SQL) + Python + HTTP
> **Requisito del camino base:** Fases 19 y 23 · **Requisito del track:** [ss01](ss01-la-base-en-su-motor-original.md) (el `sqlcmd.sh` y el extra `sqlserver`)
> **El dolor de Alameda:** la app de 2024 que pide los resultados y abre un enlace al portal de 2013 ([historia](00-historia-de-alameda.md), 2024), y el antibiograma que la Fase 20 propuso como documento
> **Fecha de verificación ejecutada:** 18/10/2026
> **Objetivo:** publicar el mismo contrato de la Fase 23 sobre SQL Server con Data API builder y su seguridad por fila, guardar el antibiograma con el tipo `json` de 2025, y saber dónde está la confianza en cada uno.

---

## 🧭 1. Dónde estamos

La [Fase 23](23-la-base-como-producto.md) convirtió la base en un producto: un esquema `api` de vistas, PostgREST delante, un JWT
firmado que dice quién es cada uno y la seguridad por fila de Postgres que decide qué ve. El paciente 39 veía sus resultados, el médico
144 los protocolos que derivó, y nadie veía lo ajeno ([M-48](bitacora-de-medicion.md#m-48--f23--la-api-con-postgrest-vista-desde-afuera)).
La [Fase 19](19-json-en-los-motores.md) guardó el antibiograma como documento `jsonb` y midió su búsqueda con GIN
([M-35](bitacora-de-medicion.md#m-35--f19--el-antibiograma-como-documento-en-la-búsqueda-por-un-resultado)).

SQL Server tiene respuestas propias para las dos cosas. **Data API builder** (DAB) es el PostgREST de Microsoft: un servicio de código
abierto, con licencia MIT, que lee un archivo de configuración y publica tablas y vistas como REST y GraphQL. Y SQL Server 2025 trae un
**tipo `json` nativo**, con índice propio, que hasta 2022 no existía: el JSON se guardaba en `nvarchar(max)`. Esta fase arma el mismo
contrato de la Fase 23 sobre el motor original y mira, en cada pieza, **dónde está la confianza**.

`01_modelo.py` copia a una base aparte, `ss05`, el modelo que publicó la Fase 23: 1.327.622 protocolos, sus 1.327.622 derivaciones, 210
analitos y 12.710.308 resultados, y los 60.001 antibiogramas de la Fase 19. Los cuenta en los dos motores al terminar, y dan iguales. Los
resultados ya no son los 12,1 millones de la Fase 23: la [Fase 25](25-la-migracion-sin-parar.md) sumó los de las tablas anchas.

> 📝 **La regla del track, y lo que esta fase sí publica.** De SQL Server no se publica ninguna lectura ni ningún tiempo. Sí se publica
> lo que contesta la API (los códigos HTTP y cuántas filas devuelve, que son datos de la caja, iguales en Postgres), los mensajes, lo que
> DAB le manda al motor y la estructura de los planes. DAB es software abierto, y lo que hace se cuenta entero
> ([`a09`](a09-licencias-publicacion-y-riesgo.md#-qué-sí-se-publica-de-oracle-y-de-sql-server)).

---

## 🎯 2. Objetivos de esta fase

1. Publicar `api.resultados` y `api.protocolos` con DAB, con un rol por perfil, y contestar desde afuera los mismos pedidos que la Fase 23.
2. Escribir la seguridad por fila de SQL Server (`CREATE SECURITY POLICY`) con los *claims* que DAB pone en `SESSION_CONTEXT`, y ver en
   una traza qué le manda DAB al motor en cada pedido.
3. Explicar dónde valida la identidad cada proveedor de DAB, y romper el que confía en un encabezado.
4. Guardar el antibiograma con el tipo `json`, buscarlo con `JSON_VALUE` y `JSON_CONTAINS`, corregirlo con `.modify()` e indexarlo de dos
   maneras.
5. Decidir, para el portal de Alameda, entre PostgREST, DAB y un servicio escrito a mano.

---

## 🚫 3. Qué NO entra todavía

- **La autenticación con Microsoft Entra ID**, que es como se usa DAB en producción: exige un inquilino de Azure, y se nombra en la
  sección 8 → [ssa-01](ssa-01-que-cambia-en-windows.md) para la autenticación integrada en general.
- **El protocolo MCP de DAB** (DAB 2.x lo trae para agentes de IA): fuera del curso.
- **Los vectores y las funciones de IA de 2025**: fuera del curso; algunas están en *preview*.
- **El *broker* y el *outbox***: los midió la [Fase 22](22-la-exportacion-de-las-9-40.md) en Postgres, y el track no los repite.

---

## 🏚️ 4. El dolor, en la caja

La app de 2024 (Node.js sobre MongoDB Atlas) es lo que los pacientes más usan, y lo que más le piden son los resultados, que hoy abren
un enlace al portal PHP de 2013. La Fase 23 lo resolvió con PostgREST. Si Alameda se queda en SQL Server, el equipo digital de
Horizonte va a proponer lo que propone Microsoft para lo mismo: DAB. `02_api.sql` arma las mismas vistas y una política de seguridad por
fila; `dab-config.json` las publica; y `03_api.py` hace desde afuera los pedidos de la Fase 23:

```text
1 · sin identidad: HTTP 403 · Authorization Failure: Access Not Allowed.
2 · paciente 39: HTTP 200 · 1284 resultados · protocolos distintos 152
3 · paciente 39 pide el protocolo -2147402959 (del paciente 12594): HTTP 200 · []
4 · médico 144: HTTP 200 · 1114 protocolos
5 · paciente 39 sin X-MS-API-ROLE: HTTP 403 · Authorization Failure: Access Not Allowed.
6 · cualquiera escribe la identidad del paciente 12594: HTTP 200 · 115 resultados ajenos
```

Las primeras cinco líneas son el contrato de la Fase 23, cumplido: el paciente 39 ve sus 1.284 resultados en 152 protocolos, los mismos
que cuenta Postgres sobre el mismo modelo; el protocolo de otro paciente es una lista vacía, no un error; el médico 144 ve sus 1.114
protocolos, los de M-48. La sexta es el dolor de esta fase, y la sección 8 la explica: el proveedor de identidad con que corre el
laboratorio le cree a cualquiera que escriba un encabezado.

> 🏚️ **De la historia:** en 2018, la agencia que mantiene el portal *"arregla"* la URL `resultados.php?prot=2010-045123` pasándola a MD5
> del número de protocolo, y la Fase 23 lo desarmó en una línea: un MD5 de algo que se puede adivinar no es un secreto. La línea 6 es la
> misma clase de error con otra forma.

---

## 🧩 5. El contrato, la seguridad y el documento

### 5.1 Data API builder

DAB no lee el catálogo entero, como PostgREST: publica **solo lo que dice su archivo de configuración**. La documentación lo dice así:
*"By default, an entity has no permissions configured, which means no one can access the entity. Additionally, Data API builder ignores
database objects when they aren't referenced in the runtime configuration."* `dab-config.json` declara dos entidades:

```json
"resultados": {
  "source": { "object": "api.resultados", "type": "view", "key-fields": [ "result_id" ] },
  "permissions": [ { "role": "paciente", "actions": [ "read" ] }, { "role": "medico", "actions": [ "read" ] } ]
}
```

Cada pedido se evalúa con **un** rol. Sin identidad es `Anonymous`; con identidad y sin encabezado `X-MS-API-ROLE`, es `Authenticated`;
con el encabezado, el rol que nombra, si la identidad lo tiene entre sus *claims* `roles`. Ni `Anonymous` ni `Authenticated` tienen
permisos aquí: por eso las líneas 1 y 5 son un 403. Es el mismo modelo de la Fase 23 con otra mecánica: PostgREST cambia de rol de Postgres
según el JWT (`SET ROLE paciente`); DAB entra siempre con el mismo *login* (`dab_api`, que solo puede leer el esquema `api`) y decide el
rol en su propia capa.

Lo mismo se pide por GraphQL, sin escribir nada más:

```text
POST /graphql  { protocolos(first: 3, orderBy: {ordered_on: DESC}) { items { lab_order_id ordered_on site_code } } }
{'data': {'protocolos': {'items': [{'lab_order_id': 11044977, 'ordered_on': '2025-10-20T00:00:00Z', 'site_code': 'C'}, …]}}}
```

### 5.2 La seguridad por fila de SQL Server

SQL Server la tiene desde 2016, con otra forma que Postgres: un **predicado** (una función de tabla en línea, `WITH SCHEMABINDING`) y una
**política** que lo aplica a una o varias tablas.

```sql
CREATE FUNCTION api.puede_ver (@lab_order_id int, @patient_id int)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT 1 AS ok
WHERE (CAST(SESSION_CONTEXT(N'roles') AS nvarchar(20)) = N'paciente'
       AND @patient_id = TRY_CAST(CAST(SESSION_CONTEXT(N'patient_id') AS nvarchar(20)) AS int))
   OR (CAST(SESSION_CONTEXT(N'roles') AS nvarchar(20)) = N'medico'
       AND EXISTS (SELECT 1 FROM alameda.referral AS f WHERE f.lab_order_id = @lab_order_id
                     AND f.physician_id = TRY_CAST(CAST(SESSION_CONTEXT(N'physician_id') AS nvarchar(20)) AS int)))
   OR IS_SRVROLEMEMBER(N'sysadmin') = 1;

CREATE SECURITY POLICY api.portal
ADD FILTER PREDICATE api.puede_ver(lab_order_id, patient_id) ON alameda.lab_order,
ADD FILTER PREDICATE api.puede_ver_resultado(lab_order_id) ON alameda.result
WITH (STATE = ON);
```

La última línea del predicado no es un descuido. La documentación es explícita: *"Security policies apply to all users, including dbo
users in the database"*, y si un administrador necesita ver todo, *"the security policy must be written to allow that"*. En Postgres es al
revés: el superusuario y el dueño de la tabla no pasan por RLS, y la Fase 23 tuvo que cuidar que las vistas tuvieran `security_invoker`.
En SQL Server, el `sa` que corre los scripts del laboratorio vería cero filas si el predicado no lo nombrara.

¿De dónde salen `roles`, `patient_id` y `physician_id`? De DAB, que con `set-session-context` pasa cada *claim* de la identidad a
`SESSION_CONTEXT` antes de cada consulta. Una traza de *Extended Events* sobre `ss05` muestra lo que llega al motor en un pedido:

```text
usuario texto
dab_api exec sp_reset_connection
dab_api exec sp_executesql N'EXEC sp_set_session_context @session_key0, @session_param0, @read_only = 0;EXEC sp_set_session_context
        @session_key1, @session_param1, @read_only = 0;EXEC sp_set_session_context @session_key2, @session_param2, @read_only = 0;SELECT TOP …
```

Tres cosas en esas dos líneas. El *pool* de conexiones se resetea entre pedidos (`sp_reset_connection`), y con él el contexto del pedido
anterior. Los valores van como parámetros, no pegados al texto. Y van con `@read_only = 0`: la documentación de RLS recomienda lo
contrario (*"Setting the `@read_only` parameter to `1` prevents the value from changing again until the connection is closed"*), porque
un contexto escribible lo puede cambiar cualquier código que corra en esa conexión. DAB no expone nada que lo haga, y aun así es un
supuesto que la base no puede verificar. La documentación de DAB agrega un costo: con `set-session-context`, *"response caching is
disabled for the data source"*.

> 🩻 **Esto sí funciona igual.** Lo que ve cada perfil, contado desde afuera, es el de la Fase 23: el mismo modelo, la misma regla
> ("el paciente, lo suyo; el médico, lo que derivó") y la misma respuesta vacía para lo ajeno. La seguridad por fila de los dos motores
> es un filtro que el motor agrega a toda consulta, la pida o no quien la escribe.

### 5.3 El tipo `json`

Hasta SQL Server 2022, un documento JSON se guardaba en `nvarchar(max)`, y cada consulta lo volvía a leer como texto. SQL Server 2025 trae
`json`, que según su documentación se guarda en un formato binario nativo, se valida al escribir y tiene métodos propios. `01_modelo.py`
copia los 60.001 antibiogramas de la Fase 19 a `staging.culture_doc` con la columna `antibiogram json`. `04_json.sql` hace las preguntas de
la Fase 19:

```text
cultivos meropenem_r ciprofloxacina_r
60001    600         13303
```

Son los 600 y los 13.303 de M-35: los mismos cultivos, contados en el otro motor. La pregunta se escribe de dos maneras: con
`JSON_VALUE(antibiogram, '$.MEROPENEM') = 'R'`, que existe desde 2016, o con `JSON_CONTAINS(antibiogram, 'R', '$.MEROPENEM') = 1`, que es
de 2025 y equivale al `@>` de `jsonb`. Corregir un antibiótico ya no es reescribir el documento: `UPDATE … SET antibiogram.modify('$.MEROPENEM',
'I')`. Y armar el documento desde filas, como el `jsonb_object_agg` de la Fase 19, es `JSON_OBJECTAGG` (también de 2025).

El tipo **valida**. El documento con una coma de más no entra:

```text
Msg 13609, Level 16, State 9, Server a07be756749e, Line 2
JSON text is not properly formatted. Unexpected character '}' is found at position 18.
```

Con `nvarchar(max)`, la validación era un `CHECK (ISJSON(antibiogram) = 1)` que alguien tenía que acordarse de poner.

### 5.4 Dos maneras de indexar un documento

`CREATE JSON INDEX` (2025) indexa todas las rutas del documento, como el GIN de la Fase 19. La documentación pone tres condiciones: la tabla
necesita una **clave primaria agrupada**, hay **un solo índice JSON por columna** y se construye **fuera de línea** (*"online index builds
aren't supported for JSON indexes"*). La manera de antes de 2025 es una **columna calculada** con la ruta que importa y un índice común
sobre ella. Las estructuras de los planes, de `SHOWPLAN_XML`:

```text
sin índices · JSON_VALUE y JSON_CONTAINS
  Stream Aggregate (Aggregate)
    Filter
      Clustered Index Scan on culture_doc.PK__culture…

con el índice JSON · JSON_VALUE
  Stream Aggregate (Aggregate)
    Hash Match (Inner Join)
      Filter
        Clustered Index Seek on json_index_….culture_doc_ji
      Index Scan on culture_doc.culture_doc_meropenem_idx

con la columna calculada · meropenem = 'R'
  Stream Aggregate (Aggregate)
    Index Seek on culture_doc.culture_doc_meropenem_idx
```

Sin índice, cualquier pregunta recorre los 60.001 documentos. El índice JSON es una tabla interna (`json_index_…`) con su propia clave
agrupada, donde el plan busca la ruta y el valor; la columna calculada es un índice común con una búsqueda. Cuánto lee cada una es la
apuesta de la sección 7.

---

## 🔀 6. El contraste: dónde otro motor cambia la decisión

**Quién valida la identidad.** PostgREST valida el JWT con el secreto que tiene en su configuración: un token alterado es un 401 (M-48).
DAB delega en un **proveedor**: con `EntraID` (o `AzureAD`) y `Custom`, valida un JWT contra el emisor; con `AppService`, confía en el
encabezado que inyecta App Service después de autenticar; con `Simulator`, *"requests are treated as `authenticated` for
development/testing, without validating a real token"*. La decisión cambia: con PostgREST, la API es la frontera; con DAB y `AppService`,
la frontera es **lo que esté delante**, y si no hay nada delante, no hay frontera (sección 8).

**Cómo llega el usuario a la base.** PostgREST cambia de rol de Postgres en cada pedido, y los *claims* quedan en `request.jwt.claims`; la
base sabe qué rol es. DAB entra siempre como `dab_api`, y lo que sabe del usuario es lo que DAB le pone en `SESSION_CONTEXT`. Un permiso de
Postgres (`GRANT SELECT … TO paciente`) es una segunda barrera; en SQL Server, con DAB, la única barrera de la base es el predicado.

**Quién pasa por RLS.** En Postgres, el superusuario y el dueño de la tabla no; en SQL Server, todos, hasta que el predicado diga otra cosa.
Es más seguro por defecto y más fácil de equivocar al revés: un predicado que no nombra al administrador deja a los procesos de
mantenimiento sin ver nada, sin error.

**El documento.** `jsonb` normaliza el documento: la documentación de Postgres dice que ordena las claves y que, con una clave
repetida, *"only the last value is kept"*. GIN tiene dos clases de operadores, que la Fase 19 midió por separado. El `json` de SQL Server se
valida y se guarda en binario, su índice es uno por columna, con todas las rutas o con las que se nombren, y qué hace con una clave
repetida es el ejercicio 5: si los dos motores no conservan el mismo valor, migrar documentos de uno a otro cambia datos sin avisar. En Postgres, la salida para una sola ruta muy consultada es la misma que aquí: un índice de expresión sobre
`(antibiogram ->> 'MEROPENEM')`.

| | Postgres y PostgREST (Fases 19 y 23, publicado) | SQL Server y DAB |
|---|---|---|
| sin identidad | 401 | 403 (sección 4) |
| paciente 39 | sus resultados (426 en la Fase 23, antes de la Fase 25) | sus 1.284, los mismos que Postgres hoy |
| identidad alterada | 401: el JWT no valida | depende del proveedor; con `AppService`, 200 (sección 8) |
| documento, búsqueda rara (meropenem) | GIN `jsonb_path_ops`: 527 bloques, el 27 % del *seq scan* (M-35) | índice JSON o columna calculada: 🪞🔒 |
| documento, búsqueda común (ciprofloxacina, 22 %) | el índice no ayuda (M-35) | 🪞🔒 |

---

## 🪞 7. Tu instinto dice… y la apuesta

*"Si el motor tiene un índice para JSON, es el que conviene: indexa todo, y no hay que saber de antemano qué se va a buscar."* Es el
instinto que la Fase 19 ya puso a prueba en Postgres, y que perdió en parte: el GIN ayudó con lo raro y no con lo común.

> 🪞🔒 **Apuesta sin resolver: SQL Server.** Hipótesis: para meropenem R (600 de 60.001), el índice JSON lee **menos del 10 %** de lo que
> lee el recorrido de la clave agrupada, y la columna calculada con su índice lee **menos que el índice JSON**; para ciprofloxacina R
> (13.303, el 22 %), el índice JSON lee más del 15 % del recorrido. Condiciones: `staging.culture_doc` de `ss05`, los dos índices de
> `04_json.sql`. Resuélvela: las consultas de `04_json.sql` con `SET STATISTICS IO ON`, o la estructura y las lecturas con
> `lab measure --engine sqlserver --private` contra `ss05`. El mecanismo, en la página de `CREATE JSON INDEX` (en las referencias).
> 📝 No publicamos el resultado: la licencia de SQL Server Developer no permite divulgar resultados de pruebas sin permiso de Microsoft
> ([`a09`](a09-licencias-publicacion-y-riesgo.md#-sql-server-la-cláusula-tal-cual)).

> 🪞🔒 **Apuesta sin resolver: SQL Server.** Hipótesis: el portal del paciente por DAB, con la política de `02_api.sql`, lee del orden de
> lo que lee sin la política, porque el predicado del paciente usa el índice por `patient_id`; el del médico, que pasa por `referral`, lee
> varias veces más. Es la apuesta de M-47 en el otro motor. Resuélvela: `SET STATISTICS IO ON` con `sp_set_session_context` a mano, como
> paciente y como médico, con la política encendida y apagada (`ALTER SECURITY POLICY api.portal WITH (STATE = OFF)`).

**Resultado:** sin publicar. Lo que ya está publicado alcanza para la decisión: la estructura muestra que las dos maneras de indexar
buscan, y la Fase 19 midió que, para una búsqueda común, ningún índice evita leer buena parte de la tabla.

---

## 💥 8. El punto de rotura

La línea 6 de la sección 4. `dab-config.json` usa el proveedor `AppService`, el de *Easy Auth*: en Azure App Service, la plataforma
autentica al usuario y le pasa a la aplicación la identidad en el encabezado `X-MS-CLIENT-PRINCIPAL`, un JSON en base64 con los *claims*.
La documentación de DAB lo describe así: *"platform-injected headers (such as `X-MS-CLIENT-PRINCIPAL`) establish authentication rather
than a bearer token"*. DAB no verifica nada: no hay firma. Confía en que nadie más que la plataforma pudo escribir ese encabezado.

En el laboratorio no hay plataforma delante. `03_api.py` arma el encabezado de un paciente que no es (`patient_id` 12594) y DAB lo
atiende:

```text
6 · cualquiera escribe la identidad del paciente 12594: HTTP 200 · 115 resultados ajenos
```

La seguridad por fila de SQL Server hizo exactamente lo que tenía que hacer: filtró por el `patient_id` que le llegó. El problema está
antes. Es el MD5 de 2018 otra vez: lo que la aplicación usa como prueba de identidad lo puede fabricar cualquiera.

**Qué hay que cambiar para salir:** o DAB queda detrás de App Service y **solo** recibe tráfico de ahí, o el proveedor valida un token:
`EntraID` con un inquilino de Microsoft Entra, o `Custom` con el emisor y la audiencia de un proveedor OIDC propio. En los dos, una
identidad alterada es un 401, como en PostgREST. `AppService` y `Simulator` son para desarrollo, y `"mode": "development"` lo dice en el
mismo archivo. Que el laboratorio funcione con ellos es justamente el riesgo: funciona igual de bien con un encabezado falso.

Hay una segunda rotura, más chica, en la línea de GraphQL de la sección 5.1: `ordered_on` es una columna `date`, y DAB la devuelve como
`'2025-10-20T00:00:00Z'`, medianoche en UTC. Un cliente en Córdoba que la convierte a su hora la muestra como el 19 de octubre a las 21.
Es la hora de [ss04](ss04-clustered-newsequentialid-y-temporales.md) en otra capa: un día sin hora no debería tener zona, y la API se la
puso.

---

## ⚰️ 9. Autopsia: el MD5 del número de protocolo, en otro encabezado

**1. La decisión.** La de 2018: *"Que el enlace del resultado no sea el número de protocolo, que se adivina."* La agencia lo pasó a MD5. En
esta fase, la misma decisión tiene otra forma: *"Que DAB use el proveedor de App Service, que es el que trae la plantilla, y después lo
ponemos detrás del portal."*

**2. Por qué era razonable.** En 2018, el MD5 parecía un identificador opaco, y lo era para quien no supiera cómo se armaba. En 2026, el
proveedor `AppService` es el que la documentación usa en sus ejemplos, el que funciona en una máquina sin Azure, y el que es correcto **en
App Service**.

**3. Qué pasa después.** El MD5 se calculaba desde el número de protocolo, que es secuencial: cualquiera recorría los resultados de todos
(la Fase 23 lo midió). El encabezado de `AppService` se arma desde un JSON con el `patient_id`: cualquiera es cualquier paciente, si DAB
recibe tráfico que no pasó por App Service. Un puerto abierto de más, una regla de red que nadie revisó, un proxy que reenvía encabezados,
y la línea 6 está en producción.

**4. Cuánto cuesta salir.** Poco, si se decide antes: un proveedor que valida un token (`EntraID` o `Custom`) y una prueba como la línea 6
en la integración continua, que tiene que dar 401. Mucho, si se descubre después: no hay forma de saber, por los registros de DAB, qué
pedidos traían una identidad fabricada.

**5. Qué lo habría cambiado.** *¿Qué prueba tiene la API de que este usuario es quien dice ser, y quién puede fabricar esa prueba?* Si la
respuesta es "nadie, porque está detrás de algo", la seguridad es de ese algo, y hay que probarla ahí.

**Antes y después, con números:** con `AppService` y sin plataforma delante, el encabezado del paciente 12594 da 115 resultados ajenos; con
un proveedor que valida un token, el mismo pedido es un 401 sin filas, como el token alterado de la Fase 23.

---

## 📖 10. Traducción

| SQL Server y DAB | Postgres y PostgREST | Lo que cambia |
|---|---|---|
| `dab-config.json`, entidades | el esquema expuesto (`db-schemas`) | DAB publica solo lo declarado |
| roles de DAB y `X-MS-API-ROLE` | roles de Postgres y el *claim* `role` | quién decide el rol |
| `set-session-context` → `SESSION_CONTEXT(N'…')` | `request.jwt.claims` → `current_setting(…)` | por parámetro, escribible |
| `CREATE SECURITY POLICY` + predicado | `CREATE POLICY … USING (…)` | todos pasan por RLS, hasta `sa` |
| `AppService` / `Simulator` | — (PostgREST valida siempre el JWT) | la confianza en lo que está delante |
| `EntraID` / `Custom` | `jwt-secret` o JWKS | — |
| `json` (binario, validado) | `jsonb` | las claves repetidas (ejercicio 5) |
| `JSON_VALUE`, `JSON_CONTAINS` | `->>`, `@>` | — |
| `.modify('$.ruta', valor)` | `jsonb_set` | — |
| `JSON_OBJECTAGG` | `jsonb_object_agg` | — |
| `CREATE JSON INDEX` (uno por columna) | GIN (`jsonb_ops`, `jsonb_path_ops`) | una clase contra dos |
| columna calculada + índice | índice de expresión | el mismo recurso |
| `$after` (cursor por clave) | `Range` o `offset` | DAB pagina por clave |

Más en [`a07`](a07-diccionario-y-glosario.md).

---

## ⚖️ 11. Veredicto honesto: cuándo NO usar esto

**No pongas DAB con `AppService` o `Simulator` en un lugar al que llegue tráfico que no pasó por App Service.** Es la línea 6. Para el
portal de Alameda, DAB va con `EntraID` (si Horizonte tiene Entra) o con `Custom` contra el proveedor que ya autentica a los pacientes de
la app.

**Con Postgres, PostgREST sigue siendo la opción**: es más chico y valida el JWT por su cuenta. DAB gana cuando la casa ya está en Azure y
en Entra.

**No conviertas `nvarchar(max)` a `json` sin probar la conversión.** El tipo valida: un documento que hasta ayer entraba como texto puede no
entrar ahora, y la conversión falla en la primera fila mala (Msg 13609). Primero `ISJSON`, después el tipo.

**No pongas un índice JSON de todas las rutas para una sola pregunta.** Para meropenem en el portal, una columna calculada con su índice es
más chica, se construye en línea y no exige nada de la tabla.

**Las cinco preguntas:** el **acceso** es por paciente y por médico, como en la Fase 23; la **consistencia** de lo que ve cada uno la da la
política, y la de quién es cada uno la da el proveedor, no la base; la **escala** del predicado depende de su índice, como midió M-47;
la **evolución** del contrato es un archivo versionable, igual que el esquema `api`; la **operación** suma una pregunta que PostgREST no
tenía: qué está delante de la API.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **Todo 403:** `Authorization Failure: Access Not Allowed.` → el pedido no trae `X-MS-API-ROLE`, o el rol no está en los *claims*, o la
  entidad no tiene permisos para ese rol → 🩺 el registro de DAB dice qué rol evaluó. E-95.
- **Cero filas sin error:** ninguno → el predicado no encuentra los *claims* (`SESSION_CONTEXT` NULL) o no nombra al administrador → 🩺
  `SELECT SESSION_CONTEXT(N'patient_id')` en la misma conexión, y `sys.security_policies`.
- **El documento que no entra:** `Msg 13609 JSON text is not properly formatted` → validar con `ISJSON` antes de convertir. E-96.
- **El índice JSON que no se crea:** `Msg 13672 Table '…' needs to have a clustered primary key with less than 32 columns in it in order
  to create a JSON index on it` → clave primaria agrupada primero. E-97.
- **`QUOTED_IDENTIFIER`:** los métodos de `json` lo exigen, y `sqlcmd` lo trae apagado (E-87). `04_json.sql` lo enciende en su primera
  línea.
- **DAB no vuelve después de recrear SQL Server:** `HTTP 500 … The server was not found or was not accessible`, `Error Number:11001`
  en el registro de DAB → DAB guardó la resolución del nombre `sqlserver` → reiniciar DAB después de recrear el contenedor del motor. E-99.
- **El contenedor de SQL Server que muere:** sin mensaje; `docker inspect` dice `OOMKilled=true` → en esta verificación, en un Mac con
  la emulación, recorrer muchas veces los 12,7 millones de resultados lo llevó al límite con 2, 3 y 4 GB, también con `max server memory`
  en 1.024 MB → las consultas de esta fase van por índice; un recorrido entero de `alameda.result`, de a uno. E-98.

---

## 📋 13. Checklist de validación

```text
[ ] 01_modelo.py copió las cinco tablas con los mismos conteos en los dos motores
[ ] 02_api.sql dejó la política api.portal encendida, y dab_api solo lee el esquema api
[ ] uv run lab up sqlserver dab levanta DAB, y 03_api.py da las seis líneas de la sección 4
[ ] puedes explicar la línea 6 y cómo se convierte en un 401
[ ] 04_json.sql da 600 y 13.303, corrige y deja como estaba el cultivo, y rechaza el documento roto
[ ] resolviste las dos apuestas de la sección 7, sin publicar los números
[ ] dejaste ss05 con sus dos índices y la política encendida
```

---

## 🧪 14. Ejercicios (20)

## 🟢 Fácil — el contrato (1–6)

### 🟢 Ejercicio 1 — Las seis líneas

Levanta DAB (`uv run lab up sqlserver dab`) y corre `03_api.py`.

**Objetivo:** las seis líneas de la sección 4, y para cada una, qué rol evaluó DAB.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-1)

### 🟢 Ejercicio 2 — El encabezado por dentro

Decodifica el `X-MS-CLIENT-PRINCIPAL` que arma `03_api.py` para el paciente 39.

**Objetivo:** el JSON, y cuáles de sus *claims* terminan en `SESSION_CONTEXT` según la traza de la sección 5.2.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-2)

### 🟢 Ejercicio 3 — Lo que la base ve

Como `sa`, haz `EXEC sp_set_session_context N'roles', N'paciente'; EXEC sp_set_session_context N'patient_id', N'39';` y cuenta
`api.resultados`.

**Pregunta:** ¿cuántas filas ves, y por qué `sa` ve todas si no fija el contexto? Señala la línea del predicado responsable.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-3)

### 🟢 Ejercicio 4 — GraphQL

Pide por GraphQL los últimos tres protocolos del paciente 39 y los resultados de glucosa de uno de ellos.

**Objetivo:** las dos consultas, y la diferencia con hacer lo mismo por REST con `$filter` y `$select`.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-4)

### 🟢 Ejercicio 5 — El documento roto

Intenta insertar en `staging.culture_doc` tres documentos inválidos distintos (una coma de más, una comilla simple, una clave sin
comillas), y uno válido con una clave repetida (`{"AMPICILINA": "R", "AMPICILINA": "S"}`).

**Objetivo:** el mensaje de cada inválido, qué valor de ampicilina queda en el repetido, y la misma prueba en `jsonb` de Postgres.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-5)

### 🟢 Ejercicio 6 — `legacy` en Postgres: lo que ve el paciente

En Postgres, cuenta los resultados y los protocolos del paciente 39 en el modelo, y cuántos de esos resultados vinieron de las tablas
anchas de la Fase 25.

**Objetivo:** los 1.284 y 152 de la sección 4, y la diferencia con los 426 de la Fase 23 explicada por la migración.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-6)

## 🟡 Intermedio — la confianza (7–12)

### 🟡 Ejercicio 7 — El contexto escribible

En una sesión con el contexto del paciente 39, vuelve a fijar `patient_id` en 12594 y cuenta `api.resultados`. Después repítelo con el
primer `sp_set_session_context` hecho con `@read_only = 1`.

**Objetivo:** el resultado de cada caso y el mensaje del segundo, y qué tendría que exponer DAB para que el primero fuera un problema.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-7)

### 🟡 Ejercicio 8 — El cursor de la paginación

Pide `api/resultados?$first=3` como el paciente 39 y decodifica el `$after` del `nextLink`.

**Pregunta:** ¿qué dice el cursor, qué tipo de paginación es (Fase 14), y qué le revela a quien lo lee?

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-8)

### 🟡 Ejercicio 9 — La fecha con zona

La columna `ordered_on` es `date`, y GraphQL la devuelve como `'2025-10-20T00:00:00Z'`.

**Objetivo:** mostrar en un cliente (Python con `datetime` y la zona de Córdoba) cómo se convierte en el 19, y proponer dos salidas: una en
la vista y otra en el cliente.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-9)

### 🟡 Ejercicio 10 — La política por sede

Agrega un rol `sede`, con un *claim* `site_code`, que ve los protocolos de su sede.

**Objetivo:** el cambio al predicado, la entrada en `dab-config.json` y el pedido de la sede `V` que devuelve sus protocolos y ninguno del
central.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-10)

### 🟡 Ejercicio 11 — `JSON_CONTAINS` y `@>`

Cuenta los cultivos con ampicilina R **y** gentamicina S, con `JSON_CONTAINS` en SQL Server y con `@>` en Postgres.

**Objetivo:** las dos consultas y el mismo conteo en los dos motores (que es de la caja).

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-11)

### 🟡 Ejercicio 12 — Del documento a filas

Convierte `staging.culture_doc` de vuelta a la forma larga (una fila por cultivo y antibiótico) con `OPENJSON`.

**Objetivo:** la consulta, y que el total de filas coincida con el de `staging.antibiogram_long` de la Fase 19 en Postgres.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-12)

## 🟠 Difícil — medir y cerrar (13–17)

### 🟠 Ejercicio 13 — La primera apuesta

Resuelve la apuesta de los índices con `SET STATISTICS IO ON`.

**Objetivo:** explicar el resultado con la estructura de los tres planes de la sección 5.4 y compararlo con M-35, sin publicar los números.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-13)

### 🟠 Ejercicio 14 — La segunda apuesta

Resuelve la apuesta de lo que cuesta la política, como paciente y como médico.

**Objetivo:** el resultado comparado con M-47, y dónde tendría que estar el índice para que el médico cueste como el paciente.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-14)

### 🟠 Ejercicio 15 — Un proveedor que valida

Configura DAB con el proveedor `Custom`, con un emisor OIDC de laboratorio (un servicio que publique su `/.well-known/openid-configuration`
y sus claves), y repite la línea 6.

**Objetivo:** la línea 6 da 401, y la línea 2 sigue dando los 1.284 resultados con un token firmado.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-15)

### 🟠 Ejercicio 16 — El bloqueo de escritura

Dale al médico permiso de `create` sobre una entidad de resultados y agrega a la política un predicado de bloqueo (`BLOCK PREDICATE …
AFTER INSERT`).

**Objetivo:** un `POST` de un resultado para un protocolo que el médico no derivó, rechazado, con el mensaje de SQL Server, contra el
`new row violates row-level security policy` de la Fase 23.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-16)

### 🟠 Ejercicio 17 — La historia y la política

La documentación de RLS dice que una política sobre una tabla temporal no se copia a su tabla de historia.

**Objetivo:** demostrarlo con `dbo.resultado` de [ss04](ss04-clustered-newsequentialid-y-temporales.md) y una política por sede, y escribir
la política que cubre las dos tablas.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-17)

## 🔴 Muy difícil — decidir (18–20)

### 🔴 Ejercicio 18 — PostgREST, DAB o un servicio

El equipo digital de Horizonte tiene que publicar los resultados para la app.

**Objetivo:** una recomendación con su mejor contraargumento, en tres escenarios: Alameda en Postgres, Alameda en SQL Server con Entra, y
Alameda en SQL Server sin Entra.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-18)

### 🔴 Ejercicio 19 — La propuesta de Florencia, en SQL Server

La [Fase 20](20-la-propuesta-de-florencia.md) midió en Postgres y en MongoDB las cinco operaciones del antibiograma en tres diseños.

**Objetivo:** el diseño con `json` en SQL Server para las cinco, con la apuesta de cada una escrita antes de medir y resuelta en tu
máquina, y qué cambia en el veredicto de la Fase 20. No publiques los números.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-19)

### 🔴 Ejercicio 20 — La prueba que tiene que fallar

Escribe la prueba de integración que impide que la línea 6 llegue a producción.

**Objetivo:** una prueba que corre contra la API desplegada, fabrica una identidad y exige un 401, y el lugar del ciclo de entrega donde
corre, con lo que hace si falla.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio-20)

## 🔥 Opcionales

### 🔥 Ejercicio 🔥 1 — El antibiograma por DAB

Publica `staging.culture_doc` por DAB y pide los cultivos de una persona.

**Objetivo:** cómo devuelve DAB la columna `json` (texto o documento), y una política para que cada paciente vea solo sus cultivos.

[Solución](soluciones/ss05-data-api-builder-y-json.md#ejercicio--1)

---

## 📚 15. Referencias

**Data API builder**

- **Visión general** — https://learn.microsoft.com/en-us/azure/data-api-builder/overview
- **Autorización y roles** — https://learn.microsoft.com/en-us/azure/data-api-builder/concept/security/authorization-overview
- **Seguridad por fila con `SESSION_CONTEXT`** — https://learn.microsoft.com/en-us/azure/data-api-builder/concept/security/row-level-security
- **Novedades de la versión 2.0** — https://learn.microsoft.com/en-us/azure/data-api-builder/whats-new/version-2-0
- **El repositorio, con la licencia MIT** — https://github.com/Azure/data-api-builder

**SQL Server 2025**

- **Seguridad por fila** — https://learn.microsoft.com/en-us/sql/relational-databases/security/row-level-security?view=sql-server-ver17
- **`SESSION_CONTEXT` y `sp_set_session_context`** — https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-set-session-context-transact-sql?view=sql-server-ver17
- **El tipo `json`** — https://learn.microsoft.com/en-us/sql/t-sql/data-types/json-data-type?view=sql-server-ver17
- **`CREATE JSON INDEX`** — https://learn.microsoft.com/en-us/sql/t-sql/statements/create-json-index-transact-sql?view=sql-server-ver17
- **`JSON_CONTAINS`** — https://learn.microsoft.com/en-us/sql/t-sql/functions/json-contains-transact-sql?view=sql-server-ver17

**Postgres, para el contraste:** PostgREST, la sección *Authentication* — https://docs.postgrest.org/en/stable/ · `jsonb` —
https://www.postgresql.org/docs/18/datatype-json.html

**Orden de lectura sugerido:** la página de autorización de DAB antes de la sección 5.1; la de RLS de SQL Server antes de la 5.2, con su
sección de *side-channel attacks*; la del tipo `json` antes de la 5.3.

> ⚠️ Las URL y sus contenidos cambian. Se consultaron el 18/10/2026; DAB cambia rápido, y la configuración de esta fase es de la 2.1.5.

---

## 🏁 16. Resultado de la fase

```text
DATA API BUILDER Y EL TIPO JSON · ss05 (el modelo de la Fase 23 y los antibiogramas de la 19) · 18/10/2026
EL CONTRATO  DAB 2.1.5 · dos vistas · roles paciente y médico · login dab_api, solo el esquema api
             sin identidad 403 · paciente 39: 1.284 resultados en 152 protocolos · lo ajeno, [] · médico 144: 1.114
LA BASE      CREATE SECURITY POLICY con SESSION_CONTEXT · todos pasan por RLS, hasta sa · DAB: sp_set_session_context @read_only = 0
LA ROTURA    AppService confía en un encabezado: la identidad del paciente 12594, fabricada, da 115 resultados ajenos
EL DOCUMENTO json validado (Msg 13609) · 600 y 13.303, como en la Fase 19 · .modify · JSON_OBJECTAGG
             índice JSON (tabla interna, un Seek) · columna calculada (un Seek) · cuánto lee cada uno: 🪞🔒
```

> **La señal de que quedó bien:** *"Sé qué le prueba a la API que un usuario es quien dice ser, quién puede fabricar esa prueba, y tengo
> una prueba automática que lo intenta."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a ss-fase-05-data-api-builder-y-json -m "ss05 cerrada: el contrato de la Fase 23 con DAB y la RLS de SQL Server, la identidad fabricada con AppService, el antibiograma con el tipo json y sus dos índices"
> ```
>
> Commits de la fase con prefijo `ss05:`, los de ejercicio `ss05 ej15: …`.
