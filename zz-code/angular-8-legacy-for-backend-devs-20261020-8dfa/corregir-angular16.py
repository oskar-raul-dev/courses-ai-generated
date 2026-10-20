#!/usr/bin/env python3
"""Corrige en angular-16 lo que contradicen salidas/kind-rosetta.log (el pod amd64 corre traducido en un Mac)
y salidas/kind-sin-traduccion.log (sin traducción: Error/CrashLoopBackOff, Exit Code 255, y `kubectl logs` dice
`exec … : exec format error`). Uso: python3 -I corregir-angular16.py <curso angular-16>
"""
import os
import sys

C = sys.argv[1]
E = {
"14-casi-prod-kind.md": [
("""**Síntoma:** en un Mac con chip M, el pod entra en `CrashLoopBackOff` inmediatamente y `kubectl describe` no explica por qué.
**Causa:** la imagen se construyó para `amd64` y el nodo es `arm64`.
**Fix mínimo:** reconstruir en la arquitectura del nodo, o construir multi-arquitectura con `docker buildx`.
**Lo que importa:** **el mensaje útil está en `kubectl logs`, no en `kubectl describe`** — dice `exec format error`, que es del kernel y no de Kubernetes. Es el mejor ejemplo del curso de por qué hay que mirar los dos y en qué orden. **A12** lo desarrolla.""",
"""**Síntoma:** la imagen que construiste en tu Mac funciona en tu kind, pero en el cluster de la empresa el pod entra en `CrashLoopBackOff` inmediatamente y `kubectl describe` no explica por qué.
**Causa:** la imagen es `arm64` —la de tu Mac— y los nodos de la empresa son `amd64`, sin nadie que traduzca. En tu kind no lo ves: la máquina virtual de tu runtime traduce lo que no es arm64 (Rosetta, y si no QEMU), así que una imagen de la arquitectura equivocada arranca igual, solo más lenta. En la prueba del curso, un pod con una imagen solo-amd64 quedó `Running` en un kind sobre Docker Desktop.
**Fix mínimo:** construir para la arquitectura del destino (`--platform=linux/amd64`), o multi-arquitectura con `docker buildx`.
**Lo que importa:** **el mensaje útil está en `kubectl logs`, no en `kubectl describe`** — dice `exec /…: exec format error`, que es del kernel y no de Kubernetes; `describe` solo muestra `Exit Code: 255`. Es el mejor ejemplo del curso de por qué hay que mirar los dos y en qué orden. **A12** lo desarrolla."""),
],
"a09-docker-kubernetes.md": [
("""> 💡 **En un Mac con chip M hay un `CrashLoopBackOff` con causa propia**: la imagen está construida para amd64 y el nodo es arm64. `kubectl describe` no lo explica bien y los logs vienen vacíos. Es lo primero que hay que descartar en Apple Silicon, y el diagnóstico completo está en **A12** 🔥.""",
"""> 💡 **Hay un `CrashLoopBackOff` con causa propia cuando el equipo mezcla Macs con chip M y servidores x86**: la imagen se construyó arm64 en un Mac y el nodo es amd64. `kubectl describe` solo da `Exit Code: 255`; el mensaje útil está en los logs: `exec /…: exec format error`. En tu propio kind no aparece, porque la VM de tu runtime traduce la otra arquitectura. El diagnóstico completo está en **A12** 🔥."""),
],
"a12-arm64-m1.md": [
("| arm64 | arm64 | **amd64** | el contenedor no arranca, o arranca emulado y va muy lento |",
 "| arm64 | arm64 | **amd64** | arranca emulado —Rosetta o QEMU, dentro de la VM de tu runtime— y va lento; solo no arranca si la VM no tiene emulación |"),
("""> 🧠 **La segunda fila es la que produce el error más desconcertante del curso**, y llega en la Fase 14: un pod en `CrashLoopBackOff` cuyos logs vienen vacíos y cuyo `kubectl describe` no dice nada sobre arquitecturas. La causa es que la imagen es amd64 y el nodo es arm64, y el mensaje —si llegas a verlo— dice `exec format error`, que no significa nada para nadie la primera vez.""",
"""> 🧠 **La segunda fila esconde el error más desconcertante del curso**, porque en tu Mac no se ve: la imagen de la arquitectura equivocada arranca, traducida. Se ve en el sentido contrario y en otra máquina —una imagen arm64 de tu Mac en un nodo amd64 de la empresa—, en la Fase 14: un pod en `CrashLoopBackOff` cuyo `kubectl describe` solo dice `Exit Code: 255` y cuyos logs dicen `exec /…: exec format error`, que no significa nada para nadie la primera vez."""),
("| `exec format error` al correr un contenedor | imagen amd64 en máquina arm64 | `docker image inspect … --format '{{.Architecture}}'` | reconstruir sin `--platform`, o instalar la emulación |\n| Pod en `CrashLoopBackOff` con logs vacíos en kind | lo mismo, dentro del cluster | inspeccionar la imagen **antes** del `kind load` | reconstruir para arm64 |",
 "| `exec format error` al correr un contenedor | imagen de otra arquitectura en una máquina que no la traduce | `docker image inspect … --format '{{.Architecture}}'` | reconstruir para esa máquina, o activar la emulación del runtime |\n| Pod en `CrashLoopBackOff`, `Exit Code: 255` y `exec format error` en `kubectl logs`, en el cluster de la empresa | imagen arm64 construida en un Mac, en un nodo amd64 | inspeccionar la imagen **antes** de publicarla | reconstruir con `--platform=linux/amd64`, o `buildx` (§4) |\n| La imagen amd64 arranca en tu kind, pero va lenta | la VM de tu runtime la traduce | `docker image inspect` | reconstruir para arm64: en kind, nativo |"),
("""4. 🟡 Provoca el error de la §6 a propósito: carga la imagen amd64 en el cluster de kind de la Fase 14, aplica el Deployment y anota **todo** lo que ves — el estado del pod, la salida de `logs`, la de `logs --previous` y la de `describe`. Escribe después la frase de una línea que le dirías a un compañero para que reconozca este fallo en treinta segundos.""",
"""4. 🟡 Carga la imagen amd64 en el cluster de kind de la Fase 14, aplica el Deployment y anota **todo** lo que ves — el estado del pod, la salida de `logs` y la de `describe`. Vas a ver que arranca: explica en dos líneas qué pieza lo hace posible (§1) y por qué eso esconde el fallo que la misma imagen, al revés, provocaría en un nodo amd64 de la empresa. Escribe después la frase de una línea que le dirías a un compañero para que reconozca ese fallo en treinta segundos (§6)."""),
],
"forense-fase-14.md": [
("""### Paso 3 — El caso sin logs, que en un Mac con chip M es casi siempre el mismo

```bash
kubectl logs certcore-… --previous
# (vacío)

kubectl describe pod certcore-… | grep -A3 "Last State"
```

```
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
```

Logs vacíos, código de salida 1, y ninguna explicación. En un Mac con Apple Silicon, **eso es casi siempre una imagen amd64 en un nodo arm64**:

```bash
docker image inspect certcore:fase-13 --format '{{.Architecture}}'
# amd64          ← y tu nodo es arm64
```

El proceso no llega a ejecutarse, así que no escribe nada. Es un segundo de comprobación y descarta la causa más desconcertante del capítulo. El diagnóstico completo está en **A12** §6.""",
"""### Paso 3 — El caso de la arquitectura, que en tu kind no vas a ver

```bash
kubectl describe pod certcore-… | grep -A3 "Last State"
```

```
    Last State:     Terminated
      Reason:       Error
      Exit Code:    255
```

Código de salida 255 y ninguna explicación en `describe`. El mensaje está en los logs, y es una sola línea:

```bash
kubectl logs certcore-…
# exec /docker-entrypoint.sh: exec format error
```

Es una imagen de otra arquitectura que el nodo, sin nadie que la traduzca: el proceso ni llega a arrancar, y lo único que queda escrito es la queja del kernel. **En tu kind de Apple Silicon no lo vas a ver**: la VM de tu runtime traduce amd64 (Rosetta, y si no QEMU), así que una imagen amd64 arranca, más lenta. Aparece en el cluster de la empresa, con una imagen arm64 construida en un Mac:

```bash
docker image inspect certcore:fase-13 --format '{{.Architecture}}'
# arm64          ← y los nodos de la empresa son amd64
```

Es un segundo de comprobación y descarta la causa más desconcertante del capítulo. El diagnóstico completo está en **A12** §6."""),
("Si coinciden, descarta la arquitectura y quedan dos posibilidades, las dos del **Paso 4**: que el pod ya se reciclara y sus logs se fueran con él, o que nunca escribiera nada por otro motivo.",
 "Si coinciden, descarta la arquitectura; y si los logs vienen vacíos, quedan dos posibilidades, las dos del **Paso 4**: que el pod ya se reciclara y sus logs se fueran con él, o que nunca escribiera nada por otro motivo."),
],
"forense-master.md": [
("| `CrashLoopBackOff` sin logs, en un Mac con chip M 🔥 | [**A12**](a12-arm64-m1.md) §6 — casi siempre una imagen amd64 |",
 "| `CrashLoopBackOff` con `exec format error` en los logs, tras construir en un Mac con chip M 🔥 | [**A12**](a12-arm64-m1.md) §6 — una imagen arm64 en un nodo amd64 |"),
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
    print(f"{f}: {len(pares)}")
