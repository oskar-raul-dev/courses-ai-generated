# 🏷️ Convención de git: commits y tags de progreso
## Ruta NoSQL Lite

Cómo versionas lo que haces mientras recorres la ruta. Es corta a propósito: no es un proyecto de
empresa, no hay releases ni equipo, y una estrategia de ramas elaborada sobraría. Son tres cosas
—commits con un prefijo, un tag por fase cerrada y un tag por miniproyecto— más un uso que en esta
ruta rinde mucho: **la fase que rompe y mide se compara contra la que levantó**, y esa comparación
es un `git diff` entre dos tags.

> **Cuándo se lee:** antes de la [Fase 00](00-la-decision-que-se-hereda.md), y cada vez que el
> bloque 🏷️ de cierre de una fase te mande aquí.
> **Vigencia:** 2026-10-07.

> 🧠 **La frase para memorizar:** un tag es un puntero a un commit. No ocupa espacio, no agrega
> overhead y se borra con `git tag -d`. La pregunta no es "¿vale la pena etiquetar esto?", es "¿por
> qué no?".

---

## 📦 1. El repositorio

**La ruta no se hace dentro del repositorio donde se publica.** Antes de la Fase 00 copias la
carpeta del curso a un repositorio tuyo, y es ahí donde trabajas: tu `git init`, tus commits y tus
tags. La copia trae lo que necesitas, porque el laboratorio vive en `src/lab/`, con su
`compose.yaml`, el generador y el arnés ([a01](a01-laboratorio-contenerizado.md)); el repositorio del
curso queda intacto, como referencia. Lo que escribes
en cada fase va en `src/NN-<slug>/`, con el nombre exacto de la fase, y cada miniproyecto en
`src/h-mini-NN-<familia>-<empresa>/`.

**Lo que queda fuera**, y el `.gitignore` de `src/` ya lo excluye: los datos que produce el
generador en `src/lab/data/` (se versiona el generador, no lo que genera), `node_modules/`, los
entornos de Python y `src/lab/.env`, que tiene los puertos de tu máquina (se versiona el
`.env.example`). Los datos de los motores viven en volúmenes de Docker, fuera del repositorio. Y un
secreto que entra al repo ya no sale, aunque lo borres en el commit siguiente.

No hace falta remoto. Si lo tienes, recuerda que **los tags no viajan solos**:
`git push --tags`.

---

## 💬 2. Los mensajes de commit

Un prefijo, y ya. El prefijo es el código de la fase:

```bash
git commit -m "f05: sesiones de Cóndor como hash con TTL"
git commit -m "f05 ej17: candado atómico con SET NX y su expiración"
```

Los ejercicios llevan además su número (`ej17`), y así queda claro qué es contenido de la fase y qué
es práctica tuya. Eso te deja dos búsquedas útiles:

```bash
git log --oneline --grep '^f05'        # todo lo de la Fase 5
git log --oneline --grep '^f05 ej'     # solo los ejercicios de la Fase 5
```

### Los apéndices

**Los apéndices no cierran con tag**: un tag marca un cambio en el repositorio, y un apéndice explica
lo que ya está ahí. Lo que salga de leer uno se commitea con el prefijo de la fase desde la que
llegaste. Las dos excepciones son los apéndices que **dejan archivos** en el repositorio, y por eso
sí llevan tag:

| Apéndice | Tag | Qué deja |
|---|---|---|
| [a02](a02-compose-de-la-ruta.md) | `apendice-a02-compose` | `src/lab/compose.yaml` y su `.env.example` |
| [a05](a05-el-dominio-de-flota.md) | `apendice-a05-generador` | el generador de `src/lab/generator/` |

---

## 🏷️ 3. Un tag por fase cerrada

**Cuando cierras una fase —con su "📋 Checklist de validación" en verde— haces commit y creas el
tag.** Uno por fase, y no hace falta más.

El tag se llama **`fase-` + el mismo slug del archivo `.md`**, así no hay que recordar nada: el
archivo que estás leyendo te dice cómo se llama su tag.

```text
03-documental-levantar-y-modelar.md   →   fase-03-documental-levantar-y-modelar
04-documental-romper-y-medir.md       →   fase-04-documental-romper-y-medir
```

Anotado (`git tag -a`), porque así guarda fecha y mensaje. El mensaje no se inventa: es el checklist
de la fase, con lo que efectivamente quedó funcionando y **los números que mediste**, que así quedan
pegados al commit que los produjo.

```bash
git tag -a fase-05-clave-valor-levantar-y-modelar -m "F05 cerrada: <el checklist en una línea por ítem, con sus cifras>"
```

Si al escribir el mensaje descubres que un ítem del checklist no está, no está la fase. El tag es
honesto o no sirve para nada.

**Cada familia se lee en dos tags.** La fase que levanta y modela y la que rompe y mide son un par, y
el `diff` entre las dos es lo que tuviste que cambiar cuando el motor dejó de portarse como esperabas:

```bash
git diff fase-03-documental-levantar-y-modelar fase-04-documental-romper-y-medir --stat
```

> ⚠️ **Volver a un tag te deja en `detached HEAD`.** Es normal: `git checkout fase-04-documental-romper-y-medir`
> te pone a mirar ese estado sin estar en ninguna rama. Si vas a escribir desde ahí, crea una rama
> primero (`git switch -c wip/fase-04-intento-2`), con prefijo: una rama y un tag que se llaman igual
> vuelven ambiguo cualquier `git checkout`.

---

## 🧪 4. Los miniproyectos y los ejercicios

**Cada miniproyecto cierra con su propio tag, `mini-NN-<slug>`**, en un espacio de nombres aparte
para que `git tag -l 'fase-*'` siga siendo el índice limpio de la ruta. El slug es el de su archivo
sin el `h-`: [`h-mini-01-documental-barlovento.md`](h-mini-01-documental-barlovento.md) cierra con
`mini-01-documental-barlovento`. Anotado, y con la medición en el mensaje.

Los tags de ejercicio son opcionales, y valen la pena en los de medición y en los de diagnóstico:

```bash
git tag -a ej/f06/18 -m "<la cifra de antes y la de después, con el tamaño del dataset>"
git tag ej/f04/20-roto     # el problema reproducido, antes de tocar nada
git tag ej/f04/20-fix      # la corrección aplicada y medida
```

> ⚠️ **Un cuidado, uno solo.** No crees nunca un tag llamado literalmente `ej/f04`. Git guarda los
> refs como archivos: si existe `refs/tags/ej/f04`, no puede existir además el directorio
> `refs/tags/ej/f04/`, y `git tag ej/f04/20-roto` falla con un error confuso.

---

## 📈 5. Los comandos que hacen que esto sirva

```bash
git tag -l 'fase-*'                                      # ¿dónde estoy?
git tag -n99 -l 'fase-*'                                 # las cifras de cada fase, en sus mensajes
git tag -n99 -l 'mini-*'                                 # las de los miniproyectos
git for-each-ref --sort=creatordate \
  --format='%(creatordate:short)  %(refname:short)' 'refs/tags/fase-*'   # cuándo cerré cada fase
git checkout fase-03-documental-levantar-y-modelar -- src/03-documental-levantar-y-modelar/
```

---

## ✅ 6. Checklist de cierre de fase

- [ ] El "📋 Checklist de validación" de la fase, en verde y verificado a mano.
- [ ] Las mediciones de la fase anotadas en la [bitácora de medición](bitacora-de-medicion.md).
- [ ] `git status` limpio: todo lo de la fase está commiteado.
- [ ] `git tag -a fase-NN-<slug> -m "…"` creado, con el checklist y sus cifras en el mensaje.

> **La señal de que quedó bien:** "vuelvo después de tres semanas, corro `git tag -n99 -l 'fase-*'`,
> y sé exactamente dónde me quedé, qué medí y qué sigue — sin releer una sola línea del curso".
