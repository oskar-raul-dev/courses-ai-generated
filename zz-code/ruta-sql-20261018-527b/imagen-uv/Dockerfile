# La imagen de uv de las pruebas, más lo que el ODBC de mssql-python pide en Debian y no trae su wheel.
FROM ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim@sha256:0f373734b28e2dea75993003daacf1badd7aa88f3ba88e8d1b4779dabf54ad08
LABEL curso=ruta-sql
RUN apt-get update && apt-get install -y --no-install-recommends libltdl7 libkrb5-3 libgssapi-krb5-2 \
    && rm -rf /var/lib/apt/lists/*
