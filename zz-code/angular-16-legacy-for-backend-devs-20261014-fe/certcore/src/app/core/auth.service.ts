import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, tap } from 'rxjs';

import { AppConfigService } from './config/app-config.service';
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
  // La sesión vive en un sujeto: el usuario actual se decodifica una vez por
  // cambio real (arranque, login, logout) y no en cada consulta. Ver la 💸 de la
  // Fase 2 y su pago en la Fase 4.
  private readonly currentUserSubject = new BehaviorSubject<AccessTokenPayload | null>(null);

  readonly currentUser$: Observable<AccessTokenPayload | null> =
    this.currentUserSubject.asObservable();

  // Inyección por constructor: el estilo del código heredado, que es lo que
  // este archivo es. La comparación completa con inject() está en A04.
  constructor(
    private readonly http: HttpClient,
    private readonly appConfig: AppConfigService,
  ) {
    // La sesión puede existir antes de que la aplicación arranque: el token
    // sobrevive a la recarga. Se decodifica UNA vez, aquí.
    this.currentUserSubject.next(this.readUserFromStorage());
  }

  login(credentials: AuthCredentials): Observable<LoginResponse> {
    return this.http
      .post<LoginResponse>(`${this.appConfig.current.apiBaseUrl}/auth/login`, credentials)
      // tap y no map: el efecto de guardar no transforma la respuesta, y quien
      // llama sigue recibiendo lo que el servidor mandó.
      .pipe(
        tap((response) => {
          localStorage.setItem(TOKEN_STORAGE_KEY, response.accessToken);
          this.currentUserSubject.next(this.readUserFromStorage());
        }),
      );
  }

  logout(): void {
    localStorage.removeItem(TOKEN_STORAGE_KEY);
    // Emitir null es lo que dispara el reset() de todos los servicios de estado
    // que estén escuchando. Nadie tiene que acordarse de limpiar nada.
    this.currentUserSubject.next(null);
  }

  getToken(): string | null {
    return localStorage.getItem(TOKEN_STORAGE_KEY);
  }

  /** Sigue siendo síncrono porque el guard lo necesita síncrono. */
  isAuthenticated(): boolean {
    const user = this.currentUserSubject.value;

    // exp está en segundos y Date.now() en milisegundos. Confundirlos da una
    // sesión que expira en 1970 o dentro de cincuenta años, y las dos versiones
    // del bug se han visto en producción.
    // Aquí Date.now() es legítimo: comparamos instantes, no días de calendario.
    return user !== null && user.exp * 1000 > Date.now();
  }

  getCurrentUser(): AccessTokenPayload | null {
    // Ya no decodifica: lee el valor que el sujeto tiene guardado. Éste es el
    // cambio que paga la deuda, y se mide con el console.count del ejercicio 8.
    return this.currentUserSubject.value;
  }

  /** El decodificado de verdad, ahora en un solo sitio y llamado dos veces por sesión. */
  private readUserFromStorage(): AccessTokenPayload | null {
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
}
