-- sqlserver
-- ss03 · §5.5. ¿Por qué PSP no armó variantes para la consulta por sede? El evento extendido lo dice.
--   ../ss01-la-base-en-su-motor-original/sqlcmd.sh < 06_psp.sql
IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'ss03_psp') DROP EVENT SESSION ss03_psp ON SERVER;
CREATE EVENT SESSION ss03_psp ON SERVER
ADD EVENT sqlserver.parameter_sensitive_plan_optimization_skipped_reason (WHERE sqlserver.database_name = N'ss03'),
ADD EVENT sqlserver.query_with_parameter_sensitivity (WHERE sqlserver.database_name = N'ss03')
ADD TARGET package0.ring_buffer;
ALTER EVENT SESSION ss03_psp ON SERVER STATE = START;
GO
USE ss03;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC dbo.resultados_por_sede @sede = N'C', @desde = '2026-09-01';
GO
-- Lo que registró cada evento: el motivo del salto, o los predicados que le parecieron interesantes.
-- sqlcmd abre la sesión con QUOTED_IDENTIFIER apagado, y los métodos de xml lo exigen (Msg 1934).
SET QUOTED_IDENTIFIER ON;
WITH t AS (SELECT CAST(xet.target_data AS xml) AS x FROM sys.dm_xe_session_targets AS xet
           JOIN sys.dm_xe_sessions AS xs ON xs.address = xet.event_session_address WHERE xs.name = 'ss03_psp')
SELECT e.value('@name', 'nvarchar(80)') AS evento,
       e.value('(data[@name="reason"]/text)[1]', 'nvarchar(80)') AS motivo,
       e.value('(data[@name="interesting_predicate_details"]/value)[1]', 'nvarchar(400)') AS predicados,
       e.value('(data[@name="psp_optimization_supported"]/value)[1]', 'nvarchar(10)') AS soportado
FROM t CROSS APPLY t.x.nodes('/RingBufferTarget/event') AS n(e);
GO
ALTER EVENT SESSION ss03_psp ON SERVER STATE = STOP;
DROP EVENT SESSION ss03_psp ON SERVER;
GO
