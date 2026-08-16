# 🐳 Propuesta: complemento Docker Legacy Node

Propuesta de material de apoyo para un problema muy concreto: **correr Node.js
antiguo (10–14) dentro de contenedores, en máquinas de desarrollo modernas** —
macOS Apple Silicon (arm64) y Windows 11 (x86_64). El eje es la fricción de
arquitectura y de libc que aparece cuando el runtime que necesitas nunca tuvo
binarios para el CPU que tienes.

> ⚠️ Borrador. Ver el [README del directorio de propuestas](../README.md) para
> entender qué implica ese estado.

## 🎯 Alcance

El material se organiza en dos bloques que comparten origen pero se leen por
separado.

### Bloque A — Node legacy en contenedores

Cubre la cadena completa de decisiones:

- **Fundamentos de libc:** qué es glibc, qué es musl, en qué se diferencian de
  verdad y por qué la distinción decide si un `npm install` funciona o no.
- **El catálogo de paquetes que explotan:** node-sass, phantomjs, bcrypt, sqlite3 y
  compañía — por qué fallan sobre musl, qué prebuilds existen y cuáles son las
  salidas viables para cada uno.
- **Estrategias de ejecución comparadas:** traducción de binarios x86_64 vs.
  emulación QEMU vs. compilar arm64 nativo, con las consecuencias de cada camino
  sobre velocidad, mantenimiento y vida útil.
- **Rendimiento medido:** por qué V8 sufre especialmente bajo emulación y qué
  órdenes de magnitud separan a cada opción.
- **Compilación casi bare-metal:** construir Node desde fuente en Lima (macOS) y
  WSL2 (Windows), flags de `./configure`, caché de compilación y cómo convertir ese
  trabajo manual en un Dockerfile reutilizable.
- **Plantillas listas para copiar:** Dockerfiles desde el caso básico hasta
  multi-stage, multi-arquitectura y entornos con proxy corporativo.

### Bloque B — Ruta de aprendizaje de sistemas

Una extensión opcional para quien quiera bajar un nivel más: la escalera de distros
que obliga a entender lo que hay debajo, sistemas operativos didácticos como
material de estudio, el armado de una máquina física de laboratorio y una guía
práctica de compra de hardware usado en Colombia. Compilar Node desde fuente
funciona como puente natural entre los dos bloques.

## 👥 Público objetivo

Desarrolladores y gente de DevOps que mantiene aplicaciones Node que ya no se
pueden actualizar de golpe, y que necesitan un entorno de desarrollo reproducible en
equipos ARM y x86 al mismo tiempo. Se asume manejo de terminal, Docker a nivel de
uso y noción de qué hace un compilador.

## 🚫 Fuera de alcance

- Enseñar Docker desde cero: contenedores, imágenes, volúmenes y redes se dan por
  conocidos.
- Modernizar o migrar la aplicación Node en sí. Aquí el supuesto de partida es que
  la versión antigua se queda.
- Orquestación, despliegue en producción y CI/CD.
- Runtimes distintos de Node.

## 🗺️ Cómo está organizado

Archivos numerados, pensados para leerse en orden aunque cada uno se sostiene solo.
`00-indice-lectura.md` es la puerta de entrada: trae el mapa completo, los tiempos
estimados por documento y varias rutas de lectura según lo que necesites (desde
"solo quiero que funcione ya" hasta el recorrido completo).

📝 El documento de errata corrige afirmaciones que quedaron en varios documentos
anteriores. Mientras el material siga siendo borrador, esa corrección **no** está
propagada hacia atrás: lee la errata antes de tomar decisiones basadas en los
documentos de estrategia.
