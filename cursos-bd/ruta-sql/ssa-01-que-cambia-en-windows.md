# 🪟 Apéndice ssa-01 — Qué cambia en Windows

> **Curso:** Ruta SQL · Track SQL Server · Consulta rápida · **1 h** · opcional
> **Usado por:** [ss01](ss01-la-base-en-su-motor-original.md) a [ss05](ss05-data-api-builder-y-json.md) · **Versiones cubiertas:** SQL Server 2025 CU9 (17.0.5005.3) en Linux, la imagen del laboratorio; SQL Server 2025 en Windows, por la documentación
> **Fecha de verificación ejecutada:** 18/10/2026

**Esto no se lee de corrido.** Se entra buscando por qué algo que el track hizo en el contenedor no es como lo hace la base de Alameda,
que corre en un Windows. El laboratorio es SQL Server sobre Linux; Alameda, desde 2011, es SQL Server sobre Windows Server, con Standard
desde 2014. El motor es el mismo binario de base de datos; lo que cambia es lo que está alrededor.

**Qué queda fuera:** instalar SQL Server en Windows paso a paso, que la documentación de Microsoft cubre mejor; administrar Windows Server;
y cualquier número de SQL Server, por la regla del track ([`a09`](a09-licencias-publicacion-y-riesgo.md#-sql-server-la-cláusula-tal-cual)).

---

## Índice

- [La autenticación integrada](#-la-autenticación-integrada)
- [Alta disponibilidad: WSFC contra Pacemaker](#️-alta-disponibilidad-wsfc-contra-pacemaker)
- [Las herramientas: SSMS, VS Code y los dos `sqlcmd`](#-las-herramientas-ssms-vs-code-y-los-dos-sqlcmd)
- [Lo que no existe en Linux](#-lo-que-no-existe-en-linux)
- [La región del servidor: zona, idioma e intercalación](#-la-región-del-servidor-zona-idioma-e-intercalación)
- [Cuándo usar qué](#-cuándo-usar-qué)
- [Referencias](#-referencias)

---

## 🔑 La autenticación integrada

En Windows, el modo más común es la **autenticación de Windows**: el usuario entra con su cuenta del dominio (Kerberos, o NTLM si Kerberos
no se puede), sin una clave para la base. Es la que conviene en una red con Active Directory, porque las altas y bajas de personas son las
del dominio. La otra es la **autenticación de SQL Server**: un *login* con usuario y clave guardados en el motor. Alameda usa esta: el LEEME de
la caja dice *"Usuario y clave del SQL Server: pedírselos a Verónica"*, y el laboratorio también (`sa`, `dab_api`).

`SELECT SERVERPROPERTY('IsIntegratedSecurityOnly')` dice cuál acepta la instancia: 1 es solo Windows; 0, las dos. El contenedor da 0.

SQL Server en Linux **también** puede autenticar contra Active Directory, con más trabajo: el equipo se une al dominio (o no, en
contenedores), se crea un usuario con su SPN, se genera un *keytab* (con `adutil` o `ktpass`) y se le dice al motor dónde está, con
`mssql-conf`. La documentación tiene un tutorial para cada camino. Lo que **no** funciona en Linux, según la tabla de funciones no
soportadas de 2025, es la autenticación integrada en los servidores vinculados y en los *endpoints* de los grupos de disponibilidad: ahí van
certificados.

---

## 🛡️ Alta disponibilidad: WSFC contra Pacemaker

En Windows, una instancia en clúster (FCI) y un grupo de disponibilidad (AG) se apoyan en el **Windows Server Failover Cluster** (WSFC), que
decide quién es el primario y mueve los recursos. En Linux, el gestor de clúster es **Pacemaker**, y el AG se crea con `CLUSTER_TYPE =
EXTERNAL`: SQL Server no decide la conmutación, la decide Pacemaker con su agente de recursos. También existe `CLUSTER_TYPE = NONE`, para
escalar lecturas sin conmutación automática.

| | Windows | Linux |
|---|---|---|
| gestor del clúster | WSFC | Pacemaker (`CLUSTER_TYPE = EXTERNAL`) |
| autenticación entre réplicas | Windows o certificados | certificados |
| AG en Standard | *Basic*: dos réplicas, una base | igual |
| AG completo | Enterprise | Enterprise |

La última fila es la que importa para Alameda: con Standard, la alta disponibilidad es un AG *Basic*, de dos réplicas y una base por grupo,
en los dos sistemas operativos (tabla de ediciones de 2025). El *standby* del SIH, que es Oracle Enterprise con Data Guard, no tiene un
equivalente barato del lado de SQL Server.

---

## 🧰 Las herramientas: SSMS, VS Code y los dos `sqlcmd`

**SQL Server Management Studio** (SSMS) es solo de Windows. Es lo que usa Matías, y lo que generó `esquema/ALAMEDA.sql`. En macOS y Linux, la
herramienta gráfica que Microsoft recomienda es **Visual Studio Code con la extensión `mssql`**: *Azure Data Studio*, la que ocupaba ese lugar,
se retiró el 28 de febrero de 2026.

`sqlcmd` tiene **dos** versiones, y la documentación las separa:

- **`sqlcmd` (ODBC)**, el de siempre, que viene en `mssql-tools18`. Es el del contenedor del laboratorio y el de los scripts del track.
- **`sqlcmd` (Go)**, basado en `go-mssqldb`, que se descarga solo y corre en Windows, macOS y Linux.

Una diferencia mordió al track: con el de ODBC, `QUOTED_IDENTIFIER` está **apagado** salvo que se pase `-I`, y los métodos del tipo `xml` y
`json` lo exigen (E-87 de [`a08`](a08-catalogo-de-errores.md), en [ss03](ss03-query-store-y-parameter-sniffing.md)). En el de Go, la
documentación dice: *"The `-I` switch is ignored. Quoted identifiers are always enabled."* Las tres opciones que usa el `sqlcmd.sh` de
[ss01](ss01-la-base-en-su-motor-original.md): `-C` confía en el certificado autofirmado del contenedor, `-W` no rellena las columnas y `-b`
corta en el primer error.

---

## 🚫 Lo que no existe en Linux

La documentación de SQL Server 2025 tiene una tabla de funciones y servicios no disponibles en Linux. Las que tocan a Alameda:

| No disponible en Linux | Por qué le importa a Alameda | Lo vio el track |
|---|---|---|
| FILESTREAM y FileTable | la salida clásica para sacar de las páginas de datos las órdenes escaneadas y los PDF (1,1 TB de 1,4) | `Msg 15392` |
| `xp_cmdshell` y otros procedimientos extendidos | los trabajos que exportan archivos desde el motor | `Msg 15392` |
| subsistemas del Agente: `CmdExec`, PowerShell, SSIS | los trabajos programados que no son T-SQL | el Agente viene detenido |
| *Reporting Services* y *Analysis Services* | los reportes de Matías, si están en SSRS | — |
| replicación de mezcla | — | — |
| `CODEPAGE` en `BULK INSERT` (salvo `'RAW'`) | la carga de archivos en Latin-1 | `Msg 16202` ([ss01](ss01-la-base-en-su-motor-original.md)) |
| *Buffer Pool Extension* | — | — |

Los dos intentos de `sp_configure` dieron el mismo mensaje:

```text
Msg 15392, Level 16, State 2, Server a07be756749e, Procedure sp_configure, Line 177
The specified option 'xp_cmdshell' is not supported by this edition of SQL Server and cannot be changed using sp_configure.
The specified option 'filestream access level' is not supported by this edition of SQL Server and cannot be changed using sp_configure.
```

El mensaje dice "edición", y no es la edición: el laboratorio es Enterprise Developer, que tiene todo. Es el sistema operativo.

El **Agente** existe en Linux y viene apagado en el contenedor (`sys.dm_server_services` dice `Stopped`): se enciende con
`MSSQL_AGENT_ENABLED=true`. Corre trabajos de T-SQL, no de sistema operativo.

---

## 🌎 La región del servidor: zona, idioma e intercalación

Tres cosas que en Windows salen de la instalación del sistema operativo, y en el contenedor salen de su configuración:

```text
zona                                idioma      intercalación
(UTC) Coordinated Universal Time    us_english  SQL_Latin1_General_CP1_CI_AS
```

- **La zona.** `CURRENT_TIMEZONE()` da la del sistema. El servidor de Alameda, un Windows en Córdoba, está en UTC−3, y su `SYSDATETIME()`
  es la hora local; el contenedor está en UTC. Con `TZ=America/Argentina/Cordoba` en el contenedor, `CURRENT_TIMEZONE()` da `(UTC-03:00)
  City of Buenos Aires` y `SYSDATETIME()`, la hora local. Las tablas temporales guardan UTC en los dos ([ss04](ss04-clustered-newsequentialid-y-temporales.md)).
- **El idioma.** El contenedor viene en `us_english` (orden `mdy`). Un servidor en español lee las fechas como `dmy`, y la misma cadena da
  otra fecha ([ss01](ss01-la-base-en-su-motor-original.md), sección 8). `MSSQL_LCID` lo cambia en la instalación del contenedor.
- **La intercalación.** `SQL_Latin1_General_CP1_CI_AS` en los dos, porque es la que SQL Server elige para el inglés de Estados Unidos.
  `MSSQL_COLLATION` la cambia en la instalación.

> ⚠️ **Probar en el contenedor no es probar en el servidor de Alameda.** Todo lo que el track hizo con fechas y textos dependía de estas
> tres cosas. Antes de llevar un script del track a la base real, `SELECT CURRENT_TIMEZONE(), @@LANGUAGE,
> SERVERPROPERTY('Collation')` en los dos.

---

## 🧭 Cuándo usar qué

| Situación | Opción | Por qué |
|---|---|---|
| personas de la red con cuenta en el dominio | autenticación de Windows | las altas y bajas son las del dominio |
| una API o un servicio (DAB, un reporte) | un *login* propio con lo mínimo | no hay persona; hay una aplicación |
| alta disponibilidad con Standard | AG *Basic* (dos réplicas, una base) | lo único que da la edición |
| administrar desde un Mac | VS Code con `mssql`, o `sqlcmd` | SSMS es solo de Windows |
| scripts que usan `xml` o `json` desde `sqlcmd` (ODBC) | `-I` o `SET QUOTED_IDENTIFIER ON` | la opción viene apagada |
| las órdenes escaneadas y los PDF | fuera de la base (un almacenamiento de objetos) | FILESTREAM no está en Linux, y el respaldo ya no entra en la noche |
| un trabajo que llama al sistema operativo | fuera del motor (un programador del sistema) | en Linux el Agente no tiene `CmdExec` |

---

## ⚠️ Advertencias

- La tabla de funciones no disponibles cambia con cada versión: la de esta página es la de 2025, consultada el 18/10/2026.
- El mensaje `Msg 15392` dice "edición" cuando es el sistema operativo; no lo leas como un problema de licencia.
- Las variables `MSSQL_*` del contenedor se aplican al configurarlo la primera vez; sobre un volumen que ya existe, no todas cambian algo
  (lo encontró el track con la memoria, E-98).

---

## 📚 Referencias

- **Ediciones y funciones de SQL Server 2025 en Linux** (con la tabla de no soportadas) — https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-editions-and-components-2025?view=sql-server-ver17
- **Autenticación de Active Directory en Linux** — https://learn.microsoft.com/en-us/sql/linux/security/authentication/active-directory-tutorial?view=sql-server-ver17
- **Grupos de disponibilidad en Linux** — https://learn.microsoft.com/en-us/sql/linux/business-continuity/availability-groups/overview?view=sql-server-ver17
- **`sqlcmd`, las dos versiones** — https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility?view=sql-server-ver17
- **Variables de entorno del contenedor** — https://learn.microsoft.com/en-us/sql/linux/configure/environment-variables?view=sql-server-ver17
- **El retiro de Azure Data Studio** — https://learn.microsoft.com/en-us/sql/tools/whats-happening-azure-data-studio?view=sql-server-ver17

---

## 🧪 Ejercicios (6)

## 🟢 Fácil — leer la instancia (1–2)

### 🟢 Ejercicio 1 — El sistema operativo del motor

Consulta `sys.dm_os_host_info` y `SERVERPROPERTY('IsIntegratedSecurityOnly')` en el contenedor.

**Pregunta:** ¿qué dicen, y qué tendría que decir cada una en el servidor de Alameda?

[Solución](soluciones/ssa-01-que-cambia-en-windows.md#ejercicio-1)

### 🟢 Ejercicio 2 — Los servicios

Consulta `sys.dm_server_services`.

**Objetivo:** el estado del Agente, y la variable del contenedor que lo enciende.

[Solución](soluciones/ssa-01-que-cambia-en-windows.md#ejercicio-2)

## 🟡 Intermedio — lo que no está (3–4)

### 🟡 Ejercicio 3 — `xp_cmdshell` y FILESTREAM

Intenta encender `xp_cmdshell` y `filestream access level` con `sp_configure`, y deja las opciones como estaban.

**Objetivo:** el mensaje literal, y por qué dice "edición" si la del laboratorio es Enterprise Developer.

[Solución](soluciones/ssa-01-que-cambia-en-windows.md#ejercicio-3)

### 🟡 Ejercicio 4 — El reloj de Córdoba

Levanta un contenedor aparte con `TZ=America/Argentina/Cordoba` y compara `CURRENT_TIMEZONE()`, `SYSDATETIME()` y `SYSUTCDATETIME()` con
los del laboratorio. Al terminar, `docker rm -f -v` de ese contenedor y nada más.

**Objetivo:** las tres columnas en los dos, y qué cambia en `dbo.resultado` de ss04 si el servidor está en hora local.

[Solución](soluciones/ssa-01-que-cambia-en-windows.md#ejercicio-4)

## 🟠 Difícil — llevarlo a Alameda (5–6)

### 🟠 Ejercicio 5 — Las órdenes escaneadas

La [Fase 09](09-el-tamano-de-las-cosas.md) midió lo que pesan las imágenes dentro de la base. En Windows, FILESTREAM era una salida.

**Objetivo:** comparar FILESTREAM (Windows) con un almacenamiento de objetos fuera de la base (cualquier sistema), en tres criterios
(respaldo, transacción, migración a Postgres), y decir cuál elegirías para Alameda.

[Solución](soluciones/ssa-01-que-cambia-en-windows.md#ejercicio-5)

### 🟠 Ejercicio 6 — La lista para Verónica

Antes de correr en la base de 2026 cualquier script del track, Verónica quiere saber qué puede dar distinto.

**Objetivo:** una lista de al menos cinco diferencias entre el contenedor y el servidor de Alameda, cada una con la consulta que la
comprueba y la fase del track donde importó.

[Solución](soluciones/ssa-01-que-cambia-en-windows.md#ejercicio-6)

---

> 🏷️ **Este apéndice no lleva tag propio.** Va con los commits del track, con prefijo `ssa01:`.
