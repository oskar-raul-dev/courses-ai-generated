// T4: lo que el plan pide además del spec del cuaderno. Corre IGUAL sobre los dos
// árboles (fase-06 y fase-06 + fix del 22): `taxIdValidators` lo genera correr-t4.sh
// copiando literalmente el arreglo `validators` del control taxId de cada árbol.
import { FormControl } from '@angular/forms';
import { Observable, of } from 'rxjs';

import { ClientApiService } from '../src/app/core/api/client-api.service';
import { uniqueTaxIdValidator } from '../src/app/features/clients/unique-tax-id.validator';
import { taxIdValidators } from './validators-del-arbol';

/** Doble del servicio: responde con `of(...)` y cuenta las llamadas. */
class ClientApiDouble {
  calls: string[] = [];
  constructor(private readonly taken: ReadonlySet<string>) {}
  existsByTaxId(taxId: string, _exceptId: number | null): Observable<boolean> {
    this.calls.push(taxId);
    return of(this.taken.has(taxId));
  }
}

function control(value: string, api: ClientApiDouble): FormControl<string> {
  // Igual que el formulario de F06: síncronos de este árbol + el asíncrono de F06.
  // `api` entra con el tipo del servicio: el doble tiene el único método que el validador usa.
  const service: Pick<ClientApiService, 'existsByTaxId'> = api;
  return new FormControl(value, {
    nonNullable: true,
    validators: taxIdValidators,
    asyncValidators: [uniqueTaxIdValidator(service as ClientApiService, null)],
  });
}

const settle = () => new Promise((resolve) => setTimeout(resolve, 500)); // timer(400) del validador

describe('T4 · el formulario de clientes con los validadores de este árbol', () => {
  const casos: ReadonlyArray<readonly [string, boolean]> = [
    ['900123456', true], ['9001234567', true],          // NIT
    ['20000000001', true],                              // RUC de Perú
    ['2091748323001', true],                            // RUC de Ecuador (la hostería)
    ['12345678', false], ['123456789012', false],       // 8 y 12 dígitos
    ['2091748323002', false],                           // 13 sin 001
    ['900.123.456', false], ['2000000000A', false], ['', false],
  ];

  for (const [taxId, ok] of casos) {
    it(`"${taxId}" ${ok ? 'pasa' : 'no pasa'} los síncronos`, () => {
      const c = new FormControl(taxId, { nonNullable: true, validators: taxIdValidators });
      expect(c.valid).withContext(JSON.stringify(c.errors)).toBe(ok);
    });
  }

  it('el RUC de la hostería llega al chequeo asíncrono y queda VALID', async () => {
    const api = new ClientApiDouble(new Set());
    const c = control('2091748323001', api);
    expect(c.status).toBe('PENDING');
    await settle();
    expect(api.calls).toEqual(['2091748323001']);
    expect(c.status).toBe('VALID');
  });

  it('un RUC ya registrado se marca como repetido', async () => {
    const api = new ClientApiDouble(new Set(['2091748323001']));
    const c = control('2091748323001', api);
    await settle();
    expect(c.errors).toEqual({ taxIdTaken: true });
  });

  it('un NIT sigue pasando por el asíncrono como siempre', async () => {
    const api = new ClientApiDouble(new Set(['900123456']));
    const c = control('900123456', api);
    await settle();
    expect(c.errors).toEqual({ taxIdTaken: true });
  });

  it('lo que no tiene forma no llega al servidor', async () => {
    const api = new ClientApiDouble(new Set());
    const c = control('123456789012', api);
    await settle();
    expect(c.status).toBe('INVALID');
    expect(api.calls).toEqual([]);
  });
});
