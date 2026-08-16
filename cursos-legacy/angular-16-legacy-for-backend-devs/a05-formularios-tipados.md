# 📎 Apéndice A05 — Formularios reactivos tipados

> Tutorial Angular 16 — Inspecciones y certificaciones · Consulta rápida · **3 horas**
> Usado por: [Fase 6](06-clientes-activos.md), [Fase 7](07-plantillas-versionadas.md), [Fase 8](08-formulario-dinamico.md), [Fase 9](09-hallazgos-severidad.md), [Fase 12](12-testing-coverage.md) · Versión cubierta: Angular 16.2.12 — el tipado llegó en la 14

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve el problema que produce más tickets en CertCore después del versionado: **un formulario denso cuyo valor no es lo que tú creías que era**, casi siempre porque hay un `null` que nadie decidió o un control deshabilitado que desapareció del objeto sin avisar.

**Qué queda fuera:** los formularios por plantilla (`ngModel`, `FormsModule`). CertCore no tiene ni uno, por una razón que conviene decir aquí y no repetir: un formulario que se construye desde datos —que es lo que hace la **Fase 8** con las plantillas de checklist— no se puede declarar en el HTML, porque nadie sabe cuántos campos va a tener. Tampoco entran los componentes de formulario de Material (`mat-form-field`, `mat-select`, sus `appearance` y su densidad): eso es **A01**.

---

## Índice

- [1. `FormControl<T>` y el `| null` que nadie espera](#1-formcontrolt-y-el--null-que-nadie-espera)
- [2. `nonNullable: true`: qué cambia exactamente](#2-nonnullable-true-qué-cambia-exactamente)
- [3. `FormGroup<T>`: tipo explícito frente a inferencia](#3-formgroupt-tipo-explícito-frente-a-inferencia)
- [4. `FormRecord` y los controles que nacen en runtime](#4-formrecord-y-los-controles-que-nacen-en-runtime)
- [5. `FormArray` tipado](#5-formarray-tipado)
- [6. Validadores tipados, síncronos y asíncronos](#6-validadores-tipados-síncronos-y-asíncronos)
- [7. ⚠️ `value` frente a `getRawValue()`](#7-️-value-frente-a-getrawvalue)
- [8. Tipar un formulario que no se conoce en compilación](#8-tipar-un-formulario-que-no-se-conoce-en-compilación)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios](#-ejercicios-9)

---

## 1. `FormControl<T>` y el `| null` que nadie espera

La primera sorpresa del tipado de formularios es que el tipo por defecto **no** es el que escribiste:

```ts
const legalName = new FormControl('');
// El tipo inferido es FormControl<string | null>, no FormControl<string>.
```

El `null` no es un descuido de Angular: es la consecuencia de una API que ya existía. `reset()` —sin argumentos, que es como lo llama todo el mundo— pone el control en `null`. Como el tipo tiene que describir todos los valores posibles del control a lo largo de su vida, y `null` es uno de ellos, ahí está.

Con `strict: true` puesto eso se convierte inmediatamente en trabajo:

```ts
// El compilador no te deja olvidarlo, y ésa es la gracia.
const value = legalName.value;        // string | null
const trimmed = value.trim();         // ❌ Object is possibly 'null'
```

Hay tres formas de responder a ese error y sólo dos son aceptables:

- **Decidir que el control nunca es nulo** → `nonNullable: true` (§2). Es lo que hace CertCore en el 90% de los casos.
- **Decidir que `null` significa algo** → dejarlo, y tratar el caso. `validUntil: FormControl<string | null>` donde `null` es "vigente indefinidamente" es un tipo que dice la verdad.
- **Taparlo con `!` o con `as string`** → no. La guía §6.4 lo prohíbe, y el motivo no es purismo: una familia entera de bugs del curso —el hallazgo que no bloquea, el certificado sin fecha— nace exactamente de la diferencia entre `null`, `undefined` y "campo ausente".

> 🧭 **Regla del proyecto (Fase 6).** La nulabilidad de un control se decide al escribirlo, no al usarlo. Si el campo siempre tiene un valor —aunque sea la cadena vacía—, va `nonNullable: true`. Si `null` significa algo de verdad, va sin él y el tipo lo dice. Lo que no se admite es un `| null` heredado de la migración que nadie decidió.

---

## 2. `nonNullable: true`: qué cambia exactamente

```ts
const legalName = new FormControl('', { nonNullable: true });
// FormControl<string>. El .value es string, sin uniones.
```

Cambian dos cosas, y la segunda es la que la gente descubre tarde:

**El tipo.** `value` pasa a ser `string`, y todo lo que se construye encima deja de arrastrar guardas.

**El comportamiento de `reset()`.** Un control `nonNullable` vuelve a **su valor inicial** —el que le diste al crearlo— en vez de a `null`. Que es, casualmente, lo que un usuario espera de un botón que dice "Limpiar": el formulario vuelve a como estaba, no se queda en un estado que no existía.

```ts
const withNull = new FormControl('Edificio Central');
const withoutNull = new FormControl('Edificio Central', { nonNullable: true });

withNull.reset();      // value === null
withoutNull.reset();   // value === 'Edificio Central'
```

> ⚠️ **`nonNullable` no es una validación.** No impide que el campo esté vacío: `''` es un `string` perfectamente válido. Quien exige contenido es `Validators.required`. Confundirlos produce el formulario que compila, tipa bien y se guarda vacío.

**La forma con `FormBuilder`.** Si prefieres el builder, `fb.nonNullable` es un builder entero cuyos controles nacen no nulos, y evita repetir la opción en cada línea:

```ts
private readonly fb = inject(FormBuilder);

// Cada control lleva su opción. Explícito y ruidoso.
readonly form = this.fb.group({
  legalName: this.fb.control('', { nonNullable: true, validators: [Validators.required] }),
  taxId: this.fb.control('', { nonNullable: true }),
});

// El mismo formulario, con el builder no nulo. Menos ruido, misma semántica.
readonly form2 = this.fb.nonNullable.group({
  legalName: ['', [Validators.required]],
  taxId: [''],
});
```

> 📝 **Nota de migración.** Los formularios genéricos llegaron en Angular **14**, y con ellos `nonNullable`, `FormRecord` y `NonNullableFormBuilder`. Antes existía `initialValueIsDefault: true`, que hacía la mitad —el `reset()`— y no tocaba el tipo, porque no había tipo. Si en un proyecto heredado ves `initialValueIsDefault`, estás mirando código anterior a la 14: es el mismo comportamiento con el nombre viejo, y `nonNullable` lo sustituyó. En CertCore no aparece: la migración de 2024 pasó por encima de esa era.

---

## 3. `FormGroup<T>`: tipo explícito frente a inferencia

Hay dos maneras de tipar un grupo, y en este curso conviven a propósito.

**La explícita.** Se escribe una interfaz cuyos campos son `FormControl`s, y se la pasas al `FormGroup`. Es lo que hace la **Fase 6** con `ClientForm` y la **Fase 8** con `AnswerForm`.

```ts
interface ClientForm {
  legalName: FormControl<string>;
  taxId: FormControl<string>;
}

readonly form = new FormGroup<ClientForm>({
  legalName: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
  taxId: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
});
```

Cuesta cuatro líneas más y compra tres cosas: el tipo tiene nombre y se puede exportar, `setValue` falla en compilación si mañana alguien añade un campo y olvida rellenarlo, y el error del compilador apunta a la interfaz en vez de a un objeto literal de veinte líneas.

**La inferida.** `FormBuilder.group({...})` deduce el tipo del objeto que le pasas. Es más corta y perfectamente válida para un formulario de tres campos que no sale de su componente.

```ts
readonly form = this.fb.nonNullable.group({
  legalName: ['', [Validators.required]],
  taxId: ['', [Validators.required]],
});
// El tipo existe, pero no tiene nombre: es un FormGroup<{...}> anónimo.
```

> 🧭 **Regla práctica.** Si el tipo del formulario tiene que viajar —a una función, a un servicio, a un test—, escríbelo explícito y dale nombre. Si vive y muere dentro del componente, infiérelo. La **Fase 8** es el caso extremo del primero: `InspectionForm` es un tipo exportado que usan tres archivos y una suite de tests.

**Lo que NO puedes hacer con un `FormGroup<T>` tipado**, y es la limitación que lleva directo a la §4:

```ts
form.addControl('phone', new FormControl(''));
// ❌ El compilador se queja: 'phone' no está en ClientForm.
```

Y hace bien. Un `FormGroup<T>` promete exactamente esas claves; si pudieras añadir cualquiera, el tipo sería una sugerencia. Cuando de verdad no sabes las claves, el tipo correcto es otro.

---

## 4. `FormRecord` y los controles que nacen en runtime

`FormRecord<T>` es un `FormGroup` cuyas **claves se conocen en runtime** y cuyos controles son **todos del mismo tipo `T`**. Es la respuesta oficial al `FormGroup` con `any` que antes de la 14 escribía todo el mundo.

```ts
// El tipo del formulario de una inspección, de la Fase 8.
export type InspectionForm = FormRecord<FormGroup<AnswerForm>>;

const form: InspectionForm = new FormRecord<FormGroup<AnswerForm>>({});

for (const item of template.items) {
  form.addControl(item.id, buildItemGroup(item, /* … */));   // ✅ aquí sí
}
```

Lo que ganas: `getRawValue()` devuelve un `Record<string, { answer: string; evidenceUrl: string | null; note: string | null }>`. El compilador no sabe qué claves habrá —nadie puede saberlo— pero sabe exactamente qué hay dentro de cada una. Es todo el tipado que la situación admite, y es mucho más del que parece.

Su API útil, en cuatro líneas:

```ts
form.addControl(itemId, group);      // añade; si la clave existe, no hace nada
form.setControl(itemId, group);      // añade o REEMPLAZA
form.removeControl(itemId);          // quita
form.contains(itemId);               // ¿existe y está habilitado?
```

> ⚠️ **`contains()` devuelve `false` para un control deshabilitado.** Es la respuesta a "¿este control participa en el valor?", no a "¿este control existe?". Si lo que quieres saber es lo segundo, la pregunta es `form.get(itemId) !== null`. Confundirlos produce el control huérfano que la **Fase 8** caza en su pieza forense.

> 🧭 **Regla del proyecto (Fase 8): la clave es el `itemId`, nunca la posición.** Con `FormArray` indexado por posición, reordenar los ítems de una plantilla en una v3 desplazaría las respuestas de todo el mundo. Con `FormRecord` y el `itemId` como clave, no hay nada que desplazar — y además la diferencia entre las claves del formulario y los ítems de la plantilla delata en una línea las respuestas huérfanas de un ítem retirado.

---

## 5. `FormArray` tipado

`FormArray<T>` es la estructura correcta cuando **el orden es el dato** y los elementos no tienen identidad propia: una lista de teléfonos de contacto, un conjunto de rangos de fechas, las filas de un detalle que el usuario añade y quita.

```ts
interface AssetForm {
  code: FormControl<string>;
  tags: FormArray<FormControl<string>>;
}

const form = new FormGroup<AssetForm>({
  code: new FormControl('', { nonNullable: true }),
  tags: new FormArray<FormControl<string>>([]),
});

form.controls.tags.push(new FormControl('elevator', { nonNullable: true }));
form.controls.tags.removeAt(0);
form.controls.tags.at(0)?.value;    // string | undefined — `at` puede no encontrar nada
```

En la plantilla hay una trampa que cuesta media tarde la primera vez:

```html
<!-- El índice del *ngFor no basta: formGroupName / formControlName necesitan
     el índice como cadena, y el control tiene que existir ANTES de pintarse. -->
<div formArrayName="tags">
  <input *ngFor="let control of form.controls.tags.controls; let i = index"
         [formControlName]="i" />
</div>
```

> 💡 **`FormArray` frente a `FormRecord`, en una línea.** Si puedes reordenar los elementos sin que cambie su significado, `FormArray`. Si cada elemento tiene una identidad que sobrevive al orden —un `itemId`, un `assetId`—, `FormRecord`. CertCore usa `FormRecord` en la pieza central por esa razón exacta.

---

## 6. Validadores tipados, síncronos y asíncronos

Un validador es una función que recibe un `AbstractControl` y devuelve `ValidationErrors | null`. Y aquí llega la parte que sorprende: **el `AbstractControl` que recibe NO está tipado**. Su `value` es `any`, porque el mismo validador tiene que poder aplicarse a un control, a un grupo o a un array.

```ts
/** La respuesta tiene que ser uno de los criterios del ítem. */
export function oneOfValidator(allowed: readonly string[]): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    // El valor llega sin tipar: se recibe como `unknown` y se estrecha.
    // Es la regla del proyecto desde la Fase 6, y aquí es donde más se nota.
    const value: unknown = control.value;

    if (typeof value !== 'string' || value === '') {
      // Vacío no es inválido por ESTE validador: de eso se ocupa `required`.
      // Dos errores a la vez producen dos mensajes, y el usuario lee el que no sirve.
      return null;
    }

    return allowed.includes(value) ? null : { notAllowed: { value, allowed } };
  };
}
```

**Detalles con intención**

- **`const value: unknown = control.value`** es la línea que convierte un `any` en algo con lo que `strict` puede trabajar. Sin ella, el resto del validador está tipado sobre arena.
- **Un validador hace una sola pregunta.** El de arriba no comprueba si está vacío; eso es `required`. Un validador que comprueba tres cosas devuelve tres claves de error y produce un mensaje que nadie sabe redactar.
- **El objeto de error lleva datos, no texto.** `{ notAllowed: { value, allowed } }` deja que la plantilla componga el mensaje en español. Un validador que devuelve `{ error: 'El valor no es válido' }` mezcla dominio con interfaz.

**Los asíncronos** viven en su propio parámetro, y tienen tres reglas que se olvidan las tres:

```ts
export function uniqueTaxIdValidator(
  clientApi: ClientApiService,
  currentClientId: number | null,
): AsyncValidatorFn {
  return (control: AbstractControl): Observable<ValidationErrors | null> => {
    const value: unknown = control.value;

    if (typeof value !== 'string' || value === '') {
      return of(null);
    }

    // 1. ESPERAR. Sin esto, una petición por tecla.
    return timer(400).pipe(
      switchMap(() => clientApi.findByTaxId(value)),
      map((found) =>
        found === null || found.id === currentClientId ? null : { taxIdTaken: true },
      ),
      // 2. NO INVALIDAR POR UN FALLO DE RED. Si el servidor no responde, el
      //    usuario no tiene la culpa: el error saldrá al guardar, que es donde
      //    sí se puede explicar.
      catchError(() => of(null)),
      // 3. COMPLETAR. Si no completa, el control se queda `pending` para
      //    siempre y el formulario nunca llega a ser válido.
      first(),
    );
  };
}
```

> ⚠️ **`pending` no es `invalid`.** Mientras un validador asíncrono está en vuelo, el control está `pending` y `form.invalid` es **`false`**. Un botón que sólo mira `[disabled]="form.invalid"` deja pasar el clic durante ese rato, y guarda un valor que iba a resultar inválido. La comprobación correcta es `if (this.form.invalid || this.form.pending)`, y es literalmente el bug más caro de la pantalla de clientes de la **Fase 6**.

---

## 7. ⚠️ `value` frente a `getRawValue()`

Ésta es la sección que justifica sola el apéndice.

```ts
const form = new FormGroup<ClientForm>({
  legalName: new FormControl('Edificio Central', { nonNullable: true }),
  taxId: new FormControl('900123456', { nonNullable: true }),
});

form.controls.taxId.disable();

form.value;         // { legalName: 'Edificio Central' }   ← taxId NO está
form.getRawValue(); // { legalName: 'Edificio Central', taxId: '900123456' }
```

**Un control deshabilitado desaparece de `value`.** No vale `null`, no vale `undefined`: no está la clave. Y el tipo lo dice, aunque nadie lo lea: el tipo de `value` en un `FormGroup<T>` es `Partial<…>`, precisamente porque cualquier control puede estar deshabilitado en cualquier momento.

Por qué es el bug más silencioso del tema:

1. Funciona durante meses, porque en la pantalla nadie deshabilita nada.
2. Llega un ticket normal: *"el NIT no se debe poder editar cuando el cliente ya tiene certificados emitidos"*. Alguien añade un `disable()` de dos líneas, que es exactamente el arreglo correcto.
3. A partir de ese día, guardar un cliente manda un `PATCH` **sin `taxId`**. Con `json-server` y con casi cualquier backend REST, eso significa "no lo cambies", así que no pasa nada visible.
4. Hasta que otro endpoint interpreta el campo ausente como "ponlo a nulo", y entonces se pierde el NIT de los clientes que alguien editó. Y el commit que lo rompió es un `disable()` de dos líneas que revisaron tres personas.

> 🧭 **Regla del proyecto: para construir el objeto que se envía, siempre `getRawValue()`.** `value` sirve para pintar y para decidir en pantalla; `getRawValue()` es lo que se manda al servidor. Es la misma familia de decisión que la de la **Fase 10** con el PDF: *el documento se arma desde la fuente del dato, nunca desde lo que hay pintado.*

Con `nonNullable` en todos los controles y `getRawValue()`, el objeto que sale del formulario tiene exactamente el tipo que declaraste, sin `Partial`, sin uniones con `null` y sin una sola guarda. Ésa es la recompensa completa del tipado, y llega justo en la línea donde importa.

---

## 8. Tipar un formulario que no se conoce en compilación

Es la situación de la **Fase 8** y la razón por la que este apéndice existe. El resumen del método, en cuatro decisiones:

**Uno — separa lo que sí sabes de lo que no.** No sabes cuántos ítems tendrá la plantilla; sí sabes qué campos tiene la respuesta a un ítem. Lo segundo se tipa con una interfaz (`AnswerForm`); lo primero, con `FormRecord`.

**Dos — que la construcción sea una función pura.** Recibe los datos, devuelve el formulario. No inyecta, no pide, no sabe qué pantalla la llamó:

```ts
export function buildAnswerForm(
  template: ChecklistTemplate,
  answers: readonly InspectionAnswer[],
): InspectionForm { /* … */ }
```

Eso la vuelve testeable sin `TestBed` —la **Fase 12** la prueba así— y elimina de golpe la clase de bug en la que el formulario depende de en qué orden pasaron las cosas.

**Tres — que los validadores salgan del dato, no de la pantalla.** `photoRequired: true` en la plantilla se convierte en `Validators.required` sobre `evidenceUrl`. Cambiar ese booleano en una v3 cambia la validación sin tocar una línea de código. Eso es lo que significa "derivado de la plantilla", y es lo que hace que el motor de plantillas sea un motor y no una configuración.

**Cuatro — que el camino de vuelta también sea una función.** Del formulario al modelo del dominio, con su propia decisión explícita sobre qué no viaja:

```ts
export function toAnswers(form: InspectionForm): readonly InspectionAnswer[] {
  return Object.entries(form.getRawValue())     // getRawValue, siempre (§7)
    .filter(([, value]) => value.answer !== '')  // lo no respondido no viaja
    .map(([itemId, value]) => ({ itemId, answer: value.answer, evidenceUrl: value.evidenceUrl, note: value.note }));
}
```

> 🧠 **El patrón a memorizar.** Un formulario dinámico bien hecho es una **función pura de sus datos**: misma plantilla y mismas respuestas, mismo formulario. En cuanto necesita saber en qué pantalla está o qué había antes, deja de poderse testear y empieza a acumular bugs de estado.

---

## 🧭 Cuándo usar qué

| Situación | Estructura | Por qué |
|---|---|---|
| Campos fijos, conocidos al escribir | `FormGroup<T>` con interfaz | el tipo tiene nombre y `setValue` te protege |
| Formulario chico que no sale del componente | `fb.nonNullable.group({...})` | la inferencia basta y se lee mejor |
| Claves decididas en runtime, mismo tipo de control | `FormRecord<T>` | es literalmente para esto |
| Lista ordenada, elementos sin identidad | `FormArray<T>` | el orden es el dato |
| El campo siempre tiene valor | `nonNullable: true` | el tipo deja de arrastrar `null` y `reset()` hace lo esperable |
| `null` significa algo del dominio | sin `nonNullable`, y documentarlo | "vigente indefinidamente" es un valor, no un olvido |
| Construir el objeto que se envía | `getRawValue()` | los deshabilitados también son parte del dato |
| Decidir qué pintar en pantalla | `value` | ahí sí quieres saber qué participa |
| Comprobar antes de guardar | `form.invalid \|\| form.pending` | `pending` no es `invalid`, y ahí se cuela el bug |

---

## ⚠️ Advertencias

- **Casi todos los ejemplos que hay en internet son anteriores a Angular 14** y no compilan aquí. Se reconocen a simple vista: `new FormGroup({...})` sin genérico, `this.fb.group({...})` con `Validators` en un array posicional y un `any` en el `subscribe` del `valueChanges`. No están "mal": están fechados, y traducirlos es exactamente el ejercicio 2.
- **`setValue` frente a `patchValue`.** `setValue` exige el objeto completo y falla en compilación si mañana se añade un campo y alguien olvida rellenarlo; `patchValue` lo dejaría vacío en silencio. En CertCore, `setValue` por defecto y `patchValue` sólo cuando de verdad quieres tocar una parte.
- **`disable()` y `enable()` disparan `valueChanges`** salvo que les pases `{ emitEvent: false }`. En una pantalla con autosave —la de la **Fase 8**— eso significa un guardado que nadie pidió, disparado por deshabilitar un campo.
- **Un `FormControl<Date>` es casi siempre una mala idea.** El dominio de CertCore guarda fechas como cadenas ISO con offset explícito (**Fase 7** y **Fase 10**), y meter un `Date` en el formulario introduce una conversión de zona horaria en el punto exacto donde menos la quieres.

---

## 📚 Referencias

- https://v16.angular.io/guide/typed-forms — la guía oficial de formularios tipados. Es corta, es buena, y es la referencia exacta de esta versión.
- https://v16.angular.io/api/forms/FormControl — incluida la firma de `nonNullable` y la nota sobre `reset()`.
- https://v16.angular.io/api/forms/FormRecord · https://v16.angular.io/api/forms/FormArray · https://v16.angular.io/api/forms/FormGroup — las tres estructuras, con sus métodos.
- https://v16.angular.io/api/forms/AbstractControl#getRawValue — el método de la §7, con la frase clave sobre los controles deshabilitados.
- https://v16.angular.io/api/forms/NonNullableFormBuilder — el `fb.nonNullable` de la §2.
- https://v16.angular.io/guide/form-validation — validadores síncronos y asíncronos, y el estado `pending`.

> ⚠️ La documentación en https://angular.dev cubre la 17 en adelante y mezcla los formularios con signals (`toSignal`, `linkedSignal` en versiones posteriores). Nada de eso existe aquí. Para este curso, `v16.angular.io`.

**Orden de lectura sugerido:** §1 y §2 antes de la Fase 6, que es donde escribes tu primer formulario tipado de verdad. La §7 **antes** de que te toque un ticket con un `disable()` dentro, no después. La §4 y la §8 cuando abras la Fase 8, y no antes: fuera del contexto del formulario dinámico se leen como abstracción. La §6 el día que un validador asíncrono te deje el formulario colgado en `pending`.

---

## 🧪 Ejercicios (9)

1. 🟢 Crea `new FormControl('')` y `new FormControl('', { nonNullable: true })`, pásale el ratón por encima a cada uno en el editor y anota los dos tipos inferidos. Después llama a `reset()` en los dos e imprime los valores.

2. 🟢 Toma este fragmento pre-14 y tradúcelo al estilo del proyecto, explicando cada cambio: `this.form = this.fb.group({ name: ['', Validators.required], email: [''] });`

3. 🟢 En `ClientFormComponent` (Fase 6), quita el `nonNullable: true` de `legalName` y anota todos los errores de compilación que aparecen. Devuélvelo y cuenta cuántas guardas te ahorró esa palabra.

4. 🟡 Reproduce el bug de la §7 de punta a punta: deshabilita `taxId` en el formulario de clientes, guarda un cliente con el mock corriendo, y mira en la pestaña Network qué se envió exactamente. Después arréglalo con `getRawValue()` y verifica la diferencia en el payload.

5. 🟡 Escribe un validador `notInFutureValidator` para una fecha ISO que devuelva `{ inFuture: { value } }` si la fecha es posterior a hoy. Aplícalo al campo de fecha de una inspección y comprueba que **no** se queja cuando el control está vacío.

6. 🟡 Convierte el formulario de clientes de la forma explícita (`FormGroup<ClientForm>`) a la inferida (`fb.nonNullable.group`). Compara los dos archivos y argumenta en cuatro líneas cuál dejarías, sabiendo que `ClientForm` no se exporta a ningún sitio.

7. 🟠 Construye un `FormRecord<FormControl<string>>` con tres claves, deshabilita una, y compara `value`, `getRawValue()` y `contains()` sobre esa clave. Escribe la frase de una línea que explique la diferencia entre las tres respuestas.

8. 🟠 En la pantalla de inspección de la Fase 8, añade un `disable()` a un control dentro del `subscribe` del autosave y observa cuántas peticiones salen. Después añade `{ emitEvent: false }` y vuelve a medir. Explica qué pasó con la advertencia de la §"Advertencias" en la mano.

9. 🔴 Escribe desde cero una función pura `buildAssetForm(assetType: AssetType): FormGroup<AssetForm>` que construya un formulario distinto según el tipo de activo —un ascensor pide número de paradas, una caldera pide presión máxima— usando `FormRecord` para los campos variables y `FormGroup<T>` para los fijos. Escribe además su función inversa. Los dos tienen que poder testearse sin `TestBed`, y ése es el criterio de éxito: si necesitas `TestBed`, la función no es pura y hay que rehacerla.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es consulta rápida y los formularios que explica los escriben las Fases 6, 8 y 9, así que lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`fase 06: …`, `fase 08: …`). Si el ejercicio 9 te deja código que quieres conservar, va con la forma `ej/a05/9`. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
