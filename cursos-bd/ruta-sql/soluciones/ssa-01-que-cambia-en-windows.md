# ✅ Soluciones — Apéndice ssa-01: Qué cambia en Windows

> **Curso:** Ruta SQL · Solucionario de [ssa-01](../ssa-01-que-cambia-en-windows.md)
> **Ejercicios:** 6 · **Motor:** SQL Server 2025 CU9 `mcr.microsoft.com/mssql/server@sha256:2b5b58162112…` (emulado, en Linux)
> **Fecha de verificación ejecutada:** 18/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

---

## 🟢 Fácil (1–2)

### Ejercicio 1

```text
host_platform host_distribution host_release
Linux         Ubuntu            24.04
solo_windows
0
```

En el contenedor, el motor corre sobre Ubuntu 24.04 y acepta las dos autenticaciones (0). En el servidor de Alameda, `sys.dm_os_host_info`
diría `Windows` y la versión de Windows Server; `IsIntegratedSecurityOnly` daría 0 también, porque Alameda usa *logins* de SQL Server (el
LEEME de la caja). Si diera 1, ningún usuario con clave del motor podría entrar, y la conexión de Matías fallaría.

### Ejercicio 2

```text
servicename                     status_desc
MSSQLSERVER                     Running
SQL Server Agent (MSSQLSERVER)  Stopped
```

El Agente viene detenido en el contenedor. Se enciende con `MSSQL_AGENT_ENABLED=true` en el entorno del servicio (o con `mssql-conf set
sqlagent.enabled true` en una instalación de Linux). En el servidor de Alameda, con Standard en Windows, el Agente es un servicio de Windows
aparte, y suele estar encendido porque corre los respaldos.

---

## 🟡 Intermedio (3–4)

### Ejercicio 3

```text
Msg 15392, Level 16, State 2, Server a07be756749e, Procedure sp_configure, Line 177
The specified option 'xp_cmdshell' is not supported by this edition of SQL Server and cannot be changed using sp_configure.
Msg 15392, Level 16, State 2, Server a07be756749e, Procedure sp_configure, Line 177
The specified option 'filestream access level' is not supported by this edition of SQL Server and cannot be changed using sp_configure.
```

El mensaje es el genérico de una opción no disponible en esa instalación. La edición es Enterprise Developer, que tiene todas las funciones
de Enterprise; lo que falta es el sistema operativo: la tabla de 2025 pone `xp_cmdshell` y FILESTREAM entre lo no disponible en Linux. Al
terminar, `sp_configure 'show advanced options', 0; RECONFIGURE;` deja todo como estaba, y las dos opciones siguen en 0.

### Ejercicio 4

```bash
docker run -d --name ss-tztest --label curso=ruta-sql --platform linux/amd64 -m 2g \
  -e ACCEPT_EULA=Y -e MSSQL_PID=Developer -e MSSQL_SA_PASSWORD=Lab-2026-pass -e TZ=America/Argentina/Cordoba \
  mcr.microsoft.com/mssql/server@sha256:2b5b581621126574f3d1f75e78d3eebe8d05aedb59ad0cfdf9aa42cb0634d726
# cuando sqlcmd conecte:
docker exec ss-tztest /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P Lab-2026-pass -W \
  -Q "SELECT CURRENT_TIMEZONE() AS zona, SYSDATETIME() AS servidor, SYSUTCDATETIME() AS utc"
docker rm -f -v ss-tztest          # el contenedor y su volumen anónimo, nada más
```

```text
zona                              servidor                     utc
(UTC-03:00) City of Buenos Aires  2026-10-18 22:20:52.8939582  2026-10-19 01:20:52.8982340
```

En el laboratorio, `CURRENT_TIMEZONE()` es UTC y las dos horas son la misma. Con `TZ`, el servidor da la hora de Córdoba, tres horas menos.
En `dbo.resultado` de ss04 **no cambia nada**: los períodos de una tabla temporal se guardan en UTC en cualquier servidor. Lo que cambia es
que, en un servidor en hora local, comparar un período con `SYSDATETIME()` da tres horas de error, y el `AS OF` con la hora local cae antes
de lo que se quería: es la rotura de ss04, más fácil de cometer.

---

## 🟠 Difícil (5–6) — rúbrica

### Ejercicio 5

*Las órdenes escaneadas.*

**Rúbrica (sobre 4 puntos):** 1 punto por el respaldo (FILESTREAM entra en el respaldo de la base, y el respaldo de seis horas de la Fase 09
no se achica; fuera de la base, el respaldo de la base se achica y el de los archivos va por otro camino); 1 por la transacción (FILESTREAM
es transaccional con la fila; afuera, la base guarda la referencia y hay que tolerar un archivo sin fila o una fila sin archivo); 1 por la
migración (FILESTREAM es de SQL Server sobre Windows: no está en Linux ni en Postgres, y es una dependencia más; un almacenamiento de objetos
sirve igual con cualquier motor); 1 por la elección razonada para Alameda, que la Fase 09 ya sugiere: fuera de la base.

### Ejercicio 6

*La lista para Verónica.*

**Rúbrica (sobre 5 puntos):** 1 punto cada una, hasta cinco, de estas o de otras que el lector encuentre, con su consulta y su fase:
el sistema operativo y el *build* (`@@VERSION`, todo el track); la zona (`CURRENT_TIMEZONE()`, ss04); el idioma de la sesión de cada
*login* (`SELECT name, default_language_name FROM sys.server_principals`, ss01); la intercalación de la base (`DATABASEPROPERTYEX(…,
'Collation')`, ss01); el nivel de compatibilidad (`sys.databases`, ss03); RCSI y `SNAPSHOT` (`sys.databases`, ss02); Query Store
(`sys.database_query_store_options`, ss03); la edición, porque Standard no tiene el ajuste automático ni las operaciones en línea
(`SERVERPROPERTY('Edition')`, ss03 y ss04).
