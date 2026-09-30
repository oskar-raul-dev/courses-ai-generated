# 🖥️ Ideas para un curso de C++ de escritorio en Windows — notas de exploración

> **Qué es esto:** una propuesta de forma para un curso *"C++ para desarrolladores Java senior"*
> orientado a aplicaciones de escritorio en Windows. No es un plan aprobado: las decisiones
> provisionales están marcadas como tales.
> **Fecha:** 29 de septiembre de 2026
> **Contexto:** en `cursos-algoritmos-lenguajes/` ya existen C#, Go y Python para Java devs, y en
> `propuestas-cursos/ideas-rust.md` está la exploración de Rust. El panorama general de lenguajes
> candidatos está en [`ideas-lenguajes-para-java-devs.md`](ideas-lenguajes-para-java-devs.md).
> **Estado:** borrador de discusión. Ninguna versión está fijada y ningún número está medido.

Hay una idea que ordena el documento, y conviene ponerla primero porque es la que evita que el
curso duplique algo que ya existe:

> 🧠 **El curso de C# ya responde "¿cómo hago una aplicación de escritorio en Windows?". Su bloque
> C (fases 12–14) mide WinForms, WPF, WinUI 3 y Blazor Hybrid, y firma un veredicto. Un curso de
> C++ de escritorio solo se justifica si trabaja donde ese veredicto no alcanza: cuando la memoria,
> el tiempo de cuadro, el hardware o treinta años de código C++ heredado no dejan elegir.**

---

## 1. 🧭 El criterio: dónde C++ sigue siendo la respuesta en el escritorio

Si el curso construye un formulario con una grilla contra una base de datos, pierde contra C# en
todas las columnas menos en RSS, y el alumno concluye, con razón, que C++ no valía la pena. Es el
mismo error que `ideas-rust.md` señala sobre Rust y las APIs REST: elegir el peor día del lenguaje
como escenario.

El escritorio en C++ tiene un nicho concreto y bastante estable. Todo esto es **apreciación de
mercado sin verificar**:

- **Software técnico con datos grandes en pantalla.** CAD/CAM, topografía, SIG, imagen médica,
  metrología, simulación. Millones de puntos que hay que pintar a 60 cuadros por segundo, donde
  un GC que pausa o un modelo de objetos con 16 bytes de cabecera por punto son la diferencia.
- **Audio y video en tiempo real.** Estaciones de audio, plugins VST3, edición de video. El hilo
  de audio no puede asignar memoria ni tomar un lock: es la frontera más dura del escritorio.
- **Control de hardware e instrumentos.** HMI industrial, equipos de laboratorio, lectores y
  periféricos con SDK del fabricante en C o C++. El SDK dicta el lenguaje.
- **Herramientas internas de motores de juego y visualización.** Editores, perfiladores, visores
  de escenas: Dear ImGui sobre Direct3D.
- **El mantenimiento del MFC heredado.** Probablemente el mayor volumen de empleo real de todo el
  nicho y el menos glamoroso: aplicaciones de 1998–2010 que facturan y que nadie va a reescribir.
- **Extensiones del propio Windows.** Extensiones del shell, proveedores COM, servicios. Ahí el
  contrato es COM y el lenguaje natural sigue siendo C++.

> 🧭 **La regla que mantiene honesto al curso:** cada proyecto existe porque C# o Java *ahí*
> pierden, y el proyecto lo mide. Y el curso tiene que incluir un proyecto donde C++ pierde
> claramente, para poder firmar el veredicto de "no lo uses aquí".

---

## 2. 👤 El alumno y su acento

Es el mismo Java senior de los otros cursos: ocho años o más, sabe concurrencia, pruebas y build.
Lo que tiene que desaprender en C++ es más que en C#, Go o Python, porque la JVM le resolvía en
silencio cosas que C++ no resuelve por nadie. El curso se sostiene en esos reflejos 🪞:

| El instinto de Java | Por qué falla en C++ |
|---|---|
| "Los objetos se crean con `new`" | En C++ el valor en el stack es lo normal y `new` desnudo es un olor. El dueño se declara con `std::unique_ptr` |
| "`shared_ptr` es una referencia de Java" | Es conteo de referencias con incremento atómico: tiene costo, no rompe ciclos y oculta de quién es el objeto |
| "Si compila y pasa las pruebas, está bien" | El comportamiento indefinido puede pasar las pruebas y romperse con otro nivel de optimización. ASan y UBSan no son opcionales |
| "Los genéricos son genéricos" | Las plantillas se instancian por tipo, no se borran: el binario crece, los errores se alargan y los *concepts* son el contrato |
| "Las excepciones son el mecanismo de error" | En las fronteras de DLL, COM y el hilo de audio no cruzan. Ahí mandan `HRESULT`, `std::expected` y los códigos de error |
| "Un `.jar` es un `.jar`" | Una DLL de C++ comparte un ABI frágil: compilador, runtime (`/MD` o `/MT`) y convención de llamada tienen que coincidir |
| "El JIT optimiza por mí" | La disposición en memoria (arreglo de estructuras o estructura de arreglos) decide el rendimiento antes que cualquier optimizador |
| "El hilo de UI es el EDT de Swing" | Se parece, pero el bucle de mensajes de Win32 es tuyo: reentrancia, `PostMessage` y apartamentos COM incluidos |

🩻 **Lo que sí funciona igual** tiene peso y hay que decirlo: orientación a objetos, diseño por
interfaces, pruebas unitarias con dobles, el modelo de memoria de concurrencia (que es primo
directo del JMM) y casi todo el criterio de arquitectura.

---

## 3. 🏗️ La empresa (provisional)

Todos los cursos del repositorio construyen para una empresa con historia propia. Una candidata,
para descartar o ajustar:

**Geodesia Austral**, de Santiago, fundada en 1996, vende software de topografía a constructoras y
mineras de cuatro países. Su producto, **Trazo**, es una aplicación MFC de unas 380.000 líneas
escritas en C++98 entre 1999 y 2011. Lee estaciones totales y receptores GNSS por serial y USB con
el SDK del fabricante, calcula poligonales y dibuja nubes de puntos con GDI.

Lo que duele hoy, y alimenta los proyectos:

- Las nubes de puntos de los drones traen 50 millones de puntos y GDI congela la aplicación.
- En monitores 4K todo se ve borroso, porque Trazo no sabe qué es el DPI.
- Se cae en campo sin dejar rastro: no hay minidumps ni servidor de símbolos.
- Solo compila en una máquina virtual con Visual Studio 2010 que nadie se atreve a apagar.
- Hace tres años un consultor propuso reescribirla en Electron. La propuesta sigue en un cajón.

La pregunta del curso rima con la de C# a propósito, pero no es la misma: **¿qué parte de Trazo
necesita de verdad C++, qué parte se moderniza sin salir de C++, y qué parte debería irse a C#?**

---

## 4. 🗺️ Forma posible: seis bloques, ~22 fases

Estimación provisional de tamaño: de 100 a 130 horas, en línea con el curso de C#.

**Bloque 0 · el ambiente (00).** Visual Studio 2026 con MSVC y clang-cl, CMake con presets, vcpkg
en modo manifiesto, AddressSanitizer en MSVC, Google Benchmark y GoogleTest. La fase no es un
setup: de ella sale el arnés de medición, y se enseña que en C++ **no hay un Maven**. El mapa
Maven → CMake + vcpkg es el primer diccionario.

**Bloque A · el lenguaje moderno (01–07).** Valores, copia y *move*; RAII y propiedad
(`unique_ptr`, `shared_ptr`, `weak_ptr`) frente al GC; referencias, tiempos de vida y
comportamiento indefinido con los sanitizers encendidos; plantillas y *concepts* frente a los
genéricos borrados; contenedores, algoritmos y *ranges* frente a Streams; errores con excepciones y
`std::expected`; el modelo de compilación (encabezados, módulos de C++20 —MSVC tiene el soporte
más maduro— y ABI).

**Bloque B · Windows nativo (08–12).** La ventana y el bucle de mensajes de Win32 desde cero;
Unicode en Windows (`wchar_t`, UTF-16, y el manifiesto UTF-8); COM y conteo de referencias con
WIL y `ComPtr`; DPI por monitor y dibujo con Direct2D y DirectWrite; hilos de trabajo y el hilo de
UI. Es el bloque que ningún curso de C# enseña, y el que explica todo lo que viene después.

**Bloque C ⭐ · el MFC heredado (13–15).** El curso escribe el trozo de Trazo de 1999 que después
va a tocar: compilarlo en Visual Studio 2026, caracterizarlo con pruebas antes de entenderlo,
hacerlo consciente del DPI y cambiar GDI por Direct2D en la vista de puntos sin reescribir el
resto. Es el corazón, y el equivalente del bloque B del curso de C#.

**Bloque D · los frameworks de hoy (16–18).** Qt 6 (Widgets y QML) con su licencia como parte del
costo; Dear ImGui para herramientas internas; WinUI 3 desde C++/WinRT. Cada uno construye la misma
vista y cierra con una tabla de decisión.

**Bloque E · la frontera y la operación (19–21).** La biblioteca de cálculo de Trazo expuesta como
DLL con API en C, consumida desde C# (P/Invoke) y desde Java (FFM/Panama con `jextract`);
empaquetado, firma de código, minidumps, servidor de símbolos y WER; perfilado con ETW y Windows
Performance Analyzer, y disposición en memoria amigable con la caché.

**Cierre (22).** 🥊 El duelo: la misma vista de nube de puntos en C++ con Direct2D, en C# con WPF y
en Java con JavaFX, midiendo arranque, RSS, tiempo por cuadro con 1, 10 y 50 millones de puntos y
horas de desarrollo. Y el ⚖️ veredicto: qué parte de Trazo no debió quedarse en C++.

> 💡 **El bloque E es probablemente el más valioso para el público del repositorio.** La vía de
> adopción realista de C++ en una empresa Java no es reescribir la aplicación: es aislar el 3 % que
> duele en una DLL con API en C y llamarla desde la JVM. Desde Java 22, con FFM ya estable, eso se
> hace sin JNI.

---

## 5. 🧱 Proyectos ancla (provisionales)

1. **Trazo heredado.** El MFC de 1999 escrito por el curso, que se compila, se caracteriza y se
   moderniza a lo largo de los bloques C y E.
2. **`trazo-core`.** La biblioteca de cálculo (poligonales, transformaciones de coordenadas)
   extraída del MFC, con API en C, pruebas y benchmarks. La consumen los proyectos 1, 3 y el duelo.
3. **El visor de nubes de puntos.** Direct2D primero y Direct3D 11 después, con la medición de
   tiempo por cuadro como criterio de aceptación.
4. **El panel del instrumento.** Una herramienta interna en Dear ImGui que lee un simulador de
   estación total por serial (un puerto virtual), con hilo de lectura, cola sin bloqueo y UI a 60
   cuadros por segundo.
5. **El formulario que no debió ser C++.** Un ABM de clientes en Qt Widgets, medido contra el
   mismo formulario en WPF. Existe para perder, y para que el veredicto tenga dónde apoyarse.

---

## 6. ⚖️ Riesgos y cosas que hay que verificar antes de promover

- **El requisito de Windows es duro**, igual que en el curso de C#: MFC, Win32, COM, Direct2D y
  WinUI no existen fuera de Windows. Qt y ImGui sí son multiplataforma, pero el curso se toma en
  Windows 11.
- **La licencia de Qt** (LGPLv3 o comercial) cambia el costo de un producto cerrado. Hay que
  documentarla con las condiciones vigentes, no de memoria.
- **El estado de C++/WinRT.** Hay que confirmar en la documentación oficial si sigue en desarrollo
  activo o si está en modo de mantenimiento, porque eso decide si WinUI 3 en C++ merece una fase
  completa o solo una sección.
- **Las versiones:** MSVC, CMake, vcpkg, Qt y el SDK de Windows se fijan en la fase 00 con fecha,
  como en el curso de C#.
- **Cada "C++ gana en X"** de este documento está sin medir, y no puede entrar en una fase hasta
  que exista en un `BENCHMARKS.md` con su arnés.
- **El tamaño del bloque A.** C++ moderno para alguien que viene de Java es fácilmente la mitad del
  curso si no se recorta con disciplina. El criterio de recorte: solo lo que el proyecto usa.

---

## 7. 🧵 Preguntas abiertas

1. ¿El curso asume que el alumno ya pasó por el de C#? Si lo asume, la fase 18 (WinUI 3) y el duelo
   pueden apoyarse en el bloque C de C# en vez de repetirlo.
2. ¿MFC es el corazón del curso, o es un bloque más? Es donde está el empleo, pero también es lo
   que menos atrae a quien elige el curso.
3. ¿Audio en tiempo real (JUCE, VST3) entra como apéndice o se queda fuera? Es el nicho con las
   restricciones más didácticas, pero es otro dominio.
4. ¿La DLL con FFM/Panama es un apéndice o el capstone? Es lo que más le sirve a un Java dev que no
   va a cambiar de trabajo.
5. ¿Zig entra como apéndice de toolchain (`zig cc` para compilación cruzada)? Ver el documento de
   panorama.
