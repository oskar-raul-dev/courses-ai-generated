import { AsyncPipe, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, DestroyRef, OnInit, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatPaginatorModule, PageEvent } from '@angular/material/paginator';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatTableModule } from '@angular/material/table';
import { RouterLink } from '@angular/router';
import { BehaviorSubject, Observable, combineLatest, filter, map, switchMap } from 'rxjs';

import { ApiError } from '../../../core/api/api-error';
import { ClientStateService } from '../../../core/state/client-state.service';
import { Client } from '../../../core/models/client.model';
import {
  ConfirmDialogComponent,
  ConfirmDialogData,
} from '../../../shared/confirm-dialog/confirm-dialog.component';
import { EmptyStateComponent } from '../../../shared/empty-state/empty-state.component';
import { CLIENT_LIST_PAGE_SIZE } from '../client-list-page-size.token';

/** Lo que la plantilla necesita, ya calculado. Ni un cálculo en el HTML. */
interface ClientListView {
  readonly visible: readonly Client[];
  readonly total: number;
  readonly loading: boolean;
  readonly error: string | null;
}

@Component({
  selector: 'cc-client-list',
  standalone: true,
  imports: [
    AsyncPipe,
    NgIf,
    ReactiveFormsModule,
    RouterLink,
    MatButtonModule,
    MatDialogModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatPaginatorModule,
    MatProgressSpinnerModule,
    // MatDialogModule y MatSnackBarModule no aportan ninguna directiva a esta
    // plantilla: están aquí por los servicios MatDialog y MatSnackBar que el
    // componente inyecta arriba. Pruébalo quitando uno de los dos imports:
    // si el inject() sigue funcionando, el import sobraba; si falla con
    // NullInjectorError, es el que lo provee. Es el caso que la Fase
    // 5 §4 anunciaba: importar un NgModule desde un standalone también trae sus
    // providers.
    MatSnackBarModule,
    MatTableModule,
    EmptyStateComponent,
  ],
  templateUrl: './client-list.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ClientListComponent implements OnInit {
  private readonly clientState = inject(ClientStateService);
  private readonly dialog = inject(MatDialog);
  private readonly snackBar = inject(MatSnackBar);
  // DestroyRef explícito: takeUntilDestroyed() sin argumento sólo funciona en
  // contexto de inyección —campos y constructor—, y abajo se usa dentro de un
  // método. Guardarlo aquí es lo que lo hace legal allí. Ver A06.
  private readonly destroyRef = inject(DestroyRef);

  readonly pageSize = inject(CLIENT_LIST_PAGE_SIZE);

  readonly displayedColumns: readonly string[] = ['legalName', 'taxId', 'actions'];

  /**
   * El buscador. nonNullable porque "sin texto" es la cadena vacía, no null:
   * un buscador vacío busca todo, no busca nada.
   */
  readonly searchControl = new FormControl<string>('', { nonNullable: true });

  private readonly pageSubject = new BehaviorSubject<PageEvent | null>(null);

  readonly view$: Observable<ClientListView> = combineLatest([
    this.clientState.state$,
    this.pageSubject,
  ]).pipe(
    map(([state, page]) => {
      const size = page?.pageSize ?? this.pageSize;
      const start = (page?.pageIndex ?? 0) * size;

      return {
        // slice() devuelve un array nuevo y no toca el original: con el estado
        // readonly de 5.2 es la única forma que compila, y no por casualidad.
        visible: state.items.slice(start, start + size),
        total: state.items.length,
        loading: state.loading,
        error: state.error,
      };
    }),
  );

  ngOnInit(): void {
    // El componente no decide cuándo pedir ni cuánto esperar: sólo cuenta lo
    // que el usuario escribió. El debounce y la cancelación viven en el servicio.
    this.searchControl.valueChanges
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe((term) => this.clientState.search(term));

    this.clientState.reload();
  }

  onPage(event: PageEvent): void {
    this.pageSubject.next(event);
  }

  confirmRemove(client: Client): void {
    const data: ConfirmDialogData = {
      title: 'Eliminar cliente',
      message: `¿Eliminar a ${client.legalName}? Esta acción no se puede deshacer.`,
      confirmLabel: 'Eliminar',
    };

    this.dialog
      .open<ConfirmDialogComponent, ConfirmDialogData, boolean>(ConfirmDialogComponent, { data })
      .afterClosed()
      .pipe(
        // afterClosed() emite `undefined` si el usuario cerró con Escape o
        // pulsando fuera. El type guard descarta ese caso y de paso estrecha
        // el tipo, que es lo que hace innecesario un `!` más abajo.
        filter((confirmed): confirmed is true => confirmed === true),
        switchMap(() => this.clientState.remove(client)),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe({
        next: () => this.snackBar.open('Cliente eliminado.', 'Cerrar', { duration: 4000 }),
        error: (error: unknown) =>
          this.snackBar.open(
            error instanceof ApiError ? error.message : 'No se pudo eliminar el cliente.',
            'Cerrar',
            { duration: 6000 },
          ),
      });
  }
}
