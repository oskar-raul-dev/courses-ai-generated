## Incidente 22 — "No me deja crear el cliente de Galápagos: dice que el NIT son 9 o 10 dígitos"

> **Fase:** 6 · **Categoría:** Formularios · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30 min · **Ruta forense:** [`forense-fase-06.md`](forense-fase-06.md)

### 🎫 El ticket

> *"No me deja crear el cliente de Galápagos. Pongo el RUC de la hostería y sale que el NIT son 9 o 10 dígitos, sin puntos ni guiones. No tiene puntos ni guiones: es un RUC de Ecuador y tiene 13. Se lo pedí a Patricio dos veces y está bien copiado. ¿Lo creo con los primeros diez números mientras tanto, para no atrasar la inspección?"*

**Reportado por:** coordinadora de calidad, con copia a la gerencia general
**Ambiente:** PROD

### 🎯 Qué se te pide

Contestar la pregunta del final antes que nada, explicar por qué Lima y Quito llevan años con clientes que tienen RUC y nadie había visto este error, y arreglar la validación sin romper el chequeo de NIT repetido que ya hace la pantalla.

### 🔧 Preparación

No hay nada que preparar: el bug está en el formulario desde que la Fase 6 lo escribió, y la semilla basta para verlo.

```bash
npm run mock
npm start
# Clientes → Nuevo cliente
#   Razón social: Hostería Chiriboga Cía. Ltda.
#   NIT:          2091748323001
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El mensaje del error lo escribió alguien, en un archivo concreto: búscalo. Y antes de cambiar nada, pregúntale al control qué le pasa, como en la ruta forense de la Fase 6: `ng.getComponent($0).form.controls.taxId.errors`.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Los `validators` del control `taxId` en `client-form.component.ts`. ¿Cuántos países caben en esa expresión regular? Y abre Network mientras escribes los 13 dígitos: ¿sale la petición que comprueba si el NIT está repetido?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Los clientes de Lima y de Quito existen desde que se abrió cada filial. ¿Por qué puerta entraron a la base, si esta pantalla no los habría dejado pasar?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

```
```

**Hipótesis**
- ❌ Descartada:
- ✅ Confirmada:

**Tu causa raíz**

**Tu fix**

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Primero, la pregunta del final: no.** Un cliente creado con los diez primeros dígitos de su RUC pasa la validación porque tiene la forma de un NIT colombiano, y eso es lo peor que le puede pasar: el certificado saldría a nombre de un número que no existe en ningún registro tributario, y nadie lo notaría hasta que el cliente lo reclamara. Un dato inventado para pasar un validador es un bug en la base que ya no se ve en ninguna pantalla.

**Causa raíz**

Una línea del formulario de clientes, escrita con los clientes colombianos delante:

```ts
// src/app/features/clients/client-form/client-form.component.ts — la línea
      validators: [Validators.required, Validators.pattern(/^\d{9,10}$/)],
```

Nueve dígitos y uno de verificación: el NIT de Colombia, y nada más. Los identificadores de los otros dos países no caben:

| País | Identificación | Forma | Fuente |
|---|---|---|---|
| Colombia | NIT | 9 dígitos, o 10 con el de verificación | lo que ya validaba la Fase 6 |
| Perú | RUC | 11 dígitos | SUNAT |
| Ecuador | RUC | 13 dígitos; los dos primeros, la provincia; los tres últimos, `001` | Reglamento de la Ley del RUC, art. 3 |

**¿Y por qué nadie lo vio en cinco años?** Porque los clientes de Lima y de Quito no entraron por esta pantalla. Cada filial llegó con su cartera, y esa cartera se cargó **por script, directo a la API**, el día en que se abrió. La validación de la pantalla nunca los vio. La hostería de Galápagos es el primer cliente fuera de Colombia que alguien crea a mano, y por eso es el primero que tropieza.

Y un detalle que la Pista 2 buscaba: en Network **no sale** la petición de `existsByTaxId`. Angular corre los validadores síncronos primero y llama al asíncrono solo si pasaron. Con el patrón fallando, el chequeo de repetidos ni siquiera arranca, así que mirar el validador asíncrono es perder el tiempo.

**Parche mínimo**

Un validador con nombre, al lado del asíncrono que ya existe, que reconozca por su **forma** los tres identificadores. No hay campo de país, así que no puede saber cuál de los tres es: solo que tiene la forma de uno.

```ts
// src/app/features/clients/tax-id.validator.ts — nuevo, el fix del incidente 22
import { AbstractControl, ValidationErrors, ValidatorFn } from '@angular/forms';

/**
 * 🩹 INCIDENTE 22. La identificación tributaria de un cliente de cualquiera de
 * los tres países, reconocida por su forma:
 *   - NIT de Colombia: 9 dígitos, o 10 con el de verificación;
 *   - RUC de Perú: 11 dígitos (SUNAT);
 *   - RUC de Ecuador: 13 dígitos terminados en 001 (Reglamento de la Ley del RUC).
 *
 * No comprueba dígitos verificadores, y es a propósito: sin país no se sabe
 * cuál aplicar, y el que el cliente tiene impreso en su RUC vale más que
 * nuestra cuenta. Lo que sí hace es no dejar pasar nada que no sea uno de los
 * tres, que es lo que el patrón de antes hacía con uno solo.
 */
const TAX_ID_FORMATS: readonly RegExp[] = [/^\d{9,10}$/, /^\d{11}$/, /^\d{10}001$/];

export const taxIdValidator: ValidatorFn = (control: AbstractControl): ValidationErrors | null => {
  // Igual que en el asíncrono: el valor llega como `any` y se estrecha.
  const value: unknown = control.value;

  if (typeof value !== 'string' || value === '') {
    // El vacío es cosa de `Validators.required`, que ya está en el control.
    return null;
  }

  return TAX_ID_FORMATS.some((format) => format.test(value)) ? null : { taxIdFormat: true };
};
```

```diff
// src/app/features/clients/client-form/client-form.component.ts
 import { uniqueTaxIdValidator } from '../unique-tax-id.validator';
+import { taxIdValidator } from '../tax-id.validator';
@@
-      validators: [Validators.required, Validators.pattern(/^\d{9,10}$/)],
+      // 🩹 INCIDENTE 22. NIT, RUC de Perú o RUC de Ecuador: ver tax-id.validator.ts.
+      validators: [Validators.required, taxIdValidator],
       // El validador asíncrono va en su propio parámetro, no mezclado con los
       // síncronos. Angular corre los síncronos primero y sólo llama al
-      // asíncrono si aquéllos pasaron: no se pregunta al servidor por un NIT
-      // que ni siquiera tiene nueve dígitos.
+      // asíncrono si aquéllos pasaron: no se pregunta al servidor por un
+      // número que no tiene la forma de ninguno de los tres.
       asyncValidators: [uniqueTaxIdValidator(this.clientApi, this.clientId)],
```

```diff
<!-- src/app/features/clients/client-form/client-form.component.html -->
-    <mat-label>NIT</mat-label>
+    <mat-label>NIT o RUC</mat-label>
@@
-    <mat-error *ngIf="form.controls.taxId.hasError('pattern')">
-      El NIT son 9 o 10 dígitos, sin puntos ni guiones.
+    <mat-error *ngIf="form.controls.taxId.hasError('taxIdFormat')">
+      Sin puntos ni guiones: NIT de 9 o 10 dígitos, RUC de Perú de 11, o RUC de Ecuador de 13 terminado en 001.
     </mat-error>
```

El asíncrono no se toca: `uniqueTaxIdValidator` compara el texto con lo que ya hay en la base, y le da igual de qué país sea.

**La refactorización correcta**

El país del cliente, como dato. Con él, el validador sabe cuál de los tres formatos exigir, puede comprobar el dígito verificador donde la norma lo pida, y la pantalla puede decir "RUC" o "NIT" según corresponda en vez de "NIT o RUC". Es la misma conversación que el incidente 21 abre con la zona del activo, y no se tiene un viernes.

Y una que no es de Angular: los clientes de 2019 entraron sin pasar por esta validación, y cualquier otro script puede hacer lo mismo. La regla tiene que vivir también del lado de la API, donde no hay forma de saltársela.

**Prueba de regresión**

```ts
// src/app/features/clients/tax-id.validator.spec.ts — el caso del incidente 22
import { FormControl } from '@angular/forms';

import { taxIdValidator } from './tax-id.validator';

describe('incidente 22: la identificación tributaria de los tres países', () => {
  const isValid = (taxId: string): boolean =>
    new FormControl(taxId, { nonNullable: true, validators: [taxIdValidator] }).valid;

  it('acepta el NIT de siempre, de 9 y de 10 dígitos', () => {
    expect(isValid('900123456')).toBeTrue();
    expect(isValid('9001234567')).toBeTrue();
  });

  it('acepta el RUC de Perú y el de Ecuador', () => {
    expect(isValid('20000000001')).toBeTrue();
    // El de la hostería. Antes del fix, este caso era inválido.
    expect(isValid('2091748323001')).toBeTrue();
  });

  it('sigue rechazando lo que no es ninguno de los tres', () => {
    expect(isValid('12345678')).toBeFalse(); // ocho dígitos
    expect(isValid('123456789012')).toBeFalse(); // doce: no es de ningún país
    expect(isValid('2091748323002')).toBeFalse(); // trece, sin 001
    expect(isValid('900.123.456')).toBeFalse(); // con puntos
    expect(isValid('2000000000A')).toBeFalse(); // con una letra
  });
});
```

**Prevención**

El test de arriba, y una búsqueda que conviene repetir cada vez que el negocio cruza una frontera: las reglas de un solo país escondidas en literales.

```bash
grep -rn -e 'NIT' -e '9,10' src/app/
```

La búsqueda también encuentra la cabecera **NIT** de la tabla de clientes y el *placeholder* "Razón social o NIT" del buscador, que siguen diciendo "NIT" con un RUC debajo. No rompen nada, pero son el mismo supuesto, y entran en la refactorización del país.

**Por qué llegó a producción**

Porque la regla era verdad para todos los clientes que la pantalla vio. Las carteras de Lima y de Quito llegaron por script, directo a la API, y durante años la única gente que dio de alta clientes a mano en CertCore trabajaba en Bogotá con clientes colombianos. El formulario pasó sus pruebas con NIT, porque NIT era lo que había.

Lo que lo hizo visible fue un cliente que no llegó con ninguna filial sino con un contrato. Y lo que casi lo esconde otra vez fue la pregunta del ticket: *"¿lo creo con los primeros diez números?"*. Cuando un validador estorba, alguien encuentra la forma de pasarlo, y el dato que entra así ya no lo detecta nadie.

**Si tu causa fue distinta a esta**

Si quitaste el patrón, la pantalla acepta cualquier cosa y el asíncrono le pregunta al servidor por basura. Si lo ampliaste a `/^\d{9,13}$/`, aceptas doce dígitos, que no son de ningún país, y un RUC de Ecuador sin `001`. Si te fuiste al validador asíncrono porque "es el que consulta", la Pista 2 lo descarta: con el síncrono fallando, el asíncrono no llega a correr. Y si creaste el cliente con los diez primeros dígitos, como proponía el ticket, el formulario quedó contento y la base, mal: es el único de estos caminos que no deja ningún error a la vista.

</details>

---

