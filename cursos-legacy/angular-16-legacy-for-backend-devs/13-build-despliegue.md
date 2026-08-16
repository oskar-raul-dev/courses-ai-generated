# 🚚 Fase 13 — Build, despliegue y cierre

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 13 de 14 · **7 horas**
> Depende de: Fase 12 (testing y coverage) · Habilita: Fase 14 (🔥 opcional)
> Apéndices de apoyo: [A03 (Node y npm)](a03-node-npm.md) · [A09 (Docker y Kubernetes)](a09-docker-kubernetes.md) · [A12 (arm64)](a12-arm64-m1.md) 🔥
> [Incidentes asociados](cuaderno-incidentes.md): 18, 19
> Estilo de esta fase: **nuevo** en la app, con una costura 🧬 hacia el `AppModule` heredado; el resto es Docker, nginx y shell

---

## 🎯 1. Propósito

Trece fases construyendo una aplicación que sólo ha corrido en tu máquina. Hoy sale.

Y sale por la puerta donde está la piedra: **Angular hornea `environment.ts` en tiempo de compilación**, y cualquier contenedor espera inyectar la configuración en tiempo de arranque. Esas dos frases se contradicen, y de esa contradicción sale la mitad de los *"funciona en UAT y no en PROD"* de cualquier SPA del mundo.

Lo que la hace interesante es que **no es un defecto de Angular 16**. Angular 8 lo tiene igual, Angular 19 lo tiene igual, y React y Vue también. No es una versión vieja que alguien arregló: es una propiedad de cómo se construye una aplicación que se compila una vez y se despliega muchas. Por eso esta fase es obligatoria y el cluster de la Fase 14 no lo es.

Al final vas a tener **una sola imagen** levantada dos veces, en dos puertos, comportándose distinto — una diciendo `PROD` y hablando con un backend, y otra diciendo `UAT` y hablando con otro. El mismo `docker run`, el mismo digest, dos comportamientos. Cuando veas eso funcionando, el problema entero del despliegue de una SPA se te queda entendido para siempre.

Y hay una deuda esperando desde la primera fase. En la Fase 0 la URL del backend estaba escrita dentro de un componente; en la Fase 1 se mudó a `environment.ts` y quedó más ordenada sin dejar de estar horneada. Hoy se paga de verdad, y la factura se lee en un comando.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `docker build` produce una imagen de nginx con el `dist/` dentro, sin Node, sin `node_modules` y sin el código fuente.
- [ ] **La misma imagen, dos `docker run` con variables distintas**: `http://localhost:8080` dice `PROD` en la toolbar y `http://localhost:8081` dice `UAT`. Compruebas con `docker inspect` que el digest es idéntico.
- [ ] Cambias `API_BASE_URL` en el `docker run` y la aplicación habla con otro backend **sin recompilar nada**. La 💸 de la Fase 0 queda saldada y `git diff fase-00 fase-13 -- src/environments src/assets` es la factura.
- [ ] Recargas la página estando en `/inspections/500` y **no** sale un 404. Sabes qué línea del `nginx.conf` lo evita y qué pasa si la quitas.
- [ ] Despliegas una versión nueva, recargas, y ves el cambio **a la primera**. Si tienes que hacer Ctrl+Shift+R, tienes el incidente 18.
- [ ] Provocas un error en producción y llegas desde el stack trace minificado hasta la línea del `.ts`. Después sirves el `dist/` sin los `.map` y compruebas qué se pierde.
- [ ] `ng build --configuration production` respeta los presupuestos, y sabes cuál de las cifras de `deuda.md` está más cerca de hacerlos saltar.
- [ ] Existe `HOTFIX.md` en la raíz del repositorio: una página, sin adornos, que te llevas al trabajo el lunes.
- [ ] `git tag` lista `fase-13`.

---

## 🚫 3. Qué NO entra todavía

- **Kubernetes y cualquier orquestador** → **Fase 14** 🔥, que toma esta misma imagen sin modificarle una línea. Aquí todo se hace con `docker run`, a propósito: si no entiendes el problema con dos contenedores, un cluster sólo lo esconde detrás de más YAML.
- **CI/CD real** → fuera de alcance. La Fase 12 dejó el comando que un pipeline necesitaría (`npm run test:ci`) y aquí queda el `docker build`. Juntarlos es un archivo de veinte líneas y una plataforma concreta que este curso no elige.
- **CDN, SSR e hidratación** → fuera de alcance. Un sistema interno de certificaciones no tiene el problema que resuelven, y meterlos aquí sería enseñar la solución de otro.
- **Un backend de verdad** → nunca entró. El mock de la Fase 3 se levanta en un segundo contenedor, con su inyector de caos incluido, y eso basta para tener dos ambientes que se comportan distinto.
- **HTTPS, certificados y cabeceras de seguridad** → fuera de alcance, y conviene decirlo en vez de omitirlo: un nginx de producción de verdad lleva TLS, `Content-Security-Policy` y unas cuantas cabeceras más. Aquí no, porque cada una es un tema propio y ninguna enseña nada sobre Angular.
- **La imagen non-root en un puerto alto** → es la 💸 de esta fase, **no se paga**, y su destino está documentado en **A09**.

---

## 🧠 4. Concepto mínimo

### El problema, antes que la herramienta

Corre esto ahora mismo, antes de leer nada más:

```bash
ng build --configuration production
grep -r "localhost:3000" dist/ | head
```

Si hiciste el ejercicio 27 de la Fase 0, ya sabes lo que sale. Si no: la cadena está ahí, dentro de un `.js` minificado, incrustada entre código que nadie puede editar a mano. Y está ahí **aunque la constante viva en un archivo aparte con un nombre bonito**, porque mover una constante de archivo no cambia cuándo se resuelve su valor.

Ése es el problema entero y cabe en una frase: **el valor se decidió cuando compilaste**. Para cambiarlo hace falta compilar otra vez. Y compilar otra vez significa que el artefacto que probaste en UAT **no es** el artefacto que va a producción — es otro, construido después, con otra configuración, y por lo tanto sin probar.

> 🧭 **La regla que ordena esta fase: se construye una vez y se despliega muchas.** El mismo artefacto, bit a bit, recorre todos los ambientes. Lo único que cambia entre uno y otro es lo que le pasas al arrancarlo. Cualquier cosa que obligue a recompilar para cambiar de ambiente rompe la garantía de que probaste lo que desplegaste.

### 🩻 Esto sí funciona igual que en tu backend

Si vienes de Spring, de .NET o de cualquier servicio que arranca leyendo variables de entorno, esto te va a sonar raro por lo contrario: **en el backend el problema no existe**. Tu `application.yml` se lee al arrancar el proceso, `System.getenv()` funciona, y desplegar el mismo `.jar` en tres ambientes con tres configuraciones es lo normal desde siempre.

En una SPA no puedes hacer eso, y la razón es física, no de diseño: **tu código no corre en el servidor, corre en el navegador de otra persona**. No hay proceso al que pasarle variables de entorno. Lo único que llega al navegador son archivos estáticos que un servidor web entregó, y esos archivos ya estaban escritos cuando el servidor arrancó.

Hasta aquí el paralelo funciona. Donde se rompe es en la solución, y la solución es la única que hay: **si la configuración no puede viajar en el código, tiene que viajar como un dato que el código pide**. Un archivo `assets/config.json` que el contenedor **reescribe al arrancar** y que la aplicación lee antes de pintar nada. El contenedor sí tiene proceso, sí tiene variables de entorno, y sí puede escribir un archivo antes de levantar nginx.

Es un rodeo, y no hay atajo. Lo que se gana con él es exactamente la garantía de arriba: una imagen, un digest, todos los ambientes.

### `APP_INITIALIZER`, y por qué bloquea el arranque

Angular tiene un gancho para esto y es de los pocos que hacen exactamente lo que promete. `APP_INITIALIZER` es un token multi-provider: si registras una función que devuelve una `Promise`, **Angular no arranca la aplicación hasta que esa promesa se resuelve**.

Bloquear el arranque suena mal y aquí es justo lo que quieres. Piensa en la alternativa: si la configuración llegara *después*, tendrías una ventana —corta, variable, imposible de reproducir— en la que algún servicio ya pidió `apiBaseUrl` y recibió `undefined`. Ese bug aparece una vez de cada veinte cargas, sólo en máquinas lentas, y es de los que se cierran como "no reproducible".

El precio es real y hay que decirlo: **cada milisegundo que tarde esa promesa es un milisegundo de pantalla en blanco**. Por eso lo que va en un `APP_INITIALIZER` es una petición a un archivo estático servido por el mismo nginx que sirvió el `index.html` — no una llamada a una API, no una sesión, no tres cosas encadenadas. Un `APP_INITIALIZER` lento es la forma más elegante de hacer que tu aplicación parezca rota.

> 📝 **Nota de migración.** `APP_INITIALIZER` es de Angular 2 y sigue siendo la respuesta correcta en la 16: no lo ha sustituido nada. Lo que sí cambió alrededor es dónde se registra. En 2021, CertCore lo habría puesto en los `providers` de `AppModule`, que es donde va a estar hoy. En una aplicación arrancada con `bootstrapApplication` iría en el array de `providers` de la llamada, con la misma forma. Y en Angular 19 aparece `provideAppInitializer()`, que es azúcar sobre lo mismo. Tres formas de escribir, un solo mecanismo, veintitrés versiones sin moverse: es el ejemplo más limpio del curso de que no todo lo viejo está esperando ser reemplazado.

### Lo que sí es de tiempo de compilación

Hay una tentación al llegar aquí y es mover **todo** a `config.json`. No: `environment.ts` no desaparece, adelgaza. La pregunta que separa las dos cosas es concreta:

**¿Este valor puede cambiar entre dos despliegues del mismo artefacto?** Si puede, es configuración de arranque. Si no puede, es de compilación y `environment.ts` es su sitio.

`apiBaseUrl` puede: UAT habla con un backend y producción con otro. `environmentName` puede: es la etiqueta que la toolbar pinta desde la Fase 1. `production`, en cambio, **no** puede — no es un dato, es un interruptor del compilador: activa `enableProdMode()`, apaga la doble comprobación de detección de cambios y decide cómo se optimiza el bundle. Un `production: false` leído en tiempo de arranque no desharía nada de eso; sería una mentira con forma de configuración.

Hay un tercer valor que lleva doce fases esperando y que casi nadie nota: el tipo `AppEnvironment` de la Fase 1 declara `environmentName: 'DEV' | 'UAT' | 'PROD'`, y **`'UAT'` no lo ha producido ningún build todavía**. Estaba en el tipo desde el primer día, sin implementación. Hoy aparece, y no hace falta tocar el tipo: aparece porque la configuración dejó de ser de compilación.

---

## 💻 5. Código mínimo con comentarios

### 5.1 La configuración que se lee al arrancar

```ts
// src/app/core/config/app-config.model.ts

/**
 * Lo que puede cambiar entre dos despliegues DEL MISMO artefacto.
 *
 * Compáralo con `AppEnvironment` de la Fase 1: aquel tenía tres campos y éste
 * tiene dos. El que falta es `production`, y no es un olvido — es un
 * interruptor del compilador, no un dato. Ver §4.
 */
export interface AppConfig {
  readonly apiBaseUrl: string;
  readonly environmentName: 'DEV' | 'UAT' | 'PROD';
}
```

```json
// src/assets/config.json — los valores de DESARROLLO
// Este archivo se versiona con los valores de desarrollo y el contenedor lo
// SOBRESCRIBE al arrancar. Que exista en el repositorio es lo que hace que
// `ng serve` siga funcionando sin ningún montaje especial.
{
  "apiBaseUrl": "http://localhost:3000",
  "environmentName": "DEV"
}
```

```ts
// src/app/core/config/app-config.service.ts
import { Injectable } from '@angular/core';

import { AppConfig } from './app-config.model';

@Injectable({ providedIn: 'root' })
export class AppConfigService {
  private config: AppConfig | null = null;

  /**
   * Se llama UNA vez, desde el APP_INITIALIZER de 5.2, antes de que exista
   * ningún componente.
   *
   * Se usa `fetch` y no `HttpClient`, y la razón es la cadena de interceptores:
   * el `authInterceptor` de la Fase 2 le pondría un `Authorization` a esta
   * petición y trataría un 401 como sesión caducada, mandando al usuario al
   * login antes de que la aplicación exista. Pedir un archivo estático del
   * propio servidor no necesita nada de eso.
   *
   * El `?t=` es antichaché y es deliberado: el navegador guarda respuestas de
   * `fetch` igual que las de cualquier petición, y un `config.json` cacheado es
   * exactamente el incidente 18. En 5.5 nginx lo prohíbe además desde su lado;
   * las dos defensas juntas no sobran, porque entre el navegador y nginx suele
   * haber un proxy corporativo que nadie controla.
   */
  async load(): Promise<void> {
    const response = await fetch(`assets/config.json?t=${Date.now()}`);

    if (!response.ok) {
      // Se lanza y se deja morir la aplicación a propósito. Una SPA que arranca
      // sin saber con qué backend habla no está "degradada": está rota, y va a
      // producir cinco tickets confusos en vez de uno claro. El mensaje va en
      // español, como todos los dirigidos a otro desarrollador.
      throw new Error(
        `No se pudo leer assets/config.json (HTTP ${response.status}). La aplicación no puede arrancar sin configuración.`,
      );
    }

    // `unknown` y estrechar, que es la regla desde la Fase 6. Un
    // `await response.json()` devuelve `any` en las definiciones de
    // TypeScript, y aceptarlo aquí apagaría `strict` en el punto exacto donde
    // entra un dato que nadie controla.
    const raw: unknown = await response.json();

    this.config = parseAppConfig(raw);
  }

  /**
   * El acceso. Lanza si alguien lo llama antes de que el initializer
   * terminara, que sólo puede pasar si alguien inyecta este servicio DENTRO de
   * otro APP_INITIALIZER — y entonces el error dice exactamente eso en vez de
   * devolver una cadena vacía que produce peticiones a `/undefined/clients`.
   */
  get current(): AppConfig {
    if (this.config === null) {
      throw new Error('AppConfigService: se pidió la configuración antes de cargarla.');
    }

    return this.config;
  }
}

/**
 * La guarda de forma, que es la misma disciplina que la Fase 3 puso en el
 * borde HTTP y la Fase 9 en los hallazgos. Aquí importa más que en ningún
 * sitio: este archivo lo escribe un shell script desde variables de entorno,
 * así que un despliegue con una variable mal puesta produce un JSON válido y
 * equivocado. Es el incidente 19.
 */
function parseAppConfig(raw: unknown): AppConfig {
  if (typeof raw !== 'object' || raw === null) {
    throw new Error('assets/config.json no contiene un objeto.');
  }

  const candidate = raw as Record<string, unknown>;
  const apiBaseUrl = candidate['apiBaseUrl'];
  const environmentName = candidate['environmentName'];

  if (typeof apiBaseUrl !== 'string' || apiBaseUrl === '') {
    throw new Error('assets/config.json: `apiBaseUrl` falta o está vacío.');
  }

  if (
    environmentName !== 'DEV' &&
    environmentName !== 'UAT' &&
    environmentName !== 'PROD'
  ) {
    // Se comprueba contra los tres valores del tipo y no con un `as`. Una
    // variable de entorno mal escrita —`PRD` en vez de `PROD`— tiene que
    // reventar aquí, en el arranque, con un mensaje que la nombra; no tres
    // pantallas más allá con una etiqueta rara en la toolbar.
    throw new Error(
      `assets/config.json: \`environmentName\` vale "${String(environmentName)}" y sólo admite DEV, UAT o PROD.`,
    );
  }

  return { apiBaseUrl, environmentName };
}
```

**Detalles con intención**

- **`config` es `AppConfig | null` y el acceso lanza.** La alternativa —devolver un objeto con valores por defecto— convierte un despliegue mal configurado en una aplicación que funciona a medias contra el backend equivocado. Fallar en el arranque es ruidoso, visible y barato de diagnosticar.
- **El `?t=${Date.now()}` no es paranoia.** Es la primera de las dos defensas contra el incidente 18, y la única que sigue funcionando cuando entre el usuario y tu nginx hay un proxy que tú no configuras.
- **Se valida un archivo que escribe tu propio script.** Parece exagerado hasta la primera vez que alguien despliega con `ENVIRONMENT_NAME=Prod` y la aplicación arranca tan tranquila con una etiqueta en minúsculas que nadie mira.

### 5.2 🧬 El `APP_INITIALIZER`, en un `AppModule` de 2021

```ts
// src/app/app.module.ts — lo que se añade
import { APP_INITIALIZER, NgModule } from '@angular/core';

import { AppConfigService } from './core/config/app-config.service';

/**
 * 🧬 LA COSTURA DE ESTA FASE, Y ES LA ÚLTIMA DEL CURSO.
 *
 * Un `APP_INITIALIZER` registrado en los `providers` de un NgModule escrito en
 * 2021, que carga la configuración que consume código standalone de 2025: los
 * servicios de API de las Fases 3 a 10, todos con `inject()` y `providedIn:
 * 'root'`.
 *
 * Ninguna de las dos generaciones sabe de la otra. El módulo heredado no sabe
 * que sus consumidores son standalone; los servicios standalone no saben que
 * quien les llenó la configuración fue un provider de un NgModule. Sólo
 * comparten el inyector raíz, que es de las dos y de ninguna.
 *
 * `main.ts` sigue arrancando con `platformBrowserDynamic().bootstrapModule()`,
 * igual que desde la Fase 1. Convertirlo a `bootstrapApplication` no habría
 * cambiado ni una línea de esto —el mismo provider iría en el array de la
 * llamada— y habría exigido desmontar el AppModule, que es la migración que
 * este curso decidió no hacer. Ver los 📌.
 */
export function loadAppConfig(appConfig: AppConfigService): () => Promise<void> {
  // Una función exportada con nombre, y no una arrow anónima dentro del
  // `useFactory`. Es requisito del compilador AOT: las factorías tienen que ser
  // referenciables estáticamente, y una arrow inline compila en desarrollo y
  // falla en el build de producción. Es de los pocos errores que sólo aparecen
  // al desplegar, así que se evita escribiéndolo bien la primera vez.
  return () => appConfig.load();
}

@NgModule({
  // …declarations e imports, sin cambios desde la Fase 5…
  providers: [
    // …los providers que ya había…
    {
      provide: APP_INITIALIZER,
      useFactory: loadAppConfig,
      deps: [AppConfigService],
      // `multi: true` porque APP_INITIALIZER es un token multi: se pueden
      // registrar varios y Angular espera a todos. Sin esto, el tuyo
      // REEMPLAZARÍA a los que Angular registra por su cuenta.
      multi: true,
    },
  ],
})
export class AppModule {}
```

```ts
// src/environments/environment.ts — lo que queda
import { AppEnvironment } from './environment.model';

/**
 * 🪦 LA DEUDA DE LA FASE 0, PAGADA. Trece fases después.
 *
 * En la Fase 0 la URL vivía dentro de un componente. En la Fase 1 se mudó aquí
 * y quedó más ordenada sin dejar de estar horneada. Hoy se va a
 * `assets/config.json` y este archivo se queda con lo único que de verdad es de
 * compilación: el interruptor `production`.
 *
 * La factura se lee en un comando, y lo dejó escrito la convención de git:
 *     git diff fase-00 fase-13 -- src/environments src/assets
 */
export const environment: Pick<AppEnvironment, 'production'> = {
  production: true,
};
```

```ts
// src/app/core/api/inspection-api.service.ts — la única línea que cambia
@Injectable({ providedIn: 'root' })
export class InspectionApiService {
  private readonly http = inject(HttpClient);
  private readonly appConfig = inject(AppConfigService);

  // Era: `${environment.apiBaseUrl}/inspections`, resuelto en compilación.
  // Ahora se lee del servicio, y sigue siendo un `readonly` calculado una vez
  // porque el APP_INITIALIZER ya terminó cuando este servicio se instancia.
  private readonly baseUrl = `${this.appConfig.current.apiBaseUrl}/inspections`;
}
```

**Detalles con intención**

- **El cambio en los servicios de API es de dos líneas cada uno, y son ocho servicios.** Hazlo con el compilador de guía: borra `apiBaseUrl` del `AppEnvironment` y corre `ng build`. Los errores que salgan son el mapa completo, exactamente como la Fase 6 hizo con la inmutabilidad del estado. Cuéntalos y anótalos en `deuda.md`: ese número —*"la URL horneada vivía en N sitios"*— es lo que se lleva a una reunión.
- **`Pick<AppEnvironment, 'production'>` y no una interfaz nueva.** El tipo de la Fase 1 sigue siendo la fuente; esto sólo dice qué parte de él sobrevive aquí. Y el `environmentName` que la toolbar pinta ahora sale de `AppConfigService`, así que el `'UAT'` que el tipo declaraba desde la Fase 1 por fin tiene quién lo produzca.

**Prueba de fuego**

`ng serve` y mira la toolbar: dice `DEV`, igual que siempre, pero ahora el valor viene de `assets/config.json` y no del compilador. Edita ese archivo a mano, pon `"environmentName": "UAT"`, **recarga sin reiniciar el servidor** y mira otra vez. Cambió. Eso, que en desarrollo parece un truco tonto, es exactamente lo que en el contenedor vale una tarde de trabajo.

### 5.3 El build de producción, sus presupuestos y sus mapas

```jsonc
// angular.json → …architect.build.configurations.production
{
  "production": {
    "budgets": [
      {
        "type": "initial",
        // El bundle inicial: lo que el usuario descarga antes de ver nada.
        // Aquí es donde aterrizan las cifras que `deuda.md` lleva acumulando
        // desde la Fase 5 — el SharedModule, el tema de Material, Chart.js.
        "maximumWarning": "1mb",
        "maximumError": "1.5mb"
      },
      {
        "type": "anyComponentStyle",
        "maximumWarning": "4kb",
        "maximumError": "8kb"
      }
    ],
    "outputHashing": "all",
    /**
     * ⭐ `hidden: true` — la opción que casi nadie pone y que cambia de qué se
     * puede diagnosticar en producción.
     *
     * `false` no genera mapas: un stack trace de producción dice
     * `main.8a1f2c.js:1:48213` y ahí se acaba la investigación.
     * `true` los genera y NO los referencia desde el bundle: tú los tienes en
     * el `dist/`, los subes a donde reportes errores, y los usas para traducir
     * un trace — mientras que un curioso con DevTools abierto no ve tu código
     * fuente porque el navegador no sabe que existen.
     *
     * En el Dockerfile de 5.4 los `.map` NO se copian a la imagen final, y ésa
     * es la otra mitad de la decisión: se generan, se guardan fuera, y no se
     * sirven. El ejercicio 20 te hace vivir las tres combinaciones.
     */
    "sourceMap": {
      "scripts": true,
      "styles": false,
      "hidden": true,
      "vendor": false
    }
  }
}
```

**Prueba de fuego**

Corre `ng build --configuration production` y mira dos cosas. Primero, los presupuestos: si sale un aviso, contrasta el número con lo que `deuda.md` lleva anotado desde la Fase 5 y responde cuál de las decisiones de aquellas fases está más cerca de hacerlo saltar. Segundo, `ls dist/certcore/*.map`: los archivos están. Ahora `grep sourceMappingURL dist/certcore/main.*.js` y comprueba que **no** hay ninguna referencia. Eso es `hidden: true`.

### 5.4 El Dockerfile, en dos etapas y sin Node en la final

```dockerfile
# Dockerfile
# Comentarios en español, como todo el código del proyecto. Esto también lo es.

# ─── Etapa 1: construir ───────────────────────────────────────────────────────
# La versión EXACTA, con los tres números. `node:18-alpine` traería el npm que
# le toque ese día, y construir con un npm distinto al de tu máquina es cómo se
# consigue que el lockfile resuelva otro árbol. Fase 0 §5.1 y apéndice A03.
FROM node:18.18.2-alpine AS build

WORKDIR /app

# Se copian SÓLO los manifiestos primero, y esto no es manía: Docker cachea por
# capa. Mientras package.json y el lockfile no cambien, la capa del `npm ci` se
# reutiliza y una recompilación de código tarda segundos en vez de minutos.
# Copiar todo de una vez invalida esa capa con cada línea que toques.
COPY package.json package-lock.json ./

# `npm ci` y no `npm install`: instala exactamente el lockfile y falla si no
# coincide con el package.json, en vez de "arreglarlo" silenciosamente. En una
# imagen es la diferencia entre reproducible y parecido. A03 lo desarrolla.
RUN npm ci

COPY . .

RUN npm run build -- --configuration production

# ─── Etapa 2: servir ──────────────────────────────────────────────────────────
# Aquí NO hay Node. La imagen final es nginx y el `dist/`, y nada más: ni
# `node_modules`, ni código fuente, ni el mock, ni el historial de git. Eso son
# cientos de megabytes menos y, sobre todo, es que nada de lo que no se sirve
# puede filtrarse.
FROM nginx:1.25-alpine

# Los .map se quedan FUERA a propósito: `hidden: true` los generó para que tú
# los tengas, no para servirlos. Guárdalos donde reportes errores.
COPY --from=build /app/dist/certcore/ /usr/share/nginx/html/
RUN rm -f /usr/share/nginx/html/*.map

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /docker-entrypoint.d/40-certcore-config.sh

# El bit de ejecución se pone AQUÍ y no se hereda del sistema de archivos del
# que copiaste: si el archivo llega sin permiso de ejecución, nginx arranca
# igual, ignora el script en silencio, y la aplicación sale con la
# configuración de desarrollo. Es la causa raíz más tonta del incidente 19.
RUN chmod +x /docker-entrypoint.d/40-certcore-config.sh

EXPOSE 80
```

**Detalles con intención**

- **No hay `CMD` ni `ENTRYPOINT`.** La imagen de nginx ya trae los suyos, y su entrypoint ejecuta todo lo que encuentre en `/docker-entrypoint.d/` antes de levantar el servidor. Aprovecharlo es más corto y más robusto que escribir un `ENTRYPOINT` propio que se olvide de hacer `exec nginx -g 'daemon off;'` — que es el error por el que un contenedor deja de responder a `docker stop`.
- **El `40-` del nombre importa.** Los scripts de ese directorio corren en orden alfabético, y los que nginx trae de fábrica ocupan del `10-` al `30-`. El nuestro va después, cuando el resto ya preparó el terreno.
- **`.map` borrados con `rm` y no excluidos del `COPY`.** Copiar el directorio entero y borrar después es una línea; filtrar en el `COPY` exige listar lo que sí quieres y se rompe el día que aparece un tipo de archivo nuevo.

```
# .dockerignore
# Sin esto, el `COPY . .` de la etapa 1 manda al demonio de Docker cientos de
# megabytes que no se usan —y `node_modules` de tu máquina, que puede tener
# binarios de otra arquitectura y romper el `npm ci` de formas creativas.
node_modules
dist
coverage
.git
.angular
mock/db.json
```

### 5.5 El `nginx.conf`, tres bloques y dos incidentes

```nginx
# nginx.conf
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;

    # ─── 1. El 404 al recargar una ruta profunda ─────────────────────────────
    location / {
        # Sin esta línea, recargar estando en /inspections/500 da un 404, y el
        # motivo es que nginx busca un ARCHIVO llamado así. No existe: esa ruta
        # sólo vive dentro del router de Angular, en el navegador.
        # `try_files` dice: intenta el archivo, intenta el directorio, y si no,
        # devuelve index.html — y entonces Angular arranca, lee la URL y pinta
        # lo que toca. Es la línea más copiada del mundo y la que menos gente
        # sabe explicar.
        try_files $uri $uri/ /index.html;
    }

    # ─── 2. El caché, que es el incidente 18 ─────────────────────────────────
    # Los bundles llevan hash en el nombre (`outputHashing: "all"`), así que su
    # contenido NUNCA cambia: un nombre distinto es un archivo distinto. Se
    # pueden cachear un año sin miedo.
    location ~* \.(js|css|woff2?)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # index.html y config.json NO llevan hash y cambian en cada despliegue.
    # Cachearlos es exactamente el incidente 18: despliegas el fix, el usuario
    # recarga, y sigue recibiendo el index.html de ayer — que referencia los
    # bundles de ayer, que siguen existiendo porque nadie borra nada.
    # `no-store` y no `no-cache`: el segundo permite guardar y revalidar, y un
    # proxy intermedio puede interpretar la revalidación con generosidad.
    location = /index.html {
        add_header Cache-Control "no-store";
    }

    location = /assets/config.json {
        add_header Cache-Control "no-store";
    }

    # ─── 3. El backend ───────────────────────────────────────────────────────
    # `apiBaseUrl` vale `/api` en el contenedor, así que las peticiones salen
    # al mismo origen y nginx las reenvía. Eso elimina el CORS de un plumazo:
    # para el navegador, todo viene del mismo sitio.
    # El nombre `certcore-mock` lo resuelve el DNS de la red de Docker, y por
    # eso los dos contenedores tienen que estar en la MISMA red (5.7).
    location /api/ {
        proxy_pass http://certcore-mock:3000/;
        proxy_set_header Host $host;
        # Se propaga la cabecera que el CorrelationIdInterceptor de 2021 estampa
        # en cada petición (Fase 2). Sin esto, la trazabilidad se corta justo
        # aquí, que es donde más falta hace.
        proxy_set_header X-Correlation-Id $http_x_correlation_id;
    }
}
```

**El patrón a memorizar**

> Lo que lleva hash en el nombre se cachea para siempre; lo que no lleva hash no se cachea nunca. Toda la política de caché de una SPA cabe en esa frase, y equivocarse en el lado del `index.html` produce el bug más frustrante que existe: el que ya arreglaste.

### 5.6 El `entrypoint.sh`, que es el corazón de la fase

```sh
#!/bin/sh
# /docker-entrypoint.d/40-certcore-config.sh
#
# Se ejecuta DENTRO del contenedor, antes de que nginx acepte la primera
# conexión, y su único trabajo es traducir variables de entorno a un archivo
# JSON que el navegador pueda pedir.
#
# Ésta es la pieza que hace que la misma imagen sirva para todos los ambientes.
# Todo lo demás de esta fase es andamiaje alrededor de estas quince líneas.

# `set -e` para que el script muera al primer fallo. Sin esto, un error a mitad
# deja un config.json vacío o a medias, nginx arranca igual, y la aplicación
# sale rota con un mensaje que no apunta aquí.
set -e

CONFIG_FILE=/usr/share/nginx/html/assets/config.json

# Valores por defecto pensados para que un `docker run` sin variables funcione
# y sea evidente que le faltan: `/api` es lo que el nginx de al lado sabe
# reenviar, y la etiqueta dice PROD porque es el ambiente que más veces se
# despliega sin pensar.
API_BASE_URL="${API_BASE_URL:-/api}"
ENVIRONMENT_NAME="${ENVIRONMENT_NAME:-PROD}"

# El JSON se escribe entero, no se parchea. Un `sed` sobre el archivo existente
# es la forma habitual de hacer esto y es peor: depende del formato exacto del
# original, se rompe silenciosamente cuando alguien reindenta, y deja el
# archivo a medias si falla. Escribirlo completo no puede quedar a medias.
cat > "$CONFIG_FILE" <<EOF
{
  "apiBaseUrl": "$API_BASE_URL",
  "environmentName": "$ENVIRONMENT_NAME"
}
EOF

# Se imprime en el log de arranque del contenedor. No es decoración: cuando
# alguien pregunte "¿contra qué backend está corriendo esto?", la respuesta
# está en `docker logs` y no hace falta entrar al contenedor a mirar.
echo "[certcore] configuración de arranque: $ENVIRONMENT_NAME -> $API_BASE_URL"
```

**Detalles con intención**

- **`#!/bin/sh` y no `#!/bin/bash`.** La imagen es Alpine y **no trae bash**. Un script con shebang de bash falla con `not found` —un mensaje que parece decir que el script no existe— y es de los errores que cuestan veinte minutos porque el mensaje miente.
- **No valida nada, y la aplicación sí.** Este script escribe lo que le den; el `parseAppConfig` de 5.1 es quien rechaza un `ENVIRONMENT_NAME=PRD`. La validación vive donde está el tipo, no donde está el shell — y así el mismo error se detecta igual venga de un `docker run`, de un Compose o del ConfigMap de la Fase 14.
- **Escribe el archivo entero en vez de parchearlo.** Es la misma decisión que la Fase 7 tomó al publicar una versión de plantilla: reemplazar es atómico de razonar, parchear depende de lo que hubiera antes.

### 5.7 ⭐ La misma imagen, dos veces, comportándose distinto

Éste es el momento de la fase. Todo lo anterior existe para que estos cuatro comandos funcionen.

```bash
# Una red propia, para que los contenedores se vean por nombre. El DNS interno
# de Docker resuelve `certcore-mock` sólo dentro de una red de usuario; en la
# red por defecto tendrías que usar direcciones IP, que cambian.
docker network create certcore-net

# El mock de la Fase 3, en un contenedor. No hace falta una imagen propia:
# se monta el directorio y se ejecuta con la misma versión exacta de Node.
docker run -d --name certcore-mock --network certcore-net \
  -v "$(pwd)/mock:/app/mock" -w /app \
  node:18.18.2-alpine node mock/server.js

# La imagen de la aplicación, construida UNA vez y etiquetada con el tag de
# git que la produjo — no `:latest`. Es lo que pide la convención del curso, y
# es lo que permite contestar "¿qué código hay dentro de esa imagen?".
docker build -t certcore:fase-13 .

# ─── Y ahora lo que importa: la MISMA imagen, dos veces ──────────────────────
docker run -d --name certcore-prod --network certcore-net -p 8080:80 \
  -e ENVIRONMENT_NAME=PROD -e API_BASE_URL=/api \
  certcore:fase-13

docker run -d --name certcore-uat --network certcore-net -p 8081:80 \
  -e ENVIRONMENT_NAME=UAT -e API_BASE_URL=/api \
  certcore:fase-13
```

**Prueba de fuego**

Abre `http://localhost:8080` y `http://localhost:8081` en dos pestañas. La toolbar de una dice **PROD** y la de la otra dice **UAT**. Ahora comprueba que no te estoy engañando:

```bash
# El mismo digest. No es "la misma imagen más o menos": es la misma, bit a bit.
docker inspect --format '{{.Image}}' certcore-prod certcore-uat

# Y la prueba de que la diferencia está fuera del artefacto:
docker exec certcore-prod cat /usr/share/nginx/html/assets/config.json
docker exec certcore-uat  cat /usr/share/nginx/html/assets/config.json
```

Dos archivos distintos dentro de dos contenedores nacidos de la misma imagen, escritos por el mismo script, alimentados por variables distintas. **Eso es todo el capítulo**, y si sale bien, el problema del despliegue de una SPA se te queda entendido.

Para el segundo acto, levanta un mock con caos —`CHAOS=latency,error CHAOS_RATE=0.5`— en otro contenedor, apunta el UAT a ése, y mira las dos pestañas al lado. Misma imagen, mismo código, dos comportamientos. Ésa es la conversación de *"en UAT falla y en PROD no"*, reproducida en tu máquina en treinta segundos.

```
💸 DEUDA TÉCNICA INTENCIONAL — nginx corre como root y escucha en el puerto 80
La imagen `nginx:1.25-alpine` arranca su proceso maestro como root para poder
tomar el puerto 80, que en Linux es privilegiado, y después baja de privilegios
para los workers. Funciona en tu máquina y funciona con `docker run`.
NO SE PAGA AQUÍ, y su destino está documentado fuera del curso: **A09** explica
por qué en el cluster real de una empresa esto es exactamente lo que va a
fallar. Muchas plataformas aplican políticas que prohíben contenedores que
corran como root, y entonces nginx no puede abrir el puerto 80 y el pod entra en
un bucle de reinicios cuyo mensaje —`bind() to 0.0.0.0:80 failed (13:
Permission denied)`— no menciona la política que lo causó.
Lo correcto es la imagen `nginxinc/nginx-unprivileged`, escuchando en 8080, con
`runAsNonRoot` declarado. Son tres líneas y **no se escriben aquí** porque este
capítulo se hace con `docker run`, donde el problema no existe y arreglarlo
enseñaría una precaución sin mostrar de qué protege. El ejercicio 27 lo hace, y
A09 tiene la nota obligatoria de preguntarle al equipo de plataforma antes de
improvisar.
```

### 5.8 El stack trace minificado, y cómo se lee

```bash
# Provoca un error en la aplicación desplegada. El más rápido: para el mock
# y pulsa cualquier cosa que pida datos.
docker stop certcore-mock
```

La consola del navegador dice algo así:

```
ERROR TypeError: Cannot read properties of null (reading 'items')
    at main.8a1f2c3d.js:1:184213
```

Eso, tal cual, es todo lo que un usuario te puede mandar en una captura. Y con los mapas **fuera** de la imagen, es todo lo que hay — a propósito. El procedimiento tiene tres pasos y ninguno pasa por adivinar:

**Uno: consigue el bundle exacto.** El nombre lleva el hash del contenido, así que `main.8a1f2c3d.js` identifica una compilación concreta. Si tu imagen está etiquetada con el tag de git que la produjo —`certcore:fase-13`, no `:latest`— ya sabes qué código hay dentro. Si está etiquetada `:latest`, este paso puede costarte una tarde, y es la razón entera de esa convención.

**Dos: consigue el mapa.** El `.map` correspondiente está en el `dist/` de esa compilación, que guardaste fuera de la imagen. Es lo que `hidden: true` te dio.

**Tres: traduce.** Con el mapa y la posición, `source-map` en Node te devuelve el archivo y la línea del `.ts` original:

```bash
npx source-map@0.7.4 --help   # o el visor de source maps que prefieras
```

y el resultado deja de ser `main.8a1f2c3d.js:1:184213` y pasa a ser
`inspection-form.component.ts:187`.

**Prueba de fuego**

Haz el recorrido entero una vez. Después borra el `.map` y repite: llegas al primer paso y no puedes seguir. Guarda esa sensación — es la diferencia entre "tengo un ticket con una captura" y "sé qué línea falló", y cuesta una opción en el `angular.json`.

### 5.9 `HOTFIX.md` — la única página que te llevas

```markdown
<!-- HOTFIX.md, en la raíz del repositorio -->
# Checklist de hotfix

Una página. Se lee entera antes de tocar nada, el viernes a las seis.

## 1. Antes de escribir código

- [ ] **Reproduce el bug.** Si no puedes reproducirlo, no puedes arreglarlo:
      puedes, como mucho, cambiar algo y esperar. Anota los pasos exactos.
- [ ] **¿Qué ambiente?** Reprodúcelo en el mismo que lo reportó. Si falla en
      PROD y no en UAT, empieza por `docker exec … cat assets/config.json` en
      los dos: el 80 % de esos casos es configuración, no código.
- [ ] **¿Qué versión?** El nombre del bundle lleva el hash, y la imagen lleva
      el tag de git. Averigua **qué código está corriendo** antes de mirar el
      que tienes abierto.
- [ ] **Escribe el test que falla.** Antes del fix, no después. Si no lo has
      visto rojo, no sabes si prueba algo.

## 2. Al escribir el fix

- [ ] **El mínimo, no el correcto.** Distingue el parche de la refactorización
      y escribe el parche. La refactorización va en otra rama, otro día.
- [ ] **En el estilo del archivo que tocas.** Si es de 2021, se toca con
      `constructor` y NgModule. Modernizar mientras arreglas es cómo se rompen
      otras tres cosas.
- [ ] **¿Es un dato derivado?** Antes de cambiar un cálculo, comprueba si el
      valor está además guardado en algún sitio. Si lo está, tienes dos
      verdades y el fix sólo arregla una.
- [ ] **¿Toca fechas?** Pregunta en qué zona y a qué hora del día. Nunca es un
      bug de fechas: es un bug de no haber decidido eso.

## 3. Antes de desplegar

- [ ] La suite pasa: `npm run test:ci`.
- [ ] El test de regresión nuevo está dentro, y lo viste fallar antes.
- [ ] `ng build --configuration production` sin errores de presupuesto.
- [ ] La imagen se etiqueta con el tag de git, **nunca** `:latest`.
- [ ] Los `.map` se guardan fuera de la imagen, donde puedas recuperarlos.

## 4. Después de desplegar

- [ ] Recarga **una vez**, sin Ctrl+Shift+R. Si tienes que forzar la recarga
      para ver el cambio, el bug no está arreglado: está cacheado.
- [ ] Comprueba el ambiente en la toolbar y en `docker logs` del contenedor.
- [ ] Escribe el post-mortem de ocho puntos mientras lo tienes fresco. Sin
      culpabilización: se analiza el sistema, no a la persona.
```

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** recargas la página estando en `/inspections/500` y sale el 404 de nginx.
**Causa:** falta `try_files`. nginx busca un archivo con ese nombre y no existe.
**Fix mínimo:** la línea de 5.5.
**Lo que importa:** el bug no aparece navegando —el router de Angular no pide nada al servidor al cambiar de ruta— sino **recargando**, o abriendo un enlace pegado desde un chat. Es decir: nunca durante el desarrollo y siempre en cuanto un usuario comparte una URL.

**Síntoma:** desplegaste el fix hace dos horas y los usuarios siguen viendo el bug. A ti te funciona.
**Causa:** el `index.html` está cacheado. El navegador del usuario sigue pidiendo los bundles de ayer, que siguen existiendo porque el despliegue no borró nada.
**Fix mínimo:** el `Cache-Control: no-store` sobre `index.html` y `config.json`.
**Lo que importa:** es el **incidente 18**, y a ti te funciona porque tienes DevTools abierto con *Disable cache* puesto desde hace meses. La primera regla de este bug es **no diagnosticarlo con tu navegador**: usa una ventana privada, o `curl -I` y mira las cabeceras.

**Síntoma:** en UAT funciona y en PROD la pantalla se queda en blanco, sin errores visibles.
**Causa:** `config.json` tiene un `apiBaseUrl` que no responde, o un `environmentName` que no está entre los tres válidos. El `APP_INITIALIZER` lanza y Angular no arranca.
**Fix mínimo:** la variable de entorno del `docker run`.
**Lo que importa:** es el **incidente 19**, y la pantalla en blanco es una **decisión**, no un fallo del diseño: el `parseAppConfig` de 5.1 prefiere no arrancar antes que arrancar contra el backend equivocado. Lo que sí hace falta es que el error sea visible — está en la consola y en `docker logs`, y el ejercicio 25 te hace decidir si además debería pintarse en pantalla.

**Síntoma:** el contenedor arranca, la aplicación carga, y la toolbar dice `DEV` en producción.
**Causa:** el `entrypoint.sh` no se ejecutó. Casi siempre por el bit de ejecución, a veces por el shebang de bash en una imagen Alpine.
**Fix mínimo:** el `chmod +x` del Dockerfile.
**Lo que importa:** nginx **arranca igual**. Un script del `docker-entrypoint.d/` que no es ejecutable se ignora sin ruido, así que el síntoma aparece tres capas más allá, en la toolbar. El `echo` del final de 5.6 existe exactamente para esto: si no está en `docker logs`, el script no corrió.

### Pieza forense de esta fase

**El diff de ambientes: por qué la misma imagen se comportó distinto.**

El ticket es el que ordena el final del curso: *"en UAT funciona y en PROD no"*. Cuatro pasos, y el orden importa porque cada uno descarta una capa entera.

**Paso 1 — ¿Es de verdad la misma imagen?** Antes de mirar nada más:

```bash
docker inspect --format '{{.Image}}' certcore-prod certcore-uat
```

Si los digests difieren, no tienes un problema de configuración: tienes dos artefactos distintos, y la pregunta pasa a ser quién construyó cuál. **Ésta es la comprobación que la etiqueta `:latest` hace imposible**, y es la mitad de la razón por la que la convención del curso pide etiquetar con el tag de git.

**Paso 2 — ¿Qué configuración tiene cada uno?** Los dos archivos, uno al lado del otro:

```bash
docker exec certcore-prod cat /usr/share/nginx/html/assets/config.json
docker exec certcore-uat  cat /usr/share/nginx/html/assets/config.json
docker logs certcore-prod 2>&1 | grep certcore
```

El `echo` del `entrypoint.sh` está en los logs justo por esto: contesta la pregunta sin entrar al contenedor, que es lo que un equipo de plataforma te va a dejar hacer y lo otro no.

**Paso 3 — ¿Qué llega al navegador?** No lo que crees que llega: lo que llega.

```bash
# Las cabeceras del index.html. Si aquí no dice `no-store`, tienes el 18.
curl -I http://localhost:8080/

# Y el config.json tal como lo ve un cliente cualquiera.
curl -s http://localhost:8080/assets/config.json
```

Hazlo con `curl` y no con tu navegador. Tu navegador lleva meses con *Disable cache* puesto y te va a mentir con la mejor intención.

**Paso 4 — Y sólo ahora, el código.** Si la imagen es la misma, la configuración es la esperada y las cabeceras están bien, entonces sí es un bug de la aplicación — y entonces tienes el stack trace minificado de 5.8 y el procedimiento para traducirlo.

> 🧭 **La regla que se lleva el estudiante:** *"funciona en UAT y no en PROD"* casi nunca es un bug de código. Es, por orden de frecuencia: configuración distinta, caché, versiones distintas creyendo ser la misma, y sólo al final, código. Ir al código primero es lo que convierte una hora en una tarde.

> 📄 El recorrido completo, con los dos tickets literales y la salida de cada paso, en `forense-fase-13.md`.

**🧨 Rompe a propósito**

Cuatro roturas, una por capa, y las cuatro se arreglan en una línea.

1. **Quita el `try_files`** y recarga estando en `/inspections/500`. 404 de nginx. Ahora navega hasta ahí desde el listado sin recargar: funciona. Explica esa asimetría sin usar la palabra "router".

2. **Quita el `Cache-Control: no-store` del `index.html`**, despliega un cambio visible —el título de la toolbar—, y recarga en una ventana privada. Después recarga con Ctrl+Shift+R. Anota cuántas veces tuviste que forzar y cómo se lo explicarías a un usuario que no puede.

3. **Quita el `chmod +x` del Dockerfile**, reconstruye y levanta. El contenedor arranca, la aplicación funciona, y dice `DEV`. Busca el mensaje del `entrypoint.sh` en `docker logs` y comprueba que no está. Ése es el diagnóstico entero.

4. **Pon `ENVIRONMENT_NAME=PRD`** —sin la O— en el `docker run`. Pantalla en blanco. Abre la consola, lee el mensaje del `parseAppConfig`, y decide en cinco líneas si prefieres eso o una aplicación que arranca con una etiqueta rara. Después haz lo mismo con `API_BASE_URL=http://un-backend-que-no-existe` y observa que **ésta sí arranca**, porque el error no está en el JSON: está en lo que hay al otro lado. Explica por qué esos dos casos se comportan distinto y cuál de los dos es más peligroso.

---

## 🧪 7. Ejercicios (28)

**🟢 Fácil (1–8)**

1. Corre `ng build --configuration production` y `grep -r "localhost:3000" dist/`. Entrega la salida y explica en tres frases por qué está ahí aunque la constante viva en `src/environments/`.
2. Escribe `AppConfig`, `assets/config.json` y `AppConfigService`. Comprueba con `ng serve` que la toolbar sigue diciendo `DEV`.
3. **Diagnóstico.** Edita `assets/config.json` a mano poniendo `"environmentName": "UAT"` y recarga **sin reiniciar `ng serve`**. Anota qué cambió y qué no, y explica por qué esto no se podía hacer ayer.
4. Registra el `APP_INITIALIZER` en `AppModule`. Después quita el `multi: true` y anota qué se rompe y por qué.
5. **Diagnóstico.** Borra `apiBaseUrl` de `AppEnvironment` y corre `ng build` **sin arreglar nada**. Cuenta los errores y en qué archivos: es el mapa completo de la deuda de la Fase 0. Anota el número en `deuda.md`.
6. Activa `sourceMap.hidden` y comprueba las dos cosas: que los `.map` existen en `dist/` y que ningún `.js` los referencia con `sourceMappingURL`.
7. **Diagnóstico.** Corre el build de producción y anota si algún presupuesto avisa. Contrasta la cifra del bundle inicial con las que `deuda.md` lleva desde la Fase 5 y di cuál de aquellas decisiones está más cerca de hacerlo saltar.
8. Escribe el `.dockerignore`. Después haz `docker build` con y sin él, y entrega los dos tamaños del contexto que el demonio reporta al empezar.

**🟡 Intermedio (9–16)**

9. Escribe el Dockerfile de dos etapas y constrúyelo. Comprueba con `docker run --rm certcore:fase-13 ls /usr/share/nginx/html` que dentro no hay `node_modules`, ni `.ts`, ni `.map`.
10. **Diagnóstico.** Cambia una línea de un componente y reconstruye. Anota qué capas reutiliza Docker y cuáles no. Ahora mueve el `COPY package.json package-lock.json` a después del `COPY . .` y repite: entrega los dos tiempos.
11. Escribe el `nginx.conf` con `try_files` y levanta el contenedor. Comprueba que `/inspections/500` recarga bien y que `/lo-que-sea` cae en el 404 de Angular y no en el de nginx.
12. **Diagnóstico.** Haz el 🧨 número 1: quita `try_files`, recarga en una ruta profunda, y después navega hasta la misma ruta desde el listado. Explica la asimetría con la pestaña Network delante.
13. Escribe el `entrypoint.sh` y comprueba con `docker exec` que el `config.json` de dentro del contenedor tiene los valores de las variables que pasaste.
14. **Diagnóstico.** Haz el 🧨 número 3: quita el `chmod +x`, reconstruye, y diagnostica el síntoma con `docker logs` sin abrir el Dockerfile. Escribe los pasos que seguiste, en orden.
15. Levanta la red, el mock y **las dos** instancias de la aplicación. Entrega la captura de las dos toolbars y la salida de `docker inspect --format '{{.Image}}'` de las dos.
16. Cambia `#!/bin/sh` por `#!/bin/bash` en el `entrypoint.sh`, reconstruye y levanta. Entrega el mensaje de error exacto y explica por qué parece decir que el script no existe.

**🟠 Difícil (17–23)**

17. **Diagnóstico.** Reproduce el **incidente 18**: quita el `no-store` del `index.html`, despliega un cambio visible, y compruébalo en una ventana privada y con `curl -I`. Entrega las cabeceras de los dos casos y explica por qué tu navegador habitual no sirve para diagnosticar esto.
18. Levanta un tercer contenedor con el mock en modo caos (`CHAOS=latency,error CHAOS_RATE=0.5`) y apunta el UAT a él. Documenta tres diferencias observables entre las dos pestañas sin tocar una línea de código.
19. 🧬 **Estilo.** Ticket: *"la toolbar debería mostrar también contra qué backend está corriendo, no sólo el ambiente"*. El archivo es el componente de layout, **heredado** de la Fase 1. Escribe el fix y justifica en cinco líneas por qué no lo convertiste a standalone ni le cambiaste el `constructor` por `inject()` aunque tocaste seis líneas.
20. **Diagnóstico.** Provoca un error en la aplicación desplegada y recorre los tres pasos de 5.8 hasta llegar a la línea del `.ts`. Después borra el `.map` y repite. Entrega hasta dónde llegaste en cada caso.
21. 🧬 **Estilo.** El `APP_INITIALIZER` está en un `AppModule` heredado y sus consumidores son servicios standalone. Escribe la variante en la que la aplicación arranca con `bootstrapApplication` y el mismo provider va en el array de la llamada, en una rama de usar y tirar. Cuenta los archivos que tuviste que tocar, y decide si lo entregarías — sabiendo que la Fase 5 declaró que los nueve módulos heredados no se convierten.
22. **Diagnóstico.** Reproduce el **incidente 19** de las dos formas del 🧨 número 4: `ENVIRONMENT_NAME=PRD` y un `API_BASE_URL` que no responde. Explica por qué una impide arrancar y la otra no, y cuál de las dos preferirías que le pasara a un usuario.
23. Sirve las fuentes de Material desde el propio contenedor en vez de desde `fonts.googleapis.com`, que es lo que el schematic de la Fase 1 dejó puesto. Mide el peso que añade a la imagen y decide si compensa — pensando en un despliegue sin salida a internet, que en sistemas de certificación es más común de lo que parece.

**🔴 Muy difícil (24–28)**

24. Escribe el post-mortem completo de ocho puntos del **incidente 18** siguiendo `formato-cuaderno-incidentes.md`, con su par de tags. El punto 3 —evidencia observable— es el difícil: describe qué mirar cuando el síntoma **no se reproduce en la máquina de quien lo investiga**, y por qué eso lo convierte en uno de los bugs más caros que existen.
25. Escribe el post-mortem completo de ocho puntos del **incidente 19** con su par de tags. En el punto 7 —prevención— contesta la pregunta que 5.1 deja abierta: ¿debería la pantalla en blanco convertirse en una pantalla que **explique** que la configuración falló? Diséñala si decides que sí, y di qué le pasa entonces a la garantía de que la aplicación no arranca mal configurada.
26. **La misma imagen en tres ambientes.** Añade un tercero —`DEV` apuntando al mock de tu máquina desde el contenedor— y monta los tres a la vez. Después escribe el `docker-compose.yml` que hace todo lo de 5.7 en un comando, y argumenta en cinco líneas qué se gana y qué se pierde al esconder los cuatro `docker run` detrás de un archivo.
27. 💸 **Paga la deuda de esta fase en una rama.** Sustituye la imagen base por `nginxinc/nginx-unprivileged`, mueve el puerto a 8080, ajusta el `nginx.conf` y el `EXPOSE`, y comprueba que todo sigue funcionando. Después responde: ¿por qué no lo dejamos así de entrada, si son tres líneas? Lee la nota de **A09** antes de contestar.
28. **Diagnóstico.** Te dan un contenedor corriendo, sin acceso al repositorio y sin saber qué versión es. Con `docker inspect`, `docker exec`, `docker logs` y `curl`, escribe el procedimiento completo para contestar tres preguntas: qué código hay dentro, contra qué backend habla, y si el `index.html` que sirve se puede cachear. Después provoca el caso más difícil: la imagen está etiquetada `:latest`. Di hasta dónde llegas y qué te falta.

**🔥 Opcionales**

- 🔥 **El pipeline.** Escribe el archivo que correría `npm ci`, `npm run test:ci` y `docker build` en la plataforma de CI que uses. El CI real está fuera de alcance; escribirlo y ver por qué falla la primera vez —casi siempre, Chrome dentro del contenedor— no lo está.
- 🔥 **Imagen multi-arquitectura.** Construye la imagen para `amd64` y `arm64` con `docker buildx`, y comprueba en un Mac con chip M qué pasa al correr la variante equivocada. Es el trabajo preparatorio de la **Fase 14** y vive en **A12**.
- 🔥 **Cabeceras de seguridad.** Añade `Content-Security-Policy`, `X-Content-Type-Options` y `Referrer-Policy` al `nginx.conf`, y comprueba cuál de ellas rompe la aplicación primero. Angular Material inyecta estilos en línea, así que la CSP te va a dar una conversación interesante.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v16.angular.io/guide/build — configuraciones de build, `fileReplacements` y presupuestos. ⚠️ La página de la 16 describe el builder de Webpack; el de esbuild llegó después y cambia los nombres de algunas opciones.
- https://v16.angular.io/api/core/APP_INITIALIZER — la firma exacta, incluido el `multi: true` que casi nadie explica.
- https://v16.angular.io/guide/workspace-config#optimization-and-source-map-configuration — las cuatro opciones de `sourceMap`, incluida `hidden`.
- https://docs.docker.com/build/building/multi-stage/ — el patrón de dos etapas.
- https://docs.docker.com/reference/dockerfile/ — la referencia del Dockerfile, para `COPY --from` y el orden de las capas.
- https://github.com/nginxinc/docker-nginx/tree/master/entrypoint — los scripts que la imagen oficial de nginx ejecuta desde `/docker-entrypoint.d/`, que es de dónde sale el mecanismo de 5.4. Leerlos es diez minutos y explica el `40-` del nombre.
- https://nginx.org/en/docs/http/ngx_http_core_module.html#try_files — `try_files`, la línea más copiada del mundo.
- https://developer.mozilla.org/es/docs/Web/HTTP/Headers/Cache-Control — la diferencia entre `no-cache`, `no-store` e `immutable`, que es exactamente lo que separa el incidente 18 de su ausencia.
- https://github.com/mozilla/source-map — la librería para traducir un stack trace minificado, si prefieres hacerlo a mano en vez de con un servicio.

**Orden de lectura sugerido:** los scripts del entrypoint de nginx **antes** de escribir 5.4, que son cortos y explican por qué el Dockerfile no lleva `CMD`. La página de `Cache-Control` **después** de provocar el incidente 18, no antes. **A03** si el `npm ci` frente a `npm install` no te queda claro, y **A09** antes del ejercicio 27, que es donde la 💸 de esta fase se vuelve concreta. **A12** sólo si estás en un Mac con chip M y vas a seguir a la Fase 14.

---

## 🚀 9. Cierre y conexión con la siguiente fase

CertCore está desplegado. Una imagen, dos contenedores, dos ambientes, y la certeza de que el artefacto que probaste es el que está corriendo.

Y con eso se cierra el círculo que el curso abrió en la Fase 0, cuando la URL del backend estaba escrita dentro de un componente y el ejercicio 27 te hizo buscarla en el `dist/` con `grep`. Ese `grep` era la pregunta; esto es la respuesta. Trece fases después, el mismo problema, resuelto de la única forma en que se puede resolver: sacando de la compilación todo lo que puede cambiar entre dos despliegues.

**Lo que sabes hacer ahora que no sabías hace trece fases.** Abrir un archivo de este proyecto y decir en diez segundos si es de 2021 o de 2024, y qué implica eso para el fix que vas a escribir. Reproducir un bug desde un ticket vago. Explicar por qué una inspección de agosto se ve con la plantilla de agosto, y arreglarlo cuando no. Rastrear una fuga de suscripción hasta el `BehaviorSubject` que la sostiene. Escribir el test de regresión **antes** del fix. Y contestar *"¿por qué esta imagen se comportó distinto en UAT y en PROD?"* empezando por la pregunta correcta, que casi nunca es sobre el código.

**Lo que no sabes hacer, y conviene decirlo.** Este curso no te ha enseñado a diseñar una arquitectura de frontend desde cero: te ha enseñado a mantener una que ya existe, que es un trabajo distinto y más común. No has hecho e2e, ni CI, ni observabilidad, ni accesibilidad — cuatro cosas que un sistema en producción de verdad necesita. Y CertCore mismo se queda con deudas que el curso nombró y no pagó: la trazabilidad que el `alcance-del-proyecto.md` §5 promete y que cuatro fases reclamaron sin éxito, el trabajo sin conexión que quedó como historia, y unas alertas que no alertan a nadie porque no hay canal. Un sistema heredado real se parece más a eso que a un repositorio limpio, y esa parte también era la lección.

**Y sobre Angular 17 en adelante**, la respuesta honesta: signals y control flow son mejores que lo que este proyecto usa, y **eso no es un argumento para migrar CertCore**. Una migración se justifica con un problema concreto —una versión sin soporte, una dependencia que no avanza, un rendimiento que no da— y no con una lista de novedades. Lo que sí conviene es saber leerlas, porque el código nuevo que llegue las va a traer. Para eso está **A11**, y para eso la Fase 12 dejó la pincelada.

La **Fase 14** es 🔥 y **no es requisito de nada**. Toma la imagen que acabas de construir, sin modificarle una línea, y la lleva a un Kubernetes local: un ConfigMap montado como volumen alimentando el mismo `entrypoint.sh` que escribiste hoy. Si la haces, vas a comprobar algo que vale la pena: el orquestador **no resuelve** el problema de la configuración horneada. Sólo cambia quién le pasa las variables al mismo script de quince líneas.

> **La señal de que quedó bien:** cuando alguien pregunta por qué falla en producción, no abres el código. Abres `docker inspect`, `docker exec` y `curl -I`, en ese orden — y las tres veces de cada cuatro, ahí está la respuesta.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-13 -m "F13 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 13: …`) y los de ejercicio su
> número (`fase 13 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f13/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Esta fase paga la deuda 💸 **más vieja del curso** y su factura ya estaba
> escrita antes de que existiera el código: `git diff fase-00 fase-13 --
> src/environments src/assets` enseña una URL saliendo de un componente,
> pasando por un archivo de entorno y acabando en un JSON que escribe un shell
> script. Trece tags de distancia para trece líneas de diferencia, y ése es
> exactamente el punto.
>
> Y hay algo que sólo esta fase hace: **el tag de git deja de ser sólo un
> marcador del curso y se convierte en la etiqueta de la imagen.**
> `docker build -t certcore:fase-13 .` no es una convención de nombres, es lo
> que permite contestar *"¿qué código hay dentro de ese contenedor?"* sin
> adivinar. A partir de hoy, cada imagen que construyas lleva el nombre del
> commit que la produjo — y la Fase 14, si la haces, va a cargar exactamente
> esa etiqueta en el cluster.

---

## 📌 Pendientes sugeridos

- **La frase de la Fase 5 sobre `main.ts` hay que corregirla.** Aquella fase escribió que CertCore seguiría arrancando con `platformBrowserDynamic().bootstrapModule(AppModule)` *"hasta la Fase 13"*, y esta fase **no** lo convierte: el `APP_INITIALIZER` funciona igual en las dos formas y convertir el `AppModule` contradice su propia regla de que los nueve módulos heredados no se tocan. El ejercicio 21 hace escribir la variante y decidir. → **Aviso para una segunda pasada sobre la Fase 5**: la frase correcta es *"y va a seguir así hasta el final del curso"*.
- **El mock quedó contenedorizado a medias y a propósito.** Se levanta montando el directorio sobre una imagen de Node en vez de construir una imagen propia, porque construirla no enseña nada sobre Angular y añade un Dockerfile más que mantener. Es una decisión, no un olvido, y conviene que la Fase 14 lo sepa: allí el mock necesita un Deployment y esa decisión hay que volver a tomarla. → **Aviso para el chat de la Fase 14.**
- **La zona horaria no reservó un tercer incidente, y es deliberado.** El contenedor corre en UTC, pero el reloj que importa para un certificado es el del navegador del usuario y el offset del negocio, que son fijos desde la Fase 7. El caso de despliegue es el mismo incidente 15 de la Fase 10 con otra ropa, y reservarle un ID nuevo habría sido repetir. Queda como paso del recorrido forense. → **Nota para el chat del cuaderno de incidentes.**
- **`HOTFIX.md` vive en la raíz del repositorio y no dentro del material del curso.** Es el único archivo que el estudiante se lleva al trabajo, así que tiene que estar donde lo encuentre — no en un capítulo. Si el cierre del track forense (`forense-master.md`) escribe su propia versión, hay que fundirlas y dejar una: dos checklists de hotfix que dicen cosas parecidas es peor que ninguno. → **Aviso para el chat del track forense.**
- **A09 hereda dos cosas concretas de esta fase**, además de su nota obligatoria sobre el cluster real: por qué `:latest` te muerde —ya anunciado en `00-convencion-de-git-y-tags.md`— y el desarrollo completo de la 💸 de nginx como root, que el ejercicio 27 sólo hace tocar. → **Aviso para el chat de A09.**
- **Las cabeceras de seguridad quedaron fuera y son la ausencia más visible del `nginx.conf`.** Un nginx de producción real lleva TLS y unas cuantas cabeceras más; aquí no hay ninguna, y el ejercicio 🔥 sólo las prueba. Es defendible por alcance y conviene no fingir que el archivo está completo. → **Decisión de proyecto**: o un apéndice 🔥 corto, o una línea explícita en `alcance-del-proyecto.md` §8.
- **El `environmentName: 'UAT'` llevaba doce fases declarado en el tipo y sin producir.** Aparece hoy por primera vez, y es un buen ejemplo de algo que este curso hace y no explica: los tipos de la Fase 1 anticipaban decisiones que la Fase 13 iba a tomar. Merece una frase en alguna parte, porque es la clase de detalle que un lector atento nota y agradece que se confirme. → **Pendiente de revisión editorial.**
- 🔥 **Un diagrama de las dos líneas de tiempo** —compilación arriba, arranque abajo, con `environment.ts` en una y `config.json` en la otra, y la flecha del `entrypoint.sh` cruzando— explicaría §4 mejor que sus cuatro párrafos, y es la idea central del final del curso. Es el undécimo pendiente de ilustración. Pendiente de dibujo, no de contenido.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 18 | "Desplegamos el arreglo hace dos horas y la gente sigue viendo el error; a mí me funciona" | Despliegue | 🔴 |
| 19 | "En UAT entra bien y en producción la pantalla se queda en blanco" | Despliegue | 🔴 |
