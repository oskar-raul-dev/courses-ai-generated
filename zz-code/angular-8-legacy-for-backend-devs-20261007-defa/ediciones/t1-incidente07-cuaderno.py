# T1: incident 07 rewrite in the cuaderno (mechanism: v2 boundary loaded in UTC; thresholds v1 6.5 / v2 7.0).
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
c = Archivo('cuaderno-incidentes.md')
c.rep('''> *"Un potasio de 6.8 de un paciente de urgencias entró el sábado por la noche y
> nadie se enteró hasta el lunes a las siete.''','''> *"Un potasio de 6.8 de un paciente de urgencias entró el viernes 31 por la noche
> y nadie se enteró hasta el lunes a las siete.''')
c.rep('''Un `db.json` alterno: hace falta un resultado crítico tomado en el borde exacto
de una ventana de vigencia, un sábado por la noche. Es un dato, no un código.''','''Un `db.json` alterno: hace falta un resultado crítico tomado en el borde exacto
de una ventana de vigencia —la noche del 31 de diciembre de 2021, la última de la
v1— y una v2 cargada como la cargó el script de fines de 2021. Es un dato, no un
código.''')
c.rep('''En `America/Bogota` (UTC-5), cualquier hora local a partir de las 19:00 **ya es el
día siguiente en UTC**. La comparación de vigencia usa `.getTime()`, que compara
instantes absolutos. ¿De qué lado del borde cae un sábado a las 20:00?''','''Mira cómo está escrito cada borde, no qué día dice: uno lleva `-05:00` y otro
`Z`. En Ottawa, en invierno, la medianoche UTC son **las 19:00 del día anterior**.
La comparación de vigencia usa `.getTime()`, que compara instantes absolutos.
¿De qué lado del borde cae el viernes 31 a las 20:15?''')
c.rep('''notifique. El sistema marca el resultado crítico en rojo en una pantalla, y eso es
todo lo que hace. Si nadie abre esa pantalla, nadie se entera — y el sábado a las
nueve de la noche no hay nadie abriendo pantallas.

La respuesta a la coordinadora, entonces, es: **sí lo detectó, y no tenía forma de
avisar**. No es un fallo del sistema, es un hueco de alcance que lleva ahí desde
2019 y que nadie declaró nunca por escrito.''','''notifique. El sistema marca el resultado crítico en rojo en una pantalla, y eso es
todo lo que hace. Si nadie abre esa pantalla, nadie se entera — y un 31 de
diciembre a las nueve de la noche no hay nadie abriendo pantallas.

La respuesta a la coordinadora, entonces, tiene dos partes: **esta vez no lo
detectó** —es el hallazgo 2— **y, aunque lo hubiera detectado, no tenía forma de
avisar**. La segunda no es un fallo del sistema, es un hueco de alcance que lleva
ahí desde 2019 y que nadie declaró nunca por escrito.''')
c.between('''**Hallazgo 2 — Y además el veredicto estaba mal calculado.**''', '''> 🧬 Y el hallazgo que hay que anotar aparte, porque es peor:''', open(os.path.join(os.path.dirname(__file__), 't1-incidente07-hallazgo2.md'), encoding='utf-8').read())
c.between('''**Parche mínimo**

Para el hallazgo 2, forzar''', '''**Prevención**

Tres cosas, en orden de lo que cuestan:''', open(os.path.join(os.path.dirname(__file__), 't1-incidente07-parche.md'), encoding='utf-8').read())
c.rep('''1. **Un test por cada borde de vigencia que exista en los datos**, con la hora
   puesta a propósito en la franja de las 19:00 a las 23:59. Es el único horario
   en el que este bug vive.''','''1. **Un chequeo del dato, y un test por cada borde de vigencia**: ningún
   `effectiveFrom` ni `effectiveTo` termina en `Z`
   (`curl -s http://localhost:3000/referenceRanges | grep -c '[0-9]Z"'` tiene que
   dar 0), y cada borde se prueba con la hora puesta a propósito en la franja de
   las 19:00 a las 23:59. Es el único horario en el que este bug vive.''')
c.rep('''El bug de zona horaria llegó porque en 2019 no había en el proyecto ninguna
librería de zonas, `Date` de JavaScript parecía suficiente y la comparación de
instantes **es** la forma correcta de comparar instantes. El error no está en la
comparación: está en que uno de los dos lados no era un instante, era una fecha de
calendario escrita en hora local. Es el bug más difícil de ver de todo el curso
porque el código se lee bien.''','''El bug de zona horaria llegó porque a fines de 2021 la v2 la cargó un script que
armó los bordes con `new Date('2022-01-01').toISOString()` —que es medianoche UTC,
no de Ottawa—, nadie miró la letra final de la cadena, y la comparación de
instantes **es** la forma correcta de comparar instantes. El error no está en la
comparación: está en que uno de los dos lados no era el instante que la norma
decía. Es el bug más difícil de ver de todo el curso porque el código se lee bien
y el dato también, salvo por una `Z`.''')
c.rep('''- Si dijiste **"el umbral crítico está mal configurado"**, compruébalo y descarta:
  los `criticalLow`/`criticalHigh` están en el rango y son correctos en las dos
  versiones. Lo que cambió no fue el umbral, fue cuál de los dos se aplicó.''','''- Si dijiste **"el umbral crítico está mal configurado"**, compruébalo y descarta:
  el `criticalHigh` es 6.5 en la v1 y 7.0 en la v2, y los dos son correctos para
  su norma. Lo que cambió no fue el umbral, fue cuál de los dos se aplicó.''')
c.rep('''  coordinadora sigue sin enterarse el sábado que viene. Si te quedaste **sólo con''','''  coordinadora sigue sin enterarse el próximo fin de semana. Si te quedaste **sólo con''')
c.rep('''incidente(07): abre — resultados críticos sin alerta el sábado''','''incidente(07): abre — resultados críticos sin alerta el fin de semana''')
c.rep('alerta-del-sabado-roto', 'critico-de-nochevieja-roto')
c.rep('alerta-del-sabado-fix', 'critico-de-nochevieja-fix')
c.save()
