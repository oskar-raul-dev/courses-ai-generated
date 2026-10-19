# 💀☕ Boss del puente — El puente

El encargo de **Matías Ledesma** está en la
[Fase 23](../../../23-la-base-como-producto.md#-16b-boss-del-puente--el-puente): la interfaz con el SIH en Java 25 y
Apache Artemis, con mensajes que imitan HL7 v2, caídas a mitad de camino, correcciones fuera de orden y mensajes
veneno. Cierra con una medición: **¿hacía falta un broker?**, contra la cola en Postgres de la Fase 22.

## Qué hay

| Archivo | Qué es | ¿Se edita? |
|---|---|---|
| `01_setup.sql` | el punto de partida: las tablas del lado del laboratorio y del lado del SIH (que aquí vive en Postgres, en `staging`) | **sí** |
| `Puente.java` | el servicio, en un solo archivo y sin frameworks: `purgar`, `producir`, `consumir` y `medir` | **sí** |
| `pom.xml` | solo baja las dependencias (el cliente de Artemis y el driver de Postgres) a `lib/` | no |
| `arnes.py` | evalúa cinco criterios (P1 a P5) sobre el directorio que le pases, corriendo el servicio en el contenedor de Java 25 | no |

## Cómo se corre

Nada de Java en tu máquina: Maven y Java corren en contenedor ([`a06`](../../../a06-python-java-y-drivers.md#-java-25-un-archivo-y-un-driver)).
Desde esta carpeta, una vez:

```bash
docker run --rm -v "$PWD":/w -w /w maven@sha256:a291659c5ffddf142e5174df5bfc3f3dcb48706e44868f341ef7914b39a254c9 \
  mvn -q dependency:copy-dependencies -DoutputDirectory=lib
```

Y desde `src/`:

```bash
uv run lab up base puente
uv run python 23-la-base-como-producto/puente/arnes.py               # el punto de partida
uv run python 23-la-base-como-producto/puente/arnes.py mi-puente/    # tu copia, con su lib/ o con PUENTE_LIB
```

`lib/` no se versiona. **La solución no se publica**.
