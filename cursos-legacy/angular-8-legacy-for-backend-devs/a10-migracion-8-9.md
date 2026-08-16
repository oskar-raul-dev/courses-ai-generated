# 📎 Apéndice A10 — 🔥 Migración 8 → 9

> Tutorial Angular 8 — Laboratorio clínico · Consulta rápida · **3h**
> Usado por: Fases 3, 4, 12 y 13, siempre como referencia · Versión cubierta: el salto de **Angular 8.2.14 a la línea 9.0**, con Ivy
> Estado: 🔥 **Opcional.** El curso se completa sin abrir este apéndice

**Esto no se lee de corrido.** Es material de consulta: se entra por el índice buscando algo concreto y se sale. Resuelve la conversación que aparece una vez al año, normalmente en una reunión y normalmente mal planteada: **"¿y por qué no actualizamos a una versión más nueva?"**.

Este apéndice **no migra el sistema** y no propone hacerlo. Sirve para dos cosas: leerlo, para poder responder con criterio en esa reunión; y ejecutarlo, en una **rama desechable que se tira al terminar** (§8), para poder responder con datos en vez de con opiniones. El código principal del curso se queda en Angular 8 pase lo que pase — todo lo que hay aquí es comparación y reconocimiento, nunca práctica que se lleve al proyecto.

**Qué queda fuera:** la migración real, obviamente; todo lo posterior a la 9 —standalone, `inject()`, control flow, `strict` de TypeScript— que es el **Apéndice A11**; las herramientas para medir el bundle antes y después (**A04 §5**, que es su dueño: acá se dice *qué* medir, no con qué); y cualquier **tabla de versiones compatibles**, que deliberadamente no vas a encontrar (§6, y la razón está ahí explicada).

---

## Índice

- [1. La pregunta que de verdad se responde acá](#1-la-pregunta-que-de-verdad-se-responde-acá)
- [2. Ivy, en las tres cosas que sí vas a notar](#2-ivy-en-las-tres-cosas-que-sí-vas-a-notar)
- [3. `ng update` de verdad](#3-ng-update-de-verdad)
- [4. `ngcc`, el invitado que nadie espera](#4-ngcc-el-invitado-que-nadie-espera)
- [5. Los errores nuevos, traducidos](#5-los-errores-nuevos-traducidos)
- [6. La cadena de dependencias: la pregunta que le haces a cada una](#6-la-cadena-de-dependencias-la-pregunta-que-le-haces-a-cada-una)
- [7. Lo que no bloquea hoy y sí bloquea después](#7-lo-que-no-bloquea-hoy-y-sí-bloquea-después)
- [8. El ensayo en una rama desechable](#8-el-ensayo-en-una-rama-desechable)
- [9. Estimar el costo sin inventárselo](#9-estimar-el-costo-sin-inventárselo)
- [⚖️ El veredicto honesto: cuándo NO migrar](#️-el-veredicto-honesto-cuándo-no-migrar)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [📚 Referencias](#-referencias)
- [🧪 Ejercicios (7)](#-ejercicios-7)

---

## 1. La pregunta que de verdad se responde acá

La reunión empieza mal casi siempre, y empieza mal por la forma de la pregunta. *"¿Actualizamos a una versión más nueva?"* no se puede responder, porque mezcla tres preguntas distintas que tienen respuestas distintas y dueños distintos:

**¿Qué se gana?** Poco de cara al usuario y bastante de cara a quien mantiene: una clase entera de bugs de compilación desaparece (§2), los mensajes de error mejoran, y sobre todo **dejas de estar en una versión que ya nadie soporta**, que es lo que de verdad te bloquea el día que necesites una librería nueva o un parche de seguridad.

**¿Qué cuesta?** Angular sube prácticamente solo: `ng update` reescribe buena parte de tu código (§3). El costo real está en otro sitio, y conviene decirlo desde el primer minuto: **el problema no es Angular, son las ocho librerías de alrededor** (§6) y lo que hay que volver a probar a mano (§9).

**¿Qué riesgo hay?** El del sistema, no el del framework. Un sistema con suite de pruebas y despliegue reversible acepta esto con calma; uno sin pruebas convierte cada cambio de comportamiento silencioso en un ticket de producción tres semanas después.

> 🧭 **La frase que hay que poner sobre la mesa antes de discutir nada:** *migrar un legacy en producción es un proyecto, no un `ng update`*. Y la contraria, igual de importante: *quedarse tampoco es gratis, solo es un costo que no aparece en ningún ticket hasta que aparece de golpe*. Las dos son ciertas, y elegir entre ellas es una decisión de producto con información técnica, no una decisión técnica a secas. Lo que sí es tuyo es llevar la información: §9 explica cómo conseguirla.

Y una cosa más, para bajar la ansiedad: el salto **8 → 9 es de los amables**. Es el que trae Ivy, sí, pero Angular hizo un trabajo poco habitual en compatibilidad —Ivy fue diseñado para que el código de ViewEngine siguiera compilando— y trae más *migration schematics* que ningún otro salto de la época. Los saltos duros de este camino vienen después, y son territorio de **A11**.

---

## 2. Ivy, en las tres cosas que sí vas a notar

Ivy es el compilador y el runtime nuevos que estrena la 9. Qué es por dentro no te ayuda a decidir nada, así que esto es solo lo que se nota desde fuera.

### 2.1 AOT en todas partes, y una clase de bug que se evapora

En Angular 8, `ng serve` compila con JIT y `ng build --prod` con AOT: **no compilan lo mismo**, y de ahí sale uno de los patrones más caros del curso, el de "compila en desarrollo y revienta en producción". Lo sufriste dos veces: con el `httpLoaderFactory` de i18n escrito como arrow inline (**Fase 2 §6**) y otra vez con el `appConfigInitializer` (**Fase 13 §6**), las dos por la misma razón: el AOT de la época necesitaba funciones exportadas con nombre para poder serializar los metadatos.

**Con Ivy, AOT está encendido también en desarrollo, y esa restricción de metadatos desaparece.** Es el argumento más fuerte a favor de migrar, y es el que la 📝 de **A04 §2.2** anticipa. Traducido a lo que te importa: el error lo ves en tu máquina, a los segundos, y no en el pipeline veinte minutos después.

Lo que **no** desaparece es la idea de que hay dos entornos: el primer build se vuelve más lento porque ahora también compila AOT, y aparece un actor nuevo que sí puede hacer que "en mi máquina funcione" (§4).

### 2.2 `entryComponents` se va, y se va solo

Todo componente que se crea dinámicamente —los diálogos y los snackbars con `openFromComponent`— tiene que declararse en `entryComponents` en Angular 8, y **A01 §7.2** lo explica con la 📝 de que es el requisito que peor envejeció. Ivy no lo necesita: genera la factoría igual. La *schematic* de `ng update` **borra el campo de tus módulos por ti**, y es de las pocas deudas de este curso que se pagan gratis, sin decidir nada.

### 2.3 Los errores cambian de redacción y algunos de momento

Los mensajes se reescriben casi todos y varias comprobaciones se mueven a tiempo de ejecución en vez de fallar al compilar. En la práctica: **un error que conoces de memoria en Angular 8 va a decir otra cosa en la 9**, y buscar el texto viejo en internet te va a llevar a respuestas que no aplican.

> ⚠️ A partir de esta época Angular empieza a numerar los errores de runtime con códigos `NG0xxx`, que son buscables y mucho más útiles que el texto. **Qué códigos existen exactamente en tu versión, verifícalo en la referencia de errores de la versión que instales**, no en un blog: es de las cosas que cambian entre menores.

---

## 3. `ng update` de verdad

No es un `npm install`. Es un comando que **lee tu código, lo reescribe y te deja el resultado en el árbol de trabajo** — y por eso la primera regla no es técnica.

```bash
# 1. El árbol de git TIENE que estar limpio. ng update se niega a correr si hay
#    cambios sin confirmar, y hace bien: lo que vas a leer después es el diff
#    que produjo, y no puede estar mezclado con lo tuyo.
git status

# 2. Que dice Angular que se puede actualizar, sin tocar nada todavía.
npx ng update

# 3. El salto, con core y cli JUNTOS y en el mismo comando. Separarlos deja el
#    proyecto en un estado intermedio que ninguna schematic espera.
npx ng update @angular/core@9 @angular/cli@9

# 4. Y las librerías de Angular que tienen su propia schematic, después.
npx ng update @angular/material@9
```

**Cuatro reglas que no se negocian.**

**Una mayor por vez.** De la 8 se va a la 9, no a la 12. Cada salto trae sus *schematics* y solo saben leer el código de la versión anterior. Saltarse una es quedarse sin las reescrituras automáticas de ese tramo y hacerlas a mano.

**Core y CLI a la vez.** Son la misma pieza repartida en dos paquetes.

**El árbol limpio, antes y entre pasos.** Un commit por paso del `ng update`, con el mensaje diciendo qué comando lo produjo. El diff de cada paso es el documento más valioso del ensayo (§8).

**Lee el diff. Todo.** Las *schematics* son buenas y no son mágicas: reescriben lo que reconocen y dejan intacto lo que no entienden, sin avisar de que no lo entendieron.

### Qué reescriben las schematics del 8 → 9

Sin ser exhaustivo —la lista exacta la publica la guía oficial de actualización para tu par de versiones concreto—, esto es lo que toca de **este** proyecto:

| Lo que tienes en Angular 8 | Qué pasa en la 9 | ¿Automático? |
|---|---|---|
| `entryComponents` en los módulos con diálogos (**A01 §7.2**) | Deja de hacer falta | ✅ La schematic lo borra |
| `loadChildren: './x/x.module#XModule'` (**Fase 3**, 📝 de época) | La sintaxis de string se retira; se usa `import()` dinámico | ✅ La schematic lo reescribe |
| `ModuleWithProviders` sin genérico | Pasa a exigir `ModuleWithProviders<T>` | ✅ En tu código; ❌ si viene de una librería |
| Clases base con inyección y sin decorador | Necesitan `@Directive()` | ✅ La schematic lo añade |
| `Renderer` (el viejo, no `Renderer2`) | Retirado | ⚠️ Comprueba si lo usas; el proyecto no debería |
| `TestBed.get()` (**Fase 12 §5**) | Queda obsoleto en favor de `TestBed.inject()` | ⚠️ Sigue funcionando; migrarlo es opcional |
| Imports de Material desde el paquete raíz | Hay que importar por punto de entrada (`@angular/material/button`) | ✅ La schematic de Material lo reescribe |

> 💡 **El commit más útil de todo el ensayo** es el que separa "lo que reescribió la máquina" de "lo que tuve que arreglar yo". El primero es rutina y se revisa en diagonal; el segundo es **la estimación de verdad** del §9. Si mezclas los dos en un commit, tiras el dato más caro que produce el ensayo.

---

## 4. `ngcc`, el invitado que nadie espera

Este es el que sorprende, y es el que hace que alguien diga "algo se rompió" cuando en realidad todo va bien pero lento.

**El problema que resuelve.** Tu aplicación pasa a Ivy, pero las librerías que instalaste —Material, NgRx, `@ngx-translate`, los gráficos— están **compiladas para ViewEngine**, que es el compilador anterior. No las vas a recompilar tú y sus autores tardarán en publicar versiones Ivy. Angular resuelve el desfase con el **Angular Compatibility Compiler**, `ngcc`: un proceso que recorre `node_modules` y **reescribe las librerías al formato de Ivy**.

**Los tres síntomas que produce, y ninguno se parece a su causa:**

- **El `npm install` se vuelve eterno.** `ngcc` corre después de instalar y procesa paquete por paquete. En un stack como este son varios minutos en una máquina normal, y bastantes más en una lenta. No está colgado: está compilando.
- **`node_modules` deja de ser reproducible por copia.** `ngcc` **modifica los paquetes en su sitio**, así que un `node_modules` procesado no es igual al que produce un `npm ci` limpio. Todo lo que **A03** cuenta sobre copiar `node_modules` entre máquinas se vuelve todavía más falso.
- **CI falla distinto que tu máquina.** Si el pipeline cachea `node_modules` a medias, o si el build corre con el paquete a medio procesar, salen errores que hablan de módulos que no encuentran factorías. La solución habitual es forzar el procesado como paso explícito del pipeline, después de instalar y antes de compilar.

> ⚠️ Los flags exactos de `ngcc` y la forma recomendada de encadenarlo en CI **cambian entre la 9.0 y la 9.1**, así que ese es un dato a verificar en la documentación de la versión que instales, no a copiar de acá. Lo que no cambia es el diagnóstico: **si tras migrar el `npm install` tarda muchísimo o CI se rompe con errores de módulos, sospecha de `ngcc` antes que de tu código.**

> 🧭 **La escotilla de emergencia existe.** La 9 permite volver a ViewEngine con `enableIvy: false` en el `tsconfig`. Sirve para desbloquear un ensayo que se atasca y para separar dos preguntas: *"¿falla por la versión nueva o falla por Ivy?"*. **No sirve como plan**: es un interruptor temporal que las versiones siguientes retiran, y quedarse ahí es migrar a medias, que es peor que no migrar.

---

## 5. Los errores nuevos, traducidos

Los que de verdad vas a ver en este proyecto, con lo que significan.

**`Generic type 'ModuleWithProviders<T>' requires 1 type argument(s)`.**
Es TypeScript, no Angular. El tipo pasó a exigir el genérico, y aparece en cualquier módulo con un `forRoot()` propio. La *schematic* lo arregla en tu código; si el error apunta a un archivo dentro de `node_modules`, no es tuyo: es una librería que todavía no se actualizó, y la respuesta está en §6.

**Un error sobre una clase que necesita un decorador.**
En la 9, una clase base que recibe dependencias por constructor y de la que heredan componentes tiene que llevar `@Directive()` (vacío). Suena raro y tiene sentido: es lo que le dice al compilador que ahí hay inyección. La *schematic* lo añade.

**`'mat-...' is not a known element` de repente, en un módulo que no tocaste.**
Casi siempre es el cambio de puntos de entrada de Material: el import dejó de resolverse y el módulo ya no está importado de verdad. Revisa el diff de la *schematic* de Material en ese archivo.

**Errores de plantilla que antes no salían.**
La 9 estrena `strictTemplates`, una comprobación de tipos mucho más severa dentro de los HTML: `@Input` que reciben el tipo equivocado, `async` sobre cosas que pueden ser `null`, eventos con la firma cambiada. **Es opcional y viene apagada en un proyecto que se actualiza.**

> ⚠️ **No enciendas `strictTemplates` el día de la migración.** Con `strict: false` y `any` a discreción —que es el TS-0 declarado de este curso—, encenderlo produce cientos de errores que no tienen nada que ver con el salto de versión, y a partir de ahí ya nadie sabe qué rompió qué. Se enciende **después**, como proyecto aparte, y de preferencia módulo por módulo. Es conversación de **A11**, junto con el `strict` de TypeScript.

**Y uno que no vas a ver, gracias a una decisión de la Fase 2.** La 9 cambia el i18n nativo: llega `@angular/localize` y la extracción se hace distinto. Como este proyecto resolvió i18n **en runtime con `@ngx-translate`** (**Fase 2 §4**, **A07 §2**), toda esa parte de la migración no te toca. Es la primera vez en el curso que una deuda vieja sale a favor, y conviene decirlo en la reunión: *la decisión de 2019 de no usar el i18n nativo hace este salto más barato*.

---

## 6. La cadena de dependencias: la pregunta que le haces a cada una

Acá no vas a encontrar una tabla de "qué versión de cada librería funciona con Angular 9". **Es deliberado**, y por dos razones: esas matrices cambian con cada parche y una tabla escrita hoy miente en seis meses; y sobre todo, porque el trabajo que importa no es leer una tabla que alguien escribió, sino **saber comprobarlo tú en un minuto** para cualquier librería, incluidas las que este curso no conoce.

### Cómo se comprueba, en tres comandos

```bash
# 1. Que versiones existen del paquete. Se mira de atras hacia adelante
#    buscando la primera que salió después de Angular 9.
npm view @ngrx/store versions --json

# 2. LA PREGUNTA. Qué versión de Angular exige esa versión del paquete.
#    Esto es la verdad; el README y los blogs son rumores.
npm view @ngrx/store@9 peerDependencies

# 3. Que tienes instalado ahora, y quien lo trajo.
npm ls @angular/core
```

> ⚠️ **Con npm 6 —el del curso (**A03**)— un conflicto de *peer dependencies* no detiene la instalación: la completa y deja un `WARN` en medio de mil líneas.** Es la misma trampa que la **Fase 2 §5.1** documenta con `@ngx-translate`: instalas una versión incompatible, npm no te detiene, y el error aparece veinte minutos después en forma de fallo de compilación que nadie relaciona con la instalación. Con npm 7 en adelante esto falla ruidoso; con el tuyo, **el `peerDependencies` hay que mirarlo a mano, antes**.

### La ficha que se llena por dependencia

Una por librería, y el conjunto es el inventario de riesgo de la migración. Se rellena **antes** de tocar nada:

```
Paquete:              @ngrx/store
Versión actual:       8.6.0
¿Primera versión compatible con Angular 9?   ← npm view <pkg>@<v> peerDependencies
¿Es un salto de mayor?                       ← si sí, tiene su propio changelog que leer
¿Tiene ng update / schematic propia?         ← ng update lo lista; si no, es a mano
¿Hay cambios que rompen en ESE salto?        ← su CHANGELOG, no el de Angular
¿Cuántos archivos míos la importan?          ← grep -rl "@ngrx/store" src/ | wc -l
Veredicto:            sube solo / sube con trabajo / no hay versión / bloqueante
```

Y estas son las del stack, con la pregunta concreta que le corresponde a cada una:

| Dependencia | Qué le preguntas | Si la respuesta es mala |
|---|---|---|
| `@angular/material` + `cdk` | ¿La 9 reescribe mis imports por punto de entrada? | Tiene schematic; el riesgo es visual, no de compilación |
| `@ngrx/*` | ¿Qué mayor de NgRx pide Angular 9, y qué rompe **ese** salto? | Es tu segunda migración, con su propio changelog |
| `@ngx-translate/core` + `http-loader` | Ya sabes la respuesta: la 12 exige Angular 9+ (**Fase 2 §5.1**) | Sube con la migración, no antes |
| `ng2-charts` + `chart.js` | ¿Hay una versión que declare Angular 9 en sus peers? | Si no la hay, es de las que bloquean de verdad |
| `ngx-charts` (heredado) | ¿Alguien la usa todavía? (**Fase 10**) | Si no, la mejor migración es borrarla |
| `zone.js` | Sube de línea con Angular; ¿lo hizo el `ng update`? | Lo actualiza el propio salto |
| `jasmine` + `karma` | ¿Compilan los specs y corre la suite entera? | La suite de la **Fase 12** es tu red de seguridad: si no pasa, no hay migración |
| `node-sass` | ¿Compila con el Node que exige el CLI nuevo? | Es la deuda de **A12**, y aparece acá con otro disfraz |
| `jspdf`, `bootstrap` | Nada: no dependen de Angular | No te van a dar problemas |

> 🧭 **La regla que ordena el inventario:** una librería sin versión compatible **no es un problema técnico, es una decisión**. Las salidas son tres —esperar a que su autor publique, cambiarla por otra, o quitarla—, y las tres son trabajo de proyecto, no de migración. Encontrar esa librería el primer día del ensayo es el mejor resultado posible; encontrarla el último es la razón por la que las migraciones se abandonan a la mitad.

---

## 7. Lo que no bloquea hoy y sí bloquea después

Media sección para no confundir "problema del 8 → 9" con "problema del camino completo". Todo lo de acá es territorio del **Apéndice A11**, que lo recoge como sus **cuatro puertas** (**A11 §2**): RxJS 7, el retiro de ViewEngine, los saltos de Node y TypeScript, y las mayores de las ocho librerías.

**`rxjs-compat` no bloquea este salto.** Conviene precisarlo porque **A05 §2** lo declara "un bloqueante real de cualquier migración futura" y podría leerse como que frena la 9. No la frena: **Angular 9 sigue sobre RxJS 6.x**, y `rxjs-compat` vive en esa línea sin molestar. Lo que bloquea es el salto a **RxJS 7**, que llega bastante más adelante en el camino —y como `rxjs-compat` no tiene versión 7, hay que **quitarlo antes**, no después. O sea: sigue siendo un bloqueante real, y su fecha de vencimiento no es hoy. Ese día, el trabajo es el que **A05 §2** ya describe: buscar la sintaxis pre-pipe en el código y migrarla antes de tocar la versión.

**El `strict` de TypeScript y `strictTemplates`.** Ni uno ni otro son requisito de la 9. Encenderlos es un proyecto propio, con su propio calendario, y mezclarlo con una migración de versión es la forma más segura de que ninguno de los dos termine (§5).

**`@angular/localize` frente a `@ngx-translate`.** A partir de la 9 existe la alternativa oficial que en 2019 no existía. Eso **no** significa migrar: sigue sin permitir cambiar de idioma en caliente sin recargar, que es exactamente el requisito por el que se eligió runtime (**Fase 2 §4**). Lo que sí conviene es tenerlo escrito, porque alguien lo va a proponer.

**`node-sass`.** Compila contra la versión de Node que tengas, y cada salto de Node exige una versión distinta de `node-sass`. Ese hilo termina en `sass` (Dart Sass) y es la conversación del **Apéndice A12**; acá solo hay que saber que existe y que aparece como un fallo de instalación, no de Angular.

---

## 8. El ensayo en una rama desechable

Un ensayo bien hecho convierte la reunión de opiniones en una de datos, y cuesta una tarde. **Su entregable es un documento, nunca un merge.**

```bash
# La rama lleva "spike" en el nombre a propósito: cualquiera que la vea sabe
# que no es un plan ni una feature, y que se va a borrar.
git checkout -b spike/angular-9

# Antes de tocar nada, la foto del estado actual. Sin esto no hay comparación
# posible después, y "me pareció que tardaba más" no es un dato.
npx ng build --prod --stats-json     # el tamaño, medido con A04 §5
npm test -- --watch=false            # la suite de la Fase 12: cuantas pasan HOY
git commit -am "spike: estado inicial medido"
```

Después, el salto por pasos, **un commit por paso** (§3). Y al terminar, lo único que sobrevive a la rama:

```markdown
# Ensayo de migración Angular 8 → 9 — <fecha>

## Qué se hizo
Comandos ejecutados, en orden, y el commit de cada uno.

## Qué reescribió la máquina
Archivos tocados por las schematics. Revisado en diagonal: <sí/no>.

## Qué hubo que arreglar a mano
Lista, con el archivo y qué se hizo. **Esta lista es la estimación** (§9).

## Dependencias
La ficha de §6 rellenada. Marcar en rojo cualquiera sin versión compatible.

## Qué se midió
Suite: N pasaban antes / M pasan después.
Bundle inicial: antes / después (con la herramienta de A04 §5).
Tiempo de `npm install` y de build: antes / después (§4).

## Qué NO se probó
Todo lo que no tiene test automático. Esto es lo que hay que probar a mano
si la migración se aprueba, y es el grueso del costo real.

## Recomendación
Migrar / esperar / no migrar, con la condición que cambiaría la respuesta.
```

```bash
# Y se tira. La rama no se mergea, no se deja "por si acaso" y no se sube como
# propuesta: lo que se conserva es el informe, en el sitio donde el equipo
# guarda las decisiones.
git checkout master
git branch -D spike/angular-9
```

> ⚠️ **Una rama de ensayo que sobrevive tres meses se convierte en una promesa que nadie hizo.** Alguien la encuentra, asume que la migración "está casi", y la planifica sobre un trabajo que ya no compila con el `master` de hoy. Bórrala el mismo día. El informe es lo que vale, y el informe cabe en una página.

---

## 9. Estimar el costo sin inventárselo

Nadie puede darte un número de horas, y quien te lo dé sin haber corrido el ensayo se lo está inventando. Lo que sí existe es un método para llegar a un rango defendible.

### Primero: separa el trabajo en tres categorías

Son categorías con costos de naturaleza distinta, y mezclarlas es lo que produce estimaciones que fallan por un factor de cinco.

**(A) Lo que reescribe la máquina.** `entryComponents`, `loadChildren`, `ModuleWithProviders`, los imports de Material. Su costo **no es escribirlo, es revisarlo**: leer el diff y confirmar que la schematic entendió bien. Es rutina y es lo más predecible del proyecto.

**(B) Lo que compila y hay que volver a probar.** Todo lo que sigue compilando y **puede comportarse distinto**: los diálogos que ya no dependen de `entryComponents`, los formularios de Material, cualquier cosa con temporizadores o detección de cambios. **Este es el grueso del costo real** y no se mide en archivos, se mide en **pantallas que alguien tiene que abrir y mirar**. Si el sistema tiene poca cobertura —y la **Fase 12** te dice exactamente cuánta tiene—, esta categoría se dispara.

**(C) Lo que depende de terceros.** Las fichas de §6. Su costo es **desconocido hasta que rellenas la ficha**, y una sola librería sin versión compatible puede convertir la migración entera en otro proyecto. Es la categoría de mayor varianza y la que hay que resolver **primero**.

### Segundo: cuenta lo contable

No estima el esfuerzo, pero acota el tamaño y se hace en cinco minutos:

```bash
# Cuántos modulos declaran entryComponents (categoría A)
grep -rl "entryComponents" src/ | wc -l

# Cuantas rutas usan la sintaxis de string de loadChildren (categoría A)
grep -rn "loadChildren" src/ | grep "#" | wc -l

# Cuántos archivos importan cada librería del stack (categoría C)
grep -rl "@ngrx/" src/ | wc -l
grep -rl "@angular/material" src/ | wc -l

# Cuantas pantallas hay que mirar a mano (categoría B): los componentes que la
# suite NO cubre. El numerador sale del reporte de coverage de la Fase 12.
find src/ -name "*.component.ts" | wc -l
```

### Tercero: expresa la estimación como lo que es

Un rango, con los supuestos escritos al lado y la condición que lo invalidaría. Algo con esta forma:

> *"Categoría A: resuelta por las schematics en el ensayo, revisión incluida. Categoría C: N librerías, de las cuales una (`<nombre>`) no tiene versión compatible y decide si esto es viable. Categoría B: M componentes sin cobertura que hay que probar a mano; es el grueso y depende de cuánta gente pueda probar. **Supuesto:** que la suite de la Fase 12 siga verde tras el salto — si no lo está, la estimación no vale y hay que rehacerla."*

> 🧭 **Y el dato que más convence en una reunión no es un número, es el ensayo.** *"Lo probé en una rama, tardó una tarde, la máquina reescribió esto, tuve que arreglar aquello a mano, y hay una librería que nos bloquea"* vale más que cualquier estimación, porque es reproducible. Si te piden un número antes de tener el ensayo, la respuesta profesional es *"deja que corra el ensayo y te lo digo el jueves"*.

---

## ⚖️ El veredicto honesto: cuándo NO migrar

Este apéndice existiría igual si la respuesta fuera siempre "sí", pero no lo es.

**No migres si el sistema está en mantenimiento puro y no vas a añadirle nada.** Si nadie va a escribir una pantalla nueva, la versión del framework es un dato interno que no le importa a nadie. El trabajo se justifica por lo que desbloquea, y si no desbloquea nada, no se justifica.

**No migres sin una red de seguridad.** El riesgo real de este salto es la **categoría B**: lo que sigue compilando y se comporta distinto. Sin pruebas y sin capacidad de probar a mano, no estás migrando: estás apostando. Si la cobertura es baja, **la migración empieza escribiendo pruebas**, no ejecutando `ng update`.

**No migres a mitad de nada.** Ni con una entrega grande encima, ni con medio equipo de vacaciones, ni en la misma semana que otro cambio grande. Cuando algo se rompa —y algo se rompe—, tienes que poder decir con certeza si fue la migración o lo otro.

**No migres solo porque la versión es vieja.** "Estamos en la 8" no es un argumento; "necesitamos una librería que exige la 9", "hay un parche de seguridad que no llega a la 8" o "no encontramos gente que quiera mantener esto" sí lo son.

**Y sí conviene empezar la conversación cuando aparece cualquiera de esas tres**, porque el costo de quedarse crece de forma silenciosa: cada mayor que pasa aleja el destino, y saltar de la 8 a la 9 hoy es mucho más barato que saltar de la 8 a la 16 dentro de dos años, en tres saltos y con las mismas librerías dos años más abandonadas. Eso es lo que hay que decir en la reunión, sin dramatizarlo: **no es urgente, y se encarece con el tiempo**.

---

## 🧭 Cuándo usar qué

| Situación | Qué haces | Por qué |
|---|---|---|
| "¿Por qué no actualizamos?" en una reunión | §1 para plantear las tres preguntas | Sin separarlas, la discusión no converge |
| Te piden un número de horas | El ensayo primero (§8), la estimación después (§9) | Un número sin ensayo es una invención |
| Quieres saber si es viable, rápido | Las fichas de §6, antes que nada | Una librería sin versión compatible decide sola |
| Vas a correr `ng update` | Árbol limpio, una mayor, core y CLI juntos (§3) | Es un comando que reescribe tu código |
| El `npm install` se volvió eterno | `ngcc` (§4) | No está colgado, está compilando |
| CI falla y tu máquina no, tras migrar | `ngcc` y la caché de `node_modules` (§4) | `node_modules` deja de ser copiable |
| Un error apunta a un archivo de `node_modules` | Ficha de esa librería (§6) | No es tu código, es una versión incompatible |
| Salen cientos de errores en las plantillas | ¿Encendiste `strictTemplates`? Apágalo (§5) | Es otro proyecto, no parte del salto |
| Quieres saber si el bundle mejoró | Mídelo antes y después (**A04 §5**) | Las cifras de internet no son tu aplicación |
| Alguien propone saltar directo a la 16 | Una mayor por vez (§3), y **A11** | Saltarse tramos es renunciar a las schematics |
| El ensayo terminó | Escribe el informe y **borra la rama** (§8) | Una rama viva se convierte en una promesa |

---

## ⚠️ Advertencias

**Esto es comparación, no práctica del curso.** Nada de este apéndice se lleva al código principal: el proyecto se queda en Angular 8.2.14, con NgModules, sin `inject()` y sin control flow nuevo. Si te encuentras "aprovechando" para modernizar un módulo mientras haces el ensayo, estás fuera del alcance y contaminando la rama que ibas a tirar.

**`ng update` reescribe tu código y no todo lo que reescribe está bien.** Las *schematics* cubren lo que reconocen y callan sobre lo que no. El diff se lee entero, siempre; y si un archivo raro no aparece en el diff, esa ausencia también es información.

**Una mayor por vez, y sin saltarse ninguna.** Cada salto trae sus reescrituras automáticas y solo entienden el código de la versión inmediatamente anterior.

**Con npm 6 un conflicto de peers no detiene nada.** Deja un `WARN` y sigue, y el error aparece después disfrazado de fallo de compilación. En este stack, los `peerDependencies` se leen a mano antes de instalar (§6).

**No enciendas `strictTemplates` ni el `strict` de TypeScript en la misma tanda.** Son proyectos aparte. Mezclarlos hace imposible saber qué rompió qué, que es justo lo que necesitas saber.

**`enableIvy: false` es una escotilla, no un destino.** Sirve para desbloquear un ensayo y para separar dos preguntas. Quedarse ahí es migrar a medias y heredar lo peor de las dos versiones.

**Y la que gobierna a todas: el riesgo de esta migración no está en lo que no compila, está en lo que compila y se comporta distinto.** Lo que no compila te lo dice el compilador en minutos. Lo demás te lo dice un usuario, en producción, tres semanas después. Por eso la conversación empieza por la cobertura de pruebas (**Fase 12**) y no por el `ng update`.

---

## 📚 Referencias

- https://update.angular.io — **la primera parada, siempre.** Eliges versión de origen y destino, tu nivel de complejidad, y te genera la lista exacta de pasos para ese par. Es la única fuente que no envejece, porque se regenera. Si de este apéndice te quedas con un enlace, es este.
- https://v9.angular.io/guide/ivy — Ivy en la documentación de la versión 9, incluida la escotilla `enableIvy` (§4).
- https://v9.angular.io/guide/deprecations — **la página que más rinde y menos se lee.** Qué quedó obsoleto y qué se retiró, con la versión de cada cosa. Es donde se confirma lo de §3 y §5 sin creerle a nadie.
- https://v9.angular.io/guide/migration-ngcc — `ngcc`, qué hace y cómo encadenarlo. ⚠️ Los flags cambian entre menores: mira la doc de la versión que instales.
- https://v9.angular.io/guide/template-typecheck — `fullTemplateTypeCheck` y `strictTemplates`, con los tres niveles y qué caza cada uno. Léelo **antes** de encender nada (§5).
- https://blog.angular.io — el anuncio de cada versión mayor, que resume los cambios que rompen antes que la documentación. ⚠️ Busca la entrada de la versión concreta; el blog cubre todas.
- https://github.com/angular/angular/blob/main/CHANGELOG.md — el changelog completo, para cuando dudes de si algo existe en tu versión exacta. Es el mismo método que **A06** recomienda para NgRx.
- https://docs.npmjs.com/cli/v6/commands/npm-view — `npm view`, la herramienta de §6. La versión 6 de la documentación, que es la del stack (**A03**).
- https://v9.angular.io/guide/updating-to-version-9 — la guía específica del salto que cubre este apéndice, con la lista completa de *schematics* que corren.

> ⚠️ Todos los enlaces con `v9.angular.io` apuntan a la documentación **archivada** de la versión 9, que es la correcta para este apéndice y la que ya nadie enlaza. Si buscas cualquiera de estos temas en un buscador vas a caer en `angular.dev`, que documenta versiones muy posteriores donde varias de estas páginas ni existen. Y verifica antes de confiar: las URLs archivadas de Angular han cambiado de dominio más de una vez.

**Orden de lectura sugerido:** antes de opinar en la reunión, §1 y el veredicto de ⚖️. Antes de correr nada, `update.angular.io` para tu par de versiones exacto y las fichas de §6. Durante el ensayo, §3 y §4 a mano. Después, §9 para escribir la estimación y §8 para no dejar la rama viva.

---

## 🧪 Ejercicios (7)

Cortos y de consulta. Los tres primeros no necesitan tocar nada; los demás corren sobre una rama `spike/angular-9` que **se borra al terminar**.

1. Entra a `update.angular.io`, elige 8.2 → 9.0 con complejidad "avanzada" y lee la lista completa que genera. Anota **cuántos pasos** son y **cuántos aplican a este proyecto** (varios no, porque hablan de cosas que no usas). La diferencia entre esos dos números es la primera intuición honesta del costo.
2. Corre los cuatro conteos de §9 sobre el proyecto y escribe las cifras en tu cuaderno: módulos con `entryComponents`, rutas con `loadChildren` de string, archivos que importan NgRx y componentes totales. Después clasifica cada cifra en categoría A, B o C y explica en una línea por qué la categoría B es la que no puedes contar así.
3. Rellena la ficha de §6 para **tres** dependencias: `@ngrx/store`, `@ngx-translate/core` y `ng2-charts`. Usa `npm view` y no un blog. Anota cuál de las tres tardaste más en resolver y por qué — esa es tu candidata a bloqueante.
4. Crea la rama de ensayo, mide el estado inicial (bundle con **A04 §5** y suite de la **Fase 12**) y **haz el commit de la foto antes de tocar nada**. Sin ese commit, todo lo que midas después no se puede comparar con nada.
5. Corre `ng update @angular/core@9 @angular/cli@9` y **lee el diff completo** antes de compilar. Anota tres archivos que la schematic tocó y que tú no habrías tocado, y explica qué hizo en cada uno. Después compila y anota el primer error que salga, tal cual, con su texto exacto.
6. **Diagnóstico.** Tras migrar, corre `npm ci` cronometrándolo y compáralo con lo que tardaba antes. Después borra `node_modules`, vuelve a instalar y observa la salida buscando el paso de `ngcc`. Escribe en tres líneas qué le contestarías a un compañero que dice *"desde la migración el install está roto, se queda colgado"*.
7. Escribe el informe de §8 completo, con su recomendación y la condición que la cambiaría. Después **borra la rama** y confirma con `git branch` que no queda. El ejercicio no está terminado hasta que la rama no existe: ese es el punto.


> 🏷️ **Este apéndice no lleva tag propio, pero sí pide uno antes de empezar.**
> El ensayo de los ejercicios 4 a 7 corre sobre una rama `spike/angular-9` que
> **se borra al terminar**, y el ejercicio 4 te pide la foto del estado inicial
> para poder comparar. Esa foto es un tag, y sobrevive a la rama:
>
> ```bash
> git tag pre-spike-9     # antes de crear la rama y de tocar nada
> ```
>
> Con eso, `git diff pre-spike-9..spike/angular-9 --stat` es el costo de la
> migración en archivos y líneas, y sigue siendo consultable cuando la rama ya
> no exista. La convención completa está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **La lista exacta de schematics del 8 → 9.** §3 cubre las que tocan a este proyecto y remite el resto a `update.angular.io`, que la genera para tu par de versiones. Escribirla completa acá sería copiar algo que se regenera solo y envejece; si alguien corre el ensayo, la lista real que salió es un buen anexo del informe.
- **Cobertura como requisito previo.** El ⚖️ dice que sin red de seguridad esto es una apuesta, y la **Fase 12** mide cuánta hay. Lo que nadie ha decidido es **qué número sería suficiente** para aprobar una migración, y esa es una conversación de equipo, no de apéndice → decisión de proyecto, con nota en la **Fase 12**.
- **Theming de Material y `legacy` → `outline`.** **A01** y **A02 §5.3** mandaban acá dos cambios visuales globales, con el argumento de que "si igual vas a tocar todo, aprovecha". Este apéndice **no los recoge**: son cambios de aspecto con riesgo en pantallas que nadie está mirando, y meterlos en la misma tanda que un salto de versión viola la regla de §⚖️ de no migrar a mitad de nada. Destino corregido: **decisión de proyecto propia**, antes o después de la migración, nunca durante.
- 🪦 **El camino completo hasta hoy.** Este apéndice cubre un tramo; el resto quedó escrito en el **Apéndice A11**, que toma la lista de §7 como punto de partida. Un detalle que A11 corrigió: el **control flow** (`@if`, `@for`) no es de la 16 sino de la **17**, así que si alguien lo cita como argumento para saltar a la 16, está fechando mal el ejemplo.
