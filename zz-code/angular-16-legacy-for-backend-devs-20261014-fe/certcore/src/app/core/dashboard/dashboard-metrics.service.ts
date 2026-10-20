import { Injectable, inject } from '@angular/core';
import { Observable, combineLatest, map, shareReplay, switchMap, tap, timer } from 'rxjs';

import { FindingApiService } from '../api/finding-api.service';
import {
  DashboardMetrics,
  assetsWithoutCoverage,
  bucketCertificates,
  rejectionByInspector,
  topFindingItems,
} from '../domain/dashboard-metrics';
import { deriveAllFindings, flattenFindings } from '../domain/derive-all-findings';
import { AssetStateService } from '../state/asset-state.service';
import { CertificateStateService } from '../state/certificate-state.service';
import { InspectionStateService } from '../state/inspection-state.service';
import { TemplateStateService } from '../state/template-state.service';
import { nowInstant } from '../time/business-day';

/**
 * Cada cuánto se refresca el panel. Constante exportada por la misma razón que
 * `AUTOSAVE_DEBOUNCE_MS` de la Fase 8: la Fase 12 lo va a testear con
 * `fakeAsync` y `tick`, y un número mágico dentro de un `pipe` no se puede
 * testear sin copiarlo.
 *
 * Un minuto y no cinco segundos: los datos de este panel cambian a ritmo de
 * jornada laboral, no de bolsa de valores. Refrescar más seguido no informa
 * mejor, sólo multiplica peticiones y hace que el gráfico parpadee.
 */
export const DASHBOARD_REFRESH_MS = 60_000;

/** Cuántos ítems entran en el ranking de hallazgos. Diez cabe en pantalla. */
const TOP_FINDINGS_LIMIT = 10;

/**
 * ⚠️ Se llama `MetricsService` y NO `MetricsStateService`, y la diferencia no
 * es de gusto. La convención de la guía §5.3 reserva el sufijo `StateService`
 * para lo que GUARDA estado; esto no guarda nada: deriva de los cuatro
 * servicios que sí lo hacen. No hay ni un `BehaviorSubject` en este archivo, y
 * el nombre es lo que impide que aparezca uno dentro de tres meses porque "así
 * carga más rápido".
 */
@Injectable({ providedIn: 'root' })
export class DashboardMetricsService {
  private readonly inspectionState = inject(InspectionStateService);
  private readonly templateState = inject(TemplateStateService);
  private readonly certificateState = inject(CertificateStateService);
  private readonly assetState = inject(AssetStateService);
  private readonly findingApi = inject(FindingApiService);

  /**
   * El latido. Recarga las cuatro colecciones y trae los hallazgos guardados,
   * que son los únicos que no tienen servicio de estado — y no lo tienen a
   * propósito: la Fase 9 decidió que los hallazgos se derivan, así que guardar
   * un estado de hallazgos sería exactamente lo que aquella fase evitó.
   */
  private readonly heartbeat$ = timer(0, DASHBOARD_REFRESH_MS).pipe(
    tap(() => {
      // Los `load()` son efectos: cada servicio actualiza su propio sujeto y
      // sus Observables emiten solos. Este servicio no espera respuestas ni
      // las encadena; sólo dice "es hora de refrescar".
      this.inspectionState.load();
      this.templateState.load();
      this.certificateState.load();
      this.assetState.load();
    }),
    switchMap(() => this.findingApi.getAll()),
  );

  readonly metrics$: Observable<DashboardMetrics> = combineLatest([
    this.heartbeat$,
    this.inspectionState.inspections$,
    // `TemplateState` no es `FeatureState<T>` —la Fase 7 rompió el molde a
    // propósito— así que las versiones se sacan de su `state$`. Se mapea aquí
    // en vez de añadir un `versions$` a aquel servicio: el panel es el único
    // que las quiere planas, y una API pública nueva por un solo consumidor es
    // deuda barata de crear y cara de quitar.
    this.templateState.state$.pipe(map((state) => state.versions)),
    this.certificateState.state$.pipe(map((state) => state.items)),
    this.assetState.assets$,
  ]).pipe(
    map(([stored, inspections, versions, certificates, assets]) => {
      // El instante se toma UNA vez por cálculo, por la puerta al reloj de la
      // Fase 10, y se pasa a las cuatro funciones puras. Si cada una leyera el
      // reloj por su cuenta, dos KPI del mismo panel podrían estar calculados
      // con relojes distintos — improbable, y suficiente para que a las
      // 23:59:59 una tarjeta diga hoy y la de al lado diga mañana.
      const now = nowInstant();
      const derived = deriveAllFindings(inspections, versions, stored);
      const findings = flattenFindings(derived);

      return {
        generatedAt: now,
        buckets: bucketCertificates(certificates, now),
        inspectorRates: rejectionByInspector(inspections),
        topFindings: topFindingItems(findings, versions, TOP_FINDINGS_LIMIT),
        coverage: assetsWithoutCoverage(assets, inspections, certificates, now),
        openCriticalCount: findings.filter(
          (finding) =>
            finding.kind === 'item' && finding.severity === 'critical' && finding.resolvedAt === null,
        ).length,
        inProgressCount: inspections.filter((inspection) => inspection.status === 'in_progress')
          .length,
      };
    }),
    /**
     * ⚠️ `refCount: true`, Y ES LA LÍNEA MÁS IMPORTANTE DEL ARCHIVO.
     *
     * `shareReplay` sirve para que los ocho suscriptores de la plantilla
     * compartan un solo cálculo en vez de hacer ocho. Sin `refCount`, la
     * suscripción interna NUNCA muere: el `timer` de `heartbeat$` sigue
     * disparando cada minuto para siempre, aunque el usuario se haya ido del
     * panel hace cuatro horas. Cinco peticiones por minuto durante una jornada
     * son dos mil cuatrocientas peticiones que nadie mira.
     *
     * Con `refCount`, cuando el último suscriptor se va —el `async` pipe se
     * desuscribe al destruirse el componente— la fuente se cancela y el timer
     * muere con ella. Es el incidente 16, y es la lección de la Fase 4 con
     * consecuencias medibles en la pestaña de red.
     */
    shareReplay({ bufferSize: 1, refCount: true }),
  );
}
