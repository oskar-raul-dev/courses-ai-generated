from lab import config
import oracledb, psycopg, pymysql

pg = psycopg.connect(**config.POSTGRES)                     # 127.0.0.1:25432, base alameda
my = pymysql.connect(**config.MYSQL, database="legacy")     # 127.0.0.1:23306
o = config.ORACLE
ora = oracledb.connect(user="alameda", password=o["password"],
                       dsn=f"{o['host']}:{o['port']}/{o['service']}")   # servicio FREEPDB1
print(pg.info.server_version, my.get_server_info(), ora.version)
