PAIRS = [
("""> las dos propuestas; lo que depende de la verificación de laboratorio (P8) queda ⏳ y lo fija P11.""",
 """> las dos propuestas; lo que dependía de la verificación de laboratorio (P8) lo fijó P11 el
> 11/10/2026 (§8), y lo que queda ⏳ lo fija T1."""),
("""> **Vigencia:** 2026-10-06.""", """> **Vigencia:** 2026-10-11."""),
("""Java 21 solo en el boss del puente y en `a10` | alcance §9, D11 |""",
 """Java 25 solo en el boss del puente y en `a10` | alcance §9, D11, D19 |"""),
("""| `puente` | ActiveMQ Artemis y el servicio Java 21 | el boss del puente | F23 |""",
 """| `puente` | Apache Artemis y el servicio Java 25 | el boss del puente | F23 |"""),
("""Servicios, volúmenes, puertos y digests: ⏳ T1 (`a02`), con la tabla de RAM medida en P8.""",
 """Servicios: `postgres`, `mysql`, `oracle`, `mongo`, `api`, `broker`, `bridge` y `sqlserver` (guía §12),
los mismos que usó la verificación de laboratorio. Volúmenes, puertos y digests: ⏳ T1 (`a02`), con
la tabla de RAM que midió P8 (`verificacion-de-laboratorio/hallazgos.md`)."""),
("""- **Perfiles de volumen:** S, M y L (D4); los conteos, ⏳ P8 → `a05`.""",
 """- **Perfiles de volumen:** S, M y L (D4), con la semilla `1979`; los conteos, en §8 (P11). `a05` los
  confirma en T1 y, si su generador cambia, los reescribe aquí."""),
("""Cada tanda que fije un nombre nuevo (el proyecto de Compose, los puertos, el esquema del modelo, la
cola del puente) agrega aquí su subsección **al cerrarse**, con fecha y tanda, y quita su ⏳ de arriba.
""",
"""Cada tanda que fije un nombre nuevo (el proyecto de Compose, los puertos, el esquema del modelo, la
cola del puente) agrega aquí su subsección **al cerrarse**, con fecha y tanda, y quita su ⏳ de arriba.

### P11 · 11/10/2026 · Perfiles de volumen y semilla

Calibrados con el prototipo del generador en la verificación de laboratorio (`hallazgos.md` §H12).
M entra en 16 GB con los tres motores arriba, así que no se achicó.

| Perfil | Personas | Filas de `Pacientes` | `Protocolos` | `ResultadoItem` | Uso |
|---|---|---|---|---|---|
| `s` | ≈ 20.700 | ≈ 25.200 | ≈ 142.000 | ≈ 1,7 M | por defecto en `lab load` |
| `m` | ≈ 208.000 | ≈ 252.000 | ≈ 1,43 M | ≈ 16,8 M | las mediciones publicadas |
| `l` | ≈ 1 M | ≈ 1,2 M | ≈ 7 M | ≈ 84 M | opcional, nunca por defecto |

- **Semilla por defecto:** `1979`, el año en que Alameda abre (historia §1). Misma semilla, mismos
  bytes: se comprueba por SHA-256 sobre todos los archivos generados.
- **La verdad**, en el prototipo: `truth/patient_person.csv` y `truth/result_value.csv`. El nombre del
  esquema donde se carga (`truth`, propuesto) sigue ⏳ hasta `a05`.
"""),
]
