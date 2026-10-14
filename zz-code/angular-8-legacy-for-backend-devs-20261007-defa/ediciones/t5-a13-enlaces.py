# T5: A13's links to the sibling Docker course broke when the repo was grouped into families.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
a = Archivo('a13-docker-colima.md')
n = a.s.count('](../docker-container-legacy/')
a.rep('](../docker-container-legacy/', '](../../cursos-contenedores-cloud-infra/docker-container-legacy/', n)
a.save(); print(n, 'enlaces')
