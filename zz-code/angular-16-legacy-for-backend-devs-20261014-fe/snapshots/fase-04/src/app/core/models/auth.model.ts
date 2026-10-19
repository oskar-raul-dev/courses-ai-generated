
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
