# 📌 Pendientes a futuro: la hoja de verificación al tomar el curso
## Laboratorio de contenedores y Kubernetes local

> **Qué es este documento:** la hoja de trabajo de la pasada que cierra el curso: el autor lo toma
> como lector, desde cero, en cada sistema, monta todos los contenedores y rehace todas las pruebas.
> No se cita desde el curso.
> **Fecha:** 05/10/2026. Ese día la redacción quedó cerrada: `verificar-corpus.py` sale en 0 errores y
> 0 avisos en sus dos modos, y las 44 decisiones están en ✅.
> **19/10/2026 — Publicado antes de la pasada (D45).** Lo que este documento pedía antes de publicar
> pasa a ser **accionable del curso publicado**: la lista y su plan de cierre en macOS están en
> [§ Accionables](#-accionables-del-curso-publicado-d45). Lo que corrija la pasada entra como edición.

La verificación de la producción fue **la del autor**: macOS arm64, comandos corridos por las
sesiones de escritura, con `src/lab/` ya armado al lado. Esa verificación prueba que el laboratorio
funciona; no prueba que las fases, leídas en orden por alguien que empieza de cero, lleven a que
funcione. Eso solo lo prueba tomar el curso, y en Windows 11 y Linux esa pasada es además la primera.

---

## 🧭 Las reglas de la pasada

1. **Desde cero y como lector.** La máquina arranca sin nada del curso: sin la máquina de Podman (se
   borró el 05/10/2026), sin clusters, sin imágenes `lab/*`. Se instala desde `a01`, sin atajos, y
   se trabaja en un repositorio propio, como manda `00-convencion-de-git-y-tags.md`. El `src/lab/`
   del curso solo se usa para compararse: si se copia de ahí, la prueba deja de valer.
2. **Toda diferencia es un hallazgo.** Va en
   [`verificacion-de-laboratorio/hallazgos.md`](verificacion-de-laboratorio/hallazgos.md) desde H271,
   con el mismo formato (fecha, log en `logs/`, documento que cambia), y la corrección pasa del
   hallazgo al documento, nunca al revés. La marca *"no verificado por el autor"* se quita solo
   donde se corrió de verdad.
3. **Las cifras no se pisan.** Un número propio dentro de la variación ya medida deja la cifra
   publicada como está; uno fuera la corrige, con la máquina declarada. Lo de Windows y Linux entra
   como filas nuevas en `BENCHMARKS.md`, no en lugar de las de macOS.
4. **El orden.** Primero una pasada completa en macOS, que valida las instrucciones; después Windows
   11 y Linux, como mínimo hasta la F07, que es donde el host pesa. De la Parte II en adelante todo
   corre dentro del cluster y diverge poco.

En cada fase, lo mínimo es lo mismo: los comandos del recorrido dan la salida publicada (o una
equivalente), la suite del paso pasa (`task conformance`), los incidentes que la fase reserva se
rompen y se arreglan con `task inc:break|fix`, y el tag de la fase coincide con lo que quedó.

---

## 🍎 La pasada en macOS: lo que pide atención por tramo

| Tramo | Además de lo de cada fase | Cierra |
|---|---|---|
| F00 + `a01` | Instalación completa desde `a01`, incluido Podman con su instalador oficial y su máquina de 4 GiB. Las versiones instaladas contra las fijadas en `a01` | — |
| F01–F02 + `a16` | El patrimonio entero con el perfil `legacy` (Contingencia, el portal, la Braqui y su aviso de traslados), y la suite G0 | — |
| F03–F05 | B-04 y B-05 con el arnés de `measure.py`, en la VM de 4 GiB | — |
| F06–F07 | Los dos clusters de kind; B-07. Si se prueba el bloque opcional con el Kubernetes de Docker Desktop: al apagarlo, confirmar que no quedan corriendo `desktop-control-plane`, `kind-registry-mirror` ni `kind-cloud-provider`. En la producción quedaron huérfanos, y si se repite, va a `a02` y a la F07 | — |
| `a01` | **B-00 de nuevo**, ahora sin el Kubernetes de Docker Desktop, que en la producción estuvo encendido al menos desde T8 (H155) | H155; B-00 en `BENCHMARKS.md`, `a01`, contrato §5, F17 §5.5 |
| F08–F16 | Los incidentes 05–17; B-12 y B-16 | — |
| F17–F18 | La observabilidad pieza por pieza, sin construir con todo encendido: con 4 GiB, trazas + Prometheus + Grafana + el agente de Java ahogan la VM | — |
| F19 | **La CA en el navegador**: con la puerta en 8443, el navegador confía sin advertencias. La CA ya está en el llavero `login` (H270) | H174 y H270; `a01` (la CA) y F19 §5.3 |
| F20–F21 | Los incidentes 18–26; k9s contra el cluster (`a04`) | — |
| F22–F26 | Caos, B-23, la saga, la coreografía y el outbox; NATS con `task bus:on` | — |
| F27 | El proyecto final con su rúbrica | — |
| Apéndices 🔥 | `a06`–`a15`, opcionales: cada uno instala y retira lo suyo | — |
| Al terminar | **Quitar la CA** con el paso 4 de `a01` (`delete-certificate -Z <SHA-1>`, H269) y probar la variante del llavero del sistema que la receta nombra. Bajar los clusters y el compose con sus tareas (`task cluster:down`, `task legacy:down`) y decidir si la máquina de Podman se queda | la sección de la CA de `a01` |

---

## 🪟🐧 Windows 11 y Linux

Las instrucciones de los dos sistemas están escritas contra la documentación oficial y marcadas *"no
verificado por el autor"* en el README, `0-ESTRUCTURA-CURSO.md`, F00–F03, F05, F07, F10, `a01`,
`a02`, `a03`, `a05`, `a06`, `a07`, `a14`, `a16` y el cuaderno.

- **Hasta la F07, como mínimo:** instalación desde `a01`, los dos motores, el patrimonio, los dos
  clusters de kind y `task images:load`. Es donde el host decide: rutas, shells, permisos, la VM o
  WSL2, el proxy de la empresa (incidente 27).
- **Las mediciones** B-00, B-04, B-05 y B-07, como filas nuevas con su máquina.
- **La CA del laboratorio**, con la receta de cada sistema en `a01`, si se llega a la F19.
- **Al cerrar:** se quita la marca solo donde se ejecutó, y `a02` suma los problemas que aparezcan.

---

## 🔁 Mantenimiento, fuera de la pasada

- **La versión del nodo de kind.** D32 lo fijó en Kubernetes 1.36 porque Envoy Gateway 1.9 no soporta
  1.37. Cuando salga una versión que lo soporte, se reabre D32 y se reverifica el camino base; las
  versiones viven solo en `a01`, así que el cambio empieza allí.
- **La publicación (etapa E9).** Cerrada por D45 el 19/10/2026: se publica ya. `verificar-corpus.py
  --publicacion` sale limpio y ningún enlace relativo sale del curso. Lo que queda (el repositorio
  público, sin tags por D46) es O5, abajo.

---

## 📋 Accionables del curso publicado (D45)

El curso salió el 19/10/2026 con lo no ejecutado declarado al lector. Lo que sigue es lo que falta
para quitar esas marcas, repartido entre lo que **puede ejecutar una sesión** en esta Mac y lo que
**solo puede hacer el autor**. Casi todo lo abierto es del perfil de Podman o de máquinas que no son
esta; Windows y Linux quedan fuera de este plan.

### Lo que puede ejecutar una sesión en macOS

| ID | Qué | Necesita | Cierra |
|---|---|---|---|
| ~~**A1**~~ | ~~El repositorio de referencia con sus tags~~. **Retirada por D46** (19/10/2026): el curso ya no promete un repositorio del curso con tags; la referencia es el `src/lab/` final y los incidentes salen de `task inc:break\|fix` | — | — |
| ~~**A2**~~ | ~~**B-00 sin el Kubernetes de Docker Desktop**~~. **Hecha en C1 el 20/10/2026** (H271–H273): `minimo` y `lab` reprodujeron dentro del 1 % y se dejan; la columna de Docker de `legacy` se corrigió con las cifras del 20/10. H155 cerrado salvo su sexta entrega, la observabilidad pieza por pieza de la F17 §5.5, que es trabajo de C2. La columna de Podman, en A4 | — | — |
| ~~**A3**~~ | ~~**La pasada en macOS con Docker**~~. **Hecha:** F00–F07 en C1 (20–21/10/2026, H271–H288), F08–F27 y los apéndices 🔥 en C2 (22–24/10/2026, H289–H371) y lo pendiente en C2-bis (H372–H375). Sin ejecutar, por decisión: la compilación nativa de `a08` y las apuestas de la F15 §7 (piden ampliar la VM) | — | — |
| ~~**A4**~~ | ~~**El perfil de Podman**~~. **Hecha en C3 el 24/10/2026** (H379–H394): la máquina, F03, F05 (§5.5 corregida), B-05, F07 y B-07 (minikube corregido), B-00 de Podman (`lab` corregida), B-12 y Testcontainers (cuatro correcciones a `test:pricing` y `main_test.go`), y con los dos motores F00 §4.6, F05 §9 (el contexto que kind borra) y F03 §5.5. B-04 no aplica: solo publica Docker. Sin marcas de Podman en macOS pendientes | — | — |
| **A5** | **La versión del nodo de kind** (D32): ver si una versión de Envoy Gateway ya soporta Kubernetes 1.37. **Consultado el 19/10/2026:** ninguna publicada; solo la fila `latest` de la matriz de compatibilidad (la rama de desarrollo) lista 1.37, y la 1.10 tiene fecha prevista el 29/10/2026. D32 sigue; volver a mirar cuando salga la 1.10 | solo documentación; si la hay, reabre D32 y pide A3 desde F07 | D32 |

### Lo que solo puede hacer el autor

| ID | Qué | Por qué no la sesión |
|---|---|---|
| ~~**O1**~~ | ~~**La CA en el navegador**~~. **Hecha por el autor el 24/10/2026** (H376): Chrome confía sin advertencias en la puerta del 8443 | es una comprobación visual en el navegador |
| ~~**O2**~~ | ~~**Quitar la CA**~~. **Hecha el 24/10/2026** (H377): paso 4 de `a01` en el llavero `login` y la variante del sistema, instalada, comprobada y quitada | — |
| ~~**O3**~~ | ~~**Decidir si la máquina de Podman se queda** al cerrar A4~~. **Decidido el 24/10/2026:** se queda; el autor vacía sus imágenes y contenedores | — |
| **O4** | **Windows 11 y Linux**, según la sección de arriba | no son esta máquina |
| **O5** | **El repositorio público**: crearlo sin `prompts/`, sin tags (D46) | git y la publicación los maneja el autor |

### 🧭 El plan de cierre en macOS

Las tandas van en este orden porque Docker Desktop está en uso: lo que lo necesita libre va junto, y
lo que pide cerrarlo va aparte. Cada tanda abre su directorio con `python3 zz-code/nuevo.py
lab-docker-kubernetes`, anota sus hallazgos desde H271 con su log en
`verificacion-de-laboratorio/logs/`, y para al cerrar para que el autor la revise.

1. **C0 · Sin máquina (cuando quiera el autor).** A5: leer las notas de versión de Envoy Gateway y de
   kind. Si nada cambió, queda anotado con la fecha; si cambió, A3 empieza con D32 reabierta.
2. **C1 · Docker Desktop libre y dedicado.** Primero A2, porque es la única que exige la máquina sin
   otras cargas; después A3 de F00 a F07 en un repositorio nuevo, con los tags `fase-NN-<slug>` de esas
   fases, como los haría el lector. Al cerrar, `task cluster:down` y `task legacy:down`.
3. **C2 · Docker Desktop libre.** A3 de F08 a F27 y los apéndices 🔥, por tramos de la tabla, con
   los tags `fase-NN-<slug>` del repositorio de la pasada. Termina con el `diff` vacío contra `src/lab/`
   del curso; si no da vacío, cada diferencia es un hallazgo.
4. **C3 · Docker Desktop cerrado.** El autor instala Podman y cierra Docker Desktop; la sesión hace A4.
   Al terminar, el autor decide O3 y vuelve a abrir Docker Desktop.
5. **C4 · El autor.** O1 con el laboratorio de C2 todavía arriba, después O2, y O5. O4 queda para
   cuando haya máquinas.

Lo que la pasada corrija en el curso publicado entra como edición: la marca *"no verificado por el
autor"* se quita solo donde se corrió de verdad.
