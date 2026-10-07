# 🧪 ruta-sql-20261006-fc2f · cómo correr estas pruebas

> **Curso:** ruta-sql · **Tanda:** revisión contra `zz-instrucciones/` · **Creado:** 2026-10-06
> **Propósito:** PoC del `.accdb` de museo, mudado desde `taller/accdb-museo/`; lo extrae `a10` en T14.
> **En esta sesión no se ejecutó nada:** solo se movió el directorio. Las instrucciones de corrida
> vienen del `README.md` original del PoC (`accdb-museo/README.md`), escrito en la sesión del
> 29/09/2026 que lo corrió, y aquí se ordenan con las diez secciones de `zz-code/README.md`.

## 1. 🎯 Qué se prueba y para qué

- **Que se puede generar un `.accdb` real sin Access ni Office**, con la tabla `pacientes` como la
  cargaba la recepción de Alameda en 1998 (datos sucios con semilla 1997) → apéndice
  `a10-el-access-de-museo.md` (decisión D15 del curso).
- **Que el parser de Rubén (`ModParser.bas`, VBA de 1998) corre tal cual en LibreOffice Basic** y se
  comporta distinto según la configuración regional → la anécdota del parser de la historia
  (`00-historia-de-alameda.md` §3.2) y `a10`.
- **Que un port fiel a Python (`parse_patients.py`) reproduce sus defectos** y es la referencia de
  comportamiento.

## 2. 🛠️ Prerrequisitos

Java 17 o superior, Maven, Python 3.10 o superior y, para el `.bas`, LibreOffice con `soffice` en el
`PATH`. Opcional para mirar el archivo: DBeaver con UCanAccess, o `mdbtools`. Versiones que usó la
corrida del 29/09/2026: Jackcess 4.0.10 (y 5.1.0, que trae UCanAccess), UCanAccess 5.1.3 y HSQLDB
2.7.4 (`pom.xml`). No usa Docker.

## 3. 🧭 Reglas antes de correr

No toca Docker ni la configuración de la máquina. `run_bas_tests.py` usa un perfil de LibreOffice
aislado en `accdb-museo/out/lo-profile`, así que la configuración del autor no cambia. Todo lo que
escribe va a `accdb-museo/out/`.

## 4. ▶️ Cómo se corre

Desde `accdb-museo/`:

```bash
mvn -q dependency:copy-dependencies -DoutputDirectory=lib
mkdir -p out

java -cp "lib/*" AccdbTool.java generate out/alameda_1998.accdb
java -cp "lib/*" AccdbTool.java export   out/alameda_1998.accdb out/pacientes.csv

python3 parse_patients.py out/pacientes.csv out/pacientes_parseado.csv

cp out/alameda_1998.accdb out/alameda_1998_parseado.accdb
java -cp "lib/*" AccdbTool.java apply    out/alameda_1998_parseado.accdb out/pacientes_parseado.csv

java -cp "lib/*" QueryAccdb.java demo  out/alameda_1998.accdb
java -cp "lib/*" QueryAccdb.java query out/alameda_1998.accdb "SELECT COUNT(*) FROM pacientes WHERE dni IS NULL"

python3 run_bas_tests.py                 # es-AR, años 1930-2029: la PC de la recepción en 1998
python3 run_bas_tests.py en-US           # el mismo código con configuración regional de EE. UU.
python3 run_bas_tests.py es-AR default   # la ventana de años propia de LibreOffice
```

## 5. 📏 Cómo se mide

No hay medición de rendimiento: la prueba es de comportamiento. `TestParser.bas` tiene 40 aserciones
sobre `ParsearNombre` y `ExtraerDNI`, con los valores esperados sacados de `parse_patients.py`, y la
cifra es cuántas pasan en cada configuración.

## 6. 🧮 Los intermedios que amasan la salida

`run_bas_tests.py` escribe el resultado en `out/bas_tests.txt` (en LibreOffice, `Print` abre un
diálogo, por eso va a archivo); la cuenta "N de 40" sale de esa salida tal cual. La demo de
`QueryAccdb.java` imprime directo a la terminal.

## 7. ✅ Qué se espera ver

Resultados del 29/09/2026, en el `README.md` original:

| Corrida | Resultado |
|---|---|
| `es-AR`, años desde 1930 | 40 de 40 |
| `en-US` | 31 de 40 (`15/03/62` deja de ser fecha; `12/11/27` sale como `11/12/2027`) |
| `es-AR`, ventana por defecto de LibreOffice | 39 de 40 (`23/05/35` sale como 2035) |

## 8. 📂 Salidas

`accdb-museo/out/`: `alameda_1998.accdb`, `alameda_1998_parseado.accdb`, `pacientes.csv`,
`pacientes_parseado.csv`, `verificacion.csv`, `bas_tests.txt` y `lo-profile/`. Se regeneran con §4.
Nada se copió todavía al curso.

## 9. 🧹 Limpieza

Nada que limpiar fuera del directorio. Para liberar espacio: `python3 zz-code/limpiar.py` (vista
previa) muestra `out/` y `__pycache__/`; `lib/` se borra a mano y se rehace con Maven.

## 9 ter. ✅ La prueba del verificador de solucionarios

`prueba-verificador.sh` arma en `salidas/prueba-verificador/` un curso falso con una F03 de 22
ejercicios y corre `prompts/verificar-corpus.py` tres veces: sin solucionario (`SOLUCIONARIO` y los
22 enlaces `ROTO`), con 21 soluciones (`SOLUCIONARIO` y un `ANCLA`) y completo (nada del curso). Se
corrió el 06/10/2026 con ese resultado; también confirma que el ancla de vuelta al ejercicio es
`#-ejercicio-N--<título>`. Los `ROTO` de `prompts/propuesta-fases-y-alcance.md` vienen de copiar solo
parte de `prompts/` y se filtran.

## 9 bis. 📝 El script de la historia

`historia-alineada.py` no es una prueba: es el registro de los reemplazos literales que alinearon
`00-historia-de-alameda.md` el 06/10/2026. Se corrió una vez, desde la raíz del repositorio, con
`python3 zz-code/ruta-sql-20261006-fc2f/historia-alineada.py cursos-bd/ruta-sql`, y después se
corrigió a mano una frase de la §9 (el Access de Rubén, no el `.accdb` de turnos, es lo que vuelve en
`a10`). Volver a correrlo falla en la primera aserción, que es lo esperado.

## 10. 🚫 Qué se dejó fuera

Nada. Los `.jar` de `lib/` siguen aquí porque en `taller/` estaban versionados; se regeneran con
`mvn -q dependency:copy-dependencies -DoutputDirectory=lib`. Límites conocidos del PoC (VBA que no
vive dentro del `.accdb`, `InStr()` de UCanAccess, `CREATE FUNCTION` con HSQLDB 2.7.4): en
`accdb-museo/README.md`, § "Límites conocidos".
