# 📎 Apéndice bea-08 — Seguridad de API sobre un runtime sin parches

> Tutorial Angular 16 — Inspecciones y certificaciones · **Track BE opcional 🔥** · Consulta rápida · **4 horas**
> Usado por: **be06**, **be07** · Versiones cubiertas: PHP **7.4.33** (**EOL desde el 28 de noviembre de 2022**), Lumen **5.8.13**
> 🔥 Pertenece al track opcional de backend. El track base se completa sin abrirlo.

**Esto no se lee de corrido.** Se entra buscando qué hacer con un riesgo concreto —*"tengo SQL a mano y no puedo parchear el runtime"*— y se sale con la compensación y con la forma de documentarlo.

🧭 **El ángulo, que es lo que lo diferencia de cualquier checklist de OWASP: el runtime está EOL y eso no se va a arreglar.** Es la premisa del track, no un pendiente. La pregunta no es *"¿cómo lo actualizo?"* —eso es el trasplante de bootstrap de [`be06`](be06-la-reescritura-a-medias.md) y la decisión de [`be07`](be07-el-assessment-de-riesgo.md)—, es **"¿qué hago mientras tanto, y cómo lo documento para que la decisión la tome quien debe?"**.

**Qué queda fuera:** asesoría de seguridad —esto es material didáctico, no un dictamen—; **pruebas de intrusión** y cualquier técnica ofensiva; y cualquier receta que dependa de infraestructura que no tengas. Este apéndice enseña a **detectar, compensar y escalar**, y las tres palabras son literales.

---

## Índice

- [La premisa, dicha sin rodeos](#la-premisa-dicha-sin-rodeos)
- [OWASP sobre este dominio, en cuatro riesgos](#owasp-sobre-este-dominio-en-cuatro-riesgos)
- [Las capas de compensación](#las-capas-de-compensación)
- [Cómo se documenta y se escala un riesgo aceptado](#cómo-se-documenta-y-se-escala-un-riesgo-aceptado)
- [🧭 Cuándo usar qué](#-cuándo-usar-qué)
- [⚠️ Advertencias](#️-advertencias)
- [Referencias](#-referencias)
- [Ejercicios](#-ejercicios-7)

---

## La premisa, dicha sin rodeos

PHP 7.4 dejó de recibir parches de seguridad el **28 de noviembre de 2022**. La imagen `php:7.4-cli` tuvo su último *push* el **15 de noviembre de 2022** — se congeló, literalmente, el día que el runtime llegó a su fin de vida. Y la base del sistema operativo de esa imagen, Debian 11 *bullseye*, también terminó su ciclo (es la historia de la cápsula del tiempo de [`bea-02`](bea-02-receta-de-imagen-y-compose.md)).

Eso significa que **hay tres capas sin parches**: el sistema operativo de la imagen, el runtime, y el framework. No una.

> 🧠 **Un sistema sin parches no es un sistema inseguro: es un sistema cuyo riesgo crece solo, todos los meses, sin que nadie haga nada.** Ésa es la diferencia que hay que saber explicar, porque es la que convierte "no ha pasado nada" en un argumento malo.

Y la consecuencia práctica que ordena el apéndice: **si no puedes parchear, sólo te quedan tres movimientos** — reducir la superficie, compensar en otra capa, y documentar lo que queda. Ninguno de los tres arregla nada. Los tres se hacen igual.

⚠️ **Sobre los CVE concretos:** el listado de vulnerabilidades de PHP 7.4 posteriores a su EOL hay que consultarlo **en el aviso oficial y con fecha** —nunca de memoria y nunca desde este documento—, y hay que asumir que **la lista crece**. Este apéndice envejece por diseño: lo que enseña es el método, no el inventario.

---

## OWASP sobre este dominio, en cuatro riesgos

No la lista entera: los cuatro que este sistema tiene de verdad, cada uno con dónde vive exactamente en `certcore-api`.

### 1. Inyección SQL, y sabemos dónde está

Eloquent usa marcadores y no es inyectable. **El riesgo vive, entero, en el SQL a mano** — que es exactamente donde [`be04`](be04-el-salto-de-version-que-nadie-corrio.md) dijo que estaban también los bugs de dialecto. Ese archivo ya lo tienes:

```bash
cd server
grep -rn "DB::select(\|DB::raw(\|DB::statement(" app/ > ../SQL-CRUDO.txt
# Y ahora lo que importa: ¿cuáles CONCATENAN en vez de usar marcadores?
grep -n '\$' ../SQL-CRUDO.txt | grep -v '?'
```

```php
// ❌ Inyectable: la variable entra en el texto de la consulta.
DB::select("SELECT * FROM certificates WHERE status = '" . $status . "'");

// ✅ Con marcador: el valor viaja aparte y nunca se interpreta como SQL.
DB::select('SELECT * FROM certificates WHERE status = ?', [$status]);

// ⚠️ El caso que los marcadores NO cubren: identificadores.
// Un nombre de columna no puede ser un marcador. Si viene de fuera, sólo
// hay una defensa: una LISTA BLANCA. Escapar no basta.
$allowed = ['issued_at', 'valid_until'];
$column = in_array($request->query('sort'), $allowed, true) ? $request->query('sort') : 'issued_at';
```

> 🧭 **La lista blanca no es "una forma de validar": es la única defensa para lo que no admite marcadores.** Ordenaciones dinámicas, nombres de tabla, direcciones de ordenación. Si te descubres escapando un identificador, estás resolviendo el problema equivocado.

### 2. Autorización a nivel de objeto, que aquí significa algo concreto

En una certificadora: **que un cliente no vea los activos de otro.** Es el riesgo más probable de este sistema y el más fácil de pasar por alto, porque no produce ningún error.

```php
// ❌ Comprueba que estás autenticado. No comprueba que sea TUYO.
$router->get('/assets/{id}', function ($id) {
    return Asset::find($id);
});
```

El token de CertCore trae `sub` y `role`, y **el `role` no autoriza nada** — el track base lo declaró explícitamente en su Fase 2. Cambiar eso es una decisión de producto, no de este apéndice; lo que sí corresponde aquí es **detectarlo y escribirlo**:

```bash
# Rutas con {id} — cada una es un candidato a acceso directo a objeto.
grep -rn "{id}\|{.*}" server/routes/web.php
```

Para cada una, contesta tres preguntas: ¿quién puede pedirla?, ¿qué pasa si cambio el id por otro?, ¿lo habría notado alguien? **La tercera es la que duele.**

### 3. Asignación masiva

```php
// ❌ Todo lo que llegue en el cuerpo entra en la fila.
Certificate::create($request->all());
```

Con eso, un cliente puede mandar `{"status": "valid", "revoked_at": null}` sobre un certificado revocado. En Eloquent la defensa es declarativa y va **en el modelo**:

```php
class Certificate extends Model
{
    // Lista blanca de lo que se puede asignar en masa. Todo lo demás se ignora.
    protected $fillable = ['inspection_id', 'issued_at', 'valid_until'];

    // Y lo que nunca se expone al serializar, aunque esté en la fila.
    protected $hidden = ['internal_notes'];
}
```

⚠️ `$guarded = []` —que aparece en muchos ejemplos— **desactiva la protección entera**. Si lo encuentras en el código heredado, es un hallazgo, no un estilo.

### 4. Lo que exponen los mensajes de error

```bash
docker compose exec api php -r 'var_dump(getenv("APP_DEBUG"));'
```

Con `APP_DEBUG=true`, una excepción devuelve la traza completa: rutas del sistema de archivos, nombres de clase, fragmentos de consulta y, con suerte para quien mira, valores. Es información de reconocimiento gratis.

La regla es de una línea y no tiene excepciones: **`APP_DEBUG=false` en cualquier entorno que no sea tu portátil**, y el detalle al log del contenedor, que es donde tiene que estar de todas formas ([`bea-01`](bea-01-php-7-4-y-lumen-para-quien-no-escribe-php.md)).

Y un caso propio de este track: **`tools/probe.php` usa `eval()`** ([`be01`](be01-lumen-y-la-familiaridad-falsa.md) §5.8). Es correcto en una herramienta de laboratorio que no se despliega y que sólo ejecuta quien ya tiene una terminal dentro del contenedor; sería una puerta trasera completa si acabara en el artefacto de despliegue. **La diferencia entre "peligroso" y "peligroso aquí" es dónde vive el archivo**, y por eso excluirlo del despliegue es una línea de configuración que hay que escribir, no una confianza.

---

## Las capas de compensación

Cuando el runtime no se puede parchear, la defensa se mueve a las capas que sí controlas. Ninguna sustituye al parche; todas reducen la probabilidad o el alcance.

| Capa | Qué compensa | Qué **no** compensa |
|---|---|---|
| **Reducir la superficie** | Endpoints que nadie usa, herramientas de laboratorio, extensiones de PHP de más, `APP_DEBUG` | Nada de lo que sí se usa |
| **Red** | Exposición directa: la API detrás de un proxy, la base **sin puerto publicado** | Un fallo en un endpoint legítimo |
| **WAF / filtro delante** | Patrones conocidos de inyección y recorrido de rutas | Lógica de negocio, autorización |
| **Límites de tasa** | Fuerza bruta, enumeración de identificadores | Un único acceso bien dirigido |
| **Registro y alerta** | Nada — pero es lo único que te dice que pasó | Que pase |
| **Aislamiento** | El alcance: qué puede tocar el proceso si cae | La caída |

Las tres que en este laboratorio ya están puestas y conviene reconocer: **la base no publica el 5432** (`bea-02`), **`pdo_pgsql` es la única extensión instalada**, y **el código va montado, no copiado** — lo cual es cómodo en desarrollo y sería un error en un despliegue, y ahí está la diferencia entre un laboratorio y un sistema.

> 🧭 **La reducción de superficie es la única compensación que no cuesta dinero ni añade una pieza nueva que mantener.** Empieza siempre por ahí: cada endpoint que borras, cada extensión que no instalas y cada variable de depuración que apagas es riesgo que desaparece en vez de mudarse.

---

## Cómo se documenta y se escala un riesgo aceptado

Ésta es la parte que alimenta el *assessment* de [`be07`](be07-el-assessment-de-riesgo.md), y es la que casi nadie escribe.

Un riesgo aceptado **no es un riesgo ignorado**. La diferencia son cinco campos:

```markdown
## R-01 · Runtime sin parches de seguridad

**Qué es.** `certcore-api` corre sobre PHP 7.4.33, sin soporte de seguridad desde
el 28/11/2022. El sistema operativo de la imagen y el framework están igual.

**Qué podría pasar.** Una vulnerabilidad publicada del runtime no tendrá parche.
La exposición depende de qué componentes procesen entrada externa.

**Probabilidad y alcance.** [Con criterio y fecha, no con adjetivos.]

**Qué se ha hecho para compensar.** Superficie reducida (n endpoints retirados),
API detrás de proxy, base sin puerto publicado, `APP_DEBUG=false`, SQL crudo
revisado (n consultas, todas con marcadores).

**Qué haría falta para eliminarlo.** Subir a PHP 8, que implica el trasplante de
bootstrap de be06: estimación en `SUPERFICIE.md`.

**Quién lo acepta y hasta cuándo.** ← EL CAMPO QUE HACE QUE ESTO SIRVA.
Nombre, cargo, fecha de aceptación y **fecha de revisión**. Sin los dos últimos,
esto es un archivo; con ellos, es una decisión.
```

> 🧠 **Un riesgo sin dueño y sin fecha de revisión no está aceptado: está escondido.** Escalar no es quejarse por correo: es poner el riesgo por escrito, con su compensación y su coste de eliminación, delante de quien tiene el presupuesto — y conseguir una firma o un *no* con fecha. Las dos respuestas sirven; el silencio, no.

Y la frase que hay que poder decir sin que suene a excusa: *"no es un fallo técnico pendiente, es una decisión de negocio que necesita a alguien que la tome."*

---

## 🧭 Cuándo usar qué

| Síntoma o situación | Qué hacer primero | Después |
|---|---|---|
| Hay SQL crudo | Comprobar marcadores, no escapado | Lista blanca para identificadores |
| Ruta con `{id}` sin comprobación de dueño | Documentarla como riesgo | Decidir si el producto necesita autorización por objeto |
| `create($request->all())` | `$fillable` en el modelo | Buscar `$guarded = []` en todo el proyecto |
| Trazas en las respuestas | `APP_DEBUG=false` | Registro estructurado al log del contenedor |
| Herramienta de laboratorio con `eval()` | Excluirla del artefacto de despliegue | Comprobarlo en el pipeline |
| No se puede parchear el runtime | Reducir superficie | Compensar en red, documentar, escalar |
| Alguien pide bajar la seguridad de la base para un cliente viejo | **No** | Subir el cliente, o excepción documentada con fecha |
| Te piden un dictamen de seguridad | Detectar, compensar, escalar | Y decir que no eres el dictamen |

---

## ⚠️ Advertencias

**Este apéndice no es una auditoría de seguridad y no la sustituye.** Enseña a detectar lo evidente, compensar lo que se pueda y escalar el resto. Si el sistema maneja datos de terceros bajo obligación regulatoria —y una certificadora los maneja—, la conversación incluye a cumplimiento y a alguien con mandato, no sólo al equipo.

**Ningún ejercicio de este apéndice es ofensivo.** Todos son de detección y de documentación. Este track no enseña a explotar nada, y no porque sea difícil: porque no es el oficio que entrena.

**La lista de vulnerabilidades crece y este documento no.** Cita siempre el aviso oficial con fecha. Un inventario de CVE escrito en un `.md` envejece mal y da falsa tranquilidad — que es peor que no tener ninguno.

---

## 📚 Referencias

- https://owasp.org/API-Security/editions/2023/en/0x11-t10/ — el top 10 de seguridad de API. Los cuatro riesgos de arriba salen de aquí, aplicados a este dominio.
- https://owasp.org/www-project-top-ten/ — el clásico, para el contexto general.
- https://www.php.net/supported-versions.php — el calendario de soporte. La fila de 7.4 dice **28 de noviembre de 2022**.
- https://www.php.net/ChangeLog-7.php — el registro de cambios de PHP 7, donde se ve **qué dejó de recibir correcciones y cuándo**.
- https://nvd.nist.gov/vuln/search — la base nacional de vulnerabilidades, para consultar con fecha en vez de citar de memoria.
- https://laravel.com/docs/5.8/eloquent#mass-assignment — `$fillable` y `$guarded` en la línea contemporánea de este sistema.

> ⚠️ Los enlaces pueden haber cambiado; verifícalos. Y con los avisos de vulnerabilidades, **la fecha de consulta es parte del dato**: escribe siempre *"consultado el DD/MM/AAAA"* junto a cualquier afirmación sobre qué hay publicado.

---

## 🧪 Ejercicios (7)

Ninguno es ofensivo: todos son de detección y de documentación.

1. Genera `SQL-CRUDO.txt` y clasifica cada consulta: con marcadores, con concatenación, o con identificador dinámico. Anota el número de cada clase.
2. **Diagnóstico.** Busca `$guarded = []` y `create($request->all())` en `server/app/`. Para cada hallazgo, escribe qué campo podría sobrescribirse y qué significaría eso en el dominio de certificaciones.
3. Lista las rutas con `{id}` y contesta las tres preguntas de autorización por objeto para cada una. Marca las que un cliente podría usar para ver datos de otro.
4. **Diagnóstico.** Con `APP_DEBUG=true`, provoca una excepción y anota **exactamente** qué información aparece en la respuesta. Después ponlo en `false` y repite. Compara las dos salidas línea a línea.
5. Escribe la ficha de riesgo `R-01` completa, con los siete campos, incluida la fecha de revisión. Después identifica en tu organización —real o imaginaria— **quién tendría que firmarla**.
6. **Diagnóstico.** Haz el inventario de reducción de superficie: endpoints que nadie llama (el `CONTRACT.md` de be00 lo dice), extensiones de PHP instaladas, variables de depuración, y herramientas de laboratorio que no deberían desplegarse. Cuantifica cuánto se reduce.
7. **Diagnóstico.** Consulta hoy, con fecha, cuántas vulnerabilidades con CVE afectan a PHP 7.4 publicadas **después** del 28/11/2022. Anota el número y la fuente. Después escribe en tres líneas por qué ese número, por sí solo, **no** decide nada — y qué haría falta añadirle para que decidiera.

---

> 🏷️ **Este apéndice no lleva tag propio.** Lo que salga de leerlo se commitea con el prefijo de la fase desde la que llegaste (`be06: …`, `be07: …`). La ficha de riesgo del ejercicio 5 sí es un entregable que sobrevive: vive en el *assessment* de be07 y se cita en [`bea-10`](bea-10-mapa-de-deuda-del-track-be.md) como la deuda insignia del track. La convención completa está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
