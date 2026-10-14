-- Loads one profile of the box into Postgres (schema legacy). psql -v perfil=m -f carga/postgres.sql
\timing on
DROP SCHEMA IF EXISTS legacy CASCADE;
CREATE SCHEMA legacy;
CREATE TABLE legacy."Pacientes" ("IdPaciente" integer, "Nombre" varchar(120), "DNI" varchar(20), "FechaNac" date,
  "Sexo" char(1), "Telefono" varchar(60), "ObraSocial" varchar(40), "NroAfiliado" varchar(20));
CREATE TABLE legacy."Protocolos" ("IdProtocolo" integer, "NroProtocolo" varchar(20), "IdPaciente" integer,
  "Fecha" date, "Sede" char(1), "ObraSocialTexto" varchar(40));
CREATE TABLE legacy."ResultadoItem" ("IdItem" integer, "IdProtocolo" integer, "CodAnalito" varchar(10),
  "Valor" varchar(40), "Unidad" varchar(10));
\set f_pac '/caja/' :perfil '/Pacientes.csv'
\set f_pro '/caja/' :perfil '/Protocolos.csv'
\set f_res '/caja/' :perfil '/ResultadoItem.csv'
COPY legacy."Pacientes" FROM :'f_pac' WITH (FORMAT csv, HEADER true, ENCODING 'LATIN1');
COPY legacy."Protocolos" FROM :'f_pro' WITH (FORMAT csv, HEADER true);
COPY legacy."ResultadoItem" FROM :'f_res' WITH (FORMAT csv, HEADER true);
ANALYZE legacy."Pacientes"; ANALYZE legacy."Protocolos"; ANALYZE legacy."ResultadoItem";
SELECT relname, n_live_tup, pg_size_pretty(pg_total_relation_size(relid)) FROM pg_stat_user_tables WHERE schemaname='legacy' ORDER BY 1;
SELECT "Nombre", "DNI" FROM legacy."Pacientes" WHERE "Nombre" LIKE '%Ñ%' LIMIT 2;
