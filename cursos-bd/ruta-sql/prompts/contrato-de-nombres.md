# 🧊 Contrato de nombres
## Ruta SQL

> **Qué es este documento:** los nombres que muchas fases arrastran y que no se pueden cambiar
> después sin tocarlas todas: los del laboratorio, los del código, los de los datos y los de git.
> **Origen:** agregado el 06/10/2026, en la revisión contra los lineamientos de producción del
> repositorio, **antes de T0**. Recoge lo que ya fijaron el alcance (§7, §9, §12), la guía §5 y §14 y
> las dos propuestas; lo que depende de la verificación de laboratorio (P8) queda ⏳ y lo fija P11.
> **Precedencia:** por debajo del [alcance](alcance-del-proyecto.md) y de la
> [guía](guia-de-estilo-y-convenciones.md); al lado del [diccionario](diccionario-de-terminos.md),
> que fija las palabras. Por encima de cualquier fase.
> **Vigencia:** 2026-10-06.

---

## 1. 🧭 Las reglas del contrato

1. **No se inventan valores nuevos** en una fase. Todo nombre, puerto, perfil, esquema, tag o
   variable sale de aquí.
2. **No se renombra** lo ya publicado. Si un nombre resultó malo, se documenta la excepción aquí.
3. **Lo que todavía no se puede fijar se marca ⏳** con la tanda que lo fija, y esa tanda lo escribe
   aquí antes de cerrar (§8).
4. **Nunca `latest`, `*` ni rangos de versión**: las imágenes van por digest, y solo en `a02` (D12).

---

## 2. 🌍 Valores globales

| Qué | Valor | Nota |
|---|---|---|
| Proyecto de Compose | ⏳ lo fija `a02` en T1 | prefijo de todo lo que levanta el laboratorio |
| Puertos del laboratorio publicado | ⏳ lo fija `a02` en T1, después de P8 | decisión del curso: de por defecto o desplazados y configurables por variable, como en la NoSQL Lite |
| Puertos de las pruebas de la sesión | aleatorios, los elige Docker (`-p 127.0.0.1::PUERTO`), con un `compose.override.yaml` en `zz-code/` | regla de los lineamientos; nunca los del curso |
| Etiqueta de las pruebas de la sesión | `curso=ruta-sql` | solo se borra lo que la lleva |
| Entornos | SQL y Python con `uv` en todo el camino base; Java 21 solo en el boss del puente y en `a10` | alcance §9, D11 |
| Comando del laboratorio | `lab up`, `lab load --profile s\|m\|l` (S por defecto), `lab load --engine mysql --tables …`, `lab measure`, `lab race` | ⏳ dónde vive el script y su forma exacta, en T1 (`a02`, `a04`, `a05`) |

> ⚠️ **Excepción documentada: dos perfiles se llaman en español** (`contraste` y `puente`), aunque la
> guía §5 pide inglés para todo lo que se ejecuta: nombran el papel en el curso, no el producto, como
> los perfiles de la NoSQL Lite. Si T1 prefiere otros nombres, los cambia aquí antes de escribir `a02`.

---

## 3. 🗂️ La estructura de archivos

```text
ruta-sql/
├── README.md                          T15
├── 0-ESTRUCTURA-CURSO.md              T15
├── 00-historia-de-alameda.md          la historia: el lector la lee antes de F00
├── 00-…md … 26-…md                    fases; los slugs canónicos, en la propuesta de fases §11
├── a01-…md … a10-…md                  apéndices; slugs en la propuesta de apéndices §2
├── ss01-…md … ss05-…md · ssa-01-…md   track opcional de SQL Server
├── INSTINTOS.md · bitacora-de-medicion.md    documentos vivos (con a08)
├── soluciones/                        un solucionario por documento con ejercicios, con su mismo nombre (D18)
├── prompts/                           maquinaria; el lector no la abre
└── src/                               el código; un solo .gitignore, en src/ (nace en T0)
    ├── lab/                           compose.yaml, generator/, el arnés y la caja generada (no se versiona)
    └── NN-<slug>/ · aNN-<slug>/       una carpeta por fase o apéndice que deja código, con el nombre exacto del documento
```

---

## 4. 🧱 El laboratorio: perfiles

| Perfil | Motor o servicio | Para qué | Fases |
|---|---|---|---|
| `base` | PostgreSQL | el motor principal, siempre arriba | todas |
| `contraste` | MySQL | el contraste donde cambia la decisión | según la ficha |
| `oracle` | Oracle Database Free | el caso de estudio; sin números publicados | según la ficha |
| `mongo` | MongoDB | el invitado del duelo | F20 |
| `api` | PostgREST | la base como producto | F23, boss V |
| `puente` | ActiveMQ Artemis y el servicio Java 21 | el boss del puente | F23 |
| `sqlserver` | SQL Server | el track opcional | `ss01`–`ss05` |

Servicios, volúmenes, puertos y digests: ⏳ T1 (`a02`), con la tabla de RAM medida en P8.

---

## 5. 🗄️ Datos

- **Entidades del modelo nuevo**, en `snake_case` y en singular (guía §5, D10): `patient`,
  `identity_document`, `lab_order`, `order_item`, `practice`, `analyte`, `result`,
  `reference_range`, `specimen`, `payer`, `agreement`, `site`, `physician`, `invoice`, `appointment`.
- **Restricciones e índices:** `<tabla>_<columnas>_<sufijo>`, con los sufijos de Postgres (`pkey`,
  `key`, `fkey`, `check`, `idx`, `excl`).
- **Esquema `legacy`:** la caja tal cual, con sus nombres originales y comillas donde el motor las
  exija (`legacy."Pacientes"`, `legacy."ResultadoItem"`). Nada nuevo se crea en `legacy`. Se carga en
  Postgres siempre y en MySQL y Oracle solo las tablas que pide cada fase (D13).
- **La verdad del generador:** ⏳ `a05` decide en T1 cómo se guarda (el prompt propone un esquema
  `truth` aparte).
- **Esquema del modelo nuevo:** ⏳ lo fija F01 o F03 al crear la primera tabla.
- **Perfiles de volumen:** S, M y L (D4); los conteos, ⏳ P8 → `a05`.

---

## 7. 🏷️ Git

- **Tags de fase:** `fase-NN-<slug>`; commits con prefijo `fNN:` y los de ejercicio `fNN ejM: …`.
- **Track:** `ss-fase-NN-<slug>` y `ssNN:`, para que `git tag -l 'fase-*'` siga siendo el índice
  limpio del camino base.
- **Apéndices que dejan archivos:** `apendice-a02-compose`, `apendice-a05-la-caja` y
  `apendice-a10-access-de-museo`. Los demás, sin tag.

(La numeración salta de §5 a §7 para conservar la de la plantilla de los lineamientos: los eventos y
colas del boss del puente se fijan en §8 cuando T11 los diseñe.)

---

## 8. 🔒 Fijado por tanda

Cada tanda que fije un nombre nuevo (el proyecto de Compose, los puertos, el esquema del modelo, la
cola del puente) agrega aquí su subsección **al cerrarse**, con fecha y tanda, y quita su ⏳ de arriba.

---

## 9. ❓ Qué hacer si falta un nombre

1. Se busca aquí, en el diccionario §4 y en las fases ya escritas.
2. Si no existe, se propone con las convenciones de la guía §5 y se agrega aquí, con la fase que lo
   estrena.
3. Si choca con uno existente, gana el existente.
