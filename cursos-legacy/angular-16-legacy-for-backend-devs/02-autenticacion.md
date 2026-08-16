# 🔐 Fase 02 — Autenticación mínima

> Tutorial Angular 16 — Inspecciones y certificaciones · Fase 2 de 14 · **6 horas**
> Depende de: Fase 1 (estructura base con NgModules) · Habilita: Fases 3 a 13
> Apéndices de apoyo: [A04 (`inject()](a04-inject-vs-constructor.md)` vs constructor) · [A06 (RxJS 7 idiomático)](a06-rxjs.md)
> [Incidentes asociados](cuaderno-incidentes.md): 03
> Estilo de esta fase: **mixto 🧬** — la aplicación es de NgModules y aquí entra el primer código funcional moderno

---

## 🎯 1. Propósito

Poner login, token y protección de rutas en CertCore. Y, mientras lo haces, ver por primera vez lo que define a este track entero: **el punto exacto donde el código de 2024 se enchufa en una aplicación de 2021 y los dos siguen funcionando.**

La Fase 1 te dio un esqueleto donde cualquiera entra a cualquier pantalla. Hoy eso se acaba: un `authGuard` funcional decide quién pasa, un `authInterceptor` funcional le pone el token a cada petición, y un interceptor de clase escrito en 2021 sigue corriendo al lado sin que nadie lo haya tocado. Ese "al lado" es la fase.

---

## ✅ 2. Qué queda listo al terminar

- [ ] `node mock/server.js` levanta y `POST /auth/login` con `inspector@certcore.co` / `certcore123` devuelve un JWT de tres partes.
- [ ] Entrar a `/clients` sin sesión te manda a `/login?returnUrl=%2Fclients`, y tras autenticarte aterrizas en `/clients` y no en el panel.
- [ ] Toda petición saliente lleva **dos** cabeceras: `Authorization: Bearer …` puesta por el interceptor funcional y `X-Correlation-Id` puesta por el de clase. Las ves en Network.
- [ ] `localStorage` guarda el token bajo la clave `certcore.accessToken`, y cerrar sesión la borra.
- [ ] Un `401` de cualquier petición cierra la sesión y te devuelve al login — excepto el `401` del propio login, que muestra "Credenciales inválidas" y te deja donde estabas.
- [ ] La toolbar muestra el nombre y el rol de quien está dentro, y un botón de salir.
- [ ] `git tag` lista `fase-02`.

---

## 🚫 3. Qué NO entra todavía

- **Roles como autorización.** El token trae `role` y la toolbar lo muestra, pero **no restringe nada**. Los permisos finos están fuera del alcance del curso (`alcance-del-proyecto.md` §8) y no los va a traer ninguna fase posterior: se declara y ya.
- **Refresh token real** → fuera de alcance. No hay backend propio, y simularlo enseñaría un mecanismo falso.
- **Cierre de sesión sincronizado entre pestañas** → ejercicio 🔥 y ejercicio 25. Se diagnostica, no se implementa.
- **El mock completo** —`db.json` con el modelo del dominio, json-server, el inyector de caos— → Fase 3. Hoy nace `mock/server.js` con lo justo para que el login tenga contra qué autenticarse.
- **Estado reactivo de sesión** → Fase 4. Hoy `AuthService` pregunta a `localStorage` cada vez que alguien quiere saber si hay sesión, que es exactamente lo que hacía CertCore en 2021.
- **Pruebas del guard y del interceptor** → Fase 12, que es donde el token vuelve a aparecer, esta vez para testearlo.

---

## 🧠 4. Concepto mínimo

### El problema, antes que la herramienta

Tienes seis pantallas que muestran datos de clientes reales y un backend que exige un token en cada petición. Necesitas tres cosas distintas que la gente confunde todo el rato: **quién decide si una pantalla se puede abrir** (el guard), **quién le pone el token a cada petición** (el interceptor) y **quién guarda la sesión** (el servicio). Son tres responsabilidades, tres archivos, y mezclarlas es cómo se llega a un `AuthService` de cuatrocientas líneas que nadie se atreve a tocar.

Si vienes de backend, el paralelo es directo y sirve una sola vez: el interceptor es el middleware o el filtro de la cadena de peticiones, el guard es el chequeo de autorización antes del handler. Y aquí está el límite del paralelo, que conviene tener claro desde el primer minuto:

> 🧭 **Un guard no es seguridad.** Corre en el navegador, en código que el usuario puede leer, pausar y saltarse con el depurador abierto. Lo único que hace es evitar que alguien vea una pantalla vacía y un error feo. **Quien decide de verdad qué datos salen es el servidor.** Si tu backend devuelve las inspecciones sin mirar el token, el guard no está protegiendo nada: está decorando.

### 🧬 ¿Nuevo o heredado? Guards e interceptors

Ésta es la primera API del curso que tiene dos formas vivas en el mismo repositorio, y las vas a escribir las dos hoy.

```ts
// ── HEREDADO (2021) ────────────────────────────────────────────────────────
// Un interceptor era una clase con un decorador, registrada en un token
// multi-provider. Verboso, pero heredable y fácil de espiar en el inyector.
@Injectable()
export class CorrelationIdInterceptor implements HttpInterceptor {
  intercept(request: HttpRequest<unknown>, next: HttpHandler): Observable<HttpEvent<unknown>> {
    return next.handle(request);
  }
}
// …y en algún módulo:
// { provide: HTTP_INTERCEPTORS, useClass: CorrelationIdInterceptor, multi: true }
```

```ts
// ── NUEVO (2024) ───────────────────────────────────────────────────────────
// Una función. Sin clase, sin decorador, sin token. Las dependencias entran
// con inject(), y `next` es una función en vez de un objeto con .handle().
export const authInterceptor: HttpInterceptorFn = (request, next) => next(request);
// …y al registrar el cliente:
// provideHttpClient(withInterceptors([authInterceptor]))
```

**Cuál usarías.** El funcional, en todo lo que escribas de aquí en adelante: es lo que Angular 16 documenta, se lee de un vistazo y no arrastra ceremonia. El de clase, si estás arreglando uno que ya existe — y **arreglar no es reescribir**. El `CorrelationIdInterceptor` de CertCore funciona desde 2021, nadie se ha quejado, y convertirlo a función el día que haya que tocarle una línea sería gastar riesgo sin comprar nada.

> 🧭 **Regla del proyecto.** Código nuevo, estilo nuevo. Código heredado, se toca lo mínimo y en su propio estilo. Y nunca los dos dentro del mismo archivo.

El corolario, que es lo que hace difícil esta fase: **hay un archivo donde los dos estilos se tocan por narices**, porque alguien tiene que registrar a los dos interceptores. Es `core.module.ts`, va marcado con 🧬, y es el archivo más importante que vas a escribir hoy.

> 📝 **Nota de migración.** Los guards e interceptors funcionales llegaron en Angular 14 (`CanActivateFn`) y 15 (`HttpInterceptorFn`), y `provideHttpClient()` es la forma que la 15 introdujo para registrar el cliente HTTP fuera de un `NgModule`. CertCore nació en 2021 con las tres piezas en versión clase; durante la migración de 2024, el equipo reescribió **el guard y el interceptor de auth** —los dos que había que tocar de todos modos para añadir el manejo del 401— y **dejó el de correlación como estaba**. Esa decisión, tomada un martes por alguien con prisa, es la razón de que hoy convivan las dos formas. No fue un plan; fue lo razonable en el momento.

### El contexto de inyección, que es donde `inject()` explota

`inject()` no funciona en cualquier sitio. Sólo puede llamarse mientras Angular está construyendo algo: en el inicializador de un campo de clase, en un constructor, o dentro de una factory — y un guard funcional y un interceptor funcional **son factories**, por eso ahí sí vale.

Lo que rompe, y lo vas a romper hoy en el ejercicio 10, es llamarlo un momento después: dentro del callback de un `catchError`, dentro de un `subscribe`, dentro de un `setTimeout`. Para entonces Angular ya terminó de construir y el contexto se cerró. El error es `NG0203` y su mensaje es sorprendentemente claro para lo raro que suena el problema.

La solución no es una técnica: es un hábito. **Se inyecta arriba del todo y se usa después.** Las referencias quedan capturadas en el closure y funcionan donde quieras.

> 📚 El mapa completo —dónde vale, dónde no, `runInInjectionContext`, herencia sin `super()` interminable— está en **A04**. Hoy alcanza con el hábito.

---

## 💻 5. Código mínimo con comentarios

### 5.1 El stub de la Fase 0 se retira 🪦

```bash
git rm mock/db.json
```

Aquel `db.json` tenía un array de `inspection-requests` que existía sólo para que el POST de la Fase 0 no fuera al vacío. El modelo de dominio de verdad llega en la Fase 3, con json-server delante. Hoy el mock cambia de naturaleza: pasa de ser un archivo de datos a ser un servidor con lógica, porque autenticar es lógica.

### 5.2 `mock/server.js`

Cuarenta líneas de Express. No se explica Express: eres senior de backend y esto no es nuevo para ti. Lo que sí conviene mirar es qué forma tiene el token, porque la Fase 3 lo va a firmar igual y la Fase 12 lo va a testear.

```bash
npm install --save-dev express@4.18.2 jsonwebtoken@9.0.2
```

```js
// mock/server.js
const express = require('express');
const jwt = require('jsonwebtoken');

const app = express();
app.use(express.json());

// Secreto de juguete, en claro y versionado a propósito: esto es un mock de
// desarrollo. Un secreto de verdad no vive en el repositorio, y la Fase 13
// vuelve sobre eso cuando hablemos de configuración en tiempo de arranque.
const JWT_SECRET = 'certcore-dev-secret';
const TOKEN_TTL_SECONDS = 3600;

const USERS = [
  {
    email: 'inspector@certcore.co',
    password: 'certcore123',
    sub: 'INS-15',
    name: 'Ana Restrepo',
    role: 'inspector',
  },
  {
    email: 'supervisor@certcore.co',
    password: 'certcore123',
    sub: 'SUP-02',
    name: 'Diego Marín',
    role: 'supervisor',
  },
];

// CORS a mano. Fíjate en Allow-Headers: si X-Correlation-Id no está en esa
// lista, el navegador rechaza la petición antes de enviarla y el error que
// verás no menciona la cabecera. La Fase 3 hace de esto un fallo provocable.
app.use((request, response, next) => {
  response.header('Access-Control-Allow-Origin', 'http://localhost:4200');
  response.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Correlation-Id');
  response.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  if (request.method === 'OPTIONS') {
    return response.sendStatus(204);
  }
  next();
});

app.post('/auth/login', (request, response) => {
  const { email, password } = request.body;
  const user = USERS.find((candidate) => candidate.email === email && candidate.password === password);

  if (!user) {
    // 401 con cuerpo: el cliente necesita algo que mostrar, y "Unauthorized"
    // a secas no le dice nada a un inspector en campo.
    return response.status(401).json({ message: 'Credenciales inválidas' });
  }

  const accessToken = jwt.sign(
    { sub: user.sub, name: user.name, role: user.role },
    JWT_SECRET,
    { expiresIn: TOKEN_TTL_SECONDS },
  );

  response.json({ accessToken, expiresIn: TOKEN_TTL_SECONDS });
});

// Middleware de autorización. Es lo que convierte al guard del navegador en un
// adorno y a esto en la protección de verdad.
const requireToken = (request, response, next) => {
  const header = request.headers.authorization;

  if (typeof header !== 'string' || !header.startsWith('Bearer ')) {
    return response.status(401).json({ message: 'Falta el token de acceso' });
  }

  try {
    request.user = jwt.verify(header.slice('Bearer '.length), JWT_SECRET);
    next();
  } catch (error) {
    // jwt.verify lanza tanto si la firma no cuadra como si el token expiró.
    response.status(401).json({ message: 'Token inválido o expirado' });
  }
};

// Un endpoint protegido, vacío, sólo para tener dónde probar el interceptor.
// La Fase 3 lo reemplaza por json-server con el db.json del dominio.
app.get('/inspections', requireToken, (request, response) => {
  response.json([]);
});

app.listen(3000, () => {
  console.log('Mock de CertCore escuchando en http://localhost:3000');
});
```

**Detalles con intención**

- **El mock devuelve `expiresIn` aunque el token ya lleve `exp` dentro.** Es redundante y es lo que hacen casi todas las APIs reales, porque el cliente no debería tener que abrir el token para saber cuánto le queda. Nosotros lo vamos a abrir igual, y en 5.4 verás por qué eso tiene un costo.
- **Dos usuarios, no uno.** El segundo existe para que el `role` de la toolbar cambie de verdad al cambiar de sesión. Un rol que siempre vale lo mismo no se puede depurar.

### 5.3 Los modelos

```ts
// src/app/core/models/auth.model.ts

/** Lo que el formulario de login manda al servidor. */
export interface AuthCredentials {
  readonly email: string;
  readonly password: string;
}

/** Lo que devuelve POST /auth/login. */
export interface LoginResponse {
  readonly accessToken: string;
  /** Vida del token en SEGUNDOS, tal como la declara el servidor. */
  readonly expiresIn: number;
}

export type UserRole = 'inspector' | 'supervisor';

/**
 * El contenido del JWT. No lo definimos nosotros: lo define quien firma el
 * token, y por eso esta interfaz es un contrato con el backend, no un modelo
 * de dominio. Si el mock cambia el payload, esto se queda mintiendo — de ahí
 * el type guard de 5.4.
 */
export interface AccessTokenPayload {
  /** El identificador del inspector: "INS-15". */
  readonly sub: string;
  readonly name: string;
  readonly role: UserRole;
  /** Emisión y expiración en SEGUNDOS desde epoch. No en milisegundos. */
  readonly iat: number;
  readonly exp: number;
}
```

### 5.4 `AuthService` — heredado

```ts
// src/app/core/auth.service.ts
import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, tap } from 'rxjs';

import { environment } from '../../environments/environment';
import {
  AccessTokenPayload,
  AuthCredentials,
  LoginResponse,
  UserRole,
} from './models/auth.model';

const TOKEN_STORAGE_KEY = 'certcore.accessToken';
const VALID_ROLES: readonly UserRole[] = ['inspector', 'supervisor'];

/**
 * Decodifica la parte de datos de un JWT sin ninguna librería.
 *
 * atob() devuelve una cadena binaria: un carácter por byte. El payload va en
 * UTF-8, y "Marín" ocupa dos bytes en la í — con atob a secas, el nombre del
 * supervisor sale roto. El rodeo por escapes hexadecimales lo rearma.
 * El ejercicio 14 te hace romperlo a propósito para que lo reconozcas.
 */
function decodeBase64Url(value: string): string {
  const base64 = value.replace(/-/g, '+').replace(/_/g, '/');
  const binary = atob(base64);
  const escaped = Array.from(
    binary,
    (character) => `%${character.charCodeAt(0).toString(16).padStart(2, '0')}`,
  ).join('');

  return decodeURIComponent(escaped);
}

/**
 * El token viene de fuera, así que llega como `unknown` y hay que estrecharlo.
 * Sin esto tendríamos que escribir `as AccessTokenPayload`, que es prometerle
 * al compilador algo que no podemos garantizar.
 */
function isAccessTokenPayload(value: unknown): value is AccessTokenPayload {
  if (typeof value !== 'object' || value === null) {
    return false;
  }

  const candidate = value as Record<string, unknown>;

  return (
    typeof candidate['sub'] === 'string' &&
    typeof candidate['name'] === 'string' &&
    typeof candidate['iat'] === 'number' &&
    typeof candidate['exp'] === 'number' &&
    VALID_ROLES.includes(candidate['role'] as UserRole)
  );
}

/**
 * 💸 DEUDA TÉCNICA INTENCIONAL
 * El token vive en localStorage. Cualquier script que se cuele en la página
 * —una dependencia comprometida, un XSS en un campo que alguien olvidó
 * escapar— puede leerlo y usarlo hasta que expire. Lo correcto es una cookie
 * httpOnly con refresh del lado del servidor, que el navegador manda sola y
 * el JavaScript de la página no puede leer.
 * NO SE PAGA EN ESTE CURSO, y el motivo es honesto: arreglarlo de verdad es
 * trabajo de backend, y CertCore no tiene uno propio. Lo que sí se lleva el
 * estudiante es saber nombrar el riesgo y estimar el cambio (ejercicio 26).
 */
@Injectable({ providedIn: 'root' })
export class AuthService {
  // Inyección por constructor: el estilo del código heredado, que es lo que
  // este archivo es. La comparación completa con inject() está en A04.
  constructor(private readonly http: HttpClient) {}

  login(credentials: AuthCredentials): Observable<LoginResponse> {
    return this.http
      .post<LoginResponse>(`${environment.apiBaseUrl}/auth/login`, credentials)
      // tap y no map: el efecto de guardar no transforma la respuesta, y quien
      // llama sigue recibiendo lo que el servidor mandó.
      .pipe(tap((response) => localStorage.setItem(TOKEN_STORAGE_KEY, response.accessToken)));
  }

  logout(): void {
    localStorage.removeItem(TOKEN_STORAGE_KEY);
  }

  getToken(): string | null {
    return localStorage.getItem(TOKEN_STORAGE_KEY);
  }

  /** El usuario de la sesión, o null si no hay token o el token no es legible. */
  getCurrentUser(): AccessTokenPayload | null {
    const token = this.getToken();

    if (token === null) {
      return null;
    }

    const parts = token.split('.');

    if (parts.length !== 3) {
      return null;
    }

    try {
      const parsed: unknown = JSON.parse(decodeBase64Url(parts[1]));

      return isAccessTokenPayload(parsed) ? parsed : null;
    } catch {
      // Un token manipulado a mano en localStorage llega aquí. No es un caso
      // teórico: es el ejercicio 19.
      return null;
    }
  }

  isAuthenticated(): boolean {
    const user = this.getCurrentUser();

    if (user === null) {
      return false;
    }

    // exp está en segundos y Date.now() en milisegundos. Confundirlos da una
    // sesión que expira en 1970 o dentro de cincuenta años, y las dos versiones
    // del bug se han visto en producción.
    // Aquí Date.now() es legítimo: comparamos instantes, no días de calendario.
    return user.exp * 1000 > Date.now();
  }
}
```

**Detalles con intención**

- **Se llama `AuthService` y no `AuthStateService`.** La guía de estilo §5.3 reserva el sufijo `StateService` para los servicios que guardan estado, y la sesión lo es. Ésta es la **única excepción documentada** de todo el curso, por dos razones: ningún proyecto del mundo llama `AuthStateService` a su servicio de auth, y renombrarlo en la Fase 4 rompería la estabilidad de nombres que exige §12. Se llama así hoy y hasta la Fase 14.
- **Cero `any` en el camino del token**, que es justo por donde entra lo que no controlas. `unknown` + type guard, y el `as Record<string, unknown>` sólo dentro del guard, que es su sitio.
- **`isAuthenticated()` abre el token cada vez que alguien pregunta.** Léelo otra vez, porque en 5.9 va a doler.

### 5.5 El login — heredado

```ts
// src/app/features/auth/login/login.component.ts
import { HttpErrorResponse } from '@angular/common/http';
import { Component } from '@angular/core';
import { FormBuilder, FormControl, FormGroup, Validators } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';

import { AuthService } from '../../../core/auth.service';

/**
 * El tipo del formulario, escrito a mano porque la migración de Angular 14 lo
 * dejó a medias. Ver la nota de abajo: ese `| null` no significa nada.
 */
interface LoginForm {
  email: FormControl<string | null>;
  password: FormControl<string | null>;
}

@Component({
  selector: 'cc-login',
  templateUrl: './login.component.html',
})
export class LoginComponent {
  readonly form: FormGroup<LoginForm>;

  errorMessage: string | null = null;
  submitting = false;

  constructor(
    private readonly formBuilder: FormBuilder,
    private readonly authService: AuthService,
    private readonly router: Router,
    private readonly route: ActivatedRoute,
  ) {
    // El formulario se arma en el constructor y no en el campo, porque el
    // campo se inicializaría antes de que formBuilder exista.
    this.form = this.formBuilder.group<LoginForm>({
      email: this.formBuilder.control('', [Validators.required, Validators.email]),
      password: this.formBuilder.control('', [Validators.required]),
    });
  }

  submit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    const { email, password } = this.form.getRawValue();

    // Esta guarda no puede dispararse nunca: los dos controles son requeridos
    // y el formulario ya pasó por invalid. Está aquí porque los controles se
    // tipan como `string | null` y strict exige tratarlo. Es el costo exacto
    // del `nonNullable` que nadie puso en 2022 — ver la nota de migración.
    if (email === null || password === null) {
      return;
    }

    this.submitting = true;
    this.errorMessage = null;

    this.authService.login({ email, password }).subscribe({
      next: () => {
        // returnUrl: a dónde iba el usuario cuando el guard lo interceptó.
        // Sin esto, todo el mundo aterriza en el panel y tiene que volver a
        // navegar, que es la clase de fricción que nadie reporta y todos odian.
        const returnUrl = this.route.snapshot.queryParamMap.get('returnUrl') ?? '/dashboard';
        void this.router.navigateByUrl(returnUrl);
      },
      error: (error: unknown) => {
        this.submitting = false;
        this.errorMessage =
          error instanceof HttpErrorResponse && error.status === 401
            ? 'Credenciales inválidas. Revisa el correo y la contraseña.'
            : 'No se pudo conectar con el servidor. Intenta de nuevo.';
      },
    });
  }
}
```

> 📝 **Nota de migración: el formulario a medio tipar.** Angular 14 hizo genéricos los formularios reactivos, y la migración automática convirtió cada `FormControl` en `FormControl<T | null>` sin preguntar — que es lo correcto, porque un control puede volver a `null` al hacer `reset()`. Lo que la migración no podía saber es que aquí el `null` **no significa nada**: el correo o está escrito o el formulario es inválido. Poner `nonNullable: true` habría hecho innecesaria la guarda de arriba. Nadie volvió a ponerlo, en éste ni en los otros treinta formularios del sistema, y así sigue. Los formularios de las Fases 6 en adelante se escriben con la nulabilidad decidida desde el principio; éste se queda como está, porque tocar un login que funciona para ganar un tipo no vale el riesgo. **El ejercicio 16 te hace medir cuánto costaría arreglarlo.**

```html
<!-- src/app/features/auth/login/login.component.html -->
<div class="login-page">
  <mat-card>
    <h1>CertCore</h1>
    <p>Inspecciones y certificaciones</p>

    <form [formGroup]="form" (ngSubmit)="submit()">
      <mat-form-field appearance="outline">
        <mat-label>Correo</mat-label>
        <input matInput type="email" formControlName="email" autocomplete="username" />
      </mat-form-field>

      <mat-form-field appearance="outline">
        <mat-label>Contraseña</mat-label>
        <input matInput type="password" formControlName="password" autocomplete="current-password" />
      </mat-form-field>

      <p class="login-error" *ngIf="errorMessage !== null">{{ errorMessage }}</p>

      <button mat-raised-button color="primary" type="submit" [disabled]="submitting">
        {{ submitting ? 'Entrando…' : 'Entrar' }}
      </button>
    </form>
  </mat-card>
</div>
```

```ts
// src/app/features/auth/auth.module.ts
import { NgModule } from '@angular/core';

import { SharedModule } from '../../shared/shared.module';
import { AuthRoutingModule } from './auth-routing.module';
import { LoginComponent } from './login/login.component';

@NgModule({
  declarations: [LoginComponent],
  // SharedModule trae ReactiveFormsModule y los doce de Material 💸 de la Fase 1.
  imports: [SharedModule, AuthRoutingModule],
})
export class AuthModule {}
```

```ts
// src/app/features/auth/auth-routing.module.ts
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';

import { LoginComponent } from './login/login.component';

const routes: Routes = [{ path: '', component: LoginComponent }];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class AuthRoutingModule {}
```

Con esto el árbol llega a los **diez NgModules además de `AppModule`** que la Fase 1 dejó apalabrados: `core`, `shared`, `layout` y siete features. Ese número lo va a usar la Fase 5.

### 5.6 El interceptor de clase — heredado, y no se toca

```ts
// src/app/core/interceptors/correlation-id.interceptor.ts
import {
  HttpEvent,
  HttpHandler,
  HttpInterceptor,
  HttpRequest,
} from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';

/**
 * Escrito en 2021 y sin tocar desde entonces. Estampa un identificador en cada
 * petición para que una línea del log del servidor se pueda casar con una
 * petición concreta del navegador — la trazabilidad es requisito del negocio,
 * no un lujo de observabilidad.
 *
 * Hoy se escribiría como HttpInterceptorFn, en diez líneas menos. No se
 * reescribe: funciona, nadie se ha quejado, y no hay ninguna línea suya que
 * haya que tocar. Modernizar sin motivo es cómo se rompen otras tres cosas.
 */
@Injectable()
export class CorrelationIdInterceptor implements HttpInterceptor {
  intercept(
    request: HttpRequest<unknown>,
    next: HttpHandler,
  ): Observable<HttpEvent<unknown>> {
    // Las peticiones son inmutables: clone() devuelve una nueva con la
    // cabecera añadida. Mutar `request` no haría nada y no daría error.
    const correlatedRequest = request.clone({
      setHeaders: { 'X-Correlation-Id': crypto.randomUUID() },
    });

    return next.handle(correlatedRequest);
  }
}
```

### 5.7 El interceptor funcional — nuevo

```ts
// src/app/core/interceptors/auth.interceptor.ts
import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError, throwError } from 'rxjs';

import { AuthService } from '../auth.service';

export const authInterceptor: HttpInterceptorFn = (request, next) => {
  // Se inyecta ARRIBA DEL TODO. Aquí seguimos dentro del contexto de
  // inyección; dentro del catchError de más abajo ya no estaríamos, y llamar a
  // inject() ahí da NG0203. Ver el ejercicio 10.
  const authService = inject(AuthService);
  const router = inject(Router);

  // El login es el único endpoint que no lleva token, por razones obvias, y
  // sobre todo es el único cuyo 401 significa "te equivocaste de contraseña"
  // en vez de "tu sesión caducó". Distinguirlo evita el bucle de la sección 6.
  const isLoginRequest = request.url.endsWith('/auth/login');
  const token = authService.getToken();

  const authorizedRequest =
    token === null
      ? request
      : request.clone({ setHeaders: { Authorization: `Bearer ${token}` } });

  return next(authorizedRequest).pipe(
    catchError((error: unknown) => {
      if (error instanceof HttpErrorResponse && error.status === 401 && !isLoginRequest) {
        authService.logout();
        // router.url es la ruta actual: la guardamos para volver después.
        void router.navigate(['/login'], { queryParams: { returnUrl: router.url } });
      }

      // El error se relanza SIEMPRE. El interceptor reacciona; no se traga el
      // fallo. Si se lo tragara, quien llamó creería que todo salió bien.
      return throwError(() => error);
    }),
  );
};
```

**El patrón a memorizar**

> Un interceptor reacciona y deja pasar. En cuanto uno se traga un error para "simplificar", el componente que lo llamó se queda esperando una respuesta que no va a llegar, y el bug aparece tres pantallas más allá sin nada en la consola.

### 5.8 El guard funcional — nuevo

```ts
// src/app/core/guards/auth.guard.ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';

import { AuthService } from '../auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }

  // Devolvemos un UrlTree en vez de llamar a router.navigate(): el router
  // cancela esta navegación y ejecuta la otra en un solo paso. Con navigate()
  // habría dos navegaciones compitiendo y el historial quedaría raro.
  return router.createUrlTree(['/login'], {
    queryParams: { returnUrl: state.url },
  });
};
```

> 🧭 **Regla del proyecto: dónde vive un guard.** Si protege rutas de más de una feature, va en `core/guards/` — es el caso de `authGuard`. Si es específico de una feature (un "no salgas de este formulario sin guardar", que llegará en la Fase 8), vive junto a esa feature. La regla evita el `core/` que acaba siendo el cajón de sastre del proyecto.

### 5.9 🧬 `CoreModule` — el punto de contacto

Éste es el archivo de la fase. Dos generaciones registrando dos interceptores en el mismo array.

```ts
// src/app/core/core.module.ts
import {
  HTTP_INTERCEPTORS,
  provideHttpClient,
  withInterceptors,
  withInterceptorsFromDi,
} from '@angular/common/http';
import { NgModule, Optional, SkipSelf } from '@angular/core';

import { CorrelationIdInterceptor } from './interceptors/correlation-id.interceptor';
import { authInterceptor } from './interceptors/auth.interceptor';

@NgModule({
  providers: [
    // 🧬 PUNTO DE CONTACTO ENTRE GENERACIONES
    // provideHttpClient() sustituye al HttpClientModule que este módulo
    // importaba en la Fase 1. Registra el cliente HTTP con dos features:
    //
    //   withInterceptorsFromDi() → sigue ejecutando los interceptores de
    //     CLASE registrados en HTTP_INTERCEPTORS. Sin esta línea, el
    //     CorrelationIdInterceptor de 2021 deja de correr EN SILENCIO.
    //   withInterceptors([...])  → registra los interceptores FUNCIONALES.
    //
    // El orden en que aparecen las dos features decide cuál cadena corre
    // primero. No lo des por sabido: compruébalo con un log (ejercicio 17).
    provideHttpClient(withInterceptorsFromDi(), withInterceptors([authInterceptor])),

    // El registro de 2021, intacto. `multi: true` porque HTTP_INTERCEPTORS es
    // un token de múltiples valores: cada interceptor añade el suyo.
    { provide: HTTP_INTERCEPTORS, useClass: CorrelationIdInterceptor, multi: true },
  ],
})
export class CoreModule {
  constructor(@Optional() @SkipSelf() parentModule?: CoreModule) {
    if (parentModule) {
      throw new Error(
        'CoreModule ya está cargado. Impórtalo únicamente en AppModule.',
      );
    }
  }
}
```

**Detalles con intención**

- **`HttpClientModule` salió de `imports` y de `exports`.** Nadie dependía de esa reexportación, así que el cambio es invisible desde fuera. Si tu proyecto sí dependiera, el error sería un `NullInjectorError` de `HttpClient` en el módulo que lo esperaba, y es exactamente el ejercicio 6 de la Fase 1 al revés.
- **Este archivo mezcla generaciones y no viola la regla.** La regla prohíbe escribir un componente standalone y un `NgModule` en el mismo archivo, o inyectar con `constructor` e `inject()` en la misma clase. Aquí no hay dos estilos de escritura: hay un módulo heredado **registrando** código de las dos épocas, que es literalmente su trabajo. Por eso lleva 🧬 y no 💸: no es deuda, es la costura.

### 5.10 Las rutas

```ts
// src/app/app-routing.module.ts — sólo lo que cambia
import { authGuard } from './core/guards/auth.guard';

const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'dashboard' },

  // El login es lazy como todo lo demás. Efecto colateral que se ve en
  // Network: su chunk se descarga en el instante en que el guard te rechaza.
  {
    path: 'login',
    loadChildren: () => import('./features/auth/auth.module').then((m) => m.AuthModule),
  },

  {
    path: 'dashboard',
    canActivate: [authGuard],
    loadChildren: () =>
      import('./features/dashboard/dashboard.module').then((m) => m.DashboardModule),
  },
  // …y lo mismo, canActivate: [authGuard], en clients, assets, templates,
  // inspections y certificates.

  { path: '**', component: NotFoundComponent },
];
```

**Detalles con intención**

- **El guard repetido seis veces, y no una ruta padre con `canActivateChild`.** La alternativa existe y es más corta, pero mete un nivel de anidamiento en el árbol de rutas que después hay que explicar cada vez que alguien añada una pantalla. Seis líneas repetidas y explícitas se leen mejor que una abstracción que ahorra cinco.
- **`canActivate` protege la ruta, no la descarga.** El chunk de `clients` se descarga sólo si el guard deja pasar, porque Angular evalúa el guard antes de resolver el `loadChildren`. Es un detalle que suele sorprender y que se comprueba en Network en diez segundos.

### 5.11 El shell aprende quién entró

Tocamos un archivo de 2021, así que **se escribe en el estilo de 2021**. Nada de convertirlo a standalone de paso.

```ts
// src/app/layout/shell/shell.component.ts — sólo lo que cambia
import { Router } from '@angular/router';

import { AuthService } from '../../core/auth.service';

export class ShellComponent {
  // …navigationItems y environmentName, de la Fase 1…

  /**
   * 💸 DEUDA TÉCNICA INTENCIONAL
   * `authService` es público para que la plantilla pueda llamar a
   * isAuthenticated() y getCurrentUser() directamente. Como este componente
   * usa detección de cambios por defecto, esos métodos se ejecutan en CADA
   * ciclo — y cada llamada decodifica el JWT entero: split, base64, JSON.parse.
   * Lo correcto es que el estado de sesión sea un observable y la plantilla lo
   * pinte con el pipe async, calculándose una sola vez por cambio real.
   * SE PAGA EN LA FASE 4, cuando AuthService exponga `currentUser$`.
   * El ejercicio 12 te hace contar las llamadas antes de creerte el número.
   */
  constructor(
    public readonly authService: AuthService,
    private readonly router: Router,
  ) {}

  logout(): void {
    this.authService.logout();
    void this.router.navigate(['/login']);
  }
}
```

```html
<!-- src/app/layout/shell/shell.component.html — sólo el bloque de la toolbar -->
<mat-toolbar color="primary">
  <!-- …botón de menú y título, de la Fase 1… -->
  <span class="shell-spacer"></span>

  <ng-container *ngIf="authService.getCurrentUser() as currentUser">
    <span class="shell-user">{{ currentUser.name }} · {{ currentUser.role }}</span>
    <button mat-icon-button (click)="logout()" aria-label="Cerrar sesión">
      <mat-icon>logout</mat-icon>
    </button>
  </ng-container>

  <span class="shell-environment">{{ environmentName }}</span>
</mat-toolbar>
```

**Detalles con intención**

- **`*ngIf … as currentUser`.** Sin el `as`, la plantilla llamaría a `getCurrentUser()` tres veces: una para el `*ngIf`, otra para el nombre y otra para el rol. Con el `as`, una sola vez por ciclo. Sigue siendo una vez de más —de ahí la 💸— pero no tres.
- **Con `strictTemplates` puesto, `currentUser` está tipado** como `AccessTokenPayload` dentro del bloque, no como `AccessTokenPayload | null`. Escribir `currentUser.nombre` no compila.

### 5.12 El 401, de punta a punta

**Prueba de fuego**

Baja `TOKEN_TTL_SECONDS` a `30` en el mock y reinícialo. Entra, quédate en el panel, espera medio minuto y navega a Inspecciones. Sigue el recorrido con Network abierto:

1. El token sigue en `localStorage`, pero su `exp` ya pasó, así que `isAuthenticated()` devuelve `false` y **el guard te manda al login sin que salga una sola petición HTTP**. La pestaña Network se queda vacía: nadie llegó a preguntarle nada al servidor.
2. Ahora prueba el otro camino: entra, y **antes de que expire** borra el secreto del mock y reinícialo, para que el token deje de validar sin haber caducado. Navega. Ahora el guard sí deja pasar —el `exp` es futuro—, la petición sale con su `Authorization`, y el servidor devuelve `401`. El **interceptor** lo caza, borra el token y te manda al login.

Son dos caminos distintos al mismo sitio, y saber cuál te echó es la mitad de la pieza forense de esta fase.

---

## ⚠️ 6. Errores comunes y pieza forense

### Errores comunes

**Síntoma:** `NullInjectorError: No provider for _HttpClient!` justo después de tocar `CoreModule`.
**Causa:** quitaste `HttpClientModule` y no llegaste a poner `provideHttpClient()`, o lo pusiste en `imports` en vez de en `providers`. `provideHttpClient()` devuelve proveedores, no un módulo.
**Fix mínimo:** moverlo al array correcto.
**Lo que importa:** el error es idéntico al de la Fase 1, y eso es una buena noticia: `NullInjectorError` siempre significa lo mismo, cambie la sintaxis que cambie.

**Síntoma:** la cabecera `X-Correlation-Id` desapareció de todas las peticiones. Ningún error, ninguna advertencia, la aplicación funciona.
**Causa:** falta `withInterceptorsFromDi()` en `provideHttpClient()`. Los interceptores de clase registrados en `HTTP_INTERCEPTORS` dejan de estar en la cadena.
**Fix mínimo:** añadir la feature.
**Lo que importa:** éste es el fallo más peligroso de la fase, porque **no se ve**. La aplicación no se rompe: sólo deja de ser trazable, y te enteras dentro de tres meses cuando alguien pida correlacionar un incidente con un log y no haya con qué. Los bugs que no rompen nada son los que sobreviven años.

**Síntoma:** `NG0203: inject() must be called from an injection context`.
**Causa:** un `inject()` dentro de un `catchError`, un `subscribe` o un `setTimeout`. Para cuando ese callback corre, Angular ya cerró el contexto.
**Fix mínimo:** subir la llamada al principio de la función y usar la referencia capturada.
**La refactorización correcta:** la misma. No hay una versión elaborada de esto; es un hábito, y el hábito es "inyecta arriba".

**Síntoma:** escribes mal la contraseña y en vez del mensaje de error te redirige al login… donde ya estabas.
**Causa:** el `401` del propio `POST /auth/login` entra por el `catchError` del interceptor, que hace `logout()` y navega. El componente nunca llega a pintar su mensaje.
**Fix mínimo:** el `isLoginRequest` de 5.7.
**Lo que importa:** es el bug más instructivo de la fase, porque nace de aplicar una regla correcta —"un 401 significa sesión caducada"— a un caso donde no aplica. **Un interceptor global tiene que saber de qué peticiones no es responsable**, y esa lista crece con el sistema.

### Pieza forense de esta fase

**¿Dónde pongo el breakpoint en un interceptor funcional?** El cuerpo de la función corre **una vez por petición**, en el momento de lanzarla: ahí es donde ves la URL, el token y la request clonada. El callback del `catchError` corre **después**, cuando la respuesta vuelve, y para entonces las variables inyectadas sólo existen porque quedaron capturadas en el closure. Si quieres inspeccionar la respuesta, el breakpoint va dentro del `catchError`; si quieres inspeccionar lo que sale, va antes del `return`. Poner uno solo y esperar ver las dos cosas es la media hora que se pierde la primera vez.

**¿Me echó el guard o me echó el interceptor?** Es la pregunta que más vas a hacerte, y se contesta en Network sin abrir el código:

- **Sin ninguna petición fallida y con la URL en `/login?returnUrl=…`** → fue el guard. Ni siquiera se intentó hablar con el servidor: `isAuthenticated()` dijo que no y la navegación se canceló antes de empezar.
- **Con una petición en rojo, status `401`, y luego la redirección** → fue el interceptor. El token existía y parecía válido desde el navegador; el servidor opinó distinto.

La distinción importa porque las causas no se parecen en nada. El primero es un problema de reloj o de token ausente, del lado del cliente. El segundo es un problema de firma, de secreto o de expiración real, del lado del servidor.

**¿Qué cabecera puso quién?** En Network, pestaña Headers, sección Request Headers. `Authorization` la puso el funcional; `X-Correlation-Id`, el de clase. Si falta una de las dos, ya sabes qué mitad de `provideHttpClient()` mirar.

> 📄 El recorrido completo, con los mensajes literales de cada paso, en `forense-fase-02.md`.

**🧨 Rompe a propósito**

Quita `withInterceptorsFromDi()` de `provideHttpClient()`, dejando el `HTTP_INTERCEPTORS` intacto en el array de abajo. Recarga, entra, navega, y responde:

1. ¿Dio Angular algún error, advertencia o mensaje de cualquier tipo?
2. ¿Sigue apareciendo `Authorization` en las peticiones? ¿Y `X-Correlation-Id`?
3. Si un compañero hiciera este cambio en un pull request, ¿qué habría tenido que mirar el revisor para detectarlo?
4. ¿Qué prueba automatizada lo habría cazado? Descríbela; escribirla es de la Fase 12.

---

## 🧪 7. Ejercicios (28)

**🟢 Fácil (1–8)**

1. Instala `express@4.18.2` y `jsonwebtoken@9.0.2` con esas versiones exactas y demuestra con `npm ls express jsonwebtoken` que no quedó ningún `^`.
2. Levanta el mock y consigue un token con `curl`. Decodifica el payload sin salir de la terminal (`node -e "console.log(JSON.parse(Buffer.from(process.argv[1].split('.')[1],'base64url')))" "<token>"`) y anota `sub`, `role`, `iat` y `exp`. Convierte el `exp` a hora local y comprueba que es dentro de una hora.
3. Entra desde la interfaz y verifica en DevTools → Application → Local Storage que la clave es exactamente `certcore.accessToken`. Bórrala a mano, recarga, y confirma que vuelves al login.
4. **Diagnóstico.** Sin sesión, escribe `/clients` en la barra de direcciones. Responde: ¿cuántas peticiones HTTP salieron? ¿Qué dice la URL después del rechazo? ¿Se descargó el chunk de `clients`?
5. Con sesión abierta, navega a Inspecciones y localiza en Network las dos cabeceras. Di cuál interceptor puso cada una, y en qué archivo vive cada uno.
6. **Diagnóstico.** Haz el 🧨 de la sección 6 y entrega las cuatro respuestas.
7. Cierra sesión con el botón de la toolbar y comprueba que `/certificates` ya no es accesible. Explica quién te lo impidió, el guard o el interceptor, y cómo lo sabes.
8. Entra como `supervisor@certcore.co` y confirma que la toolbar cambia. Explica por qué eso **no** significa que el sistema tenga roles.

**🟡 Intermedio (9–16)**

9. **Diagnóstico.** Comenta la condición `!isLoginRequest` del interceptor. Intenta entrar con una contraseña incorrecta y describe exactamente qué ocurre y por qué el mensaje de error nunca llega a pintarse. Restáuralo.
10. **Diagnóstico.** Mueve `const router = inject(Router)` dentro del callback del `catchError`. Provoca un 401, captura el error literal, y explica con tus palabras qué es el contexto de inyección y por qué ahí ya se cerró. Enlaza tu explicación con **A04**.
11. Comprueba el `returnUrl` de punta a punta: sin sesión, entra directo a `/templates`, autentícate, y verifica que aterrizas en `/templates`. Después rompe el `?? '/dashboard'` y explica qué pasa si alguien llega al login sin `returnUrl`.
12. **Diagnóstico.** Añade `console.count('decode')` al principio de `getCurrentUser()`. Navega entre tres rutas, abre y cierra el sidenav, y anota el número final. Es la 💸 que paga la Fase 4: escribe el número en `deuda.md`, junto al de la Fase 1.
13. 🧬 Reescribe `authGuard` como su equivalente de clase (`@Injectable()` con `implements CanActivate`) en una rama de usar y tirar. Cuenta las líneas de cada versión, y responde: si mañana tuvieras que añadir un `supervisorGuard` que reutilice esta lógica, ¿cuál de las dos formas te lo pone más fácil, y compensa?
14. **Diagnóstico.** Sustituye `decodeBase64Url(parts[1])` por `atob(parts[1])` a secas. Entra como `supervisor@certcore.co` y describe qué pasa con "Diego Marín" en la toolbar. Explica por qué con el inspector no se nota.
15. Haz que el mock escriba en consola el `X-Correlation-Id` de cada petición que recibe. Provoca una navegación, y casa una línea de la terminal con una petición concreta de Network. Ésa es la razón de que ese interceptor exista.
16. Mide el costo real de arreglar el formulario de login: pon `nonNullable: true` en los dos controles, ajusta el tipo `LoginForm`, borra la guarda imposible y comprueba que todo compila y funciona. Cuenta las líneas que cambiaron. Después **revierte**, y argumenta en tres frases si lo harías en un viernes por la tarde con el sistema en producción.

**🟠 Difícil (17–23)**

17. **Diagnóstico.** Averigua experimentalmente cuál cadena de interceptores corre primero: añade un `console.log` a cada uno, prueba con `withInterceptorsFromDi()` antes y después de `withInterceptors([...])`, y documenta el método y el resultado. No busques la respuesta en la documentación antes de medirla.
18. Haz que el mock devuelva `500` en `/inspections`. Comprueba que el interceptor **no** cierra la sesión y explica por qué eso está bien, y qué habría que cambiar si el negocio pidiera reintentar automáticamente.
19. **Diagnóstico.** Escribe a mano en `localStorage` un token con tres partes pero con el payload corrupto (`certcore.accessToken` = `"aaa.bbb.ccc"`). Recarga y describe qué pasa en cada capa: `decodeBase64Url`, `JSON.parse`, el type guard, `isAuthenticated()`, el guard y la pantalla. Di cuál de esas capas te salvó.
20. Escribe un `guestGuard` funcional que impida entrar a `/login` cuando ya hay sesión, y redirija al panel. Criterio: con sesión abierta, escribir `/login` te devuelve a `/dashboard` sin parpadeo.
21. **Diagnóstico.** Haz que el mock firme un token ya vencido (`expiresIn: -60`). Entra y describe la secuencia completa: ¿quién lo detecta primero, el cliente o el servidor? ¿Qué ve el usuario? ¿Y qué habría pasado si el reloj del navegador estuviera diez minutos atrasado?
22. 🧬 Te piden mostrar en la toolbar el nombre del cliente cuya inspección se está viendo. Eso toca `ShellComponent` (2021) y va a necesitar un dato que hoy no existe. Sin escribir el código, entrega: en qué estilo escribes el cambio en cada archivo que toques, qué archivos nuevos creas y en qué estilo, y qué regla del proyecto aplicas en cada decisión.
23. Mide el chunk de `auth` con `ng build` y explica en qué momento exacto se descarga. Después responde: si `AuthModule` fuera eager, ¿qué mejoraría y qué empeoraría, y para qué tipo de usuario de CertCore?

**🔴 Muy difícil (24–28)**

24. Escribe el post-mortem completo de ocho puntos del incidente **03** siguiendo `formato-cuaderno-incidentes.md` §7, y márcalo en git con el par `inc/03/<slug>-roto` / `-fix` según la convención. El `git diff` entre los dos tags tiene que ser el punto 5 del post-mortem y nada más.
25. **Diagnóstico.** Abre CertCore en dos pestañas con la misma sesión. Cierra sesión en una. Describe con precisión el estado del sistema en la otra: qué muestra la toolbar, qué pasa si navega, qué pasa si envía una petición. Propón **tres** formas de arreglarlo (evento `storage`, sondeo, cambiar dónde vive la sesión), con el costo de cada una. No implementes ninguna.
26. Escribe una página para tu líder técnico argumentando el riesgo del token en `localStorage`: el ataque concreto y sus precondiciones, qué se pierde exactamente si ocurre, qué haría falta para pasar a cookie `httpOnly` con refresh, cuánto de ese trabajo es de backend, y tu recomendación. Sin dramatizar y sin citar a nadie: con el sistema que tienes delante.
27. **Diagnóstico.** Ticket: *"a veces me saca al login sin avisar, sobre todo cuando llevo un rato con la pantalla abierta"*. Construye un árbol de diagnóstico con al menos cinco causas posibles —expiración, reloj desincronizado, secreto rotado en el servidor, token borrado por otra pestaña, un 401 de un endpoint distinto al que crees—, provoca tres de ellas, y verifica que tu árbol las separa en menos de cuatro pasos.
28. Dispara dos peticiones a la vez con el token caducado (dos componentes que cargan datos en la misma pantalla). Demuestra que hoy se ejecutan **dos** `logout()` y **dos** navegaciones. Explica por qué normalmente no se nota, en qué caso sí se notaría, y arréglalo con el cambio más pequeño que se te ocurra — sin introducir estado compartido, que es de la Fase 4.

**🔥 Opcionales**

- 🔥 Implementa el cierre de sesión sincronizado entre pestañas con el evento `storage` de `window`. Mide qué pasa cuando hay tres pestañas.
- 🔥 Investiga qué haría falta para un refresh token de verdad: qué endpoint, qué pasa con las peticiones en vuelo mientras se refresca, y por qué eso obliga a poner una cola en el interceptor. Escríbelo; no lo implementes.
- 🔥 Sustituye el decodificado a mano por una librería (`jwt-decode`). Mide qué añade al bundle y decide si compensa para tres campos.

---

## 📚 8. Referencias

**Documentación oficial**

- https://v16.angular.io/guide/http#intercepting-requests-and-responses — interceptores en la 16, con las dos formas documentadas una al lado de la otra. Es la referencia central de esta fase.
- https://v16.angular.io/api/common/http/HttpInterceptorFn y https://v16.angular.io/api/common/http/withInterceptorsFromDi — las firmas exactas de lo que escribiste en 5.7 y 5.9.
- https://v16.angular.io/api/router/CanActivateFn — el guard funcional y qué puede devolver, incluido el `UrlTree`.
- https://v16.angular.io/guide/router-tutorial-toh#milestone-5-route-guards — el tutorial de guards. ⚠️ Usa guards de clase en varios ejemplos, porque es material anterior a la 15: léelo por los conceptos, no por la sintaxis.
- https://v16.angular.io/errors/NG0203 — el error de `inject()` fuera de contexto, explicado por Angular mejor de lo que suele explicarse.
- https://github.com/auth0/node-jsonwebtoken/tree/v9.0.2 — `sign`, `verify` y qué lanza cada uno.
- https://developer.mozilla.org/es/docs/Web/API/Window/localStorage y https://developer.mozilla.org/es/docs/Glossary/Base64 — el `atob` y por qué rompe con UTF-8 (la sección "The Unicode Problem" es exactamente el bug del ejercicio 14).
- https://cheatsheetseries.owasp.org/cheatsheets/HTML5_Security_Cheat_Sheet.html — la referencia para el ejercicio 26. ⚠️ Verifica la URL: OWASP reorganiza sus guías cada tanto.

> ⚠️ Buena parte de lo que encuentres sobre autenticación en Angular es de 2019-2022 y usa guards e interceptors de clase. **No está mal** —esa forma sigue funcionando en la 16 y CertCore tiene uno— pero no es lo que escribes en código nuevo. Y si acabas en `angular.dev`, estás en la 17+: ahí `CanActivate` de clase ya está deprecado y los ejemplos no aplican tal cual.

**Video y apoyo**

- La charla "Functional Guards and Interceptors" del equipo de Angular, de la época de la 15-16, es la mejor explicación corta del cambio; búscala por título en el canal oficial de Angular en YouTube. ⚠️ Los identificadores de video cambian y no vamos a inventar uno.

**Orden de lectura sugerido**

Antes de escribir código: la guía de `HttpClient` en la sección de interceptores, entera, que son diez minutos y contesta la mitad de la fase. Durante: la página de `CanActivateFn` cuando llegues a 5.8, y **A04** en cuanto el `inject()` te dé el primer NG0203 — que te lo va a dar. Después: **A06**, si el `catchError` con `throwError` te resultó opaco; el operador se usa igual en las Fases 3, 4 y 8, así que vale la pena que quede claro hoy.

---

## 🚀 9. Cierre y conexión con la siguiente fase

CertCore ya distingue quién entra. Tienes un servidor que firma tokens, un servicio que los guarda y los lee, un guard que decide, un interceptor que los adjunta y otro, escrito tres años antes, que sigue estampando su identificador de correlación sin enterarse de nada. Y tienes la costura 🧬 vista y marcada: seis líneas en `core.module.ts` donde 2021 y 2024 se dan la mano.

Lo que te llevas no es el login. Es haber visto que **las dos generaciones no compiten: se registran juntas**, y que la decisión de cuál usar depende de si el archivo es nuevo o heredado, no de cuál te guste más.

La **Fase 3** convierte esas cuarenta líneas de Express en el mock de verdad: json-server con el `db.json` del dominio completo —clientes, activos, plantillas versionadas, inspecciones, certificados— y, encima, el **inyector de caos** que vas a construir tú: latencia, `500` intermitentes, respuestas malformadas, CORS roto, timeouts y, sí, tokens expirados. El manejo del 401 que escribiste hoy es lo que va a hacer que ese último fallo sea observable en vez de misterioso.

> **La señal de que quedó bien:** cuando te sacan al login y, antes de tocar el código, ya sabes en qué pestaña mirar para saber si fue el guard o el servidor.

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de la sección 2 en
> verde y `git status` limpio:
>
> ```bash
> git tag -a fase-02 -m "F2 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`fase 02: …`) y los de ejercicio su
> número (`fase 02 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f02/17`, y un incidente resuelto en el par `inc/<ID>/<slug>-roto` /
> `-fix`, con el ID que le reserva el cuaderno. Todo eso está en
> [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
>
> Esta fase estrena el par de tags de incidente: el **03** sale de aquí, y su
> rama de partida es este mismo commit (`git switch -c incidente/03 fase-02`).
> Etiqueta también que `mock/db.json` se fue: si algún día quieres ver cómo era
> el mock antes de tener lógica, `fase-01` es el único sitio donde existe.

---

## 📌 Pendientes sugeridos

- **La excepción de nombrado de `AuthService`.** La guía §5.3 pide `*StateService` para lo que guarda estado y la sesión lo es. Esta fase declara la excepción y la justifica, pero debería quedar escrita en la guía para que no la reabra ningún chat posterior. → **Decisión de proyecto**, una línea en §5.3.
- **La 💸 del shell la cobra la Fase 4.** Cuando `AuthService` exponga `currentUser$` y la toolbar lo pinte con `async`, hay que volver aquí y comprobar que el número del ejercicio 12 baja. Si la Fase 4 no toca auth, esta deuda se queda sin pagador y hay que declararla no pagada. → **Aviso para el chat de la Fase 4.**
- **El `role` que no autoriza.** El token lo trae, la toolbar lo muestra, y nada lo usa. Es coherente con el alcance, pero es la clase de cosa que un lector espera que se cierre. Merece dos párrafos en algún sitio sobre por qué autorizar en el cliente es teatro. → **Fase 12**, junto a la prueba del guard, o ejercicio 🔥 de la Fase 9.
- **El secreto del mock, en claro y versionado.** Correcto para un mock, y una pésima costumbre si se traslada. La conversación completa —qué es un secreto, por qué un Secret de Kubernetes tampoco lo es— vive en **A09**, y la Fase 13 la toca de refilón. Hoy sólo queda la advertencia.
- **La cola de peticiones del ejercicio 28** es el 80% de lo que hace falta para un refresh token real. Si alguna vez el curso quiere ese material, es un apéndice 🔥, no una fase.
- 🔥 **Un diagrama del recorrido de una petición** —componente → interceptor funcional → interceptor de clase → red → vuelta— ayudaría en 5.9 y en la pieza forense. Pendiente de ilustración, no de contenido.

### Reservas para el cuaderno de incidentes

Los enunciados ya están escritos en el índice de [`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**

| ID | Título | Categoría | Dif. |
|---|---|---|---|
| 03 | "Entro con mi usuario y me saca al login sin decir nada" | Integración | 🟢 |
