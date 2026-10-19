show wal_level; show max_replication_slots; select slot_name from pg_replication_slots;
select c.relname, c.relreplident, (select count(*) from pg_constraint k where k.conrelid=c.oid and k.contype='p') pk
from pg_class c where c.relnamespace='legacy'::regnamespace and c.relname in ('Protocolos','ProtocoloPracticas','ResultadoItem','Pacientes','Precios');
select count(*) filter (where exists (select 1 from pg_constraint k where k.conrelid=c.oid and k.contype='p')) con_pk, count(*) from pg_class c where c.relnamespace='legacy'::regnamespace and relkind='r' and relname in (select unnest(array['Hemograma','Quimica','Orina','Serologia','Brucelosis']));
select max("IdItem") from legacy."ResultadoItem"; select max("IdProtocolo") from legacy."Protocolos" where "IdProtocolo" < 100000000; select max("Id") from legacy."ProtocoloPracticas";
