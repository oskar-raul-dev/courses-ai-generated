# ✅ Soluciones — Apéndice a09: Licencias, publicación y riesgo

> **Curso:** Ruta SQL · Solucionario del [Apéndice a09](../a09-licencias-publicacion-y-riesgo.md)
> **Ejercicios:** 5 · **Perfil:** no aplica · **Motores:** ninguno; textos de licencia consultados el
> 12/10/2026
> **Fecha de verificación ejecutada:** 12/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

> ⚖️ Como el apéndice, este solucionario no es asesoramiento legal.

---

## 🟢 Fácil (1–2)

### Ejercicio 1

**Enunciado (resumen):** buscar `benchmark` en la licencia de SQL Server 2025 y en los *Free Use
Terms* de Oracle, con la fecha de cada texto.

**Solución.** Con el PDF de SQL Server descargado y `pdftotext` (de Poppler), y la página de Oracle
pasada a texto:

```bash
pdftotext -layout SQL_Server_2025_Developer_Express_and_Evaluation_Edition_English.pdf - | grep -n -A1 "BENCHMARK"
curl -sSL https://www.oracle.com/downloads/licenses/oracle-free-license.html | sed 's/<[^>]*>/ /g' \
  | grep -o -i "benchmark\|Last updated: [0-9]* [A-Za-z]* [0-9]*" | sort | uniq -c
```

```text
142:5. BENCHMARK TESTING. You must obtain Microsoft's prior written approval to disclose to a third
143-   party the results of any benchmark test of the software.
   1 Last updated: 9 June 2021
```

En SQL Server, la cláusula es la **sección 5**, y el PDF está fechado el 05/12/2025 (lo dice su
`CreationDate`). En los *Free Use Terms*, `benchmark` no aparece ni una vez; lo único que encuentra el
`grep` es la fecha del texto, el 9 de junio de 2021.

[← Volver al ejercicio](../a09-licencias-publicacion-y-riesgo.md#-ejercicio-1--la-cláusula-en-su-fuente)

### Ejercicio 2

**Enunciado (resumen):** clasificar seis salidas como publicables o no.

**Solución.**

| Salida | ¿Se publica? | Por qué |
|---|---|---|
| Tiempo de arranque del contenedor de Oracle | sí | dimensionamiento del laboratorio: dice si entra en tu máquina |
| Estructura del plan con `TABLE ACCESS FULL` | sí | operaciones y orden, de `EXPLAIN PLAN` sin ejecutar |
| `consistent gets` de esa consulta | **no** | es una estadística de ejecución, un resultado del motor |
| Mensaje de `ORA-03113` | sí | un error dice qué pasó, no cuánto costó |
| Tiempo de `lab load` en Oracle | **no** | es el motor bajo una carga; por eso `lab load` lo esconde |
| Lecturas de un plan de MySQL | sí | la GPL no restringe publicar resultados |

> ⚠️ **Error típico:** marcar el arranque de Oracle como no publicable. La regla tiene una sola
> excepción, el dimensionamiento del laboratorio, y es justo esa.

[← Volver al ejercicio](../a09-licencias-publicacion-y-riesgo.md#-ejercicio-2--se-publica-o-no)

## 🟡 Intermedio (3–4)

### Ejercicio 3

**Enunciado (resumen):** reescribir "Oracle lee el doble de bloques que Postgres" como apuesta sin
resolver.

**Solución.** Un ejemplo, para la consulta que mide [`a04`](../a04-el-arnes-de-forma.md):

```markdown
> 🪞🔒 **Apuesta sin resolver: Oracle.** Hipótesis: para contar las filas de `legacy."Pacientes"`
> cuyo `Nombre` contiene `DNI`, Oracle hace un `TABLE ACCESS FULL` y lee del orden de bloques que
> Postgres (4.160 en M), porque ninguno de los dos tiene un índice que sirva para `LIKE '%DNI%'`.
> Condiciones: perfil M, la tabla cargada con `uv run lab load --profile m --engine oracle --tables
> Pacientes` y estadísticas recogidas.
> Resuélvela: `uv run lab measure --engine oracle --profile m --private -c "SELECT count(*) FROM
> legacy.\"Pacientes\" WHERE \"Nombre\" LIKE '%DNI%'"`, y mira `Buffers` en la fila del `TABLE ACCESS
> FULL`.
> El mecanismo, en la documentación oficial: el recorrido completo de tabla, en la *SQL Tuning Guide*
> de Oracle.
> 📝 No publicamos el resultado: el curso no publica números de Oracle (`a09`).
```

El número de Postgres sí puede ir en la hipótesis: es publicable y sirve de referencia. Lo que se va
es el de Oracle, y la comparación pasa a ser una pregunta que resuelve el lector.

**Rúbrica.** Una respuesta correcta tiene que:
- tener hipótesis, condiciones, comando y documentación, en ese orden;
- usar `--private` en el comando, para que el número quede en la terminal del lector;
- no contener ningún número de Oracle, ni siquiera aproximado ("el doble").

Y queda invalidada si:
- conserva la proporción medida ("lee el doble") en el texto publicado.

[← Volver al ejercicio](../a09-licencias-publicacion-y-riesgo.md#-ejercicio-3--la-apuesta-sin-resolver)

### Ejercicio 4

**Enunciado (resumen):** tres preguntas para el área legal antes de publicar una comparación entre el
Oracle de producción y Postgres, y qué documento mirar.

**Solución.** Un juego razonable:

1. ¿Nuestro contrato con Oracle (el OMA, el OLSA o el que tengamos) restringe divulgar resultados de
   *benchmarks* a terceros, y qué cuenta como tercero (un blog, una charla, un proveedor)?
2. ¿La restricción cubre una medición hecha en otra instancia (un Oracle Free en una laptop) si el
   texto habla de "los Programas"?
3. Si se puede pedir permiso, ¿quién lo pide y a quién, y cuánto tarda?

**El documento es el contrato de la empresa**, no los *Free Use Terms*: estos rigen Oracle Free, que no
es lo que corre en producción, y no dicen nada sobre el contrato que sí se firmó. Por eso el curso no
publica números de Free aunque su texto lo permita.

[← Volver al ejercicio](../a09-licencias-publicacion-y-riesgo.md#-ejercicio-4--tu-contrato)

## 🟠 Difícil (5)

### Ejercicio 5

**Enunciado (resumen):** un plan a cinco años para el MySQL 5.7 del portal, con tres opciones.

**Solución de referencia.**

- **MySQL 9.7 LTS.** Soporte *premier* hasta el 30/04/2031 y extendido hasta el 30/04/2034: cubre
  los cinco años. El salto desde 5.7 pasa por 8.0 y 8.4, con cambios de autenticación, de
  intercalación por defecto (`utf8mb4_0900_ai_ci`, que en el ejercicio 3 de [`a05`](../a05-la-caja-y-el-generador.md)
  hace que `Ñ` sea `N`) y de palabras reservadas. Riesgo: el de gobierno de MySQL desde septiembre de
  2025, que hoy no cambia el soporte de 9.7 pero sí la incertidumbre sobre lo que viene después.
- **Percona Server.** Compatible con MySQL y mantenido por otra empresa. Reduce la dependencia de un
  solo fabricante. Riesgo: depende de que Percona siga siguiendo el código de Oracle, y la carta de
  febrero de 2026 muestra que también le preocupa.
- **Postgres.** El portal pasa a leer de la base nueva que el curso construye, y el MySQL se apaga. Es
  la opción que elimina un motor del inventario de Alameda. Riesgo: es la más cara en el corto plazo y
  depende de que el modelo nuevo exista, que es el trabajo del Bloque V.

**Elegiría** pasar ya a 9.7 LTS para salir de un motor sin soporte desde 2023, y planificar el cierre del
portal sobre Postgres cuando la API del modelo nuevo esté lista. El 5.7 es el riesgo de hoy; el de 2027
se gestiona con un plan B escrito.

**Rúbrica.** Una respuesta correcta tiene que:
- partir de que 5.7 está **fuera de soporte desde el 31/10/2023**, que es el riesgo concreto;
- dar una fecha o una fuente para el riesgo de cada opción;
- separar "el motor funciona" de "quién lo mantiene".

Y queda invalidada si:
- descarta MySQL "porque Oracle lo va a matar", sin fecha ni fuente;
- propone quedarse en 5.7 sin decir cómo se cubren los parches de seguridad.

[← Volver al ejercicio](../a09-licencias-publicacion-y-riesgo.md#-ejercicio-5--el-plan-de-salida-del-portal)
