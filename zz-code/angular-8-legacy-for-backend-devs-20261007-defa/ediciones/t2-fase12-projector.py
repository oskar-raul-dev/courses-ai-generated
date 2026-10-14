# T2: the Fase 12 selector spec passed state.items to a projector that receives the PatientsState.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
a = Archivo('12-testing-coverage.md')
a.rep("PatientsSelectors.selectAllPatients.projector(state.items)", "PatientsSelectors.selectAllPatients.projector(state)", count=3)
a.save()
