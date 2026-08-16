# 📓 Cuaderno de incidentes — CertCore

> Tutorial Angular 16 — Inspecciones y certificaciones · **20 incidentes · 14 horas**
> ≈3.5h por semana, repartidas a lo largo del mes que dura el curso

Veinte tickets como los que llegan de verdad: vagos, escritos por alguien que no sabe qué es un resolver, y a veces describiendo dos problemas distintos como si fueran uno. Tu trabajo es convertirlos en un diagnóstico.

> 🧭 **El trato.** Cada incidente trae su solución de referencia, plegada al final. Está ahí porque trabajas sin instructor y necesitas saber si acertaste. **Abrirla antes de escribir la tuya no te ahorra tiempo: te ahorra el ejercicio**, que es lo único que estabas comprando. Lo mismo con las tres pistas: son un plan de rescate, no un atajo.

---

## 🧭 Cómo se trabaja un incidente

### El método, en cuatro preguntas

Son las mismas del track forense y van siempre en este orden, porque cada una cuesta un orden de magnitud más que la anterior:

1. **¿Se reproduce, y con qué?** — con un flag, con un dato, o hace falta otro código. Las tres respuestas llevan a investigaciones distintas.
2. **¿Qué dice la evidencia observable, antes que el código?** — la URL de una petición, el cuerpo crudo, el estado de un control, el paréntesis de un error.
3. **¿En qué capa está?** — plantilla, componente, servicio de estado, API, interceptor, guard, mock, build, contenedor.
4. **¿De qué generación es el archivo que voy a tocar?** 🧬 — porque el parche mínimo se escribe **en el estilo del archivo que tocas**, aunque sea el estilo viejo.

El índice de síntomas que cruza *"esto es lo que veo"* con *"esta es la ruta"* está en [`forense-master.md`](forense-master.md) §3. Empieza ahí cuando no sepas ni de qué fase es tu problema.

### Las tres formas de tener el sistema roto

Cada incidente dice cuál usa en su bloque **🔧 Preparación**. El orden no es casual: **se usa siempre la más barata que sirva**, porque una preparación complicada es una excusa para saltarse el incidente.

**1 · Un flag del inyector de caos** (Fase 3), cuando el fallo es de red o de respuesta. Es la preferida: no toca tu código, no toca tus datos, y se apaga sola al reiniciar el mock.

```bash
CHAOS=malformed npm run mock
```

**2 · Un `db.json` alterno**, cuando el bug está en el dato y no en el código.

```bash
cp mock/db.incidente-09.json mock/db.json    # guarda el tuyo antes, o corre npm run seed después
```

**3 · Una rama de git**, y sólo cuando haya que romper código. Sale del tag de la fase correspondiente, así que se crea sin buscar nada:

```bash
git switch -c incidente/08 fase-07
# …y el commit de la rama trae el cambio mínimo que produce el síntoma
```

> 🧭 **La regla, y sirve más allá de este cuaderno:** cuando alguien te pida reproducir un bug, la primera pregunta es *"¿esto se reproduce con un flag, con un dato, o hace falta otro código?"*. Averiguarlo te ahorra la mitad del camino antes de leer una línea.

### La convención de commits

El asunto sigue este formato, para que `git log --oneline` se lea como la línea de tiempo de la investigación:

```
incidente(08): abre — la inspección de agosto tiene un ítem más
incidente(08): repro — sólo pasa con inspecciones anteriores a 2024
incidente(08): hipótesis descartada — no es el editor, la v1 sigue intacta en db
incidente(08): causa — el detalle resuelve por fecha y no por versión guardada
incidente(08): fix — leer templateVersion de la inspección
incidente(08): cierre — test de regresión y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`, `causa`, `fix`, `cierre`.

**Commitea también los callejones sin salida.** Un `git log` con seis commits de investigación y uno de fix es un registro honesto; uno que muestra sólo el fix no le sirve a nadie, y menos a ti dentro de seis meses.

Y como el fix de casi todos estos incidentes es de una o dos líneas, márcalo con el par de tags de [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md):

```bash
git tag -a inc/08/version-ejecutada-roto -m "F7 inc08: el test reproduce el bug y falla"
# …el fix…
git tag -a inc/08/version-ejecutada-fix  -m "F7 inc08: causa raíz y fix, con el test en verde"

git diff inc/08/version-ejecutada-roto inc/08/version-ejecutada-fix   # ← el post-mortem, sin ruido
git tag -n99 -l 'inc/*'                                              # ← el cuaderno entero, sin abrir un archivo
```

> 💡 Para releer la historia de un incidente: `git log --oneline --grep "incidente(08)"`

**Regla del archivo: se agrega, no se corrige.** Una hipótesis que resultó falsa no se borra: se marca como descartada, con la evidencia que la tumbó.

### Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y test de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 📋 Índice

Actualiza la columna **Estado** en el mismo commit que abre o cierra cada incidente.

### Semana 1 · Fases 0-4

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [01](#incidente-01--cloné-el-repo-hice-npm-install-y-ng-serve-no-arranca) | 0 | "Cloné el repo, hice npm install y `ng serve` no arranca" | Despliegue | 🟢 | ⬜ |
| [02](#incidente-02--agregué-la-pantalla-de-activos-la-ruta-funciona-pero-sale-en-blanco) | 1 | "Agregué la pantalla de activos, la ruta funciona pero sale en blanco" | UI | 🟢 | ⬜ |
| [03](#incidente-03--entro-con-mi-usuario-y-me-saca-al-login-sin-decir-nada) | 2 | "Entro con mi usuario y me saca al login sin decir nada" | Integración | 🟢 | ⬜ |
| [04](#incidente-04--la-pantalla-de-plantillas-a-veces-carga-y-a-veces-se-queda-pensando) | 3 | "La pantalla de plantillas a veces carga y a veces se queda pensando" | Integración | 🟢 | ⬜ |
| [05](#incidente-05--entro-a-plantillas-y-dice-que-no-hay-ninguna-pero-en-el-mock-están-las-tres) | 4 | "Entro a Plantillas y dice que no hay ninguna, pero en el mock están las tres" | Estado (servicios) | 🟢 | ⬜ |

### Semana 2 · Fases 5-8

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [06](#incidente-06--el-botón-de-nuevo-cliente-se-ve-gris-y-plano-desde-el-martes-pero-todo-compila) | 5 | "El botón de Nuevo cliente se ve gris y plano desde el martes, pero todo compila" | Convivencia de estilos 🧬 | 🟡 | ⬜ |
| [07](#incidente-07--metí-el-listado-de-clientes-en-el-panel-y-la-pantalla-se-queda-en-blanco) | 5 | "Metí el listado de clientes en el panel y la pantalla se queda en blanco" | Convivencia de estilos 🧬 | 🟡 | ⬜ |
| [08](#incidente-08--la-inspección-de-agosto-ahora-tiene-un-ítem-más-que-cuando-la-hice) | 7 | "La inspección de agosto ahora tiene un ítem más que cuando la hice" | Versionado normativo | 🟡 | ⬜ |
| [09](#incidente-09--publiqué-la-v3-y-el-sistema-dice-que-hay-dos-plantillas-vigentes) | 7 | "Publiqué la v3 y el sistema dice que hay dos plantillas vigentes" | Versionado normativo | 🟠 | ⬜ |
| [10](#incidente-10--cambié-de-inspección-desde-el-listado-y-me-aparecieron-ítems-de-la-otra) | 8 | "Cambié de inspección desde el listado y me aparecieron ítems de la otra" | Versionado normativo | 🟠 | ⬜ |
| [11](#incidente-11--escribo-una-letra-y-la-aplicación-se-queda-pegada-el-ventilador-se-dispara) | 8 | "Escribo una letra y la aplicación se queda pegada; el ventilador se dispara" | Formularios dinámicos | 🟠 | ⬜ |

### Semana 3 · Fases 9-11

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [12](#incidente-12--aprobé-la-inspección-y-el-sistema-me-dejó-pero-el-cable-está-para-cambiar) | 9 | "Aprobé la inspección y el sistema me dejó, pero el cable está para cambiar" | Tipos (strict) | 🟠 | ⬜ |
| [13](#incidente-13--el-supervisor-subió-la-severidad-de-un-hallazgo-y-al-día-siguiente-había-vuelto-a-bajar) | 9 | "El supervisor subió la severidad de un hallazgo y al día siguiente había vuelto a bajar" | Tipos (strict) | 🟠 | ⬜ |
| [14](#incidente-14--descargué-el-certificado-y-la-tabla-de-hallazgos-no-dice-lo-mismo-que-la-pantalla) | 10 | "Descargué el certificado y la tabla de hallazgos no dice lo mismo que la pantalla" | Trazabilidad | 🟠 | ⬜ |
| [15](#incidente-15--el-certificado-venció-ayer-para-el-sistema-y-hoy-para-el-cliente-y-sólo-pasa-por-la-tarde) | 10 | "El certificado venció ayer para el sistema y hoy para el cliente, y sólo pasa por la tarde" | Tiempo | 🔴 | ⬜ |
| [16](#incidente-16--cerré-el-panel-hace-media-hora-y-el-servidor-sigue-recibiendo-peticiones-mías) | 11 | "Cerré el panel hace media hora y el servidor sigue recibiendo peticiones mías" | Performance | 🟠 | ⬜ |

### Semana 4 · Fases 12-13

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| [17](#incidente-17--el-test-pasa-en-mi-máquina-y-falla-en-el-pipeline-y-nadie-tocó-nada) | 12 | "El test pasa en mi máquina y falla en el pipeline, y nadie tocó nada" | Testing | 🔴 | ⬜ |
| [18](#incidente-18--desplegamos-el-arreglo-hace-dos-horas-y-la-gente-sigue-viendo-el-error-a-mí-me-funciona) | 13 | "Desplegamos el arreglo hace dos horas y la gente sigue viendo el error; a mí me funciona" | Despliegue | 🔴 | ⬜ |
| [19](#incidente-19--en-uat-entra-bien-y-en-producción-la-pantalla-se-queda-en-blanco) | 13 | "En UAT entra bien y en producción la pantalla se queda en blanco" | Despliegue | 🔴 | ⬜ |
| [20](#incidente-20--tenemos-82--de-coverage-y-el-bug-llegó-a-producción-igual) | 12 | "Tenemos 82 % de coverage y el bug llegó a producción igual" | Testing | 🔴 | ⬜ |

**Reparto:** 3 de versionado de plantillas (08, 09, 10), 2 de convivencia de estilos 🧬 (06, 07) y 2 de tipos bajo `strict` (12, 13). **Los IDs son globales y no se reasignan nunca**, aunque un incidente se retire.

---
## 🧪 Incidentes

---

## Incidente 01 — "Cloné el repo, hice npm install y `ng serve` no arranca"

> **Fase:** 0 · **Categoría:** Despliegue · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-30 min · **Ruta forense:** [`forense-fase-00.md`](forense-fase-00.md)

### 🎫 El ticket

> *"Me pasaron el repo para que ayude con un hotfix. Cloné, hice `npm install` como siempre, y `ng serve` se cae con un error larguísimo de TypeScript. A mi compañero le funciona con el mismo repo."*

**Reportado por:** un desarrollador que se incorpora al equipo
**Ambiente:** local

### 🎯 Qué se te pide

Reproducir, explicar por qué a uno le funciona y al otro no con el mismo repositorio, y aplicar el arreglo que impide que vuelva a pasarle al siguiente que llegue.

### 🔧 Preparación

Una rama, porque hay que romper el `package.json` — que es código.

```bash
git switch -c incidente/01 fase-00
# La rama cambia una línea del package.json. Después:
rm -rf node_modules package-lock.json
npm install
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

El error no está en tu código: ninguno de los archivos que menciona es tuyo. Antes de leerlo entero, pregúntate qué tienes tú instalado que tu compañero no — y la herramienta que contesta eso no es el editor.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`npm ls typescript` y `npm ls @angular/core`. Compara los dos números con la tabla de versiones de `alcance-del-proyecto.md` §9. Después mira **cómo** están escritos en el `package.json`, que es distinto de qué versión hay instalada.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué diferencia hay entre `"typescript": "5.1.6"` y `"typescript": "^5.1.6"` el día que se publica la 5.4, y por qué tu compañero —que instaló hace tres meses y no ha vuelto a borrar `node_modules`— no lo nota?

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

**Causa raíz**

`package.json`, línea de `devDependencies`: `"typescript": "^5.1.6"` en vez de `"typescript": "5.1.6"`. El acento circunflejo admite cualquier versión menor por encima, y Angular 16.2.12 sólo soporta TypeScript `>=4.9.3 <5.2.0`. El error literal es:

```
Error: The Angular Compiler requires TypeScript >=4.9.3 and <5.2.0 but 5.4.5 was found instead.
```

A tu compañero le funciona porque **su `node_modules` es de hace tres meses**, cuando la 5.2 todavía no existía. Los dos tienen el mismo `package.json` y árboles distintos: eso es exactamente lo que un lockfile existe para impedir, y aquí el `npm install` lo reescribió.

**Parche mínimo**

```jsonc
// package.json — el hotfix de un viernes
{
  "devDependencies": {
    "typescript": "5.1.6"
  }
}
```

```bash
rm -rf node_modules package-lock.json
npm install
git add package.json package-lock.json    # el lockfile va en el mismo commit
```

**La refactorización correcta**

Fijar la versión no impide que el siguiente que llegue lo haga con otro Node. Las dos líneas que sí lo impiden:

```jsonc
// package.json
{
  "engines": { "node": "18.18.2", "npm": "9.8.1" }
}
```

```bash
# .npmrc en la raíz. Sin esto, `engines` es decorativo: npm lo lee, no coincide,
# se encoge de hombros y sigue.
echo "engine-strict=true" > .npmrc
```

Y el cambio de hábito, que es el de verdad: **`npm ci` al clonar y al cambiar de rama; `npm install` sólo cuando añades una dependencia a propósito.** El detalle está en el **Apéndice A03** §2.

**Prueba de regresión**

Aquí no hay un `.spec.ts` que valga: lo que hay que verificar es la cadena de herramientas, y eso se comprueba antes de compilar.

```js
// scripts/check-toolchain.mjs
// Falla el arranque si el árbol instalado no es el que el proyecto fija.
// Corre antes de `ng serve` y antes de `ng build`, así que el error llega
// con un mensaje en español en vez de con un stack del compilador.
import { readFileSync } from 'node:fs';

const EXPECTED = { typescript: '5.1.6', '@angular/core': '16.2.12', rxjs: '7.8.1' };

const failures = Object.entries(EXPECTED).flatMap(([name, expected]) => {
  const installed = JSON.parse(
    readFileSync(`node_modules/${name}/package.json`, 'utf8'),
  ).version;

  return installed === expected ? [] : [`${name}: se esperaba ${expected} y hay ${installed}`];
});

if (failures.length > 0) {
  console.error('❌ El árbol de dependencias no es el del proyecto:');
  failures.forEach((failure) => console.error(`   ${failure}`));
  console.error('   Corre `npm ci` en vez de `npm install`. Ver el apéndice A03.');
  process.exit(1);
}
```

```jsonc
// package.json
{
  "scripts": {
    "check:toolchain": "node scripts/check-toolchain.mjs",
    "start": "npm run check:toolchain && ng serve",
    "build": "npm run check:toolchain && ng build"
  }
}
```

**Prevención**

El script de arriba, más `engine-strict=true`, más `npm ci` en el `Dockerfile` de la **Fase 13** — que ya lo tiene, y por esta razón exacta.

**Por qué llegó a producción**

Nadie lo desplegó: llegó a la máquina de alguien nuevo, que es donde este bug se cobra. El sistema lo permitió por dos decisiones separadas y ninguna descabellada: el proyecto arrancó con los rangos que genera el CLI, y el equipo se acostumbró a `npm install` porque durante dos años nunca dio problemas. El fallo aparece **sólo cuando alguien instala desde cero**, y en un equipo estable eso pasa una vez cada muchos meses — el tiempo justo para que nadie recuerde el anterior.

**Si tu causa fue distinta a esta**

Si concluiste "hay que actualizar Angular a una versión que soporte TS 5.4", el síntoma también encaja y el remedio es una migración no planificada disfrazada de arreglo. Si concluiste "es la versión de Node", es una hipótesis excelente y se descarta en un comando: `node -v` da lo mismo en las dos máquinas. Y si tu fix fue `--legacy-peer-deps`, taparías otra clase de error: aquí no hay ningún conflicto de peers, hay un rango que resolvió a algo incompatible.

</details>

---

## Incidente 02 — "Agregué la pantalla de activos, la ruta funciona pero sale en blanco"

> **Fase:** 1 · **Categoría:** UI · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 25-40 min · **Ruta forense:** [`forense-fase-01.md`](forense-fase-01.md)

### 🎫 El ticket

> *"Copié la estructura de la pantalla de plantillas para hacer la de activos. La URL cambia a `/assets`, el menú se marca, y donde debería estar la tabla no hay nada. No sale nada rojo por ningún lado."*

**Reportado por:** un compañero del equipo
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Localizar en qué punto se rompe la cadena entre la ruta y el componente, y aplicar el fix. **No hay error en consola**, así que el entregable incluye explicar por qué no lo hay.

### 🔧 Preparación

```bash
git switch -c incidente/02 fase-01
npm start
# Entra a /assets
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Hay dos preguntas que parecen la misma y no lo son: *"¿el componente no se ve?"* y *"¿el componente no existe?"*. Contesta primero la segunda; se hace en una línea de consola y decide todo lo demás.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

En la pestaña Network, con el filtro en `JS` y *Disable cache* activado, mira si al navegar a `/assets` se descarga un chunk nuevo. Después, en la consola: `ng.getComponent(document.querySelector('cc-asset-list'))`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El chunk carga y el componente existe. Entonces la ruta hija se activó y el componente se construyó. ¿Dónde tenía que pintarse?

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

**Causa raíz**

`src/app/features/assets/assets.component.html`: el componente contenedor de la feature no tiene `<router-outlet>`. La ruta hija se activa, Angular construye `AssetListComponent`, y no hay dónde pintarlo. **No hay error porque no hay nada mal**: el router hizo su trabajo y nadie pidió el resultado.

Es el mismo mecanismo que hace que un `<ng-template>` sin `ngTemplateOutlet` no muestre nada. El componente existe, y por eso `ng.getComponent()` lo devuelve.

**Parche mínimo**

```html
<!-- src/app/features/assets/assets.component.html -->
<h2>Activos</h2>

<!-- Sin esto, las rutas hijas se activan y no se pintan. Es el error que menos
     ruido hace de toda la Fase 1: no da excepción, no ensucia la consola, y el
     componente sí existe en memoria. -->
<router-outlet></router-outlet>
```

**La refactorización correcta**

Ninguna: el parche **es** el arreglo. Lo que sí conviene revisar de paso —y en otro commit— es si el resto de features tienen el suyo:

```bash
# Todo módulo de feature con rutas hijas necesita su outlet.
grep -rLn "router-outlet" src/app/features/*/[a-z]*.component.html
```

**Prueba de regresión**

```ts
// src/app/features/assets/assets.component.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { By } from '@angular/platform-browser';
import { RouterOutlet } from '@angular/router';

import { AssetsComponent } from './assets.component';

describe('AssetsComponent', () => {
  let fixture: ComponentFixture<AssetsComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      declarations: [AssetsComponent],
      // El outlet real, no un stub: lo que se prueba es que EXISTA.
      imports: [RouterOutlet],
    }).compileComponents();

    fixture = TestBed.createComponent(AssetsComponent);
    fixture.detectChanges();
  });

  it('tiene un router-outlet donde pintar sus rutas hijas', () => {
    // Falla antes del fix: query devuelve null y el mensaje lo dice claro.
    expect(fixture.debugElement.query(By.directive(RouterOutlet)))
      .withContext('el contenedor de la feature necesita <router-outlet>')
      .not.toBeNull();
  });
});
```

**Prevención**

El test de arriba, replicado en cada contenedor de feature. Es de los pocos tests de plantilla que valen la pena: comprueba una decisión estructural que se olvida al copiar y pegar, y su fallo tiene un mensaje que se entiende sin abrir el archivo.

**Por qué llegó a producción**

Nunca llegó: se cazó en desarrollo, que es donde se cazan los errores que no producen síntomas en el servidor. Lo que sí conviene mirar es **cómo se llegó a escribir**: copiando la estructura de otra feature y omitiendo un archivo. La plantilla de la feature de plantillas sí lo tiene; la de activos se creó a mano. Un schematic propio del proyecto —`ng generate` con un template de feature— habría evitado la clase entera.

**Si tu causa fue distinta a esta**

`RouterModule.forRoot()` en vez de `forChild()` en el módulo de feature produce **exactamente el mismo síntoma**, también sin error, y es la otra causa de esta familia. Si ésa fue tu hipótesis, compruébala: `grep -n "forRoot" src/app/features/`. Si concluiste que el componente no estaba declarado, el síntoma habría sido `NG0304` en la terminal de `ng serve` — la ausencia de ese mensaje es lo que descarta esa rama.

</details>

---

## Incidente 03 — "Entro con mi usuario y me saca al login sin decir nada"

> **Fase:** 2 · **Categoría:** Integración · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-40 min · **Ruta forense:** [`forense-fase-02.md`](forense-fase-02.md) y [`forense-fase-00.md`](forense-fase-00.md)

### 🎫 El ticket

> *"Entro con mi correo y mi clave, veo el listado un segundo, y me devuelve a la pantalla de inicio de sesión. No dice nada. Pensé que era mi clave y la cambié, y sigue igual."*

**Reportado por:** inspector de campo
**Ambiente:** UAT

### 🎯 Qué se te pide

Determinar **quién** lo está echando —el guard o el interceptor— y aplicar el hotfix que hace que el usuario sepa qué pasó. La causa de fondo puede no ser tuya; el silencio sí lo es.

### 🔧 Preparación

Un flag: el fallo es de red y no hace falta tocar nada.

```bash
CHAOS=expired npm run mock
# Y en otra terminal, la aplicación como siempre:
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Hay tres piezas que pueden echarte y las tres producen el mismo síntoma en pantalla. La evidencia que las separa está en Network, no en el código — y necesitas *Preserve log* activado, porque la redirección borra el registro.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

¿Hubo o no hubo una petición fallida antes de la redirección? Sin ninguna petición en rojo, fue el guard. Con un `401` en rojo, fue el interceptor. Son dos causas que no se parecen en nada.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El interceptor hace tres cosas al recibir un `401`: cierra la sesión, navega al login y relanza el error. ¿Cuál de las tres es la que el usuario tendría que percibir, y cuál falta?

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

**Causa raíz**

Dos capas, y conviene separarlas porque el arreglo de cada una es de un equipo distinto.

**La causa técnica** es del servidor: con `CHAOS=expired`, `/auth/login` devuelve un token cuyo `exp` ya pasó. La primera petición protegida responde `401`, el `authInterceptor` la caza y hace lo que debe.

**La causa del ticket** es del frontend, y es una omisión: `authInterceptor` cierra la sesión, navega al login y relanza el error, **y no le dice nada al usuario**. Desde la silla del inspector, la aplicación lo expulsó sin motivo — y por eso cambió su contraseña, que es tiempo perdido de dos personas.

```ts
// src/app/core/interceptors/auth.interceptor.ts — lo que hay
if (error instanceof HttpErrorResponse && error.status === 401 && !isLoginRequest) {
  authService.logout();
  void router.navigate(['/login'], { queryParams: { returnUrl: router.url } });
}
```

**Parche mínimo**

El archivo es **nuevo** (funcional, con `inject()`), así que el parche se escribe en ese estilo:

```ts
// src/app/core/interceptors/auth.interceptor.ts
export const authInterceptor: HttpInterceptorFn = (request, next) => {
  const authService = inject(AuthService);
  const router = inject(Router);
  // Se inyecta ARRIBA: dentro del catchError ya no hay contexto de inyección.
  const snackBar = inject(MatSnackBar);

  // …

  return next(authorizedRequest).pipe(
    catchError((error: unknown) => {
      if (error instanceof HttpErrorResponse && error.status === 401 && !isLoginRequest) {
        authService.logout();
        // Seis segundos y con botón: un aviso de error que se va en dos es un
        // error que nadie vio. Ver el apéndice A01 §6.
        snackBar.open('Tu sesión caducó. Vuelve a entrar.', 'Cerrar', { duration: 6000 });
        void router.navigate(['/login'], { queryParams: { returnUrl: router.url } });
      }

      return throwError(() => error);
    }),
  );
};
```

**La refactorización correcta**

El interceptor no debería saber de `MatSnackBar`: mezcla una decisión de infraestructura con una de interfaz. Con calma, el interceptor emite un evento de sesión —un `Subject` en `AuthService`— y el `ShellComponent` decide cómo mostrarlo. Eso además permite probar el interceptor sin Material y hace que el día que el aviso tenga que ser un diálogo, se cambie en un sitio.

Y la causa de fondo, que no es del frontend: un token que nace vencido es un reloj desajustado entre el emisor y el verificador. Eso se lleva al equipo de backend con la evidencia del `exp` decodificado, no se parchea en el cliente.

**Prueba de regresión**

```ts
// src/app/core/interceptors/auth.interceptor.spec.ts
it('avisa al usuario cuando la sesión caduca', () => {
  const snackBar = TestBed.inject(MatSnackBar);
  const openSpy = spyOn(snackBar, 'open');

  httpClient.get('/templates').subscribe({ error: () => undefined });
  httpMock.expectOne('/templates').flush(null, { status: 401, statusText: 'Unauthorized' });

  // Falla antes del fix: el interceptor cerraba sesión en silencio.
  expect(openSpy).toHaveBeenCalledWith(
    'Tu sesión caducó. Vuelve a entrar.',
    'Cerrar',
    jasmine.objectContaining({ duration: 6000 }),
  );
});

it('NO avisa cuando el 401 es del propio login', () => {
  const openSpy = spyOn(TestBed.inject(MatSnackBar), 'open');

  httpClient.post('/auth/login', {}).subscribe({ error: () => undefined });
  httpMock.expectOne('/auth/login').flush(null, { status: 401, statusText: 'Unauthorized' });

  // Un 401 en el login significa "te equivocaste de contraseña", no "caducó
  // tu sesión". Sin esta distinción, cada intento fallido provoca un logout
  // y una redirección a /login desde /login: el bucle de parpadeo.
  expect(openSpy).not.toHaveBeenCalled();
});
```

**Prevención**

Los dos tests de arriba, y una regla de revisión que vale para cualquier interceptor: **si una pieza puede cambiar lo que el usuario ve, tiene que poder decírselo.** Un `logout()` silencioso, un reintento silencioso y un error tragado son la misma familia.

**Por qué llegó a producción**

El interceptor se escribió durante la migración de 2024 junto con el manejo del `401`, y en ese momento la única forma de perder la sesión era dejar la pestaña abierta toda la noche — un caso en el que "te devolvió al login" se entiende solo. El TTL corto llegó después, con otra decisión de otro equipo, y nadie volvió sobre el interceptor. **No es un descuido: es una decisión que dejó de ser correcta cuando cambió su contexto**, y ninguna revisión de código lo habría detectado porque el archivo no cambió.

**Si tu causa fue distinta a esta**

Si concluiste que fue el guard, comprueba Network: sin ninguna petición en rojo tendrías razón, y la causa sería el `exp` leído en milisegundos en vez de en segundos. Si concluiste que el bug es del backend, tienes razón **a medias** y es la mitad que no puedes arreglar tú: el ticket seguiría llegando igual, porque el usuario no sabría qué pasó. Y si tu fix fue quitar el `logout()`, deja al usuario con un token inválido en `localStorage` y con todas las pantallas fallando de una en una — cambia un síntoma claro por uno difuso.

</details>

---

## Incidente 04 — "La pantalla de plantillas a veces carga y a veces se queda pensando"

> **Fase:** 3 · **Categoría:** Integración · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-40 min · **Ruta forense:** [`forense-fase-03.md`](forense-fase-03.md)

### 🎫 El ticket

> *"La pantalla de plantillas a veces carga y a veces se queda pensando para siempre. Cuando se queda, ni siquiera da error: el círculo gira y ya. Toca recargar la página entera."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir de forma determinista —un fallo que ocurre "a veces" no se investiga, se hace ocurrir siempre—, identificar cuál de los seis fallos del inyector de caos es, y explicar por qué **este** no lo caza ningún `catchError`.

### 🔧 Preparación

```bash
CHAOS=timeout CHAOS_RATE=1 npm run mock
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Empieza siempre por la columna **Status** de Network, que parte el problema en tres ramas que no se parecen en nada: nadie contestó, contestaron a medias, o contestaron. Este síntoma cae en una de las tres y la elimina casi todo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`CHAOS_RATE=1` convierte el intermitente en determinista, y ése es siempre el primer movimiento. Con la petición reproducida, mira qué recibe tu código: pon un `tap` con tres callbacks —`next`, `error`, `complete`— y observa cuál de los tres se ejecuta.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Ninguno de los tres se ejecuta. Si el observable no emite, no falla y no completa, ¿de qué te sirve un `catchError`? ¿Qué operador es el único que puede intervenir cuando **no pasa nada**?

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

**Causa raíz**

El fallo es `timeout` del inyector de caos: el servidor **no responde nunca**. La petición se queda en `pending` en Network, sin status y sin error.

Y la causa del lado del cliente es una ausencia: **ningún flujo del proyecto tiene tiempo límite**. `TemplateStateService.load()` pone `loading: true`, lanza la petición, y espera indefinidamente una emisión que no va a llegar. El observable no emite, no falla y no completa, así que:

- El `catchError` **nunca se ejecuta**: no hay error que capturar.
- El `next` nunca se ejecuta: no hay valor.
- `loading` se queda en `true` para siempre, y con él el spinner.

> 🧭 **La lección de diseño: un `catchError` no te protege de que no pase nada.** Lo único que protege es un tiempo límite explícito, y decidir cuántos milisegundos es una decisión de producto que casi nadie toma hasta que le ocurre esto.

**Parche mínimo**

El archivo es **nuevo** (Fase 4, `inject()`), así que el parche va en ese estilo:

```ts
// src/app/core/state/template-state.service.ts
load(): void {
  this.patch({ loading: true, error: null });

  this.templateApi
    .getAll()
    .pipe(
      // 15 segundos: por encima de cualquier respuesta razonable del backend
      // y por debajo de la paciencia de un inspector en campo con mala señal.
      // El número es una decisión de producto, no una constante técnica.
      timeout(15_000),
    )
    .subscribe({
      next: (templates) => this.patch({ items: [...templates], loading: false }),
      error: (error: unknown) => {
        this.patch({
          loading: false,
          error:
            error instanceof TimeoutError
              ? 'El servidor no respondió a tiempo. Reintenta en unos segundos.'
              : toErrorMessage(error),
        });
      },
    });
}
```

**La refactorización correcta**

El tiempo límite no pertenece a `TemplateStateService`: pertenece al **borde HTTP**, donde ya vive la traducción de errores de la Fase 3. Un interceptor funcional lo aplica a todas las peticiones de una vez, y entonces ningún servicio de estado tiene que acordarse:

```ts
// src/app/core/interceptors/timeout.interceptor.ts — código nuevo
export const timeoutInterceptor: HttpInterceptorFn = (request, next) =>
  next(request).pipe(timeout(REQUEST_TIMEOUT_MS));
```

Con un matiz que hay que decidir antes de escribirlo: **quince segundos no valen para todo**. Una descarga de evidencias o un informe pesado necesitan más, y eso se resuelve con `HttpContext` en vez de con una excepción escrita a mano en el interceptor.

**Prueba de regresión**

```ts
// src/app/core/state/template-state.service.spec.ts
it('sale del estado de carga cuando el servidor no responde', fakeAsync(() => {
  service.load();
  httpMock.expectOne('/templates');   // la petición sale y nadie la responde

  // El tiempo virtual avanza hasta pasado el límite. Sin fakeAsync este test
  // tardaría quince segundos de reloj y sería el más lento de la suite.
  tick(15_001);

  let state: FeatureState<ChecklistTemplate> | null = null;
  service.state$.subscribe((value) => (state = value));

  // Antes del fix: loading seguía en true y error seguía en null, para siempre.
  expect(state!.loading).toBeFalse();
  expect(state!.error).toContain('no respondió a tiempo');
}));
```

**Prevención**

El interceptor de la refactorización, y una regla de revisión: **todo flujo que pinte un spinner tiene que tener una salida que no dependa del servidor.** Si el único camino para quitar el spinner es que llegue una respuesta, el spinner es eterno por diseño.

**Por qué llegó a producción**

El mock de desarrollo responde en dos milisegundos y nunca deja de responder. En UAT, detrás de una red corporativa y un proxy, sí ocurre — y ocurre poco, así que llega como "a veces". El sistema permitió esto porque **el caso "no pasa nada" no aparece en ninguna prueba manual**: para verlo hay que provocarlo, y provocarlo es exactamente lo que el inyector de caos de la Fase 3 existe para hacer barato.

**Si tu causa fue distinta a esta**

Si concluiste `latency`, el síntoma se parece y hay una diferencia observable: con latencia la petición **termina**, y en Timing se ve un `Waiting (TTFB)` alto. Aquí no termina nunca. Si concluiste que el bug es que falta un botón de reintentar, no te equivocas —hace falta— pero sin tiempo límite ese botón no se puede llegar a mostrar, porque la pantalla sigue creyendo que está cargando.

</details>

---

## Incidente 05 — "Entro a Plantillas y dice que no hay ninguna, pero en el mock están las tres"

> **Fase:** 4 · **Categoría:** Estado (servicios) · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 25-40 min · **Ruta forense:** [`forense-fase-04.md`](forense-fase-04.md)

### 🎫 El ticket

> *"Entro a Plantillas y la pantalla dice que no hay ninguna. Pero yo veo las tres en el mock, y si entro por el editor sí aparecen. Es sólo el listado."*

**Reportado por:** un compañero del equipo
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Explicar por qué una pantalla ve el estado vacío y otra no, y arreglarlo de forma que el fix no dependa de que cada pantalla nueva se acuerde de algo.

### 🔧 Preparación

```bash
git switch -c incidente/05 fase-04
npm run mock     # sin ningún flag: el backend está perfectamente bien
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de mirar el estado, mira la red. Hay una pregunta que casi nadie hace y que aquí lo resuelve todo: ¿cuántas peticiones a `/templates` salen al entrar a esa pantalla?

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

No sale ninguna. El servicio de estado tiene un `BehaviorSubject` que **siempre** entrega un valor a quien se suscriba, aunque nadie haya cargado nada. ¿Qué valor entrega en ese caso?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`createInitialState<T>()` devuelve `{ items: [], selected: null, loading: false, error: null }`. Suscribirse no carga nada: pedir y recordar son dos responsabilidades distintas. ¿Quién llama a `load()`, y qué pasa si nadie lo hace?

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

**Causa raíz**

`TemplateListComponent` se suscribe a `templateState.templates$` y **nadie llama a `load()`**. El `BehaviorSubject` entrega su valor inicial —un array vacío— y la pantalla lo pinta con toda corrección: cero plantillas.

El editor sí funciona porque él **sí** llama a `load()` en su `ngOnInit`. Y de ahí sale el detalle que confunde al reportar: si entras primero al editor y después al listado, **el listado funciona**, porque el servicio raíz conserva el estado entre navegaciones. El bug parece intermitente y depende del orden en que abras las pantallas.

```
Network al entrar a /templates:  (ninguna petición a /templates)
Estado emitido:                  { items: [], loading: false, error: null }
```

> 🧠 **La confusión de fondo, y es la que este incidente entrena: suscribirse no es cargar.** Un `BehaviorSubject` siempre tiene un valor; que te lo entregue no significa que alguien haya ido a buscarlo. `state$` no miente: dice la verdad sobre un estado que nadie llenó.

**Parche mínimo**

```ts
// src/app/features/templates/template-list/template-list.component.ts
ngOnInit(): void {
  // Sin esta línea, la pantalla pinta el estado inicial —vacío— y no pide nada.
  this.templateState.load();
}
```

**La refactorización correcta**

El parche funciona y **traslada el problema a la siguiente pantalla que alguien escriba**. La Fase 6, la 7 y la 11 van a consumir este mismo estado, y las tres tendrían que acordarse.

La forma que no exige memoria es que el servicio cargue **la primera vez que alguien mire**:

```ts
// src/app/core/state/template-state.service.ts
/**
 * Carga perezosa: la primera suscripción dispara la petición y las siguientes
 * comparten el resultado. Ninguna pantalla tiene que acordarse de nada, y
 * quien necesite datos frescos llama a `reload()` explícitamente.
 *
 * `refCount: true` es obligatorio: sin él la suscripción interna quedaría viva
 * para siempre aunque no quede nadie mirando. Ver el apéndice A06 §7.
 */
readonly templates$: Observable<readonly ChecklistTemplate[]> = defer(() => {
  if (!this.loadedOnce) {
    this.loadedOnce = true;
    this.load();
  }
  return this.state$;
}).pipe(
  map((state) => state.items),
  distinctUntilChanged(),
  shareReplay({ bufferSize: 1, refCount: true }),
);
```

Con la contrapartida dicha en voz alta: **una carga escondida en un `defer` es más difícil de seguir en un breakpoint** que un `load()` explícito en un `ngOnInit`. Es un intercambio real —menos memoria a cambio de menos transparencia— y merece decidirse en equipo, no colarse en un hotfix.

**Prueba de regresión**

```ts
// src/app/features/templates/template-list/template-list.component.spec.ts
it('pide las plantillas al montarse', () => {
  const templateState = TestBed.inject(TemplateStateService);
  const loadSpy = spyOn(templateState, 'load');

  fixture.detectChanges();   // dispara ngOnInit

  // Falla antes del fix: nadie llamaba a load() y la pantalla pintaba vacío.
  expect(loadSpy).toHaveBeenCalledTimes(1);
});

it('no confunde "sin cargar" con "no hay ninguna"', fakeAsync(() => {
  fixture.detectChanges();
  httpMock.expectOne('/templates').flush([templateV1, templateV2, boilerV1]);
  tick();
  fixture.detectChanges();

  expect(fixture.debugElement.queryAll(By.css('[data-testid="template-row"]')).length).toBe(3);
}));
```

**Prevención**

El segundo test es el que importa a largo plazo, y su nombre es la lección: **"sin cargar" y "no hay ninguna" son dos estados distintos que hoy se pintan igual.** Un `FeatureState<T>` con un campo `loaded: boolean` los separaría, y la pantalla podría decir "cargando…" en vez de "no hay plantillas". Es un pendiente legítimo de este incidente.

**Por qué llegó a producción**

No llegó: se cazó en desarrollo. Y aun así merece post-mortem, porque el sistema **facilitó** el error de dos maneras. Primero, el estado inicial de una lista vacía es indistinguible de una lista que de verdad está vacía. Segundo, el bug es intermitente según el orden de navegación, así que quien lo reporta describe algo que a otro no le pasa — y eso desgasta la confianza en el reporte antes de que nadie mire nada.

**Si tu causa fue distinta a esta**

Si concluiste que el mock no devuelve nada, se descarta con un `curl` a `/templates`: devuelve las tres. Si concluiste que hay un `shareReplay` mal puesto, es una hipótesis razonable y produce un síntoma parecido —datos que no llegan a un segundo suscriptor— pero la evidencia lo tumba: con `shareReplay` mal puesto **habría** una petición en Network, y aquí no hay ninguna. **La ausencia de tráfico es lo que hace único a este incidente**, y es el primer sitio donde hay que mirar.

</details>

---
## Incidente 06 — "El botón de Nuevo cliente se ve gris y plano desde el martes, pero todo compila"

> **Fase:** 5 · **Categoría:** Convivencia de estilos 🧬 · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-45 min · **Ruta forense:** [`forense-fase-05.md`](forense-fase-05.md)

### 🎫 El ticket

> *"El botón de Nuevo cliente se ve gris y plano desde el martes. Antes era azul y con sombra. No se rompió nada, funciona, pero se ve raro y el resto de botones de la aplicación sí están bien."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Explicar por qué **compila y no falla** un componente al que le falta algo, y arreglarlo. El entregable incluye decir qué cambió "el martes".

### 🔧 Preparación

```bash
git switch -c incidente/06 fase-05
npm start
# Entra a /clients y compara ese botón con cualquier otro de la aplicación
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No mires el CSS todavía. Inspecciona el elemento `<button>` y compara sus clases con las de un botón que sí se ve bien, en otra pantalla. La diferencia no está en los estilos: está en lo que le falta al elemento.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Un botón correcto tiene clases `mat-mdc-raised-button mat-primary`. El tuyo no tiene ninguna. Nadie se las puso. ¿Quién se las pone normalmente, y por qué en este componente no?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`mat-raised-button` no es un componente: es una **directiva con selector de atributo**. Un atributo que ninguna directiva reclama es HTML perfectamente válido. ¿Qué pasó "el martes" con lo que este componente importaba?

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

**Causa raíz**

`ClientListComponent` es standalone y **no tiene `MatButtonModule` en sus `imports`**.

Y aquí está lo que hace peligroso a este bug: `mat-raised-button` es una **directiva con selector de atributo**. Si nadie la provee, `<button mat-raised-button>` es un `<button>` con un atributo desconocido — HTML válido, sin error de plantilla, sin advertencia. El compilador sólo se queja de un elemento desconocido (`NG0304`) o de una **propiedad** que no existe (`NG0303`); un atributo suelto no dispara ninguno de los dos.

```html
<!-- Lo que el navegador acaba pintando: -->
<button mat-raised-button color="primary">Nuevo cliente</button>
<!-- …sin una sola clase de Material. Un botón del sistema, gris y plano. -->
```

**Y "el martes"** fue el pago de la deuda 💸 del `SharedModule` en la Fase 5: hasta entonces, `SharedModule` reexportaba media librería de Material y **todo el que lo importara heredaba `MatButtonModule` sin pedirlo**. Al convertir este componente a standalone, esa herencia desapareció y quedó al descubierto que nunca declaró lo que usaba.

> 🧬 **Es la costura exacta entre generaciones**, y por eso este incidente no puede existir en un sistema de una sola época: en el mundo de los NgModule, importar de más funcionaba; en el mundo standalone, cada archivo declara lo que usa. El componente no se rompió al convertirlo — **ya estaba mal y el `SharedModule` lo tapaba.**

**Parche mínimo**

```ts
// src/app/features/clients/client-list/client-list.component.ts
@Component({
  selector: 'cc-client-list',
  standalone: true,
  imports: [
    AsyncPipe,
    NgIf,
    RouterLink,
    MatButtonModule,   // ← lo que faltaba. La directiva mat-raised-button vive aquí.
    MatFormFieldModule,
    MatIconModule,
    MatInputModule,
    MatTableModule,
  ],
  // …
})
```

**La refactorización correcta**

Ninguna sobre el componente: importar lo que usas **es** el modelo standalone. Lo que sí conviene, y en otro commit, es buscar a los demás heridos del mismo pago:

```bash
# Componentes standalone que usan directivas de Material sin importar su módulo.
grep -rln "mat-raised-button\|mat-stroked-button\|mat-icon-button" src/app --include="*.html" \
  | while read -r html; do
      ts="${html%.html}.ts"
      grep -q "MatButtonModule" "$ts" || echo "FALTA MatButtonModule → $ts"
    done
```

**Prueba de regresión**

```ts
// src/app/features/clients/client-list/client-list.component.spec.ts
it('pinta el botón de nuevo cliente con el estilo de Material', () => {
  fixture.detectChanges();

  const button = fixture.debugElement.query(By.css('[data-testid="new-client"]'));

  // Falla antes del fix: sin MatButtonModule importado, la directiva no corre
  // y el elemento no recibe ninguna clase de Material. El atributo del HTML
  // sigue ahí, así que comprobar el atributo NO detectaría nada.
  expect(button.nativeElement.classList).toContain('mat-mdc-raised-button');
});
```

> 💡 **Comprobar la clase y no el atributo es toda la gracia de este test.** El atributo `mat-raised-button` está en la plantilla tanto si la directiva corre como si no; la clase `mat-mdc-raised-button` sólo aparece si corrió.

**Prevención**

El test de arriba en cada pantalla con botones de acción, y el `grep` de la refactorización convertido en una comprobación del pipeline. A largo plazo, lo que de verdad previene esta familia es una regla de revisión: **cuando un componente se convierte a standalone, sus `imports` se derivan de su plantilla, no de lo que "ya venía funcionando".**

**Por qué llegó a producción**

Porque no rompió nada. El componente compiló, los tests pasaron —no había ninguno que mirase el estilo— y la pantalla funcionaba: el botón se pulsa y navega. **Un fallo puramente visual no tiene ningún mecanismo automático que lo detecte** en este proyecto, así que la única red era que alguien mirase la pantalla, y quien hizo la conversión miró que funcionara.

El sistema lo permitió por una decisión razonable de 2021 —un `SharedModule` que reexporta Material "por comodidad"— cuyo costo real sólo se ve el día que alguien deja de importarlo. Es la definición de deuda técnica: barata al contraerla, y la factura llega en un momento que no eliges.

**Si tu causa fue distinta a esta**

Si buscaste el problema en `styles.scss` o en el tema, es exactamente donde el ticket te empuja a mirar y no hay nada: el tema está bien y el resto de botones lo demuestra. Si concluiste que faltaba `color="primary"`, el atributo está puesto — y sin la directiva tampoco haría nada. Y si tu fix fue añadir CSS propio para que se vea azul, funcionaría hasta que alguien cambie el tema, y habrías creado un botón que ya no participa del sistema de diseño.

</details>

---

## Incidente 07 — "Metí el listado de clientes en el panel y la pantalla se queda en blanco"

> **Fase:** 5 · **Categoría:** Convivencia de estilos 🧬 · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-50 min · **Ruta forense:** [`forense-fase-05.md`](forense-fase-05.md) y [`forense-fase-01.md`](forense-fase-01.md)

### 🎫 El ticket

> *"Me pidieron mostrar los últimos clientes en el panel principal. Reusé el componente del listado, que ya existe. La pantalla del panel se queda en blanco. Por el menú de Clientes sigue funcionando igual de bien."*

**Reportado por:** un compañero del equipo
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Explicar por qué **el mismo componente** funciona por una ruta y no por otra, y arreglarlo de forma que el componente sea reusable de verdad.

### 🔧 Preparación

```bash
git switch -c incidente/07 fase-05
npm start
# Entra al panel principal, y después a /clients por el menú
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Hay un error en consola y su mensaje es largo. No leas el stack: lee lo que hay **entre paréntesis** justo después de `R3InjectorError`. Ese paréntesis decide si vas a buscar en diez archivos o en dos.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El paréntesis dice `Standalone[ClientListComponent]`. Eso significa que el inyector que falló es el del propio componente, y que ningún `.module.ts` va a tener la respuesta. La pregunta correcta no es "qué falta" sino **"por qué ruta llegó este componente a la pantalla"**.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`grep -rn "CLIENT_LIST_PAGE_SIZE" src/app --include="*.ts"`. Hay exactamente un sitio que lo provee. ¿Está en el camino del panel?

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

**Causa raíz**

```
ERROR NullInjectorError: R3InjectorError(Standalone[ClientListComponent])[InjectionToken CLIENT_LIST_PAGE_SIZE -> InjectionToken CLIENT_LIST_PAGE_SIZE]:
  NullInjectorError: No provider for InjectionToken CLIENT_LIST_PAGE_SIZE!
```

`ClientListComponent` hace `inject(CLIENT_LIST_PAGE_SIZE)`, y ese token **sólo se provee en la ruta `/clients`**:

```ts
// src/app/features/clients/clients.routes.ts
{
  path: '',
  loadComponent: () => import('./client-list/client-list.component').then((m) => m.ClientListComponent),
  providers: [{ provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 }],
}
```

Un componente standalone resuelve sus dependencias en su propio inyector y en el de **la ruta que lo activó**. Por el menú se pasa por esa ruta y el token está; embebido en la plantilla del panel, no hay ninguna ruta que lo traiga. **La misma clase, dos inyectores distintos.**

> 🧬 **Y por eso este incidente es de convivencia y no de configuración.** En el mundo de los NgModule, un provider registrado en un módulo lo veía todo lo que ese módulo declaraba, vinieras por donde vinieras. En el mundo standalone, **el camino importa**, y ése es el cambio de modelo mental que la Fase 5 entrena.

**Parche mínimo**

Sí, hay un parche de una línea, y **no es el que hay que entregar**:

```ts
// El hotfix de un viernes: proveer el token también en la ruta del panel.
{ path: '', component: DashboardComponent, providers: [{ provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 }] }
```

Funciona y deja la trampa puesta para la siguiente pantalla que reuse el componente. Se entrega **sólo** si hay que desplegar ya, y con el ticket de seguimiento abierto en el mismo commit.

**La refactorización correcta**

El token tiene un valor por defecto razonable, así que lo declara él:

```ts
// src/app/features/clients/client-list-page-size.token.ts
/**
 * Cuántas filas por página muestra el listado de clientes.
 *
 * La factory `providedIn: 'root'` es lo que hace al componente REUSABLE: quien
 * lo monte sin decir nada obtiene 25, y quien necesite otro tamaño lo provee en
 * su ruta. Sin ella, el componente sólo funciona por el camino que su autor
 * probó — y el error que da no dice "te falta un provider en la ruta", dice
 * "no hay proveedor", que suena a un problema del componente.
 */
export const CLIENT_LIST_PAGE_SIZE = new InjectionToken<number>('CLIENT_LIST_PAGE_SIZE', {
  providedIn: 'root',
  factory: () => 25,
});
```

La ruta de clientes puede seguir sobrescribiéndolo con `5`, y el panel funciona sin tocar nada.

> 🧭 **La regla que sale de aquí y que vale para todo el curso: un componente standalone que exige un provider de ruta no es reutilizable, es una trampa.** Funciona por el camino que su autor probó y explota por cualquier otro.

**Prueba de regresión**

```ts
// src/app/features/clients/client-list/client-list.component.spec.ts
it('se monta sin ningún provider de ruta', () => {
  // Ni un solo `providers`: es exactamente la situación del panel.
  TestBed.configureTestingModule({
    imports: [ClientListComponent],
    providers: [provideHttpClient(), provideHttpClientTesting()],
  });

  // Falla antes del fix con NullInjectorError. El test es el escenario, no la aserción.
  const fixture = TestBed.createComponent(ClientListComponent);
  fixture.detectChanges();

  expect(fixture.componentInstance.pageSize).toBe(25);
});

it('respeta el tamaño que provea la ruta', () => {
  TestBed.configureTestingModule({
    imports: [ClientListComponent],
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: CLIENT_LIST_PAGE_SIZE, useValue: 5 },
    ],
  });

  expect(TestBed.createComponent(ClientListComponent).componentInstance.pageSize).toBe(5);
});
```

**Prevención**

El primer test es la prevención: **montar todo componente standalone sin ningún provider de ruta, como parte de su suite.** Si no se monta así, no es reusable, y el test lo dice antes de que alguien lo descubra embebiéndolo en otra pantalla.

**Por qué llegó a producción**

El componente se escribió para una ruta y se probó en esa ruta. Nada en el código dice "esto necesita que alguien te provea algo": la dependencia es invisible desde fuera, y el compilador no puede avisar porque el token existe y el tipo cuadra. El fallo sólo aparece en tiempo de ejecución y sólo por el camino que nadie probó.

El sistema lo permitió porque **la Fase 5 introdujo el token con provider de ruta a propósito**, para enseñar el mecanismo, y la deuda quedó declarada. Este incidente es su factura.

**Si tu causa fue distinta a esta**

Si buscaste en `SharedModule` o en `CoreModule`, el paréntesis del error te estaba diciendo que ahí no había nada que buscar — y perder diez minutos ahí la primera vez es normal: es exactamente el reflejo heredado que este track entrena a corregir. Si tu fix fue `inject(CLIENT_LIST_PAGE_SIZE, { optional: true }) ?? 25`, funciona, y con `strict` te obliga a decidir el valor por defecto **en el componente** en vez de en el token: es defendible, y el argumento en contra es que ese 25 queda escondido en una línea de inyección en vez de estar donde se define el token.

</details>

---

## Incidente 08 — "La inspección de agosto ahora tiene un ítem más que cuando la hice"

> **Fase:** 7 · **Categoría:** Versionado normativo · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min · **Ruta forense:** [`forense-fase-07.md`](forense-fase-07.md) y [`forense-fase-12.md`](forense-fase-12.md)

### 🎫 El ticket

> *"La inspección 501, la del ascensor de la torre A que hice en agosto del año pasado, ahora tiene un ítem más que cuando la hice. Yo respondí tres cosas y ahora aparecen cuatro, y la última está vacía. No la he vuelto a tocar. Y el título del primer ítem tampoco es el que yo leí."*

**Reportado por:** inspector de campo
**Ambiente:** UAT

### 🎯 Qué se te pide

Localizar la línea, aplicar el fix, y —**antes del fix**— escribir el test que reproduce el bug y verlo fallar. Este incidente es el que cierra el par de tags de la convención.

### 🔧 Preparación

```bash
git switch -c incidente/08 fase-07
npm run mock
npm start
# Abre la inspección 501
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No abras ningún archivo todavía. La petición que la pantalla hace al abrir la inspección contesta la pregunta entera, y está en Network.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Compara dos cosas: el campo `templateVersion` de la inspección 501, y los parámetros de la petición a `/templates`. Uno de los dos números no aparece donde debería.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`grep -rn "resolveTemplateVersion" src/app --include="*.ts"`. Esa función contesta *"¿qué versión rige hoy?"*, que es una pregunta legítima. ¿Es la pregunta que hay que hacer al **leer** una inspección que ya se ejecutó?

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

**Causa raíz**

La pantalla de detalle resuelve la plantilla **por fecha de hoy** en vez de leer la versión que la inspección guardó.

```
Lo que la inspección dice:   templateVersion: 1
Lo que la pantalla pide:     GET /templates?templateId=elevator-annual
                                                       ↑ sin &version=
Lo que recibe:               la v2 — cuatro ítems, y "Estado y tensión del cable principal"
```

La v1 tiene tres ítems y la v2 tiene cuatro. El cuarto (`cabin-lighting`) aparece vacío porque **nadie lo respondió: no existía en agosto de 2023**. Y el título de `main-cable` cambió con la norma, que es lo que hace el bug *visible* en vez de sólo incorrecto.

```ts
// src/app/features/inspections/inspection-detail/inspection-detail.component.ts
const template = resolveTemplateVersion(family, todayInBusinessZone());
```

> 🧭 **Las dos preguntas que suenan igual y no lo son:** *"¿qué versión rige hoy?"* es un cálculo sobre fechas y sirve para **empezar** una inspección nueva. *"¿con qué versión se ejecutó ésta?"* es leer un campo, y es lo único correcto al **abrir** una que ya existe. Confundirlas no da ningún error: da un histórico que cambia solo.

**Parche mínimo**

El archivo es **nuevo**, así que el parche va en estilo nuevo:

```ts
// src/app/features/inspections/inspection-detail/inspection-detail.component.ts
readonly view$ = this.route.paramMap.pipe(
  map((params) => Number(params.get('inspectionId'))),
  switchMap((inspectionId) => this.inspectionApi.getById(inspectionId)),
  switchMap((inspection) =>
    // La versión que la inspección GUARDÓ. Es un campo, no un cálculo: una
    // inspección se lee siempre con la plantilla con la que se ejecutó, hoy y
    // dentro de diez años, aunque la vigente sea otra.
    this.templateApi
      .getByVersion(inspection.templateId, inspection.templateVersion)
      .pipe(map((template) => ({ inspection, template }))),
  ),
);
```

**La refactorización correcta**

El parche arregla una pantalla. Lo que evita la familia entera es hacer **imposible** pedir una plantilla para una inspección sin decir su versión:

```ts
// src/app/core/api/template-api.service.ts
/**
 * La única forma soportada de obtener la plantilla de una inspección
 * existente. Recibe la inspección entera precisamente para que nadie pueda
 * llamarla sin la versión: el tipo lo impide.
 */
templateOf(inspection: Inspection): Observable<ChecklistTemplate> {
  return this.getByVersion(inspection.templateId, inspection.templateVersion);
}
```

Y la regla de revisión que la acompaña: **cada aparición de `resolveTemplateVersion` hay que justificarla en el propio código**, porque es correcta en un sitio del curso y sólo en uno —la Fase 8 §5.9, al empezar una inspección nueva—.

**Prueba de regresión**

Va **antes** del fix, y hay que verla fallar. No necesita `TestBed`: la regla vive en una función pura.

```ts
// src/app/core/domain/template-resolution.spec.ts
it('lee una inspección con la versión que guardó, no con la vigente', () => {
  const family = [templateV1, templateV2];   // v1 hasta 2023-12-31, v2 desde 2024-01-01
  const inspection = { templateId: 'elevator-annual', templateVersion: 1 } as Inspection;

  const applied = family.find((version) => version.version === inspection.templateVersion);

  expect(applied?.version).toBe(1);
  expect(applied?.items.length).toBe(3);            // la v2 tiene cuatro
  expect(applied?.items[0].title).toBe('Estado del cable principal');   // la v2 dice "y tensión"
});
```

```
Chrome Headless: Executed 1 of 1 (1 FAILED)
  ✗ lee una inspección con la versión que guardó, no con la vigente
    Expected 2 to be 1.
```

```bash
git tag -a inc/08/version-ejecutada-roto -m "F7 inc08: el test reproduce el bug y falla"
# …el fix…
git tag -a inc/08/version-ejecutada-fix  -m "F7 inc08: causa raíz y fix, con el test en verde"
git diff inc/08/version-ejecutada-roto inc/08/version-ejecutada-fix   # ← dos líneas
```

**Prevención**

El test de arriba, el método `templateOf()` de la refactorización, y un test de contrato que vale más que los dos: **ninguna petición a `/templates` originada al abrir una inspección puede salir sin `version=`.** Con `HttpTestingController` eso se comprueba en tres líneas y cubre todas las pantallas a la vez.

**Por qué llegó a producción**

Durante casi tres años **no hubo ninguna segunda versión de ninguna plantilla**. `resolveTemplateVersion(family, hoy)` devolvía la única que existía, que era también la que la inspección había usado, y el código era correcto por casualidad. El bug nació el día que se publicó la v2 de `elevator-annual`, en enero de 2024, **sin que nadie tocara una línea de la aplicación**.

Es la clase de fallo que ninguna revisión de código detecta, porque el código que se revisó no cambió: cambió el dato. Y es la razón por la que este curso repite el invariante hasta el cansancio en vez de confiar en que se deduzca.

**Si tu causa fue distinta a esta**

Si concluiste que el editor sobrescribió la v1, es la hipótesis correcta de descartar primero y se tumba con un `diff` contra `db.seed.json`: la v1 está intacta. Si concluiste que hay que "actualizar las inspecciones viejas a la versión nueva", ése es el bug propuesto como arreglo: una inspección responde a las preguntas que se le hicieron, y migrarla inventa respuestas que nadie dio. Y si tu fix fue filtrar el ítem vacío en la vista, taparías el síntoma dejando los otros dos —el título cambiado y la versión equivocada— intactos y ahora invisibles.

</details>

---

## Incidente 09 — "Publiqué la v3 y el sistema dice que hay dos plantillas vigentes"

> **Fase:** 7 · **Categoría:** Versionado normativo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-70 min · **Ruta forense:** [`forense-fase-07.md`](forense-fase-07.md)

### 🎫 El ticket

> *"Publiqué la v3 de la plantilla de ascensores porque cambió la norma. Ahora, cuando empiezo una inspección nueva, unas veces me sale con los ítems de la v2 y otras con los de la v3. En el listado de plantillas aparecen las dos como vigentes."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Explicar por qué el resultado es **inconsistente entre llamadas** y arreglar la operación que dejó el sistema en ese estado. Y decidir qué hacer con el dato que ya está mal.

### 🔧 Preparación

El bug está en el dato, no en el código: un `db.json` alterno.

```bash
cp mock/db.json mock/db.mio.json          # guarda el tuyo
cp mock/db.incidente-09.json mock/db.json
npm run mock
npm start
```

Para volver: `npm run seed`, o `cp mock/db.mio.json mock/db.json`.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

"Unas veces una y otras otra" con el mismo dato de entrada no es aleatoriedad: es un desempate que nadie definió. Antes de mirar el código, mira las tres filas de la familia `elevator-annual` y sus dos campos de vigencia.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s "http://localhost:3000/templates?templateId=elevator-annual" \
  | python3 -c "import json,sys; [print(t['version'], t['validFrom'], t['validUntil']) for t in json.load(sys.stdin)]"
```

Mira la columna de la derecha. ¿Cuántas filas dicen `None`, y qué significa `null` en ese campo?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Publicar una versión nueva son **dos** escrituras: nace la v3 con su `validFrom`, y se cierra la v2 poniéndole `validUntil`. Si sólo ocurre la primera, no falla nada hoy. ¿Qué hace `resolveTemplateVersion` cuando dos versiones son válidas para la misma fecha?

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

**Causa raíz**

```
version  validFrom    validUntil
1        2021-01-01   2023-12-31
2        2024-01-01   None          ← sigue abierta
3        2025-06-01   None          ← y la nueva también
```

`null` en `validUntil` significa **"vigente indefinidamente"**. Dos filas con `null` a la vez son dos ventanas abiertas que se solapan desde el 1 de junio de 2025, y `resolveTemplateVersion` tiene que elegir entre dos respuestas igualmente válidas. Devuelve la que le toque según el orden en que json-server le entregue el array — que no está garantizado — y por eso el resultado cambia entre llamadas.

La operación culpable es `publish()`: **hace una escritura donde el dominio exige dos**.

```ts
// src/app/core/state/template-state.service.ts — lo que hay
publish(draft: ChecklistTemplateDraft): void {
  this.templateApi.create(draft).subscribe(/* … */);   // nace la v3, y nadie cierra la v2
}
```

> ⚠️ **Es la clase de bug que `strict` no puede atrapar**, y conviene entender por qué: `null` es un valor perfectamente válido en las dos filas. No hay ningún tipo que se viole. El invariante que se rompe —"como máximo una versión vigente por familia en cualquier fecha"— no vive en el sistema de tipos: vive en el dominio, y ahí hay que ponerlo a la fuerza.

**Parche mínimo**

```ts
// src/app/core/state/template-state.service.ts
publish(draft: ChecklistTemplateDraft): void {
  this.patch({ loading: true, error: null });

  // Publicar son DOS escrituras. `concatMap` y no `mergeMap`: el orden importa,
  // porque si la nueva versión nace antes de que la anterior se cierre, hay una
  // ventana —corta, real— en la que el sistema tiene dos vigentes.
  const closesPrevious$ = this.currentActive(draft.templateId).pipe(
    concatMap((active) =>
      active === null
        ? of(null)
        : this.templateApi.close(active.id, previousDay(draft.validFrom)),
    ),
  );

  closesPrevious$
    .pipe(concatMap(() => this.templateApi.create(draft)))
    .subscribe({
      next: () => this.load(),
      error: (error: unknown) => this.patch({ loading: false, error: toErrorMessage(error) }),
    });
}
```

Y el dato que ya está mal se corrige a mano, una vez, con su registro:

```bash
curl -s -X PATCH "http://localhost:3000/templates/elevator-annual-v2" \
  -H 'Content-Type: application/json' \
  -d '{"validUntil":"2025-05-31"}'
```

**La refactorización correcta**

Dos escrituras desde el navegador **no son atómicas**: si la segunda falla, el sistema queda en el estado inconsistente que este ticket describe, y ahora por culpa del fix. La forma correcta es un endpoint de publicación en el servidor que haga las dos cosas en una transacción — y **CertCore no tiene backend propio**, así que ésa es una conversación con el equipo de backend, no un cambio de frontend.

Lo que sí se puede hacer desde aquí, y es lo que hay que entregar junto al parche: **una comprobación que detecte el estado inconsistente en vez de asumir que no ocurre.**

```ts
// src/app/core/domain/template-family.ts
/** Devuelve las versiones que se solapan. Un array vacío es el invariante cumplido. */
export function overlappingVersions(
  family: readonly ChecklistTemplate[],
): readonly (readonly [ChecklistTemplate, ChecklistTemplate])[] { … }
```

**Prueba de regresión**

```ts
// src/app/core/domain/template-family.spec.ts
it('detecta dos versiones vigentes a la vez', () => {
  const family = [
    { version: 2, validFrom: '2024-01-01', validUntil: null },
    { version: 3, validFrom: '2025-06-01', validUntil: null },
  ] as ChecklistTemplate[];

  // Falla antes del fix: nadie comprobaba esto y el array salía vacío.
  expect(overlappingVersions(family).length).toBe(1);
});

it('publicar cierra la versión anterior', fakeAsync(() => {
  service.publish({ templateId: 'elevator-annual', validFrom: '2025-06-01', items: [] });

  // La primera petición es el CIERRE, no la creación: el orden es parte del fix.
  const close = httpMock.expectOne((r) => r.method === 'PATCH' && r.url.includes('elevator-annual-v2'));
  expect(close.request.body).toEqual({ validUntil: '2025-05-31' });
  close.flush({});
  tick();

  httpMock.expectOne((r) => r.method === 'POST' && r.url.endsWith('/templates')).flush({});
  tick();
}));
```

**Prevención**

`overlappingVersions()` ejecutado al cargar la familia, con un aviso visible en el editor cuando devuelve algo. No arregla el dato, y **hace imposible que el estado inconsistente pase desapercibido tres meses**, que es lo que ocurrió aquí.

**Por qué llegó a producción**

`publish()` se escribió cuando la familia de ascensores tenía una sola versión, y con una sola versión **una escritura basta**: no hay ninguna anterior que cerrar. La operación fue correcta durante todo 2021 y 2022. Se volvió incorrecta en enero de 2024, con la v2, y nadie lo notó porque la v1 sí tenía `validUntil` puesto — se lo había puesto alguien a mano, en una migración, sin dejar constancia de que eso era un requisito.

**El invariante existía en la cabeza del equipo original y en ningún archivo.** Ésa es la causa raíz de fondo, y por eso la prevención es una función con nombre y no un recordatorio.

**Si tu causa fue distinta a esta**

Si concluiste que `resolveTemplateVersion` está mal escrita, mírala otra vez: hace lo que puede con una entrada ambigua, y **cualquier desempate que le pongas —la más nueva, la de `validFrom` más reciente— esconde el problema real**, que es que el dato no debería ser ambiguo. Ese cambio hace que el síntoma desaparezca y que el sistema siga aceptando publicaciones incompletas, que es peor. Si concluiste que es un problema de ordenación de json-server, tienes razón en el mecanismo y no en la causa: el orden es lo que hace visible la ambigüedad, no lo que la crea.

</details>

---

## Incidente 10 — "Cambié de inspección desde el listado y me aparecieron ítems de la otra"

> **Fase:** 8 · **Categoría:** Versionado normativo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-70 min · **Ruta forense:** [`forense-fase-07.md`](forense-fase-07.md) y [`forense-fase-08.md`](forense-fase-08.md)

### 🎫 El ticket

> *"Estaba llenando la inspección de la caldera y me acordé de que tenía otra a medias. Volví al listado, abrí la del ascensor, y me aparecieron mezclados ítems de las dos. Uno de ellos ni siquiera es de ascensores."*

**Reportado por:** inspector de campo
**Ambiente:** UAT

### 🎯 Qué se te pide

Localizar por qué el formulario conserva controles de la inspección anterior, y arreglarlo. El entregable incluye distinguir este caso del que **sí** es correcto: un ítem retirado de la misma familia.

### 🔧 Preparación

```bash
git switch -c incidente/10 fase-08
npm run mock
npm start
# Abre la inspección 502 (caldera), vuelve al listado, abre la 500 (ascensor)
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El formulario no está escrito en ningún HTML: se construye desde datos. Así que se depura **comparándolo con los datos**, no leyéndolo. Dos líneas de consola bastan.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```js
const component = ng.getComponent($0);   // el <form>
Object.keys(component.currentView.form.controls);
component.currentView.template.items.map((item) => item.id);
```

Las dos listas tienen que ser idénticas. ¿Qué clave sobra, y a qué plantilla pertenece?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`pressure-valve` es de `boiler-annual`. ¿Qué método se está usando para meter los controles de la inspección nueva, y qué hace ese método cuando la clave ya existe… y cuando sobra?

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

**Causa raíz**

```js
Object.keys(form.controls);
// ['pressure-valve', 'flue-gas', 'main-cable', 'emergency-brake', 'door-sensor', 'cabin-lighting']

template.items.map((i) => i.id);
// ['main-cable', 'emergency-brake', 'door-sensor', 'cabin-lighting']
```

`pressure-valve` y `flue-gas` son de `boiler-annual`. **El formulario no se reconstruye al cambiar de inspección: se le añaden encima los controles de la nueva.**

```ts
// src/app/features/inspections/inspection-form/inspection-form.component.ts
for (const item of template.items) {
  this.form.addControl(item.id, buildItemGroup(item, answerByItemId.get(item.id) ?? null));
}
```

`addControl()` **no reemplaza** si la clave ya existe y **no quita** las que sobran. Con un `FormRecord` que sobrevive a la navegación, cada inspección deja su sedimento.

**La distinción que hay que saber hacer**, porque hay un caso idéntico en apariencia que **es correcto**:

| La clave sobrante es… | Qué pasó | ¿Bug? |
|---|---|---|
| un `itemId` de **otra plantilla** (`pressure-valve` en un ascensor) | el formulario no se reconstruyó | **sí** — es este incidente |
| un `itemId` de la **misma familia**, retirado en una versión posterior | una respuesta de un ítem que ya no existe | **no** — se pinta como "ítem retirado" |
| un `itemId` que no existe en ninguna plantilla | el dato está corrompido | **sí**, y no está en el frontend |

**Parche mínimo**

```ts
// Un formulario nuevo por inspección. `buildAnswerForm` es una función pura:
// dale los datos y te devuelve el formulario. No hay estado que arrastrar,
// y por eso no hace falta acordarse de limpiar nada.
readonly currentView$ = this.route.paramMap.pipe(
  map((params) => Number(params.get('inspectionId'))),
  switchMap((inspectionId) => this.loadView(inspectionId)),
  map(({ inspection, template }) => ({
    inspection,
    template,
    form: buildAnswerForm(template, inspection.answers),
  })),
);
```

**La refactorización correcta**

El parche ya lo es. Lo que conviene además es **hacer imposible** el error, quitando la operación que lo permitió: si nadie llama nunca a `addControl` sobre un formulario existente, el bug no puede volver.

```ts
// src/app/core/domain/inspection-form.ts
/**
 * Único punto de construcción del formulario de una inspección. Devuelve uno
 * NUEVO siempre: no hay ninguna forma soportada de mutar uno existente, y ésa
 * es la garantía que evita el incidente 10.
 */
export function buildAnswerForm(
  template: ChecklistTemplate,
  answers: readonly InspectionAnswer[],
): InspectionForm { … }
```

**Y la conexión con el versionado**, que es por lo que este incidente está en esa categoría: la misma función, llamada con la plantilla **vigente** en vez de con la que la inspección guardó, produce un formulario perfectamente válido con los ítems equivocados y **sin ninguna clave sobrante que lo delate**. La Fase 8 §5.3 lo avisa por escrito. Ese caso es indistinguible por las claves y sólo se ve en la URL de `/templates` — es el incidente 08 visto desde aquí.

**Prueba de regresión**

```ts
// src/app/core/domain/inspection-form.spec.ts
it('construye un formulario con exactamente los ítems de su plantilla', () => {
  const form = buildAnswerForm(elevatorV2, inspection500.answers);

  // Falla antes del fix cuando el formulario se reutilizaba entre inspecciones.
  expect(Object.keys(form.controls).sort())
    .toEqual(['cabin-lighting', 'door-sensor', 'emergency-brake', 'main-cable']);
});

it('no arrastra claves entre construcciones sucesivas', () => {
  const boiler = buildAnswerForm(boilerV1, inspection502.answers);
  const elevator = buildAnswerForm(elevatorV2, inspection500.answers);

  expect(Object.keys(elevator.controls)).not.toContain('pressure-valve');
  expect(Object.keys(boiler.controls)).not.toContain('main-cable');
});
```

**Prevención**

Los dos tests, y una comprobación en la propia pantalla que convierte el bug en visible:

```ts
// Al construir la vista, en desarrollo. Un formulario cuyas claves no coinciden
// con su plantilla es un bug, y callarlo es cómo se llega a este ticket.
const orphans = Object.keys(form.controls).filter(
  (key) => !template.items.some((item) => item.id === key),
);
if (orphans.length > 0 && !environment.production) {
  console.warn('[certcore] controles huérfanos en el formulario:', orphans);
}
```

**Por qué llegó a producción**

Durante meses, el listado de inspecciones no permitía saltar de una a otra sin pasar por otra pantalla: había que volver al panel, y eso destruía el componente y con él el formulario. **El bug existía desde el principio y no era alcanzable.** Se volvió alcanzable el día que se añadió el enlace directo entre inspecciones en el listado — un cambio de tres líneas, en otra pantalla, que ninguna revisión relacionó con el formulario.

Es el patrón que más se repite en este cuaderno: **el código que falla no es el que cambió.**

**Si tu causa fue distinta a esta**

Si concluiste que hay que llamar a `form.reset()` al cambiar de ruta, no basta: `reset()` limpia los **valores** y deja los controles. Si concluiste que hay que quitar los controles sobrantes a mano, funciona y es frágil — tienes que acertar cuáles quitar, y esa lista es justamente la que ya estaba mal. Y si tu diagnóstico fue "es el incidente 08 otra vez", vale la pena mirar la diferencia: aquí la URL de `/templates` **es correcta**; lo que está mal es lo que sobrevivió en el formulario.

</details>

---

## Incidente 11 — "Escribo una letra y la aplicación se queda pegada; el ventilador se dispara"

> **Fase:** 8 · **Categoría:** Formularios dinámicos · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-70 min · **Ruta forense:** [`forense-fase-08.md`](forense-fase-08.md)

### 🎫 El ticket

> *"Escribo una letra en la nota de un ítem y la aplicación se queda pegada. El ventilador del portátil se dispara y la tablet se calienta. Si cierro la pestaña y vuelvo a entrar, va bien hasta que escribo otra vez."*

**Reportado por:** inspector de campo
**Ambiente:** UAT

### 🎯 Qué se te pide

Dibujar el ciclo completo antes de tocar nada, y romperlo por el sitio correcto. Hay dos formas de romperlo y sólo una conserva lo que el usuario estaba escribiendo.

### 🔧 Preparación

```bash
git switch -c incidente/11 fase-08
npm run mock
npm start
# Abre la inspección 500 y escribe una letra en la nota de cualquier ítem
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Abre Network con el filtro en `Fetch/XHR`, escribe **una** letra, y después no toques nada durante treinta segundos. Lo que veas contesta si el ciclo pasa por la red o si es interno.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Pon un `console.count` en la suscripción de `valueChanges` y otro en el `next` del guardado. Si los dos crecen a la vez y sin parar, ya tienes el ciclo. Ahora escribe sus cuatro pasos en una servilleta.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El paso 3 del ciclo es *"para que quede sincronizado, parcheo el formulario con lo que devolvió el servidor"*. ¿Qué dispara `patchValue`? ¿Y por qué apagar esa emisión, aunque funciona, es la respuesta equivocada?

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

**Causa raíz**

Un ciclo de cuatro pasos que cierra perfectamente y **no produce ningún error**:

```
1. El inspector escribe una letra.        → valueChanges emite.
2. Pasa el debounce, sale el PATCH,
   el servidor responde con lo guardado.
3. "Para que quede sincronizado",
   el código parchea el formulario.       → patchValue()
4. patchValue dispara valueChanges.       → vuelve al 2. Para siempre.
```

```ts
// src/app/features/inspections/inspection-form/inspection-form.component.ts
concatMap((answers) => this.inspectionApi.saveAnswers(this.inspectionId, answers)),
takeUntilDestroyed(this.destroyRef),
).subscribe((saved) => {
  // ← El paso 3. Parece prudente y es el bucle.
  this.form.patchValue(toFormValue(saved.answers));
});
```

Lo que se ve es la aplicación arrastrándose, Network llenándose sola y el ventilador. Nada rojo en ninguna parte.

**Parche mínimo**

```ts
// El único cambio: después de guardar, el formulario NO SE TOCA.
// El servidor confirma; no dicta. El único patchValue de esta pantalla es el
// de la carga inicial, y ni siquiera hace falta: el formulario se construye
// ya con los valores dentro.
).subscribe(() => {
  this.lastSavedAt = nowInstant();
});
```

**La forma que parece obvia y no se entrega:**

```ts
// ❌ Funciona, rompe el bucle, y pisa lo que el inspector tenía escrito con lo
//    que el servidor devolvió. Si escribió algo durante el viaje de red, se
//    pierde — y ahora sin ningún síntoma. Cambias un bug ruidoso por uno mudo.
this.form.patchValue(toFormValue(saved.answers), { emitEvent: false });
```

> 🧭 **La regla: el servidor confirma, no dicta.** En una pantalla con autosave, el usuario es la fuente de verdad de lo que está escribiendo. Lo único que el servidor puede decir es "recibido" o "no pude"; en cuanto empieza a devolver contenido que se pinta, la escritura del usuario compite con la red y pierde a veces.

**Y una segunda causa del mismo bucle que hay que conocer**, porque no tiene ningún `patchValue` a la vista: `disable()` y `enable()` **también disparan `valueChanges`** salvo que les pases `{ emitEvent: false }`. Un ítem que se deshabilita según lo que el inspector responda en otro produce exactamente este ticket.

**La refactorización correcta**

Además de no tocar el formulario, el flujo necesita las dos piezas que impiden guardar de más:

```ts
this.form.valueChanges.pipe(
  debounceTime(1500),
  map(() => toAnswers(this.form)),
  // Sin comparador explícito, distinctUntilChanged compara con === y dos
  // objetos con el mismo contenido nunca son ===: no filtraría nada, y
  // parecería que sí. La serialización es O(n) sobre decenas de elementos y
  // corre como mucho una vez cada segundo y medio.
  distinctUntilChanged((a, b) => serializeAnswers(a) === serializeAnswers(b)),
  // concatMap y no switchMap: cancelar un PATCH que ya salió no cancela nada
  // en el servidor, sólo te deja sin saber si llegó. Para escrituras, cola.
  concatMap((answers) =>
    this.inspectionApi.saveAnswers(this.inspectionId, answers).pipe(
      // El catchError va DENTRO, protegiendo sólo la petición. En el pipe
      // externo mataría el valueChanges para siempre: un fallo y el autosave
      // no vuelve a funcionar hasta recargar. Ver el apéndice A06 §6.
      catchError(() => of(null)),
    ),
  ),
  takeUntilDestroyed(this.destroyRef),
).subscribe();
```

**Prueba de regresión**

```ts
// src/app/features/inspections/inspection-form/inspection-form.component.spec.ts
it('no vuelve a guardar como consecuencia de haber guardado', fakeAsync(() => {
  component.form.controls['main-cable'].patchValue({ note: 'a' });
  tick(1500);

  const first = httpMock.expectOne((r) => r.method === 'PATCH');
  first.flush({ id: 500, answers: [{ itemId: 'main-cable', answer: '', evidenceUrl: null, note: 'a' }] });
  tick(3000);

  // Falla antes del fix: la respuesta parcheaba el formulario, valueChanges
  // volvía a emitir, y aquí había un segundo PATCH esperando.
  httpMock.expectNone((r) => r.method === 'PATCH');
}));

it('no guarda dos veces el mismo contenido', fakeAsync(() => {
  component.form.controls['main-cable'].patchValue({ note: 'a' });
  tick(1500);
  httpMock.expectOne((r) => r.method === 'PATCH').flush({});

  component.form.controls['main-cable'].patchValue({ note: 'a' });   // idéntico
  tick(1500);

  httpMock.expectNone((r) => r.method === 'PATCH');
}));
```

**Prevención**

El primer test es la prevención de verdad, y su nombre lo dice: *no vuelve a guardar como consecuencia de haber guardado*. Es la formulación general del bucle y se puede copiar a cualquier pantalla con autosave.

Y una regla de revisión: **cualquier escritura al formulario dentro de una suscripción que nazca del propio formulario es un bucle hasta que se demuestre lo contrario.**

**Por qué llegó a producción**

El `patchValue` se añadió con la mejor intención y por una razón real: **el servidor normaliza**. Recorta espacios, y en algún momento se decidió que la pantalla debía reflejar lo normalizado. Con el mock local respondiendo en dos milisegundos, el debounce de 1500 ms absorbía la realimentación y el bucle **no se notaba**: parecía que sólo salía una petición.

En UAT, con latencia real y un inspector escribiendo seguido, las emisiones dejaron de solaparse y el ciclo se hizo visible. **El bug estuvo siempre; lo que cambió fue el tiempo de respuesta.** Es la razón por la que el inyector de caos de la Fase 3 existe: sin latencia, media docena de bugs de este curso no se pueden ver.

**Si tu causa fue distinta a esta**

Si concluiste que el `debounceTime` es muy corto, subirlo espacia el bucle y no lo rompe: con 5000 ms tendrías una petición cada cinco segundos, para siempre. Si concluiste que falta `distinctUntilChanged`, tienes razón en que falta —y con el comparador puesto **el bucle se detendría**, porque el contenido no cambia—; es un arreglo que funciona por accidente y deja el ciclo intacto para el día que el servidor sí devuelva algo distinto. Y si tu fix fue `{ emitEvent: false }`, lee otra vez el párrafo del parche: funciona y pierde escritura del usuario.

</details>

---
## Incidente 12 — "Aprobé la inspección y el sistema me dejó, pero el cable está para cambiar"

> **Fase:** 9 · **Categoría:** Tipos (strict) · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-70 min · **Ruta forense:** [`forense-fase-09.md`](forense-fase-09.md)

### 🎫 El ticket

> *"Aprobé la inspección del ascensor de la torre A y el sistema me dejó, pero el cable está para cambiar: lo puse como hallazgo crítico. ¿No era que un crítico bloqueaba la aprobación? En la pantalla de hallazgos sale bien, en rojo y todo."*

**Reportado por:** supervisor de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Explicar por qué la pantalla muestra el hallazgo correctamente y la regla no lo ve, y decidir **en cuál de tres sitios posibles** va el arreglo. Los tres funcionan hoy; sólo uno sigue funcionando en la Fase 10 y en la 11.

### 🔧 Preparación

El bug está en el dato: un `db.json` alterno.

```bash
cp mock/db.json mock/db.mio.json
cp mock/db.incidente-12.json mock/db.json
npm run mock
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

La pantalla ya aplicó tus valores por defecto. El cuerpo crudo de la respuesta, no. Mira el JSON de `/findings?inspectionId=…` en la pestaña Response, **por columnas y no por filas**.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Una de las filas no trae la clave `resolvedAt`. No es que valga `null`: es que **no existe**. Y el tipo `Finding` la declara como `string | null`. ¿Quién comprobó eso?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

```js
finding.resolvedAt === null;    // ?
finding.resolvedAt == null;     // ?
'resolvedAt' in finding;        // ?
```

Escribe las tres en la consola. La primera es la que hay en el código.

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

**Causa raíz**

El hallazgo llega **sin la clave `resolvedAt`**, así que su valor es `undefined`. La regla compara con `=== null`, y `undefined === null` es `false`:

```ts
// src/app/core/domain/inspection-findings.ts
const blocking = findings.filter(
  (finding) => finding.severity === 'critical' && finding.resolvedAt === null,
);
// El hallazgo crítico no entra en la lista. No bloquea. La aprobación sigue.
```

La pantalla lo muestra bien porque pinta `severity` y `description`, que sí llegan. **El campo que decide es el único que falta**, y nadie lo comprueba: entre el tipo que lo declara y el servidor que no lo manda no hay ninguna verificación.

```ts
export interface Finding {
  readonly resolvedAt: string | null;   // una promesa, no una comprobación
}
```

> ⚠️ **`strict: true` no te salva de esto, y conviene entender por qué.** El compilador comprueba lo que **declaraste**, y tú declaraste `string | null`. Nunca vio la respuesta. `this.http.get<Finding[]>(url)` **no valida nada**: el genérico es una promesa que tú le haces al compilador sobre datos que vienen de fuera. `strict` protege la frontera entre tus archivos; la frontera con la red la defiendes tú.

**Parche mínimo**

El de un viernes, en el sitio donde se manifestó:

```ts
const blocking = findings.filter(
  (finding) => finding.severity === 'critical' && (finding.resolvedAt ?? null) === null,
);
```

**La refactorización correcta**

El `?? null` puede ir en tres sitios y los tres arreglan esta pantalla:

| Dónde | Esta pantalla | La emisión (Fase 10) | El dashboard (Fase 11) |
|---|---|---|---|
| en el componente | ✅ | ❌ | ❌ |
| en la regla de dominio | ✅ | ✅ | ❌ si no la usa |
| **en el borde HTTP** | ✅ | ✅ | ✅ |

```ts
// src/app/core/api/finding-api.service.ts — el borde, donde el dato entra
getByInspection(inspectionId: number): Observable<readonly Finding[]> {
  return this.http.get<unknown>(`${this.baseUrl}/findings`, { params: { inspectionId } }).pipe(
    map((response) => {
      if (!Array.isArray(response)) {
        throw new ApiError('El servidor devolvió algo que no es una lista de hallazgos.');
      }
      // Normalizar una vez, aquí. A partir de este punto el dominio confía:
      // `resolvedAt` es `string | null` y nunca `undefined` ni ausente.
      return response.map((raw) => toFinding(raw));
    }),
  );
}
```

> 🧭 **La regla del proyecto: lo que entra por la red se normaliza una vez, en el borde, y a partir de ahí el dominio confía.** Un `?? null` repartido por cinco componentes es cinco sitios donde alguien puede olvidarse; uno en el `*ApiService` es un sitio donde alguien puede leerlo.

**Prueba de regresión**

```ts
// src/app/core/domain/inspection-findings.spec.ts
it('bloquea con un hallazgo crítico cuyo resolvedAt llega ausente', () => {
  // Así viene del servidor: SIN la clave. `as unknown as Finding` es
  // deliberado — reproduce lo que el genérico de HttpClient deja pasar.
  const finding = {
    id: 904, inspectionId: 503, itemId: 'main-cable',
    severity: 'critical', description: 'Desgaste severo',
  } as unknown as Finding;

  // Falla antes del fix: `undefined === null` es false y el array salía vacío.
  expect(blockingFindings([finding]).length).toBe(1);
});

it('no bloquea con un crítico ya resuelto', () => {
  const finding = { severity: 'critical', resolvedAt: '2024-01-10T09:00:00-05:00' } as Finding;
  expect(blockingFindings([finding]).length).toBe(0);
});
```

```ts
// src/app/core/api/finding-api.service.spec.ts — el test del borde
it('normaliza un resolvedAt ausente a null', () => {
  service.getByInspection(503).subscribe((findings) => {
    expect(findings[0].resolvedAt).toBeNull();
    expect('resolvedAt' in findings[0]).toBeTrue();
  });
  httpMock.expectOne((r) => r.url.endsWith('/findings')).flush([{ id: 904, severity: 'critical' }]);
});
```

**Prevención**

La normalización en el borde, y una regla que la sostiene: **ninguna respuesta HTTP entra al dominio sin pasar por una función `toX()` que la estreche.** Ya existe para las plantillas desde la Fase 3; lo que faltaba era aplicarla a los hallazgos.

**Por qué llegó a producción**

El campo `resolvedAt` se añadió al modelo cuando se implementó la resolución de hallazgos, y el mock lo sembró en todas las filas. La regla se escribió mirando esos datos, donde `null` siempre estaba. **Con el dato de la semilla, `=== null` es correcto.**

El fallo aparece cuando entra un hallazgo por otra vía —una carga masiva, una integración, un `POST` de un cliente que no manda el campo— y omite una clave opcional. Nada en el sistema lo rechaza, nada lo avisa, y la regla más importante del dominio deja de aplicarse en silencio.

Y hay un agravante de proceso que hay que decir: **no había ningún test que probara la regla con un dato incompleto.** Todos los tests usaban objetos construidos a mano, con todos los campos. Un test así no puede detectar esta familia jamás.

**Si tu causa fue distinta a esta**

Si concluiste que el backend está mal y que lo arreglen ellos, tienes razón **y no cambia tu trabajo**: un cliente que se cae porque el servidor omitió un campo opcional es un cliente frágil. Si tu fix fue `finding.resolvedAt!`, silenciarías la única señal disponible — y la guía prohíbe el aserto de no-nulo en este proyecto precisamente por esta familia. Si concluiste que hay que hacer el campo obligatorio en el tipo (`resolvedAt: string`), el compilador te dejaría y el dato seguiría llegando ausente: **cambiar el tipo no cambia la respuesta HTTP.**

</details>

---

## Incidente 13 — "El supervisor subió la severidad de un hallazgo y al día siguiente había vuelto a bajar"

> **Fase:** 9 · **Categoría:** Tipos (strict) · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-70 min · **Ruta forense:** [`forense-fase-09.md`](forense-fase-09.md)

### 🎫 El ticket

> *"El supervisor subió la severidad del hallazgo de la iluminación de menor a mayor el jueves, porque el cliente tiene un requisito adicional. El viernes había vuelto a bajar sola. Nadie la tocó, y no aparece en ningún registro quién la cambió."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Determinar si el cambio se guardó o no —son dos investigaciones distintas— y arreglarlo. El post-mortem tiene que decir además qué parte de este ticket **no** se puede arreglar con este fix.

### 🔧 Preparación

```bash
git switch -c incidente/13 fase-09
npm run mock
npm start
# Sube la severidad del hallazgo 901 (cabin-lighting, inspección 503) y recarga
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de acusar a nadie de no haber guardado: compara lo que el servidor tiene con lo que la pantalla muestra. Son dos comandos y descartan media investigación — y hacerlo **antes** de preguntarle a una persona es la diferencia entre un post-mortem y una conversación incómoda.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -s "http://localhost:3000/findings/901" -H "Authorization: Bearer <token>"
```
…y en la consola, `ng.getComponent($0).finding.severity`. Si no coinciden, el dato se guardó y algo lo está recalculando encima.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`cabin-lighting` tiene `nonComplianceSeverity: 'minor'` en la v2 de `elevator-annual`. ¿De dónde saca la pantalla la severidad que pinta: del hallazgo o del ítem de la plantilla? ¿Y qué pasa cuando el sistema tiene dos fuentes de verdad para el mismo campo?

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

**Causa raíz**

```bash
# Lo que el servidor guarda:
curl -s http://localhost:3000/findings/901 | grep severity
# "severity": "major"      ← el PATCH del jueves funcionó
```

```js
// Lo que la pantalla muestra:
ng.getComponent($0).finding.severity;   // 'minor'
```

El dato se guardó. Lo que ocurre es que la severidad **se deriva** del ítem de la plantilla cada vez que se lee, y la derivación pisa lo guardado:

```ts
// src/app/core/domain/finding-severity.ts
export function severityOf(item: ChecklistItem, answer: string): Severity {
  return isNonCompliant(item, answer) ? item.nonComplianceSeverity : 'minor';
}
```

`cabin-lighting` declara `nonComplianceSeverity: 'minor'` en la v2, así que la regla devuelve `minor` cada vez que alguien recarga. **El sistema tiene dos fuentes de verdad para el mismo campo y la derivada gana siempre, en silencio.** No hay error, no hay conflicto, no hay aviso.

**Y aquí está la parte de tipos**, que es por lo que este incidente vive en esa categoría: la forma natural de arreglarlo es una anulación explícita, y la forma natural de escribirla es la equivocada.

```ts
// ❌ Opcional: "no me molesté en decidirlo".
severityOverride?: Severity;
// Un hallazgo sin anulación trae la clave ausente; otro trae `undefined` porque
// alguien la puso y la quitó; otro trae `null`. Tres formas de decir lo mismo,
// y la comprobación que las distinga se escribe mal la primera vez — que es
// exactamente el incidente 12.
```

**Parche mínimo**

No hay parche honesto de una línea: el modelo necesita un campo que no existe. Lo mínimo defendible es **dejar de derivar en la lectura** mientras se decide, y eso hay que decirlo en el ticket, porque es un cambio de comportamiento:

```ts
// Hotfix declarado: la pantalla muestra lo guardado. Deja de reflejar cambios
// de la plantilla en hallazgos ya creados, que es un efecto secundario real y
// hay que avisarlo antes de desplegar.
readonly severity = finding.severity;
```

**La refactorización correcta**

```ts
// src/app/core/models/finding.model.ts
export interface Finding {
  readonly severity: Severity;
  /**
   * Anulación manual de la severidad derivada.
   *
   * `null` significa "sin anulación" y es un valor DECIDIDO, no un hueco. La
   * forma opcional (`severityOverride?: Severity`) admitiría tres estados donde
   * el negocio sólo tiene dos, y produce el incidente 12 en otro campo.
   */
  readonly severityOverride: Severity | null;
  readonly overriddenBy: string | null;
  readonly overriddenAt: string | null;
}
```

```ts
// src/app/core/domain/finding-severity.ts
/** La anulación gana, y sólo si existe de verdad. */
export function effectiveSeverity(
  finding: Finding,
  item: ChecklistItem,
  answer: string,
): Severity {
  return finding.severityOverride ?? severityOf(item, answer);
}
```

> 🧭 **La regla del proyecto (guía §6.4): los modelos del dominio distinguen ausencia de vacío.** `severityOverride: Severity | null` dice "aquí no hay anulación"; `severityOverride?: Severity` diría "no me molesté en decidirlo". Es la misma decisión que el incidente 12, tomada al escribir el modelo en vez de al depurar el ticket.

**Prueba de regresión**

```ts
// src/app/core/domain/finding-severity.spec.ts
it('la anulación manual gana sobre la derivada', () => {
  const finding = { severity: 'minor', severityOverride: 'major' } as Finding;

  // Falla antes del fix: la derivación pisaba lo guardado y devolvía 'minor'.
  expect(effectiveSeverity(finding, cabinLightingItem, 'partial')).toBe('major');
});

it('sin anulación, deriva de la plantilla', () => {
  const finding = { severity: 'minor', severityOverride: null } as Finding;
  expect(effectiveSeverity(finding, cabinLightingItem, 'partial')).toBe('minor');
});

it('una anulación ausente se comporta igual que null', () => {
  // El caso del incidente 12, aquí: el dato llega sin la clave.
  const finding = { severity: 'minor' } as unknown as Finding;
  expect(effectiveSeverity(finding, cabinLightingItem, 'partial')).toBe('minor');
});
```

**Prevención**

Los tres tests, la normalización en el borde HTTP del incidente 12 aplicada también a este campo, y una regla de revisión general: **cuando un campo se puede calcular y también se puede escribir, hace falta un tercer campo que diga cuál manda.** Sin él, el conflicto se resuelve por accidente, y se resuelve siempre a favor del cálculo.

**Por qué llegó a producción**

La derivación de severidad se diseñó bien y para un caso real: **cuando la norma cambia, los hallazgos tienen que reflejar la severidad nueva sin que nadie los toque uno a uno.** Ese requisito es correcto y sigue vigente.

Lo que nadie previó es que un supervisor necesitara **subir** la severidad de un caso concreto por un requisito del cliente. No es un caso raro: es un caso que no estaba en la conversación inicial. El sistema se diseñó para un mundo donde la plantilla siempre tiene razón, y funcionó hasta que apareció alguien con más información que la plantilla.

**Y hay una mitad de este ticket que el fix no arregla**, y el post-mortem tiene que decirlo: *"no aparece en ningún registro quién la cambió"*. Los campos `overriddenBy` y `overriddenAt` de la refactorización guardan quién y cuándo, y aun así **no hay historial**: sólo la última anulación. En un sistema cuyo dominio **es** la trazabilidad, esa ironía es el límite del patrón de estado que el **Apéndice A07** §8 nombra por escrito, y saldarlo de verdad exige una decisión de arquitectura que no cabe en un incidente.

**Si tu causa fue distinta a esta**

Si tu primera hipótesis fue "el supervisor no guardó bien", es la más natural y es la que hay que descartar **primero y con un `curl`**, no preguntando. Si concluiste que hay que quitar la derivación y guardar siempre la severidad, es tentador y peor: el día que la norma cambie el `nonComplianceSeverity` de un ítem, los hallazgos viejos seguirán diciendo lo de antes y nadie sabrá si eso es correcto o es un dato viejo. **La derivación es la decisión correcta; lo que faltaba era la anulación explícita**, que es otra cosa.

</details>

---

## Incidente 14 — "Descargué el certificado y la tabla de hallazgos no dice lo mismo que la pantalla"

> **Fase:** 10 · **Categoría:** Trazabilidad · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min · **Ruta forense:** [`forense-fase-10.md`](forense-fase-10.md)

### 🎫 El ticket

> *"Descargué el certificado de la 502 para mandárselo al cliente y la tabla de hallazgos dice que hay uno mayor sin resolver. Lo resolvimos ayer. La pantalla del sistema tampoco lo decía cuando lo descargué, pero yo llevaba la pestaña abierta desde la mañana."*

**Reportado por:** supervisor de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Localizar de dónde salieron los datos del PDF, arreglarlo, y explicar en el post-mortem por qué este bug es **cualitativamente distinto** de una pantalla desactualizada.

### 🔧 Preparación

```bash
git switch -c incidente/14 fase-10
npm run mock
npm start
```

Reproducción, con dos pestañas y sin ninguna herramienta:

```
1. Abre el detalle de un certificado. NO cierres la pestaña.
2. En otra pestaña, marca como resuelto uno de sus hallazgos.
3. Vuelve a la primera y descarga el PDF.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Compara tres cosas, no dos: lo que dice la pantalla, lo que dice el PDF, y lo que dice el servidor. Con esas tres, el bug queda localizado sin abrir un archivo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El PDF coincide con **la pantalla** y no con el **servidor**. Eso no deja ambigüedad: el documento no pidió los datos, los recibió de alguien que ya los tenía.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Mira la **firma** de la función que genera el PDF, no su cuerpo. ¿Qué recibe? ¿De dónde salieron esos parámetros?

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

**Causa raíz**

```
Pantalla (abierta desde la mañana):  door-sensor · Mayor · Pendiente
PDF descargado:                      door-sensor · Mayor · Pendiente
Servidor (curl):                     door-sensor · Mayor · RESUELTO
```

El PDF se arma **desde lo que el componente ya tenía pintado**:

```ts
// src/app/features/certificates/certificate-pdf.service.ts
async download(view: CertificateView, findings: readonly InspectionFinding[]): Promise<void> {
  // `view` y `findings` son los objetos que la pantalla cargó cuando se abrió.
  // Todo está aquí, no hace falta pedir nada, y el PDF sale en 50 ms.
}
```

**El bug está en la firma, no en el cuerpo.** Cualquier implementación que reciba lo que el componente ya tenía produce este ticket, por bien escrita que esté.

Y no falló nada: el PDF salió perfecto, con acentos, con la tabla alineada. No hay error en consola, no hay nada rojo en Network, y el documento ya está camino de un correo.

**Parche mínimo**

Aquí **no hay parche mínimo defendible**, y decirlo es parte del entregable. Un `reload()` antes de generar no basta: la pantalla se recargaría, el PDF seguiría armándose desde ella, y la ventana entre la recarga y la generación sigue existiendo. El arreglo es el de abajo.

**La refactorización correcta**

Dos decisiones, y la primera es la mitad del arreglo:

```ts
// src/app/core/pdf/certificate-document.ts
/**
 * Todo lo que el documento necesita, junto y ya resuelto. Que sea una interfaz
 * explícita y no "lo que tenga el componente" es la mitad del arreglo: aquí se
 * ve de un vistazo que hacen falta seis cosas, y las seis tienen que venir de
 * la fuente.
 */
export interface CertificateDocumentSource {
  readonly certificate: Certificate;
  readonly view: CertificateView;
  readonly inspection: Inspection;
  readonly template: ChecklistTemplate;   // la versión CONGELADA de la inspección
  readonly asset: Asset;
  readonly client: Client;
  readonly findings: readonly InspectionFinding[];
}
```

```ts
// Y el servicio pide las seis, otra vez, en el momento de generar.
download(certificateId: string): Observable<void> {
  return this.certificateApi.getById(certificateId).pipe(
    concatMap((certificate) => this.inspectionApi.getById(certificate.inspectionId).pipe(
      concatMap((inspection) => combineLatest({
        certificate: of(certificate),
        inspection: of(inspection),
        // La versión que la inspección GUARDÓ, no la vigente.
        template: this.templateApi.getByVersion(inspection.templateId, inspection.templateVersion),
        asset: this.assetApi.getById(inspection.assetId),
        findings: this.findingApi.getByInspection(inspection.id),
      })),
    )),
    concatMap((source) => from(this.render(source))),
  );
}
```

**Seis peticiones para un PDF, y está bien**: es una acción explícita del usuario, no un render. El día que sean sesenta, la respuesta es un endpoint que devuelva el certificado completo, no una caché en el cliente.

> 🧭 **La regla del proyecto: lo que hay en la pantalla es una foto de hace un rato. Está bien para mirar y está mal para imprimir.** Cualquier artefacto que sobreviva a la sesión —un PDF, un correo, un export— se arma pidiendo el dato otra vez.

**Prueba de regresión**

```ts
// src/app/features/certificates/certificate-pdf.service.spec.ts
it('pide los datos otra vez en vez de usar los de la pantalla', () => {
  service.download('CERT-2024-000502').subscribe();

  // Falla antes del fix: no salía NINGUNA petición, porque los datos llegaban
  // por parámetro. El test comprueba la firma tanto como el comportamiento.
  httpMock.expectOne((r) => r.url.includes('/certificates/CERT-2024-000502'));
  httpMock.expectOne((r) => r.url.includes('/inspections/502'));
  httpMock.expectOne((r) => r.url.includes('/findings'));
  httpMock.expectOne((r) => r.url.includes('/templates') && r.url.includes('version=1'));
});
```

**Prevención**

La firma es la prevención: **una función que no acepta datos ya cargados no puede usarlos.** Y una regla de revisión con nombre: *ningún generador de artefactos exportables recibe objetos de vista como parámetro.*

Además, y esto no previene el bug pero limita su daño: **el pie del PDF lleva la fecha y hora de generación, con zona horaria explícita.** Convierte "este PDF miente" en "este PDF es de antes de la resolución", que es una conversación completamente distinta.

**Por qué llegó a producción**

La primera versión se escribió con toda la información a mano y sin una sola petición: era rápida, simple y funcionaba en todas las pruebas — porque en una prueba nadie deja una pestaña abierta veinte minutos mientras otra persona cambia el dato desde otro equipo.

**El sistema no tiene ningún mecanismo para detectar esto.** No hay error, no hay warning, no hay test que falle. La única forma de encontrarlo es reproducir el escenario de dos pestañas, y ese escenario no se le ocurre a nadie hasta que un cliente recibe un documento equivocado.

Lo que hace peligrosa a esta deuda no es que el dato esté viejo: es que **el PDF es el único artefacto del sistema que sobrevive al sistema.** Una pantalla desactualizada se arregla con F5. Un PDF desactualizado se archiva, se imprime y se adjunta a la respuesta de un requerimiento normativo, y dentro de dos años nadie va a poder decir de qué momento son sus datos. El **Apéndice A08** §7 y §9 lo desarrolla, incluida la parte incómoda: **un PDF ya descargado no se puede revocar.**

**Si tu causa fue distinta a esta**

Si concluiste que el PDF está cacheado, se descarta en un segundo: cada descarga genera el archivo desde cero en el navegador. Si el contenido es viejo, es porque los **datos** lo eran. Si concluiste que la pantalla debería refrescarse sola —con un `interval` o con websockets—, es una mejora legítima de otra conversación y **no arregla esto**: la ventana entre el último refresco y la pulsación del botón sigue existiendo, sólo que más corta. Y una ventana más corta para un bug que produce documentos falsos no es una solución.

</details>

---
## Incidente 15 — "El certificado venció ayer para el sistema y hoy para el cliente, y sólo pasa por la tarde"

> **Fase:** 10 · **Categoría:** Tiempo · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1h30-2h · **Ruta forense:** [`forense-fase-10.md`](forense-fase-10.md)

### 🎫 El ticket

> *"A veces el sistema dice que un certificado está vencido y el cliente nos manda una foto del papel donde dice que vence hoy. Pasa sobre todo por la tarde. Por la mañana no me ha pasado nunca."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar por qué **"sobre todo por la tarde"** no es ruido sino el dato más preciso del reporte, localizar la decisión que nadie tomó, y arreglarla de forma que no dependa de dónde esté parado quien pregunta.

### 🔧 Preparación

```bash
git switch -c incidente/15 fase-10
npm run mock
npm start
```

Y el experimento que reproduce el ticket en tu máquina, que **es parte de la preparación**: cambia la zona horaria de tu sistema operativo a **Auckland (UTC+13)** y recarga. Devuélvela al terminar — hay tests de la Fase 12 que dependen del reloj.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de leer código: mira los **últimos seis caracteres** del campo `validUntil` en el cuerpo crudo de la respuesta. Deciden en qué mitad del sistema está el bug, y se leen en diez segundos.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```js
const validUntil = '2025-02-10T23:59:59-05:00';
new Date(validUntil).toISOString();   // ?
new Date(validUntil).toString();      // ?
```
Las dos son correctas y dicen días distintos. Ahora busca cuál de las dos usa el código para decidir si algo venció.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En Bogotá, `-05:00`, las 19:00 locales son las 00:00 UTC **del día siguiente**. ¿A partir de qué hora del día empiezan a discrepar una comparación hecha en UTC y una hecha en hora local?

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

**Causa raíz**

El dato está bien: `"validUntil": "2025-02-10T23:59:59-05:00"`, con offset explícito, como toda fecha del proyecto desde la Fase 3. **El bug está en quien lo lee.**

```ts
// src/app/core/domain/certificate-status.ts
const expired = certificate.validUntil.slice(0, 10) < new Date().toISOString().slice(0, 10);
```

Esa línea compara **dos días calculados en husos distintos**:

```js
'2025-02-10T23:59:59-05:00'.slice(0, 10);        // '2025-02-10'  ← día LOCAL del dato
new Date().toISOString().slice(0, 10);            // el día en UTC
```

En Bogotá (`-05:00`), a partir de las **19:00** locales, el día en UTC ya es el siguiente. Desde esa hora, un certificado que vence hoy se compara contra el día de mañana y el sistema lo declara vencido. Antes de las 19:00 el bug no existe.

**Ése es el "sobre todo por la tarde" del ticket**, y era el dato más preciso que traía.

Y las tres conversiones, para ver que las tres son correctas y dicen cosas distintas:

```js
new Date('2025-02-10T23:59:59-05:00').toISOString();   // '2025-02-11T04:59:59.000Z' — MISMO instante
new Date('2025-02-10T23:59:59-05:00').toString();      // el mismo instante, en TU huso
toBusinessDay('2025-02-10T23:59:59-05:00');            // '2025-02-10' — el día del NEGOCIO
```

> 🧠 **Nunca es un bug de fechas.** `Date` hizo exactamente lo que le pidieron, tres veces, con tres resultados correctos. Es un bug de **no haber decidido a qué hora vence algo**, y por eso el arreglo no es un `+1` ni un `-5`.

**Parche mínimo**

No lo hay que sea honesto, y hay que decirlo: los tres arreglos de una línea que aparecen en cualquier revisión **mueven el síntoma a otra hora o a otro huso**.

```ts
// ❌ Los tres, y por qué:
new Date(cert.validUntil) < new Date();                    // compara instantes, no días:
                                                           // vence a las 23:59:59, no al final del día
new Date(cert.validUntil).getTime() + 86400000 < Date.now();  // el bug desaparece por la tarde en
                                                           // Bogotá y aparece por la mañana en Auckland
cert.validUntil.slice(0,10) < todayLocalString();          // depende del huso del navegador: dos
                                                           // usuarios ven cosas distintas
```

**La refactorización correcta**

Una decisión, con nombre, en un archivo, llamada desde todas partes:

```ts
// src/app/core/domain/business-day.ts
/**
 * La zona horaria de las decisiones de negocio de CertCore.
 *
 * No es la del navegador ni la del servidor: es la del país donde la empresa
 * opera y donde la norma aplica. Un certificado vence al final del día ahí,
 * y eso no cambia porque el inspector esté de viaje.
 */
export const BUSINESS_TIME_ZONE = 'America/Bogota';

/** El día de calendario del negocio para un instante ISO. */
export function toBusinessDay(instant: string): string {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: BUSINESS_TIME_ZONE,
    year: 'numeric', month: '2-digit', day: '2-digit',
  }).format(new Date(instant));   // 'en-CA' produce YYYY-MM-DD, que ordena como cadena
}

/** Hoy, según el negocio. */
export function todayInBusinessZone(): string {
  return toBusinessDay(new Date().toISOString());
}
```

```ts
// Y la comparación, que ahora dice lo que significa:
const expired = toBusinessDay(certificate.validUntil) < todayInBusinessZone();
```

> 🧭 **La regla del proyecto: la zona horaria de una decisión de negocio es un dato del negocio, no del entorno.** Cuando esa decisión tiene nombre y vive en un archivo, deja de tomarse por accidente en catorce sitios distintos.

**Prueba de regresión**

```ts
// src/app/core/domain/certificate-status.spec.ts
it('no depende del huso del navegador', () => {
  const certificate = { validUntil: '2025-02-10T23:59:59-05:00' } as Certificate;

  // Las 20:00 de Bogotá del día en que vence: en UTC ya es el día 11.
  // Antes del fix, este caso devolvía 'expired'.
  const bogotaEvening = '2025-02-11T01:00:00.000Z';

  expect(buildCertificateView(certificate, bogotaEvening).status).toBe('valid');
});

it('vence al terminar el día del negocio, no antes', () => {
  const certificate = { validUntil: '2025-02-10T23:59:59-05:00' } as Certificate;

  expect(buildCertificateView(certificate, '2025-02-10T04:00:00.000Z').status).toBe('valid');
  expect(buildCertificateView(certificate, '2025-02-11T06:00:00.000Z').status).toBe('expired');
});
```

> 💡 **Fíjate en que el instante entra por parámetro y no se lee de `new Date()` dentro.** Ésa es la diferencia entre un test determinista y uno que falla una vez al año a las 19:00 — que es el incidente 17.

**Prevención**

Los tests de arriba, y una regla de lint que se puede automatizar: **`new Date()` y `Date.now()` no se llaman dentro de funciones de dominio.** El instante entra siempre por parámetro. Con eso, todo el dominio de tiempo del proyecto se vuelve determinista y probable.

```bash
# La comprobación, mientras la regla de lint no exista:
grep -rn "new Date()\|Date.now()" src/app/core/domain/ && echo "❌ el dominio no pregunta la hora"
```

**Por qué llegó a producción**

Durante todo el desarrollo, la máquina de todo el equipo estuvo en `America/Bogota`. Con ese huso, `toISOString().slice(0,10)` y el día local **coinciden diecinueve horas de cada veinticuatro**, y las cinco que no coinciden son de 19:00 a medianoche — fuera del horario en que nadie estaba probando.

En PROD el patrón se invirtió: los coordinadores cierran certificaciones **a última hora de la tarde**, que es exactamente la ventana rota. El bug no llegó a producción por descuido: llegó porque **el entorno de desarrollo hacía imposible verlo**, y nadie tenía la costumbre de cambiar el reloj del sistema para probar.

Es la razón por la que este curso insiste en fechas con offset explícito desde el `db.json`: el dato correcto es lo único que permitió que el arreglo fuera una lectura y no una migración de datos históricos.

**Si tu causa fue distinta a esta**

Si concluiste "hay que guardar todo en UTC", es la respuesta estándar y resuelve el problema equivocado: UTC te da un **instante** sin ambigüedad, y eso ya lo tienes con el offset. Lo que UTC no te da es el **día de calendario del negocio**, que es lo que decide si un certificado está vencido.

Si concluiste que es un bug de `Date` y hay que meter una librería de fechas, una librería te habría dado mejores herramientas para escribir la misma decisión — y la decisión seguiría sin estar tomada. Si tu fix fue sumar un día, mueve el error de sitio: desaparece por la tarde en Bogotá y aparece por la mañana en Auckland.

Y si concluiste que el `status: "valid"` guardado en el `db.json` es el culpable, has encontrado **otro bug real** que no es éste: un estado que se calcula pero se almacena empieza a mentir al día siguiente. La Fase 10 lo convierte en derivado, y merece su propio apunte en los pendientes.

</details>

---

## Incidente 16 — "Cerré el panel hace media hora y el servidor sigue recibiendo peticiones mías"

> **Fase:** 11 · **Categoría:** Performance · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min · **Ruta forense:** [`forense-fase-11.md`](forense-fase-11.md) y [`forense-fase-04.md`](forense-fase-04.md)

### 🎫 El ticket

> *"El de infraestructura me preguntó por qué mi usuario está haciendo peticiones cada minuto si yo cerré el panel a las once. Y sí: tengo la aplicación abierta, pero en otra pantalla. Además el navegador se va poniendo lento durante la mañana."*

**Reportado por:** coordinador de certificaciones
**Ambiente:** UAT

### 🎯 Qué se te pide

Confirmar cuántas suscripciones vivas hay —el número, no sólo el hecho—, localizar cuál es, y cerrarla en el estilo que corresponda al archivo.

### 🔧 Preparación

```bash
git switch -c incidente/16 fase-11
npm run mock
npm start
# Entra al panel, sal al listado de clientes, y repite cinco veces
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Network con el filtro en `Fetch/XHR`, **fuera** del panel, y dos minutos de paciencia sin tocar nada. No hace falta abrir el código para saber si hay una fuga y **cuántas**.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El ritmo te dice el número: si el refresco era de un minuto y ves cinco pares de peticiones por minuto, hay cinco pantallas zombis. Ahora la pregunta es qué suscripción sobrevive al componente — y no todas pueden.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un observable de `HttpClient` completa solo y no se puede fugar. ¿Cuál de los observables del panel **no completa nunca**?

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

**Causa raíz**

```
# Network, fuera del panel, dos minutos:
certificates   200   xhr   14 ms
inspections    200   xhr   22 ms
certificates   200   xhr   11 ms
inspections    200   xhr   19 ms
…cinco pares por minuto tras cinco visitas al panel
```

`DashboardComponent` se suscribe a un `interval` para refrescar las métricas y **no lo corta al destruirse**:

```ts
// src/app/features/dashboard/dashboard.component.ts
ngOnInit(): void {
  // `interval` NO completa nunca. Este componente sí se destruye. La
  // suscripción sobrevive a su dueño, y eso es la definición de una fuga.
  interval(60_000)
    .pipe(switchMap(() => this.dashboardState.reload()))
    .subscribe();
}
```

Cada visita al panel deja un `interval` corriendo. Cinco visitas, cinco refrescos por minuto, para siempre — y con ellos, cinco componentes que el recolector de basura no puede liberar. Eso explica las dos mitades del ticket: **el tráfico** y **el navegador que se pone lento durante la mañana**.

> 🧠 **No toda suscripción sin cerrar es una fuga.** Una fuga es una suscripción que **sobrevive a quien la creó**. El `subscribe` a `HttpClient` de dos líneas más arriba no lo es: completa al llegar la respuesta. El del `interval` sí, porque `interval` no completa nunca.

**Parche mínimo**

El archivo es **nuevo** (standalone, `inject()`), así que el parche va en estilo nuevo:

```ts
// src/app/features/dashboard/dashboard.component.ts
private readonly destroyRef = inject(DestroyRef);

ngOnInit(): void {
  interval(60_000)
    .pipe(
      switchMap(() => this.dashboardState.reload()),
      // Corta cuando Angular destruye el componente. Sin argumento sólo se
      // puede llamar en el contexto de inyección; aquí estamos en ngOnInit,
      // así que el DestroyRef va explícito. Ver el apéndice A04 §7.
      takeUntilDestroyed(this.destroyRef),
    )
    .subscribe();
}
```

**La refactorización correcta**

El refresco periódico no es del componente: es del estado. Y así, además, deja de reiniciarse cada vez que alguien entra al panel:

```ts
// src/app/core/state/dashboard-state.service.ts
/**
 * El refresco vive aquí, no en la pantalla. `providedIn: 'root'` significa que
 * hay uno solo, y `refCount: true` que sólo corre mientras alguien mire — con
 * `refCount: false` seguiría pidiendo con el panel cerrado, que es este mismo
 * incidente escrito de otra manera. Ver el apéndice A06 §7.
 */
readonly metrics$ = interval(60_000).pipe(
  startWith(0),
  switchMap(() => this.load()),
  shareReplay({ bufferSize: 1, refCount: true }),
);
```

Y el componente se queda con un `async` pipe y **ninguna suscripción manual**, que es el sitio donde este bug ya no puede existir.

**Prueba de regresión**

```ts
// src/app/features/dashboard/dashboard.component.spec.ts
it('deja de refrescar cuando se destruye', fakeAsync(() => {
  fixture.detectChanges();
  httpMock.expectOne((r) => r.url.includes('/certificates')).flush([]);

  tick(60_000);
  httpMock.expectOne((r) => r.url.includes('/certificates')).flush([]);   // el refresco periódico

  fixture.destroy();
  tick(180_000);

  // Falla antes del fix: el interval seguía vivo y aquí había tres peticiones
  // más esperando. `verify()` en el afterEach las habría delatado igual.
  httpMock.expectNone((r) => r.url.includes('/certificates'));
  discardPeriodicTasks();
}));
```

**Prevención**

El test de arriba, replicado en cualquier pantalla con refresco periódico, y una regla de revisión que se puede automatizar a medias:

```bash
# Todo subscribe manual sobre una fuente que no completa necesita corte.
grep -rn "interval(\|timer(.*,\|fromEvent(" src/app --include="*.ts" | grep -v spec
```

Y la regla de oro del curso, que es la prevención de fondo: **`async` pipe para pintar, `.subscribe()` para efectos — y entonces alguien se desuscribe.** El panel refactorizado no tiene ninguna suscripción manual, y por eso no puede fugarse.

**Por qué llegó a producción**

El refresco automático se añadió tarde, en la última semana antes de una demostración, y se probó de la única manera en que este bug es invisible: **abriendo el panel y mirándolo**. Nadie salió y volvió cinco veces.

El sistema tampoco ayuda: una fuga de suscripción **no produce ningún síntoma inmediato**. La primera visita funciona perfecto, la segunda también, y el coste se acumula tan despacio que cuando alguien lo nota ya no lo relaciona con nada que se haya desplegado. Aquí lo detectó **infraestructura**, mirando tráfico — no el equipo de desarrollo, y no un test.

**Si tu causa fue distinta a esta**

Si concluiste que hay que poner `OnPush` en el panel, es el sospechoso 4 puesto en primer lugar: `OnPush` decide cuándo se **revisa** un componente, y una fuga es un componente que **ya no existe** y sigue trabajando. No se tocan. Si concluiste que el `switchMap` cancela y por tanto no hay problema, cancela la petición **anterior de la misma suscripción**, no la suscripción: hay cinco `interval` independientes, cada uno con su `switchMap` funcionando perfectamente. Y si tu fix fue subir el intervalo a cinco minutos, espacia el tráfico y deja las cinco suscripciones vivas: el navegador se sigue poniendo lento.

</details>

---
## Incidente 17 — "El test pasa en mi máquina y falla en el pipeline, y nadie tocó nada"

> **Fase:** 12 · **Categoría:** Testing · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1h30-2h · **Ruta forense:** [`forense-fase-12.md`](forense-fase-12.md)

### 🎫 El ticket

> *"El pipeline lleva tres días fallando de forma intermitente y nadie ha tocado esos tests. A veces pasa si relanzo el job. En mi máquina siempre pasa. Ya hay gente relanzando sin mirar."*

**Reportado por:** tu líder técnico
**Ambiente:** integración continua

### 🎯 Qué se te pide

Hacerlo determinista **antes** de investigar, localizar la pareja de tests que se contamina, y arreglarla. Y el entregable incluye una frase para el equipo sobre por qué relanzar no es una opción.

### 🔧 Preparación

```bash
git switch -c incidente/17 fase-12
ng test --watch=false --browsers=ChromeHeadless
# Repítelo. Anota la semilla que Jasmine imprime al principio de cada ejecución.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Un fallo que ocurre una de cada diez veces no se investiga: **se hace ocurrir siempre**. Lo primero que Jasmine imprime es lo primero que casi nadie lee, y es exactamente lo que te permite reproducirlo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Con la semilla fija, el fallo es reproducible. Ahora bisecciona: marca la mitad de los `describe` con `xdescribe`, corre con la misma semilla, y quédate con la mitad que sigue fallando. Siete iteraciones bastan para toda la suite.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Lo que queda es una pareja de tests que no deberían conocerse. ¿Qué comparten? Piensa en qué **no** limpia el `TestBed` entre `it` de `describe` distintos: lo que vive fuera de Angular.

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

**Causa raíz**

```
Randomized with seed 47291
Chrome Headless 120.0.0: Executed 128 of 128 SUCCESS (2.104 secs)

Randomized with seed 83104
Chrome Headless 120.0.0: Executed 128 of 128 (1 FAILED) (2.233 secs)

  AuthGuard
    ✗ redirige al login cuando no hay sesión
      Expected UrlTree to be true.
```

Falla **según la semilla**, así que es el orden. Y con la semilla fija (`ng test --seed=83104`) más la bisección, la pareja aparece:

```ts
// auth.service.spec.ts — deja un token puesto y no lo limpia
it('guarda el token al iniciar sesión', () => {
  service.login({ email: 'inspector@certcore.co', password: 'certcore123' }).subscribe();
  httpMock.expectOne('/auth/login').flush({ accessToken: VALID_TOKEN });

  expect(localStorage.getItem('certcore.accessToken')).toBe(VALID_TOKEN);
  // …y aquí termina. El token sigue en localStorage.
});
```

```ts
// auth.guard.spec.ts — asume que no hay sesión
it('redirige al login cuando no hay sesión', () => {
  // No hay ningún setup que garantice que NO hay sesión: se da por hecho.
  expect(authGuard(route, state)).toBeInstanceOf(UrlTree);
});
```

**`localStorage` no lo limpia nadie.** `TestBed.resetTestingModule()` reconstruye el inyector entre tests y no toca el almacenamiento del navegador, que vive fuera de Angular. Si el spec del servicio corre **antes** que el del guard, el guard encuentra una sesión válida, devuelve `true`, y el test falla.

Con la semilla `47291` el orden es el contrario y todo pasa. **En tu máquina siempre pasa** porque Karma en modo `--watch` reutiliza la misma semilla mientras no reinicies.

> 🧭 **Un test que sólo pasa si otro corrió antes no es un test: es media prueba.** Y su fallo aparece el día que alguien añada un `it` en otro archivo, que es cuando nadie lo va a relacionar con nada.

**Parche mínimo**

```ts
// src/app/core/auth.service.spec.ts
afterEach(() => {
  // localStorage vive fuera de Angular: el TestBed no lo limpia.
  localStorage.clear();
});
```

**La refactorización correcta**

Un `afterEach` en el spec culpable arregla **esta** pareja y deja el mecanismo intacto para el siguiente que escriba en `localStorage`. La limpieza va donde no se pueda olvidar:

```ts
// src/test.ts — se ejecuta una vez, y aplica a toda la suite.
afterEach(() => {
  // Todo lo que vive fuera de Angular y sobrevive al TestBed.
  localStorage.clear();
  sessionStorage.clear();
});
```

Y la mitad que de verdad previene: **cada test declara el estado del que parte en vez de asumirlo.**

```ts
// src/app/core/guards/auth.guard.spec.ts
beforeEach(() => {
  // El escenario, explícito. Un test que dice de qué parte se puede leer
  // aislado, y deja de depender de en qué orden lo ejecuten.
  localStorage.removeItem('certcore.accessToken');
});
```

**Prueba de regresión**

Aquí la "prueba" es que el fallo deje de depender del orden, y eso se comprueba forzando el orden peor:

```ts
// src/app/core/guards/auth.guard.spec.ts
describe('authGuard con estado sucio de otro test', () => {
  beforeEach(() => {
    // Reproduce exactamente lo que dejaba el spec de AuthService.
    localStorage.setItem('certcore.accessToken', VALID_TOKEN);
  });

  it('parte de un estado limpio pase lo que pase antes', () => {
    // Falla antes del fix: el guard veía la sesión y devolvía true.
    // El beforeEach del propio spec tiene que ganarle al residuo.
    expect(authGuard(route, state)).toBeInstanceOf(UrlTree);
  });
});
```

Y la comprobación de que el arreglo es real, que es la que hay que dejar en el pipeline:

```bash
# La misma semilla que fallaba, tres veces. Si pasa las tres, está cerrado.
for i in 1 2 3; do ng test --watch=false --browsers=ChromeHeadless --seed=83104 || exit 1; done
```

**Prevención**

El `afterEach` global de `test.ts`, y una regla de revisión: **un test no asume el estado del que parte; lo declara.** Si un `it` necesita que no haya sesión, la quita él, aunque "obviamente" no la haya.

Y una decisión de proceso que vale más que las dos: **fijar y registrar la semilla en el pipeline.** Un pipeline que aleatoriza sin dejar rastro de la semilla produce fallos que nadie puede reproducir; uno que la imprime y la conserva convierte cada fallo en un caso investigable.

**Por qué llegó a producción**

Al pipeline, no a producción — y es un matiz importante, porque el daño de este incidente es distinto: **erosiona la confianza en la suite entera**. Cuando el equipo aprende que los rojos a veces son mentira, el día que uno sea real nadie va a mirarlo.

El sistema lo permitió por tres decisiones separadas, ninguna mala por sí sola. Jasmine aleatoriza el orden **a propósito**, para detectar exactamente esto. Karma en `--watch` reutiliza la semilla, así que en local nunca varía. Y `localStorage` es global por diseño del navegador. La combinación de las tres hace que el bug sea invisible en desarrollo y frecuente en integración continua.

**Y la frase para el equipo**, que es parte del entregable:

> *Relanzar el job hasta que pase no es una decisión neutra: es enseñarle al equipo a ignorar los rojos. Un test intermitente es un test roto, aunque el código que prueba esté bien, y vale menos que no tenerlo — porque además genera confianza.*

**Si tu causa fue distinta a esta**

Si concluiste que el pipeline es más lento y por eso falla, tienes razón en el mecanismo de otros intermitentes y no de éste: el tiempo no cambia el orden de los `describe`. Si tu hipótesis fue el reloj, se descarta en un `grep`: ningún archivo de esa pareja llama a `new Date()`. Si tu fix fue marcar el test con `xit` "mientras tanto", es legítimo **como decisión consciente y con fecha**, y un desastre como reflejo: un `xit` sin comentario ni ticket es un test que nadie va a volver a mirar — y el coverage sigue contando sus líneas si otro test las toca de refilón, que es el incidente 20.

</details>

---

## Incidente 18 — "Desplegamos el arreglo hace dos horas y la gente sigue viendo el error; a mí me funciona"

> **Fase:** 13 · **Categoría:** Despliegue · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1h-1h30 · **Ruta forense:** [`forense-fase-13.md`](forense-fase-13.md)

### 🎫 El ticket

> *"Desplegamos el arreglo del formulario hace dos horas y la gente sigue viendo el error. A mí me funciona perfecto. Ya le dije a dos personas que recargaran y una dice que sigue igual."*

**Reportado por:** tu líder técnico
**Ambiente:** PROD

### 🎯 Qué se te pide

Explicar por qué a unos les funciona y a otros no, y por qué **"a mí me funciona"** es en este ticket un dato técnico y no una excusa. Arreglar la causa, no el episodio.

### 🔧 Preparación

```bash
git switch -c incidente/18 fase-13
docker build -t certcore:inc18 .
docker run --rm -d --name certcore-inc18 -p 8080:80 \
  -e ENVIRONMENT_NAME=PROD -e API_BASE_URL=/api certcore:inc18
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No uses tu navegador para diagnosticar esto: lleva meses con *Disable cache* puesto y te va a mentir con la mejor intención. Usa `curl`, que no tiene opiniones.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

```bash
curl -I http://localhost:8080/
```
Mira la cabecera `Cache-Control`. Después piensa qué archivos del `dist/` llevan hash en el nombre y cuáles no.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el navegador conserva el `index.html` de ayer, ese HTML referencia los bundles de ayer — que siguen existiendo en el servidor, porque un despliegue no borra nada. ¿Qué versión de la aplicación está ejecutando ese usuario, y produce algún error?

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

**Causa raíz**

```
$ curl -I http://localhost:8080/
HTTP/1.1 200 OK
Content-Type: text/html
Cache-Control: public, max-age=31536000     ← un año, sobre el index.html
```

El `nginx.conf` aplica la política de caché de los bundles **a todo**, incluido el `index.html`. Los bundles llevan hash en el nombre (`main.8a1f2c.js`) y se pueden cachear un año sin riesgo: un nombre distinto es un archivo distinto. El `index.html` **no lleva hash** y cambia en cada despliegue.

El resultado es que el navegador de cada usuario conserva el `index.html` de la última visita, que referencia los bundles de esa versión — **que siguen existiendo en el servidor, porque un despliegue no borra nada**. Esos usuarios ejecutan la aplicación de ayer, completa y funcionando, sin ningún error que delate nada.

**Y "a mí me funciona" es el dato clave:** quien lo dice tiene DevTools abierto con *Disable cache*. Es el único de todo el equipo que **nunca** ha visto este bug, y por eso es también quien lo va a descartar más rápido.

> 🧭 **La regla que cabe en una frase y resuelve toda la política de caché de una SPA: lo que lleva hash en el nombre se cachea para siempre; lo que no lleva hash no se cachea nunca.** Equivocarse en el lado del `index.html` produce el bug más frustrante que existe: el que ya arreglaste.

**Parche mínimo**

```nginx
# nginx.conf
# Los bundles llevan hash: su contenido nunca cambia. Un año, sin miedo.
location ~* \.(js|css|woff2?)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# El index.html NO lleva hash y cambia en cada despliegue.
# `no-store` y no `no-cache`: el segundo permite guardar y revalidar, y un proxy
# intermedio puede interpretar la revalidación con generosidad.
location = /index.html {
    add_header Cache-Control "no-store";
}

# Y lo mismo para la configuración de arranque, por la misma razón.
location = /assets/config.json {
    add_header Cache-Control "no-store";
}
```

```bash
docker build -t certcore:inc18-fix .
curl -I http://localhost:8080/ | grep -i cache
# Cache-Control: no-store
```

**La refactorización correcta**

El parche arregla los despliegues futuros y **no alcanza a quien ya tiene el HTML malo cacheado un año**. Para ésos hay dos caminos, y conviene saber cuál se puede:

- **Si hay una CDN o un proxy delante**, se invalida la ruta `/` y el problema se acaba en minutos.
- **Si no lo hay**, no hay forma de alcanzar esos navegadores. Lo único que queda es un mecanismo de versión en la propia aplicación: la aplicación consulta periódicamente un `version.json` **sin caché** y, si la versión no coincide con la suya, avisa al usuario de que recargue. Es feo, y es lo que hacen los sistemas que ya han pasado por esto una vez.

**Prueba de regresión**

Aquí no hay `.spec.ts`: lo que hay que verificar es la respuesta del servidor, y eso se comprueba contra la imagen construida.

```bash
#!/usr/bin/env bash
# scripts/check-cache-headers.sh — corre en el pipeline, después del build de imagen.
set -euo pipefail
BASE="${1:-http://localhost:8080}"

header() { curl -sI "$1" | tr -d '\r' | grep -i '^cache-control:' | cut -d' ' -f2-; }

# El index.html NO se cachea nunca.
[[ "$(header "$BASE/")" == *"no-store"* ]] \
  || { echo "❌ index.html cacheable: es el incidente 18"; exit 1; }

# La configuración de arranque tampoco.
[[ "$(header "$BASE/assets/config.json")" == *"no-store"* ]] \
  || { echo "❌ config.json cacheable: dos ambientes con la misma config"; exit 1; }

# Y los bundles SÍ, porque llevan hash.
BUNDLE=$(curl -s "$BASE/" | grep -o 'main\.[a-z0-9]*\.js' | head -1)
[[ "$(header "$BASE/$BUNDLE")" == *"immutable"* ]] \
  || { echo "❌ bundles sin caché: cada visita descarga todo otra vez"; exit 1; }

echo "✅ política de caché correcta"
```

**Prevención**

El script de arriba en el pipeline, **después de construir la imagen y antes de promocionarla**. Es la única forma de comprobar una decisión que no vive en el código de la aplicación sino en la configuración del servidor, y que por tanto ningún test unitario puede alcanzar.

**Por qué llegó a producción**

La regla de caché se escribió con una sola intención —que los bundles no se descarguen en cada visita, que es correcto y mejora mucho la experiencia— y se aplicó con un patrón amplio porque en ese momento **todo lo que había que servir llevaba hash**. El `index.html` quedó dentro por omisión, no por decisión.

El fallo es invisible en desarrollo (`ng serve` no cachea), invisible para quien tiene DevTools abierto (que es todo el equipo de desarrollo), y **sólo aparece en el segundo despliegue**, cuando ya hay una versión anterior que conservar. Entre la decisión y su consecuencia pasaron semanas y varios despliegues correctos.

Y hay un agravante de proceso que merece decirse: **la primera reacción del equipo fue pedirle a los usuarios que recargaran**, que no funciona —una recarga normal usa la caché— y consumió dos horas antes de que nadie mirara una cabecera.

**Si tu causa fue distinta a esta**

Si concluiste que el despliegue no llegó, se descarta en el paso 1 del recorrido de `forense-fase-13.md`: los digests de la imagen coinciden. Si concluiste que es la CDN, puede serlo **y se comprueba igual**: si `curl` directo al origen ya devuelve la cabecera mala, la CDN está obedeciendo. Y si tu fix fue reconstruir y volver a desplegar, funciona por accidente esta vez —el HTML nuevo llega con otro momento de caché para algunos— y deja la política intacta: el mismo bug vuelve en el siguiente despliegue, y ahora con el equipo convencido de que redesplegar es un procedimiento de diagnóstico.

</details>

---

## Incidente 19 — "En UAT entra bien y en producción la pantalla se queda en blanco"

> **Fase:** 13 · **Categoría:** Despliegue · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1h30-2h · **Ruta forense:** [`forense-fase-13.md`](forense-fase-13.md)

### 🎫 El ticket

> *"Subimos la misma imagen a producción y la pantalla se queda en blanco. En UAT entra perfecto. No sale ningún error en la consola, o al menos yo no veo nada."*

**Reportado por:** el equipo de soporte
**Ambiente:** PROD

### 🎯 Qué se te pide

Descartar las capas en el orden correcto —el código va **al final**—, encontrar la causa, y explicar por qué una pantalla en blanco sin errores es la firma de un tipo de fallo muy concreto.

### 🔧 Preparación

```bash
git switch -c incidente/19 fase-13
docker build -t certcore:inc19 .

# UAT, que funciona:
docker run --rm -d --name certcore-uat -p 8080:80 \
  -e ENVIRONMENT_NAME=UAT -e API_BASE_URL=/api certcore:inc19

# PROD, que no:
docker run --rm -d --name certcore-prod -p 8081:80 \
  -e ENVIRONMENT_NAME=PROD -e API_BASE_URL=/api certcore:inc19
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de nada, la pregunta que descarta la capa más grande: ¿es **de verdad** la misma imagen? Un comando, diez segundos.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Es la misma. Entonces la diferencia está en lo que cada contenedor tiene dentro **después de arrancar**. Compara el `assets/config.json` de los dos y mira los logs de arranque de cada uno.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En uno de los dos, el archivo no existe. `APP_INITIALIZER` **bloquea el arranque** de Angular hasta que resuelve. ¿Qué pasa si la promesa se rechaza antes de que haya dónde pintar un error?

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

**Causa raíz**

Los cuatro pasos, en orden, y cada uno descarta una capa entera:

```bash
# 1. ¿Es la misma imagen? Sí: los digests coinciden.
docker inspect --format '{{.Image}}' certcore-prod certcore-uat
# sha256:9f2c4b1e…
# sha256:9f2c4b1e…

# 2. ¿Qué configuración tiene cada uno?
docker exec certcore-uat  cat /usr/share/nginx/html/assets/config.json
# {"apiBaseUrl": "/api", "environmentName": "UAT"}
docker exec certcore-prod cat /usr/share/nginx/html/assets/config.json
# cat: can't open '/usr/share/nginx/html/assets/config.json': No such file or directory

# 3. ¿Qué dijo el arranque?
docker logs certcore-prod 2>&1 | grep certcore
# (nada — el script nunca corrió)

# 4. Y la causa, en un ls:
docker exec certcore-prod ls -l /docker-entrypoint.d/
# -rw-r--r--  1 root root  412 40-certcore-config.sh     ← SIN el bit de ejecución
```

El `entrypoint.sh` **llegó a la imagen sin permiso de ejecución**. El entrypoint de nginx recorre `/docker-entrypoint.d/`, encuentra un archivo que no puede ejecutar, **lo ignora en silencio**, y arranca perfectamente. nginx sirve la aplicación; sólo falta el `config.json`.

**Y ahí está la pantalla en blanco:** `APP_INITIALIZER` bloquea el arranque de Angular hasta que su promesa resuelve. La petición a `assets/config.json` devuelve `404`, la promesa se rechaza, **Angular no arranca**, y lo que ve el usuario es una página vacía sin ningún error visible — porque el fallo ocurrió antes de que hubiera dónde pintarlo.

> 🧠 **Una pantalla en blanco sin errores en consola es casi siempre un fallo en el arranque**, y en una aplicación con `APP_INITIALIZER` es casi siempre él. No hay error visible porque no hay aplicación donde mostrarlo. Es una firma muy reconocible una vez que la has visto.

**Por qué en UAT sí funciona:** el contenedor de UAT se levantó desde una imagen construida en otra máquina, donde el archivo sí tenía el bit puesto en el sistema de archivos de origen. **Los permisos de un archivo copiado con `COPY` dependen de cómo estuviera en la máquina que construyó**, y eso convierte el build en algo que depende del entorno — que es exactamente lo que una imagen existe para evitar.

**Parche mínimo**

```dockerfile
# Dockerfile
COPY entrypoint.sh /docker-entrypoint.d/40-certcore-config.sh

# El bit de ejecución se pone AQUÍ y no se hereda del sistema de archivos del
# que copiaste. Si el archivo llega sin permiso, nginx arranca igual, ignora el
# script en silencio, y la aplicación sale con la configuración ausente.
RUN chmod +x /docker-entrypoint.d/40-certcore-config.sh
```

**La refactorización correcta**

El `chmod` arregla la causa y deja el **modo de fallo** intacto: si mañana el script falla por otra razón —una variable ausente, un directorio sin permiso de escritura—, la aplicación volverá a salir en blanco sin decir nada. Dos cambios lo convierten en un fallo ruidoso:

```sh
#!/bin/sh
# entrypoint.sh
# `set -e` para que cualquier fallo detenga el arranque en vez de dejar el
# contenedor sirviendo una aplicación incompleta. Un contenedor que no arranca
# es un problema visible; uno que arranca mal es un ticket de dos horas.
set -e

: "${ENVIRONMENT_NAME:?falta la variable ENVIRONMENT_NAME}"
: "${API_BASE_URL:?falta la variable API_BASE_URL}"

cat > /usr/share/nginx/html/assets/config.json <<JSON
{"apiBaseUrl": "${API_BASE_URL}", "environmentName": "${ENVIRONMENT_NAME}"}
JSON

echo "[certcore] configuración de arranque: ${ENVIRONMENT_NAME} -> ${API_BASE_URL}"
```

Y del lado de Angular, que el fallo tenga dónde verse:

```ts
// src/app/core/config/app-config.initializer.ts
export function loadAppConfig(): Promise<void> {
  const http = inject(HttpClient);
  const config = inject(AppConfigService);

  return firstValueFrom(http.get<AppConfig>('assets/config.json'))
    .then((loaded) => config.set(loaded))
    .catch((error: unknown) => {
      // Sin esto, el fallo de arranque es una página en blanco muda.
      // Pintar a mano en el DOM es feo y es lo único que funciona: Angular
      // todavía no existe, así que no hay componente que pueda hacerlo.
      document.body.innerHTML =
        '<p style="font-family:system-ui;padding:2rem">' +
        'No se pudo cargar la configuración de la aplicación. ' +
        'Avisa al equipo de plataforma.</p>';
      throw error;
    });
}
```

**Prueba de regresión**

Contra la imagen construida, en el pipeline:

```bash
#!/usr/bin/env bash
# scripts/check-image.sh — corre después de `docker build`, antes de promocionar.
set -euo pipefail
IMAGE="${1:?uso: check-image.sh <imagen>}"

# 1. El script de configuración es ejecutable. Es el incidente 19.
docker run --rm --entrypoint sh "$IMAGE" -c \
  '[ -x /docker-entrypoint.d/40-certcore-config.sh ]' \
  || { echo "❌ el entrypoint no es ejecutable: la app saldrá en blanco"; exit 1; }

# 2. Sin las variables obligatorias, el contenedor NO arranca en silencio.
if docker run --rm -d --name certcore-check "$IMAGE" >/dev/null 2>&1; then
  sleep 2
  docker rm -f certcore-check >/dev/null
  echo "❌ arrancó sin ENVIRONMENT_NAME: falla en silencio"; exit 1
fi

# 3. Con ellas, el config.json existe y tiene los valores dados.
CID=$(docker run --rm -d -e ENVIRONMENT_NAME=TEST -e API_BASE_URL=/api "$IMAGE")
sleep 2
docker exec "$CID" cat /usr/share/nginx/html/assets/config.json | grep -q '"TEST"' \
  || { docker rm -f "$CID" >/dev/null; echo "❌ config.json no refleja las variables"; exit 1; }
docker rm -f "$CID" >/dev/null

echo "✅ imagen correcta"
```

**Prevención**

El script de arriba, y la regla que lo justifica: **todo lo que puede fallar en el arranque de un contenedor tiene que fallar ruidosamente.** Un contenedor que no arranca lo ve el orquestador y lo reporta; uno que arranca sirviendo una aplicación rota lo descubre un usuario dos horas después.

**Por qué llegó a producción**

Tres decisiones razonables que sólo juntas producen el fallo. **`COPY` conserva los permisos del origen**, lo cual es útil y hace que el build dependa de la máquina que lo ejecuta. **El entrypoint de nginx ignora lo que no puede ejecutar** en vez de fallar, que es prudente para no romper contenedores por un archivo suelto de otro. Y **`APP_INITIALIZER` bloquea el arranque**, que es exactamente lo que queremos: una aplicación que arranca sin saber a qué backend hablar es peor que una que no arranca.

Ninguna de las tres está mal. La combinación produce un contenedor sano sirviendo una aplicación muerta, sin una sola línea en ningún log.

El agravante es que **el archivo llegó bien a la imagen de UAT** —construida en otra máquina, en otro momento— así que la evidencia disponible decía "la misma imagen se comporta distinto", que es la afirmación que más tiempo hace perder cuando resulta ser falsa. En este caso era cierta: la imagen sí era la misma; lo que cambió fue **cuál de los dos contenedores se levantó desde una construcción anterior**.

**Si tu causa fue distinta a esta**

Si concluiste que las variables de entorno están mal en PROD, es la hipótesis correcta que hay que descartar **primero** y se descarta en el paso 2: el problema no es que el JSON tenga valores equivocados, es que **no existe**. Si concluiste que falta `try_files` en el `nginx.conf`, eso produce un `404` al recargar una ruta profunda, no una pantalla en blanco en la raíz — y se descarta con un `curl` a `/inspections/500`. Y si te fuiste directo al código de la aplicación, es exactamente el callejón que este incidente entrena a evitar: los cuatro pasos cuestan cinco minutos entre todos y descartan tres capas.

</details>

---
## Incidente 20 — "Tenemos 82 % de coverage y el bug llegó a producción igual"

> **Fase:** 12 · **Categoría:** Testing · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1h30-2h · **Ruta forense:** [`forense-fase-12.md`](forense-fase-12.md)

### 🎫 El ticket

> *"El incidente 08 se nos escapó a producción con la suite en verde y 82 % de coverage. Quiero saber cómo es posible y qué hacemos para que no vuelva a pasar. Y no quiero 'subamos el coverage al 90'."*

**Reportado por:** tu líder técnico
**Ambiente:** —

### 🎯 Qué se te pide

Este incidente **no termina en un fix de código**: termina en un diagnóstico y una decisión. Demostrar con números por qué el 82 % no protegía nada de lo que importa, y proponer un cambio concreto que sí lo haga. La frase que no se admite como respuesta es la que el propio ticket ya descarta.

### 🔧 Preparación

```bash
git switch -c incidente/20 fase-12
ng test --watch=false --code-coverage --browsers=ChromeHeadless
open coverage/certcore/index.html   # o el navegador que uses
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El número global no dice nada; la distribución sí. Ordena el informe por porcentaje y mira **qué tipos de archivo** están arriba y cuáles abajo. No es una casualidad: es una consecuencia de qué es fácil de testear.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Busca en el informe el archivo donde vivía el bug del incidente 08. ¿Qué porcentaje tiene? Y si está cubierto, abre el test que lo cubre y pregúntate **qué afirma**.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Una línea "cubierta" significa que **se ejecutó** durante la suite. No significa que alguien haya comprobado lo que hace. ¿Qué mide entonces el 82 %?

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

**Causa raíz**

Hay dos, y la segunda es la que duele.

**Primera: el 82 % global esconde su distribución.**

```
File                          % Stmts   % Branch   % Funcs   % Lines
------------------------------------------------------------------
core/domain/                    97.4      94.1      100       97.1
core/api/                       91.2      85.7       94       90.8
core/state/                     88.6      79.3       92       88.1
features/**/components          43.2      31.5       48       42.7
------------------------------------------------------------------
All files                       82.3      74.6       86       81.9
```

El coverage del proyecto **está dominado por funciones puras**, y eso es honesto, no un truco: `resolveTemplateVersion`, `buildAnswerForm`, las reglas de severidad y las agregaciones del panel se prueban sin `TestBed`, cuestan diez líneas por test, y ahí es donde la suite se concentra sola.

El precio es que **el número global no dice nada sobre los componentes**, que es donde vive el riesgo de una SPA. Con un 43 % en `features/`, más de la mitad de las pantallas no las mira nadie — y el 82 % de la portada las deja invisibles.

**Segunda, y es la de verdad: una línea cubierta no es una línea comprobada.**

```ts
// El archivo del incidente 08 aparecía cubierto al 100 %. Éste era el test:
it('carga el detalle de la inspección', fakeAsync(() => {
  fixture.detectChanges();
  httpMock.expectOne((r) => r.url.includes('/inspections/501')).flush(inspection501);
  tick();
  httpMock.expectOne((r) => r.url.includes('/templates')).flush([templateV2]);
  tick();

  expect(component.view).toBeTruthy();   // ← esto es todo lo que afirma
}));
```

La línea `resolveTemplateVersion(family, todayInBusinessZone())` **se ejecutó**, así que cuenta como cubierta. Y el test pasa igual con la v1 que con la v2, porque **`toBeTruthy()` no mira la versión**. El bug pasó por debajo de un test verde, en una línea verde, dentro de un archivo al 100 %.

> 🧠 **El coverage mide qué código se ejecutó, no qué comportamiento se comprobó.** Es una métrica de **alcance**, no de **calidad**. Un `expect(x).toBeTruthy()` al final de un flujo largo cubre decenas de líneas y no afirma nada sobre ninguna.

**Parche mínimo**

No hay parche: el entregable es una decisión. Y la primera parte es **el test que faltaba**, que ya existe desde el incidente 08 y afirma el invariante en vez de la ausencia de excepciones:

```ts
expect(applied?.version).toBe(1);
expect(applied?.items.length).toBe(3);
```

**La refactorización correcta**

Tres cambios, en orden de valor y **ninguno es "subir el número"**:

**Uno — umbrales por carpeta, no globales.** Un solo número deja que las funciones puras paguen la factura de los componentes.

```jsonc
// karma.conf.js — coverageReporter
{
  "check": {
    "global": { "statements": 80, "branches": 70, "functions": 80, "lines": 80 },
    "each": {
      // El umbral por archivo es lo que impide que un archivo al 20 % se
      // esconda detrás de veinte al 95 %.
      "statements": 50, "branches": 40, "functions": 50, "lines": 50,
      "overrides": {
        // El dominio es barato de probar y es donde vive el negocio.
        "src/app/core/domain/**/*.ts": { "statements": 95, "branches": 90 }
      }
    }
  }
}
```

**Dos — la pregunta que sustituye al porcentaje en la revisión de código.** No *"¿subió el coverage?"* sino:

> 🧭 **¿Esta zona tiene test, o sólo tiene porcentaje?**
>
> Y su versión operativa, que se puede aplicar en cualquier revisión en treinta segundos: **cambia una constante del código y corre la suite. Si sigue en verde, ese test no protege nada.** Es mutación a mano, y es la única forma barata de saber si una aserción afirma algo.

**Tres — un test de invariante por regla de negocio, con nombre.** El proyecto tiene cuatro invariantes que ningún componente puede violar, y cada uno merece un test que lo diga en su nombre:

```ts
// src/app/core/domain/invariants.spec.ts
describe('invariantes de CertCore', () => {
  it('una inspección se lee siempre con la versión que guardó', () => { … });
  it('un hallazgo crítico sin resolver bloquea la emisión', () => { … });
  it('un certificado vence al final del día del negocio', () => { … });
  it('como máximo una versión vigente por familia en cualquier fecha', () => { … });
});
```

**Cuatro nombres que se leen como el contrato del sistema.** Si alguno se pone en rojo, nadie tiene que interpretar qué significa.

**Prueba de regresión**

La de este incidente es distinta: se prueba **el pipeline**, no el código.

```bash
#!/usr/bin/env bash
# scripts/check-coverage.sh — falla si algún archivo baja del suelo por archivo.
set -euo pipefail
ng test --watch=false --code-coverage --browsers=ChromeHeadless

node -e '
const s = require("./coverage/certcore/coverage-summary.json");
const FLOOR = 50;
const bad = Object.entries(s)
  .filter(([f]) => f !== "total" && !f.includes(".spec."))
  .filter(([, m]) => m.statements.pct < FLOOR);

if (bad.length) {
  console.error(`❌ ${bad.length} archivo(s) por debajo del ${FLOOR}%:`);
  bad.forEach(([f, m]) => console.error(`   ${m.statements.pct.toFixed(1)}%  ${f}`));
  process.exit(1);
}
console.log("✅ ningún archivo por debajo del suelo");
'
```

**Prevención**

Los umbrales por archivo, la pregunta de revisión, y los cuatro tests de invariante. Y una cuarta cosa que no es técnica y vale más que las tres: **cada incidente de este cuaderno se cierra con un test que falla antes del fix.** Veinte incidentes son veinte tests que prueban comportamiento real y no cobertura — y eso es una suite construida desde los bugs que de verdad ocurrieron, que es la única forma honesta de saber que prueba lo que importa.

**Por qué llegó a producción**

Porque el equipo midió lo que era fácil de medir. El coverage es un número automático, comparable entre proyectos y fácil de poner en un panel; *"¿este test afirma algo?"* no se automatiza y hay que preguntárselo persona a persona en cada revisión.

El sistema empujó en esa dirección sin que nadie lo decidiera: el umbral del 80 % se puso al montar la suite en la Fase 12 —una cifra razonable, tomada de la costumbre—, y a partir de ahí **la métrica se convirtió en el objetivo**. Los tests que suben el número rápido son los que ejecutan mucho código y afirman poco, así que el incentivo empujaba exactamente hacia los tests que no protegen.

No hay nadie a quien señalar aquí: hay una métrica mal elegida y un proceso que la premió durante dos años.

**Si tu causa fue distinta a esta**

Si tu conclusión fue "hay que subir el coverage al 90 %", es la que el ticket descarta de entrada y merece decir por qué: **con estos tests, el 90 % se alcanza cubriendo más componentes con más `toBeTruthy()`**, y el sistema quedaría igual de desprotegido con un número más bonito. Si concluiste que hacen falta tests end-to-end, es una conversación legítima y de otro presupuesto — y no arregla ésta: un e2e que no afirme el invariante tampoco lo habría detectado. Y si concluiste que el problema fue no haber escrito el test de regresión **antes** del fix, has llegado al mismo sitio por otro camino: verlo en rojo es lo único que demuestra que un test prueba lo que dice probar.

</details>

---

## 🪞 Retrospectiva del mes

Se llena **al terminar**, de una sola vez, releyendo tu propio `git log`. No es un informe: es la única parte de este archivo que vas a releer dentro de un año.

```bash
# El material para escribirla:
git log --oneline --grep "incidente(" | wc -l          # cuántos commits de investigación
git tag -n99 -l 'inc/*'                                # los pares roto/fix, con su mensaje
git log --oneline --grep "hipótesis descartada"        # los callejones que registraste
```

**Cuántos abriste, cuántos cerraste, cuántos quedaron ⚪**

**Cuántas veces tu causa raíz coincidió con la de referencia, y en cuáles no.**
El patrón importa más que el número. Si fallaste tres veces y las tres eran de tiempo, ya sabes qué leer.

**En qué capa te costó más**
Plantilla · componente · servicio de estado · `*ApiService` · guard · interceptor · mock · build · contenedor.

**Cuántas veces el estilo te confundió 🧬**
Cuántos incidentes perdiste buscando en un `NgModule` algo que vivía en un standalone, o al revés. **Es la métrica propia de este track** y no existe en un sistema de una sola generación.

**Qué pista abriste antes de tiempo y por qué**
Sin culpa. Es un dato sobre dónde te falta confianza, no sobre tu disciplina.

**Tu checklist de hotfix**
La de una página, reescrita con lo que aprendiste este mes. Es lo único de este archivo que te llevas al trabajo real: el `HOTFIX.md` que escribiste en la **Fase 13 §5.9**, revisado con veinte incidentes encima.

> 🧭 **Y el criterio para saber si el mes hizo su trabajo:** que ante un ticket vago, tu primer movimiento ya no sea abrir el editor.

---

## 📌 Pendientes que salieron de los incidentes

Lo que apareció investigando y no cabía en el fix.

- **[05]** "Sin cargar" y "no hay ninguna" se pintan igual. Un campo `loaded: boolean` en `FeatureState<T>` los separaría y la pantalla podría decir "cargando…" en vez de "no hay plantillas". → **Fase 4**, o decisión de proyecto.
- **[06]** Un fallo puramente visual no tiene ningún mecanismo automático que lo detecte en este proyecto. La conversación sobre pruebas de regresión visual cabe en media página. → **Fase 12** 🔥 o apéndice.
- **[09]** Publicar una versión son dos escrituras y **desde el navegador no son atómicas**. La solución real es un endpoint transaccional, y CertCore no tiene backend propio. → **Conversación con backend**, documentada en `docs/`.
- **[13]** `overriddenBy` y `overriddenAt` guardan **la última** anulación, no su historial. En un sistema cuyo dominio es la trazabilidad, eso es un límite de arquitectura. → **A07** §8 ya lo nombra; merece una decisión escrita.
- **[14]** El pie del PDF con fecha, hora y zona horaria de generación convierte "este PDF miente" en "este PDF es de antes". → **A08** §4 lo recomienda; hacerlo obligatorio en la Fase 10.
- **[15]** El `status` de un certificado está **guardado** en el `db.json` y debería ser derivado. Un estado que se calcula pero se almacena empieza a mentir al día siguiente. → **Fase 10** ya lo convierte; el dato de la semilla queda como recordatorio deliberado.
- **[15]** Regla de lint: `new Date()` y `Date.now()` prohibidos dentro de `core/domain/`. El instante entra por parámetro. → **Fase 12**, con el pipeline de calidad.
- **[17]** El pipeline aleatoriza el orden y **no registra la semilla**. Un fallo que nadie puede reproducir no se investiga. → **Fase 12**, configuración de integración continua.
- **[18]** Sin CDN delante, no hay forma de alcanzar un navegador con el `index.html` cacheado un año. Un `version.json` sin caché que avise al usuario es feo y es lo que hacen los sistemas que ya pasaron por esto. → **Fase 13** 🔥.
- **[19]** Todo lo que puede fallar en el arranque de un contenedor tiene que fallar **ruidosamente**. `set -e` y variables obligatorias en el `entrypoint.sh`. → **Fase 13**, ya incorporado en la refactorización.
- **[20]** Los cuatro invariantes del sistema merecen un `invariants.spec.ts` propio, con nombres que se lean como el contrato. → **Fase 12**.
- **[20]** Mutación a mano como paso de revisión: *cambia una constante y corre la suite; si sigue en verde, ese test no protege nada.* → **Checklist de revisión del equipo.**

---

## 🔥 El cuaderno hermano del track de backend

Este archivo es el cuaderno del **track base**, y sus IDs no cambian nunca.

El track opcional de backend tiene el suyo, **`cuaderno-incidentes-be.md`**, con
doce incidentes numerados `be-01` … `be-12` y un rango de IDs **independiente**:
los dos cuadernos no se cruzan ni se renumeran el uno al otro.

La separación es deliberada. Quien haga solo el track base no tiene por qué
recibir incidentes de PHP 7.4 + Lumen + PostgreSQL 16 mezclados con los suyos, y quien haga los dos sabe
en todo momento de qué capa es el ticket que está leyendo — que es justamente el
músculo que los dos cursos entrenan.

⚠️ Los incidentes del track BE tienen además una particularidad: **uno de ellos no
tiene par `-roto` / `-fix`**, porque su causa no está en ningún commit. Está
explicado en `00-convencion-de-git-y-tags.md`.
