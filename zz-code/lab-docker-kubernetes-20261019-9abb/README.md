# 🧪 lab-docker-kubernetes-20261019-9abb · cómo correr estas pruebas

> **Curso:** lab-docker-kubernetes · **Tanda:** C0 · **Creado:** 2026-10-19
> **Propósito:** retirar el repositorio padre y los tags inc/ del curso publicado; A5
> Se llena **mientras se prueba**: cada script nuevo entra aquí en la misma sesión. Las reglas, en
> `zz-code/README.md` § "El README de cada directorio". Si una sección no aplica, se dice por qué.

## 1. 🎯 Qué se prueba y para qué

`cuaderno_sin_tags.py` → `cuaderno-incidentes.md`, C0.2 del plan de cierre (D46): quita de la línea
«Cómo llegar.» de cada incidente de plataforma y de certificados (05–26) la ruta por tag
(`git switch --detach inc/NN/<slug>-roto` · o …), y deja la tarea y la forma a mano. No alimenta
ningún H-n ni B-n: es edición de texto.

## 2. 🛠️ Prerrequisitos

Python 3 (probado con 3.13), solo biblioteca estándar. Sin Docker ni cluster.

## 3. 🧭 Reglas antes de correr

No aplica: no levanta contenedores ni toca la máquina. Sin `--write` solo cuenta.

## 4. ▶️ Cómo se corre

```bash
C=cursos-contenedores-cloud-infra/lab-docker-kubernetes
Z=zz-code/lab-docker-kubernetes-20261019-9abb
python3 $Z/cuaderno_sin_tags.py $C/cuaderno-incidentes.md                      # vista previa
python3 $Z/cuaderno_sin_tags.py $C/cuaderno-incidentes.md --write | tee $Z/salidas/cuaderno.txt
```

Desde la raíz del repositorio.

## 5. 📏 Cómo se mide

Cuenta las entradas cambiadas y las referencias `inc/NN/` que quedan en el archivo.

## 6. 🧮 Intermedios que amasan la salida

No hay: el script lee y escribe el mismo archivo.

## 7. ✅ Qué se espera

`entradas cambiadas: 22 (05 … 26)` y `referencias inc/NN/ que quedan: 0`. Una segunda corrida da 0
entradas, porque el patrón ya no aparece.

## 8. 📦 Salidas

`salidas/cuaderno.txt` (ignorado por git): la salida de la corrida del 19/10/2026, con 22 y 0.

## 9. 🧹 Limpieza

Nada que limpiar en la máquina. `salidas/` lo borra `zz-code/limpiar.py`.

## 10. 🚫 Qué se dejó fuera

El resto de C0 se editó a mano (convención de git, `00-el-ambiente` §4.7, README, `0-ESTRUCTURA`,
la sección «Dos formas de llegar» del cuaderno, los cierres de nueve fases, `inc.py` y `prompts/`),
porque cada pasaje pedía redacción propia. A5 fue una consulta a la documentación de Envoy Gateway,
sin código.
