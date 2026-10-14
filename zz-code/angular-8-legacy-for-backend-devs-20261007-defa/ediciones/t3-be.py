# T3: be04 zone, be06 timeline (v2 written 2021-12-28, in force 2022-01-01, result 2022-10-12, $set 2023-03-01:
# still 14 months), D10 legal name, the consultancy, and the 2020 import as the Gatineau collection point
# Andina bought (author's decision of 2026-10-07).
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo

b4 = Archivo('be04-el-audit-log-que-escribia-el-navegador.md')
b4.rep('''Cadena, con desplazamiento explícito de `America/Bogota`. Es la de los datos sembrados.''',
       '''Cadena, con el desplazamiento de `America/Toronto` en invierno, escrito como constante desde la Era 1. Es la de los datos sembrados, que caen todos en invierno.''')
b4.rep('''Conserva el desplazamiento de aquel día, que con horario de verano no es lo mismo; Colombia no lo tiene, así que aquí funciona por suerte y no por diseño.''',
       '''Conserva el desplazamiento de aquel día, que con horario de verano no es lo mismo; Ottawa lo tiene, y el `-05:00` de LabCore solo es correcto de noviembre a marzo: funciona por calendario y no por diseño (`bea-08` §8).''')
b4.rep('''// El instante se guarda en UTC y NADA MÁS. La zona America/Bogota es una''', '''// El instante se guarda en UTC y NADA MÁS. La zona America/Toronto es una''')
b4.save()

b6 = Archivo('be06-los-rangos-y-la-historia-perdida.md')
R = [
 ('"¿Qué rango de glucosa estaba vigente el 12 de marzo de 2020?"', '"¿Qué rango de glucosa estaba vigente el 12 de octubre de 2022?"', 1),
 ('es el fundamento de que un informe firmado en 2020 signifique algo.', 'es el fundamento de que un informe firmado en 2022 signifique algo.', 1),
 ('un resultado validado en 2020 cuyo `rangeVersionApplied`', 'un resultado validado en 2022 cuyo `rangeVersionApplied`', 1),
 ('Un resultado validado en 2020 se queda como está', 'Un resultado validado en 2022 se queda como está', 1),
 ('"El rango de glucosa v2 rige desde el 1 de junio de 2019".', '"El rango de glucosa v2 rige desde el 1 de enero de 2022".', 1),
 ('desde que lo escribimos el 28 de mayo de 2019 hasta que alguien lo cambió el 1 de agosto de 2020."', 'desde que lo escribimos el 28 de diciembre de 2021 hasta que alguien lo cambió el 1 de marzo de 2023."', 1),
 ('| *¿Qué rango regía el 12 de marzo de 2020?* |', '| *¿Qué rango regía el 12 de octubre de 2022?* |', 1),
 ('| *¿Qué rango creía el sistema que regía el 12 de marzo de 2020?* |', '| *¿Qué rango creía el sistema que regía el 12 de octubre de 2022?* |', 1),
 ('que hace que el problema pasara desapercibido seis años:', 'que hace que el problema pasara desapercibido tres años:', 1),
 ('no son los que había en 2020.', 'no son los que había en 2022.', 1),
 ('**Qué se hizo.** En agosto de 2020 llegó una actualización de la norma:', '**Qué se hizo.** En marzo de 2023 llegó una actualización de la norma:', 1),
 ('// Agosto de 2020. Una línea. Catorce meses de historia.', '// Marzo de 2023. Una línea. Catorce meses de historia.', 1),
 ('**14 meses perdidos** (jun 2019 – ago 2020)', '**14 meses perdidos** (ene 2022 – mar 2023)', 1),
 ("{ $set: { effectiveTo: ISODate('2020-07-31T23:59:59Z') } }", "{ $set: { effectiveTo: ISODate('2023-02-28T23:59:59Z') } }", 1),
 ("effectiveFrom: ISODate('2020-08-01T00:00:00Z'), effectiveTo: null", "effectiveFrom: ISODate('2023-03-01T00:00:00Z'), effectiveTo: null", 1),
 ("validatedAt: { $gte: ISODate('2020-03-01'),\n                                        $lt:  ISODate('2020-04-01') } },", "validatedAt: { $gte: ISODate('2022-10-01'),\n                                        $lt:  ISODate('2022-11-01') } },", 1),
 ('validatedAt: ISODate("2020-03-12T15:41:00Z"), rangeVersionApplied: 2 }', 'validatedAt: ISODate("2022-10-12T15:41:00Z"), rangeVersionApplied: 2 }', 1),
 ('Con la v2 de marzo de 2020 —`high: 100`— estaba **dentro**', 'Con la v2 de octubre de 2022 —`high: 100`— estaba **dentro**', 1),
 ('  hasta: 2020-08-01  (fecha de la resolución;', '  hasta: 2023-03-01  (fecha de la resolución;', 1),
 ("$lt:  ISODate('2020-08-01') } } },", "$lt:  ISODate('2023-03-01') } } },", 1),
 ("validatedAt: { $lt: ISODate('2020-08-01') },", "validatedAt: { $lt: ISODate('2023-03-01') },", 1),
 ('// se va a enterar de que estaba a punto de repetir 2020.', '// se va a enterar de que estaba a punto de repetir 2023.', 1),
 ('el `$set` de 2020 fue una acción deliberada', 'el `$set` de 2023 fue una acción deliberada', 1),
 ('entre el 1/06/2019 y\nel 1/08/2020.', 'entre el 1/01/2022 y\nel 1/03/2023.', 1),
 ('validado el 12 de marzo de 2020, que la pantalla de hoy', 'validado el 12 de octubre de 2022, que la pantalla de hoy', 1),
 ('El informe en PDF que se archivó en 2020 —y que existe', 'El informe en PDF que se archivó en 2022 —y que existe', 1),
 ('**El error ocurrió en 2020 y lo que ves hoy es su consecuencia**, cinco años después,', '**El error ocurrió en 2023 y lo que ves hoy es su consecuencia**, tres años después,', 1),
 ('Con el PDF de 2020 al lado de la pantalla de hoy.', 'Con el PDF de 2022 al lado de la pantalla de hoy.', 1),
 ('Ahora releé un resultado de 2019 validado contra la v2', 'Ahora releé un resultado de 2022 validado contra la v2', 1),
 ('*"la norma de 2020 bajó el límite porque el criterio clínico cambió; releer un resultado de 2019 con el criterio de hoy', '*"la norma de 2023 bajó el límite porque el criterio clínico cambió; releer un resultado de 2022 con el criterio de hoy', 1),
 ('si hay copias de seguridad de 2020 todavía disponibles.', 'si hay copias de seguridad de 2023 todavía disponibles.', 1),
 ('*"un paciente trajo su informe de 2020 y no coincide con lo que muestra el sistema"*', '*"un paciente trajo su informe de 2022 y no coincide con lo que muestra el sistema"*', 1),
 ('que el dato se perdió hace cinco años,', 'que el dato se perdió hace tres años,', 1),
 ('que quien ejecutó el `$set` en 2020 hizo lo que', 'que quien ejecutó el `$set` en 2023 hizo lo que', 1),
 ('si el `$set` de 2020 no dejó rastro en el código', 'si el `$set` de 2023 no dejó rastro en el código', 1),
]
for a_, b_, n in R:
    b6.rep(a_, b_, n)
b6.save()

cb = Archivo('cuaderno-incidentes-be.md')
cb.rep('tienen **`name`**, porque así se llamaba en el sistema de origen de la sede que\nentró en 2020 y el script de importación no tradujo el campo.',
       'tienen **`name`**, porque así se llamaba en el sistema de agenda del punto de\nGatineau que Andina compró en 2020, y el script de importación no tradujo el campo.')
n07 = cb.s.count("2020-07-31T23:59:59Z")
cb.rep("2020-07-31T23:59:59Z", "2023-02-28T23:59:59Z", n07)
n08 = cb.s.count("2020-08-01T00:00:00Z")
cb.rep("2020-08-01T00:00:00Z", "2023-03-01T00:00:00Z", n08)
cb.save()

b2 = Archivo('be02-medir-la-deriva-de-esquema.md')
b2.rep('**Y está en el script de importación que alguien corrió una vez en 2020**, cuando entró la sede que venía del sistema anterior.',
       '**Y está en el script de importación que alguien corrió una vez en 2020**, cuando Andina compró el punto de toma de Gatineau que traía a sus pacientes en el sistema de agenda de la clínica anterior.')
b2.save()

h = Archivo('00-historia-del-sistema.md')
h.rep('''puntos de toma en Ottawa y, por primera vez, cruzó el río: dos puntos en
Gatineau, uno de ellos en un barrio con mucha población latinoamericana.''','''puntos de toma en Ottawa y, por primera vez, cruzó el río: dos puntos en
Gatineau, uno de ellos en un barrio con mucha población latinoamericana. El otro
no se abrió: se compró. Era el punto de toma de una clínica privada que cerraba, y
llegó con su fichero de pacientes en el sistema de agenda de la clínica; un script
los pasó a LabCore una sola vez, y nadie volvió a mirar cómo.''')
h.save()

for rel, pairs in {
  'be00-el-contrato-auditoria-del-mock.md': [('En 2019, el mismo equipo contratado que escribió el frontend', 'En 2019, la misma consultora —Chaudière Conseils, con su equipo de San José— que escribió el frontend')],
  'be01-java-spring-y-la-forma-del-monolito.md': [('El equipo contratado arrancó en 2019 con lo que había', 'El equipo de la consultora arrancó en 2019 con lo que había')],
  'be08-la-contencion-y-lo-irrecuperable.md': [('Laboratorios Andina S.A.S. · Sistema de gestión de laboratorio clínico', 'Andina Laboratories Inc. · Laboratoires Andina · Sistema de gestión de laboratorio clínico')],
}.items():
    f = Archivo(rel)
    for a_, b_ in pairs: f.rep(a_, b_)
    f.save()

for rel in ['be07-la-subida-que-nadie-decidio.md', 'bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md', 'bea-10-riesgo-de-licencia-sspl.md', 'be08-la-contencion-y-lo-irrecuperable.md']:
    f = Archivo(rel)
    n = f.s.count('Laboratorios Andina')
    if n:
        f.rep('Laboratorios Andina', 'Andina Laboratories', n); f.save()
    print(n, rel)
