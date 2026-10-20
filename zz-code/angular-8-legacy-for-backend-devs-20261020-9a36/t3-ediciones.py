#!/usr/bin/env python3
"""T3: Node x64 en Apple Silicon, fsevents y la opción C (Dart Sass) verificada, en A12 y A02.
Cada par (viejo, nuevo) aparece exactamente una vez. Uso: python3 -I t3-ediciones.py <carpeta del curso>
"""
import os
import sys

C = sys.argv[1]
E = {
"a12-arm64-m1.md": [
("""Y de ahí sale la decisión del curso, que ya está tomada y explicada en **A03 §1.2**: en Apple Silicon, Node **14.21.3** —que es x64 y corre bajo Rosetta— es el número, y no hay conversación. Este apéndice explica el mecanismo detrás de esa decisión y qué hacer cuando aun así algo se rompe.""",
"""Y de ahí sale la decisión del curso, que ya está tomada y explicada en **A03 §1.2**: en Apple Silicon, Node **14.21.3** —que es x64 y corre bajo Rosetta— es el número, y no hay conversación. Este apéndice explica el mecanismo detrás de esa decisión y qué hacer cuando aun así algo se rompe.

> ⚠️ **Que sea x64 depende de cómo lo instalaste.** nodejs.org no publica `darwin-arm64` para la 14, y nvm solo pide el x64 por su cuenta por debajo de la 14.17.0: con la 14.21.3, `nvm install` a secas intenta el arm64, no lo encuentra y **compila Node desde fuente**. Si la fila 3 de arriba te sorprendió con `arm64`, es eso. La instalación correcta es desde una shell bajo Rosetta —`arch -x86_64 zsh -c 'source ~/.nvm/nvm.sh && nvm install 14.21.3'`— y está completa, con su comprobación, en la **Fase 0 §5.1**."""),
("""Los paquetes de este stack que pasan por aquí son pocos y conviene tenerlos identificados: **`node-sass`** es el protagonista, y cualquier cosa que instale un navegador o un binario externo (§5) tiene el mismo problema con otra forma.""",
"""Los paquetes de este stack que pasan por aquí son pocos y conviene tenerlos identificados: **`node-sass`** es el protagonista, y cualquier cosa que instale un navegador o un binario externo (§5) tiene el mismo problema con otra forma. El tercero es **`fsevents`**, el vigilante de archivos de macOS, y es el que hace ruido sin importar: el lockfile trae la 1.2.13 cuatro veces (por `@angular/compiler-cli`, `karma`, `watchpack-chokidar2` y `webpack-dev-server`), como dependencia **opcional**. En Linux se salta sola (`Skipping 'fsevents' build as platform linux is not supported`) y en Windows ni se instala. En el Mac intenta compilarse, y con un Python 3.11 o más nuevo —el de cualquier Mac actualizado— falla con un bloque de `gyp ERR!` que termina en una carpeta `…/fsevents`. Como es opcional, npm sigue y la instalación termina bien. **Ese `gyp ERR!` no es tu problema**; el que importa termina en `npm ERR!` y corta la instalación."""),
("""Qué es: exactamente lo que ya fija el curso. Node **14.21.3** en Apple Silicon (**A03 §1.2**) es un binario x64 traducido por Rosetta, así que""",
"""Qué es: exactamente lo que ya fija el curso. Node **14.21.3** en Apple Silicon (**A03 §1.2**), instalado como x64 (**Fase 0 §5.1**), es un binario de Intel traducido por Rosetta, así que"""),
("""Y un matiz que conviene saber antes de entrar: dentro de un contenedor **arm64** tu Node es arm64 de verdad, no x64 traducido, así que `node-sass` vuelve a no tener binario — el contenedor reubica el problema, no lo borra (**A13 §3**).""",
"""Y un matiz que conviene saber antes de entrar: dentro de un contenedor **arm64** tu Node es arm64 de verdad, no x64 traducido, así que `node-sass` vuelve a no tener binario y hay que compilarlo — el contenedor reubica el problema, no lo borra (**A13 §3**). El devcontainer de **A13 §6** ya trae lo que esa compilación pide, `python2` incluido."""),
("""Cuándo conviene: es la dirección a la que fue el mundo —`node-sass` está archivado desde 2020 (**A02 §1.1**, 📝 de época)— y en un proyecto moderno es la respuesta obvia.
El costo, y por qué **no es la receta de este apéndice**: en el CLI **8.3.29** el compilador no lo eliges tú, lo elige el `sass-loader` que el CLI trae por dentro, y `node-sass` viene arrastrado como dependencia del propio `build-angular`. Puede que el loader caiga en dart-sass si no encuentra el otro, y puede que no. Además, dart-sass es más estricto con la sintaxis vieja y tu proyecto está lleno de `@import` sin `@use` (**A02**).
Veredicto: **experimento, no receta.** Si lo intentas, hazlo en una rama desechable y con la suite de estilos delante — y si funciona, escríbelo, porque este apéndice no puede prometértelo.""",
"""Cuándo conviene: es la dirección a la que fue el mundo —`node-sass` está archivado desde 2020 (**A02 §1.1**, 📝 de época)— y en un proyecto moderno es la respuesta obvia.
Cómo funciona en el CLI **8.3.29**, que es lo que hace posible esta salida: `@angular-devkit/build-angular` 0.803.29 intenta cargar `node-sass` y, si no puede, usa `sass`, que **ya viene en tu lockfile** como dependencia suya (la 1.22.9). `node-sass` no lo arrastra nadie: está en el manifiesto de **A03 §8.1** porque el curso lo pide. Quitarlo es una línea:

```bash
# Sale node-sass del package.json y del lockfile; el CLI cae solo en sass.
npm uninstall node-sass
```

Así se probó, sobre la base del proyecto con el Sass de **A02 §5–§6**, en un contenedor arm64 **sin** Python 2: el `npm ci` instaló 59 paquetes menos y sin compilar nada, y `ng build` y `ng test` pasaron. El `@import` de Bootstrap 4 compila igual. El CSS no sale idéntico: de 2.691 reglas cambian 30, y ninguna por algo que se vea a simple vista —el redondeo de los colores que Bootstrap oscurece con `darken()` (`#5c5b5b` en `node-sass`, `#5c5c5c` en Dart Sass, en el gris de la Fase 8), la cantidad de decimales (`33.33333333%` frente a `33.3333333333%`), el orden de algunos selectores agrupados y un `@charset "UTF-8"` al principio—. El CSS de los componentes salió igual.
El costo: es un cambio de proyecto, no de tu máquina. Toca el manifiesto que comparte todo el equipo, el **A02** entero está escrito sobre `node-sass`, y el CSS que sale cambia en esas 30 reglas, así que alguien tiene que mirarlo antes de decidir.
Veredicto: **verificado, y decisión de proyecto.** El curso se queda con `node-sass` porque A02 lo enseña; si tu equipo decide quitarlo, esta es la salida que elimina el problema de raíz.

> ⚠️ **El cambio también puede pasar sin que nadie lo decida.** Si `node-sass` está en el manifiesto pero su binario no existe —por ejemplo, tras un `npm ci --ignore-scripts` en arm64—, el CLI no falla: atrapa el error de `node-sass` y compila con `sass` sin avisar. Tu CSS sale con las 30 diferencias de arriba y nada en la consola lo dice. Si en un Mac y en Windows el mismo commit da CSS distinto, revisa `ls node_modules/node-sass/vendor` en los dos."""),
("""| `Cannot find module 'node-sass'` tras cambiar de Node |""",
"""| `node -p process.arch` dice `arm64` con Node 14.21.3, o `nvm install` se pone a compilar | Node se instaló sin `arch -x86_64` | **Fase 0 §5.1**, §1 |
| `gyp ERR!` que termina en `…/fsevents`, y la instalación sigue | `fsevents` 1.2.13 opcional que no compila con Python ≥ 3.11 | §2: no es tu problema |
| `Cannot find module 'node-sass'` tras cambiar de Node |"""),
("""| El proyecto es tuyo y puedes cambiar el compilador | dart-sass, **en una rama** (§3, opción C) | Con el CLI 8 no está garantizado |""",
"""| El proyecto es tuyo y puedes cambiar el compilador | Dart Sass: `npm uninstall node-sass` (§3, opción C) | Verificado; el CSS cambia en 30 reglas que hay que revisar |"""),
("""**Cambiar `node-sass` por dart-sass no está garantizado con el CLI 8.3.29.** El compilador lo elige el loader interno del CLI, no tú, y la sintaxis vieja del proyecto es más frágil de lo que parece. Si lo intentas, que sea en una rama que se pueda tirar (§3).""",
"""**Cambiar `node-sass` por Dart Sass funciona con el CLI 8.3.29, y no es neutro.** El CLI cae en `sass` cuando `node-sass` no carga, también sin que nadie lo pida, y el CSS que sale difiere en detalles de redondeo y forma. Es una decisión de proyecto, no un arreglo de tu máquina (§3)."""),
("""- **dart-sass sobre el CLI 8.3.29: sin verificar.** La opción C del §3 se declara como experimento porque no está comprobado si el `sass-loader` que arrastra `build-angular` acepta el cambio. Quien lo pruebe en una rama y lo documente cierra una pregunta que el curso arrastra desde **A02** → ejercicio 🔥 de la **Fase 0** o decisión de proyecto.""",
"""- **Quitar `node-sass` del manifiesto.** La opción C del §3 está verificada sobre la base del proyecto: sin `node-sass`, arm64 instala sin compilar y el contenedor de **A13 §6** dejaría de necesitar `python2`. El curso lo mantiene porque **A02** está escrito sobre él; pasar a Dart Sass toca A02, **A03 §8.1** y A13, y obliga a revisar las 30 reglas que cambian → decisión de proyecto."""),
],
"a02-bootstrap-sass.md": [
("""el cambio a dart-sass declarado como **experimento sin verificar** sobre el CLI 8""",
"""el cambio a dart-sass, que con el CLI 8 funciona y se verificó, pero es una decisión de proyecto"""),
],
}
for f, pares in E.items():
    p = os.path.join(C, f)
    t = open(p, encoding="utf-8").read()
    for i, (a, b) in enumerate(pares, 1):
        n = t.count(a)
        if n != 1:
            sys.exit(f"{f} edición {i}: aparece {n} veces")
        t = t.replace(a, b)
    open(p, "w", encoding="utf-8").write(t)
    print(f"{f}: {len(pares)} ediciones")
