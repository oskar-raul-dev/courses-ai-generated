# 📦 Apéndice 3 — npm (repaso de consulta)

## 🎯 Para qué sirve este apéndice

npm apareció en la primera hora del curso y no se fue nunca — pero siempre de
pasada. Este apéndice junta lo que un dev de mantenimiento necesita entender
de él: la anatomía de `package.json`, la diferencia que importa entre tipos
de dependencias, qué promete el lockfile, cómo leer los rangos de versión, y
el diagnóstico de los males clásicos. Consúltalo antes del ritual de "borro
node_modules y rezo" — que tiene su lugar, pero como **último** recurso, no
primero.

---

## 🧬 Anatomía del `package.json` del Mini Jira

```json
{
  "name": "mini-jira-legacy",
  "version": "1.0.0",
  "private": true,                    // ← nunca publicar esto a npm por accidente
  "scripts": { ... },                 // ← los comandos del proyecto (abajo)
  "dependencies": { ... },            // ← lo que la APP necesita para correr
  "devDependencies": { ... }          // ← lo que TÚ necesitas para desarrollarla
}
```

Es el documento de identidad del proyecto: al abrir un legacy ajeno, leer su
`package.json` completo (5 minutos) te dice el stack, la época, los comandos
disponibles y las sorpresas — antes de abrir un solo componente.

## ⚖️ dependencies vs devDependencies — el criterio con la evidencia del curso

**La pregunta:** ¿este código termina dentro del bundle que corre en el
navegador (o lo necesita la app en runtime)? Sí → `dependencies`. ¿Es
herramienta de desarrollo, build, test o mock? → `devDependencies`.

La auditoría del propio proyecto:

| Paquete | Tipo | Por qué |
|---|---|---|
| `vue`, `vue-router`, `vuex`, `axios`, `lodash`, `vuelidate`, `bootstrap`, `jquery`, `popper.js` | dependencies | van dentro del bundle: la app los ejecuta |
| `socket.io-client` | dependencies | corre en el navegador (F8) |
| `vue-template-compiler` | **dev** | compila templates en BUILD-time; el navegador recibe render functions, no templates |
| `json-server`, `stubby` | dev | mocks: solo existen mientras desarrollas |
| `socket.io` (el servidor) | dev | nuestro mini-server es infraestructura de desarrollo del curso |
| `jest`, `@vue/test-utils`, etc. | dev | los trae el plugin (F11); los tests no viajan a producción |
| `concurrently` | dev | orquesta terminales de desarrollo (F3 ej. 15) |

¿Importa de verdad? En una SPA con webpack, el bundle incluye **lo que
importas**, no lo que declaras — así que confundirlas rara vez rompe. Pero sí
importa para: instalaciones de producción (`npm install --production` omite
dev), auditorías de seguridad, y sobre todo **comunicación** — el
package.json le dice al siguiente dev qué es app y qué es andamiaje. En
legacy, un `json-server` en dependencies es una pequeña mentira que confunde.

## 🔢 Semver y los símbolos `^` `~` — por qué el curso fijó versiones

Las versiones siguen `MAYOR.MENOR.PARCHE` (semver): parche = fix compatible,
menor = feature compatible, mayor = **rompe cosas**. Los prefijos declaran
cuánta libertad le das a npm:

| Declarado | npm puede instalar | Espíritu |
|---|---|---|
| `"2.6.14"` | exactamente 2.6.14 | control total |
| `"~2.6.14"` | 2.6.x (≥14) | acepta parches |
| `"^2.6.14"` | 2.x.x (≥2.6.14) | acepta menores — **el default de npm** |
| `"*"` / `"latest"` | lo que sea | caos con sintaxis |

📍 **Por qué el curso fija `vue@2.6.14` exacto y empareja
`vue-template-compiler`:** esos dos deben ser **idénticos** (F0/F1 — el error
críptico de compilación cuando divergen), y un `^` podría actualizarlos por
separado en máquinas distintas. La regla legacy general: **semver es una
promesa del autor del paquete, no una garantía** — los "parches" que rompen
existen, y en un proyecto de mantenimiento la estabilidad vale más que los
fixes automáticos. Fijar exacto + actualizar deliberadamente > confiar en el
`^`.

## 🔒 `package-lock.json` — la foto exacta

El `package.json` declara rangos; el **lockfile** graba qué se instaló
exactamente — cada paquete, cada dependencia transitiva, con versión y hash.
Tres reglas:

1. **Se versiona en git.** Siempre. Es la única forma de que otra máquina (u
   otro año) reproduzca tu `node_modules`.
2. **No se edita a mano.** Lo mantiene npm.
3. `npm ci` (en vez de `npm install`) instala **exactamente** el lockfile —
   borra node_modules y clava las versiones. Es lo correcto para CI y para
   "quiero exactamente lo que el repo dice". `npm install` puede *actualizar*
   el lockfile si los rangos lo permiten — de ahí los misteriosos "no toqué
   nada y cambió el lock".

📍 El clásico "en mi máquina sí funciona" de la Fase 0 tiene dos vacunas:
`.nvmrc` (versión de Node) + lockfile versionado (versiones de paquetes).
Juntas cierran el caso.

## 📜 Scripts — los verbos del proyecto

Los del Mini Jira al final del curso:

```json
"scripts": {
  "serve":      "vue-cli-service serve",
  "build":      "vue-cli-service build",
  "test:unit":  "vue-cli-service test:unit",
  "mock":       "json-server --watch db.json --port 3000",
  "mock:reset": "cp db.seed.json db.json",
  "sockets":    "node server/socket-server.js",
  "dev":        "concurrently \"npm run mock\" \"npm run sockets\" \"npm run serve\""
}
```

Lo que hay que saber:

- **Los scripts encuentran los binarios locales.** `json-server` no está en
  tu PATH — está en `node_modules/.bin/`, y npm agrega esa carpeta al PATH
  *solo dentro de scripts*. Por eso `npm run mock` funciona y `json-server`
  a secas en tu terminal dice `command not found` (la solución suelta:
  `npx json-server ...`).
- **Pasar flags al script:** el `--` separador —
  `npm run test:unit -- --watch` (F11). Sin el `--`, el flag se lo queda npm.
- **Hooks pre/post:** un script llamado `premock` correría automáticamente
  antes de `mock`. Útil y peligroso: en legacy, un `postinstall` misterioso
  es de lo primero a auditar.
- Los scripts son **documentación ejecutable**: el `dev` de arriba le dice a
  cualquiera cómo se levanta el proyecto completo sin leer un README.

## 🌍 Global vs local vs npx

| Modo | Comando | Cuándo | 📍 En el curso |
|---|---|---|---|
| **Local** (default) | `npm install x` | casi siempre: la versión queda en el lockfile, atada al proyecto | todo el stack |
| **Global** | `npm install -g x` | herramientas de "tu máquina", no del proyecto | `@vue/cli` (F0) — la necesitas ANTES de que exista el proyecto |
| **npx** | `npx x` | ejecutar sin instalar, o forzar la versión local | probar cosas, correr binarios locales fuera de scripts |

La trampa del global: no queda registrado en ningún lado del repo — el
siguiente dev no sabe que lo necesita, ni qué versión. Regla: **global solo
lo que crea proyectos; todo lo demás, local**. (Stubby fue global en la F0
por pereza justificada de Hello World; nota que al jubilarse no dejó rastro
en el package.json — exactamente el problema.)

---

## ⚠️ Diagnóstico rápido (el orden importa)

Ante un problema de dependencias, la escalera — de menos a más destructivo:

```
1. ¿Versión de Node correcta?  → nvm use  (resuelve más de lo que crees)
2. ¿Falta instalar?            → npm install
3. ¿El lockfile y node_modules divergieron? → npm ci  (reinstala exacto)
4. Último recurso: rm -rf node_modules package-lock.json && npm install
   ⚠️ esto RE-RESUELVE los rangos: puede instalar versiones distintas a las
   que funcionaban. En legacy con ^ regados, es jugar a la ruleta — por eso
   es el último peldaño y no el primero.
```

| Síntoma | Causa probable |
|---|---|
| `command not found: json-server` (u otro binario) | es local: úsalo vía script o `npx` |
| Error críptico de vue-loader / "Vue packages version mismatch" | `vue` ≠ `vue-template-compiler` (F1) — iguala ambas versiones |
| `npm WARN peer dep ...` | un paquete espera otro en cierta versión que no cumples; con npm 6 (Node 14) es warning — anótalo, suele explicar bugs raros |
| `ERESOLVE` / conflictos duros al instalar | rangos incompatibles entre paquetes; identifica el par en el mensaje antes de forzar nada |
| Funciona en una máquina y no en otra | lockfile sin versionar, o `npm install` vs `npm ci`, o Node distinto |
| El lockfile cambió "solo" en tu diff | corriste `npm install` con rangos `^` — decide si commitear el cambio o revertir |
| `npm audit` grita 47 vulnerabilidades | normal en legacy; NO corras `audit fix --force` a ciegas (sube mayores y rompe) — evalúa cuáles tocan código que de verdad corre |

---

## 🧪 Ejercicios (34) — todos opcionales

> Los apéndices son material de consulta y práctica libre. Haz los que te
> sirvan, cuando te sirvan.

**🟢 Fácil (1–10)**

1. Lee el `package.json` completo en voz alta (sí, en voz alta) y verifica
   que puedes explicar cada línea. Anota las que no.
2. `npm ls vue` y `npm ls axios`: el árbol te dice qué versión hay instalada
   y quién la pide.
3. `npm outdated`: lee las tres columnas (current/wanted/latest). ¿Qué
   instalaría un `npm update`? No lo corras: solo entiéndelo.
4. `npx cowsay "legacy 4ever"`: siente npx. Verifica que el package.json no
   cambió.
5. Corre `json-server` a secas en tu terminal y confirma el
   `command not found`. Ahora con `npx`. Explica la diferencia.
6. `npm view vue versions` (o `npm view vue@2 version`): explora el catálogo
   público de una dependencia.
7. Clasifica de memoria cinco dependencias del proyecto en dep/devDep y
   verifica contra el package.json. Anota los fallos.
8. Añade un script `"hola": "echo hola"` y córrelo. Ahora con `--silent`.
9. Corre `npm run` sin argumentos: te lista todos los scripts. Es el "menú"
   de cualquier legacy que abras.
10. Encuentra `node_modules/.bin/` y lista su contenido: ahí viven todos los
    binarios que tus scripts usan.

**🟡 Intermedio (11–20)**

11. Agrega un `"prelint"` que imprima un mensaje y comprueba el hook en
    acción antes de `lint`.
12. Provoca el mismatch: cambia `vue-template-compiler` a `2.6.12`,
    reinstala, corre `serve` y captura el error exacto. Restaura.
13. Simula la máquina nueva: clona tu repo a otra carpeta, `nvm use`,
    `npm ci`, `npm run dev`. Cronometra. Todo lo que hiciste "de memoria" es
    documentación que falta en el README.
14. Compara `npm install` vs `npm ci` en tiempo y en efecto sobre el
    lockfile. Mide ambos.
15. Fija TODAS las versiones del proyecto (quita los `^`), reinstala y
    verifica que nada cambió. Escribe 3 líneas sobre qué acabas de ganar y
    perder.
16. Descubre a los polizones: `npm ls --depth=0` vs los imports reales del
    código. ¿Hay dependencias declaradas que nadie importa?
17. Alias de scripts: crea `"start": "npm run dev"` y descubre que
    `npm start` funciona sin `run` (junto con test, stop, restart — los
    scripts "especiales" de npm).
18. Instala una dependencia con `--save-exact` y observa cómo queda en el
    package.json. Compara con la instalación normal.
19. Explora un `node_modules` real: entra al paquete `axios`, lee su
    package.json (main, files, dependencies) y encuentra el archivo que
    realmente importas.
20. Cambia `axios` a `"^0.21.1"`, borra el lockfile, reinstala y compara qué
    versión llegó. Escribe 3 líneas sobre el riesgo presenciado. Restaura.

**🟠 Difícil (21–24)**

21. `npm audit`: elige UNA vulnerabilidad, rastrea con `npm ls <paquete>`
    quién la trae, y evalúa si afecta código que corre en tu app o solo
    tooling. El veredicto razonado ES el ejercicio.
22. `DEPENDENCIES.md`: tabla de cada dependencia directa con su propósito, la
    fase donde entró y su estado (activa / jubilada / dormida). Encontrarás
    al menos una sorpresa.
23. Resuelve un conflicto real: instala dos paquetes con peer dependencies
    incompatibles a propósito (busca un par de la época), lee el error
    completo y decide la salida (bajar versión, forzar, buscar alternativa).
    Documenta el razonamiento, no solo el comando.
24. Analiza el árbol completo: `npm ls --all | wc -l` (cuenta las
    dependencias transitivas) y encuentra el paquete más profundo. Reflexiona
    sobre la superficie de confianza que acabas de medir.

**🔴 Muy difícil (25–34)**

25. Publica un paquete propio: extrae `ticketTransitions` + `ticketStats` a
    un paquete `@tuusuario/minijira-core` con su package.json, build a CJS y
    ESM, y publícalo (en npm real o en un registry local con `verdaccio`).
    Consúmelo desde el proyecto. Acabas de vivir el otro lado del `npm
    install`.
26. Monorepo: convierte el proyecto en workspaces (`packages/app`,
    `packages/core`, `packages/mock-server`) con npm workspaces o Lerna (el
    de la época). Descubre qué problema resuelve y qué complejidad cobra.
27. Auditoría de licencias: script (o `license-checker`) que liste la
    licencia de cada dependencia transitiva y marque las incompatibles con un
    uso comercial (GPL en un producto propietario, por ejemplo). Es una tarea
    real que le cae a alguien en toda empresa, y suele ser al que "sabe de
    npm".
28. Actualización mayor controlada: elige UNA dependencia con una versión
    mayor disponible (ej. `vuelidate` 0.x → 2.x, o `chart.js` 2 → 3),
    actualízala en una rama, arregla TODO lo que rompa (con los tests de F11
    como red), y escribe el informe de migración: cuánto costó, qué ganó,
    qué recomendarías. Es exactamente el entregable que te pedirán en un
    legacy.
29. Reproducibilidad extrema: verifica que `npm ci` en dos máquinas distintas
    produce `node_modules` idénticos comparando hashes de los archivos.
    Investiga por qué puede NO ser idéntico (scripts de instalación, binarios
    nativos por plataforma).
30. Elimina los `postinstall` ajenos: audita si alguna dependencia ejecuta
    scripts al instalar (`npm install --ignore-scripts` y ver qué rompe).
    Entiende el vector de ataque de supply-chain que acabas de tocar y
    escribe la política que recomendarías al equipo.
31. Cachea el CI: diseña (aunque no lo despliegues) la estrategia de caché
    de `node_modules` / caché de npm para un pipeline, con la clave correcta
    (hash del lockfile) e invalidación. Explica por qué cachear mal es peor
    que no cachear.
32. Registry privado: levanta `verdaccio` local, configura el proyecto para
    usarlo como proxy del registry público, y publica ahí tu paquete del
    ejercicio 25. Es como funciona el npm de toda empresa mediana.
33. Reemplaza npm por yarn (v1, la de la época) en el proyecto: `yarn.lock`,
    equivalentes de comandos, diferencias de resolución. Documenta las tres
    diferencias que más importan en mantenimiento — y por qué muchos legacy
    tienen AMBOS lockfiles (y por qué eso es una bomba).
34. Escribe el `README.md` definitivo del proyecto: requisitos exactos
    (Node, npm), instalación reproducible, todos los comandos con su
    propósito, arquitectura en 10 líneas, y los tres errores más comunes de
    arranque con su solución. Pásaselo a alguien que nunca vio el repo y
    cronometra cuánto tarda en tener la app corriendo. Ese número es la
    calidad real de tu documentación.

## 📚 Referencias

- npm — docs de package.json: https://docs.npmjs.com/cli/v6/configuring-npm/package-json
- npm — package-lock.json: https://docs.npmjs.com/cli/v6/configuring-npm/package-lock-json
- npm — scripts: https://docs.npmjs.com/cli/v6/using-npm/scripts
- semver — la especificación y calculadora: https://semver.org/ · https://semver.npmjs.com/
- npm ci: https://docs.npmjs.com/cli/v6/commands/npm-ci

*(Docs de npm v6 — la que trae Node 14. Las versiones nuevas de npm cambian
comportamientos: en legacy, lee la doc de TU versión: `npm -v`.)*
