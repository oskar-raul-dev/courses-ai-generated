# 👥 Fase 06 — Clientes y activos

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 6 de 14 · **8 horas**
> Depende de: Fase 5 (standalone conviviendo con NgModules) · Habilita: Fases 7 a 11
> Apéndices de apoyo: [A01 (Angular Material 16)](a01-material.md) · [A05 (Formularios reactivos tipados)](a05-formularios-tipados.md)
> [Incidentes asociados](cuaderno-incidentes.md): 07
> Estilo de esta fase: **nuevo** en todo lo que se crea; toca dos archivos heredados de refilón 🧬

---

## 🎯 1. Propósito

Cinco fases construyendo fontanería y ni una sola pantalla donde alguien pueda escribir algo. Hoy se acaba: vas a montar el primer CRUD completo del curso —clientes y sus activos— con formularios reactivos tipados, Material 16 y el servicio de estado de la Fase 4 haciendo por fin el trabajo para el que se escribió.

No es una fase de "aprender formularios". Es la fase donde todo lo que decidiste en frío se cobra o se paga: el `OnPush` que la Fase 5 puso por costumbre va a dejar de repintar una lista y vas a tener que entender por qué; el `items: T[]` mutable que la Fase 4 dejó a propósito va a ser exactamente la causa; y el `nonNullable` que nadie puso en el login de 2022 va a ahorrarte hoy una guarda que allí era obligatoria.

Y aquí nace la deuda 💸 que te va a acompañar tres fases: una regla de negocio escrita en un componente porque había prisa. Va marcada, va explicada, y la Fase 9 la va a cobrar.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `/clients` lista los clientes en una `mat-table` con buscador y paginador, y el buscador **cancela** la petición anterior: con `CHAOS=latency` escribes rápido y sólo llega una respuesta, la última que pediste.
- [ ] `/clients/new` y `/clients/:id/edit` dan de alta y editan con validación; un `taxId` repetido se marca en rojo **antes** de que pulses guardar.
- [ ] Borrar un cliente pide confirmación en un diálogo, y borrar uno que tiene activos **falla con un mensaje que dice cuántos**.
- [ ] `/assets` lista los activos y permite crear y editar, con la pantalla nueva alojada dentro de `AssetsModule`, que sigue siendo un `NgModule` de 2021 🧬.
- [ ] `FeatureState<T>` expone `readonly items: readonly T[]`, y el intento de ordenar la lista en sitio **no compila**. La 💸 de la Fase 4 queda saldada.
- [ ] El tema de Material está compilado en `styles.scss` con densidad −1, y el prefabricado de la Fase 1 ya no se enlaza en `angular.json`.
- [ ] Reprodujiste el ticket "no me deja guardar y no dice por qué" y localizaste el control inválido sin tocar el código.
- [ ] `git tag` lista `fase-06`.

---

## 🚫 3. Qué NO entra todavía

- **Plantillas, inspecciones, hallazgos y certificados** → Fases 7 a 10. Hoy sólo existen el cliente y su activo, que son las dos entidades de las que cuelga todo lo demás.
- **Trazabilidad de los cambios** —quién editó qué cliente y cuándo— → **se difiere y se declara**: CertCore la tiene en la vida real y este curso no la construye. Aparecería como una colección `audit` en el mock y un interceptor que la alimenta; hay una nota en los 📌 con el porqué de dejarla fuera.
- **Borrado de activos** → no entra nunca, y no es un recorte: un activo con inspecciones y certificados detrás no se borra, se da de baja. La sección 5.10 lo explica en dos líneas.
- **Paginación en el servidor** → hoy se pagina en el cliente sobre una lista de tres. `_page` y `_limit` de json-server son el ejercicio 27.
- **`mat-sort`** → ejercicio 12. La tabla se ordena en el servicio o no se ordena.
- **Signals y control flow nuevo** → Fase 12 y **A11**, como siempre.

---

## 🧠 4. Concepto mínimo

### El problema, antes que la herramienta

Un formulario de alta de cliente tiene dos campos. Parece que no hay nada que decidir, y hay tres cosas.

La primera: **qué significa que un campo esté vacío.** En el login de la Fase 2 el correo se tipó como `FormControl<string | null>` y eso obligó a escribir una guarda —`if (email === null) return;`— que no puede dispararse nunca. Aquella guarda no era paranoia: era el precio de no haber decidido la nulabilidad. Aquí se decide antes de escribir la primera línea, y la guarda desaparece.

La segunda: **quién dice que un NIT no está repetido.** El navegador no lo sabe; sólo el servidor lo sabe. Y preguntárselo en cada tecla es tan malo como no preguntárselo nunca.

La tercera, la que produce el bug del día: **cuándo se entera la pantalla de que la lista cambió.** Con `OnPush` puesto —y la Fase 5 lo puso en todo lo nuevo— la respuesta deja de ser "siempre" y pasa a ser "cuando cambia una referencia". Un `push` sobre el array del estado no cambia ninguna referencia. La lista se queda como estaba y el dato ya no.

### `FormGroup<T>`: el tipo primero, el formulario después

Angular 14 hizo genéricos los formularios reactivos. La forma de usarlos bien es escribir el tipo del formulario como una interfaz de `FormControl`s y pasárselo al `FormGroup`:

```ts
interface ClientForm {
  legalName: FormControl<string>;
  taxId: FormControl<string>;
}
```

Fíjate en lo que **no** dice: no dice `string | null`. Eso obliga a que cada control se cree con `nonNullable: true`, y a cambio te devuelve dos cosas. `getRawValue()` te da un objeto con los tipos que declaraste, sin uniones con `null` que estrechar. Y `reset()` vuelve al valor inicial en vez de dejar el control en `null`, que es lo que un usuario espera de un botón que dice "Limpiar".

> 🧭 **Regla del proyecto: la nulabilidad de un control se decide al escribirlo, no al usarlo.** Si el campo tiene siempre un valor —aunque sea la cadena vacía—, va `nonNullable: true`. Si `null` significa algo de verdad —"todavía no se eligió fecha de baja"—, va sin `nonNullable` y el tipo lo dice. Lo que no se admite es un `| null` heredado de la migración que nadie decidió.

El tratamiento completo —`FormBuilder` tipado, `FormArray<T>`, formularios construidos en runtime— vive en **A05**, y la Fase 8 lo va a exprimir. Hoy sólo hace falta esto.

### La validación asíncrona, y por qué no es un `subscribe` disfrazado

Un validador asíncrono es una función que recibe el control y devuelve un `Observable` que emite **una vez** y completa: `null` si el valor es válido, un objeto de errores si no. Angular pone el control en estado `pending` mientras tanto, y `form.invalid` es `false` durante ese rato — detalle que causa el bug de "guardó igual" si el botón sólo mira `invalid`.

Tres cosas hay que hacerle siempre, y las tres se olvidan:

**Esperar.** Sin un `timer` o un `debounceTime` delante, cada tecla es una petición. Con tres clientes no se nota; con un endpoint real y un NIT de nueve dígitos son nueve peticiones por campo.

**Completar.** Si el observable no completa, el control se queda `pending` para siempre y el formulario nunca es válido. Por eso lleva `first()` al final.

**No invalidar por un fallo de red.** Si el servidor no responde, el usuario no tiene la culpa: el validador devuelve `null` y deja que el error salga al guardar, que es donde sí se puede explicar.

### `OnPush`, y las cuatro cosas que lo despiertan

Con `ChangeDetectionStrategy.Default`, Angular revisa el componente ante cualquier evento de cualquier parte de la aplicación. Con `OnPush`, sólo lo revisa cuando pasa una de cuatro cosas: **cambia la referencia de un `@Input`**, **se dispara un evento dentro de su propia plantilla**, **emite un observable conectado con el pipe `async`**, o **alguien llama a `markForCheck()`** a mano.

Ninguna de las cuatro incluye "alguien mutó un array que el componente ya tenía". Y ahí está la 💸 de la Fase 4 esperándote: `FeatureState<T>` expone `items: T[]`, cualquiera puede hacerle `sort()` o `push()`, la referencia no cambia, nadie emite, y la vista se queda mintiendo. En la sección 5.2 vas a verlo, con la variante cruel: **la pantalla heredada de activos, que no tiene `OnPush`, se refresca igual** — así que el mismo bug se ve en una pantalla y no en la otra, y quien lo reporte va a jurar que es cosa de clientes.

> 📝 **Nota de migración: Material 15 cambió de motor y `mat-form-field` no es el mismo.** CertCore migró a Material 16 durante 2024 y con él llegó MDC (Material Design Components), que reescribió por dentro casi todos los componentes manteniendo los mismos nombres. Consecuencias que vas a tocar hoy: `appearance="legacy"` y `"standard"` ya no existen —sólo quedan `fill` y `outline`—, el `mat-error` **tiene que estar dentro** del `mat-form-field` o no se pinta, y la altura por defecto de los campos creció, que es la razón de la densidad −1 de 5.1. Cualquier ejemplo de formularios de Material anterior a 2023 está describiendo el componente viejo con el nombre nuevo. El aviso permanente y el detalle están en **A01**.

---

## 💻 5. Código mínimo con comentarios

### 5.1 El tema de Material, fijado de una vez

La Fase 1 aceptó el tema prefabricado que ofrece el schematic. Sirvió para cinco fases y hoy se retira 🪦: un prefabricado no se puede ajustar, y esta aplicación es de tablas y formularios densos, donde la altura por defecto de MDC desperdicia media pantalla.

```scss
// src/styles.scss
@use '@angular/material' as mat;

// mat.core() va una sola vez en todo el proyecto: trae los estilos base que
// comparten todos los componentes. Repetirlo duplica CSS sin avisar.
@include mat.core();

// Se mantienen Indigo y Pink, que son las de la Fase 1: cambiar la marca de
// color no aporta nada al curso y obligaría a rehacer cualquier captura.
$certcore-primary: mat.define-palette(mat.$indigo-palette);
$certcore-accent: mat.define-palette(mat.$pink-palette, A200, A100, A400);
$certcore-warn: mat.define-palette(mat.$red-palette);

$certcore-theme: mat.define-light-theme(
  (
    color: (
      primary: $certcore-primary,
      accent: $certcore-accent,
      warn: $certcore-warn,
    ),
    typography: mat.define-typography-config(),
    // Densidad −1: una muesca más compacto que el valor de fábrica. Con 0, un
    // formulario de seis campos no cabe en una pantalla de portátil. Con −2 se
    // gana espacio y se pierde área táctil, que en tablet en campo importa.
    density: -1,
  )
);

@include mat.all-component-themes($certcore-theme);
```

```jsonc
// angular.json → …architect.build.options.styles
{
  "styles": [
    // Fuera el prefabricado que puso el schematic en la Fase 1: el tema ahora
    // se compila desde styles.scss y tener los dos gana el que cargue último.
    // "@angular/material/prebuilt-themes/indigo-pink.css",
    "src/styles.scss"
  ]
}
```

**Detalles con intención**

- **Esto queda cerrado hoy.** Ninguna fase posterior toca paleta, tipografía ni densidad. Si la Fase 11 quiere un color para "certificado por vencer", sale de `warn` o de una clase propia, no de una paleta nueva.
- **`all-component-themes` y no los mixins uno a uno.** Genera CSS para componentes que quizá no uses, y a cambio no vuelve a fallar nunca cuando alguien añada un componente en la Fase 10. Cuando el CSS pese —y en la Fase 13 se mide— el ejercicio 28 compara las dos formas con números.

### 5.2 💸 El pago: el estado deja de ser mutable

La Fase 4 dejó esto escrito, a propósito, con su factura a nombre de hoy:

```ts
// ANTES — Fase 4
export interface FeatureState<T> {
  items: T[];            // 💸 mutable, y la referencia nunca cambia
  selected: T | null;
  loading: boolean;
  error: string | null;
}
```

**Primero el daño, que es lo que justifica el arreglo.** Escribe esto en el listado de clientes y pulsa el botón:

```ts
// El botón "Ordenar por NIT" que parece inocente
sortByTaxId(state: FeatureState<Client>): void {
  // sort() ordena EN SITIO y devuelve el mismo array. La referencia no cambia,
  // el BehaviorSubject no emite, y con OnPush la tabla no se entera de nada.
  state.items.sort((a, b) => a.taxId.localeCompare(b.taxId));
}
```

La tabla no se mueve. Y si abres la consola y miras el estado, **los datos sí están ordenados**: el modelo dice una cosa y la pantalla dice otra. Ahora ve a la pantalla de activos —heredada, sin `OnPush`— y haz lo mismo: **ahí sí se reordena**, porque la detección de cambios por defecto revisa la vista ante cualquier evento y se encuentra el array ya ordenado. Mismo bug, dos comportamientos. Es la clase de reporte que llega como *"lo de clientes está roto"* y hace perder una tarde buscando en el sitio equivocado.

**Ahora el arreglo:**

```ts
// src/app/core/state/feature-state.model.ts
/**
 * 🪦 LA DEUDA DE LA FASE 4, PAGADA
 * `readonly items: readonly T[]` cierra la casa entera: los *ApiService ya
 * devolvían `readonly T[]` desde la Fase 3, y ahora el dato sigue siendo
 * inmutable de la puerta para adentro. El compilador rechaza push, splice y
 * sort, que son las tres formas de romper OnPush sin darse cuenta.
 *
 * `readonly` en la propiedad además de en el array: lo primero impide
 * reasignar `state.items = otra`, lo segundo impide mutar la que hay. Faltando
 * cualquiera de los dos, la puerta queda entornada.
 */
export interface FeatureState<T> {
  readonly items: readonly T[];
  readonly selected: T | null;
  readonly loading: boolean;
  readonly error: string | null;
}

export function createInitialState<T>(): FeatureState<T> {
  return { items: [], selected: null, loading: false, error: null };
}
```

Y el botón se escribe como debía:

```ts
// Copiar y ordenar la copia. Referencia nueva, emisión nueva, tabla repintada.
// Es una línea más y es la línea que hace que OnPush signifique algo.
sortByTaxId(items: readonly Client[]): readonly Client[] {
  return [...items].sort((a, b) => a.taxId.localeCompare(b.taxId));
}
```

**El patrón a memorizar**

> Con `OnPush`, mutar es no hacer nada. Si después de tu cambio `oldItems === newItems` sigue siendo cierto, no ha pasado nada para nadie que estuviera mirando — y el modelo te va a dar la razón mientras la pantalla te la quita.

### 5.3 🧬 El daño colateral del pago

Cambiar un tipo compartido rompe la compilación de todo lo que lo usa, y eso es una virtud: el compilador te está entregando la lista exacta de los sitios donde la deuda vivía. Son dos.

```ts
// src/app/core/state/template-state.service.ts — sólo la línea que cambia
// ANTES: this.patch({ items: [...templates], loading: false });
//   La copia estaba ahí para convertir un readonly array en uno mutable, o
//   sea: para deshacer justo la protección que traía.
this.patch({ items: templates, loading: false });
```

```html
<!-- src/app/features/templates/template-list/template-list.component.html -->
<!-- Sin cambios. El pipe async y *ngFor leen; leer nunca fue el problema. -->
```

**Detalles con intención**

- **`TemplateStateService` es un archivo nuevo (2024) y se toca en estilo nuevo.** No lleva ninguna otra modificación de paso, aunque haya tentaciones: pagar una deuda es un commit que hace una sola cosa.
- **`TemplateListComponent` es heredado y no se toca en absoluto.** Que el pago de una deuda no obligue a tocar el código viejo es la mejor señal de que la deuda estaba bien localizada.

**Prueba de fuego**

Corre `ng build` justo después de cambiar la interfaz y **antes** de arreglar nada. Los errores que salgan son el mapa completo de la deuda: cada uno es un sitio donde alguien podía haber mutado el estado. Cuéntalos y anótalos en `deuda.md` junto a los números de la Fase 5. Ese número —*"la deuda vivía en N sitios"*— es el que se lleva a una reunión, no la explicación.

### 5.4 `ClientApiService` aprende a escribir

```ts
// src/app/core/api/client-api.service.ts — lo que se añade
import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError, map } from 'rxjs';

import { environment } from '../../../environments/environment';
import { Client } from '../models/client.model';
import { toApiError } from './api-error';

/** Un cliente todavía sin `id`: lo asigna el servidor al crearlo. */
export type ClientDraft = Omit<Client, 'id'>;

@Injectable({ providedIn: 'root' })
export class ClientApiService {
  private readonly http = inject(HttpClient);

  private readonly baseUrl = `${environment.apiBaseUrl}/clients`;

  // …getAll() y getById() siguen igual que en la Fase 3…

  /**
   * Búsqueda por razón social. json-server implementa `q` como búsqueda de
   * texto completo sobre todos los campos del recurso, así que buscar "900"
   * también encuentra por NIT — y eso es exactamente lo que un usuario espera
   * de una caja de búsqueda, así que se deja.
   */
  search(term: string): Observable<readonly Client[]> {
    const trimmed = term.trim();
    const params = trimmed === '' ? new HttpParams() : new HttpParams().set('q', trimmed);

    return this.http
      .get<readonly Client[]>(this.baseUrl, { params })
      .pipe(catchError(toApiError));
  }

  create(draft: ClientDraft): Observable<Client> {
    return this.http.post<Client>(this.baseUrl, draft).pipe(catchError(toApiError));
  }

  update(client: Client): Observable<Client> {
    // PUT y no PATCH: el formulario manda la entidad entera, así que reemplazar
    // es honesto. Un PATCH con el objeto completo miente sobre la intención.
    return this.http
      .put<Client>(`${this.baseUrl}/${client.id}`, client)
      .pipe(catchError(toApiError));
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${id}`).pipe(catchError(toApiError));
  }

  /**
   * ¿Existe ya este NIT? `exceptId` es el cliente que se está editando: sin él,
   * editar la razón social de un cliente daría "NIT repetido" contra sí mismo,
   * que es el bug número uno de los validadores de unicidad.
   */
  existsByTaxId(taxId: string, exceptId: number | null): Observable<boolean> {
    const params = new HttpParams().set('taxId', taxId);

    return this.http.get<readonly Client[]>(this.baseUrl, { params }).pipe(
      map((matches) => matches.some((client) => client.id !== exceptId)),
      catchError(toApiError),
    );
  }
}
```

### 5.5 `ClientStateService`: el molde de la Fase 4, con trabajo de verdad

Aquí se resuelven los dos límites que la Fase 4 dejó abiertos a propósito: las cargas concurrentes que no se ordenan y el `loading` que se queda mal cuando hay dos peticiones en vuelo.

```ts
// src/app/core/state/client-state.service.ts
import { Injectable, inject } from '@angular/core';
import {
  BehaviorSubject,
  EMPTY,
  Observable,
  Subject,
  catchError,
  combineLatest,
  debounceTime,
  distinctUntilChanged,
  filter,
  map,
  startWith,
  switchMap,
  tap,
  throwError,
} from 'rxjs';

import { ApiError } from '../api/api-error';
import { AssetApiService } from '../api/asset-api.service';
import { ClientApiService, ClientDraft } from '../api/client-api.service';
import { AuthService } from '../auth.service';
import { Client } from '../models/client.model';
import { FeatureState, createInitialState } from './feature-state.model';

@Injectable({ providedIn: 'root' })
export class ClientStateService {
  private readonly clientApi = inject(ClientApiService);
  private readonly assetApi = inject(AssetApiService);
  private readonly authService = inject(AuthService);

  private readonly stateSubject = new BehaviorSubject<FeatureState<Client>>(
    createInitialState<Client>(),
  );

  readonly state$: Observable<FeatureState<Client>> = this.stateSubject.asObservable();

  readonly clients$ = this.state$.pipe(map((state) => state.items), distinctUntilChanged());
  readonly selected$ = this.state$.pipe(map((state) => state.selected), distinctUntilChanged());
  readonly loading$ = this.state$.pipe(map((state) => state.loading), distinctUntilChanged());
  readonly error$ = this.state$.pipe(map((state) => state.error), distinctUntilChanged());

  /** El criterio de búsqueda vigente. Es estado de la feature, no del componente. */
  private readonly criteriaSubject = new BehaviorSubject<string>('');
  readonly criteria$ = this.criteriaSubject.asObservable();

  /** Un disparo manual para releer sin cambiar el criterio. */
  private readonly reloadSubject = new Subject<void>();

  constructor() {
    // El reseteo al cerrar sesión, igual que en TemplateStateService: dos
    // servicios raíz, nadie sobrevive a nadie, nadie se desuscribe. Fase 4 §5.6.
    this.authService.currentUser$
      .pipe(filter((user) => user === null))
      .subscribe(() => this.reset());

    combineLatest([
      // debounceTime + distinctUntilChanged: el usuario escribe "Central" y
      // sale UNA petición, no siete. distinctUntilChanged además ignora el
      // teclazo que borra y reescribe la misma letra.
      this.criteriaSubject.pipe(debounceTime(300), distinctUntilChanged()),
      this.reloadSubject.pipe(startWith(undefined)),
    ])
      .pipe(
        tap(() => this.patch({ loading: true, error: null })),
        // ⭐ switchMap es lo que arregla los dos límites de la Fase 4: al llegar
        // un criterio nuevo CANCELA la petición anterior, así que ya no puede
        // ganar una respuesta vieja que llegó tarde, y `loading` sólo describe
        // una petición porque sólo hay una viva.
        switchMap(([term]) =>
          this.clientApi.search(term).pipe(
            catchError((error: unknown) => {
              this.patch({
                loading: false,
                error:
                  error instanceof ApiError
                    ? error.message
                    : 'No se pudieron cargar los clientes.',
              });

              // EMPTY y no throwError: si el error saliera del pipe, mataría
              // esta suscripción y el buscador dejaría de funcionar para
              // siempre después del primer fallo. Ejercicio 20.
              return EMPTY;
            }),
          ),
        ),
      )
      .subscribe((clients) => this.patch({ items: clients, loading: false }));
  }

  /** Lo llama el buscador de la pantalla en cada tecla. El debounce vive aquí. */
  search(term: string): void {
    this.criteriaSubject.next(term);
  }

  /** Relee con el criterio actual. Se usa después de escribir. */
  reload(): void {
    this.reloadSubject.next();
  }

  select(id: number): void {
    const selected = this.stateSubject.value.items.find((client) => client.id === id) ?? null;
    this.patch({ selected });
  }

  /**
   * Devuelve el observable en vez de suscribirse: quien escribe necesita saber
   * si salió bien para navegar y mostrar el snackbar, y eso es decisión de la
   * pantalla, no del servicio.
   *
   * ⚠️ Y aquí NO hay switchMap. `switchMap` es la respuesta correcta para leer
   * y la equivocada para escribir: cancelar un POST que ya salió no deshace
   * nada en el servidor, sólo te deja sin enterarte del resultado.
   */
  create(draft: ClientDraft): Observable<Client> {
    return this.clientApi.create(draft).pipe(tap(() => this.reload()));
  }

  update(client: Client): Observable<Client> {
    return this.clientApi.update(client).pipe(tap(() => this.reload()));
  }

  /**
   * La regla de negocio "no se borra un cliente con activos" vive AQUÍ, en el
   * servicio, y no en el componente. Es donde va: si mañana el borrado se
   * dispara desde el detalle del cliente o desde un proceso en lote, la regla
   * sigue puesta sin que nadie la copie. Compárala con la 💸 de 5.10, que es
   * la misma clase de regla escrita en el sitio equivocado.
   */
  remove(client: Client): Observable<void> {
    return this.assetApi.getByClient(client.id).pipe(
      // switchMap encadenando lectura → escritura. Es seguro porque el diálogo
      // de confirmación es modal y no se puede pedir dos borrados a la vez; si
      // el botón fuera pulsable en ráfaga, esto sería concatMap.
      switchMap((assets) => {
        if (assets.length > 0) {
          return throwError(
            () =>
              new ApiError(
                `No se puede eliminar ${client.legalName}: tiene ${assets.length} activos asociados.`,
                null,
              ),
          );
        }

        return this.clientApi.delete(client.id);
      }),
      tap(() => this.reload()),
    );
  }

  reset(): void {
    this.criteriaSubject.next('');
    this.stateSubject.next(createInitialState<Client>());
  }

  private patch(changes: Partial<FeatureState<Client>>): void {
    this.stateSubject.next({ ...this.stateSubject.value, ...changes });
  }
}
```

**Detalles con intención**

- **El criterio de búsqueda es estado del servicio, no del componente.** Sales a editar un cliente, vuelves al listado, y la búsqueda sigue puesta. Si viviera en el componente, cada navegación la borraría — y eso es un ticket, no una decisión.
- **`combineLatest` con `startWith(undefined)`.** El `startWith` es lo que hace que la primera carga no espere a un `reload()`. Sin él, la pantalla arranca vacía y nadie sabe por qué.
- **Un error no mata el buscador.** Es la diferencia entre `EMPTY` y `throwError` dentro de un `catchError`, y es de las cosas que sólo se aprenden rompiéndolas: por eso está el ejercicio 20.

### 5.6 El listado, ahora con datos

```ts
// src/app/features/clients/client-list/client-list.component.ts
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
    // plantilla: se importan porque MatDialog y MatSnackBar son servicios
    // declarados con `providedIn: <su módulo>`, así que sin el import el
    // inject() de arriba sería un NullInjectorError. Es el caso exacto que la
    // Fase 5 §4 anunciaba: importar un NgModule desde un standalone también
    // trae sus providers.
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
    // que el usuario escribió. El debounce y la cancelación viven en 5.5.
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
```

```html
<!-- src/app/features/clients/client-list/client-list.component.html -->
<h2>Clientes</h2>

<div class="client-list-toolbar">
  <mat-form-field appearance="outline">
    <mat-label>Buscar</mat-label>
    <input matInput [formControl]="searchControl" placeholder="Razón social o NIT" />
    <mat-icon matSuffix>search</mat-icon>
  </mat-form-field>

  <a mat-raised-button color="primary" routerLink="/clients/new">
    <mat-icon>add</mat-icon>
    Nuevo cliente
  </a>
</div>

<!-- UN solo async pipe para todo lo que la vista necesita, como en la Fase 4. -->
<ng-container *ngIf="view$ | async as view">
  <mat-progress-spinner
    *ngIf="view.loading"
    mode="indeterminate"
    diameter="32"
  ></mat-progress-spinner>

  <p class="client-list-error" *ngIf="view.error !== null">{{ view.error }}</p>

  <table mat-table [dataSource]="view.visible" *ngIf="view.total > 0">
    <ng-container matColumnDef="legalName">
      <th mat-header-cell *matHeaderCellDef>Razón social</th>
      <td mat-cell *matCellDef="let client">{{ client.legalName }}</td>
    </ng-container>

    <ng-container matColumnDef="taxId">
      <th mat-header-cell *matHeaderCellDef>NIT</th>
      <td mat-cell *matCellDef="let client">{{ client.taxId }}</td>
    </ng-container>

    <ng-container matColumnDef="actions">
      <th mat-header-cell *matHeaderCellDef>Acciones</th>
      <td mat-cell *matCellDef="let client">
        <a mat-icon-button [routerLink]="['/clients', client.id, 'edit']" aria-label="Editar">
          <mat-icon>edit</mat-icon>
        </a>
        <button mat-icon-button (click)="confirmRemove(client)" aria-label="Eliminar">
          <mat-icon>delete</mat-icon>
        </button>
      </td>
    </ng-container>

    <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
    <tr mat-row *matRowDef="let row; columns: displayedColumns"></tr>
  </table>

  <mat-paginator
    *ngIf="view.total > 0"
    [length]="view.total"
    [pageSize]="pageSize"
    [pageSizeOptions]="[5, 10, 25]"
    (page)="onPage($event)"
  ></mat-paginator>

  <cc-empty-state
    *ngIf="!view.loading && view.total === 0"
    icon="business"
    message="No hay clientes que coincidan con la búsqueda."
  ></cc-empty-state>
</ng-container>
```

**Detalles con intención**

- **La paginación es en el cliente, y es una decisión con fecha de caducidad.** Con tres clientes es correcto y con tres mil sería un disparate: se traerían todos para mostrar cinco. json-server soporta `_page` y `_limit`, y moverlo allá es el ejercicio 27. No lleva 💸 porque no es un atajo escondido: es el alcance declarado.
- **El mensaje del estado vacío habla de la búsqueda.** "No hay clientes" a secas es mentira cuando lo que pasa es que el filtro no encuentra nada, y esa mentira produce tickets.
- **`routerLink` en un `<a>` para navegar y `(click)` en un `<button>` para actuar.** Editar tiene URL propia y se puede abrir en otra pestaña; eliminar no es un sitio, es una acción.

**Prueba de fuego**

Levanta el mock con `CHAOS=latency npm run mock`, abre Network y escribe "Central" letra a letra. Tienen que salir **una o dos** peticiones —no siete—, y las que salgan de más aparecen marcadas como **canceladas** en rojo. Ésa es la firma visual de `switchMap`, y es la respuesta definitiva a los dos ejercicios que la Fase 4 dejó abiertos: ya no puede ganar una respuesta vieja, porque las viejas ya no llegan.

### 5.7 El formulario, en su propia ruta

Un solo componente para alta y edición. La diferencia entre los dos modos es si la ruta trae `:id`, y se resuelve en tres líneas.

```ts
// src/app/features/clients/client-form/client-form.component.ts
import { NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, DestroyRef, OnInit, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';

import { ApiError } from '../../../core/api/api-error';
import { ClientApiService } from '../../../core/api/client-api.service';
import { ClientStateService } from '../../../core/state/client-state.service';
import { uniqueTaxIdValidator } from '../unique-tax-id.validator';

/**
 * El tipo del formulario, con la nulabilidad decidida: los dos campos SIEMPRE
 * tienen un valor, aunque sea la cadena vacía. Compáralo con el LoginForm de
 * la Fase 2, que arrastra un `| null` de la migración de Angular 14 y paga por
 * él una guarda que nunca se ejecuta.
 */
interface ClientForm {
  legalName: FormControl<string>;
  taxId: FormControl<string>;
}

@Component({
  selector: 'cc-client-form',
  standalone: true,
  imports: [
    NgIf,
    ReactiveFormsModule,
    RouterLink,
    MatButtonModule,
    MatFormFieldModule,
    MatInputModule,
    // Por el servicio, no por sus directivas. Ver el comentario del listado.
    MatSnackBarModule,
  ],
  templateUrl: './client-form.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ClientFormComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly clientApi = inject(ClientApiService);
  private readonly clientState = inject(ClientStateService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly destroyRef = inject(DestroyRef);

  /** `null` en alta, el id del cliente en edición. Decide todo lo demás. */
  private readonly clientId: number | null = this.readClientId();

  readonly isEdit = this.clientId !== null;

  submitting = false;

  readonly form = new FormGroup<ClientForm>({
    legalName: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.minLength(3)],
    }),
    taxId: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.pattern(/^\d{9,10}$/)],
      // El validador asíncrono va en su propio parámetro, no mezclado con los
      // síncronos. Angular corre los síncronos primero y sólo llama al
      // asíncrono si aquéllos pasaron: no se pregunta al servidor por un NIT
      // que ni siquiera tiene nueve dígitos.
      asyncValidators: [uniqueTaxIdValidator(this.clientApi, this.clientId)],
    }),
  });

  ngOnInit(): void {
    if (this.clientId === null) {
      return;
    }

    this.clientApi
      .getById(this.clientId)
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        // setValue y no patchValue: el formulario tiene exactamente estos dos
        // campos, y setValue falla en compilación si mañana se añade un
        // tercero y alguien olvida rellenarlo. patchValue lo dejaría vacío
        // en silencio.
        next: (client) => this.form.setValue({ legalName: client.legalName, taxId: client.taxId }),
        error: () => {
          this.snackBar.open('No se pudo cargar el cliente.', 'Cerrar', { duration: 6000 });
          void this.router.navigate(['/clients']);
        },
      });
  }

  submit(): void {
    // `pending` es el estado mientras el validador asíncrono está en vuelo, y
    // durante ese rato `invalid` es false. Sin esta comprobación, pulsar
    // rápido guarda un NIT repetido. Es el bug más caro de esta pantalla.
    if (this.form.invalid || this.form.pending) {
      this.form.markAllAsTouched();
      return;
    }

    // Sin guarda de null. Ésa es toda la ganancia de `nonNullable`, y se ve
    // mejor comparándola con el submit() del login de la Fase 2.
    const { legalName, taxId } = this.form.getRawValue();

    this.submitting = true;

    const request$ =
      this.clientId === null
        ? this.clientState.create({ legalName, taxId })
        : this.clientState.update({ id: this.clientId, legalName, taxId });

    request$.pipe(takeUntilDestroyed(this.destroyRef)).subscribe({
      next: () => {
        this.snackBar.open(
          this.isEdit ? 'Cliente actualizado.' : 'Cliente creado.',
          'Cerrar',
          { duration: 4000 },
        );
        void this.router.navigate(['/clients']);
      },
      error: (error: unknown) => {
        this.submitting = false;
        this.snackBar.open(
          error instanceof ApiError ? error.message : 'No se pudo guardar el cliente.',
          'Cerrar',
          { duration: 6000 },
        );
      },
    });
  }

  /**
   * El parámetro de ruta llega como `string | null` y el modelo pide `number`.
   * La conversión se hace UNA vez, aquí, en vez de en cada uso.
   */
  private readClientId(): number | null {
    const raw = this.route.snapshot.paramMap.get('id');

    if (raw === null) {
      return null;
    }

    const parsed = Number(raw);

    // Number('abc') es NaN, y NaN pasaría como number sin que strict se queje.
    // Es el hueco clásico del sistema de tipos: el tipo dice number y el valor
    // no sirve para nada.
    return Number.isInteger(parsed) ? parsed : null;
  }
}
```

```ts
// src/app/features/clients/unique-tax-id.validator.ts
import { AbstractControl, AsyncValidatorFn, ValidationErrors } from '@angular/forms';
import { Observable, catchError, first, map, of, switchMap, timer } from 'rxjs';

import { ClientApiService } from '../../core/api/client-api.service';

/**
 * Valida que el NIT no esté ya registrado. Es una fábrica y no un validador
 * suelto porque necesita dos cosas del contexto: el servicio con el que
 * preguntar y el cliente que se está editando —para no chocar consigo mismo—.
 */
export function uniqueTaxIdValidator(
  clientApi: ClientApiService,
  exceptId: number | null,
): AsyncValidatorFn {
  return (control: AbstractControl): Observable<ValidationErrors | null> => {
    // El valor de un AbstractControl no está tipado: llega como `any`, y en
    // este proyecto eso se trata como `unknown` y se estrecha. Es el caso
    // exacto del §6.4 de la guía.
    const value: unknown = control.value;

    if (typeof value !== 'string' || value.trim() === '') {
      return of(null);
    }

    const taxId = value.trim();

    return timer(400).pipe(
      // El timer es el que evita una petición por tecla. Si el usuario sigue
      // escribiendo, Angular cancela este observable y arranca otro.
      switchMap(() => clientApi.existsByTaxId(taxId, exceptId)),
      map((exists) => (exists ? { taxIdTaken: true } : null)),
      // Un fallo de red no convierte un NIT válido en inválido: el usuario no
      // tiene la culpa de que el servidor esté caído. El error saldrá al
      // guardar, que es donde sí se puede explicar.
      catchError(() => of(null)),
      // Sin first(), el observable no completa y el control se queda `pending`
      // para siempre: el formulario nunca vuelve a ser válido y el botón nunca
      // se habilita. Es el bug que más tiempo hace perder de esta pantalla.
      first(),
    );
  };
}
```

```html
<!-- src/app/features/clients/client-form/client-form.component.html -->
<h2>{{ isEdit ? 'Editar cliente' : 'Nuevo cliente' }}</h2>

<form [formGroup]="form" (ngSubmit)="submit()" class="client-form">
  <mat-form-field appearance="outline">
    <mat-label>Razón social</mat-label>
    <input matInput formControlName="legalName" autocomplete="organization" />
    <!-- Los mat-error van DENTRO del mat-form-field. Fuera no se pintan, y no
         avisa nadie: es el error de MDC que más se repite. -->
    <mat-error *ngIf="form.controls.legalName.hasError('required')">
      La razón social es obligatoria.
    </mat-error>
    <mat-error *ngIf="form.controls.legalName.hasError('minlength')">
      Debe tener al menos 3 caracteres.
    </mat-error>
  </mat-form-field>

  <mat-form-field appearance="outline">
    <mat-label>NIT</mat-label>
    <input matInput formControlName="taxId" inputmode="numeric" />
    <mat-hint *ngIf="form.controls.taxId.pending">Verificando el NIT…</mat-hint>
    <mat-error *ngIf="form.controls.taxId.hasError('required')">
      El NIT es obligatorio.
    </mat-error>
    <mat-error *ngIf="form.controls.taxId.hasError('pattern')">
      El NIT son 9 o 10 dígitos, sin puntos ni guiones.
    </mat-error>
    <mat-error *ngIf="form.controls.taxId.hasError('taxIdTaken')">
      Ya existe un cliente con este NIT.
    </mat-error>
  </mat-form-field>

  <div class="client-form-actions">
    <a mat-button routerLink="/clients">Cancelar</a>
    <button mat-raised-button color="primary" type="submit" [disabled]="submitting">
      {{ submitting ? 'Guardando…' : 'Guardar' }}
    </button>
  </div>
</form>
```

**Detalles con intención**

- **`form.controls.legalName` y no `form.get('legalName')`.** Con `FormGroup<T>` el primero está tipado y el segundo devuelve `AbstractControl | null`, que obliga a comprobar por nada. Es la ventaja más práctica de los formularios tipados y la que más rápido se nota.
- **El `mat-hint` del `pending`.** Sin él, el usuario que escribe un NIT repetido ve medio segundo de nada y luego un error rojo que parece salido de la nada. Decir "verificando" cuesta una línea.
- **`markAllAsTouched()` al intentar guardar inválido.** Un control que nunca fue tocado no muestra sus errores, así que un formulario recién abierto y vacío no se pinta de rojo. La contrapartida es que al pulsar "Guardar" no pasaría nada visible — y ese "no pasa nada" es literalmente el ticket de la pieza forense.

### 5.8 Las rutas de clientes, completas

```ts
// src/app/features/clients/clients.routes.ts
import { Routes } from '@angular/router';

import { CLIENT_LIST_PAGE_SIZE } from './client-list-page-size.token';

export const CLIENTS_ROUTES: Routes = [
  {
    path: '',
    providers: [{ provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 }],
    loadComponent: () =>
      import('./client-list/client-list.component').then((m) => m.ClientListComponent),
  },
  // 'new' va ANTES que cualquier ruta con parámetro de un solo segmento. Hoy no
  // hay ninguna, así que da igual; el día que exista `:id` para el detalle,
  // ponerla después haría que /clients/new intentara cargar el cliente "new".
  {
    path: 'new',
    loadComponent: () =>
      import('./client-form/client-form.component').then((m) => m.ClientFormComponent),
  },
  {
    path: ':id/edit',
    loadComponent: () =>
      import('./client-form/client-form.component').then((m) => m.ClientFormComponent),
  },
];
```

**Prueba de fuego**

Abre Network, entra a `/clients` y pulsa "Nuevo cliente": aparece **un chunk nuevo**, el del formulario, que no se descargó al entrar al listado. Vuelve y entra a editar: no aparece nada, porque es el mismo componente y ya está en memoria. Dos rutas, un chunk, y la prueba de que `loadComponent` diferido no significa "uno por ruta" sino "uno por archivo".

### 5.9 El diálogo de confirmación, genérico y standalone

```ts
// src/app/shared/confirm-dialog/confirm-dialog.component.ts
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';

/** Lo que hay que darle al abrirlo. Tipado: nada de pasarle un objeto suelto. */
export interface ConfirmDialogData {
  readonly title: string;
  readonly message: string;
  readonly confirmLabel: string;
}

/**
 * Vive en shared/ y no está declarado en SharedModule, igual que
 * EmptyStateComponent: lo importa quien lo usa. Fase 5 §5.5.
 */
@Component({
  selector: 'cc-confirm-dialog',
  standalone: true,
  imports: [MatButtonModule, MatDialogModule],
  template: `
    <h2 mat-dialog-title>{{ data.title }}</h2>
    <mat-dialog-content>{{ data.message }}</mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button (click)="dialogRef.close(false)">Cancelar</button>
      <button mat-raised-button color="warn" (click)="dialogRef.close(true)">
        {{ data.confirmLabel }}
      </button>
    </mat-dialog-actions>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ConfirmDialogComponent {
  // inject() con genérico explícito: MAT_DIALOG_DATA es un token sin tipo, y
  // sin el genérico esto sería `any` entrando por la puerta grande.
  readonly data = inject<ConfirmDialogData>(MAT_DIALOG_DATA);

  readonly dialogRef = inject<MatDialogRef<ConfirmDialogComponent, boolean>>(MatDialogRef);
}
```

**Detalles con intención**

- **El diálogo no borra nada.** Devuelve `true` o `false` y se va. Si supiera borrar clientes, no serviría para confirmar la baja de un activo en la Fase 9, y habría dos diálogos casi iguales — que es como nacen los componentes con siete `@Input` opcionales.
- **`MatDialogRef<Componente, boolean>`.** El segundo genérico es el tipo de lo que devuelve `afterClosed()`, y es lo que permite el `filter((confirmed): confirmed is true => …)` de 5.6 sin ningún `as`.

### 5.10 🧬 Activos: pantalla nueva dentro de un módulo de 2021

`AssetsModule` sigue siendo uno de los nueve módulos que la Fase 5 no convirtió, y hoy tiene que crecer. La regla decide sola: **el archivo que ya existía se toca lo mínimo y en su estilo; el que nace hoy nace standalone.**

```ts
// src/app/core/api/asset-api.service.ts — nuevo, y el molde de la Fase 3
import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, catchError } from 'rxjs';

import { environment } from '../../../environments/environment';
import { Asset } from '../models/asset.model';
import { toApiError } from './api-error';

@Injectable({ providedIn: 'root' })
export class AssetApiService {
  private readonly http = inject(HttpClient);

  private readonly baseUrl = `${environment.apiBaseUrl}/assets`;

  getAll(): Observable<readonly Asset[]> {
    return this.http.get<readonly Asset[]>(this.baseUrl).pipe(catchError(toApiError));
  }

  getByClient(clientId: number): Observable<readonly Asset[]> {
    const params = new HttpParams().set('clientId', clientId);

    return this.http
      .get<readonly Asset[]>(this.baseUrl, { params })
      .pipe(catchError(toApiError));
  }

  getById(id: string): Observable<Asset> {
    return this.http.get<Asset>(`${this.baseUrl}/${id}`).pipe(catchError(toApiError));
  }

  /**
   * El `id` de un activo lo escribe el usuario —"ASC-CENTRAL-03" está pintado
   * en el equipo—, así que va dentro del cuerpo y no lo asigna el servidor.
   * Es la diferencia con `ClientDraft`, y la razón de que aquí no exista un
   * `AssetDraft`.
   */
  create(asset: Asset): Observable<Asset> {
    return this.http.post<Asset>(this.baseUrl, asset).pipe(catchError(toApiError));
  }

  update(asset: Asset): Observable<Asset> {
    return this.http
      .put<Asset>(`${this.baseUrl}/${asset.id}`, asset)
      .pipe(catchError(toApiError));
  }

  // Sin delete(), y no es un olvido: un activo con inspecciones y certificados
  // detrás no se borra, se da de baja. Dar de baja es un cambio de estado y
  // exige un campo que el modelo no tiene todavía. Está en los 📌.
}
```

`AssetStateService` es el molde de la Fase 4 sin ninguna variación —`state$`, `assets$`, `load()`, `create()`, `update()`, `reset()`, y la suscripción al cierre de sesión—, así que no se reproduce entero aquí: lo escribes en el ejercicio 4 copiando `ClientStateService` y quitándole el buscador.

Lo que sí merece verse es el formulario, porque trae la deuda de la fase:

```ts
// src/app/features/assets/asset-form/asset-form.component.ts — NUEVO, standalone
@Component({
  selector: 'cc-asset-form',
  standalone: true,
  imports: [NgIf, ReactiveFormsModule, MatButtonModule, MatFormFieldModule, MatInputModule, MatSelectModule],
  templateUrl: './asset-form.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AssetFormComponent implements OnInit {
  private readonly clientState = inject(ClientStateService);
  // …resto de inyecciones, igual que en el formulario de clientes…

  // El tipo del formulario, con la misma disciplina de 5.7: ningún `| null`
  // heredado. `installedAt` es un día de calendario y viaja como string,
  // igual que en el modelo de la Fase 3.
  //   interface AssetForm {
  //     id: FormControl<string>;
  //     clientId: FormControl<number>;
  //     type: FormControl<AssetType>;
  //     description: FormControl<string>;
  //     installedAt: FormControl<string>;
  //   }

  readonly assetTypes: readonly AssetType[] = ['elevator', 'boiler', 'tank', 'fire_system'];

  readonly form = new FormGroup<AssetForm>({
    id: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.pattern(/^[A-Z]{3}-[A-Z]+-\d{2}$/)],
    }),
    clientId: new FormControl(0, { nonNullable: true, validators: [Validators.required] }),
    type: new FormControl<AssetType>('elevator', { nonNullable: true }),
    description: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    installedAt: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
  });

  ngOnInit(): void {
    // …carga del activo en modo edición…

    /**
     * 💸 DEUDA TÉCNICA INTENCIONAL
     * "Un activo no puede cambiar de cliente" es una REGLA DE NEGOCIO y está
     * escrita aquí, en un componente, en forma de un control deshabilitado.
     * Funciona: la pantalla no deja hacerlo. Y falla en todo lo demás — un
     * alta por lote, un import de CSV o la pantalla que la Fase 9 va a
     * escribir pueden saltársela sin enterarse, porque la regla no existe
     * fuera de este archivo.
     * Lo correcto es que viva en AssetStateService, junto a la de "no se borra
     * un cliente con activos" de 5.5, que sí está en su sitio.
     * SE PAGA EN LA FASE 9, cuando esta misma clase de regla aparezca por
     * tercera vez y el argumento de la prisa ya no se sostenga.
     */
    if (this.isEdit) {
      this.form.controls.clientId.disable();
    }
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    // ⚠️ getRawValue() y NO value: `value` OMITE los controles deshabilitados,
    // así que en edición devolvería un objeto sin clientId y el PUT dejaría el
    // activo huérfano. Con el formulario tipado el error se ve en compilación;
    // sin tipar, se ve en producción. Es el segundo síntoma de la sección 6.
    const asset = this.form.getRawValue();
    // …create o update según el modo…
  }
}
```

Y la costura, que son dos líneas en dos archivos heredados:

```ts
// src/app/features/assets/assets.module.ts
@NgModule({
  declarations: [AssetListComponent],
  imports: [
    SharedModule,
    AssetsRoutingModule,
    EmptyStateComponent,
    // 🧬 El formulario nuevo entra por `imports` porque es standalone. Y
    // MatTableModule se importa aquí, directamente, porque SharedModule dejó de
    // reexportarlo en la Fase 5: un módulo heredado importando lo que usa es
    // exactamente el arreglo correcto, escrito en el estilo del archivo.
    AssetFormComponent,
    MatTableModule,
  ],
})
export class AssetsModule {}
```

```ts
// src/app/features/assets/assets-routing.module.ts
// 🧬 RouterModule.forChild() de 2021 apuntando a un componente standalone de
// 2025. `component:` y no `loadComponent:` a propósito: el componente ya viaja
// en el chunk de este módulo, así que diferirlo otra vez no ahorraría nada.
const routes: Routes = [
  { path: '', component: AssetListComponent },
  { path: 'new', component: AssetFormComponent },
  { path: ':id/edit', component: AssetFormComponent },
];
```

`AssetListComponent` se toca **lo mínimo**: sigue con `constructor`, sigue sin `OnPush`, sigue declarado. Sólo pasa de mostrar el estado vacío a pintar la tabla con `assetState.state$ | async`, que es una sustitución de plantilla y ni una línea de estilo nuevo.

**El patrón a memorizar**

> Una feature no se convierte porque le crezca una pantalla. Le crece la pantalla en el estilo de hoy, el módulo la aloja en el estilo de ayer, y el punto donde se tocan lleva un 🧬 para que la próxima persona sepa que eso está así a propósito.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** el mensaje de error del NIT no aparece nunca, aunque el control está en rojo.
**Causa:** el `<mat-error>` quedó fuera del `<mat-form-field>`. En Material 14 se toleraba en algunos casos; en MDC no.
**Fix mínimo:** meterlo dentro, entre los hijos del `mat-form-field`.
**Lo que importa:** no hay error, ni en consola ni en el build. Es la misma familia que el botón sin estilo de la Fase 5: MDC pinta lo que reconoce como hijo suyo y **ignora en silencio** lo que no. Cuando algo de Material "no aparece", la primera pregunta es de anidamiento, no de lógica.

**Síntoma:** al editar un activo, el `clientId` se pierde y el PUT lo manda sin cliente.
**Causa:** se usó `form.value` en vez de `form.getRawValue()`, y `value` omite los controles deshabilitados.
**Fix mínimo:** `getRawValue()`.
**Lo que importa:** es la trampa de deshabilitar un control para expresar una regla. El control deshabilitado desaparece del valor **y** deja de validarse, así que "deshabilitado" significa dos cosas a la vez y sólo querías una. Es precisamente por qué la 💸 de 5.10 está mal puesta: la regla no sólo está en el archivo equivocado, además se expresa con una herramienta que hace de más.

**Síntoma:** el botón "Guardar" no hace nada y no aparece ningún error.
**Causa:** el formulario está inválido y sus controles nunca fueron `touched`, así que ningún `mat-error` se pinta. O está `pending` porque el validador asíncrono sigue en vuelo.
**Fix mínimo:** el `markAllAsTouched()` que ya está en `submit()`, más el `mat-hint` del `pending`.
**Lo que importa:** desde fuera, "inválido y sin pintar" y "no pasa nada" son indistinguibles. Es el ticket de la pieza forense y el bug más humano del curso: la aplicación sabe qué está mal y no lo dice.

**Síntoma:** ordenas la lista de clientes y la tabla no se mueve; en la de activos, la misma acción sí funciona.
**Causa:** una mutación en sitio sobre el array del estado, con `OnPush` en un lado y detección por defecto en el otro.
**Fix mínimo:** copiar antes de ordenar — y a partir de 5.2 ya ni compila.
**Lo que importa:** dos pantallas del mismo repositorio con distinta estrategia de detección **no son comparables** como evidencia. Que en una funcione no significa que la otra esté rota por otra razón: significa que una está tapando el bug.

### Pieza forense de esta fase

El ticket llega así, literal: *"No me deja guardar el cliente nuevo y no dice por qué."* Sin captura, sin navegador, sin usuario. Sin acceso a producción. Ésta es la ruta, y son cuatro minutos.

**Paso 1 — Reproducir con lo que hay.** No preguntes qué escribió: prueba los tres casos que producen ese síntoma exacto. Campo vacío sin tocar, NIT con formato malo, NIT repetido. Uno de los tres se comporta como dice el ticket.

**Paso 2 — Preguntarle al formulario, no al código.** Con la pantalla abierta, selecciona el elemento del formulario en el inspector y en la consola:

```js
// $0 es el elemento seleccionado en el inspector. ng está disponible en el
// build de desarrollo; en producción, no — y eso es la Fase 13.
const component = ng.getComponent($0);

Object.entries(component.form.controls)
  .filter(([, control]) => control.invalid || control.pending)
  .map(([name, control]) => ({ name, status: control.status, errors: control.errors }));
```

La salida dice el nombre del control, si está `INVALID` o `PENDING`, y qué error tiene. Eso es el ticket resuelto: ya sabes si el usuario escribió mal el NIT o si el validador asíncrono se quedó colgado.

**Paso 3 — Distinguir las dos causas que se parecen.** `INVALID` con `{taxIdTaken: true}` es un usuario que necesita un mensaje. `PENDING` que nunca cambia es un bug tuyo: el validador no completó. Los dos producen el mismo "no me deja guardar" y se arreglan en sitios opuestos.

**Paso 4 — Confirmar en Network.** Si el estado era `PENDING`, la petición de `existsByTaxId` te dice el resto: si quedó colgada, si devolvió 500, o si nunca salió.

> 📄 El recorrido completo, con el ticket, las tres reproducciones y la salida literal de cada paso, en `forense-fase-06.md`.

**🧨 Rompe a propósito**

Quita el `first()` del validador asíncrono de 5.7 y guarda. Escribe un NIT válido y mira el control: se queda en `PENDING` **para siempre**. El botón nunca se habilita, no hay ningún error en consola, la petición en Network aparece completada con 200, y el formulario es correcto en todos los sentidos menos en el que importa.

Ahora compáralo con quitar el `catchError`: apaga el mock y escribe un NIT. El control queda `INVALID` con un error que no tiene mensaje, y el usuario ve un campo en rojo sin explicación por un fallo que no es suyo.

Dos líneas quitadas, dos formas de romper el mismo formulario, y ninguna de las dos aparece en un test que sólo compruebe que el validador marca los NIT repetidos.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Compila el tema de 5.1 y quita el prefabricado de `angular.json`. Compara la altura de un `mat-form-field` con densidad `0`, `-1` y `-2`, y anota cuál eliges para una tabla de inspecciones en tablet.
2. Cambia `FeatureState<T>` a `readonly` y corre `ng build` **sin arreglar nada**. Anota cuántos errores salen y en qué archivos: es el mapa de la deuda. Guárdalo en `deuda.md`.
3. Añade `create`, `update`, `delete`, `search` y `existsByTaxId` a `ClientApiService`. Pruébalos con `curl` antes de tocar una sola pantalla.
4. Escribe `AssetStateService` copiando `ClientStateService` y quitándole el buscador y la regla de borrado. Debe tener exactamente `state$`, `assets$`, `loading$`, `error$`, `load()`, `create()`, `update()` y `reset()`.
5. **Diagnóstico.** Pon el `<mat-error>` del NIT fuera del `<mat-form-field>`. Anota qué dice el build, qué dice la consola y qué se ve en pantalla. Las tres respuestas son la misma: nada.
6. **Diagnóstico.** En el formulario de activos, cambia `getRawValue()` por `value` y edita un activo. Mira el cuerpo del PUT en Network y di qué campo falta y por qué.
7. Añade el `mat-hint` de "Verificando el NIT…" y comprueba con `CHAOS=latency` que se ve de verdad. Sin caos dura 50 ms y no lo vas a ver nunca.
8. **Diagnóstico.** Crea un cliente con el NIT `900123456`, que ya existe en la semilla. Describe la secuencia completa: qué controla el validador, cuándo pasa a `pending`, cuándo aparece el `mat-error`, y qué pasa si pulsas Guardar durante el `pending`.

**🟡 Intermedio (9–17)**

9. Implementa la búsqueda con `switchMap` de 5.5 y demuéstralo: `CHAOS=latency npm run mock`, escribe rápido, y entrega la captura de Network con las peticiones canceladas en rojo.
10. Cambia el `switchMap` del buscador por `mergeMap` y repite el experimento con `CHAOS=latency`. Anota qué resultado queda en pantalla y explica por qué es el peor de los posibles.
11. **Diagnóstico.** Quita el `debounceTime(300)` y cuenta las peticiones al escribir "Central". Después ponlo en 3000 y describe cómo se siente la pantalla. Elige un número y justifícalo en dos frases.
12. Añade `mat-sort` a la tabla de clientes. Decide dónde vive el criterio de orden —¿componente o servicio?— y justifícalo con el mismo argumento que hizo que el criterio de búsqueda viviera en el servicio.
13. 🧬 **Estilo.** Ticket: *"en la lista de activos las columnas están en el orden equivocado"*. `AssetListComponent` es heredado. Escribe el fix y justifica en tres líneas por qué no aprovechaste para ponerle `OnPush`.
14. 🧬 **Estilo.** Ticket: *"al crear un cliente, el foco debería quedar en el primer campo"*. `ClientFormComponent` es nuevo. Escribe el fix en el estilo que le corresponde y di qué habría estado mal si lo hubieras resuelto con `ngAfterViewInit` y un `document.querySelector`.
15. Añade al formulario de activos el validador asíncrono de unicidad del `id`, reutilizando la técnica de `uniqueTaxIdValidator`. Ojo con el caso de la edición: un activo no puede chocar consigo mismo.
16. **Diagnóstico.** Borra un cliente que tiene activos y captura el mensaje. Después borra uno que no tiene ninguno. Explica por qué la regla está en el servicio y qué se rompería si estuviera en el componente del listado.
17. Haz que el buscador conserve su texto al ir a editar un cliente y volver. Comprueba que ya funciona sin escribir código, y explica por qué en tres frases. Después múdalo al componente, comprueba que se rompe, y devuélvelo.

**🟠 Difícil (18–24)**

18. **Diagnóstico.** Reproduce el ticket de la pieza forense de las tres formas posibles y entrega, para cada una, la salida del `Object.entries(...)` de la consola. Di cuál de las tres es un bug tuyo y cuáles dos son de usuario.
19. **Diagnóstico.** Quita el `first()` del validador asíncrono. El control se queda `PENDING` para siempre. Explica por qué Network muestra la petición como completada y aun así el control no se resuelve, y qué le pasa a `form.valid` durante todo ese tiempo.
20. **Diagnóstico.** En el `catchError` del buscador, cambia `EMPTY` por `throwError(() => error)`. Provoca un fallo con `CHAOS=error CHAOS_RATE=1`, quita el caos, y comprueba que el buscador **ya no vuelve a funcionar**. Explica qué murió exactamente y por qué recargar la página lo arregla.
21. El post-mortem del incidente **07** lo escribiste en la Fase 5 sobre un cascarón sin datos. Vuelve a él ahora que la pantalla tiene tabla, buscador y formulario, y reescribe dos puntos: el **2** (pasos de reproducción, que ahora se pueden dar con datos reales) y el **6** (la prueba de regresión, que antes no tenía qué comprobar). Mantén el mismo par de tags `inc/07/<slug>-roto` / `-fix` y explica en una línea por qué el ID no cambia.
22. **Diagnóstico.** Añade el botón "Ordenar por NIT" de 5.2 en la versión que muta, primero en clientes (`OnPush`) y después en activos (detección por defecto). Entrega los dos comportamientos y escribe el ticket que habría reportado un usuario que sólo usa la pantalla de activos.
23. Pon `CHAOS=timeout CHAOS_RATE=1` y crea un cliente. El `POST` no responde nunca. Describe qué ve el usuario, cuánto tiempo, y qué habría que añadir para que la pantalla no se quede colgada. Impleméntalo con el operador de RxJS que corresponde y di por qué **no** basta con un `setTimeout`.
24. Reescribe el listado de clientes con `MatTableDataSource` y el paginador enlazado por `@ViewChild`, que es como lo enseña la documentación de Material. Entrega las dos versiones y compara: líneas, dónde vive el estado, y qué pasa con `OnPush` en cada una. No hay respuesta correcta; hay respuesta justificada.

**🔴 Muy difícil (25–30)**

25. **Diagnóstico.** Dos pestañas abiertas en `/clients`. En la primera editas un cliente; en la segunda, sin recargar, lo borras. Describe qué pasa exactamente, qué responde el servidor, qué ve cada pestaña, y diseña la mínima defensa razonable. Después argumenta si esa defensa vale su costo en un sistema de tres usuarios.
26. Mueve la regla *"un activo no puede cambiar de cliente"* del componente al `AssetStateService` —la 💸 de esta fase, pagada por adelantado— en una rama `spike/`. Mide qué cambia: cuántos archivos, cuántas líneas, y qué pasa con el control deshabilitado. Después decide si la fusionarías hoy o esperarías a la Fase 9, y escribe el argumento.
27. Mueve la paginación al servidor con `_page` y `_limit` de json-server, incluida la lectura de la cabecera `X-Total-Count`. Explica qué gana el sistema, qué pierde la búsqueda del ejercicio 9, y cómo se combinan las dos cosas sin hacer dos peticiones por tecla.
28. Cambia `mat.all-component-themes` por los mixins de los componentes que el proyecto usa de verdad. Mide `styles.css` antes y después con `ng build`, anota las dos cifras, y decide si el ahorro justifica que alguien tenga que acordarse de añadir un mixin cada vez que aparezca un componente nuevo.
29. **Diagnóstico.** Un usuario reporta que "a veces se guarda el cliente dos veces". Reprodúcelo: pulsa Guardar dos veces rápido con `CHAOS=latency`. Explica por qué `[disabled]="submitting"` no siempre basta, y arréglalo de dos formas distintas —una en la pantalla y otra en el servicio—. Di cuál elegirías para las Fases 7 y 8, donde los formularios son mucho más lentos de llenar.
30. Diseña la trazabilidad que esta fase difirió: qué colección haría falta en el mock, quién la alimentaría —¿el componente, el servicio, un interceptor?—, qué se guardaría exactamente, y qué preguntas del negocio podría contestar. Después estima qué le costaría al curso construirla y argumenta si la dejarías fuera igual que nosotros.

**🔥 Opcionales**

- 🔥 Añade el detalle del cliente en `/clients/:id`, con sus activos listados debajo, y decide si esa ruta reemplaza al formulario de edición o convive con él. Ojo con el orden de las rutas de 5.8.
- 🔥 Escribe un `CanDeactivateFn` funcional que avise al salir de un formulario con cambios sin guardar. Es media hora, es lo que más agradece un inspector en campo, y la Fase 8 lo va a necesitar de verdad cuando el formulario tenga veinte controles.
- 🔥 Extrae `ConfirmDialogComponent` y `EmptyStateComponent` a una carpeta `ui/` y decide, por escrito, cuál es el criterio que separa `ui/` de `shared/`. Es el 📌 de la Fase 5, y tiene respuesta correcta sólo si la escribes tú.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v16.angular.io/guide/typed-forms — la guía de formularios tipados. Es corta y es la que evita el 90% de las dudas de esta fase.
- https://v16.angular.io/guide/form-validation — validadores síncronos y asíncronos, con el ciclo `PENDING` explicado.
- https://v16.angular.io/api/forms/AsyncValidatorFn — la firma exacta, incluida la obligación de completar.
- https://v16.angular.io/guide/change-detection-skipping-subtrees — `OnPush` y qué lo despierta. Léela después de haber visto la tabla que no se repinta, no antes.
- https://v16.material.angular.io/components/table/overview y https://v16.material.angular.io/components/paginator/overview — tabla y paginador de Material 16.
- https://v16.material.angular.io/components/dialog/overview — `MatDialog`, con los genéricos de `open()` que usa 5.6.
- https://v16.material.angular.io/guide/theming — el tema compilado de 5.1, incluida la densidad, que es lo que peor documentado está fuera de aquí.
- https://github.com/typicode/json-server — los parámetros `q`, `_page` y `_limit` de los ejercicios 9 y 27.
- https://rxjs.dev/api/operators/switchMap — y su tabla de hermanos, que es lo que hace falta para el ejercicio 10.

> ⚠️ Casi todo el material de formularios de Material que encuentres en blogs es anterior a MDC y usa `appearance="legacy"`, `mat-form-field` con hijos que aquí no compilan, y ejemplos de `FormControl` sin genéricos. Si el artículo no dice explícitamente "Angular 15+" o "MDC", asume que está describiendo otro componente con el mismo nombre. El resumen de qué cambió está en **A01**.

**Orden de lectura sugerido:** la guía de formularios tipados antes de escribir 5.7 — entera, son quince minutos. Durante, la de validación de formularios cuando llegues al validador asíncrono, y **A05** si `FormGroup<T>` se te resiste. Después, la de `OnPush`: cuando ya hayas visto una tabla que no se repinta, esa página deja de ser teoría y explica algo que te acaba de pasar.

---

## 🚀 9. Cierre y conexión con la siguiente fase

CertCore tiene por fin pantallas donde se trabaja. Un listado que busca sin ahogar al servidor, un formulario que sabe qué campos pueden estar vacíos y cuáles no, un validador que pregunta al servidor sin preguntarle en cada tecla, un diálogo que confirma y no decide, y dos reglas de negocio a la vista: una en su sitio y otra marcada con 💸 y con fecha de cobro.

Y una deuda saldada que costó más que contraerla. El `readonly` de `FeatureState<T>` es un cambio de dos palabras que rompió la compilación en varios sitios, y cada uno de esos sitios era un lugar donde alguien podía haber hecho `push` sin enterarse. Pagar deuda técnica casi nunca se ve en la pantalla: se ve en la lista de errores del compilador, y esa lista es el argumento.

Lo que de verdad te llevas es la pregunta que ahora vas a hacerte ante cualquier lista que no se refresca: **¿cambió la referencia?** Antes de mirar el servicio, antes de mirar la red, antes de sospechar de Angular. Y su gemela, la que separa a quien depura de quien adivina: **¿esta pantalla usa `OnPush` o no?**, porque el mismo bug se ve en una y se esconde en la otra.

La **Fase 7** es el corazón del curso ⭐ y es donde todo esto deja de ser cómodo. Las plantillas de checklist no son una entidad más: son una entidad **versionada**, y el molde de servicio de estado que hoy has copiado dos veces se va a quedar corto por primera vez —resolver *"qué versión aplica a esta fecha"* no es "cargar una lista"—. El formulario que hoy tiene dos campos se va a construir en runtime en la Fase 8, con los tipos puestos, desde los datos que la 7 modele. Y el invariante que ordena el resto del sistema entra en escena: **una inspección se lee siempre con la versión de plantilla con la que se ejecutó.**

> **La señal de que quedó bien:** cuando una lista no se actualiza y tu primera reacción no es abrir el servicio, sino preguntarte si alguien mutó en vez de reemplazar — y sabes en qué línea mirarlo.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-06 -m "F6 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 06: …`) y los de ejercicio su
> número (`fase 06 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f06/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Esta fase paga la 💸 de inmutabilidad que declaró la Fase 4, y la factura se
> lee en `git diff fase-04 fase-06 -- src/app/core/state/`: dos palabras en la
> interfaz y el rastro de todo lo que hubo que ajustar por ellas. Guarda en el
> mensaje del tag el número de errores de compilación del ejercicio 2 — es la
> única medida honesta de lo que costaba tener el estado abierto. Y ojo con el
> `db.json`: esta fase es la primera que **escribe** en el mock, así que tu base
> de datos ya no es la semilla. Antes de etiquetar, decide si commiteas tu
> `db.json` o lo devuelves con `npm run seed`.

---

## 📌 Pendientes sugeridos

- 🪦 **La 💸 de inmutabilidad de la Fase 4, pagada.** `FeatureState<T>` es `readonly` de punta a punta y el borde HTTP ya lo era desde la Fase 3. Sin acción pendiente, salvo que la Fase 7 —que va a necesitar un estado con forma propia— respete la misma regla.
- **La trazabilidad de los cambios sigue sin dueño, y esta fase la difirió a propósito.** Un `audit` en el mock alimentado por un interceptor es media fase de trabajo y toca un dominio —quién hizo qué— que el curso nombra pero no construye. El ejercicio 30 lo diseña sin implementarlo. → **Decisión de proyecto**: o entra como apéndice 🔥, o se declara fuera de alcance en `alcance-del-proyecto.md` para que ninguna fase posterior lo prometa.
- **Los activos no se borran y el modelo no tiene cómo darlos de baja.** `Asset` no tiene `decommissionedAt` ni `status`, así que hoy un activo vive para siempre. Añadir ese campo toca `db.seed.json`, y la Fase 3 avisó de lo caro que se vuelve eso con las fases encima. → **Aviso para el chat de la Fase 9**, que es donde el ciclo de vida de las entidades vuelve a aparecer.
- **Esta fase no reserva ningún ID de incidente.** Hereda el **07** de la Fase 5 como asociado, y el 08 y el 09 pertenecen a la Fase 7. El CRUD produjo al menos dos candidatos buenos —el control `PENDING` eterno del ejercicio 19 y el doble guardado del 29— que hoy viven sólo como ejercicios. Meterlos en el cuaderno exige renumerar de la Fase 7 en adelante. → **Decisión de proyecto**, no de este chat.
- **`ClientStateService` y `AssetStateService` empiezan a parecerse demasiado**, y son los servicios tres y cuatro del mismo molde. La Fase 4 defendió la repetición con un argumento concreto: que la Fase 7 iba a necesitar uno distinto. Cuando esa fase llegue, conviene volver aquí y comprobar si el argumento se sostuvo. → **Aviso para el chat de la Fase 7.**
- **El `CanDeactivate` del ejercicio 🔥 deja de ser opcional en la Fase 8.** Un formulario dinámico de veinte controles que se pierde al navegar es un ticket garantizado, y escribirlo entonces desde cero cuesta más que heredarlo hecho. → **Aviso para el chat de la Fase 8.**
- **El tema de Material queda cerrado hoy** (5.1). Cualquier fase posterior que necesite un color nuevo lo saca de la paleta existente o de una clase propia. Si alguna necesita una paleta más, hay que volver aquí y no improvisar allá. → **Regla de proyecto, ya escrita.**
- 🔥 **Un diagrama del ciclo de un formulario** —`valid` / `invalid` / `pending` / `disabled` cruzado con `pristine` / `dirty` / `touched`— resolvería medio ejercicio 18 y toda la sección 6. Es el cuarto pendiente de ilustración del curso. Pendiente de dibujo, no de contenido.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| — | Esta fase no reserva ID nuevo: hereda el **07** de la Fase 5 y le da la pantalla real donde reproducirlo | Integración | 🟡 |
