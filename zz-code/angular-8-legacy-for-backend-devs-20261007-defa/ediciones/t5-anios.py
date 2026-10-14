# T5 continuity: LabCore went live in September 2019 and "today" is September 2026 (be02's dump, be07, be08):
# seven years. The audit log dates from 2021 (five, as be04 says). Some texts said "seis años".
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
b3 = Archivo('bea-03-modelar-documentos-embeber-o-referenciar.md')
b3.rep('la bitácora de LabCore siga siendo consultable seis años después', 'la bitácora de LabCore siga siendo consultable cinco años después')
b3.rep('Y es exactamente lo que permitió, seis años después,', 'Y es exactamente lo que permitió, años después,')
b3.rep('LabCore es un sistema con seis años de preguntas imprevistas', 'LabCore es un sistema con siete años de preguntas imprevistas')
b3.save()
total = 0
for rel in ['01-estructura-base-ngrx.md', 'a07-i18n.md', 'cuaderno-incidentes.md', 'cuaderno-incidentes-be.md', 'be00-el-contrato-auditoria-del-mock.md',
            'be02-medir-la-deriva-de-esquema.md', 'be03-la-costura-y-el-reemplazo.md', 'be05-la-cadena-de-custodia-y-la-transaccion.md',
            'be08-la-contencion-y-lo-irrecuperable.md', 'bea-05-indices-y-explain-en-mongodb.md', 'bea-12-datos-de-prueba-y-volumen.md']:
    a = Archivo(rel)
    n = a.s.count('seis años')
    if n:
        a.rep('seis años', 'siete años', n); a.save(); total += n
    print(n, rel)
print(total, 'reemplazos')
