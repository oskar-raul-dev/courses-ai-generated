# 🔐 Fase 03 — Autenticación mínima

> Tutorial Angular 8 — Laboratorio clínico · Fase 3 de 14 · **8 horas**
> Depende de: Fase 1 — Estructura base + NgRx · Fase 2 — Internacionalización · Habilita: Fase 4 — Mock API + caos · Fases 5-12
> Apéndices de apoyo: [A05 (RxJS de supervivencia)](./a05-rxjs.md) · [A01 (Angular Material)](./a01-material.md) · [A07 (i18n en Angular 8)](./a07-i18n.md) · [Incidentes asociados](./cuaderno-incidentes.md): 05

---

## 🎯 1. Propósito

En la Fase 1 dejaste el router abierto: cualquiera que sepa la URL entra a `/patients` sin que nadie le pregunte nada. Eso funcionó mientras el curso solo tenía una pantalla que mostrar, pero LabCore que vas a mantener sí pide usuario y contraseña, y esa pantalla de login es casi siempre lo primero que un analista ve al llegar y lo primero que revisas tú cuando alguien reporta que "no lo deja entrar".

Esta fase simula ese login sin backend real: un mock que firma un JWT de verdad, un guard que bloquea rutas, un interceptor que agrega el token a cada petición y reacciona cuando el servidor dice que ya no vale. No hay roles ni permisos finos —eso es de otra fase— pero sí hay algo que vas a encontrar en casi cualquier sistema legacy con más de tres años: sesión que expira sola sin que nadie se los avise a tiempo. Al terminar vas a saber leer ese síntoma sin adivinar.

---

## ✅ 2. Qué queda listo al terminar

- [ ] Entrar a `http://localhost:4200/patients` sin haber iniciado sesión te redirige a `/login`, y en la URL queda una `returnUrl` con la ruta original.
- [ ] Con las credenciales del mock (`analista1` / `analista1` o `analista2` / `analista2`, ver sección 5), el login te devuelve un JWT real y te navega a `/patients`.
- [ ] En la pestaña Application → Local Storage del navegador ves la clave con el token guardado, y puedes pegarlo en jwt.io y leer el payload (`sub`, `role`, `exp`).
- [ ] Cualquier petición HTTP hacia el mock sale con el header `Authorization: Bearer ...`, visible en Network.
- [ ] Esperas a que el token expire (configurado corto para la clase) y la siguiente petición dispara un 401; la aplicación te desloguea sola y te manda a `/login`.
- [ ] El botón de logout limpia el storage y no deja rastro del token.

---

## 🚫 3. Qué NO entra todavía

- Backend real. El JWT lo firma el mock de Express con inyector de caos → sigue así hasta que el curso decida si alguna vez hay un backend de verdad (no está planeado).
- Refresh token. Cuando expira, se desloguea; no hay renovación silenciosa → fuera de alcance de Track A, se anota como pendiente sugerido al final.
- Roles y permisos finos (qué puede ver un analista vs un supervisor) → **fuera del alcance del curso**. El campo `role` viaja en el token y se decodifica, y ahí se queda: ninguna pantalla le pregunta nada. Es una puerta dejada abierta a propósito —el día que el sistema los necesite, el dato ya está— y no una promesa de este tutorial.
- Countdown o aviso de "tu sesión expira en 30 segundos". El logout por expiración es abrupto → pendiente sugerido, candidato a ejercicio 🔥 o a incidente del cuaderno.
- Cualquier UI de "recordarme" o de cambio de contraseña.

---

## 🧠 4. Concepto mínimo

### El problema primero

Hasta la Fase 1, cualquier componente podía llamar a `HttpClient` y el mock respondía sin preguntar quién eres. En un sistema real eso no dura ni un día: hay que saber quién está mirando la pantalla, y hay que evitar que alguien entre a `/patients` escribiendo la URL a mano si no iniciar sesión antes. Angular no tiene "autenticación" como concepto nativo — lo que tiene son dos piezas de bajo nivel que, combinadas, simulan el comportamiento: una que revisa **antes de navegar** (el guard) y otra que revisa **en cada petición HTTP** (el interceptor). Ninguna de las dos es seguridad real: corren en el navegador, y cualquiera con las herramientas de desarrollador abiertas puede desactivar el guard llamando al componente a mano. Lo que hacen es **experiencia de usuario controlada** — la seguridad de verdad, si existiera, tendría que vivir en el servidor. Guarda esa distinción: en LabCore, el guard evita que un analista se pierda por la interfaz, no evita que alguien malintencionado llegue a los datos.

### La herramienta

Un **`CanActivate` guard** es una función que el router de Angular consulta antes de activar una ruta; si devuelve `false` (o una URL para redirigir), la navegación no ocurre. Es el equivalente a un chequeo de autorización antes de un handler en un backend, con la salvedad de que acá el handler es una pantalla, no un endpoint.

Un **`HttpInterceptor`** es, para quien viene de backend, el primo cercano de un middleware: toda petición saliente pasa por él antes de llegar a la red, y toda respuesta pasa por él antes de llegar al componente que la pidió. Acá va a hacer dos cosas: agregar el header `Authorization` a cada petición, y mirar si la respuesta viene con un 401 para reaccionar con un logout automático.

El **token** en sí es un JWT firmado por el mock — no una cadena inventada sin estructura, sino un JWT real con las tres partes (`header.payload.signature`), que puedes decodificar en cualquier decodificador de JWT. La firma es real en el sentido de que el mock la genera con una librería estándar y una clave secreta propia del curso; lo que no hay del otro lado es un servidor de autenticación de verdad validando contra una base de usuarios en producción. Es un JWT de laboratorio, con la forma exacta que vas a encontrar en LabCore.

> 📝 **Nota de época.** En 2019, guardar el JWT en `localStorage` era la opción por defecto en casi cualquier tutorial y en muchísimos sistemas en producción, a pesar de que ya se sabía que es vulnerable a robo por XSS. La alternativa más segura —cookie `httpOnly`— exige que el backend la setee, y complica el CORS entre front y back separados. El sistema que vas a mantener tomó la decisión rápida y nunca volvió a tocarla. Tú tampoco la vas a tocar en Track A: la señalas y sigues.

### Dónde encaja NgRx (o más bien, dónde no)

La Fase 1 fijó NgRx como el mecanismo de estado del curso, y quizás esperabas ver acciones tipo `[Auth] Login Success` acá. No las vas a ver. El login de este sistema vive en un `AuthService` plano, con el token leído y escrito directo en `localStorage`, sin pasar por el store. No es una excepción arbitraria: así está resuelto en LabCore, y es además un patrón legítimo — no todo estado pertenece al store. Ya lo viste con `sidenavOpen` en el `ShellComponent` de la Fase 1: un estado que nadie más consulta y que no aporta nada al log de acciones no necesita ceremonia. El estado de sesión tiene una particularidad extra: tiene que sobrevivir a un F5 del navegador, y leerlo de `localStorage` al arrancar la aplicación es más simple que rehidratar un store completo. La consecuencia práctica es que **no vas a poder ver el login en Redux DevTools** — y esa ausencia es parte de lo que tienes que aprender a reconocer: si alguna vez buscas un bug de sesión ahí, estás mirando en el lugar equivocado.

> 📚 HttpInterceptor (v8): https://v8.angular.io/api/common/http/HttpInterceptor
> 📚 Router — CanActivate (v8): https://v8.angular.io/api/router/CanActivate

---

## 💻 5. Código mínimo con comentarios

Siete piezas, en el orden en que las vas a tocar si esto fuera un ticket real: primero el mock que emite el token, después el servicio que lo guarda, después lo que lo usa (guard, interceptor), y por último el formulario y el enchufe en los módulos.

### 5.1 El mock — `mock-server/auth.js`

```javascript
// mock-server/auth.js
// Endpoint de login del servidor Express del mock. El inyector de caos que
// va a envolver a este endpoint se construye en la Fase 4; hoy no existe.
// Firma un JWT real con una librería estándar; no hay base de datos de
// verdad detrás, solo el arreglo de usuarios de más abajo.
const jwt = require('jsonwebtoken');

// Clave secreta propia del curso. En un sistema real esto vive en una
// variable de entorno y nunca en el repositorio; acá va literal a propósito
// porque el mock entero es descartable.
const JWT_SECRET = 'lab-clinico-secreto-de-curso';

// Usuarios fijos. El campo "role" ya está presente aunque todavía nadie
// lo lea: la Fase 3 deja la puerta abierta para permisos finos, sin
// implementarlos.
const USERS = [
  { username: 'analista1', password: 'analista1', role: 'analyst', fullName: 'Marcela Ríos' },
  { username: 'analista2', password: 'analista2', role: 'analyst', fullName: 'Julián Prada' },
  { username: 'supervisor1', password: 'supervisor1', role: 'supervisor', fullName: 'Deisy Cárdenas' }
];

// Tiempo de vida del token, en segundos. Corto a propósito para que la
// expiración se vea en clase sin esperar minutos reales.
const TOKEN_TTL_SECONDS = 120;

function login(req, res) {
  const { username, password } = req.body;
  const user = USERS.find(function (u) {
    return u.username === username && u.password === password;
  });

  if (!user) {
    // 401 genérico: no distinguimos "usuario no existe" de "clave mala".
    // Es una decisión de seguridad básica que LabCore también toma.
    res.status(401).json({ message: 'Credenciales inválidas' });
    return;
  }

  const token = jwt.sign(
    { sub: user.username, role: user.role, fullName: user.fullName },
    JWT_SECRET,
    { expiresIn: TOKEN_TTL_SECONDS }
  );

  res.status(200).json({ token: token, expiresIn: TOKEN_TTL_SECONDS });
}

module.exports = { login: login, JWT_SECRET: JWT_SECRET };
```

> ⚠️ **Dependencias nuevas del mock.** Hasta acá el mock era `json-server` arrancado con `npx`. Este es el primer momento en que hace falta lógica de servidor de verdad —firmar un token—, así que entra Express:
>
> ```bash
> npm install express@4.17.1 json-server@0.16.3 jsonwebtoken@8.5.1 --save-dev
> ```
>
> Las tres van en `devDependencies`: son del mock y ninguna entra al bundle de Angular. `express` 4.17.1 es la contemporánea del stack (la rama 5 cambia el manejo de errores asíncronos); `jsonwebtoken` 8.5.1 es la de la época. Las tres están fijadas y no hay nada que verificar: **el mock es código de este curso, no de LabCore**, y la Fase 4 §5.2 lo desarrolla cuando el servidor pasa a ser tuyo del todo.

### 5.2 El servidor del mock — `mock-server/server.js`

Acá nace el archivo que va a acompañar el resto del curso. Es la primera vez que el mock deja de ser un comando suelto y pasa a ser código tuyo: Express es el anfitrión y `json-server` va **adentro**, como router, no como proceso aparte. Así hay un solo puerto, un solo origen y un solo lugar donde meter cosas más adelante.

```javascript
// mock-server/server.js
// Servidor único del mock. Nace en la Fase 3 porque el login necesita
// lógica de servidor (firmar un token) y json-server solo no la tiene.
// La Fase 4 le agrega el inyector de caos sin mover nada de esto de lugar.
const express = require('express');
const jsonServer = require('json-server');
const path = require('path');

const { login } = require('./auth');

const PORT = 3000;

const app = express();

// CORS. La aplicación corre en 4200 y el mock en 3000: son origenes
// distintos y sin estas cabeceras el navegador bloquea todo antes de que
// nuestro código se entere. Se escribe a mano en vez de usar la librería
// "cors" porque la Fase 4 necesita poder quitar estas cabeceras a voluntad.
app.use(function (req, res, next) {
  res.header('Access-Control-Allow-Origin', 'http://localhost:4200');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');

  // El preflight se responde acá y no sigue viajando.
  if (req.method === 'OPTIONS') {
    res.sendStatus(204);
    return;
  }

  next();
});

// Parseo del cuerpo. Sin esto, req.body es undefined en el login y el error
// que ves es "no se puede leer username de undefined", que apunta al lugar
// equivocado.
app.use(express.json());

// El login, antes del router de json-server: si quedara después, json-server
// vería un POST a una colección "login" que no existe y respondería otra cosa.
app.post('/login', login);

// Todo lo demás sale de db.json, igual que en las Fases 0 y 1. La aplicación
// no se entera del cambio: el puerto y las rutas son los mismos.
const router = jsonServer.router(path.join(__dirname, '..', 'db.json'));
app.use(router);

app.listen(PORT, function () {
  console.log('[mock] escuchando en http://localhost:' + PORT);
});
```

Y en `package.json`, para no volver a escribir el comando nunca más:

```json
{
  "scripts": {
    "start": "ng serve",
    "mock": "node mock-server/server.js"
  }
}
```

Desde ahora el mock se levanta con `npm run mock` y **no** con `npx json-server`. Son dos procesos y dos terminales, a propósito: cuando lo apagues a mano para ver qué hace la aplicación sin backend, tiene que ser evidente qué apagaste.

**Detalles con intención**

- El orden de los `app.use` **es** la lógica del archivo. Express es una tubería y cada función decide si responde o llama a `next()`; equivocarse de línea no produce un error, produce un middleware que no se ejecuta nunca. La Fase 4 vive de esa idea.
- `json-server` como router y no como proceso: un solo origen. Con dos puertos habría dos configuraciones de CORS y `environment.apiUrl` tendría que partirse en dos.
- El preflight se corta arriba del todo. Es la línea que más gente omite, y produce el síntoma "solo fallan las peticiones con `Authorization`" — porque un `GET` simple no dispara preflight y uno con header personalizado sí. Guarda esa frase para el interceptor de §5.6.

### 5.3 El modelo del usuario — `src/app/core/auth/auth-user.model.ts`

```typescript
// src/app/core/auth/auth-user.model.ts
// TS-0: la interfaz existe más por documentación que por chequeo real, ya
// que "strict" está apagado y nadie fuerza que el payload decodificado
// cumpla esta forma.
export interface AuthUser {
  sub: string;
  role: string;
  fullName: string;
  exp: number;
}
```

### 5.4 El servicio — `src/app/core/auth/auth.service.ts`

```typescript
// src/app/core/auth/auth.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

import { environment } from '../../../environments/environment';
import { AuthUser } from './auth-user.model';

// Clave de storage propia, para no chocar con otras cosas que el navegador
// o extensiones puedan guardar bajo nombres genéricos como "token".
const TOKEN_KEY = 'lab_clinico_token';

@Injectable({ providedIn: 'root' })
export class AuthService {

  constructor(private http: HttpClient, private router: Router) { }

  // 💸 Deuda técnica intencional: token en localStorage.
  // Lo correcto hoy sería una cookie httpOnly seteada por el backend, que
  // ni el JavaScript del navegador puede leer y que mitiga el robo por XSS.
  // En Track A no se paga: LabCore lo tiene así desde 2019, el
  // backend no está bajo nuestro control en esta fase del curso, y cambiar
  // el mecanismo de sesión exige tocar el backend real, cosa que un
  // hotfix de mantenimiento no hace.
  login(username: string, password: string): Observable<{ token: string; expiresIn: number }> {
    return this.http.post<{ token: string; expiresIn: number }>(
      environment.apiUrl + '/login',
      { username: username, password: password }
    ).pipe(
      tap(function (this: AuthService, response) {
        localStorage.setItem(TOKEN_KEY, response.token);
      }.bind(this))
    );
  }

  logout() {
    localStorage.removeItem(TOKEN_KEY);
    this.router.navigate(['/login']);
  }

  getToken(): string | null {
    return localStorage.getItem(TOKEN_KEY);
  }

  isAuthenticated(): boolean {
    const token = this.getToken();
    if (!token) {
      return false;
    }
    return !this.isExpired(token);
  }

  // Decodifica el payload del JWT sin validar la firma: no hace falta,
  // porque la validación de verdad la hace el interceptor cuando el
  // servidor responde 401. Esto es solo para leer el "exp" localmente y
  // evitar mandar peticiones con un token que ya sabemos vencido.
  getDecodedUser(): AuthUser | null {
    const token = this.getToken();
    if (!token) {
      return null;
    }
    try {
      const payload = token.split('.')[1];
      // atob decodifica base64; es exactamente lo mismo que hace jwt.io.
      return JSON.parse(atob(payload));
    } catch (error) {
      // any tolerado: un token corrupto en storage no debería tumbar la app.
      console.error('[AuthService] no se pudo decodificar el token', error);
      return null;
    }
  }

  // Quien esta operando, para estampar en los campos de custodia que van a
  // escribir las Fases 7, 8 y 9: quien recogio la muestra, quien valido el
  // resultado, quien entrego el informe.
  //
  // Devuelve el "sub" del token -el username- y NO el fullName, y esa decisión
  // vale la pena entenderla porque se repite en todo el curso: el sub es un
  // identificador estable y el fullName es un texto que puede cambiar. Si un
  // analista se casa y cambia de apellido, todos los registros de custodia que
  // guardaron su nombre pasan a hablar de alguien que ya no existe. Se guarda
  // la referencia, se resuelve el texto al mostrar — la misma regla que el
  // curso aplica con las claves de i18n (A07 §7).
  getCurrentUser(): string | null {
    const decoded = this.getDecodedUser();
    return decoded ? decoded.sub : null;
  }

  private isExpired(token: string): boolean {
    const decoded = this.getDecodedUser();
    if (!decoded) {
      return true;
    }
    // "exp" en un JWT viene en segundos desde epoch; Date.now() en milisegundos.
    return Date.now() >= decoded.exp * 1000;
  }
}
```

**Detalles con intención**

- `providedIn: 'root'` en vez de declararlo en `CoreModule`: es el mismo mecanismo, más corto de escribir, y es el que vas a ver en LabCore para servicios sin estado compartido con otros módulos vía `forRoot()`.
- `getDecodedUser()` no valida la firma. Eso es intencional y está bien para uso de UI (mostrar el nombre en la toolbar, decidir si mandar una petición); la validación de la firma la hace el propio servidor cuando recibe el token, y ahí es donde de verdad importa que no se pueda falsificar.
- Hay **dos** formas de preguntar quién está operando y no son intercambiables. `getDecodedUser()` devuelve el payload entero y es lo que usas para *mostrar* —el nombre en la toolbar, el saludo—. `getCurrentUser()` devuelve el `sub` y es lo que usas para *registrar*: los campos de custodia de las Fases 7, 8 y 9, y los asientos del audit log de la Fase 11. Confundirlas produce un rastro que dice `Marcela Ríos` donde debería decir `analista1`, y ese rastro deja de cruzar con el resto de los registros el día que alguien cambie de apellido.

> **El patrón a memorizar:** un JWT decodificado en el navegador no es una fuente confiable, es una fuente *conveniente*. Confías en su contenido para la experiencia de usuario, nunca para autorizar algo que de verdad importe — eso lo revalida siempre el servidor.

### 5.5 El guard — `src/app/core/auth/auth.guard.ts`

```typescript
// src/app/core/auth/auth.guard.ts
import { Injectable } from '@angular/core';
import { CanActivate, Router, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';

import { AuthService } from './auth.service';

@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {

  constructor(private authService: AuthService, private router: Router) { }

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
    if (this.authService.isAuthenticated()) {
      return true;
    }

    // Guardamos a donde quería ir el usuario para devolverlo ahí después
    // del login. Sin esto, cada login abandonado te tira siempre a la
    // misma pantalla por defecto, y es un detalle que un analista nota
    // rápido cuando lo pierde.
    this.router.navigate(['/login'], { queryParams: { returnUrl: state.url } });
    return false;
  }
}
```

> ⚠️ **El pipe `translate` no llega solo.** `LoginComponent` se declara en
> `CoreModule`, que ya importa `I18nModule` desde la Fase 2 §5.8 — así que aquí
> funciona sin tocar nada. Si algún día esta pantalla se mudara a un módulo
> propio con carga diferida, haría falta el `TranslateModule.forChild({ isolate:
> false })` de siempre, y olvidarlo produce el error de pipe no encontrado que la
> Fase 2 §6 documenta.

> 📝 **Nota de época.** En Angular 8 los guards son siempre clases con `@Injectable`. Los *functional guards* (una función suelta, sin clase) llegaron recién en Angular 14. Si alguna vez ves un guard como función en código más nuevo, es otra época; acá no aplica.

### 5.6 El interceptor — `src/app/core/auth/auth.interceptor.ts`

```typescript
// src/app/core/auth/auth.interceptor.ts
import { Injectable } from '@angular/core';
import { HttpEvent, HttpHandler, HttpInterceptor, HttpRequest } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';

import { AuthService } from './auth.service';

@Injectable()
export class AuthInterceptor implements HttpInterceptor {

  constructor(private authService: AuthService) { }

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    const token = this.authService.getToken();

    // No le agregamos el header a la petición de login: todavía no hay
    // token, y mandar "Bearer null" como string literal es un clásico bug
    // de interceptor mal escrito que vale la pena nombrar acá para que no
    // lo repitas.
    const authReq = token
      ? req.clone({ setHeaders: { Authorization: 'Bearer ' + token } })
      : req;

    return next.handle(authReq).pipe(
      catchError(function (this: AuthInterceptor, error) {
        if (error.status === 401) {
          // El servidor dijo que el token ya no vale. No importa si expiró,
          // si está corrupto o si nunca existió: la reacción es la misma,
          // desloguear. Distinguir el motivo exacto es trabajo del backend,
          // no de este interceptor.
          this.authService.logout();
        }
        return throwError(error);
      }.bind(this))
    );
  }
}
```

> ⚠️ **Advertencia.** Este interceptor agrega el header a *toda* petición saliente, incluidas las que no van al mock del laboratorio (si algún día hay una llamada a un servicio externo, viajaría con el token también). En un sistema real con múltiples backends, esto se filtra por URL. Acá no hace falta: todo apunta al mismo `apiUrl`.

### 5.7 El formulario — `src/app/core/auth/login/login.component.ts`

```typescript
// src/app/core/auth/login/login.component.ts
import { Component } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';

import { AuthService } from '../auth.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {

  // ngModel a pelo, sin Reactive Forms: dos campos no lo justifican, y es
  // además el nivel de formulario que vas a ver en las pantallas viejas de
  // LabCore que nunca se migraron.
  credentials: any = {
    username: '',
    password: ''
  };

  loading = false;

  // Se guarda la CLAVE, no el texto. Es la regla de la Fase 2 (y de A07 §7): un
  // texto ya traducido que se guarda en una propiedad queda congelado en el
  // idioma que estaba activo cuando se guardo, y cambiar de idioma no lo toca.
  // La plantilla lo pasa por el pipe, que si reacciona.
  errorMessageKey = '';

  constructor(private authService: AuthService, private router: Router, private route: ActivatedRoute) { }

  submit() {
    if (!this.credentials.username || !this.credentials.password) {
      this.errorMessageKey = 'auth.errors.required';
      return;
    }

    this.loading = true;
    this.errorMessageKey = '';

    this.authService.login(this.credentials.username, this.credentials.password)
      .subscribe(
        function (this: LoginComponent) {
          this.loading = false;
          // returnUrl viaja en la query string desde el guard. Si no hay
          // ninguna (login directo, sin haber sido redirigido), caemos a
          // /patients por defecto.
          const returnUrl = this.route.snapshot.queryParams['returnUrl'] || '/patients';
          this.router.navigateByUrl(returnUrl);
        }.bind(this),
        function (this: LoginComponent, error: any) {
          this.loading = false;
          // Mensaje genérico para el usuario; el detalle real queda en
          // consola y Network, igual que en la Fase 0.
          this.errorMessageKey = 'auth.errors.failed';
          console.error('[LoginComponent] falló el login', error);
        }.bind(this)
      );
  }
}
```

```html
<!-- src/app/core/auth/login/login.component.html -->
<div class="login-container">
  <mat-card class="login-card">
    <!-- Ni un literal. La Fase 2 monto i18n y su cierre lo dejo escrito: de ahi
         en adelante, ninguna pantalla del curso lleva texto a mano. Esta es la
         primera pantalla nueva que nace despues de esa regla. -->
    <mat-card-title>{{ 'shell.title' | translate }}</mat-card-title>

    <form (ngSubmit)="submit()">
      <mat-form-field appearance="fill">
        <mat-label>{{ 'auth.login.username' | translate }}</mat-label>
        <input matInput name="username" [(ngModel)]="credentials.username">
      </mat-form-field>

      <mat-form-field appearance="fill">
        <mat-label>{{ 'auth.login.password' | translate }}</mat-label>
        <input matInput type="password" name="password" [(ngModel)]="credentials.password">
      </mat-form-field>

      <p class="error-message" *ngIf="errorMessageKey">
        {{ errorMessageKey | translate }}
      </p>

      <button mat-raised-button color="primary" type="submit" [disabled]="loading">
        {{ (loading ? 'auth.login.submitting' : 'auth.login.submit') | translate }}
      </button>
    </form>
  </mat-card>
</div>
```

Y las claves nuevas en el árbol de referencia. El `en.json` y el `fr.json` se
completan igual; el francés se deja incompleto a propósito, como fijó la Fase 2:

```json
{
  "auth": {
    "login": {
      "username": "Usuario",
      "password": "Contraseña",
      "submit": "Ingresar",
      "submitting": "Ingresando..."
    },
    "errors": {
      "required": "Usuario y contraseña son obligatorios.",
      "failed": "No se pudo iniciar sesión. Verifica tus credenciales."
    }
  }
}
```

### 5.8 Enchufe en el router — fragmento de `app-routing.module.ts`

```typescript
// src/app/app-routing.module.ts (fragmento)
import { AuthGuard } from './core/auth/auth.guard';
import { LoginComponent } from './core/auth/login/login.component';

const routes: Routes = [
  { path: 'login', component: LoginComponent },
  {
    path: '',
    component: ShellComponent,
    canActivate: [AuthGuard],
    // canActivateChild también existe y evita repetir el guard en cada
    // ruta hija; no lo usamos acá a propósito, para que el guard quede
    // visible una sola vez y fácil de encontrar durante un diagnóstico.
    children: [
      { path: 'patients', loadChildren: './patients/patients.module#PatientsModule' },
      { path: 'orders', loadChildren: './orders/orders.module#OrdersModule' },
      { path: 'samples', loadChildren: './samples/samples.module#SamplesModule' },
      { path: 'results', loadChildren: './results/results.module#ResultsModule' },
      { path: '', redirectTo: 'patients', pathMatch: 'full' }
    ]
  }
];
```

Y hay una consecuencia que es fácil pasar por alto, porque no está en este
fragmento sino en un archivo de la Fase 1: **el `ShellComponent` deja de ser el
techo fijo de la aplicación y pasa a ser un componente de ruta.** Antes lo montaba
`app.component.html` directamente; ahora lo monta el router, y solo para las rutas
protegidas. La consecuencia práctica es que `/login` se pinta **fuera** de él, sin
toolbar y sin sidenav, que es exactamente lo que quieres en una pantalla de acceso.

```html
<!-- src/app/app.component.html — cambia respecto de la Fase 1 -->
<!-- Antes: <app-shell></app-shell>. Ahora un router-outlet pelado, porque quien
     decide si toca shell o toca login es el router. El <router-outlet> que la
     Fase 1 puso DENTRO del shell sigue donde estaba y pasa a ser el de las rutas
     hijas: son dos outlets anidados, y esa anidacion es la que hace que el
     layout envuelva a /patients y no a /login. -->
<router-outlet></router-outlet>
```

> ⚠️ Si te saltas este cambio, la aplicación compila y el síntoma es
> desconcertante: el login aparece **dentro** del shell, con la barra de navegación
> de un sistema al que todavía no has entrado. Es la primera vez en el curso que
> una fase modifica una pieza que construyó otra, y por eso se dice en voz alta.

> 📝 **Nota de época.** `loadChildren: './patients/patients.module#PatientsModule'` con el `#` es la sintaxis de *string* que usaba Angular 8. Desde Angular 9 en adelante se escribe como función dinámica `() => import('./patients/patients.module').then(m => m.PatientsModule)`. Si ves la segunda forma en un tutorial más nuevo, no es un error, es otra versión — y si algún día se migra, es de las que reescribe sola la schematic de `ng update` (**Apéndice A10 §3**).

### 5.9 Enchufe del interceptor — fragmento de `core.module.ts`

```typescript
// src/app/core/core.module.ts (fragmento)
import { HTTP_INTERCEPTORS } from '@angular/common/http';
import { AuthInterceptor } from './auth/auth.interceptor';

@NgModule({
  // ...imports y declarations ya existentes desde la Fase 1
  providers: [
    // multi: true porque HTTP_INTERCEPTORS es un arreglo; si el proyecto
    // suma otro interceptor a futuro (por ejemplo uno de logging), se
    // agrega otra entrada, nunca se reemplaza esta.
    { provide: HTTP_INTERCEPTORS, useClass: AuthInterceptor, multi: true }
  ]
})
export class CoreModule { }
```

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma: "el login funciona pero cualquier petición después me tira 401 igual".**
Causa: el interceptor se registró en un módulo distinto de `CoreModule`, o sin `multi: true`, y Angular lo pisó con otro provider. Fix mínimo: confirma que el `providers` de `CoreModule` tiene la entrada exacta de la sección 5.9, y que `CoreModule` solo se importa una vez, en `AppModule` (si se importa dos veces, se registran dos interceptores y el orden deja de ser predecible).

**Síntoma: "me desloguea a los pocos segundos aunque el token debería durar 2 minutos".**
Causa casi siempre reloj del cliente vs reloj del servidor, o confundir segundos con milisegundos al comparar `exp`. Fix mínimo: revisa `isExpired()` en `AuthService` — es un error clásico comparar `Date.now()` (milisegundos) contra `exp` (segundos) sin multiplicar por 1000.

**Síntoma: "el guard me deja pasar aunque no inicié sesión".**
Causa: alguien está leyendo `localStorage.getItem('token')` en vez de la clave real (`lab_clinico_token`), típicamente porque copiaron un fragmento de otro tutorial sin ajustar el nombre. Fix mínimo: busca todas las referencias literales a la clave de storage y confirma que hay una sola fuente de verdad — idealmente solo dentro de `AuthService`, nunca repetida en un componente.

**Síntoma: "en Network veo el header Authorization pero dice 'Bearer null'".**
Causa: el interceptor corrió antes de que el token terminara de guardarse, o se está agregando el header incluso cuando `getToken()` devuelve `null`. Fix mínimo: revisa que el `token ? ... : req` de la sección 5.6 esté de verdad condicionando, y no algo como `` `Bearer ${token}` `` sin chequeo previo.

### Pieza forense de esta fase

Acá vive el primer ejercicio serio de leer una petición HTTP de punta a punta: request-id y breakpoints condicionales en el interceptor. La mecánica completa —cómo poner un breakpoint que solo dispare cuando la petición es a `/patients`, cómo correlacionar un request-id entre el log del navegador y el de Express— se desarrolla en [`forense-fase-03.md`](./forense-fase-03.md); acá solo dejamos el gancho.

**Rompe a propósito y observa:** con la aplicación logueada, abre las DevTools, anda a Application → Local Storage, y borra manualmente la clave `lab_clinico_token` sin recargar la página. Navega a otra ruta protegida (por ejemplo de `/patients` a `/orders`) usando el menú, no el botón de recargar. ¿Qué esperas ver? El guard debería mandarte a `/login` en la siguiente navegación, porque `isAuthenticated()` vuelve a consultar el storage cada vez, no una copia en memoria. Si en cambio sigues navegando como si nada, la pantalla te está mintiendo: algo quedó cacheado donde no debería, y el lugar correcto para mirar no es el componente sino el guard mismo.

Ese mismo experimento es la puerta de entrada al **incidente 05** del cuaderno —*"cerré sesión en una pestaña y en la otra sigo adentro"*—, que es exactamente este síntoma provocado por otra pestaña en vez de por tus dedos. Cuando lo abras, ya vas a tener el reflejo de preguntar quién consulta el storage y cada cuánto.

---

## 🧪 7. Ejercicios (30)

**🟢 Fácil (1–8)**

1. Cambia `TOKEN_TTL_SECONDS` en el mock a 300 segundos y confirma en jwt.io que el `exp` del nuevo token corresponde a 5 minutos desde la emisión.
2. Agrega un cuarto usuario al arreglo `USERS` del mock con rol `supervisor` y loguéate con él.
3. En `login.component.html`, agrega un `mat-icon` al botón de ingresar sin romper el `[disabled]` existente.
4. Explica con tus palabras (en un comentario nuevo en `auth.service.ts`) por qué `getDecodedUser()` no valida la firma del token.
5. Busca en el código las tres apariciones de la clave `lab_clinico_token` y confirma que son consistentes.
6. Agrega un mensaje de error distinto cuando el campo usuario esté vacío vs cuando esté vacío el de contraseña. Son dos claves nuevas en los tres diccionarios, no dos cadenas en el componente: si te descubres escribiendo texto en el `.ts`, vuelve a §5.7.
7. **Diagnóstico.** En Network, la petición a `/login` sale con el header `Authorization: Bearer <token viejo>` porque quedaba una sesión anterior en storage. Reprodúcelo —loguéate, haz logout a medias borrando solo parte del storage, y vuelve a intentar— y explica en dos líneas por qué el interceptor no debería mandar ese header ahí y qué pasaría si el servidor lo tomara en serio.
8. Anota en un comentario qué pasaría si `TOKEN_KEY` colisionara con una clave que ya usa otra parte de la aplicación.

**🟡 Intermedio (9–17)**

9. Agrega un método `getCurrentUserName()` a `AuthService` que devuelva el `fullName` del usuario decodificado, o `null` si no hay sesión. Ahora tienes tres formas de preguntar quién está operando: escribe en dos líneas para qué sirve cada una y cuál usarías para estampar un campo de custodia.
10. Muestra ese nombre en la `mat-toolbar` del `ShellComponent`, junto a un botón de logout.
11. Haz que el interceptor no agregue el header `Authorization` cuando la petición vaya dirigida a `/login` (aunque hoy no haya token en ese momento, déjalo explícito para cuando exista un caso de re-login con sesión previa).
12. Escribe un test manual: apaga el mock (`Ctrl+C` en la terminal del servidor Express), intenta loguearte, y documenta qué mensaje ve el usuario y qué aparece en consola.
13. **Diagnóstico.** Un analista reporta que "el usuario no existe" y jura que lo escribe bien. Resulta que su gestor de contraseñas le pega un espacio al final. Reprodúcelo, confirma en Network qué viaja exactamente en el cuerpo del POST, y aplica la validación que lo evita — en el componente, no en el mock.
14. **Diagnóstico.** El guard rechaza y nadie sabe por qué: no hay rastro de qué ruta se intentó ni con qué token. Agrega un `console.warn` que lo diga —sin cambiar el comportamiento, solo el diagnóstico— y después provoca los tres rechazos posibles (sin token, token expirado, token corrupto) confirmando que los distingues por el log.
15. Confirma con DevTools qué pasa si abres dos pestañas del navegador logueadas con usuarios distintos: ¿comparten sesión? ¿Por qué sí o por qué no, dado que `localStorage` es por origen y no por pestaña?
16. **Diagnóstico.** Pega en `localStorage` un `lab_clinico_token` que no sea un JWT —cualquier cadena— y navega a `/patients`. Anota qué pasa exactamente: qué devuelve `getDecodedUser()`, qué hace `isExpired()` con eso, y si acabas en `/login` o en una pantalla rota. Después ajusta el guard para que ese caso también redirija.
17. Documenta en un comentario qué diferencia hay entre `canActivate` y `canActivateChild`, y por qué esta fase eligió el primero.

**🟠 Difícil (18–24)**

18. **Diagnóstico.** Un compañero reporta: "inicio sesión, entro a `/patients`, y a los 10 segundos me tira afuera aunque configuramos el token a 2 minutos". Con el código de esta fase, lista tres causas posibles y cómo las descartarías una por una.
19. **Diagnóstico.** En Network ves que la petición a `/patients` sale sin header `Authorization` a pesar de que el login fue exitoso y el token está en storage. ¿Qué archivo miras primero y qué pruebas ahí?
20. Haz que el `AuthInterceptor` distinga entre un 401 por token expirado y un 401 por credenciales simplemente inválidas en otro endpoint (pista: vas a necesitar que el mock devuelva un código de error distinguible en el body, no solo el status).
21. **Diagnóstico.** El guard deja pasar correctamente en local, pero en un build de producción (`ng build --configuration=production`) no redirige nunca a `/login`. ¿Qué relación tiene esto con lo que aprendiste en la Fase 1 sobre `environment.prod.ts` y el file replacement?
22. Escribe, sin ejecutarlo todavía (los tests llegan en otra fase), el esqueleto de un test unitario para `AuthGuard` que verifique que `canActivate` devuelve `false` cuando no hay token.
23. Investiga qué pasa si dos pestañas comparten sesión y en una haces logout: ¿la otra pestaña se entera de inmediato, o solo al hacer la próxima petición? Documenta el resultado observado.
24. Propón (sin implementarlo) cómo agregarías un mecanismo de "logout en todas las pestañas" usando el evento `storage` del navegador, y explica por qué esto no rompe la decisión de no usar NgRx para auth.

**🔴 Muy difícil (25–30)**

25. **Diagnóstico.** Un analista reporta que "a veces" queda logueado con la sesión de otro compañero después de compartir la misma computadora. Reconstruye la secuencia de eventos más probable, usando lo que sabes de `localStorage` y de cómo hace logout esta implementación.
26. Modifica el mock para que, además del token, devuelva un segundo valor `serverTime`, y usa ese valor en `AuthService.isExpired()` en vez de `Date.now()` del cliente. Explica en un comentario qué clase de bug de producción previene este cambio.
27. **Diagnóstico.** Con el inyector de caos que se completa en la Fase 4 en mente (todavía no lo tienes armado, pero puedes simularlo agregando un `setTimeout` artificial en el endpoint `/login`), razona qué pasaría si la latencia de red hace que la respuesta del login llegue *después* de que el usuario navegó manualmente a otra pantalla.
28. Propón una estrategia (sin código, en prosa) para migrar el token de `localStorage` a una cookie `httpOnly` el día en que exista un backend real, incluyendo qué cambiaría en el interceptor y qué dejaría de ser necesario.
29. Compara, en una tabla corta, tres estrategias de expiración de sesión (logout abrupto como esta fase, refresh token silencioso, aviso previo con countdown) en términos de complejidad de implementación y de qué tan bien tolera un analista de laboratorio cada una en un turno de 8 horas.
30. **Diagnóstico.** Baja `TOKEN_TTL_SECONDS` a 30 segundos, entra a `/patients` y espera a que el token venza **sin tocar la pantalla**. Anota qué ve el usuario en ese momento y en qué instante exacto se entera la aplicación de que la sesión murió. Después explica por qué el guard no detecta nada mientras nadie navegue, por qué el interceptor tampoco mientras nadie pida datos, y qué implica eso para un analista que deja la pantalla abierta durante el almuerzo. Cierra con la corrección mínima que aplicarías en un hotfix y la refactorización que propondrías con calma.

**🔥 Opcionales**
- 🔥 Implementa un countdown visual (por ejemplo un snackbar de Material) que avise 15 segundos antes de que expire el token, sin bloquear la interfaz. Es exactamente el pendiente sugerido que quedó fuera del alcance de esta fase.
- 🔥 Agrega un modo "recordarme" que use `sessionStorage` en vez de `localStorage` cuando esté desactivado, y documenta la diferencia de comportamiento entre cerrar la pestaña y cerrar el navegador.

---

## 📚 8. Referencias

**Documentación oficial**
- HttpInterceptor (v8): https://v8.angular.io/api/common/http/HttpInterceptor
- CanActivate (v8): https://v8.angular.io/api/router/CanActivate
- Router guards, guía completa (v8): https://v8.angular.io/guide/router#milestone-5-route-guards
- HttpClient, guía completa (v8): https://v8.angular.io/guide/http

**Libros / artículos de referencia**
- jwt.io — decodificador de JWT y explicación de la estructura del token: https://jwt.io

**Orden de lectura sugerido:** primero la guía de router guards completa (te da el contexto de `CanActivate` más allá del fragmento de esta fase), después la de `HttpClient` si el interceptor te resulta oscuro, y vuelve a jwt.io cada vez que necesites inspeccionar un token real durante un diagnóstico.

> ⚠️ Las URLs de `v8.angular.io` documentan específicamente Angular 8; verifica que no te redirijan a `angular.io` o `angular.dev`, que cubren versiones muy posteriores con APIs que no existen en este proyecto (por ejemplo, guards funcionales). Los enlaces pueden haber cambiado desde que se escribió este documento.

---

## 🚀 9. Cierre y conexión con la siguiente fase

Con esta fase, la aplicación dejó de ser una vidriera abierta: hay una puerta, y esa puerta reacciona tanto a la navegación como a las respuestas del servidor. Las Fases 5 a 11, que van a construir el CRUD real de pacientes, órdenes, muestras y resultados, dan por hecho que quien llega ahí ya pasó por acá — no van a repetir la lógica de sesión, solo van a asumir que `AuthService.getToken()` funciona y que el interceptor ya está poniendo el header.

La **Fase 4 — Mock API + caos** es la siguiente, y es la que le pone a prueba todo esto. Hasta ahora el mock siempre respondió bien y el token siempre llegó a tiempo, así que el `catchError` del interceptor y el camino del 401 corrieron una sola vez, a mano y con paciencia. La Fase 4 convierte ese camino en un interruptor: `CHAOS=expired` dispara el 401 cuando tú quieras, y de paso absorbe el `server.js` que acá escribiste dentro del servidor único del curso. Dicho de otro modo, la puerta ya está montada; la Fase 4 es donde aprendes a golpearla.

Quedaron dos hilos sueltos, anotados como pendientes: el countdown de expiración (candidato a 🔥 o a un incidente del cuaderno) y la migración eventual a cookie `httpOnly` si algún día aparece un backend real, que no está planeada pero conviene tener pensada.

> **La señal de que quedó bien:** si apagas el mock, esperas a que el token expire, y la aplicación te devuelve solita a `/login` sin una excepción sin capturar en consola ni una pantalla que se quede pensando para siempre, la Fase 3 hizo su trabajo.


> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-03-autenticacion -m "F3 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f03: …`) y los de ejercicio su
> número (`f03 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f03/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva `cuaderno-incidentes.md`. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).

---

## 📌 Pendientes sugeridos

- **Countdown de expiración con aviso previo.** Candidato a ejercicio 🔥 (ya incluido arriba) o a un incidente propio del cuaderno si prefieres desarrollarlo como caso de post-mortem simulado en vez de como ejercicio.
- **Logout sincronizado entre pestañas.** Mencionado en el ejercicio 24 y no resuelto. Su destino es el **incidente 05** del cuaderno —*"cerré sesión en una pestaña y en la otra sigo adentro"*—, que es el enfoque correcto: llega como bug reportado, no como feature pendiente. No necesita apéndice propio.
- **Migración del storage a cookie `httpOnly`.** Exige un backend que la emita, o sea que está fuera del alcance por partida doble (no hay backend, y no se toca la sesión en Track A). Queda como el ejercicio 28 de esta fase, que pide diseñarla en prosa: es el nivel correcto para algo que nadie va a implementar aquí.

### Reservas para el cuaderno de incidentes

Esta fase toma el incidente **05**, ya reservado en el índice de
[`cuaderno-incidentes.md`](./cuaderno-incidentes.md). El enunciado completo —ticket, preparación,
pistas plegadas y solución de referencia— **ya está escrito allí**:

- **05** · Fase 3 · *"Cerré sesión en una pestaña y en la otra sigo adentro"* · Categoría: UI · Dificultad 🟡 — quién consulta el storage y cada cuánto. Llega como bug reportado y no como feature pendiente, que es el enfoque correcto para algo que el pendiente del logout sincronizado deja abierto.
