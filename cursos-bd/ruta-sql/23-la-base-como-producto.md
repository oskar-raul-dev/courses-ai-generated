# 🔌 Fase 23 — La base como producto: PostgREST, la seguridad por fila, y la corrección de verdad del portal de 2018

> **Curso:** Ruta SQL · Fase 23 de 27 · Bloque V — La base en la red · **15 h** · cierra el bloque: lleva el 💀 boss V y el 💀☕ boss del puente
> **Motores:** PostgreSQL `pgvector/pgvector@sha256:2358fcba361e…` (18.6) · PostgREST `postgrest/postgrest@sha256:d155c6718ed9…` (v16.4) · Apache Artemis `apache/artemis@sha256:0f32b054e1f4…` (2.57.0), solo para el boss del puente · Java 25 (Temurin) · ORDS de Oracle, solo con la documentación (🔒, D20)
> **Entorno de ejecución:** SQL, Python y HTTP en `src/23-la-base-como-producto/`; Java 25 en `src/23-la-base-como-producto/puente/`
> **Perfil de volumen:** M, con `alameda.result` completo (12,1 M de resultados) y los 1.327.622 protocolos
> **El dolor de Alameda:** el incidente del portal de 2018: los catorce mil informes descargados en una noche, y la corrección que no corrigió nada
> **Depende de:** Fases 10 y 22 · **Habilita:** el Bloque VI, desde la [Fase 24](24-el-diseno.md), que pone a prueba todo lo anterior
> **Apéndices de apoyo:** a02, a04, a06, a07, a08
> **Fecha de verificación ejecutada:** 14/10/2026
> **Objetivo:** exponer la base como API con PostgREST, corregir el IDOR de 2018 con seguridad por fila, medir lo que cuesta, y decidir cuándo no exponer la base. Cerrar el bloque con los dos boss.

---

## 🧭 1. Dónde estamos

La [Fase 10](10-identificadores.md) dejó una deuda dicha y no pagada: el MD5 del número de protocolo no arreglaba el portal de 2018, porque el problema no era el identificador sino **la autorización**. Alguien con un número válido podía pedir otro número y el portal lo entregaba. Eso es un IDOR (*insecure direct object reference*), y esta fase lo corrige donde corresponde: en la base, con **seguridad por fila**.

La [Fase 22](22-la-exportacion-de-las-9-40.md) dejó otra cosa: una cola dentro de la base, medida, contra la que el boss del puente compara un *broker*. Las dos deudas se pagan aquí.

Y esta fase deja una para el Bloque VI: la seguridad por fila se enciende sobre `alameda.lab_order` y `alameda.result`, y desde aquí todo lo que lea esas tablas con un rol que no sea el superusuario pasa por ella. La facturación del 🏆 "Un martes", en la [Fase 26](26-el-comite.md), lo descubre cuando su rol no ve ningún protocolo.

---

## 🎯 2. Objetivos de esta fase

1. Exponer la base como API con PostgREST, sobre un esquema `api` de vistas que es el contrato.
2. Escribir políticas de seguridad por fila (RLS) para el paciente y para el médico derivante, a partir de los *claims* del JWT.
3. Medir lo que cuesta RLS, con y sin índice, y saber dónde tiene que estar ese índice.
4. Ver el error de una escritura que viola la política, y el de un rol sin permisos.
5. Revertir el MD5 del portal de 2018, y ver por qué la seguridad por fila lo vuelve irrelevante.
6. Decidir cuándo no exponer la base como API, y cuándo la lógica en la base es una cárcel.
7. Resolver los dos boss del bloque: "Las 9:40" en SQL y Python, y "El puente" en Java 25 con Artemis.

---

## 🚫 3. Qué NO entra todavía

- **Una aplicación web.** La API se mide con pedidos HTTP desde Python; no hay pantalla.
- **Un proveedor de identidad.** Los JWT se firman con un secreto de laboratorio, publicado a propósito en el compose: no es la forma de producción, y la fase lo dice.
- **ORDS de Oracle y Data API builder.** El primero, con la documentación (🔒, D20); el segundo, en el track (`ss05`).
- **La operación de PostgREST en producción** (réplicas, caché, límites de velocidad). Se nombran en el veredicto.

---

## 🏚️ 4. El dolor, en la caja

El portal de 2018 publicaba los informes en una URL con el número de protocolo. Un paciente cambió el número de su URL, encontró el de otro, y descargó **catorce mil informes en una noche** recorriendo los números. La agencia que mantenía el portal lo "corrigió" reemplazando el número por su MD5.

La caja guarda ese portal: `staging.portal_2018` tiene, para cada uno de los 1.327.622 protocolos, su número visible y el `url_hash` que publicaba. En todos, el hash es exactamente `md5(visible_number)`.

La autopsia (§8) muestra cuánto tarda revertir esos hashes. Esta sección muestra lo que faltaba: que el portal, aun con un hash imposible de adivinar, entregaba cualquier informe a quien tuviera su dirección.

---

## 🧩 5. La API: PostgREST sobre un esquema de vistas

PostgREST lee el catálogo de Postgres y publica como recursos HTTP las tablas y vistas de un esquema. En el laboratorio, ese esquema es `api`, y tiene **vistas**, no tablas: la vista es el contrato, y la tabla puede cambiar detrás de ella. Una versión nueva del contrato es un esquema nuevo (`api_v2`), no un cambio que rompe a quien ya lo usa.

PostgREST entra a la base como un único rol, `authenticator`, que puede cambiar a otros tres: `web_anon` (sin token), `paciente` y `medico`. El rol lo decide el JWT que llega en cada pedido; los *claims* del JWT quedan en `request.jwt.claims` durante la transacción del pedido, y las políticas los leen.

```sql
CREATE VIEW api.resultados WITH (security_invoker = true) AS
SELECT o.lab_order_id, o.ordered_on, r.result_id, r.analyte_code, a.name AS analyte, a.unit,
       r.value_numeric, r.qualifier, r.value_text, r.recorded_at
FROM alameda.result r
JOIN alameda.lab_order o ON o.lab_order_id = r.lab_order_id
LEFT JOIN alameda.analyte a ON a.analyte_code = r.analyte_code;
```

⚠️ **`security_invoker = true` es la línea más importante del archivo.** Sin ella, la vista se lee con los permisos de su dueño, y el dueño (el superusuario que la creó) no pasa por la seguridad por fila. La vista entera queda a la vista de cualquiera. Ejercicio 9: sin la opción, un paciente ve filas de **165 pacientes distintos** en las primeras mil. Es el boss V, C4: el portal de 2018, otra vez, dentro de la API.

### 5.1 Un pedido, una transacción

Lo que PostgREST hace con cada pedido HTTP se puede contar en cinco pasos, y saberlos es lo que permite razonar sobre el costo y sobre la seguridad:

1. **Valida el JWT**: la firma, con el secreto o la clave pública que tiene configurada, y la fecha de vencimiento (`exp`) si el token la trae. Un token mal firmado no llega a la base: es el 401 de la tabla de la sección 6.
2. **Abre una transacción** con la conexión de `authenticator` que toma de su *pool*.
3. **Cambia de rol** con `SET LOCAL ROLE`, al que dice el *claim* `role` del token, o a `web_anon` si no hay token, y **fija los claims** con `set_config('request.jwt.claims', …, true)`, que vale solo hasta el final de esa transacción.
4. **Traduce la URL a una consulta** sobre la vista: `GET /resultados?analyte_code=eq.GLU&order=recorded_at.desc&limit=20` es un `SELECT … FROM api.resultados WHERE analyte_code = 'GLU' ORDER BY recorded_at DESC LIMIT 20`, con los valores como parámetros, nunca pegados al texto.
5. **Confirma** (o deshace, si el pedido falló) y devuelve la conexión al *pool*, sin rol ni claims.

De ahí salen tres consecuencias. La primera: **cada pedido es una transacción corta**, y nada de lo que la Fase 17 dijo de las lecturas largas le pasa a la API, salvo que alguien pida una página de un millón de filas. La segunda: el rol y los claims **no sobreviven al pedido**, porque son `LOCAL`; la conexión vuelve limpia al *pool*, y por eso el hallazgo de la sección 7 (los claims vacíos en una conexión reutilizada) no le pasa a PostgREST y sí le pasa a una aplicación que maneja su propio *pool* y se olvida de limpiar. La tercera: **la base ve el rol y los claims, no el token**. Si mañana el token lo emite otro proveedor, las políticas no cambian mientras los claims sean los mismos.

### 5.2 El token: qué trae y quién lo firma

Un JWT son tres partes en base64 separadas por puntos: una cabecera con el algoritmo, el cuerpo con los *claims* y la firma. Los de esta fase llevan `role` (`paciente` o `medico`), el identificador correspondiente (`patient_id` o `physician_id`) y nada más. Se firman con **HS256 y un secreto compartido**, el que está publicado en el `compose.yaml`: quien conoce el secreto puede fabricar cualquier token, con cualquier rol y cualquier paciente. En el laboratorio, eso es lo que permite que `04_api.py` firme sus propios pedidos.

En producción el secreto no lo tiene nadie más que quien emite los tokens. Lo habitual es que los emita un **proveedor de identidad** con una clave privada, firmando con RS256 o ES256, y que PostgREST tenga solo la clave pública (o la dirección donde la publica, un JWKS): puede verificar la firma y no puede fabricarla. Es la diferencia que el track mide del otro lado, en [ss05](ss05-data-api-builder-y-json.md): ahí la identidad la escribe quien está delante, sin firma, y quien escribe el encabezado se vuelve el paciente que quiera (M-74 en la [bitácora](bitacora-de-medicion.md)).

> 📝 **El médico derivante no estaba en el modelo.** `alameda.lab_order` no tenía médico, y la caja sí (`legacy.Protocolos.IdMedico`, 1.250 médicos). La fase lo trae a `alameda.referral`, una tabla nueva del modelo. 92.776 protocolos no tienen médico, y ningún médico los ve.

---

## 🔐 6. La seguridad por fila

Cada política es un filtro que el motor agrega a toda consulta del rol, lo pida o no quien escribe la consulta:

```sql
CREATE POLICY paciente_ve_lo_suyo ON alameda.lab_order FOR SELECT TO paciente
  USING (patient_id = api.claim('patient_id')::integer);

CREATE POLICY medico_ve_lo_que_derivo ON alameda.lab_order FOR SELECT TO medico
  USING (lab_order_id IN (SELECT lab_order_id FROM alameda.referral
                          WHERE physician_id = api.claim('physician_id')::integer));
```

Los pedidos, medidos desde afuera con un JWT firmado:

| Pedido | Respuesta |
|---|---|
| Sin token | HTTP 401, `permission denied for view resultados` |
| Paciente 39, sus resultados | HTTP 200, **426 resultados** en 52 protocolos |
| Paciente 39 pide un protocolo del paciente 12594 | HTTP 200, **lista vacía**: no un error, una ausencia |
| Médico 144, lo que derivó | HTTP 200, **1.114 protocolos** |
| Token con la firma alterada | HTTP 401, `No suitable key or wrong key type` |
| Portal del paciente, mediana de 20 pedidos | **5 a 7 ms** según la corrida |

Fuente: medidas de la sesión de verificación del 14/10/2026.

El 401 del pedido sin token merece una línea. La base no dice "no autenticado": dice `permission denied for view resultados`, porque `web_anon` no tiene permiso sobre la vista. Es PostgREST el que traduce ese error a **401 cuando el pedido es anónimo** (le falta identificarse) y a **403 cuando trae un token válido** (está identificado, y no le alcanza). La distinción la hace la API, y la base solo dice que ese rol no puede.

🧭 El paciente que pide un protocolo ajeno no recibe "acceso denegado", recibe nada. Eso es deliberado: un "denegado" confirma que el protocolo existe, y un atacante recorre las respuestas para saber qué números son válidos.

### 6.1 Lo que cuesta, y dónde tiene que estar el índice

**Apuesta antes de medir:** *"con índice sobre la columna de la política, RLS agrega un filtro que apenas cambia las lecturas; sin ese índice, cada consulta del portal recorre la tabla entera."*

| Consulta | Política | Índice | Bloques | Tiempo |
|---|---|---|---:|---:|
| Paciente 39, sin RLS (filtro escrito a mano, como superusuario) | — | `lab_order(patient_id)` | 600 | 2,8 ms |
| Paciente 39, con RLS | columna de la tabla protegida | `lab_order(patient_id)` | **692** | 0,5 ms |
| Médico 144 | subconsulta sobre `referral` | ninguno | 14.573 | 864 ms |
| Médico 144 | subconsulta sobre `referral` | `referral(physician_id)` | **9.684** | 91 ms |
| Médico 144 (copia en `staging`) | columna de la tabla protegida | `physician_id` en la tabla | **5** | 0,1 a 0,25 ms |

**Resultado: ganada, con una condición que la apuesta no decía.** Para el paciente, RLS agrega 92 bloques a una consulta de 600: la política es una comparación de columna de la tabla protegida, y su índice la resuelve. Para el médico, con la política escrita como subconsulta, **la tabla protegida se recorre entera aunque el índice exista**: el índice está en `referral`, no en `lab_order`, y el plan termina en un *Seq Scan* de 1,3 millones de protocolos con un filtro de *hashed SubPlan*. Con el médico como columna de la tabla protegida, la misma pregunta cuesta 5 bloques.

> 🧭 **El índice de una política tiene que estar en la tabla que la política protege.** Una política que filtra por una subconsulta a otra tabla no puede usar un índice de la tabla protegida para empezar, y la recorre.

### 6.2 Por dentro: la política se escribe dentro de la consulta

Una política no es un filtro que corre después: el motor **agrega su expresión `USING` a la consulta** antes de planificarla, como si quien la escribió hubiera puesto el `WHERE` a mano. Se ve con `EXPLAIN`, haciendo lo mismo que hace PostgREST en cada pedido:

```sql
BEGIN;
SELECT set_config('request.jwt.claims', '{"role":"paciente","patient_id":"39"}', true);
SET LOCAL ROLE paciente;
EXPLAIN (COSTS OFF) SELECT lab_order_id, ordered_on FROM alameda.lab_order;
ROLLBACK;
```

```text
 Index Scan using lab_order_patient_id_idx on lab_order
   Index Cond: (patient_id = (((NULLIF(current_setting('request.jwt.claims'::text, true), ''::text))::json ->> 'patient_id'::text))::integer)
```

La consulta no tiene ningún `WHERE`, y el plan tiene una condición de índice: es la política, con la función `api.claim` desplegada en su cuerpo (es SQL y no PL/pgSQL, así que el planificador puede verla por dentro). Por eso la política del paciente cuesta 92 bloques y no un recorrido: el planificador la trata como cualquier condición, y elige el índice por `patient_id`. La del médico, con su `IN (SELECT …)` sobre otra tabla, se planifica también como cualquier condición, y lo que el planificador hace con ella es lo de la sección 6.1.

Tres reglas del mecanismo que deciden cómo se escriben las políticas:

- **Las políticas de un mismo rol se suman con `OR`.** Son *permissive* por defecto: una fila se ve si alguna la deja ver. Una política `AS RESTRICTIVE` se suma con `AND`, y sirve para una regla que tiene que valer siempre, como "nada de otra sede".
- **`USING` mira las filas que existen; `WITH CHECK` mira las que se escriben.** Una política `FOR ALL` que solo tiene `USING` usa esa misma expresión como `WITH CHECK`. La del médico para cargar resultados es `FOR INSERT … WITH CHECK`, y es la que da el mensaje de la sección 7 cuando escribe en un protocolo ajeno.
- **La política se combina con el resto de la consulta sin dejar escapar filas.** El motor no aplica antes un filtro del usuario que pueda mostrar, en un mensaje de error, el valor de una fila que la política esconde, salvo que la función del filtro esté marcada como `LEAKPROOF`. Es un detalle de la documentación que tiene una consecuencia práctica: una función propia en un filtro sobre una tabla con RLS puede impedir que se use un índice, y el `EXPLAIN` lo muestra.

### 6.3 Quién no pasa por la política

La seguridad por fila se enciende por tabla (`ALTER TABLE … ENABLE ROW LEVEL SECURITY`), y **no vale para todos**. En el laboratorio:

```text
  relname  | relrowsecurity | relforcerowsecurity
 lab_order | t              | f
 result    | t              | f

    rolname    | rolbypassrls
 postgres      | t
 authenticator | f
 paciente      | f
 medico        | f
```

El superusuario, y cualquier rol con `BYPASSRLS`, la saltea: como `postgres`, la misma consulta de arriba ve los 1.327.622 protocolos. Lo mismo pasa con el **dueño de la tabla**, salvo que la tabla tenga `FORCE ROW LEVEL SECURITY`, que aquí está apagado (`relforcerowsecurity` falso). Por eso las otras fases del curso, que corren como `postgres`, no notaron que la Fase 23 encendió la seguridad por fila, y por eso la vista sin `security_invoker` de la sección 5 es un agujero: se lee como su dueño. La regla para Alameda es simple de decir: **ningún rol de aplicación es dueño de las tablas ni tiene `BYPASSRLS`**, y el único que los tiene es el de las migraciones, que no atiende pedidos.

> 🩻 **Esto sí funciona igual** en SQL Server, con otro nombre: una *security policy* con un predicado de filtro y uno de bloqueo es la política con `USING` y `WITH CHECK`, y el track lo mide con Data API builder delante ([ss05](ss05-data-api-builder-y-json.md)). Con una diferencia que conviene recordar: en SQL Server la política alcanza también a `sa`. **MySQL no tiene seguridad por fila**: lo más parecido es una vista con `SQL SECURITY INVOKER` que filtre por el usuario conectado, que no protege la tabla de quien la consulta directamente.

### 6.4 Lo que la política no protege

La seguridad por fila decide **qué filas** ve un rol. Hay cuatro cosas que no decide, y las cuatro aparecieron alguna vez en un portal:

- **Las columnas.** Si el paciente puede ver su protocolo, ve todas las columnas de la vista. Lo que no debe ver (el médico que lo derivó, una observación interna del laboratorio) se saca de la vista o se le niega con un `GRANT SELECT (columnas…)` por columna. La política no lo hace.
- **La existencia, por un costado.** La documentación de Postgres lo advierte: una restricción única o una clave foránea se comprueban contra todas las filas, también las que la política esconde. Un rol que puede insertar y recibe `duplicate key value violates unique constraint` aprende que esa clave existe aunque no pueda leerla. Por eso, en el portal, ni el paciente ni el médico insertan en tablas con claves que signifiquen algo; el médico carga resultados en una tabla cuya clave es un identificador generado.
- **Lo que corre como otro.** Una función `SECURITY DEFINER` corre con los permisos de su dueño, y si el dueño saltea la política, la función también. Una función así en el esquema `api`, escrita para "ayudar" a la aplicación, es una puerta lateral.
- **El volumen.** Un paciente que pide sus resultados mil veces por minuto no viola ninguna política, y aun así es un problema. Los límites de velocidad están delante de la API, no en la base.

### 6.5 Oracle: VPD y ORDS

Oracle tiene la misma idea desde hace dos décadas con el nombre de **Virtual Private Database**: con `DBMS_RLS.ADD_POLICY` se registra una función que devuelve, como texto, el predicado que el motor agrega a cada consulta sobre la tabla, y el contexto de la sesión (`SYS_CONTEXT`) hace el papel de los claims. La API la pone **ORDS**, que publica tablas, vistas y procedimientos como REST, con OAuth2 delante.

> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: con una política VPD que devuelve `patient_id = SYS_CONTEXT('portal', 'patient_id')` y un índice por `patient_id`, la lectura del paciente cuesta del orden de la consulta escrita a mano, como en Postgres; con un predicado que es una subconsulta sobre la tabla de derivaciones, la del médico recorre la tabla protegida, como en la sección 6.1. Resuélvela con la política sobre los protocolos cargados en Oracle y `uv run lab measure --engine oracle --private`, comparando el plan con el predicado a mano. El resultado se queda en tu terminal ([`a09`](a09-licencias-publicacion-y-riesgo.md)).

---

## 💥 7. El punto de rotura

**La política sin índice** es la rotura de la ficha, y ya está en la tabla: 864 ms y 14.573 bloques para cada pedido del médico. Con quinientos médicos mirando el portal a las 9 de la mañana, el portal no se cae por un ataque: se cae por la política.

**La escritura que viola la política** tiene su mensaje. El médico 144 intenta cargar un resultado en un protocolo que no derivó:

```text
ERROR:  new row violates row-level security policy for table "result"
```

La política `FOR INSERT … WITH CHECK` vale para lo que se escribe, no solo para lo que se lee. En un protocolo que sí derivó, la misma sentencia entra (ejercicio 11).

**Un hallazgo que la fase no buscaba.** Después de un `set_config` en la misma sesión, `current_setting('request.jwt.claims', true)` devuelve una cadena vacía, no `NULL`, y la conversión a JSON falla con `invalid input syntax for type json` en lugar de devolver cero filas. Con PostgREST no pasa, porque fija los claims en cada pedido. Pero una conexión del pool que se reutiliza sin claims rompe en vez de no mostrar nada. La función `api.claim` lo cubre con `nullif(…, '')` (ejercicio 16).

---

## ⚰️ 8. Autopsia: el MD5 del número de protocolo, otra vez

El atacante conoce la forma del número porque la ve en su propio informe: una letra de sede, un guion y siete dígitos. Prueba cada número de cada sede hasta su máximo, calcula el MD5 y lo cruza con las URL del portal:

| Paso | Volumen | Tiempo |
|---|---:|---:|
| Calcular el MD5 de todos los números posibles | 1.302.033 candidatos | 2,96 s |
| Cruzarlos con las URL del portal | 1.305.942 URL con número de sede | 0,54 s |
| **URL revertidas** | **1.305.942 de 1.305.942** | **unos 3,5 s en total** |

Hay más URL que candidatos porque algunos números visibles se repiten entre protocolos. El MD5 no ocultaba nada: un espacio de un millón de números se recorre en segundos en una laptop.

Lo que el portal de 2018 tampoco tenía es **quién mira**: catorce mil pedidos de un mismo origen, en una noche, con números consecutivos, es un patrón que cualquier registro de accesos muestra al día siguiente. La seguridad por fila evita que esos pedidos devuelvan algo; un registro con alerta sobre las listas vacías repetidas (el atacante que prueba números ajenos recibe `[]` una y otra vez) dice que alguien lo está intentando. Son dos defensas distintas, y la segunda es la que hubiera adelantado el aviso de la agencia en semanas.

La corrección de verdad está en la tabla del §6: con RLS, conocer el número de protocolo de otro paciente no sirve de nada, porque la base no lo entrega. El identificador puede ser secuencial, MD5 o UUID; la autorización no depende de que nadie lo adivine.

---

## 🏛️ 9. Cuándo la lógica en la base es una cárcel

El sistema de historia clínica de Horizonte tiene **miles de paquetes PL/SQL**, y por una buena razón (historia §3, 2022): en 2010 era la única forma de garantizar que toda escritura pasara por las mismas reglas, sin importar qué aplicación la hiciera. Esa misma decisión es, doce años después, lo que impide migrarlo: la lógica no está en un servicio que se pueda reemplazar, está repartida en un motor que solo se puede reemplazar entero.

RLS y PostgREST son la versión liviana de esa decisión. Las reglas de **quién ve qué** son buenas candidatas para vivir en la base: son pocas, son críticas, y se aplican igual desde la API, desde un reporte o desde un `psql`. Las reglas de **negocio** (cuándo se factura, qué convenio aplica, qué se notifica) no lo son: cambian con cada contrato, y en la base son difíciles de probar, de versionar y de mover. La frontera es esa.

### 9.1 Cómo se prueba una política

Una política es código, y se prueba como código: **por rol, con el número esperado**. La prueba no le pregunta a la política si está bien escrita; le pregunta a la base qué ve cada uno. Para cada rol se fijan los claims de un caso conocido, se cuenta lo que devuelve la vista, y se compara con lo que dice otra fuente, que en este curso es `truth`: el paciente 39 tiene que ver los protocolos que la verdad le asigna, ni uno más; un protocolo de otro paciente tiene que dar una lista vacía; sin claims, nada; y el médico, lo que derivó según `referral`. Es lo que hace el criterio C4 del boss V, y es lo que hay que correr cada vez que una migración toca una tabla con RLS, porque una columna renombrada o una vista recreada sin `security_invoker` no dan error: dan de más.

Dos cosas más entran en esa prueba. Una, **el plan**: un `EXPLAIN` con el rol de cada perfil, para ver que la política usa el índice que debe (la sección 6.1 muestra lo que pasa si no). Otra, **el rol de servicio**: que ninguno de los roles que atienden pedidos tenga `BYPASSRLS` ni sea dueño de una tabla protegida, con una consulta a `pg_roles` y a `pg_class` como la de la sección 6.3. Las tres juntas son unas pocas líneas de SQL, y son las que separan una política que se cree segura de una que se sabe segura.

---

## 📖 10. Traducción

| Lo que sabes (aplicación) | En Postgres con PostgREST | Lo que cambia |
|---|---|---|
| Un `if user.id == order.patient_id` en el controlador | Una política RLS | La regla vale para toda consulta, no solo para la del controlador |
| Un endpoint `/api/v1/results` | Una vista en el esquema `api` | La vista es el contrato; la tabla cambia detrás |
| Un middleware que valida el token | PostgREST valida la firma y cambia de rol | La base ve el rol y los claims, no el token |
| "403 Forbidden" | Una lista vacía | No se confirma que el objeto existe |
| Un ID imposible de adivinar | Una política | La seguridad no depende del ID |

📖 **De RLS a la aplicación:** cuando la regla de acceso depende de datos que no están en la base (un sistema de permisos externo, un horario), la política no puede verla, y la regla vuelve a la aplicación.

---

## ⚖️ 11. Veredicto honesto: cuándo no exponer la base como API

**Expón la base** cuando el modelo de lectura es estable, las reglas de acceso caben en políticas, y quien consume la API puede vivir con el contrato de vistas. El portal de resultados de Alameda cumple: un paciente ve lo suyo, un médico lo que derivó, y la API responde en 5 a 7 ms.

**Para Alameda**, eso se traduce en un portal de resultados que sale por PostgREST, con un esquema `api` de vistas, la política del paciente por columna y la del médico con `physician_id` en la tabla de protocolos, que es la que cuesta 5 bloques; tokens emitidos por un proveedor de identidad y no por el secreto del laboratorio; y la prueba por rol de la sección 9.1 corriendo con cada migración. Lo que no sale por PostgREST es la facturación y la integración con el SIH: tienen reglas de negocio y otros sistemas del otro lado, y van por la aplicación y por la cola de la [Fase 22](22-la-exportacion-de-las-9-40.md).

**Lo que cuesta operarla.** PostgREST no guarda estado: se pueden correr varias copias detrás de un balanceador, todas contra la misma base, y el límite real es la cantidad de conexiones que la base acepta. Lee el catálogo al arrancar y lo guarda en memoria, así que una vista nueva o una columna cambiada no aparece en la API hasta que se le pide que lo recargue (con una señal, o con un `NOTIFY pgrst, 'reload schema'` desde la migración). Una migración que cambia el esquema `api` sin recargar deja a la API sirviendo el contrato viejo. Es poco, y hay que escribirlo en el procedimiento de despliegue.

**No la expongas** cuando la API tiene que orquestar varios sistemas (el SIH, la facturación, la obra social), cuando las reglas son de negocio y cambian con cada contrato, o cuando el equipo no puede operar la base como un servicio público (límites de velocidad, réplicas, monitoreo de políticas). Y no la expongas sin haber medido la política: una política mal indexada convierte cada pedido en un recorrido de la tabla.

---

## ⚠️ 12. Errores comunes y diagnóstico

- **Una vista sin `security_invoker`**: se lee con los permisos del dueño, y el dueño no pasa por RLS. Es el IDOR, dentro de la API.
- **Una política que filtra por subconsulta a otra tabla**: no puede empezar por un índice de la tabla protegida, y la recorre.
- **`current_setting` sin `nullif`**: una conexión reutilizada sin claims falla en lugar de no mostrar nada.
- **Responder "denegado" a un recurso ajeno**: confirma que existe.
- **Firmar los JWT con el secreto del laboratorio en producción.**
- **Confiar en el identificador opaco como autorización.**
- **Conectar la aplicación como dueño de las tablas.** El dueño no pasa por RLS salvo con `FORCE ROW LEVEL SECURITY`; el superusuario, nunca (§6.3).
- **Probar la política leyendo su texto.** Se prueba contando lo que ve cada rol contra una fuente independiente (§9.1).
- **Firmar con un secreto compartido que conoce más de un sistema.** Quien tiene el secreto puede fabricar cualquier identidad (§5.2).

---

## 📋 13. Checklist de validación

- [ ] `uv run lab up base api` deja PostgREST *healthy*, y `GET /` responde 200.
- [ ] Los roles `authenticator`, `web_anon`, `paciente` y `medico` existen, y `authenticator` es miembro de los otros tres.
- [ ] Las vistas de `api` tienen `security_invoker = true`.
- [ ] El paciente 39 ve 426 resultados; un protocolo ajeno devuelve una lista vacía.
- [ ] La política del médico se mide con y sin índice, y con la columna en la tabla protegida.
- [ ] La escritura que viola la política da el mensaje de §7.
- [ ] El `EXPLAIN` como `paciente`, con sus claims, muestra la política como condición de índice (§6.2).
- [ ] Ningún rol que atiende pedidos tiene `BYPASSRLS` ni es dueño de `alameda.lab_order` o `alameda.result` (§6.3).
- [ ] Lo que el paciente no debe ver por columna está fuera de la vista o sin `GRANT` (§6.4).
- [ ] El boss V pasa 5 de 5 con la solución; el punto de partida, 0 de 5.
- [ ] El boss del puente pasa 5 de 5 con la solución; el punto de partida, 1 de 5.

---

## 🧪 14. Ejercicios (26)

Cada ejercicio tiene su solución en `soluciones/23-la-base-como-producto.md`. Los 1 a 16 se corren con `05_ejercicios.sql`; los 17 a 26 se resuelven con su rúbrica.

### 🟢 Ejercicio 1 — Los roles

¿De qué roles es miembro `authenticator`?

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-1](soluciones/23-la-base-como-producto.md#ejercicio-1)

### 🟢 Ejercicio 2 — El anónimo

¿Qué ve `web_anon` en `api.resultados`?

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-2](soluciones/23-la-base-como-producto.md#ejercicio-2)

### 🟢 Ejercicio 3 — El claim

Fija los claims del paciente 39 y léelos con `api.claim`, incluido uno que no existe.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-3](soluciones/23-la-base-como-producto.md#ejercicio-3)

### 🟢 Ejercicio 4 — Lo propio

¿Cuántos resultados ve el paciente 39?

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-4](soluciones/23-la-base-como-producto.md#ejercicio-4)

### 🟢 Ejercicio 5 — Lo ajeno

¿Qué ve el paciente 39 al pedir el protocolo `-2147402959`?

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-5](soluciones/23-la-base-como-producto.md#ejercicio-5)

### 🟢 Ejercicio 6 — El médico

¿Cuántos protocolos ve el médico 144?

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-6](soluciones/23-la-base-como-producto.md#ejercicio-6)

### 🟢 Ejercicio 7 — Las políticas en el catálogo

Lista las políticas de `alameda` con su comando y sus roles.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-7](soluciones/23-la-base-como-producto.md#ejercicio-7)

### 🟢 Ejercicio 8 — El plan del paciente

¿Qué índice usa la política del paciente?

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-8](soluciones/23-la-base-como-producto.md#ejercicio-8)

### 🟡 Ejercicio 9 — La vista sin `security_invoker`

Crea una vista sin la opción y cuenta cuántos pacientes distintos ve el paciente 39 en sus primeras mil filas.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-9](soluciones/23-la-base-como-producto.md#ejercicio-9)

### 🟡 Ejercicio 10 — La escritura ajena

El médico 144 carga un resultado en un protocolo que no derivó. ¿Qué pasa?

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-10](soluciones/23-la-base-como-producto.md#ejercicio-10)

### 🟡 Ejercicio 11 — La escritura propia

Y en un protocolo que sí derivó.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-11](soluciones/23-la-base-como-producto.md#ejercicio-11)

### 🟡 Ejercicio 12 — El MD5

Comprueba que el `url_hash` de `C-0048213` es el MD5 de su número.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-12](soluciones/23-la-base-como-producto.md#ejercicio-12)

### 🟡 Ejercicio 13 — La subconsulta con índice

Muestra el plan de la política del médico con el índice de `referral`. ¿Qué tabla recorre?

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-13](soluciones/23-la-base-como-producto.md#ejercicio-13)

### 🟡 Ejercicio 14 — La columna con índice

Muestra el plan de la política del médico sobre la copia con la columna `physician_id`.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-14](soluciones/23-la-base-como-producto.md#ejercicio-14)

### 🟡 Ejercicio 15 — Quién no pasa por RLS

¿Qué roles tienen `rolsuper` o `rolbypassrls`?

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-15](soluciones/23-la-base-como-producto.md#ejercicio-15)

### 🟡 Ejercicio 16 — Sin claim

¿Qué ve un paciente cuya transacción no fijó claims?

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-16](soluciones/23-la-base-como-producto.md#ejercicio-16)

### 🟠 Ejercicio 17 — Las vistas versionadas

Diseña `api_v2` con un cambio de forma en `resultados`, sin romper a quien usa `api`. Di cómo retiras `api` después.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-17](soluciones/23-la-base-como-producto.md#ejercicio-17)

**Rúbrica (sobre 3 puntos):** 1 punto por el esquema nuevo con sus vistas; 1 por la convivencia de los dos; 1 por el plan de retiro con una métrica de uso.

### 🟠 Ejercicio 18 — La política por sede

Un técnico de sede ve los protocolos de su sede. Escribe la política y mide su costo con el índice que corresponda.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-18](soluciones/23-la-base-como-producto.md#ejercicio-18)

**Rúbrica (sobre 4 puntos):** 1 punto por el claim y el rol; 1 por la política sobre una columna de la tabla protegida; 1 por la medida con y sin índice; 1 por decir cuántos protocolos ve cada sede.

### 🟠 Ejercicio 19 — La rotación del secreto

El secreto de los JWT se filtra. Diseña la rotación sin cortar el servicio.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-19](soluciones/23-la-base-como-producto.md#ejercicio-19)

**Rúbrica (sobre 3 puntos):** 1 punto por aceptar dos claves durante la transición (JWKS); 1 por la expiración corta de los tokens; 1 por la invalidación de los tokens viejos.

### 🟠 Ejercicio 20 — El límite de filas

Un médico pide todos sus protocolos sin paginar. Diseña el límite en PostgREST y mide la respuesta con y sin él.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-20](soluciones/23-la-base-como-producto.md#ejercicio-20)

**Rúbrica (sobre 3 puntos):** 1 punto por el límite de filas del servidor; 1 por la paginación con `Range` o `limit`/`offset`; 1 por la medida.

### 🟠 Ejercicio 21 — La función con permisos del dueño

Una política llama a una función `SECURITY DEFINER`. Di qué riesgo trae y cómo se mitiga.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-21](soluciones/23-la-base-como-producto.md#ejercicio-21)

**Rúbrica (sobre 3 puntos):** 1 punto por explicar que corre con los permisos del dueño; 1 por el `search_path` fijado en la función; 1 por limitar lo que la función puede leer.

### 🟠 Ejercicio 22 — Quién leyó qué

Diseña la auditoría de lecturas del portal, para saber quién vio un informe.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-22](soluciones/23-la-base-como-producto.md#ejercicio-22)

**Rúbrica (sobre 3 puntos):** 1 punto por dónde se registra (registro de PostgREST, o una función de auditoría); 1 por el costo de registrar cada lectura; 1 por la retención y quién la consulta.

### 🔴 Ejercicio 23 — ORDS, con la documentación

Lee la documentación de ORDS de Oracle y escribe, sin cifras, qué ofrece frente a PostgREST.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-23](soluciones/23-la-base-como-producto.md#ejercicio-23)

**Rúbrica (sobre 3 puntos):** 1 punto por describir ORDS; 1 por la comparación en prosa sin números de Oracle (D20); 1 por decir cuándo lo elegirías.

### 🔴 Ejercicio 24 — La cárcel

Elige tres reglas de Alameda y decide, con argumentos, cuáles van en la base y cuáles en un servicio.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-24](soluciones/23-la-base-como-producto.md#ejercicio-24)

**Rúbrica (sobre 4 puntos):** 1 punto por cada regla bien ubicada con su argumento; 1 por la frontera explícita (quién ve qué, contra reglas de negocio).

### 🔴 Ejercicio 25 — La política que sí usa un índice, en el modelo

Diseña cómo llevar `physician_id` a `lab_order` en el modelo, sin parar el portal (anticipa la Fase 25).

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-25](soluciones/23-la-base-como-producto.md#ejercicio-25)

**Rúbrica (sobre 4 puntos):** 1 punto por la columna nueva sin reescritura; 1 por el relleno en lotes; 1 por el índice concurrente; 1 por el cambio de política en una transacción corta.

### 🔴 Ejercicio 26 — El veredicto

Decide si la base de Alameda se expone como API para el portal, para el SIH y para la obra social. Justifica cada uno.

*Solución:* [soluciones/23-la-base-como-producto.md#ejercicio-26](soluciones/23-la-base-como-producto.md#ejercicio-26)

**Rúbrica (sobre 3 puntos):** 1 punto por cada destino decidido con su argumento y su medida.

---

## 📚 15. Referencias

**Documentación oficial**

- **PostgREST** — https://docs.postgrest.org/en/stable/ — autenticación con JWT, roles y esquemas.
- **Seguridad por fila de Postgres 18** — https://www.postgresql.org/docs/18/ddl-rowsecurity.html
- **`CREATE VIEW` y `security_invoker`** — https://www.postgresql.org/docs/18/sql-createview.html
- **Apache Artemis** — https://artemis.apache.org/ — el *broker*, desde su separación de ActiveMQ.
- **Jakarta Messaging** — https://jakarta.ee/specifications/messaging/ — la API que usa el boss del puente.

**Papers y libros**

- **Martin Kleppmann, *Designing Data-Intensive Applications*, 2.ª ed., O'Reilly, 2026** — los capítulos de flujos entre sistemas y de entrega de mensajes.

> ⚠️ **Verificación pendiente:** las URL de esta sección no se comprobaron con su código de estado en esta sesión. Quedan como deuda de verificación de la fase (plan §4).

---

## 💀 16. Boss del Bloque V — Las 9:40

**Pedido de Verónica Colombo:** la exportación nocturna y la notificación de doce horas pasadas a flujo, y el portal que deja de ser un volcado nocturno. Se entrega el flujo nuevo, la API con RLS, y la medición de que ninguna fila se pierde ni se publica dos veces. Cruza las Fases 22 y 23.

El punto de partida está en `src/23-la-base-como-producto/boss/`: `01_setup.sql` (las tablas y la vista del portal) y `flujo.py` (exportar, entregar, registrar un resultado y cerrar el día), con fallas que no se dicen. `arnes.py` evalúa cinco criterios sobre el directorio que se le pase:

1. **C1** · La exportación no pierde la fila de la transacción que confirma tarde.
2. **C2** · Un mensaje repetido por el transporte no se aplica dos veces en el destino.
3. **C3** · La notificación de un detectable sale dentro de las doce horas del registro.
4. **C4** · La API no le muestra a un paciente informes de otro.
5. **C5** · Una corrección vieja que llega tarde no pisa a la nueva.

**El punto de partida pasa 0 de 5.** El arnés lo dice en números: exporta la fila tardía como perdida (`[2] de [1, 2]`), deja dos copias del mismo mensaje, notifica **25,7 h** después del registro (el cierre de las 9:40 del día siguiente), le muestra a un paciente **50 de 50 filas de otros pacientes**, y deja las dos versiones de la corrección. Cada falla es una fase: la 22 (marca de agua, idempotencia, versión, outbox) y esta (`security_invoker`).

**La solución pasa 5 de 5.** No se publica (D42). Una simplificación declarada: el relevador del outbox corre continuamente en un sistema real; en el arnés, envía en el instante en que la fila existe, así que C3 mide el diseño (la notificación se confirma con el resultado) y no la latencia del relevador.

---

## 💀☕ 16b. Boss del puente — El puente

**Pedido de Matías Ledesma:** la interfaz con el SIH. Resultados que salen del laboratorio como mensajes que imitan HL7 v2 (`ORU`, con los segmentos `MSH`, `OBR` y `OBX`; la versión del resultado va en el último campo de `OBX`, una simplificación declarada), a través de Apache Artemis, con duplicados, desorden y mensajes veneno. Es **el único Java del camino base**: un `Puente.java` de un solo archivo, Java 25, sin frameworks que oculten la transacción. La tabla del SIH vive en Postgres para el laboratorio; el SIH real está en Oracle (historia §3).

El punto de partida está en `src/23-la-base-como-producto/puente/`: `01_setup.sql`, `Puente.java` (con los modos `producir`, `consumir`, `medir` y `purgar`) y `pom.xml`, que solo baja las dependencias. El servicio corre en el contenedor de Java 25 de [`a06`](a06-python-java-y-drivers.md), en la red del laboratorio. `arnes.py` evalúa cinco criterios:

1. **P1** · Ningún resultado se pierde, aunque el productor caiga entre confirmar y enviar (2 %).
2. **P2** · Ningún mensaje se aplica dos veces, aunque el consumidor caiga entre aplicar y confirmar (2 %).
3. **P3** · Las correcciones quedan en su última versión, aunque la anterior llegue después.
4. **P4** · Los mensajes veneno terminan en la tabla de descartes del SIH, con su motivo.
5. **P5** · La medida: 6.651 mensajes con cuatro consumidores, todos aplicados una vez.

**El punto de partida pasa 1 de 5.** Pierde **12 resultados** de 1.000 por la doble escritura; aplica **120 mensajes de más** (1.108 filas para 988 resultados); deja **0 de 50 correcciones** con solo la última versión; y el veneno termina en la cola de descartes del propio Artemis (la `DLQ`, de donde la purga siguiente sacó 3 mensajes), sin que el SIH lo sepa. Pasa P5, porque la medida no inyecta caídas.

**La solución pasa 5 de 5**, con outbox en el productor, aplicación con clave y versión en el consumidor, y el veneno apartado al tercer intento. No se publica (D42).

> 🧭 **Un hallazgo del servicio:** con la sesión en `CLIENT_ACKNOWLEDGE` y `recover()` para simular la caída, Artemis respondió `AMQ229027: Could not find reference on consumerId` y los consumidores se cayeron con mensajes pendientes. Con sesiones transaccionales (`commit` y `rollback`), el mismo escenario corre limpio. La transacción de la sesión es la forma de decir "este mensaje no se aplicó", no un detalle de la API.

### ¿Hacía falta un *broker*?

| Medida (6.651 mensajes, cuatro consumidores, sin caídas) | Cola en Postgres (Fase 22) | Artemis |
|---|---:|---:|
| Encolar | una inserción por mensaje | **26,8 a 37,2 s** (envío persistente, uno por uno) |
| Consumir y aplicar | **5,5 s** | **13,1 a 15,9 s** |

**Para el volumen de Alameda, la cola en la base gana**, por un factor de 2,4 a 2,9 en el consumo. El *broker* no se gana su lugar por velocidad en este laboratorio. Una condición del entorno que hay que decir: el journal de Artemis escribe sobre el sistema de archivos de Docker Desktop, que midió **0,1 escrituras por milisegundo** al verificar el laboratorio, y el envío persistente lo paga en cada mensaje. En Linux nativo, con un disco propio, la cifra sería otra, y no se midió.

**Pero el SIH sí lo necesita, y no por velocidad.** El SIH es otro sistema, en otro motor (Oracle), de otra empresa. Con la cola en Postgres, el SIH tendría que conectarse a la base de Alameda y leer sus tablas: el contrato sería el esquema de Alameda. Con el *broker*, el contrato es el mensaje, y cada lado cambia su base sin avisar al otro. **La respuesta medida es: no hacía falta para la exportación interna, y sí para la interfaz con el SIH**, que es justo lo que la ficha permitía contestar.

---

## 🏁 17. Resultado de la fase

- **El IDOR de 2018 se corrige con seguridad por fila**: un paciente ve sus 426 resultados, y el protocolo ajeno devuelve una lista vacía. La deuda de la Fase 10 queda pagada.
- **Apuesta ganada, con condición:** RLS cuesta 92 bloques sobre 600 cuando la política compara una columna indexada de la tabla protegida. Una política por subconsulta recorre la tabla protegida aunque el índice exista en la otra tabla (9.684 bloques frente a 5).
- **El MD5 del portal se revierte entero en unos 3,5 s.**
- **`security_invoker` es la diferencia entre la API y el IDOR**: sin ella, un paciente ve filas de 165 pacientes en mil.
- **Boss V: 0 de 5 en el punto de partida, 5 de 5 con la solución.**
- **Boss del puente: 1 de 5 en el punto de partida, 5 de 5 con la solución.** Para el volumen de Alameda, la cola en Postgres consume 2,4 a 2,9 veces más rápido que Artemis en este laboratorio; el *broker* se justifica para el SIH por el contrato, no por la velocidad.

Esta fase cierra el Bloque V. El Bloque VI no enseña nada nuevo: pone la bitácora sobre la mesa y decide.

> 🏆 **"Un martes", opcional.** Si vas armando la base nueva de Alameda bloque a bloque, el Bloque V te deja cómo sale a la red:
> el portal por una API con seguridad por fila, la exportación por una cola y un outbox, y el SIH por un *broker* con su contrato.
> La facturación de un martes todavía no corrió nunca sobre la base nueva con legacy viva al lado, y eso es el Bloque VI: la
> migración de la Fase 25, y el martes de la Fase 26, que va a encontrar lo que al modelo todavía le falta para facturar.

> **La señal de que quedó bien:** *"El portal no le muestra a nadie lo que no es suyo, aunque adivine el número; sé cuánto cuesta esa seguridad y dónde va su índice; y sé por qué el SIH va por un broker y el portal no."*

> 🏷️ **No cierres la fase sin el tag.** Con el checklist en verde y `git status` limpio:
>
> ```bash
> git tag -a fase-23-la-base-como-producto -m "F23 cerrada: la API con PostgREST, la seguridad por fila, el MD5 de 2018 revertido, el boss V y el boss del puente"
> ```
>
> Commits de la fase con prefijo `f23:`, los de ejercicio `f23 ej26: …`.
