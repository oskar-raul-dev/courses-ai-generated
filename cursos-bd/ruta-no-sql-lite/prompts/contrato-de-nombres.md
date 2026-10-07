# 🧊 Contrato de nombres
## Ruta NoSQL Lite

> **Qué es este documento:** los nombres que muchas fases arrastran y que no se pueden cambiar
> después sin tocarlas todas: los del laboratorio, los del código, los de los datos y los de git.
> **Origen:** agregado el 06/10/2026, en la revisión contra los lineamientos de producción del
> repositorio, **con el curso a medio escribir** (Tandas 0–2 cerradas). No congela nada nuevo:
> recoge lo que ya fijaron el `compose.yaml` de `src/lab/` (verificado en T10, el 29/09/2026),
> `a02`, `a05`, la guía §5 y §13, y lo que las fases publicadas ya usan. Desde ahora, lo que una fase
> nueva necesite se agrega aquí primero.
> **Precedencia:** por debajo del [alcance](alcance-del-proyecto.md) y de la
> [guía](guia-de-estilo-y-convenciones.md); al lado del [diccionario](diccionario-de-terminos.md),
> que fija las palabras. Por encima de cualquier fase ya escrita.
> **Vigencia:** 2026-10-06.

---

## 1. 🧭 Las reglas del contrato

1. **No se inventan valores nuevos** en una fase. Todo nombre, puerto, perfil, tag o variable sale de
   aquí.
2. **No se renombra** lo ya publicado. Si un nombre resultó malo, se documenta la excepción aquí; no se
   arrastra el cambio por veinte documentos.
3. **Lo que todavía no se puede fijar se marca ⏳** con la fase que lo fija, y esa fase lo escribe aquí
   antes de cerrar (§8).
4. **Nunca `latest`, `*` ni rangos de versión**: las imágenes van por digest (`a02`).

---

## 2. 🌍 Valores globales

| Qué | Valor | Nota |
|---|---|---|
| Proyecto de Compose | `condor-lab` | todo lo que levanta el laboratorio lleva ese prefijo de proyecto |
| Puertos del laboratorio publicado | desplazados del de por defecto (tabla de §4), ligados al host y configurables por variable en `src/lab/.env` | para no chocar con motores que el lector ya tenga instalados |
| Puertos de las pruebas de la sesión | aleatorios, los elige Docker (`-p 127.0.0.1::PUERTO`), con un `compose.override.yaml` en `zz-code/` | regla de los lineamientos; nunca los del curso |
| Etiqueta de las pruebas de la sesión | `curso=ruta-no-sql-lite` | solo se borra lo que la lleva |
| Entornos | TypeScript (Node 24, sin compilar) para el arnés, el generador y casi todas las fases; Python con `uv` solo en analítico embebido y en la ingesta vectorial | regla de los dos entornos de `a06` |

> ⚠️ **Excepción documentada: los perfiles y los servicios se llaman en español** (`documental`,
> `clave-valor`, `busqueda`…), aunque la guía §5 pide inglés para todo lo que se ejecuta. Se nombran
> por familia y no por producto para que cambiar de motor no rompa ningún comando, y la familia es
> un concepto del curso, que se dice en español. Están publicados desde la Tanda 0 y no se renombran
> (regla 2). Las variables de entorno siguen en inglés y mayúsculas (`CLAVE_VALOR_PORT`).

---

## 3. 🗂️ La estructura de archivos

```text
ruta-no-sql-lite/
├── README.md                          se actualiza en la Tanda 7
├── 0-ESTRUCTURA-CURSO.md              el temario; se actualiza en la Tanda 7
├── 00-historia-de-condor.md           la historia: el lector la lee antes de F00
├── 00-…md … 25-…md                    fases: NN-<familia>-levantar-y-modelar / -romper-y-medir
├── a01-…md … a10-…md                  apéndices transversales
├── h-mini-NN-<familia>-<empresa>.md   miniproyectos; NN es el orden de la familia, no la fase
├── miniproyectos.md                   índice de los miniproyectos
├── INSTINTOS.md · bitacora-de-medicion.md    documentos vivos (con a09)
├── prompts/                           maquinaria; el lector no la abre
└── src/                               el código; un solo .gitignore, en src/
    ├── lab/                           compose.yaml, .env.example, generator/, harness/, check/, data/ (no se versiona)
    └── NN-<slug>/ · aNN-<slug>/       una carpeta por fase o apéndice que deja código, con el nombre exacto del documento
```

La lista de nombres de archivo de cada fase está en la [propuesta de fases](propuesta-fases-y-alcance.md)
§10.

---

## 4. 🧱 El laboratorio: perfiles, servicios y puertos

Un perfil por familia, y el servicio se llama igual que el perfil (`a02`). Analítico embebido no tiene
perfil: DuckDB corre dentro del proceso de Python.

| Perfil y servicio | Motor | Puerto del host (variable) | Fases |
|---|---|---|---|
| `base` | PostgreSQL 18 + pgvector | `15432` (`BASE_PORT`) | todas |
| `documental` | MongoDB | `27018` (`DOCUMENTAL_PORT`) | F03–F04 |
| `clave-valor` | Valkey | `16379` (`CLAVE_VALOR_PORT`) | F05–F06 |
| `series` | TimescaleDB | `15433` (`SERIES_PORT`) | F09–F10 |
| `busqueda` | OpenSearch | `19200` (`BUSQUEDA_PORT`) | F11–F12 |
| `grafos` | Neo4j Community | `17474` y `17687` (`GRAFOS_HTTP_PORT`, `GRAFOS_BOLT_PORT`) | F13–F14 |
| `vectorial` | Qdrant | `16333` y `16334` (`VECTORIAL_HTTP_PORT`, `VECTORIAL_GRPC_PORT`) | F15–F16 |
| `columnar` | Cassandra, con el heap fijado | `19042` (`COLUMNAR_PORT`) | F17–F18 |
| `offline` | CouchDB | `15984` (`OFFLINE_PORT`) | F19–F20 |
| `newsql` | CockroachDB, un nodo | `26258` y `18080` (`NEWSQL_PORT`, `NEWSQL_UI_PORT`) | F21 |
| `newsql-global` (+ `newsql-global-puerta`) | CockroachDB, nueve nodos en tres regiones | `26259` (`NEWSQL_GLOBAL_PORT`) | F22 y el boss del Bloque IV |

**Volúmenes:** `<servicio>-data` (`base-data`, `documental-data`…), uno por servicio salvo
`newsql-global`, que vive en memoria. Las versiones y los digests no se escriben aquí: viven en `a02`.

---

## 5. 🗄️ Datos

- **Dominio:** las diez entidades de la historia §6, con las convenciones de nombrado del
  [diccionario](diccionario-de-terminos.md) §4.
- **Datasets del generador** (`a05`): `src/lab/data/<focus>-<volume>/`, con `--focus` en `part`,
  `partCatalog`, `workOrder`, `reading` o `pirep`, y `--volume` en `10k`, `1m` o un entero. Los hashes
  de cada uno están en `a05` y se comprueban, no se copian aquí.
- **Vectores del millón:** `src/lab/data/pirep-1m/pirep-e5-{passage,noprefix}.f32` (media hora cada
  uno en CPU; no se regeneran sin necesidad).

---

## 7. 🏷️ Git

- **Tags de fase:** `fase-NN-<slug>`, al cerrar cada fase; los crea el autor.
- **Commits:** prefijo `fNN:`; los de ejercicio, `fNN ejM: …`.
- **Miniproyectos:** `mini-NN-<slug>`, en su propio espacio, para que `git tag -l 'fase-*'` siga
  siendo el índice limpio del curso.
- **Apéndices:** sin tag, salvo los que dejan archivos en el repositorio.

(La numeración salta de §5 a §7 para conservar la de la plantilla de los lineamientos: este curso no
tiene eventos ni colas entre servicios.)

---

## 8. 🔒 Fijado por fase

Las fases ya escritas (F00–F06, F15–F16) usaron solo nombres de las secciones anteriores. Desde la
Tanda 3, cada fase que fije un nombre nuevo (una colección, un índice, un keyspace, un script de
`src/NN-…/`) agrega aquí su subsección **al cerrarse**, con fecha y tanda.

---

## 9. ❓ Qué hacer si falta un nombre

1. Se busca aquí, en el diccionario §4 y en las fases ya escritas.
2. Si no existe, se propone con las convenciones del diccionario §4.2 y se agrega aquí, con la fase
   que lo estrena.
3. Si choca con uno existente, gana el existente.
