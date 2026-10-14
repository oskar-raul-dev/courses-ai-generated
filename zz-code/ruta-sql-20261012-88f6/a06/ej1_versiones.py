import importlib.metadata as m
import platform

import pymysql

print("Python", platform.python_version())
for package in ("psycopg", "psycopg-binary", "pymysql", "oracledb"):
    print(f"{package} {m.version(package)}")
print("pymysql.__version__ =", pymysql.__version__)
