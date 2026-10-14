import psycopg

from lab import config

work = psycopg.connect(**config.POSTGRES, application_name="recepcion")
work.execute("SELECT count(*) FROM legacy.\"Pacientes\" WHERE \"Sede\" = 'V'")
print("estado de la conexión:", work.info.transaction_status.name)
with psycopg.connect(**config.POSTGRES, autocommit=True) as watcher:
    row = watcher.execute("SELECT state, now() - xact_start > interval '0' FROM pg_stat_activity "
                          "WHERE application_name = 'recepcion'").fetchone()
    print("pg_stat_activity:", row)
work.close()
