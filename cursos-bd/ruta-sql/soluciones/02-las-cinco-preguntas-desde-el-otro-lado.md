# ✅ Soluciones — Fase 02: Las cinco preguntas, desde el otro lado

> **Curso:** Ruta SQL · Solucionario de la [Fase 02](../02-las-cinco-preguntas-desde-el-otro-lado.md)
> **Ejercicios:** 12 · **Perfil:** no aplica · **Motores:** ninguno: la fase se lee
> **Fecha de verificación ejecutada:** no aplica: los datos salen de la
> [historia de Alameda](../00-historia-de-alameda.md) y de las cifras de la caja de M publicadas en la
> [Fase 01](../01-la-caja-y-el-arnes.md)

> ⚠️ **Intenta el ejercicio antes de leer su solución.** Leída antes, solo te enseña a reconocerla.

---

## 🟢 Fácil (1–4)

### Ejercicio 1

**Enunciado (resumen):** la pregunta que faltó en cuatro decisiones de Alameda.

**Solución.**

- **`DMax + 1`** → *¿dónde está la frontera transaccional?* Leer el máximo y escribir el siguiente
  tenían que ocurrir juntos.
- **`ResultadoItem` con el valor como texto** → *¿cuál es la unidad de lectura?* y, sobre todo, qué
  valores son válidos: se guardó lo que escribió el equipo, sin decidir qué era un resultado.
- **El parser en VBA y en T-SQL** → *¿dónde vive la regla?*, que es la frontera transaccional aplicada a
  una regla: dos copias que nada obliga a cambiar juntas.
- **Las 280 tablas de precios** → *¿conoces tus consultas de antemano?* "¿Cuánto valía esta práctica
  en marzo?" era una consulta segura, y el modelo de un valor por práctica no podía contestarla.

[← Volver al ejercicio](../02-las-cinco-preguntas-desde-el-otro-lado.md#-ejercicio-1--la-pregunta-que-falta)

### Ejercicio 2

**Enunciado (resumen):** tres sitios donde el esquema existía fuera del motor.

**Solución.**

1. **El papel pegado al monitor**: *"APELLIDO NOMBRE espacio DNI espacio NÚMERO"*, la primera
   especificación de formato de la empresa, que vivía en la recepción.
2. **`ExtraerDNI()`**: las reglas del documento (tipo, país, número, recién nacidos), en casi trescientas
   líneas de VBA y en su copia de T-SQL.
3. **La función de 300 líneas que resalta los valores fuera de rango**: el significado de cada rango de
   referencia, que en la base es texto libre y solo conoce Matías.

[← Volver al ejercicio](../02-las-cinco-preguntas-desde-el-otro-lado.md#-ejercicio-2--el-esquema-que-sí-había)

### Ejercicio 3

**Enunciado (resumen):** los hechos que cambian juntos al emitir un comprobante.

**Solución.**

1. **El número**: pasa a ser el último autorizado para ese punto de venta y ese tipo.
2. **El comprobante con sus líneas**: las prácticas cobradas, con su precio vigente ese día.
3. **El estado del protocolo**: pasa a facturado, para no cobrarlo dos veces.

Si el número avanza y el comprobante no se guarda, el siguiente sale con un número salteado y el web
service lo rechaza. Si el comprobante se guarda y el protocolo no cambia de estado, se factura dos
veces. Si el número no avanza, otra caja emite el mismo: el error 10016 de 2015.

[← Volver al ejercicio](../02-las-cinco-preguntas-desde-el-otro-lado.md#-ejercicio-3--la-frontera-del-comprobante)

### Ejercicio 4

**Enunciado (resumen):** qué se lee junto cuando un paciente abre su informe.

**Solución.** El protocolo (fecha, sede, médico), sus prácticas y los resultados de cada una, con su
unidad y su rango de referencia. En la caja de M son unos **nueve resultados por protocolo** (12,1
millones para 1,3 millones de protocolos), y se leen siempre juntos y casi nunca por separado. Eso
favorece a Florencia: un documento por protocolo se lee de una vez, sin juntar filas de tres tablas.

[← Volver al ejercicio](../02-las-cinco-preguntas-desde-el-otro-lado.md#-ejercicio-4--la-unidad-de-lectura-del-informe)

## 🟡 Intermedio (5–8)

### Ejercicio 5

**Enunciado (resumen):** las cinco preguntas para el módulo de turnos.

**Solución de referencia.**

- **Frontera transaccional:** el turno y su horario: dos personas no pueden tomar el mismo. Cruza el
  turno con la agenda de la sede.
- **Consultas conocidas:** sí: los turnos de un día, de una sede, de un paciente.
- **Unidad de lectura:** el turno con sus exámenes solicitados.
- **Saltos:** uno (turno → paciente).
- **Exactitud:** exacta.

**Conclusión:** es relacional. El campo multivalor de `ExamenesSolicitados` es una relación muchos a
muchos que Access guardaba dentro de un campo; en el modelo nuevo es una tabla. La frontera del horario
es justo lo que un motor relacional defiende con una restricción.

[← Volver al ejercicio](../02-las-cinco-preguntas-desde-el-otro-lado.md#-ejercicio-5--turnos)

### Ejercicio 6

**Enunciado (resumen):** las cinco preguntas para `ParaLlamar`.

**Solución de referencia.**

- **Frontera transaccional:** marcar "llamado" (y, desde la pandemia, "llamado dos") sobre un resultado
  listo. Es una sola fila.
- **Consultas conocidas:** una sola: los pendientes de hoy.
- **Unidad de lectura:** la llamada pendiente, con nombre y teléfono.
- **Saltos:** uno (al paciente).
- **Exactitud:** exacta.

**¿Tiene que existir?** No como tabla aparte: es el **estado de una notificación** de un protocolo, y
`LlamadoDos` muestra que hace falta registrar cada intento. En el modelo nuevo, una tabla de
notificaciones con su canal (teléfono, portal, app) y su fecha reemplaza la planilla, y deja de duplicar
el nombre y el teléfono del paciente.

[← Volver al ejercicio](../02-las-cinco-preguntas-desde-el-otro-lado.md#-ejercicio-6--parallamar)

### Ejercicio 7

**Enunciado (resumen):** qué tendría que pasar para que el informe también fuera la unidad de escritura.

**Solución de referencia.** Que el informe se escribiera **de una vez y no se tocara más**: todos los
resultados llegando juntos, validados antes de guardarse, sin correcciones posteriores ni facturación por
práctica. En Alameda eso significaría cambiar el laboratorio, no la base: esperar a que todos los equipos
terminen para guardar nada, y emitir una corrección como un informe nuevo entero. Lo pagarían Norma, que
necesita saber quién cambió cada valor, y la facturación, que cobra por práctica. Por eso el curso
concede la lectura y discute la escritura.

[← Volver al ejercicio](../02-las-cinco-preguntas-desde-el-otro-lado.md#-ejercicio-7--escritura-contra-lectura)

### Ejercicio 8

**Enunciado (resumen):** la tabla de la sección 4.7 para un sistema propio.

**Rúbrica.** No hay solución única. Una respuesta correcta tiene que:
- partir el sistema en partes que se escriben y se leen distinto, no en módulos de código;
- contestar las cinco columnas para cada parte, con un dato o un ejemplo de cada respuesta;
- señalar al menos una parte donde la respuesta no favorezca al modelo relacional, o decir con qué
  dato se descartó.

Y queda invalidada si:
- contesta las preguntas para el sistema entero, en una sola fila.

[← Volver al ejercicio](../02-las-cinco-preguntas-desde-el-otro-lado.md#-ejercicio-8--un-dominio-tuyo)

## 🟠 Difícil (9–11)

### Ejercicio 9

**Enunciado (resumen):** responder a "necesitamos esquema flexible porque los exámenes cambian".

**Solución de referencia.** *"Tienes razón en que los exámenes cambian: hay unos 1.100 tipos de
determinación, y una tabla por examen fue lo que se rompió en 1999. Pero el esquema no desaparece con
Mongo: hoy Alameda ya tiene un esquema flexible, `ResultadoItem` con todo como texto, y el esquema real
vive en una función de VBA que solo entiende Matías. La pregunta no es si el esquema es fijo, sino dónde
vive. Lo que varía de verdad, la forma de cada examen, puede ir en un `jsonb` con su validación; lo que no
varía, el protocolo, el precio y el folio, tiene que estar donde el motor lo defienda."*

**Rúbrica.** Una respuesta correcta tiene que:
- conceder que la variedad de exámenes es real, con el dato;
- reformular "esquema fijo" como "dónde vive el esquema";
- separar lo que varía de lo que no.

Y queda invalidada si:
- niega que la forma de los exámenes varíe.

[← Volver al ejercicio](../02-las-cinco-preguntas-desde-el-otro-lado.md#-ejercicio-9--esquema-fijo)

### Ejercicio 10

**Enunciado (resumen):** contestar a quien quiere empezar por las 280 tablas de precios.

**Solución de referencia.** Las tablas de precios duelen **una vez por mes**, a mano, y nadie pierde datos
porque estén separadas: Rubén las creó justamente para no perder un precio. El folio fiscal se rechaza
**una vez por mes** y traba la caja cuando hay carga, y el portal expone resultados de pacientes. El triaje
empieza por lo que pierde dinero, datos o la ley: primero el folio y el portal, después el respaldo, y los
precios cuando el modelo temporal del Bloque I esté listo. Unificar los precios primero es un mes de
trabajo visible que no le quita al laboratorio ni un rechazo.

**Rúbrica.** Una respuesta correcta tiene que:
- reconocer que las tablas de precios son un problema real;
- ordenar por lo que cuesta hoy, con un dato de la historia para cada caso;
- decir cuándo sí se atacan los precios.

Y queda invalidada si:
- descarta el problema de los precios en lugar de postergarlo.

[← Volver al ejercicio](../02-las-cinco-preguntas-desde-el-otro-lado.md#-ejercicio-10--el-triaje-con-otro-orden)

### Ejercicio 11

**Enunciado (resumen):** un `CHECK` contra fechas de nacimiento futuras, con 442 que ya las tienen.

**Solución de referencia.** **Creado hoy, falla**: el motor comprueba las filas que ya existen, encuentra
las 442 y no crea la restricción. **SQL Server en 2011** eligió el otro extremo para las claves foráneas:
`WITH NOCHECK`, que crea la restricción sin mirar lo existente y nunca la valida; las nuevas filas quedan
protegidas, y las viejas, para siempre sin revisar. **El camino del triaje** es el del medio: crear la
restricción **sin validar** lo existente (`NOT VALID` en Postgres), de modo que ninguna fila nueva pueda
nacer en el futuro; limpiar las 442 con un criterio que se pueda medir contra `truth`; y recién entonces
**validarla** (`VALIDATE CONSTRAINT`), que deja la restricción completa y verificada.

**Rúbrica.** Una respuesta correcta tiene que:
- decir que el `CHECK` directo falla, y por qué;
- distinguir `WITH NOCHECK` (nunca se valida) de `NOT VALID` (se valida después);
- incluir la limpieza entre la creación y la validación.

Y queda invalidada si:
- propone borrar las 442 filas para poder crear la restricción.

[← Volver al ejercicio](../02-las-cinco-preguntas-desde-el-otro-lado.md#-ejercicio-11--la-restricción-que-no-se-puede-crear)

## 🔴 Muy difícil (12)

### Ejercicio 12

**Enunciado (resumen):** un plan para el primer mes, con cuatro acciones en orden y lo que no se toca.

**Solución de referencia.**

1. **Semana 1: la copia medible.** La caja cargada en un Postgres de análisis, con la prueba de fuego
   pasada. Pregunta: ninguna todavía; es el instrumento.
2. **Semana 2: las cinco preguntas por partes**, con Matías, Norma y Florencia, y la tabla de la sección
   4.7 firmada por los tres. Sale de ahí qué es relacional y qué se mide en el Bloque IV.
3. **Semanas 2 y 3: el folio fiscal.** Una propuesta para reemplazar `UltimoNumero` con una transacción,
   probada con varias cajas a la vez sobre la copia. Pregunta: la frontera transaccional; dato: un rechazo
   por mes y la caja trabada en 2020.
4. **Semana 4: el portal.** Cerrar la enumeración de resultados, que el MD5 de 2018 no cerró. Dato: los
   catorce mil informes descargados.

**Lo que no se toca todavía:** los precios, la deduplicación de pacientes y la elección de motor. Los
tres tienen su bloque y necesitan mediciones que todavía no existen.

**Rúbrica.** Una respuesta correcta tiene que:
- empezar por una copia que se pueda medir, no por producción;
- ordenar por costo actual, con un dato de la historia en cada paso;
- decir explícitamente qué queda fuera del primer mes.

Y queda invalidada si:
- incluye en el primer mes elegir el motor o migrar datos de producción.

[← Volver al ejercicio](../02-las-cinco-preguntas-desde-el-otro-lado.md#-ejercicio-12--el-primer-mes)
