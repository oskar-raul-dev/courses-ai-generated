# ✅ Soluciones — Fase 26: El comité

> **Curso:** Ruta SQL · Solucionario de la [Fase 26](../26-el-comite.md)
> **Ejercicios:** 20 · **Perfil:** M · **Motor:** Postgres 18.6 de [`a02`](../a02-compose-de-la-ruta.md), para el arnés del martes
> **Fecha de verificación ejecutada:** 15/10/2026

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

Los ejercicios 1 a 10 están resueltos con `01_factura.py`, la salida de `martes/arnes.py` y las fuentes de la sección 3 de la lección, en la sesión de verificación del 15/10/2026. Los de 11 a 20 llevan rúbrica, que también está en la lección. El boss global no publica su solución.

---

## 🟢 Fácil (1–5)

### Ejercicio 1

```bash
python 26-el-comite/01_factura.py
```

```text
2 servidores de 16 núcleos x86 · factor 0.5 · 16 licencias de procesador
escenario                                               licencias  soporte/año       5 años
EE sola                                                   760,000      167,200    1,596,000
```

**Lectura:** USD 1.596.000 a cinco años, de los que **836.000 son soporte** (167.200 por año). Pasado el primer año, el soporte es la mayor parte de la cuenta: a los cinco años supera a la licencia.

### Ejercicio 2

Ocho núcleos Xeon son **4 licencias** (8 × 0,5). Ocho núcleos de un ARM que no es Ampere son **8**, porque la tabla del 28/01/2026 les da factor 1,0, y a Ampere 0,25. Sobre un mismo servidor, el factor de núcleo es la primera línea de la factura.

### Ejercicio 3

El **22 %**: 10.450 sobre 47.500 en EE, 3.850 sobre 17.500 en SE2, 2.530 sobre 11.500 en Partitioning. Es la misma proporción en toda la sección I de la lista.

### Ejercicio 4

```text
❌ C1 · precio a la fecha: 6652 de 14942 líneas con otro precio; 8288 líneas con el precio de octubre
❌ C2 · lo que no se paga no se presenta: presentadas de más 7250, de menos 0, exclusiones con otro motivo o sin motivo 7578; …
❌ C3 · cantidad y coseguro: 282 líneas con otra cantidad; coseguro distinto en […] (esperado 9437714.8000)
❌ C4 · la reconciliación cierra al centavo: 330 prácticas de la semana sin destino; totales distintos en […]
❌ C5 · legacy sigue viva: de la mañana faltan 0 de 4; corregida con cantidad 1; borrada afuera; de la tarde en la presentación 2 de 2; volver a emitir cambió la presentación
0 de 5
```

**Lectura:** 0 de 5. El error más grande en pesos es **presentar lo que está fuera de convenio**: 205,3 millones de la semana, que la obra social debitaría entera. Le sigue el coseguro que no se descuenta (9,4 millones que el paciente ya pagó y la obra social pagaría otra vez).

### Ejercicio 5

```text
lo esperado: {'excede_tope': 6, 'fuera_de_convenio': 7241, 'incluida_en_panel': 1, 'presentada': 7692, 'sin_precio': 330}
```

**Lectura:** de 15.270 prácticas de la semana (sin `PARTICULAR`), se presentan 7.692. Quedan afuera 7.241 por convenio, 330 sin precio vigente, 6 por el tope y 1 por estar incluida en su panel. La proporción fuera de convenio es un artefacto de la caja (D50); el criterio mide que no se presente ninguna.

---

## 🟡 Intermedio (6–10)

### Ejercicio 6

Porque la tabla de precios de Matías tiene, para PAMI, **vigencias duplicadas**: dos precios de la misma práctica que empiezan el mismo día. La Fase 07 no eligió ninguno y los mandó a rechazos (`precios.vigencia_duplicada`), así que el período queda sin precio en el modelo y lo facturado de esos días va a `facturacion.practica_sin_precio_vigente`. La planilla de legacy elige el último cargado y lo factura. Un martes, Matías llama a PAMI o mira el convenio firmado, decide cuál es el precio acordado y lo carga una vez; las prácticas se reaplican desde la cola. Lo que no hace es facturar un precio que nadie decidió.

### Ejercicio 7

**6 prácticas de PAMI**, por 174.721,69 pesos de la planilla. El tope es por mes calendario y por afiliado, así que para saber si una práctica del 28 de septiembre se pasa del tope hay que contar **las unidades de ese afiliado desde el 1 de septiembre**. Por eso el arnés y la solución leen el mes completo, aunque presenten solo la semana. Y la semana cruza al 1 de octubre, donde el tope vuelve a empezar: el criterio se rompe si se cuenta por semana o si se arrastra septiembre a octubre.

### Ejercicio 8

El manual de MySQL 9.7 dice que una serie LTS sigue la política de soporte de Oracle con **cinco años *premier* y tres de extendido**, y las notas de la 9.7.0 la fechan el **21/04/2026**. Con esa política, *premier* hasta abril de 2031 y extendido hasta abril de 2034. Es una fecha **calculada** con la política publicada: el documento de ciclo de vida de Oracle no se leyó en esta sesión, y en un documento para el comité se cita así.

### Ejercicio 9

Con el mismo procedimiento de la Fase 25: una instancia nueva con la versión siguiente al lado, la carga inicial, la convivencia por replicación lógica (de Postgres a Postgres es la replicación lógica nativa, con publicación y suscripción, la misma familia que `test_decoding`), la reconciliación, y un corte con criterio y vuelta atrás. La política de versiones de Postgres da cinco años de soporte por versión mayor, y una por año: la migración entre versiones se vuelve rutina, no proyecto.

### Ejercicio 10

**9.437.714,80 pesos.** Se descuenta por protocolo porque el coseguro se cobra en la caja **por protocolo** (`Protocolos.Coseguro`), no por práctica, y no puede superar lo presentado de ese protocolo. Si un protocolo tiene prácticas presentadas y otras fuera de convenio, el coseguro se descuenta solo hasta lo que la obra social va a pagar; el resto es del paciente. Repartirlo por práctica obligaría a inventar una regla de prorrateo que Alameda no tiene.

---

## 🟠 Avanzado (11–16) — rúbrica

### Ejercicio 11

*Las opciones.*

**Rúbrica (sobre 3 puntos):** 1 punto por lo que da cada opción; 1 por su costo a cinco años con la lista; 1 por el equivalente en Postgres y su costo (personas, no licencia).

### Ejercicio 12

*La formación de Matías.*

**Rúbrica (sobre 3 puntos):** 1 punto por empezar por lo que puede parar el laboratorio (slots, esperas); 1 por la fase de cada punto; 1 por separar lo que ya sabe.

### Ejercicio 13

*MySQL dentro de cinco años.*

**Rúbrica (sobre 3 puntos):** 1 punto por las fechas con su fuente; 1 por separar el motor del portal; 1 por la salida (la API de la Fase 23).

### Ejercicio 14

*Los turnos.*

**Solución de referencia:** el turno y el protocolo comparten una frontera transaccional (un turno se convierte en protocolo), así que el árbol termina en la primera hoja: relacional. Los exámenes separados por punto y coma son un valor no atómico que la Fase 04 sabe descomponer. El turno no necesita otro motor: necesita salir del `.accdb` de la PC de recepción.

**Rúbrica (sobre 3 puntos):** 1 punto por la frontera transaccional (el turno y el protocolo); 1 por los exámenes separados por punto y coma; 1 por la hoja y su medición.

### Ejercicio 15

*Un criterio más.*

**Rúbrica (sobre 3 puntos):** 1 punto por un criterio de débito real (la orden firmada, el número de afiliado); 1 por cómo se verifica contra legacy; 1 por lo que el modelo necesitaría agregar.

### Ejercicio 16

*Standard Edition 2.*

**Rúbrica (sobre 3 puntos):** 1 punto por el costo con la lista; 1 por lo que se pierde (opciones como el particionado); 1 por decidir con el volumen de Alameda.

---

## 🔴 Muy difícil (17–20) — rúbrica

### Ejercicio 17

*Un martes.*

**Rúbrica (sobre 5 puntos):** 1 punto por cada criterio del arnés en verde. El boss no publica su solución: la salida del arnés con `5 de 5` es la prueba.

### Ejercicio 18

*Diez minutos.*

**Rúbrica (sobre 4 puntos):** 1 punto por empezar por el problema (la condición de no parar); 1 por una medición en contra dicha por ti; 1 por la factura entera; 1 por lo que le pides al comité que decida.

### Ejercicio 19

*La parte que no es relacional.*

**Rúbrica (sobre 4 puntos):** 1 punto por la parte y la rama del árbol; 1 por la medición que lo sostiene; 1 por cómo se mantiene coherente con la fuente; 1 por lo que se pierde.

### Ejercicio 20

*El veredicto.*

**Rúbrica (sobre 4 puntos):** 1 punto por la decisión con su mejor contraargumento; 1 por la factura de licencias, personas y riesgo; 1 por las métricas de dentro de un año; 1 por el criterio de dar marcha atrás.
