# 🕵️ Forense Fase 05 — "No hay proveedor para… ¿y ahora dónde busco?" 🧬

> Pieza forense de la **Fase 5 — Standalone conviviendo con NgModules** · Recorrido: ~35 min
> Herramientas: el mensaje de `NullInjectorError` · `ng build --configuration production`
> Síntoma que cubre: la pantalla no se monta y el error dice que falta un proveedor. En un repositorio con dos generaciones, ese mensaje se lee de dos maneras y llevan a sitios opuestos.

Ésta es la pieza más propia del track, porque el error es idéntico en las dos generaciones **salvo por lo que hay entre paréntesis**, y ese paréntesis decide si vas a buscar en diez archivos o en dos.

La fase enseña a distinguir los dos mensajes. Aquí está el recorrido completo, incluido lo que queda de ellos en un build de producción minificado — que es donde de verdad los vas a leer.

---

## 🎫 El ticket

> *"Metí el listado de clientes en el panel principal, como me dijiste, y la pantalla se queda en blanco. En la consola sale algo de un inyector. A mí me funciona si entro por el menú de Clientes."*

**Reportado por:** un compañero del equipo
**Ambiente:** desarrollo

El dato que decide todo está en la última frase: **por una ruta funciona y por otra no**. Eso, en un componente standalone, tiene una sola familia de causas.

---

## 🧭 La ruta

El orden no es casual: **el paréntesis del mensaje cuesta un vistazo** y decide por cuál de las dos ramas sigues, así que va primero. Leer ese mismo error en un build de producción minificado cuesta una compilación entera, y por eso va al final — aunque sea el único sitio donde de verdad te lo vas a encontrar.

### Paso 1 — Lee el paréntesis, no el stack

El mensaje completo, tal como sale en desarrollo. Los dos casos, uno al lado del otro:

```
ERROR NullInjectorError: R3InjectorError(AppModule)[HttpClient -> HttpClient]:
  NullInjectorError: No provider for HttpClient!
```

```
ERROR NullInjectorError: R3InjectorError(Standalone[ClientListComponent])[InjectionToken CLIENT_LIST_PAGE_SIZE -> InjectionToken CLIENT_LIST_PAGE_SIZE]:
  NullInjectorError: No provider for InjectionToken CLIENT_LIST_PAGE_SIZE!
```

**Qué descarta.** El paréntesis es el diagnóstico entero:

| Lo que dice el paréntesis | Qué inyector falló | Dónde buscas | Cuántos archivos |
|---|---|---|---|
| `AppModule`, `CoreModule`, cualquier `…Module` | el árbol de módulos | los `providers` y los `imports` de los `.module.ts` | ~10 |
| `Standalone[NombreComponente]` | el inyector del propio componente | el `imports` de su decorador y los `providers` de **la ruta que lo montó** | 2 |
| `EnvironmentInjector` | el inyector raíz | nadie lo provee en ninguna parte del arranque | 1 |

Y el corchete siguiente, `[X -> Y]`, es la **cadena de resolución**: se lee de izquierda a derecha y dice quién pidió qué. Con `[ClientApiService -> HttpClient]` sabes que el que falló no es el servicio, sino algo que el servicio necesitaba — y eso cambia el archivo que vas a abrir.

### Paso 2 — Si dice `Standalone[…]`: la pregunta no es "qué falta" sino "por qué ruta llegó"

Ésta es la parte que no se parece en nada al caso heredado. Un componente standalone resuelve sus dependencias en su propio inyector y en el de **la ruta que lo activó**. La misma clase, montada desde dos sitios, tiene dos inyectores distintos.

```ts
// La ruta de clientes SÍ provee el token.
{
  path: 'clients',
  loadComponent: () => import('./client-list.component').then((m) => m.ClientListComponent),
  providers: [{ provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 }],
}
```

```html
<!-- El panel monta el MISMO componente, y aquí no hay ninguna ruta que provea nada. -->
<cc-client-list></cc-client-list>
```

**Ésa es la causa del ticket**, y explica por qué "por el menú funciona": por el menú se pasa por la ruta que trae el provider; embebido en el panel, no.

```bash
# La comprobación, y son dos grep:
grep -rn "CLIENT_LIST_PAGE_SIZE" src/app --include="*.ts"
# …token.ts:8:  export const CLIENT_LIST_PAGE_SIZE = new InjectionToken<number>('CLIENT_LIST_PAGE_SIZE');
# …clients.routes.ts:14:  providers: [{ provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 }],
# …client-list.component.ts:31:  readonly pageSize = inject(CLIENT_LIST_PAGE_SIZE);
```

Un solo sitio que lo provee, y no está en el camino del panel. Diagnóstico cerrado sin abrir un archivo entero.

**Las tres formas de arreglarlo, y cuál elegir:**

| Arreglo | Cuándo |
|---|---|
| Añadir el provider también en la ruta del panel | si el panel necesita **otro** tamaño de página. Es la respuesta correcta cuando el valor es de la pantalla |
| Darle al token un valor por defecto: `new InjectionToken<number>('CLIENT_LIST_PAGE_SIZE', { providedIn: 'root', factory: () => 25 })` | si el token tiene un valor razonable siempre. **Es el arreglo del ticket**: un componente reutilizable no puede exigir que cada sitio que lo monte sepa configurarlo |
| `inject(CLIENT_LIST_PAGE_SIZE, { optional: true }) ?? 25` | si de verdad puede no estar. Con `strict`, el tipo pasa a `number \| null` y te obliga a decidir el valor por defecto en el sitio |

**Aquí termina esta rama.** El bug está localizado: un token sin proveedor en el camino de inyección por el que llegó el componente. Si el paréntesis decía `Standalone[…]`, **no vas a pasar por el Paso 3**: las dos ramas son excluyentes, y la tuya acaba eligiendo cuál de las tres salidas de la tabla corresponde. El Paso 4 sigue valiendo para los dos casos, y es otra cosa: cómo se lee este mismo error en producción.

> 🧭 **La regla que sale de aquí, y que la Fase 5 fija para todo el curso: un componente standalone que exige un provider de ruta no es reutilizable, es una trampa.** Funciona por el camino que su autor probó y explota por cualquier otro, y el error no dice "te falta un provider en la ruta": dice "no hay proveedor", que suena a un problema del componente.

### Paso 3 — Si dice `…Module`: la búsqueda de siempre

Aquí el mecanismo es el heredado y el camino también:

```bash
# ¿Quién debería proveerlo?
grep -rn "provideHttpClient\|HttpClientModule" src/app --include="*.ts"

# ¿Y el módulo que aparece en el paréntesis lo importa?
grep -n "imports" src/app/core/core.module.ts
```

El caso típico de este proyecto: alguien quitó `provideHttpClient(...)` de los `providers` de `CoreModule` —donde lo dejó la Fase 2— y todo lo que pide `HttpClient` deja de resolverse. Como `CoreModule` sólo se importa en `AppModule`, el paréntesis dice `AppModule`.

**Aquí termina esta rama.** El bug está localizado: el proveedor no está en el módulo que el paréntesis nombra, ni en ninguno que ése importe. Si llegaste por aquí **no pasas por el Paso 2**: el mensaje ya dijo que el inyector era de módulo y no de componente standalone.

### Paso 4 — Y ahora en producción, que es donde de verdad los vas a leer

Construye y sirve el `dist/`:

```bash
ng build --configuration production
npx http-server dist/certcore -p 8081
```

El mismo fallo, en producción:

```
ERROR Error: NG0201: No provider found for `t`. Find more at https://angular.io/errors/NG0201
```

**Compáralo con el de desarrollo y mira lo que se perdió:** el paréntesis con el inyector, la cadena de resolución, y el nombre. `t` es lo que quedó de `ClientApiService` después del minificador. **El mensaje de producción no te dice ni qué falta ni dónde buscar.**

Y aquí está el hallazgo práctico de toda esta pieza:

```ts
// El nombre de la CONSTANTE se minifica. La CADENA que le pasas al
// InjectionToken, no: es un literal y sobrevive al build de producción.
export const CLIENT_LIST_PAGE_SIZE = new InjectionToken<number>('CLIENT_LIST_PAGE_SIZE');
```

```
// Por eso, en producción, un token con descripción sigue diciendo su nombre:
ERROR Error: NG0201: No provider found for `InjectionToken CLIENT_LIST_PAGE_SIZE`. …
```

> 💡 **La descripción de un `InjectionToken` no es documentación: es la única pista que te va a quedar en producción.** Cuesta escribir la misma palabra dos veces y es la diferencia entre un ticket de diez minutos y uno de dos días. Un token creado como `new InjectionToken<number>('')` está tirando esa pista a la basura.

Y para los servicios, cuyo nombre sí se minifica, la herramienta es la de siempre: los source maps con `sourceMap.hidden: true` de la **Fase 13**. Sin ellos, `t` es todo lo que vas a tener.


**Aquí termina la ruta.** Sabes leer el mismo error en los dos sitios donde te lo vas a encontrar, y en producción sabes qué parte del mensaje sobrevive a la minificación y cuál no. El arreglo es de la rama por la que llegaste, el Paso 2 o el Paso 3.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Qué inyector | Dónde miras |
|---|---|---|
| `R3InjectorError(AppModule)[…]` | árbol de módulos | `providers` / `imports` de los `.module.ts` |
| `R3InjectorError(Standalone[X])[…]` 🧬 | el del componente | `imports` del decorador y `providers` de la ruta que lo montó |
| `R3InjectorError(EnvironmentInjector)[…]` | el raíz | el arranque: nadie lo provee en ninguna parte |
| `[A -> B]`: falla `B`, no `A` | — | abre el archivo de `A` y busca qué pide |
| Funciona por una ruta y no por otra 🧬 | provider de ruta | es el caso del ticket: paso 2 |
| `NG0201: No provider found for \`t\`` | producción minificada | source maps, o la descripción del token |
| `NG0203` en vez de `NG0201` | **no es esto** | `inject()` fuera de contexto — **A04** §7 |

---

## ⚰️ Los callejones

**"Le añado el import al `SharedModule` y listo."** No aplica: un componente standalone **no ve** lo que declara o exporta un `NgModule` a menos que lo importe él mismo. Es exactamente el cambio de modelo que la Fase 5 enseña, y el reflejo heredado manda a buscar en el archivo equivocado.

**"Falta importar el módulo de Material."** Ése es otro error y tiene otro texto: `NG0304: 'mat-form-field' is not a known element` o `NG0303: Can't bind to 'matInput'`. Un `NullInjectorError` **nunca** es un problema de plantilla: es un problema de inyección. Si lo que no aparece es un componente, mira `forense-fase-01.md`.

**"El servicio no tiene `providedIn: 'root'`."** Comprobable en cinco segundos, y cuando es cierto el error es distinto: el paréntesis dice `EnvironmentInjector` y no `Standalone[…]`, porque nadie lo provee en ningún sitio en vez de "no en este camino".

**"Es un problema de orden de imports."** Casi nunca en Angular 16. El orden importa para los interceptores registrados con `provideHttpClient()` —eso sí, y es `forense-fase-02.md`— pero no para resolver un token.

---

## 🧨 Deshacer

Si quitaste `provideHttpClient(...)` de `CoreModule` para provocar el primer error, **devuélvelo**: sin esa línea deja de funcionar todo lo que hable con el mock, y el síntoma que produce en la Fase 6 no se parece en nada a éste.

El `dist/` del paso 4 se puede borrar: `rm -rf dist/`. Un `stats.json` o un `.map` viejo confundiendo una investigación posterior es la mentira de los source maps desactualizados de `forense-fase-00.md`.

---

## 🧠 El patrón transferible

> **Cuando dos generaciones conviven, el mensaje de error tiene un campo que te dice en cuál estás.** Aquí es el paréntesis. Aprender a leerlo cuesta una tarde y ahorra una por incidente, porque decide entre buscar en diez archivos o en dos.

Y el segundo, que es de diseño y no de depuración: **lo que el minificador conserva es lo que decidas escribir como cadena.** Nombres de clase, de variable y de función se pierden; los literales sobreviven. Una descripción en un `InjectionToken`, un mensaje de error con el nombre del contexto dentro, una etiqueta en un `console.error`: son las únicas cosas que van a seguir ahí cuando el ticket llegue desde producción.

**Incidentes del cuaderno que usan esta ruta:** 06 y 07, los dos de convivencia de estilos 🧬.
**Amplía:** **A04** para el contexto de inyección y las opciones de `inject()`, `forense-fase-01.md` para el mismo síntoma en el mundo de los NgModule, y `forense-fase-13.md` para el stack minificado.
