# ✅ Soluciones — Apéndice a10: El Access de museo

> **Curso:** Ruta SQL · Solucionario de [a10](../a10-el-access-de-museo.md)
> **Ejercicios:** 6 · **Herramientas:** Jackcess 4.0.10 y UCanAccess 5.1.3 sobre Java 25.0.4.1, mdbtools 1.0.1,
> LibreOffice 25.2.3 y Python 3.13.5, en las dos imágenes del apéndice
> **Fecha de verificación ejecutada:** 18/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Todos los comandos, desde `src/a10-el-access-de-museo/`, con `r`, `$MVN` y `$LO` definidos como en el
apéndice.

---

## 🟢 Fácil (1–2)

### Ejercicio 1

```bash
r $MVN java -cp "lib/*" QueryAccdb.java query out/alameda_1998_parseado.accdb \
  "SELECT COUNT(*) AS sin_dni FROM pacientes WHERE dni IS NULL"
r $MVN java -cp "lib/*" QueryAccdb.java query out/alameda_1998_parseado.accdb \
  "SELECT id, dni FROM pacientes WHERE NOT REGEXP_MATCHES(dni, '[0-9]+') ORDER BY id"
```

```text
sin_dni
-------
5
(1 filas)
id  | dni
--------------------
43  | NO TRAE
55  | 15519835 (VER)
67  | NO TRAE
99  | NO TRAE
104 | 36633751 (VER)
(5 filas)
```

Los 5 sin DNI son los 64 que no tenían menos los 59 que el parser separó: los ids 18, 29, 58, 88 y 108,
que en la salida del parser aparecen como `dni no es un DNI: ''`, con la dirección pegada al nombre. Los
5 que no son solo dígitos venían así en el campo `dni` y el parser no los toca, porque solo mira los
pacientes sin DNI: son los `NO TRAE` y los `(VER)` de la lista de sospechosos. `REGEXP_MATCHES` es de
HSQLDB, no de Access: en Access se escribiría con `Like`. Los tres pasaportes no salen en ninguna de las
dos consultas, porque su número es de siete dígitos: **pasan por DNI**, y es lo que el ejercicio quería
que vieras.

### Ejercicio 2

```bash
r $LO mdb-export out/alameda_1998_parseado.accdb pacientes > out/parseado_mdb.csv
r $MVN java -cp "lib/*" AccdbTool.java export out/alameda_1998_parseado.accdb out/parseado_jackcess.csv
cmp out/parseado_mdb.csv out/parseado_jackcess.csv && echo idénticos
```

```text
exported 120 rows to out/parseado_jackcess.csv
idénticos
```

Son idénticos. `apply` escribió con Jackcess y mdbtools, que es C y no comparte una línea de código con
Jackcess, lee las mismas 120 filas con los mismos valores: el archivo que dejó `apply` es un `.accdb`
válido, no algo que solo Jackcess entiende. Ojo con comparar contra `pacientes_parseado.csv`: ese lo
escribió Python con todo entre comillas (`QUOTE_NONNUMERIC`), y `cmp` da distinto desde el primer byte
aunque los valores sean los mismos.

---

## 🟡 Intermedio (3–4)

### Ejercicio 3

```bash
r $LO python3 run_bas_tests.py es-AR 1900
```

```text
FAIL  newborn takes mother's DNI / fecha_nac: got [22/05/1901] expected [22/05/2001]
FAIL  two-digit year 27 -> 2027 / fecha_nac: got [12/11/1927] expected [12/11/2027]
38 passed, 2 failed
```

Con la ventana desde 1900, toda fecha de dos cifras es 19xx. Fallan las dos que la PC de 1998 ponía en
20xx: el recién nacido de `22/05/01` vuelve a 1901, y la `12/11/27` de la señora Romero pasa a 1927. Lo
irónico es que la segunda **queda bien**: el DNI 11154535 es de alguien nacido en los años veinte, y la
ventana de 1998 era la que la mandaba al futuro. La prueba falla porque fija lo que el código hacía, no
lo que era verdad, y eso es exactamente una prueba de caracterización. `23/05/35` y `21/12/88` no se
mueven, porque ya eran 19xx.

### Ejercicio 4

```bash
r $LO mdb-schema out/alameda_1998.accdb postgres > out/museo_schema.sql
r $LO mdb-export -I postgres -q "'" out/alameda_1998.accdb pacientes > out/museo_datos.sql
PG=pgvector/pgvector@sha256:2358fcba361ed2233a5ed81b5fe4ca779ccb304120ce531a3bf51c0ed7e2bc11
docker run -d --rm --name a10-museo --label curso=ruta-sql -e POSTGRES_PASSWORD=lab -v "$PWD/out":/museo:ro $PG
# cuando pg_isready conteste:
docker exec a10-museo psql -U postgres -q -f /museo/museo_schema.sql -f /museo/museo_datos.sql
docker exec a10-museo psql -U postgres -c "INSERT INTO pacientes (nombre) VALUES ('MOYANO HECTOR')"
docker exec a10-museo psql -U postgres \
  -c "SELECT setval(pg_get_serial_sequence('pacientes', 'id'), max(id)) FROM pacientes" \
  -c "INSERT INTO pacientes (nombre) VALUES ('MOYANO HECTOR') RETURNING id"
docker stop a10-museo                    # --rm lo borra con su volumen anónimo
```

```text
ERROR:  duplicate key value violates unique constraint "pacientes_pkey"
DETAIL:  Key (id)=(1) already exists.
 setval
--------
    120
 id
-----
 121
```

Los `INSERT` de `mdb-export` traen el `id`, y un valor explícito en una columna `SERIAL` no pasa por la
secuencia: queda en 1, y el primer `INSERT` sin `id` choca. `setval` la lleva al máximo y el siguiente
recibe 121. Es la misma trampa que cualquier carga con claves de origen, y la
[Fase 25](../25-la-migracion-sin-parar.md) la resuelve dándole a las claves nuevas un rango propio.

---

## 🟠 Difícil (5)

### Ejercicio 5

Una función que separa la fecha a mano y la arma con `DateSerial`, y que usan los dos sitios donde el
original preguntaba al sistema (`IsDate` en `EsFecha`, `CDate` en `ParsearNombre`):

```diff
+' d/m/aa o d/m/aaaa, siempre dia/mes, sin mirar la configuracion regional.
+' Anio de dos cifras: del 00 al 29 es 20xx, como la PC de la recepcion en 1998.
+Private Function FechaDMA(ByVal t As String, ByRef f As Date) As Boolean
+    Dim p() As String, d As Integer, m As Integer, a As Integer
+    p = Split(t, "/")
+    If UBound(p) <> 2 Then Exit Function
+    If Not (EsNumero(p(0)) And EsNumero(p(1)) And EsNumero(p(2))) Then Exit Function
+    If InStr(t, ".") > 0 Then Exit Function
+    If Len(p(2)) <> 2 And Len(p(2)) <> 4 Then Exit Function
+    d = CInt(p(0)): m = CInt(p(1)): a = CInt(p(2))
+    If Len(p(2)) = 2 Then a = IIf(a < 30, 2000 + a, 1900 + a)
+    If m < 1 Or m > 12 Or d < 1 Then Exit Function
+    f = DateSerial(a, m, d)
+    If Day(f) <> d Then Exit Function
+    FechaDMA = True
+End Function
+
 Private Function EsFecha(ByVal t As String) As Boolean
-    EsFecha = (InStr(t, "/") > 0) And IsDate(t)
+    Dim f As Date
+    EsFecha = FechaDMA(t, f)
 End Function
@@
         ElseIf EsFecha(t) And fecha = "" Then
-            ' CDate con anio de dos digitos: del 00 al 29 lo toma como 20xx
-            fecha = Format$(CDate(t), "dd/mm/yyyy")
+            Dim f As Date
+            FechaDMA t, f
+            fecha = Format$(Day(f), "00") & "/" & Format$(Month(f), "00") & "/" & Year(f)
             enNombre = False
```

```text
== es-AR            40 passed, 0 failed
== en-US            40 passed, 0 failed
== es-AR default    40 passed, 0 failed
== es-AR 1950       40 passed, 0 failed
```

`If Day(f) <> d` descarta un `31/02/88`, que `DateSerial` convertiría en marzo sin quejarse. La fecha
se escribe pieza por pieza porque en `Format$` la barra de `"dd/mm/yyyy"` no es una barra: es el
separador de fechas de la configuración regional, y en una PC configurada con otro separador la fecha
sale con otro carácter. La corrección es la misma que la del modelo: **la conversión explícita, en un
solo sitio, sin preguntar al entorno**.

**Rúbrica, si tu solución es otra (sobre 4 puntos):** 1 punto por 40 de 40 en `en-US`; 1 por 40 de 40 con
las dos ventanas; 1 por no tocar `TestParser.bas`; 1 por la frase sobre `Format$`.

---

## 🔴 Muy difícil (6)

### Ejercicio 6

`suspicious` recibe `today` como parámetro, así que no hace falta esperar: se llama con otras fechas.

```bash
r $LO python3 -c '
from datetime import date
import csv, parse_patients as p
rows = list(csv.DictReader(open("out/pacientes_parseado.csv", encoding="utf-8")))
for hoy in (date(2026, 10, 18), date(2027, 11, 12), date(2030, 1, 1)):
    marcados = [(r["id"], w) for r in rows if (w := p.suspicious(r, hoy))]
    print(hoy, len(marcados), [w for i, w in marcados if i == "81"])'
```

```text
2026-10-18 17 [['nació en el futuro: 12/11/2027']]
2027-11-12 17 [['DNI 11154535 no cuadra con nacer en 2027']]
2030-01-01 17 [['DNI 11154535 no cuadra con nacer en 2027']]
```

El total no cambia, pero el motivo sí. Hasta el 11/11/2027 el 81 "nació en el futuro"; desde el
12/11/2027 ya no (la regla es `birth > today`), y cae en la regla siguiente: un DNI menor que 20 millones
no cuadra con nacer después de 2000. Es la misma fila, con el mismo error (la ventana de dos cifras la
mandó de 1927 a 2027), y el diagnóstico depende del día en que corre el chequeo. Una regla así no se
puede usar para comparar dos corridas, porque cambia sola.

**Rúbrica (sobre 4 puntos):** 1 punto por llamar a `suspicious` con otra fecha en lugar de cambiar el
reloj; 1 por ver que el total se mantiene y el motivo cambia; 1 por explicar la causa (la regla compara
con hoy; la fila es la de la ventana); 1 por una regla que no dependa del día. La de referencia
compara contra un dato fijo y no contra el reloj: en el modelo nuevo, `person.birth_date` no puede ser
posterior a la fecha del primer protocolo de esa persona, que no cambia nunca. Como cruza dos tablas, no
es un `CHECK`: va en la validación de la carga, y da el mismo resultado hoy y en 2030. Para la fecha de
dos cifras, además, la conversión explícita de la [Fase 04](../04-un-valor-un-hecho.md), que no la deja
llegar.
