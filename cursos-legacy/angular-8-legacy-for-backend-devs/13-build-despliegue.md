# 🚚 Fase 13 — Build, despliegue y cierre

> Tutorial Angular 8 — Laboratorio clínico · Fase 13 de 14 · **7 horas**
> Depende de: Fase 12 · Habilita: Fase 14
> Apéndices de apoyo: [A04 (Webpack oculto)](./a04-webpack-oculto.md) · [A09 (Kubernetes para el dev de front)](./a09-kubernetes.md) · [A03 (Node y npm)](./a03-node-npm.md) · [A07 (i18n en Angular 8)](./a07-i18n.md) · [A02 (Bootstrap 4 + Sass)](./a02-bootstrap-sass.md) · [A13 (Docker + Colima en Apple Silicon)](./a13-docker-colima.md) · [Incidentes asociados](./cuaderno-incidentes.md): 19, 20

---

## 🎯 1. Propósito

Llegaste hasta acá con una aplicación que corre con `ng serve` y habla con un mock en `localhost:3000`. Funciona en tu máquina. Ese es exactamente el problema.

El sistema que vas a mantener no se despliega con `ng serve`. Se compila una vez, se mete en una imagen de contenedor, y esa **misma imagen** se levanta en UAT, en staging y en PROD. Si la aplicación llevara la dirección del API horneada adentro —como la llevó durante once fases—, cada ambiente necesitaría su propia compilación, y en el momento en que alguien despliega en PROD la imagen que compilaste para UAT, tienes el bug más clásico y más caro de todos: *funciona en UAT y no en PROD*, sin un solo error en consola que te diga por qué.

Esta fase enseña la lección que ordena todo el final del curso: **la imagen es la misma en todos lados; lo único que cambia es lo que le inyectas por fuera al arrancar.** Vas a construir un Dockerfile que compila la aplicación y la sirve con nginx, un `nginx.conf` que no se rompe cuando alguien recarga una ruta profunda del router, y un `entrypoint.sh` que escribe la configuración desde variables de entorno un instante antes de que nginx acepte la primera petición. Al final vas a levantar la misma imagen dos veces, con dos direcciones de API distintas, y verla comportarse distinto sin haberla recompilado. Ahí cae la ficha.

Y como es la última fase obligatoria, cierra el curso: te llevas un checklist de hotfix de una página y un vistazo honesto a lo que viene después de Angular 8.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `docker build -t lab-frontend .` construye la imagen sin errores, en dos etapas, y la imagen final **no** contiene `node_modules` ni el código fuente TypeScript — solo el `dist` compilado servido por nginx.
- [ ] `docker run -p 8080:80 -e API_URL=http://uat.interno:3000 lab-frontend` levanta la aplicación en `http://localhost:8080` y, al abrir la pestaña Network, ves que `assets/config.json` se sirvió con `"apiUrl": "http://uat.interno:3000"` — el valor que le pasaste, no el que compilaste.
- [ ] La misma imagen, levantada con `-e API_URL=http://prod.interno:3000`, sirve un `config.json` con la otra dirección. **No recompilaste nada.** Ese es el entregable central de la fase.
- [ ] Recargas la página estando en una ruta profunda (`/patients/42/orders`) y **no** obtienes un 404 de nginx: la aplicación se vuelve a montar en esa ruta. El `try_files` está haciendo su trabajo.
- [ ] `AppConfigService` expone `apiUrl` y el resto de la configuración, y `PatientsService` (y todos los demás) lee de ahí en vez de `environment.apiUrl`. Puedes señalar en el código el punto exacto donde la aplicación deja de depender del valor horneado.
- [ ] Los diccionarios de i18n se sirven bien desde el contenedor: cambias un texto en `es.json`, reconstruyes, recargas, y **ves el texto nuevo** sin tener que limpiar la caché del navegador a mano. Y si pides un idioma que no existe, obtienes un 404 honesto y no un `index.html` disfrazado de JSON.
- [ ] Tienes tu **checklist de hotfix** de una página, escrito con tus palabras, guardado donde lo vas a encontrar un viernes a las seis de la tarde.

---

## 🚫 3. Qué NO entra todavía

- Orquestación —levantar la imagen en un cluster, replicar, hacer rolling updates— → **Fase 14** (opcional). Acá la imagen corre con `docker run` a mano; el cluster es otra conversación.
- Pipelines de CI/CD —compilar y publicar la imagen en cada push, escanear vulnerabilidades, promover entre ambientes— → **fuera de alcance del curso** (`alcance-del-proyecto.md`). Acá compilas en tu máquina.
- Optimización del peso del bundle —`webpack-bundle-analyzer`, budgets, tree-shaking manual, la unificación de las dos librerías de gráficos que quedó pendiente en la Fase 10— → **Apéndice A04 (Webpack oculto)**. El Dockerfile de esta fase compila con `--prod` y no discute cuánto pesa el resultado.
- La migración a i18n de compile-time —tres builds, tres artefactos, un `location` por idioma— → se describe en la 🔥 de §5.9 y los comandos están en el **Apéndice A07 §9**, pero **no se implementa**: el proyecto sirve un solo bundle con diccionarios en runtime.
- Construcción multi-arquitectura (`docker buildx`, imágenes arm64 para Apple Silicon) → **Apéndice A13**, opcional por plataforma. Acá se compila para la arquitectura de tu máquina.
- Correr el contenedor como usuario sin privilegios, que es lo que el cluster real de la empresa probablemente exige → se menciona en la ⚠️ de §5.4 pero **no se resuelve acá**; qué política lo exige, qué tres cosas hay que cambiar a la vez y a quién preguntar están en el **Apéndice A09 §8**.

---

## 🧠 4. Concepto mínimo

### El problema antes que la herramienta

En la Fase 1 pusiste `apiUrl` dentro de `environment.ts` y te dije que guardaras una frase: ese valor **queda horneado en el bundle al compilar**, no se lee al arrancar. Angular resuelve la configuración por ambiente con un mecanismo llamado *file replacement*: al compilar con `--prod`, el CLI sustituye `environment.ts` por `environment.prod.ts` antes de que Webpack empaquete, y lo que queda adentro del `.js` final es texto fijo. Un `grep` en el bundle te encuentra la dirección del API como una cadena literal más.

Eso está bien mientras compilas una imagen por ambiente. Deja de estar bien en el instante en que decides —con toda la razón— compilar **una sola imagen** y promoverla de UAT a PROD sin tocarla. Porque esa imagen lleva la dirección de UAT cocida adentro, y en PROD va a seguir hablándole a UAT, en silencio, hasta que un paciente aparezca en el ambiente equivocado y alguien te abra un ticket que empieza con "a veces".

El choque es estructural y vale la pena nombrarlo con precisión: **Angular hornea la configuración en tiempo de compilación; cualquier despliegue en contenedores espera inyectarla en tiempo de arranque.** Esas dos frases están en desacuerdo, y esta fase es el puente entre ellas.

### La herramienta: leer la config al arrancar, no al compilar

La idea es sacar `apiUrl` (y cualquier otra cosa que cambie entre ambientes) del bundle y ponerla en un archivo que la aplicación lea **cuando arranca en el navegador**, no cuando se compila. Ese archivo va a ser `assets/config.json`, un JSON diminuto servido como un asset estático más. La aplicación lo pide con `HttpClient` antes de mostrar nada, guarda el resultado en un servicio, y desde ese momento todos preguntan al servicio en vez de al `environment`.

"Antes de mostrar nada" es la parte delicada. Si la aplicación empieza a renderizar y a disparar peticiones antes de saber a qué API hablarle, tienes una condición de carrera. Angular tiene un gancho exacto para esto y **ya lo usaste en la Fase 2**: el `APP_INITIALIZER`. Es un token que recibe una función que devuelve una promesa, y Angular no arranca la aplicación hasta que esa promesa resuelve. En la Fase 2 lo usaste para cargar los diccionarios de i18n antes de pintar la primera pantalla; acá lo usas para cargar la configuración. El mismo gancho, otro pasajero. Como `APP_INITIALIZER` es `multi: true`, los dos conviven sin pisarse.

> 📝 **Nota de época.** En 2019 esto era artesanal: no había una receta oficial de Angular para configuración en runtime, así que cada equipo montaba su variante de "cargar un JSON en el `APP_INITIALIZER`". Hoy el patrón es el mismo —Angular sigue sin traer nada mejor de fábrica— así que lo que aprendes acá no envejeció. Lo que cambió es todo lo de alrededor: el build, Ivy, standalone. La configuración en runtime sigue siendo este JSON y esta promesa.

### La herramienta: el contenedor de dos etapas

Compilar Angular necesita Node, npm, todo `node_modules` y el CLI: cientos de megas de herramientas que **no hacen falta para servir la aplicación**. Servir la aplicación necesita un servidor de archivos estáticos y nada más. Meter las dos cosas en la misma imagen te deja un contenedor gordo, lento de arrancar y con más superficie de ataque de la necesaria.

La solución es un **build multi-stage**: el Dockerfile define dos etapas. La primera tiene Node y compila; produce el `dist`. La segunda parte de una imagen de nginx limpia, copia **solo el `dist`** de la primera etapa, y descarta todo lo demás. La imagen final no tiene Node, no tiene `node_modules`, no tiene tu código TypeScript: tiene HTML, JS, CSS y nginx. Si vienes de backend, es la misma idea que compilar un binario en una imagen con el toolchain y copiarlo a una imagen mínima para correrlo. El paralelo aguanta entero.

### La herramienta: nginx y el 404 al recargar

Tu aplicación es una SPA: el router de Angular vive en el navegador y cambia la URL sin pedirle nada al servidor. Cuando estás en `/patients/42` y navegas a `/orders`, nginx no se entera; el router reescribe la barra de direcciones y monta el componente. Pero si **recargas** estando en `/orders`, el navegador sí le pide `/orders` a nginx, y nginx busca un archivo llamado `orders` en el disco, no lo encuentra, y devuelve un 404. La aplicación entera desaparece por recargar una página que "estaba ahí".

La solución cabe en una línea de configuración: `try_files $uri $uri/ /index.html`. Le dice a nginx: "busca el archivo pedido; si no existe, busca el directorio; si tampoco, sirve `index.html`". Así cualquier ruta que nginx no reconozca cae en `index.html`, Angular arranca, el router lee la URL y monta el componente correcto. Es el incidente 20 de este curso, resuelto de antemano.

### La herramienta: el `entrypoint.sh`

Falta el pegamento. La imagen se construyó una vez, con un `config.json` de plantilla que tiene placeholders en vez de valores. Cuando el contenedor arranca —no cuando se construye, cuando **arranca**— un pequeño script lee las variables de entorno que le pasaste con `-e`, las sustituye en la plantilla, escribe el `config.json` final, y recién entonces le cede el control a nginx. Ese script es el `entrypoint.sh`, y la herramienta que hace la sustitución se llama `envsubst`, que viene con la imagen de nginx.

Ese script es el corazón de la fase. Es la línea donde "la misma imagen" se convierte en "comportamiento distinto según el ambiente". Todo lo demás es andamiaje alrededor de este momento.

---

## 💻 5. Código mínimo con comentarios

Vas a tocar seis piezas, en este orden: la plantilla de configuración, el servicio que la lee, su registro en el `AppModule`, el ajuste en los servicios que hoy usan `environment`, y del lado de infraestructura el `Dockerfile`, el `nginx.conf` y el `entrypoint.sh`. Al final, la prueba de fuego que lo amarra todo.

### 5.1 El punto de partida: lo que la Fase 1 dejó horneado

No hay código nuevo acá; es el dolor antes de la herramienta. Así quedó `environment.prod.ts` en la Fase 1:

```typescript
// src/environments/environment.prod.ts — tal como lo dejó la Fase 1
export const environment = {
  production: true,
  // Este valor se hornea en el bundle al compilar con --prod. Si promueves
  // esta misma imagen a PROD, seguirá apuntando acá. Ese es el bug a matar.
  apiUrl: 'http://localhost:3000'
};
```

Compila con `npx ng build --prod`, abre cualquiera de los `.js` generados en `dist/` y busca `localhost:3000`. Ahí está, como texto. Esa cadena es la que vamos a sacar del bundle.

### 5.2 `src/assets/config.template.json` — la plantilla con placeholders

```json
{
  "apiUrl": "${API_URL}",
  "environmentName": "${ENVIRONMENT_NAME}",
  "timeZone": "${APP_TIME_ZONE}",
  "features": {
    "deliveryPdfEnabled": ${FEATURE_DELIVERY_PDF}
  }
}
```

Es una **plantilla**, no la configuración final: los `${...}` son marcadores que `envsubst` va a reemplazar en el arranque del contenedor. No lleva comentarios porque JSON no los admite, y no es un descuido: si algún día alguien mete `// comentario` acá, `envsubst` lo copia tal cual y el `JSON.parse` del navegador revienta con un mensaje que no menciona este archivo.

Fíjate en `deliveryPdfEnabled`: es un **feature flag**. Un booleano que decide si una funcionalidad está encendida en este ambiente. Lo metemos desde ya porque es la herramienta que convierte un hotfix aterrador en uno manejable: si mañana la entrega de PDF empieza a fallar en PROD, apagas la feature con una variable de entorno y un reinicio del contenedor, sin recompilar y sin desplegar código nuevo. Volvemos sobre esto en la pieza forense (§6).

> ⚠️ Este archivo es la plantilla. El `config.json` **real** lo genera el contenedor al arrancar y no debe estar en el control de versiones con valores reales adentro. Agrega `src/assets/config.json` a tu `.gitignore`: es un artefacto de arranque, no código fuente.

### 5.3 `src/app/core/config/app-config.service.ts` — el que lee la config

```typescript
// src/app/core/config/app-config.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

// La forma de la configuración. La tipamos aunque sea a mano: el día que alguien
// agregue una clave al config.json y se olvide de la plantilla, este tipo es la
// única pista que va a tener antes de que reviente en runtime.
export interface AppConfig {
  apiUrl: string;
  environmentName: string;
  // La zona del laboratorio, no la del navegador del usuario. Viene de la Fase 2,
  // donde vivía en environment.ts, y se muda acá por la misma razón que apiUrl:
  // es un valor que cambia entre ambientes. Si el sistema se desplegara para un
  // laboratorio en otra zona, esto es lo único que habría que tocar.
  timeZone: string;
  features: {
    deliveryPdfEnabled: boolean;
  };
}

@Injectable({ providedIn: 'root' })
export class AppConfigService {

  // any tolerado a propósito: hasta que load() resuelva, no hay config, y no
  // queremos que el compilador nos obligue a inicializarla con un objeto falso
  // que después confunda al que debuguee. Se comenta, no se corrige.
  private config: AppConfig = null as any;

  constructor(private http: HttpClient) { }

  // Devuelve una promesa porque el APP_INITIALIZER espera una promesa y no
  // arranca la aplicación hasta que resuelva. function () {} y no arrow: es el
  // estilo del curso y además .toPromise() no necesita capturar this.
  load(): Promise<void> {
    // `var self` y no `.bind(this)`: el callback vive dentro de un .then() de
    // promesa, no de un observable, y ahí el idioma habitual del curso no aplica
    // limpio. Es la segunda de las dos excepciones que declara la guia §6.
    var self = this;
    // Le pegamos una marca de tiempo para saltarnos el cache: si el navegador
    // sirve un config.json viejo, apuntas al ambiente equivocado y no hay error.
    // Es exactamente la clase de bug que esta fase existe para prevenir.
    return this.http.get<AppConfig>('assets/config.json?ts=' + Date.now())
      .toPromise()
      .then(function (loaded) {
        self.config = loaded;
      });
  }

  // A partir de que load() resolvió, todo el mundo pregunta acá. Nadie vuelve a
  // importar environment para leer apiUrl.
  get apiUrl(): string {
    return this.config.apiUrl;
  }

  get environmentName(): string {
    return this.config.environmentName;
  }

  get timeZone(): string {
    return this.config.timeZone;
  }

  isFeatureEnabled(feature: string): boolean {
    // Acceso defensivo: si la feature no existe en el config, se asume apagada.
    // En un feature flag, "no se que es esto" siempre significa "apagado".
    return !!(this.config.features && (this.config.features as any)[feature]);
  }
}
```

**Detalles con intención:**

- El `?ts=` no es paranoia. El `config.json` es un asset estático y nginx lo cachea; sin el rompe-cache, un contenedor recién arrancado con la config nueva puede servirle a un navegador la versión que ese navegador guardó ayer. Apuntas al ambiente equivocado y no hay ni un error en consola. Este es el incidente 19.
- `config` empieza en `null`. Si algún código corre `apiUrl` **antes** de que `load()` resuelva, revienta con un `Cannot read property 'apiUrl' of null` —feo pero honesto— en vez de devolver un valor vacío que dispara una petición a `/patients` sin host. El error ruidoso es preferible al silencioso.

### 5.4 `src/app/app.module.ts` — registrar el segundo `APP_INITIALIZER`

En la Fase 2 registraste un `APP_INITIALIZER` para i18n dentro de `I18nModule`. Este es un segundo inicializador que convive con aquel gracias a `multi: true`. Angular espera a que **los dos** resuelvan antes de arrancar.

```typescript
// src/app/app.module.ts (fragmento: providers)
import { APP_INITIALIZER, NgModule } from '@angular/core';
import { AppConfigService } from './core/config/app-config.service';

// Función exportada, no arrow inline: el compilador AOT de Angular 8 no sabe
// serializar closures anónimas en un factory. Compila en dev y revienta en
// ng build --prod con un error que no menciona esta línea. Mismo motivo por el
// que la Fase 2 exportó httpLoaderFactory. Guárdate el patrón.
export function appConfigInitializer(configService: AppConfigService) {
  return function () {
    return configService.load();
  };
}

@NgModule({
  // ...imports, declarations...
  providers: [
    {
      provide: APP_INITIALIZER,
      useFactory: appConfigInitializer,
      deps: [AppConfigService],
      // multi: true es lo que deja convivir este initializer con el de i18n.
      // Sin el, el segundo pisa al primero y una de las dos cargas nunca corre.
      multi: true
    }
  ]
})
export class AppModule { }
```

> ⚠️ El orden entre los dos `APP_INITIALIZER` no está garantizado por Angular 8. Si algún día la carga de i18n necesitara leer una clave del `config.json` (por ejemplo, la URL de un servidor de traducciones externo), este esquema no te lo asegura y tendrías que encadenarlos a mano dentro de un único initializer. Hoy son independientes y no se necesitan entre sí, así que conviven sin problema. Lo anoto porque es una trampa clásica.

### 5.5 `patients.service.ts` — cortar el cordón con `environment`

Así quedó el servicio en la Fase 1, leyendo de `environment`:

```typescript
// ANTES — Fase 1
import { environment } from '../../environments/environment';

getPatients(): Observable<any> {
  return this.http.get(environment.apiUrl + '/patients');
}
```

Y así queda ahora, leyendo del servicio de config:

```typescript
// src/app/patients/patients.service.ts — DESPUÉS
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

import { AppConfigService } from '../core/config/app-config.service';

@Injectable({ providedIn: 'root' })
export class PatientsService {

  // Ya no importamos environment. La URL sale de la config cargada en runtime.
  constructor(private http: HttpClient, private appConfig: AppConfigService) { }

  getPatients(): Observable<any> {
    // Como load() ya resolvió antes de que la aplicación arrancara, acá
    // appConfig.apiUrl siempre tiene valor. Ese es todo el punto del
    // APP_INITIALIZER: cuando este método corre, la config ya está.
    return this.http.get(this.appConfig.apiUrl + '/patients');
  }
}
```

> 💸 **Deuda técnica intencional.** LabCore todavía tiene `apiUrl` horneado en `environment.ts`, y no todos los servicios se migraron a `AppConfigService` de un tirón: vas a encontrar servicios nuevos leyendo del config y servicios viejos leyendo del `environment`, conviviendo en el mismo bundle. **Lo correcto hoy** sería una sola fuente de verdad para la configuración —el `AppConfigService`— y ni un solo `import { environment }` para leer `apiUrl` en toda la base de código; incluso podrías borrar `apiUrl` de `environment.ts` para que el compilador te grite dónde quedó un rezagado. **En Track A no se paga**: migrar los diez servicios y borrar la clave es un refactor con pruebas, no un hotfix, y el objetivo de la fase es que entiendas el mecanismo y sepas reconocer los dos patrones cuando los veas mezclados en producción. Este mismo cambio aplica a `orders.service.ts`, `samples.service.ts`, `results.service.ts` y `audit.service.ts`; queda como ejercicios 9 a 12. Y hay un rezagado que no es un servicio y que por eso se escapa de esa lista: **`environment.timeZone`**, que la Fase 2 §5.9 puso para el `DatePipe` de la lista de pacientes y la Fase 9 §5.1 usa para formatear la fecha del PDF. También se mudó a `config.json` —está en la plantilla de §5.2 y en la interfaz de §5.3— y también hay dos consumidores que siguen leyéndolo del `environment`. Localizarlos es el ejercicio 13.

### 5.6 `Dockerfile` — el build de dos etapas

> ⚠️ Este `Dockerfile` es el del **artefacto que va a producción**: compila y sirve con nginx, y su etapa final no lleva Node. No lo confundas con el contenedor de **desarrollo** del **Apéndice A13 §6**, que sí trae Node, Python y las build tools porque es donde se trabaja. Viven en carpetas distintas y se construyen por separado.

```dockerfile
# Dockerfile
# Etapa 1: build. Tiene Node y todo node_modules; produce el dist y muere acá.
# La 14 coincide con el .nvmrc del proyecto (Fase 0). Y es -bullseye-slim, o sea
# Debian, NO alpine: alpine usa musl en vez de glibc y el tooling nativo de esta
# epoca -node-gyp, node-sass- falla o compila raro contra musl. El peso extra de
# la imagen da igual porque esta etapa se descarta entera. El apendice A03 lo
# desarrolla, junto con el por que de npm ci.
FROM node:14.21.3-bullseye-slim AS build

WORKDIR /app

# Copiamos primero solo los manifiestos y hacemos npm ci ANTES de copiar el
# código. Así Docker cachea la capa de dependencias: si cambia el código pero no
# el package-lock, no reinstala node_modules. npm ci (no npm install) porque
# reproduce el lockfile exacto y no lo modifica. El apéndice A03 explica por que.
COPY package.json package-lock.json ./
RUN npm ci

# Ahora sí, el resto del código. Este COPY invalida la cache hacia abajo, no
# hacia arriba: node_modules ya quedó cacheado en la capa anterior.
COPY . .

# Compilamos para producción. Esto hornea environment.prod.ts, pero ya no nos
# importa: la única cosa que cambia entre ambientes salió de ahí y vive en
# config.json, que se genera al arrancar el contenedor, no acá.
RUN npm run build -- --prod

# Etapa 2: runtime. Parte de nginx limpio y se lleva SOLO el dist. Nada de Node,
# nada de node_modules, nada de código fuente TypeScript. La imagen final es
# nginx + archivos estáticos y punto.
# Acá sí usamos alpine, y no es una contradicción con la etapa 1: el problema de
# musl es compilar dependencias nativas de Node, y en esta etapa no se compila
# nada. Solo se sirven archivos estaticos.
FROM nginx:stable-alpine

# La config de nginx del proyecto reemplaza la default (el try_files vive acá).
COPY nginx.conf /etc/nginx/conf.d/default.conf

# El dist compilado en la etapa 1. El nombre sale del "ng new clinical-lab" de
# la Fase 0 §5.2, que es lo que fija el outputPath del angular.json: la carpeta
# se llama como el proyecto, no como la imagen. Confundirlos produce un COPY que
# no falla -copia una carpeta vacia- y una imagen que sirve un 404 en la raiz.
COPY --from=build /app/dist/clinical-lab /usr/share/nginx/html

# La plantilla de config y el entrypoint que la va a rellenar en el arranque.
COPY src/assets/config.template.json /usr/share/nginx/html/assets/config.template.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

# El entrypoint corre primero (rellena config.json) y después cede el control a
# nginx. Ver entrypoint.sh: termina con exec nginx, no lo lanza en background.
ENTRYPOINT ["/entrypoint.sh"]
```

> ⚠️ Esta imagen corre nginx como **root** y escucha en el **puerto 80**. En tu máquina no molesta. En el cluster real de la empresa es muy probable que el contenedor tenga prohibido correr como root, y entonces nginx no puede abrir el puerto 80 y el pod queda en `CrashLoopBackOff` sin un mensaje claro. La solución (usar una imagen de nginx sin privilegios y escuchar en un puerto alto) y —sobre todo— a quién preguntar antes de improvisarla, están en el cierre del **Apéndice A09**. No la resuelvas por tu cuenta contra el cluster de producción.

#### 5.6.1 La línea del `angular.json` que hay que tocar antes de construir

El CLI genera la configuración de producción con `"sourceMap": false`. Este
proyecto la enciende, y conviene hacerlo **ahora**, antes del primer
`docker build`, porque cambia lo que va dentro de la imagen:

```jsonc
// angular.json -> projects -> clinical-lab -> architect -> build
//                 -> configurations -> production
"sourceMap": true
```

Con eso, abrir DevTools contra el contenedor desplegado te muestra tus `.ts`
originales, con nombres de variable de verdad, y un stack trace de un log de
usuario —`main.9c4f.js:1:284712`— se traduce solo. Sin eso, ese stack trace es una
coordenada dentro de una sola línea de 1,2 MB y no sirve para nada. Es lo que hace
posible la pieza forense de la Fase 8.

> ⚠️ **Y es una decisión, no un ajuste.** Los `.map` viajan dentro de la imagen, así
> que cualquiera que abra DevTools contra el ambiente desplegado puede leer el
> TypeScript completo del sistema: nombres, comentarios, lógica de negocio. Para una
> aplicación interna es defendible —quien puede abrirla ya está dentro de la red— y
> para una expuesta a internet, no. La alternativa (`hidden: true`, que genera los
> mapas pero no los enlaza desde el bundle) y lo que cuesta en infraestructura están
> en el **Apéndice A04 §6**. Lo que no se hace es heredar esta línea copiando el
> `angular.json` a otro proyecto sin tener esa conversación.

Añade también un `.dockerignore` mínimo con `node_modules`, `dist` y `.git`, para no arrastrar basura al contexto de build y no filtrar el `node_modules` de tu host —que puede ser de otra arquitectura— dentro de la imagen.

### 5.7 `nginx.conf` — servir la SPA y no morir al recargar

```nginx
# nginx.conf
server {
  listen 80;
  server_name _;

  root /usr/share/nginx/html;
  index index.html;

  # El corazón de servir una SPA. try_files busca el archivo pedido; si no
  # existe, busca el directorio; si tampoco, sirve index.html. Así /patients/42
  # recargado en el navegador no da 404: cae en index.html, Angular arranca y el
  # router lee la URL y monta el componente. Sin esta línea, recargar cualquier
  # ruta que no sea la raíz rompe la aplicación. Es el incidente 20.
  location / {
    try_files $uri $uri/ /index.html;
  }

  # El config.json NUNCA se cachea: es la única pieza que cambia por ambiente.
  # Un config.json cacheado es apuntar al API equivocado sin un solo error.
  # Es el incidente 19.
  location = /assets/config.json {
    add_header Cache-Control "no-store, no-cache, must-revalidate";
    try_files $uri =404;
  }
}
```

**El patrón a memorizar:** en una SPA en contenedor hay exactamente dos reglas de nginx que no puedes olvidar, y las dos son incidentes de este curso. La primera, `try_files ... /index.html`, evita el 404 al recargar. La segunda, `no-store` sobre el `config.json`, evita que un archivo de configuración viejo te mande al ambiente equivocado. Si algún día heredas un `nginx.conf` de una SPA y quieres saber si quien lo escribió sabía lo que hacía, busca estas dos líneas.

### 5.8 `entrypoint.sh` — donde la misma imagen se vuelve dos ambientes

```bash
#!/bin/sh
# entrypoint.sh
# Corre UNA vez, en el arranque del contenedor, antes de que nginx acepte nada.

set -e

# Valores por defecto: si el contenedor arranca sin -e, no queda un ${API_URL}
# literal metido en el JSON. Un default sensato evita un config roto silencioso.
export API_URL="${API_URL:-http://localhost:3000}"
export ENVIRONMENT_NAME="${ENVIRONMENT_NAME:-local}"
export APP_TIME_ZONE="${APP_TIME_ZONE:-America/Bogota}"
export FEATURE_DELIVERY_PDF="${FEATURE_DELIVERY_PDF:-true}"

TEMPLATE=/usr/share/nginx/html/assets/config.template.json
TARGET=/usr/share/nginx/html/assets/config.json

# envsubst reemplaza SOLO las variables que le listamos explícitamente. Sin esa
# lista, tocaría cualquier cosa con forma de ${VAR} en el archivo, incluida
# alguna que no queremos expandir. La lista es la parte fácil de olvidar.
envsubst '${API_URL} ${ENVIRONMENT_NAME} ${APP_TIME_ZONE} ${FEATURE_DELIVERY_PDF}' < "$TEMPLATE" > "$TARGET"

# Dejar rastro en los logs del contenedor: cuando algo falle, la primera
# pregunta va a ser "a qué ambiente arrancó esto". Que la respuesta este en la
# primera línea del log ahorra media hora.
echo "[entrypoint] config generada para ambiente: $ENVIRONMENT_NAME -> $API_URL"

# exec reemplaza el proceso del script por nginx: nginx queda como PID 1 y
# recibe las señales de parada del contenedor directamente. daemon off para que
# nginx corra en primer plano; si corriera en background, el contenedor arranca
# y se muere al instante porque su proceso principal terminó.
exec nginx -g 'daemon off;'
```

**Detalles con intención:**

- `exec` no es cosmético. Sin él, nginx sería un proceso hijo del script, el script sería PID 1, y cuando el orquestador mande la señal de parada la recibiría el script y no nginx —que se quedaría sin enterarse y sería matado a la fuerza tras el timeout. Con `exec`, nginx **es** PID 1 y se apaga limpio. En la Fase 14 esto importa de verdad.
- Los valores por defecto convierten "arranqué el contenedor sin configurar nada" en "arrancó apuntando a localhost" en vez de en "arrancó con `${API_URL}` como texto y el `JSON.parse` reventó". Un default sensato es la diferencia entre un error obvio y uno desconcertante.

### 5.9 Los diccionarios de i18n dentro del contenedor

La Fase 2 dejó tres archivos JSON en `src/assets/i18n/` que se piden por HTTP en tiempo de ejecución. Mientras corriste con `ng serve` eso fue invisible: el servidor de desarrollo sirve `assets/` sin hacer preguntas. Dentro del contenedor, esos tres archivos pasan a ser lo mismo que cualquier otro archivo estático, y heredan **dos problemas que no existían en desarrollo**.

**El primero es la caché, y es el que muerde.** El CLI compila `main.js` como `main.a3f9c1.js`: el hash cambia con cada build, así que el navegador nunca te sirve un JavaScript viejo. Los archivos de `assets/` **no llevan hash**. `es.json` sale del build llamándose `es.json`, con el mismo nombre que tenía hace tres meses, y el navegador —que lo cacheó la primera vez— tiene todo el derecho de seguir sirviendo el viejo. Corriges un texto, despliegas, entras a comprobar y lo ves bien porque recargaste sin caché; el usuario sigue viendo el texto de antes durante días. Es el mismo mecanismo del incidente 19 aplicado a otro archivo.

**El segundo es el `try_files`.** La línea que evita el 404 al recargar una ruta profunda tiene un efecto colateral: cualquier ruta que no exista devuelve `index.html` con un 200. Si el loader de traducciones pide `assets/i18n/pt.json` y ese archivo no está, no recibe un 404: recibe una página HTML completa, con estado 200, que `@ngx-translate` intenta parsear como JSON. El error que ves en consola es `Unexpected token < in JSON at position 0`, que no menciona ni traducciones ni nginx, y manda a cualquiera a buscar el bug en el sitio equivocado.

Las dos cosas se arreglan en el mismo archivo, con dos bloques:

```nginx
# nginx.conf (fragmento, va ANTES del location / )

# Los assets con hash en el nombre se pueden cachear para siempre: si cambian,
# cambia el nombre. Esto es gratis y hace la segunda visita mucho más rápida.
location ~* \.[0-9a-f]{8,}\.(js|css)$ {
  add_header Cache-Control "public, max-age=31536000, immutable";
  try_files $uri =404;
}

# Los diccionarios NO llevan hash, así que no se pueden cachear a ciegas.
# must-revalidate obliga al navegador a preguntar cada vez si cambio; si no
# cambio, nginx responde 304 y no se transfiere nada. Barato y correcto.
# Y el try_files con =404 evita que un idioma inexistente devuelva index.html:
# preferimos un 404 honesto a un HTML que revienta el JSON.parse.
location /assets/i18n/ {
  add_header Cache-Control "no-cache, must-revalidate";
  try_files $uri =404;
}

# El resto de assets -imágenes, fuentes- tampoco deben caer en index.html.
location /assets/ {
  try_files $uri =404;
}
```

**Detalles con intención:**

- `no-cache` **no** significa "no cachees": significa "cachea, pero pregunta antes de usarlo". Es exactamente lo que quieres para un archivo que cambia poco y tiene que cambiar rápido cuando cambia. `no-store` —lo que usamos para el `config.json`— es más agresivo y acá sería un desperdicio: tres peticiones completas en cada arranque.
- El orden de los `location` importa, pero no como se cree: nginx resuelve primero las coincidencias exactas (`= /assets/config.json`), después los prefijos más largos, y las expresiones regulares antes que los prefijos normales. Por eso el bloque del hash va con `~*` y los otros con prefijo.
- Si prefieres no depender del navegador, la alternativa es **versionar la ruta desde el código**: el loader de la Fase 2 acepta un sufijo, así que `new TranslateHttpLoader(http, './assets/i18n/', '.json?v=' + APP_VERSION)` convierte cada despliegue en una URL distinta. Es más invasivo —toca código de la aplicación— y a cambio es determinista. En LabCore conviven las dos costumbres, según quién escribió cada proyecto.

**Y la trampa del subdirectorio.** Si algún día la aplicación deja de servirse en la raíz y pasa a `https://interno/lab/`, el `base href` cambia y con él todas las rutas relativas. El loader de la Fase 2 pide `./assets/i18n/es.json` —relativo, que es lo correcto—; si alguien lo escribe como `/assets/i18n/` con barra inicial, la petición se va a `https://interno/assets/i18n/es.json`, fuera del subdirectorio, y cae en el `try_files` del `location /`. Resultado: 200, HTML, `Unexpected token <`, y una tarde perdida. La aplicación se compila para el subdirectorio con `ng build --prod --base-href=/lab/`, y **la barra final no es opcional**.

> ⚠️ Este es el desarrollo completo del ejercicio 27 de la Fase 2, el de la clave que falla en el 1% de los casos. La causa está acá y no en la capa de i18n: el código de traducción es idéntico en los dos escenarios; lo que cambia es dónde termina la petición. Cuando un bug de i18n solo aparece en el ambiente desplegado y nunca en local, empieza por Network mirando **la URL exacta** que se pidió y el `Content-Type` de la respuesta.

> 🔥 **Si algún día se migrara a i18n de compile-time**, el reparto cambia entero: en vez de un `dist` con tres JSON, tendrías tres `dist` —uno por idioma, cada uno compilado con su `--base-href=/es/`, `/en/`, `/fr/`—, un `location` de nginx por idioma, y una regla que redirija la raíz al idioma que corresponda según la cabecera `Accept-Language`. La caché deja de ser un problema (todo lleva hash) y aparece otro: tres artefactos que hay que desplegar juntos y que pueden quedar desincronizados. Los comandos de extracción y build están en el **Apéndice A07 §9**; el proyecto no los usa.

### 5.10 Prueba de fuego

Esto es todo el curso destilado en tres comandos. Constrúyela una vez:

```bash
docker build -t lab-frontend .
```

Levántala apuntando a un ambiente:

```bash
docker run --rm -p 8080:80 -e API_URL=http://uat.interno:3000 -e ENVIRONMENT_NAME=uat lab-frontend
```

Abre `http://localhost:8080`, ve a la pestaña Network, filtra por `config.json` y confirma que la respuesta trae `"apiUrl": "http://uat.interno:3000"`. Para el contenedor (`Ctrl+C`) y levanta **la misma imagen**, sin reconstruir, apuntando a otro lado:

```bash
docker run --rm -p 8080:80 -e API_URL=http://prod.interno:3000 -e ENVIRONMENT_NAME=prod lab-frontend
```

Y una comprobación más, corta, para lo que agregó §5.9: con el contenedor levantado, abre Network, filtra por `i18n` y confirma que `es.json` se sirvió con `Cache-Control: no-cache, must-revalidate`. Recarga: la segunda vez tiene que ser un **304**, no un 200 con cuerpo. Después pide `http://localhost:8080/assets/i18n/pt.json` en la barra de direcciones y confirma que obtienes un **404** y no la página de la aplicación.

Recarga, mira el `config.json` otra vez: ahora dice `prod.interno`. **No recompilaste.** El bundle de JavaScript servido en los dos casos es byte por byte idéntico —puedes verificarlo con el hash del `main.js` en Network—; lo único que cambió fue un archivo de 200 bytes que el contenedor escribió al arrancar. Si mañana te cambian el mock por el backend real, tocas una variable de entorno y ninguna vista se entera. Esa es la frase con la que cierra el curso.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Recargo una ruta profunda y la aplicación desaparece con un 404.**
Síntoma: navegar dentro de la app funciona, pero recargar en `/patients/42/orders` da la página de error 404 de nginx. Causa: falta el `try_files $uri $uri/ /index.html` en el `nginx.conf`, o el `COPY nginx.conf` del Dockerfile apunta al lugar equivocado y nginx está usando su configuración por defecto. Fix mínimo: la línea de `try_files` de §5.7. Refactorización correcta: la misma línea; acá no hay diferencia entre parche y solución, es una config de una línea que está o no está.

**Levanto el contenedor con `-e API_URL=...` y la app sigue apuntando a localhost.**
Síntoma: el `-e` no tiene efecto; el `config.json` servido trae el default. Causa habitual: el navegador cacheó un `config.json` viejo, o `envsubst` no listó `${API_URL}` y lo dejó sin expandir. Fix mínimo: fuerza recarga sin cache (`Ctrl+Shift+R`) y confirma que Network muestra el `config.json` con el valor nuevo; si sigue mal, revisa que la lista de variables del `envsubst` incluya la que estás pasando. Este es el mecanismo detrás del incidente 19.

**Compila en dev con `ng serve` pero `docker build` falla en `npm run build -- --prod`.**
Síntoma: un error de AOT que no aparecía sirviendo en desarrollo, a veces sobre una factory. Causa: una arrow function anónima en un `useFactory` (el AOT de Angular 8 no serializa closures anónimas), exactamente la trampa que la Fase 2 documentó con `httpLoaderFactory` y que §5.4 repite con `appConfigInitializer`. Fix mínimo: convertir la arrow en una `function` exportada con nombre.

**La imagen pesa 900 MB.**
Síntoma: `docker images` muestra una imagen enorme. Causa: el Dockerfile no es multi-stage, o la etapa final parte de `node:14` en vez de `nginx:stable-alpine`, arrastrando Node y `node_modules`. Fix mínimo: la estructura de dos etapas de §5.6. El peso del bundle en sí —distinto del peso de la imagen— es tema del Apéndice A04.

### Pieza forense de esta fase

Lo que se debuggea acá no es un stack trace: es un **diff entre ambientes**. El bug clásico de despliegue no tiene error en consola; tiene una aplicación que hace lo correcto con los datos equivocados porque arrancó con la configuración de otro ambiente. La técnica es comparar: el `config.json` que sirve UAT contra el que sirve PROD, la variable de entorno que se pasó contra la que se documentó, el hash del bundle en un ambiente contra el otro (si difieren, alguien recompiló cuando no debía). Y cuando encuentras la feature rota en PROD, el **feature flag** es lo que te deja apagarla —`FEATURE_DELIVERY_PDF=false` y reinicio— comprando tiempo para arreglarla bien, sin desplegar código un viernes. El desarrollo completo de la técnica, con el diff transcrito y el árbol de decisión del hotfix, vive en [`forense-fase-13.md`](./forense-fase-13.md).

**Rompe a propósito y observa:** levanta el contenedor con `-e API_URL=http://no-existe.interno:9999`. La aplicación arranca sin un solo error —el `config.json` se generó perfecto— y recién falla cuando intentas cargar pacientes, con un error de red genérico que **no** menciona la configuración. La pantalla te va a contar la mentira de que el backend está caído. El lugar correcto donde mirar no es la consola de errores sino la pestaña Network buscando `config.json`, leyendo a qué host se está intentando conectar, y comparándolo con el que esperabas. Esa es toda la lección forense de la fase: cuando algo "no responde", antes de culpar al backend, confirma a qué backend le estás hablando.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Compila con `npx ng build --prod`, abre un `.js` de `dist/` y encuentra la cadena `localhost:3000` horneada. Cópiala en tu cuaderno: es lo que esta fase saca del bundle.
2. Construye la imagen con `docker build -t lab-frontend .` y corre `docker images` para ver su tamaño. Anótalo.
3. Levanta el contenedor con `-e API_URL=http://uat.interno:3000` y confirma en Network que el `config.json` servido trae ese valor.
4. Levanta **la misma imagen** con `-e API_URL=http://prod.interno:3000` y confirma que el `config.json` cambió sin haber reconstruido.
5. Navega a `/patients`, luego a `/orders`, y recarga estando en `/orders`. Confirma que la aplicación se vuelve a montar y no da 404.
6. Abre el `entrypoint.sh` y explica en dos líneas qué hace `exec` en la última línea y qué pasaría sin él.
7. Cambia `ENVIRONMENT_NAME` a `staging` en el `-e` y confirma que la línea `[entrypoint] config generada...` de los logs del contenedor lo refleja.
8. Encuentra en el `nginx.conf` la línea que evita que el `config.json` se cachee y explica con tus palabras qué incidente previene.

**🟡 Intermedio (9–17)**

9. Migra `orders.service.ts` para que lea `apiUrl` de `AppConfigService` en vez de `environment`, siguiendo el molde de §5.5.
10. Haz lo mismo con `samples.service.ts`.
11. Haz lo mismo con `results.service.ts`.
12. Haz lo mismo con `audit.service.ts`. Al terminar, `grep` `environment.apiUrl` en `src/` y anota cuántos rezagados quedan.
13. `timeZone` ya está en el `config.json` (§5.2 y §5.3), pero sus dos consumidores siguen leyendo `environment.timeZone`: el `PatientListComponent` de la Fase 2 §5.9 y el `ReportService` de la Fase 9 §5.1. Migra los dos a `AppConfigService` y después levanta el contenedor con `-e APP_TIME_ZONE=America/Mexico_City`: la fecha de una orden emitida a las 23:40 tiene que cambiar de día. Es el ejercicio que demuestra que la migración de §5.5 no había terminado.
14. Añade un feature flag `auditLogVisible` y usa `isFeatureEnabled('auditLogVisible')` con un `*ngIf` para ocultar la vista de audit log cuando esté apagado.
15. Reduce el tamaño de la imagen: verifica que la etapa final parte de `nginx:stable-alpine` y no de una imagen con Node. Compara el tamaño con el del ejercicio 2.
16. Escribe el `.dockerignore` y demuestra, comparando el "sending build context" de dos `docker build`, que reduce el contexto enviado.
17. Añade una segunda ruta cacheada distinta del `config.json` (por ejemplo, un `no-store` sobre `/assets/i18n/`) y razona si conviene o no. Justifica tu respuesta.

**🟠 Difícil (18–24)**

18. **Diagnóstico.** Te entregan una imagen donde recargar `/patients/42` da 404 pero la raíz funciona. Localiza la causa en el `nginx.conf` sin que te digan cuál es, y aplica el fix mínimo.
19. **Diagnóstico.** Un contenedor levantado con `-e API_URL=http://prod.interno:3000` sigue mostrando datos de UAT tras recargar. Reproduce el problema, identifica que es el cache del `config.json`, y demuestra el fix.
20. **Diagnóstico.** `docker build` falla en `npm run build -- --prod` con un error de AOT sobre una factory, pero `ng serve` funciona. Localiza la arrow anónima culpable y conviértela en `function` exportada.
21. **Diagnóstico.** Alguien pasó `-e API_URL` pero olvidó agregar la variable a la lista del `envsubst`. Reproduce el síntoma (el `config.json` sirve `${API_URL}` literal) y explica por qué el `JSON.parse` del navegador revienta.
22. Convierte `FEATURE_DELIVERY_PDF` en el interruptor real del botón de entrega de PDF (Fase 9): con la feature apagada, el botón no debe renderizarse. Prueba los dos valores levantando la imagen dos veces.
23. **Diagnóstico.** Levanta el contenedor con un `API_URL` que apunta a un host inexistente. Documenta la mentira que cuenta la pantalla y el camino correcto para llegar a la causa real usando Network.
24. Demuestra que el bundle `main.js` es idéntico byte a byte entre dos ambientes distintos, comparando su hash en Network. Explica qué prueba eso sobre "la misma imagen en todos lados".

**🔴 Muy difícil (25–30)**

25. **Diagnóstico.** Se reporta que "en PROD a veces los pacientes salen mal". Con solo acceso al `config.json` de cada ambiente y a los logs de arranque de los contenedores, arma el diff que localiza que PROD arrancó con el `API_URL` de UAT. Escribe el post-mortem de tres líneas.
26. Haz que el `AppConfigService` falle ruidoso: si `load()` no puede traer el `config.json` (borra el archivo del contenedor y reinicia), la aplicación debe mostrar una pantalla de error clara en vez de arrancar a medias. Implementa el `catch` del `APP_INITIALIZER`.
27. **Diagnóstico.** El `APP_INITIALIZER` de config y el de i18n de la Fase 2 conviven. Fuerza una situación donde el orden entre ellos importe (haz que i18n necesite una clave del config) y demuestra que el esquema actual no lo garantiza. Encadénalos dentro de un único initializer como fix.
28. Prepara la imagen para correr como usuario no-root en el puerto 8080 en vez del 80 (imagen `nginxinc/nginx-unprivileged` o equivalente). Documenta qué rompió y qué tocaste — son tres archivos a la vez, no uno. Cruza tu solución con el **Apéndice A09 §8**, que enumera las cuatro políticas que rechazan esta imagen, incluida la del sistema de archivos de solo lectura contra el `entrypoint.sh` que escribe.
29. **Diagnóstico.** Te dan dos imágenes que "deberían ser iguales" pero una funciona en el cluster y la otra queda en `CrashLoopBackOff`. Una corre como root y otra no. Reproduce localmente la diferencia de permisos de puerto y explica el `CrashLoopBackOff` sin cluster.
30. Escribe tu **checklist de hotfix** de una página: los pasos que sigues, en orden, desde que llega un ticket de PROD hasta que confirmas el fix, incluyendo cuándo apagar una feature con flag en vez de desplegar. Es el entregable que te llevas del curso.

**🔥 Opcionales**

- 🔥 Toma la imagen de esta fase sin modificarla y llévala a un cluster de kind: es literalmente la Fase 14. Si vas a hacer una, que sea esta.
- 🔥 Compila la imagen para arm64 con `docker buildx` en una Mac con Apple Silicon y documenta qué dependencias se quejan. Cruza con el Apéndice A13.
- 🔥 Reemplaza el `try_files` por una configuración de nginx que además cachee agresivamente los assets con hash en el nombre (`main.[hash].js`) pero nunca el `index.html`. Explica por qué esa combinación es segura.
- 🔥 **Diagnóstico.** Quita el bloque `location /assets/i18n/` de §5.9, reconstruye, y pide en la barra de direcciones un idioma que no existe (`/assets/i18n/pt.json`). Anota el código de estado, el `Content-Type` y el error exacto que produce `@ngx-translate` en consola. Después vuelve a ponerlo y confirma que ahora es un 404 limpio.
- 🔥 Cambia un texto de `es.json`, reconstruye la imagen y levántala **sin** limpiar la caché del navegador. Comprueba si ves el texto nuevo con y sin el `Cache-Control` de §5.9, y anota qué código de estado devuelve nginx en la segunda recarga (deberías ver un 304).
- 🔥 Compila con `--base-href=/lab/`, sirve la aplicación bajo ese subdirectorio, y comprueba que los tres diccionarios siguen cargando. Después cambia la ruta del loader de `./assets/i18n/` a `/assets/i18n/` y documenta el síntoma completo: URL pedida, estado, `Content-Type` y mensaje de consola.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v8.angular.io/guide/build#configure-target-specific-file-replacements — el *file replacement* de `environment.ts` al compilar. Es el mecanismo que esta fase evita para la config por ambiente. (v8, la del curso.)
- https://angular.io/api/core/APP_INITIALIZER — el token que usamos para cargar el config antes de arrancar. La página documenta una versión posterior, pero el comportamiento de `multi: true` y la promesa es idéntico en 8.
- https://docs.docker.com/develop/develop-images/multistage-build/ — builds multi-stage. Documentación viva; el concepto no cambió.
- https://nginx.org/en/docs/http/ngx_http_core_module.html#try_files — la directiva `try_files`, palabra por palabra. Lee el ejemplo del `index.html` de fallback.
- https://github.com/typicode/json-server — el mock de las fases anteriores, por si necesitas repasar a qué apunta el `apiUrl`.
- https://nginx.org/en/docs/http/ngx_http_headers_module.html#add_header — `add_header` y el orden en que se heredan las cabeceras entre bloques `location`. Es la directiva de §5.9 y su herencia sorprende más de lo que debería.
- https://developer.mozilla.org/es/docs/Web/HTTP/Headers/Cache-Control — la diferencia entre `no-cache`, `no-store` y `must-revalidate`, que es exactamente lo que separa el `config.json` de los diccionarios de i18n.
- https://v8.angular.io/cli/build — las banderas del build del CLI 8, incluida `--base-href`, que es la de la trampa del subdirectorio.

**Video / apoyo**

- Cualquier charla de "Angular runtime configuration" o "Angular config APP_INITIALIZER" cubre este patrón; el título y la URL exactos cambian seguido, así que búscalos por concepto y verifica que el ejemplo use `APP_INITIALIZER` y no `inject()` (que es Angular 14+).

**Orden de lectura sugerido:** antes de escribir código, relee la sección "Dónde vive la configuración por ambiente" de la Fase 1 y el `APP_INITIALIZER` de la Fase 2 —esta fase es la confluencia de esas dos—. Durante, ten a mano la doc de `try_files` y la de multi-stage. Después, si vas a desplegar en el cluster real, el Apéndice A09 antes de tocar nada.

> ⚠️ Las URLs, títulos y contenidos pueden haber cambiado o desaparecido; verifícalos. En particular, la doc de `APP_INITIALIZER` en `angular.io` ya solo cubre versiones muy posteriores a la 8: el mecanismo es el mismo, pero ignora cualquier ejemplo con `inject()` o standalone.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Construiste una imagen que se compila una vez y se comporta como el ambiente que le toque: UAT, staging o PROD, según lo que le inyectes al arrancar. Cerraste el bucle que abriste en la Fase 1, cuando pusiste `apiUrl` horneado en `environment.ts` y te pedí que guardaras una frase. La frase era esta fase.

Con eso, el **Track A del curso está completo**. Tienes una aplicación Angular 8 que se levanta, autentica, hace CRUD sobre un store de NgRx, internacionaliza, genera PDFs, dibuja un dashboard, registra auditoría, tiene tests con coverage medible, y se despliega en un contenedor que no miente sobre a qué ambiente pertenece. Y —más importante para Maintenance— tienes el ojo entrenado para diagnosticar cuando algo de todo eso se rompe.

La **Fase 14** es opcional y toma esta misma imagen, sin modificarla, y la lleva a un Kubernetes local con kind: el mismo `entrypoint.sh` alimentado por un ConfigMap en vez de un `-e`, un Deployment, un Service, un Ingress, y un rolling update en vivo. No es requisito del onboarding; el líder la asigna a quien tenga interés en ver su imagen corriendo en un cluster de verdad. Todo lo que necesita ya existe: es esta imagen y este `config.json`, montados distinto.

Y sobre lo que viene **después** de Angular 8: en algún momento alguien va a proponer migrar. Angular 9 trae Ivy —un compilador nuevo que cambia cómo se genera el bundle y hace que varios de los errores de AOT que sufriste en este curso simplemente desaparezcan—, y de ahí en adelante llegan standalone components, `inject()` y el control flow nuevo, que hacen que este código se vea antiguo. No vas a migrar durante el onboarding, y probablemente no migres nunca este sistema —migrar un legacy en producción es un proyecto, no un `ng update`—. Pero cuando la conversación aparezca, el camino empieza en el **Apéndice A10 (Migración 8 → 9)**, y lo primero que vas a agradecer es Ivy comiéndose la mitad de las trampas de AOT que documentamos en todo el curso. Ese apéndice trae además dos cosas para esa reunión concreta: el guion del **ensayo en una rama desechable** (§8), que convierte opiniones en datos por el precio de una tarde, y el **veredicto honesto** (§⚖️) sobre cuándo la respuesta correcta es no migrar. Y si lo que quieres es solo entender por qué los ejemplos que encuentras no se parecen a tu código, el **Apéndice A11** tiene la tabla que traduce lo moderno a lo tuyo, línea por línea.

> **La señal de que quedó bien:** "si mañana me cambian el mock por el backend real, o me mueven de UAT a PROD, toco una variable de entorno, reinicio el contenedor, y ninguna vista se entera. Y si algo se rompe igual, sé que la primera pregunta no es 'qué falló' sino 'a qué ambiente arrancó esto'."


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-13-build-despliegue -m "F13 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f13: …`) y los de ejercicio su
> número (`f13 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f13/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Y como esta fase estrena la imagen, etiquétala con el mismo nombre:
> `docker build -t lab-frontend:fase-13-build-despliegue .` en vez del `:latest`
> implícito. Saber qué código hay adentro es la mitad barata de cualquier
> "funciona en UAT y no en PROD".

---

## 📌 Pendientes sugeridos

- **[`forense-fase-13.md`](./forense-fase-13.md)** — desarrollo completo de la técnica de diff de ambientes, el `config.json` comparado, transcrito y el árbol de decisión del hotfix con feature flags. Cierre del track forense con el checklist de una página.
- **Correr como non-root en el cluster real** — anotado en la ⚠️ de §5.6 y en el ejercicio 28; la solución con contexto de la empresa vive en el cierre del **Apéndice A09**, no acá.
- **Unificación de las dos librerías de gráficos y peso del bundle** — heredado de la Fase 10; es material del **Apéndice A04 (Webpack oculto)**, no de esta fase.

### Reservas para el cuaderno de incidentes

Esta fase toma los incidentes **19 y 20**, ambos ya reservados en el índice de
`cuaderno-incidentes.md` —que es el único archivo de incidentes del curso, no hay
un `.md` por incidente—. El enunciado completo —ticket, preparación, pistas plegadas y
solución de referencia— **ya está escrito allí**:

- **19** · Fase 13 · *"Desplegamos a PROD y le sigue hablando a UAT"* · Categoría: despliegue · Dificultad 🔴 — el mecanismo quedó preparado en §5.3 y §5.7; la causa raíz vive entre la config horneada y el `config.json` cacheado por el navegador.
- **20** · Fase 13 · *"Si recargo la página en cualquier pantalla, me da 404"* · Categoría: despliegue · Dificultad 🟠 — prevenido con el `try_files` de §5.7; el enunciado parte de una imagen a la que se le quitó esa línea.
