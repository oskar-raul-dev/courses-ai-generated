# Docker Legacy Node - Idea del Curso, Filosofía y Estilo Editorial

## ¿Qué es este proyecto?

Este proyecto busca crear una guía extremadamente detallada para aprender a construir y utilizar imágenes Docker destinadas a ejecutar aplicaciones JavaScript legacy utilizando versiones antiguas de Node.js.

La idea principal es resolver un problema muy común:

Muchos proyectos empresariales desarrollados entre 2017 y 2020 dependen de tecnologías que actualmente son difíciles de instalar de forma nativa en sistemas operativos modernos.

Por ejemplo:

- Vue 2
- Angular 7
- Angular 8
- Angular 9
- AngularJS
- React 16
- Primeras versiones de Svelte
- Webpack 3
- Webpack 4
- Babel clásico
- TypeScript 2.x
- TypeScript 3.x

Además, estos proyectos suelen depender de versiones antiguas de:

- Node.js
- npm
- Python
- node-gyp
- Compiladores nativos

La situación se vuelve especialmente compleja en:

- Windows 11
- macOS Apple Silicon (M1, M2, M3, M4)
- Distribuciones Linux modernas

El objetivo del curso es encapsular completamente ese entorno dentro de una imagen Docker basada en Debian, permitiendo ejecutar proyectos legacy de forma reproducible y consistente. Esta idea está alineada con el laboratorio descrito en la referencia base del proyecto. 【1-101bf3】

---

# Objetivos del curso

Al finalizar el tutorial el estudiante debería ser capaz de:

- Comprender qué es la contenedorización.
- Comprender qué es Docker.
- Comprender qué es Podman.
- Entender la diferencia entre imagen y contenedor.
- Construir imágenes Docker desde cero.
- Leer y modificar Dockerfiles.
- Crear imágenes personalizadas basadas en Debian.
- Instalar Node.js dentro de una imagen.
- Instalar herramientas de compilación.
- Ejecutar aplicaciones Node.js dentro de contenedores.
- Conectar proyectos mediante volúmenes.
- Trabajar con VS Code Dev Containers.
- Ejecutar proyectos legacy sin instalar Node localmente.
- Entender los problemas típicos de compatibilidad de proyectos antiguos.

Más importante aún:

El estudiante deberá comprender qué está pasando internamente en cada paso.

No se busca copiar y pegar comandos.

Se busca entender.

---

# Público objetivo

El curso está diseñado para:

## Estudiantes de informática

Personas que están aprendiendo:

- Sistemas operativos
- Desarrollo web
- DevOps
- Infraestructura

## Desarrolladores Junior

Personas que:

- Nunca han utilizado Docker
- Han escuchado hablar de contenedores
- Se sienten incómodos con Linux
- Necesitan trabajar con proyectos heredados

## Desarrolladores Frontend

Personas que trabajan con:

- Vue
- Angular
- React
- TypeScript

y necesitan ejecutar versiones antiguas de esos frameworks.

## Desarrolladores Backend

Que necesitan comprender entornos de desarrollo reproducibles.

## Ingenieros de Software

Que desean comprender qué sucede detrás de herramientas modernas como:

- Dev Containers
- GitHub Codespaces
- CI/CD
- Build Pipelines

---

# Filosofía de enseñanza

## Regla principal

Nunca asumir conocimientos previos.

Aunque el lector sea un arquitecto de software con veinte años de experiencia, cada concepto será explicado desde cero.

No porque el lector sea incapaz.

Sino porque:

Las explicaciones detalladas reducen la ambigüedad.

---

# Significado real de "como para un bebé"

Esta expresión NO significa:

- Infantilizar el contenido.
- Eliminar profundidad técnica.
- Simplificar en exceso.

Significa:

Explicar cada decisión de manera tan clara que cualquier persona de IT pueda seguir el razonamiento.

Por ejemplo:

En lugar de decir:

"Instalaremos Debian Slim por ser más ligero."

Se explicará:

- Qué es Debian.
- Qué es una distribución Linux.
- Qué significa Slim.
- Qué paquetes se eliminan.
- Qué ventajas aporta.
- Qué desventajas introduce.
- Por qué se eligió frente a otras alternativas.

Cada decisión deberá responder la pregunta:

"¿Por qué estamos haciendo esto?"

---

# Filosofía técnica

## Aprender Docker de verdad

El curso NO utilizará inicialmente:

- Docker Compose
- Kubernetes
- Helm
- Soluciones automáticas

No porque sean malas herramientas.

Sino porque ocultan conceptos fundamentales.

El estudiante primero aprenderá:

- docker build
- docker run
- docker exec
- docker image
- docker container
- docker volume

Cuando estos conceptos sean comprendidos, las capas superiores resultarán mucho más fáciles de aprender.

---

# Principio de transparencia

Cada comando deberá explicarse.

Ejemplo:

```bash
docker run -it --rm imagen