SET QUOTED_IDENTIFIER ON;
WITH t AS (SELECT CAST(xet.target_data AS xml) AS x FROM sys.dm_xe_session_targets AS xet
           JOIN sys.dm_xe_sessions AS xs ON xs.address = xet.event_session_address WHERE xs.name = 'ss05_dab')
SELECT TOP (6) e.value('(action[@name="username"]/value)[1]', 'nvarchar(50)') AS usuario,
       LEFT(COALESCE(e.value('(data[@name="statement"]/value)[1]', 'nvarchar(max)'),
                     e.value('(data[@name="batch_text"]/value)[1]', 'nvarchar(max)')), 400) AS texto
FROM t CROSS APPLY t.x.nodes('/RingBufferTarget/event') AS n(e);
GO
ALTER EVENT SESSION ss05_dab ON SERVER STATE = STOP;
DROP EVENT SESSION ss05_dab ON SERVER;
GO
