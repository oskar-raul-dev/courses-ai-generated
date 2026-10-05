# mdm-lab: el laboratorio de producción del camino base de 01-bases.
# SQLite (CLI y herramientas), Python con venv, radb y Faker, con versiones fijadas en P8.
# Herramienta de producción, no material del curso: el contenedor del lector es a09.
FROM python:3.14.8-slim-trixie

LABEL curso=01-bases

# sqlite3-tools trae sqlite3_analyzer; las versiones son las de Debian 13 (trixie).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      sqlite3=3.46.1-7+deb13u2 \
      sqlite3-tools=3.46.1-7+deb13u2 \
      git \
 && rm -rf /var/lib/apt/lists/*

# El venv imita lo que hace el lector en a02; requirements.txt fija cada versión.
COPY requirements.txt /opt/requirements.txt
RUN python -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir -r /opt/requirements.txt

ENV PATH="/opt/venv/bin:${PATH}"
WORKDIR /curso/cursos-bd/gestores-sql/01-bases
CMD ["sleep", "infinity"]
