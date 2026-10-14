# 🏷️ Convención de git: commits y tags de progreso
## El Árbitro — Capstone Políglota

Cómo versionas el código que escribes mientras haces el curso. Es corta a propósito: no es un
proyecto de empresa, no hay releases ni equipo, y una estrategia de ramas elaborada sobraría. Son
tres cosas —un repo, commits con un prefijo y un tag por fase cerrada— y una regla que las ordena:
el archivo que estás leyendo te dice cómo se llama su tag.

> **Cuándo se lee:** antes de la Fase 00, y cada vez que el bloque 🏷️ de cierre de una fase te mande
> aquí.
> **Vigencia:** 2026-10-07.

> 📝 **Curso en preparación.** Los nombres de este documento ya están decididos en sus lineamientos;
> lo que lleva ⏳ lo fija una fase o un apéndice que todavía no existe.

> 🔑 **La frase para memorizar:** un tag es un puntero a un commit. No ocupa espacio, no agrega
> overhead y se borra con `git tag -d`. La pregunta no es "¿vale la pena etiquetar esto?", es "¿por
> qué no?".

---

## 📦 1. El repositorio

**El curso no se hace dentro del repositorio donde se publica.** Antes de la Fase 00 copias la
carpeta del curso a un repositorio tuyo, y es ahí donde trabajas: tu `git init`, tus commits y tus
tags. El repositorio del curso queda intacto, como referencia contra la que te comparas.

El código del curso es un solo proyecto en `src/` que crece fase a fase. Los nombres del sistema son
los de Palco, la empresa de la historia del curso.

**Lo que queda fuera desde el primer commit**: dependencias (`node_modules/`, `.venv/`), datos
generados que se pueden regenerar, los volúmenes de los contenedores y cualquier `.env` con valores
reales (se versiona el `.env.example`). Un secreto que entra al repo ya no sale, aunque lo borres en
el commit siguiente.

No hace falta remoto. Si lo tienes, recuerda que **los tags no viajan solos**: `git push --tags`.

---

## 💬 2. Los mensajes de commit

Un prefijo, y ya. El prefijo es el código de la fase, `fNN:`, y los de ejercicio llevan además su
número, `fNN ejM:`.

```bash
git commit -m "f03: <lo que hizo el commit>"
git commit -m "f03 ej12: <lo que resolvió el ejercicio>"
git log --oneline --grep '^f03'        # todo lo de la Fase 3
git log --oneline --grep '^f03 ej'     # solo sus ejercicios
```

Commitea seguido y con mensajes cortos que digan **qué decidiste**, no qué archivo tocaste.

### Los apéndices

**Los apéndices no cierran con tag**: un tag marca un cambio en el repositorio, y un apéndice
explica lo que ya está ahí. Lo que salga de leer uno se commitea con el prefijo de la fase desde la
que llegaste. ⏳ Si alguno deja archivos versionados, lleva un tag `apendice-aNN-<slug>`.

---

## 🏷️ 3. Un tag por fase cerrada

**Cuando cierras una fase —con su checklist de validación en verde— haces commit y creas el tag.**
Uno por fase: `fase-NN-<slug>`, con el mismo slug del archivo `.md` de la fase.

Anotado (`git tag -a`), porque así guarda fecha y mensaje. El mensaje no se inventa: es el checklist
de la fase, con lo que efectivamente quedó funcionando y las cifras que mediste.

```bash
git tag -a fase-03-<slug> -m "F03 cerrada: <el checklist, una línea por ítem>"
```

Si al escribir el mensaje descubres que un ítem del checklist no está, no está la fase. El tag es
honesto o no sirve para nada.

> ⚠️ **Volver a un tag te deja en `detached HEAD`.** Es normal: `git checkout <tag>` te pone a mirar
> ese estado sin estar en ninguna rama. Si vas a escribir desde ahí, crea una rama primero, con
> prefijo (`git switch -c wip/fase-03-intento-2`): una rama y un tag que se llaman igual vuelven
> ambiguo cualquier `git checkout`.

---

## 🧪 4. Tags de ejercicio *(opcionales, pero baratos)*

Van en un espacio de nombres aparte, `ej/<fase>/<número>`, para que `git tag -l 'fase-*'` siga
limpio. Rinden en dos casos: los ejercicios de diagnóstico, con un par `-roto` / `-fix` cuyo `git
diff` es la corrección aislada del ruido, y los de medición, con la cifra en el mensaje.

```bash
git tag ej/f03/12-roto     # el problema reproducido, antes de tocar nada
git tag ej/f03/12-fix      # la corrección aplicada y verificada
git tag -a ej/f03/18 -m "<la cifra de antes y la de después, con el tamaño del dataset>"
```

> ⚠️ Nunca un tag llamado literalmente `ej/f03`: si existe ese ref, git no puede crear `ej/f03/12`.
> Los niveles intermedios del espacio de nombres se quedan vacíos.

---

## 📈 5. Los comandos que hacen que esto sirva

```bash
git tag -l 'fase-*'                         # ¿dónde estoy?
git tag -n99 -l 'fase-*'                    # lo que cerró cada fase, con sus cifras
git for-each-ref --sort=creatordate \
  --format='%(creatordate:short)  %(refname:short)' 'refs/tags/fase-*'   # cuándo cerré cada fase
git diff <tag-anterior>..<tag-de-la-fase> --stat   # qué costó una fase
```

---

## ✅ 6. Checklist de cierre de fase

- [ ] El checklist de validación de la fase, en verde y verificado a mano.
- [ ] `git status` limpio: todo lo de la fase está commiteado.
- [ ] `git tag -a fase-NN-<slug> -m "…"` creado, con el checklist en el mensaje.

> **La señal de que quedó bien:** "vuelvo después de tres semanas, corro `git tag -l 'fase-*'`, y sé
> exactamente dónde me quedé y qué sigue — sin releer una sola línea del curso".
