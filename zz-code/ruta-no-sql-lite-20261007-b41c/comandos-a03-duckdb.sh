# Comandos de la sección DuckDB de a03, tal como corrieron (desde src/).
uv run python -c "import duckdb; print(duckdb.connect('lab/data/analitico/condor.duckdb', read_only=True).sql('SHOW TABLES'))"
uv run python -c "import duckdb; c = duckdb.connect('lab/data/analitico/condor.duckdb', read_only=True); print(c.sql(\"SELECT registration, model, operator_id FROM aircraft WHERE has_flight_recorder LIMIT 3\")); print(c.sql('SELECT count(*) FROM reading'))"
uv run python -c "import duckdb; c = duckdb.connect('lab/data/analitico/condor.duckdb', read_only=True); c.sql(\"INSERT INTO aircraft VALUES ('HK-9999', 'ATR 42-500', 'turboprop-twin', 'OP-LLA', 'CO', false, true)\")"
uv run python -c "import duckdb; c = duckdb.connect(); c.sql('CREATE TABLE landing (registration VARCHAR, flight_minutes INTEGER)'); c.sql(\"INSERT INTO landing VALUES ('HK-4207', 84)\"); print(c.sql('SELECT * FROM landing')); c.sql(\"DELETE FROM landing WHERE registration = 'HK-4207'\"); print(c.sql('SELECT count(*) FROM landing'))"
uv run python -c "import duckdb; print(duckdb.connect('lab/data/analitico/condor.duckdb', read_only=True).sql(\"EXPLAIN SELECT avg(egt_c) FROM reading WHERE aircraft = 'HK-4207'\"))"
