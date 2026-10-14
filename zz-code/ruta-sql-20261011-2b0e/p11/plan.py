PAIRS = [
("""> **Vigencia:** 2026-10-07.""", """> **Vigencia:** 2026-10-11."""),
("""   - **T1** exige además **P8** (la verificación de laboratorio) y **P11** (lo verificado,
     trasladado): sin digests, sin RAM medida y sin perfiles calibrados no hay `a01`, `a02`, `a05`
     ni `a06`.
   - **T2** exige además **P9**: `a09` cita el texto de las licencias, y F00–F02 citan los libros
     base.""",
"""   - **T1** exige además **P8** (la verificación de laboratorio) y **P11** (lo verificado,
     trasladado): sin digests, sin RAM medida y sin perfiles calibrados no hay `a01`, `a02`, `a05`
     ni `a06`. ✅ desde el 11/10/2026.
   - **T2** exige además **P9**: `a09` cita el texto de las licencias, y F00–F02 citan los libros
     base. ✅ desde el 11/10/2026."""),
("""| **P8** | Verificación de laboratorio: imágenes, digests, RAM, emulación, drivers, perfiles de volumen | — | densa | ⬜ |
| **P9** | Fuentes base: edición y año de los seis libros de la guía §11; texto de las licencias para `a09` | — | — | ⬜ |""",
"""| **P8** | Verificación de laboratorio: imágenes, digests, RAM, emulación, drivers, perfiles de volumen | 1 | densa | ✅ |
| **P9** | Fuentes base: edición y año de los seis libros de la guía §11; texto de las licencias para `a09` | — | — | ✅ |"""),
("""| **P11** | Traslado de lo verificado en P8 y P9 (versiones, perfiles, driver, ediciones) | — | — | ⬜ |""",
 """| **P11** | Traslado de lo verificado en P8 y P9 (versiones, perfiles, driver, ediciones) | — | — | ✅ |"""),
("""💀☕ boss del puente (Java 21 y Artemis) | 1 | densa | ⬜ |""", """💀☕ boss del puente (Java 25 y Apache Artemis) | 1 | densa | ⬜ |"""),
("""> 🚦 **Dónde está la producción (07/10/2026).** La preparación está cerrada salvo P8 (verificación de
> laboratorio), P9 (fuentes base) y P11 (su traslado); T0 puede empezar ya, T1 espera a P8 y P11, y T2
> a P9. Ninguna decisión espera revisión de Oskar.""",
"""> 🚦 **Dónde está la producción (11/10/2026).** **La preparación está cerrada: P1–P12 ✅.** P8, P9 y
> P11 se hicieron el 11/10/2026 (`verificacion-de-laboratorio/hallazgos.md`), con cuatro decisiones
> nuevas de Oskar (D19–D22). Ninguna tanda de escritura espera nada: sigue **T0**, y después T1 y T2.
> Ninguna decisión espera revisión de Oskar."""),
("""más los 13 documentos de `prompts/` que
existen durante la producción (2 de ellos desechables)""",
"""más los 14 documentos de `prompts/` que
existen durante la producción (2 de ellos desechables, y `verificacion-de-laboratorio/hallazgos.md`)"""),
("""**Terminada cuando** todas tienen un hallazgo con fecha, y lo que no funciona tiene alternativa
decidida. Solo macOS arm64 es obligatorio; Linux y WSL2 quedan como pendiente transversal, igual que
en la Lite.""",
"""**Terminada cuando** todas tienen un hallazgo con fecha, y lo que no funciona tiene alternativa
decidida. Solo macOS arm64 es obligatorio; Linux y WSL2 quedan como pendiente transversal, igual que
en la Lite.

✅ **Hecha el 11/10/2026**, en `zz-code/ruta-sql-20261011-2b0e/`: trece hallazgos (H1–H13). Lo que no
funcionó tiene su alternativa: MongoDB 9 no arranca (8.0.20, como la Lite), SQL Server no arranca en
Podman (el track exige Docker Desktop en Apple Silicon), `pg_hint_plan` no viene en la imagen
(ejercicio 🔥 con imagen derivada)."""),
("""resultados, con enlace y fecha, para `a09`.
""",
"""resultados, con enlace y fecha, para `a09`.

✅ **Hecha el 11/10/2026** (`hallazgos.md` §F1 y §F2). Lo que cambió: Kleppmann tiene segunda edición
con Riccomini (2026), el de Kyte es la cuarta, de Kuhn y Kyte (21c), y **los *Free Use Terms* de Oracle
Free no tienen cláusula DeWitt**: Oskar decidió mantener la regla igual (D20).
"""),
("""ningún documento de `prompts/` dice "a verificar" sobre algo que P8 o P9 ya verificaron, y §4 sale
limpia sobre `prompts/`.""",
"""ningún documento de `prompts/` dice "a verificar" sobre algo que P8 o P9 ya verificaron, y §4 sale
limpia sobre `prompts/`.

✅ **Hecha el 11/10/2026**: alcance (§4, §6.1, §7.1, §8, §9, §12), guía (§6.1, §10.1, §11, §12, §18 y
§19), las dos propuestas (con D19–D22 en el registro), el contrato (§2, §4, §5 y §8 con los perfiles),
los tres archivos de prompts y el README de `prompts/`. Los versiones y los digests no se copiaron a
ningún documento: viven en `hallazgos.md` hasta que `a02` los fije (D12)."""),
("""`puente` (Artemis
y el servicio Java 21 del boss del puente). Los dos se verifican antes de escribir.""",
"""`puente` (Apache Artemis
y el servicio Java 25 del boss del puente). Los dos se verifican antes de escribir; P8 ya dejó sus
arreglos (`hallazgos.md` §H8 y §H9)."""),
("""- [ ] P8 · Versiones según D12, con fecha
- [ ] P8 · Imágenes y digests de los siete servicios, con memoria medida
- [ ] P8 · Oracle Free en arm64 y SQL Server con Rosetta (Docker y Podman)
- [ ] P8 · Tabla de RAM en 16 GB
- [ ] P8 · Drivers de Python y elección del de MySQL
- [ ] P8 · Prototipo del generador: suciedad, verdad y perfiles S y M
- [ ] P8 · Funciones de Postgres que las fases dan por supuestas
- [ ] P9 · Edición y año de los seis libros base
- [ ] P9 · Texto de las licencias de Oracle Free y SQL Server sobre divulgación de resultados""",
"""- [x] P8 · Versiones según D12, con fecha
- [x] P8 · Imágenes y digests de los siete servicios, con memoria medida
- [x] P8 · Oracle Free en arm64 y SQL Server con Rosetta (Docker y Podman)
- [x] P8 · Tabla de RAM en 16 GB
- [x] P8 · Drivers de Python y elección del de MySQL
- [x] P8 · Prototipo del generador: suciedad, verdad y perfiles S y M
- [x] P8 · Funciones de Postgres que las fases dan por supuestas
- [x] P9 · Edición y año de los seis libros base
- [x] P9 · Texto de las licencias de Oracle Free y SQL Server sobre divulgación de resultados"""),
("""- [ ] P11 · Lo verificado en P8 y P9 trasladado; nada "a verificar" que ya esté verificado; los ⏳
      del contrato de nombres que dependen de P8, fijados""",
"""- [x] P11 · Lo verificado en P8 y P9 trasladado; nada "a verificar" que ya esté verificado; los ⏳
      del contrato de nombres que dependen de P8, fijados
- [x] P8–P11 · D19–D22 cerradas por Oskar y registradas en la propuesta de fases §12"""),
("""- [ ] Perfiles `api` (PostgREST) y `puente` (Artemis y Java 21) del compose verificados""",
 """- [ ] Perfiles `api` (PostgREST) y `puente` (Apache Artemis y Java 25) del compose verificados"""),
("""| `zz-code/ruta-sql-20261006-fc2f/` | diseño (29/09/2026), mudado en P12 |""",
 """| `zz-code/ruta-sql-20261011-2b0e/` | P8, P9 y P11 (11/10/2026) | versiones, digests, arranque y RAM de los ocho servicios, Oracle en arm64, SQL Server en Docker Desktop y en Podman, drivers, funciones de los tres motores, el prototipo del generador con la carga de M, Java 25, las URL y las licencias de P9 | vigente hasta T1 (`compose.yaml` y generador de partida) | sí | sí (`salidas/`, 1,1 GB, con la caja) |
| `zz-code/ruta-sql-20261006-fc2f/` | diseño (29/09/2026), mudado en P12 |"""),
]
