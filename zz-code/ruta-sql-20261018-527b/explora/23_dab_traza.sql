IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = 'ss05_dab') DROP EVENT SESSION ss05_dab ON SERVER;
CREATE EVENT SESSION ss05_dab ON SERVER
ADD EVENT sqlserver.rpc_completed (ACTION (sqlserver.username) WHERE sqlserver.database_name = N'ss05'),
ADD EVENT sqlserver.sql_batch_completed (ACTION (sqlserver.username) WHERE sqlserver.database_name = N'ss05')
ADD TARGET package0.ring_buffer;
ALTER EVENT SESSION ss05_dab ON SERVER STATE = START;
GO
