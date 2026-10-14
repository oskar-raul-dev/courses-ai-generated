# T3: bea-08 to Ottawa. §8 rewritten from "Colombia no, y aun así" to "Ottawa sí, y por eso", backed by
# salidas/t3-java-zonas.txt, t3-java-localdate.txt and t3-mongo.txt.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
a = Archivo('bea-08-tiempo-zonas-y-fechas-en-mongo.md')
a.rep('''- El `db.json` guarda **todas** las fechas con desplazamiento explícito: `"2022-01-03T08:15:00-05:00"`. Nunca `Z`, nunca fecha desnuda.
- La Fase 2 fijó **`America/Bogota`** como zona de la aplicación.''','''- El `db.json` guarda **todas** las fechas con desplazamiento explícito: `"2022-01-03T08:15:00-05:00"`. Nunca `Z`, nunca fecha desnuda. (En PROD hay dos excepciones que son un incidente: los bordes de la v2 del potasio, que un script escribió en `Z` — el **07** del cuaderno base.)
- Ese `-05:00` es el de Ottawa **en invierno**, y todas las fechas de la semilla caen entre diciembre y enero. La Era 1 lo escribió como constante.
- La Fase 2 fijó **`America/Toronto`** como zona de la aplicación.''')
a.rep('''- [8. Horario de verano: Colombia no, y aun así](#8-horario-de-verano-colombia-no-y-aun-así)''','''- [8. Horario de verano: Ottawa sí, y por eso](#8-horario-de-verano-ottawa-sí-y-por-eso)''')
a.rep('''No conservas la zona: conservas **el desplazamiento de aquel día**. Son cosas distintas. Con un país sin horario de verano —Colombia— coinciden, así que funciona. Con datos de un proveedor en un país que sí lo tiene, el mismo `-05:00` significa dos zonas distintas según el mes. Funciona **por suerte y no por diseño**, y saber que estás en ese caso es lo que hace que no te sorprenda el día que dejes de estarlo.''','''No conservas la zona: conservas **el desplazamiento de aquel día**. Son cosas distintas. En Ottawa coinciden de noviembre a marzo y no el resto del año: el `-05:00` de la semilla es correcto porque todas sus fechas caen en invierno, y el mismo `-05:00` escrito un día de julio es un instante una hora más tarde que el reloj de la pared. Funciona **por calendario y no por diseño**, y saber que estás en ese caso es lo que hace que no te sorprenda el día que dejes de estarlo (§8).''')
a.rep('''// $dateToString con timezone (desde MongoDB 3.6). Es la forma correcta de
// agrupar "por día en Bogotá": la conversión se hace en la agregación, no
// guardando hora local.''','''// $dateToString con timezone (desde MongoDB 3.6). Es la forma correcta de
// agrupar "por día en Ottawa": la conversión se hace en la agregación, no
// guardando hora local, y con el identificador IANA el horario de verano
// sale solo.''')
a.rep("                              timezone: 'America/Bogota' } },", "                              timezone: 'America/Toronto' } },")
a.rep('''> 💡 **Ese `timezone` es la línea que separa un informe correcto de uno que reparte mal los asientos de la noche.** Sin él, `$dateToString` agrupa en UTC, y todo lo ocurrido entre las 19:00 y las 24:00 de Bogotá cae en el día siguiente. Cinco horas de cada día en la casilla equivocada, todos los días, sin ningún error.''','''> 💡 **Ese `timezone` es la línea que separa un informe correcto de uno que reparte mal los asientos de la noche.** Sin él, `$dateToString` agrupa en UTC, y todo lo ocurrido desde las 19:00 de Ottawa en invierno —desde las 20:00 en verano— cae en el día siguiente. Cinco horas de cada día en la casilla equivocada, o cuatro según el mes, todos los días, sin ningún error. Y un `timezone: '-05:00'` fijo no lo arregla: acierta en invierno y reparte mal una hora cada noche de verano.''')
a.rep('''ZonedDateTime inBogota = now.atZone(ZoneId.of("America/Bogota"));    // para pintar''','''ZonedDateTime inOttawa = now.atZone(ZoneId.of("America/Toronto"));   // para pintar''')
a.rep('''java.util.Date d = new java.util.Date(1757516645123L);
System.out.println(d);
// Imprime la hora en la zona POR DEFECTO DE LA JVM. En el contenedor, UTC.
// En el portátil de un desarrollador en Bogotá, cinco horas menos.''','''java.util.Date d = new java.util.Date(1789052645123L);   // 2026-09-10T15:04:05.123Z
System.out.println(d);
// Imprime la hora en la zona POR DEFECTO DE LA JVM. En el contenedor, UTC:
// "Thu Sep 10 15:04:05 UTC 2026". En el portátil de un desarrollador en
// Ottawa, "Thu Sep 10 11:04:05 EDT 2026": cuatro horas menos en septiembre,
// cinco en enero.''')
a.rep('''> ⚠️ **`LocalDate` es la trampa sutil.** Se guarda como un instante a medianoche —y según la versión y los convertidores, en UTC o en la zona por defecto—. Un cumpleaños guardado así en un sistema configurado en `America/Bogota` y leído en UTC **sale un día antes**.''','''> ⚠️ **`LocalDate` es la trampa sutil.** Spring Data 2.1 lo guarda como la medianoche **en la zona por defecto de la JVM que escribe**, y lo lee en la zona de la JVM que lee. Un cumpleaños escrito por el contenedor —en UTC: `1984-03-12T00:00:00Z`— y leído en el portátil de un desarrollador en Ottawa **sale un día antes**: esa medianoche UTC son las 19:00 del 11. Al revés no pasa: escrito en Ottawa queda en `05:00Z` del mismo día, y leído en UTC sigue siendo el 12.''')
a.between('''## 8. Horario de verano: Colombia no, y aun así''', '''## 🧭 Cuándo usar qué''', open(os.path.join(os.path.dirname(__file__), 't3-bea08-seccion8.md'), encoding='utf-8').read())
a.rep('''| Pintarlo para un operador | `ZonedDateTime` con `America/Bogota`, **en el borde de salida** |''','''| Pintarlo para un operador | `ZonedDateTime` con `America/Toronto`, **en el borde de salida** |''')
a.rep('''| Calcular un desplazamiento | `ZoneId`, nunca aritmética a mano |''','''| Calcular un desplazamiento | `ZoneId`, nunca aritmética a mano ni un `-05:00` fijo |''')
a.rep('''Las imágenes base suelen venir en UTC, así que el servidor piensa en UTC y el operador en Bogotá.''','''Las imágenes base suelen venir en UTC, así que el servidor piensa en UTC y el operador en Ottawa.''')
a.rep('''3. Escribe el `$dateToString` que agrupa asientos por día **en Bogotá** y el mismo sin `timezone`. Compara los dos resultados y cuenta cuántos asientos cambian de día.''','''3. Escribe el `$dateToString` que agrupa asientos por día **en Ottawa** y el mismo sin `timezone`, y un tercero con `timezone: '-05:00'`. Compara los tres resultados, cuenta cuántos asientos cambian de día, y separa los de invierno de los de verano.''')
a.save()
