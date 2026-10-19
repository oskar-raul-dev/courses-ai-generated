# ✅ Soluciones — Apéndice a05: La caja y el generador

> **Curso:** Ruta SQL · Solucionario del [Apéndice a05](../a05-la-caja-y-el-generador.md)
> **Ejercicios:** 6 · **Perfil:** S en el 1, M en los demás · **Motores:** Postgres y MySQL, los de
> [`a02`](../a02-compose-de-la-ruta.md#-las-versiones-del-curso)
> **Fecha de verificación ejecutada:** 12/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

---

## 🟢 Fácil (1–2)

### Ejercicio 1

**Enunciado (resumen):** generar S, comparar el hash con el publicado, borrar la caja, regenerarla y
comparar otra vez.

**Solución.** Desde `src/`:

```text
$ uv run lab generate --profile s
…
Listo en 17 s: 20002 personas, 24245 filas de Pacientes, 132065 protocolos, 1201086 filas de ResultadoItem.
SHA-256 de la caja: 49cfb8db41947b05ec06c81d0948fbe872f1d57d14d8ba9d293f46e687453fab
```

`rm -r lab/caja/s` y otra vez `uv run lab generate --profile s`: el mismo hash. En la verificación, S
se generó en macOS con Python 3.13.4 y en Linux con 3.13.13, y las dos corridas dieron ese hash; sus
`MANIFIESTO.json`, comparados entre sí, tienen el mismo SHA-256 (`c96d8911163fe925…`), así que también son
idénticos los 439 hashes por archivo que contienen.

> ⚠️ **Error típico:** comparar el tamaño de los archivos en lugar del hash. Un cambio de una coma
> por un punto en `ResultadoItem` no mueve el tamaño y sí cambia todo lo que se mide después.

[← Volver al ejercicio](../a05-la-caja-y-el-generador.md#-ejercicio-1--tu-caja-es-la-del-curso)

### Ejercicio 2

**Enunciado (resumen):** con M en Postgres, comparar `lab.loaded` y tres conteos con
`MANIFIESTO.json`.

**Solución.**

```sql
-- postgres
SELECT left(sha256, 12) AS caja,
       (SELECT count(*) FROM legacy."Pacientes")     AS pacientes,
       (SELECT count(*) FROM legacy."Protocolos")    AS protocolos,
       (SELECT count(*) FROM legacy."ResultadoItem") AS resultados
FROM lab.loaded;
```

```text
     caja     | pacientes | protocolos | resultados
--------------+-----------+------------+------------
 3e59292e9918 |    242427 |    1327622 |   12134453
(1 row)
```

Y del manifiesto, con `python3 -c "import json; m = json.load(open('lab/caja/m/MANIFIESTO.json'));
print(m['sha256']); print({k: m['rows'][k] for k in ('Pacientes', 'Protocolos', 'ResultadoItem')})"`:

```text
3e59292e9918ee259e44c49c928d0b024686019fe070cc9fdca40a97fb2dd465
{'Pacientes': 242427, 'Protocolos': 1327622, 'ResultadoItem': 12134453}
```

Coinciden los cuatro datos. `lab load` ya había hecho esta comprobación al cargar, y se habría detenido
si alguna tabla no coincidía; el ejercicio es para que sepas dónde mirar cuando dudes.

[← Volver al ejercicio](../a05-la-caja-y-el-generador.md#-ejercicio-2--lo-que-cargó-postgres-contra-lo-que-escribió-el-generador)

## 🟡 Intermedio (3–4)

### Ejercicio 3

**Enunciado (resumen):** contar los `Nombre` con `Ñ` en Postgres y en MySQL, y en MySQL también con
`LIKE BINARY`.

**Solución.**

```sql
-- postgres
SELECT count(*) AS con_enie FROM legacy."Pacientes" WHERE "Nombre" LIKE '%Ñ%';
```

```text
 con_enie
----------
    21559
(1 row)
```

```sql
-- mysql
SELECT sum(Nombre LIKE '%Ñ%') AS ai_ci, sum(Nombre LIKE BINARY '%Ñ%') AS binario FROM Pacientes;
```

```text
ai_ci	binario
163399	21559
```

La respuesta correcta a "cuántos nombres tienen una Ñ" es **21.559**. MySQL, con su intercalación de
fábrica, `utf8mb4_0900_ai_ci`, no distingue acentos ni la `Ñ` de la `N`, y devuelve 163.399: todas las
filas con una `N`. `LIKE BINARY` compara bytes y vuelve a 21.559.

**La recepcionista que busca `MUÑOZ`** no busca mal, y esa es la parte interesante:

```sql
-- mysql
SELECT sum(Nombre LIKE 'MUÑOZ %') AS ai_ci, sum(Nombre LIKE BINARY 'MUÑOZ %') AS binario,
       sum(Nombre LIKE BINARY 'MUNOZ %') AS sin_enie
FROM Pacientes;
```

```text
ai_ci	binario	sin_enie
3979	3823	156
```

La búsqueda de MySQL encuentra también los 156 `MUNOZ` que alguien cargó sin la eñe, y para encontrar
a una persona eso es una ventaja. Para contar, o para una restricción de unicidad, es un error. La
intercalación no es buena ni mala: es una decisión, y la de fábrica decide por ti.

[← Volver al ejercicio](../a05-la-caja-y-el-generador.md#-ejercicio-3--la-ñ-en-dos-motores)

### Ejercicio 4

**Enunciado (resumen):** contar `Edad` NULL y `''` en los dos motores, y explicarlo con dos filas del
CSV.

**Solución.**

```sql
-- postgres
SELECT count(*) FILTER (WHERE "Edad" IS NULL) AS nulos, count(*) FILTER (WHERE "Edad" = '') AS vacios
FROM legacy."Pacientes";
```

```text
 nulos | vacios
-------+--------
  1417 |   1481
(1 row)
```

```sql
-- mysql
SELECT sum(Edad IS NULL) AS nulos, sum(Edad = '') AS vacios FROM Pacientes;
```

```text
nulos	vacios
0	2898
```

Las dos filas del CSV que lo explican, la 64 y la 396 de M (`Pacientes.csv` está en Latin-1; se
muestran convertidas):

```text
64,"APAZA TICONA EZEQUIEL GONZALO","X3574392",,"","M","15-519962","SAN MARTIN 3847","PART.",,"C","1997-05-21 00:00:00.000"
396,"GOMEZ VERONICA",,,,"F","15-588995","AV. VELEZ SARSFIELD 1556","PAMI","589055570804/03","C","1998-05-22 00:00:00.000"
```

En la 64, `Edad` es `""`: un texto vacío. En la 396 es un campo vacío sin comillas: NULL. Postgres, con
`COPY … FORMAT csv`, respeta la diferencia. MySQL, con `LOAD DATA`, pone `''` en una columna de texto
para los dos casos, y las 1.417 filas NULL se suman a las vacías: 2.898.

**La consulta de MySQL que da un número equivocado** es cualquiera que pregunte por los NULL, como
"cuántos pacientes no tienen edad cargada" escrita con `IS NULL`: devuelve 0. La que cuenta "sin
edad" de verdad tiene que mirar los dos casos, y en MySQL ya no se pueden separar.

[← Volver al ejercicio](../a05-la-caja-y-el-generador.md#-ejercicio-4--null-contra-texto-vacío)

## 🟠 Difícil (5)

### Ejercicio 5

**Enunciado (resumen):** una expresión regular que extraiga el DNI después de `DNI`, `LC` o `LE`,
medida contra `truth.parser_case`, con predicción previa.

**Solución de referencia.**

```sql
-- postgres
WITH guess AS (
    SELECT p."IdPaciente" AS id,
           replace(substring(p."Nombre" FROM '\m(?:DNI|LC|LE)\s+([0-9.]+)'), '.', '') AS dni
    FROM legacy."Pacientes" AS p
)
SELECT count(*) FILTER (WHERE g.dni IS NOT NULL)                          AS extraidos,
       count(*) FILTER (WHERE g.dni = pc.expected_dni)                    AS correctos,
       count(*) FILTER (WHERE pc.expected_dni <> '')                      AS esperados,
       round(100.0 * count(*) FILTER (WHERE g.dni = pc.expected_dni)
             / count(*) FILTER (WHERE g.dni IS NOT NULL), 1)              AS precision_pct,
       round(100.0 * count(*) FILTER (WHERE g.dni = pc.expected_dni)
             / count(*) FILTER (WHERE pc.expected_dni <> ''), 1)          AS recall_pct
FROM guess AS g
LEFT JOIN truth.parser_case AS pc ON pc.legacy_patient_id = g.id;
```

```text
 extraidos | correctos | esperados | precision_pct | recall_pct
-----------+-----------+-----------+---------------+------------
     19358 |     18236 |     24985 |          94.2 |       73.0
(1 row)
```

Una predicción razonable era precisión alta y cobertura baja, porque la expresión es estricta: cuando
dispara, casi siempre acierta (94,2 %), pero solo encuentra el 73 % de los documentos escritos en
`Nombre`. Las que se le escapan:

```sql
-- postgres
SELECT p."Nombre", g.dni AS extraido, pc.expected_dni AS esperado
FROM legacy."Pacientes" AS p
JOIN truth.parser_case AS pc ON pc.legacy_patient_id = p."IdPaciente"
CROSS JOIN LATERAL (SELECT replace(substring(p."Nombre" FROM '\m(?:DNI|LC|LE)\s+([0-9.]+)'), '.', '') AS dni) AS g
WHERE pc.expected_dni <> '' AND g.dni IS DISTINCT FROM pc.expected_dni
ORDER BY p."IdPaciente"
LIMIT 8;
```

```text
                      Nombre                       | extraido | esperado
---------------------------------------------------+----------+----------
 RODRIGUEZ DE VERA ROSA DORA 7158422               |          | 7158422
 AGÜERO CEBALLOS GRACIELA CAMILA D.N.I. 31759070   |          | 31759070
 LEDESMA OSCAR VICTOR DNI:14624137                 |          | 14624137
 RUIZ LUCIA 28819172                               |          | 28819172
 LEDESMA MARCELO FACUNDO 37949975                  |          | 37949975
 MAMANI CACERES DE VILLARREAL BEATRIZ DNI E8031109 |          | E8031109
 HUANCA FLORES LAURA DNI A8069632 26/05/65         |          | A8069632
 RUIZ TERESA MARIA 19959835                        |          | 19959835
(8 rows)
```

Tres razones: el número sin prefijo (`7158422`), el prefijo escrito de otra forma (`D.N.I.`, `DNI:`) y
un documento que no es solo de dígitos (`E8031109`, un pasaporte cargado como DNI).

**Rúbrica.** Una respuesta correcta tiene que:
- medir contra `truth.parser_case`, cruzando por `IdPaciente`, y no contra la propia expresión;
- dar precisión y cobertura por separado, y la predicción antes del resultado;
- explicar las faltas por tipo de escritura, con filas reales.

Y queda invalidada si:
- usa `truth` dentro de la expresión o para elegir qué filas procesar;
- da un solo porcentaje sin decir si es precisión o cobertura.

[← Volver al ejercicio](../a05-la-caja-y-el-generador.md#-ejercicio-5--medir-una-limpieza)

## 🔴 Muy difícil (6)

### Ejercicio 6

**Enunciado (resumen):** cuántos `NroProtocolo` se repiten en M, cómo se reparten por año, qué lo
explica y si se puede declarar `UNIQUE`.

**Solución de referencia.**

```sql
-- postgres
SELECT count(*) AS numeros_repetidos, sum(n) AS filas
FROM (SELECT "NroProtocolo", count(*) AS n FROM legacy."Protocolos" GROUP BY 1 HAVING count(*) > 1) AS d;

WITH dup AS (
    SELECT "NroProtocolo" FROM legacy."Protocolos" GROUP BY 1 HAVING count(*) > 1
)
SELECT extract(YEAR FROM p."Fecha")::int AS anio,
       count(*) AS protocolos,
       count(d."NroProtocolo") AS con_numero_repetido
FROM legacy."Protocolos" AS p
LEFT JOIN dup AS d USING ("NroProtocolo")
GROUP BY 1
ORDER BY 1;
```

```text
 numeros_repetidos | filas
-------------------+-------
              3902 |  7811
(1 row)

 anio | protocolos | con_numero_repetido
------+------------+---------------------
 1997 |       1570 |                   0
 …
 2004 |       5348 |                   0
 2005 |       6349 |                  28
 2006 |       7418 |                  52
 …
 2019 |      25747 |                 138
 2020 |      96533 |                 620
 …
 2025 |     192614 |                1216
 2026 |     150509 |                 950
(30 rows)
```

**Desde cuándo y a qué ritmo:** desde 2005, en todos los años, entre el 0,4 % y el 0,7 % de los
protocolos llevan un número repetido. **Qué lo explica:** `DMax("NroProtocolo", "Protocolos") + 1`,
el número que calcula el formulario desde 2004 ([historia](../00-historia-de-alameda.md), 2004 y
2005). Con una PC por sede funcionaba; desde que dos recepcionistas cargan a la vez, las dos leen el
mismo máximo y escriben el mismo número. M es la décima parte de Alameda: 28 filas en 2005 son unos
14 pares, que a escala real dan los "dos o tres por semana" de la historia. Y el ritmo no baja nunca,
porque nadie cambió el mecanismo: la regla fue "si sale repetido, bórralo y cárgalo de nuevo", y la
caja muestra lo que nadie borró.

**`UNIQUE` hoy no se puede**: 3.902 números lo impiden. El mecanismo que los produce lo trata el
Bloque III, con los comprobantes de la [Fase 16](../16-el-folio-sin-huecos.md); lo que hay que decidir aquí es qué número es el
verdadero de cada par: el primero en el tiempo, el que tiene
resultados, el que se imprimió. Lo que no se hace es renumerar en silencio un número que está impreso
en el sobre de un paciente.

**Rúbrica.** Una respuesta correcta tiene que:
- dar los dos conteos (números y filas) y el reparto por año;
- ubicar el inicio en 2005 y explicarlo con `DMax + 1` y la concurrencia;
- concluir que `UNIQUE` no entra sin decidir antes qué hacer con cada par, y proponer un criterio.

Y queda invalidada si:
- propone borrar las filas repetidas o renumerarlas sin criterio;
- atribuye los repetidos a un error de carga del generador sin mirar la historia.

[← Volver al ejercicio](../a05-la-caja-y-el-generador.md#-ejercicio-6--los-números-de-protocolo-repetidos)
