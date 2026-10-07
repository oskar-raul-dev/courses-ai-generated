# 🏛️ El Access de Rubén — pieza de museo

Experimento de taller: generar un `.accdb` real **sin Access ni Office**, con la tabla `pacientes`
tal como la cargaba la recepción de Alameda, y correr "el parser" de Rubén sobre ella.

| Archivo | Qué es |
|---|---|
| `AccdbTool.java` | Crea el `.accdb` con Jackcess (datos sucios con semilla 1997), lo exporta a CSV y aplica cambios de vuelta |
| `ModParser.bas` | El parser original de Rubén en VBA (1998), como texto. Jackcess no puede escribir módulos VBA dentro del archivo |
| `QueryAccdb.java` | Hace SQL sobre el `.accdb` con UCanAccess (JDBC en Java puro) y muestra el parser por dentro |
| `parse_patients.py` | Port fiel del VBA a Python, con sus defectos incluidos, más el chequeo que Rubén nunca tuvo |
| `TestParser.bas` y `run_bas_tests.py` | Pruebas de caracterización del `.bas` original, ejecutadas en LibreOffice Basic sin interfaz |
| `pom.xml` | Solo sirve para bajar Jackcess y UCanAccess a `lib/` |

## ▶️ Cómo correrlo

Necesitas Java 17 o superior, Maven y Python 3.10 o superior.

```bash
mvn -q dependency:copy-dependencies -DoutputDirectory=lib
mkdir -p out

java -cp "lib/*" AccdbTool.java generate out/alameda_1998.accdb
java -cp "lib/*" AccdbTool.java export   out/alameda_1998.accdb out/pacientes.csv

python3 parse_patients.py out/pacientes.csv out/pacientes_parseado.csv

cp out/alameda_1998.accdb out/alameda_1998_parseado.accdb
java -cp "lib/*" AccdbTool.java apply    out/alameda_1998_parseado.accdb out/pacientes_parseado.csv
```

Para consultarlo con SQL, sin Access:

```bash
java -cp "lib/*" QueryAccdb.java demo  out/alameda_1998.accdb
java -cp "lib/*" QueryAccdb.java query out/alameda_1998.accdb "SELECT COUNT(*) FROM pacientes WHERE dni IS NULL"
```

La demo muestra cuatro cosas: lo que ve la recepción, el parser escrito en SQL puro, el parser de
Rubén aplicado sobre el resultado y los aciertos que no son el DNI de esa persona (pasaportes y
DNI de la madre).

Para abrir el `.accdb` con interfaz gráfica en Mac o Linux: DBeaver con el driver UCanAccess, o
`brew install mdbtools` y después `mdb-export out/alameda_1998.accdb pacientes`.

## ⚠️ Límites conocidos

- El "procedure" no vive dentro del `.accdb`: ni Jackcess ni UCanAccess escriben módulos VBA ni
  consultas guardadas. Con Access en Windows, `ModParser.bas` se importa desde el editor de VBA.
- Jackcess no crea campos multivalor ni de adjuntos.
- UCanAccess carga el archivo en un HSQLDB en memoria: el dialecto se parece al de Access pero no
  es Access. En la versión 5.1.3, `InStr()` devuelve 0 incluso con literales; `LOCATE()` y
  `SUBSTRING()` funcionan.
- UCanAccess promete registrar funciones Java llamables desde SQL (`addFunctions`), como se
  llamaría una función VBA desde una consulta de Access. Con HSQLDB 2.7.4 el `CREATE FUNCTION`
  falla aunque el método se resuelve bien por reflexión, y no se investigó más. Por eso la demo
  aplica el parser en Java sobre el resultado del SQL.
- UCanAccess trae su propio fork de Jackcess (`io.github.spannm.jackcess`). Convive con el Jackcess
  original de `AccdbTool` porque los paquetes son distintos.
- `ModParser.bas` no se ejecutó nunca en Access real. El port de Python sí se ejecutó y es la
  referencia de comportamiento.

## 🧪 Ejecutar `ModParser.bas` tal cual, con LibreOffice

Sin Access no hay forma de correr el VBA dentro del `.accdb`, pero el `.bas` sí corre en
**LibreOffice Basic** en modo headless, desde la terminal. `TestParser.bas` es un `Sub Main()`
con 40 aserciones sobre `ParsearNombre` y `ExtraerDNI`; los valores esperados salen de
`parse_patients.py`.

```bash
python3 run_bas_tests.py                 # es-AR, años 1930-2029: la PC de la recepción en 1998
python3 run_bas_tests.py en-US           # el mismo código con configuración regional de EE. UU.
python3 run_bas_tests.py es-AR default   # la ventana de años propia de LibreOffice
```

El script usa un perfil de LibreOffice aislado en `out/lo-profile` (no toca tu configuración) y
solo quita las dos líneas exclusivas de Access (`Attribute VB_Name`, `Option Compare Database`)
y agrega `Option VBASupport 1`. `ParsearPacientes` compila pero no se ejecuta, porque usa DAO.

Resultados verificados:

| Corrida | Resultado | Qué muestra |
|---|---|---|
| `es-AR`, años desde 1930 | 40 de 40 | el `.bas` de 1998 se comporta como en Access |
| `en-US` | 31 de 40 | `15/03/62` deja de ser fecha y cae en la dirección; `12/11/27` sale como `11/12/2027`. **El parser dependía de la configuración regional de la PC** |
| `es-AR`, ventana por defecto de LibreOffice | 39 de 40 | `23/05/35` sale como 2035: el mismo código, otro runtime, otro siglo |

La salida queda en `out/bas_tests.txt`, porque en LibreOffice `Print` abre un diálogo.
