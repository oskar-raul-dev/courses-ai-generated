# 📋 Fase 07 — Plantillas versionadas ⭐

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 7 de 14 · **14 horas**
> Depende de: Fase 6 (clientes y activos) · Habilita: Fases 8 a 11
> Apéndices de apoyo: [A05 (Formularios reactivos tipados)](a05-formularios-tipados.md) · [A06 (RxJS 7)](a06-rxjs.md) · [A07 (Estado con servicios)](a07-estado-servicios.md)
> [Incidentes asociados](cuaderno-incidentes.md): 08, 09
> Estilo de esta fase: **nuevo**, con dos costuras 🧬 hacia el `TemplatesModule` heredado

---

## 🎯 1. Propósito

Ésta es la fase que justifica el curso. Todo lo anterior —el estado, los formularios, la convivencia de estilos, el mock con caos— era herramienta; el problema que CertCore resuelve de verdad empieza aquí.

Una plantilla de checklist no es un formulario guardado: es una **norma con fecha**. Cuando la norma cambia nace una v2, y desde ese día las inspecciones nuevas se hacen con la v2. Lo que no puede pasar —nunca, bajo ninguna circunstancia, ni para arreglar otra cosa— es que una inspección ejecutada en agosto de 2023 con la v1 se vuelva a pintar con la v2. Si eso ocurre, el certificado que salió de esa inspección deja de ser defendible, y un certificado que no se puede defender no vale nada.

Vas a construir cuatro cosas: el modelo de familia de versiones, la función que contesta *"¿qué versión rige el día D?"* con sus tres respuestas posibles, el editor que crea la v2 a partir de la v1 sin tocarla, y la publicación — que son **dos escrituras sin transacción** y por eso es la operación más peligrosa del sistema.

Y una quinta, que no es código: aprender a distinguir la pregunta *"¿qué versión rige hoy?"* de la pregunta *"¿con qué versión se hizo esto?"*. Se parecen tanto que el código que contesta una acaba contestando la otra, y ése es literalmente el incidente 08.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `resolveTemplateVersion(versions, day)` existe, es pura, y devuelve **tres** resultados distintos: `resolved`, `none` y `ambiguous`. Ninguno de los tres es `null`.
- [ ] `/templates` lista familias —no versiones sueltas— y `/templates/elevator-annual` muestra su línea de tiempo con las dos vigencias.
- [ ] En esa pantalla puedes escribir una fecha cualquiera y ver qué versión resolvía ese día: con `2023-08-02` sale la v1 y con `2024-03-15` sale la v2.
- [ ] El editor crea la v3 de `elevator-annual` a partir de la v2, y al publicarla **la v2 queda cerrada el día anterior**: en `db.json` hay tres filas y ningún día con dos vigentes.
- [ ] Provocaste a mano un hueco y un solape, y la pantalla los nombra en vez de elegir en silencio.
- [ ] `CERTCORE_TIME_ZONE_OFFSET` está en un solo archivo y todo el cálculo de días pasa por `toBusinessDay()`. No queda ningún `new Date()` suelto donde importe el día.
- [ ] Abriste la inspección **501** y confirmaste en Network que su petición lleva `version=1`. Sigue teniendo tres ítems, no cuatro.
- [ ] `git tag` lista `fase-07`.

---

## 🚫 3. Qué NO entra todavía

- **El motor de render del checklist** —pintar los ítems de una plantilla como formulario y guardar respuestas— → Fase 8. Hoy la plantilla se edita como definición, no se rellena.
- **Los hallazgos derivados** de `nonComplianceSeverity` → Fase 9. El campo existe desde la Fase 3 y aquí sólo se edita.
- **La migración de respuestas entre versiones** → fuera de alcance, y conviene decir por qué: convertir una respuesta de la v1 al formato de la v2 significa **inventar el dato de un ítem que nadie inspeccionó**. En un sistema de certificaciones eso no es una funcionalidad ausente: es una funcionalidad prohibida. El ejercicio 32 te hace diseñarla para que veas dónde se rompe.
- **Borrar una versión** → no existe la operación. Una versión publicada se cierra; no se borra. La sección 5.4 explica por qué el `delete` no está.
- **Un endpoint transaccional para publicar** → es trabajo de backend y queda como ejercicio 31, con su 📌.
- **Signals y control flow nuevo** → Fase 12 y **A11**.

---

## 🧠 4. Concepto mínimo

### El problema, antes que la herramienta

En 2021 CertCore tenía una plantilla de ascensores y nadie hablaba de versiones: la plantilla era un objeto con sus ítems, y editarla era editar el objeto. Funcionó dos años.

En 2023 cambió la norma: el cable principal ya no se inspecciona sólo por desgaste sino también por tensión, y hay que revisar la iluminación de cabina. Alguien editó la plantilla, cambió el título del ítem y añadió el ítem nuevo. Al día siguiente, un cliente pidió el respaldo de una inspección de junio y el sistema le mostró **una inspección con cuatro ítems, uno de ellos vacío**, y con el título del primer ítem cambiado respecto al papel que el inspector había firmado.

Nadie borró un dato. La inspección seguía teniendo sus tres respuestas. Lo que cambió fue **el molde con el que se lee**, y eso basta para que un documento firmado deje de coincidir consigo mismo.

De ahí salió el modelo que vas a construir hoy: la plantilla dejó de ser un objeto que se edita y pasó a ser **una fila por versión**, con `templateId` como identificador lógico, `version` como número, y `validFrom` / `validUntil` como su ventana de vigencia. Y cada inspección guarda el `templateVersion` con el que se ejecutó.

> 🧭 **El invariante que ordena el sistema entero: una inspección se lee siempre con la versión de plantilla con la que se ejecutó.** No con la vigente, no con la más nueva, no con la que el usuario tenga seleccionada. Con la suya, la que está escrita en su propio campo `templateVersion`. Todo lo demás de esta fase existe para proteger esa frase.

### Dos preguntas que se parecen y no son la misma

Aquí está el 80% del valor de la fase, y cabe en dos líneas de código.

**Pregunta 1 — *"¿Qué versión rige el día D?"*** Se hace **una sola vez**: cuando se va a empezar una inspección nueva. Su respuesta depende de una fecha y puede cambiar mañana.

```ts
const resolution = resolveTemplateVersion(family.versions, today);
```

**Pregunta 2 — *"¿Con qué versión se hizo esta inspección?"*** Se hace **cada vez que se abre una inspección existente**. Su respuesta está escrita en la propia inspección y no depende de nada más. No cambia nunca.

```ts
const template$ = this.templateApi.getByVersion(inspection.templateId, inspection.templateVersion);
```

Las dos devuelven un `ChecklistTemplate`. Las dos parecen "conseguir la plantilla". Y usar la primera donde va la segunda es el bug más caro que este sistema puede tener, porque **no falla**: pinta una pantalla perfectamente creíble con los datos equivocados. Nadie ve una excepción; alguien ve un certificado que no coincide con su respaldo, seis meses después, delante de un auditor.

> ⚠️ **La señal de alarma, en una línea:** si estás mirando una inspección **ya existente** y la petición al backend no lleva `version=` en la URL, hay un bug. No hace falta leer el código: la URL lo dice.

### Las tres respuestas de resolver por fecha

La tentación es que `resolveTemplateVersion` devuelva `ChecklistTemplate | null`. Y es un error, porque `null` mete en la misma bolsa dos situaciones que no se parecen en nada.

**`resolved`** — exactamente una versión cubre ese día. Es el caso normal.

**`none`** — ninguna versión cubre ese día. Pasa cuando hay un hueco entre la `validUntil` de una y la `validFrom` de la siguiente, casi siempre por un error de un día al publicar. Consecuencia: no se puede empezar una inspección. Molesto, ruidoso, y **inofensivo**: nadie va a hacer una inspección mal, sencillamente no la va a poder empezar.

**`ambiguous`** — dos o más versiones cubren ese día. Pasa cuando la publicación cerró mal la anterior. Consecuencia: hay que elegir, y **cualquier elección automática es una mentira**. Si el código coge "la de número más alto" tapa el error de datos y produce inspecciones cuya versión depende de un detalle de implementación.

> 🧠 **El modelo mental:** un `null` que significa dos cosas obliga a quien lo recibe a adivinar cuál de las dos era. Una unión discriminada convierte esa adivinanza en un `switch` que el compilador te obliga a completar. Es la misma razón por la que el modelo de la Fase 3 distingue `validUntil: string | null` de `validUntil?: string`.

### "La más nueva" no es "la vigente"

La Fase 4 dejó un derivado llamado `latestVersions$`: la versión de número más alto de cada familia. Es útil —el editor la usa como punto de partida— y **no contesta la pregunta de la vigencia**. Publica hoy una v3 con `validFrom: '2026-01-01'` y tendrás una versión más alta que no rige, y no regirá durante meses.

Confundir las dos es una línea de código y un ticket. Por eso `latestVersions$` sobrevive en el servicio con un comentario que dice exactamente para qué sirve y para qué no.

### Días de calendario frente a instantes

Las fechas de una plantilla —`validFrom`, `validUntil`— son **días de calendario**: `'2024-01-01'`, sin hora y sin huso. Comparar dos días así es comparar dos cadenas ISO, y eso es una virtud enorme: `'2023-08-02' <= '2023-12-31'` es cierto sin construir un solo `Date`, sin husos y sin sorpresas de fin de mes.

El huso aparece en un solo sitio: cuando hay que convertir **un instante** —`startedAt: '2024-03-15T09:00:00-05:00'`— en el día que el negocio considera. Y ahí sí importa, porque una inspección iniciada a las 23:30 hora de Bogotá ocurre, en UTC, al día siguiente. Si esa conversión la hace el navegador con su huso local, la respuesta depende de dónde esté sentada la persona que abre la pantalla.

Por eso esta fase fija la zona de referencia en un archivo y todo el cálculo de días pasa por ahí. La Fase 10, que vive de esto para la vigencia de los certificados, va a reutilizar esa constante en vez de crear una segunda.

> 📝 **Nota de migración.** `FormArray` es de Angular 2, pero el `FormArray<FormGroup<T>>` **tipado** que usa el editor de 5.8 llegó con los formularios genéricos de la 14 (2022). CertCore migró a 16 durante 2024 y por eso puede escribirlo así hoy; el `LoginComponent` de la Fase 2, escrito antes, arrastra su `FormControl<string | null>` sin decidir. Los dos conviven, y ninguno es un error: uno es de antes de que se pudiera y el otro es de después. La diferencia se ve mejor que en ningún otro sitio en el editor de esta fase, donde el tipo del formulario **es** el contrato con el backend.

---

## 💻 5. Código mínimo con comentarios

### 5.1 El día de calendario, y la zona horaria de CertCore

```ts
// src/app/core/time/business-day.ts

/**
 * Un día de calendario en ISO: 'YYYY-MM-DD'. NO es un instante y no lleva hora
 * ni huso. Es lo que significan `validFrom` y `validUntil` de una plantilla, y
 * dos días de éstos se comparan con < y > como cadenas, sin construir un Date.
 *
 * Es un alias de `string` y no un tipo nominal: en TypeScript, un tipo de
 * marca daría más seguridad y costaría un `as` en cada frontera con el
 * backend, que es donde los `as` hacen daño. La disciplina la sostiene el
 * nombre y la revisión, no el compilador. Ejercicio 🔥.
 */
export type BusinessDay = string;

/**
 * La zona horaria de referencia del negocio. CertCore opera en Colombia, que
 * no tiene horario de verano, así que un desplazamiento fijo es correcto y no
 * hace falta Intl para esto.
 *
 * ⚠️ Si algún día CertCore opera en una zona CON horario de verano, este
 * archivo entero cambia: haría falta `Intl.DateTimeFormat` con `timeZone`, no
 * un número. Está escrito aquí para que ese día se cambie UN archivo.
 *
 * 🧭 Ésta es la única definición de zona horaria del proyecto. La Fase 10, que
 * calcula la vigencia de los certificados, la reutiliza. Una segunda constante
 * en otro archivo sería el bug de zona horaria más caro y más difícil de ver.
 */
export const CERTCORE_TIME_ZONE_OFFSET = '-05:00';

/** El desplazamiento de arriba, en minutos. Se calcula una vez. */
const OFFSET_MINUTES = parseOffsetMinutes(CERTCORE_TIME_ZONE_OFFSET);

/**
 * Convierte un instante con offset —como los `startedAt` del mock— en el día
 * de calendario que ve el negocio.
 *
 * Éste es el ÚNICO sitio del proyecto donde un instante se convierte en día.
 * Si aparece un segundo, aparecerá también el primer bug de zona horaria.
 */
export function toBusinessDay(instant: string): BusinessDay {
  const parsed = new Date(instant);

  if (Number.isNaN(parsed.getTime())) {
    throw new Error(`No es un instante válido: "${instant}".`);
  }

  // Se desplaza el instante a la zona de referencia y se lee la parte de fecha
  // en UTC. Leerla con getFullYear() usaría el huso del NAVEGADOR, que es
  // justamente lo que este archivo existe para evitar.
  const shifted = new Date(parsed.getTime() + OFFSET_MINUTES * 60_000);

  return shifted.toISOString().slice(0, 10);
}

/** Hoy, en la zona del negocio. El único `new Date()` sin argumentos del proyecto. */
export function todayInBusinessZone(): BusinessDay {
  return toBusinessDay(new Date().toISOString());
}

/**
 * Suma (o resta) días a un día de calendario. Se usa al publicar, para cerrar
 * la versión anterior el día antes de que empiece la nueva.
 */
export function addDays(day: BusinessDay, delta: number): BusinessDay {
  // Date.UTC evita el huso local por completo: aquí sólo se hace aritmética de
  // calendario, y hacerla en UTC es lo que la vuelve predecible.
  const [year, month, dayOfMonth] = day.split('-').map(Number);
  const shifted = new Date(Date.UTC(year, month - 1, dayOfMonth + delta));

  return shifted.toISOString().slice(0, 10);
}

/** Estrecha un valor desconocido —un parámetro de ruta, por ejemplo— a día válido. */
export function isBusinessDay(value: unknown): value is BusinessDay {
  return typeof value === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(value);
}

function parseOffsetMinutes(offset: string): number {
  const match = /^([+-])(\d{2}):(\d{2})$/.exec(offset);

  if (match === null) {
    throw new Error(`Offset de zona horaria mal formado: "${offset}".`);
  }

  const [, sign, hours, minutes] = match;
  const total = Number(hours) * 60 + Number(minutes);

  return sign === '-' ? -total : total;
}
```

**Detalles con intención**

- **`addDays` con `Date.UTC` y no con `setDate`.** `setDate` opera en el huso local del navegador y en una zona con horario de verano puede devolver el mismo día dos veces. Aquí no hay horario de verano y aun así se escribe bien: el día que CertCore abra en otro país, este archivo ya está preparado.
- **`toBusinessDay` lanza en vez de devolver `null`.** Un instante mal formado es un dato corrupto, no una situación de negocio. Y el mensaje va en español, como todos los mensajes dirigidos a otro desarrollador.

**Prueba de fuego**

Convierte estos cuatro instantes y compara: `'2024-03-15T09:00:00-05:00'` → `2024-03-15`. `'2024-03-15T23:30:00-05:00'` → `2024-03-15`, aunque en UTC ya sea día 16. Ahora `'2024-03-15T23:30:00Z'` → `2024-03-15`, porque en Bogotá son las 18:30. Y por último, `'2024-03-16T02:00:00Z'` → `2024-03-15`. Si alguno de los cuatro te da otro día, tu `OFFSET_MINUTES` tiene el signo cambiado — que es, con diferencia, el error más común de este archivo.

### 5.2 La familia: agrupar versiones sin inventar una entidad

El backend guarda **filas de versión**, no familias. La familia es una vista del cliente, y por eso se calcula en vez de guardarse — la misma decisión que la Fase 4 tomó con los derivados.

```ts
// src/app/core/domain/template-family.ts
import { ChecklistTemplate } from '../models/checklist-template.model';

/**
 * Todas las versiones de una misma plantilla lógica, ordenadas de la más
 * antigua a la más nueva. No existe en el backend: se calcula agrupando por
 * `templateId`. Guardarla sería tener dos fuentes de verdad para lo mismo.
 */
export interface TemplateFamily {
  readonly templateId: string;
  /** Ordenadas por `version` ascendente. Nunca vacía. */
  readonly versions: readonly ChecklistTemplate[];
  /**
   * La de número más alto. ⚠️ NO es "la vigente": una versión publicada con
   * `validFrom` en el futuro es la más alta y no rige todavía. Para saber cuál
   * rige un día concreto está `resolveTemplateVersion`, y no hay atajo.
   */
  readonly latest: ChecklistTemplate;
}

export function groupIntoFamilies(
  templates: readonly ChecklistTemplate[],
): readonly TemplateFamily[] {
  const byTemplateId = new Map<string, ChecklistTemplate[]>();

  for (const template of templates) {
    const group = byTemplateId.get(template.templateId);

    if (group === undefined) {
      byTemplateId.set(template.templateId, [template]);
    } else {
      // Se muta el array LOCAL del Map, que nadie más ha visto todavía. Mutar
      // lo que acabas de crear no es lo que la 💸 de la Fase 4 prohibía;
      // prohibía mutar lo que ya está publicado en el estado.
      group.push(template);
    }
  }

  return [...byTemplateId.entries()]
    .map(([templateId, group]) => {
      const versions = [...group].sort((a, b) => a.version - b.version);
      // El grupo nunca está vacío —se creó con un elemento dentro—, así que el
      // último existe. Se escribe con reduce y no con versions[length - 1]
      // para que el tipo salga `ChecklistTemplate` y no `... | undefined`.
      const latest = versions.reduce((best, current) =>
        current.version > best.version ? current : best,
      );

      return { templateId, versions, latest };
    })
    .sort((a, b) => a.templateId.localeCompare(b.templateId));
}
```

### 5.3 ⭐ `resolveTemplateVersion`: la función que citan cuatro incidentes

```ts
// src/app/core/domain/resolve-template-version.ts
import { ChecklistTemplate } from '../models/checklist-template.model';
import { BusinessDay } from '../time/business-day';

/**
 * El resultado de preguntar "¿qué versión rige el día D?". Son TRES respuestas
 * y no dos, porque `ChecklistTemplate | null` mete en la misma bolsa el hueco
 * —molesto e inofensivo— y el solape —silencioso y peligroso—, que se
 * diagnostican distinto y se arreglan distinto.
 */
export type TemplateResolution =
  | { readonly status: 'resolved'; readonly template: ChecklistTemplate }
  | { readonly status: 'none'; readonly day: BusinessDay }
  | { readonly status: 'ambiguous'; readonly candidates: readonly ChecklistTemplate[] };

/**
 * ¿Esta versión cubre este día? Los dos extremos son INCLUSIVE: una versión
 * que va del 1 de enero al 31 de diciembre rige los dos días. `validUntil:
 * null` significa "vigente indefinidamente", tal como lo definió el modelo de
 * la Fase 3 — y no "sin decidir".
 */
export function appliesOn(template: ChecklistTemplate, day: BusinessDay): boolean {
  // Comparación de cadenas, no de Date. Con el formato 'YYYY-MM-DD' el orden
  // lexicográfico y el cronológico son el mismo, y eso ahorra el huso horario
  // entero. Es la razón de que estos campos NO lleven hora.
  return template.validFrom <= day && (template.validUntil === null || day <= template.validUntil);
}

/**
 * Resuelve qué versión rige un día.
 *
 * ⚠️ `versions` tiene que ser UNA familia: todas con el mismo `templateId`. Si
 * le pasas versiones mezcladas, el resultado es basura con buena pinta —dos
 * plantillas distintas vigentes el mismo día son un `ambiguous` que no lo es—.
 * Quien tiene las familias bien formadas es `groupIntoFamilies`, y por eso
 * esta función recibe versiones y no un `templateId`: así no necesita saber de
 * dónde salieron ni hablar con nadie. El ejercicio 25 te hace decidir si eso
 * merece una comprobación en tiempo de ejecución.
 */
export function resolveTemplateVersion(
  versions: readonly ChecklistTemplate[],
  day: BusinessDay,
): TemplateResolution {
  const matches = versions.filter((version) => appliesOn(version, day));

  if (matches.length === 0) {
    // Se devuelve el día dentro del resultado para que quien lo pinte pueda
    // decir "no hay plantilla vigente el 15 de enero de 2024" y no un genérico
    // "no hay plantilla", que no se puede diagnosticar.
    return { status: 'none', day };
  }

  if (matches.length > 1) {
    // NO se elige la más alta. Elegir aquí taparía un error de datos y haría
    // que la versión con la que se ejecuta una inspección dependiera de un
    // detalle de implementación. Se devuelven las candidatas para que la
    // pantalla las enseñe y alguien arregle las fechas. Incidente 09.
    return { status: 'ambiguous', candidates: matches };
  }

  const [only] = matches;

  if (only === undefined) {
    // Inalcanzable: length === 1. Está aquí porque `matches[0]` se tipa como
    // ChecklistTemplate aunque el array pudiera estar vacío, y prefiero una
    // guarda explícita a un aserto de no-nulo, que en CertCore no se usa.
    return { status: 'none', day };
  }

  return { status: 'resolved', template: only };
}
```

**Detalles con intención**

- **Pura y sin `Observable`.** No inyecta nada, no pide nada, no guarda nada. La Fase 12 la va a testear con una tabla de casos y sin `TestBed`, que es la diferencia entre un test de dos líneas y uno de veinte.
- **Recibe `versions` y no `templateId`.** Buscar es trabajo del servicio de estado; decidir es trabajo de esta función. Mezclarlo es cómo una regla de negocio acaba necesitando una petición HTTP para poder probarse.

**La tabla de bordes**, que conviene tener delante al escribir los tests de la Fase 12:

| Situación | `versions` | `day` | Resultado |
|---|---|---|---|
| Caso normal | v1 hasta 2023-12-31, v2 desde 2024-01-01 | `2023-08-02` | `resolved` v1 |
| Primer día de vigencia | v2 desde 2024-01-01 | `2024-01-01` | `resolved` v2 |
| Último día de vigencia | v1 hasta 2023-12-31 | `2023-12-31` | `resolved` v1 |
| Antes de todo | v1 desde 2021-01-01 | `2020-12-31` | `none` |
| Hueco entre versiones | v1 hasta 2023-12-31, v2 desde 2024-02-01 | `2024-01-15` | `none` |
| Solape por mal cierre | v1 sin `validUntil`, v2 desde 2024-01-01 | `2024-06-01` | `ambiguous` |
| Vigente indefinidamente | v2 desde 2024-01-01, `validUntil: null` | `2030-01-01` | `resolved` v2 |
| Familia vacía | `[]` | cualquiera | `none` |

### 5.4 Lo que `TemplateApiService` aprende hoy

```ts
// src/app/core/api/template-api.service.ts — lo que se añade
import { HttpParams } from '@angular/common/http';

import { BusinessDay } from '../time/business-day';

/** El `id` de la fila, compuesto. Se arma en un solo sitio para que nadie lo teclee. */
export function buildTemplateRowId(templateId: string, version: number): string {
  return `${templateId}-v${version}`;
}

// …dentro de TemplateApiService…

  /** Todas las versiones de una familia. El orden lo pone `groupIntoFamilies`. */
  getFamily(templateId: string): Observable<readonly ChecklistTemplate[]> {
    const params = new HttpParams().set('templateId', templateId);

    return this.http
      .get<readonly ChecklistTemplate[]>(this.baseUrl, { params })
      .pipe(catchError(toApiError));
  }

  /**
   * Crea una versión. El `id` compuesto viaja en el cuerpo: json-server lo
   * respeta si se lo das, y aquí lo damos porque la clave es del dominio y no
   * del backend. Si lo dejáramos autogenerar, tendríamos dos identificadores
   * para la misma cosa.
   */
  create(template: ChecklistTemplate): Observable<ChecklistTemplate> {
    return this.http.post<ChecklistTemplate>(this.baseUrl, template).pipe(catchError(toApiError));
  }

  /**
   * Cierra una versión poniéndole fecha de fin. Es lo único que se le puede
   * cambiar a una versión publicada: sus ítems son historia y el histórico no
   * se edita.
   */
  close(template: ChecklistTemplate, lastDay: BusinessDay): Observable<ChecklistTemplate> {
    const closed: ChecklistTemplate = { ...template, validUntil: lastDay };

    return this.http
      .put<ChecklistTemplate>(`${this.baseUrl}/${template.id}`, closed)
      .pipe(catchError(toApiError));
  }

  // Sin delete(), y esta vez no es alcance: es dominio. Borrar una versión deja
  // huérfanas a todas las inspecciones que la usaron, y una inspección sin su
  // plantilla es un certificado que no se puede volver a imprimir. Una versión
  // se cierra; no se borra. Que la operación no exista es la mejor forma de
  // impedirla.
```

### 5.5 El molde que no encaja, y cómo se rompe bien

La Fase 4 escribió `FeatureState<T>` con `items` y `selected`, y renunció a una clase base genérica diciendo en voz alta que alguna feature iba a necesitar otra forma. Es ésta.

Lo que no encaja no es el contenedor: es que **la unidad de trabajo no es una fila**. Cuando el usuario "selecciona una plantilla" no selecciona una versión, selecciona una **familia**, y después mira su historia. Un `selected: ChecklistTemplate | null` no puede expresar eso; obligaría a la pantalla a mantener por su cuenta cuál familia está abierta, que es exactamente el estado que este servicio existe para no repartir.

```ts
// src/app/core/state/template-state.service.ts
import { Injectable, inject } from '@angular/core';
import {
  BehaviorSubject,
  Observable,
  catchError,
  combineLatest,
  concatMap,
  distinctUntilChanged,
  filter,
  map,
  of,
  tap,
} from 'rxjs';

import { ApiError } from '../api/api-error';
import { TemplateApiService, buildTemplateRowId } from '../api/template-api.service';
import { AuthService } from '../auth.service';
import {
  TemplateFamily,
  groupIntoFamilies,
} from '../domain/template-family';
import {
  TemplateResolution,
  resolveTemplateVersion,
} from '../domain/resolve-template-version';
import { ChecklistItem, ChecklistTemplate } from '../models/checklist-template.model';
import { BusinessDay, addDays } from '../time/business-day';

/**
 * El estado de esta feature NO es `FeatureState<ChecklistTemplate>`, y es la
 * primera vez que el molde de la Fase 4 se queda corto. Dos diferencias:
 *
 *   - `versions` en vez de `items`: son filas de versión, no entidades sueltas,
 *     y la pantalla siempre las mira agrupadas.
 *   - `selectedFamilyId` en vez de `selected`: se selecciona una FAMILIA, que
 *     es un concepto que no existe como fila en el backend.
 *
 * Todo lo demás del molde se mantiene igual, porque lo demás sí servía: sujeto
 * privado, Observable público de sólo lectura, un único `patch()`, `readonly`
 * de punta a punta y reseteo al cerrar sesión. Romper un patrón no es tirarlo:
 * es cambiar la pieza que estorba y dejar quietas las que no.
 */
export interface TemplateState {
  readonly versions: readonly ChecklistTemplate[];
  readonly selectedFamilyId: string | null;
  readonly loading: boolean;
  readonly error: string | null;
}

function createInitialTemplateState(): TemplateState {
  return { versions: [], selectedFamilyId: null, loading: false, error: null };
}

/** Lo que el editor entrega para publicar. Sin `id` ni `validUntil`: los pone el servicio. */
export interface NewVersionDraft {
  readonly templateId: string;
  readonly version: number;
  readonly validFrom: BusinessDay;
  readonly items: readonly ChecklistItem[];
}

@Injectable({ providedIn: 'root' })
export class TemplateStateService {
  private readonly templateApi = inject(TemplateApiService);
  private readonly authService = inject(AuthService);

  private readonly stateSubject = new BehaviorSubject<TemplateState>(createInitialTemplateState());

  readonly state$: Observable<TemplateState> = this.stateSubject.asObservable();

  readonly loading$ = this.state$.pipe(map((state) => state.loading), distinctUntilChanged());
  readonly error$ = this.state$.pipe(map((state) => state.error), distinctUntilChanged());

  readonly families$: Observable<readonly TemplateFamily[]> = this.state$.pipe(
    map((state) => groupIntoFamilies(state.versions)),
    distinctUntilChanged(),
  );

  readonly selectedFamily$: Observable<TemplateFamily | null> = combineLatest([
    this.families$,
    this.state$.pipe(map((state) => state.selectedFamilyId), distinctUntilChanged()),
  ]).pipe(
    map(([families, selectedFamilyId]) =>
      selectedFamilyId === null
        ? null
        : families.find((family) => family.templateId === selectedFamilyId) ?? null,
    ),
  );

  /**
   * ⚠️ "La más alta de cada familia", que NO es "la vigente". Sigue aquí porque
   * el editor la usa como punto de partida —se edita a partir de la última—,
   * y con ese uso es correcta. Usarla para decidir con qué plantilla se hace
   * una inspección es el incidente 08. La pregunta de la vigencia la contesta
   * `resolveForDay()`, y no hay atajo.
   */
  readonly latestVersions$: Observable<readonly ChecklistTemplate[]> = this.families$.pipe(
    map((families) => families.map((family) => family.latest)),
  );

  constructor() {
    this.authService.currentUser$
      .pipe(filter((user) => user === null))
      .subscribe(() => this.reset());
  }

  load(): void {
    this.patch({ loading: true, error: null });

    this.templateApi.getAll().subscribe({
      next: (versions) => this.patch({ versions, loading: false }),
      error: (error: unknown) => {
        this.patch({
          loading: false,
          error:
            error instanceof ApiError ? error.message : 'No se pudieron cargar las plantillas.',
        });
      },
    });
  }

  selectFamily(templateId: string | null): void {
    this.patch({ selectedFamilyId: templateId });
  }

  /**
   * ¿Qué versión de esta familia rige este día? Es una CONSULTA, no estado: no
   * guarda nada y su respuesta caduca. Por eso devuelve un Observable derivado
   * y no hay ningún `resolvedTemplate` dentro de `TemplateState`.
   */
  resolveForDay(templateId: string, day: BusinessDay): Observable<TemplateResolution> {
    return this.families$.pipe(
      map((families) => families.find((family) => family.templateId === templateId)),
      map((family) =>
        family === undefined
          ? ({ status: 'none', day } satisfies TemplateResolution)
          : resolveTemplateVersion(family.versions, day),
      ),
    );
  }

  /**
   * ⭐ PUBLICAR. La operación más peligrosa del sistema, y merece leerse dos
   * veces: son DOS escrituras y el backend no tiene transacciones.
   *
   * Orden elegido: primero se CIERRA la anterior, después se CREA la nueva.
   * Si falla la segunda, queda un hueco —`none`— y nadie puede empezar una
   * inspección hasta que alguien lo arregle: ruidoso, visible e inofensivo.
   * Con el orden contrario, un fallo dejaría dos versiones vigentes a la vez
   * —`ambiguous`—, y ahí el daño depende de que todo el que consulte se niegue
   * a elegir. Nuestro resolver se niega; el reporte que alguien escriba dentro
   * de dos años, quizá no.
   *
   * Lo correcto de verdad es un endpoint que haga las dos cosas o ninguna.
   * Eso es trabajo de backend, está en los 📌 y es el ejercicio 31.
   */
  publishNewVersion(
    draft: NewVersionDraft,
    previous: ChecklistTemplate | null,
  ): Observable<ChecklistTemplate> {
    const created: ChecklistTemplate = {
      id: buildTemplateRowId(draft.templateId, draft.version),
      templateId: draft.templateId,
      version: draft.version,
      validFrom: draft.validFrom,
      // Nace abierta: la que se cierra es la anterior. Una versión con fecha de
      // fin en el momento de nacer sería una versión que ya sabe cuándo muere,
      // y eso lo decide la norma siguiente, que todavía no existe.
      validUntil: null,
      items: draft.items,
    };

    const close$: Observable<ChecklistTemplate | null> =
      previous === null || previous.validUntil !== null
        ? // No hay anterior, o ya estaba cerrada. `of(null)` mantiene la tubería
          // con una sola forma en vez de partir el método en dos caminos.
          of(null)
        : this.templateApi.close(previous, addDays(draft.validFrom, -1));

    return close$.pipe(
      // concatMap y NO switchMap. Es la regla que la Fase 6 dejó escrita: para
      // leer, switchMap; para escribir, jamás. Cancelar el cierre a mitad
      // dejaría el sistema en el peor de los dos estados rotos.
      concatMap(() => this.templateApi.create(created)),
      tap(() => this.load()),
    );
  }

  /** Retirar una familia: cerrar su versión abierta y no crear ninguna. */
  retire(template: ChecklistTemplate, lastDay: BusinessDay): Observable<ChecklistTemplate> {
    return this.templateApi.close(template, lastDay).pipe(tap(() => this.load()));
  }

  reset(): void {
    this.stateSubject.next(createInitialTemplateState());
  }

  private patch(changes: Partial<TemplateState>): void {
    this.stateSubject.next({ ...this.stateSubject.value, ...changes });
  }
}
```

**Detalles con intención**

- **`resolveForDay` no guarda su resultado.** La tentación de meter un `currentTemplate` en el estado es fuerte y es exactamente el error de diseño de los certificados que la Fase 10 va a desmontar: un dato derivado guardado empieza a mentir en cuanto cambia el reloj o los datos de los que salió.
- **`satisfies TemplateResolution` en el caso de familia inexistente.** Comprueba que el objeto literal cumple la unión sin ensanchar su tipo, que es justo lo que se quiere en un `map`.
- **El reseteo al cerrar sesión sobrevive al cambio de forma.** Era del molde de la Fase 4 y sigue siendo correcto: lo que cambió es qué se guarda, no quién lo tiene que limpiar.

### 5.6 🧬 Las dos costuras con el módulo heredado

`TemplatesModule` es uno de los nueve módulos que la Fase 5 congeló, y hoy tiene que alojar dos pantallas nuevas. Misma solución que los activos en la Fase 6: el módulo heredado importa componentes standalone y sus rutas los apuntan con `component:`.

```ts
// src/app/features/templates/templates.module.ts
@NgModule({
  declarations: [TemplateListComponent],
  imports: [
    SharedModule,
    TemplatesRoutingModule,
    // 🧬 Dos pantallas de 2025 alojadas por un módulo de 2021. Van en `imports`
    // porque son standalone; en `declarations` no compilaría, y el mensaje de
    // error te lo diría — es el ejercicio 6 de la Fase 5.
    TemplateVersionsComponent,
    TemplateEditorComponent,
  ],
})
export class TemplatesModule {}
```

```ts
// src/app/features/templates/templates-routing.module.ts
// 🧬 RouterModule.forChild() heredado apuntando a componentes standalone.
// `component:` y no `loadComponent:`: los tres viajan ya en el chunk de este
// módulo, así que diferirlos otra vez no ahorraría nada.
const routes: Routes = [
  { path: '', component: TemplateListComponent },
  { path: ':templateId', component: TemplateVersionsComponent },
  { path: ':templateId/new-version', component: TemplateEditorComponent },
];
```

Y el listado heredado, que pasa de enumerar versiones sueltas a enumerar familias. **Se toca lo mínimo y en su estilo**: sigue con `constructor`, sigue sin `OnPush`, sigue declarado.

```ts
// src/app/features/templates/template-list/template-list.component.ts
import { Component, OnInit } from '@angular/core';
import { Observable } from 'rxjs';

import { TemplateFamily } from '../../../core/domain/template-family';
import { TemplateStateService } from '../../../core/state/template-state.service';

@Component({
  selector: 'cc-template-list',
  templateUrl: './template-list.component.html',
})
export class TemplateListComponent implements OnInit {
  readonly families$: Observable<readonly TemplateFamily[]>;

  // Componente de 2021: inyección por constructor y detección por defecto.
  // Cambiar la FORMA del estado obliga a tocarlo —el `state$` que consumía ya
  // no tiene `items`—, y se toca sólo para eso. Modernizar de paso es cómo se
  // rompen otras tres cosas.
  constructor(private readonly templateState: TemplateStateService) {
    this.families$ = templateState.families$;
  }

  ngOnInit(): void {
    this.templateState.load();
  }
}
```

```html
<!-- src/app/features/templates/template-list/template-list.component.html -->
<h2>Plantillas de checklist</h2>

<mat-nav-list>
  <a mat-list-item *ngFor="let family of families$ | async" [routerLink]="[family.templateId]">
    <span matListItemTitle>{{ family.templateId }}</span>
    <span matListItemLine>
      {{ family.versions.length }} versiones · la más reciente es la v{{ family.latest.version }}
    </span>
  </a>
</mat-nav-list>
```

### 5.7 La línea de tiempo de una familia

La pantalla que convierte el versionado en algo que se ve. Standalone, `OnPush`, y con el probador de fechas incorporado — que es la herramienta forense de esta fase vestida de funcionalidad.

```ts
// src/app/features/templates/template-versions/template-versions.component.ts
import { AsyncPipe, NgFor, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, OnInit, inject } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { Observable, combineLatest, startWith, switchMap } from 'rxjs';

import { TemplateResolution } from '../../../core/domain/resolve-template-version';
import { TemplateFamily } from '../../../core/domain/template-family';
import { TemplateStateService } from '../../../core/state/template-state.service';
import { BusinessDay, isBusinessDay, todayInBusinessZone } from '../../../core/time/business-day';
import { EmptyStateComponent } from '../../../shared/empty-state/empty-state.component';

@Component({
  selector: 'cc-template-versions',
  standalone: true,
  imports: [
    AsyncPipe,
    NgFor,
    NgIf,
    ReactiveFormsModule,
    RouterLink,
    MatButtonModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    EmptyStateComponent,
  ],
  templateUrl: './template-versions.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TemplateVersionsComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly templateState = inject(TemplateStateService);

  readonly templateId = this.route.snapshot.paramMap.get('templateId') ?? '';

  /**
   * El día que se está probando. Arranca en hoy y el usuario puede cambiarlo:
   * es la pregunta "¿qué versión regía el 2 de agosto de 2023?" convertida en
   * un campo de texto. nonNullable porque siempre hay un día en la caja.
   */
  readonly dayControl = new FormControl<BusinessDay>(todayInBusinessZone(), {
    nonNullable: true,
  });

  readonly family$: Observable<TemplateFamily | null> = this.templateState.selectedFamily$;

  readonly resolution$: Observable<TemplateResolution> = combineLatest([
    // valueChanges NO emite el valor inicial: sin el startWith, el probador se
    // quedaría en blanco hasta la primera tecla aunque ya tenga la fecha de hoy
    // escrita. Ponerlo aquí —y no con un BehaviorSubject aparte— mantiene una
    // sola fuente para el día.
    this.dayControl.valueChanges.pipe(startWith(this.dayControl.value)),
    // La familia entra en el combineLatest para que el resultado se recalcule
    // cuando el estado se recarga, por ejemplo al volver de publicar.
    this.family$,
  ]).pipe(
    // switchMap porque esto es una LECTURA: si el usuario sigue escribiendo, la
    // resolución anterior sobra.
    switchMap(([day]) => this.templateState.resolveForDay(this.templateId, day)),
  );

  ngOnInit(): void {
    this.templateState.selectFamily(this.templateId);
    this.templateState.load();
  }

  /** Para el `*ngIf` del formulario: un día mal escrito no se resuelve, se avisa. */
  isValidDay(day: string): boolean {
    return isBusinessDay(day);
  }
}
```

```html
<!-- src/app/features/templates/template-versions/template-versions.component.html -->
<h2>{{ templateId }}</h2>

<ng-container *ngIf="family$ | async as family; else noFamily">
  <a mat-raised-button color="primary" routerLink="new-version">
    <mat-icon>add</mat-icon>
    Nueva versión
  </a>

  <!-- La línea de tiempo. Una fila por versión, de la más antigua a la más
       nueva, con su ventana de vigencia escrita en claro. -->
  <ol class="version-timeline">
    <li *ngFor="let version of family.versions">
      <strong>v{{ version.version }}</strong>
      <span>
        Vigente desde {{ version.validFrom }}
        <ng-container *ngIf="version.validUntil !== null">
          hasta {{ version.validUntil }}
        </ng-container>
        <ng-container *ngIf="version.validUntil === null">
          · sin fecha de fin
        </ng-container>
      </span>
      <span>{{ version.items.length }} ítems</span>
    </li>
  </ol>

  <!-- El probador de fechas: la pieza forense de esta fase, en pantalla. -->
  <mat-form-field appearance="outline">
    <mat-label>¿Qué versión regía el día…?</mat-label>
    <input matInput [formControl]="dayControl" placeholder="AAAA-MM-DD" />
  </mat-form-field>

  <ng-container *ngIf="resolution$ | async as resolution">
    <p *ngIf="resolution.status === 'resolved'" class="resolution-ok">
      Ese día regía la <strong>v{{ resolution.template.version }}</strong>, con
      {{ resolution.template.items.length }} ítems.
    </p>

    <p *ngIf="resolution.status === 'none'" class="resolution-none">
      Ningún día cubre el {{ resolution.day }}. Hay un hueco entre versiones, y
      hoy no se podría empezar una inspección con esta fecha.
    </p>

    <p *ngIf="resolution.status === 'ambiguous'" class="resolution-ambiguous">
      ⚠️ Hay {{ resolution.candidates.length }} versiones vigentes ese día. Es un
      error en las fechas y hay que corregirlo: el sistema no elige por ti.
    </p>
  </ng-container>
</ng-container>

<ng-template #noFamily>
  <cc-empty-state icon="checklist" message="No existe una plantilla con ese identificador."></cc-empty-state>
</ng-template>
```

**Detalles con intención**

- **Los tres estados se pintan distinto a propósito.** `none` es informativo, `ambiguous` es una alarma. Si los dos dijeran "no se pudo determinar la plantilla", la pantalla habría vuelto a juntar lo que la unión discriminada separó.
- **El probador no es una funcionalidad de adorno.** Es lo que convierte *"¿por qué esta inspección se ve así?"* en una comprobación de diez segundos que puede hacer alguien de soporte sin abrir DevTools. La mitad de las herramientas forenses buenas terminan siendo pantallas.

**Prueba de fuego**

Abre `/templates/elevator-annual` y escribe `2023-08-02` en el probador: tiene que decir **v1, 3 ítems**. Escribe `2024-03-15`: **v2, 4 ítems**. Ahora escribe `2023-12-31` y `2024-01-01`, que son el último día de una y el primero de la otra: el salto tiene que ser limpio, sin un solo día que dé `none` ni `ambiguous`. Ese par de fechas es el que va a fallar el día que alguien publique con un error de un día.

### 5.8 El editor: la v3 nace de la v2 y no la toca

```ts
// src/app/features/templates/template-editor/template-editor.component.ts
import { NgFor, NgIf } from '@angular/common';
import { ChangeDetectionStrategy, Component, DestroyRef, OnInit, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import {
  FormArray,
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { filter, first } from 'rxjs';

import { ApiError } from '../../../core/api/api-error';
import { TemplateFamily } from '../../../core/domain/template-family';
import { TemplateStateService } from '../../../core/state/template-state.service';
import { ChecklistItem, ChecklistTemplate } from '../../../core/models/checklist-template.model';
import { FindingSeverity } from '../../../core/models/finding.model';
import { BusinessDay, todayInBusinessZone } from '../../../core/time/business-day';
import { uniqueItemIdsValidator } from '../unique-item-ids.validator';

/**
 * Un ítem del checklist, en forma de formulario. `criteria` es un FormControl
 * de texto con las opciones separadas por comas, y no un FormArray anidado:
 * con cinco criterios de una palabra, un FormArray dentro de otro FormArray
 * multiplica el código sin mejorar la edición. Es una decisión de interfaz y
 * está declarada; el FormArray anidado de verdad es el ejercicio 33, y la
 * Fase 8 construye formularios anidados en runtime, que es donde sí hace falta.
 */
interface ChecklistItemForm {
  id: FormControl<string>;
  title: FormControl<string>;
  criteria: FormControl<string>;
  photoRequired: FormControl<boolean>;
  nonComplianceSeverity: FormControl<FindingSeverity>;
}

interface NewVersionForm {
  validFrom: FormControl<BusinessDay>;
  items: FormArray<FormGroup<ChecklistItemForm>>;
}

@Component({
  selector: 'cc-template-editor',
  standalone: true,
  imports: [
    NgFor,
    NgIf,
    ReactiveFormsModule,
    RouterLink,
    MatButtonModule,
    MatCheckboxModule,
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatSelectModule,
    MatSnackBarModule,
  ],
  templateUrl: './template-editor.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TemplateEditorComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly templateState = inject(TemplateStateService);
  private readonly snackBar = inject(MatSnackBar);
  private readonly destroyRef = inject(DestroyRef);

  readonly templateId = this.route.snapshot.paramMap.get('templateId') ?? '';
  readonly severities: readonly FindingSeverity[] = ['critical', 'major', 'minor'];

  /**
   * La versión de la que se parte, y la que se va a cerrar al publicar. Se
   * guarda entera —no sólo su número— para que `submit()` no tenga que volver
   * a preguntarle al estado: un `subscribe` dentro de otro `subscribe` es el
   * antipatrón que la guía §6.5 nombra por su nombre.
   */
  previousTemplate: ChecklistTemplate | null = null;
  submitting = false;

  readonly form = new FormGroup<NewVersionForm>({
    validFrom: new FormControl<BusinessDay>(todayInBusinessZone(), {
      nonNullable: true,
      validators: [Validators.required, Validators.pattern(/^\d{4}-\d{2}-\d{2}$/)],
    }),
    items: new FormArray<FormGroup<ChecklistItemForm>>([], {
      // Los ids de ítem son la clave con la que las respuestas se casan con la
      // plantilla. Dos ítems con el mismo id producen una inspección en la que
      // una respuesta pisa a la otra, y eso no se ve hasta la Fase 8.
      validators: [uniqueItemIdsValidator],
    }),
  });

  ngOnInit(): void {
    this.templateState.load();

    this.templateState.selectedFamily$
      .pipe(
        // El filter con type guard estrecha a TemplateFamily, así que abajo no
        // hace falta comprobar el null otra vez. El first() es lo que hace que
        // la copia se haga UNA vez: sin él, cada recarga del estado pisaría lo
        // que el usuario lleve escrito, que es el bug más frustrante que puede
        // tener un editor.
        filter((family): family is TemplateFamily => family !== null),
        first(),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe((family) => {
        this.previousTemplate = family.latest;

        // Aquí está el corazón del versionado, y es aburridísimo a propósito:
        // se COPIAN los ítems de la última versión a controles nuevos. La v2
        // no se toca, no se referencia y no se comparte. Cuando se publique, la
        // v3 tendrá su propia copia completa de todo — la 💸 de 5.10.
        for (const item of family.latest.items) {
          this.form.controls.items.push(this.buildItemGroup(item));
        }
      });
  }

  addItem(): void {
    this.form.controls.items.push(
      this.buildItemGroup({
        id: '',
        title: '',
        criteria: [],
        photoRequired: false,
        nonComplianceSeverity: 'minor',
      }),
    );
  }

  removeItem(index: number): void {
    this.form.controls.items.removeAt(index);
  }

  /** Mover un ítem una posición. El orden del array ES el orden del checklist. */
  moveItem(index: number, delta: number): void {
    const target = index + delta;
    const items = this.form.controls.items;

    if (target < 0 || target >= items.length) {
      return;
    }

    const group = items.at(index);
    items.removeAt(index);
    items.insert(target, group);
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const previous = this.previousTemplate;

    if (previous === null) {
      // Sin versión de partida no se publica: crear una v1 desde cero es otra
      // operación y no la hace esta pantalla.
      this.snackBar.open('No se pudo determinar la versión anterior.', 'Cerrar', {
        duration: 6000,
      });
      return;
    }

    const raw = this.form.getRawValue();
    const items: readonly ChecklistItem[] = raw.items.map((item) => ({
      id: item.id.trim(),
      title: item.title.trim(),
      criteria: parseCriteria(item.criteria),
      photoRequired: item.photoRequired,
      nonComplianceSeverity: item.nonComplianceSeverity,
    }));

    this.submitting = true;

    // Una sola suscripción, sin anidar: todo lo que hacía falta del estado ya
    // está en `previous`, copiado en ngOnInit.
    this.templateState
      .publishNewVersion(
        {
          templateId: this.templateId,
          version: previous.version + 1,
          validFrom: raw.validFrom,
          items,
        },
        previous,
      )
      .pipe(takeUntilDestroyed(this.destroyRef))
      .subscribe({
        next: (created) => {
          this.snackBar.open(`Publicada la v${created.version}.`, 'Cerrar', { duration: 4000 });
          void this.router.navigate(['/templates', this.templateId]);
        },
        error: (error: unknown) => {
          this.submitting = false;
          this.snackBar.open(
            error instanceof ApiError ? error.message : 'No se pudo publicar la versión.',
            'Cerrar',
            { duration: 8000 },
          );
        },
      });
  }

  private buildItemGroup(item: ChecklistItem): FormGroup<ChecklistItemForm> {
    return new FormGroup<ChecklistItemForm>({
      id: new FormControl(item.id, {
        nonNullable: true,
        validators: [Validators.required, Validators.pattern(/^[a-z][a-z0-9-]*$/)],
      }),
      title: new FormControl(item.title, {
        nonNullable: true,
        validators: [Validators.required],
      }),
      criteria: new FormControl(formatCriteria(item.criteria), {
        nonNullable: true,
        validators: [Validators.required],
      }),
      photoRequired: new FormControl(item.photoRequired, { nonNullable: true }),
      nonComplianceSeverity: new FormControl<FindingSeverity>(item.nonComplianceSeverity, {
        nonNullable: true,
      }),
    });
  }
}

/** 'ok, leaking, blocked' → ['ok', 'leaking', 'blocked']. Sin entradas vacías. */
export function parseCriteria(text: string): readonly string[] {
  return text
    .split(',')
    .map((criterion) => criterion.trim())
    .filter((criterion) => criterion !== '');
}

export function formatCriteria(criteria: readonly string[]): string {
  return criteria.join(', ');
}
```

```ts
// src/app/features/templates/unique-item-ids.validator.ts
import { AbstractControl, ValidationErrors } from '@angular/forms';

/**
 * Valida que no haya dos ítems con el mismo `id` dentro de una versión. Se
 * aplica al FormArray entero y no a cada control, porque la regla no habla de
 * un ítem: habla de la relación entre todos.
 */
export function uniqueItemIdsValidator(control: AbstractControl): ValidationErrors | null {
  // El valor de un AbstractControl llega sin tipar: se trata como `unknown` y
  // se estrecha, que es la regla del proyecto para estos casos.
  const value: unknown = control.value;

  if (!Array.isArray(value)) {
    return null;
  }

  const ids = value
    .map((item: unknown) =>
      typeof item === 'object' && item !== null && 'id' in item && typeof item.id === 'string'
        ? item.id.trim()
        : null,
    )
    .filter((id): id is string => id !== null && id !== '');

  const duplicated = ids.filter((id, index) => ids.indexOf(id) !== index);

  return duplicated.length === 0 ? null : { duplicatedItemIds: [...new Set(duplicated)] };
}
```

**Detalles con intención**

- **El editor copia; nunca referencia.** Los `ChecklistItem` de la v2 se leen para inicializar controles y se olvidan. No hay un solo punto donde el objeto de la v2 pueda acabar dentro de la v3, que es lo que haría que editar una tocara la otra.
- **`first((family) => family !== null)` y no un `subscribe` normal.** Es la diferencia entre un editor que se rellena una vez y un editor que se borra solo cada vez que el estado se recarga. El ejercicio 27 explora qué pasa cuando alguien publica mientras tú editas.
- **La validación de ids duplicados vive en el `FormArray`.** Es una regla sobre el conjunto, y ponerla en cada control obligaría a que cada uno conociera a los demás.

### 5.9 El invariante, escrito donde se lee

Esta fase no renderiza inspecciones —eso es la Fase 8— pero sí deja escrito, en el código y no sólo en la prosa, cómo se consigue una plantilla para cada uno de los dos usos. Las dos líneas van juntas a propósito:

```ts
// Para EMPEZAR una inspección hoy: se pregunta por la fecha.
const resolution = resolveTemplateVersion(family.versions, todayInBusinessZone());

// Para LEER una inspección existente: se pregunta por su propia versión.
// Nunca por la fecha. Ni siquiera por la fecha en que se ejecutó.
const template$ = this.templateApi.getByVersion(inspection.templateId, inspection.templateVersion);
```

Fíjate en el detalle que parece un matiz y no lo es: **para leer una inspección no se resuelve ni siquiera con su fecha de ejecución**. Podría parecer equivalente —se ejecutó el 2 de agosto de 2023, resolvamos con ese día— y no lo es: si alguien corrige un `validFrom` mal puesto en 2026, todas las inspecciones de 2023 cambiarían de plantilla retroactivamente. El campo `templateVersion` de la inspección es la única fuente que no se puede reescribir por accidente.

```
💸 DEUDA TÉCNICA INTENCIONAL — cada versión guarda sus ítems completos
La v2 de elevator-annual repite tres ítems idénticos a los de la v1 y añade uno.
La v3 volverá a repetirlos todos. Lo eficiente sería guardar el diff contra la
versión anterior y reconstruir al leer.
NO SE PAGA, y es una decisión, no un descuido. Un diff ahorra unos kilobytes y
multiplica por tres la clase de bug que este curso existe para evitar: para leer
una inspección de 2023 habría que reconstruir la v1 aplicando diffs hacia atrás,
y cualquier error en esa cadena —un diff corrupto, uno perdido, uno aplicado dos
veces— produce una plantilla que NO es la que se usó, sin que nada falle. Un
sistema de certificaciones prefiere gastar disco antes que reconstruir historia.
El ejercicio 34 te hace implementar el lector de diffs para que veas por dónde
se rompe.
```

**El patrón a memorizar**

> Cuando el histórico importa, se guarda completo. La normalización es una virtud de los datos vivos; de los datos que ya ocurrieron, es una forma cara de perderlos.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** la inspección 501, de agosto de 2023, muestra cuatro ítems y uno de ellos vacío. El título del primero tampoco coincide con el papel firmado.
**Causa:** alguien consiguió la plantilla resolviendo por fecha —o peor, con `latestVersions$`— en vez de pedir `getByVersion(templateId, inspection.templateVersion)`.
**Fix mínimo:** cambiar la línea que obtiene la plantilla. Son dos líneas de diff.
**Lo que importa:** es el incidente **08** y es el bug más caro que este sistema puede tener, porque no rompe nada visible. La pantalla se pinta, los datos "cuadran", y el error sólo aparece cuando alguien compara con un documento externo — típicamente delante de un auditor, meses después.

**Síntoma:** tras publicar la v3, la pantalla dice "no hay plantilla vigente" para hoy.
**Causa:** la publicación cerró la v2 y falló al crear la v3, o la `validFrom` de la v3 dejó un día de hueco respecto al cierre de la v2.
**Fix mínimo:** crear la versión que falta, o corregir la `validUntil` de la anterior.
**Lo que importa:** es el fallo **elegido**. El orden de escrituras de 5.5 hace que un fallo produzca un hueco y no un solape, precisamente porque un hueco no deja hacer nada mientras que un solape deja hacerlo mal.

**Síntoma:** el probador de fechas dice "hay 2 versiones vigentes ese día".
**Causa:** la v2 quedó con `validUntil: null` cuando debería haberse cerrado.
**Fix mínimo:** poner la `validUntil` que le falta.
**Lo que importa:** es el incidente **09**. Y fíjate en lo que **no** pasa: el sistema no elige una y sigue. Que un error de datos se convierta en un mensaje en vez de en una decisión silenciosa es una propiedad que se diseñó a mano, en el `resolveTemplateVersion` de 5.3, y que se pierde en cuanto alguien añade un `?? candidates[candidates.length - 1]` "para que no se quede en blanco".

**Síntoma:** una inspección iniciada a las once y media de la noche aparece resuelta con la versión del día siguiente.
**Causa:** el instante se convirtió a día con el huso del navegador en vez de con `toBusinessDay()`.
**Fix mínimo:** pasar por `toBusinessDay()`.
**Lo que importa:** este bug **no se reproduce en tu máquina** si estás en la misma zona que el negocio. Aparece en el portátil de alguien que viajó, o en un servidor en UTC. Es el ejercicio 29 y es el aperitivo de la Fase 10.

### Pieza forense de esta fase

Dos preguntas gemelas que llegan con las mismas palabras y significan cosas opuestas.

**Pregunta 1 — *"¿Por qué esta inspección se ve con la plantilla vieja?"*** Casi siempre la respuesta es **porque está bien**, y tu trabajo no es arreglarla sino demostrarlo en tres pasos:

1. Abre la inspección y mira su `templateVersion`. Es un campo, no un cálculo.
2. En Network, busca la petición a `/templates`. Tiene que llevar `?templateId=…&version=…`, con el mismo número.
3. Compara el número de ítems de la respuesta con lo que la pantalla pinta. Si coinciden, el sistema hizo exactamente lo que debía y lo que hay que corregir es la expectativa de quien reportó.

**Pregunta 2 — *"¿Por qué esta inspección de hace un año se ve con la plantilla nueva?"*** Ésta **sí es un bug**, y tiene tres causas posibles que se distinguen sin leer código:

- **La petición no lleva `version`.** El código resolvió por fecha. Es el incidente 08 y es la causa del 90%.
- **La petición lleva `version` pero el número está mal.** Alguien escribió `family.latest.version` donde iba `inspection.templateVersion`. La URL te lo dice.
- **La petición es correcta y la respuesta trae la versión equivocada.** Entonces el bug no está en el frontend: alguien editó una versión publicada en la base de datos. Es el más raro y el más grave, y se confirma comparando la respuesta con el `db.seed.json`.

> 🩺 **Diagnóstico por síntoma.** La URL de la petición contesta la pregunta antes que el código: sin `version=`, es resolución por fecha. Con `version=` y el número equivocado, es la línea que lo lee. Con `version=` correcto y contenido raro, es el dato. Tres miradas a Network, tres sitios distintos donde buscar.

> 📄 El recorrido completo, con los dos tickets literales y la salida de cada paso, en `forense-fase-07.md`.

**🧨 Rompe a propósito**

Edita `mock/db.json` a mano y cámbiale el título al ítem `main-cable` de la **v1** —la versión cerrada, la de 2021—. Pon "PROBANDO". Ahora abre la inspección 501 en la pantalla que la Fase 8 va a construir… que todavía no existe, así que hazlo con `curl`:

```bash
curl -s "http://localhost:3000/templates?templateId=elevator-annual&version=1" \
  -H "Authorization: Bearer <tu token>" | grep PROBANDO
```

Sale. Y ése es el punto: **el sistema no protege el histórico, lo respeta**. No hay nada en el frontend que impida que alguien edite una versión publicada; lo único que hay es una operación que no existe (`delete`), un editor que sólo crea versiones nuevas, y una `close()` que sólo toca `validUntil`. La integridad del histórico es una propiedad del diseño, no una defensa activa — y por eso el día que alguien escriba un script de mantenimiento, hay que estar mirando. Corre `npm run seed` para deshacerlo.

---

## 🧪 7. Ejercicios (35)

**🟢 Fácil (1–9)**

1. Escribe `business-day.ts` completo y comprueba los cuatro instantes de la prueba de fuego de 5.1. Anota cuál te da un día distinto al que esperabas y por qué.
2. Escribe `resolveTemplateVersion` y compruébala con la semilla: `2023-08-02` tiene que dar la v1 y `2024-03-15` la v2. Sin abrir el navegador: un archivo suelto y `console.log` basta.
3. **Diagnóstico.** Provoca un `none`: cambia la `validFrom` de la v2 a `2024-02-01` en `db.json` y resuelve `2024-01-15`. Copia el resultado completo del objeto que devuelve la función.
4. **Diagnóstico.** Provoca un `ambiguous`: pon la `validUntil` de la v1 en `null` y resuelve `2024-06-01`. Anota cuántas candidatas devuelve y en qué orden.
5. Convierte el listado heredado para que muestre familias en vez de versiones sueltas, sin modernizarlo. Comprueba que `template-list.component.ts` sigue con `constructor` y sin `OnPush`.
6. Monta la línea de tiempo de `boiler-annual`, que tiene una sola versión con `validUntil: null`. Comprueba que la pantalla dice "sin fecha de fin" y no un hueco vacío.
7. **Diagnóstico.** Pasa `'2024-01-01T00:30:00-05:00'` y `'2024-01-01T00:30:00'` (sin offset) por `toBusinessDay`. Anota los dos días y explica de dónde sale la diferencia.
8. Publica la v3 de `elevator-annual` desde el editor con `validFrom` de mañana. Abre `mock/db.json` y verifica las **tres** filas: la v2 tiene que haber quedado cerrada hoy.
9. **Diagnóstico.** Con `curl`, pide la plantilla de la inspección 501 tal como debe pedirse. Después pídela sin el parámetro `version`. Compara las dos respuestas y di cuál rompería el invariante.

**🟡 Intermedio (10–20)**

10. Añade el probador de fechas a la pantalla de versiones. Comprueba los cuatro días de la prueba de fuego de 5.7 y anota el resultado de cada uno.
11. Escribe el validador que impide publicar una versión cuya `validFrom` sea anterior o igual a la de la versión que reemplaza. Explica por qué "igual" también hay que prohibirlo.
12. Implementa `uniqueItemIdsValidator` y provoca el error: dos ítems con `id: "main-cable"`. Comprueba que el mensaje nombra el id duplicado y no un genérico "hay un error".
13. **Diagnóstico.** Publica una v3 con la misma `validFrom` que la v2 saltándote el validador del ejercicio 11. Describe qué queda en `db.json`, qué dice el probador de fechas, y por qué el sistema no elige.
14. 🧬 **Estilo.** Ticket: *"en el listado de plantillas, el conteo de versiones debería decir 'versión' en singular cuando hay una sola"*. El archivo es `TemplateListComponent`, heredado. Escribe el fix y justifica en tres líneas por qué no lo convertiste a standalone de paso.
15. 🧬 **Estilo.** Ticket: *"en la línea de tiempo, la versión vigente hoy debería destacarse"*. El archivo es `TemplateVersionsComponent`, nuevo. Escríbelo en su estilo y di qué habría estado mal si hubieras calculado la vigencia en la plantilla HTML.
16. **Diagnóstico.** Simula el fallo de la segunda escritura: publica con `CHAOS=error CHAOS_RATE=1` activado sólo después del cierre (puedes pausar con un `debugger`). Describe el estado que queda y qué ve el usuario siguiente que entre a empezar una inspección.
17. Invierte el orden de las dos escrituras de `publishNewVersion` —crear primero, cerrar después— y provoca el fallo otra vez. Compara los dos estados rotos y escribe cuál preferirías heredar un lunes por la mañana, con el argumento.
18. **Diagnóstico.** Publica una v3 con `validFrom` dentro de seis meses. Compara qué devuelve `latestVersions$` y qué devuelve `resolveForDay(hoy)`. Explica en cuatro líneas por qué el editor usa el primero y una inspección nueva tiene que usar el segundo.
19. Añade los botones de subir y bajar ítem, y comprueba con Network que el orden del array llega al POST tal como se ve en pantalla. El orden del checklist es dato, no presentación.
20. **Diagnóstico.** Cambia el `concatMap` de `publishNewVersion` por `switchMap`, activa `CHAOS=latency` y pulsa Publicar dos veces seguidas. Describe qué se canceló, qué llegó al servidor y en qué estado queda la familia.

**🟠 Difícil (21–29)**

21. Escribe el post-mortem completo de ocho puntos del incidente **08** siguiendo `formato-cuaderno-incidentes.md` §7, con su par de tags `inc/08/<slug>-roto` / `-fix`. El punto 6 —la prueba de regresión— tiene que fallar antes del fix con la inspección 501 y pasar después.
22. **Diagnóstico.** Monta una pantalla de prueba que pinte la inspección 501 resolviendo por su fecha de ejecución en vez de por su `templateVersion`. Con la semilla actual, **da lo mismo**. Ahora cambia la `validFrom` de la v2 a `2023-01-01` y vuelve a mirar. Explica por qué el bug estuvo escondido y qué lo destapó.
23. Publica una v3 que **retire** el ítem `cabin-lighting`. Después mira la inspección 503, que lo respondió. Explica qué le pasa a esa respuesta, qué debería mostrar la pantalla de la Fase 8, y por qué la respuesta correcta no es "borrar la respuesta huérfana".
24. **Diagnóstico.** Alguien dejó un hueco de un día entre la v2 y la v3. Encuéntralo **sin abrir `db.json`**, sólo con el probador de fechas, y describe el método que usarías si la familia tuviera veinte versiones en vez de tres.
25. Decide si `resolveTemplateVersion` debe comprobar en tiempo de ejecución que todas las versiones son de la misma familia. Implementa las dos opciones —una comprobación que lanza y una que no—, y argumenta cuál eliges considerando que esta función la van a llamar la Fase 8, la 9 y la 10.
26. Retira la familia `boiler-annual` entera cerrando su única versión con la fecha de hoy. Comprueba qué dice el probador con la fecha de mañana y decide qué debería hacer la pantalla que empieza una inspección: ¿bloquear, avisar, o dejar elegir una versión cerrada?
27. **Diagnóstico.** Abre el editor de una familia, y desde otra pestaña publica una v3. Vuelve a la primera y publica. Describe qué pasa exactamente —qué número de versión intenta crear, qué responde json-server, qué ve el usuario— y diseña la defensa mínima razonable.
28. Escribe la tabla completa de casos borde de `resolveTemplateVersion` con al menos las ocho filas de 5.3, en formato listo para convertirse en tests de la Fase 12: entrada, día, resultado esperado. Añade dos filas que la tabla de la fase no tiene.
29. **Diagnóstico.** Cambia el huso horario de tu sistema operativo a UTC+13 y comprueba qué devuelve `todayInBusinessZone()` cerca de la medianoche. Después quita `toBusinessDay` y usa `new Date().toISOString().slice(0, 10)` directamente, y compara. Entrega los dos días y di cuántas horas al día están mal.

**🔴 Muy difícil (30–35)**

30. Escribe el post-mortem completo de ocho puntos del incidente **09** siguiendo `formato-cuaderno-incidentes.md` §7, con su par de tags `inc/09/<slug>-roto` / `-fix`. En el punto 7 —prevención— tienes que decidir entre tres defensas: validar en el cliente, un endpoint transaccional, o una comprobación periódica que detecte solapes. Elige y justifica.
31. Implementa en el mock un endpoint `POST /templates/publish` que haga el cierre y la creación **o ninguna de las dos**. Después reescribe `publishNewVersion` para usarlo y compara: cuántas líneas desaparecen del frontend, qué clase de bug deja de ser posible, y qué se pierde al depender de un endpoint que no es json-server estándar.
32. Diseña la migración de respuestas entre versiones: qué haría falta para que una inspección de la v1 se pudiera "actualizar" a la v2. Escribe el algoritmo, y después escribe el párrafo que le mandarías al negocio explicando por qué **no** se va a implementar. El párrafo es la parte difícil.
33. Reescribe el editor con `criteria` como `FormArray<FormControl<string>>` anidado dentro de cada `FormGroup<ChecklistItemForm>`. Entrega las dos versiones, cuenta las líneas de cada una, y decide cuál merece la pena. Guárdalo: la Fase 8 construye formularios anidados en runtime y este ejercicio es su ensayo.
34. Implementa el almacenamiento por diffs que la 💸 de 5.10 descarta: guarda sólo lo que cambia respecto a la versión anterior y escribe el lector que reconstruye una versión completa. Después rompe un diff intermedio a propósito y describe qué le pasa a las inspecciones de las versiones posteriores. Ése es el argumento entero.
35. Escribe la defensa del invariante en tiempo de ejecución: una función que, dada una inspección y la plantilla con la que se va a pintar, verifique que `template.version === inspection.templateVersion` y falle ruidosamente si no. Decide dónde vive —¿el servicio, un interceptor, un guard?—, qué hace cuando falla en producción, y si la dejarías activa o sólo en desarrollo.

**🔥 Opcionales**

- 🔥 Convierte `BusinessDay` en un tipo de marca (`string & { readonly __businessDay: unique symbol }`) con una función `parseBusinessDay(value: unknown): BusinessDay | null` como única puerta de entrada. Cuenta cuántos `as` te obliga a escribir en la frontera con el backend y decide si el compilador te devuelve más de lo que te cobra.
- 🔥 Añade una pantalla de comparación entre dos versiones: qué ítems se añadieron, cuáles cambiaron de título o de severidad, y cuáles desaparecieron. Es lo primero que pide cualquiera que audite un cambio normativo, y es media hora con `groupIntoFamilies` ya hecho.
- 🔥 Escribe un script de Node que recorra `db.json` y detecte huecos y solapes en todas las familias. Es la comprobación periódica del ejercicio 30, y es el tipo de herramienta que salva un fin de semana.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v16.angular.io/api/forms/FormArray — la API completa: `push`, `removeAt`, `insert`, `at`. Es corta y es la mitad del editor.
- https://v16.angular.io/guide/typed-forms — la sección de `FormArray` tipado, que es lo que hace posible el `FormGroup<ChecklistItemForm>` de 5.8.
- https://v16.angular.io/guide/form-validation — validadores a nivel de grupo y de array, que es donde vive `uniqueItemIdsValidator`.
- https://rxjs.dev/api/operators/concatMap — y su comparación con `switchMap`, que es la decisión de 5.5.
- https://www.typescriptlang.org/docs/handbook/2/narrowing.html#discriminated-unions — las uniones discriminadas, que son la forma de `TemplateResolution`. ⚠️ Documenta versiones posteriores a la 5.1 del curso; lo de esta página lleva estable desde mucho antes.
- https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Date/toISOString y https://developer.mozilla.org/es/docs/Web/JavaScript/Reference/Global_Objects/Date/UTC — las dos piezas de `business-day.ts`.
- https://github.com/typicode/json-server — el filtrado por campos que usa `getFamily`.

**Libros / artículos de referencia**

- El patrón de **slowly changing dimension type 2** del mundo de los data warehouses es exactamente lo que estás construyendo: una fila por versión con su ventana de validez. Buscarlo por ese nombre da cuarenta años de literatura sobre los mismos casos borde que la tabla de 5.3. ⚠️ Es vocabulario de bases de datos, no de frontend; los títulos y las URLs cambian, y aquí sólo se cita el concepto.

**Orden de lectura sugerido:** nada antes de 5.1 y 5.2 — el día de calendario y la familia se entienden solos. Antes de 5.3, la página de uniones discriminadas de TypeScript, que es lo que hace que `TemplateResolution` parezca obvia. Antes de 5.8, la de `FormArray` y **A05**. Y después de haber roto la publicación en el ejercicio 16, la de `concatMap`: hasta entonces la diferencia con `switchMap` es una curiosidad y a partir de entonces es una decisión de diseño.

---

## 🚀 9. Cierre y conexión con la siguiente fase

CertCore tiene su corazón. Una plantilla ya no es un objeto que alguien edita: es una familia de versiones con ventanas de vigencia, una función pura que dice cuál rige cada día y que se niega a adivinar cuando los datos están mal, un editor que crea sin tocar lo anterior, y una publicación que sabe cuál de sus dos formas de fallar es la menos dañina.

Y tienes escrito el invariante, que es lo que de verdad se lleva alguien que mantiene este sistema: **una inspección se lee siempre con la versión con la que se ejecutó**. No es una preferencia de diseño. Es lo que separa un certificado defendible de un papel bonito.

Lo que te llevas para cualquier sistema, no sólo para éste: cuando algo tiene historia, la pregunta *"¿cuál es el valor?"* está mal formulada. La pregunta es *"¿cuál era el valor cuando ocurrió esto?"*, y los sistemas que no la distinguen acaban reescribiendo su pasado sin enterarse. Y su corolario técnico: un tipo de retorno que junta dos situaciones distintas —el `null` que significa "no hay" y "hay demasiados"— obliga a adivinar a todo el que lo reciba, para siempre.

La **Fase 8** ⭐ toma la plantilla y la convierte en formulario: un `FormGroup` construido en runtime desde `items[]`, con validadores derivados de `photoRequired` y de `criteria`, respuestas que se guardan con su versión, autosave con `debounceTime` y el `valueChanges` que se muerde la cola. Todo lo que hoy es una definición se vuelve allí una pantalla que un inspector rellena con guantes puestos. Y el `getByVersion` de 5.9 va a ser la primera línea que esa fase escriba.

> **La señal de que quedó bien:** cuando alguien te pregunta "¿por qué esta inspección se ve con la plantilla vieja?" y tu primera reacción no es abrir el código, sino sonreír y abrir Network — porque ya sabes que la URL contesta antes que tú.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-07 -m "F7 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 07: …`) y los de ejercicio su
> número (`fase 07 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f07/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Ésta es la fase donde el `db.json` deja de ser un detalle: publicar escribe
> filas nuevas y cierra las viejas, así que tu base ya no es la semilla. Antes
> de etiquetar, decide qué conservas. Si construiste un escenario que vale la
> pena —una familia con hueco, una con solape—, commitéalo: los incidentes 08 y
> 09 van a nacer de ahí y `npm run seed` los borra. Y guarda en el mensaje del
> tag la firma exacta de `resolveTemplateVersion`: cuatro fases y cuatro
> incidentes la citan, y el tag es el sitio donde se puede comprobar cuál era
> el día que se fijó.

---

## 📌 Pendientes sugeridos

- **La zona horaria queda fijada aquí, y la Fase 10 la hereda.** `CERTCORE_TIME_ZONE_OFFSET` y `toBusinessDay()` viven en `src/app/core/time/business-day.ts` y son la única definición del proyecto. La Fase 10 calcula la vigencia de los certificados —que sí lleva hora, no sólo día— y tiene que **extender este archivo, no crear otro**. Una segunda constante sería el bug de zona horaria más caro del curso y el más difícil de ver. → **Aviso para el chat de la Fase 10**, y la dependencia que su prompt anticipaba queda resuelta en esta dirección.
- **`TemplateStateService` cambió de forma y de firma.** `FeatureState<ChecklistTemplate>` pasó a `TemplateState` propio, y `select(rowId: string)` —que la Fase 4 publicó— pasó a `selectFamily(templateId: string | null)`. Es un renombrado sobre una firma ya escrita, documentado aquí como pide §12. Ninguna fase posterior usaba `select`, así que no hay nada roto detrás. → **Cerrado**, sin acción pendiente.
- **La publicación son dos escrituras y el mock no tiene transacciones.** El orden elegido convierte el fallo en un hueco visible en vez de un solape silencioso, y eso es lo mejor que se puede hacer desde el frontend. Lo correcto es un endpoint `POST /templates/publish` atómico (ejercicio 31). Si alguna vez el curso quiere ese material, es media hora de Express y cambia el discurso de esta fase. → **Decisión de proyecto.**
- **El histórico no está protegido, sólo respetado.** No hay `delete`, el editor sólo crea y `close()` sólo toca `validUntil` — pero nada impide que un script edite una versión publicada. El ejercicio 35 diseña la defensa en tiempo de ejecución. Merece dos párrafos en el checklist de hotfix del cierre del track forense: *"antes de tocar `templates` en la base, comprueba qué inspecciones dependen de esa versión."* → **Aviso para el chat del cierre forense.**
- **La comparación entre dos versiones** (ejercicio 🔥) es lo primero que pide cualquiera que audite un cambio normativo, y con `groupIntoFamilies` hecho cuesta media hora. Es candidata a pantalla real de la Fase 11, junto al dashboard, más que a ejercicio. → **Aviso para el chat de la Fase 11.**
- **La respuesta huérfana del ejercicio 23** —un ítem que existió en la v2, se respondió, y desapareció en la v3— es un caso que la Fase 8 va a encontrarse al renderizar y la Fase 9 al derivar hallazgos. Conviene que las dos sepan que existe y que la decisión ya está tomada: **la respuesta no se borra, se muestra como perteneciente a un ítem retirado**. → **Aviso para los chats de las Fases 8 y 9.**
- 🔥 **Un diagrama de la línea de tiempo de una familia** —dos versiones, sus ventanas, el hueco y el solape dibujados— explicaría la sección 5.3 mejor que su tabla. Es el quinto pendiente de ilustración del curso y probablemente el que más falta hace. Pendiente de dibujo, no de contenido.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 08 | "La inspección de agosto ahora tiene un ítem más que cuando la hice" | Versionado normativo | 🟡 |
| 09 | "Publiqué la v3 y el sistema dice que hay dos plantillas vigentes" | Versionado normativo | 🟠 |
