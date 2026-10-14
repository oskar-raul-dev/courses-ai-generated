# T2 (D9): CAD with two decimals in A07 §6, and the PDF date in 'es' (the LOCALE_ID of Fase 02).
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
a = Archivo('a07-i18n.md')
a.rep("{{ order.total | currency:'COP':'symbol-narrow':'1.0-0' }}",
      "{{ order.total | currency:'CAD':'symbol-narrow':'1.2-2' }}   <!-- es: 1.234,50 $   en: $1,234.50   fr: 1 234,50 $ -->")
a.save()
p = Archivo('09-entrega-pdf.md')
p.rep("return new Date(iso).toLocaleString('es-CO', { timeZone: environment.timeZone });",
      "return new Date(iso).toLocaleString('es', { timeZone: environment.timeZone });")
p.save()
