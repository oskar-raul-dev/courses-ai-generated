PAIRS = [
("""> **Estado de las decisiones:** todas cerradas por Oskar el 30/09/2026 (§12). Su registro vive en
> [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) §12. Lo que depende de la
> verificación de laboratorio (versiones, digests y conteos de los perfiles) se fija en `a02` y
> `a05` cuando esa verificación esté hecha.""",
"""> **Estado de las decisiones:** todas cerradas por Oskar el 30/09/2026 (§12), más D19–D22, que
> cerró el 11/10/2026 al verificar el laboratorio. Su registro vive en
> [`propuesta-fases-y-alcance.md`](propuesta-fases-y-alcance.md) §12. Lo verificado en el
> laboratorio (versiones, digests, memoria y conteos de los perfiles) está en
> [`verificacion-de-laboratorio/hallazgos.md`](verificacion-de-laboratorio/hallazgos.md) desde el
> 11/10/2026, y lo fijan `a02` y `a05` en T1."""),
("""**Requisitos de entrada:** Docker o Podman funcionando, **16 GB de RAM** (Oracle Free no entra en
menos junto a los otros dos motores; el número exacto sale de la verificación de laboratorio), y
soltura leyendo Python. Java 21 aparece solo""",
"""**Requisitos de entrada:** Docker o Podman funcionando, **16 GB de RAM** (medido el 11/10/2026: con
M cargado y todos los perfiles arriba, el laboratorio pide unos 5,3 GiB en su pico, y entra en la VM
de 8 GB que Docker Desktop da por defecto en un Mac de 16 GB), y soltura leyendo Python. El track de
SQL Server, en Apple Silicon, exige Docker Desktop (§8). Java 25 aparece solo"""),
("""**Las licencias de Oracle y de SQL Server prohíben divulgar resultados de benchmark sin permiso
del fabricante** (la llamada cláusula DeWitt). Ejecutarlos en privado está permitido; publicarlos
no. Eso convierte""",
"""**La licencia de SQL Server prohíbe divulgar resultados de benchmark sin permiso del fabricante**
(la llamada cláusula DeWitt), también la de Developer, y **los contratos de empresa de Oracle
Database (OMA, OLSA) llevan la misma cláusula**: son los que corre el lector en su trabajo. Oracle AI
Database Free, la del laboratorio, se licencia con los *Free Use Terms*, que no la tienen (comprobado
el 11/10/2026), y **el curso igual no publica sus números** (D20): un número medido en Free invita a
extrapolarlo a la edición que el lector sí tiene bajo cláusula. Ejecutarlos en privado está
permitido; publicarlos, no. `a09` cita los dos textos. Eso convierte"""),
("""El perfil M apunta a unos 200.000 pacientes y unos
15 millones de filas de resultados, con una condición que manda sobre el número: **M tiene que
entrar en 16 GB con los tres motores arriba**. Si en la verificación de laboratorio no entra, se
achica M; no se sube el requisito de memoria. Los conteos finales se fijan en `a05`.""",
"""El perfil M, calibrado en la verificación de laboratorio,
tiene unos 250.000 pacientes (208.000 personas) y unos 17 millones de filas de resultados, con una
condición que manda sobre el número: **M tiene que entrar en 16 GB con los tres motores arriba**.
Entró con margen; si un cambio posterior lo rompe, se achica M y no se sube el requisito de memoria.
Los conteos finales se fijan en `a05`."""),
("""| 🐬 **MySQL** (8.4 LTS) |""", """| 🐬 **MySQL** (9.7 LTS) |"""),
("""**Ninguna versión de esta tabla está verificada.** Las versiones y los digests se fijan
ejecutando, en la verificación de laboratorio (tanda P8), y quedan escritos en `a02` con su fecha.
Hasta entonces ningún documento del curso publica un número de versión. Dos riesgos declarados:
que la imagen de Oracle Free funcione en arm64 sin emulación, y que la de SQL Server arranque con
Rosetta en Docker Desktop **y** en Podman.""",
"""**Las versiones se verificaron ejecutando el 11/10/2026** (tanda P8, en
[`hallazgos.md`](verificacion-de-laboratorio/hallazgos.md)) y las fija `a02` por digest, con su fecha;
ningún otro documento del curso publica un número de versión. De los dos riesgos declarados, uno no
se materializó: **Oracle Free corre nativo en arm64**. El otro, a medias: SQL Server arranca con
Rosetta en Docker Desktop, pero **no en Podman**, ni con QEMU ni con Rosetta, así que en Apple
Silicon el track exige Docker Desktop. Y uno nuevo: MongoDB queda fijado en 8.0.20, como en la NoSQL
Lite, porque las versiones posteriores no arrancan con el kernel de Docker Desktop."""),
("""- **Java 21 solo donde la narrativa lo pide**""", """- **Java 25 solo donde la narrativa lo pide**"""),
("""  con ActiveMQ Artemis y mensajes que imitan HL7 v2)""", """  con Apache Artemis y mensajes que imitan HL7 v2)"""),
("""9. **Stack: SQL + Python con `uv`**; Java 21 solo""", """9. **Stack: SQL + Python con `uv`**; Java 25 solo"""),
("""23. **D11 · Java 21 LTS**, solo en el boss del puente y en `a10`.""",
 """23. **D11 · Java LTS**, solo en el boss del puente y en `a10`: Java 25 desde el 11/10/2026 (D19)."""),
("""    opcional y el punto de rotura de las fases de plan como precipicio del plan, con la línea que
    cambió.
""",
"""    opcional y el punto de rotura de las fases de plan como precipicio del plan, con la línea que
    cambió.
27. **D19 a D22, cerradas el 11/10/2026 al verificar el laboratorio y las licencias:** Java 25 LTS en
    lugar de 21 (D19); ningún número de Oracle se publica aunque Oracle Free no lleve la cláusula
    DeWitt (D20, §6.1); la imagen de Oracle es la de gvenzl en su variante `slim-faststart` (D21); el
    driver de MySQL para Python es PyMySQL (D22).
"""),
("""la interfaz con el SIH en Java 21 y ActiveMQ Artemis""", """la interfaz con el SIH en Java 25 y Apache Artemis"""),
]
