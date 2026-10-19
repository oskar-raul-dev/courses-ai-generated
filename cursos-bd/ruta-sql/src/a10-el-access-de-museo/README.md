# 🏛️ El Access de museo

El `.accdb` de Rubén **sin Access ni Office**: la tabla `pacientes` como la cargaba la recepción entre 1997 y
2005, generada con Jackcess, consultada con UCanAccess y con mdbtools, y "el parser" de 1998 corrido tal cual en
LibreOffice Basic. Lo explica el apéndice opcional [`a10`](../../a10-el-access-de-museo.md), con sus seis
ejercicios. **Nadie lo necesita para hacer el curso**: el insumo oficial es la caja en CSV.

---

## 🗂️ Qué hay

| Archivo | Qué es |
|---|---|
| `AccdbTool.java` | crea el `.accdb` con 120 pacientes sucios (semilla 1997), lo exporta a CSV y escribe de vuelta lo parseado |
| `QueryAccdb.java` | SQL sobre el `.accdb` con UCanAccess: una demo en cuatro partes y cualquier consulta |
| `ModParser.bas` | el parser de Rubén, en VBA, como texto |
| `parse_patients.py` | el port fiel del VBA a Python, con sus defectos, y el chequeo que Rubén nunca tuvo |
| `TestParser.bas`, `run_bas_tests.py` | 40 aserciones sobre el `.bas` original, en LibreOffice Basic sin interfaz |
| `Dockerfile.libreoffice` | la imagen con LibreOffice 25.2, Python 3.13 y mdbtools, sobre Debian trixie fijado por digest |
| `pom.xml` | solo baja Jackcess y UCanAccess a `lib/` |

`lib/` y `out/` no se versionan: se rehacen con los comandos de abajo.

---

## ▶️ Cómo se corre

Todo en contenedores, desde esta carpeta. Java corre en la imagen de Maven que fija
[`a02`](../../a02-compose-de-la-ruta.md#-las-versiones-del-curso); lo demás, en la del museo:

```bash
docker build -t ruta-sql-libreoffice:a10 --label curso=ruta-sql -f Dockerfile.libreoffice .
MVN=maven@sha256:a291659c5ffddf142e5174df5bfc3f3dcb48706e44868f341ef7914b39a254c9
LO=ruta-sql-libreoffice:a10
r() { docker run --rm --label curso=ruta-sql -v "$PWD":/w -w /w "$@"; }

r $MVN mvn -q dependency:copy-dependencies -DoutputDirectory=lib
mkdir -p out
r $MVN java -cp "lib/*" AccdbTool.java generate out/alameda_1998.accdb
r $MVN java -cp "lib/*" AccdbTool.java export   out/alameda_1998.accdb out/pacientes.csv
r $LO  python3 parse_patients.py out/pacientes.csv out/pacientes_parseado.csv
cp out/alameda_1998.accdb out/alameda_1998_parseado.accdb
r $MVN java -cp "lib/*" AccdbTool.java apply    out/alameda_1998_parseado.accdb out/pacientes_parseado.csv

r $MVN java -cp "lib/*" QueryAccdb.java demo  out/alameda_1998.accdb
r $LO  mdb-export out/alameda_1998.accdb pacientes

r $LO python3 run_bas_tests.py                 # es-AR, años desde 1930: la PC de la recepción en 1998
r $LO python3 run_bas_tests.py en-US           # el mismo código, configuración regional de EE. UU.
r $LO python3 run_bas_tests.py es-AR 1950      # otra ventana de años de dos cifras
```

---

## ✅ Lo que tiene que salir

Verificado el 18/10/2026:

- `120 pacientes, 59 separados por el parser, 17 sospechosos`, y `updated 59 rows`. Los dos CSV son idénticos
  byte a byte a los de la primera corrida, del 29/09/2026, y el de `mdb-export` es idéntico al de `AccdbTool`.
- Las pruebas del `.bas`: **40 de 40** en `es-AR` desde 1930, **31 de 40** en `en-US` y **39 de 40** con la
  ventana desde 1950. El parser dependía de la configuración regional de la PC donde corría.

> ⚠️ **`es-AR default` cambia con la versión de LibreOffice.** La ventana de dos cifras de fábrica es 1930 en
> LibreOffice 25.2.3 (el de la imagen) y 1950 en 26.2.1: el mismo comando da 40 o 39 de 40 según cuál corras.
> Por eso los comandos de arriba la fijan.

---

## ⚠️ Límites conocidos

- **El VBA no vive dentro del `.accdb`**: ni Jackcess ni UCanAccess escriben módulos ni consultas guardadas.
  Con Access en Windows, `ModParser.bas` se importa desde el editor de VBA.
- **Jackcess no crea campos multivalor ni adjuntos.**
- **UCanAccess no es Access**: el SQL corre sobre HSQLDB, e `InStr()` devuelve 0 en la 5.1.3. La demo usa
  `LOCATE()` y `SUBSTRING()`, y aplica el parser en Java sobre el resultado.
- **`mdb-sql` no sirve para consultar**: con `IS NULL` devuelve cero filas. mdbtools es para sacar los datos.
- **`ParsearPacientes` no se ejecuta en LibreOffice**, porque usa DAO; `ParsearNombre` y `ExtraerDNI`, sí.
- **`ModParser.bas` no se ejecutó nunca en Access real.** La referencia de comportamiento es el port de Python,
  y las 40 aserciones dicen dónde coinciden.
