# 🗺️ Próximos cursos "for Java devs" — panorama de lenguajes candidatos

> **Qué es esto:** una exploración de qué otros cursos de cruce de lenguaje tendrían sentido en
> `cursos-algoritmos-lenguajes/`, junto a C#, Go y Python. No es un plan: es una lista priorizada
> con su razonamiento, para decidir qué se promueve.
> **Fecha:** 29 de septiembre de 2026
> **Documentos hermanos:** [`ideas-rust.md`](ideas-rust.md) (el curso grande de Rust),
> [`ideas-rust-herramientas.md`](ideas-rust-herramientas.md) (la ruta corta de herramientas) e
> [`ideas-cpp-escritorio-windows.md`](ideas-cpp-escritorio-windows.md) (C++, desarrollado aparte).
> **Estado:** borrador. Todo lo que dice "mercado" es **apreciación sin verificar**: antes de
> promover cualquier curso hay que contrastarlo con datos de ofertas.

Hay una idea que ordena la lista:

> 🧠 **Un curso de cruce se sostiene cuando el lenguaje tiene un terreno donde gana frente a Java y
> ese terreno enseña un modelo de acceso que el alumno no conoce.** Si solo gana en gusto, es un
> tutorial de sintaxis. Si gana pero el terreno no da empleo, es un pasatiempo. Hacen falta las
> dos cosas.

---

## 1. 🧭 El criterio, en tres preguntas

Cada candidato se evalúa con las mismas tres preguntas, que salen del principio editorial del
repositorio:

1. **¿Dónde gana frente a Java, con un número?** No "es más elegante": arranque, memoria, tiempo
   de desarrollo, latencia de cola o acceso a una plataforma que la JVM no alcanza.
2. **¿Qué modelo nuevo enseña?** El bucle de eventos, los actores, la memoria manual, la
   convención sobre configuración. Es lo que hace que el curso no sea una traducción de sintaxis.
3. **¿Hay mercado para alguien que ya sabe Java?** Plazas reales, no entusiasmo de la comunidad.
   Y, además, **¿se solapa con un curso que ya existe?**

---

## 2. 📊 El resumen

| Lenguaje | Dónde gana frente a Java | Modelo nuevo que enseña | Mercado (apreciación) | Solapamiento | Prioridad |
|---|---|---|---|---|---|
| **C++ (escritorio Windows)** | Memoria, tiempo por cuadro, hardware, código heredado | Propiedad manual, RAII, bucle de mensajes, ABI | Alto y estable, poco visible | Parcial con el bloque C de C# | ⭐ Alta |
| **TypeScript / Node** | Arranque, un solo lenguaje de punta a punta, ecosistema | Bucle de eventos de un hilo | Muy alto | Bajo (los cursos de React y Angular son de frontend) | ⭐ Alta |
| **Kotlin** | Menos ceremonia en la misma JVM, Android | Corrutinas y concurrencia estructurada, nulabilidad en el tipo | Alto, pegado a Java | Alto con Java mismo | Media, en formato corto |
| **Ruby (Rails)** | Velocidad de desarrollo de un CRUD de negocio | Convención sobre configuración, Active Record, metaprogramación | Medio, en contracción, mucho heredado | Medio con Python | Media |
| **Elixir** | Concurrencia masiva y tolerancia a fallos | Actores de la BEAM, "déjalo caer", supervisión | Bajo pero bien pagado | Ninguno | Media-baja |
| **Rust (utilitarios y CLIs)** | Arranque, binario sin runtime, latencia sin pausas de GC | Propiedad verificada por el compilador, enums como lenguaje | Medio y creciendo | Ninguno | ⭐ Alta, en ruta corta |
| **Zig** | Compilación cruzada de C/C++, control total de la memoria | Asignadores explícitos, `comptime` | Muy bajo | Con C++ y Rust | Baja como curso, alta como apéndice |
| **Scala** | Datos (Spark) y sistemas de tipos avanzados | Programación funcional tipada | En contracción | Alto con Kotlin y Java | ❌ Descartado |

---

## 3. 🖥️ C++ — el pendiente del escritorio en Windows

Está desarrollado en [`ideas-cpp-escritorio-windows.md`](ideas-cpp-escritorio-windows.md). En
resumen: **no puede competir con el bloque de escritorio del curso de C#**, así que trabaja donde
ese veredicto no alcanza. Eso incluye software técnico con datos grandes en pantalla, control de
hardware, MFC heredado y la DLL nativa que se llama desde la JVM con FFM/Panama. Propone una
empresa (Geodesia Austral y su MFC de 380.000 líneas), seis bloques y un duelo final contra WPF y
JavaFX.

---

## 4. 💎 Ruby — el curso honesto es el del monolito heredado

### 4.1 Dónde está el mercado

Ruby tiene un mercado real pero concentrado, y conviene decirlo sin adornos. Casi todo el empleo
está en **Rails**: monolitos de empresas que nacieron entre 2008 y 2016 (en Latinoamérica, muchas
*startups* de esa generación) y un puñado de empresas grandes que siguen apostando por él. Pocas
empresas nuevas eligen Rails hoy frente a TypeScript o Python, así que la oferta tiende a ser
**mantenimiento y evolución de un sistema que ya factura**.

Eso define el curso. Uno que venda Ruby como el lenguaje del futuro miente. Uno que diga *"te
contrataron para un monolito Rails de 2014 y tienes seis meses para hacerte cargo"* es exactamente
lo que ese mercado necesita.

### 4.2 Qué modelo nuevo enseña a un Java dev

- **Convención sobre configuración.** Es lo opuesto a Spring: nada se declara y todo se deduce
  del nombre. El 🪞 más rentable del curso: *"tu instinto dice que lo explícito es más seguro, y en
  Rails lo explícito es lo que rompe las convenciones que el equipo daba por sentadas"*.
- **Active Record frente al *data mapper* de JPA.** El objeto *es* la fila. Los N+1, los *callbacks*
  y los *concerns* son las autopsias ⚰️ naturales.
- **Metaprogramación y clases abiertas.** `method_missing`, *monkey patching* y DSLs. Es lo que hace
  a Rails posible y lo que hace ilegible a un monolito de diez años.
- **El GVL**, que rima con el GIL del curso de Python, e YJIT como la respuesta del rendimiento.

### 4.3 Forma posible

Unas 12–14 fases, más corto que los otros cursos de cruce. Una empresa con un monolito Rails
heredado, versiones de Ruby y Rails fijadas con fecha, y el arco: leer el monolito → caracterizarlo
con pruebas → llevarlo a la versión actual de Rails → medir contra el mismo endpoint en Spring Boot
→ veredicto.

### 4.4 El riesgo

**Solapa con el curso de Python** en todo lo que es "lenguaje dinámico para un Java dev": tipado
dinámico, ceremonia mínima, el lock global del intérprete. Si se promueve, las fases de lenguaje
tienen que ser pocas y remitir al de Python donde el reflejo es el mismo. El valor diferencial es
Rails, no Ruby.

---

## 5. ⚡ Zig — mejor como apéndice que como curso

### 5.1 El diagnóstico

Zig es el lenguaje de nicho más interesante de la lista y el peor candidato para un curso
completo, por dos razones que no dependen del gusto:

- **No ha llegado a 1.0 y rompe compatibilidad entre versiones.** La biblioteca estándar y la API de
  entrada y salida han cambiado de forma incompatible en versiones recientes. Un curso de 100 horas
  escrito hoy tendría fases que no compilan en la próxima versión. En un repositorio que fija
  versiones y verifica todo, eso es costo de mantenimiento permanente.
- **El mercado de empleo es muy pequeño.** Hay proyectos visibles (TigerBeetle, Ghostty, el runtime
  de Bun) y empresas que lo usan como herramienta, pero las plazas de "desarrollador Zig" son
  contadas.

### 5.2 Donde sí aporta, y mucho

**Como toolchain de C y C++.** `zig cc` y `zig c++` compilan de forma cruzada para casi cualquier
destino sin instalar nada más, y hay empresas que lo usan así dentro de sus sistemas de build sin
escribir una sola línea de Zig. Para el curso de C++ es un apéndice natural: *"compila `trazo-core`
para Linux arm64 desde tu Windows, sin máquina virtual"*.

**Como contraste didáctico.** Los asignadores explícitos (cada función que asigna memoria recibe el
asignador como parámetro) y `comptime` enseñan en una tarde lo que C++ esconde. Sirve como
laboratorio corto dentro de C++ o de Rust.

### 5.3 Recomendación

Un **apéndice en el curso de C++** (toolchain) y, si llega a 1.0 y se estabiliza, un **minicurso de
6–8 laboratorios** en `propuestas-cursos/`. No un curso de la familia todavía.

---

## 6. 🦀 Rust — primero como ruta corta de utilitarios y CLIs

Está desarrollado en [`ideas-rust-herramientas.md`](ideas-rust-herramientas.md). El curso se sitúa
donde Rust le gana a Java con números: el arranque de un CLI que se invoca mil veces, un binario sin
runtime y una latencia sin pausas de GC. El hilo son cinco herramientas de uso propio en un
workspace de Cargo: tres CLIs (generador de datos de prueba, filtro de logs, generador de carga) y
dos servicios (un servidor de mocks con reglas sobre JSON y un simulador genérico de pasarela de
pago). Los competidores que el veredicto enfrenta son GraalVM native-image y Go. Es la puerta de
entrada a Rust. El curso grande de infraestructura queda para después, y esta ruta puede
convertirse en su bloque de herramientas.

---

## 7. 🟦 Los otros candidatos, en breve

### TypeScript / Node — el de mayor mercado

Es probablemente **el curso con más demanda de toda la lista** y el que menos se ha considerado.
Un Java dev que llega a un backend en Node se encuentra con un solo hilo y un bucle de eventos, y
el 🪞 central se escribe solo: *"tu instinto dice que bloquear un hilo es barato porque hay más;
aquí hay uno"*. NestJS copia deliberadamente la forma de Spring (inyección de dependencias,
decoradores, módulos), lo que da un diccionario bidireccional muy natural. El duelo contra Spring
Boot y el veredicto sobre cuándo Node no aguanta (CPU intensiva, cómputo numérico) están servidos.

### Kotlin — el que menos cruce tiene

Es el lenguaje con más mercado para un Java dev y el que menos necesita un curso de cruce, porque
corre en la misma JVM y con las mismas bibliotecas. Si se hace, que sea **corto y centrado en dos
cosas**: las corrutinas y la concurrencia estructurada medidas contra los hilos virtuales de Java
21+, y la nulabilidad en el sistema de tipos. Android justificaría un curso aparte, pero es otra
familia.

### Elixir — el que mejor encarna el principio del repositorio

Por mercado, es de nicho. Por contenido, **es el que mejor responde a "enseña modelos de acceso,
no productos"**: la BEAM, los procesos ligeros, la supervisión y el "déjalo caer" son un modelo de
concurrencia que ningún otro curso del repositorio toca. Phoenix LiveView es el contraste directo
con el render en servidor de Blazor. Buen candidato para cuando la familia ya tenga los grandes.

### Scala — descartado

Su nicho natural (Spark, sistemas de tipos avanzados) está en contracción, y Kotlin cubre la mayor
parte de lo que un Java dev buscaba en él.

---

## 8. ⚖️ Orden recomendado (provisional)

1. **C++ de escritorio en Windows.** Es el pendiente declarado, completa el arco de escritorio que
   abrió el curso de C# y el bloque de FFM/Panama le sirve a cualquier Java dev.
2. **Rust para utilitarios y CLIs**, ruta corta. Se puede empezar ya, porque las herramientas sirven a
   los demás proyectos desde la primera mitad.
3. **TypeScript / Node para Java devs.** El de más mercado. Conviene verificar primero que no se pisa
   con los cursos de frontend de `cursos-legacy/`.
4. **Ruby on Rails heredado**, corto, apoyado en el curso de Python.
5. **Elixir**, o el curso grande de Rust si la ruta corta deja ganas.
6. **Zig**, como apéndice del curso de C++. Minicurso solo si llega a 1.0.

> 📝 **PHP queda fuera de la lista por decisión del autor:** el lenguaje ya lo domina, y el
> framework lo va a abordar por su cuenta más adelante.

---

## 9. 🧵 Preguntas abiertas

1. ¿La prioridad es mercado (TypeScript, Kotlin) o contenido diferencial (C++, Elixir, Rust)? La
   lista cambia de orden según la respuesta.
2. ¿Ruby vale un curso propio, o un curso de "Rails para quien ya pasó por Python" de 8–10 fases?
3. ¿Los cursos nuevos asumen el de C# o el de Python como prerrequisito, para no repetir fases de
   lenguaje dinámico o de escritorio?
4. ¿Hay que verificar el mercado con datos de ofertas antes de decidir el orden? En este
   repositorio la respuesta coherente es sí.
