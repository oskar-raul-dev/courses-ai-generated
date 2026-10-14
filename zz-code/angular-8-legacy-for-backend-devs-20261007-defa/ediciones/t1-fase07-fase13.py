# T1: custody timeline shows times in the lab zone (appDate), and Fase 13 names its two real timeZone consumers.
import sys, os; sys.path.insert(0, os.path.dirname(__file__))
from rep import Archivo
s = Archivo('07-muestras-custodia.md')
s.rep('''import * as SamplesActions from '../store/samples.actions';
import * as SamplesSelectors from '../store/samples.selectors';
import { SAMPLE_TRANSITIONS, canTransition } from '../store/sample.transitions';

@Component({
  selector: 'app-sample-timeline',''','''import * as SamplesActions from '../store/samples.actions';
import * as SamplesSelectors from '../store/samples.selectors';
import { SAMPLE_TRANSITIONS, canTransition } from '../store/sample.transitions';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'app-sample-timeline',''')
s.rep('''  orderId: number = null;
  samples: any[] = [];
  loading = false;
''','''  orderId: number = null;
  samples: any[] = [];
  loading = false;

  // Las horas de custodia son evidencia de auditoría: se muestran en la hora
  // del laboratorio, no en la del navegador. Mismo campo y mismo pipe que la
  // lista de pacientes de la Fase 2 (appDate, §5.10 de aquella).
  timeZone: string = environment.timeZone;
''')
s.rep('''      — {{ event.by }} — {{ event.at | date:'short' }}''','''      — {{ event.by }} — {{ event.at | appDate:'short':timeZone }}''')
s.save()
t = Archivo('13-build-despliegue.md')
t.rep('''export APP_TIME_ZONE="${APP_TIME_ZONE:-America/Bogota}"''','''export APP_TIME_ZONE="${APP_TIME_ZONE:-America/Toronto}"''')
t.rep('''Y hay un rezagado que no es un servicio y que por eso se escapa de esa lista: **`environment.timeZone`**, que la Fase 2 §5.9 puso para el `DatePipe` de la lista de pacientes y la Fase 9 §5.1 usa para formatear la fecha del PDF.''','''Y hay un rezagado que no es un servicio y que por eso se escapa de esa lista: **`environment.timeZone`**, que la Fase 2 §5.9 puso para el pipe `appDate`, que la línea de custodia de la Fase 7 §5.8 usa para mostrar sus horas y que la Fase 9 §5.1 usa para formatear la fecha del PDF.''')
t.rep('''13. `timeZone` ya está en el `config.json` (§5.2 y §5.3), pero sus dos consumidores siguen leyendo `environment.timeZone`: el `PatientListComponent` de la Fase 2 §5.9 y el `ReportService` de la Fase 9 §5.1. Migra los dos a `AppConfigService` y después levanta el contenedor con `-e APP_TIME_ZONE=America/Mexico_City`: la fecha de una orden emitida a las 23:40 tiene que cambiar de día.''','''13. `timeZone` ya está en el `config.json` (§5.2 y §5.3), pero sus dos consumidores siguen leyendo `environment.timeZone`: el `SampleTimelineComponent` de la Fase 7 §5.8 y el `ReportService` de la Fase 9 §5.1. (La lista de pacientes de la Fase 2 §5.9 también lo leía, pero esa tarjeta desapareció cuando la Fase 5 reescribió la lista.) Migra los dos a `AppConfigService` y después levanta el contenedor con `-e APP_TIME_ZONE=America/Vancouver`: una custodia y una validación hechas a la 01:30 hora de Ottawa tienen que mostrarse el día anterior, a las 22:30, en la línea de custodia y en el PDF.''')
t.save()
